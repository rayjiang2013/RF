##Procedure Header
# Name:
#    ixiangpf::emulation_ospf_lsa_config
#
# Description:
#    This procedure is not supported in ixiangpf namespace
#
# Synopsis:
#    ixiangpf::emulation_ospf_lsa_config
#        -mode                               CHOICES create modify delete reset
#                                            DEFAULT create
#        -handle                             ANY
#        [-lsa_handle                        ANY]
#        [-adv_router_id                     IP
#                                            DEFAULT 198.18.1.1]
#x       [-area_id                           IP
#x                                           DEFAULT 0.0.0.0]
#        [-attached_router_id                IP
#                                            DEFAULT 14.0.0.1]
#        [-external_number_of_prefix         ANY
#                                            DEFAULT 16]
#        [-external_prefix_start             IP]
#        [-external_prefix_length            ANY
#                                            DEFAULT 16]
#        [-external_prefix_step              IP
#                                            DEFAULT 0.0.0.1]
#        [-external_prefix_metric            RANGE 0-16777215
#                                            DEFAULT 1]
#        [-external_prefix_type              CHOICES 1 2
#                                            DEFAULT 1]
#        [-external_prefix_forward_addr      IP]
#        [-external_route_tag                IP
#                                            DEFAULT 17.0.0.1]
#x       [-external_metric_fbit              CHOICES 1 0
#x                                           DEFAULT 1]
#x       [-external_metric_tbit              CHOICES 1 0
#x                                           DEFAULT 1]
#x       [-external_metric_ebit              CHOICES 1 0
#x                                           DEFAULT 0]
#        [-link_state_id                     IP
#                                            DEFAULT 199.18.1.1]
#        [-link_state_id_step                IPV4]
#        [-ls_type_function_code             RANGE 0-8191
#                                            DEFAULT 0]
#x       [-lsa_group_mode                    CHOICES append create
#x                                           DEFAULT append]
#        [-net_prefix_length                 ANY
#                                            DEFAULT 16]
#        [-net_attached_router               CHOICES create delete reset
#                                            DEFAULT create]
#x       [-no_write                          FLAG]
#        [-opaque_enable_link_id             CHOICES 0 1
#                                            DEFAULT 0]
#        [-opaque_enable_link_local_ip_addr  CHOICES 0 1
#                                            DEFAULT 0]
#        [-opaque_enable_link_max_bw         CHOICES 0 1
#                                            DEFAULT 0]
#        [-opaque_enable_link_max_resv_bw    CHOICES 0 1
#                                            DEFAULT 0]
#        [-opaque_enable_link_metric         CHOICES 0 1
#                                            DEFAULT 0]
#        [-opaque_enable_link_remote_ip_addr CHOICES 0 1
#                                            DEFAULT 0]
#        [-opaque_enable_link_resource_class CHOICES 0 1
#                                            DEFAULT 0]
#        [-opaque_enable_link_type           CHOICES 0 1
#                                            DEFAULT 0]
#        [-opaque_enable_link_unresv_bw      CHOICES 0 1
#                                            DEFAULT 0]
#        [-opaque_link_id                    IP
#                                            DEFAULT 0.0.0.0]
#        [-opaque_link_local_ip_addr         IP
#                                            DEFAULT 0.0.0.0]
#        [-opaque_link_max_bw                ANY
#                                            DEFAULT 0]
#        [-opaque_link_max_resv_bw           ANY
#                                            DEFAULT 0]
#        [-opaque_link_metric                NUMERIC
#                                            DEFAULT 0]
#        [-opaque_link_remote_ip_addr        IP
#                                            DEFAULT 0.0.0.0]
#        [-opaque_link_resource_class        HEX
#                                            DEFAULT 0x00000000]
#        [-opaque_link_type                  CHOICES ptop multiaccess
#                                            DEFAULT ptop]
#        [-opaque_link_subtlvs               IP
#                                            DEFAULT 0.0.0.0]
#x       [-opaque_link_other_subtlvs         REGEXP ^(0x[0-9a-fA-F]+:[0-9]+:[0-9]+ )*0x[0-9a-fA-F]+:[0-9]+:[0-9]+$]
#        [-opaque_link_unresv_bw_priority    ANY
#                                            DEFAULT 0]
#        [-opaque_router_addr                IP
#                                            DEFAULT 0.0.0.0]
#        [-opaque_tlv_type                   CHOICES link router
#                                            DEFAULT router]
#        [-options                           RANGE 0-255]
#x       [-prefix_options                    RANGE 0-255]
#        [-router_abr                        CHOICES 0 1
#                                            DEFAULT 0]
#        [-router_asbr                       CHOICES 0 1
#                                            DEFAULT 0]
#        [-router_virtual_link_endpt         CHOICES 0 1
#                                            DEFAULT 0]
#x       [-router_wildcard                   CHOICES 0 1
#x                                           DEFAULT 0]
#        [-router_link_mode                  CHOICES create modify delete
#                                            DEFAULT create]
#        [-router_link_id                    IP
#                                            DEFAULT 12.0.0.1]
#        [-router_link_data                  IP
#                                            DEFAULT 13.0.0.1]
#        [-router_link_type                  CHOICES ptop transit stub virtual
#                                            DEFAULT ptop]
#        [-router_link_metric                RANGE 1-65535
#                                            DEFAULT 1]
#        [-session_type                      CHOICES ospfv2 ospfv3
#                                            DEFAULT ospfv2]
#        [-summary_number_of_prefix          ANY
#                                            DEFAULT 16]
#        [-summary_prefix_start              IP
#                                            DEFAULT 15.0.0.1]
#        [-summary_prefix_length             ANY
#                                            DEFAULT 16]
#        [-summary_prefix_step               IP
#                                            DEFAULT 0.0.0.1]
#        [-summary_prefix_metric             RANGE 0-16777215
#                                            DEFAULT 1]
#        [-type                              CHOICES router
#                                            CHOICES network
#                                            CHOICES summary_pool
#                                            CHOICES asbr_summary
#                                            CHOICES ext_pool
#                                            CHOICES opaque_type_9
#                                            CHOICES opaque_type_10
#                                            CHOICES opaque_type_11
#                                            DEFAULT router]
#n       [-auto_ls_age                       ANY]
#n       [-auto_ls_checksum                  ANY]
#n       [-auto_ls_seq                       ANY]
#n       [-auto_update                       ANY]
#n       [-ls_age                            ANY]
#n       [-ls_checksum                       ANY]
#n       [-ls_seq                            ANY]
#n       [-ls_type_s_bits                    ANY]
#n       [-ls_type_u_bit                     ANY]
#n       [-nssa_number_of_prefix             ANY]
#n       [-nssa_prefix_forward_addr          ANY]
#n       [-nssa_prefix_length                ANY]
#n       [-nssa_prefix_metric                ANY]
#n       [-nssa_prefix_start                 ANY]
#n       [-nssa_prefix_step                  ANY]
#n       [-nssa_prefix_type                  ANY]
#n       [-router_link_idx                   ANY]
#n       [-te_tlv_type                       ANY]
#n       [-te_instance_id                    ANY]
#n       [-te_router_address                 ANY]
#n       [-te_link_id                        ANY]
#n       [-te_link_type                      ANY]
#n       [-te_metric                         ANY]
#n       [-te_local_ip                       ANY]
#n       [-te_remote_ip                      ANY]
#n       [-te_admin_group                    ANY]
#n       [-te_max_bw                         ANY]
#n       [-te_max_resv_bw                    ANY]
#n       [-te_max_resv_priority0             ANY]
#n       [-te_max_resv_priority1             ANY]
#n       [-te_max_resv_priority2             ANY]
#n       [-te_max_resv_priority3             ANY]
#n       [-te_max_resv_priority4             ANY]
#n       [-te_max_resv_priority5             ANY]
#n       [-te_max_resv_priority6             ANY]
#n       [-te_max_resv_priority7             ANY]
#
# Arguments:
#    -mode
#        Mode of the procedure call.Valid options are:
#        create
#        modify
#        delete
#    -handle
#        This option represents the handle the user *must* pass to the
#        "emulation_ospf_lsa_config" procedure. This option specifies
#        on which OSPF router to configure the OSPF User LSA.
#        The OSPF router handle(s) are returned by the procedure
#        "emulation_ospf_config" when configuring OSPF routers on the
#        Ixia interface.
#    -lsa_handle
#        This option specifies on which OSPF User LSA to configure. This option
#        *must* be passed if the -mode option is modify or delete.
#        The OSPF LSA handle(s) are returned by the procedure
#        "emulation_ospf_lsa_config" when creating OSPF user LSA(s) on the Ixia
#        interface.
#    -adv_router_id
#        The router ID of the router that is originating the LSA.
#x   -area_id
#x       The area ID of the User LSA Group.
#x       This option is valid only for IxTclNetwork API.
#    -attached_router_id
#        A list of router IDs in the area, in IP address format separated by
#        spaces.
#    -external_number_of_prefix
#        The number of External IP LSAs to generate.
#    -external_prefix_start
#        This option is valid for OSPFv3 external route type. The prefix
#        address to be advertised in the LSA. Although only prefixLength
#        bits of the IPv6 address are meaningful, a full IPv6 address should
#        be specified.
#    -external_prefix_length
#        The number of high-order bits of prefixAddress that are significant.
#    -external_prefix_step
#        If external_number_of_prefix is greater than 1,this is the value that
#        will be added to the most significant external_prefix_length bits of
#        external_prefix_start between generated LSAs. This is also the value
#        to increment the link_state_id.
#    -external_prefix_metric
#        The cost of the route for all TOS levels.
#    -external_prefix_type
#        The type of external metric. A value of 1 implies type 2 metric.A
#        value of 0 implies type 1.
#    -external_prefix_forward_addr
#        If the external_metric_fbit is true, data traffic for the advertised
#        destination will be forwarded to this fully qualified IPv6 address.
#    -external_route_tag
#        If the external_metric_tbit is true, an additional value to be used for
#        external routes between AS boundary routers. This field is not used
#        within OSPF.
#x   -external_metric_fbit
#x       The value of the external metric's F-bit. If true, then the
#x       forwardingAddress field is to be included in the LSA.
#x   -external_metric_tbit
#x       The value of the external metric's T-bit. If true, then the
#x       externalRouteTag field will be included in the LSA.
#x   -external_metric_ebit
#x       The value of the external metric's E-bit.
#    -link_state_id
#        The router ID of the originating router. This field uniquely identified
#        the LSA in the link-state database.
#    -link_state_id_step
#        If summary_number_of_prefix is greater than 1, the value to increment
#        the link_state_id by for each LSA. The value is expressed in IPv4 format.
#    -ls_type_function_code
#x   -lsa_group_mode
#x       The two modes are append or create. Append means appending the new LSA
#x       to the last LSA group created. Create means creating a new LSA group
#x       for the newly added LSA.
#x       This option is valid only for -mode create.
#x       This option is valid only for IxTclNetwork API.
#    -net_prefix_length
#        The length in bits of the IP address mask for the network.
#    -net_attached_router
#        The option specifies the mode in configuring router IDs in the area.
#        Note that delete and reset does not work. Valid options are:
#        create
#        delete
#        reset
#x   -no_write
#x       If this option is present, the protocol configuration will not be
#x       written to the server.
#    -opaque_enable_link_id
#        This will enable usage of link id. TLV Type 2. If checked, this will
#        be the 4-octet IP address which identifies the other end of the link.
#        For Point to Point, the Neighbor's Router ID.
#        For Multi-access, the interface of the DR.
#        This option is valid only when type is opaque and opaque_tlv_type is link.
#        This option is valid only for IxTclNetwork API.
#    -opaque_enable_link_local_ip_addr
#        This will enable the usage of local IP address. TLV Type 3.
#        The IP address of the local interface for this link. Each address is
#        a 4-octet value. The total length is N times 4 octets, where N is the
#        number of addresses.
#        This option is valid only when type is opaque and opaque_tlv_type is link.
#        This option is valid only for IxTclNetwork API.
#    -opaque_enable_link_max_bw
#        This will enable the usage of max bandwidth. TLV Type 6.
#        Units are in bytes per second. The maximum bandwidth that can be used
#        on this link in this direction (from originator to the neighbor).
#        Four octets in length, expressed in IEEE floating point format.
#        This option is valid only when type is opaque and opaque_tlv_type is link.
#        This option is valid only for IxTclNetwork API.
#    -opaque_enable_link_max_resv_bw
#        This will enable the usage of max reservable bandwidth. TLV Type 7.
#        Units in bytes per second. The maximum bandwidth that can be reserved
#        on this link in this direction (from originator to the neighbor).
#        Four octets in length, expressed in IEEE floating point format. This
#        may be greater than the maximum bandwidth.
#        This option is valid only when type is opaque and opaque_tlv_type is link.
#        This option is valid only for IxTclNetwork API.
#    -opaque_enable_link_metric
#        This will enable the usage of link metric. TLV Type 5.
#        The Traffic Engineering Metric.
#        This option is valid only when type is opaque and opaque_tlv_type is link.
#        This option is valid only for IxTclNetwork API.
#    -opaque_enable_link_remote_ip_addr
#        This will enable the usage of the remote IP address. TLV Type 4.
#        The IP address of the neighbor's interface for this link. The total
#        length is N times four octets, where N is the number of addresses.
#        This option is valid only when type is opaque and opaque_tlv_type is link.
#        This option is valid only for IxTclNetwork API.
#    -opaque_enable_link_resource_class
#        This will enable the usage of link resource class. TLV Type 9.
#        A bit mask value, four octets in length, which specifies
#        administrative group membership for this link.
#        This option is valid only when type is opaque and opaque_tlv_type is link.
#        This option is valid only for IxTclNetwork API.
#    -opaque_enable_link_type
#        This will enable the usage of link type. TLV Type 1. Defines the type
#        of link and is one octet in length.
#        This option is valid only when type is opaque and opaque_tlv_type is link.
#        This option is valid only for IxTclNetwork API.
#    -opaque_enable_link_unresv_bw
#        This will enable the usage of the unreserved bandwidth. TLV Type 8.
#        The amount of bandwidth not yet reserved at each of the eight
#        priority levels. This value will be less than or equal to the maximum
#        reservable bandwidth. 32 octets in length, expressed in IEEE floating
#        point format. If checked, unreserved bandwidth may be assigned to
#        each of the 8 priority levels (0 through 7).
#        This option is valid only when type is opaque and opaque_tlv_type is link.
#        This option is valid only for IxTclNetwork API.
#    -opaque_link_id
#        TLV Type 2. If checked, this will be the 4-octet IP address which
#        identifies the other end of the link.
#        For Point to Point, the Neighbor's Router ID.
#        For Multiaccess, the interface of the DR.
#        This option is valid only when type is opaque and opaque_tlv_type is link.
#        This option is valid only for IxTclNetwork API.
#    -opaque_link_local_ip_addr
#        TLV Type 3. The IP address of the local interface for this link.
#        Each address is a 4-octet value. The total length is N times 4 octets,
#        where N is the number of addresses.
#        This option is valid only when type is opaque and opaque_tlv_type is link.
#        This option is valid only for IxTclNetwork API.
#    -opaque_link_max_bw
#        TLV Type 6. Units are in bytes per second. The maximum bandwidth that
#        can be used on this link in this direction (from originator to the
#        neighbor). Four octets in length, expressed in IEEE floating point
#        format.
#        This option is valid only when type is opaque and opaque_tlv_type is link.
#        This option is valid only for IxTclNetwork API.
#    -opaque_link_max_resv_bw
#        TLV Type 7. Units in bytes per second. The maximum bandwidth that can
#        be reserved on this link in this direction (from originator to the
#        neighbor). Four octets in length, expressed in IEEE floating point
#        format. This may be greater than the maximum bandwidth.
#        This option is valid only when type is opaque and opaque_tlv_type is link.
#        This option is valid only for IxTclNetwork API.
#    -opaque_link_metric
#        TLV Type 5. The Traffic Engineering Metric. Four octets in length.
#        This option is valid only when type is opaque and opaque_tlv_type is link.
#        This option is valid only for IxTclNetwork API.
#    -opaque_link_remote_ip_addr
#        TLV Type 4. The IP address of the neighbor's interface for this link.
#        The total length is N times four octets, where N is the number of
#        addresses.
#        This option is valid only when type is opaque and opaque_tlv_type is link.
#        This option is valid only for IxTclNetwork API.
#    -opaque_link_resource_class
#        TLV Type 9. A bit mask value, four octets in length, which specifies
#        administrative group membership for this link.
#        This option is valid only when type is opaque and opaque_tlv_type is link.
#        This option is valid only for IxTclNetwork API.
#    -opaque_link_type
#        TLV Type 1. Defines the type of link and is one octet in length.
#        This option is valid only when type is opaque and opaque_tlv_type is link.
#        This option is valid only for IxTclNetwork API.
#    -opaque_link_subtlvs
#        Allows the user to create custom type 10 Sub-TLVs with length 4 - for Traffic Engineering.
#        When both -opaque_link_subtlvs and -opaque_link_other_subtlvs are
#        provided then -opaque_link_subtlvs has a greater priority.
#        This option is valid only when type is opaque and opaque_tlv_type is link.
#        This option is valid only for IxTclNetwork API.
#x   -opaque_link_other_subtlvs
#x       Allows the user to create custom Sub-TLVs - for Traffic Engineering.
#x       To be provided with a list of parameters in the following format:
#x       <type>:<length>:<value>, where type is from 0 to 65535, length is a
#x       value from 0 to 65535 and value is a hex number preceeded by 0x with
#x       the length specified by <length> parameter.
#x       When both -opaque_link_subtlvs and -opaque_link_other_subtlvs are
#x       provided then -opaque_link_subtlvs has a greater priority.
#x       This option is valid only when type is opaque and opaque_tlv_type is link.
#x       This option is valid only for IxTclNetwork API.
#    -opaque_link_unresv_bw_priority
#        Unreserved Bandwidth in bytes per second per priority level.
#        This option is valid only when type is opaque and opaque_tlv_type is link.
#        This option is valid only for IxTclNetwork API.
#    -opaque_router_addr
#        TLVs are Type/Length/Value field combinations that make up part of the
#        LSA payload and enable OSPF Traffic Engineering (OSPF-TE).
#        If opaque_tlv_type is router, the field is for the four-octet IP
#        address of the advertising router.
#        This option is valid only when type is opaque and opaque_tlv_type is router.
#        This option is valid only for IxTclNetwork API.
#    -opaque_tlv_type
#        TLVs are Type/Length/Value field combinations that make up part of the
#        LSA payload and enable OSPF Traffic Engineering (OSPF-TE).
#        If opaque_tlv_type is router, the field is for the four-octet IP
#        address of the advertising router.
#        Otherwise, if opaque_tlv_type is link, all the other TLVs from 1-9 can
#        be enabled and used.
#        This option is valid only when type is opaque.
#        This option is valid only for IxTclNetwork API.
#    -options
#        The optional capabilities supported by the OSPFv2 router. For OSPFv3,
#        use OSPFv3 specific options.
#        Multiple options may becombined using a logical "or".
#        Valid choices are:
#        ospfOptionBitTypeOfService - 0x01
#        ospfOptionBitExternalRouting - 0x02
#        ospfOptionBitMulticast - 0x04
#        ospfOptionBitNSSACapability - 0x08
#        ospfOptionBitExternalAttributes - 0x10
#        ospfOptionBitDemandCircuit - 0x20
#        ospfOptionBitLSANoForward - 0x40
#        ospfOptionBitUnused - 0x80
#x   -prefix_options
#x       An 8-bit quantity with options related to the prefixAddress. Multiple
#x       bits may becombined using a logical or. If both options and prefix_options
#x       are provided, the options value takes priority.
#x       Valid choices are:
#x       ospfV3PrefixOptionPBit - 0x08--The propagate bit, which is set on
#x       NSSA area prefixes that should be re-advertised at
#x       the NSSA area border.
#x       ospfV3PrefixOptionMCBit - 0x04--The multicast capability bit, which
#x       should be set if the prefix should be included in IPv6
#x       multicast routing calculations.
#x       ospfV3PrefixOptionLABit - 0x02--The local address capability bit,
#x       which should be set if the prefix is actually an IPv6
#x       interface address of the advertising router.
#x       ospfV3PrefixOptionNUBit - 0x01--The no unicast bit, which should be
#x       set if the prefix should be excluded from IPv6 unicast
#x       calculations.
#    -router_abr
#        Set router to be an area boundary router (ABR). Correspond to E
#        (external) bit in router LSA.
#    -router_asbr
#        Set router to be an AS boundary router (ASBR). Correspond to B
#        (border) bit in router LSA.
#    -router_virtual_link_endpt
#        Set router to be an endpoint of an active virtual link. Correspond
#        to V (virtual link endpoint) bit in router LSA.
#x   -router_wildcard
#x       Indicates that the router is a wild-card multicast receiver and will
#x       receive multicast datagrams regardless of destination.
#    -router_link_mode
#        This option specifies the mode for configuring router links in a router
#        LSA.Note that the modify and delete mode do not work. Valid options are:
#        create
#        modify
#        delete
#    -router_link_id
#        Identifies the object that this router link connects to, depending on
#        the router_link_type option. Valid choices are:
#        ptop - The neighboring routers router ID.
#        transit - The IP address of the Designated Router.
#        stub - The IP network/subnet number.
#        virtual - The neighboring routers router ID.
#    -router_link_data
#        The meaning of this option depends on the router_link_type option.
#        Valid choices are:
#        ptop - The interfaces MIB-II.
#        transit - The router interfaces IP address.
#        stub - The networks IP address mask.
#        virtual - The router interfaces IP address.
#    -router_link_type
#        The type of the router link. Valid choices are:
#        ptop - A point-to-point connection to another router.
#        transit - (default) A connection to a transit network.
#        stub - A connection a stub network.
#        virtual - A virtual link.
#    -router_link_metric
#        The cost of using the router link, applied to all TOS values.
#    -session_type
#    -summary_number_of_prefix
#        The number of Summary IP LSAs to generate.
#    -summary_prefix_start
#        This option is valid for OSPFv3 summary_pool route type. The prefix
#        address to be advertised in the LSA. Although only prefixLength
#        bits of the IPv6 address are meaningful, a full IPv6 address should
#        be specified.
#    -summary_prefix_length
#        The number of high-order bits of prefixAddress that are significant.
#    -summary_prefix_step
#        If summary_number_of_prefix is greater than 1, this is the value that
#        will be added to the most significant summary_prefix_length bits of
#        summary_prefix_start between generated LSAs.This is also the value
#        to increment the link_state_id, if link_state_id_step is not present.
#        This parameter can be provided as an IPv4/IPv6 address, depending on
#        the prefix type, but the corresponding number of the IP address
#        provided should not be greater than 4,294,967,295.
#    -summary_prefix_metric
#        The cost of the route for all TOS levels.
#    -type
#        This option specified the type of the LSA. The user *must* pass this option when creating a LSA. The choices are:
#        router- ospfv2, ospfv3
#        network- ospfv2, ospfv3
#        summary_pool- ospfv2, ospfv3
#        asbr_summary- ospfv2, ospfv3
#        ext_pool- ospfv2, ospfv3
#        opaque_type_9- ospfv2
#        opaque_type_10- ospfv2
#        opaque_type_11- ospfv2
#n   -auto_ls_age
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -auto_ls_checksum
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -auto_ls_seq
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -auto_update
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -ls_age
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -ls_checksum
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -ls_seq
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -ls_type_s_bits
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -ls_type_u_bit
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -nssa_number_of_prefix
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -nssa_prefix_forward_addr
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -nssa_prefix_length
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -nssa_prefix_metric
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -nssa_prefix_start
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -nssa_prefix_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -nssa_prefix_type
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -router_link_idx
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -te_tlv_type
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -te_instance_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -te_router_address
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -te_link_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -te_link_type
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -te_metric
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -te_local_ip
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -te_remote_ip
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -te_admin_group
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -te_max_bw
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -te_max_resv_bw
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -te_max_resv_priority0
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -te_max_resv_priority1
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -te_max_resv_priority2
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -te_max_resv_priority3
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -te_max_resv_priority4
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -te_max_resv_priority5
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -te_max_resv_priority6
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -te_max_resv_priority7
#n       This argument defined by Cisco is not supported for NGPF implementation.
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status                                 value:$::SUCCESS | $::FAILURE
#    On status of failure, gives detailed information.
#    key:log                                    value:On status of failure, gives detailed information.
#    key:lsa_handle                             value:
#    key:adv_router_id                          value:
#    key:For Router LSA                         value:
#    key:router.links.<idx = 0>.id              value:
#    key:router.links.<idx = 0>.data            value:
#    key:router.links.<idx = 0>.type            value:
#    key:router.links.<idx = n>.id              value:
#    key:router.links.<idx = n>.data            value:
#    key:router.links.<idx = n>.type            value:
#    key:For Network LSA                        value:
#    key:network.attached_router_ids            value:
#    key:For Summary_Pool and ASBR_Summary LSA  value:
#    key:summary.num_prefix                     value:
#    key:summary.prefix_start                   value:
#    key:summary.prefix_length                  value:
#    key:summary.prefix_step                    value:
#    key:For Ext_Pool LSA                       value:
#    key:external.num_prefix                    value:
#    key:external.prefix_start                  value:
#    key:external.prefix_length                 value:
#    key:external.prefix_step                   value:
#
# Examples:
#    See files starting with OSPFv2 and OSPFv3 in the Samples subdirectory. Also see some of the L2VPN, L3VPN, MPLS, and MVPN sample files for further examples of the OSPF usage.
#    See the OSPF example in Appendix A, "Example APIs," for one specific example usage.
#
# Sample Input:
#    .
#
# Sample Output:
#    .
#
# Notes:
#    1) Coded versus functional specification v5-3-6.
#    2) In OSPFv3, asbr_summary type and the summary_prefix_length field do not
#    apply and are not returned in returnList.
#    Caveats: Due to the problem with getting item with local lable ID, there
#    are the following limitations:
#    - handle (ospf_session_handle) must be gotten within the same wish
#    shell.
#    - router_link_mode of modify and delete is not supported.
#    - net_attached_router of delete and reset is not supported.
#    - For OSPFv3, only one lsa can be created per router handle.
#
# See Also:
#

package ixiangpf;

use utils;
use ixiahlt;

sub emulation_ospf_lsa_config {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('emulation_ospf_lsa_config', $args);
	# ixiahlt::utrackerLog ('emulation_ospf_lsa_config', $args);

	return ixiangpf::runExecuteCommand('emulation_ospf_lsa_config', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
