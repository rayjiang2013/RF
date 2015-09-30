##Library Header
# $Id: $
# Copyright © 2003-2009 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_ospf_api.tcl
#
# Purpose:
#    A script development library containing OSPF APIs for test automation with
#    the Ixia chassis.
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures contained within this library include:
#
#    - emulation_ospf_config
#    - emulation_ospf_topology_route_config
#    - emulation_ospf_control
#    - emulation_ospf_lsa_config
#
# Requirements:
#    utils_ospf.tcl, a library containing ospf specific tcl utilities
#    ixiaapiutils.tcl, a library containing tcl utilities
#    parseddashedargs.tcl, a library containing the parse_dashed_args procedure
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

proc ::ixia::emulation_ospf_config { args } {
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
                \{::ixia::emulation_ospf_config $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    variable new_ixnetwork_api

    ::ixia::utrackerLog $procName $args

    keylset returnList status $::SUCCESS

    # Arguments
    set man_args {
        -port_handle  REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -mode         CHOICES create delete modify enable disable
        -session_type CHOICES ospfv2 ospfv3
                      DEFAULT ospfv2
    }

    set ixnetwork_man_args {
        -mode         CHOICES create delete modify enable disable
        -session_type CHOICES ospfv2 ospfv3
                      DEFAULT ospfv2
    }

     set opt_args {
        -area_id                    IP
                                    DEFAULT 0.0.0.0
        -area_id_step               IP
        -area_type                  CHOICES external-capable ppp stub
        -authentication_mode        CHOICES null simple md5
        -count                      RANGE   1-2000
                                    DEFAULT 1
        -dead_interval              RANGE   1-65535
        -demand_circuit             CHOICES 0 1
                                    DEFAULT 0
        -enable_support_rfc_5838    CHOICES 0 1
                                    DEFAULT 0
        -graceful_restart_enable    CHOICES 0 1
        -handle
        -hello_interval             RANGE   1-65535
        -ignore_db_desc_mtu         CHOICES 0 1
                                    DEFAULT 0
        -interface_cost             RANGE   0-4294967295
        -intf_ip_addr               IP
        -intf_ip_addr_step          IP
        -intf_prefix_length         RANGE   1-128
        -interface_handle
        -instance_id                RANGE   0-255
                                    DEFAULT 0
        -instance_id_step           RANGE   0-255
                                    DEFAULT 0
        -loopback_ip_addr           IP
                                    DEFAULT 0.0.0.0
        -loopback_ip_addr_step      IP
                                    DEFAULT 0.0.0.0
        -lsa_discard_mode           CHOICES 0 1
        -mac_address_init           MAC
        -mac_address_step           MAC
                                    DEFAULT 0000.0000.0001
        -md5_key
        -md5_key_id                 RANGE   0-255
        -mtu                        RANGE   68-9216
        -network_type               CHOICES broadcast ptomp ptop
        -neighbor_intf_ip_addr      IP
        -neighbor_intf_ip_addr_step IP
        -neighbor_router_id         IPV4
        -neighbor_router_id_step    IPV4
                                    DEFAULT 0.0.1.0
        -option_bits                HEX
        -override_existence_check   CHOICES 0 1
                                    DEFAULT 0
        -override_tracking          CHOICES 0 1
                                    DEFAULT 0
        -password
        -reset
        -router_id                  IPV4
        -router_id_step             IPV4
                                    DEFAULT 0.0.1.0
        -router_priority            RANGE   0-255
        -te_enable                  CHOICES 0 1
        -te_max_bw                  REGEXP  ^[0-9]+
        -te_max_resv_bw             REGEXP  ^[0-9]+$
        -te_unresv_bw_priority0     REGEXP  ^[0-9]+$
        -te_unresv_bw_priority1     REGEXP  ^[0-9]+$
        -te_unresv_bw_priority2     REGEXP  ^[0-9]+$
        -te_unresv_bw_priority3     REGEXP  ^[0-9]+$
        -te_unresv_bw_priority4     REGEXP  ^[0-9]+$
        -te_unresv_bw_priority5     REGEXP  ^[0-9]+$
        -te_unresv_bw_priority6     REGEXP  ^[0-9]+$
        -te_unresv_bw_priority7     REGEXP  ^[0-9]+$
        -te_metric                  RANGE   1-2147483647
        -te_router_id               IPV4
        -vlan                       CHOICES 0 1
        -vlan_id_mode               CHOICES fixed increment
                                    DEFAULT increment
        -vlan_id                    RANGE   0-4096
        -vlan_id_step               RANGE   0-4096
                                    DEFAULT 1
        -vlan_user_priority         RANGE   0-7
                                    DEFAULT 0
        -atm_encapsulation          CHOICES VccMuxIPV4Routed
                                    CHOICES VccMuxIPV6Routed
                                    CHOICES VccMuxBridgedEthernetFCS
                                    CHOICES VccMuxBridgedEthernetNoFCS
                                    CHOICES LLCRoutedCLIP
                                    CHOICES LLCBridgedEthernetFCS
                                    CHOICES LLCBridgedEthernetNoFCS
        -bfd_registration           CHOICES 0 1
                                    DEFAULT 0
        -enable_dr_bdr              CHOICES 0 1
        -vci                        RANGE   0-65535
                                    DEFAULT 10
        -vci_step                   DEFAULT 1
        -vpi                        RANGE   0-255
                                    DEFAULT 32
        -vpi_step                   DEFAULT 1
        -get_next_session_mode      CHOICES from_array from_server
                                    DEFAULT from_array
        -no_write                   FLAG
        -te_admin_group             REGEXP ^[0-9]{2}([:.]{1}[0-9]{2}){3}$
        -validate_received_mtu      CHOICES 0 1 
                                    DEFAULT 1
        -graceful_restart_helper_mode_enable CHOICES 0 1 
                                    DEFAULT 0
        -strict_lsa_checking        CHOICES 0 1
                                    DEFAULT 1
        -support_reason_sw_restart  CHOICES 0 1
                                    DEFAULT 1
        -support_reason_sw_reload_or_upgrade    CHOICES 0 1
                                    DEFAULT 1
        -support_reason_switch_to_redundant_processor_control   CHOICES 0 1
                                    DEFAULT 1
        -support_reason_unknown     CHOICES 0 1
                                    DEFAULT 0
    }

    set ixnetwork_opt_args {
        -port_handle  REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
    }
    #not using lappend because that will break the existing list from opt_args
    set ixnetwork_opt_args "        \
            $ixnetwork_opt_args     \
            $opt_args"
   
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_ospf_config $args $ixnetwork_man_args $ixnetwork_opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList log "ERROR in $procName:\
                    [keylget returnList log]"
        }
        return $returnList
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args

    if { $mode == "disable" } {
        set enable $::false
    } else {
        set enable $::true
    }

    if {$mode == "modify" || $mode == "disable" } {
        removeDefaultOptionVars $opt_args $args
    }

    if {![info exists intf_prefix_length]} {
        if {$session_type == "ospfv2"} {
            set intf_prefix_length 24
        } else {
            set intf_prefix_length 64
        }
    }
    
    array set truth {
        0     false
        1     true
        false 0
        true  1
    }
    set netmask "0.0.0.0"
    
    # Configure the Protocol Server commands for OSPFv2 or OSPFv3
    if {$session_type == "ospfv2"} {
        set netmask [getIpV4MaskFromWidth $intf_prefix_length]
        # OSPFv2 Interface
        array set ospfArray                  [list                      \
                areaId                       area_id                    \
                linkType                     area_type                  \
                authenticationMethod         authentication_mode        \
                connectToDut                 connect_dut                \
                deadInterval                 dead_interval              \
                enable                       enable                     \
                helloInterval                hello_interval             \
                protocolInterfaceDescription interface_description      \
                ipMask                       netmask                    \
                ipAddress                    ip_address                 \
                metric                       interface_cost             \
                md5Key                       md5_key                    \
                md5KeyId                     md5_key_id                 \
                mtuSize                      mtu                        \
                neighborRouterId             neighbor_router_id         \
                networkType                  network_type               \
                options                      option_bits                \
                password                     password                   \
                priority                     router_priority            \
                enableTrafficEngineering     te_enable                  \
                maxBandwidth                 te_max_bw                  \
                maxReservableBandwidth       te_max_resv_bw             \
                unreservedBandwidthPriority0 te_unresv_bw_priority0     \
                unreservedBandwidthPriority1 te_unresv_bw_priority1     \
                unreservedBandwidthPriority2 te_unresv_bw_priority2     \
                unreservedBandwidthPriority3 te_unresv_bw_priority3     \
                unreservedBandwidthPriority4 te_unresv_bw_priority4     \
                unreservedBandwidthPriority5 te_unresv_bw_priority5     \
                unreservedBandwidthPriority6 te_unresv_bw_priority6     \
                unreservedBandwidthPriority7 te_unresv_bw_priority7     \
                linkMetric                   te_metric                  \
                enableBFDRegistration        bfd_registration           \
                enableValidateMtu            validate_received_mtu      \
                ]

        # OSPFv2 Router
        array set ospfRouterArray        [list                   \
                routerId                 router_id               \
                enable                   enable                  \
                enableDiscardLearnedLsas lsa_discard_mode        \
                enableGracefulRestart    graceful_restart_enable \
                ]

        # Set up enum converter list
        foreach dataset {                                              \
                {broadcast        ospfBroadcast}                       \
                {nbma             ospfBroadcast}                       \
                {ptomp            ospfPointToMultipoint}               \
                {ptop             ospfPointToPoint}                    \
                {virtual_link     ospfBroadcast}                       \
                {null             ospfInterfaceAuthenticationNull}     \
                {simple           ospfInterfaceAuthenticationPassword} \
                {md5              ospfInterfaceAuthenticationMD5}      \
                {ppp              ospfInterfaceLinkPointToPoint}       \
                {external-capable ospfInterfaceLinkTransit}            \
                {stub             ospfInterfaceLinkStub}               } {

            foreach {dataName enumName} $dataset {}
            if {[info exists ::$enumName]} {
                set enumList($dataName) [set ::$enumName]
            }
        }

    } elseif {$session_type == "ospfv3"} {

        # OSPFv3 Interface
        array set ospfArray                  [list                 \
                areaId                       area_id               \
                deadInterval                 dead_interval         \
                enable                       enable                \
                helloInterval                hello_interval        \
                instanceId                   instance_id           \
                type                         network_type          \
                options                      option_bits           \
                protocolInterfaceDescription interface_description \
                enableBFDRegistration        bfd_registration      \
                enableIgnoreDBDescMTU        ignore_db_desc_mtu    \
                ]

        # OSPFv3 Router
        array set ospfRouterArray                                       [list                               \
                enable                                                  enable                              \
                enableDiscardLearnedLsas                                lsa_discard_mode                    \
                enableSupportRfc5838                                    enable_support_rfc_5838             \
                routerId                                                router_id                           \
                enableGracefulRestartHelperMode                         graceful_restart_helper_mode_enable \
                enableStrictLsaChecking                                 strict_lsa_checking                 \
                enableSupportReasonSwRestart                            support_reason_sw_restart           \
                enableSupportReasonSwReloadOrUpgrade                    support_reason_sw_reload_or_upgrade \
                enableSupportReasonSwitchToRedundantControlProcessor    support_reason_switch_to_redundant_processor_control \
                enableSupportReasonUnknown                              support_reason_unknown              \
                ]

        foreach dataset {                                              \
                {broadcast        ospfV3InterfaceBroadcast}            \
                {ptop             ospfV3InterfacePointToPoint}         \
                {null             ospfInterfaceAuthenticationNull}     \
                {simple           ospfInterfaceAuthenticationPassword} \
                {md5              ospfInterfaceAuthenticationMD5}      \
                {ppp              ospfInterfaceLinkPointToPoint}       \
                {external-capable ospfInterfaceLinkTransit}            \
                {stub             ospfInterfaceLinkStub}               \
                {software_restart softwareRestart}                     \
                {software_reload_upgrade softwareReloadOrUpgrade}      \
                {switch_to_redundant_control_processor switchToRedundantControlProcessor} \
                {unknown unknown}                                   } {

            foreach {dataName enumName} $dataset {}
            if {[info exists ::$enumName]} {
                set enumList($dataName) [set ::$enumName]
            }
        }
    }

    set ospf_neighbor_list [list]
    set port_list [format_space_port_list $port_handle]
    set interface [lindex $port_list 0]
    foreach {chasNum cardNum portNum} $interface {}
    ::ixia::addPortToWrite $chasNum/$cardNum/$portNum

    # Check if OSPF package has been installed on the port
    if {$session_type == "ospfv2"} {
        if {[catch {ospfServer select $chasNum $cardNum $portNum} retCode]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: The OSPFv2 protocol\
                    has not been installed on port or is not supported on port: \
                    $chasNum/$cardNum/$portNum."
            return $returnList
        }
    } elseif {$session_type == "ospfv3"}  {
        # Check if OSPFv3 protocol is supported
        if {![port isValidFeature $chasNum $cardNum $portNum \
                    portFeatureProtocolOSPFv3]} {

            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : This card does not\
                    support OSPFv3 protocol."
            return $returnList
        }
        if {[catch {ospfV3Server select $chasNum $cardNum $portNum} retCode]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: The OSPFv3 protocol\
                    has not been installed on port or is not supported on port: \
                    $chasNum/$cardNum/$portNum."
            return $returnList
        }
    }

    # If the user is modifying/enabling/disabling/deleting an existing
    # configuration, an input option handle should exist.  A flag will be set to
    # indicate this combination.
    set ospf_modify_flag 0

    # Check if the call is for modify or delete
    if {$mode == "modify" || $mode == "delete" || $mode == "disable" || \
            $mode == "enable"} {
        if {![info exists handle]} {
            keylset returnList log "ERROR in $procName: When -mode is $mode,\
                    the -handle option must be used.  Please set this value."
            keylset returnList status $::FAILURE
            return $returnList
        } elseif {[llength $handle] > 1} {
            keylset returnList log "ERROR in $procName: When -mode is $mode,\
                    -handle may only contain one value.  Current: $handle"
            keylset returnList status $::FAILURE
            return $returnList
        } else {
            set ospf_modify_flag 1
        }

        if {$mode != "modify"} {
            # Enable/Disable/Delete OSPFvX Router
            set actionOspf_status [::ixia::actionOspf $chasNum $cardNum \
                    $portNum $session_type $mode $handle]

            if {[keylget actionOspf_status status] != $::SUCCESS} {
                keylset returnList log "ERROR in $procName: Failed to\
                        $mode the OSPF with -handle $handle on port $chasNum\
                        $cardNum $portNum.  Error returned was\
                        [keylget actionOspf_status log]"
                keylset returnList status $::FAILURE
                return $returnList
            }
            ::ixia::updateOspfHandleArray $mode $port_handle $handle
            set retCode [::ixia::writePortListConfig ]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        ::ixia::writePortListConfig failed. \
                        [keylget retCode log]"
                return $returnList
            }

            keylset returnList handle $handle
            return $returnList
        }
    }

    # Flag for Stub interface
    set stub_flag 0
    if {[info exists loopback_ip_addr] && ($loopback_ip_addr != "0.0.0.0")} {
        set stub_flag 1
    }


    # Configure the Protocol Server commands for OSPFv2 or OSPFv3
    # Set the default options bit
    if {$session_type == "ospfv2"} {
        set serverCommand     "ospfServer"
        set routerCommand     "ospfRouter"
        set interfaceCommand  "ospfInterface"
        set statsCommand      "enableOspfStats"
        set serviceCommand    "enableOspfService"
        set ospf_option_bits [expr              \
                $::ospfOptionBitExternalRouting|\
                $::ospfOptionBitLSANoForward    ]

        if  {[info exists demand_circuit] && $demand_circuit} {
            set ospf_option_bits [expr \
                    $ospf_option_bits| \
                    $::ospfOptionBitDemandCircuit]
        }
    } elseif {$session_type == "ospfv3"} {
        set serverCommand      "ospfV3Server"
        set routerCommand      "ospfV3Router"
        set interfaceCommand   "ospfV3Interface"
        set statsCommand       "enableOspfV3Stats"
        set serviceCommand     "enableOspfV3Service"
        set ospf_option_bits [expr            \
                $::ospfV3InterfaceOptionV6Bit|\
                $::ospfV3InterfaceOptionEBit |\
                $::ospfV3InterfaceOptionRBit  ]

        if  {[info exists demand_circuit] && $demand_circuit} {
            set ospf_option_bits [expr  \
                    $ospf_option_bits|  \
                    $::ospfV3InterfaceOptionDCBit]
        }
    }

    # Change the Area ID from IP to integer if any
    if {[info exists area_id]} {
        set area_id [::ixia::ip_addr_to_num $area_id]
    }
    if {[info exists area_id_step]} {
        set area_id_step [::ixia::ip_addr_to_num $area_id_step]
    }
    # Now take care of the protocol server and interfaces
    if {$mode == "create"} {

        set enable $::true

        if {![info exists vlan] && [info exists vlan_id]} {
            set vlan $::true
        }

        #################################
        #  CONFIGURE THE IXIA INTERFACES
        #################################
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


        # If IPv6 address, expand all the fields
        if {$ip_version == 6} {
            set intf_ip_addr               [::ipv6::expandAddress \
                    $intf_ip_addr]
            set intf_ip_addr_step          [::ipv6::expandAddress \
                    $intf_ip_addr_step]
            if {[info exists neighbor_intf_ip_addr]} {
                set neighbor_intf_ip_addr      [::ipv6::expandAddress \
                        $neighbor_intf_ip_addr]
            }
            set neighbor_intf_ip_addr_step [::ipv6::expandAddress \
                    $neighbor_intf_ip_addr_step]
        }

        set config_options \
                "-port_handle             port_handle                \
                -count                    count                      \
                -ip_address               intf_ip_addr               \
                -ip_address_step          intf_ip_addr_step          \
                -ip_version               ip_version                 \
                -mac_address              mac_address_init           \
                -netmask                  intf_prefix_length         \
                -vlan_id                  vlan_id                    \
                -vlan_id_mode             vlan_id_mode               \
                -vlan_id_step             vlan_id_step               \
                -vlan_user_priority       vlan_user_priority         \
                -loopback_ip_address      loopback_ip_addr           \
                -loopback_ip_address_step loopback_ip_addr_step      \
                -atm_vpi                  vpi                        \
                -atm_vpi_step             vpi_step                   \
                -atm_vci                  vci                        \
                -atm_vci_step             vci_step                   \
                -mtu                      mtu                        \
                -gateway_ip_address       neighbor_intf_ip_addr      \
                -gateway_ip_address_step  neighbor_intf_ip_addr_step \
                -no_write                 no_write                   "

        ## passed in only those options that exists
        set config_param ""
        foreach {option value_name} $config_options {
            if {[info exists $value_name]} {
                append config_param "$option [set $value_name] "
            }
        }

        set intf_status [eval ixia::protocol_interface_config \
                $config_param]

        # Check status
        if {[keylget intf_status status] != $::SUCCESS} {
            keylset returnList log "ERROR in $procName:\
                    [keylget intf_status log]"
            keylset returnList status $::FAILURE
            return $returnList
        }

        # For OSPF, we need the interface description and Stub interface
        # description if needed
        set desc_list [keylget intf_status description]
        set loop_list [keylget intf_status loopback_description]
    }

    # Change the Options Bits from HEX to INT if needed
    if {[info exists option_bits]} {
        if {[expr {$option_bits & 0x8}]} {
            if {[info exists area_id] && ($area_id == 0)} {
                keylset returnList log "ERROR in $procName: Area number can't\
                        be 0 for a NSSA area."
                keylset returnList status $::FAILURE
                return  $returnList
            }
            if {[expr {$option_bits & 0x2}]} {
                keylset returnList log "ERROR in $procName: Can't have external\
                        routing and NSSA capability at the same time."
                keylset returnList status $::FAILURE
                return  $returnList
            }
        }
        set option_bits [format %02i $option_bits]
    } else {
        set option_bits $ospf_option_bits
    }

    # Select Protocol Server on Ixia port
    if {[$serverCommand select $chasNum $cardNum $portNum]} {
        keylset returnList log "ERROR in $procName: Failure on call to\
                $serverCommand select $chasNum $cardNum $portNum."
        keylset returnList status $::FAILURE
        return  $returnList
    }

    # Reset flag
    if {[info exists reset]} {
        $serverCommand clearAllRouters
        ::ixia::updateOspfHandleArray reset $port_handle NULL $session_type
    }
    if {[info exists enable_dr_bdr] && ($session_type == "ospfv2")} {
        $serverCommand config -enableDesignatedRouter $truth($enable_dr_bdr)
        $serverCommand set
    }
    
    if {![info exists count]} {
        set count 1
    }

    for {set nodeId 1} {$nodeId <= $count} {incr nodeId} {
        # Get the OSPF handle
        if {$ospf_modify_flag} {
            set node $handle
            # Get the OSPF information from handle
            if {[$serverCommand getRouter $handle] != 0} {
                keylset returnList log "ERROR in $procName: Failure on get the\
                        OSPF router $handle.  On port $chasNum $cardNum\
                        $portNum for node $node."
                keylset returnList status $::FAILURE
                return  $returnList
            }

            if {[$routerCommand getInterface interface1] != 0} {
                keylset returnList log "ERROR in $procName: Failure on get the\
                        OSPF interface.  On port $chasNum $cardNum\
                        $portNum for node $node."
                keylset returnList status $::FAILURE
                return  $returnList
            }
        } else {
            set node [::ixia::getNextOspfRouter $serverCommand $session_type \
                    $port_handle $get_next_session_mode]

            # Get the interface description
            set interface_description [lindex $desc_list [expr $nodeId - 1]]

            # Set the Router ID is new router and router_id not set
            if {![info exists router_id]} {
                if {$ip_version == 4} {
                    set retCode [::ixia::get_interface_parameter \
                            -port_handle $port_handle            \
                            -description $interface_description  \
                            -parameter   ipv4_address            ]

                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]."
                        return $returnList
                    }

                    set router_id [keylget retCode ipv4_address]
                    if {$router_id == ""} {
                        set router_id $chasNum.$cardNum.$portNum.$intf_num
                    }
                } else {
                    set startIndex [expr \
                            [string last - $interface_description] + 1]
                    set intf_num [string trimleft [string range \
                            $interface_description $startIndex end]]
                    set router_id $chasNum.$cardNum.$portNum.$intf_num
                }
            }

            # Configure OSPF interface
            $routerCommand clearAllRouteRanges
            $routerCommand clearAllInterfaces
            $routerCommand setDefault
            $interfaceCommand setDefault
        }


        set connect_dut $::true

        foreach item [array names ospfArray] {
            if {![catch {set $ospfArray($item)} value] } {
                if {[lsearch [array names enumList] $value] != -1} {
                    set value $enumList($value)
                }
                catch {$interfaceCommand config -$item $value}
            }
        }

        # Add interface
        if {$ospf_modify_flag == 0} {
            if {[$routerCommand addInterface interface1] } {
                keylset returnList log "ERROR in $procName: Failure on call to\
                        $routerCommand addInterface interface1.  On port\
                        $chasNum $cardNum $portNum for node $node."
                keylset returnList status $::FAILURE
                return $returnList
            }
        } else  {
            if {[$routerCommand setInterface interface1] } {
                keylset returnList log "ERROR in $procName: Failure on call to\
                        $routerCommand setInterface interface1.  On port\
                        $chasNum $cardNum $portNum for node $node."
                keylset returnList status $::FAILURE
                return $returnList
            }

            if {$session_type == "ospfv3"} {
                # Select Protocol Server on Ixia port
                if {[$serverCommand select $chasNum $cardNum $portNum]} {
                    keylset returnList log "ERROR in $procName: Failure on call to\
                            $serverCommand select $chasNum $cardNum $portNum."
                    keylset returnList status $::FAILURE
                    return  $returnList
                }

                # Get the OSPF information from handle
                if {[$serverCommand getRouter $node] != 0} {
                    keylset returnList log "ERROR in $procName: Failure on get the\
                            OSPF router $handle.  On port $chasNum $cardNum\
                            $portNum for node $node."
                    keylset returnList status $::FAILURE
                    return  $returnList
                }
            }
        }

        # Configure OSPF Stub interface if needed
        if {$stub_flag} {

            # Get the stub IP/MASK
            set netmask 255.255.255.255
            set loop_desc [lindex $loop_list [expr $nodeId - 1]]
            set retCode [::ixia::get_interface_parameter \
                    -port_handle $port_handle \
                    -description $loop_desc   \
                    -parameter   ipv4_address ]

            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]."
                return $returnList
            }
            set ip_address [keylget retCode ipv4_address]
            if {$ip_address == ""} {
                set ip_address 0.0.0.0
            }
            set connect_dut $::false
            set area_type   ospfInterfaceLinkStub
            set stub_flag_two 1

            if {$ospf_modify_flag == 0} {
                $interfaceCommand  setDefault
            } else  {
                if {[$routerCommand getInterface interface2] } {
                    set stub_flag_two 0
                }
            }

            foreach item [array names ospfArray] {
                if {![catch {set $ospfArray($item)} value] } {
                    if {[lsearch [array names enumList] $value] != -1} {
                        set value $enumList($value)
                    }
                    catch {$interfaceCommand config -$item $value}
                }
            }

            # Add interface
            if {($ospf_modify_flag == 0) || \
                        (($ospf_modify_flag == 1) && ($stub_flag_two == 0))} {
                if {[$routerCommand addInterface interface2] } {
                    keylset returnList log "ERROR in $procName: Failure on call\
                            to $routerCommand addInterface interface2.  On\
                            port $chasNum $cardNum $portNum for (STUB) node\
                            $node."
                    keylset returnList status $::FAILURE
                    return $returnList
                }
            } else  {
                if {[$routerCommand setInterface interface2] } {
                    keylset returnList log "ERROR in $procName: Failure on call\
                            to $routerCommand setInterface interface2.  On\
                            port $chasNum $cardNum $portNum for (STUB) node\
                            $node."
                    keylset returnList status $::FAILURE
                    return $returnList
                }
                if {$session_type == "ospfv3"} {
                    # Select Protocol Server on Ixia port
                    if {[$serverCommand select $chasNum $cardNum $portNum]} {
                        keylset returnList log "ERROR in $procName: \
                                Failure on call to $serverCommand select\
                                $chasNum $cardNum $portNum."
                        keylset returnList status $::FAILURE
                        return  $returnList
                    }

                    # Get the OSPF information from handle
                    if {[$serverCommand getRouter $node] != 0} {
                        keylset returnList log "ERROR in $procName: \
                                Failure on get the OSPF router $handle. On port\
                                $chasNum $cardNum $portNum for node $node."
                        keylset returnList status $::FAILURE
                        return  $returnList
                    }
                }
            }
        }

        # Configure OSPF Router
        foreach item [array names ospfRouterArray] {
            if {![catch {set $ospfRouterArray($item)} value] } {
                if {[lsearch [array names enumList] $value] != -1} {
                    set value $enumList($value)
                }
                catch {$routerCommand config -$item $value}
            }
        }

        if {$ospf_modify_flag == 0} {

            if {[$serverCommand addRouter $node] } {
                keylset returnList log "ERROR in $procName: Failure on call to\
                        $serverCommand addRouter $node on port $chasNum\
                        $cardNum $portNum."
                keylset returnList status $::FAILURE

                return $returnList
            }
        } else {
            if {[$serverCommand setRouter  $node]} {
                keylset returnList log "ERROR in $procName: Failure on call to\
                        $serverCommand setRouter $node on port $chasNum\
                        $cardNum $portNum."
                keylset returnList status $::FAILURE
                return $returnList
            }
        }

        lappend node_list $node

        # Increment items if needed
        # Router ID
        if {[info exists router_id_step]} {
            set router_id [::ixia::increment_ipv4_address_hltapi \
                    $router_id $router_id_step]
        }
        # Neighbor Router ID
        if {[info exists neighbor_router_id] && [info exists neighbor_router_id_step]} {
            set neighbor_router_id [::ixia::increment_ipv4_address_hltapi \
                    $neighbor_router_id $neighbor_router_id_step]
        }
        # Area ID
        if {[info exists area_id_step]} {
            incr area_id $area_id_step
        }
        # Instance ID
        if {[info exists instance_id_step]} {
            incr instance_id $instance_id_step
        }
        ::ixia::updateOspfHandleArray $mode $port_handle $node $session_type
    }

    stat config -$statsCommand $::true
    if {[stat set $chasNum $cardNum $portNum ]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failure on call to stat\
                set $chasNum $cardNum $portNum."
        return $returnList
    }

    if {[protocolServer get $chasNum $cardNum $portNum]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failure on call to\
                protocolServer get $chasNum $cardNum $portNum."
        return $returnList
    }
    protocolServer config -$serviceCommand $::true
    if {[protocolServer set $chasNum $cardNum $portNum]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failure on call to\
                protocolServer set $chasNum $cardNum $portNum."
        return $returnList
    }

    if {![info exists no_write]} {
        set retCode [::ixia::writePortListConfig ]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ::ixia::writePortListConfig failed. \
                    [keylget retCode log]"
            return $returnList
        }
    }

    keylset returnList handle $node_list
    return $returnList
}


proc ::ixia::emulation_ospf_topology_route_config { args } {
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
                \{::ixia::emulation_ospf_topology_route_config $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    variable new_ixnetwork_api
    
    variable  ospf_handles_array

    ::ixia::utrackerLog $procName $args

    keylset returnList status $::SUCCESS

    # Arguments
    set man_args {
        -mode                           CHOICES create modify delete enable disable
        -handle
    }

    set opt_args {
        -area_id                        IP
                                        DEFAULT 0.0.0.0
        -bfd_registration               CHOICES 0 1 
                                        DEFAULT 0
        -count                          RANGE 1-2000
        -dead_interval                  RANGE 0-65535
                                        DEFAULT 40
        -elem_handle
        -enable_advertise               CHOICES 0 1
                                        DEFAULT 1
        -enable_advertise_loopback      CHOICES 0 1
                                        DEFAULT 0
        
        -entry_point_address            IP
        -entry_point_prefix_length      RANGE 0-128
        -external_address_family        CHOICES unicast multicast
                                        DEFAULT unicast
        -external_ip_type               CHOICES ipv4 ipv6
                                        DEFAULT ipv6
        -external_number_of_prefix      RANGE 1-16000000
                                        DEFAULT 24
        -external_prefix_length         RANGE 0-128
        -external_prefix_metric         RANGE 0-16777215
                                        DEFAULT 1
        -external_prefix_start          IP
        -external_prefix_step           RANGE 0-2147483647
                                        DEFAULT 1
        -external_prefix_type           CHOICES 1 2
                                        DEFAULT 1
        -grid_col                       RANGE 0-10000
                                        DEFAULT 1
        -grid_connect                   DEFAULT 1 1
        -grid_disconnect
        -grid_link_type                 CHOICES broadcast ptop_numbered ptop_unnumbered
                                        DEFAULT ptop_numbered
        -grid_prefix_length             RANGE 0-128
        -grid_prefix_start              IP
        -grid_prefix_step               IP
        -grid_router_id                 IP
                                        DEFAULT 0.0.0.0
        -grid_router_id_step            IP
                                        DEFAULT 0.0.0.0
        -grid_row                       RANGE 0-10000
                                        DEFAULT 1
        -grid_te                        CHOICES 0 1
                                        DEFAULT 0
        -hello_interval                 RANGE 0-65535
                                        DEFAULT 10
        -interface_ip_address           IP
        -interface_ip_mask              IP
        -interface_ip_options
        -interface_metric               RANGE 0-65535
                                        DEFAULT 10
        -interface_mode                 CHOICES ospf_interface ospf_and_protocol_interface 
                                        DEFAULT ospf_and_protocol_interface
        -interface_mode2                CHOICES ospf_interface ospf_and_protocol_interface 
                                        DEFAULT ospf_and_protocol_interface
        -link_te                        CHOICES 0 1
        -link_te_metric                 RANGE 0-65535
                                        DEFAULT 10
        -link_te_max_bw                 DECIMAL
                                        DEFAULT 0
        -link_te_max_resv_bw            DECIMAL
                                        DEFAULT 0
        -link_te_unresv_bw_priority0    DECIMAL
                                        DEFAULT 0
        -link_te_unresv_bw_priority1    DECIMAL
                                        DEFAULT 0
        -link_te_unresv_bw_priority2    DECIMAL
                                        DEFAULT 0
        -link_te_unresv_bw_priority3    DECIMAL
                                        DEFAULT 0
        -link_te_unresv_bw_priority4    DECIMAL
                                        DEFAULT 0
        -link_te_unresv_bw_priority5    DECIMAL
                                        DEFAULT 0
        -link_te_unresv_bw_priority6    DECIMAL
                                        DEFAULT 0
        -link_te_unresv_bw_priority7    DECIMAL
                                        DEFAULT 0
        -link_type                      CHOICES external-capable ppp stub
        -neighbor_router_id             IPV4
        -neighbor_router_prefix_length  RANGE 0-32
                                        DEFAULT 32
        -net_ip                         IP
        -net_prefix_length              RANGE 1-128
        -net_prefix_options             DEFAULT 0
        -no_write                       FLAG
        -router_abr                     CHOICES 0 1
                                        DEFAULT 0
        -router_asbr                    CHOICES 0 1
                                        DEFAULT 0
        -router_id                      IP
                                        DEFAULT 0.0.0.0
        -router_te                      CHOICES 0 1
                                        DEFAULT 0
        -router_virtual_link_endpt      CHOICES 0 1
                                        DEFAULT 0
        -router_wcr                     CHOICES 0 1
                                        DEFAULT 0
        -summary_address_family         CHOICES unicast multicast
                                        DEFAULT unicast
        -summary_ip_type                CHOICES ipv4 ipv6
                                        DEFAULT ipv6
        -summary_number_of_prefix       RANGE 1-16000000
                                        DEFAULT 24
        -summary_prefix_length          RANGE 0-128
        -summary_prefix_metric          RANGE 0-16777215
        -summary_prefix_start           IP
                                        DEFAULT 1
        -summary_prefix_step            RANGE 0-2147483647
                                        DEFAULT 1
        -summary_route_type             CHOICES another_area same_area 
                                        DEFAULT another_area
        -type                           CHOICES router grid network summary_routes ext_routes
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_ospf_topology_config $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList log "ERROR in $procName:\
                    [keylget returnList log]"
        }
        return $returnList
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log $errorMsg
        return $returnList
    }

    if {$mode == "modify" || $mode == "enable" || $mode == "disable"} {
        removeDefaultOptionVars $opt_args $args
    }
    if {$mode == "enable"} {
        set enable 1
    } elseif {$mode == "disable"} {
        set enable 0
    }
    if {$mode != "delete"} {
        if {![info exists type]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    When -mode is $mode, parameter -type must be specified."
            
            return $returnList
        }
    }
    
    if {([info exists enable_advertise] && $enable_advertise == 1) && \
            (![info exists enable_advertise_loopback] || \
            [is_default_param_value "enable_advertise_loopback" $args])} {
        
        set enable_advertise_loopback 1
    }
    
    if {$mode != "create"} {
        if {![info exists elem_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    When -mode is $mode, parameter -elem_handle must be specified."
            
            return $returnList
        }
    } else {
        set mask_width_list {
            grid_prefix_length      grid_prefix_start       grid_prefix_step
            net_prefix_length       net_ip                  tmp_step
            summary_prefix_length   summary_prefix_start    tmp_step
            external_prefix_length  external_prefix_start   tmp_step
        }
        foreach {mask ip step} $mask_width_list {
            if {[info exists $ip]} {
                if {[isIpAddressValid [set $ip]]} {
                    if {![info exists $mask]} {
                        set $mask 24
                    } else {
                        if {[set $mask] > 32} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: $mask\
                                    should be between 0 and 32."
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
    if {[array names ospf_handles_array $handle,session] == ""} {
        keylset returnList log "ERROR in $procName: cannot find the session handle \
                $handle in the ospf_handles_array"
        keylset returnList status $::FAILURE
        return $returnList
    }
    if {[info exists link_type]} {
        switch -- $link_type {
            external-capable {set link_type $::ospfInterfaceLinkTransit}
            ppp              {set link_type $::ospfInterfaceLinkPointToPoint}
            stub             {set link_type $::ospfInterfaceLinkStub}
        }
    }
    if {[info exists grid_link_type]} {
        switch -- $grid_link_type {
            broadcast       {set grid_link_type $::ospfNetworkRangeLinkBroadcast}
            ptop_numbered   {set grid_link_type $::ospfNetworkRangeLinkPointToPoint}
            ptop_unnumbered {set grid_link_type $::ospfNetworkRangeLinkPointToPoint}
        }
    }
    if {[info exists summary_address_family]} {
        switch -- $summary_address_family {
            unicast   {set summary_address_family "unicastAddress"}
            multicast {set summary_address_family "multicastAddress"}
        }
    }
    if {[info exists summary_ip_type]} {
        switch -- $summary_ip_type {
            ipv4 {set summary_ip_type "addressTypeIpV4"}
            ipv6 {set summary_ip_type "addressTypeIpV6"}
        }
    }
    if {[info exists external_address_family]} {
        switch -- $external_address_family {
            unicast   {set external_address_family "unicastAddress"}
            multicast {set external_address_family "multicastAddress"}
        }
    }
    if {[info exists external_ip_type]} {
        switch -- $external_ip_type {
            ipv4 {set external_ip_type "addressTypeIpV4"}
            ipv6 {set external_ip_type "addressTypeIpV6"}
       }
    }
    if {[info exists area_id]} {
        set area_id [::ixia::ip_addr_to_num $area_id]
    }
    set port_handle  [lindex $ospf_handles_array($handle,session) 0]
    set session_type [lindex $ospf_handles_array($handle,session) 1]
    
    scan $port_handle "%d/%d/%d" chasNum cardNum portNum
    ::ixia::addPortToWrite $chasNum/$cardNum/$portNum

    # Check if OSPF package has been installed on the port
    if {$session_type == "ospfv2"} {
        if {[catch {ospfServer select $chasNum $cardNum $portNum} retCode]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: The OSPFv2 protocol\
                    has not been installed on port or is not supported on port: \
                    $chasNum/$cardNum/$portNum."
            return $returnList
        }
    } elseif {$session_type == "ospfv3"}  {
        if {[catch {ospfV3Server select $chasNum $cardNum $portNum} retCode]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: The OSPFv3 protocol\
                    has not been installed on port or is not supported on port: \
                    $chasNum/$cardNum/$portNum."
            return $returnList
        }
    }

    create_ospf_topology_route_arrays $session_type

    if {$session_type == "ospfv2"} {
        set serverCommand               "ospfServer"
        set routerCommand               "ospfRouter"
        set interfaceCommand            "ospfInterface"
        set ip_version                  4
        switch $mode {
            create {
                set ospfRouterConfigProc "createOspfv2RouteObject \
                        $handle $port_handle $type"
            }
            disable -
            enable -
            modify {
                set ospfRouterConfigProc "modifyOspfv2RouteObject \
                        $handle $elem_handle $type"
            }
            delete {
                set ospfRouterConfigProc "deleteOspfv2RouteObject \
                        $handle $elem_handle"
            }
        }
    } else {
        set serverCommand               "ospfV3Server"
        set routerCommand               "ospfV3Router"
        set interfaceCommand            "ospfV3Interface"
        set ip_version                  6
        switch $mode {
            create {
                set ospfRouterConfigProc "createOspfv3RouteObject \
                        $handle $port_handle $type"
            }
            disable -
            enable -
            modify {
                set ospfRouterConfigProc "modifyOspfv3RouteObject \
                        $handle $elem_handle $type"
            }
            delete {
                set ospfRouterConfigProc "deleteOspfv3RouteObject \
                        $handle $elem_handle"
            }
        }
    }

    if {[$serverCommand select $chasNum $cardNum $portNum]} {
        keylset returnList log "ospfServer select on port\
                $chasNum $cardNum $portNum failed."
        keylset returnList status $::FAILURE
        return $returnList
    }
    if {[$serverCommand getRouter $handle]} {
       keylset returnList log "ERROR in $procName: $serverCommand\
               getRouter $handle command failed. \
               \n$::ixErrorInfo"
       keylset returnList status $::FAILURE
       return $returnList
    }
    
    # Loopback interface is only for OSPFv2, OSPFv3 does not allow multiple interfaces  per neighbor
    if {$mode == "create" && $session_type == "ospfv2"} {
        if {[info exists interface_ip_address] && $interface_ip_address != "0.0.0.0" && $interface_ip_address != "0::0"} {
            # get the ospf connected interface
            set connected_via ""
            
            set rc [$routerCommand getFirstInterface]
            while {$rc == 0} {
                if {[$interfaceCommand cget -connectToDut] && [$interfaceCommand cget -enable]} {
                    set connected_via [$interfaceCommand cget -protocolInterfaceDescription]
                    break
                }
                set rc [$routerCommand getNextInterface]
            }
            
            if {$connected_via == ""} {
                keylset returnList log "ERROR in $procName:\
                        Unable to find ospf Dut connected interface"
                keylset returnList status $::FAILURE
                return $returnList
            }
            
            set intf_status [ixia::protocol_interface_config \
                -type routed \
                -port_handle $port_handle \
                -ip_address $interface_ip_address \
                -ip_version $ip_version \
                -connected_via $connected_via \
                -netmask 32]
                
            # Check status
            if {[keylget intf_status status] != $::SUCCESS} {
                keylset returnList log "ERROR in $procName:\
                        [keylget intf_status log]"
                keylset returnList status $::FAILURE
                return $returnList
            }
            
            set created [keylget intf_status created]
            
        }
    }

    set elem_handle [eval $ospfRouterConfigProc]
    if {$elem_handle == "NULL"} {
       keylset returnList log "ERROR in $procName: failed to\
               $mode $session_type route objects\
               on port $chasNum $cardNum $portNum\n$::ixErrorInfo"
       keylset returnList status $::FAILURE
       return $returnList
    }
    
    ### For router & grid type, update the auto generated userLsa options:
    ### router_asbr, router_abr, router_virtual_link_endpt, router_wcr
    ### and the description for the userLsaGroup
    if {($session_type == "ospfv3") && ($mode != "delete")} {
        if {($type == "router") || ($type == "grid")} {
            if {[configAutoGeneratedUserLsas $elem_handle]} {
               keylset returnList log "ERROR in $procName: failed to update\
                       the auto generated userLsaGroup for router/grid\
                       topology config"
               keylset returnList status $::FAILURE
               return $returnList
            }
            if {[$serverCommand getRouter $handle]} {
               keylset returnList log "ERROR in $procName: $serverCommand\
                       setRouter $handle command failed. \n$::ixErrorInfo"
               keylset returnList status $::FAILURE
               return $returnList
            }
            if {[setRouterLsaHeaderBits $elem_handle $router_asbr $router_abr\
                $router_virtual_link_endpt $router_wcr]} {
               keylset returnList log "ERROR in $procName: failed to set the\
                       Lsa Header Bits \n$::ixErrorInfo"
               keylset returnList status $::FAILURE
               return $returnList
            }
        }
    }

    ### Don't do setRouter again here.  It'll mess up the userLsaGroup config
    #if {[$serverCommand setRouter $handle]} /{
    #   keylset returnList log "ERROR in $procName: $serverCommand\
    #               setRouter $handle command failed. \
    #               \n$::ixErrorInfo"
    #   keylset returnList status $::FAILURE
    #   return $returnList
    #/}
    
    if {![info exists no_write]} {
        if {$mode == "enable" || $mode == "disable"} {
            if {[$serverCommand write]} {
                keylset returnList log "ospfServer write failed."
                keylset returnList status $::FAILURE
                return $returnList
            }
        } else {
            set retCode [::ixia::writePortListConfig ]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        ::ixia::writePortListConfig failed. \
                        [keylget retCode log]"
                return $returnList
            }
        }
    }

    cleanup_ospf_topology_route_arrays $session_type

    ### some configuration is not cleared;  for example, the userLsaGroup
    ### generated by the OSPFV3 NetworkRange.  Need to remove it here.
    if {$session_type == "ospfv3"} {
        $routerCommand clearAllLsaGroups
    }

    ###########     Constructing the return list ###########
    keylset returnList elem_handle $elem_handle
    if {[info exists type]} {
        keylset returnList $type.version $session_type

        if {$type == "grid"} {
            keylset returnList grid.connected_session.$handle.row \
                                $grid_row
            keylset returnList grid.connected_session.$handle.col \
                                $grid_col
        }
    }
    return $returnList
}


proc ::ixia::emulation_ospf_control { args } {
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
                \{::ixia::emulation_ospf_control $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    variable new_ixnetwork_api
    variable ospf_handles_array

    ::ixia::utrackerLog $procName $args

    # Arguments
    set man_args {
        -mode   CHOICES start stop restart
    }

    set opt_args {
        -port_handle REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -handle
    }

    if {[isUNIX] && [info exists ::ixTclSvrHandle]} {
        set retValueClicks [eval "::ixia::SendToIxTclServer $::ixTclSvrHandle {clock clicks}"]
        set retValueSeconds [eval "::ixia::SendToIxTclServer $::ixTclSvrHandle {clock seconds}"]
    } else {
        set retValueClicks [clock clicks]
        set retValueSeconds [clock seconds]
    }
    keylset returnList clicks [format "%u" $retValueClicks]
    keylset returnList seconds [format "%u" $retValueSeconds]

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_ospf_control $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList log "ERROR in $procName:\
                    [keylget returnList log]"
        }
        return $returnList
    }
    
    ::ixia::parse_dashed_args -args $args -mandatory_args $man_args\
            -optional_args $opt_args

    if {![info exists handle] && ![info exists port_handle]} {
        keylset returnList log "ERROR in $procName: -port_handle or -handle option\
                must be specified."
        keylset returnList status $::FAILURE
        return $returnList
    }
    array set port_list   ""
    set port_list(ospfv2) ""
    set port_list(ospfv3) ""
    set session_type_list {ospfv2 ospfv3}
    if {[info exists handle]} {
        foreach handle_elem $handle {
            if {[array names ospf_handles_array $handle_elem,session] == ""} {
                keylset returnList log "ERROR in $procName: Invalid handle\
                        element $handle_elem provided to -handle parameter."
                keylset returnList status $::FAILURE
                return $returnList
            }
            set port_elem         [lindex $ospf_handles_array($handle_elem,session) 0]
            scan $port_elem "%d/%d/%d" chasNum cardNum portNum
            set session_type_elem [lindex $ospf_handles_array($handle_elem,session) 1]
            
            lappend port_list($session_type_elem)  [list $chasNum $cardNum $portNum]
        }
    }
    
    if {[info exists port_handle]} {
        foreach port_elem $port_handle {
            scan $port_elem "%d/%d/%d" chasNum cardNum portNum
            if {[protocolServer get $chasNum $cardNum $portNum]} {
                keylset returnList log "$procName: Could not read data from \
                        port $chasNum $cardNum $portNum."
                keylset returnList status $::FAILURE
                return $returnList
            }
            set session_type_elem ""
            if {[protocolServer cget -enableOspfService] == 1} {
                lappend session_type_elem "ospfv2"
                lappend port_list(ospfv2) [list $chasNum $cardNum $portNum]
            } 
            if {[protocolServer cget -enableOspfV3Service] == 1} {
                lappend session_type_elem "ospfv3"
                lappend port_list(ospfv3) [list $chasNum $cardNum $portNum]
            } 
            if {$session_type_elem == ""}  {
                keylset returnList log "ERROR in $procName: Could not read version \
                        type of OSPF protocol on port $chasNum $cardNum \
                        $portNum. OSPFv2/v3 protocol is not enabled."
                keylset returnList status $::FAILURE
                return $returnList
            }
            protocolServer config -enableOspfCreateInterface false
            protocolServer set $chasNum $cardNum $portNum
        }
    }

    # Check if OSPF package has been installed on the port
    foreach session_type_i [array names port_list] {
        if {$port_list($session_type_i) == ""} {continue}
        if {$session_type_i == "ospfv2"} {
            set ospfServerCommand ospfServer
            set ospfStartCommand  ixStartOspf
            set ospfStopCommand   ixStopOspf
        } else {
            set ospfServerCommand ospfV3Server
            set ospfStartCommand  ixStartOspfV3
            set ospfStopCommand   ixStopOspfV3
        }
        foreach port_i $port_list($session_type_i) {
            foreach {chs_i crd_i prt_i} $port_i {}
        
            if {[catch {$ospfServerCommand select $chs_i $crd_i $prt_i} retCode]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The $session_type_i\
                        protocol has not been installed on port or\
                        is not supported on port: $chs_i/$crd_i/$prt_i."
                return $returnList
            }
        }
        set retCode [::ixia::writePortListConfig ]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ::ixia::writePortListConfig failed. \
                    [keylget retCode log]"
            return $returnList
        }
        
        # Start the protocol
        if {$mode == "start"} {
            if {[$ospfStartCommand port_list($session_type_i)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Could not\
                        start OSPF on port(s): $port_list($session_type_i)"
                return $returnList
            }
        } elseif {$mode == "stop"} {
            # Stop the protocol
            if {[$ospfStopCommand port_list($session_type_i)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Could not\
                        stop OSPF on port(s): $port_list($session_type_i)"
                return $returnList
            }
        } elseif {$mode == "restart"} {
            # Restart the protocol
            if {[$ospfStopCommand port_list($session_type_i)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Could not\
                        restart OSPF on port(s): $port_list($session_type_i)"
                return $returnList
            }
            if {[$ospfStartCommand port_list($session_type_i)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Could not\
                        restart OSPF on port(s): $port_list($session_type_i)"
                return $returnList
            }
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::emulation_ospf_lsa_config { args } {
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
                \{::ixia::emulation_ospf_lsa_config $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    variable new_ixnetwork_api
    variable  ospf_handles_array

    ::ixia::utrackerLog $procName $args

    keylset returnList status $::SUCCESS

    ## Hardcode the userLsaGroup.  Cisco's spec does not allow multiple
    ## userLsaGroups
    set userLsaGroupId  userLsaGroup1
    set routeRangeId    userRouteRange1

    # Arguments
    set man_args {
        -mode    CHOICES create modify delete reset
                 DEFAULT create
        -handle
    }

    set opt_args {
        -lsa_handle
        -adv_router_id                            IP 
                                                  DEFAULT 198.18.1.1
        -area_id                                  IP
                                                  DEFAULT 0.0.0.0
        -attached_router_id                       IP
                                                  DEFAULT 14.0.0.1
        -external_number_of_prefix                DEFAULT 16
        -external_prefix_start                    IP
                                                  DEFAULT 2000::1::1
        -external_prefix_length                   DEFAULT 16
        -external_prefix_step                     IP
                                                  DEFAULT 0.0.0.1
        -external_prefix_metric                   RANGE 0-16777215
                                                  DEFAULT 1
        -external_prefix_type                     CHOICES 1 2
                                                  DEFAULT 1
        -external_prefix_forward_addr             IP
                                                  DEFAULT 2001::1::1
        -external_route_tag                       IP
                                                  DEFAULT 17.0.0.1
        -external_metric_fbit                     CHOICES 1 0
                                                  DEFAULT 1
        -external_metric_tbit                     CHOICES 1 0
                                                  DEFAULT 1
        -external_metric_ebit                     CHOICES 1 0
                                                  DEFAULT 0
        -link_state_id                            IP 
                                                  DEFAULT 199.18.1.1
        -link_state_id_step                       IPV4
        -ls_type_function_code                    RANGE 0-8191
                                                  DEFAULT 0
        -lsa_group_mode                           CHOICES append create
                                                  DEFAULT append
        -net_prefix_length                        DEFAULT 16
        -net_attached_router                      CHOICES create delete reset
                                                  DEFAULT create
        -no_write                                 FLAG
        -opaque_enable_link_id                    CHOICES 0 1
                                                  DEFAULT 0
        -opaque_enable_link_local_ip_addr         CHOICES 0 1
                                                  DEFAULT 0
        -opaque_enable_link_max_bw                CHOICES 0 1
                                                  DEFAULT 0
        -opaque_enable_link_max_resv_bw           CHOICES 0 1
                                                  DEFAULT 0
        -opaque_enable_link_metric                CHOICES 0 1
                                                  DEFAULT 0
        -opaque_enable_link_remote_ip_addr        CHOICES 0 1
                                                  DEFAULT 0
        -opaque_enable_link_resource_class        CHOICES 0 1
                                                  DEFAULT 0
        -opaque_enable_link_type                  CHOICES 0 1
                                                  DEFAULT 0
        -opaque_enable_link_unresv_bw             CHOICES 0 1
                                                  DEFAULT 0
        -opaque_link_id                           IP 
                                                  DEFAULT 0.0.0.0
        -opaque_link_local_ip_addr                IP 
                                                  DEFAULT 0.0.0.0
        -opaque_link_max_bw                       DECIMAL 
                                                  DEFAULT 0
        -opaque_link_max_resv_bw                  DECIMAL 
                                                  DEFAULT 0
        -opaque_link_metric                       NUMERIC 
                                                  DEFAULT 0
        -opaque_link_remote_ip_addr               IP
                                                  DEFAULT 0.0.0.0
        -opaque_link_resource_class               HEX 
                                                  DEFAULT 0x00000000
        -opaque_link_type                         CHOICES ptop multiaccess
                                                  DEFAULT ptop
        -opaque_link_subtlvs                      IP
        -opaque_link_other_subtlvs                REGEXP ^(0x[0-9a-fA-F]+:[0-9]+:[0-9]+ )*0x[0-9a-fA-F]+:[0-9]+:[0-9]+$
        -opaque_link_unresv_bw_priority           DECIMAL 
                                                  DEFAULT 0
        -opaque_router_addr                       IP 
                                                  DEFAULT 0.0.0.0
        -opaque_tlv_type                          CHOICES link router 
                                                  DEFAULT router
        -options                                  RANGE 0-255
        -prefix_options                           RANGE 0-255
        -router_abr                               CHOICES 0 1
                                                  DEFAULT 0
        -router_asbr                              CHOICES 0 1
                                                  DEFAULT 0
        -router_virtual_link_endpt                CHOICES 0 1
                                                  DEFAULT 0
        -router_wildcard                          CHOICES 0 1
                                                  DEFAULT 0
        -router_link_mode                         CHOICES create modify delete
                                                  DEFAULT create
        -router_link_id                           IP
                                                  DEFAULT 12.0.0.1
        -router_link_data                         IP
                                                  DEFAULT 13.0.0.1
        -router_link_type                         CHOICES ptop transit stub virtual
                                                  DEFAULT ptop
        -router_link_metric                       RANGE 1-65535
                                                  DEFAULT 1
        -session_type                             CHOICES ospfv2 ospfv3
                                                  DEFAULT ospfv2
        -summary_number_of_prefix                 DEFAULT 16
        -summary_prefix_start                     IP
                                                  DEFAULT 15.0.0.1
        -summary_prefix_length                    DEFAULT 16
        -summary_prefix_step                      IP
                                                  DEFAULT 0.0.0.1
        -summary_prefix_metric                    RANGE 0-16777215
                                                  DEFAULT 1
        -type                                     CHOICES router network summary_pool
                                                  CHOICES asbr_summary ext_pool
                                                  CHOICES opaque_type_9 opaque_type_10 opaque_type_11
                                                  DEFAULT router
    }
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_ospf_lsa_config $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList log "ERROR in $procName:\
                    [keylget returnList log]"
        }
        return $returnList
    }
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args

    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
    }

    array set lsaTypeArrayNames [list ospfv2 ospfv2LsaTypeEnumArray \
            ospfv3 ospfv3LsaTypeEnumArray]

    ### These are the options that need special treatment before applying
    ### to IxTclHal commands
    set refVarList [list router_link_mode net_prefix_length  \
            net_attached_router attached_router_id           \
            summary_prefix_length external_prefix_length     \
            external_prefix_type external_prefix_step]

    if {[array names ospf_handles_array $handle,session] == ""} {
        keylset returnList log "ERROR in $procName: cannot find the session handle\
                $handle in the ospf_handles_array"
        keylset returnList status $::FAILURE
        return $returnList
    }

    set port_handle [lindex $ospf_handles_array($handle,session) 0]
    set session_type [lindex $ospf_handles_array($handle,session) 1]
    scan $port_handle "%d/%d/%d" chasNum cardNum portNum
    ::ixia::addPortToWrite $chasNum/$cardNum/$portNum

    # Check if OSPF package has been installed on the port
    if {$session_type == "ospfv2"} {
        if {[catch {ospfServer select $chasNum $cardNum $portNum} retCode]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: The OSPFv2\
                    protocol has not been installed on port\
                    or is not supported on port: \
                    $chasNum/$cardNum/$portNum."
            return $returnList
        }
    } elseif {$session_type == "ospfv3"}  {
        if {[catch {ospfV3Server select $chasNum $cardNum $portNum} retCode]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: The OSPFv3\
                    protocol has not been installed on port or\
                    is not supported on port: \
                    $chasNum/$cardNum/$portNum."
            return $returnList
        }
    }

    # Configure the Protocol Server commands for OSPFv2 or OSPFv3
    # Set the default options bit
    if {$session_type == "ospfv2"} {
        set serverCommand             "ospfServer"
        set routerCommand             "ospfRouter"
        set userLsaGroupCommand       "ospfUserLsaGroup"
        set userLsaCommand            "ospfUserLsa"
        set routerLsaInterfaceCommand "ospfRouterLsaInterface"
        set routeRangeCommand         "ospfRouteRange"

        set ospfv2ArrayList [list ospfV2UserLsaArray  \
                ospfV2RouterLsaInterfaceArray         \
                ospfV2LsaExternalArray                \
                ospfV2LsaSummaryArray                 ]

        array set ospfv2LsaTypeEnumArray [list            \
                router                $::ospfLsaRouter    \
                network               $::ospfLsaNetwork   \
                summary_pool          $::ospfLsaSummaryIp \
                asbr_summary          $::ospfLsaSummaryAs \
                ext_pool              $::ospfLsaExternal  \
                ]

        array set ospfV2UserLsaArray [list                \
                advertisingRouterId adv_router_id         \
                linkStateId            link_state_id      \
                options                options            \
                ]

        array set ospfV2RouterLsaInterfaceArray [list        \
                linkId                  router_link_id       \
                linkData                router_link_data     \
                linkType                router_link_type     \
                metric                  router_link_metric   \
                ]

        array set ospfV2LsaExternalArray [list                      \
                numberOfLSAs            external_number_of_prefix   \
                linkStateId             external_prefix_start       \
                incrementLinkStateIdBy  external_prefix_step        \
                metric                  external_prefix_metric      \
                forwardingAddress       external_prefix_forward_addr\
                externalRouteTag        external_route_tag          \
                eBit                    external_metric_ebit        \
                ]

        array set ospfV2LsaSummaryArray [list                       \
                numberOfLSAs            summary_number_of_prefix    \
                incrementLinkStateIdBy  summary_prefix_step         \
                metric                  summary_prefix_metric       \
                ]

        array set lsaTypeList [list                         \
                $::ospfLsaRouter        router              \
                $::ospfLsaNetwork       network             \
                $::ospfLsaSummaryIp     summary_pool        \
                $::ospfLsaSummaryAs     asbr_summary        \
                $::ospfLsaExternal      ext_pool            \
                ]

        array set lsaRouterIfcTypeArray [list               \
                $::ospfLinkPointToPoint     ptop            \
                $::ospfLinkTransit          transit         \
                $::ospfLinkStub             stub            \
                $::ospfLinkVirtual          virtual         \
                ]

    } elseif {$session_type == "ospfv3"} {
        set serverCommand             "ospfV3Server"
        set routerCommand             "ospfV3Router"
        set userLsaGroupCommand       "ospfV3UserLsaGroup"
        set routerLsaInterfaceCommand "ospfV3LsaRouterInterface"
        set routeRangeCommand         "ospfV3RouteRange"

        set ospfv3ArrayList [list               \
                ospfV3LsaRouterArray            \
                ospfV3LsaRouterInterfaceArray   \
                ospfV3LsaAsExternalArray        \
                ospfV3LsaNetworkArray           \
                ospfV3LsaInterAreaPrefixArray   \
                ospfV3LsaInterAreaRouterArray   \
                ]

        array set userLsaCommandArray [list                 \
                router             ospfV3LsaRouter          \
                network            ospfV3LsaNetwork         \
                summary_pool       ospfV3LsaInterAreaPrefix \
                asbr_summary       ospfV3LsaInterAreaRouter \
                ext_pool           ospfV3LsaAsExternal      ]

        array set ospfv3LsaTypeEnumArray [list                    \
                router                $::ospfV3LsaRouter          \
                network               $::ospfV3LsaNetwork         \
                summary_pool          $::ospfV3LsaInterAreaPrefix \
                asbr_summary          $::ospfV3LsaInterAreaRouter \
                ext_pool              $::ospfV3LsaAsExternal      ]

        array set ospfV3LsaAsExternalArray [list                    \
                advertisingRouterId     adv_router_id               \
                linkStateId             link_state_id               \
                numLsaToGenerate        external_number_of_prefix   \
                prefixAddress           external_prefix_start       \
                prefixLength            external_prefix_length      \
                prefixOptions           prefix_options              \
                metric                  external_prefix_metric      \
                forwardingAddress       external_prefix_forward_addr\
                externalRouteTag        external_route_tag          \
                enableFBit              external_metric_fbit        \
                enableTBit              external_metric_tbit        \
                ]

        array set ospfV3LsaNetworkArray [list             \
                advertisingRouterId     adv_router_id     \
                linkStateId             link_state_id     \
                options                 options           \
                ]

        array set ospfV3LsaRouterArray [list                      \
                advertisingRouterId     adv_router_id             \
                linkStateId             link_state_id             \
                options                 options                   \
                enableWBit              router_wildcard           \
                enableBBit              router_asbr               \
                enableEBit              router_abr                \
                enableVBit              router_virtual_link_endpt \
                ]

        array set ospfV3LsaRouterInterfaceArray [list       \
                metric                  router_link_metric  \
                neighborRouterId        router_link_data    \
                type                    router_link_type    \
                ]

        array set ospfV3LsaInterAreaPrefixArray [list               \
                advertisingRouterId         adv_router_id           \
                linkStateId                 link_state_id           \
                incrementLinkStateIdBy      link_state_id_step      \
                numLsaToGenerate            summary_number_of_prefix\
                prefixOptions               prefix_options          \
                prefixAddress               summary_prefix_start    \
                prefixLength                summary_prefix_length   \
                ]

        array set ospfV3LsaInterAreaRouterArray [list               \
                advertisingRouterId         adv_router_id           \
                linkStateId                 link_state_id           \
                incrementLinkStateIdBy      link_state_id_step      \
                numLsaToGenerate            summary_number_of_prefix\
                options                     options                 \
                incrementDestRouterIdBy     summary_prefix_step     \
                destinationRouterId         summary_prefix_start    \
                metric                      summary_prefix_metric   \
                ]

        array set lsaTypeList [list                                 \
                $::ospfV3LsaRouter          router                  \
                $::ospfV3LsaNetwork         network                 \
                $::ospfV3LsaInterAreaPrefix summary_pool            \
                $::ospfV3LsaInterAreaRouter asbr_summary            \
                $::ospfV3LsaAsExternal      ext_pool                \
                ]

        array set lsaRouterIfcTypeArray  [list                      \
                $::ospfV3LsaRouterInterfacePointToPoint     ptop    \
                $::ospfV3LsaRouterInterfaceTransit          transit \
                $::ospfV3LsaRouterInterfaceVirtual          virtual \
                ]

        if {$mode == "create"} {
            set userLsaCommand $userLsaCommandArray($type)
        }
    }

    if {[$serverCommand select $chasNum $cardNum $portNum]} {
        keylset returnList log "$serverCommand select\
                $chasNum $cardNum $portNum failed."
        keylset returnList status $::FAILURE
        return $returnList
    }

    # Check if the call is for modify or delete
    if {$mode == "modify" || $mode == "delete"} {
        if {![info exists lsa_handle]} {
            keylset returnList log "ERROR in $procName: When -mode is\
                  $mode, the -lsa_handle option must be used.  Please set\
                  this value."
            keylset returnList status $::FAILURE
            return $returnList
        } elseif {[llength $lsa_handle] > 1} {
            keylset returnList log "ERROR in $procName: When -mode is\
                    $mode, -lsa_handle may only contain one value. \
                    Current: $handle"
            keylset returnList status $::FAILURE
            return $returnList
        }
    } elseif {$mode == "reset"} {
        if {![info exist lsa_handle]} {
            set lsa_handle NULL
        }
    }

    if {$mode == "reset" || $mode == "delete"} {
        set actionOspf_status [::ixia::actionUserLsaGroup        \
                $chasNum $cardNum $portNum         $session_type \
                $mode    $handle  $userLsaGroupId  $lsa_handle   ]

        if {[keylget actionOspf_status status] != $::SUCCESS} {
            keylset returnList log "ERROR in $procName: Failed to\
                    $mode the OSPF LSA Config with -handle $handle on port\
                    $chasNum $cardNum $portNum.  Error returned was\
                    [keylget actionOspf_status log]"
            keylset returnList status $::FAILURE
            return $returnList
        }
        if {![info exists no_write]} {
            set retCode [::ixia::writePortListConfig ]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        ::ixia::writePortListConfig failed. \
                        [keylget retCode log]"
                return $returnList
            }
        }
        # Process completed, return with SUCCESS
        keylset returnList status $::SUCCESS
        return $returnList
    }

    set addUserLsaGroup $::false
    if {$mode == "create"} {
        if {[$serverCommand getRouter $handle]} {
            keylset returnList log "ERROR in $procName: $serverCommand\
                    getRouter $handle command failed. \
                    \n$::ixErrorInfo"
            keylset returnList status $::FAILURE
            return $returnList
        }

        ### addLsaGroupId to the ospfRouter if there isn't one already
        if {[$routerCommand getUserLsaGroup $userLsaGroupId]} {
            $userLsaGroupCommand setDefault
            $userLsaGroupCommand clearAllUserLsas
            $userLsaGroupCommand config -description "$userLsaGroupId"
            $userLsaGroupCommand config -enable true
            set addUserLsaGroup $::true

        }
        $userLsaCommand setDefault
        $userLsaCommand config -enable $::true
        $routerLsaInterfaceCommand setDefault
        set lsa_handle [::ixia::getNextUserLsa $session_type $port_handle]

    } else {

        if {[$serverCommand getRouter $handle]} {
              keylset returnList log "ERROR in $procName: $serverCommand \
                      getRouter $handle command failed. \n$::ixErrorInfo"
              keylset returnList status $::FAILURE
              return $returnList
        }

        if {[$routerCommand getUserLsaGroup $userLsaGroupId]} {
              keylset returnList log "ERROR in $procName: $routerCommand \
                      getUserLsaGroup $userLsaGroupId command failed. \
                      \n$::ixErrorInfo"
              keylset returnList status $::FAILURE
              return $returnList
        }

        if {$session_type == "ospfv2"} {
            if {[$userLsaGroupCommand getUserLsa $lsa_handle] } {
                keylset returnList log "ERROR in $procName:$userLsaGroupCommand\
                        getUserLsa $lsa_handle command failed. \
                        \n$::ixErrorInfo"
                keylset returnList status $::FAILURE
                return $returnList
            }
            set type $lsaTypeList([$userLsaCommand cget -lsaType])
        } else {
            set userLsaObj [$userLsaGroupCommand getUserLsa $lsa_handle]
            if {$userLsaObj == "NULL"} {
                keylset returnList log "ERROR in $procName:$userLsaGroupCommand\
                        getUserLsa $lsa_handle command failed. \
                        \n$::ixErrorInfo"
                keylset returnList status $::FAILURE
                return $returnList
            } else {
               # BUG692421: the $userLsaObj doesn't exist due to legacy issues
               set retCode [::ixia::getLsaOspfProcedure $userLsaObj]
               if {[keylget retCode status] != $::SUCCESS} {
                   keylset returnList log "ERROR in $procName:cannot find a valid ospfV3 function for the \n
                           $userLsaObj object"
                   keylset returnList status $::FAILURE
                   return $returnList
               }
               set ospfProcedure [keylget retCode ospfProcedure]
               
               set type $lsaTypeList([$ospfProcedure cget -type])
               set userLsaCommand $userLsaCommandArray($type)
            }
        }
    }

    if {$session_type == "ospfv2"} {
        set returnList [configureOspfv2UserLsaParams $ospfv2ArrayList \
                $refVarList $type]
    } else {
        set returnList [configureOspfv3UserLsaParams $ospfv3ArrayList \
                $refVarList $type]
    }
    if {[keylget returnList status] == $::FAILURE} {
        return $returnList
    }
    if {$mode == "modify"} {
        if {[$userLsaGroupCommand setUserLsa $lsa_handle]} {
            keylset returnList log "ERROR in $procName: ospfUserLsaGroup\
                    setUserLsa $lsa_handle command failed. \
                    \n$::ixErrorInfo"

            keylset returnList status $::FAILURE
            return $returnList
        }
    } else {
        set lsaTypeEnumArray $lsaTypeArrayNames($session_type)
        set lsaType [lindex  [array get $lsaTypeEnumArray $type] 1]
        if {[$userLsaGroupCommand addUserLsa $lsa_handle $lsaType]} {
            keylset returnList log "ERROR in $procName: ospfUserLsaGroup\
                    addUserLsa $lsa_handle $::ospfLsaRouter command failed. \
                    \n$::ixErrorInfo"

            keylset returnList status $::FAILURE
            return $returnList
        }
        set ospf_handles_array($handle,userLsa,$lsa_handle) \
                [list $lsa_handle $lsaType]
    }
    if {$addUserLsaGroup} {
        if {[$routerCommand addUserLsaGroup $userLsaGroupId]} {
            keylset returnList log "ERROR in $procName: $routerCommand\
                    addUserLsaGroup $userLsaGroupId command failed. \
                    \n$::ixErrorInfo"

            keylset returnList status $::FAILURE
            return $returnList
        }

        if {[$serverCommand setRouter $handle]} {
            keylset returnList log "ERROR in $procName: \
                    $serverCommand setRouter $handle command failed. \
                    \n$::ixErrorInfo"

            keylset returnList status $::FAILURE
            return $returnList
        }

    } else {
        ### create LSA on existing userLsaGroup
        if {$mode == "create"} {
            if {[$routerCommand setUserLsaGroup $userLsaGroupId]} {
                keylset returnList log "ERROR in $procName: $routerCommand \
                        setUserLsaGroup $userLsaGroupId command failed."
                        keylset returnList status $::FAILURE

                keylset returnList status $::FAILURE
                return $returnList
            }

            #### serverCommand setRouter must be called in OSPF
            if {[$serverCommand setRouter $handle]} {
                keylset returnList log "ERROR in $procName: $serverCommand \
                        setRouter $handle command failed."

                keylset returnList status $::FAILURE
                return $returnList
            }
        }
    }

    ###########     Constructing the return list ###########
    # Must call the getRouter & getUserLsaGroup to be able to get
    # newly added userLsa object

    if {[$serverCommand select $chasNum $cardNum $portNum]} {
        keylset returnList log "ospfServer select on port $chasNum $cardNum\
                $portNum failed."

        keylset returnList status $::FAILURE
        return $returnList
    }

    ### create the variables that need to be returned if not passed in
    if {![info exists adv_router_id]} {
        set adv_router_id [$userLsaCommand cget -advertisingRouterId]
    }

    keylset returnList lsa_handle $lsa_handle
    keylset returnList adv_router_id $adv_router_id

    if {[$serverCommand getRouter $handle]} {
        keylset returnList log "ERROR in $procName: Failed with\
                command: ospfServer getRouter $handle. \
                \n$::ixErrorInfo"
        keylset returnList status $::FAILURE
        return $returnList
    }

    if {[$routerCommand getUserLsaGroup $userLsaGroupId]} {
        keylset returnList log "ERROR in $procName: Failed with\
                command: getUserLsaGroup $userLsaGroupId. \
                \n$::ixErrorInfo"
        keylset returnList status $::FAILURE
        return $returnList

    }

    if {$session_type == "ospfv2"} {
        if {[$userLsaGroupCommand getUserLsa $lsa_handle]} {
            keylset returnList log "ERROR in $procName: Failed with\
                    command: $userLsaGroupCommand getUserLsa $lsa_handle. \
                    \n$::ixErrorInfo"
            keylset returnList status $::FAILURE
            return $returnList
        }
        switch $type {
            router {
                set ifc 0
                if {![$userLsaCommand getFirstRouterLsaInterface]} {
                    keylset returnList router.links.$ifc.id   \
                            [ospfRouterLsaInterface cget -linkId]
                    keylset returnList router.links.$ifc.data \
                            [ospfRouterLsaInterface cget -linkData]
                    set typeIndex [ospfV3LsaRouterInterface cget -type]
                    set typeString $lsaRouterIfcTypeArray($typeIndex)
                    keylset returnList router.links.$ifc.type $typeString
                    incr ifc
                    while {![$userLsaCommand getNextRouterLsaInterface]} {
                        keylset returnList router.links.$ifc.id   \
                                [ospfRouterLsaInterface cget -linkId]
                        keylset returnList router.links.$ifc.data \
                                [ospfRouterLsaInterface cget -linkData]
                        set typeIndex [ospfV3LsaRouterInterface cget -type]
                        set typeString $lsaRouterIfcTypeArray($typeIndex)
                        keylset returnList router.links.$ifc.type $typeString
                        incr ifc
                    }
                }
            }
            network {
                keylset returnList network.attached_router_ids \
                        [$userLsaCommand cget -neighborId]
            }
            summary_pool -
            asbr_summary {
                keylset returnList summary.num_prefix  \
                        [$userLsaCommand cget -numberOfLSAs]
                keylset returnList summary.prefix_start\
                        [$userLsaCommand cget -linkStateId]
                keylset returnList summary.prefix_length $summary_prefix_length

                keylset returnList summary.prefix_step \
                        [$userLsaCommand cget -incrementLinkStateIdBy]
            }
            ext_pool {

                keylset returnList external.num_prefix    \
                        [$userLsaCommand cget -numberOfLSAs]
                keylset returnList external.prefix_start  \
                        [$userLsaCommand cget -linkStateId]
                keylset returnList external.prefix_length \
                        $external_prefix_length
                keylset returnList external.prefix_step   \
                        [$userLsaCommand cget -incrementLinkStateIdBy]
            }
        }
    } else {
        #### OSPFV3 returnList
        switch $type {
            router {
                set ifc 0
                if {[ospfV3LsaRouter getFirstInterface] == $::TCL_OK} {
                    keylset returnList router.links.$ifc.id   \
                            [ospfV3LsaRouterInterface cget -neighborInterfaceId]
                    keylset returnList router.links.$ifc.data \
                            [ospfV3LsaRouterInterface cget -neighborRouterId]
                    set typeIndex [ospfV3LsaRouterInterface cget -type]
                    set typeString $lsaRouterIfcTypeArray($typeIndex)
                    keylset returnList router.links.$ifc.type $typeString
                    incr ifc
                    while {![ospfV3LsaRouter getNextInterface]} {
                        keylset returnList router.links.$ifc.id   \
                                [ospfV3LsaRouterInterface cget    \
                                -neighborInterfaceId              ]
                        keylset returnList router.links.$ifc.data \
                                [ospfV3LsaRouterInterface cget    \
                                -neighborRouterId                 ]
                        set typeIndex [ospfV3LsaRouterInterface cget -type]
                        set typeString $lsaRouterIfcTypeArray($typeIndex)
                        keylset returnList router.links.$ifc.type $typeString
                        incr ifc
                    }
                }
            }
            network {
                keylset returnList network.attached_router_ids \
                        [ospfV3LsaNetwork cget -neighborRouterIdList]
            }
            summary_pool {
                keylset returnList summary.num_prefix    \
                        [ospfV3LsaInterAreaPrefix cget -numLsaToGenerate]
                keylset returnList summary.prefix_start  \
                        [ospfV3LsaInterAreaPrefix cget -prefixAddress]
                keylset returnList summary.prefix_length \
                        [ospfV3LsaInterAreaPrefix cget -prefixLength]
                keylset returnList summary.prefix_step   \
                        [ospfV3LsaInterAreaPrefix cget -incrementPrefixBy]
            }
            asbr_summary {
                keylset returnList summary.num_prefix    \
                        [ospfV3LsaInterAreaRouter cget -numLsaToGenerate]
                keylset returnList summary.prefix_start  \
                        [ospfV3LsaInterAreaRouter cget -destinationRouterId]
                # don't have this field to return
                #keylset returnList summary.prefix_length $summary_prefix_length

                keylset returnList summary.prefix_step   \
                        [ospfV3LsaInterAreaRouter cget -incrementDestRouterIdBy]
            }
            ext_pool {
                keylset returnList external.num_prefix   \
                        [ospfV3LsaAsExternal cget -numLsaToGenerate]
                keylset returnList external.prefix_start \
                        [ospfV3LsaAsExternal cget -prefixAddress]
                keylset returnList external.prefix_length\
                        [ospfV3LsaAsExternal cget -prefixLength]
                keylset returnList external.prefix_step  \
                        [ospfV3LsaAsExternal cget -incrementPrefixBy]
            }
        }
    }

    if {![info exists no_write]} {
        set retCode [::ixia::writePortListConfig ]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ::ixia::writePortListConfig failed. \
                    [keylget retCode log]"
            return $returnList
        }
    }

    return $returnList
}


proc ::ixia::emulation_ospf_info { args } {
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
                \{::ixia::emulation_ospf_info $args\}]
        
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
        -mode          CHOICES aggregate_stats learned_info clear_stats
    }
    set opt_args {
        -port_handle   REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -handle
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_ospf_info $args $man_args $opt_args]
        
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "Retrieving OSPF statistics is not supported with IxTclProtocol."
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    return $returnList
}
