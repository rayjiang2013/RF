#############################################################################################
#
# highLevelAPI.tcl  
#
# Copyright © 1997-2004 by IXIA.
# All Rights Reserved.
#
#   Revision Log:
#   05-06-2004  EM  Genesis

#############################################################################################



########################################################################
# Procedure:   ixStartBGP4
#
# Description: This command turns ON the protocol server to start BGP4
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from stopBgp4Server
########################################################################
proc ixStartBGP4 {TxRxArray} \
{
    upvar $TxRxArray        txRxArray

    return [startBgp4Server txRxArray]
}


########################################################################
# Procedure:   ixStopBGP4
#
# Description: This command turns ON the protocol server to stop BGP4
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from stopBgp4Server
########################################################################
proc ixStopBGP4 {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [stopBgp4Server txRxArray]
}


########################################################################
# Procedure:   ixStartOspf
#
# Description: This command turns ON the protocol server to start ospf
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startOspfServer
########################################################################
proc ixStartOspf {TxRxArray} \
{
    upvar $TxRxArray        txRxArray

    return [startOspfServer txRxArray]
}


########################################################################
# Procedure:   ixStopOspf
#
# Description: This command turns ON the protocol server to stop ospf
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from stopOspfServer
########################################################################
proc ixStopOspf {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [stopOspfServer txRxArray]
}


########################################################################
# Procedure:   ixStartIsis
#
# Description: This command turns ON the protocol server to start Isis
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startIsisServer
########################################################################
proc ixStartIsis {TxRxArray} \
{
    upvar $TxRxArray        txRxArray

    return [startIsisServer txRxArray]
}


########################################################################
# Procedure:   ixStopIsis
#
# Description: This command turns ON the protocol server to stop Isis
#
# Arguments:
#   TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from stopIsisServer
########################################################################
proc ixStopIsis {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [stopIsisServer txRxArray]
}


########################################################################
# Procedure:   ixStartRsvp
#
# Description: This command turns ON the protocol server to start Rsvp
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startRsvpServer
########################################################################
proc ixStartRsvp {TxRxArray} \
{
    upvar $TxRxArray        txRxArray

    return [startRsvpServer txRxArray]
}


########################################################################
# Procedure:   ixStopRsvp
#
# Description: This command turns ON the protocol server to stop Rsvp
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from stopRsvpServer
########################################################################
proc ixStopRsvp {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [stopRsvpServer txRxArray]
}


########################################################################
# Procedure:   ixStartRip
#
# Description: This command turns ON the protocol server to start Rip
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startRipServer
########################################################################
proc ixStartRip {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startRipServer txRxArray]
}


########################################################################
# Procedure:   ixStopRip
#
# Description: This command turns ON the protocol server to stop Rip
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopRipServer
########################################################################
proc ixStopRip {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopRipServer txRxArray]
}

########################################################################
# Procedure:   ixStartLdp
#
# Description: This command turns ON the protocol server to start LDP
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startLdpServer
########################################################################
proc ixStartLdp {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startLdpServer txRxArray]
}


########################################################################
# Procedure:   ixStopLdp
#
# Description: This command turns ON the protocol server to stop LDP
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopLdpServer
########################################################################
proc ixStopLdp {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopLdpServer txRxArray]
}

########################################################################
# Procedure:   ixStartRipng
#
# Description: This command turns ON the protocol server to start Ripng
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startRipngServer
########################################################################
proc ixStartRipng {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startRipngServer txRxArray]
}


########################################################################
# Procedure:   ixStopRipng
#
# Description: This command turns ON the protocol server to stop Ripng
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopRipngServer
########################################################################
proc ixStopRipng {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopRipngServer txRxArray]
}

########################################################################
# Procedure:   ixStartMld
#
# Description: This command turns ON the protocol server to start MLD
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startMldServer
########################################################################
proc ixStartMld {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startMldServer txRxArray]
}


########################################################################
# Procedure:   ixStopMld
#
# Description: This command turns ON the protocol server to stop MLD
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopMldServer
########################################################################
proc ixStopMld {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopMldServer txRxArray]
}



########################################################################
# Procedure:   ixStartPimsm
#
# Description: This command turns ON the protocol server to start PIM-SM
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startPimsmServer
########################################################################
proc ixStartPimsm {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startPimsmServer txRxArray]
}


########################################################################
# Procedure:   ixStopPimsm
#
# Description: This command turns ON the protocol server to stop PIM-SM
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopPimsmsServer
########################################################################
proc ixStopPimsm {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopPimsmServer txRxArray]
}


########################################################################
# Procedure:   ixStartOspfV3
#
# Description: This command turns ON the protocol server to start OSPFV3
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startOspfV3Server
########################################################################
proc ixStartOspfV3 {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startOspfV3Server txRxArray]
}


########################################################################
# Procedure:   ixStopOspfV3
#
# Description: This command turns ON the protocol server to stop OSPFV3
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopOspfV3Server
########################################################################
proc ixStopOspfV3 {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopOspfV3Server txRxArray]
}


########################################################################
# Procedure:   ixStartIgmp
#
# Description: This command turns ON the protocol server to start Igmp
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startIgmpServer
########################################################################
proc ixStartIgmp {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startIgmpServer txRxArray]
}


########################################################################
# Procedure:   ixStopIgmp
#
# Description: This command turns ON the protocol server to stop Igmp
#				without sending any leaves.
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopIgmpServer
########################################################################
proc ixStopIgmp {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopIgmpServer txRxArray]
}


########################################################################
# Procedure: ixTransmitIgmpJoin
#
# This command sends IGMP report message to the ports in the TxRxArray
#
# Argument(s):
#   TxRxArray - list or array of RX ports to change
#   groupId   - groupId Number
#   create    - create set to create for new port group
#   destroy   - destroy set to destroy to clean up the port group when
#               comnmand complete
#
########################################################################
proc ixTransmitIgmpJoin {TxRxArray { groupId 101064 } {create create} {destroy destroy}} \
{
  upvar $TxRxArray txRxArray

  return [transmitIgmpJoin txRxArray $groupId $create $destroy]

}

########################################################################
# Procedure: ixTransmitIgmpLeave
#
# This command sends IGMP leave message to the ports in the TxRxArray
#
# Argument(s):
#   TxRxArray - list or array of RX ports to change
#   groupId   - groupId Number
#   create    - create set to create for new port group
#   destroy   - destroy set to destroy to clean up the port group when
#               comnmand complete
#
########################################################################
proc ixTransmitIgmpLeave {TxRxArray { groupId 101064 } {create create} {destroy destroy}} \
{
  upvar $TxRxArray txRxArray

  return [transmitIgmpLeave txRxArray $groupId $create $destroy]

}

########################################################################
# Procedure:   ixStartStp
#
# Description: This command turns ON the protocol server to start STP
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startOspfV3Server
########################################################################
proc ixStartStp {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startStpServer txRxArray]
}


########################################################################
# Procedure:   ixStopStp
#
# Description: This command turns ON the protocol server to stop STP
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopOspfV3Server
########################################################################
proc ixStopStp {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopStpServer txRxArray]
}


########################################################################
# Procedure:   ixStartEigrp
#
# Description: This command turns ON the protocol server to start EIGRP
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startEigrpServer
########################################################################
proc ixStartEigrp {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startEigrpServer txRxArray]
}


########################################################################
# Procedure:   ixStopEigrp
#
# Description: This command turns ON the protocol server to stop EIGRP
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopEigrpServer
########################################################################
proc ixStopEigrp {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopEigrpServer txRxArray]
}

########################################################################
# Procedure:   ixStartBfd
#
# Description: This command turns ON the protocol server to start BFD
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startBfdServer
########################################################################
proc ixStartBfd {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startBfdServer txRxArray]
}


########################################################################
# Procedure:   ixStopBfd
#
# Description: This command turns ON the protocol server to stop BFD
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopBfdServer
########################################################################
proc ixStopBfd {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopBfdServer txRxArray]
}

########################################################################
# Procedure:   ixStartCfm
#
# Description: This command turns ON the protocol server to start CFM
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startCfmServer
########################################################################
proc ixStartCfm {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startCfmServer txRxArray]
}


########################################################################
# Procedure:   ixStopCfm
#
# Description: This command turns ON the protocol server to stop CFM
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopCfmServer
########################################################################
proc ixStopCfm {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopCfmServer txRxArray]
}
########################################################################
# Procedure:   ixStartLacp
#
# Description: This command turns ON the protocol server to start LACP
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startLacpServer
########################################################################
proc ixStartLacp {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startLacpServer txRxArray]
}
########################################################################
# Procedure:   ixStopLacp
#
# Description: This command turns ON the protocol server to stop LACP
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopLacpServer
########################################################################
proc ixStopLacp {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopLacpServer txRxArray]
}

########################################################################
# Procedure:   ixStartOam
#
# Description: This command turns ON the protocol server to start OAM
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startOamServer
########################################################################
proc ixStartOam {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startOamServer txRxArray]
}
########################################################################
# Procedure:   ixStopOam
#
# Description: This command turns ON the protocol server to stop OAM
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopOamServer
########################################################################
proc ixStopOam {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopOamServer txRxArray]
}



########################################################################
# Procedure:   ixStartMplsTp
#
# Description: This command turns ON the protocol server to start MPLSTP
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startMplsTpServer
########################################################################
proc ixStartMplsTp {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startMplsTpServer txRxArray]
}


########################################################################
# Procedure:   ixStopMplsTp
#
# Description: This command turns ON the protocol server to stop MPLSTP
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopMplsTpServer
########################################################################
proc ixStopMplsTp {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopMplsTpServer txRxArray]
}

########################################################################
# Procedure:   ixStartMplsOam
#
# Description: This command turns ON the protocol server to start MPLSOAM
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startMplsOamServer
########################################################################
proc ixStartMplsOam {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startMplsOamServer txRxArray]
}


########################################################################
# Procedure:   ixStopMplsOam
#
# Description: This command turns ON the protocol server to stop MPLSOAM
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopMplsOamServer
########################################################################
proc ixStopMplsOam {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopMplsOamServer txRxArray]
}

########################################################################
# Procedure:   ixStartElmi
#
# Description: This command turns ON the protocol server to start Elmi
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#
# Returns:     The return code from startElmiServer
########################################################################
proc ixStartElmi {TxRxArray} \
{
    upvar $TxRxArray       txRxArray

    return [startElmiServer txRxArray]
}


########################################################################
# Procedure:   ixStopElmi
#
# Description: This command turns ON the protocol server to stop Elmi
#
# Arguments:
#    TxRxArray - either list of ports or array of ports
#                     
# Returns:     The return code from stopElmiServer
########################################################################
proc ixStopElmi {TxRxArray} \
{
    upvar $TxRxArray      txRxArray

    return [stopElmiServer txRxArray]
}
########################################################################
# Some utility Arrays for APIs to TC Integration. 
########################################################################

#Array of valid protocols for a port mode
# any chnage for support for a protocol for a portmode should be entered here.
# Port Mode 0 POS Mode
# Port Mode 1 Ethernet/10GigWan
# Port Mode 4 10Gig LAN
# Port Mode 7 ATM Mode

set validProtocols(0) {enablePingResponse enableIgmpQueryResponse \
		enableOspfService enableBgp4Service enableIsisService enableRsvpService \
		enableRipService enableLdpService enableRipngService enableMldService \
		enableOspfV3Service enablePimsmService enableStpService enableEigrpService \
		enableBfdService enableCfmService enableOamService enableMplsTpService enableMplsOamService enableElmiService}
set validProtocols(1) {enableArpResponse enablePingResponse enableIgmpQueryResponse \
		enableOspfService enableBgp4Service enableIsisService enableRsvpService \
		enableRipService enableLdpService enableRipngService enableMldService \
		enableOspfV3Service enablePimsmService enableStpService enableEigrpService \
		enableBfdService enableCfmService enableOamService enableMplsTpService enableMplsOamService enableElmiService}
set validProtocols(4) {enableArpResponse enablePingResponse enableIgmpQueryResponse \
		enableOspfService enableBgp4Service enableIsisService enableRsvpService \
		enableRipService enableLdpService enableRipngService enableMldService \
		enableOspfV3Service enablePimsmService enableStpService enableEigrpService \
		enableBfdService enableCfmService enableOamService enableMplsTpService enableMplsOamService enableElmiService}
set validProtocols(7) {enableArpResponse enablePingResponse enableIgmpQueryResponse \
		enableOspfService enableBgp4Service enableIsisService enableRsvpService \
		enableRipService enableLdpService enableRipngService enableMldService \
		enableOspfV3Service enablePimsmService enableStpService enableEigrpService \
		enableBfdService enableCfmService enableOamService enableMplsTpService enableMplsOamService enableElmiService}
		
########################################################################		
# Set of valid commands for a particular sevice.
# When a new protocol gets added we need to add the protocol and the its commands to the list.
########################################################################

set protocolcmd(enableArpResponse)    {ARP}
set protocolcmd(enablePingResponse)   {PING}
set protocolcmd(enableCfmService)     {CFM ixStartCfm ixStopCfm}
set protocolcmd(enableBgp4Service)    {BGP4 ixStartBGP4 ixStopBGP4}
set protocolcmd(enableOspfService)    {OSPF ixStartOspf ixStopOspf}
set protocolcmd(enableIsisService)    {ISIS ixStartIsis ixStopIsis}
set protocolcmd(enableRsvpService)    {RSVP ixStartRsvp ixStopRsvp}
set protocolcmd(enableRipService)     {RIP ixStartRip ixStopRip}
set protocolcmd(enableLdpService)     {LDP ixStartLdp ixStopLdp}
set protocolcmd(enableRipngService)   {RIPNG ixStartRipng ixStopRipng}
set protocolcmd(enableMldService)     {MLD ixStartMld ixStopMld}
set protocolcmd(enableOspfV3Service)  {OSPFV3 ixStartOspfV3 ixStopOspfV3}
set protocolcmd(enablePimsmService)   {PIMSM ixStartPimsm ixStopPimsm}
set protocolcmd(enableStpService)     {STP ixStartStp ixStopStp}
set protocolcmd(enableEigrpService)   {EIGRP ixStartEigrp ixStopEigrp}
set protocolcmd(enableBfdService)     {BFD ixStartBfd ixStopBfd}
set protocolcmd(enableIgmpQueryResponse) {IGMP ixStartIgmp ixStopIgmp}
set protocolcmd(enableOamService)	  {OAM ixStartOam ixStopOam}
set protocolcmd(enableMplsTpService)  {MPLSTP ixStartMplsTp ixStopMplsTp}
set protocolcmd(enableMplsOamService)  {MPLSOAM ixStartMplsOam ixStopMplsOam}
set protocolcmd(enableElmiService)  {ELMI ixStartElmi ixStopElmi}

########################################################################
# A Static Array for all protocol Stats
########################################################################

set protocolStatList(ARP)     {}
set protocolStatList(PING)    {}
set protocolStatList(RIP)     {}
set protocolStatList(RIPNG)   {}
set protocolStatList(BGP4)    {bgpTotalSessions bgpTotalSessionsEstablished}
set protocolStatList(OSPF)    {ospfTotalSessions ospfFullNeighbors}
set protocolStatList(OSPFV3)  {ospfV3SessionsConfigured ospfV3SessionsUp}
set protocolStatList(LDP)     {ldpSessionsConfigured ldpSessionsUp ldpBasicSessionsUp}
set protocolStatList(PIMSM)   {pimsmRoutersConfigured pimsmRoutersRunning pimsmNeighborsLearned}
set protocolStatList(ISIS)    {isisSessionsConfiguredL1 isisSessionsUpL1 isisNeighborsL1 isisSessionsConfiguredL2 isisSessionsUpL2 isisNeighborsL2}
set protocolStatList(EIGRP)   {eigrpRoutersConfigured eigrpRoutersRunning eigrpNeighborsLearned}
set protocolStatList(MLD)     {rxMldFrames txMldFrames}
set protocolStatList(IGMP)    {rxIgmpFrames txIgmpFrames}
set protocolStatList(BFD)     {bfdRoutersConfigured bfdRoutersRunning bfdSessionsConfigured bfdSessionsAutoConfigured bfdAutoConfiguredSessionsUp bfdSessionsUp}
set protocolStatList(RSVP)    {rsvpIngressLSPsConfigured rsvpIngressLSPsUp rsvpEgressLSPsUp}
set protocolStatList(CFM)     {cfmBridgesConfigured cfmBridgesRunning cfmMepsConfigured  cfmMepsRunning cfmMasConfigured cfmMasRunning cfmRemoteMepsLearned \
                              cfmTrunksConfigured cfmTrunksRunning}
set protocolStatList(LACP)    {lacpDURx lacpDUTx lacpMarkerDURx lacpMarkerDUTx  lacpMarkerResponseRx lacpMarkerResponseTx lacpSessionState}
set protocolStatList(STP)     {bpduFramesSent bpduFramesReceived}
set protocolStatList(OAM)     {oamLinksConfigured oamLinksRunning oamInformationPDUsSent oamInformationPDUsReceived oamEventNotificationPDUsSent \
							   oamEventNotificationPDUsReceived oamVariableRequestPDUsSent oamVariableRequestPDUsReceived oamVariableResponsePDUsSent \
							   oamVariableResponsePDUsReceived oamLoopbackControlPDUsSent oamLoopbackControlPDUsReceived oamOrgSpecificPDUsSent oamOrgSpecificPDUsReceived}

set protocolStatList(MPLSTP)     {}
set protocolStatList(MPLSOAM)    {}
set protocolStatList(ELMI)    {}

########################################################################
# Protocol Specific stats
########################################################################
set protocolSpecificStatList(BGP4) {bgpOurIP bgpPeerIP bgpOurAS bgpPeerAS bgpOurId bgpPeerId bgpPeerHoldTimer bgpHoldTimer bgpMessageSent \
									bgpMessageReceived bgpUpdateSent bgpUpdateReceived bgpRoutesAdvertised \
									bgpRoutesWithdrawn bgpRoutesAdvertisedReceived bgpRoutesWithdrawnReceived \
									bgpRoutesPerSecondSent bgpRoutesPerSecondReceived bgpOpenSent bgpOpenReceived \
									bgpKeepAliveSent bgpKeepAliveReceived bgpNotificationSent bgpNotificationReceived \
									bgpCeaseSent bgpCeaseReceived bgpStateMachineErrorSent bgpStateMachineErrorReceived \
									bgpHoldTimeExpiredSen bgpHoldTimeExpiredReceived bgpInvalidOpenSent bgpInvalidOpenReceived \
									bgpLastErrorReceived bgpLastErrorSent bgpnvalidOpenUnsupportVersion bgpInvalidOpenUnsupportVersion \
									bgpInvalidOpenBadPeerAS bgpInvalidOpenBadBGPId bgpInvalidOpenUnsupportParm bgpInvalidOpenAuthenticationFail \
									bgpInvalidOpenUnacceptHoldTime bgpInvalidOpenSubUnspecified bgpUpdateErrorSent bgpUpdateErrorReceived \
									bgpUpdateErrorAttribListError bgpUpdateErrorUnknownWellKnownAttrib bgpUpdateErrorMissingWellKnownAttrib \
									bgpUpdateErrorAttribFlagError bgpUpdateErrorAttribLengthError bgpUpdateErrorOriginAttribInvalid \
									bgpUpdateErrorASRoutingLoop bgpUpdateErrorNextHopAttribInvalid bgpUpdateErrorOptionalAttribError \
									bgpUpdateErrorNetworkFieldInvalid bgpUpdateErrorAsPathInvalid bgpUpdateErrorSubUnspecified \
									bgpHeaderErrorSent bgpHeaderErrorReceived bgpHeaderErrorConnNotSyncron bgpHeaderErrorBadMsgLength \
									bgpHeaderErrorBadMsgType bgpHeaderErrorSubUnspecified bgpUnspecifiedErrorSent bgpUnspecifiedErrorReceived \
									bgpActiveOn bgpStartsOccured bgpStateMachineState bgpExternalConnectsReceived bgpExternalConnectsAccepted \
									bgpGracefulRestartsAttempted bgpGracefulRestartsFailed bgpRoutesReceivedBeforeStaleTimerExpired}
########################################################################
# Procedure:  _getEnabledProtocolList 
#
# Description: This private proc returns a List of the enabled protocols on 
#				a particular port.
#		
# Arguments:
#    portList - three arguments of chassis card port in format {chassId1 cardId1 portId1}
#                     
# Returns:     A List of the protocols enabled for that port.
# Assumption:  The configuration has been already loaded in the port.
########################################################################
proc _getEnabledProtocolList { chassis card port } {
	set retError 1
	set retProtocolList {}
	set a [port get $chassis $card $port]
	if {$a != 0} {
		puts "Cmd port get Failed"
		return $retError
	}
	set mode [port cget -portMode]
	global validProtocols
	
	# Get the valid protocolList from the global array with index as port mode.
	set protocolList $validProtocols($mode)

	# Get the protocolSever for the chassis card port.
	set ret [protocolServer get $chassis $card $port]
	if {$ret != 0 } {
		puts "ProtocolServer get failed"
		return $retError
	}
	foreach {protocol} $protocolList {
		if {[protocolServer cget -$protocol] == 1} {
			# If protocol is enabled then only put the values in the XML string.
			lappend retProtocolList $protocol
		}
	}
	return $retProtocolList
}


########################################################################
# Procedure:   getEnabledProtocols
#
# Description: This command returns a string in xml format for valid 
#              enabled protocols for a port.
#		
# Arguments:
#    TxRxArray - a List of format {{chassId1 cardId1 portId1} {chassId1 cardId2 portId1} \
#                                   {chassId2 cardId3 portId4} . . .{chassisId5 cardId3 portId4}}
#                     
# Returns:     A string in XML format.
# Assumption:  The configuration has been already loaded in the port.
########################################################################

proc getEnabledProtocols { portList } {

  # Set the XML header
  set str "<?xml version=\"1.0\" encoding=\"utf-8\" ?> <root id='IxRouter::PortProtocols'>"
  
  # Loop through each set of chassidId cardId portId
	foreach { portL } $portList {
		# Loop through each of the chassisId cardId portId
		# Get the chassisId cardId portId
		set ch [lindex $portL 0]
		set cd [lindex $portL 1]
		set pt [lindex $portL 2]
		
		# Call to the private proc to retrive the List of enabled protocols
		set protoList [_getEnabledProtocolList $ch $cd $pt]
		# To check if the list is empty
		if { $protoList != 1 && [llength $protoList] != 0} {
			# set  the XML tags
			set chassistag "<chassis id='$ch'>"
			set cardtag "<card id='$cd'>"
			set porttag "<port id ='$pt' >"
			#format the string with the XML tags and actual values
			set str [format "%s %s %s %s" $str $chassistag $cardtag $porttag]
		
			# Set Protocol XML tag 
			set protocoltag "<protocol>"
			set str [format "%s %s" $str $protocoltag]
			global protocolcmd
			foreach {protocol} $protoList {
				set protoCmd $protocolcmd($protocol)
				set proto [lindex $protoCmd 0]
				set start [lindex $protoCmd 1]
				set stop [lindex $protoCmd 2]
				set prototag "<$proto startCmd='$start' stopCmd='$stop'/>"
				set str [format "%s %s" $str $prototag]
			}
			# close the corresponding XML tags.
			set protocolCloseTag "</protocol>"
			set str [format "%s %s" $str $protocolCloseTag]
			set chassisCloseTag "</chassis>"
			set cardCloseTag "</card>"
			set portCloseTag "</port>"
			set str [format "%s %s %s %s" $str $portCloseTag $cardCloseTag $chassisCloseTag]
		}		
	}
	set rootCloseTag "</root>"
	set str [format "%s %s" $str $rootCloseTag]
	return $str
}

########################################################################
# Procedure:   getAvailableProtocolStats
#
# Description: This command returns a string in xml format for the valid
#				stats for an valid enabled protocol for a port.
#		
# Arguments:
#    TxRxArray - a List of format {{chassId1 cardId1 portId1} {chassId1 cardId2 portId1} \
#                                   {chassId2 cardId3 portId4} . . .{chassisId5 cardId3 portId4}}
#                     
# Returns:     A string in XML format.
# Assumption:  The configuration has been already loaded in the port.
########################################################################

######## Proc to retrieve the valid stats in the XML format in a string format for an enabled protocol ########
# Inputs : a portList { {ch1 cd1 pt1} {ch1 cd2 pt3} {ch2 cd1 pt1} .... {ch5 cd2 pt1} }
# Output : a String with the stats for a particular enabled protocol in the XML format

proc getAvailableProtocolStats { portList } {

	# Set the XML header
	set str "<?xml version=\"1.0\" encoding=\"utf-8\" ?> <root id='IxRouter::PortProtocolStats'>"

	# Loop through each set of chassidId cardId portId
	foreach { portL } $portList {
		# Get the chassisId cardId portId
		set ch [lindex $portL 0]
		set cd [lindex $portL 1]
		set pt [lindex $portL 2]

		# Call to the private proc to retrive the List of enabled protocols
		set protoList [_getEnabledProtocolList $ch $cd $pt]
		
		# To check if the list is empty
		if {$protoList != 1 && [llength $protoList] != 0} {
			# set  the XML tags
			set chassistag "<chassis id='$ch'>"
			set cardtag "<card id='$cd'>"
			set porttag "<port id ='$pt' >"
			
			# format the string with XML tags.
			set str [format "%s %s %s %s" $str $chassistag $cardtag $porttag]

			# Set Statistics XML tag 
			set stattag "<statistics>"
			set str [format "%s %s" $str $stattag]
			
			global protocolcmd
			foreach {protocol} $protoList {
				set protoCmd $protocolcmd($protocol)
				set proto [lindex $protoCmd 0]
				# Get the Stat List
				global protocolStatList
				set statList $protocolStatList($proto)
				foreach {stat} $statList {
					set statsettag "<$proto displayName=\"$stat\" type=\"numerical\"/>"
					set str [format "%s %s" $str $statsettag]
				}
			}
			# Close the corresponding XML tags.
			set protocolCloseTag "</statistics>"
			set str [format "%s %s" $str $protocolCloseTag]
			set chassisCloseTag "</chassis>"
			set cardCloseTag "</card>"
			set portCloseTag "</port>"
			set str [format "%s %s %s %s" $str $portCloseTag $cardCloseTag $chassisCloseTag]
		}
	}
	set rootCloseTag "</root>"
	set str [format "%s %s" $str $rootCloseTag]
	return $str 
}

########################################################################
# Procedure:   getBGPSpecificStats
#
# Description: This command returns a string in xml format for the valid specific
#				stats for BGP protocol for a port.
#		
# Arguments:
#    TxRxArray - a List of format {{chassId1 cardId1 portId1} {chassId1 cardId2 portId1} \
#                                   {chassId2 cardId3 portId4} . . .{chassisId5 cardId3 portId4}}
#                     
# Returns:     A string in XML format.
# Assumption:  The configuration has been already loaded in the port.
########################################################################

proc getBGPSpecificStats { portList } {

	# Set the XML header
	set str "<?xml version=\"1.0\" encoding=\"utf-8\" ?> <root id='IxRouter::PortBGPProtocolSpecificStats'>"

	# Loop through each set of chassidId cardId portId
	foreach { portL } $portList {
		# Get the chassisId cardId portId
		set ch [lindex $portL 0]
		set cd [lindex $portL 1]
		set pt [lindex $portL 2]

		# Call to the private proc to retrive the List of enabled protocols
		set protoList [_getEnabledProtocolList $ch $cd $pt]
		
		# To check if the list is empty
		if {$protoList != 1 && [llength $protoList] != 0} {
			# set  the XML tags
			set chassistag "<chassis id='$ch'>"
			set cardtag "<card id='$cd'>"
			set porttag "<port id ='$pt' >"
			
			# format the string with XML tags.
			set str [format "%s %s %s %s" $str $chassistag $cardtag $porttag]

			# Set Statistics XML tag 
			set stattag "<statistics>"
			set str [format "%s %s" $str $stattag]
			
			global protocolcmd
			global protocolSpecificStatList
			foreach {protocol} $protoList {
				set protoCmd $protocolcmd($protocol)
				set proto [lindex $protoCmd 0]
				if {$proto == "BGP4"} {
					set statList $protocolSpecificStatList($proto)
					foreach {stat} $statList {
						set statsettag "<$proto displayName=\"$stat\" type=\"numerical\"/>"
						set str [format "%s %s" $str $statsettag]
					}
				}		
			}
			# Close the corresponding XML tags.
			set protocolCloseTag "</statistics>"
			set str [format "%s %s" $str $protocolCloseTag]
			set chassisCloseTag "</chassis>"
			set cardCloseTag "</card>"
			set portCloseTag "</port>"
			set str [format "%s %s %s %s" $str $portCloseTag $cardCloseTag $chassisCloseTag]
		}
	}
	set rootCloseTag "</root>"
	set str [format "%s %s" $str $rootCloseTag]
	return $str 
}
###############################################################################
#   Procedure Name: ::ixTclNet::ExportLearnedInfoToCsv
#   Description   : This procedure exports the learned info of the given
#                   protocol into a file in .csv format
#   Input         : portDataList - [list [list chassis1 card1 port1] ...
#                                        [list chassisN cardN portN]]
#                   proto    - protocol name
#                   filename - the file where to put the output in
#                               .csv format
#   output        : the learned info in .csv format
###############################################################################
proc exportLearnedInfoToCsv {portDataList proto filename} {
    upvar $portDataList _portDataList
    foreach _portData $_portDataList {
        set errorMsg {}
        set isError [catch {[string toupper $proto]_export \
                         $_portData $filename} errorMsg]

        if {$isError} {
            expr {[regexp "invalid command name" $errorMsg] ? \
                  [puts "exportLearnedInfoToCsv is not supported for $proto"] : \
                  [puts "$errorMsg"]}
            break
        }
    }
    return $isError
}

###############################################################################
#   Procedure Name: BGP_export
#   Description   : fetches the BGP learned info and writes to a file
#                   in .csv format
#   Input         : portDataList - [list [list chassis1 card1 port1] ...
#                                        [list chassisN cardN portN]]
#                   filename - the file where to put the output in
#   output        : the learned info in .csv format
###############################################################################
proc BGP_export {portDataList filename} {

    # The proposed CSV fields
    set peerType          "i"
    set networkAddrPrefix ""
    set nextHopAddress    ""
    set metric             0
    set localPref          0
    set weight             0
    set asPath            ""
    set originType        "i"

    set filterType {bgp4FamilyIpV4Unicast}
    set fileVersion [ixProtocolUtils getCurrentIxiaFileFormatVersion]

    if {[scan $portDataList "%d %d %d" chassisId card port] != 3} {
        error "invalid argument $portDataList"
    }

    if {[bgp4Server select $chassisId $card $port]} {
        error "error in getting bgp server"
    }

    if [catch {set csvFileHadler [open $filename "w"]} errorMsg] {
       error $errorMsg
    }
    puts $csvFileHadler "#Version:$fileVersion"
    set neighborCount 0
    while {true} {
        expr {$neighborCount ? [set neighbor NextNeighbor] : \
                               [set neighbor FirstNeighbor]}

        if {[bgp4Server get$neighbor] ||
            [bgp4Neighbor requestLearnedRoutes]} {
            break
        }

        while {true} {
            if {[bgp4Neighbor getLearnedRouteList] == $::TCL_OK} {
               break;
            }
            after 1000
        }

        foreach filter $filterType {
            set learnedInfoCount 0
            while {true} {
                expr {$learnedInfoCount ? [set route Next] : \
                                          [set route First]}

                set bgpLinfo [bgp4LearnedRoute get$route $filter]
                if {$bgpLinfo} {
                    break
                }

                # populate csv fields
                expr {[bgp4Neighbor cget -type] ? [set peerType "e"] : \
                                                  [set peerType "i"]}

                set routeDescription [bgp4LearnedRoute cget -description]

                puts "--->$routeDescription"
                set networkAddrPrefix [string trim [lindex [split [lindex [split \
                        $routeDescription ","] 0] ":"] 1]]

                set nextHopAddress [string trim [lindex [split [lindex [split \
                        $routeDescription ","] 1] ":"] 1]]

                set metric     [bgp4LearnedRoute cget -multiExitDiscriminator]
                set localPref  [bgp4LearnedRoute cget -localPreference]
                set asPath     [bgp4LearnedRoute cget -asPath]
                set originType [bgp4LearnedRoute cget -originType]

                # format AS path to underscore seperated format
                # AS Path format in learned info <100 200 65538>{333,300,131074}<200> 
                # should be exported as          <100_200_65538>{333_300_131074}<200>
                # into the ixia formatted csv file

                set _asPath [string map { "> <" "><"
                                       "> (" ">("
                                       "> \[" ">\["
                                       "> \{" ">\{"
                                       ") <" ")<"
                                       ") (" ")("
                                       ") \[" ")\["
                                       ") \{" ")\{"
                                       "\} <" "\}<"
                                       "\} (" "\}("
                                       "\} \[" "\}\["
                                       "\} \{" "\}\{"
                                       "\] <" "\]<"
                                       "\] (" "\]("
                                       "\] \[" "\]\["
                                       "\] \{" "\]\{"
                                       " " "_"
                                       "," "_"} $asPath]
                set asPath $_asPath
               
                # format originType
                set _originType [string map -nocase {"IGP"        "i"  \
                                                     "EGP"        "e"  \
                                                     "Unknown"     ""  \
                                                     "Incomplete" "?"} \
                                                     $originType]
                set originType $_originType        

                set tuple [join [list $peerType          \
                                      $networkAddrPrefix \
                                      $nextHopAddress    \
                                      $metric            \
                                      $localPref         \
                                      $weight            \
                                      $asPath            \
                                      $originType] ","]
                puts $csvFileHadler $tuple
                incr learnedInfoCount
            } ;# end while getFirstRoute getNextRoute
            incr neighborCount
        } ;# end for each route type
    } ;# end while getFirstNeighbor getNextNeighbor
    close $csvFileHadler
}
