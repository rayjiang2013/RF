##Procedure Header
# Name:
#    ::ixiangpf::emulation_isis_config
#
# Description:
#    This procedure configures ISIS routers on an Ixia interface.  The user
#    can create a single or multiple ISIS routers.  These routers can be
#    either L1, L2, or L1L2.
#
# Synopsis:
#    ::ixiangpf::emulation_isis_config
#        -mode                                    CHOICES create
#                                                 CHOICES modify
#                                                 CHOICES delete
#                                                 CHOICES disable
#                                                 CHOICES enable
#n       [-port_handle                            ANY]
#        [-area_authentication_mode               CHOICES null text md5]
#        [-area_password                          ALPHA]
#        [-area_id                                ANY
#                                                 DEFAULT 49 00 01]
#x       [-area_id_step                           ANY
#x                                                DEFAULT 00 00 00]
#n       [-atm_encapsulation                      ANY]
#        [-attach_bit                             CHOICES 0 1]
#n       [-bfd_registration                       ANY]
#        [-count                                  ANY
#                                                 DEFAULT 1]
#n       [-dce_capability_router_id               ANY]
#n       [-dce_bcast_root_priority                ANY]
#n       [-dce_num_mcast_dst_trees                ANY]
#n       [-dce_device_id                          ANY]
#n       [-dce_device_pri                         ANY]
#n       [-dce_ftag_enable                        ANY]
#n       [-dce_ftag                               ANY]
#x       [-enable_host_name                       CHOICES 0 1]
#x       [-host_name                              REGEXP ^[0-9,a-f,A-F]+$]
#        [-discard_lsp                            CHOICES 0 1]
#        [-domain_authentication_mode             CHOICES null text md5]
#        [-domain_password                        ALPHA]
#        [-gateway_ip_addr                        IPV4
#                                                 DEFAULT 0.0.0.0]
#        [-gateway_ip_addr_step                   IPV4
#                                                 DEFAULT 0.0.1.0]
#        [-gateway_ipv6_addr                      IPV6
#                                                 DEFAULT 0::0]
#        [-gateway_ipv6_addr_step                 IPV6
#                                                 DEFAULT 0:0:0:1::0]
#        [-graceful_restart                       CHOICES 0 1]
#        [-graceful_restart_mode                  CHOICES normal
#                                                 CHOICES restarting
#                                                 CHOICES starting
#                                                 CHOICES helper]
#x       [-graceful_restart_version               CHOICES draft3 draft4]
#        [-graceful_restart_restart_time          ANY]
#        -handle                                  ANY
#        [-hello_interval                         RANGE 1-65535]
#x       [-hello_interval_level1                  RANGE 1-65535]
#x       [-hello_interval_level2                  RANGE 1-65535]
#n       [-hello_password                         ANY]
#        [-circuit_tranmit_password_md5_key       ANY]
#n       [-interface_handle                       ANY]
#        [-intf_ip_addr                           IPV4
#                                                 DEFAULT 178.0.0.1]
#x       [-intf_ip_prefix_length                  RANGE 1-32
#x                                                DEFAULT 24]
#        [-intf_ip_addr_step                      IPV4
#                                                 DEFAULT 0.0.1.0]
#        [-intf_ipv6_addr                         IPV6
#                                                 DEFAULT 4000::1]
#        [-intf_ipv6_prefix_length                RANGE 1-128
#                                                 DEFAULT 64]
#        [-intf_ipv6_addr_step                    IPV6
#                                                 DEFAULT 0:0:0:1::0]
#        [-intf_metric                            RANGE 0-16777215]
#x       [-intf_type                              CHOICES broadcast ptop]
#n       [-ip_version                             ANY]
#        [-l1_router_priority                     RANGE 0-127]
#        [-l2_router_priority                     RANGE 0-255]
#n       [-loopback_bfd_registration              ANY]
#n       [-loopback_ip_addr                       ANY]
#n       [-loopback_ip_addr_step                  ANY]
#n       [-loopback_ip_prefix_length              ANY]
#n       [-loopback_ip_addr_count                 ANY]
#n       [-loopback_metric                        ANY]
#n       [-loopback_type                          ANY]
#n       [-loopback_routing_level                 ANY]
#n       [-loopback_l1_router_priority            ANY]
#n       [-loopback_l2_router_priority            ANY]
#n       [-loopback_te_metric                     ANY]
#n       [-loopback_te_admin_group                ANY]
#n       [-loopback_te_max_bw                     ANY]
#n       [-loopback_te_max_resv_bw                ANY]
#n       [-loopback_te_unresv_bw_priority0        ANY]
#n       [-loopback_te_unresv_bw_priority1        ANY]
#n       [-loopback_te_unresv_bw_priority2        ANY]
#n       [-loopback_te_unresv_bw_priority3        ANY]
#n       [-loopback_te_unresv_bw_priority4        ANY]
#n       [-loopback_te_unresv_bw_priority5        ANY]
#n       [-loopback_te_unresv_bw_priority6        ANY]
#n       [-loopback_te_unresv_bw_priority7        ANY]
#n       [-loopback_hello_password                ANY]
#        [-lsp_life_time                          RANGE 0-65535]
#        [-lsp_refresh_interval                   RANGE 1-65535]
#        [-mac_address_init                       MAC]
#x       [-mac_address_step                       MAC
#x                                                DEFAULT 0000.0000.0001]
#n       [-no_write                               ANY]
#        [-max_packet_size                        RANGE 576-32832]
#        [-partition_repair                       CHOICES 0 1]
#        [-overloaded                             CHOICES 0 1]
#n       [-override_existence_check               ANY]
#n       [-override_tracking                      ANY]
#x       [-reset                                  FLAG]
#x       [-routing_level                          CHOICES L1 L2 L1L2]
#        [-system_id                              HEX8WITHSPACES]
#x       [-system_id_step                         HEX8WITHSPACES
#x                                                DEFAULT 00:00:00:00:00:01]
#        [-te_enable                              CHOICES 0 1]
#        [-te_router_id                           IP]
#x       [-te_router_id_step                      IP
#x                                                DEFAULT 0.0.0.1]
#        [-te_admin_group                         HEX]
#        [-te_metric                              NUMERIC]
#        [-te_max_bw                              REGEXP ^[0-9]+]
#        [-te_max_resv_bw                         REGEXP ^[0-9]+$]
#        [-te_unresv_bw_priority0                 REGEXP ^[0-9]+$]
#        [-te_unresv_bw_priority1                 REGEXP ^[0-9]+$]
#        [-te_unresv_bw_priority2                 REGEXP ^[0-9]+$]
#        [-te_unresv_bw_priority3                 REGEXP ^[0-9]+$]
#        [-te_unresv_bw_priority4                 REGEXP ^[0-9]+$]
#        [-te_unresv_bw_priority5                 REGEXP ^[0-9]+$]
#        [-te_unresv_bw_priority6                 REGEXP ^[0-9]+$]
#        [-te_unresv_bw_priority7                 REGEXP ^[0-9]+$]
#n       [-type                                   ANY]
#x       [-vlan                                   CHOICES 0 1]
#        [-vlan_id                                RANGE 0-4095]
#        [-vlan_id_mode                           CHOICES fixed increment
#                                                 DEFAULT increment]
#        [-vlan_id_step                           RANGE 0-4096
#                                                 DEFAULT 1]
#        [-vlan_user_priority                     RANGE 0-7
#                                                 DEFAULT 0]
#n       [-vpi                                    ANY]
#n       [-vci                                    ANY]
#n       [-vpi_step                               ANY]
#n       [-vci_step                               ANY]
#        [-wide_metrics                           CHOICES 0 1
#                                                 DEFAULT 0]
#n       [-multi_topology                         ANY]
#x       [-enable_mt_ipv6                         CHOICES 0 1
#x                                                DEFAULT 0]
#x       [-csnp_interval                          NUMERIC]
#x       [-protocol_name                          ALPHA]
#x       [-hello_padding                          CHOICES 0 1]
#        [-router_id                              IPV4
#                                                 DEFAULT 1.1.1.1]
#n       [-router_id_step                         ANY]
#n       [-vlan_cfi                               ANY]
#x       [-ipv6_mt_metric                         NUMERIC]
#x       [-enable3_way_handshake                  CHOICES 0 1]
#x       [-extended_local_circuit_id              NUMERIC]
#n       [-level_type                             ANY]
#x       [-level1_dead_interval                   NUMERIC]
#x       [-level2_dead_interval                   NUMERIC]
#x       [-enable_configured_hold_time            CHOICES 0 1]
#x       [-configured_hold_time                   NUMERIC]
#x       [-auth_type                              CHOICES none password md5]
#x       [-auto_adjust_mtu                        CHOICES 0 1]
#x       [-auto_adjust_area                       CHOICES 0 1]
#x       [-auto_adjust_supported_protocols        CHOICES 0 1]
#x       [-active                                 CHOICES 0 1]
#x       [-max_area_addresses                     NUMERIC]
#x       [-psnp_interval                          NUMERIC]
#x       [-pdu_min_tx_interval                    NUMERIC]
#x       [-ignore_receive_md5                     CHOICES 0 1]
#x       [-pdu_per_burst                          NUMERIC]
#x       [-pdu_burst_gap                          ANY]
#x       [-if_active                              CHOICES 0 1]
#x       [-return_detailed_handles                CHOICES 0 1
#x                                                DEFAULT 0]
#x       [-send_p2p_hellos_to_unicast_mac         CHOICES 0 1]
#x       [-rate_control_interval                  NUMERIC]
#x       [-no_of_lsps_or_mgroup_pdus_per_interval NUMERIC]
#x       [-start_rate_scale_mode                  CHOICES port device_group
#x                                                DEFAULT port]
#x       [-start_rate_enabled                     CHOICES 0 1]
#x       [-start_rate_interval                    NUMERIC]
#x       [-start_rate                             ANY]
#x       [-stop_rate_scale_mode                   CHOICES port device_group
#x                                                DEFAULT port]
#x       [-stop_rate_enabled                      CHOICES 0 1]
#x       [-stop_rate_interval                     NUMERIC]
#x       [-stop_rate                              ANY]
#x       [-traffic_engineering_name               ALPHA]
#x       [-enable_sr                              CHOICES 0 1
#x                                                DEFAULT 0]
#x       [-node_prefix                            IPV4
#x                                                DEFAULT 1.1.1.1]
#x       [-mask                                   RANGE 1-32
#x                                                DEFAULT 32]
#x       [-d_bit                                  CHOICES 0 1
#x                                                DEFAULT 0]
#x       [-s_bit                                  CHOICES 0 1
#x                                                DEFAULT 0]
#x       [-redistribution                         CHOICES up down
#x                                                DEFAULT up]
#x       [-r_flag                                 CHOICES 0 1
#x                                                DEFAULT 0]
#x       [-n_flag                                 CHOICES 0 1
#x                                                DEFAULT 0]
#x       [-p_flag                                 CHOICES 0 1
#x                                                DEFAULT 0]
#x       [-e_flag                                 CHOICES 0 1
#x                                                DEFAULT 0]
#x       [-v_flag                                 CHOICES 0 1
#x                                                DEFAULT 0]
#x       [-l_flag                                 CHOICES 0 1
#x                                                DEFAULT 0]
#x       [-ipv4_flag                              CHOICES 0 1
#x                                                DEFAULT 1]
#x       [-ipv6_flag                              CHOICES 0 1
#x                                                DEFAULT 1]
#x       [-configure_sid_index_label              CHOICES 0 1
#x                                                DEFAULT 1]
#x       [-sid_index_label                        NUMERIC
#x                                                DEFAULT 0]
#x       [-algorithm                              RANGE 0-255
#x                                                DEFAULT 0]
#x       [-srgb_range_count                       RANGE 1-5
#x                                                DEFAULT 1]
#x       [-start_sid_label                        RANGE 1-1048575
#x                                                DEFAULT 16000]
#x       [-sid_count                              RANGE 1-15000
#x                                                DEFAULT 8000]
#x       [-interface_enable_adj_sid               CHOICES 0 1
#x                                                DEFAULT 0]
#x       [-interface_adj_sid                      RANGE 1-1048575
#x                                                DEFAULT 9001]
#x       [-interface_override_f_flag              CHOICES 0 1
#x                                                DEFAULT 0]
#x       [-interface_f_flag                       CHOICES 0 1
#x                                                DEFAULT 0]
#x       [-interface_b_flag                       CHOICES 0 1
#x                                                DEFAULT 0]
#x       [-interface_v_flag                       CHOICES 0 1
#x                                                DEFAULT 1]
#x       [-interface_l_flag                       CHOICES 0 1
#x                                                DEFAULT 0]
#x       [-interface_s_flag                       CHOICES 0 1
#x                                                DEFAULT 0]
#x       [-interface_weight                       RANGE 0-255
#x                                                DEFAULT 0]
#
# Arguments:
#    -mode
#n   -port_handle
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -area_authentication_mode
#        Specifies the area authentication mode.Choices are null, text and
#        md5.
#    -area_password
#        The password used in simple text authentication mode.This is used by
#        L1 routing.
#    -area_id
#        The area address to be used for the ISIS router. A valid value for this parameter
#        is represented by a list of octets written in hexadecimal.
#        Example: "3F 22 11", "23", "44 55 FA"
#x   -area_id_step
#x       The step value used for incrementing the -area_id option.A valid value for this parameter
#x       is represented by a list of octets written in hexadecimal.
#x       Example: "3F 22 11", "23", "44 55 FA"
#n   -atm_encapsulation
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -attach_bit
#        For L2 only.If 1, indicates that the AttachedFlag is set.
#        This indicates that this ISIS router can use L2 routing to reach
#        other areas.
#n   -bfd_registration
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -count
#        The number of ISIS routers to configure on the targeted Ixia
#        interface.The range is 0-1000.
#n   -dce_capability_router_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dce_bcast_root_priority
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dce_num_mcast_dst_trees
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dce_device_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dce_device_pri
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dce_ftag_enable
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dce_ftag
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -enable_host_name
#x   -host_name
#x       Host Name
#    -discard_lsp
#        If 1, discards all LSPs coming from the neighbor which helps
#        scalability.
#    -domain_authentication_mode
#        Specifies the domain authentication mode.Choices are null, text and
#        md5.
#    -domain_password
#        The password used in simple text authentication mode.This is used by
#        L2 routing.
#    -gateway_ip_addr
#        The gateway IP address.
#    -gateway_ip_addr_step
#        The gateway IP address increment value.
#    -gateway_ipv6_addr
#        The gateway IPv6 address.
#    -gateway_ipv6_addr_step
#        The gateway IPv6 address increment value.
#    -graceful_restart
#        If true (1), enable Graceful Restart (NSF) feature on the session
#        router.
#    -graceful_restart_mode
#x   -graceful_restart_version
#x       Specify which draft to use: draft3 draft4.
#    -graceful_restart_restart_time
#        Theamount of time that the router will wait for restart completion.
#    -handle
#        ISIS session handle for using the modes delete, modify, enable and disable.
#        When -handle is provided with the /globals value the arguments that configure global protocol
#        setting accept both multivalue handles and simple values.
#        When -handle is provided with a a protocol stack handle or a protocol session handle, the arguments
#        that configure global settings will only accept simple values. In this situation, these arguments will
#        configure only the settings of the parent device group or the ports associated with the parent topology.
#    -hello_interval
#        The frequency of transmitting L1/L2 Hello PDUs.
#x   -hello_interval_level1
#x       The frequency of transmitting L1 Hello PDUs.
#x   -hello_interval_level2
#x       The frequency of transmitting L2 Hello PDUs.
#n   -hello_password
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -circuit_tranmit_password_md5_key
#        area/domain password.
#n   -interface_handle
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -intf_ip_addr
#        The IP address of the Ixia Simulated ISIS router.If -count is > 1,
#        this IP address will increment by value specified
#        in -intf_ip_addr_step.
#x   -intf_ip_prefix_length
#x       Defines the mask of the IP address used for the Ixia (-intf_ip_addr)
#x       and the DUT interface.The range of the value is 1-32.
#    -intf_ip_addr_step
#        This value will be used for incrementing the IP address of Simulated
#        ISIS router if -count is > 1.
#    -intf_ipv6_addr
#        The IPv6 address of the Ixia Simulated ISIS router.If -count
#        is > 1, this IPv6 address will increment by the value specified
#        in -intf_ipv6_addr_step.
#    -intf_ipv6_prefix_length
#        Defines the mask of the IPv6 address used for the Ixia
#        (-intf_ipv6_addr) and the DUT interface.Valid range is 1-128.
#    -intf_ipv6_addr_step
#        This value will be used for incrementing the IPV6 address of Simulated
#        ISIS router if -count is > 1.
#    -intf_metric
#        The cost metric associated with the route.Valid range is 0-16777215.
#x   -intf_type
#x       Indicates the type of network attached to the interface: broadcast or
#x       ptop.
#n   -ip_version
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -l1_router_priority
#        The session routers priority number for L1 DR role.
#    -l2_router_priority
#        The session routers priority number for L2 DR role.
#n   -loopback_bfd_registration
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -loopback_ip_addr
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -loopback_ip_addr_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -loopback_ip_prefix_length
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -loopback_ip_addr_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -loopback_metric
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -loopback_type
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -loopback_routing_level
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -loopback_l1_router_priority
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -loopback_l2_router_priority
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -loopback_te_metric
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -loopback_te_admin_group
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -loopback_te_max_bw
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -loopback_te_max_resv_bw
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -loopback_te_unresv_bw_priority0
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -loopback_te_unresv_bw_priority1
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -loopback_te_unresv_bw_priority2
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -loopback_te_unresv_bw_priority3
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -loopback_te_unresv_bw_priority4
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -loopback_te_unresv_bw_priority5
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -loopback_te_unresv_bw_priority6
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -loopback_te_unresv_bw_priority7
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -loopback_hello_password
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -lsp_life_time
#        The maximum age in seconds for retaining a learned LSP.
#    -lsp_refresh_interval
#        The rate at which LSPs are resent.Unit is in seconds.
#    -mac_address_init
#        This option defines the MAC address that will be configured on
#        the Ixia interface.If is -count > 1, this MAC address will
#        increment by default by step of 1, or you can specify another step by
#        using mac_address_step option.
#x   -mac_address_step
#x       This option defines the incrementing step for the MAC address that
#x       will be configured on the Ixia interface. Valid only when
#x       IxNetwork Tcl API is used.
#n   -no_write
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -max_packet_size
#        The maximum IS-IS packet size that will be transmitted.Hello packets
#        are also padded to the size.Valid range is 576-32832.
#    -partition_repair
#        If 1, enables the optional partition repair option specified in
#        ISO/IEC 10589 and RFC 1195 for Level 1 areas.
#    -overloaded
#        If 1, the LSP database overload bit is set, indicating that the LSP
#        database on this router does not have enough memory to store a
#        received LSP.
#n   -override_existence_check
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -override_tracking
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -reset
#x       If this option is selected, this will clear any ISIS-L3 router on
#x       the targeted interface.
#x   -routing_level
#x       Selects the supported routing level.
#    -system_id
#        A system ID is typically 6-octet long.
#x   -system_id_step
#x       If -count > 1, this value is used to increment the system_id.
#    -te_enable
#        If true (1), enable traffic engineering extension. If this field is
#        set to true (1) then wide_metrics field gets set to true (1)
#        irrespective of the ip_version value. This behavior is for
#        IxTclProtocol and IxTclNetwork
#    -te_router_id
#        The ID of the TE router, usually the lowest IP address on the router.
#x   -te_router_id_step
#x       The increment used for -te_router_id option.
#    -te_admin_group
#        Administrator Group
#    -te_metric
#        TE Metric Level
#    -te_max_bw
#        The maximum bandwidth to be advertised.
#    -te_max_resv_bw
#        The maximum reservable bandwidth to be advertised.
#    -te_unresv_bw_priority0
#        The unreserved bandwidth for priority 0 to be advertised.
#    -te_unresv_bw_priority1
#        The unreserved bandwidth for priority 1 to be advertised.
#    -te_unresv_bw_priority2
#        The unreserved bandwidth for priority 2 to be advertised.
#    -te_unresv_bw_priority3
#        The unreserved bandwidth for priority 3 to be advertised.
#    -te_unresv_bw_priority4
#        The unreserved bandwidth for priority 4 to be advertised.
#    -te_unresv_bw_priority5
#        The unreserved bandwidth for priority 5 to be advertised.
#    -te_unresv_bw_priority6
#        The unreserved bandwidth for priority 6 to be advertised.
#    -te_unresv_bw_priority7
#        The unreserved bandwidth for priority 7 to be advertised.
#n   -type
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -vlan
#x       Enables vlan on the directly connected ISIS router interface.
#x       Valid options are: 0 - disable, 1 - enable.
#x       This option is valid only when -mode is create or -mode is modify
#x       and -handle is an ISIS router handle.
#    -vlan_id
#        If VLAN is enabled on the Ixia interface, this option will configure
#        the VLAN number.
#    -vlan_id_mode
#        If the user configures more than one interface on the Ixia with
#        VLAN, he can choose to automatically increment the VLAN tag
#        (increment)or leave it idle for each interface (fixed).
#    -vlan_id_step
#        If the -vlan_id_mode is increment, this will be the step value by
#        which the VLAN tags are incremented.
#        When vlan_id_step causes the vlan_id value to exceed it's maximum value the
#        increment will be done modulo <number of possible vlan ids>.
#        Examples: vlan_id = 4094; vlan_id_step = 2-> new vlan_id value = 0
#        vlan_id = 4095; vlan_id_step = 11 -> new vlan_id value = 10
#    -vlan_user_priority
#        VLAN user priority assigned to emulated router node.
#n   -vpi
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vci
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vpi_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vci_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -wide_metrics
#        If true (1), enable wide style metrics. If te_enable is true then
#        wide_metrics also gets set to true (1) irrespective of the
#        ip_version value and cannot be modified to false. This is the
#        behavior in IxTclProtocol and IxTclNetwork.
#        (DEFAULT 0)
#n   -multi_topology
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -enable_mt_ipv6
#x       If true (1), it enables multi-topology (MT) support. If ip_version
#x       is set to 4_6, this field (if not provided by user) gets enabled
#x       (set to true (1)) by default.
#x       (DEFAULT 0)
#x   -csnp_interval
#x       CSNP Interval (ms)
#x   -protocol_name
#x       Protocol name
#x   -hello_padding
#x       Enable Hello Padding
#    -router_id
#        Router capability identifier
#n   -router_id_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vlan_cfi
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -ipv6_mt_metric
#x       IPv6 MT Metric
#x   -enable3_way_handshake
#x       Enable 3-way Handshake
#x   -extended_local_circuit_id
#x       Extended Local Circuit Id
#n   -level_type
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -level1_dead_interval
#x       Level 1 Dead Interval (sec)
#x   -level2_dead_interval
#x       Level 2 Dead Interval (sec)
#x   -enable_configured_hold_time
#x       Enable Configured Hold Time
#x   -configured_hold_time
#x       Configured Hold Time
#x   -auth_type
#x       Authentication Type
#x   -auto_adjust_mtu
#x       Auto Adjust MTU
#x   -auto_adjust_area
#x       Auto Adjust Area
#x   -auto_adjust_supported_protocols
#x       Auto Adjust Supported Protocols
#x   -active
#x       Flag.
#x   -max_area_addresses
#x       Maximum Area Addresses
#x   -psnp_interval
#x       PSNP Interval (ms)
#x   -pdu_min_tx_interval
#x       LSP/MGROUP-PDU Min Transmission Interval (ms)
#x   -ignore_receive_md5
#x       Ignore Receive MD5
#x   -pdu_per_burst
#x       Max LSPs/MGROUP-PDUs Per Burst
#x   -pdu_burst_gap
#x       Inter LSPs/MGROUP-PDUs Burst Gap (ms)
#x   -if_active
#x       Flag.
#x   -return_detailed_handles
#x       This argument determines if individual interface, session or router handles are returned by the current command.
#x       This applies only to the command on which it is specified.
#x       Setting this to 0 means that only NGPF-specific protocol stack handles will be returned. This will significantly
#x       decrease the size of command results and speed up script execution.
#x       The default is 0, meaning only protocol stack handles will be returned.
#x   -send_p2p_hellos_to_unicast_mac
#x       Send P2P Hellos To Unicast MAC
#x   -rate_control_interval
#x       Rate Control Interval (ms)
#x   -no_of_lsps_or_mgroup_pdus_per_interval
#x       LSPs/MGROUP-PDUs per Interval
#x   -start_rate_scale_mode
#x       Indicates whether the control is specified per port or per device group
#x   -start_rate_enabled
#x       Enabled
#x   -start_rate_interval
#x       Time interval used to calculate the rate for triggering an action (rate = count/interval)
#x   -start_rate
#x       Number of times an action is triggered per time interval
#x   -stop_rate_scale_mode
#x       Indicates whether the control is specified per port or per device group
#x   -stop_rate_enabled
#x       Enabled
#x   -stop_rate_interval
#x       Time interval used to calculate the rate for triggering an action (rate = count/interval)
#x   -stop_rate
#x       Number of times an action is triggered per time interval
#x   -traffic_engineering_name
#x       Name of NGPF element, guaranteed to be unique in Scenario
#x   -enable_sr
#x       Enables SR to run on top of ISIS
#x   -node_prefix
#x       Used to uniquely identify the ISIS-L3 SR router
#x   -mask
#x       Mask for the node prefix
#x   -d_bit
#x       When the ISIS router capability TLV is leaked from level-2 to level-1, the D bit must be set, otherwise this bit must be clear
#x   -s_bit
#x       If the S bit is set 1, the ISIS router capability TLV must be flooded across the entire routing domain, otherwise the TLV must not be leaked between levels
#x   -redistribution
#x       It can have any of the two choices- UP or DOWN
#x   -r_flag
#x       Readvertisement flag
#x   -n_flag
#x       Node SID flag
#x   -p_flag
#x       PHP (penultimate hop popping) flag
#x   -e_flag
#x       If the E-flag is set then any upstream neighbor of the Prefix- SID originator MUST replace the PrefixSID with a Prefix-SID having an Explicit-NULL value
#x   -v_flag
#x       Value flag
#x   -l_flag
#x       L flag of ISIS-L3 router
#x   -ipv4_flag
#x       If set, then the router is capable of outgoing IPv4 encapsulation on all interfaces
#x   -ipv6_flag
#x       If set, then the router is capable of outgoing IPv6 encapsulation on all interfaces
#x   -configure_sid_index_label
#x       If enabled, then the nodal SID will not be taken from the SRGB range, rather it will be the value of SID index label
#x   -sid_index_label
#x       This is the value which will be used to set the nodal SID of the ISIS-L3 SR enabled router if configure sid index label option has been enabled
#x   -algorithm
#x       This specifies the algorithm e.g. SPF
#x   -srgb_range_count
#x       How many ranges the user wants to create in the SRGB range. Max is 5
#x   -start_sid_label
#x       Start SID in one SRGB range.
#x   -sid_count
#x       Total count of SIDs in that SRGB range
#x   -interface_enable_adj_sid
#x       Enables adjacent SID for SR enabled ISIS-L3 interface
#x   -interface_adj_sid
#x       Adjacent SID for SR enabled ISIS-L3 interface
#x   -interface_override_f_flag
#x       Override F flag option for SR enabled ISIS-L3 interface
#x   -interface_f_flag
#x       F flag for SR enabled ISIS-L3 interface
#x   -interface_b_flag
#x       B flag for SR enabled ISIS-L3 interface
#x   -interface_v_flag
#x       Value flag for SR enabled ISIS-L3 interface
#x   -interface_l_flag
#x       L flag for SR enabled ISIS-L3 interface
#x   -interface_s_flag
#x       S flag for SR enabled ISIS-L3 interface
#x   -interface_weight
#x       Weight value of the adjacent link for SR enabled ISIS-L3 interface
#
# Return Values:
#    A list containing the isis l3 protocol stack handles that were added by the command (if any).
#x   key:isis_l3_handle          value:A list containing the isis l3 protocol stack handles that were added by the command (if any).
#    A list containing the isis l3 te protocol stack handles that were added by the command (if any).
#x   key:isis_l3_te_handle       value:A list containing the isis l3 te protocol stack handles that were added by the command (if any).
#    A list containing the srgb range  rtr protocol stack handles that were added by the command (if any).
#x   key:srgb_range_handle_rtr   value:A list containing the srgb range  rtr protocol stack handles that were added by the command (if any).
#    A list containing the ethernet protocol stack handles that were added by the command (if any).
#x   key:ethernet_handle         value:A list containing the ethernet protocol stack handles that were added by the command (if any).
#    A list containing the ipv4 protocol stack handles that were added by the command (if any).
#x   key:ipv4_handle             value:A list containing the ipv4 protocol stack handles that were added by the command (if any).
#    A list containing the ipv6 protocol stack handles that were added by the command (if any).
#x   key:ipv6_handle             value:A list containing the ipv6 protocol stack handles that were added by the command (if any).
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:isis_l3_te_handles      value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:srgb_range_handles_rtr  value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:interface_handle        value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    $::SUCCESS | $::FAILURE
#    key:status                  value:$::SUCCESS | $::FAILURE
#    On status of failure, gives detailed information.
#    key:log                     value:On status of failure, gives detailed information.
#    list of router node handles Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    key:handle                  value:list of router node handles Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#
# Examples:
#    See files starting with ISIS_ in the Samples subdirectory.  Also see some of the L3VPN, MPLS, and MVPN sample files for further examples of ISIS usage. See the ISIS example in Appendix A, "Example APIs," for one specific example usage.
#
# Sample Input:
#
# Sample Output:
#    {status $::SUCCESS} {handle {router1 router2 router3 router4}}
#
# Notes:
#    This function does not support the following return values:
#    neighbor.<neighbor_handle>: area_id; system_id; pseudonode_num; intf_ip_addr; intf_ipv6_addr
#    link_local_ipv6_addr
#    link_local_ipv6_prefix_length
#    pseudonode_num
#    The following fields are used in creating a protocol interface.
#    If IxNetwork Tcl Api is used they are applicable only when mode = create.
#    ip_version
#    intf_ip_addr
#    intf_ip_prefix_length
#    intf_ip_addr_step
#    intf_ipv6_addr
#    intf_ipv6_prefix_length
#    intf_ipv6_addr_step
#    vlan
#    vlan_id
#    vlan_id_mode
#    vlan_idstep
#    vlan_user_priority
#    vpi
#    vci
#    vpi_step
#    vci_step
#    gateway_ip_addr      IP
#    gateway_ip_addr_step IP
#    mac_address_init
#    When -handle is provided with the /globals value the arguments that configure global protocol
#    setting accept both multivalue handles and simple values.
#    When -handle is provided with a a protocol stack handle or a protocol session handle, the arguments
#    that configure global settings will only accept simple values. In this situation, these arguments will
#    configure only the settings of the parent device group or the ports associated with the parent topology.
#    Notes:
#    Coded versus functional specification. If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  handle, isis_l3_te_handles, srgb_range_handles_rtr, interface_handle
#
# See Also:
#

proc ::ixiangpf::emulation_isis_config { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "emulation_isis_config" $notImplementedParams $mandatoryParams $fileParams $args]
}
