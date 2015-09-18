##Library Header
# $Id: $
# Copyright © 2003-2009 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_mld_api.tcl
#
# Purpose:
#    A script development library containing MLD APIs for test automation with
#    the Ixia chassis.
#
# Author:
#    Ixia engineering, direct all communication to support@ixiacom.com
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures contained within this library include:
#
#    - emulation_mld_config
#    - emulation_mld_group_config
#    - emulation_mld_control
#
# Requirements:
#    ixiaapiutils.tcl , a library containing TCL utilities
#    parseddashedargs.tcl , a library containing the procDescr and
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

proc ::ixia::emulation_mld_config { args } {
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
                \{::ixia::emulation_mld_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    variable mld_host_handles_array
    variable mld_group_handles_array
    variable mld_attributes_array

    ::ixia::utrackerLog $procName $args

    set man_args {
        -mode CHOICES create modify delete disable enable enable_all disable_all
    }

    set opt_args {
        -atm_encapsulation           CHOICES VccMuxIPV4Routed VccMuxIPV6Routed 
                                     CHOICES VccMuxBridgedEthernetFCS 
                                     CHOICES VccMuxBridgedEthernetNoFCS 
                                     CHOICES LLCRoutedCLIP LLCBridgedEthernetFCS
                                     CHOICES LLCBridgedEthernetNoFCS 
                                     DEFAULT LLCBridgedEthernetFCS
        -count                       RANGE   1-4000
                                     DEFAULT 1
        -enable_packing              CHOICES 0 1 
                                     DEFAULT 0
        -filter_mode                 CHOICES include exclude
                                     DEFAULT include
        -general_query               CHOICES 0 1
                                     DEFAULT 1
        -group_query                 CHOICES 0 1
                                     DEFAULT 1
        -handle
        -interface_handle
        -intf_ip_addr                IPV6
        -intf_ip_addr_step           IPV6
                                     DEFAULT 0::1
        -intf_prefix_len             RANGE   1-128 
                                     DEFAULT 64
        -ip_router_alert             CHOICES 0 1
                                     DEFAULT 1
        -mac_address_init            MAC
        -mac_address_step            MAC
                                     DEFAULT 0000.0000.0001
        -max_groups_per_pkts         RANGE   0-1500
                                     DEFAULT 0
        -max_response_control        CHOICES 0 1
                                     DEFAULT 0
        -max_response_time           RANGE 0-999999
        -max_sources_per_group       RANGE   0-1500 
                                     DEFAULT 0
        -mldv2_report_type           CHOICES 143 206
                                     DEFAULT 143
        -mld_version                 CHOICES v1 v2
                                     DEFAULT v2
        -msg_count_per_interval      RANGE   0-999999999 
                                     DEFAULT 0
        -msg_interval                RANGE   0-999999999
                                     DEFAULT 0
        -neighbor_intf_ip_addr       IPV6 
                                     DEFAULT 0::0
        -neighbor_intf_ip_addr_step  IPV6 
                                     DEFAULT 0::0
        -no_write                    FLAG
        -override_existence_check    CHOICES 0 1
                                     DEFAULT 0
        -override_tracking           CHOICES 0 1
                                     DEFAULT 0
        -port_handle                 REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -reset                       FLAG
        -robustness                  RANGE 1-65535
                                     DEFAULT 2
        -suppress_report             CHOICES 0 1
                                     DEFAULT 0
        -unsolicited_report_interval RANGE   0-999999
        -vci                         RANGE 0-65535
                                     DEFAULT 32
        -vci_step                    RANGE 0-65535
                                     DEFAULT 1
        -vlan                        CHOICES 0 1
        -vlan_cfi                    CHOICES 0 1
        -vlan_id                     RANGE   0-4095
        -vlan_id_mode                CHOICES fixed increment 
                                     DEFAULT increment
        -vlan_id_step                RANGE   0-4095
                                     DEFAULT 1
        -vlan_user_priority          RANGE   0-7
                                     DEFAULT 0
        -vpi                         RANGE 0-255
                                     DEFAULT 1
        -vpi_step                    RANGE 0-255
                                     DEFAULT 1
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_mld_config $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        return $returnList
    }

    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args

    variable mld_handles_array
    set mld_host_list ""
    
    array set mldCommandArray [list         \
            mldServer mldServerOptionsArray \
            mldHost   mldHostOptionsArray   ]
    
    array set mldServerOptionsArray [list  \
            timePeriod msg_interval        \
            numGroups  max_groups_per_pkts ]
    
    array set mldHostOptionsArray [list           \
            enableRouterAlert ip_router_alert     \
            enableGeneralQuery general_query      \
            enableGroupSpecific group_query       \
            enableSuppressReports suppress_report ]

    # When mode is delete/enable/disable/modify check if handle is present
    if {($mode == "delete") || ($mode == "enable") || ($mode == "disable") \
            || ($mode == "modify")} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the -mode is\
                    $mode, a -handle is required.  Please supply this value."
            return $returnList
        }
    }

    #When mode is create check if intf_ip_addr is present
    if {$mode == "create"} {
        if {![info exists intf_ip_addr]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the -mode is\
                    $mode, a -intf_ip_addr is required.  Please supply\
                    this value."
            return $returnList
        }
    }
    
    # When mode is create/enable_all/disable_all check if port_handle is present
    if {($mode == "create") || ($mode == "enable_all") \
            || ($mode == "disable_all")} {
        if {![info exists port_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the -mode is\
                    $mode, a -port_handle is required.  Please supply\
                    this value."
            return $returnList
        }
        
        set port_list [format_space_port_list $port_handle]
        set interface [lindex $port_list 0]
        # Set chassis card port
        foreach {chassis card port} $interface {}
        ::ixia::addPortToWrite $chassis/$card/$port
        
        # Check if MLD protocol is supported
        if {![port isValidFeature $chassis $card $port \
                    portFeatureProtocolMLD]} {
            
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : This card does not\
                    support MLD protocol."
            return $returnList
        }
        
        # Check if MLD package has been installed on the port
        if {[catch {mldServer select $chassis $card $port} retCode]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: The MLD protocol\
                    has not been installed on port or is not supported on port: \
                    $chassis/$card/$port."
            return $returnList
        }
        
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to mldServer\
                    select $chassis $card $port failed.  Return code\
                    was $retCode."
            return $returnList
        }
    }
    
    # Enable/disable hosts
    if {($mode == "disable") || ($mode == "enable")} {
        foreach mld_host $handle {
            if {[array names mld_handles_array $mld_host,port] == ""} {
                keylset returnList log "$procName: Cannot find the session\
                        handle $mld_host in the mld_handles_array"
                keylset returnList status $::FAILURE
                return $returnList
            }
            set interface $mld_handles_array($mld_host,port)
            foreach {chassis card port} $interface {}
            ::ixia::addPortToWrite $chassis/$card/$port
            
            # Check if MLD package has been installed on the port
            if {[catch {mldServer select $chassis $card $port} retCode]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The MLD\
                        protocol has not been installed on port or\
                        is not supported on port: \
                        $chassis/$card/$port."
                return $returnList
            }
            
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        mldServer select $chassis $card $port failed. \
                        Return code was $retCode."
                return $returnList
            }
            
            set retCode [mldServer getHost $mld_host]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        mldServer getHost $mld_host failed.  Return code\
                        was $retCode."
                return $returnList
            }
            
            switch -- $mode {
                enable {
                    mldHost config -enable true
                }
                disable {
                    mldHost config -enable false
                }
                default {}
            }
            
            set retCode [mldServer setHost $mld_host]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        mldServer setHost $mld_host failed.  Return code\
                        was $retCode."
                return $returnList
            }
            
            set retCode [mldServer set]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        mldServer set failed.  Return code was $retCode."
                return $returnList
            }
        }

        keylset returnList handle $handle
    }

    # Delete hosts
    if {($mode == "delete")} {
        foreach mld_host $handle {
            if {[array names mld_handles_array $mld_host,port] == ""} {
                keylset returnList log "$procName: Cannot find the session\
                        handle $mld_host in the mld_handles_array"
                keylset returnList status $::FAILURE
                return $returnList
            }
            set interface $mld_handles_array($mld_host,port)
            foreach {chassis card port} $interface {}
            ::ixia::addPortToWrite $chassis/$card/$port
    
            # Check if MLD package has been installed on the port
            if {[catch {mldServer select $chassis $card $port} retCode]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The MLD\
                        protocol has not been installed on port or\
                        is not supported on port: \
                        $chassis/$card/$port."
                return $returnList
            }
            
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        mldServer select $chassis $card $port failed. \
                        Return code was $retCode."
                return $returnList
            }
            
            set retCode [mldServer delHost $mld_host]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        mldServer delHost $mld_host failed.  Return code\
                        was $retCode."
                return $returnList
            }
            updateMldHandleArray -mode delete -handle $mld_host
            
            set retCode [mldServer set]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        mldServer set failed.  Return code was $retCode."
                return $returnList
            }
        }

        keylset returnList handle $handle
    }

    # Enable/disable all hosts on a port
    if {($mode == "enable_all") || ($mode == "disable_all")} {
        
        set do_mld_set 0
        
        set mld_handle_list [list]
        foreach tmp_handle [array names ::ixia::mld_handles_array "*,port"] {
            
            if {[join $mld_handles_array($tmp_handle) /] != $port_handle} {
                continue
            }
            
            set mld_host [string range $tmp_handle 0 end-5]
            lappend mld_handle_list $mld_host
            
            set retCode [mldServer getHost $mld_host]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        mldServer getHost $mld_host failed.  Return code\
                        was $retCode."
                return $returnList
            }
            
            switch -- $mode {
                enable_all {
                    mldHost config -enable true
                }
                disable_all {
                    mldHost config -enable false
                }
                default {}
            }
            
            set retCode [mldServer setHost $mld_host]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        mldServer setHost $mld_host failed.  Return code\
                        was $retCode."
                return $returnList
            }
            
            set do_mld_set 1
        }
        
        if {$do_mld_set} {
            set retCode [mldServer set]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        mldServer set failed.  Return code was $retCode."
                return $returnList
            }
        }
        
        keylset returnList handle $mld_handle_list
    }

    # Modify hosts
    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
        foreach mld_host $handle {
            if {[array names mld_handles_array $mld_host,port] == ""} {
                keylset returnList log "$procName: Cannot find the session\
                        handle $mld_host in the mld_handles_array"
                keylset returnList status $::FAILURE
                return $returnList
            }
            set interface $mld_handles_array($mld_host,port)
            foreach {chassis card port} $interface {}
            ::ixia::addPortToWrite $chassis/$card/$port
            
            # Check if MLD package has been installed on the port
            if {[catch {mldServer select $chassis $card $port} retCode]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The MLD\
                        protocol has not been installed on port or\
                        is not supported on port: \
                        $chassis/$card/$port."
                return $returnList
            }
            
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        mldServer select $chassis $card $port failed. \
                        Return code was $retCode."
                return $returnList
            }
            
            set retCode [mldServer get]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        mldServer get failed.  Return code was $retCode."
                return $returnList
            }

            set retCode [mldServer getHost $mld_host]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        mldServer getHost $mld_host failed.  Return code\
                        was $retCode."
                return $returnList
            }
            
            ::ixia::mldSetHostOptions
            
            set retCode [mldServer setHost $mld_host]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        mldServer setHost $mld_host failed.  Return code\
                        was $retCode."
                return $returnList
            }
            
            set retCode [mldServer set]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        mldServer set failed.  Return code was $retCode."
                return $returnList
            }
            
            # Filter mode changed -> update all groups on host
            if {[info exists filter_mode]} {
                if {$filter_mode == "include"} {
                    set sourceMode "multicastSourceModeInclude"
                } else  {
                    set sourceMode "multicastSourceModeExclude"
                }
                
                set retCode [mldServer getHost $mld_host]
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Call to\
                            mldServer getHost $mld_host failed.  Return\
                            code was $retCode."
                    return $returnList
                }
                
                if {[mldHost getFirstGroupRange] == 0} {
                    mldGroupRange config -sourceMode $sourceMode
                    
                    set retCode [mldHost setGroupRange]
                    if {$retCode} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Call to\
                                mldHost setGroupRange failed.  Return code\
                                was $retCode."
                        return $returnList
                    }
                    
                    set retCode [mldServer set]
                    if {$retCode} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Call to\
                                mldServer set failed.  Return code\
                                was $retCode."
                        return $returnList
                    }
                    
                    while {[mldHost getNextGroupRange] == 0} {
                        mldGroupRange config -sourceMode $sourceMode
                        
                        set retCode [mldHost setGroupRange]
                        if {$retCode} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Call\
                                    to mldHost setGroupRange failed.  Return\
                                    code was $retCode."
                            return $returnList
                        }
                        
                        set retCode [mldServer set]
                        if {$retCode} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Call\
                                    to mldServer set failed.  Return code\
                                    was $retCode."
                            return $returnList
                        }
                    }
                }
            }
        }

        keylset returnList handle $handle
    }
    
    if {$mode != "create"} {
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
    
    # Create from here

    # Reset MLD protocol server if requested
    if {[info exists reset]} {
        mldServer clearAllHosts
        mldServer setDefault
        
        updateMldHandleArray -mode delete -port $interface
    }
       
    set intf_ip_addr               [::ipv6::expandAddress $intf_ip_addr]
    set intf_ip_addr_step          [::ipv6::expandAddress $intf_ip_addr_step]
    set neighbor_intf_ip_addr      [::ipv6::expandAddress \
            $neighbor_intf_ip_addr]
    set neighbor_intf_ip_addr_step [::ipv6::expandAddress \
            $neighbor_intf_ip_addr_step]

    ###################################
    # CONFIGURE THE INTERFACES ON IXIA
    ###################################
    set config_param \
            "-port_handle $port_handle      \
            -count        $count            \
            -ip_address   $intf_ip_addr     \
            -ip_version   6                 "
    
    set config_options \
            "-mac_address         mac_address_init   \
            -netmask              intf_prefix_len    \
            -vlan_id              vlan_id            \
            -vlan_id_mode         vlan_id_mode       \
            -vlan_id_step         vlan_id_step       \
            -vlan_user_priority   vlan_user_priority \
            -ip_address_step      intf_ip_addr_step  \
            -no_write             no_write           \
            -gateway_ip_address   neighbor_intf_ip_addr\
            -gateway_ip_address_step neighbor_intf_ip_addr_step"

    foreach {option value_name} $config_options {
        if {[info exists $value_name]} {
            append config_param " $option [set $value_name] "
        }
    }

    set desc_list ""
    if {[info exists interface_handle]} {
        foreach item $interface_handle {
            lappend desc_list [rfget_interface_description_from_handle $item]
        }
    } else {
        set intf_status [eval ::ixia::protocol_interface_config $config_param]

        # Check status
        if {[keylget intf_status status] != $::SUCCESS} {
            keylset returnList log "ERROR in $procName: [keylget intf_status log]"
            keylset returnList status $::FAILURE
            return $returnList
        }
        set desc_list [keylget intf_status description]
    }

    #######################
    #  LOOP for multi MLD #
    #######################
    foreach interface_description $desc_list {

        set mld_host [::ixia::nextMldHandle]

        mldHost       setDefault
        mldGroupRange setDefault
        mldHost       clearAllGroupRanges
        mldGroupRange clearAllSourceRanges

        mldHost config -protocolInterfaceDescription $interface_description
        mldHost config -enable true

        ::ixia::mldSetHostOptions
    
        set retCode [mldServer addHost $mld_host]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to mldServer\
                    addHost $mld_host failed.  Return code was\
                    $retCode."
            return $returnList
        }

        lappend mld_host_list $mld_host
    }

    set retCode [mldServer set]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Call to mldServer set\
                failed.  Return code was $retCode."
        return $returnList
    }

    # Enable MLD Service on the interface
    set retCode [protocolServer get $chassis $card $port]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Call to protocolServer\
                get $chassis $card $port failed.  Return code was $retCode."
        return $returnList
    }
    protocolServer config -enableMldService true
    set retCode [protocolServer set $chassis $card $port]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Call to protocolServer\
                set $chassis $card $port failed.  Return code was $retCode."
        return $returnList
    }

    stat config -enableMldStats true
    set retCode [stat set $chassis $card $port]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Call to stat set\
                $chassis $card $port failed.  Return code was $retCode."
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
    
    keylset returnList status $::SUCCESS
    keylset returnList handle $mld_host_list
    return $returnList
}


proc ::ixia::emulation_mld_group_config { args } {
    variable executeOnTclServer
    variable new_ixnetwork_api
    variable mld_port
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args

    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::emulation_mld_group_config $args\}]
        
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
        -mode           CHOICES create modify delete clear_all
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
        set returnList [::ixia::ixnetwork_mld_group_config $args $man_args \
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

    variable mld_handles_array
    variable mld_group_ranges_array
    
    upvar #0 ::ixia::multicast_group_array  mga
    upvar #0 ::ixia::multicast_source_array msa
    
    # When mode is create/clear_all check if session_handle is present
    if {($mode == "create") || ($mode == "clear_all")} {
        if {![info exists session_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the -mode is\
                    $mode, a -session_handle is required.  Please supply\
                    this value."
            return $returnList
        }
    }
    
    # When mode is modify check if at least one of group_pool_handle or
    # source_pool_handle is present
    if {$mode == "modify"} {
        if {![info exists group_pool_handle]\
                    && ![info exists source_pool_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the -mode is\
                    $mode, at least one of -group_pool_handle or\
                    -source_pool_handle is required.  Please supply\
                    this value(s)."
            return $returnList
        }
    }
    
    # When mode is modify/delete check if handle is present
    if {($mode == "modify") || ($mode == "delete")} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the -mode is\
                    $mode, a -handle is required.  Please supply this value."
            return $returnList
        }
        if {([array names mld_group_ranges_array $handle] == "")} {
            keylset returnList status $::FAILURE
            keylset returnList log "$procName: Cannot find the group\
                    handle $handle in the mld_group_ranges_array."
            keylset returnList status $::FAILURE
            return $returnList
        }
        
        set session_handle $mld_group_ranges_array($handle)
    }
    
    # When mode is create check if group_pool_handle is present
    if {$mode == "create"} {
        if {![info exists group_pool_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the -mode is\
                    $mode, a -group_pool_handle is required.  Please supply\
                    this value."
            return $returnList
        }
    }

    # Check if there are entries in mld_handles_array for session_handle
    if {([array names mld_handles_array $session_handle,port] == "")\
            || ([array names mld_handles_array $session_handle,filter] == "")} {
        keylset returnList status $::FAILURE
        keylset returnList log "$procName: Cannot find the session\
                handle $session_handle in the mld_handles_array."
        keylset returnList status $::FAILURE
        return $returnList
    }
    
    if {$mld_handles_array($session_handle,filter) == "include"} {
        set sourceMode "multicastSourceModeInclude"
    } else  {
        set sourceMode "multicastSourceModeExclude"
    }
    
    set interface $mld_handles_array($session_handle,port)
    foreach {chassis card port} $interface {}
    ::ixia::addPortToWrite $chassis/$card/$port
    
    # Check if MLD package has been installed on the port
    if {[catch {mldServer select $chassis $card $port} retCode]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The MLD protocol\
                has not been installed on port or is not supported on port: \
                $chassis/$card/$port."
        return $returnList
    }
    
    # Select MLD server
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Call to mldServer select\
                $chassis $card $port failed.  Return code was $retCode."
        return $returnList
    }

    set retCode [mldServer getHost $session_handle]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Call to mldServer getHost\
                $session_handle failed.  Return code was $retCode."
        return $returnList
    }

    # Clears all groups on host
    if {$mode == "clear_all"} {
        mldHost clearAllGroupRanges
        
        updateMldGroupRangeArray -mode delete -handle $session_handle
                
    }

    # Deletes the specified group
    if {$mode == "delete"} {
        set retCode [mldHost delGroupRange $handle]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to mldServer\
                    delGroupRange $handle failed.  Return code was $retCode."
            return $returnList
        }

        updateMldGroupRangeArray -mode delete -group_range_handle $handle
    }
    
    # Creates a new group range
    if {$mode == "create"} {
        set group_range [nextMldGroupRange]

        if {([array names mga $group_pool_handle,num_groups] == "")\
                    || ([array names mga $group_pool_handle,ip_addr_start] == "")\
                    || ([array names mga $group_pool_handle,ip_addr_step] == "")} {
            keylset returnList status $::FAILURE
            keylset returnList log "$procName: Cannot find the group\
                    range $group_pool_handle in the multicast_group_array"
            return $returnList
        }

        set groupCount $mga($group_pool_handle,num_groups)
        set groupIp $mga($group_pool_handle,ip_addr_start)
        set groupStep [::ixia::ip_addr_to_num \
                [::ipv6::convertIpV6ToIp \
                $mga($group_pool_handle,ip_addr_step)]]
        
        mldGroupRange clearAllSourceRanges

        # Option source_pool_handle supplied
        if {[info exists source_pool_handle]} {
            set j 1
            # Add each source to group
            foreach source_range $source_pool_handle {
                if {([array names msa $source_range,num_sources] == "") || \
                            ([array names msa $source_range,ip_addr_start] == "")} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "$procName: Cannot find the source\
                            range $source_range in the multicast_source_array"
                    return $returnList
                }
                
                set sourceCount  $msa($source_range,num_sources)
                set sourceIp     [expand_ipv6_addr $msa($source_range,ip_addr_start)]
                set sourceIpStep [expand_ipv6_addr $msa($source_range,ip_addr_step)]
                
                if {[ip_addr_to_num $sourceIpStep] != 1} {
                    for {set iii 0} {$iii < $sourceCount} {incr iii} {
                        mldSourceRange setDefault
                        mldSourceRange config -count        1
                        mldSourceRange config -sourceIpFrom $sourceIp
                        mldGroupRange addSourceRange source$j
                        incr j
                        set sourceIp  [incr_ipv6_addr $sourceIp $sourceIpStep]
                    }
                } else {
                    mldSourceRange setDefault
                    mldSourceRange config -count        $sourceCount
                    mldSourceRange config -sourceIpFrom $sourceIp
                    mldGroupRange addSourceRange source$j
                    incr j
                }
            }
        }
        
        mldGroupRange setDefault
        mldGroupRange config -enable true
        mldGroupRange config -groupCount $groupCount
        mldGroupRange config -groupIpFrom $groupIp
        mldGroupRange config -incrementStep $groupStep
        mldGroupRange config -sourceMode $sourceMode
            
        set retCode [mldHost addGroupRange $group_range]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to mldHost\
                    addGroupRange $group_range failed.  Return code\
                    was $retCode."
            return $returnList
        }
        
        set handle $group_range
        updateMldGroupRangeArray -mode create -group_range_handle $handle \
               -handle $session_handle
    }
    
    #Modifies an existing group range
    if {$mode == "modify"} {
        set retCode [mldHost getGroupRange $handle]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    mldServer getGroupRange $handle failed.  Return\
                    code was $retCode."
            return $returnList
        }
        
        # Source ranges are modified
        if {[info exists source_pool_handle]} {
            mldGroupRange clearAllSourceRanges

            set j 1
            # Add each source to group
            foreach source_range $source_pool_handle {
                if {([array names msa $source_range,num_sources] == "") || \
                        ([array names msa $source_range,ip_addr_start] == "")} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "$procName: Cannot find the source\
                            range $source_range in the multicast_source_array"
                    return $returnList
                }
                
                set sourceIp          [expand_ipv6_addr $msa($source_range,ip_addr_start)]
                set sourceIpStep      [expand_ipv6_addr $msa($source_range,ip_addr_step)]
                if {[ip_addr_to_num $sourceIpStep] == 1} {
                    set sourceCount      $msa($source_range,num_sources)
                    set sourceRangeCount 1
                } else {
                    set sourceCount      1
                    set sourceRangeCount $msa($source_range,num_sources)
                }
                for {set iii 0} {$iii < $sourceRangeCount} {incr iii} {
                    mldSourceRange setDefault
                    mldSourceRange config -count        $sourceCount
                    mldSourceRange config -sourceIpFrom $sourceIp
                    mldGroupRange addSourceRange source$j
                    incr j
                    set sourceIp  [incr_ipv6_addr $sourceIp $sourceIpStep]
                }
            }
        }
        
        # Group range is modified
        if {[info exists group_pool_handle]} {
            if {([array names mga $group_pool_handle,num_groups] == "")\
                    || ([array names mga $group_pool_handle,ip_addr_start] == "")\
                    || ([array names mga $group_pool_handle,ip_addr_step] == "")} {
                keylset returnList status $::FAILURE
                keylset returnList log "$procName: Cannot find the group\
                        range $group_pool_handle in the multicast_group_array"
                return $returnList
            }
                
            set groupCount $mga($group_pool_handle,num_groups)
            set groupIp $mga($group_pool_handle,ip_addr_start)
            set groupStep [::ixia::ip_addr_to_num \
                    [::ipv6::convertIpV6ToIp \
                    $mga($group_pool_handle,ip_addr_step)]]
                    
            mldGroupRange config -groupCount $groupCount
            mldGroupRange config -groupIpFrom $groupIp
            mldGroupRange config -incrementStep $groupStep
            mldGroupRange config -sourceMode $sourceMode
        }
        
        set retCode [mldHost setGroupRange $handle]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to mldHost\
                    setGroupRange $handle failed.  Return code was $retCode."
            return $returnList
        }
    }
    
    # Do not call setHost when making modifications for the group !
    if {$mode != "modify"} {
        set retCode [mldServer setHost $session_handle]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to mldServer\
                    setHost $session_handle failed.  Return code\
                    was $retCode."
            return $returnList
        }
    }
        
    set retCode [mldServer set]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Call to mldServer\
                set failed.  Return code was $retCode."
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
    
    keylset returnList status  $::SUCCESS
    if {[info exists handle]} {
        keylset returnList handle  $handle
    }
    if {[info exists group_pool_handle]} {
        keylset returnList group_pool_handle  $group_pool_handle
    }
    if {[info exists source_pool_handle]} {
        keylset returnList source_pool_handle $source_pool_handle
    }
    return $returnList
}


proc ::ixia::emulation_mld_control { args } {
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
                \{::ixia::emulation_mld_control $args\}]
        
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
        -mode   CHOICES start stop restart join leave
    }

    set opt_args {
        -handle
        -port_handle          REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -group_member_handle
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_mld_control $args $man_args \
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

    parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args

    variable mld_handles_array
    variable mld_group_ranges_array
    
    # For start/stop/restart check if port_handle is present
    if {($mode == "start") || ($mode == "stop") || ($mode == "restart")} {
        if {![info exists port_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the -mode is\
                    $mode, a -port_handle is required.  Please supply\
                    this value."
            return $returnList
        }
        
        set port_list [format_space_port_list $port_handle]
        set interface [lindex $port_list 0]
        set list_intrf [list $interface]
        
        # Check if MLD package has been installed on the port
        foreach port_i $port_list {
            foreach {chs_i crd_i prt_i} $port_i {}
            if {[catch {mldServer select $chs_i $crd_i $prt_i } error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The MLD\
                        protocol has not been installed on port or\
                        is not supported on port: \
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
    }
    
    # Start the protocol
    if {$mode == "start"} {
        if {[ixStartMld list_intrf]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Could not start\
                    MLD on port: $port_handle"
            return $returnList
        }
    }
    
    # Stop the protocol
    if {$mode == "stop"} {
        if {[ixStopMld list_intrf]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Could not stop\
                    MLD on port: $port_handle"
            return $returnList
        }
    }
    
    # Restart the protocol
    if {$mode == "restart"} {
        if {[ixStopMld list_intrf]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Could not stop\
                    MLD on port: $port_handle, during restart process."
            return $returnList
        }
        if {[ixStartMld list_intrf]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Could not start\
                    MLD on port: $port_handle, during restart process."
            return $returnList
        }
    }
    
    # Join/leave group ranges
    if {($mode == "join") || ($mode == "leave")} {
        if {[info exists handle]} {
            # Enable/disable all group ranges on this host
            upvar 0 handle mld_host
            if {[array names mld_handles_array $mld_host,port] == ""} {
                keylset returnList log "$procName: Cannot find the session\
                        handle $mld_host in the mld_handles_array"
                keylset returnList status $::FAILURE
                return $returnList
            }
            set interface $mld_handles_array($mld_host,port)
            foreach {chassis card port} $interface {}
            
            # Check if MLD package has been installed on the port
            if {[catch {mldServer select $chassis $card $port} retCode]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The MLD\
                        protocol has not been installed on port or\
                        is not supported on port: \
                        $chassis/$card/$port."
                return $returnList
            }
            
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        mldServer select $chassis $card $port failed. \
                        Return code was $retCode."
                return $returnList
            }

            set retCode [mldServer getHost $mld_host]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        mldServer getHost $mld_host failed.  Return code\
                        was $retCode."
                return $returnList
            }
            
            if {[mldHost getFirstGroupRange] == 0} {
                switch -- $mode {
                    join {
                        mldGroupRange config -enable true
                    }
                    leave {
                        mldGroupRange config -enable false
                    }
                }
                
                set retCode [mldHost setGroupRange]
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Call to\
                            mldHost setGroupRange failed.  Return code\
                            was $retCode."
                    return $returnList
                }
                
                while {[mldHost getNextGroupRange] == 0} {
                    switch -- $mode {
                        join {
                            mldGroupRange config -enable true
                        }
                        leave {
                            mldGroupRange config -enable false
                        }
                    }
                    
                    set retCode [mldHost setGroupRange]
                    if {$retCode} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Call to\
                                mldHost setGroupRange failed.  Return\
                                code was $retCode."
                        return $returnList
                    }
                }
                
                set retCode [mldServer set]
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Call to\
                            mldServer set failed.  Return code was\
                            $retCode."
                    return $returnList
                }
                set retCode [mldServer write]
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Call to\
                            mldServer write failed.  Return code was\
                            $retCode."
                    return $returnList
                }
            }
        } elseif {[info exists group_member_handle]} {
            # Enable these group ranges only
            foreach group_range $group_member_handle {
                if {[array names mld_group_ranges_array $group_range] == ""} {
                    keylset returnList log "$procName: Cannot find the group\
                            handle $group_range in the mld_group_ranges_array"
                    keylset returnList status $::FAILURE
                    return $returnList
                }
                set mld_host $mld_group_ranges_array($group_range)

                if {[array names mld_handles_array $mld_host,port] == ""} {
                    keylset returnList log "$procName: Cannot find the session\
                            handle $mld_host in the mld_handles_array"
                    keylset returnList status $::FAILURE
                    return $returnList
                }
                set interface $mld_handles_array($mld_host,port)
                foreach {chassis card port} $interface {}
        
                # Check if MLD package has been installed on the port
                if {[catch {mldServer select $chassis $card $port} retCode]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: The MLD\
                            protocol has not been installed on port or\
                            is not supported on port: \
                            $chassis/$card/$port."
                    return $returnList
                }
                
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Call to\
                            mldServer select $chassis $card $port failed. \
                            Return code was $retCode."
                    return $returnList
                }
                
                set retCode [mldServer getHost $mld_host]
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Call to\
                            mldServer getHost $mld_host failed.  Return code\
                            was $retCode."
                    return $returnList
                }
                
                set retCode [mldHost getGroupRange $group_range]
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Call to\
                            mldHost getGroupRange $group_range failed. \
                            Return code was $retCode."
                    return $returnList
                }
                
                switch -- $mode {
                    join {
                        mldGroupRange config -enable true
                    }
                    leave {
                        mldGroupRange config -enable false
                    }
                }
    
                set retCode [mldHost setGroupRange $group_range]
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Call to\
                            mldHost setGroupRange $group_range failed. \
                            Return code was $retCode."
                    return $returnList
                }
                
                set retCode [mldServer set]
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Call to\
                            mldServer set failed.  Return code was\
                            $retCode."
                    return $returnList
                }
                
                set retCode [mldServer write]
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Call to\
                            mldServer set failed.  Return code was\
                            $retCode."
                    return $returnList
                }
            }
        } else {
            # Enable all group ranges on all hosts
            foreach session [array names mld_handles_array "*,port"] {
                
                set mld_host [string range $session 0 end-5]
                set interface $mld_handles_array($mld_host,port)
                foreach {chassis card port} $interface {}
                
                set retCode [mldServer select $chassis $card $port]
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Call to\
                            mldServer select $chassis $card $port failed. \
                            Return code was $retCode."
                    return $returnList
                }
                
                set retCode [mldServer getHost $mld_host]
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Call to\
                            mldServer getHost $mld_host failed.  Return code\
                            was $retCode."
                    return $returnList
                }
                
                if {[mldHost getFirstGroupRange] == 0} {
                    switch -- $mode {
                        join {
                            mldGroupRange config -enable true
                        }
                        leave {
                            mldGroupRange config -enable false
                        }
                    }
                    
                    set retCode [mldHost setGroupRange]
                    if {$retCode} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Call to\
                                mldHost setGroupRange failed.  Return code\
                                was $retCode."
                        return $returnList
                    }
                    
                    while {[mldHost getNextGroupRange] == 0} {
                        switch -- $mode {
                            join {
                                mldGroupRange config -enable true
                            }
                            leave {
                                mldGroupRange config -enable false
                            }
                        }
                        
                        set retCode [mldHost setGroupRange]
                        if {$retCode} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName:\
                                    Call to mldHost setGroupRange failed. \
                                    Return code was $retCode."
                            return $returnList
                        }
                    }
                    
                    set retCode [mldServer set]
                    if {$retCode} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Call\
                                to mldServer set failed.  Return code\
                                was $retCode."
                        return $returnList
                    }
                    set retCode [mldServer write]
                    if {$retCode} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Call\
                                to mldServer write failed.  Return code\
                                was $retCode."
                        return $returnList
                    }
                }
            }
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}
