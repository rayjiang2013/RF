#############################################################################################
#   
#   File: ixTclProtocolPackageControl.tcl
#
#  Package initialization file for IxNetwork
#
#  This file is sourced when you use "package require IxTclProtocol" to
#  load the IxTclProtocol library package.
#
#   Copyright ©  IXIA.
#	All Rights Reserved.
#
#############################################################################################

if {![info exists env(IXTCLHAL_DECOUPLE)]} {

      catch {package require IxTclProtocol}

}
