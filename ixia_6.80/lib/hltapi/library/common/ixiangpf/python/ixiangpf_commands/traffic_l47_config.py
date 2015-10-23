# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def traffic_l47_config(self, mode, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    traffic_l47_config
		
		 Description:
		    This command configures L4-7 AppLibrary Traffic.
		
		 Synopsis:
		    traffic_l47_config
		x       -mode                               CHOICES create
		x                                           CHOICES modify
		x                                           CHOICES delete
		x                                           CHOICES enable
		x                                           CHOICES disable
		x                                           CHOICES get
		x                                           DEFAULT create
		x       [-stream_id                         ANY
		x                                           DEFAULT none]
		x       [-l47_configuration                 CHOICES modify_profile_parameters
		x                                           CHOICES modify_flow_percentage
		x                                           CHOICES modify_flow_parameter
		x                                           CHOICES modify_flow_connection_parameter
		x                                           CHOICES override_flows
		x                                           CHOICES append_flow
		x                                           CHOICES remove_flow
		x                                           CHOICES distribute_flows_percentage_evenly
		x                                           CHOICES get_available_flows]
		x       [-name                              ANY]
		x       [-circuit_endpoint_type             CHOICES ipv4_application_traffic
		x                                           CHOICES ipv6_application_traffic
		x                                           DEFAULT ipv4_application_traffic]
		x       [-emulation_src_handle              ANY]
		x       [-emulation_dst_handle              ANY]
		x       [-emulation_scalable_src_handle     ANY]
		x       [-emulation_scalable_src_port_start NUMERIC]
		x       [-emulation_scalable_src_port_count NUMERIC]
		x       [-emulation_scalable_src_intf_start NUMERIC]
		x       [-emulation_scalable_src_intf_count NUMERIC]
		x       [-emulation_scalable_dst_handle     ANY]
		x       [-emulation_scalable_dst_port_start NUMERIC]
		x       [-emulation_scalable_dst_port_count NUMERIC]
		x       [-emulation_scalable_dst_intf_start NUMERIC]
		x       [-emulation_scalable_dst_intf_count NUMERIC]
		x       [-objective_type                    CHOICES users tputkb tputmb tputgb
		x                                           DEFAULT users]
		x       [-objective_value                   NUMERIC]
		x       [-objective_distribution            CHOICES apply_full_objective_to_each_port
		x                                           CHOICES split_objective_evenly_among_ports
		x                                           DEFAULT apply_full_objective_to_each_port]
		x       [-enable_per_ip_stats               CHOICES 0 1]
		x       [-flows                             ANY]
		x       [-flow_percentage                   ANY]
		x       [-flow_id                           ANY]
		x       [-connection_id                     NUMERIC]
		x       [-parameter_id                      ANY]
		x       [-parameter_option                  CHOICES value choice range]
		x       [-parameter_value                   CHOICES numeric
		x                                           CHOICES bool
		x                                           CHOICES string
		x                                           CHOICES hex
		x                                           CHOICES choice
		x                                           CHOICES range]
		
		 Arguments:
		x   -mode
		x       Mode of the procedure call.Valid options are:
		x       create
		x       modify
		x       delete
		x       enable
		x       disable
		x       get
		x   -stream_id
		x       Required for -mode modify/remove/enable/disable/get calls.
		x       Stream ID returned from the traffic_l47_config handles.
		x       Stream ID is not required for configuring a stream for the first time. In this case, the stream ID is returned by the call..
		x       Valid for Application Library Traffic.
		x   -l47_configuration
		x       Required for -mode modify and -stream_id traffic_item_handler calls
		x       Valid for Application Library Traffic.
		x   -name
		x       Stream string identifier/name. If this name contains spaces,
		x       the spaces will be translated to underscores and a warning
		x       will be displayed. The string name must not contain commas.
		x   -circuit_endpoint_type
		x       This argument can be used to specify the endpoint type that will be
		x       used to generate traffic.
		x   -emulation_src_handle
		x       The handle used to retrieve information for L2 or L3 source addresses and use them to configure the sources for traffic.
		x       This should be the emulation handle that was obtained after configuring NGPF protocols.
		x       This parameter can be provided with a list or with a list of lists elements.
		x   -emulation_dst_handle
		x       The handle used to retrieve information for L2 or L3 source addresses and use them to configure the destinations for traffic.
		x       This should be the emulation handle that was obtained after configuring NGPF protocols.
		x       This parameter can be provided with a list or with a list of lists elements.
		x   -emulation_scalable_src_handle
		x       An array which contains lists of handles used to retrieve information for L3
		x       src addresses, indexed by the endpointset to which they correspond.
		x       This should be a handle that was obtained after configuring protocols with
		x       commands from the ::ixia_hlapi_framework:: namespace.
		x       This parameter can be used in conjunction with emulation_src_handle.
		x   -emulation_scalable_src_port_start
		x       An array which contains lists of numbers that encode the index of the first
		x       port on which the corresponding endpointset will be configured.
		x       This parameter will be ignored if no corresponding value is specified for
		x       emulation_scalable_src_handle.
		x   -emulation_scalable_src_port_count
		x       An array which contains lists of numbers that encode the number of ports on
		x       which the corresponding endpointset will be configured.
		x       This parameter will be ignored if no corresponding value is specified for
		x       emulation_scalable_src_handle.
		x   -emulation_scalable_src_intf_start
		x       An array which contains lists of numbers that encode the index of the first
		x       interface on which the corresponding endpointset will be configured.
		x       This parameter will be ignored if no corresponding value is specified for
		x       emulation_scalable_src_handle.
		x   -emulation_scalable_src_intf_count
		x       An array which contains lists of numbers that encode the number of interfaces
		x       on which the corresponding endpointset will be configured.
		x       This parameter will be ignored if no corresponding value is specified for
		x       emulation_scalable_src_handle.
		x   -emulation_scalable_dst_handle
		x       An array which contains lists of handles used to retrieve information for L3
		x       dst addresses, indexed by the endpointset to which they correspond.
		x       This should be a handle that was obtained after configuring protocols with
		x       commands from the ::ixia_hlapi_framework:: namespace.
		x       This parameter can be used in conjunction with emulation_dst_handle.
		x   -emulation_scalable_dst_port_start
		x       An array which contains lists of numbers that encode the index of the first
		x       port on which the corresponding endpointset will be configured.
		x       This parameter will be ignored if no corresponding value is specified for
		x       emulation_scalable_dst_handle.
		x   -emulation_scalable_dst_port_count
		x       An array which contains lists of numbers that encode the number of ports on
		x       which the corresponding endpointset will be configured.
		x       This parameter will be ignored if no corresponding value is specified for
		x       emulation_scalable_dst_handle.
		x   -emulation_scalable_dst_intf_start
		x       An array which contains lists of numbers that encode the index of the first
		x       interface on which the corresponding endpointset will be configured.
		x       This parameter will be ignored if no corresponding value is specified for
		x       emulation_scalable_dst_handle.
		x   -emulation_scalable_dst_intf_count
		x       An array which contains lists of numbers that encode the number of interfaces
		x       on which the corresponding endpointset will be configured.
		x       This parameter will be ignored if no corresponding value is specified for
		x       emulation_scalable_dst_handle.
		x   -objective_type
		x       sets objective type.
		x   -objective_value
		x       sets objective value.
		x   -objective_distribution
		x       sets objective distribution.
		x   -enable_per_ip_stats
		x       enables/disables per IP statistics.
		x   -flows
		x       sets flows to be configured when create a traffic application profile.
		x   -flow_percentage
		x       Amount of traffic to be generated for this flow in percentage.
		x   -flow_id
		x       Name of the Application Library flow ( e.g. HTTP_Request).
		x   -connection_id
		x       Application library flow connection identifier ( e.g. 1).
		x   -parameter_id
		x       Application library flow parameter identifier ( e.g. enableProxyPort).
		x   -parameter_option
		x       Each parameter has one or multiple options.
		x       This options are: value, choice and range.
		x   -parameter_value
		x       For each parameter a value can be assigned.
		x       The parameters are runtime specific and can accommodate the following types:
		
		 Return Values:
		    $::SUCCESS | $::FAILURE
		    key:status                                             value:$::SUCCESS | $::FAILURE
		    On status of failure, gives detailed information.
		    key:log                                                value:On status of failure, gives detailed information.
		    A list containing the handles of L47 traffic items that were added by the command (if any). This key is returned only when the command is issued with -mode create.
		x   key:traffic_l47_handle                                 value:A list containing the handles of L47 traffic items that were added by the command (if any). This key is returned only when the command is issued with -mode create.
		    This key returns the list of initiator ports configured in the traffic item mentioned by <traffic_l47_handle>.
		x   key:<traffic_l47_handle>.initiator_ports               value:This key returns the list of initiator ports configured in the traffic item mentioned by <traffic_l47_handle>.
		    This key returns the list of responder ports configured in the traffic item mentioned by <traffic_l47_handle>.
		x   key:<traffic_l47_handle>.responder_ports               value:This key returns the list of responder ports configured in the traffic item mentioned by <traffic_l47_handle>.
		    This key returns the applib handle configured in the traffic item mentioned by <traffic_l47_handle>.
		x   key:<traffic_l47_handle>.applib_profile                value:This key returns the applib handle configured in the traffic item mentioned by <traffic_l47_handle>.
		    This key returns the applib flows configured in the traffic item mentioned by <traffic_l47_handle> and the AppLib profile mentioned by the <applib_profile> handle.
		x   key:<traffic_l47_handle>.<applib_profile>.applib_flow  value:This key returns the applib flows configured in the traffic item mentioned by <traffic_l47_handle> and the AppLib profile mentioned by the <applib_profile> handle.
		    A list of the available flows. This key is returned only when the command is issued with -mode get.
		x   key:available_flows                                    value:A list of the available flows. This key is returned only when the command is issued with -mode get.
		
		 Examples:
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		
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
				'traffic_l47_config', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
