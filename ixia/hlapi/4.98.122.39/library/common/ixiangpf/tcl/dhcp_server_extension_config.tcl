##Procedure Header
# Name:
#    ::ixiangpf::dhcp_server_extension_config
#
# Description:
#    Configures DHCPv6 server extension for the specified protocol stack (PPP, L2TP etc).
#
# Synopsis:
#    ::ixiangpf::dhcp_server_extension_config
#x       -handle                                      ANY
#n       [-dhcp6_pgdata_max_outstanding_releases      ANY]
#n       [-dhcp6_pgdata_max_outstanding_requests      ANY]
#n       [-dhcp6_pgdata_override_global_setup_rate    ANY]
#n       [-dhcp6_pgdata_override_global_teardown_rate ANY]
#n       [-dhcp6_pgdata_setup_rate_increment          ANY]
#n       [-dhcp6_pgdata_setup_rate_initial            ANY]
#n       [-dhcp6_pgdata_setup_rate_max                ANY]
#n       [-dhcp6_pgdata_teardown_rate_increment       ANY]
#n       [-dhcp6_pgdata_teardown_rate_initial         ANY]
#n       [-dhcp6_pgdata_teardown_rate_max             ANY]
#x       [-dhcp6_server_range_dns_domain_search_list  ANY
#x                                                    DEFAULT 100]
#x       [-dhcp6_server_range_first_dns_server        IP]
#x       [-dhcp6_server_range_second_dns_server       IP]
#x       [-dhcp6_server_range_subnet_prefix           NUMERIC]
#x       [-dhcp6_server_range_start_pool_address      IP]
#x       [-mode                                       CHOICES add
#x                                                    CHOICES remove
#x                                                    CHOICES enable
#x                                                    CHOICES disable
#x                                                    CHOICES modify
#x                                                    DEFAULT add]
#
# Arguments:
#x   -handle
#x       The protocol stack on top of which DHCPv6 server extension is to be
#x       created (for -mode add).
#x       The DHCpv6 server extension that needs to be modified/removed/enabled/disabled
#x       (for -mode modify/remove/enable/disable).
#x       When -handle is provided with the /globals value the arguments that configure global protocol
#x       setting accept both multivalue handles and simple values.
#x       When -handle is provided with a a protocol stack handle or a protocol session handle, the arguments
#x       that configure global settings will only accept simple values. In this situation, these arguments will
#x       configure only the settings of the parent device group or the ports associated with the parent topology.
#n   -dhcp6_pgdata_max_outstanding_releases
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp6_pgdata_max_outstanding_requests
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp6_pgdata_override_global_setup_rate
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp6_pgdata_override_global_teardown_rate
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp6_pgdata_setup_rate_increment
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp6_pgdata_setup_rate_initial
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp6_pgdata_setup_rate_max
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp6_pgdata_teardown_rate_increment
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp6_pgdata_teardown_rate_initial
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -dhcp6_pgdata_teardown_rate_max
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -dhcp6_server_range_dns_domain_search_list
#x       Specifies the domain that the client will use when resolving host names with DNS.
#x   -dhcp6_server_range_first_dns_server
#x       The first DNS server associated with this address pool. This is the first DNS
#x       address that will be assigned to any client that is allocated an IP address from this
#x       pool.
#x   -dhcp6_server_range_second_dns_server
#x       The second DNS server associated with this address pool. This is the second (of
#x       two) DNS addresses that will be assigned to any client that is allocated an IP
#x       address from this pool.
#x   -dhcp6_server_range_subnet_prefix
#x       The prefix value used to subnet the addresses specified in the address pool. This
#x       is the subnet prefix length advertised in DHCPv6PD Offer and Reply messages.
#x   -dhcp6_server_range_start_pool_address
#x       The starting IPv6 address for this DHCPv6 address pool.
#x   -mode
#x       The action to be performed: add, modify, remove, enable, disable.
#
# Return Values:
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:handle   value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    $::SUCCESS | $::FAILURE
#    key:status   value:$::SUCCESS | $::FAILURE
#    <dhcpv6 server extension handles>
#    key:handles  value:<dhcpv6 server extension handles>
#    When status is failure, contains more information
#    key:log      value:When status is failure, contains more information
#
# Examples:
#    See files in the Samples/IxNetwork/DHCPv6 Client Extension subdirectory.
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

proc ::ixiangpf::dhcp_server_extension_config { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "dhcp_server_extension_config" $notImplementedParams $mandatoryParams $fileParams $args]
}
