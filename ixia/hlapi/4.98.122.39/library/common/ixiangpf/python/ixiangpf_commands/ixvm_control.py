# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def ixvm_control(self, action, virtual_chassis, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    ixvm_control
		
		 Description:
		    This command enables the user to control the cards on IxVM virtual chassis.
		
		 Synopsis:
		    ixvm_control
		x       -action           CHOICES connect disconnect 
		x       -virtual_chassis  ANY
		x       [-card_no         NUMERIC]
		x       [-management_ip   IP]
		x       [-break_locks     CHOICES 0 1]
		
		 Arguments:
		x   -action
		x   -virtual_chassis
		x       The ip or hostname of the virtual chassis. If a DNS name is provided, please make sure the name can be resolved using the dns provider from the ixnetwork_tcl_server machine.
		x   -card_no
		x       The number of the card affected by the chosen action. If management_ip is provided this argument is ignored.
		x   -management_ip
		x       The management IPv4 adress of the virtual card affected by the choosen action. Card_no can also be provided insted of management ip. If both are provided, management_ip will take precedence and card_no will be ignored.
		x   -break_locks
		x       This argument, if specified, will force clear ownership if the virtual card is in use (has ownership taken by any user).
		x       Please note that forcefully clearing port ownership will disconnect any existing user from the port causing current running script failure.
		
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
				'ixvm_control', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
