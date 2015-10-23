# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def emulation_dhcp_server_control(self, action, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    emulation_dhcp_server_control
		
		 Description:
		    This procedure controls DHCP Server actions.
		
		 Synopsis:
		    emulation_dhcp_server_control
		        [-dhcp_handle ANY]
		        [-port_handle ANY]
		n       [-args        ANY]
		        -action       CHOICES abort
		                      CHOICES abort_async
		                      CHOICES renew
		                      CHOICES reset
		                      CHOICES collect
		                      CHOICES restart_down
		                      CHOICES force_renew
		                      CHOICES reconfigure
		
		 Arguments:
		    -dhcp_handle
		        DHCP Server range to perform action for. This parameter is supported using
		        the following APIs: IxTclNetwork.
		    -port_handle
		        The port handle to perform action for. This parameter is supported using
		        the following APIs: IxTclNetwork.
		n   -args
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -action
		        This is a mandatory argument. Used to select the task to perform.
		        This parameter is supported using the following APIs: IxTclNetwork.
		        Valid choices are: abort abort_async renew reset collect restart_down force_renew reconfigure.
		
		 Return Values:
		    $::SUCCESS | $::FAILURE Status of procedure call.
		    key:status  value:$::SUCCESS | $::FAILURE Status of procedure call.
		    When status is failure, contains more information.
		    key:log     value:When status is failure, contains more information.
		
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
				'emulation_dhcp_server_control', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
