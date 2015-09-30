##Library Header
# $Id: $
# Copyright © 2003-2009 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_ldp_api.tcl
#
# Purpose:
#    A script development library containing LDP APIs for test automation
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
#    - emulation_ldp_config
#    - emulation_ldp_route_config
#    - emulation_ldp_control
#    - emulation_ldp_info
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

proc ::ixia::emulation_ldp_config { args } {
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
                \{::ixia::emulation_ldp_config $args\}]
        
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
    
    set man_args {
        -mode        CHOICES create delete disable enable modify
        -port_handle REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
    }

    set opt_args {
        -handle
        -label_adv                      CHOICES unsolicited on_demand
                                        DEFAULT unsolicited
        -peer_discovery                 CHOICES link targeted targeted_martini
                                        DEFAULT link
        -count                          NUMERIC
                                        DEFAULT 1
        -interface_handle
        -interface_mode                 CHOICES add modify
                                        DEFAULT modify
        -intf_ip_addr                   IPV4
                                        DEFAULT 0.0.0.0
        -intf_prefix_length             RANGE   1-32
                                        DEFAULT 24
        -intf_ip_addr_step              IPV4
                                        DEFAULT 0.0.1.0
        -loopback_ip_addr               IPV4
        -loopback_ip_addr_step          IPV4
                                        DEFAULT 0.0.1.0
        -lsr_id                         IPV4
        -label_space                    RANGE   0-65535
        -lsr_id_step                    IPV4
                                        DEFAULT 0.0.1.0
        -mac_address_init               MAC
        -mac_address_step               MAC
                                        DEFAULT 0000.0000.0001
        -remote_ip_addr                 IPV4
        -remote_ip_addr_step            IPV4
        -hello_interval                 RANGE   0-65535
        -hello_hold_time                RANGE   0-65535
        -keepalive_interval             RANGE   0-65535
        -keepalive_holdtime             RANGE   0-65535
        -discard_self_adv_fecs          CHOICES 0 1
        -vlan                           CHOICES 0 1
        -vlan_id                        RANGE   0-4095
        -vlan_id_mode                   CHOICES fixed increment
                                        DEFAULT increment
        -vlan_id_step                   RANGE   0-4096
                                        DEFAULT 1
        -vlan_user_priority             RANGE   0-7
                                        DEFAULT 0
        -vpi                            RANGE   0-255
                                        DEFAULT 1
        -vci                            RANGE   0-65535
                                        DEFAULT 10
        -vpi_step                       RANGE   0-255
                                        DEFAULT 1
        -vci_step                       RANGE   0-65535
                                        DEFAULT 1
        -atm_encapsulation              CHOICES VccMuxIPV4Routed VccMuxIPV6Routed VccMuxBridgedEthernetFCS VccMuxBridgedEthernetNoFCS LLCRoutedCLIP LLCBridgedEthernetFCS LLCBridgedEthernetNoFCS
        -auth_mode                      CHOICES null md5
                                        DEFAULT null
        -auth_key                       ANY
        -bfd_registration               CHOICES 0 1
                                        DEFAULT 0
        -bfd_registration_mode          CHOICES single_hop multi_hop
                                        DEFAULT multi_hop
        -atm_range_max_vpi              RANGE   0-255
        -atm_range_min_vpi              RANGE   0-255
        -atm_range_max_vci              RANGE   33-65535
        -atm_range_min_vci              RANGE   33-65535
        -atm_vc_dir                     CHOICES bi_dir uni_dir
                                        DEFAULT bi_dir
        -enable_explicit_include_ip_fec CHOICES 0 1
        -enable_l2vpn_vc_fecs           CHOICES 0 1
        -enable_remote_connect          CHOICES 0 1
        -enable_vc_group_matching       CHOICES 0 1
        -gateway_ip_addr                IPV4
        -gateway_ip_addr_step           IPV4 
                                        DEFAULT 0.0.1.0
        -graceful_restart_enable        CHOICES 0 1
        -no_write                       FLAG
        -reconnect_time                 RANGE 0-300000
        -recovery_time                  RANGE 0-300000
        -reset                          FLAG
        -targeted_hello_hold_time       RANGE   0-65535
        -targeted_hello_interval        RANGE   0-65535
        -override_existence_check       CHOICES 0 1 
                                        DEFAULT 0
        -override_tracking              CHOICES 0 1 
                                        DEFAULT 0
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_ldp_config $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        return $returnList
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args

    set port_list [format_space_port_list $port_handle]
    set interface [lindex $port_list 0]
    # Set chassis card port
    foreach {chasNum cardNum portNum} $interface {}
    ::ixia::addPortToWrite $chasNum/$cardNum/$portNum
    
    # Check if LDP package has been installed on the port
    if {[catch {ldpServer select $chasNum $cardNum $portNum} error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The LDP protocol\
                has not been installed on port or is not supported on port: \
                $chasNum/$cardNum/$portNum."
        return $returnList
    }
    
    if {($mode == "delete") || ($mode == "enable") || ($mode == "disable")} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When -mode is $mode,\
                    the -handle option must be used.  Please set this value."
            return $returnList
        }

        set return_status [::ixia::actionLdp $chasNum $cardNum $portNum \
                $mode $handle]
        if {[keylget return_status status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: [keylget return_status \
                    log]"
            return $returnList
        }

        if {$mode == "delete"} {
            updateLdpHandleArray delete $port_handle $handle
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
        keylset returnList status $::SUCCESS
        return $returnList
    }
    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
        
        if {![info exists interface_mode]} {
            set interface_mode modify
        }
        
        # Only allow the modification of one item at a time, so artificially
        # control this.
        set count 1
        
    }
    
    # Assumption is that we are now in a create or modify mode only from this
    # point on.

    array set ldpServerArray [list                                  \
            discard_self_adv_fecs    enableDiscardSelfAdvertiseFecs \
            hello_hold_time          helloHoldTime                  \
            hello_interval           helloInterval                  \
            keepalive_holdtime       keepAliveHoldTime              \
            keepalive_interval       keepAliveInterval              \
            targeted_hello_hold_time targetedHoldTime               \
            targeted_hello_interval  targetedHelloInterval          \
            ]

    array set ldpTargetedPeerArray [list \
            remote_ip_addr ipAddress     \
            ]
    array set ldpRouterArray [list                                    \
            enable_explicit_include_ip_fec enableExplicitIncludeIpFec \
            enable_l2vpn_vc_fecs           enableL2VpnVcFecs          \
            enable_remote_connect          enableRemoteConnect        \
            enable_vc_group_matching       enableVcGroupMatching      \
            lsr_id                         routerId                   \
            graceful_restart_enable        enableGracefulRestart      \
            recovery_time                  recoveryTime               \
            reconnect_time                 reconnectTime              \
            ]

    array set ldpAtmLabelRangeArray [list \
            atm_range_max_vci maxVci \
            atm_range_max_vpi maxVpi \
            atm_range_min_vci minVci \
            atm_range_min_vpi minVpi \
            ]

    array set ldpInterfaceArray [list                    \
            auth_mode              authenticationType    \
            auth_key               md5Key                \
            label_adv              advertisingMode       \
            atm_vc_dir             atmVcDirection        \
            peer_discovery         discoveryMode         \
            label_space            labelSpaceId          \
            bfd_registration       enableBfdRegistration \
            bfd_registration_mode  bfdOperationMode      \
            ]

    # This setup is to protect against older IxOS versions that may not
    # contain a particular enum designation.
    set dataset [list                                          \
            unsolicited      ldpInterfaceDownstreamUnsolicited \
            on_demand        ldpInterfaceDownstreamOnDemand    \
            link             ldpInterfaceBasic                 \
            targeted         ldpInterfaceExtended              \
            targeted_martini ldpInterfaceExtendedMartini       \
            bi_dir           atmVcBidirectional                \
            uni_dir          atmVcUnidirectional               \
            ]
    
    foreach {dataName enumName} $dataset {
        if {[info exists ::$enumName]} {
            set enumList($dataName) [set ::$enumName]
        }
    }
    set enumList(single_hop) 0
    set enumList(multi_hop)  1
    # auth_mode - authenticationType
    set enumList(null) 0
    set enumList(md5)  1

    if {($mode == "create" || $mode == "modify") && [info exists intf_ip_addr]} {
        # Handle the protocol interface creation
        if {![info exists vlan] && [info exists vlan_id]} {
            set vlan $::true
        }
        
        if {![info exists gateway_ip_addr]} {
            if {[info exists remote_ip_addr]} {
                set gateway_ip_addr $remote_ip_addr
                if {[info exists remote_ip_addr_step]} {
                    set gateway_ip_addr_step $remote_ip_addr_step
                }
            } else  {
                set gateway_ip_addr 0.0.0.0
            }
        }
        
        set ip_version  4
        set config_options \
                "-port_handle             port_handle           \
                -count                    count                 \
                -ip_address               intf_ip_addr          \
                -ip_address_step          intf_ip_addr_step     \
                -gateway_ip_address       gateway_ip_addr       \
                -gateway_ip_address_step  gateway_ip_addr_step  \
                -loopback_ip_address      loopback_ip_addr      \
                -loopback_ip_address_step loopback_ip_addr_step \
                -ip_version               ip_version            \
                -mac_address              mac_address_init      \
                -netmask                  intf_prefix_length    \
                -vlan_id                  vlan_id               \
                -vlan_id_mode             vlan_id_mode          \
                -vlan_id_step             vlan_id_step          \
                -vlan_user_priority       vlan_user_priority    \
                -atm_vpi                  vpi                   \
                -atm_vpi_step             vpi_step              \
                -atm_vci                  vci                   \
                -atm_vci_step             vci_step              \
                -no_write                 no_write              "

        ## passed in only those options that exists
        set config_param ""
        foreach {option value_name} $config_options {
            if {[info exists $value_name]} {
                append config_param "$option [set $value_name] "
            }
        }

        set intf_status [eval ixia::protocol_interface_config \
                $config_param]
        
        if {[keylget intf_status status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName:\
                    [keylget intf_status log]"
            return $returnList
        }

        set description_list [keylget intf_status description]
        
        if {[info exists loopback_ip_addr]} {
            set description_list [keylget intf_status loopback_description]
        }
        
        if {$mode == "create"} {
            if {![info exists lsr_id]} {
                set lsr_id $intf_ip_addr
            }        
    
            if {![info exists router_id]} {
                set router_id $intf_ip_addr
            }
        }
    }

    # Select the LDP server
    set retCode [ldpServer select $chasNum $cardNum $portNum]
    if {$retCode != 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failure on call to\
                ldpServer select $chasNum $cardNum $portNum.  Return code\
                was $retCode."
        return $returnList
    }
    
    if {[info exists reset]} {
        ldpServer clearAllRouters
        ::ixia::updateLdpHandleArray reset $port_handle
    }
    
    for {set j 1} {$j <= $count} {incr j} {
        if {$mode == "create"} {
            # Get next ldp peer on the Ixia interface
            set next_ldp_router [get_next_router_number ldp \
                    "$chasNum $cardNum $portNum"]

            ldpServer        setDefault
            ldpRouter        setDefault
            ldpInterface     setDefault
            ldpTargetedPeer  setDefault
            catch {ldpAtmLabelRange setDefault}

            ldpRouter clearAllInterfaces
            ldpRouter clearAllAdvertiseFecRanges
            ldpRouter clearAllExplicitIncludeIpFecs
            ldpRouter clearAllL2VpnInterfaces
            catch {ldpRouter clearAllRequestFecRanges}

            if {[llength $description_list] >= $j} {
                ldpInterface config -protocolInterfaceDescription \
                        [lindex $description_list [expr $j - 1]]
            } elseif {[llength $description_list] == 1} {
                ldpInterface config -protocolInterfaceDescription \
                        $description_list
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The protocol\
                        interface table setup did not return the proper\
                        descriptions to be used.  Please check setup."
                return $returnList
            }

            # The user needs to explicitly turn these flags on, so default false
            ldpServer config -enableDiscardSelfAdvertiseFecs false

            ldpRouter config -enableExplicitIncludeIpFec false
            ldpRouter config -enableL2VpnVcFecs          false
            ldpRouter config -enableRemoteConnect        true
            ldpRouter config -enableVcGroupMatching      false

        } else {
            # mode is modify
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: -handle should be \
                        specified in modify mode."
                return $returnList
            }
            set next_ldp_router $handle
            ldpRouter setDefault
            if {[ldpServer getRouter $next_ldp_router]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failure on call\
                        to ldpServer getRouter $next_ldp_router.  Please\
                        check that this router exists."
                return $returnList
            }
            ldpInterface     setDefault
            ldpTargetedPeer  setDefault
            catch {ldpAtmLabelRange setDefault}
        }

        # Set up items in the ldpServer command
        foreach {item itemName} [array get ldpServerArray] {
            if {![catch {set $item} value]} {
                if {[lsearch [array names enumList] $value] != -1} {
                    set value $enumList($value)
                }
                catch {ldpServer config -$itemName $value}
            }
        }

        # Set up items in the ldpAtmLabelRange command
        foreach {item itemName} [array get ldpAtmLabelRangeArray] {
            if {![catch {set $item} value]} {
                if {[lsearch [array names enumList] $value] != -1} {
                    set value $enumList($value)
                }
                catch {ldpAtmLabelRange config -$itemName $value}
            }
        }

        if {$mode == "modify"} {
            set value 1
            if {[ldpInterface getFirstAtmLabelRange]} {
                set atmRangeName atmRange$value
            } else {
                while {![ldpInterface getNextAtmLabelRange]} {
                    incr value
                }
                incr value
                set atmRangeName atmRange$value
            }
        } else {
            set atmRangeName atmRange1
        }

        # Add this atm range to the interface
        if {![catch {ldpInterface addAtmLabelRange $atmRangeName} retCode]} {
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failure in call to\
                        ldpInterface addAtmLabelRange atmRange1.  Failed to add\
                        the atm label range.  Return code was $retCode."
                return $returnList
            }
        }

        # Set up items in the ldpTargetedPeer command
        if {[info exists remote_ip_addr]} {
            set counter 1
            if {[ldpInterface getFirstTargetedPeer]} {
                set counter 1
            } else {
                while {![ldpInterface getNextAtmLabelRange]} {
                    incr counter
                }
                incr counter
            }

            foreach addr $remote_ip_addr {
                ldpTargetedPeer setDefault
                ldpTargetedPeer config -enable    true
                ldpTargetedPeer config -ipAddress $addr
                if {[ldpInterface addTargetedPeer targetedPeer$counter]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failure on\
                            call to ldpInterface addTargetedPeer\
                            targetedPeer$counter.  IP address was $addr."
                    return $returnList
                }
                incr counter
            }
        }
        
        if {$mode == "modify"} {
            set intfNum 1
            if {[ldpRouter getFirstInterface]} {
                set intfNum 1
            } else {
                while {![ldpRouter getNextInterface]} {
                    incr intfNum
                }
                incr intfNum
            }
        } else {
            set intfNum 1
        }
        
        # Set up items in the ldpInterface command
        foreach {item itemName} [array get ldpInterfaceArray] {
            if {![catch {set $item} value]} {
                if {[lsearch [array names enumList] $value] != -1} {
                    set value $enumList($value)
                }
                catch {ldpInterface config -$itemName $value}
            }
        }
        if {[info exists description_list]} {
            if {[llength $description_list] >= $j} {
                ldpInterface config -protocolInterfaceDescription \
                        [lindex $description_list [expr $j - 1]]
            } elseif {[llength $description_list] == 1} {
                ldpInterface config -protocolInterfaceDescription \
                        $description_list
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The protocol\
                        interface table setup did not return the proper\
                        descriptions to be used.  Please check setup."
                return $returnList
            }
        }
        ldpInterface config -enable true
        
        if {$mode == "create" || ($mode =="modify" && $interface_mode == "add")} {
            set retCode [ldpRouter addInterface interface$intfNum]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failure in call to\
                        ldpRouter addInterface interface1.  Return code: $retCode."
                return $returnList
            }
        } else {
            set retCode [ldpRouter setInterface interface[expr $intfNum - 1]]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failure in call to\
                        ldpRouter addInterface interface1.  Return code: $retCode."
                return $returnList
            }
        }

        # Set up items in the ldpRouter command
        foreach {item itemName} [array get ldpRouterArray] {
            if {![catch {set $item} value]} {
                if {[lsearch [array names enumList] $value] != -1} {
                    set value $enumList($value)
                }
                catch {ldpRouter config -$itemName $value}
            }
        }
        ldpRouter config -enable true

        if {$mode == "create"} {
            if {[ldpServer addRouter $next_ldp_router]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failure in call to\
                        ldpServer addRouter $next_ldp_router."
                return $returnList
            }
        } elseif {$mode == "modify"} {
            if {[ldpServer setRouter $next_ldp_router]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failure in call to\
                        ldpServer setRouter $next_ldp_router."
                return $returnList
            }
        }

        if {[ldpServer set]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failure in call to\
                    ldpServer set."
            return $returnList
        }
        if {[info exists lsr_id] && [info exists lsr_id_step]} {
            set lsr_id [increment_ipv4_address_hltapi $lsr_id $lsr_id_step]
        }
        lappend ldp_neighbor_list $next_ldp_router
    }

    # Enable LDP on the interface
    set retCode [protocolServer get $chasNum $cardNum $portNum]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failure in call to\
                protocolServer get $chasNum $cardNum $portNum.  Return code\
                was $retCode."
        return $returnList
    }
    protocolServer config -enableLdpService true
    set retCode [protocolServer set $chasNum $cardNum $portNum]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failure in call to\
                protocolServer set $chasNum $cardNum $portNum.  Return code\
                was $retCode."
        return $returnList
    }
    
    stat config -enableLdpStats 1
    set retCode [stat set $chasNum $cardNum $portNum]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failure in call to\
                stat set $chasNum $cardNum $portNum.  Return code\
                was $retCode."
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
    
    foreach routerId $ldp_neighbor_list {
        updateLdpHandleArray create $port_handle $routerId
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList handle $ldp_neighbor_list
    return $returnList
}


proc ::ixia::emulation_ldp_route_config { args } {
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
                \{::ixia::emulation_ldp_route_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    variable new_ixnetwork_api
    variable ldp_handles_array
    keylset returnList status $::SUCCESS
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set man_args {
        -mode                       CHOICES create modify delete
        -handle
    }

    set opt_args {
        -egress_label_mode               CHOICES nextlabel fixed imnull exnull
                                         DEFAULT nextlabel
        -fec_ip_prefix_start             IPV4
                                         DEFAULT 0.0.0.0
        -fec_ip_prefix_length            RANGE 1-32
                                         DEFAULT 24
        -fec_host_addr                   IP
                                         DEFAULT 0.0.0.0
        -fec_host_prefix_length          RANGE 1-32
                                         DEFAULT 24
        -fec_type                        CHOICES ipv4_prefix host_addr vc
                                         DEFAULT ipv4_prefix
        -fec_vc_atm_enable               CHOICES 0 1 
                                         DEFAULT 1
        -fec_vc_atm_max_cells            RANGE 1-65535 
                                         DEFAULT 1
        -fec_vc_cbit                     CHOICES 0 1
                                         DEFAULT 1
        -fec_vc_ce_ip_addr               IP 
                                         DEFAULT 0.0.0.0
        -fec_vc_ce_ip_addr_inner_step    IP 
                                         DEFAULT 0.0.0.1
        -fec_vc_ce_ip_addr_outer_step    IP 
                                         DEFAULT 0.0.0.0
        -fec_vc_cem_option               RANGE 0-65535 
                                         DEFAULT 0
        -fec_vc_cem_option_enable        CHOICES 0 1 
                                         DEFAULT 0
        -fec_vc_cem_payload              RANGE 48-1023 
                                         DEFAULT 48
        -fec_vc_cem_payload_enable       CHOICES 0 1 
                                         DEFAULT 1
        -fec_vc_count                    NUMERIC
                                         DEFAULT 1
        -fec_vc_fec_type                 CHOICES generalized_id_fec_vpls pw_id_fec
                                         DEFAULT generalized_id_fec_vpls
        -fec_vc_group_id                 RANGE 0-2147483647
        -fec_vc_group_count              RANGE 0-4294967295 
                                         DEFAULT 1
        -fec_vc_id_start                 RANGE 0-2147483647
                                         DEFAULT 1
        -fec_vc_id_step                  RANGE 0-2147483647
                                         DEFAULT 1
        -fec_vc_id_count                 RANGE 0-2147483647
                                         DEFAULT 1
        -fec_vc_intf_mtu_enable          CHOICES 0 1
                                         DEFAULT 1
        -fec_vc_intf_mtu                 RANGE 0-65535
                                         DEFAULT 0
        -fec_vc_intf_desc
        -fec_vc_ip_range_addr_count      RANGE 0-4294967295 
                                         DEFAULT 10
        -fec_vc_ip_range_addr_start      IP 
                                         DEFAULT 0.0.0.0
        -fec_vc_ip_range_addr_inner_step IP 
                                         DEFAULT 0.0.0.1
        -fec_vc_ip_range_addr_outer_step IP 
                                         DEFAULT 0.0.1.0
        -fec_vc_ip_range_enable          CHOICES 0 1 
                                         DEFAULT 0
        -fec_vc_ip_range_prefix_len      RANGE 0-32 
                                         DEFAULT 24
        -fec_vc_label_mode               CHOICES fixed_label increment_label
                                         DEFAULT increment_label
        -fec_vc_label_value_start        RANGE 0-1046400 
                                         DEFAULT 16
        -fec_vc_label_value_step         RANGE 0-1046400 
                                         DEFAULT 0
        -fec_vc_mac_range_count          RANGE 0-4294967295 
                                         DEFAULT 1
        -fec_vc_mac_range_enable         CHOICES 0 1 
                                         DEFAULT 0
        -fec_vc_mac_range_first_vlan_id  RANGE 1-4095 
                                         DEFAULT 100
        -fec_vc_mac_range_repeat_mac     CHOICES 0 1 
                                         DEFAULT 1
        -fec_vc_mac_range_same_vlan      CHOICES 0 1 
                                         DEFAULT 1
        -fec_vc_mac_range_start          MAC 
                                         DEFAULT 0000.0000.000
        -fec_vc_mac_range_vlan_enable    CHOICES 0 1 
                                         DEFAULT 1
        -fec_vc_peer_address             IP
                                         DEFAULT 0.0.0.0
        -fec_vc_type                     CHOICES atm_aal5_vcc
                                         CHOICES atm_cell
                                         CHOICES atm_vcc_1_1
                                         CHOICES atm_vcc_n_1
                                         CHOICES atm_vpc_1_1
                                         CHOICES atm_vpc_n_1
                                         CHOICES cem
                                         CHOICES eth
                                         CHOICES eth_vlan
                                         CHOICES eth_vpls
                                         CHOICES fr_dlci
                                         CHOICES hdlc
                                         CHOICES ppp
                                         CHOICES fr_dlci_rfc4619
                                         DEFAULT eth_vlan
        -hop_count_tlv_enable            CHOICES 0 1
                                         DEFAULT 1
        -hop_count_value                 RANGE 1-255
                                         DEFAULT 1
        -label_msg_type                  CHOICES mapping request
                                         DEFAULT mapping
        -label_value_start               RANGE 0-1048575 
                                         DEFAULT 16
        -lsp_handle
        -next_hop_peer_ip                IP
                                         DEFAULT 0.0.0.0
        -num_lsps                        RANGE 1-34048
                                         DEFAULT 1
        -num_routes                      RANGE 1-16777216
                                         DEFAULT 1
        -packing_enable                  CHOICES 0 1
                                         DEFAULT 0
        -provisioning_model              CHOICES bgp_auto_discovery manual_configuration
        -stale_timer_enable              CHOICES 0 1
                                         DEFAULT 1
        -stale_request_time              RANGE 1-65535
                                         DEFAULT 300
        -no_write                        FLAG
    }
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_ldp_route_config $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        return $returnList
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args

    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
    }

    if {[array names ldp_handles_array $handle,session] == ""} {
        keylset returnList log "$procName: cannot find the session handle \
                                $handle in the ldp_handles_array"
        keylset returnList status $::FAILURE
        return $returnList
    }
    set port_handle [lindex $ldp_handles_array($handle,session) 0]
    scan $port_handle "%d/%d/%d" chasNum cardNum portNum
    set port_list [list [list $chasNum $cardNum $portNum]]
    ::ixia::addPortToWrite $chasNum/$cardNum/$portNum
    
    # Check if LDP package has been installed on the port
    if {[catch {ldpServer select $chasNum $cardNum $portNum} error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The LDP protocol\
                has not been installed on port or is not supported on port: \
                $chasNum/$cardNum/$portNum."
        return $returnList
    }
    
    #### error checking - check for incompatible options or missing options
    switch $mode {
        create {
            switch $fec_type {
                ipv4_prefix {
                    if {$label_msg_type == "request"} {
                        keylset returnList log "ERROR in $procName:\
                                if fec_type is ipv4_prefix, the\
                                label_msg_type must be mapping."
                        keylset returnList status $::FAILURE
                        return $returnList
                    }
                }
    
                host_addr {
                    if {$label_msg_type == "mapping"} {
                        keylset returnList log "ERROR in $procName:\
                                if fec_type is host_addr, the\
                                label_msg_type must be request."
                        keylset returnList status $::FAILURE
                        return $returnList
                    }
                }
            }
        }
        modify -
        delete {
            if {![info exists lsp_handle]} {
                keylset returnList log "ERROR in $procName: lsp_handle is\
                        missing. Cannot perform modify or delete."
                keylset returnList status $::FAILURE
                return $returnList
            }
        }
    }

    create_ldp_route_array
    
    set serverCommand ldpServer
    set routerCommand ldpRouter

    if {[$serverCommand select $chasNum $cardNum $portNum]} {
        keylset returnList log "$serverCommand select on port\
                $chasNum $cardNum $portNum failed."
        keylset returnList status $::FAILURE
        return $returnList
    }
    if {[$serverCommand getRouter $handle]} {
        keylset returnList log "ERROR in $procName:\
                $serverCommand getRouter $handle command failed.\
                \n$::ixErrorInfo"
        keylset returnList status $::FAILURE
        return $returnList
    }

    switch $mode {
        create {
            set lsp_handle [createLdpRouteObject $handle $port_handle $opt_args]
        }
        modify {
            set lsp_handle [modifyLdpRouteObject $args]
        }
        delete {
            set lsp_handle [deleteLdpRouteObject $handle $lsp_handle]
        }
    }
    if {$lsp_handle == "NULL"} {
       if {![info exists fec_type]} {
            set fec_type ""
       }

       keylset returnList log "ERROR in $procName: Failed to $mode $fec_type\
               route on port $chasNum $cardNum $portNum.\n$::ixErrorInfo"
       keylset returnList status $::FAILURE
       return $returnList
    }

    if {[$serverCommand set]} {
        keylset returnList log "ERROR in $procName:\
                $serverCommand set command failed.\n$::ixErrorInfo"
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
    cleanup_ldp_route_arrays

    keylset returnList lsp_handle $lsp_handle
    return $returnList
}


proc ::ixia::emulation_ldp_control { args } {
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
                \{::ixia::emulation_ldp_control $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    variable new_ixnetwork_api
    variable ldp_handles_array
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set man_args {
        -mode        CHOICES restart start stop
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
        set returnList [::ixia::ixnetwork_ldp_control $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        keylset returnList clicks [format "%u" $retValueClicks]
        keylset returnList seconds [format "%u" $retValueSeconds]
        return $returnList
    }

    ::ixia::parse_dashed_args -args $args -mandatory_args $man_args \
            -optional_args $opt_args

    # Find out which ports to act upon.
    set port_list {}
    if {[info exists port_handle]} {
        set port_list [format_space_port_list $port_handle]
    } elseif {[info exists handle]} {
        if {[array names ldp_handles_array $handle,session] == ""} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Cannot find the session\
                    handle $handle in the internal ldp_handles_array."
            return $returnList
        }
        set port_handle [lindex $ldp_handles_array($handle,session) 0]
        set port_list [format_space_port_list $port_handle]
    } else  {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: You must provide\
                -port_handle or -handle arguments."
        return $returnList
    }
    
    # Check if LDP package has been installed on the port
    foreach port_i $port_list {
        foreach {chs_i crd_i prt_i} $port_i {}
        if {[catch {ldpServer select $chs_i $crd_i $prt_i } error]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: The LDP protocol\
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
            if {[ixStopLdp port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error stopping\
                        LDP on the port list $port_list."
                return $returnList
            }
            if {[ixStartLdp port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error starting\
                        LDP on the port list $port_list."
                return $returnList
            }
        }
        start {
            if {[ixStartLdp port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error starting\
                        LDP on the port list $port_list."
                return $returnList
            }
        }
        stop {
            if {[ixStopLdp port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error stopping\
                        LDP on the port list $port_list."
                return $returnList
            }
        }
        default {
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::emulation_ldp_info { args } {
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
                \{::ixia::emulation_ldp_info $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    variable new_ixnetwork_api
    variable ldp_handles_array
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set man_args {
        -mode        CHOICES state  stats  clear_stats  settings
                     CHOICES neighbors  lsp_labels
        -handle
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_ldp_info $args $man_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        return $returnList
    }

    ::ixia::parse_dashed_args -args $args -mandatory_args $man_args

    if {![info exists ldp_handles_array($handle,session)]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                Invalid session handle $handle."
        return $returnList
    }
    set port_handle [lindex $ldp_handles_array($handle,session) 0]
    foreach {chassis card port} [split $port_handle /] {}
    
    # Check if LDP package has been installed on the port
    if {[catch {ldpServer select $chassis $card $port} retCode]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The LDP protocol\
                has not been installed on port or is not supported on port: \
                $chassis/$card/$port."
        return $returnList
    }
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Call to\
                ldpServer select $chassis $card $port failed. \
                Return code was $retCode."
        return $returnList
    }
    
    # MODE STATE
    if {$mode == "state"} {
        # NOT SUPPORTED
    }
    
    # MODE STATS
    if {$mode == "stats"} {
        statGroup setDefault
        statGroup add $chassis $card $port
        if {[statGroup get]} {
            keylset returnList log "ERROR in $procName: Failed to\
                    statGroup get $chassis $card $port."
            keylset returnList status $::FAILURE
            return $returnList
        }
        statList setDefault
        if {[statList get $chassis $card $port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to\
                    stat get allStats $chassis $card $port."
            return $returnList
        }
        array set ldpStatList [list \
                ldpBasicSessionsUp     basic_sessions               \
                ldpSessionsConfigured  targeted_sessions_configured \
                ldpSessionsUp          targeted_sessions_running    ]
        
        foreach {ldpStat ldpKey} [array get ldpStatList] {
            if {[catch {statList cget -$ldpStat} retValue] } {
                keylset returnList $ldpKey "N/A"
            } else  {
                keylset returnList $ldpKey $retValue
            }
        }
    }
    
    # MODE CLEAR_STATS
    if {$mode == "clear_stats"} {
        # Reseting all the stats for the selected port
        set clearPortList [list $chassis,$card,$port]
        if {[ixClearStats clearPortList]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to\
                    ixClearStats $clearPortList."
            return $returnList
        }
    }
    
    # MODE SETTINGS
    if {$mode == "settings"} {
        set retCode [ldpServer getRouter $handle]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ldpServer getRouter $handle failed. \
                    Return code was $retCode."
            return $returnList
        }
        
        set retCode [ldpRouter getFirstInterface]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ldpRouter getFirstInterface failed. \
                    Return code was $retCode."
            return $returnList
        }
        # KEY: intf_ip_addr
        # KEY: ip_address
        set description [ldpInterface cget -protocolInterfaceDescription ]
        set retCode [::ixia::get_interface_parameter \
                -port_handle $port_handle \
                -description $description \
                -parameter   ipv4_address ]
        
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget retCode log]."
            return $returnList
        }
        
        set retValue [keylget retCode ipv4_address]
        if {$retValue == ""} {
            keylset returnList intf_ip_addr N/A
            keylset returnList ip_address   N/A
        } else  {
            keylset returnList intf_ip_addr $retValue
            keylset returnList ip_address   $retValue
        }
        
        # KEY: label_adv
        array set label_adv   [list                                \
                $::ldpInterfaceDownstreamUnsolicited unsolicited   \
                $::ldpInterfaceDownstreamOnDemand    on_demand     \
                ]
        keylset returnList label_adv $label_adv([ldpInterface cget \
                -advertisingMode])
        
        # KEY: hold_time
        keylset returnList hold_time       [ldpServer cget \
                -targetedHoldTime]
        
        # KEY: hello_hold_time
        keylset returnList hello_hold_time [ldpServer cget \
                -targetedHoldTime]
        
        # KEY: hello_interval
        keylset returnList hello_interval  [ldpServer cget \
                -targetedHelloInterval]
        
        # KEY: targeted_hello
        keylset returnList targeted_hello [ldpServer cget \
                -targetedHelloInterval]
        
        # KEY: keepalive_holdtime
        keylset returnList keepalive_holdtime  [ldpServer cget \
                -keepAliveHoldTime]
        
        # KEY: keepalive_interval
        keylset returnList keepalive_interval  [ldpServer cget \
                -keepAliveInterval]
        
        # KEY: keepalive
        keylset returnList keepalive           [ldpServer cget \
                -keepAliveInterval]
        
        # KEY: label_space
        keylset returnList label_space      [ldpInterface cget \
                -labelSpaceId]
        
        # KEY: vpi
        set retCode [::ixia::get_interface_parameter \
                -port_handle $port_handle \
                -description $description \
                -parameter   atm_vpi ]
        
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget retCode log]."
            return $returnList
        }
        
        set retValue [keylget retCode atm_vpi]
        if {$retValue == ""} {
            keylset returnList vpi N/A
        } else  {
            keylset returnList vpi $retValue
        }
        
        # KEY: vci
        set retCode [::ixia::get_interface_parameter \
                -port_handle $port_handle \
                -description $description \
                -parameter   atm_vci ]
        
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget retCode log]."
            return $returnList
        }
        
        set retValue [keylget retCode atm_vci]
        if {$retValue == ""} {
            keylset returnList vci N/A
        } else  {
            keylset returnList vci $retValue
        }
        # KEY: atm_range_max_vpi atm_range_max_vci
        # KEY: atm_range_min_vpi atm_range_min_vci
        set atm_range_max_vpi ""
        set atm_range_max_vci ""
        set atm_range_min_vpi ""
        set atm_range_min_vci ""
        if {![ldpInterface getFirstAtmLabelRange]} {
            lappend atm_range_max_vpi [ldpAtmLabelRange cget  -maxVpi]
            lappend atm_range_max_vci [ldpAtmLabelRange cget  -maxVci]
            lappend atm_range_min_vpi [ldpAtmLabelRange cget  -minVpi]
            lappend atm_range_min_vci [ldpAtmLabelRange cget  -minVci]
            while {![ldpInterface getNextAtmLabelRange]} {
                lappend atm_range_max_vpi [ldpAtmLabelRange cget  -maxVpi]
                lappend atm_range_max_vci [ldpAtmLabelRange cget  -maxVci]
                lappend atm_range_min_vpi [ldpAtmLabelRange cget  -minVpi]
                lappend atm_range_min_vci [ldpAtmLabelRange cget  -minVci]
                
            }
            keylset returnList atm_range_max_vpi $atm_range_max_vpi
            keylset returnList atm_range_max_vci $atm_range_max_vci
            keylset returnList atm_range_min_vpi $atm_range_min_vpi
            keylset returnList atm_range_min_vci $atm_range_min_vci
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
    
    # MODE NEIGHBORS
    if {$mode == "neighbors"} {
        set retCode [ldpServer getRouter $handle]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ldpServer getRouter $handle failed. \
                    Return code was $retCode."
            return $returnList
        }
        
        # When router is disabled return
        if {![ldpRouter cget -enable]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: LDP session handle\
                    $handle is not enabled."
            return $returnList
        }
        
        set source_list        ""
        set interfaceRetCode [ldpRouter getFirstInterface]
        
        if {$interfaceRetCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: LDP session handle\
                    $handle does not have any interfaces configured."
            return $returnList
        }
        
        while {$interfaceRetCode == 0} {
            ldpInterface requestLearnedLabels
            set requestResult [ldpInterface getLearnedLabelList]
            for {set i 0} {($requestResult != 0) && ($i < 5)} {incr i} {
                after 3000
                set requestResult [ldpInterface getLearnedLabelList]
            }
            # LEARNED IPv4 LABELS
            if {$requestResult == 0} {
                set labelRetCode [ldpInterface getFirstLearnedIpV4Label]
                while {$labelRetCode == 0} {
                    lappend source_list        [ldpLearnedIpV4Label cget \
                            -peerIpAddress   ]
                    
                    set labelRetCode [ldpInterface getNextLearnedIpV4Label]
                }
            }
            # LEARNED IPv4 ATM LABELS
            if {$requestResult == 0} {
                set labelRetCode [ldpInterface getFirstLearnedIpV4AtmLabel]
                while {$labelRetCode == 0} {
                    lappend source_list        [ldpLearnedIpV4AtmLabel cget \
                            -peerIpAddress   ]
                    
                    set labelRetCode [ldpInterface getNextLearnedIpV4AtmLabel]
                }
            }
            # ASSIGNED ATM LABELS
            if {$requestResult == 0} {
                set labelRetCode [ldpInterface getFirstAssignedAtmLabel]
                while {$labelRetCode == 0} {
                    lappend source_list        [ldpAssignedAtmLabel cget \
                            -peerIpAddress   ]
                    
                    set labelRetCode [ldpInterface getNextAssignedAtmLabel]
                }
            }
            # LEARNED MARTINI LABELS
            if {$requestResult == 0} {
                set labelRetCode [ldpInterface getFirstLearnedMartiniLabel]
                while {$labelRetCode == 0} {
                    lappend source_list        [ldpLearnedMartiniLabel cget \
                            -peerIpAddress   ]
                    
                    set labelRetCode [ldpInterface getNextLearnedMartiniLabel]
                }
            }
            set interfaceRetCode [ldpRouter getNextInterface]
        }
        if {[llength $source_list] > 0} {
            keylset returnList neighbors  [lsort -unique $source_list]
        } else  {
            keylset returnList neighbors  N/A
        }
    }
    
    # MODE LSP_LABELS
    if {$mode == "lsp_labels"} {
        set retCode [ldpServer getRouter $handle]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ldpServer getRouter $handle failed. \
                    Return code was $retCode."
            return $returnList
        }
        
        # When router is disabled return
        if {![ldpRouter cget -enable]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: LDP session handle\
                    $handle is not enabled."
            return $returnList
        }
        
        set prefix_list        ""
        set prefix_length_list ""
        set label_list         ""
        set source_list        ""
        set type_list          ""
        set fec_type_list      ""
        set vc_id_list         ""
        set vc_type_list       ""
        set group_id_list      ""
        set vci_list           ""
        set vpi_list           ""
        set state_list         ""
        
        set interfaceRetCode [ldpRouter getFirstInterface]
        
        if {$interfaceRetCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: LDP session handle\
                    $handle does not have any interfaces configured."
            return $returnList
        }
        
        while {$interfaceRetCode == 0} {
            ldpInterface requestLearnedLabels
            set requestResult [ldpInterface getLearnedLabelList]
            for {set i 0} {($requestResult != 0) && ($i < 5)} {incr i} {
                after 3000
                set requestResult [ldpInterface getLearnedLabelList]
            }
            # LEARNED IPv4 LABELS
            if {$requestResult == 0} {
                set labelRetCode [ldpInterface getFirstLearnedIpV4Label]
                while {$labelRetCode == 0} {
                    lappend prefix_list        [ldpLearnedIpV4Label cget \
                            -fec             ]
                    
                    lappend prefix_length_list [ldpLearnedIpV4Label cget \
                            -fecPrefixLength ]
                    
                    lappend label_list         [ldpLearnedIpV4Label cget \
                            -label           ]
                    
                    lappend source_list        [ldpLearnedIpV4Label cget \
                            -peerIpAddress   ]
                    
                    lappend type_list          learned
                    lappend fec_type_list      ipv4_prefix
                    lappend vc_id_list         N/A
                    lappend vc_type_list       N/A
                    lappend group_id_list      N/A
                    lappend vci_list           N/A
                    lappend vpi_list           N/A
                    lappend state_list         N/A
                    
                    set labelRetCode [ldpInterface getNextLearnedIpV4Label]
                }
            }
            # LEARNED IPv4 ATM LABELS
            if {$requestResult == 0} {
                set labelRetCode [ldpInterface getFirstLearnedIpV4AtmLabel]
                while {$labelRetCode == 0} {
                    lappend prefix_list        [ldpLearnedIpV4AtmLabel cget \
                            -fec             ]
                    
                    lappend prefix_length_list [ldpLearnedIpV4AtmLabel cget \
                            -fecPrefixLength ]
                    
                    lappend label_list         N/A
                    
                    lappend source_list        [ldpLearnedIpV4AtmLabel cget \
                            -peerIpAddress   ]
                    
                    lappend type_list          learned
                    lappend fec_type_list      ipv4_prefix
                    lappend vc_id_list         N/A
                    lappend vc_type_list       N/A
                    lappend group_id_list      N/A
                    lappend vci_list           [ldpLearnedIpV4AtmLabel cget \
                            -vci   ]
                    
                    lappend vpi_list           [ldpLearnedIpV4AtmLabel cget \
                            -vpi   ]
                    
                    lappend state_list         N/A
                    
                    set labelRetCode [ldpInterface getNextLearnedIpV4AtmLabel]
                }
            }
            # ASSIGNED ATM LABELS
            if {$requestResult == 0} {
                set labelRetCode [ldpInterface getFirstAssignedAtmLabel]
                while {$labelRetCode == 0} {
                    lappend prefix_list        [ldpAssignedAtmLabel cget \
                            -fec             ]
                    
                    lappend prefix_length_list [ldpAssignedAtmLabel cget \
                            -fecPrefixLength ]
                    
                    lappend label_list         N/A
                    
                    lappend source_list        [ldpAssignedAtmLabel cget \
                            -peerIpAddress   ]
                    
                    lappend type_list          assigned
                    lappend fec_type_list      ipv4_prefix
                    lappend vc_id_list         N/A
                    lappend vc_type_list       N/A
                    lappend group_id_list      N/A
                    lappend vci_list           [ldpAssignedAtmLabel cget \
                            -vci   ]
                    
                    lappend vpi_list           [ldpAssignedAtmLabel cget \
                            -vpi   ]
                    
                    lappend state_list         [ldpAssignedAtmLabel cget \
                            -state ]
                    
                    set labelRetCode [ldpInterface getNextAssignedAtmLabel]
                }
            }
            # LEARNED MARTINI LABELS
            if {$requestResult == 0} {
                array set vc_types_array [list \
                        1  frameRelay \
                        2  ATMAAL5    \
                        3  ATMXCell   \
                        4  VLAN       \
                        5  Ethernet   \
                        6  HDLC       \
                        7  PPP        \
                        8  CEM        \
                        9  ATMVCC     \
                        10 ATMVPC     ]
                set labelRetCode [ldpInterface getFirstLearnedMartiniLabel]
                while {$labelRetCode == 0} {
                    lappend prefix_list        N/A
                    
                    lappend prefix_length_list N/A
                    
                    lappend label_list         [ldpLearnedMartiniLabel cget \
                            -label           ]
                    
                    lappend source_list        [ldpLearnedMartiniLabel cget \
                            -peerIpAddress   ]
                    
                    lappend type_list          learned
                    lappend fec_type_list      vc
                    lappend vc_id_list         [ldpLearnedMartiniLabel cget \
                            -vcId     ]
                    
                    set     temp_vc_type       [ldpLearnedMartiniLabel cget \
                            -vcType   ]
                    lappend vc_type_list       $vc_types_array($temp_vc_type)
                    lappend group_id_list      [ldpLearnedMartiniLabel cget \
                            -groupId  ]
                    lappend vci_list           N/A
                    lappend vpi_list           N/A
                    lappend state_list         N/A
                    
                    set labelRetCode [ldpInterface getNextLearnedMartiniLabel]
                }
            }
            set interfaceRetCode [ldpRouter getNextInterface]
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
    
    keylset returnList status $::SUCCESS
    return $returnList
}
