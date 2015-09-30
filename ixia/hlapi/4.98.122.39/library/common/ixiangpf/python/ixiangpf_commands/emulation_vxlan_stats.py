# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def emulation_vxlan_stats(self, mode, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    emulation_vxlan_stats
		
		 Description:
		    Controls VXLAN subscriber group activity.
		
		 Synopsis:
		    emulation_vxlan_stats
		        [-port_handle       ANY]
		        [-handle            ANY]
		        -mode               CHOICES aggregate_stats
		                            CHOICES clear_stats
		                            CHOICES session
		                            CHOICES vni
		                            CHOICES learned_info
		x       [-execution_timeout NUMERIC
		x                           DEFAULT 1800]
		
		 Arguments:
		    -port_handle
		        Specifies the port upon which emulation id configured.
		        This parameter is returned from emulation_dhcp_config proc.
		        Emulation must have been previously enabled on the specified port
		        via a call to emulation_dhcp_group_config proc.
		        When -version is ixnetwork, one of -port_handle or -handle parameters
		        should be provided.
		    -handle
		        Allows the user to optionally select the groups to which the
		        specified action is to be applied.
		        If this parameter is not specified, then the specified action is
		        applied to all groups configured on the port specified by
		        the -port_handle command. The handle is obtained from the keyed list returned
		        in the call to emulation_vxlan_group_config proc.
		        The port handle parameter must have been initialized and vxlan group
		        emulation must have been configured prior to calling this function.
		        For IxTclNetwork the statistics will be aggregated at port level (the
		        port on which this handle has been configured). The stats aggregate.<stat key>
		        will represent the aggregated port stats for the first port if multiple
		        handles are provided.
		    -mode
		        This is a mandatory argument. Used to select the task to perform.
		        This parameter is supported using the following APIs: IxTclNetwork.Valid choices are: clear collect.
		x   -execution_timeout
		x       This is the timeout for the function.
		x       The setting is in seconds.
		x       Setting this setting to 60 it will mean that the command must complete in under 60 seconds.
		x       If the command will last more than 60 seconds the command will be terminated by force.
		x       This flag can be used to prevent dead locks occuring in IxNetwork.
		
		 Return Values:
		    $::SUCCESS | $::FAILURE
		    key:status                                                    value:$::SUCCESS | $::FAILURE
		    When status is failure, contains more information
		    key:log                                                       value:When status is failure, contains more information
		    Port Name
		    key:<port_handle>.aggregate.port_name                         value:Port Name
		    Bytes sent. Supported with IxTclNetwork.
		    key:<port_handle>.aggregate.bytes_tx                          value:Bytes sent. Supported with IxTclNetwork.
		    Bytes received. Supported with IxTclNetwork.
		    key:<port_handle>.aggregate.bytes_rx                          value:Bytes received. Supported with IxTclNetwork.
		    Packets sent. Supported with IxTclNetwork.
		    key:<port_handle>.aggregate.packets_tx                        value:Packets sent. Supported with IxTclNetwork.
		    Packets received. Supported with IxTclNetwork.
		    key:<port_handle>.aggregate.packets_rx                        value:Packets received. Supported with IxTclNetwork.
		    Number of up sessions. Supported with IxTclNetwork.
		    key:<port_handle>.aggregate.sessions_up                       value:Number of up sessions. Supported with IxTclNetwork.
		    Number of down sessions. Supported with IxTclNetwork.
		    key:<port_handle>.aggregate.sessions_down                     value:Number of down sessions. Supported with IxTclNetwork.
		    Number of not started sessions. Supported with IxTclNetwork.
		    key:<port_handle>.aggregate.sessions_not_started              value:Number of not started sessions. Supported with IxTclNetwork.
		    Total number of sessions. Supported with IxTclNetwork.
		    key:<port_handle>.aggregate.sessions_total                    value:Total number of sessions. Supported with IxTclNetwork.
		    Bytes sent. Supported with IxTclNetwork.
		    key:session.<session ID>.bytes_tx                             value:Bytes sent. Supported with IxTclNetwork.
		    Bytes received. Supported with IxTclNetwork.
		    key:session.<session ID>.bytes_rx                             value:Bytes received. Supported with IxTclNetwork.
		    Packets sent. Supported with IxTclNetwork.
		    key:session.<session ID>.packets_tx                           value:Packets sent. Supported with IxTclNetwork.
		    Packets received. Supported with IxTclNetwork.
		    key:session.<session ID>.packets_rx                           value:Packets received. Supported with IxTclNetwork.
		    Topology name. Supported with IxTclNetwork.
		    key:session.<session ID>.topology                             value:Topology name. Supported with IxTclNetwork.
		    Device Group name. Supported with IxTclNetwork.
		    key:session.<session ID>.device_group                         value:Device Group name. Supported with IxTclNetwork.
		    VXLAN stack name. Supported with IxTclNetwork.
		    key:session.<session ID>.protocol                             value:VXLAN stack name. Supported with IxTclNetwork.
		    VXLAN device id. Supported with IxTclNetwork.
		    key:session.<session ID>.device_id                            value:VXLAN device id. Supported with IxTclNetwork.
		    VXLAN Network Identifier. Supported with IxTclNetwork.
		    key:session.<session ID>.vni                                  value:VXLAN Network Identifier. Supported with IxTclNetwork.
		    Session status. Supported with IxTclNetwork.
		    key:session.<session ID>.session_status                       value:Session status. Supported with IxTclNetwork.
		    Bytes sent. Supported with IxTclNetwork.
		    key:vni.<VNI ID>.<session ID>.bytes_tx                        value:Bytes sent. Supported with IxTclNetwork.
		    Bytes received. Supported with IxTclNetwork.
		    key:vni.<VNI ID>.<session ID>.bytes_rx                        value:Bytes received. Supported with IxTclNetwork.
		    Packets sent. Supported with IxTclNetwork.
		    key:vni.<VNI ID>.<session ID>.packets_tx                      value:Packets sent. Supported with IxTclNetwork.
		    Packets received. Supported with IxTclNetwork.
		    key:vni.<VNI ID>.<session ID>.packets_rx                      value:Packets received. Supported with IxTclNetwork.
		    Topology name. Supported with IxTclNetwork.
		    key:vni.<VNI ID>.<session ID>.topology                        value:Topology name. Supported with IxTclNetwork.
		    Device Group name. Supported with IxTclNetwork.
		    key:vni.<VNI ID>.<session ID>.device_group                    value:Device Group name. Supported with IxTclNetwork.
		    VXLAN Stack name. Supported with IxTclNetwork.
		    key:vni.<VNI ID>.<session ID>.protocol                        value:VXLAN Stack name. Supported with IxTclNetwork.
		    VXLAN Network Identifier. Supported with IxTclNetwork.
		    key:vni.<VNI ID>.<session ID>.vni                             value:VXLAN Network Identifier. Supported with IxTclNetwork.
		    Remote VM id. Supported with IxTclNetwork.
		    key:learned_info.<VTEP ID>.ipv4_learnedinfo.deviceid          value:Remote VM id. Supported with IxTclNetwork.
		    Remote VM MAC address. Supported with IxTclNetwork.
		    key:learned_info.<VTEP ID>.ipv4_learnedinfo.remote_vm_mac     value:Remote VM MAC address. Supported with IxTclNetwork.
		    Remote VTEP IPv4 address. Supported with IxTclNetwork.
		    key:learned_info.<VTEP ID>.ipv4_learnedinfo.remote_vtep_ipv4  value:Remote VTEP IPv4 address. Supported with IxTclNetwork.
		
		 Examples:
		
		 Sample Input:
		    .
		
		 Sample Output:
		    .
		
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
				'emulation_vxlan_stats', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
