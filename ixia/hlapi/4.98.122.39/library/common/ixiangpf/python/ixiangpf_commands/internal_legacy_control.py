# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def internal_legacy_control(self, action, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    internal_legacy_control
		
		 Description:
		    Method used to compress the overlays in the config.
		
		 Synopsis:
		    internal_legacy_control
		x       -action     CHOICES start_automatic_overlay_compression
		x                   CHOICES save_interfaces
		x                   CHOICES load_interfaces
		x       [-threshold NUMERIC
		x                   DEFAULT 100]
		x       [-file_path ANY]
		
		 Arguments:
		x   -action
		x   -threshold
		x       Used on automatic compression - is the number of commands per topology after what we start compressing the overlays on the given topology.
		x   -file_path
		x       When saving make sure that you provide a valid file path where IxNetwork.exe process has write access.
		
		 Return Values:
		
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
				'internal_legacy_control', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
