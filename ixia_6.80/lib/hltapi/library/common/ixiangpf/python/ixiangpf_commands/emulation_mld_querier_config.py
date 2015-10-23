# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def emulation_mld_querier_config(self, mode, handle, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    emulation_mld_querier_config
		
		 Description:
		    Configures MLD Querier sessions.
		
		 Synopsis:
		    emulation_mld_querier_config
		        -mode                               CHOICES create
		                                            CHOICES modify
		                                            CHOICES delete
		                                            CHOICES disable
		                                            CHOICES enable
		x       -handle                             ANY
		x       [-version                           CHOICES version1 version2
		x                                           DEFAULT version2]
		x       [-startup_query_count               ANY
		x                                           DEFAULT 2]
		x       [-general_query_interval            ANY
		x                                           DEFAULT 125]
		x       [-router_alert                      ANY
		x                                           DEFAULT 1]
		x       [-robustness_variable               ANY
		x                                           DEFAULT 2]
		x       [-general_query_response_interval   ANY
		x                                           DEFAULT 10000]
		x       [-specific_query_response_interval  ANY
		x                                           DEFAULT 1000]
		x       [-specific_query_transmission_count ANY
		x                                           DEFAULT 2]
		x       [-support_election                  ANY
		x                                           DEFAULT 1]
		x       [-support_older_version_host        ANY
		x                                           DEFAULT 1]
		x       [-support_older_version_querier     ANY
		x                                           DEFAULT 1]
		x       [-discard_learnt_info               ANY
		x                                           DEFAULT 1]
		x       [-active                            ANY
		x                                           DEFAULT 1]
		x       [-name                              ALPHA]
		x       [-count                             NUMERIC
		x                                           DEFAULT 1]
		x       [-intf_ip_addr                      IPV6]
		x       [-intf_ip_addr_step                 IPV6
		x                                           DEFAULT 0::1]
		x       [-intf_prefix_len                   RANGE 1-128
		x                                           DEFAULT 64]
		x       [-neighbor_intf_ip_addr             IP]
		x       [-neighbor_intf_ip_addr_step        IP
		x                                           DEFAULT 0::0]
		x       [-mac_address_init                  MAC]
		x       [-mac_address_step                  MAC
		x                                           DEFAULT 0000.0000.0001]
		x       [-vlan                              CHOICES 0 1
		x                                           DEFAULT 0]
		x       [-vlan_id                           RANGE 0-4095]
		x       [-vlan_id_mode                      CHOICES fixed increment
		x                                           DEFAULT increment]
		x       [-vlan_id_step                      RANGE 0-4096
		x                                           DEFAULT 1]
		x       [-vlan_user_priority                RANGE 0-7
		x                                           DEFAULT 0]
		x       [-enabled                           ANY]
		x       [-no_of_queries_per_unit_time       ANY]
		x       [-time_period                       ANY]
		
		 Arguments:
		    -mode
		        This option defines the action to be taken.
		x   -handle
		x       If -mode is create, delete, modify, enable or disable this option is required
		x       to specify the existing MLD Querier session.
		x   -version
		x       MLD Querier Version
		x   -startup_query_count
		x       The number of general query messages sent at startup.
		x   -general_query_interval
		x       General Query Interval in seconds
		x   -router_alert
		x       If true (1), enable IP Router Alert Option.
		x   -robustness_variable
		x       Defines the subnet vulnerability to lost packets. MLD can recover from robustness variable minus 1 lost MLD packets.
		x       The robustness variable should be set to a value of 2 or greater (7 being the maximum).
		x   -general_query_response_interval
		x       General Query Response Interval in milliseconds
		x   -specific_query_response_interval
		x       The maximum amount of time in seconds that the MLD Querier waits to receivea response to a Specific
		x       Query message. The default query response interval is 1000 milliseconds and must be less than the query interval.
		x       This parameter will be set (-mode create and -modify) only if discard_learned_info is not enabled.
		x   -specific_query_transmission_count
		x       Indicates the total number of specific Query messages sent every Specific Query Response Interval
		x       seconds before assuming that there is no interestedlistener for the particular group/source.
		x       This parameter will be set (-mode create and -modify) only if discard_learned_info is not enabled.
		x   -support_election
		x       Indicates whether or not the Querier participates in querier election. If disabled, then all incoming query messages are discarded.
		x   -support_older_version_host
		x       Indicates whether the Querier will comply to RFC 3376 Section 7.3.2 and RFC 3810 Section 8.3.2. If disabled, all membership reports with a version less than the current version are discarded.
		x   -support_older_version_querier
		x       Indicates whether the Querier downgrades to the lowest version of received query messages. If disabled, all query messages with a version less than the current version are discarded.
		x   -discard_learnt_info
		x       When -discard_learnt_info is 0, the emulated Querier maintains a complete record state for received
		x       reports and send queries (based on timer expiry for received groups and sources).
		x       If -discard_learnt_info is 1, the Querier does not maintain any database and only sends periodic general queries.
		x       The specific query group/source record information is not calculated based on any earlier received report, but is based only on the last received report.
		x   -active
		x       Specifies if the selected querier will be active or not.
		x   -name
		x       Name of the sppecified stack.
		x   -count
		x       Defines the number of sessions to create on the interface.
		x   -intf_ip_addr
		x       IP address of the test interface / emulated MLD Querier.
		x   -intf_ip_addr_step
		x       The IP address step between each session.
		x   -intf_prefix_len
		x       The netmask length value for the interface.
		x   -neighbor_intf_ip_addr
		x       IP address of the neighbor.
		x   -neighbor_intf_ip_addr_step
		x       The IP address step between each session.
		x   -mac_address_init
		x       The MAC address for the interface to be created.
		x   -mac_address_step
		x       The incrementing step for the MAC address of the interface to be
		x       created. Valid only when using IxNetwork Tcl API.
		x   -vlan
		x       Enables vlan on the directly connected MLD router interface.
		x       Valid options are: 0 - disable, 1 - enable.
		x       This option is valid only when -mode is create or -mode is modify
		x       and -handle is an MLD router handle.
		x       This option is available only when IxNetwork tcl API is used.
		x   -vlan_id
		x       VLAN ID for emulated router node. Valid for mode create and modify.
		x   -vlan_id_mode
		x       For multiple neighbor configuration, configures the VLAN ID mode to
		x       fixed or increment. Valid for mode create and modify.
		x   -vlan_id_step
		x       When -vlan_id_mode is set to increment, this defines the step for
		x       every VLAN. Valid for mode create.
		x       When vlan_id_step causes the vlan_id value to exceed it's maximum value the
		x       increment will be done modulo <number of possible vlan ids>.
		x       Examples: vlan_id = 4094; vlan_id_step = 2-> new vlan_id value = 0
		x       vlan_id = 4095; vlan_id_step = 11 -> new vlan_id value = 10
		x   -vlan_user_priority
		x       VLAN user priority assigned to emulated router node. Valid for mode create and modfiy.
		x   -enabled
		x       Enable/Disable Rate Control
		x   -no_of_queries_per_unit_time
		x       No. of Queries (per Time Period)
		x   -time_period
		x       Time Period
		
		 Return Values:
		    A list containing the mld querier protocol stack handles that were added by the command (if any).
		x   key:mld_querier_handle    value:A list containing the mld querier protocol stack handles that were added by the command (if any).
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
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:interface_handle      value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    $::SUCCESS | $::FAILURE
		    key:status                value:$::SUCCESS | $::FAILURE
		    The handles for the MLD Querier created Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    key:mld_querier_handles   value:The handles for the MLD Querier created Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		
		 Examples:
		    See files starting with MLD_ in the Samples subdirectory.
		    See the MLD example in Appendix A, "Example APIs," for one specific example usage.
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    1) MLD implementation using IxTclNetwork is NOT SUPPORTED in HLTAPI 3.30. If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  mld_querier_handles, interface_handle
		
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
				'emulation_mld_querier_config', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
