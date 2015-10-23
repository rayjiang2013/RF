##Procedure Header
# Name:
#    ixiangpf::dhcp_extension_stats
#
# Description:
#    Retrieves statistics for the DHCPv6PD sessions configured on the
#    specified test port.
#
# Synopsis:
#    ixiangpf::dhcp_extension_stats
#        -mode         CHOICES aggregate session
#                      DEFAULT aggregate
#        [-port_handle REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
#        [-handle      ANY]
#
# Arguments:
#    -mode
#        Specifies statistics retrieval mode as either aggregate for all
#        configured sessions or on a per session basis.
#    -port_handle
#        The port handle for which the DHCPv6 sessions statistics needs to be
#        retrieved. Valid only when using IxNetwork.
#    -handle
#        The port for which the DHCPv6 sessions statistics needs to be
#        retrieved. The statistics will be retrieved
#        for the port where that handle belongs.
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status                                                            value:$::SUCCESS | $::FAILURE
#    If status is failure, detailed information provided.
#    key:log                                                               value:If status is failure, detailed information provided.
#    The stats can be used with or without <port_handle>. These stats are only available with IxNetwork.
#    key:AGGREGATE STATS:                                                  value:The stats can be used with or without <port_handle>. These stats are only available with IxNetwork.
#    Server Solicits Received
#    key:[<port_handle.>].aggregate.dhcpv6_solicits_received               value:Server Solicits Received
#    Server Advertisements Sent
#    key:[<port_handle.>].aggregate.dhcpv6_advertisements_sent             value:Server Advertisements Sent
#    Server Requests Received
#    key:[<port_handle.>].aggregate.dhcpv6_requests_received               value:Server Requests Received
#    Server Confirms Received
#    key:[<port_handle.>].aggregate.dhcpv6_confirms_received               value:Server Confirms Received
#    Server Renewals Received
#    key:[<port_handle.>].aggregate.dhcpv6_renewals_received               value:Server Renewals Received
#    Server Rebinds Received
#    key:[<port_handle.>].aggregate.dhcpv6_rebinds_received                value:Server Rebinds Received
#    Server Replies Sent
#    key:[<port_handle.>].aggregate.dhcpv6_replies_sent                    value:Server Replies Sent
#    Server Releases Received
#    key:[<port_handle.>].aggregate.dhcpv6_releases_received               value:Server Releases Received
#    Server Declines Received
#    key:[<port_handle.>].aggregate.dhcpv6_declines_received               value:Server Declines Received
#    Server Information-Requests Received
#    key:[<port_handle.>].aggregate.dhcpv6_information_requests_received   value:Server Information-Requests Received
#    Server Total Prefixes Allocated
#    key:[<port_handle.>].aggregate.dhcpv6_total_prefixes_allocated        value:Server Total Prefixes Allocated
#    Server Total Prefixes Renewed
#    key:[<port_handle.>].aggregate.dhcpv6_total_prefixes_renewed          value:Server Total Prefixes Renewed
#    Server Current Prefixes Allocated
#    key:[<port_handle.>].aggregate.dhcpv6_current_prefixes_allocated      value:Server Current Prefixes Allocated
#    Client Addresses Discovered
#    key:[<port_handle.>].aggregate.dhcpv6_addresses_discovered            value:Client Addresses Discovered
#    Client Advertisements Ignored
#    key:[<port_handle.>].aggregate.dhcpv6_advertisements_ignored          value:Client Advertisements Ignored
#    Client Advertisements Received
#    key:[<port_handle.>].aggregate.dhcpv6_advertisements_received         value:Client Advertisements Received
#    Client Enabled Interfaces
#    key:[<port_handle.>].aggregate.dhcpv6_enabled_interfaces              value:Client Enabled Interfaces
#    Client Rebinds Sent
#    key:[<port_handle.>].aggregate.dhcpv6_rebinds_sent                    value:Client Rebinds Sent
#    Client Releases Sent
#    key:[<port_handle.>].aggregate.dhcpv6_releases_sent                   value:Client Releases Sent
#    Client Renews Sent
#    key:[<port_handle.>].aggregate.dhcpv6_renews_sent                     value:Client Renews Sent
#    Client Replies Received
#    key:[<port_handle.>].aggregate.dhcpv6_replies_received                value:Client Replies Received
#    Client Requests Sent
#    key:[<port_handle.>].aggregate.dhcpv6_requests_sent                   value:Client Requests Sent
#    Client Sessions Failed
#    key:[<port_handle.>].aggregate.dhcpv6_sessions_failed                 value:Client Sessions Failed
#    Client Sessions Initiated
#    key:[<port_handle.>].aggregate.dhcpv6_sessions_initiated              value:Client Sessions Initiated
#    Client Sessions Succeeded
#    key:[<port_handle.>].aggregate.dhcpv6_sessions_succeeded              value:Client Sessions Succeeded
#    Client Setup Success Rate
#    key:[<port_handle.>].aggregate.dhcpv6_setup_success_rate              value:Client Setup Success Rate
#    Client Solicits Sent
#    key:[<port_handle.>].aggregate.dhcpv6_solicits_sent                   value:Client Solicits Sent
#    Client Teardown Fail
#    key:[<port_handle.>].aggregate.dhcpv6_teardown_fail                   value:Client Teardown Fail
#    Client Teardown Initiated
#    key:[<port_handle.>].aggregate.dhcpv6_teardown_initiated              value:Client Teardown Initiated
#    Client Teardown Success
#    key:[<port_handle.>].aggregate.dhcpv6_teardown_success                value:Client Teardown Success
#    Client Information Requests Sent
#    key:[<port_handle.>].aggregate.dhcpv6_information_requests_sent       value:Client Information Requests Sent
#    Client Min Establishment Time
#    key:[<port_handle.>].aggregate.dhcpv6_min_establishment_time          value:Client Min Establishment Time
#    Client Avg Establishment Time
#    key:[<port_handle.>].aggregate.dhcpv6_avg_establishment_time          value:Client Avg Establishment Time
#    Client Max Establishment Time
#    key:[<port_handle.>].aggregate.dhcpv6_max_establishment_time          value:Client Max Establishment Time
#    These stats are only available with IxNetwork.
#    key:SESSION STATS:                                                    value:These stats are only available with IxNetwork.
#    Lease Name
#    key:session.server.<session ID>.dhcpv6_lease_name                     value:Lease Name
#    Offer Count
#    key:session.server.<session ID>.dhcpv6_offer_count                    value:Offer Count
#    Bind Count
#    key:session.server.<session ID>.dhcpv6_bind_count                     value:Bind Count
#    Bind Rapid Commit Count
#    key:session.server.<session ID>.dhcpv6_bind_rapid_commit_count        value:Bind Rapid Commit Count
#    Renew Count
#    key:session.server.<session ID>.dhcpv6_renew_count                    value:Renew Count
#    Release Count
#    key:session.server.<session ID>.dhcpv6_release_count                  value:Release Count
#    Information-Requests Received
#    key:session.server.<session ID>.dhcpv6_information_request_received   value:Information-Requests Received
#    Replies Sent
#    key:session.server.<session ID>.dhcpv6_replies_sent                   value:Replies Sent
#    Lease State
#    key:session.server.<session ID>.dhcpv6_lease_state                    value:Lease State
#    Lease Address
#    key:session.server.<session ID>.dhcpv6_lease_address                  value:Lease Address
#    Valid Time
#    key:session.server.<session ID>.dhcpv6_valid_time                     value:Valid Time
#    Prefered Time
#    key:session.server.<session ID>.dhcpv6_prefered_time                  value:Prefered Time
#    Renew Time
#    key:session.server.<session ID>.dhcpv6_renew_time                     value:Renew Time
#    Rebind Time
#    key:session.server.<session ID>.dhcpv6_rebind_time                    value:Rebind Time
#    Client ID
#    key:session.server.<session ID>.dhcpv6_client_id                      value:Client ID
#    Remote ID
#    key:session.server.<session ID>.dhcpv6_remote_id                      value:Remote ID
#    Session Name
#    key:session.client.<session ID>.dhcpv6_session_name                   value:Session Name
#    Solicits Sent
#    key:session.client.<session ID>.dhcpv6_solicits_sent                  value:Solicits Sent
#    Advertisements Received
#    key:session.client.<session ID>.dhcpv6_advertisements_received        value:Advertisements Received
#    Advertisements Ignored
#    key:session.client.<session ID>.dhcpv6_advertisements_ignored         value:Advertisements Ignored
#    Requests Sent
#    key:session.client.<session ID>.dhcpv6_requests_sent                  value:Requests Sent
#    Replies Received
#    key:session.client.<session ID>.dhcpv6_replies_received               value:Replies Received
#    Renews Sent
#    key:session.client.<session ID>.dhcpv6_renews_sent                    value:Renews Sent
#    Rebinds Sent
#    key:session.client.<session ID>.dhcpv6_rebinds_sent                   value:Rebinds Sent
#    Releases Sent
#    key:session.client.<session ID>.dhcpv6_releases_sent                  value:Releases Sent
#    IP Prefix
#    key:session.client.<session ID>.dhcpv6_ip_prefix                      value:IP Prefix
#    Gateway Address
#    key:session.client.<session ID>.dhcpv6_gateway_address                value:Gateway Address
#    DNS Server List
#    key:session.client.<session ID>.dhcpv6_dns_server_list                value:DNS Server List
#    Prefix Lease Time
#    key:session.client.<session ID>.dhcpv6_prefix_lease_time              value:Prefix Lease Time
#    Information Requests Sent
#    key:session.client.<session ID>.dhcpv6_onformation_requests_sent      value:Information Requests Sent
#    DNS Search List
#    key:session.client.<session ID>.dhcpv6_dns_search_list                value:DNS Search List
#    Solicits w/ Rapid Commit Sent
#    key:session.client.<session ID>.dhcpv6_solicits_rapid_commit_sent     value:Solicits w/ Rapid Commit Sent
#    Replies w/ Rapid Commit Received
#    key:session.client.<session ID>.dhcpv6_replies_rapid_commit_received  value:Replies w/ Rapid Commit Received
#    Lease w/ Rapid Commit
#    key:session.client.<session ID>.dhcpv6_lease_rapid_commit             value:Lease w/ Rapid Commit
#
# Examples:
#    See files in the Samples/IxNetwork/L2TP subdirectory.
#
# Sample Input:
#    .
#
# Sample Output:
#    .
#
# Notes:
#
# See Also:
#

package ixiangpf;

use utils;
use ixiahlt;

sub dhcp_extension_stats {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('dhcp_extension_stats', $args);
	# ixiahlt::utrackerLog ('dhcp_extension_stats', $args);

	return ixiangpf::runExecuteCommand('dhcp_extension_stats', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
