# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def ixvm_config(self, mode, virtual_chassis, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    ixvm_config
		
		 Description:
		    This command can be used to create and delete IxVM virtual cards on an IxVM virtual chassis.
		    Please note that no operation can be performed if the cards is owned by any user. Ownership needs to be cleared before making any configuration changes.
		
		 Synopsis:
		    ixvm_config
		x       -mode                     CHOICES create
		x                                 CHOICES modify
		x                                 CHOICES delete
		x                                 CHOICES delete_all
		x       [-port_action             CHOICES add delete]
		x       -virtual_chassis          ANY
		x       [-card_no                 RANGE 1-32]
		x       [-port_no                 RANGE 1-9]
		x       [-management_ip           IP]
		x       [-keep_alive              RANGE 1-2147483647
		x                                 DEFAULT 300]
		x       [-virtual_interface_list  REGEXP ^\w[0-9]+$]
		x       [-virtual_interface_count RANGE 1-9]
		x       [-mtu                     RANGE 1500-9000
		x                                 DEFAULT 1500]
		x       [-promiscuous_mode        CHOICES 0 1
		x                                 DEFAULT 0]
		x       [-break_locks             CHOICES 0 1]
		x       [-rebuild_from_discovery  CHOICES 0 1]
		x       [-rediscover              CHOICES 0 1]
		x       [-max_wait_timer          RANGE 0-300
		x                                 DEFAULT 30]
		
		 Arguments:
		x   -mode
		x   -port_action
		x       Valid only for mode modify.
		x       When specified will allow adding/deleting port(s) to existing cards.
		x       Without specifying this parameter only existing port(s) can be modified.
		x       Please note that in this mode the existing port setting will not be modified (mtu, promiscuous. arguments supplied will only refer to the new ports being added).
		x   -virtual_chassis
		x       The ip or hostname of the virtual chassis. If a DNS name is provided, please make sure the name can be resolved using the dns provider from the ixnetwork_tcl_server machine.
		x   -card_no
		x       The number of the card affected by the chosen action. Valid only for mode modify or delete.
		x       If management_ip is provided the card_no is ignored.
		x   -port_no
		x       The number of the port affected by the chosen action. Valid only for mode modify or delete_port.
		x   -management_ip
		x       The management IPv4 address of the virtual card.
		x   -keep_alive
		x       The interval in seconds in which the keep alive is being sent to the virtual chassis.
		x   -virtual_interface_list
		x       The list of interface names that the virtual ports will use.<br/>
		x       This argument is only valid when mode is create or modify. For mode modify this argument is only valid when port_action is add.<br/>
		x       <br/><b>Example:</b> providing a list of eth1, eth2, eth3 will result in 3 virtual ports using eth1, eth2 and respectively eth3 virtual network interface names.
		x   -virtual_interface_count
		x       The number of ports to create. Using this argument the interface names are automatically calculated.<br/>
		x       Can be used instead of virtual_interface_list.<br/>
		x       This argument is only valid when mode is create or modify. For mode modify this argument is only valid when port_action is add.<br/>
		x       When both virtual_interface_list and virtual_interface_count are present, virtual_interface_list will take precedence over virtual_interface_count and virtual_interface_count will be ignored.<br/>
		x       Example:virtual_interface_count 5 will result in eth1 eth2 eth3 eth4 and eth5 as the 5 created virtual interfaces
		x   -mtu
		x       The MTU of the virtual port created.
		x       When a single value is provided, the value will be applied to all ports given by the virtual_interface_list.
		x       When providing a list, the list length needs to match the length of the one provided for virtual_interface_list.
		x   -promiscuous_mode
		x       This argument specifies if the virtual port will use promiscuous mode. For more info on this setting please consult IxVM documentation.
		x       When providing a single value, the value will be applied to all ports given by the virtual_interface_list.
		x       When providing a list, the list length needs to match the length of the one provided for virtual_interface_list.
		x   -break_locks
		x       This argument, if specified, will force clear ownership if the virtual card is in use (has ownership taken by any user).
		x       This will allow modify/delete operations to be performed forcefully. Please note that forcefully clearing port ownership
		x       will disconnect any existing user from the port causing current running script failure.
		x       Valid only when mode is modify, delete. delete_all.
		x       For mode create, the ownership cannot be cleared using break_locks since the ports do not exist in order to clear ownership.
		x       If the ports are in use by other IxOS Virtual chassis you need to first delete/modify them from that chassis (and here you can use
		x       the break_locks and then add them to the current chassis).
		x   -rebuild_from_discovery
		x       This argument, if specified, will rebuild entire topology using discovered appliances.
		x       This argument is only valid for mode create.
		x       When this argument is used only the following arguments are valid: virtual_chassis, rediscover andpromiscuous_mode (only one value
		x       can be specified in this mode and this value will apply to all ports from all discovered appliances).
		x       Any other arguments will be ignored.
		x   -rediscover
		x       If this argument is specified, a rediscovery will be done prior to rebuilding from discovered appliances.
		x       Valid only when mode is rebuild_from_discovery is used.
		x   -max_wait_timer
		x       The maximum number of seconds to wait for the IxVM card/port to become ready when adding a new card/port.
		x       Giving a 0 value will cause the command to return without waiting.
		x       This argument is only valid when mode is create or modify.
		
		 Return Values:
		    $::SUCCESS | $::FAILURE
		    key:status   value:$::SUCCESS | $::FAILURE
		    The ID of the card created from the virtual chassis.
		x   key:card_no  value:The ID of the card created from the virtual chassis.
		    If status is failure, detailed information provided.
		    key:log      value:If status is failure, detailed information provided.
		
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
				'ixvm_config', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
