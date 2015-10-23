##l
# $Id: $
# Copyright (c) 2003-2005 Ixia
#
# Name:
#    pkgIndex.tcl
#
# Purpose:
#    Provide an independant package for the script development library containing
#    general APIs for test automation with the Ixia chassis.
#
# Author:
#    Debby Stopp
#
# Usage:
#    package require Ixia
#
# Description:
#
# Requirements:
#    ixiaHLTAPI.tcl, a library containing the Ixia HLTAPI
#    ixiaapiutils.tcl, a library containing TCL utilities
#    parseddashedargs.tcl, a library containing the procDescr and 
#        parse_dashed_args procedures
#
# Variables:
#    To be added
#
# Keywords:
#    To be defined
#
# Category:
#    To be defined

# Minimum version of Tcl 8.3 required to work
if {![package vsatisfies [package provide Tcl] 8.3]} {return}

package ifneeded Ixia 4.96 [list source [file join $dir Ixia.tcl]]
