##Library Header
# $Id: $
# Copyright © 2003-2007 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_L47sip_api.tcl
#
# Purpose:
#
# Author:
#
# Usage:
#
# Description:
#    For testing SIP, HLT includes a SIP client and SIP server. The SIP client simulates
#     a caller with a softphone establishing sessions with a softphone-equipped
#     callee, which is simulated by the SIP server. Although in an actual SIP 
#     implementation, either party can initiate a call, in HLT, the client always 
#     initiates the call and the server always terminates it. The SIP client and 
#     server can simulate media traffic between a caller and callee by playing 
#     waveform audio files over the SIP session established between them.
#     To transport the waveform audio, the HLT  SIP client and server use RTP
#     (Real-time Transport Protocol).
#     Typically, SIP requests initially go through a proxy server. After a pair of SIP
#     user agents have received each others’ contact information, they can communicate
#     directly with each other, and no longer need the proxy server. This direct
#     end-to-end communication reduces the processing load on the proxy server.
#     However, there are scenarios in which it may be desirable for a proxy server
#     should continue to participate in a SIP call, and stay on the path for the URIs
#     between the user agents. For example, the proxy server may need to record call
#     detail for billing , or may be required for firewall control, which are important
#     network functions.
#     To force messages to be routed through it, a proxy server inserts a Record-Route
#     header field in the Request-URIs from the user agents. The Record-Route field
#     contains a globally reachable Request-URI that identifie s the proxy server.
#     Record-Route is described in the RFC 3261.
#     Two types of routing are available for SIP: strict routing and loose routing.
#         * Strict routing combines the request target with the next hop 
#           destination. Using strict routing, when a Request-URI arrives at a 
#           destination, its routing information must be re-written with the 
#           destination of the next hop. Strict routing implies that a 
#           Request-URI must visit the entire list of SIP nodes listed in the 
#           Route header, in order they are listed, and must not visit any other
#           nodes. Otherwise, the Request-URI may be considered to be in error.
#         * Loose routing separates the request target from the next hop 
#           destination. Loose routing implies that, before it can be delivered, 
#           the Request-URI must visit the SIP nodes listed in the Route header, 
#           but it may also visit other nodes before or afterwards. Support for 
#           loose routing is indicated by the "lr" parameter.
#     The IxLoad SIP client and server include support for both loose and strict 
#     routing.
#     Strict routing is defined in RFC 2543; loose routing is defined in RFC 3261.
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
#    ::ixia::L47_sip_client
#
# Description:
#    The ::ixia::L47_sip_client procedure is used to create and configure a 
#    traffic client.  A client performs protocol specific activities, which we 
#    will further refer to as agents. Even if a client is created using the 
#    ::ixia::L47_sip_client  procedure, other protocol agents can be attached 
#    to it using ::ixia::L47_<protocol>_client  procedure, by using 
#    "-property agent" "-mode add" "-handle <<the client handle>>".
#
# Synopsis:
#    ::ixia::L47_sip_client
#        -mode                             CHOICES add remove modify enable 
#                                          disable
#        [-b_advisable                     FLAG]
#        [-b_best_performance              CHOICES 0 1]
#        [-b_comp_ms                       CHOICES 0 1]
#        [-b_compact                       FLAG]
#        [-b_folding                       FLAG]
#        [-b_jit_ms                        CHOICES 0 1]
#        [-b_limit_dtmf                    FLAG]
#        [-b_modify_power_level            FLAG]
#        [-b_mos_on_max                    CHOICES 0 1]
#        [-b_next_on_fail                  FLAG]
#        [-b_optional                      FLAG]
#        [-b_recv5xx                       FLAG]
#        [-b_reg_before                    FLAG]
#        [-b_route                         FLAG]
#        [-b_rtp_start_collector           FLAG]
#        [-b_scattered                     FLAG]
#        [-b_silence_mode                  CHOICES 0 1]
#        [-b_use_compensation              FLAG]
#        [-b_use_dest                      FLAG]
#        [-b_use_jitter                    FLAG]
#        [-b_use_mos                       FLAG]
#        [-b_use_silence                   FLAG]
#        [-b_use_timer                     FLAG]
#        [-enable_tos_rtp                  FLAG]
#        [-enable_tos_sip                  FLAG]
#        [-handle                          ANY]
#        [-ms_n_dtmf_duration              RANGE 60-999]
#        [-ms_n_dtmf_interdigits           RANGE 30-9999]
#        [-ms_n_play_mode                  CHOICES 0 1]
#        [-ms_n_session_type               RANGE 10-2147483647]
#        [-ms_sz_codec_name                CHOICES g711alaw g711ulaw g729a
#                                          g729b g726 g723_1 amr i_lbc]
#        [-n_amplitude1                    RANGE -30-0]
#        [-n_amplitude2                    RANGE -30-0]
#        [-n_channels                      RANGE 10-2147483647]
#        [-n_comp_jitter_buffer            RANGE 0-300]
#        [-n_comp_jitter_ms                RANGE 0-3000]
#        [-n_comp_max_dropped              RANGE 1-100]
#        [-n_detect_time                   RANGE 1-2147483647]
#        [-n_detect_time_unit              CHOICES 0 1 2 3]
#        [-n_dtmf_amplitude                RANGE -30-0]
#        [-n_dtmf_count                    RANGE 1-2147483647]
#        [-n_dtmf_duration                 RANGE 10-990]
#        [-n_dtmf_interdigits              RANGE 10-9990]
#        [-n_dtmf_streams                  RANGE 1-900]
#        [-n_dtmfdetection_mode            CHOICES 0 1 2]
#        [-n_duration                      RANGE 10-2147483647]
#        [-n_first_dtmftimeout             RANGE 60-100000000]
#        [-n_frequency1                    RANGE 10-9999]
#        [-n_frequency2                    RANGE 10-9999]
#        [-n_inter_dtmfinterval            RANGE 30-100000000]
#        [-n_inter_mf_interval             RANGE 10-9990]
#        [-n_jitter_buffer                 RANGE 1-300]
#        [-n_jitter_ms                     RANGE 1-3000]
#        [-n_mf_amplitude                  RANGE -30-0]
#        [-n_mf_duration                   RANGE 10-990]
#        [-n_mos_interval                  RANGE 2-30]
#        [-n_mos_max_streams               RANGE 1-2147483647]
#        [-n_off_time                      RANGE 0-9990]
#        [-n_on_time                       RANGE 10-990]
#        [-n_pc_interval                   RANGE 1-2147483647]
#        [-n_peer_dtmf_duration            RANGE 10-2147483647]
#        [-n_peer_dtmf_interdigits         RANGE 10-2147483647]
#        [-n_play_mode                     CHOICES 0 1]
#        [-n_play_time                     RANGE 1-2147483647]
#        [-n_re_reg_duration               RANGE 0-60000]
#        [-n_repeat_count                  RANGE 1-2147483647]
#        [-n_repetition_count              RANGE 10-2147483647]
#        [-n_resolution                    RANGE 10-2147483647]
#        [-n_sample_rate                   RANGE 10-2147483647]
#        [-n_session_type                  CHOICES 0 1 2]
#        [-n_size                          RANGE 10-2147483647]
#        [-n_tcp_port                      RANGE 1-65535]
#        [-n_think_max                     RANGE 10-2147483647]
#        [-n_think_min                     RANGE 10-2147483647]
#        [-n_time_unit                     CHOICES 0 1 2 3]
#        [-n_timeout                       RANGE 10-2147483647]
#        [-n_timers_t1                     RANGE 10-2147483647]
#        [-n_timers_t2                     RANGE 10-2147483647]
#        [-n_timers_t4                     RANGE 10-2147483647]
#        [-n_timers_tc                     RANGE 10-2147483647]
#        [-n_timers_td                     RANGE 10-2147483647]
#        [-n_tone_duration                 RANGE 10-990]
#        [-n_tone_name                     CHOICES 0 1 2 3 4 5 6 7 8 9 10
#                                          11 12 13 14 15 16 17 -1]
#        [-n_tone_type                     CHOICES 0 1 2 3]
#        [-n_total_time                    RANGE 10-2147483647]
#        [-n_udp_max_size                  RANGE 1024-4000]
#        [-n_udp_port                      RANGE 1-65535]
#        [-n_wav_duration                  RANGE 10-2147483647]
#        [-property                        CHOICES client agent  rulesTable ]
#                                          audioClipsTable scenarios]
#        [-scenarios_id                    CHOICES REGISTRATION]
#                                          CHOICES ORIGINATECALL THINK]
#                                          CHOICES ENDCALL REDIRECTION]
#                                          CHOICES VOICESESSION MEDIASESSION]
#                                          CHOICES GENERATEDTMF GENERATEMF]
#                                          CHOICES GENERATETONE DETECTDTMF]
#        [-sym_destination                 ANY]
#        [-synth_video                     FLAG]
#        [-sz_action                       ANY]
#        [-sz_audio_file                   ANY]
#        [-sz_auth_domain                  ANY]
#        [-sz_auth_password                ANY]
#        [-sz_auth_username                ANY]
#        [-sz_bit_rate                     ANY]
#        [-sz_codec_descr                  ANY]
#        [-sz_codec_details                ANY]
#        [-sz_codec_name                   ANY]
#        [-sz_contact                      ANY]
#        [-sz_data_format                  ANY]
#        [-sz_destination                  REGEXP ^(((25[0-5]|2[0-4]\d|[0-
#                                          1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?
#                                          \d?\d)){3})|(\[(?![fF]{2}[0-9a-fA-F]
#                                          {2}:)(((?:[0-9a-fA-F]{1,4}:){7}
#                                          [0-9a-fA-F]{1,4})|(((?:[0-9A-Fa-f]
#                                          {1,4}(?::[0-9A-Fa-f]{1,4})*)?)::
#                                          ((?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]
#                                          {1,4})*)?))|(((?:[0-9A-Fa-f]{1,4}:)
#                                          {6,6})(25[0-5]|2[0-4]\d|[0-1]?\d?\d)
#                                          (\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d))
#                                          {3})|(((?:[0-9A-Fa-f]{1,4}
#                                          (?::[0-9A-Fa-f]{1,4})*)?) ::
#                                          ((?:[0-9A-Fa-f]{1,4}:)*)(25[0-5]|
#                                          2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2
#                                          [0-4]\d|[0-1]?\d?\d)){3})))\]):
#                                          ([1-9]\d{0,3}|[1-5]\d{4}|6[0-4]\d
#                                          {3}|65[0-4]\d\d|655[012]\d|6553[0-5])$]
#        [-sz_dtmf_seq                     REGEXP ^[0-9a-dA-D#*]+$]
#        [-sz_from                         ANY]
#        [-sz_message                      CHOICES register]
#        [-sz_mf_seq                       REGEXP ^[0-9a-cA-C#*]+$]
#        [-sz_peer_codec_details           ANY]
#        [-sz_peer_codec_name              ANY]
#        [-sz_peer_dtmf_seq                ANY]
#        [-sz_power_level                  CHOICES pl_20 pl_30]
#        [-sz_raw_wave_name                ANY]
#        [-sz_registrar                    REGEXP ^(|((((25[0-5]|2[0-4]\d|[0-1]
#                                          ?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]
#                                          ?\d?\d)){3})|(\[(?![fF]{2}[0-9a-fA-F]{2}:)
#                                          (((?:[0-9a-fA-F]{1,4}:){7}
#                                          [0-9a-fA-F]{1,4})|(((?:[0-9A-Fa-f]
#                                          {1,4}(?::[0-9A-Fa-f]{1,4})*)?)::
#                                          ((?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]
#                                          {1,4})*)?))|(((?:[0-9A-Fa-f]{1,4}:)
#                                          {6,6})(25[0-5]|2[0-4]\d|[0-1]?\d?\d)
#                                          (\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3})
#                                          |(((?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]
#                                          {1,4})*)?) ::((?:[0-9A-Fa-f]{1,4}:)*)
#                                          (25[0-5]|2[0-4]\d|[0-1]?\d?\d)
#                                          (\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d))
#                                          {3})))\]):([1-9]\d{0,3}|[1-5]\d{4}
#                                          |6[0-4]\d{3}|65[0-4]\d\d|655[012]
#                                          \d|6553[0-5])))$]
#        [-sz_requesturi                   ANY]
#        [-sz_route                        ANY]
#        [-sz_to                           ANY]
#        [-sz_total_time                   ANY]
#        [-sz_transport                    CHOICES udp tcp only_udp only_tcp]
#        [-sz_value                        ANY]
#        [-sz_wave_name                    ANY]
#        [-type_of_service_for_rtp         ANY]
#        [-type_of_service_for_sip         ANY]
#        [-video_bitrate                   RANGE 64-1000]
#        [-video_bitrate_limit             RANGE 10-2147483647]
#        [-vs_n_play_mode                  CHOICES 0 1]
#
# Arguments:
#    -mode
#        Defines types of actions to be taken on the –property object.
#        Choices:
#           * add – can be used with –property client | agent | rulesTable | 
#                   audioClipsTable | scenarios 
#           * remove – can be used with –property client | agent | rulesTable | 
#                   audioClipsTable | scenarios 
#           * enable – can be used with –property agent 
#           * disable –can be used with –property agent
#           * modify – can be used with –property client | agent | rulesTable | 
#                       audioClipsTable | scenarios
#        (DEFAULT = N/A)
#    -b_advisable
#        If 1, the SIP request includes the header fields that are defined as
#        ‘mandatory’ by the SIP RFC (RFC 3261), plus those that are recommended 
#        as advisable.’
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_best_performance
#        If 1, HLT inserts the headers into the message so that the message can 
#        be processed as quickly as possible by the receiving system. 
#        If 0, HLT inserts the headers into the message so that it requires 
#        maximum processing by the receiving system.
#        (DEFAULT = 1)
#        Dependencies: -property agent
#    -b_comp_ms
#        Defines the method used to set the compensation jitter buffer size.
#        0 (Default). Compensation jitter buffer size is set by n_comp_jitter_buffer.
#        1 Compensation jitter buffer size is set by n_comp_jitter_ms.
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_compact
#        If 1, HLT uses the compact forms of the SIP header field notations.
#        The compact form is intended for instances in which messages would 
#        otherwise become too large to be carried on the transport available to 
#        it (exceeding the maximum transmission unit [MTU] when using UDP, for example).
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_folding
#        If 1, the VIA field spans two lines. Some SIP devices many not be able to 
#        handle this.
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_jit_ms
#        Defines the method used to set the jitter buffer size.
#        0 (Default). Jitter buffer size is set by n_jitter_buffer.
#        1 Jitter buffer size is set by n_jitter_ms.
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_limit_dtmf
#        Enable or disable limitation on the number of DTMF streams to be processed.
#        0 DTMF applied to all streams.
#        1 (Default) DTMF limited to number of streams specified by n_dtmf_streams.
#        (DEFAULT = 1)
#        Dependencies: -property agent
#    -b_modify_power_level
#        If 1, HLT modifies the volume of the compressed audio.
#        (DEFAULT = 0)
#        Order Dependent: N/A
#        Dependencies: -property agent
#    -b_mos_on_max
#        Defines types of actions to be taken on the –property object.
#        Defines whether MOS is calculated for a subset of streams or for all streams.
#        0 (Default). MOS calculation is applied to all streams.
#        1 MOS calculation is applied to the number of streams specified by n_mos_max_streams.
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_next_on_fail
#        Description:
#        If 1 and HLT encounters a transaction failure, it continues processing SIP
#        requests. If 0 and HLT encounters a transaction failure, it stops processing
#        SIP requests.
#        (DEFAULT = 1)
#        Dependencies: -property agent
#    -b_optional
#        If 1, the SIP request includes the header fields that are defined as 
#        ‘mandatory’ by the SIP RFC (RFC 3261), plus those that are listed as ‘optional.’
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_recv5xx
#        If 1 and HLT receives a 5xx series response to a transaction, HLT marks
#        it as a failed transaction, and increments the transaction failure statistics.
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_reg_before
#        If 1, before starting the Originate Call/EnCall --> Receive call process, 
#        the HLT SIP client registers with the proxy server. Registration occurs only once at the beginning of the test.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_route
#        If 1, HLT inserts a Route header field into the SIP message. The route 
#        should contain a list of specified proxies. Use the sz_route parameter to specify the route.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_rtp_start_collector
#        Specifies, whether the statistics for rtp should be collected or not. 
#        Possible values
#        are:
#        0 Do not start
#        1 Start
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_scattered
#        Description:
#        If 1, HLT moves the header fields around in the message in order to 
#        make it more difficult for the DUT to decode the message.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_silence_mode
#        Description:
#        Indicates the method used to generate the background noise. Possible 
#        Values are:
#        "0" Comfort Noise silence type.
#        "1" Null Data encoded silence type.
#        (DEFAULT = 1)
#        Dependencies: -property agent
#    -b_use_compensation
#        Description:
#        Enables or disables use of the compensation jitter buffer.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_use_dest
#        If 1, the registration is sent to the address specified by sz_destination. 
#        If 0, the registration is sent to the Registrar configured by the 
#        General Settings command.
#        Type: optional
#        (DEFAULT = 1)
#        Dependencies: -property scenarios; -scenarios_id REGISTRATION
#    -b_use_jitter
#        Enables or disables use of the jitter buffer.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_use_mos
#        Enables or disables use of MOS.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_use_silence
#        If enabled, HLT generates and sends artificial background noise during 
#        times of silence during a call.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_use_timer
#        If 1, HLT enforces a timeout limit on transactions. If a transaction 
#        exceeds the timeout value, HLT marks it as a failed transaction, and 
#        increments the transaction failure statistics.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -enable_tos_rtp
#        Enables the setting of the TOS (Type of Service) bits in the header 
#        of the RTP data packets.
#        0 (default) TOS bits not enabled.
#        1 TOS bits enabled.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -enable_tos_sip
#        Enables the setting of the TOS (Type of Service) bits in the header 
#        of the SIP packets.
#        0 (default) TOS bits not enabled.
#        1 TOS bits enabled.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -handle
#        Type: optional
#        (DEFAULT = N/A)
#        Dependencies:
#    -ms_n_dtmf_duration
#        Length of time allowed to play the DTMF sequence. Minimum = "60," 
#        maximum = "999."
#        Type: optional
#        (DEFAULT = 100)
#        Dependencies: -property agent
#    -ms_n_dtmf_interdigits
#        Duration (in milliseconds) of the DTMF interdigit signal. 
#        Minimum = "30," maximum = "9999."
#        Type: optional
#        (DEFAULT = 40)
#        Dependencies: -property agent
#    -ms_n_play_mode
#        If 1, the audio file plays for a fixed number of times. If 0, 
#        the audio file plays continuously.
#        Type: optional
#        (DEFAULT = 1)
#        Dependencies: -property scenarios; -scenarios_id MEDIASESSION
#    -ms_n_session_type
#        Type of voice session. The choices are:
#        "0" (default) Plays audio file specified by sz_audio_fIle.
#        "1" Perform DTMF path confirmation.
#        "2" Perform synthetic DTMF path confirmation.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -ms_sz_codec_name
#        Codec to be used to encode waveform audio files listed in the 
#        Audio Clips Pool.
#        The choices are:
#        "g711alaw" (default) G.711 A-law
#        "g711ulaw" G.711 mu-law
#        "g729a" G.729A
#        "g729b" G.729B
#        "g726" G.726
#        "g723_1" G.723.1
#        "amr"
#        "i_lbc"
#        Type: optional
#        (DEFAULT = g711alaw)
#        Order Dependent: N/A
#        Dependencies: -property agent
#    -n_amplitude1
#        Amplitude of the nFrequency1 signal.
#        Type: optional
#        (DEFAULT = -10)
#        Dependencies: -property scenarios; scenarios_id GENERATETONE
#    -n_amplitude2
#        Amplitude of the nFrequency2 signal.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property scenarios; scenarios_id GENERATETONE
#    -n_channels
#        Number of audio channels: "0" = mono, "1" = stereo. (Default = "0").
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property audioClipsTable
#    -n_comp_jitter_buffer
#        Compensation jitter buffer maximum size, in packets. Minimum = "0," 
#        maximum = "300."
#        Type: optional
#        (DEFAULT = 50)
#        Dependencies: -property agent
#    -n_comp_jitter_ms
#        Compensation jitter buffer maximum size, in milliseconds. 
#        Minimum = "0,"maximum = "3,000."
#        Type: optional
#        (DEFAULT = 1000)
#        Dependencies: -property agent
#    -n_comp_max_dropped
#        Maximum dropped consecutive packets. Minimum = "1," maximum = "100,"
#        Type: optional
#        (DEFAULT = 7)
#        Dependencies: -property agent
#    -n_detect_time
#        The number of time units to sustain the detect operation.
#        Type: optional
#        (DEFAULT = 10)
#        Dependencies: -property scenarios; scenarios_id DETECTDTMF
#    -n_detect_time_unit
#        Signifies the time unit type. Possible values are:
#        "0" (default) Seconds
#        "1" Minutes
#        "2" Hours
#        "3" Days
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property scenarios; scenarios_id DETECTDTMF
#    -n_dtmf_amplitude
#        The signal amplitude generated for the stream containing the digits.
#        Type: optional
#        (DEFAULT = -10)
#        Dependencies: -property scenarios; scenarios_id GENERATEDTMF
#    -n_dtmf_count
#        The exact number of digits to detect.
#        Type: optional
#        (DEFAULT = 6)
#        Dependencies: -property scenarios; scenarios_id DETECTDTMF
#    -n_dtmf_duration
#        Length of time allowed to play the DTMF sequence. Minimum = "60,
#        " maximum = "999."
#        Type: optional
#        (DEFAULT = 100)
#        Dependencies: -property scenarios; scenarios_id GENERATEDTMF
#    -n_dtmf_interdigits
#        Duration (in milliseconds) of the DTMF interdigit signal. 
#        Minimum = "30," maximum = "9999."
#        Type: optional
#        (DEFAULT = 40)
#        Dependencies: -property scenarios; scenarios_id GENERATEDTMF
#    -n_dtmf_streams
#        Number of streams to which path confirmation will be applied. 
#        Minimum = "1," maximum = "900."
#        Type: optional
#        (DEFAULT = 10)
#        Dependencies: -property agent
#    -n_dtmfdetection_mode
#        Method used to detect tones. Possible values are:
#        0 detect continously for a specified time
#        1 detect exactly a specified numebr of digits
#        2 detect a specified sequence
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property scenarios; -scenarios_id DETECTDTMF
#    -n_duration
#        Playing time of audio file.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property audioClipsTable
#    -n_first_dtmftimeout
#        The maximmum time for the first digit to arrive and to be decoded.
#        Type: optional
#        (DEFAULT = 2000)
#        Dependencies: -property scenarios; -scenarios_id DETECTDTMF
#    -n_frequency1
#        For a single tone, this is the frequency of the signal used to 
#        generate the tone. For a dual tone, this is the frequency of the signal 
#        used to generate the lower band of the tone.
#        Type: optional
#        (DEFAULT = 615)
#        Dependencies: -property scenarios; -scenarios_id GENERATETONE
#    -n_frequency2
#        For a dual tone, this is the frequency of the signal used to 
#        generate the upper band of the tone.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property scenarios; -scenarios_id GENERATETONE
#    -n_inter_dtmfinterval
#        The maximum time between the arrival of digits.
#        Type: optional
#        (DEFAULT = 1000)
#        Dependencies: -property scenarios; -scenarios_id DETECTDTMF
#    -n_inter_mf_interval
#        Duration (in milliseconds) of the MF interdigit signal. Minimum = "10", 
#        Maximum = "9990".
#        Type: optional
#        (DEFAULT = 40)
#        Dependencies: -property scenarios; -scenarios_id GENERATEMF
#    -n_jitter_buffer
#        Duration (in milliseconds) of the MF interdigit signal. Minimum = "10", 
#        Maximum = "9990".
#        Type: optional
#        (DEFAULT = 1)
#        Dependencies: -property agent
#    -n_jitter_ms
#        Jitter Buffer size, in milliseconds. Minimum = "1," maximum = "3,000."
#        Type: optional
#        (DEFAULT = 20)
#        Dependencies: -property agent
#    -n_mf_amplitude
#        The amplitude of the signal generated by the sending sequence. 
#        Minimum = "- 30", Maximum = "-10".
#        Type: optional
#        (DEFAULT = -10)
#        Dependencies: -property scenarios; -scenarios_id GENERATEMF
#    -n_mf_duration
#        Length of time allowed to play the MF sequence. Minimum = "10", 
#        Maximum = "990".
#        Type: optional
#        (DEFAULT = 200)
#        Dependencies: -property scenarios; -scenarios_id GENERATEMF
#    -n_mos_interval
#        Frequency at which IxLoad samples the RTP streams to generate the 
#        MOS scores. Minimum = "2," maximum = "30."
#        Type: optional
#        (DEFAULT = 3)
#        Dependencies: -property agent
#    -n_mos_max_streams
#        Maximum number of concurrent streams used in MOS calculation. 
#        Minimum = "1."
#        Type: optional
#        (DEFAULT = 1)
#        Dependencies: -property agent
#    -n_off_time
#        For a cadenced tone, this is the amount of time the tone signal 
#        or signals are muted.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property scenarios; -scenarios_id GENERATETONE
#    -n_on_time
#        For a cadenced tone, this is the amount of time the tone signal or 
#        signals are played.
#        Type: optional
#        (DEFAULT = 100)
#        Dependencies: -property scenarios; -scenarios_id GENERATETONE
#    -n_pc_interval
#        If Synthetic path confirmation is selected, this is the interval at 
#        which HLT add the synthetic RTP packets to the stream. Minimum = "1,"
#        Type: optional
#        (DEFAULT = 500)
#        Dependencies: -property agent
#    -n_peer_dtmf_duration
#        DTMF duration used by peer.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -n_peer_dtmf_interdigits
#        Inter-digits interval used by peer.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -n_play_mode
#        The play mode to play the MF tones. Possible values are:
#        0 Generate for a specified period of time
#        1 Repeat for a specified number of times
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent; -scenarios_id GENERATETONE | GENERATEMF | 
#        GENERATEDTMF
#    -n_play_time
#        The time units to play the specified sequence.
#        Type: optional
#        (DEFAULT = 30)
#        Dependencies: -property scenarios; -scenarios_id GENERATETONE | 
#        GENERATEMF | GENERATEDTMF
#    -n_re_reg_duration
#        In the event that HLT fails to register with a registrar, this field 
#        defines the amount of time allowed to re-registration. Minimum = "0,"
#         maximum = "60,000."
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -n_repeat_count
#        If n_play_mode is true, this parameter sets the number of times 
#        that the audio file will play.
#        Type: optional
#        (DEFAULT = 1)
#        Dependencies: -property scenarios; -scenarios_id GENERATETONE | 
#        GENERATEMF | GENERATEDTMF | VOICESESSION | MEDIASESSION | 
#    -n_repetition_count
#        For a cadenced tone, this specifies the number of times that the 
#        On Time / Off Time cycle is repeated.
#        Type: optional
#        (DEFAULT = 1)
#        Dependencies: -property scenarios; -scenarios_id GENERATETONE
#    -n_resolution
#        Number of bits per sample.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property audioClipsTable
#    -n_sample_rate
#        Number of samples taken per second from the recording source.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property audioClipsTable
#    -n_session_type
#        Type of voice session. The choices are:
#        "0" (default) Plays audio file specified by sz_audio_fIle.
#        "1" Perform DTMF path confirmation.
#        "2" Perform synthetic DTMF path confirmation.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property scenarios; -scenarios_id VOICESESSION
#    -n_size
#        Size of audio file, in bytes.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property audioClipsTable
#    -n_tcp_port
#        Port number to be used for sending and receiving SIP messages over TCP. 
#        Minimum = "1," maximum = "65,535."
#        Type: optional
#        (DEFAULT = 5060)
#        Dependencies: -property agent
#    -n_think_max
#        Maximum length of the pause, in milliseconds. To configure a 
#        fixed-length pause, enter the same value in this field and n_think_min.
#        Type: optional
#        (DEFAULT = 1000)
#        Dependencies: -property scenarios; -scenarios_id THINK
#    -n_think_min
#        Minimum length of the pause, in milliseconds. To configure a 
#        fixed-length pause, enter the same value in this field and n_think_max.
#        Type: optional
#        (DEFAULT = 1000)
#        Dependencies: -property scenarios; -scenarios_id THINK
#    -n_time_unit
#        Units of time used to set the audio file play time (n_play_time). 
#        The choices are:
#        "0" (default) Seconds
#        "1" Minutes
#        "2" Hours
#        "3" Days
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property scenarios; -scenarios_id GENERATETONE | 
#        GENERATEMF | VOICESESSION | MEDIASESSION | GENERATEDTMF
#    -n_timeout
#        If b_use_timer is 1, this parameter specifies the transaction timeout 
#        interval, in in milliseconds (ms).
#        Type: optional
#        (DEFAULT = 30000)
#        Dependencies: -property agent
#    -n_timers_t1
#        Estimate of the round-trip time (RTT), in milliseconds (ms).
#        Type: optional
#        (DEFAULT = 500)
#        Dependencies: -property agent
#    -n_timers_t2
#        Maximum retransmit interval, in milliseconds (ms), for non-INVITE 
#        requests and INVITE responses.
#        Type: optional
#        (DEFAULT = 4000)
#        Dependencies: -property agent
#    -n_timers_t4
#        Maximum length of time, in milliseconds (ms), that a message will 
#        remain in the network.
#        Type: optional
#        (DEFAULT = 5000)
#        Dependencies: -property agent
#    -n_timers_tc
#        Proxy INVITE transaction timeout. Minimum = 180,000.
#        Type: optional
#        (DEFAULT = 180000)
#        Dependencies: -property agent
#    -n_timers_td
#        Wait time for response retransmits. For UDP, this must be greater 
#        than 32 seconds.
#        Type: optional
#        (DEFAULT = 32000)
#        Dependencies: -property agent
#    -n_tone_duration
#        The duration of a tone with only one frequency.
#        Type: optional
#        (DEFAULT = 100)
#        Dependencies: -property scenarios; -scenarios_id GENERATETONE
#    -n_tone_name
#        This is the id for the tone. Possible values are:
#        0 "600-10"
#        1 "1400-10"
#        2 "2500-10"
#        3 "550-20"
#        4 "1350-20"
#        5 "2450-20"
#        6 "650-30"
#        7 "2550-30"
#        8 "1450-30"
#        9 "3400-10"
#        10 "3400-30"
#        11 "2100-10"
#        12 "2150-30"
#        13 "400-10"
#        14 "450-30"
#        15 "Confirmation Tone"
#        16 "Call Waiting Tone"
#        17 "TN_1"
#        -1 "Custom Tone"
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property scenarios; -scenarios_id GENERATETONE
#    -n_tone_type
#        The format of the tone. Possible values:
#        0 "Single Tone"
#        1 "Dual Tone"
#        2 "Single Tone Cadence"
#        3 "Dual Tone Cadence"
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property scenarios; -scenarios_id GENERATETONE
#    -n_total_time
#        The total time for which an .wav file will be played.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property scenarios; -scenarios_id GENERATETONE | 
#        GENERATEMF | VOICESESSION | MEDIASESSION | GENERATEDTMF
#    -n_udp_max_size
#        Maximum size, in Kb, of a SIP message that will be sent. If a message 
#        exceeds this size, HLT ignores it.
#        Type: optional
#        (DEFAULT = 1024)
#        Dependencies: -property agent
#    -n_udp_port
#        Port number to be used for sending and receiving SIP messages over 
#        UDP. Minimum = "1," maximum = "65,535."
#        Type: optional
#        (DEFAULT = 5060)
#        Dependencies: -property agent
#    -n_wav_duration
#        The time duration of a wave.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property scenarios; -scenarios_id VOICESESSION | 
#        MEDIASESSION
#    -property
#        Types of objects that this procedure can configure. Valid values are:
#        client
#        agent
#        rulesTable
#        audioClipsTable
#        scenarios
#        Type: optional
#        (DEFAULT = agent)
#        Dependencies: N/A
#    -scenarios_id
#        When –property is ‘scenarios’, this parameter determines what type 
#        of scenario will be generated.
#        REGISTRATION
#        ORIGINATECALL
#        THINK
#        ENDCALL
#        REDIRECTION
#        VOICESESSION
#        MEDIASESSION
#        GENERATEDTMF
#        CHOICES GENERATEMF
#        GENERATETONE
#        DETECTDTMF
#        Type: optional
#        (DEFAULT = N/A)
#        Dependencies: -property scenarios
#    -sym_destination
#        Destination of the call. If the destination is an external host, 
#        specify its address or
#        host name and port number. If the destination is an HLT SIP server agent,
#        specify the name of the agent. This option also accepts IPV6 addresses 
#        that are enclosed in square brackets.
#        Type: optional
#        (DEFAULT = "none")
#        Dependencies: -property scenarios; -scenarios_id ORIGINATECALL
#    -synth_video
#        If enabled, the SIP client generates video data and transmits it to the 
#        server along with the audio to simulate a video phone call.
#        Type: optional
#        (DEFAULT = 1)
#        Dependencies: -property scenarios; -scenarios_id MEDIASESSION
#    -sz_action
#        Action the rule performs.
#        Type: optional
#        (DEFAULT = "")
#        Dependencies: -property rulesTable
#    -sz_audio_file
#        Waveform audio file that will be played during the session. This must 
#        be an sz_wave_name object contained within the Audio Clips Pool object.
#        Type: optional
#        (DEFAULT = <_none>)
#        Dependencies: -property scenarios; -scenarios_id VOICESESSION | 
#        MEDIASESSION
#    -sz_auth_domain
#        Domain to be registered with registrar. Maximum length = 128 characters.
#        Type: optional
#        (DEFAULT = domain[0000_])
#        Dependencies: -property agent
#    -sz_auth_password
#        Password to be registered with registrar. Maximum length = 128 characters.
#        Type: optional
#        (DEFAULT = password[0000_])
#        Dependencies: -property agent
#    -sz_auth_username
#        User name to be registered with registrar. Maximum length = 128 characters.
#        Type: optional
#        (DEFAULT = user[0000_])
#        Dependencies: -property agent
#    -sz_bit_rate
#        This specifies the bit rate of the codec being used. Possible values are:
#        Codec     Bit Rate
#        g711alaw    64 kbps
#        g711ulaw    64 kbps
#        g723_1    5.3 kbps
#        6.3 kbps
#        g726    40 kbps
#        g729a    8 kbps
#        g729b    8 kbps
#        amr    4.75 kbps
#        5.15 kbps
#        5.9 kbps
#        6.7 kbps
#        7.4 kbps
#        7.95 kbps
#        10.2 kbps
#        12.2 kbps
#        i_lbc    13.33 kbps
#        15.2 kbps
#        Type: optional
#        (DEFAULT = "")
#        Dependencies: -property agent
#    -sz_codec_descr
#        Codec description.
#        Type: optional
#        (DEFAULT = "")
#        Dependencies: -property agent
#    -sz_codec_details
#        Displays the properties of the codec such as the number of bytes per 
#        frame of compressed audio, and the rate at which packets are sent over the 
#        connection.
#        sz_codec_details has a special format: BFval1PTval2, where:
#        "val1"    Number of codec bytes per frame (only the rtp payload; do 
#        not add the 12 bytes for the rtp header)
#        "val2"     The packet time
#        Type: optional
#        (DEFAULT = "")
#        Dependencies: -property agent | -property scenarios; -scenarios_id 
#        GENERATETONE | GENERATEMF | GENERATEDTMF
#    -sz_codec_name
#        Codec to be used to encode waveform audio files listed in the Audio Clips Pool.
#        Type: optional
#        (DEFAULT = "")
#        Dependencies: -property scenarios; -scenarios_id GENERATETONE | 
#        GENERATEMF | GENERATEDTMF 
#    -sz_contact
#        The Contact header field value provides a URI whose meaning depends on the
#        type of request or response it is in.The Contact header field has a role similar to
#        the Location header field in HTTP. You can include variables in this field to 
#        automatically generate large numbers of unique domains. 
#        Maximum length = 128 characters. This option also accepts IPV6 addresses 
#        that are enclosed in square brackets.
#        Type: optional
#        (DEFAULT = <sip:id[00000_]@_ip>)
#        Dependencies: -property agent
#    -sz_data_format
#        Encoding format of waveform audio file.
#        Type: optional
#        (DEFAULT = "...")
#        Dependencies: -property audioClipsTable
#    -sz_destination
#        Registrar that the registration will be sent to. This option also 
#        accepts IPV6 addresses that are enclosed in square brackets.
#        Type: optional
#        (DEFAULT = "127.0.0.1:5060")
#        Dependencies: -property scenarios; -scenarios_id REGISTRATION | 
#        REDIRECTION
#    -sz_dtmf_seq
#        The dtmf sequence to be generated.
#        Type: optional
#        (DEFAULT = 12345)
#        Dependencies: -property agent | -property scenarios; -scenarios_id 
#        DETECTDTMF 
#        GENERATEDTMF
#    -sz_from
#        Initiator of the SIP request. You can include variables in this field to 
#        automatically
#        generate large numbers of unique domains. Maximum length = 128 characters. 
#        This option also accepts IPV6 addresses that are enclosed in square brackets.
#        Type: optional
#        (DEFAULT = <sip:id[00000_]@_ip>)
#        Dependencies: -property agent
#    -sz_message
#        Type of message the rule will apply to. (Default = "REGISTER"). See sz_action
#        for the list of messages that you can configure rules for.
#        Type: optional
#        (DEFAULT = register)
#        Dependencies: -property rulesTable
#    -sz_mf_seq
#        The sequence of MF digits to be generated.
#        Type: optional
#        (DEFAULT = 12345)
#        Dependencies: -property scenarios; -scenarios_id GENERATEMF
#    -sz_peer_codec_details
#        Details of codec used by peer.
#        Type: optional
#        (DEFAULT = "")
#        Dependencies: -property agent
#    -sz_peer_codec_name
#        Name of codec used by peer.
#        Type: optional
#        (DEFAULT = "")
#        Dependencies: -property agent
#    -sz_peer_dtmf_seq
#        DTMF sequence used by peer.
#        Type: optional
#        (DEFAULT = "")
#        Dependencies: -property agent
#    -sz_power_level
#        If b_modify_power_level is 1, this parameter specifies the amount of gain (volume)
#        added to compressed audio. The choices are:
#        "PL_20" -20 dB
#        "PL_30" -30 dB
#        Type: optional
#        (DEFAULT = pl_20)
#        Dependencies: -property agent
#    -sz_raw_wave_name
#        Name and path of wave file to be added to the list.
#        Type: optional
#        (DEFAULT = "")
#        Dependencies: -property audioClipsTable
#    -sz_registrar
#        Host name or IP address and port number of registrar. This option also accepts
#        IPV6 addresses that are enclosed in square brackets.
#        Type: optional
#        (DEFAULT = "127.0.0.1:5060")
#        Dependencies: -property agent
#    -sz_requesturi
#        User or service to which the SIP request is being addressed. You can include variables
#        in this field to automatically generate large numbers of unique domains.
#        Maximum length = 128 characters.
#        This option also accepts IPV6 addresses that are enclosed in square brackets.
#        Type: optional
#        (DEFAULT = sip:id[50000_]@_ip)
#        Dependencies: -property agent
#    -sz_route
#        If b_route is 1, this parameter specifies the Route header field used to force the
#        request to follow a fixed route through a listed set of proxies.
#        Type: optional
#        (DEFAULT = "route: <sip:p1.example.com;lr>,<sip:p2.domain.com;lr>")
#        Dependencies: -property agent
#    -sz_to
#        Logical recipient of the request. You can include variables in this 
#        field to automatically generate large numbers of unique domains. 
#        Maximum length = 128 characters. This option also accepts IPV6 addresses 
#        that are enclosed in square brackets.
#        Type: optional
#        (DEFAULT = <sip:id[50000_]@_ip>)
#        Dependencies: -property agent
#    -sz_total_time
#        The total time for which an audio file will be played.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property scenarios; -scenarios_id GENERATETONE | 
#        GENERATEMF | VOICESESSION | MEDIASESSION | GENERATEDTMF
#    -sz_transport
#        Type of transport to be used. The choices are:
#        tcp     HLT initially uses TCP as the transport. If the remote party answers
#        using UDP, HLT accepts the response and switches to UDP as the 
#        transport.
#        udp     HLT initially uses UDP as the transport. If the remote party answers
#        using TCP, HLT accepts the response and switches to TCP as the 
#        transport.
#        only_tcp     HLT uses only TCP as the transport. If the remote party answers 
#        using UDP, HLT discards the response and continues using TCP.
#        only_udp     HLT uses only UDP as the transport. If the remote party answers 
#        Using TCP, HLT discards the response and continues using UDP.
#        Type: optional
#        (DEFAULT = udp)
#        Dependencies: -property agent
#    -sz_value
#        Numerical value for the sz_action.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property rulesTable
#    -sz_wave_name
#        Waveform audio (.wav) file.
#        Type: optional
#        (DEFAULT = "...")
#        Dependencies: -property audioClipsTable
#    -type_of_service_for_rtp
#        N/A
#        Type: optional
#        (DEFAULT = best_effort)
#        Dependencies: -property agent
#    -type_of_service_for_sip
#        If enable_tos_sip is 1, this option specifies the IP Precedence / TOS (Type of
#        Service) bit setting and Assured Forwarding classes. (Default = "Best Effort
#        0x0"). If you want to specify the standard choices that are in the GUI, you can use
#        a string representation. To specify any of the other 255 TOS values, specify the
#        decimal value. The default choices are:
#        "Best Effort (0x0)" (Default) routine priority
#        "Class 1 (0x20)" Priority service, Assured Forwarding class 1
#        "Class 2 (0x40)" Immediate service, Assured Forwarding class 2
#        "Class 3 (0x60)" Flash, Assured Forwarding class 3
#        "Class 4 (0x80)" Flash-override, Assured Forwarding class 4
#        "Express Forwarding (0xA0)" Critical-ecp
#        "Control (0xC0)" Internet-control
#        Type: optional
#        (DEFAULT = best_effort)
#        Dependencies: -property agent
#    -video_bitrate
#        Bit rate of generated (synthetic) video data.
#        Type: optional
#        (DEFAULT = 128)
#        Dependencies: -property agent
#    -video_bitrate_limit
#        The videoBitrate limit in Kbps.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -vs_n_play_mode
#        If 1, the audio file plays for a fixed number of times. If 0, the audio 
#        file plays continuously.
#        Type: optional
#        (DEFAULT = 1)
#        Dependencies: -property scenarios; -scenarios_id VOICESESSION
#
# Return Values:
#         A Keyed List
#         key:status     value:$::SUCCESS | $::FAILURE
#         key:client_handle     value:when -property client; -mode add
#         key:agent_handle     value:when -property client | agent; -mode add
#         key:action_handle     value:when -property action; -mode add
#         key:real_file_handle     value:when -property real_file; -mode add
#         key:log     value:returned debug info for when status is $::FAILURE
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
proc ::ixia::L47_sip_client { args } {
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
            \{::ixia::L47_sip_client $args\}]
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args

    set returnList [checkL47 SIP]
    if {[keylget returnList status] == $::FAILURE} {
        return $returnList
    }
    set mandatory_args {
            -mode        CHOICES add remove modify enable disable
    }


    set opt_args {
            -b_advisable    CHOICES 0 1
                        DEFAULT 0
        -b_best_performance    CHOICES 0
                               CHOICES 1
                               DEFAULT 1
        -b_comp_ms    CHOICES 0
                      CHOICES 1
                      DEFAULT 0
        -b_compact    CHOICES 0 1
                      DEFAULT 0
        -b_folding    CHOICES 0 1
                      DEFAULT 0
        -b_jit_ms    CHOICES 0
                     CHOICES 1
                     DEFAULT 0
        -b_limit_dtmf    CHOICES 0 1
                         DEFAULT 1
        -b_modify_power_level    CHOICES 0 1
                                 DEFAULT 0
        -b_mos_on_max    CHOICES 0
                         CHOICES 1
                         DEFAULT 0
        -b_next_on_fail    CHOICES 0 1
                           DEFAULT 1
        -b_optional    CHOICES 0 1
                       DEFAULT 0
        -b_recv5xx    CHOICES 0 1
                      DEFAULT 0
        -b_reg_before    CHOICES 0 1
                         DEFAULT 0
        -b_route    CHOICES 0 1
                    DEFAULT 0
        -b_rtp_start_collector    CHOICES 0 1
                                  DEFAULT 0
        -b_scattered    CHOICES 0 1
                        DEFAULT 0
        -b_silence_mode    CHOICES 0
                           CHOICES 1
                           DEFAULT 1
        -b_use_compensation    CHOICES 0 1
                               DEFAULT 0
        -b_use_dest    CHOICES 0 1
                       DEFAULT 1
        -b_use_jitter    CHOICES 0 1
                         DEFAULT 0
        -b_use_mos    CHOICES 0 1
                      DEFAULT 0
        -b_use_silence    CHOICES 0 1
                          DEFAULT 0
        -b_use_timer    CHOICES 0 1
                        DEFAULT 0
        -enable_tos_rtp    CHOICES 0 1
                           DEFAULT 0
        -enable_tos_sip    CHOICES 0 1
                           DEFAULT 0
        -handle    ANY
        -ms_n_dtmf_duration    RANGE 60-999
                               DEFAULT 100
        -ms_n_dtmf_interdigits    RANGE 30-9999
                                  DEFAULT 40
        -ms_n_play_mode    CHOICES 0
                           CHOICES 1
                           DEFAULT 1
        -ms_n_session_type    RANGE 0-2147483647
                              DEFAULT 0
        -ms_sz_codec_name    CHOICES g711alaw
                             CHOICES g711ulaw
                             CHOICES g729a
                             CHOICES g729b
                             CHOICES g726
                             CHOICES g723_1
                             CHOICES amr
                             CHOICES i_lbc
                             DEFAULT g711alaw
        -n_amplitude1    ANY 
                         DEFAULT -10
        -n_amplitude2    ANY 
                         DEFAULT 0
        -n_channels    RANGE 0-2147483647
                       DEFAULT 0
        -n_comp_jitter_buffer    RANGE 0-300
                                 DEFAULT 50
        -n_comp_jitter_ms    RANGE 0-3000
                             DEFAULT 1000
        -n_comp_max_dropped    RANGE 1-100
                               DEFAULT 7
        -n_detect_time    RANGE 1-2147483647
                          DEFAULT 10
        -n_detect_time_unit    CHOICES 0
                               CHOICES 1
                               CHOICES 2
                               CHOICES 3
                               DEFAULT 0
        -n_dtmf_amplitude    ANY 
                             DEFAULT -10
        -n_dtmf_count    RANGE 1-2147483647
                         DEFAULT 6
        -n_dtmf_duration    RANGE 10-990
                            DEFAULT 100
        -n_dtmf_interdigits    RANGE 10-9990
                               DEFAULT 40
        -n_dtmf_streams    RANGE 1-900
                           DEFAULT 10
        -n_dtmfdetection_mode    CHOICES 0
                                 CHOICES 1
                                 CHOICES 2
                                 DEFAULT 0
        -n_duration    RANGE 0-2147483647
                       DEFAULT 0
        -n_first_dtmftimeout    RANGE 60-100000000
                                DEFAULT 2000
        -n_frequency1    RANGE 0-9999
                         DEFAULT 615
        -n_frequency2    RANGE 0-9999
                         DEFAULT 0
        -n_inter_dtmfinterval    RANGE 30-100000000
                                 DEFAULT 1000
        -n_inter_mf_interval    RANGE 10-9990
                                DEFAULT 40
        -n_jitter_buffer    RANGE 1-300
                            DEFAULT 1
        -n_jitter_ms    RANGE 1-3000
                        DEFAULT 20
        -n_mf_amplitude    ANY 
                           DEFAULT -10
        -n_mf_duration    RANGE 10-990
                          DEFAULT 200
        -n_mos_interval    RANGE 2-30
                           DEFAULT 3
        -n_mos_max_streams    RANGE 1-2147483647
                              DEFAULT 1
        -n_off_time    RANGE 0-9990
                       DEFAULT 0
        -n_on_time    RANGE 10-990
                      DEFAULT 100
        -n_pc_interval    RANGE 1-2147483647
                          DEFAULT 500
        -n_peer_dtmf_duration    RANGE 0-2147483647
                                 DEFAULT 0
        -n_peer_dtmf_interdigits    RANGE 0-2147483647
                                    DEFAULT 0
        -n_play_mode    CHOICES 0
                        CHOICES 1
                        DEFAULT 0
        -n_play_time    RANGE 1-2147483647
                        DEFAULT 30
        -n_re_reg_duration    RANGE 0-60000
                              DEFAULT 0
        -n_repeat_count    RANGE 1-2147483647
                           DEFAULT 1
        -n_repetition_count    RANGE 0-2147483647
                               DEFAULT 1
        -n_resolution    RANGE 0-2147483647
                         DEFAULT 0
        -n_sample_rate    RANGE 0-2147483647
                          DEFAULT 0
        -n_session_type    CHOICES 0
                           CHOICES 1
                           CHOICES 2
                           DEFAULT 0
        -n_size    RANGE 0-2147483647
                   DEFAULT 0
        -n_tcp_port    RANGE 1-65535
                       DEFAULT 5060
        -n_think_max    RANGE 0-2147483647
                        DEFAULT 1000
        -n_think_min    RANGE 0-2147483647
                        DEFAULT 1000
        -n_time_unit    CHOICES 0
                        CHOICES 1
                        CHOICES 2
                        CHOICES 3
                        DEFAULT 0
        -n_timeout    RANGE 0-2147483647
                      DEFAULT 30000
        -n_timers_t1    RANGE 0-2147483647
                        DEFAULT 500
        -n_timers_t2    RANGE 0-2147483647
                        DEFAULT 4000
        -n_timers_t4    RANGE 0-2147483647
                        DEFAULT 5000
        -n_timers_tc    RANGE 0-2147483647
                        DEFAULT 180000
        -n_timers_td    RANGE 0-2147483647
                        DEFAULT 32000
        -n_tone_duration    RANGE 10-990
                            DEFAULT 100
        -n_tone_name    CHOICES 0
                        CHOICES 1
                        CHOICES 2
                        CHOICES 3
                        CHOICES 4
                        CHOICES 5
                        CHOICES 6
                        CHOICES 7
                        CHOICES 8
                        CHOICES 9
                        CHOICES 10
                        CHOICES 11
                        CHOICES 12
                        CHOICES 13
                        CHOICES 14
                        CHOICES 15
                        CHOICES 16
                        CHOICES 17
                        CHOICES _1
                        DEFAULT 0
        -n_tone_type    CHOICES 0
                        CHOICES 1
                        CHOICES 2
                        CHOICES 3
                        DEFAULT 0
        -n_total_time    RANGE 0-2147483647
                         DEFAULT 0
        -n_udp_max_size    RANGE 1024-4000
                           DEFAULT 1024
        -n_udp_port    RANGE 1-65535
                       DEFAULT 5060
        -n_wav_duration    RANGE 0-2147483647
                           DEFAULT 0
        -property    CHOICES client
                     CHOICES agent
                     CHOICES rulesTable
                     CHOICES audioClipsTable
                     CHOICES scenarios
                     DEFAULT agent
        -redirection_sz_destination    REGEXP ^(((25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3})|(\[(((?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4})|(((?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?)::((?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?))|(((?:[0-9A-Fa-f]{1,4}:){6,6})(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3})|(((?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?) ::((?:[0-9A-Fa-f]{1,4}:)*)(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3})))\]):([1-9]\d{0,3}|[1-5]\d{4}|6[0-4]\d{3}|65[0-4]\d\d|655[012]\d|6553[0-5])$
                                       DEFAULT 127.0.0.1:5060
        -scenarios_id    CHOICES REGISTRATION
                         CHOICES ORIGINATECALL
                         CHOICES THINK
                         CHOICES ENDCALL
                         CHOICES REDIRECTION
                         CHOICES VOICESESSION
                         CHOICES MEDIASESSION
                         CHOICES GENERATEDTMF
                         CHOICES GENERATEMF
                         CHOICES GENERATETONE
                         CHOICES DETECTDTMF
        -sym_destination    ANY
                            DEFAULT none
        -synth_video    CHOICES 0 1
                        DEFAULT 1
        -sz_action    ANY
        -sz_audio_file    ANY
                          DEFAULT <_none>
        -sz_auth_domain    ANY
                           DEFAULT domain[0000_]
        -sz_auth_password    ANY
                             DEFAULT password[0000_]
        -sz_auth_username    ANY
                             DEFAULT user[0000_]
        -sz_bit_rate    ANY
        -sz_codec_descr    ANY
        -sz_codec_details    ANY
        -sz_codec_name    ANY
        -sz_contact    ANY
                       DEFAULT <sip:id[00000_]@_ip>
        -sz_data_format    ANY
                           DEFAULT ...
        -sz_destination    REGEXP ^(((25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3})|(\[(?![fF]{2}[0-9a-fA-F]{2}:)(((?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4})|(((?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?)::((?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?))|(((?:[0-9A-Fa-f]{1,4}:){6,6})(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3})|(((?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?) ::((?:[0-9A-Fa-f]{1,4}:)*)(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3})))\]):([1-9]\d{0,3}|[1-5]\d{4}|6[0-4]\d{3}|65[0-4]\d\d|655[012]\d|6553[0-5])$
                           DEFAULT 127.0.0.1:5060
        -sz_dtmf_seq    REGEXP ^[0-9a-dA-D#*]+$
                        DEFAULT 12345
        -sz_from    ANY
                    DEFAULT <sip:id[00000_]@_ip>
        -sz_message    CHOICES register
                       DEFAULT register
        -sz_mf_seq    REGEXP ^[0-9a-cA-C#*]+$
                      DEFAULT 12345
        -sz_peer_codec_details    ANY
        -sz_peer_codec_name    ANY
        -sz_peer_dtmf_seq    ANY
        -sz_power_level    CHOICES pl_20
                           CHOICES pl_30
                           DEFAULT pl_20
        -sz_raw_wave_name    ANY
        -sz_registrar    REGEXP ^(|((((25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3})|(\[(?![fF]{2}[0-9a-fA-F]{2}:)(((?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4})|(((?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?)::((?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?))|(((?:[0-9A-Fa-f]{1,4}:){6,6})(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3})|(((?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?) ::((?:[0-9A-Fa-f]{1,4}:)*)(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3})))\]):([1-9]\d{0,3}|[1-5]\d{4}|6[0-4]\d{3}|65[0-4]\d\d|655[012]\d|6553[0-5])))$
                         DEFAULT 127.0.0.1:5060
        -sz_requesturi    ANY
                          DEFAULT sip:id[50000-]@ip
        -sz_route    ANY
                     DEFAULT route: <sip:p1.example.com;lr>,<sip:p2.domain.com;lr>
        -sz_to    ANY
                  DEFAULT <sip:id[50000_]@_ip>
        -sz_total_time    ANY
                          DEFAULT 0
        -sz_transport    CHOICES udp
                         CHOICES tcp
                         CHOICES only_udp
                         CHOICES only_tcp
                         DEFAULT udp
        -sz_value    ANY
                     DEFAULT 0
        -sz_wave_name    ANY
                         DEFAULT ...
        -type_of_service_for_rtp    ANY
                                    DEFAULT best _effort (0x0)
        -type_of_service_for_sip    ANY
                                    DEFAULT best _effort (0x0)
        -video_bitrate    RANGE 64-1000
                          DEFAULT 128
        -video_bitrate_limit    RANGE 0-2147483647
                                DEFAULT 0
        -vs_n_play_mode    CHOICES 0
                           CHOICES 1
                           DEFAULT 1
        -vs_sz_dtmf_seq    ANY
                           DEFAULT 12345
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
            set property [::ixia::ixL47GetProperty $handle sip]
        }
    }

    # scenarios parameters
    set scenarios_option_list [list procName mode handle property target \
        vs_sz_dtmf_seq sym_destination sz_destination n_dtmf_interdigits sz_total_time \
        n_total_time n_inter_mf_interval sz_dtmf_seq n_off_time n_tone_name sz_codec_details \
        n_tone_type n_detect_time n_repeat_count n_dtmf_duration n_think_min n_play_mode \
        n_time_unit n_inter_dtmfinterval n_dtmfdetection_mode n_dtmf_amplitude n_mf_amplitude \
        n_mf_duration sz_codec_name n_frequency1 n_wav_duration n_play_time n_dtmf_count \
        n_amplitude1 n_detect_time_unit n_tone_duration sz_audio_file ms_n_play_mode \
        n_amplitude2 n_think_max redirection_sz_destination n_session_type scenarios_id \
        vs_n_play_mode synth_video n_repetition_count n_first_dtmftimeout b_use_dest \
        sz_mf_seq n_frequency2 n_on_time ]
    set scenarios_args [list]

    lappend option_variables scenarios_option_list
    lappend option_variables scenarios_args

    # audioClipsTable parameters
    set audioClipsTable_option_list [list procName mode handle property target \
        sz_data_format sz_raw_wave_name n_channels n_size n_resolution sz_wave_name \
        n_sample_rate n_duration ]
    set audioClipsTable_args [list]

    lappend option_variables audioClipsTable_option_list
    lappend option_variables audioClipsTable_args

    # rulesTable parameters
    set rulesTable_option_list [list procName mode handle property target \
        sz_value sz_action sz_message ]
    set rulesTable_args [list]

    lappend option_variables rulesTable_option_list
    lappend option_variables rulesTable_args

    # agent parameters
    set agent_option_list [list procName mode handle property target \
        b_comp_ms ms_n_session_type sz_auth_password b_optional b_route b_use_silence \
        sz_from sz_power_level enable_tos_rtp n_udp_port b_recv5xx b_use_mos sz_auth_username \
        b_use_compensation b_rtp_start_collector sz_registrar n_timeout sz_transport \
        b_next_on_fail n_comp_jitter_ms type_of_service_for_rtp n_comp_jitter_buffer \
        n_pc_interval b_best_performance n_timers_t4 n_peer_dtmf_duration video_bitrate \
        n_timers_t2 sz_peer_codec_name sz_codec_descr sz_bit_rate n_jitter_ms n_peer_dtmf_interdigits \
        n_timers_tc b_reg_before sz_contact b_compact b_use_timer n_udp_max_size \
        n_jitter_buffer sz_dtmf_seq n_timers_t1 ms_n_dtmf_interdigits n_tcp_port \
        b_advisable sz_codec_details n_dtmf_streams sz_auth_domain ms_n_dtmf_duration \
        sz_to enable_tos_sip n_timers_td video_bitrate_limit b_scattered b_silence_mode \
        n_mos_max_streams n_mos_interval sz_peer_codec_details sz_peer_dtmf_seq \
        b_limit_dtmf b_jit_ms sz_requesturi sz_route b_use_jitter ms_sz_codec_name \
        n_comp_max_dropped b_folding type_of_service_for_sip b_mos_on_max n_re_reg_duration \
        b_modify_power_level ]
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
        scenarios {
            set returnList [eval [format "%s %s" ::ixia::ixL47SIPCLIENTscenarios\
                $scenarios_args]]
            return $returnList
        }
        audioClipsTable {
            set returnList [eval [format "%s %s" ::ixia::ixL47SIPCLIENTaudioClipsTable\
                $audioClipsTable_args]]
            return $returnList
        }
        rulesTable {
            set returnList [eval [format "%s %s" ::ixia::ixL47SIPCLIENTrulesTable\
                $rulesTable_args]]
            return $returnList
        }
        client -
        agent {
            set returnList [eval [format "%s %s" ::ixia::ixL47SIPCLIENTagent\
                $agent_args]]
            return $returnList
        }
        default {}
    }
}


## Internal Procedure Header
# Name:
#    ::ixia::L47_sip_server
#
# Description:
#    The ::ixia::L47_sip_server procedure is used to create and configure a 
#    traffic server.  A server performs protocol specific activities, which we 
#    will further refer to as agents. Even if a server is created using the 
#    ::ixia::L47_sip_server  procedure, other protocol agents can be attached 
#    to it using ::ixia::L47_<protocol>_server  procedures, by using 
#    "-property agent" "-mode add" "-handle <<the server handle>>".
#
# Synopsis:
#    ::ixia::L47_sip_server
#        -mode                              CHOICES add remove modify enable 
#                                           disable
#        [-b_advisable                      FLAG]
#        [-b_best_performance               CHOICES 0 1]
#        [-b_comp_ms                        CHOICES 0 1]
#        [-b_compact                        FLAG]
#        [-b_folding                        FLAG]
#        [-b_jit_ms                         CHOICES 0 1]
#        [-b_limit_dtmf                     FLAG]
#        [-b_modify_power_level             FLAG]
#        [-b_mos_on_max                     CHOICES 0 1]
#        [-b_optional                       FLAG]
#        [-b_reg_before                     FLAG]
#        [-b_rtp_start_collector            FLAG]
#        [-b_scattered                      FLAG]
#        [-b_silence_mode                   CHOICES 0 1]
#        [-b_uas_stateless                  CHOICES 0 1]
#        [-b_use_compensation               FLAG]
#        [-b_use_jitter                     FLAG]
#        [-b_use_mos                        FLAG]
#        [-b_use_silence                    FLAG]
#        [-enable_tos_rtp                   FLAG]
#        [-enable_tos_sip                   FLAG]
#        [-handle                           ANY]
#        [-ipv6form                         CHOICES 0 1]
#        [-ms_n_dtmf_duration               RANGE 60-999]
#        [-ms_n_dtmf_interdigits            RANGE 30-9999]
#        [-ms_n_session_type                RANGE 10-2147483647]
#        [-ms_sz_codec_name                 CHOICES g711alaw g711ulaw g729a
#                                           g729b g726 g723_1 amr i_lbc]
#        [-n_channels                       RANGE 10-2147483647]
#        [-n_comp_jitter_buffer             RANGE 0-300]
#        [-n_comp_jitter_ms                 RANGE 0-3000]
#        [-n_comp_max_dropped               RANGE 1-100]
#        [-n_dtmf_streams                   RANGE 1-900]
#        [-n_duration                       RANGE 10-2147483647]
#        [-n_jitter_buffer                  RANGE 1-300]
#        [-n_jitter_ms                      RANGE 1-3000]
#        [-n_mos_interval                   RANGE 2-30]
#        [-n_mos_max_streams                RANGE 1-2147483647]
#        [-n_pc_interval                    RANGE 1-2147483647]
#        [-n_peer_dtmf_duration             RANGE 10-2147483647]
#        [-n_peer_dtmf_interdigits          RANGE 10-2147483647]
#        [-n_play_mode                      CHOICES 0 1]
#        [-n_play_time                      RANGE 1-2147483647]
#        [-n_repeat_count                   RANGE 1-2147483647]
#        [-n_resolution                     RANGE 10-2147483647]
#        [-n_sample_rate                    RANGE 10-2147483647]
#        [-n_session_type                   CHOICES 0 1 2]
#        [-n_size                           RANGE 10-2147483647]
#        [-n_tcp_port                       RANGE 1-65535]
#        [-n_time_unit                      CHOICES 0 1 2 3]
#        [-n_timers_t1                      RANGE 10-2147483647]
#        [-n_timers_t2                      RANGE 10-2147483647]
#        [-n_timers_t4                      RANGE 10-2147483647]
#        [-n_timers_tc                      RANGE 10-2147483647]
#        [-n_timers_td                      RANGE 10-2147483647]
#        [-n_total_time                     RANGE 10-2147483647]
#        [-n_udp_max_size                   RANGE 1024-4000]
#        [-n_udp_port                       RANGE 1-65535]
#        [-n_wav_duration                   RANGE 10-2147483647]
#        [-property                         CHOICES server agent  rulesTable ]
#                                           audioClipsTable scenarios]
#        [-scenarios_id                     CHOICES RECEIVEUSING180]
#                                           CHOICES RECEIVEUSING100AND180]
#                                           CHOICES SEND6XX]
#                                           CHOICES VOICESESSION]
#        [-sz_action                        ANY]
#        [-sz_audio_file                    ANY]
#        [-sz_auth_domain                   ANY]
#        [-sz_auth_password                 ANY]
#        [-sz_auth_username                 ANY]
#        [-sz_bit_rate                      ANY]
#        [-sz_codec_descr                   ANY]
#        [-sz_contact                       ANY]
#        [-sz_data_format                   ANY]
#        [-sz_dtmf_seq                      REGEXP ^[0-9a-dA-D#*]+$]
#        [-sz_from                          ANY]
#        [-sz_message                       CHOICES register]
#        [-sz_peer_codec_details            ANY]
#        [-sz_peer_codec_name               ANY]
#        [-sz_peer_dtmf_seq                 ANY]
#        [-sz_power_level                   CHOICES pl_20 pl_30]
#        [-sz_raw_wave_name                 ANY]
#        [-sz_registrar                     REGEXP ^(|((((25[0-5]|2[0-4]\d|[0-1]
#                                           ?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?
#                                           \d?\d)){3})|(\[(?![fF]{2}[0-9a-fA-F]
#                                           {2}:)(((?:[0-9a-fA-F]{1,4}:){7}
#                                           [0-9a-fA-F]{1,4})|(((?:[0-9A-Fa-f]{1,4}
#                                           (?::[0-9A-Fa-f]{1,4})*)?)::((?:[0-9A-Fa-f]
#                                           {1,4}(?::[0-9A-Fa-f]{1,4})*)?))|
#                                           (((?:[0-9A-Fa-f]{1,4}:){6,6})(25[0-5]|2[0-4]
#                                           \d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?
#                                           \d?\d)){3})|(((?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]
#                                           {1,4})*)?) ::((?:[0-9A-Fa-f]{1,4}:)*)(25[0-5]
#                                           |2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]
#                                           ?\d?\d)){3})))\]):([1-9]\d{0,3}|[1-5]\d{4}|6[0-4]
#                                           \d{3}|65[0-4]\d\d|655[012]\d|6553[0-5])))$]
#        [-sz_requesturi                    ANY]
#        [-sz_to                            ANY]
#        [-sz_total_time                    ANY]
#        [-sz_transport                     CHOICES udp tcp only_udp only_tcp]
#        [-sz_value                         ANY]
#        [-sz_wave_name                     ANY]
#        [-type_of_service_for_rtp          ANY]
#        [-type_of_service_for_sip          ANY]
#        [-video_bitrate                    RANGE 64-1000]
#        [-video_bitrate_limit              RANGE 10-2147483647]
#        [-vs_n_play_mode                   CHOICES 0 1]
#
# Arguments:
#
#    -mode
#        Defines types of actions to be taken on the –property object.
#        Choices:
#            • add – can be used with –property server | agent | rulesTable | 
#        audioClipsTable | scenarios 
#            • remove – can be used with –property server | agent | rulesTable 
#        | audioClipsTable | scenarios 
#            • enable – can be used with –property agent 
#            • disable –can be used with –property agent
#            • modify – can be used with –property server | agent | rulesTable 
#        | audioClipsTable | scenarios
#        Type: mandatory
#        (DEFAULT = N/A)
#        Dependencies:
#    -b_advisable
#        If 1, the SIP request includes the header fields that are defined as
#        ‘mandatory’ by the SIP RFC (RFC 3261), plus those that are recommended 
#        as advisable.’
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_best_performance
#        If 1, HLT inserts the headers into the message so that the message can 
#        be processed as quickly as possible by the receiving system. 
#        If 0, HLT inserts the headers into the message so that it requires 
#        maximum processing by the receiving system.
#        Type: optional
#        (DEFAULT = 1)
#        Dependencies: -property agent
#    -b_comp_ms
#        Description:
#        Defines the method used to set the compensation jitter buffer size.
#        0 (Default). Compensation jitter buffer size is set by n_comp_jitter_buffer.
#        1 Compensation jitter buffer size is set by n_comp_jitter_ms.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_compact
#        If 1, HLT uses the compact forms of the SIP header field notations.
#        The compact form is intended for instances in which messages would otherwise
#         become too large to be carried on the transport available to it 
#         (exceeding the maximum transmission unit [MTU] when using UDP, 
#         for example).
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_folding
#        If 1, the VIA field spans two lines. Some SIP devices many not 
#        be able to handle this.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_jit_ms
#        Description:
#        Defines the method used to set the jitter buffer size.
#        0 (Default). Jitter buffer size is set by n_jitter_buffer.
#        1 Jitter buffer size is set by n_jitter_ms.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_limit_dtmf
#        Enable or disable limitation on the number of DTMF streams to 
#        be processed.
#        0 DTMF applied to all streams.
#        1 (Default) DTMF limited to number of streams specified by 
#        n_dtmf_streams.
#        Type: optional
#        (DEFAULT = 1)
#        Dependencies: -property agent
#    -b_modify_power_level
#        If 1, HLT modifies the volume of the compressed audio.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_mos_on_max
#        Defines types of actions to be taken on the –property object.
#        Defines whether MOS is calculated for a subset of streams or 
#        for all streams.
#        0 (Default). MOS calculation is applied to all streams.
#        1 MOS calculation is applied to the number of streams specified 
#        by n_mos_max_streams.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_optional
#        If 1, the SIP request includes the header fields that are defined 
#        as ‘mandatory’ by the SIP RFC (RFC 3261), plus those that are 
#        listed as ‘optional.’
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_reg_before
#        If 1, before starting the Originate Call/EnCall --> Receive call 
#        process, the HLT SIP server registers with the proxy server. 
#        Registration occurs only once at the beginning of the test.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_rtp_start_collector
#        Specifies, whether the statistics for rtp should be collected 
#        or not. Possible values
#        are:
#        0 Do not start
#        1 Start
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_scattered
#        Description:
#        If 1, HLT moves the header fields around in the message in order 
#        to make it more difficult for the DUT to decode the message.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_silence_mode
#        Description:
#        Indicates the method used to generate the background noise. 
#        Possible Values are:
#        "0" Comfort Noise silence type.
#        "1" Null Data encoded silence type.
#        Type: optional
#        (DEFAULT = 1)
#        Dependencies: -property agent
#    -b_uas_stateless
#        Description:
#        If true, the SIP server behaves as a stateless User Agent Server (UAS).
#        A stateless UAS does not maintain transaction states. It replies to 
#        requests normally,
#        but discards any state that would ordinarily be retained by a UAS after a
#        response has been sent.
#        If a stateless UAS receives a retransmission of a request, it 
#        regenerates the
#        response and resends it, just as if it were replying to the first 
#        instance of the
#        request.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_use_compensation
#        Description:
#        Enables or disables use of the compensation jitter buffer.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_use_jitter
#        Enables or disables use of the jitter buffer.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_use_mos
#        Enables or disables use of MOS.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -b_use_silence
#        If enabled, HLT generates and sends artificial background noise during 
#        times of silence during a call.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -enable_tos_rtp
#        Enables the setting of the TOS (Type of Service) bits in the header of 
#        the RTP data packets.
#        0 (default) TOS bits not enabled.
#        1 TOS bits enabled.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -enable_tos_sip
#        Enables the setting of the TOS (Type of Service) bits in the header of 
#        the SIP packets.
#        0 (default) TOS bits not enabled.
#        1 TOS bits enabled.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -handle
#        Type: optional
#        (DEFAULT = N/A)
#        Dependencies:
#    -ipv6form
#        Specifies 0 (ipv4) or 1 (ipv6) to determine the types of networks that 
#        the SIP server and server use.
#        All the fields that support IPv4 addresses also support IPv6 addresses.
#         There are
#        two methods for entering IPv6 addresses in SIP fields.
#        In all options mentioned below, enclose the address in square brackets ([ ])
#        sz_registrar; for example [::C212:1003]:5060
#        ORIGINATECALL command; for example [::C212:1003]:5060
#        REGISTRATION command
#        REDIRECTION command
#        For the command options refer Scenarios.
#        In the Content of Messages the four options accepts IPV6 addresses.
#         These
#        options enclose the address in vertical bar (pipe) symbols ( | ).
#         Square brackets
#        are used to enclose sequence generators. The options are:
#        sz_requesturi
#        sz_from
#        sz_to
#        sz_contac
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -ms_n_dtmf_duration
#        Length of time allowed to play the DTMF sequence. Minimum = "60,
#        " maximum = "999."
#        Type: optional
#        (DEFAULT = 100)
#        Dependencies: -property agent
#    -ms_n_dtmf_interdigits
#        Duration (in milliseconds) of the DTMF interdigit signal.
#         Minimum = "30," maximum = "9999."
#        Type: optional
#        (DEFAULT = 40)
#        Dependencies: -property agent
#    -ms_n_session_type
#        Type of voice session. The choices are:
#        "0" (default) Plays audio file specified by sz_audio_fIle.
#        "1" Perform DTMF path confirmation.
#        "2" Perform synthetic DTMF path confirmation.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -ms_sz_codec_name
#        Codec to be used to encode waveform audio files listed in the
#         Audio Clips Pool.
#        The choices are:
#        "g711alaw" (default) G.711 A-law
#        "g711ulaw" G.711 mu-law
#        "g729a" G.729A
#        "g729b" G.729B
#        "g726" G.726
#        "g723_1" G.723.1
#        "amr"
#        "i_lbc"
#        Type: optional
#        (DEFAULT = g711alaw)
#        Dependencies: -property agent
#    -n_channels
#        Number of audio channels: "0" = mono, "1" = stereo. (Default = "0").
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property audioClipsTable
#    -n_comp_jitter_buffer
#        Compensation jitter buffer maximum size, in packets. Minimum = "0,
#        " maximum = "300."
#        Type: optional
#        (DEFAULT = 50)
#        Dependencies: -property agent
#    -n_comp_jitter_ms
#        Compensation jitter buffer maximum size, in milliseconds. Minimum = "0,
#        "maximum = "3,000."
#        Type: optional
#        (DEFAULT = 1000)
#        Dependencies: -property agent
#    -n_comp_max_dropped
#        Maximum dropped consecutive packets. Minimum = "1," maximum = "100,"
#        Type: optional
#        (DEFAULT = 7)
#        Dependencies: -property agent
#    -n_dtmf_streams
#        Number of streams to which path confirmation will be applied.
#         Minimum = "1," maximum = "900."
#        Type: optional
#        (DEFAULT = 10)
#        Dependencies: -property agent
#    -n_duration
#        Playing time of audio file.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property audioClipsTable
#    -n_jitter_buffer
#        Duration (in milliseconds) of the MF interdigit signal. Minimum = "10",
#         Maximum = "9990".
#        Type: optional
#        (DEFAULT = 1)
#        Dependencies: -property agent
#    -n_jitter_ms
#        Jitter Buffer size, in milliseconds. Minimum = "1," maximum = "3,000."
#        Type: optional
#        (DEFAULT = 20)
#        Dependencies: -property agent
#    -n_mos_interval
#        Frequency at which IxLoad samples the RTP streams to generate the MOS
#         scores. Minimum = "2," maximum = "30."
#        Type: optional
#        (DEFAULT = 3)
#        Dependencies: -property agent
#    -n_mos_max_streams
#        Maximum number of concurrent streams used in MOS calculation.
#         Minimum = "1."
#        Type: optional
#        (DEFAULT = 1)
#        Dependencies: -property agent
#    -n_pc_interval
#        If Synthetic path confirmation is selected, this is the interval at
#         which HLT add the synthetic RTP packets to the stream. Minimum = "1,"
#        Type: optional
#        (DEFAULT = 500)
#        Dependencies: -property agent
#    -n_peer_dtmf_duration
#        DTMF duration used by peer.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -n_peer_dtmf_interdigits
#        Inter-digits interval used by peer.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -n_play_mode
#        The play mode to play the MF tones. Possible values are:
#        0 Generate for a specified period of time
#        1 Repeat for a specified number of times
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -n_play_time
#        The time units to play the specified sequence.
#        Type: optional
#        (DEFAULT = 30)
#        Dependencies: -property scenarios; -scenarios_id VOICESESSION
#    -n_repeat_count
#        If n_play_mode is true, this parameter sets the number of times that
#         the audio file will play.
#        Type: optional
#        (DEFAULT = 1)
#        Dependencies: -property scenarios; -scenarios_id VOICESESSION
#    -n_resolution
#        Number of bits per sample.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property audioClipsTable
#    -n_sample_rate
#        Number of samples taken per second from the recording source.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property audioClipsTable
#    -n_session_type
#        Type of voice session. The choices are:
#        "0" (default) Plays audio file specified by sz_audio_fIle.
#        "1" Perform DTMF path confirmation.
#        "2" Perform synthetic DTMF path confirmation.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property scenarios; -scenarios_id VOICESESSION
#    -n_size
#        Size of audio file, in bytes.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property audioClipsTable
#    -n_tcp_port
#        Port number to be used for sending and receiving SIP messages over TCP.
#         Minimum = "1," maximum = "65,535."
#        Type: optional
#        (DEFAULT = 5060)
#        Dependencies: -property agent
#    -n_time_unit
#        Units of time used to set the audio file play time (n_play_time).
#         The choices are:
#        "0" (default) Seconds
#        "1" Minutes
#        "2" Hours
#        "3" Days
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property scenarios; -scenarios_id VOICESESSION
#    -n_timers_t1
#        Estimate of the round-trip time (RTT), in milliseconds (ms).
#        Type: optional
#        (DEFAULT = 500)
#        Dependencies: -property agent
#    -n_timers_t2
#        Maximum retransmit interval, in milliseconds (ms), for non-INVITE
#         requests and INVITE responses.
#        Type: optional
#        (DEFAULT = 4000)
#        Dependencies: -property agent
#    -n_timers_t4
#        Maximum length of time, in milliseconds (ms), that a message will
#         remain in the network.
#        Type: optional
#        (DEFAULT = 5000)
#        Dependencies: -property agent
#    -n_timers_tc
#        Proxy INVITE transaction timeout. Minimum = 180,000.
#        Type: optional
#        (DEFAULT = 180000)
#        Dependencies: -property agent
#    -n_timers_td
#        Wait time for response retransmits. For UDP, this must be greater
#         than 32 seconds.
#        Type: optional
#        (DEFAULT = 32000)
#        Dependencies: -property agent
#    -n_total_time
#        The total time for which an .wav file will be played.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property scenarios; -scenarios_id VOICESESSION
#    -n_udp_max_size
#        Maximum size, in Kb, of a SIP message that will be sent. If a message
#         exceeds this size, HLT ignores it.
#        Type: optional
#        (DEFAULT = 1024)
#        Dependencies: -property agent
#    -n_udp_port
#        Port number to be used for sending and receiving SIP messages over UDP.
#         Minimum = "1," maximum = "65,535."
#        Type: optional
#        (DEFAULT = 5060)
#        Dependencies: -property agent
#    -n_wav_duration
#        The time duration of a wave.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property scenarios; -scenarios_id VOICESESSION
#    -property
#        Types of objects that this procedure can configure. Valid values are:
#        server
#        agent
#        rulesTable
#        audioClipsTable
#        scenarios
#        Type: optional
#        (DEFAULT = agent)
#        Dependencies: N/A
#    -scenarios_id
#        When –property is ‘scenarios’, this parameter determines what type of
#         scenario will be generated.
#        RECEIVEUSING180
#        RECEIVEUSING100AND180
#        SEND6XX
#        VOICESESSION
#        Type: optional
#        (DEFAULT = N/A)
#        Dependencies: -property scenarios
#    -sz_action
#        Action the rule performs.
#        Type: optional
#        (DEFAULT = "")
#        Dependencies: -property rulesTable
#    -sz_audio_file
#        Waveform audio file that will be played during the session. This must
#         be an sz_wave_name object contained within the Audio Clips Pool object.
#        Type: optional
#        (DEFAULT = <_none>)
#        Dependencies: -property scenarios; -scenarios_id VOICESESSION 
#    -sz_auth_domain
#        Domain to be registered with registrar. Maximum length = 128 characters.
#        Type: optional
#        (DEFAULT = domain[0000_])
#        Dependencies: -property agent
#    -sz_auth_password
#        Password to be registered with registrar. Maximum length = 128 characters.
#        Type: optional
#        (DEFAULT = password[0000_])
#        Dependencies: -property agent
#    -sz_auth_username
#        User name to be registered with registrar. Maximum length = 128 characters.
#        Type: optional
#        (DEFAULT = user[0000_])
#        Dependencies: -property agent
#    -sz_bit_rate
#        This specifies the bit rate of the codec being used. Possible values are:
#        Codec     Bit Rate
#        g711alaw    64 kbps
#        g711ulaw    64 kbps
#        g723_1     5.3 kbps
#        6.3 kbps
#        g726    40 kbps
#        g729a     8 kbps
#        g729b     8 kbps
#        amr     4.75 kbps
#        5.15 kbps
#        5.9 kbps
#        6.7 kbps
#        7.4 kbps
#        7.95 kbps
#        10.2 kbps
#        12.2 kbps
#        i_lbc     13.33 kbps
#        15.2 kbps
#        Type: optional
#        (DEFAULT = "")
#        Dependencies: -property agent
#    -sz_codec_descr
#        Codec description.
#        Type: optional
#        (DEFAULT = "")
#        Dependencies: -property agent
#    -sz_contact
#        The Contact header field value provides a URI whose meaning depends on the
#        type of request or response it is in.The Contact header field has a role similar to
#        the Location header field in HTTP. You can include variables in this
#         field to automatically generate large numbers of unique domains.
#          Maximum length = 128 characters. This option also accepts IPV6 addresses
#           that are enclosed in square brackets.
#        Type: optional
#        (DEFAULT = <sip:id[50000_]@_ip>)
#        Dependencies: -property agent
#    -sz_data_format
#        Encoding format of waveform audio file.
#        Type: optional
#        (DEFAULT = "...")
#        Dependencies: -property audioClipsTable
#    -sz_dtmf_seq
#        The dtmf sequence to be generated.
#        Type: optional
#        (DEFAULT = 12345)
#        Dependencies: -property agent | -property scenarios; -scenarios_id
#         VOICESESSION
#    -sz_from
#        Initiator of the SIP request. You can include variables in this field
#         to automatically generate large numbers of unique domains.
#          Maximum length = 128 characters. This option also accepts IPV6 addresses
#           that are enclosed in square brackets.
#        Type: optional
#        (DEFAULT = <sip:id[50000_]@_ip>)
#        Dependencies: -property agent
#    -sz_message
#        Type of message the rule will apply to. (Default = "REGISTER"). See sz_action
#        for the list of messages that you can configure rules for.
#        Type: optional
#        (DEFAULT = register)
#        Dependencies: -property rulesTable
#    -sz_peer_codec_details
#        Details of codec used by peer.
#        Type: optional
#        (DEFAULT = "")
#        Dependencies: -property agent
#    -sz_peer_codec_name
#        Name of codec used by peer.
#        Type: optional
#        (DEFAULT = "")
#        Dependencies: -property agent
#    -sz_peer_dtmf_seq
#        DTMF sequence used by peer.
#        Type: optional
#        (DEFAULT = "")
#        Dependencies: -property agent
#    -sz_power_level
#        If b_modify_power_level is 1, this parameter specifies the amount of gain (volume)
#        added to compressed audio. The choices are:
#        "PL_20" -20 dB
#        "PL_30" -30 dB
#        Type: optional
#        (DEFAULT = pl_20)
#        Dependencies: -property agent
#    -sz_raw_wave_name
#        Name and path of wave file to be added to the list.
#        Type: optional
#        (DEFAULT = "")
#        Dependencies: -property audioClipsTable
#    -sz_registrar
#        Host name or IP address and port number of registrar. This option also accepts
#        IPV6 addresses that are enclosed in square brackets.
#        Type: optional
#        (DEFAULT = "127.0.0.1:5060")
#        Dependencies: -property agent
#    -sz_requesturi
#        User or service to which the SIP request is being addressed. You can
#        include variables in this field to automatically generate large numbers
#         of unique domains.
#        Maximum length = 128 characters.
#        This option also accepts IPV6 addresses that are enclosed in square brackets.
#        Type: optional
#        (DEFAULT = sip:_ip)
#        Dependencies: -property agent
#    -sz_to
#        Logical recipient of the request. You can include variables in this 
#        field to automatically
#        generate large numbers of unique domains.. Maximum length = 128 
#        characters. This option also accepts IPV6 addresses that are enclosed in 
#        square brackets.
#        Type: optional
#        (DEFAULT = <sip:id[50000_]@_ip>)
#        Dependencies: -property agent
#    -sz_total_time
#        The total time for which an audio file will be played.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property scenarios; -scenarios_id VOICESESSION
#    -sz_transport
#        Type of transport to be used. The choices are:
#        tcp     HLT initially uses TCP as the transport. If the remote party answers
#        using UDP, HLT accepts the response and switches to UDP as the 
#        transport.
#        udp     HLT initially uses UDP as the transport. If the remote party answers
#        using TCP, HLT accepts the response and switches to TCP as the 
#        transport.
#        only_tcp     HLT uses only TCP as the transport. If the remote party answers 
#        using UDP, HLT discards the response and continues using TCP.
#        only_udp     HLT uses only UDP as the transport. If the remote party answers 
#        Using TCP, HLT discards the response and continues using UDP.
#        Type: optional
#        (DEFAULT = udp)
#        Dependencies: -property agent
#    -sz_value
#        Numerical value for the sz_action.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property rulesTable
#    -sz_wave_name
#        Waveform audio (.wav) file.
#        Type: optional
#        (DEFAULT = "...")
#        Dependencies: -property audioClipsTable
#    -type_of_service_for_rtp
#        N/A
#        Type: optional
#        (DEFAULT = best_effort)
#        Dependencies: -property agent
#    -type_of_service_for_sip
#        If enable_tos_sip is 1, this option specifies the IP Precedence / TOS (Type of
#        Service) bit setting and Assured Forwarding classes. (Default = "Best Effort
#        0x0"). If you want to specify the standard choices that are in the GUI, you can use
#        a string representation. To specify any of the other 255 TOS values, specify the
#        decimal value. The default choices are:
#        "Best Effort (0x0)" (Default) routine priority
#        "Class 1 (0x20)" Priority service, Assured Forwarding class 1
#        "Class 2 (0x40)" Immediate service, Assured Forwarding class 2
#        "Class 3 (0x60)" Flash, Assured Forwarding class 3
#        "Class 4 (0x80)" Flash-override, Assured Forwarding class 4
#        "Express Forwarding (0xA0)" Critical-ecp
#        "Control (0xC0)" Internet-control
#        Type: optional
#        (DEFAULT = best_effort)
#        Dependencies: -property agent
#    -video_bitrate
#        Bit rate of generated (synthetic) video data.
#        Type: optional
#        (DEFAULT = 128)
#        Dependencies: -property agent
#    -video_bitrate_limit
#        The videoBitrate limit in Kbps.
#        Type: optional
#        (DEFAULT = 0)
#        Dependencies: -property agent
#    -vs_n_play_mode
#        If 1, the audio file plays for a fixed number of times. If 0, the audio
#         file plays continuously.
#        Type: optional
#        (DEFAULT = 1)
#        Dependencies: -property scenarios; -scenarios_id VOICESESSION
#
# Return Values:
#    A keyed list
#        key                             value
#        ---                             -----
#        status                         SUCCESS | FAILURE
#        log                            Error message if command returns {status 0}
#        agent_handle                   when –mode add; -property agent | server
#        client_handle                  when –mode add; -property server
#        rulesTable_handle              when –mode add; -property rulesTable
#        audioClipsTable_handle         when –mode add; -property audioClipsTable
#        audioClipsTable_handle         when –mode add; -property server | agent 
#                                      (when audioClipsTableObjects are added, 
#                                       they remain in the audioClipsTable until 
#                                       they are removed, even if the test ended.
#                                       If the audioClipsTable contains objects, 
#                                       handles to those objects will be returned 
#                                       every time a client or server SIP agent 
#                                       is created)
#        scenarios_handle               when –mode add; -property scenarios
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
proc ::ixia::L47_sip_server { args } {
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
            \{::ixia::L47_sip_server $args\}]
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args

    set returnList [checkL47 SIP]
    if {[keylget returnList status] == $::FAILURE} {
        return $returnList
    }
    set mandatory_args {
            -mode        CHOICES add remove modify enable disable
    }


    set opt_args {
            -b_advisable    CHOICES 0 1
                        DEFAULT 0
        -b_best_performance    CHOICES 0
                               CHOICES 1
                               DEFAULT 1
        -b_comp_ms    CHOICES 0
                      CHOICES 1
                      DEFAULT 0
        -b_compact    CHOICES 0 1
                      DEFAULT 0
        -b_folding    CHOICES 0 1
                      DEFAULT 0
        -b_jit_ms    CHOICES 0
                     CHOICES 1
                     DEFAULT 0
        -b_limit_dtmf    CHOICES 0 1
                         DEFAULT 1
        -b_modify_power_level    CHOICES 0 1
                                 DEFAULT 0
        -b_mos_on_max    CHOICES 0
                         CHOICES 1
                         DEFAULT 0
        -b_optional    CHOICES 0 1
                       DEFAULT 0
        -b_reg_before    CHOICES 0 1
                         DEFAULT 0
        -b_rtp_start_collector    CHOICES 0 1
                                  DEFAULT 0
        -b_scattered    CHOICES 0 1
                        DEFAULT 0
        -b_silence_mode    CHOICES 0
                           CHOICES 1
                           DEFAULT 1
        -b_uas_stateless    CHOICES 0 1
                            DEFAULT 0
        -b_use_compensation    CHOICES 0 1
                               DEFAULT 0
        -b_use_jitter    CHOICES 0 1
                         DEFAULT 0
        -b_use_mos    CHOICES 0 1
                      DEFAULT 0
        -b_use_silence    CHOICES 0 1
                          DEFAULT 0
        -enable_tos_rtp    CHOICES 0 1
                           DEFAULT 0
        -enable_tos_sip    CHOICES 0 1
                           DEFAULT 0
        -handle    ANY
        -ipv6form    CHOICES 0
                     CHOICES 1
                     DEFAULT 0
        -ms_n_dtmf_duration    RANGE 60-999
                               DEFAULT 100
        -ms_n_dtmf_interdigits    RANGE 30-9999
                                  DEFAULT 40
        -ms_n_session_type    RANGE 0-2147483647
                              DEFAULT 0
        -ms_sz_codec_name    CHOICES g711alaw
                             CHOICES g711ulaw
                             CHOICES g729a
                             CHOICES g729b
                             CHOICES g726
                             CHOICES g723_1
                             CHOICES amr
                             CHOICES i_lbc
                             DEFAULT g711alaw
        -n_channels    RANGE 0-2147483647
                       DEFAULT 0
        -n_comp_jitter_buffer    RANGE 0-300
                                 DEFAULT 50
        -n_comp_jitter_ms    RANGE 0-3000
                             DEFAULT 1000
        -n_comp_max_dropped    RANGE 1-100
                               DEFAULT 7
        -n_dtmf_streams    RANGE 1-900
                           DEFAULT 10
        -n_duration    RANGE 0-2147483647
                       DEFAULT 0
        -n_jitter_buffer    RANGE 1-300
                            DEFAULT 1
        -n_jitter_ms    RANGE 1-3000
                        DEFAULT 20
        -n_mos_interval    RANGE 2-30
                           DEFAULT 3
        -n_mos_max_streams    RANGE 1-2147483647
                              DEFAULT 1
        -n_pc_interval    RANGE 1-2147483647
                          DEFAULT 500
        -n_peer_dtmf_duration    RANGE 0-2147483647
                                 DEFAULT 0
        -n_peer_dtmf_interdigits    RANGE 0-2147483647
                                    DEFAULT 0
        -n_play_time    RANGE 1-2147483647
                        DEFAULT 30
        -n_repeat_count    RANGE 1-2147483647
                           DEFAULT 1
        -n_resolution    RANGE 0-2147483647
                         DEFAULT 0
        -n_sample_rate    RANGE 0-2147483647
                          DEFAULT 0
        -n_session_type    CHOICES 0
                           CHOICES 1
                           CHOICES 2
                           DEFAULT 0
        -n_size    RANGE 0-2147483647
                   DEFAULT 0
        -n_tcp_port    RANGE 1-65535
                       DEFAULT 5060
        -n_time_unit    CHOICES 0
                        CHOICES 1
                        CHOICES 2
                        CHOICES 3
                        DEFAULT 0
        -n_timers_t1    RANGE 0-2147483647
                        DEFAULT 500
        -n_timers_t2    RANGE 0-2147483647
                        DEFAULT 4000
        -n_timers_t4    RANGE 0-2147483647
                        DEFAULT 5000
        -n_timers_tc    RANGE 0-2147483647
                        DEFAULT 180000
        -n_timers_td    RANGE 0-2147483647
                        DEFAULT 32000
        -n_total_time    RANGE 0-2147483647
                         DEFAULT 0
        -n_udp_max_size    RANGE 1024-4000
                           DEFAULT 1024
        -n_udp_port    RANGE 1-65535
                       DEFAULT 5060
        -n_wav_duration    RANGE 0-2147483647
                           DEFAULT 0
        -property    CHOICES server
                     CHOICES agent
                     CHOICES rulesTable
                     CHOICES audioClipsTable
                     CHOICES scenarios
                     DEFAULT agent
        -scenarios_id    CHOICES RECEIVEUSING180
                         CHOICES RECEIVEUSING100AND180
                         CHOICES SEND6XX
                         CHOICES VOICESESSION
        -sz_action    ANY
        -sz_audio_file    ANY
                          DEFAULT <_none>
        -sz_auth_domain    ANY
                           DEFAULT domain[0000_]
        -sz_auth_password    ANY
                             DEFAULT password[0000_]
        -sz_auth_username    ANY
                             DEFAULT user[0000_]
        -sz_bit_rate    ANY
        -sz_codec_descr    ANY
        -sz_contact    ANY
                       DEFAULT <sip:id[50000_]@_ip>
        -sz_data_format    ANY
                           DEFAULT ...
        -sz_from    ANY
                    DEFAULT <sip:id[50000_]@_ip>
        -sz_message    CHOICES register
                       DEFAULT register
        -sz_peer_codec_details    ANY
        -sz_peer_codec_name    ANY
        -sz_peer_dtmf_seq    ANY
        -sz_power_level    CHOICES pl_20
                           CHOICES pl_30
                           DEFAULT pl_20
        -sz_raw_wave_name    ANY
        -sz_registrar    REGEXP ^(|((((25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3})|(\[(?![fF]{2}[0-9a-fA-F]{2}:)(((?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4})|(((?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?)::((?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?))|(((?:[0-9A-Fa-f]{1,4}:){6,6})(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3})|(((?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?) ::((?:[0-9A-Fa-f]{1,4}:)*)(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3})))\]):([1-9]\d{0,3}|[1-5]\d{4}|6[0-4]\d{3}|65[0-4]\d\d|655[012]\d|6553[0-5])))$
                         DEFAULT 127.0.0.1:5060
        -sz_requesturi    ANY
                          DEFAULT sip:_ip
        -sz_to    ANY
                  DEFAULT <sip:id[50000_]@_ip>
        -sz_total_time    ANY
                          DEFAULT 0
        -sz_transport    CHOICES udp
                         CHOICES tcp
                         CHOICES only_udp
                         CHOICES only_tcp
                         DEFAULT udp
        -sz_value    ANY
                     DEFAULT 0
        -sz_wave_name    ANY
                         DEFAULT ...
        -type_of_service_for_rtp    ANY
                                    DEFAULT best _effort (0x0)
        -type_of_service_for_sip    ANY
                                    DEFAULT best _effort (0x0)
        -video_bitrate    RANGE 64-1000
                          DEFAULT 128
        -video_bitrate_limit    RANGE 0-2147483647
                                DEFAULT 0
        -vs_n_play_mode    CHOICES 0
                           CHOICES 1
                           DEFAULT 1
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
            set property [::ixia::ixL47GetProperty $handle sip]
        }
    }

    # scenarios parameters
    set scenarios_option_list [list procName mode handle property target \
        scenarios_id n_session_type n_repeat_count n_play_time n_total_time n_wav_duration \
        n_time_unit vs_n_play_mode sz_total_time sz_audio_file ]
    set scenarios_args [list]

    lappend option_variables scenarios_option_list
    lappend option_variables scenarios_args

    # audioClipsTable parameters
    set audioClipsTable_option_list [list procName mode handle property target \
        sz_data_format sz_raw_wave_name n_channels n_size n_resolution sz_wave_name \
        n_sample_rate n_duration ]
    set audioClipsTable_args [list]

    lappend option_variables audioClipsTable_option_list
    lappend option_variables audioClipsTable_args

    # rulesTable parameters
    set rulesTable_option_list [list procName mode handle property target \
        sz_value sz_action sz_message ]
    set rulesTable_args [list]

    lappend option_variables rulesTable_option_list
    lappend option_variables rulesTable_args

    # agent parameters
    set agent_option_list [list procName mode handle property target \
        b_comp_ms ms_n_session_type sz_auth_password b_optional sz_peer_codec_name \
        sz_from sz_power_level n_udp_port b_use_mos n_comp_jitter_ms sz_auth_username \
        b_use_compensation b_rtp_start_collector sz_registrar type_of_service_for_rtp \
        sz_transport b_use_silence n_comp_jitter_buffer n_jitter_buffer sz_peer_dtmf_seq \
        b_best_performance n_timers_t4 n_peer_dtmf_duration video_bitrate sz_codec_descr \
        sz_bit_rate n_jitter_ms n_pc_interval n_peer_dtmf_interdigits n_timers_tc \
        b_reg_before sz_contact b_compact n_udp_max_size b_scattered enable_tos_rtp \
        n_timers_t1 ms_n_dtmf_interdigits n_tcp_port b_advisable n_dtmf_streams \
        sz_auth_domain ms_n_dtmf_duration sz_to enable_tos_sip video_bitrate_limit \
        b_use_jitter b_silence_mode n_mos_max_streams n_mos_interval b_uas_stateless \
        sz_peer_codec_details b_limit_dtmf b_jit_ms sz_requesturi n_timers_td n_timers_t2 \
        ms_sz_codec_name n_comp_max_dropped b_folding type_of_service_for_sip ipv6form \
        b_mos_on_max b_modify_power_level ]
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
        scenarios {
            set returnList [eval [format "%s %s" ::ixia::ixL47SIPSERVERscenarios\
                $scenarios_args]]
            return $returnList
        }
        audioClipsTable {
            set returnList [eval [format "%s %s" ::ixia::ixL47SIPSERVERaudioClipsTable\
                $audioClipsTable_args]]
            return $returnList
        }
        rulesTable {
            set returnList [eval [format "%s %s" ::ixia::ixL47SIPSERVERrulesTable\
                $rulesTable_args]]
            return $returnList
        }
        server -
        agent {
            set returnList [eval [format "%s %s" ::ixia::ixL47SIPSERVERagent\
                $agent_args]]
            return $returnList
        }
        default {}
    }
}
