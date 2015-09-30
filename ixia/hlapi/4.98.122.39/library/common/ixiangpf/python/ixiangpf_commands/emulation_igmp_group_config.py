# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def emulation_igmp_group_config(self, mode, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    emulation_igmp_group_config
		
		 Description:
		    This procedure will configure multicast group ranges for a simulated
		    IGMP Host. Note that IGMP is only supported on ports with CPUs.
		
		 Synopsis:
		    emulation_igmp_group_config
		        -mode                     CHOICES create
		                                  CHOICES delete
		                                  CHOICES modify
		                                  CHOICES clear_all
		                                  CHOICES enable
		                                  CHOICES disable
		x       [-return_detailed_handles CHOICES 0 1
		x                                 DEFAULT 0]
		n       [-g_enable_packing        ANY]
		x       [-g_filter_mode           CHOICES include exclude]
		n       [-g_max_groups_per_pkts   ANY]
		n       [-g_max_sources_per_group ANY]
		        [-group_pool_handle       ANY]
		        [-handle                  ANY]
		x       [-no_of_grp_ranges        NUMERIC
		x                                 DEFAULT 1]
		x       [-no_of_src_ranges        NUMERIC]
		n       [-no_write                ANY]
		x       [-reset                   FLAG]
		        [-session_handle          ANY]
		        [-source_pool_handle      ANY]
		
		 Arguments:
		    -mode
		        This option defines the action to be taken.
		x   -return_detailed_handles
		x       This argument determines if individual interface, session or router handles are returned by the current command.
		x       This applies only to the command on which it is specified.
		x       Setting this to 0 means that only NGPF-specific protocol stack handles will be returned. This will significantly
		x       decrease the size of command results and speed up script execution.
		x       The default is 0, meaning only protocol stack handles will be returned.
		n   -g_enable_packing
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -g_filter_mode
		x       Cofigure IGMPv3 Include Filter Mode. This is valid only for IxTclNetwork API.
		x       If this parameter is not provided, the filter_mode that was set at host level will be used instead.
		n   -g_max_groups_per_pkts
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -g_max_sources_per_group
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -group_pool_handle
		        Groups to be linked to the session in create mode. Parameter -group_pool_handle can be provided in two ways.
		        <p>
		        <ol>
		        <li> This parameter should be provided with a multicast group handle or a list of multicast group handles retrieved after calling emulation_multicast_group_config. Valid for both IxTclNetwork and IxTclProtocols.</li>
		        <li>This parameter should be provided with one element or a list of elements in the following format: (group IP)/(group IP step)/(group count). Eg: 50.0.1.2/0.0.0.1/3. Valid for IxTclNetwork only. </li>
		        </ol>
		        </p>
		    -handle
		        Group membership handle that associates group pools with an IGMP
		        session. If modify mode, membership handle must be used in conjunction
		        with session handle to identify the multicast group pools.
		x   -no_of_grp_ranges
		x       Number of igmp multicast groups in group pool.
		x   -no_of_src_ranges
		x       Number of igmp unicast sources in source pool.
		n   -no_write
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -reset
		x       If the -mode is create and this option exists, then any existing
		x       group ranges will be deleted before creating new ones.
		    -session_handle
		        IGMP Host handle on which to configure the IGMP group ranges. There are two ways of providing this parameter.<br/>
		        1. Providing the IP address of the protocol interface that is associated with an IGMP host
		        on which to configure the IGMP group ranges. Valid for IxTclNetwork only.<br/>
		        2. Providing the IGMP host handle returned by ::ixiangpf::emulation_igmp_config. Valid for both IxTclNetwork and IxTclProtocols.
		    -source_pool_handle
		        Associate source pool(s) with group(s). Specify one or more source pool
		        handle(s) for (S,G) entries. None for (*,G) entries. There are two ways of providing -source_pool_handle. <br/>
		        1. This parameter should be provided with a multicast source handle or a list of multicast source handles
		        retrieved after callingemulation_multicast_source_config. Valid for both IxTclNetwork and IxTclProtocols.<br/>
		        2. This parameter should be provided with one element or a list of elements in the following
		        format: (source group IP)/(source group IP step)/(source group count) . <br/> Eg: 20.0.0.2/0.0.0.1/3. Valid for IxTclNetwork only.
		
		 Return Values:
		    A list containing the igmp group protocol stack handles that were added by the command (if any).
		x   key:igmp_group_handle   value:A list containing the igmp group protocol stack handles that were added by the command (if any).
		    A list containing the igmp source protocol stack handles that were added by the command (if any).
		x   key:igmp_source_handle  value:A list containing the igmp source protocol stack handles that were added by the command (if any).
		    $::SUCCESS | $::FAILURE
		    key:status              value:$::SUCCESS | $::FAILURE
		    If status is failure, detailed information provided.
		    key:log                 value:If status is failure, detailed information provided.
		    The handle for the group member created Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    key:handle              value:The handle for the group member created Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    The handle for the source created (IGMPv3), only for IxTclNetwork Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    key:source_handle       value:The handle for the source created (IGMPv3), only for IxTclNetwork Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    The group_pool_handle used for creating the group member
		    key:group_pool_handle   value:The group_pool_handle used for creating the group member
		    The source_pool_handles used for creating the group member
		    key:source_pool_handle  value:The source_pool_handles used for creating the group member
		
		 Examples:
		    See files starting with IGMPv1_, IGMPv2_, or IGMPv3_ in the Samples subdirectory. See the IGMP example in Appendix A, "Examples APIs," for one specific example usage.
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  handle, source_handle
		
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
				'emulation_igmp_group_config', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
