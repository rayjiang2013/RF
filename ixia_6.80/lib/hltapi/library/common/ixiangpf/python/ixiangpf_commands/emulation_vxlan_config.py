# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def emulation_vxlan_config(self, handle, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    emulation_vxlan_config
		
		 Description:
		    Configures VXLAN emulation for the specified test port or handle.
		
		 Synopsis:
		    emulation_vxlan_config
		        [-mode                       CHOICES create modify delete
		                                     DEFAULT create]
		        -handle                      ANY
		x       [-create_ig                  CHOICES 0 1
		x                                    DEFAULT 0]
		x       [-protocol_name              ALPHA]
		x       [-mac_address_init           MAC]
		x       [-mac_address_step           MAC
		x                                    DEFAULT 0000.0000.0001]
		x       [-mac_mtu                    RANGE 500-9216
		x                                    DEFAULT 1500]
		        [-ip_num_sessions            RANGE 1-16000]
		x       [-sessions_per_vxlan         RANGE 1-1600
		x                                    DEFAULT 1]
		        [-vlan_id                    RANGE 0-4095
		                                     DEFAULT 4094]
		        [-vlan_id_step               RANGE 0-4095]
		x       [-vlan_user_priority         RANGE 0-7
		x                                    DEFAULT 0]
		        [-intf_ip_addr               IPV4
		                                     DEFAULT 100.1.0.2]
		        [-intf_ip_addr_step          IPV4
		                                     DEFAULT 0.0.0.0]
		x       [-intf_ip_prefix_length      RANGE 1-32
		x                                    DEFAULT 24]
		x       [-vni                        ANY]
		x       [-ipv4_multicast             ANY]
		x       [-enable_static_info         CHOICES 0 1]
		x       [-static_info_count          NUMERIC]
		x       [-remote_vtep_ipv4           ANY
		x                                    DEFAULT 0.0.0.0]
		x       [-suppress_arp               CHOICES 0 1]
		x       [-remote_vm_static_mac       ANY
		x                                    DEFAULT 00:00:00:00:00:00]
		x       [-remote_vm_static_ipv4      ANY
		x                                    DEFAULT 0.0.0.0]
		x       [-remote_info_active         CHOICES 0 1]
		x       [-ip_to_vxlan_multiplier     NUMERIC]
		x       [-start_rate_enabled         CHOICES 0 1]
		x       [-start_rate                 NUMERIC]
		x       [-start_rate_interval        NUMERIC]
		x       [-start_rate_scale_mode      CHOICES device_group port]
		x       [-stop_rate_enabled          CHOICES 0 1]
		x       [-stop_rate                  NUMERIC]
		x       [-stop_rate_interval         NUMERIC]
		x       [-stop_rate_scale_mode       CHOICES device_group port]
		x       [-udp_dest                   ANY]
		x       [-igmp_mode                  ANY]
		x       [-outer_ip_dest_mode         ANY]
		        [-gateway                    IP
		                                     DEFAULT 100.1.0.1]
		        [-gateway_step               IP
		                                     DEFAULT 0.0.0.0]
		x       [-ig_vlan_id                 RANGE 0-4095
		x                                    DEFAULT 4094]
		x       [-ig_vlan_id_step            RANGE 0-4095]
		x       [-ig_vlan_user_priority      RANGE 0-7
		x                                    DEFAULT 0]
		x       [-ig_intf_ip_addr            IPV4
		x                                    DEFAULT 102.1.0.2]
		x       [-ig_intf_ip_prefix_length   RANGE 1-32
		x                                    DEFAULT 24]
		x       [-ig_intf_ip_addr_step       IPV4
		x                                    DEFAULT 0.0.0.0]
		x       [-ig_gateway                 IP
		x                                    DEFAULT 102.1.0.1]
		x       [-ig_gateway_step            IP
		x                                    DEFAULT 0.0.0.0]
		x       [-ig_mac_address_init        MAC]
		x       [-ig_mac_address_step        MAC
		x                                    DEFAULT 0000.0000.0001]
		x       [-ig_mac_mtu                 RANGE 500-9216
		x                                    DEFAULT 1500]
		x       [-enable_resolve_gateway     CHOICES 0 1
		x                                    DEFAULT 1]
		x       [-manual_gateway_mac         MAC
		x                                    DEFAULT 0010.0000.0001]
		x       [-manual_gateway_mac_step    MAC
		x                                    DEFAULT 0000.0000.0000]
		x       [-ig_enable_resolve_gateway  CHOICES 0 1
		x                                    DEFAULT 1]
		x       [-ig_manual_gateway_mac      MAC]
		x       [-ig_manual_gateway_mac_step MAC
		x                                    DEFAULT 0000.0000.0000]
		
		 Arguments:
		    -mode
		        Action to take on the port specified the handle argument.
		    -handle
		        Specifies the port and group upon which emulation is configured.If
		        the -mode is "modify", -handle specifies the group upon which
		        emulation is configured, otherwise it specifies the session upon
		        which emulation is configured.
		        Valid for IxTclNetwork" (IxTclHal is not supported) .
		x   -create_ig
		x       If enabled creates behind the VXLAN device group a chained device group with IPv4 and Ethernet stacks emulating the connected VMs. If not enabled only the VXLAN device group will be created. Valid options:
		x       0 - Disabled
		x       1 - Enabled
		x       This option is valid only when -mode is create
		x       and -handle is an port handle.
		x       This option is available only when IxNetwork tcl API is used.
		x   -protocol_name
		x       This is the name of the protocol stack as it appears in the GUI.
		x   -mac_address_init
		x       The MAC address for the interface to be created.
		x       This option is available only if -mode is create
		x   -mac_address_step
		x       The incrementing step for the MAC address of the interface to be
		x       created.
		x       This option is available only if -mode is create.
		x       Valid only when using IxNetwork Tcl API.
		x   -mac_mtu
		x       The maximum transmission unit for the interfaces created with this range.
		x       The default value is 1500.
		x       This option is available only if -mode is create.
		x       Valid for IxTclNetwork.
		    -ip_num_sessions
		        Indicates the number of IP address clients emulated.
		        Valid for IxTclNetwork.
		x   -sessions_per_vxlan
		x       Indicates the multiplier per VXLAN entity for behind VM clients emulated.
		x       The default value is 1.
		x       Valid for IxTclNetwork.
		    -vlan_id
		        The first VLAN ID to be used for the outer VLAN tag.
		        This option is available only if -mode is create.
		        Valid for IxTclNetwork.
		    -vlan_id_step
		        The value to be added to the outer VLAN ID for each new assignment.
		        This option is available only if -mode is create.
		        Valid for IxTclNetwork.
		x   -vlan_user_priority
		x       The 802.1Q priority for the outer VLAN.
		x       This option is available only if -mode is create.
		x       Valid for IxTclNetwork.
		    -intf_ip_addr
		        The IP address of the simulated VTEP. If -ip_num_sessions is > 1, this IP address will increment by value specified in -intf_ip_addr_step.
		        This option is available only if -mode is create.
		        Valid for IxTclNetwork.
		    -intf_ip_addr_step
		        This value will be used for incrementing the IP address of
		        simulated VTEP if -count is > 1.
		        This option is available only if -mode is create.
		        Valid for IxTclNetwork.
		x   -intf_ip_prefix_length
		x       Defines the mask of the IP address used for the Ixia (-intf_ip_addr)
		x       and the DUT interface.The range of the value is 1-32.
		x       This option is available only if -mode is create.
		x       Valid for IxTclNetwork.
		x   -vni
		x       VXLAN Network Identifier.
		x   -ipv4_multicast
		x       IPv4 Multicast Address.
		x   -enable_static_info
		x       Enable Unicast Info.
		x   -static_info_count
		x       Unicast Info Count.
		x   -remote_vtep_ipv4
		x       Remote VTEP Ipv4.
		x   -suppress_arp
		x       Suppress Arp for each Remote VM defined. Valid options are: 0/1.
		x   -remote_vm_static_mac
		x       Remote VM MAC.
		x   -remote_vm_static_ipv4
		x       Remote VM Ipv4.
		x   -remote_info_active
		x       Activates the Unicast Info for each Remote VM. Valid options are: 0/1.
		x   -ip_to_vxlan_multiplier
		x       Configures the custom multiplier between stack elements (IPv4 and VXLAN stacks)
		x   -start_rate_enabled
		x       Number of times an action is triggered per time interval
		x       This option configures a global protocol parameter and is available only with /globals handle.
		x   -start_rate
		x       Number of times an action is triggered per time interval.
		x       This option configures a global protocol parameter and is available only with /globals handle.
		x   -start_rate_interval
		x       Time interval used to calculate the rate for triggering an action.
		x       This option configures a global protocol parameter and is available only with /globals handle.
		x   -start_rate_scale_mode
		x       Indicates whether the control is specified per port or per device group.
		x       This option configures a global protocol parameter and is available only with /globals handle.
		x   -stop_rate_enabled
		x       Number of times an action is triggered per time interval.
		x       This option configures a global protocol parameter and is available only with /globals handle.
		x   -stop_rate
		x       Number of times an action is triggered per time interval.
		x       This option configures a global protocol parameter and is available only with /globals handle.
		x   -stop_rate_interval
		x       Time interval used to calculate the rate for triggering an action.
		x       This option configures a global protocol parameter and is available only with /globals handle.
		x   -stop_rate_scale_mode
		x       Indicates whether the control is specified per port or per device group.
		x       This option configures a global protocol parameter and is available only with /globals handle.
		x   -udp_dest
		x       UDP Destination Port.
		x       This option configures a global protocol parameter and is available only with /globals handle.
		x   -igmp_mode
		x       Indicates the IGMP version used by VXLAN interfaces.
		x       This option configures a global protocol parameter and is available only with /globals handle.
		x   -outer_ip_dest_mode
		x       Indicates what is the outer destination IP in the generated fpga traffic.
		x       This option configures a global protocol parameter and is available only with /globals handle.
		    -gateway
		        The IP address of the Gateway for the Interface Interface.
		        This option is available only if -mode is create.
		        Valid for IxTclNetwork.
		    -gateway_step
		        This parameter is not valid on mode modify when IxTclProtocol is used.
		        What step will be use for incrementing the -gateway option.
		        This option is available only if -mode is create.
		        Valid for IxTclNetwork.
		x   -ig_vlan_id
		x       The first VLAN ID to be used for the outer VLAN tag.
		x       Argument configures the Ethernet stack of the chained device group/VMs.
		x       This option is available only if -mode is create.
		x       Valid for IxTclNetwork.
		x   -ig_vlan_id_step
		x       The value to be added to the outer VLAN ID for each new assignment. Argument configures the Ethernet stack of the chained device group/VMs.
		x       This option is available only if -mode is create.
		x       Valid for IxTclNetwork.
		x   -ig_vlan_user_priority
		x       The 802.1Q priority for the outer VLAN.Argument configures the Ethernet stack of the chained device group/VMs.
		x       This option is available only if -mode is create.
		x       Valid for IxTclNetwork.
		x   -ig_intf_ip_addr
		x       List of IP addresses that configure each of the traffic generation
		x       tool interfaces.If -sessions_per_vxlan is > 1,
		x       this IP address will increment by value specified
		x       in -ig_intf_ip_addr_step. Argument configures the IPv4 stack of the chained device group/VMs.
		x       This option is available only if -mode is create.
		x       Valid for IxTclNetwork.
		x   -ig_intf_ip_prefix_length
		x       Defines the mask of the IP address used for the Ixia (-intf_ip_addr)
		x       and the DUT interface.The range of the value is 1-32. Argument configures the IPv4 stack of the chained device group/VMs.
		x       This option is available only if -mode is create.
		x       Valid for IxTclNetwork.
		x   -ig_intf_ip_addr_step
		x       This value will be used for incrementing the IP address if -count is > 1.
		x       Argument configures the IPv4 stack of the chained device group/VMs.
		x       This option is available only if -mode is create.
		x       Valid for IxTclNetwork.
		x   -ig_gateway
		x       The IP address of the Gateway.
		x       Argument configures the IPv4 stack of the chained device group/VMs.
		x       This option is available only if -mode is create.
		x       Valid for IxTclNetwork.
		x   -ig_gateway_step
		x       What step will be use for incrementing the -ig_gateway option.
		x       Argument configures the IPv4 stack of the chained device group/VMs.
		x       This option is available only if -mode is create.
		x       Valid for IxTclNetwork.
		x   -ig_mac_address_init
		x       The MAC address for the interface to be created.
		x       Argument configures the Ethernet stack of the chained device group/VMs.
		x       This option is available only if -mode is create.
		x       Valid for IxTclNetwork.
		x   -ig_mac_address_step
		x       The incrementing step for the MAC address of the interface to be
		x       created.
		x       Argument configures the Ethernet stack of the chained device group/VMs.
		x       This option is available only if -mode is create.
		x       Valid for IxTclNetwork.
		x   -ig_mac_mtu
		x       The maximum transmission unit for the interfaces created with this range.
		x       The default value is 1500.
		x       Argument configures the Ethernet stack of the chained device group/VMs.
		x       This option is available only if -mode is create.
		x       Valid for IxTclNetwork.
		x   -enable_resolve_gateway
		x       Autoresolve gateway MAC addresses.
		x       This option is available only if -mode is create.
		x       Valid for IxTclNetwork.
		x   -manual_gateway_mac
		x       The manual gateway MAC addresses.
		x       This option has no effect unless enable_resolve_gateway is set to 0.
		x       This option is available only if -mode is create.
		x       Valid for IxTclNetwork.
		x   -manual_gateway_mac_step
		x       The step of the manual gateway MAC addresses.
		x       This option has no effect unless enable_resolve_gateway is set to 0.
		x       This option is available only if -mode is create.
		x       Valid for IxTclNetwork.
		x   -ig_enable_resolve_gateway
		x       Autoresolve gateway MAC addresses.
		x       Argument configures the IPv4 stack of the chained device group/VMs.
		x       This option is available only if -mode is create.
		x       Valid for IxTclNetwork.
		x   -ig_manual_gateway_mac
		x       The manual gateway MAC addresses.
		x       This option has no effect unless enable_resolve_gateway is set to 0.
		x       Argument configures the IPv4 stack of the chained device group/VMs.
		x       This option is available only if -mode is create.
		x       Valid for IxTclNetwork.
		x   -ig_manual_gateway_mac_step
		x       The step of the manual gateway MAC addresses.
		x       This option has no effect unless enable_resolve_gateway is set to 0.
		x       Argument configures the IPv4 stack of the chained device group/VMs.
		x       This option is available only if -mode is create.
		x       Valid for IxTclNetwork.
		
		 Return Values:
		    A list containing the vxlan static info protocol stack handles that were added by the command (if any).
		x   key:vxlan_static_info   value:A list containing the vxlan static info protocol stack handles that were added by the command (if any).
		    $::SUCCESS | $::FAILURE
		    key:status              value:$::SUCCESS | $::FAILURE
		    Error message if command returns {status 0}
		    key:log                 value:Error message if command returns {status 0}
		    Device handles of the VXLAN devices configured Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    key:handle              value:Device handles of the VXLAN devices configured Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    Stack handle of the VXLAN stack configured
		x   key:vxlan_handle        value:Stack handle of the VXLAN stack configured
		    Handle for the configured VXLAN device group
		x   key:dg_handle           value:Handle for the configured VXLAN device group
		    Ethernet handle for the VXLAN device group Ethernet stack
		x   key:ethernet_handle     value:Ethernet handle for the VXLAN device group Ethernet stack
		    IPv4 handle for the VXLAN device group IPv4 stack
		x   key:ipv4_handle         value:IPv4 handle for the VXLAN device group IPv4 stack
		    Ethernet handle for the chained device group Ethernet stack
		x   key:ig_ethernet_handle  value:Ethernet handle for the chained device group Ethernet stack
		    IPv4 handle for the chained device group IPv4 stack
		x   key:ig_ipv4_handle      value:IPv4 handle for the chained device group IPv4 stack
		    Handle for the chained device group
		x   key:ig_dg_handle        value:Handle for the chained device group
		
		 Examples:
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    When -handle is provided with the /globals value the arguments that configure global protocol
		    setting accept both multivalue handles and simple values.
		    When -handle is provided with a a protocol stack handle or a protocol session handle, the arguments
		    that configure global settings will only accept simple values. In this situation, these arguments will
		    configure only the settings of the parent device group or the ports associated with the parent topology.
		    If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  handle
		
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
				'emulation_vxlan_config', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
