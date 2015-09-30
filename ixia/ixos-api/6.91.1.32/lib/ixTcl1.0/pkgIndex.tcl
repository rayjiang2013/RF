#############################################################################################
#   Version 6.91
#   
#   File: pkgIndex.tcl
#
#   Copyright �  IXIA.
#	All Rights Reserved.
#
#############################################################################################

if {$::tcl_platform(platform) != "unix"} {
    # if this package is already loaded, then don't load it again
    if {[lsearch [package names] IxTclHal] != -1} {
        return
    }
} else {
    lappend ::auto_path $dir
}

package ifneeded IxTclHal 6.91 [list source [file join $dir ixTclHal.tcl]]





