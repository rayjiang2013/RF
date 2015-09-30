# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def emulation_multicast_source_config(self, mode, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    emulation_multicast_source_config
		
		 Description:
		    Configures multicast sources to be used by all multicast emulation tools
		    including PIM, IGMP, MLD.
		
		 Synopsis:
		    emulation_multicast_source_config
		        [-handle        ANY]
		        -mode           CHOICES create delete modify
		        [-ip_addr_start IP]
		        [-ip_addr_step  IP
		                        DEFAULT 0.0.0.1]
		n       [-ip_prefix_len ANY]
		        [-num_sources   NUMERIC
		                        DEFAULT 1]
		x       [-active        CHOICES 0 1]
		n       [-multiplier    ANY]
		
		 Arguments:
		    -handle
		        If the -mode is delete or modify, then this option is required to
		        specify the existing multicast source pool.
		    -mode
		        This option defines the action to be taken.
		    -ip_addr_start
		        First multicast source address in the group pool.
		    -ip_addr_step
		        Used to increment source address. For MLD protocol this
		        parameter is ignored.
		n   -ip_prefix_len
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -num_sources
		        Number of multicast sources in source pool.
		x   -active
		x       The active state of an individual item from the group pool.
		n   -multiplier
		n       This argument defined by Cisco is not supported for NGPF implementation.
		
		 Return Values:
		    A list containing the multicast source protocol stack handles that were added by the command (if any).
		x   key:multicast_source_handle  value:A list containing the multicast source protocol stack handles that were added by the command (if any).
		    $::SUCCESS | $::FAILURE
		    key:status                   value:$::SUCCESS | $::FAILURE
		    When status is failure, contains more information
		    key:log                      value:When status is failure, contains more information
		    The handle for the multicast source pool created
		    key:handle                   value:The handle for the multicast source pool created
		
		 Examples:
		    See the files starting with IGMPv1_, IGMPv2_, IGMPv3_, MLD_, MVPN_, and
		    PIM_ in the Samples subdirectory.
		    See the IGMP, MLD, MVPN, or PIM examples in Appendix A, "Example APIs," for
		    more specific example usage.
		
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
				'emulation_multicast_source_config', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
