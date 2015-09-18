##Procedure Header
# Name:
#    ::ixiangpf::emulation_dhcp_server_config
#
# Description:
#    This procedure will configure DHCP Server on an Ixia port.
#
# Synopsis:
#    ::ixiangpf::emulation_dhcp_server_config
#        [-count                                 RANGE 1-100000
#                                                DEFAULT 1]
#x       [-ip_count                              NUMERIC
#x                                               DEFAULT 1]
#x       [-dhcp6_ia_type                         CHOICES iana iata iapd iana_iapd
#x                                               DEFAULT iana]
#n       [-dhcp_ack_circuit_id                   ANY]
#n       [-dhcp_ack_cisco_server_id_override     ANY]
#n       [-dhcp_ack_link_selection               ANY]
#n       [-dhcp_ack_options                      ANY]
#n       [-dhcp_ack_remote_id                    ANY]
#n       [-dhcp_ack_router_address               ANY]
#n       [-dhcp_ack_server_id_override           ANY]
#n       [-dhcp_ack_subnet_mask                  ANY]
#n       [-dhcp_ack_time_offset                  ANY]
#n       [-dhcp_ack_time_server_address          ANY]
#n       [-dhcp_ignore_mac                       ANY]
#n       [-dhcp_ignore_mac_mask                  ANY]
#n       [-dhcp_mac_nak                          ANY]
#n       [-dhcp_mac_nak_mask                     ANY]
#n       [-dhcp_offer_circuit_id                 ANY]
#n       [-dhcp_offer_cisco_server_id_override   ANY]
#n       [-dhcp_offer_link_selection             ANY]
#        [-dhcp_offer_options                    CHOICES 0 1
#                                                DEFAULT 0]
#n       [-dhcp_offer_remote_id                  ANY]
#        [-dhcp_offer_router_address             IP
#                                                DEFAULT 0.0.0.0]
#x       [-dhcp_offer_router_address_step        IP
#x                                               DEFAULT 0.0.0.0]
#x       [-dhcp_offer_router_address_inside_step IP
#x                                               DEFAULT 0.0.0.0]
#n       [-dhcp_offer_server_id_override         ANY]
#n       [-dhcp_offer_subnet_mask                ANY]
#n       [-dhcp_offer_time_offset                ANY]
#n       [-dhcp_offer_time_server_address        ANY]
#n       [-encapsulation                         ANY]
#        [-handle                                ANY]
#        [-ip_address                            IP
#                                                DEFAULT 10.10.0.1|1000::100]
#x       [-ip_dns1                               IP]
#x       [-ip_dns1_step                          IP
#x                                               DEFAULT 0.1.0.0|0:0:0:0:0:0:0:0100]
#x       [-ip_dns1_inside_step                   IP
#x                                               DEFAULT 0.0.0.1|0:0:0:0:0:0:0:1]
#x       [-ip_dns2                               IP]
#x       [-ip_dns2_step                          IP
#x                                               DEFAULT 0.1.0.0|0:0:0:0:0:0:0:0100]
#x       [-ip_dns2_inside_step                   IP
#x                                               DEFAULT 0.0.0.1|0:0:0:0:0:0:0:1]
#        [-ip_gateway                            IP]
#x       [-ip_gateway_step                       IP
#x                                               DEFAULT 0.1.0.0]
#x       [-ip_gateway_inside_step                IP]
#        [-ip_prefix_length                      RANGE 0-128
#                                                DEFAULT 16|120]
#        [-ip_prefix_step                        NUMERIC
#                                                DEFAULT 1]
#x       [-ip_prefix_inside_step                 NUMERIC
#x                                               DEFAULT 1]
#        [-ip_repeat                             NUMERIC
#                                                DEFAULT 1]
#        [-ip_step                               IP
#                                                DEFAULT 0.1.0.0|0:0:0:0:0:0:0:0100]
#x       [-ip_inside_step                        IP
#x                                               DEFAULT 0.1.0.0|0:0:0:0:0:0:0:0100]
#x       [-ip_version                            CHOICES 4 6
#x                                               DEFAULT 4]
#        [-ipaddress_count                       RANGE 1-1000000
#                                                DEFAULT 16000]
#n       [-ipaddress_increment                   ANY]
#        [-ipaddress_pool                        IP
#                                                DEFAULT 10.10.1.1|::A0A:101]
#x       [-ipaddress_pool_step                   IP
#x                                               DEFAULT 0.1.0.0|0:0:0:0:0:0:0:0100]
#x       [-ipaddress_pool_inside_step            IP
#x                                               DEFAULT 0.1.0.0|0:0:0:0:0:0:0:0100]
#x       [-ipaddress_pool_prefix_length          RANGE 0-128
#x                                               DEFAULT 16|120]
#x       [-ipaddress_pool_prefix_step            NUMERIC
#x                                               DEFAULT 1]
#x       [-ipaddress_pool_prefix_inside_step     NUMERIC
#x                                               DEFAULT 1]
#x       [-ipv6_gateway                          IPV6
#x                                               DEFAULT 1000::1]
#x       [-ipv6_gateway_step                     IPV6
#x                                               DEFAULT 0:0:0:0:0:0:0:0100]
#x       [-ipv6_gateway_inside_step              IPV6
#x                                               DEFAULT 0:0:0:0:0:0:0:0100]
#        [-lease_time                            RANGE 300-30000000
#                                                DEFAULT 3600]
#n       [-lease_time_max                        ANY]
#x       [-lease_time_increment                  NUMERIC]
#        [-local_mac                             MAC
#                                                DEFAULT 0000.0000.0001]
#x       [-local_mac_outer_step                  MAC
#x                                               DEFAULT 0000.0001.0000]
#x       [-local_mac_step                        MAC
#x                                               DEFAULT 0000.0000.0001]
#x       [-local_mtu                             RANGE 500-9216
#x                                               DEFAULT 1500]
#        [-mode                                  CHOICES create modify reset
#                                                DEFAULT create]
#x       [-ping_check                            CHOICES 0 1
#x                                               DEFAULT 0]
#x       [-ping_timeout                          RANGE 1-100
#x                                               DEFAULT 1]
#x       [-offer_timeout                         NUMERIC]
#x       [-advertise_timeout                     NUMERIC]
#x       [-init_force_renew_timeout              NUMERIC]
#x       [-force_renew_factor                    NUMERIC]
#x       [-force_renew_max_rc                    NUMERIC]
#x       [-reconfigure_timeout                   NUMERIC]
#x       [-reconfigure_max_rc                    NUMERIC]
#        [-port_handle                           ANY]
#n       [-pvc_incr_mode                         ANY]
#x       [-qinq_incr_mode                        CHOICES inner outer both
#x                                               DEFAULT both]
#n       [-remote_mac                            ANY]
#n       [-single_address_pool                   ANY]
#n       [-spfc_mac_ipaddress_count              ANY]
#n       [-spfc_mac_ipaddress_increment          ANY]
#n       [-spfc_mac_ipaddress_pool               ANY]
#n       [-spfc_mac_mask_pool                    ANY]
#n       [-spfc_mac_pattern_pool                 ANY]
#n       [-vci                                   ANY]
#n       [-vci_count                             ANY]
#n       [-vci_repeat                            ANY]
#n       [-vci_step                              ANY]
#n       [-vlan_ethertype                        ANY]
#        [-vlan_id                               RANGE 0-4095]
#x       [-vlan_id_count                         RANGE 0-4095
#x                                               DEFAULT 1]
#x       [-vlan_id_count_inner                   RANGE 0-4095
#x                                               DEFAULT 1]
#x       [-vlan_id_inner                         RANGE 0-4095]
#x       [-vlan_id_repeat                        NUMERIC
#x                                               DEFAULT 1]
#x       [-vlan_id_repeat_inner                  NUMERIC
#x                                               DEFAULT 1]
#x       [-vlan_id_step                          RANGE 0-4095
#x                                               DEFAULT 1]
#x       [-vlan_id_step_inner                    RANGE 0-4095
#x                                               DEFAULT 1]
#x       [-vlan_id_inter_device_step             RANGE 0-4095
#x                                               DEFAULT 1]
#x       [-vlan_id_inner_inter_device_step       RANGE 0-4095
#x                                               DEFAULT 1]
#x       [-vlan_user_priority                    RANGE 0-7
#x                                               DEFAULT 0]
#x       [-vlan_user_priority_inner              RANGE 0-7
#x                                               DEFAULT 0]
#n       [-vpi                                   ANY]
#n       [-vpi_count                             ANY]
#n       [-vpi_repeat                            ANY]
#n       [-vpi_step                              ANY]
#x       [-functional_specification              CHOICES v4_compatible
#x                                               CHOICES v4_v6_compatible
#x                                               DEFAULT v4_compatible]
#n       [-args                                  ANY]
#n       [-dhcp_mac_ignore_mask                  ANY]
#n       [-spfc_mac_address_pool                 ANY]
#x       [-protocol_name                         ALPHA]
#x       [-use_rapid_commit                      CHOICES 0 1]
#x       [-echo_relay_info                       CHOICES 0 1
#x                                               DEFAULT 1]
#x       [-pool_address_increment                IP]
#x       [-pool_address_increment_step           IP]
#x       [-start_pool_prefix                     IPV6]
#x       [-start_pool_prefix_step                IPV6]
#x       [-pool_prefix_increment                 IPV6]
#x       [-pool_prefix_increment_step            IPV6]
#x       [-pool_prefix_size                      NUMERIC]
#x       [-prefix_length                         NUMERIC]
#x       [-dns_domain                            ALPHA]
#x       [-custom_renew_time                     NUMERIC]
#x       [-custom_rebind_time                    NUMERIC]
#x       [-use_custom_times                      CHOICES 0 1
#x                                               DEFAULT 0]
#x       [-enable_resolve_gateway                CHOICES 0 1
#x                                               DEFAULT 1]
#x       [-manual_gateway_mac                    MAC]
#x       [-manual_gateway_mac_step               MAC
#x                                               DEFAULT 0000.0000.0001]
#x       [-reconfigure_rate_scale_mode           CHOICES port device_group
#x                                               DEFAULT port]
#x       [-reconfigure_rate_enabled              CHOICES 0 1]
#x       [-reconfigure_rate_max_outstanding      NUMERIC]
#x       [-reconfigure_rate_interval             NUMERIC]
#x       [-reconfigure_rate                      NUMERIC]
#x       [-pool_count                            NUMERIC]
#x       [-enable_address_match_duid             CHOICES 0 1]
#x       [-address_duid_mask                     HEX]
#x       [-address_duid_pattern                  HEX]
#x       [-addresses_per_ia                      NUMERIC]
#x       [-enable_prefix_match_duid              CHOICES 0 1]
#x       [-prefix_duid_start                     HEX]
#x       [-prefix_duid_increment                 HEX]
#x       [-prefixes_per_ia                       NUMERIC]
#x       [-duid_match_nak                        CHOICES 0 1]
#x       [-duid_nak_mask                         HEX]
#x       [-duid_nak_pattern                      HEX]
#x       [-duid_match_ignore                     CHOICES 0 1]
#x       [-duid_ignore_mask                      HEX]
#x       [-duid_ignore_pattern                   HEX]
#
# Arguments:
#    -count
#        Number of emulated dhcp server devices. This parameter is supported
#        using the following APIs: IxTclNetwork.
#        Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -ip_count
#x       The number of IPv4 values in sequence.
#x   -dhcp6_ia_type
#x       The Identity Association type for DHCP V6.
#x       Valid for functional_specification: v4_v6_compatible.
#n   -dhcp_ack_circuit_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_ack_cisco_server_id_override
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_ack_link_selection
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_ack_options
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_ack_remote_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_ack_router_address
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_ack_server_id_override
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_ack_subnet_mask
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_ack_time_offset
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_ack_time_server_address
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_ignore_mac
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_ignore_mac_mask
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_mac_nak
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_mac_nak_mask
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_offer_circuit_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_offer_cisco_server_id_override
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_offer_link_selection
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -dhcp_offer_options
#        Dhcp offer options
#n   -dhcp_offer_remote_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -dhcp_offer_router_address
#        DHCP Offer Option router option IP address. Dependencies:
#        -dhcp_offer_options.
#        Valid for functional_specification: v4_v6_compatible.
#x   -dhcp_offer_router_address_step
#x       DHCP Offer Option router option IP address step. Dependencies:
#x       -dhcp_offer_options.
#x       Valid for functional_specification: v4_v6_compatible.
#x   -dhcp_offer_router_address_inside_step
#x       DHCP Offer Option router option IP address step inside the dhcp range. Dependencies:
#x       -dhcp_offer_options.
#x       Valid for functional_specification: v4_v6_compatible.
#n   -dhcp_offer_server_id_override
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_offer_subnet_mask
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_offer_time_offset
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_offer_time_server_address
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -encapsulation
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -handle
#        The DHCP Server handle for which the configuration will be made. Valid
#        for -mode modify and reset. This parameter is supported using the
#        following APIs: IxTclNetwork.
#        Valid for functional_specification: v4_compatible, v4_v6_compatible.
#        When -handle is provided with the /globals value the arguments that configure global protocol
#        setting accept both multivalue handles and simple values.
#        When -handle is provided with a a protocol stack handle or a protocol session handle, the arguments
#        that configure global settings will only accept simple values. In this situation, these arguments will
#        configure only the settings of the parent device group or the ports associated with the parent topology.
#    -ip_address
#        IPv4 or IPv6 address of the emulated device. This parameter is supported
#        using the following APIs: IxTclNetwork.
#        Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -ip_dns1
#x       First DNS Server.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -ip_dns1_step
#x       First DNS Server step when creating multiple DHCP Servers.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -ip_dns1_inside_step
#x       First DNS Server step inside DHCP range.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -ip_dns2
#x       Second DNS Server.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -ip_dns2_step
#x       Second DNS Server step when creating multiple DHCP Servers.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -ip_dns2_inside_step
#x       Second DNS Server step inside the Dhcp server range.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#    -ip_gateway
#        The IPv4 or IPv6 address of the DUT. This parameter is supported using
#        the following APIs: IxTclNetwork.
#        Valid for functional_specification:
#        v4_compatible - ip_gateway represents the gateway for the IPv4 address pool and the default value is 10.10.0.2
#        v4_v6_compatible - ip_gateway represents the gateway for the IPv4/v6 server address and there is no default value
#x   -ip_gateway_step
#x       The incrementing step for the IPv4 (or 6) address of the DUT. Valid only for -mode create and when -count is greater than 1. This parameter is
#x       supported using the following APIs: IxTclNetwork.
#x       Valid for functional_specification:
#x       v4_compatible - represents the gateway step for the IPv4 address pool
#x       v4_v6_compatible - represents the gateway step for the IPv4/v6 server address
#x   -ip_gateway_inside_step
#x       The incrementing step for the IPv4 (or 6) address of the DUT inside the dhcp server range.
#x       Valid only for -mode create and when -count is greater than 1. This parameter is
#x       supported using the following APIs: IxTclNetwork.
#x       Valid for functional_specification:
#x       v4_compatible - represents the gateway step for the IPv4 address pool
#x       v4_v6_compatible - represents the gateway step for the IPv4/v6 server address
#    -ip_prefix_length
#        The bit position at which the prefix step is applied. This parameter is
#        supported using the following APIs: IxTclNetwork.
#        Valid for functional_specification: v4_compatible, v4_v6_compatible.
#    -ip_prefix_step
#        The size of the step applied to the prefix length bit position.
#        Depends on ip_prefix_length if ip_step is not used. Valid only
#        for -mode create and when -count is greater than 1. This parameter is
#        supported using the following APIs: IxTclNetwork.
#        Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -ip_prefix_inside_step
#x       The size of the step applied to the prefix length bit position, inside the dhcp server range.
#x       Depends on ip_prefix_length if ip_step is not used. Valid only
#x       for -mode create and when -count is greater than 1. This parameter is
#x       supported using the following APIs: IxTclNetwork.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#    -ip_repeat
#        The number of times to repeat a value before incrementing. Valid only
#        for -mode create and when -count is greater than 1. This parameter is
#        supported using the following APIs: IxTclNetwork.
#        Valid for functional_specification: v4_compatible, v4_v6_compatible.
#    -ip_step
#        Incrementing step for the IPv4 (or 6) address of the emulated device. Valid
#        only for -mode create and when -count is greater than 1. This parameter
#        is supported using the following APIs: IxTclNetwork.
#        Valid for functional_specification: v4_compatible (default 0.1.0.0|0:0:0:0:0:0:0:0100) , v4_v6_compatible (default 0.0.0.1|0:0:0:0:0:0:0:0001).
#x   -ip_inside_step
#x       Incrementing step for the IPv4 (or 6) address of the emulated device, inside the dhpc server range. Valid
#x       only for -mode create and when -count is greater than 1. This parameter
#x       is supported using the following APIs: IxTclNetwork.
#x       Valid for functional_specification: v4_compatible (default 0.0.0.1|0:0:0:0:0:0:0:0001), v4_v6_compatible (default 0.1.0.0|0:0:0:0:0:0:0:0100)
#x   -ip_version
#x       DHCP Server type: IPv4 or IPv6. Added support for IPv6 in HLT 4.00.
#x       Valid for functional_specification: v4_v6_compatible.
#    -ipaddress_count
#        Number of ip addresses in the pool. This parameter is supported using
#        the following APIs: IxTclNetwork.
#        Valid for functional_specification: v4_compatible, v4_v6_compatible.
#n   -ipaddress_increment
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -ipaddress_pool
#        The first IP address in the DHCP server address pool. This parameter is
#        supported using the following APIs: IxTclNetwork.
#        Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -ipaddress_pool_step
#x       The incrementing step for the IPv4 address of the DHCP pool when creating multiple DHCP Servers. Valid only for -mode create and when -count is greater than 1. This parameter is
#x       supported using the following APIs: IxTclNetwork.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -ipaddress_pool_inside_step
#x       The incrementing step for the IPv4 address of the DHCP pool inside the dhcp server range.
#x       Valid only for -mode create and when -count is greater than 1. This parameter is
#x       supported using the following APIs: IxTclNetwork.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -ipaddress_pool_prefix_length
#x       The bit position at which the prefix step is applied. This parameter is
#x       supported using the following APIs: IxTclNetwork.
#x       Valid for functional_specification: v4_v6_compatible.
#x   -ipaddress_pool_prefix_step
#x       The size of the step applied to the prefix length bit position.
#x       Depends on ipaddress_pool_prefix_length if ipaddress_pool_step is not used. Valid only
#x       for -mode create and when -count is greater than 1. This parameter is
#x       supported using the following APIs: IxTclNetwork.
#x       Valid for functional_specification: v4_v6_compatible.
#x   -ipaddress_pool_prefix_inside_step
#x       The size of the step applied to the prefix length bit position, inside the dhcp server range.
#x       Valid only for -mode create and when -count is greater than 1. This parameter is
#x       supported using the following APIs: IxTclNetwork.
#x       Valid for functional_specification: v4_v6_compatible.
#x   -ipv6_gateway
#x       The IPv6 address of the DUT.
#x   -ipv6_gateway_step
#x       The incrementing step for the IPv6 address of the DUT. Valid only for -mode create and when -count is greater than 1. This parameter is
#x       supported using the following APIs: IxTclNetwork.
#x       Valid for functional_specification:
#x       v4_v6_compatible - ipc6_gateway represents the gateway step for the IPv6 server address
#x   -ipv6_gateway_inside_step
#x       The incrementing step for the IPv6 address of the DUT, inside the dhcp server range.
#x       Valid only for -mode create and when -count is greater than 1. This parameter is
#x       supported using the following APIs: IxTclNetwork.
#x       Valid for functional_specification:
#x       v4_v6_compatible - ipc6_gateway represents the gateway step for the IPv6 server address
#    -lease_time
#        Lease duration is seconds. This parameter is supported using the
#        following APIs: IxTclNetwork. This is a global setting, valid for all servers.
#        Valid for functional_specification: v4_compatible, v4_v6_compatible.
#n   -lease_time_max
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -lease_time_increment
#x       The value with which Lease Time is incremented when assigning many Addresses/Prefixes per IA.
#    -local_mac
#        The mac address of the emulated device(s). This parameter is supported
#        using the following APIs: IxTclNetwork.
#        Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -local_mac_outer_step
#x       The mac address step when creating multiple emulated device(s). This
#x       parameter is supported using the following APIs: IxTclNetwork.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -local_mac_step
#x       The mac address step when enabling multiple VLAN domains. This
#x       parameter is supported using the following APIs: IxTclNetwork.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -local_mtu
#x       Maximum Transmission Unit (MTU) is the largest packet that a given
#x       network medium can carry. Ethernet, for example, has a fixed MTU of
#x       1500 bytes, ATM has a fixed MTU of 48 bytes, and PPP has a negotiated
#x       MTU that is usually between 500 and 2000 bytes. The parameter defines
#x       the MTU value for the Access Node. This parameter is supported using
#x       the following APIs: IxTclNetwork.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#    -mode
#        Action to perform. This parameter is supported using the following
#        APIs: IxTclNetwork.
#        Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -ping_check
#x       When enabled, the DHCP server issues ICMP echo requests (pings) to
#x       check for the existence of IP addresses in the network. The DHCP will
#x       not assign an IP address to a node that responds to the ICMP echo
#x       requests within the time period specified by Ping Timeout. Note that
#x       using this option will diminish the performance of the test. This
#x       option is disabled by default. This parameter is supported using
#x       the following APIs: IxTclNetwork. This is a global setting, valid for all servers.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -ping_timeout
#x       The number of seconds the DHCP server will wait for an ICMP Echo
#x       response before assigning the address. The default is 1, the minimum
#x       is 1, and the maximum is 100. This parameter is supported using
#x       the following APIs: IxTclNetwork. This is a global setting, valid for all servers.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -offer_timeout
#x       Offer timeout in seconds
#x   -advertise_timeout
#x       Advertise timeout in seconds
#x   -init_force_renew_timeout
#x       Force Renew timeout in seconds
#x   -force_renew_factor
#x       Force Renew timeout factor
#x   -force_renew_max_rc
#x       Force Renew Attempts
#x   -reconfigure_timeout
#x       RFC 3315 Reconfigure timeout in seconds
#x   -reconfigure_max_rc
#x       RFC 3315 Reconfigure retry attempts
#    -port_handle
#        This parameter specifies the port handle upon which emulation is
#        configured. Mandatory for -mode create. This parameter is supported using the following APIs: IxTclNetwork.
#        Valid for functional_specification: v4_compatible, v4_v6_compatible.
#n   -pvc_incr_mode
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -qinq_incr_mode
#x       The incrementing mode for Stacked Vlan. This parameter is supported
#x       using the following APIs: IxTclNetwork.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x       Valid choices are:
#x       inner -
#n   -remote_mac
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -single_address_pool
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -spfc_mac_ipaddress_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -spfc_mac_ipaddress_increment
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -spfc_mac_ipaddress_pool
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -spfc_mac_mask_pool
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -spfc_mac_pattern_pool
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vci
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vci_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vci_repeat
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vci_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vlan_ethertype
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -vlan_id
#        Vlan ID of the emulated device. This parameter is supported using the
#        following APIs: IxTclNetwork.
#        Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -vlan_id_count
#x       Defines the number of Vlan IDs. This parameter is supported using the
#x       following APIs: IxTclNetwork.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -vlan_id_count_inner
#x       Defines the number of Inner Vlan IDs. This parameter is supported using
#x       the following APIs: IxTclNetwork.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -vlan_id_inner
#x       Defines the Inner Vlan ID for Access Node. Doesn't support a list of
#x       vlan IDs. This parameter is supported using the following APIs:
#x       IxTclNetwork.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -vlan_id_repeat
#x       Defines the repeat count of VLAN ID. This parameter is supported using
#x       the following APIs: IxTclNetwork.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -vlan_id_repeat_inner
#x       Defines the repeat count of Inner VLAN ID. This parameter is supported
#x       using the following APIs: IxTclNetwork.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -vlan_id_step
#x       Defines the Vlan ID incrementing step. This parameter is supported
#x       using the following APIs: IxTclNetwork. This is valid when emulating a single DHCP device that distributes IP addresses over multiple VLAN domains.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -vlan_id_step_inner
#x       Defines the Inner Vlan ID incrementing step. This parameter is
#x       supported using the following APIs: IxTclNetwork.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -vlan_id_inter_device_step
#x       Defines the Vlan ID incrementing step when creating multiple DHCP devices. This parameter is supported
#x       using the following APIs: IxTclNetwork. This parameter is valid only on -mode create when -count is greater than one.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -vlan_id_inner_inter_device_step
#x       Defines the Inner Vlan ID incrementing step when creating multiple DHCP devices. This parameter is supported
#x       using the following APIs: IxTclNetwork. This parameter is valid only on -mode create when -count is greater than one.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -vlan_user_priority
#x       Defines the Vlan user priority for Access Node. This parameter is
#x       supported using the following APIs: IxTclNetwork.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#x   -vlan_user_priority_inner
#x       Defines the Inner Vlan user priority for Access Node. This parameter is
#x       supported using the following APIs: IxTclNetwork.
#x       Valid for functional_specification: v4_compatible, v4_v6_compatible.
#n   -vpi
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vpi_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vpi_repeat
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vpi_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -functional_specification
#n   -args
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_mac_ignore_mask
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -spfc_mac_address_pool
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -protocol_name
#x       Name of the dhcp protocol as it should appear in the IxNetwork GUI
#x   -use_rapid_commit
#x       Enable DHCP Server to negotiate leases with rapid commit for DHCP Clients that request it.
#x   -echo_relay_info
#x       Enable echoing of DHCP option 82.
#x   -pool_address_increment
#x       The increment value for the lease address within the lease pool.
#x   -pool_address_increment_step
#x       The increment step value for the lease address within the lease pool.
#x   -start_pool_prefix
#x       The prefix of the first lease pool.
#x   -start_pool_prefix_step
#x       The prefix step of the first lease pool.
#x   -pool_prefix_increment
#x       The increment value for the lease prefix within the lease pool.
#x   -pool_prefix_increment_step
#x       The increment step value for the lease prefix within the lease pool.
#x   -pool_prefix_size
#x       The number of leases to be allocated per each server prefix.
#x   -prefix_length
#x       The subnet address length advertised in DHCP Offer and Replay messages
#x   -dns_domain
#x       The domain name to be searched during name resolution advertised in DHCP Offer and Reply messages.
#x   -custom_renew_time
#x       The time (in seconds) after the client will start renewing the leases from the server.
#x   -custom_rebind_time
#x       The time (in seconds) after the client will start rebinding the leases from the server.
#x   -use_custom_times
#x       Use Custom Renew/Rebind Times instead of the ones computed from the valability times of the leases.
#x   -enable_resolve_gateway
#x       Autoresolve gateway MAC addresses.
#x   -manual_gateway_mac
#x       The manual gateway MAC addresses.
#x       This option has no effect unless enable_resolve_gateway is set to 0.
#x   -manual_gateway_mac_step
#x       The step of the manual gateway MAC addresses.
#x       This option has no effect unless enable_resolve_gateway is set to 0.
#x   -reconfigure_rate_scale_mode
#x       Indicates whether the control is specified per port or per device group
#x   -reconfigure_rate_enabled
#x       Enabled
#x   -reconfigure_rate_max_outstanding
#x       The number of triggered instances of an action that is still awaiting a response or completion
#x   -reconfigure_rate_interval
#x       Time interval used to calculate the rate for triggering an action(rate = count/interval)
#x   -reconfigure_rate
#x       Number of times an action is triggered per time interval
#x   -pool_count
#x       The number of DHCP pools a single server has
#x   -enable_address_match_duid
#x       If enabled, the requests with DUIDs matching the mask and pattern will be assigned addresses from this pool.
#x   -address_duid_mask
#x       The mask based on which the DUIDs are chosen for address assignment.
#x   -address_duid_pattern
#x       The pattern based on which the DUIDs are chosen for address assignment.
#x   -addresses_per_ia
#x       The number of Addreses the Server offers for each IA.
#x   -enable_prefix_match_duid
#x       If enabled, the requests with DUIDs matching DUID start and increment will be given a specific prefix from this pool.
#x   -prefix_duid_start
#x       The first DUID which will be chosen for prefix assignment.
#x   -prefix_duid_increment
#x       The increment used to generate the DUIDs which will be chosen for prefix assignment.
#x   -prefixes_per_ia
#x       The number of Prefixes the Server offers for each IA.
#x   -duid_match_nak
#x       If enabled, the requests with DUIDs matching the mask and pattern will be NAKed by the Server.
#x   -duid_nak_mask
#x       The mask based on which the DUIDs of NAKed addresses are chosen.
#x   -duid_nak_pattern
#x       The pattern based on which the DUIDs of NAKed addresses are chosen.
#x   -duid_match_ignore
#x       If enabled, the requests with DUIDs matching the mask and pattern will be ignored by the Server.
#x   -duid_ignore_mask
#x       The mask based on which the DUIDs of ignored addresses are chosen.
#x   -duid_ignore_pattern
#x       The pattern based on which the DUIDs of ignored addresses are chosen.
#
# Return Values:
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:handle               value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    $::SUCCESS | $::FAILURE Status of procedure call.
#    key:status               value:$::SUCCESS | $::FAILURE Status of procedure call.
#    When status is failure, contains more information.
#    key:log                  value:When status is failure, contains more information.
#    The port handle on which DHCP emulation was configured.
#    key:handle.port_handle   value:The port handle on which DHCP emulation was configured.
#    The handle of the DHCP emulation.
#    key:handle.dhcp_handle   value:The handle of the DHCP emulation.
#    Handle of any dhcpv4 endpoints configured
#    key:dhcpv4server_handle  value:Handle of any dhcpv4 endpoints configured
#    Handle of any dhcpv6 endpoints configured
#    key:dhcpv6server_handle  value:Handle of any dhcpv6 endpoints configured
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    When -handle is provided with the /globals value the arguments that configure global protocol
#    setting accept both multivalue handles and simple values.
#    When -handle is provided with a a protocol stack handle or a protocol session handle, the arguments
#    that configure global settings will only accept simple values. In this situation, these arguments will
#    configure only the settings of the parent device group or the ports associated with the parent topology.
#    If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  handle
#
# See Also:
#

proc ::ixiangpf::emulation_dhcp_server_config { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "emulation_dhcp_server_config" $notImplementedParams $mandatoryParams $fileParams $args]
}
