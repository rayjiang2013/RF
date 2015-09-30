##Procedure Header
# Name:
#    ::ixiangpf::test_control
#
# Description:
#    This command gives more options to control the various operations for a test session.
#    The command can be used to start or stop any (or all) protocols configured and to apply
#    pending on the fly changes for NGPF protocols.
#    The command gives control over quick tests and also supports check_link_state.
#    Valid only when using IxTclNetwork (new API). Also this command is avaliable only in Ixia.
#
# Synopsis:
#    ::ixiangpf::test_control
#        -action             CHOICES start_all_protocols
#                            CHOICES stop_all_protocols
#                            CHOICES restart_down
#                            CHOICES start_protocol
#                            CHOICES stop_protocol
#                            CHOICES abort_protocol
#                            CHOICES apply_on_the_fly_changes
#                            CHOICES check_link_state
#                            CHOICES get_all_qt_handles
#                            CHOICES get_available_qt_types
#                            CHOICES get_qt_handles_for_type
#                            CHOICES qt_remove_test
#                            CHOICES qt_apply_config
#                            CHOICES qt_start
#                            CHOICES qt_run
#                            CHOICES qt_stop
#                            CHOICES qt_wait_for_test
#                            CHOICES is_done
#                            CHOICES wait
#                            CHOICES get_result
#                            CHOICES qt_get_input_params
#        [-port_handle       REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
#        [-handle            ANY]
#        [-desired_status    CHOICES busy up down unassigned
#                            DEFAULT up]
#        [-timeout           NUMERIC
#                            DEFAULT 60]
#        [-qt_handle         ANY]
#        [-result_handle     ANY]
#        [-qt_type           ANY]
#        [-input_params      ANY]
#        [-action_mode       CHOICES sync async
#                            DEFAULT sync]
#        [-action_on_failure CHOICES stop continue
#                            DEFAULT continue]
#        [-args              ANY]
#        [-mandatory_args    ANY]
#
# Arguments:
#    -action
#        This option specified the action to be taken based on the option provided.
#    -port_handle
#        List of ports for which to retrieve information.
#        Valid when -action is check_link_state
#    -handle
#        List of handles to act on.
#        Valid when -action is start_protocol or stop_protocol.
#    -desired_status
#        Valid when -action is check_link_state
#    -timeout
#        Numeric value used to specify the timeout.
#        Valid when -action is check_link_state
#    -qt_handle
#        List of handles for the quick test to perform commands
#        Valid with the following -action values
#        qt_start with -action_modesync
#        qt_run with -action_modesync
#        qt_apply_config -action_modesync
#        qt_remove_test
#        Instead of List of handles, only single handle is supported for the following -action values
#        qt_start with -action_modeasync
#        qt_run with -action_modeasync
#        qt_apply_config -action_modeasync
#        qt_stop
#        qt_wait_for_test
#    -result_handle
#        List of result_handles returned by previously executed asynchronous operations
#        Valid with the following -action values
#        is_done
#        get_result
#        wait
#    -qt_type
#        List of qt types for which the available test handles to be returned.
#        Valid when -action is get_qt_handles_for_type
#    -input_params
#        List of runtime Parameters for the quick test specified by qt_handle.
#        Valid with the following -action values
#        qt_start
#        qt_run
#    -action_mode
#        Valid options are:
#        sync- perform the operation specified in -action in synchronous mode
#        async- perform the operation specified in -action in asynchronous mode
#        (DEFAULT - sync)
#        Valid when -action is qt_start, qt_stop, qt_run and qt_apply_config
#    -action_on_failure
#        (DEFAULT- continue)
#        Valid when -action_mode sync and -action is qt_start, qt_stop, qt_run or qt_apply_config
#    -args
#    -mandatory_args
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status                       value:$::SUCCESS | $::FAILURE
#    On status of failure, gives detailed information.
#    key:log                          value:On status of failure, gives detailed information.
#    up, down, unassigned, busy
#    key:<port_handle>.state          value:up, down, unassigned, busy
#    List of valid handles for all quick tests available in the config.
#    key:qt_handle                    value:List of valid handles for all quick tests available in the config.
#    Gives detailed information about the test run.
#    key:<qt_handle>.log              value:Gives detailed information about the test run.
#    $::SUCCESS | $::FAILURE
#    key:<qt_handle>.is_running       value:$::SUCCESS | $::FAILURE
#    Based on the pass/fail criteria of the test execution, the values  none, pass or fail will be returned.
#    key:<qt_handle>.result           value:Based on the pass/fail criteria of the test execution, the values  none, pass or fail will be returned.
#    The local path to the results folder for test specified in qt_handle.
#    key:<qt_handle>.result_path      value:The local path to the results folder for test specified in qt_handle.
#    The result handle obtained with the -action_mode async for -action types qt_start, qt_stop, qt_run, qt_apply_config
#    key:<qt_handle>.result_handle    value:The result handle obtained with the -action_mode async for -action types qt_start, qt_stop, qt_run, qt_apply_config
#    List of all supported input parameters for the test specified in qt_handle.
#    key:<qt_handle>.input_params     value:List of all supported input parameters for the test specified in qt_handle.
#    $::SUCCESS | $::FAILURE, to indicate the asynchronous operation mentioned in result_handle is completed or not.
#    key:<result_handle>.status       value:$::SUCCESS | $::FAILURE, to indicate the asynchronous operation mentioned in result_handle is completed or not.
#    On status of failure for a given result_handle, gives detailed information.
#    key:<result_handle>.log          value:On status of failure for a given result_handle, gives detailed information.
#    Based on the pass/fail criteria of the test execution, the values  none, pass or fail will be returned.
#    key:<result_handle>.result       value:Based on the pass/fail criteria of the test execution, the values  none, pass or fail will be returned.
#    The local path to the results folder for the test specified in qt_handle.
#    key:<result_handle>.result_path  value:The local path to the results folder for the test specified in qt_handle.
#    List of all supported qt types.
#    key:qt_types                     value:List of all supported qt types.
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

proc ::ixiangpf::test_control { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "test_control" $notImplementedParams $mandatoryParams $fileParams $args]
}
