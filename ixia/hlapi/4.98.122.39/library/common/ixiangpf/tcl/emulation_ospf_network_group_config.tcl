##Procedure Header
# Name:
#    ::ixiangpf::emulation_ospf_network_group_config
#
# Description:
#    This procedure will add OSPF route(s) to a particular simulated OSPF
#    router Ixia Interface. The user can configure the properties of the
#    OSPF routes.
#
# Synopsis:
#    ::ixiangpf::emulation_ospf_network_group_config
#        -handle                                  ANY
#        [-mode                                   CHOICES create modify delete
#                                                 DEFAULT create]
#        [-type                                   CHOICES grid
#                                                 CHOICES mesh
#                                                 CHOICES custom
#                                                 CHOICES ring
#                                                 CHOICES hub-and-spoke
#                                                 CHOICES tree
#                                                 CHOICES ipv4-prefix
#                                                 CHOICES fat-tree
#                                                 CHOICES linear
#                                                 CHOICES ipv6-prefix]
#x       [-protocol_name                          ALPHA]
#x       [-multiplier                             NUMERIC]
#x       [-enable_device                          CHOICES 0 1]
#        [-grid_col                               RANGE 2-10000
#                                                 DEFAULT 2]
#        [-grid_row                               RANGE 2-10000
#                                                 DEFAULT 2]
#x       [-grid_include_emulated_device           CHOICES 0 1]
#x       [-grid_link_multiplier                   NUMERIC]
#x       [-mesh_number_of_nodes                   NUMERIC]
#x       [-mesh_include_emulated_device           CHOICES 0 1]
#x       [-mesh_link_multiplier                   NUMERIC]
#x       [-ring_number_of_nodes                   NUMERIC]
#x       [-ring_include_emulated_device           CHOICES 0 1]
#x       [-ring_link_multiplier                   NUMERIC]
#x       [-hub_spoke_number_of_first_level        NUMERIC]
#x       [-hub_spoke_number_of_second_level       NUMERIC]
#x       [-hub_spoke_enable_level_2               CHOICES 0 1]
#x       [-hub_spoke_link_multiplier              NUMERIC]
#x       [-tree_number_of_nodes                   NUMERIC]
#x       [-tree_include_emulated_device           CHOICES 0 1]
#x       [-tree_use_tree_depth                    CHOICES 0 1]
#x       [-tree_depth                             NUMERIC]
#x       [-tree_max_children_per_node             NUMERIC]
#x       [-tree_link_multiplier                   NUMERIC]
#x       [-custom_link_multiplier                 NUMERIC]
#x       [-custom_from_node_index                 NUMERIC]
#x       [-custom_to_node_index                   NUMERIC]
#x       [-fat_tree_link_multiplier               NUMERIC]
#x       [-fat_tree_level_count                   NUMERIC]
#x       [-fat_tree_node_count                    NUMERIC]
#x       [-linear_nodes                           NUMERIC]
#x       [-linear_link_multiplier                 NUMERIC]
#x       [-active_router_id                       CHOICES 0 1]
#x       [-router_id                              IP
#x                                                DEFAULT 0.0.0.0]
#        [-router_id_step                         IP
#                                                 DEFAULT 0.0.0.0]
#x       [-router_system_id                       HEX8WITHSPACES]
#x       [-enable_advertise_as_stub_network       CHOICES 0 1]
#        [-router_abr                             CHOICES 0 1
#                                                 DEFAULT 0]
#        [-router_asbr                            CHOICES 0 1
#                                                 DEFAULT 0]
#x       [-router_active                          CHOICES 0 1]
#x       [-connected_to_handle                    ANY]
#x       [-from_ip                                IPV4]
#x       [-from_ip_step                           IPV4]
#x       [-to_ip                                  IPV4]
#x       [-to_ip_step                             IPV4]
#x       [-enable_ip                              CHOICES 0 1]
#x       [-subnet_prefix_length                   NUMERIC]
#        [-link_te                                CHOICES 0 1]
#x       [-link_metric                            NUMERIC]
#        [-link_te_metric                         RANGE 0-65535
#                                                 DEFAULT 10]
#        [-link_te_max_bw                         NUMERIC
#                                                 DEFAULT 0]
#        [-link_te_max_resv_bw                    NUMERIC
#                                                 DEFAULT 0]
#        [-link_te_unresv_bw_priority0            NUMERIC
#                                                 DEFAULT 0]
#        [-link_te_unresv_bw_priority1            NUMERIC
#                                                 DEFAULT 0]
#        [-link_te_unresv_bw_priority2            NUMERIC
#                                                 DEFAULT 0]
#        [-link_te_unresv_bw_priority3            NUMERIC
#                                                 DEFAULT 0]
#        [-link_te_unresv_bw_priority4            NUMERIC
#                                                 DEFAULT 0]
#        [-link_te_unresv_bw_priority5            NUMERIC
#                                                 DEFAULT 0]
#        [-link_te_unresv_bw_priority6            NUMERIC
#                                                 DEFAULT 0]
#        [-link_te_unresv_bw_priority7            NUMERIC
#                                                 DEFAULT 0]
#x       [-link_te_administrator_group            NUMERIC
#x                                                DEFAULT 0]
#x       [-external1_metric                       NUMERIC]
#x       [-external1_active                       CHOICES 0 1]
#x       [-external1_network_address              IPV4]
#x       [-external1_network_address_step         IPV4
#x                                                DEFAULT 0.0.0.1]
#x       [-external1_number_of_routes             NUMERIC]
#x       [-external1_prefix                       NUMERIC]
#x       [-external2_metric                       NUMERIC]
#x       [-external2_active                       CHOICES 0 1]
#x       [-external2_network_address              IPV4]
#x       [-external2_network_address_step         IPV4
#x                                                DEFAULT 0.0.0.1]
#x       [-external2_number_of_routes             NUMERIC]
#x       [-external2_prefix                       NUMERIC]
#x       [-nssa_metric                            NUMERIC]
#x       [-nssa_active                            CHOICES 0 1]
#x       [-nssa_network_address                   IP]
#x       [-nssa_network_address_step              IP
#x                                                DEFAULT 0.0.0.1]
#x       [-nssa_number_of_routes                  NUMERIC]
#x       [-nssa_prefix                            NUMERIC]
#x       [-stub_metric                            NUMERIC]
#x       [-stub_active                            CHOICES 0 1]
#x       [-stub_network_address                   IPV4]
#x       [-stub_network_address_step              IPV4
#x                                                DEFAULT 0.0.0.1]
#x       [-stub_number_of_routes                  NUMERIC]
#x       [-stub_prefix                            NUMERIC]
#x       [-summary_metric                         NUMERIC]
#x       [-summary_active                         CHOICES 0 1]
#x       [-summary_network_address                IPV4]
#x       [-summary_network_address_step           IPV4
#x                                                DEFAULT 0.0.0.1]
#x       [-summary_number_of_routes               NUMERIC]
#x       [-summary_prefix                         NUMERIC]
#x       [-ipv4_prefix_network_address            IP]
#x       [-ipv4_prefix_network_address_step       IP
#x                                                DEFAULT 0.0.0.1]
#x       [-ipv4_prefix_length                     NUMERIC]
#x       [-ipv4_prefix_number_of_addresses        NUMERIC]
#x       [-ipv4_prefix_metric                     NUMERIC]
#x       [-ipv4_prefix_active                     CHOICES 0 1]
#x       [-ipv4_prefix_allow_propagate            CHOICES 0 1]
#x       [-ipv4_prefix_route_origin               CHOICES another_area
#x                                                CHOICES external_type_1
#x                                                CHOICES external_type_2
#x                                                CHOICES nssa
#x                                                CHOICES same_area
#x                                                DEFAULT another_area]
#x       [-return_detailed_handles                CHOICES 0 1
#x                                                DEFAULT 0]
#x       [-external_link_router_source            NUMERIC]
#x       [-external_link_router_destination       NUMERIC]
#x       [-external_link_network_group_handle     ANY]
#x       [-ipv6_prefix_network_address            IPV6]
#x       [-ipv6_prefix_network_address_step       IPV6]
#x       [-ipv6_prefix_length                     NUMERIC]
#x       [-ipv6_prefix_number_of_addresses        NUMERIC]
#x       [-ipv6_prefix_metric                     NUMERIC]
#x       [-ipv6_prefix_route_origin               CHOICES anotherarea
#x                                                CHOICES externaltype1
#x                                                CHOICES externaltype2
#x                                                CHOICES samearea
#x                                                CHOICES nssa]
#x       [-ipv6_prefix_active                     CHOICES 0 1]
#x       [-from_ipv6                              IPV6]
#x       [-from_ipv6_step                         IPV6]
#x       [-to_ipv6                                IPV6]
#x       [-to_ipv6_step                           IPV6]
#x       [-external_ipv6_network_address          IPV6]
#x       [-external_ipv6_network_address_step     IPV6
#x                                                DEFAULT 0:0:0:1:0:0:0:0]
#x       [-inter_area_destination_router_id       IPV4]
#x       [-inter_area_destination_router_id_step  IPV4]
#x       [-inter_area_link_state_id               IPV4]
#x       [-external_reference_ls_type             CHOICES ignore router network]
#x       [-external_forwarding_address            IPV6]
#x       [-external_external_route_tag            IPV4]
#x       [-external_referenced_link_state_id      IPV4]
#x       [-external_link_state_id                 IPV4]
#x       [-external_link_state_id_prefix          IPV4]
#x       [-intra_area_reference_ls_type           CHOICES router network]
#x       [-intra_area_referenced_link_state_id    IPV4]
#x       [-intra_area_referenced_router_id        IPV4]
#x       [-intra_area_link_state_id               IPV4]
#x       [-intra_area_link_state_id_prefix        IPV4]
#x       [-linklsa_router_priority                NUMERIC]
#x       [-linklsa_link_local_address             IPV6]
#x       [-linklsa_metric                         NUMERIC]
#x       [-linklsa_link_state_id                  IPV4]
#x       [-linklsa_link_state_id_prefix           IPV4]
#x       [-linklsa_active                         CHOICES 0 1]
#x       [-linklsa_network_address                IPV6]
#x       [-linklsa_prefix_count                   NUMERIC]
#x       [-linklsa_prefix                         NUMERIC]
#x       [-inter_area_metric                      NUMERIC]
#x       [-inter_area_active                      CHOICES 0 1]
#x       [-external_metric                        NUMERIC]
#x       [-external_active                        CHOICES 0 1]
#x       [-external_prefix_count                  NUMERIC]
#x       [-external_prefix                        ANY]
#x       [-auto_select_forwarding_address         CHOICES 0 1]
#x       [-allow_propagate                        CHOICES 0 1]
#x       [-forwarding_address                     IPV6]
#x       [-forwarding_address_step                IPV6]
#x       [-inter_area_prefix_metric               NUMERIC]
#x       [-inter_area_prefix_link_state_id        IPV4]
#x       [-inter_area_prefix_link_state_id_prefix IPV4]
#x       [-inter_area_prefix_active               CHOICES 0 1]
#x       [-inter_area_prefix_network_address      IPV6]
#x       [-inter_area_prefix_prefix_count         NUMERIC]
#x       [-inter_area_prefix_prefix               NUMERIC]
#x       [-nssa_propagate                         CHOICES 0 1]
#x       [-nssa_link_state_id                     IPV4]
#x       [-nssa_link_state_id_step                IPV4]
#x       [-intra_area_metric                      NUMERIC]
#x       [-intra_area_active                      CHOICES 0 1]
#x       [-intra_area_prefix_count                NUMERIC]
#x       [-prefix                                 ANY]
#x       [-inter_area_prefix_count                NUMERIC]
#x       [-nssa_include_forwarding_address        CHOICES 0 1]
#x       [-inter_area_link_state_id_step          IPV4]
#x       [-intra_area_network_address             IPV6]
#x       [-intra_area_network_address_step        IPV6]
#x       [-external_e_bit                         CHOICES 0 1]
#x       [-external_f_bit                         CHOICES 0 1]
#x       [-external_t_bit                         CHOICES 0 1]
#x       [-inter_area_reserved_bit7               CHOICES 0 1]
#x       [-inter_area_reserved_bit6               CHOICES 0 1]
#x       [-inter_area_d_c_bit                     CHOICES 0 1]
#x       [-inter_area_r_bit                       CHOICES 0 1]
#x       [-inter_area_n_bit                       CHOICES 0 1]
#x       [-inter_area_m_c_bit                     CHOICES 0 1]
#x       [-inter_area_e_bit                       CHOICES 0 1]
#x       [-inter_area_v6_bit                      CHOICES 0 1]
#x       [-external_unused_bit7                   CHOICES 0 1]
#x       [-external_unused_bit6                   CHOICES 0 1]
#x       [-external_unused_bit5                   CHOICES 0 1]
#x       [-external_unused_bit4                   CHOICES 0 1]
#x       [-external_p_bit                         CHOICES 0 1]
#x       [-external_m_c_bit                       CHOICES 0 1]
#x       [-external_l_a_bit                       CHOICES 0 1]
#x       [-external_n_u_bit                       CHOICES 0 1]
#x       [-intra_area_unused_bit7                 CHOICES 0 1]
#x       [-intra_area_unused_bit6                 CHOICES 0 1]
#x       [-intra_area_unused_bit5                 CHOICES 0 1]
#x       [-intra_area_unused_bit4                 CHOICES 0 1]
#x       [-intra_area_p_bit                       CHOICES 0 1]
#x       [-intra_area_m_c_bit                     CHOICES 0 1]
#x       [-intra_area_l_a_bit                     CHOICES 0 1]
#x       [-intra_area_n_u_bit                     CHOICES 0 1]
#x       [-inter_area_prefix_unused_bit7          CHOICES 0 1]
#x       [-inter_area_prefix_unused_bit6          CHOICES 0 1]
#x       [-inter_area_prefix_unused_bit5          CHOICES 0 1]
#x       [-inter_area_prefix_unused_bit4          CHOICES 0 1]
#x       [-inter_area_prefix_p_bit                CHOICES 0 1]
#x       [-inter_area_prefix_m_c_bit              CHOICES 0 1]
#x       [-inter_area_prefix_l_a_bit              CHOICES 0 1]
#x       [-inter_area_prefix_n_u_bit              CHOICES 0 1]
#x       [-linklsa_reserved_bit7                  CHOICES 0 1]
#x       [-linklsa_reserved_bit6                  CHOICES 0 1]
#x       [-linklsa_d_c_bit                        CHOICES 0 1]
#x       [-linklsa_r_bit                          CHOICES 0 1]
#x       [-linklsa_n_bit                          CHOICES 0 1]
#x       [-linklsa_x_bit                          CHOICES 0 1]
#x       [-linklsa_e_bit                          CHOICES 0 1]
#x       [-linklsa_v6_bit                         CHOICES 0 1]
#x       [-linklsa_unused_bit7                    CHOICES 0 1]
#x       [-linklsa_unused_bit6                    CHOICES 0 1]
#x       [-linklsa_unused_bit5                    CHOICES 0 1]
#x       [-linklsa_unused_bit4                    CHOICES 0 1]
#x       [-linklsa_p_bit                          CHOICES 0 1]
#x       [-linklsa_m_c_bit                        CHOICES 0 1]
#x       [-linklsa_l_a_bit                        CHOICES 0 1]
#x       [-linklsa_n_u_bit                        CHOICES 0 1]
#
# Arguments:
#    -handle
#        This option represents the handle the user *must* pass to the
#        "emulation_ospf_network_group_config" procedure. This option specifies
#        on which OSPF router to configure the OSPF route range.
#        The OSPF router handle(s) are returned by the procedure
#        "emulation_ospf_config" when configuring OSPF routers on the
#        Ixia interface.
#    -mode
#        Mode of the procedure call.Valid options are:
#        create
#        modify
#        delete
#    -type
#        The type of topology route to create.
#x   -protocol_name
#x   -multiplier
#x   -enable_device
#x       enables/disables device.
#    -grid_col
#        Defines number of columns in a grid.
#        This option is valid only when -type is grid, otherwise it
#        is ignored. This option is available with IxTclNetwork and IxTclProtocol API.
#    -grid_row
#        Defines number of rows in a grid.
#        This option is valid only when -type is grid, otherwise it
#        is ignored.
#        This option is available with IxTclNetwork and IxTclProtocol API.
#x   -grid_include_emulated_device
#x   -grid_link_multiplier
#x   -mesh_number_of_nodes
#x   -mesh_include_emulated_device
#x   -mesh_link_multiplier
#x   -ring_number_of_nodes
#x   -ring_include_emulated_device
#x   -ring_link_multiplier
#x   -hub_spoke_number_of_first_level
#x   -hub_spoke_number_of_second_level
#x   -hub_spoke_enable_level_2
#x   -hub_spoke_link_multiplier
#x   -tree_number_of_nodes
#x   -tree_include_emulated_device
#x   -tree_use_tree_depth
#x   -tree_depth
#x   -tree_max_children_per_node
#x   -tree_link_multiplier
#x   -custom_link_multiplier
#x       number of links between two nodes
#x   -custom_from_node_index
#x   -custom_to_node_index
#x   -fat_tree_link_multiplier
#x       number of links between two nodes
#x   -fat_tree_level_count
#x       Number of Levels
#x   -fat_tree_node_count
#x       Number of Nodes Per Level
#x   -linear_nodes
#x       number of nodes
#x   -linear_link_multiplier
#x       number of links between two nodes
#x   -active_router_id
#x   -router_id
#x       The ID associated with the router.
#    -router_id_step
#        The ID associated with the router.
#x   -router_system_id
#x       6 Byte System Id in hex format.
#x   -enable_advertise_as_stub_network
#    -router_abr
#        If true (1), set router to be an area boundary router (ABR).
#        Correspond to E (external) bit in router LSA.
#        This option is valid only when -type is router or grid, otherwise it
#        is ignored.
#        This option is available with IxTclNetwork and IxTclProtocol API.
#    -router_asbr
#        If true (1), set router to be an AS boundary router (ASBR).
#        Correspond to B (Border) bit in router LSA.
#        This option is valid only when -type is router or grid, otherwise it
#        is ignored.
#        This option is available with IxTclNetwork and IxTclProtocol API.
#x   -router_active
#x       Flag.
#x   -connected_to_handle
#x       Scenario element this connector is connecting to
#x   -from_ip
#x   -from_ip_step
#x   -to_ip
#x   -to_ip_step
#x   -enable_ip
#x       Enable Simulated Interface IP
#x   -subnet_prefix_length
#    -link_te
#        This parameter enables Traffic Engineering on the link to the virtual ospf network Range topology.
#        This field is applicable only when the -type is grid.
#        This option is available with IxTclNetwork.
#x   -link_metric
#    -link_te_metric
#        This parameter is valid for -type router, grid.
#        This parameter is valid with IxTclProtocol and IxTclNetwork.
#    -link_te_max_bw
#        This parameter is valid for -type router, grid.
#        This parameter is valid with IxTclProtocol and IxTclNetwork.
#    -link_te_max_resv_bw
#        This parameter is valid for -type router, grid.
#        This parameter is valid with IxTclProtocol and IxTclNetwork.
#    -link_te_unresv_bw_priority0
#        This parameter is valid for -type router, grid.
#        This parameter is valid with IxTclProtocol and IxTclNetwork.
#    -link_te_unresv_bw_priority1
#        This parameter is valid for -type router, grid.
#        This parameter is valid with IxTclProtocol and IxTclNetwork.
#    -link_te_unresv_bw_priority2
#        This parameter is valid for -type router, grid.
#        This parameter is valid with IxTclProtocol and IxTclNetwork.
#    -link_te_unresv_bw_priority3
#        This parameter is valid for -type router, grid.
#        This parameter is valid with IxTclProtocol and IxTclNetwork.
#    -link_te_unresv_bw_priority4
#        This parameter is valid for -type router, grid.
#        This parameter is valid with IxTclProtocol and IxTclNetwork.
#    -link_te_unresv_bw_priority5
#        This parameter is valid for -type router, grid.
#        This parameter is valid with IxTclProtocol and IxTclNetwork.
#    -link_te_unresv_bw_priority6
#        This parameter is valid for -type router, grid.
#        This parameter is valid with IxTclProtocol and IxTclNetwork.
#    -link_te_unresv_bw_priority7
#        This parameter is valid for -type router, grid.
#        This parameter is valid with IxTclProtocol and IxTclNetwork.
#x   -link_te_administrator_group
#x       This parameter is valid for -type router, grid.
#x       This parameter is valid with IxTclProtocol and IxTclNetwork.
#x   -external1_metric
#x   -external1_active
#x   -external1_network_address
#x   -external1_network_address_step
#x   -external1_number_of_routes
#x   -external1_prefix
#x   -external2_metric
#x   -external2_active
#x   -external2_network_address
#x   -external2_network_address_step
#x   -external2_number_of_routes
#x   -external2_prefix
#x   -nssa_metric
#x   -nssa_active
#x   -nssa_network_address
#x   -nssa_network_address_step
#x   -nssa_number_of_routes
#x   -nssa_prefix
#x   -stub_metric
#x   -stub_active
#x   -stub_network_address
#x   -stub_network_address_step
#x   -stub_number_of_routes
#x   -stub_prefix
#x   -summary_metric
#x   -summary_active
#x   -summary_network_address
#x   -summary_network_address_step
#x   -summary_number_of_routes
#x   -summary_prefix
#x   -ipv4_prefix_network_address
#x   -ipv4_prefix_network_address_step
#x   -ipv4_prefix_length
#x   -ipv4_prefix_number_of_addresses
#x   -ipv4_prefix_metric
#x   -ipv4_prefix_active
#x   -ipv4_prefix_allow_propagate
#x   -ipv4_prefix_route_origin
#x   -return_detailed_handles
#x       This argument determines if individual interface, session or router handles are returned by the current command.
#x       This applies only to the command on which it is specified.
#x       Setting this to 0 means that only NGPF-specific protocol stack handles will be returned. This will significantly
#x       decrease the size of command results and speed up script execution.
#x       The default is 0, meaning only protocol stack handles will be returned.
#x   -external_link_router_source
#x       Index of the originating node as defined in fromNetworkTopology
#x   -external_link_router_destination
#x       Index of the target node as defined in toNetworkTopology
#x   -external_link_network_group_handle
#x       Network Topology this link is pointing to
#x   -ipv6_prefix_network_address
#x       Network addresses of the simulated IPv4 network
#x   -ipv6_prefix_network_address_step
#x       Network addresses step of the simulated IPv6 network
#x   -ipv6_prefix_length
#x       Defines the length (in bits) of the mask to be used
#x       in conjunction with all the addresses created in the range.
#x   -ipv6_prefix_number_of_addresses
#x       Number of Network Addresses
#x   -ipv6_prefix_metric
#x       Route Metric
#x   -ipv6_prefix_route_origin
#x       Route Origin
#x   -ipv6_prefix_active
#x       Flag.
#x   -from_ipv6
#x       128 Bits IPv6 address.
#x   -from_ipv6_step
#x   -to_ipv6
#x       128 Bits IPv6 address.
#x   -to_ipv6_step
#x   -external_ipv6_network_address
#x       Network addresses of the simulated IPv6 network
#x   -external_ipv6_network_address_step
#x   -inter_area_destination_router_id
#x       Destination Router Id
#x   -inter_area_destination_router_id_step
#x       Destination Router Id Prefix
#x   -inter_area_link_state_id
#x       Link State Id of the simulated IPv6 network
#x   -external_reference_ls_type
#x       Reference LS Type
#x   -external_forwarding_address
#x       128 Bits IPv6 address.
#x   -external_external_route_tag
#x       External Route Tag
#x   -external_referenced_link_state_id
#x       Referenced Link State Id
#x   -external_link_state_id
#x       Link State Id of the simulated IPv6 network
#x   -external_link_state_id_prefix
#x       Link State Id Prefix
#x   -intra_area_reference_ls_type
#x       Reference LS Type
#x   -intra_area_referenced_link_state_id
#x       Referenced Link State Id
#x   -intra_area_referenced_router_id
#x       Referenced Advertising Router Id
#x   -intra_area_link_state_id
#x       Link State Id of the simulated IPv6 network
#x   -intra_area_link_state_id_prefix
#x       Link State Id Prefix
#x   -linklsa_router_priority
#x       Router Priority
#x   -linklsa_link_local_address
#x       128 Bits IPv6 address.
#x   -linklsa_metric
#x       Metric
#x   -linklsa_link_state_id
#x       Link State Id of the simulated IPv6 network
#x   -linklsa_link_state_id_prefix
#x       Link State Id Prefix
#x   -linklsa_active
#x       Whether this is to be advertised or not
#x   -linklsa_network_address
#x       Network addresses of the simulated IPv6 network
#x   -linklsa_prefix_count
#x       Range Size
#x   -linklsa_prefix
#x       Prefix
#x   -inter_area_metric
#x       Metric
#x   -inter_area_active
#x       Whether this is to be advertised or not
#x   -external_metric
#x       Metric
#x   -external_active
#x       Whether this is to be advertised or not
#x   -external_prefix_count
#x       Prefix Count
#x   -external_prefix
#x       Prefix Length
#x   -auto_select_forwarding_address
#x       Auto Select Forwarding Address
#x   -allow_propagate
#x       Allow Propagate
#x   -forwarding_address
#x       Forwarding addresses of the Type-7 LSA
#x   -forwarding_address_step
#x   -inter_area_prefix_metric
#x       Metric
#x   -inter_area_prefix_link_state_id
#x       Link State Id of the simulated IPv6 network
#x   -inter_area_prefix_link_state_id_prefix
#x       Link State Id Prefix
#x   -inter_area_prefix_active
#x       Whether this is to be advertised or not
#x   -inter_area_prefix_network_address
#x       Prefixes of the simulated IPv6 network
#x   -inter_area_prefix_prefix_count
#x       Prefix Count
#x   -inter_area_prefix_prefix
#x       Prefix Length
#x   -nssa_propagate
#x       Propagate
#x   -nssa_link_state_id
#x       Start Link State Id for the LSAs to be generated for this set of IPv6 NSSA networks.
#x   -nssa_link_state_id_step
#x       Link State Id Step for the LSAs to be generated for this set of IPv6 NSSA networks.
#x   -intra_area_metric
#x       Metric
#x   -intra_area_active
#x       Whether this is to be advertised or not
#x   -intra_area_prefix_count
#x       Prefix Count
#x   -prefix
#x       Prefix Length
#x   -inter_area_prefix_count
#x       Count
#x   -nssa_include_forwarding_address
#x       Include Forwarding Address
#x   -inter_area_link_state_id_step
#x       Link State Id Step for the LSAs to be generated for this set of IPv6 Inter-Area networks.
#x   -intra_area_network_address
#x       Prefixes of the simulated IPv6 network
#x   -intra_area_network_address_step
#x   -external_e_bit
#x       External Metric Bit
#x   -external_f_bit
#x       Forwarding Address Bit
#x   -external_t_bit
#x       External Route Tag Bit
#x   -inter_area_reserved_bit7
#x       (7) Reserved Bit
#x   -inter_area_reserved_bit6
#x       (6) Reserved Bit
#x   -inter_area_d_c_bit
#x       Demand Circuit bit
#x   -inter_area_r_bit
#x       Router bit
#x   -inter_area_n_bit
#x       bit for handling Type 7 LSAs
#x   -inter_area_m_c_bit
#x       bit for forwarding of IP multicast datagrams
#x   -inter_area_e_bit
#x       bit describing how AS-external-LSAs are flooded
#x   -inter_area_v6_bit
#x       bit for excluding the router/link from IPv6 routing calculations. If clear, router/link is excluded
#x   -external_unused_bit7
#x       Options-(7)Unused
#x   -external_unused_bit6
#x       Options-(6)Unused
#x   -external_unused_bit5
#x       Options-(5)Unused
#x   -external_unused_bit4
#x       Options-(4)Unused
#x   -external_p_bit
#x       Options-P Bit(Propagate)
#x   -external_m_c_bit
#x       Options-MC Bit(Multicast)
#x   -external_l_a_bit
#x       Options-LA Bit(Local Address)
#x   -external_n_u_bit
#x       Options-NU Bit(No Unicast)
#x   -intra_area_unused_bit7
#x       Options-(7)Unused
#x   -intra_area_unused_bit6
#x       Options-(6)Unused
#x   -intra_area_unused_bit5
#x       Options-(5)Unused
#x   -intra_area_unused_bit4
#x       Options-(4)Unused
#x   -intra_area_p_bit
#x       Options-P Bit(Propagate)
#x   -intra_area_m_c_bit
#x       Options-MC Bit(Multicast)
#x   -intra_area_l_a_bit
#x       Options-LA Bit(Local Address)
#x   -intra_area_n_u_bit
#x       Options-NU Bit(No Unicast)
#x   -inter_area_prefix_unused_bit7
#x       Options-(7)Unused
#x   -inter_area_prefix_unused_bit6
#x       Options-(6)Unused
#x   -inter_area_prefix_unused_bit5
#x       Options-(5)Unused
#x   -inter_area_prefix_unused_bit4
#x       Options-(4)Unused
#x   -inter_area_prefix_p_bit
#x       Options-P Bit(Propagate)
#x   -inter_area_prefix_m_c_bit
#x       Options-MC Bit(Multicast)
#x   -inter_area_prefix_l_a_bit
#x       Options-LA Bit(Local Address)
#x   -inter_area_prefix_n_u_bit
#x       Options-NU Bit(No Unicast)
#x   -linklsa_reserved_bit7
#x       (7) Reserved Bit
#x   -linklsa_reserved_bit6
#x       (6) Reserved Bit
#x   -linklsa_d_c_bit
#x       Demand Circuit bit
#x   -linklsa_r_bit
#x       Router bit
#x   -linklsa_n_bit
#x       bit for handling Type 7 LSAs
#x   -linklsa_x_bit
#x       bit for forwarding of IP multicast datagrams
#x   -linklsa_e_bit
#x       bit describing how AS-external-LSAs are flooded
#x   -linklsa_v6_bit
#x       bit for excluding the router/link from IPv6 routing calculations. If clear, router/link is excluded
#x   -linklsa_unused_bit7
#x       Options-(7)Unused
#x   -linklsa_unused_bit6
#x       Options-(6)Unused
#x   -linklsa_unused_bit5
#x       Options-(5)Unused
#x   -linklsa_unused_bit4
#x       Options-(4)Unused
#x   -linklsa_p_bit
#x       Options-P Bit(Propagate)
#x   -linklsa_m_c_bit
#x       Options-MC Bit(Multicast)
#x   -linklsa_l_a_bit
#x       Options-LA Bit(Local Address)
#x   -linklsa_n_u_bit
#x       Options-NU Bit(No Unicast)
#
# Return Values:
#    A list containing the simulated router protocol stack handles that were added by the command (if any).
#x   key:simulated_router_handle           value:A list containing the simulated router protocol stack handles that were added by the command (if any).
#    A list containing the external1 protocol stack handles that were added by the command (if any).
#x   key:external1_handle                  value:A list containing the external1 protocol stack handles that were added by the command (if any).
#    A list containing the external2 protocol stack handles that were added by the command (if any).
#x   key:external2_handle                  value:A list containing the external2 protocol stack handles that were added by the command (if any).
#    A list containing the nssa protocol stack handles that were added by the command (if any).
#x   key:nssa_handle                       value:A list containing the nssa protocol stack handles that were added by the command (if any).
#    A list containing the stub protocol stack handles that were added by the command (if any).
#x   key:stub_handle                       value:A list containing the stub protocol stack handles that were added by the command (if any).
#    A list containing the summary protocol stack handles that were added by the command (if any).
#x   key:summary_handle                    value:A list containing the summary protocol stack handles that were added by the command (if any).
#    A list containing the simulated interface protocol stack handles that were added by the command (if any).
#x   key:simulated_interface_handle        value:A list containing the simulated interface protocol stack handles that were added by the command (if any).
#    A list containing the ipv4 prefix interface protocol stack handles that were added by the command (if any).
#x   key:ipv4_prefix_interface_handle      value:A list containing the ipv4 prefix interface protocol stack handles that were added by the command (if any).
#    A list containing the sim interface ipv4 config protocol stack handles that were added by the command (if any).
#x   key:sim_interface_ipv4_config_handle  value:A list containing the sim interface ipv4 config protocol stack handles that were added by the command (if any).
#    A list containing the network group protocol stack handles that were added by the command (if any).
#x   key:network_group_handle              value:A list containing the network group protocol stack handles that were added by the command (if any).
#    A list containing the ipv4 prefix pools protocol stack handles that were added by the command (if any).
#x   key:ipv4_prefix_pools_handle          value:A list containing the ipv4 prefix pools protocol stack handles that were added by the command (if any).
#    A list containing the v3 inter area protocol stack handles that were added by the command (if any).
#x   key:v3_inter_area_handle              value:A list containing the v3 inter area protocol stack handles that were added by the command (if any).
#    A list containing the v3 external protocol stack handles that were added by the command (if any).
#x   key:v3_external_handle                value:A list containing the v3 external protocol stack handles that were added by the command (if any).
#    A list containing the v3 intra area prefix protocol stack handles that were added by the command (if any).
#x   key:v3_intra_area_prefix_handle       value:A list containing the v3 intra area prefix protocol stack handles that were added by the command (if any).
#    A list containing the v3 nssa protocol stack handles that were added by the command (if any).
#x   key:v3_nssa_handle                    value:A list containing the v3 nssa protocol stack handles that were added by the command (if any).
#    A list containing the v3 inter area prefix protocol stack handles that were added by the command (if any).
#x   key:v3_inter_area_prefix_handle       value:A list containing the v3 inter area prefix protocol stack handles that were added by the command (if any).
#    A list containing the ipv6 prefix interface protocol stack handles that were added by the command (if any).
#x   key:ipv6_prefix_interface_handle      value:A list containing the ipv6 prefix interface protocol stack handles that were added by the command (if any).
#    A list containing the ipv6 prefix pools protocol stack handles that were added by the command (if any).
#x   key:ipv6_prefix_pools_handle          value:A list containing the ipv6 prefix pools protocol stack handles that were added by the command (if any).
#    A list containing the sim interface ipv6 config protocol stack handles that were added by the command (if any).
#x   key:sim_interface_ipv6_config_handle  value:A list containing the sim interface ipv6 config protocol stack handles that were added by the command (if any).
#    A list containing the simulated v3 interface protocol stack handles that were added by the command (if any).
#x   key:simulated_v3_interface_handle     value:A list containing the simulated v3 interface protocol stack handles that were added by the command (if any).
#    A list containing the v3 linklsa protocol stack handles that were added by the command (if any).
#x   key:v3_linklsa_handle                 value:A list containing the v3 linklsa protocol stack handles that were added by the command (if any).
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:simulated_router_handles          value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:external1_handles                 value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:external2_handles                 value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:nssa_handles                      value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:stub_handles                      value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:summary_handles                   value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:simulated_interface_handles       value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:ipv4_prefix_interface_handles     value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:v3_inter_area_handles             value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:v3_external_handles               value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:v3_intra_area_prefix_handles      value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:v3_nssa_handles                   value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:v3_inter_area_prefix_handles      value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:ipv6_prefix_interface_handles     value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:simulated_v3_interface_handles    value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:v3_linklsa_handles                value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  simulated_router_handles, external1_handles, external2_handles, nssa_handles, stub_handles, summary_handles, simulated_interface_handles, ipv4_prefix_interface_handles, v3_inter_area_handles, v3_external_handles, v3_intra_area_prefix_handles, v3_nssa_handles, v3_inter_area_prefix_handles, ipv6_prefix_interface_handles, simulated_v3_interface_handles, v3_linklsa_handles
#
# See Also:
#

proc ::ixiangpf::emulation_ospf_network_group_config { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "emulation_ospf_network_group_config" $notImplementedParams $mandatoryParams $fileParams $args]
}
