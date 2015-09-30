##Library Header
# $Id: $
# Copyright © 2003-2007 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_L47telnet_api.tcl
#
# Purpose:
#
# Author: Mircea Hasegan
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures contained within this library include:
#
#    - L47_telnet_client
#    - L47_telnet_server
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


proc ::ixia::L47_telnet_client { args } {
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
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::L47_telnet_client $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    set returnList [checkL47 Telnet]
    if {[keylget returnList status] == $::FAILURE} {
        return $returnList
    }
    
    # Arguments
    set mandatory_args {
        -mode        CHOICES add remove modify enable disable
    }
    
    set opt_args {
        -handle                  ANY
        -property                CHOICES client agent command
        -command_prompt          ANY
        -options_enable          CHOICES 0 1
                                 DEFAULT 0
        -expect_timeout          NUMERIC
                                 DEFAULT 120
        -esm_enable              CHOICES 0 1
        -esm                     NUMERIC
                                 DEFAULT 1460
        -loop_enable             CHOICES 0 1
                                 DEFAULT 0
        -c_id                    CHOICES open login password
                                 CHOICES send exit think loop_begin loop_end
        -c_expect                ANY
        -c_send                  ANY
        -c_server_ip             ANY
        -c_max_interval          NUMERIC
                                 DEFAULT 1000
        -c_min_interval          NUMERIC
                                 DEFAULT 1000
    }
    
    if {[catch  {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
                        -mandatory_args $mandatory_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }
    
    set target client    
    
    if {$mode == "add"} {
        if {![info exists property]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -mode is $mode, then -property\
                    must be provided."
            return $returnList
        }
        if {($property != "client") && (![info exists handle])} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -property is $property, then -handle\
                    must be provided."
            return $returnList
        }
    } else  {
        ::ixia::removeDefaultOptionVars $opt_args $args
        
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -mode is $mode, then -handle\
                    must be provided."
            return $returnList
        }
        
        if {![info exists property]} {
            set property [::ixia::ixL47GetProperty $handle telnet]
        }
    }
    
    # Agent parameters
    set agent_option_list [list procName mode handle target command_prompt   \
            options_enable expect_timeout esm_enable esm loop_enable property]
    
    set agent_args [list]
    
    # Action parameters
    set command_option_list [list procName mode handle target c_id c_expect \
            c_server_ip c_send c_max_interval c_min_interval]
    
    set command_args [list]
    
    set option_variables "agent_option_list agent_args command_option_list \
            command_args"
    
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
        client -
        agent {
            set returnList [eval [format "%s %s" ::ixia::ixL47TelnetAgent   \
                    $agent_args]]
            return $returnList
        }
        action -
        command {
            set returnList [eval [format "%s %s" ::ixia::ixL47TelnetCommand \
                    $command_args]]
            return $returnList
        }
        default {}
    }
}


proc ::ixia::L47_telnet_server { args } {
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
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::L47_telnet_server $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    set returnList [checkL47 Telnet]
    if {[keylget returnList status] == $::FAILURE} {
        return $returnList
    }
    
    # Arguments
    set mandatory_args {
        -mode        CHOICES add remove modify enable disable
    }
    
    set opt_args {
        -handle                  ANY
        -property                CHOICES server agent
        -close_command           ANY
        -command_prompt          ANY
                                 DEFAULT #
        -echo_enable             CHOICES 0 1
                                 DEFAULT 1
        -linemode_enable         CHOICES 0 1
                                 DEFAULT 0
        -listen_port             RANGE 0-65635
                                 DEFAULT 23
        -suppress_go_ahead       CHOICES 0 1
                                 DEFAULT 1
        -esm_enable              CHOICES 0 1
        -esm                     NUMERIC
                                 DEFAULT 1460
    }
    
    if {[catch  {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
                        -mandatory_args $mandatory_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }
    
    set target server    
    
    if {$mode == "add"} {
        if {![info exists property]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -mode is $mode, then -property\
                    must be provided."
            return $returnList
        }
        if {($property != "server") && (![info exists handle])} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -property is $property, then -handle\
                    must be provided."
            return $returnList
        }
    } else  {
        ::ixia::removeDefaultOptionVars $opt_args $args
        
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -mode is $mode, then -handle\
                    must be provided."
            return $returnList
        }
        
        if {![info exists property]} {
            set property [::ixia::ixL47GetProperty $handle telnet]
        }
    }
    
    # Agent parameters
    set agent_option_list [list procName mode handle property target      \
            close_command command_prompt echo_enable linemode_enable      \
            listen_port suppress_go_ahead esm_enable esm]
    
    set agent_args [list]
    
    set option_variables "agent_option_list agent_args"
    
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
            set returnList [eval [format "%s %s" ::ixia::ixL47TelnetAgent   \
                    $agent_args]]
            return $returnList
        }
        default {}
    }
}
