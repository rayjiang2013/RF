##Procedure Header
# Name:
#    ::ixiangpf::emulation_ospf_config
#
# Description:
#    This procedure will add OSPF router(s) to a particular Ixia Interface.
#    The user can then configure OSPF routes by using the procedure
#    "emulation_ospf_route_config".
#
# Synopsis:
#    ::ixiangpf::emulation_ospf_config
#        [-handle                                               ANY]
#x       [-return_detailed_handles                              CHOICES 0 1
#x                                                              DEFAULT 0]
#        [-area_id                                              IPV4
#                                                               DEFAULT 0.0.0.0]
#        [-area_id_step                                         IPV4]
#x       [-area_id_as_number                                    NUMERIC]
#x       [-area_id_as_number_step                               NUMERIC]
#x       [-area_id_type                                         CHOICES number
#x                                                              CHOICES ip
#x                                                              CHOICES area_id_as_number
#x                                                              CHOICES area_id_as_ip
#x                                                              DEFAULT ip]
#n       [-area_type                                            ANY]
#        [-authentication_mode                                  CHOICES null simple md5]
#        [-count                                                RANGE 1-2000
#                                                               DEFAULT 1]
#        [-dead_interval                                        RANGE 1-65535]
#        [-demand_circuit                                       CHOICES 0 1
#                                                               DEFAULT 0]
#n       [-enable_support_rfc_5838                              ANY]
#        [-graceful_restart_enable                              CHOICES 0 1]
#        [-hello_interval                                       RANGE 1-65535]
#n       [-ignore_db_desc_mtu                                   ANY]
#x       [-router_interface_active                              CHOICES 0 1]
#x       [-enable_fast_hello                                    CHOICES 0 1]
#x       [-hello_multiplier                                     NUMERIC]
#x       [-max_mtu                                              NUMERIC]
#x       [-protocol_name                                        ALPHA]
#x       [-router_active                                        CHOICES 0 1]
#x       [-router_asbr                                          CHOICES 0 1
#x                                                              DEFAULT 0]
#x       [-do_not_generate_router_lsa                           CHOICES 0 1]
#x       [-router_abr                                           CHOICES 0 1
#x                                                              DEFAULT 0]
#x       [-inter_flood_lsupdate_burst_gap                       NUMERIC]
#x       [-lsa_refresh_time                                     NUMERIC]
#x       [-lsa_retransmit_time                                  NUMERIC]
#x       [-max_ls_updates_per_burst                             NUMERIC]
#x       [-oob_resync_breakout                                  CHOICES 0 1]
#        [-interface_cost                                       RANGE 0-4294967295]
#        [-intf_ip_addr                                         IP]
#        [-intf_ip_addr_step                                    IP
#                                                               DEFAULT 0.0.1.0]
#        [-intf_prefix_length                                   RANGE 1-128
#                                                               DEFAULT 24]
#x       [-interface_handle                                     ANY]
#        [-instance_id                                          RANGE 0-255
#                                                               DEFAULT 0]
#        [-instance_id_step                                     RANGE 0-255
#                                                               DEFAULT 0]
#        [-loopback_ip_addr                                     IP
#                                                               DEFAULT 0.0.0.0]
#        [-loopback_ip_addr_step                                IP
#                                                               DEFAULT 0.0.0.0]
#        [-lsa_discard_mode                                     CHOICES 0 1]
#x       [-mac_address_init                                     MAC]
#x       [-mac_address_step                                     MAC
#x                                                              DEFAULT 0000.0000.0001]
#        [-md5_key                                              ALPHA]
#        [-md5_key_id                                           RANGE 0-255]
#        [-mtu                                                  RANGE 68-9216]
#        [-network_type                                         CHOICES broadcast ptomp ptop]
#        [-neighbor_intf_ip_addr                                IP
#                                                               DEFAULT 0.0.0.0]
#        [-neighbor_intf_ip_addr_step                           IP
#                                                               DEFAULT 0.0.0.0]
#        [-neighbor_router_id                                   IPV4]
#        [-neighbor_router_id_step                              IPV4
#                                                               DEFAULT 0.0.1.0]
#        [-option_bits                                          ANY]
#x       [-type_of_service_routing                              CHOICES 0 1]
#x       [-external_capabilities                                CHOICES 0 1]
#x       [-multicast_capability                                 CHOICES 0 1]
#x       [-nssa_capability                                      CHOICES 0 1]
#x       [-external_attribute                                   CHOICES 0 1]
#x       [-opaque_lsa_forwarded                                 CHOICES 0 1]
#x       [-unused                                               CHOICES 0 1]
#x       [-override_existence_check                             CHOICES 0 1
#x                                                              DEFAULT 0]
#x       [-override_tracking                                    CHOICES 0 1
#x                                                              DEFAULT 0]
#        [-password                                             ALPHA]
#x       [-reset                                                FLAG]
#        [-router_id                                            IPV4]
#        [-router_id_step                                       IPV4
#                                                               DEFAULT 0.0.1.0]
#        [-router_priority                                      RANGE 0-255]
#        [-te_enable                                            CHOICES 0 1]
#        [-te_max_bw                                            REGEXP ^[0-9]+]
#        [-te_max_resv_bw                                       REGEXP ^[0-9]+$]
#        [-te_unresv_bw_priority0                               REGEXP ^[0-9]+$]
#        [-te_unresv_bw_priority1                               REGEXP ^[0-9]+$]
#        [-te_unresv_bw_priority2                               REGEXP ^[0-9]+$]
#        [-te_unresv_bw_priority3                               REGEXP ^[0-9]+$]
#        [-te_unresv_bw_priority4                               REGEXP ^[0-9]+$]
#        [-te_unresv_bw_priority5                               REGEXP ^[0-9]+$]
#        [-te_unresv_bw_priority6                               REGEXP ^[0-9]+$]
#        [-te_unresv_bw_priority7                               REGEXP ^[0-9]+$]
#        [-te_metric                                            RANGE 0-2147483647]
#n       [-te_router_id                                         ANY]
#x       [-vlan                                                 CHOICES 0 1]
#        [-vlan_id_mode                                         CHOICES fixed increment
#                                                               DEFAULT increment]
#        [-vlan_id                                              RANGE 0-4096]
#        [-vlan_id_step                                         RANGE 0-4096
#                                                               DEFAULT 1]
#        [-vlan_user_priority                                   RANGE 0-7
#                                                               DEFAULT 0]
#n       [-atm_encapsulation                                    ANY]
#x       [-bfd_registration                                     CHOICES 0 1
#x                                                              DEFAULT 0]
#x       [-enable_dr_bdr                                        CHOICES 0 1
#x                                                              DEFAULT 0]
#n       [-vci                                                  ANY]
#n       [-vci_step                                             ANY]
#n       [-vpi                                                  ANY]
#n       [-vpi_step                                             ANY]
#n       [-get_next_session_mode                                ANY]
#n       [-no_write                                             ANY]
#        [-te_admin_group                                       HEX]
#x       [-validate_received_mtu                                CHOICES 0 1
#x                                                              DEFAULT 1]
#        [-graceful_restart_helper_mode_enable                  CHOICES 0 1
#                                                               DEFAULT 0]
#        [-strict_lsa_checking                                  CHOICES 0 1
#                                                               DEFAULT 1]
#        [-support_reason_sw_restart                            CHOICES 0 1
#                                                               DEFAULT 1]
#        [-support_reason_sw_reload_or_upgrade                  CHOICES 0 1
#                                                               DEFAULT 1]
#        [-support_reason_switch_to_redundant_processor_control CHOICES 0 1
#                                                               DEFAULT 1]
#        [-support_reason_unknown                               CHOICES 0 1
#                                                               DEFAULT 0]
#        [-mode                                                 CHOICES create
#                                                               CHOICES delete
#                                                               CHOICES modify
#                                                               CHOICES enable
#                                                               CHOICES disable
#                                                               DEFAULT create]
#        [-session_type                                         CHOICES ospfv2 ospfv3
#                                                               DEFAULT ospfv2]
#n       [-graceful_restart_restarting_mode_enable              ANY]
#n       [-grace_period                                         ANY]
#n       [-restart_reason                                       ANY]
#n       [-number_of_restarts                                   ANY]
#n       [-restart_start_time                                   ANY]
#n       [-restart_down_time                                    ANY]
#n       [-restart_up_time                                      ANY]
#x       [-port_handle                                          REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
#x       [-rate_control_interval                                NUMERIC]
#x       [-flood_lsupdates_per_interval                         NUMERIC]
#x       [-attempt_scale_mode                                   CHOICES port device_group
#x                                                              DEFAULT port]
#x       [-attempt_rate                                         RANGE 1-10000]
#x       [-attempt_interval                                     NUMERIC]
#x       [-attempt_enabled                                      CHOICES 0 1]
#x       [-disconnect_scale_mode                                CHOICES port device_group
#x                                                              DEFAULT port]
#x       [-disconnect_rate                                      RANGE 1-10000]
#x       [-disconnect_interval                                  NUMERIC]
#x       [-disconnect_enabled                                   CHOICES 0 1]
#n       [-gre_checksum                                         ANY]
#n       [-gre_local_ip                                         ANY]
#n       [-gre_remote_ip                                        ANY]
#n       [-gre_tunnel                                           ANY]
#n       [-host_route                                           ANY]
#n       [-int_msg_exchange                                     ANY]
#n       [-lsa_retransmit_delay                                 ANY]
#n       [-max_lsas_per_pkt                                     ANY]
#n       [-neighbor_dr_eligibility                              ANY]
#n       [-poll_interval                                        ANY]
#n       [-transmit_delay                                       ANY]
#n       [-vlan_cfi                                             ANY]
#x       [-link_metric                                          RANGE 0-4294967295
#x                                                              DEFAULT 0]
#x       [-enable_ignore_db_desc_mtu                            CHOICES 0 1
#x                                                              DEFAULT 0]
#x       [-router_bit                                           CHOICES 0 1
#x                                                              DEFAULT 0]
#x       [-v6                                                   CHOICES 0 1
#x                                                              DEFAULT 0]
#x       [-disable_auto_generate_link_lsa                       ANY]
#x       [-ospfv3_lsa_flood_rate_control                        ANY
#x                                                              DEFAULT 1]
#x       [-intf_ipv6_addr                                       IPV6]
#x       [-intf_ipv6_addr_step                                  IPV6]
#x       [-ipv6_gateway_ip                                      IPV6]
#x       [-ipv6_gateway_ip_step                                 IPV6]
#x       [-intf_ipv6_prefix_length                              RANGE 1-128
#x                                                              DEFAULT 64]
#
# Arguments:
#    -handle
#        OSPF session handle for using the modes delete, modify, enable, and disable.
#        When -handle is provided with the /globals value the arguments that configure global protocol
#        setting accept both multivalue handles and simple values.
#        When -handle is provided with a a protocol stack handle or a protocol session handle, the arguments
#        that configure global settings will only accept simple values. In this situation, these arguments will
#        configure only the settings of the parent device group or the ports associated with the parent topology.
#x   -return_detailed_handles
#x       This argument determines if individual interface, session or router handles are returned by the current command.
#x       This applies only to the command on which it is specified.
#x       Setting this to 0 means that only NGPF-specific protocol stack handles will be returned. This will significantly
#x       decrease the size of command results and speed up script execution.
#x       The default is 0, meaning only protocol stack handles will be returned.
#    -area_id
#        The OSPF area ID associated with the interface.
#    -area_id_step
#        The OSPF area ID step associated with the -area_id option on the ISPF
#        interface.
#x   -area_id_as_number
#x       OSPF Area ID for a non-connected interface, displayed in Integer format
#x   -area_id_as_number_step
#x       OSPF Area ID step for a non-connected interface, displayed in Integer format
#x   -area_id_type
#x       Area ID Type
#n   -area_type
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -authentication_mode
#        This option defines the authentification mode used for OSPF.
#    -count
#        Defines the number of OSPF routers to configure on the -port_handle.
#    -dead_interval
#        The time after which the DUT router is considered dead if it
#        does not send HELLO messages.
#    -demand_circuit
#        Enables the Demand Circuit bit.Pertains to handling of demand
#        circuits (DCs) by the router. CHOICES 0 1
#n   -enable_support_rfc_5838
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -graceful_restart_enable
#        Will enable graceful restart (HA) on the OSPF neighbor.
#    -hello_interval
#        The time between HELLO messages sent over the interface. RANGE 1-65535
#n   -ignore_db_desc_mtu
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -router_interface_active
#x       Enable/disable router interface
#x   -enable_fast_hello
#x       Enable/disable fast hello
#x   -hello_multiplier
#x       Hello multiplier value
#x   -max_mtu
#x       Max mtu value
#x   -protocol_name
#x       Name of the ospf protocol as it should appear in the IxNetwork GUI
#x   -router_active
#x       Enable/disable the ospf router
#x   -router_asbr
#x       If true (1), set router to be an AS boundary router (ASBR).
#x       Correspond to B (Border) bit in router LSA.
#x       This option is valid only when -type is router or grid, otherwise it
#x       is ignored.
#x       This option is available with IxTclNetwork and IxTclProtocol API.
#x   -do_not_generate_router_lsa
#x       Generate/not generate router lsa
#x   -router_abr
#x       If true (1), set router to be an area boundary router (ABR).
#x       Correspond to E (external) bit in router LSA.
#x       This option is valid only when -type is router or grid, otherwise it
#x       is ignored.
#x       This option is available with IxTclNetwork and IxTclProtocol API.
#x   -inter_flood_lsupdate_burst_gap
#x       Inter flood LSUpdate burst gap (ms)
#x   -lsa_refresh_time
#x       LSA refresh time (s)
#x   -lsa_retransmit_time
#x       LSA retransmit time (s)
#x   -max_ls_updates_per_burst
#x       Max flood LSUpdates per burst
#x   -oob_resync_breakout
#x       Enable out-of-band resynchronization breakout
#    -interface_cost
#        The metric associated with the OSPF interface. RANGE 1-65535
#    -intf_ip_addr
#        The IP address of the Ixia Simulated OSPF router. This parameter is
#        not valid on mode modify when IxTclProtocol is used. IP
#    -intf_ip_addr_step
#        What step will be use for incrementing the -intf_ip_addr option.
#        This parameter is not valid on mode modify when IxTclProtocol is used.
#    -intf_prefix_length
#        Defines the mask of the IP address used for the Ixia (-intf_ip_addr)
#        and the DUT interface. This parameter is not valid on mode modify when
#        IxTclProtocol is used. RANGE 1-128
#x   -interface_handle
#x       A handle or list of the handles that are returned from the
#x       interface_config call. These provide a direct link to an already
#x       existing interface and supercede the use of the intf_ip_addr value.
#x       Starting with IxNetwork 5.60 this parameter accepts handles returned by
#x       emulation_dhcp_group_config procedure and pppox_config procedure in the following format:
#x       <DHCP Group Handle>|<interface index X>,<interface index Y>-<interface index Z>, ...
#x       The DHCP ranges are separated from the Interface Index identifiers with the (|) character.
#x       The Interface Index identifiers are separated with comas (,).
#x       A range of Interface Index identifiers can be defined using the dash (-) character.
#x       Ranges along with the Interface Index identifiers are grouped together in TCL Lists. The
#x       lists can contain mixed items, protocol interface handles returned by interface_config
#x       and handles returned by emulation_dhcp_group_config along with the interface index.
#x       Example:
#x       count 10 (10 OSPF routers). 3 DHCP range handles returned by ::ixia::emulation_dhcp_group_config.
#x       Each DHCP range has 20 sessions (interfaces). If we pass 'interface_handle
#x       in the following format: [list $dhcp_r1|1,5 $dhcp_r2|1-3 $dhcp_r3|1,3,5-9,13]
#x       The interfaces will be distributed to the routers in the following manner:
#x       OSPF Router 1: $dhcp_r1 -> interface 1
#x       OSPF Router 2: $dhcp_r1 -> interface 5
#x       OSPF Router 3: $dhcp_r2 -> interface 1
#x       OSPF Router 4: $dhcp_r2 -> interface 2
#x       OSPF Router 5: $dhcp_r2 -> interface 3
#x       OSPF Router 6: $dhcp_r3 -> interface 1
#x       OSPF Router 7: $dhcp_r3 -> interface 3
#x       OSPF Router 8: $dhcp_r3 -> interface 5
#x       OSPF Router 9: $dhcp_r3 -> interface 6
#x       OSPF Router 10: $dhcp_r3 -> interface 7
#x       OSPF Router 11: $dhcp_r3 -> interface 8
#x       OSPF Router 12: $dhcp_r3 -> interface 9
#x       OSPF Router 13 $dhcp_r3 -> interface 13
#x       Valid for mode create for IxTclNetwork only.
#    -instance_id
#        Defines the instance ID of the OSPFv3 process. It allows
#        multiple instances of the OSPFv3 protocol to be run simultaneously
#        over the same link. RANGE 0-255
#    -instance_id_step
#        Step at which the -instance_id will be incremented. RANGE 0-255
#    -loopback_ip_addr
#        Defines the IP address of the loopback interface for MPLS VPN testing.
#        This parameter is not valid on mode modify when IxTclProtocol is used.
#    -loopback_ip_addr_step
#        Defines the IP address step of the loopback interface for MPLS VPN.
#        This parameter is not valid on mode modify when IxTclProtocol is used.
#    -lsa_discard_mode
#        Enables/Disables the LSA discard mode on the OSPF router. CHOICES 0 1
#x   -mac_address_init
#x       This option defines the MAC address that will be configured on
#x       the Ixia interface. This parameter is not valid on mode modify when
#x       IxTclProtocol is used.
#x   -mac_address_step
#x       This option defines the incrementing step for the MAC address that
#x       will be configured on the Ixia interface. This option is valid only
#x       when IxTclNetwork API is used.
#    -md5_key
#        Active only when "MD5" is selected in the Authentication field.
#        Enter a character string (maximum 16 characters) to be used as
#        a "secret" MD5 Key.
#    -md5_key_id
#        Active only when "MD5" is selected in the Authentication field.
#        Enter a value to be used as a Key ID.This identifier is associated
#        with the MD5 Key entered previously.
#    -mtu
#        The advertised MTU value in database entries sent to other routers
#        create on the Ixia interface. RANGE 68-9216.
#        OSPFv2 Only. For OSPFv3 this option is ignored.
#    -network_type
#        Indicates the type of network for the interface.
#    -neighbor_intf_ip_addr
#        The IP address of the DUT OSPF Interface.
#        This parameter is not valid on mode modify when IxTclProtocol is used.
#    -neighbor_intf_ip_addr_step
#        This parameter is not valid on mode modify when IxTclProtocol is used.
#        What step will be use for incrementing the -neighbor_intf_ip_addr option.
#    -neighbor_router_id
#        Available only for use when the Point-Multipoint network type is
#        selected. The DUT IP Interface address can be provided.
#    -neighbor_router_id_step
#        Available only for use when the Point-Multipoint network type is
#        selected. The DUT IP Interface address step can be provided.
#    -option_bits
#        The bit sum of the different OSPF option bits. This switch is for
#        users to customize options since area_type will determine a default
#        value for those bits. The Demand circuit option can be modified with
#        the -demand_circuit option. In HEX.
#        If (option_bits & 0x8) then area_id must not be 0.
#        (option_bits & 0x2) is not allowed - can't have external routing and NSSA capability at the same time.
#x   -type_of_service_routing
#x       Option bit 0
#x   -external_capabilities
#x       Option bit 1
#x   -multicast_capability
#x       Option bit 2
#x   -nssa_capability
#x       Option bit 3
#x   -external_attribute
#x       Option bit 4
#x   -opaque_lsa_forwarded
#x       Option bit 6
#x   -unused
#x       Option bit 7
#x   -override_existence_check
#x       If this option is enabled, the interface existence check is skipped but
#x       the list of interfaces is still created and maintained in order to keep
#x       track of existing interfaces if required. Using this option will speed
#x       up the interfaces' creation.
#x   -override_tracking
#x       If this option is enabled, the list of interfaces won't be created and
#x       maintained anymore, thus, speeding up the interfaces' creation even
#x       more. Also, it will enable -override_existence_check in case it wasn't
#x       already enabled because checking for interface existence becomes
#x       impossible if the the list of interfaces doesn't exist anymore.
#    -password
#        Password to be used in the OSPF authentication mode is enabled and
#        set to "simple".
#x   -reset
#x       If this option is selected, this will clear any OSPF router on
#x       the targeted interface.
#    -router_id
#        The Router ID for this emulated OSPF Router, in IPv4 format. IP
#    -router_id_step
#        The Router ID step for this emulated OSPF Router, in IPv4 format. IP
#    -router_priority
#        The priority of the interface, for use in election of the designated or
#        backup master. RANGE 0-255
#    -te_enable
#        If set to 1, this will enable Traffic Engineering on the OSPF router.
#        The user can then configure the TE parameters by using "-te_metric",
#        "-te_max_bw", "-te_max_resv_bw", "-te_unresv_bw_priority0-7".
#    -te_max_bw
#        If "-te_enable" is 1, then this indicates the maximum bandwidth
#        that can be used on the link between this interface and its
#        neighbors in the outbound direction.
#    -te_max_resv_bw
#        If "-te_enable" is 1, then this indicates the maximum bandwidth,
#        in bytes per second, that can be reserved on the link between
#        this interface and its neighbors in the outbound direction.
#    -te_unresv_bw_priority0
#        If "-te_enable" is 1, then this value indicates the amount of bandwidth,
#        in bytes per second, not yet reserved at the 0 priority level. This
#        value corresponds to the bandwidth that can be reserved with a setup
#        priority of 0. The value must be less than the maxReservableBandwidth
#        option.
#    -te_unresv_bw_priority1
#        If "-te_enable" is 1, then this value indicates the amount of bandwidth,
#        in bytes per second, not yet reserved at the 1 priority level. This
#        value corresponds to the bandwidth that can be reserved with a setup
#        priority of 1. The value must be less than the maxReservableBandwidth
#        option.
#    -te_unresv_bw_priority2
#        If "-te_enable" is 1, then this value indicates the amount of bandwidth,
#        in bytes per second, not yet reserved at the 2 priority level. This
#        value corresponds to the bandwidth that can be reserved with a setup
#        priority of 2. The value must be less than the maxReservableBandwidth
#        option.
#    -te_unresv_bw_priority3
#        If "-te_enable" is 1, then this value indicates the amount of bandwidth,
#        in bytes per second, not yet reserved at the 3 priority level. This
#        value corresponds to the bandwidth that can be reserved with a setup
#        priority of 3. The value must be less than the maxReservableBandwidth
#        option.
#    -te_unresv_bw_priority4
#        If "-te_enable" is 1, then this value indicates the amount of bandwidth,
#        in bytes per second, not yet reserved at the 4 priority level.This
#        value corresponds to the bandwidth that can be reserved with a setup
#        priority of 4.The value must be less than the maxReservableBandwidth
#        option.
#    -te_unresv_bw_priority5
#        If "-te_enable" is 1, then this value indicates the amount of bandwidth,
#        in bytes per second, not yet reserved at the 5 priority level. This
#        value corresponds to the bandwidth that can be reserved with a setup
#        priority of 5. The value must be less than the maxReservableBandwidth
#        option.
#    -te_unresv_bw_priority6
#        If "-te_enable" is 1, then this value indicates the amount of bandwidth,
#        in bytes per second, not yet reserved at the 6 priority level. This
#        value corresponds to the bandwidth that can be reserved with a setup
#        priority of 6. The value must be less than the maxReservableBandwidth
#        option.
#    -te_unresv_bw_priority7
#        If "-te_enable" is 1, then this value indicates the amount of bandwidth,
#        in bytes per second, not yet reserved at the 7 priority level. This
#        value corresponds to the bandwidth that can be reserved with a setup
#        priority of 7. The value must be less than the maxReservableBandwidth
#        option.
#    -te_metric
#        If set to 1, then this indicates the traffic engineering metric
#        associated with the interface. RANGE 1-2147483647
#n   -te_router_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -vlan
#x       Enables vlan on the directly connected OSPF router interface.
#x       Valid options are: 0 - disable, 1 - enable.
#x       This option is valid only when -mode is create or -mode is modify
#x       and -handle is a OSPF router handle.
#x       This option is available only when IxNetwork tcl API is used.
#    -vlan_id_mode
#        If the user configures more than one interface on the Ixia with
#        VLAN, he can choose to automatically increment the VLAN tag or
#        leave it idle for each interface. CHOICES fixed increment.
#        This parameter is not valid on mode modify when IxTclProtocol is used.
#    -vlan_id
#        If VLAN is enable on the Ixia interface, this option will configure
#        the VLAN number. This parameter is not valid on mode modify when
#        IxTclProtocol is used. RANGE 0-4095
#    -vlan_id_step
#        This parameter is not valid on mode modify when IxTclProtocol is used.
#        If the -vlan_id_mode is increment, this will be the step value by
#        which the VLAN tags are incremented. RANGE 0-4095
#        When vlan_id_step causes the vlan_id value to exceed it's maximum value the
#        increment will be done modulo <number of possible vlan ids>.
#        Examples: vlan_id = 4094; vlan_id_step = 2-> new vlan_id value = 0
#        vlan_id = 4095; vlan_id_step = 11 -> new vlan_id value = 10
#    -vlan_user_priority
#        This parameter is not valid on mode modify when IxTclProtocol is used.
#n   -atm_encapsulation
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -bfd_registration
#x       Enable or disable BFD registration.
#x   -enable_dr_bdr
#x       If 1, enables the OSPF Designated Router/Backup Designated Router
#x       DR/BDR) feature for all router interfaces on this port.
#n   -vci
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vci_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vpi
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vpi_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -get_next_session_mode
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -no_write
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -te_admin_group
#        Assignment of traffic engineering administrative group numbers to the interface.
#        Valid only with IxTclNetwork API.
#x   -validate_received_mtu
#x       Enabling this option means that the MTU will be verified during the DB exchange.
#x       This is only available for OSPFv2 interfaces that are directly connected to the DUT.
#    -graceful_restart_helper_mode_enable
#        This parameter -graceful_restart_helper_mode_enable will allow Ixia to
#        act as a helping neighbor to a restarting router.If the attribute is
#        set to 1, the router will act as restarting router's neighbors, which must
#        cooperate in order for the restart to be graceful.This attribute/argument
#        is valid when session_type is ospfV3.
#        Valid choices are:
#        0 - disable (default)
#        1 - enable
#    -strict_lsa_checking
#        If enabled, the helping router continues to help the restarting router even if there is a
#        topology change detected. Relevant with 'graceful_restart_helper_mode_enable'.
#        This attribute is associated with the four Graceful Restart reasons. This attribute/argument
#        is valid when session_type is ospfV3.
#    -support_reason_sw_restart
#        This is one of the reasons supported by this helping router when the neighboring router
#        gracefully restarts. Helping router will support only those restart reasons which are
#        enabled by the user. User can select more than one reason at a time. Relevant with
#        'graceful_restart_helper_mode_enable'.This attribute/argument is valid when session_type is ospfV3.
#    -support_reason_sw_reload_or_upgrade
#        This is one of the reasons supported by this helping router when the neighboring router gracefully restarts.
#        Helping router will support only those restart reasons which are enabled by the user. User can
#        select more than one reason at a time. Relevant with 'graceful_restart_helper_mode_enable'.
#        This attribute/argument is valid when session_type is ospfV3.
#    -support_reason_switch_to_redundant_processor_control
#        This is one of the reasons supported by this helping router when the neighboring router gracefully restarts.
#        Helping router will support only those restart reasons which are enabled by the user. User can
#        select more than one reason at a time. Relevant with 'graceful_restart_helper_mode_enable'.
#        This attribute/argument is valid when session_type is ospfV3.
#    -support_reason_unknown
#        This is one of the reasons supported by this helping router when the neighboring router gracefully restarts.
#        Helping router will support only those restart reasons which are enabled by the user. User can
#        select more than one reason at a time. Relevant with 'graceful_restart_helper_mode_enable'.
#        This attribute/argument is valid when session_type is ospfV3.
#    -mode
#    -session_type
#        The OSPF version to be emulated. CHOICES: ospfv2 ospfv3.
#n   -graceful_restart_restarting_mode_enable
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -grace_period
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -restart_reason
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -number_of_restarts
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -restart_start_time
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -restart_down_time
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -restart_up_time
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -port_handle
#x       Ixia interface upon which to act.
#x   -rate_control_interval
#x       Flood link state updates per interval.
#x   -flood_lsupdates_per_interval
#x       Flood link state updates per interval.
#x   -attempt_scale_mode
#x       Indicates whether the control is specified per port or per device group.
#x       This setting is global for all the ospf protocols configured in the ixncfg
#x       and can be configured just when handle is /globals (when the user wants to configure just the global settings)
#x   -attempt_rate
#x       Number of times an action is triggered per second.
#x   -attempt_interval
#x       Time interval used to calculate the rate for triggering an action(rate = count/interval).
#x   -attempt_enabled
#x   -disconnect_scale_mode
#x       Indicates whether the control is specified per port or per device group.
#x       This setting is global for all the ospf protocols configured in the ixncfg
#x       and can be configured just when handle is /globals (when the user wants to configure just the global settings)
#x   -disconnect_rate
#x       Number of times an action is triggered per second.
#x   -disconnect_interval
#x       Time interval used to calculate the rate for triggering an action(rate = count/interval).
#x   -disconnect_enabled
#n   -gre_checksum
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_local_ip
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_remote_ip
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_tunnel
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -host_route
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -int_msg_exchange
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -lsa_retransmit_delay
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -max_lsas_per_pkt
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -neighbor_dr_eligibility
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -poll_interval
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -transmit_delay
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vlan_cfi
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -link_metric
#x       Link Metric
#x   -enable_ignore_db_desc_mtu
#x       Ignore DB-Desc MTU
#x   -router_bit
#x       Option bit 4
#x   -v6
#x       Option bit 0
#x   -disable_auto_generate_link_lsa
#x       Support graceful restart helper mode when restart reason is unknown and unplanned.
#x   -ospfv3_lsa_flood_rate_control
#x       Inter Flood LSUpdate burst gap (ms)
#x   -intf_ipv6_addr
#x       IPv6 addresses of the layer
#x   -intf_ipv6_addr_step
#x   -ipv6_gateway_ip
#x       gateways of the layer
#x   -ipv6_gateway_ip_step
#x   -intf_ipv6_prefix_length
#x       Defines the mask of the IP address used for the Ixia (-intf_ipv6_addr)
#x       and the DUT interface. This parameter is not valid on mode modify when
#x       IxTclProtocol is used. RANGE 1-128
#
# Return Values:
#    A list containing the ethernet protocol stack handles that were added by the command (if any).
#x   key:ethernet_handle  value:A list containing the ethernet protocol stack handles that were added by the command (if any).
#    A list containing the ipv4 protocol stack handles that were added by the command (if any).
#x   key:ipv4_handle      value:A list containing the ipv4 protocol stack handles that were added by the command (if any).
#    A list containing the ospfv2 protocol stack handles that were added by the command (if any).
#x   key:ospfv2_handle    value:A list containing the ospfv2 protocol stack handles that were added by the command (if any).
#    A list containing the ipv6 protocol stack handles that were added by the command (if any).
#x   key:ipv6_handle      value:A list containing the ipv6 protocol stack handles that were added by the command (if any).
#    A list containing the ospfv3 protocol stack handles that were added by the command (if any).
#x   key:ospfv3_handle    value:A list containing the ospfv3 protocol stack handles that were added by the command (if any).
#    $::SUCCESS or $::FAILURE
#    key:status           value:$::SUCCESS or $::FAILURE
#    If failure, will contain more information
#    key:log              value:If failure, will contain more information
#    The router numbers Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    key:handle           value:The router numbers Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    1) Coded versus functional specification.
#    2) When -handle is provided with the /globals value the arguments that configure global protocol
#    setting accept both multivalue handles and simple values.
#    When -handle is provided with a a protocol stack handle or a protocol session handle, the arguments
#    that configure global settings will only accept simple values. In this situation, these arguments will
#    configure only the settings of the parent device group or the ports associated with the parent topology.
#    If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  handle
#
# See Also:
#

proc ::ixiangpf::emulation_ospf_config { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "emulation_ospf_config" $notImplementedParams $mandatoryParams $fileParams $args]
}
