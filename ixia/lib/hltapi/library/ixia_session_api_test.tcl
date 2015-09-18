
proc ::ixia::test_control {args} {

    variable objectMaxCount
    variable executeOnTclServer
    variable ignoreLinkState
    variable ixnetworkVersion
    variable no_more_tclhal

    if {[info exists linkState]} {
        unset linkState
    }

    set procName [lindex [info level [info level]] 0]
    
    ::ixia::logHltapiCommand $procName $args
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::test_control $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args

    set mandatory_args {
        -action             CHOICES start_all_protocols stop_all_protocols start_protocol stop_protocol abort_protocol check_link_state \
                            get_all_qt_handles get_available_qt_types get_qt_handles_for_type qt_remove_test qt_apply_config qt_start qt_run qt_stop qt_wait_for_test \
                            is_done wait get_result qt_get_input_params
    }
    
    set opt_args {
        -port_handle        REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -handle             ANY
        -desired_status     CHOICES busy up down unassigned
                            DEFAULT up
        -timeout            NUMERIC
                            DEFAULT 60
        -qt_handle          ANY
        -result_handle      ANY
        -qt_type            ANY
		-input_params		ANY
        -action_mode        CHOICES sync async
                            DEFAULT sync
        -action_on_failure  CHOICES stop continue
                            DEFAULT continue
	}
    if {[catch {::ixia::parse_dashed_args -args $args \
            -mandatory_args $mandatory_args -optional_args $opt_args} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg"
        return $returnList
    }

    proc _startstop_protocol_handle {handle action ixnet_err_ref} \
    {
        upvar $ixnet_err_ref ixnet_err
        if {[catch "ixNet exec $action $handle" ixnet_err] || \
            ([string first "::ixNet::OK" $ixnet_err] == -1) \
        } {
            return 0
        }
        return 1
    }
    if {[info exists action]} {
        switch -- $action {
            start_all_protocols {
                if {[catch {ixNet exec startAllProtocols} retCode] || \
                ([string first "::ixNet::OK" $retCode] == -1)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to start Protocols !!!"
                    return $returnList
                }
            }
            stop_all_protocols {
                if {[catch {ixNet exec stopAllProtocols} retCode] || \
                ([string first "::ixNet::OK" $retCode] == -1)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to stop Protocols !!!"
                    return $returnList
                }
            }
            start_protocol \
            {
                foreach handle_item $handle \
                {
                    # try the handle and the parent
                    set parent_handle [join [lrange [split $handle_item /] 0 end-1] /]
                    if {![_startstop_protocol_handle $handle_item "start" ixnet_err] && \
                        ![_startstop_protocol_handle $parent_handle "start" ixnet_err] \
                    } {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed to start protocol for handle $handle_item: $ixnet_err"
                        return $returnList
                    }
                }
            }
            stop_protocol \
            {
                foreach handle_item $handle \
                {
                    # try the handle and the parent
                    set parent_handle [join [lrange [split $handle_item /] 0 end-1] /]
                    if {![_startstop_protocol_handle $handle_item "stop" ixnet_err] && \
                        ![_startstop_protocol_handle $parent_handle "stop" ixnet_err] \
                    } {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed to stop protocol for handle $handle_item: $ixnet_err"
                        return $returnList
                    }
                }
            }
            abort_protocol \
            {
                foreach handle_item $handle \
                {
                    # try the handle and the parent
                    set parent_handle [join [lrange [split $handle_item /] 0 end-1] /]
                    if {![_startstop_protocol_handle $handle_item "abort" ixnet_err] && \
                        ![_startstop_protocol_handle $parent_handle "abort" ixnet_err] \
                    } {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed to abort protocol for handle $handle_item: $ixnet_err"
                        return $returnList
                    }
                }
            }
            check_link_state {
                if {![info exists desired_status]} {
                    set desired_status up
                }
                
                if {![info exists timeout]} {
                    set timeout 60
                }
                if {![info exists port_handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: -port_handle attribute is mandatory if -action is check_link_state. Please configure -port_handle attribute."
                    return $returnList
                }
                # go through all the ports and label the ones whose links are not as desieredStatus
                foreach port $port_handle {
                    if {![info exists linkState($port)]} {
                        set vportObjRef [::ixia::ixNetworkGetPortObjref $port]
                        set vportObj [keylget vportObjRef vport_objref]
                        set state   [ixNet getAttribute $vportObj -state]
                        if {$state != $desired_status } {
                            set linkState($port)    $state
                        }
                        if { $state == "up" && [ixNet getAttribute $vportObj -isConnected] == "false" } {
                            set linkState($port)    $state
                        }
                    }
                }

                # the linkState array are all the ports whose links are not desired. Now poll
                # them a few times until they are all desired or return.
                set loopCount   [expr $timeout * 2] 
                for {set ctr 0} {$ctr < $loopCount} {incr ctr} {
                    foreach downlink [array names linkState] {
                        set vportObjRef [::ixia::ixNetworkGetPortObjref $downlink]
                        set vportObj [keylget vportObjRef vport_objref]
                        set state   [ixNet getAttribute $vportObj -state]
                        if {$state == $desired_status } {
                            if { $state == "up" && [ixNet getAttribute $vportObj -isConnected] == "false" } {
                                continue
                            }
                            unset linkState($downlink)
                        }
                    }
                    if {[llength [array names linkState]] == 0} {
                        break
                    } else {
                        after 500
                    }
                }

                if {[llength [array names linkState]] == 0} {
                    foreach port $port_handle {
                        keylset returnList $port.state $desired_status
                    }
                } else {
                
                    set portsToRemove [array names linkState]
                    
                    foreach port $portsToRemove {
                        set index [lsearch $port_handle $port]
                        set port_handle [lreplace $port_handle $index $index]
                    }
                    
                    foreach port $port_handle {
                        keylset returnList $port.state $desired_status
                    }                    

                    foreach downlink [array names linkState] {
                        keylset returnList $downlink.state $linkState($downlink)
                    }
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Not all ports are in desired status : $desired_status !"
                    return $returnList
                }
            }
            
            get_all_qt_handles {
                debug "ixNet getAttr [ixNet getRoot]/quickTest -testIds"
                if { [catch {ixNet getAttr [ixNet getRoot]/quickTest -testIds} retCode] } {                
                    debug "ERROR in $procName: $retCode"
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to get QuickTest handles !!!"
                    return $returnList
                }
                keylset returnList qt_handle $retCode
            }

            get_available_qt_types {
                debug "Getting quicktest types"
                set qt_types ""
                if [ catch {
                    set ixNetRoot [ixNet getRoot]
                    set tmpList [regexp -all -inline {\n\s+(\w+)\s\(kList} [lindex [regexp -inline {Child Lists:(.*)Attributes:} [ixNet help $ixNetRoot\quickTest]] 1]]
                    foreach {match qt_matched} $tmpList {lappend qt_types  "$ixNetRoot\quickTest/$qt_matched"}
                    unset tmpList
                } err ] {
                    debug "Failed to get quicktests: $err"
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to get the list of QuickTest types !!!"
                    return $returnList
                }
                keylset returnList qt_types $qt_types
            }
            
            get_qt_handles_for_type {
                if {![info exists qt_type]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: -qt_type attribute is\
                            mandatory if -action is get_qt_handles_for_type. Please\
                            configure -qt_type attribute."
                    return $returnList
                }
                set qt_handles {}
                foreach type $qt_type {
                    debug "Trying to get $type"
                    if { [catch {ixNet getList ::ixNet::OBJ-/quickTest [lindex [split "/$type" "/"] end] } retCode] } {
                        debug "ERROR in $procName: $retCode"
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed to get QuickTest handles !!!"
                        return $returnList
                    }
                    lappend qt_handles $retCode
                }
                keylset returnList qt_handle $qt_handles
            }
            
            qt_remove_test  {
                if {![info exists qt_handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: -qt_handle attribute is mandatory if -action is qt_remove_test. Please configure -qt_handle attribute."
                    return $returnList
                }
                # Validating the qt_handle
                set valid_tests [ixNet getA [ixNet getRoot]quickTest -testIds]
                set invalid_handles ""
                foreach handle $qt_handle {
                    if { [lsearch $valid_tests $handle] < 0 } { lappend invalid_handles $handle }
                }
                if { $invalid_handles != "" } {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Invalid qt_handles provided: $invalid_handles !!!"
                    return $returnList
                }
                set  error_count 0
                set  failed_qt {}
                foreach handle $qt_handle {
                    debug "ixNet remove ${handle}"
                    if { [catch {ixNet remove ${handle} } retCode] || \
                        ([string first "::ixNet::OK" $retCode] == -1)} {   
                        debug "ERROR while removing $handle: $retCode"
                        incr error_count
                        lappend failed_qt $handle
                        keylset returnList ${handle}.status $::FAILURE
                        keylset returnList ${handle}.log "ERROR in $procName: Failed to remove QuickTest config for ${handle} !!!"
                        if { $action_on_failure == "continue" } {
                            continue
                        } else {
                            break
                        }
                    } else {
                        keylset returnList ${handle}.status $::SUCCESS
                    }
                }
                debug "ixNet commit"
                if { [catch {ixNet commit } retCode] || \
                    ([string first "::ixNet::OK" $retCode] == -1)} {   
                    debug "ERROR in $procName: $retCode"
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to commit changes !!!"
                    return $returnList
                }
                if {$error_count} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to remove $error_count QuickTest configs: $failed_qt  !!!"
                    return $returnList 
                }
            }
            
            qt_apply_config {
                if {![info exists qt_handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: -qt_handle attribute is mandatory if -action is qt_apply_config. Please configure -qt_handle attribute."
                    return $returnList
                }
                # Validating the qt_handle
                set valid_tests [ixNet getA [ixNet getRoot]quickTest -testIds]
                set invalid_handles ""
                foreach handle $qt_handle {
                    if { [lsearch $valid_tests $handle] < 0 } { lappend invalid_handles $handle }
                }
                if { $invalid_handles != "" } {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Invalid qt_handles provided: $invalid_handles !!!"
                    return $returnList
                }
                if { $action_mode == "async" } {
                    # Individual handle is needed for the async operations
                    if { [llength $qt_handle] != 1 } {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Single handle is expected for the parameter -qt_handle, when -action is $action and -async_mode is async. !!!"
                        return $returnList   
                    }
                    debug "ixNet -async exec apply ${qt_handle}"
                    if { [catch {ixNet -async exec apply ${qt_handle} } retCode] } {                
                        debug "ERROR in $procName: $retCode"
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed to apply QuickTest config  !!!"
                        return $returnList
                    }
                    keylset returnList ${qt_handle}.result_handle $retCode
                } else  {          
                    #sync
                    set  error_count 0
                    set  failed_qt {}
                    foreach handle $qt_handle {
                        debug "ixNet exec apply ${handle} "
                        if { [catch {ixNet exec apply ${handle} } retCode] || \
                            ([string first "::ixNet::OK" $retCode] == -1)} {   
                            debug "ERROR while applying $handle: $retCode"
                            incr error_count
                            lappend failed_qt $handle
                            keylset returnList ${handle}.status $::FAILURE
                            keylset returnList ${handle}.log "ERROR in $procName: Failed to apply QuickTest !!!"
                            if { $action_on_failure == "continue" } {
                                continue
                            } else {
                                break
                            }
                        }
                        keylset returnList ${handle}.status $::SUCCESS
                    }
                    if {$error_count} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed to apply $error_count QuickTest(s): $failed_qt  !!!"
                        return $returnList 
                    }
                    
                }    
                
            }
            
            is_done {
                if {![info exists result_handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: -result_handle attribute is mandatory if -action is is_done. Please configure -result_handle attribute."
                    return $returnList
                }
                set error_count 0
                foreach r_handle $result_handle {
                    debug "ixNet isDone $r_handle"
                    if { [catch { ixNet isDone $r_handle} retCode] } {   
                        incr error_count
                        keylset returnList ${r_handle}.status $::FAILURE
                        keylset returnList ${r_handle}.log "ERROR in $procName: Failed to get the is_done status on $r_handle !!!"
                        if { $action_on_failure == "continue" } {
                            continue
                        } else {
                            break
                        }
                    }
                    keylset returnList ${r_handle}.status [ expr ( $retCode == "true" ) ? ${::SUCCESS} : ${::FAILURE} ]
                }
                if {$error_count} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to get the is_done status for some of the result handles  !!!"
                    return $returnList 
                }
            }
            
            wait {
                if {![info exists result_handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: -result_handle attribute is mandatory if -action is wait. Please configure -result_handle attribute."
                    return $returnList
                }
            
                if { [llength $result_handle] != 1 } {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Single handle is expected for the parameter result_handle !!!"
                        return $returnList   
                }
                debug "ixNet wait $result_handle"
                if { [catch { ixNet wait $result_handle} retCode] } {   
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to wait for the completion on $result_handle !!!"
                    return $returnList 
                }
            }
            
            get_result {
                if {![info exists result_handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: -result_handle attribute is mandatory if -action is get_result. Please configure -result_handle attribute."
                    return $returnList
                }
                
                set error_count 0
                foreach r_handle $result_handle {
                    debug "ixNet getResult $r_handle"
                    if { [catch { ixNet getResult $r_handle} retCode] } {   
                        incr error_count
                        keylset returnList ${r_handle}.status $::FAILURE
                        keylset returnList ${r_handle}.log "ERROR in $procName: Failed to get the result on $r_handle !!!"
                        if { $action_on_failure == "continue" } {
                            continue
                        } else {
                            break
                        }
                    }
                    
                    set result_list [::ixTclNet::ParseExecArray $retCode]
                    foreach {param stat} $result_list {
                        switch -- $param {
                            status    {
                                keylset returnList ${r_handle}.return_message  "$stat"
                            }
                            isRunning {
                                keylset returnList ${r_handle}.is_running  [ expr ( $stat == "True" ) ? ${::SUCCESS} : ${::FAILURE} ] 
                            }
                            resultPath {
                                keylset returnList ${r_handle}.result_path  "$stat"
                            }
                            default {
                                keylset returnList ${r_handle}.${param}  "$stat"
                            }
                        }                            
                    }
                    keylset returnList ${r_handle}.status $::SUCCESS
                }
                if {$error_count} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to get the result for some of the result handles  !!!"
                    return $returnList 
                }
            }
            
            qt_start {
                keylset returnList status $::SUCCESS
                if {![info exists qt_handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: -qt_handle attribute is mandatory if\
                            -action is qt_start. Please configure -qt_handle attribute."
                    return $returnList
                }
                # Checking if the execution is idle
                set running_tests [ixNet getA [ixNet getRoot]quickTest -runningTest]
                if { $running_tests != "" } {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Cannot start while another quicktest\
                            is running !!! Running test: $running_tests."
                    return $returnList
                }
                # Validating the qt_handle
                set valid_tests [ixNet getA [ixNet getRoot]quickTest -testIds]
                set invalid_handles ""
                foreach handle $qt_handle {
                    if { [lsearch $valid_tests $handle] < 0 } { lappend invalid_handles $handle }
                }
                if { $invalid_handles != "" } {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Invalid qt_handles provided: $invalid_handles !!!"
                    return $returnList
                }
                # Validating input parameters
                if { [info exists input_params] && ([::ixia::validate_qt_input_parameters $input_params [llength $qt_handle]] != 0) } {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Invalid -input_params provided.\
                            The input_params array length needs to match the -qt_handles length\
                            and also each member of the array need to be another 2 element array.\
                            \nExamples for 1 qt_handle: {{x 1}}, {{x 1} {y 2}}, {}.\
                            \nExamples for 2 qt_handles: {{{x 1} {y 2}} {{x2 1} {y2 1}}}, {{{x 1} {y 2}} {}}."
                    return $returnList
                }
                
                if { $action_mode == "async" } {
                    # Individual handles is needed for the async operations
                    if { [llength $qt_handle] != 1 } {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Single handle is expected for the parameter -qt_handle, when -action is $action and -async_mode is async !!!"
                        return $returnList   
                    }
                    set _cmd "ixNet -async exec start ${handle}"
                    if {[info exists input_params]} {
                        lappend _cmd $input_params
                    }
                    debug [subst $_cmd]
                    if { [catch {eval $_cmd} retCode] } {
                        debug "ERROR starting ${qt_handle}: $retCode"
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed to start QuickTest !!!"
                        return $returnList
                    }
                    keylset returnList ${qt_handle}.result_handle $retCode
                } else  {          
                    #sync
                    set  error_count 0
                    set _cmd_params ""
                    set input_params_index 0
                    if {[info exists input_params]} {
                        if {[llength $qt_handle] != 1} {
                            set _cmd_params {[lindex ${input_params} ${input_params_index}]}
                        } else {
                            set _cmd_params $input_params
                        }
                    }
                    foreach handle $qt_handle {
                        keylset returnList ${handle}.status $::SUCCESS
                        # initializing all return handles with blank value
                        keylset returnList ${handle}.is_running ""
                        keylset returnList ${handle}.result ""
                        keylset returnList ${handle}.result_path ""
                        keylset returnList ${handle}.return_message ""
                        set _cmd "ixNet exec start $handle"
                        if { [string length [string trim [subst $_cmd_params]]] > 0 } {
                            lappend _cmd $_cmd_params
                        }
                        debug [subst $_cmd]
                        if { [catch {eval [subst $_cmd]} retCode] || \
                            ([string first "::ixNet::OK" $retCode] == -1)} {
                            debug "ERROR starting $handle: $retCode"
                            incr error_count
                            keylset returnList ${handle}.status $::FAILURE
                            keylset returnList ${handle}.log "ERROR in $procName: Failed to start QuickTest for ${handle} !!!"
                            if { $action_on_failure == "continue" } {
                                continue
                            } else {
                                break
                            }
                        }
                        incr input_params_index
                        # wait 1 second to be sure the test has started after above call
                        after 1000
                        catch {keylset returnList ${handle}.is_running [expr ( [ixNet getAttr $handle/results -isRunning] == "true" ) ? ${::SUCCESS} : ${::FAILURE}]}
                        # Multiple tests can't be started at the same time
                        # so we must wait for the current one to stop, before starting the next one.
                        if { [llength $qt_handle] != 1 } {
                            debug "ixNet exec waitForTest  ${handle}"
                            if { [catch {ixNet exec waitForTest  ${handle} } retCode] } {   
                                incr error_count
                                keylset returnList ${handle}.status $::FAILURE
                                keylset returnList ${handle}.log "ERROR in $procName: Failed to wait for completion of QuickTest for ${handle} !!!"
                                if { $action_on_failure == "continue" } {
                                    continue
                                } else {
                                    break
                                }
                            }
                            set result_list [::ixTclNet::ParseExecArray $retCode]
                            foreach {param stat} $result_list {
                                switch -- $param {
                                    status    {
                                        keylset returnList ${handle}.return_message  "$stat"
                                    }
                                    isRunning {
                                        keylset returnList ${handle}.is_running  [ expr ( $stat == "True" ) ? ${::SUCCESS} : ${::FAILURE} ] 
                                    }
                                    resultPath {
                                        keylset returnList ${handle}.result_path  "$stat"
                                    }
                                    default {
                                        keylset returnList ${handle}.${param}  "$stat"
                                    }
                                }                            
                            }
                            if { ([keylget returnList ${handle}.result] != "pass") && ($action_on_failure == "stop") } {
                                break
                            }
                        }
                    }
                    if {$error_count} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed to start QuickTest for some of the qt handles  !!!"
                        return $returnList 
                    }
                }
            }
            
            qt_run {
                keylset returnList status $::SUCCESS
                if {![info exists qt_handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: -qt_handle attribute is mandatory if\
                            -action is qt_start. Please configure -qt_handle attribute."
                    return $returnList
                }
                # Checking if the execution is idle
                set running_tests [ixNet getA [ixNet getRoot]quickTest -runningTest]
                if { $running_tests != "" } {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Cannot start while another quicktest\
                            is running !!! Running test: $running_tests."
                    return $returnList
                }
                # Validating the qt_handle
                set valid_tests [ixNet getA [ixNet getRoot]quickTest -testIds]
                set invalid_handles ""
                foreach handle $qt_handle {
                    if { [lsearch $valid_tests $handle] < 0 } { lappend invalid_handles $handle }
                }
                if { $invalid_handles != "" } {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Invalid qt_handles provided: $invalid_handles !!!"
                    return $returnList
                }
                # Validating input parameters
                if { [info exists input_params] && ([::ixia::validate_qt_input_parameters $input_params [llength $qt_handle]] != 0) } {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Invalid -input_params provided.\
                            The input_params array length needs to match the -qt_handles length\
                            and also each member of the array need to be another 2 element array.\
                            \nExamples for 1 qt_handle: {{x 1}}, {{x 1} {y 2}}, {}.\
                            \nExamples for 2 qt_handles: {{{x 1} {y 2}} {{x2 1} {y2 1}}}, {{{x 1} {y 2}} {}}."
                    return $returnList
                }
                if { $action_mode == "async" } {
                    # Individual handles is needed for the async operations
                    if { [llength $qt_handle] != 1 } {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Single handle is expected for the parameter -qt_handle, when -action is $action and -async_mode is async !!!"
                        return $returnList   
                    }
                    set _cmd "ixNet -async exec run ${handle}"
                    if {[info exists input_params]} {
                        lappend _cmd $input_params
                    }
                    debug [subst $_cmd]
                    if { [catch {eval $_cmd} retCode] } {
                        debug "ERROR starting ${qt_handle}: $retCode"
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed to start QuickTest !!!"
                        return $returnList
                    }
                    keylset returnList ${qt_handle}.result_handle $retCode
                } else  {
                    #sync
                    set  error_count 0 
                    set _cmd_params ""
                    set input_params_index 0
                    if {[info exists input_params]} {
                        if {[llength $qt_handle] != 1} {
                            set _cmd_params {[lindex ${input_params} ${input_params_index}]}
                        } else {
                            set _cmd_params $input_params
                        }
                    }
                    foreach handle $qt_handle {
                        keylset returnList ${handle}.status $::SUCCESS
                        set _cmd "ixNet exec run $handle"
                        if { [string length [string trim [subst $_cmd_params]]] > 0 } {
                            lappend _cmd $_cmd_params
                        }
                        debug [subst $_cmd]                   
                        if { [catch {eval [subst $_cmd]} retCode] || \
                            ([string first "::ixNet::OK" $retCode] == -1)} {
                            debug "ERROR starting $handle: $retCode"
                            incr error_count
                            keylset returnList ${handle}.status $::FAILURE
                            keylset returnList ${handle}.log "ERROR in $procName: Failed to start QuickTest for ${handle} !!!"
                            if { $action_on_failure != "continue" } {
                                break
                            }
                        }
                        incr input_params_index
                        set result_list [::ixTclNet::ParseExecArray $retCode]
                        debug $retCode
                        foreach {param stat} $result_list {
                            switch -- $param {
                                status    {
                                    keylset returnList ${handle}.return_message  "$stat"
                                }
                                isRunning {
                                    keylset returnList ${handle}.is_running  [ expr ( $stat == "True" ) ? ${::SUCCESS} : ${::FAILURE} ] 
                                }
                                resultPath {
                                    keylset returnList ${handle}.result_path  "$stat"
                                }
                                default {
                                    keylset returnList ${handle}.${param}  "$stat"
                                }
                            }                            
                        }
                        if { ([keylget returnList ${handle}.result] != "pass") && ($action_on_failure == "stop") } {
                            break
                        }
                    }
                    if {$error_count} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed to start QuickTest for some of the qt handles  !!!"
                        return $returnList 
                    }
                }
            }
            
            qt_stop {
                set log_message {}
                keylset returnList status $::SUCCESS
                if {[info exists qt_handle]} {
                    puts "WARN: Only currently executing test can be stopped. -qt_handle will be ignored"
                    lappend log_message "WARN in $procName: Only currently executing test can be stopped.  -qt_handle will be ignored"
                    keylset returnList log $log_message
                }
                # Only currently executing test can be stopped.
                set ixNetRoot [ixNet getRoot]
                set qt_running_handle [ixNet getA ${ixNetRoot}quickTest -runningTest]
                for {set i 0}  {$i < [llength $qt_running_handle]} {incr i} {
                    lset qt_running_handle $i "$ixNetRoot[lindex $qt_running_handle $i]"
                }
                regsub -all {//} $qt_running_handle {/} qt_running_handle
                if {[llength $qt_running_handle] < 1} {
                    keylset returnList status $::FAILURE
                    lappend log_message "ERROR in $procName: No quicktest is runnning !!!"
                    keylset returnList log $log_message
                    return $returnList
                }
                if { $action_mode == "async" } {
                    debug "Sending stop signal for $qt_running_handle ..."
                    foreach {qt_handle} $qt_running_handle {
                        if { [catch {ixNet -async exec stop ${qt_handle}} retCode] } {
                            debug "Error occured while stopping quicktest: $retCode"
                            keylset returnList ${qt_handle}.status $::FAILURE
                            keylset returnList status $::FAILURE
                            keylset returnList ${qt_handle}.log "ERROR in $procName: Failed to stop $qt_handle QuickTest !!!"
                        } else {
                            keylset returnList ${qt_handle}.result_handle $retCode
                            keylset returnList ${qt_handle}.status $::SUCCESS
                            if { ![catch { ixNet -async exec waitForTest  ${qt_handle} } retCode] } {
                                keylset returnList ${qt_handle}.result_handle $retCode
                            }
                        }
                    }
                } else  {
                    #sync
                    foreach {qt_handle} $qt_running_handle {
                        debug "Stopping $qt_handle ..."
                        if { [catch {ixNet exec stop ${qt_handle}} retCode] } {
                            debug "Error occured while stopping quicktest: $retCode"
                            keylset returnList ${qt_handle}.status $::FAILURE
                            keylset returnList status $::FAILURE
                            keylset returnList ${qt_handle}.log "ERROR in $procName: Failed to stop $qt_handle QuickTest !!!"
                        } else {
                            debug "Waiting for $qt_handle to stop ..."
                            # waiting for stop action to finish as the IxNet api is always async.
                            catch {ixNet exec waitForTest  ${qt_handle} }
                            keylset returnList ${qt_handle}.status $::SUCCESS
                        }
                    }
                }
                if { [keylget returnList status] == $::FAILURE } {
                    keylset returnList log $log_message
                    return $returnList
                }
            }
            qt_wait_for_test {
                set log_message {}
                if {[info exists qt_handle]} {
                    puts "WARN: This command only applies to the curently executing test so there is no need for -qt_handle"
                    lappend log_message "WARN in $procName: This command only applies to the curently executing test so there is no need for -qt_handle"
                    keylset returnList log $log_message
                }
                set ixNetRoot [ixNet getRoot]
                set qt_running_handle [ixNet getA ${ixNetRoot}quickTest -runningTest]
                for {set i 0}  {$i < [llength $qt_running_handle]} {incr i} {
                    lset qt_running_handle $i "$ixNetRoot[lindex $qt_running_handle $i]"
                }
                regsub -all {//} $qt_running_handle {/} qt_running_handle
                if { [llength $qt_running_handle] < 1 } {
                    keylset returnList status $::FAILURE
                    lappend log_message "ERROR in $procName: No test running !!!"
                    keylset returnList log $log_message
                    return $returnList
                }
                set qt_handle $qt_running_handle
                if { [llength $qt_running_handle] > 1 } {
                    set es [regexp -inline {[\w:/-]+eventScheduler:[0-9]+} $qt_running_handle]
                    if { $es != ""} { set qt_handle $es }
                }
                set  error_count 0
                foreach handle $qt_handle {
                    debug "ixNet exec waitForTest  ${handle}"
                    if { [catch {ixNet exec waitForTest  ${handle} } retCode] } {   
                        incr error_count
                        keylset returnList ${handle}.status $::FAILURE
                        keylset returnList ${handle}.log "ERROR in $procName: Failed to wait for completion of QuickTest for ${handle} !!!"
                    }
                    set result_list [::ixTclNet::ParseExecArray $retCode]
                    foreach {param stat} $result_list {
                        switch -- $param {
                            status    {
                                keylset returnList ${handle}.return_message  "$stat"
                            }
                            isRunning {
                                keylset returnList ${handle}.is_running  [ expr ( $stat == "True" ) ? ${::SUCCESS} : ${::FAILURE} ] 
                            }
                            resultPath {
                                keylset returnList ${handle}.result_path  "$stat"
                            }
                            default {
                                keylset returnList ${handle}.${param}  "$stat"
                            }
                        }                            
                    }
                    keylset returnList ${handle}.status $::SUCCESS
                }
                if {$error_count} {
                    keylset returnList status $::FAILURE
                    lappend log_message "ERROR in $procName: Some error occured while waiting to finish the current quicktest !!!"
                    keylset returnList log $log_message
                    return $returnList 
                }
            }
            
            qt_get_input_params {
                if {![info exists qt_handle]} {
                    #if no qt_handle is specified we should return all input_params for all existing quicktests
                    set qt_handle [ixNet getA [ixNet getRoot]quickTest -testIds]
                } else {
                    # Validating the qt_handle
                    set valid_tests [ixNet getA [ixNet getRoot]quickTest -testIds]
                    set invalid_handles ""
                    foreach handle $qt_handle {
                        if { [lsearch $valid_tests $handle] < 0 } { lappend invalid_handles $handle }
                    }
                    if { $invalid_handles != "" } {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Invalid qt_handles provided: $invalid_handles !!!"
                    return $returnList
                    }
                }
                set  error_count 0
                foreach handle $qt_handle {
                    debug "ixNet getAttr $handle -inputParameters"
                    if { [catch {ixNet getAttr $handle -inputParameters } retCode] } {  
                        incr error_count
                        debug "ERROR: $retCode"
                        keylset returnList ${handle}.status $::FAILURE
                        keylset returnList ${handle}.log "ERROR in $procName: Failed to get the inputParameters for ${handle} !!!"
                        if { $action_on_failure == "continue" } {
                            continue
                        } else {
                            break
                        }
                    }
                    keylset returnList ${handle}.input_params_list [lindex $retCode 0]
					keylset returnList ${handle}.input_params $retCode
                    keylset returnList ${handle}.status $::SUCCESS
                }
                if {$error_count} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to get the inputParameters for some of the qt handles  !!!"
                    return $returnList 
                }
            }
            
            default {}
        }
    }
    keylset returnList status $::SUCCESS 
    return $returnList
}

proc ::ixia::test_stats {args} {

    variable objectMaxCount
    variable executeOnTclServer
    variable ignoreLinkState
    variable ixnetworkVersion
    variable no_more_tclhal

    set procName [lindex [info level [info level]] 0]
    
    ::ixia::logHltapiCommand $procName $args
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::test_stats $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args

    set mandatory_args {
        -mode        CHOICES qt_currently_running qt_running_status qt_progress qt_flow_view qt_result
    }

    set opt_args { 
        -qt_handle  ANY
    }

    if {[catch {::ixia::parse_dashed_args -args $args \
            -mandatory_args $mandatory_args -optional_args $opt_args} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg"
        return $returnList
    }

    switch -- $mode {
    
        qt_currently_running {
            set ixNetRoot [ixNet getRoot]
            debug "ixNet getAttr ${ixNetRoot}quickTest -runningTest"
            if { [catch { ixNet getAttr ${ixNetRoot}quickTest -runningTest } retCode] } {                
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $retCode"
                return $returnList
            }
            for {set i 0}  {$i < [llength $retCode]} {incr i} {
                lset retCode $i "$ixNetRoot[lindex $retCode $i]"
            }
            regsub -all {//} $retCode {/} retCode
            if { [llength $retCode] < 1 } {
                keylset returnList log "WARNING: No test running !!!"
             }
            keylset returnList qt_handle $retCode
        }
        
        qt_running_status {
        
            if {![info exists qt_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: -qt_handle attribute is mandatory if -mode is qt_running_status. Please configure -qt_handle attribute."
                return $returnList
            }
            
            foreach handle $qt_handle {
                debug "ixNet getAttr $handle/results -isRunning"
                if { [catch { ixNet getAttr $handle/results -isRunning} retCode] } {                
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $retCode"
                    return $returnList
                }
                keylset returnList ${handle}.is_running [ expr ( $retCode == "true" ) ? ${::SUCCESS} : ${::FAILURE} ] 
            }
        }
        
        qt_progress {
        
            if {![info exists qt_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: -qt_handle attribute is mandatory if -mode is qt_progress. Please configure -qt_handle attribute."
                return $returnList
            }
            
            foreach handle $qt_handle {
            
                debug "ixNet getAttr $handle/results -progress"
                if { [catch { ixNet getAttr $handle/results -progress } retCode] } {                
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $retCode"
                    return $returnList
                }
                keylset returnList ${handle}.progress "$retCode" 
            }
        }
        
        qt_result {
            keylset returnList status $::SUCCESS
            if {![info exists qt_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: -qt_handle attribute is mandatory if -mode is qt_progress. Please configure -qt_handle attribute."
                return $returnList
            }
            # Validating the qt_handle
            set valid_tests [ixNet getA [ixNet getRoot]quickTest -testIds]
            set invalid_handles ""
            foreach handle $qt_handle {
                if { [lsearch $valid_tests $handle] < 0 } { lappend invalid_handles $handle }
            }
            if { $invalid_handles != "" } {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Invalid qt_handles provided: $invalid_handles !!!"
                return $returnList
            }
            foreach handle $qt_handle {
                set log_message {}
                keylset returnList ${handle}.status $::SUCCESS
                debug "ixNet getAttr $handle/results -status"
                if { [catch { ixNet getAttr $handle -name } retCode] } {                
                    keylset returnList status $::FAILURE
                    keylset returnList ${handle}.status $::FAILURE
                    lappend log_message "ERROR in $procName: Failed to get the name of the $handle !!!"
                } else {
                    keylset returnList ${handle}.name "$retCode" 
                }
                if { [catch { ixNet getAttr $handle/results -status } retCode] } {                
                    keylset returnList status $::FAILURE
                    keylset returnList ${handle}.status $::FAILURE
                    lappend log_message "ERROR in $procName: Failed to get the stat -status on $handle !!!"
                } else {
                    keylset returnList ${handle}.return_message "$retCode" 
                }
                debug "ixNet getAttr $handle/results -result"
                if { [catch { ixNet getAttr $handle/results -result } retCode] } {                
                    keylset returnList status $::FAILURE
                    keylset returnList ${handle}.status $::FAILURE
                    lappend log_message "ERROR in $procName: Failed to get the stat -result on $handle   !!!"
                } else {
                    keylset returnList ${handle}.result "$retCode" 
                }
                debug "ixNet getAttr $handle/results -resultPath"
                if { [catch { ixNet getAttr $handle/results -resultPath } retCode] } {                
                    keylset returnList status $::FAILURE
                    keylset returnList ${handle}.status $::FAILURE
                    lappend log_message "ERROR in $procName: Failed to get the stat -resultPath on $handle   !!!"
                } else {
                    keylset returnList ${handle}.result_path [file normalize $retCode]
                }
                debug "ixNet getAttr $handle/results -startTime"
                if { [catch { ixNet getAttr $handle/results -startTime } retCode] } {                
                    keylset returnList status $::FAILURE
                    keylset returnList ${handle}.status $::FAILURE
                    lappend log_message "ERROR in $procName: Failed to get the stat -startTime on $handle   !!!"
                } else {
                    keylset returnList ${handle}.start_time "$retCode"
                }
                debug "ixNet getAttr $handle/results -duration"
                if { [catch { ixNet getAttr $handle/results -duration } retCode] } {
                    keylset returnList status $::FAILURE
                    keylset returnList ${handle}.status $::FAILURE
                    lappend log_message "ERROR in $procName: Failed to get the stat -duration on $handle   !!!"
                } else {
                    keylset returnList ${handle}.duration "$retCode"
                }
                if { [keylget returnList ${handle}.status] == $::FAILURE } {
                    keylset returnList ${handle}.log $log_message
                }
            }
            if { [keylget returnList status] == $::FAILURE } {
                    keylset returnList log "ERROR in $procName: Some statistics fail to be retrieved !!!"
                    return $returnList
            }
        }
        
        qt_flow_view {
        
            array set stats_array_flow_view {
                "Tx Frames"                         tx_frames
                "Rx Frames"                         rx_frames
                "Frames Delta"                      frames_delta
                "Loss %"                            loss_percentage
                "Tx Frame Rate"                     tx_frame_rate
                "Rx Frame Rate"                     rx_frame_rate
                "Rx Bytes"                          rx_bytes
                "Tx Rate (Bps)"                     tx_rate_Bps                
                "Rx Rate (Bps)"                     rx_rate_Bps
                "Tx Rate (bps)"                     tx_rate_bps
                "Rx Rate (bps)"                     rx_rate_bps
                "Tx Rate (Kbps)"                    tx_rate_kbps
                "Rx Rate (Kbps)"                    rx_rate_kbps
                "Tx Rate (Mbps)"                    tx_rate_mbps
                "Rx Rate (Mbps)"                    rx_rate_mbps
                "Cut-Through Avg Latency(ns)"       avg_latency_cut_through
                "Cut-Through Min Latency(ns)"       min_latency_cut_through
                "Cut-Through Max Latency(ns)"       max_latency_cut_through
                "Fist TimeStamp"                    first_time_stamp
                "Last TimeStamp"                    last_time_stamp
            }
            
            set stat_name  "Flow Statistics"
            set stats_list [array names stats_array_flow_view]
            
            set returned_stats_list [::ixia::ixNetworkGetStats \
            $stat_name $stats_list]            
            if {[keylget returned_stats_list status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: [keylget returned_stats_list log]"
                return $returnList
            }
            set row_count [keylget returned_stats_list row_count]
            keylset returnList row_count $row_count
            array set rows_array [keylget returned_stats_list statistics]
            
            
            for {set i 1} {$i <= $row_count} {incr i} {    
                
                set row_name_list $rows_array($i)
                set row_name_length [llength $row_name_list]
                keylset returnList ${i}.tx_port [lindex $row_name_list 0]
                keylset returnList ${i}.rx_port [lindex $row_name_list 1]
                keylset returnList ${i}.traffic_item [lindex $row_name_list 2]
                keylset returnList ${i}.flow_group "[lrange $row_name_list 3 $row_name_length]"    
                
                
                foreach stat $stats_list {                
                                        
                    if {[info exists rows_array($i,$stat)]} {
                        keylset returnList ${i}.$stats_array_flow_view($stat) $rows_array($i,$stat)
                    }
                }    
            }
        }
        
        default {}
    }
    keylset returnList status $::SUCCESS
    return $returnList
}
