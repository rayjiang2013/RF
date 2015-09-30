# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def emulation_igmp_querier_config(self, mode, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    emulation_igmp_querier_config
		
		 Description:
		    This procedure will configure IGMP Querier(s).
		
		 Synopsis:
		    emulation_igmp_querier_config
		        -mode                               CHOICES create
		                                            CHOICES modify
		                                            CHOICES delete
		                                            CHOICES disable
		                                            CHOICES enable
		n       [-atm_encapsulation                 ANY]
		x       [-count                             NUMERIC
		x                                           DEFAULT 1]
		x       [-discard_learned_info              CHOICES 0 1
		x                                           DEFAULT 1]
		x       [-active                            CHOICES 0 1
		x                                           DEFAULT 1]
		x       [-general_query_response_interval   RANGE 1-3174400
		x                                           DEFAULT 10000]
		x       [-handle                            ANY]
		x       [-igmp_version                      CHOICES v1 v2 v3
		x                                           DEFAULT v2]
		x       [-interface_handle                  ANY]
		x       [-intf_ip_addr                      IPV4]
		x       [-intf_ip_addr_step                 IPV4
		x                                           DEFAULT 0.0.0.1]
		x       [-intf_prefix_len                   RANGE 1-32
		x                                           DEFAULT 24]
		x       [-ip_router_alert                   CHOICES 0 1
		x                                           DEFAULT 1]
		x       [-mac_address_init                  MAC]
		x       [-mac_address_step                  MAC
		x                                           DEFAULT 0000.0000.0001]
		x       [-msg_count_per_interval            NUMERIC]
		x       [-msg_interval                      NUMERIC]
		x       [-neighbor_intf_ip_addr             IPV4]
		x       [-neighbor_intf_ip_addr_step        IPV4
		x                                           DEFAULT 0.0.0.0]
		n       [-no_write                          ANY]
		x       [-override_existence_check          CHOICES 0 1
		x                                           DEFAULT 0]
		x       [-override_tracking                 CHOICES 0 1
		x                                           DEFAULT 0]
		        [-port_handle                       REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
		x       [-reset                             FLAG]
		x       [-robustness_variable               RANGE 1-7
		x                                           DEFAULT 2]
		x       [-specific_query_response_interval  RANGE 1-3174400
		x                                           DEFAULT 1000]
		x       [-specific_query_transmission_count RANGE 1-255
		x                                           DEFAULT 2]
		x       [-startup_query_count               RANGE 1-255
		x                                           DEFAULT 2]
		x       [-support_election                  CHOICES 0 1
		x                                           DEFAULT 1]
		x       [-support_older_version_host        CHOICES 0 1
		x                                           DEFAULT 1]
		x       [-support_older_version_querier     CHOICES 0 1
		x                                           DEFAULT 1]
		n       [-vci                               ANY]
		n       [-vci_step                          ANY]
		x       [-vlan                              CHOICES 0 1
		x                                           DEFAULT 0]
		x       [-vlan_id                           RANGE 0-4095
		x                                           DEFAULT 1]
		x       [-vlan_id_mode                      CHOICES fixed increment
		x                                           DEFAULT increment]
		x       [-vlan_id_step                      RANGE 0-4096
		x                                           DEFAULT 1]
		x       [-vlan_user_priority                RANGE 0-7
		x                                           DEFAULT 0]
		n       [-vpi                               ANY]
		n       [-vpi_step                          ANY]
		x       [-query_interval                    RANGE 1-31744
		x                                           DEFAULT 125]
		x       [-no_of_queries_per_unit_time       NUMERIC
		x                                           DEFAULT 0]
		x       [-time_period                       NUMERIC
		x                                           DEFAULT 0]
		x       [-global_settings_enable            CHOICES 0 1]
		x       [-name                              ALPHA]
		
		 Arguments:
		    -mode
		        This option defines the action to be taken.
		n   -atm_encapsulation
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -count
		x       Defines the number of sessions to create on the interface. Valid for
		x       mode create.
		x   -discard_learned_info
		x       When -discard_learned_info is 0, the emulated Querier maintains a complete record state for received reports and send queries (based on timer expiry for received groups and sources).
		x       If -discard_learned_info is 1, the Querier does not maintain any database and only sends periodic general queries. The specific query group/source record information is not calculated based on any earlier received Report, but is based only on the last received report.
		x   -active
		x       Specifies whether the emulated IGMP Querier is active or not.
		x   -general_query_response_interval
		x       General Query Response Interval in milliseconds
		x   -handle
		x       IGMP Host handle if the option -mode is delete, modify, disable, enable.
		x       When -handle is provided with the /globals value the arguments that configure global protocol
		x       setting accept both multivalue handles and simple values.
		x       When -handle is provided with a a protocol stack handle or a protocol session handle, the arguments
		x       that configure global settings will only accept simple values. In this situation, these arguments will
		x       configure only the settings of the parent device group or the ports associated with the parent topology.
		x   -igmp_version
		x       The version of IGMP to be used: v1, v2, v3. Valid for mode create.
		x   -interface_handle
		x       A handle or list of the handles that are returned from the interface_config call. These provide a direct link to an already existing interface and supercede the use of the intf_ip_addr value.
		x       <p>Starting with IxNetwork 5.50 this parameter accepts handles returned by
		x       pppox_config procedure in the following format:
		x       (PPPoX Range Handle)|(interface index X),(interface index Y)-(interface index Z), ... </p>
		x       <p>The PPPoX ranges are separated from the Interface Index identifiers with the (|) character.
		x       The Interface Index identifiers are separated with comas (,).
		x       A range of Interface Index identifiers can be defined using the dash (-) character. </p>
		x       <p> Ranges along with the Interface Index identifiers are grouped together in TCL Lists. The
		x       lists can contain mixed items, protocol interface handles returned by interface_config
		x       and handles returned by pppox_config along with the interface index. Valid for mode create. </p>
		x   -intf_ip_addr
		x       IP address of the test interface / emulated IGMP Host. Valid for mode create and modify.
		x   -intf_ip_addr_step
		x       The IP address step between each session. Valid for mode create and modify.
		x   -intf_prefix_len
		x       The netmask length value for the interface. Valid for mode create and modify.
		x   -ip_router_alert
		x       If true (1), enable IP Router Alert Option. Valid for mode create and modify.
		x   -mac_address_init
		x       The MAC address for the interface to be created. Valid for mode create and modify.
		x   -mac_address_step
		x       The incrementing step for the MAC address of the interface to be
		x       created. Valid only when using IxNetwork Tcl API. Valid for mode create and modify.
		x   -msg_count_per_interval
		x       The number of reports that an IGMP Querier sends out during the specified time period.
		x       This parameter is only applicable for IGMP Queriers.
		x   -msg_interval
		x       The time period (milliseconds) for sending out IGMP queries. This parameter is only applicable for IGMP Queriers.
		x   -neighbor_intf_ip_addr
		x       IP address of the neighbor.
		x   -neighbor_intf_ip_addr_step
		x       The IP address step between each session.
		n   -no_write
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -override_existence_check
		x       If this option is enabled, the interface existence check is skipped but
		x       the list of interfaces is still created and maintained in order to keep
		x       track of existing interfaces, if required. Using this option will speed
		x       up the creation of interfaces. Valid for mode create.
		x   -override_tracking
		x       If this option is enabled, the list of interfaces will not be created and
		x       maintained anymore, thus speeding up the creation of interfaces even
		x       more. Also, it will enable -override_existence_check in case it was not
		x       already enabled, because checking for interface existence becomes
		x       impossible if the the list of interfaces doesn t exist anymore. Valid for mode create.
		    -port_handle
		        The port on which the operation will apply.
		x   -reset
		x       Clear all existent hosts. Valid for mode create.
		x   -robustness_variable
		x       Defines the subnet vulnerability to lost packets. IGMP can recover from
		x       robustness variable minus 1 lost IGMP packets. The robustness variable
		x       should be set to a value of 2 or greater (7 being the maximum).
		x   -specific_query_response_interval
		x       The maximum amount of time in seconds that the IGMP Querier waits to receive
		x       a response to a Specific Query message. The default query response interval
		x       is 1000 milliseconds and must be less than the query interval. This parameter will be set
		x       (-mode create and -modify) only if discard_learned_info is not enabled.
		x   -specific_query_transmission_count
		x       Indicates the total number of specific Query messages sent every Specific
		x       Query Response Interval seconds before assuming that there is no interested
		x       listener for the particular group/source. This parameter will be set
		x       (-mode create and -modify) only if discard_learned_info is not enabled.
		x   -startup_query_count
		x       The number of general query messages sent at startup.
		x   -support_election
		x       Indicates whether or not the Querier participates in querier election.
		x       If disabled, then all incoming query messages are discarded.
		x   -support_older_version_host
		x       Indicates whether the Querier will comply to RFC 3376 Section 7.3.2 and
		x       RFC 3810 Section 8.3.2. If disabled, all membership reports with a version
		x       less than the current version are discarded.
		x   -support_older_version_querier
		x       Indicates whether the Querier downgrades to the lowest version of received
		x       query messages. If disabled, all query messages with a version less than
		x       the current version are discarded.
		n   -vci
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -vci_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -vlan
		x       Enables vlan on the directly connected IGMP router interface.
		x       Valid options are: 0 - disable, 1 - enable.
		x       This option is valid only when -mode is create or -mode is modify
		x       and -handle is an IGMP router handle.
		x       This option is available only when IxNetwork tcl API is used.
		x   -vlan_id
		x       VLAN ID for emulated router node. Valid for mode create and modify.
		x   -vlan_id_mode
		x       For multiple neighbor configuration, configures the VLAN ID mode to
		x       fixed or increment. Valid for mode create and modify.
		x   -vlan_id_step
		x       <p>When -vlan_id_mode is set to increment, this defines the step for
		x       every VLAN. Valid for mode create.</p>
		x       <p>When vlan_id_step causes the vlan_id value to exceed it's maximum value the
		x       increment will be done modulo (number of possible vlan ids).
		x       Examples: </p>
		x       <p>
		x       <ul>
		x       <li>vlan_id = 4094; vlan_id_step = 2-> new vlan_id value = 0 </li>
		x       <li>vlan_id = 4095; vlan_id_step = 11 -> new vlan_id value = 10 </li>
		x       </ul>
		x       </p>
		x   -vlan_user_priority
		x       VLAN user priority assigned to emulated router node. Valid for mode create and modfiy.
		n   -vpi
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -vpi_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -query_interval
		x       Represents the general query response interval in ms
		x   -no_of_queries_per_unit_time
		x       The number of reports that an IGMP Querier sends out during the specified time period. This parameter is only applicable for IGMP Queriers.
		x   -time_period
		x       The time period (milliseconds) for sending out IGMP queries. This parameter is only applicable for IGMP Queriers.
		x   -global_settings_enable
		x       Enable/Disable Rate Control
		x   -name
		x       Name of the igmp protocol as it should appear in the IxNetwork GUI
		
		 Return Values:
		    A list containing the igmp querier protocol stack handles that were added by the command (if any).
		x   key:igmp_querier_handle   value:A list containing the igmp querier protocol stack handles that were added by the command (if any).
		    A list containing the ethernet protocol stack handles that were added by the command (if any).
		x   key:ethernet_handle       value:A list containing the ethernet protocol stack handles that were added by the command (if any).
		    A list containing the ipv4 protocol stack handles that were added by the command (if any).
		x   key:ipv4_handle           value:A list containing the ipv4 protocol stack handles that were added by the command (if any).
		    A list containing the dhcpv4 client protocol stack handles that were added by the command (if any).
		x   key:dhcpv4_client_handle  value:A list containing the dhcpv4 client protocol stack handles that were added by the command (if any).
		    A list containing the pppox client protocol stack handles that were added by the command (if any).
		x   key:pppox_client_handle   value:A list containing the pppox client protocol stack handles that were added by the command (if any).
		    A list containing the pppox server protocol stack handles that were added by the command (if any).
		x   key:pppox_server_handle   value:A list containing the pppox server protocol stack handles that were added by the command (if any).
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:igmp_querier_handles  value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:interface_handle      value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    $::SUCCESS | $::FAILURE
		    key:status                value:$::SUCCESS | $::FAILURE
		    The handles for the IGMP Querier created
		    key:handle                value:The handles for the IGMP Querier created
		    If status is failure, detailed information provided.
		    key:log                   value:If status is failure, detailed information provided.
		
		 Examples:
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    When -handle is provided with the /globals value the arguments that configure global protocol
		    setting accept both multivalue handles and simple values.
		    When -handle is provided with a a protocol stack handle or a protocol session handle, the arguments
		    that configure global settings will only accept simple values. In this situation, these arguments will
		    configure only the settings of the parent device group or the ports associated with the parent topology.
		    If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  igmp_querier_handles, interface_handle
		
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
				'emulation_igmp_querier_config', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
