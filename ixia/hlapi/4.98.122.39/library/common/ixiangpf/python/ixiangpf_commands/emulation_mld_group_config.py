# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def emulation_mld_group_config(self, mode, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    emulation_mld_group_config
		
		 Description:
		    Configures multicast groups added to an MLD session.  This procedure
		    utilizes the common emulation_multicast_group_config and
		    emulation_multicast_source_config procedures.
		
		 Synopsis:
		    emulation_mld_group_config
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
		x       [-filter_mode             CHOICES include exclude
		x                                 DEFAULT include]
		
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
		x       Cofigure MLDv2 Include Filter Mode. This is valid only for IxTclNetwork API.
		x       If this parameter is not provided, the filter_mode that was set at host level will be used instead.
		n   -g_max_groups_per_pkts
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -g_max_sources_per_group
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -group_pool_handle
		        Groups to be linked to the session in create mode. The group pool
		        must be added beforehand through procedure
		        emulation_multicast_group_config.
		    -handle
		        Group membership handle that associates group pools with an MLD
		        session. If modify mode, membership handle must be used to identify the multicast group pools.
		x   -no_of_grp_ranges
		x       Number of MLD multicast groups in group pool.
		x   -no_of_src_ranges
		x       Number of MLD unicast sources in source pool.
		n   -no_write
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -reset
		x       If the -mode is create and this option exists, then any existing group ranges (for the specified -session_handle mld host) will
		x       be deleted before creating new ones. This option is available
		x       only for IxNetwork Tcl API.
		    -session_handle
		        MLD Host handle on which to configure the MLD group ranges.
		    -source_pool_handle
		        Associate source pool(s) with group(s). Specify one or more source pool
		        handle(s) for (S,G) entries. None for (*,G) entries. The source pool(s)
		        must be added beforehand through procedure
		        emulation_multicast_source_config.
		x   -filter_mode
		x       Configure MLDv2 Include Filter Mode.
		
		 Return Values:
		    A list containing the mld source protocol stack handles that were added by the command (if any).
		x   key:mld_source_handle  value:A list containing the mld source protocol stack handles that were added by the command (if any).
		    $::SUCCESS | $::FAILURE
		    key:status             value:$::SUCCESS | $::FAILURE
		    When status is failure, contains more info
		    key:log                value:When status is failure, contains more info
		    The group member handle Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    key:handle             value:The group member handle Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    The group pool handle
		    key:mld_group_handle   value:The group pool handle
		    Source pool handles list Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    key:source_handle      value:Source pool handles list Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		
		 Examples:
		    See files starting with MLD_ in the Samples subdirectory.
		    See the MLD example in Appendix A, "Example APIs," for one specific example usage.
		
		 Sample Input:
		
		 Sample Output:
		    {status $::SUCCESS} {mld_groups {routeRange1 routeRange2}}
		
		 Notes:
		    1) Not yet coded to functional specification.
		    2) MLD implementation using IxTclNetwork is NOT SUPPORTED in HLTAPI 3.20.
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
				'emulation_mld_group_config', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
