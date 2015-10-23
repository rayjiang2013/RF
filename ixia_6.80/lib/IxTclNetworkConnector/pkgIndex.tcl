#############################################################################################
#
# pkgIndex.tcl
#
# Copyright © 1997-2012 by IXIA.
# All Rights Reserved.
#
# NOTE: This package has been deprecated and is no longer required in order to
#       access the ConnectionManager.  It has been superseded by package req IxTclNetwork.
#############################################################################################

set env(IXTCLNETWORKCONNECTOR_LOCATION) [file dirname [info script]]

package ifneeded IxTclNetworkConnector 7.41.945.9 {
	package provide IxTclNetworkConnector 7.41.945.9
	package req IxTclNetwork
	puts "This package has been deprecated and is no longer required in order to access the ConnectionManager. It has been superseded by package req IxTclNetwork"
}

