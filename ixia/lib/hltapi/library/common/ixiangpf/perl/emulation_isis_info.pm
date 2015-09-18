##Procedure Header
# Name:
#    ixiangpf::emulation_isis_info
#
# Description:
#    Retrieves information about the IS-SI protocol.
#
# Synopsis:
#    ixiangpf::emulation_isis_info
#x       -mode         CHOICES stats
#x                     CHOICES clear_stats
#x                     CHOICES learned_info
#        [-port_handle REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
#x       [-handle      ANY]
#
# Arguments:
#x   -mode
#    -port_handle
#        The port from which to extract ISISdata.
#        One of the two parameters is required: port_handle/handle.
#x   -handle
#x       ISIS session handle where the ISIS control action is applied. The
#x       session handle is an emulated IS-IS router object reference.
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status                                                                     value:$::SUCCESS | $::FAILURE
#    If status is failure, detailed information provided.
#    key:log                                                                        value:If status is failure, detailed information provided.
#    The stats are aggregated per port no matter which optional parameter is provided: handle or port_handle. If multiple ports were provided, the stats' values are for the first port in the list. If multiple handles were provided, the stats' values are for the corresponding port of the first handles in the list. This is valid only for IxTclNetwork API (new API).
#    key:For -mode stats                                                            value:The stats are aggregated per port no matter which optional parameter is provided: handle or port_handle. If multiple ports were provided, the stats' values are for the first port in the list. If multiple handles were provided, the stats' values are for the corresponding port of the first handles in the list. This is valid only for IxTclNetwork API (new API).
#    Ixia only; represents the port name
#    key:port_name                                                                  value:Ixia only; represents the port name
#    Ixia only; represents the count of ISIS L1 Sessions Configured
#    key:l1_sessions_configured                                                     value:Ixia only; represents the count of ISIS L1 Sessions Configured
#    Ixia only; represents the count of ISIS L1 Sessions Up
#    key:l1_sessions_up                                                             value:Ixia only; represents the count of ISIS L1 Sessions Up
#    Ixia only; represents the count of ISIS Number of Full L1 Neighbors
#    key:full_l1_neighbors                                                          value:Ixia only; represents the count of ISIS Number of Full L1 Neighbors
#    Ixia only; represents the count of ISIS L2 Sessions Configured
#    key:l2_sessions_configured                                                     value:Ixia only; represents the count of ISIS L2 Sessions Configured
#    Ixia only; represents the count of ISIS L2 Sessions Up
#    key:l2_sessions_configured                                                     value:Ixia only; represents the count of ISIS L2 Sessions Up
#    Ixia only; represents the count of ISIS Number of Full L2 Neighbors
#    key:full_l2_neighbors                                                          value:Ixia only; represents the count of ISIS Number of Full L2 Neighbors
#    Ixia only; represents the count of ISIS Aggregated L1 Hellos Tx
#    key:aggregated_l1_hellos_tx                                                    value:Ixia only; represents the count of ISIS Aggregated L1 Hellos Tx
#    Ixia only; represents the count of ISIS Aggregated L1 Point-to-Point Hellos Tx
#    key:aggregated_l1_p2p_hellos_tx                                                value:Ixia only; represents the count of ISIS Aggregated L1 Point-to-Point Hellos Tx
#    Ixia only; represents the count of ISIS Aggregated L1 LSP Tx
#    key:aggregated_l1_lsp_tx                                                       value:Ixia only; represents the count of ISIS Aggregated L1 LSP Tx
#    Ixia only; represents the count of ISIS Aggregated L1 CSNP Tx
#    key:aggregated_l1_csnp_tx                                                      value:Ixia only; represents the count of ISIS Aggregated L1 CSNP Tx
#    Ixia only; represents the count of ISIS Aggregated L1 PSNP Tx
#    key:aggregated_l1_psnp_tx                                                      value:Ixia only; represents the count of ISIS Aggregated L1 PSNP Tx
#    Ixia only; represents the count of ISIS Aggregated L1 Database Size
#    key:aggregated_l1_db_size                                                      value:Ixia only; represents the count of ISIS Aggregated L1 Database Size
#    Ixia only; represents the count of ISIS Aggregated L2 Hellos Tx
#    key:aggregated_l2_hellos_tx                                                    value:Ixia only; represents the count of ISIS Aggregated L2 Hellos Tx
#    Ixia only; represents the count of ISIS Aggregated L2 Point-to-Point Hellos Tx
#    key:aggregated_l2_p2p_hellos_tx                                                value:Ixia only; represents the count of ISIS Aggregated L2 Point-to-Point Hellos Tx
#    Ixia only; represents the count of ISIS Aggregated L2 LSP Tx
#    key:aggregated_l2_lsp_tx                                                       value:Ixia only; represents the count of ISIS Aggregated L2 LSP Tx
#    Ixia only; represents the count of ISIS Aggregated L2 CSNP Tx
#    key:aggregated_l2_csnp_tx                                                      value:Ixia only; represents the count of ISIS Aggregated L2 CSNP Tx
#    Ixia only; represents the count of ISIS Aggregated L2 PSNP Tx
#    key:aggregated_l2_psnp_tx                                                      value:Ixia only; represents the count of ISIS Aggregated L2 PSNP Tx
#    Ixia only; represents the count of ISIS Aggregated L2 Database Size
#    key:aggregated_l2_db_size                                                      value:Ixia only; represents the count of ISIS Aggregated L2 Database Size
#    Ixia only; represents the count of ISIS Aggregated L1 Hellos Rx
#    key:aggregated_l1_hellos_rx                                                    value:Ixia only; represents the count of ISIS Aggregated L1 Hellos Rx
#    Ixia only; represents the count of ISIS Aggregated L1 Point-to-Point Hellos Rx
#    key:aggregated_l1_p2p_hellos_rx                                                value:Ixia only; represents the count of ISIS Aggregated L1 Point-to-Point Hellos Rx
#    Ixia only; represents the count of ISIS Aggregated L1 LSP Rx
#    key:aggregated_l1_lsp_rx                                                       value:Ixia only; represents the count of ISIS Aggregated L1 LSP Rx
#    Ixia only; represents the count of ISIS Aggregated L1 CSNP Rx
#    key:aggregated_l1_csnp_rx                                                      value:Ixia only; represents the count of ISIS Aggregated L1 CSNP Rx
#    Ixia only; represents the count of ISIS Aggregated L1 PSNP Rx
#    key:aggregated_l1_psnp_rx                                                      value:Ixia only; represents the count of ISIS Aggregated L1 PSNP Rx
#    Ixia only; represents the count of ISIS Aggregated L2 Hellos Rx
#    key:aggregated_l2_hellos_rx                                                    value:Ixia only; represents the count of ISIS Aggregated L2 Hellos Rx
#    Ixia only; represents the count of ISIS Aggregated L2 Point-to-Point Hellos Rx
#    key:aggregated_l2_p2p_hellos_rx                                                value:Ixia only; represents the count of ISIS Aggregated L2 Point-to-Point Hellos Rx
#    Ixia only; represents the count of ISIS Aggregated L2 LSP Rx
#    key:aggregated_l2_lsp_rx                                                       value:Ixia only; represents the count of ISIS Aggregated L2 LSP Rx
#    Ixia only; represents the count of ISIS Aggregated L2 CSNP Rx
#    key:aggregated_l2_csnp_rx                                                      value:Ixia only; represents the count of ISIS Aggregated L2 CSNP Rx
#    Ixia only; represents the count of ISIS Aggregated L2 PSNP Rx
#    key:aggregated_l2_psnp_rx                                                      value:Ixia only; represents the count of ISIS Aggregated L2 PSNP Rx
#    Ixia only; represents the count of ISIS Aggregated L1 Init Count
#    key:aggregated_l1_init_count                                                   value:Ixia only; represents the count of ISIS Aggregated L1 Init Count
#    Ixia only; represents the count of ISIS Aggregated L1 Full Count
#    key:aggregated_l1_full_count                                                   value:Ixia only; represents the count of ISIS Aggregated L1 Full Count
#    Ixia only; represents the count of ISIS Aggregated L2 Init Count
#    key:aggregated_l2_init_count                                                   value:Ixia only; represents the count of ISIS Aggregated L2 Init Count
#    Ixia only; represents the count of ISIS Aggregated L2 Full Count
#    key:aggregated_l2_full_count                                                   value:Ixia only; represents the count of ISIS Aggregated L2 Full Count
#    The stats are aggregated per port no matter which optional parameter is provided: handle or port_handle. This is valid only for IxTclNetwork API (new API).
#    key:For -mode stats                                                            value:The stats are aggregated per port no matter which optional parameter is provided: handle or port_handle. This is valid only for IxTclNetwork API (new API).
#    Ixia only; represents the count of ISIS L1 Sessions Configured
#    key:<port_handle>.l1_sessions_configured                                       value:Ixia only; represents the count of ISIS L1 Sessions Configured
#    Ixia only; represents the count of ISIS L1 Sessions Up
#    key:<port_handle>.l1_sessions_up                                               value:Ixia only; represents the count of ISIS L1 Sessions Up
#    Ixia only; represents the count of ISIS Number of Full L1 Neighbors
#    key:<port_handle>.full_l1_neighbors                                            value:Ixia only; represents the count of ISIS Number of Full L1 Neighbors
#    Ixia only; represents the count of ISIS L2 Sessions Configured
#    key:<port_handle>.l2_sessions_configured                                       value:Ixia only; represents the count of ISIS L2 Sessions Configured
#    Ixia only; represents the count of ISIS L2 Sessions Up
#    key:<port_handle>.l2_sessions_up                                               value:Ixia only; represents the count of ISIS L2 Sessions Up
#    Ixia only; represents the count of ISIS Number of Full L2 Neighbors
#    key:<port_handle>.full_l2_neighbors                                            value:Ixia only; represents the count of ISIS Number of Full L2 Neighbors
#    Ixia only; represents the count of ISIS Aggregated L1 Hellos Tx
#    key:<port_handle>.aggregated_l1_hellos_tx                                      value:Ixia only; represents the count of ISIS Aggregated L1 Hellos Tx
#    Ixia only; represents the count of ISIS Aggregated L1 Point-to-Point Hellos Tx
#    key:<port_handle>.aggregated_l1_p2p_hellos_tx                                  value:Ixia only; represents the count of ISIS Aggregated L1 Point-to-Point Hellos Tx
#    Ixia only; represents the count of ISIS Aggregated L1 LSP Tx
#    key:<port_handle>.aggregated_l1_lsp_tx                                         value:Ixia only; represents the count of ISIS Aggregated L1 LSP Tx
#    Ixia only; represents the count of ISIS Aggregated L1 CSNP Tx
#    key:<port_handle>.aggregated_l1_csnp_tx                                        value:Ixia only; represents the count of ISIS Aggregated L1 CSNP Tx
#    Ixia only; represents the count of ISIS Aggregated L1 PSNP Tx
#    key:<port_handle>.aggregated_l1_psnp_tx                                        value:Ixia only; represents the count of ISIS Aggregated L1 PSNP Tx
#    Ixia only; represents the count of ISIS Aggregated L1 Database Size
#    key:<port_handle>.aggregated_l1_db_size                                        value:Ixia only; represents the count of ISIS Aggregated L1 Database Size
#    Ixia only; represents the count of ISIS Aggregated L2 Hellos Tx
#    key:<port_handle>.aggregated_l2_hellos_tx                                      value:Ixia only; represents the count of ISIS Aggregated L2 Hellos Tx
#    Ixia only; represents the count of ISIS Aggregated L2 Point-to-Point Hellos Tx
#    key:<port_handle>.aggregated_l2_p2p_hellos_tx                                  value:Ixia only; represents the count of ISIS Aggregated L2 Point-to-Point Hellos Tx
#    Ixia only; represents the count of ISIS Aggregated L2 LSP Tx
#    key:<port_handle>.aggregated_l2_lsp_tx                                         value:Ixia only; represents the count of ISIS Aggregated L2 LSP Tx
#    Ixia only; represents the count of ISIS Aggregated L2 CSNP Tx
#    key:<port_handle>.aggregated_l2_csnp_tx                                        value:Ixia only; represents the count of ISIS Aggregated L2 CSNP Tx
#    Ixia only; represents the count of ISIS Aggregated L2 PSNP Tx
#    key:<port_handle>.aggregated_l2_psnp_tx                                        value:Ixia only; represents the count of ISIS Aggregated L2 PSNP Tx
#    Ixia only; represents the count of ISIS Aggregated L2 Database Size
#    key:<port_handle>.aggregated_l2_db_size                                        value:Ixia only; represents the count of ISIS Aggregated L2 Database Size
#    Ixia only; represents the count of ISIS Aggregated L1 Hellos Rx
#    key:<port_handle>.aggregated_l1_hellos_rx                                      value:Ixia only; represents the count of ISIS Aggregated L1 Hellos Rx
#    Ixia only; represents the count of ISIS Aggregated L1 Point-to-Point Hellos Rx
#    key:<port_handle>.aggregated_l1_p2p_hellos_rx                                  value:Ixia only; represents the count of ISIS Aggregated L1 Point-to-Point Hellos Rx
#    Ixia only; represents the count of ISIS Aggregated L1 LSP Rx
#    key:<port_handle>.aggregated_l1_lsp_rx                                         value:Ixia only; represents the count of ISIS Aggregated L1 LSP Rx
#    Ixia only; represents the count of ISIS Aggregated L1 CSNP Rx
#    key:<port_handle>.aggregated_l1_csnp_rx                                        value:Ixia only; represents the count of ISIS Aggregated L1 CSNP Rx
#    Ixia only; represents the count of ISIS Aggregated L1 PSNP Rx
#    key:<port_handle>.aggregated_l1_psnp_rx                                        value:Ixia only; represents the count of ISIS Aggregated L1 PSNP Rx
#    Ixia only; represents the count of ISIS Aggregated L2 Hellos Rx
#    key:<port_handle>.aggregated_l2_hellos_rx                                      value:Ixia only; represents the count of ISIS Aggregated L2 Hellos Rx
#    Ixia only; represents the count of ISIS Aggregated L2 Point-to-Point Hellos Rx
#    key:<port_handle>.aggregated_l2_p2p_hellos_rx                                  value:Ixia only; represents the count of ISIS Aggregated L2 Point-to-Point Hellos Rx
#    Ixia only; represents the count of ISIS Aggregated L2 LSP Rx
#    key:<port_handle>.aggregated_l2_lsp_rx                                         value:Ixia only; represents the count of ISIS Aggregated L2 LSP Rx
#    Ixia only; represents the count of ISIS Aggregated L2 CSNP Rx
#    key:<port_handle>.aggregated_l2_csnp_rx                                        value:Ixia only; represents the count of ISIS Aggregated L2 CSNP Rx
#    Ixia only; represents the count of ISIS Aggregated L2 PSNP Rx
#    key:<port_handle>.aggregated_l2_psnp_rx                                        value:Ixia only; represents the count of ISIS Aggregated L2 PSNP Rx
#    Ixia only; represents the count of ISIS Aggregated L1 Init Count
#    key:<port_handle>.aggregated_l1_init_count                                     value:Ixia only; represents the count of ISIS Aggregated L1 Init Count
#    Ixia only; represents the count of ISIS Aggregated L1 Full Count
#    key:<port_handle>.aggregated_l1_full_count                                     value:Ixia only; represents the count of ISIS Aggregated L1 Full Count
#    Ixia only; represents the count of ISIS Aggregated L2 Init Count
#    key:<port_handle>.aggregated_l2_init_count                                     value:Ixia only; represents the count of ISIS Aggregated L2 Init Count
#    Ixia only; represents the count of ISIS Aggregated L2 Full Count
#    key:<port_handle>.aggregated_l2_full_count                                     value:Ixia only; represents the count of ISIS Aggregated L2 Full Count
#    The stats are aggregated per port no matter which optional parameter is provided: handle or port_handle. This is valid only for IxTclProtocol API (old API).
#    key:For -mode stats                                                            value:The stats are aggregated per port no matter which optional parameter is provided: handle or port_handle. This is valid only for IxTclProtocol API (old API).
#    Ixia only; represents the count of ISIS L1 Sessions Configured
#    key:<port_handle>.l1_sessions_configured                                       value:Ixia only; represents the count of ISIS L1 Sessions Configured
#    Ixia only; represents the count of ISIS L1 Sessions Up
#    key:<port_handle>.l1_sessions_up                                               value:Ixia only; represents the count of ISIS L1 Sessions Up
#    Ixia only; represents the count of ISIS Number of Full L1 Neighbors
#    key:<port_handle>.full_l1_neighbors                                            value:Ixia only; represents the count of ISIS Number of Full L1 Neighbors
#    Ixia only; represents the count of ISIS L2 Sessions Configured
#    key:<port_handle>.l2_sessions_configured                                       value:Ixia only; represents the count of ISIS L2 Sessions Configured
#    Ixia only; represents the count of ISIS L2 Sessions Up
#    key:<port_handle>.l2_sessions_up                                               value:Ixia only; represents the count of ISIS L2 Sessions Up
#    Ixia only; represents the count of ISIS Number of Full L2 Neighbors
#    key:<port_handle>.full_l2_neighbors                                            value:Ixia only; represents the count of ISIS Number of Full L2 Neighbors
#    Ixia only; valid only with IxOS 5.30 an greater.
#    key:<port_handle>.rbridges_learned                                             value:Ixia only; valid only with IxOS 5.30 an greater.
#    Ixia only; valid only with IxOS 5.30 an greater.
#    key:<port_handle>.mac_group_recors_learned                                     value:Ixia only; valid only with IxOS 5.30 an greater.
#    Ixia only; valid only with IxOS 5.30 an greater.
#    key:<port_handle>.ipv4_group_records_learned                                   value:Ixia only; valid only with IxOS 5.30 an greater.
#    Ixia only; valid only with IxOS 5.30 an greater.
#    key:<port_handle>.ipv6_group_records_learned                                   value:Ixia only; valid only with IxOS 5.30 an greater.
#    Ixia only; valid only with IxOS 5.30 an greater.
#    key:<port_handle>.l1_db_size                                                   value:Ixia only; valid only with IxOS 5.30 an greater.
#    Ixia only; valid only with IxOS 5.30 an greater.
#    key:<port_handle>.l2_db_size                                                   value:Ixia only; valid only with IxOS 5.30 an greater.
#    The stats are retrieved per ISIS session handle no matter which optional parameter is provided: handle or port_handle. Valid only for IxTclProtocol (old API).
#    key:For -mode learned_info                                                     value:The stats are retrieved per ISIS session handle no matter which optional parameter is provided: handle or port_handle. Valid only for IxTclProtocol (old API).
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.rbridges.<index>.this              value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.rbridges.<index>.system_id         value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.rbridges.<index>.ftag              value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.rbridges.<index>.role              value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.rbridges.<index>.priority          value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.rbridges.<index>.age               value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.rbridges.<index>.seq_number        value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.rbridges.<index>.device_id         value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.rbridges.<index>.graph_id          value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.rbridges.<index>.secondary_ftag    value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.ipv4.<index>.lsp_id                value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.ipv4.<index>.sequence_number       value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.ipv4.<index>.group_address         value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.ipv4.<index>.source_address        value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.ipv4.<index>.age                   value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.ipv6.<index>.lsp_id                value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.ipv6.<index>.sequence_number       value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.ipv6.<index>.mcast_group_address   value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.ipv6.<index>.ucast_source_address  value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.ipv6.<index>.age                   value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.mac.<index>.lsp_id                 value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.mac.<index>.sequence_number        value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.mac.<index>.mcast_group_address    value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.mac.<index>.ucast_source_address   value:Ixia only;
#    Ixia only;
#    key:<handle>.dce_isis_draft_ward_l2_isis_04.mac.<index>.age                    value:Ixia only;
#    The stats are retrieved per ISIS session handle no matter which optional parameter is provided: handle or port_handle. Valid for both IxTclProtocol (old API) and IxTclNetwork (new API).
#    key:For -mode learned_info                                                     value:The stats are retrieved per ISIS session handle no matter which optional parameter is provided: handle or port_handle. Valid for both IxTclProtocol (old API) and IxTclNetwork (new API).
#    Ixia only;
#    key:<handle>.isis_l3_routing.ipv4.<index>.lsp_id                               value:Ixia only;
#    Ixia only;
#    key:<handle>.isis_l3_routing.ipv4.<index>.sequence_number                      value:Ixia only;
#    Ixia only;
#    key:<handle>.isis_l3_routing.ipv4.<index>.prefix                               value:Ixia only;
#    Ixia only;
#    key:<handle>.isis_l3_routing.ipv4.<index>.metric                               value:Ixia only;
#    Ixia only;
#    key:<handle>.isis_l3_routing.ipv4.<index>.age                                  value:Ixia only;
#    Ixia only;
#    key:<handle>.isis_l3_routing.ipv6.<index>.lsp_id                               value:Ixia only;
#    Ixia only;
#    key:<handle>.isis_l3_routing.ipv6.<index>.sequence_number                      value:Ixia only;
#    Ixia only;
#    key:<handle>.isis_l3_routing.ipv6.<index>.prefix                               value:Ixia only;
#    Ixia only;
#    key:<handle>.isis_l3_routing.ipv6.<index>.metric                               value:Ixia only;
#    Ixia only;
#    key:<handle>.isis_l3_routing.ipv6.<index>.age                                  value:Ixia only;
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#

package ixiangpf;

use utils;
use ixiahlt;

sub emulation_isis_info {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('emulation_isis_info', $args);
	# ixiahlt::utrackerLog ('emulation_isis_info', $args);

	return ixiangpf::runExecuteCommand('emulation_isis_info', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
