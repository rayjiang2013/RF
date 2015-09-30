##Library Header
# $Id: $
# Copyright © 2003-2007 by IXIA
# All Rights Reserved.
#
# Name:
#    ixnetwork_isis_api.tcl
#
# Purpose:
#    A library containing ISIS APIs for test automation
#    with the Ixia chassis. It uses the IxNetwork 5.30 TCL API.
#
# Author:
#    Matei-Eugen Vasile
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures contained within this library include:
#
#    - ixnetwork_isis_config
#    - ixnetwork_isis_topology_route_config
#    - ixnetwork_isis_control
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

proc ::ixia::ixnetwork_isis_config { args man_args opt_args } {
    variable objectMaxCount
    variable truth

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    if {[info exists area_id]} {
        set area_id [::ixia::formatAreaId $area_id]
    }
    
    keylset returnList status $::SUCCESS

    array set translate_mode [list                  \
            enable              true                \
            disable             false               \
            ]

    array set translate_area_authentication_mode [list \
            null                none                \
            text                password            \
            md5                 md5                 \
            ]
    
    array set translate_domain_authentication_mode [list \
            null                none                \
            text                password            \
            md5                 md5                 \
            ]
    
    array set translate_graceful_restart_mode [list \
            normal              normalRouter        \
            restarting          restartingRouter    \
            starting            startingRouter      \
            helper              helperRouter        \
            ]

    array set translate_graceful_restart_version [list \
            draft3              version3               \
            draft4              version4               \
            ]

    array set translate_intf_type [list             \
            broadcast           broadcast           \
            ptop                pointToPoint        \
            ]

    array set translate_routing_level [list         \
            L1                  level1              \
            L1L2                level1Level2        \
            L2                  level2              \
            ]
    
    array set translate_loopback_routing_level [list \
            L1                  level1               \
            L1L2                level1Level2         \
            L2                  level2               \
            ]
    
    set result [ixNetworkGetPortObjref $port_handle]
    if {[keylget result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to find the port object reference \
                associated to the $port_handle port handle -\
                [keylget result log]."
        return $returnList
    }
    set protocol_objref [keylget result vport_objref]/protocols/isis
    # Check if protocols are supported
    set retCode [checkProtocols [keylget result vport_objref]]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Port $port_handle does not support protocol\
                configuration."
        return $returnList
    }

    if {[info exists reset]} {
        if {![info exists no_write]} {
            set result [ixNetworkNodeRemoveList $protocol_objref \
                    { {child remove router} {} } -commit]
        } else {
            set result [ixNetworkNodeRemoveList $protocol_objref \
                    { {child remove router} {} }]
        }
        if {[keylget result status] == $::FAILURE} {
            return $returnList
        }
        if {[info exists isis_handles_array]} {
            array unset isis_handles_array
        }
        array set isis_handles_array ""
    }

    if {($mode == "delete") || ($mode == "enable") || ($mode == "disable") || \
            ($mode == "modify")} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode,\
                    the -handle option must be used.  Please set this value."
            return $returnList
        }

        if {$mode == "delete"} {
            debug "ixNetworkRemove $handle"
            ixNetworkRemove $handle
            if {![info exists no_write]} {
                debug "ixNetworkCommit"
                ixNetworkCommit
            }

            array unset isis_handles_array $handle
        } elseif {[info exists translate_mode($mode)]} {
            if {![info exists no_write]} {
                set retCode [ixNetworkNodeSetAttr $handle \
                        [subst {-enabled $translate_mode($mode)}] -commit]
            } else {
                set retCode [ixNetworkNodeSetAttr $handle \
                        [subst {-enabled $translate_mode($mode)}]]
            }
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
        }

        keylset returnList handle $handle
    }

    if {$mode == "create"} {
        set isis_router_list [list]

        if {![info exists no_write]} {
            set retCode [ixNetworkNodeSetAttr $protocol_objref [list -enabled true] -commit]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
        } else {
            set retCode [ixNetworkNodeSetAttr $protocol_objref [list -enabled true]]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
        }

        ##Interfaces
        # Configure the necessary interfaces
        if {[info exists interface_handle] && [info exists count] && \
                [llength $interface_handle] != $count} {
            keylset returnList status $::FAILURE
            keylset returnList log "The -interface_handle list doesn't\
                    have the size specified with the -count argument."
            return $returnList
        } elseif {[info exists interface_handle]} {
            set intf_list [list]
            foreach intf $interface_handle {
                lappend intf_list $intf
            }
        } else {
            set protocol_intf_options "                                     \
                    -atm_encapsulation          atm_encapsulation           \
                    -atm_vci                    vci                         \
                    -atm_vci_step               vci_step                    \
                    -atm_vpi                    vpi                         \
                    -atm_vpi_step               vpi_step                    \
                    -count                      count                       \
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
            if {[::ixia::is_default_param_value ip_version $args]} {
                if {[::ixia::is_default_param_value intf_ip_addr $args]} {
                    if {[::ixia::is_default_param_value intf_ipv6_addr $args]} {
                        set ip_version 4_6
                    } else {
                        set ip_version 6
                    }
                } else {
                    if {[::ixia::is_default_param_value intf_ipv6_addr $args]} {
                        set ip_version 4
                    } else {
                        set ip_version 4_6
                    }
                }
            }
            if {$ip_version == 4 || $ip_version == "4_6"} {
                append protocol_intf_options " \
                        -ipv4_address               intf_ip_addr            \
                        -ipv4_address_step          intf_ip_addr_step       \
                        -ipv4_prefix_length         intf_ip_prefix_length   \
                        -gateway_address            gateway_ip_addr         \
                        -gateway_address_step       gateway_ip_addr_step    \
                        "
            }
            if {$ip_version == 6 || $ip_version == "4_6"} {
                append protocol_intf_options " \
                        -ipv6_address               intf_ipv6_addr          \
                        -ipv6_address_step          intf_ipv6_addr_step     \
                        -ipv6_prefix_length         intf_ipv6_prefix_length \
                        -ipv6_gateway               gateway_ipv6_addr       \
                        -ipv6_gateway_step          gateway_ipv6_addr_step  \
                        "
            }
            ## Cisco specs- if ip_version is 4_6 wide_metrics, multi_topology 
			##  should default to true.
            if {$ip_version == "4_6"} {
				if {[::ixia::is_default_param_value wide_metrics $args]} {
					set wide_metrics $::true
				}
				if {[::ixia::is_default_param_value multi_topology $args]} {
					set multi_topology $::true
				} 
            } 
            # Passed in only those options that exist
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
            set intf_list [keylget intf_list connected_interfaces]
        }
        
        # List of static (non-incrementing) options for ISIS router
        set staticIsisRouterOptions {
            area_authentication_mode      areaAuthType              translate
            attach_bit                    enableAttached            truth
            discard_lsp                   enableDiscardLearnedLsps  truth
            domain_authentication_mode    domainAuthType            translate
            graceful_restart              enableHitlessRestart      truth
            graceful_restart_mode         restartMode               translate
            graceful_restart_restart_time restartTime               default
            graceful_restart_version      restartVersion            translate
            lsp_life_time                 lspLifeTime               default
            lsp_refresh_interval          lspRefreshRate            default
            max_packet_size               lspMaxSize                default
            overloaded                    enableOverloaded          truth
            partition_repair              enablePartitionRepair     truth
            te_enable                     teEnable                  truth
            wide_metrics                  enableWideMetric          truth
			multi_topology				  enableMtIpv6				truth
        }
        
        # Start creating list of static ISIS router options
        set isis_router_static_args [list -enabled true]
        
        # Check ISIS router options existence and append parameters that exist
        foreach {hltOpt ixnOpt optType} $staticIsisRouterOptions {
            if {[info exists $hltOpt]} {
                switch $optType {
                    translate {
                        lappend isis_router_static_args -$ixnOpt \
                                [set translate_${hltOpt}([set $hltOpt])]
                    }
                    truth {
                        lappend isis_router_static_args -$ixnOpt \
                                $truth([set $hltOpt])
                    }
                    default {
                        lappend isis_router_static_args -$ixnOpt \
                                [set $hltOpt]
                    }
                }
            }
        }
        # Static arg area_password
        if {[info exists area_authentication_mode]} {
            if {[info exists area_password]} {
                if {$area_authentication_mode == "text" ||
                        $area_authentication_mode == "md5" } {
                    lappend isis_router_static_args -areaTransmitPassword \
                            $area_password
                }
                if {$area_authentication_mode == "text"} {
                    lappend isis_router_static_args -areaReceivedPasswordList \
                            [list $area_password]
                }
            }
        }
        # Static arg domain_password
        if {[info exists domain_authentication_mode]} {
            if {[info exists domain_password]} {
                if {$domain_authentication_mode == "text" ||
                        $domain_authentication_mode == "md5" } {
                    lappend isis_router_static_args -domainTransmitPassword \
                            $domain_password
                }
                if {$domain_authentication_mode == "text"} {
                    lappend isis_router_static_args -domainReceivedPasswordList \
                            [list $domain_password]
                }
            }
        }
        
        # List of static default values for ISIS interface
        set staticDefaultIsisInterfaceValues {
            te_unresv_bw_priority0 0
            te_unresv_bw_priority1 0
            te_unresv_bw_priority2 0
            te_unresv_bw_priority3 0
            te_unresv_bw_priority4 0
            te_unresv_bw_priority5 0
            te_unresv_bw_priority6 0
            te_unresv_bw_priority7 0
        }
        foreach {hltOpt defaultValue} $staticDefaultIsisInterfaceValues {
            if {![info exists $hltOpt]} {
                set $hltOpt $defaultValue
            }
        }
        
        # List of static (non-incrementing) options for ISIS interface
        set staticIsisInterfaceOptions {
            hello_interval          level1HelloTime       default
            hello_interval          level2HelloTime       default
            intf_metric             metric                default
            intf_type               networkType           translate
            routing_level           level                 translate
            l1_router_priority      priorityLevel1        default
            l2_router_priority      priorityLevel2        default
            te_metric               teMetricLevel         default
            te_admin_group          teAdminGroup          hex
            te_max_bw               teMaxBandwidth        default
            te_max_resv_bw          teResMaxBandwidth     default
            bfd_registration        enableBfdRegistration truth
        }
        
        # Start creating list of static ISIS interface options
        set isis_intf_static_args [list     \
                -enabled              true  \
                -enableConnectedToDut true  ]
        
        # Static args area_authentication_mode,   area_password
        # Static args domain_authentication_mode, domain_password
        if {[info exists hello_password] && $truth($hello_password)} {
            if {[info exists routing_level] && \
                    ($routing_level == "L1" || $routing_level == "L1L2")} {
                if {[info exists area_authentication_mode]} {
                    lappend isis_intf_static_args -circuitAuthType \
                            $translate_area_authentication_mode($area_authentication_mode)
                    if {[info exists area_password]} {
                        if {$area_authentication_mode == "text" ||
                                $area_authentication_mode == "md5" } {
                            lappend isis_intf_static_args -circuitTransmitPassword \
                                    $area_password
                        }
                        if {$area_authentication_mode == "text"} {
                            lappend isis_intf_static_args -circuitReceivedPasswordList \
                                    [list $area_password]
                        }
                    }
                }
            } else {
                if {[info exists domain_authentication_mode]} {
                    lappend isis_intf_static_args -circuitAuthType \
                            $translate_domain_authentication_mode($domain_authentication_mode)
                    if {[info exists domain_password]} {
                        if {$domain_authentication_mode == "text" ||
                                $domain_authentication_mode == "md5" } {
                            lappend isis_intf_static_args -circuitTransmitPassword \
                                    $domain_password
                        }
                        if {$domain_authentication_mode == "text"} {
                            lappend isis_intf_static_args -circuitReceivedPasswordList \
                                    [list $domain_password]
                        }
                    }
                }
            }
        }
        # Check ISIS interface options existence and append parameters that exist
        foreach {hltOpt ixnOpt optType} $staticIsisInterfaceOptions {
            if {[info exists $hltOpt]} {
                switch $optType {
                    translate {
                        lappend isis_intf_static_args -$ixnOpt \
                                [set translate_${hltOpt}([set $hltOpt])]
                    }
                    truth {
                        lappend isis_intf_static_args -$ixnOpt \
                                $truth([set $hltOpt])
                    }
                    hex {
                        lappend isis_intf_static_args -$ixnOpt \
                                [format "%x" [set $hltOpt]]
                    }
                    default {
                        lappend isis_intf_static_args -$ixnOpt \
                                [set $hltOpt]
                    }
                }
            }
        }
        # List of static default values for ISIS loopback interface
        set staticDefaultIsisInterfaceValues {
            loopback_te_unresv_bw_priority0 0
            loopback_te_unresv_bw_priority1 0
            loopback_te_unresv_bw_priority2 0
            loopback_te_unresv_bw_priority3 0
            loopback_te_unresv_bw_priority4 0
            loopback_te_unresv_bw_priority5 0
            loopback_te_unresv_bw_priority6 0
            loopback_te_unresv_bw_priority7 0
        }
        foreach {hltOpt defaultValue} $staticDefaultIsisInterfaceValues {
            if {![info exists $hltOpt]} {
                set $hltOpt $defaultValue
            }
        }
        # List of static (non-incrementing) options for ISIS loopback interface
        set staticIsisLoopbackOptions {
            loopback_metric                  metric                default
            loopback_routing_level           level                 translate
            loopback_l1_router_priority      priorityLevel1        default
            loopback_l2_router_priority      priorityLevel2        default
            loopback_te_metric               teMetricLevel         default
            loopback_te_admin_group          teAdminGroup          hex
            loopback_te_max_bw               teMaxBandwidth        default
            loopback_te_max_resv_bw          teResMaxBandwidth     default
            loopback_bfd_registration        enableBfdRegistration truth
            loopback_ip_prefix_length        interfaceIpMask       mask
        }
        # Start creating list of static ISIS interface options
        set isis_loop_static_args [list -enabled true -enableConnectedToDut false]
        
        # Static args: area_authentication_mode, area_password
        # Static args: domain_authentication_mode, domain_password
        if {[info exists loopback_hello_password] && \
                $truth($loopback_hello_password)} {
            if {[info exists routing_level] && \
                    ($routing_level == "L1" || $routing_level == "L1L2")} {
                if {[info exists area_authentication_mode]} {
                    lappend isis_loop_static_args -circuitAuthType \
                            $translate_area_authentication_mode($area_authentication_mode)
                    if {[info exists area_password]} {
                        if {$area_authentication_mode == "text" ||
                                $area_authentication_mode == "md5" } {
                            lappend isis_loop_static_args \
                                    -circuitTransmitPassword \
                                    $area_password
                        }
                        if {$area_authentication_mode == "text"} {
                            lappend isis_loop_static_args \
                                    -circuitReceivedPasswordList \
                                    [list $area_password]
                        }
                    }
                }
            } else {
                if {[info exists domain_authentication_mode]} {
                    lappend isis_loop_static_args -circuitAuthType \
                            $translate_domain_authentication_mode($domain_authentication_mode)
                    if {[info exists domain_password]} {
                        if {$domain_authentication_mode == "text" ||
                                $domain_authentication_mode == "md5" } {
                            lappend isis_loop_static_args \
                                    -circuitTransmitPassword \
                                    $domain_password
                        }
                        if {$domain_authentication_mode == "text"} {
                            lappend isis_loop_static_args \
                                    -circuitReceivedPasswordList \
                                    [list $domain_password]
                        }
                    }
                }
            }
        }
        # Check ISIS loopback options existence and append parameters that exist
        foreach {hltOpt ixnOpt optType} $staticIsisLoopbackOptions {
            if {[info exists $hltOpt]} {
                switch $optType {
                    translate {
                        lappend isis_loop_static_args -$ixnOpt \
                                [set translate_${hltOpt}([set $hltOpt])]
                    }
                    truth {
                        lappend isis_loop_static_args -$ixnOpt \
                                $truth([set $hltOpt])
                    }
                    hex {
                        lappend isis_loop_static_args -$ixnOpt \
                                [format "%x" [set $hltOpt]]
                    }
                    mask {
                        lappend isis_loop_static_args -$ixnOpt \
                                [getIpV4MaskFromWidth [set $hltOpt]]
                    }
                    default {
                        lappend isis_loop_static_args -$ixnOpt \
                                [set $hltOpt]
                    }
                }
            }
        }
        
        ## Routers
        set objectCount    0
        foreach intf_objref $intf_list {
            ## Router
            # Create the attributes list
            set isis_router_args $isis_router_static_args
            
            if {[info exists area_id]} {
                lappend isis_router_args -areaAddressList [list $area_id]
            }
            
            if {[info exists te_router_id]} {
                lappend isis_router_args -teRouterId $te_router_id
            }
            
            if {![info exists system_id]} {
                if {$ip_version == "6"} {
                    set ipHex [convert_v6_addr_to_hex $intf_ipv6_addr]
                    set system_id [format "%s" [join $ipHex ""]]
                } else {
                    set ipHex [convert_v4_addr_to_hex $intf_ip_addr]
                    set system_id [format "0200%s" [join $ipHex ""]]
                }
            } else {
                # check system_id if has a valid value
                set match 0
                foreach {reg_exp type} [list "^\\d+$" "n" "^0x\[0-9a-f\]+$" "n" \
                        "^(\[0-9a-f\]{2}\ ){5}(\[0-9a-f\]{2})$" "e" \
                        "^(\[0-9a-f\]{2}\.){5}(\[0-9a-f\]{2})$" "e" \
                        "^(\[0-9a-f\]{2}\:){5}(\[0-9a-f\]{2})$" "e" ] {
                    if {[regexp -nocase -- $reg_exp [string trim $system_id]]} {
                        set match 1
                        if {$type == "e"} {
                            set system_id "[regsub -all "\[.: \]" $system_id {}]"
                        } else {
                            regexp -- "^0x(.*)" $system_id {} system_id
                        }
                        break
                    }
                }
                if {!$match} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value \
                            specified for system_id."
                    return $returnList
                }
            }
            lappend isis_router_args -systemId $system_id

            # Create router
            set result [ixNetworkNodeAdd $protocol_objref router \
                    $isis_router_args]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not add a new router to the\
                        following protocol object reference: $protocol_objref -\
                        [keylget result log]."
                return $returnList
            }
            set router_objref [keylget result node_objref]
            
            if {$router_objref == [ixNet getNull]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to add router to the \
                        $protocol_objref protocol object reference"
                return $returnList
            }
            lappend isis_router_list $router_objref
            set isis_handles_array($router_objref) $port_handle
            
            # Commit
            incr objectCount
            if {![info exists no_write] && [expr $objectCount % $objectMaxCount] == 0} {
                debug "ixNetworkCommit"
                ixNetworkCommit
            }
            
            ## Protocol interfaces
            ## Connected protocol interface
            #  Create the attributes list
            set     isis_intf_args $isis_intf_static_args
            lappend isis_intf_args -interfaceId $intf_objref
            lappend isis_intf_args                  \
                    -teUnreservedBwPriority [list   \
                    $te_unresv_bw_priority0         \
                    $te_unresv_bw_priority1         \
                    $te_unresv_bw_priority2         \
                    $te_unresv_bw_priority3         \
                    $te_unresv_bw_priority4         \
                    $te_unresv_bw_priority5         \
                    $te_unresv_bw_priority6         \
                    $te_unresv_bw_priority7         \
                    ]
                        
            # Create connected protocol interface
            set result [ixNetworkNodeAdd $router_objref interface \
                    $isis_intf_args]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not add a new connected protocol\
                        interface to the following router object reference:\
                        $router_objref - [keylget result log]."
                return $returnList
            }
            set proto_intf_objref [keylget result node_objref]
            
            if {$proto_intf_objref == [ixNet getNull]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to add protocol interface\
                        to the $router_objref router object reference"
                return $returnList
            }
            
            # Commit
            incr objectCount
            if {![info exists no_write] && [expr $objectCount % $objectMaxCount] == 0} {
                debug "ixNetworkCommit"
                ixNetworkCommit
            }
            
            ## Unconnected router interface
            if {![info exists loopback_ip_addr]} {
                set loopback_ip_addr_count 0
            }
            for {set i 0} {$i < $loopback_ip_addr_count} {incr i} {
                # Create the attributes list
                set isis_intf_args $isis_loop_static_args
                if {[info exists loopback_ip_addr]} {
                    lappend isis_intf_args -interfaceIp $loopback_ip_addr
                }
                
                lappend isis_intf_args                      \
                        -teUnreservedBwPriority [list       \
                        $loopback_te_unresv_bw_priority0    \
                        $loopback_te_unresv_bw_priority1    \
                        $loopback_te_unresv_bw_priority2    \
                        $loopback_te_unresv_bw_priority3    \
                        $loopback_te_unresv_bw_priority4    \
                        $loopback_te_unresv_bw_priority5    \
                        $loopback_te_unresv_bw_priority6    \
                        $loopback_te_unresv_bw_priority7    \
                        ]
    
                # Create unconnected router interface
                set result [ixNetworkNodeAdd $router_objref \
                        interface $isis_intf_args ]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not add a new unconnected\
                            protocol interface to the following router object\
                            reference: $router_objref - [keylget result log]."
                    return $returnList
                }
                set loopback_intf_objref [keylget result node_objref]
                
                if {$loopback_intf_objref == [ixNet getNull]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to add unconnected \
                            protocol interface to the $router_objref router \
                            object reference"
                    return $returnList
                }
                
                # Commit
                incr objectCount
                if {![info exists no_write] && [expr $objectCount % $objectMaxCount] == 0} {
                    debug "ixNetworkCommit"
                    ixNetworkCommit
                }
                
                # Increment unconnected interface parameters
                if {[info exists loopback_ip_addr]} {
                    if {![info exists loopback_ip_addr_step]} {
                        set loopback_ip_addr_step 0.0.1.0
                    } else  {
                        if {![::isIpAddressValid $loopback_ip_addr_step]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Invalid unconnected \
                                    interface IP step."
                            return $returnList
                        }
                    }
                    set loopback_ip_addr [::ixia::incr_ipv4_addr \
                            $loopback_ip_addr $loopback_ip_addr_step]
                }
            }

            ##Increment router parameters
            if {[info exists area_id]} {
                if {![info exists area_id_step]} {
                    set area_id_step "00 00 01"
                }
                set area_id [mpformat "%x" [mpexpr \
                        0x[::ixia::convert_string_to_hex $area_id] + \
                        0x[::ixia::convert_string_to_hex $area_id_step]]]
            }

            if {[info exists system_id]} {
                if {![info exists system_id_step]} {
                    set system_id_step "00 00 00 00 00 01"
                }
                set system_id [::ixia::val2Bytes [mpexpr \
                        0x[::ixia::convert_string_to_hex $system_id] + \
                        0x[::ixia::convert_string_to_hex $system_id_step]] 6 ]
            }

            if {[info exists te_router_id]} {
                if {![info exists te_router_id_step]} {
                    set te_router_id_step 0.0.1.0
                } else  {
                    if {![::isIpAddressValid $te_router_id_step]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Invalid TE router ID step."
                        return $returnList
                    }
                }
                set te_router_id [::ixia::incr_ipv4_addr $te_router_id \
                        $te_router_id_step]
            }
        }

        ##Done
        if {![info exists no_write] && [expr $objectCount % $objectMaxCount] != 0} {
            debug "ixNetworkCommit"
            ixNetworkCommit
        }
        set connected_intf_list {}
        set unconnected_intf_list {}
        
        foreach router_item [ixNet remapIds $isis_router_list] {
            set first true
            foreach intf_obj [ixNetworkGetList $router_item interface] {
                if {$first} {
                    set first false
                    append connected_intf_list "$intf_obj "
                } else {
                    append unconnected_intf_list "$intf_obj "
                }
            }
        }
        
        debug "ixNet remapIds {$isis_router_list}"
        set isis_router_list [ixNet remapIds $isis_router_list]
        keylset returnList handle $isis_router_list
        keylset returnList connected_isis_interfaces $connected_intf_list
        keylset returnList unconnected_isis_interfaces $unconnected_intf_list
    }

    if {$mode == "modify"} {
        # Remove defaults
        removeDefaultOptionVars $opt_args $args

        # Interface
        # Modify the interface
        set interface_handle ""
        if {[regexp -- "::ixNet::OBJ-/vport:\\d+/protocols/isis/router:\\d+" \
                $handle router_objref] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "Malformed handle specified."
            return $returnList
        }
        if {[regexp -- "::ixNet::OBJ-/vport:\\d+/protocols/isis/router:\\d+/interface:\\d+" \
                $handle isis_intf_objref] == 1} {
            if {[ixNetworkGetAttr $isis_intf_objref -enableConnectedToDut]} {
                set router_intf_objref $isis_intf_objref
                set router_loop_objref [list]
            } else {
                set router_intf_objref [lindex [ixNetworkGetList $router_objref \
                        interface] 0]
                set router_loop_objref $isis_intf_objref
            }
        } else {
            set router_intf_objref [lindex [ixNetworkGetList $router_objref \
                        interface] 0]
            set router_loop_objref [lrange [ixNetworkGetList $router_objref \
                        interface] 1 end]
        }
                
        set interface_handle   [ixNetworkGetAttr $router_intf_objref \
                -interfaceId]
        
        if {$interface_handle == ""} {
            keylset returnList status $::FAILURE
            keylset returnList log "Cannot get protocol interface from\
                    -handle $handle"
            return $returnList
        }
        
        set retCode [ixNetworkGetPortFromObj $handle]
        if {[keylget retCode status] == $::FAILURE} {
            return $retCode
        }
        set port_handle  [keylget retCode port_handle]
        set vport_objref [keylget retCode vport_objref]
        set protocol_objref [keylget retCode vport_objref]/protocols/isis
        
        
        set protocol_intf_options "                                 \
                -atm_encapsulation          atm_encapsulation       \
                -atm_vci                    vci                     \
                -atm_vpi                    vpi                     \
                -ipv4_address               intf_ip_addr            \
                -ipv4_prefix_length         intf_ip_prefix_length   \
                -ipv6_address               intf_ipv6_addr          \
                -ipv6_prefix_length         intf_ipv6_prefix_length \
                -gateway_address            gateway_ip_addr         \
                -ipv6_gateway               gateway_ipv6_addr       \
                -ipv6_gateway_step          gateway_ipv6_addr_step  \
                -mac_address                mac_address_init        \
                -vlan_enabled               vlan                    \
                -vlan_id                    vlan_id                 \
                -vlan_user_priority         vlan_user_priority      \
                "
                
        # Passed in only those options that exists
        set protocol_intf_args ""
        foreach {option value_name} $protocol_intf_options {
            if {[info exists $value_name]} {
                append protocol_intf_args " $option [set $value_name]"
            }
        }
        if {$protocol_intf_args != ""} {
            lappend protocol_intf_args -port_handle       $port_handle
            lappend protocol_intf_args -prot_intf_objref  $interface_handle
                        
            # Create the necessary interfaces
            set intf_list [eval ixNetworkConnectedIntfCfg \
                    [join $protocol_intf_args]]
            if {[keylget intf_list status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to modify the \
                        IPv4 interfaces - [keylget intf_list log]"
                return $returnList
            }
        }
        
        # List of static (non-incrementing) options for ISIS router
        set staticIsisRouterOptions {
            area_authentication_mode      areaAuthType              translate
            area_id                       areaAddressList           list
            attach_bit                    enableAttached            truth
            discard_lsp                   enableDiscardLearnedLsps  truth
            domain_authentication_mode    domainAuthType            translate
            graceful_restart              enableHitlessRestart      truth
            graceful_restart_mode         restartMode               translate
            graceful_restart_restart_time restartTime               default
            graceful_restart_version      restartVersion            translate
            lsp_life_time                 lspLifeTime               default
            lsp_refresh_interval          lspRefreshRate            default
            max_packet_size               lspMaxSize                default
            overloaded                    enableOverloaded          truth
            partition_repair              enablePartitionRepair     truth
            te_enable                     teEnable                  truth
            te_router_id                  teRouterId                default
            system_id                     systemId                  default
            wide_metrics                  enableWideMetric          truth
        }
        
        # Start creating list of static ISIS router options
        set isis_router_static_args [list -enabled true]
        
        # Check ISIS router options existence and append parameters that exist
        foreach {hltOpt ixnOpt optType} $staticIsisRouterOptions {
            if {[info exists $hltOpt]} {
                switch $optType {
                    translate {
                        lappend isis_router_static_args -$ixnOpt \
                                [set translate_${hltOpt}([set $hltOpt])]
                    }
                    truth {
                        lappend isis_router_static_args -$ixnOpt \
                                $truth([set $hltOpt])
                    }
                    list {
                        lappend isis_router_static_args -$ixnOpt \
                                [list [set $hltOpt]]
                    }
                    hex {
                        lappend isis_router_static_args -$ixnOpt \
                                [set $hltOpt]
                    }
                    default {
                        lappend isis_router_static_args -$ixnOpt \
                                [set $hltOpt]
                    }
                }
            }
        }
        # Static arg area_password
        if {[info exists area_authentication_mode]} {
            if {[info exists area_password]} {
                if {$area_authentication_mode == "text" ||
                        $area_authentication_mode == "md5" } {
                    lappend isis_router_static_args -areaTransmitPassword \
                            $area_password
                }
                if {$area_authentication_mode == "text"} {
                    lappend isis_router_static_args -areaReceivedPasswordList \
                            [list $area_password]
                }
            }
        }
        # Static arg domain_password
        if {[info exists domain_authentication_mode]} {
            if {[info exists domain_password]} {
                if {$domain_authentication_mode == "text" ||
                        $domain_authentication_mode == "md5" } {
                    lappend isis_router_static_args -domainTransmitPassword \
                            $domain_password
                }
                if {$domain_authentication_mode == "text"} {
                    lappend isis_router_static_args -domainReceivedPasswordList \
                            [list $domain_password]
                }
            }
        }
                
        # Set router args
        if {$isis_router_static_args != ""} {
            set result [ixNetworkNodeSetAttr $router_objref $isis_router_static_args]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not add a new router to the\
                        following protocol object reference: $protocol_objref -\
                        [keylget result log]."
                return $returnList
            }
        }
        
        
        # List of static (non-incrementing) options for ISIS interface
        set staticIsisInterfaceOptions {
            hello_interval          level1HelloTime       default
            hello_interval          level2HelloTime       default
            intf_metric             metric                default
            intf_type               networkType           translate
            routing_level           level                 translate
            te_metric               teMetricLevel         default
            te_admin_group          teAdminGroup          hex
            te_max_bw               teMaxBandwidth        default
            te_max_resv_bw          teResMaxBandwidth     default
            bfd_registration        enableBfdRegistration truth
        }
        
        # Start creating list of static ISIS interface options
        set isis_intf_static_args ""
        
        # Static args area_authentication_mode,   area_password
        # Static args domain_authentication_mode, domain_password
        if {[info exists hello_password] && $truth($hello_password)} {
            if {[info exists routing_level] && \
                    ($routing_level == "L1" || $routing_level == "L1L2")} {
                if {[info exists area_authentication_mode]} {
                    lappend isis_intf_static_args -circuitAuthType \
                            $translate_area_authentication_mode($area_authentication_mode)
                    if {[info exists area_password]} {
                        if {$area_authentication_mode == "text" ||
                                $area_authentication_mode == "md5" } {
                            lappend isis_intf_static_args -circuitTransmitPassword \
                                    $area_password
                        }
                        if {$area_authentication_mode == "text"} {
                            lappend isis_intf_static_args -circuitReceivedPasswordList \
                                    [list $area_password]
                        }
                    }
                }
            } else {
                if {[info exists domain_authentication_mode]} {
                    lappend isis_intf_static_args -circuitAuthType \
                            $translate_domain_authentication_mode($domain_authentication_mode)
                    if {[info exists domain_password]} {
                        if {$domain_authentication_mode == "text" ||
                                $domain_authentication_mode == "md5" } {
                            lappend isis_intf_static_args -circuitTransmitPassword \
                                    $domain_password
                        }
                        if {$domain_authentication_mode == "text"} {
                            lappend isis_intf_static_args -circuitReceivedPasswordList \
                                    [list $domain_password]
                        }
                    }
                }
            }
        }
        # Check ISIS interface options existence and append parameters that exist
        foreach {hltOpt ixnOpt optType} $staticIsisInterfaceOptions {
            if {[info exists $hltOpt]} {
                switch $optType {
                    translate {
                        lappend isis_intf_static_args -$ixnOpt \
                                [set translate_${hltOpt}([set $hltOpt])]
                    }
                    truth {
                        lappend isis_intf_static_args -$ixnOpt \
                                $truth([set $hltOpt])
                    }
                    hex {
                        lappend isis_intf_static_args -$ixnOpt \
                                [format "%x" [set $hltOpt]]
                    }
                    default {
                        lappend isis_intf_static_args -$ixnOpt \
                                [set $hltOpt]
                    }
                }
            }
        }
        # Param te_unresv_bw_priority
        set te_unresv_bw_priority_value 0
        for {set i 0} {$i < 8} {incr i} {
            set te_unresv_bw_priority_value [expr  \
                    $te_unresv_bw_priority_value & \
                    [info exists te_unresv_bw_priority${i}]]
        }
        if {$te_unresv_bw_priority_value} {
            lappend isis_intf_static_args           \
                    -teUnreservedBwPriority [list   \
                    $te_unresv_bw_priority0         \
                    $te_unresv_bw_priority1         \
                    $te_unresv_bw_priority2         \
                    $te_unresv_bw_priority3         \
                    $te_unresv_bw_priority4         \
                    $te_unresv_bw_priority5         \
                    $te_unresv_bw_priority6         \
                    $te_unresv_bw_priority7         \
                    ]
        }
        
        if {($isis_intf_static_args != "") && ($router_intf_objref != "")} {
            # Modify interface
            set result [ixNetworkNodeSetAttr $router_intf_objref \
                    $isis_intf_static_args]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not modify\
                        interface for router object reference:\
                        $router_objref - [keylget result log]."
                return $returnList
            }
        }
        
        # List of static (non-incrementing) options for ISIS loopback interface
        set staticIsisLoopbackOptions {
            loopback_metric                  metric                default
            loopback_routing_level           level                 translate
            loopback_te_metric               teMetricLevel         default
            loopback_te_admin_group          teAdminGroup          hex
            loopback_te_max_bw               teMaxBandwidth        default
            loopback_te_max_resv_bw          teResMaxBandwidth     default
            loopback_bfd_registration        enableBfdRegistration truth
            loopback_ip_prefix_length        interfaceIpMask       mask
            loopback_ip_addr                 interfaceIp           default
        }
        # Start creating list of static ISIS interface options
        set isis_loop_static_args ""
        
        # Static args: area_authentication_mode, area_password
        # Static args: domain_authentication_mode, domain_password
        if {[info exists loopback_hello_password] && \
                $truth($loopback_hello_password)} {
            if {[info exists routing_level] && \
                    ($routing_level == "L1" || $routing_level == "L1L2")} {
                if {[info exists area_authentication_mode]} {
                    lappend isis_loop_static_args -circuitAuthType \
                            $translate_area_authentication_mode($area_authentication_mode)
                    if {[info exists area_password]} {
                        if {$area_authentication_mode == "text" ||
                                $area_authentication_mode == "md5" } {
                            lappend isis_loop_static_args \
                                    -circuitTransmitPassword \
                                    $area_password
                        }
                        if {$area_authentication_mode == "text"} {
                            lappend isis_loop_static_args \
                                    -circuitReceivedPasswordList \
                                    [list $area_password]
                        }
                    }
                }
            } else {
                if {[info exists domain_authentication_mode]} {
                    lappend isis_loop_static_args -circuitAuthType \
                            $translate_domain_authentication_mode($domain_authentication_mode)
                    if {[info exists domain_password]} {
                        if {$domain_authentication_mode == "text" ||
                                $domain_authentication_mode == "md5" } {
                            lappend isis_loop_static_args \
                                    -circuitTransmitPassword \
                                    $domain_password
                        }
                        if {$domain_authentication_mode == "text"} {
                            lappend isis_loop_static_args \
                                    -circuitReceivedPasswordList \
                                    [list $domain_password]
                        }
                    }
                }
            }
        }
        # Check ISIS loopback options existence and append parameters that exist
        foreach {hltOpt ixnOpt optType} $staticIsisLoopbackOptions {
            if {[info exists $hltOpt]} {
                switch $optType {
                    translate {
                        lappend isis_loop_static_args -$ixnOpt \
                                [set translate_${hltOpt}([set $hltOpt])]
                    }
                    truth {
                        lappend isis_loop_static_args -$ixnOpt \
                                $truth([set $hltOpt])
                    }
                    hex {
                        lappend isis_loop_static_args -$ixnOpt \
                                [format "%x" [set $hltOpt]]
                    }
                    mask {
                        lappend isis_loop_static_args -$ixnOpt \
                                [getIpV4MaskFromWidth [set $hltOpt]]
                    }
                    default {
                        lappend isis_loop_static_args -$ixnOpt \
                                [set $hltOpt]
                    }
                }
            }
        }
        # Param te_unresv_bw_priority
        set loopback_te_unresv_bw_priority_value 0
        for {set i 0} {$i < 8} {incr i} {
            set loopback_te_unresv_bw_priority_value [expr  \
                    $loopback_te_unresv_bw_priority_value & \
                    [info exists loopback_te_unresv_bw_priority${i}]]
        }
        if {$loopback_te_unresv_bw_priority_value} {
            lappend isis_loop_static_args            \
                    -teUnreservedBwPriority [list    \
                    $loopback_te_unresv_bw_priority0 \
                    $loopback_te_unresv_bw_priority1 \
                    $loopback_te_unresv_bw_priority2 \
                    $loopback_te_unresv_bw_priority3 \
                    $loopback_te_unresv_bw_priority4 \
                    $loopback_te_unresv_bw_priority5 \
                    $loopback_te_unresv_bw_priority6 \
                    $loopback_te_unresv_bw_priority7 \
                    ]
        }
        
        if {($isis_loop_static_args != "") && ($router_loop_objref != "")} {
            foreach {router_loop_intf} $router_loop_objref  {
                set result [ixNetworkNodeSetAttr $router_loop_intf \
                            $isis_loop_static_args ]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not modify\
                            loopback parameters for router object\
                            reference: $router_objref - [keylget result log]."
                    return $returnList
                }
            }
        }
        
        
        # Commit
        if {![info exists no_write]} {
            debug "ixNetworkCommit"
            ixNetworkCommit
        }
    }
    
    return $returnList
}

proc ::ixia::ixnetwork_isis_topology_route_config { args man_args opt_args } {
    variable objectMaxCount
    variable truth

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    set handle [ixNet remapIds $handle]
    
    array set translate_link_type [list         \
            broadcast           broadcast       \
            ptop                pointToPoint    \
            ]

    if {$mode == "delete"} {
        if {![info exists elem_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Please specify an elem_handle to delete."
            return $returnList
        }
        set no_ipv4 [catch {keylget elem_handle 4} ipv4_routes]
        set no_ipv6 [catch {keylget elem_handle 6} ipv6_routes]
        if {!$no_ipv4 || !$no_ipv6} {
            if {!$no_ipv4} {
                foreach route $ipv4_routes {
                    debug "ixNetworkRemove $route"
                    ixNetworkRemove $route
                    
                }
            }
            if {!$no_ipv6} {
                foreach route $ipv6_routes {
                    debug "ixNetworkRemove $route"
                    ixNetworkRemove $route
                }
            }
            if {![info exists no_write]} {
                debug "ixNetworkCommit"
                ixNetworkCommit
            }
        } else {
            debug "ixNetworkRemove $elem_handle"
            ixNetworkRemove $elem_handle
            if {![info exists no_write]} {
                debug "ixNetworkCommit"
                ixNetworkCommit
            }
        }
        updateIsisTopologyHandleArray delete $handle $elem_handle 
        keylset returnList status $::SUCCESS
        return $returnList
    }
    if {$mode == "create"} {
        if {![info exists type]} {
            set type_count 0
            if {
                    [info exists link_narrow_metric] || \
                    [info exists link_wide_metric] || \
                    [info exists link_ip_addr] || \
                    [info exists link_ip_prefix_length] || \
                    [info exists link_ip_prefix_length] || \
                    [info exists link_ipv6_addr] || \
                    [info exists link_ipv6_prefix_length] || \
                    [info exists link_enable] || \
                    [info exists link_te] || \
                    [info exists link_te_metric] || \
                    [info exists link_te_max_bw] || \
                    [info exists link_te_max_resv_bw] || \
                    [info exists link_te_unresv_bw_priority0] || \
                    [info exists link_te_unresv_bw_priority1] || \
                    [info exists link_te_unresv_bw_priority2] || \
                    [info exists link_te_unresv_bw_priority3] || \
                    [info exists link_te_unresv_bw_priority4] || \
                    [info exists link_te_unresv_bw_priority5] || \
                    [info exists link_te_unresv_bw_priority6] || \
                    [info exists link_te_unresv_bw_priority7] || \
                    [info exists link_te_admin_group]} {
                set  type router
                incr type_count
            }
            if {
                    [info exists grid_row] || \
                    [info exists grid_col] || \
                    [info exists grid_user_wide_metric] || \
                    [info exists grid_stub_per_router] || \
                    [info exists grid_router_id] || \
                    [info exists grid_router_id_step] || \
                    [info exists grid_link_type] || \
                    [info exists grid_ip_start] || \
                    [info exists grid_ip_pfx_len] || \
                    [info exists grid_ip_step] || \
                    [info exists grid_ipv6_start] || \
                    [info exists grid_ipv6_pfx_len] || \
                    [info exists grid_ipv6_step] || \
                    [info exists grid_start_te_ip] || \
                    [info exists grid_te_ip_step] || \
                    [info exists grid_start_system_id] || \
                    [info exists grid_system_id_step] || \
                    [info exists grid_connect] || \
                    [info exists grid_te] || \
                    [info exists grid_router_metric] || \
                    [info exists grid_router_ip_pfx_len] || \
                    [info exists grid_router_up_down_bit] || \
                    [info exists grid_router_origin] || \
                    [info exists grid_te_metric] || \
                    [info exists grid_te_admin] || \
                    [info exists grid_te_max_bw] || \
                    [info exists grid_te_max_resv_bw] || \
                    [info exists grid_te_unresv_bw_priority0] || \
                    [info exists grid_te_unresv_bw_priority1] || \
                    [info exists grid_te_unresv_bw_priority2] || \
                    [info exists grid_te_unresv_bw_priority3] || \
                    [info exists grid_te_unresv_bw_priority4] || \
                    [info exists grid_te_unresv_bw_priority5] || \
                    [info exists grid_te_unresv_bw_priority6] || \
                    [info exists grid_te_unresv_bw_priority7] || \
                    [info exists grid_interface_metric]} {
                set  type grid
                incr type_count
            }
            if {
                    [info exists stub_ip_start] || \
                    [info exists stub_ip_pfx_len] || \
                    [info exists stub_ip_step] || \
                    [info exists stub_ipv6_start] || \
                    [info exists stub_ipv6_pfx_len] || \
                    [info exists stub_ipv6_step] || \
                    [info exists stub_count] || \
                    [info exists stub_metric] || \
                    [info exists stub_up_down_bit]} {
                set  type stub
                incr type_count
            }
            if {
                    [info exists external_ip_start] || \
                    [info exists external_ip_pfx_len] || \
                    [info exists external_ip_step] || \
                    [info exists external_ipv6_start] || \
                    [info exists external_ipv6_pfx_len] || \
                    [info exists external_ipv6_step] || \
                    [info exists external_count] || \
                    [info exists external_metric] || \
                    [info exists external_up_down_bit]} {
                set  type external
                incr type_count
            }

            if {$type_count == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "Please specify the route type\
                        as one of the following: 'router', 'grid', 'stub' or\
                        'external'."
                return $returnList
            } elseif {$type_count > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "Please specify explicitely\
                        the route type as one of the following: 'router',\
                        'grid', 'stub' or 'external', or use options for\
                        only one of these range types."
                return $returnList
            }
        }
    }
    if {$mode == "modify"} {
        # Remove defaults
        removeDefaultOptionVars $opt_args $args
        
        if {![info exists elem_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "The 'elem_handle' option\
                    must be specified when the 'modify' mode is used."
            return $returnList
        }
		if {![info exists type]} {
			set retCode [getIsisElemInfoFromHandle $handle $elem_handle type]
			if {[keylget retCode status] == $::FAILURE} {
				return $retCode
			}
			set type [keylget retCode value]
		}

    }
    if {($mode == "create") && ![info exists ip_version]} {
        set ip_version 4_6
        keylset returnList version $ip_version
    }
    
    switch $type {
        router {
            # Single router network range
            if {$mode == "modify"} {
                set link_data_array [ixNetworkGetAttr $elem_handle -interfaceIps]
                set ip_version ""
                foreach link_data $link_data_array {
                    if {[lindex $link_data 0] == "ipv4"} {
                        if {![info exists link_ip_addr]} {
                            set link_ip_addr [lindex $link_data 1]
                        }
                        if {![info exists link_ip_prefix_length]} {
                            set link_ip_prefix_length [lindex $link_data 2]
                        }
                        lappend ip_version 4
                    }
                    if {[lindex $link_data 0] == "ipv6"} {
                        if {![info exists link_ipv6_addr]} {
                            set link_ipv6_addr [lindex $link_data 1]
                        }
                        if {![info exists link_ipv6_prefix_length]} {
                            set link_ipv6_prefix_length [lindex $link_data 2]
                        }
                        lappend ip_version 6
                    }
                }
                set ip_version [join [lsort -unique $ip_version] "_"]
                keylset returnList version $ip_version
            }

            # Configure network range
            set router_network_range_args [list \
                    -enabled  true              \
                    -noOfRows 1                 \
                    -noOfCols 1                 \
                    -entryRow 1                 \
                    -entryCol 1                 \
                    -linkType pointToPoint      \
                    ]
            set interface_ip_list [list]

            if {[info exists router_system_id]} {
                lappend router_network_range_args -routerId \
                        $router_system_id
            }
            if {[info exists link_narrow_metric]} {
                lappend router_network_range_args -useWideMetric false
                lappend router_network_range_args -interfaceMetric \
                        $link_narrow_metric
            } elseif {[info exists link_wide_metric]} {
                lappend router_network_range_args -useWideMetric true
                lappend router_network_range_args -interfaceMetric \
                        $link_wide_metric
            }

            # interfaceIPs
            if {$ip_version == "4" || $ip_version == "4_6"} {
                if {![info exists link_ip_addr]} {
                    set link_ip_addr 0.0.0.0
                }
                if {![info exists link_ip_prefix_length]} {
                    set link_ip_prefix_length 24
                }
                lappend interface_ip_list "ipv4 \
                        $link_ip_addr $link_ip_prefix_length"
            }
            if {$ip_version == "6" || $ip_version == "4_6"} {
                if {![info exists link_ipv6_addr]} {
                    set link_ipv6_addr 3000::0
                }
                if {![info exists link_ipv6_prefix_length]} {
                    set link_ipv6_prefix_length 64
                }
                lappend interface_ip_list "ipv6 \
                        $link_ipv6_addr $link_ipv6_prefix_length"
            }
            lappend router_network_range_args \
                    -interfaceIps $interface_ip_list

            if {$mode == "create"} {
                # Add network range
                if {![info exists no_write]} {
                    set result [ixNetworkNodeAdd $handle networkRange \
                            $router_network_range_args -commit]
                } else {
                    set result [ixNetworkNodeAdd $handle networkRange \
                            $router_network_range_args]
                }
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to add a single router\
                            network range to the $handle protocol object\
                            reference - [keylget result log]."
                    return $returnList
                }
                set router_network_range_objref [keylget result node_objref]
            } else {
                # Modify network range
                if {$router_network_range_args != ""} {
                    if {![info exists no_write]} {
                        set result [ixNetworkNodeSetAttr \
                                $elem_handle $router_network_range_args -commit]
                    } else {
                        set result [ixNetworkNodeSetAttr \
                                $elem_handle $router_network_range_args]
                    }
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to modify a single router\
                                network range ${elem_handle}.\
                                [keylget result log]."
                        return $returnList
                    }
                }
                set router_network_range_objref $elem_handle
            }

            # Configure TE range
            set router_network_range_te_args ""
            if {([info exists router_te] && $truth($router_te)) ||
                    ([info exists link_te] && $truth($link_te))} {
                lappend router_network_range_te_args -enableRangeTe true
                if {[info exists router_id]} {
                    lappend router_network_range_te_args -teRouterId \
                            $router_id
                }
                if {[info exists link_te_metric]} {
                    lappend router_network_range_te_args -teLinkMetric \
                            $link_te_metric
                }
                if {[info exists link_te_admin_group]} {
                    lappend router_network_range_te_args -teAdmGroup \
                            $link_te_admin_group
                }
                if {[info exists link_te_max_bw]} {
                    lappend router_network_range_te_args -teMaxBandWidth \
                            $link_te_max_bw
                }
                if {[info exists link_te_max_resv_bw]} {
                    lappend router_network_range_te_args \
                            -teMaxReserveBandWidth $link_te_max_resv_bw
                }
                if {![info exists link_te_unresv_bw_priority0]} {
                    set link_te_unresv_bw_priority0 0
                }
                if {![info exists link_te_unresv_bw_priority1]} {
                    set link_te_unresv_bw_priority1 0
                }
                if {![info exists link_te_unresv_bw_priority2]} {
                    set link_te_unresv_bw_priority2 0
                }
                if {![info exists link_te_unresv_bw_priority3]} {
                    set link_te_unresv_bw_priority3 0
                }
                if {![info exists link_te_unresv_bw_priority4]} {
                    set link_te_unresv_bw_priority4 0
                }
                if {![info exists link_te_unresv_bw_priority5]} {
                    set link_te_unresv_bw_priority5 0
                }
                if {![info exists link_te_unresv_bw_priority6]} {
                    set link_te_unresv_bw_priority6 0
                }
                if {![info exists link_te_unresv_bw_priority7]} {
                    set link_te_unresv_bw_priority7 0
                }
                lappend router_network_range_te_args    \
                        -teUnreservedBandWidth [list    \
                        $link_te_unresv_bw_priority0    \
                        $link_te_unresv_bw_priority1    \
                        $link_te_unresv_bw_priority2    \
                        $link_te_unresv_bw_priority3    \
                        $link_te_unresv_bw_priority4    \
                        $link_te_unresv_bw_priority5    \
                        $link_te_unresv_bw_priority6    \
                        $link_te_unresv_bw_priority7    \
                        ]

                # Add/modify network range
                if {$router_network_range_te_args != ""} {
                    if {![info exists no_write]} {
                        set retCode [ixNetworkNodeSetAttr \
                                $router_network_range_objref/rangeTe \
                                $router_network_range_te_args -commit]
                    } else {
                        set retCode [ixNetworkNodeSetAttr \
                                $router_network_range_objref/rangeTe \
                                $router_network_range_te_args]
                    }
                    if {[keylget retCode status] != $::SUCCESS} {
                        return $retCode
                    }
                }
            }
            keylset returnList elem_handle $router_network_range_objref
            if {$mode == "create"} {
                updateIsisTopologyHandleArray \
                    create $handle $router_network_range_objref $type $ip_version
            }
        }
        grid {
            # Single router network range
            if {$mode == "modify" } {
                set grid_data_array [ixNetworkGetAttr $elem_handle \
                        -interfaceIps]
                set ip_version ""
                foreach grid_data $grid_data_array {
                    if {[lindex $grid_data 0] == "ipv4"} {
                        if {![info exists grid_ip_start]} {
                            set grid_ip_start     [lindex $grid_data 1]
                        }
                        if {![info exists grid_ip_pfx_len]} {
                            set grid_ip_pfx_len   [lindex $grid_data 2]
                        }
                        lappend ip_version 4
                    }
                    if {[lindex $grid_data 0] == "ipv6"} {
                        if {![info exists grid_ipv6_start]} {
                            set grid_ipv6_start   [lindex $grid_data 1]
                        }
                        if {![info exists grid_ipv6_pfx_len]} {
                            set grid_ipv6_pfx_len [lindex $grid_data 2]
                        }
                        lappend ip_version 6
                    }
                }
                set ip_version [join [lsort -unique $ip_version] "_"]
                keylset returnList version $ip_version
            }

            # Configure network range
            set grid_network_range_args [list -enabled true]
            set interface_ip_list [list]

            if {[info exists grid_row]} {
                lappend grid_network_range_args -noOfRows $grid_row
            }
            if {[info exists grid_col]} {
                lappend grid_network_range_args -noOfCols $grid_col
            }
            if {[info exists grid_connect] && \
                    [regexp {(\d)+\s+(\d)+} $grid_connect {} 1 2]} {
                lappend grid_network_range_args -entryRow $1
                lappend grid_network_range_args -entryCol $2
            }
            if {[info exists grid_link_type]} {
                lappend grid_network_range_args -linkType \
                        $translate_link_type($grid_link_type)
            }
            if {[info exists grid_start_system_id]} {
                lappend grid_network_range_args -routerId \
                        $grid_start_system_id
            } elseif {[info exists router_system_id]} {
                lappend grid_network_range_args -routerId \
                        $router_system_id
            }
            if {[info exists grid_system_id_step]} {
                lappend grid_network_range_args -routerIdIncrement \
                        $grid_system_id_step
            }
            if {[info exists grid_user_wide_metric]} {
                lappend grid_network_range_args -useWideMetric \
                        $truth($grid_user_wide_metric)
            }
            if {[info exists grid_interface_metric]} {
                lappend grid_network_range_args -interfaceMetric \
                        $grid_interface_metric
            }

            # interfaceIPs
            set ip_version_index 0
            foreach ip_version_elem $ip_version {
                if {$ip_version_elem == "4" || $ip_version_elem == "4_6"} {
                    set interface_ip_elem ipv4
                    if {![info exists grid_ip_start]} {
                        lappend interface_ip_elem 0.0.0.0
                    } else {
                        if {[lindex $grid_ip_start $ip_version_index] != ""} {
                            lappend interface_ip_elem [lindex $grid_ip_start $ip_version_index]
                        } else {
                            set i 0
                            while {[lindex $grid_ip_start end-$i] == "" && ($i <= [llength $grid_ip_start])} {
                                incr i
                            }
                            lappend interface_ip_elem [lindex $grid_ip_start end-$i]
                        }
                    }
                    if {![info exists grid_ip_pfx_len]} {
                        lappend interface_ip_elem 24
                    } else {
                        if {[lindex $grid_ip_pfx_len $ip_version_index] != ""} {
                            lappend interface_ip_elem [lindex $grid_ip_pfx_len $ip_version_index]
                        } else {
                            set i 0
                            while {[lindex $grid_ip_pfx_len end-$i] == "" && ($i <= [llength $grid_ip_pfx_len])} {
                                incr i
                            }
                            lappend interface_ip_elem [lindex $grid_ip_pfx_len end-$i]
                        }
                    }
                    lappend interface_ip_list $interface_ip_elem
                }
                if {$ip_version_elem == "6" || $ip_version_elem == "4_6"} {
                    set interface_ip_elem ipv6
                    if {![info exists grid_ipv6_start]} {
                        lappend interface_ip_elem 3000::0
                    } else {
                        if {[lindex $grid_ipv6_start $ip_version_index] != ""} {
                            lappend interface_ip_elem [lindex $grid_ipv6_start $ip_version_index]
                        } else {
                            set i 0
                            while {[lindex $grid_ipv6_start end-$i] == "" && ($i <= [llength $grid_ipv6_start])} {
                                incr i
                            }
                            lappend interface_ip_elem [lindex $grid_ipv6_start end-$i]
                        }
                    }
                    if {![info exists grid_ipv6_pfx_len]} {
                        lappend interface_ip_elem 64
                    } else {
                        if {[lindex $grid_ipv6_pfx_len $ip_version_index] != ""} {
                            lappend interface_ip_elem [lindex $grid_ipv6_pfx_len $ip_version_index]
                        } else {
                            set i 0
                            while {[lindex $grid_ipv6_pfx_len end-$i] == "" && ($i <= [llength $grid_ipv6_pfx_len])} {
                                incr i
                            }
                            lappend interface_ip_elem [lindex $grid_ipv6_pfx_len end-$i]
                        }
                    }
                    lappend interface_ip_list $interface_ip_elem
                }
            }
            lappend grid_network_range_args \
                    -interfaceIps $interface_ip_list

            # gridNodeRoutes
            set gnr_entry_list ""
            if {![info exists grid_router_count]} { set grid_router_count 0}
            for {set gnr_i 0} {$gnr_i < $grid_router_count} {incr gnr_i} {
                set gnr_entry "true"
                if {![info exists grid_router_ip_version]} {
                    lappend gnr_entry ipv4
                } else {
                    if {[lindex $grid_router_ip_version $gnr_i] == "4"} {
                        lappend gnr_entry ipv4
                    } elseif {[lindex $grid_router_ip_version $gnr_i] == "6"} {
                        lappend gnr_entry ipv6
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Invalid value\
                                ({[lindex $grid_router_ip_version $gnr_i]}) for\
                                parameter -grid_router_ip_version.\
                                [keylget result log]."
                        return $returnList
                    }
                }
                set gnr_entry_ip_version [lindex $gnr_entry end]
                if {$gnr_entry_ip_version == "ipv4"} {
                    if {![info exists grid_router_id]} {
                        lappend gnr_entry 0.0.0.0
                    } else {
                        if {[lindex $grid_router_id $gnr_i] == ""} {
                            lappend gnr_entry 0.0.0.0
                        } else {
                            if {[isIpAddressValid [lindex $grid_router_id $gnr_i]]} {
                                lappend gnr_entry [lindex $grid_router_id $gnr_i]
                            } else {
                                lappend gnr_entry [::ixia::convert_v6_addr_to_v4 [lindex $grid_router_id $gnr_i]]
                            }
                        }
                    }
                } else {
                    if {![info exists grid_router_id]} {
                        lappend gnr_entry 0::0
                    } else {
                        if {[lindex $grid_router_id $gnr_i] == ""} {
                            lappend gnr_entry 0::0
                        } else {
                            if {[isIpAddressValid [lindex $grid_router_id $gnr_i]]} {
                                lappend gnr_entry [::ixia::convert_v4_addr_to_v6 [lindex $grid_router_id $gnr_i]]
                            } else {
                                lappend gnr_entry [lindex $grid_router_id $gnr_i]
                            }
                        }
                    }
                }
                if {![info exists grid_stub_per_router]} {
                    lappend gnr_entry 1
                } else {
                    if {[lindex $grid_stub_per_router $gnr_i] == ""} {
                        lappend gnr_entry 1
                    } else {
                        lappend gnr_entry [lindex $grid_stub_per_router $gnr_i]
                    }
                }
                if {$gnr_entry_ip_version == "ipv4"} {
                    if {![info exists grid_router_ip_pfx_len]} {
                        lappend gnr_entry 24
                    } else {
                        if {[lindex $grid_router_ip_pfx_len $gnr_i] == ""} {
                            lappend gnr_entry 24
                        } else {
                            lappend gnr_entry [lindex $grid_router_ip_pfx_len $gnr_i]
                        }
                    }
                } else {
                    if {![info exists grid_router_ip_pfx_len]} {
                        lappend gnr_entry 64
                    } else {
                        if {[lindex $grid_router_ip_pfx_len $gnr_i] == ""} {
                            lappend gnr_entry 64
                        } else {
                            lappend gnr_entry [lindex $grid_router_ip_pfx_len $gnr_i]
                        }
                    }
                }
                set gnr_entry_router_ip_pfx_len [lindex $gnr_entry end]
                if {![info exists grid_router_route_step]} {
                    lappend gnr_entry 1
                } else {
                    if {[lindex $grid_router_route_step $gnr_i] == ""} {
                        lappend gnr_entry 1
                    } else {
                        lappend gnr_entry [lindex $grid_router_route_step $gnr_i]
                    }
                }
                if {![info exists grid_router_metric]} {
                    lappend gnr_entry 0
                } else {
                    if {[lindex $grid_router_metric $gnr_i] == ""} {
                        lappend gnr_entry 0
                    } else {
                        lappend gnr_entry [lindex $grid_router_metric $gnr_i]
                    }
                }
                if {![info exists grid_router_origin]} {
                    lappend gnr_entry false
                } else {
                    if {[lindex $grid_router_origin $gnr_i] == ""} {
                        lappend gnr_entry false
                    } elseif {[lindex $grid_router_origin $gnr_i] == "stub"} {
                        lappend gnr_entry false
                    } else {
                        lappend gnr_entry true
                    }
                }
                if {![info exists grid_router_up_down_bit]} {
                    lappend gnr_entry false
                } else {
                    if {[lindex $grid_router_up_down_bit $gnr_i] == ""} {
                        lappend gnr_entry false
                    } elseif {[lindex $grid_router_up_down_bit $gnr_i] == 1} {
                        lappend gnr_entry false
                    } else {
                        lappend gnr_entry true
                    }
                }
                if {![info exists grid_router_id_step]} {
                    lappend gnr_entry 256
                } else {
                    if {[lindex $grid_router_id_step $gnr_i] == ""} {
                        lappend gnr_entry 256
                    } else {
                        # Use this because the node route ranges take a numeric
                        # step instead of an IP address step.
                        if {$gnr_entry_ip_version == "ipv4"} {
                            lappend gnr_entry [expr \
                                    [::ixia::ip_addr_to_num [lindex $grid_router_id_step $gnr_i]] \
                                    >> [expr 32 - $gnr_entry_router_ip_pfx_len]]
                        } else {
                            lappend gnr_entry [expr \
                                    [::ixia::ip_addr_to_num [lindex $grid_router_id_step $gnr_i]] \
                                    >> [expr 128 - $gnr_entry_router_ip_pfx_len]]
                        }
                    }
                }
                lappend gnr_entry_list $gnr_entry
            }
            
            lappend grid_network_range_args -gridNodeRoutes $gnr_entry_list
			
			#Adding outside link Support
			if { $grid_outside_link } {
            
				set  link_index 0
				set outsideExLinkList {}
				if { ![ info exists grid_ol_connection_row ] } {
					set grid_ol_connection_row 1
				}
				foreach row $grid_ol_connection_row {
					set link_params_list {}
					lappend link_params_list $row
		
					if { [ info exists grid_ol_connection_col ] && [llength $grid_ol_connection_col] > $link_index } {
						set  col [lindex $grid_ol_connection_col $link_index]
					} elseif {![info exists col]} {
						set col 1	;#DEFAULT
					}
					lappend link_params_list $col
					
					if { [ info exists grid_ol_linked_rid ] && [llength $grid_ol_linked_rid] > $link_index } {
						set  rid_input [lindex $grid_ol_linked_rid $link_index]
						if {[string first 0x $rid_input] == -1} {
							set router_id [format "0x%s" $rid_input]
						}
						set router_id [val2Bytes $router_id 6]
					} elseif {![info exists router_id]} {
						set router_id {00 00 00 00 00 00}	;#DEFAULT
					}
					lappend link_params_list  	$router_id
                    
					###### MULTIPLE IPv4/IPv6 Addresses can be added to a single outside link.
					set IP_list {}
					if { [ info exists grid_ol_ip_and_prefix ] && [llength $grid_ol_ip_and_prefix] > $link_index } {
						set ip_set [lindex $grid_ol_ip_and_prefix $link_index]
						foreach ip_prefix [split  $ip_set ","] {
							if {[isValidIPv4AddressAndPrefix $ip_prefix]} {
								set ip_prefix_list [split $ip_prefix "/"]
								lappend IP_list [list ipv4 [lindex $ip_prefix_list 0] [lindex $ip_prefix_list 1]]
							} elseif {[isValidIPv6AddressAndPrefix $ip_prefix]} {
								set ip_prefix_list [split $ip_prefix "/"]
								lappend IP_list [list ipv6 [lindex $ip_prefix_list 0] [lindex $ip_prefix_list 1]]
							} else {
								#Adding default values
								lappend IP_list {ipv4 0.0.0.0 24}
							}			
											
						}
					} else {
						#Adding default values
						lappend IP_list {ipv4 0.0.0.0 24}
					}
					lappend link_params_list  	$IP_list

					if { [ info exists grid_ol_admin_group ] && [llength $grid_ol_admin_group] > $link_index } {
						set  rid_input [lindex $grid_ol_admin_group $link_index]
						if {[string first 0x $rid_input] == -1} {
							set adm_grp [format "0x%s" $rid_input]
						}
						set adm_grp [val2Bytes $adm_grp 4]
					} elseif {![info exists adm_grp]} {
						set adm_grp {00 00 00 00}	;#DEFAULT
					}
					lappend link_params_list  	$adm_grp
					
					if { [ info exists grid_ol_metric ] && [llength $grid_ol_metric] > $link_index } {
						set  metric [lindex $grid_ol_metric $link_index]
					} elseif {![info exists metric]} {
						set metric 0	;#DEFAULT
					}
					lappend link_params_list    $metric
					
					if { [ info exists grid_ol_max_bw ] && [llength $grid_ol_max_bw] > $link_index } {
						set  max_bw [lindex $grid_ol_max_bw $link_index]
					} elseif {![info exists max_bw]} {
						set max_bw 0	;#DEFAULT
					}
					lappend link_params_list    $max_bw
					
					if { [ info exists grid_ol_max_resv_bw ] && [llength $grid_ol_max_resv_bw] > $link_index } {
						set  max_res_bw [lindex $grid_ol_max_resv_bw $link_index]
					} elseif {![info exists max_res_bw]} {
						set max_res_bw 0	;#DEFAULT
					}
					lappend link_params_list    $max_res_bw
					
					#Adding ureserved bw priority bits in loop
					for {set i 0} { $i <=7 } { incr i} {
						set curret_var "grid_ol_unresv_bw_priority$i"
						if { [ info exists $curret_var ] && [llength [set $curret_var] ] > 0 } {
							set  unres_bw [lindex [set $curret_var] $link_index]
						} elseif {![info exists unres_bw]} {
							set unres_bw 0	;#DEFAULT
						}
						lappend link_params_list $unres_bw

					}

					lappend outsideExLinkList $link_params_list					
					incr link_index					
				}
				#puts "outsideExLinkList=$outsideExLinkList"
				lappend grid_network_range_args -gridOutsideExLinks $outsideExLinkList				
				#lappend grid_network_range_args -gridOutsideExLinks {{1 1 {32 32 32 32 32 32} {{ipv4 123.1.1.1 30}} {00 00 00 00} 0 1250000000 1250000000 1250000000 1250000000 1250000000 1250000000 1250000000 1250000000 1250000000 1250000000}}
			}
			
            if {$mode == "create"} {
                # Add network range
                if {![info exists no_write]} {
                    set result [ixNetworkNodeAdd $handle networkRange \
                            $grid_network_range_args -commit]
                } else {
                    set result [ixNetworkNodeAdd $handle networkRange \
                            $grid_network_range_args]
                }
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to add a router grid\
                            network range to the $handle protocol object\
                            reference - [keylget result log]."
                    return $returnList
                }
                set grid_network_range_objref [keylget result node_objref]
            } else {
                # Modify network range
                if {$grid_network_range_args != ""} {
                    if {![info exists no_write]} {
                        set result [ixNetworkNodeSetAttr $elem_handle \
                                $grid_network_range_args -commit]
                    } else {
                        set result [ixNetworkNodeSetAttr $elem_handle \
                                $grid_network_range_args]
                    }
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to modify grid\
                                ${elem_handle}. [keylget result log]."
                        return $returnList
                    }
                }
                set grid_network_range_objref $elem_handle
            }

            # Configure TE range
            set grid_network_range_te_args ""
            if {[info exists router_te] || [info exists grid_te]} {
                set enableRangeTe 0
                if {[info exists router_te]} {
                    set enableRangeTe [expr $router_te | $enableRangeTe]
                }
                if {[info exists grid_te]} {
                    set enableRangeTe [expr $grid_te | $enableRangeTe]
                }
                
                lappend grid_network_range_te_args -enableRangeTe $truth($enableRangeTe)
                if {[info exists grid_start_te_ip]} {
                    lappend grid_network_range_te_args -teRouterId \
                            $grid_start_te_ip
                } elseif {[info exists router_id]} {
                    lappend grid_network_range_te_args -teRouterId \
                            $router_id
                }
                if {[info exists grid_te_ip_step]} {
                    lappend grid_network_range_te_args \
                            -teRouterIdIncrement $grid_te_ip_step
                }
  
                if {[info exists grid_te_admin]} {
                    lappend grid_network_range_te_args -teAdmGroup \
                            [::ixia::val2Bytes $grid_te_admin 4]
                }
                if {[info exists grid_te_max_bw]} {
                    lappend grid_network_range_te_args -teMaxBandWidth \
                            $grid_te_max_bw
                }
                if {[info exists grid_te_max_resv_bw]} {
                    lappend grid_network_range_te_args \
                            -teMaxReserveBandWidth $grid_te_max_resv_bw
                }
                if {![info exists grid_te_unresv_bw_priority0]} {
                    set grid_te_unresv_bw_priority0 0
                }
                if {![info exists grid_te_unresv_bw_priority1]} {
                    set grid_te_unresv_bw_priority1 0
                }
                if {![info exists grid_te_unresv_bw_priority2]} {
                    set grid_te_unresv_bw_priority2 0
                }
                if {![info exists grid_te_unresv_bw_priority3]} {
                    set grid_te_unresv_bw_priority3 0
                }
                if {![info exists grid_te_unresv_bw_priority4]} {
                    set grid_te_unresv_bw_priority4 0
                }
                if {![info exists grid_te_unresv_bw_priority5]} {
                    set grid_te_unresv_bw_priority5 0
                }
                if {![info exists grid_te_unresv_bw_priority6]} {
                    set grid_te_unresv_bw_priority6 0
                }
                if {![info exists grid_te_unresv_bw_priority7]} {
                    set grid_te_unresv_bw_priority7 0
                }
                lappend grid_network_range_te_args      \
                        -teUnreservedBandWidth [list    \
                        $grid_te_unresv_bw_priority0    \
                        $grid_te_unresv_bw_priority1    \
                        $grid_te_unresv_bw_priority2    \
                        $grid_te_unresv_bw_priority3    \
                        $grid_te_unresv_bw_priority4    \
                        $grid_te_unresv_bw_priority5    \
                        $grid_te_unresv_bw_priority6    \
                        $grid_te_unresv_bw_priority7    \
                        ]

                if {$grid_network_range_te_args != ""} {
                    if {![info exists no_write]} {
                        set retCode [ixNetworkNodeSetAttr \
                                $grid_network_range_objref/rangeTe \
                                $grid_network_range_te_args -commit]
                    } else {
                        set retCode [ixNetworkNodeSetAttr \
                                $grid_network_range_objref/rangeTe \
                                $grid_network_range_te_args]
                    }
                    if {[keylget retCode status] != $::SUCCESS} {
                        return $retCode
                    }
                }
                
                if {[info exists grid_te_metric]} {
                    if {![info exists no_write]} {
                        set retCode [ixNetworkNodeSetAttr \
                            $grid_network_range_objref/rangeTe \
                            [list -teLinkMetric $grid_te_metric] -commit]
                    } else {
                        set retCode [ixNetworkNodeSetAttr \
                            $grid_network_range_objref/rangeTe \
                            [list -teLinkMetric $grid_te_metric]]
                    }
                }
            }
            # Configure TE entry
            set grid_network_range_entry_te_args ""
            if {[info exists grid_te_override_enable]} {
                lappend grid_network_range_entry_te_args -enableEntryTe $truth($grid_te_override_enable)
                
                if {[info exists grid_te_override_metric]} {
                    lappend grid_network_range_entry_te_args -eteLinkMetric \
                            $grid_te_override_metric
                }
                if {[info exists grid_te_override_admin]} {
                    lappend grid_network_range_entry_te_args -eteAdmGroup \
                            [::ixia::val2Bytes $grid_te_override_admin 4]
                }
                if {[info exists grid_te_override_max_bw]} {
                    lappend grid_network_range_entry_te_args -eteMaxBandWidth \
                            $grid_te_override_max_bw
                }
                if {[info exists grid_te_override_max_resv_bw]} {
                    lappend grid_network_range_entry_te_args \
                            -eteMaxReserveBandWidth $grid_te_override_max_resv_bw
                }
                if {![info exists grid_te_override_unresv_bw_priority0]} {
                    set grid_te_override_unresv_bw_priority0 0
                }
                if {![info exists grid_te_override_unresv_bw_priority1]} {
                    set grid_te_override_unresv_bw_priority1 0
                }
                if {![info exists grid_te_override_unresv_bw_priority2]} {
                    set grid_te_override_unresv_bw_priority2 0
                }
                if {![info exists grid_te_override_unresv_bw_priority3]} {
                    set grid_te_override_unresv_bw_priority3 0
                }
                if {![info exists grid_te_override_unresv_bw_priority4]} {
                    set grid_te_override_unresv_bw_priority4 0
                }
                if {![info exists grid_te_override_unresv_bw_priority5]} {
                    set grid_te_override_unresv_bw_priority5 0
                }
                if {![info exists grid_te_override_unresv_bw_priority6]} {
                    set grid_te_override_unresv_bw_priority6 0
                }
                if {![info exists grid_te_override_unresv_bw_priority7]} {
                    set grid_te_override_unresv_bw_priority7 0
                }
                lappend grid_network_range_entry_te_args      \
                        -eteUnreservedBandWidth [list    \
                        $grid_te_override_unresv_bw_priority0    \
                        $grid_te_override_unresv_bw_priority1    \
                        $grid_te_override_unresv_bw_priority2    \
                        $grid_te_override_unresv_bw_priority3    \
                        $grid_te_override_unresv_bw_priority4    \
                        $grid_te_override_unresv_bw_priority5    \
                        $grid_te_override_unresv_bw_priority6    \
                        $grid_te_override_unresv_bw_priority7    \
                        ]

                if {$grid_network_range_entry_te_args != ""} {
                    if {![info exists no_write]} {
                        set retCode [ixNetworkNodeSetAttr \
                                $grid_network_range_objref/entryTe \
                                $grid_network_range_entry_te_args -commit]
                    } else {
                        set retCode [ixNetworkNodeSetAttr \
                                $grid_network_range_objref/entryTe \
                                $grid_network_range_entry_te_args]
                    }
                    if {[keylget retCode status] != $::SUCCESS} {
                        return $retCode
                    }
                }
            }
            
            # Configure TE path
            if {[info exists grid_te_path_count] && $grid_te_path_count > 0} {
                set grid_network_range_path_te_args ""
                for {set te_path_i 0} {$te_path_i < $grid_te_path_count} {incr te_path_i} {
                    set grid_network_range_path_te_elem ""
                    # 1
                    if {[info exists grid_te_path_start_row]} {
                        lappend grid_network_range_path_te_elem \
                                [lindex $grid_te_path_start_row $te_path_i]
                    } else {
                        lappend grid_network_range_path_te_elem 1
                    }
                    # 2
                    if {[info exists grid_te_path_start_col]} {
                        lappend grid_network_range_path_te_elem \
                                [lindex $grid_te_path_start_col $te_path_i]
                    } else {
                        lappend grid_network_range_path_te_elem 1
                    }
                    # 3
                    if {[info exists grid_te_path_end_row]} {
                        lappend grid_network_range_path_te_elem \
                                [lindex $grid_te_path_end_row $te_path_i]
                    } else {
                        lappend grid_network_range_path_te_elem 1
                    }
                    # 4
                    if {[info exists grid_te_path_end_col]} {
                        lappend grid_network_range_path_te_elem \
                                [lindex $grid_te_path_end_col $te_path_i]
                    } else {
                        lappend grid_network_range_path_te_elem 1
                    }
                    # 5
                    if {[info exists grid_te_path_row_step]} {
                        lappend grid_network_range_path_te_elem \
                                [lindex $grid_te_path_row_step $te_path_i]
                    } else {
                        lappend grid_network_range_path_te_elem 0
                    }
                    # 6
                    if {[info exists grid_te_path_col_step]} {
                        lappend grid_network_range_path_te_elem \
                                [lindex $grid_te_path_col_step $te_path_i]
                    } else {
                        lappend grid_network_range_path_te_elem 0
                    }
                    # 7
                    if {[info exists grid_te_path_bidir]} {
                        lappend grid_network_range_path_te_elem \
                                $truth([lindex $grid_te_path_bidir $te_path_i])
                    } else {
                        lappend grid_network_range_path_te_elem True
                    }
                    # 8
                    if {[info exists grid_te_path_admin]} {
                        lappend grid_network_range_path_te_elem \
                                [::ixia::val2Bytes [lindex $grid_te_path_admin $te_path_i] 4]
                    } else {
                        lappend grid_network_range_path_te_elem \
                                {00 00 00 00}
                    }
                    # 9
                    if {[info exists grid_te_path_metric]} {
                        lappend grid_network_range_path_te_elem \
                                [lindex $grid_te_path_metric $te_path_i]
                    } else {
                        lappend grid_network_range_path_te_elem 0
                    }
                    # 10
                    if {[info exists grid_te_path_max_bw]} {
                        lappend grid_network_range_path_te_elem  \
                                [lindex $grid_te_path_max_bw $te_path_i]
                    } else {
                        lappend grid_network_range_path_te_elem  0
                    }
                    # 11
                    if {[info exists grid_te_path_max_resv_bw]} {
                        lappend grid_network_range_path_te_elem \
                                [lindex $grid_te_path_max_resv_bw $te_path_i]
                    } else {
                        lappend grid_network_range_path_te_elem  0
                    }
                    # 12
                    if {![info exists grid_te_path_unresv_bw_priority0]} {
                        lappend grid_network_range_path_te_elem 0
                    } else {
                        lappend grid_network_range_path_te_elem [lindex $grid_te_path_unresv_bw_priority0 $te_path_i]
                    }
                    if {![info exists grid_te_path_unresv_bw_priority1]} {
                        lappend grid_network_range_path_te_elem 0
                    } else {
                        lappend grid_network_range_path_te_elem [lindex $grid_te_path_unresv_bw_priority1 $te_path_i]
                    }
                    if {![info exists grid_te_path_unresv_bw_priority2]} {
                        lappend grid_network_range_path_te_elem 0
                    } else {
                        lappend grid_network_range_path_te_elem [lindex $grid_te_path_unresv_bw_priority2 $te_path_i]
                    }
                    if {![info exists grid_te_path_unresv_bw_priority3]} {
                        lappend grid_network_range_path_te_elem 0
                    } else {
                        lappend grid_network_range_path_te_elem [lindex $grid_te_path_unresv_bw_priority3 $te_path_i]
                    }
                    if {![info exists grid_te_path_unresv_bw_priority4]} {
                        lappend grid_network_range_path_te_elem 0
                    } else {
                        lappend grid_network_range_path_te_elem [lindex $grid_te_path_unresv_bw_priority4 $te_path_i]
                    }
                    if {![info exists grid_te_path_unresv_bw_priority5]} {
                        lappend grid_network_range_path_te_elem 0
                    } else {
                        lappend grid_network_range_path_te_elem [lindex $grid_te_path_unresv_bw_priority5 $te_path_i]
                    }
                    if {![info exists grid_te_path_unresv_bw_priority6]} {
                        lappend grid_network_range_path_te_elem 0
                    } else {
                        lappend grid_network_range_path_te_elem [lindex $grid_te_path_unresv_bw_priority6 $te_path_i]
                    }
                    if {![info exists grid_te_path_unresv_bw_priority7]} {
                        lappend grid_network_range_path_te_elem 0
                    } else {
                        lappend grid_network_range_path_te_elem [lindex $grid_te_path_unresv_bw_priority7 $te_path_i]
                    }
                    
                    lappend grid_network_range_path_te_args $grid_network_range_path_te_elem
                }
                if {$grid_network_range_path_te_args != ""} {
                    set grid_network_range_path_te_params ""
                    lappend grid_network_range_path_te_params -tePaths $grid_network_range_path_te_args
                    if {![info exist no_write]} {
                        set retCode [ixNetworkNodeSetAttr \
                                $grid_network_range_objref \
                                $grid_network_range_path_te_params -commit]
                    } else {
                        set retCode [ixNetworkNodeSetAttr \
                                $grid_network_range_objref \
                                $grid_network_range_path_te_params]
                    }
                    if {[keylget retCode status] != $::SUCCESS} {
                        return $retCode
                    }
                }
            }
            
            keylset returnList elem_handle $grid_network_range_objref
            catch {
                keylset returnList grid.connected_session.$handle.row $grid_row
            }
            catch {
                keylset returnList grid.connected_session.$handle.col $grid_col
            }
            if {$mode == "create"} {
                updateIsisTopologyHandleArray \
                    create $handle $grid_network_range_objref $type $ip_version
            }
        }
        stub -
        external {
            # Stub or external route range
            # Functional note: the returned elem_handle is a keyed list 
            # containing the IPv4 and IPv6 lists of created routes.
            # The structure is the following:
            # elem_handle {
            #     {4 {$type_ipv4_route_list}}
            #     {6 {$type_ipv4_route_list}}
            # }

            # Remove the old $type range
            if {$mode == "modify"} {
                set no_ipv4 [catch {keylget elem_handle 4} ipv4_routes]
                set no_ipv6 [catch {keylget elem_handle 6} ipv6_routes]
                
                if {!$no_ipv4 && !$no_ipv6 && $ipv4_routes != "" && $ipv6_routes != ""} {
                    set ip_version 4_6
                } elseif {!$no_ipv4} {
                    set ip_version 4
                } elseif {!$no_ipv6} {
                    set ip_version 6
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The $elem_handle object\
                            reference is not a valid $type range handle."
                    return $returnList
                }
                keylset returnList version $ip_version
                
                if {$ip_version == "4" || $ip_version == "4_6"} {
                    if {![info exists ${type}_ip_start] && !$no_ipv4} {
                        set ${type}_ip_start [ixNetworkGetAttr \
                                [lindex $ipv4_routes 0] -firstRoute]
                    }
                    if {![info exists ${type}_ip_pfx_len] && !$no_ipv4} {
                        set ${type}_ip_pfx_len [ixNetworkGetAttr \
                                [lindex $ipv4_routes 0] -maskWidth]
                    }
                }

                if {$ip_version == "6" || $ip_version == "4_6"} {
                    if {![info exists ${type}_ipv6_start] && !$no_ipv6} {
                        set ${type}_ipv6_start [ixNetworkGetAttr \
                                [lindex $ipv6_routes 0] -firstRoute]
                    }
                    if {![info exists ${type}_ipv6_pfx_len] && !$no_ipv6} {
                        set ${type}_ipv6_pfx_len [ixNetworkGetAttr \
                                [lindex $ipv6_routes 0] -maskWidth]
                    }
                }

                if {![info exists ${type}_count]} {
                    if {!$no_ipv4} {
                        set ${type}_count [llength $ipv4_routes]
                    } elseif {!$no_ipv6} {
                        set ${type}_count [llength $ipv6_routes]
                    }
                }
                if {!$no_ipv4} {
                    foreach route $ipv4_routes {
                        debug "ixNetworkRemove $route"
                        ixNetworkRemove $route
                    }
                }
                if {!$no_ipv6} {
                    foreach route $ipv6_routes {
                        debug "ixNetworkRemove $route"
                        ixNetworkRemove $route
                    }
                }
                if {!$no_ipv4 || !$no_ipv6} {
                    if {![info exists no_write]} {
                        debug "ixNetworkCommit"
                        ixNetworkCommit
                    }
                }
            }

            # Create the new $type range
            set objectCount    0
            set ipv4_route_list [list]
            set ipv6_route_list [list]
            if {$type == "external" && ![info exists external_count]} {
                set external_count 1
            } elseif {$type == "stub" && ![info exists stub_count]} {
                set stub_count 1
            }
            if {$type == "external" && ![info exists external_route_count]} {
                set external_route_count 1
            } elseif {$type == "stub" && ![info exists stub_route_count]} {
                set stub_route_count 1
            }
            
            # Check IPv6 address
            if {![info exists ${type}_ipv6_step]} {
                set ${type}_ipv6_step 0:0:0:1::0
            } else  {
                if {![::ipv6::isValidAddress \
                        [subst $${type}_ipv6_step]]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid external\
                            route step."
                    return $returnList
                }
            }
            
            if {[info exists ${type}_ipv6_start]} {
                set ${type}_ipv6_start [::ixia::expand_ipv6_addr \
                        [subst $${type}_ipv6_start]]
            }
            if {[info exists ${type}_ipv6_step]} {
                set ${type}_ipv6_step [::ixia::expand_ipv6_addr \
                        [subst $${type}_ipv6_step]]
            }
            
            for {set i 0} {$i < [subst $${type}_count]} {incr i} {
                if {$ip_version == "4" || $ip_version == "4_6"} {
                    # Create the IPv4 attributes list
                    set ipv4_route_range_args [list                      \
                            -enabled        true                         \
                            -numberOfRoutes [subst $${type}_route_count] \
                            -type           ipv4                         \
                            ]

                    if {$type == "stub"} {
                        lappend ipv4_route_range_args -routeOrigin false
                    } else {
                        lappend ipv4_route_range_args -routeOrigin true
                    }
                    if {[info exists ${type}_ip_start]} {
                        lappend ipv4_route_range_args -firstRoute \
                                [subst $${type}_ip_start]
                    }
                    if {[info exists ${type}_ip_pfx_len]} {
                        lappend ipv4_route_range_args -maskWidth \
                                [subst $${type}_ip_pfx_len]
                    }
                    if {[info exists ${type}_metric]} {
                        lappend ipv4_route_range_args -metric \
                                [subst $${type}_metric]
                    }
                    if {[info exists ${type}_up_down_bit]} {
                        # Use !$truth() because in HLT the UP/DOWN (1/0) is 
                        # given but, in IxN, isRedistributed (false/true) is 
                        # used.
                        if {$truth([subst $${type}_up_down_bit])} {
                            lappend ipv4_route_range_args \
                                    -isRedistributed false
                        } else {
                            lappend ipv4_route_range_args \
                                    -isRedistributed true
                        }
                    }

                    # Create the IPv4 route range
                    set result [ixNetworkNodeAdd $handle routeRange \
                            $ipv4_route_range_args]
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to add an IPv4\
                                external route range to the $handle\
                                protocol object reference -\
                                [keylget result log]."
                        return $returnList
                    }
                    lappend ipv4_route_list [keylget result node_objref]
                    # Commit
                    incr objectCount
                    if {![info exists no_write] && [expr $objectCount % $objectMaxCount] == 0} {
                        debug "ixNetworkCommit"
                        ixNetworkCommit
                    }

                    # Increment IPv4 address
                    if {![info exists ${type}_ip_step]} {
                        if {[info exists ${type}_ip_pfx_len]} {
                            set ${type}_ip_step [::ixia::num_to_ip_addr \
                                    [expr 1 << [expr 32 - [subst \
                                    $${type}_ip_pfx_len]]] 4]
                        } else {
                            set ${type}_ip_step 0.0.1.0
                        }
                    } else  {
                        if {![::isIpAddressValid [subst $${type}_ip_step]]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Invalid external\
                                    route step."
                            return $returnList
                        }
                    }

                    set ${type}_ip_start \
                            [::ixia::incr_ipv4_addr   \
                            [subst $${type}_ip_start] \
                            [subst $${type}_ip_step]]
                }

                if {$ip_version == "6" || $ip_version == "4_6"} {
                    # Create the IPv6 attributes list
                    set ipv6_route_range_args [list                      \
                            -enabled        true                         \
                            -numberOfRoutes [subst $${type}_route_count] \
                            -type           ipv6                         \
                            ]
                    
                    if {$type == "stub"} {
                        lappend ipv6_route_range_args -routeOrigin false
                    } else {
                        lappend ipv6_route_range_args -routeOrigin true
                    }
                    if {[info exists ${type}_ipv6_start]} {
                        lappend ipv6_route_range_args -firstRoute \
                                [subst $${type}_ipv6_start]
                    }
                    if {[info exists ${type}_ipv6_pfx_len]} {
                        lappend ipv6_route_range_args -maskWidth \
                                [subst $${type}_ipv6_pfx_len]
                    }
                    if {[info exists ${type}_metric]} {
                        lappend ipv6_route_range_args -metric \
                                [subst $${type}_metric]
                    }
                    if {[info exists ${type}_up_down_bit]} {
                        # idem. IPv4
                        if {$truth([subst $${type}_up_down_bit])} {
                            lappend ipv6_route_range_args \
                                    -isRedistributed false
                        } else {
                            lappend ipv6_route_range_args \
                                    -isRedistributed true
                        }
                                
                    }

                    # Create the IPv6 route range
                    set result [ixNetworkNodeAdd $handle routeRange \
                            $ipv6_route_range_args]
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to add an IPv6\
                                external route range to the $handle\
                                protocol object reference -\
                                [keylget result log]."
                        return $returnList
                    }
                    lappend ipv6_route_list [keylget result node_objref]
                    
                    # Commit
                    incr objectCount
                    if {![info exists no_write] && [expr $objectCount % $objectMaxCount] == 0} {
                        debug "ixNetworkCommit"
                        ixNetworkCommit
                    }
                    
                    set ${type}_ipv6_start \
                            [::ixia::incr_ipv6_addr     \
                            [subst $${type}_ipv6_start] \
                            [subst $${type}_ipv6_step]]
                }
            }
            
            # Commit
            if {![info exists no_write] && [expr $objectCount % $objectMaxCount] != 0} {
                debug "ixNetworkCommit"
                ixNetworkCommit
            }
            if {$ipv4_route_list != ""} {
                set ipv4_route_list [ixNet remapIds $ipv4_route_list]
            }
            if {$ipv6_route_list != ""} {
                set ipv6_route_list [ixNet remapIds $ipv6_route_list]
            }
            
            keylset route_range 4 $ipv4_route_list
            keylset route_range 6 $ipv6_route_list
            keylset returnList elem_handle $route_range
            keylset returnList $type.num_networks [subst $${type}_count]
            if {$mode == "create"} {
                updateIsisTopologyHandleArray \
                    create $handle $route_range $type $ip_version
            }
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixnetwork_isis_control { args man_args opt_args } {
    variable truth

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    keylset returnList status $::SUCCESS

    if {![info exists port_handle] && ![info exists handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Neither 'port_handle' nor 'handle'\
                options have been specified. Please specify at least one of\
                the 'port_handle' or 'handle' options."
        return $returnList
    }
    if {[info exists port_handle]} {
        set protocol_objref_list [list]
        foreach item $port_handle {
            set result [ixNetworkGetPortObjref $item]
            if {[keylget result status] == $::FAILURE} {
                if {![info exists handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to find the port object\
                            reference associated to the $item port handle -\
                            [keylget result log]."
                    return $returnList
                }
            } else {
                lappend protocol_objref_list \
                        [keylget result vport_objref]/protocols/isis
            }
        }
    }
    if {[info exists handle]} {
        set protocol_objref_list [list]
        foreach item $handle {
            set found [regexp {(.*)/router:\d} $item {} found_protocol_objref]
            if {$found} {
                lappend protocol_objref_list $found_protocol_objref
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to get the IS-IS protocol\
                        object reference out of the handle received as input:\
                        $item"
                return $returnList
            }
        }
    }
    if {![info exists port_handle] && ![info exists handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Neither 'port_handle' nor 'handle'\
                options have been specified. Please specify at least one of\
                the 'port_handle' or 'handle' options."
        return $returnList
    }
    after 10000
    # Check link state
    foreach protocol_objref $protocol_objref_list {
        regexp {(::ixNet::OBJ-/vport:\d).*} $protocol_objref {} vport_objref
        set retries 60
        set portState  [ixNet getAttribute $vport_objref -state]
        set portStateD [ixNet getAttribute $vport_objref -stateDetail]
        while {($retries > 0) && ( \
                ($portStateD != "idle") || ($portState  == "busy"))} {
            debug "Port state: $portState, $portStateD ..."
            after 1000
            set portState  [ixNet getAttribute $vport_objref -state]
            set portStateD [ixNet getAttribute $vport_objref -stateDetail]
            incr retries -1
        }
        debug "Port state: $portState, $portStateD ..."
        if {($portStateD != "idle") || ($portState == "busy")} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to start IS-IS on the $vport_objref\
                    port. Port state is $portState, $portStateD."
            return $returnList
        }
    }

    switch -exact $mode {
        restart {
            foreach protocol_objref $protocol_objref_list {
                debug "ixNet exec stop $protocol_objref"
                if {[catch {ixNet exec stop $protocol_objref} retCode] || \
                        ([string first "::ixNet::OK" $retCode] == -1)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to start IS-IS on the\
                            $vport_objref port. Error code: $retCode."
                    return $returnList
                }
                after 1000
                debug "ixNetworkExec [list start $protocol_objref]"
                if {[catch {ixNetworkExec [list start $protocol_objref]} retCode] || \
                        ([string first "::ixNet::OK" $retCode] == -1)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to start IS-IS on the\
                            $vport_objref port. Error code: $retCode."
                    return $returnList
                }
            }
            after 1000
        }
        start {
            foreach protocol_objref $protocol_objref_list {
                debug "ixNetworkExec [list start $protocol_objref]"
                if {[catch {ixNetworkExec [list start $protocol_objref]} retCode] || \
                        ([string first "::ixNet::OK" $retCode] == -1)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to start IS-IS on the\
                            $vport_objref port. Error code: $retCode."
                    return $returnList
                }
            }
            after 1000
        }
        stop {
            foreach protocol_objref $protocol_objref_list {
                debug "ixNet exec stop $protocol_objref"
                if {[catch {ixNet exec stop $protocol_objref} retCode] || \
                        ([string first "::ixNet::OK" $retCode] == -1)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to start IS-IS on the\
                            $vport_objref port. Error code: $retCode."
                    return $returnList
                }
            }
            after 1000
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "Unknown mode: '$mode'. Please use \
                    'start', 'stop' or 'restart'."
            return $returnList
        }
    }

    return $returnList
}

proc ::ixia::ixnetwork_isis_info { args man_args opt_args} {
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    if {[info exists port_handle]} {
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
            set routerHandles [concat $routerHandles [ixNet getList $portObjHandle/protocols/isis router]]
        }
    } elseif {[info exists handle]} {
        set portHandles    ""
        set portObjHandles ""
        set routerHandles  $handle
        foreach handleElem $handle {
            if {![regexp {^(.*)/protocols/isis/router:[a-zA-Z0-9]+$} $handleElem {} port_objref]} {
                keylset returnList status $::FAILURE
                keylset returnList log "The handle '$handle' is not a valid\
                        IS-IS router handle."
                return $returnList
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
    
    if {$mode == "stats"} {
        set port_handles $portHandles
        
        array set stats_array_aggregate {
			"Port Name"
                    port_name
            "L1 Sess. Configured"
                    l1_sessions_configured
            "L1 Sess. Up"
                    l1_sessions_up
            "L1 Neighbors"
                    full_l1_neighbors
            "L2 Sess. Configured"
                    l2_sessions_configured
            "L2 Sess. Up"
                    l2_sessions_up
            "L2 Neighbors"
                    full_l2_neighbors
            "L1 Hellos Tx"
                    aggregated_l1_hellos_tx
            "L1 PTP Hellos Tx"
                    aggregated_l1_p2p_hellos_tx
            "L1 LSP Tx"
                    aggregated_l1_lsp_tx
            "L1 CSNP Tx"
                    aggregated_l1_csnp_tx
            "L1 PSNP Tx"
                    aggregated_l1_psnp_tx
            "L1 DB Size"
                    aggregated_l1_db_size
            "L2 Hellos Tx"
                    aggregated_l2_hellos_tx
            "L2 PTP Hellos Tx"
                    aggregated_l2_p2p_hellos_tx
            "L2 LSP Tx"
                    aggregated_l2_lsp_tx
            "L2 CSNP Tx"
                    aggregated_l2_csnp_tx
            "L2 PSNP Tx"
                    aggregated_l2_psnp_tx
            "L2 DB Size"
                    aggregated_l2_db_size
            "L1 Hellos Rx"
                    aggregated_l1_hellos_rx
            "L1 PTP Hellos Rx"
                    aggregated_l1_p2p_hellos_rx
            "L1 LSP Rx"
                    aggregated_l1_lsp_rx
            "L1 CSNP Rx" 
                    aggregated_l1_csnp_rx
            "L1 PSNP Rx"
                    aggregated_l1_psnp_rx
            "L2 Hellos Rx"
                    aggregated_l2_hellos_rx
            "L2 PTP Hellos Rx"
                    aggregated_l2_p2p_hellos_rx
            "L2 LSP Rx"
                    aggregated_l2_lsp_rx
            "L2 CSNP Rx"
                    aggregated_l2_csnp_rx
            "L2 PSNP Rx"
                    aggregated_l2_psnp_rx
            "L1 Init State Count"
                    aggregated_l1_init_count
            "L1 Full State Count"
                    aggregated_l1_full_count
            "L2 Init State Count"
                    aggregated_l2_init_count
            "L2 Full State Count"
                    aggregated_l2_full_count
        }
        
        set statistic_types {
            aggregate "ISIS Aggregated Statistics"
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
                            keylset returnList $port_key.$stats_array($stat) \
                                    $rows_array($i,$stat)
                        } else {
                            keylset returnList $port_key.$stats_array($stat) "N/A"
                        }
                        if {$portIndex == 0} {
                            if {[info exists rows_array($i,$stat)] && \
                                    $rows_array($i,$stat) != ""} {
                                keylset returnList $stats_array($stat) \
                                        $rows_array($i,$stat)
                            } else {
                                keylset returnList $stats_array($stat) "N/A"
                            }
                        }
                        incr portIndex
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

    if {$mode == "clear_stats"} {
        set port_handle [ixNetworkGetRouterPort $port_objref]
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
    
    if {$mode == "learned_info"} {
    
        set ipv4_stats_list {
            lspId                lsp_id
            sequenceNumber       sequence_number
            ipv4Prefix           prefix
            metric               metric
            age                  age
        }
        set ipv6_stats_list {
            lspId                lsp_id
            sequenceNumber       sequence_number
            ipv6Prefix           prefix
            metric               metric
            age                  age
        }
        
        foreach {router} $routerHandles {
            debug "ixNet exec refreshLearnedInformation $router"
            set retCode [ixNet exec refreshLearnedInformation $router]
            if {[string first "::ixNet::OK" $retCode] == -1 } {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to refresh learned info for\
                        ISIS router $router."
                return $returnList
            }
            
            set retries 10
            set ipv4Prefixes [ixNet getL ${router}/learnedInformation ipv4Prefixes]
            while {$retries > 0} {
                after 10
                incr retries -1                
                set ipv4Prefixes [ixNet getL ${router}/learnedInformation ipv4Prefixes]
                if {[llength $ipv4Prefixes] > 0} {
                    break
                }
            }

            set retries 10
            set ipv6Prefixes [ixNet getL ${router}/learnedInformation ipv6Prefixes]
            while {$retries > 0} {
                after 10
                incr retries -1                
                set ipv6Prefixes [ixNet getL ${router}/learnedInformation ipv6Prefixes]
                if {[llength $ipv6Prefixes] > 0} {
                    break
                }
            }

            if {[llength $ipv6Prefixes] == 0 && [llength $ipv4Prefixes] == 0} {
                keylset returnList status $::SUCCESS
                keylset returnList log "Refreshing learned info for\
                        ISIS router $router has timed out. Please try again later."

                set session 1
                foreach {ixnOpt hltOpt} $ipv4_stats_list {
                    keylset returnList $router.session.$session.$hltOpt \
                            "NA"
                }
                return $returnList
            }
            set session 1
            foreach {ipv4Prefix} $ipv4Prefixes {
                foreach {ixnOpt hltOpt} $ipv4_stats_list {
                    keylset returnList $router.isis_l3_routing.ipv4.$session.$hltOpt \
                            [ixNet getAttribute $ipv4Prefix -$ixnOpt]
                }
                incr session
            }

            set session 1
            foreach {ipv6Prefix} $ipv6Prefixes {
                foreach {ixnOpt hltOpt} $ipv6_stats_list {
                    keylset returnList $router.isis_l3_routing.ipv6.$session.$hltOpt \
                            [ixNet getAttribute $ipv6Prefix -$ixnOpt]
                }
                incr session
            }

        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}
