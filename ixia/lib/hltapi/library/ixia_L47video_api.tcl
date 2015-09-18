##Library Header
# $Id: $
# Copyright © 2003-2007 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_L47video_api.tcl
#
# Purpose: Implement Video IPTV IxLoad capabilities in HLTAPI
#
# Author: Mircea Hasegan
#
# Usage:
#
# Description:
#      The HLT video API consists of a client agent, a server agent, and their 
#      commands.
#     
#     IPTV
#     The IPTV client and server API structure is similar to the video API 
#     structure with some additions.
#     
#     IPTV Mode Server and Client
#     The HLT Video client and server can operate in either of two modes:
#     •    Video to emulate a standard multicast/unicast video client and server.
#     •    IPTV to emulate an IPTV client and server.
#     
#     Video Server
#     In the IPTV mode, the HLT video server can be configured to emulate two 
#     types of IPTV servers: a combination A/D Server or a V server.
#     *    In an actual IPTV implementation an A (Acquisition) server packages RTP 
#         streams into multicast UDP packets and streams them onto the 
#         distribution network.
#     *    A D (Distribution) server caches a certain amount of the multicast 
#         video data being streamed over the network. When a user changes a 
#         channel, the D server sends a short unicast burst of the new channel’s 
#         video traffic for the user to view while the system switches the user 
#         from the previous channel’s multicast group to the new channel’s group.
#     *    A V server provides Video-on-Demand service to an IPTV client.
#     
#     Video Client
#     In IPTV mode, the HLT video client emulates an IPTV client. In IPTV mode, 
#     all the same commands are available as in Video mode, except that the 
#     Join command is replaced with the ICCCommand for testing multicast 
#     performance.
#
# Requirements:
#
# Variables:
#
# Keywords:
#
# Category:
#
################################################################################
#                                                                              #
#                                LEGAL  NOTICE:                                #
#                                ==============                                #
# The following code and documentation (hereinafter "the script") is an        #
# example script for demonstration purposes only.                              #
# The script is not a standard commercial product offered by Ixia and have     #
# been developed and is being provided for use only as indicated herein. The   #
# script [and all modifications, enhancements and updates thereto (whether     #
# made by Ixia and/or by the user and/or by a third party)] shall at all times #
# remain the property of Ixia.                                                 #
#                                                                              #
# Ixia does not warrant (i) that the functions contained in the script will    #
# meet the user's requirements or (ii) that the script will be without         #
# omissions or error-free.                                                     #
# THE SCRIPT IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, AND IXIA        #
# DISCLAIMS ALL WARRANTIES, EXPRESS, IMPLIED, STATUTORY OR OTHERWISE,          #
# INCLUDING BUT NOT LIMITED TO ANY WARRANTY OF MERCHANTABILITY AND FITNESS FOR #
# A PARTICULAR PURPOSE OR OF NON-INFRINGEMENT.                                 #
# THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SCRIPT  IS WITH THE #
# USER.                                                                        #
# IN NO EVENT SHALL IXIA BE LIABLE FOR ANY DAMAGES RESULTING FROM OR ARISING   #
# OUT OF THE USE OF, OR THE INABILITY TO USE THE SCRIPT OR ANY PART THEREOF,   #
# INCLUDING BUT NOT LIMITED TO ANY LOST PROFITS, LOST BUSINESS, LOST OR        #
# DAMAGED DATA OR SOFTWARE OR ANY INDIRECT, INCIDENTAL, PUNITIVE OR            #
# CONSEQUENTIAL DAMAGES, EVEN IF IXIA HAS BEEN ADVISED OF THE POSSIBILITY OF   #
# SUCH DAMAGES IN ADVANCE.                                                     #
# Ixia will not be required to provide any software maintenance or support     #
# services of any kind (e.g., any error corrections) in connection with the    #
# script or any part thereof. The user acknowledges that although Ixia may     #
# from time to time and in its sole discretion provide maintenance or support  #
# services for the script, any such services are subject to the warranty and   #
# damages limitations set forth herein and will not obligate Ixia to provide   #
# any additional maintenance or support services.                              #
#                                                                              #
################################################################################
## Internal Procedure Header
# Name:
#    ::ixia::L47_video_client
#
# Description:
#     The ::ixia::L47_video_client procedure can create the following type of 
#     objects:
#     *    Traffic client and video client agent when –property parameter is 
#         "client". The traffic client can be extracted from the keyed list using 
#         the key "client_handle". The video client agent can be extracted from 
#         the keyed list using the key "agent_handle".
#     *    Video client agent when –property parameter is "agent" and –handle 
#         parameter has the value of a traffic client handle.
#     *    profile_table object when –property parameter is "profile_table" 
#         and –handle parameter has the value of a video client agent handle. 
#         The profile_table handle can be extracted from the keyed list using 
#         the key "profile_table_handle".
#     *    Commands object when –property parameter is "commands" and the 
#         –handle parameter has the value of a video client agent. The 
#         commands handle can be extracted from the keyed list using the 
#         key "commands_handle".
#     *    channelviewTable object when –property parameter is 
#         "channelviewTable" and –handle parameter has the value of a commands 
#         handle. The channelviewTable object handle can be extracted from the 
#         keyed list using the key "channelviewTable_handle".
#     *    Rule object  when –property parameter is "rule" and –handle parameter 
#         has the value of a commands object handle. The rule object can be 
#         extracted from the keyed list using the key "rule_handle".
#
# Synopsis:
#    ::ixia::L47_video_client
#         -mode                             CHOICES add remove modify enable 
#                                           disable
#         [-bitrate_limit                   RANGE 0-2147483647]
#         [-channel_switch_delay_max        RANGE 0-100000000]
#         [-channel_switch_delay_min        RANGE 0-100000000]
#         [-channel_switch_mode             CHOICES sequential
#                                           CHOICES    random
#                                           CHOICES    poisson
#                                           CHOICES    normal
#                                           CHOICES    unique
#                                           CHOICES    custom]
#         [-client_mode                     CHOICES 0
#                                           CHOICES    1]
#         [-clock_rate                      RANGE 0-2147483647]
#         [-codec                           CHOICES h264
#                                           CHOICES    mpeg4
#                                           CHOICES    vc1
#                                           CHOICES    ts
#                                           CHOICES    mpeg4aac
#                                           CHOICES    mpeg4ldaac]
#         [-commands_id                     CHOICES    ICCCommand
#                                           CHOICES    KeepAliveCommand
#                                           CHOICES    JoinCommand
#                                           CHOICES    DescribeCommand
#                                           CHOICES    RTSPSetupCommand
#                                           CHOICES    RTSPPlayCommand
#                                           CHOICES    RTSPPauseCommand
#                                           CHOICES    RTSPSetParamCommand
#                                           CHOICES    RTSPGetParamCommand
#                                           CHOICES    RTSPTeardownCommand
#                                           CHOICES    PlayCommand
#                                           CHOICES    PlayStaticCommand
#                                           CHOICES    PlayMediaCommand
#                                           CHOICES    PauseCommand
#                                           CHOICES    ResumeCommand
#                                           CHOICES    SeekCommand
#                                           CHOICES    StopCommand
#                                           CHOICES    ThinkCommand
#                                           CHOICES    LoopBeginCommand
#                                           CHOICES    LoopEndCommand
#                                           CHOICES    PassiveCommand]
#         [-concurrent_channels             RANGE 1-1]
#         [-content                         ANY]
#         [-content_type                    ANY]
#         [-count                           RANGE 1-1000000]
#         [-custom_setup                    ANY]
#         [-da_switchover_delay             RANGE 1-2147483]
#         [-destination_server_activity     ANY]
#         [-duration                        RANGE 1-2147483]
#         [-duration_max                    RANGE 1-2147483]
#         [-duration_min                    RANGE 1-2147483]
#         [-enable_custom                   CHOICES 0 1]
#         [-enable_custom_setup             CHOICES 0 1]
#         [-enable_esm                      CHOICES 0 1]
#         [-enable_frame_stats              CHOICES 0 1]
#         [-enable_tos_rtsp                 CHOICES 0 1]
#         [-enable_unicast                  CHOICES 0
#                                           CHOICES    1]
#         [-enable_vlan_priority            CHOICES 0 1]
#         [-enable_vqmon_stats              CHOICES 0 1]
#         [-esm                             RANGE 64-1460]
#         [-follow_rtsp_redirect            CHOICES 0 1]
#         [-general_query_response_mode     CHOICES 0 1]
#         [-group_address_count             RANGE 1-1000]
#         [-group_address_step              ANY]
#         [-group_specific_query_response_mode    CHOICES 0 1]
#         [-handle                          ANY]
#         [-icc_channel_switch_delay_max    RANGE 0-100000000]
#         [-icc_channel_switch_delay_min    RANGE 0-100000000]
#         [-icc_duration_max                RANGE 30-2147483]
#         [-icc_duration_min                RANGE 30-2147483]
#         [-igmp_version                    CHOICES     igmpv1
#                                           CHOICES    igmpv2
#                                           CHOICES    igmpv3
#         [-ignore_loss                     CHOICES 0 1]
#         [-immediate_response              CHOICES 0 1]
#         [-ip_version                      CHOICES ipv4
#                                           CHOICES    ipv6
#         [-iptv_switch_delay               RANGE 1-60]
#         [-iptv_switch_mode                CHOICES 0
#                                           CHOICES    1
#                                           CHOICES    2]
#         [-jbemode                         CHOICES 0
#                                           CHOICES    1
#                                           CHOICES    2]
#         [-jc_channel_switch_delay_max     RANGE 0-100000000]
#         [-jc_channel_switch_delay_min     RANGE 0-100000000]
#         [-jc_channel_switch_mode      CHOICES sequential
#                                           CHOICES    random
#                                           CHOICES    concurrent
#                                           CHOICES    poisson
#                                           CHOICES    normal
#                                           CHOICES    unique
#                                           CHOICES    custom]
#         [-jc_concurrent_channels          RANGE 1-4]
#         [-loop_count                      RANGE 0-2147483647]
#         [-max_delay                       RANGE 1-100000]
#         [-max_freq                        RANGE 1000-10000000]
#         [-maximum_interval                RANGE 1000-2147483647]
#         [-media                           ANY]
#         [-min_delay                       RANGE 1-100000]
#         [-min_freq                        RANGE 1000-10000000]
#         [-minimum_interval                RANGE 1000-2147483647]
#         [-mld_version                     CHOICES v1
#                                           CHOICES    v2]
#         [-mu                              RANGE 1-2147483]
#         [-nom_delay                       RANGE 1-100000]
#         [-num_profiles                    RANGE 1-1000]
#         [-pc_duration                     RANGE 1-2147483]
#         [-percentage                      RANGE 0-100]
#         [-property                        CHOICES     client
#                                           CHOICES    agent
#                                           CHOICES    profile_table
#                                           CHOICES    commands
#                                           CHOICES    channelviewTable
#                                           CHOICES    rule]
#         [-psc_duration                    RANGE 1-2147483]
#         [-rc_duration                     RANGE 1-2147483]
#         [-report_frequency                RANGE 30-2147483]
#         [-rtp_pt                          RANGE 1-127]
#         [-rtsp_duration                   RANGE 0-2147483]
#         [-rtsp_header                     CHOICES windows_media_player
#                                           CHOICES    real_player
#                                           CHOICES    quick_time
#                                           CHOICES    custom]
#         [-rtsp_proxy_enable               CHOICES 0 1]
#         [-rtsp_proxy_ip                   ANY]
#         [-rtsp_proxy_port                 ANY]
#         [-rule_value                      ANY]
#         [-server_ip                       ANY]
#         [-sigma                           RANGE 1-2147483]
#         [-source_address                  ANY]
#         [-start_group_address             ANY]
#         [-suppress_reports                CHOICES 0 1]
#         [-sym_server_ip                   ANY]
#         [-transport                       CHOICES 1
#                                           CHOICES    0]
#         [-type_of_service_for_rtsp        ANY]
#         [-unsolicited_response_mode       CHOICES 0 1]
#         [-update_interval                 RANGE 2000-100000]
#         [-urls                            ANY]
#         [-var_lambda                      RANGE 1-2147483]
#         [-view_sequence                   ANY]
#         [-watch_count                     RANGE 0-2147483]
#
# Arguments:
#    -mode
#       Defines types of actions to be taken on the –property object.
#       Choices:
#           * add – can be used with –property client | agent | rulesTable | 
#                   audioClipsTable | scenarios 
#           * remove – can be used with –property client | agent | rulesTable | 
#                   audioClipsTable | scenarios 
#           * enable – can be used with –property agent 
#           * disable –can be used with –property agent
#           * modify – can be used with –property client | agent | rulesTable | 
#                       audioClipsTable | scenarios
#       (DEFAULT = N/A)
#    -bitrate_limit
#       The video_bitrate limit in Kbps.
#        Type: optional
#       (DEFAULT = 0)
#        Dependencies: -property agent
#    -channel_switch_delay_max
#       Maximum length of time, in milliseconds, that users of this profile will 
#       pause before viewing a new channel (requesting a new file).
#        Type: optional
#       (DEFAULT = 1000)
#        Dependencies: -property profile_table
#    -channel_switch_delay_min
#       Minimum length of time, in milliseconds, that users of this profile 
#       will pause before viewing a new channel (requesting a new file).
#        Type: optional
#       (DEFAULT = 1000)
#        Dependencies: -property profile_table
#    -channel_switch_mode
#       Specifies the order in which the client joins the multicast groups 
#       in the Channel List to view the channels.
#       •    sequential: The client plays the channels in the Channel List one 
#       after the other, in order based on their address, starting with the 
#       start_group_address. After the Channel Watch Duration expires, the 
#       client sends an IGMP LEAVE for the channel being viewed. The client 
#       waits for the duration specified by Channel Switch Delay duration before 
#       joining the next group to view the next channel.
#       •    poisson: The client plays the channel in an order that follows 
#       a Poisson distribution. Configure the watch_count, then set the var_lambda 
#       value for the Poisson distribution.
#       •    normal: The client plays the channel in an order that follows 
#       a Normal distribution. Configure the watch_count, then set the mu and sigma 
#       values for the Normal distribution.
#       •    unique: Each user starts from a different channel, and plays 
#       each channel in numerical order. There are no configuration options for a 
#       Unique sequence. The number of channels played is automatically set to the 
#       same value as the Count parameter.
#       •    custom: The client plays the channels following an existing 
#       profile, but in a sequence that you specify.
#        Type: optional
#       (DEFAULT = sequential)
#        Dependencies: -property commands; -commands_id ICCCommand
#    -client_mode
#       Specifies whether it is a Video client (0) or IPTV client (1).
#        Type: optional
#       (DEFAULT = 0)
#        Dependencies: -property agent
#    -clock_rate
#       Specifies the stream’s bit rate.
#        Type: optional
#       (DEFAULT = 90000)
#        Dependencies: -property rule
#    -codec
#       Indicates the codec used on the stream.
#        Type: optional
#       (DEFAULT = h264)
#        Dependencies: -property rule
#    -commands_id
#       Establishes what type of command will be added when –property is commands
#        Type: optional
#       (DEFAULT = N/A)
#        Dependencies: -property commands
#    -concurrent_channels
#       Specifies the number of channels that each client plays at one time. 
#       You can specify up to 1 channels to play at one time.
#        Type: optional
#       (DEFAULT = 1)
#        Dependencies: -property commands; -commands_id ICCCommand
#    -content
#       Specifies the value of the content.
#        Type: optional
#       (DEFAULT = "")
#        Dependencies: -property commands; -commands_id RTSPSetParamCommand | 
#       RTSPGetParamCommand
#    -content_type
#       Specifies the parameter of the content.
#        Type: optional
#       (DEFAULT = N/A)
#        Dependencies: -property commands; -commands_id RTSPSetParamCommand | 
#       RTSPGetParamCommand
#    -count
#       Number of {KeepAlive} messages to be sent.
#        Type: optional
#       (DEFAULT = 1)
#        Dependencies: -property commands; -commands_id KeepAliveCommand
#    -custom_setup
#       If enable_custom_setup_transport_param is 0, then the Transport: line 
#       contains the following data, which is mandatory for RTSP:
#       •    Transport protocol, connection type (unicast or multicast), and 
#       client IP port range used for the transport protocol. For example:
#       o    RTP/AVP;unicast;client_port=35246-35247
#       If enable_custom_setup_transport_param is 1, then HLT appends a semicolon
#       •    (;) to the mandatory data on Transport: line, and then appends the 
#       custom data in the field.
#       o    For example, if you specify the string mode=PLAY, the Transport: 
#       line will contain the following string: RTP/AVP;unicast;
#       client_port=35246-35247;mode=PLAY
#        Type: optional
#       (DEFAULT = mode_play)
#        Dependencies: -mode agent
#    -da_switchover_delay
#       If you want the client to pause before switching to the next channel, 
#       specify the length of the delay here. You can specify a fixed-length delay 
#       (same delay before playing every channel) or a random-length delay (different 
#       delay before playing every channel).
#        Type: optional
#       (DEFAULT = 1)
#        Dependencies: -property commands; -commands_id ICCCommand
#    -destination_server_activity
#       Handle of the video or iptv server agent.
#        Type: optional
#       (DEFAULT = "none")
#        Dependencies: -property commands; -commands_id JoinCommand
#    -duration
#       Length of time (in seconds) to play the video stream.
#        Type: optional
#       (DEFAULT = 10)
#        Dependencies: -property commands; -commands_id SeekCommand
#    -duration_max
#       Maximum length of time, in seconds, that the client will play the 
#       channel for. (if –property is commands).
#       Maximum length of time, in seconds, that users of this profile will 
#       view a channel (play a file). (if –property is profile_table)
#        Type: optional
#       (DEFAULT = 10)
#        Dependencies: -property commands –commands_id JoinCommand OR –property 
#       profile_table
#    -duration_min
#       Minimum length of time, in seconds, that the client will play the 
#       channel for. (if –property is commands)
#       Minimum length of time, in seconds, that users of this profile will 
#       view a channel (if –property is profile_table)
#        Type: optional
#       (DEFAULT = 10)
#        Dependencies: -property commands –commands_id JoinCommand OR –property 
#       profile_table
#    -enable_custom
#       If enabled, the custom client profiles that have been configured will 
#       be used in a test. The duration and channel_switch_mode configured for 
#       individual JOIN commands (Arguments for -commands_ id  JoinCommand ) will 
#       not apply.
#        Type: optional
#       (DEFAULT = 0)
#        Dependencies: -property agent
#    -enable_custom_setup
#       This enables or disables the entry of parameters specified in the 
#       Transport: line of the RTSP SETUP message. You can use these parameters to 
#       set or enable additional RTSP transport options on the server.
#        Type: optional
#       (DEFAULT = 0)
#        Dependencies: -property agent
#    -enable_esm
#       If true, the use of the esm option is enabled.
#        Type: optional
#       (DEFAULT = 0)
#        Dependencies: -property 0
#    -enable_frame_stats
#       If enabled, HLT generates per-frame statistics for the I-, P-, 
#       and B-frames in the video streams received by the client.
#       Frame Statistics cannot be collected for the following streams:
#       •    Synthetic streams
#       •    MPEG-2 TS streams carrying H.264 or MPEG4 video
#        Type: optional
#       (DEFAULT = 0)
#        Notes: enable_frame_stats can be enabled only if enable_vqmon_stats 
#       option is true.
#        Dependencies: -property agent
#    -enable_tos_rtsp
#       Enables the setting of the TOS (Type of Service) bits in the IP header 
#       of the RTSP packets.
#       •    0 (default) TOS bits not enabled.
#       •    1 TOS bits enabled.
#        Type: optional
#       (DEFAULT = 0)
#        Dependencies: -property agent
#    -enable_unicast
#       Enables an Unicast or Multicast stream that can be monitored. 
#       (Default = "0"). If you enter 1 that is Unicast, then a new rule object needs 
#       to be configured (using –property rule).
#        Type: optional
#       (DEFAULT = 0)
#        Dependencies: -property commands –commands_id PassiveCommand
#    -enable_vlan_priority
#       VLAN Priority can be set on a per-agent basis or on a per-network 
#       (traffic client) basis. This parameter sets the VLAN priority for the agent. 
#       An agent’s VLAN Priority bit setting takes precedence over a network’s 
#       Priority bit setting.
#       If 1, HLT sets the VLAN Priority bit in traffic from this activity. 
#       Configure the VLAN priority value in vlan_priority.
#        Type: optional
#       (DEFAULT = 0)
#        Dependencies: -property agent
#    -enable_vqmon_stats
#       If enabled, HLT applies the values in the Quality Metrics fields to 
#       the video streams received by the client and computes the Quality Metrics 
#       statistics.
#        Type: optional
#       (DEFAULT = 0)
#        Dependencies: -property agent
#    -esm
#       If enable_esm is 1, this option specifies the TCP Maximum Segment 
#       Size in the MSS (TX) field. Otherwise, the TCP Maximum Segment Size is 
#       1,460 bytes.
#        Type: optional
#       (DEFAULT = 1460)
#        Dependencies: -property agent
#    -follow_rtsp_redirect
#       If enabled, the client follows RTSP redirect responses from the server.
#        Type: optional
#       (DEFAULT = 0)
#        Dependencies: -property agent
#    -general_query_response_mode
#       If 1, the video client responds to General Query messages.
#       •    0 Client does not respond to General Query messages.
#       •    1 (default) Client responds to General Query messages.
#        Type: optional
#       (DEFAULT = 1)
#        Dependencies: -property agent
#    -group_address_count
#       Specifies the number of additional channels, if you want the client to 
#       play more than one channel (stream) (when commands_id is ICCCommand).
#       Number of multicast groups that the client will join. 
#       (when –commands_id is JoinCommand)
#        Type: optional
#       (DEFAULT = 1)
#        Dependencies: -property commands –commands_id  ICCCommand | JoinCommand
#    -group_address_step
#       Specifies the amount of increase in the channel number (A server 
#       address). See the description of the group_address_count for more information 
#       (when commands_id is ICCommand).
#       If the client will join more than one multicast group, enter the 
#       amount of increase in the multicast group address. (when commands_id is 
#       JoinCommand
#        Type: optional
#       (DEFAULT = 0.0.0.1)
#        Dependencies: -property commands –commands_id ICCCommand | JoinCommand
#    -group_specific_query_response_mode
#       If enabled, the client responds to group-specific Query messages. 
#       A group-specific Query message is sent by a multicast router so it can learn 
#       about the multicast reception state of one multicast address, for each of 
#       the neighboring interfaces, for example, when a member leaves a group.
#        Type: optional
#       (DEFAULT = 1)
#        Dependencies: -property agent
#    -handle
#       When –mode is create:
#       •    video client handle if -property agent
#       •    agent handle if -property profile_table | commands
#       •    commands handle if –property channelviewTable | rule
#       When –mode is modify | remove | enable | disable the –handle parameter 
#       must be of the same type as the –property parameter value.
#        Type: optional
#       (DEFAULT = N/A)
#        Dependencies: N/A
#    -icc_channel_switch_delay_max
#       If you want the client to pause before switching to the next channel, 
#       specify themaximum length of the delay here.
#        Type: optional
#       (DEFAULT = 30)
#        Dependencies: -property commands -commands_id ICCCommand
#    -icc_channel_switch_delay_min
#       If you want the client to pause before switching to the next channel, 
#       specify the minimum length of the delay here.
#        Type: optional
#       (DEFAULT = 30)
#        Dependencies: -property commands -commands_id ICCCommand
#    -igmp_version
#       Sets the version of IGMP used by the client. The choices are:
#       •    "igmpv1" IGMP version 1.
#       •    "igmpv2" IGMP version 2.
#       •    "igmpv3" (default) IGMP version 3.
#        Type: optional
#       (DEFAULT = igmpv3)
#        Notes: for "igmpv1" you have to select IPv4 under ip_version option
#        Dependencies: -property agent
#    -ignore_loss
#       If enabled, HLT does not count the number of packets lost, and therefore 
#       does not consider the effect of lost packets on the quality of the video.
#        Type: optional
#       (DEFAULT = 0)
#        Dependencies: -property agent
#    -immediate_response
#       If 1, the video client will ignore the value specified in the Maximum Response
#       Delay in the Membership Query message, assume that the Delay is always zero
#    (0) seconds, and immediately respond to the Query by sending a Report.
#       •    0 (default) Client does not immediately respond to a query with a report.
#       •    1 Client immediately responds to a query with a report.
#        Type: optional
#       (DEFAULT = 0)
#        Dependencies: -property agent
#    -ip_version
#       Sets the IP version used for multicast addresses. If multicast 
#       addresses are in IPv4 format you can select the igmp_version. If multicast 
#       addresses are in IPv6 format you can select the mld_version.
#        Type: optional
#       (DEFAULT = ipv4)
#        Dependencies: -property agent
#    -iptv_switch_delay
#       If iptv_switch_mode is "2" then specify the fixed length of time here.
#        Type: optional
#       (DEFAULT = 1)
#        Dependencies: -property agent
#    -iptv_switch_mode
#       Selects how the IPTV client switches from the D server stream to 
#       the A server
#       stream. The choices are:
#       •    "0" (Default) Stop Receiving D Server Stream When First A Server 
#       Packet Received
#       •    "1" Receive D Server Stream for its entire Duration
#       •    "2" Stop Receiving D Server Streams after Receving A Server for 
#       Certain Duration
#        Type: optional
#       (DEFAULT = 0)
#        Dependencies: -property agent
#    -jbemode
#       Mode that the emulated jitter buffer operates in. The values are:
#       •    "0" (Default) Fixed Mode
#       •    "1" Adaptive Mode
#       •    "2" Ignore Delay Mode
#        Type: optional
#       (DEFAULT = 0)
#        Dependencies: -property agent
#    -jc_channel_switch_delay_max
#       Maximum length of the time, in milliseconds, that the client will pause 
#       before playing the next channel on the server.
#        Type: optional
#       (DEFAULT = 0)
#        Dependencies: -property commands ;–commands_id JoinCommand
#    -jc_channel_switch_delay_min
#       Minimum length of the time, in milliseconds, that the client will 
#       pause before playing the next channel on the server.
#        Type: optional
#       (DEFAULT = 0)
#        Dependencies: -property commands ;–commands_id JoinCommand
#    -jc_channel_switch_mode
#       Order in which the client joins the multicast groups in the Channel List 
#       to play the channels. The choices are:
#       •    sequential The client plays the channels in the Channel List one 
#       after the other, in order based on their address, starting with the 
#       Starting Group Address. After the Channel Watch Duration expires, the 
#       client sends an IGMP LEAVE for the channel being watched. The client 
#       waits for the duration specified by Channel Switch Delay duration 
#       before joining the next group to play the next channel.
#       •    random The client plays the channels in the Channel List randomly.
#       •    concurrent (default) The client plays the channels in the Channel 
#       List in order, based on their address. Specify the number of channels 
#       that it can play at any one time in the Concurrent Channels field.
#       •    poisson The client plays the channel in an order that follows 
#       a Poisson distribution. For Poisson distribution, the jb_channel_switch_mode 
#       is set to "Poisson". New attributes used are: watch_count and var_lambda.
#       •    normal The client plays the channel in an order that follows a 
#       Normal distribution. For Normal distribution, the jb_channel_switch_mode 
#       is set to "normal" New attributes used are: mu, sigma and watch_count.
#       •    unique Each user starts from a different channel, and plays 
#       each channel in numerical order. There are no configuration options for a 
#       Unique sequence. The number of channels played is automatically set to the
#        same value as the Count parameter.
#       •    custom The client plays the channels following an existing 
#       profile, but in a sequence that you specify.
#        Type: optional
#       (DEFAULT = concurrent)
#        Dependencies: -property commands ;–commands_id JoinCommand
#    -jc_concurrent_channels
#       If jb_channel_switch_mode is set to Concurrent, this parameter 
#       specifies the number of channels that the client plays at one time.
#        Type: optional
#       (DEFAULT = 1)
#        Dependencies: -property commands ;–commands_id JoinCommand
#    -loop_count
#       Number of times to iterate. Value '0' treated as infinity.
#        Type: optional
#       (DEFAULT = 5)
#        Dependencies: -property commands ;–commands_id LoopBeginCommand
#    -max_delay
#       Defines the maximum number of packets the jitter buffer emulator 
#       can hold before it overflows, resulting in packets being discarded. 
#       Typically, the maximum delay should be at least twice the nominal delay.
#       This parameter is used by the following jbemode: Fixed, Adaptive
#        Type: optional
#       (DEFAULT = 80)
#        Dependencies: -property agent
#    -max_freq
#       The maximum time, in milliseconds, that can elapse before the 
#       client sends the next {KeepAlive} message.
#        Type: optional
#       (DEFAULT = 10000)
#        Dependencies: -property commands; -commands_id KeepAliveCommand
#    -maximum_interval
#       Maximum length of the time, in milliseconds, that the client will 
#       pause before playing the next channel on the server.
#        Type: optional
#       (DEFAULT = 1000)
#        Dependencies: -property commands; -commands_id ThinkCommand
#    -media
#       Video stream to be played. You can include sequence generators 
#       in this field to automatically generate unique requests from simulated users. 
#       When –commands_id is DescribeCommand:
#       The presentation URL sent to the server. The presentation URL 
#       identifies the stream to be controlled. Media names may only contain 
#       letters, numbers, and the special symbols ‘.’, ‘,’, ‘_’, ‘/’ and ‘-’.
#                    You can pass a video server stream_handle.
#        Type: optional
#       (DEFAULT = "")
#        Dependencies: -property commands; -commands_id PlayCommand | 
#       PlayStaticCommand | PlayMediaCommand | DescribeCommand | 
#    -min_delay
#       Defines the minimum jitter buffer emulator delay the adaptive algorithm allows.
#       This parameter is used by the following  jbemode: Adaptive
#        Type: optional
#       (DEFAULT = 5)
#        Dependencies: -property agent
#    -min_freq
#       The minimum time, in milliseconds, that can elapse before the 
#       client sends the next {KeepAlive} message.
#        Type: optional
#       (DEFAULT = 10000)
#        Dependencies: -property commands; -commands_id KeepAliveCommand
#    -minimum_interval
#       Minimum length of the time, in milliseconds, that the client will 
#       pause before playing the next channel on the server.
#        Type: optional
#       (DEFAULT = 1000)
#        Dependencies: -property commands; -commands_id ThinkCommand
#    -mld_version
#       Version of the Multicast Listener Discovery (MLD) protocol used to 
#       listen for IPv6 multicast addresses. You can select v1 or v2. The ip_version 
#       has to be "IPv6" for MLD.
#        Type: optional
#       (DEFAULT = v2)
#        Dependencies: -property agent
#    -mu
#       In a Normal distribution, m (mu) is the location parameter and s 
#       (sigma) is the scale parameter. In HLT, mu is the mean average channel 
#       number that the distribution will be clustered around. As channel numbers 
#       increase or decrease away from the mu value, they are less likely to be 
#       watched. Sigma determines thewidth of the distribution, the number of 
#       channels that may be watched.
#        Type: optional
#       (DEFAULT = 1)
#        Dependencies: -property commands; -commands_id ICCCommand
#    -nom_delay
#       The nominal delay defines the per-packet delay incurred by the jitter 
#       buffer emulator prior to playback.
#       This parameter is used by the following jbemode: Fixed, Adaptive
#        Type: optional
#       (DEFAULT = 20)
#        Dependencies: -property agent
#    -num_profiles
#       This indicates the number of profiles to be added with the same parameters.
#        Type: optional
#       (DEFAULT = 1)
#        Dependencies: -property profile_table
#    -pc_duration
#       Length of time (in seconds) to play the video stream.
#        Type: optional
#       (DEFAULT = 10)
#        Dependencies: -property commands; -commands_id PlayCommand
#    -percentage
#       Percentage of video clients that the profile will be applied to. The 
#       percentages of all profiles must add up to 100.
#       The profile table is populated by default with a couple of profiles. 
#       If you do not clear the table before you start adding profiles, you will get an
#       exception saying you have too many profiles which add up to over 100%.
#        Type: optional
#       (DEFAULT = 100)
#        Dependencies: -property profile_table
#    -property
#        Type: optional
#       (DEFAULT = )
#        Dependencies: N/A
#    -psc_duration
#       Length of time (in seconds) to play the video stream.
#        Type: optional
#       (DEFAULT = 10)
#        Dependencies: -property commands; -commands_id PlayStaticCommand
#    -rc_duration
#       Length of time (in seconds) to play from the new location in the video stream.
#        Type: optional
#       (DEFAULT = 10)
#        Dependencies: -property commands; -commands_id ResumeCommand
#    -report_frequency
#       If unsolicited_response_mode is 1, this option specifies the frequency 
#       (in seconds) at which unsolicited messages are generated.
#        Type: optional
#       (DEFAULT = 60)
#        Dependencies: -property agent
#    -rtp_pt
#       Sets the RTP Payload type to a default value based on the codec value. 
#       The values are:
#       Codec     Default RTP Payload Type value
#       MPEG-TS     33
#       H264     96 (Default)
#       MPEG4 Part 2     97
#       VC1     98
#        Type: optional
#       (DEFAULT = 96)
#        Dependencies: -property rule
#    -rtsp_duration
#       Length of time to play the stream. Enter 0 (zero) to play the stream 
#       for its full duration.
#        Type: optional
#       (DEFAULT = 10)
#        Dependencies: -property commands; -commands_id RTSPPlayCommand
#    -rtsp_header
#       Type of header used to identify the video player simulated by the Video 
#       client agent. The choices are:
#       windows_media_player     Windows Media Player 9.0
#       real_player     (default) Real Networks RealPlayer
#       quick_time     Apple Quick Time 6.5
#       custom     Custom player. Use the options to configure the headers that 
#            will identify this client.
#        Type: optional
#       (DEFAULT = real_player)
#        Dependencies: -property agent
#    -rtsp_proxy_enable
#       If enabled, you can enter the Rtsp proxy ip and port address.
#        Type: optional
#       (DEFAULT = 0)
#        Dependencies: -property agent
#    -rtsp_proxy_ip
#       If rtsp_proxy_enable is 1, then you can enter the Rtspp proxy ip for 
#       this option.
#        Type: optional
#       (DEFAULT = 0.0.0.0)
#        Dependencies: -property agent
#    -rtsp_proxy_port
#       If rtsp_proxy_enable is 1, then you can enter the Rtspp proxy port 
#       address for this option.
#        Type: optional
#       (DEFAULT = 554)
#        Dependencies: -property agent
#    -rule_value
#       Indicates the port range used by the stream.
#        Type: optional
#       (DEFAULT = 10000_65535)
#        Dependencies: -property rule
#    -server_ip
#       IP address of the D server. (when –commands_id ICCCommand)
#       Video server that hosts the video stream to be played. (when -commands_id 
#       is PlayCommand or PlayStaticCommand)
#       The IP address of the server. (when –commands_id is DescribeCommand)
#       An HLT video server agent handle can be passed as a parameter.
#        Type: optional
#       (DEFAULT = "")
#        Dependencies: -property commands; -commands_id ICCCommand | 
#       PlayStaticCommand | PlayCommand | DescribeCommand
#    -sigma
#       In a Normal distribution, m (mu) is the location parameter and s (sigma) 
#       is the scale parameter. In HLT, mu is the mean average channel number 
#       that the distribution will be clustered around. As channel numbers 
#       increase or decrease away from the mu value, they are less likely to 
#       be watched. Sigma determines the width of the distribution, the number 
#       of channels that may be watched.
#        Type: optional
#       (DEFAULT = 1)
#        Dependencies: -property commands; -commands_id ICCCommand | JoinCommand
#    -source_address
#       Configures the source address (the IP address of the A server), 
#       if the client uses IGMP v3 and you want to send a source-specific JOIN to 
#       a multicast group. If you specify ANY, the client does not specify a 
#       particular source address.
#        Type: optional
#       (DEFAULT = any)
#        Dependencies: -property commands -commands_id ICCCommand | JoinCommand
#    -start_group_address
#       IP address of the first multicast group that the client will join.
#        Type: optional
#       (DEFAULT = )
#        Dependencies: -property commands -commands_id ICCCommand | JoinCommand
#    -suppress_reports
#    (IGMPv3 only) If 1, the client allows its IGMPv3 Membership Record 
#       to be "suppressed" by a membership report for version 2. The suppression 
#       will only be for group reports received from another port.
#        Type: optional
#       (DEFAULT = 1)
#        Dependencies: -property agent
#    -sym_server_ip
#       IxLoad video server agent handle that hosts the video stream to be played.
#        Type: optional
#       (DEFAULT = "none")
#        Dependencies: -property commands; -commands_id PlayMediaCommand
#    -transport
#       Transport protocol used to send the video stream. It applies only to VoD.
#       •    0 RTP over UDP
#       •    1 (default) UDP
#        Type: optional
#       (DEFAULT = 1)
#        Dependencies: -property agent
#    -type_of_service_for_rtsp
#       If enable_tos_rtsp  is 1, this option specifies the IP Precedence / 
#       TOS (Type of Service) bit setting and Assured Forwarding classes. 
#       (Default = "Best Effort 0x0"). If you want to specify the standard choices 
#       that are in the GUI, you can use a string representation. To specify any 
#       of the other 255 TOS values, specify the decimal value. 
#       The default choices are:
#       best_effort    (Default) routine priority
#       "Class 1 (0x20)"     Priority service, Assured Forwarding class 1
#       "Class 2 (0x40)"     Immediate service, Assured Forwarding class 2
#       "Class 3 (0x60)"     Flash, Assured Forwarding class 3
#       "Class 4 (0x80)"     Flash-override, Assured Forwarding class 4
#       "Express Forwarding (0xA0)"     Critical-ecp
#       "Control (0xC0)"     Internet-control
#        Type: optional
#       (DEFAULT = best_effort)
#        Dependencies: -property agent
#    -unsolicited_response_mode
#       If 1, the video client automatically sends full IGMP membership 
#       messages at regular intervals without waiting for a query message. In 
#       the Report Interval Field, specify the frequency, in seconds, at which 
#       unsolicited messages are generated.
#       •    0 (default) Client does not send unsolicited IGMP membership 
#       messages.
#       •    1 Client sends unsolicited IGMP membership messages.
#        Type: optional
#       (DEFAULT = 0)
#        Dependencies: -property agent
#    -update_interval
#       Frequency, in milliseconds, at which HLT gathers the statistics 
#       related to the quality metrics.
#        Type: optional
#       (DEFAULT = 2000)
#        Dependencies: -property agent
#    -urls
#       IPTV (multicast) streams to play from the D server.
#       You can enter sequence generators in this field to generate 
#       URLs for more than one stream.
#       You can use an IxLoad video server stream handle.
#        Type: optional
#       (DEFAULT = "")
#        Dependencies: -property commands; -commands_id ICCCommand
#    -var_lambda
#       A Poisson distribution models the number of events that occur 
#       within a given time interval. In a Poisson distribution, l (lambda) 
#       is the shape parameter, which indicates the average number of events 
#       in the given time interval. When used for HLT, the lambda value is 
#       the mean average channel number that the distribution will be clustered 
#       around. The bell-curved shape of the distribution ensures that the 
#       most-watched channels will be those closest to the mean (the lambda), 
#       with channels less likely to be watched as channel numbers move away 
#       from the lambda value.
#        Type: optional
#       (DEFAULT = 1)
#        Dependencies: -property commands; -commands_id ICCCommand | JoinCommand
#    -var_lambda
#       A Poisson distribution models the number of events that occur 
#       within a given time interval. In a Poisson distribution, l (lambda) is 
#       the shape parameter, which indicates the average number of events in 
#       the given time interval. When used for HLT, the lambda value is the mean 
#       average channel number that the distribution will be clustered around. 
#       The bell-curved shape of the distribution ensures that the most-watched 
#       channels will be those closest to the mean (the lambda), with channels 
#       less likely to be watched as channel numbers move away from the lambda value.
#        Type: optional
#       (DEFAULT = 1)
#        Dependencies: -property commands; -commands_id ICCCommand | JoinCommand
#    -view_sequence
#       Mentions the sequence in which the channel is viewed.
#        Type: optional
#       (DEFAULT = 1)
#        Dependencies: -property channelviewTable
#    -watch_count
#       Number of channels that will be viewed as a part of this Join 
#       command. If you set the channel_switch_mode to Normal or Poisson, you 
#       can configure the value here. For the other distribution options, this 
#       option is read-only and automatically set to the same value as the 
#       channel_count parameter.
#        Type: optional
#       (DEFAULT = 1)
#        Dependencies: -property commands; -commands_id ICCCommand | JoinCommand
#
# Return Values:
#        A Keyed List
#         Key                       value
#         ---                       -----
#         Status                    SUCCESS | FAILURE
#         Log                       Error message if command returns {status 0}
#         client_handle             when –property is “client”
#         agent_handle              when –property is “client” or “agent”
#         profile_table_handle      when –property is “profile_table”
#         commands_handle           when –property is “commands”
#         channelviewTable_handle   when –property is “channelviewTable”
#         rule_handle               when –property is “rule”
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
#     Available statistic keys for Video and IPTV client
#     [Key: Name
#         Description]
#     Statistics can be added and collected using ::ixia::L47_stats procedure 
#    (please refer to HLT User Guide for a description of this procedure).
#     
#     video_active_multicast_channels: Active Multicast Channels 
#         Number of multicast channels joined across all users.
#     video_multicast_channels_requested: Multicast Channels Requested 
#         Number of multicast channels that the client requested.
#     video_multicast_requests_successful: Multicast Requests Successful 
#         Number of multicast requests for which the client received a successful response.
#     video_multicast_requests_failed: Multicast Requests Failed 
#         Number of multicast requests for which the client received a failure response.
#     video_vod_streams_playback_successful: VoD Streams Playback Successful 
#         Number of VoD streams successfully played.
#     video_vod_streams_played_failed: VoD Streams Played Failed 
#         Number of VoD streams that could not be played.
#     video_vod_streams_played: VoD Streams Played 
#         Number of VoD streams that the client attempted to play.
#     
#     IPTV Statistics
#     video_active_d_server_channels: Active D Server Channels 
#         Number of streams currently playing on the D server.
#     video_active_v_server_channels: Active V Server Channels 
#         Number of streams currently playing on the V server.
#     video_d_server_channels_requested: D Server Channels Requested 
#         Number of streams requested from the D server.
#     video_d_server_requests_successful: D Server Requests Successful 
#         Number of requests to the D server that were successful.
#     video_d_server_requests_failed: D Server Requests Failed 
#         Combined total of control and data requests to the D server that failed.
#     video_d_server_requests_failed_control: D Server Requests Failed (Control) 
#         Number of control plane requests to the D server that failed.
#     video_d_server_requests_failed_data: D Server Requests Failed (Data) 
#         Number of data plane requests to the D server that failed.
#     video_v_server_channels_requested: V Server Channels Requested 
#         Number of streams requested from the V server.
#     video_v_server_requests_successful: V Server Requests Successful 
#         Number of requests to the V server that were successful.
#     video_v_server_requests_failed: V Server Requests Failed 
#         Combined total of control and data requests to the V server that failed.
#     video_v_server_requests_failed_control: V Server Requests Failed (Control) 
#         Number of control plane requests to the V server that failed.
#     video_v_server_requests_failed_data: V Server Requests Failed (Data) 
#         Number of data plane requests to the V server that failed.
#     
#     Video client statistics
#     video_igmp_queries_rcvd: IGMP Queries Rcvd 
#         Number of IGMP Query messages received by the client.
#     video_igmp_reports_sent: IGMP Reports Sent 
#         Number of IGMP Report messages sent by the client for all users.
#     video_igmp_leaves_sent: IGMP Leaves Sent 
#         Number of IGMP Leave messages sent by the client.
#     video_mld_queries_rcvd: MLD Queries Rcvd 
#         Number of Multicast Listener Discovery (MLD) Query messages received.
#     video_mld_reports_sent: MLD Reports Sent 
#         Number of MLD Report messages sent.
#     video_mld_leaves_sent: MLD Leaves Sent 
#         Number of MLD Leave messages sent.
#     video_join_latency: Join Latency 
#         Average time elapsed between the time the client sent an IGMP Join message 
#         and the time it received a response.
#         Note for Tcl API users: This is a weighted statistic. If you are using this
#         statistic in a Tcl script, use the kWeightedAverage aggregation type.
#     video_leave_latency: Leave Latency 
#         Average time elapsed between the time the client sent an IGMP Leave 
#         message and the time it received a response.
#         This statistic is valid only for IGMPv2. For IGMPv3, Leaves for multicast
#         groups are sent by sending an IGMP report with the modified group list.
#         Note for Tcl API users: This is a weighted statistic. If you are using this
#         statistic in a Tcl script, use the kWeightedAverage aggregation type.
#     video_channel_switch_latency: Channel Switch Latency 
#         Average time elapsed between the time the client changed to a new channel and 
#         the time it received the first byte of the new stream.
#         Note for Tcl API users: This is a weighted statistic. If you are using this
#         statistic in a Tcl script, use the kWeightedAverage aggregation type.
#     video_rtsp_bytes_sent: RTSP Bytes Sent 
#         Number of bytes sent by the RTSP client, including the payload and all headers.
#     video_rtsp_bytes_received: RTSP Bytes Received 
#         Number of bytes received in RTSP messages.
#     video_rtsp_packets_sent: RTSP Packets Sent 
#         Number of RTSP packets sent by the client.
#     video_rtsp_packets_received: RTSP Packets Received 
#         Number of RTSP packets received by the client.
#     video_rtsp_concurrent_sessions: RTSP Concurrent Sessions 
#         Number of concurrent RTSP sessions maintained.
#     video_rtsp_connection_rate: RTSP Connection Rate 
#         Rate at which the client established RTSP connections.
#     video_rtsp_transactions: RTSP Transactions 
#         Number of RTSP transactions completed.
#     video_rtsp_transaction_rate: RTSP Transaction Rate 
#         Rate at which the client completed RTSP transactions.
#     video_rtsp_connections: RTSP Connections 
#         Number of RTSP connections established by the client.
#     video_rtsp_setup_latency_ms: RTSP Setup Latency (ms) 
#         Amount of time elapsed, in milliseconds, between a client sending a request 
#         to establish an RTSP connection and receiving the first byte of the response.
#         Note for Tcl API users: This is a weighted statistic. If you are using this
#         statistic in a Tcl script, use the kWeightedAverage aggregation type.
#     video_rtsp_teardown_latency_ms: RTSP Teardown Latency (ms) 
#         Amount of time elapsed, in milliseconds, between a client sending a request 
#         to end an RTSP connection and receiving the first byte of the response.
#         Note for Tcl API users: This is a weighted statistic. If you are using this
#         statistic in a Tcl script, use the kWeightedAverage aggregation type.
#     video_rtsp_play_latency_ms: RTSP Play Latency (ms) 
#         Amount of time elapsed, in milliseconds, between a client sending a PLAY 
#         command and receiving the first byte of the media stream.
#         Note for Tcl API users: This is a weighted statistic. If you are using this
#         statistic in a Tcl script, use the kWeightedAverage aggregation type.
#     video_rtsp_play_latency_0_ms_10_ms: RTSP Play Latency (0 ms - 10 ms) 
#         Number of instances in which 0 to 10 milliseconds elapsed between the time
#         a client sent a PLAY command and the time it received the first byte of the
#         media stream.
#     video_rtsp_play_latency_10_ms_50_ms: RTSP Play Latency (10 ms - 50 ms) 
#         Number of instances in which 10 to 50 milliseconds elapsed between the time
#         a client sent a PLAY command and the time it received the first byte of the
#         media stream.
#     video_rtsp_play_latency_50_ms_100_ms: RTSP Play Latency (50 ms - 100 ms) 
#         Number of instances in which 50 to 100 milliseconds elapsed between the
#         time a client sent a PLAY command and the time it received the first byte of
#         the media stream.
#     video_rtsp_play_latency_100_ms_300ms: RTSP Play Latency (100 ms - 300ms)
#         Number of instances in which 100 to 300 milliseconds elapsed between the
#         time a client sent a PLAY command and the time it received the first byte of
#         the media stream.
#     video_rtsp_play_latency_300_ms_1s: RTSP Play Latency (300 ms - 1s) 
#         Number of instances in which 300 to 1000 milliseconds elapsed between
#         the time a client sent a PLAY command and the time it received the first byte of
#         the media stream.
#     video_rtsp_play_latency_greater_than_1s: RTSP Play Latency (Greater Than 1s) 
#         Number of instances in which more than one second elapsed between the
#         time a client sent a PLAY command and the time it received the first byte of
#         the media stream.
#     video_rtsp_presentations_active: RTSP Presentations Active 
#         Number of RTSP presentations available.
#     video_rtsp_presentations_playing: RTSP Presentations Playing 
#         Number of RTSP presentations playing.
#     video_rtsp_presentations_paused: RTSP Presentations Paused 
#         Number of RTSP presentations paused.
#     video_rtsp_presentations_requested: RTSP Presentations Requested 
#         Number of RTSP presentations requested by the client.
#     video_rtsp_presentation_requests_successful: RTSP Presentation Requests Successful
#         Number of presentation requests sent by the client for which it received a 
#         successful response.
#     video_rtsp_presentation_requests_failed: RTSP Presentation Requests Failed 
#         Number of presentation requests sent by the client that failed.
#     video_rtsp_set_parameter: RTSP SET PARAMETER 
#         Sent Number of RTSP SET PARAMETER messages sent.
#     video_rtsp_get_parameter: RTSP GET PARAMETER 
#         Sent Number of RTSP GET PARAMETER messages sent.
#     video_rtsp_describe: RTSP DESCRIBE 
#         Sent Number of RTSP DESCRIBE messages sent.
#     video_rtsp_setup: RTSP SETUP 
#         Sent Number of RTSP SETUP messages sent.
#     video_rtsp_play: RTSP PLAY 
#         Sent Number of RTSP PLAY commands sent.
#     video_rtsp_pause: RTSP PAUSE 
#         Sent Number of RTSP PAUSE commands sent.
#     video_rtsp_teardown: RTSP TEARDOWN 
#         Sent Number of RTSP TEARDOWN commands sent.
#     video_rtsp_describe: RTSP DESCRIBE 
#         Successful Number of RTSP DESCRIBE commands for which a successful response 
#         was received.
#     video_rtsp_setup: RTSP SETUP 
#         Successful Number of RTSP SETUP commands for which a successful response was
#         received.
#     video_rtsp_set_parameter: RTSP SET PARAMETER 
#         Successful Number of SET_PARAMETER replies received with code OK (200).
#     video_rtsp_get_parameter: RTSP GET PARAMETER 
#         Successful Number of RTSP GET PARAMETER commands for which a successful
#         response was received.
#     video_rtsp_play: RTSP PLAY 
#         Successful Number of RTSP PLAY commands for which a successful response was
#         received.
#     video_rtsp_pause: RTSP PAUSE 
#         Successful Number of RTSP PAUSE commands for which a successful response was
#         received.
#     video_rtsp_teardown: RTSP TEARDOWN 
#         Successful Number of RTSP TEARDOWN commands for which a successful response 
#         was received.
#     video_rtsp_describe: RTSP DESCRIBE 
#         Failed Number of RTSP DESCRIBE commands that failed.
#     video_rtsp_setup: RTSP SETUP 
#         Failed Number of RTSP SETUP commands that failed.
#     video_rtsp_set_parameter: RTSP SET PARAMETER 
#         Failed Number of SET_PARAMETER replies received with a code other than OK(200).
#     video_rtsp_get_parameter: RTSP GET PARAMETER 
#         Failed Number of RTSP GET PARAMETER commands that failed.
#     video_rtsp_play: RTSP PLAY 
#         Failed Number of RTSP PLAY commands that failed.
#     video_rtsp_pause: RTSP PAUSE 
#         Failed Number of RTSP PAUSE commands that failed.
#     video_rtsp_teardown: RTSP TEARDOWN 
#         Failed Number of RTSP TEARDOWN commands that failed.
#     video_average_play_latency: Average Play latency 
#         Average amount of time elapsed between the time the client sent a Play
#         command and them time it received the first byte of the video stream.
#         Note for Tcl API users: This is a weighted statistic. If you are using this
#         statistic in a Tcl script, use the kWeightedAverage aggregation type.
#     video_average_pause_latency: Average Pause latency 
#         Average amount of time elapsed between the time the client sent a
#         Pause command and the time it stopped receiving data from the video
#         stream.
#         Note for Tcl API users: This is a weighted statistic. If you are using this
#         statistic in a Tcl script, use the kWeightedAverage aggregation type.
#     video_video_simulated_users: Video Simulated Users 
#         Number of users simulated by the client.
#     
#     Global Stream Statistics
#     video_frame_stats_disabled: Frame Stats Disabled 
#         Initially this statistic displays no value.
#         If the received data rate exceeds the cut-off threshold, IxLoad stops
#         computing the I-, P-, and B-frame statistics and this statistic will display
#         “YES”.
#         The value will remain YES until the end of the iteration. Once frame statistics
#         computation is disabled during a run, it remains disabled throughout the
#         remainder of the run.
#         Prior to starting the next run (or the next iteration of the same test), this
#         statistic will be cleared and IxLoad will again begin computing the frame
#         statistics. It will continue to compute the frame statistics as long as the bit
#         rate remains below the cut-off threshold.
#         Note for Tcl API users: For this statistic, use the Aggregation Type kString.
#     video_quality_metrics_disabled: Quality Metrics Disabled 
#         Initially, this statistic displays no value.
#         If the received data rate exceeds the cut-off threshold, IxLoad stops
#         computing the Quality Metrics, and this statistic will display “YES”.
#         The value will remain YES until the end of the iteration. Once the Quality
#         Metrics computation is disabled during a run, it remains disabled throughout
#         the remainder of the run.
#         Prior to starting the next run (or the next iteration of the same test), this
#         statistic will be cleared and IxLoad will again begin computing the Quality
#         Metrics. It will continue to compute the metrics as long as the bit rate remains
#         below the cut-off threshold. 
#         Note for Tcl API users: For this statistic, use the Aggregation Type kString.
#     video_total_bytes_rcvd: Total Bytes Rcvd 
#         Total number of bytes received by the client.
#     video_total_packets_rcvd: Total packets Rcvd 
#         Total number of packets received by the client.
#     video_total_loss: Total Loss 
#         Total number MPEG2-TS packets lost.
#     video_unexpected_udp_packets_received: Unexpected UDP Packets Received 
#         Number of UDP packets received packets during a time when no channels are active.
#     video_overload_packets_dropped: Overload Packets Dropped 
#         Number of RTP packets dropped because a port did not have enough computing 
#         power to process them.
#     video_total_rtp_packets_lost: Total RTP Packets Lost 
#         Total number of RTP packets lost while using RTP over UDP transport.
#     video_total_out_of_order_rtp_packets_rcvd: Total Out Of Order RTP Packets Rcvd 
#         Total number of RTP packets received in the wrong order while using RTP 
#         over UDP transport.
#     video_total_duplicate_rtp_packets: Total Duplicate RTP Packets
#         Total number of duplicate RTP packets received.
#     video_global_jitter: Global Jitter 
#         Average variation in arrival times of packets on all streams.
#         Note for Tcl API users: This is a weighted statistic. If you are using this
#         statistic in a Tcl script, use the kWeightedAverage aggregation type.
#     video_jitter_less_than_50_us: Jitter less than 50 us 
#         Number of packets received with 0 to 50 microseconds of jitter.
#     video_jitter_between_50_100_us: Jitter between 50 - 100 us 
#         Number of packets received with 50 to 100 microseconds of jitter.
#     video_jitter_between_100_500_us: Jitter between 100 - 500 us 
#         Number of packets received with 100 - 500 microseconds of jitter.
#     video_jitter_between_500_us_2_ms: Jitter between 500 us - 2 ms 
#         Number of packets received with 500 microseconds to 2 milliseconds of jitter.
#     video_jitter_between_2_5_ms: Jitter between 2 - 5 ms 
#         Number of packets received with 2 to 5 milliseconds of jitter.
#     video_jitter_between_5_10_ms: Jitter between 5 - 10 ms 
#         Number of packets received with 5 to 10 milliseconds of jitter.
#     video_jitter_greater_than_10_ms: Jitter greater than 10 ms 
#         Number of packets received with more than 10 milliseconds of jitter.
#     video_packet_size_between_0_100_bytes: Packet Size between 0 - 100 bytes 
#         Number of packets received that were 0 to 100 bytes in size.
#     video_packet_size_between_100_200_bytes: Packet Size between 100 - 200 bytes 
#         Number of packets received that were between 100 and 200 bytes in size.
#     video_packet_size_between_200_400_bytes: Packet Size between 200 - 400 bytes 
#         Number of packets received that were between 200 and 400 bytes in size.
#     video_packet_size_between_400_600_bytes: Packet Size between 400 - 600 bytes 
#         Number of packets received that were between 400 and 600 bytes in size.
#     video_packet_size_between_600_1000_bytes: Packet Size between 600 - 1000 bytes
#         Number of packets received that were between 600 and 1000 bytes in size.
#     video_packet_size_greater_than_1000_bytes: Packet Size greater than 1000 bytes 
#         Number of packets received that were larger than 1000 bytes.
#     video_inter_packet_arrival_time_between_0_2_ms: Inter Packet Arrival Time between 
#         0 - 2 ms
#         Number of packets that arrived less than 2 milliseconds after the preceding
#         packet was received.
#     video_inter_packet_arrival_time_between_2_5_ms: Inter Packet Arrival Time 
#         between 2 - 5 ms
#         Number of packets that arrived between 2 and 5 milliseconds after the
#         preceding packet was received.
#     video_inter_packet_arrival_time_between_5_10_ms: Inter Packet Arrival Time 
#         between 5 - 10 ms
#         Number of packets that arrived between 5 and 10 milliseconds after
#         the preceding packet was received.
#     video_inter_packet_arrival_time_between_10_25_ms: Inter Packet Arrival Time 
#         between 10 - 25 ms
#         Number of packets that arrived between 10 and 25 milliseconds after
#         the preceding packet was received.
#     video_inter_packet_arrival_time_between_25_50_ms: Inter Packet Arrival Time 
#         between 25 - 50 ms
#         Number of packets that arrived between 25 and 50 milliseconds after
#         the preceding packet was received.
#     video_inter_packet_arrival_time_between_50_100_ms: Inter Packet Arrival Time 
#         between 50 - 100 ms
#         Number of packets that arrived between 50 and 100 milliseconds after
#         the preceding packet was received.
#     video_inter_packet_arrival_time_between_100_200_ms: Inter Packet Arrival Time 
#         between 100 - 200 ms
#         Number of packets that arrived between 100 and 200 milliseconds
#         after the preceding packet was received.
#     video_inter_packet_arrival_time_between_200_500_ms: Inter Packet Arrival Time 
#         between 200 - 500 ms
#         Number of packets that arrived between 200 and 500 milliseconds
#         after the preceding packet was received.
#     video_inter_packet_arrival_time_greater_than_500_ms: Inter Packet Arrival Time 
#         greater than 500 ms
#         Number of packets that arrived more than 500 milliseconds after the
#         preceding packet was received. 
#         Note: The following packet latency statistics are only available for 
#         streams from an IxLoad Video server with synthetic payloads.
#     video_packet_latency_between_0_2_ms: Packet Latency between 0 - 2 ms 
#         Number of UDP packets that required between 0 and 2 milliseconds to travel
#         from the server to the client.
#     video_packet_latency_between_2_5_ms: Packet Latency between 2 - 5 ms 
#         Number of UDP packets that required between 2 and 5 milliseconds to travel
#         from the server to the client.
#     video_packet_latency_between_5_10_ms: Packet Latency between 5 - 10 ms 
#         Number of UDP packets that required between 5 and 10 milliseconds to
#         travel from the server to the client.
#     video_packet_latency_between_10_25_ms: Packet Latency between 10 - 25 ms 
#         Number of UDP packets that required between 10 and 25 milliseconds to
#         travel from the server to the client.
#     video_packet_latency_between_25_50_ms: Packet Latency between 25 - 50 ms 
#         Number of UDP packets that required between 25 and 50 milliseconds to
#         travel from the server to the client.
#     video_packet_latency_between_50_100_ms: Packet Latency between 50 - 100 ms 
#         Number of UDP packets that required between 50 and 100 milliseconds to
#         travel from the server to the client.
#     video_packet_latency_between_100_200_ms: Packet Latency between 100 - 200 ms
#         Number of UDP packets that required between 100 and 200 milliseconds to
#         travel from the server to the client.
#     video_packet_latency_between_200_500_ms: Packet Latency between 200 - 500 ms
#         Number of UDP packets that required between 200 and 500 milliseconds to
#         travel from the server to the client.
#     video_packet_latency_greater_than_500_ms: Packet Latency greater than 500 ms 
#         Number of UDP packets that more than 500 milliseconds to travel from the
#         server to the client.
# 
proc ::ixia::L47_video_client { args } {
    variable executeOnTclServer
	
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
	
    variable temporary_fix_122311
    if {$::ixia::executeOnTclServer && $::ixia::temporary_fix_122311 == 0} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
            \{::ixia::L47_video_client $args\}]
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args

    set returnList [checkL47 VIDEO]
    if {[keylget returnList status] == $::FAILURE} {
        return $returnList
    }
    set mandatory_args {
            -mode        CHOICES add remove modify enable disable
    }


    set opt_args {
            -bitrate_limit    RANGE 0-2147483647
                          DEFAULT 0
        -channel_switch_delay_max    RANGE 0-100000000
                                     DEFAULT 1000
        -channel_switch_delay_min    RANGE 0-100000000
                                     DEFAULT 1000
        -channel_switch_mode    CHOICES sequential
                                CHOICES random
                                CHOICES poisson
                                CHOICES normal
                                CHOICES unique
                                CHOICES custom
                                DEFAULT sequential
        -client_mode    CHOICES 0
                        CHOICES 1
                        DEFAULT 0
        -clock_rate    RANGE 0-2147483647
                       DEFAULT 90000
        -codec    CHOICES h264
                  CHOICES mpeg4
                  CHOICES vc1
                  CHOICES ts
                  CHOICES mpeg4aac
                  CHOICES mpeg4ldaac
                  DEFAULT h264
        -commands_id    CHOICES ICCCommand
                        CHOICES KeepAliveCommand
                        CHOICES JoinCommand
                        CHOICES DescribeCommand
                        CHOICES RTSPSetupCommand
                        CHOICES RTSPPlayCommand
                        CHOICES RTSPPauseCommand
                        CHOICES RTSPSetParamCommand
                        CHOICES RTSPGetParamCommand
                        CHOICES RTSPTeardownCommand
                        CHOICES PlayCommand
                        CHOICES PlayStaticCommand
                        CHOICES PlayMediaCommand
                        CHOICES PauseCommand
                        CHOICES ResumeCommand
                        CHOICES SeekCommand
                        CHOICES StopCommand
                        CHOICES ThinkCommand
                        CHOICES LoopBeginCommand
                        CHOICES LoopEndCommand
                        CHOICES PassiveCommand
        -concurrent_channels    RANGE 1-1
                                DEFAULT 1
        -content    ANY
        -content_type    ANY
        -count    RANGE 1-1000000
                  DEFAULT 1
        -custom_setup    ANY
                         DEFAULT mode_play
        -da_switchover_delay    RANGE 1-2147483
                                DEFAULT 1
        -destination_server_activity    ANY
                                        DEFAULT none
        -duration    RANGE 1-2147483
                     DEFAULT 10
        -duration_max    RANGE 1-2147483
                         DEFAULT 10
        -duration_min    RANGE 1-2147483
                         DEFAULT 10
        -enable_custom    CHOICES 0 1
                          DEFAULT 0
        -enable_custom_setup    CHOICES 0 1
                                DEFAULT 0
        -enable_esm    CHOICES 0 1
                       DEFAULT 0
        -enable_frame_stats    CHOICES 0 1
                               DEFAULT 0
        -enable_tos_rtsp    CHOICES 0 1
                            DEFAULT 0
        -enable_unicast    CHOICES 0
                           CHOICES 1
                           DEFAULT 0
        -enable_vlan_priority    CHOICES 0 1
                                 DEFAULT 0
        -enable_vqmon_stats    CHOICES 0 1
                               DEFAULT 0
        -esm    RANGE 64-1460
                DEFAULT 1460
        -follow_rtsp_redirect    CHOICES 0 1
                                 DEFAULT 0
        -general_query_response_mode    CHOICES 0 1
                                        DEFAULT 1
        -group_address_count    RANGE 1-1000
                                DEFAULT 1
        -group_address_step    ANY
                               DEFAULT 0.0.0.1
        -group_specific_query_response_mode    CHOICES 0 1
                                               DEFAULT 1
        -handle    ANY
        -icc_channel_switch_delay_max    RANGE 0-100000000
                                         DEFAULT 0
        -icc_channel_switch_delay_min    RANGE 0-100000000
                                         DEFAULT 0
        -icc_duration_max    RANGE 30-2147483
                             DEFAULT 30
        -icc_duration_min    RANGE 30-2147483
                             DEFAULT 30
        -igmp_version    CHOICES igmpv1
                         CHOICES igmpv2
                         CHOICES igmpv3
                         DEFAULT igmpv3
        -ignore_loss    CHOICES 0 1
                        DEFAULT 0
        -immediate_response    CHOICES 0 1
                               DEFAULT 0
        -ip_version    CHOICES ipv4
                       CHOICES ipv6
                       DEFAULT ipv4
        -iptv_switch_delay    RANGE 1-60
                              DEFAULT 1
        -iptv_switch_mode    CHOICES 0
                             CHOICES 1
                             CHOICES 2
                             DEFAULT 0
        -jbemode    CHOICES 0
                    CHOICES 1
                    CHOICES 2
                    DEFAULT 0
        -jc_channel_switch_delay_max    RANGE 0-100000000
                                        DEFAULT 0
        -jc_channel_switch_delay_min    RANGE 0-100000000
                                        DEFAULT 0
        -jc_channel_switch_mode    CHOICES sequential
                                   CHOICES random
                                   CHOICES concurrent
                                   CHOICES poisson
                                   CHOICES normal
                                   CHOICES unique
                                   CHOICES custom
                                   DEFAULT concurrent
        -jc_concurrent_channels    RANGE 1-4
                                   DEFAULT 1
        -loop_count    RANGE 0-2147483647
                       DEFAULT 5
        -max_delay    RANGE 1-100000
                      DEFAULT 80
        -max_freq    RANGE 1000-10000000
                     DEFAULT 10000
        -maximum_interval    RANGE 1000-2147483647
                             DEFAULT 1000
        -media    ANY
        -min_delay    RANGE 1-100000
                      DEFAULT 5
        -min_freq    RANGE 1000-10000000
                     DEFAULT 10000
        -minimum_interval    RANGE 1000-2147483647
                             DEFAULT 1000
        -mld_version    CHOICES v1
                        CHOICES v2
                        DEFAULT v2
        -mu    RANGE 1-2147483
               DEFAULT 1
        -nom_delay    RANGE 1-100000
                      DEFAULT 20
        -num_profiles    RANGE 1-1000
                         DEFAULT 1
        -pc_duration    RANGE 1-2147483
                        DEFAULT 10
        -percentage    RANGE 0-100
                       DEFAULT 100
        -property    CHOICES client
                     CHOICES agent
                     CHOICES profile_table
                     CHOICES commands
                     CHOICES channelviewTable
                     CHOICES rule
                     DEFAULT agent
        -psc_duration    RANGE 1-2147483
                         DEFAULT 10
        -rc_duration    RANGE 1-2147483
                        DEFAULT 10
        -report_frequency    RANGE 30-2147483
                             DEFAULT 60
        -rtp_pt    RANGE 1-127
                   DEFAULT 96
        -rtsp_duration    RANGE 0-2147483
                          DEFAULT 10
        -rtsp_header    CHOICES windows_media_player
                        CHOICES real_player
                        CHOICES quick_time
                        CHOICES custom
                        DEFAULT real_player
        -rtsp_proxy_enable    CHOICES 0 1
                              DEFAULT 0
        -rtsp_proxy_ip    ANY
                          DEFAULT 0.0.0.0
        -rtsp_proxy_port    ANY
                            DEFAULT 554
        -rule_value    ANY
                       DEFAULT 10000_65535
        -server_ip    ANY
        -sigma    RANGE 1-2147483
                  DEFAULT 1
        -source_address    ANY
                           DEFAULT any
        -start_group_address    ANY
        -start_group_address_sym    ANY
        -suppress_reports    CHOICES 0 1
                             DEFAULT 1
        -sym_server_ip    ANY
                          DEFAULT none
        -transport    CHOICES 1
                      CHOICES 0
                      DEFAULT 1
        -type_of_service_for_rtsp    ANY
                                     DEFAULT best_effort
        -unsolicited_response_mode    CHOICES 0 1
                                      DEFAULT 0
        -update_interval    RANGE 2000-100000
                            DEFAULT 2000
        -urls    ANY
        -var_lambda    RANGE 1-2147483
                       DEFAULT 1
        -view_sequence    ANY
        -watch_count    RANGE 0-2147483
                        DEFAULT 1
    }


    if {[catch  {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $mandatory_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }

    set target client
    if {$mode == "add"} {
        if {![info exists property]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -mode is $mode, then -property\
                    must be provided."
            return $returnList
        }

        if {($property != "client") && (![info exists handle])} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -property is $property, then -handle\
                    must be provided."
            return $returnList
        }
    } else  {
        ::ixia::removeDefaultOptionVars $opt_args $args

        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -mode is $mode, then -handle\
                    must be provided."
            return $returnList
        }
        if {![info exists property]} {
            set property [::ixia::ixL47GetProperty $handle video]
        }
    }

    # profile_table parameters
    set profile_table_option_list [list procName mode handle property target \
        channel_switch_delay_min percentage channel_switch_delay_max duration_max \
        num_profiles duration_min ]
    set profile_table_args [list]

    lappend option_variables profile_table_option_list
    lappend option_variables profile_table_args

    # rule parameters
    set rule_option_list [list procName mode handle property target \
        rtp_pt codec clock_rate rule_value ]
    set rule_args [list]

    lappend option_variables rule_option_list
    lappend option_variables rule_args

    # commands parameters
    set commands_option_list [list procName mode handle property target \
        maximum_interval sigma duration media jc_concurrent_channels rc_duration \
        min_freq group_address_step destination_server_activity urls count mu start_group_address \
        concurrent_channels server_ip enable_unicast commands_id icc_channel_switch_delay_max \
        content_type max_freq jc_channel_switch_delay_max pc_duration rtsp_duration \
        content watch_count var_lambda channel_switch_mode group_address_count loop_count \
        sym_server_ip source_address duration_min jc_channel_switch_delay_min icc_duration_min \
        duration_max jc_channel_switch_mode icc_channel_switch_delay_min minimum_interval \
        psc_duration icc_duration_max start_group_address_sym da_switchover_delay \
        ]
    set commands_args [list]

    lappend option_variables commands_option_list
    lappend option_variables commands_args

    # channelviewTable parameters
    set channelviewTable_option_list [list procName mode handle property target \
        view_sequence ]
    set channelviewTable_args [list]

    lappend option_variables channelviewTable_option_list
    lappend option_variables channelviewTable_args

    # agent parameters
    set agent_option_list [list procName mode handle property target \
        enable_custom_setup update_interval mld_version unsolicited_response_mode \
        custom_setup min_delay iptv_switch_delay iptv_switch_mode rtsp_header rtsp_proxy_port \
        bitrate_limit nom_delay enable_tos_rtsp ip_version follow_rtsp_redirect \
        esm enable_custom type_of_service_for_rtsp enable_vqmon_stats general_query_response_mode \
        report_frequency suppress_reports max_delay ignore_loss jbemode transport \
        igmp_version enable_esm group_specific_query_response_mode enable_frame_stats \
        rtsp_proxy_enable immediate_response rtsp_proxy_ip client_mode enable_vlan_priority \
        ]
    set agent_args [list]

    lappend option_variables agent_option_list
    lappend option_variables agent_args


    foreach {property_list property_args} $option_variables {
        set _o_list [set $property_list]
        foreach item $_o_list {
            if {[info exists $item]} {
                lappend $property_args "-$item"
                lappend $property_args "\"[set $item]\""
            }
        }
    }


    switch -- $property {
        profile_table {
            set returnList [eval [format "%s %s" ::ixia::ixL47VIDEOCLIENTprofile_table\
                $profile_table_args]]
            return $returnList
        }
        rule {
            set returnList [eval [format "%s %s" ::ixia::ixL47VIDEOCLIENTrule\
                $rule_args]]
            return $returnList
        }
        commands {
            set returnList [eval [format "%s %s" ::ixia::ixL47VIDEOCLIENTcommands\
                $commands_args]]
            return $returnList
        }
        channelviewTable {
            set returnList [eval [format "%s %s" ::ixia::ixL47VIDEOCLIENTchannelviewTable\
                $channelviewTable_args]]
            return $returnList
        }
        client -
        agent {
            set returnList [eval [format "%s %s" ::ixia::ixL47VIDEOCLIENTagent\
                $agent_args]]
            return $returnList
        }
        default {}
    }
}


## Internal Procedure Header
# Name:
#    ::ixia::L47_video_server
#
# Description:
#     The ::ixia::L47_video_server procedure can create the following type of objects:
#         * Traffic server and video server agent when –property parameter is 
#           “server”. The traffic server can be extracted from the keyed list 
#           using the key “server_handle”. The video server agent can be 
#           extracted from the keyed list using the key “agent_handle”.
#         * Video server agent when –property parameter is “agent” and –handle 
#           parameter has the value of a traffic server handle.
#         * VideoList when –property parameter is “videoList” and –handle 
#           parameter has the value of a video server agent handle. The video list 
#           can be extracted from the keyed list using the key “videoList_handle”.
#         * Link utilization list when –property parameter is 
#           “linkUtilizationList” and the –handle parameter has the value of 
#           a video server agent. The link utilization list handle can be 
#           extracted from the keyed list using the key 
#           “linkUtilizationList_handle”.
#         * Stream object when –property parameter is “stream” and –handle 
#           parameter has the value of a video server agent handle. The stream object 
#           handle can be extracted from the keyed list using the key “stream_handle”.
#         * Program object  when –property parameter is “program” and –handle 
#           parameter has the value of a stream object handle. The program object can be 
#           extracted from the keyed list using the key “program_handle”.
#
# Synopsis:
#    ::ixia::L47_video_server
#         -mode                             CHOICES add remove modify enable 
#                                           disable
#         [-addr_incr                       ANY]
#         [-content                         ANY]
#         [-d_server_bit_rate               RANGE 0-200.0000]
#         [-d_server_tos_or_dscp            ANY]
#         [-dest_port_incr                  RANGE 0-2147483647]
#         [-duration                        RANGE 0-2147483]
#         [-enable_d_server_tos             CHOICES 0 1]
#         [-enable_esm                      CHOICES 0 1]
#         [-enable_tos_data                 CHOICES 0 1]
#         [-enable_tos_rtsp                 CHOICES 0 1]
#         [-esm                             RANGE 64-1460]
#         [-filename                        ANY]
#         [-handle                          ANY]
#         [-ip_bit_rate                     RANGE 0-200.0000]
#         [-iptv_multiport_enable           CHOICES 0]
#                                           CHOICES 1]
#         [-listen_port                     RANGE 1-65535]
#         [-mpeg_type                       ANY]
#         [-name                            ANY]
#         [-property                        CHOICES server
#                                           CHOICES agent
#                                           CHOICES videoList
#                                           CHOICES stream]
#         [-server_mode                     CHOICES 0]
#                                           CHOICES 1]
#         [-starting_dest_port              RANGE 0-65535]
#         [-starting_multicast_group_addr   ANY]
#         [-stream_count                    RANGE 1-2000]
#         [-transport                       CHOICES 1]
#                                           CHOICES 0]
#         [-tsperudp                        CHOICES 1]
#                                           CHOICES 2]
#                                           CHOICES 3]
#                                           CHOICES 4]
#                                           CHOICES 5]
#                                           CHOICES 6]
#                                           CHOICES 7]
#         [-type                            ANY]
#
# Arguments:
#    -mode
#       Defines types of actions to be taken on the –property object.
#       Choices:
#           * add – can be used with –property server | agent | videoList | 
#                   stream
#           * remove – can be used with –property server | agent | videoList | 
#                   stream
#           * enable – can be used with –property agent 
#           * disable –can be used with –property agent
#           * modify – can be used with –property server | agent | videoList | 
#                       stream
#       (DEFAULT = N/A)
#    -addr_incr
#        If more than one instance of the Broadcast channel will be streamed out
#         is greater than 1), this parameter specifies the amount of increase in
#        Type: optional
#        (DEFAULT= 0.0.0.1)
#        Dependencies: -property videoList | stream
#    -content
#        Type of payload carried by stream. The choices are:
#            * synthetic_payload - The payload is simulated MPEG 2 compressed
#         generated by the hlt video server. The file for the synthetic payload
#         a valid MPEG2 TS header but does not contain any MPEG2 PES packets.
#         the bit rate for the simulated video data in the ip_bit_rate parameter.
#            * real_payload The payload is an actual MPEG 2 compressed video.
#         the file containing the video data in the filename parameter. The file
#         be a valid MPEG2 SPTS, MPEG2 MPTS, MPEG4 Part2, MPEG4 Part10 (also
#        Type: optional
#        (DEFAULT= synthetic_payload)
#        Dependencies: -property stream
#    -d_server_bit_rate
#        If you are running the A and D server on different ports, configure the
#         rate for the D server’s stream with this option. The bit rate for the D
#        Type: optional
#        (DEFAULT= 3.75)
#        Dependencies: -property stream
#    -d_server_tos_or_dscp
#        If enable_d_server_tos is set to 1, you can set the Type of Service
#         bits that will be set in this stream from the A server, D Server and V
#         The value that is set here takes precedence over the setting agent
#            * Best Effort (0x0)
#            * Routine service.
#            * Class 1 (0x20) Priority service, Assured Forwarding class 1
#            * Class 2 (0x40) Immediate service, Assured Forwarding
#            * class 2
#            * Class 3 (0x60) Flash, Assured Forwarding class 3
#            * Class 4 (0x80) Flash-override, Assured Forwarding class 4
#            * Express Forwarding
#            * (0xA0)
#            * Critical-ecp
#            * Control (0xC0) Internet-control
#        Type: optional
#        (DEFAULT= “best _effort (0x0)”)
#        Dependencies: -property stream
#    -duration
#        If the stream type is VoD or D Server, this parameter specifies the
#        Type: optional
#        (DEFAULT= 0)
#        Dependencies: -property videoList | stream
#    -enable_d_server_tos
#        This enables the Type of Service (ToS) bits.
#        Type: optional
#        (DEFAULT= 0)
#        Dependencies: -property stream
#    -enable_esm
#        If 1, the use of the ESM option is enabled.
#        Type: optional
#        (DEFAULT= 0)
#        Dependencies: -property agent
#    -enable_tos_data
#        Enables the setting of the TOS (Type of Service) bits in the header of
#            * 0 (default) TOS bits not enabled.
#            * 1 TOS bits enabled.
#        Type: optional
#        (DEFAULT= 0)
#        Dependencies: -property agent
#    -enable_tos_rtsp
#        Enables the setting of the TOS (Type of Service) bits in the header of
#            * 0 (default) TOS bits not enabled.
#            * 1 TOS bits enabled.
#        Type: optional
#        (DEFAULT= 0)
#        Dependencies: -property agent
#    -esm
#        If enable_esm is true, the ESM value to negotiate with. (Default =
#        Type: optional
#        (DEFAULT= 1460)
#        Dependencies: -property agent
#    -filename
#        If content is set to real_payload, specify the name and path of the
#        Each load module type supports a different maximum file size. The
#         total of all the video files to be played cannot exceed the limits
#        Load Module 	Maximum Video File Size(per port)
#        CPM1000T8 	250MB
#        ALM (512MB) 	40MB
#        ALM (1GB)	80MB
#        STXS4-256 	20MB
#        STXS4-128 	10MB
#        10GE-LSM 	40MB divided by the number of streams
#        	(40MB / # of streams)
#        Type: optional
#        (DEFAULT= “”)
#        Dependencies: -property stream
#    -ip_bit_rate
#        If content is set to synthet_payload, specify the bit rate of the
#        Type: optional
#        (DEFAULT= 3.75)
#        Dependencies: -property stream
#    -iptv_multiport_enable
#        Indicates whether traffic from A and D server originates from the same
#        Type: optional
#        (DEFAULT= 0)
#        Dependencies: -property agent
#    -listen_port
#        Port that RTSP server listens on for new connections.
#        Type: optional
#        (DEFAULT= 554)
#        Dependencies: -property agent
#    -mpeg_type
#        MPEG version of video stream. Possible options are:
#        mpeg2_spts
#        mpeg2_mpts
#        mpeg4_part2
#        mpeg4_part10 (also known as H.264)
#        vc1
#        Type: optional
#        (DEFAULT= mpeg2)
#        Dependencies: -property stream
#    -server_mode
#        Sets the server mode to Video or IPTV.
#        Type: optional
#        (DEFAULT= 0)
#        Dependencies: -property agent
#    -starting_dest_port
#        For a Multicast channel, this field specifies the first port number
#        Type: optional
#        (DEFAULT= 0)
#        Dependencies: -property videoList | stream
#    -starting_multicast_group_addr
#        For a Multicast channel, this field specifies the address of the first
#        Type: optional
#        (DEFAULT= “”)
#        Dependencies: -property videoList | stream
#    -stream_count
#        If the video or IPTV A Server type is Multicast, this parameter
#         the number of instances of this stream that will be streamed out.
#        if the video or D Server type is VoD, this parameter specifies how many
#        Type: optional
#        (DEFAULT= 1)
#        Dependencies: -property videoList | stream
#    -transport
#        Transport protocol used to send the video stream to the client. This is
#        0 RTP over UDP.
#        1 (default) UDP.
#        Type: optional
#        (DEFAULT= 1)
#        Dependencies: -property stream
#    -tsperudp
#        Helps to configure the number of transport stream (TS) packets packaged
#        Type: optional
#        (DEFAULT= 7)
#        Dependencies: -property stream
#    -type
#        Type of the video stream. The choices are:
#            * Multicast Broadcast-type real-time video stream.
#            * VoD Video-on-Demand stream.
#        The choices for IPTV are:
#            * AD Server An A (Acquisition) server packages RTP streams into
#            * A D (Distribution) server caches a certain amount of the
#         video data being streamed over the network. When a user changes a
#         the D server sends a short unicast burst of the new channel’s video
#         for the user to view while the system switches the user from the
#            * V Server A V server provides Video-on-Demand service to an IPTV
#        Please note, that for a stream, which uses payloadfile containing
#        video or H264 video, the type has to be VoD. It cannot be Multicast.
#        Type: optional
#        (DEFAULT= N/A)
#        Dependencies: -property videoList | stream
#
# Return Values:
#        A Keyed List
#         Key                       value
#         ---                       -----
#         Status                    SUCCESS | FAILURE
#         Log                       Error message if command returns {status 0}
#         server_handle             when –property is “server”
#         agent_handle              when –property is “server” or “agent”
#         videoList_handle          when –property is “videoList”
#         stream_handle             when –property is “stream”
#         program_handle            when –property is “program”
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
#     Available statistic keys for Video and IPTV client
#     [Key: Name
#         Description]
#     Statistics can be added and collected using ::ixia::L47_stats procedure 
#    (please refer to HLT User Guide for a description of this procedure).
#     
#     video_total_streams_playing: Total Streams Playing 
#         Total number of video streams playing on the video server.
#     video_no_of_multicast_streams_playing: No of Multicast Streams Playing 
#         Number of multicast (broadcast-type) streams playing.
#     video_no_of_vod_streams: No of VoD Streams 
#         Active Number of video-on-demand streams active.
#     video_no_of_vod_streams_playing: No of VoD Streams Playing 
#         Number of video-on-demand streams playing.
#     video_no_of_vod_streams_paused: No of VoD Streams Paused 
#         Number of video-on-demand streams currently paused.
#     video_no_of_multicast_streams_played: No of Multicast Streams Played 
#         Number of multicast (broadcast-type) streams played.
#     video_no_of_vod_streams_played: No of VoD Streams Played 
#         Number of video-on-demand streams played.
#     video_total_streaming_bit_rate: Total Streaming Bit Rate 
#         Aggregate bit rate of all video streams playing on the server.
#     video_multicast_streams_bit_rate: Multicast Streams Bit Rate 
#         Bit rate of multicast (broadcast-type)video streams playing on the server.
#     video_vod_streams_bit_rate: VoD Streams Bit Rate 
#         Bit rate of video-on-demand videostreams playing on the server.
#     video_no_of_iptv_d_server_requests_received: No of IPTV D Server Requests Received
#         Number of requests received by the D server.
#     video_no_of_iptv_v_server_requests_received: No of IPTV V Server Requests Received
#         Number of requests received by the V server.
#     video_no_of_iptv_d_server_requests_successful: No of IPTV D Server Requests Successful
#         Number of requests received by the D server that were successful.
#     video_no_of_iptv_v_server_requests_successful: No of IPTV V Server Requests Successful
#         Number of requests received by the V server that were successful.
#     video_no_of_iptv_d_server_requests_failed: No of IPTV D Server Requests Failed 
#         Total number of requests received by the D server that failed for all reasons.
#     video_no_of_iptv_v_server_requests_failed: No of IPTV V Server Requests Failed 
#         Total number of requests received by the V server that failed for all reasons.
#     video_no_of_iptv_d_server_requests_failed_for_bandwidth: No of IPTV D Server Requests Failed for Bandwidth
#         Number of requests received by the D server that failed because not enough
#         bandwidth was available on the server.
#     video_no_of_iptv_v_server_requests_failed_for_bandwidth: No of IPTV V Server Requests Failed for Bandwidth
#         Number of requests received by the V server that failed because not enough
#         bandwidth was available on the server.
#     video_no_of_iptv_d_server_requests_failed_for_port_overload: No of IPTV D Server Requests Failed for Port Overload
#         Number of requests received by the D server that failed because the Ixia port
#         that the server was running on was oversubscribed.
#     video_no_of_iptv_v_server_requests_failed_for_port_overload: No of IPTV V Server Requests Failed for Port Overload
#         Number of requests received by the V server that failed because the Ixia port
#         that the server was running on was oversubscribed.
#     video_no_of_iptv_d_server_requests_failed_for_other_reasons: No of IPTV D Server Requests Failed for Other Reasons
#         Number of requests received by the D server that failed for reasons other
#         than lack of bandwidth or port overload.
#     video_no_of_iptv_v_server_requests_failed_for_other_reasons: No of IPTV V Server Requests Failed for Other Reasons
#         Number of requests received by the V server that failed for reasons other
#         than lack of bandwidth or port overload.
#     video_no_of_iptv_active_a_server_streams_playing: No of IPTV Active A Server Streams Playing
#         Number of streams available on the A server that are currently playing.
#     video_no_of_iptv_active_d_server_streams_playing: No of IPTV Active D Server Streams Playing
#         Number of streams available on the D server that are currently playing.
#     video_no_of_iptv_active_v_server_streams: No of IPTV Active V Server Streams 
#         Number of streams available on the V server.
#     video_no_of_iptv_active_v_server_streams_playing: No of IPTV Active V Server Streams Playing
#         Number of streams on the V server that are currently playing.
#     video_no_of_iptv_active_v_server_streams_paused: No of IPTV Active V Server Streams Paused
#         Number of streams on the V server that are currently paused.
#     video_a_server_streams_bit_rate: A Server Streams Bit Rate 
#         Combined bit rate of all streams currently playing on the A server.
#     video_d_server_streams_bit_rate: D Server Streams Bit Rate 
#         Combined bit rate of all streams currently playing on the D server.
#     video_v_server_streams_bit_rate: V Server Streams Bit Rate 
#         Combined bit rate of all streams currently playing on the V server.
#     video_iptv_total_streaming_bit_rate: IPTV Total Streaming Bit Rate 
#         Combined bit rate of all streams currently playing on the A, D, and V servers.
#     video_rtsp_presentations_received: RTSP Presentations Received 
#         Number of RTSP Presentation requests received by the servers.
#     video_rtsp_presentations_successful: RTSP Presentations Successful 
#         Number of RTSP Presentation requests that succeeded.
#     video_rtsp_presentations_failed: RTSP Presentations Failed 
#         Number of RTSP Presentation requests that failed.
#     video_rtsp_bytes_sent: RTSP Bytes Sent 
#         Number of RTSP-related bytes (commands and responses) sent by the server.
#     video_rtsp_bytes_received: RTSP Bytes Received 
#         Number of RTSP-related bytes (commands and responses) received by the server.
#     video_rtsp_packets_sent: RTSP Packets Sent 
#         Number of RTSP packets sent by the server.
#     video_rtsp_packets_received: RTSP Packets Received 
#         Number of RTSP packets received the server.
#     video_rtsp_play_latency_ms: RTSP Play Latency (ms) 
#         Average amount of time elapsed, in milliseconds, between the time the
#         server received a PLAY request and the time it transmitted the first byte of
#         the video stream.
#         Note for Tcl API users: This is a weighted statistic. If you are using this
#         statistic in a Tcl script, use the kWeightedAverage aggregation type.
#     video_rtsp_commands_received: RTSP Commands Received 
#         Total number of RTSP commands of all types received by the server.
#     video_rtsp_describe: RTSP DESCRIBE 
#         Received Total number of RTSP DESCRIBE commands received by the server.
#     video_rtsp_setup_received: RTSP SETUP Received 
#         Total number of RTSP SETUP commands received by the server.
#     video_rtsp_play_received: RTSP PLAY Received 
#         Total number of RTSP PLAY commands received by the server.
#     video_rtsp_pause_received: RTSP PAUSE Received 
#         Total number of RTSP PAUSE commands received by the server.
#     video_rtsp_teardown_received: RTSP TEARDOWN Received 
#         Total number of RTSP TEARDOWN commands received by the server.
#     video_rtsp_response_codes_sent_2xx: RTSP Response Codes Sent (2xx) 
#         Number of 200-range (Success) responses sent.
#         A 200-range response indicates that the action was successfully received, 
#         understood, and accepted.
#     video_rtsp_response_codes_sent_3xx: RTSP Response Codes Sent (3xx) 
#         Number of 300-range (Redirection) responses sent.
#         A 300-range response indicates that further action must be taken in order 
#         to complete the request.
#     video_rtsp_response_codes_sent_4xx: RTSP Response Codes Sent (4xx) 
#         Number of 400-range (Client Error) responses sent.
#         A 400-range response indicates that the request contains bad syntax or 
#         cannot be fulfilled.
#     video_rtsp_response_codes_sent_5xx: RTSP Response Codes Sent (5xx) 
#         Number of 500-range (Server Error) responses sent.
#         A 500-range response indicates that the server failed to fulfill an 
#         apparently valid request.
#     video_rtsp_response_codes_sent_6xx_1xxx: RTSP Response Codes Sent (6xx-1xxx)
#         Number of 600- to 1000-range responses sent.
#     video_total_bytes_sent: Total Bytes Sent 
#         Total bytes sent by the server.
#     video_total_packets_sent: Total Packets Sent 
#         Total packets sent by the server.
#     video_tx_jitter_ns: Tx Jitter (ns) 
#         Variation in packet transmission times, in nanoseconds.
#     video_tx_packets_dropped: Tx Packets Dropped 
#         Number of packets dropped before transmission.
#

proc ::ixia::L47_video_server { args } {
    variable executeOnTclServer
	
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
	
    variable temporary_fix_122311
    if {$::ixia::executeOnTclServer && $::ixia::temporary_fix_122311 == 0} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
            \{::ixia::L47_video_server $args\}]
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args

    set returnList [checkL47 VIDEO]
    if {[keylget returnList status] == $::FAILURE} {
        return $returnList
    }
    set mandatory_args {
            -mode        CHOICES add remove modify enable disable
    }


    set opt_args {
            -addr_incr    ANY
                      DEFAULT 0.0.0.1
        -content    ANY
                    DEFAULT synthetic_payload
        -d_server_bit_rate    RANGE 0-200.0000
                              DEFAULT 3.75
        -d_server_tos_or_dscp    ANY
                                 DEFAULT best_effort_0x0
        -dest_port_incr    RANGE 0-2147483647
                           DEFAULT 0
        -duration    RANGE 0-2147483
                     DEFAULT 0
        -enable_d_server_tos    CHOICES 0 1
                                DEFAULT 0
        -enable_esm    CHOICES 0 1
                       DEFAULT 0
        -enable_tos_data    CHOICES 0 1
                            DEFAULT 0
        -enable_tos_rtsp    CHOICES 0 1
                            DEFAULT 0
        -esm    RANGE 64-1460
                DEFAULT 1460
        -filename    ANY
        -handle    ANY
        -ip_bit_rate    RANGE 0-200.0000
                        DEFAULT 3.75
        -iptv_multiport_enable    CHOICES 0
                                  CHOICES 1
                                  DEFAULT 0
        -listen_port    RANGE 1-65535
                        DEFAULT 554
        -mpeg_type    ANY
                      DEFAULT na
        -name    ANY
        -property    CHOICES server
                     CHOICES agent
                     CHOICES videoList
                     CHOICES stream
                     DEFAULT agent
        -server_mode    CHOICES 0
                        CHOICES 1
                        DEFAULT 0
        -starting_dest_port    RANGE 0-65535
                               DEFAULT 0
        -starting_multicast_group_addr    ANY
        -stream_count    RANGE 1-2000
                         DEFAULT 1
        -transport    CHOICES 1
                      CHOICES 0
                      DEFAULT 1
        -tsperudp    CHOICES 1
                     CHOICES 2
                     CHOICES 3
                     CHOICES 4
                     CHOICES 5
                     CHOICES 6
                     CHOICES 7
                     DEFAULT 7
        -type    ANY
    }


    if {[catch  {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $mandatory_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }

    set target server
    if {$mode == "add"} {
        if {![info exists property]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -mode is $mode, then -property\
                    must be provided."
            return $returnList
        }

        if {($property != "server") && (![info exists handle])} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -property is $property, then -handle\
                    must be provided."
            return $returnList
        }
    } else  {
        ::ixia::removeDefaultOptionVars $opt_args $args

        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -mode is $mode, then -handle\
                    must be provided."
            return $returnList
        }
        if {![info exists property]} {
            set property [::ixia::ixL47GetProperty $handle video]
        }
    }

    # stream parameters
    set stream_option_list [list procName mode handle property target \
        stream_count duration tsperudp transport dest_port_incr mpeg_type d_server_bit_rate \
        addr_incr d_server_tos_or_dscp enable_d_server_tos starting_dest_port filename \
        ip_bit_rate name content type starting_multicast_group_addr ]
    set stream_args [list]

    lappend option_variables stream_option_list
    lappend option_variables stream_args

    # agent parameters
    set agent_option_list [list procName mode handle property target \
        enable_tos_rtsp enable_tos_data server_mode iptv_multiport_enable esm listen_port \
        enable_esm ]
    set agent_args [list]

    lappend option_variables agent_option_list
    lappend option_variables agent_args

    # videoList parameters
    set videoList_option_list [list procName mode handle property target \
        starting_multicast_group_addr stream_count type starting_dest_port duration \
        dest_port_incr name addr_incr ]
    set videoList_args [list]

    lappend option_variables videoList_option_list
    lappend option_variables videoList_args


    foreach {property_list property_args} $option_variables {
        set _o_list [set $property_list]
        foreach item $_o_list {
            if {[info exists $item]} {
                lappend $property_args "-$item"
                lappend $property_args "\"[set $item]\""
            }
        }
    }


    switch -- $property {
        stream {
            set returnList [eval [format "%s %s" ::ixia::ixL47VIDEOSERVERstream\
                $stream_args]]
            return $returnList
        }
        server -
        agent {
            set returnList [eval [format "%s %s" ::ixia::ixL47VIDEOSERVERagent\
                $agent_args]]
            return $returnList
        }
        videoList {
            set returnList [eval [format "%s %s" ::ixia::ixL47VIDEOSERVERvideoList\
                $videoList_args]]
            return $returnList
        }
        default {}
    }
}
