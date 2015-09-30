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
		        -handle                                            ANY
		        -mode                                              CHOICES create modify delete
		        [-type                                             CHOICES grid
		                                                           CHOICES mesh
		                                                           CHOICES custom
		                                                           CHOICES ring
		                                                           CHOICES hub-and-spoke
		                                                           CHOICES tree
		                                                           CHOICES ipv4-prefix
		                                                           CHOICES ipv6-prefix
		                                                           CHOICES fat-tree
		                                                           CHOICES linear]
		x       [-protocol_name                                    ALPHA]
		x       [-multiplier                                       NUMERIC]
		x       [-connected_to_handle                              ANY]
		x       [-return_detailed_handles                          CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-enable_device                                    CHOICES 0 1]
		        [-grid_row                                         NUMERIC]
		        [-grid_col                                         NUMERIC]
		x       [-grid_include_emulated_device                     CHOICES 0 1]
		x       [-grid_link_multiplier                             NUMERIC]
		x       [-mesh_number_of_nodes                             NUMERIC]
		x       [-mesh_include_emulated_device                     CHOICES 0 1]
		x       [-mesh_link_multiplier                             NUMERIC]
		x       [-ring_number_of_nodes                             NUMERIC]
		x       [-ring_include_emulated_device                     CHOICES 0 1]
		x       [-ring_link_multiplier                             NUMERIC]
		x       [-hub_spoke_number_of_first_level                  NUMERIC]
		x       [-hub_spoke_number_of_second_level                 NUMERIC]
		x       [-hub_spoke_enable_level_2                         CHOICES 0 1]
		x       [-hub_spoke_link_multiplier                        NUMERIC]
		x       [-tree_number_of_nodes                             NUMERIC]
		x       [-tree_include_emulated_device                     CHOICES 0 1]
		x       [-tree_use_tree_depth                              CHOICES 0 1]
		x       [-tree_depth                                       NUMERIC]
		x       [-tree_max_children_per_node                       NUMERIC]
		x       [-tree_link_multiplier                             NUMERIC]
		x       [-custom_link_multiplier                           NUMERIC]
		x       [-custom_from_node_index                           NUMERIC]
		x       [-custom_to_node_index                             NUMERIC]
		x       [-fat_tree_link_multiplier                         NUMERIC]
		x       [-fat_tree_level_count                             NUMERIC]
		x       [-fat_tree_node_count                              NUMERIC]
		x       [-linear_nodes                                     NUMERIC]
		x       [-linear_link_multiplier                           NUMERIC]
		        [-router_system_id                                 HEX8WITHSPACES]
		x       [-enable_mt_ipv6                                   CHOICES 0 1]
		x       [-ipv6_mt_metric                                   NUMERIC]
		x       [-enable_wide_metric                               CHOICES 0 1]
		        [-router_te                                        CHOICES 0 1]
		        [-router_id                                        IPV4]
		x       [-node_active                                      CHOICES 0 1]
		        [-admin_group                                      HEX]
		x       [-metric_level                                     RANGE 0-16777215
		x                                                          DEFAULT 0]
		        [-max_bw                                           REGEXP ^[0-9]+]
		        [-max_resv_bw                                      REGEXP ^[0-9]+$]
		        [-bw_priority0                                     REGEXP ^[0-9]+$]
		        [-bw_priority1                                     REGEXP ^[0-9]+$]
		        [-bw_priority2                                     REGEXP ^[0-9]+$]
		        [-bw_priority3                                     REGEXP ^[0-9]+$]
		        [-bw_priority4                                     REGEXP ^[0-9]+$]
		        [-bw_priority5                                     REGEXP ^[0-9]+$]
		        [-bw_priority6                                     REGEXP ^[0-9]+$]
		        [-bw_priority7                                     REGEXP ^[0-9]+$]
		x       [-from_ip                                          IPV4]
		x       [-from_ip_step                                     IPV4]
		x       [-to_ip                                            IPV4]
		x       [-to_ip_step                                       IPV4]
		x       [-enable_ip                                        CHOICES 0 1]
		x       [-subnet_prefix_length                             NUMERIC]
		x       [-from_ipv6                                        IPV6]
		x       [-from_ipv6_step                                   IPV6]
		x       [-to_ipv6                                          IPV6]
		x       [-to_ipv6_step                                     IPV6]
		x       [-enable_ipv6                                      CHOICES 0 1]
		x       [-subnet_ipv6_prefix_length                        NUMERIC]
		x       [-to_node_active                                   CHOICES 0 1]
		x       [-to_node_link_metric                              RANGE 0-16777215
		x                                                          DEFAULT 0]
		x       [-from_node_active                                 CHOICES 0 1]
		x       [-from_node_link_metric                            RANGE 0-16777215
		x                                                          DEFAULT 0]
		x       [-sim_topo_active                                  CHOICES 0 1]
		x       [-sim_topo_enable_host_name                        CHOICES 0 1]
		x       [-sim_topo_host_name                               REGEXP ^[0-9,a-f,A-F]+$]
		x       [-sim_topo_ipv4_node_route_count                   NUMERIC]
		x       [-sim_topo_ipv6_node_route_count                   NUMERIC]
		        [-grid_router_id                                   IPV4
		                                                           DEFAULT 201.1.0.0]
		        [-grid_router_ip_pfx_len                           RANGE 1-32
		                                                           DEFAULT 16]
		        [-grid_stub_per_router                             NUMERIC
		                                                           DEFAULT 1]
		x       [-grid_router_route_step                           NUMERIC]
		        [-grid_router_metric                               NUMERIC
		                                                           DEFAULT 0]
		        [-grid_router_origin                               CHOICES stub external
		                                                           DEFAULT stub]
		        [-grid_router_up_down_bit                          CHOICES 0 1
		                                                           DEFAULT 0]
		x       [-grid_node_step                                   NUMERIC]
		x       [-grid_router_active                               CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-grid_ipv6_router_id                              IPV6
		x                                                          DEFAULT 3000:0:1:1:0:0:0:0]
		x       [-grid_ipv6_router_ip_pfx_len                      RANGE 1-128
		x                                                          DEFAULT 64]
		x       [-grid_ipv6_stub_per_router                        NUMERIC
		x                                                          DEFAULT 1]
		x       [-grid_ipv6_router_route_step                      NUMERIC]
		x       [-grid_ipv6_router_metric                          NUMERIC
		x                                                          DEFAULT 0]
		x       [-grid_ipv6_router_origin                          CHOICES stub external
		x                                                          DEFAULT stub]
		x       [-grid_ipv6_router_up_down_bit                     CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-grid_ipv6_node_step                              NUMERIC]
		        [-ipv4_prefix_network_address                      IPV4
		                                                           DEFAULT 0.0.0.0]
		x       [-ipv4_prefix_number_of_addresses                  NUMERIC
		x                                                          DEFAULT 1]
		        [-ipv4_prefix_length                               RANGE 1-32
		                                                           DEFAULT 24]
		        [-stub_metric                                      NUMERIC]
		x       [-stub_router_origin                               CHOICES stub external]
		        [-stub_up_down_bit                                 CHOICES 0 1]
		x       [-stub_router_active                               CHOICES 0 1]
		        [-ipv6_prefix_network_address                      IPV6
		                                                           DEFAULT 3000::0]
		x       [-ipv6_prefix_number_of_addresses                  NUMERIC
		x                                                          DEFAULT 1]
		        [-ipv6_prefix_length                               RANGE 1-128
		                                                           DEFAULT 64]
		        [-external_metric                                  NUMERIC]
		x       [-external_router_origin                           CHOICES stub external]
		        [-external_up_down_bit                             CHOICES 0 1]
		x       [-external_router_active                           CHOICES 0 1]
		x       [-external_link_router_source                      NUMERIC]
		x       [-external_link_router_destination                 NUMERIC]
		x       [-external_link_network_group_handle               ANY]
		x       [-link_type                                        CHOICES pttopt broadcast]
		x       [-routerange_ipv4_r_flag                           CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-routerange_ipv4_n_flag                           CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-routerange_ipv4_p_flag                           CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-routerange_ipv4_e_flag                           CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-routerange_ipv4_v_flag                           CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-routerange_ipv4_l_flag                           CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-routerange_ipv4_configure_sid_index_label        CHOICES 0 1
		x                                                          DEFAULT 1]
		x       [-routerange_ipv4_sid_index_label                  RANGE 0-1048575
		x                                                          DEFAULT 1]
		x       [-routerange_ipv6_r_flag                           CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-routerange_ipv6_n_flag                           CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-routerange_ipv6_p_flag                           CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-routerange_ipv6_e_flag                           CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-routerange_ipv6_v_flag                           CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-routerange_ipv6_l_flag                           CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-routerange_ipv6_configure_sid_index_label        CHOICES 0 1
		x                                                          DEFAULT 1]
		x       [-routerange_ipv6_sid_index_label                  RANGE 0-1048575
		x                                                          DEFAULT 1]
		x       [-si_enable_adj_sid                                CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-si_adj_sid                                       RANGE 1-1048575
		x                                                          DEFAULT 9001]
		x       [-si_b_flag                                        CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-si_override_f_flag                               CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-si_f_flag                                        CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-si_v_flag                                        CHOICES 0 1
		x                                                          DEFAULT 1]
		x       [-si_l_flag                                        CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-si_s_flag                                        CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-si_weight                                        RANGE 0-255
		x                                                          DEFAULT 0]
		x       [-pseudo_node_enable_sr                            CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-pseudo_node_node_prefix                          IPV4
		x                                                          DEFAULT 1.1.1.1]
		x       [-pseudo_node_mask                                 RANGE 1-32
		x                                                          DEFAULT 32]
		x       [-pseudo_node_rtrcap_id                            IPV4
		x                                                          DEFAULT 1.1.1.1]
		x       [-pseudo_node_d_bit                                CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-pseudo_node_s_bit                                CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-pseudo_node_redistribution                       CHOICES up down
		x                                                          DEFAULT up]
		x       [-pseudo_node_r_flag                               CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-pseudo_node_n_flag                               CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-pseudo_node_p_flag                               CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-pseudo_node_e_flag                               CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-pseudo_node_v_flag                               CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-pseudo_node_l_flag                               CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-pseudo_node_ipv4_flag                            CHOICES 0 1
		x                                                          DEFAULT 1]
		x       [-pseudo_node_ipv6_flag                            CHOICES 0 1
		x                                                          DEFAULT 1]
		x       [-pseudo_node_configure_sid_index_label            CHOICES 0 1
		x                                                          DEFAULT 1]
		x       [-pseudo_node_sid_index_label                      RANGE 0-1048575
		x                                                          DEFAULT 0]
		x       [-pseudo_node_algorithm                            RANGE 0-255
		x                                                          DEFAULT 0]
		x       [-pseudo_node_srgb_range_count                     RANGE 1-5
		x                                                          DEFAULT 1]
		x       [-pseudo_node_start_sid_label                      RANGE 1-1048575
		x                                                          DEFAULT 16000]
		x       [-pseudo_node_sid_count                            RANGE 1-15000
		x                                                          DEFAULT 8000]
		x       [-pseudo_node_route_ipv4_r_flag                    CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-pseudo_node_route_ipv4_n_flag                    CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-pseudo_node_route_ipv4_p_flag                    CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-pseudo_node_route_ipv4_e_flag                    CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-pseudo_node_route_ipv4_v_flag                    CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-pseudo_node_route_ipv4_l_flag                    CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-pseudo_node_route_ipv4_configure_sid_index_label CHOICES 0 1
		x                                                          DEFAULT 1]
		x       [-pseudo_node_route_ipv4_sid_index_label           RANGE 0-1048575
		x                                                          DEFAULT 1]
		x       [-pseudo_node_route_ipv6_r_flag                    CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-pseudo_node_route_ipv6_n_flag                    CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-pseudo_node_route_ipv6_p_flag                    CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-pseudo_node_route_ipv6_e_flag                    CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-pseudo_node_route_ipv6_v_flag                    CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-pseudo_node_route_ipv6_l_flag                    CHOICES 0 1
		x                                                          DEFAULT 0]
		x       [-pseudo_node_route_ipv6_configure_sid_index_label CHOICES 0 1
		x                                                          DEFAULT 1]
		x       [-pseudo_node_route_ipv6_sid_index_label           RANGE 0-1048575
		x                                                          DEFAULT 1]
		x       [-grid_ipv6_router_active                          CHOICES 0 1
		x                                                          DEFAULT 0]
		
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
		x   -return_detailed_handles
		x       This argument determines if individual interface, session or router handles are returned by the current command.
		x       This applies only to the command on which it is specified.
		x       Setting this to 0 means that only NGPF-specific protocol stack handles will be returned. This will significantly
		x       decrease the size of command results and speed up script execution.
		x       The default is 0, meaning only protocol stack handles will be returned.
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
		        IPv4 type network prefix address corresponding to the pseudo node route.
		    -grid_router_ip_pfx_len
		        IPv4 prefix length for the corresponding IPv4 network address (pseudo node routes).
		    -grid_stub_per_router
		        Number of IPv4 network addresses (pseudo node routes).
		x   -grid_router_route_step
		x       The step for the route in the grid node route entry.
		    -grid_router_metric
		        Route metric corresponding to the IPv4 pseudo node routes
		    -grid_router_origin
		        The origin of the routes advertised by the grid nodes.Choices are stub and external (or Choices are internal or external).
		    -grid_router_up_down_bit
		        This is the up down bit associated with the routes advertised by the
		        grid nodes.If 1, the route will be distributed down.If 0, the
		        route will be redistributed up.
		x   -grid_node_step
		x       grid ipv4 Node route step
		x   -grid_router_active
		x       If set, then the IPv4 pseudo node routes will get advertised
		x   -grid_ipv6_router_id
		x       IPv6 type network prefix address corresponding to the pseudo node route.
		x   -grid_ipv6_router_ip_pfx_len
		x       IPv6 prefix length for the corresponding IPv6 network address (pseudo node routes)
		x   -grid_ipv6_stub_per_router
		x       Number of IPv6 network addresses (pseudo node routes)
		x   -grid_ipv6_router_route_step
		x       The step for the route in the grid node route entry.
		x   -grid_ipv6_router_metric
		x       Route metric corresponding to the IPv6 pseudo node routes
		x   -grid_ipv6_router_origin
		x       The origin of the routes advertised by the grid nodes.Choices are stub and external.
		x   -grid_ipv6_router_up_down_bit
		x       This is the up down bit associated with the routes advertised by the
		x       grid nodes.If 1, the route will be distributed down.If 0, the
		x       route will be redistributed up.
		x   -grid_ipv6_node_step
		x       grid ipv4 Node route step
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
		x   -routerange_ipv4_r_flag
		x       R flag for ISIS IPv4 route range (prefix pool)
		x   -routerange_ipv4_n_flag
		x       N flag for ISIS IPv4 route range (prefix pool)
		x   -routerange_ipv4_p_flag
		x       P flag for ISIS IPv4 route range (prefix pool)
		x   -routerange_ipv4_e_flag
		x       E flag for ISIS IPv4 route range (prefix pool)
		x   -routerange_ipv4_v_flag
		x       V flag (Value flag) for ISIS IPv4 route range (prefix pool)
		x   -routerange_ipv4_l_flag
		x       L flag for ISIS IPv4 route range (prefix pool)
		x   -routerange_ipv4_configure_sid_index_label
		x       If set, then all the prefixes in that prefix pool (IPv4 type) will take SID/ index from SID index label field and not from the SRGB range being configured under ISIS-L3 router, otherwise SID/ indexes will be assigned to the prefixes from the configured SRGB range
		x   -routerange_ipv4_sid_index_label
		x       If IPv4 configure SID index label has been enabled, then the IPv4 prefixes in the prefix pool will be assigned with the SID/ index from the SID index label field depending on the configured V flag
		x   -routerange_ipv6_r_flag
		x       R flag for ISIS IPv6 route range (prefix pool)
		x   -routerange_ipv6_n_flag
		x       N flag for ISIS IPv6 route range (prefix pool)
		x   -routerange_ipv6_p_flag
		x       P flag for ISIS IPv6 route range (prefix pool)
		x   -routerange_ipv6_e_flag
		x       E flag for ISIS IPv6 route range (prefix pool)
		x   -routerange_ipv6_v_flag
		x       V flag (Value flag) for ISIS IPv6 route range (prefix pool)
		x   -routerange_ipv6_l_flag
		x       L flag for ISIS IPv6 route range (prefix pool)
		x   -routerange_ipv6_configure_sid_index_label
		x       If set, then all the prefixes in that prefix pool (IPv6 type) will take SID/ index from SID index label field and not from the SRGB range being configured under ISIS-L3 router, otherwise SID/ indexes will be assigned to the prefixes from the configured SRGB range
		x   -routerange_ipv6_sid_index_label
		x       If IPv6 configure SID index label has been enabled, then the IPv6 prefixes in the prefix pool will be assigned with the SID/ index from the SID index label field depending on the configured V flag
		x   -si_enable_adj_sid
		x       Enables adjacent SID for SR enabled ISIS pseudo interface
		x   -si_adj_sid
		x       Adjacent SID for SR enabled ISIS pseudo interface
		x   -si_b_flag
		x       B flag for SR enabled ISIS pseudo interface
		x   -si_override_f_flag
		x       Override F flag option for SR enabled ISIS pseudo interface
		x   -si_f_flag
		x       F flag for SR enabled ISIS pseudo interface
		x   -si_v_flag
		x       Value flag for SR enabled ISIS pseudo interface
		x   -si_l_flag
		x       L flag for SR enabled ISIS pseudo interface
		x   -si_s_flag
		x       S flag for SR enabled ISIS pseudo interface
		x   -si_weight
		x       Weight value of the adjacent link for SR enabled ISIS pseudo interface
		x   -pseudo_node_enable_sr
		x       This will enable segment routing on an ISIS pseudo node (simulated router)
		x   -pseudo_node_node_prefix
		x       It uniquely identifies the SR enabled ISIS pseudo node
		x   -pseudo_node_mask
		x       Mask for node prefix corresponding to SR enabled ISIS pseudo node
		x   -pseudo_node_rtrcap_id
		x       Router capability identifier for SR enabled ISIS pseudo node
		x   -pseudo_node_d_bit
		x       D bit for SR enabled ISIS pseudo node
		x   -pseudo_node_s_bit
		x       S bit for SR enabled ISIS pseudo node
		x   -pseudo_node_redistribution
		x       Possible choices are UP or DOWN for SR enabled ISIS pseudo node
		x   -pseudo_node_r_flag
		x       Readvertisement flag for SR enabled ISIS pseudo node
		x   -pseudo_node_n_flag
		x       Node SID flag for SR enabled ISIS pseudo node
		x   -pseudo_node_p_flag
		x       PHP (penultimate hop popping) flag for SR enabled ISIS pseudo node
		x   -pseudo_node_e_flag
		x       E flag for SR enabled ISIS pseudo node
		x   -pseudo_node_v_flag
		x       Value flag for SR enabled ISIS pseudo node
		x   -pseudo_node_l_flag
		x       L flag for SR enabled ISIS pseudo node
		x   -pseudo_node_ipv4_flag
		x       I flag for SR enabled ISIS pseudo node
		x   -pseudo_node_ipv6_flag
		x       V flag for SR enabled ISIS pseudo node
		x   -pseudo_node_configure_sid_index_label
		x       If enabled, then the nodal SID for SR enabled ISIS pseudo node will not be taken from the SRGB range, rather it will be the value of SID index label
		x   -pseudo_node_sid_index_label
		x       This is the value which will be used to set the nodal SID of the SR enabled ISIS pseudo node if configure sid index label option has been enabled
		x   -pseudo_node_algorithm
		x       It specifies Algorithm value corresponding to a pseudo node and it can be like SPF
		x   -pseudo_node_srgb_range_count
		x       How many ranges the user wants to create in the SRGB range of SR enabled ISIS pseudo node. Max is 5
		x   -pseudo_node_start_sid_label
		x       Start SID in one SRGB range for SR enabled ISIS pseudo node
		x   -pseudo_node_sid_count
		x       Total count of SIDs in that SRGB range for SR enabled ISIS pseudo node
		x   -pseudo_node_route_ipv4_r_flag
		x       R flag corresponding to IPv4 pseudo node route
		x   -pseudo_node_route_ipv4_n_flag
		x       N flag corresponding to IPv4 pseudo node route
		x   -pseudo_node_route_ipv4_p_flag
		x       P flag corresponding to IPv4 pseudo node route
		x   -pseudo_node_route_ipv4_e_flag
		x       E flag corresponding to IPv4 pseudo node route
		x   -pseudo_node_route_ipv4_v_flag
		x       V flag corresponding to IPv4 pseudo node route
		x   -pseudo_node_route_ipv4_l_flag
		x       L flag corresponding to IPv4 pseudo node route
		x   -pseudo_node_route_ipv4_configure_sid_index_label
		x       If set, then all the pseudo node routes (IPv4 type) will take SID/ index from SID index label field and not from the SRGB range being configured under ISIS pseudo node, otherwise SID/ indexes will be assigned to them from the configured SRGB range
		x   -pseudo_node_route_ipv4_sid_index_label
		x       If pseudo node route IPv4 configure SID index label has been enabled, then the IPv4 prefixes corresponding to the pseudo node routes will be assigned with the SID/ index from the SID index label field depending on the configured V flag
		x   -pseudo_node_route_ipv6_r_flag
		x       R flag corresponding to IPv6 pseudo node route
		x   -pseudo_node_route_ipv6_n_flag
		x       N flag corresponding to IPv6 pseudo node route
		x   -pseudo_node_route_ipv6_p_flag
		x       P flag corresponding to IPv6 pseudo node route
		x   -pseudo_node_route_ipv6_e_flag
		x       E flag corresponding to IPv6 pseudo node route
		x   -pseudo_node_route_ipv6_v_flag
		x       V flag corresponding to IPv6 pseudo node route
		x   -pseudo_node_route_ipv6_l_flag
		x       L flag corresponding to IPv6 pseudo node route
		x   -pseudo_node_route_ipv6_configure_sid_index_label
		x       If set, then all the pseudo node routes (IPv6 type) will take SID/ index from SID index label field and not from the SRGB range being configured under ISIS pseudo node, otherwise SID/ indexes will be assigned to them from the configured SRGB range.
		x   -pseudo_node_route_ipv6_sid_index_label
		x       If pseudo node route IPv6 configure SID index label has been enabled, then the IPv6 prefixes pseudo node routes will be assigned with the SID/ index from the SID index label field depending on the configured V flag.
		x   -grid_ipv6_router_active
		x       If set, then the IPv6 pseudo node routes will get advertised
		
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
		    A list containing the pseudo node srgb range protocol stack handles that were added by the command (if any).
		x   key:pseudo_node_srgb_range_handle     value:A list containing the pseudo node srgb range protocol stack handles that were added by the command (if any).
		    A list containing the pseudo node ipv4 route protocol stack handles that were added by the command (if any).
		x   key:pseudo_node_ipv4_route_handle     value:A list containing the pseudo node ipv4 route protocol stack handles that were added by the command (if any).
		    A list containing the pseudo node ipv6 route protocol stack handles that were added by the command (if any).
		x   key:pseudo_node_ipv6_route_handle     value:A list containing the pseudo node ipv6 route protocol stack handles that were added by the command (if any).
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
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:pseudo_node_srgb_range_handles    value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:pseudo_node_ipv4_route_handles    value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:pseudo_node_ipv6_route_handles    value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		
		 Examples:
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  simulated_rbridge_handles, pseudo_node_handles, simulated_interface_ipv4_handles, simulated_interface_ipv6_handles, to_node_handles, from_node_handle, simulated_topology_handles, ipv4_prefix_interface_handles, ipv6_prefix_interface_handles, pseudo_node_srgb_range_handles, pseudo_node_ipv4_route_handles, pseudo_node_ipv6_route_handles
		
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
