##Library Header
# $Id: $
# Copyright © 2003-2007 by IXIA
# All Rights Reserved.
#
# Name:
#    ixnetwork_ldp_api.tcl
#
# Purpose:
#    A library containing LDP APIs for test automation
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
#    - ixnetwork_ldp_config
#    - ixnetwork_ldp_route_config
#    - ixnetwork_ldp_control
#    - ixnetwork_ldp_info
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

proc ::ixia::ixnetwork_ldp_config { args man_args opt_args } {
    variable objectMaxCount
    variable truth

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    array set translate_mode [list              \
            enable              true            \
            disable             false           \
            ]

    array set translate_label_adv [list         \
            unsolicited         unsolicited     \
            on_demand           onDemand        \
            ]

    array set translate_peer_discovery [list    \
            link                basic           \
            targeted            extended        \
            targeted_martini    extendedMartini \
            ]

    array set translate_atm_vc_dir [list        \
            bi_dir              bidirectional   \
            uni_dir             unidirectional  \
            ]
    
    array set translate_bfd_registration_mode [list \
            single_hop          singleHop       \
            multi_hop           multiHop        \
            ]
    
    # Check to see if a connection to the IxNetwork TCL server already exists. 
    # If it doesn't, establish it.
    set return_status [checkIxNetwork]
    if {[keylget return_status status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to IxNetwork - \
                [keylget return_status log]"
        return $returnList
    }
    # Add port
    set return_status [ixNetworkPortAdd $port_handle {} force]
    if {[keylget return_status status] != $::SUCCESS} {
        return $return_status
    }

    set result [ixNetworkGetPortObjref $port_handle]
    if {[keylget result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to find the port object reference \
                associated to the $port_handle port handle -\
                [keylget result log]."
        return $returnList
    }
    set protocol_objref [keylget result vport_objref]/protocols/ldp
    # Check if protocols are supported
    set retCode [checkProtocols [keylget result vport_objref]]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Port $port_handle does not support protocol\
                configuration."
        return $returnList
    }

    if {[info exists reset]} {
        set result [ixNetworkNodeRemoveList $protocol_objref \
                { {child remove router} {} } -commit]
        if {[keylget result status] == $::FAILURE} {
            return $returnList
        }
        if {[info exists ldp_handles_array]} {
            array unset ldp_handles_array
        }
        array set ldp_handles_array ""
    }

    if {($mode == "delete") || ($mode == "enable") || ($mode == "disable") || \
            ($mode == "modify")} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode,\
                    the -handle option must be used.  Please set this value."
            return $returnList
        }

        keylset returnList handle $handle

        if {$mode == "delete"} {
            ixNet remove $handle
            ixNet commit

            array unset ldp_handles_array $handle
        } elseif {[info exists translate_mode($mode)]} {
            set retCode [ixNetworkNodeSetAttr $handle \
                    [subst {-enabled $translate_mode($mode)}] -commit]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
        }
    }

    if {$mode == "create"} {
        # Start creating list of global LDP options
        set ldp_protocol_args [list -enabled true]
        
        # List of global options for LDP
        set globalLdpOptions {
            discard_self_adv_fecs       enableDiscardSelfAdvFecs    truth
            hello_hold_time             helloHoldTime               default
            hello_interval              helloInterval               default
            keepalive_holdtime          keepAliveHoldTime           default
            keepalive_interval          keepAliveInterval           default
            targeted_hello_hold_time    targetedHoldTime            default
            targeted_hello_interval     targetedHelloInterval       default
        }

        # Check LDP options existence and append parameters that exist
        foreach {hltOpt ixnOpt optType} $globalLdpOptions {
            if {[info exists $hltOpt]} {
                switch $optType {
                    truth {
                        lappend ldp_protocol_args -$ixnOpt \
                                $truth([set $hltOpt])
                    }
                    default {
                        lappend ldp_protocol_args -$ixnOpt \
                                [set $hltOpt]
                    }
                }
            }
        }

        # Apply configurations
        set retCode [ixNetworkNodeSetAttr $protocol_objref $ldp_protocol_args -commit]
        if {[keylget retCode status] != $::SUCCESS} {
            return $retCode
        }

        # Interfaces
        # Configure the necessary interfaces
        if {[info exists interface_handle] && [info exists count] && \
                [llength $interface_handle] != $count} {
            keylset returnList status $::FAILURE
            keylset returnList log "The -interface_handle list doesn't\
                    have the size specified with the -count argument."
            return $returnList
        } elseif {[info exists interface_handle]} {
            set intf_list [list]
            set no_ipv4 false
            foreach intf $interface_handle {
                if {[llength [ixNet getList $intf ipv4]] > 0} {
                    lappend intf_list [list [list interface_handle $intf]]
                } else {
                    lappend no_ipv4_intf_list \
                            [list [list interface_handle $intf]]
                    set no_ipv4 true
                }
            }
            if {$no_ipv4} {
                keylset returnList status $::FAILURE
                keylset returnList log "The following interfaces don't have\
                        IPv4 addresses configured: $no_ipv4_intf_list"
                return $returnList
            }
        } else {
            set loopback_ip_addr_prefix 32
            set loopback_count          1
            set protocol_intf_options "                                         \
                    -atm_encapsulation              atm_encapsulation           \
                    -atm_vci                        vci                         \
                    -atm_vci_step                   vci_step                    \
                    -atm_vpi                        vpi                         \
                    -atm_vpi_step                   vpi_step                    \
                    -count                          count                       \
                    -ipv4_address                   intf_ip_addr                \
                    -ipv4_address_step              intf_ip_addr_step           \
                    -ipv4_prefix_length             intf_prefix_length          \
                    -gateway_address                gateway_ip_addr             \
                    -gateway_address_step           gateway_ip_addr_step        \
                    -loopback_count                 loopback_count              \
                    -loopback_ipv4_address          loopback_ip_addr            \
                    -loopback_ipv4_address_step     loopback_ip_addr_step       \
                    -loopback_ipv4_prefix_length    loopback_ip_addr_prefix     \
                    -mac_address                    mac_address_init            \
                    -mac_address_step               mac_address_step            \
                    -override_existence_check       override_existence_check    \
                    -override_tracking              override_tracking           \
                    -port_handle                    port_handle                 \
                    -vlan_enabled                   vlan                        \
                    -vlan_id                        vlan_id                     \
                    -vlan_id_mode                   vlan_id_mode                \
                    -vlan_id_step                   vlan_id_step                \
                    -vlan_user_priority             vlan_user_priority          \
                    "
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
            set unconnected_intf_list [keylget intf_list routed_interfaces]
            set intf_list [keylget intf_list connected_interfaces]
        }

        # Start creating list of static LDP router options
        set ldp_router_static_args [list -enabled true]
        
        # List of static (non-incrementing) options for LDP router
        set staticLdpRouterOptions {
            enable_l2vpn_vc_fecs        enableVcFecs            truth
            enable_vc_group_matching    enableVcGroupMatch      truth
            graceful_restart_enable     enableGracefulRestart   truth
            reconnect_time              reconnectTime           default
            recovery_time               recoveryTime            default
        }

        # Check LDP options existence and append parameters that exist
        foreach {hltOpt ixnOpt optType} $staticLdpRouterOptions {
            if {[info exists $hltOpt]} {
                switch $optType {
                    truth {
                        lappend ldp_router_static_args -$ixnOpt \
                                $truth([set $hltOpt])
                    }
                    default {
                        lappend ldp_router_static_args -$ixnOpt \
                                [set $hltOpt]
                    }
                }
            }
        }

        # Start creating list of static LDP protocol interface options
        set ldp_intf_static_args [list]
        
        # List of static (non-incrementing) options for LDP protocol interface
        set staticLdpInterfaceOptions {
            auth_mode                authentication         default
            auth_key                 md5Key                 default
            label_adv                advertisingMode        translate
            peer_discovery           discoveryMode          translate
            label_space              labelSpaceId           default
            bfd_registration         enableBfdRegistration  default
            bfd_registration_mode    bfdOperationMode       translate
        }

        # Check LDP options existence and append parameters that exist
        foreach {hltOpt ixnOpt optType} $staticLdpInterfaceOptions {
            if {[info exists $hltOpt]} {
                switch $optType {
                    translate {
                        lappend ldp_intf_static_args -$ixnOpt \
                                [set translate_${hltOpt}([set $hltOpt])]
                    }
                    default {
                        lappend ldp_intf_static_args -$ixnOpt \
                                [set $hltOpt]
                    }
                }
            }
        }

        # Particular static (non-incrementing) options for LDP router
        if {[info exists atm_vc_dir] && \
                $label_adv == "on_demand" && $peer_discovery == "link"} {
            lappend ldp_intf_static_args -enableAtmSession true
            lappend ldp_intf_static_args -atmVcDirection \
                    $translate_atm_vc_dir($atm_vc_dir)
        }

        # List of static (non-incrementing) options for LDP ATM label range
        set atm_label_range_static_args [list]
        if {    [info exists atm_range_max_vpi] || \
                [info exists atm_range_min_vpi] || \
                [info exists atm_range_max_vci] || \
                [info exists atm_range_min_vci]} {
            # List of static (non-incrementing) options for LDP ATM label range
            set staticLdpAtmRangeOptions {
                atm_range_max_vci       maxVci
                atm_range_max_vpi       maxVpi
                atm_range_min_vci       minVci
                atm_range_min_vpi       minVpi
            }

            # Check LDP options existence and append parameters that exist
            foreach {hltOpt ixnOpt} $staticLdpAtmRangeOptions {
                if {[info exists $hltOpt]} {
                    lappend atm_label_range_static_args -$ixnOpt [set $hltOpt]
                }
            }
        }

        # Routers
        set objectCount     0
        set index           0
        set ldp_router_list [list]
        foreach intf_objref $intf_list {
            if {![catch {keylkeys intf_objref} err]} {
                set intf_objref [keylget intf_objref interface_handle]
            }
            # Router
            set ldp_router_args $ldp_router_static_args
            if {[info exists lsr_id]} {
                lappend ldp_router_args -routerId $lsr_id
            }
            set result [ixNetworkNodeAdd $protocol_objref router \
                    $ldp_router_args]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to add router to the \
                        $protocol_objref protocol object reference -\
                        [keylget result log]."
                return $returnList
            } else {
                set router_objref [keylget result node_objref]
            }
            lappend ldp_router_list $router_objref
            set ldp_handles_array($router_objref) $port_handle

            # Commit
            incr objectCount
            if {[expr $objectCount % $objectMaxCount] == 0} {
                ixNet commit
            }

            # Protocol interfaces
            set ldp_intf_args $ldp_intf_static_args
            if {$peer_discovery != "targeted_martini"} {
                lappend ldp_intf_args -enabled true -protocolInterface \
                        $intf_objref
            } else {
                lappend ldp_intf_args -enabled true -protocolInterface \
                        [lindex $unconnected_intf_list $index]
            }
            set result [ixNetworkNodeAdd $router_objref interface \
                    $ldp_intf_args]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to add protocol interface\
                        to the $router_objref router object reference -\
                        [keylget result log]."
                return $returnList
            } else {
                set proto_intf_objref [keylget result node_objref]
            }

            # Commit
            incr objectCount
            if {[expr $objectCount % $objectMaxCount] == 0} {
                ixNet commit
            }

            # Target peers
            if {[info exists remote_ip_addr]} {
                set result [ixNetworkNodeAdd $proto_intf_objref targetPeer \
                        [list -enabled true -ipAddress $remote_ip_addr]]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to add target peer to\
                            the $proto_intf_objref protocol interface object\
                            reference - [keylget result log]."
                    return $returnList
                } else {
                    set peer_objref [keylget result node_objref]
                }

                # Commit
                incr objectCount
                if {[expr $objectCount % $objectMaxCount] == 0} {
                    ixNet commit
                }
            }

            # ATM label ranges
            if {    [info exists atm_range_max_vpi] || \
                    [info exists atm_range_min_vpi] || \
                    [info exists atm_range_max_vci] || \
                    [info exists atm_range_min_vci]} {
                set result [ixNetworkNodeAdd $proto_intf_objref \
                        atmLabelRange $atm_label_range_static_args]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to add atm label\
                            range to the $proto_intf_objref protocol interface\
                            object reference - [keylget result log]."
                    return $returnList
                } else {
                    set atm_label_range_objref [keylget result node_objref]
                }

                # Commit
                incr objectCount
                if {[expr $objectCount % $objectMaxCount] == 0} {
                    ixNet commit
                }
            }

            # Increment router parameters
            if {[info exists lsr_id]} {
                if {![info exists lsr_id_step]} {
                    set lsr_id_step 0.0.1.0
                } else  {
                    if {![::isIpAddressValid $lsr_id_step]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Invalid LDP router ID step."
                        return $returnList
                    }
                }

                set lsr_id [::ixia::incr_ipv4_addr $lsr_id $lsr_id_step]
            }

            if {[info exists remote_ip_addr]} {
                if {![info exists remote_ip_addr_step]} {
                    set remote_ip_addr_step 0.0.1.0
                } else  {
                    if {![::isIpAddressValid $remote_ip_addr_step]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Invalid LDP target peer IP step."
                        return $returnList
                    }
                }

                set remote_ip_addr [::ixia::incr_ipv4_addr \
                        $remote_ip_addr $remote_ip_addr_step]
            }

            incr index
        }

        # Commit
        if {[expr $objectCount % $objectMaxCount] != 0} {
            ixNet commit
        }
        set ldp_router_list [ixNet remapIds $ldp_router_list]

        # Done
        keylset returnList handle $ldp_router_list
    }

    if {$mode == "modify"} {
        # Remove defaults
        removeDefaultOptionVars $opt_args $args

        set ldp_protocol_args [list -enabled true]
        if {[info exists discard_self_adv_fecs]} {
            lappend ldp_protocol_args -enableDisacrdSelfAdvFecs \
                $truth($discard_self_adv_fecs)
        }
        if {[info exists hello_hold_time]} {
            lappend ldp_protocol_args -helloHoldTime $hello_hold_time
        }
        if {[info exists hello_interval]} {
            lappend ldp_protocol_args -helloInterval $hello_interval
        }
        if {[info exists keepalive_holdtime]} {
            lappend ldp_protocol_args -keepAliveHoldTime $keepalive_holdtime
        }
        if {[info exists keepalive_interval]} {
            lappend ldp_protocol_args -keepAliveInterval $keepalive_interval
        }
        if {[info exists targeted_hello_hold_time]} {
            lappend ldp_protocol_args -targetedHoldTime \
                    $targeted_hello_hold_time
        }
        if {[info exists targeted_hello_interval]} {
            lappend ldp_protocol_args -targetedHelloInterval \
                    $targeted_hello_interval
        }
        
        set retCode [ixNetworkNodeSetAttr $protocol_objref $ldp_protocol_args -commit]
        if {[keylget retCode status] != $::SUCCESS} {
            return $retCode
        }

        ## Interface
        set connected_intf_options "                                    \
                -atm_encapsulation              atm_encapsulation       \
                -atm_vci                        vci                     \
                -atm_vpi                        vpi                     \
                -ipv4_address                   intf_ip_addr            \
                -ipv4_prefix_length             intf_ip_prefix_length   \
                -gateway_address                gateway_ip_addr         \
                -mac_address                    mac_address_init        \
                -vlan_enabled                   vlan                    \
                -vlan_id                        vlan_id                 \
                -vlan_user_priority             vlan_user_priority      \
                "
        
        # Get the interface object reference
        if {[regexp {router:\d*$} $handle]} {
            set _intf_objref [ixNetworkNodeGetList $handle interface]
            set interface_handle [ixNet getAttribute $_intf_objref \
                    -protocolInterface]
            if {[ixNet getAttr $_intf_objref -discoveryMode] != "extendedMartini"} {
                set connected_intf $interface_handle
            } else {
                set unconnected_intf $interface_handle
                set connected_intf [ixNet getAttr $interface_handle/unconnected -connectedVia]
            }
        }
        if {![info exists interface_handle] || $interface_handle == ""} {
            keylset returnList status $::FAILURE
            keylset returnList log "Cannot get protocol interface from\
                    -handle $handle"
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
        set port_handle [keylget retCode port_handle]
        if {[string equal $port_handle ""]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR on $procName: invalid \
                    interface handle specified."
            return $returnList
        }

        # Modify the interface
        if {[info exists connected_intf]} {
            set protocol_intf_args ""
            foreach {option value_name} $connected_intf_options {
                if {[info exists $value_name]} {
                    append protocol_intf_args " $option [set $value_name]"
                }
            }
            if {![string equal $protocol_intf_args ""]} {
                debug "::ixia::ixNetworkConnectedIntfCfg \
                        -port_handle $port_handle \
                        -prot_intf_objref $connected_intf \
                        $protocol_intf_args"
                if {[catch {set retCode [eval ::ixia::ixNetworkConnectedIntfCfg \
                        -port_handle $port_handle \
                        -prot_intf_objref $connected_intf \
                        $protocol_intf_args]} errorMsg]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "$errorMsg"
                    return $returnList
                }
            }
        } 
        
        if {[info exists unconnected_intf] && \
                [info exists loopback_ip_addr]} {
            if {[catch {set retCode [eval ::ixia::ixNetworkUnconnectedIntfCfg \
                    -port_handle $port_handle \
                    -prot_intf_objref $unconnected_intf \
                    -loopback_ipv4_prefix_length    32 \
                    -loopback_ipv4_address $loopback_ip_addr]} errorMsg]} {
                keylset returnList status $::FAILURE
                keylset returnList log "$errorMsg"
                return $returnList
            }
            
        }
        
        if {[info exists retCode] && [keylget retCode status] != $::SUCCESS} {
            return $retCode
        }
        
        # Router
        set ldp_router_args ""
        if {[info exists enable_l2vpn_vc_fecs]} {
            lappend ldp_router_args -enableVcFecs \
                    $truth($enable_l2vpn_vc_fecs)
        }
        if {[info exists enable_vc_group_matching]} {
            lappend ldp_router_args -enableVcGroupMatch \
                    $truth($enable_vc_group_matching)
        }
        if {[info exists graceful_restart_enable]} {
            lappend ldp_router_args -enableGracefulRestart \
                    $truth($graceful_restart_enable)
        }
        if {[info exists reconnect_time]} {
            lappend ldp_router_args -reconnectTime $reconnect_time
        }
        if {[info exists recovery_time]} {
            lappend ldp_router_args -recoveryTime $recovery_time
        }
        if {[info exists lsr_id]} {
            lappend ldp_router_args -routerId $lsr_id
        }
        if {$ldp_router_args != ""} {
            set retCode [ixNetworkNodeSetAttr $handle $ldp_router_args -commit]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
        }

        # Protocol interface
        set intf [ixNetworkNodeGetList $handle interface]
        set ldp_intf_args ""
        if {[info exists label_adv]} {
            lappend ldp_intf_args -advertisingMode \
                    $translate_label_adv($label_adv)
        }
        if {[info exists peer_discovery]} {
            lappend ldp_intf_args -discoveryMode \
                    $translate_peer_discovery($peer_discovery)
        }
        if {[info exists label_space]} {
            lappend ldp_intf_args -labelSpaceId $label_space
        }
        if {[info exists atm_vc_dir] && \
                $label_adv == "on_demand" && $peer_discovery == "link"} {
            lappend ldp_intf_args -enableAtmSession true
            lappend ldp_intf_args -atmVcDirection \
                    $translate_atm_vc_dir($atm_vc_dir)
        }
        if {$ldp_intf_args != ""} {
            set retCode [ixNetworkNodeSetAttr $intf $ldp_intf_args -commit]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
        }

        # Target peer
        set target_peer [ixNetworkNodeGetList $intf targetPeer]
        if {[info exists remote_ip_addr]} {
            if {$target_peer != [ixNet getNull]} {
                set retCode [ixNetworkNodeSetAttr $target_peer \
                        [list -enabled true -ipAddress $remote_ip_addr] \
                        -commit]
                if {[keylget retCode status] != $::SUCCESS} {
                    return $retCode
                }
            } else {
                set result [ixNetworkNodeAdd $intf targetPeer \
                        [list -enabled true -ipAddress $remote_ip_addr] \
                        -commit]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to add target\
                            peer to $intf protocol interface object\
                            reference - [keylget result log]."
                    return $returnList
                } else {
                    set peer_objref [keylget result node_objref]
                }
            }
        }

        # ATM label ranges
        set atm_label_range [ixNetworkNodeGetList $intf atmLabelRange]
        set atm_label_range_args ""
        if {[info exists atm_range_max_vci]} {
            lappend atm_label_range_args -maxVci $atm_range_max_vci
        }
        if {[info exists atm_range_max_vpi]} {
            lappend atm_label_range_args -maxVpi $atm_range_max_vpi
        }
        if {[info exists atm_range_min_vci]} {
            lappend atm_label_range_args -minVci $atm_range_min_vci
        }
        if {[info exists atm_range_min_vpi]} {
            lappend atm_label_range_args -minVpi $atm_range_min_vpi
        }
        if {$atm_label_range_args != ""} {
            if {$atm_label_range != [ixNet getNull]} {
                set retCode [ixNetworkNodeSetAttr $atm_label_range $atm_label_range_args \
                        -commit]
                if {[keylget retCode status] != $::SUCCESS} {
                    return $retCode
                }
            } else {
                set result [ixNetworkNodeAdd $intf \
                        targetPeer [list -enabled true -ipAddress \
                        $remote_ip_addr] -commit]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to add atm label range\
                            to the $intf protocol interface object\
                            reference - [keylget result log]."
                    return $returnList
                } else {
                    set atm_label_range_objref [keylget result node_objref]
                }
            }
        }
    }
    ixNet commit

    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::ixnetwork_ldp_route_config { args man_args opt_args } {
    variable objectMaxCount
    variable truth

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    keylset returnList status $::SUCCESS

    array set translate_egress_label_mode [list \
            nextlabel           increment       \
            fixed               none            \
            imnull              none            \
            exnull              none            \
            ]

    array set translate_fec_vc_type {
        atm_aal5_vcc        atmaal5
        atm_vcc_1_1         atmvcc
        atm_vcc_n_1         atmvcc
        atm_vpc_1_1         atmvpc
        atm_vpc_n_1         atmvpc
        atm_cell            atmxCell
        cem                 cem
        eth                 ethernet
        fr_dlci             frameRelay
        fr_dlci_rfc4619     frameRelayRfc4619
        hdlc                hdlc
        eth_vpls            ip
        ppp                 ppp
        eth_vlan            vlan
    }

    array set translate_fec_vc_label_mode [list \
            increment_label     increment       \
            fixed_label         none            \
            ]
            
    array set translate_provisioning_model {
        bgp_auto_discovery          bgpAutoDiscovery
        manual_configuration        manualConfiguration
        }
        
    array set translate_fec_vc_fec_type {
        generalized_id_fec_vpls        generalizedIdFecVpls
        pw_id_fec                      pwIdFec
    }
    
    # Configure range(s).
    if {$mode == "delete"} {
        if {![info exists lsp_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "please specify a lsp_handle to \
                    delete."
            return $returnList
        } else {
            ixNet remove $lsp_handle
            ixNet commit
        }
    }

    if {$mode == "create"} {
        switch $fec_type {
            ipv4_prefix {
                # Advertising FEC range
                set adv_fec_range_args [list -enabled true]
                if {[info exists egress_label_mode]} {
                    lappend adv_fec_range_args -labelMode \
                            $translate_egress_label_mode($egress_label_mode)
                    if {$egress_label_mode == "imnull"} {
                        set label_value_start 3
                    } elseif {$egress_label_mode == "exnull"} {
                        set label_value_start 0
                    }
                }
                if {[info exists fec_ip_prefix_start]} {
                    lappend adv_fec_range_args -firstNetwork \
                            $fec_ip_prefix_start
                }
                if {[info exists num_lsps]} {
                    lappend adv_fec_range_args -numberOfNetworks $num_lsps
                }
                if {[info exists fec_ip_prefix_length]} {
                    lappend adv_fec_range_args -maskWidth $fec_ip_prefix_length
                }
                if {[info exists label_value_start]} {
                    lappend adv_fec_range_args -labelValueStart $label_value_start
                }
                if {[info exists packing_enable]} {
                    lappend adv_fec_range_args -enablePacking \
                            $truth($packing_enable)
                }
                set result [ixNetworkNodeAdd $handle advFecRange \
                        $adv_fec_range_args -commit]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to add advertising FEC range\
                            to the $handle protocol object reference -\
                            [keylget result log]."
                    return $returnList
                } else {
                    set adv_fec_range_objref [keylget result node_objref]
                }
                keylset returnList lsp_handle $adv_fec_range_objref
            }

            host_addr {
                # Requesting FEC range
                set req_fec_range_args [list -enabled true]
                if {[info exists fec_host_addr]} {
                    lappend req_fec_range_args -firstNetwork $fec_host_addr
                }
                if {[info exists fec_host_prefix_length]} {
                    lappend req_fec_range_args -maskWidth \
                            $fec_host_prefix_length
                }
                if {[info exists hop_count_tlv_enable]} {
                    lappend req_fec_range_args -enableHopCount \
                            $truth($hop_count_tlv_enable)
                }
                if {[info exists hop_count_value]} {
                    lappend req_fec_range_args -hopCount $hop_count_value
                }
                if {[info exists next_hop_peer_ip]} {
                    lappend req_fec_range_args -nextHopPeer $next_hop_peer_ip
                }
                if {[info exists num_routes]} {
                    lappend req_fec_range_args -numberOfRoutes $num_routes
                }
                if {[info exists stale_request_time]} {
                    lappend req_fec_range_args -staleReqTime $stale_request_time
                }
                if {[info exists stale_timer_enable]} {
                    lappend req_fec_range_args -enableStateTimer \
                            $truth($stale_timer_enable)
                }
                set result [ixNetworkNodeAdd $handle reqFecRange \
                        $req_fec_range_args -commit]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to add requested FEC range\
                            to the $handle protocol object reference -\
                            [keylget result log]."
                    return $returnList
                } else {
                    set req_fec_range_objref [keylget result node_objref]
                }
                keylset returnList lsp_handle $req_fec_range_objref
            }

            vc {
                set objectCount    0
                # VC ranges
                set l2_vc_ranges     [list]
                # VC IP ranges
                set l2_vc_ip_ranges  [list]
                # VC MAC ranges
                set l2_vc_mac_ranges [list]
                # L2 Interface
                set l2_intf_args [list -enabled true]
                set l2_intf_options {
                    fec_vc_group_id       groupId
                    fec_vc_type           type
                    fec_vc_group_count    count
                }
                foreach {hltOpt ixnOpt} $l2_intf_options {
                    if {[info exists $hltOpt]} {
                        if {[array exists translate_$hltOpt] && \
                                [info exists translate_${hltOpt}([set $hltOpt])]} {
                            lappend l2_intf_args -${ixnOpt} \
                                    [set translate_${hltOpt}([set $hltOpt])]
                        } else {
                            lappend l2_intf_args -${ixnOpt} [set $hltOpt]
                        }
                    }
                }
                set result [ixNetworkNodeAdd $handle l2Interface \
                        $l2_intf_args]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to add L2 interface to the\
                            $handle protocol object reference -\
                            [keylget result log]."
                    return $returnList
                }
                set l2_intf_objref [keylget result node_objref]
                # Commit
                incr objectCount
                if {[expr $objectCount % $objectMaxCount] == 0} {
                    ixNet commit
                    set l2_intf_objref [ixNet remapIds $l2_intf_objref]
                }
                
                # VC range
                set l2_vc_range_args [list -enabled true]
                set l2_vc_range_options {
                    fec_vc_cbit               enableCBit
                    fec_vc_id_count           count
                    fec_vc_id_start           vcId
                    fec_vc_id_step            vcIdStep
                    fec_vc_intf_mtu           mtu
                    fec_vc_intf_mtu_enable    enableMtuPresent
                    fec_vc_label_mode         labelMode
                    fec_vc_label_value_start  labelStart
                    fec_vc_peer_address       peerAddress
                    packing_enable            enablePacking
                    fec_vc_atm_enable         enableMaxAtmPresent
                    fec_vc_atm_max_cells      maxNumberOfAtmCells
                    fec_vc_cem_option         cemOption
                    fec_vc_cem_option_enable  enableCemOption
                    fec_vc_cem_payload        cemPayload
                    fec_vc_cem_payload_enable enableCemPayload
                    fec_vc_ce_ip_addr         ceIpAddress
                    fec_vc_fec_type           fecType
                    provisioning_model        provisioningModel
                }
                # parameters that are allowed to be lists, and not separately treated in the lower increment section
                # WARNING: these parameters are assumed not to contain spaces (excepting fec_vc_intf_desc which is treated separately)
                set fec_vc_params_lists {
                    fec_vc_id_step
                    fec_vc_id_count
                    fec_vc_label_mode
                    fec_vc_cbit
                    fec_vc_intf_mtu
                    fec_vc_intf_mtu_enable
                    fec_vc_peer_address
                    packing_enable
                    fec_vc_atm_enable
                    fec_vc_atm_max_cells
                    fec_vc_cem_option
                    fec_vc_cem_option_enable
                    fec_vc_cem_payload
                    fec_vc_cem_payload_enable
                    fec_vc_intf_desc
                    fec_vc_ce_ip_addr_step
                    fec_vc_fec_type
                    provisioning_model
                }
                
                foreach {hltOpt ixnOpt} $l2_vc_range_options {
                    if {[info exists $hltOpt]} {
                        if {[array exists translate_$hltOpt] && \
                                [info exists translate_${hltOpt}([lindex [set $hltOpt] 0])]} {
                            set ${hltOpt}_li [set translate_${hltOpt}([lindex [set $hltOpt] 0])]
                        } else {
                            set ${hltOpt}_li [lindex [set $hltOpt] 0]
                        }
                        # add a _li suffix for increment and other ops use
                        lappend l2_vc_range_args -${ixnOpt} \$${hltOpt}_li
                    }
                }
                if {[info exists fec_vc_intf_desc]} {
                    lappend l2_vc_range_args -enableDescriptionPresent true
                    # description might contain spaces, treat that too
                    lappend l2_vc_range_args -description \$fec_vc_intf_desc_li
                    if {$fec_vc_count == 1} {
                        # previous processing of parameters will turn the ones that contain spaces to lists
                        set fec_vc_intf_desc_li $fec_vc_intf_desc
                    } else {
                        set fec_vc_intf_desc_li [lindex $fec_vc_intf_desc 0]
                    }
                }
                if {[info exists fec_vc_ce_ip_addr_step]} {
                    lappend l2_vc_range_args -step \$fec_vc_ce_ip_addr_step_li
                    set fec_vc_ce_ip_addr_step_li [lindex $fec_vc_ce_ip_addr_step 0]
                }
                
                # VCIPRange
                set l2_vc_ip_range_options {
                    fec_vc_ip_range_addr_count    numHosts
                    fec_vc_ip_range_addr_start    startAddress
                    fec_vc_ip_range_prefix_len    mask
                }
                # params that may be lists
                set fec_vc_ip_range_params_lists {
                    fec_vc_ip_range_addr_count
                    fec_vc_ip_range_prefix_len
                    fec_vc_ip_range_addr_inner_step
                }
                set fec_vc_ip_range_addr_start_li [lindex $fec_vc_ip_range_addr_start 0]
                foreach hltOpt $fec_vc_ip_range_params_lists {
                    if {[info exists $hltOpt]} {
                        set ${hltOpt}_li [lindex [set $hltOpt] 0]
                    }
                }
                # VCMACRange
                set l2_vc_mac_range_options {
                    fec_vc_mac_range_count          count
                    fec_vc_mac_range_first_vlan_id  firstVlanId
                    fec_vc_mac_range_repeat_mac     enableRepeatMac
                    fec_vc_mac_range_same_vlan      enableSameVlan
                    fec_vc_mac_range_start          startMac
                    fec_vc_mac_range_vlan_enable    enableVlan
                }
                foreach {hltOpt ixnOpt} $l2_vc_mac_range_options {
                    if {[info exists $hltOpt]} {
                        set ${hltOpt}_li [lindex [set $hltOpt] 0]
                    }
                } 
                # Main VCRange loop
                for {set i 0} {$i < $fec_vc_count} {incr i} {
                    debug "ixNetworkNodeAdd $l2_intf_objref \
                            l2VcRange \[subst $l2_vc_range_args\]"
                    set result [ixNetworkNodeAdd $l2_intf_objref \
                            l2VcRange [subst $l2_vc_range_args]]
                    
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to add L2 VC range\
                                to the $l2_vc_range_objref L2 interface\
                                object reference - [keylget result log]."
                        return $returnList
                    }
                    set l2_vc_range_objref [keylget result node_objref]
                    # Commit
                    incr objectCount
                    if {[expr $objectCount % $objectMaxCount] == 0} {
                        ixNet commit
                        set l2_intf_objref     [ixNet remapIds $l2_intf_objref]
                        set l2_vc_range_objref [ixNet remapIds $l2_vc_range_objref]
                    }
                    lappend l2_vc_ranges $l2_vc_range_objref
                    # IP Range
                    if {[info exists fec_vc_ip_range_enable]} {
                        set t_val [lindex $fec_vc_ip_range_enable [expr $i+1]]
                        if {$t_val == ""} {
                            set t_val [lindex $fec_vc_ip_range_enable end]
                        }
                        if {$t_val} {
                            set l2_vc_ip_range_args [list -enabled true]
                            
                            set fec_vc_ip_range_cparam 0
                            foreach {hltOpt ixnOpt} $l2_vc_ip_range_options {
                                if {[info exists $hltOpt]} {
                                    lappend l2_vc_ip_range_args -${ixnOpt} [set ${hltOpt}_li]
                                }
                            }
                            if {[info exists fec_vc_ip_range_addr_inner_step]} {
                                lappend l2_vc_ip_range_args -incrementBy \
                                        [ip_addr_to_num $fec_vc_ip_range_addr_inner_step_li]
                            }
                            
                            set result [ixNetworkNodeSetAttr \
                                    $l2_vc_range_objref/l2VcIpRange \
                                    $l2_vc_ip_range_args]
                            
                            if {[keylget result status] == $::FAILURE} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Unable to add L2 VC IP range.\
                                        [keylget result log]."
                                return $returnList
                            }
                            set l2_vc_ip_range_objref $l2_vc_range_objref/l2VcIpRange
                            # Commit
                            incr objectCount
                            if {[expr $objectCount % $objectMaxCount] == 0} {
                                ixNet commit
                                set l2_intf_objref        [ixNet remapIds $l2_intf_objref]
                                set l2_vc_range_objref    [ixNet remapIds $l2_vc_range_objref]
                            }
                            lappend l2_vc_ip_ranges $l2_vc_ip_range_objref
                            
                            if {[info exists fec_vc_ip_range_addr_start] && \
                                    [info exists fec_vc_ip_range_addr_outer_step]} {
                                if {[lindex $fec_vc_ip_range_addr_start [expr $i+1]] == ""} {
                                    # if there's no present value, increment the last one
                                    # t_start is old val for *_start
                                    set t_start [lindex $fec_vc_ip_range_addr_start $i]
                                    if {$t_start == ""} {
                                        set t_start $fec_vc_ip_range_addr_start_li
                                    }
                                    set t_step $fec_vc_ip_range_addr_outer_step
                                    set fec_vc_ip_range_cparam [increment_ipv4_address_hltapi $t_start $t_step]
                                } else {
                                    set fec_vc_ip_range_cparam [lindex $fec_vc_ip_range_addr_start [expr $i+1]]
                                }
                                set fec_vc_ip_range_addr_start_li $fec_vc_ip_range_cparam
                            }
                            
                            # update all other params that may be lists
                            foreach fec_vc_ip_range_p $fec_vc_ip_range_params_lists {
                                if {[info exists $fec_vc_ip_range_p]} {
                                    set fec_vc_ip_range_cparam [lindex [set $fec_vc_ip_range_p] [expr $i+1]]
                                    if {$fec_vc_ip_range_cparam == ""} {
                                        set fec_vc_ip_range_cparam [lindex [set $fec_vc_ip_range_p] end]
                                    }
                                    set ${fec_vc_ip_range_p}_li $fec_vc_ip_range_cparam
                                }
                            }
                        }
                    }
                    # MAC Range
                    if {[info exists fec_vc_mac_range_enable]} {
                        set t_val [lindex $fec_vc_mac_range_enable [expr $i+1]]
                        if {$t_val == ""} {
                            set t_val [lindex $fec_vc_mac_range_enable end]
                        }
                        if {$t_val} {
                            if {[info exists fec_vc_mac_range_start]} {
                                set fec_vc_mac_range_start_li [convertToIxiaMac \
                                        $fec_vc_mac_range_start_li ":"]
                            }
                            set l2_vc_mac_range_args [list -enabled true]
                            foreach {hltOpt ixnOpt} $l2_vc_mac_range_options {
                                if {[info exists $hltOpt]} {
                                    lappend l2_vc_mac_range_args -${ixnOpt} [set ${hltOpt}_li]
                                }
                            }                        
                            set result [ixNetworkNodeSetAttr \
                                    $l2_vc_range_objref/l2MacVlanRange \
                                    $l2_vc_mac_range_args]
                            
                            if {[keylget result status] == $::FAILURE} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Unable to add L2 VC MAC range.\
                                        [keylget result log]."
                                return $returnList
                            }
                            set l2_vc_mac_range_objref $l2_vc_range_objref/l2MacVlanRange
                            # Commit    
                            incr objectCount
                            if {[expr $objectCount % $objectMaxCount] == 0} {
                                ixNet commit
                                set l2_intf_objref         [ixNet remapIds $l2_intf_objref]
                                set l2_vc_range_objref     [ixNet remapIds $l2_vc_range_objref]
                            }
                            lappend l2_vc_mac_ranges $l2_vc_mac_range_objref
                            
                            if {[info exists fec_vc_mac_range_start] && \
                                    [info exists fec_vc_mac_range_count]} {
                                if {[lindex $fec_vc_mac_range_start [expr $i+1]] == ""} {
                                    # if there's no present value, increment the last one
                                    # t_start is old val for *_start
                                    set t_start [lindex $fec_vc_mac_range_start $i]
                                    if {$t_start == ""} {
                                        set t_start $fec_vc_mac_range_start_li
                                    }
                                    set t_count [lindex $fec_vc_mac_range_count $i]
                                    if {$t_count == ""} {
                                        set t_count $fec_vc_mac_range_count_li
                                    }
                                    set fec_vc_mac_range_cparam  [join [::ixia::incrementMacAdd $t_start $t_count] ":"]
                                } else {
                                    set fec_vc_mac_range_cparam [lindex $fec_vc_mac_range_start [expr $i+1]]
                                }
                                set fec_vc_mac_range_start_li $fec_vc_mac_range_cparam
                            }
                            
                            # update all other params that may be lists
                            # exclude *_start
                            foreach fec_vc_mac_range_p $l2_vc_mac_range_options {
                                if {[regexp {^.*_start$} $fec_vc_mac_range_p]} {
                                    continue
                                }
                                if {[info exists $fec_vc_mac_range_p]} {
                                    set fec_vc_mac_range_cparam [lindex [set $fec_vc_mac_range_p] [expr $i+1]]
                                    if {$fec_vc_mac_range_cparam == ""} {
                                        set fec_vc_mac_range_cparam [lindex [set $fec_vc_mac_range_p] end]
                                    }
                                    set ${fec_vc_mac_range_p}_li $fec_vc_mac_range_cparam
                                }
                            }
                        }
                    }
                    # Increment VC range params
                    set fec_vc_cparam 0
                    # use fec_vc_cparam once for each attribute specified in the current block
                    
                    if {[info exists fec_vc_id_start] && \
                            [info exists fec_vc_id_step] && \
                            [info exists fec_vc_id_count]} {
                        if {[lindex $fec_vc_id_start [expr $i+1]] == ""} {
                            # if there's no present value, increment the last one
                            # t_start is old val for *_start
                            set t_start [lindex $fec_vc_id_start $i]
                            if {$t_start == ""} {
                                set t_start $fec_vc_id_start_li
                            }
                            set t_step [lindex $fec_vc_id_step $i]
                            if {$t_step == ""} {
                                set t_step [lindex $fec_vc_id_step end]
                            }
                            set t_count [lindex $fec_vc_id_count $i]
                            if {$t_count == ""} {
                                set t_count [lindex $fec_vc_id_count end]
                            }
                            set fec_vc_cparam [expr $t_start + ($t_count * $t_step)]
                        } else {
                            set fec_vc_cparam [lindex $fec_vc_id_start [expr $i+1]]
                        }
                    } else {
                        set fec_vc_cparam [lindex $fec_vc_id_start [expr $i+1]]
                        if {$fec_vc_cparam == ""} {
                            set fec_vc_cparam [lindex $fec_vc_id_start end]
                        }
                    }
                    set fec_vc_id_start_li $fec_vc_cparam
                    
                    if {[info exists fec_vc_label_mode] && \
                            [info exists fec_vc_label_value_start] && \
                            [info exists fec_vc_label_value_step]} {
                        # get last label mode, if it' increment, do as it says
                        set fec_vc_cparam [lindex $fec_vc_label_mode $i]
                        if {$fec_vc_cparam == ""} {
                            set fec_vc_cparam [lindex $fec_vc_label_mode end]
                        }
                        if {$fec_vc_cparam == "increment_label"} {
                            if {[lindex $fec_vc_label_value_start [expr $i+1]] == ""} {
                                # if there's no present value, increment the last one
                                # t_start is old val for *_start
                                set t_start [lindex $fec_vc_label_value_start $i]
                                if {$t_start == ""} {
                                    set t_start $fec_vc_label_value_start_li
                                }
                                set t_step $fec_vc_label_value_step
                                set fec_vc_cparam [expr $t_start + $t_step]
                            } else {
                                set fec_vc_cparam [lindex $fec_vc_label_value_start [expr $i+1]]
                            }
                            
                            set fec_vc_label_value_start_li $fec_vc_cparam
                        }
                    }
                    
                    if {[info exists fec_vc_ce_ip_addr] && \
                            [info exists fec_vc_ce_ip_addr_outer_step]} {
                        if {[lindex $fec_vc_ce_ip_addr [expr $i+1]] == ""} {
                            # if there's no present value, increment the last one
                            set t_start [lindex $fec_vc_ce_ip_addr $i]
                            if {$t_start == ""} {
                                set t_start $fec_vc_ce_ip_addr_li
                            }
                            set t_step $fec_vc_ce_ip_addr_outer_step
                            set fec_vc_cparam [increment_ipv4_address_hltapi $t_start $t_step]
                        } else {
                            set fec_vc_cparam [lindex $fec_vc_ce_ip_addr [expr $i+1]]
                        }
                        
                        set fec_vc_ce_ip_addr_li $fec_vc_cparam
                    }
                    
                    # update all other params that may be lists
                    foreach fec_vc_p $fec_vc_params_lists {
                        if {[info exists $fec_vc_p]} {
                            set fec_vc_cparam [lindex [set $fec_vc_p] [expr $i+1]]
                            if {$fec_vc_cparam == ""} {
                                set fec_vc_cparam [lindex [set $fec_vc_p] end]
                            }
                            if {[array exists translate_$fec_vc_p] && [info exists translate_${fec_vc_p}($fec_vc_cparam)]} {
                                set fec_vc_cparam [set translate_${fec_vc_p}($fec_vc_cparam)]
                            }
                            set ${fec_vc_p}_li $fec_vc_cparam
                        }
                    }
                }
                if {[expr $objectCount % $objectMaxCount] != 0} {
                    ixNet commit
                }
                set l2_intf_objref    [ixNet remapIds $l2_intf_objref]
                if {$l2_vc_ranges != ""} {
                    set l2_vc_ranges  [ixNet remapIds $l2_vc_ranges]
                }
                if {$l2_vc_ip_ranges != ""} {
                    set l2_vc_ip_ranges  [ixNet remapIds $l2_vc_ip_ranges]
                }
                if {$l2_vc_mac_ranges != ""} {
                    set l2_vc_mac_ranges  [ixNet remapIds $l2_vc_mac_ranges]
                }
                keylset returnList lsp_intf                 $l2_intf_objref
                keylset returnList lsp_handle               $l2_intf_objref
                keylset returnList lsp_vc_range_handles     $l2_vc_ranges
                keylset returnList lsp_vc_ip_range_handles  $l2_vc_ip_ranges
                keylset returnList lsp_vc_mac_range_handles $l2_vc_mac_ranges
            }

            default {
                keylset returnList status $::FAILURE
                keylset returnList log "Tried to create unknown FEC \
                        range type: $fec_type. Please use 'ipv4_prefix', \
                        'host_addr' or 'vc'."
                return $returnList
            }
        }
    }

    if {$mode == "modify"} {
        if {![info exists lsp_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode,\
                    the -lsp_handle option must be specified."
            return $returnList
        }
        # Remove defaults
        removeDefaultOptionVars $opt_args $args

        # Advertising FEC range
        if {[regexp {advFecRange} $lsp_handle]} {
            set adv_fec_range_args ""
            if {[info exists egress_label_mode]} {
                lappend adv_fec_range_args -labelMode \
                        $translate_egress_label_mode($egress_label_mode)
                if {$egress_label_mode == "imnull"} {
                    set label_value_start 3
                } elseif {$egress_label_mode == "exnull"} {
                    set label_value_start 0
                }
            }
            if {[info exists fec_ip_prefix_start]} {
                lappend adv_fec_range_args -firstNetwork \
                        $fec_ip_prefix_start
            }
            if {[info exists num_lsps]} {
                lappend adv_fec_range_args -numberOfNetworks $num_lsps
            }
            if {[info exists fec_ip_prefix_length]} {
                lappend adv_fec_range_args -maskWidth $fec_ip_prefix_length
            }
            if {[info exists label_value_start]} {
                lappend adv_fec_range_args -labelValueStart $label_value_start
            }
            if {[info exists packing_enable]} {
                lappend adv_fec_range_args -enablePacking \
                        $truth($packing_enable)
            }
            if {$adv_fec_range_args != ""} {
                set retCode [ixNetworkNodeSetAttr $lsp_handle $adv_fec_range_args -commit]
                if {[keylget retCode status] != $::SUCCESS} {
                    return $retCode
                }
            }
        }

        # Requesting FEC range
        if {[regexp {reqFecRange} $lsp_handle]} {
            set req_fec_range_args ""
            if {[info exists fec_host_addr]} {
                lappend req_fec_range_args -firstNetwork $fec_host_addr
            }
            if {[info exists fec_host_prefix_length]} {
                lappend req_fec_range_args -maskWidth \
                        $fec_host_prefix_length
            }
            if {[info exists hop_count_tlv_enable]} {
                lappend req_fec_range_args -enableHopCount \
                        $truth($hop_count_tlv_enable)
            }
            if {[info exists hop_count_value]} {
                lappend req_fec_range_args -hopCount $hop_count_value
            }
            if {[info exists next_hop_peer_ip]} {
                lappend req_fec_range_args -nextHopPeer $next_hop_peer_ip
            }
            if {[info exists num_routes]} {
                lappend req_fec_range_args -numberOfRoutes $num_routes
            }
            if {[info exists stale_request_time]} {
                lappend req_fec_range_args -staleReqTime $stale_request_time
            }
            if {[info exists stale_timer_enable]} {
                lappend req_fec_range_args -enableStateTimer \
                        $truth($stale_timer_enable)
            }
            if {$req_fec_range_args != ""} {
                set retCode [ixNetworkNodeSetAttr $lsp_handle $req_fec_range_args -commit]
                if {[keylget retCode status] != $::SUCCESS} {
                    return $retCode
                }
            }
        }

        # L2 Interface
        if {[regexp {l2Interface:\d*$} $lsp_handle]} {
            set l2_intf_args ""
            if {[info exists fec_vc_group_id]} {
                lappend l2_intf_args -groupId $fec_vc_group_id
            }
            if {[info exists fec_vc_type]} {
                lappend l2_intf_args -type \
                        $translate_fec_vc_type($fec_vc_type)
            }
            if {[info exists fec_vc_group_count]} {
                lappend l2_intf_args -count $fec_vc_group_count
            }
            if {$l2_intf_args != ""} {
                set retCode [ixNetworkNodeSetAttr $lsp_handle $l2_intf_args -commit]
                if {[keylget retCode status] != $::SUCCESS} {
                    return $retCode
                }
            }
            # VC ranges
            set l2_vc_ranges_list [ixNetworkNodeGetList $lsp_handle l2VcRange -all]
        }

        # VC range
        if {[regexp {l2VcRange:\d*$} $lsp_handle]} {
            set l2_vc_ranges_list $lsp_handle
        }
        if {[info exists l2_vc_ranges_list]} {
            set l2_vc_range_args ""
            set l2_vc_range_options {
                fec_vc_cbit               enableCBit
                fec_vc_id_count           count
                fec_vc_id_start           vcId
                fec_vc_id_step            vcIdStep
                fec_vc_intf_mtu           mtu
                fec_vc_intf_mtu_enable    enableMtuPresent
                fec_vc_label_mode         labelMode
                fec_vc_label_value_start  labelStart
                fec_vc_peer_address       peerAddress
                packing_enable            enablePacking
                fec_vc_atm_enable         enableMaxAtmPresent
                fec_vc_atm_max_cells      maxNumberOfAtmCells
                fec_vc_cem_option         cemOption
                fec_vc_cem_option_enable  enableCemOption
                fec_vc_cem_payload        cemPayload
                fec_vc_cem_payload_enable enableCemPayload
                fec_vc_ce_ip_addr         ceIpAddress
                provisioning_model        provisioningModel
            }
            foreach {hltOpt ixnOpt} $l2_vc_range_options {
                if {[info exists $hltOpt]} {
                    if {[array exists translate_$hltOpt] && \
                            [info exists translate_${hltOpt}([set $hltOpt])]} {
                        lappend l2_vc_range_args -${ixnOpt} \
                                [set translate_${hltOpt}([set $hltOpt])]
                    } else {
                        lappend l2_vc_range_args -${ixnOpt} [set $hltOpt]
                    }
                }
            }
            if {[info exists fec_vc_intf_desc]} {
                lappend l2_vc_range_args -enableDescriptionPresent true
                lappend l2_vc_range_args -description $fec_vc_intf_desc
            }
            if {[info exists fec_vc_ce_ip_addr_inner_step]} {
                lappend l2_vc_range_args -step \
                        [ip_addr_to_num $fec_vc_ce_ip_addr_inner_step]
            }
            foreach l2_vc_range_objref $l2_vc_ranges_list {
                if {$l2_vc_range_args != ""} {
                    set retCode [ixNetworkNodeSetAttr $l2_vc_range_objref $l2_vc_range_args -commit]
                    if {[keylget retCode status] != $::SUCCESS} {
                        return $retCode
                    }
                }
                # IP Range
                if {[ixNet getAttribute $l2_vc_range_objref/l2VcIpRange -enabled]} {
                    set l2_vc_ip_range_args ""
                    set l2_vc_ip_range_options {
                        fec_vc_ip_range_addr_count    numHosts
                        fec_vc_ip_range_addr_start    startAddress
                        fec_vc_ip_range_prefix_len    mask
                    }
                    foreach {hltOpt ixnOpt} $l2_vc_ip_range_options {
                        if {[info exists $hltOpt]} {
                            if {[array exists translate_$hltOpt] && \
                                    [info exists translate_${hltOpt}([set $hltOpt])]} {
                                lappend l2_vc_ip_range_args -${ixnOpt} \
                                        [set translate_${hltOpt}([set $hltOpt])]
                            } else {
                                lappend l2_vc_ip_range_args -${ixnOpt} [set $hltOpt]
                            }
                        }
                    }
                    if {[info exists fec_vc_ip_range_addr_step]} {
                        lappend l2_vc_ip_range_args -incrementBy \
                                [ip_addr_to_num $fec_vc_ip_range_addr_step]
                    }
                    if {$l2_vc_ip_range_args != ""} {
                        set result [ixNetworkNodeSetAttr \
                                $l2_vc_range_objref/l2VcIpRange \
                                $l2_vc_ip_range_args -commit]
                        
                        if {[keylget result status] == $::FAILURE} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Unable to modify L2 VC IP range.\
                                    [keylget result log]."
                            return $returnList
                        }
                    }
                }
                # MAC Range
                if {[ixNet getAttribute $l2_vc_range_objref/l2MacVlanRange -enabled]} {
                    if {[info exists fec_vc_mac_range_start]} {
                        set fec_vc_mac_range_start [convertToIxiaMac \
                                $fec_vc_mac_range_start ":"]
                    }
                    set l2_vc_mac_range_args ""
                    set l2_vc_mac_range_options {
                        fec_vc_mac_range_count          count
                        fec_vc_mac_range_first_vlan_id  firstVlanId
                        fec_vc_mac_range_repeat_mac     enableRepeatMac
                        fec_vc_mac_range_same_vlan      enableSameVlan
                        fec_vc_mac_range_start          startMac
                        fec_vc_mac_range_vlan_enable    enableVlan
                    }
                    foreach {hltOpt ixnOpt} $l2_vc_mac_range_options {
                        if {[info exists $hltOpt]} {
                            if {[array exists translate_$hltOpt] && \
                                    [info exists translate_${hltOpt}([set $hltOpt])]} {
                                lappend l2_vc_mac_range_args -${ixnOpt} \
                                        [set translate_${hltOpt}([set $hltOpt])]
                            } else {
                                lappend l2_vc_mac_range_args -${ixnOpt} [set $hltOpt]
                            }
                        }
                    }
                    if {$l2_vc_mac_range_args != ""} {
                        set result [ixNetworkNodeSetAttr \
                                $l2_vc_range_objref/l2MacVlanRange \
                                $l2_vc_mac_range_args -commit]
                                
                        if {[keylget result status] == $::FAILURE} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Unable to modify L2 VC MAC range.\
                                    [keylget result log]."
                            return $returnList
                        }
                    }
                }
            }
        }
        # IP Range
        if {[regexp {l2VcIpRange$} $lsp_handle]} {
            set l2_vc_ip_range_args ""
            set l2_vc_ip_range_options {
                fec_vc_ip_range_addr_count    numHosts
                fec_vc_ip_range_addr_start    startAddress
                fec_vc_ip_range_prefix_len    mask
            }
            foreach {hltOpt ixnOpt} $l2_vc_ip_range_options {
                if {[info exists $hltOpt]} {
                    if {[array exists translate_$hltOpt] && \
                            [info exists translate_${hltOpt}([set $hltOpt])]} {
                        lappend l2_vc_ip_range_args -${ixnOpt} \
                                [set translate_${hltOpt}([set $hltOpt])]
                    } else {
                        lappend l2_vc_ip_range_args -${ixnOpt} [set $hltOpt]
                    }
                }
            }
            if {[info exists fec_vc_ip_range_addr_step]} {
                lappend l2_vc_ip_range_args -incrementBy \
                        [ip_addr_to_num $fec_vc_ip_range_addr_step]
            }
            if {$l2_vc_ip_range_args != ""} {
                set result [ixNetworkNodeSetAttr \
                        $lsp_handle \
                        $l2_vc_ip_range_args -commit]
                
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to modify L2 VC IP range.\
                            [keylget result log]."
                    return $returnList
                }
            }
        }
        # MAC range
        if {[regexp {l2MacVlanRange$} $lsp_handle]} {
            if {[info exists fec_vc_mac_range_start]} {
                set fec_vc_mac_range_start [convertToIxiaMac \
                        $fec_vc_mac_range_start ":"]
            }
            set l2_vc_mac_range_args ""
            set l2_vc_mac_range_options {
                fec_vc_mac_range_count          count
                fec_vc_mac_range_first_vlan_id  firstVlanId
                fec_vc_mac_range_repeat_mac     enableRepeatMac
                fec_vc_mac_range_same_vlan      enableSameVlan
                fec_vc_mac_range_start          startMac
                fec_vc_mac_range_vlan_enable    enableVlan
            }
            foreach {hltOpt ixnOpt} $l2_vc_mac_range_options {
                if {[info exists $hltOpt]} {
                    if {[array exists translate_$hltOpt] && \
                            [info exists translate_${hltOpt}([set $hltOpt])]} {
                        lappend l2_vc_mac_range_args -${ixnOpt} \
                                [set translate_${hltOpt}([set $hltOpt])]
                    } else {
                        lappend l2_vc_mac_range_args -${ixnOpt} [set $hltOpt]
                    }
                }
            }
            if {$l2_vc_mac_range_args != ""} {
                set result [ixNetworkNodeSetAttr \
                        $lsp_handle \
                        $l2_vc_mac_range_args -commit]
                        
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to modify L2 VC MAC range.\
                            [keylget result log]."
                    return $returnList
                }
            }
        }
    }

    return $returnList
}


proc ::ixia::ixnetwork_ldp_control { args man_args opt_args } {
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
                        [keylget result vport_objref]/protocols/ldp
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
                keylset returnList log "Failed to get the LDP protocol\
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
            keylset returnList log "Failed to start LDP on the $vport_objref\
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
                    keylset returnList log "Failed to start LDP on the\
                            $vport_objref port. Error code: $retCode."
                    return $returnList
                }
                after 1000
                debug "ixNetworkExec [list start $protocol_objref]"
                if {[catch {ixNetworkExec [list start $protocol_objref]} retCode] || \
                        ([string first "::ixNet::OK" $retCode] == -1)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to start LDP on the\
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
                    keylset returnList log "Failed to start LDP on the\
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
                    keylset returnList log "Failed to start LDP on the\
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




proc ::ixia::ixnetwork_ldp_info { args man_args } {
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    if {![regexp {^(.*)/protocols/ldp/router:\d+$} $handle {} port_objref]} {
        keylset returnList status $::FAILURE
        keylset returnList log "The handle '$handle' is not a valid\
                LDP router handle."
        return $returnList
    }
    keylset returnList status $::SUCCESS

    if {$mode == "state"} {
        keylset returnList status $::FAILURE
        keylset returnList log "The 'state' mode is not supported.\
                Please use 'stats', 'clear_stats', 'settings', 'neighbors' or\
                'lsp_labels'."
        return $returnList
    }

    if {$mode == "stats"} {
        set port_handle [ixNetworkGetRouterPort $port_objref]
        set port_handles $port_handle
        array set stats_array_aggregate {
            "Port Name"
                    port_name
            "Basic Sess. Up"
                    basic_sessions
            "Targeted Sess. Up"
                    targeted_sessions_running
            "Targeted Sess. Configured"
                    targeted_sessions_configured
            "Label Abort Tx"
                    abort_tx
            "Label Abort Rx"
                    abort_rx
            "Label Request Tx"
                    req_tx
            "Label Request Rx"
                    req_rx
            "Label Mapping Tx"
                    map_tx
            "Label Mapping Rx"
                    map_rx
            "Label Release Tx"
                    release_tx
            "Label Release Rx"
                    release_rx
            "Label Withdraw Tx"
                    withdraw_tx
            "Label Withdraw Rx"
                    withdraw_rx
            "Label Notification Tx"
                    notif_tx
            "Label Notification Rx"
                    notif_rx
            "Non Existent State Count"
                    non_existent_state_count
            "Initialized State Count"
                    initialized_state_count
            "Open Sent State Count"
                    open_state_count
            "Operational State Count"
                    operational_state_count
            "Established LSP Ingress"
                    established_lsp_ingress
            "Established LSP Egress"
                    established_lsp_egress
            "PW Status Down"
                    pw_status_down
            "PW Status Notification Tx"
                    pw_status_notif_tx
            "PW Status Notification Rx"
                    pw_status_notif_rx
            "PW Status Cleared Tx"
                    pw_status_cleared_tx
            "PW Status Cleared Rx"
                    pw_status_cleared_rx
        }
        
        set statistic_types {
            aggregate "LDP Aggregated Statistics"
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

        keylset returnList routing_protocol     "N/A"
        keylset returnList ip_address           "N/A"
        keylset returnList elapsed_time         "N/A"
        keylset returnList linked_hellos_tx     "N/A"
        keylset returnList linked_hellos_rx     "N/A"
        keylset returnList targeted_hellos_tx   "N/A"
        keylset returnList targeted_hellos_rx   "N/A"
        keylset returnList total_setup_time     "N/A"
        keylset returnList min_setup_time       "N/A"
        keylset returnList max_setup_time       "N/A"
        keylset returnList num_lsps_setup       "N/A"
        keylset returnList max_peers            "N/A"
        keylset returnList max_lsps             "N/A"
        keylset returnList peer_count           "N/A"
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

    if {$mode == "settings"} {
        array set translate_label_adv [list         \
                unsolicited         unsolicited     \
                onDemand            on_demand       \
                ]

        # Protocol interface settings
        set protocol_intf_objref [ixNetworkNodeGetList $handle interface]
        keylset returnList label_adv $translate_label_adv([ixNet getAttribute \
                $protocol_intf_objref -advertisingMode])
        keylset returnList label_space [ixNet getAttribute \
                $protocol_intf_objref -labelSpaceId]

        # Interface settings
        set intf_objref [ixNet getAttribute $protocol_intf_objref \
                -protocolInterface]
        set intf_ip [ixNet getAttribute $intf_objref/ipv4 -ip]
        keylset returnList intf_ip_addr $intf_ip
        keylset returnList ip_address $intf_ip
        keylset returnList vpi [ixNet getAttribute $intf_objref/atm -vci]
        keylset returnList vci [ixNet getAttribute $intf_objref/atm -vpi]

        # Protocol settings
        regexp {(.*/protocols/ldp)/router:\d} $handle {} protocol_objref
        set hello_hold_time [ixNet getAttribute $protocol_objref -helloHoldTime]
        keylset returnList hold_time $hello_hold_time
        keylset returnList hello_hold_time $hello_hold_time
        keylset returnList hello_interval [ixNet getAttribute $protocol_objref \
                -helloInterval]
        keylset returnList targeted_hello [ixNet getAttribute $protocol_objref \
                -targetedHelloInterval]
        keylset returnList keepalive_holdtime [ixNet getAttribute \
                $protocol_objref -keepAliveHoldTime]
        set keepalive_interval [ixNet getAttribute $protocol_objref \
                -keepAliveInterval]
        keylset returnList keepalive_interval $keepalive_interval
        keylset returnList keepalive $keepalive_interval

        set atm_label_range_objref [ixNetworkNodeGetList $protocol_intf_objref \
                atmLabelRange]
        if {$atm_label_range_objref != [ixNet getNull] && \
                $atm_label_range_objref != ""} {
            keylset returnList atm_range_max_vpi \
                    [ixNet getAttribute $protocol_objref -maxVci]
            keylset returnList atm_range_max_vci \
                    [ixNet getAttribute $protocol_objref -maxVpi]
            keylset returnList atm_range_min_vpi \
                    [ixNet getAttribute $protocol_objref -minVci]
            keylset returnList atm_range_min_vci \
                    [ixNet getAttribute $protocol_objref -minVpi]
        } else {
            keylset returnList atm_range_max_vpi N/A
            keylset returnList atm_range_max_vci N/A
            keylset returnList atm_range_min_vpi N/A
            keylset returnList atm_range_min_vci N/A
        }

        keylset returnList transport_address    N/A
        keylset returnList label_type           N/A
        keylset returnList vc_direction         N/A
        keylset returnList atm_merge_capability N/A
        keylset returnList fr_merge_capability  N/A
        keylset returnList path_vector_limit    N/A
        keylset returnList max_pdu_length       N/A
        keylset returnList loop_detection       N/A
        keylset returnList config_seq_no        N/A
        keylset returnList max_lsps             N/A
        keylset returnList max_peers            N/A
        keylset returnList atm_label_range      N/A
        keylset returnList fr_label_range       N/A
    }

    if {$mode == "neighbors"} {
        if {[ixNet getAttribute $handle -enabled] == false} {
            keylset returnList status $::FAILURE
            keylset returnList log "Emulated router '$handle' is not\
                    enabled."
            return $returnList
       }

        set neighbors [list]
        set protocol_intf_list [ixNetworkNodeGetList $handle interface -all]

        if {$protocol_intf_list != [ixNet getNull]} {
            foreach protocol_intf $protocol_intf_list {
                # Refresh the list of learned labels
                ixNet exec refreshLearnedInfo $protocol_intf
                # TODO: get rid of 'after's (waiting for chip build)
                after 5000
                # Get the list of learned labels
                set learned_labels [ixNetworkNodeGetList $protocol_intf \
                        learnedIpv4Label -all]
                foreach learned_label $learned_labels {
                    lappend neighbors [ixNet getAttribute $learned_label \
                            -peerIpAddress]
                }
            }
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "No protocol interface found on\
                    emulated router '$handle'."
            return $returnList
        }

        if {[llength $neighbors] > 0} {
            keylset returnList neighbors [lsort -unique $neighbors]
        } else  {
            keylset returnList neighbors  N/A
        }
    }

    if {$mode == "lsp_labels"} {
        if {[ixNet getAttribute $handle -enabled] == false} {
            keylset returnList status $::FAILURE
            keylset returnList log "Emulated router '$handle' is not\
                    enabled."
            return $returnList
        }

        set prefix_list        [list]
        set prefix_length_list [list]
        set label_list         [list]
        set source_list        [list]
        set type_list          [list]
        set fec_type_list      [list]
        set vc_id_list         [list]
        set vc_type_list       [list]
        set group_id_list      [list]
        set vci_list           [list]
        set vpi_list           [list]
        set state_list         [list]
        set protocol_intf_list [ixNetworkNodeGetList $handle interface -all]

        if {$protocol_intf_list != [ixNet getNull]} {
            # Refresh the list of learned labels
            foreach protocol_intf $protocol_intf_list {
                ixNet exec refreshLearnedInfo $protocol_intf
            }
            # TODO: get rid of 'after's (waiting for chip build)
            after 5000
            # Get the list of learned labels
            foreach protocol_intf $protocol_intf_list {
                set learned_labels [ixNetworkNodeGetList $protocol_intf \
                        learnedIpv4Label -all]
                foreach learned_label $learned_labels {
                    lappend prefix_list         \
                            [ixNet getAttribute $learned_label -fec]
                    lappend prefix_length_list  \
                            [ixNet getAttribute $learned_label -fecPrefixLen]
                    lappend label_list          \
                            [ixNet getAttribute $learned_label -label]
                    lappend source_list         \
                            [ixNet getAttribute $learned_label -peerIpAddress]
                    lappend type_list           learned
                    lappend fec_type_list       ipv4_prefix
                    lappend vc_id_list          N/A
                    lappend vc_type_list        N/A
                    lappend group_id_list       N/A
                    lappend vci_list            N/A
                    lappend vpi_list            N/A
                    lappend state_list          N/A
                }
            }
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "No protocol interface found on\
                    emulated router '$handle'."
            return $returnList
        }

        keylset returnList prefix        $prefix_list
        keylset returnList prefix_length $prefix_length_list
        keylset returnList label         $label_list
        keylset returnList source        $source_list
        keylset returnList type          $type_list
        keylset returnList fec_type      $fec_type_list
        keylset returnList vc_id         $vc_id_list
        keylset returnList vc_type       $vc_type_list
        keylset returnList group_id      $group_id_list
        keylset returnList vci           $vci_list
        keylset returnList vpi           $vpi_list
        keylset returnList state         $state_list
    }

    return $returnList
}
