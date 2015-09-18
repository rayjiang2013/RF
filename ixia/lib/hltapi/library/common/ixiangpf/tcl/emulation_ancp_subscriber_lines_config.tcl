##Procedure Header
# Name:
#    ::ixiangpf::emulation_ancp_subscriber_lines_config
#
# Description:
#    Used to configure simulating subscriber lines behind an ANCP enabled Access Node.
#
# Synopsis:
#    ::ixiangpf::emulation_ancp_subscriber_lines_config
#        -mode                                         CHOICES create
#                                                      CHOICES modify
#                                                      CHOICES delete
#                                                      CHOICES enable
#                                                      CHOICES disable
#                                                      CHOICES enable_all
#                                                      CHOICES disable_all
#n       [-profile_type                                ANY]
#x       [-enable_actual_rate_downstream               ANY]
#        [-actual_rate_downstream                      NUMERIC]
#        [-actual_rate_downstream_step                 NUMERIC]
#n       [-actual_rate_downstream_end                  ANY]
#x       [-enable_actual_rate_upstream                 ANY]
#        [-actual_rate_upstream                        NUMERIC]
#        [-actual_rate_upstream_step                   NUMERIC]
#n       [-actual_rate_upstream_end                    ANY]
#        [-ancp_client_handle                          ANY]
#        [-circuit_id                                  ANY]
#n       [-circuit_id_suffix                           ANY]
#n       [-circuit_id_suffix_repeat                    ANY]
#n       [-circuit_id_suffix_step                      ANY]
#n       [-data_link                                   ANY]
#n       [-downstream_act_interleaving_delay           ANY]
#n       [-downstream_attainable_rate                  ANY]
#n       [-downstream_max_interleaving_delay           ANY]
#n       [-downstream_max_rate                         ANY]
#n       [-downstream_min_low_power_rate               ANY]
#n       [-downstream_min_rate                         ANY]
#x       [-enable_dsl_type                             ANY]
#        [-dsl_type                                    CHOICES adsl1
#                                                      CHOICES adsl2
#                                                      CHOICES adsl2_plus
#                                                      CHOICES vdsl1
#                                                      CHOICES vdsl2
#                                                      CHOICES sdsl
#                                                      CHOICES unknown
#                                                      DEFAULT adsl1]
#n       [-encap1                                      ANY]
#n       [-encap2                                      ANY]
#        [-handle                                      ANY]
#n       [-include_encap                               ANY]
#x       [-enable_remote_id                            ANY]
#        [-remote_id                                   ANY]
#n       [-upstream_act_interleaving_delay             ANY]
#n       [-upstream_attainable_rate                    ANY]
#n       [-upstream_max_interleaving_delay             ANY]
#n       [-upstream_max_rate                           ANY]
#n       [-upstream_min_low_power_rate                 ANY]
#n       [-upstream_min_rate                           ANY]
#n       [-actual_rate_upstream_min_value              ANY]
#n       [-actual_rate_downstream_min_value            ANY]
#n       [-upstream_min_rate_min_value                 ANY]
#n       [-downstream_min_rate_min_value               ANY]
#n       [-upstream_attainable_rate_min_value          ANY]
#n       [-downstream_attainable_rate_min_value        ANY]
#n       [-upstream_max_rate_min_value                 ANY]
#n       [-downstream_max_rate_min_value               ANY]
#n       [-upstream_min_low_power_rate_min_value       ANY]
#n       [-downstream_min_low_power_rate_min_value     ANY]
#n       [-upstream_max_interleaving_delay_min_value   ANY]
#n       [-upstream_act_interleaving_delay_min_value   ANY]
#n       [-downstream_max_interleaving_delay_min_value ANY]
#n       [-downstream_act_interleaving_delay_min_value ANY]
#n       [-percentage                                  ANY]
#n       [-actual_rate_downstream_repeat               ANY]
#n       [-actual_rate_upstream_repeat                 ANY]
#        [-customer_vlan_id                            ANY]
#n       [-customer_vlan_id_repeat                     ANY]
#        [-customer_vlan_id_step                       ANY]
#        [-downstream_rate_tolerance                   ANY]
#n       [-enable_c_vlan                               ANY]
#        [-flap_mode                                   CHOICES none reset resynchronize
#                                                      DEFAULT none]
#n       [-remote_id_suffix                            ANY]
#n       [-remote_id_suffix_repeat                     ANY]
#n       [-remote_id_suffix_step                       ANY]
#        [-service_vlan_id                             ANY]
#n       [-service_vlan_id_repeat                      ANY]
#        [-service_vlan_id_step                        ANY]
#        [-subscriber_line_down_time                   ANY]
#        [-subscriber_line_up_time                     ANY]
#        [-subscriber_lines_per_access_node            ANY]
#        [-upstream_rate_tolerance                     ANY]
#        [-vlan_allocation_model                       CHOICES disabled N_1 1_1
#                                                      DEFAULT disabled]
#
# Arguments:
#    -mode
#        Used to specify the action that the function will perform on the given ANCP Client
#        session handle. Every mode except create, enable_all, and disable_all requires a
#        valid AN Subscriber Line Pool handle. Modes create, enable_all, and disable_all
#        will perform on any given ANCP Client handle. Default: None
#        Valid choices are:
#        create - ancp_client_handle returned by emulation_ancp_config is mandatory.
#        This mode will create a DSL Profile and DSL Resync profile and add it to
#        the profiles used by the ANCP Client. If an identical profile already exists
#        it will be used instead of creating a new one.
#        modify - handle returned by emulation_ancp_subscriber_lines_config is
#        mandatory. All the TLVs will be removed from this profile and new ones
#        will be added according to the procedure parameters. In this case the
#        parameters will not accept lists (single values only).
#        delete - handle returned by emulation_ancp_subscriber_lines_config is
#        mandatory. The DSL Profile specified with -handle will be removed.
#        enable - ancp_client_handle returned by emulation_ancp_config and
#        handle returned by emulation_ancp_subscriber_lines_config are
#        mandatory. The ANCP client specified with ancp_client_handle will
#        use the DSL Profile specified with -handle parameter.
#        disable - ancp_client_handle returned by emulation_ancp_config and
#        handle returned by emulation_ancp_subscriber_lines_config are
#        mandatory. The ANCP client specified with ancp_client_handle will
#        stop using the DSL Profile specified with -handle parameter.
#        enable_all - ancp_client_handle returned by emulation_ancp_config is
#        mandatory. The ANCP client specified with ancp_client_handle will
#        use all DSL Profiles available.
#        disable_all - ancp_client_handle returned by emulation_ancp_config is
#        mandatory. The ANCP client specified with ancp_client_handle will
#        not use any DSL Profiles.
#n   -profile_type
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -enable_actual_rate_downstream
#x       Enable Actual-Net-Data-Rate-Downstream TLV
#    -actual_rate_downstream
#        Used to set emulated actual DSL sync rate (kbps) downstream. It may be a list of
#        rate values.
#        Default: None
#        Dependencies: maximum 63 digits
#    -actual_rate_downstream_step
#        Step for actual_rate_downstream. The DSL TLV Resync Profile will be configured
#        as trend starting from actual_rate_downstream with a step of
#        actual_rate_downstream_step and ending at -actual_rate_downstream_end.
#n   -actual_rate_downstream_end
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -enable_actual_rate_upstream
#x       Enable Actual-Net-Data-Rate-Upstream TLV
#    -actual_rate_upstream
#        Used to set emulated actual DSL sync rate (kbps) upstream. It may be a list of rate values.
#        Default: None
#        Dependencies: maximum 63 digits
#    -actual_rate_upstream_step
#        Step for actual_rate_upstream. The DSL TLV Resync Profile will be configured
#        as trend starting from actual_rate_upstream with a step of
#        actual_rate_upstream_step and ending at actual_rate_upstream_end.
#n   -actual_rate_upstream_end
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -ancp_client_handle
#        This parameter is used to specify the ANCP Client session handle on which
#        ANCP Subscriber Line Pool will be added. This handle is returned by procedure
#        emulation_ancp_config.
#        May be a list, in which case all the handles are configured with the same parameters.
#        Default: None
#        Dependencies: None
#    -circuit_id
#        Used to set circuit id.
#        May be a list, needs to have the same length as ancp_client_handle.
#        Default: None
#        Dependencies: None
#n   -circuit_id_suffix
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -circuit_id_suffix_repeat
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -circuit_id_suffix_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -data_link
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -downstream_act_interleaving_delay
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -downstream_attainable_rate
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -downstream_max_interleaving_delay
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -downstream_max_rate
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -downstream_min_low_power_rate
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -downstream_min_rate
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -enable_dsl_type
#x       Enable DSL Type TLV
#    -dsl_type
#        Used to set the type of DSL transmission system in use.
#        Default: None
#        Dependencies: maximum 63 digits
#n   -encap1
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -encap2
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -handle
#        Used to modify, enable, disable or delete AN Subscriber Line Pool handle.
#        This handle is returned by emulation_ancp_subscriber_lines_config procedure.
#        Default: None
#        Dependencies: None
#n   -include_encap
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -enable_remote_id
#x       Enable Access-Loop-Remote-ID TLV
#    -remote_id
#        Used to set remote id. This parameter is also use to enable Remote Id option.
#        Hence, if and only if the switch remote_id is specified, Remote Id option will be
#        enabled.
#        Default: None
#        Dependencies: maximum 63 digits
#n   -upstream_act_interleaving_delay
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -upstream_attainable_rate
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -upstream_max_interleaving_delay
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -upstream_max_rate
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -upstream_min_low_power_rate
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -upstream_min_rate
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -actual_rate_upstream_min_value
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -actual_rate_downstream_min_value
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -upstream_min_rate_min_value
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -downstream_min_rate_min_value
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -upstream_attainable_rate_min_value
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -downstream_attainable_rate_min_value
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -upstream_max_rate_min_value
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -downstream_max_rate_min_value
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -upstream_min_low_power_rate_min_value
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -downstream_min_low_power_rate_min_value
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -upstream_max_interleaving_delay_min_value
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -upstream_act_interleaving_delay_min_value
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -downstream_max_interleaving_delay_min_value
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -downstream_act_interleaving_delay_min_value
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -percentage
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -actual_rate_downstream_repeat
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -actual_rate_upstream_repeat
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -customer_vlan_id
#n   -customer_vlan_id_repeat
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -customer_vlan_id_step
#    -downstream_rate_tolerance
#n   -enable_c_vlan
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -flap_mode
#n   -remote_id_suffix
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -remote_id_suffix_repeat
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -remote_id_suffix_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -service_vlan_id
#n   -service_vlan_id_repeat
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -service_vlan_id_step
#    -subscriber_line_down_time
#    -subscriber_line_up_time
#    -subscriber_lines_per_access_node
#    -upstream_rate_tolerance
#    -vlan_allocation_model
#
# Return Values:
#    A list containing the ancp subscriber lines protocol stack handles that were added by the command (if any).
#x   key:ancp_subscriber_lines_handle  value:A list containing the ancp subscriber lines protocol stack handles that were added by the command (if any).
#    $::SUCCESS | $::FAILURE, Status of procedure call.
#    key:status                        value:$::SUCCESS | $::FAILURE, Status of procedure call.
#    When status is failure, contains more information.
#    key:log                           value:When status is failure, contains more information.
#    <ancp_subscriber_lines_handle> Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    key:handle                        value:<ancp_subscriber_lines_handle> Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    1) Unsupported parameters or unsupported parameter options will be
#    silently ignored. If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  handle
#
# See Also:
#

proc ::ixiangpf::emulation_ancp_subscriber_lines_config { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "emulation_ancp_subscriber_lines_config" $notImplementedParams $mandatoryParams $fileParams $args]
}
