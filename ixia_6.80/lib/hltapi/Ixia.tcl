
##l
# $Id: $
# Copyright (c) 2003-2005 Ixia
# All Rights Reserved.
#
# Name:
#    Ixia.tcl
#
# Purpose:
#    The main file that provides the necessary setup for the package require
#    Ixia command.
#
# Author:
#    Michael Githens
#
# Usage:
#
# Description:
#
# Requirements:
#
# Variables:
#
# Keywords:
#
# Category:
#
################################################################################
#                                                                              #
#                                LEGAL  NOTICE:                                #
#                                ==============                                #
# The following code and documentation (hereinafter "the script") is an        #
# example script for demonstration purposes only.                              #
# The script is not a standard commercial product offered by Ixia and have     #
# been developed and is being provided for use only as indicated herein. The   #
# script [and all modifications, enhancements and updates thereto (whether     #
# made by Ixia and/or by the user and/or by a third party)] shall at all times #
# remain the property of Ixia.                                                 #
#                                                                              #
# Ixia does not warrant (i) that the functions contained in the script will    #
# meet the users requirements or (ii) that the script will be without         #
# omissions or error-free.                                                     #
# THE SCRIPT IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, AND IXIA        #
# DISCLAIMS ALL WARRANTIES, EXPRESS, IMPLIED, STATUTORY OR OTHERWISE,          #
# INCLUDING BUT NOT LIMITED TO ANY WARRANTY OF MERCHANTABILITY AND FITNESS FOR #
# A PARTICULAR PURPOSE OR OF NON-INFRINGEMENT.                                 #
# THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SCRIPT  IS WITH THE #
# USER.                                                                        #
# IN NO EVENT SHALL IXIA BE LIABLE FOR ANY DAMAGES RESULTING FROM OR ARISING   #
# OUT OF THE USE OF, OR THE INABILITY TO USE THE SCRIPT OR ANY PART THEREOF,   #
# INCLUDING BUT NOT LIMITED TO ANY LOST PROFITS, LOST BUSINESS, LOST OR        #
# DAMAGED DATA OR SOFTWARE OR ANY INDIRECT, INCIDENTAL, PUNITIVE OR            #
# CONSEQUENTIAL DAMAGES, EVEN IF IXIA HAS BEEN ADVISED OF THE POSSIBILITY OF   #
# SUCH DAMAGES IN ADVANCE.                                                     #
# Ixia will not be required to provide any software maintenance or support     #
# services of any kind (e.g., any error corrections) in connection with the    #
# script or any part thereof. The user acknowledges that although Ixia may     #
# from time to time and in its sole discretion provide maintenance or support  #
# services for the script, any such services are subject to the warranty and   #
# damages limitations set forth herein and will not obligate Ixia to provide   #
# any additional maintenance or support services.                              #
#                                                                              #
################################################################################

# These data sets are comprised of these versions, HLT, IxOS, IxRouter,
# IxNetwork, IxAccess, and IxLoad.  NA represents when a version is not
# valid for the data set
# Next to the IxNetwork version you can find one of the following combinations:
#   P       - Connect to chassis using IxTclHal and configures protocols using IxTclProtocols
#   N       - Connect to chassis using IxTclHal and IxTclNetwork and configures protocols using
#             IxTclNetwork. Traffic can be configured using IxTclHal (traffic_generator ixos)
#             or IxTclNetwork (traffic_generator ixnetwork or ixnetwork_540)
#   NO      - Connect to chassis using IxTclNetwork and configures protocols using IxTclNetwork.
#             Traffic can be configured only using IxTclNetwork (traffic_generator ixnetwork or ixnetwork_540)
#   P2NO    - When parameter -ixnetwork_tcl_server is missing from ::ixia::connect, the 
#             behavior will be identical to "P".
#             When parameter -ixnetwork_tcl_server is specified in ::ixia::connect, the 
#             behavior will be identical to "NO".
#
array set ixiaHltVersions [list \
        HLTSET1  [list [list 2.40 2.50]      3.80 NA   NA    2.00 NA         ] \
        HLTSET2  [list 2.40                  4.00 4.00 NA    2.00 NA         ] \
        HLTSET3  [list [list 2.40 2.50]      3.80 NA   NA    2.00 NA         ] \
        HLTSET4  [list [list 2.50 2.60]      4.00 4.00 NA    2.10 NA         ] \
        HLTSET5  [list [list 2.50 2.60]      4.00 4.00 NA    2.10 NA         ] \
        HLTSET6  [list 2.60                  4.00 4.10 NA    2.10 NA         ] \
        HLTSET7  [list 2.60                  4.10 4.10 NA    2.20 NA         ] \
        HLTSET8  [list [list 2.70 2.80]      4.00 4.10 NA    2.20 NA         ] \
        HLTSET9  [list [list 2.70 2.80]      4.10 4.10 NA    2.20 3.00       ] \
        HLTSET10 [list 2.70                  4.10 NA   5.00  2.20 3.00       ] \
        HLTSET11 [list [list 2.70 2.80]      4.00 4.10 NA    2.20 NA         ] \
        HLTSET12 [list [list 2.70 2.80]      4.10 4.10 NA    2.20 3.00       ] \
        HLTSET13 [list 2.80                  4.10 NA   5.00  2.20 3.00       ] \
        HLTSET14 [list [list 2.80 2.90]      4.10 4.10 NA    2.30 3.00       ] \
        HLTSET15 [list 2.80                  4.10 NA   5.00  2.30 3.00       ] \
        HLTSET16 [list 2.80                  4.10 NA   5.10  2.30 3.00       ] \
        HLTSET17 [list NA                    NA   NA   NA    NA   NA         ] \
        HLTSET18 [list [list 2.80 2.90]      5.00 NA   5.10  2.30 3.20.38.96 ] \
        HLTSET19 [list 2.90                  5.00 4.10 NA    2.30 3.20.38.96 ] \
        HLTSET20 [list 2.90                  5.00 NA   5.20  2.30 3.20.38.96 ] \
        HLTSET21 [list 2.90                  5.00 NA   5.20  2.30 3.20.38.98 ] \
        HLTSET22 [list 3.00                  5.00 NA   5.30P 2.30 3.30       ] \
        HLTSET23 [list 3.00                  5.00 NA   5.30N NA   3.30       ] \
        HLTSET24 [list [list 3.00 3.10]      4.10 4.10 NA    NA   NA         ] \
        HLTSET25 [list 3.10                  5.00 NA   NA    2.30 NA         ] \
        HLTSET26 [list 3.10                  5.10 NA   5.30P NA   3.40       ] \
        HLTSET27 [list 3.10                  5.10 NA   5.30N NA   3.40       ] \
        HLTSET28 [list 3.10                  5.00 4.10 NA    2.30 NA         ] \
        HLTSET29 [list 3.10                  5.00 NA   5.30P 2.30 NA         ] \
        HLTSET30 [list 3.10                  5.00 NA   5.30N NA   NA         ] \
        HLTSET31 [list 3.10                  5.10 NA   5.30P NA   3.30       ] \
        HLTSET32 [list 3.10                  5.10 NA   5.30N NA   3.30       ] \
        HLTSET33 [list 3.10                  5.10 NA   5.30P 2.40 4.00       ] \
        HLTSET34 [list 3.10                  5.10 NA   5.30N NA   4.00       ] \
        HLTSET35 [list 3.10                  5.20 NA   5.30P NA   NA         ] \
        HLTSET36 [list 3.10                  5.20 NA   5.30N NA   NA         ] \
        HLTSET37 [list 3.20                  5.00 4.10 NA    2.30 NA         ] \
        HLTSET38 [list 3.20                  5.10 NA   5.30P 2.40 NA         ] \
        HLTSET39 [list 3.20                  5.10 NA   5.30N NA   4.00       ] \
        HLTSET40 [list 3.20                  5.20 NA   5.30P NA   4.00       ] \
        HLTSET41 [list 3.20                  5.20 NA   5.30N NA   NA         ] \
        HLTSET42 [list 3.30                  5.20 NA   5.30P NA   4.10       ] \
        HLTSET43 [list 3.30                  5.20 NA   5.30N NA   4.10       ] \
        HLTSET44 [list 3.30                  5.30 NA   5.30N NA   4.10       ] \
        HLTSET45 [list 3.30                  5.30 NA   NA    NA   4.10       ] \
        HLTSET46 [list 3.40                  5.20 NA   5.30P NA   4.10       ] \
        HLTSET47 [list 3.40                  5.20 NA   5.30N NA   4.10       ] \
        HLTSET48 [list 3.40                  5.30 NA   5.30P NA   4.10       ] \
        HLTSET49 [list 3.40                  5.30 NA   5.30N NA   4.10       ] \
        HLTSET50 [list [list 3.50 3.60 3.70] 5.30 NA   5.30P NA   4.20       ] \
        HLTSET51 [list [list 3.50 3.60 3.70] 5.30 NA   5.30N NA   4.20       ] \
        HLTSET52 [list [list 3.50 3.60 3.70] 5.50 NA   5.30P NA   4.20       ] \
        HLTSET53 [list [list 3.50 3.60 3.70] 5.50 NA   5.30N NA   4.20       ] \
        HLTSET54 [list [list 3.60 3.70 3.80] 5.50 NA   5.40P NA   4.30       ] \
        HLTSET55 [list [list 3.60 3.70 3.80] 5.50 NA   5.40N NA   4.30       ] \
        HLTSET56 [list [list 3.80]           5.60 NA   5.40P NA   4.30       ] \
        HLTSET57 [list [list 3.80]           5.60 NA   5.40N NA   4.30       ] \
        HLTSET58 [list [list 3.90]           5.50 NA   5.40P  NA  4.30       ] \
        HLTSET59 [list [list 3.90]           5.50 NA   5.40N  NA  4.30       ] \
        HLTSET60 [list [list 3.90]           5.50 NA   5.40NO NA  4.30       ] \
        HLTSET61 [list [list 3.90]           5.50 NA   5.50P  NA  5.00       ] \
        HLTSET62 [list [list 3.90]           5.50 NA   5.50N  NA  5.00       ] \
        HLTSET63 [list [list 3.90]           5.50 NA   5.50NO NA  5.00       ] \
        HLTSET64 [list [list 3.90]           5.60 NA   5.50P  NA  5.00       ] \
        HLTSET65 [list [list 3.90]           5.60 NA   5.50N  NA  5.00       ] \
        HLTSET66 [list [list 3.90]           5.60 NA   5.50NO NA  5.00       ] \
        HLTSET67 [list [list 3.90]           5.50 NA   5.40P2NO NA  4.30     ] \
        HLTSET68 [list [list 3.90]           5.50 NA   5.50P2NO NA  5.00     ] \
        HLTSET69 [list [list 3.90]           5.60 NA   5.50P2NO NA  5.00     ] \
        HLTSET70 [list [list 4.00]           5.60 NA   5.50P    NA  5.00     ] \
        HLTSET71 [list [list 4.00]           5.60 NA   5.50N    NA  5.00     ] \
        HLTSET72 [list [list 4.00]           5.60 NA   5.50NO   NA  5.00     ] \
        HLTSET73 [list [list 4.00]           5.60 NA   5.50P2NO NA  5.00     ] \
        HLTSET74 [list [list 4.00 4.10]      5.70 NA   5.60P    NA  5.10     ] \
        HLTSET75 [list [list 4.00 4.10]      5.70 NA   5.60N    NA  5.10     ] \
        HLTSET76 [list [list 4.00 4.10]      5.70 NA   5.60NO   NA  5.10     ] \
        HLTSET77 [list [list 4.00 4.10]      5.70 NA   5.60P2NO NA  5.10     ] \
        HLTSET78 [list [list 4.10]           6.00 NA   5.70P    NA  5.20     ] \
        HLTSET79 [list [list 4.10]           6.00 NA   5.70N    NA  5.20     ] \
        HLTSET80 [list [list 4.10]           6.00 NA   5.70NO   NA  5.20     ] \
        HLTSET81 [list [list 4.10]           6.00 NA   5.70P2NO NA  5.20     ] \
        HLTSET82 [list [list 4.20]           5.70 NA   5.60P    NA  5.20     ] \
        HLTSET83 [list [list 4.20]           5.70 NA   5.60N    NA  5.20     ] \
        HLTSET84 [list [list 4.20]           5.70 NA   5.60NO   NA  5.20     ] \
        HLTSET85 [list [list 4.20]           5.70 NA   5.60P2NO NA  5.20     ] \
        HLTSET86 [list [list 4.20]           6.10 NA   6.0P     NA  5.15     ] \
        HLTSET87 [list [list 4.20]           6.10 NA   6.0N     NA  5.15     ] \
        HLTSET88 [list [list 4.20]           6.10 NA   6.0NO    NA  5.15     ] \
        HLTSET89 [list [list 4.20]           6.10 NA   6.0P2NO  NA  5.15     ] \
        HLTSET90  [list [list 4.30]          5.70 NA   6.0P     NA  5.10     ] \
        HLTSET91  [list [list 4.30]          5.70 NA   6.0N     NA  5.10     ] \
        HLTSET92  [list [list 4.30]          5.70 NA   6.0NO    NA  5.10     ] \
        HLTSET93  [list [list 4.30]          5.70 NA   6.0P2NO  NA  5.10     ] \
        HLTSET94  [list [list 4.30]          6.10 NA   6.0P     NA  5.30     ] \
        HLTSET95  [list [list 4.30]          6.10 NA   6.0N     NA  5.30     ] \
        HLTSET96  [list [list 4.30]          6.10 NA   6.0NO    NA  5.30     ] \
        HLTSET97  [list [list 4.30]          6.10 NA   6.0P2NO  NA  5.30     ] \
        HLTSET98  [list [list 4.30]          5.70 NA   6.10P    NA  5.10     ] \
        HLTSET99  [list [list 4.30]          5.70 NA   6.10N    NA  5.10     ] \
        HLTSET100 [list [list 4.30]          5.70 NA   6.10NO   NA  5.10     ] \
        HLTSET101 [list [list 4.30]          5.70 NA   6.10P2NO NA  5.10     ] \
        HLTSET102 [list [list 4.30]          6.10 NA   6.10P    NA  5.30     ] \
        HLTSET103 [list [list 4.30]          6.10 NA   6.10N    NA  5.30     ] \
        HLTSET104 [list [list 4.30]          6.10 NA   6.10NO   NA  5.30     ] \
        HLTSET105 [list [list 4.30]          6.10 NA   6.10P2NO NA  5.30     ] \
        HLTSET106 [list [list 4.30]          6.20 NA   6.20P    NA  5.40     ] \
        HLTSET107 [list [list 4.30]          6.20 NA   6.20N    NA  5.40     ] \
        HLTSET108 [list [list 4.30]          6.20 NA   6.20NO   NA  5.40     ] \
        HLTSET109 [list [list 4.30]          6.20 NA   6.20P2NO NA  5.40     ] \
        HLTSET110 [list [list 4.40]          6.10 NA   6.0P     NA  5.30     ] \
        HLTSET111 [list [list 4.40]          6.10 NA   6.0N     NA  5.30     ] \
        HLTSET112 [list [list 4.40]          6.10 NA   6.0NO    NA  5.30     ] \
        HLTSET113 [list [list 4.40]          6.10 NA   6.0P2NO  NA  5.30     ] \
        HLTSET114 [list [list 4.40]          6.30 NA   NA       NA  6.0      ] \
        HLTSET115 [list [list 4.40]          6.20 NA   6.20P    NA  5.40     ] \
        HLTSET116 [list [list 4.40]          6.20 NA   6.20N    NA  5.40     ] \
        HLTSET117 [list [list 4.40]          6.20 NA   6.20NO   NA  5.40     ] \
        HLTSET118 [list [list 4.40]          6.20 NA   6.20P2NO NA  5.40     ] \
        HLTSET119 [list [list 4.40]          6.30 NA   6.30P    NA  6.0      ] \
        HLTSET120 [list [list 4.40]          6.30 NA   6.30N    NA  6.0      ] \
        HLTSET121 [list [list 4.40]          6.30 NA   6.30NO   NA  6.0      ] \
        HLTSET122 [list [list 4.40]          6.30 NA   6.30P2NO NA  6.0      ] \
        HLTSET123 [list [list 4.50]          6.30 NA   6.30P    NA  6.10     ] \
        HLTSET124 [list [list 4.50]          6.30 NA   6.30N    NA  6.10     ] \
        HLTSET125 [list [list 4.50]          6.30 NA   6.30NO   NA  6.10     ] \
        HLTSET126 [list [list 4.50]          6.30 NA   6.30P2NO NA  6.10     ] \
        HLTSET127 [list [list 4.60]          6.30 NA   6.30P    NA  6.10     ] \
        HLTSET128 [list [list 4.60]          6.30 NA   6.30N    NA  6.10     ] \
        HLTSET129 [list [list 4.60]          6.30 NA   6.30NO   NA  6.10     ] \
        HLTSET130 [list [list 4.60]          6.30 NA   6.30P2NO NA  6.10     ] \
        HLTSET131 [list [list 4.60]          6.40 NA   7.0P     NA  6.20     ] \
        HLTSET132 [list [list 4.60]          6.40 NA   7.0N     NA  6.20     ] \
        HLTSET133 [list [list 4.60]          6.40 NA   7.0NO    NA  6.20     ] \
        HLTSET134 [list [list 4.60]          6.40 NA   7.0P2NO  NA  6.20     ] \
        HLTSET135 [list [list 4.70]          6.40 NA   7.0P     NA  6.30     ] \
        HLTSET136 [list [list 4.70]          6.40 NA   7.0N     NA  6.30     ] \
        HLTSET137 [list [list 4.70]          6.40 NA   7.0NO    NA  6.30     ] \
        HLTSET138 [list [list 4.70]          6.40 NA   7.0P2NO  NA  6.30     ] \
        HLTSET139 [list [list 4.70]          6.50 NA   7.10P    NA  6.30     ] \
        HLTSET140 [list [list 4.70]          6.50 NA   7.10N    NA  6.30     ] \
        HLTSET141 [list [list 4.70]          6.50 NA   7.10NO   NA  6.30     ] \
        HLTSET142 [list [list 4.70]          6.50 NA   7.10P2NO NA  6.30     ] \
        HLTSET143 [list [list 4.71]          6.50 NA   7.11P    NA  NA       ] \
        HLTSET144 [list [list 4.71]          6.50 NA   7.11N    NA  NA       ] \
        HLTSET145 [list [list 4.71]          6.50 NA   7.11NO   NA  NA       ] \
        HLTSET146 [list [list 4.71]          6.50 NA   7.11P2NO NA  NA       ] \
        HLTSET147 [list [list 4.72]          6.50 NA   7.12P    NA  NA       ] \
        HLTSET148 [list [list 4.72]          6.50 NA   7.12N    NA  NA       ] \
        HLTSET149 [list [list 4.72]          6.50 NA   7.12NO   NA  NA       ] \
        HLTSET150 [list [list 4.72]          6.50 NA   7.12P2NO NA  NA       ] \
        HLTSET151 [list [list 4.80]          6.60 NA   7.20P    NA  NA       ] \
        HLTSET152 [list [list 4.80]          6.60 NA   7.20N    NA  NA       ] \
        HLTSET153 [list [list 4.80]          6.60 NA   7.20NO   NA  NA       ] \
        HLTSET154 [list [list 4.80]          6.60 NA   7.20P2NO NA  NA       ] \
        HLTSET155 [list [list 4.81]          6.60 NA   7.21P    NA  NA       ] \
        HLTSET156 [list [list 4.81]          6.60 NA   7.21N    NA  NA       ] \
        HLTSET157 [list [list 4.81]          6.60 NA   7.21NO   NA  NA       ] \
        HLTSET158 [list [list 4.81]          6.60 NA   7.21P2NO NA  NA       ] \
        HLTSET159 [list [list 4.82]          6.62 NA   7.22P    NA  NA       ] \
        HLTSET160 [list [list 4.82]          6.62 NA   7.22N    NA  NA       ] \
        HLTSET161 [list [list 4.82]          6.62 NA   7.22NO   NA  NA       ] \
        HLTSET162 [list [list 4.82]          6.62 NA   7.22P2NO NA  NA       ] \
        HLTSET163 [list [list 4.90]          6.70 NA   7.30P    NA  NA       ] \
        HLTSET164 [list [list 4.90]          6.70 NA   7.30N    NA  NA       ] \
        HLTSET165 [list [list 4.90]          6.70 NA   7.30NO   NA  NA       ] \
        HLTSET166 [list [list 4.90]          6.70 NA   7.30P2NO NA  NA       ] \
        HLTSET167 [list [list 4.91]          6.70 NA   7.31P    NA  NA       ] \
        HLTSET168 [list [list 4.91]          6.70 NA   7.31N    NA  NA       ] \
        HLTSET169 [list [list 4.91]          6.70 NA   7.31NO   NA  NA       ] \
        HLTSET170 [list [list 4.91]          6.70 NA   7.31P2NO NA  NA       ] \
        HLTSET171 [list [list 4.95]          6.80 NA   7.40P    NA  NA       ] \
        HLTSET172 [list [list 4.95]          6.80 NA   7.40N    NA  NA       ] \
        HLTSET173 [list [list 4.95]          6.80 NA   7.40NO   NA  NA       ] \
        HLTSET174 [list [list 4.95]          6.80 NA   7.40P2NO NA  NA       ] \
        HLTSET175 [list [list 4.96]          6.80 NA   7.41P    NA  NA       ] \
        HLTSET176 [list [list 4.96]          6.80 NA   7.41N    NA  NA       ] \
        HLTSET177 [list [list 4.96]          6.80 NA   7.41NO   NA  NA       ] \
        HLTSET178 [list [list 4.96]          6.80 NA   7.41P2NO NA  NA       ] \
        ]

set ::env(IXIA_HLTAPI_LIBRARY) [file dirname [info script]]

# Create global so that IxTclHal will not attempt to package require any
# other Ixia products
set ::env(IXTCLHAL_DECOUPLE) 1

# Setting this for use within parse dashed args, as the variable is not
# necessarily set for Ixia use
# set ::tcl_interactive 1


if { ([info exists tcl_platform(pointerSize)]) && ($tcl_platform(pointerSize) == 8)} {
    puts "Tcl [info tclversion] is installed on 64bit architecture."
} else {
    puts "Tcl [info tclversion] is installed on 32bit architecture."
}



namespace eval ::ixia {
    namespace eval trace {}
    
    proc ::ixia::get_package_latest_version {package_name major_minor} {
        
        # Given the major and minor version of a package this procedure will
        #   return the latest full version major.minor.X.X of the package
        
        foreach {input_major input_minor} [lrange [split $major_minor .] 0 1] {}
        
        set all_versions [lsort -unique [package versions $package_name]]
        
        set ret_version ""
        
        foreach pack_version $all_versions {
            catch {unset major}
            catch {unset minor}
            foreach {major minor} [lrange [split $pack_version .] 0 1] {}
            
            # Go only thru versions that have the same major.minor
            if {$major == $input_major && $minor == $input_minor} {
                if {$ret_version == ""} {
                    set ret_version $pack_version
                } elseif {![catch {package vcompare $ret_version $pack_version} err] &&\
                        $err == -1} {
                    # vcompare returns
                    #   -1 if version1 is an earlier version than version2
                    #    0 if they are equal
                    #    1 if version1 is later than version2
                    set ret_version $pack_version
                }
            }
            
        }
        
        return $ret_version
        
    }
    
    set ::ixia::hltapi_version                      4.96.118.5
    set ::ixia::hltapi_date                         3/12/2015
    
    ##Internal Procedure Header
    # Name:
    #    ::ixia::set_init
    #
    # Description:
    #    This procedure is used to set the variables declared in Ixia.tcl
    #    to their default values
    #
    # Synopsis:
    #    ::ixia::set_init
    #
    # Arguments:
    #
    # Return Values:
    #
    # Examples:
    #
    proc ::ixia::set_init {} {
        if {![isUNIX]} {
            set ::ixia::ixtclhal_version [version cget -ixTclHALVersion]
        }

        if {[info exists ::ixia::pgid_to_stream]} {
            array unset ::ixia::pgid_to_stream
        }
        set ::ixia::pgid_to_stream(-1)                  {0,0,0,0}
        
        if {[info exists ::ixia::no_of_streams_per_port]} {
            array unset ::ixia::no_of_streams_per_port
        }
        
        set ::ixia::ips_to_hosts                        [list]
        set ::ixia::hosts_to_ips                        [list]
        set ::ixia::logHltapiCommandsFileDescriptor     ""
        set ::ixia::logHltapiCommandsFlag               0
        set ::ixia::logHltapiCommandsFileIndex          0
        set ::ixia::logHltapiCommandsFileName           ""
        set ::ixia::debug                               0
        
        # default val if not explicitly set
        namespace eval trace {
            set fileName                                "C:/trace.tcl"
            if {[info exists varNameArray]} {
                array unset varNameArray
            }
            array set varNameArray                      {}
            if {[info exists tempVarNameArray]} {
                array unset tempVarNameArray
            }
            array set tempVarNameArray                  {}
            set lastValidCommand                        ""
            set lastCommand                             ""
            set connectReached                          0
            if {[info exists lastViewAvailableArray]} {
                array unset lastViewAvailableArray
            }
            array set lastViewAvailableArray            {}
            set enableOriginal                          0
        }
        
        set ::ixia::reboot_port_cpu                     0
        if {[regexp -all -nocase {linux} $::tcl_platform(os)]} {
            # Disable utracker if OS is Linux otherwise console becomes unresponsive
            # See bug BUG448330
            set ::ixia::utrackerEnable                      0
        } else {
            set ::ixia::utrackerEnable                      1
        }
        set ::ixia::utrackerDefaultServer               "tasmania-linux"
        set ::ixia::utrackerServer                      "tasmania-linux"
        set ::ixia::reserved_port_list                  [list]
        set ::ixia::current_streamid                    0
        set ::ixia::current_intf                        1
        set ::ixia::port_handles_write_config           ""
        set ::ixia::port_handles_write_ports            ""
        set ::ixia::bgp_handle_index                    0
        set ::ixia::protocol_interfaces_mac_address     0x000000000000
        set ::ixia::ixnetwork_tcl_server                ""
        catch {unset ::ixia::ixnetwork_tcl_proxy}
        set ::ixia::ixnetwork_tcl_server_reset          0
        set ::ixia::ixload_tcl_server                   ""
        set ::ixia::ixload_handles_count                0
        set ::ixia::ixload_test_controller              {{created 0}}
        set ::ixia::ixload_returned_stats               ""
        set ::ixia::ixload_logger                       ""
        set ::ixia::ixload_log_engine                   ""
        set ::ixia::interface_handle                    1
        set ::ixia::portListWritten                     0
        set ::ixia::executeOnTclServer                  0
        set ::ixia::portListWritten                     0
        set ::ixia::ixload_clear_per_interface_stats    0
        set ::ixia::dhcpv6_groups_list                  [list]
        set ::ixia::dhcpv6_groups_index                 0
        set ::ixia::dhcpv6_settings_list                [list]
        set ::ixia::dhcpv6_settings_index               0
        set ::ixia::connected_tcl_srv                   ""
        set ::ixia::chassis_list                        [list]
        set ::ixia::ixnetwork_chassis_list              [list]
        set ::ixia::ixload_chassis_list                 [list]
        set ::ixia::objectMaxCount                      100
        set ::ixia::ixnetwork_emulation_cfg_no          0
        set ::ixia::gateway_list                        [list]
        set ::ixia::source_ixaccess_validate            0
        set ::ixia::hltConnectCall                      0
        set ::ixia::port_supports_types                 ""
        set ::ixia::session_owner_tclhal                ""
        set ::ixia::no_efm_event_trigger                1
        set ::ixia::forceNextGenTraffic                 1
        set ::ixia::chassisIdIndex                      auto
        set ::ixia::csv_path                            ""
        # If ::ixia::chassisIdIndex is auto the starting value of chassis id will be done based on HLTSET
        #                              1    the starting value will be 1
        #                              0    the starting value will be 0

        # This will be used to bypass the sending of HLT procedures to tcl
        # server and hardcoding the IxLoad variables when running on UNIX
        # When this value is "2" it means that IxLoad was package was
        # loaded and we're running on a UNIX machine so the HLT procedure
        # ::ixia::cleanup_sessions must also not send it's call to the tclServer
        set ::ixia::temporary_fix_122311                1
        
        set ::ixia::first_connect_in_session            1
        
        # Enable snapshot method to grab traffic stats.
        set ::ixia::snapshot_stats                      1
        
        catch {unset cfm_messages_current_id}
        catch {unset cfm_topology_current_id}
        catch {unset connect_timeout}
        catch {unset ixn_traffic_version}
        
        if {[info exists ::ixia::master_chassis_array]} {
            array unset ::ixia::master_chassis_array
        }
        array set ::ixia::master_chassis_array           [list]
        
        if {[info exists ::ixia::ixnetwork_master_chassis_array]} {
            array unset ::ixia::ixnetwork_master_chassis_array
        }
        array set ::ixia::ixnetwork_master_chassis_array [list]
        
        if {[info exists ::ixia::ancp_profile_handles_array]} {
            array unset ::ixia::ancp_profile_handles_array
        }
        array set ::ixia::ancp_profile_handles_array ""
        
        if {[info exists ::ixia::stream_to_queue_map]} {
            array unset ::ixia::stream_to_queue_map
        }
        array set ::ixia::stream_to_queue_map ""
        
        if {[info exists ::ixia::port_queue_num]} {
            array unset ::ixia::port_queue_num
        }
        array set ::ixia::port_queue_num ""
        
        if {[info exists ::ixia::aPortState]} {
            array unset ::ixia::aPortState
        }
        array set ::ixia::aPortState ""
        
        if {[info exists ::ixia::ignoreLinkState]} {
            array unset ::ixia::ignoreLinkState
        }
        array set ::ixia::ignoreLinkState ""
        
        if {[info exists ::ixia::dhcpv6_subport_index_array]} {
            array unset ::ixia::dhcpv6_subport_index_array
        }
        array set ::ixia::dhcpv6_subport_index_array    ""
        
        if {[info exists ::ixia::ixnetwork_port_handles_array]} {
            array unset ::ixia::ixnetwork_port_handles_array
        }
        array set ::ixia::ixnetwork_port_handles_array  ""

        if {[info exists ::ixia::ixnetwork_port_handles_array_vport2rp]} {
            array unset ::ixia::ixnetwork_port_handles_array_vport2rp
        }
        array set ::ixia::ixnetwork_port_handles_array_vport2rp  ""

        if {[info exists ::ixia::ixnetwork_stream_ids]} {
            array unset ::ixia::ixnetwork_stream_ids
        }
        array set ::ixia::ixnetwork_stream_ids          ""

        if {[info exists ::ixia::emulation_handles_array]} {
            array unset ::ixia::emulation_handles_array
        }
        array set ::ixia::emulation_handles_array       ""

        if {[info exists ::ixia::ixnetwork_emulation_handles_array]} {
            array unset ::ixia::ixnetwork_emulation_handles_array
        }
        array set ::ixia::ixnetwork_emulation_handles_array       ""

        if {[info exists ::ixia::bgp_neighbor_handles_array]} {
            array unset ::ixia::bgp_neighbor_handles_array
        }
        array set ::ixia::bgp_neighbor_handles_array    ""

        if {[info exists ::ixia::bgp_route_handles_array]} {
            array unset ::ixia::bgp_route_handles_array
        }
        array set ::ixia::bgp_route_handles_array       ""

        if {[info exists ::ixia::bgp_neig_intf_map]} {
            array unset ::ixia::bgp_neig_intf_map
        }
        array set ::ixia::bgp_neig_intf_map       ""

        if {[info exists ::ixia::igmp_attributes_array]} {
            array unset ::ixia::igmp_attributes_array
        }
        array set ::ixia::igmp_attributes_array         ""

        if {[info exists ::ixia::igmp_host_ip_handles_array]} {
            array unset ::ixia::igmp_host_ip_handles_array
        }
        array set ::ixia::igmp_host_ip_handles_array         ""

        if {[info exists ::ixia::igmp_host_handles_array]} {
            array unset ::ixia::igmp_host_handles_array
        }
        array set ::ixia::igmp_host_handles_array       ""

        if {[info exists ::ixia::igmp_group_handles_array]} {
            array unset ::ixia::igmp_group_handles_array
        }
        array set ::ixia::igmp_group_handles_array      ""

        if {[info exists ::ixia::isis_handles_array]} {
            array unset ::ixia::isis_handles_array
        }
        array set ::ixia::isis_handles_array            ""

        if {[info exists ::ixia::ldp_handles_array]} {
            array unset ::ixia::ldp_handles_array
        }
        array set ::ixia::ldp_handles_array             ""

        if {[info exists ::ixia::multicast_group_array]} {
            array unset ::ixia::multicast_group_array
        }
        array set ::ixia::multicast_group_array         ""

        if {[info exists ::ixia::multicast_source_array]} {
            array unset ::ixia::multicast_source_array
        }
        array set ::ixia::multicast_source_array        ""

        if {[info exists ::ixia::multicast_group_ip_to_handle]} {
            array unset ::ixia::multicast_group_ip_to_handle
        }
        array set ::ixia::multicast_group_ip_to_handle        ""

        if {[info exists ::ixia::multicast_source_ip_to_handle]} {
            array unset ::ixia::multicast_source_ip_to_handle
        }
        array set ::ixia::multicast_source_ip_to_handle        ""

        if {[info exists ::ixia::mld_handles_array]} {
            array unset ::ixia::mld_handles_array
        }
        array set ::ixia::mld_handles_array             ""

        if {[info exists ::ixia::mld_group_ranges_array]} {
            array unset ::ixia::mld_group_ranges_array
        }
        array set ::ixia::mld_group_ranges_array        ""

        if {[info exists ::ixia::ospf_handles_array]} {
            array unset ::ixia::ospf_handles_array
        }
        array set ::ixia::ospf_handles_array            ""

        if {[info exists ::ixia::pimsm_handles_array]} {
            array unset ::ixia::pimsm_handles_array
        }
        array set ::ixia::pimsm_handles_array           ""

        if {[info exists ::ixia::rip_router_handles_array]} {
            array unset ::ixia::rip_router_handles_array
        }
        array set ::ixia::rip_router_handles_array      ""

        if {[info exists ::ixia::rip_route_handles_array]} {
            array unset ::ixia::rip_route_handles_array
        }
        array set ::ixia::rip_route_handles_array       ""

        if {[info exists ::ixia::rsvp_handles_array]} {
            array unset ::ixia::rsvp_handles_array
        }
        array set ::ixia::rsvp_handles_array            ""
        
        if {[info exists ::ixia::rsvp_tunnel_parameters]} {
            array unset ::ixia::rsvp_tunnel_parameters
        }
        array set ::ixia::rsvp_tunnel_parameters        ""

        if {[info exists ::ixia::l2tpv3_cc_handles_array]} {
            array unset ::ixia::l2tpv3_cc_handles_array
        }
        array set ::ixia::l2tpv3_cc_handles_array       ""

        if {[info exists ::ixia::l2tpv3_session_handles_array]} {
            array unset ::ixia::l2tpv3_session_handles_array
        }
        array set ::ixia::l2tpv3_session_handles_array  ""
        
        if {[info exists ::ixia::pa_ip_idx]} {
            array unset ::ixia::pa_ip_idx
        }
        array set ::ixia::pa_ip_idx  ""
        
        if {[info exists ::ixia::pa_mac_idx]} {
            array unset ::ixia::pa_mac_idx
        }
        array set ::ixia::pa_mac_idx  ""
        
        if {[info exists ::ixia::pa_descr_idx]} {
            array unset ::ixia::pa_descr_idx
        }
        array set ::ixia::pa_descr_idx  ""
        
        if {[info exists ::ixia::pa_inth_idx]} {
            array unset ::ixia::pa_inth_idx
        }
        array set ::ixia::pa_inth_idx  ""
        
        if {[info exists ::ixia::clear_csv_stats]} {
            array unset ::ixia::clear_csv_stats
        }
        array set ::ixia::clear_csv_stats  ""
        
        if {[info exists ::ixia::atmStatsConfig]} {
            array unset ::ixia::atmStatsConfig
        }
        array set ::ixia::atmStatsConfig                ""

        if {[info exists ::ixia::handles_state_evidence_array]} {
            array unset ::ixia::handles_state_evidence_array
        }
        array set ::ixia::handles_state_evidence_array  ""

        if {[info exists ::ixia::handles_state_evidence_resynch_array]} {
            array unset ::ixia::handles_state_evidence_resynch_array
        }
        array set ::ixia::handles_state_evidence_resynch_array  ""
        
        if {[info exists ::ixia::ixload_cardtype_array]} {
            array unset ::ixia::ixload_cardtype_array
        }
        array set ::ixia::ixload_cardtype_array         ""

        if {[info exists ::ixia::ixload_handles_array]} {
            array unset ::ixia::ixload_handles_array
        }
        array set ::ixia::ixload_handles_array          ""

        if {[info exists ::ixia::ixload_registered_stats]} {
            array unset ::ixia::ixload_registered_stats
        }
        array set ::ixia::ixload_registered_stats       ""

        if {[info exists ::ixia::igmp_port]} {
            array unset ::ixia::igmp_port
        }
        array set ::ixia::igmp_port                     [list   \
                current         no_port                         \
                last            no_port                         \
                write           0                               \
            ]

        if {[info exists ::ixia::igmp_counters]} {
            array unset ::ixia::igmp_counters
        }
        array set ::ixia::igmp_counters                 [list   \
                host            0                               \
                session         0                               \
                groupRange      0                               \
                group_member    0                               \
            ]

        if {[info exists ::ixia::ixaccess_traffic_ports]} {
            array unset ::ixia::ixaccess_traffic_ports
        }
        array set ::ixia::ixaccess_traffic_ports        [list   \
                rx_ports        ""                              \
                tx_ports        ""                              \
            ]

        if {[info exists ::ixia::pending_operations]} {
            array unset ::ixia::pending_operations
        }
        array set ::ixia::pending_operation ""
        
        # tgen_offset_value - information whether signature, signature_offset and/or 
        # pgid_offset were set in ::ixia::interface_config
        # Value:     x          x                x 
        #        signature signature_offset pgid_offset
        # e.g.   101(0x5) - signature and pgid_offset were set 
        if {[info exists ::ixia::tgen_offset_value]} {
            array unset ::ixia::tgen_offset_value
        }
        array set ::ixia::tgen_offset_value ""
        
        if {[info exists ::ixia::oampdu_counters]} {
            array unset ::ixia::oampdu_counters
        }
        array set ::ixia::oampdu_counters ""

        
        if {[info exists ::ixia::traffic_stats_num_calls]} {
            for {set iii 0} {$iii < $::ixia::traffic_stats_num_calls} {incr iii} {
                array unset ::ixia::traffic_stats_returned_keyed_array_$iii
                array set ::ixia::traffic_stats_returned_keyed_array_$iii ""
            }
        }
        set ::ixia::traffic_stats_num_calls 0
        set ::ixia::traffic_stats_max_list_length  1900
        
        if {[info exists ::ixia::cfm_stats_num_calls]} {
            for {set iii 0} {$iii < $::ixia::cfm_stats_num_calls} {incr iii} {
                array unset ::ixia::cfm_stats_returned_keyed_array_$iii
                array set ::ixia::cfm_stats_returned_keyed_array_$iii ""
            }
        }
        set ::ixia::cfm_stats_num_calls 0
        set ::ixia::cfm_stats_max_list_length  1900

        if {[info exists ::ixia::trunk_config_num_calls]} {
            for {set iii 0} {$iii < $::ixia::trunk_config_num_calls} {incr iii} {
                array unset ::ixia::trunks_returned_keyed_array_$iii
                array set ::ixia::trunks_returned_keyed_array_$iii ""
            }
        }
        set ::ixia::trunk_config_num_calls 0
        set ::ixia::trunks_max_list_length  1900
        
        if {[info exists ::ixia::mr_config_num_calls]} {
            for {set iii 0} {$iii < $::ixia::mr_config_num_calls} {incr iii} {
                array unset ::ixia::mr_returned_keyed_array_$iii
                array set ::ixia::mr_returned_keyed_array_$iii ""
            }
        }
        set ::ixia::mr_config_num_calls 0
        set ::ixia::mr_max_list_length  1900

        if {[info exists ::ixia::pbb_stats_num_calls]} {
            for {set iii 0} {$iii < $::ixia::pbb_stats_num_calls} {incr iii} {
                array unset ::ixia::pbb_stats_returned_keyed_array_$iii
                array set ::ixia::pbb_stats_returned_keyed_array_$iii ""
            }
        }
        set ::ixia::pbb_stats_num_calls 0
        set ::ixia::pbb_stats_max_list_length  1900
                        
        set ::ixia::internal_lacp_link_index 1
        set ::ixia::internal_lacp_lag_index  1
        if {[info exists ::ixia::internal_lacp_lag_settings_array]} {
            array unset ::ixia::internal_lacp_lag_settings_array
        }
        array set ::ixia::internal_lacp_lag_settings_array ""
        
        if {[info exists ::ixia::mep_handles_array]} {
            array unset ::ixia::mep_handles_array
        }
        
        if {[info exists ::ixia::cfm_vlan_handles_array]} {
            array unset ::ixia::cfm_vlan_handles_array
        }
        
        if {[info exists ::ixia::cfm_mdlevel_handles_array]} {
            array unset ::ixia::cfm_mdlevel_handles_array
        }
        
        if {[info exists ::ixia::cfm_message_handles_array]} {
            array unset ::ixia::cfm_message_handles_array
        }
        array set ::ixia::cfm_message_handles_array ""
        
        if {[info exists ::ixia::efm_global_counters]} {
            array unset ::ixia::efm_global_counters
        }
        array set ::ixia::efm_global_counters ""
        set ::ixia::efm_global_counters(organization_specific_info_tlv) 0
        set ::ixia::efm_global_counters(variable_descriptors)           0
        set ::ixia::efm_global_counters(variable_response_database)     0
        
        if {[info exists ::ixia::egress_tracking_global_array]} {
            array unset ::ixia::egress_tracking_global_array
        }
        array set ::ixia::egress_tracking_global_array ""
		
		if {[info exists ::ixia::dhcp_globals_params]} {
            array unset ::ixia::dhcp_globals_params
        }
        array set ::ixia::dhcp_globals_params        ""
		
		if {[info exists ::ixia::dhcp_options_params]} {
            array unset ::ixia::dhcp_options_params
        }
        array set ::ixia::dhcp_options_params        ""
        
        array set ::ixia::ixnetwork_async_operations_array ""
        
        # configure debug trace
        trace add variable ::ixia::debug write ::ixia::debugTrace
    }
    
    
    
    # Array updates_array contains updates applied on the current build
    # Special index
    #       ids => list of ids
    # Indexes for each hotfix
    #       $id,description => $description
    #       $id,files       => $list_of_affected_files
    # Each affected files will add itself to the list
    # It is the programmers job to add these entries in the hotfix files
    # Use the add_update_item and print_update_items procedures to add/print the items
    
    
    proc ::ixia::print_update_items {} {
        variable updates_array
        
        if {[catch {set update_items $updates_array(ids)} err]} {
            # No updates were applied
        } else {
            
            array set additional_keys {
                description         Description
                files               "Affected Files"
            }
            
            set first 1
            puts "\nThis HLT build contains the following UPDATES:"
            foreach update_item $update_items {
                
                puts "\t$update_item"
                
                foreach detail [array names additional_keys] {
                    if {![info exists updates_array($update_item,$detail)]} {
                        continue
                    }
                    
                    puts "\t\t$additional_keys($detail): $updates_array($update_item,$detail)"
                }
                puts "\t[string repeat "-" 40]"
            }
        }
    }


    proc ::ixia::add_update_item {args} {
        variable updates_array
        
        foreach {param value} $args {
            set param [string trimleft $param -]
            set $param $value
        }
        
        if {![info exists id]} {
            return
        }
        
        if {![info exists updates_array(ids)]} {
            set update_ids ""
        } else {
            set update_ids $updates_array(ids)
        }
        
        if {[lsearch $update_ids $id] == -1} {
            lappend updates_array(ids) $id 
        }
        
        if {[info exists description]} {
            set updates_array($id,description) $description
        }
        
        if {[info exists file_name]} {
            lappend updates_array($id,files) $file_name
            set updates_array($id,files) [lsort -unique $updates_array($id,files)]
        }
    }
    
    # Array hotfix_array contains hotfixes applied on the current build
    # Special index
    #       ids => list of ids
    # Indexes for each hotfix
    #       $id,description => $description
    #       $id,files       => $list_of_affected_files
    # Each affected files will add itself to the list
    # It is the programmers job to add these entries in the hotfix files
    # Use the add_hotfix_item and print_hotfix_items procedures to add/print the items
    
    
    proc ::ixia::print_hotfix_items {} {
        variable hotfix_array
        
        if {[catch {set hotfix_items $hotfix_array(ids)} err]} {
            # No hotfixes were applied
        } else {
            
            array set additional_keys {
                description         Description
                files               "Affected Files"
            }
            
            set first 1
            puts "\nThis HLT build contains the following HOTFIX items:"
            foreach hotfix_item $hotfix_items {
                
                puts "\t$hotfix_item"
                
                foreach detail [array names additional_keys] {
                    if {![info exists hotfix_array($hotfix_item,$detail)]} {
                        continue
                    }
                    
                    puts "\t\t$additional_keys($detail): $hotfix_array($hotfix_item,$detail)"
                }
                puts "\t[string repeat "-" 40]"
            }
        }
    }


    proc ::ixia::add_hotfix_item {args} {
        variable hotfix_array
        
        foreach {param value} $args {
            set param [string trimleft $param -]
            set $param $value
        }
        
        if {![info exists id]} {
            return
        }
        
        if {![info exists hotfix_array(ids)]} {
            set hotfix_ids ""
        } else {
            set hotfix_ids $hotfix_array(ids)
        }
        
        if {[lsearch $hotfix_ids $id] == -1} {
            lappend hotfix_array(ids) $id 
        }
        
        if {[info exists description]} {
            set hotfix_array($id,description) $description
        }
        
        if {[info exists file_name]} {
            lappend hotfix_array($id,files) $file_name
            set hotfix_array($id,files) [lsort -unique $hotfix_array($id,files)]
        }
    }
    
    variable ixloadVersion
    variable ixnetworkVersion
    variable hltVersion
    variable hltsetUsed
    variable ixaccessLoaded
    set ixaccessLoaded 0
    
    # This variable is 1 by default
    # When traffic_generator is ixnetwork and HLTSET is *P2NO, next gen traffic
    # will be used to configure traffic
    # To override this behavior (to use legacy traffic generator) set this variable
    # to 0
    variable forceNextGenTraffic
    
    variable chassisIdIndex

    # Set to 1 to have various debug messaged printed out during execution
    variable debug
    # Used for logging IxNetwork procedure calls to a file
    variable file_debug
    set file_debug 0

    # Default values
    variable utrackerEnable
    variable utrackerDefaultServer
    variable utrackerServer
    
    # Currently connected IxTclServer
    variable connected_tcl_srv

    if {![info exists ::env(IXIA_VERSION)]} {
        # User did not explicitly set the value, so we will default to the latest
        # set of products
        set index 1

        while {true} {; #find the latest HLTSET
            set default_hltset "HLTSET$index"
            if {![info exists ixiaHltVersions($default_hltset)]} {
                incr index -1; #the current hltset doesn't exist
                set default_hltset "HLTSET$index"
                break
            }
            incr index
        }
        
        foreach {hltVersion ixosVersion ixrouterVersion ixnetworkVersion \
                ixaccessVersion ixloadVersion} $ixiaHltVersions($default_hltset) {}
        if {[llength $hltVersion] > 1} {
            set hltVersion [lindex $hltVersion end]
        }
        if {[regexp {^[0-9]+.[0-9]+} $::ixia::hltapi_version] && \
                ($hltVersion != "[lindex [split $::ixia::hltapi_version .] 0].[lindex [split $::ixia::hltapi_version .] 1]")} {
            
            if {[catch {package ifneeded Ixia $hltVersion} needed_path] || $needed_path == ""} {
                puts "Package Ixia $hltVersion is not available"
                return 0
            }
            
            package forget Ixia
            
            package ifneeded Ixia $hltVersion $needed_path
            package require -exact Ixia $hltVersion
            return 1
        }
        puts "Using products based on $default_hltset"
        set hltsetUsed $default_hltset
    } else {
        if {[lsearch [array names ixiaHltVersions] $::env(IXIA_VERSION)] < 0} {
            # The ixia version is not one of the known name sets.  See if it is
            # valid for just an ixos version
            scan $::env(IXIA_VERSION) "%d.%d" major minor
            set found ""
            foreach name [lsort -dictionary [array names ixiaHltVersions]] {
                if {[info exists major] && [info exists minor]} {
                    if {[lindex $ixiaHltVersions($name) 1] == "$major.$minor" } {
                        set found $name
                    }
                }
            }
            set hltsetUsed $found
            if {$found == ""} {
                # No HLT data set name set or IxOS version set that is supported
                # so exit at this point of the package require
                puts stderr "IXIA_VERSION env variable is set but some software \
                        to match it's value is not present."
                return 1
            }
            foreach {hltVersion ixosVersion ixrouterVersion ixnetworkVersion \
                    ixaccessVersion ixloadVersion} $ixiaHltVersions($found) {}
            if {[llength $hltVersion] > 1} {
                set hltVersion [lindex $hltVersion end]
            }
            if {[regexp {^[0-9]+.[0-9]+} $::ixia::hltapi_version] && \
                    ($hltVersion != "[lindex [split $::ixia::hltapi_version .] 0].[lindex [split $::ixia::hltapi_version .] 1]")} {
                
                if {[catch {package ifneeded Ixia $hltVersion} needed_path] || $needed_path == ""} {
                    puts "Package Ixia $hltVersion is not available"
                    return 0
                }
                
                package forget Ixia
                
                package ifneeded Ixia $hltVersion $needed_path
                package require -exact Ixia $hltVersion
                return 1
            }
            puts "Using products based on $found"
        } else {
            foreach {hltVersion ixosVersion ixrouterVersion ixnetworkVersion \
                    ixaccessVersion ixloadVersion} \
                    $ixiaHltVersions($::env(IXIA_VERSION)) {}
            if {[llength $hltVersion] > 1} {
                set hltVersion [lindex $hltVersion end]
            }
            if {[regexp {^[0-9]+.[0-9]+} $::ixia::hltapi_version] && \
                    ($hltVersion != "[lindex [split $::ixia::hltapi_version .] 0].[lindex [split $::ixia::hltapi_version .] 1]")} {
                
                if {[catch {package ifneeded Ixia $hltVersion} needed_path] || $needed_path == ""} {
                    puts "Package Ixia $hltVersion is not available"
                    return 0
                }
                
                package forget Ixia
                
                package ifneeded Ixia $hltVersion $needed_path
                package require -exact Ixia $hltVersion
                return 1
            }
            set hltsetUsed $::env(IXIA_VERSION)
            puts "Using products based on: $::env(IXIA_VERSION)"
        }
    }

    set ::env(IXIA_VERSION) $ixosVersion

    # Try to package require IxTclHal which is for IxOS
    if {[catch {package require -exact IxTclHal $ixosVersion} err]} {
        puts "Failure to load Ixia package, the IxTclHal package failed to load.\n[set ::errorInfo]"
        return -code error -errorinfo "Error package requiring IxTclHal for\
                version $ixosVersion"
    } else {
        puts "Loaded IxTclHal $ixosVersion"
    }

    if {[catch {package require IxTclServices} err]} {
        puts "The IxTclServices $ixosVersion package failed to load.\
                You might not be able to run IxOS traffic over PPP sessions.\
                \n[set ::errorInfo]"
    } else {
        puts "Loaded IxTclServices $ixosVersion"
    }

    # These variables are used if the IxNetwork 5.30 API is used
    variable new_ixnetwork_api
    variable ixnetwork_tcl_server
    variable ixnetwork_tcl_server_reset
    variable ixnetwork_port_handles_array
    variable ixnetwork_port_handles_array_vport2rp
    variable ixnetwork_stream_ids
    variable no_more_tclhal
    variable loadProtOrNetw

    # Try to package require IxTclProtocol which is for either IxRouter or
    # IxNetwork or IxTclNetwork which is for IxNetwork
    set ::ixia::new_ixnetwork_api 0
    set ::ixia::no_more_tclhal    0
    set ::ixia::loadProtOrNetw    1
    if {$ixrouterVersion != "NA"} {
        if {$ixrouterVersion < 5.40} {
            set p_version_list [package versions IxTclProtocol]
            foreach p_version $p_version_list {
                if {[regexp "^[string trim ${ixrouterVersion} P](.*)$" $p_version str_ignore]} {
                    set ixrouterVersion $p_version
                    break;
                }
            }
            if {[catch {package require -exact IxTclProtocol $ixrouterVersion} err]} {
                puts "The IxTclProtocol $ixrouterVersion package failed to load"
                puts "[set ::errorInfo]"
            } else {
                puts "Loaded IxTclProtocol $ixrouterVersion"
            }
        } else {
            if {[catch {package require IxTclProtocol} err]} {
                puts "The IxTclProtocol $ixrouterVersion package failed to load"
                puts "[set ::errorInfo]"
            } else {
                if {"[lindex [split $err "."] 0].[lindex [split $err "."] 1]" == $ixrouterVersion} {
                    puts "Loaded IxTclProtocol $ixrouterVersion"
                } else {
                    puts "The IxTclProtocol $ixrouterVersion package failed to load"
                    puts "[set ::errorInfo]"
                }
            }
        }

        set ::ixia::loadProtOrNetw 0
        
    } elseif {$ixnetworkVersion != "NA"} {

        if {[regexp {^(\d+.\d+)(P|N|NO|P2NO)?$} $ixnetworkVersion {} version product]} {
            
            if {$product == "P2NO"} {
                set product_list [list P NO]
                # set product_list [list NO]
            } else {
                set product_list $product
            }
            
            foreach product $product_list {
                switch -- $product {
                    "P" {
                        
                        set ixtclprotocol_version [get_package_latest_version "IxTclProtocol" $version]
                        if {$ixtclprotocol_version == ""} {
                            puts "The IxTclProtocol $version package failed to load"
                        }
                        
                        # IxTclHal loads IxTclProtocol package too
                        # Check if the IxTclProtocol loaded is the same with the one we
                        #   want to load
                        if {![catch {package present IxTclProtocol} old_tp_ver]} {
                            if {![catch {package vcompare $old_tp_ver $ixtclprotocol_version} err] &&\
                                    $err != 0} {
                                catch {package forget -exact IxTclProtocol $old_tp_ver}
                            }
                        }
                        
                        if {[catch {package require -exact IxTclProtocol $ixtclprotocol_version} err]} {
                            puts "The IxTclProtocol $ixtclprotocol_version package failed to load"
                            if {[llength $ixtclprotocol_version] > 0} {
                                puts "[set ::errorInfo]"
                            }
                        } else {
                            set ::ixia::new_ixnetwork_api 0
                            puts "Loaded IxTclProtocol $ixtclprotocol_version"
                        }
                    }
                    "N" {
                        if {$version < "5.30"} {
                            puts "The IxTclNetwork $version package failed to load"
                            puts "[set ::errorInfo]"
                        } elseif {$version == "5.30"} {
                            if {[catch {package require -exact IxTclNetwork $version} err]} {
                                puts "The IxTclNetwork $version package failed to load"
                                puts "[set ::errorInfo]"
                            } else {
                                set ::ixia::new_ixnetwork_api 1
                                
                                if {!$file_debug} {
                                    ixNet setSessionParameter logFile none
                                }
                                puts "Loaded IxTclNetwork $version"
                            }
                        } else {
                            # Version > 5.30
                            
                            set ixtclnetwork_version [get_package_latest_version "IxTclNetwork" $version]
                            if {$ixtclnetwork_version == ""} {
                                puts "The IxTclNetwork $version package failed to load"
                            }
                            
                            if {[catch {package require -exact IxTclNetwork $ixtclnetwork_version} err]} {
                                puts "The IxTclNetwork $ixtclnetwork_version package failed to load"
                                puts "[set ::errorInfo]"
                            } else {
                                if {"[lindex [split $err "."] 0].[lindex [split $err "."] 1]" == $version} {
                                    set ::ixia::new_ixnetwork_api 1
                                    
                                    if {!$file_debug} {
                                        ixNet setSessionParameter logFile none
                                    }
                                    puts "Loaded IxTclNetwork $ixtclnetwork_version"
                                } else {
                                    puts "The IxTclNetwork $ixtclnetwork_version package failed to load"
                                    puts "[set ::errorInfo]"
                                }
                            }
                        }
                    }
                    default {
                        
                        # NO
                        # Load ixnetwork tcl api
                        
                        set ::ixia::no_more_tclhal 1
                        
                        if {$version < "5.30"} {
                            puts "The IxTclNetwork $version package failed to load"
                            puts "[set ::errorInfo]"
                        } elseif {$version == "5.30"} {
                            if {[catch {package require -exact IxTclNetwork $version} err]} {
                                puts "The IxTclNetwork $version package failed to load"
                                puts "[set ::errorInfo]"
                            } else {
                                set ::ixia::new_ixnetwork_api 1
                                
                                if {!$file_debug} {
                                    ixNet setSessionParameter logFile none
                                }
                                puts "Loaded IxTclNetwork $version"
                            }
                        } else {
                            # Version > 5.30
                            set ixtclnetwork_version [get_package_latest_version "IxTclNetwork" $version]
                            if {$ixtclnetwork_version == ""} {
                                puts "The IxTclNetwork $version package failed to load"
                            }
                            
                            if {[catch {package require -exact IxTclNetwork $ixtclnetwork_version} err]} {
                                puts "The IxTclNetwork $ixtclnetwork_version package failed to load"
                                puts "[set ::errorInfo]"
                            } else {
                                if {"[lindex [split $err "."] 0].[lindex [split $err "."] 1]" == $version} {
                                    set ::ixia::new_ixnetwork_api 1
                                    
                                    if {!$file_debug} {
                                        ixNet setSessionParameter logFile none
                                    }
                                    puts "Loaded IxTclNetwork $ixtclnetwork_version"
                                } else {
                                    puts "The IxTclNetwork $ixtclnetwork_version package failed to load"
                                    puts "[set ::errorInfo]"
                                }
                            }
                        }
                    }
                }
            }
            
            if {[llength $product_list] == 1} {
                # This was not P2NO
                set ::ixia::loadProtOrNetw 0
            }
        }
    }

    # Try to package require IxAccess
    if {$ixaccessVersion != "NA"} {
        if {[catch {package require -exact IxTclAccess $ixaccessVersion} err]} {
            puts "The IxTclAccess $ixaccessVersion package failed to load"
            puts "[set ::errorInfo]"
        } else {
            if {[catch {package require IxAccessGUI} retValue]} {
                puts "Loaded IxAccessGUI $ixaccessVersion ..."
            } else {
                puts "Loaded IxAccessGUI $ixaccessVersion"
            }
            puts "Loaded IxTclAccess $ixaccessVersion"
            set ixaccessLoaded 1
        }
    }

    if {[isUNIX]} {
        if { $ixloadVersion <= 3.00 } {
            set ixloadVersion 1.0
        }
    }

    variable used_port_list
    variable reserved_port_list
    variable emulation_handles_array
    variable ixnetwork_emulation_handles_array
    variable hltapi_version
    variable ixtclhal_version
    variable igmp_port
    variable igmp_counters
    variable aPortState

    if {[info exists pim_counters]} {
        unset    pim_counters
    }
    variable pim_counters

    variable ixaccess_traffic_ports
    variable current_streamid
    variable current_intf
    variable pgid_to_stream
    variable no_of_streams_per_port
    variable port_handles_write_config
    variable port_handles_write_ports
    variable bgp_neighbor_handles_array
    variable bgp_route_handles_array
    variable bgp_handle_index
    variable bgp_neig_intf_map
    variable igmp_attributes_array
    variable igmp_host_ip_handles_array
    variable igmp_host_handles_array
    variable igmp_group_handles_array
    variable isis_handles_array
    variable ldp_handles_array
    variable multicast_group_array
    variable multicast_source_array
    variable multicast_group_ip_to_handle
    variable multicast_source_ip_to_handle
    variable mld_handles_array
    variable mld_group_ranges_array
    variable ospf_handles_array
    variable pimsm_handles_array
    variable rip_router_handles_array
    variable rip_route_handles_array
    variable rsvp_handles_array
    variable l2tpv3_cc_handles_array
    variable l2tpv3_session_handles_array
    variable protocol_interfaces_mac_address
    variable atmStatsConfig
    variable dhcpv6_groups_list
    variable dhcpv6_groups_index
    variable dhcpv6_settings_list
    variable dhcpv6_settings_index
    variable dhcpv6_subport_index_array
    variable stream_to_queue_map
    variable port_queue_num

    variable chassis_list
    variable ixnetwork_chassis_list
    variable ixload_chassis_list
    variable connect_timeout
    
    variable ::ixia::oampdu_counters

    variable truth
    array set truth [list   \
            1      true     \
            0      false    \
            ]

    # These are the parameters that are being kept in the protocol_interfaces
    # array in order to keep track of the protocol interfaces created
    # NOTE: If a new parameter needs to be added it should be added here also.
    variable cmdProtIntfParamsList
    set cmdProtIntfParamsList [list  \
            port_handle      \
            description      \
            type             \
            ipv4_address     \
            ipv4_mask        \
            ipv4_gateway     \
            ipv4_dst_address \
            ipv6_address     \
            ipv6_mask        \
            vlan_id          \
            vlan_priority    \
            mac_address      \
            atm_encap        \
            atm_vpi          \
            atm_vci          \
            dhcp_enable      \
            ipv6_gateway     \
            ixnetwork_objref \
            ]

    # These are the positions of the parameters that are being kept in the
    # protocol_interfaces array indices
    # NOTE: If a new parameter needs to be added it should be added here also.
    variable cmdProtIntfParamsPositions
    array set cmdProtIntfParamsPositions [list \
            port_handle      0    \
            description      1    \
            type             2    \
            ipv4_address     3    \
            ipv4_mask        4    \
            ipv4_gateway     5    \
            ipv4_dst_address 6    \
            ipv6_address     7    \
            ipv6_mask        8    \
            vlan_id          9    \
            vlan_priority    10   \
            mac_address      11   \
            atm_encap        12   \
            atm_vpi          13   \
            atm_vci          14   \
            dhcp_enable      15   \
            ipv6_gateway     16   \
            ixnetwork_objref 17   \
            ]
    
    # Variable used for determining if a port is an ethernet port or not for RAW traffic creation
    variable ixNetworkEthernetPortTypes
    set ixNetworkEthernetPortTypes {
        ethernet
		ethernetvm
        ethernetFcoe
        tenGigLan
        tenGigLanFcoe
        tenGigWan
        tenGigWanFcoe
        fortyGigLan
        fortyGigLanFcoe
        hundredGigLan
        tenFortyHundredGigLan
        tenFortyHundredGigLanFcoe
    }
    
    # Variable used by ::ixia::portSupports to determine port cababilities
    variable port_supports_types

    ##### ixLoad support
    #

    variable temporary_fix_122311
    variable ixload_chassis_chain
    variable ixload_tcl_server
    variable ixload_cardtype_array
    variable ixload_handles_count
    variable ixload_handles_array
    
    variable temporary_fix_122311

    variable ixload_telnet_client_stats
    array set ixload_telnet_client_stats {
        telnet_active_conn
        "Telnet Active Connections"
        telnet_total_conn_requested
        "Telnet Total Connections Requested"
        telnet_total_conn_succeeded
        "Telnet Total Connections Succeeded"
        telnet_total_conn_failed
        "Telnet Total Connections Failed"
        telnet_total_conn_latency
        "Telnet Total Connections Latency"
        telnet_total_sessions_completed
        "Telnet Total Sessions Completed"
        telnet_total_sessions_not_completed
        "Telnet Total Sessions Not Completed"
        telnet_average_session_length
        "Telnet Average Session Length"
        telnet_total_login_prompts_received
        "Telnet Total Login Prompts Received"
        telnet_total_login_prompts_not_received
        "Telnet Total Login Prompts Not Received"
        telnet_total_password_prompts_received
        "Telnet Total Password Prompts Received"
        telnet_total_password_prompts_not_received
        "Telnet Total Password Prompts Not Received"
        telnet_total_logins_succeeded
        "Telnet Total Logins Succeeded"
        telnet_total_logins_failed
        "Telnet Total Logins Failed"
        telnet_total_logins_failed_timeout
        "Telnet Total Logins Failed (Timed Out)"
        telnet_total_logins_failed_other
        "Telnet Total Logins Failed (Other)"
        telnet_total_transactions
        "Telnet Total Transactions"
        telnet_total_commands_sent
        "Telnet Total Commands Sent"
        telnet_total_commands_succeeded
        "Telnet Total Commands Succeeded"
        telnet_total_commands_failed
        "Telnet Total Commands Failed"
        telnet_total_commands_failed_timeout
        "Telnet Total Commands Failed (Timed Out)"
        telnet_total_commands_failed_other
        "Telnet Total Commands Failed (Other)"
        telnet_total_bytes_sent
        "Telnet Total Bytes Sent"
        telnet_total_bytes_received
        "Telnet Total Bytes Received"
        telnet_total_bytes_sent_and_received
        "Telnet Total Bytes Sent And Received"
        telnet_total_echo_options_received
        "Telnet Total Echo Options Do Received"
        telnet_total_echo_options_not_received
        "Telnet Total Echo Options Dont Received"
        telnet_total_echo_options_will_received
        "Telnet Total Echo Options Will Received"
        telnet_total_echo_options_wont_received
        "Telnet Total Echo Options Wont Received"
        telnet_total_echo_options_do_sent
        "Telnet Total Echo Options Do Sent"
        telnet_total_echo_options_dont_sent
        "Telnet Total Echo Options Dont Sent"
        telnet_total_echo_options_will_sent
        "Telnet Total Echo Options Will Sent"
        telnet_total_echo_options_wont_sent
        "Telnet Total Echo Options Wont Sent"
        telnet_total_suppress_goahead_do_received
        "Telnet Total Suppress Go Ahead Options Do Received"
        telnet_total_suppress_goahead_dont_received
        "Telnet Total Suppress Go Ahead Options Dont Received"
        telnet_total_suppress_goahead_will_received
        "Telnet Total Suppress Go Ahead Options Will Received"
        telnet_total_suppress_goahead_wont_received
        "Telnet Total Suppress Go Ahead Options Wont Received"
        telnet_total_suppress_goahead_do_sent
        "Telnet Total Suppress Go Ahead Options Do Sent"
        telnet_total_suppress_goahead_dont_sent
        "Telnet Total Suppress Go Ahead Options Dont Sent"
        telnet_total_suppress_goahead_will_sent
        "TelnetTotal Suppress Go Ahead Options Will Sent"
        telnet_total_suppress_goahead_wont_sent
        "Telnet Total Suppress Go Ahead Options Wont Sent"
        telnet_total_line_mode_options_do_received
        "Telnet Total Line Mode Options Do Received"
        telnet_total_line_mode_options_dont_received
        "Telnet Total Line Mode Options Dont Received"
        telnet_total_line_mode_options_will_received
        "Telnet Total Line Mode Options Will Received"
        telnet_total_line_mode_options_wont_received
        "Telnet Total Line Mode Options Wont Received"
        telnet_total_line_mode_options_do_sent
        "Telnet Total Line Mode Options Do Sent"
        telnet_total_line_mode_options_dont_sent
        "Telnet Total Line Mode Options Dont Sent"
        telnet_total_line_mode_options_will_sent
        "Telnet Total Line Mode Options Will Sent"
        telnet_total_line_mode_options_wont_sent
        "Telnet Total Line Mode Options Wont Sent"
        telnet_total_suboptions_received
        "Telnet Total Suboptions Received"
        telnet_total_suboptions_sent
        "Telnet Total Suboptions Sent"
        telnet_total_line_mode_suboptions_em_received
        "Telnet Total Line Mode Suboptions Edit Mask Received"
        telnet_total_line_mode_suboptions_em_sent
        "Telnet Total Line Mode Suboptions Edit Mask Sent"
        simulated_users
        "Simulated Users"
        concurrent_connections
        "Concurrent Connections"
        connection_rate
        "Connection Rate"
        transaction_rate
        "Transaction Rate"
    }

    variable ixload_telnet_server_stats
    array set ixload_telnet_server_stats {
        telnet_active_conn
        "Telnet Active Connections"
        telnet_total_accepted_conn
        "Telnet Total Accepted Connections"
        telnet_login_prompts_sent
        "Telnet Login Prompts Sent"
        telnet_usernames_succeeded
        "Telnet UserNames Succeeded"
        telnet_usernames_failed
        "Telnet UserNames Failed"
        telnet_usernames_failed_timeout
        "Telnet UserNames Failed (Timed Out)"
        telnet_usernames_failed_other
        "Telnet UserNames Failed (Other)"
        telnet_password_prompts_sent
        "Telnet Password Prompts Sent"
        telnet_passwords_succeeded
        "Telnet Passwords Succeeded"
        telnet_passwords_failed
        "Telnet Passwords Failed"
        telnet_passwords_failed_timeout
        "Telnet Passwords Failed (Timed Out)"
        telnet_passwords_failed_other
        "Telnet Passwords Failed (Other)"
        telnet_logins_succeeded
        "Telnet Logins Succeeded"
        telnet_logins_failed
        "Telnet Logins Failed"
        telnet_commands_processed
        "Telnet Commands Processed"
        telnet_total_bytes_sent
        "Telnet Total Bytes Sent"
        telnet_total_bytes_received
        "Telnet Total Bytes Received"
        telnet_total_bytes_sent_and_received
        "Telnet Total Bytes Sent And Received"
        telnet_option_negotiation_failed
        "Telnet Option Negotiation Failed"
        telnet_option_negociation_failed_timeout
        "Telnet Option Negotiation Failed (Timed Out)"
        telnet_option_negociation_failed_other
        "Telnet Option Negotiation Failed (Other)"
        telnet_suboption_negociation_failed
        "Telnet Suboption Negotiation Failed"
        telnet_suboption_negociation_failed_timeout
        "Telnet Suboption Negotiation Failed (Timed Out)"
        telnet_suboption_negociation_failed_other
        "Telnet Suboption Negotiation Failed (Other)"
        telnet_echo_options_do_sent
        "Telnet Echo Options DO Sent"
        telnet_echo_options_will_sent
        "Telnet Echo Options WILL Sent"
        telnet_echo_options_dont_sent
        "Telnet Echo Options DONT Sent"
        telnet_echo_options_wont_sent
        "Telnet Echo Options WONT Sent"
        telnet_echo_options_do_received
        "Telnet Echo Options DO Received"
        telnet_echo_options_will_received
        "Telnet Echo Options WILL Received"
        telnet_echo_options_dont_received
        "Telnet Echo Options DONT Received"
        telnet_echo_options_wont_received
        "Telnet Echo Options WONT Received"
        telnet_ga_suppress_options_do_sent
        "Telnet GA Suppress Options DO Sent"
        telnet_ga_suppress_options_will_sent
        "Telnet GA Suppress Options WILL Sent"
        telnet_ga_suppress_options_dont_sent
        "Telnet GA Suppress Options DONT Sent"
        telnet_ga_suppress_options_wont_sent
        "Telnet GA Suppress Options WONT Sent"
        telnet_ga_suppress_options_do_received
        "Telnet GA Suppress Options DO Received"
        telnet_ga_suppress_options_will_received
        "Telnet GA Suppress Options WILL Received"
        telnet_ga_suppress_options_dont_received
        "Telnet GA Suppress Options DONT Received"
        telnet_ga_suppress_options_wont_received
        "Telnet GA Suppress Options WONT Received"
        telnet_linemode_options_do_sent
        "Telnet Line-mode Options DO Sent"
        telnet_linemode_options_will_sent
        "Telnet Line-mode Options WILL Sent"
        telnet_linemode_options_dont_sent
        "Telnet Line-mode Options DONT Sent"
        telnet_linemode_options_wont_sent
        "Telnet Line-mode Options WONT Sent"
        telnet_linemode_options_do_received
        "Telnet Line-mode Options DO Received"
        telnet_linemode_options_will_received
        "Telnet Line-mode Options WILL Received"
        telnet_linemode_options_dont_received
        "Telnet Line-mode Options DONT Received"
        telnet_linemode_options_wont_received
        "Telnet Line-mode Options WONT Received"
    }

    variable ixload_ftp_client_stats
    array set ixload_ftp_client_stats {
        ftp_simulated_users
        "FTP Simulated Users"
        ftp_concurrent_sessions
        "FTP Concurrent Sessions"
        ftp_connections
        "FTP Connections"
        ftp_transactions
        "FTP Transactions"
        ftp_bytes
        "FTP Bytes"
        ftp_control_conn_requested
        "FTP Control Conn Requested"
        ftp_control_conn_established
        "FTP Control Conn Established"
        ftp_control_conn_failed
        "FTP Control Conn Failed"
        ftp_control_conn_failed_rejected
        "FTP Control Conn Failed (Rejected)"
        ftp_control_conn_failed_other
        "FTP Control Conn Failed (Other)"
        ftp_control_conn_active
        "FTP Control Conn Active"
        ftp_data_conn_established
        "FTP Data Conn Established"
        ftp_data_conn_established_active_mode
        "FTP Data Conn Established (Active Mode)"
        ftp_data_conn_requested_passive_mode
        "FTP Data Conn Requested (Passive Mode)"
        ftp_data_conn_established_passive_mode
        "FTP Data Conn Established (Passive Mode)"
        ftp_data_conn_failed_passive_mode
        "FTP Data Conn Failed (Passive Mode)"
        ftp_file_uploads_requested
        "FTP File Uploads Requested"
        ftp_file_uploads_successful
        "FTP File Uploads Successful"
        ftp_file_uploads_failed
        "FTP File Uploads Failed"
        ftp_file_downloads_requested
        "FTP File Downloads Requested"
        ftp_file_downloads_successful
        "FTP File Downloads Successful"
        ftp_file_downloads_failed
        "FTP File Downloads Failed"
        ftp_data_bytes_sent
        "FTP Data Bytes Sent"
        ftp_data_bytes_received
        "FTP Data Bytes Received"
        ftp_control_bytes_sent
        "FTP Control Bytes Sent"
        ftp_control_bytes_received
        "FTP Control Bytes Received"
        ftp_control_connection_latency
        "FTP Control Connection Latency (ms)"
        ftp_data_connection_latency_passive_mode
        "FTP Data Connection Latency (Passive Mode) (ms)"
        ftp_data_conn_active
        "FTP Data Conn Active"
        ftp_connection_rate
        "FTP Connections"
        ftp_transaction_rate
        "FTP Transactions"
        ftp_throughput
        "FTP Bytes"
    }

    variable ixload_ftp_server_stats
    array set ixload_ftp_server_stats {
        ftp_control_conn_received
        "FTP Control Conn Received"
        ftp_control_conn_established
        "FTP Control Conn Established"
        ftp_control_conn_rejected
        "FTP Control Conn Rejected"
        ftp_control_conn_active
        "FTP Control Conn Active"
        ftp_data_conn_established
        "FTP Data Conn Established"
        ftp_data_conn_requested_active
        "FTP Data Conn Requested (Active Mode)"
        ftp_data_conn_established_active
        "FTP Data Conn Established (Active Mode)"
        ftp_data_conn_failed_active
        "FTP Data Conn Failed (Active Mode)"
        ftp_data_conn_established_passive
        "FTP Data Conn Established (Passive Mode)"
        ftp_data_conn_active
        "FTP Data Conn Active"
        ftp_file_uploads_requested
        "FTP File Uploads Requested"
        ftp_file_uploads_successful
        "FTP File Uploads Successful"
        ftp_file_uploads_failed
        "FTP File Uploads Failed"
        ftp_file_downloads_requested
        "FTP File Downloads Requested"
        ftp_file_downloads_successful
        "FTP File Downloads Successful"
        ftp_file_downloads_failed
        "FTP File Downloads Failed"
        ftp_data_bytes_sent
        "FTP Data Bytes Sent"
        ftp_data_bytes_received
        "FTP Data Bytes Received"
        ftp_control_bytes_sent
        "FTP Control Bytes Sent"
        ftp_control_bytes_received
        "FTP Control Bytes Received"
        ftp_data_conn_latency
        "FTP Data Connection Latency (Active Mode) (ms)"
    }

    variable ixload_http_client_stats
    array set ixload_http_client_stats {
        http_simulated_users
        "HTTP Simulated Users"
        http_concurrent_connections
        "HTTP Concurrent Connections"
        http_connections
        "HTTP Connections"
        http_transactions
        "HTTP Transactions"
        http_bytes
        "HTTP Bytes"
        http_requests_sent
        "HTTP Requests Sent"
        http_requests_successful
        "HTTP Requests Successful"
        http_requests_failed
        "HTTP Requests Failed"
        http_requests_failed_write
        "HTTP Requests Failed (Write)"
        http_requests_failed_read
        "HTTP Requests Failed (Read)"
        http_requests_failed_bad_header
        "HTTP Requests Failed (Bad Header)"
        http_requests_failed_4xx
        "HTTP Requests Failed (4xx)"
        http_requests_failed_400
        "HTTP Requests Failed (400)"
        http_requests_failed_401
        "HTTP Requests Failed (401)"
        http_requests_failed_403
        "HTTP Requests Failed (403)"
        http_requests_failed_404
        "HTTP Requests Failed (404)"
        http_requests_failed_408
        "HTTP Requests Failed (408)"
        http_requests_failed_4xx_other
        "HTTP Requests Failed (4xx other)"
        http_requests_failed_5xx
        "HTTP Requests Failed (5xx)"
        http_requests_failed_505
        "HTTP Requests Failed (505)"
        http_requests_failed_5xx_other
        "HTTP Requests Failed (5xx other)"
        http_requests_failed_timeout
        "HTTP Requests Failed (Timeout)"
        http_requests_failed_aborted
        "HTTP Requests Failed (Aborted)"
        http_requests_timeouts
        "HTTP Session Timeouts (408)"
        http_sessions_rejected
        "HTTP Sessions Rejected (503)"
        http_transactions
        "HTTP Transactions Active"
        http_users_active
        "HTTP Users Active"
        http_bytes_sent
        "HTTP Bytes Sent"
        http_bytes_received
        "HTTP Bytes Received"
        http_cookies_received
        "HTTP Cookies Received"
        http_cookies_sent
        "HTTP Cookies Sent"
        http_cookies_rejected
        "HTTP Cookies Rejected"
        http_cookies_rejected_path
        "HTTP Cookies Rejected - (Path Match Failed)"
        http_cookies_rejected_domain
        "HTTP Cookies Rejected - (Domain Match Failed)"
        http_cookies_rejected_overflow
        "HTTP Cookies Rejected - (Cookiejar Overflow)"
        http_cookies_rejected_probabilistic
        "HTTP Cookies Rejected - (Probabilistic Reject)"
        http_connect_time
        "HTTP Connect Time (ms)"
        http_time_first_byte
        "HTTP Time To First Byte (ms)"
        http_time_last_byte
        "HTTP Time To Last Byte (ms)"
        http_aborted_before_request
        "HTTP Aborted Before Request"
        http_aborted_after_request
        "HTTP Aborted After Request"
        http_content_bytes_sent
        "HTTP Content Bytes Sent"
        http_cookie_headers_rejected
        "HTTP Cookie headers Rejected - (Memory Overflow)"
        http_responses_received_with_match
        "HTTP Responses Received With Match"
        http_responses_received_without_match
        "HTTP Responses Received Without Match"
    }

    variable ixload_http_server_stats
    array set ixload_http_server_stats {
        http_requests_received
        "HTTP Requests Received"
        http_requests_successful
        "HTTP Requests Successful"
        http_requests_failed
        "HTTP Requests Failed"
        http_requests_failed_404
        "HTTP Requests Failed (404)"
        http_requests_failed_50x
        "HTTP Requests Failed (50x)"
        http_requests_failed_write
        "HTTP Requests Failed (Write Error)"
        http_sessions_rejected
        "HTTP Sessions Rejected (503)"
        http_session_timeouts
        "HTTP Session Timeouts (408)"
        http_transactions_active
        "HTTP Transactions Active"
        http_bytes_received
        "HTTP Bytes Received"
        http_bytes_sent
        "HTTP Bytes Sent"
        http_cookies_received
        "HTTP Cookies Received"
        http_cookies_sent
        "HTTP Cookies Sent"
        http_cookies_match
        "HTTP Cookies Received With Matching ServerID"
        http_cookies_non_match
        "HTTP Cookies Received With Non-matching ServerID"
        http_content_bytes_received
        "HTTP Content Bytes Received"
        http_content_bytes_sent
        "HTTP Content Bytes Sent"
    }
    
    variable ixload_sip_client_stats
    array set ixload_sip_client_stats {
        sip_simulated_users
        "SIP Simulated Users"
        sip_calls_initiated
        "SIP calls initiated"
        sip_calls_initiated_per_s
        "SIP calls initiated/s"
        sip_calls_completed
        "SIP calls completed"
        sip_calls_completed_per_s
        "SIP calls completed/s"
        sip_calls_active
        "SIP calls active"
        sip_invite_client_transactions_initiated
        "SIP INVITE client transactions initiated"
        sip_invite_client_transactions_initiated_per_s
        "SIP INVITE client transactions initiated/s"
        sip_invite_client_transactions_succeded
        "SIP INVITE client transactions succeded"
        sip_invite_client_transactions_succeded_per_s
        "SIP INVITE client transactions succeded/s"
        sip_invite_client_transactions_failed
        "SIP INVITE client transactions failed"
        sip_invite_client_transactions_failed_per_s
        "SIP INVITE client transactions failed/s"
        sip_invite_client_transactions_failed_timer_b_
        "SIP INVITE client transactions failed (TIMER B)"
        sip_invite_client_transactions_failed_timer_b_per_s
        "SIP INVITE client transactions failed (TIMER B)/s"
        sip_invite_client_transactions_failed_transport_error_per_s
        "SIP INVITE client transactions failed (TRANSPORT ERROR)/s"
        sip_invite_client_transactions_failed_transaction_timeout_timer_
        "SIP INVITE client transactions failed (TRANSACTION TIMEOUT TIMER)"
        sip_invite_client_transactions_failed_transaction_timeout_timer_per_s
        "SIP INVITE client transactions failed (TRANSACTION TIMEOUT TIMER)/s"
        sip_invite_client_transactions_failed_5xx_
        "SIP INVITE client transactions failed (5xx)"
        sip_invite_client_transactions_failed_5xx_per_s
        "SIP INVITE client transactions failed (5xx)/s"
        sip_non-invite_client_transactions_initiated
        "SIP NON-INVITE client transactions initiated"
        sip_non-invite_client_transactions_initiated_per_s
        "SIP NON-INVITE client transactions initiated/s"
        sip_non-invite_client_transactions_succeded
        "SIP NON-INVITE client transactions succeded"
        sip_non-invite_client_transactions_succeded_per_s
        "SIP NON-INVITE client transactions succeded/s"
        sip_non-invite_client_transactions_failed
        "SIP NON-INVITE client transactions failed"
        sip_non-invite_client_transactions_failed_per_s
        "SIP NON-INVITE client transactions failed/s"
        sip_non-invite_client_transactions_failed_timer_f_
        "SIP NON-INVITE client transactions failed (TIMER F)"
        sip_non-invite_client_transactions_failed_timer_f_per_s
        "SIP NON-INVITE client transactions failed (TIMER F)/s"
        sip_non-invite_client_transactions_failed_transport_error_
        "SIP NON-INVITE client transactions failed (TRANSPORT ERROR)"
        sip_non-invite_client_transactions_failed_transport_error_per_s
        "SIP NON-INVITE client transactions failed (TRANSPORT ERROR)/s"
        sip_invite_requests_sent
        "SIP INVITE requests sent"
        sip_invite_requests_sent_per_s
        "SIP INVITE requests sent/s"
        sip_ack_requests_sent
        "SIP ACK requests sent"
        sip_ack_requests_sent_per_s
        "SIP ACK requests sent/s"
        sip_bye_requests_sent
        "SIP BYE requests sent"
        sip_bye_requests_sent_per_s
        "SIP BYE requests sent/s"
        sip_register_requests_sent
        "SIP REGISTER requests sent"
        sip_register_requests_sent_per_s
        "SIP REGISTER requests sent/s"
        sip_invite_messages_retransmitted
        "SIP INVITE messages retransmitted"
        sip_invite_messages_retransmitted_per_s
        "SIP INVITE messages retransmitted/s"
        sip_non-invite_requests_retransmitted
        "SIP NON-INVITE requests retransmitted"
        sip_non-invite_requests_retransmitted_per_s
        "SIP NON-INVITE requests retransmitted/s"
        sip_invite_requests_unexpected
        "SIP INVITE requests unexpected"
        sip_invite_requests_unexpected_per_s
        "SIP INVITE requests unexpected/s"
        sip_ack_requests_unexpected
        "SIP ACK requests unexpected"
        sip_ack_requests_unexpected_per_s
        "SIP ACK requests unexpected/s"
        sip_bye_requests_unexpected
        "SIP BYE requests unexpected"
        sip_bye_requests_unexpected_per_s
        "SIP BYE requests unexpected/s"
        sip_cancel_requests_unexpected
        "SIP CANCEL requests unexpected"
        sip_cancel_requests_unexpected_per_s
        "SIP CANCEL requests unexpected/s"
        sip_unknown_messages_unexpected
        "SIP UNKNOWN messages unexpected"
        sip_unknown_messages_unexpected_per_s
        "SIP UNKNOWN messages unexpected/s"
        sip_unknown_requests_unexpected
        "SIP UNKNOWN requests unexpected"
        sip_unknown_requests_unexpected_per_s
        "SIP UNKNOWN requests unexpected/s"
        sip_1xx_responses_expected
        "SIP 1xx responses expected"
        sip_1xx_responses_received_per_s
        "SIP 1xx responses received/s"
        sip_1xx_responses_unexpected
        "SIP 1xx responses unexpected"
        sip_1xx_responses_unexpected_per_s
        "SIP 1xx responses unexpected/s"
        sip_2xx_responses_expected
        "SIP 2xx responses expected"
        sip_2xx_responses_received_per_s
        "SIP 2xx responses received/s"
        sip_2xx_responses_unexpected
        "SIP 2xx responses unexpected"
        sip_2xx_responses_unexpected_per_s
        "SIP 2xx responses unexpected/s"
        sip_3xx_responses_expected
        "SIP 3xx responses expected"
        sip_3xx_responses_received_per_s
        "SIP 3xx responses received/s"
        sip_3xx_responses_unexpected
        "SIP 3xx responses unexpected"
        sip_3xx_responses_unexpected_per_s
        "SIP 3xx responses unexpected/s"
        sip_4xx_responses_expected
        "SIP 4xx responses expected"
        sip_4xx_responses_received_per_s
        "SIP 4xx responses received/s"
        sip_4xx_responses_unexpected
        "SIP 4xx responses unexpected"
        sip_4xx_responses_unexpected_per_s
        "SIP 4xx responses unexpected/s"
        sip_5xx_responses_expected
        "SIP 5xx responses expected"
        sip_5xx_responses_received_per_s
        "SIP 5xx responses received/s"
        sip_5xx_responses_unexpected
        "SIP 5xx responses unexpected"
        sip_5xx_responses_unexpected_per_s
        "SIP 5xx responses unexpected/s"
        sip_6xx_responses_expected
        "SIP 6xx responses expected"
        sip_6xx_responses_received_per_s
        "SIP 6xx responses received/s"
        sip_6xx_responses_unexpected
        "SIP 6xx responses unexpected"
        sip_6xx_responses_unexpected_per_s
        "SIP 6xx responses unexpected/s"
    }

    variable ixload_sip_server_stats
    array set ixload_sip_server_stats {
        sip_calls_received
        "SIP calls received"
        sip_calls_received_per_s
        "SIP calls received/s"
        sip_calls_completed
        "SIP calls completed"
        sip_calls_completed_per_s
        "SIP calls completed/s"
        sip_calls_active
        "SIP calls active"
        sip_invite_server_transactions_received
        "SIP INVITE server transactions received"
        sip_invite_server_transactions_received_per_s
        "SIP INVITE server transactions received/s"
        sip_invite_server_transactions_succeded
        "SIP INVITE server transactions succeded"
        sip_invite_server_transactions_succeded_per_s
        "SIP INVITE server transactions succeded/s"
        sip_invite_server_transactions_failed
        "SIP INVITE server transactions failed"
        sip_invite_server_transactions_failed_per_s
        "SIP INVITE server transactions failed/s"
        sip_invite_server_transactions_failed_timer_h_
        "SIP INVITE server transactions failed (TIMER H)"
        sip_invite_server_transactions_failed_timer_h_per_s
        "SIP INVITE server transactions failed (TIMER H)/s"
        sip_invite_server_transactions_failed_transport_error_
        "SIP INVITE server transactions failed (TRANSPORT ERROR)"
        sip_invite_server_transactions_failed_transport_error_per_s
        "SIP INVITE server transactions failed (TRANSPORT ERROR)/s"
        sip_non-invite_server_transactions_received
        "SIP NON-INVITE server transactions received"
        sip_non-invite_server_transactions_received_per_s
        "SIP NON-INVITE server transactions received/s"
        sip_non-invite_server_transactions_succeded
        "SIP NON-INVITE server transactions succeded"
        sip_non-invite_server_transactions_succeded_per_s
        "SIP NON-INVITE server transactions succeded/s"
        sip_non-invite_server_transactions_failed
        "SIP NON-INVITE server transactions failed"
        sip_non-invite_server_transactions_failed_per_s
        "SIP NON-INVITE server transactions failed/s"
        sip_non-invite_requests_retransmitted
        "SIP NON-INVITE requests retransmitted"
        sip_non-invite_requests_retransmitted_per_s
        "SIP NON-INVITE requests retransmitted/s"
        sip_register_requests_sent
        "SIP REGISTER Requests sent"
        sip_register_requests_sent_per_s
        "SIP REGISTER Requests sent/s"
        sip_1xx_responses_expected
        "SIP 1xx responses expected"
        sip_1xx_responses_expected_per_s
        "SIP 1xx responses expected/s"
        sip_2xx_responses_expected
        "SIP 2xx responses expected"
        sip_2xx_responses_expected_per_s
        "SIP 2xx responses expected/s"
        sip_3xx_responses_expected
        "SIP 3xx responses expected"
        sip_3xx_responses_expected_per_s
        "SIP 3xx responses expected/s"
        sip_4xx_responses_expected
        "SIP 4xx responses expected"
        sip_4xx_responses_expected_per_s
        "SIP 4xx responses expected/s"
        sip_5xx_responses_expected
        "SIP 5xx responses expected"
        sip_5xx_responses_expected_per_s
        "SIP 5xx responses expected/s"
        sip_6xx_responses_expected
        "SIP 6xx responses expected"
        sip_6xx_responses_expected_per_s
        "SIP 6xx responses expected/s"
        sip_300-699_responses_retransmitted
        "SIP 300-699 responses retransmitted"
        sip_300-699_responses_retransmitted_per_s
        "SIP 300-699 responses retransmitted/s"
        sip_invite_requests_expected
        "SIP INVITE requests expected"
        sip_invite_requests_expected_per_s
        "SIP INVITE requests expected/s"
        sip_ack_requests_expected
        "SIP ACK requests expected"
        sip_ack_requests_expected_per_s
        "SIP ACK requests expected/s"
        sip_bye_requests_expected
        "SIP BYE requests expected"
        sip_bye_requests_expected_per_s
        "SIP BYE requests expected/s"
        sip_1xx_responses_sent
        "SIP 1xx responses sent"
        sip_1xx_responses_sent_per_s
        "SIP 1xx responses sent/s"
        sip_1xx_responses_unexpected
        "SIP 1xx responses unexpected"
        sip_1xx_responses_unexpected_per_s
        "SIP 1xx responses unexpected/s"
        sip_2xx_responses_sent
        "SIP 2xx responses sent"
        sip_2xx_responses_sent_per_s
        "SIP 2xx responses sent/s"
        sip_2xx_responses_unexpected
        "SIP 2xx responses unexpected"
        sip_2xx_responses_unexpected_per_s
        "SIP 2xx responses unexpected/s"
        sip_3xx_responses_sent
        "SIP 3xx responses sent"
        sip_3xx_responses_sent_per_s
        "SIP 3xx responses sent/s"
        sip_3xx_responses_unexpected
        "SIP 3xx responses unexpected"
        sip_3xx_responses_unexpected_per_s
        "SIP 3xx responses unexpected/s"
        sip_4xx_responses_sent
        "SIP 4xx responses sent"
        sip_4xx_responses_sent_per_s
        "SIP 4xx responses sent/s"
        sip_4xx_responses_unexpected
        "SIP 4xx responses unexpected"
        sip_4xx_responses_unexpected_per_s
        "SIP 4xx responses unexpected/s"
        sip_5xx_responses_sent
        "SIP 5xx responses sent"
        sip_5xx_responses_sent_per_s
        "SIP 5xx responses sent/s"
        sip_5xx_responses_unexpected
        "SIP 5xx responses unexpected"
        sip_5xx_responses_unexpected_per_s
        "SIP 5xx responses unexpected/s"
        sip_6xx_responses_sent
        "SIP 6xx responses sent"
        sip_6xx_responses_sent_per_s
        "SIP 6xx responses sent/s"
        sip_6xx_responses_unexpected
        "SIP 6xx responses unexpected"
        sip_6xx_responses_unexpected_per_s
        "SIP 6xx responses unexpected/s"
        sip_invite_requests_unexpected
        "SIP INVITE requests unexpected"
        sip_invite_requests_unexpected_per_s
        "SIP INVITE requests unexpected/s"
        sip_ack_requests_unexpected
        "SIP ACK requests unexpected"
        sip_ack_requests_unexpected_per_s
        "SIP ACK requests unexpected/s"
        sip_bye_requests_unexpected
        "SIP BYE requests unexpected"
        sip_bye_requests_unexpected_per_s
        "SIP BYE requests unexpected/s"
        sip_cancel_requests_unexpected
        "SIP CANCEL requests unexpected"
        sip_cancel_requests_unexpected_per_s
        "SIP CANCEL requests unexpected/s"
        sip_unknown_requests_unexpected
        "SIP UNKNOWN requests unexpected"
        sip_unknown_requests_unexpected_per_s
        "SIP UNKNOWN requests unexpected/s"
        sip_unknown_messages_unexpected
        "SIP UNKNOWN messages unexpected"
        sip_unknown_messages_unexpected_per_s
        "SIP UNKNOWN messages unexpected/s"
    }
    
    variable ixload_video_client_stats
    array set ixload_video_client_stats {
        video_active_multicast_channels
        "Active Multicast Channels"
        video_multicast_channels_requested
        "Multicast Channels Requested"
        video_multicast_requests_successful
        "Multicast Requests Successful"
        video_multicast_requests_failed
        "Multicast Requests Failed"
        video_vod_streams_playback_successful
        "VoD Streams Playback Successful"
        video_vod_streams_played_failed
        "VoD Streams Playedback Failed"
        video_vod_streams_played
        "VoD Streams Played"
        video_active_d_server_channels
        "Active D Server Channels"
        video_active_v_server_channels
        "Active V Server Channels"
        video_d_server_channels_requested
        "D Server Channels Requested"
        video_d_server_requests_successful
        "D Server Requests Successful"
        video_d_server_requests_failed
        "D Server Requests Failed"
        video_d_server_requests_failed_control
        "D Server Requests Failed (Control)"
        video_d_server_requests_failed_data
        "D Server Requests Failed (Data)"
        video_v_server_channels_requested
        "V Server Channels Requested"
        video_v_server_requests_successful
        "V Server Requests Successful"
        video_v_server_requests_failed
        "V Server Requests Failed"
        video_v_server_requests_failed_control
        "V Server Requests Failed (Control)"
        video_v_server_requests_failed_data
        "V Server Requests Failed (Data)"
        video_igmp_queries_rcvd
        "IGMP Queries Rcvd"
        video_igmp_reports_sent
        "IGMP Reports Sent"
        video_igmp_leaves_sent
        "IGMP Leaves Sent"
        video_mld_queries_rcvd
        "MLD Queries Rcvd"
        video_mld_reports_sent
        "MLD Reports Sent"
        video_mld_leaves_sent
        "MLD Leaves Sent"
        video_join_latency
        "Join Latency"
        video_leave_latency
        "Leave Latency"
        video_channel_switch_latency
        "Channel Switch Latency"
        video_rtsp_bytes_sent
        "RTSP Bytes Sent"
        video_rtsp_bytes_received
        "RTSP Bytes Received"
        video_rtsp_packets_sent
        "RTSP Packets Sent"
        video_rtsp_packets_received
        "RTSP Packets Received"
        video_rtsp_concurrent_sessions
        "RTSP Concurrent Sessions"
        video_rtsp_connection_rate
        "RTSP Connection Rate"
        video_rtsp_transactions
        "RTSP Transactions"
        video_rtsp_transaction_rate
        "RTSP Transaction Rate"
        video_rtsp_connections
        "RTSP Connections"
        video_rtsp_setup_latency_ms
        "RTSP Setup Latency (ms)"
        video_rtsp_teardown_latency_ms
        "RTSP Teardown Latency (ms)"
        video_rtsp_play_latency_ms
        "RTSP Play Latency (ms)"
        video_rtsp_play_latency_0_ms_10_ms
        "RTSP Play Latency (0 ms - 10 ms)"
        video_rtsp_play_latency_10_ms_50_ms
        "RTSP Play Latency (10 ms - 50 ms)"
        video_rtsp_play_latency_50_ms_100_ms
        "RTSP Play Latency (50 ms - 100 ms)"
        video_rtsp_play_latency_100_ms_300ms
        "RTSP Play Latency (100 ms - 300ms)"
        video_rtsp_play_latency_300_ms_1s
        "RTSP Play Latency (300 ms - 1s)"
        video_rtsp_play_latency_greater_than_1s
        "RTSP Play Latency (Greater Than 1s)"
        video_rtsp_presentations_active
        "RTSP Presentations Active"
        video_rtsp_presentations_playing
        "RTSP Presentations Playing"
        video_rtsp_presentations_paused
        "RTSP Presentations Paused"
        video_rtsp_presentations_requested
        "RTSP Presentations Requested"
        video_rtsp_presentation_requests_successful
        "RTSP Presentation Requests Successful"
        video_rtsp_presentation_requests_failed
        "RTSP Presentation Requests Failed"
        video_rtsp_set_parameter
        "RTSP SET PARAMETER"
        video_rtsp_get_parameter
        "RTSP GET PARAMETER"
        video_rtsp_describe
        "RTSP DESCRIBE"
        video_rtsp_setup
        "RTSP SETUP"
        video_rtsp_play
        "RTSP PLAY"
        video_rtsp_pause
        "RTSP PAUSE"
        video_rtsp_teardown
        "RTSP TEARDOWN"
        video_rtsp_describe
        "RTSP DESCRIBE"
        video_rtsp_setup
        "RTSP SETUP"
        video_rtsp_set_parameter
        "RTSP SET PARAMETER"
        video_rtsp_get_parameter
        "RTSP GET PARAMETER"
        video_rtsp_play
        "RTSP PLAY"
        video_rtsp_pause
        "RTSP PAUSE"
        video_rtsp_teardown
        "RTSP TEARDOWN"
        video_rtsp_describe
        "RTSP DESCRIBE"
        video_rtsp_setup
        "RTSP SETUP"
        video_rtsp_set_parameter
        "RTSP SET PARAMETER"
        video_rtsp_get_parameter
        "RTSP GET PARAMETER"
        video_rtsp_play
        "RTSP PLAY"
        video_rtsp_pause
        "RTSP PAUSE"
        video_rtsp_teardown
        "RTSP TEARDOWN"
        video_average_play_latency
        "Average Play latency"
        video_average_pause_latency
        "Average Pause latency"
        video_simulated_users
        "Video Simulated Users"
        video_frame_stats_disabled
        "Frame Stats Disabled"
        video_quality_metrics_disabled
        "Quality Metrics Disabled"
        video_total_bytes_rcvd
        "Total Bytes Rcvd"
        video_total_packets_rcvd
        "Total packets Rcvd"
        video_total_loss
        "Total Loss"
        video_unexpected_udp_packets_received
        "Unexpected UDP Packets Received"
        video_overload_packets_dropped
        "Overload Packets Dropped"
        video_total_rtp_packets_lost
        "Total RTP Packets Lost"
        video_total_out_of_order_rtp_packets_rcvd
        "Total Out Of Order RTP Packets Rcvd"
        video_total_duplicate_rtp_packets
        "Total Duplicate RTP Packets"
        video_global_jitter
        "Global Jitter"
        video_jitter_less_than_50_us
        "Jitter less than 50 us"
        video_jitter_between_50_100_us
        "Jitter between 50 - 100 us"
        video_jitter_between_100_500_us
        "Jitter between 100 - 500 us"
        video_jitter_between_500_us_2_ms
        "Jitter between 500 us - 2 ms"
        video_jitter_between_2_5_ms
        "Jitter between 2 - 5 ms"
        video_jitter_between_5_10_ms
        "Jitter between 5 - 10 ms"
        video_jitter_greater_than_10_ms
        "Jitter greater than 10 ms"
        video_packet_size_between_0_100_bytes
        "Packet Size between 0 - 100 bytes"
        video_packet_size_between_100_200_bytes
        "Packet Size between 100 - 200 bytes"
        video_packet_size_between_200_400_bytes
        "Packet Size between 200 - 400 bytes"
        video_packet_size_between_400_600_bytes
        "Packet Size between 400 - 600 bytes"
        video_packet_size_between_600_1000_bytes
        "Packet Size between 600 - 1000 bytes"
        video_packet_size_greater_than_1000_bytes
        "Packet Size greater than 1000 bytes"
        video_inter_packet_arrival_time_between_0_2_ms
        "Inter Packet Arrival Time between 0 - 2 ms"
        video_inter_packet_arrival_time_between_2_5_ms
        "Inter Packet Arrival Time between 2 - 5 ms"
        video_inter_packet_arrival_time_between_5_10_ms
        "Inter Packet Arrival Time between 5 - 10 ms"
        video_inter_packet_arrival_time_between_10_25_ms
        "Inter Packet Arrival Time between 10 - 25 ms"
        video_inter_packet_arrival_time_between_25_50_ms
        "Inter Packet Arrival Time between 25 - 50 ms"
        video_inter_packet_arrival_time_between_50_100_ms
        "Inter Packet Arrival Time between 50 - 100 ms"
        video_inter_packet_arrival_time_between_100_200_ms
        "Inter Packet Arrival Time between 100 - 200 ms"
        video_inter_packet_arrival_time_between_200_500_ms
        "Inter Packet Arrival Time between 200 - 500 ms"
        video_inter_packet_arrival_time_greater_than_500_ms
        "Inter Packet Arrival Time greater than 500 ms"
        video_packet_latency_between_0_2_ms
        "Packet Latency between 0 - 2 ms"
        video_packet_latency_between_2_5_ms
        "Packet Latency between 2 - 5 ms"
        video_packet_latency_between_5_10_ms
        "Packet Latency between 5 - 10 ms"
        video_packet_latency_between_10_25_ms
        "Packet Latency between 10 - 25 ms"
        video_packet_latency_between_25_50_ms
        "Packet Latency between 25 - 50 ms"
        video_packet_latency_between_50_100_ms
        "Packet Latency between 50 - 100 ms"
        video_packet_latency_between_100_200_ms
        "Packet Latency between 100 - 200 ms"
        video_packet_latency_between_200_500_ms
        "Packet Latency between 200 - 500 ms"
        video_packet_latency_greater_than_500_ms
        "Packet Latency greater than 500 ms"
    }
    
    variable ixload_video_server_stats
    array set ixload_video_server_stats {
        video_total_streams_playing
        "Total Streams Playing"
        video_no_of_multicast_streams_playing
        "No of Multicast Streams Playing"
        video_no_of_vod_streams
        "No of VoD Streams"
        video_no_of_vod_streams_playing
        "No of VoD Streams Playing"
        video_no_of_vod_streams_paused
        "No of VoD Streams Paused"
        video_no_of_multicast_streams_played
        "No of Multicast Streams Played"
        video_no_of_vod_streams_played
        "No of VoD Streams Played"
        video_total_streaming_bit_rate
        "Total Streaming Bit Rate"
        video_multicast_streams_bit_rate
        "Multicast Streams Bit Rate"
        video_vod_streams_bit_rate
        "VoD Streams Bit Rate"
        video_no_of_iptv_d_server_requests_received
        "No of IPTV D Server Requests Received"
        video_no_of_iptv_v_server_requests_received
        "No of IPTV V Server Requests Received"
        video_no_of_iptv_d_server_requests_successful
        "No of IPTV D Server Requests Successful"
        video_no_of_iptv_v_server_requests_successful
        "No of IPTV V Server Requests Successful"
        video_no_of_iptv_d_server_requests_failed
        "No of IPTV D Server Requests Failed"
        video_no_of_iptv_v_server_requests_failed
        "No of IPTV V Server Requests Failed"
        video_no_of_iptv_d_server_requests_failed_for_bandwidth
        "No of IPTV D Server Requests Failed for Bandwidth"
        video_no_of_iptv_v_server_requests_failed_for_bandwidth
        "No of IPTV V Server Requests Failed for Bandwidth"
        video_no_of_iptv_d_server_requests_failed_for_port_overload
        "No of IPTV D Server Requests Failed for Port Overload"
        video_no_of_iptv_v_server_requests_failed_for_port_overload
        "No of IPTV V Server Requests Failed for Port Overload"
        video_no_of_iptv_d_server_requests_failed_for_other_reasons
        "No of IPTV D Server Requests Failed for Other Reasons"
        video_no_of_iptv_v_server_requests_failed_for_other_reasons
        "No of IPTV V Server Requests Failed for Other Reasons"
        video_no_of_iptv_active_a_server_streams_playing
        "No of IPTV Active A Server Streams Playing"
        video_no_of_iptv_active_d_server_streams_playing
        "No of IPTV Active D Server Streams Playing"
        video_no_of_iptv_active_v_server_streams
        "No of IPTV Active V Server Streams"
        video_no_of_iptv_active_v_server_streams_playing
        "No of IPTV Active V Server Streams Playing"
        video_no_of_iptv_active_v_server_streams_paused
        "No of IPTV Active V Server Streams Paused"
        video_a_server_streams_bit_rate
        "A Server Streams Bit Rate"
        video_d_server_streams_bit_rate
        "D Server Streams Bit Rate"
        video_v_server_streams_bit_rate
        "V Server Streams Bit Rate"
        video_iptv_total_streaming_bit_rate
        "IPTV Total Streaming Bit Rate"
        video_rtsp_presentations_received
        "RTSP Presentations Received"
        video_rtsp_presentations_successful
        "RTSP Presentations Successful"
        video_rtsp_presentations_failed
        "RTSP Presentations Failed"
        video_rtsp_bytes_sent
        "RTSP Bytes Sent"
        video_rtsp_bytes_received
        "RTSP Bytes Received"
        video_rtsp_packets_sent
        "RTSP Packets Sent"
        video_rtsp_packets_received
        "RTSP Packets Received"
        video_rtsp_play_latency_ms
        "RTSP Play Latency (ms)"
        video_rtsp_commands_received
        "RTSP Commands Received"
        video_rtsp_describe
        "RTSP DESCRIBE"
        video_rtsp_setup_received
        "RTSP SETUP Received"
        video_rtsp_play_received
        "RTSP PLAY Received"
        video_rtsp_pause_received
        "RTSP PAUSE Received"
        video_rtsp_teardown_received
        "RTSP TEARDOWN Received"
        video_rtsp_response_codes_sent_2xx
        "RTSP Response Codes Sent (2xx)"
        video_rtsp_response_codes_sent_3xx
        "RTSP Response Codes Sent (3xx)"
        video_rtsp_response_codes_sent_4xx
        "RTSP Response Codes Sent (4xx)"
        video_rtsp_response_codes_sent_5xx
        "RTSP Response Codes Sent (5xx)"
        video_rtsp_response_codes_sent_6xx_1xxx
        "RTSP Response Codes Sent (6xx-1xxx)"
        video_total_bytes_sent
        "Total Bytes Sent"
        video_total_packets_sent
        "Total Packets Sent"
        video_tx_jitter_ns
        "Tx Jitter (ns)"
        video_tx_packets_dropped
        "Tx Packets Dropped"
    }
    
    variable ixload_per_interface_stats
    array set ixload_per_interface_stats {
        packets_sent
        "Packets Sent"
        packets_received
        "Packets Received"
        bytes_sent
        "Bytes Sent"                    
        bytes_received
        "Bytes Received"
        fragments_received
        "Fragments Received"
        reassembly_timeouts
        "Reassembly Timeouts"
        tcp_syn_sent
        "TCP SYN Sent"
        tcp_syn_received
        "TCP SYN Received"
        tcp_synack_sent
        "TCP SYN-ACK Sent"
        tcp_fin_sent
        "TCP FIN Sent"
        tcp_fin_received
        "TCP FIN Received"
        tcp_finack_sent
        "TCP FIN-ACK Sent"
        tcp_finack_received
        "TCP FIN-ACK Received"
        tcp_resets_sent
        "TCP Resets Sent"
        tcp_resets_received
        "TCP Resets Received"
        tcp_bytes_sent
        "TCP Bytes Sent"
        tcp_bytes_received
        "TCP Bytes Received"
    }
    
    variable ixload_clear_per_interface_stats
        
    variable ixload_test_controller
    variable ixload_registered_stats
    variable ixload_returned_stats
    variable ixload_logger
    variable ixload_log_engine
    variable interface_handle
    variable pa_ip_idx
    variable pa_mac_idx
    variable pa_descr_idx
    variable pa_inth_idx
    variable mep_handles_array
    variable cfm_vlan_handles_array
    variable cfm_mdlevel_handles_array
    variable cfm_message_handles_array
    variable cfm_messages_current_id
    variable cfm_topology_current_id
    variable clear_csv_stats
    variable csv_path
    
    # This variable tells if the procedure already called ixaSetPortList
    # command, as this command can be called only once per configuration
    variable portListWritten

    # This variable tells if procedures can attempt to run special through
    # tcl server
    variable executeOnTclServer

    # This variable tells if the procedure already called ixaSetPortList
    # command, as this command can be called only once per configuration
    variable portListWritten

    #
    ##### ixLoad support end

    # Initialize the variables
    ::ixia::set_init

    # public interface
    namespace export                                    \
                L47_client_mapping                      \
                L47_dut                                 \
                L47_ftp_client                          \
                L47_ftp_server                          \
                L47_http_client                         \
                L47_http_server                         \
                L47_network                             \
                L47_server_mapping                      \
                L47_sip_client                          \
                L47_sip_server                          \
                L47_stats                               \
                L47_telnet_client                       \
                L47_telnet_server                       \
                L47_test                                \
                L47_video_client                        \
                L47_video_server                        \
                capture_packets                         \
                cleanup_session                         \
                connect                                 \
                device_info                             \
                emulation_ancp_config                   \
                emulation_ancp_control                  \
                emulation_ancp_profile_config           \
                emulation_ancp_stats                    \
                emulation_bfd_config                    \
                emulation_bfd_control                   \
                emulation_bfd_info                      \
                emulation_bfd_session_config            \
                emulation_bgp_config                    \
                emulation_bgp_control                   \
                emulation_bgp_info                      \
                emulation_bgp_route_config              \
                emulation_cfm_config                    \
                emulation_cfm_control                   \
                emulation_cfm_custom_tlv_config         \
                emulation_cfm_info                      \
                emulation_cfm_links_config              \
                emulation_cfm_md_meg_config             \
                emulation_cfm_mip_mep_config            \
                emulation_cfm_vlan_config               \
                emulation_dhcp_config                   \
                emulation_dhcp_control                  \
                emulation_dhcp_group_config             \
                emulation_dhcp_stats                    \
                emulation_efm_config                    \
                emulation_efm_control                   \
                emulation_efm_org_var_config            \
                emulation_efm_stat                      \
                emulation_eigrp_config                  \
                emulation_eigrp_control                 \
                emulation_eigrp_info                    \
                emulation_eigrp_route_config            \
                emulation_ftp_config                    \
                emulation_ftp_control                   \
                emulation_ftp_control_config            \
                emulation_ftp_stats                     \
                emulation_ftp_traffic_config            \
                emulation_http_config                   \
                emulation_http_control                  \
                emulation_http_control_config           \
                emulation_http_stats                    \
                emulation_http_traffic_config           \
                emulation_http_traffic_type_config      \
                emulation_igmp_config                   \
                emulation_igmp_control                  \
                emulation_igmp_group_config             \
                emulation_igmp_info                     \
                emulation_isis_config                   \
                emulation_isis_control                  \
                emulation_isis_info                     \
                emulation_isis_topology_route_config    \
                emulation_lacp_control                  \
                emulation_lacp_info                     \
                emulation_lacp_link_config              \
                emulation_ldp_config                    \
                emulation_ldp_control                   \
                emulation_ldp_info                      \
                emulation_ldp_route_config              \
                emulation_mld_config                    \
                emulation_mld_control                   \
                emulation_mld_group_config              \
                emulation_multicast_group_config        \
                emulation_multicast_source_config       \
                emulation_oam_config_msg                \
                emulation_oam_config_topology           \
                emulation_oam_control                   \
                emulation_oam_info                      \
                emulation_ospf_config                   \
                emulation_ospf_control                  \
                emulation_ospf_lsa_config               \
                emulation_ospf_topology_route_config    \
                emulation_pim_config                    \
                emulation_pim_control                   \
                emulation_pim_group_config              \
                emulation_pim_info                      \
                emulation_rip_config                    \
                emulation_rip_control                   \
                emulation_rip_route_config              \
                emulation_rsvp_config                   \
                emulation_rsvp_control                  \
                emulation_rsvp_info                     \
                emulation_rsvp_tunnel_config            \
                emulation_rsvp_tunnel_info              \
                emulation_stp_bridge_config             \
                emulation_stp_control                   \
                emulation_stp_info                      \
                emulation_stp_lan_config                \
                emulation_stp_msti_config               \
                emulation_stp_vlan_config               \
                emulation_telnet_config                 \
                emulation_telnet_control                \
                emulation_telnet_control_config         \
                emulation_telnet_stats                  \
                emulation_telnet_traffic_config         \
                emulation_twamp_config                  \
                emulation_twamp_control                 \
                emulation_twamp_control_range_config    \
                emulation_twamp_info                    \
                emulation_twamp_server_range_config     \
                emulation_twamp_test_range_config       \
                get_packet_content                      \
                interface_config                        \
                interface_stats                         \
                l2tp_config                             \
                l2tp_control                            \
                l2tp_stats                              \
                l2tpv3_control                          \
                l2tpv3_dynamic_cc_config                \
                l2tpv3_session_config                   \
                l2tpv3_stats                            \
                l3vpn_generate_stream                   \
                packet_config_buffers                   \
                packet_config_filter                    \
                packet_config_triggers                  \
                packet_control                          \
                packet_stats                            \
                pppox_config                            \
                pppox_control                           \
                pppox_stats                             \
                set_init                                \
                traffic_config                          \
                traffic_control                         \
                traffic_stats                           \
                utracker                                \
                validateHandleObjectRef
}

# Source all of the IxTclHal files
set origDir [pwd]

cd [file join $::env(IXTCLHAL_LIBRARY) Generic]
foreach fileName [glob -nocomplain *.tcl] {
    catch {source $fileName}
}
cd $origDir

# Package IxAccess
if {$::ixia::ixaccessLoaded} {
    if {[namespace exists ixAccessValidate]} {
        if {![catch {set procBody [info body ixAccessValidate::getSupPortUtilPpsInfo]}]} {
            if {[string first \
                    "set rate    \[calculatePercentMaxRate \$ch \$ca \$po \$pps \$absFrameSize  \$encapOrPreamble\]" \
                    $procBody] != -1} {
                set ::ixia::source_ixaccess_validate 1 
            }
        }
    }
}


if {[catch {package req Mpexpr} mpvers]} {
    interp alias {} mpexpr {} expr
    puts "WARNING: Mpexpr not found! Using expr for mpexpr.\
            Math expresions using multiple precision might return unexpected results when using expr\
            (plase see tcl documentation for differences between mpexpr and expr)! "
} else {
    puts "Loaded Mpexpr $mpvers"
}

# Source all of the Ixia package files
# The Ixia.tcl file being sourced, may not be the one for the actual package
# wanted by the user.
set origDir [pwd]

# This is entirely based on the pkgIndex.tcl file sourcing the Ixia.tcl
# in the directory that the version is installed and nothing else.
set pkgSource [package ifneeded Ixia $::ixia::hltVersion]
if {$pkgSource == ""} {
    puts "Failed to load the '$::ixia::hltVersion' version of the Ixia package."
    return -code error -errorinfo "Failed to load the '$::ixia::hltVersion'\
            version of the Ixia package."
}
set ::env(IXIA_HLTAPI_LIBRARY) [file dir [lindex $pkgSource 1]]

cd [file join $::env(IXIA_HLTAPI_LIBRARY) library/dependencies]
foreach file [lsort [glob *.tcl]] { catch { source $file } } 

cd [file join $::env(IXIA_HLTAPI_LIBRARY) library]
foreach fileName [glob -nocomplain *.tcl] {
    if {$::ixia::source_ixaccess_validate} {
        catch {source $fileName}
    } else {
        if {![regexp {utils_ixaccess_validate.tcl$} $fileName]} {
            catch {source $fileName}
        }
    }
}
cd $origDir

if { [catch {
cd [file join $::env(IXIA_HLTAPI_LIBRARY) library/common/ixiangpf/tcl]
source ixiangpf.tcl
} errmsg] } {puts "Error loading ixiangpf: $errmsg"}

# import the connect function from the ::ixiangpf namespace
# so we will have the same functionality in both namespaces
namespace eval ::ixia {
	if { [catch {
		namespace import ::ixiangpf::connect
		namespace import ::ixiangpf::cleanup_session
	} errmsg] } {puts "Error: $errmsg"}
}

cd $origDir

package require Tclx


# Load utracker library
catch {::ixia::utrackerLoadLibrary}

catch {unset ::SUCCESS}
catch {unset ::FAILURE}
set ::SUCCESS 1
set ::FAILURE 0

if {[catch {set ::true}] || [catch {set ::false}]} {
    set ::true  1
    set ::false 0
}

package provide Ixia $::ixia::hltVersion

# The regsub is present only to avoid CM build to replace the IXIA VERSION string
# with the actual build in this particular case.
if {[info exists ::ixia::hltapi_version] && $::ixia::hltapi_version != [regsub " " "IXIA VERSION" ""]} {
    puts "HLT release $::ixia::hltapi_version"
}

if {[info exists ::ixia::ixnetworkVersion]} {
    set __hl_major      [lindex [split $::ixia::ixnetworkVersion .] 0]
    set __hl_minor_temp [lindex [split $::ixia::ixnetworkVersion .] 1]
    regexp {^([0-9]+)(P|N|NO|P2NO)$} $__hl_minor_temp __hl_minor_temp_ignore __hl_minor
    
    if {[string first "N" $__hl_minor_temp] != -1} {
        if {![info exists __hl_minor]} {
            puts "Failed to load ixia_hl_lib. Cannot determine correctly the IxNetwork version  ..."
        }
        lappend auto_path [file join            \
            $::env(IXIA_HLTAPI_LIBRARY)         \
            library                             \
            common                              \
            ixia_hl_lib-$__hl_major.$__hl_minor \
            ]
        
        if {[catch {package require -exact ixiahltgenerated $__hl_major.$__hl_minor} retCode]} {
            puts "Failed to load ixia_hl_lib-$__hl_major.$__hl_minor. ( $retCode )  ..."
        } else {
            puts "Loaded ixia_hl_lib-$__hl_major.$__hl_minor "
        }
    }
}

# Remove duplicates from auto_path
set ::auto_path [lsort -unique $::auto_path]

##################################################################
# If an UPDATE affects this file it should be added here
#   ::ixia::add_update_item                             \
#       -id <HLTAPI VERSION for UPDATE>                 \
#       -description "Monthly Update (without dashes)" \
#       -file_name   "Ixia.tcl"
#    
#   If an UPDATE affects another file, add this code at the beginning of that file
#   ::ixia::add_update_item                             \
#       -id <HLTAPI VERSION for UPDATE>                 \
#       -description "Monthly Update (without dashes)"  \
#       -file_name   [file tail [info script]]
#
# Parameters description and file_name are optional
##################################################################

# ::ixia::add_update_item -id 4.96.118.5 -description "Monthly Update" -file_name "Ixia.tcl"


##################################################################
# If a HOTFIX affects this file it should be added here
#   ::ixia::add_hotfix_item                             \
#       -id 556792                                      \
#       -description "short description without dashes" \
#       -file_name   "Ixia.tcl"
#    
#   If a HOTFIX affects another file, add this code at the beginning of that file
#   ::ixia::add_hotfix_item                             \
#       -id 856792                                      \
#       -description "short description without dashes" \
#       -file_name   [file tail [info script]]
#
# Parameters description and file_name are optional
##################################################################


::ixia::print_update_items
::ixia::print_hotfix_items
