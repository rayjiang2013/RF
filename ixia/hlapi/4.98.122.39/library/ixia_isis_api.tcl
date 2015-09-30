##Library Header
# $Id: $
# Copyright © 2003-2009 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_isis_api.tcl
#
# Purpose:
#     A script development library containing ISIS APIs for test automation
#     with the Ixia chassis.
#
# Author:
#    Brad Leabo
#    Karim Lacasse
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures contained within this library include:
#
#    - emulation_isis_config
#    - emulation_isis_topology_route_config
#    - emulation_isis_control
#    - emulation_isis_info
#
# Requirements:
#     ixiaapiutils.tcl , a library containing TCL utilities
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


proc ::ixia::emulation_isis_config { args } {
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
                \{::ixia::emulation_isis_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    variable new_ixnetwork_api
    variable isis_handles_array

    ::ixia::utrackerLog $procName $args

    ### an arbitrary default IPV4 address used for te_router_id
    set default_te_router_id    123.0.0.1
    set IPV4        4
    set IPV6        6

    set man_args {
        -mode           CHOICES create modify delete disable enable
        -port_handle    REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
    }

    ### Renamed optional_args to opt_args.  The ::ixia::parse_dashed_args proc
    ### overwrites the optional_args var.
    set opt_args {
        -area_authentication_mode           CHOICES null text md5
        -area_id                            DEFAULT "49 00 01"
        -area_id_step                       DEFAULT "00 00 00"
        -area_password
        -atm_encapsulation                  CHOICES VccMuxIPV4Routed
                                            CHOICES VccMuxIPV6Routed
                                            CHOICES VccMuxBridgedEthernetFCS
                                            CHOICES VccMuxBridgedEthernetNoFCS
                                            CHOICES LLCRoutedCLIP
                                            CHOICES LLCBridgedEthernetFCS
                                            CHOICES LLCBridgedEthernetNoFCS
        -attach_bit                         CHOICES 0 1
        -bfd_registration                   CHOICES 0 1
                                            DEFAULT 0
        -count                              DEFAULT 1
        -dce_capability_router_id           IPV4
                                            DEFAULT 0.0.0.0
        -dce_bcast_root_priority            RANGE 0-65535 DEFAULT 65535
        -dce_num_mcast_dst_trees            RANGE 0-65535 DEFAULT 1
        -dce_device_id                      RANGE 0-65535 DEFAULT 1
        -dce_device_pri                     RANGE 0-255   DEFAULT 1
        -dce_ftag_enable                    CHOICES 0 1   DEFAULT 0
        -dce_ftag                           RANGE 0-65535 DEFAULT 1
        -discard_lsp                        CHOICES 0 1
        -domain_authentication_mode         CHOICES null text md5
        -domain_password
        -gateway_ip_addr                    IP
                                            DEFAULT 0.0.0.0
        -gateway_ip_addr_step               IP
                                            DEFAULT 0.0.1.0
        -gateway_ipv6_addr                  IPV6
                                            DEFAULT 0::0
        -gateway_ipv6_addr_step             IPV6
                                            DEFAULT 0:0:0:1::0
        -graceful_restart                   CHOICES 0 1
        -graceful_restart_mode              CHOICES normal restarting starting
                                            CHOICES helper
        -graceful_restart_restart_time
        -graceful_restart_version           CHOICES draft3 draft4
        -handle
        -hello_interval                     RANGE   1-65535
        -hello_password                     CHOICES 0 1
        -interface_handle
        -intf_ip_addr                       IP
                                            DEFAULT 178.0.0.1
        -intf_ip_prefix_length              RANGE   1-32
                                            DEFAULT 24
        -intf_ip_addr_step                  IP
                                            DEFAULT 0.0.1.0
        -intf_ipv6_addr                     IPV6
                                            DEFAULT 4000::1
        -intf_ipv6_prefix_length            RANGE   1-128
                                            DEFAULT 64
        -intf_ipv6_addr_step                IPV6
                                            DEFAULT 0:0:0:1::0
        -intf_metric                        RANGE   0-16777215
        -intf_type                          CHOICES broadcast ptop
        -ip_version                         CHOICES 4 6 4_6
                                            DEFAULT 4
        -l1_router_priority                 RANGE   0-255
        -l2_router_priority                 RANGE   0-255
        -loopback_bfd_registration          CHOICES 0 1
                                            DEFAULT 0
        -loopback_ip_addr                   IPV4
        -loopback_ip_addr_step              IPV4
                                            DEFAULT 0.0.0.1
        -loopback_ip_prefix_length          RANGE 0-32
                                            DEFAULT 24
        -loopback_ip_addr_count             NUMERIC
                                            DEFAULT 1
        -loopback_metric                    RANGE   0-16777215
        -loopback_type                      CHOICES broadcast ptop
        -loopback_routing_level             CHOICES L1 L2 L1L2
        -loopback_l1_router_priority        RANGE   0-255
        -loopback_l2_router_priority        RANGE   0-255
        -loopback_te_metric                 RANGE   0-2147483647
        -loopback_te_admin_group            RANGE   0-2147483647
        -loopback_te_max_bw                 NUMERIC
        -loopback_te_max_resv_bw            NUMERIC
        -loopback_te_unresv_bw_priority0    NUMERIC
        -loopback_te_unresv_bw_priority1    NUMERIC
        -loopback_te_unresv_bw_priority2    NUMERIC
        -loopback_te_unresv_bw_priority3    NUMERIC
        -loopback_te_unresv_bw_priority4    NUMERIC
        -loopback_te_unresv_bw_priority5    NUMERIC
        -loopback_te_unresv_bw_priority6    NUMERIC
        -loopback_te_unresv_bw_priority7    NUMERIC
        -loopback_hello_password            CHOICES 0 1
        -lsp_life_time                      RANGE   1-65535
        -lsp_refresh_interval               RANGE   1-65535
        -mac_address_init                   MAC
        -mac_address_step                   MAC 
                                            DEFAULT 0000.0000.0001
        -no_write                           FLAG
        -max_packet_size                    RANGE   576-32832
        -partition_repair                   CHOICES 0 1
        -overloaded                         CHOICES 0 1
        -override_existence_check           CHOICES 0 1
                                            DEFAULT 0
        -override_tracking                  CHOICES 0 1
                                            DEFAULT 0
        -reset                              FLAG
        -routing_level                      CHOICES L1 L2 L1L2
        -system_id
        -system_id_step                     DEFAULT 1
        -te_enable                          CHOICES 0 1
        -te_router_id                       IP
        -te_router_id_step                  IP
                                            DEFAULT 0.0.0.1
        -te_metric                          RANGE   0-2147483647
        -te_admin_group                     RANGE   0-2147483647
        -te_max_bw                          NUMERIC
        -te_max_resv_bw                     NUMERIC
        -te_unresv_bw_priority0             NUMERIC
        -te_unresv_bw_priority1             NUMERIC
        -te_unresv_bw_priority2             NUMERIC
        -te_unresv_bw_priority3             NUMERIC
        -te_unresv_bw_priority4             NUMERIC
        -te_unresv_bw_priority5             NUMERIC
        -te_unresv_bw_priority6             NUMERIC
        -te_unresv_bw_priority7             NUMERIC
        -type                               CHOICES dce_isis_draft_ward_l2_isis_04 isis_l3_routing
                                            DEFAULT isis_l3_routing
        -vlan                               CHOICES 0 1
        -vlan_id                            RANGE   0-4095
        -vlan_id_mode                       CHOICES fixed increment
                                            DEFAULT increment
        -vlan_id_step                       RANGE   0-4096
                                            DEFAULT 1
        -vlan_user_priority                 RANGE   0-7
                                            DEFAULT 0
        -vpi                                RANGE   0-255
                                            DEFAULT 1
        -vci                                RANGE   0-65535
                                            DEFAULT 10
        -vpi_step                           RANGE   0-255
                                            DEFAULT 1
        -vci_step                           RANGE   0-65535
                                            DEFAULT 1
        -wide_metrics                       CHOICES 0 1
                                            DEFAULT 0
        -multi_topology                     CHOICES 0 1
                                            DEFAULT 0
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_isis_config $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        return $returnList
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args

    if {[info exists area_id]} {
        set area_id [::ixia::formatAreaId $area_id]
    }
            
    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
    }

    set isisCommandArray {
        isisRouter    isisRouterOptionsArray
        isisInterface isisInterfaceOptionsArray
    }
    
    array set isisServerOptionsArray {
        emulationType               type
    }
            
    array set isisRouterOptionsArray {
        enable                      enable
        areaAddressList             area_id
        routerId                    system_id
        enableWideMetric            wide_metrics
        enableDiscardLearnedLSPs    discard_lsp
        enableAttached              attach_bit
        enablePartitionRepair       partition_repair
        enableOverloaded            overloaded
        enableHitlessRestart        graceful_restart
        hitlessRestartMode          graceful_restart_mode
        hitlessRestartVersion       graceful_restart_version
        hitlessRestartTime          graceful_restart_restart_time
        areaAuthType                area_authentication_mode
        areaRxPasswordList          area_password
        areaTxPassword              area_password
        domainAuthType              domain_authentication_mode
        domainRxPasswordList        domain_password
        domainTxPassword            domain_password
        lspLifetime                 lsp_life_time
        lspRefreshRate              lsp_refresh_interval
        lspMaxSize                  max_packet_size
        enableTrafficEngineering    te_enable
        trafficEngineeringRouterId  te_router_id
        capabilityRouterId          dce_capability_router_id
        broadcastRootPriority       dce_bcast_root_priority
        numberOfMultiDestinationTrees dce_num_mcast_dst_trees
        deviceId                    dce_device_id
        devicePriority              dce_device_pri
        enableFtag                  dce_ftag_enable
        fTagValue                   dce_ftag
        enableMtIpv6                multi_topology
    }
    
    array set isisInterfaceOptionsArray {
        enable                       enable
        enableBFDRegistration        bfd_registration
        metric                       intf_metric
        networkType                  intf_type
        level                        routing_level
        priorityLevel1               l1_router_priority
        priorityLevel2               l2_router_priority
        teMetric                     te_metric
        administrativeGroup          te_admin_group
        maxBandwidth                 te_max_bw
        maxReservableBandwidth       te_max_resv_bw
        unreservedBandwidthPriority0 te_unresv_bw_priority0
        unreservedBandwidthPriority1 te_unresv_bw_priority1
        unreservedBandwidthPriority2 te_unresv_bw_priority2
        unreservedBandwidthPriority3 te_unresv_bw_priority3
        unreservedBandwidthPriority4 te_unresv_bw_priority4
        unreservedBandwidthPriority5 te_unresv_bw_priority5
        unreservedBandwidthPriority6 te_unresv_bw_priority6
        unreservedBandwidthPriority7 te_unresv_bw_priority7
        circuitAuthType              hello_password
        circuitTxPassword            hello_tx_password
        circuitRxPasswords           hello_rx_password
    }
    
    array set isisLoopInterfaceOptionsArray {
        enable                       enable
        ipAddress                    loopback_ip_addr
        ipMask                       loopback_ip_mask
        metric                       loopback_metric
        networkType                  loopback_type
        level                        loopback_routing_level
        priorityLevel1               loopback_l1_router_priority
        priorityLevel2               loopback_l2_router_priority
        teMetric                     loopback_te_metric
        administrativeGroup          loopback_te_admin_group
        maxBandwidth                 loopback_te_max_bw
        maxReservableBandwidth       loopback_te_max_resv_bw
        unreservedBandwidthPriority0 loopback_te_unresv_bw_priority0
        unreservedBandwidthPriority1 loopback_te_unresv_bw_priority1
        unreservedBandwidthPriority2 loopback_te_unresv_bw_priority2
        unreservedBandwidthPriority3 loopback_te_unresv_bw_priority3
        unreservedBandwidthPriority4 loopback_te_unresv_bw_priority4
        unreservedBandwidthPriority5 loopback_te_unresv_bw_priority5
        unreservedBandwidthPriority6 loopback_te_unresv_bw_priority6
        unreservedBandwidthPriority7 loopback_te_unresv_bw_priority7
        circuitAuthType              loopback_hello_password
        circuitTxPassword            loopback_hello_tx_password
        circuitRxPasswords           loopback_hello_rx_password
        helloIntervalLevel1          hello_interval
        helloIntervalLevel2          hello_interval
    }

    array set dataSet {
        text                             isisAuthTypePassword
        null                             isisAuthTypeNone
        L1                               isisLevel1
        L2                               isisLevel2
        L1L2                             isisLevel1Level2
        draft3                           isisDraftVersion3
        draft4                           isisDraftVersion4
        normal                           isisNormalRouter
        restarting                       isisRestartingRouter
        starting                         isisStartingRouter
        helper                           isisHelperRouter
        broadcast                        isisBroadcast
        ptop                             isisPointToPoint
        dce_isis_draft_ward_l2_isis_04   {dceIsisDraftWardL2Isis04 dceIsis}
        isis_l3_routing                  isisL3Routing
    }
    

    ######################################################################
    #  Take care of modes - all modes except "create" mode need to have
    #  -handle option passed in
    ######################################################################
    if {$mode != "create"} {
        if {![info exists handle]} {
            keylset returnList log "ERROR in $procName: No -handle was\
                    passed to modify the ISIS router"
            keylset returnList status $::FAILURE
            return $returnList
        } else {
            if {[array names isis_handles_array $handle,session] == ""} {
                keylset returnList log "$procName: cannot find the session\
                        handle $handle in the isis_handles_array"
                keylset returnList status $::FAILURE
                return $returnList
            }
            set port_handle [lindex $isis_handles_array($handle,session) 0]
        }
    }
    set port_list [format_space_port_list $port_handle]
    set interface [lindex $port_list 0]
    foreach {chassis card port} $interface {}
    ::ixia::addPortToWrite $chassis/$card/$port
    
    # Check if ISIS package has been installed on the port
    debug "isisServer select $chassis $card $port"
    if {[catch {isisServer select $chassis $card $port} error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The ISIS protocol\
                has not been installed on port or is not supported on port: \
                $chassis/$card/$port."
        return $returnList
    }
    
    # Reset if requested
    if {[info exists reset]} {
        isisServer select $chassis $card $port
        debug "isisServer select $chassis $card $port"
        isisServer clearAllRouters
        debug "isisServer clearAllRouters"
        updateIsisHandleArray reset $chassis/$card/$port
    }

    ######################################################################
    #  Take care of "enable", "disable" and "delete" mode first
    ######################################################################
    switch $mode {
        "enable" - 
        "disable" -
        "delete" {
            set returnList [actionIsis $chassis $card $port $mode $handle]

            if {[keylget returnList status] == $::FAILURE} {
                return $returnList
            }

            if {$mode == "delete"} {
                updateIsisHandleArray delete $port_handle $handle
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

            keylset returnList handle $handle
            return $returnList
        }
    }

    #######################################################################
    # For $mode == create, configure the Protocol Interface
    #######################################################################
    if {$mode == "create"} {
        if {![info exists vlan] && [info exists vlan_id]} {
            set vlan $::true
        }
        set numIpProtocol [scan $ip_version "%d_%d" ipFirstVer ipNextVer]

        # Get the number of interfaces already configured on the port
        set num_existing_interfaces [get_number_of_intf "$chassis $card $port"]
        for {set i 0} {$i < $numIpProtocol} {incr i} {
            if {$i == 0} {
                set ipProtocolVersion $ipFirstVer
            } else {
                set ipProtocolVersion $ipNextVer
            }
            
            set config_options \
                    "-port_handle       port_handle        \
                    -ip_version         ipProtocolVersion  \
                    -mac_address        mac_address_init   \
                    -count              count              \
                    -atm_vci            vci                \
                    -atm_vci_step       vci_step           \
                    -atm_vpi            vpi                \
                    -atm_vpi_step       vpi_step           \
                    -vlan_id            vlan_id            \
                    -vlan_id_mode       vlan_id_mode       \
                    -vlan_id_step       vlan_id_step       \
                    -vlan_user_priority vlan_user_priority \
                    -no_write           no_write           "
            
            if {$ipProtocolVersion == $IPV6 } {
                append config_options \
                        "-ip_address     intf_ipv6_addr          \
                        -ip_address_step intf_ipv6_addr_step     \
                        -netmask         intf_ipv6_prefix_length \
                        -gateway_ip_address      gateway_ipv6_addr      \
                        -gateway_ip_address_step gateway_ipv6_addr_step "
            } else {
                append config_options \
                        "-ip_address             intf_ip_addr           \
                        -ip_address_step         intf_ip_addr_step      \
                        -netmask                 intf_ip_prefix_length  \
                        -gateway_ip_address      gateway_ip_addr      \
                        -gateway_ip_address_step gateway_ip_addr_step "
            }

            # Pass in only those options that exist
            set config_param ""
            foreach {option value_name} $config_options {
                if {[info exists $value_name]} {
                    append config_param "$option [set $value_name] "
                }
            }

            if {[info exists interface_handle]} {
                # Do nothing, the code below queries if the required interface
                # exists.
            } else {
                set config_status [eval ixia::protocol_interface_config \
                        $config_param]

                if {[keylget config_status status] ==  $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: failed to\
                            configure protocol interfaces on $port_handle.  Log :\
                            [keylget config_status log]"
                    return $returnList
                }
            }
        }
    }

    # Select the port for isisServer to operate on
    if {[set retCode [isisServer select $chassis $card $port]]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed to\
                start protocol configuration on port $chassis/$card/$port\
                (isisServer select $chassis $card $port returned $retCode).\
                $::ixErrorInfo"
        return $returnList
    }

    set isis_neighbor_list [list]

    if {$mode == "create"} {
        ######################################################################
        ### Set Default values - these require some work to derive the default
        ### values. The simple default values are set in optional_args
        ######################################################################
        set enable $::true
        set dceIsisMode 0
        foreach dataSetElem $dataSet($type) {
            if {[info exists ::$dataSetElem]} {
                isisServer config -emulationType [set ::$dataSetElem]
                debug "isisServer config -emulationType [set ::$dataSetElem]"
                if {[set retCode [isisServer set ]]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to\
                            set protocol configuration on port $chassis/$card/$port\
                            (isisServer set returned $retCode).\
                            $::ixErrorInfo"
                    return $returnList
                }
                debug "isisServer set"
                break;
            } else {
                if {$type == "dce_isis_draft_ward_l2_isis_04"} {
                    incr dceIsisMode
                    
                    # Set mandatory values for DCE ISIS mode
                    set intf_type     ptop
                    set routing_level L1
                }
            }
        }
        if {$dceIsisMode == [llength $dataSet($type)]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: ISIS protocol could\
                    not be switched to DCE ISIS functionality.\
                    A DCE ISIS configuration cannot be completed"
            return $returnList
        }
        
        if {[set retCode [isisServer select $chassis $card $port]]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to\
                    start router configuration on port $chassis/$card/$port\
                    (isisServer select $chassis $card $port returned $retCode).\
                    $::ixErrorInfo"
            return $returnList
        }
        
        if {![info exists system_id]} {
            set system_id [ip2num $intf_ip_addr]
        } else {
            # check system_id if has a valid value
            set match 0
            foreach {reg_exp type} [list "^\\d+$" "n" "^0x\[0-9a-f\]+$" "n" \
                    "^(\[0-9a-f\]{2}\ ){5}(\[0-9a-f\]{2})$" "e" \
                    "^(\[0-9a-f\]{2}\.){5}(\[0-9a-f\]{2})$" "e" \
                    "^(\[0-9a-f\]{2}\:){5}(\[0-9a-f\]{2})$" "e" ] {
                if {[regexp -nocase -- $reg_exp $system_id]} {
                    set match 1
                    if {$type == "e"} {
                        set system_id "0x[regsub -all "\[.: \]" $system_id {}]"
                    }
                    break
                }
            }
            if {!$match} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR on $procName: invalid value \
                        specified for system_id."
                return $returnList
            }
        }
        ### convert hex number to a list of hex bytes
        set id_length   6
        set system_id [val2Bytes $system_id $id_length]
        
        ## Setting system_id_step
        # check value 
        set match 0
        foreach {reg_exp type} [list "^\\d+$"            "n"  \
                "^0x\[0-9a-f\]+$"                        "n"  \
                "^(\[0-9a-f\]{2}\ ){5}(\[0-9a-f\]{2})$"  "e"  \
                "^(\[0-9a-f\]{2}\\.){5}(\[0-9a-f\]{2})$" "e"  \
                "^(\[0-9a-f\]{2}:){5}(\[0-9a-f\]{2})$"   "e"  ] {
            if {[regexp -nocase -- $reg_exp $system_id_step]} {
                set match 1
                if {$type == "e"} {
                    set system_id_step \
                            "0x[regsub -all "\[.: \]" $system_id_step {}]"
                }
                break
            }
        }
        if {!$match} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR on $procName: invalid value \
                    specified for system_id_step."
            return $returnList
        }

        # If TE is enables and the user does not provide a TE router ID,
        # For IPV4 interface, the IP address of the interface will be
        # designated by default;  for IPV6, a arbitrary IPV4 default value
        # is assigned.
        if {([info exists te_enable]) && ($te_enable == $::true)} {
            if {![info exists te_router_id]} {
                if {$ip_version == 6} {
                    set te_router_id $default_te_router_id
                } else {
                    set first_intf_addr [get_interface_ip \
                            "$chassis $card $port" 1 $IPV4]
                    set te_router_id $first_intf_addr
                }
            }
        }

        # Default
        isisRouter    setDefault
        debug "isisRouter    setDefault"
        isisInterface setDefault
        debug "isisInterface setDefault"

        # set initial IP address for getting the interface description.  For dual
        # IPV4/IPV6 interface, both IPV4 and IPV6 have the same interface
        # description.
        scan $ip_version "%d" ipVersion
        if {![info exists interface_handle]} {
            if {$ipVersion == $IPV4} {
                set ixia_ip_address $intf_ip_addr
            } else {
                set ixia_ip_address $intf_ipv6_addr
            }
        }
        
        if {[info exists te_admin_group]} {
            set te_admin_group [val2Bytes $te_admin_group 4]
        }
        set intfIndex 0
        for {set node 0} {$node < $count} {incr node} {
            # Get number of current ldp routers and interfaces if any
            set next_isis_router [get_next_router_number isis \
                    "$chassis $card $port"]
            updateIsisHandleArray create $port_handle $next_isis_router
            debug "isisRouter clearAllInterfaces"
            isisRouter clearAllInterfaces
            
            debug "isisRouter clearAllRouteRanges"
            isisRouter clearAllRouteRanges
            
            debug "isisRouter clearAllGrids"
            isisRouter clearAllGrids
            
            debug "isisRouter clearAllDceNetworkRanges"
            catch {isisRouter clearAllDceNetworkRanges}
            
            debug "isisRouter clearAllMulticastMacRanges"
            catch {isisRouter clearAllMulticastMacRanges}
            
            debug "isisRouter clearAllMulticastIpv4GroupRanges"
            catch {isisRouter clearAllMulticastIpv4GroupRanges}
            
            debug "isisRouter clearAllMulticastIpv6GroupRanges"
            catch {isisRouter clearAllMulticastIpv6GroupRanges}
        
            if {[info exists hello_interval]} {
                isisInterface config -helloIntervalLevel1 $hello_interval
                debug "isisInterface config -helloIntervalLevel1 $hello_interval"
                isisInterface config -helloIntervalLevel2 $hello_interval
                debug "isisInterface config -helloIntervalLevel2 $hello_interval"
            }
            
            if {[info exists routing_level] && \
                    [info exists hello_password] && ($hello_password)} {
                
                switch -- $routing_level {
                    L1
                    - L1L2{
                        if {[info exists area_password]} {
                            set hello_tx_password $area_password
                            set hello_rx_password $area_password
                        }
                    }
                    L2   {
                        if {[info exists domain_password]} {
                            set hello_tx_password $domain_password
                            set hello_rx_password $domain_password
                        }
                    }
                }
            }
            ##BUG611097: if wide_metrics is provided we should not use the default.
            ### Enable wide_metrics, multi_topology if ip_version is 4_6 as 
            ### defined by Cisco's HLTAPI spec
            if {$ip_version == "4_6"} {
                if {[::ixia::is_default_param_value wide_metrics $args]} {
                    set wide_metrics $::true
                }
                if {[::ixia::is_default_param_value multi_topology $args]} {
                    set multi_topology $::true
                }
            }
            foreach {isisCommand optionsArray}  $isisCommandArray {
                foreach {item itemName} [array get $optionsArray] {
                    if {![catch {set $itemName} value] } {
                        if {[lsearch [array names dataSet] $value] != -1} {
                            set value [set ::$dataSet($value)]
                        }
                        catch {$isisCommand config -$item $value}
                        debug "$isisCommand config -$item $value"
                    }                    
                }
            }


            isisInterface config -connectToDut $::true
            debug "isisInterface config -connectToDut $::true"
            # Configure isisInterface description.  For dual protocol
            # interface, it does not matter which protocol item (IPv4 or IPv6).
            # It should contain the same interface description
            
            if {![info exists interface_handle]} {
                set interface_check_list [::ixia::interface_exists \
                        -port_handle $port_handle -ip_version $ipFirstVer \
                        -ip_address $ixia_ip_address]
    
                if {[keylget interface_check_list status] != 1} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Could not find the\
                            interface with IPV$ipProtocolVersion address\
                            $ixia_ip_address on port $port_list."
                    return $returnList
                }
                isisInterface config -protocolInterfaceDescription \
                        [keylget interface_check_list description]
                
                debug "isisInterface config -protocolInterfaceDescription \
                        {[keylget interface_check_list description]}"
            } else {
                set interface_description [rfget_interface_description_from_handle\
                        [lindex $interface_handle $intfIndex]]
                if {[llength $interface_description] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            Invalid interface handle provided: [lindex $interface_handle $intfIndex].\
                            The interface_handle parameter should be provided with interface handles obtained when calling ::ixia::interface_config.\n\
                            $::ixErrorInfo."
                    return $returnList
                }
                isisInterface config -protocolInterfaceDescription \
                        $interface_description
                
                debug "isisInterface config -protocolInterfaceDescription \
                        \{$interface_description\}"
                
                incr intfIndex
            }
            
            
            debug "isisRouter addInterface isisInterface0"
            if {[isisRouter addInterface isisInterface0]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        Failed to isisRouter addInterface isisInterface0.\n \
                        $::ixErrorInfo."
                return $returnList
            }
            
            # Create loopback interfaces
            if {[info exists loopback_ip_addr]} {
                set loopback_ip_mask [getIpV4MaskFromWidth \
                        $loopback_ip_prefix_length]
                
                if {[info exists loopback_routing_level] && \
                            [info exists loopback_hello_password] && \
                            ($loopback_hello_password)} {
                    
                    switch -- $loopback_routing_level {
                        L1
                        - L1L2{
                            if {[info exists area_password]} {
                                set loopback_hello_tx_password $area_password
                                set loopback_hello_rx_password $area_password
                            }
                        }
                        L2   {
                            if {[info exists domain_password]} {
                                set loopback_hello_tx_password $domain_password
                                set loopback_hello_rx_password $domain_password
                            }
                        }
                    }
                }
                
                for {set loopNum 1} {$loopNum <= $loopback_ip_addr_count} \
                        {incr loopNum} {
                    
                    isisInterface setDefault
                    debug "isisInterface setDefault"
                    isisInterface config -connectToDut $::false
                    debug "isisInterface config -connectToDut $::false"
                    foreach {item itemName} \
                    [array get isisLoopInterfaceOptionsArray] {
                        
                        if {![catch {set $itemName} value] } {
                            if {[lsearch [array names enumList] $value] != -1} {
                                set value $enumList($value)
                            }
                            catch {isisInterface config -$item $value}
                            debug "isisInterface config -$item $value"
                        }
                    }
                    debug "isisRouter addInterface isisInterface$loopNum"
                    if {[isisRouter addInterface isisInterface$loopNum]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                Failed to isisRouter addInterface\
                                isisInterface$loopNum.\n \
                                $::ixErrorInfo."
                        return $returnList
                    }
                    set loopback_ip_addr [increment_ipv4_address_hltapi \
                            $loopback_ip_addr $loopback_ip_addr_step]
                }
            }
            
            lappend isis_neighbor_list $next_isis_router

            set system_id_val [list2Val $system_id]
            mpincr system_id_val $system_id_step
            set system_id [val2Bytes $system_id_val $id_length]
            
            if {[info exists area_id] && [info exists area_id_step]} {
                set area_id_length [llength $area_id]
                set area_id [val2Bytes [mpexpr [list2Val $area_id] + \
                        [list2Val $area_id_step]] $area_id_length]
            }
            
            if {[info exists te_router_id] && [info exists te_router_id_step]} {
                set te_router_id [increment_ipv4_address_hltapi \
                        $te_router_id $te_router_id_step]
            }
            debug "isisServer addRouter $next_isis_router"
            if {[isisServer addRouter $next_isis_router] != 0 } {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Could not add ISIS\
                        router $next_isis_router to port $chassis $card $port."
                return $returnList
            }
            if {![info exists interface_handle]} {
                if {$ipVersion == $IPV4} {
                    set ixia_ip_address [::ixia::increment_ipv4_address_hltapi \
                            $ixia_ip_address $intf_ip_addr_step]
                } else {
                    set ixia_ip_address [::ixia::increment_ipv6_address_hltapi \
                            $ixia_ip_address $intf_ipv6_addr_step]
                }
            }
        }

        set retCode [protocolServer get $chassis $card $port]
        if {$retCode != 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failure in call to\
                    protocolServer get $chassis $card $port.  Return code was\
                    $retCode."
            return $returnList
        }
        protocolServer config -enableIsisService true
        set retCode [protocolServer set $chassis $card $port]
        if {$retCode != 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failure in call to\
                    protocolServer set $chassis $card $port.  Return code was\
                    $retCode."
            return $returnList
        }
        
        stat config -enableIsisStats   true
        set retCode [stat set $chassis $card $port]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failure in call to\
                    stat set $chassis $card $port. \
                    Return code was $retCode."
            return $returnList
        }
        
    } else {
        #### mode = modify
        if {[isisServer getRouter $handle] != 0 } {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Could not get\
                    ISIS router with $handle from port $chassis $card $port."
            return $returnList
        }
        if {[isisRouter getInterface isisInterface0] != 0 } {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: failed with isisRouter\
                    getInterface isisInterface0 command on port\
                    $chassis $card $port"
            return $returnList
        }
        if {[info exists hello_interval]} {
            isisInterface config -helloIntervalLevel1 $hello_interval
            isisInterface config -helloIntervalLevel2 $hello_interval
        }

        foreach {isisCommand optionsArray}  [array get isisCommandArray] {
            foreach {item itemName} [array get $optionsArray] {
                if {![catch {set $itemName} value] } {
                    if {[lsearch [array names enumList] $value] != -1} {
                        set value $enumList($value)
                    }
                    catch {$isisCommand config -$item $value}
                }
            }
        }
        if {[isisRouter setInterface isisInterface0] != 0 } {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: failed with command:\
                    isisRouter setInterface isisInterface0 on port $chassis\
                    $card $port."
            return $returnList
        }
        if {[isisServer setRouter $handle] != 0 } {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Could not modify\
                    ISIS router $next_isis_router to port $chassis $card $port."
            return $returnList
        }
        lappend isis_neighbor_list $handle
    }

    ### clean up configurations in local memory
    if {[isisRouter clearAllInterfaces]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: failed with isisRouter\
                clearAllInterfaces command.  $::ixErrorInfo"
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

    keylset returnList status $::SUCCESS
    keylset returnList handle $isis_neighbor_list
    return $returnList
}


proc ::ixia::emulation_isis_topology_route_config { args } {
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
                \{::ixia::emulation_isis_topology_route_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
        
    variable new_ixnetwork_api
    variable isis_handles_array
    keylset returnList status $::SUCCESS
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set man_args {
        -mode   CHOICES create modify delete
    }

    set opt_args {
        -handle
        -elem_handle
        -type                        CHOICES router grid stub external 
                                     CHOICES dce_mcast_mac_range dce_mcast_ipv4_group_range dce_mcast_ipv6_group_range
                                     CHOICES dce_node_mac_group dce_node_ipv4_group dce_node_ipv6_group
                                     CHOICES dce_network_range dce_outside_link
        -ip_version                  CHOICES 4 6 4_6
                                     DEFAULT 4_6
        -router_system_id
        -router_id                   IP
        -router_area_id
        -router_te                   CHOICES 0 1
        -router_connect
        -link_narrow_metric          RANGE   0-63
                                     DEFAULT 0
        -link_wide_metric            RANGE   0-16777215
                                     DEFAULT 0
        -link_ip_addr                IP
                                     DEFAULT 0.0.0.0
        -link_ip_prefix_length       RANGE   1-32
                                     DEFAULT 24
        -link_ipv6_addr              IP
                                     DEFAULT 3000::0
        -link_ipv6_prefix_length     RANGE   1-128
                                     DEFAULT 64
        -link_multi_topology         CHOICES 1
        -link_enable                 CHOICES 0 1
        -link_te                     CHOICES 0 1
                                     DEFAULT 0
        -link_te_metric              RANGE   0-16777215
                                     DEFAULT 0
        -link_te_max_bw              NUMERIC
        -link_te_max_resv_bw         NUMERIC
        -link_te_unresv_bw_priority0 NUMERIC
        -link_te_unresv_bw_priority1 NUMERIC
        -link_te_unresv_bw_priority2 NUMERIC
        -link_te_unresv_bw_priority3 NUMERIC
        -link_te_unresv_bw_priority4 NUMERIC
        -link_te_unresv_bw_priority5 NUMERIC
        -link_te_unresv_bw_priority6 NUMERIC
        -link_te_unresv_bw_priority7 NUMERIC
        -link_te_admin_group         RANGE 1-2147483647
        -grid_row                    NUMERIC
        -grid_col                    NUMERIC
        -grid_user_wide_metric       CHOICES 0 1
                                     DEFAULT 1
        -grid_stub_per_router        NUMERIC
        -grid_router_count           NUMERIC
        -grid_router_id              IP
        -grid_router_id_step         IP
        -grid_router_ip_version      CHOICES 4 6
                                     DEFAULT 4
        -grid_router_route_step      NUMERIC
        -grid_link_type              CHOICES broadcast ptop
        -grid_ip_start               IP
                                     DEFAULT 0.0.0.0
        -grid_ip_pfx_len             VCMD ::ixia::validate_list_range_1_32
                                     DEFAULT 24
        -grid_ip_step                IP
                                     DEFAULT 0.0.1.0
        -grid_ipv6_start             IP
                                     DEFAULT 3000::0
        -grid_ipv6_pfx_len           VCMD ::ixia::validate_list_range_1_128
                                     DEFAULT 64
        -grid_ipv6_step              IP
                                     DEFAULT 0:0:0:1::0
        -grid_start_te_ip            IP
        -grid_te_ip_step             IP
                                     DEFAULT 0.0.0.1
        -grid_start_system_id        REGEXP  ^[0-9,a-f,A-F]+$
        -grid_system_id_step         REGEXP  ^[0-9,a-f,A-F]+$
                                     DEFAULT 0x000000000001
        -grid_connect                DEFAULT 1 1
        -grid_outside_link           CHOICES 0 1
                                     DEFAULT 0
        -grid_ol_connection_row      NUMERIC
        -grid_ol_connection_col      NUMERIC
        -grid_ol_linked_rid          REGEXP  ^[0-9,a-f,A-F]+$
        -grid_ol_ip_and_prefix         
        -grid_ol_admin_group         RANGE 0-2147483647
        -grid_ol_metric              RANGE 0-16777215
        -grid_ol_max_bw              NUMERIC
        -grid_ol_max_resv_bw         NUMERIC
        -grid_ol_unresv_bw_priority0 DECIMAL        
        -grid_ol_unresv_bw_priority1 DECIMAL
        -grid_ol_unresv_bw_priority2 DECIMAL
        -grid_ol_unresv_bw_priority3 DECIMAL
        -grid_ol_unresv_bw_priority4 DECIMAL
        -grid_ol_unresv_bw_priority5 DECIMAL
        -grid_ol_unresv_bw_priority6 DECIMAL
        -grid_ol_unresv_bw_priority7 DECIMAL
        -grid_te                     CHOICES 0 1
                                     DEFAULT 0
        -grid_router_metric          NUMERIC
        -grid_router_ip_pfx_len      RANGE   1-128
                                     DEFAULT 24
        -grid_router_up_down_bit     CHOICES 0 1
        -grid_router_origin          CHOICES stub external
        -grid_te_admin               RANGE   0-2147483647
        -grid_te_max_bw              NUMERIC
        -grid_te_max_resv_bw         NUMERIC
        -grid_te_metric              NUMERIC
        -grid_te_override_admin               RANGE   0-2147483647
        -grid_te_override_enable              CHOICES 0 1
        -grid_te_override_max_bw              DECIMAL
        -grid_te_override_max_resv_bw         DECIMAL
        -grid_te_override_metric              NUMERIC
        -grid_te_override_unresv_bw_priority0 DECIMAL
        -grid_te_override_unresv_bw_priority1 DECIMAL
        -grid_te_override_unresv_bw_priority2 DECIMAL
        -grid_te_override_unresv_bw_priority3 DECIMAL
        -grid_te_override_unresv_bw_priority4 DECIMAL
        -grid_te_override_unresv_bw_priority5 DECIMAL
        -grid_te_override_unresv_bw_priority6 DECIMAL
        -grid_te_override_unresv_bw_priority7 DECIMAL
        -grid_te_path_count               NUMERIC
                                          DEFAULT 0
        -grid_te_path_start_row           NUMERIC
        -grid_te_path_start_col           NUMERIC
        -grid_te_path_end_row             NUMERIC
        -grid_te_path_end_col             NUMERIC
        -grid_te_path_row_step            NUMERIC
        -grid_te_path_col_step            NUMERIC
        -grid_te_path_bidir               NUMERIC
        -grid_te_path_admin               RANGE   0-2147483647
        -grid_te_path_metric              NUMERIC
        -grid_te_path_max_bw              DECIMAL
        -grid_te_path_max_resv_bw         DECIMAL
        -grid_te_path_unresv_bw_priority0 DECIMAL
        -grid_te_path_unresv_bw_priority1 DECIMAL
        -grid_te_path_unresv_bw_priority2 DECIMAL
        -grid_te_path_unresv_bw_priority3 DECIMAL
        -grid_te_path_unresv_bw_priority4 DECIMAL
        -grid_te_path_unresv_bw_priority5 DECIMAL
        -grid_te_path_unresv_bw_priority6 DECIMAL
        -grid_te_path_unresv_bw_priority7 DECIMAL 
        -grid_te_unresv_bw_priority0 DECIMAL
        -grid_te_unresv_bw_priority1 DECIMAL
        -grid_te_unresv_bw_priority2 DECIMAL
        -grid_te_unresv_bw_priority3 DECIMAL
        -grid_te_unresv_bw_priority4 DECIMAL
        -grid_te_unresv_bw_priority5 DECIMAL
        -grid_te_unresv_bw_priority6 DECIMAL
        -grid_te_unresv_bw_priority7 DECIMAL
        -grid_interface_metric       NUMERIC
        -stub_ip_start               IP
                                     DEFAULT 0.0.0.0
        -stub_ip_pfx_len             RANGE   1-32
                                     DEFAULT 24
        -stub_ip_step                IP
                                     DEFAULT 0.0.1.0
        -stub_ipv6_start             IP
                                     DEFAULT 3000::0
        -stub_ipv6_pfx_len           RANGE   1-128
                                     DEFAULT 64
        -stub_ipv6_step              IP
                                     DEFAULT 0:0:0:1::0
        -stub_count                  NUMERIC
        -stub_route_count            NUMERIC
        -stub_metric                 NUMERIC
        -stub_up_down_bit            CHOICES 0 1
        -stub_connect                DEFAULT 1 1
        -external_ip_start           IP
                                     DEFAULT 0.0.0.0
        -external_ip_pfx_len         RANGE   1-32
                                     DEFAULT 24
        -external_ip_step            IP
                                     DEFAULT 0.0.1.0
        -external_ipv6_start         IP
                                     DEFAULT 3000::0
        -external_ipv6_pfx_len       RANGE   1-128
                                     DEFAULT 64
        -external_ipv6_step          IP
                                     DEFAULT 0:0:0:1::0
        -external_count              NUMERIC
        -external_route_count        NUMERIC
        -external_metric             NUMERIC
        -external_up_down_bit        CHOICES 0 1
        -external_connect            NUMERIC
                                     DEFAULT 1
        -dce_bcast_root_pri                    RANGE 0-65535 DEFAULT 65535
        -dce_bcast_root_pri_step               RANGE 0-65535 DEFAULT 0
        -dce_connection_column                 RANGE 1-100000 DEFAULT 1
        -dce_connection_row                    RANGE 1-100000 DEFAULT 1
        -dce_device_id                         RANGE 0-65535 DEFAULT 1
        -dce_device_id_step                    RANGE 0-65535 DEFAULT 1
        -dce_device_pri                        RANGE 0-255 DEFAULT 1
        -dce_ftag                              RANGE 0-65535 DEFAULT 1
        -dce_ftag_enable                       CHOICES 0 1 DEFAULT 0
        -dce_include_groups                    CHOICES 0 1 DEFAULT 0
        -dce_intra_grp_ucast_step
        -dce_inter_grp_ucast_step
        -dce_linked_router_id
        -dce_local_entry_point_column          RANGE 1-100000 DEFAULT 1
        -dce_local_entry_point_row             RANGE 1-100000 DEFAULT 1
        -dce_local_link_metric                 RANGE 0-63 DEFAULT 1
        -dce_local_num_columns                 RANGE 1-100000 DEFAULT 1
        -dce_local_num_rows                    RANGE 1-100000 DEFAULT 1
        -dce_mcast_addr_count                  RANGE 1-4294967295 DEFAULT 1
        -dce_mcast_addr_node_step
        -dce_mcast_addr_step
        -dce_mcast_start_addr
        -dce_num_mcast_destination_trees       RANGE 0-65535 DEFAULT 1
        -dce_src_grp_mapping                   CHOICES fully_meshed one_to_one manual_mapping
                                               DEFAULT fully_meshed
        -dce_system_id
        -dce_system_id_step
        -dce_ucast_addr_node_step
        -dce_ucast_sources_per_mcast_addr      RANGE 0-4294967295 DEFAULT 1
        -dce_ucast_src_addr
        -dce_vlan_id                           RANGE 0-4095 DEFAULT 1
        -no_write                              FLAG
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_isis_topology_route_config $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        return $returnList
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args

    # BUG697632 - For IxTclProtocol external_count and external_route_count must have
    # the same behaviour. If both parameters are given external_count will be used 
    # instead of external_route_count. The same principle applies for the stub_count
    # and stub_route_count pair.
    if {[info exists external_count]} {
        if {[info exists external_route_count]} {
            unset external_route_count
        }
    } else {
        if {[info exists external_route_count]} {
            set external_count $external_route_count
        }
    }
    
    if {[info exists stub_count]} {
        if {[info exists stub_route_count]} {
            unset stub_route_count
        }
    } else {
        if {[info exists stub_route_count]} {
            set stub_count $stub_route_count
        }
    }
    
    if {$mode == "create"} {
        if {![info exists handle]} {
            keylset returnList log "ERROR in $procName: \
                    When -mode is $mode, parameter -handle must be specified."
            keylset returnList status $::FAILURE
            return $returnList
        }
        set param_handle  $handle
        set parent_handle $handle
        set child_handle  ""
    } else {
        if {![info exists elem_handle]} {
            keylset returnList log "ERROR in $procName: \
                    When -mode is $mode, parameter -elem_handle must be specified."
            keylset returnList status $::FAILURE
            return $returnList
        }
        set param_handle  $elem_handle
        set parent_handle ""
        set child_handle  $elem_handle
    }
    
    set level1_handles [array names isis_handles_array -regexp $param_handle,session]
    set leveln_handles [array names isis_handles_array -regexp (.*),topology,${param_handle}$]
    
    if {($level1_handles == "") && ($leveln_handles == "")} {
        keylset returnList log "ERROR in $procName: cannot find the session handle\
                $handle in the isis_handles_array"
        keylset returnList status $::FAILURE
        return $returnList
    }
    
    create_isis_topology_route_arrays
    
    array set leveln_types {
        dce_mcast_mac_range          
        dce_mcast_ipv4_group_range
        dce_mcast_ipv6_group_range
        dce_network_range
        dce_node_mac_group
        dce_node_ipv4_group
        dce_node_ipv6_group
        dce_ouside_link
    }
    
    if {$level1_handles != ""} {
        set port_handle [lindex $isis_handles_array($param_handle,session) 0]
        set router_handle $param_handle
    } else {
        set leveln_handle [lindex $leveln_handles 0]
        if {$mode == "create"} {
            set leveln_type $type
        } else {
            if {[catch {set leveln_type [lindex $isis_handles_array($leveln_handle) 0]}]} {
                keylset returnList log "ERROR in $procName: Invalid handle\
                        $handle in the isis_handles_array."
                keylset returnList status $::FAILURE
                return $returnList
            }
        }
        
        set route_handle  $param_handle
        switch $leveln_type {
            dce_mcast_mac_range -
            dce_mcast_ipv4_group_range -
            dce_mcast_ipv6_group_range - 
            dce_network_range {
                set router_handle [lindex [split $leveln_handle ,] 0]
                set port_handle   [lindex $isis_handles_array($router_handle,session) 0]
                # Modify
                if {$parent_handle == ""} {
                    set parent_handle $router_handle
                }
            }
            dce_node_mac_group -
            dce_node_ipv4_group -
            dce_node_ipv6_group - 
            dce_outside_link {
                set network_range_handle [lindex [split $leveln_handle ,] end]
                set router_handle        [lindex [split $leveln_handle ,] 0]
                set port_handle          [lindex $isis_handles_array($router_handle,session) 0]
                # Modify
                if {$parent_handle == ""} {
                    set parent_handle $network_range_handle
                }
                lappend opt_args -router_handle $router_handle
            }
            router -
            grid -
            stub -
            external  {
                set router_handle [lindex [split $leveln_handle ,] 0]
                set port_handle   [lindex $isis_handles_array($router_handle,session) 0]
                # Modify
                if {$parent_handle == ""} {
                    set parent_handle $router_handle
                }
            }
            default {
                keylset returnList log "ERROR in $procName: Invalid handle type ($leveln_type) for\
                        $handle in the isis_handles_array."
                keylset returnList status $::FAILURE
                return $returnList
            }
        }
    }
    
    scan $port_handle "%d/%d/%d" chasNum cardNum portNum
    ::ixia::addPortToWrite $chasNum/$cardNum/$portNum
    
    # Check if ISIS package has been installed on the port
    if {[catch {isisServer select $chasNum $cardNum $portNum} error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The ISIS protocol\
                has not been installed on port or is not supported on port: \
                $chasNum/$cardNum/$portNum."
        return $returnList
    }
    debug "isisServer select $chasNum $cardNum $portNum"
    if {[isisServer select $chasNum $cardNum $portNum]} {
        keylset returnList log "ERROR in $procName: \
                isisServer select $chasNum $cardNum $portNum failed."
        keylset returnList status $::FAILURE
        return $returnList
    }
    
    ### clean up configurations in local memory
    set cleanupList {
        clearAllRouteRanges
        clearAllInterfaces
        clearAllGrids
        clearAllDceNetworkRanges
        clearAllMulticastMacRanges
        clearAllMulticastIpv4GroupRanges
        clearAllMulticastIpv6GroupRanges
    }
    foreach cleanupElem $cleanupList {
        debug "isisRouter $cleanupElem"
        if {![catch {isisRouter $cleanupElem} retCode] && ($retCode != 0)} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    Failed with isisRouter $cleanupElem\
                    command./n$::ixErrorInfo"
            return $returnList
        }
    }

    ### clean up configurations in local memory
    set cleanupList {
        clearAllDceNodeMacGroups
        clearAllDceNodeIpv4Groups
        clearAllDceNodeIpv6Groups
        clearAllDceOutsideLinks
    }
    foreach cleanupElem $cleanupList {
        debug "isisDceNetworkRange $cleanupElem"
        if {![catch {isisDceNetworkRange $cleanupElem} retCode] && ($retCode != 0)} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    Failed with isisDceNetworkRange $cleanupElem\
                    command./n$::ixErrorInfo"
            return $returnList
        }
    }
    debug "isisServer getRouter $router_handle"
    if {[isisServer getRouter $router_handle]} {
        keylset returnList log "ERROR in $procName: \
                isisServer getRouter $router_handle command failed.\
                \n$::ixErrorInfo"
        keylset returnList status $::FAILURE
        return $returnList
    }
    if {[info exists network_range_handle]} {
        debug "isisRouter getDceNetworkRange $network_range_handle"
        if {[isisRouter getDceNetworkRange $network_range_handle]} {
            keylset returnList log "ERROR in $procName: \
                    isisRouter getDceNetworkRange $network_range_handle command failed.\
                    \n$::ixErrorInfo"
            keylset returnList status $::FAILURE
            return $returnList
        }
    }
    
    switch $mode {
        create {
            set elem_handle [createIsisRouteObject $parent_handle $port_handle $opt_args]
        }
        modify {
            removeDefaultOptionVars $opt_args $args
            set retCode     [getIsisElemInfoFromHandle $parent_handle $child_handle type]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set type [keylget retCode value]
            
            set retCode     [getIsisElemInfoFromHandle $parent_handle $child_handle ip_version]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ip_version [keylget retCode value]
            
            set retCode  [modifyIsisRouteObject $args]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set elem_handle [keylget retCode elem_handle]
        }
        delete {
            set retCode     [getIsisElemInfoFromHandle $parent_handle $child_handle type]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set type [keylget retCode value]
            
            set retCode     [getIsisElemInfoFromHandle $parent_handle $child_handle ip_version]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ip_version [keylget retCode value]
            
            set retCode  [deleteIsisRouteObject $parent_handle $child_handle]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set elem_handle [keylget retCode elem_handle]
        }
    }

    if {$elem_handle == "NULL"} {
        if {![info exists type]} {
            set type ""
        }

        keylset returnList log "ERROR in $procName: failed to\
                $mode $type network objects\
                on port $chasNum $cardNum $portNum\n$::ixErrorInfo"
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
    
    cleanup_isis_topology_route_arrays

    ###########     Constructing the return list ###########
    keylset returnList elem_handle $elem_handle
    keylset returnList version $ip_version

    if {[info exists type]} {
        switch $type {
            grid {
                if {[info exists grid_row]} {
                    keylset returnList grid.connected_session.$handle.row \
                            $grid_row
                }
                if {[info exists grid_col]} {
                    keylset returnList grid.connected_session.$handle.col \
                            $grid_col
                }
            }
            stub {
                if {[info exists stub_count]} {
                    keylset returnList stub.num_networks $stub_count
                }
                
            }
            external {
                if {[info exists external_count]} {
                    keylset returnList external.num_networks $external_count
                }
            }
        }
    }
    return $returnList
}


proc ::ixia::emulation_isis_control { args } {
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
                \{::ixia::emulation_isis_control $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    variable new_ixnetwork_api
    variable isis_handles_array
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set man_args {
        -mode CHOICES start stop restart
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
        set returnList [::ixia::ixnetwork_isis_control $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        keylset returnList clicks [format "%u" $retValueClicks]
        keylset returnList seconds [format "%u" $retValueSeconds]
        return $returnList
    }

    ::ixia::parse_dashed_args -args $args -mandatory_args $man_args\
            -optional_args $opt_args

    ### If port_handle option is not passed in, use the port_handle stored in
    ### the session handle
    if {[info exists port_handle]} {
        # Need to replace the slashes with spaces for IxTclHal api calls using
        # port lists
        set port_list [list]
        for {set index 0} {$index < [llength $port_handle]} {incr index} {
            regsub -all "/" [lindex $port_handle $index] " " temp_port
            lappend port_list $temp_port
        }
    } else {
        if {![info exists handle]} {
            keylset returnList log "$procName: must have either session\
                    handle or port handle option"
            keylset returnList status $::FAILURE
            return $returnList
        }
        if {[array names isis_handles_array $handle,session] == ""} {
            keylset returnList log "$procName: cannot find the session handle \
                    $handle in the isis_handles_array"
            keylset returnList status $::FAILURE
            return $returnList
        }
        set port_handle [lindex $isis_handles_array($handle,session) 0]
        scan $port_handle "%d/%d/%d" chasNum cardNum portNum
        set port_list [list [list $chasNum $cardNum $portNum]]
    }
    
    # Check if ISIS package has been installed on the port
    foreach port_i $port_list {
        foreach {chs_i crd_i prt_i} $port_i {}
        if {[catch {isisServer select $chs_i $crd_i $prt_i } error]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: The ISIS protocol\
                    has not been installed on port or is not supported on port: \
                    $chs_i/$crd_i/$prt_i."
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
    
    switch -exact $mode {
        restart {
            if {[ixStopIsis port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error stopping\
                        IS-IS on the port list $port_list."
                return $returnList
            }
            if {[ixStartIsis port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error starting\
                        IS-IS on the port list $port_list."
                return $returnList
            }
        }
        start {
            if {[ixStartIsis port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error starting\
                        IS-IS on the port list $port_list."
                return $returnList
            }
        }
        stop {
            if {[ixStopIsis port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error stopping\
                        IS-IS on the port list $port_list."
                return $returnList
            }
        }
        default {
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::emulation_isis_info { args } {
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
                \{::ixia::emulation_isis_info $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    variable new_ixnetwork_api
    variable isis_handles_array
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set man_args {
        -mode        CHOICES stats clear_stats learned_info
    }
    set opt_args {
        -port_handle
        -handle
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_isis_info $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        return $returnList
    }
    
    if {[catch {::ixia::parse_dashed_args \
            -args           $args         \
            -mandatory_args $man_args     \
            -optional_args  $opt_args     } parseError]} {
        keylset returnList log "ERROR in $procName: $parseError."
        keylset returnList status $::FAILURE
        return $returnList
    }
    if {![info exists port_handle] && ![info exists handle]} {
        keylset returnList log "ERROR in $procName: \
                One of the parameters -port_handle or -handle must be provided."
        keylset returnList status $::FAILURE
        return $returnList
    }
    if {[info exists port_handle]} {
        set portHandles $port_handle
        array set sessionHandles ""
    } elseif {[info exists handle]} {
        set portHandles    ""
        array set sessionHandles ""
        foreach handleElem $handle {
            if {[info exists isis_handles_array($handleElem,session)]} {
                lappend portHandles    [lindex $isis_handles_array($handleElem,session) 0]
                lappend sessionHandles([lindex $isis_handles_array($handleElem,session) 0]) $handleElem
            }
        }
        set portHandles [lsort -unique $portHandles]
        if {$portHandles == ""} {
            keylset returnList log "ERROR in $procName: \
                    Invalid handles were provided. Parameter -handle must\
                    be provided with a list of ISIS session handles."
            keylset returnList status $::FAILURE
            return $returnList
        }
    }
    
    if {$mode == "clear_stats"} {
        # Reseting all the stats for the selected ports
        if {[ixClearStats portHandles]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to\
                    clear statistics for ports $portHandles."
            return $returnList
        }
    }
    
    if {$mode == "stats"} {
        array set stats_array_aggregate {
            isisIpV4GroupRecordsLearned     ipv4_group_records_learned
            isisIpV6GroupRecordsLearned     ipv6_group_records_learned
            isisL1DBSize                    l1_db_size
            isisL2DBSize                    l2_db_size
            isisMacGroupRecordsLearned      mac_group_recors_learned
            isisNeighborsL1                 full_l1_neighbors
            isisNeighborsL2                 full_l2_neighbors
            isisRBridgesLearned             rbridges_learned
            isisSessionsConfiguredL1        l1_sessions_configured
            isisSessionsConfiguredL2        l2_sessions_configured
            isisSessionsUpL1                l1_sessions_up
            isisSessionsUpL2                l2_sessions_up
        }
        
        foreach {port_h} $portHandles {
            foreach {chassis card port} [split $port_h /] {}
            
            statGroup setDefault
            statGroup add $chassis $card $port
            if {[statGroup get]} {
                keylset returnList log "Failed to\
                        statGroup get $chassis $card $port."
                keylset returnList status $::FAILURE
                return $returnList
            }
        }
        set index 0
        foreach {port_h} $portHandles {
            foreach {chassis card port} [split $port_h /] {}
            
            statList setDefault
            if {[statList get $chassis $card $port]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to\
                        stat get allStats $chassis $card $port."
                return $returnList
            }
            
            foreach {isisStat isisKey} [array get stats_array_aggregate] {
                if {[catch {statList cget -$isisStat} retValue] } {
                    keylset returnList ${port_h}.$isisKey "N/A"
                } else  {
                    keylset returnList ${port_h}.$isisKey $retValue
                }
                if {$index == 0} {
                    if {[catch {statList cget -$isisStat} retValue] } {
                        keylset returnList $isisKey "N/A"
                    } else  {
                        keylset returnList $isisKey $retValue
                    }
                }
            }
            incr index
        }
    }
    
    if {$mode == "learned_info"} {
        foreach portHandle $portHandles {
            foreach {ch ca po} [split $portHandle /] {}
            if {[set retCode [isisServer select $ch $ca $po]]} {
                keylset returnList log "ERROR in $procName: \
                        Failed to isisServer select $ch $ca $po.\
                        Return code was $retCode. $::ixErrorInfo"
                keylset returnList status $::FAILURE
                return $returnList
            }
            if {![info exists sessionHandles($portHandle)]} {
                set sessionHandlesList $isis_handles_array($portHandle)
            } else {
                set sessionHandlesList $sessionHandles($portHandle)
            }
            foreach sessionHandle $sessionHandlesList {
                if {[set retCode [isisServer getRouter $sessionHandle]]} {
                    keylset returnList log "ERROR in $procName: \
                            Failed to isisServer getRouter $sessionHandle.\
                            Return code was $retCode. $::ixErrorInfo"
                    keylset returnList status $::FAILURE
                    return $returnList
                }
                set retries 20
                while {[set retCode [isisRouter requestLearnedInformation]] && $retries} {
                    after 1000
                    incr retries -1
                }
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to request ISIS learned\
                            info on port $ch/$ca/$po for router $sessionHandle.\
                            Return code was $retCode. $::ixErrorInfo"
                    return $returnList
                }
                set retries 20
                while {[set retCode [isisRouter getLearnedInformation]] && $retries} {
                    after 1000
                    incr retries -1
                }
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to retrieve ISIS learned\
                            info on port $ch/$ca/$po for router $sessionHandle.\
                            Return code was $retCode. $::ixErrorInfo"
                    return $returnList
                }
                if {[isisServer cget -emulationType] == 0} {
                
                    # IPv4 Unicast Learned Info
                    set commandLearnedInfo getFirstLearnedIpv4UnicastInfo
                    set index 0
                    while {[isisRouter $commandLearnedInfo] == 0} {
                        keylset returnList $sessionHandle.isis_l3_routing.ipv4.$index.lsp_id \
                                [isisLearnedIpv4Unicast cget -lspId]
                        
                        keylset returnList $sessionHandle.isis_l3_routing.ipv4.$index.sequence_number \
                                [isisLearnedIpv4Unicast cget -sequenceNumber]
                        
                        keylset returnList $sessionHandle.isis_l3_routing.ipv4.$index.prefix \
                                [isisLearnedIpv4Unicast cget -prefix]
                        
                        keylset returnList $sessionHandle.isis_l3_routing.ipv4.$index.metric \
                                [isisLearnedIpv4Unicast cget -metric]
                        
                        keylset returnList $sessionHandle.isis_l3_routing.ipv4.$index.age \
                                [isisLearnedIpv4Unicast cget -age]
                        
                        set commandLearnedInfo getNextLearnedIpv4MulticastInfo
                        incr index
                    }
                    
                    # IPv6 Unicast Learned Info
                    set commandLearnedInfo getFirstLearnedIpv6UnicastInfo
                    set index 0
                    while {[isisRouter $commandLearnedInfo] == 0} {
                        keylset returnList $sessionHandle.isis_l3_routing.ipv6.$index.lsp_id \
                                [isisLearnedIpv6Unicast cget -lspId]
                        
                        keylset returnList $sessionHandle.isis_l3_routing.ipv6.$index.sequence_number \
                                [isisLearnedIpv6Unicast cget -sequenceNumber]
                        
                        keylset returnList $sessionHandle.isis_l3_routing.ipv6.$index.prefix \
                                [isisLearnedIpv6Unicast cget -prefix]
                        
                        keylset returnList $sessionHandle.isis_l3_routing.ipv6.$index.metric \
                                [isisLearnedIpv4Unicast cget -metric]
                        
                        keylset returnList $sessionHandle.isis_l3_routing.ipv6.$index.age \
                                [isisLearnedIpv6Unicast cget -age]
                        
                        set commandLearnedInfo getNextLearnedIpv4MulticastInfo
                        incr index
                    }
                } else {
                    # IPv4 Multicast Learned Info
                    set commandLearnedInfo getFirstLearnedIpv4MulticastInfo
                    set index 0
                    while {[isisRouter $commandLearnedInfo] == 0} {
                        keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.ipv4.$index.lsp_id \
                                [isisLearnedIpv4Multicast cget -lspId]
                        
                        keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.ipv4.$index.sequence_number \
                                [isisLearnedIpv4Multicast cget -sequenceNumber]
                        
                        keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.ipv4.$index.mcast_group_address \
                                [isisLearnedIpv4Multicast cget -ipv4MulticastGroupAddress]
                        
                        keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.ipv4.$index.age \
                                [isisLearnedIpv4Multicast cget -age]
                        
                        if {[isisLearnedIpv4Multicast getFirstUnicastSourceAddress] == 0} {
                            keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.ipv4.$index.ucast_source_address \
                                    [isisLearnedIpv4UnicastItem cget -ipv4UnicastSourceAddress]
                            
                            while {[isisLearnedIpv4Multicast getNextUnicastSourceAddress] == 0} {
                                keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.ipv4.$index.ucast_source_address \
                                        [concat [keylget returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.ipv4.$index.ucast_source_address] \
                                        [isisLearnedIpv4UnicastItem cget -ipv4UnicastSourceAddress]]
                            }
                        } else {
                            keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.ipv4.$index.ucast_source_address ""
                        }
                        set commandLearnedInfo getNextLearnedIpv4MulticastInfo
                        incr index
                    }
                    # IPv6 Multicast Learned Info
                    set commandLearnedInfo getFirstLearnedIpv6MulticastInfo
                    set index 0
                    while {[isisRouter $commandLearnedInfo] == 0} {
                        keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.ipv6.$index.lsp_id \
                                [isisLearnedIpv6Multicast cget -lspId]
                        
                        keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.ipv6.$index.sequence_number \
                                [isisLearnedIpv6Multicast cget -sequenceNumber]
                        
                        keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.ipv6.$index.mcast_group_address \
                                [isisLearnedIpv6Multicast cget -ipv6MulticastGroupAddress]
                        
                        keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.ipv6.$index.age \
                                [isisLearnedIpv6Multicast cget -age]
                        
                        if {[isisLearnedIpv6Multicast getFirstUnicastSourceAddress] == 0} {
                            keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.ipv6.$index.ucast_source_address \
                                    [isisLearnedIpv6UnicastItem cget -ipv6UnicastSourceAddress]
                            
                            while {[isisLearnedIpv6Multicast getNextUnicastSourceAddress] == 0} {
                                keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.ipv6.$index.ucast_source_address \
                                        [concat [keylget returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.ipv6.$index.ucast_source_address] \
                                        [isisLearnedIpv6UnicastItem cget -ipv6UnicastSourceAddress]]
                            }
                        } else {
                            keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.ipv6.$index.ucast_source_address ""
                        }
                        set commandLearnedInfo getNextLearnedIpv6MulticastInfo
                        incr index
                    }
                    
                    # MAC Multicast Learned Info
                    set commandLearnedInfo getFirstLearnedMacMulticastInfo
                    set index 0
                    while {[isisRouter $commandLearnedInfo] == 0} {
                        keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.mac.$index.lsp_id \
                                [isisLearnedMacMulticast cget -lspId]
                        
                        keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.mac.$index.sequence_number \
                                [isisLearnedMacMulticast cget -sequenceNumber]
                        
                        keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.mac.$index.mcast_group_address \
                                [isisLearnedMacMulticast cget -multicastGroupMacAddress]
                        
                        keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.mac.$index.age \
                                [isisLearnedMacMulticast cget -age]
                        
                        if {[isisLearnedMacMulticast getFirstUnicastSourceAddress] == 0} {
                            keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.mac.$index.ucast_source_address \
                                    [isisLearnedMacUnicastItem cget -unicastSourceMacAddress]
                            
                            while {[isisLearnedMacMulticast getNextUnicastSourceAddress] == 0} {
                                keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.mac.$index.ucast_source_address \
                                        [concat [keylget returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.mac.$index.ucast_source_address] \
                                        [isisLearnedMacUnicastItem cget -unicastSourceMacAddress]]
                            }
                        } else {
                            keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.mac.$index.ucast_source_address ""
                        }
                        set commandLearnedInfo getNextLearnedMacMulticastInfo
                        incr index
                    }
                    
                    # RBrige Learned Info
                    set commandLearnedInfo getFirstLearnedRbridgesInfo
                    set index 0
                    while {[isisRouter $commandLearnedInfo] == 0} {
                        if {[catch {keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.rbridges.$index.this           \
                                [isisLearnedRbridges cget -this]} ]} {
                            keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.rbridges.$index.this                 N/A
                        }
                        if {[catch {keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.rbridges.$index.system_id      \
                                [isisLearnedRbridges cget -systemId]} ]} {
                            keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.rbridges.$index.system_id            N/A
                        }
                        if {[catch {keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.rbridges.$index.ftag           \
                                [isisLearnedRbridges cget -primaryFtag]} ]} {
                            keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.rbridges.$index.ftag                 N/A
                        }
                        if {[catch {keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.rbridges.$index.role           \
                                [isisLearnedRbridges cget -role]} ]} {
                            keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.rbridges.$index.role                 N/A
                        }
                        if {[catch {keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.rbridges.$index.priority       \
                                [isisLearnedRbridges cget -priority]} ]} {
                            keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.rbridges.$index.priority             N/A
                        }
                        if {[catch {keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.rbridges.$index.age            \
                                [isisLearnedRbridges cget -age]} ]} {
                            keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.rbridges.$index.age                  N/A
                        }
                        if {[catch {keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.rbridges.$index.seq_number     \
                                [isisLearnedRbridges cget -sequenceNumber]} ]} {
                            keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.rbridges.$index.seq_number           N/A
                        }
                        if {[catch {keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.rbridges.$index.device_id      \
                                [isisLearnedRbridges cget -switchId]} ]} {
                            keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.rbridges.$index.device_id            N/A
                        }
                        if {[catch {keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.rbridges.$index.graph_id       \
                                [isisLearnedRbridges cget -graphId]} ]} {
                            keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.rbridges.$index.graph_id             N/A
                        }
                        if {[catch {keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.rbridges.$index.secondary_ftag \
                                [isisLearnedRbridges cget -secondaryFtag]} ]} {
                            keylset returnList $sessionHandle.dce_isis_draft_ward_l2_isis_04.rbridges.$index.secondary_ftag       N/A
                        }
                        
                        
                        set commandLearnedInfo getNextLearnedRbridgesInfo
                        incr index
                    }
                }
            }
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}
