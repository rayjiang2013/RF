# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def ptp_globals_config(self, mode, parent_handle, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    ptp_globals_config
		
		 Description:
		    Not supported in ixiangpf namespace.
		
		 Synopsis:
		    ptp_globals_config
		        -mode             CHOICES create add modify delete
		        -parent_handle    ANY
		        [-handle          ANY]
		        [-style           ANY]
		        [-max_outstanding RANGE 1-10000
		                          DEFAULT 20]
		        [-setup_rate      RANGE 1-20000
		                          DEFAULT 5]
		        [-teardown_rate   RANGE 1-20000
		                          DEFAULT 5]
		
		 Arguments:
		    -mode
		        Not supported in ixiangpf namespace.
		    -parent_handle
		        Not supported in ixiangpf namespace.
		    -handle
		        Not supported in ixiangpf namespace.
		    -style
		        Not supported in ixiangpf namespace.
		    -max_outstanding
		        Not supported in ixiangpf namespace.
		    -setup_rate
		        Not supported in ixiangpf namespace.
		    -teardown_rate
		        Not supported in ixiangpf namespace.
		
		 Return Values:
		
		 Examples:
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		
		 See Also:
		    External documentation on Tclx keyed lists
		
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
				'ptp_globals_config', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
