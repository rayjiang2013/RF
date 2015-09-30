##Procedure Header
# Name:
#    ::ixiangpf::emulation_lacp_link_config
#
# Description:
#    This procedure will configure LACP/Static LAG
#
# Synopsis:
#    ::ixiangpf::emulation_lacp_link_config
#        -mode                               CHOICES create
#                                            CHOICES delete
#                                            CHOICES modify
#                                            CHOICES enable
#                                            CHOICES disable
#        [-port_handle                       REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
#        [-handle                            ANY]
#x       [-active                            CHOICES 0 1]
#        [-session_type                      CHOICES lacp staticLag
#                                            DEFAULT lacp]
#x       [-lag_id                            RANGE 1-65535
#x                                           DEFAULT 1]
#        [-count                             NUMERIC
#                                            DEFAULT 1]
#x       [-reset                             ANY]
#        [-actor_key                         RANGE 0-65535
#                                            DEFAULT 1]
#        [-actor_port_num                    RANGE 0-65535
#                                            DEFAULT 1]
#        [-actor_key_step                    RANGE 0-65535
#                                            DEFAULT 1]
#        [-actor_port_num_step               RANGE 0-65535
#                                            DEFAULT 1]
#        [-actor_port_pri                    RANGE 0-65535
#                                            DEFAULT 1]
#        [-actor_port_pri_step               RANGE 0-65535
#                                            DEFAULT 1]
#        [-lag_count                         RANGE 0-65535
#                                            DEFAULT 1]
#        [-actor_system_id                   HEX8WITHSPACES]
#x       [-administrative_key                RANGE 1-65535
#x                                           DEFAULT 1]
#        [-actor_system_id_step              HEX8WITHSPACES
#                                            DEFAULT 0000.0000.0001]
#n       [-auto_pick_port_mac                ANY]
#x       [-collecting_flag                   CHOICES 0 1
#x                                           DEFAULT 1]
#x       [-distributing_flag                 CHOICES 0 1
#x                                           DEFAULT 1]
#x       [-collector_max_delay               RANGE 0-65535
#x                                           DEFAULT 0]
#x       [-inter_marker_pdu_delay            RANGE 1-255
#x                                           DEFAULT 6]
#x       [-lacp_activity                     CHOICES active passive
#x                                           DEFAULT active]
#x       [-lacp_timeout                      RANGE 0-65535
#x                                           DEFAULT 0]
#x       [-lacpdu_periodic_time_interval     RANGE 0-65535
#x                                           DEFAULT 0]
#x       [-marker_req_mode                   CHOICES fixed random
#x                                           DEFAULT fixed]
#x       [-marker_res_wait_time              RANGE 1-255
#x                                           DEFAULT 5]
#x       [-send_marker_req_on_lag_change     CHOICES 0 1
#x                                           DEFAULT 1]
#x       [-inter_marker_pdu_delay_random_min RANGE 1-255
#x                                           DEFAULT 1]
#x       [-inter_marker_pdu_delay_random_max RANGE 1-255
#x                                           DEFAULT 6]
#x       [-send_periodic_marker_req          CHOICES 0 1
#x                                           DEFAULT 0]
#x       [-support_responding_to_marker      CHOICES 0 1
#x                                           DEFAULT 1]
#x       [-sync_flag                         CHOICES 0 1
#x                                           DEFAULT 1]
#x       [-aggregation_flag                  CHOICES 0 1
#x                                           DEFAULT 1]
#
# Arguments:
#    -mode
#    -port_handle
#    -handle
#        LACP and StaticLag protocol Handle
#x   -active
#x       Flag.
#    -session_type
#        The LACP to be emulated. CHOICES: lacp staticLag.
#x   -lag_id
#x       lag_id. RANGE 1-65535
#    -count
#        Defines the number of LACP to create.
#x   -reset
#x       Clears any LACP configuration on the targeted port before
#x       configuring further.
#    -actor_key
#        Actor Key. RANGE 0-65535
#    -actor_port_num
#        Actor Port Number. RANGE 0-65535
#    -actor_key_step
#        Actor Key Step. RANGE 0-65535
#    -actor_port_num_step
#        Actor Port Num step. RANGE 0-65535
#    -actor_port_pri
#        Actor Port Priority. RANGE 0-65535
#    -actor_port_pri_step
#        Actor Port Priority step. RANGE 0-65535
#    -lag_count
#        lag_count
#    -actor_system_id
#        actor system id
#x   -administrative_key
#x       administrative key
#    -actor_system_id_step
#        actor_system_id_step
#n   -auto_pick_port_mac
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -collecting_flag
#x       collecting flag
#x   -distributing_flag
#x       distributing Flag
#x   -collector_max_delay
#x       collector maximum delay
#x   -inter_marker_pdu_delay
#x       inter marker pdu delay
#x   -lacp_activity
#x       lacp activity
#x   -lacp_timeout
#x       lacp timeout
#x   -lacpdu_periodic_time_interval
#x       lacpdu periodic time interval
#x   -marker_req_mode
#x       marker req mode
#x   -marker_res_wait_time
#x       marker res wait time
#x   -send_marker_req_on_lag_change
#x       send marker req on lag change
#x   -inter_marker_pdu_delay_random_min
#x       inter marker pdu delay random min
#x   -inter_marker_pdu_delay_random_max
#x       inter marker pdu delay random max
#x   -send_periodic_marker_req
#x       send periodic marker req
#x   -support_responding_to_marker
#x       support responding to marker
#x   -sync_flag
#x       sync flag
#x   -aggregation_flag
#x       aggregation flag
#
# Return Values:
#    A list containing the ethernet protocol stack handles that were added by the command (if any).
#x   key:ethernet_handle   value:A list containing the ethernet protocol stack handles that were added by the command (if any).
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:handle            value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    $::SUCCESS | $::FAILURE
#    key:status            value:$::SUCCESS | $::FAILURE
#    When status is $::FAILURE, contains more information
#    key:log               value:When status is $::FAILURE, contains more information
#    Handle of lacp configured
#    key:lacp_handle       value:Handle of lacp configured
#    Handle of lacp configured
#    key:staticLag_handle  value:Handle of lacp configured
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  handle
#
# See Also:
#

proc ::ixiangpf::emulation_lacp_link_config { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "emulation_lacp_link_config" $notImplementedParams $mandatoryParams $fileParams $args]
}
