##Library Header
# $Id: $
# Copyright © 2003-2007 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_stp_api.tcl
#
# Purpose:
#     A script development library containing STP APIs for test automation
#     with the Ixia chassis.
#
# Author:
#    Radu Antonescu
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures contained within this library include:
#
#    - emulation_stp_bridge_config
#    - emulation_stp_msti_config
#    - emulation_stp_vlan_config
#    - emulation_stp_lan_config
#    - emulation_stp_control
#    - emulation_stp_info
#
# Requirements:
#     ixiaapiutils.tcl , a library containing TCL utilities
#     utils_ixnetwork.tcl, a library containing IxNetwork utilities
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

proc ::ixia::emulation_stp_bridge_config { args } {

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
                \{::ixia::emulation_stp_bridge_config $args\}]
        
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
        -auto_pick_bridge_mac             CHOICES 0 1
                                          DEFAULT 1
        -auto_pick_port                   CHOICES 0 1
                                          DEFAULT 1
        -bridge_mac                       VCMD ::ixia::validate_mac_address
                                          DEFAULT 0F00.0000.0000
        -bridge_mac_step                  VCMD ::ixia::validate_mac_address
                                          DEFAULT 0000.0000.0001
        -bridge_mode                      CHOICES mstp pvst rpvst rstp stp pvstp
                                          DEFAULT rstp
        -bridge_msti_vlan                 
                                          DEFAULT all
        -bridge_priority                  CHOICES 0 4096 8192 12288 16384
                                          CHOICES 20480 24576 28672 32768
                                          CHOICES 36864 40960 45056 49152 
                                          CHOICES 53248 57344 61440
                                          DEFAULT 32768
        -bridge_system_id                 RANGE   0-4095
                                          DEFAULT 0
        -cist_external_root_cost          RANGE   0-4294967295
                                          DEFAULT 0
        -cist_external_root_mac           VCMD ::ixia::validate_mac_address
                                          DEFAULT 0000.0000.0001
        -cist_external_root_priority      CHOICES 0 4096 8192 12288 16384
                                          CHOICES 20480 24576 28672 32768
                                          CHOICES 36864 40960 45056 49152 
                                          CHOICES 53248 57344 61440
                                          DEFAULT 32768
        -cist_reg_root_cost               RANGE   0-4294967295
                                          DEFAULT 0
        -cist_reg_root_mac                VCMD ::ixia::validate_mac_address
                                          DEFAULT 0000.0000.0000
        -cist_reg_root_priority           CHOICES 0 4096 8192 12288 16384
                                          CHOICES 20480 24576 28672 32768
                                          CHOICES 36864 40960 45056 49152 
                                          CHOICES 53248 57344 61440
                                          DEFAULT 32768
        -cist_remaining_hop               RANGE   0-255
                                          DEFAULT 20
        -count                            RANGE   1-200
                                          DEFAULT 1
        -cst_root_mac_address             VCMD ::ixia::validate_mac_address
                                          DEFAULT 0000.0000.0000
        -cst_root_path_cost               RANGE   0-4294967295
                                          DEFAULT 0
        -cst_root_priority                CHOICES 0 4096 8192 12288 16384
                                          CHOICES 20480 24576 28672 32768
                                          CHOICES 36864 40960 45056 49152 
                                          CHOICES 53248 57344 61440
                                          DEFAULT 32768
        -cst_vlan_port_priority           RANGE 0-63
                                          DEFAULT 32
        -enable_jitter                    CHOICES 0 1
                                          DEFAULT 0
        -forward_delay                    RANGE   500-255000
                                          DEFAULT 15000
        -handle
        -hello_interval                   RANGE   500-255000
                                          DEFAULT 2000
        -inter_bdpu_gap                   RANGE   0-60000
                                          DEFAULT 0
        -interface_handle
        -intf_cost                        RANGE   1-4294967295
                                          DEFAULT 1
        -intf_count                       RANGE   1-100
                                          DEFAULT 1
        -intf_gw_ip_addr                  IPV4
                                          DEFAULT 0.0.0.0
        -intf_gw_ip_addr_step             IPV4
                                          DEFAULT 0.0.1.0
        -intf_gw_ip_addr_bridge_step      IPV4
                                          DEFAULT 0.1.0.0
        -intf_ip_addr                     IP
        -intf_ip_prefix_length            RANGE   1-32
                                          DEFAULT 24
        -intf_ip_addr_step                IP
                                          DEFAULT 0.0.1.0
        -intf_ip_addr_bridge_step         IP
                                          DEFAULT 0.1.0.0
        -intf_ipv6_addr                   IPV6
        -intf_ipv6_prefix_length          RANGE   1-128
                                          DEFAULT 64
        -intf_ipv6_addr_step              IPV6
                                          DEFAULT 0:0:0:1::0
        -intf_ipv6_addr_bridge_step       IPV6
                                          DEFAULT 0:0:1::0
        -jitter_percentage                RANGE   0-100
                                          DEFAULT 0
        -link_type                        CHOICES point_to_point shared
                                          DEFAULT point_to_point
        -mac_address_bridge_step          VCMD ::ixia::validate_mac_address
                                          DEFAULT 0000.0001.0000
        -mac_address_init                 VCMD ::ixia::validate_mac_address
                                          DEFAULT 0000.0000.0000
        -mac_address_intf_step            VCMD ::ixia::validate_mac_address
                                          DEFAULT 0000.0000.0001
        -max_age                          RANGE   500-255000
                                          DEFAULT 20000
        -message_age                      RANGE   0-65535
                                          DEFAULT 0
        -mode                             CHOICES create modify delete 
                                          CHOICES enable disable
                                          DEFAULT create
        -mstc_name                        ANY
        -mstc_revision                    RANGE   0-65535
                                          DEFAULT 0
        -mtu                              RANGE   64-1514
                                          DEFAULT 1500
        -override_existence_check         CHOICES 0 1
                                          DEFAULT 0
        -override_tracking                CHOICES 0 1
                                          DEFAULT 0
        -port_handle                      REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -port_no                          RANGE   1-4095
                                          DEFAULT 1
        -port_no_bridge_step              RANGE 0-4095
                                          DEFAULT 0
        -port_no_intf_step                RANGE 0-4095
                                          DEFAULT 1
        -port_priority                    CHOICES 0 16 32 48 64 80 96 112 
                                          CHOICES 128 144 160 176 208 224 
                                          CHOICES 240
                                          DEFAULT 0
        -pvid                             RANGE   1-4094
                                          DEFAULT 1
        -reset                            FLAG
        -root_cost                        RANGE   0-4294967295
        -root_mac                         VCMD ::ixia::validate_mac_address
                                          DEFAULT 0000.0000.0000
        -root_priority                    CHOICES 0 12288 16384 20480 24576 
                                          CHOICES 28672 32768 36864 4096 
                                          CHOICES 40960 49152 53248 57344 
                                          CHOICES 61440 8192
                                          DEFAULT 32768
        -root_system_id                   RANGE   0-4095
                                          DEFAULT 0
        -vlan                             CHOICES 0 1
                                          DEFAULT 0
        -vlan_id                          REGEXP  ^([0-9]+,)*[0-9]+$
                                          DEFAULT 1
        -vlan_id_intf_step                REGEXP  ^([0-9]+,)*[0-9]+$
                                          DEFAULT 1
        -vlan_id_bridge_step              REGEXP  ^([0-9]+,)*[0-9]+$
                                          DEFAULT 0
        -vlan_user_priority               REGEXP  ^([0-7],)*[0-7]$
                                          DEFAULT 0
        -vlan_user_priority_intf_step     RANGE   ^([0-7],)*[0-7]$
                                          DEFAULT 0
        -vlan_user_priority_bridge_step   RANGE   ^([0-7],)*[0-7]$
                                          DEFAULT 0
    }
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_stp_bridge_config $args $opt_args]
        
    } else {
        # set returnList [::ixia::ixprotocol_stp_bridge_config $args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "STP is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    return $returnList
}

proc ::ixia::emulation_stp_msti_config { args } {

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
                \{::ixia::emulation_stp_msti_config $args\}]
        
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
        -bridge_handle                ANY
        -count                        RANGE 1-200
                                      DEFAULT 1
        -mode                         CHOICES create modify delete
                                      CHOICES enable disable
                                      DEFAULT create
        -msti_hops                    RANGE 0-255
                                      DEFAULT 20
        -msti_id                      RANGE  1-4094
                                      DEFAULT 1
        -msti_id_step                 RANGE 0-4093
                                      DEFAULT 0
        -msti_internal_root_path_cost RANGE 0-4294967295
                                      DEFAULT 0
        -msti_mac  VCMD ::ixia::validate_mac_address
                                      DEFAULT 0000.0000.0001
        -msti_mac_step  VCMD ::ixia::validate_mac_address
                                      DEFAULT 0000.0000.0001
        -msti_name                    ANY
                                      DEFAULT "MSTI ID-%"
        -msti_port_priority           CHOICES 0 16 32 48 64 80 96 112 
                                      CHOICES 128 144 160 176 208 224 
                                      CHOICES 240
                                      DEFAULT 0
        -msti_priority                CHOICES 0 4096 8192 12288 16384 
                                      CHOICES 20480 24576 28672 32768
                                      CHOICES 36864 40960 49152 53248
                                      CHOICES 57344 61440
                                      DEFAULT 32768
        -msti_vlan_start              RANGE 1-4094
                                      DEFAULT 1
        -msti_vlan_start_step         RANGE 1-4094
                                      DEFAULT 1
        -msti_vlan_stop               RANGE 1-4094
                                      DEFAULT 1
        -msti_vlan_stop_step          RANGE 1-4094
                                      DEFAULT 1
        -msti_wildcard_percent_enable CHOICES 0 1
                                      DEFAULT 1
        -msti_wildcard_percent_start  RANGE 0-4294967295
                                      DEFAULT 1
        -msti_wildcard_percent_step   RANGE 1-4294967295
                                      DEFAULT 1
        -handle                       ANY
    }
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_stp_msti_config $args $opt_args]
    } else {
        # set returnList [::ixia::ixprotocol_stp_msti_config $args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "STP is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    return $returnList
}

proc ::ixia::emulation_stp_vlan_config { args } {

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
                \{::ixia::emulation_stp_vlan_config $args\}]
        
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
        -bridge_handle
        -count                   RANGE 1-4094
                                 DEFAULT 1
        -handle
        -internal_root_path_cost RANGE 0-4294967295
                                 DEFAULT 0
        -mode                    CHOICES create modify delete 
                                 CHOICES enable disable
                                 DEFAULT create
        -root_mac_address        VCMD ::ixia::validate_mac_address
                                 DEFAULT 0000.0000.0000
        -root_mac_address_step   VCMD ::ixia::validate_mac_address
                                 DEFAULT 0000.0000.0001
        -root_priority           CHOICES 0 12288 16384 20480 24576 
                                 CHOICES 28672 32768 36864 4096 
                                 CHOICES 40960 49152 53248 57344 
                                 CHOICES 61440 8192 45056
                                 DEFAULT 32768
        -vlan_port_priority      RANGE 0-63
                                 DEFAULT 32
        -vlan_port_priority_step RANGE 0-63
                                 DEFAULT 1
        -vlan_id                 RANGE 2-4094
        -vlan_id_step            RANGE 0-4092
                                 DEFAULT 1
    }
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_stp_vlan_config $args $opt_args]
    } else {
        # set returnList [::ixia::ixprotocol_stp_vlan_config $args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "STP is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    return $returnList
}

proc ::ixia::emulation_stp_lan_config { args } {

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
                \{::ixia::emulation_stp_lan_config $args\}]
        
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
        -count            RANGE 1-4294967295
                          DEFAULT 1
        -handle           ANY
        -mac_address      VCMD ::ixia::validate_mac_address
                          DEFAULT 0000.0000.0000
        -mac_incr_enable  CHOICES 0 1
                          DEFAULT 0
        -mode             CHOICES create modify delete
                          CHOICES enable disable
                          DEFAULT create
        -port_handle      ANY
        -vlan_enable      CHOICES 0 1
                          DEFAULT 0
        -vlan_id          RANGE   1-4094
                          DEFAULT 1
        -vlan_incr_enable CHOICES 0 1
                          DEFAULT 0
    }
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_stp_lan_config $args $opt_args]
        
    } else {
        # set returnList [::ixia::ixprotocol_stp_lan_config $args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "STP is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    return $returnList
}

proc ::ixia::emulation_stp_control { args } {

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
                \{::ixia::emulation_stp_control $args\}]
        
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
        -handle
        -mode        CHOICES start stop restart bridge_topology_change 
                     CHOICES cist_topology_change update_parameters
                     DEFAULT start
        -port_handle REGEXP   ^[0-9]+/[0-9]+/[0-9]+$
    }
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_stp_control $args $opt_args]
    } else {
        # set returnList [::ixia::ixprotocol_stp_control $args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "STP is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    return $returnList
}

proc ::ixia::emulation_stp_info { args } {

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
                \{::ixia::emulation_stp_info $args\}]
        
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
        -handle 
        -mode      CHOICES aggregate_stats learned_info
                   CHOICES clear_stats
                   DEFAULT aggregate_stats
        -port_handle
    }
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_stp_info $args $opt_args]
        
    } else {
        # set returnList [::ixia::ixprotocol_stp_vlan_config $args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "STP is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    return $returnList
}
