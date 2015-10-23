# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def l2tp_control(self, action, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    l2tp_control
		
		 Description:
		    Start, stop or restart the l2tpox sessions and tunnels.
		
		 Synopsis:
		    l2tp_control
		        -action  CHOICES connect
		                 CHOICES disconnect
		                 CHOICES abort
		                 CHOICES abort_async
		                 CHOICES retry
		        [-handle ANY]
		
		 Arguments:
		    -action
		        Action to be executed.
		        choices not supported:
		        reset- Aborts all L2TPoX sessions and resets the L2TP
		        emulation engine on the specified device. A session is
		        not notified of termination, and a Terminate Request
		        packet is not sent to the peers.
		        clear- Clears the status and statistics.
		        pause- Pauses all the sessions.
		        resume- Resumes all the sessions.
		    -handle
		        The port where the L2TPoX sessions are to be created.
		
		 Return Values:
		    $::SUCCESS | $::FAILURE
		    key:status  value:$::SUCCESS | $::FAILURE
		    If status is failure, detailed information provided.
		    key:log     value:If status is failure, detailed information provided.
		
		 Examples:
		    See files in the Samples/IxNetwork/L2TP subdirectory.
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    Coded versus functional specification.
		    1) Clear action has not been implemented yet.
		
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
				'l2tp_control', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
