#############################################################################################
#
# IxTclProtocol.tcl  - required file for package require IxTclProtocol
#
# Copyright © 1997-2004 by IXIA.
# All Rights Reserved.
#
#   Revision Log:
#   05-06-2004  EM  Genesis
#
#############################################################################################

if {[catch {package require IxTclNetwork}]} { 
	logMsg "Error in package require IxTclNetwork"
	return 1
}

set currDir [file dirname [info script]]

foreach fileItem1 [glob -nocomplain [file join $currDir/*]] {
    # We only are concerned with directories
    if {[file isdirectory $fileItem1]} {
        foreach fileItem2 [glob -nocomplain $fileItem1/*] {
            if {![file isdirectory $fileItem2]} {
				source  $fileItem2
			} 
        }
    } 
}

namespace eval ixTclNetworkProtocol {
    variable noArgList
    variable pointerList
    variable commandList
}

#source [file join $currDir ixTclProtocolSetup.tcl]

package provide IxTclNetworkProtocol 7.41.1076.5 

