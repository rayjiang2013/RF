# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def emulation_lacp_info(self, mode, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    emulation_lacp_info
		
		 Description:
		    Retrieves information about the LACP protocol
		    The following operations are done:
		    aggregate_stats learned_info clear_stats configuration
		
		 Synopsis:
		    emulation_lacp_info
		        -mode          CHOICES aggregate_stats
		                       CHOICES global_learned_info
		                       CHOICES per_port
		                       CHOICES per_device_group
		                       CHOICES per_lag_statistics
		                       CHOICES clear_stats
		                       CHOICES configuration
		        [-session_type CHOICES lacp staticLag
		                       DEFAULT lacp]
		        [-handle       ANY]
		        [-port_handle  REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
		
		 Arguments:
		    -mode
		    -session_type
		        The LACP to be emulated. CHOICES: lacp static_lag.
		    -handle
		    -port_handle
		
		 Return Values:
		    $::SUCCESS | $::FAILURE
		    key:status                                                      value:$::SUCCESS | $::FAILURE
		    On status of failure, gives detailed information.
		    key:log                                                         value:On status of failure, gives detailed information.
		    key:Aggregate stats:                                            value:
		    key:<port_handle>.aggregate.port_name                           value:
		    key:<port_handle>.aggregate.sessions_up                         value:
		    key:<port_handle>.aggregate.sessions_flap                       value:
		    key:<port_handle>.aggregate.sessions_not_started                value:
		    key:<port_handle>.aggregate.sessions_down                       value:
		    key:<port_handle>.aggregate.link_state                          value:
		    key:<port_handle>.aggregate.lag_id                              value:
		    key:<port_handle>.aggregate.total_lag_member_ports              value:
		    key:<port_handle>.aggregate.lag_member_ports_up                 value:
		    key:<port_handle>.aggregate.lacpdu_tx                           value:
		    key:<port_handle>.aggregate.lacpdu_rx                           value:
		    key:<port_handle>.aggregate.lacpu_malformed_rx                  value:
		    key:<port_handle>.aggregate.marker_pdu_tx                       value:
		    key:<port_handle>.aggregate.marker_pdu_rx                       value:
		    key:<port_handle>.aggregate.marker_res_pdu_tx                   value:
		    key:<port_handle>.aggregate.marker_res_pdu_rx                   value:
		    key:<port_handle>.aggregate.marker_res_timeout_count            value:
		    key:<port_handle>.aggregate.lacpdu_tx_rate_violation_count      value:
		    key:<port_handle>.aggregate.marker_pdu_tx_rate_violation_count  value:
		    key:<port_handle>.aggregate.lag_id                              value:
		    key:lag_id                                                      value:
		    key:actor_system_id                                             value:
		    key:actor_system_priority                                       value:
		    key:actor_port_number                                           value:
		    key:administrative_key                                          value:
		    key:actor_operationalkey                                        value:
		    key:actor_lacp_activity                                         value:
		    key:actor_lacp_activity                                         value:
		    key:actor_lacpdu_timeout                                        value:
		    key:actor_aggregration_enabled                                  value:
		    key:actor_synchronized_flag                                     value:
		    key:actor_synchronized_flag                                     value:
		    key:actor_collecting_flag                                       value:
		    key:actor_defaulted_flag                                        value:
		    key:actor_expired_flag                                          value:
		    key:link_aggregration_status                                    value:
		    key:partner_system_id                                           value:
		    key:partner_system_priority                                     value:
		    key:partner_port_number                                         value:
		    key:partner_port_priority                                       value:
		    key:partner_operational_key                                     value:
		    key:partner_lacp_activity                                       value:
		    key:partner_lacpdu_timeout                                      value:
		    key:partner_aggregration                                        value:
		    key:partner_synchronized_flag                                   value:
		    key:partner_collecting_flag                                     value:
		    key:partner_distributing_flag                                   value:
		    key:partner_defaulted_flag                                      value:
		    key:partner_expired_flag                                        value:
		    key:collectors_max_delay                                        value:
		    key:other_lag_member_count                                      value:
		    key:details                                                     value:
		
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
				'emulation_lacp_info', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
