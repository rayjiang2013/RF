# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def emulation_igmp_info(self, mode, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    emulation_igmp_info
		
		 Description:
		    This procedure gathers IGMP statistics.
		    This procedure is only supported for IxTclNetwork.
		    It is not supported by IxNetwork-FT.
		
		 Synopsis:
		    emulation_igmp_info
		x       -mode         CHOICES stats_per_device_group
		x                     CHOICES stats_per_session
		x                     CHOICES aggregate
		x                     CHOICES clear_stats
		x                     CHOICES learned_info
		x                     DEFAULT aggregate
		        [-port_handle REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
		n       [-timeout     ANY]
		x       [-handle      ANY]
		x       [-type        CHOICES igmp_over_ppp
		x                     CHOICES igmp
		x                     CHOICES host
		x                     CHOICES querier
		x                     CHOICES both
		x                     DEFAULT host]
		
		 Arguments:
		x   -mode
		x       The statistics that should be retrieved for IGMP hosts/queriers.
		    -port_handle
		        This parameter is used to specify the port from which
		        statistics will be gathered.
		n   -timeout
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -handle
		x       IGMP session handle for which the IGMP info is applied. The session handle is an emulated IGMP router object reference.
		x   -type
		x       The type of aggregated statistics to be gathered. Valid only for -mode aggregate.
		
		 Return Values:
		    $::SUCCESS | $::FAILURE
		    key:status                                                                value:$::SUCCESS | $::FAILURE
		    When status is failure, contains more information
		    key:log                                                                   value:When status is failure, contains more information
		    Sessions Total
		    key:<port_handle>.sessions_total                                          value:Sessions Total
		    Sessions Up
		    key:<port_handle>.sessions_up                                             value:Sessions Up
		    Sessions Down
		    key:<port_handle>.sessions_down                                           value:Sessions Down
		    Sessions Not Started
		    key:<port_handle>.sessions_notstarted                                     value:Sessions Not Started
		    Total Frames Tx
		    key:<port_handle>.igmp.aggregate.total_tx                                 value:Total Frames Tx
		    Total Frames Rx
		    key:<port_handle>.igmp.aggregate.total_rx                                 value:Total Frames Rx
		    Invalid Packets Rx
		    key:<port_handle>.igmp.aggregate.invalid_rx                               value:Invalid Packets Rx
		    v1 Membership Reports Tx
		    key:<port_handle>.igmp.aggregate.rprt_v1_tx                               value:v1 Membership Reports Tx
		    v1 Membership Reports Rx
		    key:<port_handle>.igmp.aggregate.rprt_v1_rx                               value:v1 Membership Reports Rx
		    v2 Membership Reports Tx
		    key:<port_handle>.igmp.aggregate.rprt_v2_tx                               value:v2 Membership Reports Tx
		    v2 Membership Reports Rx
		    key:<port_handle>.igmp.aggregate.rprt_v2_rx                               value:v2 Membership Reports Rx
		    v3 Membership Reports Tx
		    key:<port_handle>.igmp.aggregate.rprt_v3_tx                               value:v3 Membership Reports Tx
		    v3 Membership Reports Rx
		    key:<port_handle>.igmp.aggregate.rprt_v3_rx                               value:v3 Membership Reports Rx
		    General Queries Rx
		    key:<port_handle>.igmp.aggregate.gen_query_rx                             value:General Queries Rx
		    v2 Group-Specific Queries Rx
		    key:<port_handle>.igmp.aggregate.grp_query_rx                             value:v2 Group-Specific Queries Rx
		    v3 Group&Source Specific Queries Rx
		    key:<port_handle>.igmp.aggregate.v3_group_and_source_specific_queries_rx  value:v3 Group&Source Specific Queries Rx
		    v2 Leave Tx
		    key:<port_handle>.igmp.aggregate.leave_v2_tx                              value:v2 Leave Tx
		    v2 Leave Rx
		    key:<port_handle>.igmp.aggregate.leave_v2_rx                              value:v2 Leave Rx
		    v3 MODE_IS_INCLUDE Tx
		    key:<port_handle>.igmp.aggregate.v3_mode_include_tx                       value:v3 MODE_IS_INCLUDE Tx
		    v3 MODE_IS_INCLUDE Rx
		    key:<port_handle>.igmp.aggregate.v3_mode_include_rx                       value:v3 MODE_IS_INCLUDE Rx
		    v3 MODE_IS_EXCLUDE Tx
		    key:<port_handle>.igmp.aggregate.v3_mode_exclude_tx                       value:v3 MODE_IS_EXCLUDE Tx
		    v3 MODE_IS_EXCLUDE Rx
		    key:<port_handle>.igmp.aggregate.v3_mode_exclude_rx                       value:v3 MODE_IS_EXCLUDE Rx
		    v3 CHANGE_TO_INCLUDE_MODE Tx
		    key:<port_handle>.igmp.aggregate.v3_change_mode_include_tx                value:v3 CHANGE_TO_INCLUDE_MODE Tx
		    v3 CHANGE_TO_INCLUDE_MODE Rx
		    key:<port_handle>.igmp.aggregate.v3_change_mode_include_rx                value:v3 CHANGE_TO_INCLUDE_MODE Rx
		    v3 CHANGE_TO_EXCLUDE_MODE Tx
		    key:<port_handle>.igmp.aggregate.v3_change_mode_exclude_tx                value:v3 CHANGE_TO_EXCLUDE_MODE Tx
		    v3 CHANGE_TO_EXCLUDE_MODE Rx
		    key:<port_handle>.igmp.aggregate.v3_change_mode_exclude_rx                value:v3 CHANGE_TO_EXCLUDE_MODE Rx
		    v3 ALLOW_NEW_SOURCES Tx
		    key:<port_handle>.igmp.aggregate.v3_allow_new_source_tx                   value:v3 ALLOW_NEW_SOURCES Tx
		    v3 ALLOW_NEW_SOURCES Rx
		    key:<port_handle>.igmp.aggregate.v3_allow_new_source_rx                   value:v3 ALLOW_NEW_SOURCES Rx
		    v3 BLOCK_OLD_SOURCES Tx
		    key:<port_handle>.igmp.aggregate.v3_block_old_source_tx                   value:v3 BLOCK_OLD_SOURCES Tx
		    v3 BLOCK_OLD_SOURCES Rx
		    key:<port_handle>.igmp.aggregate.v3_block_old_source_rx                   value:v3 BLOCK_OLD_SOURCES Rx
		    Port Name
		    key:<port_handle>.igmp.aggregate.port_name                                value:Port Name
		    Pairs Joined
		    key:<port_handle>.igmp.aggregate.pair_joined                              value:Pairs Joined
		    Sessions Total
		    key:<port_handle>.sessions_total                                          value:Sessions Total
		    Sessions Up
		    key:<port_handle>.sessions_up                                             value:Sessions Up
		    Sessions Down
		    key:<port_handle>.sessions_down                                           value:Sessions Down
		    Sessions Not Started
		    key:<port_handle>.sessions_notstarted                                     value:Sessions Not Started
		    Invalid Packets Rx
		    key:<port_handle>.igmp.aggregate.invalid_rx                               value:Invalid Packets Rx
		    v1 General Queries Tx
		    key:<port_handle>.igmp.aggregate.gen_query_v1_tx                          value:v1 General Queries Tx
		    v2 General Queries Tx
		    key:<port_handle>.igmp.aggregate.gen_query_v2_tx                          value:v2 General Queries Tx
		    v3 General Queries Tx
		    key:<port_handle>.igmp.aggregate.gen_query_v3_tx                          value:v3 General Queries Tx
		    v2 Group Specific Queries Tx
		    key:<port_handle>.igmp.aggregate.grp_v2_query_tx                          value:v2 Group Specific Queries Tx
		    v3 Group Specific Queries Tx
		    key:<port_handle>.igmp.aggregate.grp_v3_query_tx                          value:v3 Group Specific Queries Tx
		    v3 Group and Source Specific Queries Tx
		    key:<port_handle>.igmp.aggregate.grp_src_v3_query_tx                      value:v3 Group and Source Specific Queries Tx
		    v1 Membership Reports Rx
		    key:<port_handle>.igmp.aggregate.rprt_v1_rx                               value:v1 Membership Reports Rx
		    v2 Membership Reports Rx
		    key:<port_handle>.igmp.aggregate.rprt_v2_rx                               value:v2 Membership Reports Rx
		    v3 Membership Reports Rx
		    key:<port_handle>.igmp.aggregate.rprt_v3_rx                               value:v3 Membership Reports Rx
		    Leave Rx
		    key:<port_handle>.igmp.aggregate.leave_rx                                 value:Leave Rx
		    Total Frames Tx
		    key:<port_handle>.igmp.aggregate.total_tx                                 value:Total Frames Tx
		    Total Frames Rx
		    key:<port_handle>.igmp.aggregate.total_rx                                 value:Total Frames Rx
		    General Queries Rx
		    key:<port_handle>.igmp.aggregate.gen_query_rx                             value:General Queries Rx
		    Group Specific Queries Rx
		    key:<port_handle>.igmp.aggregate.grp_query_rx                             value:Group Specific Queries Rx
		    Port Name
		    key:<port_handle>.igmp.aggregate.port_name                                value:Port Name
		
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
				'emulation_igmp_info', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
