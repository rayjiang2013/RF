##Library Header
# $Id: $
# Copyright © 2003-2007 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_mplstp_api.tcl
#
# Purpose:
#     A script development library containing MPLS-TP APIs for test automation
#     with the Ixia chassis.
#
# Author:
#    Adrian Enache
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures contained within this library include:
#
#    - emulation_mplstp_config
#    - emulation_mplstp_lsp_pw_config
#    - emulation_mplstp_control
#    - emulation_mplstp_info
#
# Requirements:
#     ixiaapiutils.tcl , a library containing TCL utilities
#     parseddashedargs.tcl , a library containing the parse_dashed_args proc
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

proc ::ixia::emulation_mplstp_config { args } {
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
                \{::ixia::emulation_mplstp_config $args\}]
        
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
        -mode                           CHOICES create modify delete enable disable
    }
    
    set opt_args {
        -router_id                      IP
                                        DEFAULT 170.0.11.1
        -router_id_step                 IP
                                        DEFAULT 0.0.1.0
        -router_count                   NUMERIC
                                        DEFAULT 1
        -port_handle                    REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -handle                         ANY
        -interface_count                NUMERIC
        -aps_channel_type               REGEXP ^[0-9A-Fa-f]{4}$
        -bfdcc_channel_type             REGEXP ^[0-9A-Fa-f]{4}$
        -delay_management_channel_type  REGEXP ^[0-9A-Fa-f]{4}$
        -high_performance_mode_enable   CHOICES 0 1
        -fault_management_channel_type  REGEXP ^[0-9A-Fa-f]{4}$
        -loss_measurement_channel_type  REGEXP ^[0-9A-Fa-f]{4}$
        -ondemand_cv_channel_type       REGEXP ^[0-9A-Fa-f]{4}$
        -pw_status_channel_type         REGEXP ^[0-9A-Fa-f]{4}$
        -y1731_channel_type             REGEXP ^[0-9A-Fa-f]{4}$
        -dut_mac_addr                   MAC
                                        DEFAULT ffff.ffff.ffff
        -dut_mac_addr_step              MAC
                                        DEFAULT 0000.0000.0001
        -interface_handle               ANY
        -no_write                       FLAG
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_mplstp_config $args $man_args $opt_args]
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "MPLS-TP is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    return $returnList
}


proc ::ixia::emulation_mplstp_lsp_pw_config { args } {
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
                \{::ixia::emulation_mplstp_lsp_pw_config $args\}]
        
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
        -mode                               CHOICES create modify delete enable disable
        -handle                             ANY
    }
    
    set opt_args {
        -count                              NUMERIC
                                            DEFAULT 1
        -alarm_traffic_class                RANGE 0-7
                                            DEFAULT 7
        -alarm_type                         CHOICES ietf y1731
                                            DEFAULT ietf
        -aps_traffic_class                  RANGE 0-7
                                            DEFAULT 7
        -aps_type                           CHOICES ietf y1731
                                            DEFAULT ietf
        -cccv_interval                      DECIMAL
                                            DEFAULT 1000
        -cccv_traffic_class                 RANGE 0-7
                                            DEFAULT 7
        -cccv_type                          CHOICES none bfdcc y1731
                                            DEFAULT bfdcc
        -description                        ANY
        -dest_ac_id                         NUMERIC
                                            DEFAULT 2
        -dest_ac_id_step                    NUMERIC
                                            DEFAULT 1
        -dest_global_id                     NUMERIC
                                            DEFAULT 1
        -dest_lsp_number                    RANGE 0-65535
                                            DEFAULT 1
        -dest_lsp_number_step               RANGE 0-65535
                                            DEFAULT 1
        -dest_mep_id                        RANGE 1-8191
                                            DEFAULT 2
        -dest_mep_id_step                   RANGE 0-8191
                                            DEFAULT 1
        -dest_node_id                       NUMERIC
                                            DEFAULT 2
        -dest_tunnel_number                 RANGE 0-65535
                                            DEFAULT 1
        -dest_tunnel_number_step            RANGE 0-65535
                                            DEFAULT 1
        -dm_time_format                     CHOICES ieee ntp
                                            DEFAULT ieee
        -dm_traffic_class                   RANGE 0-7
                                            DEFAULT 7
        -dm_type                            CHOICES ietf y1731
                                            DEFAULT ietf
        -ip_address                         IP
                                            DEFAULT 0.0.0.0
        -ip_address_mask_len                RANGE 1-32
                                            DEFAULT 24
        -ip_address_step                    NUMERIC
                                            DEFAULT 1
        -ip_host_per_lsp                    RANGE 0-100
                                            DEFAULT 0
        -ip_type                            CHOICES ipv4 ipv6
                                            DEFAULT ipv4
        -lm_counter_type                    CHOICES 32b 64b
                                            DEFAULT 32b
        -lm_initial_rx_value                NUMERIC
                                            DEFAULT 1
        -lm_initial_tx_value                NUMERIC
                                            DEFAULT 1
        -lm_rx_step                         NUMERIC
                                            DEFAULT 1
        -lm_traffic_class                   RANGE 0-7
                                            DEFAULT 7
        -lm_tx_step                         NUMERIC
                                            DEFAULT 1
        -lm_type                            CHOICES ietf y1731
                                            DEFAULT ietf
        -lsp_incoming_label                 RANGE 16-1048575
                                            DEFAULT 16
        -lsp_incoming_label_step            RANGE 1-1048575
                                            DEFAULT 1
        -lsp_outgoing_label                 RANGE 16-1048575
                                            DEFAULT 16        
        -lsp_outgoing_label_step            RANGE 1-1048575
                                            DEFAULT 1
        -mac_address                        MAC
                                            DEFAULT 0000.0000.0000
        -mac_per_pw                         RANGE 0-100
                                            DEFAULT 0
        -meg_id_integer_step                NUMERIC
                                            DEFAULT 0
        -meg_id_prefix                      ANY
                                            DEFAULT Ixia-0001
        -meg_level                          RANGE 0-7
                                            DEFAULT 7
        -lsp_count                          RANGE 1-20000
                                            DEFAULT 1
        -pw_per_lsp_count                   RANGE 1-20000
                                            DEFAULT 1
        -on_demand_cv_traffic_class         RANGE 0-7
                                            DEFAULT 7
        -peer_lsp_pw_range                  ANY
        -peer_nested_lsp_pw_range           ANY
        -pw_incoming_label                  RANGE 16-1048575
                                            DEFAULT 16
        -pw_incoming_label_step             RANGE 1-1048575
                                            DEFAULT 1
        -pw_incoming_label_step_across_lsp  RANGE 0-1048575
                                            DEFAULT 0
        -pw_outgoing_label                  RANGE 16-1048575
                                            DEFAULT 16
        -pw_outgoing_label_step             RANGE 1-1048575
                                            DEFAULT 0
        -pw_outgoing_label_step_across_lsp  RANGE 0-1048575
                                            DEFAULT 0
        -pw_status_traffic_class            RANGE 0-7
                                            DEFAULT 7
        -pw_status_fault_reply_interval     NUMERIC
                                            DEFAULT 600
        -range_role                         CHOICES none working protect
                                            DEFAULT none
        -repeat_mac                         CHOICES 0 1
                                            DEFAULT 0
        -src_ac_id                          NUMERIC
                                            DEFAULT 1
        -src_ac_id_step                     NUMERIC
                                            DEFAULT 1
        -src_global_id                      NUMERIC
                                            DEFAULT 1
        -src_lsp_number                     RANGE 0-65535
                                            DEFAULT 1
        -src_lsp_number_step                RANGE 0-65535
                                            DEFAULT 1
        -src_mep_id                         RANGE 1-8191
                                            DEFAULT 1
        -src_mep_id_step                    RANGE 0-8191
                                            DEFAULT 1
        -src_node_id                        NUMERIC
                                            DEFAULT 1
        -src_tunnel_number                  RANGE 0-65535
                                            DEFAULT 1
        -src_tunnel_number_step             RANGE 0-65535
                                            DEFAULT 1
        -support_slow_start                 CHOICES 0 1
                                            DEFAULT 0
        -protection_switching_type          CHOICES one_to_one_bidir one_plus_one_bidir one_to_one_unidir one_plus_one_unidir
                                            DEFAULT one_to_one_bidir
        -range_type                         CHOICES lsp pw nested
                                            DEFAULT lsp
        -vlan_count                         RANGE 1-6
        -vlan_id                            ANY
                                            DEFAULT 1
        -vlan_increment_mode                CHOICES inner_first outer_first none parallel
                                            DEFAULT none
        -vlan_priority                      ANY
                                            DEFAULT 0
        -vlan_tp_id                         ANY
                                            DEFAULT 8100
        -skip_zero_vlan_id                  CHOICES 0 1
                                            DEFAULT 0
        -wait_to_revert_time                RANGE 10-429967295
        -no_write                           FLAG
    }
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_mplstp_lsp_pw_config $args $man_args $opt_args]
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "MPLS-TP is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    return $returnList
}


proc ::ixia::emulation_mplstp_control { args } {

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
                \{::ixia::emulation_mplstp_control $args\}]
        
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
        -mode          CHOICES start stop restart trigger
    }
    #TODO: add params after bug with missing trigger params
    set opt_args {
        -port_handle    REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -handle         ANY
        -alarm_enable                                   CHOICES 0 1
                                                        DEFAULT 0
        -alarm_trigger                                  CHOICES start clear
                                                        DEFAULT start
        -alarm_type                                     CHOICES ietf y1731
                                                        DEFAULT ietf
        -alarm_ais_enable                               CHOICES 0 1
                                                        DEFAULT 1
        -alarm_lck_enable                               CHOICES 0 1
                                                        DEFAULT 0
        -alarm_set_ldi_enable                           CHOICES 0 1
                                                        DEFAULT 1
        -alarm_periodicity                              RANGE 100-4294967295
                                                        DEFAULT 5000
        -aps_trigger_enable                             CHOICES 0 1
                                                        DEFAULT 0
        -aps_trigger_type                               CHOICES clear exercise freeze lockout forced_switch manual_switch
                                                        DEFAULT forced_switch
        -cccv_pause_trigger_option                      CHOICES tx rx both
                                                        DEFAULT tx
        -cccv_resume_trigger_option                     CHOICES tx rx both
                                                        DEFAULT tx
        -cccv_pause_enable                              CHOICES 0 1
                                                        DEFAULT 0
        -cccv_resume_enable                             CHOICES 0 1
                                                        DEFAULT 0
        -dm_trigger_enable                              CHOICES 0 1
                                                        DEFAULT 0
        -dm_interval                                    RANGE 5-4294967295
                                                        DEFAULT 1000
        -dm_iterations                                  RANGE 1-4294967295
                                                        DEFAULT 10
        -dm_mode                                        CHOICES response_expected no_response_expected
                                                        DEFAULT response_expected
        -dm_pad_len                                     RANGE 0-9000
                                                        DEFAULT 0
        -dm_request_padded_reply                        CHOICES 0 1
                                                        DEFAULT 0
        -dm_time_format                                 CHOICES ntp ieee
                                                        DEFAULT ntp
        -dm_traffic_class                               RANGE 0-7
                                                        DEFAULT 7
        -dm_type                                        CHOICES ietf y1731
                                                        DEFAULT ietf
        -last_dm_response_timeout                       RANGE 5-4294967295
                                                        DEFAULT 1000
        -last_lm_response_timeout                       NUMERIC
                                                        DEFAULT 1000
        -lm_trigger_enable                              CHOICES 0 1
                                                        DEFAULT 0
        -lm_initial_rx_value                            NUMERIC
                                                        DEFAULT 0
        -lm_initial_tx_value                            NUMERIC
                                                        DEFAULT 0
        -lm_interval                                    NUMERIC
                                                        DEFAULT 1000
        -lm_iterations                                  NUMERIC
                                                        DEFAULT 10
        -lm_mode                                        CHOICES response_expected no_response_expected
                                                        DEFAULT response_expected
        -lm_rx_step                                     NUMERIC
                                                        DEFAULT 0
        -lm_tx_step                                     NUMERIC
                                                        DEFAULT 0
        -lm_traffic_class                               RANGE 0-7
                                                        DEFAULT 7
        -lm_type                                        CHOICES ietf y1731
                                                        DEFAULT ietf
        -lm_counter_type                                CHOICES 32b 64b
                                                        DEFAULT 32b
        -lsp_ping_enable                                CHOICES 0 1
                                                        DEFAULT 0
        -lsp_ping_encapsulation_type                    CHOICES gach udp_ip_gach
                                                        DEFAULT gach
        -lsp_ping_fec_stack_validation_enable           CHOICES 0 1
                                                        DEFAULT 1
        -lsp_ping_response_timeout                      RANGE 1000-4294967295
                                                        DEFAULT 1000
        -lsp_ping_ttl_value                             RANGE 1-255
                                                        DEFAULT 255
        -lsp_trace_route_enable                         CHOICES 0 1
                                                        DEFAULT 0
        -lsp_trace_route_encapsulation_type             CHOICES gach udp_ip_gach
                                                        DEFAULT gach
        -lsp_trace_route_fec_stack_validation_enable    CHOICES 0 1
                                                        DEFAULT 1
        -lsp_trace_route_response_timeout               RANGE 1000-4294967295
                                                        DEFAULT 1000
        -lsp_trace_route_ttl_limit                      RANGE 1-255
                                                        DEFAULT 5
        -pw_status_clear_enable                         CHOICES 0 1
                                                        DEFAULT 0        
        -pw_status_clear_label_ttl                      RANGE 1-255
                                                        DEFAULT 1
        -pw_status_clear_transmit_interval              RANGE 1-65535
                                                        DEFAULT 30
        -pw_status_code                                 REGEXP ^[0-9A-Fa-f]{8}$
                                                        DEFAULT 00000001
        -pw_status_fault_enable                         CHOICES 0 1
                                                        DEFAULT 0
        -pw_status_fault_label_ttl                      RANGE 1-255
                                                        DEFAULT 1   
        -pw_status_fault_transmit_interval              RANGE 1-65535
                                                        DEFAULT 30
        -incoming_inner_label                           REGEXP ^(\d+:\d+:\d+|\d+)+$
                                                        DEFAULT 0
        -incoming_outer_label                           REGEXP ^(\d+:\d+:\d+|\d+)+$
                                                        DEFAULT 0
        -outgoing_inner_label                           REGEXP ^(\d+:\d+:\d+|\d+)+$
                                                        DEFAULT 0
        -outgoing_outer_label                           REGEXP ^(\d+:\d+:\d+|\d+)+$
                                                        DEFAULT 0
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_mplstp_control $args $man_args $opt_args]
        
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "MPLS-TP is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    return $returnList
}


proc ::ixia::emulation_mplstp_info { args } {
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
                \{::ixia::emulation_mplstp_info $args\}]
        
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
        -mode           CHOICES aggregate_stats learned_info general_learned_info lm_learned_info dm_learned_info ping_learned_info trace_route_learned_info clear_stats
    }
    set opt_args {
        -port_handle                                    REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -handle                                         ANY
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_mplstp_info $args $man_args $opt_args]
        
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "MPLS-TP is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    return $returnList
}

