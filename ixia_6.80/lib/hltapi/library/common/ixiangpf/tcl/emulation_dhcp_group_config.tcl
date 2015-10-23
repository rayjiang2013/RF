##Procedure Header
# Name:
#    ::ixiangpf::emulation_dhcp_group_config
#
# Description:
#    Configures and modifies a group of DHCP subscribers where each
#    group share a set of common characteristics.
#    This proc can be invoked multiple times to create multiple
#    groups of subscribers on a port with characteristics different
#    from other groups or for independent control purposes.
#    This command allows the user to configure a specified number of DHCP
#    client sessions which belong to a subscriber group with specific Layer 2
#    network settings. Once the subscriber group has been configured a handle
#    is created, which can be used to modify the parameters or reset
#    sessions for the subscriber.
#
# Synopsis:
#    ::ixiangpf::emulation_dhcp_group_config
#        [-encap                                        CHOICES ethernet_ii
#                                                       CHOICES ethernet_ii_vlan
#                                                       CHOICES ethernet_ii_qinq
#                                                       CHOICES vc_mux_ipv4_routed
#                                                       CHOICES vc_mux_fcs
#                                                       CHOICES vc_mux
#                                                       CHOICES vc_mux_ipv6_routed
#                                                       CHOICES llcsnap_routed
#                                                       CHOICES llcsnap_fcs
#                                                       CHOICES llcsnap
#                                                       CHOICES llcsnap_ppp
#                                                       CHOICES vc_mux_ppp
#                                                       DEFAULT ethernet_ii]
#        [-mac_addr                                     MAC]
#        [-mac_addr_step                                MAC
#                                                       DEFAULT 00.00.00.00.00.01]
#        [-num_sessions                                 RANGE 1-65536]
#n       [-pvc_incr_mode                                ANY]
#        [-qinq_incr_mode                               CHOICES inner outer both
#                                                       DEFAULT inner]
#n       [-sessions_per_vc                              ANY]
#n       [-vci                                          ANY]
#n       [-vci_count                                    ANY]
#n       [-vci_step                                     ANY]
#        [-vlan_id                                      RANGE 0-4095
#                                                       DEFAULT 4094]
#        [-vlan_id_count                                RANGE 0-4095
#                                                       DEFAULT 4094]
#        [-vlan_id_outer                                NUMERIC]
#        [-vlan_id_outer_count                          RANGE 1-4094]
#        [-vlan_id_outer_step                           RANGE 1-4094]
#        [-vlan_id_step                                 RANGE 0-4095]
#n       [-vpi                                          ANY]
#n       [-vpi_count                                    ANY]
#n       [-vpi_step                                     ANY]
#x       [-dhcp6_range_duid_enterprise_id               NUMERIC
#x                                                      DEFAULT 10]
#x       [-dhcp6_range_duid_type                        CHOICES duid_llt duid_en duid_ll
#x                                                      DEFAULT duid_llt]
#x       [-dhcp6_range_duid_vendor_id                   NUMERIC
#x                                                      DEFAULT 10]
#x       [-dhcp6_range_duid_vendor_id_increment         NUMERIC
#x                                                      DEFAULT 1]
#x       [-dhcp6_range_ia_id                            NUMERIC
#x                                                      DEFAULT 10]
#x       [-dhcp6_range_ia_id_increment                  NUMERIC
#x                                                      DEFAULT 1]
#x       [-dhcp6_range_ia_t1                            NUMERIC
#x                                                      DEFAULT 302400]
#x       [-dhcp6_range_ia_t2                            NUMERIC
#x                                                      DEFAULT 483840]
#x       [-dhcp6_range_ia_type                          CHOICES iana iata iapd iana_iapd
#x                                                      DEFAULT iana]
#x       [-dhcp6_range_max_no_per_client                NUMERIC
#x                                                      DEFAULT 1]
#x       [-dhcp6_range_iana_count                       NUMERIC
#x                                                      DEFAULT 1]
#x       [-dhcp6_range_iapd_count                       NUMERIC
#x                                                      DEFAULT 1]
#x       [-dhcp6_range_ia_id_inc                        NUMERIC
#x                                                      DEFAULT 1]
#n       [-dhcp6_range_param_request_list               ANY]
#x       [-dhcp_range_ip_type                           CHOICES ipv4 ipv6
#x                                                      DEFAULT ipv4]
#n       [-dhcp_range_param_request_list                ANY]
#x       [-dhcp_range_renew_timer                       NUMERIC
#x                                                      DEFAULT 0]
#x       [-dhcp_range_server_address                    IP
#x                                                      DEFAULT 10.0.0.1]
#x       [-dhcp_range_use_first_server                  CHOICES 0 1
#x                                                      DEFAULT 1]
#n       [-dhcp_range_use_trusted_network_element       ANY]
#x       [-mac_mtu                                      RANGE 500-9216
#x                                                      DEFAULT 1500]
#n       [-no_write                                     ANY]
#n       [-server_id                                    ANY]
#n       [-target_subport                               ANY]
#x       [-use_vendor_id                                CHOICES 0 1
#x                                                      DEFAULT 0]
#x       [-vendor_id                                    ANY
#x                                                      DEFAULT Ixia]
#n       [-version                                      ANY]
#x       [-vlan_id_outer_increment_step                 RANGE 0-4093
#x                                                      DEFAULT 1]
#x       [-vlan_id_increment_step                       RANGE 0-4093
#x                                                      DEFAULT 1]
#x       [-vlan_id_outer_priority                       RANGE 0-7
#x                                                      DEFAULT 0]
#x       [-vlan_user_priority                           RANGE 0-7
#x                                                      DEFAULT 0]
#        [-mode                                         CHOICES create
#                                                       CHOICES create_relay_agent
#                                                       CHOICES modify
#                                                       CHOICES reset
#                                                       DEFAULT create]
#        -handle                                        ANY
#n       [-release_rate                                 ANY]
#n       [-request_rate                                 ANY]
#x       [-use_rapid_commit                             CHOICES 0 1
#x                                                      DEFAULT 0]
#x       [-protocol_name                                ALPHA]
#x       [-dhcp4_broadcast                              CHOICES 0 1
#x                                                      DEFAULT 0]
#x       [-enable_stateless                             CHOICES 0 1
#x                                                      DEFAULT 0]
#x       [-dhcp6_use_pd_global_address                  CHOICES 0 1
#x                                                      DEFAULT 0]
#x       [-dhcp_range_relay_type                        CHOICES normal lightweight
#x                                                      DEFAULT normal]
#x       [-dhcp_range_use_relay_agent                   CHOICES 0 1
#x                                                      DEFAULT 0]
#x       [-dhcp_range_relay_count                       RANGE 1-1000000
#x                                                      DEFAULT 1]
#x       [-dhcp_range_relay_override_vlan_settings      CHOICES 0 1
#x                                                      DEFAULT 0]
#x       [-dhcp_range_relay_first_vlan_id               RANGE 0-4095
#x                                                      DEFAULT 1]
#x       [-dhcp_range_relay_vlan_increment              RANGE 0-4093
#x                                                      DEFAULT 1]
#x       [-dhcp_range_relay_vlan_count                  RANGE 1-4094
#x                                                      DEFAULT 1]
#x       [-dhcp_range_relay_destination                 IP
#x                                                      DEFAULT 20.0.0.1]
#x       [-dhcp_range_relay_first_address               IP
#x                                                      DEFAULT 20.0.0.100]
#x       [-dhcp_range_relay_address_increment           IP
#x                                                      DEFAULT 0.0.0.1]
#x       [-dhcp_range_relay_subnet                      RANGE 1-128
#x                                                      DEFAULT 24]
#x       [-dhcp_range_relay_gateway                     IP
#x                                                      DEFAULT 20.0.0.1]
#n       [-dhcp_range_relay_use_circuit_id              ANY]
#n       [-dhcp_range_relay_circuit_id                  ANY]
#n       [-dhcp_range_relay_hosts_per_circuit_id        ANY]
#n       [-dhcp_range_relay_use_remote_id               ANY]
#n       [-dhcp_range_relay_remote_id                   ANY]
#n       [-dhcp_range_relay_hosts_per_remote_id         ANY]
#n       [-dhcp_range_relay_use_suboption6              ANY]
#n       [-dhcp_range_suboption6_address_subnet         ANY]
#n       [-dhcp_range_suboption6_first_address          ANY]
#n       [-dhcp_range_relay6_use_opt_interface_id       ANY]
#n       [-dhcp_range_relay6_opt_interface_id           ANY]
#n       [-dhcp_range_relay6_hosts_per_opt_interface_id ANY]
#x       [-dhcp4_gateway_address                        IP
#x                                                      DEFAULT 0.0.0.0]
#x       [-dhcp4_gateway_mac                            MAC
#x                                                      DEFAULT 00.00.00.00.00.00]
#x       [-dhcp6_gateway_address                        IPV6
#x                                                      DEFAULT 0:0:0:0:0:0:0:0]
#x       [-dhcp6_gateway_mac                            MAC
#x                                                      DEFAULT 00.00.00.00.00.00]
#x       [-dhcpv6_multiplier                            NUMERIC]
#
# Arguments:
#    -encap
#        Note: ethernet_ii_qinq is not supported with IxTclHal.
#        Valid for IxTclHal and IxTclNetwork.
#    -mac_addr
#        Specifies the base (first) MAC address to use when emulating
#        multiple clients. This parameter is mandatory when -mode is "create".
#        Valid for IxTclHal and IxTclNetwork.
#    -mac_addr_step
#        Specifies the step value applied to the base MAC address for each
#        subsequent emulated client. It must be provided in the integer format
#        (unlike ixTclHal where it is provided in MAC address format). The
#        step MAC address is arithmetically added to the base MAC address with
#        any overflow beyond 48 bits silently discarded.
#        Valid for IxTclHal and IxTclNetwork.
#    -num_sessions
#        Indicates the number of DHCP clients emulated.
#        The default value is 4096.
#        Valid for IxTclHal and IxTclNetwork.
#n   -pvc_incr_mode
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -qinq_incr_mode
#        The Method used to increment VLAN IDs.
#        Valid for IxTclHal and IxTclNetwork.
#n   -sessions_per_vc
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vci
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vci_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vci_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -vlan_id
#        The first VLAN ID to be used for the outer VLAN tag.
#        Valid for IxTclHal and IxTclNetwork.
#    -vlan_id_count
#        The number of unique outer VLAN IDs that will be created. The default
#        value is 4094.
#        Valid for IxTclHal and IxTclNetwork.
#    -vlan_id_outer
#        The first VLAN ID to be used for the inner VLAN tag.
#        Valid for IxTclNetwork.
#    -vlan_id_outer_count
#        The number of unique inner VLAN IDs that will be created.
#        Valid for IxTclNetwork.
#    -vlan_id_outer_step
#        The value to be added to the inner VLAN ID for each new assignment.
#        Valid for IxTclNetwork.
#    -vlan_id_step
#        The value to be added to the outer VLAN ID for each new assignment.
#        Valid for IxTclHal and IxTclNetwork.
#n   -vpi
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vpi_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vpi_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -dhcp6_range_duid_enterprise_id
#x       The vendor's registered Private Enterprise Number maintained by IANA.
#x       The default value is 10.
#x       Valid for IxTclNetwork.
#x   -dhcp6_range_duid_type
#x       DHCP Unique Identifier (DUID) Type.
#x       Valid for IxTclNetwork.
#x   -dhcp6_range_duid_vendor_id
#x       The Option Request option is used to identify a list of options in a
#x       message between a client and a server.
#x       Valid for IxTclNetwork.
#x   -dhcp6_range_duid_vendor_id_increment
#x       The value by which the VENDOR-ID is incremented for each DHCP client.
#x       The default value is 1.
#x       Valid for IxTclNetwork.
#x   -dhcp6_range_ia_id
#x       Identity Association (IA) Unique Identifier. This Id is incremented
#x       automatically for each DHCP client. The default value is 10.
#x       Valid for IxTclNetwork.
#x   -dhcp6_range_ia_id_increment
#x       The value by which the IA-ID is incremented for each DHCP client.
#x       The default is 1.
#x       Valid for IxTclNetwork.
#x   -dhcp6_range_ia_t1
#x       The suggested time, in seconds, at which the client contacts the server
#x       to extend the lifetimes of the assigned addresses. The default value is
#x       302400.
#x       Valid for IxTclNetwork.
#x   -dhcp6_range_ia_t2
#x       The suggested time, in seconds, at which the client contacts any
#x       available server to extend the lifetimes of the addresses assigned.
#x       The default value is 483840.
#x       Valid for IxTclNetwork.
#x   -dhcp6_range_ia_type
#x       The Identity Association Type. The IA types are IANA, IATA, and IAPD.
#x       The default is IANA.
#x       Valid for IxTclNetwork.
#x   -dhcp6_range_max_no_per_client
#x       The maximum number of addresses/prefixes that can be negotiated by a DHCPv6 Client.
#x       The default value is 1. Valid for IxTclNetwork.
#x   -dhcp6_range_iana_count
#x       The number of IANA IAs requested in a single negotiation. The default value is 1.
#x       Valid for IxTclNetwork.
#x   -dhcp6_range_iapd_count
#x       The number of IAPD IAs requested in a single negotiation. The default value is 1.
#x       Valid for IxTclNetwork.
#x   -dhcp6_range_ia_id_inc
#x       The increment with which IAID is incremented for each IA solicited by a DHCPv6 Client.
#x       The default value is 1. Valid for IxTclNetwork.
#n   -dhcp6_range_param_request_list
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -dhcp_range_ip_type
#x       Defines the IP address version to be used for the range: IPv4 or IPv6.
#x       The default value is IPv4.
#x       Valid for IxTclNetwork.
#n   -dhcp_range_param_request_list
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -dhcp_range_renew_timer
#x       When an address is allocated or reallocated, the client starts two timers
#x       that control the renewal process. The renewal process is designed to
#x       ensure that a client's lease can be extended before it is scheduled to end.
#x       Valid for IxTclNetwork.
#x   -dhcp_range_server_address
#x       The address of the DHCP server from which the subnet will accept IP addresses.
#x       Valid for IxTclNetwork.
#x   -dhcp_range_use_first_server
#x       If enabled, the subnet accepts the IP addresses offered by the first
#x       server to respond to the DHCPDISCOVER message.
#x       Valid for IxTclNetwork.
#n   -dhcp_range_use_trusted_network_element
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -mac_mtu
#x       The maximum transmission unit for the interfaces created with this range.
#x       The default value is 1500.
#x       Valid for IxTclNetwork.
#n   -no_write
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -server_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -target_subport
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -use_vendor_id
#x       Enables or disables the use of the Vendor Class Identifier.
#x       Valid for IxTclNetwork.
#x   -vendor_id
#x       The vendor ID associated with the client.
#x       The default value is "Ixia".
#x       Valid for IxTclHal, IxTclNetwork.
#n   -version
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -vlan_id_outer_increment_step
#x       How often a new outer VLAN ID is generated, if encapsulation is ethernet_ii_qinq.
#x       Valid for IxTclNetwork.
#x   -vlan_id_increment_step
#x       How often a new outer VLAN ID is generated, if encapsulation is ethernet_ii_vlan. Otherwise, specifies
#x       how often a new inner VLAN ID is generated, if encapsulation is ethernet_ii_qinq.
#x       Valid for IxTclNetwork.
#x   -vlan_id_outer_priority
#x       The 802.1Q priority for the inner VLAN.
#x       Valid for IxTclNetwork.
#x   -vlan_user_priority
#x       The 802.1Q priority for the outer VLAN.
#x       Valid for IxTclNetwork.
#    -mode
#        Action to take on the port specified the handle argument.
#    -handle
#        Specifies the port and group upon which emulation is configured.If
#        the -mode is "modify", -handle specifies the group upon which
#        emulation is configured, otherwise it specifies the session upon
#        which emulation is configured.
#        Valid for IxTclHal and IxTclNetwork.
#n   -release_rate
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -request_rate
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -use_rapid_commit
#x       Enable DHCP Client to negotiate leases with rapid commit.
#x   -protocol_name
#x       Name of the dhcp protocol as it should appear in the IxNetwork GUI.
#x   -dhcp4_broadcast
#x       If enabled, ask the server or relay agent to use the broadcast IP address in the replies.
#x   -enable_stateless
#x       Enable DHCP stateless.
#x   -dhcp6_use_pd_global_address
#x       Use DHCPc6-PD global addressing.
#x   -dhcp_range_relay_type
#x       Defines the relay agent type to be used: normal or lightweight.
#x       The default value is normal. Valid only for dhcpv6.
#x       Valid for IxTclNetwork.
#x   -dhcp_range_use_relay_agent
#x       If true, the subnet will emulate a DHCP relay agent (added before the DHCP device group).
#x       Valid for IxTclNetwork.
#x   -dhcp_range_relay_count
#x       The number of relay agents to use in this range. Note that the number
#x       of Ethernet or ATM interfaces used by a range has to be equal to the
#x       number of DHCP clients plus the number of relay agents, and the relay
#x       agent count cannot exceed the number of DHCP clients defined on the Ixia
#x       port. The default is 1.
#x       Valid for IxTclNetwork.
#x   -dhcp_range_relay_override_vlan_settings
#x       If true, the DHCP plug-in overrides the VLAN settings, thereby allowing
#x       you to specify how VLANs are assigned.
#x       Valid for IxTclNetwork.
#x   -dhcp_range_relay_first_vlan_id
#x       The first (outer) VLAN ID to allocate to relay agent interfaces. The
#x       default is 1.
#x       Valid for IxTclNetwork.
#x   -dhcp_range_relay_vlan_increment
#x       The VLAN increment to use for relay interfaces. The default is 1.
#x       Valid for IxTclNetwork.
#x   -dhcp_range_relay_vlan_count
#x       The number of different VLAN IDs to use. The default is 1.
#x       Valid for IxTclNetwork.
#x   -dhcp_range_relay_destination
#x       The address to which the requests from DHCP clients are forwarded. The
#x       default value is 20.0.0.1.
#x       Valid for IxTclNetwork.
#x   -dhcp_range_relay_first_address
#x       The IP address of the first emulated DHCP Relay Agent. The DHCP network
#x       stack element will create one relay agent on each port contained in the
#x       current port and current range. The default value is 20.0.0.100.
#x       Valid for IxTclNetwork.
#x   -dhcp_range_relay_address_increment
#x       The value by which to increment the IP address for each relay agent.
#x       The default value is 0.0.0.1.
#x       Valid for IxTclNetwork.
#x   -dhcp_range_relay_subnet
#x       The network mask (expressed as a prefix length) used for all relay agents.
#x       The default value is 24.
#x       Valid for IxTclNetwork.
#x   -dhcp_range_relay_gateway
#x       The gateway address used for all relay agents. Default value is 20.0.0.1.
#x       Valid for IxTclNetwork.
#n   -dhcp_range_relay_use_circuit_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_range_relay_circuit_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_range_relay_hosts_per_circuit_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_range_relay_use_remote_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_range_relay_remote_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_range_relay_hosts_per_remote_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_range_relay_use_suboption6
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_range_suboption6_address_subnet
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_range_suboption6_first_address
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_range_relay6_use_opt_interface_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_range_relay6_opt_interface_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp_range_relay6_hosts_per_opt_interface_id
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -dhcp4_gateway_address
#x       The Gateway IP Address for the session.
#x       Valid for IxTclNetwork.
#x   -dhcp4_gateway_mac
#x       The Gateway Mac for the session.
#x       Valid for IxTclNetwork.
#x   -dhcp6_gateway_address
#x       The Gateway IPv6 Address for the session.
#x       Valid for IxTclNetwork.
#x   -dhcp6_gateway_mac
#x       The Gateway Mac for the session.
#x       Valid for IxTclNetwork.
#x   -dhcpv6_multiplier
#x       Number of layer instances per parent instance (multiplier)
#
# Return Values:
#    A list containing the dhcpv6 iapd protocol stack handles that were added by the command (if any).
#x   key:dhcpv6_iapd_handle       value:A list containing the dhcpv6 iapd protocol stack handles that were added by the command (if any).
#    A list containing the dhcpv6 iana protocol stack handles that were added by the command (if any).
#x   key:dhcpv6_iana_handle       value:A list containing the dhcpv6 iana protocol stack handles that were added by the command (if any).
#    $::SUCCESS | $::FAILURE
#    key:status                   value:$::SUCCESS | $::FAILURE
#    When status is failure, contains more info
#    key:log                      value:When status is failure, contains more info
#    Handle of the dhcp endpoint configured Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    key:handle                   value:Handle of the dhcp endpoint configured Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    Handle of any dhcpv4 endpoints configured
#    key:dhcpv4client_handle      value:Handle of any dhcpv4 endpoints configured
#    Handle of any dhcpv6 endpoints configured
#    key:dhcpv6client_handle      value:Handle of any dhcpv6 endpoints configured
#    Handle of any dhcpv4 relay agents configured
#    key:dhcpv4relayagent_handle  value:Handle of any dhcpv4 relay agents configured
#    Handle of any dhcpv6 relay agents configured
#    key:dhcpv6relayagent_handle  value:Handle of any dhcpv6 relay agents configured
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  handle
#
# See Also:
#

proc ::ixiangpf::emulation_dhcp_group_config { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "emulation_dhcp_group_config" $notImplementedParams $mandatoryParams $fileParams $args]
}
