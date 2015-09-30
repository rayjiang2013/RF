##Procedure Header
# Name:
#    ixiangpf::emulation_igmp_config
#
# Description:
#    This procedure will configure IGMP Host(s). Note that IGMP is only
#    supported on ports with CPUs.
#
# Synopsis:
#    ixiangpf::emulation_igmp_config
#        [-handle                          ANY]
#x       [-protocol_name                   ALPHA]
#        -mode                             CHOICES create
#                                          CHOICES delete
#                                          CHOICES modify
#                                          CHOICES enable
#                                          CHOICES disable
#                                          CHOICES enable_all
#                                          CHOICES disable_all
#x       [-return_detailed_handles         CHOICES 0 1
#x                                         DEFAULT 0]
#n       [-atm_encapsulation               ANY]
#        [-count                           NUMERIC
#                                          DEFAULT 1]
#n       [-enable_packing                  ANY]
#        [-filter_mode                     CHOICES include exclude
#                                          DEFAULT include]
#        [-general_query                   CHOICES 0 1
#                                          DEFAULT 1]
#        [-global_settings_enable          CHOICES 0 1]
#        [-group_query                     CHOICES 0 1
#                                          DEFAULT 1]
#        [-igmp_version                    CHOICES v1 v2 v3
#                                          DEFAULT v2]
#        [-inter_stb_start_delay           NUMERIC
#                                          DEFAULT 0]
#x       [-interface_handle                ANY]
#        [-intf_ip_addr                    IPV4]
#        [-intf_ip_addr_step               IPV4
#                                          DEFAULT 0.0.0.1]
#        [-intf_prefix_len                 RANGE 1-32
#                                          DEFAULT 24]
#        [-ip_router_alert                 CHOICES 0 1
#                                          DEFAULT 1]
#x       [-mac_address_init                MAC]
#x       [-mac_address_step                MAC
#x                                         DEFAULT 0000.0000.0001]
#n       [-max_groups_per_pkts             ANY]
#        [-max_response_control            CHOICES 0 1
#                                          DEFAULT 0]
#        [-max_response_time               NUMERIC]
#n       [-max_sources_per_group           ANY]
#        [-msg_count_per_interval          NUMERIC
#                                          DEFAULT 0]
#        [-msg_interval                    NUMERIC
#                                          DEFAULT 0]
#        [-neighbor_intf_ip_addr           IPV4]
#        [-neighbor_intf_ip_addr_step      IPV4
#                                          DEFAULT 0.0.0.0]
#n       [-no_write                        ANY]
#x       [-override_existence_check        CHOICES 0 1
#x                                         DEFAULT 0]
#x       [-override_tracking               CHOICES 0 1
#x                                         DEFAULT 0]
#        [-port_handle                     REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
#x       [-reset                           FLAG]
#n       [-suppress_report                 ANY]
#        [-unsolicited_report_interval     NUMERIC
#                                          DEFAULT 120]
#n       [-vci                             ANY]
#n       [-vci_step                        ANY]
#x       [-vlan                            CHOICES 0 1
#x                                         DEFAULT 0]
#        [-vlan_id                         RANGE 0-4095
#                                          DEFAULT 1]
#        [-vlan_id_mode                    CHOICES fixed increment
#                                          DEFAULT increment]
#        [-vlan_id_step                    RANGE 0-4096
#                                          DEFAULT 1]
#        [-vlan_user_priority              RANGE 0-7
#                                          DEFAULT 0]
#n       [-vpi                             ANY]
#n       [-vpi_step                        ANY]
#n       [-older_version_timeout           ANY]
#n       [-robustness                      ANY]
#n       [-vlan_cfi                        ANY]
#x       [-unsolicited_response_mode       CHOICES 0 1
#x                                         DEFAULT 0]
#x       [-join_leave_multiplier           NUMERIC
#x                                         DEFAULT 1]
#n       [-no_of_reports_per_second        ANY]
#x       [-name                            ALPHA]
#x       [-enable_iptv                     ANY]
#x       [-iptv_name                       ALPHA]
#x       [-stb_leave_join_delay            NUMERIC]
#x       [-join_latency_threshold          NUMERIC]
#x       [-leave_latency_threshold         NUMERIC]
#x       [-zap_behavior                    CHOICES zaponly zapandview onetime]
#x       [-zap_direction                   CHOICES up down random]
#x       [-zap_interval_type               CHOICES leavetoleave multicasttoleave]
#x       [-zap_interval                    NUMERIC]
#x       [-num_channel_changes_before_view NUMERIC]
#x       [-view_duration                   NUMERIC]
#x       [-log_failure_timestamps          CHOICES 0 1]
#
# Arguments:
#    -handle
#        IGMP Host handle if the option -mode is delete, modify, disable,
#        enable.
#x   -protocol_name
#x       Name of the igmp protocol as it should appear in the IxNetwork GUI
#    -mode
#        This option defines the action to be taken.
#x   -return_detailed_handles
#x       This argument determines if individual interface, session or router handles are returned by the current command.
#x       This applies only to the command on which it is specified.
#x       Setting this to 0 means that only NGPF-specific protocol stack handles will be returned. This will significantly
#x       decrease the size of command results and speed up script execution.
#x       The default is 0, meaning only protocol stack handles will be returned.
#n   -atm_encapsulation
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -count
#        Defines the number of sessions to create on the interface. Valid for
#        mode create.
#n   -enable_packing
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -filter_mode
#        Cofigure IGMPv3 Include Filter Mode. Valid for mode create and modify. The
#        modification will be applied on all groups configured on the IGMP host.
#    -general_query
#        If true (1), respond to general queries received on the interface. Valid for
#        mode create and modify.
#    -global_settings_enable
#        Enables the Global Settings for Igmp Host.
#    -group_query
#        If true (1), respond to group specific queries
#        received on the interface. Valid for mode create and modify.
#    -igmp_version
#        The version of IGMP to be used: v1, v2, v3. Valid for mode create.
#    -inter_stb_start_delay
#        Time in milliseconds between Join messages from clients within the same range.
#x   -interface_handle
#x       <p> A handle or list of the handles that are returned from the
#x       interface_config call. These provide a direct link to an already
#x       existing interface and supercede the use of the intf_ip_addr value. </p>
#x       <p> Starting with IxNetwork 5.50 this parameter accepts handles returned by
#x       pppox_config procedure in the following format:
#x       &lt;PPPoX Range Handle&gt;|&lt;interface index X&gt;,&lt;interface index Y&gt;-&lt;interface index Z&gt;, ...
#x       The PPPoX ranges are separated from the Interface Index identifiers with the (|) character.
#x       The Interface Index identifiers are separated with comas (,).
#x       A range of Interface Index identifiers can be defined using the dash (-) character. </p>
#x       <p>Ranges along with the Interface Index identifiers are grouped together in TCL Lists. The
#x       lists can contain mixed items, protocol interface handles returned by interface_config
#x       and handles returned by pppox_config along with the interface index. </p>
#x       <p>Example:
#x       count 10 (10 IGMP routers). 3 pppox range handles returned by ::ixia::pppox_config.
#x       Each pppox range has 20 sessions (interfaces). If we pass interface_handle
#x       in the following format: [list $pppox_r1|1,5 $pppox_r2|1-3 $pppox_r3|1,3,5-9,13]
#x       The interfaces will be distributed to the routers in the following manner:</p>
#x       <p>
#x       <ul>
#x       <li> IGMP Router 1: $pppox_r1 -&gt; interface 1 </li>
#x       <li> IGMP Router 2: $pppox_r1 -&gt; interface 5 </li>
#x       <li> IGMP Router 3: $pppox_r2 -&gt; interface 1 </li>
#x       <li> IGMP Router 4: $pppox_r2 -&gt; interface 2 </li>
#x       <li> IGMP Router 5: $pppox_r2 -&gt; interface 3 </li>
#x       <li> IGMP Router 6: $pppox_r3 -&gt; interface 1 </li>
#x       <li> IGMP Router 7: $pppox_r3 -&gt; interface 3 </li>
#x       <li> IGMP Router 8: $pppox_r3 -&gt; interface 5 </li>
#x       <li> IGMP Router 9: $pppox_r3 -&gt; interface 6 </li>
#x       <li> IGMP Router 10: $pppox_r3 -&gt; interface 7 </li>
#x       <li> IGMP Router 11: $pppox_r3 -&gt; interface 8 </li>
#x       <li> IGMP Router 12: $pppox_r3 -&gt; interface 9 </li>
#x       <li> IGMP Router 13 $pppox_r3 -&gt; interface 13 </li>
#x       </ul>
#x       </p>
#x       <p> Valid for mode create. </p>
#    -intf_ip_addr
#        IP address of the test interface / emulated IGMP Host. Valid for mode create.
#    -intf_ip_addr_step
#        The IP address step between each session. Valid for mode create.
#    -intf_prefix_len
#        The netmask length value for the interface. Valid for mode create.
#    -ip_router_alert
#        If true (1), enable IP Router Alert Option. Valid for mode create and modify.
#x   -mac_address_init
#x       The MAC address for the interface to be created. Valid for mode create.
#x   -mac_address_step
#x       The incrementing step for the MAC address of the interface to be
#x       created. Valid only when using IxNetwork Tcl API. Valid for mode create.
#n   -max_groups_per_pkts
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -max_response_control
#        If true (1), use -max_response_time to overwrite the value obtained
#        from the received Query message. Valid for mode create and modify.
#    -max_response_time
#        Set the maximum response time (in 1/10 seconds) on receipt of a query.
#        If set to 0, immediately respond to received Query message.Valid
#        for mode create and modify.
#n   -max_sources_per_group
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -msg_count_per_interval
#        The number of multicast IGMP groups to be advertised during each time period.
#        A value of 0 disables this feature and transmits all groups
#        immediately for all updates. Valid for mode create and modify.
#    -msg_interval
#        The interval in seconds used for throttling updates. A value of 0 will
#        cause sending the messages as fast as possible. Valid for mode create and modify.
#    -neighbor_intf_ip_addr
#        IP address of the neighbor. Valid for mode create.
#    -neighbor_intf_ip_addr_step
#        The IP address step between each session. Valid for mode create.
#n   -no_write
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -override_existence_check
#x       If this option is enabled, the interface existence check is skipped but
#x       the list of interfaces is still created and maintained in order to keep
#x       track of existing interfaces, if required. Using this option will speed
#x       up the creation of interfaces. Valid for mode create.
#x   -override_tracking
#x       If this option is enabled, the list of interfaces will not be created and
#x       maintained anymore, thus speeding up the creation of interfaces even
#x       more. Also, it will enable -override_existence_check in case it was not
#x       already enabled, because checking for interface existence becomes
#x       impossible if the the list of interfaces doesn?t exist anymore. Valid for mode create.
#    -port_handle
#        The port on which the session is to be created. Valid for mode create.
#x   -reset
#x       Clear all existent hosts. Valid for mode create.
#n   -suppress_report
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -unsolicited_report_interval
#        The interval (in seconds) to wait before re-sending the host's
#        initial report of membership in a group. If 0, do not send unsolicited
#        report.
#n   -vci
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vci_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -vlan
#x       Enables vlan on the directly connected IGMP router interface.
#x       Valid options are: 0 - disable, 1 - enable.
#x       This option is valid only when -mode is create or -mode is modify
#x       and -handle is an IGMP router handle.
#x       This option is available only when IxNetwork tcl API is used.
#    -vlan_id
#        VLAN ID for emulated router node. Valid for mode create.
#    -vlan_id_mode
#        For multiple neighbor configuration, configures the VLAN ID mode to
#        fixed or increment. Valid for mode create.
#    -vlan_id_step
#        <p> When -vlan_id_mode is set to increment, this defines the step for
#        every VLAN. Valid for mode create. </p>
#        <p> When vlan_id_step causes the vlan_id value to exceed it's maximum value the
#        increment will be done modulo <number of possible vlan ids>. </p>
#        <p> Examples:</p>
#        <ul>
#        <li> vlan_id = 4094; vlan_id_step = 2-> new vlan_id value = 0 </li>
#        <li> vlan_id = 4095; vlan_id_step = 11 -> new vlan_id value = 10 </li>
#        </ul>
#    -vlan_user_priority
#        VLAN user priority assigned to emulated router node. Valid for mode create.
#n   -vpi
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vpi_step
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -older_version_timeout
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -robustness
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -vlan_cfi
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -unsolicited_response_mode
#x       If selected, the emulated IGMP host automatically sends full membership messages at regular intervals, without waiting for a query message.
#x   -join_leave_multiplier
#x       No. of Join/Leave messages to send per operation
#n   -no_of_reports_per_second
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -name
#x       DEPRECATED: use protocol_name instead
#x   -enable_iptv
#x       Enable IPTV
#x   -iptv_name
#x       Name of NGPF element, guaranteed to be unique in Scenario
#x   -stb_leave_join_delay
#x       Time in milliseconds between sending a Leave for the current channel and Join for the next channel.
#x   -join_latency_threshold
#x       The maximum time that is allowed for a multicast stream to arrive for channel for which a Join has been sent.
#x   -leave_latency_threshold
#x       The maximum time allowed for a multicast stream to stop for a channel for which a Leave has been sent.
#x   -zap_behavior
#x       Use Zap Only to change channels without viewing the channel or Zap and View to change traffic and receive traffic for the last channel.
#x   -zap_direction
#x       Specifies the direction of changing channels.
#x   -zap_interval_type
#x       Specifies the wait interval type before changing the channels.
#x   -zap_interval
#x       Interval in milliseconds between channel changes based on the selected type.
#x   -num_channel_changes_before_view
#x       Number of channels to change before stopping on a channel and watching it for View Duration.
#x   -view_duration
#x       Specifies the time in milliseconds to view the last channel.
#x   -log_failure_timestamps
#x       If enabled, the timestamps for Join and Leave failures are saved to a log file.
#
# Return Values:
#    A list containing the igmp host protocol stack handles that were added by the command (if any).
#x   key:igmp_host_handle       value:A list containing the igmp host protocol stack handles that were added by the command (if any).
#    A list containing the ethernet protocol stack handles that were added by the command (if any).
#x   key:ethernet_handle        value:A list containing the ethernet protocol stack handles that were added by the command (if any).
#    A list containing the ipv4 protocol stack handles that were added by the command (if any).
#x   key:ipv4_handle            value:A list containing the ipv4 protocol stack handles that were added by the command (if any).
#    A list containing the pppox client protocol stack handles that were added by the command (if any).
#x   key:pppox_client_handle    value:A list containing the pppox client protocol stack handles that were added by the command (if any).
#    A list containing the pppox server protocol stack handles that were added by the command (if any).
#x   key:pppox_server_handle    value:A list containing the pppox server protocol stack handles that were added by the command (if any).
#    A list containing the igmp host iptv protocol stack handles that were added by the command (if any).
#x   key:igmp_host_iptv_handle  value:A list containing the igmp host iptv protocol stack handles that were added by the command (if any).
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:interface_handle       value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#x   key:iptv_handles           value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    $::SUCCESS | $::FAILURE
#    key:status                 value:$::SUCCESS | $::FAILURE
#    The handles for the IGMP Hosts created. Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    key:handle                 value:The handles for the IGMP Hosts created. Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
#    If status is failure, detailed information provided.
#    key:log                    value:If status is failure, detailed information provided.
#
# Examples:
#    See files starting with IGMPv1_, IGMPv2_, or IGMPv3_ in the Samples subdirectory. See the IGMP example in Appendix A, "Examples APIs," for one specific example usage.
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  handle, interface_handle, iptv_handles
#
# See Also:
#

package ixiangpf;

use utils;
use ixiahlt;

sub emulation_igmp_config {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('emulation_igmp_config', $args);
	# ixiahlt::utrackerLog ('emulation_igmp_config', $args);

	return ixiangpf::runExecuteCommand('emulation_igmp_config', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
