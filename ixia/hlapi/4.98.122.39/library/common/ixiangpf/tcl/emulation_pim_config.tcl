##Procedure Header
# Name:
#    ::ixiangpf::emulation_pim_config
#
# Description:
#    This procedure will configure PIM SM interface.
#
# Synopsis:
#    ::ixiangpf::emulation_pim_config
#n       [-port_handle                ANY]
#        -mode                        CHOICES create
#                                     CHOICES modify
#                                     CHOICES delete
#                                     CHOICES disable
#                                     CHOICES enable
#                                     DEFAULT create
#        [-handle                     ANY]
#n       [-interface_handle           ANY]
#x       [-return_detailed_handles    CHOICES 0 1
#x                                    DEFAULT 0]
#        [-pim_mode                   CHOICES sm ssm
#                                     DEFAULT sm]
#        [-type                       CHOICES remote_rp]
#        -ip_version                  CHOICES 4 6
#                                     DEFAULT 4
#x       [-bootstrap_enable           CHOICES 0 1
#x                                    DEFAULT 0]
#x       [-bootstrap_support_unicast  CHOICES 0 1
#x                                    DEFAULT 1]
#x       [-bootstrap_hash_mask_len    RANGE 0-128]
#x       [-bootstrap_interval         RANGE 0-65535
#x                                    DEFAULT 60]
#x       [-bootstrap_priority         RANGE 0-255
#x                                    DEFAULT 64]
#x       [-bootstrap_timeout          RANGE 0-65535
#x                                    DEFAULT 130]
#        [-count                      NUMERIC
#                                     DEFAULT 1]
#        [-intf_ip_addr               IP]
#        [-intf_ip_addr_step          IP
#                                     DEFAULT 0.0.1.0]
#x       [-intf_ip_prefix_length      RANGE 1-128]
#        [-intf_ip_prefix_len         RANGE 1-128]
#        [-learn_selected_rp_set      CHOICES 0 1
#                                     DEFAULT 1]
#        [-discard_learnt_rp_info     CHOICES 0 1
#                                     DEFAULT 0]
#        [-router_id                  IP]
#        [-router_id_step             IP]
#x       [-gateway_intf_ip_addr       IP]
#x       [-gateway_intf_ip_addr_step  IP]
#x       [-auto_pick_neighbor         CHOICES 0 1]
#        [-neighbor_intf_ip_addr      IP]
#        [-neighbor_intf_ip_addr_step IP]
#        [-dr_priority                NUMERIC
#                                     DEFAULT 0]
#        [-bidir_capable              CHOICES 0 1
#                                     DEFAULT 0]
#        [-hello_interval             NUMERIC
#                                     DEFAULT 30]
#        [-hello_holdtime             NUMERIC
#                                     DEFAULT 105]
#        [-join_prune_interval        NUMERIC
#                                     DEFAULT 60]
#        [-join_prune_holdtime        NUMERIC
#                                     DEFAULT 180]
#        [-prune_delay_enable         CHOICES 0 1
#                                     DEFAULT 0]
#        [-prune_delay                RANGE 100-32767
#                                     DEFAULT 500]
#        [-override_interval          RANGE 100-65535
#                                     DEFAULT 2500]
#        [-vlan_id                    RANGE 0-4096]
#        [-vlan_id_mode               CHOICES fixed increment
#                                     DEFAULT increment]
#        [-vlan_id_step               RANGE 0-4096
#                                     DEFAULT 1]
#        [-vlan_user_priority         RANGE 0-7
#                                     DEFAULT 0]
#x       [-reset                      ANY]
#x       [-generation_id_mode         CHOICES increment random constant]
#x       [-prune_delay_tbit           CHOICES 0 1]
#x       [-send_generation_id         CHOICES 0 1]
#x       [-mac_address_init           MAC]
#x       [-mac_address_step           MAC
#x                                    DEFAULT 0000.0000.0001]
#x       [-vlan                       CHOICES 0 1]
#x       [-interface_name             ALPHA]
#x       [-interface_active           CHOICES 0 1]
#x       [-triggered_hello_delay      NUMERIC
#x                                    DEFAULT 5]
#x       [-disable_triggered_hello    CHOICES 0 1]
#x       [-force_semantic             CHOICES 0 1]
#x       [-router_active              CHOICES 0 1]
#x       [-router_name                ALPHA]
#x       [-join_prunes_count          RANGE 0-255
#x                                    DEFAULT 0]
#x       [-sources_count              RANGE 0-255
#x                                    DEFAULT 0]
#x       [-crp_ranges_count           RANGE 0-255
#x                                    DEFAULT 0]
#n       [-writeFlag                  ANY]
#n       [-no_write                   ANY]
#n       [-gre                        ANY]
#n       [-gre_enable                 ANY]
#n       [-gre_unique                 ANY]
#n       [-gre_dst_ip_addr            ANY]
#n       [-gre_count                  ANY]
#n       [-gre_ip_addr                ANY]
#n       [-gre_ip_addr_step           ANY]
#n       [-gre_ip_addr_lstep          ANY]
#n       [-gre_ip_addr_cstep          ANY]
#n       [-gre_ip_prefix_length       ANY]
#n       [-gre_dst_ip_addr_step       ANY]
#n       [-gre_dst_ip_addr_lstep      ANY]
#n       [-gre_dst_ip_addr_cstep      ANY]
#n       [-gre_key_in_step            ANY]
#n       [-gre_key_out_step           ANY]
#n       [-gre_src_ip_addr_mode       ANY]
#n       [-gre_seq_enable             ANY]
#x       [-loopback_count             NUMERIC
#x                                    DEFAULT 0]
#x       [-loopback_ip_address        IP]
#x       [-loopback_ip_address_step   IP]
#n       [-loopback_ip_address_cstep  ANY]
#n       [-vlan_cfi                   ANY]
#n       [-mvpn_enable                ANY]
#n       [-mvpn_pe_count              ANY]
#n       [-mvpn_pe_ip                 ANY]
#n       [-mvpn_pe_ip_incr            ANY]
#n       [-mvrf_count                 ANY]
#n       [-mvrf_unique                ANY]
#n       [-default_mdt_ip             ANY]
#n       [-default_mdt_ip_incr        ANY]
#n       [-gre_checksum_enable        ANY]
#n       [-gre_key_enable             ANY]
#n       [-gre_key_in                 ANY]
#n       [-gre_key_out                ANY]
#n       [-bs_period                  ANY]
#n       [-c_bsr_addr                 ANY]
#n       [-c_bsr_adv                  ANY]
#n       [-c_bsr_group_addr           ANY]
#n       [-c_bsr_group_admin          ANY]
#n       [-c_bsr_group_bidir          ANY]
#n       [-c_bsr_group_prefix_len     ANY]
#n       [-c_bsr_priority             ANY]
#n       [-c_bsr_rp_addr              ANY]
#n       [-c_bsr_rp_handle            ANY]
#n       [-c_bsr_rp_holdtime          ANY]
#n       [-c_bsr_rp_mode              ANY]
#n       [-c_bsr_rp_priority          ANY]
#n       [-c_rp_addr                  ANY]
#n       [-c_rp_adv                   ANY]
#n       [-c_rp_adv_holdtime          ANY]
#n       [-c_rp_adv_interval          ANY]
#n       [-c_rp_bsr_addr              ANY]
#n       [-c_rp_group_addr            ANY]
#n       [-c_rp_group_admin           ANY]
#n       [-c_rp_group_bidir           ANY]
#n       [-c_rp_group_handle          ANY]
#n       [-c_rp_group_mode            ANY]
#n       [-c_rp_group_prefix_len      ANY]
#n       [-c_rp_priority              ANY]
#n       [-hello_max_delay            ANY]
#n       [-keepalive_period           ANY]
#n       [-register_probe_time        ANY]
#n       [-register_suppression_time  ANY]
#
# Arguments:
#n   -port_handle
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -mode
#        This option defines the action to be taken.Limitations: for modify
#        mode, the following options cannot be changed: router_id, dr_priority,
#        join_prune_holdtime, and join_prune_interval. Valid options are:
#        create (DEFAULT)
#        modify
#        delete
#        disable
#        enable
#    -handle
#        PIM-SM handle if the option -mode is not create.
#n   -interface_handle
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -return_detailed_handles
#x       This argument determines if individual interface, session or router handles are returned by the current command.
#x       This applies only to the command on which it is specified.
#x       Setting this to 0 means that only NGPF-specific protocol stack handles will be returned. This will significantly
#x       decrease the size of command results and speed up script execution.
#x       The default is 0, meaning only protocol stack handles will be returned.
#    -pim_mode
#        Supports SM (sparse mode) and SSM (source spefic multicast).
#        (DEFAULT = sm)
#    -type
#        Type of the PIM session router.Supports remote_rp type only.
#        c_rp and c_bsr types are not supported.
#    -ip_version
#        The IP version of the interface.Choices are:4, 6
#        (DEFAULT = 4)
#x   -bootstrap_enable
#x       If 1, enables the PIM-SM interface to participate in Bootstrap
#x       Router election procedure.
#x       Valid choices are:
#x       0 - disable
#x       1 - enable
#x       (DEFAULT = 0)
#x   -bootstrap_support_unicast
#x       If 1, enables support for unicast trasmission in Bootstrap procedure.
#x       Valid choices are:
#x       0 - disable
#x       1 - enable
#x       (DEFAULT = 1)
#x   -bootstrap_hash_mask_len
#x       Hash Mask Length of the Bootstrap Router (BSR) that is set with
#x       the same name in all Bootstrap Messages sent by this BSR.
#x   -bootstrap_interval
#x       The time interval (in seconds) between two consecutive bootstrap
#x       messages sent by the BSR.
#x       (DEFAULT = 60)
#x   -bootstrap_priority
#x       Priority of the Bootstrap Router (BSR) that is set with the same
#x       name in all Bootstrap Messages sent by this BSR.
#x       (DEFAULT = 64)
#x   -bootstrap_timeout
#x       Amount of time (in seconds) of not receiving any Bootstrap Messages,
#x       after which the BSR if candidate at that point of time will decide that
#x       the currently elected BSR has gone down and will restart BSR election procedure.
#x       (DEFAULT = 130)
#    -count
#        Number of PIM-SM sessions to create on the interface.
#        If this parameter is 1 then the default behaviour of this function is to create a router
#        and add the <interface_handle> interfaces to it. In this case the following parameters may be lists:
#        interface_handle
#        ip_version
#        generation_id_mode
#        hello_holdtime
#        hello_interval
#        prune_delay
#        prune_delay_tbit
#        override_interval
#        bidir_capable
#        send_generation_id
#        prune_delay_enable
#        neighbor_intf_ip_addr
#        bootstrap_support_unicast
#        bootstrap_enable
#        bootstrap_hash_mask_len
#        bootstrap_interval
#        bootstrap_priority
#        bootstrap_timeout
#        (only IxTclNetwork api)
#        (DEFAULT = 1)
#    -intf_ip_addr
#        The interface IP address.
#    -intf_ip_addr_step
#        The interface IP address octet to be incremented by given step.
#x   -intf_ip_prefix_length
#x       The prefix length on the interface (DEFAULT = 24).
#x       NOTE: This value is being maintained for backwards compatibility
#x       and shouldn't be used going forward.
#x       Please use the -intf_ip_prefix_len value.
#    -intf_ip_prefix_len
#        The prefix length on the interface.
#        (DEFAULT = 24)
#    -learn_selected_rp_set
#        Enable learning of elected BSR and Candidate RPs.
#        (DEFAULT = 1)
#    -discard_learnt_rp_info
#        Discard the learnt BSR and Candidate RP info.
#        (DEFAULT = 0)
#    -router_id
#        The ID of the router in IPv4 format.
#        (DEFAULT = 0.0.0.1)
#    -router_id_step
#        The value use to increment the router_id when count > 1.
#        (DEFAULT = 0.0.0.1)
#x   -gateway_intf_ip_addr
#x       The gateway IP address of the port interface.
#x       (DEFAULT = 0.0.0.0)
#x   -gateway_intf_ip_addr_step
#x       The gateway IP address octet to be incremented by given step.
#x       (DEFAULT = 0.0.0.1)
#x   -auto_pick_neighbor
#x       Auto pick Neighbor
#    -neighbor_intf_ip_addr
#        The interface IP address of PIM-SM neighbor (next hop).
#        (DEFAULT = 0.0.0.0)
#    -neighbor_intf_ip_addr_step
#        The interface IP address step for the PIM-SM neighbor.
#        (DEFAULT = 0.0.0.0)
#    -dr_priority
#        The Designated Router (DR) priority assigned to this simulated router.
#        (DEFAULT = 0)
#    -bidir_capable
#        If true (1), enable bi-directional PIM.
#        (DEFAULT = 0)
#    -hello_interval
#        Hello interval in seconds.
#        (DEFAULT = 30)
#    -hello_holdtime
#        The length of time, in seconds, between the transmission of Hello
#        messages.
#        (DEFAULT = 105)
#    -join_prune_interval
#        The length of time, in seconds, between transmission of Join/Prune
#        messages.Also called t_periodic in RFCs.
#        (DEFAULT = 60)
#    -join_prune_holdtime
#        The period, in seconds, during which a router receiving a Join/Prune
#        must keep the state alive.The default is 3 times the Join/Prune
#        interval.If this value is 65536 (0xffff), then the timeout is
#        infinite and if this value isi 0, the timeout is immediate.
#        (DEFAULT = 180)
#    -prune_delay_enable
#        If true (1), the LAN prune propagation delay is enabled for this
#        interface.
#        (DEFAULT = 0)
#    -prune_delay
#        The value, in milliseconds, of the LAN prune propagation delay for this
#        interface.It indicates to an upstream router how long to wait for
#        a Join override message before it prunes an interface.
#        (DEFAULT = 500)
#    -override_interval
#        The delay interval, in milliseconds, for randomizing the transmission
#        time for override messages, which are used when scheduling a delayed
#        Join message.
#        (DEFAULT = 2500)
#    -vlan_id
#        If VLAN is enable on the Ixia interface, this option will configure
#        the VLAN number. RANGE 0-4095.
#        (DEFAULT = 100)
#    -vlan_id_mode
#        If the user configures more than one interface on the Ixia with
#        VLAN, he can choose to automatically increment the VLAN tag or
#        leave it idle for each interface.
#        (DEFAULT = increment)
#    -vlan_id_step
#        If the -vlan_id_mode is increment, this will be the step value by
#        which the VLAN tags are incremented. RANGE 0-4095
#        When vlan_id_step causes the vlan_id value to exceed it's maximum value the
#        increment will be done modulo <number of possible vlan ids>.
#        Examples: vlan_id = 4094; vlan_id_step = 2-> new vlan_id value = 0
#        vlan_id = 4095; vlan_id_step = 11 -> new vlan_id value = 10
#        (DEFAULT = 1)
#    -vlan_user_priority
#        VLAN user priority assigned to emulated router node.RANGE 0-7
#        (DEFAULT = 0)
#x   -reset
#x       If this option is present, all the Pim Interface and router in the given device group are
#x       deleted.
#x   -generation_id_mode
#x       The mode used for creating the 32-bit value for the Generation
#x       Identifier (GenID) option in Hello messages.Valid options are:
#x       increment
#x       random
#x       constant
#x   -prune_delay_tbit
#x       If true (1), the T flag bit in the LAN Prune Delay option of the
#x       Hello message is set (= 1). Setting this bit specifies that the
#x       sending PIM-SM router has the ability to disable Join message
#x       suppression.
#x   -send_generation_id
#x       If true (1), the generation ID is included in Hello messages.
#x   -mac_address_init
#x       The MAC address of the directly connected interface.
#x   -mac_address_step
#x       The incrementing step for the MAC address of the interface.
#x       Valid only when IxNetwork Tcl API is used.
#x       (DEFAULT = 0000.0000.0001)
#x   -vlan
#x       Enables vlan on the directly connected PIM router interface.
#x       Valid options are: 0 - disable, 1 - enable.
#x       This option is valid only when -mode is create or -mode is modify
#x       and -handle is a PIM router handle.
#x       This option is available only when IxNetwork tcl API is used.
#x       (DEFAULT = 0)
#x   -interface_name
#x       Name of Pim interface stack in the scenario.
#x   -interface_active
#x       Flag.
#x   -triggered_hello_delay
#x       Triggered Hello Delay (sec)
#x   -disable_triggered_hello
#x       Disable Triggered
#x   -force_semantic
#x       Force Semantic
#x   -router_active
#x       Flag.
#x   -router_name
#x       Name of Pim Router stack in the scenario.
#x   -join_prunes_count
#x       Number of Join/Prunes
#x   -sources_count
#x       Number of Sources
#x   -crp_ranges_count
#x       Number of C-RP Ranges
#n   -writeFlag
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -no_write
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_enable
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_unique
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_dst_ip_addr
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_ip_addr
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_ip_addr_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_ip_addr_lstep
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_ip_addr_cstep
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_ip_prefix_length
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_dst_ip_addr_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_dst_ip_addr_lstep
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_dst_ip_addr_cstep
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_key_in_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_key_out_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_src_ip_addr_mode
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_seq_enable
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -loopback_count
#x       If this parameter is > 0 and gre_enable is '0' the router interfaces will be
#x       the loopback protocol interfaces. The number of loopback interfaces will be
#x       count * loopback_count.
#x       Valid only when:
#x       IxTclProtocols HLTSET and
#x       loopback_count > 0 and
#x       mode create and
#x       mvpn_enable 0 and
#x       interface_handle missing.
#x   -loopback_ip_address
#x       Valid only when:
#x       IxTclProtocols HLTSET and
#x       loopback_count > 0 and
#x       mode create and
#x       mvpn_enable 0 and
#x       interface_handle missing.
#x   -loopback_ip_address_step
#x       The step used to increment the 'loopback_ip_address' when moving from one loopback
#x       interface to the next.
#x       Valid only when:
#x       IxTclProtocols HLTSET and
#x       loopback_count > 1 and
#x       mode create and
#x       mvpn_enable 0 and
#x       interface_handle missing.
#n   -loopback_ip_address_cstep
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vlan_cfi
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -mvpn_enable
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -mvpn_pe_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -mvpn_pe_ip
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -mvpn_pe_ip_incr
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -mvrf_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -mvrf_unique
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -default_mdt_ip
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -default_mdt_ip_incr
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_checksum_enable
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_key_enable
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_key_in
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -gre_key_out
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -bs_period
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_bsr_addr
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_bsr_adv
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_bsr_group_addr
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_bsr_group_admin
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_bsr_group_bidir
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_bsr_group_prefix_len
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_bsr_priority
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_bsr_rp_addr
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_bsr_rp_handle
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_bsr_rp_holdtime
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_bsr_rp_mode
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_bsr_rp_priority
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_rp_addr
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_rp_adv
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_rp_adv_holdtime
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_rp_adv_interval
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_rp_bsr_addr
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_rp_group_addr
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_rp_group_admin
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_rp_group_bidir
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_rp_group_handle
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_rp_group_mode
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_rp_group_prefix_len
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -c_rp_priority
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -hello_max_delay
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -keepalive_period
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -register_probe_time
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -register_suppression_time
#n       This argument defined by Cisco is not supported for NGPF implementation.
#
# Return Values:
#    A list containing the ipv4 loopback protocol stack handles that were added by the command (if any).
#x   key:ipv4_loopback_handle     value:A list containing the ipv4 loopback protocol stack handles that were added by the command (if any).
#    A list containing the ipv6 loopback protocol stack handles that were added by the command (if any).
#x   key:ipv6_loopback_handle     value:A list containing the ipv6 loopback protocol stack handles that were added by the command (if any).
#    A list containing the ipv4 protocol stack handles that were added by the command (if any).
#x   key:ipv4_handle              value:A list containing the ipv4 protocol stack handles that were added by the command (if any).
#    A list containing the ipv6 protocol stack handles that were added by the command (if any).
#x   key:ipv6_handle              value:A list containing the ipv6 protocol stack handles that were added by the command (if any).
#    A list containing the ethernet protocol stack handles that were added by the command (if any).
#x   key:ethernet_handle          value:A list containing the ethernet protocol stack handles that were added by the command (if any).
#    A list containing the pim router protocol stack handles that were added by the command (if any).
#x   key:pim_router_handle        value:A list containing the pim router protocol stack handles that were added by the command (if any).
#    A list containing the pim v4 interface protocol stack handles that were added by the command (if any).
#x   key:pim_v4_interface_handle  value:A list containing the pim v4 interface protocol stack handles that were added by the command (if any).
#    A list containing the pim v6 interface protocol stack handles that were added by the command (if any).
#x   key:pim_v6_interface_handle  value:A list containing the pim v6 interface protocol stack handles that were added by the command (if any).
#    $::SUCCESS | $::FAILURE
#    key:status                   value:$::SUCCESS | $::FAILURE
#    When status is failure, contains more information
#    key:log                      value:When status is failure, contains more information
#    The handles for the PIM-SM router created Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    key:handle                   value:The handles for the PIM-SM router created Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    All the interfaces created using the command Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    key:interfaces               value:All the interfaces created using the command Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#
# Examples:
#    See files starting with PIM_ in the Samples subdirectory.  Also see some of the MVPN sample files for further examples of the PIM usage.
#    See the PIM example in Appendix A, "Example APIs," for one specific example usage.
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    1) MVPN parameters are not supported with IxTclNetwork API (new API). If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  handle, interfaces
#
# See Also:
#

proc ::ixiangpf::emulation_pim_config { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "emulation_pim_config" $notImplementedParams $mandatoryParams $fileParams $args]
}
