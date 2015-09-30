#############################################################################################
#
# sgProtocolServer.tcl  Utilities for scriptgen
#
#   Copyright © 1997 - 2004 by IXIA.
#   All Rights Reserved.
#
#	Revision Log:
#	04-03-2004	EM	Genesis
#
#
#############################################################################################

########################################################################
# Procedure: doProtocols
#
# This command generats commands for enabled protocols.
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
#
########################################################################

proc scriptGen::doProtocols {chassis card port} \
{
	doIxNetInterfaceTable $chassis $card $port

	if {[protocolServer cget -enableBgp4Service]} {
        getBgp $chassis $card $port
    }
    
    if {[protocolServer cget -enableOspfService] } {
        getOspf $chassis $card $port
    }

    if {[protocolServer cget -enableIsisService]} {
        getIsis $chassis $card $port
    }
    if {[protocolServer cget -enableRsvpService]} {
        getRsvp $chassis $card $port
    }
    
    if {[protocolServer cget -enableRipService]} {
        getRip $chassis $card $port
    }

    if {[protocolServer cget -enableRipngService]} {
        getRipng $chassis $card $port
    }

    if {[protocolServer cget -enableLdpService]} {
        getLdp $chassis $card $port
    }

	if {[protocolServer cget -enableMldService]} {
        getMld $chassis $card $port
    }
	
	if {[protocolServer cget -enableOspfV3Service]} {
        getOspfV3 $chassis $card $port
    }
	
	if {[protocolServer cget -enablePimsmService]} {
        getPimsm $chassis $card $port
    }

    if [protocolServer cget -enableIgmpQueryResponse] {

		if {[port isValidFeature $chassis $card $port $::portFeatureProtocolIGMP]} {
			catch {getIgmpVx $chassis $card $port}
		} else {
			if {![igmpAddressTable get $chassis $card $port]} {
				getIgmpProtocol $chassis $card $port
			} else {
				logMsg "Error in getting igmpAddressTable"
			set retCode 1 
			}
		}	
	}

    if {[protocolServer cget -enableStpService]} {
        getStp $chassis $card $port
    }

	if {[protocolServer cget -enableEigrpService]} {
		getEigrp $chassis $card $port
	}

	if {[protocolServer cget -enableBfdService]} {
		getBfd $chassis $card $port
	}

	if {[protocolServer cget -enableCfmService]} {
		getCfm $chassis $card $port
	}

	if {[protocolServer cget -enableLacpService]} {
		getLacp $chassis $card $port
	}
	
	if {[protocolServer cget -enableOamService]} {
			getLinkOam $chassis $card $port
	}
	if {[protocolServer cget -enableMplsTpService]} {
			getMplsTp $chassis $card $port
	}
	if {[protocolServer cget -enableMplsOamService]} {
			getMplsOam $chassis $card $port
	}
	if {[protocolServer cget -enableElmiService]} {
			getElmi $chassis $card $port
	}

}


########################################################################
# 
#       ------------  BGP procedures  ------------
#
########################################################################

########################################################################
# Procedure: getBgp
#
# This command generats bgp server commands
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
#
########################################################################

proc scriptGen::getBgp {chassis card port} \
{
    set retCode 0
    set nameIndex 2
    if {![bgp4Server select $chassis $card $port]} {
        sgPuts {bgp4Server select $chassis $card $port}
        sgPuts "bgp4Server clearAllNeighbors"
    
        if {![bgp4Server getFirstNeighbor]} {
            doBgpNeighbor neighbor1
            while {![bgp4Server getNextNeighbor]} {
                doBgpNeighbor [format "neighbor%i" $nameIndex]
				incr nameIndex
            }
        }
    
        if {![bgp4Server get]} {
            generateCommand bgp4Server
            sgPuts "bgp4Server set"
            sgPuts ""
        }
    }
    return $retCode
}



########################################################################
# Procedure: doBgpNeighbor
#
# This command gets bgp neighbor params.
# Arguments(s):
# name : NeighborName
# Returned Result:
#
########################################################################

proc scriptGen::doBgpNeighbor {name} \
{
    set retCode 0

    if {![bgp4Neighbor getFirstRouteRange]} {
        set nameIndex 2
        doBgpRouteRange routeRange1
      while {![bgp4Neighbor getNextRouteRange]} {
          doBgpRouteRange  [format "routeRange%i" $nameIndex]
		  incr nameIndex
      }
    }

	if [ixUtils isVpnL3Installed] {
		 if {![bgp4Neighbor getFirstMplsRouteRange]} {
			set nameIndex 2
			doBgpMplsRouteRange mplsRouteRange1
			while {![bgp4Neighbor getNextMplsRouteRange]} {
				doBgpMplsRouteRange  [format "mplsRouteRange%i" $nameIndex]
				incr nameIndex
			}
		}

		if {![bgp4Neighbor getFirstL3Site]} {
			set nameIndex 2
			doBgpVpnL3Site l3Site1
		  while {![bgp4Neighbor getNextL3Site]} {
			  doBgpVpnL3Site [format "l3Site%i" $nameIndex]
			  incr nameIndex
		  }
		}
	}

    if {![bgp4Neighbor getFirstPrefixFilter]} {
       doBgp4IncludePrefixFilter  
       while {![bgp4Neighbor getNextPrefixFilter]} {
           doBgp4IncludePrefixFilter  
	   }
    }       
	
	if {![bgp4Neighbor getFirstL2Site]} {
	set nameIndex 2
       doBgpVpnL2Site l2Site1
       while {![bgp4Neighbor getNextL2Site]} {
           doBgpVpnL2Site  [format "l2Site%i" $nameIndex]
			  incr nameIndex
	   }
    }
    
    if {![bgp4Neighbor getFirstBgpAdVplsRange]} {
	set nameIndex 2
       doBgpVpnAdVplsRange adVpls1
       while {![bgp4Neighbor getNextBgpAdVplsRange]} {
           doBgpVpnAdVplsRange  [format "adVpls%i" $nameIndex]
			  incr nameIndex
	   }
    }
    
    if {![bgp4Neighbor getFirstBgpUserDefinedAfiSafi]} {
	set nameIndex 2
       doBgpUserDefinedAfiSafi userDefinedAfiSafi1
       while {![bgp4Neighbor getNextBgpUserDefinedAfiSafi]} {
           doBgpUserDefinedAfiSafi  [format "userDefinedAfiSafi1%i" $nameIndex]
			  incr nameIndex
	   }
    }
           
	generateCommand	bgp4RouteFilter
    generateCommand bgp4Neighbor
    sgPuts "bgp4Server addNeighbor $name" 
    sgPuts ""
	sgPuts "bgp4Neighbor clearAllPrefixFilter"

    return $retCode
}

########################################################################
# Procedure: doBgp4IncludePrefixFilter
#
# This command gets bgp4IncludePrefixFilter Target parameters.
# Arguments(s):
# 
# Returned Result:
########################################################################

proc scriptGen::doBgp4IncludePrefixFilter {} \
{
    set retCode 0
       
    generateCommand bgp4IncludePrefixFilter
    
    sgPuts "bgp4Neighbor    addPrefixFilter"
    sgPuts ""

    return $retCode
}


########################################################################
# Procedure: doBgpRouteRange
#
# This command gets route ranges params for BGP
# Arguments(s):
# Name : RouteRange Name
# Returned Result:
########################################################################

proc scriptGen::doBgpRouteRange {name} \
{
  
    set retCode 0

    if {[bgp4RouteItem cget -enableASPath]} {
       if {![bgp4RouteItem getFirstASPathItem] } {
           doBgp4AsPath  bgp4RouteItem
           while {![bgp4RouteItem getNextASPathItem] } {
               doBgp4AsPath  bgp4RouteItem
           }
      }       
    }                                            
    
	if {![bgp4RouteItem getFirstExtendedCommunity] } {
       doBgp4Community  bgp4RouteItem
       while {![bgp4RouteItem getNextExtendedCommunity] } {
           doBgp4Community  bgp4RouteItem
       }
	}       

    generateCommand bgp4RouteItem
    sgPuts "bgp4Neighbor addRouteRange $name"     
    sgPuts ""
    sgPuts "bgp4RouteItem clearASPathList"

    return $retCode
}


########################################################################
# Procedure: doBgp4AsPath
#
# This command gets AsPath params for BGP
# Arguments(s):
# cmd: The command  for adding.
# Returned Result:
########################################################################

proc scriptGen::doBgp4AsPath { cmd  } \
{
    set retCode 0
       
    generateCommand bgp4AsPathItem
   
    sgPuts "$cmd    addASPathItem"


    sgPuts ""

    return $retCode
}


########################################################################
# Procedure: doBgpVpnL3Site
#
# This command gets l3 site params for BGP
# Arguments(s):
# Name : RouteRange Name
# Returned Result:
########################################################################

proc scriptGen::doBgpVpnL3Site {name} \
{
  
    set retCode 0

    if {![bgp4VpnL3Site getFirstVpnRouteRange]} {
        set nameIndex 2
        doBgpVpnRouteRange vpnRouteRange1
      while {![bgp4VpnL3Site getNextVpnRouteRange]} {
          doBgpVpnRouteRange  [format "vpnRouteRange%i" $nameIndex]
		  incr nameIndex
	  }
    }

    if {![bgp4VpnL3Site getFirstVpnTarget] } {
       doBgp4VpnTarget  
       while {![bgp4VpnL3Site getNextVpnTarget] } {
           doBgp4VpnTarget  
	   }
    }       
        
	if {![bgp4VpnL3Site getFirstImportTarget] } {
       doBgp4ImportTarget  
       while {![bgp4VpnL3Site getNextImportTarget] } {
           doBgp4ImportTarget  
	   }
    }

    if {![bgp4VpnL3Site getFirstUmhSelectionRouteRange]} {
        set nameIndex 2
        doBgpUmhSelectionRouteRange umhSelectionRouteRange1
      while {![bgp4VpnL3Site getNextUmhSelectionRouteRange]} {
          doBgpUmhSelectionRouteRange  [format "umhSelectionRouteRange%i" $nameIndex]
		  incr nameIndex
	  }
    }

    if {![bgp4VpnL3Site getFirstUmhTarget] } {
       doBgp4UmhTarget  
       while {![bgp4VpnL3Site getNextUmhTarget] } {
           doBgp4UmhTarget  
	   }
    }       
        
	if {![bgp4VpnL3Site getFirstUmhImportTarget] } {
       doBgp4UmhImportTarget  
       while {![bgp4VpnL3Site getNextUmhImportTarget] } {
           doBgp4UmhImportTarget  
	   }
    }

	if {![bgp4VpnL3Site getFirstMcastReceiverSite]} {
        set nameIndex 2
        doBgpMcastReceiverSite mcastReceiverSite1
		while {![bgp4VpnL3Site getNextMcastReceiverSite]} {
          doBgpMcastReceiverSite  [format "mcastReceiverSite%i" $nameIndex]
		  incr nameIndex
	  }
    }

	if {![bgp4VpnL3Site getFirstMcastSenderSite]} {
        set nameIndex 2
        doBgpMcastSenderSite mcastSenderSite1
        while {![bgp4VpnL3Site getNextMcastSenderSite]} {
          doBgpMcastSenderSite  [format "mcastSenderSite%i" $nameIndex]
          incr nameIndex
        }
    }
    
   if {![bgp4VpnL3Site getFirstOpaqueValueElement]} {
        set nameIndex 2
        doBgpOpaqueValueElement  opaqueValueElement1
        while {![bgp4VpnL3Site getNextOpaqueValueElement]} {
            doBgpOpaqueValueElement [format "opaqueValueElement%i" $nameIndex]
            incr nameIndex
        }
    }

    generateCommand bgp4VpnL3Site
    sgPuts "bgp4Neighbor addL3Site $name"     
    sgPuts ""
    sgPuts "bgp4VpnL3Site clearAllVpnTargets"

    return $retCode
}

########################################################################
# Procedure: doBgpVpnL2Site
#
# This command gets l2 site params for BGP
# Arguments(s):
# Name : RouteRange Name
# Returned Result:
########################################################################

proc scriptGen::doBgpVpnL2Site {name} \
{
  
    set retCode 0

    if {![bgp4VpnL2Site getFirstVpnLabelBlock]} {
        set nameIndex 2
        doBgpVpnLabelBlock LabelBlock1
      while {![bgp4VpnL2Site getNextVpnLabelBlock]} {
          doBgpVpnLabelBlock [format "LabelBlock%i" $nameIndex]
		  incr nameIndex
	  }
    }

    generateCommand bgp4VpnL2Site
    sgPuts "bgp4Neighbor addL2Site $name"     
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doBgpVpnAdVplsRange
#
# This command gets Ad Vpls params for BGP
# Arguments(s):
# Name : RouteRange Name
# Returned Result:
########################################################################

proc scriptGen::doBgpVpnAdVplsRange {name} \
{  
    set retCode 0
	  
    generateCommand bgp4VpnBgpAdVplsRange
    sgPuts "bgp4Neighbor addBgpAdVplsRange $name"     
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doBgpUserDefinedAfiSafi
#
# This command gets UserDefinedAfiSafi params for BGP
# Arguments(s):
# Name : RouteRange Name
# Returned Result:
########################################################################

proc scriptGen::doBgpUserDefinedAfiSafi {name} \
{  
    set retCode 0
	  

    
    if {![bgp4UserDefinedAfiSafi getFirstBgpUserDefinedAfiSafiRoute]} {
		set nameIndex 2
		doBgpUserDefinedAfiSafiRoute userDefinedAfiSafiRoute1
		while {![bgp4UserDefinedAfiSafi getNextBgpUserDefinedAfiSafiRoute]} {
           doBgpUserDefinedAfiSafiRoute  [format "userDefinedAfiSafiRoute%i" $nameIndex]
			incr nameIndex
	   }
    }
    
    generateCommand bgp4UserDefinedAfiSafi
    sgPuts "bgp4Neighbor addBgpUserDefinedAfiSafi $name"     
    sgPuts ""

    return $retCode
}
########################################################################
# Procedure: doBgpUserDefinedAfiSafiRoute
#
# This command gets UserDefinedAfiSafiRoute params for BGP
# Arguments(s):
# Name : RouteRange Name
# Returned Result:
########################################################################

proc scriptGen::doBgpUserDefinedAfiSafiRoute {name} \
{  
    set retCode 0
	  
    generateCommand bgp4UserDefinedAfiSafiRoute
    sgPuts "bgp4UserDefinedAfiSafi addBgpUserDefinedAfiSafiRoute $name"     
    sgPuts ""

    return $retCode
}
########################################################################
# Procedure: doBgp4LabelBlocks
#
# This command gets bgp4Vpn Target parameters.
# Arguments(s):
# 
# Returned Result:
########################################################################

proc scriptGen::doBgpVpnLabelBlock {name} \
{
    set retCode 0
       
    generateCommand bgp4VpnLabelBlock
    
    sgPuts "bgp4VpnL2Site    addVpnLabelBlock $name"
    sgPuts ""

    return $retCode
}


########################################################################
# Procedure: doBgp4VpnTarget
#
# This command gets bgp4Vpn Target parameters.
# Arguments(s):
# 
# Returned Result:
########################################################################

proc scriptGen::doBgp4VpnTarget {} \
{
    set retCode 0
       
    generateCommand bgp4VpnTarget
    
    sgPuts "bgp4VpnL3Site    addVpnTarget"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doBgp4ImportTarget
#
# This command gets bgp4Vpn Import Target parameters.
# Arguments(s):
# 
# Returned Result:
########################################################################

proc scriptGen::doBgp4ImportTarget {} \
{
    set retCode 0
       
    generateCommand bgp4VpnImportTarget
    
    sgPuts "bgp4VpnL3Site    addImportTarget"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doBgpVpnRouteRange
#
# This command gets VPN route ranges params for BGP
# Arguments(s):
# Name : RouteRange Name
# Returned Result:
########################################################################

proc scriptGen::doBgpVpnRouteRange {name} \
{
  
    set retCode 0

    if {[bgp4VpnRouteRange cget -enableASPath]} {
       if {![bgp4VpnRouteRange getFirstASPathItem] } {
           doBgp4AsPath  bgp4VpnRouteRange
           while {![bgp4VpnRouteRange getNextASPathItem] } {
               doBgp4AsPath bgp4VpnRouteRange 
		   }
      }       
    }                                          

	if {![bgp4VpnRouteRange getFirstExtendedCommunity] } {
       doBgp4Community  bgp4VpnRouteRange
       while {![bgp4VpnRouteRange getNextExtendedCommunity] } {
           doBgp4Community  bgp4VpnRouteRange
       }
	}     

    generateCommand bgp4VpnRouteRange
    sgPuts "bgp4VpnL3Site addVpnRouteRange $name"     
    sgPuts ""
    sgPuts "bgp4VpnRouteRange clearASPathList"

    return $retCode
}

########################################################################
# Procedure: doBgp4UmhTarget
#
# This command gets bgp4Umh Target parameters.
# Arguments(s):
# 
# Returned Result:
########################################################################

proc scriptGen::doBgp4UmhTarget {} \
{
    set retCode 0
       
    generateCommand bgp4UmhTarget
    
    sgPuts "bgp4VpnL3Site    addUmhTarget"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doBgp4UmhImportTarget
#
# This command gets bgp4Vpn UMH Import Target parameters.
# Arguments(s):
# 
# Returned Result:
########################################################################

proc scriptGen::doBgp4UmhImportTarget {} \
{
    set retCode 0
       
    generateCommand bgp4UmhImportTarget
    
    sgPuts "bgp4VpnL3Site    addUmhImportTarget"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doBgpUmhSelectionRouteRange
#
# This command gets UMH Selection route ranges params for BGP
# Arguments(s):
# Name : RouteRange Name
# Returned Result:
########################################################################

proc scriptGen::doBgpUmhSelectionRouteRange {name} \
{
  
    set retCode 0

    if {[bgp4UmhSelectionRouteRange cget -enableASPath]} {
       if {![bgp4UmhSelectionRouteRange getFirstASPathItem] } {
           doBgp4AsPath  bgp4UmhSelectionRouteRange
           while {![bgp4UmhSelectionRouteRange getNextASPathItem] } {
               doBgp4AsPath bgp4UmhSelectionRouteRange 
		   }
      }       
    }                                          

	if {![bgp4UmhSelectionRouteRange getFirstExtendedCommunity] } {
       doBgp4Community  bgp4UmhSelectionRouteRange
       while {![bgp4UmhSelectionRouteRange getNextExtendedCommunity] } {
           doBgp4Community  bgp4UmhSelectionRouteRange
       }
	}     

    generateCommand bgp4UmhSelectionRouteRange
    sgPuts "bgp4VpnL3Site addUmhSelectionRouteRange $name"     
    sgPuts ""
    sgPuts "bgp4UmhSelectionRouteRange clearASPathList"

    return $retCode
}
########################################################################
# Procedure: doBgpMplsRouteRange
#
# This command gets MPLS route ranges params for BGP
# Arguments(s):
# Name : RouteRange Name
# Returned Result:
########################################################################

proc scriptGen::doBgpMplsRouteRange {name} \
{
  
    set retCode 0

    if {[bgp4MplsRouteRange cget -enableASPath]} {
       if {![bgp4MplsRouteRange getFirstASPathItem] } {
           doBgp4AsPath  bgp4MplsRouteRange
           while {![bgp4MplsRouteRange getNextASPathItem] } {
               doBgp4AsPath bgp4MplsRouteRange 
		   }
      }       
    }                                          

	if {![bgp4MplsRouteRange getFirstExtendedCommunity] } {
       doBgp4Community  bgp4MplsRouteRange
       while {![bgp4MplsRouteRange getNextExtendedCommunity] } {
           doBgp4Community  bgp4MplsRouteRange
       }
	}     

    generateCommand bgp4MplsRouteRange
    sgPuts "bgp4Neighbor addMplsRouteRange $name"     
    sgPuts ""
    sgPuts "bgp4MplsRouteRange clearASPathList"

    return $retCode
}

########################################################################
# Procedure: doBgp4Community
#
# This command gets bgp4 extended community parameters.
# Arguments(s):
# cmd : The command  for adding.
# Returned Result:
########################################################################

proc scriptGen::doBgp4Community {cmd} \
{
    set retCode 0
       
    generateCommand bgp4ExtendedCommunity
    
    sgPuts "$cmd    addExtendedCommunity"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: getCommunityListEnum
#
# 
# Arguments(s):
#           communityList:
#
# Returned Result: List with Enum text
########################################################################
    
proc scriptGen::getCommunityListEnum {communityList} \
{
    variable enumsArray
	set enumText {}

    foreach value $communityList {
        set enumValList $enumsArray(bgp4RouteItem,communityList)
        set joinedList  [join $enumValList]
        set index       [lsearch $joinedList $value]
        set retString   [lindex $joinedList [expr $index-1]]
        if { $retString == ""} {
            set retString   $value
        } else {
            set retString [format "$%s" $retString]
        }
        lappend enumText $retString
    }	
 
	return [join $enumText]
  
}
########################################################################
# Procedure: doBgpMcastReceiverSite
#
# This command gets Multicast Receiver Site params for BGP
# Arguments(s):
# Name : Multicast Receiver Site Name
# Returned Result:
########################################################################

proc scriptGen::doBgpMcastReceiverSite {name} \
{
  
    set retCode 0

    generateCommand bgp4McastReceiverSite
    sgPuts "bgp4VpnL3Site addMcastReceiverSite $name"     
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doBgpOpaqueValueElement
#
# This command gets Opaque Value Element params for BGP
# Arguments(s):
# Name : Opaque Value Elemnt Name
# Returned Result:
########################################################################

proc scriptGen::doBgpOpaqueValueElement {name} \
{
  
    set retCode 0

    generateCommand bgp4OpaqueValueElement
    sgPuts "bgp4VpnL3Site addOpaqueValueElement $name"     
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doBgpMcastSenderSite
#
# This command gets Multicast Sender Site params for BGP
# Arguments(s):
# Name : Multicast Sender Site Name
# Returned Result:
########################################################################

proc scriptGen::doBgpMcastSenderSite {name} \
{
  
    set retCode 0

	if {![bgp4McastSenderSite getFirstOpaqueValueElement]} {
        set nameIndex 2
        doBgp4SenderSiteOpaqueValueElement  opaqueValueElement1
        while {![bgp4McastSenderSite getNextOpaqueValueElement]} {
            doBgp4SenderSiteOpaqueValueElement [format "opaqueValueElement%i" $nameIndex]
            incr nameIndex
        }
    }

    generateCommand bgp4McastSenderSite
    sgPuts "bgp4VpnL3Site addMcastSenderSite $name"     
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doBgp4SenderSiteOpaqueValueElement
#
# This command gets Opaque Value Element params for BGP
# Arguments(s):
# Name : Opaque Value Elemnt Name
# Returned Result:
########################################################################

proc scriptGen::doBgp4SenderSiteOpaqueValueElement {name} \
{
  
    set retCode 0

    generateCommand bgp4SenderSiteOpaqueValueElement
    sgPuts "bgp4McastSenderSite addOpaqueValueElement $name"     
    sgPuts ""

    return $retCode
}

########################################################################
# 
#       ------------  OSPF procedures  ------------
#
########################################################################

########################################################################
# Procedure: getOspf
#
# This command generats Ospf server commands
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
#
########################################################################

proc scriptGen::getOspf {chassis card port} \
{
    set retCode 0
    set nameIndex 2
    if {![ospfServer select $chassis $card $port]} {
        sgPuts {ospfServer select $chassis $card $port}
        sgPuts "ospfServer clearAllRouters"
        
        if {![ospfServer getFirstRouter]} {
            doOspfRouter router1
            while {![ospfServer getNextRouter]} {
                doOspfRouter [format "router%i" $nameIndex]
                incr nameIndex
            }
        }
	}
		
        if {![ospfServer get]} {
            generateCommand ospfServer
            sgPuts "ospfServer set"
            sgPuts ""
        }
    return $retCode
}


########################################################################
# Procedure: doOspfRouter
#
# This command gets OSPF router
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################

proc scriptGen::doOspfRouter {name} \
{
    set retCode 0
    
    if {![ospfRouter getFirstInterface]} {
        set nameIndex 2
        doOspfInterface interface1
        while {![ospfRouter  getNextInterface]} {
            doOspfInterface [format "interface%i" $nameIndex]
            incr nameIndex
        }
    }               
    if {![ospfRouter getFirstRouteRange]} {
        set nameIndex 2
        doOspfRouteRange routeRange1
        while {![ospfRouter  getNextRouteRange]} {
            doOspfRouteRange [format "routeRange%i" $nameIndex]
            incr nameIndex
        }
    }            
    if {![ospfRouter getFirstUserLsaGroup]} {
        set nameIndex 2
        doOspfUserLsaGroup userLsaGroup1
        while {![ospfRouter  getNextUserLsaGroup]} {
            doOspfUserLsaGroup [format "userLsaGroup%i" $nameIndex]
            incr nameIndex
        }
    }   
    
    generateCommand ospfRouter
    sgPuts "ospfServer addRouter $name"
    sgPuts ""
    return $retCode
}  

########################################################################
# Procedure: doOspfInterface
#
# This command gets OSPF Interface
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doOspfInterface {name} \
{
    set retCode 0

    set includeSetDefault  yes

    if {![ospfInterface cget -connectToDut]} {
        
        set optionList {}
        catch {ospfInterface config} paramList
        foreach param [join $paramList] {
            if {[string compare $param "-protocolInterfaceDescription"] != 0} {
                lappend optionList [string trimleft $param -]
            }
        }

        generateCommand ospfNetworkRange
        sgPuts ""
        partiallyGenerateCommand ospfInterface $optionList

        sgPuts "ospfInterface config -ipAddress {[ospfInterface cget -ipAddress]}"
        sgPuts "ospfInterface config -ipMask	{[ospfInterface cget -ipMask]}"
        
	} else {
        generateCommand ospfInterface
    }
    sgPuts "ospfRouter addInterface $name"
    return $retCode
}  


########################################################################
# Procedure: doOspfRouteRange
#
# This command gets OSPF route range
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doOspfRouteRange {name} \
{
    set retCode 0
    generateCommand ospfRouteRange
    sgPuts "ospfRouter addRouteRange $name"
    return $retCode
}  


########################################################################
# Procedure: doOspfUserLsaGroup
#
# This command gets OSPF userLsa group
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doOspfUserLsaGroup {name} \
{
    set retCode 0
    set nameIndex 2

    if {![ospfUserLsaGroup getFirstUserLsa]} {
        doOspfUserLsa userLsa1
        while {![ospfUserLsaGroup getNextUserLsa]} {
            doOspfUserLsa [format "userLsa%i" $nameIndex]
            incr nameIndex
        }
    }
            
    generateCommand ospfUserLsaGroup
    sgPuts "ospfRouter addUserLsaGroup $name"
    return $retCode
}


########################################################################
# Procedure: doOspfUserLsa
#
# This command gets OSPF userLsa 
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doOspfUserLsa {name} \
{  
    set retCode 0
    set nameIndex 2
    set lsaType [ospfUserLsa cget -lsaType]

    if {$lsaType == $::ospfLsaRouter } {
        if {![ospfUserLsa getFirstRouterLsaInterface]} {
            doRouterLsaInterface userLsaInterface1
            while {![ospfUserLsa getNextRouterLsaInterface]} {
                doRouterLsaInterface [format "userLsaInterface%i" $nameIndex]
				incr nameIndex
            }
        }
        set lsaParamList [list advertisingRouterId enable options linkStateId routerCapabilityBits]

    } elseif {$lsaType == $::ospfLsaNetwork } {
        set lsaParamList [list advertisingRouterId enable options linkStateId neighborId networkMask]

    } elseif {$lsaType == $::ospfLsaSummaryIp } {
        set lsaParamList [list advertisingRouterId enable options linkStateId incrementLinkStateIdBy \
                          metric networkMask numberOfLSAs]

    } elseif {$lsaType == $::ospfLsaSummaryAs} {
        set lsaParamList [list advertisingRouterId enable options linkStateId]

    } elseif {$lsaType == $::ospfLsaExternal } {
        set lsaParamList [list advertisingRouterId enable options linkStateId incrementLinkStateIdBy \
                              metric networkMask numberOfLSAs forwardingAddress externalRouteTag \
                              externalMetricEBit]

    } elseif {$lsaType == $::ospfLsaOpaqueLocal || \
              $lsaType == $::ospfLsaOpaqueArea || \
              $lsaType == $::ospfLsaOpaqueDomain } {

        set tlvType [ospfUserLsa cget -tlvType]
        if {$tlvType == $::ospfRouterTlv} {

            set lsaParamList [list advertisingRouterId enable options linkStateId \
                                   tlvType tlvRouterIpAddress]
        } else {
  
            set lsaParamList [list advertisingRouterId enable options linkStateId \
                               tlvType tlvLinkType enableTlvLinkType \
                               tlvLinkId enableTlvLinkId tlvLinkMetric enableTlvLinkMetric \
                               tlvResourceClass enableTlvResourceClass tlvLocalIpAddress \
                               enableTlvLocalIpAddress tlvRemoteIpAddress  enableTlvRemoteIpAddress \
                               tlvMaxBandwidth enableTlvMaxBandwidth tlvMaxReservableBandwidth \
                               enableTlvMaxReservableBandwidth enableTlvUnreservedBandwidth \
                               tlvUnreservedBandwidthPriority0 tlvUnreservedBandwidthPriority1 \
                               tlvUnreservedBandwidthPriority2 tlvUnreservedBandwidthPriority3 \
                               tlvUnreservedBandwidthPriority4 tlvUnreservedBandwidthPriority5 \
                               tlvUnreservedBandwidthPriority6 tlvUnreservedBandwidthPriority7] 
        }
    
    } else {
        set lsaParamList {}
    }
        
    partiallyGenerateCommand ospfUserLsa $lsaParamList
    sgPuts "ospfUserLsaGroup addUserLsa $name [getEnumString ospfUserLsa -lsaType] " 
    sgPuts "ospfUserLsa  clearAllRouterLsaInterface" 
    

    return $retCode
}

########################################################################
# Procedure: doRouterLsaInterface
#
# This command gets OSPF Router Lsa Interface
# Arguments(s):
# name : RouterLSAInterfaceName
# Returned Result:
########################################################################
 
proc scriptGen::doRouterLsaInterface {name} \
{  
    set retCode 0
    generateCommand ospfRouterLsaInterface
    sgPuts "ospfUserLsa addInterfaceDescriptionToRouterLsa $name"

    return $retCode
}

########################################################################
# 
#       ------------  ISIS procedures  ------------
#
########################################################################

########################################################################
# Procedure: getisis
#
# This command generats isis server commands
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
#
########################################################################

proc scriptGen::getIsis {chassis card port} \
{
    set retCode 0
    set nameIndex 2
    if {![isisServer select $chassis $card $port]} {
        sgPuts {isisServer select $chassis $card $port}
        sgPuts "isisServer clearAllRouters"
        
        if {![isisServer getFirstRouter]} {
            doIsisRouter router1
            while {![isisServer getNextRouter]} {
                doIsisRouter [format "router%i" $nameIndex]
                incr nameIndex
            }
        }
		if {![isisServer get]} {
            generateCommand isisServer
            sgPuts "isisServer set"
            sgPuts ""
        }
    }
    return $retCode
}


########################################################################
# Procedure: doIsisRouter
#
# This command gets isis router
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################

proc scriptGen::doIsisRouter {name} \
{
    set retCode 0
    
    if {![isisRouter getFirstInterface]} {
        set nameIndex 2
        doIsisInterface interface1
        while {![isisRouter  getNextInterface]} {
            doIsisInterface [format "interface%i" $nameIndex]
            incr nameIndex
        }
    }
    
 
    if {![isisRouter getFirstRouteRange]} {
        set nameIndex 2
        doIsisRouteRange routeRange1
        while {![isisRouter  getNextRouteRange]} {
            doIsisRouteRange [format "routeRange%i" $nameIndex]
            incr nameIndex
        }
    }            
 
	if {![isisRouter getFirstGrid]} {
        set nameIndex 2
        doIsisGrid grid1
        while {![isisRouter  getNextGrid]} {
            doIsisGrid [format "grid%i" $nameIndex]
            incr nameIndex
        }
    }

	if {![isisRouter getFirstUnicastMacRange]} {
        set nameIndex 2
        doIsisDceUnicastMacRange unicastMacRange1
        while {![isisRouter  getNextUnicastMacRange]} {
            doIsisDceUnicastMacRange [format "unicastMacRange%i" $nameIndex]
            incr nameIndex
        }
    }
	
	if {![isisRouter getFirstMulticastMacRange]} {
        set nameIndex 2
        doIsisDceMulticastMacRange macRange1
        while {![isisRouter  getNextMulticastMacRange]} {
            doIsisDceMulticastMacRange [format "macRange%i" $nameIndex]
            incr nameIndex
        }
    }
	
	if {![isisRouter getFirstMulticastIpv4GroupRange]} {
        set nameIndex 2
        doIsisDceMulticastIpv4GroupRange ipv4GroupRange1
        while {![isisRouter  getNextMulticastIpv4GroupRange]} {
            doIsisDceMulticastIpv4GroupRange [format "ipv4GroupRange%i" $nameIndex]
            incr nameIndex
        }
    }

	if {![isisRouter getFirstMulticastIpv6GroupRange]} {
        set nameIndex 2
        doIsisDceMulticastIpv6GroupRange ipv6GroupRange1
        while {![isisRouter  getNextMulticastIpv6GroupRange]} {
            doIsisDceMulticastIpv6GroupRange [format "ipv6GroupRange%i" $nameIndex]
            incr nameIndex
        }
    }
    
    if {![isisRouter getFirstDceNetworkRange]} {
        set nameIndex 2
        doIsisDceNetworkRange networkRange1
        while {![isisRouter  getNextDceNetworkRange]} {
            doIsisDceNetworkRange [format "networkRange%i" $nameIndex]
            incr nameIndex
        }
    }	       
    
    if {![isisRouter getFirstTopologyRange]} {
        set nameIndex 2
        doIsisDceTopologyRange topologyRange1
        while {![isisRouter  getNextTopologyRange]} {
            doIsisDceTopologyRange [format "topologyRange%i" $nameIndex]
            incr nameIndex
        }
    }

    if {![isisRouter getFirstSpbTopologyRange]} {
        set nameIndex 2
        doIsisSpbTopologyRange spbTopologyRange1
        while {![isisRouter  getNextSpbTopologyRange]} {
            doIsisSpbTopologyRange [format "spbTopologyRange%i" $nameIndex]
            incr nameIndex
        }
    }
    
    if {![isisRouter getFirstSpbmNetworkRange]} {
        set nameIndex 2
        doIsisSpbmNetworkRange spbNetworkRange1
        while {![isisRouter  getNextSpbmNetworkRange]} {
            doIsisSpbmNetworkRange [format "spbNetworkRange%i" $nameIndex]
            incr nameIndex
        }
    }

    generateCommand isisRouter
    sgPuts "isisServer addRouter $name"
    sgPuts ""
    return $retCode
}  

########################################################################
# Procedure: doIsisInterface
#
# This command gets isis Interface
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doIsisInterface {name} \
{
    set retCode 0

    sgPuts "isisInterface setDefault"
	if {![isisInterface cget -connectToDut]} {
		sgPuts "isisInterface config -ipAddress {[isisInterface cget -ipAddress]}"
		sgPuts "isisInterface config -ipMask	{[isisInterface cget -ipMask]}"
	}

    generateCommand isisInterface noSetDefault
    sgPuts "isisRouter addInterface $name"
	sgPuts ""
    return $retCode
}  

########################################################################
# Procedure: doIsisDceInterestedVlanRange
#
# This command gets isis Dce Interested Vlan
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doIsisDceInterestedVlanRange {name} \
{
    set retCode 0
    generateCommand isisDceInterestedVlanRange
    sgPuts "isisDceTopologyRange addDceInterestedVlanRange $name"
	sgPuts ""
    return $retCode
}

########################################################################
# Procedure: doIsisRouteRange
#
# This command gets isis route range
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doIsisRouteRange {name} \
{
    set retCode 0
    generateCommand isisRouteRange
    sgPuts "isisRouter addRouteRange $name"
	sgPuts ""
    return $retCode
}  

########################################################################
# Procedure: doIsisGrid
#
# This command gets isis grid
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################

proc scriptGen::doIsisGrid {name} \
{
    set retCode 0
    
    if {![isisGrid getFirstInternodeRoute]} {
        doIsisInternodeRoute 
        while {![isisGrid  getNextInternodeRoute]} {
            doIsisInternodeRoute 
        }
    } 
	              
    if {![isisGrid getFirstRoute]} {
        doIsisGridRoute 
        while {![isisGrid  getNextRoute]} {
            doIsisGridRoute 
        }
    }   
	
	sgPuts ""

	if {![isisGrid getFirstOutsideLink]} {
        doIsisGridOutsideLink 
        while {![isisGrid  getNextOutsideLink]} {
            doIsisGridOutsideLink 
        }
    }   

	sgPuts ""
	if {[isisGrid cget -enableTe]} {

		if {![isisGrid getFirstTePath]} {
			doIsisGridTePath
			while {![isisGrid  getNextTePath]} {
				doIsisGridTePath 
			}
		} 
		sgPuts "" 
		generateCommand isisGridRangeTe
		
		sgPuts ""
		if {[isisGrid cget -overrideEntryTe]} {
			generateCommand isisGridEntryTe
			sgPuts ""
		}
	}

	
    generateCommand isisGrid
    sgPuts "isisRouter addGrid $name"
    sgPuts ""
    return $retCode
}  



########################################################################
# Procedure: doIsisInternodeRoute
#
# This command gets isis Grid internode
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doIsisInternodeRoute {} \
{
    set retCode 0
    generateCommand isisGridInternodeRoute
    sgPuts "isisGrid addInternodeRoute"
	sgPuts ""
    return $retCode
}  


########################################################################
# Procedure: doIsisGridRoute
#
# This command gets isis Grid route 
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doIsisGridRoute {} \
{
    set retCode 0
    generateCommand isisGridRoute
    sgPuts "isisGrid addRoute"
	sgPuts ""
    return $retCode
}  


########################################################################
# Procedure: doIsisGridTePath
#
# This command gets isis Grid TE Path
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doIsisGridTePath {} \
{
    set retCode 0
    generateCommand isisGridTePath
    sgPuts "isisGrid addTePath"
    return $retCode
}  


########################################################################
# Procedure: doIsisGridOutsideLink
#
# This command gets isis grid outsideLink
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doIsisGridOutsideLink {} \
{
    set retCode 0

	if {![isisGridOutsideLink getFirstRoute]} {

        generateCommand isisGridInternodeRoute
		sgPuts "isisGridOutsideLink addRoute"

        while {![isisGridOutsideLink  getNextRoute]} {
            generateCommand isisGridInternodeRoute
			sgPuts "isisGridOutsideLink addRoute"
        }
    }   

    generateCommand isisGridOutsideLink
    sgPuts "isisGrid addOutsideLink"
	sgPuts ""
    return $retCode
}  

########################################################################
# Procedure: doIsisDceUnicastMacRange
#
# This command gets isis Dce/Trill Unicast Mac range
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doIsisDceUnicastMacRange {name} \
{
    set retCode 0
    generateCommand isisUnicastMacRange
    sgPuts "isisRouter addUnicastMacRange $name"
	sgPuts ""
    return $retCode
} 

########################################################################
# Procedure: doIsisDceMulticastMacRange
#
# This command gets isis Dce Multicast Mac range
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doIsisDceMulticastMacRange {name} \
{
    set retCode 0
    generateCommand isisDceMulticastMacRange
    sgPuts "isisRouter addMulticastMacRange $name"
	sgPuts ""
    return $retCode
} 

########################################################################
# Procedure: doIsisDceMulticastIpv4GroupRange
#
# This command gets isis Dce Multicast Ipv6Group range
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doIsisDceMulticastIpv4GroupRange {name} \
{
    set retCode 0
    generateCommand isisDceMulticastIpv4GroupRange
    sgPuts "isisRouter addMulticastIpv4GroupRange $name"
	sgPuts ""
    return $retCode
}

########################################################################
# Procedure: doIsisDceMulticastIpv6GroupRange
#
# This command gets isis Dce Multicast Ipv6Group range
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doIsisDceMulticastIpv6GroupRange {name} \
{
    set retCode 0
    generateCommand isisDceMulticastIpv6GroupRange
    sgPuts "isisRouter addMulticastIpv6GroupRange $name"
	sgPuts ""
    return $retCode
}


########################################################################
# Procedure: doIsisDceTopologyRange
#
# This command gets isis Dce Topology range
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doIsisDceTopologyRange {name} \
{
    set retCode 0
    if {![isisDceTopologyRange getFirstDceInterestedVlanRange]} {
		set nameIndex 2
		doIsisDceInterestedVlanRange interestedVlanRange1
		while {![isisDceTopologyRange  getNextDceInterestedVlanRange]} {
			doIsisDceInterestedVlanRange [format "interestedVlanRange%i" $nameIndex]
			incr nameIndex
		}
	}
    generateCommand isisDceTopologyRange
    sgPuts "isisRouter addTopologyRange $name"
	sgPuts ""
    return $retCode
}

########################################################################
# Procedure: doIsisSpbTopologyRange
#
# This command gets isis Spb Topology range
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doIsisSpbTopologyRange {name} \
{
    set retCode 0
    if {![isisSpbTopologyRange getFirstSpbBaseVidRange]} {
		set nameIndex 2
		doIsisSpbBaseVidRange spbBaseVidRange1
		while {![isisSpbTopologyRange  getNextSpbBaseVidRange]} {
			doIsisSpbBaseVidRange [format "spbBaseVidRange%i" $nameIndex]
			incr nameIndex
		}
	}
    generateCommand isisSpbTopologyRange
    sgPuts "isisRouter addSpbTopologyRange $name"
	sgPuts ""
    return $retCode
}

########################################################################
# Procedure: doIsisSpbBaseVidRange
#
# This command gets isis Spb BaseVid range
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doIsisSpbBaseVidRange {name} \
{
    set retCode 0
    if {![isisSpbBaseVidRange getFirstSpbISidRange]} {
		set nameIndex 2
		doIsisSpbISidRange spbISidRange1
		while {![isisSpbBaseVidRange  getNextSpbISidRange]} {
			doIsisSpbISidRange [format "spbISidRange%i" $nameIndex]
			incr nameIndex
		}
	}
    generateCommand isisSpbBaseVidRange
    sgPuts "isisSpbTopologyRange addSpbBaseVidRange $name"
	sgPuts ""
    return $retCode
}

########################################################################
# Procedure: doIsisSpbISidRange
#
# This command gets isis SpbISid range
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doIsisSpbISidRange {name} \
{
    set retCode 0
    generateCommand isisSpbISidRange
    sgPuts "isisSpbBaseVidRange addSpbISidRange $name"
	sgPuts ""
    return $retCode
}


########################################################################
# Procedure: doIsisSpbmNetworkRange
#
# This command gets isis Spbm Network range
# Arguments(s):
# name : NetworkRangeName
# Returned Result:
########################################################################      

proc scriptGen::doIsisSpbmNetworkRange {name} \
{
    set retCode 0

    if {![isisSpbmNetworkRange getFirstSpbmNodeTopologyRange]} {
        set nameIndex 2
        doIsisSpbmNodeTopologyRange nodeTopologyRange1
        while {![isisSpbmNetworkRange  getNextSpbmNodeTopologyRange]} {
            doIsisSpbmNodeTopologyRange [format "nodeTopologyRange%i" $nameIndex]
            incr nameIndex
        }
    }
    
    if {![isisSpbmNetworkRange getFirstSpbOutsideLinks]} {
        set nameIndex 2
        doIsisSpbmOutsideLinks OutsideLinkRange1
        while {![isisSpbmNetworkRange  getNextSpbOutsideLinks]} {
            doIsisSpbmOutsideLinks [format "OutsideLinkRange%i" $nameIndex]
            incr nameIndex
        }
    }
    
    generateCommand isisSpbmNetworkRange
    sgPuts "isisRouter addSpbmNetworkRange $name"
	sgPuts ""
    return $retCode
}


########################################################################
# Procedure: doIsisSpbmNodeTopologyRange
#
# This command gets isis Spbm Node Topology range
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doIsisSpbmNodeTopologyRange {name} \
{
    set retCode 0
    if {![isisSpbmNodeTopologyRange getFirstSpbmNodeBaseVidRange]} {
            set nameIndex 2
            doIsisSpbmNodeBaseVidRange nodeBaseVidRange1
            while {![isisSpbmNodeTopologyRange  getNextSpbmNodeBaseVidRange]} {
                doIsisSpbmNodeBaseVidRange [format "nodeBaseVidRange%i" $nameIndex]
                incr nameIndex
            }
    }
    generateCommand isisSpbmNodeTopologyRange
    sgPuts "isisSpbmNetworkRange addSpbmNodeTopologyRange $name"
	sgPuts ""
    return $retCode
}

########################################################################
# Procedure: doIsisSpbmNodeBaseVidRange
#
# This command gets isis SpbmNode BaseVid range
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doIsisSpbmNodeBaseVidRange {name} \
{
    set retCode 0
    if {![isisSpbmNodeBaseVidRange getFirstSpbmNodeISidRange]} {
		set nameIndex 2
		doIsisSpbmNodeISidRange spbmNodeISidRange1
		while {![isisSpbmNodeBaseVidRange  getNextSpbmNodeISidRange]} {
			doIsisSpbmNodeISidRange [format "spbmNodeISidRange%i" $nameIndex]
			incr nameIndex
		}
	}
    generateCommand isisSpbmNodeBaseVidRange
    sgPuts "isisSpbmNodeTopologyRange addSpbmNodeBaseVidRange $name"
	sgPuts ""
    return $retCode
}

########################################################################
# Procedure: doIsisSpbmNodeISidRange
#
# This command gets isis Spbm Node ISid range
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doIsisSpbmNodeISidRange {name} \
{
    set retCode 0
    generateCommand isisSpbmNodeISidRange
    sgPuts "isisSpbmNodeBaseVidRange addSpbmNodeISidRange $name"
	sgPuts ""
    return $retCode
}

########################################################################
# Procedure: doIsisSpbmOutsideLinks
#
# This command gets isis Spbm Network Outside Links
# Arguments(s):
# name : outsideLinks
# Returned Result:
########################################################################      

proc scriptGen::doIsisSpbmOutsideLinks {name} \
{
    set retCode 0
    generateCommand isisSpbOutsideLinks
    sgPuts "isisSpbmNetworkRange addSpbOutsideLinks $name"
	sgPuts ""
	return $retCode
}

########################################################################
# Procedure: doIsisDceNetworkRange
#
# This command gets isis Dce Network range
# Arguments(s):
# name : NetworkRangeName
# Returned Result:
########################################################################      

proc scriptGen::doIsisDceNetworkRange {name} \
{
    set retCode 0

	if {![isisDceNetworkRange getFirstNodeUnicastMacRange]} {
        set nameIndex 2
        doIsisNodeUnicastMacRange nodeUnicastMacRange1
        while {![isisDceNetworkRange  getNextNodeUnicastMacRange]} {
            doIsisNodeUnicastMacRange [format "nodeUnicastMacRange%i" $nameIndex]
            incr nameIndex
        }
    }

	if {![isisDceNetworkRange getFirstDceNodeMacGroups]} {
        set nameIndex 2
        doIsisDceNodeMacGroups nodeMacGroups1
        while {![isisDceNetworkRange  getNextDceNodeMacGroups]} {
            doIsisDceNodeMacGroups [format "nodeMacGroups%i" $nameIndex]
            incr nameIndex
        }
    }

	if {![isisDceNetworkRange getFirstDceNodeIpv4Groups]} {
        set nameIndex 2
        doIsisDceNodeIpv4Groups nodeIpv4Groups1
        while {![isisDceNetworkRange  getNextDceNodeIpv4Groups]} {
            doIsisDceNodeIpv4Groups [format "nodeIpv4Groups%i" $nameIndex]
            incr nameIndex
        }
    }

	if {![isisDceNetworkRange getFirstDceNodeIpv6Groups]} {
        set nameIndex 2
        doIsisDceNodeIpv6Groups nodeIpv6Groups1
        while {![isisDceNetworkRange  getNextDceNodeIpv6Groups]} {
            doIsisDceNodeIpv6Groups [format "nodeIpv6Groups%i" $nameIndex]
            incr nameIndex
        }
    }

	if {![isisDceNetworkRange getFirstDceOutsideLinks]} {
        set nameIndex 2
        doIsisDceOutsideLinks outsideLinks1
        while {![isisDceNetworkRange  getNextDceOutsideLinks]} {
            doIsisDceOutsideLinks [format "outsideLinks%i" $nameIndex]
            incr nameIndex
        }
    }
    
    if {![isisDceNetworkRange getFirstDceNodeTopologyRange]} {
        set nameIndex 2
        doIsisDceNodeTopologyRange nodeTopologyRange1
        while {![isisDceNetworkRange  getNextDceNodeTopologyRange]} {
            doIsisDceNodeTopologyRange [format "nodeTopologyRange%i" $nameIndex]
            incr nameIndex
        }
    }
    
    generateCommand isisDceNetworkRange
    sgPuts "isisRouter addDceNetworkRange $name"
	sgPuts ""
    return $retCode
}


########################################################################
# Procedure: doIsisDceNodeTopologyRange
#
# This command gets isis Dce Node Topology range
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doIsisDceNodeTopologyRange {name} \
{
    set retCode 0
    if {![isisDceNodeTopologyRange getFirstDceNodeInterestedVlanRange]} {
            set nameIndex 2
            doIsisDceNodeInterestedVlanRange nodeInterestedVlanRange1
            while {![isisDceNodeTopologyRange  getNextDceNodeInterestedVlanRange]} {
                doIsisDceNodeInterestedVlanRange [format "nodeInterestedVlanRange%i" $nameIndex]
                incr nameIndex
            }
    }
    generateCommand isisDceNodeTopologyRange
    sgPuts "isisDceNetworkRange addDceNodeTopologyRange $name"
	sgPuts ""
    return $retCode
}

########################################################################
# Procedure: doIsisDceNodeInterestedVlanRange
#
# This command gets isis Dce Node Interested Vlan Range
# Arguments(s):
# name : vlanRange
# Returned Result:
########################################################################      

proc scriptGen::doIsisDceNodeInterestedVlanRange {name} \
{
    set retCode 0
    generateCommand isisDceNodeInterestedVlanRange
    sgPuts "isisDceNodeTopologyRange addDceNodeInterestedVlanRange $name"
	sgPuts ""
	return $retCode
}


#######################################################################
# Procedure: doIsisNodeUnicastMacRange
#
# This command gets isis Dce/Trill Network Mac Group range
# Arguments(s):
# name : nodeUnicastMacRange
# Returned Result:
########################################################################      

proc scriptGen::doIsisNodeUnicastMacRange {name} \
{
    set retCode 0
    generateCommand isisNodeUnicastMacRange
    sgPuts "isisDceNetworkRange addNodeUnicastMacRange $name"
	sgPuts ""
	return $retCode
}
 
########################################################################
# Procedure: doIsisDceNodeMacGroups
#
# This command gets isis Dce Network Mac Group range
# Arguments(s):
# name : nodeMacGroups
# Returned Result:
########################################################################      

proc scriptGen::doIsisDceNodeMacGroups {name} \
{
    set retCode 0
    generateCommand isisDceNodeMacGroups
    sgPuts "isisDceNetworkRange addDceNodeMacGroups $name"
	sgPuts ""
	return $retCode
}
 
########################################################################
# Procedure: doIsisDceNodeIpv4Groups
#
# This command gets isis Dce Network Ipv4 Group range
# Arguments(s):
# name : nodeIpv4Groups
# Returned Result:
########################################################################      

proc scriptGen::doIsisDceNodeIpv4Groups {name} \
{
    set retCode 0
    generateCommand isisDceNodeIpv4Groups
    sgPuts "isisDceNetworkRange addDceNodeIpv4Groups $name"
	sgPuts ""
	return $retCode
}
 
########################################################################
# Procedure: doIsisDceNodeIpv6Groups
#
# This command gets isis Dce Network Ipv6 Group range
# Arguments(s):
# name : nodeIpv6Groups
# Returned Result:
########################################################################      

proc scriptGen::doIsisDceNodeIpv6Groups {name} \
{
    set retCode 0
    generateCommand isisDceNodeIpv6Groups
    sgPuts "isisDceNetworkRange addDceNodeIpv6Groups $name"
	sgPuts ""
	return $retCode
}
 
########################################################################
# Procedure: doIsisDceOutsideLinks
#
# This command gets isis Dce Network Outside Links
# Arguments(s):
# name : outsideLinks
# Returned Result:
########################################################################      

proc scriptGen::doIsisDceOutsideLinks {name} \
{
    set retCode 0
    generateCommand isisDceOutsideLinks
    sgPuts "isisDceNetworkRange addDceOutsideLinks $name"
	sgPuts ""
	return $retCode
}
 
########################################################################
# 
#       ------------  RIP procedures  ------------
#
########################################################################


########################################################################
# Procedure: scriptGen::getRip
#
# This command generats rip server commands
#
# Arguments(s):
#   chassis :       chassis Id
#   card    :       card Id
#   port    :       port Id
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::getRip {chassis card port} \
{
    set retCode 0
    set nameIndex 2

    if {![ripServer select $chassis $card $port]} {
        sgPuts {ripServer select $chassis $card $port}
        sgPuts "ripServer clearAllRouters"
        
        if {![ripServer getFirstRouter]} {
            doRipRouter router1
            while {![ripServer getNextRouter]} {
                doRipRouter [format "router%i" $nameIndex]
                incr nameIndex
            }
        } 
    } 

    return $retCode
}

########################################################################
# Procedure: doRipRouter
#
# This command gets rip router
#
# Arguments(s):
#
#   name :          Rip router name
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::doRipRouter {name} \
{
    set retCode 0
            
    if {![ripInterfaceRouter getFirstRouteRange]} {
        set nameIndex 2
        doRipRouteRange routeRange1
        while {![ripInterfaceRouter  getNextRouteRange]} {
            doRipRouteRange [format "routeRange%i" $nameIndex]
            incr nameIndex
        }
    } 

    generateCommand ripInterfaceRouter
    sgPuts "ripServer addRouter $name"
    sgPuts ""
    
    return $retCode
}  

########################################################################
# Procedure: doRipRouter
#
# This command gets rip router range
#
# Arguments(s):
#
#   name :          Rip router range name
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doRipRouteRange {name} \
{
    set retCode 0

    generateCommand ripRouteRange
    sgPuts "ripInterfaceRouter addRouteRange $name"

    return $retCode
}


########################################################################
# 
#       ------------  RIPng procedures  ------------
#
########################################################################

########################################################################
# Procedure: getripng
#
# This command generats ripng server commands
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
#
########################################################################
proc scriptGen::getRipng {chassis card port} \
{
    set retCode 0
    set nameIndex 2
    if {![ripngServer select $chassis $card $port]} {
        sgPuts {ripngServer select $chassis $card $port}
        sgPuts "ripngServer clearAllRouters"
        
        if {![ripngServer getFirstRouter]} {
            doRipngRouter router1
            while {![ripngServer getNextRouter]} {
                doRipngRouter [format "router%i" $nameIndex]
                incr nameIndex
            }
        }
        if {![ripngServer get]} {
            generateCommand ripngServer
            sgPuts "ripngServer set"
            sgPuts ""
        }    
    }

    return $retCode
}


########################################################################
# Procedure: doRipngRouter
#
# This command gets ripng router
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################
proc scriptGen::doRipngRouter {name} \
{
    set retCode 0
    
    if {![ripngRouter getFirstInterface]} {
        set nameIndex 2
        doRipngInterface interface1
        while {![ripngRouter  getNextInterface]} {
            doRipngInterface [format "interface%i" $nameIndex]
            incr nameIndex
        }
    }               
    if {![ripngRouter getFirstRouteRange]} {
        set nameIndex 2
        doRipngRouteRange routeRange1
        while {![ripngRouter  getNextRouteRange]} {
            doRipngRouteRange [format "routeRange%i" $nameIndex]
            incr nameIndex
        }
    }            
 
    generateCommand ripngRouter
    sgPuts "ripngServer addRouter $name"
    sgPuts ""
    return $retCode
}  

########################################################################
# Procedure: doRipngInterface
#
# This command gets ripng Interface
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      
proc scriptGen::doRipngInterface {name} \
{
    set retCode 0
    generateCommand ripngInterface
    sgPuts "ripngRouter addInterface $name"
    return $retCode
}  


########################################################################
# Procedure: doRipngRouteRange
#
# This command gets ripng route range
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      
proc scriptGen::doRipngRouteRange {name} \
{
    set retCode 0
    generateCommand ripngRouteRange
    sgPuts "ripngRouter addRouteRange $name"
    return $retCode
}  


########################################################################
# 
#       ------------  RSVP procedures  ------------
#
########################################################################

########################################################################
# Procedure: getRsvp
#
# This command generats rsvp server commands
#
# Arguments(s):
#   chassis :       chassis Id
#   card    :       card Id
#   port    :       port Id
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::getRsvp {chassis card port} \
{
    set retCode 0
    set nameIndex 2

    if {![rsvpServer select $chassis $card $port]} {
		sgPuts ""
        sgPuts {rsvpServer select $chassis $card $port}
        sgPuts "rsvpServer clearAllNeighborPair"
        
        if {![rsvpServer getFirstNeighborPair]} {
            doRsvpNeighborPair neighborPair1
            while {![rsvpServer getNextNeighborPair]} {
                doRsvpNeighborPair [format "neighborPair%i" $nameIndex]
                incr nameIndex
            }
        }

        if {![rsvpServer get]} {
            generateCommand rsvpServer
            sgPuts "rsvpServer set"
            sgPuts ""
        }
    } 

    return $retCode
}

########################################################################
# Procedure: doRsvpNeighborPair
#
# This command gets rip router
#
# Arguments(s):
#
#   name :          Rsvp neighbor pair name
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::doRsvpNeighborPair {name} \
{
    set retCode 0
           
    if {![rsvpNeighborPair getFirstDestinationRange]} {
        set nameIndex 2
        doRsvpDestinationRange destinationRange1
        while {![rsvpNeighborPair   getNextDestinationRange]} {
            doRsvpDestinationRange [format "destinationRange%i" $nameIndex]
            incr nameIndex
        }
    }         

	if {![rsvpNeighborPair getFirstHelloTlv]} {
        generateCommand rsvpCustomTlv
		sgPuts "rsvpNeighborPair addHelloTlv"
		sgPuts ""
        while {![rsvpNeighborPair   getNextHelloTlv]} {
			generateCommand rsvpCustomTlv
			sgPuts "rsvpNeighborPair addHelloTlv"
			sgPuts ""
        }
    }

    generateCommand rsvpNeighborPair
    sgPuts "rsvpServer addNeighborPair $name"
    sgPuts ""


    return $retCode
} 

########################################################################
# Procedure: doRsvpDestinationRange
#
# This command gets Rsvp Destination Range
#
# Arguments(s):
#
#   name :          Rsvp Destination Range name
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::doRsvpDestinationRange {name} \
{
    set retCode 0

    if {![rsvpDestinationRange getFirstSenderRange]} {
        set nameIndex 2
        doRsvpSenderRange senderRange1
        while {![rsvpDestinationRange  getNextSenderRange]} {
            doRsvpSenderRange [format "senderRange%i" $nameIndex]
            incr nameIndex
        }
    } 
    
    if {![rsvpDestinationRange getFirstTunnelLeafRange]} {
        set nameIndex 2
        doRsvpTunnelLeafRange tunnelLeafRange1
        while {![rsvpDestinationRange  getNextTunnelRange]} {
            doRsvpTunnelLeafRange [format "tunnelLeafRange%i" $nameIndex]
            incr nameIndex
        }
    } 
       
    if {![rsvpDestinationRange getFirstTailTrafficEndPoint]} {
        set nameIndex 2
        doRsvpTunnelTailTrafficEndPoint tunnelTailTrafficEndPoint1
		# Currently we do not support multiple traffic End points
        #while {![rsvpDestinationRange  getNextTailTrafficEndPoint]} {
        #    doRsvpTunnelTailTrafficEndPoint [format "tunnelTailTrafficEndPoint%i" $nameIndex]
        #    incr nameIndex
        #}
    } 
       
    if {![rsvpDestinationRange getFirstEroItem]} {
        doRsvpEroItem 
        while {![rsvpDestinationRange  getNextEroItem]} {
            doRsvpEroItem 
        }
    }

    if {![rsvpDestinationRange getFirstRroItem]} {
        doRsvpRroItem 
        while {![rsvpDestinationRange  getNextRroItem]} {
            doRsvpRroItem 
        }
    }     
    
	if {[rsvpDestinationRange cget -behavior] == $::rsvpEgress } {
		if {![rsvpDestinationRange getFirstResvTlv]} {
			generateCommand rsvpCustomTlv
			sgPuts "rsvpDestinationRange addResvTlv"
			sgPuts ""
			while {![rsvpDestinationRange   getNextResvTlv]} {
				generateCommand rsvpCustomTlv
				sgPuts "rsvpDestinationRange addResvTlv"
				sgPuts ""
			}
		}

		if {![rsvpDestinationRange getFirstResvTearTlv]} {
			generateCommand rsvpCustomTlv
			sgPuts "rsvpDestinationRange addResvTearTlv"
			sgPuts ""
			while {![rsvpDestinationRange   getNextResvTearTlv]} {
				generateCommand rsvpCustomTlv
				sgPuts "rsvpDestinationRange addResvTearTlv"
				sgPuts ""
			}
		}


		if {![rsvpDestinationRange getFirstPathTlv]} {
			generateCommand rsvpCustomTlv
			sgPuts "rsvpDestinationRange addPathTlv"
			sgPuts ""
			while {![rsvpDestinationRange   getNextPathTlv]} {
				generateCommand rsvpCustomTlv
				sgPuts "rsvpDestinationRange addPathTlv"
				sgPuts ""
			}
		}

	} else {

		if {![rsvpDestinationRange getFirstResvErrTlv]} {
			generateCommand rsvpCustomTlv
			sgPuts "rsvpDestinationRange addResvErrTlv"
			sgPuts ""
			while {![rsvpDestinationRange   getNextResvErrTlv]} {
				generateCommand rsvpCustomTlv
				sgPuts "rsvpDestinationRange addResvErrTlv"
				sgPuts ""
			}
		}
	}


 
    generateCommand rsvpDestinationRange
    sgPuts "rsvpNeighborPair addDestinationRange $name"
    sgPuts "rsvpDestinationRange clearAllEro"
    sgPuts "rsvpDestinationRange clearAllRro"
    sgPuts ""


    return $retCode
}

########################################################################
# Procedure: doRsvpSenderRange
#
# This command gets rsvp router range
#
# Arguments(s):
#
#   name :          Rsvp sender range name
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doRsvpSenderRange {name} \
{
    set retCode 0

    if {![rsvpSenderRange getFirstHeadTrafficEndPoint]} {
        #set nameIndex 2
        doRsvpTunnelHeadTrafficEndPoint tunnelHeadTrafficEndPoint1
		# Currently we do not support multiple traffic End points 
        #while {![rsvpSenderRange getNextHeadTrafficEndPoint]} {
        #    doRsvpTunnelHeadTrafficEndPoint [format "tunnelHeadTrafficEndPoint%i" $nameIndex]
        #    incr nameIndex
        #}
    } 
       
    if {![rsvpSenderRange getFirstTunnelHeadToLeaf]} {
        set nameIndex 2
        doRsvpTunnelHeadToLeaf tunnelHeadToLeaf1
        while {![rsvpSenderRange getNextTunnelHeadToLeaf]} {
            doRsvpTunnelHeadToLeaf [format "tunnelHeadToLeaf%i" $nameIndex]
            incr nameIndex
        }
    } 
       
	if {![rsvpSenderRange getFirstPlr]} {
        doRsvpPlr 
        while {![rsvpSenderRange  getNextPlr]} {
            doRsvpPlr 
        }
    }

	if {![rsvpSenderRange getFirstTearTlv]} {
			generateCommand rsvpCustomTlv
			sgPuts "rsvpSenderRange addTearTlv"
			sgPuts ""
			while {![rsvpSenderRange   getNextTearTlv]} {
				generateCommand rsvpCustomTlv
				sgPuts "rsvpSenderRange addTearTlv"
				sgPuts ""
			}
		}


	if {![rsvpSenderRange getFirstPathTlv]} {
		generateCommand rsvpCustomTlv
		sgPuts "rsvpSenderRange addPathTlv"
		sgPuts ""
		while {![rsvpSenderRange   getNextPathTlv]} {
			generateCommand rsvpCustomTlv
			sgPuts "rsvpSenderRange addPathTlv"
			sgPuts ""
		}
	}


    generateCommand rsvpSenderRange
    sgPuts "rsvpDestinationRange addSenderRange $name"
	sgPuts "rsvpSenderRange clearPlrList"
	sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doRsvpTunnelLeafRange
#
# This command gets Rsvp Tunnel Leaf Range 
#
# Arguments(s):
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doRsvpTunnelLeafRange {name} \
{
    set retCode 0

    generateCommand rsvpTunnelLeafRange
    sgPuts "rsvpDestinationRange addTunnelLeafRange $name"
	sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doRsvpTunnelTailTrafficEndPoint
#
# This command gets Rsvp Tunnel Tail Traffic End-Point
#
# Arguments(s):
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doRsvpTunnelTailTrafficEndPoint {name} \
{
    set retCode 0

    generateCommand rsvpTunnelTailTrafficEndPoint
	# We do not support Add of traffic End point but only set 
    sgPuts "rsvpDestinationRange setTailTrafficEndPoint $name"
	sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doRsvpTunnelHeadTrafficEndPoint
#
# This command gets Rsvp Tunnel Head Traffic End-Point
#
# Arguments(s):
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doRsvpTunnelHeadTrafficEndPoint {name} \
{
    set retCode 0

    generateCommand rsvpTunnelHeadTrafficEndPoint
	# We do not support add of traffic end point but only set
    sgPuts "rsvpSenderRange setHeadTrafficEndPoint $name"
	sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doRsvpTunnelHeadToLeaf 
#
# This command gets Rsvp Tunnel Head-To-Leaf Entry 
#
# Arguments(s):
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doRsvpTunnelHeadToLeaf {name} \
{
    set retCode 0

    generateCommand rsvpTunnelHeadToLeaf
    sgPuts "rsvpSenderRange addTunnelHeadToLeaf $name"
	sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doRsvpEroItem
#
# This command gets Rsvp Ero item
#
# Arguments(s):
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doRsvpEroItem {} \
{
    set retCode 0

    generateCommand rsvpEroItem
    sgPuts "rsvpDestinationRange addEroItem"
	sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doRsvpRroItem
#
# This command gets Rsvp Rro Item
#
# Arguments(s):
#
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doRsvpRroItem {} \
{
    set retCode 0

    generateCommand rsvpRroItem
    sgPuts "rsvpDestinationRange addRroItem"
	sgPuts ""

    return $retCode
}  


########################################################################
# Procedure: doRsvpPlr
#
# This command gets Rsvp plr list
#
# Arguments(s):
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doRsvpPlr {} \
{
    set retCode 0

    generateCommand rsvpPlrNodeIdPair
    sgPuts "rsvpSenderRange addPlr"
	sgPuts ""

    return $retCode
}

########################################################################
# 
#       ------------  LDP procedures  ------------
#
########################################################################

########################################################################
# Procedure: getLdp
#
# This command generats ldp server commands
#
# Arguments(s):
#   chassis :       chassis Id
#   card    :       card Id
#   port    :       port Id
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::getLdp {chassis card port} \
{
    set retCode 0
    set nameIndex 2

    if {![ldpServer select $chassis $card $port]} {
        sgPuts {ldpServer select $chassis $card $port}
        sgPuts "ldpServer clearAllRouters"
        
        if {![ldpServer getFirstRouter]} {
            doLdpRouter router1
            while {![ldpServer getNextRouter]} {
                doLdpRouter [format "router%i" $nameIndex]
                incr nameIndex
            }
        }
    } 

	if {![ldpServer get]} {
        generateCommand ldpServer
        sgPuts "ldpServer set"
        sgPuts ""
    }    

    return $retCode
}




########################################################################
# Procedure: doLdpRouter
#
# This command gets LDP router
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################

proc scriptGen::doLdpRouter {name} \
{
    set retCode 0
    
    if {![ldpRouter getFirstInterface]} {
        set nameIndex 2
        doLdpInterface interface1
        while {![ldpRouter  getNextInterface]} {
            doLdpInterface [format "interface%i" $nameIndex]
            incr nameIndex
        }
    }
    sgPuts ""              
    if {![ldpRouter getFirstAdvertiseFecRange]} {
        set nameIndex 2
        doLdpAdvertiseFecRange advertiseFecRange1
        while {![ldpRouter  getNextAdvertiseFecRange]} {
            doLdpAdvertiseFecRange [format "advertiseFecRange%i" $nameIndex]
            incr nameIndex
        }
    } 
	sgPuts ""
	if {![ldpRouter getFirstExplicitIncludeIpFec]} {
       set nameIndex 2
       doLdpExplicitIncludeIpFec explicitIncludeIpFec1
       while {![ldpRouter  getNextExplicitIncludeIpFec]} {
           doLdpExplicitIncludeIpFec [format "explicitIncludeIpFec%i" $nameIndex]
           incr nameIndex
       }
    }            
	sgPuts ""          
    if {![ldpRouter getFirstRequestFecRange]} {
        set nameIndex 2
        doLdpRequestFecRange requestFecRange1
        while {![ldpRouter  getNextRequestFecRange]} {
            doLdpRequestFecRange [format "requestFecRange%i" $nameIndex]
            incr nameIndex
        }
    }            
   sgPuts ""
   if [ixUtils isVpnL2Installed] {
     
	   if {![ldpRouter getFirstL2VpnInterface]} {
			set nameIndex 2
			doLdpL2VpnInterface l2VpnInterface1
			while {![ldpRouter  getNextL2VpnInterface]} {
				doLdpL2VpnInterface [format "l2VpnInterface%i" $nameIndex]
				incr nameIndex
			}
		}
	}
    sgPuts ""
    if {![ldpRouter getFirstMulticastLeafRange]} {
	    set nameIndex 2
	    doLdpMulticastLeafRange multicastLeafRange1
	    while {![ldpRouter  getNextMulticastLeafRange]} {
		    doLdpMulticastLeafRange [format "multicastLeafRange%i" $nameIndex]
		    incr nameIndex
	    }
    }
    generateCommand ldpRouter
    sgPuts "ldpServer addRouter $name"
    sgPuts ""
    return $retCode
}  




########################################################################
# Procedure: doLdpInterface
#
# This command gets LDP Interface
# Arguments(s):
# name : Interface Name
# Returned Result:
########################################################################      

proc scriptGen::doLdpInterface {name} \
{
    set retCode 0
    
    if {![ldpInterface getFirstTargetedPeer]} {
        set nameIndex 2
        doLdpTargetedPeer  targetedPeer1
        while {![ldpInterface getNextTargetedPeer]} {
            doLdpTargetedPeer [format "targetedPeer%i" $nameIndex]
            incr nameIndex
        }
    }

	if {[ldpInterface cget -enableAtmSession] == 1} {
        if {![ldpInterface getFirstAtmLabelRange]} {
            set nameIndex 2
            doLdpAtmLabelRanger  atmLabelRange1
            while {![ldpInterface getNextAtmLabelRange]} {
                doLdpAtmLabelRanger [format "atmLabelRange%i" $nameIndex]
                incr nameIndex
            }
        }
    }

    generateCommand ldpInterface
    sgPuts "ldpRouter addInterface $name"
	sgPuts ""
    return $retCode
}  


########################################################################
# Procedure: doLdpTargetedPeer
#
# This command gets LDP targeted peer
# Arguments(s):
# name : TargetedPeer Name
# Returned Result:
########################################################################      

proc scriptGen::doLdpTargetedPeer {name} \
{
    set retCode 0
       
    generateCommand ldpTargetedPeer
    sgPuts "ldpInterface addTargetedPeer $name"
	sgPuts ""
    return $retCode
}  

########################################################################
# Procedure: doLdpAtmLabelRanger
#
# This command gets LDP ATM label Range
# Arguments(s):
# name : ATM Label range Name
# Returned Result:
########################################################################      

proc scriptGen::doLdpAtmLabelRanger {name} \
{
    set retCode 0
       
    generateCommand ldpAtmLabelRange
    sgPuts "ldpInterface addAtmLabelRange $name"
	sgPuts ""
    return $retCode
}

########################################################################
# Procedure: doLdpAdvertiseFecRange
#
# This command gets LDP advertise FEC Range
# Arguments(s):
# name : AdvertiseFecRange Name
# Returned Result:
########################################################################      

proc scriptGen::doLdpAdvertiseFecRange {name} \
{
    set retCode 0
       
    generateCommand ldpAdvertiseFecRange
    sgPuts "ldpRouter addAdvertiseFecRange $name"
	sgPuts ""
    return $retCode
}  


########################################################################
# Procedure: doLdpExplicitIncludeIpFec
#
# This command gets LDP Explicit Include FEC range
# Arguments(s):
# name : AdvertiseFecRange Name
# Returned Result:
########################################################################      

proc scriptGen::doLdpExplicitIncludeIpFec {name} \
{
    set retCode 0
       
    generateCommand ldpExplicitIncludeIpFec
    sgPuts "ldpRouter addExplicitIncludeIpFec $name"
    return $retCode
}  




########################################################################
# Procedure: doLdpRequestFecRange
#
# This command gets LDP request FEC Range
# Arguments(s):
# name : RequestFecRange Name
# Returned Result:
########################################################################      

proc scriptGen::doLdpRequestFecRange {name} \
{
    set retCode 0
      
    generateCommand ldpRequestFecRange
    sgPuts "ldpRouter addRequestFecRange $name"
    return $retCode
}  


########################################################################
# Procedure: doLdpL2VpnInterface
#
# This command gets LDP L2 VPN Interface
# Arguments(s):
# name : ldpL2VpnInterface Name
# Returned Result:
########################################################################      

proc scriptGen::doLdpL2VpnInterface {name} \
{
    set retCode 0
    
    if {![ldpL2VpnInterface getFirstL2VpnVcRange]} {
        set nameIndex 2
        doLdpL2VpnVcRange  l2VpnVcRange1
        while {![ldpL2VpnInterface getNextL2VpnVcRange]} {
            doLdpL2VpnVcRange [format "l2VpnVcRange%i" $nameIndex]
            incr nameIndex
        }
    }

    generateCommand ldpL2VpnInterface
    sgPuts "ldpRouter addL2VpnInterface $name"
    return $retCode
}  

########################################################################
# Procedure: doLdpMulticastLeafRange
#
# This command gets LDP Multicast Leaf Range
# Arguments(s):
# name : ldpMulticastLeafRange Name
# Returned Result:
########################################################################      

proc scriptGen::doLdpMulticastLeafRange {name} \
{
    set retCode 0
    
    if {![ldpMulticastLeafRange getFirstOpaqueValueElement]} {
        set nameIndex 2
        doLdpOpaqueValueElement  opaqueValueElement1
        while {![ldpMulticastLeafRange getNextOpaqueValueElement]} {
            doLdpOpaqueValueElement [format "opaqueValueElement%i" $nameIndex]
            incr nameIndex
        }
    }

    generateCommand ldpMulticastLeafRange
    sgPuts "ldpRouter addMulticastLeafRange $name"
    return $retCode
}  

########################################################################
# Procedure: doLdpOpaqueValueElement
#
# This command gets LDP Opaque Value Element
# Arguments(s):
# name : ldpOpaqueValueElement Name
# Returned Result:
########################################################################      

proc scriptGen::doLdpOpaqueValueElement {name} \
{
    set retCode 0
	  
    generateCommand ldpOpaqueValueElement
    sgPuts "ldpMulticastLeafRange addOpaqueValueElement $name"
    return $retCode
}  


########################################################################
# Procedure: doLdpL2VpnVcRange
#
# This command gets LDP L2 VPN VC Range
# Arguments(s):
# name : ldpL2VpnVcRange Name
# Returned Result:
########################################################################      

proc scriptGen::doLdpL2VpnVcRange {name} \
{
    set retCode 0
    
	if {![ldpL2VpnVcRange getFirstVplsMacRange]} {
        set nameIndex 2
        doLdpL2VplsMacRange  l2VplsMacRange1
        while {![ldpL2VpnVcRange getNextVplsMacRange]} {
            doLdpL2VplsMacRange [format "l2VplsMacRange%i" $nameIndex]
            incr nameIndex
        }
    }
	

	if {![ldpL2VpnVcRange getFirstVcMacVlanRange]} {
        set nameIndex 2
        doLdpL2VpnMacVlanRange  l2VpnMacVlanRange1
        while {![ldpL2VpnVcRange getNextVcMacVlanRange]} {
            doLdpL2VpnMacVlanRange [format "l2VpnMacVlanRange%i" $nameIndex]
            incr nameIndex
        }
    }

	if {![ldpL2VpnVcRange getFirstVcIpRange]} {
        set nameIndex 2
        doLdpL2VpnIpRange  l2VpnIpRange1
        while {![ldpL2VpnVcRange getNextVcIpRange]} {
            doLdpL2VpnIpRange [format "l2VpnIpRange%i" $nameIndex]
            incr nameIndex
        }
    }
	  
    generateCommand ldpL2VpnVcRange
    sgPuts "ldpL2VpnInterface addL2VpnVcRange $name"
    return $retCode
}  


########################################################################
# Procedure: doLdpL2VplsMacRange
#
# This command gets LDP L2 VPLS Mac Ranges
# Arguments(s):
# name : ldpL2VpnVcRange Name
# Returned Result:
########################################################################      

proc scriptGen::doLdpL2VplsMacRange {name} \
{
    set retCode 0
	  
    generateCommand ldpL2VplsMacRange
    sgPuts "ldpL2VpnVcRange addVplsMacRange $name"
    return $retCode
}  


########################################################################
# Procedure: doLdpL2VpnIpRange
#
# This command gets LDP L2 VPN IP Ranges
# Arguments(s):
# name : ldpL2VpnIpRange Name
# Returned Result:
########################################################################      

proc scriptGen::doLdpL2VpnIpRange {name} \
{
    set retCode 0
	  
    generateCommand ldpL2VpnIpRange
    sgPuts "ldpL2VpnVcRange addVcIpRange $name"
    return $retCode
}  

########################################################################
# Procedure: doLdpL2VpnMacVlanRange
#
# This command gets LDP L2 VPN Mac/Vlan Ranges
# Arguments(s):
# name : ldpL2VpnMacVlanRange Name
# Returned Result:
########################################################################      

proc scriptGen::doLdpL2VpnMacVlanRange {name} \
{
    set retCode 0
	  
    generateCommand ldpL2VpnMacVlanRange
    sgPuts "ldpL2VpnVcRange addVcMacVlanRange $name"
    return $retCode
}  

########################################################################
# 
#       ------------  MLD procedures  ------------
#
########################################################################

########################################################################
# Procedure: getMld
#
# This command generats Mld server commands
#
# Arguments(s):
#   chassis :       chassis Id
#   card    :       card Id
#   port    :       port Id
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::getMld {chassis card port} \
{
    set retCode 0
    set nameIndex 2

    if {![mldServer select $chassis $card $port]} {
        sgPuts {mldServer select $chassis $card $port}
        sgPuts "mldServer clearAllHosts"
        
        if {![mldServer getFirstHost]} {
            doMldHost host1
            while {![mldServer getNextHost]} {
                doMldHost [format "host%i" $nameIndex]
                incr nameIndex
            }
        }
        sgPuts "mldServer clearAllQueriers"
        set nameIndex 2
        if {![mldServer getFirstQuerier]} {
            doMldQuerier querier1
            while {![mldServer getNextQuerier]} {
                doMldQuerier [format "querier%i" $nameIndex]
                incr nameIndex
            }
        }
    } 

    if {![mldServer get]} {
        generateCommand mldServer
        sgPuts "mldServer set"
        sgPuts ""
    }    

    return $retCode
}

########################################################################
# Procedure: doMldQuerier
#
# This command gets Mld Querier
#
# Arguments(s):
#
#   name :          Mld Querier name
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::doMldQuerier {name} \
{
    set retCode 0
            
    generateCommand mldQuerier
    sgPuts "mldServer addQuerier $name"
    sgPuts ""


    return $retCode
}


########################################################################
# Procedure: doMldHost
#
# This command gets Mld host
#
# Arguments(s):
#
#   name :          MLD host name
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::doMldHost {name} \
{
    set retCode 0
            
    if {![mldHost getFirstGroupRange]} {
        set nameIndex 2
        doMldGroupRange groupRange1
        while {![mldHost   getNextGroupRange]} {
            doMldGroupRange [format "groupRange%i" $nameIndex]
            incr nameIndex
        }
    }         

    generateCommand mldHost
    sgPuts "mldServer addHost $name"
    sgPuts ""


    return $retCode
} 

########################################################################
# Procedure: doMldGroupRange
#
# This command gets MLD Group range.
#
# Arguments(s):
#
#   name :          MLD Group range name
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::doMldGroupRange {name} \
{
    set retCode 0

    if {![mldGroupRange getFirstSourceRange]} {
        set nameIndex 2
        doMldSourceRange sourceRange1
        while {![mldGroupRange  getNextSourceRange]} {
            doMldSourceRange [format "sourceRange%i" $nameIndex]
            incr nameIndex
        }
    } 
        
    generateCommand mldGroupRange
    sgPuts "mldHost addGroupRange $name"
    sgPuts ""


    return $retCode
}

########################################################################
# Procedure: doMldSourceRange
#
# This command gets MLD source range
#
# Arguments(s):
#
#   name :         MLD source range name
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doMldSourceRange {name} \
{
    set retCode 0

    generateCommand mldSourceRange
    sgPuts "mldGroupRange addSourceRange $name"
	sgPuts ""
    return $retCode
}

########################################################################
# 
#       ------------  IGMP procedures  ------------
#
########################################################################


########################################################################
# Procedure: getIgmpProtocol
#
# This command gets igmp protocol parameters.
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
########################################################################

proc scriptGen::getIgmpProtocol { chassis card port} \
{
    set retCode 0

    getCommand igmpServer $chassis $card $port
    sgPuts {igmpServer set $chassis $card $port}

    sgPuts "igmpAddressTable clear"

    if {![igmpAddressTable getFirstItem]} {
        getProtocolTableItem igmpAddressTableItem  
        sgPuts "igmpAddressTable addItem"
        while {![igmpAddressTable getNextItem]} {
            getProtocolTableItem igmpAddressTableItem   
            sgPuts "igmpAddressTable addItem"      
        }
    }      
    sgPuts {igmpAddressTable set $chassis $card $port}

    return $retCode 
}

########################################################################
# Procedure: getIgmpVx
#
# This command generats Igmp server commands fo CPU ports.
#
# Arguments(s):
#   chassis :       chassis Id
#   card    :       card Id
#   port    :       port Id
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::getIgmpVx {chassis card port} \
{
    set retCode 0
    set nameIndex 2

    if {![igmpVxServer select $chassis $card $port]} {
        sgPuts {igmpVxServer select $chassis $card $port}
        sgPuts "igmpVxServer clearAllHosts"
        sgPuts "igmpVxServer clearAllQueriers"
        
        if {![igmpVxServer getFirstHost]} {
            doIgmpHost host1
            while {![igmpVxServer getNextHost]} {
                doIgmpHost [format "host%i" $nameIndex]
                incr nameIndex
            }
        }
        set nameIndex 2
        if {![igmpVxServer getFirstQuerier]} {
            doIgmpQuerier querier1
            while {![igmpVxServer getNextQuerier]} {
                doIgmpQuerier [format "querier%i" $nameIndex]
                incr nameIndex
            }
        }
    } 

    if {![igmpVxServer get]} {
        generateCommand igmpVxServer
        sgPuts "igmpVxServer set"
        sgPuts ""
    }       
    return $retCode
}

########################################################################
# Procedure: doIgmpQuerier
#
# This command gets Igmp Querier
#
# Arguments(s):
#
#   name :          Igmp Querier name
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::doIgmpQuerier {name} \
{
    set retCode 0
            
    generateCommand igmpQuerier
    sgPuts "igmpVxServer addQuerier $name"
    sgPuts ""


    return $retCode
}

########################################################################
# Procedure: doIgmpHost
#
# This command gets Igmp host
#
# Arguments(s):
#
#   name :          Igmp host name
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::doIgmpHost {name} \
{
    set retCode 0
            
    if {![igmpHost getFirstGroupRange]} {
        set nameIndex 2
        doIgmpGroupRange groupRange1
        while {![igmpHost   getNextGroupRange]} {
            doIgmpGroupRange [format "groupRange%i" $nameIndex]
            incr nameIndex
        }
    }         

    generateCommand igmpHost
    sgPuts "igmpVxServer addHost $name"
    sgPuts ""


    return $retCode
} 

########################################################################
# Procedure: doIgmpGroupRange
#
# This command gets Igmp Group range.
#
# Arguments(s):
#
#   name :          Igmp Group range name
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::doIgmpGroupRange {name} \
{
    set retCode 0

    if {![igmpGroupRange getFirstSourceRange]} {
        set nameIndex 2
        doIgmpSourceRange sourceRange1
        while {![igmpGroupRange  getNextSourceRange]} {
            doIgmpSourceRange [format "sourceRange%i" $nameIndex]
            incr nameIndex
        }
    } 
        
    generateCommand igmpGroupRange
    sgPuts "igmpHost addGroupRange $name"
    sgPuts ""


    return $retCode
}

########################################################################
# Procedure: doIgmpSourceRange
#
# This command gets Igmp source range
#
# Arguments(s):
#
#   name :         Igmp source range name
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doIgmpSourceRange {name} \
{
    set retCode 0

    generateCommand igmpSourceRange
    sgPuts "igmpGroupRange addSourceRange $name"
	sgPuts ""
    return $retCode
}

########################################################################
# 
#       ------------  OSPFV3 procedures  ------------
#
########################################################################

########################################################################
# Procedure: getOspfV3
#
# This command generats OspfV3 server commands
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
#
########################################################################

proc scriptGen::getOspfV3 {chassis card port} \
{
    set retCode 0
    set nameIndex 2
    if {![ospfV3Server select $chassis $card $port]} {
        sgPuts {ospfV3Server select $chassis $card $port}
        sgPuts "ospfV3Server clearAllRouters"
        
        if {![ospfV3Server getFirstRouter]} {
            doOspfV3Router router1
            while {![ospfV3Server getNextRouter]} {
                doOspfV3Router [format "router%i" $nameIndex]
                incr nameIndex
            }
        }
    }
	if {![ospfV3Server get]} {
       generateCommand ospfV3Server
       sgPuts "ospfV3Server set"
       sgPuts ""
    }
    return $retCode
}


########################################################################
# Procedure: doOspfV3Router
#
# This command gets OSPFV3 router
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################

proc scriptGen::doOspfV3Router {name} \
{
    set retCode 0
    
    if {![ospfV3Router getFirstInterface]} {
        set nameIndex 2
        doOspfV3Interface interface1
        while {![ospfV3Router  getNextInterface]} {
            doOspfV3Interface [format "interface%i" $nameIndex]
            incr nameIndex
        }
    }               
    if {![ospfV3Router getFirstRouteRange]} {
        set nameIndex 2
        doOspfV3RouteRange routeRange1
        while {![ospfV3Router  getNextRouteRange]} {
            doOspfV3RouteRange [format "routeRange%i" $nameIndex]
            incr nameIndex
        }
    }            
    if {![ospfV3Router getFirstUserLsaGroup]} {
        set nameIndex 2
        doOspfV3UserLsaGroup userLsaGroup1
        while {![ospfV3Router  getNextUserLsaGroup]} {
            doOspfV3UserLsaGroup [format "userLsaGroup%i" $nameIndex]
            incr nameIndex
        }
    }
    # SDM-AUTOGEN-TCL-DEFN-CHILDOBJ-SCRIPTGEN: OBJ=/vport/protocols/ospfV3/router
	if {![ospfV3Router getFirstNetworkRange]} {
        set nameIndex 2
        doOspfV3NetworkRange networkRange1
        while {![ospfV3Router  getNextNetworkRange]} {
            doOspfV3NetworkRange [format "networkRange%i" $nameIndex]
            incr nameIndex
        }
    }     

    generateCommand ospfV3Router
    sgPuts "ospfV3Server addRouter $name"
    sgPuts ""
    return $retCode
}  

########################################################################
# Procedure: doOspfV3Interface
#
# This command gets OSPFV3 Interface
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doOspfV3Interface {name} \
{
    set retCode 0
    # SDM-AUTOGEN-TCL-DEFN-CHILDOBJ-SCRIPTGEN: OBJ=/vport/protocols/ospfV3/router/interface

    generateCommand ospfV3Interface 
    sgPuts "ospfV3Router addInterface $name"
    return $retCode
}  


########################################################################
# Procedure: doOspfV3RouteRange
#
# This command gets OSPFV3 route range
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doOspfV3RouteRange {name} \
{
    set retCode 0
    generateCommand ospfV3RouteRange
    sgPuts "ospfV3Router addRouteRange $name"
    return $retCode
}  

########################################################################
# Procedure: doOspfV3NetworkRange
#
# This command gets OSPFV3 Network Range
# Arguments(s):
# name : NetworkRangeName
# Returned Result:
########################################################################      

proc scriptGen::doOspfV3NetworkRange {name} \
{
    set retCode 0

    generateCommand ospfV3NetworkRange 
    sgPuts "ospfV3Router addNetworkRange $name"
    return $retCode
}  


########################################################################
# Procedure: doOspfV3UserLsaGroup
#
# This command gets OSPF userLsa group
# Arguments(s):
# name : RouterName
# Returned Result:
########################################################################      

proc scriptGen::doOspfV3UserLsaGroup {name} \
{
    set retCode 0
    set nameIndex 2

    set lsaObject [ospfV3UserLsaGroup getFirstUserLsa]
	if {$lsaObject != "NULL" } {
		set lsaType [$lsaObject cget -type]
		doOspfV3UserLsa userLsa1 $lsaType

		set lsaObject [ospfV3UserLsaGroup getNextUserLsa]

        while {$lsaObject != "NULL"} {
			set lsaType [$lsaObject cget -type]
            doOspfV3UserLsa [format "userLsa%i" $nameIndex] $lsaType
			set lsaObject [ospfV3UserLsaGroup getNextUserLsa]
            incr nameIndex
        }
    }
            
    generateCommand ospfV3UserLsaGroup
    sgPuts "ospfV3Router addUserLsaGroup $name"
    return $retCode
}


########################################################################
# Procedure: doOspfV3UserLsa
#
# This command gets OSPFV3 userLsa 
# Arguments(s):
# name : RouterName
# lsaType: lsa type.
# Returned Result:
########################################################################      

proc scriptGen::doOspfV3UserLsa {name  lsaType} \
{  
    set retCode 0
	set lsaTypeString "ospfV3LsaRouter"
    switch $lsaType \
        $::ospfV3LsaRouter { \
			doOspfV3LsaRouterInterface
            generateCommand  ospfV3LsaRouter 
			set lsaTypeString "ospfV3LsaRouter" \
		} \
        $::ospfV3LsaNetwork { \
            generateCommand ospfV3LsaNetwork 
			set lsaTypeString "ospfV3LsaNetwork" \
        }\
        $::ospfV3LsaInterAreaPrefix { \
            generateCommand ospfV3LsaInterAreaPrefix 
			set lsaTypeString "ospfV3LsaInterAreaPrefix" 
        } \
        $::ospfV3LsaInterAreaRouter { \
            generateCommand ospfV3LsaInterAreaRouter 
			set lsaTypeString "ospfV3LsaInterAreaRouter" \
        } \
        $::ospfV3LsaAsExternal { \
            generateCommand ospfV3LsaAsExternal 
			set lsaTypeString "ospfV3LsaAsExternal" \
        } \
		$::ospfV3LsaLink { \
			doOspfV3Prefix ospfV3LsaLink
            generateCommand ospfV3LsaLink 
			set lsaTypeString "ospfV3LsaLink"  \
        } \
		$::ospfV3LsaIntraAreaPrefix { \
			doOspfV3Prefix ospfV3LsaIntraAreaPrefix
            generateCommand ospfV3LsaIntraAreaPrefix 
			set lsaTypeString "ospfV3LsaIntraAreaPrefix" \
        } \

    sgPuts "ospfV3UserLsaGroup addUserLsa $name $lsaTypeString" 
	
	switch $lsaType \
        $::ospfV3LsaRouter { \
			sgPuts "ospfV3LsaRouter clearAllInterfaces" \
        } \
		$::ospfV3LsaLink { \
			sgPuts "ospfV3LsaLink clearPrefixList" \
        } \
		$::ospfV3LsaIntraAreaPrefix { \
			sgPuts "ospfV3LsaIntraAreaPrefix clearPrefixList" \
        } \
	
	sgPuts "" 
    
    return $retCode
}

########################################################################
# Procedure: doOspfV3LsaRouterInterface
#
# This command gets OSPFV3 Router LSA Interface 
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doOspfV3LsaRouterInterface {} \
{  
	if {![ospfV3LsaRouter getFirstInterface]} {
        generateCommand ospfV3LsaRouterInterface
		sgPuts "ospfV3LsaRouter addInterface" 
        while {![ospfV3LsaRouter getNextInterface]} {
            generateCommand ospfV3LsaRouterInterface
			sgPuts "ospfV3LsaRouter addInterface"
        }
    } 
}  


########################################################################
# Procedure: doOspfV3Prefix
#
# This command gets OSPFV3 prefix
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doOspfV3Prefix {cmd} \
{  
	if {![$cmd getFirstPrefix]} {
        generateCommand ospfV3IpV6Prefix
		sgPuts "$cmd addPrefix" 
        while {![$cmd getNextPrefix]} {
            generateCommand ospfV3IpV6Prefix
			sgPuts "$cmd addPrefix"
        }
    } 
} 


########################################################################
# Procedure: doOspfV3Options
#
# This command gets the enum for ospfV3 options.
# Arguments(s):
# value : The value of options
# Returned Result: Text for options ( [expr x|y]) 
########################################################################
    
proc scriptGen::doOspfV3Options {value enumValList} \
{
    variable enumsArray
    set retCode 0 
    set modes {}
	set enumText 0
	set itemIndex 0
 
    set joinedList  [join $enumValList]
    for {set i 1} {$i < 0xFF} {set i [expr $i << 1]} {

        if {[expr $value & $i]} {
			set enumValue [expr $value & $i]         
			set index       [lsearch $joinedList $enumValue]		
			if { $index != -1 } {
				if { $itemIndex > 0 } {
					lappend modes "|"
				}
                lappend modes {$::}
				lappend modes   [lindex $joinedList [expr $index-1]]
				incr itemIndex
			} 
        }
	}
	if {[string length $modes] != 0} {
		set enumText [format "%cexpr %s%c" 91 [removeSpaces [join $modes]] 93]
	}
	return $enumText
  
} 
# SDM-AUTOGEN-TCL-DEFN-OBJ-SCRIPTGEN: OBJ=/vport/protocols/ospfV3

########################################################################
# 
#       ------------  PIM-SM procedures  ------------
#
########################################################################

########################################################################
# Procedure: getPimsm
#
# This command generats PIM SM server commands fo CPU ports.
#
# Arguments(s):
#   chassis :       chassis Id
#   card    :       card Id
#   port    :       port Id
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::getPimsm {chassis card port} \
{
    set retCode 0
    set nameIndex 2

    if {![pimsmServer select $chassis $card $port]} {
        sgPuts {pimsmServer select $chassis $card $port}
        sgPuts "pimsmServer clearAllRouters"
        
        if {![pimsmServer getFirstRouter]} {
            doPimsmRouter router1
            while {![pimsmServer getNextRouter]} {
                doPimsmRouter [format "router%i" $nameIndex]
                incr nameIndex
            }
        }
    } 

  	if {![pimsmServer get]} {
  		generateCommand pimsmServer
  		sgPuts "pimsmServer set"
  		sgPuts ""
  	}
    return $retCode
}

########################################################################
# Procedure: doPimsmRouter
#
# This command gets PIM-SM router
#
# Arguments(s):
#
#   name :          PIM-SM router name
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::doPimsmRouter {name} \
{
    set retCode 0
            
    if {![pimsmRouter getFirstInterface]} {
        set nameIndex 2
        doPimsmInterface interface1
        while {![pimsmRouter   getNextInterface]} {
            doPimsmInterface [format "interface%i" $nameIndex]
            incr nameIndex
        }
    }         

    generateCommand pimsmRouter
    sgPuts "pimsmServer addRouter $name"
    sgPuts ""


    return $retCode
} 

########################################################################
# Procedure: doPimsmInterface
#
# This command gets PIM-SM interface.
#
# Arguments(s):
#
#   name :          PIM-SM interface name
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::doPimsmInterface {name} \
{
    set retCode 0

    if {![pimsmInterface getFirstJoinPrune]} {
        set nameIndex 2
        doPimsmJoinPrune joinPrune1
        while {![pimsmInterface  getNextJoinPrune]} {
            doPimsmJoinPrune [format "joinPrune%i" $nameIndex]
            incr nameIndex
        }
    } 
        
	if {![pimsmInterface getFirstSource]} {
        set nameIndex 2
        doPimsmSource source1
        while {![pimsmInterface  getNextSource]} {
            doPimsmSource [format "source%i" $nameIndex]
            incr nameIndex
        }
    } 
	
	if {![pimsmInterface getFirstDataMdtRange]} {
		set nameIndex 2
		doPimsmDataMdtRange dataMdtRange1
		while {![pimsmInterface getNextDataMdtRange]} {
			doPimsmDataMdtRange [format "dataMdtRange%i" $nameIndex]
			incr nameIndex
		}
	}

	if {![pimsmInterface getFirstCRPRange]} {
		set nameIndex 2
		doPimsmCRPRange cRPRange1
		while {![pimsmInterface getNextCRPRange]} {
			doPimsmCRPRange [format "cRPRange%i" $nameIndex]
			incr nameIndex
		}
	}

    generateCommand pimsmInterface
    sgPuts "pimsmRouter addInterface $name"
    sgPuts ""


    return $retCode
}

########################################################################
# Procedure: doPimsmJoinPrune
#
# This command gets PIM-SM Multicast range
#
# Arguments(s):
#
#   name :         IPIM-SM Multicast range name
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doPimsmJoinPrune {name} \
{
    set retCode 0

    generateCommand pimsmJoinPrune
    sgPuts "pimsmInterface addJoinPrune $name"
	sgPuts ""
    return $retCode
}



########################################################################
# Procedure: doPimsmSource
#
# This command gets PIM-SM register range.
#
# Arguments(s):
#
#   name :         PIM-SM register range name
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doPimsmSource {name} \
{
    set retCode 0

    generateCommand pimsmSource
    sgPuts "pimsmInterface addSource $name"
	sgPuts ""
    return $retCode
}


########################################################################
# Procedure: doPimsmDataMdtRange
#
# This command gets PIM-SM DataMdt range
#
# Arguments(s):
#
#   name :         IPIM-SM DataMdt range name
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doPimsmDataMdtRange {name} \
{
    set retCode 0

    generateCommand pimsmDataMdtRange
    sgPuts "pimsmInterface addDataMdtRange $name"
	sgPuts ""
    return $retCode
}



########################################################################
# Procedure: doPimsmCRPRange
#
# This command gets PIM-SM CRP range
#
# Arguments(s):
#
#   name :         IPIM-SM CRP range name
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doPimsmCRPRange {name} \
{
    set retCode 0

    generateCommand pimsmCRPRange
    sgPuts "pimsmInterface addCRPRange $name"
	sgPuts ""
    return $retCode
}



########################################################################
# 
#       ------------  STP procedures  ------------
#
########################################################################

########################################################################
# Procedure: getStp
#
# This command generats STP server commands fo CPU ports.
#
# Arguments(s):
#   chassis :       chassis Id
#   card    :       card Id
#   port    :       port Id
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::getStp {chassis card port} \
{
    set retCode 0

    if {![stpServer select $chassis $card $port]} {
        sgPuts {stpServer select $chassis $card $port}
        sgPuts "stpServer clearAllBridges"
        sgPuts "stpServer clearAllLans"
        
        if {![stpServer getFirstLan]} {
            doStpLan 
            while {![stpServer getNextLan]} {
                doStpLan 
            }
        }
        
        if {![stpServer getFirstBridge]} {
            doStpBridge 
            while {![stpServer getNextBridge]} {
                doStpBridge 
            }
        }
	
    } 
    return $retCode
}

########################################################################
# Procedure: doStpBridge
#
# This command gets STP Bridge
#
# Arguments(s):
#
#
#   Results :        Always returns 0
#       
########################################################################
proc scriptGen::doStpBridge {} \
{
    set retCode 0
            
    if {![stpBridge getFirstInterface]} {
          doStpInterface 
        while {![stpBridge   getNextInterface]} {
            doStpInterface 
        }
    }   


	if {![stpBridge getFirstMsti]} {
           doStpMsti 
        while {![stpBridge   getNextMsti]} {
           doStpMsti 
        }
    }              
	
	if {![stpBridge getFirstVlan]} {
           doStpVlan 
        while {![stpBridge   getNextVlan]} {
           doStpVlan 
        }
    } 
	 

    generateCommand stpBridge
    sgPuts "stpServer addBridge [stpBridge cget -name]"
    sgPuts ""


    return $retCode
} 

########################################################################
# Procedure: doStpInterface
#
# This command gets STP interface.
#
# Arguments(s):
#
# name : StpBridgeInterfaceName
# Results :        Always returns 0
#       
########################################################################
proc scriptGen::doStpInterface {} \
{
    set retCode 0
    generateCommand stpInterface
    sgPuts "stpBridge addInterface [stpInterface cget -name]"
    sgPuts ""


    return $retCode
}

########################################################################
# Procedure: doStpLan
#
# This command gets STP Global LANs
#
# Arguments(s):
#
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doStpLan {} \
{
    set retCode 0

    generateCommand stpLan
    sgPuts "stpServer addLan [stpLan cget -name]"
	sgPuts ""
    return $retCode
}
########################################################################
# Procedure: doStpMsti
#
# This command gets STP Global MSTIs
#
# Arguments(s):
#
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doStpMsti {} \
{
    set retCode 0

	if {![stpMsti getFirstVlanRange]} {
        doStpMstiVlan 
        while {![stpMsti getNextVlanRange]} {
           doStpMstiVlan 
        }
    }    

    generateCommand stpMsti
    sgPuts "stpBridge addMsti [stpMsti cget -name]"
    sgPuts ""
    
    return $retCode
}

########################################################################
# Procedure: doStpMstiVlan
#
# This command gets STP Global MSTI VLANs
#
# Arguments(s):
#
# Results :      Always returns 0
#       
########################################################################
proc scriptGen::doStpMstiVlan {} \
{
    set retCode 0
    generateCommand stpMstiVlan
    sgPuts "stpMsti addVlanRange [stpMstiVlan cget -name]"
    sgPuts ""
    
    return $retCode
}

########################################################################
# Procedure: doStpVlan
#
# This command gets STP Global VLANs
#
# Arguments(s):
#
#
#   Results :      Always returns 0
#       
########################################################################
proc scriptGen::doStpVlan {} \
{
    set retCode 0
    generateCommand stpVlan
    sgPuts "stpBridge addVlan [stpVlan cget -name]"
    sgPuts ""
    
    return $retCode
}

########################################################################
# 
#       ------------  EIGRP procedures  ------------
#
########################################################################

########################################################################
# Procedure: getEigrp
#
# This command generats Eigrp server commands
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
#
########################################################################

proc scriptGen::getEigrp {chassis card port} \
{
    set retCode 0

    if {![eigrpServer select $chassis $card $port]} {
        sgPuts {eigrpServer select $chassis $card $port}
        sgPuts "eigrpServer clearAllRouters"
        
        if {![eigrpServer getFirstRouter]} {
            doEigrpRouter 
            while {![eigrpServer getNextRouter]} {
                doEigrpRouter 
            }
        }
	}

    return $retCode
}


########################################################################
# Procedure: doEigrpRouter
#
# This command gets EIGRP router
# Arguments(s):
# Returned Result:
########################################################################

proc scriptGen::doEigrpRouter {} \
{
    set retCode 0
    
    if {![eigrpRouter getFirstInterface]} {
        doEigrpInterface 
    }               
    if {![eigrpRouter getFirstRouteRange]} {
        doEigrpRouteRange 
        while {![eigrpRouter  getNextRouteRange]} {
            doEigrpRouteRange 
        }
    }            
    
    generateCommand eigrpRouter
    sgPuts "eigrpServer addRouter [eigrpRouter cget -name]"
    sgPuts ""

    return $retCode
}  

########################################################################
# Procedure: doEigrpInterface
#
# This command gets EIGRP Interface
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doEigrpInterface {} \
{
    set retCode 0

    generateCommand eigrpInterface 
    sgPuts "eigrpRouter addInterface [eigrpInterface cget -name]"
	sgPuts ""

    return $retCode
}  


########################################################################
# Procedure: doEigrpRouteRange
#
# This command gets Eigrp route range
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doEigrpRouteRange {} \
{
    set retCode 0

    generateCommand eigrpRouteRange
    sgPuts "eigrpRouter addRouteRange [eigrpRouteRange cget -name]"
	sgPuts ""

    return $retCode
}  

########################################################################
# 
#       ------------  BFD procedures  ------------
#
########################################################################

########################################################################
# Procedure: getBfd
#
# This command generats Bfd server commands
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
#
########################################################################

proc scriptGen::getBfd {chassis card port} \
{
    set retCode 0

    if {![bfdServer select $chassis $card $port]} {
        sgPuts {bfdServer select $chassis $card $port}
        sgPuts "bfdServer clearAllRouters"
        
        if {![bfdServer getFirstRouter]} {
            doBfdRouter 
            while {![bfdServer getNextRouter]} {
                doBfdRouter 
            }
        }
	}

    return $retCode
}

########################################################################
# Procedure: doBfdRouter
#
# This command gets BFD router
# Arguments(s):
# Returned Result:
########################################################################

proc scriptGen::doBfdRouter {} \
{
    set retCode 0
                 
    if {![bfdRouter getFirstInterface]} {
        doBfdInterface 
        while {![bfdRouter  getNextInterface]} {
            doBfdInterface 
        }
    }            
    
    generateCommand bfdRouter
    sgPuts "bfdServer addRouter [bfdRouter cget -name]"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doBfdInterface
#
# This command gets BFD Interface
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doBfdInterface {} \
{
    set retCode 0

    if {![bfdInterface getFirstSession]} {
        doBfdSession 
        while {![bfdInterface  getNextSession]} {
            doBfdSession 
        }
    }     

	generateCommand bfdInterface 
    sgPuts "bfdRouter addInterface [bfdInterface cget -name]"
	sgPuts ""

    return $retCode
}    

########################################################################
# Procedure: doBfdSession
#
# This command gets Bfd Session
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doBfdSession {} \
{
    set retCode 0

    generateCommand bfdSession
    sgPuts "bfdInterface addSession [bfdSession cget -name]"
	sgPuts ""

    return $retCode
}

########################################################################
# 
#       ------------  CFM procedures  ------------
#
########################################################################

########################################################################
# Procedure: getCfm
#
# This command generats Cfm server commands
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
#
########################################################################

proc scriptGen::getCfm {chassis card port} \
{
    set retCode 0

    if {![cfmServer select $chassis $card $port]} {
        sgPuts {cfmServer select $chassis $card $port}
        sgPuts "cfmServer clearAllBridges"

        if {![cfmServer getFirstBridge]} {
            doCfmBridge 
            while {![cfmServer getNextBridge]} {
                doCfmBridge 
            }
        }
	}

	if {![cfmServer get]} {
        generateCommand cfmServer
        sgPuts "cfmServer set"
        sgPuts ""
    }

    return $retCode
}

########################################################################
# Procedure: doCfmBridge
#
# This command gets CFM bridge
# Arguments(s):
# Returned Result:
########################################################################

proc scriptGen::doCfmBridge {} \
{
    set retCode 0
                 
    if {![cfmBridge getFirstInterface]} {
        doCfmInterface 
        while {![cfmBridge  getNextInterface]} {
            doCfmInterface 
        }
    }
    if {![cfmBridge getFirstMdLevel]} {
        doCfmMdLevel
        while {![cfmBridge  getNextMdLevel]} {
            doCfmMdLevel
        }
    }

    if {![cfmBridge getFirstVlan]} {
        doCfmVlan
        while {![cfmBridge  getNextVlan]} {
            doCfmVlan
        }
    }

    if {![cfmBridge getFirstMp]} {
        doCfmMp
        while {![cfmBridge  getNextMp]} {
            doCfmMp 
        }
    }

	if {![cfmBridge getFirstTrunk]} {
        doCfmTrunk
        while {![cfmBridge  getNextTrunk]} {
            doCfmTrunk 
        }
    }

    if {![cfmBridge getFirstLink]} {
        doCfmLink
        while {![cfmBridge  getNextLink]} {
            doCfmLink
        }
    }

	if {![cfmBridge getFirstCustomTlv]} {
        doCfmCustomTlv
        while {![cfmBridge  getNextCustomTlv]} {
            doCfmCustomTlv
        }
    }

    generateCommand cfmBridge
    sgPuts "cfmServer addBridge [cfmBridge cget -name]"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doCfmInterface
#
# This command gets CFM Interface
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doCfmInterface {} \
{
    set retCode 0

    generateCommand cfmInterface 
    sgPuts "cfmBridge addInterface [cfmInterface cget -name]"
    sgPuts ""

    return $retCode
}    

########################################################################
# Procedure: doCfmMP
#
# This command gets CFM MP
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doCfmMp {} \
{
    set retCode 0

    generateCommand cfmMp
    sgPuts "cfmBridge addMp [cfmMp cget -name]"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doCfmTrunk
#
# This command gets CFM Trunk
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doCfmTrunk {} \
{
    set retCode 0

    generateCommand cfmTrunk
    sgPuts "cfmBridge addTrunk [cfmTrunk cget -name]"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doCfmLink
#
# This command gets CFM Link
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doCfmLink {} \
{
    set retCode 0

    generateCommand cfmLink
    sgPuts "cfmBridge addLink [cfmLink cget -name]"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doCfmMdLevel
#
# This command gets CFM MdLevel
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doCfmMdLevel {} \
{
    set retCode 0

    generateCommand cfmMdLevel
    sgPuts "cfmBridge addMdLevel [cfmMdLevel cget -name]"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doCfmVlan
#
# This command gets CFM Vlan
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doCfmVlan {} \
{
    set retCode 0

    generateCommand cfmVlan
    sgPuts "cfmBridge addVlan [cfmVlan cget -name]"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doCfmCustomTlv
#
# This command gets CFM CustomTlv
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doCfmCustomTlv {} \
{
    set retCode 0

    generateCommand cfmCustomTlv
    sgPuts "cfmBridge addCustomTlv [cfmCustomTlv cget -name]"
    sgPuts ""

    return $retCode
}

########################################################################
# 
#       ------------  LACP procedures  ------------
#
########################################################################

########################################################################
# Procedure: getLacp
#
# This command generats Lacp server commands
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
#
########################################################################

proc scriptGen::getLacp {chassis card port} \
{
    set retCode 0

    if {![lacpServer select $chassis $card $port]} {
        sgPuts {lacpServer select $chassis $card $port}
        sgPuts "lacpServer clearAllLinks"

        if {![lacpServer getFirstLink]} {
            doLacpLink 
            while {![lacpServer getNextLink]} {
                doLacpLink 
            }
        }
	}
	
	if {![lacpServer get]} {
        generateCommand lacpServer
        sgPuts "lacpServer set"
        sgPuts ""
    }

    return $retCode
}

########################################################################
# Procedure: doLacpLink
#
# This command gets LACP link
# Arguments(s):
# Returned Result:
########################################################################

proc scriptGen::doLacpLink {} \
{
	set retCode 0

	generateCommand lacpLink
    sgPuts "lacpServer addLink [lacpLink cget -name]"
    sgPuts ""

    return $retCode
}


########################################################################
# 
#       ------------  linkOAM procedures  ------------
#
########################################################################

########################################################################
# Procedure: getLinkOam
#
# This command generates Oam server commands
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
#
########################################################################

proc scriptGen::getLinkOam {chassis card port} \
{
    set retCode 0

    if {![linkOamServer select $chassis $card $port]} {
        sgPuts {linkOamServer select $chassis $card $port}        

        if {![linkOamServer getLink]} {
            dolinkOamLink 
        }
	}

	if {![linkOamServer get]} {
        generateCommand linkOamServer
        sgPuts "linkOamServer set"
        sgPuts ""
    }

    return $retCode
}

########################################################################
# Procedure: dolinkOamLink
#
# This command gets LinkOAM Link
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::dolinkOamLink {} \
{
    set retCode 0
        
    if {![linkOamLink getFirstInterface]} {
		doOamInterface
        while {![linkOamLink getNextInterface]} {
			doOamInterface 
        }		
	}
    
    if {![linkOamLink getErroredSymbolPeriodEventTlv]} {
		generateCommand linkOamSymTlv
		sgPuts "linkOamLink setErroredSymbolPeriodEventTlv"
		sgPuts ""
	}

	if {![linkOamLink getErroredFrameEventTlv]} {
		generateCommand linkOamFrameTlv
		sgPuts "linkOamLink setErroredFrameEventTlv"
		sgPuts ""
    }
    
    if {![linkOamLink getErroredFramePeriodEventTlv]} {
		generateCommand linkOamPeriodTlv
		sgPuts "linkOamLink setErroredFramePeriodEventTlv"
		sgPuts ""
	}
    
    if {![linkOamLink getErroredFrameSSEventTlv]} {
		generateCommand linkOamSSTlv
		sgPuts "linkOamLink setErroredFrameSSEventTlv"
		sgPuts ""
	}
    
    if {![linkOamLink getOrgSpecEventTlv]} {
		generateCommand linkOamOrgEventTlv
		sgPuts "linkOamLink setOrgSpecEventTlv"
		sgPuts ""
    }
    
    if {![linkOamLink getFirstOrgSpecInfoTlv]} {
            doOrgSpecInfoTlv
            while {![linkOamLink  getNextOrgSpecInfoTlv]} {
                doOrgSpecInfoTlv 
            }
    }
    
    if {![linkOamLink getFirstVariableResponseDbContainer]} {
	    doVariableResponseDbContainer
	    while {![linkOamLink  getNextVariableResponseDbContainer]} {
		doVariableResponseDbContainer 
	    }
    }

	if {![linkOamLink getFirstOrgSpecTlv]} {
		doOrgSpecTlv
        while {![linkOamLink getNextOrgSpecTlv]} {
			doOrgSpecTlv 
        }		
	}
	
    generateCommand linkOamLink
    sgPuts "linkOamServer addLink [linkOamLink cget -name]"
    sgPuts ""
    
    return $retCode
}


########################################################################
# Procedure: doOrgSpecInfoTlv
#
# This command gets LinkOAM Org Spec Information TLV
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doOrgSpecInfoTlv {} \
{
    set retCode 0
	
    generateCommand linkOamOrgInfoTlv
    sgPuts "linkOamLink addOrgSpecInfoTlv [linkOamOrgInfoTlv cget -name]"
    sgPuts ""

    return $retCode
}


########################################################################
# Procedure: doVariableResponseDbContainer
#
# This command gets LinkOAM Variable Response Container
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doVariableResponseDbContainer {} \
{
    set retCode 0
	
    generateCommand linkOamVarContainer
    sgPuts "linkOamLink addVariableResponseDbContainer [linkOamVarContainer cget -name]"
    sgPuts ""

    return $retCode
}


########################################################################
# Procedure: doOrgSpecTlv
#
# This command gets LinkOAM Org Spec TLV
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doOrgSpecTlv {} \
{
    set retCode 0
	
    generateCommand linkOamOrgTlv
    sgPuts "linkOamLink addOrgSpecTlv [linkOamOrgTlv cget -name]"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doOamInterface
#
# This command gets OAM Interface
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doOamInterface {} \
{
    set retCode 0

    generateCommand linkOamInterface 
    sgPuts "linkOamLink addInterface [linkOamInterface cget -name]"
    sgPuts ""

    return $retCode
}

########################################################################
# 
#       ------------  MPLSTP procedures  ------------
#
########################################################################

########################################################################
# Procedure: getMplsTp
#
# This command generats MplsTp server commands
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
#
########################################################################

proc scriptGen::getMplsTp {chassis card port} \
{
    set retCode 0

    if {![mplsTpServer select $chassis $card $port]} {
        sgPuts {mplsTpServer select $chassis $card $port}
        sgPuts "mplsTpServer clearAllRouters"
        
        if {![mplsTpServer getFirstRouter]} {
            doMplsTpRouter 
            while {![mplsTpServer getNextRouter]} {
                doMplsTpRouter 
            }
        }
	}
	if {![mplsTpServer get]} {
        generateCommand mplsTpServer
        sgPuts "mplsTpServer set"
        sgPuts ""
        sgPuts "mplsTpServer write"
        sgPuts ""
    }

    return $retCode
}

########################################################################
# Procedure: doMplsTpRouter
#
# This command gets MplsTp router
# Arguments(s):
# Returned Result:
########################################################################

proc scriptGen::doMplsTpRouter {} \
{
    set retCode 0
                 
    if {![mplsTpRouter getFirstInterface]} {
        doMplsTpInterface 
        while {![mplsTpRouter  getNextInterface]} {
            doMplsTpInterface 
        }
    }            
    
    generateCommand mplsTpRouter
    sgPuts "mplsTpServer addRouter [mplsTpRouter cget -name]"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doMplsTpInterface
#
# This command gets MPLSTP Interface
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doMplsTpInterface {} \
{
    set retCode 0

    if {![mplsTpInterface getFirstLspPwRange]} {
        doMplsTpLspPwRange 
        while {![mplsTpInterface  getNextLspPwRange]} {
            doMplsTpLspPwRange 
        }
    }     

	generateCommand mplsTpInterface 
    sgPuts "mplsTpRouter addInterface [mplsTpInterface cget -name]"
	sgPuts ""

    return $retCode
}    

########################################################################
# Procedure: doMplsTpLspPwRange
#
# This command gets MplsTp LspPwRange
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doMplsTpLspPwRange {} \
{
    set retCode 0

    generateCommand mplsTpLspPwRange
    sgPuts "mplsTpInterface addLspPwRange [mplsTpLspPwRange cget -name]"
	sgPuts ""

    return $retCode
}

########################################################################
# 
#       ------------  MPLSOAM procedures  ------------
#
########################################################################

########################################################################
# Procedure: getMplsOam
#
# This command generats MplsOam server commands
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
#
########################################################################

proc scriptGen::getMplsOam {chassis card port} \
{
    set retCode 0

    if {![mplsOamServer select $chassis $card $port]} {
        sgPuts {mplsOamServer select $chassis $card $port}
        sgPuts "mplsOamServer clearAllRouters"
        
        if {![mplsOamServer getFirstRouter]} {
            doMplsOamRouter 
            while {![mplsOamServer getNextRouter]} {
                doMplsOamRouter 
            }
        }
	}
	if {![mplsOamServer get]} {
        generateCommand mplsOamServer
        sgPuts "mplsOamServer set"
        sgPuts ""
        sgPuts "mplsOamServer write"
        sgPuts ""
    }
	 return $retCode
 }

########################################################################
# Procedure: doMplsOamRouter
#
# This command gets MplsOam router
# Arguments(s):
# Returned Result:
########################################################################

proc scriptGen::doMplsOamRouter {} \
{
    set retCode 0
                 
    if {![mplsOamRouter getFirstInterface]} {
        doMplsOamInterface 
        while {![mplsOamRouter  getNextInterface]} {
            doMplsOamInterface 
        }
    }            
    
    generateCommand mplsOamRouter
    sgPuts "mplsOamServer addRouter [mplsOamRouter cget -name]"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doMplsOamInterface
#
# This command gets MPLSOAM Interface
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doMplsOamInterface {} \
{
    set retCode 0

    generateCommand mplsOamInterface 
    sgPuts "mplsOamRouter addInterface [mplsOamInterface cget -name]"
	sgPuts ""

    return $retCode
}    

########################################################################
# 
#       ------------  ELMI procedures  ------------
#
########################################################################

########################################################################
# Procedure: getElmi
#
# This command generats Elmi server commands
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result:
#
########################################################################

proc scriptGen::getElmi {chassis card port} \
{
    set retCode 0

    if {![elmiServer select $chassis $card $port]} {
        sgPuts {elmiServer select $chassis $card $port}
        sgPuts "elmiServer clearAllUnis"

        if {![elmiServer getFirstUni]} {
            doElmiUni 
            while {![elmiServer getNextUni]} {
                doElmiUni 
            }
        }
	}

	if {![elmiServer get]} {
        generateCommand elmiServer
        sgPuts "elmiServer set"
        sgPuts ""
    }

    return $retCode
}

########################################################################
# Procedure: doElmiUni
#
# This command gets ELMI Uni
# Arguments(s):
# Returned Result:
########################################################################

proc scriptGen::doElmiUni {} \
{
    set retCode 0
                 
    if {![elmiUni getFirstUniStatus]} {
        doElmiUniStatus
        while {![elmiUni  getNextUniStatus]} {
            doElmiUniStatus 
        }
    }

	if {![elmiUni getFirstEvc]} {
        doElmiEvc
        while {![elmiUni  getNextEvc]} {
            doElmiEvc 
        }
    }

    generateCommand elmiUni
    sgPuts "elmiServer addUni [elmiUni cget -name]"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doElmiUniStatus
#
# This command gets ELMI UniStatus
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doElmiUniStatus {} \
{
    set retCode 0
    
    if {![elmiUniStatus getFirstBwProfile]} {
        doElmiUniBwProfile
        while {![elmiUniStatus  getNextBwProfile]} {
            doElmiUniBwProfile 
        }
    }    

    generateCommand elmiUniStatus
    sgPuts "elmiUni addUniStatus [elmiUniStatus cget -name]"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doElmiEvc
#
# This command gets ELMI Evc
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doElmiEvc {} \
{
    set retCode 0

    if {![elmiEvc getFirstBwProfile]} {
        doElmiEvcBwProfile
        while {![elmiEvc  getNextBwProfile]} {
            doElmiEvcBwProfile 
        }
    }  
    
    if {![elmiEvc getFirstCeVlanIdRange]} {
        doElmiCeVlanIdRange
        while {![elmiEvc  getNextCeVlanIdRange]} {
            doElmiCeVlanIdRange
        }
    } 
    generateCommand elmiEvc
    sgPuts "elmiUni addEvc [elmiEvc cget -name]"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doElmiUniBwProfile
#
# This command gets ELMI UNI BwProfile
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doElmiUniBwProfile {} \
{
    set retCode 0

    generateCommand elmiBwProfile
    sgPuts "elmiUniStatus addBwProfile [elmiBwProfile cget -name]"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doElmiEvcBwProfile
#
# This command gets ELMI EVC BwProfile
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doElmiEvcBwProfile {} \
{
    set retCode 0

    generateCommand elmiBwProfile
    sgPuts "elmiEvc addBwProfile [elmiBwProfile cget -name]"
    sgPuts ""

    return $retCode
}

########################################################################
# Procedure: doElmiCeVlanIdRange
#
# This command gets ELMI EVC CeVlanIdRange
# Arguments(s):
# Returned Result:
########################################################################      

proc scriptGen::doElmiCeVlanIdRange {} \
{
    set retCode 0

    generateCommand elmiCeVlanIdRange
    sgPuts "elmiEvc addCeVlanIdRange [elmiCeVlanIdRange cget -name]"
    sgPuts ""

    return $retCode
}
