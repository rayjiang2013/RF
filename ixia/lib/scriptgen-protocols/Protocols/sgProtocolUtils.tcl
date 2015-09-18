#############################################################################################
#
#  sgProtocolUtils.tcl $ - Utilities for scriptgen
#
#   Copyright © 1997 - 2004 by IXIA.
#   All Rights Reserved.
#
#	Revision Log:
#	05-12-2004	EM	Genesis
#
#
#############################################################################################

########################################################################
# Procedure: handleProtocolsOddParams
#
# This command takes care of protocols odd parameters like 
# Arguments(s):
# cmd       : command
#
# Returned Result: The enum text.
########################################################################


proc scriptGen::handleProtocolsOddParams {cmd {parameter ""} } \
{
	variable enumsArray

    set enumText ""

	if { $cmd == "ospfV3Interface" } {
        set enumText [doOspfV3Options [ospfV3Interface cget -options] $enumsArray(ospfV3Interface,options)]
    }
	
	if { $cmd == "ospfV3LsaRouter" } {
        set enumText [doOspfV3Options [ospfV3LsaRouter cget -options] $enumsArray(ospfV3LsaRouter,options)]
    }
	
	if { $cmd == "ospfV3LsaNetwork" } {
        set enumText [doOspfV3Options [ospfV3LsaNetwork cget -options] $enumsArray(ospfV3LsaNetwork,options)]
    }

	if { $cmd == "ospfV3LsaLink" } {
        set enumText [doOspfV3Options [ospfV3LsaLink cget -options] $enumsArray(ospfV3LsaLink,options)]
    }

	if { $cmd == "ospfV3LsaInterAreaRouter" } {
        set enumText [doOspfV3Options [ospfV3LsaInterAreaRouter cget -options] $enumsArray(ospfV3LsaInterAreaRouter,options)]
    }

	if { $cmd == "ospfV3IpV6Prefix" } {
        set enumText [doOspfV3Options [ospfV3IpV6Prefix cget -options] $enumsArray(ospfV3IpV6Prefix,options)]
    }

	if { $cmd == "ospfV3LsaInterAreaPrefix" } {
        set enumText [doOspfV3Options [ospfV3LsaInterAreaPrefix cget -prefixOptions] $enumsArray(ospfV3LsaInterAreaPrefix,prefixOptions)]
    }
	if { $cmd == "ospfV3LsaAsExternal" } {
        set enumText [doOspfV3Options [ospfV3LsaAsExternal cget -prefixOptions] $enumsArray(ospfV3LsaAsExternal,prefixOptions)]
    }

    if { $cmd == "protocolServer" } {
        set enumText false
    }

    if { $parameter == "communityList" } {
        set value 0
        switch $cmd {
            bgp4RouteItem { 
                set value [bgp4RouteItem cget -communityList] 
            } 
            bgp4VpnRouteRange { 
                set value [bgp4VpnRouteRange cget -communityList] 
            }
            bgp4MplsRouteRange { 
                set value [bgp4MplsRouteRange cget -communityList] 
            }
        }
        set enumText [format "\"%s\"" [getCommunityListEnum $value]]
    }

    if { $cmd == "isisInterface" || $cmd == "isisRouter"} {
       set newValue [list]
	    foreach item [$cmd cget -$parameter] { 
			regsub -all "\"" $item {\\"} item
            regsub -all "{" $item "\\{" item
			regsub -all "}" $item "\\}" item
			lappend newValue $item
		}
        set enumText [format "\{%s\}" $newValue]
    }

    return $enumText
}


########################################################################
# Procedure: createProtocolsObsoleteParamsArray
#
# Description: This command creates obsolete params array
#
# Arguments(s):
#
# Result:   Always returns 0
#
########################################################################
proc scriptGen::createProtocolsObsoleteParamsArray { } \
{
    variable obsoleteParamsArray 
    set retCode 0

    set asPathParamList [list enableAsPathSeq asPathSeqList enableAsPathSet \
                              asPathSetList enableAsPathConfedSeq asPathConfedSeqList \
                              enableAsPathConfedSet asPathConfedSetList]
 
    set obsoleteParamsArray(bgp4AsPathItem) $asPathParamList  

	
    set protocolParamList [list arpServerEnable pingServerEnable repeatCount \
                                rate MacAddress IpAddress count mapType]
    set obsoleteParamsArray(protocolServer) $protocolParamList

	set isisRouteRangeParamList [list extendedDefaultMetric]
	set obsoleteParamsArray(isisRouteRange) $isisRouteRangeParamList

	set protocolInterfaceList [list ipAddress ipMask maskWidth networkIpAddress]
	set obsoleteParamsArray(ospfInterface) $protocolInterfaceList
	set obsoleteParamsArray(ldpInterface) $protocolInterfaceList

	# note that the traffic engineering ones are really deprecated
    set isisInterfaceList [list ipAddress ipMask maskWidth networkIpAddress trafficEngineeringMetric1 trafficEngineeringMetric2 enableTrafficEngineering]
	set obsoleteParamsArray(isisInterface) $isisInterfaceList
	
	set ldpAdvertiseFecRangeList [list baseLabel]
	set obsoleteParamsArray(ldpAdvertiseFecRange) $ldpAdvertiseFecRangeList

    set obsoleteParamsArray(pimsmServer) [list messagesPerInterval]

    set obsoleteParamsArray(pimsmJoinPrune) [list  joinPruneRate joinPruneRateDuration]
    
    set obsoleteParamsArray(bgp4Neighbor) [list  externalNeighborASNum asNumMode]
    set obsoleteParamsArray(pimsmInterface) [list  neighborIpV6]
    set obsoleteParamsArray(pimsmInterface) [list showSelectedRPSetOnly]
	
    set obsoleteParamsArray(cfmBridge) [list function userSelectDstMepById userSelectSrcMepById aisInterval enableAis]
    set obsoleteParamsArray(cfmMp) [list dmmPriority]
    set obsoleteParamsArray(cfmTrunk) [list dmmPriority]
    
    set obsoleteParamsArray(isisDceNetworkRange) [list startBroadcastRootPriority startBroadcastRootPriorityStep numberOfMultiDestinationTrees startSwitchId switchIdStep switchIdPriority]

    set obsoleteParamsArray(isisRouter) [list deviceId switchId devicePriority fTagValue broadcastRootPriority numberOfMultiDestinationTrees switchIdPriority enableFtag startFtagValue]
        
    set obsoleteParamsArray(bgp4Server) [list enableLabelExchangeOverLsp]
    set obsoleteParamsArray(ldpServer) [list enableLabelExchangeOverLsp]    
    set obsoleteParamsArray(rsvpServer) [list enableBgpOverLsp]
	set obsoleteParamsArray(mplsTpServer) [list onDemandCvChannelType bfdCcChannelType apsChannelType faultManagementChannelType lossMeasurementChannelType delayManagementChannelType y1731ChannelType pwStatusChannelType]
	set obsoleteParamsArray(mplsTpLspPwRange) [list cccvInterval supportSlowStart]

	return $retCode
}

########################################################################
# Procedure: createRoutingProtocolEnums
#
# This command calls all functions to create the enumsArray
# Arguments(s):
# 
# Returned Result:
########################################################################
proc scriptGen::createRoutingProtocolEnums { } \
{
	set retCode 0
	
    # Do not remove this code specimen.
    # Needed for debugging errors in creating enum values.
	#if { [catch { createMplsTpEnums } enumError] } {
	#    sgPuts "Something is wrong $enumError"
	#}
	createElmiEnums
	createMplsOamEnums
	createMplsTpEnums
	createOamEnums
	createLacpEnums
	createCfmEnums
	createMulticastEnums    
	createBgp4Enums
    createRsvpEnums
    createIsisEnums
    createOspfEnums
    # There is a similar proc in ixos TCL. Hence renaming this proc to avoid conflict.
    createProtocolRipEnums
	createLdpEnums
	createProtocolServerEnums
    createStpEnums    
    createIxNetInterfaceEntryEnums    
	
}


########################################################################
# Procedure: createBgp4Enums
#
# This command creates bgp4 enums
# Arguments(s):
# Returned Result:
#
########################################################################

proc scriptGen::createBgp4Enums { } \
{
    variable enumsArray
    variable oddParamsList

    set retCode 0
    set enumValList {}
    set enumList    {}

    set enumList [list bgpOriginIGP bgpOriginEGP bgpOriginIncomplete]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4RouteItem,originProtocol)  $enumValList

    set enumList [list bgpRouteAsPathNoInclude bgpRouteAsPathIncludeAsSeq bgpRouteAsPathIncludeAsSet\
                   bgpRouteAsPathIncludeAsSeqConf bgpRouteAsPathIncludeAsSetConf \
                   bgpRouteAsPathPrependAs]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4RouteItem,asPathSetMode)  $enumValList

    set enumList [list bgpSegmentUnknown bgpSegmentAsSet bgpSegmentAsSequence bgpSegmentAsConfedSet\
                   bgpSegmentAsConfedSequence]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4AsPathItem,asSegmentType)  $enumValList                
   
    set enumList [list bgpRouteNextHopSetManually bgpRouteNextHopSetSameAsLocalIp]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4RouteItem,nextHopSetMode)  $enumValList

    set enumList [list bgp4NeighborInternal bgp4NeighborExternal]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4Neighbor,type)  $enumValList

    set enumList [list bgp4AsNumModeFixed bgp4AsNumModeIncrement]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4Neighbor,asNumMode)  $enumValList

    set enumList [list bgp4VpnFixedLabel bgp4VpnIncrementLabel]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4VpnRouteRange,labelMode)  $enumValList
	set enumsArray(bgp4MplsRouteRange,labelMode)  $enumValList

	set enumList [list bgpRouteNextHopFixed bgpRouteNextHopIncrement bgpRouteNextHopIncrementPerPrefix]   
    setEnumValList $enumList enumValList
    set enumsArray(bgp4MplsRouteRange,nextHopMode)  $enumValList 
    set enumsArray(bgp4VpnRouteRange,nextHopMode)  $enumValList
    set enumsArray(bgp4UmhSelectionRouteRange,nextHopMode)  $enumValList

	set enumList [list kTunnelTypePimGreRosenDraft kTunnelTypeRSVPP2MP kTunnelTypeMLDPP2MP]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4VpnL3Site,tunnelType)  $enumValList

    set enumList [list bgp4DistinguisherTypeAS bgp4DistinguisherTypeIP]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4VpnRouteRange,distinguisherType)  $enumValList
	set enumsArray(bgp4MplsRouteRange,distinguisherType)  $enumValList
	set enumsArray(bgp4VpnL3Site,distinguisherType)  $enumValList
	set enumsArray(bgp4VpnL2Site,distinguisherType)  $enumValList
	set enumsArray(bgp4UmhSelectionRouteRange,distinguisherType)  $enumValList

    set enumList [list bgp4TargetTypeAS bgp4TargetTypeIP bgp4TargetTypeAs2]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4VpnTarget,type)  $enumValList

    set enumList [list vpnDistinguisherIncrementGlobalPart vpnDistinguisherIncrementLocalPart]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4VpnRouteRange,distinguisherMode)  $enumValList
	set enumsArray(bgp4MplsRouteRange,distinguisherMode)  $enumValList
	set enumsArray(bgp4UmhSelectionRouteRange,distinguisherMode)  $enumValList

    set enumList [list bgpOriginIGP bgpOriginEGP bgpOriginIncomplete]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4VpnRouteRange,originProtocol)  $enumValList 
    set enumsArray(bgp4MplsRouteRange,originProtocol)  $enumValList
    set enumsArray(bgp4UmhSelectionRouteRange,originProtocol)  $enumValList

    set enumList [list addressTypeIpV4 addressTypeIpV6]   
    setEnumValList $enumList enumValList
    set enumsArray(bgp4VpnRouteRange,ipType)  $enumValList
    set enumsArray(bgp4Neighbor,ipType)  $enumValList 
    set enumsArray(bgp4RouteItem,ipType)  $enumValList 
	set enumsArray(bgp4MplsRouteRange,ipType)  $enumValList 
	set enumsArray(bgp4RouteItem,nextHopIpType)  $enumValList
	set enumsArray(bgp4UmhSelectionRouteRange,nextHopIpType)  $enumValList

	set enumList [list bgpRouteNextHopFixed bgpRouteNextHopIncrement bgpRouteNextHopIncrementPerPrefix]   
    setEnumValList $enumList enumValList
    set enumsArray(bgp4RouteItem,nextHopMode)  $enumValList 

    set enumList [list bgpCommunityNoExport bgpCommunityNoAdvertise bgpCommunityExportSubconfed]   
    setEnumValList $enumList enumValList
    
    set enumsArray(bgp4VpnRouteRange,communityList)  $enumValList 
    set enumsArray(bgp4RouteItem,communityList)  $enumValList 
	set enumsArray(bgp4MplsRouteRange,communityList)  $enumValList 
	set enumsArray(bgp4UmhSelectionRouteRange,communityList)  $enumValList 


    set enumList [list sourceTreeJoin sharedTreeJoin]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4McastReceiverSite,cMcastRouteType)  $enumValList

    set enumList [list recvAddressFamilyIpv4 recvAddressFamilyIpv6]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4McastReceiverSite,addressFamily)  $enumValList

    set enumList [list recvFullyMeshed recvOneToOne]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4McastReceiverSite,sourceGroupMapping)  $enumValList

    set enumList [list recvAsDistinguisherType recvIpDistinguisherType recvAs4BytesDistinguisherType]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4McastReceiverSite,distinguisherType)  $enumValList

	set enumList [list kTunnelTypeMulticastRSVPP2MP kTunnelTypeMulticastMLDPP2MP]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4McastSenderSite,tunnelType)  $enumValList

    set enumList [list sndrAddressFamilyIpv4 sndrAddressFamilyIpv6]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4McastSenderSite,addressFamilyType)  $enumValList

    set enumList [list sndrFullyMeshed sndrOneToOne]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4McastSenderSite,sourceGroupMapping)  $enumValList

    set enumList [list sndrDistinguisherTypeAs sndrDistinguisherTypeIp sndrDistinguisherTypeAs4Byte]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4McastSenderSite,distinguisherType)  $enumValList

    set enumList [list bgpAdVplsRtTypeAsNumber bgpAdVplsRtTypeIpAddress]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4VpnBgpAdVplsRange,routeTargetType)  $enumValList
    
    set enumList [list bgpAdVplsVplsIdTypeAsNumber bgpAdVplsVplsIdTypeIpAddress]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4VpnBgpAdVplsRange,vplsIdType)  $enumValList
    
    set enumList [list bgpAdVplsRdTypeAsNumber bgpAdVplsRdTypeIpAddress]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4VpnBgpAdVplsRange,routeDistinguisherType)  $enumValList
    
    set enumList [list bgpAdVplsVsiIdPeAddress bgpAdVplsVsiIdAssignedNumber]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4VpnBgpAdVplsRange,vsiId)  $enumValList

	set enumList [list bgp4UmhSelectionFixedLabel bgp4UmhSelectionIncrementLabel]
    setEnumValList $enumList enumValList
    set enumsArray(bgp4UmhSelectionRouteRange,labelMode)  $enumValList
											  
    lappend oddParamsList [list bgp4VpnRouteRange communityList \
                                bgp4RouteItem communityList \
                                bgp4MplsRouteRange communityList \
								bgp4UmhSelectionRouteRange communityList]
    return $retCode
}   

########################################################################
# Procedure: createIxNetInterfaceEntryEnums
#
# This command creates Interface Entry enums for IxNetInterfaceEntry
# Arguments(s):
# Returned Result:
#
########################################################################
proc scriptGen::createIxNetInterfaceEntryEnums { } \
{

    variable enumsArray

    set retCode 0
    set enumValList {}
    set enumList    {}

    set enumList    [list atmEncapsulationNone \
						  atmEncapsulationVccMuxIPV4Routed \
						  atmEncapsulationVccMuxBridgedEthernetFCS \
						  atmEncapsulationVccMuxBridgedEthernetNoFCS \
				          atmEncapsulationVccMuxIPV6Routed \
				          atmEncapsulationVccMuxMPLSRouted \
				          atmEncapsulationLLCRoutedCLIP \
						  atmEncapsulationLLCBridgedEthernetFCS \
						  atmEncapsulationLLCBridgedEthernetNoFCS \
						  atmEncapsulationLLCPPPoA \
						  atmEncapsulationVccMuxPPPoA \
						  atmEncapsulationLLCNLPIDRouted]
    setEnumValList $enumList enumValList
    set enumsArray(ixNetInterfaceEntry,atmEncapsulation)    $enumValList 
    
	set enumList [list interfaceTypeConnected \
					   interfaceTypeGre \
					   interfaceTypeRouted]
    setEnumValList $enumList enumValList
    set enumsArray(ixNetInterfaceEntry,interfaceType)    $enumValList

    return $retCode
} 
########################################################################
# Procedure: createOspfEnums
#
# This command creates ospf enums
# Arguments(s):
# Returned Result:
#
########################################################################

proc scriptGen::createOspfEnums { } \
{

    variable enumsArray
    variable oddParamsList

    set retCode 0
    set enumValList {}
    set enumList    {}

    set enumList [list ospfRouteOriginArea ospfRouteOriginExternal\
						ospfRouteOriginExternalType2 ospfRouteOriginNSSA\
						ospfRouteOriginSameArea]

    setEnumValList $enumList enumValList
    set enumsArray(ospfRouteRange,routeOrigin)    $enumValList 

    set enumList [list ospfLinkPointToPoint ospfLinkTransit ospfLinkStub\
                   ospfLinkVirtual] 
    setEnumValList $enumList enumValList
    set enumsArray(ospfRouterLsaInterface,linkType)    $enumValList 

    set enumList [list ospfBroadcast ospfPointToPoint ospfPointToMultipoint]
    setEnumValList $enumList enumValList
    set enumsArray(ospfInterface,networkType)    $enumValList 

    set enumList [list ospfInterfaceAuthenticationNull ospfInterfaceAuthenticationPassword ospfInterfaceAuthenticationMD5]
    setEnumValList $enumList enumValList
    set enumsArray(ospfInterface,authenticationMethod)    $enumValList 

    set enumList [list ospfLsaRouter ospfLsaNetwork ospfLsaSummaryIp \
                       ospfLsaSummaryAs ospfLsaExternal ospfLsaOpaqueLocal \
                       ospfLsaOpaqueArea ospfLsaOpaqueDomain]
    setEnumValList $enumList enumValList
    set enumsArray(ospfUserLsa,lsaType)    $enumValList 

    set enumList [list ospfTlvLinkPointToPoint ospfTlvLinkMultiAccess]
    setEnumValList $enumList enumValList
    set enumsArray(ospfUserLsa,tlvLinkType)    $enumValList 

    set enumList [list ospfRouterTlv ospfLinkTlv]
    setEnumValList $enumList enumValList
    set enumsArray(ospfUserLsa,tlvType)    $enumValList 

    set enumList [list ospfLinkPointToPoint ospfLinkTransit ospfLinkStub\
                   ospfLinkVirtual] 
    setEnumValList $enumList enumValList
    set enumsArray(ospfInterface,linkType)    $enumValList 

    set enumList [list ospfExteralMetricType1 ospfExteralMetricType2]
    setEnumValList $enumList enumValList
    set enumsArray(ospfUserLsa,externalMetricEBit)    $enumValList
    
    set enumList [list ospfNetworkRangeLinkBroadcast ospfNetworkRangeLinkPointToPoint]
    setEnumValList $enumList enumValList
    set enumsArray(ospfNetworkRange,linkType)    $enumValList

#ospfV3 enums

	set enumList [list ospfV3InterfaceOptionDCBit ospfV3InterfaceOptionRBit ospfV3InterfaceOptionNBit \
					ospfV3InterfaceOptionMCBit ospfV3InterfaceOptionEBit ospfV3InterfaceOptionV6Bit]
    setEnumValList $enumList enumValList
    set enumsArray(ospfV3Interface,options)    $enumValList

	lappend oddParamsList [list ospfV3Interface options]

	set enumList [list ospfV3RouteOriginAnotherArea ospfV3RouteOriginExternalType1 \
					ospfV3RouteOriginExternalType2 ospfV3RouteOriginSameArea]
    setEnumValList $enumList enumValList
    set enumsArray(ospfV3RouteRange,routeOrigin)    $enumValList

	set enumList [list ospfV3LsaOptionV6Bit ospfV3LsaOptionEBit ospfV3LsaOptionMCBit \
					ospfV3LsaOptionNBit ospfV3LsaOptionRBit ospfV3LsaOptionDCBit]
    setEnumValList $enumList enumValList
    set enumsArray(ospfV3LsaInterAreaRouter,options)    $enumValList
	set enumsArray(ospfV3LsaLink,options)    $enumValList
	set enumsArray(ospfV3LsaNetwork,options)    $enumValList
	set enumsArray(ospfV3LsaRouter,options)    $enumValList

	lappend oddParamsList [list ospfV3LsaInterAreaRouter options]
	lappend oddParamsList [list ospfV3LsaLink options]
	lappend oddParamsList [list ospfV3LsaNetwork options]
	lappend oddParamsList [list ospfV3LsaRouter options]

	set enumList [list ospfV3PrefixOptionPBit ospfV3PrefixOptionMCBit ospfV3PrefixOptionLABit \
					ospfV3PrefixOptionNUBit]
    setEnumValList $enumList enumValList
    set enumsArray(ospfV3IpV6Prefix,options)                  $enumValList
	set enumsArray(ospfV3LsaInterAreaPrefix,prefixOptions)    $enumValList
	set enumsArray(ospfV3LsaAsExternal,prefixOptions)		  $enumValList

	lappend oddParamsList [list ospfV3IpV6Prefix options]
	lappend oddParamsList [list ospfV3LsaInterAreaPrefix prefixOptions]
	lappend oddParamsList [list ospfV3LsaAsExternal prefixOptions]


	set enumList [list ospfV3LsaRouterInterfacePointToPoint ospfV3LsaRouterInterfaceTransit\
					ospfV3LsaRouterInterfaceVirtual]
    setEnumValList $enumList enumValList
    set enumsArray(ospfV3LsaRouterInterface,type)    $enumValList

	set enumList [list ospfV3InterfacePointToPoint ospfV3InterfaceBroadcast]
    setEnumValList $enumList enumValList
    set enumsArray(ospfV3Interface,type)    $enumValList

    set enumList [list addressTypeIpV4 addressTypeIpV6]
    setEnumValList $enumList enumValList
    set enumsArray(ospfV3RouteRange,ipType)    $enumValList

    set enumList [list unicastAddress multicastAddress]
    setEnumValList $enumList enumValList
    set enumsArray(ospfV3RouteRange,addressFamily)    $enumValList

	set enumList [list ospfV3NetworkRangeLinkBroadcast ospfV3NetworkRangeLinkPointToPoint]
    setEnumValList $enumList enumValList
    set enumsArray(ospfV3NetworkRange,linkType)    $enumValList

    set enumList [list softwareRestart softwareReloadOrUpgrade switchToRedundantControlProcessor unknown]
    setEnumValList $enumList enumValList
    set enumsArray(ospfV3Router,gracefulRestartReason)    $enumValList

    # SDM-AUTOGEN-TCL-DEFN-ENUM-SCRIPTGEN: OBJ=/vport/protocols/ospfV3

    return $retCode
}   


########################################################################
# Procedure: createIsisEnums
#
# This command creates Isis enums
# Arguments(s):
# Returned Result:
#
########################################################################

proc scriptGen::createIsisEnums { } \
{

    variable enumsArray
    variable oddParamsList

    set retCode 0
    set enumValList {}
    set enumList    {}

	set enumList [list isisDraftVersion3 isisDraftVersion4]   
    setEnumValList $enumList enumValList
    set enumsArray(isisRouter,hitlessRestartVersion)    $enumValList

	set enumList [list isisNormalRouter isisRestartingRouter isisStartingRouter isisHelperRouter]   
    setEnumValList $enumList enumValList
    set enumsArray(isisRouter,hitlessRestartMode)    $enumValList

    set enumList [list isisAuthTypeNone isisAuthTypePassword]
    setEnumValList $enumList enumValList
    set enumsArray(isisRouter,domainAuthType)        $enumValList
    set enumsArray(isisRouter,areaAuthType)          $enumValList
    set enumsArray(isisInterface,circuitAuthType)    $enumValList

    set enumList [list isisBroadcast isisPointToPoint]
    setEnumValList $enumList enumValList
    set enumsArray(isisInterface,networkType)    $enumValList 

    set enumList [list isisLevel1 isisLevel2 isisLevel1Level2]   
    setEnumValList $enumList enumValList
    set enumsArray(isisInterface,level)    $enumValList 

    set enumList [list addressTypeIpV4 addressTypeIpV6]   
    setEnumValList $enumList enumValList
    set enumsArray(isisRouteRange,ipType)    $enumValList
	set enumsArray(isisGridInternodeRoute,ipType)    $enumValList
	set enumsArray(isisGridRoute,ipType)    $enumValList

	set enumList [list isisRouteInternal isisRouteExternal]   
    setEnumValList $enumList enumValList
    set enumsArray(isisRouteRange,routeOrigin)    $enumValList

	set enumList [list isisGridLinkPointToPoint isisGridLinkBroadcast]   
    setEnumValList $enumList enumValList
    set enumsArray(isisGrid,linkType)    $enumValList

    lappend oddParamsList [list isisRouter domainRxPasswordList]
    lappend oddParamsList [list isisRouter areaRxPasswordList]
    lappend oddParamsList [list isisInterface circuitRxPasswordList]

	set enumList [list isisL3Routing dceIsis spbIsis trillIsis]   
    setEnumValList $enumList enumValList
    set enumsArray(isisServer,emulationType)    $enumValList

	set enumList [list fullyMeshedMapping oneToOneMapping manualMapping]   
    setEnumValList $enumList enumValList
    set enumsArray(isisDceMulticastMacRange,sourceGroupMapping)    $enumValList
    set enumsArray(isisDceMulticastIpv4GroupRange,sourceGroupMapping)    $enumValList
    set enumsArray(isisDceMulticastIpv6GroupRange,sourceGroupMapping)    $enumValList
    set enumsArray(isisDceNodeMacGroups,sourceGroupMapping)    $enumValList
    set enumsArray(isisDceNodeIpv4Groups,sourceGroupMapping)    $enumValList
    set enumsArray(isisDceNodeIpv6Groups,sourceGroupMapping)    $enumValList
    
    set enumList [list isisType1 isisType2 isisType3 isisType4 isisType5 isisType6 isisType7 isisType8 isisType9 isisType10 isisType11 isisType12 isisType13 isisType14 isisType15 isisType16]
    setEnumValList $enumList enumValList
    set enumsArray(isisSpbBaseVidRange,ectAlgorithmType)    $enumValList 
    
    set enumList [list isisUnicast isisMulticast]
    setEnumValList $enumList enumValList
    set enumsArray(isisSpbISidRange,transmissionType)    $enumValList 
    
    set enumList [list isisVLANTypeSingleVLAN isisVLANTypeStackedVLANQinQ]
    setEnumValList $enumList enumValList
    set enumsArray(isisSpbISidRange,vlanType)    $enumValList 
    
    set enumList [list isisECTAlgorithmC201 isisECTAlgorithmC202 isisECTAlgorithmC203 isisECTAlgorithmC204 isisECTAlgorithmC205 isisECTAlgorithmC206 isisECTAlgorithmC207 isisECTAlgorithmC201 isisECTAlgorithmC209 isisECTAlgorithmC210 isisECTAlgorithmC211]
    setEnumValList $enumList enumValList
    set enumsArray(isisSpbmNodeBaseVidRange,ectAlgorithm)    $enumValList 
    
    set enumList [list isisTransmissionTypeUnicsat isisTransmissionTypeMulticast]
    setEnumValList $enumList enumValList
    set enumsArray(isisSpbmNodeISidRange,transmissionType)    $enumValList 
    
    set enumList [list isisNodeVLANTypeSingleVLAN isisNodeVLANTypeStackedVLANQinQ]
    setEnumValList $enumList enumValList
    set enumsArray(isisSpbmNodeISidRange,vlanType)    $enumValList 

    return $retCode
} 

########################################################################
# Procedure: createRsvpEnums
#
# Description: This command creates Rsvp enums
#
# Arguments(s):
#
# Result:   Always returns 0
#
########################################################################
proc scriptGen::createRsvpEnums { } \
{
    variable enumsArray

    set retCode 0
    set enumValList {}
    set enumList    {}

    set prependEroModeEnumList [list rsvpNone rsvpPrependLoose rsvpPrependStrict]
    setEnumValList $prependEroModeEnumList enumValList
    set enumsArray(rsvpDestinationRange,prependEroMode)    $enumValList 

    set behaviorEnumList [list rsvpIngress rsvpEgress]   
    setEnumValList $behaviorEnumList enumValList
    set enumsArray(rsvpDestinationRange,behavior)    $enumValList 

    set typeEnumList [list rsvpTrafficEndPoint rsvpTunnelEndPoint]   
    setEnumValList $typeEnumList enumValList
    set enumsArray(rsvpDestinationRange,type)    $enumValList

    set reservationStyleEnumList [list rsvpFF rsvpSE]   
    setEnumValList $reservationStyleEnumList enumValList
    set enumsArray(rsvpDestinationRange,reservationStyle)    $enumValList

    set eroTypeEnumList [list rsvpEroIpV4 rsvpAs]   
    setEnumValList $eroTypeEnumList enumValList
    set enumsArray(rsvpEroItem,type)    $enumValList

    set rroTypeEnumList [list rsvpRroIpV4 rsvpLabel]   
    setEnumValList $rroTypeEnumList enumValList
    set enumsArray(rsvpRroItem,type)    $enumValList

    set rroTypeEnumList [list rsvpEgressAlwaysUseConfiguredStyle \
                              rsvpEgressUseSEIfInAttribute]   
    setEnumValList $rroTypeEnumList enumValList
    set enumsArray(rsvpDestinationRange,egressBehavior)    $enumValList

    set rroTypeEnumList [list rsvpLabelValueExplicitNull rsvpLabelValueRouterAlert \
                              rsvpLabelValueIPv6ExplicitNull rsvpLabelValueImplicitNull]   
    setEnumValList $rroTypeEnumList enumValList
    set enumsArray(rsvpDestinationRange,labelValue)    $enumValList
    
    set emulationTypeEnumList [list rsvpTrafficEndpoint rsvpTunnelEndpoint \
                              rsvpP2MPTunnelEndPoint]   
    setEnumValList $emulationTypeEnumList enumValList
    set enumsArray(rsvpDestinationRange,emulationType)    $enumValList

    return $retCode
}


########################################################################
# Procedure: createProtocolRipEnums
#
# Description: This command creates Rip enums
#
# Arguments(s):
#
# Result:   Always returns 0
#
########################################################################
proc scriptGen::createProtocolRipEnums { } \
{

    variable enumsArray

    set retCode 0
    set enumValList {}
    set enumList    {}

    set sendTypeEnumList [list ripMulticast ripBroadcastV1 ripBroadcastV2]
    setEnumValList $sendTypeEnumList enumValList
    set enumsArray(ripInterfaceRouter,sendType)    $enumValList 

    set responseModeEnumList [list ripDefault ripSplitHorizon ripPoisonReverse ripSplitHorizonSpaceSaver ripSilent]   
    setEnumValList $responseModeEnumList enumValList
    set enumsArray(ripInterfaceRouter,responseMode)    $enumValList 

    set receiveTypeEnumList [list ripInvalidVersion ripReceiveVersion1 ripReceiveVersion2 ripReceiveVersion1And2]   
    setEnumValList $receiveTypeEnumList enumValList
    set enumsArray(ripInterfaceRouter,receiveType)    $enumValList

    return $retCode
}


########################################################################
# Procedure: createLdpEnums
#
# Description: This command creates LDP enums
#
# Arguments(s):
#
# Result:   Always returns 0
#
########################################################################
proc scriptGen::createLdpEnums { } \
{

    variable enumsArray

    set retCode 0
    set enumValList {}
    set enumList    {}

    set enumList [list ldpInterfaceDownstreamUnsolicited ldpInterfaceDownstreamOnDemand]

    setEnumValList $enumList enumValList
    set enumsArray(ldpInterface,advertisingMode)  $enumValList

#    set enumList [list ldpInterfaceRequestModeUnknown ldpInterfaceIndependent]

    set enumList [list ldpInterfaceIndependent]
    setEnumValList $enumList enumValList
    set enumsArray(ldpInterface,requestingMode)  $enumValList

    set enumList [list ldpAdvertiseFecRangeNone ldpAdvertiseFecRangeIncrement]
    setEnumValList $enumList enumValList
    set enumsArray(ldpAdvertiseFecRange,labelIncrementMode)  $enumValList

    
    set enumList [list ldpInterfaceBasic ldpInterfaceExtended ldpInterfaceExtendedMartini]
    setEnumValList $enumList enumValList
    set enumsArray(ldpInterface,discoveryMode)  $enumValList

    set enumList [list l2VpnInterfaceFrameRelay l2VpnInterfaceATMAAL5 l2VpnInterfaceATMXCell \
                   l2VpnInterfaceVLAN  l2VpnInterfaceEthernet l2VpnInterfaceHDLC l2VpnInterfacePPP \
                   l2VpnInterfaceCEM l2VpnInterfaceATMVCC l2VpnInterfaceATMVPC l2VpnInterfaceEthernetVPLS]
    setEnumValList $enumList enumValList
    set enumsArray(ldpL2VpnInterface,type)  $enumValList

    set enumList [list ldpL2VpnVcFixedLabel ldpL2VpnVcIncrementLabel]
    setEnumValList $enumList enumValList
    set enumsArray(ldpL2VpnVcRange,labelMode)  $enumValList

    set enumList [list ldpMulticstP2MPLSP ldpMulticstMP2MPLSP]
    setEnumValList $enumList enumValList
    set enumsArray(ldpMulticastLeafRange,lspType)  $enumValList

	set enumList [list atmVcUnidirectional atmVcBidirectional]
    setEnumValList $enumList enumValList
    set enumsArray(ldpInterface,atmVcDirection)  $enumValList
    
    set enumList [list singleHop multiHop]
    setEnumValList $enumList enumValList
    set enumsArray(ldpInterface,bfdOperationMode)  $enumValList
    
    set enumList [list ldpL2VpnPwIdFec ldpL2VpnGeneralizedIdFecVpls]
    setEnumValList $enumList enumValList
    set enumsArray(ldpL2VpnVcRange,fecType)  $enumValList
    
    set enumList [list ldpL2VpnVcModelManualConfiguration ldpL2VpnVcModelBgpAutoDiscovery]
    setEnumValList $enumList enumValList
    set enumsArray(ldpL2VpnVcRange,provisioningModel)  $enumValList
    
    set enumList [list ldpL2VpnVcVplsTypeAsNumber ldpL2VpnVcVplsTypeIpAddress]
    setEnumValList $enumList enumValList
    set enumsArray(ldpL2VpnVcRange,vplsIdType)  $enumValList

    set enumList [list ldpL2VpnVcSrcAiiTypeNumber ldpL2VpnVcSrcAiiTypeIpAddress]
    setEnumValList $enumList enumValList
    set enumsArray(ldpL2VpnVcRange,sourceAiiType)  $enumValList

    set enumList [list ldpL2VpnVcTargetAiiTypeNumber ldpL2VpnVcTargetAiiTypeIpAddress]
    setEnumValList $enumList enumValList
    set enumsArray(ldpL2VpnVcRange,targetAiiType)  $enumValList
    
    set enumList [list ldpL2VpnVcAbsolute ldpL2VpnVcDifferential]
    setEnumValList $enumList enumValList
    set enumsArray(ldpL2VpnVcRange,timestampMode)  $enumValList
	
	set enumList [list ldpL2VpnVcE1Trunk ldpL2VpnVcT1ESFTrunk ldpL2VpnVcT1SFTrunk]
    setEnumValList $enumList enumValList
    set enumsArray(ldpL2VpnVcRange,cas)  $enumValList

	set enumList [list ldpL2VpnVcHexVal1 ldpL2VpnVcHexVal2 ldpL2VpnVcHexVal3 ldpL2VpnVcHexVal4]
    setEnumValList $enumList enumValList
    set enumsArray(ldpL2VpnVcRange,sp)  $enumValList
        
    return $retCode
}


########################################################################
# Procedure: createMulticastEnums
#
# This command creates IGMPVx, MLD, PIM-SM enums
# Arguments(s):
# Returned Result:
#
########################################################################

proc scriptGen::createMulticastEnums { } \
{
    variable enumsArray

    set retCode 0
    set enumValList {}
    set enumList    {}

	set enumList [list mldVersion1 mldVersion2]      
    setEnumValList $enumList enumValList
    set enumsArray(mldHost,version)  $enumValList

	set enumList [list multicastSourceModeInclude multicastSourceModeExclude]      
    setEnumValList $enumList enumValList
    set enumsArray(mldGroupRange,sourceMode)  $enumValList
	set enumsArray(igmpGroupRange,sourceMode)  $enumValList

	set enumList [list igmpHostVersion1 igmpHostVersion2 igmpHostVersion3]      
    setEnumValList $enumList enumValList
    set enumsArray(igmpHost,version)  $enumValList

	set enumList [list pimsmGenerationIdModeIncremental pimsmGenerationIdModeRandom \
					pimsmGenerationIdModeConstant]      
    setEnumValList $enumList enumValList
    set enumsArray(pimsmInterface,generationIdMode)  $enumValList

	set enumList [list pimsmJoinsPrunesTypeRP pimsmJoinsPrunesTypeG pimsmJoinsPrunesTypeSG \
					pimsmJoinsPrunesTypeSPTSwitchOver pimsmJoinsPrunesTypeRegisterTriggeredSG]      
    setEnumValList $enumList enumValList
    set enumsArray(pimsmJoinPrune,rangeType)  $enumValList

    set enumList [list pimsmMappingFullyMeshed pimsmMappingOneToOne]     
    setEnumValList $enumList enumValList
    set enumsArray(pimsmJoinPrune,sourceGroupMapping)  $enumValList
    set enumsArray(pimsmSource,sourceGroupMapping)  $enumValList
	set enumsArray(pimsmDataMdtRange,sourceGroupMapping)  $enumValList

    set enumList [list addressTypeIpV4 addressTypeIpV6]     
    setEnumValList $enumList enumValList
    set enumsArray(pimsmInterface,ipType)  $enumValList

    set enumList [list pimsmCRPMeshingTypeFull pimsmCRPMeshingTypeOneToOne]     
    setEnumValList $enumList enumValList
    set enumsArray(pimsmCRPRange,meshingType)  $enumValList

    set enumList [list pimsmCRPPriorityTypeSame pimsmCRPPriorityTypeIncremental pimsmCRPPriorityTypeRandom]     
    setEnumValList $enumList enumValList
    set enumsArray(pimsmCRPRange,priorityType)  $enumValList

    set enumList [list pimsmNoDataMdt pimsmDataMdtIpv4]     
    setEnumValList $enumList enumValList
    set enumsArray(pimsmServer,greFilterType)  $enumValList

    return $retCode
}

########################################################################
# Procedure: createProtocolServerEnums
#
# Description: This command creates protocolServer enums
#
# Arguments(s):
#
# Result:   Always returns 0
#
########################################################################
proc scriptGen::createProtocolServerEnums { } \
{
	lappend oddParamsList [list protocolServer enableBgp4CreateInterface enableIsisCreateInterface enableOspfCreateInterface \
                            enableRipCreateInterface enableRsvpCreateInterface enableIgmpCreateInterface]

    set enumList [list false]
    setEnumValList $enumList enumValList
    set enumsArray(protocolServer,enableBgp4CreateInterface)    $enumValList 
	set enumsArray(protocolServer,enableIsisCreateInterface)    $enumValList 
	set enumsArray(protocolServer,enableOspfCreateInterface)    $enumValList 
	set enumsArray(protocolServer,enableRipCreateInterface)     $enumValList 
	set enumsArray(protocolServer,enableRsvpCreateInterface)    $enumValList
	set enumsArray(protocolServer,enableIgmpCreateInterface)    $enumValList 
}

########################################################################
# Procedure: createStpEnums
#
# Description: This command creates STP enums
#
# Arguments(s):
#
# Result:   Always returns 0
#
########################################################################
proc scriptGen::createStpEnums { } \
{
    variable enumsArray

    set retCode 0
    set enumValList {}
    set enumList    {}

    set enumList [list stpInterfacePointToPoint stpInterfaceShared]

    setEnumValList $enumList enumValList
    set enumsArray(stpInterface,interfaceType)  $enumValList

    set enumList [list bridgeStp bridgeRstp bridgeMstp bridgePvst bridgeRpvst bridgePvstp]

    setEnumValList $enumList enumValList
    set enumsArray(stpBridge,mode)  $enumValList
    
    set enumList [list stp rstp]

    setEnumValList $enumList enumValList
    set enumsArray(stpBridge,pvstpMode)  $enumValList

	set enumList [list bridges providerBridges]
	setEnumValList $enumList enumValList
    set enumsArray(stpBridge,bridgeType)  $enumValList


}

########################################################################
# Procedure: createCfmEnums
#
# Description: This command creates CFM enums
#
# Arguments(s):
#
# Result:   Always returns 0
#
########################################################################
proc scriptGen::createCfmEnums { } \
{
    variable enumsArray

    set retCode 0
    set enumValList {}
    set enumList    {}

    set enumList [list cfm y1731 pbbTe]

    setEnumValList $enumList enumValList
    set enumsArray(cfmBridge,operationMode)  $enumValList

    set enumList [list ethernet llcSnap]

    setEnumValList $enumList enumValList
    set enumsArray(cfmBridge,encapsulation)  $enumValList

    set enumList [list oneSec oneMin]

    setEnumValList $enumList enumValList
    set enumsArray(cfmBridge,aisInterval)  $enumValList

    set enumList [list noVlanId vlanId allVlanId]

    setEnumValList $enumList enumValList
    set enumsArray(cfmBridge,userSvlan)  $enumValList
    set enumsArray(cfmBridge,userCvlan)  $enumValList
    set enumsArray(cfmBridge,userBvlan)  $enumValList

    set enumList [list unicast multicast]

    setEnumValList $enumList enumValList
    set enumsArray(cfmBridge,userSendType)  $enumValList

    set enumList [list allFormats primaryVid characterString twoOctetInteger rfc2685VpnId]

    setEnumValList $enumList enumValList
    set enumsArray(cfmBridge,userShortMaNameFormat)  $enumValList

    set enumList [list dm dvm]

    setEnumValList $enumList enumValList
    set enumsArray(cfmBridge,userDelayType)  $enumValList
    set enumsArray(cfmBridge,userPbbTeDelayType)  $enumValList

    set enumList [list cfmBroadCastLink cfmPointToPointLink ]

    setEnumValList $enumList enumValList
    set enumsArray(cfmLink,linkType)  $enumValList

    set enumList [list cfmNoNamePresent cfmDomainNameString cfmMACAddressPlus2OctetInt cfmMANNameCharString]

    setEnumValList $enumList enumValList
    set enumsArray(cfmMdLevel,mdNameFormat)  $enumValList
    set enumsArray(cfmTrunk,mdNameFormat)  $enumValList

    set enumList [list cfmMIP cfmMEP]

    setEnumValList $enumList enumValList
    set enumsArray(cfmMp,mpType)  $enumValList

    set enumList [list cfmPrimaryVid cfmCharacterString cfmTwoOctet cfmRfc2685VpnId]

    setEnumValList $enumList enumValList
    set enumsArray(cfmMp,shortMaNameFormat)  $enumValList
    set enumsArray(cfmTrunk,shortMaNameFormat)  $enumValList

    set enumList [list cfmIccBasedFormat cfmPrimaryVid cfmCharacterString cfmTwoOctet cfmRfc2685VpnId]

    setEnumValList $enumList enumValList
    set enumsArray(cfmMp,megIdFormat)  $enumValList

    set enumList [list cci3msec cci10msec cci100msec cci1sec cci10sec cci1min cci10min]

    setEnumValList $enumList enumValList
    set enumsArray(cfmMp,cciInterval)  $enumValList
    set enumsArray(cfmTrunk,cciInterval)  $enumValList
    
    set enumList [list rdiModeAuto rdiModeOn rdiModeOff]

    setEnumValList $enumList enumValList
    set enumsArray(cfmMp,rdi)  $enumValList
    set enumsArray(cfmTrunk,rdi)  $enumValList
    
    set enumList [list dmMethodTwoWay dmMethodOneWay]
    setEnumValList $enumList enumValList
    set enumsArray(cfmMp,dmMethod)  $enumValList
    set enumsArray(cfmTrunk,dmMethod)  $enumValList
    set enumsArray(cfmBridge,userDelayMethod)  $enumValList
    set enumsArray(cfmBridge,userPbbTeDelayMethod)  $enumValList
    
    set enumList [list lmMethodSingleEnded lmMethodDualEnded]
    setEnumValList $enumList enumValList
    set enumsArray(cfmMp,lmMethod)  $enumValList
    set enumsArray(cfmTrunk,lmMethod)  $enumValList
    set enumsArray(cfmBridge,userLossMethod)  $enumValList
    
    set enumList [list aisModeAuto aisModeStart aisModeStop]
    setEnumValList $enumList enumValList
    set enumsArray(cfmMp,aisMode)  $enumValList
    set enumsArray(cfmTrunk,aisMode)  $enumValList
    
    set enumList [list ais1sec ais1min]
    setEnumValList $enumList enumValList
    set enumsArray(cfmMp,aisInterval)  $enumValList
    set enumsArray(cfmTrunk,aisInterval)  $enumValList
    
    set enumList [list lckModeAuto lckModeStart lckModeStop]
    setEnumValList $enumList enumValList
    set enumsArray(cfmMp,lckMode)  $enumValList
    set enumsArray(cfmTrunk,lckMode)  $enumValList
    
    set enumList [list lck1sec lck1min]
    setEnumValList $enumList enumValList
    set enumsArray(cfmMp,lckInterval)  $enumValList
    set enumsArray(cfmTrunk,lckInterval)  $enumValList
    
    set enumList [list tstModeStart tstModeStop]
    setEnumValList $enumList enumValList
    set enumsArray(cfmMp,tstMode)  $enumValList
    set enumsArray(cfmTrunk,tstMode)  $enumValList
    
    set enumList [list tstPatternNullSignalWithoutCrc32 tstPatternNullSignalWithCrc32 tstPatternPrbs2311WithoutCrc32 tstPatternPrbs2311WithCrc32]
    setEnumValList $enumList enumValList
    set enumsArray(cfmMp,tstPatternType)  $enumValList
    set enumsArray(cfmTrunk,tstPatternType)  $enumValList
    
    set enumList [list tstTestTypeInService tstTestTypeOutOfService]
    setEnumValList $enumList enumValList
    set enumsArray(cfmMp,tstTestType)  $enumValList
    set enumsArray(cfmTrunk,tstTestType)  $enumValList
    
    set enumList [list singleVlan stackedVlan]

    setEnumValList $enumList enumValList
    set enumsArray(cfmVlan,type)  $enumValList

    set enumList [list zeroMd oneMd twoMd threeMd fourMd fiveMd sixMd sevenMd allMd]

    setEnumValList $enumList enumValList
    set enumsArray(cfmBridge,userMdLevel)  $enumValList
    set enumsArray(cfmMdLevel,mdLevelId)  $enumValList
    set enumsArray(cfmTrunk,mdLevelId)  $enumValList

    set enumList [list mepMac mepId mepMacAll mepIdAll]

    setEnumValList $enumList enumValList
    set enumsArray(cfmBridge,userSrcType)  $enumValList
    set enumsArray(cfmBridge,userDstType)  $enumValList

    set enumList [list linkTrace loopback delayMeasurement]
    setEnumValList $enumList enumValList
    set enumsArray(cfmBridge,userPeriodicOamType)  $enumValList

    set enumList [list manual oneToOne oneToAll allToOne allToAll]
    setEnumValList $enumList enumValList
    set enumsArray(cfmBridge,userUsabilityOption)  $enumValList

    set enumList [list chassisComponent interfaceAlias portComponent chassisMacAddress networkAddress interfaceName locallyAssigned]
    setEnumValList $enumList enumValList
    set enumsArray(cfmMp,chassisIdSubType)  $enumValList
    set enumsArray(cfmTrunk,chassisIdSubType)  $enumValList
}


########################################################################
# Procedure: createLacpEnums
#
# Description: This command creates LACP enums
#
# Arguments(s):
#
# Result:   Always returns 0
#
########################################################################
proc scriptGen::createLacpEnums { } \
{
    variable enumsArray

    set retCode 0
    set enumValList {}
    set enumList    {}

    set enumList [list disableFlag enableFlag defaultFlag]

    setEnumValList $enumList enumValList
    set enumsArray(lacpLink,aggregationFlagState)  $enumValList
    set enumsArray(lacpLink,distributingFlag)	$enumValList
    set enumsArray(lacpLink,collectingFlag)		$enumValList
    set enumsArray(lacpLink,syncFlag)			$enumValList

	set enumList [list active passive defaultActivity]

    setEnumValList $enumList enumValList
    set enumsArray(lacpLink,lacpActivity)  $enumValList

	set enumList [list fixedMode randomMode defaultRequestMode]

    setEnumValList $enumList enumValList
    set enumsArray(lacpLink,markerRequestMode)  $enumValList

	set enumList [list fastInterval slowInterval autoInterval defaultInterval]

    setEnumValList $enumList enumValList
    set enumsArray(lacpLink,lacpduPeriodicTimeInterval)  $enumValList

	set enumList [list shortTimeOut longTimeOut autoTimeout defaultTimeOut]

    setEnumValList $enumList enumValList
    set enumsArray(lacpLink,lacpTimeout)  $enumValList
}


########################################################################
# Procedure: createOamEnums
#
# Description: This command creates OAM enums
#
# Arguments(s):
#
# Result:   Always returns 0
#
########################################################################
proc scriptGen::createOamEnums { } \
{
    variable enumsArray

    set retCode 0
    set enumValList {}
    set enumList    {}

    set enumList [list activeMode passiveMode]
    setEnumValList $enumList enumValList
    set enumsArray(linkOamLink,operationMode)  $enumValList
    
    set enumList [list single periodic]
    setEnumValList $enumList enumValList
    set enumsArray(linkOamLink,linkEventTxMode)  $enumValList

    set enumList [list enableLoopback disableLoopback]
    setEnumValList $enumList enumValList
    set enumsArray(linkOamLink,loopbackCommand)  $enumValList
}

########################################################################
# Procedure: createMplsTpEnums
#
# Description: This command creates MPLSTP enums
#
# Arguments(s):
#
# Result:   Always returns 0
#
########################################################################
proc scriptGen::createMplsTpEnums { } \
{
    variable enumsArray
	variable boolList
	
    lappend boolList [list revertive skipZeroVlanId repeatMac supportSlowStart]
    
    set retCode 0
    set enumValList {}
    set enumList    {}

    set enumList [list noIncrement parallelIncrement innerFirst outerFirst]
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpLspPwRange,vlanIncrementMode)  $enumValList

    set enumList [list apsIetf apsY1731]
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpLspPwRange,apsType)  $enumValList

    set enumList [list lsp pw nestedLspPw]
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpLspPwRange,typeOfRange)  $enumValList
    
    set enumList [list rangeRoleNone rangeRoleWorking rangeRoleProtect]
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpLspPwRange,rangeRole)  $enumValList
    
    set enumList [list cccvBfdCc cccvY1731 cccvNone]
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpLspPwRange,cccvType)  $enumValList

    set enumList [list addressTypeIpV4 addressTypeIpV6]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpLspPwRange,ipType)    $enumValList 
    
    set enumList [list lmCounterType32Bit lmCounterType64Bit]
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpLspPwRange,lmCounterType)    $enumValList

    set enumList [list alarmTypeIetf alarmTypeY1731]
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpLspPwRange,alarmType)    $enumValList

    set enumList [list dmTypeIetf dmTypeY1731]
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpLspPwRange,dmType)    $enumValList

    set enumList [list lmTypeIetf lmTypeY1731]
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpLspPwRange,lmType)    $enumValList

    set enumList [list onePlusOneUnidirectional oneIstoOneBidirectional onePlusOneBidirectional]
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpLspPwRange,typeOfProtectionSwitching)    $enumValList
    
    set enumList [list dmTimeFormatIeee dmTimeFormatNtp]
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpLspPwRange,dmTimeFormat)    $enumValList

    set enumList [list counterType32Bit counterType64Bit]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpRouter,counterType)    $enumValList

    set enumList [list alarmTriggerTypeIetf alarmTriggerTypeY1731]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpRouter,alarmType)    $enumValList
    
    set enumList [list dmTriggerTypeIetf dmTriggerTypeY1731]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpRouter,dmType)    $enumValList

    set enumList [list cccvPauseTriggerOptionTx cccvPauseTriggerOptionRx cccvPauseTriggerOptionTxRx]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpRouter,cccvPauseTriggerOption)    $enumValList 
    
    set enumList [list cccvResumeTriggerOptionTx cccvResumeTriggerOptionRx cccvResumeTriggerOptionTxRx]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpRouter,cccvResumeTriggerOption)    $enumValList 
    
    set enumList [list apsTriggerTypeClear apsTriggerTypeForcedSwitch apsTriggerTypeManualSwitchToProtect apsTriggerTypeManualSwitchToWorking apsTriggerTypeLockout apsTriggerTypeExercise apsTriggerTypeFreeze]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpRouter,apsTriggerType)    $enumValList

    set enumList [list alarmTriggerClear alarmTriggerStart]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpRouter,alarmTrigger)    $enumValList
    
    set enumList [list dmModeNoResponseExpected dmModeResponseExpected]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpRouter,dmMode)    $enumValList
    
    set enumList [list dmTriggerTimeFormatIeee dmTriggerTimeFormatNtp]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpRouter,dmTimeFormat)    $enumValList
    
    set enumList [list lmTriggerTypeIetf lmTriggerTypeY1731]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpRouter,lmType)    $enumValList
    
	set enumList [list lmModeResponseExpected lmModeNoResponseExpected]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpRouter,lmMode)    $enumValList
    
    set enumList [list pwStatusCodePwNotForwarding pwStatusCodeLocalAcRxFault pwStatusCodeLocalAcTxFault pwStatusCodeLocalPsnFacingPwRxFault pwStatusCodeLocalPsnFacingPwTxFault]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpRouter,pwStatusCodeString)    $enumValList
    
    set enumList [list lspPingEncasulationTypeGach lspPingEncasulationTypeUDPIPGach]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpRouter,lspPingEncapsulationType)    $enumValList
    
    set enumList [list lspTraceRouteEncasulationTypeGach lspTraceRouteEncasulationTypeUDPIPGach]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpRouter,lspTraceRouteEncapsulationType)    $enumValList

	set enumList [list srcVplsIdTypeAsNumber srcVplsIdTypeIpAddress srcVplsIdTypeasNumber4Bytes]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpLspPwRange,srcVplsIdType)    $enumValList

	set enumList [list destVplsIdTypeAsNumber destVplsIdTypeIpAddress destVplsIdTypeasNumber4Bytes]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpLspPwRange,destVplsIdType)    $enumValList

	set enumList [list minRxInterval_10 minRxInterval_100 minRxInterval_1000 minRxInterval_10000minRxInterval_3_33 minRxInterval_60000 minRxInterval_600000]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpRouter,minRxInterval)    $enumValList

	set enumList [list minTxInterval_10 minTxInterval_100 minTxInterval_1000 minTxInterval_10000minTxInterval_3_33 minTxInterval_60000 minTxInterval_600000]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpRouter,minTxInterval)    $enumValList

	set enumList [list unexpectedMepId unexpectedYourDiscriminator]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpRouter,misconnectivityDefectOption)    $enumValList

	set enumList [list onDemandCvPadTlv_drop onDemandCvPadTlv_copy]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpRouter,onDemandCvPadTlvFirstOctet)    $enumValList

	#set enumList [list kieee kntp knull ksequenceNumber]   
    #setEnumValList $enumList enumValList
    #set enumsArray(mplsTpRouter,lmTimeFormat)    $enumValList
	
	set enumList [list onDemandCvDownstreamAddressType_ipv4Numbered onDemandCvDownstreamAddressType_ipv4Unnumbered onDemandCvDownstreamAddressType_nonIp]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsTpRouter,onDemandCvDownstreamAddressType)    $enumValList
}


########################################################################
# Procedure: createMplsOamEnums
#
# Description: This command creates MPLSOAM enums
#
# Arguments(s):
#
# Result:   Always returns 0
#
########################################################################
proc scriptGen::createMplsOamEnums { } \
{
    variable enumsArray
	variable boolList
	
    lappend boolList [list revertive skipZeroVlanId repeatMac supportSlowStart]
    
    set retCode 0
    set enumValList {}
    set enumList    {}

    set enumList [list doNotReply replyViaIpv4Ipv6UdpPacket replyViaIpv4Ipv6UdpPacketWithRouterAlert replyViaApplicationLevelControlChannel]
    setEnumValList $enumList enumValList
    set enumsArray(mplsOamInterface,replyMode)  $enumValList
    
    set enumList [list dropPadTlvFromReply copyPadTlvToReply]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsOamInterface,padTlvFirstOctet)    $enumValList
    
    set enumList [list controlChannelRouterAlert controlChannelPwAch]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsOamInterface,controlChannel)    $enumValList
    
    set enumList [list bfdCvTypeIpUdp bfdCvTypePwAch]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsOamInterface,bfdCvType)    $enumValList
    
    set enumList [list ipv4NumberedDownStreamAddressType ipv4UnNumberedDownStreamAddressType ipv6NumberedDownStreamAddressType ipv6UnNumberedDownStreamAddressType]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsOamInterface,downStreamAddressType)    $enumValList

    set enumList [list triggerDropPadTlvFromReply triggerCopyPadTlvToReply]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsOamServer,padTlvFirstOctet)    $enumValList
    
    set enumList [list pause resume]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsOamServer,pauseResumeReplyTriggerOption)    $enumValList
    
    set enumList [list resetToNormalReply forceReplyCode]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsOamServer,triggerType)    $enumValList
    
    set enumList [list noReturnCode malformedEchoRequestReceived oneOrMoreOfTheTlvsWasNotUnderstood replyingRouterIsAnEgressForTheFecAtStackDepthRsc replyingRouterHasNoMappingForTheFecAtStackDepthRsc downstreamMappingMismatch upstreamInterfaceIndexUnknown lspPingReserved labelSwitchedAtStackDepthRsc labelSwitchedButNoMplsForwardingAtStackDepthRsc mappingForThisFecIsNotTheGivenLabelAtStackDepthRsc noLabelEntryAtStackDepthRsc protocolNotAssociatedWithInterfaceatFecStackDepthRsc prematureTerminationOfPingDueToLabelStackShrinkingToSingleLabel]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsOamServer,returnCode)    $enumValList
    
    set enumList [list bfdPduOptionsPause bfdPduOptionsResume]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsOamServer,pauseResumeBfdPduTriggerOption)    $enumValList
    
    set enumList [list tx rx txRx]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsOamServer,triggerOptions)    $enumValList
    
    set enumList [list triggerDoNotReply triggerReplyViaIpv4Ipv6UdpPacket triggerReplyViaIpv4Ipv6UdpPacketWithRouterAlert triggerReplyViaApplicationLevelControlChannel]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsOamServer,replyMode)    $enumValList
    
    set enumList [list ipv4Numbered_downstreamAddressType ipv4UnNumbered_downstreamAddressType]   
    setEnumValList $enumList enumValList
    set enumsArray(mplsOamServer,downstreamAddressType)    $enumValList
}

########################################################################
# Procedure: createElmiEnums
#
# Description: This command creates ELMI enums
#
# Arguments(s):
#
# Result:   Always returns 0
#
########################################################################
proc scriptGen::createElmiEnums { } \
{
    variable enumsArray

    set retCode 0
    set enumValList {}
    set enumList    {}

    set enumList [list uniC uniN]

    setEnumValList $enumList enumValList
    set enumsArray(elmiUni,mode)  $enumValList

    set enumList [list elmiAllToOne elmiNoBundling elmiBundling]

    setEnumValList $enumList enumValList
    set enumsArray(elmiUniStatus,ceVlanIdEvcMapType)  $enumValList

    set enumList [list p2p mp2mp]

    setEnumValList $enumList enumValList
    set enumsArray(elmiEvc,evcType)  $enumValList

    set enumList [list elmiNotActive elmiNewNNotActive elmiNewNActive elmiActive elmiPartiallyActive elmiNewNPartiallyActive]

    setEnumValList $enumList enumValList
    set enumsArray(elmiEvc,evcStatus)  $enumValList 
}
