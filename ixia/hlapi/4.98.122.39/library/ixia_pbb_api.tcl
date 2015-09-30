# Copyright © 2003-2009 by IXIA.
# All Rights Reserved.
#
# Name:
#    ixia_pbb_api.tcl
#
# Purpose:
#    A script development library containing PBB (Provider Backbone Bridging) APIs for test automation with 
#    the Ixia chassis. 
#
# Usage:
#    package req Ixia
#
# Description:
#    The procedures contained within this library include:
#        emulation_pbb_config
#        emulation_pbb_trunk_config
#        emulation_pbb_custom_tlv_config
#        emulation_pbb_info
#        emulation_pbb_control
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

proc ::ixia::emulation_pbb_config { args } {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle  \{::ixia::emulation_pbb_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set man_args {
         -mode                        CHOICES   create modify enable disable remove    
    }
    set opt_args {
         -bridge_id                   ANY
                                      DEFAULT   00:00:00:00:00:00
         -bridge_id_step              ANY
                                      DEFAULT   00:00:00:00:00:01
         -count                       NUMERIC
                                      DEFAULT   1
         -enable_optional_tlv_validation CHOICES 0 1
                                      DEFAULT   0
         -enable_out_of_sequence_detection CHOICES 0 1
                                      DEFAULT   1
         -ether_type                  CHOICES   8902 88E6
                                      DEFAULT   8902
         -handle                      ANY       
         -interface_handle            ANY       
         -mac_address_init            ANY       
         -mac_address_step            ANY
                                      DEFAULT   00:00:00:00:00:01
         -port_handle                 ANY   
         -receive_ccm                 CHOICES   0 1
                                      DEFAULT   1
         -reset                       CHOICES   0 1
                                      DEFAULT   0
         -send_ccm                    CHOICES   0 1
                                      DEFAULT   1
         -vlan_id                     RANGE     0-4095
                                      DEFAULT   0
         -vlan_id_step                RANGE     0-4095
                                      DEFAULT   1
         -vlan_user_priority          RANGE     0-4095
                                      DEFAULT   0
    }

    if [catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args  -mandatory_args $man_args \
            } errorMsg] {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg."
        return $returnList
    }
      
    array set truth {1 true 0 false enable true disable false}
    array set pbb_options_map {
        pbb_te      pbbTe
        "8902"      "35074"
        "88E6"      "35046"
    }
    
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
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When -mode is $mode -handle parameter is mandatory."
            return $returnList
        }
        
        foreach b_handle $handle {
            if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+$} $b_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -handle $b_handle is not a valid PBB Bridge handle."
                return $returnList
            }
            
            if {[ixNet exists $b_handle] == "false" || [ixNet exists $b_handle] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -handle $b_handle does not exist."
                return $returnList
            }
            
            set current_bridge_mode [ixNet getAttribute $b_handle -operationMode]
            if {$current_bridge_mode != $pbb_options_map(pbb_te)} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Operation mode cannot be cfm or y1731. It must be pbb_te for all PBB bridges."
                return $returnList
            }
        }
    }
    
    # Set PBB protocol specific options.
    set operation_mode pbb_te
    
    set global_params {
            enable_optional_tlv_validation      enableOptionalTlvValidation     truth       _none
            receive_ccm                         receiveCcm                      truth       _none
            send_ccm                            sendCcm                         truth       _none
            enabled                             enabled                         truth       _none
        }
    
    set bridge_params {
            bridge_id                           bridgeId                        mac         _none
            enable_out_of_sequence_detection    enableOutOfSequenceDetection    truth       _none
            ether_type                          etherType                       translate   _none
            operation_mode                      operationMode                   translate   _none
            enabled                             enabled                         truth       _none
        }
        
    # Check MAC parameters
    set mac_format_params [list bridge_id bridge_id_step mac_address_init mac_address_step]
    foreach mac_format_arg $mac_format_params {
        if {[info exists $mac_format_arg]} {
            set mac_format_arg_value [set $mac_format_arg]
            
            if {![isValidMacAddress $mac_format_arg_value]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Invalid mac address value $mac_format_arg_value for\
                        $mac_format_arg parameter."
                return $returnList
            }
        }
    }
    
    switch -- $mode {
        "create" {
            set enabled 1
        
            if {![info exists port_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When -mode is $mode, parameter -port_handle is mandatory."
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
            
            # Check if protocols are supported
            set retCode [checkProtocols $vport_objref]
            if {[keylget retCode status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Port $port_handle does not support protocol\
                        configuration."
                return $returnList
            }
            
            if {[info exists reset]} {
                set result [ixNetworkNodeRemoveList $protocol_objref \
                        { {child remove bridge} {} } -commit]
                if {[keylget result status] == $::FAILURE} {
                    keylset result log "ERROR in $procName: [keylget result log]"
                    return $result
                }
            }
            
            # Create protocol interfaces if necessary
            if {([info exists interface_handle]) && ([llength $interface_handle] != 0) && \
                    ([llength $interface_handle] != $count)} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Interface handle list length '[llength $interface_handle]'\
                        from -interface_handle parameter must be equal to -count parameter '$count'."
                return $returnList
            }
            
            if {![info exists interface_handle] || [llength $interface_handle] == 0} {
                set protocol_intf_options {
                    -count                       count
                    -mac_address                 mac_address_init
                    -mac_address_step            mac_address_step
                    -override_existence_check    override_existence_check
                    -override_tracking           override_tracking
                    -port_handle                 port_handle
                    -vlan_enabled                vlan_enable
                    -vlan_id                     vlan_id
                    -vlan_id_step                vlan_id_step
                    -vlan_user_priority          vlan_user_priority
                }
                
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
                    keylset returnList log "ERROR in $procName: Unable to create the\
                            protocol interfaces. [keylget intf_list log]"
                    return $returnList
                }
                
                set intf_list [keylget intf_list connected_interfaces]
                
            } else {
                set intf_list $interface_handle
            }

            # Configure pbb global (per port) params
            set ixn_global_args ""
            foreach {hlt_param ixn_param type extensions} $global_params {
                if {[info exists $hlt_param]} {
                    
                    set hlt_param_value [set $hlt_param]

                    switch -- $type {
                        value {
                            set ixn_param_value $hlt_param_value
                        }
                        truth {
                            set ixn_param_value $truth($hlt_param_value)
                        }
                        translate {
                            if {[info exists pbb_options_map($hlt_param_value)]} {
                                set ixn_param_value $pbb_options_map($hlt_param_value)
                            } else {
                                set ixn_param_value $hlt_param_value
                            }
                            
                            if {$extensions == "hex2num"} {
                                set ixn_param_value [mpformat %d $ixn_param_value]
                            }
                        }
                        mac {
                            set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                        }
                    }
                    
                    append ixn_global_args "-$ixn_param $ixn_param_value "
                }
            }
            
            if {$ixn_global_args != ""} {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                        $protocol_objref                                        \
                        $ixn_global_args                                        \
                        -commit                                                 \
                    ]
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
            }
            
            set bridge_handle_list ""
            for {set i 0} {$i < $count} {mpincr i} {
                set ixn_bridge_args ""
                
                foreach {hlt_param ixn_param type extensions} $bridge_params {
                    if {[info exists $hlt_param]} {

                        set hlt_param_value [set $hlt_param]

                        switch -- $type {
                            value {
                                set ixn_param_value $hlt_param_value
                            }
                            truth {
                                set ixn_param_value $truth($hlt_param_value)
                            }
                            translate {
                                if {[info exists pbb_options_map($hlt_param_value)]} {
                                    set ixn_param_value $pbb_options_map($hlt_param_value)
                                } else {
                                    set ixn_param_value $hlt_param_value
                                }
                                
                                if {$extensions == "hex2num"} {
                                    set ixn_param_value [mpformat %d $ixn_param_value]
                                }
                            }
                            mac {
                                set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                            }
                        }
                        
                        append ixn_bridge_args "-$ixn_param $ixn_param_value "
                    }
                }
                
                # Configure 'include all' filters for loopback/linktrace/delaymeasurement messages
                append ixn_bridge_args "-userUsabilityOption allToAll  \
                                        -userBvlan         allVlanId \
                                        -userSrcType       mepMacAll \
                                        -userDstType       mepMacAll \
                                        -userMdLevel       allMd     "
                
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
                
                set tmp_bridge_handle [keylget tmp_status node_objref]
                
                set tmp_int_status [::ixia::ixNetworkNodeAdd                            \
                        $tmp_bridge_handle                                          \
                        "interface"                                                 \
                        [list -enabled true -interfaceId [lindex $intf_list $i]]\                                 \
                        -commit                                                     \
                    ]
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
                
                lappend bridge_handle_list [keylget tmp_status node_objref]
                
                # Increment bridge parameters
                if {[info exists bridge_id_step]} {
                    set bridge_id [incrementMacAdd $bridge_id $bridge_id_step]
                }
            }
            keylset returnList  handle              $bridge_handle_list
            keylset returnList  interface_handles   $intf_list
            keylset returnList  status              $::SUCCESS
        }
        "modify" {
        
            if {[llength $handle] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Only one PBB Bridge handle can be modified with one procedure call. Parameter -handle is a list of values."
                return $returnList
            }
            
            set protocol_objref [ixNetworkGetParentObjref $handle]
            
            # Configure pbb global (per port) params
            set ixn_global_args ""
            foreach {hlt_param ixn_param type extensions} $global_params {
                if {[info exists $hlt_param]} {

                    set hlt_param_value [set $hlt_param]

                    switch -- $type {
                        value {
                            set ixn_param_value $hlt_param_value
                        }
                        truth {
                            set ixn_param_value $truth($hlt_param_value)
                        }
                        translate {
                            if {[info exists pbb_options_map($hlt_param_value)]} {
                                set ixn_param_value $pbb_options_map($hlt_param_value)
                            } else {
                                set ixn_param_value $hlt_param_value
                            }
                            
                            if {$extensions == "hex2num"} {
                                set ixn_param_value [mpformat %d $ixn_param_value]
                            }
                        }
                        mac {
                            set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                        }
                    }
                    
                    append ixn_global_args "-$ixn_param $ixn_param_value "
                }
            }
            
            if {$ixn_global_args != ""} {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                        $protocol_objref                                        \
                        $ixn_global_args                                        \
                        -commit                                                 \
                    ]
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
            }
            
            # Modify bridge parameters
            set ixn_bridge_args ""
            
            foreach {hlt_param ixn_param type extensions} $bridge_params {
                if {[info exists $hlt_param]} {
                    set hlt_param_value [set $hlt_param]

                    switch -- $type {
                        value {
                            set ixn_param_value $hlt_param_value
                        }
                        truth {
                            set ixn_param_value $truth($hlt_param_value)
                        }
                        translate {
                            if {[info exists pbb_options_map($hlt_param_value)]} {
                                set ixn_param_value $pbb_options_map($hlt_param_value)
                            } else {
                                set ixn_param_value $hlt_param_value
                            }
                            
                            if {$extensions == "hex2num"} {
                                set ixn_param_value [mpformat %d $ixn_param_value]
                            }
                        }
                        mac {
                            set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                        }
                    }
                    
                    append ixn_bridge_args "-$ixn_param $ixn_param_value "
                }
            }
            
            set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                    $handle                                                 \
                    $ixn_bridge_args                                        \
                    -commit                                                 \
                ]
            if {[keylget tmp_status status] != $::SUCCESS} {
                keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                return $tmp_status
            }
            
            if {[info exists interface_handle]} {
                if {[llength $interface_handle] > 1} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Parameter -interface_handle will modify \
                            the interface associated with the PBB Bridge handle when -mode is\
                            modify. The length of -interface_handle must be 1."
                    return $returnList
                }
                
                set pbb_interface_handle [ixNet getList $handle interface]
                
                set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                        $pbb_interface_handle                                       \
                        [list -interfaceId $interface_handle]                       \
                        -commit                                                     \
                    ]
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
            }
            
            keylset returnList  status    $::SUCCESS
            return $returnList   
        }
        "enable" -
        "disable" {
            foreach bridge_handle $handle {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                        $bridge_handle                                              \
                        [list -enabled $truth($mode)]                               \
                        -commit                                                     \
                    ]
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
            }
            keylset returnList  status  $::SUCCESS
        }
        "remove" {
            foreach bridge_handle $handle {
                debug "ixNet remove $bridge_handle"
                if {[ixNet remove $bridge_handle] != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to remove handle $bridge_handle."
                    return $returnList
                }
            }
                
            debug "ixNet commit"
            if {[ixNet commit] != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to remove -handle\
                        $bridge_handle."
                return $returnList
            }
        }
    };# End SWITCH over mode.
    keylset returnList  status    $::SUCCESS
    return $returnList
}

proc ::ixia::emulation_pbb_trunk_config { args } {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle  \{::ixia::emulation_pbb_trunk_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set man_args {      
         -mode                        CHOICES   create modify enable disable remove
    }
    set opt_args {
         -add_ccm_custom_tlvs         CHOICES   0 1
                                      DEFAULT   0
         -add_data_tlv                CHOICES   0 1
                                      DEFAULT   0
         -add_interface_status_tlv    CHOICES   0 1
                                      DEFAULT   0
         -add_lbm_custom_tlvs         CHOICES   0 1
                                      DEFAULT   0
         -add_lbr_custom_tlvs         CHOICES   0 1
                                      DEFAULT   0
         -add_ltm_custom_tlvs         CHOICES   0 1
                                      DEFAULT   0
         -add_ltr_custom_tlvs         CHOICES   0 1
                                      DEFAULT   0
         -add_organization_specific_tlv CHOICES 0 1
                                      DEFAULT   0
         -add_port_status_tlv         CHOICES   0 1
                                      DEFAULT   0
         -add_sender_id_tlv           CHOICES   0 1
                                      DEFAULT   0
         -auto_dm_iteration           RANGE     0-4294967296
                                      DEFAULT   0
         -auto_dm_timeout             RANGE     1-65535
                                      DEFAULT   30
         -auto_dm_timer               RANGE     1-65535
                                      DEFAULT   60
         -auto_lb_iteration           RANGE     0-4294967296
                                      DEFAULT   0
         -auto_lb_timeout             RANGE     1-65535
                                      DEFAULT   30
         -auto_lb_timer               RANGE     1-65535
                                      DEFAULT   60
         -auto_lt_iteration           RANGE     0-4294967296
                                      DEFAULT   0
         -auto_lt_timeout             RANGE     1-65535
                                      DEFAULT   30
         -auto_lt_timer               RANGE     1-65535
                                      DEFAULT   60
         -b_vlan_id                   RANGE     0-4095
                                      DEFAULT   1
         -b_vlan_id_step              RANGE     0-4095
                                      DEFAULT   0
         -b_vlan_priority             ANY       
         -b_vlan_tp_id                CHOICES   8100 9100 9200 88a8
                                      DEFAULT   8100
         -bridge_handle               ANY
         -cci_interval                CHOICES   3.33msec 10msec 100msec 1sec 10sec 1min 10min
                                      DEFAULT   1sec
         -ccm_priority                RANGE     0-7
                                      DEFAULT   0
         -chassis_id                  ANY       
                                      DEFAULT   00:00:00:00:00:00
         -chassis_id_length           RANGE     0-255
                                      DEFAULT   6
         -chassis_id_step             ANY       
                                      DEFAULT   00:00:00:00:00:01
         -chassis_id_sub_type         CHOICES   chassis_component interface_alias port_component mac_address network_address interface_name locally_assigned
                                      DEFAULT   chassis_component
         -count                       NUMERIC   
                                      DEFAULT   1
         -data_tlv_length             RANGE     0-1500
                                      DEFAULT   4
         -data_tlv_step               ANY       
                                      DEFAULT   00:00:00:01
         -data_tlv_value              ANY       
                                      DEFAULT   44:61:74:61
         -dmm_priority                RANGE     0-7
                                      DEFAULT   0
         -dst_mac_address             ANY       
                                      DEFAULT   00:00:00:00:00:02
         -dst_mac_address_step        ANY       
                                      DEFAULT   00:00:00:00:00:01
         -enable_auto_dm              CHOICES   0 1
                                      DEFAULT   0
         -enable_auto_lb              CHOICES   0 1
                                      DEFAULT   0
         -enable_auto_lt              CHOICES   0 1
                                      DEFAULT   0
         -enable_reverse_bvlan        CHOICES   0 1
                                      DEFAULT   0
         -handle                      ANY       
         -lbm_priority                RANGE     0-7
                                      DEFAULT   0
         -ltm_priority                RANGE     0-7
                                      DEFAULT   0
         -management_address          ANY       
                                      DEFAULT   01:02:03:03:04:05
         -management_address_domain   ANY       
                                      DEFAULT   4d:61:6e:61:67:65:6d:65:6e:74:20:41:64:64:72:20:44:6f:6d:61:69:6e
         -management_address_domain_length RANGE 0-255
                                      DEFAULT   22
         -management_address_domain_step ANY    
                                      DEFAULT   00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:01
         -management_address_length   RANGE     0-255
                                      DEFAULT   6
         -md_level_id                 RANGE 0-7
                                      DEFAULT 0
         -md_level_id_step            RANGE 0-7
                                      DEFAULT 0
         -md_name                     ANY       
                                      DEFAULT   Ixiacom    
         -md_name_format              CHOICES   none string domain_name mac_plus_2_octets
                                      DEFAULT   domain_name
         -md_name_mac_repeat_count    NUMERIC   
                                      DEFAULT   65535
         -md_name_mac_step            ANY       
                                      DEFAULT   00:00:00:00:00:00:00:01
         -md_name_wildcard_enable     CHOICES   0 1
                                      DEFAULT   0
         -md_wildcard_question_repeat_count NUMERIC 
                                      DEFAULT   1
         -md_wildcard_question_start  NUMERIC   
                                      DEFAULT   0
         -md_wildcard_question_step   NUMERIC   
                                      DEFAULT   1
         -mep_id                      RANGE 1-8190
                                      DEFAULT   1
         -mep_id_step                 RANGE 0-8191
                                      DEFAULT   1
         -mr_c_vlan_id                RANGE     0-4095
                                      DEFAULT   1
         -mr_c_vlan_priority          ANY       
         -mr_c_vlan_tp_id             CHOICES   8100 9100 9200 88a8
                                      DEFAULT   8100
         -mr_count                    NUMERIC   
                                      DEFAULT   1
         -mr_enable_vlan              CHOICES   0 1
                                      DEFAULT   1
         -mr_i_tagi_sid               RANGE     0-16777215
                                      DEFAULT   0
         -mr_inner_count              NUMERIC   
                                      DEFAULT   1
         -mr_mac_inter_range_step     ANY       
                                      DEFAULT   00:00:00:00:01:00
         -mr_mac_inter_trunk_step     ANY       
                                      DEFAULT   00:00:00:01:00:00
         -mr_mac_step                 ANY       
                                      DEFAULT   00:00:00:00:00:01
         -mr_s_vlan_id                RANGE     0-4095
                                      DEFAULT   1
         -mr_s_vlan_priority          ANY       
         -mr_s_vlan_tp_id             CHOICES   8100 9100 9200 88a8
                                      DEFAULT   8100
         -mr_stacked_vlan_id_step     RANGE     0-4094
                                      DEFAULT   1
         -mr_stacked_vlan_inter_trunk_step RANGE 0-4094
                                      DEFAULT   1
         -mr_start_mac_address        REGEXP ^([0-9a-fA-F]{4}[.:]{1}[0-9a-fA-F]{4}[.:]{1}[0-9a-fA-F]{4}[.:])|(([0-9a-fA-F]{2}[.:]{1}){5}[0-9a-fA-F]{2})$
                                      DEFAULT   00:00:00:00:00:01
         -mr_type                     CHOICES   single stacked       
                                      DEFAULT   single
         -mr_vlan_id_step             RANGE     0-4094
                                      DEFAULT   1
         -mr_vlan_inter_trunk_step    RANGE     0-4094
                                      DEFAULT   1
         -organization_specific_tlv_length RANGE 4-1500
                                      DEFAULT   4
         -organization_specific_tlv_value ANY   
                                      DEFAULT   NULL
         -override_vlan_priority      CHOICES   0 1
                                      DEFAULT   0
         -reset                       CHOICES   0 1
                                      DEFAULT   0
         -return_method               CHOICES   keyed_list keyed_list_or_array array
                                      DEFAULT   keyed_list
         -reverse_bvlan_id            RANGE     0-4095
                                      DEFAULT   1
         -reverse_bvlan_id_step       RANGE     0-4095
                                      DEFAULT   0
         -short_ma_name               ANY       
         -short_ma_name_format        ANY       
                                      DEFAULT   char_string
         -src_mac_address             ANY       
                                      DEFAULT   00:00:00:00:00:01
         -src_mac_address_step        ANY       
                                      DEFAULT   00:00:00:00:00:01
         -ttl                         RANGE     1-255
                                      DEFAULT   64
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args  -mandatory_args $man_args

    variable trunk_config_num_calls
    variable mr_config_num_calls
    set keyed_array_name_trunks trunks_returned_keyed_array_$trunk_config_num_calls
    set keyed_array_name_mr     mr_returned_keyed_array_$mr_config_num_calls
    mpincr trunk_config_num_calls
    mpincr mr_config_num_calls
    variable $keyed_array_name_trunks
    variable $keyed_array_name_mr
    catch {array unset $keyed_array_name_trunks}
    catch {array unset $keyed_array_name_mr}
    array set $keyed_array_name_trunks ""
    array set $keyed_array_name_mr ""
    variable trunks_max_list_length
    variable mr_max_list_length
        
    array set truth {1 true 0 false enable true disable false}
    array set trunk_options_map {
        "8100"              "0x8100"
        "9100"              "0x9100"
        "9200"              "0x9200"
        "88a8"              "0x88a8"
        3.33msec            3.33msec
        10msec              10msec
        100msec             100msec
        1sec                1sec
        10sec               10sec
        1min                1min
        10min               10min
        chassis_component   chassisComponent
        interface_alias     interfaceAlias
        port_component      portComponent
        mac_address         macAddress
        network_address     networkAddress
        interface_name      interfaceName
        locally_assigned    locallyAssigned
        none                noDomainName
        string              characterString
        domain_name         domainNameBasedString
        mac_plus_2_octets   macAddress2OctetInteger
        char_string         characterString
        2_octet_integer     2octetInteger
        primary_vid         primaryVid
        rfc2685_vpn_id      rfc2685VpnId
        single              singleVlan
        stacked             stackedVlan
    }
    
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
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When -mode is $mode -handle parameter is mandatory."
            return $returnList
        }
        
        foreach t_handle $handle {
            if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/trunk:\d+$} $t_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -handle $t_handle is not a valid PBB Trunk handle."
                return $returnList
            }
            
            if {[ixNet exists $t_handle] == "false" || [ixNet exists $t_handle] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -handle $t_handle does not exist."
                return $returnList
            }
        }
    }
    
    if {![info exists return_method]} {
        set return_method keyed_list
    }
    
    set trunk_params {
        add_ccm_custom_tlvs                 addCcmCustomTlvs                truth       _none
        add_data_tlv                        addDataTlv                      truth       _none
        add_interface_status_tlv            addInterfaceStatusTlv           truth       _none
        add_lbm_custom_tlvs                 addLbmCustomTlvs                truth       _none
        add_lbr_custom_tlvs                 addLbrCustomTlvs                truth       _none
        add_ltm_custom_tlvs                 addLtmCustomTlvs                truth       _none
        add_ltr_custom_tlvs                 addLtrCustomTlvs                truth       _none
        add_organization_specific_tlv       addOrganizationSpecificTlv      truth       _none
        add_port_status_tlv                 addPortStatusTlv                truth       _none
        add_sender_id_tlv                   addSenderIdTlv                  truth       _none
        auto_dm_iteration                   autoDmIteration                 value       _none
        auto_dm_timeout                     autoDmTimeout                   value       _none
        auto_dm_timer                       autoDmTimer                     value       _none
        auto_lb_iteration                   autoLbIteration                 value       _none
        auto_lb_timeout                     autoLbTimeout                   value       _none
        auto_lb_timer                       autoLbTimer                     value       _none
        auto_lt_iteration                   autoLtIteration                 value       _none
        auto_lt_timeout                     autoLtTimeout                   value       _none
        auto_lt_timer                       autoLtTimer                     value       _none
        b_vlan_id                           bVlanId                         value       _none
        b_vlan_priority                     bVlanPriority                   value       _none
        b_vlan_tp_id                        bVlanTpId                       translate   _none
        cci_interval                        cciInterval                     translate   _none
        ccm_priority                        ccmPriority                     value       _none
        chassis_id                          chassisId                       increment   _none
        chassis_id_length                   chassisIdLength                 value       _none
        chassis_id_sub_type                 chassisIdSubType                translate   _none
        data_tlv_length                     dataTlvLength                   value       _none
        data_tlv_value                      dataTlvValue                    increment   _none
        dmm_priority                        dmmPriority                     value       _none
        dst_mac_address                     dstMacAddress                   mac         _none
        enable_auto_dm                      enableAutoDm                    truth       _none
        enable_auto_lb                      enableAutoLb                    truth       _none
        enable_auto_lt                      enableAutoLt                    truth       _none
        enable_reverse_bvlan                enableReverseBvlan              truth       _none
        enabled                             enabled                         truth       _none
        lbm_priority                        lbmPriority                     value       _none
        ltm_priority                        ltmPriority                     value       _none
        management_address                  managementAddress               value       _none
        management_address_domain           managementAddressDomain         increment   _none
        management_address_domain_length    managementAddressDomainLength   value       _none
        management_address_length           managementAddressLength         value       _none
        md_level_id                         mdLevelId                       value       _none
        md_name                             mdName                          special     _none
        md_name_format                      mdNameFormat                    translate   _none
        mep_id                              mepId                           value       _none
        organization_specific_tlv_length    organizationSpecificTlvLength   value       _none
        organization_specific_tlv_value     organizationSpecificTlvValue    value       _none
        override_vlan_priority              overrideVlanPriority            truth       _none
        reverse_bvlan_id                    reverseBvlanId                  value       _none
        short_ma_name                       shortMaName                     value       _none
        short_ma_name_format                shortMaNameFormat               translate   _none
        src_mac_address                     srcMacAddress                   mac         _none
        ttl                                 ttl                             value       _none
    }

    # Incremental values for trunk
    array set increment_map {
        chassis_id                  chassis_id_step
        data_tlv_value              data_tlv_step
        management_address_domain   management_address_domain_step
    }
    
    set trunkIncrParamList {
        mep_id           mep_id_step           integer
        b_vlan_id        b_vlan_id_step        integer
        reverse_bvlan_id reverse_bvlan_id_step integer
        src_mac_address  src_mac_address_step  mac
        dst_mac_address  dst_mac_address_step  mac
        md_level_id      md_level_id_step      integer
    }
    
    if { [info exists md_name_format] && $md_name_format == "mac_plus_2_octets" } {
        # Default for this mode.
        set md_name "00:00:00:00:00:AC:00"
    }
    
    set mr_params {
            enabled                             enabled                         truth       _none
            mr_c_vlan_id                        cVlanId                         increment   _none
            mr_c_vlan_priority                  cVlanPriority                   value       _none
            mr_c_vlan_tp_id                     cVlanTpId                       value       _none
            mr_enable_vlan                      enableVlan                      truth       _none
            mr_i_tagi_sid                       iTagiSid                        value       _none
            mr_inner_count                      count                           value       _none
            mr_mac_step                         step                            mac         _none
            mr_s_vlan_id                        sVlanId                         increment   _none
            mr_s_vlan_priority                  sVlanPriority                   value       _none
            mr_s_vlan_tp_id                     sVlanTpId                       value       _none
            mr_start_mac_address                startMacAddress                 increment   _none
            mr_type                             type                            translate   _none
    }         

    # Incremental values for mac ranges
    array set mr_increment_map {
        mr_s_vlan_id                mr_vlan_id_step
        mr_c_vlan_id                mr_stacked_vlan_id_step
        mr_start_mac_address        mr_mac_inter_range_step
    }
    array set mr_increment_map_trunk {
        mr_s_vlan_id                mr_vlan_inter_trunk_step
        mr_c_vlan_id                mr_stacked_vlan_inter_trunk_step
        mr_start_mac_address        mr_mac_inter_trunk_step
    }
    
    # Check MAC parameters
    set mac_format_params [list dst_mac_address src_mac_address mr_mac_step mr_start_mac_address]
    foreach mac_format_arg $mac_format_params {
        if {[info exists $mac_format_arg]} {
            set mac_format_arg_value [set $mac_format_arg]
            
            if {![isValidMacAddress $mac_format_arg_value]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Invalid mac address value $mac_format_arg_value for\
                        $mac_format_arg parameter."
                return $returnList
            }
        }
    }

    switch -- $mode {
        "create" {
            set enabled 1
            
            if {![info exists bridge_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When -mode is $mode, parameter -bridge_handle is mandatory."
                return $returnList
            }
            
            if {[llength $bridge_handle] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: PBB Trunk \
                        can be added only on one PBB Bridge handle with one procedure\
                        call. Parameter -bridge_handle contains a list of PBB Bridge\
                        handles."
                return $returnList
            }
            
            if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+$} $bridge_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -bridge_handle
                        $bridge_handle is not a valid PBB Bridge handle."
                return $returnList
            }
            
            if {[ixNet exists $bridge_handle] == "false" || [ixNet exists $bridge_handle] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -bridge_handle
                        $bridge_handle does not exist."
                return $returnList
            }
            
            # Remove all links from this bridge if reset is present
            if {[info exists reset]} {
                set result [ixNetworkNodeRemoveList $bridge_handle \
                        { {child remove trunk} {} } -commit]
                if {[keylget result status] == $::FAILURE} {
                    keylset result log "ERROR in $procName: [keylget result log]"
                    return $result
                }
            }
            
            set repeatCounter 1
            set blockIndex    0
            
            for {set counter 0} {$counter < $count} {incr counter} {
                set trunk_args ""
                
                foreach {hlt_param ixn_param p_type f_process} $trunk_params {

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
                                if {[info exists trunk_options_map($hlt_param_value)]} {
                                    set ixn_param_value $trunk_options_map($hlt_param_value)
                                } else {
                                    set ixn_param_value $hlt_param_value
                                }
                            }
                            mac {
                                set ixn_param_value $hlt_param_value
                            }
                            increment {
                                set newParamValue $hlt_param_value
                                for {set i 0} {$i < $counter} {incr i} {
                                    set newParamValue [::ixia::incr_random_mac_like_addr $newParamValue [set $increment_map($hlt_param)]]
                                }
                                set ixn_param_value $newParamValue
                            }
                            special {
                                if { $md_name_format == "mac_plus_2_octets" } {
                                    set currentReplacement $md_name
                                    for {set i 0} {$i < $blockIndex} {incr i} {
                                        set currentReplacement [::ixia::incr_random_mac_like_addr $currentReplacement $md_name_mac_step]
                                    }
                                    set plusLen [llength [split $currentReplacement ":"]]
                                    if {$plusLen == 8} {
                                        scan $currentReplacement "%x:%x:%x:%x:%x:%x:%x:%x" q1 q2 q3 q4 q5 q6 extra1 extra2
                                    } else {
                                        scan $currentReplacement "%x:%x:%x:%x:%x:%x:%x" q1 q2 q3 q4 q5 q6 extra2
                                        set extra1 0
                                    }
                                    set currentReplacement [format "%02x %02x %02x %02x %02x %02x-%d" $q1 $q2 $q3 $q4 $q5 $q6 [format %d [expr ($extra1 << 8) + $extra2] ]]
                                    set ixn_param_value $currentReplacement
                                    if { $repeatCounter == $md_name_mac_repeat_count } {
                                        incr blockIndex
                                        set repeatCounter 1
                                    } else {
                                        incr repeatCounter
                                    }
                                } else {
                                    if { $truth($md_name_wildcard_enable) == "true" } {
                                        set currentReplacement [expr $md_wildcard_question_start + $blockIndex * $md_wildcard_question_step]
                                        set currentReplacement [string replace $md_name [string first "?" $md_name] [string first "?" $md_name] $currentReplacement]
                                        set ixn_param_value $currentReplacement
                                        if { $repeatCounter == $md_wildcard_question_repeat_count } {
                                            incr blockIndex
                                            set repeatCounter 1
                                        } else {
                                            incr repeatCounter
                                        }
                                    } else {
                                        set ixn_param_value $hlt_param_value
                                    }
                                }
                            }
                        }
                        
                        if {[llength $ixn_param_value] > 1} {
                            append trunk_args "-$ixn_param \{$ixn_param_value\} "
                        } else {
                            append trunk_args "-$ixn_param $ixn_param_value "
                        }
                        
                    }
                }
                
                if {$trunk_args != ""} {
                    set tmp_status [::ixia::ixNetworkNodeAdd                            \
                            $bridge_handle                                              \
                            "trunk"                                                     \
                            $trunk_args                                                 \
                            -commit                                                     \
                        ]
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                    
                    set trunk_handle [keylget tmp_status node_objref]
                    
                    lappend trunk_handle_list $trunk_handle
                }
                
                # Create PBB-TE MAC Ranges
                set mac_ranges_list [list]
                for {set inner_counter 0} {$inner_counter < $mr_count} {incr inner_counter} {
                    set mr_args ""
                    foreach {hlt_param ixn_param p_type f_process} $mr_params {
    
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
                                    if {[info exists trunk_options_map($hlt_param_value)]} {
                                        set ixn_param_value $trunk_options_map($hlt_param_value)
                                    } else {
                                        set ixn_param_value $hlt_param_value
                                    }
                                }
                                mac {
                                    set ixn_param_value $hlt_param_value
                                }
                                increment {
                                    set newParamValue $hlt_param_value
                                    for {set i 0} {$i < $counter} {incr i} {
                                        if {[string first ":" $newParamValue] > 0} {
                                            set newParamValue [::ixia::incr_random_mac_like_addr $newParamValue [set $mr_increment_map_trunk($hlt_param)]]
                                        } else {
                                            set newParamValue [expr $newParamValue + [set $mr_increment_map_trunk($hlt_param)]]
                                        }
                                    }
                                    for {set i 0} {$i < $inner_counter} {incr i} {
                                        if {[string first ":" $newParamValue] > 0} {
                                            set newParamValue [::ixia::incr_random_mac_like_addr $newParamValue [set $mr_increment_map($hlt_param)]]
                                        } else {
                                            set newParamValue [expr $newParamValue + [set $mr_increment_map($hlt_param)]]
                                        }
                                    }
                                    set ixn_param_value $newParamValue
                                }
                            }
                            
                            if {[llength $ixn_param_value] > 1} {
                                append mr_args "-$ixn_param \{$ixn_param_value\} "
                            } else {
                                append mr_args "-$ixn_param $ixn_param_value "
                            }
                            
                        }
                    }

                    if {$mr_args != ""} {
                        set tmp_status [::ixia::ixNetworkNodeAdd                            \
                                $trunk_handle                                               \
                                "macRanges"                                                 \
                                $mr_args                                                    \
                                -commit                                                     \
                            ]
                        if {[keylget tmp_status status] != $::SUCCESS} {
                            keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                            return $tmp_status
                        }
                        
                        set mr_handle [keylget tmp_status node_objref]
                        
                        lappend mac_ranges_list $mr_handle
                    }
                } ;# end for mac ranges inner counter
                # Increment trunk params
                foreach {incrParamStart incrParamStep incrParamType} $trunkIncrParamList {
                    if {[info exists $incrParamStart] && [info exists $incrParamStep]} {
                        switch -- $incrParamType {
                            integer {
                                incr $incrParamStart [set $incrParamStep]
                            }
                            mac {
                                set $incrParamStart [join [::ixia::incrementMacAdd [set $incrParamStart] [set $incrParamStep] ] :]
                            }
                        }
                    }
                }
            } ;# end for count
            
            # trunk_handle_list and mac_ranges_list are now available.
            
            switch -- $return_method {
                "keyed_list" {
                    keylset returnList trunk_handle $trunk_handle_list
                    keylset returnList mr_handle    $mac_ranges_list
                    keylset returnList status       $::SUCCESS
                    return $returnList
                }
                "keyed_list_or_array" {
                    if {[llength $trunk_handle_list] < $::ixia::trunks_max_list_length} {
                        keylset returnList trunk_handle $trunk_handle_list
                        keylset returnList mr_handle    $mac_ranges_list
                        keylset returnList status       $::SUCCESS
                        return $returnList
                    } else {
                        keylset returnList status $::SUCCESS
                        keylset returnList trunk_handle ::ixia::[subst $keyed_array_name_trunks]
                        keylset returnList mr_handle    ::ixia::[subst $keyed_array_name_mr]
                        return $returnList
                    }
                }
                "array" {
                    keylset returnList status $::SUCCESS
                    keylset returnList trunk_handle ::ixia::[subst $keyed_array_name_trunks]
                    keylset returnList mr_handle    ::ixia::[subst $keyed_array_name_mr]
                    return $returnList
                }
            }
            
        }
        "modify" {
            
            if {[llength $handle] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Only one PBB Trunk \
                        handle can be modified with one procedure call.\
                        Parameter -handle is a list of PBB Trunk handles."
                return $returnList
            }
            
            set trunk_args ""
            
            foreach {hlt_param ixn_param p_type f_process} $trunk_params {

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
                            if {[info exists trunk_options_map($hlt_param_value)]} {
                                set ixn_param_value $trunk_options_map($hlt_param_value)
                            } else {
                                set ixn_param_value $hlt_param_value
                            }
                        }
                        mac {
                            set ixn_param_value $hlt_param_value
                        }
                        increment {
                            set newParamValue $hlt_param_value
                            set ixn_param_value $newParamValue
                        }
                        special {
                            set ixn_param_value $hlt_param_value
                        }
                    }
                    
                    if {[llength $ixn_param_value] > 1} {
                        append trunk_args "-$ixn_param \{$ixn_param_value\} "
                    } else {
                        append trunk_args "-$ixn_param $ixn_param_value "
                    }
                    
                }
            }
            
            if {$trunk_args != ""} {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                        $handle                                                     \
                        $trunk_args                                                 \
                        -commit                                                     \
                    ]
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
                
                set trunk_handle $handle
                
            }
            
            set listOfMacRanges [ixNet getL $trunk_handle macRanges]
            set mr_count [llength $listOfMacRanges]
            
            # Modify PBB-TE MAC Ranges
            for {set inner_counter 0} {$inner_counter < $mr_count} {incr inner_counter} {
                set mr_args ""
                foreach {hlt_param ixn_param p_type f_process} $mr_params {

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
                                if {[info exists trunk_options_map($hlt_param_value)]} {
                                    set ixn_param_value $trunk_options_map($hlt_param_value)
                                } else {
                                    set ixn_param_value $hlt_param_value
                                }
                            }
                            mac {
                                set ixn_param_value $hlt_param_value
                            }
                            increment {
                                set newParamValue $hlt_param_value
                                set ixn_param_value $newParamValue
                            }
                        }
                        
                        if {[llength $ixn_param_value] > 1} {
                            append mr_args "-$ixn_param \{$ixn_param_value\} "
                        } else {
                            append mr_args "-$ixn_param $ixn_param_value "
                        }
                        
                    }
                }
                
                set trunk_mac_range_handle [lindex $listOfMacRanges $inner_counter]
                
                if {$mr_args != ""} {
                    set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                            $trunk_mac_range_handle                                     \
                            $mr_args                                                    \
                            -commit                                                     \
                        ]
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                    
                }
            } ;# end for mac ranges inner counter
            
            keylset returnList status $::SUCCESS
            keylset returnList trunk_handle $trunk_handle
            keylset returnList mr_handle    $listOfMacRanges
        }
        "enable" -
        "disable" {
            foreach trunk_handle $handle {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                        $trunk_handle                                               \
                        [list -enabled $truth($mode)]                               \
                        -commit                                                     \
                    ]
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
            }
            keylset returnList  status  $::SUCCESS
        }
        "remove" {
            foreach trunk_handle $handle {
                debug "ixNet remove $trunk_handle"
                if {[ixNet remove $trunk_handle] != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to remove handle $trunk_handle."
                    return $returnList
                }
            }
                
            debug "ixNet commit"
            if {[ixNet commit] != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to remove -handle\
                        $trunk_handle."
                return $returnList
            }
        }
    };# End SWITCH over mode.
    keylset returnList  status    $::SUCCESS
    return $returnList
}

proc ::ixia::emulation_pbb_custom_tlv_config { args } {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle  \{::ixia::emulation_pbb_custom_tlv_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set man_args {   
         -mode                        CHOICES   create modify enable disable remove
    }
    set opt_args {
         -bridge_handle               ANY
         -count                       NUMERIC
                                      DEFAULT   1
         -handle                      ANY       
         -include_in_ccm              CHOICES   0 1
                                      DEFAULT   0
         -include_in_lbm              CHOICES   0 1
                                      DEFAULT   0
         -include_in_lbr              CHOICES   0 1
                                      DEFAULT   0
         -include_in_ltm              CHOICES   0 1
                                      DEFAULT   0
         -include_in_ltr              CHOICES   0 1
                                      DEFAULT   0
         -length                      NUMERIC   
                                      DEFAULT   0
         -reset                       CHOICES   0 1
                                      DEFAULT   0
         -type                        ANY       
                                      DEFAULT   0
         -value                       ANY       
         -value_step                  ANY       
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
    
    array set pbb_options_map {
    }
    
    set custom_tlv_params {
            enabled                             enabled         truth       _none
            include_in_ccm                      includeInCcm    truth       _none
            include_in_lbm                      includeInLbm    truth       _none
            include_in_lbr                      includeInLbr    truth       _none
            include_in_ltm                      includeInLtm    truth       _none
            include_in_ltr                      includeInLtr    truth       _none
            length                              length          value       _none
            type                                type            value       _none
            value                               value           compute     _none
        }
        
    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
    }

    if {$mode != "create"} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When -mode is $mode -handle parameter is mandatory."
            return $returnList
        }
        
        foreach ct_handle $handle {
            if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/customTlvs:\d+$} $ct_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -handle $ct_handle is not a valid PBB Custom TLV handle."
                return $returnList
            }
            
            if {[ixNet exists $ct_handle] == "false" || [ixNet exists $ct_handle] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -handle $ct_handle does not exist."
                return $returnList
            }
        }
    }
    
    array set truth {1 true 0 false enable true disable false}
    
    switch -- $mode {
        "create" {
            set enabled 1
            
            # Check if bridge_handle parameter is ok
            
            if {![info exists bridge_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When -mode is $mode, parameter -bridge_handle is mandatory."
                return $returnList
            }
            
            if {[llength $bridge_handle] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: PBB Custom TLVs can be added only on one \
                        PBB Bridge handle with one procedure call. Parameter -bridge_handle contains a\
                        list of PBB Bridge handles."
                return $returnList
            }
            
            if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+$} $bridge_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -bridge_handle $bridge_handle is not a valid PBB Bridge handle."
                return $returnList
            }
            
            if {[ixNet exists $bridge_handle] == "false" || [ixNet exists $bridge_handle] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -bridge_handle $bridge_handle does not exist."
                return $returnList
            }

            set current_bridge_mode [ixNet getAttribute $bridge_handle -operationMode]
            if {$current_bridge_mode != "pbbTe"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Operation mode cannot be cfm or y1731. It must be pbb_te for PBB."
                return $returnList
            }

            # Remove all md meg from this bridge if reset is present
            if {[info exists reset]} {
                set result [ixNetworkNodeRemoveList $bridge_handle \
                        { {child remove customTlvs} {} } -commit]
                if {[keylget result status] == $::FAILURE} {
                    keylset result log "ERROR in $procName: [keylget result log]"
                    return $result
                }
            }
            
            # Check HEX parameters and format them correctly
            # Bring them to 0x001122 format and left pad them if necessary
            if {$length == 0} {
                catch {unset value}
                catch {unset value_step}
            } else {
                if {![info exists value]} {
                    
                    set value "0x00"
                    
                } else {
                    if {![isValidHex $value $length]} {
                    
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Parameter -value $value\
                                is not a valid HEX number or has a length greater than\
                                -length $length."
                        
                        return $returnList
                    } else {
                        # transform from any hex format to list format {00 11 22}
                        set value [::ixia::hex2list $value]
                        
                        # transform from list format to 0x001122 format
                        set value "0x[regsub -all { } $value {}]"
                        
                        # Left Pad with zero and transform back to list
                        set value [::ixia::format_hex $value [mpexpr $length * 8]]
                        
                        # transform the zero left padded value from list format to 0x001122 format
                        set value "0x[regsub -all { } $value {}]"
                    }
                }
                
                if {![info exists value_step]} {
                    
                    set value_step "0x01"
                    
                } else {
                    
                    if {![isValidHex $value_step $length]} {
                    
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Parameter -value_step $value_step\
                                is not a valid HEX number or has a length greater than\
                                -length $length."
                        
                        return $returnList
                    } else {
                        # transform from any hex format to list format {00 11 22}
                        set value_step [::ixia::hex2list $value_step]
                        
                        # transform from list format to 0x001122 format
                        set value_step "0x[regsub -all { } $value_step {}]"
                        
                        # Left Pad with zero and transform back to list
                        set value_step [::ixia::format_hex $value_step [mpexpr $length * 8]]
                        
                        # transform the zero left padded value from list format to 0x001122 format
                        set value_step "0x[regsub -all { } $value_step {}]"
                    }
                }
            }

            for {set ct_counter 0} {$ct_counter < $count} {incr ct_counter} {
                
                set ct_args ""

                foreach {hlt_param ixn_param p_type extensions} $custom_tlv_params {

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
                                if {[info exists pbb_options_map($hlt_param_value)]} {
                                    set ixn_param_value $pbb_options_map($hlt_param_value)
                                } else {
                                    set ixn_param_value $hlt_param_value
                                }
                            }
                            compute {
                                # value must be incremented according to steps
                                if {$ct_counter == 0} {
                                    set ixn_param_value \{[format_hex $hlt_param_value [mpexpr $length * 8]]\}
                                } else {
                                    if {[info exists value_step]} {
                                        set incr_ammount    [mpexpr $value_step * $ct_counter]
                                        set ixn_param_value [mpexpr $hlt_param_value + $incr_ammount]
                                        set ixn_param_value [mpformat %x $ixn_param_value]
                                        set ixn_param_value \{[format_hex $ixn_param_value [mpexpr $length * 8] ]\}
                                    } else {
                                        set ixn_param_value \{[format_hex $hlt_param_value [mpexpr $length * 8]]\}
                                    }
                                }
                            }
                        }
                        
                        append ct_args "-$ixn_param $ixn_param_value "
                    }
                }
                
                if {$ct_args != ""} {
                    set tmp_status [::ixia::ixNetworkNodeAdd                            \
                            $bridge_handle                                              \
                            "customTlvs"                                                \
                            $ct_args                                                    \
                            -commit                                                     \
                        ]
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                    
                    set custom_tlv_handle [keylget tmp_status node_objref]
                    
                    lappend ct_handle_list $custom_tlv_handle
                }
            }

            keylset returnList handle $ct_handle_list
        }
        "modify" {
            if {[llength $handle] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Only one PBB Custom TLV \
                        handle can be modified with one procedure call.\
                        Parameter -handle is a list of PBB Custom TLV handles."
                return $returnList
            }
            
            # Validate -value and -length
            # IxNetwork pads with zeros on the right
            # HLT will pad with zeros on the left and some extra operations need to be done
            
            if {[info exists length] || [info exists value]} {
                set ixn_length [ixNet getAttribute $handle -length]
                set ixn_value  [ixNet getAttribute $handle -value]
            }
            
            if {[info exists value]} {
                if {[info exists length] && ![isValidHex $value $length]} {
                  
                   keylset returnList status $::FAILURE
                   keylset returnList log "ERROR in $procName: Parameter -value $value\
                           is not a valid HEX number or has a length greater than\
                           -length $length."
                   
                   return $returnList
                }
                
                if {![info exists length] && ![isValidHex $value $ixn_length]} {
                  
                   keylset returnList status $::FAILURE
                   keylset returnList log "ERROR in $procName: Parameter -value $value\
                           is not a valid HEX number or has a length greater than\
                           the length $ixn_length configured on the $handle Custom TLV."
                   
                   return $returnList
                }
                
                if {![info exists length]} {
                    set tmp_length $ixn_length
                } else {
                    set tmp_length $length
                }
                 
                # transform from any hex format to list format {00 11 22}
                set value [::ixia::hex2list $value]
                
                # transform from list format to 0x001122 format
                set value "0x[regsub -all { } $value {}]"
                
                # Left Pad with zero and transform back to list
                set value [::ixia::format_hex $value [mpexpr $tmp_length * 8]]
                
#                 # transform the zero left padded value from list format to 0x001122 format
#                 set value "0x[regsub -all { } $value {}]"
            }
            
            if {[info exists length] && $length != 0 && ![info exists value]} {
                if {$length > $ixn_length} {
                    # leftpad with zeros ixn_value
                    set value "0x[regsub -all { } $ixn_value {}]"
                    set value [format_hex $value [mpexpr $length * 8]]
                } elseif {$length < $ixn_length} {
                    # remove hex from MSB -> LSB
                    set value [lreplace $ixn_value 0 [mpexpr $ixn_length - $length - 1]] 
                } else {
                    # do nothing
                }
            }
            
            set ct_args ""

            foreach {hlt_param ixn_param p_type extensions} $custom_tlv_params {

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
                            if {[info exists pbb_options_map($hlt_param_value)]} {
                                set ixn_param_value $pbb_options_map($hlt_param_value)
                            } else {
                                set ixn_param_value $hlt_param_value
                            }
                        }
                        compute {
                            set ixn_param_value \{$hlt_param_value\}
                        }
                    }
                    
                    append ct_args "-$ixn_param $ixn_param_value "
                }
            }
            
            if {$ct_args != ""} {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                        $handle                                                     \
                        $ct_args                                                    \
                        -commit                                                     \
                    ]
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
            }
        }
        "enable" -
        "disable" {
            foreach ct_handle $handle {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                        $ct_handle                                                  \
                        [list -enabled $truth($mode)]                               \
                        -commit                                                     \
                    ]
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
            }
        }
        "remove" {
            foreach ct_handle $handle {
                debug "ixNet remove $ct_handle"
                if {[ixNet remove $ct_handle] != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to remove handle $ct_handle."
                    return $returnList
                }
            }
                
            debug "ixNet commit"
            if {[ixNet commit] != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to remove -handle\
                        $handle."
                return $returnList
            }
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::emulation_pbb_info { args } {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle  \{::ixia::emulation_pbb_info $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set man_args {
         -mode                        CHOICES   set_filters get_ccm get_periodic_oam_lt get_periodic_oam_lb get_periodic_oam_dm get_lt get_lb get_dm aggregated_stats get_all_learned_info
    }
    set opt_args {
         -handle                      ANY
         -port_handle                 ANY
         -return_method               CHOICES keyed_list keyed_list_or_array array
                                      DEFAULT keyed_list
         -user_bvlan                  CHOICES   all_vlan_id no_vlan_id vlan_id
         -user_bvlan_id               ANY       
         -user_bvlan_priority         ANY       
         -user_bvlan_tpid             CHOICES   8100 9100 9200 88A8
         -user_delay_type             CHOICES   dm dvm
         -user_dst_mac_address        ANY       
         -user_dst_mep_id             ANY       
         -user_dst_type               CHOICES   mep_mac mep_id mep_mac_all mep_id_all
         -user_learned_info_time_out  ANY       
         -user_mdlevel                CHOICES   0 1 2 3 4 5 6 7 all_md
         -user_src_mac_address        ANY       
         -user_src_mep_id             ANY       
         -user_src_type               CHOICES   mep_mac mep_id mep_mac_all mep_id_all
         -user_transaction_id         ANY       
         -user_ttl_interval           ANY       
         -user_usability_option       CHOICES   manual one_to_one one_to_all all_to_one all_to_all
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
    
    array set pbb_options_map {
        all_vlan_id               allVlanId
        no_vlan_id                noVlanId
        vlan_id                   vlanId
        8100                      0x8100
        9100                      0x9100
        9200                      0x9200
        88A8                      0x88A8
        mep_mac                   mepMac
        mep_id                    mepId
        mep_mac_all               mepMacAll
        mep_id_all                mepIdAll
        all_md                    allMd
        link_trace                linkTrace
        delay_measurement         delayMeasurement
        all_formats               allFormats
        primary_vid               primaryVid
        char_string               characterString
        2_octet_integer           twoOctetInteger
        rfc2685_vpn_id            rfc2685VpnId
        one_to_one                oneToOne
        one_to_all                oneToAll
        all_to_one                allToOne
        all_to_all                allToAll
    }
        
    set mipmep_params {
        user_delay_type             userPbbTeDelayType          translate   _none
        user_dst_mac_address        userDstMacAddress           mac         _none
        user_dst_mep_id             userDstMepId                value       _none
        user_dst_type               userDstType                 translate   _none
        user_learned_info_time_out  userLearnedInfoTimeOut      value       _none
        user_mdlevel                userMdLevel                 translate   _none
        user_periodic_oam_type      userPeriodicOamType         translate   _none
        user_src_mac_address        userSrcMacAddress           mac         _none
        user_src_mep_id             userSrcMepId                value       _none
        user_src_type               userSrcType                 translate   _none
        user_transaction_id         userTransactionId           value       _none
        user_ttl_interval           userTtlInterval             value       _none
        user_usability_option       userUsabilityOption         translate   _none
    }
    
    set aggregated_stat_list {
        "Port Name"
                port_name
        "Bridges Configured"
                bridges_configured
        "Bridges Running"
                bridges_running
        "MEPs Configured"
                meps_configured
        "MEPs Running"
                meps_running
        "MAs Configured"
                mas_configured
        "MAs Running"
                mas_running
        "Remote MEPs"
                remote_meps
        "Trunks Configured"
                trunks_configured
        "Trunks Running"
                trunks_running
        "CCM Tx"
                ccm_tx
        "CCM Rx"
                ccm_rx
        "LTM Tx"
                ltm_tx
        "LTM Rx"
                ltm_rx
        "LTR Tx"
                ltr_tx
        "LTR Rx"
                ltr_rx
        "LBM Tx"
                lbm_tx
        "LBM Rx"
                lbm_rx
        "LBR Tx"
                lbr_tx
        "LBR Rx"
                lbr_rx
        "AIS Tx"
                ais_tx
        "AIS Rx"
                ais_rx
        "DMM Tx"
                dmm_tx
        "DMM Rx"
                dmm_rx
        "DMR Tx"
                dmr_tx
        "DMR Rx"
                dmr_rx
        "Packet Tx"
                packet_tx
        "Packet Rx"
                packet_rx
        "Invalid CCM Rx"
                invalid_ccm_rx
        "Invalid LBM Rx"
                invalid_lbm_rx
        "Invalid LBR Rx"
                invalid_lbr_rx
        "Invalid LTR Rx"
                invalid_ltr_rx
        "Defective RMEPS"
                defective_rmeps
        "CCM Unexpected Period"
                ccm_unexpected_period
        "Out of Sequence CCM Rx"
                out_of_sequence_ccm_rx
        "RMEP Ok"
                rmep_ok
        "RMEP Error NoDefect"
                rmep_error_nodefect
        "RMEP Error Defect"
                rmep_error_defect
        "MEP FNG Reset"
                mep_fng_reset
        "MEP FNG Defect"
                mep_fng_defect
        "MEP FNG DefectReported"
                mep_fng_defect_reported
        "MEP FNG DefectClearing"
                mep_fng_defect_clearing
        "LR Respond"
                lr_respond
    }  
    
    set keyed_array_index 0
    variable pbb_stats_num_calls
    set keyed_array_name pbb_stats_returned_keyed_array_$pbb_stats_num_calls
    mpincr pbb_stats_num_calls
    variable $keyed_array_name
    catch {array unset $keyed_array_name}
    array set $keyed_array_name ""
    variable pbb_stats_max_list_length
    
    if {![info exists return_method]} {
        set return_method keyed_list
    }
    
    # Identify user_periodic_oam_type according to the current mode...
    if {[string first "_lt" $mode] > 0} {
        set user_periodic_oam_type link_trace
    } elseif {[string first "_lb" $mode] > 0} {
        set user_periodic_oam_type loopback
    } elseif {[string first "_dm" $mode] > 0} {
        set user_periodic_oam_type delay_measurement
    } else {
        # let it be unset
    }

    if {$mode != "aggregated_stats"} {

        # Check if bridge_handle parameter is ok
        
        if {[info exists handle]} {
            set bridge_handle $handle
        }
            
        if {![info exists bridge_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Parameter -bridge_handle is mandatory."
            return $returnList
        }
        
        if {[llength $bridge_handle] > 1} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: PBB Statistics can be configured\
                    and read only on one PBB Bridge handle with one procedure\
                    call. Parameter -bridge_handle contains a list of PBB Bridges\
                    handles."
            return $returnList
        }
        
        if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+$} $bridge_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Parameter -bridge_handle
                    $bridge_handle is not a valid PBB Bridge handle."
            return $returnList
        }
        
        if {[ixNet exists $bridge_handle] == "false" || [ixNet exists $bridge_handle] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Parameter -bridge_handle
                    $bridge_handle does not exist."
            return $returnList
        }
    
        set current_bridge_mode [ixNet getAttribute $bridge_handle -operationMode]
        if {$current_bridge_mode != "pbbTe"} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Operation mode cannot be cfm or y1731. It must be pbb_te for all PBB bridges."
            return $returnList
        }
    
    }

    if {$mode == "set_filters"} {
        
        set stat_args ""

        foreach {hlt_param ixn_param p_type extensions} $mipmep_params {

            if {[info exists $hlt_param]} {
                
                set hlt_param_value [set $hlt_param]

                switch -- $p_type {
                    "value" {
                        set ixn_param_value $hlt_param_value
                    }
                    "truth" {
                        set ixn_param_value $truth($hlt_param_value)
                    }
                    "translate" {
                        if {[info exists pbb_options_map($hlt_param_value)]} {
                            set ixn_param_value $pbb_options_map($hlt_param_value)
                        } else {
                            set ixn_param_value $hlt_param_value
                        }
                    }
                    "mac" {
                        if {![isValidMacAddress $hlt_param_value]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Invalid mac \
                                    address value $hlt_param_value for\
                                    $hlt_param parameter."
                            return $returnList
                        }
                        
                        set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                    }
                    "use_ext" {
                        set ret_val [eval $extensions]
                        if {[keylget ret_val status] != $::SUCCESS} {
                            keylset ret_val log "ERROR in $procName: [keylget ret_val log]"
                            return $ret_val
                        }
                        
                        set ixn_param_value [keylget ret_val ixn_param_value]
                    }
                }

                if {$ixn_param_value != ""} {
                    if {[llength $ixn_param_value] > 1} {
                        append stat_args "-$ixn_param \{$ixn_param_value\} "
                    } else {
                        append stat_args "-$ixn_param $ixn_param_value "
                    }
                }
            }
        }
        
        if {$stat_args != ""} {
            set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                    $bridge_handle                                              \
                    $stat_args                                                  \
                    -commit                                                     \
                ]
            if {[keylget tmp_status status] != $::SUCCESS} {
                keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                return $tmp_status
            }
        }    
    }

    if {$mode == "get_ccm" || $mode == "get_all_learned_info"} {
        #         hlt_key                       ixn_key
        set stat_keys_ccm {
                  ccm.b_vlan                    bVlan
                  ccm.cci_interval              cciInterval
                  ccm.err_ccm_defect            errCcmDefect
                  ccm.md_level                  mdLevel
                  ccm.md_name                   mdName
                  ccm.md_name_format            mdNameFormat
                  ccm.out_ofsequence_ccm_count  outOfSequenceCcmCount
                  ccm.received_iface_tlv_defect receivedIfaceTlvDefect
                  ccm.received_port_tlv_defect  receivedPortTlvDefect
                  ccm.received_rdi              receivedRdi
                  ccm.rmep_ccm_defect           rmepCcmDefect
                  ccm.short_maname              shortMaName
                  ccm.short_maname_format       shortMaNameFormat
                  ccm.err_ccm_defect_count      errCcmDefectCount
                  ccm.iface_tlv_defect_count    ifaceTlvDefectCount
                  ccm.port_tlv_defect_count     portTlvDefectCount
                  ccm.remote_mac_address        remoteMacAddress
                  ccm.remote_mep_defect_count   remoteMepDefectCount
                  ccm.remote_mep_id             remoteMepId
                  ccm.src_mac_address           srcMacAddress
                  ccm.src_mep_id                srcMepId
            }

        set ccm_status [ixia::get_pbb_learned_info                      \
                                    $bridge_handle                      \
                                    $keyed_array_name                   \
                                    $stat_keys_ccm                      \
                                    "refreshCcmLearnedInfo"             \
                                    "isPbbTeCcmLearnedInfoRefreshed"         \
                                    "pbbTeCcmLearnedInfo"                    \
                                    ]
        
        if {[keylget ccm_status status] != $::SUCCESS} {
            keylset ccm_status log "ERROR in $procName on get_cfm_ccm. [keylget ccm_status log]"
            return $ccm_status
        }
    }

    if {$mode == "get_dm" || $mode == "get_all_learned_info"} {
        #   hlt_key             ixn_key
        set stat_keys_pbb_dm {
                dm.b_vlan                    bVlan
                dm.dst_mac_address           dstMacAddress
                dm.md_level                  mdLevel
                dm.src_mac_address           srcMacAddress
                dm.value_in_nano_sec         valueInNanoSec
                dm.value_in_sec              valueInSec
            }

        set pbb_dm_status [ixia::get_pbb_learned_info                   \
                                    $bridge_handle                      \
                                    $keyed_array_name                   \
                                    $stat_keys_pbb_dm                   \
                                    "startDelayMeasurement"             \
                                    [list isPbbTeDelayLearnedInfoRefreshed \
                                          isPbbTeDelayLearnedPacketSent    \
                                          pbbTeDelayLearnedErrorString    ]\
                                    "pbbTeDelayLearnedInfo"                    \
                                    ]
                                    
        if {[keylget pbb_dm_status status] != $::SUCCESS} {
            keylset pbb_dm_status log "ERROR in $procName on get_cfm_dm. [keylget pbb_dm_status log]"
            return $pbb_dm_status
        }
    }

    if {$mode == "get_lt" || $mode == "get_all_learned_info"} {
         set stat_keys_lt {
                lt.b_vlan                     bVlan
                lt.dst_mac_address            dstMacAddress
                lt.hop_count                  hopCount
                lt.hops                       hops
                lt.md_level                   mdLevel
                lt.reply_status               replyStatus
                lt.src_mac_address            srcMacAddress
                lt.transaction_id             transactionId
            }
            
        set stat_keys_lt_learned_hop {
                lt.learned_hop.egress_mac     egressMac
                lt.learned_hop.ingress_mac    ingressMac
                lt.learned_hop.reply_ttl      replyTtl
            }

        set pbb_lt_status [ixia::get_pbb_learned_info                   \
                                    $bridge_handle                      \
                                    $keyed_array_name                   \
                                    $stat_keys_lt                       \
                                    "startLinkTrace"                    \
                                    [list isLinkTraceLearnedInfoRefreshed   \
                                          isLtLearnedPacketSent             \
                                          ltLearnedErrorString         ]\
                                    "pbbTeLtLearnedInfo"                \
                                    $stat_keys_lt_learned_hop           \
                                    "ltLearnedHop"                      \
                                    "_use_index"                        ]
                                    
        if {[keylget pbb_lt_status status] != $::SUCCESS} {
            keylset pbb_lt_status log "ERROR in $procName on get_cfm_lt. [keylget pbb_lt_status log]"
            return $pbb_lt_status
        }
    }

    if {$mode == "get_lb" || $mode == "get_all_learned_info"} {
        
        #   hlt_key             ixn_key
        set stat_keys_lb {
            lb.b_vlan              bVlan
            lb.dst_mac_address     dstMacAddress
            lb.md_level            mdLevel
            lb.reachability        reachability
            lb.rtt                 rtt
            lb.src_mac_address     srcMacAddress
            lb.transaction_id      transactionId
        }
        
        set lb_status [ixia::get_pbb_learned_info                       \
                                    $bridge_handle                      \
                                    $keyed_array_name                   \
                                    $stat_keys_lb                       \
                                    "startLoopback"                     \
                                    [list isPbbTeLbLearnedInfoRefreshed \
                                          isPbbTeLbLearnedPacketSent    \
                                          pbbTeLbLearnedErrorString    ]\
                                    "pbbTeLbLearnedInfo"                \
                                    ]
                                    
        if {[keylget lb_status status] != $::SUCCESS} {
            keylset lb_status log "ERROR in $procName on get_cfm_lb. [keylget lb_status log]"
            return $lb_status
        }
    }

    if {$mode == "get_periodic_oam_lt" || $mode == "get_all_learned_info"} {
         set stat_keys_periodic_lt {
                periodic_oam_lt.average_hop_count       averageHopCount
                periodic_oam_lt.b_vlan                  bVlan
                periodic_oam_lt.complete_reply_count    completeReplyCount
                periodic_oam_lt.dst_mac_address         dstMacAddress
                periodic_oam_lt.ltm_sent_count          ltmSentCount
                periodic_oam_lt.md_level                mdLevel
                periodic_oam_lt.no_reply_count          noReplyCount
                periodic_oam_lt.partial_reply_count     partialReplyCount
                periodic_oam_lt.recent_hop_count        recentHopCount
                periodic_oam_lt.recent_hops             recentHops
                periodic_oam_lt.recent_reply_status     recentReplyStatus
                periodic_oam_lt.src_mac_address         srcMacAddress
            }
            
        set stat_keys_periodic_lt_learned_hop {
                periodic_oam_lt.learned_hop.egress_mac     egressMac
                periodic_oam_lt.learned_hop.ingress_mac    ingressMac
                periodic_oam_lt.learned_hop.reply_ttl      replyTtl
            }
        
        set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                $bridge_handle                                          \
                [list -userPeriodicOamType "linkTrace"]                 \
                -commit                                                 \
            ]
            
        if {[keylget tmp_status status] != $::SUCCESS} {
            keylset tmp_status log "ERROR in $procName on $mode.\
                    [keylget tmp_status log]"
            return $tmp_status
        }
        
        set pbb_periodic_lt_status [ixia::get_pbb_learned_info          \
                                    $bridge_handle                      \
                                    $keyed_array_name                   \
                                    $stat_keys_periodic_lt              \
                                    "updatePeriodicOamLearnedInfo"      \
                                    "isPeriodicOamLearnedInfoRefreshed" \
                                    "pbbTePeriodicOamLtLearnedInfo"     \
                                    $stat_keys_periodic_lt_learned_hop  \
                                    "ltLearnedHop"                      \
                                    "_use_index"                        ]

        if {[keylget pbb_periodic_lt_status status] != $::SUCCESS} {
            keylset pbb_periodic_lt_status log "ERROR in $procName on get_periodic_oam_lt. [keylget pbb_periodic_lt_status log]"
            return $pbb_periodic_lt_status
        }
    }

    if {$mode == "get_periodic_oam_lb" || $mode == "get_all_learned_info"} {

        set stat_keys_periodic_lb {
                periodic_oam_lb.average_rtt             averageRtt
                periodic_oam_lb.b_vlan                  bVlan
                periodic_oam_lb.dst_mac_address         dstMacAddress
                periodic_oam_lb.lbm_sent_count          lbmSentCount
                periodic_oam_lb.md_level                mdLevel
                periodic_oam_lb.no_reply_count          noReplyCount
                periodic_oam_lb.recent_reachability     recentReachability
                periodic_oam_lb.recent_rtt              recentRtt
                periodic_oam_lb.src_mac_address         srcMacAddress
            }
        
        set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                $bridge_handle                                          \
                [list -userPeriodicOamType "loopback"]                  \
                -commit                                                 \
            ]
            
        if {[keylget tmp_status status] != $::SUCCESS} {
            keylset tmp_status log "ERROR in $procName on $mode.\
                    [keylget tmp_status log]"
            return $tmp_status
        }
        
        set periodic_lb_status [ixia::get_pbb_learned_info              \
                                    $bridge_handle                      \
                                    $keyed_array_name                   \
                                    $stat_keys_periodic_lb              \
                                    "updatePeriodicOamLearnedInfo"      \
                                    "isPeriodicOamLearnedInfoRefreshed" \
                                    "pbbTePeriodicOamLbLearnedInfo"     \
                                    ]

        if {[keylget periodic_lb_status status] != $::SUCCESS} {
            keylset periodic_lb_status log "ERROR in $procName on get_periodic_oam_lb.\
                    [keylget periodic_lb_status log]"
            return $periodic_lb_status
        }        
    }
    
    if {$mode == "get_periodic_oam_dm" || $mode == "get_all_learned_info"} {
        
        set stat_keys_periodic_dm {
                periodic_oam_dm.average_delay_nano_sec  averageDelayNanoSec
                periodic_oam_dm.average_delay_sec       averageDelaySec
                periodic_oam_dm.b_vlan                  bVlan
                periodic_oam_dm.dmm_count_sent          dmmCountSent
                periodic_oam_dm.dst_mac_address         dstMacAddress
                periodic_oam_dm.md_level                mdLevel
                periodic_oam_dm.no_reply_count          noReplyCount
                periodic_oam_dm.recent_delay_nano_sec   recentDelayNanoSec
                periodic_oam_dm.recent_delay_sec        recentDelaySec
                periodic_oam_dm.src_mac_address         srcMacAddress
            }
        
        set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                $bridge_handle                                          \
                [list -userPeriodicOamType "delayMeasurement"]          \
                -commit                                                 \
            ]
            
        if {[keylget tmp_status status] != $::SUCCESS} {
            keylset tmp_status log "ERROR in $procName on $mode.\
                    [keylget tmp_status log]"
            return $tmp_status
        }
        
        set periodic_dm_status [ixia::get_pbb_learned_info              \
                                    $bridge_handle                      \
                                    $keyed_array_name                   \
                                    $stat_keys_periodic_dm              \
                                    "updatePeriodicOamLearnedInfo"      \
                                    "isPeriodicOamLearnedInfoRefreshed" \
                                    "pbbTePeriodicOamDmLearnedInfo"     \
                                    ]
                                    
        if {[keylget periodic_dm_status status] != $::SUCCESS} {
            keylset periodic_dm_status log "ERROR in $procName on get_periodic_oam_dm.\
                    [keylget periodic_dm_status log]"
            return $periodic_dm_status
        }
    }

    if {$mode == "aggregated_stats"} {
        set statViewBrowserNamesList [list "CFM Aggregated Statistics"]
        set enableStatus [enableStatViewList $statViewBrowserNamesList]
        if {[keylget enableStatus status] == $::FAILURE} {
            return $enableStatus
        }
        after 2000
        
        if {![info exists port_handle] && ![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode, one of the parameters\
                    -port_handle or -handle must be provided."
            return $returnList
        }
        
        if {![info exists port_handle]} {
            set port_handle ""
            foreach handleElem $handle {
                set retCode [ixNetworkGetPortFromObj $handleElem]
                if {[keylget retCode status] == $::FAILURE} {
                    return $retCode
                }
                lappend port_handle [keylget retCode port_handle]
            }
        }
        
        set index 1
        foreach port $port_handle {
            set result [ixNetworkGetPortObjref $port]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to find the port \
                object reference associated to the $port port handle -\
                [keylget result log]."
                return $returnList
            }
            set port_objref [keylget result vport_objref]
            set stat_type "cfm_aggregated_stats"
            set stat_name "CFM Aggregated Statistics"
            set stats_list_name  aggregated_stat_list
            set stats_array_name stats_array_${stat_type}
            array set $stats_array_name [set $stats_list_name]
            set stats_list [array names $stats_array_name]
            
            array set stats_array [array get $stats_array_name]
            set returned_stats_list [ixNetworkGetStats \
                    $stat_name $stats_list]
            if {[keylget returned_stats_list status] == $::FAILURE} {
                  continue
            }

            debug "returned_stats_list: $returned_stats_list"

            set found false
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

                if {"$port" eq "$chassis_no/$card_no/$port_no"} {
                    set found true
                    foreach stat $stats_list {
                        if {[info exists rows_array($i,$stat)] && \
                                $rows_array($i,$stat) != ""} {
                            keylset returnList ${port}.$stats_array($stat) \
                                    $rows_array($i,$stat)
                            if {$index == 1} {
                                keylset returnList $stats_array($stat) \
                                        $rows_array($i,$stat)
                            }
                        } else {
                            keylset returnList ${port}.$stats_array($stat) "N/A"
                            if {$index == 1} {
                                keylset returnList $stats_array($stat) "N/A"
                            }
                        }
                        
                    }
                    incr index
                    break
                }
            }
            if {!$found} {
                keylset returnList status $::FAILURE
                keylset returnList log "The '$port' port couldn't be\
                        found among the ports from which statistics were\
                        gathered."
                return $returnList
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
            if {$keyed_array_index < $pbb_stats_max_list_length} {
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

proc ::ixia::emulation_pbb_control { args } {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle  \{::ixia::emulation_pbb_control $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set man_args {
         -mode                        CHOICES   start stop
         -port_handle                 ANY       
    }
    set opt_args {
         -handle                      ANY       
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args  -mandatory_args $man_args
    
    set _handles $port_handle
    set protocol_objref_list ""
    foreach {_handle} $_handles {
        set retCode [ixNetworkGetPortObjref $_handle]
        if {[keylget retCode status] == $::FAILURE} {
            return $retCode
        }
        set protocol_objref [keylget retCode vport_objref]
        lappend protocol_objref_list $protocol_objref/protocols/cfm
    }
    if {$protocol_objref_list == "" } {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: All handles provided through\
                -port_handle parameter are invalid."
        return $returnList
    }
    
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
            keylset returnList log "ERROR in $procName: Failed to $mode PBB on the\
                    $vport_objref port. Port state is $portState, $portStateD."
            return $returnList
        }
    }
    
    set operation $mode
    
    foreach protocol_objref $protocol_objref_list {
        debug "ixNet exec $operation $protocol_objref"
        if {[catch {ixNet exec $operation $protocol_objref} retCode] || \
                ([string first "::ixNet::OK" $retCode] == -1)} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to $operation PBB on the\
                    $vport_objref port. Error code: $retCode."
            return $returnList
        }
    }

    keylset returnList status $::SUCCESS
    return $returnList
}

