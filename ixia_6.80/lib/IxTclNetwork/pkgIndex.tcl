#############################################################################################
#
# pkgIndex.tcl
#
# Copyright © 1997-2006 by IXIA.
# All Rights Reserved.
#
#
#############################################################################################

set env(IXTCLNETWORK_7.41.945.9) [file dirname [info script]]

package ifneeded IxTclNetwork 7.41.945.9 {
    package provide IxTclNetwork 7.41.945.9

    namespace eval ::ixTclNet {}
    namespace eval ::ixTclPrivate {}

    foreach fileItem1 [glob -nocomplain $env(IXTCLNETWORK_7.41.945.9)/Generic/*.tcl] {
        if {![file isdirectory $fileItem1]} {
            source  $fileItem1
        }
    }

    source [file join $env(IXTCLNETWORK_7.41.945.9) IxTclNetwork.tcl]
}
