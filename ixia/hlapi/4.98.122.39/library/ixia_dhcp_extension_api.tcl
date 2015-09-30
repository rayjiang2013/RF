##Library Header
# $Id: $
# Copyright © 2003-2012 by IXIA
# All Rights Reserved
#
# Name:
#    ixia_dhcp_extension_api.tcl
#
# Purpose:
#     A script development library containing DHCPv6 Client and Server 
#     extension APIs for test automation with the Ixia chassis.
#
# Author:
#    Lavinia Neagoe
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures contained within this library include:
#    - dhcp_client_extension_config
#    - dhcp_server_extension_config
#    - dhcp_extension_stats
#
#    In order to control the dhcp extension, please use the ::ixia::<protocol>_control procedure 
#    (protocol can be ppp or l2tp)
#
# Requirements:
#     parseddashedargs.tcl
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


proc ::ixia::dhcp_client_extension_config { args } {
    variable new_ixnetwork_api
    variable executeOnTclServer

    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args

    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::dhcp_client_extension_config $args\}]
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
        -handle   
    }
    
    set opt_args {
        -dhcp6_client_range_duid_enterprise_id          RANGE   1-2147483647
                                                        DEFAULT 10
        -dhcp6_client_range_duid_type                   CHOICES duid_en duid_llt duid_ll
                                                        DEFAULT duid_llt
        -dhcp6_client_range_duid_vendor_id              RANGE   1-2147483647
                                                        DEFAULT 10
        -dhcp6_client_range_duid_vendor_id_increment    RANGE   1-2147483647
                                                        DEFAULT 1
        -dhcp6_client_range_param_request_list          NUMERIC
                                                        DEFAULT {2 7 23 24}
        -dhcp6_client_range_use_vendor_class_id         CHOICES 0 1
                                                        DEFAULT 0
        -dhcp6_client_range_vendor_class_id             ANY
                                                        DEFAULT "Ixia DHCP Client"
        -dhcp6_global_rel_max_rc                        RANGE   1-100
                                                        DEFAULT 10
        -dhcp6_global_reb_max_rt                        RANGE   1-10000
                                                        DEFAULT 30
        -dhcp6_global_reb_timeout                       RANGE   1-100
                                                        DEFAULT 1
        -dhcp6_global_max_outstanding_requests          RANGE   1-100000
                                                        DEFAULT 20
        -dhcp6_global_setup_rate_increment              ANY
                                                        DEFAULT 0
        -dhcp6_global_setup_rate_initial                RANGE   1-100000
                                                        DEFAULT 10
        -dhcp6_global_setup_rate_max                    RANGE   1-100000
                                                        DEFAULT 10
        -dhcp6_pgdata_max_outstanding_requests          RANGE   1-100000
                                                        DEFAULT 20
        -dhcp6_pgdata_override_global_setup_rate        CHOICES 0 1
                                                        DEFAULT 0
        -dhcp6_pgdata_setup_rate_increment              RANGE   0-100000
                                                        DEFAULT 0
        -dhcp6_pgdata_setup_rate_initial                RANGE   1-100000
                                                        DEFAULT 10
        -dhcp6_pgdata_setup_rate_max                    RANGE   1-100000
                                                        DEFAULT 10
        -dhcp6_pgdata_associates
        -mode                                           CHOICES add remove enable disable modify
                                                        DEFAULT add
    }
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_dhcp_client_extension_config $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        return $returnList
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                IxTclProtocol API is not supported."
        return $returnList
    }
}


proc ::ixia::dhcp_server_extension_config { args } {
    variable new_ixnetwork_api
    variable executeOnTclServer

    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args

    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::dhcp_server_extension_config $args\}]
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
        -handle   
    }
    
    set opt_args {
        -dhcp6_pgdata_max_outstanding_releases          RANGE   1-100000
                                                        DEFAULT 500
        -dhcp6_pgdata_max_outstanding_requests          RANGE   1-100000
                                                        DEFAULT 20
        -dhcp6_pgdata_override_global_setup_rate        CHOICES 0 1
                                                        DEFAULT 0
        -dhcp6_pgdata_override_global_teardown_rate     CHOICES 0 1
                                                        DEFAULT 0
        -dhcp6_pgdata_setup_rate_increment              RANGE   0-100000
                                                        DEFAULT 0
        -dhcp6_pgdata_setup_rate_initial                RANGE   1-100000
                                                        DEFAULT 10
        -dhcp6_pgdata_setup_rate_max                    RANGE   1-100000
                                                        DEFAULT 10
        -dhcp6_pgdata_teardown_rate_increment           RANGE   0-100000
                                                        DEFAULT 50
        -dhcp6_pgdata_teardown_rate_initial             RANGE   1-100000
                                                        DEFAULT 50
        -dhcp6_pgdata_teardown_rate_max                 RANGE   1-100000
                                                        DEFAULT 500
        -dhcp6_server_range_dns_domain_search_list   ANY
                                                        DEFAULT 100
        -dhcp6_server_range_first_dns_server         IP
        -dhcp6_server_range_second_dns_server        IP
        -dhcp6_server_range_subnet_prefix            NUMERIC
        -dhcp6_server_range_start_pool_address       IP
        -mode                                           CHOICES add remove enable disable modify
                                                        DEFAULT add
    }
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_dhcp_server_extension_config $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        return $returnList
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                IxTclProtocol API is not supported."
        return $returnList
    }
}


proc ::ixia::dhcp_extension_stats { args } {
    variable new_ixnetwork_api
    variable executeOnTclServer

    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args

    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::dhcp_extension_stats $args\}]
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set procName [lindex [info level [info level]] 0]
        
        set man_args {
            -mode           CHOICES aggregate session
                            DEFAULT aggregate
        }
        set opt_args {
            -port_handle
            -handle
        }

        set returnList [::ixia::ixnetwork_dhcp_extension_stats $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        return $returnList
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                IxAccess API is not supported"
        return $returnList
    }
}
