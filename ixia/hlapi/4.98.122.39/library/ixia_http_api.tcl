##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_http_api.tcl
#
# Purpose:
#    A script development library containing http APIs for test automation
#    with the Ixia chassis.
#
# Author:
#    Ixia engineering, direct all communication to support@ixiacom.com
#
# Usage:
#
# Description:
#    The procedures contained within this library include:
#
#    -emulation_http_config
#    -emulation_http_traffic_config
#    -emulation_http_traffic_type_config
#    -emulation_http_control_config
#    -emulation_http_control
#    -emulation_http_stats
#
# Requirements:
#    ixiaapiutils.tcl , a library containing TCL utilities
#    parseddashedargs.tcl , a library containing the procDescr and
#    parsedashedargds.tcl
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
# meet the user's requirements or (ii) that the script will be without      #
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


proc ::ixia::emulation_http_config { args } {
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
                \{::ixia::emulation_http_config $args\}]
        
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
        
        -property                       CHOICES http network router_addr dns
        -handle                         ANY
        -target                         CHOICES client server
                                        DEFAULT client
        -port_handle                    REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -mac_mapping_mode               CHOICES macip macport
                                        DEFAULT macip
        -source_port_from               RANGE 1024-65535
                                        DEFAULT 1024
        -source_port_to                 RANGE 1024-65535
                                        DEFAULT 65535
        -emulated_router_gateway        IP
                                        DEFAULT 0.0.0.0
        -emulated_router_subnet         MASK
                                        DEFAULT 255.255.255.0
        -dns_cache_timeout              NUMERIC
                                        DEFAULT 30000
        -grat_arp_enable                CHOICES 0 1
                                        DEFAULT 0
        -congestion_notification_enable CHOICES 0 1
                                        DEFAULT 0
        -time_stamp_enable              CHOICES 0 1
                                        DEFAULT 1
        -rx_bandwidth_limit_enable      CHOICES 0 1
                                        DEFAULT 0
        -tx_bandwidth_limit_enable      CHOICES 0 1
                                        DEFAULT 0
        -fin_timeout                    NUMERIC
                                        DEFAULT 60
        -keep_alive_interval            NUMERIC
                                        DEFAULT 7200
        -keep_alive_probes              NUMERIC
                                        DEFAULT 9
        -keep_alive_time                NUMERIC
                                        DEFAULT 75
        -receive_buffer_size            NUMERIC
                                        DEFAULT 4096
        -retransmit_retries             NUMERIC
                                        DEFAULT 15
        -rx_bandwidth_limit             NUMERIC
        -rx_bandwidth_limit_unit        CHOICES kb mb
                                        DEFAULT kb
        -syn_ack_retries                NUMERIC
                                        DEFAULT 5
        -syn_retries                    NUMERIC
                                        DEFAULT 5
        -transmit_buffer_size           NUMERIC
                                        DEFAULT 4096
        -tx_bandwidth_limit             NUMERIC
        -tx_bandwidth_limit_unit        CHOICES kb mb
                                        DEFAULT kb
        -ip_address_start               IP
                                        DEFAULT 198.18.0.1
        -mac_address_start              MAC
                                        DEFAULT 00.C6.12.00.01.00
        -gateway                        IP
                                        DEFAULT 0.0.0.0
        -ip_count                       NUMERIC
                                        DEFAULT 100
        -ip_increment_step              IP
                                        DEFAULT 0.0.0.1
        -mac_increment_step             MAC
                                        DEFAULT 00.00.00.00.00.01
        -mss                            NUMERIC
                                        DEFAULT 1460
        -mss_enable                     CHOICES 0 1
                                        DEFAULT 0
        -network_mask                   MASK
                                        DEFAULT 255.255.0.0
        -vlan_enable                    CHOICES 0 1
                                        DEFAULT 0
        -vlan_id                        NUMERIC
        -dns_server                     IP
        -dns_suffix                     REGEXP ^\.[A-z]+\.[A-z]+$
        -pool_ip_address_start          IP
                                        DEFAULT 194.18.0.1
        -pool_ip_count                  NUMERIC
                                        DEFAULT 1
        -pool_mac_address_start         ANY
                                        DEFAULT 00.C2.12.00.01.00
        -pool_network                   MASK
                                        DEFAULT 255.255.0.0
        -pool_vlan_enable               CHOICES 0 1
                                        DEFAULT 0
        -pool_vlan_id                   NUMERIC
    }
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $mandatory_args
    
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
            set property [::ixia::ixLoadGetProperty $handle http]
        }
    }
    
    set http_option_list [list   procName mode handle target port_handle     \
            mac_mapping_mode source_port_from source_port_to                 \
            emulated_router_gateway emulated_router_subnet dns_cache_timeout \
            grat_arp_enable congestion_notification_enable time_stamp_enable \
            rx_bandwidth_limit_enable tx_bandwidth_limit_enable fin_timeout  \
            keep_alive_interval  keep_alive_probes keep_alive_time           \
            receive_buffer_size retransmit_retries rx_bandwidth_limit        \
            rx_bandwidth_limit_unit syn_ack_retries syn_retries              \
            transmit_buffer_size tx_bandwidth_limit tx_bandwidth_limit_unit  ]
    
    set http_args [list]
    
    set net_option_list  [list procName mode handle ip_address_start \
            mac_address_start gateway ip_count ip_increment_step     \
            mac_increment_step mss mss_enable network_mask           \
            vlan_enable vlan_id                                      ]
    
    set net_args [list]
    
    set addr_option_list [list procName mode handle pool_ip_address_start \
            pool_ip_count pool_mac_address_start pool_network             \
            pool_vlan_enable  pool_vlan_id emulated_router_gateway        \
            emulated_router_subnet]
    
    set addr_args [list]
    
    set dns_option_list  [list procName mode handle dns_cache_timeout \
            dns_server dns_suffix]
    
    set dns_args [list]
    
    set option_variables "http_option_list http_args net_option_list \
            net_args addr_option_list addr_args dns_option_list dns_args"
    
    
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
        http {
            set returnList [eval [format "%s %s" ::ixia::ixLoadNetwork \
                    $http_args]]
            return $returnList
        }
        network {
            if {[info exists ip_address_start]} {
                if {[ixLoadGetIpType ip_address_start net_args]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument \
                            -ip_address_start is not a valid IP address."
                    return $returnList
                }
            }
            set returnList [eval [format "%s %s" ::ixia::ixLoadRange $net_args]]
            return $returnList
        }
        router_addr {
            if {[info exists pool_ip_address_start]} {
                if {[ixLoadGetIpType pool_ip_address_start addr_args]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument \
                            -ip_address_start is not a valid IP address."
                    return $returnList
                }
            }
            set returnList [eval [format "%s %s" ::ixia::ixLoadPoolAddr \
                    $addr_args]]
            return $returnList
        }
        dns {
            set returnList [eval [format "%s %s" ::ixia::ixLoadDns $dns_args]]
            return $returnList
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -property does\
                    not have a valid value."
            return $returnList
        }
    }
}


proc ::ixia::emulation_http_traffic_config { args } {
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
                \{::ixia::emulation_http_traffic_config $args\}]
        
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
        -property                  CHOICES traffic agent
        -handle                    ANY
        -target                    CHOICES client server
                                   DEFAULT client
        -browser_emulation         CHOICES custom ie5 ie6 mozilla firefox
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
                                   DEFAULT 0
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
        -accept_ssl_connections    CHOICES 0 1
                                   DEFAULT 0
        -http_port                 RANGE 1-65535
                                   DEFAULT 80
        -https_port                RANGE 1-65535
                                   DEFAULT 443
        -request_timeout           RANGE 1-64000
                                   DEFAULT 300
        -tos_enable                CHOICES 0 1
                                   DEFAULT 0
        -tos                       RANGE 0-255
                                   DEFAULT 0
    }
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $mandatory_args
    
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
            set property [::ixia::ixLoadGetProperty $handle http]
        }
    }
    
    set traffic_option_list  [list procName mode handle target ]
    set traffic_args [list]
    set agent_option_list [list procName mode handle target browser_emulation \
            cookie_jar_size cookie_reject_probability cookie_support_enable   \
            esm_enable esm http_proxy_enable https_proxy_enable ip_preference \
            follow_http_redirects http_proxy https_proxy http_version         \
            keep_alive max_persistent_requests max_sessions ssl_enable        \
            sequential_session_reuse ssl_version certificate certificate_file \
            private_key private_key_file private_key_password client_ciphers  \
            accept_ssl_connections http_port https_port request_timeout       \
            tos_enable tos]
    set agent_args [list]
    set option_variables "traffic_option_list traffic_args agent_option_list \
            agent_args"
    
    foreach {property_list property_args} $option_variables {
        set _o_list [set $property_list]
        foreach item $_o_list {
            if {[info exists $item]} {
                lappend $property_args "-$item"
                lappend $property_args "[set $item]"
            }
        }
    }
    
#    debug "property=$property\ntraffic_args=$traffic_args"
    switch -- $property {
        traffic {
            set returnList [eval [format "%s %s" ::ixia::ixLoadTraffic \
                    $traffic_args]]
            return $returnList
        }
        agent {
            set returnList [eval [format "%s %s" ::ixia::ixLoadHttpAgent \
                    $agent_args]]
            return $returnList
        }
        default {}
    }
}


proc ::ixia::emulation_http_traffic_type_config { args } {
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
                \{::ixia::emulation_http_traffic_type_config $args\}]
        
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
        -property                      CHOICES action cookielist cookie
                                       CHOICES header page
        -handle                        ANY
        -abort                         CHOICES none before after
                                       DEFAULT none
        -command                       CHOICES get get_ssl delete head head_ssl 
                                       CHOICES put put_ssl post post_ssl think
                                       CHOICES  loop_begin loop_end
                                       DEFAULT get
        -arguments                     ANY
        -destination                   ANY
        -page_handle                   ANY
        -cookielist_mode               CHOICES ignore normal
                                       CHOICES setcookie1 setcookie2
                                       DEFAULT normal
        -cookielist_description        ANY
        -type                          CHOICES setcookie1 setcookie2
                                       DEFAULT setcookie2
        -domain                        NUMERIC
        -max_age                       NUMERIC
        -path                          ANY
        -cookie_name                   ANY
        -cookie_value                  ANY
        -code                          NUMERIC
                                       DEFAULT 200
        -response_name                 ANY
                                       DEFAULT 200_OK
        -response_description          ANY
                                       DEFAULT OK
        -expiration_mode               CHOICES never datetime afterrequest
                                       CHOICES afterlastmodified
                                       DEFAULT never
        -expiration_datetime           ANY
                                       DEFAULT {2009/12/31 23:59:59}
        -expiration_afterrequest       NUMERIC
                                       DEFAULT 3600
        -expiration_afterlastmodified  NUMERIC
                                       DEFAULT 3600
        -last_modified_mode            CHOICES never datetime
                                       DEFAULT never
        -last_modified_datetime        ANY
                                       DEFAULT {2004/12/31 23:59:59}
        -last_modified_incr_enable     CHOICES 0 1
                                       DEFAULT 0
        -last_modified_incr_by         NUMERIC
                                       DEFAULT 5
        -last_modified_incr_for        NUMERIC
                                       DEFAULT 1
        -mime_type                     ANY
                                       DEFAULT text/plain
        -key                           ANY
        -value                         ANY
        -url                           ANY
        -header_handle                 ANY
        -cookielist_handle             ANY
        -payload_type                  CHOICES range file
                                       DEFAULT range
        -payload_file                  ANY
        -payload_size                  ANY
                                       DEFAULT 4096
    }
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $mandatory_args
    
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
            set property [::ixia::ixLoadGetProperty $handle http]
        }
    }
    
    set action_option_list      [list procName mode handle target \
            abort arguments command destination page_handle]
    set action_args     [list]
    
    set cookielist_option_list  [list procName mode handle target \
            cookielist_description cookielist_mode readonly type  ]
    set cookielist_args [list]
    
    set cookie_option_list      [list procName mode handle target ]
    set cookie_args     [list]
    
    set header_option_list      [list procName mode handle target \
            code expiration_mode expiration_datetime              \
            expiration_afterrequest  expiration_afterlastmodified \
            last_modified_mode last_modified_datetime             \
            last_modified_incr_enable last_modified_incr_by       \
            last_modified_incr_for  mime_type response_name       ]
    set header_args     [list]
    
    set page_option_list        [list procName mode handle target \
            url payload_type payload_file payload_size cookielist_handle \
            header_handle]
    set page_args       [list]
    
    set option_variables "action_option_list action_args \
            cookielist_option_list cookielist_args cookie_option_list \
            cookie_args header_option_list header_args page_option_list \
            page_args"
    
    foreach {property_list property_args} $option_variables {
        set _o_list [set $property_list]
        foreach item $_o_list {
            if {[info exists $item]} {
                lappend $property_args "-$item"
                lappend $property_args "[set $item]"
            }
        }
    }
    
#    debug "property=$property"
    switch -- $property {
        action {
            set returnList [eval [format "%s %s" ::ixia::ixLoadHttpAction     \
                    $action_args]]
            return $returnList
        }
        cookielist {
            set returnList [eval [format "%s %s" ::ixia::ixLoadHttpCookieList \
                    $cookielist_args]]
            return $returnList
        }
        cookie {
            set returnList [eval [format "%s %s" ::ixia::ixLoadHttpCookie     \
                    $cookie_args]]
            return $returnList
        }
        header {
            set returnList [eval [format "%s %s" ::ixia::ixLoadHttpHeader     \
                    $header_args]]
            return $returnList
        }
        page {
            set returnList [eval [format "%s %s" ::ixia::ixLoadHttpPage       \
                    $page_args]]
            return $returnList
        }
        default {}
    }
}


proc ::ixia::emulation_http_control {args} {
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
                \{::ixia::emulation_http_control $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    if {[isUNIX]} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValueClicks [eval "::ixia::SendToIxTclServer $::ixTclSvrHandle {clock clicks}"]
        set retValueSeconds [eval "::ixia::SendToIxTclServer $::ixTclSvrHandle {clock seconds}"]
    } else {
        set retValueClicks [clock clicks]
        set retValueSeconds [clock seconds]
    }
    keylset returnList clicks [format "%u" $retValueClicks]
    keylset returnList seconds [format "%u" $retValueSeconds]

    set protocol HTTP
    set returnList [checkIxLoad $protocol]
    if {[keylget returnList status] == $::FAILURE} {
        return $returnList
    }
    
    # Arguments
    set mandatory_args {
        -mode        CHOICES add modify start
    }
    
    set opt_args {
        -handle                         ANY
        -map_handle                     ANY
        -force_ownership_enable         CHOICES 0 1
                                        DEFAULT 0
        -release_config_afterrun_enable CHOICES 0 1
                                        DEFAULT 0
        -reset_ports_enable             CHOICES 0 1
                                        DEFAULT 0
        -stats_required                 CHOICES 0 1
                                        DEFAULT 1
        -results_dir_enable             CHOICES 0 1
                                        DEFAULT 0
        -results_dir                    ANY
    }
    
    set args [::ixia::escapeBackslash $args results_dir]    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $mandatory_args
    
    # check to see if user created the mapping
    if {$mode == "add"} {
        if {![info exists map_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -mode is $mode, then -map_handle must be provided."
            return $returnList
        }
    }
    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
        
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -mode is $mode, then -handle must be provided."
            return $returnList
        }        
    }
    
    set control_list  [list procName mode handle map_handle dut_handle \
            stats_handle force_ownership_enable release_config_afterrun_enable\
            reset_ports_enable stats_required results_dir_enable results_dir \
            protocol ]
    
    set control_args [list]
    set option_variables "control_list control_args"
    
    foreach {property_list property_args} $option_variables {
        set _o_list [set $property_list]
        foreach item $_o_list {
            if {[info exists $item]} {
                lappend $property_args "-$item"
                lappend $property_args "[set $item]"
            }
        }
    }
    set returnList [eval [format "%s %s" ::ixia::ixLoadControl \
            $control_args]]
    keylset returnList clicks [format "%u" $retValueClicks]
    keylset returnList seconds [format "%u" $retValueSeconds]
    return $returnList
    
}


proc ::ixia::emulation_http_stats { args } {
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
                \{::ixia::emulation_http_stats $args\}]
        
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
    
    append args " -protocol http -procName $procName "
    return [eval [format "%s %s" ::ixia::ixLoadStatistics $args]]
}


proc ::ixia::emulation_http_control_config {args} {
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
                \{::ixia::emulation_http_control_config $args\}]
        
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
        -handle                      ANY
        -target                      CHOICES client server
                                     DEFAULT client
        -property                    CHOICES map dut
        -direct_server_return_enable CHOICES 0 1
                                     DEFAULT 0
        -ip_address                  IPV4
                                     DEFAULT 1.1.1.1
        -server_http_handle          ANY
        -type                        CHOICES external slb firewall
                                     DEFAULT slb
        -client_iterations           NUMERIC
                                     DEFAULT 1
        -client_http_handle          ANY
        -client_traffic_handle       ANY
        -objective_type              CHOICES na users connections crate trate
                                     CHOICES tputmb tputkb sessions
                                     DEFAULT na
        -objective_value             NUMERIC
        -client_offline_time         NUMERIC
                                     DEFAULT 0
        -port_map_policy             CHOICES pairs mesh round_robin
                                     DEFAULT pairs
        -ramp_down_time              NUMERIC
                                     DEFAULT 20
        -ramp_up_type                CHOICES users_per_second max_pending_users
                                     DEFAULT users_per_second
        -ramp_up_value               NUMERIC
        -client_standby_time         RANGE 0-3600000
                                     DEFAULT 0
        -client_sustain_time         RANGE 0-3600000
                                     DEFAULT 0
        -client_total_time           NUMERIC
                                     DEFAULT 60
        -server_traffic_handle       ANY
        -match_client_totaltime      CHOICES 0 1
                                     DEFAULT 1
        -server_iterations           NUMERIC
                                     DEFAULT 1
        -server_offline_time         NUMERIC
                                     DEFAULT 0
        -server_standby_time         RANGE 0-3600000
                                     DEFAULT 0
        -server_sustain_time         NUMERIC
                                     DEFAULT 20
        -server_total_time           NUMERIC
                                     DEFAULT 60
    }
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $mandatory_args
    
    set protocol http
    
    if {$mode == "add"} {
        if {![info exists property]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When \
                    -mode is $mode, then -property\
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
            set property [::ixia::ixLoadGetProperty $handle $protocol]
        }
    }
    
    # Mapping parameters
    set map_option_list  [list procName mode handle protocol target        \
            server_http_handle client_iterations                           \
            client_http_handle client_traffic_handle                       \
            objective_type objective_value client_offline_time             \
            port_map_policy ramp_down_time ramp_up_type                    \
            ramp_up_value client_standby_time client_sustain_time          \
            client_total_time server_traffic_handle match_client_totaltime \
            server_iterations server_offline_time server_standby_time      \
            server_sustain_time server_total_time                          ]
    
    set map_args [list]
    
    # Dut parameters
    set dut_option_list [list procName mode handle protocol \
            direct_server_return_enable   ip_address  server_http_handle \
            type]
    
    set dut_args [list]
    
    set option_variables "map_option_list map_args dut_option_list dut_args"
    
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
        map {
            set returnList [eval [format "%s %s"        \
                    ::ixia::ixLoadTrafficNetworkMapping \
                    $map_args]]
            return $returnList
        }
        dut {
            set returnList [eval [format "%s %s" ::ixia::ixLoadDut $dut_args]]
            return $returnList
        }
        
        default {}
    }
}
