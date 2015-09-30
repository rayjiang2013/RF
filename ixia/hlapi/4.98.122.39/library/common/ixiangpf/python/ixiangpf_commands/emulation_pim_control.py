# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def emulation_pim_control(self, mode, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    emulation_pim_control
		
		 Description:
		    This procedure controls the PIM simulation session.
		
		 Synopsis:
		    emulation_pim_control
		        -mode                 CHOICES stop
		                              CHOICES start
		                              CHOICES restart
		                              CHOICES stop_hello
		                              CHOICES resume_hello
		                              CHOICES send_bsm
		                              CHOICES stop_bsm
		                              CHOICES resume_bsm
		                              CHOICES join
		                              CHOICES leave
		                              CHOICES stop_periodic_join
		                              CHOICES resume_periodic_join
		                              CHOICES abort
		        [-port_handle         REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
		        [-handle              ANY]
		x       [-flap                CHOICES 0 1]
		x       [-flap_interval       RANGE 1-65535]
		n       [-group_member_handle ANY]
		
		 Arguments:
		    -mode
		        This option defines the action to be taken.Note:join and
		        prune options are not supported. Valid options are:
		        stop
		        start
		        restart.
		    -port_handle
		        The port on which to perform action.
		    -handle
		        PIM-SM session handle.It is returned by emulation_pim_config call.
		x   -flap
		x       If true (1), enables simulated flapping of this joins/prune.
		x       (DEFAULT = false)
		x   -flap_interval
		x       If flap is true, this is the amount of time, in seconds, between
		x       simulated flap events.
		n   -group_member_handle
		n       This argument defined by Cisco is not supported for NGPF implementation.
		
		 Return Values:
		    $::SUCCESS | $::FAILURE
		    key:status  value:$::SUCCESS | $::FAILURE
		
		 Examples:
		    See files starting with PIM_ in the Samples subdirectory.  Also see some of the MVPN sample files for further examples of the PIM usage.
		    See the PIM example in Appendix A, "Example APIs," for one specific example usage.
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    1) MVPN parameters are not supported with IxTclNetwork API (new API).
		
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
				'emulation_pim_control', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
