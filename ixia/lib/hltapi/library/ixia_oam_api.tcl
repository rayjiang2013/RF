##Library Header
# $Id: $
# Copyright © 2003-2009 by IXIA.
# All Rights Reserved.
#
# Name:
#    ixia_cfm_api.tcl
#
# Purpose:
#    A script development library containing CFM APIs for test automation with 
#    the Ixia chassis. 
#
# Author:
#    Mircea Hasegan
#
# Usage:
#    package req Ixia
#
# Description:
#    The procedures contained within this library include:
#        emulation_oam_config_topology
#        emulation_oam_config_msg
#        emulation_oam_control
#        emulation_oam_info
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


proc ::ixia::emulation_oam_config_topology {args} {
	variable executeOnTclServer
    
    variable mep_handles_array
    variable cfm_vlan_handles_array
    variable cfm_mdlevel_handles_array
    variable cfm_message_handles_array
    variable cfm_topology_current_id
    
    variable md_level_handles
    variable mip_handles
    variable mep_handles
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::emulation_oam_config_topology $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
        } else {
            set retData $retValue
        }
        
        if {![catch {keylget retData traffic_handles_array} keyed_a_name]} {
            if {![info exists ::ixTclSvrHandle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Not connected to TclServer."
                return $returnList
            }
            array set $keyed_a_name [eval clientSend $::ixTclSvrHandle \
                \{array get $keyed_a_name\}]
        }
        
        return $retData
    }
    
    ::ixia::utrackerLog $procName $args
    
    keylset returnList status $::SUCCESS
    
    # Arguments
    set man_args {
         -mode                        CHOICES   create modify reset
    }
    set opt_args {
         -port_handle                 REGEXP    ^[0-9]+/[0-9]+/[0-9]+$
         -count                       NUMERIC
                                      DEFAULT   1
         -encap                       CHOICES   ethernet_ii snap
                                      DEFAULT   ethernet_ii
         -mac_local                   ANY
         -mac_local_incr_mode         CHOICES   none increment decrement list random
                                      DEFAULT   none
         -mac_local_step              ANY
                                      DEFAULT   00:00:00:00:00:01
         -mac_local_repeat            NUMERIC
                                      DEFAULT   1
         -mac_local_list              ANY
         -vlan_outer_id               RANGE     0-4095
         -vlan_id_outer_step          RANGE     0-4095
                                      DEFAULT   1
         -vlan_id_outer_repeat        RANGE     1-4096
                                      DEFAULT   1
         -vlan_outer_ether_type       CHOICES   0x8100 0x88A8 0x9100 0x9200
                                      DEFAULT   0x8100
         -vlan_id                     RANGE     0-4095
                                      DEFAULT   1
         -vlan_id_step                RANGE     0-4095
                                      DEFAULT   1
         -vlan_id_repeat              RANGE     1-4096
                                      DEFAULT   1
         -vlan_ether_type             CHOICES   0x8100 0x88A8 0x9100 0x9200
                                      DEFAULT   0x8100
         -oam_standard                CHOICES   ieee_802.1ag itu-t_y1731
                                      DEFAULT   ieee_802.1ag
         -continuity_check            FLAG
         -continuity_check_interval   CHOICES   3.33ms 10ms 100ms 1s 10s 1min 10min
                                      DEFAULT   1s
         -fault_alarm_interval        CHOICES   1s 1min
                                      DEFAULT   1s
         -fault_alarm_signal          FLAG
         -domain_level                CHOICES   level0 level1 level2 level3
                                      CHOICES   level4 level5 level6 level7
                                      DEFAULT   level0
         -md_level                    RANGE     0-7
                                      DEFAULT   0
         -md_name_format              CHOICES   none domain_name mac_addr
                                      CHOICES   char_str icc_based
                                      DEFAULT   char_str
         -md_name_length              NUMERIC
                                      DEFAULT   7
         -md_name                     ANY
                                      DEFAULT   DEFAULT
         -md_mac                      ANY
                                      DEFAULT   00:00:00:00:00:01
         -md_integer                  RANGE     0-65535
                                      DEFAULT   0
         -short_ma_name_format        CHOICES   primary_vid char_str integer
                                      CHOICES   rfc_2685_vpn_id
                                      DEFAULT   integer
         -short_ma_name_length        NUMERIC
                                      DEFAULT   7
         -short_ma_name_value         ANY
                                      DEFAULT   DEFAULT
         -short_ma_name_step          NUMERIC
                                      DEFAULT   1
         -short_ma_name_repeat        NUMERIC
                                      DEFAULT   1
         -short_ma_name_wildcard      CHOICES   0 1
                                      DEFAULT   0
         -short_ma_name_wc_start      NUMERIC
                                      DEFAULT   0
         -mip_count                   NUMERIC
                                      DEFAULT   1
         -mep_count                   RANGE     1-8192
                                      DEFAULT   1
         -mep_id                      RANGE     1-8192
                                      DEFAULT   1
         -mep_id_incr_mode            CHOICES   none increment decrement list random
                                      DEFAULT   none
         -mep_id_step                 NUMERIC
                                      DEFAULT   1
         -mep_id_repeat               NUMERIC
                                      DEFAULT   1
         -mep_id_list                 NUMERIC
         -bridge_id                   ANY
         -bridge_id_step              ANY
                                      DEFAULT 00:00:00:00:00:01
         -return_method               CHOICES keyed_list keyed_list_or_array array
                                      DEFAULT keyed_list
         -ccdb_expect_conectivity
         -ccdb_mac   
         -ccdb_md_integer
         -ccdb_md_level
         -ccdb_md_mac
         -ccdb_md_name
         -ccdb_md_name_format
         -ccdb_md_name_length
         -ccdb_mep_id
         -ccdb_oam_standard
         -ccdb_short_ma_name_format
         -ccdb_short_ma_name_length
         -ccdb_short_ma_name_value
         -ccdb_vlan_id
         -ccdb_vlan_outer_id
         -continuity_check_burst_delay
         -continuity_check_burst_size
         -continuity_check_mcast_mac_dst
         -continuity_check_remote_defect_indication
         -continuity_check_ucast_mac_dst
         -fault_alarm_locked
         -handle     
         -mac_remote 
         -mac_remote_incr_mode
         -mac_remote_list
         -mac_remote_repeat
         -mac_remote_step
         -mep_port_behavior
         -multiple_levels_handle
         -responder_latency
         -sut_ip_address
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args  -mandatory_args $man_args
    
    # Check to see if a connection to the IxNetwork TCL Server already exists. 
    # If it doesn't, establish it.
    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    
    if {$mode == "modify"} {
            removeDefaultOptionVars $opt_args $args
    }
    
    if {$mode != "create"} {
        if {![info exists handle] && ![info exists port_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When -mode is $mode one of the\
                    -handle or -port_handle parameters must be provided."
            return $returnList
        }
        
        if {[info exists port_handle]} {
            set reset_handles $port_handle
        }
        
        if {[info exists handle]} {
            foreach b_handle $handle {
                foreach {b_handle b_topo_id} [split $b_handle ,] {}
                if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+$} $b_handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Parameter -handle $b_handle is not a valid OAM Bridge handle."
                    return $returnList
                }
                
                if {[ixNet exists $b_handle] == "false" || [ixNet exists $b_handle] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Parameter -handle $b_handle does not exist."
                    return $returnList
                }
                lappend reset_handles $b_handle,$b_topo_id
            }
        }
    }
    
    array set truth {1 true 0 false enable true disable false}
    
    array set cfm_options_map {
        ethernet_ii  ethernet
        snap         llcSnap
        0x8100       0x8100
        0x88A8       0x88a8
        0x9100       0x9100
        0x9200       0x9200
        ieee_802.1ag cfm
        itu-t_y1731  y1731
        3.33ms       3.33msec
        10ms         10msec
        100ms        100msec
        1s           1sec
        10s          10sec
        1min         1min
        10min        10min
        none         noDomainName
        domain_name  domainNameBasedString
        mac_addr     macAddress2OctetInteger
        char_str     characterString
        icc_based    iccBasedFormat
        primary_vid  primaryVid
        integer      2octetInteger
        rfc_2685_vpn_id   rfc2685VpnId
        "8902"       "0x8902"
        "88E6"       "0x88E6"
    }
    
    array set cfm_options_map_bridge {
        1s           oneSec
        1min         oneMin
    }

    
    set global_params {
            enable_optional_tlv_validation      enableOptionalTlvValidation     truth       _none
            receive_ccm                         receiveCcm                      truth       _none
            continuity_check                    sendCcm                         truth       _none
            enabled                             enabled                         truth       _none
        }
    
    set bridge_params {
            fault_alarm_interval                aisInterval                     translate_bridge   _none
            bridge_id                           bridgeId                        mac         _none
            fault_alarm_signal                  enableAis                       truth       _none
            enable_out_of_sequence_detection    enableOutOfSequenceDetection    truth       _none
            ether_type                          etherType                       translate   hex2num
            garbage_collect_time                garbageCollectTime              value       _none
            oam_standard                        operationMode                   translate   _none
            encap                               encapsulation                   translate   _none
            enabled                             enabled                         truth       _none
        }
    
    set mep_params {
                mac_local                           macAddress                          value                   _none
                continuity_check_interval           cciInterval                         translate                 _none
                short_ma_name_format                shortMaNameFormat                   translate                 _none
                tmp_short_ma_name                   shortMaName                         value                     _none
                mep_id                              mepId                               value                   _none
        }
    
    set vlan_params {
            vlan_outer_id               cVlanId         value       _none
            vlan_outer_ether_type       cVlanTpId       translate   _none
            vlan_id                     sVlanId         value       _none
            vlan_ether_type             sVlanTpId       translate   _none
            vlan_type                   type            value       _none
        }
    
    switch -- $mode {
        "create" {
            
            if {![info exists cfm_topology_current_id]} {
                set cfm_topology_current_id 0
            } else {
                incr cfm_topology_current_id
            }
            
            set traffic_handles ""
            
            foreach {ch ca po} [split $port_handle /] {}
            set wc_width [expr $short_ma_name_length - [string length $short_ma_name_value] + 1]
            
            # Check if short_ma_name is ok
            if {[is_default_param_value "short_ma_name_value" $args]} { 
                switch -- $short_ma_name_format {
                    "primary_vid" {
                        set short_ma_name_value 0
                    }
                    "char_str" {
                        # Use default "DEFAULT"
                    }
                    "integer" {
                        set short_ma_name_value 0
                    }
                    "rfc_2685_vpn_id" {
                        set short_ma_name_value "0-0"
                    }
                }
            }
            set tmp_status [oam_short_ma_name_check $short_ma_name_value $short_ma_name_format $short_ma_name_length]
            if {[keylget tmp_status status] != $::SUCCESS} {
                keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                return $tmp_status
            }
            
            if {![info exists mac_local]} {
                set mac_local [get_default_mac $ch $ca $po]
                set mac_local_set_by_default 1
            }
            
            # Determine if the number of MPs ($count) is large enough to create
            # all the MIPs and MEPs necessary for this topology
            if {$domain_level == "level0"} {
                # It's a simple hub&spoke topology
                
                set mip_total_count $mip_count
                set mep_total_count $mep_count
                set levels_total    0
                
            } else {
                # mip_count represents the depth/md level
                # mep_count represents the mip to mep links
                # md_level is the starting maintenance domain level
                # domain_level is the ending mainenance domain level
                regexp {(level)(\d)} $domain_level dummy tmp_string end_level
                if {$md_level > $end_level} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Value of -md_level\
                             $md_level is greater than the value of -domain_level\
                             $domain_level. Topology cannot be generated."
                    return $returnList
                }
                
                set levels_total [mpexpr $end_level - $md_level]
                
                # Example: mip_count 3; mep_count 3; md_level 0; domain_level 1
                # x = ixiaport; i#=mip#; e#=mep#
                # X-i1-i2-i3-E1-i4-i5-i6-E2
                #         ||          \\E6
                #         |\           \E7
                #         |  E8-i7-i8-i9-E9
                #         |           \\E10
                #         \            \E11
                #           E12-i10-i11-i12-E13     
                #                        \\E14
                #                         \E15
                
                # ic = mip_count
                # ec = mep_count
                # lc = domain_level - md_level
                # ic*(ec^0 + ec^1 + .. + ec^lc) -> geometric series
                # ic * (ec^(lc + 1) - 1)/(ec - 1)
                
                if {$mip_count != 0} {
                    if {$mep_count != 1} {
                        set mip_total_count [mpexpr $mip_count * \
                                (pow($mep_count,[expr $levels_total + 1]) - 1)/($mep_count - 1)]
                        set mip_total_count [mpexpr round($mip_total_count)]
                    } else {
                        set mip_total_count [mpexpr $mip_count*($levels_total + 1)]
                    }
                } else {
                    set mip_total_count 0
                }
                
                if {$mep_count != 1} {
                    set mep_total_count [mpexpr (pow($mep_count,[expr $levels_total + 2]) - 1)/($mep_count - 1) - 1]
                    set mep_total_count [mpexpr round($mep_total_count)]
                } else {
                    set mep_total_count [mpexpr $levels_total + 2]
                }
            }
            
#             puts "mip_total_count = $mip_total_count"
#             puts "mep_total_count = $mep_total_count"
            # Add port after connecting to IxNetwork TCL Server
            set retCode [ixNetworkPortAdd $port_handle {} force]
            if {[keylget retCode status] == $::FAILURE} {
                keylset retCode log "ERROR in $procName: [keylget retCode log]"
                return $retCode
            }
        
            set retCode [ixNetworkGetPortObjref $port_handle]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Unable to find the port object reference \
                        associated to the $port_handle port handle -\
                        [keylget retCode log]."
                return $returnList
            }
            
            set vport_objref    [keylget retCode vport_objref]
            set protocol_objref [keylget retCode vport_objref]/protocols/cfm
            
            # Check if protocols are supported
            set retCode [checkProtocols $vport_objref]
            if {[keylget retCode status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Port $port_handle does not support protocol\
                        configuration."
                return $returnList
            }

            # Configure CFM Global parameters
            set ixn_global_args ""
            set enabled 1
            foreach {hlt_param ixn_param p_type p_extensions} $global_params {
                if {[info exists $hlt_param]} {
                    set hlt_param_value [set $hlt_param]

                    switch -- $p_type {
                        value {
                            set ixn_param_value $hlt_param_value
                        }
                        truth {
                            set ixn_param_value $truth($hlt_param_value)
                        }
                        translate {
                            if {[info exists cfm_options_map($hlt_param_value)]} {
                                set ixn_param_value $cfm_options_map($hlt_param_value)
                            } else {
                                set ixn_param_value $hlt_param_value
                            }
                        }
                    }
                    
                    append ixn_global_args "-$ixn_param $ixn_param_value "
                    
                }
                
            }
            
            set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                    $protocol_objref                                        \
                    $ixn_global_args                                        \
                    -commit                                                 \
                ]
                
            if {[keylget tmp_status status] != $::SUCCESS} {
                keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                return $tmp_status
            }
            
            if {![info exists bridge_id]} {
               set bridge_id [get_default_mac $ch $ca $po]
            }
            
            array set bridges_already_configured ""
            foreach bridge_ac [ixNet getList $protocol_objref bridge] {
                set tmp_bid [ixNetworkFormatMac [ixNet getAttribute $bridge_ac -bridgeId]]
                set tmp_bid [string tolower $tmp_bid]
                set bridges_already_configured([ixNet getAttribute $bridge_ac -bridgeId]) $bridge_ac
            }
            
            catch {unset tmp_bid}
            
            set global_idx 0
            set global_mep_idx 0
            for {set bridge_counter 0} {$bridge_counter < $count} {incr bridge_counter} {
                
                set tmp_bid [ixNetworkFormatMac $bridge_id]
                set tmp_bid [string tolower $tmp_bid]
                
                if {[info exists bridges_already_configured($tmp_bid)]} {
                    
                    # If a bridge with this ID already exists use it
                    set bridge_handle $bridges_already_configured($tmp_bid)
                    lappend bridge_handle_list "$bridge_handle,$cfm_topology_current_id"
                    
                    if {[info exists mac_local_set_by_default] && $mac_local_set_by_default} {
                        set tmp_mep_list [ixNet getList $bridge_handle mp]
                        if {$tmp_mep_list != ""} {
                            set tmp_mp_h [lindex $tmp_mep_list end]
                            set mac_local [ixNet getAttribute $tmp_mp_h -macAddress]
                            set mac_local [incrementMacAdd $mac_local]
                            set mac_local [ixNetworkFormatMac $mac_local]
                            catch {unset tmp_mp_h}
                        }
                        catch {unset tmp_mep_list}
                    }
                    
                } else {
                    
                    # Bridge with this ID doesn't exist. Create it
                    
                    # Build Bridge arg list
                    set ixn_bridge_args ""
                    
                    foreach {hlt_param ixn_param p_type extensions} $bridge_params {
                        if {[info exists $hlt_param]} {
        
                            set hlt_param_value [set $hlt_param]
        
                            switch -- $p_type {
                                value {
                                    set ixn_param_value $hlt_param_value
                                }
                                truth {
                                    set ixn_param_value $truth($hlt_param_value)
                                }
                                translate {
                                    if {[info exists cfm_options_map($hlt_param_value)]} {
                                        set ixn_param_value $cfm_options_map($hlt_param_value)
                                    } else {
                                        set ixn_param_value $hlt_param_value
                                    }
                                    
                                    if {$extensions == "hex2num"} {
                                        set ixn_param_value [mpformat %d $ixn_param_value]
                                    }
                                }
                                mac {
                                    if {![isValidMacAddress $hlt_param_value]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: Invalid mac \
                                                address value $hlt_param_value for\
                                                $hlt_param parameter."
                                        return $returnList
                                    }
                                    set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                                }
                                translate_bridge {
                                    if {[info exists cfm_options_map_bridge($hlt_param_value)]} {
                                        set ixn_param_value $cfm_options_map_bridge($hlt_param_value)
                                    } else {
                                        set ixn_param_value $hlt_param_value
                                    }
                                }
                            }
                            
                            append ixn_bridge_args "-$ixn_param $ixn_param_value "
                        }
                    }
                    
                    
                    
                    set tmp_status [::ixia::ixNetworkNodeAdd                        \
                            $protocol_objref                                        \
                            "bridge"                                                \
                            $ixn_bridge_args                                        \
                            -commit                                                 \
                        ]
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                    
                    set bridge_handle [keylget tmp_status node_objref]
                    lappend bridge_handle_list "$bridge_handle,$cfm_topology_current_id"
                    
                    # Create an interface for the bridge
                    set intf_mac_addr $bridge_id
                    
                    set protocol_intf_args [list -count 1 -mac_address $intf_mac_addr -port_handle $port_handle]
           
                    # Create the necessary interfaces
                    set intf_list [eval ixNetworkProtocolIntfCfg \
                            $protocol_intf_args]
                    if {[keylget intf_list status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Unable to create the\
                                protocol interfaces. [keylget intf_list log]"
                        return $returnList
                    }
                    
                    set intf_list [keylget intf_list connected_interfaces]
                    
                    set tmp_int_status [::ixia::ixNetworkNodeAdd                    \
                            $bridge_handle                                          \
                            "interface"                                             \
                            [list -enabled true -interfaceId $intf_list]            \
                            -commit                                                 \
                        ]
                        
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                }
                set bridge_id [incrementMacAdd $bridge_id $bridge_id_step]
                
                # We now have the bridges configured
            
                #################
                ## Create MIPs ##
                #################
                
                set mip_handles ""
                set mep_handles ""
                
                for {set mip_counter 0} {$mip_counter < $mip_total_count} {incr mip_counter; incr global_idx} {
    
                    # create mips
    
                    if {$mac_local_incr_mode == "list"} {
                        if {[llength $mac_local_list] == 0} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: When parameter\
                                    -mac_local_incr_mode is $mac_local_incr_mode, parameter\
                                    -mac_local_list must contain at least one value."
                        }
                        
                        if {[expr $global_idx + 1] > [llength $mac_local_list]} {
                            set mac_local [lindex $mac_local_list end]
                        } else {
                            set mac_local [lindex $mac_local_list $global_idx]
                        }
                    } elseif {$mac_local == "random"} {
                        set mac_local [get_random_mac]
                    }
                    
                    if {![isValidMacAddress $mac_local]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: mac address $mac_local\
                                is not a valid MAC address."
                        return $returnList
                    }
                    
                    set mac_local [ixNetworkFormatMac $mac_local]
                    
                    set mip_args "-macAddress $mac_local"
    
                    set mip_id $mip_counter
                    if {$mip_id > 8192} {
                        set mip_id [mpexpr $mip_id % 8191]
                    }
                    
                    append mip_args " -enabled true -mpType mip -mipId $mip_id"
    
                    set tmp_status [::ixia::ixNetworkNodeAdd                            \
                            $bridge_handle                                              \
                            "mp"                                                        \
                            $mip_args                                               \
                            -commit                                                     \
                        ]
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                    
                    set mip_handle [keylget tmp_status node_objref]
                    
                    lappend mip_handles $mip_handle
                    
                    switch -- $mac_local_incr_mode {
                        "none" {
                            # do nothing
                        }
                        "increment" {
                            set mac_local [incrementMacAdd $mac_local $mac_local_step]
                        }
                        "decrement" {
                            set mac_local [decrementMacAdd $mac_local $mac_local_step]
                        }
                    }
                    
                    incr mip_id
    
                }
                
                #################
                ## Create MEPs ##
                #################
                for {set mep_counter 0} {$mep_counter < $mep_total_count} {incr mep_counter; incr global_idx; incr global_mep_idx} {
                    
                    # create meps
                    
                    # Calculate MAC Local address
                    
                    if {$mac_local_incr_mode == "list"} {
                        if {[llength $mac_local_list] == 0} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: When parameter\
                                    -mac_local_incr_mode is $mac_local_incr_mode, parameter\
                                    -mac_local_list must contain at least one value."
                        }
                        
                        if {[expr $global_idx + 1] > [llength $mac_local_list]} {
                            set mac_local [lindex $mac_local_list end]
                        } else {
                            set mac_local [lindex $mac_local_list $global_idx]
                        }
                    } elseif {$mac_local == "random"} {
                        set mac_local [get_random_mac]
                    }
                    
                    if {![isValidMacAddress $mac_local]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: mac address $mac_local\
                                is not a valid MAC address."
                        return $returnList
                    }
                    
                    set mac_local [ixNetworkFormatMac $mac_local]
                    
                    # Calculate Mep ID
                    if {$mep_id_incr_mode == "list"} {
                        if {[llength $mep_id_list] == 0} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: When parameter\
                                    -mep_id_incr_mode is $mep_id_incr_mode, parameter\
                                    -mep_id_list must contain at least one value."
                        }
                        
                        if {[expr $global_mep_idx + 1] > [llength $mep_id_list]} {
                            set mep_id [lindex $mep_id_list end]
                        } else {
                            set mep_id [lindex $mep_id_list $global_mep_idx]
                        }
                    } elseif {$mep_id_incr_mode == "random"} {
                        set mep_id [expr round(ceil( rand() * 8191))]
                    }
                    
                    # Calculate short_ma_name
                    switch -- $short_ma_name_format {
                        "primary_vid" {
                            if {$global_mep_idx > 0} {
                                if {[mpexpr $global_mep_idx % $short_ma_name_repeat] == 0} {
                                    incr short_ma_name_value $short_ma_name_step
                                    if {$short_ma_name_value > 4095} {
                                        set short_ma_name_value [mpexpr $short_ma_name_value % 4096]
                                    }
                                }
                            }
                            set tmp_short_ma_name $short_ma_name_value
                        }
                        "char_str" {
                            if {$short_ma_name_wildcard} {
                                if {$global_mep_idx > 0} {
                                    if {[mpexpr $global_mep_idx % $short_ma_name_repeat] == 0} {
                                        
                                        incr short_ma_name_wc_start $short_ma_name_step
                                        
                                        set wc_value_as_string "[format %0.${wc_width}d $short_ma_name_wc_start]"
                                        regsub {\?} $short_ma_name_value $wc_value_as_string tmp_short_ma_name
                                    }
                                } else {
                                    
                                    set wc_value_as_string "[format %0.${wc_width}d $short_ma_name_wc_start]"
                                    regsub {\?} $short_ma_name_value $wc_value_as_string tmp_short_ma_name
                                }
                            } else {
                                set tmp_short_ma_name $short_ma_name_value
                            }
                            
                        }
                        "integer" {
                            if {$global_mep_idx > 0} {
                                if {[mpexpr $global_mep_idx % $short_ma_name_repeat] == 0} {
                                    incr short_ma_name_value $short_ma_name_step
                                    if {$short_ma_name_value > 65535} {
                                        set short_ma_name_value [mpexpr $short_ma_name_value % 65536]
                                    }
                                }
                            }
                            set tmp_short_ma_name $short_ma_name_value
                        }
                        "rfc_2685_vpn_id" {
                            # incrementing will not be supported on this type
                            set tmp_short_ma_name $short_ma_name_value
                        }
                    }
                    
                    set mep_args ""
    
                    foreach {hlt_param ixn_param p_type extensions} $mep_params {
    
                        if {[info exists $hlt_param]} {
                            
                            set hlt_param_value [set $hlt_param]
    
                            switch -- $p_type {
                                value {
                                    set ixn_param_value $hlt_param_value
                                }
                                truth {
                                    set ixn_param_value $truth($hlt_param_value)
                                }
                                translate {
                                    if {[info exists cfm_options_map($hlt_param_value)]} {
                                        set ixn_param_value $cfm_options_map($hlt_param_value)
                                    } else {
                                        set ixn_param_value $hlt_param_value
                                    }
                                }
                            }
                            
                            if {$ixn_param_value != ""} {
                                if {[llength $ixn_param_value] > 1} {
                                    append mep_args "-$ixn_param \{$ixn_param_value\} "
                                } else {
                                    append mep_args "-$ixn_param $ixn_param_value "
                                }
                            }
                        }
                    }
                    
                    #################
                    ## Create VLAN ##
                    #################
                    
                    if {![is_default_param_value "vlan_id" $args]} {
                        # Create vlan object
                        if {[info exists vlan_outer_id]} {
                            set vlan_type "stackedVlan"
                        } else {
                            set vlan_type "singleVlan"
                        }
                        
                        set vlan_args "-enabled true"
                        
                        foreach {hlt_param ixn_param p_type extensions} $vlan_params {
            
                            if {[info exists $hlt_param]} {
                                
                                set hlt_param_value [set $hlt_param]
            
                                switch -- $p_type {
                                    value {
                                        set ixn_param_value $hlt_param_value
                                    }
                                    translate {
                                        if {[info exists cfm_options_map($hlt_param_value)]} {
                                            set ixn_param_value $cfm_options_map($hlt_param_value)
                                        } else {
                                            set ixn_param_value $hlt_param_value
                                        }
                                    }
                                }
                                
                                append vlan_args " -$ixn_param $ixn_param_value"
                            }
                        }
                        
                        set tmp_status [::ixia::oam_add_vlan_node                           \
                                $mac_local                                                  \
                                $bridge_handle                                              \
                                "vlans"                                                     \
                                $vlan_args                                                  \
                                -commit                                                     \
                            ]
                        if {[keylget tmp_status status] != $::SUCCESS} {
                            keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                            return $tmp_status
                        }
                        
                        set vlan_handle [keylget tmp_status node_objref]
                        lappend traffic_handles [keylget tmp_status mac_handle]
                        
                        append mep_args "-vlan $vlan_handle"
                        
                        if {[mpexpr ($global_mep_idx + 1) % $vlan_id_repeat] == 0} {
                            incr vlan_id $vlan_id_step
                            if {$vlan_id > 4095} {
                                set vlan_id [expr $vlan_id 4096]
                            }
                        }
                        
                        if {$vlan_type == "stackedVlan"} {
                            if {[mpexpr ($global_mep_idx + 1) % $vlan_id_outer_repeat] == 0} {
                                incr vlan_outer_id $vlan_id_outer_step
                                if {$vlan_outer_id > 4095} {
                                    set vlan_outer_id [expr $vlan_outer_id 4096]
                                }
                            }
                        }
                    }
                    
                    append mep_args " -enabled true -mpType mep"
                    
                    if {$oam_standard == "itu-t_y1731"} {
                        if {$md_name_format == "icc_based"} {
                            append mep_args " -megId $md_name"
                        }
                    }
                    
                    set tmp_status [::ixia::ixNetworkNodeAdd                            \
                            $bridge_handle                                              \
                            "mp"                                                        \
                            $mep_args                                                   \
                            -commit                                                     \
                        ]
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                    
                    set mep_handle [keylget tmp_status node_objref]
                    
                    lappend mep_handles $mep_handle
                    
                    
                    ##########################
                    ## Increment parameters ##
                    ##########################
                    
                    # Increment params
                    switch -- $mac_local_incr_mode {
                        "none" {
                            # do not increment mac_local
                        }
                        "increment" {
                            if {[mpexpr ($global_mep_idx + 1) % $mac_local_repeat] == 0} {
                                set mac_local [::ixia::incrementMacAdd $mac_local $mac_local_step]
                                set mac_local [ixNetworkFormatMac $mac_local]
                            }
                        }
                        "decrement" {
                            if {[mpexpr ($global_mep_idx + 1) % $mac_local_repeat] == 0} {
                                set mac_local [::ixia::decrementMacAdd $mac_local $mac_local_step]
                                set mac_local [ixNetworkFormatMac $mac_local]
                            }
                        }
                        default {
                            # These cases are treated at the begining of the loop
                        }
                    }
                    
                    # Calculate Mep ID
                    if {$mep_id_incr_mode == "increment"} {
                        if {[expr ($global_mep_idx + 1) % $mep_id_repeat] == 0} {
                            incr mep_id $mep_id_step
                            if {$mep_id > 8192} {
                                set mep_id [expr $mep_id % 8191]
                            }
                        }
                    } elseif {$mep_id_incr_mode == "decrement"} {
                        if {[expr ($global_mep_idx + 1) % $mep_id_repeat] == 0} {
                            incr mep_id -${mep_id_step}
                            if {$mep_id < 1} {
                                set mep_id [expr 8192 - abs($mep_id)]
                            }
                        }
                    }
                }
                
                # Now we finally have all the mps configured
                # mip_handles is the handle list for mips
                # mep_handles is the handle list for meps (might be longer than $count - $mip_total_count)
                
                # Start topology algorithm
                # vlan is already configured and attached to mips;
                # we must create the mdLevel objects and attach them to the mips and meps
                
                # Create md levels
                
                set md_level_args "-enabled true"
                
                if {$oam_standard == "ieee_802.1ag"} {
                    switch -- $md_name_format {
                        "none" {
                            # do nothing
                        }
                        "mac_addr" {
                            if {![isValidMacAddress $md_mac]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Error in $procName: when -md_name_format\
                                is $md_name_format, -md_mac $md_mac must be a valid MAC address."
                            }
                            set hlt_param_value [ixNetworkFormatMac $md_mac]
                            regsub -all {[:\. ]} $hlt_param_value { } hlt_param_value
                            
                            append md_level_args " -mdName \{$hlt_param_value-$md_integer\}"
                            
                        }
                        default {
                            # Check length
                            if {[string length $md_name] > $md_name_length} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Error in $procName: when -md_name_format\
                                is $md_name_format, -md_name $md_name must have a maximum length of\
                                -md_name_length $md_name_length"
                            }
                            
                            append md_level_args " -mdName $md_name"
                        }
                    }
                    
                    append md_level_args " -mdNameFormat $cfm_options_map($md_name_format)"
                }
                
                if {$domain_level == "level0"} {
                    
                    # Create one mdLevel with level -md_level
                    
                    append md_level_args  " -mdLevelId $md_level"
                    
                    set tmp_status [::ixia::oam_add_md_level_node                       \
                            $bridge_handle                                              \
                            "mdLevel"                                                   \
                            $md_level_args                                              \
                            -commit                                                     \
                        ]
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                    
                    set md_level_handle [keylget tmp_status node_objref]
                    set md_level_handles $md_level_handle
                    
                    for {set mip_item_idx 0} {$mip_item_idx < $mip_total_count} {incr mip_item_idx} {
                        if {$mip_item_idx == 0} {
                            # Create Link object and link MIP directly to Ixia Port
                            set mp_towards_ixia [ixNet getNull]
                            set mp_outwards_ixia [lindex $mip_handles $mip_item_idx]
                        } else {
                            set mp_towards_ixia [lindex $mip_handles [mpexpr $mip_item_idx - 1]]
                            set mp_outwards_ixia [lindex $mip_handles $mip_item_idx]
                        }
                        
                        set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                                [lindex $mip_handles $mip_item_idx]                         \
                                [list -mdLevel $md_level_handle]                            \
                                -commit                                                     \
                            ]
                            
                        if {[keylget tmp_status status] != $::SUCCESS} {
                            keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                            return $tmp_status
                        }
                        
                        set tmp_status [::ixia::ixNetworkNodeAdd                            \
                                $bridge_handle                                              \
                                "link"                                                      \
                                [list -enabled true -mpTowardsIxia $mp_towards_ixia         \
                                        -mpOutwardsIxia $mp_outwards_ixia]                  \
                                -commit                                                     \
                            ]
                        if {[keylget tmp_status status] != $::SUCCESS} {
                            keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                            return $tmp_status
                        }
                    }
                    
                    if {[llength $mip_handles] == 0} {
                        set last_mip [ixNet getNull]
                    } else {
                        set last_mip [lindex $mip_handles end]
                    }
                                        
                    foreach mep_item $mep_handles {
                        set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                                $mep_item                                                   \
                                [list -mdLevel $md_level_handle]                            \
                                -commit                                                     \
                            ]
                        if {[keylget tmp_status status] != $::SUCCESS} {
                            keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                            return $tmp_status
                        }
                        
                        set tmp_status [oam_push_mep_arr_entry $mep_item]
                        if {[keylget tmp_status status] != $::SUCCESS} {
                            keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                            return $tmp_status
                        }
                        
                        set tmp_status [::ixia::ixNetworkNodeAdd                            \
                                $bridge_handle                                              \
                                "link"                                                      \
                                [list -enabled true -mpTowardsIxia $last_mip                \
                                        -mpOutwardsIxia $mep_item]                          \
                                -commit                                                     \
                            ]
                        if {[keylget tmp_status status] != $::SUCCESS} {
                            keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                            return $tmp_status
                        }
                    }
                } else {
                    # Tree topology; Create levels_total mdLevels
                    # Starting value -md_level; ending value -domain_level
                    set md_level_handles ""
                    for {set current_level $md_level} {$current_level < $end_level} {incr current_level} {
                        set tmp_local_args "$md_level_args -mdLevelId $current_level"
                        set tmp_status [::ixia::oam_add_md_level_node                       \
                                $bridge_handle                                              \
                                "mdLevel"                                                   \
                                $tmp_local_args                                             \
                            ]
                        if {[keylget tmp_status status] != $::SUCCESS} {
                            keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                            return $tmp_status
                        }
                        
                        lappend md_level_handles [keylget tmp_status node_objref]
                    }
                    
                    set tmp_local_args "$md_level_args -mdLevelId $end_level"
                    set tmp_status [::ixia::ixNetworkNodeAdd                            \
                            $bridge_handle                                              \
                            "mdLevel"                                                   \
                            $tmp_local_args                                             \
                            -commit                                                     \
                        ]
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                    lappend md_level_handles [keylget tmp_status node_objref]
                    
                    set md_level_handles [ixNet remapIds $md_level_handles]
                    
                    set tmp_status [::ixia::oam_create_level [ixNet getNull] 0 $levels_total $mip_count $mep_count $bridge_handle]
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                }
            }
            
            keylset returnList handle $bridge_handle_list
            
            catch {array unset ::ixia::cfm_traffic_handles_array}
            
            switch -- $return_method {
                "keyed_list" {
                    keylset returnList traffic_handles $traffic_handles
                }
                "keyed_list_or_array" {
                    if {[llength $traffic_handles] < 2000} {
                        keylset returnList traffic_handles $traffic_handles
                    } else {
                        array set ::ixia::cfm_traffic_handles_array ""
                        set th_counter 0
                        foreach cfm_th $traffic_handles {
                            set ::ixia::cfm_traffic_handles_array($th_counter) $cfm_th
                            incr th_counter
                        }

                        keylset returnList traffic_handles_array "::ixia::cfm_traffic_handles_array"
                    }
                }
                "array" {
                    array set ::ixia::cfm_traffic_handles_array ""
                    set th_counter 0
                    foreach cfm_th $traffic_handles {
                        set ::ixia::cfm_traffic_handles_array($th_counter) $cfm_th
                        incr th_counter
                    }

                    keylset returnList traffic_handles_array "::ixia::cfm_traffic_handles_array"
                }
            }
        }
        "modify" {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Mode 'modify' is not supported."
        }
        "reset" {
            foreach rst_h $reset_handles {
                if {[regexp -- {^[0-9]+/[0-9]+/[0-9]+$} $rst_h]} {
                    # it's a port_handle
                    # first remove the entries from the array
                    foreach arr_entry [array names mep_handles_array -regexp ($port_handle,*)] {
                        set tmp_status [oam_pop_mep_arr_entry $arr_entry]
                        if {[keylget tmp_status status] != $::SUCCESS} {
                            keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                            return $tmp_status
                        }
                    }
                    
                    foreach arr_entry_vlan [array names cfm_vlan_handles_array -regexp ($port_handle,*)] {
                        catch {unset cfm_vlan_handles_array($arr_entry_vlan)}
                    }
                    
                    foreach arr_entry_mdLevel [array names cfm_mdlevel_handles_array -regexp ($port_handle,*)] {
                        catch {unset cfm_mdlevel_handles_array($arr_entry_mdLevel)}
                    }
                    
                    foreach arr_entry_msg [array names cfm_message_handles_array -regexp ($port_handle,*)] {
                        catch {unset cfm_message_handles_array($arr_entry_msg)}
                    }
                    
                    # Now remove all bridge handels from the port
                    set tmp_status [::ixia::ixNetworkGetPortObjref $port_handle]
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                    
                    set vport_objref [keylget tmp_status vport_objref]
                    
                    foreach bridge_handle [ixNet getList $vport_objref/protocols/cfm bridge] {
                        if {[ixNet remove $bridge_handle] != "::ixNet::OK"} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Failed to reset handle $bridge_handle."
                            return $returnList
                        }
                    }
                    
                    if {[ixNet commit] != "::ixNet::OK"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed to reset $port_handle."
                        return $returnList
                    }
                    
                } else {
                    # it's a bridge_handle
                    # First remove it from the array
                    foreach {rst_h topo_unique_id} [split $rst_h ,] {}
                    foreach mp_handle [ixNet getList $rst_h mp] {
                        set tmp_status [oam_pop_mep_arr_entry $mp_handle]
                        if {[keylget tmp_status status] != $::SUCCESS} {
                            keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                            return $tmp_status
                        }
                    }
                    
                    foreach arr_entry_vlan [array names cfm_vlan_handles_array -regexp $rst_h] {
                        catch {unset cfm_vlan_handles_array($arr_entry_vlan)}
                    }
                    
                    foreach arr_entry_mdLevel [array names cfm_mdlevel_handles_array -regexp $rst_h] {
                        catch {unset cfm_mdlevel_handles_array($arr_entry_mdLevel)}
                    }
                    
                    set tmp_b_id [ixNet getAttribute $rst_h -bridgeId]
                    set tmp_b_id [ixNetworkFormatMac $tmp_b_id]
                    
                    # Remove all messages from internal array based on the bridge id
                    foreach msg_h [array names cfm_message_handles_array -regexp ((\[^,\]*),$tmp_b_id,(\[^,\]*))] {
                        if {[catch {unset cfm_message_handles_array($msg_h)} err]} {
                            debug "unset cfm_message_handles_array($msg_h) returned $err"
                        }
                    }
                    
                    if {[ixNet exists $rst_h] == "true" || [ixNet exists $rst_h] == 1} {
                        if {[ixNet remove $rst_h] != "::ixNet::OK"} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Failed to reset handle $rst_h."
                            return $returnList
                        }
                    }
                    
                    if {[ixNet commit] != "::ixNet::OK"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed to reset $rst_h."
                        return $returnList
                    }
                }
            }
        }
    }
    
    # Cleanup global variables that I don't need anymore
    catch {unset md_level_handles}
    catch {unset mip_handles}
    catch {unset mep_handles}
    
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::emulation_oam_config_msg {args} {
	variable executeOnTclServer
    
    variable mep_handles_array
    variable cfm_messages_current_id
    variable cfm_message_handles_array
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::emulation_oam_config_msg $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    keylset returnList status $::SUCCESS
    
    # Arguments
    set man_args {
         -mode                        CHOICES   create modify reset
    }
    set opt_args {
         -port_handle                 REGEXP    ^[0-9]+/[0-9]+/[0-9]+$
         -count                       NUMERIC
                                      DEFAULT   1
         -handle_granularity          CHOICES   per_message per_group
                                      DEFAULT   per_group
         -msg_type                    CHOICES   loopback linktrace
                                      DEFAULT   loopback
         -mac_local                   ANY
         -mac_local_incr_mode         CHOICES   none increment decrement list random
                                      DEFAULT   none
         -mac_local_step              ANY
                                      DEFAULT   00:00:00:00:00:01
         -mac_local_repeat            NUMERIC
                                      DEFAULT   1
         -mac_local_list              ANY
                                      DEFAULT   ""
         -mac_remote                  ANY
         -mac_remote_incr_mode        CHOICES   none increment decrement list random
                                      DEFAULT   none
         -mac_remote_step             ANY
                                      DEFAULT   00:00:00:00:00:01
         -mac_remote_repeat           NUMERIC
                                      DEFAULT   1
         -mac_remote_list             ANY
                                      DEFAULT   ""
         -vlan_outer_id               ANY
         -vlan_id                     ANY
         -vlan_id_incr_mode           CHOICES   increment list
                                      DEFAULT   increment
         -vlan_id_list                ANY
                                      DEFAULT   ""
         -vlan_id_step                RANGE     0-4095
                                      DEFAULT   1
         -vlan_id_repeat              RANGE     1-4096
                                      DEFAULT   1
         -vlan_id_outer_incr_mode     CHOICES   increment list
                                      DEFAULT   increment
         -vlan_id_outer_list          ANY
                                      DEFAULT   ""
         -vlan_id_outer_step          RANGE     0-4095
                                      DEFAULT   1
         -vlan_id_outer_repeat        RANGE     1-4096
                                      DEFAULT   1
         -oam_standard                CHOICES   ieee_802.1ag itu-t_y1731
                                      DEFAULT   ieee_802.1ag
         -ttl                         NUMERIC
                                      DEFAULT   64
         -md_level                    RANGE     0-7
                                      DEFAULT   0
         -md_level_incr_mode          CHOICES   none increment decrement list random
                                      DEFAULT   none
         -md_level_step               RANGE     0-7
                                      DEFAULT   1
         -md_level_repeat             NUMERIC
                                      DEFAULT   1
         -md_level_list               ANY
                                      DEFAULT   ""
         -tlv_sender_chassis_id       NUMERIC
                                      DEFAULT   0
         -tlv_sender_chassis_id_length NUMERIC
                                      DEFAULT   0
         -tlv_sender_chassis_id_subtype RANGE   0-6
                                      DEFAULT   0
         -tlv_org_length              NUMERIC
                                      DEFAULT   4
         -tlv_org_value               REGEXP    ^0x[0-9a-fA-F]+$
                                      DEFAULT   0x0
         -tlv_data_length             NUMERIC
                                      DEFAULT   5
         -tlv_data_pattern            REGEXP    ^0x[0-9a-fA-F]+$
                                      DEFAULT   0x0
         -renew_test_msgs             FLAG
         -renew_period                RANGE     1000-65535000
                                      DEFAULT   90000
         -msg_timeout                 RANGE     1000-65535000
                                      DEFAULT   5000
         -mep_id                      RANGE     1-8192
         -mep_id_incr_mode            CHOICES   none increment list
                                      DEFAULT   none
         -mep_id_step                 RANGE     1-8191
                                      DEFAULT   1
         -mep_id_repeat               NUMERIC
                                      DEFAULT   1
         -mep_id_list                 ANY
                                      DEFAULT   ""
         -bridge_id                   ANY
         -supress_warnings            FLAG
         -short_ma_name_format        CHOICES   primary_vid char_str integer
                                      CHOICES   rfc_2685_vpn_id
                                      DEFAULT   integer
         -short_ma_name_length        NUMERIC
                                      DEFAULT   7
         -short_ma_name_value         ANY
                                      DEFAULT   DEFAULT
         -short_ma_name_step          NUMERIC
                                      DEFAULT   1
         -short_ma_name_repeat        NUMERIC
                                      DEFAULT   1
         -short_ma_name_wildcard      CHOICES   0 1
                                      DEFAULT   0
         -short_ma_name_wc_start      NUMERIC
                                      DEFAULT   0
         -short_ma_name_incr_mode     CHOICES   none increment list
                                      DEFAULT   none
         -short_ma_name_list          ANY
                                      DEFAULT   ""
         -burst_delay
         -burst_loop_count
         -dst_addr_type
         -encap
         -handle
         -mac_dst
         -mac_dst_incr_mode
         -mac_dst_list
         -mac_dst_repeat
         -mac_dst_step
         -pkts_per_burst
         -rate_pps
         -sut_ip_address
         -tlv_org_oui
         -tlv_org_subtype
         -tlv_sender_length
         -tlv_test_length
         -tlv_test_pattern
         -tlv_user_length
         -tlv_user_type
         -tlv_user_value
         -trans_id
         -trans_id_incr_mode
         -trans_id_list
         -trans_id_repeat
         -trans_id_step
         -transmit_mode
         -vlan_id_count
         -vlan_id_outer_count
         -vlan_outer_ether_type
         -vlan_ether_type
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args  -mandatory_args $man_args
    
    array set cfm_options_map {
        0       chassisComponent
        1       interfaceAlias
        2       interfaceName
        3       locallyAssigned
        4       macAddress
        5       networkAddress
        6       portComponent
    }
    
    array set truth {1 true 0 false enable true disable false}
    
    # Check to see if a connection to the IxNetwork TCL Server already exists. 
    # If it doesn't, establish it.
    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    
    if {$mode == "create" && ![info exists port_handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: When -mode is $mode, -port_handle\
                parameter is mandatory."
        return $returnList
    }
    
    if {$mode == "reset" && [info exists port_handle]} {
        set handle $port_handle
    }
    
    if {$mode == "reset" && [info exists handle]} {
        if {[regexp {^[0-9]+/[0-9]+/[0-9]+$} $handle]} {
            
            # It's a port handle. Reset all messages from all bridges all MPs
            set retCode [ixNetworkGetPortObjref $handle]
    
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Unable to find the port object reference \
                        associated to the $handle port handle -\
                        [keylget retCode log]."
                return $returnList
            }
            
            set vport_objref    [keylget retCode vport_objref]
            set protocol_objref [keylget retCode vport_objref]/protocols/cfm
            
            set commit 0
            foreach bridge_handle [ixNet getList $protocol_objref bridge] {
                foreach mep_handle [ixNet getList $bridge_handle mp] {
                    
                    set tmp_status [::ixia::ixNetworkNodeSetAttr                \
                            $mep_handle                                         \
                            [list -enableAutoLb "false" -addSenderIdTlv "false" \
                                    -addOrganizationSpecificTlv "false" -addDataTlv "false" \
                                    -enableAutoLt "false"]              \
                        ]
                        
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                    set commit 1
                }
            }
            
            if {$commit} {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                \
                        $mep_handle                                         \
                        ""                                                  \
                        -commit                                             \
                    ]
                    
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
            }
            
            # Remove messages from internal array based on port handle
            foreach msg_h [array names cfm_message_handles_array -regexp ($handle,(\[^,\]*))] {
                if {[catch {unset cfm_message_handles_array($msg_h)} err]} {
                    debug "unset cfm_message_handles_array($msg_h) returned $err"
                }
            }
            
        } elseif {[regexp {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+$} $handle]} {
            # It's a bridge handle. Reset all messages from all mps on this bridge
            
            set commit 0
            foreach mep_handle [ixNet getList $handle mp] {
                
                set tmp_status [::ixia::ixNetworkNodeSetAttr                \
                        $mep_handle                                         \
                        [list -enableAutoLb "false" -addSenderIdTlv "false" \
                                -addOrganizationSpecificTlv "false" -addDataTlv "false" \
                                -enableAutoLt "false"]              \
                    ]
                    
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
                set commit 1
            }
            
            if {$commit} {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                \
                        $mep_handle                                         \
                        ""                                                  \
                        -commit                                             \
                    ]
                    
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
            }
            
            set tmp_b_id [ixNet getAttribute $handle -bridgeId]
            set tmp_b_id [ixNetworkFormatMac $tmp_b_id]
            
            # Remove all messages from internal array based on the bridge id
            foreach msg_h [array names cfm_message_handles_array -regexp ((\[^,\]*),$tmp_b_id,(\[^,\]*))] {
                if {[catch {unset cfm_message_handles_array($msg_h)} err]} {
                    debug "unset cfm_message_handles_array($msg_h) returned $err"
                }
            }
            
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Invalid value $handle for -handle\
                    parameter when -mode is reset. Parameter -handle must be a port handle or\
                    a bridge handle returned by ::ixia::emulation_oam_config_topology."
            return $returnList
        }
        
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    # Add port after connecting to IxNetwork TCL Server
    set retCode [ixNetworkPortAdd $port_handle {} force]
    if {[keylget retCode status] == $::FAILURE} {
        keylset retCode log "ERROR in $procName: [keylget retCode log]"
        return $retCode
    }

    set retCode [ixNetworkGetPortObjref $port_handle]
    
    if {[keylget retCode status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Unable to find the port object reference \
                associated to the $port_handle port handle -\
                [keylget retCode log]."
        return $returnList
    }
    
    set vport_objref    [keylget retCode vport_objref]
    set protocol_objref [keylget retCode vport_objref]/protocols/cfm
    
    
#     if {$mode == "modify"} {
#             removeDefaultOptionVars $opt_args $args
#     }
    
    foreach {ch ca po} [split $port_handle /] {}
    
    # Validate msg_timeout and renew_period
    if {[info exists msg_timeout] && [info exists renew_period]} {
        if {$msg_timeout > $renew_period} {
            if {![info exists supress_warnings]} {
                puts "\nWARNING: Message timeout value: -msg_timeout $msg_timeout cannot be greater\
                        than the Renew period value: -renew_period $renew_period.\
                        Message timeout value will be forced to be equal to Renew period value\
                        $renew_period.\n"
                set msg_timeout $renew_period
            }
        }
    }
    
    # Validate mac addresses
    if {(![info exists mac_local] || [is_default_param_value "mac_local" $args]) &&\
            (![info exists mac_local_incr_mode] || [is_default_param_value "mac_local_incr_mode" $args])} {
        set mac_local [get_default_mac $ch $ca $po]
        set mac_local_incr_mode "list"
        set mac_local_list "all"
    }

    if {(![info exists mac_remote] || [is_default_param_value "mac_remote" $args]) &&\
            (![info exists mac_remote_incr_mode] || [is_default_param_value "mac_remote_incr_mode" $args])} {
        set mac_remote [get_default_mac $ch $ca $po]
        set mac_remote_incr_mode "list"
        set mac_remote_list "all"
    }
    
    if {(![info exists md_level] || [is_default_param_value "md_level" $args]) &&\
            (![info exists md_level_incr_mode] || [is_default_param_value "md_level_incr_mode" $args])} {
        set md_level_incr_mode "list"
        set md_level_list "all" 
    }
    
    if {(![info exists short_ma_name_value] || [is_default_param_value "short_ma_name_value" $args]) &&\
            (![info exists short_ma_name_incr_mode] || [is_default_param_value "short_ma_name_incr_mode" $args])} {
        
        set short_ma_name_incr_mode "list"
        set short_ma_name_list "all"
        
    } else {

        # Check if short_ma_name is in correct format
        if {![info exists short_ma_name_incr_mode] || $short_ma_name_incr_mode != "list"} {
            
            set wc_width [expr $short_ma_name_length - [string length $short_ma_name_value] + 1]
            
            # Check if short_ma_name is ok
            if {[is_default_param_value "short_ma_name_value" $args]} { 
                switch -- $short_ma_name_format {
                    "primary_vid" {
                        set short_ma_name_value 0
                    }
                    "char_str" {
                        # Use default "DEFAULT"
                    }
                    "integer" {
                        set short_ma_name_value 0
                    }
                    "rfc_2685_vpn_id" {
                        set short_ma_name_value "0-0"
                    }
                }
            }
            set tmp_status [oam_short_ma_name_check $short_ma_name_value $short_ma_name_format $short_ma_name_length]
            if {[keylget tmp_status status] != $::SUCCESS} {
                keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                return $tmp_status
            }
            
        } else {
                if {[info exists short_ma_name_list] && $short_ma_name_list != "all"} {
                # The increment mode is list
                # short_ma_name_list should contain a list of one or more short ma names
                # short_ma_name_format should contain a list of one or more short ma name formats
                # if length > 1 for short_ma_name_format it must have the same length as short_ma_name_list
                
                if {[llength $short_ma_name_format] > 1 && [llength $short_ma_name_format] != [llength $short_ma_name_list]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: When short_ma_name_incr_mode is 'list'\
                            -short_ma_name_format must be equal to 1 or it must have the same length as\
                            -short_ma_name_list."
                    return $returnList
                }
                
                set idx 0
                foreach tmp_short_ma_name $short_ma_name_list {
                    
                    if {[llength $short_ma_name_format] > 1} {
                        set tmp_short_ma_name_format [lindex $short_ma_name_format $idx]
                    } else {
                        set tmp_short_ma_name_format $short_ma_name_format
                    }
                    
                    set tmp_status [oam_short_ma_name_check $tmp_short_ma_name $tmp_short_ma_name_format [string length $tmp_short_ma_name]]
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                    
                    incr idx
                }
                
                catch {unset idx}
                catch {unset tmp_short_ma_name_format}
                catch {unset tmp_short_ma_name}
            }
        }
    }
    
    # $port_handle,$arr_op_mode,$arr_md_level_id,$arr_mac,$arr_vlan_id,$arr_svlan_id
    if {![array exists mep_handles_array] || [array size mep_handles_array] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed to create OAM messages.\
                A topology was not created on port $port_handle. Create an OAM Topology\
                on port $port_handle first using ::ixia::emulation_oam_config_topology."
        return $returnList
    }
    
    if {$mode == "create" || $mode == "reset"} {
    
        set addSenderIdTlv 0
    
        set sender_tlv_params [list tlv_sender_chassis_id tlv_sender_chassis_id_length \
                tlv_sender_chassis_id_subtype ]
        foreach sender_tlv_p $sender_tlv_params {
            if {![is_default_param_value $sender_tlv_p $args]} {
                set addSenderIdTlv 1
                break
            }
        }
        
        set addOrganization 0
        
        set org_tlv_params [list tlv_org_length tlv_org_value ]
        foreach org_tlv_p $org_tlv_params {
            if {![is_default_param_value $org_tlv_p $args]} {
                set addOrganization 1
                break
            }
        }
        
        if {[info exists renew_test_msgs]} {
            # autoLt/bIteration 0 means send periodically.
            set renew_test_msgs 0
        } else {
            set renew_test_msgs 1
        }
        
        if {$mac_remote_incr_mode == "list" && $mac_remote_list == "all"} {
            # set all destionations
            set autoAllDestination 1
            catch {unset mac_remote}
        }
        
        if {$mode == "reset"} {
            set msg_params {
                    enableAutoLb                        enableAutoLb                    truth
                    addSenderIdTlv                      addSenderIdTlv                  truth
                    addOrganization                     addOrganizationSpecificTlv      truth
                    addDataTlv                          addDataTlv                      truth
                    enableAutoLt                        enableAutoLt                    truth
                }
                
            set enableAutoLb    0
            set addSenderIdTlv  0
            set addOrganization 0
            set addDataTlv      0
            set enableAutoLt    0
            
        } else {
            if {$msg_type == "loopback"} {
    
                set addDataTlv 0
            
                set data_tlv_params [list tlv_data_length tlv_data_pattern ]
                foreach data_tlv_p $data_tlv_params {
                    if {![is_default_param_value $data_tlv_p $args]} {
                        set addDataTlv 1
                        break
                    }
                }
    
                set enableAutoLb 1
                
                set msg_params {
                        autoAllDestination                  autoLbAllDestination            truth
                        enableAutoLb                        enableAutoLb                    truth
                        mac_remote                          autoLbDestination               mac
                        addSenderIdTlv                      addSenderIdTlv                  truth
                        tlv_sender_chassis_id               chassisId                       num2hexlist
                        tlv_sender_chassis_id_length        chassisIdLength                 value
                        tlv_sender_chassis_id_subtype       chassisIdSubType                translate
                        addOrganization                     addOrganizationSpecificTlv                 truth
                        tlv_org_length                      organizationSpecificTlvLength   value
                        tlv_org_value                       organizationSpecificTlvValue    num2hexlist
                        addDataTlv                          addDataTlv                      truth
                        tlv_data_length                     dataTlvLength                   value
                        tlv_data_pattern                    dataTlvValue                    num2hexlist
                        renew_test_msgs                     autoLbIteration                 value
                        renew_period                        autoLbTimer                     ms2sec
                        msg_timeout                         autoLbTimeout                   ms2sec
                    }
            } else {
                set enableAutoLt 1
                
                set msg_params {
                        enableAutoLt                        enableAutoLt                    truth
                        mac_remote                          autoLtDestination               mac
                        autoAllDestination                  autoLtAllDestination            truth
                        ttl                                 ttl                             value
                        addSenderIdTlv                      addSenderIdTlv                  truth
                        tlv_sender_chassis_id               chassisId                       num2hexlist
                        tlv_sender_chassis_id_length        chassisIdLength                 value
                        tlv_sender_chassis_id_subtype       chassisIdSubType                translate
                        addOrganization                     addOrganizationSpecificTlv                 truth
                        tlv_org_length                      organizationSpecificTlvLength   value
                        tlv_org_value                       organizationSpecificTlvValue    num2hexlist
                        renew_test_msgs                     autoLtIteration                 value
                        renew_period                        autoLtTimer                     ms2sec
                        msg_timeout                         autoLtTimeout                   ms2sec
                    }
            }
            
            if {![info exists cfm_messages_current_id]} {
                set cfm_messages_current_id 0
            }
        }
        
        if {[info exists mep_id_incr_mode] && ![is_default_param_value "mep_id_incr_mode" $args] \
                && $mep_id_incr_mode == "list"} {
            # This is just a dummy value to enable using mep_id_list as filter 
            set mep_id 1
        }
        
        set msg_handles_list ""
        
        if {![info exists mep_id]} {
            
            # If all parameters are configured as lists ignore -count and use 
            # the length of the shortest list as count
            set inspect_params {
                mac_local           mac_local_incr_mode         mac_local_list
                vlan_id             vlan_id_incr_mode           vlan_id_list
                vlan_outer_id       vlan_id_outer_incr_mode     vlan_id_outer_list
                md_level            md_level_incr_mode          md_level_list
                short_ma_name_value short_ma_name_incr_mode     short_ma_name_list
            }
            
            set check_lists_for_length ""
            set use_shortest_list_count 1
            foreach {insp_p incr_p list_p} $inspect_params {
                if {[set $incr_p] == "list"} {
                    if {![info exists $list_p] || [llength [set $list_p]] == 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: If parameter\
                                $incr_p is [set $incr_p] then parameter $list_p must\
                                exist and must have at least one value."
                        return $returnList
                    }
                    
                    # increment mode is list and list parameter has at least one value
                    if {[set $list_p] != "all"} {
                        lappend check_lists_for_length $list_p
                    }
                } elseif {[set $incr_p] == "random"} {
                    set use_shortest_list_count 0
                } else {
                    if {[info exists $insp_p] && ![is_default_param_value $insp_p $args] && \
                            [set $insp_p] != "all"} {
                        # A filter which is not list was used
                        # In this case use $count as number of messages
                        set use_shortest_list_count 0
                    }
                }
            }
            
            if {$use_shortest_list_count} {
                if {[llength $check_lists_for_length] == 0} {
                    # No filter parameters were specified or all filter parameters
                    # are set to 'all'
                    if {![info exists supress_warnings] && [info exists count] &&\
                            $count != 1} {
                        puts "\nWARNING: Parameter -count is forced to value '1' because\
                                all filters are of type 'include all'.\n"
                    }
                    set count 1
                } else {
                
                    set new_count [llength [set [lindex $check_lists_for_length 0]]]
                    foreach list_param $check_lists_for_length {
                        set list_param_val [set $list_param]
                        if {[llength $list_param_val] < $new_count} {
                            set new_count [llength $list_param_val]
                        }
                    }
                    
                    if {![info exists supress_warnings] && [info exists count] &&\
                            $count != $new_count} {
                        puts "\nWARNING: Parameter -count is forced to value '$count' because\
                                all filters are of type 'list' and in this case the length\
                                of the shortest list is used.\n"
                    }
                    
                    set count $new_count
                }
            }
            
            foreach list_param $check_lists_for_length {
                if {[llength [set $list_param]] < $count} {
                    if {![info exists supress_warnings]} {
                        puts "\nWARNING: Length of parameter $list_param is shorter than\
                                -count $count. The last value in the list will be\
                                duplicated to match the number of messages.\n"
                    }
                }
            }
            
            for {set i 0} {$i < $count} {incr i} {
                
                # This loop generates the string 
                #       $port_handle,$bridge_id,$mep_id,$arr_op_mode,$arr_md_level_id,$arr_mac,$arr_vlan_id,$arr_svlan_id,$short_ma_name_format,$short_ma_name
                # necessary to search the mep_handles_array
                # If a MEP is found with the characteristics above, we'll configure a message on it.
                # Otherwise we'll just ignore it
                
                if {$mac_remote_incr_mode == "list" && $mac_remote_list != "all"} {
                    if {[llength $mac_remote_list] == 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: When \
                                -mac_remote_incr_mode is 'list', -mac_remote_list\
                                parameter should contain at least one mac address."
                        return $returnList
                    } else {
                       if {[expr $i + 1] > [llength $mac_remote_list]} {
                            set mac_remote [lindex $mac_remote_list end]
                        } else {
                            set mac_remote [lindex $mac_remote_list $i]
                        }
                    }
                } elseif {$mac_remote_incr_mode == "random"} {
                    set mac_remote [get_random_mac]
                }

                if {$mac_local_incr_mode == "list" && $mac_local_list != "all"} {
                    if {[llength $mac_local_list] == 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: When \
                                -mac_local_incr_mode is 'list', -mac_local_list\
                                parameter should contain at least one mac address."
                        return $returnList
                    } else {
                        if {[expr $i + 1] > [llength $mac_local_list]} {
                            set mac_local [lindex $mac_local_list end]
                        } else {
                            set mac_local [lindex $mac_local_list $i]
                        }
                    }
                } elseif {$mac_local_incr_mode == "random"} {
                    set mac_local [get_random_mac]
                }
                
                if {$vlan_id_incr_mode == "list"} {
                    if {$vlan_id_list != "all"} {
                        if {[llength $vlan_id_list] == 0} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: When \
                                    -vlan_id_incr_mode is 'list', -vlan_id_list\
                                    parameter should contain at least one VLAN ID."
                            return $returnList
                        } else {
                           if {[expr $i + 1] > [llength $vlan_id_list]} {
                                set vlan_id [lindex $vlan_id_list end]
                            } else {
                                set vlan_id [lindex $vlan_id_list $i]
                            }
                        }
                    } else {
                        set vlan_id "all"
                    }
                }
                
                if {$vlan_id_outer_incr_mode == "list"} {
                    if {$vlan_id_outer_list != "all"} {
                        if {[llength $vlan_id_outer_list] == 0} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: When \
                                    -vlan_id_outer_incr_mode is 'list', -vlan_id_outer_list\
                                    parameter should contain at least one VLAN ID."
                            return $returnList
                        } else {
                           if {[expr $i + 1] > [llength $vlan_id_outer_list]} {
                                set vlan_outer_id [lindex $vlan_id_outer_list end]
                            } else {
                                set vlan_outer_id [lindex $vlan_id_outer_list $i]
                            }
                        }
                    } else {
                          set vlan_outer_id "all"
                    }
                }
                
                if {$md_level_incr_mode == "list" && $md_level_list != "all"} {
                    if {[llength $md_level_list] == 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: When \
                                -md_level_incr_mode is 'list', -md_level_list\
                                parameter should contain at least one md level value."
                        return $returnList
                    }
                    
                    if {[expr $i + 1] > [llength $md_level_list]} {
                        set md_level [lindex $md_level_list end]
                    } else {
                        set md_level [lindex $md_level_list $i]
                    }
                    if {![string is integer $md_level] || $md_level < 0 || $md_level > 7} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: When \
                                -md_level_incr_mode is 'list', -md_level_list\
                                parameter must contain integer values in the range 0-7."
                        return $returnList
                    }
                } elseif {$md_level_incr_mode == "random"} {
                    set md_level [expr round( rand() * 7)]
                }
                
                if {$short_ma_name_incr_mode != "list"} {
                
                    if {$short_ma_name_incr_mode == "increment"} {
                        set tmp_idx $i
                    } else {
                        set tmp_idx 0
                    }
                
                    # Calculate short_ma_name
                    switch -- $short_ma_name_format {
                        "primary_vid" {
                            if {$i > 0} {
                                if {[mpexpr $tmp_idx % $short_ma_name_repeat] == 0} {
                                    incr short_ma_name_value $short_ma_name_step
                                    if {$short_ma_name_value > 4095} {
                                        set short_ma_name_value [mpexpr $short_ma_name_value % 4096]
                                    }
                                }
                            }
                            set tmp_short_ma_name        $short_ma_name_value
                            set tmp_short_ma_name_format $short_ma_name_format
                        }
                        "char_str" {
                            if {$short_ma_name_wildcard} {
                                if {$tmp_idx > 0} {
                                    if {[mpexpr $tmp_idx % $short_ma_name_repeat] == 0} {
                                        
                                        incr short_ma_name_wc_start $short_ma_name_step
                                        
                                        set wc_value_as_string "[format %0.${wc_width}d $short_ma_name_wc_start]"
                                        regsub {\?} $short_ma_name_value $wc_value_as_string tmp_short_ma_name
                                    }
                                } else {
                                    
                                    set wc_value_as_string "[format %0.${wc_width}d $short_ma_name_wc_start]"
                                    regsub {\?} $short_ma_name_value $wc_value_as_string tmp_short_ma_name
                                }
                            } else {
                                set tmp_short_ma_name $short_ma_name_value
                            }
                            
                            set tmp_short_ma_name_format $short_ma_name_format
                        }
                        "integer" {
                            if {$tmp_idx > 0} {
                                if {[mpexpr $tmp_idx % $short_ma_name_repeat] == 0} {
                                    incr short_ma_name_value $short_ma_name_step
                                    if {$short_ma_name_value > 65535} {
                                        set short_ma_name_value [mpexpr $short_ma_name_value % 65536]
                                    }
                                }
                            }
                            set tmp_short_ma_name        $short_ma_name_value
                            set tmp_short_ma_name_format $short_ma_name_format
                        }
                        "rfc_2685_vpn_id" {
                            # incrementing will not be supported on this type
                            set tmp_short_ma_name        $short_ma_name_value
                            set tmp_short_ma_name_format $short_ma_name_format
                        }
                    }
                    
                    catch {unset tmp_idx}
                    
                } else {
                    # short_ma_name_incr_mode is list
                    if {$short_ma_name_list != "all"} {
                        if {[llength $short_ma_name_list] == 0} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: When \
                                    -short_ma_name_incr_mode is 'list', -short_ma_name_list\
                                    parameter should contain at least one short_ma_name."
                            return $returnList
                        } else {
                            if {[expr $i + 1] > [llength $short_ma_name_list]} {
                                set tmp_short_ma_name [lindex $short_ma_name_list end]
                            } else {
                                set tmp_short_ma_name [lindex $short_ma_name_list $i]
                            }
                            
                            if {[expr $i + 1] > [llength $short_ma_name_format]} {
                                set tmp_short_ma_name_format [lindex $short_ma_name_format end]
                            } else {
                                set tmp_short_ma_name_format [lindex $short_ma_name_format $i]
                            }
                        }
                    } else {
                        set tmp_short_ma_name        "all"
                        set tmp_short_ma_name_format "all"
                    }
                }
                
                # meps from $port_handle
                set search_string "$port_handle"
                
                if {![info exists bridge_id]} {
                    # meps from any bridge_id
                    append search_string ",(\[^,\]*)"
                } else {
                    # from a specific bridge_id
                    append search_string ",[ixNetworkFormatMac $bridge_id]"
                }
                
                # Any mep_id
                append search_string ",(\[^,\]*)"
                
                if {![info exists oam_standard] || [is_default_param_value "oam_standard" $args]} {
                    append search_string ",(\[^,\]*)"
                } else {
                    append search_string ",$oam_standard"
                }
                
                if {$md_level_incr_mode == "list" && $md_level_list == "all"} {
                    append search_string ",(\[^,\]*)"
                } else {
                    append search_string ",$md_level"
                }
                
                if {$mac_local_incr_mode == "list" && $mac_local_list == "all"} {
                    append search_string ",(\[^,\]*)"
                } else {
                    set mac_local [ixNetworkFormatMac $mac_local]
                    append search_string ",$mac_local"
                }
                
                
                if {![info exists vlan_id]} {
                    append search_string ",(\[^,\]*),(\[^,\]*)"
                } else {
                    
                    if {$vlan_id == "all"} {
                        append search_string ",(\[^,\]*)"
                    } else {
                        if {![string is integer $vlan_id] || $vlan_id < 0 || $vlan_id > 4095} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Parameter \
                                    -vlan_id must be an integer value in the range 0-4095."
                            return $returnList
                        }
                        append search_string ",$vlan_id"
                    }
                    
                    if {[info exists vlan_outer_id]} {
                        if {$vlan_outer_id == "all"} {
                            append search_string ",(\[^,\]*)"
                        } else {
                            if {![string is integer $vlan_outer_id] || $vlan_outer_id < 0 || $vlan_outer_id > 4095} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: Parameter \
                                        -vlan_outer_id must be an integer value in the range 0-4095."
                                return $returnList
                            }
                            
                            append search_string ",$vlan_outer_id"
                        }
                    } else {                    
                        # Stacked vlan not applicable
                        append search_string ",(\[^,\]*)"
                    }
                }
                
                if {$tmp_short_ma_name == "all"} {
                    append search_string ",(\[^,\]*),(\[^,\]*)"
                } else {
                    array set translate_sman {
                        char_str          characterString
                        primary_vid       primaryVid
                        integer           2octetInteger
                        rfc_2685_vpn_id   rfc2685VpnId
                    }
                    
                    set tmp_short_ma_name_format $translate_sman($tmp_short_ma_name_format)
                    
                    append search_string ",$tmp_short_ma_name_format,$tmp_short_ma_name"
                }
                
                
                set mep_search_results [array names mep_handles_array -regexp ($search_string)]
                
                if {$mep_search_results == "" && ![info exists supress_warnings]} {
                    puts "\nWARNING: Cannot configure message because a MEP with the following\
                            properties has not been configured:"
                    
                    catch {::ixia::oam_print_mep_details $search_string}
                }
                
                foreach mep_single_h [lsort $mep_search_results] {
                    # Configure parameters and set them on the mep_handle object
                    set mep_handle [lindex [split $mep_handles_array($mep_single_h) ,] 0]
                    set mep_args ""
                    
                    if {[info exists autoAllDestination] && $autoAllDestination == 1} {
                        set arr_msg_dst "all"
                    } else {
                        set arr_msg_dst [ixNetworkFormatMac $mac_remote]
                    }
                    
                    if {$mode == "reset"} {
                        debug "unset cfm_message_handles_array($mep_single_h,(\[^,\]*),(\[^,\]*))"
                        catch {unset cfm_message_handles_array($mep_single_h,$msg_type,$arr_msg_dst)}
                    } else {
                    
                        if {[info exists cfm_message_handles_array($mep_single_h,$msg_type,$arr_msg_dst)]} {
                            if {![info exists supress_warnings]} {
                                puts "\nWARNING: [string totitle $msg_type] message has already been configured.\
                                        HLT message handle is $cfm_message_handles_array($mep_single_h,$msg_type,$arr_msg_dst).\
                                        Overwriting message with new configuration on the MEP with \
                                        the following properties.\n"
                                
                                catch {::ixia::oam_print_mep_details $mep_single_h}
                            }
                        }
                        
                        set cfm_message_handles_array($mep_single_h,$msg_type,$arr_msg_dst) CFM_MSG_H_$cfm_messages_current_id
                        
                        if {$handle_granularity == "per_message"} {
                            lappend msg_handles_list CFM_MSG_H_$cfm_messages_current_id
                            incr cfm_messages_current_id
                        } else {
                            set msg_handles_list CFM_MSG_H_$cfm_messages_current_id
                        }
                    }
                    
                    
                    foreach {hlt_param ixn_param p_type} $msg_params {
                        if {[info exists $hlt_param]} {

                            set hlt_param_value [set $hlt_param]
        
                            switch -- $p_type {
                                value {
                                    set ixn_param_value $hlt_param_value
                                }
                                truth {
                                    set ixn_param_value $truth($hlt_param_value)
                                }
                                translate {
                                    if {[info exists cfm_options_map($hlt_param_value)]} {
                                        set ixn_param_value $cfm_options_map($hlt_param_value)
                                    } else {
                                        set ixn_param_value $hlt_param_value
                                    }
                                }
                                mac {
                                    if {![isValidMacAddress $hlt_param_value]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: Parameter\
                                                -$hlt_param $hlt_param_value is not a valid MAC\
                                                address."
                                        return $returnList
                                    }
                                    
                                    set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                                }
                                num2hexlist {
                                    set ixn_param_value "0x[format %x $hlt_param_value]"
                                    set ixn_param_value [hex2list $ixn_param_value]
                                }
                                ms2sec {
                                    set ixn_param_value [expr round([format %f $hlt_param_value]/1000)]
                                }
                            }
                            
                            if {[llength $ixn_param_value] == 1} {
                                append mep_args "-$ixn_param $ixn_param_value "
                            } else {
                                append mep_args "-$ixn_param \{$ixn_param_value\} "
                            }
                        }
                    }
                    
                    set tmp_status [::ixia::ixNetworkNodeSetAttr                \
                            $mep_handle                                         \
                            $mep_args                                           \
                            -commit                                             \
                        ]
                        
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                }
                
                # Increment parameters that should be modified
                # Increment Vlans
                if {[info exists vlan_id] && $vlan_id != "all" && $vlan_id_incr_mode != "list"} {
                    if {[expr ($i + 1) % $vlan_id_repeat] == 0} {
                        incr vlan_id $vlan_id_step
                        if {$vlan_id > 4095} {
                            set vlan_id [expr $vlan_id % 4096]
                        }
                    }
                    
                    if {[info exists vlan_outer_id] && $vlan_outer_id != "all" && $vlan_id_outer_incr_mode != "list"} {
                        if {[expr ($i + 1) % $vlan_id_outer_repeat] == 0} {
                            incr vlan_outer_id $vlan_id_outer_step
                            if {$vlan_outer_id > 4095} {
                                set vlan_outer_id [expr $vlan_outer_id % 4096]
                            }
                        }
                    }
                }
                
                switch -- $mac_local_incr_mode {
                    "none" {
                        # do not increment mac_local
                    }
                    "increment" {
                        if {[expr ($i + 1) % $mac_local_repeat] == 0} {
                            set mac_local [::ixia::incrementMacAdd $mac_local $mac_local_step]
                            set mac_local [ixNetworkFormatMac $mac_local]
                        }
                    }
                    "decrement" {
                        if {[expr ($i + 1) % $mac_local_repeat] == 0} {
                            set mac_local [::ixia::decrementMacAdd $mac_local $mac_local_step]
                            set mac_local [ixNetworkFormatMac $mac_local]
                        }
                    }
                    default {
                        # These cases are treated at the begining of the loop
                    }
                }
                
                switch -- $mac_remote_incr_mode {
                    "none" {
                        # do not increment mac_remote
                    }
                    "increment" {
                        if {[expr ($i + 1) % $mac_remote_repeat] == 0} {
                            set mac_remote [::ixia::incrementMacAdd $mac_remote $mac_remote_step]
                            set mac_remote [ixNetworkFormatMac $mac_remote]
                        }
                    }
                    "decrement" {
                        if {[expr ($i + 1) % $mac_remote_repeat] == 0} {
                            set mac_remote [::ixia::decrementMacAdd $mac_remote $mac_remote_step]
                            set mac_remote [ixNetworkFormatMac $mac_remote]
                        }
                    }
                    default {
                        # These cases are treated at the begining of the loop
                    }
                }
                
                switch -- $md_level_incr_mode {
                    "none" {
                        # do not increment md_level
                    }
                    "increment" {
                        if {[expr ($i + 1) % $md_level_repeat] == 0} {
                            incr md_level $md_level_step
                            if {$md_level > 7} {
                                set md_level [expr $md_level % 8]
                            }
                        }
                    }
                    "decrement" {
                        if {[expr ($i + 1) % $md_level_repeat] == 0} {
                            incr md_level -${md_level_step}
                            if {$md_level < 0} {
                                set md_level [expr 8 - abs($md_level)]
                            }
                        }
                    }
                }
            }
        } else {
            # We have a mep_id
            # we will ignore all parameters that identify the mep when mep_id isn't passed:
            #       $arr_op_mode,$arr_md_level_id,$arr_mac,$arr_vlan_id,$arr_svlan_id
            
            # $port_handle,$bridge_id,$mep_id,$arr_op_mode,$arr_md_level_id,$arr_mac,$arr_vlan_id,$arr_svlan_id
            set search_string "$port_handle"
            
            if {![info exists bridge_id] || $bridge_id == "all"} {
                append search_string ",(\[^,\]*)"
            } else {
                set bridge_id [ixNetworkFormatMac $bridge_id]
                append search_string ",$bridge_id"
            }
            
            if {$mep_id_incr_mode == "list"} {
                # Override $count
                if {$mep_id_list == "all"} {
                    append search_string ",(\[^,\]*)"
                } else {
                    append search_string ",([regsub -all { } $mep_id_list {|}])"
                }
            } elseif {$mep_id_incr_mode == "none"} {
                append search_string ",$mep_id"
            } else {
                set tmp_mep_list "$mep_id"
                for {set i 1} {$i < $count} {incr i} {
                    if {[expr $i % $mep_id_repeat] == 0} {
                        incr mep_id $mep_id_step
                        if {$mep_id > 8192} {
                            set mep_id [expr $mep_id % 8191]
                        }
                        lappend tmp_mep_list $mep_id
                    } 
                }
                append search_string ",([regsub -all { } $tmp_mep_list {|}])"
            }
            
            # Anything else after this is accepted
            append search_string ",(\[^,\]*)"
            
            set mep_search_results [array names mep_handles_array -regexp ($search_string)]
            
            if {$mep_search_results == "" && ![info exists supress_warnings]} {
                puts "\nWARNING: Cannot configure message because a MEP with the following\
                        properties has not been configured:"
                
                catch {::ixia::oam_print_mep_details $search_string}
            }
            
            set i 0
            foreach mep_handle_list [lsort $mep_search_results] {
                # There could be more than one mep that matches the description
                foreach mep_single_handle $mep_handle_list {
                    # Configure parameters and set them on the mep_handle object
                    set mep_handle [lindex [split $mep_handles_array($mep_single_handle) ,] 0]
                    set mep_args ""
                    
                    if {[info exists autoAllDestination] && $autoAllDestination == 1} {
                        set arr_msg_dst "all"
                    } else {
                        set arr_msg_dst [ixNetworkFormatMac $mac_remote]
                    }
                    
                    if {$mode == "reset"} {
                        catch {unset cfm_message_handles_array($mep_single_handle,$msg_type,$arr_msg_dst)}
                    } else {

                        if {[info exists cfm_message_handles_array($mep_single_handle,$msg_type,$arr_msg_dst)]} {
                            if {![info exists supress_warnings]} {
                                puts "\nWARNING: [string totitle $msg_type] message has already been configured.\
                                        HLT message handle is $cfm_message_handles_array($mep_single_handle,$msg_type,$arr_msg_dst).\
                                        Overwriting message with new configuration on the MEP with \
                                        the following properties.\n"
                                
                                catch {::ixia::oam_print_mep_details $mep_single_handle}
                            }
                        }
                        
                        set cfm_message_handles_array($mep_single_handle,$msg_type,$arr_msg_dst) CFM_MSG_H_$cfm_messages_current_id
                        
                        if {$handle_granularity == "per_message"} {
                            lappend msg_handles_list CFM_MSG_H_$cfm_messages_current_id
                            incr cfm_messages_current_id
                        } else {
                            set msg_handles_list CFM_MSG_H_$cfm_messages_current_id
                        }
                    }
                    
                    foreach {hlt_param ixn_param p_type} $msg_params {
                        if {[info exists $hlt_param]} {
                            set hlt_param_value [set $hlt_param]
        
                            switch -- $p_type {
                                value {
                                    set ixn_param_value $hlt_param_value
                                }
                                truth {
                                    set ixn_param_value $truth($hlt_param_value)
                                }
                                mac {
                                    
                                    if {![isValidMacAddress $hlt_param_value]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: Parameter\
                                                -$hlt_param $hlt_param_value is not a valid MAC\
                                                address."
                                        return $returnList
                                    }
                                    
                                    set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                                }
                                translate {
                                    if {[info exists cfm_options_map($hlt_param_value)]} {
                                        set ixn_param_value $cfm_options_map($hlt_param_value)
                                    } else {
                                        set ixn_param_value $hlt_param_value
                                    }
                                }
                                num2hexlist {
                                    set ixn_param_value "0x[format %x $hlt_param_value]"
                                    set ixn_param_value [hex2list $ixn_param_value]
                                }
                                ms2sec {
                                    set ixn_param_value [expr round([format %f $hlt_param_value]/1000)]
                                }
                            }
                            
                            if {[llength $ixn_param_value] == 1} {
                                append mep_args "-$ixn_param $ixn_param_value "
                            } else {
                                append mep_args "-$ixn_param \{$ixn_param_value\} "
                            }
                        }
                    }
                    
                    set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                            $mep_handle                                             \
                            $mep_args                                               \
                            -commit                                                 \
                        ]
                        
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                }
                
                # Increment params
                switch -- $mac_remote_incr_mode {
                    "none" {
                        # do not increment mac_remote
                    }
                    "increment" {
                        if {[expr ($i + 1) % $mac_remote_repeat] == 0} {
                            set mac_remote [::ixia::incrementMacAdd $mac_remote $mac_remote_step]
                            set mac_remote [ixNetworkFormatMac $mac_remote]
                        }
                    }
                    "decrement" {
                        if {[expr ($i + 1) % $mac_remote_repeat] == 0} {
                            set mac_remote [::ixia::decrementMacAdd $mac_remote $mac_remote_step]
                            set mac_remote [ixNetworkFormatMac $mac_remote]
                        }
                    }
                    default {
                        # These cases are treated at the begining of the loop
                    }
                }
                
                incr i
            }
        }
        
        if {$mode == "create"} {
            if {$handle_granularity == "per_group"} {
                incr cfm_messages_current_id
            }
            
            keylset returnList handle $msg_handles_list
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::emulation_oam_control {args} {
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
                \{::ixia::emulation_oam_control $args\}]

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
    
    # Arguments
    set man_args {
         -action                         CHOICES   start stop disable_link disable_terminating_link
                                         CHOICES   enable_all lock_link unlock_all reset
    }
    
    set opt_args {
         -port_handle                 REGEXP     ^[0-9]+/[0-9]+/[0-9]+$
         -handle                      REGEXP     ^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+$
         -link_level
         -md_level
    }

    ::ixia::parse_dashed_args -args $args -mandatory_args $man_args -optional_args $opt_args
    
    # Check to see if a connection to the IxNetwork TCL Server already exists. 
    # If it doesn't, establish it.
    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    
    if {![info exists port_handle] && ![info exists handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Error in $procName: At least one of the parameters -handle or\
                -port_handle must be provided."
    }
    
    set protocol_handles ""
    set bridge_handles ""
    if {[info exists port_handle]} {
        foreach port_h $port_handle {
            
            # Add port after connecting to IxNetwork TCL Server
            set retCode [ixNetworkPortAdd $port_h {} force]
            if {[keylget retCode status] == $::FAILURE} {
                keylset retCode log "ERROR in $procName: [keylget retCode log]"
                return $retCode
            }
        
            set retCode [ixNetworkGetPortObjref $port_h]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Unable to find the port object reference \
                        associated to the $port_h port handle -\
                        [keylget retCode log]."
                return $returnList
            }
            
            set vport_objref    [keylget retCode vport_objref]
            set protocol_objref [keylget retCode vport_objref]/protocols/cfm
            
            
            if {[lsearch $protocol_handles $protocol_objref] == -1} {
                lappend protocol_handles $protocol_objref
            }
            
            foreach bridge_handle [ixNet getList $protocol_objref bridge] {
                if {[lsearch $bridge_handles $bridge_handle] == -1} {
                    lappend bridge_handles $bridge_handle
                }
            }
        }
    }
    
    if {[info exists handle]} {
        foreach bridge_handle $handle {
            set retCode [ixNetworkGetPortFromObj $bridge_handle]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            set vport_objref [keylget retCode vport_objref]/protocols/cfm
            if {[lsearch $protocol_handles $vport_objref] == -1} {
                lappend protocol_handles $vport_objref
            }
            
            if {[lsearch $bridge_handles $bridge_handle] == -1} {
                lappend bridge_handles $bridge_handle
            }

        }
    }
    
    if {$action == "reset"} {
        set action [list stop start]
    }
    
    foreach s_action $action {
        switch -- $action {
            disable_link {
                foreach bridge_handle $bridge_handles {
                    set tmp_status [::ixia::ixNetworkNodeSetAttr      \
                            $bridge_handle                                        \
                            [list -enabled false]                                   \
                            -commit                                                   \
                        ]
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: Failed to disable bridge \
                                link $bridge_handle. [keylget tmp_status log]"
                        return $tmp_status
                    }
                }
            }
            enable_all {
                foreach bridge_handle $bridge_handles {
                    set tmp_status [::ixia::ixNetworkNodeSetAttr      \
                            $bridge_handle                                        \
                            [list -enabled true]                                    \
                            -commit                                                    \
                        ]
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: Failed to enable bridge \
                                link $bridge_handle. [keylget tmp_status log]"
                        return $tmp_status
                    }
                }
            }
            start -
            stop {
                # Check link state
                foreach protocol_objref $protocol_handles {
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
                        keylset returnList log "ERROR in $procName: Failed to $action OAM on the\
                                $vport_objref port. Port state is $portState, $portStateD."
                        return $returnList
                    }
                }
                
                foreach protocol_objref $protocol_handles {
                    debug "ixNet exec $action $protocol_objref"
                    if {[catch {ixNet exec $action $protocol_objref} retCode] || \
                            ([string first "::ixNet::OK" $retCode] == -1)} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to $action OAM on the\
                                $vport_objref port. Error code: $retCode."
                        return $returnList
                    }
                }
            }
            default {
                # action not supported; silently ignore
            }
        }
    }

    return $returnList
}


proc ::ixia::emulation_oam_info {args} {
    variable executeOnTclServer
    
    variable cfm_stats_num_calls
    set keyed_array_name cfm_stats_returned_keyed_array_$cfm_stats_num_calls
    mpincr cfm_stats_num_calls
    variable $keyed_array_name
    catch {array unset $keyed_array_name}
    array set $keyed_array_name ""
    variable cfm_stats_max_list_length
    set keyed_array_index 0
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::emulation_oam_info $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
        } else {
            set retData $retValue
        }
        
        if {![catch {keylget retData handle} keyed_a_name]} {
            if {![info exists ::ixTclSvrHandle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Not connected to TclServer."
                return $returnList
            }
            array set $keyed_a_name [eval clientSend $::ixTclSvrHandle \
                \{array get $keyed_a_name\}]
        }
        
        return $retData
    }
    
    keylset returnList status $::SUCCESS
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set man_args {
         -mode                       CHOICES   aggregate session
    }
    
    set opt_args {
         -port_handle                REGEXP    ^[0-9]+/[0-9]+/[0-9]+$             
         -handle                     ANY
         -action                     CHOICES   get_topology_stats get_message_stats
                                     DEFAULT   get_message_stats
         -return_method              CHOICES   keyed_list keyed_list_or_array array
                                     DEFAULT   keyed_list
    }

    ::ixia::parse_dashed_args -args $args -mandatory_args $man_args -optional_args $opt_args
    
    set port_handle_list ""

    # Check to see if a connection to the IxNetwork TCL Server already exists. 
    # If it doesn't, establish it.
    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    
    if {![info exists port_handle] && ![info exists handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Error in $procName: At least one of the parameters -handle or\
                -port_handle must be provided."
    }
    
    set bridge_handles ""
    if {[info exists port_handle]} {
        
        if {[llength $port_handle] > 1} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Statistics can be gathered\
                    for one port at a time. Parameter $port_handle contains a list\
                    of port handles."
            return $returnList
        }
        
        # Add port after connecting to IxNetwork TCL Server
        set retCode [ixNetworkPortAdd $port_handle {} force]
        if {[keylget retCode status] == $::FAILURE} {
            keylset retCode log "ERROR in $procName: [keylget retCode log]"
            return $retCode
        }
    
        set retCode [ixNetworkGetPortObjref $port_handle]
        
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Unable to find the port object reference \
                    associated to the $port_handle port handle -\
                    [keylget retCode log]."
            return $returnList
        }
        
        set vport_objref    [keylget retCode vport_objref]
        set protocol_objref [keylget retCode vport_objref]/protocols/cfm
        
        
        foreach bridge_handle [ixNet getList $protocol_objref bridge] {
            if {[lsearch $bridge_handles $bridge_handle] == -1} {
                lappend bridge_handles $bridge_handle
            }
        }

    }
    
    if {[info exists handle]} {
        set message_handles_to_poll ""
        set topology_handles_to_poll ""
        
        foreach bridge_handle $handle {
            if {[regexp {(^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+$)} $bridge_handle]} {
                set retCode [ixNetworkGetPortFromObj $bridge_handle]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset retCode log "ERROR in $procName: [keylget retCode log]"
                    return $retCode
                }
                
                set vport_objref     [keylget retCode vport_objref]
                set real_port_handle [keylget retCode port_handle]
                
                if {[info exists port_handle] && $port_handle != $real_port_handle} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Statistics can be gathered\
                            for one port at a time. All bridges specified with -handle\
                            parameter must be from the same port. If -port_handle was\
                            passed as parameter, the port on which the bridges were configured\
                            must be the same with the port specified with -port_handle."
                    return $returnList
                }
                
                set port_handle $real_port_handle
                
                if {[lsearch $bridge_handles $bridge_handle] == -1} {
                    lappend bridge_handles $bridge_handle
                }
    
            } elseif {[regexp {(^CFM_MSG_H_\d+$)} $bridge_handle]} {
            
                lappend message_handles_to_poll $bridge_handle
                
            } elseif {[regexp {(^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+,\d+$)} $bridge_handle]} {
                
                lappend topology_handles_to_poll $bridge_handle
                
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Invalid value for -handle\
                        parameter $bridge_handle. Parameter -handle accepts\
                        bridge handles returned by ::ixia::emulation_oam_config_topology\
                        procedure and message handles returned by ::ixia::emulation_oam_config_msg."
                return $returnList
            }
        }
    }
    
    if {$mode == "aggregate"} {
        
        set oam_status [::ixia::get_oam_aggregate_stats $port_handle $action "returnList"]
        if {[keylget oam_status status] != $::SUCCESS} {
            keylset oam_status log "Failed to get $mode $action stats. [keylget oam_status log]"
            return $oam_status
        }
        
    } else {
        if {[info exists message_handles_to_poll] && \
                $message_handles_to_poll != "" && $action == "get_message_stats"} {
            
            set tmp_status [oam_get_bridge_handles_from_messages $message_handles_to_poll]
            if {[keylget tmp_status status] != $::SUCCESS} {
                keylset tmp_status log "ERROR in $procName: [keyget tmp_status log]"
                return $tmp_status
            }
            
            foreach bridge_handle [keylget tmp_status bridge_handles] {
                set cfm_periodic_lt_status [::ixia::get_oam_learned_info        \
                                            $bridge_handle                      \
                                            $keyed_array_name                   \
                                            $message_handles_to_poll            \
                                    ]
                if {[keylget cfm_periodic_lt_status status] != $::SUCCESS} {
                    keylset cfm_periodic_lt_status log "ERROR in $procName on get_periodic_oam_lt. [keylget cfm_periodic_lt_status log]"
                    return $cfm_periodic_lt_status
                }
            }
            
            incr keyed_array_index [keylget cfm_periodic_lt_status stat_count]
            
        } elseif {[info exists topology_handles_to_poll] && \
                $topology_handles_to_poll != "" && $action == "get_topology_stats"} {
            
            set bridges_already_polled ""
            foreach bridge_raw_handle $topology_handles_to_poll {
                set bridge_handle [lindex [split $bridge_raw_handle ,] 0]
                if {[lsearch $bridges_already_polled $bridge_handle] == -1} {
                    lappend bridges_already_polled $bridge_handle
                } else {
                    continue
                }
                
                set filter_params [list -userMdLevel "allMd" -userSvlan "allVlanId" -userCvlan "allVlanId"]
                
                set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                        $bridge_handle                                          \
                        $filter_params                                          \
                        -commit                                                 \
                    ]
                    
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
                
                set ccm_status [::ixia::get_oam_ccdb_learned_info_per_topo      \
                                            $bridge_handle                      \
                                            $keyed_array_name                   \
                                            $topology_handles_to_poll           ]

                if {[keylget ccm_status status] != $::SUCCESS} {
                    keylset ccm_status log "ERROR in $procName on get_cfm_ccm. [keylget ccm_status log]"
                    return $ccm_status
                }
                incr keyed_array_index [keylget ccm_status stat_count]
            }
            
        } else {
            foreach bridge_handle $bridge_handles {
                if {$action == "get_message_stats"} {
                    set cfm_periodic_lt_status [::ixia::get_oam_learned_info     \
                                                $bridge_handle                   \
                                                $keyed_array_name                \
                                        ]
                    if {[keylget cfm_periodic_lt_status status] != $::SUCCESS} {
                        keylset cfm_periodic_lt_status log "ERROR in $procName on get_periodic_oam_lt. [keylget cfm_periodic_lt_status log]"
                        return $cfm_periodic_lt_status
                    }
                    incr keyed_array_index [keylget cfm_periodic_lt_status stat_count]
                } else {
                    
                    set filter_params [list -userMdLevel "allMd" -userSvlan "allVlanId" -userCvlan "allVlanId"]
                    
                    set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                            $bridge_handle                                          \
                            $filter_params                                          \
                            -commit                                                 \
                        ]
                        
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                    
                    set ccm_status [::ixia::get_oam_ccdb_learned_info               \
                                                $bridge_handle                      \
                                                $keyed_array_name                   ]
                    if {[keylget ccm_status status] != $::SUCCESS} {
                        keylset ccm_status log "ERROR in $procName on get_cfm_ccm. [keylget ccm_status log]"
                        return $ccm_status
                    }
                    incr keyed_array_index [keylget ccm_status stat_count]
                }
            }
        }
    }
    
    switch -- $return_method {
        "keyed_list" {
            set [subst $keyed_array_name](status) $::SUCCESS
            set retTemp [array get $keyed_array_name]
            eval "keylset returnList $retTemp"
        }
        "keyed_list_or_array" {
            if {$keyed_array_index < $cfm_stats_max_list_length} {
                set [subst $keyed_array_name](status) $::SUCCESS
                set retTemp [array get $keyed_array_name]
                return $returnList
            } else {
                keylset returnList status $::SUCCESS
                keylset returnList handle ::ixia::[subst $keyed_array_name]
                return $returnList
            }
        }
        "array" {
            keylset returnList status $::SUCCESS
            keylset returnList handle ::ixia::[subst $keyed_array_name]
        }
    }
    
    return $returnList
}
