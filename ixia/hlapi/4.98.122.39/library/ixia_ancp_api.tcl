
# Copyright © 2003-2009 by IXIA
# All Rights Reserved 
#
# Name:
#    ixia_ancp_api.tcl
#
# Purpose:
#    A script development library containing (Access Node Control Protocol) ANCP APIs for test automation with 
#    the Ixia chassis. 
#
# Author:
#    Lavinia Raicea
#
# Usage:
#    package req Ixia
#
# Description:
#    The procedures contained within this library include:
#        emulation_ancp_config
#        emulation_ancp_subscriber_lines_config
#        emulation_ancp_stats
#        emulation_ancp_control
#
#
# Requirements:
#     ixiaapiutils.tcl , a library containing TCL utilities
#     parseddashedargs.tcl , a library containing the argument parsing 
#     procedures 
#
# Variables:
#    To be added
#
# Keywords:
#    To be defined
#
# Category:
#    To be defined
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

proc ::ixia::emulation_ancp_config { args } {
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
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle  \{::ixia::emulation_ancp_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set opt_args {
        -access_aggregation          CHOICES   0 1
                                     DEFAULT   0
        -access_aggregation_dsl_inner_vlan      RANGE 1-4094
                                                DEFAULT   1
        -access_aggregation_dsl_inner_vlan_type CHOICES actual_dsl_subscriber_vlan custom
                                                DEFAULT   actual_dsl_subscriber_vlan
        -access_aggregation_dsl_outer_vlan      RANGE 1-4094
                                                DEFAULT   1
        -access_aggregation_dsl_outer_vlan_type CHOICES actual_dsl_subscriber_vlan custom
                                                DEFAULT   actual_dsl_subscriber_vlan
        -access_aggregation_dsl_vci             RANGE 1-65535
                                                DEFAULT   1
        -access_aggregation_dsl_vpi             RANGE 0-255
                                                DEFAULT   1
        -access_aggregation_dsl_vci_type        CHOICES actual_dsl_subscriber_vci custom
                                                DEFAULT   actual_dsl_subscriber_vci
        -access_aggregation_dsl_vpi_type        CHOICES actual_dsl_subscriber_vpi custom
                                                DEFAULT   actual_dsl_subscriber_vpi
        -ancp_standard               CHOICES   ietf-ancp-protocol2 gsmp-l2control-config2
                                     DEFAULT   ietf-ancp-protocol2
        -circuit_id                  ANY       
                                     DEFAULT   circuit
        -device_count                NUMERIC   
                                     DEFAULT   1
        -distribution_alg_percentage RANGE     0-100
                                     DEFAULT   0
        -dsl_profile_capabilities              ANY
        -dsl_resync_profile_capabilities       ANY
        -encap_type                  CHOICES   ETHERNETII VccMuxIPV4Routed VccMuxBridgedEthernetFCS
                                     CHOICES   VccMuxBridgedEthernetNoFCS VccMuxIPV6Routed SNAP
                                     CHOICES   LLCBridgedEthernetFCS LLCBridgedEthernetNoFCS
                                     CHOICES   LLCPPPoA VccMuxPPPoA SAF
                                     DEFAULT   ETHERNETII
        -events_per_interval         RANGE     1-300
        -gateway_ip_addr             IPV4      
                                     DEFAULT   0.0.0.0
        -gateway_ip_prefix_len       RANGE     0-32
                                     DEFAULT   16
        -gateway_ip_step             IPV4      
                                     DEFAULT   0.0.0.0
        -gateway_incr_mode           CHOICES   every_subnet every_interface
                                     DEFAULT   every_subnet
        -global_port_down_rate       RANGE     1-300 
                                     DEFAULT   50
        -global_port_up_rate         RANGE     1-300 
                                     DEFAULT   10
        -global_resync_rate          RANGE     1-300 
                                     DEFAULT   50
        -gsmp_standard               CHOICES   RFC-3292 gsmp-v3-base
                                     DEFAULT   gsmp-v3-base
        -handle                      ANY       
        -interval                    RANGE     1-100 
                                     DEFAULT   1
        -intf_ip_addr                IPV4      
                                     DEFAULT   10.10.10.2
        -intf_ip_prefix_len          RANGE     0-32
                                     DEFAULT   16
        -intf_ip_step                IPV4      
                                     DEFAULT   0.0.0.1
        -keep_alive                  RANGE     1000-25000
                                     DEFAULT   10000
        -keep_alive_retries          RANGE     1-10
                                     DEFAULT   3
        -line_config                 CHOICES   0 1
                                     DEFAULT   0
        -local_mac_addr              MAC       
                                     DEFAULT   000a.0a00.0200
        -local_mac_addr_auto         CHOICES   0 1
                                     DEFAULT   1
        -local_mac_step              MAC       
                                     DEFAULT   0000.0000.0001
        -local_mss                   RANGE     28-9460 
                                     DEFAULT 1460
        -local_mtu                   RANGE     500-9500
                                     DEFAULT   1500
        -mode                        CHOICES   create modify delete enable disable enable_all disable_all
                                     DEFAULT   create
        -port_down_rate              RANGE     1-300 
                                     DEFAULT   50
        -port_resync_rate            RANGE     1-300 
                                     DEFAULT   50
        -port_up_rate                RANGE     1-300 
                                     DEFAULT   50
        -port_handle                 ANY       
        -port_override_globals       CHOICES   0 1
                                     DEFAULT   1
        -pvc_incr_mode               CHOICES   vci vpi both
                                     DEFAULT   both
        -qinq_incr_mode              CHOICES   inner outer both
                                     DEFAULT   both
        -sut_ip_addr                 IPV4      
                                     DEFAULT   20.20.0.1
        -sut_ip_step                 IPV4
                                     DEFAULT 0.0.0.0
        -sut_service_port            RANGE     1-65535
                                     DEFAULT   6068
        -topology_discovery          CHOICES   0 1
                                     DEFAULT   1
        -vci                         RANGE 32-65535 
                                     DEFAULT 32
        -vci_count                   RANGE 1-65504
                                     DEFAULT 4063
        -vci_repeat                  RANGE 1-65504  
                                     DEFAULT 1
        -vci_step                    RANGE 0-65503  
                                     DEFAULT 1
        -vlan_id                     RANGE     0-4095
        -vlan_id_count               RANGE     0-4095
                                     DEFAULT   1
        -vlan_id_count_inner         RANGE     0-4095
                                     DEFAULT   1
        -vlan_id_inner               RANGE     0-4095
        -vlan_id_repeat              NUMERIC   
                                     DEFAULT   1
        -vlan_id_repeat_inner        NUMERIC   
                                     DEFAULT   1
        -vlan_id_step                RANGE     0-4095
                                     DEFAULT   1
        -vlan_id_step_inner          RANGE     0-4095
                                     DEFAULT   1
        -vlan_user_priority          RANGE     0-7
                                     DEFAULT   0
        -vlan_user_priority_inner    RANGE     0-7
                                     DEFAULT   0
        -vpi                         RANGE 0-255
                                     DEFAULT 0
        -vpi_count                   RANGE 1-256
                                     DEFAULT 1
        -vpi_repeat                  RANGE 1-65535
                                     DEFAULT 1
        -vpi_step                    RANGE 0-255
                                     DEFAULT 1
        -gateway_ip_prefix
        -gateway_ip_repeat
        -gateway_ipv6_step
        -gateway_ipv6_addr
        -gateway_ipv6_prefix
        -gateway_ipv6_prefix_len
        -gateway_ipv6_repeat
        -intf_ip_prefix
        -intf_ip_repeat
        -local_mac_repeat
        -remote_mac_addr
        -remote_mac_repeat
        -remote_mac_step
        -return_receipt
        -session_count
        -sut_ip_prefix
        -sut_ip_prefix_len
        -sut_ip_repeat
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_ancp_config $args $opt_args]
        
    } else {
        # set returnList [::ixia::ixprotocol_ancp_config $args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "ANCP is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    
    return $returnList
}

proc ::ixia::emulation_ancp_stats { args } {
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
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle  \{::ixia::emulation_ancp_stats $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set opt_args {
        -handle                      ANY
        -port_handle                 ANY
        -reset                       FLAG
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_ancp_stats $args $opt_args]
        
    } else {
        # set returnList [::ixia::ixprotocol_ancp_stats $args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "ANCP is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    
    return $returnList
}

proc ::ixia::emulation_ancp_control { args } {
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
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle  \{::ixia::emulation_ancp_control $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set man_args {
        -action_control              CHOICES   abort bring_up_dsl_subscribers decoupled_start decoupled_stop start start_adjacency start_resync stop stop_adjacency tear_down_dsl_subscribers
    }
    set opt_args {
        -action                      CHOICES   send-reset enable disable reset flap_start flap_stop 
        -action_control_type         CHOICES   sync async
                                     DEFAULT async
        -ancp_handle                 ANY
        -ancp_subscriber
        -batch_size
        -interval                    NUMERIC
                                     DEFAULT 20
        -interval_unit               CHOICES second millisecond microsecond
                                     DEFAULT second
        -iteration_count             NUMERIC
                                     DEFAULT 10
        -job_handle
        -peer_count
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args  -mandatory_args $man_args
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_ancp_control $args $man_args $opt_args]
        
    } else {
        # set returnList [::ixia::ixprotocol_ancp_control $args $man_args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "ANCP is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    
    return $returnList
}

proc ::ixia::emulation_ancp_subscriber_lines_config { args } {
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
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle  \{::ixia::emulation_ancp_subscriber_lines_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set man_args {
       -mode                               CHOICES create modify delete enable 
                                           CHOICES disable enable_all disable_all
    }
    
    set opt_args {
       -profile_type                       CHOICES dsl_sync dsl_resync both
                                           DEFAULT both
       -actual_rate_downstream             NUMERIC
       -actual_rate_downstream_step        NUMERIC
       -actual_rate_downstream_end         NUMERIC
       -actual_rate_upstream               NUMERIC
       -actual_rate_upstream_step          NUMERIC
       -actual_rate_upstream_end           NUMERIC
       -ancp_client_handle                 ANY
       -circuit_id                         ANY
       -circuit_id_suffix                  NUMERIC
       -circuit_id_suffix_repeat           NUMERIC
       -circuit_id_suffix_step             NUMERIC
       -data_link                          CHOICES   ethernet atm_aal5
                                           DEFAULT   ethernet
       -downstream_act_interleaving_delay  NUMERIC
       -downstream_attainable_rate         NUMERIC
       -downstream_max_interleaving_delay  NUMERIC
       -downstream_max_rate                NUMERIC
       -downstream_min_low_power_rate      NUMERIC
       -downstream_min_rate                NUMERIC
       -dsl_type                           CHOICES adsl1 adsl2 adsl2_plus vdsl1 
                                           CHOICES vdsl2 sdsl unknown
                                           DEFAULT adsl1
       -encap1                             CHOICES na untagged_ethernet 
                                           CHOICES single_tagged_ethernet
                                           DEFAULT na
       -encap2                             CHOICES na pppoa_llc pppoa_null
                                           CHOICES ipoa_llc ipoa_null 
                                           CHOICES aal5_llc_w_fcs aal5_llc_wo_fcs
                                           CHOICES aal5_null_w_fcs aal5_null_wo_fcs
                                           DEFAULT na
       -handle                             ANY
       -include_encap                      CHOICES 0 1
                                           DEFAULT 0
       -remote_id                          ANY
       -upstream_act_interleaving_delay    NUMERIC
       -upstream_attainable_rate           NUMERIC
       -upstream_max_interleaving_delay    NUMERIC
       -upstream_max_rate                  NUMERIC
       -upstream_min_low_power_rate        NUMERIC
       -upstream_min_rate                  NUMERIC
       -actual_rate_upstream_min_value                NUMERIC              
       -actual_rate_downstream_min_value              NUMERIC
       -upstream_min_rate_min_value                   NUMERIC
       -downstream_min_rate_min_value                 NUMERIC
       -upstream_attainable_rate_min_value            NUMERIC
       -downstream_attainable_rate_min_value          NUMERIC
       -upstream_max_rate_min_value                   NUMERIC
       -downstream_max_rate_min_value                 NUMERIC
       -upstream_min_low_power_rate_min_value         NUMERIC
       -downstream_min_low_power_rate_min_value       NUMERIC
       -upstream_max_interleaving_delay_min_value     NUMERIC
       -upstream_act_interleaving_delay_min_value     NUMERIC
       -downstream_max_interleaving_delay_min_value   NUMERIC
       -downstream_act_interleaving_delay_min_value   NUMERIC
       -percentage                         RANGE   0-100
                                           DEFAULT 0
       -actual_rate_downstream_repeat
       -actual_rate_upstream_repeat
       -customer_vlan_id
       -customer_vlan_id_repeat
       -customer_vlan_id_step
       -downstream_rate_tolerance
       -enable_c_vlan
       -flap_mode   
       -remote_id_suffix
       -remote_id_suffix_repeat
       -remote_id_suffix_step
       -service_vlan_id
       -service_vlan_id_repeat
       -service_vlan_id_step
       -subscriber_line_down_time
       -subscriber_line_up_time
       -subscriber_lines_per_access_node
       -upstream_rate_tolerance
       -vlan_allocation_model
    }

    ::ixia::parse_dashed_args -args $args -mandatory_args $man_args -optional_args $opt_args
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_ancp_subscriber_lines_config $args $man_args $opt_args]
        
    } else {
        # set returnList [::ixia::ixprotocol_ancp_subscriber_lines_config $args $man_args $opt_args]
        keylset returnList status $::FAILURE
        keylset returnList log "ANCP is not supported with IxTclProtocol API."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    
    return $returnList
}
