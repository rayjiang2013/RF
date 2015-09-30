##Library Header
# $Id: $
# Copyright © 2003-2007 by IXIA
# All Rights Reserved.
#
# Name:
#    ixnetwork_bgp_api.tcl
#
# Purpose:
#    A script development library containing BGP APIs for test automation
#    with the Ixia chassis.
#
# Author:
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures contained within this library include:
#
#    - ixnetwork_bgp_config
#    - ixnetwork_bgp_route_config
#    - ixnetwork_bgp_control
#    - ixnetwork_bgp_info
#
# Requirements:
#    ixiaapiutils.tcl, a library containing TCL utilities
#    parseddashedargs.tcl, a library containing the parser utilities
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
proc ::ixia::ixnetwork_bgp_config { args man_args opt_args} {
    variable objectMaxCount
    variable ixnetwork_port_handles_array
    set objectCount 0

    if {[catch {::ixia::parse_dashed_args \
            -args           $args         \
            -optional_args  $opt_args     \
            -mandatory_args $man_args} parseError]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$parseError."
        return $returnList
    }
    
    # Fix for BUG585767. Sometimes, when -local_router_id_enable is 0, parse
    # dashed args ommits to initialize it with 0. Thus we cannot focrefully disable
    # the local_router_id
    if {![info exists local_router_id_enable]} {
        if {[string first "local_router_id_enable" $args] != -1} {
            # local_router_id was specified in $args. We should initialize it 
            # because parse dashed args did a lousy job
            
            if {[regexp {(-local_router_id_enable)(\s+)(\d)} $args {} {} {} ena_val]} {
                set local_router_id_enable $ena_val
            }
        }
    }
    
    if {![info exists ixnetwork_port_handles_array]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Please connect to a port, first."
        return $returnList
    }
    
    if {([info exists local_as] && $local_as > 65535) ||\
            ([info exists local_as_step] && $local_as_step > 65535)} {
        
        if {![info exists enable_4_byte_as] || $enable_4_byte_as == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "Parameters -local_as and -local_as_step must have values in\
                    the 0-65535 range when -enable_4_byte_as is 0"
            return $returnList
        }
    }
    
    switch -- $mode {
        delete {
            if {![info exists handle] && ![info exists port_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When \
                        -mode is $mode, parameter -handle or -port_handle\
                        must be provided."
                return $returnList
            }
            if {[info exists handle]} {
                set bgp_handles_list $handle
            } else {
                if {![info exists ixnetwork_port_handles_array($port_handle)]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Parameter -port_handle $port_handle is\
                            invalid. Please provide a valid port handle."
                    return $returnList
                }
                set port_objref $ixnetwork_port_handles_array($port_handle)
                set protocol_objref $port_objref/protocols/bgp
                set bgp_handles_list [ixNetworkGetList $protocol_objref neighborRange]
            }
            
            foreach bgp_handle $bgp_handles_list {
                catch {ixNetworkRemove $bgp_handle}
                debug "ixNetworkRemove $bgp_handle"
            }
            if {[llength $bgp_handles_list] > 0 && ![info exists no_write]} {
                debug "ixNetworkCommit"
                ixNetworkCommit
            }
            keylset returnList status $::SUCCESS
            keylset returnList handles $bgp_handles_list
            return $returnList
        }
        reset {
            if {![info exists port_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When \
                        -mode is $mode, parameter -port_handle must be provided."
                return $returnList
            }
            if {![info exists ixnetwork_port_handles_array($port_handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Parameter -port_handle $port_handle is\
                        invalid. Please provide a valid port handle."
                return $returnList
            }
            set port_objref $ixnetwork_port_handles_array($port_handle)
            set protocol_objref $port_objref/protocols/bgp
            set bgp_handles_list [ixNetworkGetList $protocol_objref neighborRange]
            
            foreach bgp_handle $bgp_handles_list {
                catch {ixNetworkRemove $bgp_handle}
                debug "ixNetworkRemove $bgp_handle"
            }
            if {[llength $bgp_handles_list] > 0 && ![info exists no_write]} {
                debug "ixNetworkCommit"
                ixNetworkCommit
            }
        }
        enable -
        disable {
            if {![info exists handle] && ![info exists port_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When \
                        -mode is $mode, parameter -handle or -port_handle\
                        must be provided."
                return $returnList
            }
            array set translate_enabled {
                enable  true
                disable false
            }
            
            if {[info exists handle]} {
                set handle [ixNet remapIds $handle]
                foreach bgp_neighbor $handle {
                    debug "ixNetworkSetAttr $bgp_neighbor -enabled $translate_enabled($mode)"
                    ixNetworkSetAttr $bgp_neighbor -enabled $translate_enabled($mode)
                }
                
                if {![info exists no_write]} {
                    debug "ixNetworkCommit"
                    ixNetworkCommit
                }
                
                keylset returnList handles $handle
                keylset returnList status  $::SUCCESS
                return $returnList
            } else {
                if {![info exists ixnetwork_port_handles_array($port_handle)]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Parameter -port_handle $port_handle is\
                            invalid. Please provide a valid port handle."
                    return $returnList
                }
                set port_objref $ixnetwork_port_handles_array($port_handle)
                set protocol_objref $port_objref/protocols/bgp
                
                if {$mode == "disable"} {
                
                    set bgp_handles_list [ixNetworkGetList $protocol_objref neighborRange]
                
                    foreach bgp_neighbor $bgp_handles_list {
                        debug "ixNetworkSetAttr $bgp_neighbor -enabled $translate_enabled($mode)"
                        ixNetworkSetAttr $bgp_neighbor -enabled $translate_enabled($mode)
                    }
                    if {![info exists no_write]} {
                        debug "ixNetworkCommit"
                        ixNetworkCommit
                    }
                    
                    keylset returnList handles $bgp_handles_list
                    keylset returnList status  $::SUCCESS
                    return $returnList
                }
            }
        }
        modify {
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When \
                        -mode is $mode, parameter -handle must be provided."
                return $returnList
            }
            regexp {::ixNet::OBJ-/vport:\d+} $handle port_objref
            if {![info exists port_objref]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Parameter -handle $handle is\
                        invalid. Please provide a valid BGP\
                        neighbor handle."
                return $returnList
            }
            set protocol_objref $port_objref/protocols/bgp
            set bgp_handles_list $handle
        }
        default {}
    }
    
    # Create default value list and initialize parameters if required
    if {($mode == "reset") || ($mode == "enable")} {
        set param_value_list [list          \
                neighbor_type    "internal" ]

        foreach {param value} $param_value_list {
            if {![info exists $param]} {
                set $param $value
            }
        }
        if {![info exists local_ip_addr] && ![info exists local_ipv6_addr]} {
            set local_ip_addr 0.0.0.0
        }
        if {![info exists remote_ip_addr] && ![info exists remote_ipv6_addr]} {
            if {[info exists local_ip_addr]} {
                set remote_ip_addr 0.0.0.0
            } elseif {[info exists local_ipv6_addr]} {
                set remote_ipv6_addr 0:0:0:0:0:0:0:0
            } else {
                set remote_ip_addr 0.0.0.0
            }
        }
        
        if {[info exists vpls_nlri] && ($vpls_nlri != 0) && ($vpls_nlri != "disabled")} {
            set vpls 1
        } elseif {[info exists vpls] && ($vpls != 0) && ($vpls != "disabled")} {
            set vpls 1
        } else {
            set vpls 0
        }
    }
    
    # protocol params
    set internal_protocol_param_list {
        active_connect_enable  enableInternalActiveConnect
        retries                internalRetries
        retry_time             internalRetryDelay
    }
    set external_protocol_param_list {
        active_connect_enable  enableExternalActiveConnect
        retries                externalRetries
        retry_time             externalRetryDelay
    }
    
    # params - needed by enable and modify
    set static_router_param_list {
        bfd_registration        enableBfdRegistration
        bfd_registration_mode   bfdModeOfOperation
        local_router_id_enable  enableBgpId
        hold_time               holdTimer
        graceful_restart_enable enableGracefulRestart
        staggered_start_enable  enableStaggeredStart
        enable_4_byte_as        enable4ByteAsNum
        local_as                localAsNumber
        remote_as               remoteAsNumber
        restart_time            restartTime
        staggered_start_time    staggeredStartPeriod
        stale_time              staleTime
        tcp_window_size         tcpWindowSize
        updates_per_iteration   numUpdatesPerIteration
        next_hop_enable         enableNextHop
        next_hop_ip             nextHop
        next_hop_ip_version     nextHopIpType
        update_interval         updateInterval
        neighbor_type           type
        active_connect_enable   enableActAsRestarted
        md5_enable              authentication
        md5_key                 md5Key
        ttl_value               ttlValue
    }
    
    set dynamic_router_param_list {
        local_router_id         bgpId
        enable_4_byte_as        enable4ByteAsNum
        local_as                localAsNumber
    }
    
    if {[info exists local_router_id] && ![info exists local_router_id_enable] && $mode != "modify"} {
        set local_router_id_enable 1
    }
    
    array set translate_param_array {
        enable_4_byte_as,0      false
        enable_4_byte_as,1      true
        bfd_registration,0      false
        bfd_registration,1      true
        bfd_registration_mode,single_hop   singleHop
        bfd_registration_mode,multi_hop    multiHop
        local_router_id_enable,0  false
        local_router_id_enable,1  true
        graceful_restart_enable,0 false
        graceful_restart_enable,1 true
        staggered_start_enable,0  false
        staggered_start_enable,1  true
        next_hop_enable,0         false
        next_hop_enable,1         true
        active_connect_enable,0   false
        active_connect_enable,1   true
        next_hop_ip_version,4     ipv4
        next_hop_ip_version,6     ipv6
        md5_enable,0              null
        md5_enable,1              md5
    }
    
    set param_list_capabilities {
        ipv4_mdt_nlri        ipV4Mdt         capability
        ipv4_mpls_nlri       ipV4Mpls        both
        ipv4_mpls_vpn_nlri   ipV4MplsVpn     both
        ipv4_multicast_nlri  ipV4Multicast   both
        ipv4_unicast_nlri    ipV4Unicast     both
        ipv6_mpls_nlri       ipV6Mpls        both
        ipv6_mpls_vpn_nlri   ipV6MplsVpn     both
        ipv6_multicast_nlri  ipV6Multicast   both
        ipv6_unicast_nlri    ipV6Unicast     both
        vpls                 vpls            both
    }
    
    if {$mode == "enable" || $mode == "reset" || $mode == "modify"} {
        # Compose static param list
        set static_router_args ""
        foreach {hlt_param ixn_param} \
                $static_router_param_list {
            if {[info exists $hlt_param]} {
                set param_value [set $hlt_param]
                if {[info exists translate_param_array($hlt_param,$param_value)]} {
                    set param_value $translate_param_array($hlt_param,$param_value)
                }
                lappend static_router_args $ixn_param $param_value
            }
        }
        
        set capabilities_args ""
        if {$mode != "modify"} {
            # Compose capabilities param list
            foreach {param cmd type} $param_list_capabilities {
                if {[info exists $param]} {
                    set param_value [set $param]
                    switch -- $param_value {
                        0 {set param_value false}
                        1 {set param_value true}
                    }
                    if {$type == "filter" || $type == "both"} {
                        lappend capabilities_args "/learnedFilter/capabilities" $cmd $param_value
                    }
                    lappend capabilities_args "" $cmd $param_value
                } else {
                    if {$type == "filter" || $type == "both"} {
                        lappend capabilities_args "/learnedFilter/capabilities" $cmd false
                    }
                    lappend capabilities_args "" $cmd false
                }
            }
        }
    }
    
    if {$mode == "enable" || $mode == "reset"} {
        set port_objref     $ixnetwork_port_handles_array($port_handle)
        set protocol_objref $port_objref/protocols/bgp
        # Check if protocols are supported
        set retCode [checkProtocols $port_objref]
        if {[keylget retCode status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Port $port_handle does not support protocol\
                    configuration."
            return $returnList
        }
        
        # Set protocol parameters
        debug "ixNetworkSetAttr $protocol_objref -enabled true"
        ixNetworkSetAttr $protocol_objref -enabled true
        foreach {hlt_protocol_param ixn_protocol_param} \
                [set ${neighbor_type}_protocol_param_list] {
            if {[info exists $hlt_protocol_param]} {
                set param_value [set $hlt_protocol_param]
                if {[info exists translate_param_array($hlt_protocol_param,$param_value)]} {
                    set param_value $translate_param_array($hlt_protocol_param,$param_value)
                }
                debug "ixNetworkSetAttr $protocol_objref -$ixn_protocol_param $param_value"
                ixNetworkSetAttr $protocol_objref -$ixn_protocol_param $param_value
            }
        }
        
        #if {![info exists no_write]} {
            #debug "ixNet commit"
            #ixNet commit
        #}
        keylset neighbor_rec port $port_handle
        keylset neighbor_rec ipv  $ip_version
                
        
        
        # IPv6 expansion
        set ipv6_expansion_list {
            local_ipv6_addr
            remote_ipv6_addr
            local_addr_step
            remote_addr_step
            next_hop_ip
            local_loopback_ip_addr
            local_loopback_ip_addr_step
            remote_loopback_ip_addr
            remote_loopback_ip_addr_step
        }
        foreach {ipv6_exp_list} $ipv6_expansion_list {
            if {[info exists $ipv6_exp_list] && [::ipv6::isValidAddress \
                    [lindex [set $ipv6_exp_list] 0]]} {
                set ipv6_temp_list ""
                foreach ipv6_elem [set $ipv6_exp_list] {
                    lappend ipv6_temp_list [::ixia::expand_ipv6_addr \
                            $ipv6_elem]
                }
                set $ipv6_exp_list $ipv6_temp_list
            }
        }
        
        # Check parameters dependencies based on IP type
        set connected_ip_version   0
        set unconnected_ip_version 0
        
        ##Interfaces
        # Configure the necessary interfaces
        if {[info exists interface_handle]} {
            
            set intf_list                      [list]
            set local_ip_addr_list             [list]
            set remote_ip_addr_list            [list]
            set gateway_ip_addr_list           [list]
            set local_loopback_ip_addr_list    [list]
            set remote_loopback_ip_addr_list   [list]
            set local_ipv6_addr_list           [list]
            set remote_ipv6_addr_list          [list]
            set local_loopback_ipv6_addr_list  [list]
            set remote_loopback_ipv6_addr_list [list]
            
            set intf_index 0
            set conn_list [list]
            set unconn_list [list]
            
            foreach intf_objref $interface_handle {
                if {[llength [split $intf_objref |]] > 1} {
                    # We're dealing with DHCP/IP ranges interfaces
                    
                    foreach {sm_range intf_idx_group} [split $intf_objref |] {}
                    
                    # Validate sm_range
                    set sm_type_dhcp [regexp {^::ixNet::OBJ-/vport:\d+/protocolStack/((ethernet)|(atm)):[^/]+/dhcpEndpoint:[^/]+/range:[^/]+$} $sm_range]
                    set sm_type_ip   [regexp {^::ixNet::OBJ-/vport:\d+/protocolStack/((ethernet)|(atm)):[^/]+/ipEndpoint:[^/]+/range:[^/]+$} $sm_range]
                    
                    if {!$sm_type_dhcp && !$sm_type_ip} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Invalid handle '$intf_objref' for -interface_handle\
                                parameter. Expected handle returned by emulation_dhcp_group_config/interface_config procedure."
                        return $returnList
                    }
                    
                    if {$sm_type_dhcp} {
                        set intf_type "DHCP"
                    }
                    if {$sm_type_ip} {
                        set intf_type "IP"
                    }
                    
                    # dhcp means connected
                    set connected_ip_version $ip_version
                    
                    if {$ip_version == 4} {
                        if {![info exists remote_ip_addr]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Parameter -remote_ip_addr is mandatory for DHCP/IP handles."
                            return $returnList
                        }
                    } else {
                        if {![info exists remote_ipv6_addr]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Parameter -remote_ipv6_addr is mandatory for DHCP/IP handles."
                            return $returnList
                        }
                    }
                    
                    foreach single_intf_idx_group [split $intf_idx_group ,] {
                        switch -- [regexp -all {\-} $single_intf_idx_group] {
                            0 {
                                # It's a single index
                                if {![string is integer $single_intf_idx_group] || $single_intf_idx_group <= 0} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Invalid interface index $single_intf_idx_group\
                                            in interface_handle $intf_objref. Accepted values are numeric\
                                            greater than 0."
                                    return $returnList
                                }
                                
                                lappend intf_list "${sm_range}|${single_intf_idx_group}|${intf_type}"
                                incr intf_index
                                
                                lappend local_ip_addr_list {}
                                if {$ip_version == 4} {
                                    lappend remote_ip_addr_list $remote_ip_addr
                                } else {
                                    lappend remote_ip_addr_list {}
                                }
                                lappend local_ipv6_addr_list {}
                                if {$ip_version == 6} {
                                    lappend remote_ipv6_addr_list $remote_ipv6_addr
                                } else {
                                    lappend remote_ipv6_addr_list {}
                                }
                                lappend local_loopback_ip_addr_list {}
                                lappend remote_loopback_ip_addr_list {}
                                lappend local_loopback_ipv6_addr_list {}
                                lappend remote_loopback_ipv6_addr_list {}
                                
                                if {$ip_version == 4} {
                                    if {[info exists remote_addr_step]} {
                                        set remote_ip_addr [::ixia::incr_ipv4_addr $remote_ip_addr $remote_addr_step]
                                    }
                                } else {
                                    if {[info exists remote_addr_step]} {
                                        set remote_ipv6_addr [::ixia::incr_ipv6_addr $remote_ipv6_addr $remote_addr_step]
                                    }
                                }                    
                            }
                            1 {
                                # It's a range of indexes
                                foreach {range_start range_end} [split $single_intf_idx_group -] {}
                                
                                if {!([string is integer $range_start]) || !([string is integer $range_end]) ||\
                                        !($range_start <= $range_end) || !($range_start > 0)} {
                                    
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Invalid interface index range $single_intf_idx_group\
                                            in interface_handle $intf_objref. Accepted values are numeric\
                                            greater than 0."
                                    return $returnList
                                }
                                
                                for {set i $range_start} {$i <= $range_end} {incr i} {
                                    lappend intf_list "${sm_range}|${i}|${intf_type}"
                                    incr intf_index
                                    
                                    lappend local_ip_addr_list {}
                                    if {$ip_version == 4} {
                                        lappend remote_ip_addr_list $remote_ip_addr
                                    } else {
                                        lappend remote_ip_addr_list {}
                                    }
                                    lappend local_ipv6_addr_list {}
                                    if {$ip_version == 6} {
                                        lappend remote_ipv6_addr_list $remote_ipv6_addr
                                    } else {
                                        lappend remote_ipv6_addr_list {}
                                    }
                                    lappend local_loopback_ip_addr_list {}
                                    lappend remote_loopback_ip_addr_list {}
                                    lappend local_loopback_ipv6_addr_list {}
                                    lappend remote_loopback_ipv6_addr_list {}
                                    
                                    if {$ip_version == 4} {
                                        if {[info exists remote_addr_step]} {
                                            set remote_ip_addr [::ixia::incr_ipv4_addr $remote_ip_addr $remote_addr_step]
                                        }
                                    } else {
                                        if {[info exists remote_addr_step]} {
                                            set remote_ipv6_addr [::ixia::incr_ipv6_addr $remote_ipv6_addr $remote_addr_step]
                                        }
                                    } 
                                }
                            }
                            default {
                                # It's not valid
                                keylset returnList status $::FAILURE
                                keylset returnList log "Invalid interface index range in $intf_objref."
                                return $returnList
                            }
                        }
                    }
                    
                } else {
                    # Validate protocol interface range
                    if {![regexp {^::ixNet::OBJ-/vport:\d+/interface:[0-9a-zA-Z]+$} $intf_objref]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Invalid interface handle $intf_objref,\
                                provided to -interface_handle parameter. Please provide\
                                a valid connected/unconnected protocol interface handle."
                        return $returnList
                    } else {
                        set intf_type_i "ProtocolIntf"
                    }
                    
                    set ret_code [get_interface_parameter       \
                            -description $intf_objref           \
                            -input       intf_handle            \
                            -parameter   [list type             \
                                               ipv4_address     \
                                               ipv4_gateway     \
                                               ipv6_gateway     \
                                               ipv6_address]    \
                        ]
                    if {[keylget ret_code status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to get details for $intf_objref.\
                                [keylget ret_code log]"
                        return $returnList
                    }
                    
                    set ret_code_type           [keylget ret_code type]
                    set ret_code_ipv4_address   [keylget ret_code ipv4_address]
                    set ret_code_ipv6_address   [keylget ret_code ipv6_address]
                    set ret_code_ipv4_gateway   [keylget ret_code ipv4_gateway]
                    set ret_code_ipv6_gateway   [keylget ret_code ipv6_gateway]
                    
                    set intf_type $ret_code_type
                    if {[string compare -nocase $intf_type "routed"] == 0} {
                        lappend unconn_list $intf_objref
                        set ipv4_item_temp $ret_code_ipv4_address
                        set ipv4_addr_temp $ret_code_ipv4_address
                        
                        set ipv6_item_temp $ret_code_ipv6_address
                        set ipv6_addr_temp $ret_code_ipv6_address
                        
                        if {($ipv4_item_temp != "") && ($ipv4_addr_temp != "")} {
                            set unconnected_ip_version 4
                            if {($ipv6_item_temp != "") && ($ipv6_addr_temp != "")} {
                                set unconnected_ip_version 4_6
                            }
                        } elseif {($ipv6_item_temp != "") && ($ipv6_addr_temp != "")} {
                            set unconnected_ip_version 6
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Invalid interface_handle\
                                    $intf_objref. There is no valid IPv4 or\
                                    IPv6 address configured on this interface."
                            return $returnList
                        }
                        set connected_via [ixNetworkGetAttr $intf_objref/unconnected \
                                -connectedVia]
                        
                        set ret_code [get_interface_parameter       \
                                -description $connected_via         \
                                -input       intf_handle            \
                                -parameter   [list ipv4_gateway     \
                                                   ipv4_address     \
                                                   ipv6_address]    \
                            ]
                        if {[keylget ret_code status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to get details for $connected_via.\
                                    [keylget ret_code log]"
                            return $returnList
                        }
                        
                        set ret_code_cv_ipv4_address   [keylget ret_code ipv4_address]
                        set ret_code_cv_ipv6_address   [keylget ret_code ipv6_address]
                        set ret_code_cv_gateway_addr   [keylget ret_code ipv4_gateway]
                        
                        set ipv4_item_temp $ret_code_cv_ipv4_address
                        set ipv4_addr_temp $ret_code_cv_ipv4_address
                        
                        set ipv6_item_temp $ret_code_cv_ipv6_address
                        set ipv6_addr_temp $ret_code_cv_ipv6_address
                        
                        if {($ipv4_item_temp != "") && ($ipv4_addr_temp != "")} {
                            set connected_ip_version 4
                            if {($ipv6_item_temp != "") && ($ipv6_addr_temp != "")} {
                                set connected_ip_version 4_6
                            }
                        } elseif {($ipv6_item_temp != "") && ($ipv6_addr_temp != "")} {
                            set connected_ip_version 6
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Invalid interface_handle\
                                    $intf_objref. There is no valid IPv4 or\
                                    IPv6 address configured on the dirrectly\
                                    connected interface $connected_via."
                            return $returnList
                        }
                        
                        if {$unconnected_ip_version == "4_6"} {
                            if {![info exists ip_version] || $ip_version == 4} {
                                set unconnected_ip_version 4
                            } else {
                                set unconnected_ip_version 6
                            }
                        }
                        
                        if {$connected_ip_version == "4_6"} {
                            if {![info exists ip_version] || $ip_version == 4} {
                                set connected_ip_version 4
                            } else {
                                set connected_ip_version 6
                            }
                        }
                        
                        if {$unconnected_ip_version == 4} {
                                    
                            lappend local_loopback_ip_addr_list $ret_code_ipv4_address
                            
                            if {[llength $remote_loopback_ip_addr] > $intf_index} {
                                set remote_loopback_ip_addr_list $remote_loopback_ip_addr
                            } else {
                                lappend remote_loopback_ip_addr_list \
                                        [lindex $remote_loopback_ip_addr_list end]
                            }
                            lappend local_loopback_ipv6_addr_list  {}
                            lappend remote_loopback_ipv6_addr_list {}
                        } else {
                            lappend local_loopback_ipv6_addr_list $ret_code_ipv6_address
                            
                            if {[llength $remote_loopback_ip_addr] > $intf_index} {
                                set remote_loopback_ipv6_addr_list $remote_loopback_ip_addr
                            } else {
                                lappend remote_loopback_ipv6_addr_list \
                                        [lindex $remote_loopback_ipv6_addr_list end]
                            }
                            lappend local_loopback_ip_addr_list  {}
                            lappend remote_loopback_ip_addr_list {}
                        }
                        if {$connected_ip_version == 4} {
                                    
                            lappend local_ip_addr_list $ret_code_cv_ipv4_address
                            
                            set     gwTemp               $ret_code_cv_gateway_addr
                            lappend remote_ip_addr_list  $gwTemp
                            lappend gateway_ip_addr_list $gwTemp
                            
                            lappend local_ipv6_addr_list           {}
                            lappend remote_ipv6_addr_list          {}
                        } else {
                            if {$unconnected_ip_version == 0 } {
                                if {![info exists remote_ipv6_addr]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Parameter\
                                            remote_ipv6_addr must be specified for\
                                            ip_version 6."
                                    return $returnList
                                }
                            }
                            lappend local_ipv6_addr_list $ret_code_cv_ipv6_address
                            if {$unconnected_ip_version == 0 } {
                                if {[llength $remote_ipv6_addr] >= $intf_index} {
                                    set remote_ipv6_addr_list $remote_ipv6_addr
                                } else {
                                    lappend remote_ipv6_addr_list \
                                            [lindex $remote_ipv6_addr_list end]
                                }
                            } else {
                                lappend remote_ipv6_addr_list {}
                            }
                            lappend local_ip_addr_list           {}
                            lappend remote_ip_addr_list          {}
                            lappend gateway_ip_addr_list         {}
                        }
                    } else {
                        lappend conn_list $intf_objref
                        set ipv4_item_temp $ret_code_ipv4_address
                        set ipv4_addr_temp $ret_code_ipv4_address
                        
                        set ipv6_item_temp $ret_code_ipv6_address
                        set ipv6_addr_temp $ret_code_ipv6_address
                        
                        if {($ipv4_item_temp != [ixNet getNull]) && \
                                ($ipv4_addr_temp != "")} {
                            set connected_ip_version 4
                            if {($ipv6_item_temp != [ixNet getNull]) && \
                                    ($ipv6_addr_temp != "")} {
                                set connected_ip_version 4_6
                            }
                        } elseif {($ipv6_item_temp != [ixNet getNull]) && \
                                ($ipv6_addr_temp != "")} {
                            set connected_ip_version 6
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Invalid interface_handle\
                                    $intf_objref. There is no valid IPv4 or\
                                    IPv6 address configured on this interface."
                            return $returnList
                        }
                        set unconnected_ip_version 0
                        
                        if {$connected_ip_version == "4_6"} {
                            if {![info exists ip_version] || $ip_version == 4} {
                                set connected_ip_version 4
                            } else {
                                set connected_ip_version 6
                            }
                        }
                        
                        if {$connected_ip_version == 4} {
                            lappend local_ip_addr_list $ret_code_ipv4_address
                            if {![info exists remote_ip_addr]} {
                                set     gwTemp               $ret_code_ipv4_gateway
                                lappend remote_ip_addr_list  $gwTemp
                                lappend gateway_ip_addr_list $gwTemp
                            } else {
                                if {[llength $remote_ip_addr] > $intf_index} {
                                    set remote_ip_addr_list  $remote_ip_addr
                                    set gateway_ip_addr_list $remote_ip_addr
                                } else {
									if {[info exists remote_addr_step]} {
										set remote_ip_addr_item [::ixia::incr_ipv4_addr [lindex $remote_ip_addr_list end] $remote_addr_step]
										lappend remote_ip_addr_list $remote_ip_addr_item
									} else {
										lappend remote_ip_addr_list \
												[lindex $remote_ip_addr_list end]
									}
									lappend gateway_ip_addr_list [lindex $remote_ip_addr_list end]
                                }
                            }
                            lappend local_loopback_ip_addr_list  {}
                            lappend remote_loopback_ip_addr_list {}
                            
                            lappend local_ipv6_addr_list           {}
                            lappend remote_ipv6_addr_list          {}
                            lappend local_loopback_ipv6_addr_list  {}
                            lappend remote_loopback_ipv6_addr_list {}
                        } else {
                            lappend local_ipv6_addr_list $ret_code_ipv6_address
                            if {![info exists remote_ipv6_addr]} {
                                set     gwTemp                $ret_code_ipv6_gateway
                                lappend remote_ipv6_addr_list $gwTemp
                                lappend gateway_ip_addr_list  $gwTemp
                            } else {
                                if {[llength $remote_ipv6_addr] > $intf_index} {
                                    set remote_ipv6_addr_list $remote_ipv6_addr
                                    set gateway_ip_addr_list  $remote_ipv6_addr
                                } else {
                                    lappend remote_ipv6_addr_list \
                                            [lindex $remote_ipv6_addr_list end]
                                    lappend gateway_ip_addr_list \
                                            [lindex $remote_ipv6_addr_list end]
                                }
                            }
                            
                            lappend local_ip_addr_list           {}
                            lappend remote_ip_addr_list          {}
                            lappend local_loopback_ip_addr_list  {}
                            lappend remote_loopback_ip_addr_list {}
                            lappend local_loopback_ipv6_addr_list  {}
                            lappend remote_loopback_ipv6_addr_list {}
                        }
                    }
                    lappend intf_list "${intf_objref}|dummy|${intf_type_i}"
                    incr intf_index
                }
            }
            
            if {$intf_index != $count} {
                keylset returnList status $::FAILURE
                keylset returnList log "The -interface_handle list doesn't\
                        have the size specified with the -count argument."
                return $returnList
            }
            
            set local_ip_addr             [lindex $local_ip_addr_list             0]
            set remote_ip_addr            [lindex $remote_ip_addr_list            0]
            set gateway_ip_addr           [lindex $gateway_ip_addr_list           0]
            set local_loopback_ip_addr    [lindex $local_loopback_ip_addr_list    0]
            set remote_loopback_ip_addr   [lindex $remote_loopback_ip_addr_list   0]
            set local_ipv6_addr           [lindex $local_ipv6_addr_list           0]
            set remote_ipv6_addr          [lindex $remote_ipv6_addr_list          0]
            set local_loopback_ipv6_addr  [lindex $local_loopback_ipv6_addr_list  0]
            set remote_loopback_ipv6_addr [lindex $remote_loopback_ipv6_addr_list 0]
            
        } else {
            # Connected IPv4 parameters
            set connected_ipv4_params {
                local_ip_addr      mandatory
                local_addr_step    optional
                remote_ip_addr     mandatory
                remote_addr_step   optional
            }
            set connected_ipv4_mandatory        0
            set connected_ipv4_params_exist     0
            set connected_ipv4_params_valid_ips 0
            foreach {connected_ipv4_param connected_ipv4_param_type} $connected_ipv4_params {
                if {[info exists $connected_ipv4_param]} {
                    incr connected_ipv4_params_exist
                    if {[isIpAddressValid [set $connected_ipv4_param]]} {
                        incr connected_ipv4_params_valid_ips
                    }
                } elseif {$connected_ipv4_param_type == "mandatory" } {
                    incr connected_ipv4_mandatory
                }
            }
            if {($connected_ipv4_params_exist == $connected_ipv4_params_valid_ips) &&\
                    ($connected_ipv4_mandatory == 0)} {
                set connected_ip_version 4
            } elseif {$connected_ipv4_params_exist && ($connected_ipv4_mandatory == 0) &&\
                    ($connected_ipv4_params_exist != $connected_ipv4_params_valid_ips)} {
                keylset returnList status $::FAILURE
                keylset returnList log "One of the following parameters:\
                        local_ip_addr, local_addr_step, remote_ip_addr, remote_addr_step\
                        is invalid. When provided, all these parameters\
                        must have the same IP type."
                return $returnList
            }
            if {$connected_ip_version == 0} {
                # Connected IPv6 parameters
                set connected_ipv6_params {
                    local_ipv6_addr     mandatory
                    local_addr_step     optional
                    remote_ipv6_addr    mandatory
                    remote_addr_step    optional
                }
                set connected_ipv6_mandatory        0
                set connected_ipv6_params_exist     0
                set connected_ipv6_params_valid_ips 0
                foreach {connected_ipv6_param connected_ipv6_param_type} $connected_ipv6_params {
                    if {[info exists $connected_ipv6_param]} {
                        incr connected_ipv6_params_exist
                        if {[ipv6::isValidAddress [set $connected_ipv6_param]]} {
                            incr connected_ipv6_params_valid_ips
                        }
                    } elseif {$connected_ipv6_param_type == "mandatory" } {
                        incr connected_ipv6_mandatory
                    }
                }
                if {$connected_ipv6_params_exist == $connected_ipv6_params_valid_ips &&\
                        ($connected_ipv6_mandatory == 0)} {
                    set connected_ip_version 6
                } elseif {$connected_ipv6_params_exist && ($connected_ipv6_mandatory == 0) && \
                        ($connected_ipv6_params_exist != $connected_ipv6_params_valid_ips)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "One of the following parameters:\
                            local_ipv6_addr, local_addr_step, remote_ipv6_addr, remote_addr_step\
                            is invalid. When provided, all these parameters\
                            must have the same IP type."
                    return $returnList
                }
            }
            if {$connected_ip_version == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -mode is ${mode},\
                        the following parameters must be provided:\
                        (-local_ip_addr and -remote_ip_addr) or\
                        (-local_ipv6_addr and -remote_ipv6_addr)."
                return $returnList
            }
            # Unconnected IPv4/v6 params
            set unconnected_ip_params {
                local_loopback_ip_addr        mandatory
                local_loopback_ip_addr_step   optional
                remote_loopback_ip_addr       mandatory
                remote_loopback_ip_addr_step  optional
            }
            set unconnected_ipv4_mandatory        0
            set unconnected_ipv4_params_exist     0
            set unconnected_ipv4_params_valid_ips 0
            foreach {unconnected_ipv4_param unconnected_ipv4_param_type} $unconnected_ip_params {
                if {[info exists $unconnected_ipv4_param]} {
                    incr unconnected_ipv4_params_exist
                    if {[isIpAddressValid [set $unconnected_ipv4_param]]} {
                        incr unconnected_ipv4_params_valid_ips
                    }
                } elseif {$unconnected_ipv4_param_type == "mandatory"} {
                    incr unconnected_ipv4_mandatory
                }
            }
            
            if {$unconnected_ipv4_params_exist == $unconnected_ipv4_params_valid_ips &&\
                    ($unconnected_ipv4_mandatory == 0)} {
                set unconnected_ip_version 4
            }
            if {$unconnected_ip_version == 0} {
                set unconnected_ipv6_mandatory        0
                set unconnected_ipv6_params_exist     0
                set unconnected_ipv6_params_valid_ips 0
                foreach {unconnected_ipv6_param unconnected_ipv6_param_type} $unconnected_ip_params {
                    if {[info exists $unconnected_ipv6_param]} {
                        incr unconnected_ipv6_params_exist
                        if {[ipv6::isValidAddress [set $unconnected_ipv6_param]]} {
                            incr unconnected_ipv6_params_valid_ips
                        }
                    } elseif {$unconnected_ipv6_param_type == "mandatory"} {
                        incr unconnected_ipv6_mandatory
                    }
                }
                
                if {$unconnected_ipv6_params_exist == $unconnected_ipv6_params_valid_ips &&\
                        ($unconnected_ipv6_mandatory == 0)} {
                    set unconnected_ip_version 6
                }
            }
            if {$unconnected_ip_version == 0} {
                if {($unconnected_ipv4_params_exist && ($unconnected_ipv4_mandatory == 0) && \
                        ($unconnected_ipv4_params_exist != $unconnected_ipv4_params_valid_ips)) || \
                        ($unconnected_ipv6_params_exist && ($unconnected_ipv6_mandatory == 0) && \
                        ($unconnected_ipv6_params_exist != $unconnected_ipv6_params_valid_ips))} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "One of the following parameters:\
                            local_loopback_ip_addr, local_loopback_ip_addr_step,\
                            remote_loopback_ip_addr, remote_loopback_ip_addr_step,\
                            is invalid. When provided, all these parameters\
                            must have the same IP type."
                    return $returnList
                }
                foreach {unconnected_ip_param unconnected_ip_param_type} $unconnected_ip_params {
                    if {[info exists $unconnected_ip_param]} {
                        catch {unset $unconnected_ip_param}
                    }
                }
            }
            if {$connected_ip_version == 4} {
                if {![info exists netmask]} {
                    set netmask 24
                } elseif {$netmask > 32}  {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid netmask \
                            $netmask for ip version ${ip_version}."
                    return $returnList
                }
                if {![info exists local_addr_step]} {
                    set local_addr_step 0.1.0.0
                }
                if {![info exists remote_addr_step]} {
                    set remote_addr_step 0.1.0.0
                }
                
                # Set gateway ip / gateway ip step
                if {![info exists gateway_ip_addr]} {
                    if {[info exists remote_ip_addr]} {
                        set gateway_ip_addr $remote_ip_addr
                    }
                } elseif {![isValidIPv4Address $gateway_ip_addr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid gateway_ip_addr \
                            $gateway_ip_addr for ip version ${connected_ip_version}."
                    return $returnList
                }
                
                set gateway_ip_addr_step $remote_addr_step
                
            } else {
                if {![info exists netmask]} {
                    set netmask 64
                }
                if {![info exists local_addr_step]} {
                    set local_addr_step 0000:0000:0000:0000:0001:0000:0000:0000
                }
                if {![info exists remote_addr_step]} {
                    set remote_addr_step 0000:0000:0000:0000:0001:0000:0000:0000
                }
                
                # Set gateway ip / gateway ip step
                if {![info exists gateway_ip_addr]} {
                    if {[info exists remote_ipv6_addr]} {
                        set gateway_ip_addr $remote_ipv6_addr
                    }
                } elseif {![::ipv6::isValidAddress $gateway_ip_addr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid gateway_ip_addr \
                            $gateway_ip_addr for ip version ${connected_ip_version}."
                    return $returnList
                }
                set gateway_ip_addr_step $remote_addr_step
            }
            if {$unconnected_ip_version == 4} {
                if {![info exists local_loopback_ip_prefix_length]} {
                    set local_loopback_ip_prefix_length 32
                }
                if {![info exists local_loopback_ip_addr_step]} {
                    set local_loopback_ip_addr_step 0.1.0.0
                }
                if {![info exists remote_loopback_ip_addr_step]} {
                    set remote_loopback_ip_addr_step 0.1.0.0
                }
            } elseif {$unconnected_ip_version == 6} {
                if {![info exists local_loopback_ip_prefix_length]} {
                    set local_loopback_ip_prefix_length 128
                }
                if {![info exists local_loopback_ip_addr_step]} {
                    set local_loopback_ip_addr_step 0000:0000:0000:0000:0001:0000:0000:0000
                }
                if {![info exists remote_loopback_ip_addr_step]} {
                    set remote_loopback_ip_addr_step 0000:0000:0000:0000:0001:0000:0000:0000
                }
            }
            
            if {[info exists vlan_id] && ![info exist vlan_user_priority]} {
                set vlan_user_priority 0
            }
            # Add interface(s)
            set protocol_intf_options "                                     \
                    -atm_encapsulation          atm_encapsulation           \
                    -atm_vci                    vci                         \
                    -atm_vci_step               vci_step                    \
                    -atm_vpi                    vpi                         \
                    -atm_vpi_step               vpi_step                    \
                    -count                      count                       \
                    -mac_address                mac_address_start           \
                    -mac_address_step           mac_address_step            \
                    -override_existence_check   override_existence_check    \
                    -override_tracking          override_tracking           \
                    -port_handle                port_handle                 \
                    -vlan_enabled               vlan                        \
                    -vlan_id                    vlan_id                     \
                    -vlan_id_mode               vlan_id_mode                \
                    -vlan_id_step               vlan_id_step                \
                    -vlan_user_priority         vlan_user_priority          "
            
            if {$connected_ip_version == "4"} {
                append protocol_intf_options " \
                        -ipv4_address               local_ip_addr               \
                        -ipv4_address_step          local_addr_step             \
                        -ipv4_prefix_length         netmask                     \
                        -gateway_address            gateway_ip_addr             \
                        -gateway_address_step       gateway_ip_addr_step        \
                        "
            } else {
                append protocol_intf_options " \
                        -ipv6_address               local_ipv6_addr             \
                        -ipv6_address_step          local_addr_step             \
                        -ipv6_prefix_length         netmask                     \
                        -ipv6_gateway               gateway_ip_addr             \
                        -ipv6_gateway_step          gateway_ip_addr_step        \
                        "
            }
            if {$unconnected_ip_version == "4"} {
                append protocol_intf_options " \
                        -loopback_count             1                           \
                        -loopback_ipv4_address      local_loopback_ip_addr      \
                        -loopback_ipv4_address_step local_loopback_ip_addr_step \
                        -loopback_ipv4_prefix_length local_loopback_ip_prefix_length \
                        "
            } else {
                append protocol_intf_options " \
                        -loopback_count             1                           \
                        -loopback_ipv6_address      local_loopback_ip_addr      \
                        -loopback_ipv6_address_step local_loopback_ip_addr_step \
                        -loopback_ipv6_prefix_length local_loopback_ip_prefix_length \
                        "
            }
            
            # Passed in only those options that exists
            foreach {option value_name} $protocol_intf_options {
                if {[info exists $value_name]} {
                    append protocol_intf_args " $option [set $value_name]"
                }
            }
        
            # Create the necessary interfaces
            set intf_list [eval ixNetworkProtocolIntfCfg \
                    $protocol_intf_args]
            if {[keylget intf_list status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to create the\
                        protocol interfaces. [keylget intf_list log]"
                return $returnList
            }

            if {![catch {keylget intf_list connected_interfaces}]} {
                set conn_list [keylget intf_list connected_interfaces]
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "The connected interfaces list\
                        is missing."
                return $returnList
            }
            if {![catch {keylget intf_list routed_interfaces}]} {
                set unconn_list [keylget intf_list routed_interfaces]
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "The unconnected interfaces list\
                        is missing."
                return $returnList
            }
        }
        
        # Check if parameters have been provided correctly
        if {$unconnected_ip_version != 0} {
            if {$unconnected_ip_version != $ip_version} {
                keylset returnList status $::FAILURE
                keylset returnList log "The -ip_version $ip_version, should match with the IP\
                        version of the parameters local_loopback_ip_addr and\
                        remote_loopback_ip_addr."
                return $returnList
            }
        } else {
            if {$connected_ip_version != $ip_version} {
                keylset returnList status $::FAILURE
                keylset returnList log "The -ip_version $ip_version, should match with the IP\
                        version of the parameters local_ip_addr/local_ipv6_addr and\
                        remote_ip_addr/remote_ipv6_addr."
                return $returnList
            }
        }
        
        set neigh_list {}
        set objectCount 0
        for {set i 0} {$i < $count} {incr i} {
            # setting neighbors
            debug "ixNetworkAdd $protocol_objref neighborRange"
            set neighbor [ixNetworkAdd $protocol_objref neighborRange]
            
			#always configure neighbor range as enabled
			debug "ixNetworkSetAttr $neighbor -enabled true"
            ixNetworkSetAttr $neighbor -enabled true
			
            set intf_objref_type "ProtocolIntf"
            if {[info exists interface_handle]} {
                set intf_objref [lindex $intf_list $i]
                ## Protocol Interface / DHCP interface / IP interface
                foreach {intf_objref intf_objref_index intf_objref_type} [split $intf_objref |] {}
                set ixn_version [join [lrange [split [ixNet getAttribute [ixNet getRoot]globals -buildNumber] .] 0 1] .]
                
                set prot_intf_config ""
                switch -- $intf_objref_type {
                    "ProtocolIntf" {
                        if {$ixn_version >= 5.60} {
                            append prot_intf_config "ixNetworkSetAttr \$neighbor -interfaceType \"Protocol Interface\"; "
                            append prot_intf_config "ixNetworkSetAttr \$neighbor -interfaces    $intf_objref; "
                        } else {
                            append prot_intf_config "ixNetworkSetAttr \$neighbor -interfaceId   $intf_objref; "
                        }
                    }
                    "DHCP" -
                    "IP" {
                        if {($intf_objref_type == "DHCP") && ($ixn_version < 5.60)} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Internal error. Unexpected interface handle type.\
                                    Interface handle type DHCP is only supported starting with IxNetwork 5.60."
                            return $returnList
                        }
                        
                        if {($intf_objref_type == "IP") && ($ixn_version < 6.30)} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Internal error. Unexpected interface handle type.\
                                    Interface handle type IP range is only supported starting with IxNetwork 6.30 SP1."
                            return $returnList
                        }
                        
                        append prot_intf_config "ixNetworkSetAttr \$neighbor -interfaces     $intf_objref; "
                        append prot_intf_config "ixNetworkSetAttr \$neighbor -interfaceType  $intf_objref_type; "
                        append prot_intf_config "ixNetworkSetAttr \$neighbor -interfaceStartIndex $intf_objref_index; "
                        if {$ip_version == 4} {
                            append prot_intf_config "ixNetworkSetAttr \$neighbor -localIpAddress 0.0.0.0; "
                        } else {
                            append prot_intf_config "ixNetworkSetAttr \$neighbor -localIpAddress 0:0:0:0:0:0:0:0; "
                        }
                    }
                    default {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Internal error. Unexpected interface handle type.\
                                Known interface handle types are: DHCP, IP and ProtocolIntf."
                        return $returnList
                    }
                }
                
                debug "[subst $prot_intf_config]"
                eval [subst $prot_intf_config]
            }
            
            if {$unconnected_ip_version != 0} {
                switch -- $unconnected_ip_version {
                    4 {
                        debug "ixNetworkSetAttr $neighbor -localIpAddress $local_loopback_ip_addr"
                        ixNetworkSetAttr $neighbor -localIpAddress $local_loopback_ip_addr
                        debug "ixNetworkSetAttr $neighbor -dutIpAddress $remote_loopback_ip_addr"
                        ixNetworkSetAttr $neighbor -dutIpAddress   $remote_loopback_ip_addr
                    }
                    6 {
                        if {[info exists interface_handle]} {
                            debug "ixNetworkSetAttr $neighbor -localIpAddress $local_loopback_ipv6_addr"
                            ixNetworkSetAttr $neighbor -localIpAddress $local_loopback_ipv6_addr
                            debug "ixNetworkSetAttr $neighbor -dutIpAddress $remote_loopback_ipv6_addr"
                            ixNetworkSetAttr $neighbor -dutIpAddress $remote_loopback_ipv6_addr
                        } else {
                            debug "ixNetworkSetAttr $neighbor -localIpAddress $local_loopback_ip_addr"
                            ixNetworkSetAttr $neighbor -localIpAddress $local_loopback_ip_addr
                            debug "ixNetworkSetAttr $neighbor -dutIpAddress $remote_loopback_ip_addr"
                            ixNetworkSetAttr $neighbor -dutIpAddress   $remote_loopback_ip_addr
                        }
                    }
                }
            } elseif {$connected_ip_version != 0}  {
                switch -- $connected_ip_version {
                    4 {
                        if {$intf_objref_type == "ProtocolIntf"} {
                            debug "ixNetworkSetAttr $neighbor -localIpAddress $local_ip_addr"
                            ixNetworkSetAttr $neighbor -localIpAddress $local_ip_addr
                        }
                        debug "ixNetworkSetAttr $neighbor -dutIpAddress $remote_ip_addr"
                        ixNetworkSetAttr $neighbor -dutIpAddress $remote_ip_addr
                    }
                    6 {
                        if {$intf_objref_type == "ProtocolIntf"} {
                            debug "ixNetworkSetAttr $neighbor -localIpAddress $local_ipv6_addr"
                            ixNetworkSetAttr $neighbor -localIpAddress $local_ipv6_addr
                        }
                        debug "ixNetworkSetAttr $neighbor -dutIpAddress $remote_ipv6_addr"
                        ixNetworkSetAttr $neighbor -dutIpAddress $remote_ipv6_addr
                    }
                }
            }
            if {![info exists interface_handle]} {
                switch -- $connected_ip_version {
                    4 {
                        if {[info exists remote_addr_step]} {
                            set remote_ip_addr [::ixia::incr_ipv4_addr \
                                    $remote_ip_addr $remote_addr_step]
                            
                            set gateway_ip_addr [::ixia::incr_ipv4_addr \
                                    $gateway_ip_addr $remote_addr_step]
                        }
                        if {[info exists local_addr_step]} {
                            set local_ip_addr [::ixia::incr_ipv4_addr \
                                    $local_ip_addr $local_addr_step]
                        }
                    }
                    6 {
                        if {[info exists local_addr_step]} {
                            set local_ipv6_addr [::ixia::incr_ipv6_addr \
                                    $local_ipv6_addr $local_addr_step]
                        }
                        if {[info exists remote_addr_step]} {
                            set remote_ipv6_addr [::ixia::incr_ipv6_addr \
                                    $remote_ipv6_addr $remote_addr_step]
                            
                            set gateway_ip_addr [::ixia::incr_ipv6_addr \
                                    $gateway_ip_addr $remote_addr_step]

                        }
                    }
                }
                switch -- $unconnected_ip_version {
                    4 {
                        if {[info exists local_loopback_ip_addr] && \
                                ($local_loopback_ip_addr != "")  && \
                                [info exists local_loopback_ip_addr_step]} {
                            set local_loopback_ip_addr [::ixia::incr_ipv4_addr \
                                    $local_loopback_ip_addr \
                                    $local_loopback_ip_addr_step]
                        }
                        if {[info exists remote_loopback_ip_addr] && \
                                ($remote_loopback_ip_addr != "")  && \
                                [info exists remote_loopback_ip_addr_step]} {
                            set remote_loopback_ip_addr [::ixia::incr_ipv4_addr \
                                    $remote_loopback_ip_addr \
                                    $remote_loopback_ip_addr_step]
                        }
                    }
                    6 {
                        if {[info exists local_loopback_ip_addr] && [info \
                                exists local_loopback_ip_addr_step]} {
                            set local_loopback_ip_addr [::ixia::incr_ipv6_addr \
                                    $local_loopback_ip_addr $local_loopback_ip_addr_step]
                        }
                        if {[info exists remote_loopback_ip_addr] && [info \
                                exists remote_loopback_ip_addr_step]} {
                            set remote_loopback_ip_addr [::ixia::incr_ipv6_addr \
                                    $remote_loopback_ip_addr $remote_loopback_ip_addr_step]
                        }
                    }
                }
            } else {
                set local_ip_addr             [lindex $local_ip_addr_list             [expr $i + 1]]
                set remote_ip_addr            [lindex $remote_ip_addr_list            [expr $i + 1]]
                set gateway_ip_addr           [lindex $gateway_ip_addr_list           [expr $i + 1]]
                set local_loopback_ip_addr    [lindex $local_loopback_ip_addr_list    [expr $i + 1]]
                set remote_loopback_ip_addr   [lindex $remote_loopback_ip_addr_list   [expr $i + 1]]
                set local_ipv6_addr           [lindex $local_ipv6_addr_list           [expr $i + 1]]
                set remote_ipv6_addr          [lindex $remote_ipv6_addr_list          [expr $i + 1]]
                set local_loopback_ipv6_addr  [lindex $local_loopback_ipv6_addr_list  [expr $i + 1]]
                set remote_loopback_ipv6_addr [lindex $remote_loopback_ipv6_addr_list [expr $i + 1]]
            }
            
            # set static router params
            foreach {ixn_opt ixn_value} $static_router_args {
                debug "ixNetworkSetAttr $neighbor -$ixn_opt $ixn_value"
                ixNetworkSetAttr $neighbor -$ixn_opt $ixn_value
            }
            # set dynamic router params
            foreach {hlt_param ixn_param} \
                $dynamic_router_param_list {
                if {[info exists $hlt_param]} {
                    set param_value [set $hlt_param]
                    if {[info exists translate_param_array($hlt_param,$param_value)]} {
                        set param_value $translate_param_array($hlt_param,$param_value)
                    }
                    debug "ixNetworkSetAttr $neighbor -$ixn_param $param_value"
                    ixNetworkSetAttr $neighbor -$ixn_param $param_value
                }
            }
            
            if {![info exists local_router_id_enable] || $local_router_id_enable == 0} {
                debug "ixNetworkSetAttr $neighbor -enableBgpId false"
                ixNetworkSetAttr $neighbor -enableBgpId false
            } 
            # set capabilities
            foreach {ixn_node ixn_opt ixn_value} $capabilities_args {
                set ixnCmd "ixNetworkSetAttr ${neighbor}${ixn_node} -$ixn_opt $ixn_value"
                debug $ixnCmd
                eval  $ixnCmd
            }
            # increment
            if {[info exists local_router_id]} {
                if {![info exists local_router_id_step]} {set local_router_id_step 0.0.0.1}
                set local_router_id [::ixia::incr_ipv4_addr $local_router_id $local_router_id_step]
            }
            if {[info exists local_as]} {
                if {$local_as_mode == "increment"} {
                    mpincr local_as $local_as_step
                }
            }
            
            incr objectCount
            if { $objectCount >= $objectMaxCount && ![info exists no_write]} {
                debug "ixNetworkCommit"
                ixNetworkCommit
                set objectCount 0
            }

            lappend neigh_list $neighbor
        }
        
        if {$objectCount > 0 && ![info exists no_write]} {
            debug "ixNetworkCommit"
            ixNetworkCommit
        }

        set neigh_list [ixNet remapIds $neigh_list]
        foreach neigh $neigh_list intf $conn_list {
            set ::ixia::bgp_neig_conn_map($neigh) $intf
        }
        if {[info exists unconn_list]} {
            foreach neigh $neigh_list intf $unconn_list {
                set ::ixia::bgp_neig_unconn_map($neigh) $intf
            }
        }

        # return result
        keylset returnList status $::SUCCESS
        keylset returnList handles $neigh_list
        return $returnList
    }

    if {$mode == "modify"} {
        # Remove defaults
        removeDefaultOptionVars $opt_args $args

        foreach neig $handle {
            if {[info exists connected_intf]} {
                unset connected_intf
            }
            if {[info exists unconnected_intf]} {
                unset unconnected_intf
            }
            catch {set connected_intf $::ixia::bgp_neig_conn_map($neig)}
            catch {set unconnected_intf $::ixia::bgp_neig_unconn_map($neig)}
            if {$connected_intf == {}} {
                keylset returnList status $::FAILURE
                keylset returnList log "No interface has been found for the\
                        $neig BGP neighbor."
                return $returnList
            }
            if {$unconnected_intf == {}} {
                unset unconnected_intf
            }

            if {![info exists neighbor_type]} {
                set neighbor_type [ixNetworkGetAttr $neig -type]
            }

            # Get the port handle of the port on which the neighbor has been 
            # configured
            if {![regexp {^(.*)/protocols/bgp/neighborRange:[0-9a-zA-Z]+$} $neig {} \
                    port_objref]} {
                keylset returnList status $::FAILURE
                keylset returnList log "The $neig handle is not a valid\
                        BGP neighbor handle."
                return $returnList
            }
            set neigh_port_handle [ixNetworkGetRouterPort $port_objref]
            if {$neigh_port_handle == "0/0/0"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to determine the port on\
                        which the $port_objref port object reference is\
                        configured."
                return $returnList
            }
            if {[info exists port_handle] && $port_handle != $neigh_port_handle} {
                keylset returnList status $::FAILURE
                keylset returnList log "The $neig BGP neighbor has been created\
                        on port $neigh_port_handle, not on port $port_handle."
                return $returnList
            } else {
                set port_handle $neigh_port_handle
            }

            # (Re)configure interface
            if {[info exists vlan_id] && ![info exist vlan_user_priority]} {
                set vlan_user_priority 0
            }
            if {![info exists ip_version]} {
                set ip_version 4
            }

            if {$ip_version == "4"} {
                # Test for IP address correctness
                if {[info exists local_loopback_ip_addr] && \
                        ![::isIpAddressValid $local_loopback_ip_addr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "$local_loopback_ip_addr is not a\
                            valid IPv4 value for the -local_loopback_ip_addr\
                            attribute."
                    return $returnList
                }
                if {[info exists remote_loopback_ip_addr] && \
                        ![::isIpAddressValid $remote_loopback_ip_addr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "$remote_loopback_ip_addr is not a\
                            valid IPv4 value for the -remote_loopback_ip_addr\
                            attribute."
                    return $returnList
                }

                # A necessary default
                if {![info exists gateway_ip_addr] && \
                        [info exists remote_ip_addr]} {
                    set gateway_ip_addr $remote_ip_addr
                }

                # Add/modify connected interface
                set protocol_intf_options "                                     \
                        -atm_encapsulation          atm_encapsulation           \
                        -atm_vci                    vci                         \
                        -atm_vpi                    vpi                         \
                        -gateway_address            gateway_ip_addr             \
                        -ipv4_address               local_ip_addr               \
                        -ipv4_prefix_length         netmask                     \
                        -mac_address                mac_address_start           \
                        -port_handle                port_handle                 \
                        -vlan_enabled               vlan                        \
                        -vlan_id                    vlan_id                     \
                        -vlan_user_priority         vlan_user_priority          \
                        "
    
                # Passed in only those options that exists
                set protocol_intf_args ""
                foreach {option value_name} $protocol_intf_options {
                    if {[info exists $value_name]} {
                        append protocol_intf_args " $option [set $value_name]"
                    }
                }
    
                if {![string equal $protocol_intf_args ""]} {
                    # Create/modify the necessary connected interface
                    if {[info exists connected_intf]} {
                        append protocol_intf_args \
                                " -prot_intf_objref $connected_intf"
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to get the handle of the\
                                connected interface used by this BGP neighbor.\
                                This shouldn't have happened. Log a bug to HLT."
                        return $returnList
                    }
                    set result [eval ixNetworkConnectedIntfCfg \
                            $protocol_intf_args]
                    if {[keylget result status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to create/modify the\
                                $connected_intf IPv4 connected interface -\
                                [keylget result log]"
                        return $returnList
                    } else {
                        if {![info exists no_write]} {
                            catch {ixNetworkCommit}
                            debug "ixNetworkCommit"
                        }
                    }
                }

                # Add/modify unconnected interface
                set protocol_intf_args ""
                if {[info exists local_loopback_ip_addr]} {
                    append protocol_intf_args \
                            " -loopback_ipv4_address $local_loopback_ip_addr"
                    append protocol_intf_args \
                            " -connected_via $connected_intf"
                }
    
                if {![string equal $protocol_intf_args ""]} {
                    if {[info exists port_handle]} {
                        append protocol_intf_args \
                                " -port_handle $port_handle"
                    }
                    if {[info exists unconnected_intf]} {
                        append protocol_intf_args \
                                " -prot_intf_objref $unconnected_intf"
                    }
                    # Create/modify the necessary unconnected interface
                    set result [eval ixNetworkUnconnectedIntfCfg \
                            $protocol_intf_args]
                    if {[keylget result status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to create/modify the\
                                IPv4 unconnected interface -\
                                [keylget result log]"
                        return $returnList
                    } else {
                        if {![info exists no_write]} {
                            catch {ixNetworkCommit}
                            debug "ixNetworkCommit"
                        }
                        set old_intf_objref [keylget result interface_handle]
                        set new_intf_objref [ixNet remapIds $old_intf_objref]
                        set ::ixia::bgp_neig_unconn_map($neig) $new_intf_objref
                        
                        set ret_code [rfremap_interface_handle $old_intf_objref]
                        if {[keylget ret_code status] != $::SUCCESS} {
                            return $ret_code
                        }
                    }
                }

                # Set the neighbor's addresses in accordance with the capabilities
                if {[info exists local_loopback_ip_addr] && ($local_loopback_ip_addr != "") && \
                        [info exists remote_loopback_ip_addr] && ($remote_loopback_ip_addr != "")  } {
                    ixNetworkSetAttr $neig -localIpAddress $local_loopback_ip_addr
                    debug "ixNetworkSetAttr $neig -localIpAddress $local_loopback_ip_addr"
                    ixNetworkSetAttr $neig -dutIpAddress $remote_loopback_ip_addr
                    debug "ixNetworkSetAttr $neig -dutIpAddress $remote_loopback_ip_addr"
                } elseif {[info exists local_ip_addr] && ($local_ip_addr != "") && \
                        [info exists remote_ip_addr] && ($remote_ip_addr != "")  } {
                    if {[info exists local_ip_addr]} {
                        ixNetworkSetAttr $neig -localIpAddress $local_ip_addr
                        debug "ixNetworkSetAttr $neig -localIpAddress $local_ip_addr"
                    }
                    if {[info exists remote_ip_addr]} {
                        ixNetworkSetAttr $neig -dutIpAddress $remote_ip_addr
                        debug "ixNetworkSetAttr $neig -dutIpAddress $remote_ip_addr"
                    }
                }
            } else {
                # Test for IP address correctness
                if {[info exists local_loopback_ip_addr] && \
                        ![::ipv6::isValidAddress $local_loopback_ip_addr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "$local_loopback_ip_addr is not a\
                            valid IPv6 value for the -local_loopback_ip_addr\
                            attribute."
                    return $returnList
                }
                if {[info exists remote_loopback_ip_addr] && \
                        ![::ipv6::isValidAddress $remote_loopback_ip_addr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "$remote_loopback_ip_addr is not a\
                            valid IPv6 value for the -remote_loopback_ip_addr\
                            attribute."
                    return $returnList
                }

                # Add/modify connected interface
                set protocol_intf_options "                                     \
                        -atm_encapsulation          atm_encapsulation           \
                        -atm_vci                    vci                         \
                        -atm_vpi                    vpi                         \
                        -ipv6_address               local_ipv6_addr             \
                        -ipv6_prefix_length         netmask                     \
                        -mac_address                mac_address_start           \
                        -port_handle                port_handle                 \
                        -vlan_enabled               vlan                        \
                        -vlan_id                    vlan_id                     \
                        -vlan_user_priority         vlan_user_priority          \
                        "
    
                # Passed in only those options that exists
                set protocol_intf_args ""
                foreach {option value_name} $protocol_intf_options {
                    if {[info exists $value_name]} {
                        append protocol_intf_args " $option [set $value_name]"
                    }
                }
    
                if {![string equal $protocol_intf_args ""]} {
                    # Create/modify the necessary connected interface
                    if {[info exists connected_intf]} {
                        append protocol_intf_args \
                                " -prot_intf_objref $connected_intf"
                    }
                    set result [eval ixNetworkConnectedIntfCfg \
                            $protocol_intf_args]
                    if {[keylget result status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to create/modify the\
                                $connected_intf IPv6 connected interface -\
                                [keylget result log]"
                        return $returnList
                    }
                }
                if {![info exists no_write]} {
                    catch {ixNetworkCommit}
                    debug "ixNetworkCommit"
                }

                # Add/modify unconnected interface
                set protocol_intf_options "                                     \
                        -loopback_ipv6_address      local_loopback_ip_addr      \
                        -port_handle                port_handle                 \
                        "
    
                # Passed in only those options that exists
                set protocol_intf_args ""
                foreach {option value_name} $protocol_intf_options {
                    if {[info exists $value_name]} {
                        append protocol_intf_args " $option [set $value_name]"
                    }
                }
    
                if {![string equal $protocol_intf_args ""]} {
                    # Create/modify the necessary unconnected interface
                    if {[info exists unconnected_intf]} {
                        append protocol_intf_args \
                                " -prot_intf_objref $unconnected_intf"
                    }
                    set result [eval ixNetworkUnconnectedIntfCfg \
                            $protocol_intf_args]
                    if {[keylget result status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to create/modify the\
                                IPv6 unconnected interface -\
                                [keylget result log]"
                        return $returnList
                    }
                }
                if {![info exists no_write]} {
                    catch {ixNetworkCommit}
                    debug "ixNetworkCommit"
                }

                # Set the neighbor's addresses in accordance with the capabilities
                if {[info exists local_loopback_ip_addr] && ($local_loopback_ip_addr != "") && \
                        [info exists remote_loopback_ip_addr] && ($remote_loopback_ip_addr != "")} {
                    ixNetworkSetAttr $neig -localIpAddress $local_loopback_ip_addr
                    debug "ixNetworkSetAttr $neig -localIpAddress $local_loopback_ip_addr"
                    ixNetworkSetAttr $neig -dutIpAddress $remote_loopback_ip_addr
                    debug "ixNetworkSetAttr $neig -dutIpAddress $remote_loopback_ip_addr"
                } elseif {[info exists local_ipv6_addr] && ($local_ipv6_addr != "") && \
                        [info exists remote_ipv6_addr] && ($remote_ipv6_addr != "")} {
                    if {[info exists local_ipv6_addr]} {
                        ixNetworkSetAttr $neig -localIpAddress $local_ipv6_addr
                        debug "ixNetworkSetAttr $neig -localIpAddress $local_ipv6_addr"
                    }
                    if {[info exists remote_ipv6_addr]} {
                        ixNetworkSetAttr $neig -dutIpAddress $remote_ipv6_addr
                        debug "ixNetworkSetAttr $neig -dutIpAddress $remote_ipv6_addr"
                    }
                }
            }

            # Cleanup
            if {[info exists connected_intf]} {
                unset connected_intf
            }
            if {[info exists unconnected_intf]} {
                unset unconnected_intf
            }

            # Set static router params
            foreach {ixn_opt ixn_value} $static_router_args {
                debug "ixNetworkSetAttr $neig -$ixn_opt $ixn_value"
                ixNetworkSetAttr $neig -$ixn_opt $ixn_value
            }

            # Set dynamic router params
            foreach {hlt_param ixn_param} \
                $dynamic_router_param_list {
                if {[info exists $hlt_param]} {
                    set param_value [set $hlt_param]
                    if {[info exists translate_param_array($hlt_param,$param_value)]} {
                        set param_value $translate_param_array($hlt_param,$param_value)
                    }
                    debug "ixNetworkSetAttr $neig -$ixn_param $param_value"
                    ixNetworkSetAttr $neig -$ixn_param $param_value
                }
            }
            if {[info exists local_router_id_enable] && $local_router_id_enable == 0} {
                debug "ixNetworkSetAttr $neig -enableBgpId false"
                ixNetworkSetAttr $neig -enableBgpId false
            }

            # Set capabilities
            foreach {ixn_node ixn_opt ixn_value} $capabilities_args {
                set ixnCmd "ixNetworkSetAttr ${neig}${ixn_node} -$ixn_opt $ixn_value"
                debug $ixnCmd
                eval  $ixnCmd
            }
        }

        # neighbor settings
        if {![info exists neighbor_type]} {
            debug "ixNetworkGetAttr $neig -type"
            set neighbor_type [string tolower [ixNetworkGetAttr $neig -type]]
        }
        foreach {hlt_protocol_param ixn_protocol_param} \
                [set ${neighbor_type}_protocol_param_list] {
            if {[info exists $hlt_protocol_param]} {
                set param_value [set $hlt_protocol_param]
                if {[info exists translate_param_array($hlt_protocol_param,$param_value)]} {
                    set param_value $translate_param_array($hlt_protocol_param,$param_value)
                }
                debug "ixNetworkSetAttr $protocol_objref -$ixn_protocol_param $param_value"
                ixNetworkSetAttr $protocol_objref -$ixn_protocol_param $param_value
            }
        }
        if {![info exists no_write]} {
            catch {ixNetworkCommit}
            debug "ixNetworkCommit"
        }
        keylset returnList handles $handle
        keylset returnList status  $::SUCCESS
        return $returnList
    }
}

proc ::ixia::ixnetwork_bgp_route_config { args man_args opt_args } {
    variable ixnetworkVersion
    variable objectMaxCount
    set objectCount 0

    set cluster_regexp         "^(\[0-9\]{1,3}\\.\[0-9\]{1,3}\\.\[0-9\]{1,3}\\.\[0-9\]{1,3}\\s*)+$"
    set cluster_regexp_numeric "^(\[0-9\]+\\s*)+$"
    
    if {[catch {::ixia::parse_dashed_args     \
            -args           $args             \
            -mandatory_args $man_args         \
            -optional_args  $opt_args         \
            } parseError]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$parseError."
        return $returnList
    }
    foreach handle_param [list handle route_handle l3_site_handle] {
        if {![catch {ixNet remapIds [set $handle_param]} outh]} {
            set $handle_param $outh
        }
    }
    
    # Validating cluster list...
    if {[info exists cluster_list]} {
        set ip_valid_result [regexp -all $cluster_regexp $cluster_list]
        set nr_valid_result [regexp -all $cluster_regexp_numeric $cluster_list]
        if { $ip_valid_result || $nr_valid_result } {
            # Argument is valid. Moving on...
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "Invalid list \"$cluster_list\" for \"-cluster_list\" argument. \
                    A list of IP addresses or a list of numeric cluster IDs is required."
            return  $returnList
        }
    } else {
        set nr_valid_result 0
    }
    # Cluster list validated.
    
    if {[info exists vpls_nlri] && ($vpls_nlri != 0) && ($vpls_nlri != "disabled")} {
        set vpls 1
    } elseif {[info exists vpls] && ($vpls != 0) && ($vpls != "disabled")} {
        set vpls 1
    } else {
        set vpls 0
    }
    
    # routeType
    if {([info exists num_sites] || [info exists end_of_rib]) && ([info exists ipv4_mpls_vpn_nlri] || [info exists ipv6_mpls_vpn_nlri])} {
        set routeType vpn
    } elseif {[info exists num_sites] && [info exists vpls] && $vpls} {
        set routeType vpls
    } elseif {[info exists ipv4_mpls_nlri] || [info exists ipv6_mpls_nlri]} {
        set routeType mpls
    }  else {
        set routeType normal
    }
        
    set commands_global {}
   
    if {$mode == "add"} {
        if {[info exists handle]} {
            set handle [ixNet remapIds $handle]
            if {[regexp -- {^::ixNet::OBJ-/vport:[0-9]+/protocols/bgp/neighborRange:[0-9a-zA-Z]+$} $handle]} {
                set mode_add  "create"
            } elseif {[regexp -- {^::ixNet::OBJ-/vport:[0-9]+/protocols/bgp/neighborRange:[0-9a-zA-Z]+/l2Site:[0-9a-zA-Z]+$} $handle]} {
                set mode_add  "l2Site"
                set vpls      1
                set routeType vpls
                set l2Site_handle $handle
                set handle [ixNetworkGetParentObjref $handle "neighborRange"]
            } elseif {[regexp -- {^::ixNet::OBJ-/vport:[0-9]+/protocols/bgp/neighborRange:[0-9a-zA-Z]+/l3Site:[0-9a-zA-Z]+$} $handle]} {
                set mode_add  "l3Site"
                set vpls      0
                set routeType vpn
                set l3Site_handle $handle
                set handle [ixNetworkGetParentObjref $handle "neighborRange"]
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid value $handle for -handle parameter.\
                        You should provide a valid BGP neighbor handle or L2Site handle or L3Site Handle."
                return $returnList
            }
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode, parameter -handle\
                    should be provided."
            return $returnList
        }
		
        if {![info exists prefix] && $routeType != "vpls" && ![info exists end_of_rib]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode, the parameter -prefix\
                    should be provided."
            return $returnList
        } elseif {[info exists prefix] && \
                ![::ipv6::isValidAddress $prefix] && \
                ![isIpAddressValid $prefix]} {
            keylset returnList status $::FAILURE
            keylset returnList log "The parameter -prefix $prefix is not a\
                    valid IPv4 or IPv6 address."
            return $returnList
        } elseif {$routeType == "vpls"} {
            set prefix 0.0.0.0
        }
		if {[info exists end_of_rib] && ![info exists prefix]} {
			if {$ip_version == 4} {
				set prefix 0.0.0.0
			} else {
				set prefix "0:0:0:0:0:0:0:0"
			}
		}
        if {![info exists route_ip_addr_step]} {
            if {$ip_version == 4} {
                set route_ip_addr_step 0.0.0.1
            } else {
                set prefix             [::ixia::expand_ipv6_addr $prefix]
                set route_ip_addr_step [::ixia::expand_ipv6_addr 0::1]
            }
        } else {
            if {$ip_version == 6} {
                set prefix             [::ixia::expand_ipv6_addr $prefix]
                set route_ip_addr_step [::ixia::expand_ipv6_addr $route_ip_addr_step]
            }
        }
        if {![info exists as_path]} {
            debug "ixNetworkGetAttr $handle -localAsNumber"
            set as_path "as_set:[ixNetworkGetAttr $handle -localAsNumber]"
        }
        set route_range_list {}
        # vpn
        # Param list
        # flag options for route range

        set global_list {
            prefix                      networkAddress
            num_routes                  numRoutes
            prefix_step                 iterationStep
            prefix_step_across_vrfs     routeStepAcrossVRFs
            packing_from                fromPacking
            packing_to                  thruPacking
            origin                      originProtocol
            next_hop                    nextHopIpAddress
            next_hop_mode               nextHopMode
            next_hop_set_mode           nextHopSetMode
            multi_exit_disc             med
            local_pref                  localPref
            prefix_from                 fromPrefix
            prefix_to                   thruPrefix
            originator_id               originatorId
            ip_version                  ipType
        }
            
        if {[info exists multi_exit_disc]} {
            set enable_med true
        }
        if {[info exists aggregator]} {
            set enable_aggregator true
        }
        
        set options_list_flags {
            origin_route_enable            enableOrigin
            next_hop_enable                enableNextHop
            enable_aggregator              enableAggregator
            atomic_aggregate               enableAtomicAttribute
            communities_enable             enableCommunity
            cluster_list_enable            enableCluster
            enable_med                     enableMed
            enable_generate_unique_routes  enableGenerateUniqueRoutes
            enable_traditional_nlri        enableTraditionalNlriUpdate
            end_of_rib                     endOfRib
            enable_as_path                 enableAsPath
            enable_local_pref              enableLocalPref
            originator_id_enable           enableOriginatorId
        }
        
        set flapping_list {
            flap_down_time                          downTime
            flap_up_time                            upTime
            partial_route_flap_from_route_index     routesToFlapFrom
            partial_route_flap_to_route_index       routesToFlapTo
        }

        set vpn_param_list {
            rd_count                                distinguisherCount
            rd_count_per_vrf                        distinguisherCountPerVrf
            rd_admin_ip                             distinguisherIpAddress
            rd_admin_ip_step                        distinguisherIpAddressStep
            rd_admin_ip_step_across_vrfs            distinguisherIpAddressStepAcrossVrfs
            rd_admin_as                             distinguisherAsNumber
            rd_admin_as_step                        distinguisherAsNumberStep
            rd_admin_as_step_across_vrfs            distinguisherAsNumberStepAcrossVrfs
            rd_assign_value                         distinguisherAssignedNumber
            rd_assign_value_step                    distinguisherAssignedNumberStep
            rd_assign_value_step_across_vrfs        distinguisherAssignedNumberStepAcrossVrfs
            rd_type                                 distinguisherType
            originator_id_enable                    enableOriginatorId
        }
        
        set vpn_multicast_list {
            rd_admin_ip             ipAddress
            rd_admin_as             asNumber
            rd_assign_value         assignedNumber
            rd_type                 type
        }
        
        set mpls_options_list {
            label_value 
            label_incr_mode 
            label_step
            label_value_stop
            label_id 
        }

        set mpls_commands {start mode step end labelId}

        # prepare values for set
        switch -- $ip_version {
            4 {set ip_version ipv4}
            6 {set ip_version ipv6}
            ipv4 {}
            ipv4 {}
            default {set ip_version ipAny}
        }        
        
        array set translate_next_hop_mode {
            fixed               fixed 
            increment           nextHopIncrement
            incrementPerPrefix  incrementPerPrefix
        }
        
        array set translate_next_hop_set_mode {
            same                sameAsLocalIp 
            manual              setManually
        }
        
        array set translate_next_hop_ip_version {
            4     ipv4
            6     ipv6
        }
    
        array set translate_as_path_set_mode {
            include_as_seq        includeAsSeq
            include_as_seq_conf   includeAsSeqConf
            include_as_set        includeAsSet
            include_as_set_conf   includeAsSetConf
            no_include            noInclude
            prepend_as            prependAs
        }
                
        # L2 Sites mapping lists -----------------------------------------------
        set l2_sites_mappings {
            mtu                     mtu
            site_id                 siteId
            target_type             routeTargetType
            target                  anything_goes
            target_assign           routeTargetAssignedNum
            rd_type                 routeDistinguisherType
            rd_admin_value          anything_goes
            rd_assign_value         routeDistinguisherAssignedNum
        }
        set label_block_map {
            label_block_offset      offset
            label_value             start
            num_labels              numberOfLabels
            enable_block            enabled
        }
        set l2_mac_ranges_mappings {
            l2_start_mac_addr       startMacAddress         mac
            l2_mac_incr             macIncrement            truth
            l2_enable_vlan          enableVlan              truth
            l2_vlan_id              vlanId                  value
            l2_vlan_incr            incrementVlanMode       translate
        }
        if {$ixnetworkVersion>=6.30} {
            append l2_mac_ranges_mappings {l2_mac_count            macCountPerL2Site       value}
        } else {
            append l2_mac_ranges_mappings {l2_mac_count            macCount                value}
        }
        array set l2_sites_incr_vlan_translations {
            0                   noIncrement
            1                   parallelIncrement
            2                   innerFirst
            3                   outerFirst
            no_increment        noIncrement
            parallel_increment  parallelIncrement
            inner_first         innerFirst
            outer_first         outerFirst
        }
        array set l2_sites_target_translations {
            target_as               routeTargetAs
            target_ip               routeTargetIp
            0                       twoOctetAs
            1                       ip
            2                       fourOctetAs
            rd_admin_ip             routeDistinguisherIp
            rd_admin_as             routeDistinguisherAs
            ip                      ip
        }
        array set l2_target_types {
            0                       rd_admin_as
            1                       rd_admin_ip
            2                       rd_admin_as
            ip                      target_ip
            as                      target_as
            target                  target_type
            rd_admin_value          rd_type
        }
        array set l2_steps {
            target                  target_step
            rd_admin_value          rd_admin_step
        }
        
        if {[info exists next_hop_mode]} {
            set next_hop_mode     $translate_next_hop_mode($next_hop_mode)
        }
        if {[info exists next_hop_set_mode]} {
            set next_hop_set_mode $translate_next_hop_set_mode($next_hop_set_mode)
        }
        if {[info exists next_hop_ip_version]} {
            set next_hop_ip_version $translate_next_hop_ip_version($next_hop_ip_version)
        }
        if {[info exists as_path_set_mode]} {
            set as_path_set_mode $translate_as_path_set_mode($as_path_set_mode)
        }
        if {[info exists netmask]} {
            set prefix_from [getIpV4MaskWidth $netmask]
        } elseif {[info exists ipv6_prefix_length]} {
            set prefix_from $ipv6_prefix_length
        }
        
        if {![info exists enable_traditional_nlri]} {
            set enable_traditional_nlri 0
        }
        
        if {![info exists num_routes]} {set num_routes 1}
        
        if {![info exists num_sites]} {set num_sites 1}
		
        # Route ranges
        set l23SiteParam_list    ""
        set route_range_list ""
        # Not really needed - default rd_type is 0
        if {![info exists rd_type] && ($routeType == "vpn" || $routeType == "vpls")} {
            keylset returnList status $::FAILURE
            keylset returnList log "The Route\
                    Distinguisher Type needs to be specified via the option\
                    -rd_type RANGE 0-2."
            return $returnList
        }
        
        if {($routeType == "vpn" || $routeType == "vpls")} {
            foreach rd_type_elem $rd_type {
                switch $rd_type_elem {
                    0 -
                    2 {
                        if {![info exists rd_admin_value] || ([info exists rd_admin_value_exists] && $rd_admin_value_exists) } {
                            lappend rd_admin_value          0
                            set rd_admin_value_exists       1
                        }
                        if {![info exists rd_admin_value_step] || ([info exists rd_admin_value_step_exists] && $rd_admin_value_step_exists)} {
                            lappend rd_admin_value_step         0
                            set rd_admin_value_step_exists      1
                        }
                        if {![info exists rd_admin_value_step_across_vrfs] || ([info exists rd_admin_value_step_across_vrfs_exists] && $rd_admin_value_step_across_vrfs_exists)} {
                            lappend rd_admin_value_step_across_vrfs     0
                            set rd_admin_value_step_across_vrfs_exists  1
                        }
                    }
                    1 {
                        if {![info exists rd_admin_value] || ([info exists rd_admin_value_exists] && $rd_admin_value_exists)} {
                            lappend rd_admin_value     0.0.0.0
                            set rd_admin_value_exists  1
                        }
                        if {![info exists rd_admin_value_step] || ([info exists rd_admin_value_step_exists] && $rd_admin_value_step_exists) } {
                            lappend rd_admin_value_step     0.0.0.0
                            set rd_admin_value_step_exists  1
                        }
                        if {![info exists rd_admin_value_step_across_vrfs] || ([info exists rd_admin_value_step_across_vrfs_exists] && $rd_admin_value_step_across_vrfs_exists)} {
                            lappend rd_admin_value_step_across_vrfs     0.0.0.0
                            set rd_admin_value_step_across_vrfs_exists  1
                        }
                    }
                }
            }
            if {![info exists rd_assign_value]} {
                set rd_assign_value 0
            }
            if {![info exists rd_assign_value_step]} {
                set rd_assign_value_step 0
            }
            if {![info exists rd_assign_value_step_across_vrfs]} {
                set rd_assign_value_step_across_vrfs 0
            }
        }
        
        if {$mode_add == "l2Site" || $mode_add == "l3Site"} {
            set num_sites        1
        }
        
        for {set vpn_count 0} {$vpn_count < $num_sites} {incr vpn_count} {
            if {$routeType == "vpn" || $routeType == "vpls" } {
                if {$vpn_count == 0} {
                    if {[info exists rd_type]} {
                        if {[llength $rd_type] > 1} {
                            set rd_type_selection                           [lindex $rd_type                            $vpn_count]
                            set rd_admin_value_selection                    [lindex $rd_admin_value                     $vpn_count]
                            set rd_admin_value_step_selection               [lindex $rd_admin_value_step                $vpn_count]
                            set rd_admin_value_step_across_vrfs_selection   [lindex $rd_admin_value_step_across_vrfs    $vpn_count]
                        } else {
                            set rd_type_selection                           $rd_type
                            set rd_admin_value_selection                    $rd_admin_value
                            set rd_admin_value_step_selection               $rd_admin_value_step
                            set rd_admin_value_step_across_vrfs_selection   $rd_admin_value_step_across_vrfs
                        }
                        if {$rd_type_selection == 0 || $rd_type_selection == 2} {
                            if {[regexp -- {^[0-9]+$} $rd_admin_value_selection] != 0} {
                                set rd_admin_as                     $rd_admin_value_selection
                                set rd_admin_as_step                $rd_admin_value_step_selection
                                set rd_admin_as_step_across_vrfs    $rd_admin_value_step_across_vrfs_selection
                            } else {
                                keylset returnList status $::FAILURE
                                keylset returnList log "\
                                         Invalid rd_admin_value for AS type."
                                return $returnList
                            }
                        } else {
                            if {[::isIpAddressValid $rd_admin_value_selection] == 1} {
                                set rd_admin_ip                     $rd_admin_value_selection
                                set rd_admin_ip_step                $rd_admin_value_step_selection
                                set rd_admin_ip_step_across_vrfs    $rd_admin_value_step_across_vrfs_selection
                            } else {
                                keylset returnList status $::FAILURE
                                keylset returnList log "\
                                        Invalid rd_admin_value for IP type."
                                return $returnList
                            }
                        }
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "\
                                The Route Distinguisher Type needs\
                                to be specified with the option\
                                -rd_type RANGE 0-2."
                        return $returnList
                    }
                }
                
                if {$routeType == "vpn"} {
                    # adding l3Site object
                    if {$mode_add == "l3Site"} {
                        set vpnParam $l3Site_handle
                        
                        # configure VRF count
                        if {[info exists target_count]} {
                            ixNetworkSetAttr $vpnParam -vrfCount $target_count
                        }
                        
                    } else {
                        set cmd ""
                        lappend cmd ixNetworkAdd $handle l3Site -enabled true
                        
                        # configure VRF count
                        if {[info exists target_count]} {
                           lappend cmd -vrfCount $target_count
                        }
                        
                        set vpnParam [eval $cmd]
                    }
                    
                    # configure multicast
                    if {[info exists default_mdt_ip]} {
                        ixNetworkSetAttr $vpnParam/multicast -enableMulticast True -groupAddress $default_mdt_ip
                        if {[info exists default_mdt_ip_incr]} {
                            set default_mdt_ip [ixia::incr_ipv4_addr\
                                $default_mdt_ip $default_mdt_ip_incr]
                        }
                        set pl_route_distinguisher {}
                        foreach {hlt ixn} $vpn_multicast_list {
                            if {[info exists $hlt]} {
                                if {$hlt == "rd_type"} {
                                    array set rd_type_map {
                                        0   as
                                        1   ip
                                        2   asNumber2
                                    }
                                    lappend pl_route_distinguisher -$ixn $rd_type_map([set $hlt])
                                } else {
                                    lappend pl_route_distinguisher -$ixn [set $hlt]
                                }
                            }
                        }
                        if {[llength $pl_route_distinguisher] > 0} {
                            ixNetworkSetMultiAttr $vpnParam/multicast/routeDistinguisher pl_route_distinguisher
                        }
                    }
                    
                    # retting rd params    
                    if {[info exists target_type]} {
                        set target_list {}
                        set i 0
                        foreach targetType $target_type {
                            set target_value [lindex $target $i]
                            set target_assign_value [lindex $target_assign $i]
                            
                            if {$targetType == "as"} {
                                set target_value_inner_step        0
                            } else {
                                set target_value_inner_step        0.0.0.0
                            }
                            
                            set target_assign_value_inner_step 0
                            
                            if {[info exists target_count] && $target_count > 1} {
                                if {[info exists target_inner_step]} {
                                    set target_value_inner_step        [lindex $target_inner_step $i]
                                }
                                
                                if {[info exists target_assign_inner_step]} {
                                    set target_assign_value_inner_step [lindex $target_assign_inner_step $i]
                                }
                            }
                            
                            if {$targetType == "as"} {
                                lappend target_list "as $target_value 0.0.0.0       $target_assign_value $target_value_inner_step $target_assign_value_inner_step 0.0.0.0"
                            } else {
                                lappend target_list "ip 0             $target_value $target_assign_value 0                        $target_assign_value_inner_step $target_value_inner_step"
                            }
                            incr i
                        }
                    }
                    if {[info exists import_target_type]} {
                        set import_target_list {}
                        set i 0
                        foreach targetType $import_target_type {
                            set import_target_value [lindex $import_target $i]
                            set import_target_assign_value [lindex $import_target_assign $i]
                            
                            if {$targetType == "as"} {
                                set import_target_value_inner_step        0
                            } else {
                                set import_target_value_inner_step        0.0.0.0
                            }
                            
                            set import_target_assign_value_inner_step 0
                            
                            if {[info exists target_count] && $target_count > 1} {
                                if {[info exists import_target_inner_step]} {
                                    set import_target_value_inner_step        [lindex $import_target_inner_step $i]
                                }
                                
                                if {[info exists import_target_assign_inner_step]} {
                                    set import_target_assign_value_inner_step [lindex $import_target_assign_inner_step $i]
                                }
                            }
                            
                            if {$targetType == "as"} {
                                lappend import_target_list "as      $import_target_value        0.0.0.0                 $import_target_assign_value     $import_target_value_inner_step     $import_target_assign_value_inner_step         0.0.0.0"
                            } else {
                                lappend import_target_list "ip      0                           $import_target_value    $import_target_assign_value     0                                   $import_target_assign_value_inner_step         $import_target_value_inner_step"
                            }
                            incr i
                        }
                    }
                    if {[info exists target_list]} {
                        ixNetworkSetAttr $vpnParam/target -targetListEx $target_list
                    }
                    if {[info exists import_target_list]} {
                        ixNetworkSetAttr $vpnParam/importTarget -importTargetListEx $import_target_list
                    }
                    lappend l23SiteParam_list $vpnParam
                } else {
                    # adding l2Site object
                    if {$mode_add == "l2Site"} {
                        set vplsParam $l2Site_handle
                    } else {
                        set l2Site_cmd ""
                        
                        lappend l2Site_cmd ixNetworkAdd $handle l2Site -enabled true
                        
                        foreach {param cmd} $l2_sites_mappings {
                            if {[info exists $param]} {
                                set option_value [set $param]
                                if {$cmd == "anything_goes" && [info exists $l2_steps($param)] && [llength [set $param]] == 1} {
                                    set actual_type [lindex [set $l2_target_types($param)] 0]
                                    if {$actual_type == "as" || $actual_type == 0 || $actual_type == 2} {
                                        set option_value [expr [set $param] + [set $l2_steps($param)] * $vpn_count]
                                    } else {
                                        set complete_increment "0.0.0.0"
                                        for {set i 0} {$i < $vpn_count} {incr i} {
                                            set complete_increment [ixia::incr_ipv4_addr $complete_increment [set $l2_steps($param)]]
                                        }
                                        set option_value [ixia::incr_ipv4_addr [set $param] $complete_increment]
                                    }
                                }
                                if {$cmd == "anything_goes"} {
                                    if {[llength [set $param]] > 1} {
                                        set current_type [lindex [set $l2_target_types($param)] $vpn_count]
                                    } else {
                                        set current_type [set $l2_target_types($param)]
                                    }
                                    set param $l2_target_types($current_type)
                                    set cmd   $l2_sites_target_translations($param)
                                }

                                if {[llength $option_value] > 1} {
                                    set option_value [lindex $option_value $vpn_count]
                                }
                                if {$param == "rd_type"} {
                                    set option_value $l2_sites_target_translations($option_value)
                                }
                                lappend l2Site_cmd -$cmd $option_value
                            }
                        }
                        
                        set vplsParam [eval $l2Site_cmd]
                    }
                    
                    set add_mac_range 0
                    set l2_mac_ranges_args ""
                    foreach {param cmd ptype} $l2_mac_ranges_mappings {
                        if {[info exists $param]} {
                            
                            if {![is_default_param_value $param $args]} {
                                # If at least one parameter is provided, add the mac range
                                set add_mac_range 1
                            }
                            
                            set param_value [set $param]
                            switch -- $ptype {
                                value {
                                    if {$param=="l2_vlan_id" && [info exists l2_vlan_id_incr]} {
                                        set $param [expr $param_value + $l2_vlan_id_incr]
                                    }
                                    set ixn_param_value $param_value
                                }
                                truth {
                                    set ixn_param_value $::ixia::truth($param_value)
                                }
                                mac {
                                    set ixn_param_value [::ixia::ixNetworkFormatMac $param_value]
                                }
                                translate {
                                    set ixn_param_value $l2_sites_incr_vlan_translations($param_value)
                                }
                                default {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Internal Error.\
                                            Failed to add 'macAddressRange' object\
                                            to '$vplsParam'. Unhandled value type '$ptype' for\
                                            parameter '$param'"
                                    return $returnList
                                }
                            }
                            lappend l2_mac_ranges_args -$cmd $ixn_param_value
                        }
                    }
                    
                    # adding mac range object
                    if {[llength $l2_mac_ranges_args] > 0 && $add_mac_range} {
                        
                        lappend l2_mac_ranges_args -enabled    true
                        
                        set leaf_status [::ixia::ixNetworkNodeAdd   \
                                                $vplsParam "macAddressRange"\
                                                $l2_mac_ranges_args     ]
                        if {[keylget leaf_status status] != $::SUCCESS} {
                            return $leaf_status
                        }
                    }
                    
                    lappend l23SiteParam_list $vplsParam
                }
                
                # Commit
                incr objectCount
                if { $objectCount >= $objectMaxCount && ![info exists no_write]} {
                    debug "ixNetworkCommit"
                    ixNetworkCommit
                    set objectCount 0
                }
            }
            # used for cluster param
            if {![info exists val_array]} {
                set val_array [list]
            }
            # main set cicle
            for {set ip_count 0} {$ip_count < $max_route_ranges} {incr ip_count} {
                
                set routeRangeCmd ""
                
                switch -- $routeType {
                    normal {
                        #debug "ixNetworkAdd $handle routeRange"
                        #set routeRange [ixNetworkAdd $handle routeRange]
                        lappend routeRangeCmd ixNetworkAdd $handle routeRange
                    }
                    mpls {
                        # debug "ixNetworkAdd $handle mplsRouteRange"
                        # set routeRange [ixNetworkAdd $handle mplsRouteRange]
                        lappend routeRangeCmd ixNetworkAdd $handle mplsRouteRange
                    }
                    vpn {
                        # debug "ixNetworkAdd $vpnParam vpnRouteRange"
                        # set routeRange [ixNetworkAdd $vpnParam vpnRouteRange]
                        lappend routeRangeCmd ixNetworkAdd $vpnParam vpnRouteRange
                    }
                    vpls {
                        # debug "ixNetworkAdd $vplsParam labelBlock"
                        # set routeRange [ixNetworkAdd $vplsParam labelBlock]
                        lappend routeRangeCmd ixNetworkAdd $vplsParam labelBlock
                    }
                }
                lappend routeRangeCmd -enabled true
                if {$routeType != "vpls"} {
                    if {[info exists end_of_rib] && ($end_of_rib == 1)} {
                            # the following line sets -enabled to false. do not move block.
                            lset routeRangeCmd end "false" 
                            set num_routes 1
                            set enable_generate_unique_routes 0
                            lappend routeRangeCmd -enableLocalPref false
                        }
                    
                    set pl_option_flags {}
                    foreach {param cmd} $options_list_flags {
                        if {[info exists $param]} {
                            set param_value [set $param]
                            switch -- $param_value {
                                0 {set param_value false}
                                1 {set param_value true}
                            }
                            # lappend pl_option_flags -$cmd $param_value
                            lappend routeRangeCmd -$cmd $param_value
                        }
                    }
                    
                    # options with values
                    if {[info exists prefix_to] && [info exists prefix_from]} {
                        set thruPrefix [expr $prefix_to - $prefix_from]
                        if {$thruPrefix < 0} {unset prefix_to}
                    }
                    
                    if {[info exists packing_from] && [info exists packing_to]} {
                        set thruPacking [expr $packing_to - $packing_from]
                        if {$thruPacking < 0} {unset packing_to}
                    }
                    
                    foreach {param cmd} $global_list {
                        if {[info exists $param]} {
                            set option_value [set $param]
                            lappend routeRangeCmd -$cmd $option_value
                        }
                    }
                    
                    if {($routeType != "normal") && (![info exists originator_id_enable])} {
                        if {[info exists originator_id]} {
                            lappend routeRangeCmd -enableOriginatorId true -originatorId $originator_id
                        }
                    }
                    
                    if {$routeType == "normal"} {
                        if {[info exists as_path_set_mode]} {
                            lappend routeRangeCmd -asPathSetMode $as_path_set_mode
                        }
                        if {[info exists next_hop_ip_version]} {
                            lappend routeRangeCmd -nextHopIpType $next_hop_ip_version
                        }
                    }
                    
                    # setting aggregator 
                    if {[info exists aggregator]} {
                        if {([regexp -- "(\\d+):(\\d+.\\d+.\\d+.\\d+)" $aggregator all \
                            agg_as agg_ip] == 1) && ([::isIpAddressValid $agg_ip])} {
                                lappend routeRangeCmd -aggregatorAsNum $agg_as -aggregatorIpAddress $agg_ip
                            }
                        
                    }
                    
                    # setting community attributes
                    if {[info exists communities] && $communities != ""} {
                        lappend routeRangeCmd -enableCommunity true
                    }
                    # rd settings
                    if {$routeType == "vpn"} {
                        foreach {param cmd} $vpn_param_list {
                            if {[info exists $param]} {
                                if {$param == "rd_type"} {
                                    if {[llength $rd_type] > 1} {
                                        set rd_type_temp           [lindex $rd_type $vpn_count]
                                    } else {
                                        set rd_type_temp           $rd_type
                                    }
                                    array set rd_type_map {
                                        0   as
                                        1   ip
                                        2   asNumber2
                                    }
                                    lappend routeRangeCmd -$cmd $rd_type_map($rd_type_temp)
                                } elseif {$param == "originator_id_enable"} {
                                    if {[set $param] == 0} {
                                        lappend routeRangeCmd -$cmd false
                                    } else {
                                        lappend routeRangeCmd -$cmd true
                                    }
                                } else {
                                    lappend routeRangeCmd -$cmd [set $param]
                                }
                            }
                        }
                    }
                    set routeRange [eval $routeRangeCmd]
                    
                    # flapping options
                    if {[info exists enable_partial_route_flap]} {
                        set enable_route_flap 1
                    }
                    set pl_flapping {}
                    if {[info exists enable_route_flap]} {
                        lappend pl_flapping -enabled $enable_route_flap
                    }
                    
                    if {[info exists enable_partial_route_flap]} {
                        lappend pl_flapping -enablePartialFlap $enable_partial_route_flap
                    }
                    
                    foreach {param cmd} $flapping_list {
                        if {[info exists $param]} {
                            set flap_value [set $param]
                            lappend pl_flapping -$cmd $flap_value
                        }
                    }
                    if {[llength $pl_flapping] > 0} {
                        ixNetworkSetMultiAttr $routeRange/flapping pl_flapping
                    }
                    
                    # setting community attributes
                    if {[info exists communities]} {
                        if {$communities != ""} {
                            ixNetworkSetAttr $routeRange/community -val $communities
                        }
                    }
                    
                    # setting extended comunity
                    if {[info exists ext_communities]} {
                        set comm_list [split $ext_communities ,]
                        switch -- [lindex $comm_list 0] {
                            2 {set comm_subType routeTarget}
                            3 {set comm_subType origin}
                            4 {set comm_subType extendedBandwidthSubType}
                            default {
                                set comm_subType routeTarget
                            }
                        }
                        switch -- [lindex $comm_list 1] {
                            1 {set comm_type ip}
                            2 {set comm_type fourOctetAs}
                            3 {set comm_type opaque}
                            default {set comm_type twoOctetAs}
                        }
                        
                        regsub -all { } [lindex $comm_list 2] {:} comm_value
                        set comm_item [list [list hex hex $comm_type $comm_subType $comm_value]]
                        ixNetworkSetAttr $routeRange/extendedCommunity -extendedCommunity $comm_item
                    }
                                
                    # as_path set
                    set asPath {}
                    if {$vpn_count == 0 && $ip_count == 0 && ($as_path != "")} {
                        # Ex.: {as_set:1,2,3,4 as_seq:5,6,7,8}
                        foreach asElem $as_path {
                            set asType  ""
                            set asChain ""
                            if {![regexp -- "(as_set|as_seq|as_confed_set|as_confed_seq):(\[\\d+,\]*\\d+)" \
                                        $asElem all asType asChain]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Invalid AS path format."
                                return $returnList
                            }
                            set asChain [split $asChain ,]
                            if {[string equal $asType "as_set"]} {
                                set asType asSet
                            } elseif {[string equal $asType "as_seq"]} {
                                set asType asSequence
                            } elseif {[string equal $asType "as_confed_set"]} {
                                set asType asConfedSet
                            } elseif {[string equal $asType "as_confed_seq"]} {
                                set asType asConfedSequence
                            } else {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Unknown asType $asType."
                                return $returnList
                            }
                            lappend asPath "True $asType [split $asChain ,]"
                        }
                    }
                    
                    ixNetworkSetAttr $routeRange/asSegment -asSegments $asPath
                    
                    if {[info exists cluster_list]} {
                        set val_array {}
                        foreach cluster_item $cluster_list {
                            if {$nr_valid_result} {
                                lappend val_array $cluster_item
                            } else {
                                lappend val_array [::ixia::ip_addr_to_num  $cluster_item]
                            }
                        }
                        ixNetworkSetAttr $routeRange/cluster -val $val_array
                    }
                    
                    # mpls options
                    if {$routeType == "mpls" || $routeType == "vpn"} {
                        if {[info exists label_value] && [info exists label_step] && ![info exists label_value_end]} {
                            set label_value_stop [expr $label_value + $num_routes * $label_step - 1]
                        } elseif {[info exists label_value_end]} {
                            set label_value_stop $label_value_end
                        }
                        set i 0
                        set pl_mpls {}
                        foreach mpls_option $mpls_options_list {
                            if {[info exists $mpls_option]} {
                                set command [lindex $mpls_commands $i]
                                if {$mpls_option == "label_incr_mode"} {
                                    switch -- $label_incr_mode {
                                        fixed {
                                            set value fixedLabel
                                        }
                                        rd {
                                            set value incrementLabel
                                        }
                                        prefix {
                                            set value incrementLabel
                                        }
                                        default {
                                            set value fixedLabel
                                        }
                                    }
                                } else {
                                    set value [set $mpls_option]
                                }
                                lappend pl_mpls -$command $value
                            }
                            incr i
                        }
                        if {[llength $pl_mpls] > 0} {
                            ixNetworkSetMultiAttr $routeRange/labelSpace pl_mpls
                        }
                        if {[info exists label_value]} {
                            set label_value [expr $label_value + $num_routes * $label_step]
                        }
                    }
                    # Increment values
                    if {$ip_version == "ipv4"} {
                        set prefix [ixia::incr_ipv4_addr $prefix $route_ip_addr_step]
                    } elseif {$ip_version == "ipv6"} {
                        set prefix [ixia::incr_ipv6_addr $prefix $route_ip_addr_step]
                    }
                } else {
                    
                    foreach {param cmd} $label_block_map {
                        if {[info exists $param]} {
                            if {[info exists ${param}_type]} {
                                switch -exact -- [set ${param}_type] {
                                    "list" {
                                        set tmp_val [lindex [set $param] $ip_count]
                                        # repeat the last value in list indefinitely
                                        if { $tmp_val == {} } {
                                            set tmp_val [lindex [set $param] end]
                                        }
                                        set option_value $tmp_val
                                    }
                                    "single_value" {
                                        set option_value [set $param]
                                    }
                                }
                            } else {
                                # fallback
                                set option_value [set $param]
                            }
                            if {$param == "label_value" && [info exists label_step] && $label_value_type != "list"} {
                                set option_value [expr [set $param] + $label_step * $ip_count]
                            }
                            lappend routeRangeCmd -$cmd $option_value
                        }
                    }
                    
                    set routeRange [eval $routeRangeCmd]
                }
                
                lappend route_range_list $routeRange
                
                # Commit
                incr objectCount
                if { $objectCount >= $objectMaxCount && ![info exists no_write]} {
                    debug "ixNetworkCommit"
                    ixNetworkCommit
                    set objectCount 0
                }
            }
            # increment VPN params
            if {$routeType == "vpn"} {
                # increment vpn params
                if {[info exists rd_admin_ip] && [info exists rd_admin_step]} {
                    if {![isIpAddressValid $rd_admin_step]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "rd_admin_step should be ip."
                        return $returnList
                    }
                    set rd_admin_ip [ixia::incr_ipv4_addr \
                        $rd_admin_ip $rd_admin_step]
                }
                if {[info exists rd_admin_as] && [info exists rd_admin_step]} {
                    incr rd_admin_as $rd_admin_step
                }
                if {[info exists rd_assign_value] && [info exists rd_assign_step]} {
                    incr rd_assign_value $rd_assign_step
                }
                # target ...
                if {[info exists target_step] && [info exists target_type] && \
                    [info exists target]} {
                    set pos 0
                    foreach type $target_type item $target step $target_step {
                        switch -exact -- [string tolower $type] {
                            as {
                                set value [expr $item + $step]
                            }
                            ip {
                                set value [::ixia::incr_ipv4_addr \
                                    $item $step]
                            }
                        }
                        set target [lreplace $target $pos $pos $value]
                        incr pos
                    }
                }
                if {[info exists target_assign] && \
                    [info exists target_assign_step]} {
                    set pos 0
                    foreach item $target_assign step $target_assign_step {
                        set value [expr $item + $step]
                        set target_assign [lreplace $target_assign $pos $pos $value]
                        incr pos
                    }
                }
                # import_target ...
                if {[info exists import_target_step] && \
                    [info exists import_target_type] && \
                    [info exists import_target]} {
                    set pos 0
                    foreach type $import_target_type item $import_target \
                        step $import_target_step {
                        switch -exact -- [string tolower $type] {
                            as {
                                set value [expr $item + $step]
                            }
                            ip {
                                set value [::ixia::incr_ipv4_addr \
                                    $item $step]
                            }
                        }
                        set import_target [lreplace $import_target $pos $pos $value]
                        incr pos
                    }
                }
                if {[info exists import_target_assign] && \
                    [info exists import_target_assign_step]} {
                    set pos 0
                    foreach item $import_target_assign \
                            step $import_target_assign_step {
                        set value [expr $item + $step]
                        set import_target_assign \
                            [lreplace $import_target_assign $pos $pos $value]
                        incr pos
                    }
                }
                # vpn increment end
            }
            # increment VPLS params
            if {$routeType == "vpls"} {
                if {[info exists site_id] && [info exists site_id_step]} {
                    set site_id [expr $site_id + $site_id_step]
                }
                if {[info exists rd_assign_value] && [info exists rd_assign_step] && [llength $rd_assign_value] == 1} {
                    set rd_assign_value [expr $rd_assign_value + $rd_assign_step]
                }
                if {[info exists target_assign] && [info exists target_assign_step] && [llength $target_assign] == 1} {
                    set target_assign [expr $target_assign + $target_assign_step]
                }
            }
        }
        #end of route range config
        # set variable
        if {$objectCount > 0 && ![info exists no_write]} {
            debug "ixNetworkCommit"
            ixNetworkCommit
        }
        if {$l23SiteParam_list != ""} {
            set l23SiteParam_list    [ixNet remapIds $l23SiteParam_list]
        }
        if {$route_range_list != ""} {
            set route_range_list [ixNet remapIds $route_range_list]
        }
        
        if {$routeType == "vpn" || $routeType == "vpls"} {
            set rIndex 0
            for {set vpn_count 0} {$vpn_count < $num_sites} {incr vpn_count} {
                set vpnParam [lindex $l23SiteParam_list $vpn_count]
                keylset returnList bgp_sites.$vpnParam \
                        [lrange $route_range_list $rIndex [expr $rIndex + $max_route_ranges - 1]]
                
                incr rIndex $max_route_ranges
            }
            keylset returnList bgp_routes $l23SiteParam_list
        } else  {
            keylset returnList bgp_routes $route_range_list
        }
        
        keylset returnList status    $::SUCCESS
        return $returnList
    }
    
    if {$mode == "remove"} {
        if {[info exists handle] && ![info exists route_handle]} {
            set route_handle $handle
        }
        if {![info exists route_handle] && ![info exists l3_site_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode, \
                    parameter -route_handle or -l3_site_handle must be provided."
            return $returnList
        } elseif {[info exists l3_site_handle]} {
            set route_handle $l3_site_handle
        }
        
        foreach route_item $route_handle {
            if {[regexp {bgp/neighborRange:[0-9a-zA-Z]+/routeRange:[0-9a-zA-Z]+$} $route_item] || \
                    [regexp {bgp/neighborRange:[0-9a-zA-Z]+/mplsRouteRange:[0-9a-zA-Z]+$} $route_item] || \
                    [regexp {bgp/neighborRange:[0-9a-zA-Z]+/l3Site:[0-9a-zA-Z]+/vpnRouteRange:[0-9a-zA-Z]+$} $route_item] || \
                    [regexp {bgp/neighborRange:[0-9a-zA-Z]+/l3Site:[0-9a-zA-Z]+$} $route_item] || \
                    [regexp {bgp/neighborRange:[0-9a-zA-Z]+/l2Site:[0-9a-zA-Z]+$} $route_item]} {
                debug "ixNetworkRemove $route_item"
                if {[catch {ixNetworkRemove $route_item}]} {
                    keylset returnList status    $::FAILURE
                    keylset returnList log "Cannot delete handle $route_item."
                    return $returnList
                }
                debug "ixNetworkCommit"
                ixNetworkCommit
            } else {
                keylset returnList status    $::FAILURE
                keylset returnList log "Invalid route/site handle $route_item."
                return $returnList
            }
        }
        keylset returnList bgp_routes $route_handle
        keylset returnList status     $::SUCCESS
        return $returnList
    }
}

proc ::ixia::ixnetwork_bgp_control { args man_args opt_args } {
    variable ixnetwork_port_handles_array

    if {[catch {::ixia::parse_dashed_args \
            -args $args                   \
            -optional_args  $opt_args     \
            -mandatory_args $man_args} parseError]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$parseError."
        return $returnList
    }
    
    if { (![info exists handle]) && ($mode == "link_flap" || \
            $mode == "statistic") } {
        keylset returnList status $::FAILURE
        keylset returnList log "When -mode is $mode,\
                option -handle must be provided."
        return $returnList
    }
    
    if {$mode == "link_flap"} {
        set flappingHandles ""
        foreach handle_item $handle {
            if {[regexp "\[0-9\]+/\[0-9\]+/\[0-9\]+$" $handle_item] && \
                    [info exists ixnetwork_port_handles_array($handle_item)]} {
                set neighborHandles [ixNet getList \
                        $ixnetwork_port_handles_array($handle_item)/protocols/bgp neighborRange]
                set flappingHandles [concat $flappingHandles $neighborHandles]
            } elseif {[regexp "neighborRange:\[0-9a-zA-Z\]+$" $handle_item]} {
                lappend flappingHandles $handle_item
            } elseif {[regexp "l3Site:\[0-9a-zA-Z\]+$" $handle_item]} {
                lappend flappingHandles [::ixia::ixNetworkGetParentObjref $handle_item neighborRange]
            } elseif {[regexp "mplsRouteRange:\[0-9a-zA-Z\]+$" $handle_item] || \
                    [regexp "routeRange:\[0-9a-zA-Z\]+$" $handle_item] || \
                    [regexp "vpnRouteRange:\[0-9a-zA-Z\]+$" $handle_item]} {
                lappend flappingHandles [::ixia::ixNetworkGetParentObjref $handle_item neighborRange]
            }
        }
        foreach flappingHandle $flappingHandles {
            if {[info exists link_flap_up_time]} {
                debug "ixNet setAttr $flappingHandle -linkFlapUpTime $link_flap_up_time"
                if {[set retCode [ixNet setAttr $flappingHandle \
                        -linkFlapUpTime $link_flap_up_time]] != "::ixNet::OK"} {
                    keylset returnList log "Failed to set link_flap_up_time. $retCode"
                    keylset returnList status $::FAILURE
                    return $returnList                
                }
            }
            if {[info exists link_flap_down_time]} {
                debug "ixNet setAttr $flappingHandle/flapping -linkFlapDownTime $link_flap_down_time"
                if {[set retCode [ixNet setAttr $flappingHandle \
                        -linkFlapDownTime $link_flap_down_time]] != "::ixNet::OK"} {
                    keylset returnList log "Failed to set link_flap_down_time. $retCode"
                    keylset returnList status $::FAILURE
                    return $returnList                
                }
            }
            debug "ixNet setAttr $flappingHandle -enableLinkFlap true"
            ixNet setAttr $flappingHandle -enableLinkFlap true
        }
        debug "ixNet commit"
        ixNet commit
        keylset returnList status $::SUCCESS
        return $returnList
    } elseif {$mode == "statistic"} {
        keylset returnList status $::SUCCESS
        return $returnList
    } else {
       return [ixNetworkProtocolControl                                                     \
                "-interfaces_relative_path_from_protocol neighborRange -protocol bgp $args" \
                "-protocol $man_args"                                                       \
                "-interfaces_relative_path_from_protocol $opt_args"                         \
                ]
    }
    
    keylset returnList status    $::SUCCESS
    return $returnList
}

proc ::ixia::ixnetwork_bgp_info { args man_args } {

    if {[catch {::ixia::parse_dashed_args \
            -args           $args         \
            -mandatory_args $man_args} parseError]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$parseError."
        return $returnList
    }
    
    if {[llength $handle] > 1} {
        keylset returnList status    $::FAILURE
        keylset returnList log "Parameter -handle must have only one handle\
                (provided [llength $handle] handles)."
        return $returnList
    }
    
    if {![regexp -- "::ixNet::OBJ-/vport:\\d+/protocols/bgp/neighborRange:\[0-9a-zA-Z\]+" $handle neighbor_handle]} {
        keylset returnList status    $::FAILURE
        keylset returnList log "Invalid neighbor handle specified: -handle $handle."
        return $returnList
    }
    
    if {$mode == "stats" || $mode == "clear_stats"} {
        regexp -- "::ixNet::OBJ-/vport:\\d+" $handle port_handle
        set port_handle  [::ixia::ixNetworkGetRouterPort $port_handle]
        set port_handles $port_handle
    }
    
    regexp {::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:[0-9a-zA-Z]+/l3Site:[0-9a-zA-Z]+} $handle l3_site_handle
    regexp {::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:[0-9a-zA-Z]+/l2Site:[0-9a-zA-Z]+} $handle l2_site_handle
    
    switch -- $mode {
        stats {
            array set stats_array_aggregate {
				"Port Name"
                port_name
                "Sess. Configured"
                sessions_configured
                "Sess. Up"
                sessions_established
                "Messages Tx"
                messages_tx
                "Messages Rx"
                messages_rx
                "Updates Tx"
                update_tx
                "Updates Rx"
                update_rx
                "Routes Advertised"
                routes_advertised
                "Routes Withdrawn"
                routes_withdrawn
                "Routes Rx"
                routes_rx
                "Route Withdraws Rx"
                route_withdraws_rx
                "Opens Tx"
                open_tx
                "Opens Rx"
                open_rx
                "KeepAlives Tx"
                keepalive_tx
                "KeepAlives Rx"
                keepalive_rx
                "Notifications Tx"
                notify_tx
                "Notifications Rx"
                notify_rx
                "Ceases Tx"
                cease_tx
                "Ceases Rx"
                cease_rx
                "State Machine Errors Sent"
                state_machine_error_tx
                "State Machine Errors Received"
                state_machine_error_rx
                "Hold Timer Expireds Sent"
                hold_timer_expired_tx
                "Hold Timer Expireds Received"
                hold_timer_expired_rx
                "Invalid Opens Sent"
                invalid_open_tx
                "Invalid Opens Received"
                invalid_open_rx
                "Unsupported Versions Received"
                unsupported_versions_rx
                "Bad Peer ASes Received"
                bad_peer_as_rx
                "Bad Ids Received"
                bad_id_rx
                "Unsupported Parameters Received"
                unsupported_parameter_rx
                "Authentication Failures Received"
                authentication_failure_rx
                "Non Acceptable Hold Times Rx"
                non_acceptable_hold_time_rx
                "Invalid Open Suberror Unspec"
                invalid_open_suberror_unspec
                "Update Errors Sent"
                update_error_tx
                "Update Errors Received"
                update_error_rx
                "Malformed Attribute List"
                malformed_attribute_list
                "Unrecognized Well Known Attr"
                unrecognized_well_known_attr
                "Missing Well Known Attribute"
                missing_well_known_attribute
                "Attribute Flags Error"
                attribute_flags_error
                "Attribute Length Error"
                attribute_length_error
                "Invalid ORIGIN Attribute"
                invalid_origin_attribute
                "AS Routing Loop"
                as_routing_loop
                "Invalid NEXT_HOP Attribute"
                invalid_next_hop_attribute
                "Optional Attribute Error"
                optional_attribute_error
                "Invalid Network Field"
                invalid_network_field
                "Malformed AS_PATH"
                malformed_as_path
                "Invalid Update Suberror Unspec"
                invalid_update_suberror_unspec
                "Header Errors Sent"
                header_error_tx
                "Header Errors Received"
                header_error_rx
                "Connection Not Synchronized"
                connection_not_synchronized
                "Bad Message Length"
                bad_message_length
                "Bad Message Type"
                bad_message_type
                "Invalid Header Suberror Unspec"
                invalid_header_suberror_unspec
                "Unspecified Error Sent"
                unspecified_error_tx
                "Unspecified Error Received"
                unspecified_error_rx
                "Starts Occurred"
                starts_occurred
                "External Connects Received"
                external_connect_rx
                "External Connects Accepted"
                external_connect_accepted
                "Graceful Restarts Attempted"
                graceful_restart_attempted
                "Graceful Restarts Failed"
                graceful_restart_failed
                "Routes Rx Graceful Restart"
                routes_rx_graceful_restart
                "Idle State Count"
                idle_state
                "Connect State Count"
                connect_state
                "Active State Count"
                active_state
                "OpenSent State Count"
                opentx_state
                "OpenConfirm State Count"
                openconfirm_state
                "Established State Count"
                established_state
            }
            
            set statistic_types {
                aggregate "BGP Aggregated Statistics"
            }
            
            foreach {stat_type stat_name} $statistic_types {
                set stats_array_name stats_array_${stat_type}
                array set stats_array [array get $stats_array_name]
    
                set returned_stats_list [ixNetworkGetStats \
                        $stat_name [array names stats_array]]
                if {[keylget returned_stats_list status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to read\
                            $stat_name from stat view browser.\
                            [keylget returned_stats_list log]"
                    return $returnList
                }
                set found_ports ""
                set row_count [keylget returned_stats_list row_count]
                array set rows_array [keylget returned_stats_list statistics]
                
                for {set i 1} {$i <= $row_count} {incr i} {
                    set row_name $rows_array($i)
                    set match [regexp {(.+)/Card([0-9]{2})/Port([0-9]{2})} \
                            $row_name match_name hostname card_no port_no]
                    if {$match && [catch {set chassis_ip [keylget ::ixia::hosts_to_ips $hostname]} err]} {
                        set chassis_ip $hostname
                    }
                    if {$match && ($match_name == $row_name) && \
                            [info exists chassis_ip] && [info exists card_no] && \
                            [info exists port_no] } {
                        set chassis_no [ixNetworkGetChassisId $chassis_ip]
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to interpret the '$row_name'\
                                row name."
                        return $returnList
                    }
                    regsub {^0} $card_no "" card_no
                    regsub {^0} $port_no "" port_no
                    if {[lsearch $port_handles "$chassis_no/$card_no/$port_no"] != -1} {
                        set port_key $chassis_no/$card_no/$port_no
                        lappend found_ports $port_key
                        foreach stat [array names stats_array] {
                            if {[info exists rows_array($i,$stat)] && \
                                    $rows_array($i,$stat) != ""} {
                                keylset returnList $stats_array($stat) \
                                        $rows_array($i,$stat)
                            } else {
                                keylset returnList $stats_array($stat) "N/A"
                            }
                        }
                    }
                }
                if {[llength [lsort -unique $found_ports]] != \
                        [llength [lsort -unique $port_handles]]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Retrieved statistics only for the\
                            following ports: $found_ports."
                    return $returnList
                }
            }
            
            if {![info exists l2_site_handle]} {
                set simpleRouteRange [ixNet getList $handle routeRange]
                set mplsRouteRange [ixNet getList $handle mplsRouteRange]
            } else {
                set simpleRouteRange {}
                set mplsRouteRange {}
            }
            set vpnRouteRange {}
            if {[info exists l3_site_handle]} {
                set vpnRouteRange [ixNet getList $l3_site_handle vpnRouteRange]
            }
            set numRoutes 0
            set l2LearnedRoutes {}
            if {[info exists l2_site_handle]} {
                for {set refresh 0} {$refresh < 2} {incr refresh} {
                    
                    # refresh linktrace info
                    debug "ixNet exec refreshLearnedInfo $l2_site_handle"
                    if {[catch {ixNet exec refreshLearnedInfo $l2_site_handle} err]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to 'ixNet exec refreshLearnedInfo $l2_site_handle'. $err"
                        return $returnList
                    }
                    
                    # check if info was learnt
                    set retry_count 10
                    for {set iteration 0} {$iteration < $retry_count} {incr iteration} {
                        debug "ixNet getAttribute $l2_site_handle -isLearnedInfoRefreshed"
                        set msg [ixNet getAttribute $l2_site_handle -isLearnedInfoRefreshed]
                        if {$msg == "true"} {
                            break
                        }
                        
                        after 500
                    }
                    
                    if {$iteration >= 15} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Learned L2VPN Routes are not available."
                        return $returnList
                    }

                    set l2LearnedRoutes [ixNet getList $l2_site_handle learnedRoute]
                    
                    # Use a workaround: Refresh info on neighbor range and try again
                    if {$refresh == 0 && [llength $l2LearnedRoutes] == 0} {
                        # Workaround active
                        set tmp_handle [ixNetworkGetParentObjref $l2_site_handle]
                        if {[catch {ixNet exec refreshLearnedInfo $tmp_handle} err]} {
                            debug "Unexpected error in workaround for L2Sites; L2VPN Routes\
                                    not learnt BUG513807: 'ixNet exec refreshLearnedInfo\
                                    $tmp_handle' returned $err"
                        }
                        after 500
                    } else {
                        break
                    }
                }
                
                incr numRoutes [llength $l2LearnedRoutes]
            }
            set routeRange_list [join "$simpleRouteRange $mplsRouteRange $vpnRouteRange"]
            foreach routeRange $routeRange_list {
                incr numRoutes [ixNet getAttr $routeRange -numRoutes]
            }
            keylset returnList num_node_routes $numRoutes
            keylset returnList status $::SUCCESS
            return $returnList
        }
        clear_stats {
            ::ixia::ixNetworkRemoveUserStats $port_handle BGP
            keylset returnList status $::SUCCESS
            return $returnList
        }
        settings {
            debug "ixNet getAttr $neighbor_handle -localIpAddress"
            keylset returnList ip_address [ixNet getAttr $neighbor_handle -localIpAddress]
            debug "ixNet getAttr $neighbor_handle -localAsNumber"
            keylset returnList asn [ixNet getAttr $neighbor_handle -localAsNumber]
            keylset returnList status $::SUCCESS
            return $returnList
        }
        neighbors {
            debug "ixNet getAttr $neighbor_handle -dutIpAddress"
            keylset returnList peers [ixNet getAttr $neighbor_handle -dutIpAddress]
            keylset returnList status $::SUCCESS
            return $returnList
        }
        labels {
            if {![info exists l3_site_handle] && ![info exists l2_site_handle]} {
                debug "ixNet -timeout 5000 exec refreshLearned $neighbor_handle"
                ixNet -timeout 5000 exec refreshLearnedInfo $neighbor_handle
                for {set i 0} {$i < 100} {incr i} {
                    after 100
                    debug "ixNet getAttr $neighbor_handle -isLearnedInfoRefreshed"
                    if {[ixNet getAttr $neighbor_handle -isLearnedInfoRefreshed]} {
                        break;
                    }
                }
                if {$i == 100} {
                    ixPuts "Warning: timeout occured when refresh"
                }
                set capabilities {
                    ipv4Multicast
                    ipv4Unicast
                    ipv4mpls
                    ipv4vpn
                    ipv6Multicast
                    ipv6Unicast
                    ipv6mpls
                    ipv6vpn
                    vpls
                }
                set i 1
                foreach capability $capabilities {
                    debug "ixNet getList $neighbor_handle/learnedInformation $capability"
                    set learned_list [ixNet getList $neighbor_handle/learnedInformation $capability]
                    set capability_type $capability
                    regsub {^ipv[4|6](.*)$} $capability {\1} capability_type
                     regsub {^ipv([4|6])(.*)$} $capability {\1} capability_version
                    foreach learned_item $learned_list {
                        debug "ixNet getAttr $learned_item -maxLabel"
                        set tmp_label [ixNet getAttr $learned_item -maxLabel]
                        if {$tmp_label == -1} {
                            set tmp_label "N/A"
                        }
                        keylset returnList $i.label      $tmp_label
                        debug "ixNet getAttr $learned_item -neighbor"
                        keylset returnList $i.neighbor   [ixNet getAttr $learned_item -neighbor]
                        debug "ixNet getAttr $learned_item -ipPrefix"
                        keylset returnList $i.network    [ixNet getAttr $learned_item -ipPrefix]
                        debug "ixNet getAttr $learned_item -nextHop"
                        keylset returnList $i.next_hop   [ixNet getAttr $learned_item -nextHop]
                        debug "ixNet getAttr $learned_item -prefixLength"
                        keylset returnList $i.prefix_len [ixNet getAttr $learned_item -prefixLength]
                        keylset returnList $i.type [string tolower $capability_type]
                        keylset returnList $i.version ipV$capability_version
                        incr i
                    }
                }
            } elseif {[info exists l2_site_handle]} {
                debug "ixNet -timeout 5000 exec refreshLearnedInfo $l2_site_handle"
                ixNet -timeout 5000 exec refreshLearnedInfo $l2_site_handle
                for {set i 0} {$i < 100} {incr i} {
                    after 100
                    debug "ixNet getAttr $l2_site_handle -isLearnedInfoRefreshed"
                    if {[ixNet getAttr $l2_site_handle -isLearnedInfoRefreshed]} {
                        break;
                    }
                }
                if {$i == 100} {
                    ixPuts "Warning: timeout occured when refresh"
                }
                set l2_learned_list [ixNet getList $l2_site_handle learnedRoute]
                set i 1
                foreach l2_item $l2_learned_list {
                    debug "ixNet getAttr $l2_item -routeDistinguisher"
                    keylset returnList $i.distinguisher [ixNet getAttr $l2_item -routeDistinguisher]
                    debug "ixNet getAttr $l2_item -maxLabel"
                    set tmp_label [ixNet getAttr $l2_item -maxLabel]
                    if {$tmp_label == -1} {
                        set tmp_label "N/A"
                    }
                    keylset returnList $i.label    $tmp_label
                    debug "ixNet getAttr $l2_item -neighbor"
                    keylset returnList $i.neighbor [ixNet getAttr $l2_item -neighbor]
                    debug "ixNet getAttr $l2_item -nextHop"
                    keylset returnList $i.next_hop [ixNet getAttr $l2_item -nextHop]
                    debug "ixNet getAttr $l2_item -prefixLength"
                    keylset returnList $i.prefix_len [ixNet getAttr $l2_item -prefixLength]
                    debug "ixNet getAttr $l2_item -siteId"
                    keylset returnList $i.site_id [ixNet getAttr $l2_item -siteId]
                    debug "ixNet getAttr $l2_item -controlWordEnabled"
                    keylset returnList $i.control_word [ixNet getAttr $l2_item -controlWordEnabled]
                    debug "ixNet getAttr $l2_item -blockOffset"
                    keylset returnList $i.block_offset [ixNet getAttr $l2_item -blockOffset]
                    debug "ixNet getAttr $l2_item -labelBase"
                    keylset returnList $i.label_value [ixNet getAttr $l2_item -labelBase]
                    keylset returnList $i.type vpls
                    incr i
                }
            } else {
                debug "ixNet -timeout 5000 exec refreshLearned $l3_site_handle"
                ixNet -timeout 5000 exec refreshLearned $l3_site_handle
                for {set i 0} {$i < 100} {incr i} {
                    after 100
                    debug "ixNet getAttr $l3_site_handle -isLearnedInfoRefreshed"
                    if {[ixNet getAttr $l3_site_handle -isLearnedInfoRefreshed]} {
                        break;
                    }
                }
                if {$i == 100} {
                    ixPuts "Warning: timeout occured when refresh"
                }
                set vpn_learned_list [ixNet getList $l3_site_handle learnedRoute]
                set i 1
                foreach vpn_item $vpn_learned_list {
                    debug "ixNet getAttr $vpn_item -routeDistinguisher"
                    keylset returnList $i.distinguisher [ixNet getAttr $vpn_item -routeDistinguisher]
                    debug "ixNet getAttr $vpn_item -maxLabel"
                    
                    set tmp_label [ixNet getAttr $vpn_item -maxLabel]
                    if {$tmp_label == -1} {
                        set tmp_label "N/A"
                    }
                    keylset returnList $i.label    $tmp_label
                    
                    debug "ixNet getAttr $vpn_item -neighbor"
                    keylset returnList $i.neighbor [ixNet getAttr $vpn_item -neighbor]
                    debug "ixNet getAttr $vpn_item -ipPrefix"
                    keylset returnList $i.network  [ixNet getAttr $vpn_item -ipPrefix]
                    debug "ixNet getAttr $vpn_item -nextHop"
                    keylset returnList $i.next_hop [ixNet getAttr $vpn_item -nextHop]
                    debug "ixNet getAttr $vpn_item -prefixLength"
                    keylset returnList $i.prefix_len [ixNet getAttr $vpn_item -prefixLength]
                    debug "ixNet getAttr $vpn_item -prefixLength"
                    keylset returnList $i.type mplsVpn
                    keylset returnList $i.version ipV4
                    incr i
                }
            }
            keylset returnList status $::SUCCESS
            return $returnList
        }
    }
}
