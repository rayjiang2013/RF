# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def ptp_over_mac_stats(self, mode, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    ptp_over_mac_stats
		
		 Description:
		    Retrieve statistics plane on an endpoint created
		    by a ::ixiangpf::ptp_over_mac_config command
		
		 Synopsis:
		    ptp_over_mac_stats
		        [-handle      ANY]
		        [-port_handle ANY]
		x       -mode         CHOICES aggregate session
		
		 Arguments:
		    -handle
		        The PTP handle for which the PTP statistics are to be retrieved. Valid for -mode session.
		    -port_handle
		        The port handle for which the ptp_over_mac stats need to
		        be retrieved
		x   -mode
		x       Specifies statistics retrieval mode as either aggregate for all
		x       configured sessions or on a per session basis.
		
		 Return Values:
		    $::SUCCESS | $::FAILURE
		    key:status                                                          value:$::SUCCESS | $::FAILURE
		    When status is failure, contains more information
		    key:log                                                             value:When status is failure, contains more information
		    Sessions Up
		    key:[<port_handle.>].gen.sessions_up                                value:Sessions Up
		    Sessions Down
		    key:[<port_handle.>].gen.sessions_down                              value:Sessions Down
		    Sessions Not Started
		    key:[<port_handle.>].gen.sessions_not_started                       value:Sessions Not Started
		    Sessions Total
		    key:[<port_handle.>].gen.sessions_total                             value:Sessions Total
		    Sessions Active
		    key:[<port_handle.>].gen.sessions_active                            value:Sessions Active
		    Announce Messages Sent
		    key:[<port_handle.>].gen.announce_messages_sent                     value:Announce Messages Sent
		    Announce Messages Received
		    key:[<port_handle.>].gen.announce_messages_received                 value:Announce Messages Received
		    Sync Messages Sent
		    key:[<port_handle.>].gen.sync_messages_sent                         value:Sync Messages Sent
		    Sync Messages Received
		    key:[<port_handle.>].gen.sync_messages_received                     value:Sync Messages Received
		    FollowUp Messages Sent
		    key:[<port_handle.>].gen.followup_messages_sent                     value:FollowUp Messages Sent
		    FollowUp Messages Received
		    key:[<port_handle.>].gen.followup_messages_received                 value:FollowUp Messages Received
		    DelayReq Messages Sent
		    key:[<port_handle.>].gen.delayreq_messages_sent                     value:DelayReq Messages Sent
		    DelayReq Messages Received
		    key:[<port_handle.>].gen.delayreq_messages_received                 value:DelayReq Messages Received
		    DelayResp Messages Sent
		    key:[<port_handle.>].gen.delayresp_messages_sent                    value:DelayResp Messages Sent
		    DelayResp Messages Received
		    key:[<port_handle.>].gen.delayresp_messages_received                value:DelayResp Messages Received
		    PdelayReq Messages Sent
		    key:[<port_handle.>].gen.pdelayreq_messages_sent                    value:PdelayReq Messages Sent
		    PdelayReq Messages Received
		    key:[<port_handle.>].gen.pdelayreq_messages_received                value:PdelayReq Messages Received
		    PdelayResp Messages Sent
		    key:[<port_handle.>].gen.pdelayresp_messages_sent                   value:PdelayResp Messages Sent
		    PdelayResp Messages Received
		    key:[<port_handle.>].gen.pdelayrest_messages_received               value:PdelayResp Messages Received
		    PdelayRespFollowUp Messages Sent
		    key:[<port_handle.>].gen.pdelayrespfollowup_messages_sent           value:PdelayRespFollowUp Messages Sent
		    PdelayRespFollowUp Messages Received
		    key:[<port_handle.>].gen.pdelayrespfollowup_messages_received       value:PdelayRespFollowUp Messages Received
		    Signaling Messages Sent
		    key:[<port_handle.>].gen.signaling_messages_sent                    value:Signaling Messages Sent
		    Signaling Messages Received
		    key:[<port_handle.>].gen.signaling_messages_received                value:Signaling Messages Received
		    Sync Messages Received Rate
		    key:[<port_handle.>].gen.sync_messages_received_rate                value:Sync Messages Received Rate
		    FollowUp Messages Received Rate
		    key:[<port_handle.>].gen.followup_messages_received_rate            value:FollowUp Messages Received Rate
		    DelayReq Messages Received Rate
		    key:[<port_handle.>].gen.delayreq_messages_received_rate            value:DelayReq Messages Received Rate
		    DelayResp Messages Received Rate
		    key:[<port_handle.>].gen.delayresp_messages_received_rate           value:DelayResp Messages Received Rate
		    PdelayReq Messages Received Rate
		    key:[<port_handle.>].gen.pdelayreq_messages_received_rate           value:PdelayReq Messages Received Rate
		    PdelayResp Messages Received Rate
		    key:[<port_handle.>].gen.pdelayresp_messages_received_rate          value:PdelayResp Messages Received Rate
		    PdelayRespFollowUp Messages Received Rate
		    key:[<port_handle.>].gen.pdelayrespfollowup_messages_received_rate  value:PdelayRespFollowUp Messages Received Rate
		    GPS Unit Present
		    key:[<port_handle.>].gen.gps_unit_present                           value:GPS Unit Present
		    GPS Synchronized
		    key:[<port_handle.>].gen.gps_synchronized                           value:GPS Synchronized
		    Sessions Up
		    key:[<handle.>].gen.sessions_up                                     value:Sessions Up
		    Sessions Down
		    key:[<handle.>].gen.sessions_down                                   value:Sessions Down
		    Sessions Not Started
		    key:[<handle.>].gen.sessions_not_started                            value:Sessions Not Started
		    Sessions Total
		    key:[<handle.>].gen.sessions_total                                  value:Sessions Total
		    Sessions Active
		    key:[<handle.>].gen.sessions_active                                 value:Sessions Active
		    Announce Messages Sent
		    key:[<handle.>].gen.announce_messages_sent                          value:Announce Messages Sent
		    Announce Messages Received
		    key:[<handle.>].gen.announce_messages_received                      value:Announce Messages Received
		    Sync Messages Sent
		    key:[<handle.>].gen.sync_messages_sent                              value:Sync Messages Sent
		    Sync Messages Received
		    key:[<handle.>].gen.sync_messages_received                          value:Sync Messages Received
		    FollowUp Messages Sent
		    key:[<handle.>].gen.followup_messages_sent                          value:FollowUp Messages Sent
		    FollowUp Messages Received
		    key:[<handle.>].gen.followup_messages_received                      value:FollowUp Messages Received
		    DelayReq Messages Sent
		    key:[<handle.>].gen.delayreq_messages_sent                          value:DelayReq Messages Sent
		    DelayReq Messages Received
		    key:[<handle.>].gen.delayreq_messages_received                      value:DelayReq Messages Received
		    DelayResp Messages Sent
		    key:[<handle.>].gen.delayresp_messages_sent                         value:DelayResp Messages Sent
		    DelayResp Messages Received
		    key:[<handle.>].gen.delayresp_messages_received                     value:DelayResp Messages Received
		    PdelayReq Messages Sent
		    key:[<handle.>].gen.pdelayreq_messages_sent                         value:PdelayReq Messages Sent
		    PdelayReq Messages Received
		    key:[<handle.>].gen.pdelayreq_messages_received                     value:PdelayReq Messages Received
		    PdelayResp Messages Sent
		    key:[<handle.>].gen.pdelayresp_messages_sent                        value:PdelayResp Messages Sent
		    PdelayResp Messages Received
		    key:[<handle.>].gen.pdelayrest_messages_received                    value:PdelayResp Messages Received
		    PdelayRespFollowUp Messages Sent
		    key:[<handle.>].gen.pdelayrespfollowup_messages_sent                value:PdelayRespFollowUp Messages Sent
		    PdelayRespFollowUp Messages Received
		    key:[<handle.>].gen.pdelayrespfollowup_messages_received            value:PdelayRespFollowUp Messages Received
		    Signaling Messages Sent
		    key:[<handle.>].gen.signaling_messages_sent                         value:Signaling Messages Sent
		    Signaling Messages Received
		    key:[<handle.>].gen.signaling_messages_received                     value:Signaling Messages Received
		    Status
		    key:session.<session ID>.status                                     value:Status
		    Configured Role
		    key:session.<session ID>.configured_role                            value:Configured Role
		    PTP State
		    key:session.<session ID>.ptp_state                                  value:PTP State
		    Offset [ns]
		    key:session.<session ID>.offset                                     value:Offset [ns]
		    Max Offset [ns]
		    key:session.<session ID>.offset_max                                 value:Max Offset [ns]
		    Min Offset [ns]
		    key:session.<session ID>.offset_min                                 value:Min Offset [ns]
		    Avg Offset [ns]
		    key:session.<session ID>.offset_avg                                 value:Avg Offset [ns]
		    Path Delay [ns]
		    key:session.<session ID>.path_delay                                 value:Path Delay [ns]
		    Max Path Delay [ns]
		    key:session.<session ID>.path_delay_max                             value:Max Path Delay [ns]
		    Min Path Delay [ns]
		    key:session.<session ID>.path_delay_min                             value:Min Path Delay [ns]
		    Avg Path Delay [ns]
		    key:session.<session ID>.path_delay_avg                             value:Avg Path Delay [ns]
		    Time Slope
		    key:session.<session ID>.time_slope                                 value:Time Slope
		    Port Identity
		    key:session.<session ID>.port_identity                              value:Port Identity
		    Master Port Identity
		    key:session.<session ID>.master_port_identity                       value:Master Port Identity
		    Grandmaster Port Identity
		    key:session.<session ID>.grandmaster_port_identity                  value:Grandmaster Port Identity
		    Local Clock Class
		    key:session.<session ID>.port_clock_class                           value:Local Clock Class
		    Master Clock Class
		    key:session.<session ID>.master_clock_class                         value:Master Clock Class
		    Local Clock Accuracy
		    key:session.<session ID>.port_clock_accuracy                        value:Local Clock Accuracy
		    Master Clock Accuracy
		    key:session.<session ID>.master_clock_accuracy                      value:Master Clock Accuracy
		    Current UTC Offset
		    key:session.<session ID>.current_utc_offset                         value:Current UTC Offset
		    Steps Removed
		    key:session.<session ID>.steps_removed                              value:Steps Removed
		    Leap59
		    key:session.<session ID>.leap59                                     value:Leap59
		    Leap61
		    key:session.<session ID>.leap61                                     value:Leap61
		    Frequency Traceable
		    key:session.<session ID>.frequency_traceable                        value:Frequency Traceable
		    Time Traceable
		    key:session.<session ID>.time_traceable                             value:Time Traceable
		    CF Sync [ns]
		    key:session.<session ID>.cf_sync                                    value:CF Sync [ns]
		    CF Sync Max [ns]
		    key:session.<session ID>.cf_sync_max                                value:CF Sync Max [ns]
		    CF Sync Min [ns]
		    key:session.<session ID>.cf_sync_min                                value:CF Sync Min [ns]
		    CF FollowUp [ns]
		    key:session.<session ID>.cf_follow_up                               value:CF FollowUp [ns]
		    CF FollowUp Max [ns]
		    key:session.<session ID>.cf_follow_up_max                           value:CF FollowUp Max [ns]
		    CF FollowUp Min [ns]
		    key:session.<session ID>.cf_follow_up_min                           value:CF FollowUp Min [ns]
		    CF DelayReq [ns]
		    key:session.<session ID>.cf_delay_req                               value:CF DelayReq [ns]
		    CF DelayReq Max [ns]
		    key:session.<session ID>.cf_delay_req_max                           value:CF DelayReq Max [ns]
		    CF DelayReq Min [ns]
		    key:session.<session ID>.cf_delay_req_min                           value:CF DelayReq Min [ns]
		    CF PdelayReq [ns]
		    key:session.<session ID>.cf_pdelay_req                              value:CF PdelayReq [ns]
		    CF PdelayReq Max [ns]
		    key:session.<session ID>.cf_pdelay_req_max                          value:CF PdelayReq Max [ns]
		    CF PdelayReq Min [ns]
		    key:session.<session ID>.cf_pdelay_req_min                          value:CF PdelayReq Min [ns]
		    CF DelayResp [ns]
		    key:session.<session ID>.cf_delay_resp                              value:CF DelayResp [ns]
		    CF DelayResp Max [ns]
		    key:session.<session ID>.cf_delay_resp_max                          value:CF DelayResp Max [ns]
		    CF DelayResp Min [ns]
		    key:session.<session ID>.cf_delay_resp_min                          value:CF DelayResp Min [ns]
		    CF PdelayResp [ns]
		    key:session.<session ID>.cf_pdelay_resp                             value:CF PdelayResp [ns]
		    CF PdelayResp Max [ns]
		    key:session.<session ID>.cf_pdelay_resp_max                         value:CF PdelayResp Max [ns]
		    CF PdelayResp Min [ns]
		    key:session.<session ID>.cf_pdelay_resp_min                         value:CF PdelayResp Min [ns]
		    CF PdelayRespFollowUp [ns]
		    key:session.<session ID>.cf_pdelay_resp_follow_up                   value:CF PdelayRespFollowUp [ns]
		    CF PdelayRespFollowUp Max [ns]
		    key:session.<session ID>.cf_pdelay_resp_follow_up_max               value:CF PdelayRespFollowUp Max [ns]
		    CF PdelayRespFollowUp Min [ns]
		    key:session.<session ID>.cf_pdelay_resp_follow_up_min               value:CF PdelayRespFollowUp Min [ns]
		    FM 0 Identity
		    key:session.<session ID>.fm_identity_0                              value:FM 0 Identity
		    FM 0 Port Number
		    key:session.<session ID>.fm_portNum_0                               value:FM 0 Port Number
		    FM 1 Identity
		    key:session.<session ID>.fm_identity_1                              value:FM 1 Identity
		    FM 1 Port Number
		    key:session.<session ID>.fm_port_num_1                              value:FM 1 Port Number
		    FM 2 Identity
		    key:session.<session ID>.fm_identity_2                              value:FM 2 Identity
		    FM 2 Port Number
		    key:session.<session ID>.fm_port_num_2                              value:FM 2 Port Number
		    FM 3 Identity
		    key:session.<session ID>.fm_identity_3                              value:FM 3 Identity
		    FM 3 Port Number
		    key:session.<session ID>.fm_port_num_3                              value:FM 3 Port Number
		    FM 4 Identity
		    key:session.<session ID>.fm_identity_4                              value:FM 4 Identity
		    FM 4 Port Number
		    key:session.<session ID>.fm_port_num_4                              value:FM 4 Port Number
		    Time t1 [ns]
		    key:session.<session ID>.time_t1                                    value:Time t1 [ns]
		    Time t2 [ns]
		    key:session.<session ID>.time_t2                                    value:Time t2 [ns]
		    Time t3 [ns]
		    key:session.<session ID>.time_t3                                    value:Time t3 [ns]
		    Time t4 [ns]
		    key:session.<session ID>.time_t4                                    value:Time t4 [ns]
		    Time t1 UTC
		    key:session.<session ID>.t1_utc                                     value:Time t1 UTC
		    Time t2 UTC
		    key:session.<session ID>.t2_utc                                     value:Time t2 UTC
		    Time t3 UTC
		    key:session.<session ID>.t3_utc                                     value:Time t3 UTC
		    Time t4 UTC
		    key:session.<session ID>.t4_utc                                     value:Time t4 UTC
		    IA Announce [ns]
		    key:session.<session ID>.ia_announce                                value:IA Announce [ns]
		    IA Announce Max [ns]
		    key:session.<session ID>.ia_announce_max                            value:IA Announce Max [ns]
		    IA Announce Min [ns]
		    key:session.<session ID>.ia_announce_min                            value:IA Announce Min [ns]
		    IA Sync [ns]
		    key:session.<session ID>.ia_sync                                    value:IA Sync [ns]
		    IA Sync Max [ns]
		    key:session.<session ID>.ia_sync_max                                value:IA Sync Max [ns]
		    IA Sync Min [ns]
		    key:session.<session ID>.ia_sync_min                                value:IA Sync Min [ns]
		    IA FollowUp [ns]
		    key:session.<session ID>.ia_follow_up                               value:IA FollowUp [ns]
		    IA FollowUp Max [ns]
		    key:session.<session ID>.ia_follow_up_max                           value:IA FollowUp Max [ns]
		    IA FollowUp Min [ns]
		    key:session.<session ID>.ia_follow_up_min                           value:IA FollowUp Min [ns]
		    IA DelayReq [ns]
		    key:session.<session ID>.ia_delay_req                               value:IA DelayReq [ns]
		    IA DelayReq Max [ns]
		    key:session.<session ID>.ia_delay_req_max                           value:IA DelayReq Max [ns]
		    IA DelayReq Min [ns]
		    key:session.<session ID>.ia_delay_req_min                           value:IA DelayReq Min [ns]
		    IA DelayResp [ns]
		    key:session.<session ID>.ia_delay_resp                              value:IA DelayResp [ns]
		    IA DelayResp Max [ns]
		    key:session.<session ID>.ia_delay_resp_max                          value:IA DelayResp Max [ns]
		    IA DelayResp Min [ns]
		    key:session.<session ID>.ia_delay_resp_min                          value:IA DelayResp Min [ns]
		    IA PdelayReq [ns]
		    key:session.<session ID>.ia_pdelay_req                              value:IA PdelayReq [ns]
		    IA PdelayReq Max [ns]
		    key:session.<session ID>.ia_pdelay_req_max                          value:IA PdelayReq Max [ns]
		    IA PdelayReq Min [ns]
		    key:session.<session ID>.ia_pdelay_req_min                          value:IA PdelayReq Min [ns]
		    IA PdelayResp [ns]
		    key:session.<session ID>.ia_pdelay_resp                             value:IA PdelayResp [ns]
		    IA PdelayResp Max [ns]
		    key:session.<session ID>.ia_pdelay_resp_max                         value:IA PdelayResp Max [ns]
		    IA PdelayResp Min [ns]
		    key:session.<session ID>.ia_pdelay_resp_min                         value:IA PdelayResp Min [ns]
		    IA PdelayRespFollowUp [ns]
		    key:session.<session ID>.ia_pdelay_resp_follow_up                   value:IA PdelayRespFollowUp [ns]
		    IA PdelayRespFollowUp Max [ns]
		    key:session.<session ID>.ia_pdelay_resp_follow_up_max               value:IA PdelayRespFollowUp Max [ns]
		    IA PdelayRespFollowUp Min [ns]
		    key:session.<session ID>.ia_pdelay_resp_follow_up_min               value:IA PdelayRespFollowUp Min [ns]
		    Announce Messages Sent
		    key:session.<session ID>.announce_messages_sent                     value:Announce Messages Sent
		    Announce Messages Received
		    key:session.<session ID>.announce_messages_received                 value:Announce Messages Received
		    Sync Messages Sent
		    key:session.<session ID>.sync_messages_sent                         value:Sync Messages Sent
		    Sync Messages Received
		    key:session.<session ID>.sync_messages_received                     value:Sync Messages Received
		    FollowUp Messages Sent
		    key:session.<session ID>.followup_messages_sent                     value:FollowUp Messages Sent
		    FollowUp Messages Received
		    key:session.<session ID>.followup_messages_received                 value:FollowUp Messages Received
		    DelayReq Messages Sent
		    key:session.<session ID>.delayreq_messages_sent                     value:DelayReq Messages Sent
		    DelayReq Messages Received
		    key:session.<session ID>.delayreq_messages_received                 value:DelayReq Messages Received
		    DelayResp Messages Sent
		    key:session.<session ID>.delayresp_messages_sent                    value:DelayResp Messages Sent
		    DelayResp Messages Received
		    key:session.<session ID>.delayresp_messages_received                value:DelayResp Messages Received
		    PdelayReq Messages Sent
		    key:session.<session ID>.pdelayreq_messages_sent                    value:PdelayReq Messages Sent
		    PdelayReq Messages Received
		    key:session.<session ID>.pdelayreq_messages_received                value:PdelayReq Messages Received
		    PdelayResp Messages Sent
		    key:session.<session ID>.pdelayresp_messages_sent                   value:PdelayResp Messages Sent
		    PdelayResp Messages Received
		    key:session.<session ID>.pdelayrest_messages_received               value:PdelayResp Messages Received
		    PdelayRespFollowUp Messages Sent
		    key:session.<session ID>.pdelayrespfollowup_messages_sent           value:PdelayRespFollowUp Messages Sent
		    PdelayRespFollowUp Messages Received
		    key:session.<session ID>.pdelayrespfollowup_messages_received       value:PdelayRespFollowUp Messages Received
		    Signaling Messages Sent
		    key:session.<session ID>.signaling_messages_sent                    value:Signaling Messages Sent
		    Signaling Messages Received
		    key:session.<session ID>.signaling_messages_received                value:Signaling Messages Received
		    Sync Messages Received Rate
		    key:session.<session ID>.sync_messages_received_rate                value:Sync Messages Received Rate
		    FollowUp Messages Received Rate
		    key:session.<session ID>.followup_messages_received_rate            value:FollowUp Messages Received Rate
		    DelayReq Messages Received Rate
		    key:session.<session ID>.delayreq_messages_received_rate            value:DelayReq Messages Received Rate
		
		 Examples:
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		
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
				'ptp_over_mac_stats', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
