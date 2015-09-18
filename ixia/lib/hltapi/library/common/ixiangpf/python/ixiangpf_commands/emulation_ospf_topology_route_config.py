# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def emulation_ospf_topology_route_config(self, mode, handle, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    emulation_ospf_topology_route_config
		
		 Description:
		    This procedure will add OSPF route(s) to a particular simulated OSPF
		    router Ixia Interface. The user can configure the properties of the
		    OSPF routes.
		
		 Synopsis:
		    emulation_ospf_topology_route_config
		        -mode                           CHOICES create
		                                        CHOICES modify
		                                        CHOICES delete
		                                        CHOICES enable
		                                        CHOICES disable
		        -handle                         ANY
		        [-type                          CHOICES router
		                                        CHOICES grid
		                                        CHOICES network
		                                        CHOICES summary_routes
		                                        CHOICES ext_routes]
		n       [-area_id                       ANY]
		n       [-bfd_registration              ANY]
		        [-count                         RANGE 1-2000]
		n       [-dead_interval                 ANY]
		        [-elem_handle                   ANY]
		        [-enable_advertise              CHOICES 0 1
		                                        DEFAULT 1]
		x       [-enable_advertise_loopback     CHOICES 0 1
		x                                       DEFAULT 0]
		n       [-entry_point_address           ANY]
		n       [-entry_point_prefix_length     ANY]
		n       [-external_address_family       ANY]
		n       [-external_ip_type              ANY]
		        [-external_number_of_prefix     RANGE 1-16000000
		                                        DEFAULT 24]
		        [-external_prefix_length        RANGE 0-128
		                                        DEFAULT 24]
		        [-external_prefix_metric        RANGE 0-16777215
		                                        DEFAULT 1]
		        [-external_prefix_start         IP
		                                        DEFAULT 0.0.0.0]
		        [-external_prefix_step          RANGE 0-2147483647
		                                        DEFAULT 1]
		        [-external_prefix_type          CHOICES 1 2
		                                        DEFAULT 1]
		        [-grid_col                      RANGE 0-10000
		                                        DEFAULT 2]
		n       [-grid_connect                  ANY]
		        [-grid_link_type                CHOICES broadcast
		                                        CHOICES ptop_numbered
		                                        CHOICES ptop_unnumbered
		                                        DEFAULT ptop_numbered]
		        [-grid_prefix_length            RANGE 0-128
		                                        DEFAULT 24]
		        [-grid_prefix_start             IP
		                                        DEFAULT 0.0.0.0]
		        [-grid_prefix_step              IP
		                                        DEFAULT 0.0.0.1]
		        [-grid_router_id                IP
		                                        DEFAULT 0.0.0.0]
		        [-grid_router_id_step           IP
		                                        DEFAULT 0.0.0.0]
		        [-grid_row                      RANGE 0-10000
		                                        DEFAULT 2]
		        [-grid_te                       CHOICES 0 1
		                                        DEFAULT 0]
		n       [-hello_interval                ANY]
		        [-interface_ip_address          IP
		                                        DEFAULT 0.0.0.0]
		        [-interface_ip_mask             MASK]
		n       [-interface_ip_options          ANY]
		x       [-interface_metric              RANGE 0-65535
		x                                       DEFAULT 10]
		n       [-interface_mode                ANY]
		n       [-interface_mode2               ANY]
		        [-link_te                       CHOICES 0 1]
		        [-link_te_metric                RANGE 0-65535
		                                        DEFAULT 10]
		        [-link_te_max_bw                NUMERIC
		                                        DEFAULT 0]
		        [-link_te_max_resv_bw           NUMERIC
		                                        DEFAULT 0]
		        [-link_te_unresv_bw_priority0   NUMERIC
		                                        DEFAULT 0]
		        [-link_te_unresv_bw_priority1   NUMERIC
		                                        DEFAULT 0]
		        [-link_te_unresv_bw_priority2   NUMERIC
		                                        DEFAULT 0]
		        [-link_te_unresv_bw_priority3   NUMERIC
		                                        DEFAULT 0]
		        [-link_te_unresv_bw_priority4   NUMERIC
		                                        DEFAULT 0]
		        [-link_te_unresv_bw_priority5   NUMERIC
		                                        DEFAULT 0]
		        [-link_te_unresv_bw_priority6   NUMERIC
		                                        DEFAULT 0]
		        [-link_te_unresv_bw_priority7   NUMERIC
		                                        DEFAULT 0]
		n       [-link_type                     ANY]
		n       [-neighbor_router_id            ANY]
		n       [-neighbor_router_prefix_length ANY]
		n       [-net_ip                        ANY]
		n       [-net_prefix_length             ANY]
		n       [-net_prefix_options            ANY]
		n       [-no_write                      ANY]
		        [-router_abr                    CHOICES 0 1
		                                        DEFAULT 0]
		        [-router_asbr                   CHOICES 0 1
		                                        DEFAULT 0]
		        [-router_id                     IP
		                                        DEFAULT 0.0.0.0]
		n       [-router_te                     ANY]
		n       [-router_virtual_link_endpt     ANY]
		n       [-router_wcr                    ANY]
		n       [-summary_address_family        ANY]
		n       [-summary_ip_type               ANY]
		        [-summary_number_of_prefix      RANGE 1-16000000
		                                        DEFAULT 24]
		        [-summary_prefix_length         RANGE 0-128
		                                        DEFAULT 24]
		        [-summary_prefix_metric         RANGE 0-16777215]
		        [-summary_prefix_start          IP
		                                        DEFAULT 0.0.0.0]
		        [-summary_prefix_step           RANGE 0-2147483647
		                                        DEFAULT 1]
		x       [-summary_route_type            CHOICES another_area same_area
		x                                       DEFAULT another_area]
		n       [-grid_disconnect               ANY]
		n       [-link_te_link_id               ANY]
		n       [-link_te_local_ip_addr         ANY]
		n       [-link_te_remote_ip_addr        ANY]
		n       [-link_te_type                  ANY]
		n       [-link_te_instance              ANY]
		n       [-link_te_admin_group           ANY]
		n       [-link_metric                   ANY]
		n       [-link_intf_addr                ANY]
		n       [-link_enable                   ANY]
		n       [-external_connect              ANY]
		n       [-external_prefix_forward_addr  ANY]
		n       [-grid_connect_session          ANY]
		n       [-grid_start_gmpls_link_id      ANY]
		n       [-grid_start_te_ip              ANY]
		n       [-grid_stub_per_router          ANY]
		n       [-net_dr                        ANY]
		n       [-nssa_connect                  ANY]
		n       [-nssa_number_of_prefix         ANY]
		n       [-nssa_prefix_forward_add       ANY]
		n       [-nssa_prefix_length            ANY]
		n       [-nssa_prefix_metric            ANY]
		n       [-nssa_prefix_start             ANY]
		n       [-nssa_prefix_step              ANY]
		n       [-nssa_prefix_type              ANY]
		n       [-router_connect                ANY]
		n       [-router_disconnect             ANY]
		n       [-summary_connect               ANY]
		n       [-nssa_prefix_forward_addr      ANY]
		
		 Arguments:
		    -mode
		        Mode of the procedure call.Valid options are:
		        create
		        modify
		        delete
		        enable
		        disable
		    -handle
		        This option represents the handle the user *must* pass to the
		        "emulation_ospf_topology_route_config" procedure. This option specifies
		        on which OSPF router to configure the OSPF route range.
		        The OSPF router handle(s) are returned by the procedure
		        "emulation_ospf_config" when configuring OSPF routers on the
		        Ixia interface.
		    -type
		        The type of topology route to create.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		n   -area_id
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -bfd_registration
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -count
		        Number of route ranges to be configured.
		        This parameter is valid for -type summary, ext_routes.
		        This option is available with IxTclNetwork.
		n   -dead_interval
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -elem_handle
		        This option specifies on which topology element to configure the
		        route options. The user must pass in this option if the "type" is
		        modify or delete.
		        This parameter is valid with IxTclProtocol and IxTclNetwork.
		    -enable_advertise
		        Enables the advertisement of a range of OSPF routers expressed as a
		        matrix of n x m routers (grid).
		        This parameter is valid for -type router, grid.
		        This parameter is valid with IxTclProtocol and IxTclNetwork.
		x   -enable_advertise_loopback
		x       Used for Traffic Engineering. If checked, a stub interface will be
		x       added to each router with IP = Router ID with a 32-bit mask. (x.x.x.x/32).
		x       This parameter is valid for -type router, grid.
		x       This parameter is valid with IxTclProtocol and IxTclNetwork.
		n   -entry_point_address
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -entry_point_prefix_length
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -external_address_family
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -external_ip_type
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -external_number_of_prefix
		        The number of prefixes to be advertised.
		        This option is valid only when -type is ext_routes, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		    -external_prefix_length
		        The number of bits in the prefixes to be advertised. For example,
		        a value of 24 is equivalent to a network mask of 255.255.255.0.
		        This option is valid only when -type is ext_routes, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		    -external_prefix_metric
		        The cost metric associated with the route.
		        This option is valid only when -type is ext_routes, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		    -external_prefix_start
		        The IP address of the routes to be advertised.
		        This option is valid only when -type is ext_routes, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		    -external_prefix_step
		        The increment used between generated addresses for ext_routes
		        prefixes. For usage with IxNetwork this is the step between route
		        range objects.
		        This option is valid only when -type is ext_routes, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		    -external_prefix_type
		        This option is valid only when -type is ext_routes, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		        Valid choices are:
		        1 - (default) Outside the area.
		        2 - Outside the area, but with metrics which are larger than any
		        internal metric.
		    -grid_col
		        Defines number of columns in a grid.
		        This option is valid only when -type is grid, otherwise it
		        is ignored. This option is available with IxTclNetwork and IxTclProtocol API.
		n   -grid_connect
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -grid_link_type
		        This is the Link Type advertised in the Router LSA interface list.
		        Choose one of: broadcast ptop_numbered ptop_unnumbered
		        This option is valid only when -type is grid, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		    -grid_prefix_length
		        The length of the mask associated with the grid_prefix_start.
		        This option is valid only when -type is grid, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		    -grid_prefix_start
		        The IP subnet address associated with the first router.
		        This option is valid only when -type is grid, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		    -grid_prefix_step
		        This is the value used to increment the subnet address by between
		        successively generated routers.
		        This option is valid only when -type is grid, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		    -grid_router_id
		        The first router ID of the grid.
		        This option is valid only when -type is grid, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		    -grid_router_id_step
		        The increment step for the router ID in a grid.
		        This option is valid only when -type is grid, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		    -grid_row
		        Defines number of rows in a grid.
		        This option is valid only when -type is grid, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		    -grid_te
		        If true (1), enable traffic engineering on the router grid.OSPFv2
		        only. This can overwrite the settings on the
		        session router.
		        This option is valid only when -type is grid, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		n   -hello_interval
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -interface_ip_address
		        For OSPFv2 only.
		        IP address of the unconnected interface between the router/grid
		        to the session router.
		        This option is valid only when -type is router or grid, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		    -interface_ip_mask
		        For OSPFv2 only.
		        IP mask of the un-connected interface between the router/grid
		        to the session router.
		        This option is for router and grid route only.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		n   -interface_ip_options
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -interface_metric
		x       This parameter is valid for OSPFv2 -type router, grid, network and OSPFv3 -type grid.
		x       This parameter is valid with IxTclProtocol and IxTclNetwork.
		n   -interface_mode
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -interface_mode2
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -link_te
		        This parameter enables Traffic Engineering on the link to the virtual ospf network Range topology.
		        This field is applicable only when the -type is grid.
		        This option is available with IxTclNetwork.
		    -link_te_metric
		        This parameter is valid for -type router, grid.
		        This parameter is valid with IxTclProtocol and IxTclNetwork.
		    -link_te_max_bw
		        This parameter is valid for -type router, grid.
		        This parameter is valid with IxTclProtocol and IxTclNetwork.
		    -link_te_max_resv_bw
		        This parameter is valid for -type router, grid.
		        This parameter is valid with IxTclProtocol and IxTclNetwork.
		    -link_te_unresv_bw_priority0
		        This parameter is valid for -type router, grid.
		        This parameter is valid with IxTclProtocol and IxTclNetwork.
		    -link_te_unresv_bw_priority1
		        This parameter is valid for -type router, grid.
		        This parameter is valid with IxTclProtocol and IxTclNetwork.
		    -link_te_unresv_bw_priority2
		        This parameter is valid for -type router, grid.
		        This parameter is valid with IxTclProtocol and IxTclNetwork.
		    -link_te_unresv_bw_priority3
		        This parameter is valid for -type router, grid.
		        This parameter is valid with IxTclProtocol and IxTclNetwork.
		    -link_te_unresv_bw_priority4
		        This parameter is valid for -type router, grid.
		        This parameter is valid with IxTclProtocol and IxTclNetwork.
		    -link_te_unresv_bw_priority5
		        This parameter is valid for -type router, grid.
		        This parameter is valid with IxTclProtocol and IxTclNetwork.
		    -link_te_unresv_bw_priority6
		        This parameter is valid for -type router, grid.
		        This parameter is valid with IxTclProtocol and IxTclNetwork.
		    -link_te_unresv_bw_priority7
		        This parameter is valid for -type router, grid.
		        This parameter is valid with IxTclProtocol and IxTclNetwork.
		n   -link_type
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -neighbor_router_id
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -neighbor_router_prefix_length
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -net_ip
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -net_prefix_length
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -net_prefix_options
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -no_write
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -router_abr
		        If true (1), set router to be an area boundary router (ABR).
		        Correspond to E (external) bit in router LSA.
		        This option is valid only when -type is router or grid, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		    -router_asbr
		        If true (1), set router to be an AS boundary router (ASBR).
		        Correspond to B (Border) bit in router LSA.
		        This option is valid only when -type is router or grid, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		    -router_id
		        The ID associated with the router.
		        This option is valid only when -type is router or grid, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		n   -router_te
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -router_virtual_link_endpt
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -router_wcr
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -summary_address_family
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -summary_ip_type
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -summary_number_of_prefix
		        The number of prefixes to be advertised.
		        This option is valid only when -type is summary_routes, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		    -summary_prefix_length
		        The number of bits in the prefixes to be advertised. For example,
		        a value of 24 is equivalent to a network mask of 255.255.255.0.
		        This option is valid only when -type is summary_routes, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		    -summary_prefix_metric
		        The cost metric associated with the route.
		        This option is valid only when -type is summary_routes, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		    -summary_prefix_start
		        The IP address of the routes to be advertised.
		        This option is valid only when -type is summary_routes, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		    -summary_prefix_step
		        For usage with IxNetwork this is the step between route
		        range objects.
		        For usage with IxTclProtocol and IxTclNetwork this is the increment
		        used to generate multiple summary addresses for OSPFv3 only.
		        This option is valid only when -type is summary_routes, otherwise it
		        is ignored.
		        This option is available with IxTclNetwork and IxTclProtocol API.
		x   -summary_route_type
		x       The type of summary route to be created.
		x       This option is valid only when -type is summary_routes, otherwise it
		x       is ignored.
		x       This option is available with IxTclNetwork.
		n   -grid_disconnect
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -link_te_link_id
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -link_te_local_ip_addr
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -link_te_remote_ip_addr
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -link_te_type
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -link_te_instance
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -link_te_admin_group
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -link_metric
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -link_intf_addr
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -link_enable
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -external_connect
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -external_prefix_forward_addr
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -grid_connect_session
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -grid_start_gmpls_link_id
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -grid_start_te_ip
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -grid_stub_per_router
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -net_dr
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -nssa_connect
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -nssa_number_of_prefix
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -nssa_prefix_forward_add
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -nssa_prefix_length
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -nssa_prefix_metric
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -nssa_prefix_start
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -nssa_prefix_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -nssa_prefix_type
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -router_connect
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -router_disconnect
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -summary_connect
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -nssa_prefix_forward_addr
		n       This argument defined by Cisco is not supported for NGPF implementation.
		
		 Return Values:
		    $::SUCCESS or $::FAILURE
		    key:status       value:$::SUCCESS or $::FAILURE
		    If failure, will contain more information
		    key:log          value:If failure, will contain more information
		    If mode is create this return list of current Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    key:elem_handle  value:If mode is create this return list of current Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		
		 Examples:
		    See files starting with OSPFv2 and OSPFv3 in the Samples subdirectory. Also see some of the L2VPN, L3VPN, MPLS, and MVPN sample files for further examples of the OSPF usage.
		    See the OSPF example in Appendix A, "Example APIs," for one specific example usage.
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    1) Coded versus functional specification.
		    Caveats:
		    This function does not support the following return values:
		    router
		    .  connected_handles
		    .      <handle1>.link_type   <link_type>
		    .                te_link_lsa <te_link_lsa_handle>
		    .  link_type            <link_type_list>
		    .  router_lsa           <router_lsa_handle>
		    .  link_lsa             <ospfv3_link_lsa_handle>
		    .  intra_area_pfx_lsa   <ospfv3_intra_area_prefix_lsa_handle>
		    .  te_router_lsa        <ospfv2_te_router_lsa_handle>
		    .  te_link_lsas         <ospfv2_te_link_lsa_handle_list
		    grid
		    .  router.$row.$col     <router_handle>
		    network
		    .  network_lsa          <lsa_handle>
		    .  intra_area_pfx_lsa   <ospfv3_intra_area_prefix_lsa_handle>
		    .  connected_routers    <router_handle_list>
		    summary
		    .  summary_lsas         <lsa_pool_handle>
		    .  connected_routers    <router_handle_list>
		    external
		    .  external_lsas         <lsa_pool_handle>
		    .  connected_routers     <router_handle_list>
		    nssa
		    .  nssa_lsas            <lsa_pool_handle>
		    .  connected_routers    <router_handle_list>
		    .  version              {ospfv2|ospfv3}
		    handle (ospf_session_handle)/elem_handle must be created and used within one
		    wish shell.
		    OSPFv3
		    Router and grid type do not support "modify" mode. This is due
		    to ixTclHal's lack of getNetworkRange option with a lableId.
		    To workaround, delete then re-create router or grid topology element.
		    OSPFv2/v3
		    Only types that support the enable/disable modes are summary_routes and ext_routes If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  elem_handle
		
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
				'emulation_ospf_topology_route_config', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
