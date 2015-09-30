#############################################################################################
#
# pkgIndex.tcl
#
# Copyright © 1997-2006 by IXIA.
# All Rights Reserved.
#
#
#############################################################################################

set env(IXTCLNETWORK_7.51.1014.14) [file dirname [info script]]

package ifneeded IxTclNetwork 7.51.1014.14 {
    package provide IxTclNetwork 7.51.1014.14

    namespace eval ::ixTclNet {}
    namespace eval ::ixTclPrivate {}

    foreach fileItem1 [glob -nocomplain $env(IXTCLNETWORK_7.51.1014.14)/Generic/*.tcl] {
        if {![file isdirectory $fileItem1]} {
            source  $fileItem1
        }
    }

    source [file join $env(IXTCLNETWORK_7.51.1014.14) IxTclNetwork.tcl]
}
