# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def emulation_isis_network_group_config(self, handle, mode, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    emulation_isis_network_group_config
		
		 Description:
		    This procedure creates/modifies/deletes ISIS route(s) to a particular
		    simulated ISIS router Ixia Interface. The user can configure the
		    properties of the ISIS routes.
		
		 Synopsis:
		    emulation_isis_network_group_config
		        -handle                              ANY
		        -mode                                CHOICES create modify delete
		        [-type                               CHOICES grid
		                                             CHOICES mesh
		                                             CHOICES custom
		                                             CHOICES ring
		                                             CHOICES hub-and-spoke
		                                             CHOICES tree
		                                             CHOICES ipv4-prefix
		                                             CHOICES ipv6-prefix
		                                             CHOICES fat-tree
		                                             CHOICES linear]
		x       [-protocol_name                      ALPHA]
		x       [-multiplier                         NUMERIC]
		x       [-connected_to_handle                ANY]
		x       [-enable_device                      CHOICES 0 1]
		        [-grid_row                           NUMERIC]
		        [-grid_col                           NUMERIC]
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
		        [-router_system_id                   ANY]
		x       [-enable_mt_ipv6                     CHOICES 0 1]
		x       [-ipv6_mt_metric                     NUMERIC]
		x       [-enable_wide_metric                 CHOICES 0 1]
		        [-router_te                          CHOICES 0 1]
		        [-router_id                          IPV4]
		x       [-node_active                        CHOICES 0 1]
		        [-admin_group                        RANGE 0-2147483647]
		x       [-metric_level                       RANGE 0-16777215
		x                                            DEFAULT 0]
		        [-max_bw                             NUMERIC]
		        [-max_resv_bw                        NUMERIC]
		        [-bw_priority0                       NUMERIC]
		        [-bw_priority1                       NUMERIC]
		        [-bw_priority2                       NUMERIC]
		        [-bw_priority3                       NUMERIC]
		        [-bw_priority4                       NUMERIC]
		        [-bw_priority5                       NUMERIC]
		        [-bw_priority6                       NUMERIC]
		        [-bw_priority7                       NUMERIC]
		x       [-from_ip                            IPV4]
		x       [-from_ip_step                       IPV4]
		x       [-to_ip                              IPV4]
		x       [-to_ip_step                         IPV4]
		x       [-enable_ip                          CHOICES 0 1]
		x       [-subnet_prefix_length               NUMERIC]
		x       [-from_ipv6                          IPV6]
		x       [-from_ipv6_step                     IPV6]
		x       [-to_ipv6                            IPV6]
		x       [-to_ipv6_step                       IPV6]
		x       [-enable_ipv6                        CHOICES 0 1]
		x       [-subnet_ipv6_prefix_length          NUMERIC]
		x       [-to_node_active                     CHOICES 0 1]
		x       [-to_node_link_metric                RANGE 0-16777215
		x                                            DEFAULT 0]
		x       [-from_node_active                   CHOICES 0 1]
		x       [-from_node_link_metric              RANGE 0-16777215
		x                                            DEFAULT 0]
		x       [-sim_topo_active                    CHOICES 0 1]
		x       [-sim_topo_enable_host_name          CHOICES 0 1]
		x       [-sim_topo_host_name                 REGEXP ^[0-9,a-f,A-F]+$]
		x       [-sim_topo_ipv4_node_route_count     NUMERIC]
		x       [-sim_topo_ipv6_node_route_count     NUMERIC]
		        [-grid_router_id                     IPV4]
		        [-grid_router_ip_pfx_len             RANGE 1-128
		                                             DEFAULT 24]
		        [-grid_stub_per_router               NUMERIC]
		x       [-grid_router_route_step             NUMERIC]
		x       [-grid_router_metric                 NUMERIC]
		x       [-grid_router_origin                 CHOICES stub external]
		x       [-grid_router_up_down_bit            CHOICES 0 1]
		x       [-grid_node_step                     NUMERIC]
		x       [-grid_router_active                 CHOICES 0 1]
		x       [-grid_ipv6_router_id                IPV6]
		x       [-grid_ipv6_router_ip_pfx_len        RANGE 1-128
		x                                            DEFAULT 24]
		x       [-grid_ipv6_stub_per_router          NUMERIC]
		x       [-grid_ipv6_router_route_step        NUMERIC]
		x       [-grid_ipv6_router_metric            NUMERIC]
		x       [-grid_ipv6_router_origin            CHOICES stub external]
		x       [-grid_ipv6_router_up_down_bit       CHOICES 0 1]
		x       [-grid_ipv6_node_step                NUMERIC]
		x       [-grid_ipv6_router_active            CHOICES 0 1]
		        [-ipv4_prefix_network_address        IPV4
		                                             DEFAULT 0.0.0.0]
		x       [-ipv4_prefix_number_of_addresses    NUMERIC
		x                                            DEFAULT 1]
		        [-ipv4_prefix_length                 RANGE 1-32
		                                             DEFAULT 24]
		        [-stub_metric                        NUMERIC]
		x       [-stub_router_origin                 CHOICES stub external]
		        [-stub_up_down_bit                   CHOICES 0 1]
		x       [-stub_router_active                 CHOICES 0 1]
		        [-ipv6_prefix_network_address        IPV6
		                                             DEFAULT 3000::0]
		x       [-ipv6_prefix_number_of_addresses    NUMERIC
		x                                            DEFAULT 1]
		        [-ipv6_prefix_length                 RANGE 1-128
		                                             DEFAULT 64]
		        [-external_metric                    NUMERIC]
		x       [-external_router_origin             CHOICES stub external]
		        [-external_up_down_bit               CHOICES 0 1]
		x       [-external_router_active             CHOICES 0 1]
		x       [-external_link_router_source        NUMERIC]
		x       [-external_link_router_destination   NUMERIC]
		x       [-external_link_network_group_handle ANY]
		x       [-link_type                          CHOICES pttopt broadcast]
		
		 Arguments:
		    -handle
		        This option represents the handle the user *must* pass to the
		        "emulation_isis_network_group_config" procedure. This option
		        specifies on which ISIS router to configure the ISIS topology.
		        The ISIS router handle(s) are returned by the procedure
		        "emulation_isis_config" when configuring ISIS routers on the
		        Ixia interface.
		    -mode
		        Mode of the procedure call.Valid choices are: create modify delete.
		    -type
		        The type of topology route to create.
		x   -protocol_name
		x   -multiplier
		x   -connected_to_handle
		x       Scenario element this connector is connecting to
		x   -enable_device
		x       enables/disables device.
		    -grid_row
		        Define number of rows in a grid.
		    -grid_col
		        Define number of columns in a grid.
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
		    -router_system_id
		        This is typically 6-octet long hex characters.
		x   -enable_mt_ipv6
		x   -ipv6_mt_metric
		x   -enable_wide_metric
		    -router_te
		        If true (1), enable traffic engineering.
		    -router_id
		        This is used for traffic engineering.
		x   -node_active
		x       Flag.
		    -admin_group
		        The administrative group associated with the link, expressed as the
		        decimal equivalent of 32-bit number. in 4-byte hex format.
		x   -metric_level
		x       The metric associated with the interface that the TE data is advertised
		x       on.
		    -max_bw
		        Maximum bandwidth that can be used on this link expressed as octets
		        per second.
		    -max_resv_bw
		        Maximum bandwidth that may be reserved on this link.This may be
		        greater than the actual max to allow a link to be oversubscribed.
		        It is expressed as octets per second.
		    -bw_priority0
		        If "-line_te" is 1, then this value indicates the amount of bandwidth,
		        in bytes per second, not yet reserved at the 0 priority level.This
		        value corresponds to the bandwidth that can be reserved with a setup
		        priority of 0.The value must be less than the linke_te_max_resv_bw
		        option.
		    -bw_priority1
		        If "-line_te" is 1, then this value indicates the amount of bandwidth,
		        in bytes per second, not yet reserved at the 1 priority level.This
		        value corresponds to the bandwidth that can be reserved with a setup
		        priority of 1.The value must be less than the linke_te_max_resv_bw
		        option.
		    -bw_priority2
		        If "-line_te" is 1, then this value indicates the amount of bandwidth,
		        in bytes per second, not yet reserved at the 1 priority level.This
		        value corresponds to the bandwidth that can be reserved with a setup
		        priority of 1.The value must be less than the linke_te_max_resv_bw
		        option.
		    -bw_priority3
		        If "-line_te" is 1, then this value indicates the amount of bandwidth,
		        in bytes per second, not yet reserved at the 1 priority level.This
		        value corresponds to the bandwidth that can be reserved with a setup
		        priority of 1.The value must be less than the linke_te_max_resv_bw
		        option.
		    -bw_priority4
		        If "-line_te" is 1, then this value indicates the amount of bandwidth,
		        in bytes per second, not yet reserved at the 1 priority level.This
		        value corresponds to the bandwidth that can be reserved with a setup
		        priority of 1.The value must be less than the linke_te_max_resv_bw
		        option.
		    -bw_priority5
		        If "-line_te" is 1, then this value indicates the amount of bandwidth,
		        in bytes per second, not yet reserved at the 1 priority level.This
		        value corresponds to the bandwidth that can be reserved with a setup
		        priority of 1.The value must be less than the linke_te_max_resv_bw
		        option.
		    -bw_priority6
		        If "-line_te" is 1, then this value indicates the amount of bandwidth,
		        in bytes per second, not yet reserved at the 1 priority level.This
		        value corresponds to the bandwidth that can be reserved with a setup
		        priority of 1.The value must be less than the linke_te_max_resv_bw
		        option.
		    -bw_priority7
		        If "-line_te" is 1, then this value indicates the amount of bandwidth,
		        in bytes per second, not yet reserved at the 1 priority level.This
		        value corresponds to the bandwidth that can be reserved with a setup
		        priority of 1.The value must be less than the linke_te_max_resv_bw
		        option.
		x   -from_ip
		x   -from_ip_step
		x   -to_ip
		x   -to_ip_step
		x   -enable_ip
		x       Enable IPv4
		x   -subnet_prefix_length
		x   -from_ipv6
		x   -from_ipv6_step
		x   -to_ipv6
		x   -to_ipv6_step
		x   -enable_ipv6
		x       Enable IPv4
		x   -subnet_ipv6_prefix_length
		x   -to_node_active
		x       Flag
		x       Active Simulated Interface Config for To-Node
		x   -to_node_link_metric
		x       Link Metric To-Node
		x   -from_node_active
		x       Flag
		x       Active Simulated Interface Config for From-Node
		x   -from_node_link_metric
		x       Link Metric From-Node
		x   -sim_topo_active
		x       Active Simulated Topology Config
		x   -sim_topo_enable_host_name
		x       Active Simulated Topology Config
		x   -sim_topo_host_name
		x       Simulated Topology Host Name
		x   -sim_topo_ipv4_node_route_count
		x       Simulated Topology Ipv4 Node Route Count
		x   -sim_topo_ipv6_node_route_count
		x       Simulated Topology Ipv6 Node Route Count
		    -grid_router_id
		        The IP address of the routes to be advertised per router in a grid.
		    -grid_router_ip_pfx_len
		        The number of bits in the prefixes to be advertised by the grid nodes.
		    -grid_stub_per_router
		        Define number of stub numbers per router in a grid.
		x   -grid_router_route_step
		x       The step for the route in the grid node route entry.
		x   -grid_router_metric
		x       The cost metric associated with the route advertised by the grid nodes.
		x   -grid_router_origin
		x       The origin of the routes advertised by the grid nodes.Choices are
		x       stub and external.
		x   -grid_router_up_down_bit
		x       This is the up down bit associated with the routes advertised by the
		x       grid nodes.If 1, the route will be distributed down.If 0, the
		x       route will be redistributed up.
		x   -grid_node_step
		x       grid ipv4 Node route step
		x   -grid_router_active
		x       Active ipv4 Node Route
		x   -grid_ipv6_router_id
		x       The IP address of the routes to be advertised per router in a grid.
		x   -grid_ipv6_router_ip_pfx_len
		x       The number of bits in the prefixes to be advertised by the grid nodes.
		x   -grid_ipv6_stub_per_router
		x       Define number of stub numbers per router in a grid.
		x   -grid_ipv6_router_route_step
		x       The step for the route in the grid node route entry.
		x   -grid_ipv6_router_metric
		x       The cost metric associated with the route advertised by the grid nodes.
		x   -grid_ipv6_router_origin
		x       The origin of the routes advertised by the grid nodes.Choices are
		x       stub and external.
		x   -grid_ipv6_router_up_down_bit
		x       This is the up down bit associated with the routes advertised by the
		x       grid nodes.If 1, the route will be distributed down.If 0, the
		x       route will be redistributed up.
		x   -grid_ipv6_node_step
		x       grid ipv4 Node route step
		x   -grid_ipv6_router_active
		x       Active ipv4 Node Route
		    -ipv4_prefix_network_address
		        The IP address of the first stub network route to be advertised.
		x   -ipv4_prefix_number_of_addresses
		x       For IxTclProtocol it sets the number of routes in a L3 Route Range.
		x       This paramter will be ignored if the -stub_router is also given.
		x       For IxTclNetwork it sets the the number of router in a L3 Route Range
		x       and will be advertised for stub network.
		    -ipv4_prefix_length
		        The number of bits in the prefixes to be advertised.
		    -stub_metric
		        The cost metric associated with the stub network route.
		x   -stub_router_origin
		x       The origin of the routes advertised by the grid nodes.Choices are
		x       stub and external.
		    -stub_up_down_bit
		        If 1, the route will be distributed down.If 0, the route will be
		        distributed up.
		x   -stub_router_active
		    -ipv6_prefix_network_address
		        The IPv6 address of the first external network route to be advertised.
		x   -ipv6_prefix_number_of_addresses
		x       For IxTclProtocol it sets the number of routes in a L3 Route Range.
		x       This paramter will be ignored if the -external_router is also given.
		x       For IxTclNetwork it sets the the number of router in a L3 Route Range
		x       and will be advertised for external network.
		    -ipv6_prefix_length
		        The number of bits in the prefixes to be advertised in a IPV6 external
		        network.
		    -external_metric
		        The cost metric associated with the external network route.
		x   -external_router_origin
		x       The origin of the routes advertised by the grid nodes.Choices are
		x       stub and external.
		    -external_up_down_bit
		        If 1, the route will be distributed down.If 0, the route will be
		        distributed up.
		x   -external_router_active
		x   -external_link_router_source
		x       Index of the originating node as defined in fromNetworkTopology
		x   -external_link_router_destination
		x       Index of the target node as defined in toNetworkTopology
		x   -external_link_network_group_handle
		x       Network Topology this link is pointing to
		x   -link_type
		x       Link Type
		
		 Return Values:
		    A list containing the network group protocol stack handles that were added by the command (if any).
		x   key:network_group_handle              value:A list containing the network group protocol stack handles that were added by the command (if any).
		    A list containing the simulated rbridge protocol stack handles that were added by the command (if any).
		x   key:simulated_rbridge_handle          value:A list containing the simulated rbridge protocol stack handles that were added by the command (if any).
		    A list containing the pseudo node protocol stack handles that were added by the command (if any).
		x   key:pseudo_node_handle                value:A list containing the pseudo node protocol stack handles that were added by the command (if any).
		    A list containing the simulated interface ipv4 protocol stack handles that were added by the command (if any).
		x   key:simulated_interface_ipv4_handle   value:A list containing the simulated interface ipv4 protocol stack handles that were added by the command (if any).
		    A list containing the simulated interface ipv6 protocol stack handles that were added by the command (if any).
		x   key:simulated_interface_ipv6_handle   value:A list containing the simulated interface ipv6 protocol stack handles that were added by the command (if any).
		    A list containing the to node protocol stack handles that were added by the command (if any).
		x   key:to_node_handle                    value:A list containing the to node protocol stack handles that were added by the command (if any).
		    A list containing the from node protocol stack handles that were added by the command (if any).
		x   key:from_node_handle                  value:A list containing the from node protocol stack handles that were added by the command (if any).
		    A list containing the simulated topology protocol stack handles that were added by the command (if any).
		x   key:simulated_topology_handle         value:A list containing the simulated topology protocol stack handles that were added by the command (if any).
		    A list containing the ipv4 prefix interface protocol stack handles that were added by the command (if any).
		x   key:ipv4_prefix_interface_handle      value:A list containing the ipv4 prefix interface protocol stack handles that were added by the command (if any).
		    A list containing the ipv6 prefix interface protocol stack handles that were added by the command (if any).
		x   key:ipv6_prefix_interface_handle      value:A list containing the ipv6 prefix interface protocol stack handles that were added by the command (if any).
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:simulated_rbridge_handles         value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:pseudo_node_handles               value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:simulated_interface_ipv4_handles  value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:simulated_interface_ipv6_handles  value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:to_node_handles                   value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:from_node_handle                  value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:simulated_topology_handles        value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:ipv4_prefix_interface_handles     value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:ipv6_prefix_interface_handles     value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		
		 Examples:
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  simulated_rbridge_handles, pseudo_node_handles, simulated_interface_ipv4_handles, simulated_interface_ipv6_handles, to_node_handles, from_node_handle, simulated_topology_handles, ipv4_prefix_interface_handles, ipv6_prefix_interface_handles
		
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
				'emulation_isis_network_group_config', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
