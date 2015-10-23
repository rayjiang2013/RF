##Procedure Header
# Name:
#    ixiangpf::emulation_bgp_info
#
# Description:
#    Returns information about BGP neighbors.
#
# Synopsis:
#    ixiangpf::emulation_bgp_info
#        -mode    CHOICES stats
#                 CHOICES clear_stats
#                 CHOICES settings
#                 CHOICES session
#                 CHOICES neighbors
#                 CHOICES labels
#                 CHOICES learned_info
#                 CHOICES clear_learned_info
#                 CHOICES stats_per_device_group
#        -handle  ANY
#
# Arguments:
#    -mode
#        Specifies action to be taken on the BGP or BGP+ Peer handle
#    -handle
#        The BGP session handle or L3 Site handle or L2 Site handle.
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status                                                 value:$::SUCCESS | $::FAILURE
#    On status of failure, gives detailed information.
#    key:log                                                    value:On status of failure, gives detailed information.
#    These stats are per BGP neighbor. For obtaining these statistics, you need to call emulation_bgp_control -mode statistic first.
#    key:Statistics retrieved for -mode stats, IxTclProtocols.  value:These stats are per BGP neighbor. For obtaining these statistics, you need to call emulation_bgp_control -mode statistic first.
#    a.b.c.d
#    key:ip_address                                             value:a.b.c.d
#    number of keepalive messages sent
#    key:keepalive_tx                                           value:number of keepalive messages sent
#    number of keepalive messages received
#    key:keepalive_rx                                           value:number of keepalive messages received
#    number of notify messages sent
#    key:notify_tx                                              value:number of notify messages sent
#    number of notify messages received
#    key:notify_rx                                              value:number of notify messages received
#    number of routes in session
#    key:num_node_routes                                        value:number of routes in session
#    number of open messages sent
#    key:open_tx                                                value:number of open messages sent
#    number of open messages received
#    key:open_rx                                                value:number of open messages received
#    BGP peer IP address (a.b.c.e)
#    key:peers                                                  value:BGP peer IP address (a.b.c.e)
#    BGP session type
#    key:routing_protocol                                       value:BGP session type
#    number of updates sent
#    key:update_tx                                              value:number of updates sent
#    number of updates received
#    key:update_rx                                              value:number of updates received
#    number of advertised routes sent
#    key:routes_advertised_tx                                   value:number of advertised routes sent
#    number of advertised routes received
#    key:routes_advertised_rx                                   value:number of advertised routes received
#    These stats are aggregated per port. As a handle you can specify a BGP session handle or L3 Site handle, but the stats will be retrieved per port.
#    key:Statistics retrieved for -mode stats, IxTclNetwork.    value:These stats are aggregated per port. As a handle you can specify a BGP session handle or L3 Site handle, but the stats will be retrieved per port.
#    The port name.
#    key:port_name                                              value:The port name.
#    The number of BGP neighbors configured.
#    key:sessions_configured                                    value:The number of BGP neighbors configured.
#    The number of BGP sessions established.
#    key:sessions_established                                   value:The number of BGP sessions established.
#    The total number of all types of BGP messages sent.
#    key:messages_tx                                            value:The total number of all types of BGP messages sent.
#    The total number of all types of BGP messages received.
#    key:messages_rx                                            value:The total number of all types of BGP messages received.
#    The total number of BGP route updates sent.
#    key:update_tx                                              value:The total number of BGP route updates sent.
#    The total number of BGP route updates received.
#    key:update_rx                                              value:The total number of BGP route updates received.
#    The number of routes advertised.
#    key:routes_advertised                                      value:The number of routes advertised.
#    The number of routes withdrawn.
#    key:routes_withdrawn                                       value:The number of routes withdrawn.
#    The number of routes received.
#    key:routes_rx                                              value:The number of routes received.
#    The number of update messages received which have a non-empty Withdrawn Routes field.
#    key:route_withdraws_rx                                     value:The number of update messages received which have a non-empty Withdrawn Routes field.
#    The number of open messages sent.
#    key:open_tx                                                value:The number of open messages sent.
#    The number of open messages received.
#    key:open_rx                                                value:The number of open messages received.
#    The total number of keepalive messages sent. They cannot be sent more often than 1 per second,but must be sent often enough to keep the hold timer from expiring.
#    key:keepalive_tx                                           value:The total number of keepalive messages sent. They cannot be sent more often than 1 per second,but must be sent often enough to keep the hold timer from expiring.
#    The total number of keepalive messages received.
#    key:keepalive_rx                                           value:The total number of keepalive messages received.
#    The total number of notification messages sent.
#    key:notify_tx                                              value:The total number of notification messages sent.
#    The number of notification messages received.
#    key:notify_rx                                              value:The number of notification messages received.
#    The number of BGP Start Events which have occurred.
#    key:starts_occurred                                        value:The number of BGP Start Events which have occurred.
#    The number of times that graceful restarts were attempted.
#    key:graceful_restart_attempted                             value:The number of times that graceful restarts were attempted.
#    The number of times that graceful restarts were attempted but failed.
#    key:graceful_restart_failed                                value:The number of times that graceful restarts were attempted but failed.
#    The number of BGP routes received during the process of graceful restart.
#    key:routes_rx_graceful_restart                             value:The number of BGP routes received during the process of graceful restart.
#    The number of BGP neighbors that are in State Machine State Idle.
#    key:idle_state                                             value:The number of BGP neighbors that are in State Machine State Idle.
#    The number of BGP neighbors that are in State Machine State Connect.
#    key:connect_state                                          value:The number of BGP neighbors that are in State Machine State Connect.
#    The number of BGP neighbors that are in State Machine State Active.
#    key:active_state                                           value:The number of BGP neighbors that are in State Machine State Active.
#    The number of BGP neighbors that are in State Machine State OpenTx.
#    key:opentx_state                                           value:The number of BGP neighbors that are in State Machine State OpenTx.
#    The number of BGP neighbors that are in State Machine State OpenConfirm.
#    key:openconfirm_state                                      value:The number of BGP neighbors that are in State Machine State OpenConfirm.
#    The number of BGP neighbors that are in State Machine State Established.
#    key:established_state                                      value:The number of BGP neighbors that are in State Machine State Established.
#    key:Statistics retrieved for -mode neighbors:              value:
#    List of BGP peers (a.b.c.e)
#    key:peers                                                  value:List of BGP peers (a.b.c.e)
#    key:Statistics retrieved for -mode settings:               value:
#    a.b.c.d
#    key:ip_address                                             value:a.b.c.d
#    integer
#    key:asn                                                    value:integer
#    key:Statistics retrieved for -mode labels:                 value:
#    only for MPLS VPN
#    key:<number>.distinguisher                                 value:only for MPLS VPN
#    integer
#    key:<number>.label                                         value:integer
#    ip address (v4 or v6)
#    key:<number>.neighbor                                      value:ip address (v4 or v6)
#    ip address (v4 or v6)
#    key:<number>.network                                       value:ip address (v4 or v6)
#    ip address (v4 or v6)
#    key:<number>.next_hop                                      value:ip address (v4 or v6)
#    integer
#    key:<number>.prefix_len                                    value:integer
#    mpls|mplsVpn
#    key:<number>.type                                          value:mpls|mplsVpn
#    ipV4|ipV6
#    key:<number>.version                                       value:ipV4|ipV6
#    integer
#    key:<number>.site_id                                       value:integer
#    boolean
#    key:<number>.control_word                                  value:boolean
#    integer
#    key:<number>.block_offset                                  value:integer
#    value:integer
#    key:<number>.label_                                        value:value:integer
#
# Examples:
#    See files starting with BGP4_ in the Samples subdirectory.  Also see some
#    of the L3VPN, MPLS, and MVPN sample files for further examples of BGP usage.
#    See the BGP examples in Appendix A, "Example APIs," for specific example usage.
#
# Sample Input:
#    .
#
# Sample Output:
#    .
#
# Notes:
#    Coded versus functional specification.
#
# See Also:
#

package ixiangpf;

use utils;
use ixiahlt;

sub emulation_bgp_info {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('emulation_bgp_info', $args);
	# ixiahlt::utrackerLog ('emulation_bgp_info', $args);

	return ixiangpf::runExecuteCommand('emulation_bgp_info', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
