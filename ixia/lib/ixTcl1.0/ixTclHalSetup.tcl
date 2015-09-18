#############################################################################################
#   Version 6.60
#   
#   File: ixTclHalSetup.tcl
#
#  Package initialization file
#
#  This file is executed when you use "package require IxTclHal" to
#  load the IxTclHal library package. It sets up the TclHal related
#  objects and commands. This file will be called by ixtclhal.tcl file
#  on the server side or whereever the TclHal.dll file is installed.
#
#
# Copyright ©  IXIA.
# All Rights Reserved.
#
#############################################################################################

if [isWindows] {
    load ixTclHal.dll

	# This is done for the applications that don't know the location of the mpexpr10.dll, itm
	set mpexprPath "$env(IXTCLHAL_LIBRARY)/../../bin"
	if { [catch {load Mpexpr10.dll}] } {
		catch {load $mpexprPath/Mpexpr10.dll}
	}


    ############################ OBJECT INSTANTIATION ##########################

    foreach procName $ixTclHal::noArgList {
        set tclCmd [format "TCL%s%s" [string toupper [string index $procName 0]] [string range $procName 1 end]]
        ixTclHal::createCommand $tclCmd $procName
    }

    ixTclHal::createCommand TCLStatistics    stat
    ixTclHal::createCommand TCLUtils         ixUtils
    ixTclHal::createCommand TCLVsrStatistics vsrStat

    foreach procName $ixTclHal::pointerList {
        set tclCmd [format "TCL%s%s" [string toupper [string index $procName 0]] [string range $procName 1 end]]
        ixTclHal::createCommandPtr $tclCmd $procName
    }

    foreach procName $ixTclHal::protocolList {
        set tclCmd [format "TCL%s%s" [string toupper [string index $procName 0]] [string range $procName 1 end]]
        ixTclHal::createCommand $tclCmd $procName \$::portPtr
    }
	ixTclHal::createCommandPtr TCLProtocolOffset	  protocolOffset   \$::portPtr
    ixTclHal::createCommandPtr TCLStream              stream           \$::portPtr \$::protocolPtr \$::protocolOffsetPtr
    ixTclHal::createCommandPtr TCLIgmpAddressTable    igmpAddressTable \$::igmpAddressTableItemPtr
    ixTclHal::createCommandPtr TCLRip                 rip              \$::portPtr
    ixTclHal::createCommandPtr TCLMpls                mpls             \$::portPtr 
    ixTclHal::createCommand    TCLAtmHeader           atmHeader        \$::portPtr \$::atmHeaderCounterPtr
    ixTclHal::createCommandPtr TCLSrpDiscovery        srpDiscovery     \$::portPtr \$::srpMacBindingPtr
    ixTclHal::createCommandPtr TCLSrp                 srpHeader        \$::portPtr \$::protocolPtr
    ixTclHal::createCommand    TCLIgmp			      igmp			   \$::portPtr	\$::igmpGroupRecordPtr

    ixTclHal::createCommandPtr TCLUdf                 udf              \$::streamPtr
    ixTclHal::createCommand    TCLTableUdf            tableUdf         \$::portPtr	\$::tableUdfColumnPtr
    ixTclHal::createCommand    TCLSequenceNumberUdf   sequenceNumberUdf \$::portPtr
    ixTclHal::createCommand    TCLPacketGroup         packetGroup       \$::udfPtr \$::packetGroupThresholdListPtr
    ixTclHal::createCommand    TCLPacketLengthInsertion      packetLengthInsertion   \$::streamPtr

    ixTclHal::createCommand    TCLIpAddressTable      ipAddressTable   \$::ipAddressTableItemPtr
    ixTclHal::createCommand    TCLArpServer           arpServer        \$::arpAddressTableEntryPtr
    ixTclHal::createCommand    TCLRipRoute            ripRoute         \$::ripPtr
    ixTclHal::createCommand    TCLMplsLabel           mplsLabel        \$::mplsPtr

    ixTclHal::createCommandPtr TCLRprRingControl            rprRingControl  \$::portPtr \$::protocolPtr
    ixTclHal::createCommandPtr TCLRprTlvIndividualBandwidth rprTlvIndividualBandwidth   \$::rprTlvBandwidthPairPtr
    ixTclHal::createCommand    TCLRprTopology               rprTopology     \$::portPtr \$::rprTlvIndividualBandwidthPtr \
                                                                                        \$::rprTlvStationNamePtr    \
                                                                                        \$::rprTlvNeighborAddressPtr    \
                                                                                        \$::rprTlvTotalBandwidthPtr     \
                                                                                        \$::rprTlvVendorSpecificPtr     \
                                                                                        \$::rprTlvWeightPtr 
																						

																						
    ixTclHal::createCommandPtr TCLIpV6HopByHop      ipV6HopByHop       \$::ipV6OptionPAD1Ptr                    \
                                                                       \$::ipV6OptionPADNPtr                    \
                                                                       \$::ipV6OptionJumboPtr                   \
                                                                       \$::ipV6OptionRouterAlertPtr             \
                                                                       \$::ipV6OptionBindingUpdatePtr           \
                                                                       \$::ipV6OptionBindingAckPtr              \
                                                                       \$::ipV6OptionBindingRequestPtr          \
                                                                       \$::ipV6OptionMIpV6UniqueIdSubPtr        \
                                                                       \$::ipV6OptionMIpV6AlternativeCoaSubPtr  \
                                                                       \$::ipV6OptionUserDefinePtr

    ixTclHal::createCommandPtr TCLIpV6Destination   ipV6Destination    \$::ipV6OptionPAD1Ptr                    \
                                                                       \$::ipV6OptionPADNPtr                    \
                                                                       \$::ipV6OptionHomeAddressPtr             
																						                                          

    ixTclHal::createCommand    TCLIpV6               ipV6              \$::portPtr  \$::ipV6RoutingPtr          \
                                                                                    \$::ipV6FragmentPtr         \
                                                                                    \$::ipV6DestinationPtr      \
                                                                                    \$::ipV6AuthenticationPtr	\
																					\$::ipV6HopByHopPtr
    ixTclHal::createCommandPtr TCLCustomOrderedSet   customOrderedSet
    ixTclHal::createCommand    TCLLinkFaultSignaling linkFaultSignaling \$::customOrderedSetPtr
    ixTclHal::createCommandPtr TCLPacketGroupStats   packetGroupStats  \$::latencyBinPtr
    ixTclHal::createCommandPtr TCLGfp				 gfp			   \$::portPtr
                                                                                        
    ixTclHal::createCommand    TCLAtmOam			atmOam				\$::portPtr		\$::atmOamAisPtr	\
                                                                                        \$::atmOamRdiPtr	\
                                                                                        \$::atmOamFaultManagementCCPtr	\
                                                                                        \$::atmOamFaultManagementLBPtr  \
																						\$::atmOamActDeactPtr
                                                                                        
    ixTclHal::createCommandPtr TCLAtmOamTrace		atmOamTrace			\$::portPtr

    ixTclHal::createCommandPtr TCLVlan				vlan		        \$::portPtr
    ixTclHal::createCommand	   TCLStackedVlan       stackedVlan         \$::portPtr \$::vlanPtr


    ixTclHal::createCommandPtr TCLMmd   mmd     \$::mmdRegisterPtr
    ixTclHal::createCommandPtr TCLMiiae miiae   \$::mmdPtr

    ixTclHal::createCommandPtr TCLDhcpV4Properties		dhcpV4Properties		\$::dhcpV4TlvPtr
    ixTclHal::createCommandPtr TCLDhcpV4DiscoveredInfo  dhcpV4DiscoveredInfo	\$::dhcpV4TlvPtr

	# dhcpV6Tlv command is exactly the same as dhcpV4Tlv.  We use the same underlying C++ object.
	ixTclHal::createCommandPtr TCLDhcpV4Tlv				dhcpV6Tlv	
    ixTclHal::createCommandPtr TCLDhcpV6Properties		dhcpV6Properties		\$::dhcpV6TlvPtr
    ixTclHal::createCommandPtr TCLDhcpV6DiscoveredInfo  dhcpV6DiscoveredInfo	\$::dhcpV6TlvPtr

    # fipTlv command is exactly the same as dhcpV4Tlv.  We use the same underlying C++ object.
	ixTclHal::createCommandPtr TCLDhcpV4Tlv				fipTlv
	ixTclHal::createCommandPtr TCLFcoeProperties	fcoeProperties  \$::fipTlvPtr  \
	                                                                \$::fcoePlogiPtr  \
                                                                    \$::fcoeNameServerPtr \
                                                                    \$::fcNameServerQueryPtr
                                                                    
    ixTclHal::createCommandPtr TCLFcProperties	   fcProperties  		\$::fcPlogiPtr  \
																		\$::fcNameServerPtr \
																		\$::fcNameServerQueryPtr
	                                                                
	ixTclHal::createCommandPtr TCLNpivProperties	npivProperties  \$::fcoePlogiPtr  \
																	\$::fcoeNameServerPtr \
                                                                    \$::fcNameServerPtr \
                                                                    \$::fcNameServerQueryPtr
																	
	ixTclHal::createCommandPtr TCLDcbxProperties	dcbxProperties  \$::lldpPortIdPtr    \
	                                                                \$::dcbxPriorityGroupFeaturePtr  \
	                                                                \$::dcbxPfcFeaturePtr  \
	                                                                \$::dcbxFcoeFeaturePtr  \
	                                                                \$::dcbxLogicalLinkFeaturePtr  \
                                                                    \$::dcbxCustomFeaturePtr  \
                                                                    \$::dcbxIscsiFeaturePtr
                                                            	
	ixTclHal::createCommandPtr TCLInterfaceEntry     interfaceEntry     \$::interfaceIpV4Ptr	\
																		\$::interfaceIpV6Ptr	\
																		\$::dhcpV4PropertiesPtr \
																		\$::dhcpV6PropertiesPtr \
																		\$::fcoePropertiesPtr	\
																		\$::npivPropertiesPtr	\
																		\$::ptpPropertiesPtr    \
																		\$::dcbxPropertiesPtr   \
																		\$::fcPropertiesPtr 

    ixTclHal::createCommandPtr TCLDiscoveredNeighbor discoveredNeighbor \$::discoveredAddressPtr
    ixTclHal::createCommandPtr TCLDiscoveredList     discoveredList     \$::discoveredNeighborPtr \$::discoveredAddressPtr
    
    ixTclHal::createCommandPtr TCLDcbxDiscoveredInfo dcbxDiscoveredInfo  \$::dcbxPriorityGroupFeaturePtr  \
																		 \$::dcbxPfcFeaturePtr  \
																		 \$::dcbxFcoeFeaturePtr  \
																		 \$::dcbxLogicalLinkFeaturePtr  \
																		 \$::dcbxCustomFeaturePtr    \
																		 \$::dcbxControlTlvPtr  \
																		 \$::dcbxIscsiFeaturePtr

    ixTclHal::createCommand    TCLInterfaceTable     interfaceTable     \$::interfaceEntryPtr			\
																	    \$::discoveredListPtr			\
																		\$::dhcpV4DiscoveredInfoPtr		\
																		\$::dhcpV6DiscoveredInfoPtr		\
																		\$::fcoeDiscoveredInfoPtr		\
																		\$::ptpDiscoveredInfoPtr        \
																		\$::dcbxDiscoveredInfoPtr

    ixTclHal::createCommand    TCLSonetCircuitList   sonetCircuitList   \$::sonetCircuitPtr

    ixTclHal::createCommand    TCLMacSecTx			 macSecTx		    \$::macSecChannelPtr 
    ixTclHal::createCommand    TCLMacSecRx			 macSecRx		    \$::macSecChannelPtr
    ixTclHal::createCommand    TCLMacSecTag			 macSecTag			\$::portPtr

    ixTclHal::createCommandPtr TCLOamInformation     oamInformation		\$::oamLocalInformationTlvPtr	\
																		\$::oamRemoteInformationTlvPtr  \
																		\$::oamOrganizationSpecificTlvPtr                   

    ixTclHal::createCommandPtr TCLOamEventNotification oamEventNotification	\$::oamSymbolPeriodTlvPtr	\
																			\$::oamFrameTlvPtr			\
																			\$::oamFramePeriodTlvPtr	\
																			\$::oamSummaryTlvPtr		\
																			\$::oamEventOrgTlvPtr

    ixTclHal::createCommandPtr TCLOamVariableRequest oamVariableRequest		\$::oamVariableRequestTlvPtr
    ixTclHal::createCommandPtr TCLOamVariableResponse oamVariableResponse	\$::oamVariableResponseTlvPtr
																		
																			                   
    ixTclHal::createCommand    TCLOamHeader          oamHeader          \$::portPtr \$::oamInformationPtr			\
                                                                                    \$::oamEventNotificationPtr     \
                                                                                    \$::oamVariableRequestPtr		\
                                                                                    \$::oamVariableResponsePtr      \
                                                                                    \$::oamLoopbackControlPtr		\
																					\$::oamOrganizationSpecificPtr

    ixTclHal::createCommand    TCLCiscoMetaData		ciscoMetaData       \$::portPtr \$::ciscoMetaDataSourceGroupTagPtr	\
																					\$::ciscoMetaDataCustomOptionPtr

    ixTclHal::createCommand    TCLConditionalStats	conditionalStats    \$::conditionalTablePtr

    ixTclHal::createCommand    TCLPtp          ptp						\$::portPtr \$::ptpAnnouncePtr			\
                                                                                    \$::ptpDelayRequestPtr		\
                                                                                    \$::ptpSyncPtr				\
                                                                                    \$::ptpFollowUpPtr			\
                                                                                    \$::ptpDelayResponsePtr		


    ixTclHal::createCommandPtr TCLIcmpV6NeighborDiscovery	icmpV6NeighborDiscovery \$::icmpV6OptionLinkLayerSourcePtr      \
																					\$::icmpV6OptionLinkLayerDestinationPtr \
																					\$::icmpV6OptionPrefixInformationPtr    \
																					\$::icmpV6OptionRedirectedHeaderPtr		\
																					\$::icmpV6OptionMaxTransmissionUnitPtr  \
																					\$::icmpV6OptionUserDefinePtr
																					

	ixTclHal::createCommand    TCLIcmpV6               icmpV6			\$::portPtr \$::icmpV6ErrorPtr				\
																					\$::icmpV6InformationalPtr		\
                                                                                    \$::icmpV6MulticastListenerPtr	\
                                                                                    \$::icmpV6NeighborDiscoveryPtr	\
                                                                                    \$::icmpV6UserDefinePtr

    ixTclHal::createCommand    TCLCommonTransport    commonTransport    \$::portPtr                             \
                                                                        \$::ctPreamblePtr                       \
                                                                        \$::ctGetAllNextRequestPtr              \
                                                                        \$::ctGetAllNextAcceptPtr               \
                                                                        \$::ctGetPortNameRequestPtr             \
                                                                        \$::ctGetPortNameAcceptPtr              \
                                                                        \$::ctGetNodeNameRequestPtr             \
                                                                        \$::ctGetNodeNameAcceptPtr              \
                                                                        \$::ctGetFC4TypeRequestPtr              \
                                                                        \$::ctRegisterNodeNameRequestPtr

    ixTclHal::createCommandPtr TCLFcpCommandStatus     fcpCommandStatus \$::fcpSnsInfoPtr

    ixTclHal::createCommand    TCLFcp                  fcp              \$::portPtr                     \
                                                                        \$::fcpCommandStatusPtr         \
                                                                        \$::fcpUnsolicitedCommandPtr    \
                                                                        \$::fcpDataDescriptorPtr        \
                                                                        \$::fcpScsiReadPtr              \
                                                                        \$::fcpScsiWritePtr             \
                                                                        \$::fcpScsiInquiryPtr

    ixTclHal::createCommand    TCLBasicLinkServices    basicLinkServices    \$::portPtr

    ixTclHal::createCommand    TCLExtendedLinkServices  extendedLinkServices    \$::portPtr  \
                                                                                \$::elsFlogiPtr \
                                                                                \$::elsPlogiPtr \
                                                                                \$::elsFdiscPtr \
                                                                                \$::elsLsAccPtr \
                                                                                \$::elsLogoPtr  \
                                                                                \$::elsScrPtr   \
                                                                                \$::elsLsRjtPtr \
                                                                                \$::elsRscnPtr

    ixTclHal::createCommand    TCLFcSOF                 fcSOF           \$::portPtr

    ixTclHal::createCommand    TCLFcEOF                 fcEOF           \$::portPtr


	ixTclHal::createCommandPtr    TCLNetworkHeader    networkHeader        \$::iEEE48BitAddressSrcPtr        \
																		   \$::iEEEExtendedSrcPtr            \
																	       \$::locallyAssignedSrcPtr         \
																		   \$::iEEERegisteredSrcPtr          \
																		   \$::iEEERegisteredExtendedSrcPtr  \
																		   \$::eUI64MappedSrcPtr             \
                                                                           \$::iEEE48BitAddressDestPtr       \
                                                                           \$::iEEEExtendedDestPtr           \
                                                                           \$::locallyAssignedDestPtr        \
                                                                           \$::iEEERegisteredDestPtr         \
                                                                           \$::iEEERegisteredExtendedDestPtr \
                                                                           \$::eUI64MappedDestPtr  
	
	ixTclHal::createCommand    TCLFibreChannel       fibreChannel       \$::portPtr                 \
																		\$::vftHeaderPtr            \
																		\$::ifrHeaderPtr            \
																		\$::encHeaderPtr            \
																		\$::espHeaderPtr            \
																		\$::associationHeaderPtr    \
                                                                        \$::networkHeaderPtr 
                                                                        
	ixTclHal::createCommandPtr    TCLProtocolPad		 protocolPad	\$::portPtr  

    ixTclHal::createCommandPtr      TCLHse40GQsfpLane   hse40GQsfpLane
    ixTclHal::createCommand         TCLHse40GQsfp       hse40GQsfp        \$::hse40GQsfpLanePtr
    
    ixTclHal::createCommandPtr      TCLHseCfpQsfpLane   hseCfpQsfpLane
    ixTclHal::createCommand         TCLHseCfpQsfp       hseCfpQsfp        \$::hseCfpQsfpLanePtr   

    ixTclHal::createCommandPtr      TCLPcsLaneError     pcsLaneError
    ixTclHal::createCommand         TCLPcsLaneErrorGroup    pcsLaneErrorGroup \$::pcsLaneErrorPtr

    ixTclHal::createCommandPtr      TCLTxLane           txLane
    ixTclHal::createCommand         TCLTxLaneGroup      txLaneGroup     \$::txLanePtr

    ixTclHal::createCommandPtr      TCLCapturePlayback  capturePlayback \$::portPtr
 

    # Enable logging of messages from SWIG
    enableEvents true

    #################################################################################
    # Procedure: after
    #
    # NOTE:  This command effective 'steps on' the original after command
    #        so that we have more control over what happens during the sleep
    #        process (ie., so that we can make some task switches)
    #
    #        It is used *exactly* like the original after.
    #
    #        This proc is here because we don't want to overload the 'after' command
    #        in unix, only windows.
    #
    # Argument(s):
    #   duration    - time to sleep, in milliseconds
    #
    #################################################################################
    proc after {args} \
    {
	    set retCode ""

	    set argc    [llength $args]

	    set duration  [lindex $args 0]  
	    if {[stringIsInteger $duration] && $argc == 1} {
		    ixSleep $duration
		    set retCode ""
	    } else {
		    catch {eval originalAfter $args} retCode
	    }

	    set retCode [stringSubstitute $retCode originalAfter after]

	    return $retCode
    }

} else {
    catch {package req Mpexpr}

    proc enableEvents {flag} {}
	logMsg "Tcl Client is running Ixia Software version: $env(IXIA_VERSION)"
}


# note that mpexpr is only req'd for 8.3 & below.
if {[info command mpexpr] == ""} {
    # if we didn't get a real mpexpr AND we're not 8.4, that's ugly so throw an exception - otherwise just make it work
    if {[info tclversion] <= 8.3} {
        puts "Package req failed: Mpexpr package/file not found"
        return -code error -errorinfo "Mpexpr package/file not found"
    } else {    
        proc mpexpr {args}   {return [eval expr $args]}
        proc mpformat {args} {return [eval format $args]}
        proc mpincr {args} \
        {
            set Item [lindex $args 0]
            upvar $Item item
            set args [lrange $args 1 end]
            return [eval incr item $args]
        }
    }
}


useProfile false 


