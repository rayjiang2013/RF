##Procedure Header
# Name:
#    ::ixiangpf::emulation_ldp_info
#
# Description:
#    Retrieves information about the LDP protocol.
#
# Synopsis:
#    ::ixiangpf::emulation_ldp_info
#        -mode    CHOICES stats
#                 CHOICES clear_stats
#                 CHOICES settings
#                 CHOICES neighbors
#                 CHOICES lsp_labels
#                 CHOICES stats_per_device_group
#                 CHOICES session
#        -handle  ANY
#
# Arguments:
#    -mode
#        What action will be taken.Valid options are:
#        stats
#        clear_stats
#        settings
#        neighbors
#        lsp_labels
#        stats_per_device_group
#        session
#    -handle
#        The LDP session handle to act upon.
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status                        value:$::SUCCESS | $::FAILURE
#    If status is failure, detailed information provided.
#    key:log                           value:If status is failure, detailed information provided.
#    Ixia only
#x   key:port_name                     value:Ixia only
#    Ixia only
#x   key:basic_sessions                value:Ixia only
#    Ixia only
#x   key:targeted_sessions_running     value:Ixia only
#    Ixia only
#x   key:targeted_sessions_configured  value:Ixia only
#    Cisco only
#n   key:routing_protocol              value:Cisco only
#    Cisco only
#n   key:ip_address                    value:Cisco only
#    Cisco only
#n   key:elapsed_time                  value:Cisco only
#    Cisco only
#n   key:linked_hellos_tx              value:Cisco only
#    Cisco only
#n   key:linked_hellos_rx              value:Cisco only
#    Cisco only
#n   key:targeted_hellos_tx            value:Cisco only
#    Cisco only
#n   key:targeted_hellos_rx            value:Cisco only
#    Cisco only
#n   key:total_setup_time              value:Cisco only
#    Cisco only
#n   key:min_setup_time                value:Cisco only
#    Cisco only
#n   key:max_setup_time                value:Cisco only
#    Cisco only
#n   key:num_lsps_setup                value:Cisco only
#    No further support planned
#    key:req_rx                        value:No further support planned
#    No further support planned
#    key:req_tx                        value:No further support planned
#    No further support planned
#    key:map_rx                        value:No further support planned
#    No further support planned
#    key:map_tx                        value:No further support planned
#    No further support planned
#    key:release_rx                    value:No further support planned
#    No further support planned
#    key:release_tx                    value:No further support planned
#    No further support planned
#    key:withdraw_rx                   value:No further support planned
#    No further support planned
#    key:withdraw_tx                   value:No further support planned
#    No further support planned
#    key:abort_rx                      value:No further support planned
#    No further support planned
#    key:abort_tx                      value:No further support planned
#    No further support planned
#    key:notif_rx                      value:No further support planned
#    No further support planned
#    key:notif_tx                      value:No further support planned
#    No further support planned; Cisco only
#n   key:max_peers                     value:No further support planned; Cisco only
#    No further support planned; Cisco only
#n   key:max_lsps                      value:No further support planned; Cisco only
#    No further support planned; Cisco only
#n   key:peer_count                    value:No further support planned; Cisco only
#    No further support planned
#    key:intf_ip_addr      a.b.c.d     value:No further support planned
#    No further support planned; Cisco only
#n   key:transport_address a.b.c.d     value:No further support planned; Cisco only
#    No further support planned
#    key:targeted_hello                value:No further support planned
#    No further support planned
#    key:label_adv                     value:No further support planned
#    No further support planned
#    key:hello_hold_time               value:No further support planned
#    No further support planned
#    key:hello_interval                value:No further support planned
#    No further support planned
#    key:keepalive_interval            value:No further support planned
#    No further support planned
#    key:keepalive_holdtime            value:No further support planned
#    No further support planned
#    key:label_space                   value:No further support planned
#    No further support planned
#    key:vpi                           value:No further support planned
#    No further support planned
#    key:vci                           value:No further support planned
#    No further support planned
#    key:atm_range_min_vci             value:No further support planned
#    No further support planned
#    key:atm_range_max_vci             value:No further support planned
#    No further support planned
#    key:atm_range_min_vpi             value:No further support planned
#    No further support planned
#    key:atm_range_max_vpi             value:No further support planned
#    No further support planned; Cisco only
#n   key:vc_direction                  value:No further support planned; Cisco only
#    No further support planned; Cisco only
#n   key:atm_merge_capability          value:No further support planned; Cisco only
#    No further support planned; Cisco only
#n   key:fr_merge_capability           value:No further support planned; Cisco only
#    No further support planned; Cisco only
#n   key:path_vector_limit             value:No further support planned; Cisco only
#    No further support planned; Cisco only
#n   key:max_pdu_length                value:No further support planned; Cisco only
#    No further support planned; Cisco only
#n   key:loop_detection                value:No further support planned; Cisco only
#    No further support planned
#    key:ip_address  a.b.c.d           value:No further support planned
#    No further support planned
#    key:hold_time                     value:No further support planned
#    No further support planned
#    key:keepalive                     value:No further support planned
#    No further support planned; Cisco only
#n   key:label_type                    value:No further support planned; Cisco only
#    No further support planned; Cisco only
#n   key:config_seq_no                 value:No further support planned; Cisco only
#    No further support planned; Cisco only
#n   key:max_lsps                      value:No further support planned; Cisco only
#    No further support planned; Cisco only
#n   key:max_peers                     value:No further support planned; Cisco only
#    No further support planned; Cisco only
#n   key:atm_label_range               value:No further support planned; Cisco only
#    No further support planned; Cisco only
#n   key:fr_label_range                value:No further support planned; Cisco only
#    Cisco only; disabled|nonexist|hello_adj|init|openrec|opensent|operational
#n   key:session_state                 value:Cisco only; disabled|nonexist|hello_adj|init|openrec|opensent|operational
#    Cisco only; number of opened LSPs
#n   key:num_incoming_ingress_lsps     value:Cisco only; number of opened LSPs
#    Cisco only; number of opened LSPs
#n   key:num_incoming_egress_lsps      value:Cisco only; number of opened LSPs
#    Cisco only
#n   key:lsp_pool_handle.<handle>.     value:Cisco only
#    Cisco only; {ingress|egress}
#n   key:type                          value:Cisco only; {ingress|egress}
#    Cisco only; <number of opened LSPs>
#n   key:num_opened_lsps               value:Cisco only; <number of opened LSPs>
#    Ixia only; list of neighbors of the selected LSR
#x   key:neighbors                     value:Ixia only; list of neighbors of the selected LSR
#    list of values like: <pool_handle>, incoming_egress
#    key:source                        value:list of values like: <pool_handle>, incoming_egress
#    Ixia only; list of ipv4_prefix|host_addr...
#    key:fec_type                      value:Ixia only; list of ipv4_prefix|host_addr...
#    Ixia only; list of FEC IP prefix (only for link or targeted sessions)
#    key:prefix                        value:Ixia only; list of FEC IP prefix (only for link or targeted sessions)
#    Ixia only; list of FEC prefix length (only for link or targeted sessions)
#    key:prefix_length                 value:Ixia only; list of FEC prefix length (only for link or targeted sessions)
#    Ixia only; list of MPLS label (for IPv4 labels)
#    key:label                         value:Ixia only; list of MPLS label (for IPv4 labels)
#    Ixia only; list of values learned | assigned
#x   key:type                          value:Ixia only; list of values learned | assigned
#    Ixia only; list of Group IDs (only for martini labels)
#x   key:group_id                      value:Ixia only; list of Group IDs (only for martini labels)
#    Ixia only; list of VC IDs (only for martini labels)
#x   key:vc_id                         value:Ixia only; list of VC IDs (only for martini labels)
#    Ixia only; list of VC types like: frameRelay, ATMAAL5, ATMXCell, etc.
#x   key:vc_type                       value:Ixia only; list of VC types like: frameRelay, ATMAAL5, ATMXCell, etc.
#    Ixia only; list of VCI (only for ATM labels)
#x   key:vci                           value:Ixia only; list of VCI (only for ATM labels)
#    Ixia only; list of VPI (only for ATM labels)
#x   key:vpi                           value:Ixia only; list of VPI (only for ATM labels)
#    Ixia only; list of state (only for ATM assigned labels)
#x   key:state                         value:Ixia only; list of state (only for ATM assigned labels)
#
# Examples:
#    See files starting with LDP_ in the Samples subdirectory.  Also see some of the L2VPN, L3VPN, MPLS, and MVPN sample files for further examples of the LDP usage.
#    See the LDP example in Appendix A, "Example APIs," for one specific example usage.
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    Coded versus functional specification.
#
# See Also:
#

proc ::ixiangpf::emulation_ldp_info { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "emulation_ldp_info" $notImplementedParams $mandatoryParams $fileParams $args]
}
