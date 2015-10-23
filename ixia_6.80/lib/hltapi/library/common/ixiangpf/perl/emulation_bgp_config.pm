##Procedure Header
# Name:
#    ixiangpf::emulation_bgp_config
#
# Description:
#    This procedure configures BGP neighbors, internal and/or external.
#    You can configure multiple BGP peers per interface by calling this
#    procedure multiple times.
#
# Synopsis:
#    ixiangpf::emulation_bgp_config
#        -mode                                 CHOICES delete
#                                              CHOICES disable
#                                              CHOICES enable
#                                              CHOICES create
#                                              CHOICES modify
#                                              CHOICES reset
#x       [-active                              CHOICES 0 1
#x                                             DEFAULT 1]
#x       [-md5_enable                          CHOICES 0 1]
#x       [-md5_key                             ANY]
#n       [-port_handle                         ANY]
#        [-handle                              ANY]
#        [-ip_version                          CHOICES 4 6
#                                              DEFAULT 4]
#        [-local_ip_addr                       IPV4]
#        [-gateway_ip_addr                     IP]
#        [-remote_ip_addr                      IPV4]
#        [-local_ipv6_addr                     IPV6]
#        [-remote_ipv6_addr                    IPV6]
#        [-local_addr_step                     IP]
#        [-remote_addr_step                    IP]
#        [-next_hop_enable                     CHOICES 0 1
#                                              DEFAULT 1]
#        [-next_hop_ip                         IP]
#x       [-enable_4_byte_as                    CHOICES 0 1
#x                                             DEFAULT 0]
#        [-local_as                            RANGE 0-4294967295]
#x       [-local_as4                           RANGE 0-4294967295]
#        [-local_as_mode                       CHOICES fixed increment
#                                              DEFAULT fixed]
#n       [-remote_as                           ANY]
#        [-local_as_step                       RANGE 0-4294967295
#                                              DEFAULT 1]
#        [-update_interval                     RANGE 0-65535]
#        [-count                               NUMERIC
#                                              DEFAULT 1]
#        [-local_router_id                     IPV4]
#x       [-local_router_id_step                IPV4
#x                                             DEFAULT 0.0.0.1]
#x       [-vlan                                CHOICES 0 1
#x                                             DEFAULT 0]
#        [-vlan_id                             RANGE 0-4095]
#        [-vlan_id_mode                        CHOICES fixed increment
#                                              DEFAULT increment]
#        [-vlan_id_step                        RANGE 0-4096
#                                              DEFAULT 1]
#x       [-vlan_user_priority                  RANGE 0-7]
#n       [-vpi                                 ANY]
#n       [-vci                                 ANY]
#n       [-vpi_step                            ANY]
#n       [-vci_step                            ANY]
#n       [-atm_encapsulation                   ANY]
#n       [-interface_handle                    ANY]
#n       [-retry_time                          ANY]
#        [-hold_time                           NUMERIC]
#        [-neighbor_type                       CHOICES internal external]
#        [-graceful_restart_enable             CHOICES 0 1
#                                              DEFAULT 0]
#        [-restart_time                        RANGE 0-10000000]
#        [-stale_time                          RANGE 0-10000000]
#        [-tcp_window_size                     RANGE 0-10000000]
#n       [-retries                             ANY]
#        [-local_router_id_enable              CHOICES 0 1
#                                              DEFAULT 0]
#        [-netmask                             RANGE 1-128]
#        [-mac_address_start                   MAC]
#x       [-mac_address_step                    MAC
#x                                             DEFAULT 0000.0000.0001]
#x       [-ipv4_mdt_nlri                       FLAG]
#x       [-ipv4_capability_mdt_nlri            FLAG]
#        [-ipv4_unicast_nlri                   FLAG]
#        [-ipv4_capability_unicast_nlri        FLAG]
#        [-ipv4_filter_unicast_nlri            FLAG]
#        [-ipv4_multicast_nlri                 FLAG]
#        [-ipv4_capability_multicast_nlri      FLAG]
#        [-ipv4_filter_multicast_nlri          FLAG]
#        [-ipv4_mpls_nlri                      FLAG]
#        [-ipv4_capability_mpls_nlri           FLAG]
#        [-ipv4_filter_mpls_nlri               FLAG]
#        [-ipv4_mpls_vpn_nlri                  FLAG]
#        [-ipv4_capability_mpls_vpn_nlri       FLAG]
#        [-ipv4_filter_mpls_vpn_nlri           FLAG]
#        [-ipv6_unicast_nlri                   FLAG]
#        [-ipv6_capability_unicast_nlri        FLAG]
#        [-ipv6_filter_unicast_nlri            FLAG]
#        [-ipv6_multicast_nlri                 FLAG]
#        [-ipv6_capability_multicast_nlri      FLAG]
#        [-ipv6_filter_multicast_nlri          FLAG]
#        [-ipv6_mpls_nlri                      FLAG]
#        [-ipv6_capability_mpls_nlri           FLAG]
#        [-ipv6_filter_mpls_nlri               FLAG]
#        [-ipv6_mpls_vpn_nlri                  FLAG]
#        [-ipv6_capability_mpls_vpn_nlri       FLAG]
#        [-ipv6_filter_mpls_vpn_nlri           FLAG]
#x       [-capability_route_refresh            CHOICES 0 1]
#x       [-capability_route_constraint         CHOICES 0 1]
#x       [-local_loopback_ip_addr              IP]
#x       [-local_loopback_ip_prefix_length     NUMERIC]
#x       [-local_loopback_ip_addr_step         IP]
#x       [-remote_loopback_ip_addr             IP]
#x       [-remote_loopback_ip_addr_step        IP]
#x       [-ttl_value                           NUMERIC]
#x       [-updates_per_iteration               RANGE 0-10000000]
#x       [-bfd_registration                    CHOICES 0 1
#x                                             DEFAULT 0]
#x       [-bfd_registration_mode               CHOICES single_hop multi_hop
#x                                             DEFAULT multi_hop]
#n       [-override_existence_check            ANY]
#n       [-override_tracking                   ANY]
#n       [-no_write                            ANY]
#n       [-vpls                                ANY]
#        [-vpls_nlri                           FLAG]
#        [-vpls_capability_nlri                FLAG]
#        [-vpls_filter_nlri                    FLAG]
#n       [-advertise_host_route                ANY]
#n       [-modify_outgoing_as_path             ANY]
#n       [-remote_confederation_member         ANY]
#n       [-reset                               ANY]
#n       [-route_refresh                       ANY]
#n       [-routes_per_msg                      ANY]
#n       [-suppress_notify                     ANY]
#n       [-timeout                             ANY]
#n       [-update_msg_size                     ANY]
#n       [-vlan_cfi                            ANY]
#x       [-act_as_restarted                    CHOICES 0 1
#x                                             DEFAULT 0]
#x       [-discard_ixia_generated_routes       CHOICES 0 1
#x                                             DEFAULT 0]
#x       [-flap_down_time                      ANY]
#x       [-local_router_id_type                CHOICES same new
#x                                             DEFAULT new]
#x       [-enable_flap                         CHOICES 0 1
#x                                             DEFAULT 0]
#x       [-send_ixia_signature_with_routes     CHOICES 0 1
#x                                             DEFAULT 0]
#x       [-flap_up_time                        ANY]
#x       [-ipv4_multicast_vpn_nlri             FLAG]
#x       [-ipv4_capability_multicast_vpn_nlri  FLAG]
#x       [-ipv4_filter_multicast_vpn_nlri      FLAG]
#x       [-ipv6_multicast_vpn_nlri             FLAG]
#x       [-ipv6_capability_multicast_vpn_nlri  FLAG]
#x       [-ipv6_filter_multicast_vpn_nlri      FLAG]
#x       [-advertise_end_of_rib                CHOICES 0 1
#x                                             DEFAULT 0]
#x       [-configure_keepalive_timer           CHOICES 0 1
#x                                             DEFAULT 0]
#        [-keepalive_timer                     RANGE 0-65535
#                                              DEFAULT 30]
#        [-staggered_start_enable              FLAG]
#        [-staggered_start_time                RANGE 0-10000000]
#x       [-start_rate_enable                   CHOICES 0 1]
#x       [-start_rate_interval                 NUMERIC]
#x       [-start_rate                          NUMERIC]
#x       [-start_rate_scale_mode               CHOICES deviceGroup port]
#x       [-stop_rate_enable                    CHOICES 0 1]
#x       [-stop_rate_interval                  ANY]
#x       [-stop_rate                           ANY]
#x       [-stop_rate_scale_mode                CHOICES deviceGroup port]
#        [-active_connect_enable               FLAG]
#x       [-disable_received_update_validation  CHOICES 0 1]
#x       [-enable_ad_vpls_prefix_length        CHOICES 0 1]
#x       [-ibgp_tester_as_four_bytes           NUMERIC]
#x       [-ibgp_tester_as_two_bytes            NUMERIC]
#x       [-initiate_ebgp_active_connection     CHOICES 0 1]
#x       [-initiate_ibgp_active_connection     CHOICES 0 1]
#x       [-mldp_p2mp_fec_type                  HEX]
#x       [-request_vpn_label_exchange_over_lsp CHOICES 0 1]
#x       [-trigger_vpls_pw_initiation          CHOICES 0 1]
#x       [-as_path_set_mode                    CHOICES include_as_seq
#x                                             CHOICES include_as_seq_conf
#x                                             CHOICES include_as_set
#x                                             CHOICES include_as_set_conf
#x                                             CHOICES no_include
#x                                             CHOICES prepend_as
#x                                             DEFAULT no_include]
#x       [-router_id                           IPV4]
#x       [-router_id_step                      IPV4]
#
# Arguments:
#    -mode
#        This option defines the action to be taken on the BGP server.
#x   -active
#x       Activates the item
#x   -md5_enable
#x       If set to 1, enables MD5 authentication for emulated
#x       BGP node.
#x   -md5_key
#x       The key used for md5 authentication.
#n   -port_handle
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -handle
#        BGP handle used for -mode modify/disable/delete.
#        When -handle is provided with the /globals value the arguments that configure global protocol
#        setting accept both multivalue handles and simple values.
#        When -handle is provided with a a protocol stack handle or a protocol session handle, the arguments
#        that configure global settings will only accept simple values. In this situation, these arguments will
#        configure only the settings of the parent device group or the ports associated with the parent topology.
#    -ip_version
#        This option defines the IP version of the BGP4
#        neighbor to be configured on the Ixia interface.
#    -local_ip_addr
#        The IPv4 address of the Ixia simulated BGP node to be emulated.
#    -gateway_ip_addr
#        The gateway IPV4 or IPV6 address of the BGP4 neighbor interface. If this
#        parameter is not provided it will be initialized to the remote_ip_addr value.
#    -remote_ip_addr
#        The IPv4 address of the DUTs interface connected to the emulated BGP
#        port.
#    -local_ipv6_addr
#        The IPv6 address of the BGP node to be emulated by the test port.
#    -remote_ipv6_addr
#        The IPv6 address of the DUT interface connected to emulated BGP node.
#        This parameter is mandatory when -mode is create, -ip_version is 6 and
#        parameter -neighbor_type is external, or -neighbor_type is internal
#        and ipv4_mpls_nlri, ipv6_mpls_nlri, ipv4_mpls_vpn_nlri, and
#        ipv6_mpls_vpn_nlri are not enabled.
#    -local_addr_step
#        Defines the mask and increment step for the next -local_ip_addr or
#        "-local_ipv6_addr".
#    -remote_addr_step
#        Defines the mask and increment step for the next -remote_ip_addr or
#        "-remote_ipv6_addr".
#    -next_hop_enable
#        This option is used for IPv4 traffic, and enables the
#        use of the BGP NEXT_HOP attributes.When enabled, the IP next hop
#        must be configured (using the -next_hop_ip option).
#    -next_hop_ip
#        Defines the IP of the next hop.This option is used if the
#        flag -next_hop_enable is set.
#x   -enable_4_byte_as
#x       Allow 4 byte values for -local_as.
#    -local_as
#        The AS number of the BGP node to be emulated by the test port.
#x   -local_as4
#x       The 4 bytes AS number of the BGP node to be emulated by the test port.
#    -local_as_mode
#        For External BGP type only. This option controls the AS number
#        (local_as) assigned to additional routers.
#n   -remote_as
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -local_as_step
#        If you configure more then 1 eBGP neighbor on the Ixia interface,
#        and if you select the option local_as_mode to increment, the option
#        local_as_step defines the step by which the AS number is incremented.
#    -update_interval
#        The time intervals at which UPDATE messages are sent to the DUT,
#        expressed in the number of milliseconds between UPDATE messages.
#    -count
#        Number of BGP nodes to create.
#    -local_router_id
#        BGP4 router ID of the emulated node, must be in IPv4 format.
#x   -local_router_id_step
#x       BGP4 router ID step of the emulated node, must be in IPv4 format.
#x   -vlan
#x       Enables vlan on the directly connected BGP router interface.
#x       Valid options are: 0 - disable, 1 - enable.
#x       This option is valid only when -mode is create or -mode is modify
#x       and -handle is a BGP router handle.
#x       This option is available only when IxNetwork tcl API is used.
#    -vlan_id
#        VLAN ID for the emulated router node.
#    -vlan_id_mode
#        For multiple neighbor configuration, configurest the VLAN ID mode.
#    -vlan_id_step
#        Defines the step for every VLAN When -vlan_id_mode is set to
#        increment.
#        When vlan_id_step causes the vlan_id value to exceed it's maximum value the
#        increment will be done modulo <number of possible vlan ids>.
#        Examples: vlan_id = 4094; vlan_id_step = 2-> new vlan_id value = 0
#        vlan_id = 4095; vlan_id_step = 11 -> new vlan_id value = 10
#x   -vlan_user_priority
#x       The VLAN user priority assigned to emulated router node.
#n   -vpi
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vci
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vpi_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vci_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -atm_encapsulation
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -interface_handle
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -retry_time
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -hold_time
#        Configures the hold time for BGP sessions for this Neighbor.
#        Keepalives are sent out every one-third of this interval.If the
#        default value is 90, KeepAlive messages are sent every 30 seconds.
#    -neighbor_type
#        Sets the BGP neighbor type.
#    -graceful_restart_enable
#        Will enable graceful restart (HA) on the BGP4 neighbor.
#    -restart_time
#        If -graceful_restart_enable is set, sets the amount of time following
#        a restart operation allowed to re-establish a BGP session, in seconds.
#    -stale_time
#        If -graceful_restart_enable is set, sets the amount of time
#        after which an End-Of-RIB marker is sent in an Update
#        message to the peer to allow time for routing convergence via IGP
#        and BGP selection, in seconds.Stale routing information for that
#        address family is then deleted by the receiving peer.
#    -tcp_window_size
#        For External BGP neighbor only.The TCP window used for
#        communications from the neighbor.
#n   -retries
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -local_router_id_enable
#        Enables the BGP4 local router id option.
#    -netmask
#        Mask of the IP address for the interface configuration.
#    -mac_address_start
#        Initial MAC address of the interfaces created for the BGP4 neighbor.
#x   -mac_address_step
#x       The incrementing step for thr MAC address of the dirrectly connected
#x       interfaces created for the BGP4 neighbor.
#x       This option is valid only when IxTclNetwork API is used.
#x   -ipv4_mdt_nlri
#x       If checked, this BGP/BGP+ router/peer supports IPv4 MDT address family messages.
#x   -ipv4_capability_mdt_nlri
#x       If checked, this BGP/BGP+ router/peer supports IPv4 MDT address family messages.
#    -ipv4_unicast_nlri
#        If used, support for IPv4 Unicast is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv4_capability_unicast_nlri
#        If used, support for IPv4 Unicast is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv4_filter_unicast_nlri
#        If used, support for IPv4 Unicast is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv4_multicast_nlri
#        If used, support for IPv4 Multicast is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv4_capability_multicast_nlri
#        If used, support for IPv4 Multicast is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv4_filter_multicast_nlri
#        If used, support for IPv4 Multicast is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv4_mpls_nlri
#        If used, support for IPv4 MPLS is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv4_capability_mpls_nlri
#        If used, support for IPv4 MPLS is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv4_filter_mpls_nlri
#        If used, support for IPv4 MPLS is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv4_mpls_vpn_nlri
#        If used, support for IPv4 MPLS VPN is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv4_capability_mpls_vpn_nlri
#        If used, support for IPv4 MPLS VPN is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv4_filter_mpls_vpn_nlri
#        If used, support for IPv4 MPLS VPN is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv6_unicast_nlri
#        If used, support for IPv6 Unicast is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv6_capability_unicast_nlri
#        If used, support for IPv6 Unicast is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv6_filter_unicast_nlri
#        If used, support for IPv6 Unicast is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv6_multicast_nlri
#        If used, support for IPv6 Multicast is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv6_capability_multicast_nlri
#        If used, support for IPv6 Multicast is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv6_filter_multicast_nlri
#        If used, support for IPv6 Multicast is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv6_mpls_nlri
#        If used, support for IPv6 MPLS is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv6_capability_mpls_nlri
#        If used, support for IPv6 MPLS is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv6_filter_mpls_nlri
#        If used, support for IPv6 MPLS is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv6_mpls_vpn_nlri
#        If used, support for IPv6 MPLS VPN is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv6_capability_mpls_vpn_nlri
#        If used, support for IPv6 MPLS VPN is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#    -ipv6_filter_mpls_vpn_nlri
#        If used, support for IPv6 MPLS VPN is advertised in the Capabilities
#        Optional Parameter / Multiprotocol Extensions parameter in the OPEN
#        message and in addition, for IxTclNetwork, also sets the filters for the respective learned routes.
#x   -capability_route_refresh
#x       Route Refresh
#x   -capability_route_constraint
#x       Route Constraint
#x   -local_loopback_ip_addr
#x       Required when the -ipv4_mpls_vpn_nlri option is used.
#x   -local_loopback_ip_prefix_length
#x       Prefix length for local_loopback_ip_addr.
#x   -local_loopback_ip_addr_step
#x       Required when the -ipv4_mpls_vpn_nlri option is used.
#x   -remote_loopback_ip_addr
#x       Required when the -ipv4_mpls_vpn_nlri option is used.
#x       This parameter is mandatory when -mode is create, and
#x       parameter -neighbor_type is internal and
#x       and ipv4_mpls_nlri, ipv6_mpls_nlri, ipv4_mpls_vpn_nlri, and
#x       ipv6_mpls_vpn_nlri are enabled.
#x   -remote_loopback_ip_addr_step
#x       Required when the -ipv4_mpls_vpn_nlri option is used.
#x   -ttl_value
#x       This attribute represents the limited number of iterations that a unit of data can experience
#x       before the data is discarded.
#x   -updates_per_iteration
#x       When the protocol server operates on older ports that do not possess
#x       a local processor, this tuning parameter controls how many UPDATE
#x       messages are sent at a time. When many routers are being simulated on
#x       such a port, changing this value may help to increase or decrease
#x       performance.
#x   -bfd_registration
#x       Enable or disable BFD registration.
#x   -bfd_registration_mode
#x       Set BFD registration mode to single hop or multi hop.
#n   -override_existence_check
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -override_tracking
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -no_write
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vpls
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -vpls_nlri
#        This BGP/BGP+ router/peer supports BGP/BGP+ VPLS per the Kompella draft.
#        This will enable the L2 Sites. If present, means VPLS capabilities are enabled.
#    -vpls_capability_nlri
#        This BGP/BGP+ router/peer supports BGP/BGP+ VPLS per the Kompella draft.
#        This will enable the L2 Sites. If present, means VPLS capabilities are enabled.
#    -vpls_filter_nlri
#        This BGP/BGP+ router/peer supports BGP/BGP+ VPLS per the Kompella draft.
#        This will enable the L2 Sites. If present, means VPLS capabilities are enabled.
#n   -advertise_host_route
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -modify_outgoing_as_path
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -remote_confederation_member
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -reset
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -route_refresh
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -routes_per_msg
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -suppress_notify
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -timeout
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -update_msg_size
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vlan_cfi
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -act_as_restarted
#x       Act as restarted
#x   -discard_ixia_generated_routes
#x       Discard Ixia Generated Routes
#x   -flap_down_time
#x       Downtime in Seconds
#x   -local_router_id_type
#x       BGP ID Same as Router ID
#x   -enable_flap
#x       Flap
#x   -send_ixia_signature_with_routes
#x       Send Ixia Signature With Routes
#x   -flap_up_time
#x       Uptime in Seconds
#x   -ipv4_multicast_vpn_nlri
#x       IPv4 Multicast VPN
#x   -ipv4_capability_multicast_vpn_nlri
#x       IPv4 Multicast VPN
#x   -ipv4_filter_multicast_vpn_nlri
#x       IPv4 Multicast VPN
#x   -ipv6_multicast_vpn_nlri
#x       IPv6 Multicast VPN
#x   -ipv6_capability_multicast_vpn_nlri
#x       IPv6 Multicast VPN
#x   -ipv6_filter_multicast_vpn_nlri
#x       IPv6 Multicast VPN
#x   -advertise_end_of_rib
#x       Advertise End-Of-RIB
#x   -configure_keepalive_timer
#x       Configure Keepalive Timer
#    -keepalive_timer
#        Keepalive Timer
#    -staggered_start_enable
#        Enables staggered start of neighbors.
#    -staggered_start_time
#        When the -staggered_start_enable flag is used, this is the duration of
#        the start process in seconds.
#x   -start_rate_enable
#x       Enable bgp globals start rate
#x   -start_rate_interval
#x       Time interval used to calculate the rate for triggering an action (rate = count/interval)
#x   -start_rate
#x       Number of times an action is triggered per time interval
#x   -start_rate_scale_mode
#x       Indicates whether the control is specified per port or per device group
#x   -stop_rate_enable
#x       Enable bgp globals stop rate
#x   -stop_rate_interval
#x       Time interval used to calculate the rate for triggering an action (rate = count/interval)
#x   -stop_rate
#x       Number of times an action is triggered per time interval
#x   -stop_rate_scale_mode
#x       Indicates whether the control is specified per port or per device group
#    -active_connect_enable
#        For External BGP neighbor.If set, a HELLO message is actively sent
#        when BGP testing starts.Otherwise, the port waits for the DUT to
#        send its HELLO message.
#x   -disable_received_update_validation
#x       Disable Received Update Validation (Enabled for High Performance)
#x   -enable_ad_vpls_prefix_length
#x       Enable AD VPLS Prefix Length in Bits
#x   -ibgp_tester_as_four_bytes
#x       Tester 4 Byte AS# for iBGP
#x   -ibgp_tester_as_two_bytes
#x       Tester AS# for iBGP
#x   -initiate_ebgp_active_connection
#x       Initiate eBGP Active Connection
#x   -initiate_ibgp_active_connection
#x       Initiate iBGP Active Connection
#x   -mldp_p2mp_fec_type
#x       MLDP P2MP FEC Type (Hex)
#x   -request_vpn_label_exchange_over_lsp
#x       Request VPN Label Exchange over LSP
#x   -trigger_vpls_pw_initiation
#x       Trigger VPLS PW Initiation
#x   -as_path_set_mode
#x       For External routing only.
#x       Optional setup for the AS-Path.
#x   -router_id
#x       The ID of the router to be emulated.
#x   -router_id_step
#x       The value use to increment the router_id when count > 1.
#x       (DEFAULT = 0.0.0.1)
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status      value:$::SUCCESS | $::FAILURE
#    When status is $::FAILURE, contains more information
#    key:log         value:When status is $::FAILURE, contains more information
#    Handle of bgpipv4peer or bgpipv6peer configured
#    key:bgp_handle  value:Handle of bgpipv4peer or bgpipv6peer configured
#    Item Handle of any bgpipv4peer or bgpipv6peer configured Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    key:handle      value:Item Handle of any bgpipv4peer or bgpipv6peer configured Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#
# Examples:
#    See files starting with BGP4_ in the Samples subdirectory.  Also see some
#    of the L3VPN, MPLS, and MVPN sample files for further examples of BGP usage.
#    See the BGP examples in Appendix A, "Example APIs," for specific example usage.
#
# Sample Input:
#
# Sample Output:
#    {status $::SUCCESS} {bgp_handle /topology:1/deviceGroup:1/ethernet:1/ipv4:1/bgpIpv4Peer:1} {handle {/topology:1/deviceGroup:1/ethernet:1/ipv4:1/bgpIpv4Peer:1/item:1}}
#
# Notes:
#    Coded versus functional specification.
#    When -handle is provided with the /globals value the arguments that configure global protocol
#    setting accept both multivalue handles and simple values.
#    When -handle is provided with a a protocol stack handle or a protocol session handle, the arguments
#    that configure global settings will only accept simple values. In this situation, these arguments will
#    configure only the settings of the parent device group or the ports associated with the parent topology.
#    If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  handle
#
# See Also:
#

package ixiangpf;

use utils;
use ixiahlt;

sub emulation_bgp_config {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('emulation_bgp_config', $args);
	# ixiahlt::utrackerLog ('emulation_bgp_config', $args);

	return ixiangpf::runExecuteCommand('emulation_bgp_config', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
