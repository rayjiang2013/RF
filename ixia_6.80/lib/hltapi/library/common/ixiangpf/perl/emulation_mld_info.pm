##Procedure Header
# Name:
#    ixiangpf::emulation_mld_info
#
# Description:
#    This procedure gathers MLD statistics.
#    This procedure is only supported for IxTclNetwork.
#    It is not supported by IxNetwork-FT.
#
# Synopsis:
#    ixiangpf::emulation_mld_info
#x       -mode         CHOICES stats
#x                     CHOICES aggregate
#x                     CHOICES stats_per_device_group
#x                     CHOICES stats_per_session
#x                     CHOICES clear_stats
#x                     CHOICES learned_info
#        [-port_handle REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
#n       [-timeout     ANY]
#x       [-handle      ANY]
#x       [-type        CHOICES host querier both
#x                     DEFAULT host]
#
# Arguments:
#x   -mode
#x       The statistics that should be retrieved for MLD host and querier.
#    -port_handle
#        This option is required to specify the port where to take the action.
#n   -timeout
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -handle
#x       <p> MLD session handle for which statistics are gathered. The
#x       handle is an emulated MLD router object reference.
#x       Example :
#x       </p>
#x       <p>
#x       <ul>
#x       <li>::ixiangpf::emulation_mld_info -mode stats -handle $devicehandle -type [both or host or querier]</li>
#x       <li>::ixiangpf::emulation_mld_info -mode learned_info -handle $mldQuerierHandle</li>
#x       </ul>
#x       </p>
#x   -type
#x       The type of aggregated statistics to be gathered.
#x       This option is available only when using the IxNetwork
#x       (IxTclNetwork package) 6.30 or later. The option is NOT
#x       supported by IxNetwork-FT (IxTclProtocol package).
#x       Valid only for -mode stats.
#
# Return Values:
#    Sessions Total
#x   key:sessions_total                           value:Sessions Total
#    Sessions Up
#x   key:sessions_up                              value:Sessions Up
#    Sessions Down
#x   key:sessions_down                            value:Sessions Down
#    Sessions Not Started
#x   key:sessions_not_started                     value:Sessions Not Started
#    MLD Querier Total Frames Tx
#x   key:total_frames_tx                          value:MLD Querier Total Frames Tx
#    MLD Querier Total Frames Rx
#x   key:total_frames_rx                          value:MLD Querier Total Frames Rx
#    MLD Querier Invalid Packets Rx
#x   key:invalid_packets_rx                       value:MLD Querier Invalid Packets Rx
#    MLDv1 General Query Tx
#x   key:v1_general_query_tx                      value:MLDv1 General Query Tx
#    MLDv1 Group specific Query Tx
#x   key:v1_group_specific_query_tx               value:MLDv1 Group specific Query Tx
#    MLDv1 Querier Membership Reports Rx
#x   key:v1_querier_membership_reports_rx         value:MLDv1 Querier Membership Reports Rx
#    MLDv1 Done Rx
#x   key:v1_done_rx                               value:MLDv1 Done Rx
#    MLDv2 General Query Tx
#x   key:v2_general_query_tx                      value:MLDv2 General Query Tx
#    MLDv2 Group specific Query Tx
#x   key:v2_group_specific_query_tx               value:MLDv2 Group specific Query Tx
#    MLDv2 Group and Source Specific Query Tx
#x   key:v2_group_and_source_specific_query_tx    value:MLDv2 Group and Source Specific Query Tx
#    MLDv2 Querier Membership Reports Rx
#x   key:v2_querier_membership_reports_rx         value:MLDv2 Querier Membership Reports Rx
#    MLDv1 General Query Count Rx
#x   key:v1_general_query_count_rx                value:MLDv1 General Query Count Rx
#    MLDv2 General Query Count Rx
#x   key:v2_general_query_count_rx                value:MLDv2 General Query Count Rx
#    MLDv1 Group Specific Query Count Rx
#x   key:v1_group_specific_query_count_rx         value:MLDv1 Group Specific Query Count Rx
#    MLDv2 Group Specific Query Count Rx
#x   key:v2_group_specific_query_count_rx         value:MLDv2 Group Specific Query Count Rx
#    Sessions Total
#x   key:sessions_total                           value:Sessions Total
#    Sessions Up
#x   key:sessions_up                              value:Sessions Up
#    Sessions Down
#x   key:sessions_down                            value:Sessions Down
#    Sessions Not Started
#x   key:sessions_not_started                     value:Sessions Not Started
#    Total Frames Tx
#x   key:total_frames_tx                          value:Total Frames Tx
#    Total Frames Rx
#x   key:total_frames_rx                          value:Total Frames Rx
#    Invalid Packets Rx
#x   key:invalid_packets_rx                       value:Invalid Packets Rx
#    (S,G) Pairs Joined
#x   key:joined_groups                            value:(S,G) Pairs Joined
#    v1 Membership Reports Tx
#x   key:v1_membership_reports_tx                 value:v1 Membership Reports Tx
#    v1 Membership Reports Rx
#x   key:v1_membership_reports_rx                 value:v1 Membership Reports Rx
#    v2 Membership Reports Tx
#x   key:v2_membership_reports_tx                 value:v2 Membership Reports Tx
#    v2 Membership Reports Rx
#x   key:v2_membership_reports_rx                 value:v2 Membership Reports Rx
#    v1 General Queries Tx
#x   key:v1_general_queries_tx                    value:v1 General Queries Tx
#    v1 General Queries Rx
#x   key:v1_general_queries_rx                    value:v1 General Queries Rx
#    v2 General Queries Tx
#x   key:v2_general_queries_tx                    value:v2 General Queries Tx
#    v2 General Queries Rx
#x   key:v2_general_queries_rx                    value:v2 General Queries Rx
#    v1 Group Specific Queries Tx
#x   key:v1_group_specific_queries_tx             value:v1 Group Specific Queries Tx
#    v1 Group Specific Queries Rx
#x   key:v1_group_specific_queries_rx             value:v1 Group Specific Queries Rx
#    v2 Group Specific Queries Tx
#x   key:v2_group_specific_queries_tx             value:v2 Group Specific Queries Tx
#    v2 Group Specific Queries Rx
#x   key:v2_group_specific_queries_rx             value:v2 Group Specific Queries Rx
#    v2 Group&Source Specific Queries Tx
#x   key:v2_group_and_source_specific_queries_tx  value:v2 Group&Source Specific Queries Tx
#    v2 Group&Source Specific Queries Rx
#x   key:v2_group_and_source_specific_queries_rx  value:v2 Group&Source Specific Queries Rx
#    v1 Done Tx
#x   key:v1_done_tx                               value:v1 Done Tx
#    v1 Done Rx
#x   key:v1_done_rx                               value:v1 Done Rx
#    v2 MODE_IS_INCLUDE Tx
#x   key:v2_mode_is_include_tx                    value:v2 MODE_IS_INCLUDE Tx
#    v2 MODE_IS_INCLUDE Rx
#x   key:v2_mode_is_include_rx                    value:v2 MODE_IS_INCLUDE Rx
#    v2 MODE_IS_EXCLUDE Tx
#x   key:v2_mode_is_exclude_tx                    value:v2 MODE_IS_EXCLUDE Tx
#    v2 MODE_IS_EXCLUDE Rx
#x   key:v2_mode_is_exclude_rx                    value:v2 MODE_IS_EXCLUDE Rx
#    v2 CHANGE_TO_INCLUDE_MODE Tx
#x   key:v2_change_to_include_tx                  value:v2 CHANGE_TO_INCLUDE_MODE Tx
#    v2 CHANGE_TO_INCLUDE_MODE Rx
#x   key:v2_change_to_include_rx                  value:v2 CHANGE_TO_INCLUDE_MODE Rx
#    v2 CHANGE_TO_EXCLUDE_MODE Tx
#x   key:v2_change_to_exclude_tx                  value:v2 CHANGE_TO_EXCLUDE_MODE Tx
#    v2 CHANGE_TO_EXCLUDE_MODE Rx
#x   key:v2_change_to_exclude_rx                  value:v2 CHANGE_TO_EXCLUDE_MODE Rx
#    v2 ALLOW_NEW_SOURCES Tx
#x   key:v2_allow_new_sources_tx                  value:v2 ALLOW_NEW_SOURCES Tx
#    v2 ALLOW_NEW_SOURCES Rx
#x   key:v2_allow_new_sources_rx                  value:v2 ALLOW_NEW_SOURCES Rx
#    v2 BLOCK_OLD_SOURCES Tx
#x   key:v2_block_old_sources_tx                  value:v2 BLOCK_OLD_SOURCES Tx
#    v2 BLOCK_OLD_SOURCES Rx
#x   key:v2_block_old_sources_rx                  value:v2 BLOCK_OLD_SOURCES Rx
#
# Examples:
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

sub emulation_mld_info {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('emulation_mld_info', $args);
	# ixiahlt::utrackerLog ('emulation_mld_info', $args);

	return ixiangpf::runExecuteCommand('emulation_mld_info', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
