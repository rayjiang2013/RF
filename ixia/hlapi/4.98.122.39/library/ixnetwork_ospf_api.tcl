##Library Header
# $Id: $
# Copyright © 2003-2007 by IXIA
# All Rights Reserved.
#
# Name:
#    ixnetwork_ospf_api.tcl
#
# Purpose:
#    A library containing OSPF APIs for test automation
#    with the Ixia chassis. It uses the IxNetwork 5.30 TCL API.
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
#    - ixnetwork_ospf_config
#    - ixnetwork_ospf_topology_route_config
#    - ixnetwork_ospf_control
#    - ixnetwork_ospf_info
#
# Requirements:
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

proc ::ixia::ixnetwork_ospf_config { args man_args opt_args } {
    variable objectMaxCount
    variable ixnetwork_port_handles_array
    
    set objectCount 0

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing.  $parse_error"
        return $returnList
    }

    if {[info exists interface_handle]} {
        set ignored_params [list intf_ip_addr \
                intf_ip_addr_step intf_prefix_length vlan_id vlan_id_mode vlan_id_step \
                vlan_user_priority mac_address_init mac_address_step vlan ]
        set delimiter ", "
        foreach param $ignored_params {
            if {[lsearch $args "-$param"] != -1} {
                puts "WARNING: When interface_handle is provided the L2-3 parameters will be ignored([join $ignored_params $delimiter])."
                break
            }
        }
    }
    
    if {[info exists vlan] && $vlan == 0} {
        catch {unset vlan_id}
    }
    
    if {($mode != "create") && (![info exists handle])} {
        keylset returnList status $::FAILURE
        keylset returnList log "Parameter -handle must be specified if -mode\
                is $mode"
        return $returnList
    }
    
    if {($mode == "create") && (![info exists port_handle])} {
        keylset returnList status $::FAILURE
        keylset returnList log "Parameter -port_handle must be specified if -mode\
                is $mode"
        return $returnList
    }
    
    if {($mode != "create") && [info exists port_handle]} {
        puts "WARNING: Parameter -port_handle was specified, but is ignored for $mode mode when IxNetwork is used."
    }
    
    if {$mode == "enable"} {
        debug "ixNetworkSetAttr $handle -enabled true"
        ixNetworkSetAttr $handle -enabled true
        if {![info exists no_write]} {
            debug "ixNetworkCommit"
            ixNetworkCommit
        }

        keylset returnList handle $handle
    }
    
    if {$mode == "disable"} {
        debug "ixNetworkSetAttr $handle -enabled false"
        ixNetworkSetAttr $handle -enabled false
        if {![info exists no_write]} {
            debug "ixNetworkCommit"
            ixNetworkCommit
        }

        keylset returnList handle $handle
    }
    
    if {$mode == "delete"} {
        debug "ixNetworkRemove $handle"
        ixNetworkRemove $handle
        if {![info exists no_write]} {
            debug "ixNetworkCommit"
            ixNetworkCommit
        }

        keylset returnList handle $handle
    }
    
    array set truth {
        0     false
        1     true
        false 0
        true  1
    }
	array set translate_restart_reason [list         								 \
        unknown         						unknown    							 \
        switch_to_redundant_control_processor   switchToRedundantControlProcessor    \
		software_reload_upgrade 				softwareReloadOrUpgrade				 \
		software_restart 						softwareRestart						 \
    ]		
    
    if {$mode == "create" || $mode == "modify"} {
        if {$session_type == "ospfv2"} {
            # Setting router
            set ospf_router_flag {
                graceful_restart_enable gracefulRestart
                lsa_discard_mode        discardLearnedLsa
            }
            
            set ospf_router_list {}
            
            # Setting intf param lists        
            set ospf_intf_list {
                intf_objref             protocolInterface
                area_id                 areaId
                area_type               linkTypes
                authentication_mode     authenticationMethods
                dead_interval           deadInterval
                hello_interval          helloInterval
                interface_cost          metric
                md5_key                 md5AuthenticationKey
                md5_key_id              md5AuthenticationKeyId
                mtu                     mtu
                neighbor_router_id      neighborRouterId
                network_type            networkType
                option_bits             options
                password                authenticationPassword
                router_priority         priority
                te_admin_group          teAdminGroup
                te_max_bw               teMaxBandwidth
                te_max_resv_bw          teResMaxBandwidth
                te_metric               teMetricLevel
                te_unreserved_bw_prio   teUnreservedBwPriority
                router_abr              eBit
                router_asbr             bBit
                bfd_registration        enableBfdRegistration
                validate_received_mtu   validateReceivedMtuSize
            }
        } else {
            set ospf_router_flag  {
                lsa_discard_mode                    discardLearnedLsa
                enable_support_rfc_5838             enableSupportRfc5838
                graceful_restart_helper_mode_enable enableGracefulRestartHelperMode
                strict_lsa_checking                 enableStrictLsaChecking
                support_reason_sw_restart           enableSupportReasonSwRestart
                support_reason_sw_reload_or_upgrade enableSupportReasonSwReloadOrUpgrade
                support_reason_switch_to_redundant_processor_control enableSupportReasonSwitchToRedundantControlProcessor
                support_reason_unknown              enableSupportReasonUnknown
            }
            set ospf_router_list  {
            }
            set ospf_intf_list {
                area_id                 area
                dead_interval           deadInterval
                hello_interval          helloInterval
                instance_id             instanceId
                network_type            interfaceType
                option_bits             routerOptions
                intf_objref             protocolInterface
                bfd_registration        enableBfdRegistration
                ignore_db_desc_mtu      enableIgnoreDbDescMtu
                interface_cost          linkMetric
            }
        }
        
        # prepare params
        if {[info exists area_id]} {
            set area_id [::ixia::ip_addr_to_num $area_id]
            if {[info exists area_id_step]} {
                set area_id_step [::ixia::ip_addr_to_num $area_id_step]
            } else {
                set area_id_step 0
            }
        }
        if {[info exists authentication_mode]} {
            switch -exact -- $authentication_mode {
                null {set authentication_mode null}
                simple {set authentication_mode password}
                md5 {set authentication_mode md5}
            }
        }
        if {[info exists area_type]} {
            switch -exact -- $area_type {
                external-capable {set area_type transit}
                ppp {set area_type pointToPoint}
                stub {set area_type stub}
            }
        }
        if {[info exists network_type]} {
            if {$session_type == "ospfv2"} {
                switch -exact -- $network_type {
                    broadcast {set network_type broadcast}
                    ptomp {set network_type pointToMultipoint}
                    ptop {set network_type pointToPoint}
                }
            } else {
                if {$network_type == "broadcast"} {
                    set network_type broadcast
                } else {
                    set network_type pointToPoint
                }
            }
        }
        set te_unreserved_bw_prio {}
        for {set i 0} {$i <= 7} {incr i} {
            if {[info exists te_unresv_bw_priority$i]} {
                lappend te_unreserved_bw_prio [set te_unresv_bw_priority$i]
            } else {
                lappend te_unreserved_bw_prio 0
            }
        }
        if {[llength $te_unreserved_bw_prio] == 0} {
            unset te_unreserved_bw_prio
        } else {
            set te_unreserved_bw_prio [list $te_unreserved_bw_prio]
        }
        if {[info exists te_admin_group]} {
            set te_admin_group [list [split $te_admin_group ".:"]]
        }
        if {![info exists option_bits]} {
            set option_bits 2
        } else {
            if {[catch {set _tmp [expr 0x$option_bits]}] == 0} {
                set option_bits $_tmp
            } elseif {[catch {set _tmp [expr $option_bits]}] == 0} {
                set option_bits $_tmp
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid value for option_bits."
                return $returnList
            }
        }
        if {[info exists demand_circuit] && $demand_circuit == 1} {
            set option_bits [expr $option_bits | 32]
        }
        if {![info exists router_id]} {
            if {[info exists intf_ip_addr]} {
                if {[isIpAddressValid $intf_ip_addr]} {
                    set router_id $intf_ip_addr
                } else {
                    set router_id [::ixia::convert_v6_addr_to_v4 $intf_ip_addr]
                }
            } else {
                set router_id "0.0.0.0"
            }
        }
    }

    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
        if {[info exists loopback_ip_addr] && $session_type == "ospfv3"} {
            keylset returnList status $::FAILURE
            keylset returnList log "loopback address is not supported in OSPFv3"
            return $returnList
        }
        # Getting handles
        set retCode [ixia::ixNetworkGetPortFromObj $handle]
        if {[keylget retCode status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "invalid object \
                    specified $handle."
            return $returnList
        }
        set port_handle  [keylget retCode port_handle]
        set vport_objref [keylget retCode vport_objref]
        if {[string equal $port_handle ""]} {
            keylset returnList status $::FAILURE
            keylset returnList log "There is no port_handle specified."
            return $returnList
        }
        
        if {[info exists enable_dr_bdr]} {
            ixNetworkSetAttr $vport_objref/protocols/ospf -enableDrOrBdr $truth($enable_dr_bdr)
        }
        foreach ospf_intf [ixNetworkGetList $handle interface] {
            if {$session_type == "ospfv2"} {
                set connectedToDut [ixNetworkGetAttr $ospf_intf -connectedToDut]
                set linkTypes [ixNetworkGetAttr $ospf_intf -linkTypes]
                if {$connectedToDut} {
                    set ospf_connected $ospf_intf
                    set intf_handle [ixNetworkGetAttr $ospf_intf -protocolInterface]
                }
                if {[string equal $linkTypes "stub"]} {
                    set ospf_unconnected $ospf_intf
                }
            } else {
                set intf_handle [ixNetworkGetAttr $ospf_intf -protocolInterface]
                set ospf_connected $ospf_intf
            }
        }
        # Setting connected interface
        set connected_intf_options {
            atm_encapsulation      atm_encapsulation
            atm_vci                vci
            atm_vpi                vpi
            mac_address            mac_address_init
            mtu                    mtu
            vlan_enabled           vlan
            vlan_id                vlan_id
            vlan_user_priority     vlan_user_priority
        }
        if {$session_type == "ospfv2"} {
            append connected_intf_options {
                ipv4_address           intf_ip_addr
                ipv4_prefix_length     intf_ip_prefix_length
                gateway_address        neighbor_intf_ip_addr                
            }
        } else {
            append connected_intf_options {
                ipv6_address           intf_ip_addr
                ipv6_prefix_length     intf_ip_prefix_length
                ipv6_gateway           neighbor_intf_ip_addr 
            }
        }
        set intf_cmd_modify {}
        foreach {intf_param hlt_param} $connected_intf_options {
            if {[info exists $hlt_param]} {
                append intf_cmd_modify " -$intf_param [set $hlt_param]"
            }
        }
        if {[string length $intf_cmd_modify] > 0} {
            set intf_cmd_modify "::ixia::ixNetworkConnectedIntfCfg \
                    -prot_intf_objref $intf_handle -port_handle $port_handle \
                    $intf_cmd_modify"
            if {[catch {set retCode [eval $intf_cmd_modify]} errorMsg]} {
                keylset returnList status $::FAILURE
                keylset returnList log "$errorMsg"
                return $returnList
            }
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
        }
        # Setting unconnected interface
        if {[info exists loopback_ip_addr]} {
            if {[string length $ospf_unconnected] == 0} {
                set ospf_unconnected [ixNetworkAdd $handle interface]
            }
            ixNetworkSetAttr $ospf_unconnected -interfaceIpAddress $loopback_ip_addr
            ixNetworkSetAttr $ospf_unconnected -interfaceIpMaskAddress \
                    255.255.255.255
            ixNetworkSetAttr $ospf_unconnected -linkTypes stub
        }
        # Setting emulated OSPF parameters
        if {[info exists router_id]} {
            debug "ixNetworkSetAttr $handle -routerId $router_id"
            ixNetworkSetAttr $handle -routerId $router_id
        }
        set intf_config ""
        foreach {param cmd} $ospf_intf_list {
            if {[info exists $param]} {
                append intf_config "ixNetworkSetAttr \$ospf_connected -$cmd \[set $param\]; "
            }
        }
        if {[info exists te_enable] && $session_type == "ospfv2"} {
            append prot_intf_config "ixNetworkSetAttr \$ospf_connected -teEnable $te_enable; "
        }
        debug "[subst $intf_config]"
        eval [subst $intf_config]
        if {![info exists no_write]} {
            debug "ixNetworkCommit"
            ixNetworkCommit
        }

        keylset returnList handle $handle
    }

    if {$mode == "create"} {
        # test ip parameters
        set ip_params_list {intf_ip_addr intf_ip_addr_step intf_prefix_length}
        foreach ip_param $ip_params_list {
            if {[info exists $ip_param]} {
                if {$ip_param == "intf_prefix_length"} {
                    if {$session_type == "ospfv2" && $intf_prefix_length > 32} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Invalid parameter\
                                intf_prefix_length: cannot be bigger than\
                                32 for OSPFv2"
                    }
                } else {
                    if {($session_type == "ospfv3" && \
                            ([::ipv6::isValidAddress [set $ip_param]] == 0)) || \
                            ($session_type == "ospfv2" && \
                            ([isIpAddressValid [set $ip_param]] == 0))} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Invalid parameter value for\
                                ${ip_param}: [set $ip_param] is not allowed\
                                with $session_type"
                        return $returnList
                    }
                }
            }
        }

        # reset action
        if {![info exists ixnetwork_port_handles_array($port_handle)]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Invalid port_handle $port_handle."
            return $returnList
        }
        set port $ixnetwork_port_handles_array($port_handle)
        # Check if protocols are supported
        set retCode [checkProtocols $port]
        if {[keylget retCode status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Port $port_handle does not support protocol\
                    configuration."
            return $returnList
        }
        if {[info exists reset]} {
            if {$session_type == "ospfv2"} {
                foreach ospf_handle [ixNetworkGetList $port/protocols/ospf router] {
                    debug "ixNetworkRemove $ospf_handle"
                    ixNetworkRemove $ospf_handle
                }
            } else {
                foreach ospf_handle [ixNetworkGetList $port/protocols/ospfV3 router] {
                    debug "ixNetworkRemove $ospf_handle"
                    ixNetworkRemove $ospf_handle
                }
            }
            if {![info exists no_write]} {
                ixNetworkCommit
                debug "ixNetworkCommit"
            }
        }
        ## Set default values
        if {$session_type == "ospfv2"} {
            set param_value_list [list                          \
                    intf_prefix_length         24               \
                    intf_ip_addr_step          0.0.1.0          \
                    neighbor_intf_ip_addr_step 0.0.0.0          \
                    ip_version                 4                \
                    vlan_user_priority         0                ]
        } elseif {$session_type == "ospfv3"} {
            set param_value_list [list                          \
                    intf_prefix_length         64               \
                    intf_ip_addr_step          0:0:0:1::0       \
                    neighbor_intf_ip_addr_step 0:0:0:0::0       \
                    ip_version                 6                \
                    vlan_user_priority         0                ]
        }
        foreach {param value} $param_value_list {
            if {![info exists $param]} {
                set $param $value
            }
        }
            
        ##Interfaces
        # Configure the necessary interfaces
        if {[info exists interface_handle]} {
            set tmp_interface_handle ""
            
            foreach single_intf_h $interface_handle {
                if {[llength [split $single_intf_h |]] > 1} {
                    # We're dealing with DHCP ranges interfaces
                    foreach {sm_range intf_idx_group} [split $single_intf_h |] {}
                    
                    # Validate sm_range
                    if {![regexp {^::ixNet::OBJ-/vport:\d+/protocolStack/((ethernet)|(atm)):[^/]+/dhcpEndpoint:[^/]+/range:[^/]+$} $sm_range]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Invalid handle '$single_intf_h' for -interface_handle\
                                parameter. Expected handle returned by emulation_dhcp_group_config procedure."
                        return $returnList
                    } else {
                        set intf_type "DHCP"
                    }
                    
                    foreach single_intf_idx_group [split $intf_idx_group ,] {
                        switch -- [regexp -all {\-} $single_intf_idx_group] {
                            0 {
                                # It's a single index
                                if {![string is integer $single_intf_idx_group] || $single_intf_idx_group <= 0} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Invalid interface index $single_intf_idx_group\
                                            in interface_handle $single_intf_h. Accepted values are numeric\
                                            greater than 0."
                                    return $returnList
                                }
                                
                                lappend tmp_interface_handle "${sm_range}|${single_intf_idx_group}|${intf_type}"
                            }
                            1 {
                                # It's a range of indexes
                                foreach {range_start range_end} [split $single_intf_idx_group -] {}
                                
                                if {!([string is integer $range_start]) || !([string is integer $range_end]) ||\
                                        !($range_start <= $range_end) || !($range_start > 0)} {
                                    
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Invalid interface index range $single_intf_idx_group\
                                            in interface_handle $single_intf_h. Accepted values are numeric\
                                            greater than 0."
                                    return $returnList
                                }
                                
                                for {set i $range_start} {$i <= $range_end} {incr i} {
                                    lappend tmp_interface_handle "${sm_range}|${i}|${intf_type}"
                                }
                            }
                            default {
                                # It's not valid
                                keylset returnList status $::FAILURE
                                keylset returnList log "Invalid interface index range in $single_intf_h."
                                return $returnList
                            }
                        }
                    }
                    
                    catch {unset sm_range}
                    catch {unset intf_idx_group}
                    catch {unset single_intf_idx_group}
                } else {
                    # Validate protocol interface range
                    if {![regexp {^::ixNet::OBJ-/vport:\d+/interface:\d+$} $single_intf_h]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Invalid handle '$single_intf_h' for -interface_handle\
                                parameter. Expected handle returned by interface_config procedure."
                        return $returnList
                    } else {
                        set intf_type "ProtocolIntf"
                    }

                    lappend tmp_interface_handle "${single_intf_h}|dummy|${intf_type}"
                }
            }
            
            set interface_handle $tmp_interface_handle
            
            catch {unset tmp_interface_handle}
        }
        
        if {[info exists interface_handle] && [info exists count] && \
                [llength $interface_handle] != $count} {
            keylset returnList status $::FAILURE
            keylset returnList log "The -interface_handle list doesn't\
                    have the size specified with the -count argument."
            return $returnList
        } elseif {[info exists interface_handle]} {
            set intf_list [list]
            set no_ipv46 false
            foreach intf $interface_handle {
                foreach {intf_actual_handle intf_actual_idx intf_actual_type} [split $intf |] {}
                
                switch -- $intf_actual_type {
                    "ProtocolIntf" {
                        if {$session_type == "ospfv2" && [llength [ixNet getList $intf_actual_handle ipv4]] > 0} {
                            lappend intf_list $intf
                        } elseif {$session_type == "ospfv3" && [llength [ixNet getList $intf_actual_handle ipv6]] > 0} {
                            lappend intf_list $intf
                        } else {
                            # intf_actual_handle is not a typo. We use this list only for logging the error
                            # message so we want it to be a simple list of interface handles
                            lappend no_ipv46_intf_list $intf_actual_handle
                            set no_ipv46 true
                        }
                    }
                    "DHCP" {
                        set ret_code [ixNetworkEvalCmd [list ixNet getA ${intf_actual_handle}/dhcpRange -ipType]]
                        if {[keylget ret_code status] != $::SUCCESS} {
                            return $ret_code
                        }
                        if {$session_type == "ospfv2" && [keylget ret_code ret_val] == "IPv4"} {
                            lappend intf_list $intf
                        } elseif {$session_type == "ospfv3" && [keylget ret_code ret_val] == "IPv6"} {
                            lappend intf_list $intf
                        } else {
                            lappend no_ipv46_intf_list $intf_actual_handle
                            set no_ipv46 true
                        }
                    }
                    default {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Internal error. Unexpected interface handle type.\
                                Known interface handle types are: DHCP and ProtocolIntf."
                        return $returnList
                    }
                }
            }
            if {$no_ipv46} {
                keylset returnList status $::FAILURE
                keylset returnList log "The following interfaces don't have\
                        IPv4/IPv6 addresses configured for session type $session_type: $no_ipv46_intf_list"
                return $returnList
            }
        } else {
            if {$session_type == "ospfv2"} {
                set protocol_intf_options "                                     \
                        -atm_encapsulation          atm_encapsulation           \
                        -atm_vci                    vci                         \
                        -atm_vci_step               vci_step                    \
                        -atm_vpi                    vpi                         \
                        -atm_vpi_step               vpi_step                    \
                        -count                      count                       \
                        -mtu                        mtu                         \
                        -ipv4_address               intf_ip_addr                \
                        -ipv4_address_step          intf_ip_addr_step           \
                        -ipv4_prefix_length         intf_prefix_length          \
                        -gateway_address            neighbor_intf_ip_addr       \
                        -gateway_address_step       neighbor_intf_ip_addr_step  \
                        -mac_address                mac_address_init            \
                        -mac_address_step           mac_address_step            \
                        -override_existence_check   override_existence_check    \
                        -override_tracking          override_tracking           \
                        -port_handle                port_handle                 \
                        -vlan_enabled               vlan                        \
                        -vlan_id                    vlan_id                     \
                        -vlan_id_mode               vlan_id_mode                \
                        -vlan_id_step               vlan_id_step                \
                        -vlan_user_priority         vlan_user_priority          \
                        "
            } else {
                set intf_ip_addr      [::ixia::expand_ipv6_addr $intf_ip_addr]
                set intf_ip_addr_step [::ixia::expand_ipv6_addr $intf_ip_addr_step]
                
                if {[info exists neighbor_intf_ip_addr]} {
                    set neighbor_intf_ip_addr      [::ixia::expand_ipv6_addr $neighbor_intf_ip_addr]
                }
                set neighbor_intf_ip_addr_step [::ixia::expand_ipv6_addr $neighbor_intf_ip_addr_step]
                
                set protocol_intf_options "                                     \
                        -atm_encapsulation          atm_encapsulation           \
                        -atm_vci                    vci                         \
                        -atm_vci_step               vci_step                    \
                        -atm_vpi                    vpi                         \
                        -atm_vpi_step               vpi_step                    \
                        -count                      count                       \
                        -mtu                        mtu                         \
                        -ipv6_address               intf_ip_addr                \
                        -ipv6_address_step          intf_ip_addr_step           \
                        -ipv6_prefix_length         intf_prefix_length          \
                        -ipv6_gateway               neighbor_intf_ip_addr       \
                        -ipv6_gateway_step          neighbor_intf_ip_addr_step  \
                        -mac_address                mac_address_init            \
                        -mac_address_step           mac_address_step            \
                        -override_existence_check   override_existence_check    \
                        -override_tracking          override_tracking           \
                        -port_handle                port_handle                 \
                        -vlan_enabled               vlan                        \
                        -vlan_id                    vlan_id                     \
                        -vlan_id_mode               vlan_id_mode                \
                        -vlan_id_step               vlan_id_step                \
                        -vlan_user_priority         vlan_user_priority          \
                        "
            }

            # Passed in only those options that exists
            set protocol_intf_args ""
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
            
            set tmp_intf_list ""
            foreach intf_item [keylget intf_list connected_interfaces] {
                lappend tmp_intf_list ${intf_item}|dummy|ProtocolIntf
            }
            
            set intf_list $tmp_intf_list
        }

        ## Incrementing parameters steps
        if {![info exists instance_id_step]} {
            set instance_id_step 0
        }
        if {![info exists neighbor_router_id_step]} {
            set neighbor_router_id_step 0.0.0.0
        }
        if {![info exists router_id_step]} {
            set router_id_step 0.0.0.1
        }
        if {![info exists loopback_ip_addr]} {
            set loopback_ip_addr_step 0.0.0.0
        }

        ## Enable protocol
        if {$session_type == "ospfv2"} {
            debug "ixNetworkSetAttr $port/protocols/ospf -enabled true"
            ixNetworkSetAttr $port/protocols/ospf -enabled true
            if {[info exists enable_dr_bdr]} {
                ixNetworkSetAttr $port/protocols/ospf -enableDrOrBdr $truth($enable_dr_bdr)
            }
        } else {
            debug "ixNetworkSetAttr $port/protocols/ospfV3 -enabled true"
            ixNetworkSetAttr $port/protocols/ospfV3 -enabled true
        }

        ## Prepare router
        set router_config ""
        append router_config "ixNetworkSetAttr \$ospfRouter -enabled true "
        foreach {param cmd} $ospf_router_flag {
            if {[info exists $param]} {
                 switch [set $param] {
                    1 {
                        append router_config " -$cmd true "
                    }
                    0 {
                        append router_config " -$cmd false "
                    }
                }
            }
        }
        foreach {hltOpt ixnOpt optType} $ospf_router_list {
            if {[info exists $hltOpt]} {
                switch $optType {
                    translate {
                        append router_config " -$ixnOpt \[set translate_${hltOpt}(\[set $hltOpt\])\] "
                    }
                    default {
                        append router_config " -$ixnOpt \[set $hltOpt\] "
                    }
                }
            }
        }

        ## Placeholder
        set intf_objref I_sense_a_disturbance_in_the_Force

        ## Prepare connected protocol interface
        set prot_intf_config ""
        append prot_intf_config "ixNetworkSetAttr \$ospfIntf -enabled true "
        if {$session_type == "ospfv2"} {
            append prot_intf_config " -connectedToDut true "
        }
        if {[info exists te_enable]} {
            append prot_intf_config " -teEnable $te_enable "
        }
        foreach {param cmd} $ospf_intf_list {
            if {[info exists $param]} {
                append prot_intf_config " -$cmd \[set $param\] "
            }
        }

        ## Prepare unconnected protocol interface
        set prot_loop_config "ixNetworkSetAttr \$ospfIntf "
        append prot_loop_config " -enabled true "
        append prot_loop_config " -interfaceIpAddress \$loopback_ip_addr "
        foreach {param cmd} $ospf_intf_list {
            if {[info exists $param]} {
                append prot_loop_config " -$cmd \[set $param\] "
            }
        }
        append prot_loop_config " -linkTypes stub "

        ## Routers
        set ospf_handle_list {}
        foreach intf_objref $intf_list {
            ## Router
            set prot_intf_config_obj ""
            if {$session_type == "ospfv2"} {
                debug "ixNetworkAdd $port/protocols/ospf router"
                set ospfRouter [ixNetworkAdd $port/protocols/ospf router]
                
                set intf_type_param "interfaceType"
                
            } else {
                debug "ixNetworkAdd $port/protocols/ospfV3 router"
                set ospfRouter [ixNetworkAdd $port/protocols/ospfV3 router]
                
                set intf_type_param "interfaceTypes"
            }
            debug "[subst $router_config]"
            eval [subst $router_config]
            if {[info exists router_id]} {
                debug "ixNetworkSetAttr $ospfRouter -routerId $router_id"
                ixNetworkSetAttr $ospfRouter -routerId $router_id
            }
            lappend ospf_handle_list $ospfRouter

            # Commit
            incr objectCount
            if { $objectCount >= $objectMaxCount && ![info exists no_write]} {
                debug "ixNetworkCommit"
                ixNetworkCommit
                set objectCount 0
            }

            ## Protocol interface(s)
            ## Connected interface
            debug "ixNetworkAdd $ospfRouter interface"
            set ospfIntf [ixNetworkAdd $ospfRouter interface]
            ## Protocol Interface / DHCP interface
            foreach {intf_objref intf_objref_index intf_objref_type} [split $intf_objref |] {}
            set ixn_version [join [lrange [split [ixNet getAttribute [ixNet getRoot]globals -buildNumber] .] 0 1] .]
            switch -- $intf_objref_type {
                "ProtocolIntf" {
                    if {$ixn_version >= 5.50} {
                        append prot_intf_config_obj " -$intf_type_param \"Protocol Interface\" -interfaces $intf_objref "
                    } else {
                        append prot_intf_config_obj " -interfaceId $intf_objref "
                    }
                }
                "DHCP" {
                    if {$ixn_version < 5.50} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Internal error. Unexpected interface handle type.\
                                Interface handle type DHCP is only supported starting with IxNetwork 5.50."
                        return $returnList
                    }
                    append prot_intf_config_obj "-interfaces $intf_objref -$intf_type_param $intf_objref_type -interfaceIndex $intf_objref_index "
                }
                default {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Internal error. Unexpected interface handle type.\
                            Known interface handle types are: DHCP and ProtocolIntf."
                    return $returnList
                }
            }
            set prot_intf_config_obj "$prot_intf_config $prot_intf_config_obj"
            debug "[subst $prot_intf_config_obj]"
            eval [subst $prot_intf_config_obj]
            # Commit
            incr objectCount
            if { $objectCount >= $objectMaxCount && ![info exists no_write]} {
                debug "ixNetworkCommit"
                ixNetworkCommit
                set objectCount 0
            }

            ## Unconnected interface
            if {$session_type == "ospfv2" && $loopback_ip_addr != "0.0.0.0"} {
                debug "ixNetworkAdd $ospfRouter interface"
                set ospfIntf [ixNetworkAdd $ospfRouter interface]
                eval [subst $prot_loop_config]
            }

            # Commit
            incr objectCount
            if { $objectCount >= $objectMaxCount && ![info exists no_write]} {
                debug "ixNetworkCommit"
                ixNetworkCommit
                set objectCount 0
            }

            ## Increment parameters
            if {[info exists router_id]} {
                set router_id [::ixia::incr_ipv4_addr \
                    $router_id $router_id_step]
            }
            if {[info exists area_id]} {
                incr area_id $area_id_step
            }
            if {[info exists instance_id]} {
                incr instance_id $instance_id_step
            }
            if {[info exists neighbor_router_id]} {
                set neighbor_router_id [::ixia::incr_ipv4_addr \
                    $neighbor_router_id $neighbor_router_id_step]
            }
            if {[info exists loopback_ip_addr] && \
                    $loopback_ip_addr != "0.0.0.0"} {
                set loopback_ip_addr [::ixia::incr_ipv4_addr \
                    $loopback_ip_addr $loopback_ip_addr_step]
            }
        }

        ##Done
        if {$objectCount > 0 && ![info exists no_write]} {
            debug "ixNetworkCommit"
            ixNetworkCommit
        }

        if {[llength $ospf_handle_list] > 0} {
            keylset returnList handle [ixNet remapIds $ospf_handle_list]
        }
    }

    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixnetwork_ospf_topology_config { args man_args opt_args } {
    variable objectMaxCount

    set objectCount 0

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing.  $parse_error"
        return $returnList
    }
    
    catch {unset no_write}
    
    
    if {$mode != "delete"} {
        if {![info exists type]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode,\
                    parameter -type must be specified."
            return $returnList
        }
    }
    if {$mode != "create"} {
        if {![info exists elem_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode,\
                    parameter -elem_handle must be specified."
            return $returnList
        }
    } else {
        set net_prefix_step 1
        set mask_width_list {
            grid_prefix_length            grid_prefix_start       grid_prefix_step
            net_prefix_length             net_ip                  tmp_step
            summary_prefix_length         summary_prefix_start    tmp_step
            external_prefix_length        external_prefix_start   tmp_step
        }
        foreach {mask ip step} $mask_width_list {
            if {[info exists $ip]} {
                if {[isIpAddressValid [set $ip]]} {
                    if {![info exists $mask]} {
                        set $mask 24
                    } else {
                        if {[set $mask] > 32} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Mask value should be\
                                    between 0 and 32. The value provided was $mask."
                            return $returnList
                        }
                    }
                    if {![info exists $step]} {
                        set $step 0.0.0.1
                    }
                } else {
                    if {![info exists $mask]} {
                        set $mask 64
                    }
                    if {![info exists $step]} {
                        set $step 0000:0000:0000:0000:0000:0000:0000:0001
                    }
                }
            }
        }
    }
    
    # BUG700371
    if {[regexp -- "router:L\[0-9\]+$" $handle temp_elem_match] == 1} {
        set handle [ixNet remapIds $handle]
        # if the handle still is a temporary one after remapIds, commit changes
        if {[regexp -- "router:L\[0-9\]+$" $handle temp_elem_match] == 1} {
            debug "ixNetworkCommit"
            ixNetworkCommit
            set handle [ixNet remapIds $handle]
        }
    }
    
    if {[regexp -- "^::ixNet::OBJ-/vport:\\d+/protocols/ospfV3/router:\[0-9a-zA-Z\]+" \
            $handle router] == 1} {
        set session_type ospfv3
    } elseif {[regexp -- "^::ixNet::OBJ-/vport:\\d+/protocols/ospf/router:\[0-9a-zA-Z\]+" $handle \
            router] == 1} {
        set session_type ospfv2
    }
    
    
    if {![info exists session_type]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Parameter -session_type must be provided."
        return $returnList
    }
    if {$mode == "delete"} {
        debug "ixNetworkRemove $elem_handle"
        if [catch {ixNetworkRemove $elem_handle} errorMsg] {
            keylset returnList log "Cannot delete specified handle $elem_handle.\
                    $errorMsg"
            keylset returnList status $::FAILURE
            return $returnList
        }
        if {![info exists no_write]} {
            ixNetworkCommit
            debug "ixNetworkCommit"
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    if {([info exists enable_advertise] && $enable_advertise == 1) && \
            (![info exists enable_advertise_loopback] || \
            [is_default_param_value "enable_advertise_loopback" $args])} {
        
        set enable_advertise_loopback 1
    }
    
    if {$mode == "create" || $mode == "modify" || $mode == "enable" || $mode == "disable"} {
        if {$session_type == "ospfv2"} {
            set ospf_intf_list {
                advertiseNetworkRange               bool                enable_advertise                            {{router grid}}
                areaId                              integer             area_id                                     {{router grid network}}
                authenticationMethods               translate           no_mapping                                  no_mapping
                authenticationPassword              string              no_mapping                                  no_mapping
                bBit                                bool                router_asbr                                 {{router grid}}
                connectedToDut                      bool                no_mapping                                  no_mapping
                deadInterval                        integer             dead_interval                               {{router grid network}}
                eBit                                bool                router_abr                                  {{router grid}}
                enableAdvertiseRouterLsaLoopback    bool                enable_advertise_loopback                   {{router grid}}
                enableBfdRegistration               bool                bfd_registration                            {{router grid network}}
                enabled                             bool                no_mapping                                  no_mapping
                entryColumn                         integer             entry_point_column                          {{router grid}}
                entryRow                            integer             entry_point_row                             {{router grid}}
                helloInterval                       integer             hello_interval                              {{router grid network}}
                interfaceIpAddress                  ip                  {interface_ip_address net_ip}               {{router grid} network}
                interfaceIpMaskAddress              ip                  {interface_ip_mask    net_prefix_length}    {{router grid} network}
                linkTypes                           translate           link_type                                   {{router grid network}}
                md5AuthenticationKey                string              no_mapping                                  no_mapping
                md5AuthenticationKeyId              integer             no_mapping                                  no_mapping
                metric                              integer             interface_metric                            {{router grid network}}
                mtu                                 integer             no_mapping                                  no_mapping
                neighborIpAddress                   ip                  no_mapping                                  no_mapping
                neighborRouterId                    ip                  neighbor_router_id                          {{router grid network}}
                networkRangeIp                      ip                  grid_prefix_start                           {{router grid}}
                networkRangeIpByMask                bool                enable_incrementIp_from_mask                {{router grid}}
                networkRangeIpIncrementBy           ip                  grid_prefix_step                            {{router grid}}
                networkRangeIpMask                  integer             grid_prefix_length                          {{router grid}}
                networkRangeLinkType                translate           grid_link_type                              {{router grid}}
                networkRangeRouterId                ip                  {router_id   grid_router_id}                {router grid}
                networkRangeRouterIdIncrementBy     ip                  grid_router_id_step                         {{router grid}}
                networkType                         translate           no_mapping                                  no_mapping
                noOfCols                            integer             {num_columns grid_col}                      {router grid}
                noOfRows                            integer             {num_rows    grid_row}                      {router grid}
                options                             integer             {interface_ip_options net_prefix_options}   {{router grid} network}
                priority                            integer             no_mapping                                  no_mapping
                protocolInterface                   objref              no_mapping                                  no_mapping
                showExternal                        bool                no_mapping                                  no_mapping
                showNssa                            bool                no_mapping                                  no_mapping
                teAdminGroup                        string              no_mapping                                  no_mapping
                teEnable                            bool                {router_te              grid_te}            {router grid}
                networkRangeTeMaxBandwidth          double              link_te_max_bw                              {grid}
                networkRangeTeMetric                integer             link_te_metric                              {grid}
                networkRangeTeResMaxBandwidth       double              link_te_max_resv_bw                         {grid}
                networkRangeTeUnreservedBwPriority  double              link_te_unresv_bw_priority                  {grid}
                networkRangeTeEnable                bool                link_te                                     {grid}
                validateReceivedMtuSize             bool                no_mapping                                  no_mapping
            }
            set var_options_list {
                net_prefix_options
                interface_ip_options
            }
            foreach var_options $var_options_list {
                if {![info exists $var_options]} {
                    set $var_options 2
                }
                if {[catch {set _tmp [expr [set $var_options]]}] == 1} {
                    set _tmp [expr 0x[set $var_options]]
                }
                set $var_options $_tmp
            }
            if {[info exists area_id]} {
                set area_id [::ixia::ip_addr_to_num $area_id]
            }
            if {[info exists net_prefix_length]} {
                set net_prefix_length [::ixia::getNetMaskFromPrefixLen $net_prefix_length]
            }
            
            # same with external except summary_... => external_...
            if {$type == "summary_routes"} {
                set rr_type summary
            }
            if {$type == "ext_routes"} {
                set rr_type external
            }
            if {[info exists rr_type]} {
                set ospf_route_range "  \
                    route_origin                   origin                \
                    ${rr_type}_number_of_prefix    numberOfRoutes        \
                    ${rr_type}_prefix_start        networkNumber         \
                    ${rr_type}_prefix_length       mask                  \
                    ${rr_type}_prefix_metric       metric                \
                "
            }
            
        } else {
            # create ipv6 intf
            set ospf_router_range {
                router_abr                      bBit
                router_asbr                     eBit
                router_id                       rid
                num_rows                        numRows
                num_cols                        numCols
            }
            set ospf_grid_range {
                router_abr                      bBit
                router_asbr                     eBit
                grid_row                        numRows
                grid_col                        numCols
                grid_router_id                  rid
                grid_router_id_step             incrementByRid
                grid_link_type                  linkType
                grid_prefix_start               prefixAddress
                grid_prefix_length              prefixMask
                entry_point_row                 entryRow
                entry_point_column              entryColumn
                entry_point_address             entryAddress
                entry_point_prefix_length       entryMaskLength
                interface_metric                linkMetric
            }
            
            set ospfv3NetworkList  {
                net_ip
                net_prefix_step
                net_prefix_length
                net_prefix_options }

            if {$type == "summary_routes"} {
                set rr_type summary
            }
            if {$type == "ext_routes"} {
                set rr_type external
            }
            if {[info exists rr_type]} { 
                set ospf_route_range "  \
                    route_origin                   type                  \
                    ${rr_type}_number_of_prefix    numberOfRoutes        \
                    ${rr_type}_prefix_start        firstRoute            \
                    ${rr_type}_prefix_length       mask                  \
                    ${rr_type}_prefix_metric       metric                \
                    ${rr_type}_ip_type             ipType                \
                    ${rr_type}_address_family      addressFamily         \
                "
                if {$session_type == "ospfv3" && $type == "summary_routes"} {
                    append ospf_route_range "   \
                            ${rr_type}_prefix_step step                  \
                        "
                }
            
                if {[info exists ${rr_type}_ip_type]} {
                    switch -exact -- [set ${rr_type}_ip_type] {
                        ipv4 {set ${rr_type}_ip_type ipV4}
                        ipv6 {set ${rr_type}_ip_type ipV6}
                    }
                }
            
                if {[info exists ${rr_type}_address_family]} {
                    switch -exact -- [set ${rr_type}_address_family] {
                        unicast   {set ${rr_type}_family unicast}
                        multicast {set ${rr_type}_family multicast}
                    }
                }
            }
        }
        
        # prepare parameters
        if {[info exists network_type]} {
            switch -exact -- $network_type {
                broadcast {set network_type broadcast}
                ptomp     {set network_type pointToMultipoint}
                ptop      {set network_type pointToPoint}
            }
        }
        if {[info exists grid_link_type]} {
            switch -exact -- $grid_link_type {
                broadcast {
                    set grid_link_type broadcast
                }
                ptop_numbered {
                    set grid_link_type pointToPoint
                }
                ptop_unnumbered {
                    set grid_link_type pointToPoint
                }
            }
        }
        if {[info exists link_type]} {
            switch -exact -- $link_type {
                external-capable {set link_type transit}
                ppp              {set link_type pointToPoint}
                stub             {set link_type stub}
            }
        }
        if {$type == "summary_routes"} {
            if {$session_type == "ospfv3"} {
                if {$summary_route_type == "another_area"} {
                    set route_origin anotherArea
                } else {
                    set route_origin sameArea
                }
            } else {
                if {$summary_route_type == "another_area"} {
                    set route_origin area
                } else {
                    set route_origin sameArea
                }
            }
        }
        if {$type == "ext_routes"} {
            if {$external_prefix_type == 2} {
                if {$session_type == "ospfv2"} {
                    set route_origin "externalType2"
                } else {
                    set route_origin "asExternal2"
                }
            } else {
                if {$session_type == "ospfv2"} {
                    set route_origin "externalType1"
                } else {
                    set route_origin "asExternal1"
                }
            }
        }
    }
 
    if {$mode == "create"} {
        if {![info exists count] || ($type != "summary_routes" && $type != "ext_routes")} {
            set count 1
        }
        
        set link_te_unresv_bw_priority [string repeat "0.000000 " 8]
        for {set _i 0} {$_i < 8} {incr _i} {
            if {[info exists link_te_unresv_bw_priority${_i}]} {
                set link_te_unresv_bw_priority [lreplace        \
                        $link_te_unresv_bw_priority ${_i} ${_i} \
                        [set link_te_unresv_bw_priority${_i}]   \
                        ]
            }
        }
        set elem_handle {}
        # read values from router object to be set on topology
        if {$session_type == "ospfv3"} {
            if {$router_id == "0.0.0.0"} {
                set router_id [ixNetworkGetAttr $handle -routerId]
            }
            set con_intf      [lindex [ixNetworkGetList $handle interface] 0]
            set con_prot_intf [ixNetworkGetAttr $con_intf -protocolInterface]
            if {![info exists area_id]} {
                set area_id [ixNetworkGetAttr $con_intf -area]
            }
        } else {
            if {$router_id == "0.0.0.0"} {
                set router_id [ixNetworkGetAttr $router -routerId]
            }
            
            set con_intf ""
            for {set con_intf_idx 1} {$con_intf_idx <= 10} {incr con_intf_idx} {
                if {[ixNet exists ${router}/interface:${con_intf_idx}] == "true"} {
                    set con_intf ${router}/interface:${con_intf_idx}
                    break
                }
            }
            
            if {$con_intf == ""} {
                set con_intf      [lindex [ixNetworkGetList $router interface] 0]
            }            
            set con_prot_intf [ixNetworkGetAttr $con_intf -protocolInterface]
            if {![info exists area_id]} {
                set area_id [ixNetworkGetAttr $con_intf -areaId]
            }
        }
        
        # Loopback interface is only for OSPFv2, OSPFv3 does not allow multiple interfaces  per neighbor
        if {[info exists interface_mode2] && $interface_mode2 == "ospf_and_protocol_interface" && \
            [info exists interface_ip_address] && $interface_ip_address != "0.0.0.0" && $interface_ip_address != "0::0" && $session_type == "ospfv2"} {
            
            set unconnected_intf_options {
                port_handle
                connected_via
                loopback_ipv4_address
                loopback_ipv4_prefix_length
                loopback_ipv6_address
                loopback_ipv6_prefix_length
            }
            set retCode       [ixNetworkGetPortFromObj $con_intf]
            set port_handle   [keylget retCode port_handle]
            set connected_via $con_prot_intf
            
            if {[isIpAddressValid $interface_ip_address]} {
                set loopback_ipv4_address          $interface_ip_address
                set loopback_ipv4_prefix_length    32
            } else {
                set loopback_ipv6_address          $interface_ip_address
                set loopback_ipv6_prefix_length    64
            }
            
            set unconnected_intf_list {}
            foreach {intf_param} $unconnected_intf_options {
                if {[info exists $intf_param]} {
                    append unconnected_intf_list " -$intf_param [set $intf_param]"
                }
            }
            if {[string length $unconnected_intf_list] > 0} {
                set intf_cmd_create "::ixia::ixNetworkUnconnectedIntfCfg $unconnected_intf_list"
                if {[catch {set retCode [eval $intf_cmd_create]} errorMsg]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "$errorMsg"
                    return $returnList
                }
                if {[keylget retCode status] != $::SUCCESS} {
                    return $retCode
                }
            }
        }
        
        # main loop
        for {set i 0} {$i < $count} {incr i} {
            if {($session_type == "ospfv2") && ($type == "router" || $type == "grid")  && \
                    ($interface_mode == "ospf_and_protocol_interface") && \
                    ([info exists enable_advertise] && $enable_advertise == 0) && \
                    ([info exists link_type] && $link_type == "pointToPoint") && \
                    [info exists neighbor_router_id]} {
                set unconnected_intf_options {
                    port_handle
                    connected_via
                    loopback_ipv4_address
                    loopback_ipv4_prefix_length
                    loopback_ipv6_address
                    loopback_ipv6_prefix_length
                }
                set retCode       [ixNetworkGetPortFromObj $con_intf]
                set port_handle   [keylget retCode port_handle]
                set connected_via $con_prot_intf
                
                if {$session_type == "ospfv2"} {
                    set loopback_ipv4_address          $neighbor_router_id
                    set loopback_ipv4_prefix_length    $neighbor_router_prefix_length
                } else {
                    set loopback_ipv6_address          $neighbor_router_id
                    set loopback_ipv6_prefix_length    $neighbor_router_prefix_length
                }
                set unconnected_intf_list {}
                foreach {intf_param} $unconnected_intf_options {
                    if {[info exists $intf_param]} {
                        append unconnected_intf_list " -$intf_param [set $intf_param]"
                    }
                }
                if {[string length $unconnected_intf_list] > 0} {
                    set intf_cmd_create "::ixia::ixNetworkUnconnectedIntfCfg $unconnected_intf_list"
                    if {[catch {set retCode [eval $intf_cmd_create]} errorMsg]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "$errorMsg"
                        return $returnList
                    }
                    if {[keylget retCode status] != $::SUCCESS} {
                        return $retCode
                    }
                }
            }
            if {$type == "router" || $type == "grid" || $type == "network"} {
                if {$session_type == "ospfv3" && $type != "network"} {
                    set intf_hnd [ixNetworkGetList $handle interface]
                    ixNetworkSetAttr $router -disableAutoGenerateLinkLsa   true
                    ixNetworkSetAttr $router -disableAutoGenerateRouterLsa true
                    
                    set net_hnd [ixNetworkAdd $handle networkRange]
                    ixNetworkSetAttr $net_hnd -enableAdvertiseNetworkRange true
                } elseif {$session_type == "ospfv2"} {
                    set intf_hnd [ixNetworkAdd $router interface]
                    ixNetworkSetAttr $intf_hnd -enabled               true
                    ixNetworkSetAttr $intf_hnd -connectedToDut        false
                    ixNetworkSetAttr $intf_hnd -advertiseNetworkRange true
                    
                }
            } else {
                set route_hnd [ixNetworkAdd $router routeRange]
                debug "ixNetworkAdd $router routeRange"
                ixNetworkSetAttr $route_hnd -enabled true
                debug "ixNetworkSetAttr $route_hnd -enabled true"
            }

            switch -exact -- $type {
                router {
                    set entry_point_row     1
                    set entry_point_column  1
                    set num_rows            1
                    set num_columns         1
                    if {$session_type == "ospfv2"} {
                        foreach {p_ixn p_type p_hlt_list p_app_list_of_lists} $ospf_intf_list {
                            foreach p_hlt $p_hlt_list p_app_list $p_app_list_of_lists {
                                if {[lsearch $p_app_list $type] == -1} { continue }
                                if {[info exists $p_hlt]} {
                                    debug "ixNetworkSetAttr $intf_hnd -$p_ixn [set $p_hlt]"
                                    ixNetworkSetAttr $intf_hnd -$p_ixn [set $p_hlt]
                                }
                            }
                        }
                    } else {
                        foreach {param cmd} $ospf_router_range {
                            if {[info exists $param]} {
                                ixNetworkSetAttr $net_hnd -$cmd [set $param]
                                debug "ixNetworkSetAttr $net_hnd -$cmd [set $param]"
                            }
                        }
                    }
                }
                grid {
                    set entry_point_row     [lindex $grid_connect 0]
                    set entry_point_column  [lindex $grid_connect 1]
                    if {$session_type == "ospfv2"} {
                        foreach {p_ixn p_type p_hlt_list p_app_list_of_lists} $ospf_intf_list {
                            foreach p_hlt $p_hlt_list p_app_list $p_app_list_of_lists {
                                if {[lsearch $p_app_list $type] == -1} { continue }
                                if {[info exists $p_hlt]} {
                                    debug "ixNetworkSetAttr $intf_hnd -$p_ixn [set $p_hlt]"
                                    ixNetworkSetAttr $intf_hnd -$p_ixn [set $p_hlt]
                                }
                            }
                        }
                    } else {
                        set enable_incrementIp_from_mask true
                        foreach {param cmd} $ospf_grid_range {
                            if {[info exists $param]} {
                                debug "ixNetworkSetAttr $net_hnd -$cmd [set $param]"
                                ixNetworkSetAttr $net_hnd -$cmd [set $param]
                            }
                        }
                    }
                }
                network {
                    if {[info exists net_prefix_length]} {
                        set ip_mask $net_prefix_length
                    }
                    if {![info exists link_type]} {
                        set link_type transit
                    }
                    if {$session_type == "ospfv2"} {
                        ixNetworkSetAttr $intf_hnd -advertiseNetworkRange false
                        
                        foreach {p_ixn p_type p_hlt_list p_app_list_of_lists} $ospf_intf_list {
                            foreach p_hlt $p_hlt_list p_app_list $p_app_list_of_lists {
                                if {[lsearch $p_app_list $type] == -1} { continue }
                                if {[info exists $p_hlt]} {
                                    ixNetworkSetAttr $intf_hnd -$p_ixn [set $p_hlt]
                                }
                            }
                        }
                    } else {
                        if {![info exists net_ip]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "-net_ip must be provided\
                                    for -mode create and -type network and\
                                    ospf version 3"
                            return $returnList
                        }
                        set userLsaGroup [ixNetworkAdd $handle userLsaGroup]
                        ixNetworkSetAttr $userLsaGroup -enabled true
                        if {[regexp {([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}$} $area_id match]} {
                            set area_id [::ixia::ip_addr_to_num $area_id]
                        }
                        ixNetworkSetAttr $userLsaGroup -areaId $area_id
                        set userLsaLink [ixNetworkAdd $userLsaGroup userLsa]
                        ixNetworkSetAttr $userLsaLink -lsaType link
                        ixNetworkSetAttr $userLsaLink -enabled true
                        if {![info exists no_write]} {
                            ixNetworkCommit
                            set userLsaLink [ixNet remapIds $userLsaLink]
                        }
                        foreach {hlt} $ospfv3NetworkList {
                            lappend link_lsa_list [set $hlt]
                        }
                        ixNetworkSetAttr "$userLsaLink/link" -prefixes\
                                [list $link_lsa_list]
                        ixNetworkSetAttr $userLsaLink -advertisingRouterId $router_id
                        lappend elem_handle $userLsaLink
                    }
                }
                summary_routes {
                    foreach {param cmd} $ospf_route_range {
                        if {[info exists $param]} {
                            
                            set paramVal [set $param]
                            
                            if { "summary_prefix_step" == $param } {
                                if {[isValidIPAddress $paramVal]} {
                                    # Route ranges accept numeric steps only
                                    set paramVal [ip_addr_to_num $paramVal]
                                    
                                    # The numeric step is applied only to the network bytes
                                    # shift the step value by prefix length
                                    
                                    if { [info exists summary_prefix_length] } {
                                        set prefix_shift_by [expr 128 - $summary_prefix_length]
                                    } else {
                                        set prefix_shift_by [expr 128 - 64]
                                    }
                                    
                                    set paramVal [mpexpr $paramVal >> $prefix_shift_by]
                                    
                                    # Maximum step value allowed is 32 bits
                                    if {[mpexpr $paramVal > 4294967295]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "Invalid value for parameter $param.\
                                               The maximum numeric/IP value allowed is 4294967295/[num_to_ip_addr [mpexpr 4294967295 << $prefix_shift_by] 6]"
                                        return $returnList
                                    }
                                }
                            }
                            
                            ixNetworkSetAttr $route_hnd -$cmd $paramVal
                            debug "ixNetworkSetAttr $route_hnd -$cmd $paramVal"
                        }
                    }
                }
                ext_routes {
                    foreach {param cmd} $ospf_route_range {
                        if {[info exists $param]} {
                            ixNetworkSetAttr $route_hnd -$cmd [set $param]
                            debug "ixNetworkSetAttr $route_hnd -$cmd [set $param]"
                        }
                    }
                }
            }
            
            # set result list
            if {[lsearch [list router grid network] $type] >= 0} {
                if {$session_type == "ospfv2"} {
                    lappend elem_handle $intf_hnd
                } elseif {$type != "network"} {
                    lappend elem_handle $net_hnd
                }
            } else {
                lappend elem_handle $route_hnd
            }

            # increment
            if {[info exists external_prefix_start] && \
                [info exists external_prefix_step]} {
                if {[::ipv6::isValidAddress $external_prefix_start] } {
                    if {[::ipv6::isValidAddress $external_prefix_step]} {
                        set external_prefix_start [increment_ipv6_address_hltapi \
                                $external_prefix_start $external_prefix_step]
                    } else {
                        set external_prefix_start [increment_ipv6_address_hltapi \
                                $external_prefix_start [num_to_ip_addr $external_prefix_step 6]]
                    }
                } elseif {[isIpAddressValid $external_prefix_start] } {
                    if {[isIpAddressValid $external_prefix_step]} {
                        set external_prefix_start [increment_ipv4_address_hltapi \
                                $external_prefix_start $external_prefix_step]
                    } else {
                        set external_prefix_start [increment_ipv4_address_hltapi \
                                $external_prefix_start [num_to_ip_addr $external_prefix_step 4]]
                    }
                }
            }
            if {[info exists summary_prefix_start] && \
                    [info exists summary_prefix_step]} {
                if {[::ipv6::isValidAddress $summary_prefix_start]} {
                    if {[::ipv6::isValidAddress $summary_prefix_step]} {
                        set summary_prefix_start [increment_ipv6_address_hltapi \
                                $summary_prefix_start $summary_prefix_step]
                    } else {
                        set summary_prefix_start [increment_ipv6_address_hltapi \
                                $summary_prefix_start [num_to_ip_addr $summary_prefix_step 6]]
                    }
                } elseif {[isIpAddressValid $summary_prefix_start]} {
                    if {[isIpAddressValid $summary_prefix_step]} {
                        set summary_prefix_start [increment_ipv4_address_hltapi \
                                $summary_prefix_start $summary_prefix_step]
                    } else {
                        set summary_prefix_start [increment_ipv4_address_hltapi \
                                $summary_prefix_start [num_to_ip_addr $summary_prefix_step 4]]
                    }
                }
            }
            if {[info exists grid_router_id] && [info exists grid_router_id_step]} {
                set grid_router_id [increment_ipv4_address_hltapi \
                        $grid_router_id $grid_router_id_step]
            }

            incr objectCount
            if { $objectCount >= $objectMaxCount && ![info exists no_write]} {
                debug "ixNetworkCommit"
                ixNetworkCommit
                set objectCount 0
            }
        }
        if {$objectCount > 0 && ![info exists no_write]} {
            debug "ixNetworkCommit"
            ixNetworkCommit
        }
        if {[llength $elem_handle] > 0} {
            keylset returnList elem_handle [ixNet remapIds $elem_handle]
        }
    }
    
    if {$mode == "delete"} {
        if {[lsearch [list router grid network] $type] >= 0} {
            if {$session_type == "ospfv2"} {
                ixNetworkSetAttr $elem_handle -advertiseNetworkRange false
                debug "ixNetworkSetAttr $elem_handle -advertiseNetworkRange false"
            } else {
                ixNetworkRemove $elem_handle
                debug "ixNetworkRemove $elem_handle"
            }
        } else {
            ixNetworkRemove $elem_handle
            debug "ixNetworkRemove $elem_handle"
        }
        if {![info exists no_write]} {
            ixNetworkCommit
            debug "ixNetworkCommit"
        }
    }
    
    if {$mode == "modify" || $mode == "enable" || $mode == "disable"} {
        removeDefaultOptionVars $opt_args $args
        
        if {$mode == "enable" || $mode == "disable"} {
            set ospf_route_range    "enabled enabled"
            set ospf_net_range      "enabled enabled"
            if {$mode == "enable"} {
                set enabled 1
            } else {
                set enabled 0
            }
        }
        foreach handle $elem_handle {
            if {[regexp "^::ixNet::OBJ-/vport:\\d+/protocols/ospf/router:\[0-9a-zA-Z\]+/interface:\[0-9a-zA-Z\]+$" \
                    $handle] == 1} {
                set link_te_unresv_bw_priority [ixNetworkGetAttr $handle -teUnreservedBwPriority]
                for {set _i 0} {$_i < 8} {incr _i} {
                    if {[info exists link_te_unresv_bw_priority${_i}]} {
                        set link_te_unresv_bw_priority [lreplace        \
                                $link_te_unresv_bw_priority ${_i} ${_i} \
                                [set link_te_unresv_bw_priority${_i}]   \
                                ]
                    }
                }
                
                foreach {p_ixn p_type p_hlt_list p_app_list_of_lists} $ospf_intf_list {
                    foreach p_hlt $p_hlt_list p_app_list $p_app_list_of_lists {
                        if {[lsearch $p_app_list $type] == -1} { continue }
                        if {[info exists $p_hlt]} {
                            debug "ixNetworkSetAttr $handle -$p_ixn [set $p_hlt]"
                            ixNetworkSetAttr $handle -$p_ixn [set $p_hlt]
                        }
                    }
                }
            }
            if {[regexp "^::ixNet::OBJ-/vport:\\d+/protocols/ospfV3/router:\[0-9a-zA-Z\]+/networkRange\[0-9a-zA-Z\]+$" \
                    $handle ] == 1} {
                foreach {param cmd} $ospf_net_range {
                    if {[info exists $param]} {
                        debug "ixNetworkSetAttr $elem_handle -$cmd [set $param]"
                        if {[catch {ixNetworkSetAttr $elem_handle -$cmd [set $param]}]} {
                            keylset returnList log "Cannot set $cmd on $elem_handle"
                            keylset returnList status $::FAILURE
                            return $returnList
                        }
                    }
                }
            }
            if {[regexp "^::ixNet::OBJ-/vport:\\d+/protocols/ospfV3/router:\[0-9a-zA-Z\]+/routeRange:\[0-9a-zA-Z\]+$" $handle] ||\
                    [regexp "^::ixNet::OBJ-/vport:\\d+/protocols/ospf/router:\[0-9a-zA-Z\]+/routeRange:\[0-9a-zA-Z\]+$" $handle]} {
                foreach {param cmd} $ospf_route_range {
                    if {[info exists $param]} {
                        debug "ixNetworkSetAttr $elem_handle -$cmd [set $param]"
                        if {[catch {ixNetworkSetAttr $elem_handle -$cmd [set $param]}]} {
                            keylset returnList log "Cannot set $cmd on $elem_handle"
                            keylset returnList status $::FAILURE
                            return $returnList
                        }
                    }
                }
            }
            if {[regexp "^::ixNet::OBJ-/vport:\\d+/protocols/ospfV3/router:\[0-9a-zA-Z\]+/userLsaGroup:\[0-9a-zA-Z\]+/userLsa:\[0-9a-zA-Z\]+$"\
                    $handle]} {
                if [catch {
                    set prefixes [lindex [ixNetworkGetAttr $handle/link -prefixes] 0]
                } errorMsg] {
                    keylset returnList status $::FAILURE
                    keylset returnList log $errorMsg
                    return $returnList
                }
                set pos 0
                foreach {hlt_param} $ospfv3NetworkList {
                    if {[info exists $hlt_param]} {
                        lset prefixes $pos [set $hlt_param]
                    }
                    incr pos
                }
                if [catch {
                    set prefixes [ixNetworkSetAttr $handle/link -prefixes [list $prefixes]]
                } errorMsg] {
                    keylset returnList status $::FAILURE
                    keylset returnList log $errorMsg
                    return $returnList
                }
            }
            incr objectCount
            if { $objectCount >= $objectMaxCount && ![info exists no_write]} {
                debug "ixNetworkCommit"
                ixNetworkCommit
                set objectCount 0
            }
        }
        if {$objectCount > 0 && ![info exists no_write]} {
            ixNetworkCommit
            debug "ixNetworkCommit"
        }
    }

    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixnetwork_ospf_control { args man_args opt_args } {
    variable ixnetwork_port_handles_array
    
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing.  $parse_error"
        return $returnList
    }

    keylset returnList status $::SUCCESS
    
    set objref_list {}

    if {[info exists port_handle]} {
        if {[catch {
            foreach port $port_handle {
                if {![info exists ixnetwork_port_handles_array($port)]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid port in port_handle $port."
                    return $returnList
                }
                set port_objref $ixnetwork_port_handles_array($port)
                if {[ixNet getAttr $port_objref/protocols/ospf -enabled] == false && \
                        [ixNet getAttr $port_objref/protocols/ospfV3 -enabled] == false} {
                    continue
                }
                if {[ixNet getAttr $port_objref/protocols/ospf -enabled] == true} {
                    lappend objref_list $port_objref/protocols/ospf
                } 
                if {[ixNet getAttr $port_objref/protocols/ospfV3 -enabled] == true} {
                    lappend objref_list $port_objref/protocols/ospfV3
                }
            }
        } errorMsg] == 1} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to get the OSPF protocol\
                    object reference out of the handle received as input:\
                    $handle"
            return $returnList
        }
    } elseif {[info exists handle]} {
        foreach handle_item $handle {
            if {[regexp -- {::ixNet::OBJ-/vport:\d+/protocols/ospfV3} $handle_item ospf_handle] == 1} {
                lappend objref_list $ospf_handle
            } elseif {[regexp -- {::ixNet::OBJ-/vport:\d+/protocols/ospf} $handle_item ospf_handle] == 1} {
                lappend objref_list $ospf_handle
            }
        }
    }
    
    set objref_list [lsort -unique $objref_list]
    after 1000
    # Check link state
    foreach ospf_item $objref_list {
        if {[regexp -- "::ixNet::OBJ-/vport:\\d+" $ospf_item port] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to get the OSPF protocol\
                    object reference out of the handle received as input:\
                    $handle"
            return $returnList
        }
        set retries 60
        set portState  [ixNet getAttribute $port -state]
        set portStateD [ixNet getAttribute $port -stateDetail]
        while {($retries > 0) && (($portStateD != "idle") || ($portState  == "busy"))} {
            debug "Port state: $portState, $portStateD ..."
            after 1000
            set portState  [ixNet getAttribute $port -state]
            set portStateD [ixNet getAttribute $port -stateDetail]
            incr retries -1
        }
        debug "Port state: $portState, $portStateD ..."
        if {($portStateD != "idle") || ($portState == "busy")} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to start OSPF.\
                    Port state is $portState, $portStateD."
            return $returnList
        }
        
        # Retry 5 time to start the protocol
        keylset ret_code status $::SUCCESS
        for {set i 0} {$i < 5} {incr i} {
            switch -exact $mode {
                restart {
                    set ret_code [ixNetworkEvalCmd [list ixNet exec stop $ospf_item] "ok"]
                    debug "ixNet exec stop $ospf_item"
                    if {[keylget ret_code status] != $::SUCCESS} {
                        after 5000
                        continue
                    }
                    
                    while {[ixNet getAttr $ospf_item -runningState] != "stopped"} {
                        after 100
                    }
                    
                    set ret_code [ixNetworkEvalCmd [list ixNetworkExec [list start $ospf_item]] "ok"]
                    debug "ixNetworkExec [list start $ospf_item]"
                    if {[keylget ret_code status] != $::SUCCESS} {
                        after 5000
                        continue
                    }
                    break
                }
                start {
                    set ret_code [ixNetworkEvalCmd [list ixNetworkExec [list start $ospf_item]] "ok"]
                    debug "ixNetworkExec [list start $ospf_item]"
                    if {[keylget ret_code status] != $::SUCCESS} {
                        after 5000
                        continue
                    }
                    break
                }
                stop {
                    set ret_code [ixNetworkEvalCmd [list ixNet exec stop $ospf_item] "ok"]
                    debug "ixNet exec stop $ospf_item"
                    if {[keylget ret_code status] != $::SUCCESS} {
                        after 5000
                        continue
                    }
                    break
                }
                default {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unknown choice for -mode parameter.\
                            Please use 'start', 'stop' or 'restart'."
                    return $returnList
                }
            }
        }
        
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
    }
    
    keylset returnList status $::SUCCESS

    return $returnList
}


proc ::ixia::ixnetwork_ospf_lsa_config { args man_args opt_args} {
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing.  $parse_error"
        return $returnList
    }
    
    catch {unset no_write}
    
    if {[regexp -- "^::ixNet::OBJ-/vport:\\d+/protocols/ospfV3/router:\[0-9a-zA-Z\]+$" \
            $handle router] == 1} {
        set session_type ospfv3
    } elseif {[regexp -- "^::ixNet::OBJ-/vport:\\d+/protocols/ospf/router:\[0-9a-zA-Z\]+$" \
            $handle router] == 1} {
        set session_type ospfv2
    }
    if {(![info exists session_type]) || (![info exists router]) || \
            ([ixNet exists $router] == "false" || [ixNet exists $router] == 0)} {
        keylset retrunList status $::FAILURE
        keylset returnList log "Invalid handle specified."
        return $returnList
    }
    
    if {$mode == "reset"} {
        if {[catch {
            foreach group_item [ixNetworkGetList $handle userLsaGroup] {
                foreach userLsa_item [ixNetworkGetList $group_item userLsa] {
                    debug "ixNetworkRemove $userLsa_item"
                    ixNetworkRemove $userLsa_item
                }
            }
        } errorMsg] == 1} {
            keylset returnList log $errorMsg
            keylset returnList status $::FAILURE
            return $returnList
        }
        if {![info exists no_write]} {
            debug "ixNetworkCommit"
            ixNetworkCommit
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }

    # Check if the call is for modify or delete
    if {$mode == "modify" || $mode == "delete"} {
        if {![info exists lsa_handle]} {
            keylset returnList log "When -mode is\
                  $mode, the -lsa_handle option must be used.  Please set\
                  this value."
            keylset returnList status $::FAILURE
            return $returnList
        } elseif {[llength $lsa_handle] > 1} {
            keylset returnList log "When -mode is\
                    $mode, -lsa_handle may only contain one value. \
                    Current: $handle"
            keylset returnList status $::FAILURE
            return $returnList
        }
    }

    if {$mode == "delete"} {
        if [catch {
            debug "ixNetworkRemove $lsa_handle"
            ixNetworkRemove $lsa_handle
            if {![info exists no_write]} {
                debug "ixNetworkCommit"
                ixNetworkCommit
            }
        }] {
            keylset returnList status $::FAILURE
            keylset returnList log "Cannot delete specified handle"
            return $returnList
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Parameter -handle must be specified in\
                    modify mode."
            return $returnList
        }
        if {[regexp "^::ixNet::OBJ-/vport:\\d+/protocols/ospfV3/router:\[0-9a-zA-Z\]+" $handle]} {
            set session_type ospfv3
        } elseif {[regexp "^::ixNet::OBJ-/vport:\\d+/protocols/ospf/router:\[0-9a-zA-Z\]+" $handle]} {
            set session_type ospfv2
        }
        set lsa_group_mode append
    }
    
    if {$session_type == "ospfv2"} {
    
        set ospfv2ArrayList {
            userLsaTypeArray
            userLSAList
            externalList
            summaryIpList
            routerList
            networkList
            linkTypeList
            router_opaqueList
            link_opaqueList
            nssaList
        }

        array set userLsaTypeArray {
            router             router
            network            network
            summary_pool       areaSummary
            asbr_summary       externalSummary
            ext_pool           external
            nssa_ext_pool      nssa
            opaque_type_9      opaqueLocalScope
            opaque_type_10     opaqueAreaScope
            opaque_type_11     opaqueAsScope
        }
        
        set flagList {
            ospfOptionBitTypeOfService      0x01
            ospfOptionBitExternalRouting    0x02
            ospfOptionBitMulticast          0x04
            ospfOptionBitNSSACapability     0x08
            ospfOptionBitExternalAttributes 0x10
            ospfOptionBitDemandCircuit      0x20
            ospfOptionBitLsaNoForward       0x40
        }                

        set userLSAList {
            adv_router_id                   advertisingRouterId
            link_state_id                   linkStateId
            ospfOptionBitTypeOfService      optBitTypeOfService
            ospfOptionBitExternalRouting    optBitExternalRouting
            ospfOptionBitMulticast          optBitMulticast
            ospfOptionBitNSSACapability     optBitNssaCapability
            ospfOptionBitExternalAttributes optBitExternalAttributes
            ospfOptionBitDemandCircuit      optBitDemandCircuit
            ospfOptionBitLsaNoForward       optBitLsaNoForward
            options                         option
        }

        set externalList {
            external_number_of_prefix       numberOfLsa             value
            external_prefix_length          networkMask             value
            external_prefix_step            incrementLinkStateIdBy  value
            external_prefix_metric          metric                  value
            external_prefix_forward_addr    forwardingAddress       value
            external_route_tag              routeTag                value
            external_metric_ebit            eBit                    value
        }
        
        if {[info exists external_prefix_start] && ![info exists link_state_id]} {
            set link_state_id external_prefix_start
        }

        set summaryIpList {
            summary_number_of_prefix        numberOfLsa             value
            summary_prefix_length           networkMask             value
            summary_prefix_step             incrementLinkStateIdBy  value
            summary_prefix_metric           metric                  value
        }
        
        if {[info exists summary_prefix_start] && ![info exists link_state_id]} {
            set link_state_id summary_prefix_start
        }
        set routerList {
            router_abr                  bBit        flag
            router_asbr                 eBit        flag
            router_virtual_link_endpt   vBit        flag
            intf_list                   interfaces  value
        }
        
        set networkList {
            attached_router_id_list          neighborRouterIds value
            net_prefix_length                networkMask       value
        }

        set link_opaqueList {
            opaque_enable_link_id                   enableLinkId                bool
            opaque_enable_link_metric               enableLinkMetric            bool
            opaque_enable_link_resource_class       enableLinkResourceClass     bool
            opaque_enable_link_type                 enableLinkType              bool
            opaque_enable_link_local_ip_addr        enableLocalIpAddress        bool
            opaque_enable_link_max_bw               enableMaxBandwidth          bool
            opaque_enable_link_max_resv_bw          enableMaxResBandwidth       bool
            opaque_enable_link_remote_ip_addr       enableRemoteIpAddress       bool
            opaque_enable_link_unresv_bw            enableUnreservedBandwidth   bool
            opaque_link_id                          linkId                      value
            opaque_link_local_ip_addr               linkLocalIpAddress          value
            opaque_link_metric                      linkMetric                  value
            opaque_link_remote_ip_addr              linkRemoteIpAddress         value
            opaque_link_resource_class              linkResourceClass           value
            opaque_link_type                        linkType                    translate
            opaque_link_unresv_bw_priority          linkUnreservedBandwidth     value
            opaque_link_max_bw                      maxBandwidth                value
            opaque_link_max_resv_bw                 maxResBandwidth             value
            opaque_link_other_subtlvs               subTlvs                     value
            opaque_link_subtlvs                     subTlvs                     value
        }
        set router_opaqueList {
            opaque_router_addr                      routerAddress               value
        }
        

        set linkTypeList {
            ptop                        pointToPoint
            transit                     transit
            stub                        stub
            virtual                     virtual
        }
        
        if {[info exists options]} {
            foreach {varName value} $flagList {
                if {[expr $options & $value] != 0} {
                    set $varName true
                } else {
                    set $varName false
                }
            }
        }
        
        array set lsaRouterIfcTypeArray {
            pointToPoint        ptop
            transit             transit
            stub                stub
            virtual             virtual
        }

    } elseif {$session_type == "ospfv3"} {
    
        set ospfv3ArrayList [list               \
                ospfV3CommonList                \
                ospfV3LsaRouterList             \
                ospfV3LsaNetworkList            \
                ospfV3LsaAsExternalList         \
                ospfV3LsaInterAreaPrefixList    \
                ospfV3LsaInterAreaRouterList    \
                lsaRouterIfcTypeArray           \
                ]

        array set userLsaTypeArray [list              \
                router                router          \
                network               network         \
                summary_pool          interAreaPrefix \
                asbr_summary          interAreaRouter \
                ext_pool              asExternal      \
                ]
                
        if {[info exists options]} {
            set extbit_nu [expr $options & 0x01]
            set extbit_la [expr $options & 0x02]
            set extbit_mc [expr $options & 0x04]
            set extbit_p  [expr $options & 0x08]
        }
        
        set ospfV3CommonList [list \
                adv_router_id               advertisingRouterId \
                link_state_id               linkStateId \
        ]

        # This option have default value 0. Else case is on modify mode. 
        if {[info exists options]} {
            set rbit_v6 [expr $options & 0x01]
            set rbit_e  [expr $options & 0x02]
            set rbit_mc [expr $options & 0x04]
            set rbit_n  [expr $options & 0x08]
            set rbit_r  [expr $options & 0x10]
            set rbit_dc [expr $options & 0x20]
        }

        set ospfV3LsaRouterList [list                     \
                router_wildcard          wBit       flag  \
                router_asbr              bBit       flag  \
                router_abr               eBit       flag  \
                router_virtual_link_endpt vBit      flag  \
                rbit_v6                  optBitV6   flag  \
                rbit_e                   optBitE    flag  \
                rbit_mc                  optBitMc   flag  \
                rbit_n                   optBitN    flag  \
                rbit_r                   optBitR    flag  \
                rbit_dc                  optBitDc   flag  \
                intf_list                interfaces value \
                options                  option     value \
                ]
        
        set ospfV3LsaNetworkList [list             \
                attached_routers_list attachedRouters    value \
                options               option             value \
                ]
                
        set ospfV3LsaAsExternalList [list \
                external_number_of_prefix       lsaCount              value \
                external_prefix_start           addPrefix             value \
                external_prefix_length          addPrefixLength       value \
                prefix_options                  addPrefixOption       value \
                external_prefix_metric          metric                value \
                external_prefix_forward_addr    forwardingAddress     value \
                external_route_tag              externalRouteTag      value \
                external_metric_fbit            fBit                  flag \
                external_metric_tbit            tBit                  flag \
                external_metric_ebit            eBit                  flag \
                extbit_nu                       optBitNu              flag \
                extbit_la                       optBitLa              flag \
                extbit_mc                       optBitMc              flag \
                extbit_p                        optBitP               flag \
                ]

        set ospfV3LsaInterAreaPrefixList [list \
                link_state_id_step          incrLinkStateId           value \
                summary_number_of_prefix    lsaCount                  value \
                prefix_options              option                    value \
                summary_prefix_metric       metric                    value \
                summary_prefix_length       addPrefixLength           value \
                summary_prefix_start        addressPrefix             value \
                summary_prefix_step         prefixAddressIncrementBy  value ]

        set ospfV3LsaInterAreaRouterList [list \
                link_state_id_step          incrLinkStateId           value \
                summary_number_of_prefix    lsaCount                  value \
                summary_prefix_step         routerIdIncrementBy       value \
                summary_prefix_start        routerId                  value \
                summary_prefix_metric       metric                    value \
                options                     option                    value \
                ]
        
        array set lsaRouterIfcTypeArray [list  \
                pointToPoint        ptop       \
                transit             transit    \
                stub                stub       \
                virtual             virtual    \
                ]
    }
        
    # check to see if there is already created L1 userLSAGroup
    set userLSAGroupList [ixNetworkGetList $handle userLsaGroup]
    if {$lsa_group_mode == "append" && [llength $userLSAGroupList] > 0} {
        set lsaGroup_hnd [lindex $userLSAGroupList end]
    } else {
        # adding the new userLSAGroup (1)
        debug "ixNetworkAdd $handle userLsaGroup"
        set lsaGroup_hnd [ixNetworkAdd $handle userLsaGroup]
        
        debug "ixNetworkSetAttr $lsaGroup_hnd -enabled true"
        ixNetworkSetAttr $lsaGroup_hnd -enabled true
        
        # we don't have any param in HLT yet to set area ID
        debug "ixNetworkSetAttr $lsaGroup_hnd -areaId [::ixia::ip_addr_to_num $area_id]"
        ixNetworkSetAttr $lsaGroup_hnd -areaId [::ixia::ip_addr_to_num $area_id]
        
        regexp {([0-9a-zA-Z]+)$} $lsaGroup_hnd {} description
        debug "ixNetworkSetAttr $lsaGroup_hnd -description \"Group$description\""
        ixNetworkSetAttr $lsaGroup_hnd -description "Group$description"
        
        if {![info exists no_write]} {
            debug "ixNetworkCommit"
            ixNetworkCommit
        
            debug "ixNet remapIds $lsaGroup_hnd"
            set lsaGroup_hnd [ixNet remapIds $lsaGroup_hnd]
        }
    }

    if {$mode == "create"} {
        # adding the userLSA
        debug "ixNetworkAdd $lsaGroup_hnd userLsa"
        set lsa_hnd [ixNetworkAdd $lsaGroup_hnd userLsa]
        
        debug "ixNetworkSetAttr $lsa_hnd -enabled true"
        ixNetworkSetAttr $lsa_hnd -enabled true
        
        debug "ixNetworkSetAttr $lsa_hnd -lsaType $userLsaTypeArray($type)"
        ixNetworkSetAttr $lsa_hnd -lsaType $userLsaTypeArray($type)
        
        if {![info exists no_write]} {
            debug "ixNetworkCommit"
            ixNetworkCommit
            
            debug "ixNet remapIds $lsa_hnd"
            set lsa_hnd [ixNet remapIds $lsa_hnd]
        }
        
        set refVarList {
            attached_router_id
            net_attached_router
            net_prefix_length
            external_prefix_length
            external_prefix_step
            external_prefix_type
            opaque_tlv_type
            router_link_data 
            router_link_id 
            router_link_metric
            router_link_mode
            router_link_mode_is_default
            router_link_type
            router_opaqueList
            summary_prefix_length 
        }
        
        set router_link_mode_is_default [is_default_param_value router_link_mode $args]
        
        if {![info exists no_write]} {
            if {$session_type == "ospfv2"} {
                set returnList [ixnetwork_configureOspfv2UserLsaParams $lsa_hnd \
                        $ospfv2ArrayList $refVarList $type -commit]
            } else {
                set returnList [ixnetwork_configureOspfv3UserLsaParams $lsa_hnd \
                        $ospfv3ArrayList $refVarList $type -commit]
            }
        } else {
            if {$session_type == "ospfv2"} {
                set returnList [ixnetwork_configureOspfv2UserLsaParams $lsa_hnd \
                        $ospfv2ArrayList $refVarList $type]
            } else {
                set returnList [ixnetwork_configureOspfv3UserLsaParams $lsa_hnd \
                        $ospfv3ArrayList $refVarList $type]
            }
        }
        if {[keylget returnList status] == $::FAILURE} {
            return $returnList
        }
              
    } elseif {$mode == "modify"} {
        # get userLsa type
        set type [ixNetworkGetAttr $lsa_handle -lsaType]
        foreach {hlt_param ixn_param} [array get userLsaTypeArray] {
            if {[string equal $ixn_param $type]} {
                set type $hlt_param
                break
            }
        }
        set userLSAList_hnd [ixNetworkGetList $lsaGroup_hnd userLsa]
        if {[lsearch $userLSAList_hnd $lsa_handle] >= 0} {
            set lsa_hnd $lsa_handle
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "The userLSA with this handle does\
                    not exist."
            return $returnList
        }
        debug "ixNetworkSetAttr $lsa_hnd -enabled true"
        ixNetworkSetAttr $lsa_hnd -enabled true
        
        set refVarList {
            attached_router_id
            net_attached_router
            net_prefix_length
            external_prefix_length
            external_prefix_step
            external_prefix_type
            opaque_tlv_type
            router_link_data 
            router_link_id 
            router_link_metric
            router_link_mode
            router_link_mode_is_default
            router_link_type
            router_opaqueList
            summary_prefix_length 
        }
        
        set router_link_mode_is_default [is_default_param_value router_link_mode $args]
        
        if {![info exists no_write]} {
            if {$session_type == "ospfv2"} {
                set returnList [ixnetwork_configureOspfv2UserLsaParams $lsa_hnd \
                        $ospfv2ArrayList $refVarList $type -commit]
            } else {
                set returnList [ixnetwork_configureOspfv3UserLsaParams $lsa_hnd \
                        $ospfv3ArrayList $refVarList $type -commit]
            }
        } else {
            if {$session_type == "ospfv2"} {
                set returnList [ixnetwork_configureOspfv2UserLsaParams $lsa_hnd \
                        $ospfv2ArrayList $refVarList $type]
            } else {
                set returnList [ixnetwork_configureOspfv3UserLsaParams $lsa_hnd \
                        $ospfv3ArrayList $refVarList $type]
            }
        }
        if {[keylget returnList status] == $::FAILURE} {
            return $returnList
        }
    }
    
    ###########     Constructing the return list ###########
    if {![info exists adv_router_id]} {
        set adv_router_id [ixNetworkGetAttr $lsa_hnd -advertisingRouterId]
    }

    if {$session_type == "ospfv2"} {
        switch $type {
            router {
                set ifc 0
                set interfacesList [ixNetworkGetAttr $lsa_hnd/router -interfaces]
                foreach item $interfacesList {
                    keylset returnList router.links.$ifc.id   \
                            [lindex $item 0]
                    keylset returnList router.links.$ifc.data \
                            [lindex $item 2]
                    set typeIndex [lindex $item 2]
                    set typeString $lsaRouterIfcTypeArray($typeIndex)
                    keylset returnList router.links.$ifc.type $typeString
                    incr ifc
                }
            }
            network {
                keylset returnList network.attached_router_ids \
                        [ixNetworkGetAttr $lsa_hnd/network -neighborRouterIds]
            }
            asbr_summary {
                keylset returnList summary.prefix_start\
                        [ixNetworkGetAttr $lsa_hnd -linkStateId]
            }
            summary_pool {
                keylset returnList summary.num_prefix  \
                        [ixNetworkGetAttr $lsa_hnd/summaryIp -numberOfLsa]
                keylset returnList summary.prefix_start\
                        [ixNetworkGetAttr $lsa_hnd -linkStateId]
                keylset returnList summary.prefix_length \
                        [getIpV4MaskWidth [ixNetworkGetAttr $lsa_hnd/summaryIp -networkMask]]
                keylset returnList summary.prefix_step \
                        [ixNetworkGetAttr $lsa_hnd/summaryIp -incrementLinkStateIdBy]
            }
            ext_pool {

                keylset returnList external.num_prefix    \
                        [ixNetworkGetAttr $lsa_hnd/external -numberOfLsa]
                keylset returnList external.prefix_start  \
                        [ixNetworkGetAttr $lsa_hnd -linkStateId]
                keylset returnList external.prefix_length \
                        [getIpV4MaskWidth [ixNetworkGetAttr $lsa_hnd/external -networkMask]]
                keylset returnList external.prefix_step   \
                        [ixNetworkGetAttr $lsa_hnd/external -incrementLinkStateIdBy]
            }
        }
    } else {
        #### OSPFV3 returnList
        switch $type {
            router {
                set ifc 0
                set ifc 0
                set interfacesList [ixNetworkGetAttr $lsa_hnd/router -interfaces]
                foreach item $interfacesList {
                    keylset returnList router.links.$ifc.id   \
                            [lindex $item 0]
                    keylset returnList router.links.$ifc.data \
                            [lindex $item 2]
                    set typeIndex [lindex $item 3]
                    set typeString $lsaRouterIfcTypeArray($typeIndex)
                    keylset returnList router.links.$ifc.type $typeString
                    incr ifc
                }
            }
            network {
                keylset returnList network.attached_router_ids \
                        [ixNetworkGetAttr $lsa_hnd/network -attachedRouters]
            }
            summary_pool {
                keylset returnList summary.num_prefix    \
                        [ixNetworkGetAttr $lsa_hnd/interAreaPrefix -lsaCount]
                keylset returnList summary.prefix_start  \
                        [ixNetworkGetAttr $lsa_hnd/interAreaPrefix -addressPrefix]
                keylset returnList summary.prefix_length \
                        [ixNetworkGetAttr $lsa_hnd/interAreaPrefix -addPrefixLength]
                keylset returnList summary.prefix_step   \
                    [ixNetworkGetAttr $lsa_hnd/interAreaPrefix -prefixAddressIncrementBy]
            }
            asbr_summary {
                keylset returnList summary.num_prefix    \
                        [ixNetworkGetAttr $lsa_hnd/interAreaRouter -lsaCount]
                keylset returnList summary.prefix_start  \
                        [ixNetworkGetAttr $lsa_hnd/interAreaRouter -routerId]
                # don't have this field to return
                #keylset returnList summary.prefix_length $summary_prefix_length

                keylset returnList summary.prefix_step   \
                        [ixNetworkGetAttr $lsa_hnd/interAreaRouter -routerIdIncrementBy]
            }
            ext_pool {
                keylset returnList external.num_prefix   \
                        [ixNetworkGetAttr $lsa_hnd/asExternal -lsaCount]
                keylset returnList external.prefix_start \
                        [ixNetworkGetAttr $lsa_hnd/asExternal -addPrefix]
                keylset returnList external.prefix_length\
                        [ixNetworkGetAttr $lsa_hnd/asExternal -addPrefixLength]
                keylset returnList external.prefix_step  \
                        [ixNetworkGetAttr $lsa_hnd/asExternal -addPrefixIncrementBy]
            }
        }
    }

    keylset returnList lsa_handle $lsa_hnd
    keylset returnList status $::SUCCESS

    return $returnList
}


proc ::ixia::ixnetwork_ospf_info { args man_args opt_args} {
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    set ospf_version [list 2]
    if {[info exists port_handle]} {
        set ospf_version [list]
        
        set portHandles    ""
        set portObjHandles ""
        set routerHandles  ""
        foreach portHandle $port_handle {
            set retCode [ixNetworkGetPortObjref $portHandle]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            set portObjHandle [keylget retCode vport_objref]
            lappend portHandles $portHandle
            lappend portObjHandles $portObjHandle
            set v2routers [ixNet getList $portObjHandle/protocols/ospf router]
            set v3routers [ixNet getList $portObjHandle/protocols/ospfV3 router]
            set routerHandles [list]
            if {$v2routers != ""} {
                lappend routerHandles $v2routers
                lappend ospf_version [list 2]
            }
            if {$v3routers != ""} {
                lappend routerHandles $v3routers
                lappend ospf_version [list 3]
            }
        }
    } elseif {[info exists handle]} {
        set portHandles    ""
        set portObjHandles ""
        set routerHandles  $handle
        foreach handleElem $handle {
            if {![regexp {^(.*)/protocols/ospf(?:V3)?/router:[0-9a-zA-Z]+$} $handleElem {} port_objref]} {
                keylset returnList status $::FAILURE
                keylset returnList log "The handle '$handle' is not a valid\
                        OSPF router handle."
                return $returnList
            }
            if {[regexp {^(.*)/protocols/ospfV3/router:[0-9a-zA-Z]+$} $handleElem {} port_objref]} {
                set ospf_version [list 3]
            }
            lappend portObjHandles $port_objref
            set retCode [ixNetworkGetPortFromObj $port_objref]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            lappend portHandles    [keylget retCode port_handle]
        }
        set portHandles    [lsort -unique $portHandles]
        set portObjHandles [lsort -unique $portObjHandles]
        if {$portHandles == ""} {
            keylset returnList log "ERROR in $procName: \
                    Invalid handles were provided. Parameter -handle must\
                    be provided with a list of ISIS session handles."
            keylset returnList status $::FAILURE
            return $returnList
        }
    }
    
    if {$mode == "aggregate_stats"} {
        set port_handles $portHandles
        
        set stats_array_aggregate_list {
            "Port Name"
                port_name
            "Sess. Configured"
                sessions_configured
            "Full Nbrs." 
                full_neighbors
            "Session Flap Count"
                session_flap_count
            "Down State Count"
                neighbor_down_count
            "Attempt State Count"
                neighbor_attempt_count
            "Init State Count"
                neighbor_init_count
            "TwoWay State Count"
                neighbor_2way_count
            "ExStart State Count"
                neighbor_exstart_count
            "Exchange State Count"
                neighbor_exchange_count
            "Loading State Count"
                neighbor_loading_count
            "Full State Count"
                neighbor_full_count
            "Hellos Tx"
                hellos_tx
            "Hellos Rx"
                hellos_rx
            "DBD Tx"
                database_description_tx
            "DBD Rx"
                database_description_rx
            "LS Request Tx"
                linkstate_request_tx
            "LS Request Rx"
                linkstate_request_rx
            "LS Update Tx"
                linkstate_update_tx
            "LS Update Rx"
                linkstate_update_rx
            "LS Ack Tx"
                linkstate_ack_tx
            "LS Ack Rx"
                linkstate_ack_rx
            "LinkState Advertisement Tx"
                linkstate_advertisement_tx
            "LinkState Advertisement Rx"
                linkstate_advertisement_rx
            "RouterLSA Tx"
                router_lsa_tx
            "RouterLSA Rx"
                router_lsa_rx
            "NetworkLSA Tx"
                network_lsa_tx
            "NetworkLSA Rx"
                network_lsa_rx
            "ExternalLSA Tx"
                external_lsa_tx
            "ExternalLSA Rx"
                external_lsa_rx
        }
        set stats_array_aggregate_list_v2 {
            "SummaryIPLSA Tx"
                summary_iplsa_tx
            "SummaryIPLSA Rx"
                summary_iplsa_rx
            "SummaryASLSA Tx"
                summary_aslsa_tx
            "SummaryASLSA Rx"
                summary_aslsa_rx
            "NSSALSA Tx"
                nssa_lsa_tx
            "NSSALSA Rx"
                nssa_lsa_rx
            "OpaqueLocalLSA Tx"
                opaque_local_lsa_tx
            "OpaqueLocalLSA Rx"
                opaque_local_lsa_rx
            "OpaqueAreaLSA Tx"
                opaque_area_lsa_tx
            "OpaqueAreaLSA Rx"
                opaque_area_lsa_rx
            "OpaqueDomainLSA Tx"
                opaque_domain_lsa_tx
            "OpaqueDomainLSA Rx"
                opaque_domain_lsa_rx
            "GraceLSA Rx"
                grace_lsa_rx
            "HelperMode Attempted"
                helpermode_attempted
            "HelperMode Failed"
                helpermode_failed
            "Rate Control Blocked Flood LSUpdate"
                rate_control_blocked_flood_lsupdate
            "LSAs Acknowledged"
                lsa_acknowledged
            "LSA Acknowledges Rx"
                lsa_acknowledge_rx
        }
        set stats_array_aggregate_list_v3 {
            "LinkLSA Tx"
                link_lsa_tx
            "LinkLSA Rx"
                link_lsa_rx
            "IntraareaPrefixLSA Tx"
                intraarea_prefix_lsa_tx
            "IntraareaPrefixLSA Rx"
                intraarea_prefix_lsa_rx
            "InterareaPrefixLSA Tx"
                interarea_prefix_lsa_tx
            "InterareaPrefixLSA Rx"
                interarea_prefix_lsa_rx
            "InterareaRouterLSA Tx"
                interarea_router_lsa_tx
            "InterareaRouterLSA Rx"
                interarea_router_lsa_rx
            "Retransmitted LSA"
                retrasmitted_lsa

        }
        
        foreach ospf_v $ospf_version {
            catch {unset stats_array_aggregate}
            if {$ospf_v == 2} {
                array set stats_array_aggregate [concat $stats_array_aggregate_list $stats_array_aggregate_list_v2]
                set statistic_types { aggregate "OSPF Aggregated Statistics" }
            } else {
                array set stats_array_aggregate [concat $stats_array_aggregate_list $stats_array_aggregate_list_v3]
                set statistic_types { aggregate "OSPFv3 Aggregated Statistics" }
            }
        
            set portIndex 0
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
                                keylset returnList ${port_key}.${stat_type}.$stats_array($stat) \
                                        $rows_array($i,$stat)
                            } else {
                                keylset returnList ${port_key}.${stat_type}.$stats_array($stat) "N/A"
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
        }
    }

    if {$mode == "clear_stats"} {
        foreach port_handle $portHandles {
            if {$port_handle != "0/0/0"} {
                if {[set retCode [catch \
                        {ixNet exec clearStats} retCode]]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to clear statistics."
                    return $returnList
                }
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to determine the port handle\
                        of the port on which the '$handle' router is emulated."
                return $returnList
            }
        }
    }
    
    # this mode should be used with -handle, although it will work with -port_handle
    if {$mode == "learned_info"} {
        set stats_list {
            advRouterId     adv_router_id
            age             age
            linkStateId     link_state_id
            lsaType         lsa_type
            seqNumber       seq_number
            prefixV4Address prefix_v4_address
            prefixV6Address prefix_v6_address
            prefixLength    prefix_length
        }
        
        set ok_one 0
        set incr_log ""
        foreach {router} $routerHandles {
            if {[regexp {.*/protocols/ospf/router:[0-9a-zA-Z]+$} $router]} {
                foreach {intf} [ixNet getList $router interface] {
                    debug "ixNet exec refreshLearnedInfo $intf"
                    set retCode [ixNet exec refreshLearnedInfo $intf]
                    if {[string first "::ixNet::OK" $retCode] == -1 } {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to refresh learned info for\
                                OSPF router $router interface $intf."
                        return $returnList
                    }
                    set retries 100
                    while {[ixNet getAttribute $intf -isLearnedInfoRefreshed] != "true"} {
                        after 10
                        incr retries -1
                        if {$retries < 0} {
                            keylset returnList status $::SUCCESS
                            append incr_log "Refreshing learned info for\
                                    OSPF router $router interface $intf has timed out. Please try again later. "
                            
                            set session 1
                            foreach {ixnOpt hltOpt} $stats_list {
                                keylset returnList $router.$intf.session.$session.$hltOpt \
                                        "NA"
                            }
                            break
                        }
                    }
                    # skip this interface, but no error
                    if {$retries < 0} { continue }                
                    
                    set ok_one 1
                    set learnedInfoList [ixNet getList $intf learnedLsa]
                    
                    set session 1
                    foreach {learnedInfo} $learnedInfoList {
                        foreach {ixnOpt hltOpt} $stats_list {
                            keylset returnList $router.$intf.session.$session.$hltOpt \
                                    [ixNet getAttribute $learnedInfo -$ixnOpt]
                        }
                        incr session
                    }
                }
            } elseif {[regexp {.*/protocols/ospfV3/router:[0-9a-zA-Z]+$} $router]} {
                debug "ixNet exec refreshLearnedLsa $router"
                set retCode [ixNet exec refreshLearnedLsa $router]
                if {[string first "::ixNet::OK" $retCode] == -1 } {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to refresh learned lsa for\
                            OSPF router $router."
                    return $returnList
                }
                set retries 10
                while {[ixNet getAttribute $intf -isLearnedLsaRefreshed] != "true"} {
                    after 10
                    incr retries -1
                    if {$retries < 0} {
                        keylset returnList status $::SUCCESS
                        append incr_log "Refreshing learned lsa for\
                                OSPF router $router has timed out. Please try again later. "
                        
                        set session 1
                        foreach {ixnOpt hltOpt} $stats_list {
                            keylset returnList $router.session.$session.$hltOpt \
                                    "NA"
                        }
                        break
                    }
                }
                # skip this router
                if {$retries < 0} { continue }
                
                set learnedLsaList [ixNet getList $intf learnedLsa]
                set ok_one 1
                
                set session 1
                foreach {learnedLsa} $learnedLsaList {
                    foreach {ixnOpt hltOpt} $stats_list {
                        keylset returnList $router.session.$session.$hltOpt \
                                [ixNet getAttribute $learnedLsa -$ixnOpt]
                    }
                    incr session
                }
            }
        }
        if {$ok_one == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "Refreshing learned info/lsa for all interfaces of all given OSPF routers timed out."
            return $returnList
        } else {
            keylset returnList status $::SUCCESS
            keylset returnList log $incr_log
            return $returnList
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}
