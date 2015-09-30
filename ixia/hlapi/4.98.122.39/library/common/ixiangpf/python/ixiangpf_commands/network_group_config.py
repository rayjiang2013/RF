# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def network_group_config(self, protocol_handle, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    network_group_config
		
		 Description:
		
		 Synopsis:
		    network_group_config
		x       -protocol_handle                     ANY
		x       [-protocol_name                      ALPHA]
		x       [-multiplier                         NUMERIC]
		x       [-enable_device                      CHOICES 0 1]
		x       [-connected_to_handle                ANY]
		x       [-connected_to_handle_ipv4           ANY]
		x       [-connected_to_handle_ipv6           ANY]
		x       [-mode                               CHOICES create modify delete
		x                                            DEFAULT create]
		x       [-type                               CHOICES dual-stack-prefix
		x                                            CHOICES ipv4-prefix
		x                                            CHOICES ipv6-prefix
		x                                            CHOICES mac-pools
		x                                            CHOICES grid
		x                                            CHOICES mesh
		x                                            CHOICES custom
		x                                            CHOICES ring
		x                                            CHOICES hub-and-spoke
		x                                            CHOICES tree
		x                                            CHOICES fat-tree
		x                                            CHOICES linear]
		x       [-mac_pools_use_vlans                CHOICES 0 1]
		x       [-mac_pools_mac                      MAC]
		x       [-mac_pools_mac_step                 MAC]
		x       [-mac_pools_vlan_count               RANGE 0-2]
		x       [-mac_pools_vlan_tpid                CHOICES 0x8100
		x                                            CHOICES 0x88a8
		x                                            CHOICES 0x9100
		x                                            CHOICES 0x9200
		x                                            CHOICES 0x9300]
		x       [-mac_pools_vlan_priority            NUMERIC]
		x       [-mac_pools_vlan_priority_step       NUMERIC]
		x       [-mac_pools_vlan_id                  NUMERIC]
		x       [-mac_pools_vlan_id_step             NUMERIC]
		x       [-ipv6_prefix_network_address        IPV6]
		x       [-ipv6_prefix_network_address_step   IPV6]
		x       [-ipv6_prefix_length                 NUMERIC]
		x       [-ipv6_prefix_number_of_addresses    NUMERIC]
		x       [-ipv4_prefix_network_address        IP]
		x       [-ipv4_prefix_network_address_step   IP
		x                                            DEFAULT 0.0.0.1]
		x       [-ipv4_prefix_length                 NUMERIC]
		x       [-ipv4_prefix_number_of_addresses    NUMERIC]
		x       [-external_link_router_source        NUMERIC]
		x       [-external_link_router_destination   NUMERIC]
		x       [-external_link_network_group_handle ANY]
		        [-grid_col                           RANGE 0-10000
		                                             DEFAULT 1]
		        [-grid_row                           RANGE 0-10000
		                                             DEFAULT 1]
		x       [-grid_include_emulated_device       CHOICES 0 1]
		x       [-grid_link_multiplier               NUMERIC]
		x       [-mesh_number_of_nodes               NUMERIC]
		x       [-mesh_include_emulated_device       CHOICES 0 1]
		x       [-mesh_link_multiplier               NUMERIC]
		x       [-ring_number_of_nodes               NUMERIC]
		x       [-ring_include_emulated_device       CHOICES 0 1]
		x       [-ring_link_multiplier               NUMERIC]
		x       [-hub_spoke_number_of_first_level    NUMERIC]
		x       [-hub_spoke_number_of_second_level   NUMERIC]
		x       [-hub_spoke_enable_level_2           CHOICES 0 1]
		x       [-hub_spoke_link_multiplier          NUMERIC]
		x       [-tree_number_of_nodes               NUMERIC]
		x       [-tree_include_emulated_device       CHOICES 0 1]
		x       [-tree_use_tree_depth                CHOICES 0 1]
		x       [-tree_depth                         NUMERIC]
		x       [-tree_max_children_per_node         NUMERIC]
		x       [-tree_link_multiplier               NUMERIC]
		x       [-custom_link_multiplier             NUMERIC]
		x       [-custom_from_node_index             NUMERIC]
		x       [-custom_to_node_index               NUMERIC]
		x       [-fat_tree_link_multiplier           NUMERIC]
		x       [-fat_tree_level_count               NUMERIC]
		x       [-fat_tree_node_count                NUMERIC]
		x       [-linear_nodes                       NUMERIC]
		x       [-linear_link_multiplier             NUMERIC]
		
		 Arguments:
		x   -protocol_handle
		x       Network_group_config handle for modify and delete or a NGPF handle for create mode.
		x   -protocol_name
		x   -multiplier
		x   -enable_device
		x       enables/disables device.
		x   -connected_to_handle
		x       Scenario element this connector is connecting to
		x   -connected_to_handle_ipv4
		x       Scenario element IPV4_prefix connector is connecting to for dual-stack-prefix mode.
		x   -connected_to_handle_ipv6
		x       Scenario element IPV6_prefix connector is connecting to for dual-stack-prefix mode.
		x   -mode
		x       Mode of the procedure call.Valid options are:
		x       create
		x       modify
		x       delete
		x   -type
		x       The type of topology route to create.
		x   -mac_pools_use_vlans
		x       Flag to determine whether VLANs are enabled.
		x   -mac_pools_mac
		x       MAC addresses of the plugin
		x   -mac_pools_mac_step
		x       MAC step of the plugin
		x   -mac_pools_vlan_count
		x       Number of active VLANs. The maximum value is 2
		x   -mac_pools_vlan_tpid
		x       16-bit Tag Protocol Identifier (TPID) or EtherType in the VLAN tag.
		x   -mac_pools_vlan_priority
		x       3-bit user priority field in the VLAN tag.
		x   -mac_pools_vlan_priority_step
		x       3-bit user priority step field in the VLAN tag.
		x   -mac_pools_vlan_id
		x       12-bit VLAN ID in the VLAN tag.
		x   -mac_pools_vlan_id_step
		x       12-bit VLAN ID step in the VLAN tag.
		x   -ipv6_prefix_network_address
		x       Network addresses of the simulated IPv6 network
		x   -ipv6_prefix_network_address_step
		x       Network addresses step of the simulated IPv6 network
		x   -ipv6_prefix_length
		x   -ipv6_prefix_number_of_addresses
		x       NOT DEFINED
		x   -ipv4_prefix_network_address
		x       Network addresses of the simulated IPv4 network
		x   -ipv4_prefix_network_address_step
		x       Network addresses of the simulated IPv4 network
		x   -ipv4_prefix_length
		x   -ipv4_prefix_number_of_addresses
		x   -external_link_router_source
		x       Index of the originating node as defined in fromNetworkTopology
		x   -external_link_router_destination
		x       Index of the target node as defined in toNetworkTopology
		x   -external_link_network_group_handle
		x       Network Topology this link is pointing to
		    -grid_col
		        Defines number of columns in a grid.
		        This option is valid only when -type is grid, otherwise it
		        is ignored. This option is available with IxTclNetwork and IxTclProtocol API.
		    -grid_row
		        Defines number of rows in a grid.
		        This option is valid only when -type is grid, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		x   -grid_include_emulated_device
		x   -grid_link_multiplier
		x   -mesh_number_of_nodes
		x   -mesh_include_emulated_device
		x   -mesh_link_multiplier
		x   -ring_number_of_nodes
		x   -ring_include_emulated_device
		x   -ring_link_multiplier
		x   -hub_spoke_number_of_first_level
		x   -hub_spoke_number_of_second_level
		x   -hub_spoke_enable_level_2
		x   -hub_spoke_link_multiplier
		x   -tree_number_of_nodes
		x   -tree_include_emulated_device
		x   -tree_use_tree_depth
		x   -tree_depth
		x   -tree_max_children_per_node
		x   -tree_link_multiplier
		x   -custom_link_multiplier
		x       number of links between two nodes
		x   -custom_from_node_index
		x   -custom_to_node_index
		x   -fat_tree_link_multiplier
		x       number of links between two nodes
		x   -fat_tree_level_count
		x       Number of Levels
		x   -fat_tree_node_count
		x       Number of Nodes Per Level
		x   -linear_nodes
		x       number of nodes
		x   -linear_link_multiplier
		x       number of links between two nodes
		
		 Return Values:
		    A list containing the network group protocol stack handles that were added by the command (if any).
		x   key:network_group_handle              value:A list containing the network group protocol stack handles that were added by the command (if any).
		    A list containing the mac pools protocol stack handles that were added by the command (if any).
		x   key:mac_pools_handle                  value:A list containing the mac pools protocol stack handles that were added by the command (if any).
		    A list containing the ipv4 prefix pools protocol stack handles that were added by the command (if any).
		x   key:ipv4_prefix_pools_handle          value:A list containing the ipv4 prefix pools protocol stack handles that were added by the command (if any).
		    A list containing the ipv6 prefix pools protocol stack handles that were added by the command (if any).
		x   key:ipv6_prefix_pools_handle          value:A list containing the ipv6 prefix pools protocol stack handles that were added by the command (if any).
		    A list containing the simulated router protocol stack handles that were added by the command (if any).
		x   key:simulated_router_handle           value:A list containing the simulated router protocol stack handles that were added by the command (if any).
		    A list containing the external1 protocol stack handles that were added by the command (if any).
		x   key:external1_handle                  value:A list containing the external1 protocol stack handles that were added by the command (if any).
		    A list containing the external2 protocol stack handles that were added by the command (if any).
		x   key:external2_handle                  value:A list containing the external2 protocol stack handles that were added by the command (if any).
		    A list containing the nssa protocol stack handles that were added by the command (if any).
		x   key:nssa_handle                       value:A list containing the nssa protocol stack handles that were added by the command (if any).
		    A list containing the stub protocol stack handles that were added by the command (if any).
		x   key:stub_handle                       value:A list containing the stub protocol stack handles that were added by the command (if any).
		    A list containing the summary protocol stack handles that were added by the command (if any).
		x   key:summary_handle                    value:A list containing the summary protocol stack handles that were added by the command (if any).
		    A list containing the sim interface ipv4 config protocol stack handles that were added by the command (if any).
		x   key:sim_interface_ipv4_config_handle  value:A list containing the sim interface ipv4 config protocol stack handles that were added by the command (if any).
		    A list containing the v3 inter area protocol stack handles that were added by the command (if any).
		x   key:v3_inter_area_handle              value:A list containing the v3 inter area protocol stack handles that were added by the command (if any).
		    A list containing the v3 external protocol stack handles that were added by the command (if any).
		x   key:v3_external_handle                value:A list containing the v3 external protocol stack handles that were added by the command (if any).
		    A list containing the v3 intra area prefix protocol stack handles that were added by the command (if any).
		x   key:v3_intra_area_prefix_handle       value:A list containing the v3 intra area prefix protocol stack handles that were added by the command (if any).
		    A list containing the v3 nssa protocol stack handles that were added by the command (if any).
		x   key:v3_nssa_handle                    value:A list containing the v3 nssa protocol stack handles that were added by the command (if any).
		    A list containing the v3 inter area prefix protocol stack handles that were added by the command (if any).
		x   key:v3_inter_area_prefix_handle       value:A list containing the v3 inter area prefix protocol stack handles that were added by the command (if any).
		    A list containing the v3 linklsa protocol stack handles that were added by the command (if any).
		x   key:v3_linklsa_handle                 value:A list containing the v3 linklsa protocol stack handles that were added by the command (if any).
		    A list containing the ipv6 prefix interface protocol stack handles that were added by the command (if any).
		x   key:ipv6_prefix_interface_handle      value:A list containing the ipv6 prefix interface protocol stack handles that were added by the command (if any).
		    A list containing the simulated rbridge protocol stack handles that were added by the command (if any).
		x   key:simulated_rbridge_handle          value:A list containing the simulated rbridge protocol stack handles that were added by the command (if any).
		    A list containing the simulated interface ipv6 protocol stack handles that were added by the command (if any).
		x   key:simulated_interface_ipv6_handle   value:A list containing the simulated interface ipv6 protocol stack handles that were added by the command (if any).
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:v3_inter_area_handles             value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:v3_external_handles               value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:v3_intra_area_prefix_handles      value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:v3_nssa_handles                   value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:v3_inter_area_prefix_handles      value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:v3_linklsa_handles                value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		
		 Examples:
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  v3_inter_area_handles, v3_external_handles, v3_intra_area_prefix_handles, v3_nssa_handles, v3_inter_area_prefix_handles, v3_linklsa_handles
		
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
				'network_group_config', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
