# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def emulation_bgp_route_config(self, handle, mode, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    emulation_bgp_route_config
		
		 Description:
		    This command creates a route range that is associated with a BGP4
		    neighbor.  This command defines a set of routes and associated attributes.
		    The routes can be unicast/multicast, mpls, vpn and vpls.
		
		 Synopsis:
		    emulation_bgp_route_config
		        -handle                               ANY
		        [-route_handle                        ANY]
		        [-l3_site_handle                      ANY]
		        -mode                                 CHOICES add
		                                              CHOICES create
		                                              CHOICES modify
		                                              CHOICES remove
		                                              CHOICES delete
		                                              CHOICES enable
		                                              CHOICES disable
		                                              CHOICES import_routes
		                                              CHOICES generate_routes
		x       [-protocol_name                       ALPHA]
		x       [-protocol_route_name                 ALPHA]
		x       [-active                              CHOICES 0 1]
		        [-ipv4_unicast_nlri                   FLAG]
		n       [-ipv4_multicast_nlri                 ANY]
		n       [-ipv4_mpls_nlri                      ANY]
		        [-ipv4_mpls_vpn_nlri                  FLAG]
		        [-ipv6_unicast_nlri                   FLAG]
		n       [-ipv6_multicast_nlri                 ANY]
		n       [-ipv6_mpls_nlri                      ANY]
		        [-ipv6_mpls_vpn_nlri                  FLAG]
		        [-max_route_ranges                    NUMERIC
		                                              DEFAULT 1]
		        [-ip_version                          CHOICES 4 6
		                                              DEFAULT 4]
		        [-prefix                              IP]
		        [-route_ip_addr_step                  IP]
		n       [-prefix_step_accross_vrfs            ANY]
		        [-num_routes                          NUMERIC]
		        [-num_sites                           NUMERIC]
		x       [-prefix_from                         RANGE 0-128]
		n       [-prefix_to                           ANY]
		n       [-prefix_step                         ANY]
		n       [-prefix_step_across_vrfs             ANY]
		        [-netmask                             IP]
		        [-ipv6_prefix_length                  RANGE 1-128]
		x       [-advertise_nexthop_as_v4             CHOICES 0 1]
		        [-aggregator                          ANY]
		x       [-aggregator_as                       NUMERIC]
		x       [-aggregator_id                       IP]
		x       [-aggregator_id_mode                  CHOICES fixed increment]
		x       [-as_path_set_mode                    CHOICES include_as_seq
		x                                             CHOICES include_as_seq_conf
		x                                             CHOICES include_as_set
		x                                             CHOICES include_as_set_conf
		x                                             CHOICES no_include
		x                                             CHOICES prepend_as
		x                                             DEFAULT include_as_seq]
		x       [-flap_delay                          NUMERIC]
		x       [-flap_down_time                      RANGE 1-1000000]
		x       [-enable_aggregator                   CHOICES 0 1]
		x       [-enable_as_path                      CHOICES 0 1]
		        [-atomic_aggregate                    FLAG]
		        [-cluster_list_enable                 FLAG]
		        [-communities_enable                  FLAG]
		x       [-ext_communities_enable              CHOICES 0 1]
		x       [-enable_route_flap                   FLAG]
		x       [-enable_local_pref                   CHOICES 0 1]
		x       [-enable_med                          CHOICES 0 1]
		        [-next_hop_enable                     FLAG
		                                              DEFAULT 1]
		        [-origin_route_enable                 FLAG]
		        [-originator_id_enable                CHOICES 0 1
		                                              DEFAULT 0]
		x       [-partial_route_flap_from_route_index RANGE 0-1000000]
		x       [-partial_route_flap_to_route_index   RANGE 0-1000000]
		        [-next_hop                            IP]
		x       [-next_hop_ipv4                       IP]
		x       [-next_hop_ipv6                       IP]
		        [-local_pref                          NUMERIC
		                                              DEFAULT 0]
		        [-multi_exit_disc                     NUMERIC]
		x       [-enable_weight                       CHOICES 0 1]
		x       [-weight                              NUMERIC]
		        [-next_hop_mode                       CHOICES fixed
		                                              CHOICES increment
		                                              CHOICES incrementPerPrefix]
		        [-next_hop_ip_version                 CHOICES 4 6]
		        [-next_hop_set_mode                   CHOICES same manual
		                                              DEFAULT same]
		        [-origin                              CHOICES igp egp incomplete]
		        [-originator_id                       IP]
		        [-packing_from                        RANGE 0-65535]
		        [-packing_to                          RANGE 0-65535]
		x       [-enable_partial_route_flap           FLAG]
		x       [-flap_up_time                        RANGE 1-1000000]
		x       [-enable_traditional_nlri             CHOICES 0 1
		x                                             DEFAULT 1]
		n       [-enable_generate_unique_routes       ANY]
		n       [-end_of_rib                          ANY]
		        [-communities                         NUMERIC]
		x       [-communities_as_number               NUMERIC]
		x       [-communities_last_two_octets         NUMERIC]
		x       [-communities_type                    CHOICES no_export
		x                                             CHOICES no_advertised
		x                                             CHOICES no_export_subconfed
		x                                             CHOICES manual]
		        [-ext_communities                     REGEXP ^(0|2|3|4),\d+,(\d{2}\s){5}\d{2}$]
		x       [-ext_communities_as_two_bytes        NUMERIC]
		x       [-ext_communities_as_four_bytes       NUMERIC]
		x       [-ext_communities_assigned_two_bytes  NUMERIC]
		x       [-ext_communities_assigned_four_bytes NUMERIC]
		x       [-ext_communities_ip                  IP]
		x       [-ext_communities_opaque_data         ANY]
		x       [-ext_communities_type                CHOICES admin_as_two_octet
		x                                             CHOICES admin_ip
		x                                             CHOICES admin_as_four_octet
		x                                             CHOICES opaque]
		x       [-ext_communities_subtype             CHOICES route_target
		x                                             CHOICES origin
		x                                             CHOICES extended_bandwidth]
		        [-as_path                             REGEXP ^(as_set|as_seq|as_confed_set|as_confed_seq):\d(,\d)*$]
		x       [-as_path_segment_type                CHOICES as_set
		x                                             CHOICES as_seq
		x                                             CHOICES as_confed_set
		x                                             CHOICES as_confed_seq
		x                                             DEFAULT as_set]
		x       [-as_path_segment_numbers             ANY]
		x       [-enable_as_path_segment              CHOICES 0 1]
		x       [-enable_as_path_segment_number       CHOICES 0 1]
		        [-cluster_list                        REGEXP ^([0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}\s*)+|([0-9]+\s*)+$]
		x       [-vpls                                FLAG]
		x       [-vpls_nlri                           FLAG]
		        [-rd_admin_value                      ANY]
		x       [-rd_admin_value_step                 ANY]
		n       [-rd_admin_step                       ANY]
		        [-rd_assign_value                     NUMERIC]
		x       [-rd_assign_value_step                NUMERIC]
		n       [-rd_assign_step                      ANY]
		x       [-control_word_enable                 CHOICES 0 1]
		x       [-seq_delivery_enable                 CHOICES 0 1]
		x       [-mtu                                 RANGE 0-65535
		x                                             DEFAULT 1500]
		x       [-site_id                             RANGE 0-65535
		x                                             DEFAULT 0]
		x       [-site_id_step                        RANGE 0-65535
		x                                             DEFAULT 0]
		        [-target                              ANY]
		x       [-target_inner_step                   ANY]
		x       [-target_step                         ANY]
		        [-target_assign                       NUMERIC]
		x       [-target_assign_inner_step            NUMERIC]
		x       [-target_assign_step                  NUMERIC]
		        [-rd_type                             CHOICES 0 1 2
		                                              DEFAULT 0]
		        [-target_type                         CHOICES as ip]
		x       [-vpn_name                            ALPHA]
		x       [-advertise_label_block               CHOICES 0 1]
		x       [-num_labels                          RANGE 1-65535
		x                                             DEFAULT 1]
		        [-num_labels_type                     CHOICES list single_value
		                                              DEFAULT single_value]
		x       [-label_block_offset                  RANGE 0-65535
		x                                             DEFAULT 0]
		x       [-label_block_offset_type             CHOICES list single_value
		x                                             DEFAULT single_value]
		        [-label_value                         NUMERIC
		                                              DEFAULT 16]
		        [-label_value_type                    CHOICES list single_value
		                                              DEFAULT single_value]
		x       [-l2_start_mac_addr                   MAC]
		n       [-l2_mac_incr                         ANY]
		n       [-l2_mac_count                        ANY]
		x       [-l2_enable_vlan                      CHOICES 0 1
		x                                             DEFAULT 0]
		x       [-l2_vlan_priority                    NUMERIC]
		x       [-l2_vlan_tpid                        CHOICES 0x8100
		x                                             CHOICES 0x88a8
		x                                             CHOICES 0x9100
		x                                             CHOICES 0x9200
		x                                             CHOICES 0x9300]
		x       [-l2_vlan_id                          RANGE 0-65535
		x                                             DEFAULT 1]
		x       [-l2_vlan_id_incr                     NUMERIC]
		x       [-l2_vlan_incr                        CHOICES 0
		x                                             CHOICES 1
		x                                             CHOICES 2
		x                                             CHOICES 3
		x                                             CHOICES no_increment
		x                                             CHOICES parallel_increment
		x                                             CHOICES inner_first
		x                                             CHOICES outer_first
		x                                             DEFAULT 0]
		x       [-import_rt_as_export_rt              CHOICES 0 1]
		x       [-target_count                        NUMERIC]
		x       [-import_target_count                 NUMERIC]
		n       [-default_mdt_ip                      ANY]
		n       [-default_mdt_ip_incr                 ANY]
		        [-import_target                       ANY]
		n       [-import_target_step                  ANY]
		x       [-import_target_inner_step            ANY]
		        [-import_target_assign                NUMERIC]
		        [-import_target_type                  CHOICES as ip]
		n       [-import_target_assign_step           ANY]
		x       [-import_target_assign_inner_step     NUMERIC]
		n       [-rd_count                            ANY]
		n       [-rd_count_per_vrf                    ANY]
		n       [-rd_admin_value_step_across_vrfs     ANY]
		n       [-rd_assign_value_step_across_vrfs    ANY]
		x       [-label_value_end                     NUMERIC]
		        [-label_incr_mode                     CHOICES fixed rd prefix]
		x       [-label_id                            NUMERIC
		x                                             DEFAULT 0]
		        [-label_step                          NUMERIC
		                                              DEFAULT 1]
		x       [-ad_vpls_nlri                        FLAG]
		x       [-as_number_vpls_id                   ANY]
		x       [-as_number_vpls_rd                   ANY]
		x       [-as_number_vpls_rt                   ANY]
		x       [-assigned_number_vpls_id             ANY]
		x       [-assigned_number_vpls_rd             ANY]
		x       [-assigned_number_vpls_rt             ANY]
		x       [-import_rd_as_rt                     CHOICES 0 1]
		x       [-import_vpls_id_as_rd                CHOICES 0 1]
		x       [-ip_address_vpls_id                  ANY]
		x       [-ip_address_vpls_rd                  ANY]
		x       [-ip_address_vpls_rt                  ANY]
		x       [-number_vsi_id                       ANY]
		x       [-type_vpls_id                        CHOICES as ip]
		x       [-type_vpls_rd                        CHOICES as ip]
		x       [-type_vpls_rt                        CHOICES as ip]
		x       [-type_vsi_id                         CHOICES concat_pe_addr concat_num]
		x       [-override_peer_as_set_mode           CHOICES 0 1]
		n       [-no_write                            ANY]
		x       [-best_routes                         CHOICES 0 1
		x                                             DEFAULT 0]
		x       [-route_distribution_type             CHOICES round_robin replicate
		x                                             DEFAULT round_robin]
		x       [-next_hop_modification_type          CHOICES overwrite_testers_address
		x                                             CHOICES preserve_from_file
		x                                             DEFAULT overwrite_testers_address]
		x       [-file_type                           CHOICES csv cisco juniper
		x                                             DEFAULT csv]
		x       [-route_file                          ANY]
		x       [-primary_routes_per_device           RANGE 1-1000000
		x                                             DEFAULT 1000]
		x       [-duplicate_routes_per_device_percent RANGE 0-100
		x                                             DEFAULT 20]
		x       [-network_address_start               IP
		x                                             DEFAULT 1.0.0.0]
		x       [-network_address_step                IP
		x                                             DEFAULT 0.0.2.0]
		x       [-prefix_length_distribution_type     CHOICES fixed
		x                                             CHOICES random
		x                                             CHOICES even
		x                                             CHOICES exponential
		x                                             CHOICES internet_mix
		x                                             CHOICES custom_profile
		x                                             DEFAULT even]
		x       [-prefix_length_distribution_scope    CHOICES per_device
		x                                             CHOICES per_port
		x                                             CHOICES per_topology
		x                                             DEFAULT per_port]
		x       [-custom_distribution_file            ANY]
		x       [-prefix_length_start                 RANGE 1-32
		x                                             DEFAULT 8]
		x       [-prefix_length_end                   RANGE 1-32
		x                                             DEFAULT 30]
		x       [-primary_routes_as_path_suffix       ALPHA
		x                                             DEFAULT 100,200,300]
		x       [-duplicate_routes_as_path_suffix     ALPHA
		x                                             DEFAULT 500,600]
		
		 Arguments:
		    -handle
		        Valid values are:
		        BGP router handle - handle is returned by procedure emulation_bgp_config.
		        A new route will be added when -mode is add.
		        BGP route handle - Valid only for IxNetwork Tcl API (new api). Handle is returned
		        by procedure emulation_bgp_route_config with 'bgp_routes' key.
		        Valid only for mode remove. The object will be removed.
		        BGP L2Site handle - Valid only for IxNetwork Tcl API (new api). Handle is returned
		        by procedure emulation_bgp_route_config with 'bgp_routes' key. When mode is
		        remove the L2Site will be removed. When mode is add a new label block will be
		        added to the provided L2Site.
		        BGP L3Site handle - Valid only for IxNetwork Tcl API (new api). Handle is returned
		        by procedure emulation_bgp_route_config with 'bgp_routes' key. When mode is
		        remove the L3Site will be removed. When mode is add a new vpn route range will be
		        added to the provided L3Site.
		    -route_handle
		        The handle of the BGP route where to take action.
		    -l3_site_handle
		        The handle of the L3 VPN Site where to take action.
		    -mode
		        Specifies either addition or removal of routes from emulated nodes
		        BGP table.
		x   -protocol_name
		x       This is the name of the protocol stack as it appears in the GUI.
		x   -protocol_route_name
		x       This is the name of the protocol stack as it appears in the GUI.
		x   -active
		x       Activates the item
		    -ipv4_unicast_nlri
		        Enables the emulation of routes for IPv4 unicast.
		        Learned routes filter is enabled at neighbor level for IxTclProcol, for IxTclNetwork the filters are set in emulation_bgp_config.
		        The priority of the flags is the following VPN (L3 Sites), AD VPLS (L2 VPN), VPLS (L2 Sites), MPLS, Unicast/Multicast.
		        Only one of the three route categories can be emulated in a single emulation_bgp_route_config call, the selection is made based on priority.
		n   -ipv4_multicast_nlri
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -ipv4_mpls_nlri
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -ipv4_mpls_vpn_nlri
		        Enables the emulation of routes for IPv4 MPLS VPNs.
		        Learned routes filter is enabled at neighbor level for IxTclProcol, for IxTclNetwork the filters are set in emulation_bgp_config.
		        The priority of the flags is the following VPN (L3 Sites), AD VPLS (L2 VPN), VPLS (L2 Sites), MPLS, Unicast/Multicast.
		        Only one of the three route categories can be emulated in a single emulation_bgp_route_config call, the selection is made based on priority.
		        Requires parameter num_sites to be present in order to create VPN route ranges.
		    -ipv6_unicast_nlri
		        Enables the emulation of routes for IPv6 unicast.
		        Learned routes filter is enabled at neighbor level for IxTclProcol, for IxTclNetwork the filters are set in emulation_bgp_config.
		        The priority of the flags is the following VPN (L3 Sites), AD VPLS (L2 VPN), VPLS (L2 Sites), MPLS, Unicast/Multicast.
		        Only one of the three route categories can be emulated in a single emulation_bgp_route_config call, the selection is made based on priority.
		n   -ipv6_multicast_nlri
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -ipv6_mpls_nlri
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -ipv6_mpls_vpn_nlri
		        Enables the emulation of routes for IPv6 MPLS VPNs.
		        Learned routes filter is enabled at neighbor level for IxTclProcol, for IxTclNetwork the filters are set in emulation_bgp_config.
		        The priority of the flags is the following VPN (L3 Sites), AD VPLS (L2 VPN), VPLS (L2 Sites), MPLS, Unicast/Multicast.
		        Only one of the three route categories can be emulated in a single emulation_bgp_route_config call, the selection is made based on priority.
		        Requires parameter num_sites to be present in order to create VPN route ranges.
		    -max_route_ranges
		        The number of route ranges, mpls route ranges, vpn routes to create
		        under the BGP neighbor or the number of label blocks to create under the BGP neighbor when VPLS is enabled.
		    -ip_version
		        The IP version of the BGP route to be created.
		    -prefix
		        Route prefix to be advertised / removed by emulated BGP node.
		    -route_ip_addr_step
		        IP address increment step between the multiple route ranges created
		        under the BGP neighbor, based on -max_route_ranges.
		n   -prefix_step_accross_vrfs
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -num_routes
		        Number of routes to advertise, using the prefix as the starting prefix
		        and incrementing based upon the -prefix_step and the -netmask
		        arguments.
		    -num_sites
		        Number of L2/L3 VPN sites (PEs) to be created on a BGP neighbor.
		x   -prefix_from
		x       The first prefix length to generate based on the -prefix.
		n   -prefix_to
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -prefix_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -prefix_step_across_vrfs
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -netmask
		        Netmask of the advertised routes.
		    -ipv6_prefix_length
		        IPv6 mask for the IPv6 routes advertised.
		x   -advertise_nexthop_as_v4
		x       Advertise Nexthop as V4
		    -aggregator
		        For the AGGREGATOR path attribute, specifies the last AS number that
		        formed the aggregate route, and the IP address of the BGP speaker
		        that formed the aggregate route.Format: <asn>:<a.b.c.d>.
		x   -aggregator_as
		x       For the AGGREGATOR path attribute, specifies the last AS number that
		x       formed the aggregate route.
		x       Has priority over the legacy -aggregator parameter.
		x   -aggregator_id
		x       For the AGGREGATOR path attribute, specifies the IP address of the BGP speaker
		x       that formed the aggregate route.
		x       Has priority over the legacy -aggregator parameter.
		x   -aggregator_id_mode
		x       Aggregator ID Mode
		x   -as_path_set_mode
		x       For External routing only.
		x       Optional setup for the AS-Path.
		x   -flap_delay
		x       Flapping delay
		x   -flap_down_time
		x       During flapping operation, the period expressed in seconds during
		x       which the route is withdrawn from its neighbors.
		x   -enable_aggregator
		x       Enable Aggregator ID
		x   -enable_as_path
		x       This parameter indicates that as_path attributes are to be generated.
		    -atomic_aggregate
		        Specifies the ATOMIC_AGGREGATE path attribute, which is a discretionary
		        attribute.If set to 1, informs other BGP speakers that the local
		        system selected a less specific route without selecting a more specific
		        route included in it.
		    -cluster_list_enable
		        Enables or disables cluster list on BGP route range.
		    -communities_enable
		        Enables or disables communities.
		x   -ext_communities_enable
		x       Enable Extended Community
		x   -enable_route_flap
		x       FLAG - Enables the flapping functions described by
		x       route_flap_up_time, route_flap_down_time, routesToFlapFrom, and
		x       routesToFlapTo.
		x   -enable_local_pref
		x       This attribute inserts a local_pref attribute with the indicated value. (internal bgp only)
		x   -enable_med
		x       Enable Multi Exit
		    -next_hop_enable
		        A flag to enable the generation of a NEXT HOP attribute. Can be used
		        as a flag of a choice of 0 or 1.
		    -origin_route_enable
		        A flag to define whether to enable the origin route or not.
		    -originator_id_enable
		        Enables or disables originator ID on BGP route range.
		x   -partial_route_flap_from_route_index
		x       When partial route flapping is enabled, gives the index of the
		x       route from which to start.
		x   -partial_route_flap_to_route_index
		x       When partial route flapping is enabled, gives the index of the
		x       route which to end the flap.
		    -next_hop
		        Specifies a mandatory path attribute that defines the IP address of
		        the border router that should be used as the next hop to the
		        destinations listed in the Network Layer Reachability field of the
		        UPDATE message.
		x   -next_hop_ipv4
		x       Specifies a mandatory path attribute that defines the IP address of
		x       the border router that should be used as the next hop to the
		x       destinations listed in the Network Layer Reachability field of the
		x       UPDATE message.
		x       Has priority over the legacy -next_hop parameter.
		x   -next_hop_ipv6
		x       Specifies a mandatory path attribute that defines the IP address of
		x       the border router that should be used as the next hop to the
		x       destinations listed in the Network Layer Reachability field of the
		x       UPDATE message.
		x       Has priority over the legacy -next_hop parameter.
		    -local_pref
		        Specifies the LOCAL_PREF path attribute, which is a discretionary
		        attribute used by a BGP speaker to inform other BGP speakers in its
		        own AS of the originating speakers degree of preference for an
		        advertised route.
		    -multi_exit_disc
		        Specifies the multi-exit discriminator, which is an optional
		        non-transitive path attribute.The value of this attribute may be
		        used by a BGP speakers decision process to discriminate among multiple
		        exit points to a neighboring AS.
		x   -enable_weight
		x       Enable Weight
		x   -weight
		x       Weight
		    -next_hop_mode
		        Indicates that the nextHopIpAddress may be incremented for each
		        neighbor session generated for the range of neighbor addresses.
		    -next_hop_ip_version
		        The type of IP address in nextHopIpAddress.
		    -next_hop_set_mode
		        Indicates how to set the next hop IP address.
		    -origin
		        Selects the value for the ORIGIN path attribute.Note that specifying
		        a path attribute forces the advertised route to be a node route as
		        opposed to a global route.
		    -originator_id
		        Specifies the ORIGINATOR_ID path attribute, which is an optional,
		        non-transitive BGP attribute.It is created by a Route Reflector and
		        carries the ROUTER_ID of the originator of the route in the local AS.
		    -packing_from
		        The minimum number of routes to pack into an UPDATE message.Random
		        numbers are chosen from the range -packing_from to -packing_to.
		    -packing_to
		        The maximum number of routes to pack into an UPDATE message.Random
		        numbers are chosen from the range -packing_from to -packing_to.
		x   -enable_partial_route_flap
		x       FLAG - Enable partial flapping functions.
		x   -flap_up_time
		x       During flapping operation, the time between flap cycles, expressed
		x       in seconds. During this period, the route range will be up.
		x   -enable_traditional_nlri
		x       If checked, use the traditional NLRI in the UPDATE message, instead
		x       of using the MP_REACH_NLRI Multi-protocol extension to advertise
		x       the routes. (Not applicable for MPLS and MPLS VPN Route Ranges.)
		n   -enable_generate_unique_routes
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -end_of_rib
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -communities
		        Specifies the COMMUNITIES path attribute, which is an optional
		        transitive attribute of variable length.All routes with this
		        attribute belong to the communities listed in the attribute.
		        This is a list of numbers.
		x   -communities_as_number
		x       Communities AS #
		x   -communities_last_two_octets
		x       Last Two Octets
		x   -communities_type
		x       Type
		    -ext_communities
		        Specifies the EXTENDED COMMUNITIES path attribute, which is a
		        transitive optional BGP attribute.All routes with the EXTENDED
		        COMMUNITIES attribute belong to the communities listed in the
		        attribute.
		        <p> This is a list of numbers separated by comma char "," as follows: </p>
		        <p> The first number is the value of the low-order type byte.
		        Possible values: </p>
		        <ol>
		        <li> 0 - (default) </p>
		        <li> 2 - Route target community </li>
		        <li> 3 - Route origin community </li>
		        <li> 4 - Link bandwidth community </li>
		        </ol>
		        <p> The second number is the value of the high-order type byte.
		        Possible values: </p>
		        <ol>
		        <li> 128 - IANA bit:
		        This bit may be or'd with any other values. 0 indicates
		        that this is an IANA assignable type using First Come
		        First Serve policy. 1 indicates that this is an IANA
		        assignable type using the IETF Consensus policy. </li>
		        </ol>
		        <ol>
		        <li> 64 - Transitive bit:
		        This bit may be or'd with any other values. 0 indicates
		        that the community is transitive across ASes and 1
		        indicates that it is non-transitive. </li>
		        </ol>
		        <ol>
		        <li> 0 - Two-octet AS specific (default):
		        Value holds a two-octet global ASN followed by a four-bytes
		        local admin value. </p>
		        <li> 1 - IPv4 address specific:
		        Value holds a four-octet IP address followed by a two-bytes
		        local administrator value. </li>
		        <li> 2 - Four-octet AS specific:
		        Value holds a four-octet global ASN followed by a two-bytes
		        local admin value. </li>
		        <li> 3 - Generic:
		        Value holds six-octets. </li>
		        <li> The third number is the value associated with the extended
		        community. (default = {00 00 00 00 00 00}) </li>
		        </ol>
		        <p> Example value: {2,128,03 22 00 00 00 00}. </p>
		x   -ext_communities_as_two_bytes
		x       AS 2-Bytes
		x   -ext_communities_as_four_bytes
		x       AS 4-Bytes
		x   -ext_communities_assigned_two_bytes
		x       Assigned Number(2 Octets)
		x   -ext_communities_assigned_four_bytes
		x       Assigned Number(4 Octets)
		x   -ext_communities_ip
		x       IP
		x   -ext_communities_opaque_data
		x       Opaque Data
		x   -ext_communities_type
		x       Type
		x   -ext_communities_subtype
		x       SubType
		    -as_path
		        Specifies the AS_PATH path attribute, which is a mandatory attribute
		        composed of a sequence of AS path segments.
		        Format: <as path type>:<comma separated segment list>
		        {as_set|as_seq|as_confed_set|as_confed_seq}:<x,x,x,x>.
		        Example:
		        as_set:1,2,3,4
		        as_set - specifies an unordered set of autonomous systems though
		        which a route in the UPDATE message has traversed.
		        as_seq - specifies an ordered set of autonomous systems through
		        which a route in the UPDATE message has traversed.
		        as_confed_set - specifies an unordered set of autonomous systems in
		        the local confederation that the UPDATE message has traversed.
		        as_confed_seq - specifies an ordered set of autonomous systems in
		        the local confederation that the UPDATE message has traversed.
		        DEFAULT = as_set:<router_as>, where <router_as> is the AS of the
		        router which advertises this route.
		x   -as_path_segment_type
		x       Specifies the segment type for the AS_PATH attribute.
		x       This may be a list of values with equal length to the as_path parameter list.
		x   -as_path_segment_numbers
		x       A list of lists of AS_PATH segment numbers. The outer list length needs to match as_path_segment_type list length.
		x   -enable_as_path_segment
		x       Enable AS Path Segment
		x   -enable_as_path_segment_number
		x       Enable AS Number
		    -cluster_list
		        Specifies the CLUSTER_LIST path attribute, which is an optional,
		        non-transitive BGP attribute.It is a sequence of CLUSTER_ID values
		        representing the reflection path through which the route has passed.
		x   -vpls
		x       (deprecated)
		x       This BGP/BGP+ router/peer supports BGP/BGP+ VPLS per the Kompella draft.
		x       This will enable the L2 Sites.
		x       Does not take priority over other flags that enable L3 sites and AD VPLS.
		x       The priority of the flags is the following VPN (L3 Sites), AD VPLS (L2 VPN), VPLS (L2 Sites), MPLS, Unicast/Multicast.
		x   -vpls_nlri
		x       This BGP/BGP+ router/peer supports BGP/BGP+ VPLS per the Kompella draft.
		x       This will enable the L2 Sites.
		x       Does not take priority over other flags that enable L3 sites and AD VPLS.
		x       The priority of the flags is the following VPN (L3 Sites), AD VPLS (L2 VPN), VPLS (L2 Sites), MPLS, Unicast/Multicast.
		    -rd_admin_value
		        Starting value of the administrator field of the route distinguisher.
		x   -rd_admin_value_step
		x       Inner increment value to step the base route distinguisher administrator
		x       field.
		n   -rd_admin_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -rd_assign_value
		        Starting value of the assigned number field of the route
		        distinguisher.
		x   -rd_assign_value_step
		x       Inner increment value to step the base route distinguisher assigned number
		x       field if -target_count is greater than 1.
		n   -rd_assign_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -control_word_enable
		x       Enable Control Word
		x   -seq_delivery_enable
		x       Enable Sequenced Delivery
		x   -mtu
		x       Maximum transmit unit. Has to be in concordance with the DUT settings.
		x   -site_id
		x       The current L2 site identifier.
		x   -site_id_step
		x       Increment for the L2 site identifier.
		    -target
		        AS number or IP address list based on the -target_type list.
		x   -target_inner_step
		x       Increment value to step the base target field when -target_count is greater than 1.
		x   -target_step
		x       Increment value to step the base target field.
		    -target_assign
		        The assigned number subfield of the value field of the target.It is
		        a number from a numbering space which is maintained by the enterprise
		        administers for a given IP address or ASN space.It is the local
		        part of the target.
		x   -target_assign_inner_step
		x       Increment value to step the base target assigned number fieldwhen -target_count is greater than 1.
		x   -target_assign_step
		x       Increment value to step the base target assigned number field.
		    -rd_type
		        Route distinguisher type.
		    -target_type
		        List of the target type.
		x   -vpn_name
		x       VPN Name
		x   -advertise_label_block
		x       Advertise Label Block
		x   -num_labels
		x       Specifies the number of labels to be created for the current label block.
		    -num_labels_type
		        Type of the -num_labels parameter. Default value is single_value.
		x   -label_block_offset
		x       The offset of the label block.
		x   -label_block_offset_type
		x       Type of the -label_block_offset parameter. Default value is single_value.
		    -label_value
		        Starting value for the label of the BGP route. Default is 16.
		    -label_value_type
		        Type of the -label_value parameter. If this parameter is set to list "-label_value_step" is ignored. Default value is single_value.
		x   -l2_start_mac_addr
		x       Start address for the MAC range.
		n   -l2_mac_incr
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -l2_mac_count
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -l2_enable_vlan
		x       Enable or disable vlan on this mac range.
		x   -l2_vlan_priority
		x       3-bit user priority field in the VLAN tag.
		x   -l2_vlan_tpid
		x       16-bit Tag Protocol Identifier (TPID) or EtherType in the VLAN tag.
		x   -l2_vlan_id
		x       Current vlan id.
		x   -l2_vlan_id_incr
		x       This parameter represents the increment step for vlan id across the ranges.
		x   -l2_vlan_incr
		x       Indicates whether the vlan id gets incremented inside the same range.
		x   -import_rt_as_export_rt
		x       Import RT List Same As Export RT List
		x   -target_count
		x       Number of AS number or IP address list based on the -target_type list.
		x   -import_target_count
		x       Number of RTs in Import Route Target List
		n   -default_mdt_ip
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -default_mdt_ip_incr
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -import_target
		        AS number or IP address list based on the -import_target_type list.
		n   -import_target_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -import_target_inner_step
		x       Increment value to step the base import target field when -target_count is greater than 1.
		    -import_target_assign
		        The assigned number subfield of the value field of the import target.
		        It is a number from a numbering space which is maintained by the
		        enterprise administers for a given IP address or ASN space.It is the
		        local part of the import target.
		    -import_target_type
		        List of the import target type.
		n   -import_target_assign_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -import_target_assign_inner_step
		x       Increment value to step the base import target assigned number field when -target_count is greater than 1.
		n   -rd_count
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -rd_count_per_vrf
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -rd_admin_value_step_across_vrfs
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -rd_assign_value_step_across_vrfs
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -label_value_end
		x       Ending value for the label of the BGP route. If this parameter is not provided it will be calculated as label_value + num_routes * label_step.
		    -label_incr_mode
		        Method in which the MPLS label of an IPv4 MPLS-VPN route will be
		        incremented.
		x   -label_id
		x       The identifier for the label space.
		    -label_step
		        Increment value used to step the base label.
		x   -ad_vpls_nlri
		x       This BGP/BGP+ router/peer supports BGP/BGP+ AD VPLS.
		x       Does not take priority over other flags that enable L3 sites.
		x       The priority of the flags is the following VPN (L3 Sites), AD VPLS (L2 VPN), VPLS (L2 Sites), MPLS, Unicast/Multicast.
		x   -as_number_vpls_id
		x       VPLS ID AS Number
		x   -as_number_vpls_rd
		x       Route Distinguisher AS Number
		x   -as_number_vpls_rt
		x       Route Target AS Number
		x   -assigned_number_vpls_id
		x       VPLS ID Assigned Number
		x   -assigned_number_vpls_rd
		x       Route Distinguisher Assigned Number
		x   -assigned_number_vpls_rt
		x       Route Target Assigned Number
		x   -import_rd_as_rt
		x       Use RD As RT
		x   -import_vpls_id_as_rd
		x       Use VPLS ID As Route Distinguisher
		x   -ip_address_vpls_id
		x       VPLS ID IP Address
		x   -ip_address_vpls_rd
		x       Route Distinguisher IP Address
		x   -ip_address_vpls_rt
		x       Route Target IP Address
		x   -number_vsi_id
		x       VSI ID Number
		x   -type_vpls_id
		x       VPLS ID Type
		x   -type_vpls_rd
		x       RD Type
		x   -type_vpls_rt
		x       RT Type
		x   -type_vsi_id
		x       VSI ID
		x   -override_peer_as_set_mode
		x       Override Peer AS# Set Mode
		n   -no_write
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -best_routes
		x       Import only the best routes (provided route file has this information)
		x   -route_distribution_type
		x       Option to specify distribution type, for distributing imported routes across all BGP Peer.
		x       Options:
		x       round_robin, for allocating routes sequentially, and
		x       replicate, for allocating all routes to each Peer.
		x   -next_hop_modification_type
		x       Option for setting Next Hop modification type.
		x       Options are
		x       overwrite_testers_address for "Overwrite Next Hop with Tester's address"
		x       preserve_from_file for "Preserve Next Hop from file"
		x   -file_type
		x       Import routes file type. Route import may fail in file type is not matching with the file being imported.
		x       Options are:
		x       csv for "Ixia Format / Standard CSV (.csv)"
		x       cisco for "Cisco IOS Format (.txt)"
		x       juniper for "Juniper JUNOS Format (.txt)"
		x   -route_file
		x       Select source file having route information
		x   -primary_routes_per_device
		x       Number of Primary Routes per Device
		x   -duplicate_routes_per_device_percent
		x       Percentage to Duplicate Primary Routes per Device
		x   -network_address_start
		x       This attribute will configure the network start address of the Routes to be generated
		x   -network_address_step
		x       This attribute will configure the network step address of the Routes to be generated
		x   -prefix_length_distribution_type
		x       Prefix Length Distribution Type
		x       Options are:
		x       fixed
		x       random
		x       even
		x       exponential
		x       internet_mix
		x       custom_profile
		x   -prefix_length_distribution_scope
		x       Prefix Length Distribution Scope
		x       Options are:
		x       per_device
		x       per_port
		x       per_topology
		x   -custom_distribution_file
		x       Source file having custom distribution information
		x   -prefix_length_start
		x       Prefix Length Start Value of the Routes to be generated. Applicable only for Fixed, Even and Exponential distribution type
		x   -prefix_length_end
		x       Prefix Length End Value of the Routes to be generated. Applicable only for Even and Exponential distribution type
		x   -primary_routes_as_path_suffix
		x       AS Path Suffix for Primary Routes to be generated
		x   -duplicate_routes_as_path_suffix
		x       AS Path Suffix for Duplicate Routes to be generated
		
		 Return Values:
		    A list containing the network group protocol stack handles that were added by the command (if any).
		x   key:network_group_handle  value:A list containing the network group protocol stack handles that were added by the command (if any).
		    A list containing the ip routes protocol stack handles that were added by the command (if any).
		x   key:ip_routes             value:A list containing the ip routes protocol stack handles that were added by the command (if any).
		    A list containing the l2 site protocol stack handles that were added by the command (if any).
		x   key:l2_site               value:A list containing the l2 site protocol stack handles that were added by the command (if any).
		    A list containing the label blocks protocol stack handles that were added by the command (if any).
		x   key:label_blocks          value:A list containing the label blocks protocol stack handles that were added by the command (if any).
		    A list containing the mac pools protocol stack handles that were added by the command (if any).
		x   key:mac_pools             value:A list containing the mac pools protocol stack handles that were added by the command (if any).
		    A list containing the bgp vrf protocol stack handles that were added by the command (if any).
		x   key:bgp_vrf               value:A list containing the bgp vrf protocol stack handles that were added by the command (if any).
		    A list containing the l3 vpn routes protocol stack handles that were added by the command (if any).
		x   key:l3_vpn_routes         value:A list containing the l3 vpn routes protocol stack handles that were added by the command (if any).
		    A list containing the ad l2vpn protocol stack handles that were added by the command (if any).
		x   key:ad_l2vpn              value:A list containing the ad l2vpn protocol stack handles that were added by the command (if any).
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:bgp_routes            value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:bgp_sites             value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		
		 Examples:
		    See files starting with BGP4_ in the Samples subdirectory.  Also see some
		    of the L3VPN, MPLS, and MVPN sample files for further examples of BGP usage.
		    See the BGP examples in Appendix A, "Example APIs," for specific example usage.
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    Coded versus functional specification.
		    1) You can configure multiple BGP route range on each Ixia interface.
		    If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  bgp_routes, bgp_sites
		
		 See Also:
		
		'''
		hlpy_args = locals().copy()
		hlpy_args.update(kwargs)
		del hlpy_args['self']
		del hlpy_args['kwargs']

		not_implemented_params = []
		mandatory_params = []
		file_params = ['route_file', 'custom_distribution_file']

		try:
			return self.__execute_command(
				'emulation_bgp_route_config', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
