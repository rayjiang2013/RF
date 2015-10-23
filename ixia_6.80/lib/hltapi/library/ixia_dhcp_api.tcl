##Library Header
# $Id: $
# Copyright © 2003-2009 by IXIA
# All Rights Reserved
#
# Name:
#    ixia_dhcp_api.tcl
#
# Purpose:
#    A script development library containing DHCP APIs for test automation with 
#    the Ixia chassis.
#
# Author:
#    Ixia engineering; direct all communication to support@ixiacom.com
#
# Usage:
#
# Description:
#    The procedures contained within this library include:
#
#    -emulation_dhcp_config 
#    -emulation_dhcp_group_config 
#    -emulation_dhcp_control 
#    -emulation_dhcp_stats
#
# Requirements:
#    ixiaapiutils.tcl, a library containing TCL utilities 
#    parseddashedargs.tcl, a library containing the procDescr
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
# meet the user’s requirements or (ii) that the script will be without         #
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


proc ::ixia::emulation_dhcp_config { args } {

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
                \{::ixia::emulation_dhcp_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    variable dhcp_handles_array
	
    ::ixia::utrackerLog $procName $args
    
    set man_args {
        -mode                        CHOICES create modify reset
                                     DEFAULT create
    }
    
    set opt_args {        
        -accept_partial_config          CHOICES 0 1
                                        DEFAULT 0
        -handle                         ANY
        -lease_time                     RANGE 0-2147483647
                                        DEFAULT 3600
        -max_dhcp_msg_size              RANGE 0-65535
                                        DEFAULT 576
        -mode                           CHOICES create modify reset
                                        DEFAULT create
        -msg_timeout                    NUMERIC
                                        DEFAULT 4
        -outstanding_releases_count     RANGE 1-100000
                                        DEFAULT 500
        -outstanding_session_count      NUMERIC
                                        DEFAULT 50
        -port_handle                    REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -release_rate                   RANGE 1-100000
                                        DEFAULT 50
        -release_rate_increment         RANGE 0-100000
                                        DEFAULT 50
        -request_rate                   RANGE 1-100000
                                        DEFAULT 10
        -request_rate_increment         RANGE 0-100000
                                        DEFAULT 50
        -retry_count                    RANGE 1-100
                                        DEFAULT 3
        -server_port                    RANGE 0-65535
                                        DEFAULT 67
        -wait_for_completion            CHOICES 0 1
                                        DEFAULT 0
        -associates                     ANY
        -dhcp6_echo_ia_info             CHOICES 0 1
                                        DEFAULT 0
        -dhcp6_reb_max_rt               RANGE 1-10000
                                        DEFAULT 600
        -dhcp6_reb_timeout              RANGE 1-100
                                        DEFAULT 10
        -dhcp6_rel_max_rc               RANGE 1-100
                                        DEFAULT 5
        -dhcp6_rel_timeout              RANGE 1-100
                                        DEFAULT 1
        -dhcp6_ren_max_rt               RANGE 1-10000
                                        DEFAULT 600
        -dhcp6_ren_timeout              RANGE 1-100
                                        DEFAULT 10
        -dhcp6_req_max_rc               RANGE 1-100
                                        DEFAULT 5
        -dhcp6_req_max_rt               RANGE 1-10000
                                        DEFAULT 30
        -dhcp6_req_timeout              RANGE 1-100
                                        DEFAULT 1
        -dhcp6_sol_max_rc               RANGE 1-100
                                        DEFAULT 3
        -dhcp6_sol_max_rt               RANGE 1-10000
                                        DEFAULT 120
        -dhcp6_sol_timeout              RANGE 1-100
                                        DEFAULT 1
        -msg_timeout_factor             RANGE 1-100
                                        DEFAULT 2
        -no_write                       FLAG
        -override_global_setup_rate     CHOICES 0 1
                                        DEFAULT 1
        -override_global_teardown_rate  CHOICES 0 1
                                        DEFAULT 1
        -release_rate_max               RANGE 1-100000
                                        DEFAULT 500
        -request_rate_max               RANGE 1-100000
                                        DEFAULT 50
        -reset                          FLAG
        -version                        CHOICES ixtclhal ixaccess ixnetwork
                                        DEFAULT ixtclhal
    }

    if [catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} errorMsg] {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg."
        return $returnList
    }

    # Check $port_handle count
    
    if {[info exists port_handle] && 1 != [llength $port_handle]} {\
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Please provide a single port handle"
        return $returnList
    }

    # Check for ixAccess|IxTclHal|IxNetwork version
    if {$version == "ixaccess"} {    
        if {[catch {package present IxTclAccess} versionIxTclAccess] || \
                    ($versionIxTclAccess < 2.20)} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: DHCP cannot\
                    be configured on this IxAccess version."
            return $returnList
        }
    } elseif {$version == "ixtclhal"} {
        if {[catch {package present IxTclHal} versionIxTclHal] || \
                ($versionIxTclHal < 4.00)} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: DHCP cannot\
                    be configured on this IxOS version."
            return $returnList
        }
    } else {
        if {[catch {package present IxTclNetwork} versionIxNetwork] || \
                ($versionIxNetwork < 5.30)} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: IxNetwork version not supported. \
                Please upgrade."
            return $returnList
        }
        return [::ixia::ixnetwork_dhcp_config $args $opt_args $man_args]        
    }
    
    
    # When mode is modify/reset check if handle is present
    if {$mode == "modify"} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the -mode is\
                    $mode, a -handle is required.  Please supply this value."
            return $returnList
        }
    }

    # here we decide if we use ixaccess or ixtclhal, depending on -version value
    if {$version == "ixaccess"} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                IxAccess API is not supported"
        return $returnList
    }

    if {($mode == "create")} {
        # When mode is create check if port_handle is present        
        if {![info exists port_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the -mode is\
                    $mode, a -port_handle is required.  Please supply\
                    this value."
            return $returnList
        }
        
        set port_list [format_space_port_list $port_handle]
        set interface [lindex $port_list 0]        
        foreach {chassis card port} $interface {}
        ::ixia::addPortToWrite $chassis/$card/$port 
        
        if {![port isValidFeature $chassis $card $port \
                    portFeatureProtocolDHCP]} {
            
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: This card does not\
                    support DHCP protocol."
            return $returnList
        }
        
        if {[info exists reset]} {
            # Reset the hardware and the dhcp_handles_array for that port
            set retCode [::ixia::resetDhcpHandleArray reset $port_handle ""]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to\
                        ::ixia::resetDhcpHandleArray reset $port_handle."
                return $returnList
            }            
        }

        set param_value_list [list      \
                lease_time         8640 \
                max_dhcp_msg_size  576  ]
                
        foreach {param value} $param_value_list {
            if {![info exists $param]} {
                set $param $value
            }
        }
        
        set dhcpValue ""
        keylset dhcpValue port_handle       $port_handle
        keylset dhcpValue lease_time        $lease_time
        keylset dhcpValue max_dhcp_msg_size $max_dhcp_msg_size

        set retCode [::ixia::dhcpGetNextHandle dhcpSession session]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to\
                    ::ixia::dhcpGetNextHandle dhcpSession session."
            return $returnList
        }
        set nextHandle [keylget retCode next_handle]
        set dhcp_handles_array($nextHandle,session) $dhcpValue  
        keylset returnList handle $nextHandle
    }                                 

    if {($mode == "modify")} {
        # Check if the session handle is present in dhcp_handles_array
        if {! [info exists dhcp_handles_array($handle,session)]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: The provided session\
                    handle does not exist in dhcp_handles_array."
            return $returnList
        }
        
        set port_handle [keylget dhcp_handles_array($handle,session) \
                port_handle]
        
        set port_list [format_space_port_list $port_handle]        
        set interface [lindex $port_list 0]        
        foreach {chassis card port} $interface {}
        ::ixia::addPortToWrite $chassis/$card/$port
        
        if {![port isValidFeature $chassis $card $port \
                    portFeatureProtocolDHCP]} {
            
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: This card does not\
                    support DHCP protocol."
            return $returnList
        }
        
        set dhcpValue $dhcp_handles_array($handle,session)
        if {[info exists lease_time]} {
            keylset dhcpValue lease_time        $lease_time
        }
        if {[info exists max_dhcp_msg_size]} {
            keylset dhcpValue max_dhcp_msg_size $max_dhcp_msg_size
        }
        set dhcp_handles_array($handle,session) $dhcpValue
        
        # Change all the groups of that session
        foreach groupIndex [array names dhcp_handles_array *,group] {
            if {[keylget dhcp_handles_array($groupIndex) session] == $handle} {
                set retCode [::ixia::emulation_dhcp_group_config \
                        -mode modify $no_write]
                
                if {[keylget retCode status] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to\
                            ::ixia::emulation_dhcp_group_config."
                    return $returnList
                }
            }
        }  

        keylset returnList handle $handle 
    }
    
    if {$mode == "reset"} {
        # Check if protocol is supported
        foreach {chassis card port} [split $port_handle /] {}
        if {![port isValidFeature $chassis $card $port \
                    portFeatureProtocolDHCP]} {
            
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: This card does not\
                    support DHCP protocol."
            return $returnList
        }
        
        # Reset the dhcp_handles_array for that port
        set retCode [::ixia::resetDhcpHandleArray "" $port_handle ""]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to\
                    ::ixia::resetDhcpHandleArray $port_handle."
            return $returnList
        }

        if {![info exists no_write]} {
            if {[interfaceTable write]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failure on call to\
                        interfaceTable write."
                return $returnList
            }
        }

        set handle_list [list]
        foreach sessionIndex [array names dhcp_handles_array *,session] {
            set index1 [mpexpr [string length $sessionIndex] - 1]
            set strNew1 [string replace $sessionIndex [mpexpr $index1 - 7] $index1]
            if {[keylget dhcp_handles_array($strNew1,session) port_handle] == $port_handle } {
                lappend handle_list $strNew1
            }
        }
        keylset returnList handle $handle_list
    }
    
    stat config -enableDhcpStats true
    
    if {[stat set $chassis $card $port]} { 
        keylset returnList status $::FAILURE
        keylset returnList log "Failure on call to stat set \
                $chassis $card $port."
        return $returnList
    }
    
    if {![info exists no_write]} {
        if {[stat write $chassis $card $port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure on call to stat write \
                    $chassis $card $port."
            return $returnList
        }
        
        set retCode [::ixia::writePortListConfig]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ::ixia::writePortListConfig failed. [keylget retCode log]"
            return $returnList
        }
    }
    
    keylset returnList status $::SUCCESS       
    return $returnList
}


proc ::ixia::emulation_dhcp_group_config { args } {
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
                \{::ixia::emulation_dhcp_group_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    variable dhcp_handles_array
    
    ::ixia::utrackerLog $procName $args
    
    set man_args {
        -mode                                          CHOICES create modify reset
                                                       DEFAULT create
        -handle                                        ANY    
    }
    
    set opt_args {
        -encap                                         CHOICES ethernet_ii ethernet_ii_vlan ethernet_ii_qinq 
                                                       CHOICES vc_mux_ipv4_routed vc_mux_fcs vc_mux vc_mux_ipv6_routed llcsnap_routed llcsnap_fcs llcsnap llcsnap_ppp vc_mux_ppp 
        -mac_addr                                      MAC
        -mac_addr_step                                 MAC
                                                       DEFAULT 00.00.00.00.00.01
        -num_sessions                                  RANGE 1-65536
        -pvc_incr_mode                                 CHOICES vci vpi pvc
                                                       DEFAULT vci
        -qinq_incr_mode                                CHOICES inner outer both 
                                                       DEFAULT inner
        -sessions_per_vc                               RANGE 1-65535
                                                       DEFAULT 1
        -vci                                           RANGE 0-65535
        -vci_count                                     RANGE 0-65535
        -vci_step                                      NUMERIC
        -vlan_id                                       RANGE 0-4095
                                                       DEFAULT 4094
        -vlan_id_count                                 RANGE 0-4095
                                                       DEFAULT 4094
        -vlan_id_outer                                 NUMERIC
        -vlan_id_outer_count                           RANGE 1-4094
        -vlan_id_outer_step                            RANGE 1-4094
        -vlan_id_step                                  RANGE 0-4095
        -vpi                                           RANGE 0-255
        -vpi_count                                     RANGE 0-255
        -vpi_step                                      NUMERIC
        -dhcp6_range_duid_enterprise_id                NUMERIC
                                                       DEFAULT 10
        -dhcp6_range_duid_type                         CHOICES duid_llt duid_en duid_ll
                                                       DEFAULT duid_llt
        -dhcp6_range_duid_vendor_id                    NUMERIC
                                                       DEFAULT 10
        -dhcp6_range_duid_vendor_id_increment          NUMERIC
                                                       DEFAULT 1
        -dhcp6_range_ia_id                             NUMERIC
                                                       DEFAULT 10
        -dhcp6_range_ia_id_increment                   NUMERIC
                                                       DEFAULT 1
        -dhcp6_range_ia_t1                             NUMERIC
                                                       DEFAULT 302400
        -dhcp6_range_ia_t2                             NUMERIC
                                                       DEFAULT 483840
        -dhcp6_range_ia_type                           CHOICES iana iata iapd iana_iapd
                                                       DEFAULT iana
        -dhcp6_range_param_request_list                RANGE 2-24
        -dhcp_range_ip_type                            CHOICES ipv4 ipv6
                                                       DEFAULT ipv4
        -dhcp_range_param_request_list                 RANGE 1-90
        -dhcp_range_relay6_hosts_per_opt_interface_id  RANGE 1-100
                                                       DEFAULT 1
        -dhcp_range_relay6_opt_interface_id            ANY
                                                       DEFAULT "id-\[001-900\]"
        -dhcp_range_relay6_use_opt_interface_id        CHOICES 0 1
                                                       DEFAULT 0
        -dhcp_range_relay_address_increment            IP
                                                       DEFAULT 0.0.0.1
        -dhcp_range_relay_circuit_id                   ANY
                                                       DEFAULT CIRCUITID-p
        -dhcp_range_relay_count                        RANGE 1-1000000
                                                       DEFAULT 1
        -dhcp_range_relay_destination                  IP
                                                       DEFAULT 20.0.0.1
        -dhcp_range_relay_first_address                IP
                                                       DEFAULT 20.0.0.100
        -dhcp_range_relay_first_vlan_id                RANGE 1-4094
                                                       DEFAULT 1
        -dhcp_range_relay_gateway                      IP
                                                       DEFAULT 20.0.0.1
        -dhcp_range_relay_hosts_per_circuit_id         RANGE 1-100
                                                       DEFAULT 1
        -dhcp_range_relay_hosts_per_remote_id          RANGE 1-100
                                                       DEFAULT 1
        -dhcp_range_relay_override_vlan_settings       CHOICES 0 1
                                                       DEFAULT 0
        -dhcp_range_relay_remote_id                    ANY
                                                       DEFAULT REMOTEID-I
        -dhcp_range_relay_subnet                       RANGE 1-128
                                                       DEFAULT 24
        -dhcp_range_relay_use_circuit_id               CHOICES 0 1
                                                       DEFAULT 0
        -dhcp_range_relay_use_remote_id                CHOICES 0 1
                                                       DEFAULT 0
        -dhcp_range_relay_use_suboption6               CHOICES 0 1
                                                       DEFAULT 0
        -dhcp_range_relay_vlan_count                   RANGE 1-4094
                                                       DEFAULT 1
        -dhcp_range_relay_vlan_increment               RANGE 0-4093
                                                       DEFAULT 1
        -dhcp_range_renew_timer                        NUMERIC
                                                       DEFAULT 0
        -dhcp_range_server_address                     IP
                                                       DEFAULT 10.0.0.1
        -dhcp_range_suboption6_address_subnet          RANGE 1-32
                                                       DEFAULT 24
        -dhcp_range_suboption6_first_address           IP
                                                       DEFAULT 20.1.1.100
        -dhcp_range_use_first_server                   CHOICES 0 1
                                                       DEFAULT 1
        -dhcp_range_use_relay_agent                    CHOICES 0 1
                                                       DEFAULT 0
        -dhcp_range_use_trusted_network_element        CHOICES 0 1
                                                       DEFAULT 0
        -mac_mtu                                       RANGE 500-9500
                                                       DEFAULT 1500
        -no_write                                      FLAG
        -server_id                                     IP
        -target_subport                                RANGE 0-3
                                                       DEFAULT 0
        -use_vendor_id                                 CHOICES 0 1
                                                       DEFAULT 0
        -vendor_id                                     ANY
                                                       DEFAULT Ixia
        -version                                       CHOICES ixtclhal ixaccess ixnetwork
                                                       DEFAULT ixtclhal
        -vlan_id_outer_increment_step                  RANGE 0-4093
        -vlan_id_increment_step                        RANGE 0-4093
        -vlan_id_outer_priority                        RANGE 0-7
                                                       DEFAULT 0
        -vlan_user_priority                            RANGE 0-7
                                                       DEFAULT 0
    }

    if [catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} errorMsg] {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg."
        return $returnList
    }
    if {![info exists encap]} {
        set encap ethernet_ii
    }
    if {[info exists mac_addr_step]} {
        if {$version == "ixaccess"} {
            if {[regexp -- {\d+\.\d+} $mac_addr_step] != 0} {
                set mac_addr_step [mac2num $mac_addr_step]
            }
        } else {
            if {[regexp -- {^\d+$} $mac_addr_step] != 0} {
                set mac_addr_step [num2mac $mac_addr_step]
            }
        }
    }
    # Check for ixAccess|IxTclHal version
    if {$version == "ixaccess"} {
        if {[catch {package present IxTclAccess} versionIxTclAccess] || \
                    ($versionIxTclAccess < 2.20)} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: DHCP cannot\
                    be configured on this IxAccess version."
            return $returnList
        }
        set encapList [list vc_mux llcsnap]
        if {[info exists encap] && ([lsearch $encapList $encap] == 0)} {
           keylset returnList status $::FAILURE
           keylset returnList log "ERROR in $procName: This encap ($encap)\
                   is not available when using ixaccess version."
           return $returnList
        }

        set returnList [::ixia::ixa_dhcp_group_config $args]
        return $returnList
    } elseif {$version == "ixtclhal"} {
        if {[catch {package present IxTclHal} versionIxTclHal] || \
                ($versionIxTclHal < 4.00)} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: DHCP cannot\
                    be configured on this IxOS version."
            return $returnList
        }
        set encapList [list ethernet_ii ethernet_ii_vlan vc_mux llcsnap]
        if {[info exists encap] && [lsearch $encapList $encap] < 0} {
           keylset returnList status $::FAILURE
           keylset returnList log "ERROR in $procName: This encap\
                   is not available when using ixtclhal version."
           return $returnList
        }
    } else {
        # ixnetwork implementez-moi
        if {[catch {package present IxTclNetwork} versionIxNetwork] || \
                ($versionIxNetwork < 5.30)} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: IxNetwork version not supported.\
                Please upgrade."
            return $returnList
        }
        return [::ixia::ixnetwork_dhcp_group_config $args $opt_args $man_args]        
    }

    # List of all params
    set dhcpParamList [list   \
            mode              \
            num_sessions      \
            handle            \
            encap             \
            vlan_id           \
            vlan_id_step      \
            vlan_id_count     \
            vci               \
            vpi               \
            vci_count         \
            vci_step          \
            vpi_count         \
            vpi_step          \
            sessions_per_vc   \
            pvc_incr_mode     \
            mac_addr          \
            mac_addr_step     \
            vlan_priority     \
            vendor_id         \
            server_id         \
            lease_time        \
            max_dhcp_msg_size ]
    
    if {[info exists mac_addr_step]} {
        regsub -all {\.} $mac_addr_step {:} temp_mac
        if {[isMacAddressValid $temp_mac]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: The provided mac_addr_step\
                    is not a mac address."
            return $returnList
        }
    }

    # CREATEs a new group range
    if {$mode == "create"} {   
        
        # Default values
        set param_value_list [list         \
                num_sessions       4096    \
                vlan_id_step       1       \
                vlan_id_count      1       \
                vci_count          1       \
                vci_step           1       \
                vpi_count          1       \
                vpi_step           1       \
                sessions_per_vc    1       \
                pvc_incr_mode      vci     \
                vlan_priority      0       \
                server_id          0.0.0.0 \
                vendor_id          Ixia    ]
        
        foreach {param value} $param_value_list {
            if {![info exists $param]} {
                set $param $value
            }
        }
        
        # Check if the session handle is present in dhcp_handles_array
        if {! [info exists dhcp_handles_array($handle,session)]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: The provided session\
                    handle does not exist in dhcp_handles_array."
            return $returnList
        }        
        
        # Check if encapsulation is present    
        if {![info exists encap]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the -mode is\
                    $mode, a -encap is required.  Please supply this value."
            return $returnList
        }
        
        set retCode [::ixia::dhcpGetNextHandle dhcpGroup group]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to\
                    ::ixia::dhcpGetNextHandle dhcpGroup group."
            return $returnList
        }
        
        set group_handle [keylget retCode next_handle] 
        
        set lease_time [keylget dhcp_handles_array($handle,session) lease_time]
        set max_dhcp_msg_size \
                [keylget dhcp_handles_array($handle,session) max_dhcp_msg_size]
    
        set config_param ""
        foreach value $dhcpParamList {
            if {[info exists $value]} {
                append config_param " -$value [set $value] "
            }
        }
        append config_param " -group_handle $group_handle "

        set retCode [eval ::ixia::dhcpCreateInterfaces $config_param]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ::ixia::dhcpCreateInterfaces failed. [keylget retCode log]"
            return $returnList
        }
        
        keylset returnList interface_handle [keylget dhcp_handles_array($group_handle,group) interface_handle]
        keylset returnList handle           $group_handle
        keylset returnList port_handle      $handle
    }
    
    # MODIFIes an existing group range
    if {$mode == "modify"} {
        
        # Check if the group handle is present in dhcp_handles_array
        if {! [info exists dhcp_handles_array($handle,group)]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: The provided group\
                    handle does not exist in dhcp_handles_array."
            return $returnList
        }
        
        set session_handle [keylget dhcp_handles_array($handle,group) session]
        set port_handle \
                [keylget dhcp_handles_array($session_handle,session) port_handle]
        
        set lease_time [keylget dhcp_handles_array($session_handle,session) \
                lease_time]
        set max_dhcp_msg_size \
                [keylget dhcp_handles_array($session_handle,session) \
                 max_dhcp_msg_size]
        
        # List of new params
        set dhcpValue $dhcp_handles_array($handle,group)
        foreach dhcpParam $dhcpParamList {
            if {(![info exists $dhcpParam]) && \
                        (![catch {keylget dhcpValue $dhcpParam} \
                        dhcpParamValue])} {
                set $dhcpParam  $dhcpParamValue
            }
        }
        if {[info exists mac_addr]} {
            regsub -all { } $mac_addr {.} mac_addr
        }
        if {[info exists mac_addr_step]} {
            regsub -all { } $mac_addr_step {.} mac_addr_step
        }
        
        set config_param ""
        foreach value $dhcpParamList {
            if {[info exists $value]} {                
                append config_param " -$value [set $value] "
            }
        }        
        
        set retCode [eval ::ixia::dhcpCreateInterfaces $config_param]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to\
                    ::ixia::dhcpCreateInterfaces. [keylget retCode log]"
            return $returnList
        }   
    }
    
    # RESETs the emulation locally
    if {$mode == "reset"} {
        # Reset the dhcp_handles_array for that session
        set retCode [::ixia::resetDhcpHandleArray "" "" $handle]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to\
                    ::ixia::resetDhcpHandleArray $handle."
            return $returnList
        }
    }

    if {![info exists no_write]} {
        set retCode [::ixia::writePortListConfig]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ::ixia::writePortListConfig failed. [keylget retCode log]"
            return $returnList
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::emulation_dhcp_control { args } {
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
                \{::ixia::emulation_dhcp_control $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    variable dhcp_handles_array
    
    ::ixia::utrackerLog $procName $args
    
    set man_args {
        -action        CHOICES abort abort_async bind release renew
                       DEFAULT bind
    }
    
    set opt_args {
        -port_handle   ANY
        -handle        ANY
        -no_write      FLAG
        -request_rate  RANGE 0-4294967295
                       DEFAULT 100    
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

    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg"
        return $returnList
    }
    
    # Check for ixnetwork request
    if {$::ixia::new_ixnetwork_api == 0 && $::ixia::no_more_tclhal == 0} {
        #
    } elseif {[catch {package present IxTclNetwork} versionIxNetwork]} {
        #
    } elseif {($versionIxNetwork < 5.30)} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: IxNetwork version not supported.\
                Please upgrade."
        return $returnList
    } else {
        return [::ixia::ixnetwork_dhcp_group_control $args $opt_args $man_args]
    }
    
    # Check for IxTclHal version
    if {[catch {package present IxTclHal} versionIxTclHal] || \
                ($versionIxTclHal < 4.00)} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: DHCP cannot\
                be configured on this IxOS version."
        return $returnList
    }
    
    # Check for port_handle existence
    if {![info exists port_handle] && ![[info exists handle]]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Parameter -port_handle or parameter -handle\
                must be provided."
        return $returnList
    }
    array set dhcp_control_group_handles_temp_array ""
    if {[info exists port_handle]} {
        foreach groupIndex [array names dhcp_handles_array *,group] {
            set sessionHandle [keylget dhcp_handles_array($groupIndex) session]
            set portHandle    [keylget dhcp_handles_array($sessionHandle,session) port_handle]
            append dhcp_control_group_handles_temp_array($portHandle) \
                    " [keylget dhcp_handles_array($groupIndex) description]"
        }
    } 
    if {[info exists handle]} {
        if {![info exists dhcp_handles_array($handle,group)]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: The provided group handle is invalid.\
                    Please make sure that this handle was provided by emulation_dhcp_group_config."
            return $returnList
        } else {
            set sessionHandle [keylget dhcp_handles_array($handle,group) session]
            set portHandle    [keylget dhcp_handles_array($sessionHandle,session) port_handle]
            set dhcp_control_group_handles_temp_array($portHandle) \
                    [keylget dhcp_handles_array($handle,group) description]
        }
    }
    
    foreach portHandle [array names dhcp_control_group_handles_temp_array] {
        set port_list [format_space_port_list $portHandle]
        set interface [lindex $port_list 0]
        foreach {chassis card port} $interface {}
        ::ixia::addPortToWrite $chassis/$card/$port
        
        if {![port isValidFeature $chassis $card $port portFeatureProtocolDHCP]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: This card does not\
                    support DHCP protocol."
            return $returnList
        }
    
        if {[interfaceTable select $chassis $card $port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure on call to\
                    interfaceTable select $chassis $card $port."
            return $returnList
        }
        
        switch -exact $action {
            bind {
                if {[info exists request_rate]} {
                    debug "interfaceTable config -dhcpV4RequestRate $request_rate"
                    interfaceTable config -dhcpV4RequestRate $request_rate
                }
                # Enable all the interfaces of the specified session/group
                for {set bRes [interfaceTable getFirstInterface]} \
                        {$bRes == 0} {set bRes [interfaceTable getNextInterface]} {
                    set interfaceDescription [interfaceEntry cget -description]
                    # Loop through the interfaces of the given group
                    if {[lsearch $dhcp_control_group_handles_temp_array($portHandle) $interfaceDescription] \
                                != -1} {
                        interfaceEntry config -enable true
                        if {[interfaceTable setInterface $interfaceDescription]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failure on call to\
                                    interfaceTable setInterface \
                                    $interfaceDescription."
                            return $returnList
                        }
                    }
                }
            }
            release {
                # Disable all the interfaces of the specified session/group
                for {set bRes [interfaceTable getFirstInterface]} \
                        {$bRes == 0} {set bRes [interfaceTable getNextInterface]} {
                    set interfaceDescription [interfaceEntry cget -description]
                    # Loop through the interfaces of the given group
                    if {[lsearch $dhcp_control_group_handles_temp_array($portHandle) $interfaceDescription] \
                                != -1} {
                        interfaceEntry config -enable false
                        if {[interfaceTable setInterface $interfaceDescription]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failure on call to\
                                    interfaceTable setInterface \
                                    $interfaceDescription."
                            return $returnList
                        }
                    }
                }
            }
            renew {
                #not supported option
            }
        } ;#end switch
    }
    
    switch -exact $action {
        bind -
        release {
            if {[interfaceTable set]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failure on call to\
                        interfaceTable set."
                        return $returnList
            }
            if {[interfaceTable write]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failure on call to\
                        interfaceTable write."
                        return $returnList
            }
        }
        renew {
            #not supported option
        }
    }
    
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


proc ::ixia::emulation_dhcp_stats { args } {
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
                \{::ixia::emulation_dhcp_stats $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    variable dhcp_handles_array
    
    ::ixia::utrackerLog $procName $args
    
    set opt_args {
        -port_handle  ANY
        -action       CHOICES clear
        -handle       ANY
        -mode         CHOICES session aggregate_stats
        -no_write     FLAG
        -version      CHOICES ixtclhal ixaccess ixnetwork
                      DEFAULT ixtclhal
    }
    
    if [catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args} errorMsg] {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg."
        return $returnList
    }
    
    # Check for ixAccess|IxTclHal version
    if {$version == "ixaccess"} {    
        if {[catch {package present IxTclAccess} versionIxTclAccess] || \
                    ($versionIxTclAccess < 2.20)} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: DHCP cannot\
                    be configured on this IxAccess version."
            return $returnList
        }
        set returnList [::ixia::ixa_dhcp_stats $args]
        return $returnList
    } elseif {$version == "ixtclhal"} {
        if {[catch {package present IxTclHal} versionIxTclHal] || \
                ($versionIxTclHal < 4.00)} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: DHCP cannot\
                    be configured on this IxOS version."
            return $returnList
        }
    } else {
        if {[catch {package present IxTclNetwork} versionIxNetwork] || \
                ($versionIxNetwork < 5.30)} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: IxNetwork version not supported.\
                Please upgrade."
            return $returnList
        }
        return [::ixia::ixnetwork_dhcp_group_stats $args $opt_args]
    }
    
    if {![info exists port_handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: When -version is $version, \
                please provide -port_handle parameter."
        return $returnList
    }
    
    # Check if the session handle is present in dhcp_handles_array
    set session_handle $port_handle
    if {! [info exists dhcp_handles_array($session_handle,session)]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The provided session\
                handle does not exist in dhcp_handles_array."
        return $returnList
    }
    
    # Check if the group handle is present in dhcp_handles_array
    if {[info exists handle]} {
        if {! [info exists dhcp_handles_array($handle,group)]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: The provided group\
                    handle does not exist in dhcp_handles_array."
            return $returnList
        } else {
            set s_handle [keylget dhcp_handles_array($handle,group) session]
            if {$s_handle != $session_handle} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The provided session\
                        handle does not exist in \
                        dhcp_handles_array($handle,group)."
                return $returnList
            }
        }
    }
    
    set portHandle [keylget dhcp_handles_array($session_handle,session) \
            port_handle]
    set port_list [format_space_port_list $portHandle]
    set interface [lindex $port_list 0]
    foreach {chassis card port} $interface {}
    
    if {![port isValidFeature $chassis $card $port \
                portFeatureProtocolDHCP]} {
        
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: This card does not\
                support DHCP protocol."
        return $returnList
    }
    
    debug "interfaceTable select $chassis $card $port"
    if {[interfaceTable select $chassis $card $port]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failure on call to\
                interfaceTable select $chassis $card $port."
        return $returnList
    }    
    
    # Aggregate stats:
    ixPuts "Retrieving DHCP aggregate stats ..."
    set numRetries 100
    while {1} {
        set retCode [interfaceTable requestDiscoveredTable]
        debug "interfaceTable requestDiscoveredTable"
        debug $retCode
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure on call to\
                    interfaceTable requestDiscoveredTable."
            return $returnList
        }
        
        if {[stat get allStats $chassis $card $port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure on call to\
                    stat get allStats $chassis $card $port."
            return $returnList
        }
        if {[stat cget -dhcpV4AddressesLearned] || \
                [stat cget -dhcpV4EnabledInterfaces] || \
                ($numRetries == 0)} {
            break
        }
        incr numRetries -1
        after 10
    }
    
    set currently_attempting [stat cget -dhcpV4EnabledInterfaces]
    set currently_bound      [stat cget -dhcpV4AddressesLearned]
    set currently_idle       [mpexpr $currently_attempting - $currently_bound]
    
    if {$currently_attempting == 0} {
        set success_percentage 0
    } else {
        set success_percentage \
                [mpexpr 1.*$currently_bound/$currently_attempting*100]
    }  
    
    set discover_tx_count    [stat cget -dhcpV4DiscoveredMessagesSent]
    set request_tx_count     [stat cget -dhcpV4RequestsSent]
    set release_tx_count     [stat cget -dhcpV4ReleasesSent]
    set ack_rx_count         [stat cget -dhcpV4AcksReceived]
    set nak_rx_count         [stat cget -dhcpV4NacksReceived]
    set offer_rx_count       [stat cget -dhcpV4OffersReceived]
    
    keylset returnList aggregate.currently_attempting $currently_attempting
    keylset returnList aggregate.currently_bound      $currently_bound
    keylset returnList aggregate.currently_idle       $currently_idle
    keylset returnList aggregate.success_percentage   $success_percentage
    keylset returnList aggregate.discover_tx_count    $discover_tx_count
    keylset returnList aggregate.request_tx_count     $request_tx_count
    keylset returnList aggregate.release_tx_count     $release_tx_count
    keylset returnList aggregate.ack_rx_count         $ack_rx_count
    keylset returnList aggregate.nak_rx_count         $nak_rx_count
    keylset returnList aggregate.offer_rx_count       $offer_rx_count
       
    # Stats per session/group
    if {[info exists handle]} {
        set groupDescription [keylget dhcp_handles_array($handle,group) \
                description]
    }
    array unset a
    array set   a ""
    set enabledCounter 0
    set boundedCounter 0
    
    set retCode [interfaceTable requestDiscoveredTable]
    debug "interfaceTable requestDiscoveredTable"
    debug $retCode
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failure on call to\
                interfaceTable requestDiscoveredTable."
        return $returnList
    }
    
    ixPuts -nonewline "Retrieving DHCP per group stats ..."
    debug "interfaceTable getFirstInterface"
    for {set bRes [interfaceTable getFirstInterface]} \
            {$bRes == 0} {set bRes [interfaceTable getNextInterface]} {
        
        ixPuts -nonewline "."
        debug "interfaceTable getNextInterface"
        debug "$bRes"
        set interfaceDescription "[interfaceEntry cget -description]"
        set isInterfaceEnabled   "[interfaceEntry cget -enable]"
        
        if {![info exists handle]} {
            # Loop through interfaces of all groups of the given session
            foreach var [array names dhcp_handles_array] {
                if {([lindex [split $var ,] 1] == "group") && \
                            ([keylget dhcp_handles_array($var) session] == \
                            $session_handle)} {
                    set groupDesc [keylget dhcp_handles_array($var) \
                            description]
                    if {[lsearch $groupDesc $interfaceDescription] != -1} {
                        
                        set groupId [lindex [split $var ,] 0]

                        if {![info exists a($groupId,bounded)]} {
                            set a($groupId,bounded) 0
                        }

                        if {![info exists a($groupId,enabled)]} {
                            set a($groupId,enabled) 0
                        }

                        set retCode [::ixia::dhcpRequestDiscoveredTable \
                                    $interfaceDescription]
                        if {[keylget retCode status] == $::FAILURE} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Call to\
                                ::ixia::dhcpRequestDiscoveredTable failed.\
                                [keylget retCode log]"
                            return $returnList
                        }
                                                                     
                        if { [keylget retCode discovered] == $::SUCCESS } {                            
                            incr a($groupId,bounded)
                        }

                        if { $isInterfaceEnabled } {                            
                            incr a($groupId,enabled)
                        }
                    }
                }
            }
        } else {
            # Loop through the interfaces of the given group
            if {[lsearch $groupDescription $interfaceDescription] != -1} {
                set retCode [::ixia::dhcpRequestDiscoveredTable $interfaceDescription]
                 
                if {[keylget retCode status] == $::FAILURE} {                 
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Call to\
                        ::ixia::dhcpRequestDiscoveredTable failed.\
                        [keylget retCode log]"
                    return $returnList
                }
                
                if {[keylget retCode discovered] == $::SUCCESS} {                 
                    incr boundedCounter
                }
                
                if { $isInterfaceEnabled } {
                    incr enabledCounter
                }
            }
        }
    }  ;#end for
    ixPuts "\nFinished retrieving dhcp stats ..."
    if {[info exists handle]} {
        keylset returnList group.$handle.currently_attempting $enabledCounter
        keylset returnList group.$handle.currently_bound      $boundedCounter
        keylset returnList group.$handle.currently_idle       \
                [mpexpr $enabledCounter - $boundedCounter]
    } else {
        foreach var [array names a] {
            set groupId [lindex [split $var ,] 0]
            if {[catch {keylget returnList group.$groupId}]} {
                keylset returnList group.$groupId.currently_attempting \
                        $a($groupId,enabled)
                keylset returnList group.$groupId.currently_bound      \
                        $a($groupId,bounded)
                keylset returnList group.$groupId.currently_idle       \
                        [mpexpr $a($groupId,enabled) - $a($groupId,bounded)]
            }            
        }       
    }

    if {[info exists action]} {
        # Reseting all the stats for the selected port
        set portList [list $chassis,$card,$port]
        debug "ixClearStats $portList"
        if {[ixClearStats portList]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure on call to\
                    ixClearStats $portList."
            return $returnList
        }
    }

    if {![info exists no_write]} {
        set retCode [::ixia::writePortListConfig]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ::ixia::writePortListConfig failed. [keylget retCode log]"
            return $returnList
        }
    }

    keylset returnList status $::SUCCESS
    return $returnList
}
