# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def emulation_mld_config(self, mode, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    emulation_mld_config
		
		 Description:
		    Configures MLD sessions.
		
		 Synopsis:
		    emulation_mld_config
		        -mode                             CHOICES create
		                                          CHOICES modify
		                                          CHOICES delete
		                                          CHOICES disable
		                                          CHOICES enable
		                                          CHOICES enable_all
		                                          CHOICES disable_all
		n       [-atm_encapsulation               ANY]
		x       [-count                           RANGE 1-4000
		x                                         DEFAULT 1]
		n       [-enable_packing                  ANY]
		        [-filter_mode                     CHOICES include exclude
		                                          DEFAULT include]
		        [-general_query                   CHOICES 0 1
		                                          DEFAULT 1]
		        [-group_query                     CHOICES 0 1
		                                          DEFAULT 1]
		        [-handle                          ANY]
		x       [-interface_handle                ANY]
		x       [-return_detailed_handles         CHOICES 0 1
		x                                         DEFAULT 0]
		        [-intf_ip_addr                    IPV6]
		        [-intf_ip_addr_step               IPV6
		                                          DEFAULT 0::1]
		        [-intf_prefix_len                 RANGE 1-128
		                                          DEFAULT 64]
		        [-ip_router_alert                 CHOICES 0 1
		                                          DEFAULT 1]
		x       [-mac_address_init                MAC
		x                                         DEFAULT 0011.0100.0001]
		x       [-mac_address_step                MAC
		x                                         DEFAULT 0000.0000.0001]
		n       [-max_groups_per_pkts             ANY]
		        [-max_response_control            CHOICES 0 1
		                                          DEFAULT 0]
		        [-max_response_time               RANGE 0-999999]
		n       [-max_sources_per_group           ANY]
		n       [-mldv2_report_type               ANY]
		        [-mld_version                     CHOICES v1 v2
		                                          DEFAULT v2]
		        [-msg_count_per_interval          NUMERIC
		                                          DEFAULT 0]
		        [-msg_interval                    NUMERIC
		                                          DEFAULT 0]
		        [-neighbor_intf_ip_addr           IPV6
		                                          DEFAULT 0::0]
		        [-neighbor_intf_ip_addr_step      IPV6
		                                          DEFAULT 0::0]
		n       [-no_write                        ANY]
		x       [-override_existence_check        CHOICES 0 1
		x                                         DEFAULT 0]
		x       [-override_tracking               CHOICES 0 1
		x                                         DEFAULT 0]
		        [-port_handle                     REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
		x       [-reset                           FLAG]
		n       [-robustness                      ANY]
		n       [-suppress_report                 ANY]
		        [-unsolicited_report_interval     NUMERIC
		                                          DEFAULT 120]
		n       [-vci                             ANY]
		n       [-vci_step                        ANY]
		x       [-vlan                            CHOICES 0 1
		x                                         CHOICES 0 1
		x                                         DEFAULT 0]
		n       [-vlan_cfi                        ANY]
		        [-vlan_id                         REGEXP ^[0-9]{1,4}(,[0-9]{1,4}){0,5}$
		                                          RANGE 0-4095]
		        [-vlan_id_mode                    CHOICES fixed increment
		                                          DEFAULT increment]
		        [-vlan_id_step                    REGEXP ^[0-9]{1,4}(,[0-9]{1,4}){0,5}$
		                                          RANGE 0-4095
		                                          DEFAULT 1]
		        [-vlan_user_priority              RANGE 0-7
		                                          REGEXP ^[0-7](,[0-7]){0,5}$
		                                          DEFAULT 0]
		n       [-vpi                             ANY]
		n       [-vpi_step                        ANY]
		x       [-name                            ALPHA]
		x       [-unsolicited_response_mode       ANY
		x                                         DEFAULT 0]
		x       [-join_leave_multiplier           NUMERIC
		x                                         DEFAULT 1]
		x       [-enable_iptv                     CHOICES 0 1]
		x       [-iptv_name                       ALPHA]
		x       [-stb_leave_join_delay            NUMERIC]
		x       [-join_latency_threshold          NUMERIC]
		x       [-leave_latency_threshold         NUMERIC]
		x       [-zap_behavior                    CHOICES zaponly zapandview onetime]
		x       [-zap_direction                   CHOICES up down random]
		x       [-zap_interval                    NUMERIC]
		x       [-num_channel_changes_before_view NUMERIC]
		x       [-view_duration                   ANY]
		x       [-global_settings_enable          CHOICES 0 1]
		x       [-no_of_reports_per_second        ANY]
		x       [-interval_in_ms                  NUMERIC]
		x       [-inter_stb_start_delay           NUMERIC
		x                                         DEFAULT 0]
		x       [-zap_interval_type               CHOICES leavetoleave multicasttoleave]
		x       [-log_failure_timestamps          CHOICES 0 1]
		
		 Arguments:
		    -mode
		        This option defines the action to be taken.
		n   -atm_encapsulation
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -count
		x       Number of sessions to create on the interface.
		n   -enable_packing
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -filter_mode
		        Configure MLDv2 Include Filter Mode.
		    -general_query
		        If 1, respond to general queries received on the interface.
		    -group_query
		        If 1, respond to group specific queries received on the interface.
		    -handle
		        This parameter is mandatory for all modes, when using NGPF (it specifies the stack on which to add the mld host).
		        For NGPF Backwards Compatibility for legacy HLT syntax support, if -mode is create, delete, modify, enable or disable this option is required
		        to specify the existing MLD session.
		x   -interface_handle
		x       This parameter is used only for NGPF Backwards Compatibility for legacy HLT sytax (only when -port_handle is given).
		x       <p>A handle or list of the handles that are returned from the interface_config call. These provide a direct link to an already existing interface and supercede the use of the intf_ip_addr value.</p>
		x       <p>Starting with IxNetwork 5.50 this parameter accepts handles returned by pppox_config procedure in the following format: |,-, ... The PPPoX ranges are separated from the Interface Index identifiers with the (|) character. The Interface Index identifiers are separated with comas (,). A range of Interface Index identifiers can be defined using the dash (-) character.</p>
		x       <p>Ranges along with the Interface Index identifiers are grouped together in TCL Lists. The lists can contain mixed items, protocol interface handles returned by interface_config and handles returned by pppox_config along with the interface index. </p>
		x       <p>Example:count 10 (10 MLD routers). 3 pppox range handles returned by ::::pppox_config. Each pppox range has 20 sessions (interfaces). If we pass -interface_handle in the following format: [list $pppox_r1|1,5 $pppox_r2|1-3 $pppox_r3|1,3,5-9,13] The interfaces will be distributed to the routers in the following manner:</p>
		x       <p>
		x       <ul>
		x       <li>MLD Router 1: $pppox_r1 -> interface 1</li>
		x       <li>MLD Router 2: $pppox_r1 -> interface 5</li>
		x       <li>MLD Router 3: $pppox_r2 -> interface 1</li>
		x       <li>MLD Router 4: $pppox_r2 -> interface 2</li>
		x       <li>MLD Router 5: $pppox_r2 -> interface 3</li>
		x       <li>MLD Router 6: $pppox_r3 -> interface 1</li>
		x       <li>MLD Router 7: $pppox_r3 -> interface 3</li>
		x       <li>MLD Router 8: $pppox_r3 -> interface 5</li>
		x       <li>MLD Router 9: $pppox_r3 -> interface 6</li>
		x       <li>MLD Router 10: $pppox_r3 -> interface 7</li>
		x       <li>MLD Router 11: $pppox_r3 -> interface 8</li>
		x       <li>MLD Router 12: $pppox_r3 -> interface 9</li>
		x       <li>MLD Router 13: $pppox_r3 -> interface 1</li>
		x       <li>3Valid for mode create</li>
		x       </ul>
		x       </p>
		x   -return_detailed_handles
		x       This argument determines if individual interface, session or router handles are returned by the current command.
		x       This applies only to the command on which it is specified.
		x       Setting this to 0 means that only NGPF-specific protocol stack handles will be returned. This will significantly
		x       decrease the size of command results and speed up script execution.
		x       The default is 0, meaning only protocol stack handles will be returned.
		    -intf_ip_addr
		        IP address of the test interface / emulated mld Host.
		    -intf_ip_addr_step
		        Used to increment IP address.
		    -intf_prefix_len
		        Address prefix length.
		    -ip_router_alert
		        If 1, enable IP Router Alert Option.
		x   -mac_address_init
		x       MAC address to be set on the interface.
		x   -mac_address_step
		x       The incrementing step for the MAC address to be set on the interface.
		x       This option is valid only when IxTclNetwork API is used.
		n   -max_groups_per_pkts
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -max_response_control
		        If 1, use -max_response_time to overwrite the value obtained from
		        the received Query message.
		    -max_response_time
		        Set the maximum response time (in 1/10 seconds) on receipt of a query.
		        If set to 0, immediately respond to received Query message.
		n   -max_sources_per_group
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -mldv2_report_type
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -mld_version
		        Indicates the MLD protocol version to be used.
		    -msg_count_per_interval
		        The number of multicast MLD groups to be advertised during each time period.
		        A value of 0 disables this feature and transmits all groups
		        immediately for all updates. Valid only with IxTclNetwork API.
		        Used for MLDv2 only.
		    -msg_interval
		        The interval (in ms) used for throttling updates. Use the value 0 to
		        send messages as fast as possible.
		    -neighbor_intf_ip_addr
		        Neighbor's interface IP address.
		    -neighbor_intf_ip_addr_step
		        Neighbor's interface IP address increment step for creating multiple
		        sessions. Default is 0, i.e. same IP address for all sessions.
		n   -no_write
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -override_existence_check
		x       If this option is enabled, the interface existence check is skipped but
		x       the list of interfaces is still created and maintained in order to keep
		x       track of existing interfaces if required. Using this option will speed
		x       up the interfaces' creation. Valid only for IxTclNetwork API.
		x   -override_tracking
		x       If this option is enabled, the list of interfaces won t be created and
		x       maintained anymore, thus, speeding up the interfaces' creation even
		x       more. Also, it will enable -override_existence_check in case it wasn t
		x       already enabled because checking for interface existence becomes
		x       impossible if the the list of interfaces doesn t exist anymore.
		x       Valid only for IxTclNetwork API.
		    -port_handle
		        This option is required to specify the port where to take the action.
		x   -reset
		x       Resets the MLD Host configuration on port.
		n   -robustness
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -suppress_report
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -unsolicited_report_interval
		        The interval (in seconds) to wait before re-sending the host's
		        initial report of membership in a group. If 0, do not send unsolicited
		        report.
		n   -vci
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -vci_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -vlan
		x       Enables vlan on the directly connected MLD router interface.
		x       Valid options are: 0 (disable) / 1 (enable).
		x       This option is valid only when -mode is create or -mode is modify
		x       and -handle is a MLD router handle.
		x       This option is available only when IxNetwork tcl API is used.
		n   -vlan_cfi
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -vlan_id
		        VLAN ID for emulated router node.
		    -vlan_id_mode
		        For multiple neighbor configuration, configures the VLAN ID mode to
		        be fixed or increment.
		    -vlan_id_step
		        <p>When -vlan_id_mode isset to increment, this defines the step for
		        every VLAN.
		        When vlan_id_step causes the vlan_id value to exceed it's maximum value the
		        increment will be done modulo number of possible vlan ids. Examples:</p>
		        <p>
		        <ul>
		        <li>vlan_id = 4094; vlan_id_step = 2;-> new vlan_id value = 0</li>
		        <li>vlan_id = 4095; vlan_id_step = 11; -> new vlan_id value = 10</li>
		        </ul>
		        </p>
		    -vlan_user_priority
		        VLAN user priority assigned to emulated router node.
		n   -vpi
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -vpi_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -name
		x       The name of the protocol stack.
		x   -unsolicited_response_mode
		x       Unsolicited Response Mode.
		x   -join_leave_multiplier
		x       No. of Join/Leave messages to send per operation
		x   -enable_iptv
		x       Enable IPTV
		x   -iptv_name
		x       Name of NGPF element, guaranteed to be unique in Scenario
		x   -stb_leave_join_delay
		x       Time in milliseconds between sending a Leave for the current channel and Join for the next channel.
		x   -join_latency_threshold
		x       The maximum time that is allowed for a multicast stream to arrive for channel for which a Join has been sent.
		x   -leave_latency_threshold
		x       The maximum time allowed for a multicast stream to stop for a channel for which a Leave has been sent.
		x   -zap_behavior
		x       Use Zap Only to change channels without viewing the channel or Zap and View to change traffic and receive traffic for the last channel.
		x   -zap_direction
		x       Specifies the direction of changing channels.
		x   -zap_interval
		x       Interval in milliseconds between channel changes based on the selected type.
		x   -num_channel_changes_before_view
		x       Number of channels to change before stopping on a channel and watching it for View Duration.
		x   -view_duration
		x       Specifies the time in milliseconds to view the last channel.
		x   -global_settings_enable
		x       Enable Global Settings for MLD protocol.
		x   -no_of_reports_per_second
		x       No. of Reports per Second
		x   -interval_in_ms
		x       Time interval used to calculate the rate for triggering an action (rate = count/interval)
		x   -inter_stb_start_delay
		x       Time in milliseconds between Join messages from clients within the same range.
		x   -zap_interval_type
		x       Specifies the wait interval type before changing the channels.
		x   -log_failure_timestamps
		x       If enabled, the timestamps for Join and Leave failures are saved to a log file.
		
		 Return Values:
		    A list containing the mld host protocol stack handles that were added by the command (if any).
		x   key:mld_host_handle       value:A list containing the mld host protocol stack handles that were added by the command (if any).
		    A list containing the ethernet protocol stack handles that were added by the command (if any).
		x   key:ethernet_handle       value:A list containing the ethernet protocol stack handles that were added by the command (if any).
		    A list containing the ipv6 protocol stack handles that were added by the command (if any).
		x   key:ipv6_handle           value:A list containing the ipv6 protocol stack handles that were added by the command (if any).
		    A list containing the dhcpv6 client protocol stack handles that were added by the command (if any).
		x   key:dhcpv6_client_handle  value:A list containing the dhcpv6 client protocol stack handles that were added by the command (if any).
		    A list containing the pppox client protocol stack handles that were added by the command (if any).
		x   key:pppox_client_handle   value:A list containing the pppox client protocol stack handles that were added by the command (if any).
		    A list containing the pppox server protocol stack handles that were added by the command (if any).
		x   key:pppox_server_handle   value:A list containing the pppox server protocol stack handles that were added by the command (if any).
		    A list containing the mld host iptv protocol stack handles that were added by the command (if any).
		x   key:mld_host_iptv_handle  value:A list containing the mld host iptv protocol stack handles that were added by the command (if any).
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:interface_handle      value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:mld_iptv_handles      value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    $::SUCCESS | $::FAILURE
		    key:status                value:$::SUCCESS | $::FAILURE
		    If status is failure, contains more information
		    key:log                   value:If status is failure, contains more information
		    List of session handles Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    key:handle                value:List of session handles Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		
		 Examples:
		    See files starting with MLD_ in the Samples subdirectory.
		    See the MLD example in Appendix A, "Example APIs," for one specific example usage.
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    1) MLD implementation using IxTclNetwork is NOT SUPPORTED in HLTAPI 3.30. If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  handle, interface_handle, mld_iptv_handles
		
		 See Also:
		
		'''
		hlpy_args = locals().copy()
		hlpy_args.update(kwargs)
		del hlpy_args['self']
		del hlpy_args['kwargs']

		not_implemented_params = []
		mandatory_params = []
		file_params = []

		try:
			return self.__execute_command(
				'emulation_mld_config', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
