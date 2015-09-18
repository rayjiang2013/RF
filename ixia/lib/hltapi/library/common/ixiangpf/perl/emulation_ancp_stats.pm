##Procedure Header
# Name:
#    ixiangpf::emulation_ancp_stats
#
# Description:
#    This procedure retrieves ANCP stats.
#
# Synopsis:
#    ixiangpf::emulation_ancp_stats
#        [-mode        CHOICES instance
#                      CHOICES device
#                      CHOICES per_dg
#                      CHOICES per_port
#                      DEFAULT per_port]
#        [-handle      ANY]
#x       [-port_handle ANY]
#        [-reset       FLAG]
#
# Arguments:
#    -mode
#    -handle
#        ANCP range for which to retrieve stats. The stats are retrived for the
#        port on which this ANCP handle belongs. This parameter is supported
#        using the following APIs: IxTclNetwork.
#x   -port_handle
#x       Parameter -port_handle specifies the port on which the ANCP stats are
#x       retrieved. This parameter is supported using the following APIs:
#x       IxTclNetwork.
#    -reset
#        Used to reset ANCP client device statistics. This parameter is
#        supported using the following APIs: IxTclNetwork.
#
# Return Values:
#    $::SUCCESS | $::FAILURE Status of procedure call.
#    key:status                                      value:$::SUCCESS | $::FAILURE Status of procedure call.
#    When status is failure, contains more information.
#    key:log                                         value:When status is failure, contains more information.
#    key:rx_total_pkts                               value:
#    key:rx_adj_syn_pkts                             value:
#    key:rx_adj_syn_ack_pkts                         value:
#    key:rx_adj_ack_pkts                             value:
#    key:rx_adj_rst_ack_pkts                         value:
#n   key:rx_top_disc_receipt_pkts                    value:
#n   key:rx_line_config_req                          value:
#n   key:rx_dropped_sub_not_found                    value:
#n   key:rx_dropped_no_cap                           value:
#n   key:rx_dropped_adj_not_stsab                    value:
#n   key:rx_dropped_malformed                        value:
#    key:tx_total_pkts                               value:
#    key:tx_adj_syn_pkts                             value:
#    key:tx_adj_syn_ack_pkts                         value:
#    key:tx_adj_ack_pkts                             value:
#    key:tx_adj_rst_ack_pkts                         value:
#n   key:tx_top_disc_port_up_events                  value:
#n   key:tx_top_disc_port_down_events                value:
#n   key:tx_line_config_receipts                     value:
#n   key:adj_estab_time_min                          value:
#n   key:adj_estab_time_avg                          value:
#n   key:adj_estab_time_max                          value:
#    key:adj_estab_count                             value:
#n   key:adj_estab_percent                           value:
#n   key:adj_estab_rate                              value:
#n   key:agg_sub_line_down_bw                        value:
#n   key:agg_sub_line_up_bw                          value:
#    key:port_handle.ancp_adjacency.ans_established  value:
#    key:port_handle.ancp_adjacency.tx.pkts          value:
#    key:port_handle.ancp_adjacency.rx.pkts          value:
#    key:port_handle.ancp_adjacency.tx.bytes         value:
#    key:port_handle.ancp_adjacency.rx.bytes         value:
#    key:port_handle.ancp_adjacency.tx.syn           value:
#    key:port_handle.ancp_adjacency.rx.syn           value:
#    key:port_handle.ancp_adjacency.tx.ack           value:
#    key:port_handle.ancp_adjacency.rx.ack           value:
#    key:port_handle.ancp_adjacency.tx.synack        value:
#    key:port_handle.ancp_adjacency.rx.synack        value:
#    key:port_handle.ancp_adjacency.tx.rstack        value:
#    key:port_handle.ancp_adjacency.rx.rstack        value:
#    key:port_handle.ancp_general.ans_established    value:
#    key:port_handle.ancp_general.port_name          value:
#    key:port_handle.ancp_general.dsl_lines_up       value:
#    key:port_handle.ancp_general.tx.pkts            value:
#    key:port_handle.ancp_general.rx.pkts            value:
#    key:port_handle.ancp_general.tx.bytes           value:
#    key:port_handle.ancp_general.rx.bytes           value:
#    key:port_handle.ancp_port_event.dsl_lines_up    value:
#    key:port_handle.ancp_port_event.tx.port_up      value:
#    key:port_handle.ancp_port_event.tx.port_down    value:
#    key:port_handle.ancp_port_event.tx.event_pkts   value:
#    key:port_handle.ancp_port_event.tx.event_bytes  value:
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    1) Unsupported parameters or unsupported parameter options will be
#    silently ignored.
#
# See Also:
#

package ixiangpf;

use utils;
use ixiahlt;

sub emulation_ancp_stats {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('emulation_ancp_stats', $args);
	# ixiahlt::utrackerLog ('emulation_ancp_stats', $args);

	return ixiangpf::runExecuteCommand('emulation_ancp_stats', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
