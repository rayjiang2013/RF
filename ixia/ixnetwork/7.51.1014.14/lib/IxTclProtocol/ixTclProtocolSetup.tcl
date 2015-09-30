#############################################################################################
#
# ixTclProtocolSetup.tcl
#
#  Package initialization file
#
# Copyright © 1997-2003 by IXIA.
# All Rights Reserved.
#
#############################################################################################
## these are the simple ones that don't have any ptr parameters...


set ixTclProtocol::noArgList    { protocolServer}

## these are the ones that we need simple pointers returned for other stuff...
set ixTclProtocol::pointerList   { ldpAtmLabelRange ldpLearnedIpV4AtmLabel \
                              ldpAssignedAtmLabel \
                              stpInterface  stpLan stpInterfaceLearnedInfo stpCistInterfaceLearnedInfo stpMstiInterfaceLearnedInfo stpVlanInterfaceLearnedInfo stpMstiVlan \
							  ixNetInterfaceIpV4 ixNetInterfaceIpV6 ixNetDhcpV4Tlv}

## these are basically all the protocols that require a portPtr parameter for instantiation
                                   
## this initial list is all the complicated ones
set ixTclProtocol::commandList  { bgp4Server bgp4InternalTable bgp4InternalNeighborItem bgp4ExternalTable bgp4ExternalNeighborItem \
                             bgp4Neighbor bgp4RouteFilter bgp4LearnedRoute bgp4RouteItem bgp4AsPathItem bgpStatsQuery bgp4StatsQuery bgp4IncludePrefixFilter \
                             bgp4VpnL3Site bgp4VpnL2Site bgp4VpnTarget bgp4VpnRouteRange bgp4UmhTarget bgp4UmhSelectionRouteRange bgp4VpnLabelBlock \
							 bgp4MplsRouteRange  bgp4ExtendedCommunity bgp4VpnImportTarget bgp4UmhImportTarget bgp4McastReceiverSite bgp4McastSenderSite bgp4OpaqueValueElement bgp4SenderSiteOpaqueValueElement bgp4LearnedOpaqueValueElement \
							 bgp4OpaqueRouteRange bgp4RouteImportOptions bgp4VpnBgpAdVplsRange bgp4UserDefinedAfiSafi bgp4UserDefinedAfiSafiRoute\
                             ospfServer ospfRouter ospfRouteRange ospfInterface ospfRouterLsaInterface ospfUserLsa ospfUserLsaGroup ospfNetworkRange \
                             isisServer isisRouter isisRouteRange isisInterface isisUnicastMacRange isisDceInterestedVlanRange isisGridTePath isisGridOutsideLink \
                             isisGridRangeTe isisGridEntryTe isisGridRoute isisGridInternodeRoute isisGrid isisDceMulticastMacRange \
                             isisDceTopologyRange isisDceNodeTopologyRange \
			     isisSpbISidRange isisSpbBaseVidRange isisSpbTopologyRange \
			     isisSpbOutsideLinks isisSpbmNodeISidRange isisSpbmNodeBaseVidRange isisSpbmNodeTopologyRange isisSpbmNetworkRange \
				isisSpbLearnedRbridges isisTrillLearnedMacUnicast \
                             isisDceMulticastIpv4GroupRange isisDceMulticastIpv6GroupRange isisDceNetworkRange \
                             isisNodeUnicastMacRange isisDceNodeMacGroups isisDceNodeIpv4Groups isisDceNodeIpv6Groups isisDceOutsideLinks isisDceNodeInterestedVlanRange\
                             isisLearnedIpv4Multicast isisLearnedIpv6Multicast isisLearnedMacMulticast \
                             isisLearnedIpv4UnicastItem isisLearnedIpv6UnicastItem isisLearnedMacUnicastItem \
                             isisLearnedRbridges isisLearnedIpv4Prefixes isisLearnedIpv6Prefixes \
							 ripngServer ripngRouter ripngRouteRange ripngInterface \
                             rsvpServer rsvpNeighborPair rsvpDestinationRange rsvpSenderRange rsvpEroItem rsvpRroItem rsvpPlrNodeIdPair rsvpTunnelLeafRange \
							 rsvpCustomTlv rsvpTunnelHeadToLeaf rsvpTunnelTailTrafficEndPoint rsvpTunnelHeadTrafficEndPoint \
							 ripServer ripInterfaceRouter ripRouteRange \
                             ldpServer ldpRouter ldpInterface ldpAdvertiseFecRange ldpLearnedIpV4Label ldpLearnedMartiniLabel learnedBgpAdVplsLabels \
                             ldpL2VpnInterface ldpL2VpnVcRange ldpTargetedPeer ldpL2VplsMacRange ldpExplicitIncludeIpFec ldpRequestFecRange ldpL2VpnIpRange ldpL2VpnMacVlanRange\
                             ldpMulticastLeafRange ldpOpaqueValueElement ldpLearnedMulticastLabel ldpLearnedOpaqueValueElement \
							 mldServer mldHost mldGroupRange mldSourceRange mldQuerier mldLearnedInfo\
							 igmpVxServer igmpHost igmpGroupRange igmpSourceRange igmpQuerier igmpLearnedInfo\
							 ospfV3Server ospfV3Router ospfV3Interface ospfV3RouteRange ospfV3NetworkRange ospfV3UserLsaGroup ospfV3LsaRouterInterface \
							 ospfV3IpV6Prefix ospfV3LsaAsExternal ospfV3LsaInterAreaPrefix ospfV3LsaInterAreaRouter ospfV3LsaIntraAreaPrefix \
							 ospfV3LsaLink ospfV3LsaNetwork ospfV3LsaRouter \
							 pimsmServer pimsmRouter pimsmInterface pimsmJoinPrune pimsmSource pimsmDataMdtRange pimsmLearnedJoinState pimsmInterfaceLearnedInfo pimsmLearnedDataMdt pimsmMdtLearnedjoinState\
							 pimsmCRPRange pimsmLearnedCRP pimsmLearnedBSR \
							 stpServer stpBridge stpBridgeLearnedInfo stpBridgeLearnedInfo stpBridgeCistLearnedInfo stpBridgeMstiLearnedInfo stpMsti stpBridgeVlanLearnedInfo stpVlan\
							 eigrpServer eigrpRouter eigrpInterface eigrpRouteRange eigrpRouteLearnedInfo\
							 bfdServer   bfdRouter  bfdInterface  bfdSession bfdSessionLearnedInfo\
							 cfmServer cfmBridge cfmInterface cfmMp cfmTrunk cfmLink cfmMdLevel cfmVlan cfmCcmLearnedInfo cfmLtLearnedInfo cfmLbLearnedInfo cfmDelayLearnedInfo \
							 cfmPbbTeCcmLearnedInfo cfmPbbTeLbLearnedInfo cfmLtLearnedHop cfmCustomTlv\
							 cfmPbbTeLtLearnedInfo cfmPbbTeDelayLearnedInfo cfmPeriodicOamLtLearnedInfo \
							 cfmPeriodicOamLbLearnedInfo cfmPeriodicOamDmLearnedInfo cfmPbbTePeriodicOamLtLearnedInfo \
							 cfmPbbTePeriodicOamLbLearnedInfo cfmPbbTePeriodicOamDmLearnedInfo cfmAisLearnedInfo cfmLckLearnedInfo cfmTstLearnedInfo \
							 cfmLossLearnedInfo cfmPeriodicOamLmLearnedInfo \
							 lacpServer lacpLink lacpLearnedInfo\
							 linkOamServer linkOamLink linkOamInterface linkOamSymTlv linkOamFrameTlv linkOamPeriodTlv linkOamSSTlv linkOamOrgEventTlv\
							 linkOamOrgInfoTlv linkOamVarContainer linkOamOrgTlv linkOamVarDescriptor \
							 linkOamDiscLearnedInfo linkOamEventNotifnLearnedInfo linkOamVarRequestLearnedInfo \
							 mplsTpServer mplsTpRouter mplsTpInterface mplsTpLspPwRange mplsTpGeneralLearnedInfo mplsTpLmLearnedInfo mplsTpDmLearnedInfo \
							 mplsTpPingLearnedInfo mplsTpTracerouteLearnedInfo mplsTpHopLearnedInfo\
							 mplsOamServer mplsOamRouter mplsOamInterface mplsOamGeneralLearnedInfo mplsOamTriggeredPingLearnedInfo mplsOamTracerouteLearnedInfo mplsOamHopLearnedInfo \
							 elmiServer elmiUni elmiUniStatus elmiEvc elmiBwProfile elmiCeVlanIdRange \
							 elmiLmiStatusLearnedInfo elmiUniStatusLearnedInfo elmiEvcStatusLearnedInfo \
							 ixNetInterfaceTable ixNetInterfaceEntry ixNetDhcpV4Properties ixNetDhcpV6Properties ixNetDhcpV6Tlv ixProtocolUtils}

set myList [join [list $ixTclProtocol::noArgList $ixTclProtocol::pointerList $ixTclProtocol::commandList]]
eval lappend ::halCommands $myList

set ixTclProtocol::redefineCommandList { bgp4RouteImportOptions bgp4Neighbor }
set ::halRedefineCommands [join [list $::halRedefineCommands $ixTclProtocol::redefineCommandList]]

if [isWindows] {

      set orgDirPath [pwd]
      
      #this script is supposed to be in $installDir/TclScripts/Lib/IxTclProtocol, and it's supposed to load $installDir/IxTclProtocol.dll.

	  ###### Check IxOS compatibility ######
	  set ixosCompatible false
	  set ixosIncompatible false

	  set configFilePath [file dirname [file dirname [file dirname [file dirname [info script]]]]]
	  # puts "configFilePath:$configFilePath"
	  set configFileName "IxNProto.config"
	  if {[file exists [file join $configFilePath $configFileName]]} {      
			if { ![catch {open $configFilePath/$configFileName} fid] } {
				# Get the IXOS version
				set ixosVersion [package req IxTclHal]
				# puts "ixosVersion:$ixosVersion"

				while {![eof $fid]} {
					set line [gets $fid]
					set splittedLine [split $line "=,"]
					# puts "splittedLine:$splittedLine"
					foreach s $splittedLine {
						# puts "s:$s"
						set ret [string compare [string trim $s] "IxOSSupportedVersion"]
						if {$ret == 0} {
							foreach v $splittedLine {
								# puts "v:$v"
								set vRet [string compare [string trim $v] $ixosVersion]
								if {$vRet == 0} {
									#puts "IxOS Matched v:$v"
									set ixosCompatible true
									break
								}								
							}
							if {$ixosCompatible == "false" } {
								puts "Error: The IxNProtocols does not support the given IxOS - $ixosVersion. Please use an IxOS from the list - $splittedLine. Else install a different IxNProtocols that is supported with the given IxOS version."
								set ixosIncompatible true
								break
							}
						} 
						if {$ixosCompatible == "true" || $ixosIncompatible == "true"} {
							# puts "ixosCompatible:$ixosCompatible.. breaking"
							break
						}
					}
					if {$ixosCompatible == "true" || $ixosIncompatible ==  "true"} {
						# puts "ixosCompatible:$ixosCompatible.. breaking"
						# break from While loop
						break  
					}
				}
				close $fid
			}
	  }
	  ###### Done ######
	if {$ixosCompatible ==  "true"} {
		# Commenting out the following line since tcl8.3 does not support the file api "normalize", whereas tcl8.4 does
		# IxOS wish console uses tcl8.4 and IxOS ScriptGen.exe uses tcl8.3
		# To acheive the functionality we are using basic tcl apis which are supported in both tcl8.3 and tcl8.4
		# Reference bug ids for IxTclProtocol multiversion support: 404313, 404319, 487119, 487114
      
		#set dllPath [file normalize [file join [file dirname [info script]] .. .. ..]]
		set  dllPath [file dirname [file dirname [file dirname [file dirname [info script]]]]]
      
		# Try to load the VC8 DLL first. If not found, then try to load the VC6 DLL.
		# Once we completely move to VC8, we will not search for VC6 DLL
		# we have completely moved to VC10, we will not search for VC8 DLL
		  set dllFile "IxTclProtocol_vc10.dll"
		  if {![file exists [file join $dllPath $dllFile]]} {
			  set dllFile "IxTclProtocol.dll"
		  }
		  if {[catch {cd $dllPath} cdResult]} {
			  error "couldn't load $dllFile (failed to cd [file dirname $dllPath])"
		  } else {
			  #puts "loading $dllPath/$dllFile"
			  if {[catch {load $dllPath/$dllFile} loadResult]} {
				  set savedInfo $::errorInfo
				  cd $orgDirPath
				  error $loadResult $savedInfo
			  } else {
				  cd $orgDirPath
			  }
		  }
	}
	rename protocolServer ""

    ############################ OBJECT INSTANTIATION ##########################

    foreach procName $ixTclProtocol::noArgList {
        set tclCmd [format "TCL%s%s" [string toupper [string index $procName 0]] [string range $procName 1 end]]
        ixTclHal::createCommand $tclCmd $procName
    }
    foreach procName $ixTclProtocol::pointerList {
        set tclCmd [format "TCL%s%s" [string toupper [string index $procName 0]] [string range $procName 1 end]]
        ixTclHal::createCommandPtr $tclCmd $procName
    }

    # BGP command set
    ixTclHal::createCommandPtr TCLBgp4McastReceiverSite bgp4McastReceiverSite
	ixTclHal::createCommandPtr TCLOpaqueValueElement bgp4SenderSiteOpaqueValueElement
    ixTclHal::createCommandPtr TCLBgp4McastSenderSite bgp4McastSenderSite \$::bgp4SenderSiteOpaqueValueElementPtr
    ixTclHal::createCommandPtr TCLBgp4OpaqueRouteRange		bgp4OpaqueRouteRange
    ixTclHal::createCommandPtr TCLBgp4RouteImportOptions	bgp4RouteImportOptions
    ixTclHal::createCommandPtr TCLBgp4AsPathItem        bgp4AsPathItem
	ixTclHal::createCommandPtr TCLBgp4ExtendedCommunity bgp4ExtendedCommunity
	ixTclHal::createCommandPtr TCLLearnedOpaqueValueElement bgp4LearnedOpaqueValueElement

    ixTclHal::createCommandPtr TCLBgp4RouteItem         bgp4RouteItem       \$::bgp4AsPathItemPtr \$::bgp4ExtendedCommunityPtr
    ixTclHal::createCommandPtr TCLBgp4RouteFilter       bgp4RouteFilter
    ixTclHal::createCommandPtr TCLBgp4LearnedRoute      bgp4LearnedRoute    \$::bgp4LearnedOpaqueValueElementPtr
	ixTclHal::createCommandPtr TCLBgp4MplsRouteRange	bgp4MplsRouteRange  \$::bgp4AsPathItemPtr \$::bgp4ExtendedCommunityPtr
	ixTclHal::createCommandPtr TCLBgp4IncludePrefixFilter	bgp4IncludePrefixFilter
    
    ixTclHal::createCommandPtr TCLBgp4VpnRouteRange bgp4VpnRouteRange  \$::bgp4AsPathItemPtr  \$::bgp4ExtendedCommunityPtr
	ixTclHal::createCommandPtr TCLBgp4VpnLabelBlock bgp4VpnLabelBlock  
    ixTclHal::createCommandPtr TCLBgp4VpnTarget     bgp4VpnTarget
	ixTclHal::createCommandPtr TCLBgp4VpnTarget     bgp4VpnImportTarget	
    ixTclHal::createCommandPtr TCLBgp4UmhSelectionRouteRange bgp4UmhSelectionRouteRange  \$::bgp4AsPathItemPtr  \$::bgp4ExtendedCommunityPtr
    ixTclHal::createCommandPtr TCLBgp4UmhTarget     bgp4UmhTarget
	ixTclHal::createCommandPtr TCLBgp4UmhTarget     bgp4UmhImportTarget
    ixTclHal::createCommandPtr TCLOpaqueValueElement bgp4OpaqueValueElement
    ixTclHal::createCommandPtr TCLBgp4VpnL3Site     bgp4VpnL3Site      \$::bgp4VpnRouteRangePtr \$::bgp4VpnTargetPtr   \$::bgp4VpnImportTargetPtr  \$::bgp4LearnedRoutePtr \
																		\$::bgp4McastReceiverSitePtr \$::bgp4McastSenderSitePtr \$::bgp4OpaqueValueElementPtr \$::bgp4UmhTargetPtr \$::bgp4UmhImportTargetPtr \$::bgp4UmhSelectionRouteRangePtr
	ixTclHal::createCommandPtr TCLBgp4VpnL2Site     bgp4VpnL2Site      \$::bgp4VpnLabelBlockPtr \$::bgp4LearnedRoutePtr
	ixTclHal::createCommandPtr TCLBgp4VpnBgpAdVplsRange     bgp4VpnBgpAdVplsRange      \$::bgp4LearnedRoutePtr
	ixTclHal::createCommandPtr TCLBgp4UserDefinedAfiSafiRoute     bgp4UserDefinedAfiSafiRoute
	ixTclHal::createCommandPtr TCLBgp4UserDefinedAfiSafi     bgp4UserDefinedAfiSafi   \$::bgp4UserDefinedAfiSafiRoutePtr

    ixTclHal::createCommandPtr TCLBgp4Neighbor      bgp4Neighbor		\$::bgp4RouteItemPtr \$::bgp4VpnL3SitePtr \$::bgp4VpnL2SitePtr \$::bgp4RouteFilterPtr \$::bgp4LearnedRoutePtr  \$::bgp4MplsRouteRangePtr \
																		\$::bgp4IncludePrefixFilterPtr \$::bgp4OpaqueRouteRangePtr \$::bgp4RouteImportOptionsPtr \$::bgp4VpnBgpAdVplsRangePtr \$::bgp4UserDefinedAfiSafiPtr
    ixTclHal::createCommandPtr TCLBgp4InternalNeighborItem  bgp4InternalNeighborItem \$::bgp4RouteItemPtr
    ixTclHal::createCommandPtr TCLBgp4ExternalNeighborItem  bgp4ExternalNeighborItem \$::bgp4RouteItemPtr
    ixTclHal::createCommand    TCLBgp4Server                bgp4Server               \$::bgp4NeighborPtr
    
    ixTclHal::createCommand    TCLBgp4ExternalTable         bgp4ExternalTable        \$::bgp4ExternalNeighborItemPtr
    ixTclHal::createCommand    TCLBgp4InternalTable         bgp4InternalTable        \$::bgp4InternalNeighborItemPtr
    ixTclHal::createCommand    TCLBGPStatsQuery             bgp4StatsQuery
    ixTclHal::createCommand    TCLBGPStatsQuery             bgpStatsQuery   ;# this one is provided for backwards compatibility


    # OSPF command set
        
    ixTclHal::createCommandPtr TCLOspfRouteRange         ospfRouteRange
    ixTclHal::createCommandPtr TCLOspfRouterLsaInterface ospfRouterLsaInterface

    ixTclHal::createCommandPtr TCLOspfUserLsa            ospfUserLsa            \$::ospfRouterLsaInterfacePtr
    ixTclHal::createCommandPtr TCLOspfUserLsaGroup       ospfUserLsaGroup       \$::ospfUserLsaPtr

    ixTclHal::createCommandPtr TCLOspfNetworkRange       ospfNetworkRange
    ixTclHal::createCommandPtr TCLOspfInterface          ospfInterface          \$::ospfUserLsaPtr \$::ospfNetworkRangePtr
    ixTclHal::createCommandPtr TCLOspfRouter             ospfRouter             \$::ospfInterfacePtr \$::ospfRouteRangePtr \$::ospfUserLsaGroupPtr

    ixTclHal::createCommand    TCLOspfServer             ospfServer             \$::ospfRouterPtr    
     

     # Isis command set
    
    ixTclHal::createCommandPtr TCLIsisLearnedIpv4UnicastItem isisLearnedIpv4UnicastItem
    ixTclHal::createCommandPtr TCLIsisLearnedIpv4Multicast isisLearnedIpv4Multicast \$::isisLearnedIpv4UnicastItemPtr

    ixTclHal::createCommandPtr TCLIsisLearnedIpv6UnicastItem isisLearnedIpv6UnicastItem
    ixTclHal::createCommandPtr TCLIsisLearnedIpv6Multicast isisLearnedIpv6Multicast \$::isisLearnedIpv6UnicastItemPtr

    ixTclHal::createCommandPtr TCLIsisLearnedMacUnicastItem isisLearnedMacUnicastItem
    ixTclHal::createCommandPtr TCLIsisLearnedMacMulticast isisLearnedMacMulticast   \$::isisLearnedMacUnicastItemPtr

    ixTclHal::createCommandPtr TCLIsisLearnedRbridges isisLearnedRbridges 
    ixTclHal::createCommandPtr TCLIsisLearnedIpv4Prefixes isisLearnedIpv4Prefixes 
    ixTclHal::createCommandPtr TCLIsisLearnedIpv6Prefixes isisLearnedIpv6Prefixes 
    ixTclHal::createCommandPtr TCLIsisSpbLearnedRbridges isisSpbLearnedRbridges 
	ixTclHal::createCommandPtr TCLIsisTrillLearnedMacUnicast isisTrillLearnedMacUnicast

	ixTclHal::createCommandPtr TCLIsisDceNodeInterestedVlanRange isisDceNodeInterestedVlanRange
	ixTclHal::createCommandPtr TCLIsisDceOutsideLinks isisDceOutsideLinks
	ixTclHal::createCommandPtr TCLIsisDceNodeIpv6Groups isisDceNodeIpv6Groups
	ixTclHal::createCommandPtr TCLIsisDceNodeIpv4Groups isisDceNodeIpv4Groups
	ixTclHal::createCommandPtr TCLIsisDceNodeMacGroups isisDceNodeMacGroups
	ixTclHal::createCommandPtr TCLIsisNodeUnicastMacRange isisNodeUnicastMacRange
	ixTclHal::createCommandPtr TCLIsisDceNodeTopologyRange isisDceNodeTopologyRange \$::isisDceNodeInterestedVlanRangePtr
	ixTclHal::createCommandPtr TCLIsisDceNetworkRange isisDceNetworkRange	\$::isisNodeUnicastMacRangePtr \$::isisDceNodeMacGroupsPtr \$::isisDceNodeIpv4GroupsPtr \
																			\$::isisDceNodeIpv6GroupsPtr \$::isisDceOutsideLinksPtr \
																			 \$::isisDceNodeTopologyRangePtr
    ixTclHal::createCommandPtr TCLIsisDceMulticastIpv6GroupRange isisDceMulticastIpv6GroupRange
    ixTclHal::createCommandPtr TCLIsisDceMulticastIpv4GroupRange isisDceMulticastIpv4GroupRange
	ixTclHal::createCommandPtr TCLIsisDceMulticastMacRange isisDceMulticastMacRange
	ixTclHal::createCommandPtr TCLIsisUnicastMacRange isisUnicastMacRange
	ixTclHal::createCommandPtr TCLIsisDceInterestedVlanRange  isisDceInterestedVlanRange
	ixTclHal::createCommandPtr TCLIsisDceTopologyRange isisDceTopologyRange \$::isisDceInterestedVlanRangePtr
	ixTclHal::createCommandPtr TCLIsisGridTePath          isisGridTePath
	ixTclHal::createCommandPtr TCLIsisGridInternodeRoute  isisGridInternodeRoute
	ixTclHal::createCommandPtr TCLIsisGridOutsideLink     isisGridOutsideLink    \$::isisGridInternodeRoutePtr
    ixTclHal::createCommandPtr TCLIsisGridTe              isisGridRangeTe
    ixTclHal::createCommandPtr TCLIsisGridTe              isisGridEntryTe
    ixTclHal::createCommandPtr TCLIsisGridRoute           isisGridRoute
    ixTclHal::createCommandPtr TCLIsisGrid                isisGrid    \$::isisGridOutsideLinkPtr   \$::isisGridRangeTePtr  \$::isisGridEntryTePtr \
																	  \$::isisGridRoutePtr    \$::isisGridInternodeRoutePtr    \$::isisGridTePathPtr
    ixTclHal::createCommandPtr TCLIsisSpbISidRange          isisSpbISidRange
    ixTclHal::createCommandPtr TCLIsisSpbBaseVidRange     isisSpbBaseVidRange    \$::isisSpbISidRangePtr
    ixTclHal::createCommandPtr TCLIsisSpbTopologyRange     isisSpbTopologyRange    \$::isisSpbBaseVidRangePtr
    ixTclHal::createCommandPtr TCLIsisSpbOutsideLinks		isisSpbOutsideLinks
    ixTclHal::createCommandPtr TCLIsisSpbmNodeISidRange          isisSpbmNodeISidRange
    ixTclHal::createCommandPtr TCLIsisSpbmNodeBaseVidRange     isisSpbmNodeBaseVidRange    \$::isisSpbmNodeISidRangePtr
    ixTclHal::createCommandPtr TCLIsisSpbmNodeTopologyRange     isisSpbmNodeTopologyRange    \$::isisSpbmNodeBaseVidRangePtr
    ixTclHal::createCommandPtr TCLIsisSpbmNetworkRange isisSpbmNetworkRange \$::isisSpbOutsideLinksPtr \$::isisSpbmNodeTopologyRangePtr
    ixTclHal::createCommandPtr TCLIsisInterface          isisInterface
    ixTclHal::createCommandPtr TCLIsisRouteRange         isisRouteRange
    
    ixTclHal::createCommandPtr TCLIsisRouter             isisRouter             \$::isisInterfacePtr \$::isisRouteRangePtr  \$::isisGridPtr \$::isisUnicastMacRangePtr \$::isisDceMulticastMacRangePtr \
                                                                                \$::isisDceMulticastIpv4GroupRangePtr \$::isisDceMulticastIpv6GroupRangePtr \$::isisDceNetworkRangePtr \
                                                                                \$::isisLearnedIpv4MulticastPtr  \$::isisLearnedIpv6MulticastPtr  \$::isisLearnedMacMulticastPtr \
                                                                                \$::isisLearnedRbridgesPtr  \$::isisLearnedIpv4PrefixesPtr  \$::isisLearnedIpv6PrefixesPtr  \$::isisDceTopologyRangePtr \$::isisSpbTopologyRangePtr  \$::isisSpbmNetworkRangePtr \$::isisSpbLearnedRbridgesPtr \$::isisTrillLearnedMacUnicastPtr

    ixTclHal::createCommand    TCLIsisServer             isisServer             \$::isisRouterPtr    
     
    
	# RSVP command set
	ixTclHal::createCommandPtr TCLRsvpTunnelTailTrafficEndPoint   rsvpTunnelTailTrafficEndPoint    
	ixTclHal::createCommandPtr TCLRsvpTunnelHeadTrafficEndPoint   rsvpTunnelHeadTrafficEndPoint     
	ixTclHal::createCommandPtr TCLRsvpTunnelHeadToLeaf   rsvpTunnelHeadToLeaf     
	ixTclHal::createCommandPtr TCLRsvpTunnelLeafRange    rsvpTunnelLeafRange
    ixTclHal::createCommandPtr TCLRsvpEroItem            rsvpEroItem
    ixTclHal::createCommandPtr TCLRsvpRroItem            rsvpRroItem
	ixTclHal::createCommandPtr TCLRsvpPlrNodeIdPair      rsvpPlrNodeIdPair
	ixTclHal::createCommandPtr TCLRsvpCustomTlv          rsvpCustomTlv
    ixTclHal::createCommandPtr TCLRsvpSenderRange        rsvpSenderRange		\$::rsvpPlrNodeIdPairPtr  \$::rsvpCustomTlvPtr \$::rsvpTunnelHeadToLeafPtr \$::rsvpTunnelHeadTrafficEndPointPtr
    ixTclHal::createCommandPtr TCLRsvpDestinationRange   rsvpDestinationRange   \$::rsvpSenderRangePtr \$::rsvpRroItemPtr \$::rsvpEroItemPtr \$::rsvpTunnelLeafRangePtr \$::rsvpCustomTlvPtr \$::rsvpTunnelTailTrafficEndPointPtr
    ixTclHal::createCommandPtr TCLRsvpNeighborPair       rsvpNeighborPair       \$::rsvpDestinationRangePtr  \$::rsvpCustomTlvPtr

    ixTclHal::createCommand    TCLRsvpServer             rsvpServer \$::rsvpNeighborPairPtr    


    # RIP command set 
	     
    ixTclHal::createCommandPtr TCLRipRouteRange          ripRouteRange
    ixTclHal::createCommandPtr TCLRipInterfaceRouter     ripInterfaceRouter     \$::ripRouteRangePtr
    
    ixTclHal::createCommand    TCLRipServer              ripServer               \$::ripInterfaceRouterPtr    


    # RIPNG command set

    ixTclHal::createCommandPtr TCLRipngInterface         ripngInterface
    ixTclHal::createCommandPtr TCLRipngRouteRange        ripngRouteRange
    ixTclHal::createCommandPtr TCLRipngRouter            ripngRouter            \$::ripngRouteRangePtr \$::ripngInterfacePtr

    ixTclHal::createCommand    TCLRipngServer            ripngServer            \$::ripngRouterPtr


    # LDP command set   

	ixTclHal::createCommandPtr TCLLdpL2VpnMacVlanRange	  ldpL2VpnMacVlanRange
	ixTclHal::createCommandPtr TCLLdpL2VpnIpRange		  ldpL2VpnIpRange
    ixTclHal::createCommandPtr TCLLdpAdvertiseFecRange    ldpAdvertiseFecRange
    ixTclHal::createCommandPtr TCLLdpRequestFecRange      ldpRequestFecRange
    ixTclHal::createCommandPtr TCLLdpTargetedPeer         ldpTargetedPeer
    ixTclHal::createCommandPtr TCLLdpLearnedIpV4Label     ldpLearnedIpV4Label
    ixTclHal::createCommandPtr TCLLearnedOpaqueValueElement ldpLearnedOpaqueValueElement
    ixTclHal::createCommandPtr TCLMulticastLDPLearnedLabelIPv4 ldpLearnedMulticastLabel    \$::ldpLearnedOpaqueValueElementPtr
    ixTclHal::createCommandPtr TCLLdpRouterLearnedIpV4Label    learnedBgpAdVplsLabels
	ixTclHal::createCommandPtr TCLLdpExplicitIncludeIpFec ldpExplicitIncludeIpFec

	ixTclHal::createCommandPtr TCLLdpLearnedMartiniLabel ldpLearnedMartiniLabel
    ixTclHal::createCommandPtr TCLLdpL2VplsMacRange		 ldpL2VplsMacRange
	
    ixTclHal::createCommandPtr TCLLdpL2VpnVcRange        ldpL2VpnVcRange			\$::ldpL2VplsMacRangePtr \$::ldpL2VpnIpRangePtr \$::ldpL2VpnMacVlanRangePtr
    ixTclHal::createCommandPtr TCLLdpL2VpnInterface      ldpL2VpnInterface          \$::ldpL2VpnVcRangePtr
    
    ixTclHal::createCommandPtr TCLOpaqueValueElement	 ldpOpaqueValueElement
    ixTclHal::createCommandPtr TCLLdpMulticastLeafRange  ldpMulticastLeafRange      \$::ldpOpaqueValueElementPtr
        
    ixTclHal::createCommandPtr TCLLdpInterface  ldpInterface    \$::ldpTargetedPeerPtr \$::ldpLearnedIpV4LabelPtr \$::ldpLearnedMartiniLabelPtr \
                                                                \$::ldpLearnedIpV4AtmLabelPtr \$::ldpAssignedAtmLabelPtr \$::ldpAtmLabelRangePtr \
                                                                \$::ldpLearnedMulticastLabelPtr
	                                                                
    ixTclHal::createCommandPtr TCLLdpRouter     ldpRouter       \$::ldpInterfacePtr \$::ldpAdvertiseFecRangePtr \$::ldpL2VpnInterfacePtr \$::ldpExplicitIncludeIpFecPtr \
								\$::ldpRequestFecRangePtr \$::learnedBgpAdVplsLabelsPtr \$::ldpMulticastLeafRangePtr

    ixTclHal::createCommand    TCLLdpServer     ldpServer       \$::ldpRouterPtr    

	# MLD command set
	ixTclHal::createCommandPtr TCLMldQuerierLearnedInfo  mldLearnedInfo
	ixTclHal::createCommandPtr TCLMldQuerier             mldQuerier		\$::mldLearnedInfoPtr
	ixTclHal::createCommandPtr TCLMldSourceRange        mldSourceRange
    ixTclHal::createCommandPtr TCLMldGroupRange			mldGroupRange	\$::mldSourceRangePtr
    ixTclHal::createCommandPtr TCLMldHost		        mldHost         \$::mldGroupRangePtr
    ixTclHal::createCommand    TCLMldServer             mldServer		\$::mldHostPtr	\$::mldQuerierPtr
	

	# OspfV3 command set
	  
    ixTclHal::createCommandPtr    TCLOspfV3LsaRouterInterface	   ospfV3LsaRouterInterface
    ixTclHal::createCommandPtr    TCLOspfV3IpV6Prefix	           ospfV3IpV6Prefix
	ixTclHal::createCommandPtr    TCLOspfV3LsaGrace				   ospfV3LsaGrace
    ixTclHal::createCommandPtr    TCLOspfV3LsaAsExternal	       ospfV3LsaAsExternal
	ixTclHal::createCommandPtr    TCLOspfV3LsaInterAreaPrefix	   ospfV3LsaInterAreaPrefix
    ixTclHal::createCommandPtr    TCLOspfV3LsaInterAreaRouter	   ospfV3LsaInterAreaRouter
    ixTclHal::createCommandPtr    TCLOspfV3LsaIntraAreaPrefix	   ospfV3LsaIntraAreaPrefix   \$::ospfV3IpV6PrefixPtr
    ixTclHal::createCommandPtr    TCLOspfV3LsaLink	               ospfV3LsaLink			  \$::ospfV3IpV6PrefixPtr
    ixTclHal::createCommandPtr    TCLOspfV3LsaNetwork	           ospfV3LsaNetwork
    ixTclHal::createCommandPtr    TCLOspfV3LsaRouter	           ospfV3LsaRouter		\$::ospfV3LsaRouterInterfacePtr

    ixTclHal::createCommandPtr TCLOspfV3UserLsaGroup  ospfV3UserLsaGroup    \$::ospfV3LsaAsExternalPtr  \
																			\$::ospfV3LsaInterAreaPrefixPtr  \
																			\$::ospfV3LsaInterAreaRouterPtr  \
																			\$::ospfV3LsaIntraAreaPrefixPtr  \
																			\$::ospfV3LsaLinkPtr  \
																			\$::ospfV3LsaNetworkPtr  \
																			\$::ospfV3LsaRouterPtr

	ixTclHal::createCommandPtr TCLOspfV3RouteRange         ospfV3RouteRange
	ixTclHal::createCommandPtr TCLOspfV3NetworkRange       ospfV3NetworkRange

    ixTclHal::createCommandPtr TCLOspfV3Interface          ospfV3Interface          
    ixTclHal::createCommandPtr TCLOspfV3Router             ospfV3Router             \$::ospfV3InterfacePtr \
                                                                                    \$::ospfV3RouteRangePtr \
                                                                                    \$::ospfV3UserLsaGroupPtr \
                                                                                    \$::ospfV3NetworkRangePtr \
																					\$::ospfV3LsaAsExternalPtr  \
																					\$::ospfV3LsaInterAreaPrefixPtr  \
																					\$::ospfV3LsaInterAreaRouterPtr  \
																					\$::ospfV3LsaIntraAreaPrefixPtr  \
																					\$::ospfV3LsaLinkPtr  \
																					\$::ospfV3LsaNetworkPtr  \
																					\$::ospfV3LsaRouterPtr  \
																					\$::ospfV3LsaGracePtr

    ixTclHal::createCommand    TCLOspfV3Server             ospfV3Server             \$::ospfV3RouterPtr     


	# IGMP command set
	ixTclHal::createCommandPtr TCLIgmpQuerierLearnedInfo  igmpLearnedInfo
	ixTclHal::createCommandPtr TCLIgmpQuerier             igmpQuerier		  \$::igmpLearnedInfoPtr
	ixTclHal::createCommandPtr TCLIgmpSourceRange        igmpSourceRange
	ixTclHal::createCommandPtr TCLIgmpGroupRange		 igmpGroupRange	   \$::igmpSourceRangePtr
	ixTclHal::createCommandPtr TCLIgmpHost               igmpHost          \$::igmpGroupRangePtr
	ixTclHal::createCommand    TCLIgmpVxServer           igmpVxServer	   \$::igmpHostPtr \$::igmpQuerierPtr 
	
	# PIM/SM command set
	ixTclHal::createCommandPtr TCLPimsmMdtLearnedJoinState		pimsmMdtLearnedJoinState
	ixTclHal::createCommandPtr TCLPimsmLearnedDataMdt			pimsmLearnedDataMdt
	ixTclHal::createCommandPtr TCLPimsmInterfaceLearnedCRPInfo	pimsmLearnedCRP
	ixTclHal::createCommandPtr TCLPimsmInterfaceLearnedBSRInfo	pimsmLearnedBSR
	ixTclHal::createCommandPtr TCLPimsmInterfaceLearnedInfo		pimsmInterfaceLearnedInfo
	ixTclHal::createCommandPtr TCLPimsmDataMdtRange		 pimsmDataMdtRange		\$::pimsmMdtLearnedJoinStatePtr
	ixTclHal::createCommandPtr TCLPimsmCRPRange			 pimsmCRPRange
	ixTclHal::createCommandPtr TCLPimsmLearnedJoinState	 pimsmLearnedJoinState	
	ixTclHal::createCommandPtr TCLPimsmJoinPrune         pimsmJoinPrune			\$::pimsmLearnedDataMdtPtr
   	ixTclHal::createCommandPtr TCLPimsmSource            pimsmSource		    \$::pimsmLearnedJoinStatePtr
   	ixTclHal::createCommandPtr TCLPimsmInterface         pimsmInterface         \$::pimsmJoinPrunePtr \$::pimsmSourcePtr \$::pimsmDataMdtRangePtr \$::pimsmInterfaceLearnedInfoPtr \$::pimsmCRPRangePtr \$::pimsmLearnedBSRPtr \$::pimsmLearnedCRPPtr
	ixTclHal::createCommandPtr TCLPimsmRouter            pimsmRouter            \$::pimsmInterfacePtr 
    ixTclHal::createCommand    TCLPimsmServer            pimsmServer            \$::pimsmRouterPtr    

    # STP command set
    
	ixTclHal::createCommandPtr TCLStpVlan					stpVlan
	ixTclHal::createCommandPtr TCLStpBridgeLearnedInfo      stpBridgeLearnedInfo        \$::stpInterfaceLearnedInfoPtr    
	ixTclHal::createCommandPtr TCLStpBridgeVlanLearnedInfo  stpBridgeVlanLearnedInfo    \$::stpVlanInterfaceLearnedInfoPtr
	ixTclHal::createCommandPtr TCLStpBridgeCistLearnedInfo  stpBridgeCistLearnedInfo    \$::stpCistInterfaceLearnedInfoPtr
	ixTclHal::createCommandPtr TCLStpBridgeMstiLearnedInfo  stpBridgeMstiLearnedInfo    \$::stpMstiInterfaceLearnedInfoPtr
	ixTclHal::createCommandPtr TCLStpMsti                   stpMsti						\$::stpMstiVlanPtr
	ixTclHal::createCommandPtr TCLStpBridge                 stpBridge					\$::stpInterfacePtr  \$::stpBridgeLearnedInfoPtr  \$::stpBridgeCistLearnedInfoPtr  \$::stpBridgeMstiLearnedInfoPtr   \$::stpBridgeVlanLearnedInfoPtr \$::stpMstiPtr \$::stpVlanPtr
    ixTclHal::createCommand    TCLStpServer                 stpServer					\$::stpBridgePtr     \$::stpLanPtr  
	
	

	
	#EIGRP command set

	ixTclHal::createCommandPtr TCLEigrpRouteLearnedInfo eigrpRouteLearnedInfo
	ixTclHal::createCommandPtr TCLEigrpInterface eigrpInterface
	ixTclHal::createCommandPtr TCLEigrpRouteRange eigrpRouteRange
	ixTclHal::createCommandPtr TCLEigrpRouter eigrpRouter		\$::eigrpInterfacePtr \$::eigrpRouteRangePtr \$::eigrpRouteLearnedInfoPtr
	ixTclHal::createCommand    TCLEigrpServer eigrpServer		\$::eigrpRouterPtr

	#BFD command set
	ixTclHal::createCommandPtr TCLBfdLearnedInfo bfdSessionLearnedInfo
	ixTclHal::createCommandPtr TCLBfdSession	bfdSession
	ixTclHal::createCommandPtr TCLBfdInterface  bfdInterface  \$::bfdSessionPtr
	ixTclHal::createCommandPtr TCLBfdRouter		bfdRouter		 \$::bfdInterfacePtr  \$::bfdSessionLearnedInfoPtr
	ixTclHal::createCommand    TCLBfdServer		bfdServer		 \$::bfdRouterPtr
	
	#CFM command set
	ixTclHal::createCommandPtr TCLCfmLtLearnedHop					cfmLtLearnedHop
	ixTclHal::createCommandPtr TCLCfmPbtPeriodicOamDmLearnedInfo	cfmPbbTePeriodicOamDmLearnedInfo
	ixTclHal::createCommandPtr TCLCfmPbtPeriodicOamLbLearnedInfo	cfmPbbTePeriodicOamLbLearnedInfo
	ixTclHal::createCommandPtr TCLCfmPbtPeriodicOamLtLearnedInfo	cfmPbbTePeriodicOamLtLearnedInfo	\
																		\$::cfmLtLearnedHopPtr
	ixTclHal::createCommandPtr TCLCfmPeriodicOamLbLearnedInfo		cfmPeriodicOamLbLearnedInfo
	ixTclHal::createCommandPtr TCLCfmPeriodicOamDmLearnedInfo		cfmPeriodicOamDmLearnedInfo
	ixTclHal::createCommandPtr TCLCfmPeriodicOamLtLearnedInfo		cfmPeriodicOamLtLearnedInfo \
																		\$::cfmLtLearnedHopPtr
	ixTclHal::createCommandPtr TCLCfmPbtLtLearnedInfo	cfmPbbTeLtLearnedInfo \
															\$::cfmLtLearnedHopPtr

	ixTclHal::createCommandPtr TCLCfmPeriodicOamLmLearnedInfo	cfmPeriodicOamLmLearnedInfo
	ixTclHal::createCommandPtr TCLCfmLossLearnedInfo	cfmLossLearnedInfo
	ixTclHal::createCommandPtr TCLCfmTstLearnedInfo		cfmTstLearnedInfo
	ixTclHal::createCommandPtr TCLCfmLckLearnedInfo		cfmLckLearnedInfo
	ixTclHal::createCommandPtr TCLCfmAisLearnedInfo		cfmAisLearnedInfo
	ixTclHal::createCommandPtr TCLCfmPbtDmLearnedInfo	cfmPbbTeDelayLearnedInfo
	ixTclHal::createCommandPtr TCLCfmPbtLbLearnedInfo	cfmPbbTeLbLearnedInfo
	ixTclHal::createCommandPtr TCLCfmPbtCcmLearnedInfo	cfmPbbTeCcmLearnedInfo
	ixTclHal::createCommandPtr TCLCfmItuLearnedInfo		cfmDelayLearnedInfo
	ixTclHal::createCommandPtr TCLCfmLbLearnedInfo		cfmLbLearnedInfo
	ixTclHal::createCommandPtr TCLCfmLtLearnedInfo		cfmLtLearnedInfo	\$::cfmLtLearnedHopPtr
	ixTclHal::createCommandPtr TCLCfmCcmLearnedInfo		cfmCcmLearnedInfo
	ixTclHal::createCommandPtr TCLCfmCustomTlv			cfmCustomTlv
	ixTclHal::createCommandPtr TCLCfmVlan				cfmVlan		
	ixTclHal::createCommandPtr TCLCfmMdLevel			cfmMdLevel
	ixTclHal::createCommandPtr TCLCfmLink				cfmLink
	ixTclHal::createCommandPtr TCLCfmTrunk				cfmTrunk
	ixTclHal::createCommandPtr TCLCfmMP					cfmMp
	ixTclHal::createCommandPtr TCLCfmInterface			cfmInterface
	ixTclHal::createCommandPtr TCLCfmBridge				cfmBridge		\$::cfmInterfacePtr	\$::cfmMpPtr \
														\$::cfmTrunkPtr \$::cfmLinkPtr \$::cfmMdLevelPtr \
														\$::cfmVlanPtr \$::cfmCustomTlvPtr \$::cfmCcmLearnedInfoPtr \
														\$::cfmPbbTeCcmLearnedInfoPtr \$::cfmLtLearnedInfoPtr \
														\$::cfmLbLearnedInfoPtr  \$::cfmPbbTeLbLearnedInfoPtr \
														\$::cfmDelayLearnedInfoPtr \$::cfmPbbTeLtLearnedInfoPtr \
														\$::cfmPbbTeDelayLearnedInfoPtr \
														\$::cfmPeriodicOamLtLearnedInfoPtr \
														\$::cfmPeriodicOamLbLearnedInfoPtr \
														\$::cfmPeriodicOamDmLearnedInfoPtr \
														\$::cfmPbbTePeriodicOamLtLearnedInfoPtr \
														\$::cfmPbbTePeriodicOamLbLearnedInfoPtr \
														\$::cfmPbbTePeriodicOamDmLearnedInfoPtr \
														\$::cfmAisLearnedInfoPtr \
														\$::cfmLckLearnedInfoPtr \
														\$::cfmTstLearnedInfoPtr \
														\$::cfmLossLearnedInfoPtr \
														\$::cfmPeriodicOamLmLearnedInfoPtr



	ixTclHal::createCommand    TCLCfmServer				cfmServer		\$::cfmBridgePtr

	#LACP command set
	ixTclHal::createCommandPtr TCLLacpLearnedInfo		lacpLearnedInfo
	ixTclHal::createCommandPtr TCLLacpLink				lacpLink		
	ixTclHal::createCommand    TCLLacpServer			lacpServer		\$::lacpLinkPtr \$::lacpLearnedInfoPtr
	#OAM command set
	ixTclHal::createCommandPtr TCLOamVarRequestLearnedInfo		linkOamVarRequestLearnedInfo
	ixTclHal::createCommandPtr TCLOamEventNotifnLearnedInfo		linkOamEventNotifnLearnedInfo
	ixTclHal::createCommandPtr TCLOamDiscLearnedInfo	linkOamDiscLearnedInfo
	ixTclHal::createCommandPtr TCLOamVarDescriptor		linkOamVarDescriptor
	ixTclHal::createCommandPtr TCLOamOrgSpecTLV			linkOamOrgTlv
	ixTclHal::createCommandPtr TCLOamVarRespDbContainer	linkOamVarContainer
	ixTclHal::createCommandPtr TCLOamOrgSpecInfoTLV		linkOamOrgInfoTlv
	ixTclHal::createCommandPtr TCLOamOrgSpecEventTLV	linkOamOrgEventTlv
	ixTclHal::createCommandPtr TCLOamErrFrameSSTlv		linkOamSSTlv
	ixTclHal::createCommandPtr TCLOamErrFramePeriodTlv	linkOamPeriodTlv
	ixTclHal::createCommandPtr TCLOamErrFrameTlv		linkOamFrameTlv
	ixTclHal::createCommandPtr TCLOamErrSymbolPeriodTlv	linkOamSymTlv
	ixTclHal::createCommandPtr TCLOamInterface			linkOamInterface
	ixTclHal::createCommandPtr TCLOamLink				linkOamLink		\$::linkOamInterfacePtr	\$::linkOamSymTlvPtr \
																		\$::linkOamFrameTlvPtr	\$::linkOamPeriodTlvPtr \
																		\$::linkOamSSTlvPtr	\$::linkOamOrgEventTlvPtr \
																		\$::linkOamOrgInfoTlvPtr	\$::linkOamVarContainerPtr \
																		\$::linkOamOrgTlvPtr	\$::linkOamVarDescriptorPtr \
																		\$::linkOamDiscLearnedInfoPtr \
																		\$::linkOamEventNotifnLearnedInfoPtr \
																		\$::linkOamVarRequestLearnedInfoPtr \
																		
	ixTclHal::createCommand    TCLOamServer				linkOamServer		\$::linkOamLinkPtr 

    #MPLSTP Command
    ixTclHal::createCommandPtr    TCLMplsTpHopsLearnedInfo	mplsTpHopLearnedInfo
    ixTclHal::createCommandPtr    TCLMplsTpTraceRouteLearnedInfo mplsTpTracerouteLearnedInfo \$::mplsTpHopLearnedInfoPtr
    ixTclHal::createCommandPtr    TCLMplsTpPingLearnedInfo	mplsTpPingLearnedInfo
    ixTclHal::createCommandPtr    TCLMplsTpLmLearnedInfo	mplsTpLmLearnedInfo
    ixTclHal::createCommandPtr    TCLMplsTpDmLearnedInfo	mplsTpDmLearnedInfo
    ixTclHal::createCommandPtr    TCLMplsTpCccvLearnedInfo	mplsTpGeneralLearnedInfo
    ixTclHal::createCommandPtr    TCLMplsTpLspPwRange		mplsTpLspPwRange
    ixTclHal::createCommandPtr    TCLMplsTpInterface	    mplsTpInterface		\$::mplsTpLspPwRangePtr
    ixTclHal::createCommandPtr    TCLMplsTpRouter			mplsTpRouter		\$::mplsTpInterfacePtr \$::mplsTpGeneralLearnedInfoPtr \$::mplsTpDmLearnedInfoPtr \
																				\$::mplsTpLmLearnedInfoPtr \$::mplsTpPingLearnedInfoPtr \$::mplsTpTracerouteLearnedInfoPtr
    ixTclHal::createCommand       TCLMplsTpServer			mplsTpServer		\$::mplsTpRouterPtr
    
    #MPLSOAM Command
    ixTclHal::createCommandPtr	  TCLMplsOamHopsLearnedInfo					mplsOamHopLearnedInfo
    ixTclHal::createCommandPtr	  TCLMplsOamTraceRouteLearnedInfo			mplsOamTracerouteLearnedInfo \$::mplsOamHopLearnedInfoPtr
    ixTclHal::createCommandPtr    TCLMplsOamTriggeredPingLearnedInfo		mplsOamTriggeredPingLearnedInfo
    ixTclHal::createCommandPtr    TCLMplsOamGeneralLearnedInfo				mplsOamGeneralLearnedInfo
    ixTclHal::createCommandPtr    TCLMplsOamInterface						mplsOamInterface		
    ixTclHal::createCommandPtr    TCLMplsOamRouter							mplsOamRouter		\$::mplsOamInterfacePtr 
															
    ixTclHal::createCommand       TCLMplsOamServer							mplsOamServer		\$::mplsOamRouterPtr \$::mplsOamGeneralLearnedInfoPtr \$::mplsOamTriggeredPingLearnedInfoPtr \$::mplsOamTracerouteLearnedInfoPtr
    
    #ELMI command set
    ixTclHal::createCommandPtr TCLElmiLmiStatusLearnedInfo elmiLmiStatusLearnedInfo
    ixTclHal::createCommandPtr TCLElmiUniStatusLearnedInfo elmiUniStatusLearnedInfo
    ixTclHal::createCommandPtr TCLElmiEvcStatusLearnedInfo elmiEvcStatusLearnedInfo
	ixTclHal::createCommandPtr TCLElmiBwProfile			elmiBwProfile
	ixTclHal::createCommandPtr TCLElmiCeVlanIdRange			elmiCeVlanIdRange
	ixTclHal::createCommandPtr TCLElmiEvc				elmiEvc			\$::elmiBwProfilePtr \$::elmiCeVlanIdRangePtr 
	ixTclHal::createCommandPtr TCLElmiUniStatus			elmiUniStatus	\$::elmiBwProfilePtr
	ixTclHal::createCommandPtr TCLElmiUni				elmiUni			\$::elmiUniStatusPtr \$::elmiEvcPtr \
																		\$::elmiLmiStatusLearnedInfoPtr \$::elmiUniStatusLearnedInfoPtr \$::elmiEvcStatusLearnedInfoPtr
	
	ixTclHal::createCommand    TCLElmiServer			elmiServer		\$::elmiUniPtr    
    
	#IxNetInterfaceTable command set
	
    # dhcpV6Tlv command is exactly the same as dhcpV4Tlv.  We use the same underlying C++ object.
	ixTclHal::createCommandPtr TCLIxNetDhcpV4Tlv			ixNetDhcpV6Tlv	
    ixTclHal::createCommandPtr TCLIxNetDhcpV6Properties		ixNetDhcpV6Properties		\$::ixNetDhcpV6TlvPtr

    ixTclHal::createCommandPtr TCLIxNetDhcpV4Properties		ixNetDhcpV4Properties	\$::ixNetDhcpV4TlvPtr
    ixTclHal::createCommandPtr TCLIxNetInterfaceEntry		ixNetInterfaceEntry     \$::ixNetInterfaceIpV4Ptr \$::ixNetInterfaceIpV6Ptr \$::ixNetDhcpV4PropertiesPtr \$::ixNetDhcpV6PropertiesPtr
    ixTclHal::createCommand    TCLIxNetInterfaceTable		ixNetInterfaceTable     \$::ixNetInterfaceEntryPtr

    ixTclHal::createCommand    TCLProtocolUtils              ixProtocolUtils
}

