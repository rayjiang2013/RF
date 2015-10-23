##Library Header
# $Id: $
# Copyright © 2003-2007 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_L47ftp_api.tcl
#
# Purpose:
#
# Author:
#
# Usage:
#    package require Ixia
#    Test scenarios supported are:
#    1.	emulated ftp server and emulated ftp client
#    2.	real ftp server and emulated ftp client
#
# Description:
#    The procedures contained within this library include:
#
#    - L47_ftp_client
#    - L47_ftp_server
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

proc ::ixia::L47_ftp_client { args } {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    variable temporary_fix_122311
    if {$::ixia::executeOnTclServer && $::ixia::temporary_fix_122311 == 0} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::L47_ftp_client $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    set returnList [checkL47 FTP]
    if {[keylget returnList status] == $::FAILURE} {
        return $returnList
    }
    
    # Arguments
    set mandatory_args {
        -mode        CHOICES add remove modify enable disable
    }
    
    set opt_args {
        -property                  CHOICES client agent action real_file
        -handle                    ANY
        -esm_enable                CHOICES 0 1
                                   DEFAULT 0
        -tos_enable                CHOICES 0 1
                                   DEFAULT 0
        -esm                       NUMERIC
                                   DEFAULT 1460
        -ip_preference             CHOICES 0 1 2 3
                                   DEFAULT 2
        -loop_enable                CHOICES 0 1
                                   DEFAULT 0
        -access_mode               CHOICES active passive
                                   DEFAULT active
        -password                  ANY
        -tos                       RANGE 0-255
                                   DEFAULT 0
        -user_name                 ANY
        -a_arguments               SHIFT
        -a_command                 CHOICES cd get login put quit retrieve
                                   CHOICES store think loop_begin loop_end
                                   DEFAULT get
        -a_destination             ANY
        -a_destination_port        RANGE 1-65535
        -a_password                ANY
        -a_user_name               ANY
        -rf_name                   ANY
        -rf_payload_file           ANY
    }
    
    if {[catch  {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
                    -mandatory_args $mandatory_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    } 
    
    set target Client
    
    if {$mode == "add"} {
        if {![info exists property]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -mode is $mode, then -property\
                    must be provided."
            return $returnList
        }
    } else  {
        removeDefaultOptionVars $opt_args $args
        
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -mode is $mode, then -handle\
                    must be provided."
            return $returnList
        }
        
        if {![info exists property]} {
            set property [::ixia::ixL47GetProperty $handle ftp]
        }
    }
    
    if {($property == "client") && ($mode != "add") && ($mode != "remove")} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: When \
                -mode is $mode, -property $property is not supported."
        return $returnList
    } 
    
    set agent_option_list [list procName mode handle esm_enable tos_enable \
            esm ip_preference loop_enable access_mode password tos user_name \
            property target]
    set agent_args [list]
    
    set action_option_list [list procName mode handle a_arguments a_command \
            a_destination a_destination_port a_password a_user_name]
    set action_args [list]
    
    set file_option_list [list procName mode handle rf_name rf_payload_file \
            property target]
    set file_args [list]

    set option_variables "agent_option_list agent_args action_option_list \
            action_args file_option_list file_args"
    
    foreach {property_list property_args} $option_variables {
        set _o_list [set $property_list]
        foreach item $_o_list {
            if {[info exists $item]} {
                lappend $property_args "-$item"
                if {$item == "password"} {
                    lappend $property_args "\{\"[set $item]\"\}"
                } else {
                    lappend $property_args "[set $item]"
                }
            }
        }
    }
    
#    debug "property=$property\ntraffic_args=$traffic_args"
    switch -- $property {
        client -
        agent {
            set returnList [eval [format "%s %s" ::ixia::ixL47FtpAgent \
                    $agent_args]]
            return $returnList
        }
        action {
            set returnList [eval [format "%s %s" ::ixia::ixL47FtpAction \
                    $action_args]]
            return $returnList
        }
        real_file {
            set returnList [eval [format "%s %s" ::ixia::ixL47FtpFile \
                    $file_args]]
            return $returnList
        }
        default {}
    }
}


proc ::ixia::L47_ftp_server { args } {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    variable temporary_fix_122311
    if {$::ixia::executeOnTclServer && $::ixia::temporary_fix_122311 == 0} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::L47_ftp_server $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    set returnList [checkL47 FTP]
    if {[keylget returnList status] == $::FAILURE} {
        return $returnList
    }
    
    # Arguments
    set mandatory_args {
        -mode        CHOICES add remove modify enable disable
    }
    
    set opt_args {
        -property                  CHOICES server agent real_file
        -handle                    ANY
        -esm_enable                CHOICES 0 1
                                   DEFAULT 0
        -tos_enable                CHOICES 0 1
                                   DEFAULT 0
        -esm                       NUMERIC
                                   DEFAULT 1460
        -ftp_port                  RANGE 1-65535
                                   DEFAULT 21
        -tos                       RANGE 0-255
                                   DEFAULT 0
        -rf_name                   ANY
        -rf_payload_file           ANY
    }
    
    if {[catch  {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
                        -mandatory_args $mandatory_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }

    set target Server
    
    if {$mode == "add"} {
        if {![info exists property]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -mode is $mode, then -property\
                    must be provided."
            return $returnList
        }
    } else  {
        removeDefaultOptionVars $opt_args $args
        
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -mode is $mode, then -handle\
                    must be provided."
            return $returnList
        }
        
        if {![info exists property]} {
            set property [::ixia::ixL47GetProperty $handle ftp]
        }
    }
    
    if {($property == "server") && ($mode != "add") && ($mode != "remove")} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: When \
                -mode is $mode, -property $property is not supported."
        return $returnList
    } 
    
    set agent_option_list [list procName mode handle esm_enable tos_enable \
            esm ftp_port tos property target]
    set agent_args [list]
    
    set file_option_list [list procName mode handle rf_name rf_payload_file \
            target property]
    set file_args [list]
    
    set option_variables "agent_option_list agent_args file_option_list file_args"

    foreach {property_list property_args} $option_variables {
        set _o_list [set $property_list]
        foreach item $_o_list {
            if {[info exists $item]} {
                lappend $property_args "-$item"
                lappend $property_args "[set $item]"
            }
        }
    }
    
    switch -- $property {
        server -
        agent {
            set returnList [eval [format "%s %s" ::ixia::ixL47FtpAgent $agent_args]]
            return $returnList
        }
        real_file {
            set returnList [eval [format "%s %s" ::ixia::ixL47FtpFile \
                    $file_args]]
            return $returnList
        }
        default {}
    }
}
