# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def ptp_over_mac_control(self, handle, action, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    ptp_over_mac_control
		
		 Description:
		    Perform control plane operations on an endpoint created
		    by a ::ixiangpf::ptp_over_mac_config command
		
		 Synopsis:
		    ptp_over_mac_control
		        -handle  ANY
		        -action  CHOICES abort
		                 CHOICES abort_async
		                 CHOICES start
		                 CHOICES connect
		                 CHOICES stop
		                 CHOICES disconnect
		
		 Arguments:
		    -handle
		        A handle returned via a ::<namespace>::ptp_over_mac_config
		        command. This is the object on which the action will take place.
		    -action
		        Action to be executed. Valid choices are:
		        abort- abort all sessions on the same port with the target
		        endpoint designated by -handle. The control is
		        returned when the operation is completed.
		        abort_async- abort all sessions on the same port with the target
		        endpoint designated by -handle. The control is
		        returned immediately. The operation is executed in the background.
		        start/connect - start and/or negotiate session for the target endpoint
		        designated by -handle. Start and connect offer the same functionality.
		        stop/disconnect - stop and/or release session for the target endpoint
		        designated by -handle. Stop and disconnect offer the same functionality.
		
		 Return Values:
		    $::SUCCESS | $::FAILURE
		    key:status  value:$::SUCCESS | $::FAILURE
		    When status is failure, contains more information
		    key:log     value:When status is failure, contains more information
		
		 Examples:
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    This command applies only to IxNetwork.
		
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
				'ptp_over_mac_control', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
