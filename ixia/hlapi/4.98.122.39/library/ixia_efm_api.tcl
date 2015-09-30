##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_efm_api.tcl
#
# Purpose:
#    A script development library containing Ethernet APIs for test automation
#    with the Ixia chassis.
#
# Author:
#    Mircea Hasegan
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures implemented will allow configuring EFM 
#    specific parameters using IxOS, IxNetwork and IxProtocol TCL API.
#    OAMPDUs contain control and status information needed to monitor, test 
#    and troubleshoot OAM-enabled links. This information is encoded using 
#    a major code followed by information encoded in Type-Length-Value (TLV) 
#    format
#    Limitations:
#     1. It is possible to configure OAM port characteristics and generate OAMPDUs 
#        (implemented as streams) on demand.
#     2. It is not possible to configure OAM to auto-generate OAMPDUs when an 
#        event occurs. For example, it is not possible to configure OAM to auto-generate 
#        an Event Notification OAMPDU with an Errored Frame Event TLV when the Ixia port 
#        exceeds a configured threshold. OAMPDUs can be sent only on demand (
#        using ::ixia::emulation_efm_control).
#     3. Statistics marked with ‘alarm’ are not monitored in background, 
#        so they are available only if a capture was performed on the port 
#        (limitation only when using IxOS Tcl API implementation).
#     4. The capture buffer size varies with the type of port being used. 
#        Verify capture buffer size in IxOS Hardware Guide to make sure all frames 
#        are captured (capture buffer become full before all traffic was recieved). 
#        Capture triggers and filters can be configured in order to capture only 
#        Ethernet OAM traffic. 
#     5. With IxNetwork and IxProtocol it is not possible create and send on demand Information
#        OAMPDUs. Flags and parameters that apply for Information OAMPDUs will be 
#        used for EFM discovery when the protocol is started using 
#        ::ixia::emulation_efm_control -action start.
#     6. Some statistics that were available with the IxOS implementation are not
#        available with the IxNetwork and IxProtocol implementation. This is mentioned with each 
#        statistic type.
#
# Requirements:
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


proc ::ixia::emulation_efm_config {args} {
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
                \{::ixia::emulation_efm_config $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    keylset returnList status $::SUCCESS

    ::ixia::utrackerLog $procName $args

    set man_args {
        -port_handle REGEXP ^[0-9]+/[0-9]+/[0-9]+$
    }

    set opt_args {
        -api_used                       CHOICES ixnetwork ixprotocol ixos
        -critical_event                 FLAG
        -dying_gasp                     FLAG
        -error_frame_count              NUMERIC
        -error_frame_period_count       NUMERIC
        -error_frame_period_threshold   NUMERIC
        -error_frame_period_window      NUMERIC
        -error_frame_threshold          NUMERIC
        -error_frame_window             NUMERIC
        -error_frame_summary_count      NUMERIC
        -error_frame_summary_threshold  NUMERIC
        -error_frame_summary_window     NUMERIC
        -error_symbol_period_count      NUMERIC
        -error_symbol_period_threshold  NUMERIC
        -error_symbol_period_window     NUMERIC
        -length_mode                    CHOICES fixed random
                                        DEFAULT random
        -link_events                    FLAG
        -link_fault                     FLAG
        -local_information_oui_value    REGEXP ^[0-9a-fA-F]{6}$
        -local_information_vsi_value    REGEXP ^[0-9a-fA-F]{8}$
        -mac_local
        -oampdu_type                    CHOICES none information event_notification info_and_event
                                        DEFAULT info_and_event
        -oui_value                      REGEXP ^[0-9a-fA-F]{6}$
        -remote_information_oui_value   REGEXP ^[0-9a-fA-F]{6}$
        -remote_information_vsi_value   REGEXP ^[0-9a-fA-F]{8}$
        -sequence_id                    RANGE   0-65535
        -sequence_id_step               RANGE   0-65535
                                        DEFAULT 1
        -size                           RANGE   64-1518
                                        DEFAULT 64
        -variable_retrieval             FLAG
        -vsi_value                      REGEXP ^[0-9a-fA-F]{8}$ 
        -disable_information_pdu_tx     CHOICES 0 1
                                        DEFAULT 0
        -disable_non_information_pdu_tx CHOICES 0 1
                                        DEFAULT 0
        -enable_loopback_response       CHOICES 0 1
                                        DEFAULT 1
        -enable_variable_response       CHOICES 0 1
                                        DEFAULT 1
        -event_interval                 RANGE 1-10
                                        DEFAULT 1
        -information_pdu_rate           RANGE 1-10
                                        DEFAULT 1
        -link_event_tx_mode             CHOICES single periodic
                                        DEFAULT periodic
        -local_lost_link_timer          RANGE 2-90
                                        DEFAULT 5
        -loopback_cmd                   CHOICES enable_oam_remote_loopback
                                        CHOICES disable_oam_remote_loopback
                                        DEFAULT enable_oam_remote_loopback
        -loopback_timeout               ANY
        -oam_mode                       CHOICES active passive
                                        DEFAULT passive
        -os_event_tlv_oui               REGEXP ^0x[0-9a-fA-F]{6}$
        -os_event_tlv_value             REGEXP ^0x[0-9a-fA-F]+$
        -os_oampdu_data_oui             REGEXP ^0x[0-9a-fA-F]{6}$
        -os_oampdu_data_value           REGEXP ^0x[0-9a-fA-F]+$
        -override_local_evaluating      CHOICES 0 1
                                        DEFAULT 0
        -override_local_satisfied       CHOICES 0 1
                                        DEFAULT 0
        -override_local_stable          CHOICES 0 1
                                        DEFAULT 0
        -override_remote_evaluating     CHOICES 0 1
                                        DEFAULT 0
        -override_remote_stable         CHOICES 0 1
                                        DEFAULT 0
        -override_revision              CHOICES 0 1
                                        DEFAULT 0
        -revision                       RANGE   0-65535
                                        DEFAULT 0
        -supports_remote_loopback       CHOICES 0 1
                                        DEFAULT 1
        -supports_unidir_mode           CHOICES 0 1
                                        DEFAULT 1
        -variable_response_timeout      ANY
                                        DEFAULT 1
        -version                        REGEXP ^0x[0-9a-fA-F]{2}$
                                        DEFAULT 0x01
        -enable_optional_tlv            CHOICES 0 1
        -enable_loopback                CHOICES 0 1
        -tlv_type                       REGEXP ^[0-9a-fA-F]+$
        -tlv_value                      REGEXP ^[0-9a-fA-F]+$
        -idle_timer                     RANGE   0-255
        -enable_oam                     CHOICES 0 1
        -oui_value_l1                   REGEXP ^[0-9a-fA-F]{6}$
        -vsi_value_l1                   REGEXP ^[0-9a-fA-F]{8}$
        -mac_local_l1
        -size_l1                        RANGE   64-1518
        -link_events_l1                 FLAG
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg"
        return $returnList
    }
    
    if {[info exists api_used]} {
    
        switch $api_used {
            "ixnetwork" {
            
                if {![info exists new_ixnetwork_api] || !$new_ixnetwork_api} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            parameter api_used cannot be configured to $api_used\
                            if the HLTSET used does not load IxNetwork Tcl API."
                    return $returnList
                }
    
                set returnList [::ixia::ixnetwork_efm_config $args $man_args $opt_args]
            
                if {[keylget returnList status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget returnList log]"
                }
                return $returnList
            }
            "ixprotocol" {
                if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            parameter api_used cannot be configured to $api_used\
                            if the HLTSET used does not load IxProtocol Tcl API."
                    return $returnList
                }
    
                set returnList [::ixia::ixprotocol_efm_config $args $man_args $opt_args]
            
                if {[keylget returnList status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget returnList log]"
                }
                return $returnList
            }
            "ixos" {
                # Use the implementation with IxOS Tcl API from below.
            }
        }
        
    } else {

        if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        
            set returnList [::ixia::ixnetwork_efm_config $args $man_args $opt_args]
        
            if {[keylget returnList status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget returnList log]"
            }
            return $returnList
            
        }
        
    }
    
    
    variable current_streamid
    variable pgid_to_stream
    
    foreach {ch ca po} [split $port_handle /] {}
    
    set event_notification_tlv_types {
        frame
        frame_period
        frame_summary
        symbol_period
    }
    
    set event_notification_tlv_params {
        count
        threshold
        window
    }
    
    foreach event_notification_type $event_notification_tlv_types {
        set add_${event_notification_type}_tlv 0
        foreach tlv_param $event_notification_tlv_params {
            if {[info exists error_${event_notification_type}_${tlv_param}]} {
                set add_${event_notification_type}_tlv 1
                break 
            }
        }
    }
    
    # OAMPDU Fields size
    # en_* Event Notification TLV sizes
    array set frame_size_array {
            mac_header                  12
            oam_type                    2
            oam_subtype                 1
            pdu_flag                    2
            pdu_code                    1
            end_of_tlv_marker           1
            crc                         4
            en_sequence                 2
            en_err_symbol_period_tlv    40
            en_err_frame_tlv            26
            en_err_frame_period_tlv     28
            en_err_frame_seconds_tlv    18
            info_local_tlv              16
            info_remote_tlv             16
        }
    
    # Set minimum frame size for Information OAMPDU
    set min_frame_size      0
    set min_frame_size_info 0
    set min_frame_size_en   0
    
    set min_frame_size      [mpexpr $frame_size_array(mac_header)           + \
                                    $frame_size_array(oam_type)             + \
                                    $frame_size_array(oam_subtype)          + \
                                    $frame_size_array(pdu_flag)             + \
                                    $frame_size_array(pdu_code)             + \
                                    $frame_size_array(end_of_tlv_marker)    + \
                                    $frame_size_array(crc)                    ]

    set min_frame_size_info [mpexpr $min_frame_size                         + \
                                    $frame_size_array(info_local_tlv)       + \
                                    $frame_size_array(info_remote_tlv)        ]

    if {$min_frame_size_info < 64} {
        set min_frame_size_info 64
    }

    set min_frame_size_en [mpexpr $min_frame_size + $frame_size_array(en_sequence)]
    
    # Set default values - these cannot be set through parse_dashed_args because 
    # their type does not accept DEFAULT
    set default_values_list {
        error_frame_count              0
        error_frame_period_count       0
        error_frame_period_threshold   30
        error_frame_period_window      300
        error_frame_threshold          40
        error_frame_window             400
        error_frame_summary_count      0
        error_frame_summary_threshold  30
        error_frame_summary_window     300
        error_symbol_period_count      0
        error_symbol_period_threshold  50
        error_symbol_period_window     500
        sequence_id                    0
    }
    foreach {efm_cfg_param default_value} $default_values_list {
        if {![info exists $efm_cfg_param]} {
            set $efm_cfg_param $default_value
        }
    }
    
    set flag_values {
        critical_event                 $::oamFlagCriticalEvent
        dying_gasp                     $::oamFlagDyingGasp
        link_events                    1
        link_fault                     $::oamFlagLinkFault
        variable_retrieval             1
    }
    foreach {efm_flag flag_value} $flag_values {
        if {[info exists $efm_flag]} {
            set $efm_flag $flag_value
        } else {
            set $efm_flag 0
        }
    }
    
    if {![info exists mac_local]} {
        set mac_local [::ixia::get_default_mac $ch $ca $po]
    }

    if {![::ixia::isValidMacAddress $mac_local]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Invalid mac address value \
                for -mac_local $mac_local"
        return $returnList
    }
    
    set mac_local [::ixia::convertToIxiaMac $mac_local]

    # Configure OAM port parameters
    if {![port isValidFeature $ch $ca $po portFeatureEthernetOAM]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Port $port_handle does not \
                support Ethernet OAM."
        return $returnList
    }

    debug "oamPort setDefault"
    oamPort setDefault
    debug "oamPort config -enable          $::true"
    oamPort config -enable          $::true
    debug "oamPort config -macAddress      $mac_local"
    oamPort config -macAddress      $mac_local
    debug "oamPort config -maxOamPduSize   $size"
    oamPort config -maxOamPduSize   $size
    debug "oamPort config -enableLinkEvents $link_events"
    oamPort config -enableLinkEvents $link_events
    if {[info exists oui_value]} {
        debug "oamPort config -oui [scan $oui_value {%2s%2s%2s}]"
        oamPort config -oui [scan $oui_value {%2s%2s%2s}]
    }
    if {[info exists vsi_value]} {
        debug "oamPort config -vendorSpecificInformation [scan $vsi_value {%2s%2s%2s%2s}]"
        oamPort config -vendorSpecificInformation [scan $vsi_value {%2s%2s%2s%2s}]
    }
    if {[info exists idle_timer]} {
        debug "oamPort config -idleTimer $idle_timer"
        oamPort config -idleTimer $idle_timer
    }
    if {[info exists enable_optional_tlv]} {
        debug "oamPort config -enableOptionalTlv $enable_optional_tlv"
        oamPort config -enableOptionalTlv $enable_optional_tlv
    }
    if {[info exists enable_loopback]} {
        debug "oamPort config -enableLoopback $enable_loopback"
        oamPort config -enableLoopback $enable_loopback
    }
    if {[info exists tlv_type]} {
        debug "oamPort config -optionalTlvType $tlv_type"
        oamPort config -optionalTlvType 0x$tlv_type
    }
    if {[info exists tlv_value]} {
        debug "oamPort config -optionalTlvValue $tlv_value"
        oamPort config -optionalTlvValue $tlv_value
    }
    debug "oamPort set $ch $ca $po"
    if {[oamPort set $ch $ca $po]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed to configure Ethernet OAM port \
                parameters. $::ixErrorInfo"
        return $returnList
    }
    
    if {$oampdu_type != "none"} {
        # Register unique stream_id for EFM stream
        set stream_id 1
        while {[stream get $ch $ca $po $stream_id] == $::TCL_OK} {
            incr stream_id
        }
        
        if {[array names ::ixia::pgid_to_stream] == -1} {
            set current_streamid 0
        } else {
            incr current_streamid
        }
        
        set pgid_to_stream($current_streamid) $ch,$ca,$po,$stream_id
    }
    
    if {$oampdu_type == "information" || $oampdu_type == "info_and_event"} {
        
        keylset returnList information_oampdu_id $current_streamid
        
        # Configure Information OAMPDU stream
        set counter_value [::ixia::update_efm_counters -port_handle  $port_handle \
                                                    -action       increment    \
                                                    -counter_type information  ]
        
        debug "stream setDefault"
        stream setDefault
        
        debug "protocol setDefault"
        protocol setDefault
        debug "protocol config -enableOAM true"
        protocol config -enableOAM true
        
        debug "stream config -name         \"Information OAMPDU\""
        stream config -name         "Information OAMPDU"
        debug "stream config -enable       true"
        stream config -enable       true
        
        if {$size < $min_frame_size_info} {
            puts "WARNING: Max OAMPDU size configured with parameters -size $size is smaller \
                    than minimum frame size $min_frame_size_info. Information OAMPDU packet \
                    will be truncated."
        }
        
        if {$length_mode == "fixed"} {
            debug "stream config -frameSizeType    $::sizeFixed"
            stream config -frameSizeType    $::sizeFixed
            debug "stream config -framesize    $size"
            stream config -framesize    $size
        } else {
            debug "stream config -frameSizeType    $::sizeRandom"
            stream config -frameSizeType    $::sizeRandom
            debug "stream config -frameSizeMAX    $size"
            stream config -frameSizeMAX    $size
            
            if {$size < $min_frame_size_info} {
                debug "stream config -frameSizeMIN    $size"
                stream config -frameSizeMIN    $size
            } else {
                debug "stream config -frameSizeMIN    $min_frame_size_info"
                stream config -frameSizeMIN    $min_frame_size_info
            }
        }
        
        
        
        debug "stream config -dma    $::contBurst"
        stream config -dma    $::contBurst
        debug "stream config -enableIbg    1"
        stream config -enableIbg    1
        debug "stream config -gapUnit      $::gapSeconds"
        stream config -gapUnit      $::gapSeconds
        debug "stream config -ibg          1"
        stream config -ibg          1
    #     debug "stream config -framesize    $size"
    #     stream config -framesize    $size
        
        debug "stream config -sa           $mac_local"
        stream config -sa           $mac_local
        debug "stream config -percentPacketRate    1"
        stream config -percentPacketRate    1
        
        debug "oamHeader setDefault"
        oamHeader setDefault
        debug "oamHeader config -flags \[expr $critical_event|$dying_gasp|$link_fault|$::oamFlagLocalStable|$::oamFlagRemoteStable\]"
        oamHeader config -flags [expr $critical_event|$dying_gasp|$link_fault|$::oamFlagLocalStable|$::oamFlagRemoteStable]
        debug "oamHeader config -code $::oamCodeInformation"
        oamHeader config -code $::oamCodeInformation
        
        debug "oamInformation clearAllTlvs"
        oamInformation clearAllTlvs
        debug "oamLocalInformationTlv setDefault"
        oamLocalInformationTlv setDefault
        debug "oamLocalInformationTlv config -enableLinkEvents         $link_events"
        oamLocalInformationTlv config -enableLinkEvents         $link_events
        debug "oamLocalInformationTlv config -enableVariableRetrieval  $variable_retrieval"
        oamLocalInformationTlv config -enableVariableRetrieval  $variable_retrieval
        debug "oamLocalInformationTlv config -maxPduSize               $size"
        oamLocalInformationTlv config -maxPduSize               $size
        debug "oamLocalInformationTlv config -revision $counter_value"
        oamLocalInformationTlv config -revision $counter_value
        if {[info exists local_information_oui_value]} {
            debug "oamLocalInformationTlv config -oui [scan $local_information_oui_value {%2s%2s%2s}]"
            oamLocalInformationTlv config -oui [scan $local_information_oui_value {%2s%2s%2s}]
        }
        if {[info exists local_information_vsi_value]} {
            # IxExplorer shows that nibbles were added in reversed order so we reverse them
            # once more in order to set them as requested
            scan $local_information_vsi_value {%2s%2s%2s%2s} lvi1 lvi2 lvi3 lvi4
            debug "oamLocalInformationTlv config -vendorSpecificInformation [list $lvi4 $lvi3 $lvi2 $lvi1]"
            oamLocalInformationTlv config -vendorSpecificInformation [list $lvi4 $lvi3 $lvi2 $lvi1]
        }
        
        debug "oamInformation addTlv oamInformationLocalInfo"
        if {[oamInformation addTlv oamInformationLocalInfo]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Error adding OAMPDU\
                    Local Information TLV. $::ixErrorInfo"
            return $returnList
        }
        
        debug "oamRemoteInformationTlv setDefault"
        oamRemoteInformationTlv setDefault
        debug "oamRemoteInformationTlv config -enableLinkEvents         $link_events"
        oamRemoteInformationTlv config -enableLinkEvents         $link_events
        debug "oamRemoteInformationTlv config -enableVariableRetrieval  $variable_retrieval"
        oamRemoteInformationTlv config -enableVariableRetrieval  $variable_retrieval
        debug "oamRemoteInformationTlv config -maxPduSize               $size"
        oamRemoteInformationTlv config -maxPduSize               $size
        debug "oamRemoteInformationTlv config -revision $counter_value"
        oamRemoteInformationTlv config -revision $counter_value
        if {[info exists remote_information_oui_value]} {
            debug "oamRemoteInformationTlv config -oui [scan $remote_information_oui_value {%2s%2s%2s}]"
            oamRemoteInformationTlv config -oui [scan $remote_information_oui_value {%2s%2s%2s}]
        }
        if {[info exists remote_information_vsi_value]} {
            # IxExplorer shows that nibbles were added in reversed order so we reverse them
            # once more in order to set them as requested
            scan $remote_information_vsi_value {%2s%2s%2s%2s} rvi1 rvi2 rvi3 rvi4
            debug "oamRemoteInformationTlv config -vendorSpecificInformation [list $rvi4 $rvi3 $rvi2 $rvi1]"
            oamRemoteInformationTlv config -vendorSpecificInformation [list $rvi4 $rvi3 $rvi2 $rvi1]
        }
        
        debug "oamInformation addTlv oamInformationRemoteInfo"
        if {[oamInformation addTlv oamInformationRemoteInfo]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Error adding OAMPDU\
                    Remote Information TLV. $::ixErrorInfo"
            return $returnList
        }
        
        debug "oamInformation addTlv oamInformationEndOfTlv"
        if {[oamInformation addTlv oamInformationEndOfTlv]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Error adding OAMPDU\
                    End of TLV. $::ixErrorInfo"
            return $returnList
        }
        
        debug "oamHeader set $ch $ca $po"
        if {[oamHeader set $ch $ca $po]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Error adding OAMPDU\
                    Information TLV. $::ixErrorInfo"
            return $returnList
        }
        
        debug "stream set $ch $ca $po $stream_id"
        if {[stream set $ch $ca $po $stream_id]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Error adding OAMPDU\
                    Information TLV. $::ixErrorInfo"
            return $returnList
        }
    }    
    
    if {$oampdu_type == "event_notification" || $oampdu_type == "info_and_event"} {
        if {$add_frame_tlv || $add_frame_period_tlv || $add_frame_summary_tlv || $add_symbol_period_tlv} {
            # Configure EventNotification OAMPDU stream
            
            if {$oampdu_type == "info_and_event"} {
                # Register unique stream_id for EFM stream
                incr stream_id
                incr current_streamid
                set pgid_to_stream($current_streamid) $ch,$ca,$po,$stream_id
            } else {
                
                debug "protocol setDefault"
                protocol setDefault
                debug "protocol config -enableOAM true"
                protocol config -enableOAM true
                
            }
            
            keylset returnList event_notification_oampdu_id $current_streamid
            
            debug "stream setDefault"
            stream setDefault
            debug "stream config -name         \"Event Notification OAMPDU\""
            stream config -name         "Event Notification OAMPDU"
            debug "stream config -enable       true"
            stream config -enable       true
            
            if {$length_mode == "fixed"} {
                debug "stream config -frameSizeType    $::sizeFixed"
                stream config -frameSizeType    $::sizeFixed
                debug "stream config -framesize    $size"
                stream config -framesize    $size
            } else {
                debug "stream config -frameSizeType    $::sizeRandom"
                stream config -frameSizeType    $::sizeRandom
                debug "stream config -frameSizeMAX    $size"
                stream config -frameSizeMAX    $size
            }
    
            debug "stream config -dma    $::contBurst"
            stream config -dma    $::contBurst
            debug "stream config -enableIbg    1"
            stream config -enableIbg    1
            debug "stream config -gapUnit      $::gapSeconds"
            stream config -gapUnit      $::gapSeconds
            debug "stream config -ibg          1"
            stream config -ibg          1
            
            debug "stream config -sa           $mac_local"
            stream config -sa           $mac_local
            debug "stream config -percentPacketRate    1"
            stream config -percentPacketRate    1
            
            debug "oamHeader setDefault"
            oamHeader setDefault
            debug "oamHeader config -flags \[expr $critical_event|$dying_gasp|$link_fault|$::oamFlagLocalStable|$::oamFlagRemoteStable\]"
            oamHeader config -flags [expr $critical_event|$dying_gasp|$link_fault|$::oamFlagLocalStable|$::oamFlagRemoteStable]
            debug "oamHeader config -code $::oamCodeEventNotification"
            oamHeader config -code $::oamCodeEventNotification
            
            debug "oamEventNotification setDefault"
            oamEventNotification setDefault
            debug "oamEventNotification clearAllTlvs"
            oamEventNotification clearAllTlvs
            
            set event_notification_tlv_types {
                frame
                frame_period
                frame_summary
                symbol_period
            }
            
            if {$sequence_id_step > 0} {
                # Configure UDF1 for sequence_id to increment per packet
                udf setDefault
                udf config -enable          true
                udf config -offset          18
                udf config -udfSize         16
                udf config -counterMode     udfCounterMode
                udf config -continuousCount true
                udf config -initval         [format %x $sequence_id]
                udf config -step            $sequence_id_step
                if [udf set 1] {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Error adding Event\
                            Notification OAMPDU. Failed to configure sequence id.\
                            $::ixErrorInfo"
                    return $returnList
                }
            } else {
                # Only one sequence_id. Use it in sequence id tcl efm property
                oamEventNotification config -sequenceNumber $sequence_id
            }
            
            if {$add_frame_tlv} {
                incr min_frame_size_en $frame_size_array(en_err_frame_tlv)
                debug "oamFrameTlv setDefault"
                oamFrameTlv setDefault
                debug "oamFrameTlv config -frames        $error_frame_count"
                oamFrameTlv config -frames        $error_frame_count
                debug "oamFrameTlv config -window        $error_frame_window"
                oamFrameTlv config -window        $error_frame_window
                debug "oamFrameTlv config -threshold     $error_frame_threshold"
                oamFrameTlv config -threshold     $error_frame_threshold
                
                set counter_value [::ixia::update_efm_counters -port_handle          $port_handle \
                                                            -action               increment    \
                                                            -counter_type         event_frame  \
                                                            -event_counter_target event_total  ]
                debug "oamFrameTlv config -eventRunningTotal     $counter_value"
                oamFrameTlv config -eventRunningTotal     $counter_value
                
                set counter_value [::ixia::update_efm_counters -port_handle          $port_handle \
                                                            -action               increment    \
                                                            -counter_type         event_frame  \
                                                            -event_counter_target error_total  \
                                                            -step                 $error_frame_count]
                debug "oamFrameTlv config -errorRunningTotal    $counter_value"
                oamFrameTlv config -errorRunningTotal     $counter_value
                debug "oamEventNotification addTlv oamEventNotificationFrame"
                if {[oamEventNotification addTlv oamEventNotificationFrame]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Error adding Event\
                            Notification OAMPDU Frame TLV. $::ixErrorInfo"
                    return $returnList
                }
            }
            
            if {$add_frame_period_tlv} {
                incr min_frame_size_en $frame_size_array(en_err_frame_period_tlv)
                debug "oamFramePeriodTlv setDefault"
                oamFramePeriodTlv setDefault
                debug "oamFramePeriodTlv config -frames        $error_frame_period_count"
                oamFramePeriodTlv config -frames        $error_frame_period_count
                debug "oamFramePeriodTlv config -window        $error_frame_period_window"
                oamFramePeriodTlv config -window        $error_frame_period_window
                debug "oamFramePeriodTlv config -threshold     $error_frame_period_threshold"
                oamFramePeriodTlv config -threshold     $error_frame_period_threshold
                set counter_value [::ixia::update_efm_counters -port_handle          $port_handle \
                                                            -action               increment    \
                                                            -counter_type         event_frame_period  \
                                                            -event_counter_target event_total  ]
                debug "oamFramePeriodTlv config -eventRunningTotal     $counter_value"
                oamFramePeriodTlv config -eventRunningTotal     $counter_value
                
                set counter_value [::ixia::update_efm_counters -port_handle          $port_handle \
                                                            -action               increment    \
                                                            -counter_type         event_frame_period  \
                                                            -event_counter_target error_total  \
                                                            -step                 $error_frame_period_count]
                debug "oamFramePeriodTlv config -errorRunningTotal    $counter_value"
                oamFramePeriodTlv config -errorRunningTotal     $counter_value
                
                debug "oamEventNotification addTlv oamEventNotificationFramePeriod"
                if {[oamEventNotification addTlv oamEventNotificationFramePeriod]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Error adding Event\
                            Notification OAMPDU Frame Period TLV. $::ixErrorInfo"
                    return $returnList
                }
            }
            
            if {$add_frame_summary_tlv} {
                incr min_frame_size_en $frame_size_array(en_err_frame_seconds_tlv)
                debug "oamSummaryTlv setDefault"
                oamSummaryTlv setDefault
                debug "oamSummaryTlv config -frameSeconds  $error_frame_summary_count"
                oamSummaryTlv config -frameSeconds  $error_frame_summary_count
                debug "oamSummaryTlv config -window        $error_frame_summary_window"
                oamSummaryTlv config -window        $error_frame_summary_window
                debug "oamSummaryTlv config -threshold     $error_frame_summary_threshold"
                oamSummaryTlv config -threshold     $error_frame_summary_threshold
                
                set counter_value [::ixia::update_efm_counters -port_handle          $port_handle \
                                                            -action               increment    \
                                                            -counter_type         event_frame_summary  \
                                                            -event_counter_target event_total  ]
                debug "oamSummaryTlv config -eventRunningTotal     $counter_value"
                oamSummaryTlv config -eventRunningTotal     $counter_value
                
                set counter_value [::ixia::update_efm_counters -port_handle          $port_handle \
                                                            -action               increment    \
                                                            -counter_type         event_frame_summary  \
                                                            -event_counter_target error_total  \
                                                            -step                 $error_frame_summary_count]
                debug "oamSummaryTlv config -errorRunningTotal    $counter_value"
                oamSummaryTlv config -errorRunningTotal     $counter_value
                
                debug "oamEventNotification addTlv oamEventNotificationSummary"
                if {[oamEventNotification addTlv oamEventNotificationSummary]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Error adding Event\
                            Notification OAMPDU Frame Summary TLV. $::ixErrorInfo"
                    return $returnList
                }
            }
            
            if {$add_symbol_period_tlv} {
                incr min_frame_size_en $frame_size_array(en_err_symbol_period_tlv)
                debug "oamSymbolPeriodTlv setDefault"
                oamSymbolPeriodTlv setDefault
                debug "oamSymbolPeriodTlv config -symbols      $error_symbol_period_count"
                oamSymbolPeriodTlv config -symbols      $error_symbol_period_count
                debug "oamSymbolPeriodTlv config -window       $error_symbol_period_window"
                oamSymbolPeriodTlv config -window       $error_symbol_period_window
                debug "oamSymbolPeriodTlv config -threshold    $error_symbol_period_threshold"
                oamSymbolPeriodTlv config -threshold    $error_symbol_period_threshold
                
                set counter_value [::ixia::update_efm_counters -port_handle          $port_handle \
                                                            -action               increment    \
                                                            -counter_type         event_symbol_period  \
                                                            -event_counter_target event_total  ]
                debug "oamSymbolPeriodTlv config -eventRunningTotal     $counter_value"
                oamSymbolPeriodTlv config -eventRunningTotal     $counter_value
                
                set counter_value [::ixia::update_efm_counters -port_handle          $port_handle \
                                                            -action               increment    \
                                                            -counter_type         event_symbol_period  \
                                                            -event_counter_target error_total  \
                                                            -step                 $error_symbol_period_count]
                debug "oamSymbolPeriodTlv config -errorRunningTotal    $counter_value"
                oamSymbolPeriodTlv config -errorRunningTotal     $counter_value
                
                debug "oamEventNotification addTlv oamEventNotificationSymbol"
                if {[oamEventNotification addTlv oamEventNotificationSymbol]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Error adding Event\
                            Notification OAMPDU Symbol Period TLV. $::ixErrorInfo"
                    return $returnList
                }
            }
            
            debug "oamEventNotification addTlv oamEventNotificationEndOfTlv"
            if {[oamEventNotification addTlv oamEventNotificationEndOfTlv]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error adding OAMPDU\
                        Event Notification End of TLV. $::ixErrorInfo"
                return $returnList
            }
            
            debug "oamHeader set $ch $ca $po"
            if {[oamHeader set $ch $ca $po]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error adding OAMPDU\
                        Event Notification TLV. $::ixErrorInfo"
                return $returnList
            }
            
            if {$min_frame_size_en < 64} {
                set min_frame_size_en 64
            }
            if {$size < $min_frame_size_en} {
                puts "WARNING: Max OAMPDU size configured with parameter -size $size is smaller \
                        than minimum frame size $min_frame_size_en. Event Notification OAMPDU \
                        packet will be truncated."
            }
            
            if {$length_mode == "random"} {
                if {$size < $min_frame_size_en} {
                    debug "stream config -frameSizeMIN    $size"
                    stream config -frameSizeMIN    $size
                } else {
                    debug "stream config -frameSizeMIN    $min_frame_size_en"
                    stream config -frameSizeMIN    $min_frame_size_en
                }
            }
            
            debug "stream set $ch $ca $po $stream_id"
            if {[stream set $ch $ca $po $stream_id]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error adding OAMPDU\
                        Event Notification TLV. $::ixErrorInfo"
                return $returnList
            }
        }
    }
    
    ::ixia::addPortToWrite $port_handle
    
    set retCode [::ixia::writePortListConfig]
    if {[keylget retCode status] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Call to\
                ::ixia::writePortListConfig failed. \
                [keylget retCode log]"
        return $returnList
    }
 
    return $returnList
}


proc ::ixia::emulation_efm_control {args} {
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
                \{::ixia::emulation_efm_control $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    keylset returnList status $::SUCCESS

    ::ixia::utrackerLog $procName $args

    set man_args {
        -port_handle REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -action      CHOICES start stop start_event stop_event restart_discovery
                     CHOICES send_loopback send_org_specific_pdu send_variable_request
    }
    
    set opt_args {
        -api_used                       CHOICES ixnetwork ixprotocol ixos
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg"
        return $returnList
    }
    
    if {[info exists api_used]} {
    
        switch $api_used {
            "ixnetwork" {
            
                if {![info exists new_ixnetwork_api] || !$new_ixnetwork_api} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            parameter api_used cannot be configured to $api_used\
                            if the HLTSET used does not load IxNetwork Tcl API."
                    return $returnList
                }
    
                set returnList [::ixia::ixnetwork_efm_control $args $man_args $opt_args]
            
                if {[keylget returnList status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget returnList log]"
                }
                return $returnList
            }
            "ixprotocol" {
            
                if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            parameter api_used cannot be configured to $api_used\
                            if the HLTSET used does not load IxProtocol Tcl API."
                    return $returnList
                }
    
                set returnList [::ixia::ixprotocol_efm_control $args $man_args $opt_args]
            
                if {[keylget returnList status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget returnList log]"
                }
                return $returnList
            }
            "ixos" {
                # Use the implementation with IxOS Tcl API from below.
            }
        }
        
    } else {

        if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        
            set returnList [::ixia::ixnetwork_efm_control $args $man_args $opt_args]
        
            if {[keylget returnList status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget returnList log]"
            }
            return $returnList
            
        }
        
    }
    
    
    foreach oam_port $port_handle {
        foreach {ch ca po} [split $oam_port /] {}
        
        if {![port isValidFeature $ch $ca $po portFeatureEthernetOAM]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Port $port_handle does not \
                    support Ethernet OAM."
            return $returnList
        }
        
        # Enable EOAM stats
        debug "stat get statAllStats $ch $ca $po"
        if {[stat get statAllStats $ch $ca $po]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to enable Ethernet OAM
                    statistics. $::ixErrorInfo"
            return $returnList
        }
        
        debug "oamPort get $ch $ca $po"
        if {[oamPort get $ch $ca $po]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to get Ethernet OAM port \
                    configuration. $::ixErrorInfo"
            return $returnList
        }
      
        if {$action == "start"} {
            debug "oamPort config -enable          $::true"
            oamPort config -enable          $::true
            debug "stat config -enableEthernetOamStats 1"
            stat config -enableEthernetOamStats 1
        } else {
            debug "oamPort config -enable          $::false"
            oamPort config -enable          $::false
            debug "stat config -enableEthernetOamStats 0"
            stat config -enableEthernetOamStats 0
            
            ::ixia::update_efm_counters -port_handle $oam_port -action reset_all
        }
        
        debug "oamPort set $ch $ca $po"
        if {[oamPort set $ch $ca $po]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to configure Ethernet OAM port \
                    parameters. $::ixErrorInfo"
            return $returnList
        }
        
        debug "stat set $ch $ca $po"
        if {[stat set $ch $ca $po]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to enable Ethernet OAM
                    statistics. $::ixErrorInfo"
            return $returnList
        }
                
        ::ixia::addPortToWrite $oam_port
    }
    
    set retCode [::ixia::writePortListConfig]
    if {[keylget retCode status] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Call to\
                ::ixia::writePortListConfig failed. \
                [keylget retCode log]"
        return $returnList
    }
    
    return $returnList
}


proc ::ixia::emulation_efm_org_var_config {args} {
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
                \{::ixia::emulation_efm_org_var_config $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    keylset returnList status $::SUCCESS

    ::ixia::utrackerLog $procName $args

    set man_args {
        -mode                        CHOICES create modify enable disable remove
    }
    
    set opt_args {
        -port_handle                 REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -count                       NUMERIC
                                     DEFAULT 1
        -handle                      ANY
        -os_info_tlv_oui             REGEXP ^0x[0-9a-fA-F]{6}$
                                     DEFAULT 0x000000
        -os_info_tlv_oui_step        REGEXP ^0x[0-9a-fA-F]{6}$
                                     DEFAULT 0x000001
        -os_info_tlv_value           REGEXP ^0x[0-9a-fA-F]+$
                                     DEFAULT 0x00
        -os_info_tlv_value_step      REGEXP ^0x[0-9a-fA-F]+$
                                     DEFAULT 0x00
        -reset
        -type                        CHOICES organization_specific_info_tlv
                                     CHOICES variable_response_database
                                     CHOICES variable_descriptors
                                     DEFAULT organization_specific_info_tlv
        -variable_branch             REGEXP ^0x[0-9a-fA-F]{2}$
                                     DEFAULT 0x00
        -variable_branch_step        REGEXP ^0x[0-9a-fA-F]{2}$
                                     DEFAULT 0x01
        -variable_indication         CHOICES 0 1
                                     DEFAULT 0
        -variable_leaf               REGEXP ^0x[0-9a-fA-F]{2,4}$
                                     DEFAULT 0x00
        -variable_leaf_step          REGEXP ^0x[0-9a-fA-F]{2,4}$
                                     DEFAULT 0x01
        -variable_value              REGEXP ^0x[0-9a-fA-F]+$
                                     DEFAULT 0x00
        -variable_value_step         REGEXP ^0x[0-9a-fA-F]+$
                                     DEFAULT 0x00
        -variable_width              RANGE 1-128
                                     DEFAULT 1
        -variable_width_step         RANGE 0-127
                                     DEFAULT 1
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_efm_org_var_config $args $man_args $opt_args]
    } else {
        set returnList [::ixia::ixprotocol_efm_org_var_config $args $man_args $opt_args]
    }
    
    if {[keylget returnList status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                [keylget returnList log]"
    }
    
    return $returnList
}


proc ::ixia::emulation_efm_stat {args} {
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
                \{::ixia::emulation_efm_stat $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    keylset returnList status $::SUCCESS

    ::ixia::utrackerLog $procName $args

    set man_args {
        -port_handle REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -action      CHOICES get reset
    }
    set opt_args {
        -api_used           CHOICES ixnetwork ixprotocol ixos
        -capture_file       ANY
        -skip_capture_stats        
    }

        if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg"
        return $returnList
    }
    
    if {[info exists api_used]} {
    
        switch $api_used {
            "ixnetwork" {
            
                if {![info exists new_ixnetwork_api] || !$new_ixnetwork_api} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            parameter api_used cannot be configured to $api_used\
                            if the HLTSET used does not load IxNetwork Tcl API."
                    return $returnList
                }
    
                set returnList [::ixia::ixnetwork_efm_stat $args $man_args $opt_args]
            
                if {[keylget returnList status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget returnList log]"
                }
                return $returnList
            }
            "ixprotocol" {
            
                if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            parameter api_used cannot be configured to $api_used\
                            if the HLTSET used does not load IxProtocol Tcl API."
                    return $returnList
                }
    
                set returnList [::ixia::ixprotocol_efm_stat $args $man_args $opt_args]
            
                if {[keylget returnList status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget returnList log]"
                }
                return $returnList
            }
            "ixos" {
                # Use the implementation with IxOS Tcl API from below.
            }
        }
        
    } else {

        if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        
            set returnList [::ixia::ixnetwork_efm_stat $args $man_args $opt_args]
        
            if {[keylget returnList status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget returnList log]"
            }
            return $returnList
            
        }
        
    }
    
    foreach {ch ca po} [split $port_handle /] {}
    
    if {$action == "reset"} {
        set control_status [::ixia::traffic_control \
                -port_handle $port_handle           \
                -action      clear_stats            ]
        if {[keylget control_status status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: [keylget control_status log]"
            return $returnList
        }
    } elseif {$action == "get"} {
        keylset returnList port_handle $port_handle
        
        # Get Ethernet OAM port remote status
        set mac_remote_stats {
            mac_remote                      sourceMacAddress
            oam_mode                        mode
            unidir_enabled                  unidirectionalSupport
            remote_loopback_enabled         loopback
            link_events_enabled             linkEvents
            variable_retrieval_enabled      mibVars
            oampdu_size                     pduSize
            oui_value                       oui
            vsi_value                       vendorSpecificInformation
        }
        
        if {[oamStatus get $ch $ca $po]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to retrieve OAM\
                    port statistics. Verify that OAM is enabled on\
                    port $port_handle. $::ixErrorInfo"
            return $returnList
        }
        
        oamStatus getRemoteStatus
        
        foreach {hlt_stat oam_stat} $mac_remote_stats {
            set stat_value [oamStatus cget -$oam_stat]
            keylset returnList statistics.$hlt_stat $stat_value
        }
        
        # Get the number of OAMPDUs received
        if {[stat get statAllStats $ch $ca $po]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed get EFM OAMPDU
                    statistics. $::ixErrorInfo"
            return $returnList
        }
        
        set oampdu_types {
            information_tx              ethernetOAMInformationPDUsSent
            information_rx              ethernetOAMInformationPDUsReceived
            event_notification_rx       ethernetOAMEventNotificationPDUsReceived
            loopback_control_rx         ethernetOAMLoopbackControlPDUsReceived
            organization_rx             ethernetOAMOrgPDUsReceived
            variable_request_rx         ethernetOAMVariableRequestPDUsReceived
            variable_response_rx        ethernetOAMVariableResponsePDUsReceived
            unsupported_rx              ethernetOAMUnsupportedPDUsReceived
        }
        
        set oampdu_total_count 0
        foreach {hlt_stat oam_stat} $oampdu_types {
            set stat_value [stat cget -$oam_stat]
            keylset returnList statistics.oampdu_count.$hlt_stat $stat_value
            if {$hlt_stat != "information_tx"} {
                incr oampdu_total_count $stat_value
            }
        }
        keylset returnList statistics.oampdu_count.total_rx $oampdu_total_count
        
        # Get statistic values for Event Notification TLVs
        set tlv_alarms {
            errored_symbol_period_events                x
            errored_frame_events                        x
            errored_frame_period_events                 x
            errored_frame_seconds_summary_events        x
        }
        
        if {![info exists skip_capture_stats]} {
            if {[info exists capture_file]} {
                # Import capture file
                if {![file exists \{$capture_file\}]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Capture file $capture_file\
                            does not exists. $::ixErrorInfo"
                    return $returnList
                }
                
                if {[captureBuffer import \{$capture_file\} $ch $ca $po]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to import capture\
                            file $capture_file. Verify that capture file is a valid Ixia\
                            capture. $::ixErrorInfo"
                    return $returnList
                }
            }
    
            # Get capture buffer from port
            if {[capture get $ch $ca $po]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to get capture\
                        from port $port_handle. $::ixErrorInfo."
                return $returnList
            }
            
            set num_cap_frames [capture cget -nPackets] 
            
            if {$num_cap_frames == 0} {
                # No frames in capture. Set keyed stats to N/A
                foreach {hlt_tlv_alarm ixos_tlv_alarm} $tlv_alarms {
                    keylset returnList statistics.alarms.$hlt_tlv_alarm "N/A"
                }
                return $returnList
            }
            
            if {[captureBuffer get $ch $ca $po 1 $num_cap_frames]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to get captureBuffer\
                        from port $port_handle. $::ixErrorInfo."
                return $returnList
            }
            
            # Initialize keyed stats (tlv event counters)
            foreach {hlt_tlv_alarm ixos_tlv_alarm} $tlv_alarms {
                set ${hlt_tlv_alarm}_count 0
            }
            
            # Parse capture and count tlv events
            for {set frame 1} {$frame <= $num_cap_frames} {incr frame} {
                captureBuffer getframe $frame
                set capframe [captureBuffer cget -frame]
                if {[oamHeader decode $capframe $ch $ca $po]} {
                    # Not an oamHeader frame
                    continue
                }
                
                if {[oamHeader cget -code] != $::oamCodeEventNotification} {
                    continue
                }
                
                if {[oamEventNotification getFirstTlv]} {
                    # There are no TLV in this frame
                    continue
                }
                
                set current_tlv_type [oamEventNotification cget -currentTlvType]
                
                if {$current_tlv_type == $::oamEventNotificationSymbol} {
                    incr errored_symbol_period_events_count
                } elseif {$current_tlv_type == $::oamEventNotificationFrame} {
                    incr errored_frame_events_count
                } elseif {$current_tlv_type == $::oamEventNotificationFramePeriod} {
                    incr errored_frame_period_events_count
                } elseif {$current_tlv_type == $::oamEventNotificationSummary} {
                    incr errored_frame_seconds_summary_events_count
                }
               
                while {1} {
                    if {[oamEventNotification getNextTlv]} {
                        # There are no more TLVs in this OAMPDU
                        break
                    }

                    set current_tlv_type [oamEventNotification cget -currentTlvType]
                
                    if {$current_tlv_type == $::oamEventNotificationSymbol} {
                        incr errored_symbol_period_events_count
                    } elseif {$current_tlv_type == $::oamEventNotificationFrame} {
                        incr errored_frame_events_count
                    } elseif {$current_tlv_type == $::oamEventNotificationFramePeriod} {
                        incr errored_frame_period_events_count
                    } elseif {$current_tlv_type == $::oamEventNotificationSummary} {
                        incr errored_frame_seconds_summary_events_count
                    }
                }
            }
            
            # Set keyed values
            foreach {hlt_tlv_alarm ixos_tlv_alarm} $tlv_alarms {
                keylset returnList statistics.alarms.$hlt_tlv_alarm [set ${hlt_tlv_alarm}_count]
            }
        }
    }
    
    return $returnList
}
