##Procedure Header
# Name:
#    ixiangpf::emulation_pim_info
#
# Description:
#    This command is used to retrieve aggregate statistics about PIM from a port, and
#    learned CRP_BSR info.
#
# Synopsis:
#    ixiangpf::emulation_pim_info
#        -handle  ANY
#        [-mode   CHOICES aggregate
#                 CHOICES stats_per_device_group
#                 CHOICES stats_per_session
#                 CHOICES learned_crp
#                 CHOICES clear_stats
#                 DEFAULT aggregate]
#
# Arguments:
#    -handle
#        For -mode aggregate, this parameter should be provided with an emulated
#        router or join/prune or source handle, but the command will return per port
#        aggregated stats. For -mode learned_crp, this parameters should be provided
#        with an emulated router or interface (for the emulated router) and the
#        command will return per interface learned CRP and BSR info.
#    -mode
#        Using this argument, you can return aggregate statistics or learned crp-bsr info
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status                                                value:$::SUCCESS | $::FAILURE
#    On status of failure, gives detailed information.
#    key:log                                                   value:On status of failure, gives detailed information.
#    PIMSM Aggregated Hellos Tx; valid only with -mode aggregate
#    key:port_name                                             value:PIMSM Aggregated Hellos Tx; valid only with -mode aggregate
#    PIMSM Aggregated Hellos Tx; valid only with -mode aggregate
#    key:hello_tx                                              value:PIMSM Aggregated Hellos Tx; valid only with -mode aggregate
#    PIMSM Aggregated Hellos Rx; valid only with -mode aggregate
#    key:hello_rx                                              value:PIMSM Aggregated Hellos Rx; valid only with -mode aggregate
#    PIMSM Aggregated Join (*,G) Tx; valid only with -mode aggregate
#    key:group_join_tx                                         value:PIMSM Aggregated Join (*,G) Tx; valid only with -mode aggregate
#    PIMSM Aggregated Join (*,G) Rx; valid only with -mode aggregate
#    key:group_join_rx                                         value:PIMSM Aggregated Join (*,G) Rx; valid only with -mode aggregate
#    PIMSM Aggregated Prune (*,G) Tx; valid only with -mode aggregate
#    key:group_prune_tx                                        value:PIMSM Aggregated Prune (*,G) Tx; valid only with -mode aggregate
#    PIMSM Aggregated Prune (*,G) Rx; valid only with -mode aggregate
#    key:group_prune_rx                                        value:PIMSM Aggregated Prune (*,G) Rx; valid only with -mode aggregate
#    PIMSM Aggregated Join (S,G) Tx; valid only with -mode aggregate
#    key:s_g_join_tx                                           value:PIMSM Aggregated Join (S,G) Tx; valid only with -mode aggregate
#    PIMSM Aggregated Join(S,G) Rx; valid only with -mode aggregate
#    key:s_g_join_rx                                           value:PIMSM Aggregated Join(S,G) Rx; valid only with -mode aggregate
#    PIMSM Aggregated Prune(S,G) Tx; valid only with -mode aggregate
#    key:s_g_prune_tx                                          value:PIMSM Aggregated Prune(S,G) Tx; valid only with -mode aggregate
#    PIMSM Aggregated Prune(S,G) Rx; valid only with -mode aggregate
#    key:s_g_prune_rx                                          value:PIMSM Aggregated Prune(S,G) Rx; valid only with -mode aggregate
#    PIMSM Aggregated Register Tx; valid only with -mode aggregate
#    key:reg_tx                                                value:PIMSM Aggregated Register Tx; valid only with -mode aggregate
#    PIMSM Aggregated Register Rx; valid only with -mode aggregate
#    key:reg_rx                                                value:PIMSM Aggregated Register Rx; valid only with -mode aggregate
#    PIMSM Aggregated RegisterStop Tx; valid only with -mode aggregate
#    key:reg_stop_tx                                           value:PIMSM Aggregated RegisterStop Tx; valid only with -mode aggregate
#    PIMSM Aggregated RegisterStop Rx; valid only with -mode aggregate
#    key:reg_stop_rx                                           value:PIMSM Aggregated RegisterStop Rx; valid only with -mode aggregate
#    PIMSM Aggregated RegisterNull Tx; valid only with -mode aggregate
#    key:null_reg_tx                                           value:PIMSM Aggregated RegisterNull Tx; valid only with -mode aggregate
#    PIMSM Aggregated RegisterNull Rx; valid only with -mode aggregate
#    key:null_reg_rx                                           value:PIMSM Aggregated RegisterNull Rx; valid only with -mode aggregate
#    PIMSM Aggregated Hellos Tx
#    key:<port handle>.aggregate.port_name                     value:PIMSM Aggregated Hellos Tx
#    PIMSM Aggregated Hellos Tx
#    key:<port handle>.aggregate.hello_tx                      value:PIMSM Aggregated Hellos Tx
#    PIMSM Aggregated Hellos Rx
#    key:<port handle>.aggregate.hello_rx                      value:PIMSM Aggregated Hellos Rx
#    PIMSM Aggregated Join (*,G) Tx
#    key:<port handle>.aggregate.group_join_tx                 value:PIMSM Aggregated Join (*,G) Tx
#    PIMSM Aggregated Join (*,G) Rx
#    key:<port handle>.aggregate.group_join_rx                 value:PIMSM Aggregated Join (*,G) Rx
#    PIMSM Aggregated Prune (*,G) Tx
#    key:<port handle>.aggregate.group_prune_tx                value:PIMSM Aggregated Prune (*,G) Tx
#    PIMSM Aggregated Prune (*,G) Rx
#    key:<port handle>.aggregate.group_prune_rx                value:PIMSM Aggregated Prune (*,G) Rx
#    PIMSM Aggregated Join (S,G) Tx
#    key:<port handle>.aggregate.s_g_join_tx                   value:PIMSM Aggregated Join (S,G) Tx
#    PIMSM Aggregated Join(S,G) Rx
#    key:<port handle>.aggregate.s_g_join_rx                   value:PIMSM Aggregated Join(S,G) Rx
#    PIMSM Aggregated Prune(S,G) Tx
#    key:<port handle>.aggregate.s_g_prune_tx                  value:PIMSM Aggregated Prune(S,G) Tx
#    PIMSM Aggregated Prune(S,G) Rx
#    key:<port handle>.aggregate.s_g_prune_rx                  value:PIMSM Aggregated Prune(S,G) Rx
#    PIMSM Aggregated Register Tx
#    key:<port handle>.aggregate.reg_tx                        value:PIMSM Aggregated Register Tx
#    PIMSM Aggregated Register Rx
#    key:<port handle>.aggregate.reg_rx                        value:PIMSM Aggregated Register Rx
#    PIMSM Aggregated RegisterStop Tx
#    key:<port handle>.aggregate.reg_stop_tx                   value:PIMSM Aggregated RegisterStop Tx
#    PIMSM Aggregated RegisterStop Rx
#    key:<port handle>.aggregate.reg_stop_rx                   value:PIMSM Aggregated RegisterStop Rx
#    PIMSM Aggregated RegisterNull Tx
#    key:<port handle>.aggregate.null_reg_tx                   value:PIMSM Aggregated RegisterNull Tx
#    PIMSM Aggregated RegisterNull Rx
#    key:<port handle>.aggregate.null_reg_rx                   value:PIMSM Aggregated RegisterNull Rx
#    PIMSM Number of Routers Configured; valid only with -mode aggregate
#x   key:num_routers_configured                                value:PIMSM Number of Routers Configured; valid only with -mode aggregate
#    PIMSM Number of Routers Running; valid only with -mode aggregate
#x   key:num_routers_running                                   value:PIMSM Number of Routers Running; valid only with -mode aggregate
#    PIMSM Number of Neighbors Learnt; valid only with -mode aggregate
#x   key:num_neighbors_learnt                                  value:PIMSM Number of Neighbors Learnt; valid only with -mode aggregate
#    PIMSM Aggregated Join (*,*,RP) Tx; valid only with -mode aggregate
#x   key:rp_join_tx                                            value:PIMSM Aggregated Join (*,*,RP) Tx; valid only with -mode aggregate
#    PIMSM Aggregated Join (*,*,RP) Rx; valid only with -mode aggregate
#x   key:rp_join_rx                                            value:PIMSM Aggregated Join (*,*,RP) Rx; valid only with -mode aggregate
#    PIMSM Aggregated Prune (*,*,RP) Tx; valid only with -mode aggregate
#x   key:rp_prune_tx                                           value:PIMSM Aggregated Prune (*,*,RP) Tx; valid only with -mode aggregate
#    PIMSM Aggregated Prune (*,*,RP) Rx; valid only with -mode aggregate
#x   key:rp_prune_rx                                           value:PIMSM Aggregated Prune (*,*,RP) Rx; valid only with -mode aggregate
#    PIMSM Aggregated Join (S,G,RPT) Tx; valid only with -mode aggregate
#x   key:s_g_rpt_join_tx                                       value:PIMSM Aggregated Join (S,G,RPT) Tx; valid only with -mode aggregate
#    PIMSM Aggregated Join (S,G,RPT) Rx; valid only with -mode aggregate
#x   key:s_g_rpt_join_rx                                       value:PIMSM Aggregated Join (S,G,RPT) Rx; valid only with -mode aggregate
#    PIMSM Aggregated Prune (S,G,RPT) Tx; valid only with -mode aggregate
#x   key:s_g_rpt_prune_tx                                      value:PIMSM Aggregated Prune (S,G,RPT) Tx; valid only with -mode aggregate
#    PIMSM Aggregated Prune (S,G,RPT) Rx; valid only with -mode aggregate
#x   key:s_g_rpt_prune_rx                                      value:PIMSM Aggregated Prune (S,G,RPT) Rx; valid only with -mode aggregate
#    PIMSM Aggregated DataMDT TLV Tx; valid only with -mode aggregate
#x   key:data_mdt_tlv_tx                                       value:PIMSM Aggregated DataMDT TLV Tx; valid only with -mode aggregate
#    PIMSM Aggregated DataMDT TLV Rx; valid only with -mode aggregate
#x   key:data_mdt_tlv_rx                                       value:PIMSM Aggregated DataMDT TLV Rx; valid only with -mode aggregate
#    PIMSM Number of Routers Configured
#x   key:<port handle>.aggregate.num_routers_configured        value:PIMSM Number of Routers Configured
#    PIMSM Number of Routers Running
#x   key:<port handle>.aggregate.num_routers_running           value:PIMSM Number of Routers Running
#    PIMSM Number of Neighbors Learnt
#x   key:<port handle>.aggregate.num_neighbors_learnt          value:PIMSM Number of Neighbors Learnt
#    PIMSM Aggregated Join (*,*,RP) Tx
#x   key:<port handle>.aggregate.rp_join_tx                    value:PIMSM Aggregated Join (*,*,RP) Tx
#    PIMSM Aggregated Join (*,*,RP) Rx
#x   key:<port handle>.aggregate.rp_join_rx                    value:PIMSM Aggregated Join (*,*,RP) Rx
#    PIMSM Aggregated Prune (*,*,RP) Tx
#x   key:<port handle>.aggregate.rp_prune_tx                   value:PIMSM Aggregated Prune (*,*,RP) Tx
#    PIMSM Aggregated Prune (*,*,RP) Rx
#x   key:<port handle>.aggregate.rp_prune_rx                   value:PIMSM Aggregated Prune (*,*,RP) Rx
#    PIMSM Aggregated Join (S,G,RPT) Tx
#x   key:<port handle>.aggregate.s_g_rpt_join_tx               value:PIMSM Aggregated Join (S,G,RPT) Tx
#    PIMSM Aggregated Join (S,G,RPT) Rx
#x   key:<port handle>.aggregate.s_g_rpt_join_rx               value:PIMSM Aggregated Join (S,G,RPT) Rx
#    PIMSM Aggregated Prune (S,G,RPT) Tx
#x   key:<port handle>.aggregate.s_g_rpt_prune_tx              value:PIMSM Aggregated Prune (S,G,RPT) Tx
#    PIMSM Aggregated Prune (S,G,RPT) Rx
#x   key:<port handle>.aggregate.s_g_rpt_prune_rx              value:PIMSM Aggregated Prune (S,G,RPT) Rx
#    PIMSM Aggregated DataMDT TLV Tx
#x   key:<port handle>.aggregate.data_mdt_tlv_tx               value:PIMSM Aggregated DataMDT TLV Tx
#    PIMSM Aggregated DataMDT TLV Rx
#x   key:<port handle>.aggregate.data_mdt_tlv_rx               value:PIMSM Aggregated DataMDT TLV Rx
#    the RP address expresing candidacy for the specific group of RPs; valid only with -mode learned_crp
#x   key:learned_crp.<interface_handle>.<id>.crp_addr          value:the RP address expresing candidacy for the specific group of RPs; valid only with -mode learned_crp
#    the expiry timer for the specific record as received in CRP Adv Message; valid only with -mode learned_crp
#x   key:learned_crp.<interface_handle>.<id>.expiry_timer      value:the expiry timer for the specific record as received in CRP Adv Message; valid only with -mode learned_crp
#    the Group Address learnt through Candidate RP advertisments; valid only with -mode learned_crp
#x   key:learned_crp.<interface_handle>.<id>.group_addr        value:the Group Address learnt through Candidate RP advertisments; valid only with -mode learned_crp
#    shows the prefix lenght of the group address learnt; valid only with -mode learned_crp
#x   key:learned_crp.<interface_handle>.<id>.group_mask_width  value:shows the prefix lenght of the group address learnt; valid only with -mode learned_crp
#    priority of the selected Candidate RP; valid only with -mode learned_crp
#x   key:learned_crp.<interface_handle>.<id>.priority          value:priority of the selected Candidate RP; valid only with -mode learned_crp
#    the address of the elected bootstrap router that is sending periodic bootstrap messages; valid only with -mode learned_crp
#x   key:learned_bsr.<interface_handle>.bsr_addr               value:the address of the elected bootstrap router that is sending periodic bootstrap messages; valid only with -mode learned_crp
#    indicates the elapsed time (in seconds) since the last bootstrap message was received or sent; valid only with -mode learned_crp
#x   key:learned_bsr.<interface_handle>.last_bsm_send_recv     value:indicates the elapsed time (in seconds) since the last bootstrap message was received or sent; valid only with -mode learned_crp
#    indicates the state of the configured bootstrap router; valid only with -mode learned_crp
#x   key:learned_bsr.<interface_handle>.our_bsr_state          value:indicates the state of the configured bootstrap router; valid only with -mode learned_crp
#    priority of the elected bootstrap router as received in Bootstrap messages or configured priority; valid only with -mode learned_crp
#x   key:learned_bsr.<interface_handle>.priority               value:priority of the elected bootstrap router as received in Bootstrap messages or configured priority; valid only with -mode learned_crp
#
# Examples:
#    ixia::emulation_pim_info -handle <router_handle> -mode aggregate
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    1) For many handles specified as parameters this procedure will return a keyed
#    list formatted as follows: <port_handle>.aggregate.<key_name> when mode is aggregate,
#    or learned_crp.<interface_handle>.<key_name>, learned_bsr.<interface_handle>.<key_name>
#    when mode is learned_crp.
#    2) MVPN parameters are not supported with IxTclNetwork API (new API).
#
# See Also:
#

package ixiangpf;

use utils;
use ixiahlt;

sub emulation_pim_info {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('emulation_pim_info', $args);
	# ixiahlt::utrackerLog ('emulation_pim_info', $args);

	return ixiangpf::runExecuteCommand('emulation_pim_info', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
