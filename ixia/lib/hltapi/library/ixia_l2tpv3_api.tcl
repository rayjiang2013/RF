##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_l2tpv3_api.tcl
#
# Purpose:
#    A script development library containing L2TPv3 APIs for test automation
#    with the Ixia chassis.
#
# Author:
#    Ixia engineering, direct all communication to support@ixiacom.com
#
# Usage:
#
# Description:
#    The procedures contained within this library include:
#
#    -l2tpv3_dynamic_cc_config
#    -l2tpv3_session_config
#    -l2tpv3_control
#    -l2tpv3_stats
#
# Requirements:
#    parsedashedargds.tcl
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
# meet the user’s requirements or (ii) that the script will be without      #
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


proc ::ixia::l2tpv3_dynamic_cc_config { args } {
    variable executeOnTclServer
    variable l2tpv3_cc_handles_array

    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args

    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::l2tpv3_dynamic_cc_config $args\}]
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args

    set mandatory_args {
        -action CHOICES create delete modify
    }

    set opt_args {
        -cc_handle
        -port_handle                REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -cc_src_ip                  IP
        -cc_ip_mode                 CHOICES fixed increment
                                    DEFAULT fixed
        -cc_src_ip_step             IP
                                    DEFAULT 0.0.0.1
        -cc_ip_count                NUMERIC
        -cc_src_ip_subnet_mask      IP
                                    DEFAULT 255.255.255.0
        -cc_dst_ip                  IP
        -cc_dst_ip_step             IP
                                    DEFAULT 0.0.0.1
        -gateway_ip                 IP
        -gateway_ip_step            IP
                                    DEFAULT 0.0.0.1
        -enable_unconnected_intf    CHOICES 0 1
                                    DEFAULT 0
        -base_unconnected_ip        IP
                                    DEFAULT 0.0.0.0
        -cc_id_start                NUMERIC
                                    DEFAULT 1
        -router_identification_mode CHOICES hostname routerid both
                                    DEFAULT routerid
        -hostname                   ALPHANUM
        -hostname_suffix_start      NUMERIC
                                    DEFAULT 1
        -router_id_min              NUMERIC
                                    DEFAULT 1
        -cookie_size                CHOICES 0 4 8
                                    DEFAULT 0
        -retransmit_retries         RANGE   1-1000
                                    DEFAULT 15
        -retransmit_timeout_max     RANGE   1-8
                                    DEFAULT 8
        -retransmit_timeout_min     RANGE   1-8
                                    DEFAULT 1
        -hidden                     CHOICES 0 1
                                    DEFAULT 0
        -authentication             CHOICES 0 1
                                    DEFAULT 0
        -password                   ALPHANUM
                                    DEFAULT "LAB"
        -hello_interval             RANGE   0-1000
                                    DEFAULT 60
        -cc_src_mac                 MAC
        -enable_l2_sublayer         CHOICES 0 1
                                    DEFAULT 0
        -l2tp_variant               CHOICES ietf_variant cisco_variant
                                    DEFAULT ietf_variant
        -message_digest             CHOICES no_digest md5_digest sha1_digest
                                    DEFAULT no_digest
        -peer_host_name             ANY
                                    DEFAULT "IxiaLNS"
        -peer_router_id             NUMERIC
                                    DEFAULT 200
        -secret_increment_mode      CHOICES local_incr peer_incr
                                    DEFAULT local_incr
        -tunnel_setup_role          CHOICES active_role passive_role
                                    DEFAULT active_role
        -redial                     CHOICES 0 1
                                    DEFAULT 1
        -no_call_timeout            NUMERIC
                                    DEFAULT 5
        -redial_max                 NUMERIC
                                    DEFAULT 20
        -redial_timeout             NUMERIC
                                    DEFAULT 10
        -rws                        RANGE 1-2048
                                    DEFAULT 10
        -num_cell_packed_rx         RANGE 1-25
                                    DEFAULT 1
        -num_cell_packed_tx         RANGE 1-4
                                    DEFAULT 1
        -tunnel_id_start            RANGE 1-65535
                                    DEFAULT 1
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $mandatory_args

    # Unset default values for action modify and delete
    if {$action != "create"} {
        removeDefaultOptionVars $opt_args $args
    }

    # Check parameters
    set resultList [::ixia::l2tpv3CheckCcConfigParams]
    if {[keylget resultList status] == $::FAILURE} {
        return $resultList
    }

    array set l2tpOptionsArray [list                               \
            baseLocalRouterId           router_id_min              \
            cookieLen                   cookie_size                \
            l2tpRetries                 retransmit_retries         \
            enableAvpHiding             hidden                     \
            secret                      password                   \
            maxTimeout                  retransmit_timeout_max     \
            initTimeout                 retransmit_timeout_min     \
            tunnelAuthMode              router_identification_mode \
            tunnelSetupRole             tunnel_setup_role          \
            enableL2Sublayer            enable_l2_sublayer         \
            l2tpVariant                 l2tp_variant               \
            messageDigestAlgorithm      message_digest             \
            peerHostName                peer_host_name             \
            basePeerRouterId            peer_router_id             \
            secretIncrementMode         secret_increment_mode      \
            numPeerRouters              numPeerRouters             \
            enableRedial                redial                     \
            noCallTimeout               no_call_timeout            \
            redialMax                   redial_max                 \
            redialTimeout               redial_timeout             \
            rws                         rws                        \
            frameRelayHdrLen            frame_relay_hdr_len        \
            l2SpecificSublayer          l2_specific_sublayer       \
            numCellPackedRx             num_cell_packed_rx         \
            numCellPackedTx             num_cell_packed_tx         \
            tunnelStartId               tunnel_id_start            ]
    
    array set enumList [list                                  \
            no_auth        $::kIxAccessTunAuthNone            \
            hostname       $::kIxAccessTunAuthHostname        \
            routerid       $::kIxAccessTunAuthRouterId        \
            both           $::kIxAccessTunAuthBoth            \
            no_sublayer    $::kIxAccessL2SublayerNone         \
            ietf_sublayer  $::kIxAccessL2SublayerDefault      \
            atm_sublayer   $::kIxAccessL2SublayerAtm          \
            ietf_variant   $::kIxAccessL2tpVariantIETF        \
            cisco_variant  $::kIxAccessL2tpVariantCisco       \
            no_digest      $::kIxAccessMsgDigestNone          \
            md5_digest     $::kIxAccessMsgDigestMD5           \
            sha1_digest    $::kIxAccessMsgDigestSHA1          \
            local_incr     $::kIxAccessL2tpSecretIncModeLocal \
            peer_incr      $::kIxAccessL2tpSecretIncModePeer  \
            active_role    $::kIxAccessTunnelSetupActive      \
            passive_role   $::kIxAccessTunnelSetupPassive     ]

    # Delete the group
    if {$action == "delete"} {
        ::ixia::updateL2tpv3CcHandleArray -mode delete -ccHandle $cc_handle
        keylset returnList status $::SUCCESS
        return $returnList
    }

    # Create the group
    if {$action == "create"} {
        # Find out if the port is in use
        set portUsedBy [::ixia::getL2tpv3CcHandleUsingPort $port_handle]
        if {$portUsedBy != ""} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Port $port_handle is\
                    already in use by group $portUsedBy."
            return $returnList
        }

        if {[info exists cc_src_mac]} {
            set cc_src_mac [::ixia::convertToIxiaMac $cc_src_mac]
        } else  {
            foreach {chassis card port} [split $port_handle /] {}
            set cc_src_mac "00 [format %02x $chassis] [\
                    format %02x $card] [format %02x $port] 00 01"
        }

        # When increment mode is fixed set the step to 0.0.0.0
        if {$cc_ip_mode == "fixed"} {
            set cc_src_ip_step  0.0.0.0
            set cc_dst_ip_step  0.0.0.0
            set gateway_ip_step 0.0.0.0
            set cc_ip_count     1
        }

        if {$cc_dst_ip_step == "0.0.0.0"} {
            set numPeerRouters 1
        } else  {
            set numPeerRouters $cc_ip_count
        }

        # Calculate source step value
        set space_ip [split $cc_src_ip_step .]
        foreach {one two three four} $space_ip {}
        set cc_src_step_value [mpexpr ($one << 24) | ($two << 16) | \
                ($three << 8) | ($four)]

        # Calculate source step value
        set space_ip [split $gateway_ip_step .]
        foreach {one two three four} $space_ip {}
        set gateway_step_value [mpexpr ($one << 24) | ($two << 16) | \
                ($three << 8) | ($four)]

        set srcParamsList [list $cc_src_ip $cc_src_step_value \
                $cc_src_ip_subnet_mask $cc_src_mac]
        set dstParamsList [list $cc_dst_ip $cc_dst_ip_step]
        set gatewayParamsList [list $gateway_ip $gateway_step_value]
        set unconnectedIntfParamsList [list \
                $enable_unconnected_intf $base_unconnected_ip]

        # Get next handle
        set cc_handle [::ixia::nextL2tpv3CcHandle]
        # Save data for the handle
        ::ixia::updateL2tpv3CcHandleArray                     \
                -mode              create                     \
                -ccHandle          $cc_handle                 \
                -port              $port_handle               \
                -subport           0                          \
                -numRouters        $cc_ip_count               \
                -ccIdStart         $cc_id_start               \
                -routerIdStart     $router_id_min             \
                -ipConfig [list                               \
                $srcParamsList     $dstParamsList             \
                $gatewayParamsList $unconnectedIntfParamsList ]
    }

    # Setting the options
    # Common for create and modify group
    if {[info exists authentication] && ($authentication == 0)} {
        set router_identification_mode "no_auth"
    }

    set optionValueList ""

    foreach {item itemName} [array get l2tpOptionsArray] {
        if {![catch {set $itemName} value] } {
            if {[lsearch [array names enumList] $value] != -1} {
                set value $enumList($value)
            }
            lappend optionValueList $item $value
        }
    }

    if {![info exists hostname_suffix_start]} {
        set hostname_suffix_start 1
    }

    if {[info exists hostname]} {
        # Set hostname to myHostNameXXXX, where XXXX is filled with 0s
        # when necessary
        set hostname ${hostname}%
        set suffixLength [string length $hostname_suffix_start]
        for {set i 4} {$i > $suffixLength} {incr i -1} {
            set hostname ${hostname}0
        }
        set hostname ${hostname}${hostname_suffix_start}i
        lappend optionValueList hostname $hostname
    }

    if {[info exists hello_interval]} {
        if {$hello_interval > 0} {
            lappend optionValueList enableHelloRequest true
            lappend optionValueList helloTimeout $hello_interval
        } else  {
            lappend optionValueList enableHelloRequest false
        }
    }

    ::ixia::updateL2tpv3CcHandleArray -mode modify -ccHandle $cc_handle \
            -options $optionValueList

    keylset returnList status $::SUCCESS
    keylset returnList handle $cc_handle
    return $returnList
}


proc ::ixia::l2tpv3_session_config { args } {
    variable executeOnTclServer
    variable l2tpv3_cc_handles_array
    variable l2tpv3_session_handles_array

    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::l2tpv3_session_config $args\}]
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args

    set mandatory_args {
        -action CHOICES create delete modify
    }

    set opt_args {
        -session_handle
        -cc_handle
        -vcid_start             NUMERIC
        -vcid_mode              CHOICES fixed increment
                                DEFAULT increment
        -vcid_step              NUMERIC
                                DEFAULT 1
        -num_sessions           NUMERIC
        -ip_tos                 CHOICES reflect fixed
                                DEFAULT reflect
        -ip_tos_value           RANGE 0-255
                                DEFAULT 0
        -sequencing_transmit    CHOICES 0 1
                                DEFAULT 0
        -pw_type                CHOICES ethernet dot1q_ethernet frame_relay
                                CHOICES atm
        -mac_src                MAC
        -mac_src_step           MAC
                                DEFAULT 0000.0000.0001
        -mac_dst                MAC
        -mac_dst_step           MAC
                                DEFAULT 0000.0000.0001
        -vlan_id                RANGE 1-4094
        -vlan_id_step           RANGE 0-4094
                                DEFAULT 1
        -fr_dlci_value          NUMERIC
        -fr_dlci_step           NUMERIC
                                DEFAULT 1
        -vpi                    RANGE 0-255
        -vci                    RANGE 32-65535
        -vpi_step               NUMERIC
                                DEFAULT 1
        -vci_step               NUMERIC
                                DEFAULT 1
        -session_id_start       RANGE 1-65535
                                DEFAULT 10000
        -pvc_incr_mode          CHOICES vpi vci both
        -qos_rate_mode          CHOICES percent pps bps
                                DEFAULT bps
        -qos_rate               NUMERIC
        -qos_atm_clp            CHOICES 0 1
                                DEFAULT 0
        -qos_atm_efci           CHOICES 0 1
                                DEFAULT 0
        -qos_atm_cr             CHOICES 0 1
                                DEFAULT 0
        -qos_fr_cr              CHOICES 0 1
                                DEFAULT 0
        -qos_fr_de              CHOICES 0 1
                                DEFAULT 0
        -qos_fr_becn            CHOICES 0 1
                                DEFAULT 0
        -qos_fr_fecn            CHOICES 0 1
                                DEFAULT 0
        -qos_ipv6_flow_label    RANGE 0-1048575
                                DEFAULT 0
        -qos_ipv6_traffic_class RANGE 0-255
                                DEFAULT 0
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $mandatory_args

    # Unset default values for action modify and delete
    if {$action != "create"} {
        removeDefaultOptionVars $opt_args $args
    }

    # Check parameters
    set resultList [::ixia::l2tpv3CheckSessionConfigParams]

    if {[keylget resultList status] == $::FAILURE} {
        return $resultList
    }

    # When action is modify/delete check if data is present in array
    if {($action == "delete") || ($action == "modify")} {
        if {![info exists l2tpv3_session_handles_array($session_handle,ccHandle)] \
                || ![info exists l2tpv3_session_handles_array($session_handle,pwType)] \
                || ![info exists l2tpv3_session_handles_array($session_handle,acParams)]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Cannot find the\
                    session handle $session_handle in the\
                    l2tpv3_session_handles_array"
            return $returnList
        }
    }

    # Delete session group
    if {$action == "delete"} {
        ::ixia::updateL2tpv3SessionHandleArray -mode delete \
                -sessionHandle $session_handle
        keylset returnList status $::SUCCESS
        return $returnList
    }

    # Common for create and modify.
    # Set QoS options
    array set qosEnumList [list \
            percent $::kIxAccessLineUtilization \
            pps     $::kIxAccessPacketPerSec    \
            bps     $::kIxAccessBitPerSec       ]

    array set qosOptList [list          \
            percent percentageLineRate  \
            pps     packetPerSecond     \
            bps     bitsPerSecond       ]

    array set qosDefaultList [list     \
            percentageLineRate 100     \
            packetPerSecond    1000    \
            bitsPerSecond      5000000 ]

    set qosParams ""
    array set qosParamsArray {
        rateMode             qos_rate_mode
        atmCLP               qos_atm_clp
        atmEFCI              qos_atm_efci
        atmCR                qos_atm_cr
        frCR                 qos_fr_cr
        frDE                 qos_fr_de
        frBECN               qos_fr_becn
        frFECN               qos_fr_fecn
        ipv6FlowLabel        qos_ipv6_flow_label
        ipv6TrafficClass     qos_ipv6_traffic_class
    }
    if {[info exists qos_rate_mode]} {
        if {[llength $qos_rate_mode] > 1} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Only one QoS Group can\
                    be attached per session."
            return $returnList
        }
        set qosParamsArray($qosOptList($qos_rate_mode)) qos_rate
    }
    if {$action == "create" && (![info exists qos_rate])} {
        set qos_rate $qosDefaultList($qosOptList($qos_rate_mode))
    }

    foreach {qosOpt qosName} [array get qosParamsArray] {
        if {[info exists $qosName]} {
            if {![catch {set qosEnumList([set $qosName])} value]} {
                set $qosName $value
            }
            lappend qosParams $qosOpt [set $qosName]
        }
    }

    # Set pwType and acOptions
    if {[info exists pw_type]} {
        if {$vcid_mode == "fixed"} {
            set num_sessions 1
        }

        if {$pw_type == "ethernet"} {
            set vlan_id      0
            set vlan_id_step 0
        }

        switch -- $pw_type {
            ethernet -
            dot1q_ethernet {
                set ethParams [list $mac_src $mac_src_step $mac_dst \
                        $mac_dst_step]
                set vlanParams [list $vlan_id $vlan_id_step]
                set acParams [list $ethParams $vlanParams]
            }
            frame_relay {
                set acParams [list $fr_dlci_value $fr_dlci_step]
            }
            atm {
                set vpiParams [list $vpi $vpi_step]
                set vciParams [list $vci $vci_step]
                set acParams [list $vpiParams $vciParams]
            }
            default {
            }
        }
    }

    # Modify session group
    if {$action == "modify"} {
        set optionsToBeModified ""
        if {[info exists pw_type]} {
            lappend optionsToBeModified -pwType $pw_type
            lappend optionsToBeModified -acParams $acParams
        }

        if {[info exists ip_tos]} {
            if {$ip_tos == "reflect"} {
                lappend optionsToBeModified -tosByte 0
            } else  {
                lappend optionsToBeModified -tosByte $ip_tos_value
            }
        }
        if {$qosParams != ""} {
            lappend optionsToBeModified -qosParams $qosParams
        }

        eval ::ixia::updateL2tpv3SessionHandleArray \
                -mode modify                        \
                -sessionHandle $session_handle      \
                $optionsToBeModified

        # Sequence bit is set in l2tp parameter list
        set optionsList ""
        set cc_handle $l2tpv3_session_handles_array($session_handle,ccHandle)
        if {[info exists sequencing_transmit]} {
            if {$sequencing_transmit == 1} {
                lappend optionsList         \
                        enableSequenceBit 1 \
                        enableL2Sublayer  1
            } else  {
                lappend optionsList enableSequenceBit 0
            }
        }

        if {[info exists session_id_start]} {
            lappend optionsList sessionStartId $session_id_start
        }
        if {$optionsList != ""} {
            ::ixia::updateL2tpv3CcHandleArray \
                    -mode      modify         \
                    -ccHandle $cc_handle      \
                    -options  $optionsList
        }

        keylset returnList status $::SUCCESS
        keylset returnList handle $session_handle
        return $returnList
    }

    # Create from here
    if {![info exists ip_tos] || ($ip_tos == "reflect")} {
        set ip_tos_value 0
    }

    set session_handle [::ixia::nextL2tpv3SessionHandle]
    ::ixia::updateL2tpv3SessionHandleArray                                \
            -mode          create                                         \
            -sessionHandle $session_handle                                \
            -ccHandle      $cc_handle                                     \
            -vcidInfo      [list $vcid_start $vcid_step $num_sessions]    \
            -pwType        $pw_type                                       \
            -acParams      $acParams                                      \
            -tosByte       $ip_tos_value                                  \
            -qosParams     $qosParams

    set optionsList ""
    # Sequence bit is set in l2tp parameter list
    if {[info exists sequencing_transmit]} {
        set optionsList [list \
                enableSequenceBit $sequencing_transmit \
                enableL2Sublayer  $sequencing_transmit ]
    }

    # Session id start in l2tp parameter list
    if {[info exists session_id_start]} {
        lappend optionsList sessionStartId $session_id_start
    }
    if {$optionsList != ""} {
        ::ixia::updateL2tpv3CcHandleArray \
                -mode      modify         \
                -ccHandle $cc_handle      \
                -options  $optionsList
    }

    keylset returnList status $::SUCCESS
    keylset returnList handle $session_handle
    return $returnList
}


proc ::ixia::l2tpv3_control { args } {
    variable executeOnTclServer

    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args

    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::l2tpv3_control $args\}]
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args

    set mandatory_args {
        -action CHOICES start stop retry restart clear_stats delete_all
    }

    set optional_args {
        -port_handle ^[0-9]+/[0-9]+/[0-9]+$
    }

    if {[isUNIX]} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValueClicks [eval "clientSend $::ixTclSvrHandle {clock clicks}"]
        set retValueSeconds [eval "clientSend $::ixTclSvrHandle {clock seconds}"]
    } else {
        set retValueClicks [clock clicks]
        set retValueSeconds [clock seconds]
    }
    keylset returnList clicks [format "%u" $retValueClicks]
    keylset returnList seconds [format "%u" $retValueSeconds]

    ::ixia::parse_dashed_args -args $args -optional_args $optional_args \
            -mandatory_args $mandatory_args

    if {[info exists port_handle]} {
        set portList [::ixia::format_space_port_list $port_handle]
    } else  {
        set portList [::ixia::getL2tpv3ConfiguredPortList]
    }

    # When action is start create configuration for the ports
    if {$action == "start"} {
        set ccHandleList [::ixia::l2tpv3GetCcHandles $portList]
        if {[llength $ccHandleList] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: No cc group handle\
                    configured on ports $port_handle."
            return $returnList
        }

        set resultList [::ixia::l2tpv3CreateConfiguration $ccHandleList]
        if {[keylget resultList status] == $::FAILURE} {
            return $resultList
        }
    }

    foreach portHandle $portList {
        foreach {chassis card port} $portHandle {}

        switch -- $action {
            start -
            retry -
            restart {
                ixAccessProfile select $chassis $card $port
                set retCode [ixAccessProfile startOperation setup1]

                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Error starting\
                            tunnels and sessions on port $chassis.$card.$port. \
                            Status: [ixAccessGetErrorString $retCode]"
                    return $returnList
                }

                # wait for the setup to be started or completed
                for { set k 0 } { $k < 50 } { incr k } {
                    after 100
                    set opState [ixAccessProfile getOperationState setup1]
                    if { ($opState == $::kIxAccessActive)  || \
                            ($opState == $::kIxAccessDone) } {
                        break
                    }
                }
                if { $k == 50 } {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Could not\
                            setup tunnels and sessions on port\
                            $chassis.$card.$port."
                    return $returnList
                }
            }
            stop {
                ixAccessProfile select $chassis $card $port
                # Cancel any already running setup operation
                ixAccessProfile stopOperation setup
                set retCode [ixAccessProfile startOperation teardown]
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Error stopping\
                            tunnels and sessions on port $chassis.$card.$port. \
                            Status: [ixAccessGetErrorString $retCode]"
                    return $returnList
                }

                # wait for the teardown to be started or completed
                for {set k 0} {$k < 50} {incr k} {
                    after 100
                    set opState [ixAccessProfile getOperationState teardown]
                    if { ($opState == $::kIxAccessActive)  || \
                            ($opState == $::kIxAccessDone) } {
                        break
                    }
                }
                if { $k == 50 } {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Could not stop\
                            tunnels and sessions on port\
                            $chassis.$card.$port."
                    return $returnList
                }
            }
            delete_all {
                ixAccessCleanupPorts $portList

                ::ixia::updateL2tpv3CcHandleArray -mode delete \
                        -port ${chassis}/${card}/${port}
            }
            clear_stats {
            }
        }
    }

    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::l2tpv3_stats { args } {
    variable executeOnTclServer
    variable l2tpv3_cc_handles_array

    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args

    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::l2tpv3_stats $args\}]
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args

    set mandatory_args {
        -mode CHOICES aggregate control_connection session
        -cc_handle
    }

    set opt_args {
        -cc_id           NUMERIC
                         DEFAULT 0
        -cc_id_range_end NUMERIC
        -vcid            NUMERIC
                         DEFAULT 0
        -vcid_range_end  NUMERIC
        -csv_filename
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $mandatory_args

    set aggregateStatsOptionList [list              \
            connecting          ifsLinkNeg          \
            connected           ifsUp               \
            connect_success     ifsUp               \
            sessions_up         ifsUp               \
            min_setup_time      minLatency          \
            max_setup_time      maxLatency          \
            avg_setup_time      avgLatency          \
            success_setup_rate  actualRate          ]

    set tunnelStatsOptionList [list                 \
            zlb_tx           l2tpZlbTx              \
            sccrp_tx         l2tpSccrpTx            \
            scccn_tx         l2tpScccnTx            \
            sccrq_tx         l2tpSccrqTx            \
            stopccn_tx       l2tpStopccnTx          \
            hello_tx         l2tpHelloTx            \
            icrq_tx          l2tpIcrqTx             \
            icrp_tx          l2tpIcrpTx             \
            iccn_tx          l2tpIccnTx             \
            cdn_tx           l2tpCdnTx              \
            wen_tx           l2tpWenTx              \
            sli_tx           l2tpSliTx              \
            zlb_rx           l2tpZlbRx              \
            sccrp_rx         l2tpSccrpRx            \
            scccn_rx         l2tpScccnRx            \
            sccrq_rx         l2tpSccrqRx            \
            stopccn_rx       l2tpStopccnRx          \
            hello_rx         l2tpHelloRx            \
            icrq_rx          l2tpIcrqRx             \
            icrp_rx          l2tpIcrpRx             \
            iccn_rx          l2tpIccnRx             \
            cdn_rx           l2tpCdnRx              \
            wen_rx           l2tpWenRx              \
            sli_rx           l2tpSliRx              \
            out_of_order_rx  l2tpTunRxOutOfOrder    \
            out_of_win_rx    l2tpTunRxOutOfWin      \
            duplicate_rx     l2tpTunRxDuplicate     \
            in_order_rx      l2tpTunRxInOrder       \
            retransmits      l2tpTunRetransmit      \
            tx_pkt_acked     l2tpTunTxPktAcked      \
            tx_data_pkt      l2tpTotalBytesTx       \
            rx_data_pkt      l2tpTotalBytesRx       ]

    set sessionStatsOptionList [list         \
            icrq_tx       l2tpIcrqTx         \
            icrp_tx       l2tpIcrpTx         \
            iccn_tx       l2tpIccnTx         \
            cdn_tx        l2tpCdnTx          \
            icrq_rx       l2tpIcrqRx         \
            icrp_rx       l2tpIcrpRx         \
            iccn_rx       l2tpIccnRx         \
            cdn_rx        l2tpCdnRx          \
            tx_pkt_acked  l2tpTxPktAcked     ]

    if {![info exists l2tpv3_cc_handles_array($cc_handle,port)] \
            || ![info exists l2tpv3_cc_handles_array($cc_handle,subport)]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Cannot find the cc\
                handle $cc_handle in the l2tpv3_cc_handles_array"
        return $returnList
    }

    set interface   $l2tpv3_cc_handles_array($cc_handle,port)
    set subport     $l2tpv3_cc_handles_array($cc_handle,subport)
    set numRouters  $l2tpv3_cc_handles_array($cc_handle,numRouters)
    set ccIdStart   $l2tpv3_cc_handles_array($cc_handle,ccIdStart)
    set ccIdStop    [mpexpr $ccIdStart + $numRouters - 1]
    foreach {chassis card port} [split $interface /] {}

    switch -- $mode {
        aggregate {
            ixAccessSubPort get $chassis $card $port $subport
            set numSessions [ixAccessSubPort cget -numSessions]
            keylset returnList aggregate.num_sessions $numSessions

            ixAccessPortStats get $chassis $card $port $subport

            foreach {statName statOption} $aggregateStatsOptionList {
                set statValue [ixAccessPortStats cget -$statOption]
                keylset returnList aggregate.$statName $statValue
            }

            foreach {statName statOption} $tunnelStatsOptionList {
                set statValue [ixAccessPortStats cget -$statOption]
                keylset returnList aggregate.$statName $statValue
            }
        }
        control_connection {
            if {![info exists cc_id_range_end]} {
                set cc_id_range_end $cc_id
            }

            if {($cc_id < $ccIdStart) || ($cc_id_range_end > $ccIdStop)} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: cc_id or\
                        cc_id_range_end out of range.  Should be in the\
                        range $ccIdStart - $ccIdStop"
                return $returnList
            }

            set firstRouterId [mpexpr 1 + $ccIdStart - $cc_id]
            set lastRouterId [mpexpr $firstRouterId + $cc_id_range_end - $cc_id]

            set retCode [ixAccessTunnelTable select $chassis $card $port]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to select\
                        tunnel table for port $chassis.$card.$port.  Status:\
                        [ixAccessGetErrorString $retCode]"
                return $returnList
            }

            ixAccessTunnelTable clearAllTunnels
            set retCode [ixAccessPort getTunnelStats $chassis $card $port \
                    $firstRouterId $lastRouterId $::kIxAccessStatusAll]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to get\
                        tunnel stats for port $chassis.$card.$port.  Status:\
                        [ixAccessGetErrorString $retCode]"
                return $returnList
            }

            set retCode [ixAccessTunnelTable get $chassis $card $port]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to get\
                        tunnel table for port $chassi.$card.$port.  Status:\
                        [ixAccessGetErrorString $retCode]"
                return $returnList
            }

            set ccId $cc_id
            set tunnelExists [ixAccessTunnelTable getFirstTunnel]
            while {$tunnelExists == 0} {
                foreach {statName statOption} $tunnelStatsOptionList {
                    set statValue [ixAccessTunnel cget -$statOption]
                    keylset returnList cc.$ccId.$statName $statValue
                }

                incr ccId
                set tunnelExists [ixAccessTunnelTable getNextTunnel]
            }
        }
        session {
            if {![info exists vcid_range_end]} {
                set vcid_range_end $vcid
            }

            # For unix/linux, we will use a directory structure in the /tmp
            # area, for write enabled issues.  So we will need to make sure
            # the directory exists
            if {[isUNIX]} {
                set dirName [file join / tmp Ixia IxAccess]
                if {![file isdirectory $dirName]} {
                    file mkdir $dirName
                }
            } else {
                set dirName [file join $::env(IXIA_HLTAPI_LIBRARY)]
            }

            # Retrieve and process all of the per session statistics
            set _sess_cmd "ixAccessUtil::getSessionData $chassis $card \
                    $port -startrow 1 -endrow 16000 -tcllistfile       \
                    {[file join $dirName ixAccessStats.tcl]}"

            if {[info exists csv_filename]} {
                append _sess_cmd " -csvfile \
                        {[file join $dirName $csv_filename]}"
            }

            set status [catch {eval $_sess_cmd} err]
            if {$status} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to retrieve\
                        session stats for port $chassis.$card.$port.  Status:\
                        [ixAccessGetErrorString $status]"
                return $returnList
            }

            # Fill the keyed list with detail session stats.
            if {[catch {set statFileId [open [file join $dirName \
                    ixAccessStats.tcl] r]}]} {

                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to open stat\
                        file.  No stats to return."
                return $returnList
            }

            set data [read $statFileId]
            close $statFileId
            set lines [split $data \n]
            catch {unset data}

            # The stat names are the first line in the data
            set statNames [lindex [lindex $lines 0] 0]
            set lines [lreplace $lines 0 0]
            foreach dataSet $lines {
                set dataSet [lindex $dataSet 0]
                set index1  [lsearch -exact $statNames l2tpPseudoWireId]
                if {$index1 > -1} {
                    set pwId [lindex $dataSet $index1]
                    # Is this in the range requested
                    if {($pwId >= $vcid) && ($pwId <= $vcid_range_end)} {
                        foreach {statName statOption} $sessionStatsOptionList {
                            # Add the stat value to the sum of previous values
                            if {[catch {keylget returnList \
                                    session.$pwId.$statName} prevValue]} {
                                set prevValue 0
                            }
                            set index1 [lsearch -exact $statNames $statOption]
                            if {$index1 > -1} {
                                set statValue    [lindex $dataSet $index1]
                                if {[llength $statValue] > 1} {
                                    set currentValue [expr 0x[join $statValue ""]  \
                                            + $prevValue]
                                } else  {
                                    set currentValue [expr $statValue + $prevValue]
                                }

                                keylset returnList session.$pwId.$statName \
                                        $currentValue
                            }
                        }
                    }
                }
            }
        }
        default {
        }
    }

    keylset returnList status $::SUCCESS
    return $returnList
}
