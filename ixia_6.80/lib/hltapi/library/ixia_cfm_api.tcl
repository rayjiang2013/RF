##Library Header
# $Id: $
# Copyright © 2003-2008 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_cfm_api.tcl
#
# Purpose:
#    A script development library containing CFM APIs for test automation with the Ixia chassis. 
#
# Author:
#    Mircea Hasegan
#
# Usage:
#    package req Ixia
#
# Description:
#    The procedures contained within this library include:
#        emulation_cfm_config
#        emulation_cfm_md_meg_config
#        emulation_cfm_mip_mep_config
#        emulation_cfm_custom_tlv_config
#        emulation_cfm_vlan_config
#        emulation_cfm_links_config
#        emulation_cfm_info
#        emulation_cfm_control
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


proc ::ixia::emulation_cfm_config { args } {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        set retValue [eval clientSend $::ixTclSvrHandle  \{::ixia::emulation_cfm_config $args\}]
        
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
         -mode                        CHOICES   create modify enable disable remove
    }
    set opt_args {
         -ais_interval                CHOICES   one_sec one_min
                                      DEFAULT   one_sec
         -allow_cfm_maid_formats      CHOICES 0 1
                                      DEFAULT 0
         -bridge_id                   ANY
                                      DEFAULT   00:00:00:00:00:00
         -bridge_id_step              ANY       
                                      DEFAULT   00:00:00:00:00:01
         -count                       NUMERIC   
                                      DEFAULT   1
         -enable_ais                  CHOICES   0 1
                                      DEFAULT   0
         -enable_optional_tlv_validation CHOICES 0 1
                                      DEFAULT   0
         -enable_out_of_sequence_detection CHOICES 0 1
                                      DEFAULT   1
         -ether_type                  CHOICES   8902 88E6
                                      DEFAULT   8902
         -garbage_collect_time        NUMERIC   
                                      DEFAULT   10
         -handle                      ANY
         -interface_handle            ANY
         -mac_address_init            ANY
         -mac_address_step            ANY
                                      DEFAULT   00:00:00:00:00:01
         -operation_mode              CHOICES   cfm y1731
                                      DEFAULT   cfm
         -override_existence_check    CHOICES   0 1
                                      DEFAULT   0
         -override_tracking           CHOICES   0 1
                                      DEFAULT   0
         -port_handle                 REGEXP    ^[0-9]+/[0-9]+/[0-9]+$
         -receive_ccm                 CHOICES   0 1
                                      DEFAULT   1
         -reset                       FLAG
         -send_ccm                    CHOICES   0 1
                                      DEFAULT   1
         -vlan_enable                 CHOICES   0 1
                                      DEFAULT   0
         -vlan_id                     RANGE     0-4095
                                      DEFAULT   0
         -vlan_id_step                RANGE     0-4095
                                      DEFAULT   1
         -vlan_user_priority          RANGE     0-4095
                                      DEFAULT   0
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
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When -mode is $mode -handle parameter is mandatory."
            return $returnList
        }
        
        foreach b_handle $handle {
            if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+$} $b_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -handle $b_handle is not a valid CFM Bridge handle."
                return $returnList
            }
            
            if {[ixNet exists $b_handle] == "false" || [ixNet exists $b_handle] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -handle $b_handle does not exist."
                return $returnList
            }
        }
    }
    
    array set truth {1 true 0 false enable true disable false}
    
    array set cfm_options_map {
        one_sec     oneSec
        one_min     oneMin
        "8902"      "0x8902"
        "88E6"      "0x88E6"
        cfm         cfm
        y1731       y1731
    }
    
    set global_params {
            enable_optional_tlv_validation      enableOptionalTlvValidation     truth       _none
            receive_ccm                         receiveCcm                      truth       _none
            send_ccm                            sendCcm                         truth       _none
            enabled                             enabled                         truth       _none
        }
    
    set bridge_params {
            ais_interval                        aisInterval                     translate   _none
            allow_cfm_maid_formats              allowCfmMaidFormatsInY1731      truth       _none
            bridge_id                           bridgeId                        mac         _none
            enable_ais                          enableAis                       truth       _none
            enable_out_of_sequence_detection    enableOutOfSequenceDetection    truth       _none
            ether_type                          etherType                       translate   hex2num
            garbage_collect_time                garbageCollectTime              value       _none
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
            
            # Configure cfm global (per port) params
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
                                set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
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
        }
        "modify" {
            
            if {[llength $handle] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Only one CFM Bridge handle can be modified with one procedure call. Parameter -handle is a list of values."
                return $returnList
            }
            
            set protocol_objref [ixNetworkGetParentObjref $handle]
            
            # Configure cfm global (per port) params
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
                            the interface associated with the CFM Bridge handle when -mode is\
                            modify. The length of -interface_handle must be 1."
                    return $returnList
                }
                
                set cfm_interface_handle [ixNet getList $handle interface]
                
                set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                        $cfm_interface_handle                                       \
                        [list -interfaceId $interface_handle]                       \
                        -commit                                                     \
                    ]
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
            }
            
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
    }
    
    return $returnList
}


proc ::ixia::emulation_cfm_md_meg_config { args } {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        set retValue [eval clientSend $::ixTclSvrHandle  \{::ixia::emulation_cfm_md_meg_config $args\}]
        
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
         -mode                        CHOICES   create modify enable disable remove
    }
    set opt_args {
         -bridge_handle               ANY       
         -count                       NUMERIC   
                                      DEFAULT   1
         -handle                      ANY       
         -level_id_repeat_count       NUMERIC   
                                      DEFAULT   1
         -level_id_start              RANGE     0-7
                                      DEFAULT   0
         -level_id_step               RANGE     0-7
                                      DEFAULT   1
         -name                        ANY       
                                      DEFAULT   Ixiacom
         -name_format                 CHOICES   none string domain_name mac_plus_2_octets
                                      DEFAULT   domain_name
         -name_mac_repeat_count       NUMERIC   
                                      DEFAULT   65535
         -name_mac_step               ANY       
                                      DEFAULT   00:00:00:00:00:00:00:01
         -name_wildcard_enable        CHOICES   0 1
                                      DEFAULT   0
         -reset                       FLAG
         -wildcard_question_repeat_count NUMERIC 
                                      DEFAULT   1
         -wildcard_question_start     ANY   
                                      DEFAULT   0
         -wildcard_question_step      ANY
                                      DEFAULT   1
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
    
    array set cfm_options_map {
        none                    noDomainName
        string                  characterString
        domain_name             domainNameBasedString
        mac_plus_2_octets       macAddress2OctetInteger
    }
    
    set md_level_params {
            enabled                             enabled                         truth       _none
            level_id_start                      mdLevelId                       value       _none
            name_format                         mdNameFormat                    translate   _none
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
        
        foreach mm_handle $handle {
            if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/mdLevel:\d+$} $mm_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -handle $mm_handle is not a valid CFM Maintenance Domain."
                return $returnList
            }
            
            if {[ixNet exists $mm_handle] == "false" || [ixNet exists $mm_handle] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -handle $mm_handle does not exist."
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
                keylset returnList log "ERROR in $procName: CFM Maintenance Domains can be added only on one \
                        CFM Bridge handle with one procedure call. Parameter -bridge_handle contains a\
                        list of CFM Bridge handles."
                return $returnList
            }
            
            if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+$} $bridge_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -bridge_handle $bridge_handle is not a valid CFM Bridge handle."
                return $returnList
            }
            
            if {[ixNet exists $bridge_handle] == "false" || [ixNet exists $bridge_handle] == 0 } {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -bridge_handle $bridge_handle does not exist."
                return $returnList
            }
            
            # Remove all md meg from this bridge if reset is present
            if {[info exists reset]} {
                set result [ixNetworkNodeRemoveList $bridge_handle \
                        { {child remove mdLevel} {} } -commit]
                if {[keylget result status] == $::FAILURE} {
                    keylset result log "ERROR in $procName: [keylget result log]"
                    return $result
                }
            }
            
            ## Prepare md meg parameters for the ixnet call
            # Make sure all parameters are in the right format
            if {[info exists name_format] && $name_format == "mac_plus_2_octets"} {
                if {[catch {isValidHex $name 8} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Parameter -name is not a valid hex number\
                            with a maximum 8 hex chars. Example of valid mac_plus_2_octets values are:\n\
                            0x1122aabbccddeeff\n\
                            1122aabbccddeeff\n\
                            '11 22 aa bb cc dd ee ff'\n\
                            11.22.aa.bb.cc.dd.ee.ff\n\
                            11:22:aa:bb:cc:dd:ee:ff\n$err"
                    return $returnList
                }
                set name [hex2list $name]
                set name "0x[regsub -all { } $name {} ]"
                
                if {[catch {isValidHex $name_mac_step 8} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Parameter -name_mac_step is not a valid hex number\
                            with a maximum 8 hex chars. Example of valid mac_plus_2_octets values are:\n\
                            0x1122aabbccddeeff\n\
                            1122aabbccddeeff\n\
                            '11 22 aa bb cc dd ee ff'\n\
                            11.22.aa.bb.cc.dd.ee.ff\n\
                            11:22:aa:bb:cc:dd:ee:ff\n$err"
                    return $returnList
                }
                
                set name_mac_step [hex2list $name_mac_step]
                
                set name_mac_step "0x[regsub -all { } $name_mac_step {} ]"
            }
            
            # CFM Maintenance Domains
            set mm_handle_list ""
            for {set i 0} {$i < $count} {mpincr i} {
                
                # Increment level_id
                if {$i > 0} {
                    if {[mpexpr $i % $level_id_repeat_count] == 0} {
                        mpincr level_id_start $level_id_step
                        set level_id_start [mpexpr $level_id_start % 8]
                    }
                }
            
                set ixn_mm_args ""
                foreach {hlt_param ixn_param type extensions} $md_level_params {
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
                                if {[info exists cfm_options_map($hlt_param_value)]} {
                                    set ixn_param_value $cfm_options_map($hlt_param_value)
                                } else {
                                    set ixn_param_value $hlt_param_value
                                }
                            }
                        }
                        
                        append ixn_mm_args "-$ixn_param $ixn_param_value "
                    }
                }
                
                if {[info exists name_format] && $name_format != "none"} {
                    if {$name_format == "mac_plus_2_octets"} {
                        if {[info exists name_mac_step]} {
                            if {$i > 0} {
                                if {[mpexpr $i % $name_mac_repeat_count] == 0} {
                                    mpincr name $name_mac_step
                                    set name [mpformat %x $name]
                                }
                            }
                        }
                        set tmp_name $name
                        set tmp_name [format_hex $tmp_name 64]
                        set tmp_name "\{[string replace $tmp_name 17 17 \-]\}"
                        
                    } elseif {[info exists name_wildcard_enable] && $name_wildcard_enable == 1} {
                        
                        set wildcard_width [string length $wildcard_question_start]

                        set tmp_wildcard_question_start [string trimleft $wildcard_question_start 0]
                        set tmp_wildcard_question_step  [string trimleft $wildcard_question_step  0]
                        
                        if {![string is integer $tmp_wildcard_question_start] || \
                                ![string is integer $tmp_wildcard_question_step]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Parameters\
                                    -wildcard_question_start and -wildcard_question_step\
                                    must have numeric values."
                            return $returnList
                        }
                                                
                        set increment_count [mpexpr $i / $wildcard_question_repeat_count]
                        
                        set increment_value [mpexpr $tmp_wildcard_question_step * $increment_count]
                        
                        set wildcard_value [mpexpr $tmp_wildcard_question_start + $increment_value]
                        
                        set wildcard_value_as_string "[format %0${wildcard_width}d $wildcard_value]"
                        
                        regsub {\?} $name $wildcard_value_as_string tmp_name
                    } else {
                        set tmp_name $name
                    }
                }
                
                append ixn_mm_args "-mdName $tmp_name"
                
                if {$ixn_mm_args != ""} {
                    set tmp_status [::ixia::ixNetworkNodeAdd                            \
                            $bridge_handle                                              \
                            "mdLevel"                                                   \
                            $ixn_mm_args                                                \
                            -commit                                                     \
                        ]
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                    
                    lappend mm_handle_list [keylget tmp_status node_objref]
                }
            }
            keylset returnList handle $mm_handle_list
        }
        "modify" {
        
            if {[llength $handle] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Only one CFM Maintenance \
                        Domain handle can be modified with one procedure call.\
                        Parameter -handle is a list of CFM Maintenance Domains handles."
                return $returnList
            }
        
            ## Prepare md meg parameters for the ixnet call
            # Make sure all parameters are in the right format
            set ixn_mm_args ""
            
            if {[info exists name_format] && $name_format == "mac_plus_2_octets"} {
                if {[info exists name]} {
                    if {[catch {isValidHex $name 8} err]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Parameter -name is not a valid hex number\
                                with a maximum 8 hex chars. Example of valid mac_plus_2_octets values are:\n\
                                0x1122aabbccddeeff\n\
                                1122aabbccddeeff\n\
                                '11 22 aa bb cc dd ee ff'\n\
                                11.22.aa.bb.cc.dd.ee.ff\n\
                                11:22:aa:bb:cc:dd:ee:ff\n$err"
                        return $returnList
                    }
                    
                    set name [hex2list $name]
                    set name "0x[regsub -all { } $name {} ]"
                    set name [format_hex $name 64]
                    set name "\{[string replace $name 17 17 \-]\}"
                }
            }
            
            if {[info exists name]} {
                append ixn_mm_args "-mdName $name "
            }
            
            # CFM Maintenance Domains
            foreach {hlt_param ixn_param type extensions} $md_level_params {
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
                            if {[info exists cfm_options_map($hlt_param_value)]} {
                                set ixn_param_value $cfm_options_map($hlt_param_value)
                            } else {
                                set ixn_param_value $hlt_param_value
                            }
                        }
                    }
                    
                    append ixn_mm_args "-$ixn_param $ixn_param_value "
                }
            }
            
            if {$ixn_mm_args != ""} {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                        $handle                                                     \
                        $ixn_mm_args                                                \
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
            foreach mm_handle $handle {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                        $mm_handle                                              \
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
            foreach mm_handle $handle {
                debug "ixNet remove $mm_handle"
                if {[ixNet remove $mm_handle] != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to remove handle $mm_handle."
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
    
    return $returnList
}


proc ::ixia::emulation_cfm_mip_mep_config { args } {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        set retValue [eval clientSend $::ixTclSvrHandle  \{::ixia::emulation_cfm_mip_mep_config $args\}]
        
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
         -auto_dm_all_destination     CHOICES   0 1
                                      DEFAULT   0
         -auto_dm_destination         ANY
         -auto_dm_iteration           RANGE     0-4294967296
                                      DEFAULT   0
         -auto_dm_timeout             RANGE     1-65535
                                      DEFAULT   30
         -auto_dm_timer               RANGE     1-65535
                                      DEFAULT   60
         -auto_lb_all_destination     CHOICES   0 1
                                      DEFAULT   0
         -auto_lb_destination         ANY
         -auto_lb_iteration           RANGE     0-4294967296
                                      DEFAULT   0
         -auto_lb_timeout             RANGE     1-65535
                                      DEFAULT   30
         -auto_lb_timer               RANGE     1-65535
                                      DEFAULT   60
         -auto_lt_all_destination     CHOICES   0 1
                                      DEFAULT   0
         -auto_lt_destination         ANY
         -auto_lt_iteration           RANGE     0-4294967296
                                      DEFAULT   0
         -auto_lt_timeout             RANGE     1-65535
                                      DEFAULT   30
         -auto_lt_timer               RANGE     1-65535
                                      DEFAULT   60
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
         -enable_auto_dm              CHOICES   0 1
                                      DEFAULT   0
         -enable_auto_lb              CHOICES   0 1
                                      DEFAULT   0
         -enable_auto_lt              CHOICES   0 1
                                      DEFAULT   0
         -handle                      ANY
         -lbm_priority                RANGE     0-7
                                      DEFAULT   0
         -ltm_priority                RANGE     0-7
                                      DEFAULT   0
         -mac_address                 ANY
                                      DEFAULT   00:00:00:00:00:00
         -mac_address_step            ANY
                                      DEFAULT   00:00:00:00:00:01
         -management_address          ANY
                                      DEFAULT   01:02:03:04:05
         -management_address_step     ANY
                                      DEFAULT   00:00:00:00:01
         -management_address_domain   ANY
                                      DEFAULT   4d:61:6e:61:67:65:6d:65:6e:74:20:41:64:64:72:20:44:6f:6d:61:69:6e
         -management_address_domain_length RANGE 0-255
                                      DEFAULT   22
         -management_address_domain_step ANY
                                      DEFAULT   00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:01
         -management_address_length   RANGE     0-255
                                      DEFAULT   6
         -md_meg_handle_distribution  CHOICES   round_robin repeat_count
                                      DEFAULT   round_robin
         -md_meg_handle_list          ANY
         -md_meg_handle_repeat_count  NUMERIC
                                      DEFAULT   1
         -meg_id                      ANY
         -meg_id_format               CHOICES char_string icc_based_format 2_octet_integer primary_vid rfc_2685_vpn_id 
                                      DEFAULT   icc_based_format
         -mep_id                      RANGE     1-8191
                                      DEFAULT   1
         -mep_id_step                 RANGE     1-8190
                                      DEFAULT   1
         -mip_id                      RANGE     0-65535
                                      DEFAULT   0
         -mip_id_step                 RANGE     1-65535
                                      DEFAULT   1
         -mp_type                     CHOICES   mip mep
                                      DEFAULT   mep
         -organization_specific_tlv_length RANGE 4-1500
                                      DEFAULT   4
         -organization_specific_tlv_value ANY
                                      DEFAULT   00:00:00:00
         -organization_specific_tlv_value_step ANY
                                      DEFAULT   00:00:00:01
         -override_vlan_priority      CHOICES   0 1
                                      DEFAULT   0
         -reset                       FLAG
         -short_ma_name               ANY
         -short_ma_name_format        CHOICES   primary_vid char_string 2_octet_integer rfc_2685_vpn_id
                                      DEFAULT   char_string
         -ttl                         RANGE     1-255
                                      DEFAULT   64
         -vlan_handle_list            ANY
         -vlan_handle_list_distribution CHOICES round_robin repeat_count
                                      DEFAULT   round_robin
         -vlan_handle_list_repeat_count NUMERIC
                                      DEFAULT   1
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
    
    array set cfm_options_map {
            chassis_component       chassisComponent
            interface_alias         interfaceAlias
            port_component          portComponent
            mac_address             macAddress
            network_address         networkAddress
            interface_name          interfaceName
            locally_assigned        locallyAssigned
            icc_based_format        iccBasedFormat
            mip                     mip
            mep                     mep
            primary_vid             primaryVid
            char_string             characterString
            2_octet_integer         2octetInteger
            rfc_2685_vpn_id         rfc2685VpnId
        }
    
    set mipmep_params {
                enabled                             enabled                             truth                     _none
                add_ccm_custom_tlvs                 addCcmCustomTlvs                    truth                     _none
                add_data_tlv                        addDataTlv                          truth                     _none
                add_interface_status_tlv            addInterfaceStatusTlv               truth                     _none
                add_lbm_custom_tlvs                 addLbmCustomTlvs                    truth                     _none
                add_lbr_custom_tlvs                 addLbrCustomTlvs                    truth                     _none
                add_ltm_custom_tlvs                 addLtmCustomTlvs                    truth                     _none
                add_ltr_custom_tlvs                 addLtrCustomTlvs                    truth                     _none
                add_organization_specific_tlv       addOrganizationSpecificTlv          truth                     _none
                add_port_status_tlv                 addPortStatusTlv                    truth                     _none
                add_sender_id_tlv                   addSenderIdTlv                      truth                     _none
                auto_dm_all_destination             autoDmAllDestination                truth                     _none
                auto_dm_destination                 autoDmDestination                   mac                       _none
                auto_dm_iteration                   autoDmIteration                     value                     _none
                auto_dm_timeout                     autoDmTimeout                       value                     _none
                auto_dm_timer                       autoDmTimer                         value                     _none
                auto_lb_all_destination             autoLbAllDestination                truth                     _none
                auto_lb_destination                 autoLbDestination                   mac                       _none
                auto_lb_iteration                   autoLbIteration                     value                     _none
                auto_lb_timeout                     autoLbTimeout                       value                     _none
                auto_lb_timer                       autoLbTimer                         value                     _none
                auto_lt_all_destination             autoLtAllDestination                value                     _none
                auto_lt_destination                 autoLtDestination                   mac                       _none
                auto_lt_iteration                   autoLtIteration                     value                     _none
                auto_lt_timeout                     autoLtTimeout                       value                     _none
                auto_lt_timer                       autoLtTimer                         value                     _none
                cci_interval                        cciInterval                         value                     _none
                ccm_priority                        ccmPriority                         value                     _none
                chassis_id_length                   chassisIdLength                     value                     _none
                chassis_id_sub_type                 chassisIdSubType                    translate                 _none
                data_tlv_length                     dataTlvLength                       value                     _none
                dmm_priority                        dmmPriority                         value                     _none
                enable_auto_dm                      enableAutoDm                        truth                     _none
                enable_auto_lb                      enableAutoLb                        truth                     _none
                enable_auto_lt                      enableAutoLt                        truth                     _none
                lbm_priority                        lbmPriority                         value                     _none
                ltm_priority                        ltmPriority                         value                     _none
                mac_address                         macAddress                          use_ext                   "cfm_mac_incr         \
                                                                                                                        mac_address     \
                                                                                                                        mac_address_step\
                                                                                                                        mip_mep_counter "
                meg_id_format                       megIdFormat                         translate                 _none
                mp_type                             mpType                              translate                 _none
                organization_specific_tlv_length    organizationSpecificTlvLength       value                     _none
                organization_specific_tlv_value     organizationSpecificTlvValue        use_ext                   "cfm_tlv_formatter                        \
                                                                                                                        organization_specific_tlv_value     \
                                                                                                                        organization_specific_tlv_length    \
                                                                                                                        organization_specific_tlv_value_step\
                                                                                                                        mip_mep_counter                     "
                override_vlan_priority              overrideVlanPriority                truth                     _none
                short_ma_name_format                shortMaNameFormat                   translate                 _none
                ttl                                 ttl                                 value                     _none
                meg_id                              megId                               value                     _none
                mep_id                              mepId                               use_ext                   "cfm_incr_field       \
                                                                                                                        mep_id          \
                                                                                                                        mep_id_step     \
                                                                                                                        mip_mep_counter "
                mip_id                              mipId                               use_ext                   "cfm_incr_field       \
                                                                                                                        mip_id          \
                                                                                                                        mip_id_step     \
                                                                                                                        mip_mep_counter "
                short_ma_name                       shortMaName                         use_ext                   "cfm_short_ma_name_check  \
                                                                                                                        short_ma_name       \
                                                                                                                        short_ma_name_format"
                chassis_id                          chassisId                           use_ext                   "cfm_tlv_formatter        \
                                                                                                                        chassis_id          \
                                                                                                                        chassis_id_length   \
                                                                                                                        chassis_id_step     \
                                                                                                                        mip_mep_counter     "
                data_tlv_value                      dataTlvValue                        use_ext                   "cfm_tlv_formatter        \
                                                                                                                        data_tlv_value      \
                                                                                                                        data_tlv_length     \
                                                                                                                        data_tlv_step       \
                                                                                                                        mip_mep_counter     "
                management_address_length           managementAddressLength             value                     _none
                management_address                  managementAddress                   use_ext                   "cfm_tlv_formatter                \
                                                                                                                        management_address          \
                                                                                                                        management_address_length   \
                                                                                                                        management_address_step     \
                                                                                                                        mip_mep_counter             "
                management_address_domain_length    managementAddressDomainLength       value                     _none
                management_address_domain           managementAddressDomain             use_ext                   "cfm_tlv_formatter                        \
                                                                                                                        management_address_domain           \
                                                                                                                        management_address_domain_length    \
                                                                                                                        management_address_domain_step      \
                                                                                                                        mip_mep_counter                     "
                md_meg_handle_list                  mdLevel                             use_ext                   "cfm_inner_handle_setter          \
                                                                                                                        md_meg_handle_list          \
                                                                                                                        md_meg_handle_distribution  \
                                                                                                                        md_meg_handle_repeat_count  \
                                                                                                                        mip_mep_counter             "
                vlan_handle_list                    vlan                                use_ext                   "cfm_inner_handle_setter              \
                                                                                                                        vlan_handle_list                \
                                                                                                                        vlan_handle_list_distribution   \
                                                                                                                        vlan_handle_list_repeat_count   \
                                                                                                                        mip_mep_counter                 "
        }

            

    if {$mode == "modify"} {
            removeDefaultOptionVars $opt_args $args
    }

    if {$mode != "create"} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When -mode is $mode -handle\
                    parameter is mandatory."
            return $returnList
        }

        foreach mipmep_handle $handle {
            if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/mp:\d+$} $mipmep_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -handle $mipmep_handle\
                        is not a valid CFM Maintenance Point handle."
                return $returnList
            }

            if {[ixNet exists $mipmep_handle] == "false" || [ixNet exists $mipmep_handle] == 0 } {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -handle $mipmep_handle does not exist."
                return $returnList
            }
        }
    }

    # Check validity of vlan handles and mdmeg handles
    if {[info exists md_meg_handle_list]} {
        foreach md_meg_handle $md_meg_handle_list {
            if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/mdLevel:\d+$} $md_meg_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -md_meg_handle\
                        $md_meg_handle is not a valid CFM Maintenance Domain."
                return $returnList
            }
            
            if {[ixNet exists $md_meg_handle] == "false" || [ixNet exists $md_meg_handle] == 0 } {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -md_meg_handle_list $md_meg_handle\
                        does not exist."
                return $returnList
            }
        }
    } else {
        set md_meg_handle_list ""
    }
    
    if {[info exists vlan_handle_list]} {
        foreach vlan_handle $vlan_handle_list {
            if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/vlans:\d+$} $vlan_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -vlan_handle_list\
                        $vlan_handle is not a valid CFM Vlan handle."
                return $returnList
            }
            
            if {[ixNet exists $vlan_handle] == "false" || [ixNet exists $vlan_handle] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -vlan_handle_list $vlan_handle\
                        does not exist."
                return $returnList
            }
        }
    } else {
        set vlan_handle_list ""
    }
    
    array set truth {1 true 0 false enable true disable false}
    
    
    switch -- $mode {
        "create" {
            set enabled 1
            
            # Check if bridge_handle parameter is ok
            
            if {![info exists bridge_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When -mode is $mode,\
                        parameter -bridge_handle is mandatory."
                return $returnList
            }
            
            if {[llength $bridge_handle] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: CFM Maintenance Points\
                        can be added only on one CFM Bridge handle with one procedure\
                        call. Parameter -bridge_handle contains a list of CFM Bridge\
                        handles."
                return $returnList
            }
            
            if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+$} $bridge_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -bridge_handle
                        $bridge_handle is not a valid CFM Bridge handle."
                return $returnList
            }
            
            if {[ixNet exists $bridge_handle] == "false" || [ixNet exists $bridge_handle] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -bridge_handle
                        $bridge_handle does not exist."
                return $returnList
            }
            
            # Remove all md meg from this bridge if reset is present
            if {[info exists reset]} {
                set result [ixNetworkNodeRemoveList $bridge_handle \
                        { {child remove mp} {} } -commit]
                if {[keylget result status] == $::FAILURE} {
                    keylset result log "ERROR in $procName: [keylget result log]"
                    return $result
                }
            }
            
            set mip_mep_handles ""
            
            for {set mip_mep_counter 0} {$mip_mep_counter < $count} {incr mip_mep_counter} {
                
                set mip_mep_args ""

                foreach {hlt_param ixn_param p_type extensions} $mipmep_params {

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
                                    keylset returnList log "ERROR in $procName: Invalid mac \
                                            address value $hlt_param_value for\
                                            $hlt_param parameter."
                                    return $returnList
                                }
                                
                                set ixn_param_value [convertToIxiaMac $hlt_param_value]
                            }
                            use_ext {
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
                                append mip_mep_args "-$ixn_param \{$ixn_param_value\} "
                            } else {
                                append mip_mep_args "-$ixn_param $ixn_param_value "
                            }
                        }
                    }
                }
                
                if {$mip_mep_args != ""} {
                    set tmp_status [::ixia::ixNetworkNodeAdd                            \
                            $bridge_handle                                              \
                            "mp"                                                        \
                            $mip_mep_args                                               \
                            -commit                                                     \
                        ]
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                    
                    set mip_mep_handle [keylget tmp_status node_objref]
                    
                    lappend mip_mep_handles $mip_mep_handle
                }
            }
            
            keylset returnList handle $mip_mep_handles
        }
        "modify" {
            if {[llength $handle] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Only one CFM Maintenance Point \
                        handle can be modified with one procedure call.\
                        Parameter -handle is a list of CFM Maintenance Point handles."
                return $returnList
            }
            
            # Check validity of vlan handles and md_meg handles
            if {[info exists md_meg_handle_list] && [llength $md_meg_handle_list] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -md_meg_handle_list\
                        must have only one md_meg handle when -mode is modify."
                return $returnList
            }
            
            if {[info exists vlan_handle_list] && [llength $vlan_handle_list] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -vlan_handle_list\
                        must have only one vlan handle when -mode is modify."
                return $returnList
            }
            
            # IxNetwork pads tlv values with zeros on the right.
            # If we modify the length parameter, the tlv value that the user passed at the
            # create call will be right padded with zeros.
            # If we have the length parameter and the value parameter is missing we will
            # init the value parameter with the value previously configured.
            # This way the value will be left_padded with zeros before set by ::ixia::cfm_tlv_formatter
            
            set tlv_params_list {
                organization_specific_tlv_length organization_specific_tlv_value organizationSpecificTlvValue
                chassis_id_length                chassis_id                      chassisId
                data_tlv_length                  data_tlv_value                  dataTlvValue
                management_address_length        management_address              managementAddress
                management_address_domain_length management_address_domain       managementAddressDomain
            }
            
            foreach {tmp_tlv_length tmp_tlv_value tmp_ixn_pname} $tlv_params_list {
                if {[info exists $tmp_tlv_length] && ![info exists $tmp_tlv_value]} {
                    set $tmp_tlv_value [ixNet getAttribute $handle -$tmp_ixn_pname]
                    set ixn_length [llength [set $tmp_tlv_value]]
                    if {[set $tmp_tlv_length] < $ixn_length} {
                        # cropping is needed. Remove octets from MSB to LSB
                        set $tmp_tlv_value [lreplace [set $tmp_tlv_value] 0 [mpexpr $ixn_length - [set $tmp_tlv_length] - 1]]
                    }
                }
            }
            
            set mip_mep_args ""

            foreach {hlt_param ixn_param p_type extensions} $mipmep_params {

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
                                keylset returnList log "ERROR in $procName: Invalid mac \
                                        address value $hlt_param_value for\
                                        $hlt_param parameter."
                                return $returnList
                            }
                            
                            set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                        }
                        use_ext {
                            switch -- [lindex $extensions 0] {
                                "cfm_mac_incr" {
                                    if {![isValidMacAddress $hlt_param_value]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "ERROR in $procName: Invalid mac \
                                                address value $hlt_param_value for\
                                                $hlt_param parameter."
                                        return $returnList
                                    }

                                    set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                                }
                                "cfm_tlv_formatter" {
                                    set length_param_name [lindex $extensions 2]
                                    if {![info exists $length_param_name]} {
                                        set $length_param_name \
                                            [ixNet getAttribute $handle \
                                                -[lindex $mipmep_params \
                                                        [mpexpr \
                                                            [lsearch $mipmep_params $length_param_name] + \
                                                            1\
                                                        ]\
                                                 ]\
                                            ]
                                    }
                                    
                                    set step_param_name [lindex $extensions 3]
                                    set $step_param_name 0
                                    
                                    set counter_param_name [lindex $extensions 4]
                                    set $counter_param_name 0
                                    
                                    set ret_val [eval $extensions]
                                    if {[keylget ret_val status] != $::SUCCESS} {
                                        keylset ret_val log "ERROR in $procName: [keylget ret_val log]"
                                        return $ret_val
                                    }
                                    
                                    set ixn_param_value [keylget ret_val ixn_param_value]
                                }
                                "cfm_incr_field" -
                                "cfm_inner_handle_setter" {
                                    set ixn_param_value $hlt_param_value
                                }
                                "cfm_short_ma_name_check" {
                                    if {![info exists short_ma_name_format]} {
                                        set short_ma_name_format [ixNet getAttribute $handle -shortMaNameFormat]
                                    }
                                    
                                    set ret_val [eval $extensions]
                                    if {[keylget ret_val status] != $::SUCCESS} {
                                        keylset ret_val log "ERROR in $procName: [keylget ret_val log]"
                                        return $ret_val
                                    }
                                    
                                    set ixn_param_value [keylget ret_val ixn_param_value]
                                }
                            }
                        }
                    }

                    if {$ixn_param_value != ""} {
                        if {[llength $ixn_param_value] > 1} {
                            append mip_mep_args "-$ixn_param \{$ixn_param_value\} "
                        } else {
                            append mip_mep_args "-$ixn_param $ixn_param_value "
                        }
                    }
                }
            }
            
            if {$mip_mep_args != ""} {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                        $handle                                                     \
                        $mip_mep_args                                               \
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
            foreach mip_mep_handle $handle {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                        $mip_mep_handle                                             \
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
            foreach mip_mep_handle $handle {
                debug "ixNet remove $mip_mep_handle"
                if {[ixNet remove $mip_mep_handle] != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to remove handle $mip_mep_handle."
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
    
    return $returnList
}


proc ::ixia::emulation_cfm_custom_tlv_config { args } {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        set retValue [eval clientSend $::ixTclSvrHandle  \{::ixia::emulation_cfm_custom_tlv_config $args\}]
        
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
         -length                      RANGE     0-1488
                                      DEFAULT   0
         -reset                       FLAG
         -type                        RANGE     0-255
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
    
    array set cfm_options_map {
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
                keylset returnList log "ERROR in $procName: Parameter -handle $ct_handle is not a valid CFM Custom TLV handle."
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
                keylset returnList log "ERROR in $procName: CFM Custom TLVs can be added only on one \
                        CFM Bridge handle with one procedure call. Parameter -bridge_handle contains a\
                        list of CFM Bridge handles."
                return $returnList
            }
            
            if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+$} $bridge_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -bridge_handle $bridge_handle is not a valid CFM Bridge handle."
                return $returnList
            }
            
            if {[ixNet exists $bridge_handle] == "false" || [ixNet exists $bridge_handle] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -bridge_handle $bridge_handle does not exist."
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
                                if {[info exists cfm_options_map($hlt_param_value)]} {
                                    set ixn_param_value $cfm_options_map($hlt_param_value)
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
                keylset returnList log "ERROR in $procName: Only one CFM Custom TLV \
                        handle can be modified with one procedure call.\
                        Parameter -handle is a list of CFM Custom TLV handles."
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
                            if {[info exists cfm_options_map($hlt_param_value)]} {
                                set ixn_param_value $cfm_options_map($hlt_param_value)
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
    
    return $returnList
}


proc ::ixia::emulation_cfm_vlan_config { args } {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        set retValue [eval clientSend $::ixTclSvrHandle  \{::ixia::emulation_cfm_vlan_config $args\}]
        
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
         -mode                        CHOICES   create modify enable disable remove
    }
    set opt_args {
         -bridge_handle               ANY       
         -count                       NUMERIC   
                                      DEFAULT   1
         -handle                      ANY       
         -mr_count                    ANY       
                                      DEFAULT   1
         -mr_inter_range_step         ANY       
                                      DEFAULT   00:00:00:00:01:00
         -mr_inter_vlan_step          ANY       
                                      DEFAULT   00:00:00:01:00:00
         -mr_mac_address              ANY       
                                      DEFAULT   00:00:00:00:00:00
         -mr_mac_address_step         ANY       
                                      DEFAULT   00:00:00:00:00:01
         -mr_mac_count                ANY       
                                      DEFAULT   1
         -reset                       FLAG
         -s_vlan_id                   RANGE     0-4095
                                      DEFAULT   1
         -s_vlan_id_step              RANGE     0-4094
                                      DEFAULT   1
         -s_vlan_priority             ANY       
         -s_vlan_tp_id                CHOICES   8100 9100 9200 88a8
                                      DEFAULT   8100
         -type                        CHOICES   single qinq
                                      DEFAULT   single
         -vlan_id                     RANGE     0-4095
                                      DEFAULT   1
         -vlan_id_step                RANGE     0-4095
                                      DEFAULT   1
         -vlan_priority               ANY       
         -vlan_tp_id                  CHOICES   8100 9100 9200 88a8
                                      DEFAULT   8100
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
    
    array set cfm_options_map {
        8100        "0x8100"
        9100        "0x9100"
        9200        "0x9200"
        88a8        "0x88a8"
        single      singleVlan
        qinq        stackedVlan
    }
    
    set mac_range_params {
        mr_enabled                  enabled     truth       _none
        mr_mac_address              macAddress  compute     _none
        mr_mac_address_step         step        mac         _none
        mr_mac_count                count       value       _none
    }
    
    set vlan_params {
        enabled                     enabled         truth       _none
        s_vlan_id                   cVlanId         compute     s_vlan_id_step
        s_vlan_priority             cVlanPriority   value       _none
        s_vlan_tp_id                cVlanTpId       translate   _none
        type                        type            translate   _none
        vlan_id                     sVlanId         compute     vlan_id_step
        vlan_priority               sVlanPriority   value       _none
        vlan_tp_id                  sVlanTpId       translate   _none
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
        
        foreach vlan_handle $handle {
            if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/vlans:\d+$} $vlan_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -handle $vlan_handle is not a valid CFM Vlan handle."
                return $returnList
            }
            
            if {[ixNet exists $vlan_handle] == "false" || [ixNet exists $vlan_handle] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -handle $vlan_handle does not exist."
                return $returnList
            }
        }
    }
    
    array set truth {1 true 0 false enable true disable false}
    
    # Check MAC parameters
    set mac_format_params [list mr_inter_range_step mr_inter_vlan_step mr_mac_address mr_mac_address_step]
    foreach mac_format_arg $mac_format_params {
        if {[info exists $mac_format_arg]} {
            set mac_format_arg_value [set $mac_format_arg]
            
            if {![isValidMacAddress $mac_format_arg_value]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Invalid mac address value $mac_format_arg_value for\
                        $mac_format_arg parameter."
                return $returnList
            }
            
            set $mac_format_arg [convertToIxiaMac $mac_format_arg_value]
        }
    }
    
    switch -- $mode {
        "create" {
            
            set enabled     1
            set mr_enabled  1
            
            # Check if bridge_handle parameter is ok
            
            if {![info exists bridge_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When -mode is $mode, parameter -bridge_handle is mandatory."
                return $returnList
            }
            
            if {[llength $bridge_handle] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: CFM Vlans can be added only on one \
                        CFM Bridge handle with one procedure call. Parameter -bridge_handle contains a\
                        list of CFM Bridge handles."
                return $returnList
            }
            
            if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+$} $bridge_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -bridge_handle $bridge_handle is not a valid CFM Bridge handle."
                return $returnList
            }
            
            if {[ixNet exists $bridge_handle] == "false" || [ixNet exists $bridge_handle] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -bridge_handle $bridge_handle does not exist."
                return $returnList
            }
            
            # Remove all md meg from this bridge if reset is present
            if {[info exists reset]} {
                set result [ixNetworkNodeRemoveList $bridge_handle \
                        { {child remove vlans} {} } -commit]
                if {[keylget result status] == $::FAILURE} {
                    keylset result log "ERROR in $procName: [keylget result log]"
                    return $result
                }
            }
            
            set vlan_handle_list ""
            
            for {set vlan_counter 0} {$vlan_counter < $count} {incr vlan_counter} {

                set vlan_args ""

                foreach {hlt_param ixn_param p_type extensions} $vlan_params {

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
                            compute {
                                # value must be incremented according to steps
                                if {$vlan_counter == 0} {
                                    set ixn_param_value $hlt_param_value
                                } else {
                                    if {[info exists $extensions]} {
                                        set step_value [set $extensions]
                                        set incr_ammount [mpexpr $vlan_counter * $step_value]
                                        set ixn_param_value [mpexpr $hlt_param_value + $incr_ammount]
                                        set ixn_param_value [mpexpr $ixn_param_value % 4096]
                                    }
                                }
                            }
                        }
                        
                        append vlan_args "-$ixn_param $ixn_param_value "
                    }
                }
                
                if {$vlan_args != ""} {
                    set tmp_status [::ixia::ixNetworkNodeAdd                            \
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
                    
                    lappend vlan_handle_list $vlan_handle
                }
                
                set mr_handle_list ""
                for {set mac_counter 0} {$mac_counter < $mr_count} {incr mac_counter} {

                    set mac_range_args ""

                    foreach {hlt_param ixn_param ptype extensions} $mac_range_params {
                        if {[info exists $hlt_param]} {
                            
                            set hlt_param_value [set $hlt_param]
                            
                            switch -- $ptype {
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
                                compute {
                                    set ixn_param_value $hlt_param_value
                                    
                                    for {set i 0} {$i < $vlan_counter} {incr i} {
                                        if {[info exists mr_inter_vlan_step]} {
                                            set ixn_param_value [incrementMacAdd $ixn_param_value $mr_inter_vlan_step]
                                        }
                                    }
                                    
                                    for {set i 0} {$i < $mac_counter} {incr i} {
                                        if {[info exists mr_inter_range_step]} {
                                            set ixn_param_value [incrementMacAdd $ixn_param_value $mr_inter_range_step]
                                        }
                                    }
                                    
                                    set ixn_param_value [regsub -all { } $ixn_param_value {:}]
                                }
                                mac {
                                    set ixn_param_value [regsub -all { } $hlt_param_value {:}]
                                }
                            }
                            
                            append mac_range_args "-$ixn_param $ixn_param_value "
                        }
                    }
                    
                    if {$mac_range_args != ""} {
                        set tmp_status [::ixia::ixNetworkNodeAdd                            \
                                $vlan_handle                                                \
                                "macRanges"                                                 \
                                $mac_range_args                                             \
                                -commit                                                     \
                            ]
                        if {[keylget tmp_status status] != $::SUCCESS} {
                            keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                            return $tmp_status
                        }
                        
                        set mac_handle [keylget tmp_status node_objref]
                        lappend mr_handle_list $mac_handle
                    }
                }
                
                if {$mr_handle_list != ""} {
                    keylset returnList mac_range_handles.$vlan_handle $mr_handle_list
                }
            }
            
            keylset returnList handle $vlan_handle_list
        }
        "modify" {
            if {[llength $handle] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Only one CFM Vlan \
                        handle can be modified with one procedure call.\
                        Parameter -handle is a list of CFM Vlan handles."
                return $returnList
            }
            
            set vlan_args ""

            foreach {hlt_param ixn_param p_type extensions} $vlan_params {

                if {[info exists $hlt_param]} {
                    
                    set hlt_param_value [set $hlt_param]

                    switch -- $p_type {
                        value -
                        compute {
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
                    
                    if {[info exists ixn_param_value]} {
                        append vlan_args "-$ixn_param $ixn_param_value "
                    }
                }
            }
            
            if {$vlan_args != ""} {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                        $handle                                                     \
                        $vlan_args                                                  \
                        -commit                                                     \
                    ]
                
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
            }
            
            if {[info exists mr_count]} {
                puts "\nWARNING in $procName: When -mode is 'modify' and -mr_count parameter is\
                        passed, ALL mac ranges configured on the CFM Vlan handle will be erased and\
                        new ones will be created.\n"
                        
                set result [ixNetworkNodeRemoveList $handle \
                        { {child remove macRanges} {} } -commit]
                if {[keylget result status] == $::FAILURE} {
                    keylset result log "ERROR in $procName: [keylget result log]"
                    return $result
                }
            
            
                for {set mac_counter 0} {$mac_counter < $mr_count} {incr mac_counter} {
                    set mac_range_args ""
                    foreach {hlt_param ixn_param ptype extensions} $mac_range_params {
                        if {[info exists $hlt_param]} {
                            
                            set hlt_param_value [set $hlt_param]
                            
                            switch -- $ptype {
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
                                compute {
                                    set ixn_param_value $hlt_param_value
                                    
                                    for {set i 0} {$i < $mac_counter} {incr i} {
                                        if {[info exists mr_inter_range_step]} {
                                            set ixn_param_value [incrementMacAdd $ixn_param_value $mr_inter_range_step]
                                        }
                                    }
                                    
                                    set ixn_param_value [regsub -all { } $ixn_param_value {:}]
                                }
                                mac {
                                    set ixn_param_value [regsub -all { } $hlt_param_value {:}]
                                }
                            }
                            
                            append mac_range_args "-$ixn_param $ixn_param_value "
                        }
                    }
                    
                    append mac_range_args "-enabled true"
                    
                    set tmp_status [::ixia::ixNetworkNodeAdd                            \
                            $handle                                                     \
                            "macRanges"                                                 \
                            $mac_range_args                                             \
                            -commit                                                     \
                        ]
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                }
            }

        }
        "enable" -
        "disable" {
            foreach vlan_handle $handle {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                        $vlan_handle                                              \
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
            foreach vlan_handle $handle {
                debug "ixNet remove $vlan_handle"
                if {[ixNet remove $vlan_handle] != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to remove handle $vlan_handle."
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
    
    return $returnList
}


proc ::ixia::emulation_cfm_links_config { args } {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        set retValue [eval clientSend $::ixTclSvrHandle  \{::ixia::emulation_cfm_links_config $args\}]
        
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
         -mode                        CHOICES   create modify enable disable remove
    }
    set opt_args {
         -bridge_handle               ANY       
         -count                       NUMERIC   
                                      DEFAULT   1
         -handle                      ANY       
         -link_type                   CHOICES   broadcast p2p
                                      DEFAULT   p2p
         -mip_mep_broadcast_handle_count NUMERIC
                                      DEFAULT 1
         -mip_mep_broadcast_handle_list ANY     
         -mip_mep_outwards_handle_list ANY      
         -mip_mep_towards_handle_list ANY       
         -reset                       FLAG
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
    
    array set cfm_options_map {
            broadcast       broadcast
            p2p             pointToPoint
        }
    
    set link_params {
            enabled                             enabled             truth
            mip_mep_outwards_handle_list        mpOutwardsIxia      value_at_index
            mip_mep_towards_handle_list         mpTowardsIxia       value_at_index
            mip_mep_broadcast_handle_list       moreMps             value_range
            link_type                           linkType            translate
        }
    
    array set truth {1 true 0 false enable true disable false}
    
    if {$mode == "modify"} {
            removeDefaultOptionVars $opt_args $args
    }

    if {$mode != "create"} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When -mode is $mode -handle\
                    parameter is mandatory."
            return $returnList
        }

        foreach links_handle $handle {
            if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/link:\d+$} $links_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -handle $links_handle\
                        is not a valid CFM Link handle."
                return $returnList
            }

            if {[ixNet exists $links_handle] == "false" || [ixNet exists $links_handle] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -handle $links_handle\
                        does not exist."
                return $returnList
            }
        }
    }
    
    switch -- $mode {
        "create" {
            set enabled 1
            
            # Check if bridge_handle parameter is ok
            
            if {![info exists bridge_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When -mode is $mode,\
                        parameter -bridge_handle is mandatory."
                return $returnList
            }
            
            if {[llength $bridge_handle] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: CFM Links \
                        can be added only on one CFM Bridge handle with one procedure\
                        call. Parameter -bridge_handle contains a list of CFM Bridge\
                        handles."
                return $returnList
            }
            
            if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+$} $bridge_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -bridge_handle
                        $bridge_handle is not a valid CFM Bridge handle."
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
                        { {child remove link} {} } -commit]
                if {[keylget result status] == $::FAILURE} {
                    keylset result log "ERROR in $procName: [keylget result log]"
                    return $result
                }
            }
        
            if {[info exists mip_mep_towards_handle_list] && $mip_mep_towards_handle_list != ""} {
                if {[llength $mip_mep_towards_handle_list] != $count} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Parameter -mip_mep_towards_handle_list\
                            $mip_mep_towards_handle_list must either be an empty list\
                            either have the length equal to -count $count parameter."
                    return $returnList
                }
            }
            
            if {[info exists mip_mep_outwards_handle_list] && $mip_mep_outwards_handle_list != ""} {
                if {[llength $mip_mep_outwards_handle_list] != $count} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Parameter -mip_mep_outwards_handle_list\
                            $mip_mep_outwards_handle_list must either be an empty list\
                            either have the length equal to -count $count parameter."
                    return $returnList
                }
            }
            
            if {[info exists mip_mep_towards_handle_list]} {
                foreach towards_handle $mip_mep_towards_handle_list {
                    if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/mp:\d+$} $towards_handle]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Parameter -mip_mep_towards_handle_list\
                                $towards_handle is not a valid CFM Maintenance Point handle."
                        return $returnList
                    }
        
                    if {[ixNet exists $towards_handle] == "false" || [ixNet exists $towards_handle] == 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Parameter -handle $towards_handle\
                                does not exist."
                        return $returnList
                    }
                }
            }
            
            if {[info exists mip_mep_outwards_handle_list]} {
                foreach outwards_handle $mip_mep_outwards_handle_list {
                    if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/mp:\d+$} $outwards_handle]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Parameter -mip_mep_outwards_handle_list\
                                $outwards_handle is not a valid CFM Maintenance Point handle."
                        return $returnList
                    }
        
                    if {[ixNet exists $outwards_handle] == "false" || [ixNet exists $outwards_handle] == 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Parameter -handle $outwards_handle\
                                does not exist."
                        return $returnList
                    }
                }
            }
            
            if {$link_type == "broadcast"} {
                if {[info exists mip_mep_broadcast_handle_list]} {
                    foreach broadcast_handle $mip_mep_broadcast_handle_list {
                        if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/mp:\d+$} $broadcast_handle]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Parameter -mip_mep_broadcast_handle_list\
                                    $broadcast_handle is not a valid CFM Maintenance Point handle."
                            return $returnList
                        }
            
                        if {[ixNet exists $broadcast_handle] == "false" || [ixNet exists $broadcast_handle] == 0} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Parameter -handle $broadcast_handle\
                                    does not exist."
                            return $returnList
                        }
                    }
                }
            }
            
            for {set counter 0} {$counter < $count} {incr counter} {
                
                set link_args ""
                
                foreach {hlt_param ixn_param p_type} $link_params {

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
                            value_at_index {
                                if {$hlt_param_value != ""} {
                                    set ixn_param_value [lindex $hlt_param_value $counter]
                                } else {
                                    continue
                                }
                            }
                            value_range {
                                if {$link_type == "p2p" || $mip_mep_broadcast_handle_count == 0 || \
                                        $mip_mep_broadcast_handle_list == ""} {
                                    continue
                                }
                                
                                set start_idx [mpexpr $counter * $mip_mep_broadcast_handle_count]
                                set end_idx   [mpexpr $start_idx + $mip_mep_broadcast_handle_count - 1]
                                
                                if {$start_idx > [mpexpr [llength $hlt_param_value] - 1]} {
                                    continue
                                }
                                
                                if {$end_idx > [mpexpr [llength $hlt_param_value] - 1]} {
                                    set end_idx "end"
                                }
                                
                                set ixn_param_value [lrange $hlt_param_value $start_idx $end_idx]
                            }
                        }
                        
                        if {[llength $ixn_param_value] > 1} {
                            append link_args "-$ixn_param \{$ixn_param_value\} "
                        } else {
                            append link_args "-$ixn_param $ixn_param_value "
                        }
                    }
                }
                
                if {$link_args != ""} {
                    set tmp_status [::ixia::ixNetworkNodeAdd                            \
                            $bridge_handle                                              \
                            "link"                                                      \
                            $link_args                                                  \
                            -commit                                                     \
                        ]
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                    
                    set link_handle [keylget tmp_status node_objref]
                    
                    lappend link_handle_list $link_handle
                }
            }
            
            keylset returnList handle $link_handle_list
        }
        "modify" {
            if {[llength $handle] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Only one CFM Link \
                        handle can be modified with one procedure call.\
                        Parameter -handle is a list of CFM Link handles."
                return $returnList
            }
                    
            if {[info exists mip_mep_towards_handle_list] && $mip_mep_towards_handle_list != ""} {
                if {[llength $mip_mep_towards_handle_list] > 1} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Parameter -mip_mep_towards_handle_list\
                            $mip_mep_towards_handle_list must either be an empty list\
                            either have the length equal to 1."
                    return $returnList
                }
                
                if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/mp:\d+$} $mip_mep_towards_handle_list]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Parameter -mip_mep_towards_handle_list\
                            $mip_mep_towards_handle_list is not a valid CFM Maintenance Point handle."
                    return $returnList
                }
    
                if {[ixNet exists $mip_mep_towards_handle_list] == "false" || [ixNet exists $mip_mep_towards_handle_list] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Parameter -mip_mep_towards_handle_list\
                            $mip_mep_towards_handle_list does not exist."
                    return $returnList
                }
            }
            
            if {[info exists mip_mep_outwards_handle_list] && $mip_mep_outwards_handle_list != ""} {
                if {[llength $mip_mep_outwards_handle_list] > 1} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Parameter -mip_mep_outwards_handle_list\
                            $mip_mep_outwards_handle_list must either be an empty list\
                            either have the length equal to 1."
                    return $returnList
                }
                
                if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/mp:\d+$} $mip_mep_outwards_handle_list]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Parameter -mip_mep_outwards_handle_list\
                            $mip_mep_outwards_handle_list is not a valid CFM Maintenance Point handle."
                    return $returnList
                }
    
                if {[ixNet exists $mip_mep_outwards_handle_list] == "false" || [ixNet exists $mip_mep_outwards_handle_list] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Parameter -mip_mep_outwards_handle_list\
                            $mip_mep_outwards_handle_list does not exist."
                    return $returnList
                }
            }
            
            if {![info exists link_type]} {
                set link_type [ixNet getAttribute $handle -linkType]
            }
            
            if {$link_type == "broadcast"} {
                if {[info exists mip_mep_broadcast_handle_list] && $mip_mep_broadcast_handle_list != ""} {
                    foreach broadcast_handle $mip_mep_broadcast_handle_list {
                        if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/mp:\d+$} $broadcast_handle]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Parameter -mip_mep_broadcast_handle_list\
                                    $broadcast_handle is not a valid CFM Maintenance Point handle."
                            return $returnList
                        }
            
                        if {[ixNet exists $broadcast_handle] == "false" || [ixNet exists $broadcast_handle] == 0} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Parameter -handle $broadcast_handle\
                                    does not exist."
                            return $returnList
                        }
                    }
                }
            }
            
            set link_args ""
            
            foreach {hlt_param ixn_param p_type} $link_params {

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
                        value_at_index {
                            if {$hlt_param_value != ""} {
                                set ixn_param_value $hlt_param_value
                            } else {
                                continue
                            }
                        }
                        value_range {
                            if {$hlt_param_value == "" || $link_type != "broadcast"} {
                                continue
                            }
                            
                            set ixn_param_value $hlt_param_value
                        }
                    }
                    
                    if {[llength $ixn_param_value] > 1} {
                        append link_args "-$ixn_param \{$ixn_param_value\} "
                    } else {
                        append link_args "-$ixn_param $ixn_param_value "
                    }
                }
            }
            
            if {$link_args != ""} {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                        $handle                                                     \
                        $link_args                                                  \
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
            foreach link_handle $handle {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                        \
                        $link_handle                                              \
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
            foreach link_handle $handle {
                debug "ixNet remove $link_handle"
                if {[ixNet remove $link_handle] != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to remove handle $link_handle."
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
    
    return $returnList
}


proc ::ixia::emulation_cfm_info { args } {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        set retValue [eval clientSend $::ixTclSvrHandle  \{::ixia::emulation_cfm_info $args\}]
        
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
         -mode                        CHOICES   set_filters get_ccm get_cfm_itu get_cfm_lt get_cfm_lb get_periodic_oam_lt get_periodic_oam_lb get_periodic_oam_dm get_all
    }
    set opt_args {
         -bridge_handle               ANY       
         -user_cvlan                  CHOICES   all_vlan_id no_vlan_id vlan_id
         -user_cvlan_id               ANY       
         -user_cvlan_priority         ANY       
         -user_cvlan_tpid             CHOICES   8100 9100 9200 88A8
         -user_delay_type             CHOICES   dm dvm
         -user_dst_mac_address        ANY       
         -user_dst_mep_id             ANY       
         -user_dst_type               CHOICES   mep_mac mep_id mep_mac_all mep_id_all
         -user_learned_info_time_out  ANY       
         -user_mdlevel                CHOICES   0 1 2 3 4 5 6 7 all_md
         -user_periodic_oam_type      CHOICES   link_trace loopback delay_measurement
         -user_send_type              CHOICES   unicast multicast
         -user_short_ma_name          ANY       
         -user_short_ma_name_format   CHOICES   all_formats primary_vid char_string two_octet_integer rfc2685_vpn_id
         -user_src_mac_address        ANY       
         -user_src_mep_id             ANY       
         -user_src_type               CHOICES   mep_mac mep_id mep_mac_all mep_id_all
         -user_svlan                  CHOICES   all_vlan_id no_vlan_id vlan_id
         -user_svlan_id               ANY       
         -user_svlan_priority         ANY       
         -user_svlan_tpid             CHOICES   8100 9100 9200 88A8
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
    
    array set cfm_options_map {
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
            user_cvlan                  userCvlan                   translate   _none
            user_cvlan_id               userCvlanId                 value       _none
            user_cvlan_priority         userCvlanPriority           value       _none
            user_cvlan_tpid             userCvlanTpId               translate   _none
            user_delay_type             userDelayType               translate   _none
            user_dst_mac_address        userDstMacAddress           mac         _none
            user_dst_mep_id             userDstMepId                value       _none
            user_dst_type               userDstType                 translate   _none
            user_learned_info_time_out  userLearnedInfoTimeOut      value       _none
            user_mdlevel                userMdLevel                 translate   _none
            user_periodic_oam_type      userPeriodicOamType         translate   _none
            user_send_type              userSendType                translate   _none
            user_short_ma_name          userShortMaName             use_ext     "cfm_short_ma_name_check        \
                                                                                    user_short_ma_name          \
                                                                                    user_short_ma_name_format   "
            user_short_ma_name_format   userShortMaNameFormat       translate   _none
            user_src_mac_address        userSrcMacAddress           mac         _none
            user_src_mep_id             userSrcMepId                value       _none
            user_src_type               userSrcType                 translate   _none
            user_svlan                  userSvlan                   translate   _none
            user_svlan_id               userSvlanId                 value       _none
            user_svlan_priority         userSvlanPriority           value       _none
            user_svlan_tpid             userSvlanTpId               translate   _none
            user_transaction_id         userTransactionId           value       _none
            user_ttl_interval           userTtlInterval             value       _none
            user_usability_option       userUsabilityOption         translate   _none
        }
    
    # Check if bridge_handle parameter is ok
        
    if {![info exists bridge_handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Parameter -bridge_handle is mandatory."
        return $returnList
    }
    
    if {[llength $bridge_handle] > 1} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: CFM Statistics can be configured\
                and read only on one CFM Bridge handle with one procedure\
                call. Parameter -bridge_handle contains a list of CFM Bridge\
                handles."
        return $returnList
    }
    
    if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+$} $bridge_handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Parameter -bridge_handle
                $bridge_handle is not a valid CFM Bridge handle."
        return $returnList
    }
    
    if {[ixNet exists $bridge_handle] == "false" || [ixNet exists $bridge_handle] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Parameter -bridge_handle
                $bridge_handle does not exist."
        return $returnList
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
                        if {[info exists cfm_options_map($hlt_param_value)]} {
                            set ixn_param_value $cfm_options_map($hlt_param_value)
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
                        
                        set ixn_param_value [convertToIxiaMac $hlt_param_value]
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
    
    if {$mode == "get_ccm" || $mode == "get_all"} {
        #   hlt_key             ixn_key
        set stat_keys_ccm {
                  ccm.all_rmep_dead             allRmepDead
                  ccm.c_vlan                    cVlan
                  ccm.cci_interval              cciInterval
                  ccm.err_ccm_defect            errCcmDefect
                  ccm.md_level                  mdLevel
                  ccm.md_name                   mdName
                  ccm.md_name_format            mdNameFormat
                  ccm.mep_id                    mepId
                  ccm.mep_mac_address           mepMacAddress
                  ccm.out_ofsequence_ccm_count  outOfSequenceCcmCount
                  ccm.received_ais              receivedAis
                  ccm.received_iface_tlv_defect receivedIfaceTlvDefect
                  ccm.received_port_tlv_defect  receivedPortTlvDefect
                  ccm.received_rdi              receivedRdi
                  ccm.rmep_ccm_defect           rmepCcmDefect
                  ccm.s_vlan                    sVlan
                  ccm.short_maname              shortMaName
                  ccm.short_maname_format       shortMaNameFormat
                  ccm.some_rmep_defect          someRmepDefect
            }
        
        set ccm_status [::ixia::get_cfm_learned_info                    \
                                    $stat_keys_ccm                      \
                                    $bridge_handle                      \
                                    "refreshCcmLearnedInfo"             \
                                    "isCcmLearnedInfoRefreshed"         \
                                    "ccmLearnedInfo"                    \
                                    "returnList"                        ]
        if {[keylget ccm_status status] != $::SUCCESS} {
            keylset ccm_status log "ERROR in $procName on get_cfm_ccm. [keylget ccm_status log]"
            return $ccm_status
        }
    }
    
    if {$mode == "get_cfm_itu" || $mode == "get_all"} {
        #   hlt_key             ixn_key
        set stat_keys_cfm_itu {
                itu.c_vlan                    cVlan
                itu.dst_mac_address           dstMacAddress
                itu.md_level                  mdLevel
                itu.s_vlan                    sVlan
                itu.src_mac_address           srcMacAddress
                itu.value_in_nano_sec         valueInNanoSec
                itu.value_in_sec              valueInSec
            }
        
        set cfm_itu_status [::ixia::get_cfm_learned_info                \
                                    $stat_keys_cfm_itu                  \
                                    $bridge_handle                      \
                                    "startDelayMeasurement"             \
                                    "isDelayMeasurementLearnedInfoRefreshed"\
                                    "delayLearnedInfo"                  \
                                    "returnList"                        ]
        if {[keylget cfm_itu_status status] != $::SUCCESS} {
            keylset cfm_itu_status log "ERROR in $procName on get_cfm_itu. [keylget cfm_itu_status log]"
            return $cfm_itu_status
        }
    }
    
    if {$mode == "get_cfm_lt" || $mode == "get_all"} {
         set stat_keys_lt {
                lt.c_vlan                     cVlan
                lt.dst_mac_address            dstMacAddress
                lt.hop_count                  hopCount
                lt.md_level                   mdLevel
                lt.reply_status               replyStatus
                lt.s_vlan                     sVlan
                lt.src_mac_address            srcMacAddress
                lt.transaction_id             transactionId
            }
            
        set stat_keys_lt_learned_hop {
                lt.learned_hop.egress_mac     egressMac
                lt.learned_hop.ingress_mac    ingressMac
                lt.learned_hop.reply_ttl      replyTtl
            }
            
        set cfm_lt_status [::ixia::get_cfm_learned_info                 \
                                    $stat_keys_lt                       \
                                    $bridge_handle                      \
                                    "startLinkTrace"                    \
                                    "isLinkTraceLearnedInfoRefreshed"   \
                                    "ltLearnedInfo"                     \
                                    "returnList"                        \
                                    $stat_keys_lt_learned_hop           \
                                    "ltLearnedHop"                      \
                                    "_use_index"                        ]
        if {[keylget cfm_lt_status status] != $::SUCCESS} {
            keylset cfm_lt_status log "ERROR in $procName on get_cfm_lt. [keylget cfm_lt_status log]"
            return $cfm_lt_status
        }
    }
    
    if {$mode == "get_cfm_lb" || $mode == "get_all"} {
        
        #   hlt_key             ixn_key
        set stat_keys_lb {
            lb.c_vlan              cVlan
            lb.dst_mac_address     dstMacAddress
            lb.md_level            mdLevel
            lb.reachability        reachability
            lb.rtt                 rtt
            lb.s_vlan              sVlan
        }
        
        set lb_status [::ixia::get_cfm_learned_info                     \
                                    $stat_keys_lb                       \
                                    $bridge_handle                      \
                                    "startLoopback"                     \
                                    "isLoopbackLearnedInfoRefreshed"    \
                                    "lbLearnedInfo"                     \
                                    "returnList"                        ]
        if {[keylget lb_status status] != $::SUCCESS} {
            keylset lb_status log "ERROR in $procName on get_cfm_lb. [keylget lb_status log]"
            return $lb_status
        }
    }
    
    
    if {$mode == "get_periodic_oam_lt" || $mode == "get_all"} {
         set stat_keys_periodic_lt {
                periodic_oam_lt.average_hop_count       averageHopCount
                periodic_oam_lt.c_vlan                  cVlan
                periodic_oam_lt.complete_reply_count    completeReplyCount
                periodic_oam_lt.dst_mac_address         dstMacAddress
                periodic_oam_lt.ltm_sent_count          ltmSentCount
                periodic_oam_lt.md_level                mdLevel
                periodic_oam_lt.no_reply_count          noReplyCount
                periodic_oam_lt.partial_reply_count     partialReplyCount
                periodic_oam_lt.recent_hop_count        recentHopCount
                periodic_oam_lt.recent_hops             recentHops
                periodic_oam_lt.recent_reply_status     recentReplyStatus
                periodic_oam_lt.s_vlan                  sVlan
                periodic_oam_lt.src_mac_address         srcMacAddress
            }
            
        set stat_keys_periodic_lt_learned_hop {
                periodic_oam_lt.learned_hop.egress_mac     egressMac
                periodic_oam_lt.learned_hop.ingress_mac    ingressMac
                periodic_oam_lt.learned_hop.reply_ttl      replyTtl
            }
            
        set cfm_periodic_lt_status [::ixia::get_cfm_learned_info        \
                                    $stat_keys_periodic_lt              \
                                    $bridge_handle                      \
                                    "updatePeriodicOamLearnedInfo"      \
                                    "isPeriodicOamLearnedInfoRefreshed" \
                                    "periodicOamLtLearnedInfo"          \
                                    "returnList"                        \
                                    $stat_keys_periodic_lt_learned_hop  \
                                    "ltLearnedHop"                      \
                                    "_use_index"                        ]
        if {[keylget cfm_periodic_lt_status status] != $::SUCCESS} {
            keylset cfm_periodic_lt_status log "ERROR in $procName on get_periodic_oam_lt. [keylget cfm_periodic_lt_status log]"
            return $cfm_periodic_lt_status
        }
    }
    
    if {$mode == "get_periodic_oam_lb" || $mode == "get_all"} {

        set stat_keys_periodic_lb {
                periodic_oam_lb.average_rtt             averageRtt
                periodic_oam_lb.c_vlan                  cVlan
                periodic_oam_lb.dst_mac_address         dstMacAddress
                periodic_oam_lb.lbm_sent_count          lbmSentCount
                periodic_oam_lb.md_level                mdLevel
                periodic_oam_lb.no_reply_count          noReplyCount
                periodic_oam_lb.recent_reachability     recentReachability
                periodic_oam_lb.recent_rtt              recentRtt
                periodic_oam_lb.s_vlan                  sVlan
                periodic_oam_lb.src_mac_address         srcMacAddress
            }
        
        set periodic_lb_status [::ixia::get_cfm_learned_info            \
                                    $stat_keys_periodic_lb              \
                                    $bridge_handle                      \
                                    "updatePeriodicOamLearnedInfo"      \
                                    "isPeriodicOamLearnedInfoRefreshed" \
                                    "periodicOamLbLearnedInfo"          \
                                    "returnList"                        ]
        if {[keylget periodic_lb_status status] != $::SUCCESS} {
            keylset periodic_lb_status log "ERROR in $procName on get_periodic_oam_lb.\
                    [keylget periodic_lb_status log]"
            return $periodic_lb_status
        }        
    }
    
    if {$mode == "get_periodic_oam_dm" || $mode == "get_all"} {
        
        set stat_keys_periodic_dm {
                periodic_oam_dm.average_delay_nano_sec  averageDelayNanoSec
                periodic_oam_dm.average_delay_sec       averageDelaySec
                periodic_oam_dm.c_vlan                  cVlan
                periodic_oam_dm.dmm_count_sent          dmmCountSent
                periodic_oam_dm.dst_mac_address         dstMacAddress
                periodic_oam_dm.md_level                mdLevel
                periodic_oam_dm.no_reply_count          noReplyCount
                periodic_oam_dm.recent_delay_nano_sec   recentDelayNanoSec
                periodic_oam_dm.recent_delay_sec        recentDelaySec
                periodic_oam_dm.s_vlan                  sVlan
                periodic_oam_dm.src_mac_address         srcMacAddress
            }
        
        set periodic_dm_status [::ixia::get_cfm_learned_info            \
                                    $stat_keys_periodic_dm              \
                                    $bridge_handle                      \
                                    "updatePeriodicOamLearnedInfo"      \
                                    "isPeriodicOamLearnedInfoRefreshed" \
                                    "periodicOamLbLearnedInfo"          \
                                    "returnList"                        ]
                                    
        if {[keylget periodic_dm_status status] != $::SUCCESS} {
            keylset periodic_dm_status log "ERROR in $procName on get_periodic_oam_dm.\
                    [keylget periodic_dm_status log]"
            return $periodic_dm_status
        }
    }
    
    return $returnList
}


proc ::ixia::emulation_cfm_control { args } {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        set retValue [eval clientSend $::ixTclSvrHandle  \{::ixia::emulation_cfm_control $args\}]
        
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
         -mode                        CHOICES   start stop
         -port_handle                 ANY       
    }

    ::ixia::parse_dashed_args -args $args -mandatory_args $man_args
    
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
            keylset returnList log "ERROR in $procName: Failed to $mode CFM on the\
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
            keylset returnList log "Failed to $operation BFD on the\
                    $vport_objref port. Error code: $retCode."
            return $returnList
        }
    }
    
    return $returnList
}
