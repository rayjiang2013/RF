##Library Header
# $Id: $
# Copyright © 2003-2007 by IXIA
# All Rights Reserved.
#
# Name:
#    utils_ixnetwork_lacp.tcl
#
# Purpose:
#    Utility functions to support LACP protocol config/control
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
# meet the user's requirements or (ii) that the script will be without         #
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

##Internal Procedure Header
# Name:
#    ::ixia::checkLacpLinkModeDependencies
#
# Description:
#    This command executes check if -mode dependencies are present for the
#    command emulation_lacp_link_config.
#
# Synopsis:
#
# Arguments:
#
# Return Values:
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#

proc ::ixia::checkLacpLinkModeDependencies {} {
    uplevel {
        if {($mode == "create")} {
            if {![info exists port_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -mode is $mode,\
                        parameter -port_handle must be provided."
                return $returnList
            }
        } else {
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -mode is $mode,\
                        parameter -handle must be provided."
                return $returnList
            }
            if {$handle == ""} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid parameter -handle {$handle}."
                return $returnList
            }
        }
        
        keylset returnList status $::SUCCESS
        return $returnList
    }
}


