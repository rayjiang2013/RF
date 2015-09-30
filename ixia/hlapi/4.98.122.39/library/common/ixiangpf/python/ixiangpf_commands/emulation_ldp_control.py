# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def emulation_ldp_control(self, mode, handle, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    emulation_ldp_control
		
		 Description:
		    Stop, start or restart the protocol.
		
		 Synopsis:
		    emulation_ldp_control
		        -mode                CHOICES restart
		                             CHOICES start
		                             CHOICES stop
		                             CHOICES restart_down
		                             CHOICES abort
		                             CHOICES resume_hello
		                             CHOICES stop_hello
		                             CHOICES resume_keepalive
		                             CHOICES stop_keepalive
		n       [-port_handle        ANY]
		        -handle              ANY
		n       [-advertise          ANY]
		n       [-flap_count         ANY]
		n       [-flap_down_time     ANY]
		n       [-flap_interval_time ANY]
		n       [-flap_routes        ANY]
		n       [-withdraw           ANY]
		
		 Arguments:
		    -mode
		        What is being done to the protocol.Valid choices are:
		        restart - Restart the protocol.
		        start- Start the protocol.
		        stop- Stop the protocol.
		        restart_down - Restarts the down sessions.
		        abort- Aborts the protocol.
		        resume_hello - Resumes hello message for the given LDP connected interface.
		        stop_hello - Stops hello message for the given LDP connected Interface.
		        resume_keepalive - Resumes Keepalive message for the given LDP connected interface.
		        stop_keepalive- Stop Keepalive message for the given LDP connected interface.
		n   -port_handle
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -handle
		        The LDP session handle to act upon.
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
		    See files starting with LDP_ in the Samples subdirectory.  Also see some of the L2VPN, L3VPN, MPLS, and MVPN sample files for further examples of the LDP usage.
		    See the LDP example in Appendix A, "Example APIs," for one specific example usage.
		
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
				'emulation_ldp_control', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
