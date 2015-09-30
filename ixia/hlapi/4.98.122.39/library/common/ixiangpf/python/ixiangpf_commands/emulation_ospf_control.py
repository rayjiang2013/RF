# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def emulation_ospf_control(self, mode, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    emulation_ospf_control
		
		 Description:
		    This procedure will Start, Stop, or Restart the protocol.
		
		 Synopsis:
		    emulation_ospf_control
		        [-port_handle        REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
		        [-handle             ANY]
		        -mode                CHOICES start
		                             CHOICES stop
		                             CHOICES restart
		                             CHOICES abort
		                             CHOICES restart_down
		                             CHOICES resume_hello
		                             CHOICES stop_hello
		                             CHOICES age_out_routes
		                             CHOICES readvertise_routes
		                             CHOICES advertise
		                             CHOICES withdraw
		                             CHOICES disconnect
		                             CHOICES reconnect
		x       [-age_out_percent    NUMERIC]
		n       [-advertise          ANY]
		n       [-advertise_lsa      ANY]
		n       [-flap_count         ANY]
		n       [-flap_down_time     ANY]
		n       [-flap_interval_time ANY]
		n       [-flap_lsa           ANY]
		n       [-flap_routes        ANY]
		n       [-withdraw           ANY]
		n       [-withdraw_lsa       ANY]
		
		 Arguments:
		    -port_handle
		        A list of ports on which to control the OSPF protocol. If this option
		        is not present, the port in the handle option will be applied.
		    -handle
		        This option represents the handle the user *must* pass to the
		        "emulation_ospf_control" procedure. This option specifies
		        on which OSPF session to control. If port_handle option is present,
		        the port_handle takes precedence over port in the router handle. The
		        OSPF router handle(s) is returned by the procedure
		    -mode
		        Tells which option will be performed on the OSPF protocol.
		        Valid options are:
		        restart
		        start
		        stop
		        abort
		        restart_down
		        resume_hello
		        stop_hello
		        age_out_routes
		        readvertise_routes
		        advertise
		        withdraw
		        disconnect
		        reconnect
		x   -age_out_percent
		x       The percentage of addresses that will be aged out.
		x       This argument is ignored when mode is not age_out_routes and *must* be specified
		x       in such circumstances.
		n   -advertise
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -advertise_lsa
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -flap_count
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -flap_down_time
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -flap_interval_time
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -flap_lsa
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -flap_routes
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -withdraw
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -withdraw_lsa
		n       This argument defined by Cisco is not supported for NGPF implementation.
		
		 Return Values:
		    $::SUCCESS or $::FAILURE
		    key:status  value:$::SUCCESS or $::FAILURE
		    If failure, will contain more information
		    key:log     value:If failure, will contain more information
		
		 Examples:
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    1) Coded versus functional specification.
		
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
				'emulation_ospf_control', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)