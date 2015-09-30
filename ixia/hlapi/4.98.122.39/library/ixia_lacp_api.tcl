##Library Header
# $Id: $
# Copyright © 2003-2007 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_lacp_api.tcl
#
# Purpose:
#     A script development library containing LACP APIs for test automation
#     with the Ixia chassis.
#
# Author:
#    Lavinia Raicea
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures contained within this library include:
#
#    - emulation_lacp_link_config
#    - emulation_lacp_control
#    - emulation_lacp_info
#
# Requirements:
#     ixiaapiutils.tcl , a library containing TCL utilities
#     parseddashedargs.tcl , a library containing the proceDescr and
#     parsedashedargds.tcl.
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

proc ::ixia::emulation_lacp_link_config { args } {
    variable executeOnTclServer
    variable new_ixnetwork_api
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::emulation_lacp_link_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args
    
    set opt_args {
        -actor_key                        RANGE 0-65535 
                                          DEFAULT 1
        -actor_key_step                   RANGE 0-65535 
                                          DEFAULT 1
        -actor_port_num                   RANGE 0-65535 
                                          DEFAULT 1
        -actor_port_num_step              RANGE 0-65535 
                                          DEFAULT 1
        -actor_port_pri                   RANGE 0-65535 
                                          DEFAULT 1
        -actor_port_pri_step              RANGE 0-65535 
                                          DEFAULT 1
        -actor_system_id                  MAC
        -actor_system_id_step             MAC
        -actor_system_pri                 RANGE 0-65535 
                                          DEFAULT 1
        -actor_system_pri_step            RANGE 0-65535 
                                          DEFAULT 1
        -aggregation_flag                 CHOICES auto disable 
                                          DEFAULT auto
        -auto_pick_port_mac               CHOICES 0 1 
                                          DEFAULT 1
        -collecting_flag                  CHOICES 0 1 
                                          DEFAULT 1
        -collector_max_delay              RANGE 0-65535 
                                          DEFAULT 0
        -distributing_flag                CHOICES 0 1 
                                          DEFAULT 1
        -handle
        -inter_marker_pdu_delay           RANGE 1-255
                                          DEFAULT 6
        -lacp_activity                    CHOICES active passive 
                                          DEFAULT active
        -lacp_timeout                     CHOICES short long auto RANGE 1-65535 
                                          DEFAULT auto
        -lacpdu_periodic_time_interval    CHOICES fast slow auto RANGE 1-65535 
                                          DEFAULT auto
        -lag_count                        NUMERIC
        -marker_req_mode                  CHOICES fixed random 
                                          DEFAULT fixed
        -marker_res_wait_time             RANGE 1-255
                                          DEFAULT 5
        -mode                             CHOICES create modify enable disable delete 
                                          DEFAULT create
        -no_write
        -port_handle                      REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -port_mac                         MAC
        -port_mac_step                    MAC
        -reset
        -send_marker_req_on_lag_change    CHOICES 0 1 
                                          DEFAULT 1
        -send_periodic_marker_req         CHOICES 0 1 
                                          DEFAULT 0
        -support_responding_to_marker     CHOICES 0 1 
                                          DEFAULT 1
        -sync_flag                        CHOICES auto disable 
                                          DEFAULT auto
    }
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
#         set returnList [::ixia::ixnetwork_lacp_link_config $args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "LACP is not supported with IxTclNetwork API."
    } else {
        set returnList [::ixia::ixprotocol_lacp_link_config $args $opt_args]
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    return $returnList
}


proc ::ixia::emulation_lacp_control { args } {
    variable executeOnTclServer
    variable new_ixnetwork_api
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::emulation_lacp_control $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args
    
    set man_args {
        -mode          CHOICES restart send_marker_req start start_pdu stop stop_pdu update_link
    }
    set opt_args {
        -port_handle   REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -handle
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
#         set returnList [::ixia::ixnetwork_lacp_control $args $man_args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "LACP is not supported with IxTclNetwork API."
        
    } else {
        set returnList [::ixia::ixprotocol_lacp_control $args $man_args $opt_args]
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    return $returnList
}


proc ::ixia::emulation_lacp_info { args } {
    variable executeOnTclServer
    variable new_ixnetwork_api
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::emulation_lacp_info $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args
    
    set man_args {
        -mode          CHOICES aggregate_stats learned_info clear_stats configuration
    }
    set opt_args {
        -handle
        -port_handle   REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
#         set returnList [::ixia::ixnetwork_lacp_info $args $man_args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "LACP is not supported with IxTclNetwork API."
        
    } else {
        set returnList [::ixia::ixprotocol_lacp_info $args $man_args $opt_args]
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    return $returnList
}
