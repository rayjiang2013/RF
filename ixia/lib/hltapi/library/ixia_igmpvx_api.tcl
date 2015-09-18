##Library Header
# $Id: $
# Copyright 2003-2006 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_igmpvx_api.tcl
#
# Purpose:
#     A script development library containing IGMPvX APIs for test automation
#     with the Ixia chassis.
#
# Author:
#    Lavinia Raicea
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures contained within this library include:
#
#    - emulation_igmp_config
#    - emulation_igmp_querier_config
#    - emulation_igmp_control
#    - emulation_igmp_group_config
#    - emulation_igmp_info
#
# Requirements:
#     ixiaapiutils.tcl , a library containing TCL utilities
#     parseddashedargs.tcl , a library containing the proceDescr and
#     parsedashedargds.tcl
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


proc ::ixia::emulation_igmp_config { args } {
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
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::emulation_igmp_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    variable igmp_host_handles_array
    variable igmp_group_handles_array
    variable igmp_attributes_array
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set man_args {
        -mode CHOICES create delete modify enable disable enable_all disable_all
    }
    set opt_args {
        -atm_encapsulation              CHOICES VccMuxIPV4Routed
                                        CHOICES VccMuxIPV6Routed
                                        CHOICES VccMuxBridgedEthernetFCS
                                        CHOICES VccMuxBridgedEthernetNoFCS
                                        CHOICES LLCRoutedCLIP
                                        CHOICES LLCBridgedEthernetFCS
                                        CHOICES LLCBridgedEthernetNoFCS
        -count                          NUMERIC
                                        DEFAULT 1
        -enable_packing                 CHOICES 0 1
                                        DEFAULT 0
        -filter_mode                    CHOICES include exclude
        -general_query                  CHOICES 0 1
        -group_query                    CHOICES 0 1
        -handle
        -igmp_version                   CHOICES v1 v2 v3
        -interface_handle
        -intf_ip_addr                   IP
        -intf_ip_addr_step              IP
                                        DEFAULT 0.0.0.1
        -intf_prefix_len                RANGE   1-32
                                        DEFAULT 24
        -ip_router_alert                CHOICES 0 1
        -mac_address_init               MAC
        -mac_address_step               MAC 
                                        DEFAULT 0000.0000.0001
        -max_groups_per_pkts            RANGE   0-1500
        -max_response_control           CHOICES 0 1
        -max_response_time              NUMERIC
        -max_sources_per_group          RANGE   0-1500
        -msg_count_per_interval         NUMERIC
                                        DEFAULT 0
        -msg_interval                   NUMERIC
                                        DEFAULT 0
        -neighbor_intf_ip_addr          IP
        -neighbor_intf_ip_addr_step     IP
                                        DEFAULT 0.0.0.0
        -no_write                       FLAG
        -override_existence_check       CHOICES 0 1
                                        DEFAULT 0
        -override_tracking              CHOICES 0 1
                                        DEFAULT 0
        -port_handle                    REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -reset                          FLAG
        -suppress_report                CHOICES 0 1
        -unsolicited_report_interval    NUMERIC
        -vci                            RANGE   0-65535
                                        DEFAULT 10
        -vci_step                       RANGE   0-65535
                                        DEFAULT 1
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
        -vpi_step                       RANGE   0-255
                                        DEFAULT 1
    }
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_igmp_config $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        return $returnList
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args
    
    # Check if the card supports IGMPVX
    if {[info exists port_handle]} {
        set port_list [format_space_port_list $port_handle]
        foreach port_i $port_list {
            foreach {chs_i crd_i prt_i} $port_i {}
            if {![port isValidFeature $chs_i $crd_i $prt_i \
                        portFeatureProtocolIGMP]} {
                
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : This card does not\
                        support IgmpVx."
                return $returnList
            }
        }
    }
    # Check if IGMP package has been installed on the port
    if {[info exists port_handle]} {
        set port_list [format_space_port_list $port_handle]
        foreach port_i $port_list {
            foreach {chs_i crd_i prt_i} $port_i {}
            if {[catch {igmpVxServer select $chs_i $crd_i $prt_i } error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The IGMP\
                        protocol has not been installed on port or\
                        is not supported on port: \
                        $chs_i/$crd_i/$prt_i."
                return $returnList
            }
        }
    }
    # Verify parameters given for each option
    if {($mode == "create") || ($mode == "enable_all") \
                || ($mode == "disable_all")} {
        if {![info exists port_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : No -port_handle was\
                    passed to $mode."
            return $returnList
        }
        set port_list [format_space_port_list $port_handle]
        foreach {chassis card port} [lindex $port_list 0] {}
        
    } elseif {($mode == "enable") || ($mode == "disable") \
                || ($mode == "delete") || ($mode == "modify")} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : No -handle was\
                    passed to $mode."
            return $returnList
        } else  {
            set groupPortRet [::ixia::igmp_group_sessions_by_port $handle]
            if {[keylget groupPortRet status] == 0} {
                keylset groupPortRet log "ERROR in $procName : \
                        [keylget groupPortRet log]"
                return $groupPortRet
            }
            array set sessions_per_port [keylget groupPortRet port_group]
            
            if {[array size sessions_per_port] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : -handle was\
                        not valid for -$mode."
                return $returnList
            }

            keylset returnList handle $handle
        }
    }
    
    # Set unsolicited report 0 if the interval is 0
    if {[info exists unsolicited_report_interval]} {
        if {$unsolicited_report_interval == 0}  {
            set unsolicited_report 0
        } else  {
            set unsolicited_report 1
        }
    }
    
    # Setup the corresponding parameters array
    array set igmpHost [list \
            igmp_version                          version                 \
            ip_router_alert                       enableRouterAlert       \
            general_query                         enableGeneralQuery      \
            group_query                           enableGroupSpecific     \
            unsolicited_report                    enableUnsolicited       \
            unsolicited_report_interval           reportFrequency         \
            suppress_report                       enableSuppressReports   \
            immediate_response                    enableImmediateResponse \
            ]
            
    set groups_options_list {enable_packing max_groups_per_pkts \
            max_sources_per_group}
    
    array set enumList [list ]
    set igmp_host_list [list ]
    set description_list [list ]
    
    # Clear all hosts if -reset
    if {[info exists reset] && [info exists port_handle]} {
        set port_list [format_space_port_list $port_handle]
        foreach {chassis card port} [lindex $port_list 0] {}
        
        if {[igmpVxServer select $chassis $card $port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : Failed\
                    to igmpVxServer select $chassis $card $port."
            return $returnList
        }
        igmpVxServer clearAllHosts
        ::ixia::igmp_clear_all_hosts $chassis $card $port
    }
    
    # Set IGMP Host version
    if {[info exists igmp_version]} {
        set igmp_version igmpHostVersion[string index $igmp_version 1]
        
    }
    # If I have a vlan id then enable vlan
    if {[info exists vlan_id]} {
        set vlan 1
    }
    
    if {[info exists filter_mode]} {
        switch -exact $filter_mode  {
            include {
                set filter_mode multicastSourceModeInclude
            }
            exclude {
                set filter_mode multicastSourceModeExclude
            }
        }
    }
    # Check if the call -mode option
    # if it's modify,   delete,   enable,  disable we need to verify that a
    # handle is also passed to the procedure
    if {$mode == "delete"} {
        # Delete all hosts passed by the handle
        foreach port_i [array names sessions_per_port] {
            set port_list [format_space_port_list $port_i]
            foreach {chassis card port} [lindex $port_list 0] {}
            ::ixia::addPortToWrite $chassis/$card/$port

            if {[igmpVxServer select $chassis $card $port]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : Failed\
                        to set igmpVxServer select $chassis $card $port."
                return $returnList
            }
            foreach session_handle $sessions_per_port($port_i) {
                set hostRet [::ixia::igmp_get_host_handle_host $session_handle]
                if {[keylget hostRet status] == 0} {
                    keylset hostRet log "ERROR in $procName : \
                            [keylget hostRet log]"
                    return $hostRet
                }
                set host_handle [keylget hostRet host_handle]
                
                if {[igmpVxServer delHost $host_handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : Failed\
                            to delete the IGMP Host $session_handle."
                    return $returnList
                }
                unset ::ixia::igmp_host_handles_array($session_handle)
                set retUnset [::ixia::igmp_array_unset_values             \
                        -array_handle    ::ixia::igmp_group_handles_array \
                        -session_handle  $session_handle]
                if {[keylget retUnset status] == 0} { return $retUnset  }
            }
            if {[igmpVxServer set]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName -$mode: Failed\
                        to set IGMP configuration (igmpVxServer)."
                return $returnList
            }
        }
    } elseif {$mode == "enable"} {
        # Enable hosts passed through the handle parameter
        foreach port_i [array names sessions_per_port] {
            set port_list [format_space_port_list $port_i]
            foreach {chassis card port} [lindex $port_list 0] {}
            ::ixia::addPortToWrite $chassis/$card/$port

            if {[igmpVxServer select $chassis $card $port]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : Failed\
                        to set igmpVxServer select $chassis $card $port."
                return $returnList
            }
            foreach session_handle $sessions_per_port($port_i) {
                set hostRet [::ixia::igmp_get_host_handle_host $session_handle]
                if {[keylget hostRet status] == 0} {
                    keylset hostRet log "ERROR in $procName : \
                            [keylget hostRet log]"
                    return $hostRet
                }
                set host_handle [keylget hostRet host_handle]
                
                if {[igmpVxServer getHost $host_handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName -$mode: Failed\
                            to enable the IGMP Host $session_handle."
                    return $returnList
                } else {
                    igmpHost config -enable true
                    if {[igmpVxServer setHost $host_handle]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName -$mode: \
                                Failed to igmpVxServer setHost $host_handle."
                        return $returnList
                    }
                }
            }
            if {[igmpVxServer set]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName -$mode: Failed\
                        to set IGMP configuration (igmpVxServer)."
                return $returnList
            }
        }
    } elseif {$mode == "disable"} {
        # Disable hosts passed through the handle parameter
        foreach port_i [array names sessions_per_port] {
            set port_list [format_space_port_list $port_i]
            foreach {chassis card port} [lindex $port_list 0] {}
            ::ixia::addPortToWrite $chassis/$card/$port
            
            if {[igmpVxServer select $chassis $card $port]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : Failed\
                        to set igmpVxServer select $chassis $card $port."
                return $returnList
            }
            foreach session_handle $sessions_per_port($port_i) {
                set hostRet [::ixia::igmp_get_host_handle_host $session_handle]
                if {[keylget hostRet status] == 0} {
                    keylset hostRet log "ERROR in $procName : \
                            [keylget hostRet log]"
                    return $hostRet
                }
                set host_handle [keylget hostRet host_handle]
                
                if {[igmpVxServer getHost $host_handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : Failed\
                            to disable the IGMP Host $session_handle."
                    return $returnList
                } else {
                    igmpHost config -enable false
                    if {[igmpVxServer setHost $host_handle]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName -$mode: \
                                Failed to igmpVxServer setHost $host_handle."
                        return $returnList
                    }
                    
                }
            }
            if {[igmpVxServer set]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName -$mode: Failed\
                        to set IGMP configuration (igmpVxServer)."
                return $returnList
            }
        }
    } elseif {$mode == "enable_all"}  {
        # Enable all hosts
        foreach port_item $port_list {
            foreach {chassis card port} $port_item {}
            ::ixia::addPortToWrite $chassis/$card/$port
            
            if {[igmpVxServer select $chassis $card $port]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : Failed\
                        to set igmpVxServer select $chassis $card $port."
                return $returnList
            }
            set temp_host_list [::ixia::igmp_get_all_host_handles_port \
                    $chassis/$card/$port]
            foreach _host $temp_host_list {
                set ret_code [igmpVxServer getHost $_host]
                if {$ret_code == 0} {
                    igmpHost config -enable true
                    if {[igmpVxServer setHost $_host]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName -$mode:\
                                Failed to igmpVxServer setHost $_host."
                        return $returnList
                    }
                }
            }
            if {[igmpVxServer set]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName -$mode: Failed\
                        to set IGMP configuration (igmpVxServer)."
                return $returnList
            }

            keylset returnList handle $temp_host_list
        }
    } elseif {$mode == "disable_all"}  {
        # Disable all hosts
        foreach port_item $port_list {
            foreach {chassis card port} $port_item {}
            ::ixia::addPortToWrite $chassis/$card/$port
            
            if {[igmpVxServer select $chassis $card $port]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : Failed\
                        to set igmpVxServer select $chassis $card $port."
                return $returnList
            }
            set temp_host_list [::ixia::igmp_get_all_host_handles_port \
                    $chassis/$card/$port]
            foreach _host $temp_host_list {
                set ret_code [igmpVxServer getHost $_host]
                if {$ret_code == 0} {
                    igmpHost config -enable false
                    if {[igmpVxServer setHost $_host]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName -$mode:\
                                Failed to igmpVxServer setHost $_host."
                        return $returnList
                    }
                }
            }
            if {[igmpVxServer set]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName -$mode: Failed\
                        to set IGMP configuration (igmpVxServer)."
                return $returnList
            }

            keylset returnList handle $temp_host_list
        }
    } elseif {$mode == "create"} {
        ::ixia::addPortToWrite $chassis/$card/$port

        #  CONFIGURE THE IXIA INTERFACES
        if {![info exists interface_handle] && \
                ((![info exists intf_ip_addr]) || \
                (![info exists neighbor_intf_ip_addr]))} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : Trying to create an\
                    interface and either -intf_ip_addr or\
                    -neighbor_intf_ip_addr is missing from the argument list."
            return $returnList
        }
        # Set default immediate response
        if {![info exists max_response_control]} {
            set temp_control 0
        } else  {
            set temp_control $max_response_control
        }
        if {![info exists max_response_time]} {
            set temp_time ""
        } else  {
            set temp_time $max_response_time
        }

        set temp_switch "${temp_control}SEP${temp_time}"
        switch -regexp $temp_switch {
            {1SEP0}          { set immediate_response 1 }
            {1SEP([^0]+).*}  { set immediate_response 0 }
            {1SEP}           {  }
            {0SEP(.*)}       { set immediate_response 0 }
            {SEP}            {  }
        }

        # Set default IGMP version
        if {![info exists igmp_version]} {
            set igmp_version igmpHostVersion2
        }

        # Set default values for IGMPv2 and IGMPv3 report_interval
        if {![info exists unsolicited_report_interval]} {
            if {$igmp_version == "igmpHostVersion2"} {
                set unsolicited_report_interval 100
                set unsolicited_report 1
            } elseif {$igmp_version == "igmpHostVersion3"} {
                set unsolicited_report_interval 10
                set unsolicited_report 1
            }
        }

        # Set IP version
        if {![info exists ip_version]} {
            if {[info exists intf_ip_addr]} {
                if {[llength [split $intf_ip_addr .]] == 4} {
                    set ip_version 4
                } else {
                    set ip_version 6
                }
            } else {
                set ip_version 4
            }
        }

        # Set the list of parameters with default values
        set param_value_list [list                      \
                count                        1          \
                intf_ip_addr_step            0.0.0.1    \
                intf_prefix_len              24         \
                neighbor_intf_ip_addr_step   0.0.0.0    \
                msg_interval                 0          \
                msg_count_per_interval       0          \
                ip_router_alert              1          \
                general_query                1          \
                group_query                  1          \
                suppress_report              0          \
                filter_mode                  multicastSourceModeInclude ]
        # Initialize non-existing parameters with default values
        foreach {param value} $param_value_list {
            if {![info exists $param]} {
                set $param $value
            }
        }

        # Create interfaces
        if {[info exists interface_handle]} {
            if {[llength $interface_handle] > 1} {
                foreach item $interface_handle {
                    set description_list [lappend description_list \
                            [rfget_interface_description_from_handle $item]]
                }
            } else {
                set description_list [lappend description_list \
                        [rfget_interface_description_from_handle $interface_handle]]
            }
        } else {

            # Options that are mandatory for the protocol interface config call
            set config_param \
                    "-port_handle $port_handle      \
                    -ip_address   $intf_ip_addr     \
                    -ip_version   $ip_version       \
                    -count        $count            "

            # Options that are optional and will only be used if set for the
            # protocol interface config call.
            set config_options \
                    "-mac_address            mac_address_init           \
                    -gateway_ip_address      neighbor_intf_ip_addr      \
                    -gateway_ip_address_step neighbor_intf_ip_addr_step \
                    -ip_address_step         intf_ip_addr_step          \
                    -netmask                 intf_prefix_len            \
                    -vlan_id                 vlan_id                    \
                    -vlan_id_mode            vlan_id_mode               \
                    -vlan_id_step            vlan_id_step               \
                    -vlan_user_priority      vlan_user_priority         \
                    -no_write                no_write                   "

            foreach {option value_name} $config_options {
                if {[info exists $value_name]} {
                    append config_param " $option [set $value_name] "
                }
            }

            set interface_config_status [eval ::ixia::protocol_interface_config \
                    $config_param]

            if {[keylget interface_config_status status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : \
                        Could not configure the interface(s) \
                        on the Protocol Server for port: \
                        $chassis $card $port. Error Log :\
                        [keylget interface_config_status log]"
                return $returnList
            }
            set description_list [concat $description_list \
                    [keylget interface_config_status  description] ]
        }

        # Check interfaces to see if they already have hosts configured
        # if they have hosts configured we will not configure a second one
        for {set i 1} {$i <= [llength $description_list]} {incr i} {
            set check_host_existence [::ixia::igmp_check_host_existence \
                    [list $chassis $card $port] \
                    [lindex $description_list [expr $i - 1]] ]
            if {[keylget check_host_existence status] == 0} {
                keylset check_host_existence log "ERROR in $procName : \
                        [keylget check_host_existence log]"
                return $check_host_existence
            } elseif {[keylget check_host_existence existence]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : \
                        Could not add host on interface\
                        [lindex $description_list [expr $i - 1]] \
                        because protocol interface already in use\
                        by other host"
                return $returnList
            }
        }
        # Set protocol server
        set retCode [protocolServer get $chassis $card $port]
        if {$retCode != 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failure in call to\
                    protocolServer get $chassis $card $port.  Return code was\
                    $retCode."
            return $returnList
        }
        protocolServer config -enableIgmpQueryResponse true
        set retCode [protocolServer set $chassis $card $port]
        if {$retCode != 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failure in call to\
                    protocolServer set $chassis $card $port.  Return code was\
                    $retCode."
            return $returnList
        }
        
        # Select port
        if {[igmpVxServer select $chassis $card $port]} {
            keylset returnList log "ERROR in $procName : igmpVxServer select\
                    on port $chassis $card $port failed."
            keylset returnList status $::FAILURE
            return $returnList
        }
        # Create hosts
        for {set host_num 1} {$host_num <= $count} {incr host_num} {
            set retNextHost [::ixia::igmp_get_next_handle host]
            if {[keylget retNextHost status] == 0} {
                keylset retNextHost log "ERROR in $procName : \
                        [keylget retNextHost log]"
                return retNextHost
            }
            set igmp_next_neighbor [keylget retNextHost next_handle]
            if {$host_num == 1} {
                igmpVxServer setDefault
            }
            if {[info exists msg_interval]} {
                igmpVxServer config -timePeriod $msg_interval
            }
            if {[info exists msg_count_per_interval]} {
                igmpVxServer config -numGroups $msg_count_per_interval
            }
            igmpHost setDefault
            igmpHost clearAllGroupRanges
            igmpHost config -enable true
            igmpHost config -protocolInterfaceDescription         \
                    [lindex $description_list [expr $host_num - 1]]
            # Configure host
            foreach item [array names igmpHost] {
                if {![catch {set $item} value] } {
                    if {[lsearch [array names enumList] $value] != -1} {
                        set value $enumList($value)
                    }
                    catch {igmpHost config -$igmpHost($item) $value}
                }
            }
            # Add host
            set retCode [igmpVxServer addHost $igmp_next_neighbor]
            if {$retCode != 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : Could not add\
                        Host $igmp_next_neighbor to the IGMP server.\
                        Error code: $retCode."
                return $returnList
            }
            
            set retSession [::ixia::igmp_get_next_handle session]
            set temp_session_handle [keylget retSession next_handle]

            foreach group_item $groups_options_list {
                if {[info exists $group_item]} {
                    append ::ixia::igmp_attributes_array($temp_session_handle,attr) \
                            "[list $group_item [set $group_item]] "
                }
            }

            lappend igmp_host_list $temp_session_handle
            # Set mandatory params for adding new session_handle
            set mandatory_add_config \
                    "-session_handle $temp_session_handle  \
                    -port_handle    $port_handle          \
                    -host_handle    $igmp_next_neighbor   \
                    -filter_mode    $filter_mode          "
            
            # Options that are optional and will only be used if set for the
            # add session call.
            set optional_add_config [list max_response_control \
                    max_response_time]
            
            foreach optional_param $optional_add_config {
                
                if {[info exists $optional_param]} {
                    append mandatory_add_config \
                            " -$optional_param [set $optional_param] "
                }
            }
            
            # Add new session_handle
            set add_status [eval ::ixia::igmp_add_session_handle \
                    $mandatory_add_config]
            
            if {[keylget add_status status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName :\
                        [keylget add_status log]."
                return $returnList
            }
            
        }
        # Set configuration on port
        if {[igmpVxServer set]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName :\
                    igmpVxServer set failed."
            return $returnList
        }
        if {![info exists no_write]} {
            if {[igmpVxServer write]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName -$mode: Failed\
                        to write IGMP configuration (igmpVxServer)."
                return $returnList
            }
        }
        keylset returnList handle $igmp_host_list
    } elseif {$mode == "modify"}  {
        # Modifies parameters given for a list of hosts
        # the list is grouped by port_handle
        
        # Remove default values 
        removeDefaultOptionVars $opt_args $args
        
        foreach port_i [array names sessions_per_port] {
            set port_list [format_space_port_list $port_i]
            foreach {chassis card port} [lindex $port_list 0] {}
            ::ixia::addPortToWrite $chassis/$card/$port
            
            debug "igmpVxServer select $chassis $card $port"
            if {[igmpVxServer select $chassis $card $port]} {
                keylset returnList log "ERROR in $procName : \
                        igmpVxServer select $chassis $card $port failed."
                keylset returnList status $::FAILURE
                return $returnList
            }
            foreach session_handle $sessions_per_port($port_i) {
                igmpVxServer get
                if {[info exists msg_interval]} {
                    igmpVxServer config -timePeriod $msg_interval
                }
                if {[info exists msg_count_per_interval]} {
                    igmpVxServer config -numGroups $msg_count_per_interval
                }
                # Get host handle from session_handle
                set hostRet [::ixia::igmp_get_host_handle_host $session_handle]
                if {[keylget hostRet status] == 0} {
                    keylset hostRet log "ERROR in $procName : \
                            [keylget hostRet log]"
                    return $hostRet
                }
                set host_handle [keylget hostRet host_handle]
                debug "igmpVxServer getHost $host_handle"
                igmpVxServer getHost $host_handle
                set igmp_version [igmpHost cget -version]
                set temp_control ""
                set temp_time ""
                # Set immediate response if it's the case
                if {![info exists max_response_control]} {
                    set hostRet [::ixia::igmp_get_max_response_control_host \
                            $session_handle ]
                    if {[keylget hostRet status] == 0} {
                        keylset hostRet log "ERROR in $procName : \
                                [keylget hostRet log]"
                        return $hostRet
                    }
                    set temp_control [keylget hostRet max_response_control]
                } else  {
                    set temp_control $max_response_control
                    set retMode [::ixia::igmp_modify_session_handle    \
                            -session_handle       $session_handle      \
                            -max_response_control $max_response_control]
                    if {[keylget retMode status] == 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName :\
                                [keylget retMode log]"
                        return $returnList
                    }
                }
                if {![info exists max_response_time]} {
                    set hostRet [::ixia::igmp_get_max_response_time_host \
                            $session_handle ]
                    if {[keylget hostRet status] == 0} {
                        keylset hostRet log "ERROR in $procName : \
                                [keylget hostRet log]"
                        return $hostRet
                    }
                    set temp_time [keylget hostRet max_response_time]
                } else  {
                    set temp_time $max_response_time
                    set retMode [::ixia::igmp_modify_session_handle    \
                            -session_handle       $session_handle      \
                            -max_response_time    $max_response_time   ]
                    if {[keylget retMode status] == 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName :\
                                [keylget retMode log]"
                        return $returnList
                    }
                }
                
                set temp_switch "${temp_control}SEP${temp_time}"
                switch -regexp $temp_switch {
                    {1SEP0}          { set immediate_response 1 }
                    {1SEP([^0]+).*}  { set immediate_response 0 }
                    {1SEP}           {  }
                    {0SEP(.*)}       { set immediate_response 0 }
                    {SEP}            {  }
                }
                # Configure host
                foreach item [array names igmpHost] {
                    if {![catch {set $item} value] } {
                        if {[lsearch [array names enumList] $value] != -1} {
                            set value $enumList($value)
                        }
                        catch {igmpHost config -$igmpHost($item) $value}
                    }
                }
                # Configure max_pkts_per_group and max_sources_per_group in array
                if {[info exists ::ixia::igmp_attributes_array($session_handle,attr)]} {
                    array set groups_array $::ixia::igmp_attributes_array($session_handle,attr)
                    foreach group_param $groups_options_list {
                        if {[info exists $group_param]} {
                            set groups_array($group_param) [set $group_param]
                        }
                    }
                    set ::ixia::igmp_attributes_array($session_handle,attr) [array get groups_array]
                }
                # Configure in IxTclHal
                if {[info exists ::ixia::igmp_attributes_array($session_handle,group)]} {
                    set group_param_ixos_set {
                        enable_packing          enablePacking
                        max_groups_per_pkts     recordsPerFrame
                        max_sources_per_group   sourcesPerRecord
                    }
                    if {[info exists enable_packing]} {
                        if {$enable_packing == 1} {
                            set enable_packing true
                        } else {
                            set enable_packing false
                        }
                    }
                    foreach groupId $::ixia::igmp_attributes_array($session_handle,group) {
                        if {[igmpHost getGroupRange $groupId] == 0} {
                            foreach {hlt_param ixos_param} $group_param_ixos_set {
                                if {[info exists $hlt_param]} {
                                    igmpGroupRange config -$ixos_param \
                                            $groups_array($hlt_param)
                                    debug "igmpGroupRange config -$ixos_param \
                                            $groups_array($hlt_param)"
                                }
                            }
                        } else {
                                debug "cannot get GroupRange $groupId"
                        }
                        igmpHost setGroupRange $groupId
                    }
                }
                # Set host
                if {[igmpVxServer setHost $host_handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : \
                            Failed to igmpVxServer setHost $host_handle."
                    return $returnList
                }
            }
            # Set configuration on port
            if {[igmpVxServer set]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName :\
                        igmpVxServer set failed."
                return $returnList
            }
            if {![info exists no_write]} {
                if {[igmpVxServer write]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName -$mode: Failed\
                            to write IGMP configuration (igmpVxServer)."
                    return $returnList
                }
            }
        }
        # Modify session array
        if {[info exists filter_mode]} {
            set modifyCode [::ixia::igmp_modify_session_handles \
                    $handle sourceMode $filter_mode]
            if {[keylget modifyCode status] == 0} {
                keylset modifyCode log "ERROR in $procName : \
                        [keylget modifyCode log]"
                return $modifyCode
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
    
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::emulation_igmp_querier_config { args } {
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
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::emulation_igmp_querier_config $args\}]
        
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
        -mode CHOICES create delete modify enable disable
    }
    set opt_args {
        -atm_encapsulation                  CHOICES VccMuxIPV4Routed
                                            CHOICES VccMuxIPV6Routed
                                            CHOICES VccMuxBridgedEthernetFCS
                                            CHOICES VccMuxBridgedEthernetNoFCS
                                            CHOICES LLCRoutedCLIP
                                            CHOICES LLCBridgedEthernetFCS
                                            CHOICES LLCBridgedEthernetNoFCS
        -count                              NUMERIC
                                            DEFAULT 1
        -discard_learned_info               CHOICES 0 1
        -general_query_response_interval    RANGE 1-3174400
        -handle
        -igmp_version                       CHOICES v1 v2 v3
        -interface_handle
        -intf_ip_addr                       IP
        -intf_ip_addr_step                  IP
                                            DEFAULT 0.0.0.1
        -intf_prefix_len                    RANGE   1-32
                                            DEFAULT 24
        -ip_router_alert                    CHOICES 0 1
        -mac_address_init                   MAC
        -mac_address_step                   MAC 
                                            DEFAULT 0000.0000.0001
        -msg_count_per_interval             NUMERIC
        -msg_interval                       NUMERIC
        -neighbor_intf_ip_addr              IP
        -neighbor_intf_ip_addr_step         IP
                                            DEFAULT 0.0.0.0
        -no_write                           FLAG
        -override_existence_check           CHOICES 0 1
                                            DEFAULT 0
        -override_tracking                  CHOICES 0 1
                                            DEFAULT 0
        -port_handle                        REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -reset                              FLAG
        -robustness_variable                RANGE   1-7
        -specific_query_response_interval   RANGE   1-3174400
        -specific_query_transmission_count  RANGE   1-255
        -startup_query_count                RANGE   1-255
        -support_election                   CHOICES 0 1
        -support_older_version_host         CHOICES 0 1
        -support_older_version_querier      CHOICES 0 1
        -vci                                RANGE   0-65535
                                            DEFAULT 10
        -vci_step                           RANGE   0-65535
                                            DEFAULT 1
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
        -vpi_step                           RANGE   0-255
                                            DEFAULT 1
        -query_interval                     RANGE   1-31744
    }
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
    
        set returnList [::ixia::ixnetwork_igmp_querier_config $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: [keylget returnList log]"
        }
        return $returnList
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: emulation_igmp_querier_config\
                is only supported for IxNetwork tcl API. "
        return $returnList
    }
}


proc ::ixia::emulation_igmp_control { args } {
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
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::emulation_igmp_control $args\}]
        
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
        -mode           CHOICES stop start restart join leave
    }
    set opt_args {
        -group_member_handle
        -handle
        -port_handle    REGEXP ^[0-9]+/[0-9]+/[0-9]+$
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_igmp_control $args $man_args \
                $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        return $returnList
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

    ::ixia::parse_dashed_args -args $args -mandatory_args $man_args \
            -optional_args $opt_args
    
    # Validate given parameters
    if {($mode == "stop") || ($mode == "start") || ($mode == "restart")} {
        if {(![info exists port_handle]) && (![info exists handle]) && \
                    (![info exists group_member_handle]) } {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : You must\
                    provide for one of the options -port_handle, -handle,\
                    -group_member_handle."
            return $returnList
        } elseif {[info exists handle]}  {
            set port_list ""
            foreach session_handle $handle {
                # Get port_handle
                set portRet [::ixia::igmp_get_port_handle_host $session_handle]
                if {[keylget portRet status] == 0} {
                    keylset portRet log "ERROR in $procName : \
                            [keylget portRet log]"
                    return $portRet
                }
                set port_handle [keylget portRet port_handle]
                lappend port_list $port_handle
            }
            set port_list [format_space_port_list $port_list]
        } elseif {[info exists group_member_handle]} {
            set port_list ""
            foreach group_member $group_member_handle {
                # Get session_handle
                set sessionRet [::ixia::igmp_get_session_handle_group \
                        $group_member]
                if {[keylget sessionRet status] == 0} {
                    keylset sessionRet log "ERROR in $procName : \
                            [keylget sessionRet log]"
                    return $sessionRet
                }
                set session_handle [keylget sessionRet session_handle]
                # Get port_handle
                set portRet [::ixia::igmp_get_port_handle_host $session_handle]
                if {[keylget portRet status] == 0} {
                    keylset portRet log "ERROR in $procName : \
                            [keylget portRet log]"
                    return $portRet
                }
                set port_handle [keylget portRet port_handle]
                lappend port_list $port_handle
            }
            set port_list [format_space_port_list $port_list]
            
        } elseif {[info exists port_handle]} {
            set port_list [format_space_port_list $port_handle]
        }

        set retCode [::ixia::writePortListConfig ]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ::ixia::writePortListConfig failed. \
                    [keylget retCode log]"
            return $returnList
        }
    }
    
    # Check if IGMP package has been installed on the port
    if {[info exists port_list]} {
        foreach port_i $port_list {
            foreach {chs_i crd_i prt_i} $port_i {}
            if {[catch {igmpVxServer select $chs_i $crd_i $prt_i } error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The IGMP\
                        protocol has not been installed on port or\
                        is not supported on port: \
                        $chs_i/$crd_i/$prt_i."
                return $returnList
            }
        }
    }
    
    switch -exact $mode {
        restart {
            if {[ixStopIgmp port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : Error stopping\
                        IGMP on the port list $port_list."
                return $returnList
            }
            if {[ixStartIgmp port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : Error starting\
                        IGMP on the port list $port_list."
                return $returnList
            }
        }
        start {
            if {[ixStartIgmp port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : Error starting\
                        IGMP on the port list $port_list."
                return $returnList
            }
        }
        stop {
            if {[ixStopIgmp port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : Error stopping\
                        IGMP on the port list $port_list."
                return $returnList
            }
        }
        join  {
            if {[info exists handle]} {
                set modifyCode [::ixia::igmp_modify_session_handles \
                        $handle enable true write]
                if {[keylget modifyCode status] == 0} {
                    keylset modifyCode log "ERROR in $procName :    \
                            [keylget modifyCode log]"
                    return $modifyCode
                }
            } elseif {[info exists group_member_handle]}  {
                set modifyCode [::ixia::igmp_modify_group_members   \
                        $group_member_handle enable true write]
                if {[keylget modifyCode status] == 0} {
                    keylset modifyCode log "ERROR in $procName :    \
                            [keylget modifyCode log]"
                    return $modifyCode
                }
            } else  {
                set allSessions [array names ::ixia::igmp_host_handles_array]
                set modifyCode [::ixia::igmp_modify_session_handles \
                        $allSessions enable true write]
                if {[keylget modifyCode status] == 0} {
                    keylset modifyCode log "ERROR in $procName :    \
                            [keylget modifyCode log]"
                    return $modifyCode
                }
            }
        }
        leave {
            if {[info exists handle]} {
                set modifyCode [::ixia::igmp_modify_session_handles \
                        $handle enable false write]
                if {[keylget modifyCode status] == 0} {
                    keylset modifyCode log "ERROR in $procName :    \
                            [keylget modifyCode log]"
                    return $modifyCode
                }
            } elseif {[info exists group_member_handle]}  {
                set modifyCode [::ixia::igmp_modify_group_members   \
                        $group_member_handle enable false write]
                if {[keylget modifyCode status] == 0} {
                    keylset modifyCode log "ERROR in $procName :    \
                            [keylget modifyCode log]"
                    return $modifyCode
                }
            } else  {
                set allSessions [array names ::ixia::igmp_host_handles_array]
                set modifyCode [::ixia::igmp_modify_session_handles \
                        $allSessions enable false write]
                if {[keylget modifyCode status] == 0} {
                    keylset modifyCode log "ERROR in $procName :    \
                            [keylget modifyCode log]"
                    return $modifyCode
                }
            }
        }
        default {
        }
    }

    # Need to call the write, because the join and leave need written,
    # otherwise this will have no effect as the port list will be empty.
    set retCode [::ixia::writePortListConfig ]
    if {[keylget retCode status] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Call to\
                ::ixia::writePortListConfig failed. [keylget retCode log]"
        return $returnList
    }

    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::emulation_igmp_group_config { args } {
    variable executeOnTclServer
    variable new_ixnetwork_api
    variable igmp_port
    
    set procName [lindex [info level [info level]] 0]
    
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::emulation_igmp_group_config $args\}]
        
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
        -mode            CHOICES create delete modify clear_all enable disable
    }
    set opt_args {
        -g_enable_packing        CHOICES  0 1
        -g_filter_mode           CHOICES  include exclude
        -g_max_groups_per_pkts   NUMERIC
        -g_max_sources_per_group RANGE    0-1500
        -group_pool_handle
        -handle
        -no_write                FLAG
        -reset                   FLAG
        -session_handle
        -source_pool_handle
    }
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_igmp_group_config $args $man_args \
                $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        return $returnList
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args
    # Verify conditions for getting started
    # For create and clear_all we need -session_handle argument
    if {$mode == "create" || ($mode == "clear_all")} {
        if {![info exists session_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : If -mode is\
                    $mode you must provide one argument for\
                    -session_handle"
            return $returnList
        } elseif {[llength $session_handle] > 1}  {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : When -mode is $mode,\
                    -session_handle may only contain one value."
            return $returnList
            
        }
    }
    # For create you also need a -group_pool_handle argument
    if {$mode == "create"} {
        if {![info exists group_pool_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : If -mode is\
                    $mode you must provide one argument for\
                    -group_pool_handle."
            return $returnList
        } elseif {[llength $group_pool_handle] > 1} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : If -mode is\
                    $mode -group_pool_handle may only contain\
                    one value."
            return $returnList
        }
    }
    # For delete we need a -handle argument
    if {$mode == "delete"} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : When -mode is $mode,\
                    you must provide one argument for -handle."
            return $returnList
        }
        
    }
    # For modify you also need a -handle and
    # a -group_pool_handle single argument or a -source_pool_handle
    
    if {$mode == "modify"} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : When -mode is $mode,\
                    you must provide one argument for -handle."
            return $returnList
        } elseif {[llength $handle] > 1} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : When -mode is $mode,\
                    -handle may only contain one value."
            return $returnList
        }
        if {(![info exists group_pool_handle]) && \
                    (![info exists source_pool_handle])} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : If -mode is\
                    $mode you must provide one argument for\
                    -group_pool_handle or -source_pool_handle"
            return $returnList
        } elseif {[info exists group_pool_handle]} {
            if {[llength $group_pool_handle] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : If -mode is\
                        $mode -group_pool_handle may only contain\
                        one value."
                return $returnList
            }
        }
    }
    
    if {$mode == "create"} {
        set cmd "::ixia::igmp_create_group -session_handle $session_handle"
        if {[info exists group_pool_handle]} {
            set cmd [concat $cmd " -group_pool_handle $group_pool_handle"]
        }
        if {[info exists source_pool_handle]} {
            set cmd [concat $cmd " -source_pool_handle $source_pool_handle"]
        }
        if {[info exists reset]} {
            set cmd [concat $cmd " -reset" ]
        }
        set returnList [eval $cmd]
        if {[keylget returnList status] == 0} {
            keylset returnList log "ERROR in $procName : \
                    [keylget returnList log]"
        }
    }
    if {$mode == "delete"} {
        set returnList [::ixia::igmp_delete_group $handle]
        if {[keylget returnList status] == 0} {
            keylset returnList log "ERROR in $procName : \
                    [keylget returnList log]"
        }
    }
    if {$mode == "clear_all"} {
        set returnList [::ixia::igmp_clear_all_groups $session_handle]
        if {[keylget returnList status] == 0} {
            keylset returnList log "ERROR in $procName : \
                    [keylget returnList log]"
        }
    }
    if {$mode == "modify"} {
        set cmd "::ixia::igmp_modify_group -handle $handle"
        if {[info exists group_pool_handle]} {
            set cmd [concat $cmd " -group_pool_handle $group_pool_handle"]
        }
        if {[info exists source_pool_handle]} {
            set cmd [concat $cmd " -source_pool_handle $source_pool_handle"]
        }
        set returnList [eval $cmd]
        if {[keylget returnList status] == 0} {
            keylset returnList log "ERROR in $procName : \
                    [keylget returnList log]"
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


proc ::ixia::emulation_igmp_info { args } {
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
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::emulation_igmp_info $args\}]
        
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
    # igmp_over_ppp and igmp are kept for backward compatibility they were
    #     deprecated and they refering to host option in the previous release
    #     (the same behaiviour will apply, but we removed them from docs) 
    #     Also a warning that the parameter is deprecated will be shown
    #     in ::ixia::ixnetwork_igmp_info parse_dashed_args
    set opt_args {
        -handle         REGEXP  ^::ixNet::OBJ-/vport:[0-9]+/protocols/igmp/querier:[0-9]+$
        -mode           CHOICES aggregate learned_info clear_stats
                        DEFAULT aggregate
        -port_handle    REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -timeout        NUMERIC
        -type           CHOICES igmp_over_ppp igmp host querier both
                        DEFAULT host
    }
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_igmp_info $args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        return $returnList
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                IxAccess api is not supported"
        return $returnList
    }
}
