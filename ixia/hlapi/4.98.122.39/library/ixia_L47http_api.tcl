##Library Header
# $Id: $
# Copyright © 2003-2007 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_L47http_api.tcl
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
#    - L47_http_client
#    - L47_http_server
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

proc ::ixia::L47_http_client { args } {
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
                \{::ixia::L47_http_client $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    set returnList [checkL47 HTTP]
    if {[keylget returnList status] == $::FAILURE} {
        return $returnList
    }
    
    # Arguments
    set mandatory_args {
        -mode        CHOICES add remove modify enable disable
    }
    
    set opt_args {
        -property                  CHOICES client agent action profile
                                   CHOICES request_header 
        -handle                    ANY
        -browser_emulation         CHOICES custom ie5 ie6 mozilla firefox safari
                                   DEFAULT ie6
        -cookie_jar_size           RANGE 1-300
                                   DEFAULT 10
        -cookie_reject_probability DECIMAL
                                   DEFAULT 0.0
        -cookie_support_enable     CHOICES 0 1
                                   DEFAULT 0
        -esm_enable                CHOICES 0 1
                                   DEFAULT 0
        -esm                       NUMERIC
                                   DEFAULT 1460
        -http_proxy_enable         CHOICES 0 1
                                   DEFAULT 0
        -https_proxy_enable        CHOICES 0 1
                                   DEFAULT 0
        -ip_preference             CHOICES 0 1 2 3
                                   DEFAULT 2
        -follow_http_redirects     CHOICES 0 1
                                   DEFAULT 0
        -http_proxy                ANY
        -https_proxy               ANY
        -http_version              CHOICES 1.0 1.1
                                   DEFAULT 1.0
        -keep_alive                CHOICES 0 1
                                   DEFAULT 0
        -max_persistent_requests   NUMERIC
                                   DEFAULT 1
        -max_sessions              NUMERIC
                                   DEFAULT 3
        -ssl_enable                CHOICES 0 1
                                   DEFAULT 0
        -sequential_session_reuse  NUMERIC
                                   DEFAULT 0
        -ssl_version               CHOICES ssl2 ssl3 tls1
                                   DEFAULT tls1
        -certificate               ANY
        -certificate_file          ANY
        -private_key               ANY
        -private_key_file          ANY
        -private_key_password      ANY
        -client_ciphers            ANY
        -request_timeout           RANGE 1-64000
                                   DEFAULT 300
        -tos_enable                CHOICES 0 1
                                   DEFAULT 0
        -tos                       RANGE 0-255
                                   DEFAULT 0
        -large_header_enable       CHOICES 0 1
                                   DEFAULT 0
        -loop_enable               CHOICES 0 1
                                   DEFAULT 0
        -max_header_len            RANGE 1024-10240
                                   DEFAULT 1024
        -max_pipeline              RANGE 1-1000
                                   DEFAULT 1
        -tcp_close_option          CHOICES 0 1 2
        -a_abort                         CHOICES none before after
                                         DEFAULT none
        -a_command                       CHOICES get get_ssl delete head head_ssl 
                                         CHOICES put put_ssl post post_ssl think
                                         CHOICES  loop_begin loop_end
                                         DEFAULT get
        -a_arguments                     ANY
        -a_destination                   ANY
        -a_destination_port              RANGE 1-65535
        -a_page_handle                   ANY
        -a_profile_handle                ANY
        -pr_case_insensitive_match       CHOICES 0 1
                                         DEFAULT 0
        -pr_substring                    ANY
        -pr_substring_match_enable       CHOICES 0 1
                                         DEFAULT 0
        -pr_basic_auth                   CHOICES 0 1
                                         DEFAULT 0
        -pr_user_id                      ANY
        -pr_password                     ANY
        -rh_data                         ANY
    }
    
    if {[catch  {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
                        -mandatory_args $mandatory_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }
    
    set target client

    if {[info exists cookie_reject_probability]} {
        foreach {_value} $cookie_reject_probability {
            if {($_value > 1.0) || ($_value < 0.0)} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Invalid\
                        value $_value for -cookie_reject_probability option. \
                        Valid type is RANGE: 0.0 - 1.0."
                return $returnList
            }
        }
    }

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
            set property [::ixia::ixL47GetProperty $handle http]
        }
    }
    
    if {($property == "client") && ($mode != "add") && ($mode != "remove")} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: When \
                -mode is $mode, -property $property is not supported."
        return $returnList
    }
    
    set agent_option_list [list procName mode property handle browser_emulation \
        cookie_jar_size target                                                  \
        cookie_reject_probability cookie_support_enable esm_enable esm          \
        http_proxy_enable https_proxy_enable ip_preference follow_http_redirects\
        http_proxy https_proxy http_version keep_alive max_persistent_requests  \
        max_sessions ssl_enable sequential_session_reuse ssl_version certificate\
        certificate_file private_key private_key_file private_key_password      \
        client_ciphers                                                          \
        request_timeout tos_enable tos large_header_enable                      \
        loop_enable max_header_len max_pipeline tcp_close_option                ]
    set agent_args [list]
    
    set action_option_list  [list procName mode handle a_abort a_command    \
        a_arguments a_destination a_destination_port a_page_handle          \
        a_profile_handle                                                    ]
    set action_args [list]
    
    set profile_option_list  [list procName mode handle                     \
        pr_case_insensitive_match pr_substring pr_substring_match_enable    \
        pr_basic_auth pr_user_id pr_password                                ]
    set profile_args [list]
    
    set rh_option_list  [list procName mode handle rh_data]
    set rh_args [list]

    set option_variables "agent_option_list agent_args action_option_list \
            action_args profile_option_list profile_args rh_option_list rh_args"
    
    foreach {property_list property_args} $option_variables {
        set _o_list [set $property_list]
        foreach item $_o_list {
            if {[info exists $item]} {
                lappend $property_args "-$item"
                lappend $property_args "\"[set $item]\""
            }
        }
    }
    switch -- $property {
        client -
        agent {
            set returnList [eval [format "%s %s" ::ixia::ixL47HttpAgent \
                    $agent_args]]
            return $returnList
        }
        action {
            set returnList [eval [format "%s %s" ::ixia::ixL47HttpAction \
                    $action_args]]
            return $returnList
        }
        profile {
            set returnList [eval [format "%s %s" ::ixia::ixL47HttpProfile \
                    $profile_args]]
            return $returnList
        }
        request_header {
            set returnList [eval [format "%s %s" ::ixia::ixL47HttpRequestHeader \
                    $rh_args]]
            return $returnList
        }
        default {}
    }
}


proc ::ixia::L47_http_server { args } {
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
                \{::ixia::L47_http_server $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    set returnList [checkIxLoad HTTP]
    if {[keylget returnList status] == $::FAILURE} {
        return $returnList
    }
    
    # Arguments
    set mandatory_args {
        -mode        CHOICES add remove modify enable disable
    }
    
    set opt_args {
        -property                  CHOICES server agent cookie cookie_content
                                   CHOICES response_header web_page 
        -handle                    ANY
        -accept_ssl_connections    CHOICES 0 1
                                   DEFAULT 0
        -server_ciphers            ANY
        -DH_support_enable         CHOICES 0 1
                                   DEFAULT 0
        -esm_enable                CHOICES 0 1
                                   DEFAULT 0
        -tos_enable                CHOICES 0 1
                                   DEFAULT 0
        -esm                       NUMERIC
                                   DEFAULT 1460
        -http_port                 RANGE 1-65535
                                   DEFAULT 80
        -https_port                RANGE 1-65535
                                   DEFAULT 443
        -request_timeout           RANGE 1-64000
                                   DEFAULT 300
        -tcp_close_option          CHOICES 0 1 2
        -tos                       RANGE 0-255
                                   DEFAULT 0
        -certificate               ANY
        -certificate_file          ANY
        -private_key               ANY
        -private_key_file          ANY
        -private_key_password      ANY
        -c_mode                    CHOICES ignore set_cookie1 set_cookie2 normal
                                   DEFAULT normal
        -c_type                    CHOICES cookie1 cookie2
                                   DEFAULT cookie2 
        -cc_domain                 ANY
        -cc_max_age                NUMERIC
        -cc_path                   ANY
        -cc_value                  ANY
        -cc_name                   ANY
        -rh_code                   NUMERIC
                                   DEFAULT 200 
        -rh_expiration_after_last_modified_value NUMERIC
                                                 DEFAULT 3600 
        -rh_expiration_after_request_value       NUMERIC
                                                 DEFAULT 3600        
        -rh_expiration_date_time_value           ANY
                                                 DEFAULT "2004/12/31 23:59:59"
        -rh_expiration_mode                      CHOICES never date_time after_request 
                                                 CHOICES after_last_modified
                                                 DEFAULT never
        -rh_last_modified_date_time_value        ANY
                                                 DEFAULT "2004/12/31 23:59:59"
        -rh_last_modified_increment_by           NUMERIC
                                                 DEFAULT 5
        -rh_last_modified_increment_enable       CHOICES 0 1
                                                 DEFAULT 0
        -rh_last_modified_increment_for          NUMERIC
                                                 DEFAULT 1
        -rh_last_modified_mode                   CHOICES never date_time
                                                 DEFAULT never
        -rh_mime_type                            ANY
                                                 DEFAULT "text/plain"
        -rh_name                                 ANY
                                                 DEFAULT "200_OK"
        -rh_key                                  ANY
        -rh_value                                ANY
        -wp_cookie                               ANY
        -wp_response                             ANY
        -wp_page                                 ANY
                                                 DEFAULT "/newPage.html"
        -wp_payload_file                         ANY
        -wp_payload_size                         ANY
                                                 DEFAULT 4096
        -wp_payload_type                         CHOICES range file
                                                 DEFAULT range
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
            set property [::ixia::ixL47GetProperty $handle http]
        }
    }
    
    if {($property == "server") && ($mode != "add") && ($mode != "remove")} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: When \
                -mode is $mode, -property $property is not supported."
        return $returnList
    }
    
    set agent_option_list [list procName target mode property handle           \
            accept_ssl_connections DH_support_enable esm_enable tos_enable     \
            esm http_port https_port request_timeout tcp_close_option          \
            tos certificate certificate_file private_key private_key_file      \
            private_key_password ]
    set agent_args [list]
    
    set cookie_option_list [list  procName mode handle target c_mode c_type]
    set cookie_args [list] 

    set cc_option_list [list  procName mode handle target cc_domain   \
            cc_max_age cc_path cc_value cc_name]
    set cc_args [list]
    
    set header_option_list [list procName mode handle target                \
            rh_code rh_expiration_mode rh_expiration_date_time_value        \
            rh_expiration_after_request_value                               \
            rh_expiration_after_last_modified_value                         \
            rh_last_modified_mode rh_last_modified_date_time_value          \
            rh_last_modified_increment_enable rh_last_modified_increment_by \
            rh_last_modified_increment_for  rh_mime_type rh_name rh_key     \
            rh_value]
    set header_args [list]
    
    set page_option_list [list procName mode handle target \
            wp_page wp_payload_file wp_payload_type wp_payload_size wp_cookie \
            wp_response]
    set page_args [list]
    
    set option_variables "agent_option_list agent_args cookie_option_list      \
            cookie_args cc_option_list cc_args header_option_list header_args  \
            page_option_list page_args"

    foreach {property_list property_args} $option_variables {
        set _o_list [set $property_list]
        foreach item $_o_list {
            if {[info exists $item]} {
                lappend $property_args "-$item"
                lappend $property_args "\"[set $item]\""
            }
        }
    }

    switch -- $property {
        server -
        agent {
            set returnList [eval [format "%s %s" ::ixia::ixL47HttpAgent \
                    $agent_args]]
            return $returnList
        }
        cookie {
            set returnList [eval [format "%s %s" ::ixia::ixL47HttpCookieList \
                    $cookie_args]]
            return $returnList
        }
        cookie_content {
            set returnList [eval [format "%s %s" ::ixia::ixL47HttpCookie     \
                    $cc_args]]
            return $returnList
        }
        response_header {
            set returnList [eval [format "%s %s" ::ixia::ixL47HttpHeader     \
                    $header_args]]
            return $returnList
        }
        web_page {
            set returnList [eval [format "%s %s" ::ixia::ixL47HttpPage \
                    $page_args]]
            return $returnList
        }
        default {}
    }
    
}
