# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def ixnetwork_traffic_control(self, action, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    ixnetwork_traffic_control
		
		 Description:
		    This command starts or stops traffic on a given port list.
		
		 Synopsis:
		    ixnetwork_traffic_control
		        -action                                      CHOICES sync_run
		                                                     CHOICES run
		                                                     CHOICES manual_trigger
		                                                     CHOICES stop
		                                                     CHOICES poll
		                                                     CHOICES reset
		                                                     CHOICES destroy
		                                                     CHOICES clear_stats
		                                                     CHOICES apply
		                                                     CHOICES regenerate
		        [-latency_bins                               RANGE 2-16]
		        [-latency_values                             ANY]
		x       [-latency_enable                             CHOICES 0 1]
		        [-port_handle                                REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
		x       [-cpdp_convergence_enable                    CHOICES 0 1]
		x       [-cpdp_ctrl_plane_events_enable              CHOICES 0 1]
		x       [-cpdp_data_plane_events_rate_monitor_enable CHOICES 0 1]
		x       [-cpdp_data_plane_threshold                  NUMERIC]
		x       [-cpdp_data_plane_jitter                     ANY]
		x       [-delay_variation_enable                     CHOICES 0 1]
		x       [-disable_latency_bins                       FLAG]
		x       [-disable_jitter_bins                        FLAG]
		x       [-duration                                   NUMERIC]
		x       [-handle                                     ANY]
		x       [-instantaneous_stats_enable                 CHOICES 0 1]
		x       [-jitter_bins                                RANGE 2-16]
		x       [-jitter_values                              ANY]
		x       [-l1_rate_stats_enable                       CHOICES 0 1]
		x       [-misdirected_per_flow                       CHOICES 0 1]
		x       [-large_seq_number_err_threshold             NUMERIC]
		x       [-latency_control                            CHOICES cut_through
		x                                                    CHOICES store_and_forward
		x                                                    CHOICES store_and_forward_preamble
		x                                                    CHOICES mef_frame_delay
		x                                                    CHOICES forwarding_delay]
		x       [-max_wait_timer                             NUMERIC
		x                                                    DEFAULT 0]
		x       [-packet_loss_duration_enable                CHOICES 0 1]
		x       [-stats_mode                                 CHOICES rx_delay_variation_avg
		x                                                    CHOICES rx_delay_variation_err_and_rate
		x                                                    CHOICES rx_delay_variation_min_max_and_rate]
		x       [-type                                       CHOICES l23 l47
		x                                                    DEFAULT l23]
		x       [-traffic_generator                          CHOICES ixos ixnetwork ixnetwork_540
		x                                                    DEFAULT ixos]
		
		 Arguments:
		    -action
		        Action to take. Valid choices are:
		    -latency_bins
		        The number of latency bins.
		        Valid for traffic_generator ixos/ixnetwork_540.
		        Otherwise, it will be ignored. When -traffic_generator is ixnetwork_540
		        this option will configure latency bins for all traffic items that have -port_handle
		        as a receiving port. If port_handle is not specified, it will configure latency
		        on all traffic items. If latency was previously configured on a traffic item
		        with ::ixia::traffic_config procedure, then latency bins will not be reconfigured.
		        With traffic_generator ixnetwork_540 this option along with latency_values
		        parameter triggers enable of global latency bins statistics.
		        For ixnetwork_540 there is special value "enabled" which specifies that
		        latency bins statistics will be enabled using the latency values and bins
		        curently configured for each traffic item (no need to specify the latency_values).
		        Latency cannot be enabled in the following conditions:
		        1. delay_variation_enable is 1.
		        2. jitter_bins and jitter_values are specified.
		        3. cpdp_convergence_enable is 1 and cpdp_data_plane_events_rate_monitor_enable is 1.
		    -latency_values
		        The splitting values for the bins.0 and Max will be the absolute end
		        points. A list of {1.5 3 6.8} would create these four bins {0 - 1.5}
		        {1.5 3} {3 6.8} {6.8 MAX}. It is always greater than the lower value
		        and equal to or less than the upper value.
		        This option is supported only if -traffic_generator is set to ixos/ixnetwork_540.
		        Otherwise, it will be ignored. When -traffic_generator is ixnetwork_540
		        this option will configure latency bins for all traffic items that have -port_handle
		        as a receiving port. If port_handle is not specified, it will configure latency
		        on all traffic items. If latency was previously configured on a traffic item
		        with ::ixia::traffic_config procedure, then latency bins will not be reconfigured.
		        With traffic_generator ixnetwork_540 this option along with latency_bins
		        parameter triggers enable of global latency bins statistics. Latency cannot be enabled
		        in the following conditions:
		        1. delay_variation_enable is 1.
		        2. jitter_bins and jitter_values are specified.
		        3. cpdp_convergence_enable is 1 and cpdp_data_plane_events_rate_monitor_enable is 1.
		        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
		x   -latency_enable
		x       If true, latency statistics is enabled and if false, latency statistics is disabled
		    -port_handle
		        List ports where action is to be taken.
		        Mandatory if -traffic_generator is set to ixos.
		        If -traffic_generator is set to ixnetwork the actions that will be
		        provided using -action parameter, will be applied to all ports added
		        in the configuration or to all traffic items, depending on the action.
		        Valid for traffic_generator ixos/ixnetwork/ixnetwork_540.
		x   -cpdp_convergence_enable
		x       Valid only for traffic_generator ixnetwork_540. This option enables/disables
		x       global control plane and data plane integrated time stamping for calculating
		x       convergence measurements. Valid choices are:
		x       0 - disable
		x       1 - enable
		x   -cpdp_ctrl_plane_events_enable
		x       Valid only for traffic_generator ixnetwork_540 when cpdp_convergence_enable is 1.
		x       Enable/Disable control Plane (Protocol) state change or event timestamps used for
		x       convergence measurement. Valid choices are:
		x       0 - disable
		x       1 - enable
		x   -cpdp_data_plane_events_rate_monitor_enable
		x       Valid only for traffic_generator ixnetwork_540 when cpdp_convergence_enable is 1.
		x       Enable/Disable receive ports rate monitoring to detect convergence event
		x       and capture timestamp. Data Plane events cannot be enabled in the following conditions:
		x       1. Sequence checking is enabled (sequence checking is configure with procedure
		x       traffic_config, parameter -frame_sequencing).
		x       2. delay_variation_enable is 1.
		x       3. latency_bins and latency_values parameters are used.
		x       Valid choices are:
		x       0 - disable
		x       1 - enable
		x   -cpdp_data_plane_threshold
		x       Valid only for traffic_generator ixnetwork_540 when cpdp_convergence_enable is 1.
		x       Configure Rx Rate threshold which is a percent of tx rate used to calculate the
		x       data plane convergence (value used to capture timestamps for both the Below Tx
		x       Rate threshold and Above threshold).
		x   -cpdp_data_plane_jitter
		x       Valid only for traffic_generator ixnetwork_540 when cpdp_convergence_enable is 1.
		x       Configure DataPlane jitter window. (TBD)
		x   -delay_variation_enable
		x       Valid only for traffic_generator ixnetwork_540. This option enables/disables
		x       global one-way per packet delay measurement from output port to input port. Valid
		x       choices are:
		x       0 - disable
		x       1 - enable
		x   -disable_latency_bins
		x       Valid only for traffic_generator ixnetwork_540. This options disables global
		x       latency bins statistic measurements.
		x   -disable_jitter_bins
		x       Valid only for traffic_generator ixnetwork_540. This options disables global
		x       jitter bins statistic measurements.
		x   -duration
		x       Duration in seconds of traffic to run.
		x       To set the duration of the traffic use the procedure
		x       ::ixia::traffic_config with the parameter -duration set to a value
		x       in seconds to run frame size or mix of frame sizes.
		x       Valid only for traffic_generator ixos/ixnetwork_540.
		x   -handle
		x       The handle that is used to identify an individual traffic item. It can be a list
		x       of traffic item names, traffic item handles, or items that have as ancestor a traffic item.
		x       Valid only for traffic_generator ixnetwork_540.
		x   -instantaneous_stats_enable
		x       Enables/disables instantaneous mode for statistics retrieval.
		x       When this is set with a different value that is currently in IxNetwork,
		x       all the traffic items will be stopped and regenerated.
		x       If -action is not run or sync_run the caller must issue an
		x       ::ixia::traffic_control -action run to start/resume traffic.
		x       Valid only for traffic_generator ixnetwork_540.
		x   -jitter_bins
		x       The number of jitter bins.
		x       Valid only for traffic_generator ixnetwork_540.
		x       Otherwise, it will be ignored. When -traffic_generator is ixnetwork_540
		x       this option will configure jitter bins for all traffic items that have -port_handle
		x       as a receiving port. If port_handle is not specified, it will configure jitter
		x       on all traffic items. If jitter was previously configured on a traffic item
		x       with ::ixia::traffic_config procedure, then jitter bins will not be reconfigured.
		x       With traffic_generator ixnetwork_540 this option along with jitter_values
		x       parameter triggers enable of global jitter bins statistics.
		x       For ixnetwork_540 there is special value "enabled" which specifies that
		x       latency bins statistics will be enabled using the latency values and bins
		x       curently configured for each traffic item (no need to specify the latency_values).
		x       Jitter bins cannot be enabled in the following conditions:
		x       1. latency_bins and latency_values parameters are used.
		x       2. delay_variation_enable is 1.
		x       3. Sequence checking is enabled (sequence checking is configure with procedure
		x       traffic_config, parameter -frame_sequencing).
		x   -jitter_values
		x       Same as latency bins but, if jitter bins are provided then
		x       jitter measurements will be retrieved with ::ixia::traffic_stats.
		x       Valid only for traffic_generator ixos/ixnetwork_540.
		x       Otherwise, it will be ignored. When -traffic_generator is ixnetwork_540
		x       this option will configure jitter bins for all traffic items that have -port_handle
		x       as a receiving port. If port_handle is not specified, it will configure jitter
		x       on all traffic items. If jitter was previously configured on a traffic item
		x       with ::ixia::traffic_config procedure, then jitter bins will not be reconfigured.
		x       With traffic_generator ixnetwork_540 this option along with jitter_bins
		x       parameter triggers enable of global jitter bins statistics. Jitter bins
		x       cannot be enabled in the following conditions:
		x       1. latency_bins and latency_values parameters are used.
		x       2. delay_variation_enable is 1.
		x       3. Sequence checking is enabled (sequence checking is configure with procedure
		x       traffic_config, parameter -frame_sequencing).
		x   -l1_rate_stats_enable
		x       When this option is enabled the Layer 1 Rate Statistics will be returned when
		x       using ::ixia::traffic_stats with mode aggregate or all. Not specifying this
		x       parameter will cause the Layer 1 Rate Statistics to be returned only if the
		x       "Enable L1 Rate Statistics" option was enabled "Traffic Options" in the GUI.
		x       Setting this parameters from HLT API will also be reflected in IxNetwork GUI.
		x       This parameter is valid only when action is one of the following: run, sync_run,
		x       stop and reset. This parameter applies globally, not per traffic item.
		x       Valid choices are:
		x       0 - disable
		x       1 - enable
		x       Valid only for traffic_generator ixnetwork_540.
		x   -misdirected_per_flow
		x       When this option is enabled the Misdirected Per Flow Statistics will be returned when
		x       using ::ixia::traffic_stats with mode aggregate or all. Not specifying this
		x       parameter will cause the Layer 1 Rate Statistics to be returned only if the
		x       "Misdirected Per Flow Statistics" option was enabled "Traffic Options" in the GUI.
		x       Setting this parameters from HLT API will also be reflected in IxNetwork GUI.
		x       This parameter is valid only when action is one of the following: run, sync_run,
		x       stop and reset. This parameter applies globally, not per traffic item.
		x       Valid choices are:
		x       0 - disable
		x       1 - enable
		x       Valid only for traffic_generator ixnetwork_540.
		x   -large_seq_number_err_threshold
		x       Valid only for traffic_generator ixnetwork_540 and delay_variation_enable 1.
		x       This option configures the threshold value used to determine error levels
		x       for out-of-sequence, received packets.
		x   -latency_control
		x       Valid only for traffic_generator ixos/ixnetwork_540
		x       and delay_variation_enable is '1' or latency_bins and latency_values parameters
		x       are present and disable_latency_bins is not present.
		x       Otherwise, it will be ignored. Not all options are supported on all ports. Check
		x       the reference guide for compatibility chart. Valid choices are:
		x       cut_through - the time interval between the first data bit out of the
		x       Ixia transmit port and the first data bit received by
		x       the Ixia receive port is measured.
		x       store_and_forward - the time interval between the last data bit out
		x       of the Ixia transmit port and the first data bit
		x       received by the Ixia receive port is measured.
		x       store_and_forward_preamble - (for Ethernet modules only with traffic_generator ixos) As with
		x       store and forward, but measured with respect to the
		x       preamble to the Ethernet frame. In this case, the time
		x       interval between the last data bit out of the Ixia
		x       transmit port and the first preamble data bit received
		x       by the Ixia receive port is measured.
		x       mef_frame_delay - valid only for traffic_generator ixnetwork_540. Standard
		x       MEF 10.1 and RFC 3393. The time interval starting when the First
		x       bit of the input frame reaches the input port and ending when
		x       the last bit of the output frame is seen on the output port (FILO)
		x       forwarding_delay - valid only for traffic_generator ixnetwork_540. Standard
		x       RFC 4689. The time interval starting when the last
		x       bit of the input frame reaches the input port and ending when
		x       the last bit of the output frame is seen on the output port (LILO)
		x   -max_wait_timer
		x       The maximum amount of time (in seconds) that HLT waits for the traffic command
		x       to take effect. For example after starting traffic HLT will wait for the traffic
		x       to actually start but no more than <max_wait_timer> seconds. When using many ports
		x       this parameter has to be higher.
		x       Default value is 0 (don't wait).
		x       Valid only for traffic_generator ixnetwork.
		x   -packet_loss_duration_enable
		x       Valid only for traffic_generator ixnetwork_540.
		x       Estimated time without received packets, calculated by frames delta at the
		x       expected rx rate. Valid choices are:
		x       0 - disable
		x       1 - enable
		x   -stats_mode
		x       Valid only for traffic_generator ixnetwork_540 when delay_variation is '1'.
		x   -type
		x       The type of the configured traffic that should be applied on the
		x       chassis. Valid for traffic_generator ixnetwork.
		x       Otherwise, it will be ignored.
		x   -traffic_generator
		x       The Ixia product that was used for configuring traffic.
		
		 Return Values:
		    $::SUCCESS | $::FAILURE
		    key:status                           value:$::SUCCESS | $::FAILURE
		    On status of failure, gives detailed information.
		    key:log                              value:On status of failure, gives detailed information.
		    0 if traffic is running, or 1 if traffic is stopped. This key is returned when option -action is set on run, sync_run or stop.
		    key:stopped                          value:0 if traffic is running, or 1 if traffic is stopped. This key is returned when option -action is set on run, sync_run or stop.
		    key:-ipv6_hop_by_hop_options follow  value:
		    <CHOICES pad1 padn jumbo router_alert binding_update binding_ack binding_req user_define mipv6_unique_id_sub  mipv6_alternative_coa_sub user_defined> This is a mandatory key. The type of IPv6 Hop by Hop option that needs to be added. According to RFC 2711, there  should only be one router_alert option per hop by hop extension. Configuring against the RFC the results may not be the expected ones. Valid only for traffic_generator ixos/ixnetwork_540. With ixnetwork_540 the supported types are pad1 padn and user_defined.
		    key:type                             value:<CHOICES pad1 padn jumbo router_alert binding_update binding_ack binding_req user_define mipv6_unique_id_sub  mipv6_alternative_coa_sub user_defined> This is a mandatory key. The type of IPv6 Hop by Hop option that needs to be added. According to RFC 2711, there  should only be one router_alert option per hop by hop extension. Configuring against the RFC the results may not be the expected ones. Valid only for traffic_generator ixos/ixnetwork_540. With ixnetwork_540 the supported types are pad1 padn and user_defined.
		    <RANGE 0-255> This applies to all key types except pad1. The length value for the IPv6 Hop by Hop option. Valid only for traffic_generator ixos/ixnetwork_540.
		    key:length                           value:<RANGE 0-255> This applies to all key types except pad1. The length value for the IPv6 Hop by Hop option. Valid only for traffic_generator ixos/ixnetwork_540.
		    <HEX BYTES separated by  :  or  . > This applies to padn, user_define types. The value for the IPv6 Hop by Hop option. Valid only for traffic_generator ixos/ixnetwork_540.
		    key:value                            value:<HEX BYTES separated by  :  or  . > This applies to padn, user_define types. The value for the IPv6 Hop by Hop option. Valid only for traffic_generator ixos/ixnetwork_540.
		    <RANGE 0-4294967295> This applies to jumbo type. The payload for the IPv6 Hop by Hop option. Valid only for traffic_generator ixos.
		    key:payload                          value:<RANGE 0-4294967295> This applies to jumbo type. The payload for the IPv6 Hop by Hop option. Valid only for traffic_generator ixos.
		    <RANGE 0-65535> This applies to mipv6_unique_id_sub type. A unique ID for the binding request. Valid only for traffic_generator ixos.
		    key:sub_unique                       value:<RANGE 0-65535> This applies to mipv6_unique_id_sub type. A unique ID for the binding request. Valid only for traffic_generator ixos.
		    <CHOICES mld rsvp active_net> This applies to router_alert type. Specifies the type of router alert to include with  the packet. Valid only for traffic_generator ixos.
		    key:alert_type                       value:<CHOICES mld rsvp active_net> This applies to router_alert type. Specifies the type of router alert to include with  the packet. Valid only for traffic_generator ixos.
		    <CHOICES 0 1>  This applies to binding_update type. This flag sets the Acknowledge (A) bit to indicate that the sending  mobile node is requesting that a Binding Acknowledgement be sent by the receiving node when it gets the Binding Update.  Valid only for traffic_generator ixos. (DEFAULT = 0)
		    key:ack                              value:<CHOICES 0 1>  This applies to binding_update type. This flag sets the Acknowledge (A) bit to indicate that the sending  mobile node is requesting that a Binding Acknowledgement be sent by the receiving node when it gets the Binding Update.  Valid only for traffic_generator ixos. (DEFAULT = 0)
		    <CHOICES 0 1> This applies to binding_update type. Enables the bicasting flag for the Binding Update header. Valid only for traffic_generator ixos. (DEFAULT = 0)
		    key:bicast                           value:<CHOICES 0 1> This applies to binding_update type. Enables the bicasting flag for the Binding Update header. Valid only for traffic_generator ixos. (DEFAULT = 0)
		    <CHOICES 0 1> This applies to binding_update type. This flag sets the Duplicate Address Detection (D) bit, to indicate that the sending node wants the receiving node to perform Duplicate Address Detection for the mobile node s home address in this  binding. The H and A bits MUST also be set for this action to be performed. Valid only for traffic_generator ixos. (DEFAULT = 0)
		    key:duplicate                        value:<CHOICES 0 1> This applies to binding_update type. This flag sets the Duplicate Address Detection (D) bit, to indicate that the sending node wants the receiving node to perform Duplicate Address Detection for the mobile node s home address in this  binding. The H and A bits MUST also be set for this action to be performed. Valid only for traffic_generator ixos. (DEFAULT = 0)
		    <CHOICES 0 1> This applies to binding_update type. This flag sets the Home Registration (H) bit to indicate that the  sending node wants the receiving node to act as its home agent. Valid only for traffic_generator ixos. (DEFAULT = 0)
		    key:home                             value:<CHOICES 0 1> This applies to binding_update type. This flag sets the Home Registration (H) bit to indicate that the  sending node wants the receiving node to act as its home agent. Valid only for traffic_generator ixos. (DEFAULT = 0)
		    <CHOICES 0 1> This applies to binding_update type. Enables the map flag for the Binding Update header. Valid only for traffic_generator ixos. (DEFAULT = 0)
		    key:map                              value:<CHOICES 0 1> This applies to binding_update type. Enables the map flag for the Binding Update header. Valid only for traffic_generator ixos. (DEFAULT = 0)
		    <CHOICES 0 1> This applies to binding_update type. This flag indicates if the binding cache entry is for a mobile node advertised as a router by this node, on the behalf of the mobile node, in proxy Neighbor Advertisements. Valid only for traffic_generator ixos. (DEFAULT = 0)
		    key:router                           value:<CHOICES 0 1> This applies to binding_update type. This flag indicates if the binding cache entry is for a mobile node advertised as a router by this node, on the behalf of the mobile node, in proxy Neighbor Advertisements. Valid only for traffic_generator ixos. (DEFAULT = 0)
		    <RANGE 0-255> This applies to binding_update type. If the H-bit is set, this is the length of the routing prefix  for the home address. Valid only for traffic_generator ixos.
		    key:prefix_len                       value:<RANGE 0-255> This applies to binding_update type. If the H-bit is set, this is the length of the routing prefix  for the home address. Valid only for traffic_generator ixos.
		    <RANGE 0-4294967295> This applies to binding_update, binding_ack types. (32-bit integer) The number of seconds  remaining for the Binding Cache entry.  When the value reaches zero, the binding MUST be  considered expired and the Binding Cache entry MUST be  deleted for the mobile node. Valid only for traffic_generator ixos.
		    key:life_time                        value:<RANGE 0-4294967295> This applies to binding_update, binding_ack types. (32-bit integer) The number of seconds  remaining for the Binding Cache entry.  When the value reaches zero, the binding MUST be  considered expired and the Binding Cache entry MUST be  deleted for the mobile node. Valid only for traffic_generator ixos.
		    <RANGE 0-65535> This applies to binding_update, binding_ack types. For type binding_update: The mobile node uses this  number in the  Binding Update. The receiving node uses the same number in its Binding Acknowledgement, for matching. The Sequence number in each  Binding Update to one destination address must be greater than the last. For type binding_ack: This integer is copied from the received Binding  Update into the corresponding Binding ACK message. Valid only for traffic_generator ixos.
		    key:seq_num                          value:<RANGE 0-65535> This applies to binding_update, binding_ack types. For type binding_update: The mobile node uses this  number in the  Binding Update. The receiving node uses the same number in its Binding Acknowledgement, for matching. The Sequence number in each  Binding Update to one destination address must be greater than the last. For type binding_ack: This integer is copied from the received Binding  Update into the corresponding Binding ACK message. Valid only for traffic_generator ixos.
		    <RANGE 0-255> This applies to binding_ack type. This value indicates the disposition of the Binding Update:  0-127=  Binding Update was accepted.  >/= 128 = Binding Update was rejected. Valid only for traffic_generator ixos.
		    key:status                           value:<RANGE 0-255> This applies to binding_ack type. This value indicates the disposition of the Binding Update:  0-127=  Binding Update was accepted.  >/= 128 = Binding Update was rejected. Valid only for traffic_generator ixos.
		    <RANGE 0-4294967295> This applies to binding_ack type. The mobile node SHOULD send a new Binding Update at this  recommended interval, to refresh the binding. The receiving node  (the node which sends the Binding ACK) determines the refresh interval (in  seconds). Valid only for traffic_generator ixos.
		    key:refresh                          value:<RANGE 0-4294967295> This applies to binding_ack type. The mobile node SHOULD send a new Binding Update at this  recommended interval, to refresh the binding. The receiving node  (the node which sends the Binding ACK) determines the refresh interval (in  seconds). Valid only for traffic_generator ixos.
		    <IPV6> The IPv6 address for mipv6_alternative_coa_sub type. Valid only for traffic_generator ixos.
		    key:address                          value:<IPV6> The IPv6 address for mipv6_alternative_coa_sub type. Valid only for traffic_generator ixos.
		    <CHOICES skip discard discard_icmp discard_icmp_if_not_multicast>. Behavior if option unrecognized. Valid only for traffic_generator ixnetwork_540.
		    key:unrecognized_type                value:<CHOICES skip discard discard_icmp discard_icmp_if_not_multicast>. Behavior if option unrecognized. Valid only for traffic_generator ixnetwork_540.
		    <CHOICES 0 1>. Allow packet change. Valid only for traffic_generator ixnetwork_540.
		    key:allow_packet_change              value:<CHOICES 0 1>. Allow packet change. Valid only for traffic_generator ixnetwork_540.
		    <RANGE 0-31>. User defined option type. Valid only for traffic_generator ixnetwork_540.
		    key:user_defined_type                value:<RANGE 0-31>. User defined option type. Valid only for traffic_generator ixnetwork_540.
		    <HEX BYTES separated by  :  or  . > This applies to user_defined, user_define types. The value for the IPv6 Hop by Hop option. Valid only for traffic_generator ixnetwork_540.
		    key:data                             value:<HEX BYTES separated by  :  or  . > This applies to user_defined, user_define types. The value for the IPv6 Hop by Hop option. Valid only for traffic_generator ixnetwork_540.
		
		 Examples:
		    See files starting with Streams_ in the Samples subdirectory. Also see some of the other sample files in Appendix A, "Example APIs."
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    1) Coded versus functional specification.
		    2) When using traffic_stats -mode stream or -packet_group_id options,
		    then traffic_control with -action clear_stats or -action sync_run
		    should be called first.
		
		 See Also:
		
		'''
		hlpy_args = locals().copy()
		hlpy_args.update(kwargs)
		del hlpy_args['self']
		del hlpy_args['kwargs']

		not_implemented_params = []
		mandatory_params = []
		file_params = []

		try:
			return self.__execute_command(
				'ixnetwork_traffic_control', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
