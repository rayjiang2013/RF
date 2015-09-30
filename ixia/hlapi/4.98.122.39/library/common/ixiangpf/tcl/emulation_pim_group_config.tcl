##Procedure Header
# Name:
#    ::ixiangpf::emulation_pim_group_config
#
# Description:
#    This procedure configures Multicast groups added to a PIM session.  This
#    allows adding (*,G) or (S,G) entries to PIM session.
#
# Synopsis:
#    ::ixiangpf::emulation_pim_group_config
#        [-mode                               CHOICES create
#                                             CHOICES delete
#                                             CHOICES modify
#                                             CHOICES clear_all
#                                             CHOICES disable
#                                             CHOICES enable
#                                             DEFAULT create]
#        [-session_handle                     ANY]
#        [-group_pool_handle                  ANY]
#        [-source_pool_handle                 ANY]
#        [-handle                             ANY]
#x       [-return_detailed_handles            CHOICES 0 1
#x                                            DEFAULT 0]
#        [-adv_hold_time                      RANGE 2-65535
#                                             DEFAULT 150]
#        [-back_off_interval                  RANGE 0-255
#                                             DEFAULT 3]
#        [-crp_ip_addr                        IP]
#        [-rp_ip_addr                         IP]
#x       [-rp_ip_addr_step                    IP]
#        [-group_pool_mode                    CHOICES send register candidate_rp]
#        [-join_prune_aggregation_factor      CHOICES 0 1]
#        [-wildcard_group                     CHOICES 0 1]
#        [-s_g_rpt_group                      CHOICES 0 1]
#        [-rate_control                       CHOICES 0 1]
#        [-interval                           RANGE 0-1000]
#        [-join_prune_per_interval            NUMERIC]
#        [-register_per_interval              NUMERIC]
#x       [-register_stop_per_interval         NUMERIC]
#x       [-hello_message_per_interval         NUMERIC]
#x       [-discard_join_prune_processing      CHOICES 0 1]
#x       [-crp_advertise_message_per_interval NUMERIC]
#x       [-bootstrap_message_per_interval     NUMERIC]
#x       [-flap_interval                      RANGE 1-65535]
#        [-periodic_adv_interval              RANGE 1-65535
#                                             DEFAULT 60]
#        [-pri_change_interval                RANGE 1-65535
#                                             DEFAULT 60]
#        [-pri_type                           CHOICES same incremental random]
#        [-pri_value                          RANGE 0-255
#                                             DEFAULT 192]
#x       [-register_tx_iteration_gap          RANGE 100-2147483647]
#x       [-register_stop_trigger_count        RANGE 1-127]
#x       [-register_udp_destination_port      RANGE 1-65535]
#x       [-register_udp_source_port           RANGE 1-65535]
#x       [-register_triggered_sg              CHOICES 0 1]
#        [-router_count                       RANGE 1-65535
#                                             DEFAULT 1]
#x       [-spt_switchover                     CHOICES 0 1]
#x       [-source_group_mapping               CHOICES fully_meshed one_to_one]
#x       [-switch_over_interval               RANGE 0-65535]
#x       [-send_null_register                 CHOICES 0 1
#x                                            DEFAULT 0]
#        [-trigger_crp_msg_count              RANGE 1-3
#                                             DEFAULT 3]
#n       [-writeFlag                          ANY]
#n       [-no_write                           ANY]
#x       [-default_mdt_mode                   CHOICES neighbor auto
#x                                            DEFAULT neighbor]
#n       [-border_bit                         ANY]
#x       [-group_range_type                   CHOICES startorp
#x                                            CHOICES startogroup
#x                                            CHOICES sourcetogroup
#x                                            CHOICES stargtosourcegroup
#x                                            CHOICES registeredtriggered]
#x       [-enable_flap_info                   ANY]
#x       [-discard_sg_join_states             ANY]
#x       [-multicast_data_length              ANY]
#x       [-supression_time                    ANY]
#x       [-register_probe_time                ANY]
#x       [-prune_source_address               IP]
#x       [-prune_source_mask_width            NUMERIC]
#x       [-prune_source_address_count         NUMERIC]
#x       [-crp_group_mask_len                 NUMERIC]
#x       [-join_prune_group_mask_width        NUMERIC]
#x       [-join_prune_source_mask_width       NUMERIC]
#
# Arguments:
#    -mode
#        This option defines the action to be taken. Note: modify and delete
#        options are not supported for IxTclProtocol. Valid choices are:
#        create- (default) An existing multicast group pool is associated/linked
#        with the specified PIM session.
#        delete- Remove one group pools from this session
#        clear_all - Removes all group pools from this session.
#        modify- Modifies group pools from this session.
#        enable- Enables the given item provided by -handle.
#        disable- Disables the given item provided by -handle.
#    -session_handle
#        PIM-SM session handle.
#    -group_pool_handle
#        Groups to be added beforehand through procedure
#        emulation_multicast_group_config. This parameter may be a list. If the case,
#        all other parameters that can be lists should have the same list length.
#    -source_pool_handle
#        Associate source pool(s) with the group.The source pool(s) must be
#        added beforehand through procedure emulation_multicast_source_config.
#        Specify one or more source pool handle(s) for (S,G) entries.None
#        for (*,G) entries.If one or more are specified, source-specific
#        join/prune will be enabled; otherwise it is disabled. This parameter may be a list. If the case,
#        all other parameters that can be lists should have the same list length.
#    -handle
#        Group membership handle that associates a group pool with a PIM
#        session.This option is returned from previous call to this proc
#        with "create" mode.In "modify" mode, membership handle must be
#        used in conjunction with the session handle to identify the member
#        group pool. If this is a list, all other parameters that can be lists
#        should have the same list length. As such, multiple router interfaces
#        will be created with the given parameters.
#x   -return_detailed_handles
#x       This argument determines if individual interface, session or router handles are returned by the current command.
#x       This applies only to the command on which it is specified.
#x       Setting this to 0 means that only NGPF-specific protocol stack handles will be returned. This will significantly
#x       decrease the size of command results and speed up script execution.
#x       The default is 0, meaning only protocol stack handles will be returned.
#    -adv_hold_time
#        This parameter represents the time interval (in seconds) between two
#        consecutive Candidate RP advertisements.
#    -back_off_interval
#        The back off time interval for the C-RP-Adv messages.
#    -crp_ip_addr
#        Start address of the set of candidate RPs to be simulated.
#    -rp_ip_addr
#        The IP address of Rendezvous Point router for the multicast group
#        pool. This parameter may be a list. If the case,
#        all other parameters that can be lists should have the same list length.
#x   -rp_ip_addr_step
#x       The incrementing step for the IP address of Rendezvous Point router
#x       for the multicast group pool.
#    -group_pool_mode
#        Specifies whether the membership pool is used to send or receive
#        PIM messages. Note: no configuration required for receive mode.
#        Valid choices are:
#        send - Sends Join/Prunes (downstream DR) messages.
#        register - Sends Register and NULL Register messages. (source DR)
#        and receive Stop-Register messages.
#        candidate_rp - Creates new Candidate Rendez-Vous.
#    -join_prune_aggregation_factor
#        If 1, enables the packing of multiple groups in a single packet;
#        however, this option does not specify the exact number groups in a
#        packet. This parameter may be a list. If the case,
#        all other parameters that can be lists should have the same list length.
#    -wildcard_group
#        If true (1), enable wildcard group.When enabled, (*,*,RP) Join/
#        Prune messages are sent.Takes effect only if (S,G) is disabled.
#        (no source pool). This parameter may be a list. If the case,
#        all other parameters that can be lists should have the same list length.
#        (DEFAULT = 0)
#    -s_g_rpt_group
#        If true (1), enable (S,G,rpt).When enabled, (S,G,rpt) Join/Prune
#        messages are sent.Takes effect only if (S,G) is enabled.
#        Note: only one of s_g_rpt_group, register_triggered_sg,
#        spt_switchover options can be enabled per multicast group. This parameter may be a list. If the case,
#        all other parameters that can be lists should have the same list length.
#        (DEFAULT = 0)
#    -rate_control
#        If true (1), enable rate control on Join/Prune and register messages.
#    -interval
#        The length of interval (in ms) during which a number of messages will
#        be sent.If 0, send as fast as possible.
#    -join_prune_per_interval
#        The number of Join/Prune messages sent per interval.
#    -register_per_interval
#        The number of Register messages sent per interval.
#x   -register_stop_per_interval
#x       The number of Register Stop messages sent per interval.
#x   -hello_message_per_interval
#x       Hello Messages per Interval
#x   -discard_join_prune_processing
#x       Discard join/Prune Processing
#x   -crp_advertise_message_per_interval
#x       C-RP Advertise Messages per Interval
#x   -bootstrap_message_per_interval
#x       Bootstrap Messages Per Interval
#x   -flap_interval
#x       If flap is enabled thru the emulation_pim_control, this is the amount
#x       amount of time, in seconds, between simulated flap events.
#x       (DEFAULT= 60)
#    -periodic_adv_interval
#        Rate controlling variable indicating how many C-RP-Adv messages can be sent
#        in the specified time interval.
#    -pri_change_interval
#        Time interval after which priority of all the RPs get changed, if priority type is
#        incremental or random.
#    -pri_type
#        priorityType This indicates the type of priority to be held by the
#        candidate RPs (CRPs). One of:
#        same- (default) CRPs send advertisement messages
#        with time invariant fixed priority as specified
#        in CRP Advertisement Message Priority.
#        incremental - Priority starts from the configured value and
#        with every Priority Change Interval,
#        the CRPs priority get incremented by 1.
#        random- The start value is selected based on a
#        pseudorandom number generator with every Priority
#        Change Interval, when sending the next
#        batch of CRP-Adv messages.
#    -pri_value
#        Value of priority field sent in candidate RP advertisement messages.
#x   -register_tx_iteration_gap
#x       The gap, in milliseconds, between periodically transmitted Register
#x       messages. This parameter may be a list. If the case,
#x       all other parameters that can be lists should have the same list length.
#x       (DEFAULT = 5000)
#x   -register_stop_trigger_count
#x       If register_triggered_sg option is enabled (1), this is the count of
#x       register messages received that will trigger transmission of a (S,G)
#x       message. This parameter may be a list. If the case,
#x       all other parameters that can be lists should have the same list length.
#x       (DEFAULT = 10)
#x   -register_udp_destination_port
#x       The number of UDP destination ports in the receiving multicast group. This parameter may be a list. If the case,
#x       all other parameters that can be lists should have the same list length.
#x       (DEFAULT = 3000)
#x   -register_udp_source_port
#x       The number of UDP source ports sending encapsulated UDP packets to
#x       multicast groups via Register messages to the RP. This parameter may be a list. If the case,
#x       all other parameters that can be lists should have the same list length.
#x       (DEFAULT = 3000)
#x   -register_triggered_sg
#x       When enabled (1), sends (S,G) Join/Prune messages when matching
#x       registers have been received. Sends register stop after
#x       registerStopTriggerCount registers have been received.
#x       Note: only one of s_g_rpt_group, register_triggered_sg,
#x       spt_switchover options can be enabled per PIM group.
#    -router_count
#        Total number of candidate RPs to be simulated starting from C-RP Address.
#        A contiguous address range is used for this RP range simulation.
#x   -spt_switchover
#x       When enabled (1), Sends (*,G)->(S,G) switchover type. Indicates that
#x       the simulated router will switch over from a non-source specific
#x       group state to a source specific group state.
#x       Note: only one of s_g_rpt_group, register_triggered_sg,
#x       spt_switchover options can be enabled per PIM group. This parameter may be a list. If the case,
#x       all other parameters that can be lists should have the same list length.
#x   -source_group_mapping
#x       Set the type of mapping that occurs when routes are advertised. This
#x       only applies for (S,G) and switchover types for MGR and is meaningful
#x       for RR.Choices are: fully_meshed, one_to_one. This parameter may be a list. If the case,
#x       all other parameters that can be lists should have the same list length.
#x   -switch_over_interval
#x       The time interval, in seconds, allowed for the switch from using the
#x       RP tree to using a source-specific tree. Used when spt_switchover
#x       option is enabled. This parameter may be a list. If the case,
#x       all other parameters that can be lists should have the same list length.
#x       (DEFAULT = 0)
#x   -send_null_register
#x       Enables the transmission of an initial null registration at
#x       emulation startup. This parameter may be a list. If the case,
#x       all other parameters that can be lists should have the same list length.
#x       (DEFAULT = 0)
#    -trigger_crp_msg_count
#        The number of times CRP Advertisments is sent to the newly elected Bootstrap Router.
#n   -writeFlag
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -no_write
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -default_mdt_mode
#x       If this parameter is set on auto, the mvpn specific verifications will be bypassed
#x       and the emulation_pim_group_config call will assume that all received interfaces/groups/sources
#x       are correctly configured.
#x       (DEFAULT = neighbor)
#n   -border_bit
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -group_range_type
#x       Range Type
#x   -enable_flap_info
#x       Enable Flap info
#x   -discard_sg_join_states
#x       The learned join states sent by the RP (DUT) in response to this specific register message will be discarded
#x   -multicast_data_length
#x       The length of multicast data, in bytes
#x   -supression_time
#x       Register Suppression Time
#x   -register_probe_time
#x       Register Probe Time
#x   -prune_source_address
#x       Prune Source address
#x   -prune_source_mask_width
#x       Prune source address Maskwidth
#x   -prune_source_address_count
#x       Prune Source Address count
#x   -crp_group_mask_len
#x       CRP group mask length
#x   -join_prune_group_mask_width
#x       Join/Prune group address Maskwidth
#x   -join_prune_source_mask_width
#x       Join/Prune source address Maskwidth
#
# Return Values:
#    A list containing the pim v4 join prune protocol stack handles that were added by the command (if any).
#x   key:pim_v4_join_prune_handle    value:A list containing the pim v4 join prune protocol stack handles that were added by the command (if any).
#    A list containing the pim v4 candidate rp protocol stack handles that were added by the command (if any).
#x   key:pim_v4_candidate_rp_handle  value:A list containing the pim v4 candidate rp protocol stack handles that were added by the command (if any).
#    A list containing the pim v4 source protocol stack handles that were added by the command (if any).
#x   key:pim_v4_source_handle        value:A list containing the pim v4 source protocol stack handles that were added by the command (if any).
#    A list containing the pim v6 join prune protocol stack handles that were added by the command (if any).
#x   key:pim_v6_join_prune_handle    value:A list containing the pim v6 join prune protocol stack handles that were added by the command (if any).
#    A list containing the pim v6 candidate rp protocol stack handles that were added by the command (if any).
#x   key:pim_v6_candidate_rp_handle  value:A list containing the pim v6 candidate rp protocol stack handles that were added by the command (if any).
#    A list containing the pim v6 source protocol stack handles that were added by the command (if any).
#x   key:pim_v6_source_handle        value:A list containing the pim v6 source protocol stack handles that were added by the command (if any).
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:interfaces                  value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    $::SUCCESS | $::FAILURE
#    key:status                      value:$::SUCCESS | $::FAILURE
#    When status is failure, contains more information
#    key:log                         value:When status is failure, contains more information
#    group_member_handle
#    key:handle                      value:group_member_handle
#    group_pool_handle
#    key:group_pool_handle           value:group_pool_handle
#    source_pool_handles
#    key:source_pool_handles         value:source_pool_handles
#
# Examples:
#    See files starting with PIM_ in the Samples subdirectory.  Also see some of the MVPN sample files for further examples of the PIM usage.
#    See the PIM example in Appendix A, "Example APIs," for one specific example usage.
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    1) MVPN parameters are not supported with IxTclNetwork API (new API). If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  interfaces
#
# See Also:
#

proc ::ixiangpf::emulation_pim_group_config { args } {

	set notImplementedParams "{}"
	set mandatoryParams "{}"
	set fileParams "{}"
	set procName [lindex [info level [info level]] 0]
	::ixia::logHltapiCommand $procName $args
	::ixia::utrackerLog $procName $args
	return [eval runExecuteCommand "emulation_pim_group_config" $notImplementedParams $mandatoryParams $fileParams $args]
}
