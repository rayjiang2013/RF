# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def ixvm_info(self, virtual_chassis, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    ixvm_info
		
		 Description:
		    This command enables user to retrive all card and port data from an IxVM virtual chassis.
		
		 Synopsis:
		    ixvm_info
		x       [-mode            CHOICES current_configuration
		x                         CHOICES discovered_appliances
		x                         DEFAULT current_configuration]
		x       -virtual_chassis  ANY
		x       [-rediscover      CHOICES 0 1]
		
		 Arguments:
		x   -mode
		x   -virtual_chassis
		x       The ip or hostname of the virtual chassis. If a DNS name is provided, please make sure the name can be resolved using the dns provider from the ixnetwork_tcl_server machine.
		x   -rediscover
		x       If this argument is specified, a rediscovery will be done prior to returning discovered appliances.
		x       Valid only when mode is discovered_appliances.
		
		 Return Values:
		    $::SUCCESS | $::FAILURE
		    key:status  value:$::SUCCESS | $::FAILURE
		    If status is failure, detailed information provided.
		    key:log     value:If status is failure, detailed information provided.
		
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
				'ixvm_info', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
