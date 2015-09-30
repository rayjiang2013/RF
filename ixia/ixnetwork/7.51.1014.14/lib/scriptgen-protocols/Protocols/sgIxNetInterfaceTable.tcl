#############################################################################################
#
# sgIxNetInterfaceTable.tcl  Utilities for scriptgen
#
#   Copyright © 1997 - 2006 by IXIA.
#   All Rights Reserved.
#
#	Revision Log:
#	01-19-2006	EM	Genesis
#
#
#############################################################################################

#This API is only for internal use and it is going to fix scripgen issues
#in generating interfaces that are created on IxNetwork.

########################################################################
# Procedure: doIxNetInterfaceTable
#
# This command gets  IxNetwork protocol interface table parameters.
# Arguments(s):
# chassis : chassis Id
# card    : card Id
# port    : port Id
# Returned Result: Always return OK
########################################################################

proc scriptGen::doIxNetInterfaceTable { chassis card port} \
{
    set retCode 0

	sgPuts ""

    if {![ixNetInterfaceTable select $chassis $card $port]} {
		set paramList [list $::interfaceTypeConnected  $::interfaceTypeRouted $::interfaceTypeGre]
		set ixNetHasDhcpV4 0
        set ixNetHasDhcpV6 0
        foreach param $paramList {
			if {![ixNetInterfaceTable getFirstInterface $param]} {

                if {[ixNetInterfaceEntry cget -enableDhcp] == 1} {
                    set ixNetHasDhcpV4 1
                }

                if {[ixNetInterfaceEntry cget -enableDhcpV6] == 1} {
                    set ixNetHasDhcpV6 1
                }

				doIxNetInterfaceEntry  $chassis $card $port
				while {![ixNetInterfaceTable getNextInterface $param]} {
                    
                    if {[ixNetInterfaceEntry cget -enableDhcp] == 1} {
                        set ixNetHasDhcpV4 1
                    }

                    if {[ixNetInterfaceEntry cget -enableDhcpV6] == 1} {
                        set ixNetHasDhcpV6 1
                    }


					sgPuts ""
				    doIxNetInterfaceEntry $chassis $card $port
     
				}
			}
		}

        #NOTE: dhcpV4RequestRate and dhcpV6RequestRate are table option and could be configured either on IxOS or IxNetwork
        #We use the following logic to pick a value:
        #Compare the values, if they are the same value, don't print anything.
        #If they are different getthe one that has dhcp interfaces ( dhcp is enabled on any interfaces)
        #if both has dhcp interfaces pick IxNetwork value.
        
        if {![interfaceTable select $chassis $card $port]} {
            interfaceTable get
        }
        
        ixNetInterfaceTable get

        set printFlag 0
        set paramList {}
        if { [interfaceTable cget -dhcpV4RequestRate] != [ixNetInterfaceTable cget -dhcpV4RequestRate] } {
            
            if {$ixNetHasDhcpV4 == 1} {
                interfaceTable config -dhcpV4RequestRate [ixNetInterfaceTable cget -dhcpV4RequestRate]
	            lappend  paramList dhcpV4RequestRate
                set printFlag 1
            }
        }

        if { [interfaceTable cget -dhcpV6RequestRate] != [ixNetInterfaceTable cget -dhcpV6RequestRate] } {
            
            if {$ixNetHasDhcpV6 == 1} {
                interfaceTable config -dhcpV6RequestRate [ixNetInterfaceTable cget -dhcpV6RequestRate]
	            lappend  paramList dhcpV6RequestRate
                set printFlag 1
            }
        }
            
            
        if {$printFlag == 1} {
            partiallyGenerateCommand interfaceTable $paramList noSetDefault
            sgPuts {interfaceTable set}
        }

    }      
    return $retCode 
}



########################################################################
# Procedure: doIxNetInterfaceEntry
#
# This command gets  protocol interface table entry parameters.
# Arguments(s):
# Returned Result: Always return OK
########################################################################

proc scriptGen::doIxNetInterfaceEntry { chassis card port} \
{
    set retCode 0
    
	set interfaceType [ixNetInterfaceEntry cget -interfaceType]
	

	if {$interfaceType == $::interfaceTypeConnected } {
        set interfaceParamList [list enable description macAddress mtu eui64Id atmEncapsulation \
									 atmMode atmVpi atmVci enableDhcp enableDhcpV6 enableVlan vlanId vlanPriority]
		set interfaceEntryParamList [list gatewayIpAddress maskWidth ipAddress ]
    
	} elseif {$interfaceType == $::interfaceTypeGre } {
        set interfaceParamList [list enable description greSourceIpAddress greDestIpAddress enableGreChecksum enableGreSequence enableGreKey greInKey greOutKey]
		set interfaceEntryParamList [list maskWidth ipAddress ]

    } elseif {$interfaceType == $::interfaceTypeRouted } {
        set interfaceParamList [list enable description connectedVia eui64Id ]
		set interfaceEntryParamList [list maskWidth ipAddress ]

    } else {
        set interfaceParamList {}
		set interfaceEntryParamList {}
	}

    sgPuts "interfaceEntry clearAllItems addressTypeIpV6"
    sgPuts "interfaceEntry clearAllItems addressTypeIpV4"
	sgPuts "interfaceEntry setDefault"
	sgPuts ""

    if {![ixNetInterfaceEntry getFirstItem $::addressTypeIpV6]} {
        doIxNetInterfaceIpV6
        while {![ixNetInterfaceEntry getNextItem  $::addressTypeIpV6]} {
            doIxNetInterfaceIpV6      
        }
    }

	#IpV4 is not a list now. 
   
    if {![ixNetInterfaceEntry getFirstItem $::addressTypeIpV4]} {
        foreach option $interfaceEntryParamList {
		    interfaceIpV4 config -$option [ixNetInterfaceIpV4 cget -$option]
        }

	    partiallyGenerateCommand interfaceIpV4 $interfaceEntryParamList
        sgPuts {interfaceEntry addItem addressTypeIpV4}
        sgPuts ""
    }
    
    if {$interfaceType == $::interfaceTypeConnected} {
	    doIxNetDhcpV4Properties $chassis $card $port
        doIxNetDhcpV6Properties $chassis $card $port
    }
    
    foreach option $interfaceParamList {
	    interfaceEntry config -$option [ixNetInterfaceEntry cget -$option]
    }
      
    partiallyGenerateCommand interfaceEntry $interfaceParamList	no
	sgPuts "interfaceTable addInterface [getEnumString ixNetInterfaceEntry -interfaceType]"
	sgPuts ""     
   
    return $retCode 
}



########################################################################
# Procedure: doIxNetInterfaceIpV6
#
# This command gets  protocol interface iPv6 parameters.
# Arguments(s):
# Returned Result: Always return OK
########################################################################

proc scriptGen::doIxNetInterfaceIpV6 {} \
{
    set retCode 0
    configIxOsCommand interfaceIpV6 ixNetInterfaceIpV6      
    generateCommand interfaceIpV6
    sgPuts {interfaceEntry addItem addressTypeIpV6}
    sgPuts ""
       
    return $retCode 
}

########################################################################
# Procedure: doIxNetDhcpV4Properties
#
# This command gets  protocol interface for Dhcp V4 properties.
# Arguments(s):
# Returned Result: Always return OK
########################################################################

proc scriptGen::doIxNetDhcpV4Properties { chassis card port } \
{
    set retCode 0

	if {[port isValidFeature $chassis $card $port $::portFeatureProtocolDHCP] } {

		sgPuts "dhcpV4Properties removeAllTlvs"
        configIxOsCommand dhcpV4Properties ixNetDhcpV4Properties     
		generateCommand dhcpV4Properties


		if {![ixNetDhcpV4Properties getFirstTlv]} {
            configIxOsCommand dhcpV4Tlv ixNetDhcpV4Tlv     
			generateCommand dhcpV4Tlv
			sgPuts "dhcpV4Properties addTlv"
			while {![ixNetDhcpV4Properties getNextTlv]} {
            configIxOsCommand dhcpV4Tlv ixNetDhcpV4Tlv
				generateCommand dhcpV4Tlv
				sgPuts "dhcpV4Properties addTlv"
			}
		}
		sgPuts ""      
	}
	       
    return $retCode 
}

########################################################################
# Procedure: doIxNetDhcpV6Properties
#
# This command gets  protocol interface for Dhcp V6 properties.
# Arguments(s):
# Returned Result: Always return OK
########################################################################

proc scriptGen::doIxNetDhcpV6Properties { chassis card port } \
{
    set retCode 0

	if {[port isValidFeature $chassis $card $port $::portFeatureProtocolDHCPv6] } {

		sgPuts "dhcpV6Properties removeAllTlvs"
        configIxOsCommand dhcpV6Properties ixNetDhcpV6Properties
		generateCommand dhcpV6Properties


		if {![ixNetDhcpV6Properties getFirstTlv]} {
            configIxOsCommand dhcpV6Tlv ixNetDhcpV6Tlv 
			generateCommand dhcpV6Tlv
			sgPuts "dhcpV6Properties addTlv"
			while {![ixNetDhcpV6Properties getNextTlv]} {
                configIxOsCommand dhcpV6Tlv ixNetDhcpV6Tlv 
				generateCommand dhcpV6Tlv
				sgPuts "dhcpV6Properties addTlv"
			}
		}
		sgPuts ""      
	}
	       
    return $retCode 
}

proc scriptGen::configIxOsCommand {ixOsCmd ixNetCmd} \
{
    set method config
    catch {$ixOsCmd $method} paramList

    foreach option [join $paramList] {
        if {![catch {$ixNetCmd cget $option}]} {
            $ixOsCmd config $option [$ixNetCmd cget $option]
        }
    }
}
