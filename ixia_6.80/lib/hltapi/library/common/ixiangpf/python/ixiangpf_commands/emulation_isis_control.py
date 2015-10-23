# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def emulation_isis_control(self, mode, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    emulation_isis_control
		
		 Description:
		    Stop, start or restart the protocol.
		
		 Synopsis:
		    emulation_isis_control
		        -mode                CHOICES start
		                             CHOICES stop
		                             CHOICES restart
		                             CHOICES abort
		                             CHOICES restart_down
		                             CHOICES stop_hello
		                             CHOICES resume_hello
		n       [-port_handle        ANY]
		        [-handle             ANY]
		n       [-advertise          ANY]
		n       [-flap_count         ANY]
		n       [-flap_down_time     ANY]
		n       [-flap_interval_time ANY]
		n       [-flap_routes        ANY]
		n       [-withdraw           ANY]
		
		 Arguments:
		    -mode
		n   -port_handle
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -handle
		        ISIS session handle where the ISIS control action is applied.
		n   -advertise
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -flap_count
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -flap_down_time
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -flap_interval_time
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -flap_routes
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -withdraw
		n       This argument defined by Cisco is not supported for NGPF implementation.
		
		 Return Values:
		    $::SUCCESS | $::FAILURE
		    key:status  value:$::SUCCESS | $::FAILURE
		    If status is failure, detailed information provided.
		    key:log     value:If status is failure, detailed information provided.
		
		 Examples:
		    See files starting with ISIS_ in the Samples subdirectory.  Also see some of the L3VPN, MPLS, and MVPN sample files for further examples of ISIS usage. See the ISIS example in Appendix A, "Example APIs," for one specific example usage.
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    Coded versus functional specification.
		
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
				'emulation_isis_control', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
