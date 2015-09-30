
# Copyright © 2003-2008 by IXIA
# All Rights Reserved.
#
# Name:
#    ixnetwork_dhcp_api.tcl
#
# Purpose:
#    A script development library containing DHCP API procedures.
#
# Author:
#    George Comanescu
#
# Usage:
#    package req Ixia
#
# Description:
#
#
# Requirements:
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



##Internal Procedure Header
# Name:
#    ::ixia::ixnetwork_dhcp_config
#
# Description:
#    This procedure will configure DHCP attributes.
#
# Synopsis:
#
#
# Arguments:
#
# Return Values:
#
# Examples:
#
# Notes:


proc ::ixia::ixnetwork_dhcp_config { args opt_args man_args } {
    
    set procName [lindex [info level [info level]] 0]

    if [catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} errorMsg] {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg."
        return $returnList
    }

    array set truth {1 true 0 false enable true disable false}
    
	# array: ixn_attr => val
	variable dhcp_globals_params
	# array: port_ref,ixn_attr => val
	variable dhcp_options_params
	
    set global_params {
        accept_partial_config          acceptPartialConfig           truth    _none
        lease_time                     dhcp4AddrLeaseTime            value    _none
        max_dhcp_msg_size              dhcp4MaxMsgSize               value    _none
        msg_timeout                    dhcp4ResponseTimeout          value    _none
        retry_count                    dhcp4NumRetry                 value    _none
        server_port                    dhcp4ServerPort               value    _none
        wait_for_completion            waitForCompletion             truth    _none
        dhcp6_echo_ia_info             dhcp6EchoIaInfo               truth    _none
        dhcp6_reb_max_rt               dhcp6RebMaxRt                 value    _none
        dhcp6_reb_timeout              dhcp6RebTimeout               value    _none
        dhcp6_rel_max_rc               dhcp6RelMaxRc                 value    _none
        dhcp6_rel_timeout              dhcp6RelTimeout               value    _none
        dhcp6_ren_max_rt               dhcp6RenMaxRt                 value    _none
        dhcp6_ren_timeout              dhcp6RenTimeout               value    _none
        dhcp6_req_max_rc               dhcp6ReqMaxRc                 value    _none
        dhcp6_req_max_rt               dhcp6ReqMaxRt                 value    _none
        dhcp6_req_timeout              dhcp6ReqTimeout               value    _none
        dhcp6_sol_max_rc               dhcp6SolMaxRc                 value    _none
        dhcp6_sol_max_rt               dhcp6SolMaxRt                 value    _none
        dhcp6_sol_timeout              dhcp6SolTimeout               value    _none
        msg_timeout_factor             dhcp4ResponseTimeoutFactor    value    _none
    }

    set options_args {
        outstanding_releases_count     maxOutstandingReleases        value    _none
        outstanding_session_count      maxOutstandingRequests        value    _none
        release_rate                   teardownRateInitial           value    _none
        release_rate_increment         teardownRateIncrement         value    _none
        request_rate                   setupRateInitial              value    _none
        request_rate_increment         setupRateIncrement            value    _none    
        associates                     associates                    value    _none    
        override_global_setup_rate     overrideGlobalSetupRate       truth    _none
        override_global_teardown_rate  overrideGlobalTeardownRate    truth    _none
        release_rate_max               teardownRateMax               value    _none
        request_rate_max               setupRateMax                  value    _none
    }
	
	# Make variable value adjustments to ensure compatibility...
    if {![info exists request_rate_max] && [info exists request_rate]} {
        set request_rate_max $request_rate
    }
    if {![info exists release_rate_max] && [info exists release_rate]} {
        set release_rate_max $release_rate
    }
	
    # Check to see if a connection to the IxNetwork TCL Server already exists. 
    # If it doesn't, establish it.
    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
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
            
            if {[info exists reset]} {
                set commit_needed false
                set ethernet_list [ixNet getList $vport_objref/protocolStack ethernet]
                foreach ethernet_item $ethernet_list {
                    set dhcp_endpoint_list [ixNet getList $ethernet_item dhcpEndpoint]
                    foreach dhcp_endpoint_item $dhcp_endpoint_list {
                        set range_list [ixNet getList $dhcp_endpoint_item range]
                        foreach range_item $range_list {
                            ixNet remove $range_item
                            set commit_needed true
                        }
                    }
                }
                if {$commit_needed} {
                    if {[ixNet commit] != "::ixNet::OK"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Calling IxNet commit.\
                                The range under the dhcpEndpoint could not be deleted."
                        return $returnList
                    }
                }
            }
            
			
			# clear old globals/options
			foreach {hlt_arg ixn_arg p_type ext} $global_params {
				catch {unset dhcp_globals_params($ixn_arg)}
			}
			foreach {hlt_arg ixn_arg p_type ext} $options_args {
				catch {unset dhcp_options_params($vport_objref,$ixn_arg)}
			}
            
            # Configure dhcp global params array
            foreach {hlt_param ixn_param p_type extensions} $global_params {
                if {[info exists $hlt_param]} {
                    set hlt_param_value [set $hlt_param]
                    switch -- $p_type {
                        value {
                            set ixn_param_value $hlt_param_value
                        }
                        truth {
                            set ixn_param_value $truth($hlt_param_value)
                        }
                    }
					set dhcp_globals_params($ixn_param) $ixn_param_value
                }
            }
            
            # Configure dhcp options params array
			set ixn_param_list {}
            foreach {hlt_param ixn_param p_type extensions} $options_args {
				lappend ixn_param_list $ixn_param
                if {[info exists $hlt_param]} {
                    set hlt_param_value [set $hlt_param]
                    switch -- $p_type {
                        value {
                            set ixn_param_value $hlt_param_value
                        }
                        truth {
                            set ixn_param_value $truth($hlt_param_value)
                        }
                    }
					set dhcp_options_params($vport_objref,$ixn_param) $ixn_param_value
                }
            }	
			if {![info exists dhcp_options_params(ixn_param_list)]} {
				set dhcp_options_params(ixn_param_list) $ixn_param_list
			}
        }
        "modify" {            
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : \
                        -handle parameter missing when -mode is $mode."
                return $returnList
            } else {
                if {[ixNet exists $handle] == "false" || [ixNet exists $handle] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : \
                            invalid or incorect -handle."
                    return $returnList
                }
            }
            if {![regexp -all {^::ixNet::OBJ-/vport:\d+$} $handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -handle $handle is not a valid vport handle."
                return $returnList
            }
            set vport_objref $handle
            # Configure dhcp global params array
            foreach {hlt_param ixn_param p_type extensions} $global_params {
                if {[info exists $hlt_param]} {
                    set hlt_param_value [set $hlt_param]
                    switch -- $p_type {
                        value {
                            set ixn_param_value $hlt_param_value
                        }
                        truth {
                            set ixn_param_value $truth($hlt_param_value)
                        }
                    }
					set dhcp_globals_params($ixn_param) $ixn_param_value
                }
            }
            
            # Configure dhcp options params array               
            foreach {hlt_param ixn_param p_type extensions} $options_args {
                if {[info exists $hlt_param]} {
                    set hlt_param_value [set $hlt_param]
                    switch -- $p_type {
                        value {
                            set ixn_param_value $hlt_param_value
                        }
                        truth {
                            set ixn_param_value $truth($hlt_param_value)
                        }
                    }
					set dhcp_options_params($vport_objref,$ixn_param) $ixn_param_value
                }
            }
        }
    }
	
	# Dhcp globals tree may not exist at this point. Create it.
	set globals_objs [ixNet getL ::ixNet::OBJ-/globals/protocolStack dhcpGlobals]
	if {[llength $globals_objs] == 0} {
		set globals_objs [ixNet add ::ixNet::OBJ-/globals/protocolStack dhcpGlobals]
		if {[ixNet commit] != "::ixNet::OK"} {
			keylset returnList status $::FAILURE
			keylset returnList log "ERROR in $procName: Calling IxNet commit.\
					The dhcp global options object could not be initiated."
			return $returnList
		}	
		set globals_objs [ixNet remapIds $globals_objs]
	}
	
	set ixn_global_args ""
	foreach ixn_arg [array names dhcp_globals_params] {
		append ixn_global_args "-$ixn_arg $dhcp_globals_params($ixn_arg) "
	}
	
	if {$ixn_global_args != ""} {
		set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
				[lindex $globals_objs 0]						        \
				$ixn_global_args                                        \
				-commit                                                 \
			]
		if {[keylget tmp_status status] != $::SUCCESS} {
			keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
			return $tmp_status
		}
	}
	
	# Dhcp options tree may not exist at this point. Create it.
	if {[llength [ixNet getL ${vport_objref}/protocolStack dhcpOptions]] == 0} {
		set options_obj [ixNet add ${vport_objref}/protocolStack dhcpOptions]
		if {[ixNet commit] != "::ixNet::OK"} {
			keylset returnList status $::FAILURE
			keylset returnList log "ERROR in $procName: Calling IxNet commit.\
					Could not create dhcpOptions object over protocolStack."
			return $returnList
		}
		set options_obj [ixNet remapIds $options_obj]
	} else {
		set options_obj [ixNet getL ${vport_objref}/protocolStack dhcpOptions]            
	}
	
	set ixn_options_args ""
	if {![info exists dhcp_options_params(ixn_param_list)]} {
		keylset returnList status $::FAILURE
		keylset returnList log "ERROR in $procName: \
				Internal error. Missing ixn_param_list."
		return $returnList
	}
	foreach ixn_arg $dhcp_options_params(ixn_param_list) {
		if {[info exists dhcp_options_params($vport_objref,$ixn_arg)]} {
			append ixn_options_args "-$ixn_arg $dhcp_options_params($vport_objref,$ixn_arg) "
		}
	}
	
	if {$ixn_options_args != ""} {
		set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
				"$options_obj"                                          \
				$ixn_options_args                                       \
				-commit                                                 \
			]                   
		if {[keylget tmp_status status] != $::SUCCESS} {
			keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
			return $tmp_status
		}
	} 
	
	keylset returnList  handle  "${vport_objref}"
	keylset returnList  status  $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::ixnetwork_dhcp_group_config
#
# Description:
#    This procedure will configure DHCP attributes.
#
# Synopsis:
#
#
# Arguments:
#
# Return Values:
#
# Examples:
#
# Notes:

proc ::ixia::ixnetwork_dhcp_group_config { args opt_args man_args } {
    
    set procName [lindex [info level [info level]] 0]
    
    if [catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} errorMsg] {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg."
        return $returnList
    }

    array set truth {1 true 0 false enable true disable false}
	
	# globals and port options for dhcp
	variable dhcp_globals_params
	variable dhcp_options_params
    
    # Current endpoint excluded - dhcpEndpoint
    
    set unsupported_params {
        sessions_per_vc                               X     value    _none
        server_id                                     X     value    _none
        target_subport                                X     value    _none
    }
    
    # Group dhcp_range_param_request_list so it becomes one data unit to pass into IxN.
#     if {[info exists dhcp_range_param_request_list]} {
#         set dhcp_range_param_request_list "\"${dhcp_range_param_request_list}\""
#     }
    
    set ethernet_endpoint_dhcp_range_params {        
        dhcp6_range_duid_enterprise_id                dhcp6DuidEnterpriseId              value      _none
        dhcp6_range_duid_type                         dhcp6DuidType                      translate  _none
        dhcp6_range_duid_vendor_id                    dhcp6DuidVendorId                  value      _none
        dhcp6_range_duid_vendor_id_increment          dhcp6DuidVendorIdIncrement         value      _none
        dhcp6_range_ia_id                             dhcp6IaId                          value      _none
        dhcp6_range_ia_id_increment                   dhcp6IaIdIncrement                 value      _none
        dhcp6_range_ia_t1                             dhcp6IaT1                          value      _none
        dhcp6_range_ia_t2                             dhcp6IaT2                          value      _none
        dhcp6_range_ia_type                           dhcp6IaType                        translate  _none
        dhcp6_range_param_request_list                dhcp6ParamRequestList              list       _none        
        num_sessions                                  count                              value      _none
        dhcp_range_ip_type                            ipType                             translate  _none
        dhcp_range_param_request_list                 dhcp4ParamRequestList              list       _none
        dhcp_range_relay6_hosts_per_opt_interface_id  relay6HostsPerOptInterfaceId       value      _none
        dhcp_range_relay6_opt_interface_id            relay6OptInterfaceId               escape     _none
        dhcp_range_relay6_use_opt_interface_id        relay6UseOptInterfaceId            truth      _none
        dhcp_range_relay_address_increment            relayAddressIncrement              value      _none
        dhcp_range_relay_circuit_id                   relayCircuitId                     value      _none
        dhcp_range_relay_count                        relayCount                         value      _none
        dhcp_range_relay_destination                  relayDestination                   value      _none
        dhcp_range_relay_first_address                relayFirstAddress                  value      _none
        dhcp_range_relay_first_vlan_id                relayFirstVlanId                   value      _none
        dhcp_range_relay_gateway                      relayGateway                       value      _none
        dhcp_range_relay_hosts_per_circuit_id         relayHostsPerCircuitId             value      _none
        dhcp_range_relay_hosts_per_remote_id          relayHostsPerRemoteId              value      _none
        dhcp_range_relay_override_vlan_settings       relayOverrideVlanSettings          truth      _none
        dhcp_range_relay_remote_id                    relayRemoteId                      value      _none
        dhcp_range_relay_subnet                       relaySubnet                        value      _none
        dhcp_range_relay_use_circuit_id               relayUseCircuitId                  truth      _none
        dhcp_range_relay_use_remote_id                relayUseRemoteId                   truth      _none
        dhcp_range_relay_use_suboption6               relayUseSuboption6                 truth      _none
        dhcp_range_relay_vlan_count                   relayVlanCount                     value      _none
        dhcp_range_relay_vlan_increment               relayVlanIncrement                 value      _none
        dhcp_range_renew_timer                        renewTimer                         value      _none
        dhcp_range_server_address                     dhcp4ServerAddress                 value      _none
        dhcp_range_suboption6_address_subnet          suboption6AddressSubnet            value      _none
        dhcp_range_suboption6_first_address           suboption6FirstAddress             value      _none
        dhcp_range_use_first_server                   dhcp4UseFirstServer                truth      _none
        dhcp_range_use_relay_agent                    useRelayAgent                      truth      _none
        dhcp_range_use_trusted_network_element        useTrustedNetworkElement           truth      _none
        use_vendor_id                                 useVendorClassId                   truth      _none
        vendor_id                                     vendorClassId                      value      _none
    }
    
    
    set atm_pvc_range_params {
        pvc_incr_mode                                 incrementMode      translate   _none
        vci                                           vciFirstId         value       _none
        vci_count                                     vciUniqueCount     value       _none
        vci_step                                      vciIncrement       value       _none
        vpi                                           vpiFirstId         value       _none
        vpi_count                                     vpiUniqueCount     value       _none
        vpi_step                                      vpiIncrement       value       _none
    }
    
    array set translate_encap_map {
        vc_mux_ipv4_routed  {atm "VC Mux IPv4 Routed"               1               }
        vc_mux_fcs          {atm "VC Mux Bridged Ethernet (FCS)"    2               }
        vc_mux              {atm "VC Mux Bridged Ethernet (no FCS)" 3               }
        vc_mux_ipv6_routed  {atm "VC Mux IPv6 Routed"               4               }
        llcsnap_routed      {atm "LLC Routed AAL5 Snap"             6               }
        llcsnap_fcs         {atm "LLC Bridged Ethernet (FCS)"       7               }
        llcsnap             {atm "LLC Bridged Ethernet (no FCS)"    8               }
        llcsnap_ppp         {atm "LLC Encap PPP"                    9               }
        vc_mux_ppp          {atm "VC Mux PPP"                       10              }
        ethernet_ii         {ethernet NA                                 NA}
        ethernet_ii_vlan    {ethernet NA                                 NA}
        ethernet_ii_qinq    {ethernet NA                                 NA}
    }
    
    set atm_atm_range_params {
        mac_addr                                      mac                mac                _none
        mac_addr_step                                 incrementBy        mac                _none
        num_sessions                                  count              value              _none
        mac_mtu                                       mtu                value              _none
        encap                                         encapsulation      translate_encap    _none
    }
        
    set ethernet_endpoint_mac_range_params {
        mac_addr                                      mac                mac         _none
        mac_addr_step                                 incrementBy        mac         _none
        num_sessions                                  count              value       _none
        mac_mtu                                       mtu                value       _none 
    }
    
    set ethernet_endpoint_vlan_range_params {
        vlan_enabled                                  enabled            value       _none
        vlan_inner_enabled                            innerEnable        value       _none
        vlan_id                                       firstId            value       _none
        vlan_id_count                                 uniqueCount        value       _none
        vlan_id_step                                  increment          value       _none
        vlan_id_increment_step                        incrementStep      value       _none
        vlan_user_priority                            priority           value       _none
        vlan_id_outer                                 innerFirstId       value       _none
        vlan_id_outer_count                           innerUniqueCount   value       _none
        vlan_id_outer_step                            innerIncrement     value       _none
        vlan_id_outer_increment_step                  innerIncrementStep value       _none
        vlan_id_outer_priority                        innerPriority      value       _none
    }
    
    if {[info exists encap] && $encap == "ethernet_ii_qinq"} {
        set ethernet_endpoint_vlan_range_params {
            vlan_enabled                                  enabled            value       _none
            vlan_inner_enabled                            innerEnable        value       _none
            qinq_incr_mode                                idIncrMode         translate   _none
            vlan_id                                       innerFirstId       value       _none
            vlan_id_count                                 innerUniqueCount   value       _none
            vlan_id_outer                                 firstId            value       _none
            vlan_id_outer_count                           uniqueCount        value       _none
            vlan_id_outer_step                            increment          value       _none
            vlan_id_step                                  innerIncrement     value       _none
            vlan_id_increment_step                        innerIncrementStep value       _none
            vlan_user_priority                            innerPriority      value       _none
            vlan_id_outer_increment_step                  incrementStep      value       _none
            vlan_id_outer_priority                        priority           value       _none
        }
    }
    
    if {[info exists vlan_id] && [info exists vlan_id_outer] && [info exists encap] && ($encap == "ethernet_ii_qinq")} {
        set vlan_enabled          1
        set vlan_inner_enabled    1
    } elseif {[info exists vlan_id] && [info exists encap] && ($encap == "ethernet_ii_vlan")} {
        set vlan_enabled          1
        set vlan_inner_enabled    0
    } else {
        set vlan_enabled          0
        set vlan_inner_enabled    0
    }
    
    array set range_options_map {
        iana        IANA        \
        iata        IATA        \
        iapd        IAPD        \
        iana_iapd   IANA+IAPD   \
        ipv4        IPv4        \
        ipv6        IPv6        \
        4           IPv4        \
        6           IPv6        \
        duid_llt    DUID-LLT    \
        duid_en     DUID-EN     \
        duid_ll     DUID-LL     \
        outer       0           \
        inner       1           \
        both        2           \
        vci         0           \
        vpi         1           \
        pvc         2           \
    }    
    
    # Check to see if a connection to the IxNetwork TCL Server already exists. 
    # If it doesn't, establish it.
    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    

    switch -- $mode {
        "create" {
            set enabled 1
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : \
                        -handle parameter missing when -mode is $mode."
                return $returnList
            } else {
                if {[ixNet exists $handle] == "false" || [ixNet exists $handle] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : \
                            invalid or incorect -handle."
                    return $returnList
                }
            }            
            if {![regexp -all {^::ixNet::OBJ-/vport:\d+$} $handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -handle $handle is not a valid vport handle."
                return $returnList
            }
            

            # Assuming handle type is vport... 
            set vport_objref    $handle
            set stack_object "${vport_objref}/protocolStack"
            
            if {[info exists encap]} {
                set result [ixNetworkGetSMPlugin $vport_objref [lindex $translate_encap_map($encap) 0] "dhcpEndpoint"]
                if {[keylget result status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : [keylget result log]"
                    return $returnList
                }
                set next_object [keylget result ret_val]
            } else {
                set current_type [ixNet getAttribute ${vport_objref}/l1Config -currentType]
                set result [ixNetworkGetSMPlugin $vport_objref $current_type "dhcpEndpoint"]
                if {[keylget result status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : [keylget result log]"
                    return $returnList
                }
                set next_object [keylget result ret_val]
                
                if {[string first "atm" $current_type] == 0} {
                    set encap llcsnap
                } else {
                    set encap ethernet_ii
                }
            }
            
            # There will be only one dhcpEndpoint ...
            set dhcpendpoint_object $next_object
            
            # Add range
            set temporary_object [ixNet add $dhcpendpoint_object range]
            if {[ixNet commit] != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Unable to commit after attempt to create range object."
                return $returnList
            }
            
            set range_object_ref [ixNet remapIds $temporary_object]
            # Configure dhcp range params --------------------------------------
            set ixn_dhcp_range_args ""
            foreach {hlt_param ixn_param p_type extensions} $ethernet_endpoint_dhcp_range_params {
                if {[info exists $hlt_param]} {
                    set hlt_param_value [set $hlt_param]
                    switch -- $p_type {
                        value {
                            if {[llength $hlt_param_value] > 1} {
                                set ixn_param_value "$hlt_param_value"
                            } else {
                                set ixn_param_value $hlt_param_value
                            }
                        }
                        escape {
                            set hlt_param_value [string map {[ \[} $hlt_param_value ]
                            if {[llength $hlt_param_value] > 1} {
                                set ixn_param_value "$hlt_param_value"
                            } else {
                                set ixn_param_value $hlt_param_value
                            }
                        }
                        truth {
                            set ixn_param_value $truth($hlt_param_value)
                        }
                        translate {
                            set ixn_param_value $range_options_map($hlt_param_value)
                        }
                        mac {
                            set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                        }
                        list {
                            if {[llength $hlt_param_value] > 1} {
                                set ixn_param_value [lindex $hlt_param_value 0]
                                foreach list_item [lrange $hlt_param_value 1 end] {
                                    append ixn_param_value "; $list_item"
                                }
                                
                                set ixn_param_value "$ixn_param_value"
                            } else {
                                set ixn_param_value $hlt_param_value
                            }
                        }
                    }
                    lappend ixn_dhcp_range_args -$ixn_param $ixn_param_value
                }
            }
            
            if {$ixn_dhcp_range_args != ""} {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                        "$range_object_ref/dhcpRange"                           \
                        $ixn_dhcp_range_args                                    \
                        -commit                                                 \
                    ]                                 
        
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
            }
            
            if {[info exists encap] && [string first "ethernet" $encap] == 0} {
                # Configure dhcp mac range params ----------------------------------
                set ixn_dhcp_mac_range_args ""
                foreach {hlt_param ixn_param p_type extensions} $ethernet_endpoint_mac_range_params {
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
                                set ixn_param_value $range_options_map($hlt_param_value)
                            }
                            mac {
                                set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                            }                        
                        }
                        append ixn_dhcp_mac_range_args "-$ixn_param \"$ixn_param_value\" "
                    }
                }
                if {$ixn_dhcp_mac_range_args != ""} {
                    set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                            "$range_object_ref/macRange"                            \
                            $ixn_dhcp_mac_range_args                                \
                            -commit                                                 \
                        ]                
                      
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                }
                
                # Configure dhcp vlan range params ---------------------------------
            
                set ixn_dhcp_vlan_range_args ""
                foreach {hlt_param ixn_param p_type extensions} $ethernet_endpoint_vlan_range_params {
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
                                set ixn_param_value $range_options_map($hlt_param_value)
                            }
                            mac {
                                set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                            }                        
                        }
                        append ixn_dhcp_vlan_range_args "-$ixn_param $ixn_param_value "
                    }
                }
                if {$ixn_dhcp_vlan_range_args != ""} {
                    set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                            "$range_object_ref/vlanRange"                           \
                            $ixn_dhcp_vlan_range_args                               \
                            -commit                                                 \
                        ]              
                      
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                }
            
            } else {
                # Configure dhcp atm range params ----------------------------------
                set ixn_dhcp_atm_range_args ""
                foreach {hlt_param ixn_param p_type extensions} $atm_atm_range_params {
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
                                set ixn_param_value $range_options_map($hlt_param_value)
                            }
                            translate_encap {
                                set ixn_param_value [lindex [set translate_${hlt_param}_map($hlt_param_value)] 2]
                            }
                            mac {
                                set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                            }                        
                        }
                        append ixn_dhcp_atm_range_args "-$ixn_param \"$ixn_param_value\" "
                    }
                }
                if {$ixn_dhcp_atm_range_args != ""} {
                    set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                            "$range_object_ref/atmRange"                            \
                            $ixn_dhcp_atm_range_args                                \
                            -commit                                                 \
                        ]                
                      
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                }
                
                # Configure ATM PVC range params ----------------------------------
                set atm_pvc_range_args ""
                foreach {hlt_param ixn_param p_type extensions} $atm_pvc_range_params {
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
                                set ixn_param_value $range_options_map($hlt_param_value)
                            }
                            mac {
                                set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                            }                        
                        }
                        append atm_pvc_range_args "-$ixn_param \"$ixn_param_value\" "
                    }
                }
                if {$atm_pvc_range_args != "" && ([lindex $translate_encap_map($encap) 0] == "atm")} {
                    set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                            "$range_object_ref/pvcRange"                            \
                            $atm_pvc_range_args                                     \
                            -commit                                                 \
                        ]                
                      
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                }
            }
          

            keylset returnList  handle  $range_object_ref
            keylset returnList  status  $::SUCCESS
        }
        "modify" {
            set range_handle_ref_list [list]
            if {[::ixia::ixnetwork_is_node_type $handle range]} {
                set vport_objref [ixNetworkGetParentObjref $handle "vport"]
                set dhcpendpoint_object [string range $handle 0 [expr [string first "/range" $handle] - 1]]
                set dhcpendpoint_object_list [list $dhcpendpoint_object]
                set range_handle_ref_list [list $handle]
            } elseif {[::ixia::ixnetwork_is_node_type $handle dhcpEndpoint]} {
                set vport_objref [ixNetworkGetParentObjref $handle "vport"]
                set range_handle_ref_list [ixNet getList $dhcpendpoint_object range]
            } elseif {[::ixia::ixnetwork_is_node_type $handle vport]} {
                set vport_objref    $handle
                set stack_object "${vport_objref}/protocolStack"
                if {[info exists encap] } {
                    if {[string first "ethernet" $encap] == 0} {
                        # Verify ethernet...
                        set next_object [ixNet getL $stack_object ethernet]
                        if {[llength $next_object] == 0} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Protocol stack contains no ethernet objects."
                            return $returnList
                        }
                    } else {
                        # Verify atm...
                        set next_object [ixNet getL $stack_object atm]
                        if {[llength $next_object] == 0} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Protocol stack contains no atm objects."
                            return $returnList
                        }
                    }
                } else {
                    # Verify ethernet...
                    set next_object_eth [ixNet getL $stack_object ethernet]
                    
                    # Verify atm...
                    set next_object_atm [ixNet getL $stack_object atm]
                    
                    if {[llength $next_object_atm] == 0 && [llength $next_object_eth] == 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Protocol stack contains no ethernet or atm objects."
                        return $returnList
                    }
                    set next_object [concat $next_object_eth $next_object_atm]
                }
                set range_handle_ref_list ""
                foreach next_obj $next_object {
                    set dhcpendpoint_object_list [ixNet getL $next_obj dhcpEndpoint]
                    foreach dhcpendpoint_object $dhcpendpoint_object_list {
                        lappend range_handle_ref_list [ixNet getList $dhcpendpoint_object range]
                    }
                }
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Handle object is of invalid type."
                return $returnList
            }

            # Got a list of range objects. Modify all.

            foreach range_handle_ref $range_handle_ref_list {
                # Use current range handle reference
                lappend range_return_list $range_handle_ref
                # Configure dhcp range params --------------------------------------
                set ixn_dhcp_range_args ""
                foreach {hlt_param ixn_param p_type extensions} $ethernet_endpoint_dhcp_range_params {
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
                                set ixn_param_value $range_options_map($hlt_param_value)
                            }
                            mac {
                                set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                            }
                            list {
                                if {[llength $hlt_param_value] > 1} {
                                    set ixn_param_value [lindex $hlt_param_value 0]
                                    foreach list_item [lrange $hlt_param_value 1 end] {
                                        append ixn_param_value "; $list_item"
                                    }
                                    
                                    set ixn_param_value "\{$ixn_param_value\}"
                                } else {
                                    set ixn_param_value $hlt_param_value
                                }
                            }                    
                        }
                        append ixn_dhcp_range_args "-$ixn_param $ixn_param_value "
                    }
                }
                if {$ixn_dhcp_range_args != ""} {
                    set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                            "$range_handle_ref/dhcpRange"                           \
                            $ixn_dhcp_range_args                                    \
                            -commit                                                 \
                        ]                                 
    
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                }
                if {[llength [ixNet getL ${vport_objref}/protocolStack ethernet]] != 0 } {
                    # Configure dhcp mac range params ----------------------------------
                    set ixn_dhcp_mac_range_args ""
                    foreach {hlt_param ixn_param p_type extensions} $ethernet_endpoint_mac_range_params {
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
                                    set ixn_param_value $range_options_map($hlt_param_value)
                                }
                                mac {
                                    set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                                }                        
                            }
                            append ixn_dhcp_mac_range_args "-$ixn_param \"$ixn_param_value\" "
                        }
                    }
                    if {$ixn_dhcp_mac_range_args != ""} {
                        set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                                "$range_handle_ref/macRange"                            \
                                $ixn_dhcp_mac_range_args                                \
                                -commit                                                 \
                            ]                
                          
                        if {[keylget tmp_status status] != $::SUCCESS} {
                            keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                            return $tmp_status
                        }
                    }            
                   
                    # Configure dhcp vlan range params ---------------------------------
                    set ixn_dhcp_vlan_range_args ""
                    foreach {hlt_param ixn_param p_type extensions} $ethernet_endpoint_vlan_range_params {
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
                                    set ixn_param_value $range_options_map($hlt_param_value)
                                }
                                mac {
                                    set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                                }                        
                            }
                            append ixn_dhcp_vlan_range_args "-$ixn_param $ixn_param_value "
                        }
                    }
                    if {$ixn_dhcp_vlan_range_args != ""} {
                        set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                                "$range_handle_ref/vlanRange"                           \
                                $ixn_dhcp_vlan_range_args                               \
                                -commit                                                 \
                            ]              
                          
                        if {[keylget tmp_status status] != $::SUCCESS} {
                            keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                            return $tmp_status
                        }
                    }
                }
                # Configure ATM PVC range params ----------------------------------
                set atm_pvc_range_args ""
                foreach {hlt_param ixn_param p_type extensions} $atm_pvc_range_params {
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
                                set ixn_param_value $range_options_map($hlt_param_value)
                            }
                            mac {
                                set ixn_param_value [ixNetworkFormatMac $hlt_param_value]
                            }                        
                        }
                        append atm_pvc_range_args "-$ixn_param \"$ixn_param_value\" "
                    }
                }
                 
                if {$atm_pvc_range_args != "" && \
                        [regexp -all {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[-\"0-9a-z]+/dhcpEndpoint:[-\"0-9a-z]+/range:[-\"0-9a-z]+$} $range_handle_ref]} {
                    set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                            "$range_handle_ref/pvcRange"                            \
                            $atm_pvc_range_args                                     \
                            -commit                                                 \
                        ]                
                      
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                }
            } ;# End of foreach range
                                                      
            keylset returnList  handle  $range_handle_ref_list
            keylset returnList  status  $::SUCCESS
        }
    }
	
	# Dhcp globals should exist
	set globals_objs [ixNet getL ::ixNet::OBJ-/globals/protocolStack dhcpGlobals]
	if {[llength $globals_objs] == 0} {
		keylset returnList status $::FAILURE
		keylset returnList log "ERROR in $procName: \
				The dhcp global options object should exist."
		return $returnList
	}
	
	set ixn_global_args ""
	foreach ixn_arg [array names dhcp_globals_params] {
		append ixn_global_args "-$ixn_arg $dhcp_globals_params($ixn_arg) "
	}
	
	if {$ixn_global_args != ""} {
		set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
				[lindex $globals_objs 0]						        \
				$ixn_global_args                                        \
				-commit                                                 \
			]
		if {[keylget tmp_status status] != $::SUCCESS} {
			keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
			return $tmp_status
		}
	}
	
	# Dhcp options should exist
	if {[llength [ixNet getL ${vport_objref}/protocolStack dhcpOptions]] == 0} {
		keylset returnList status $::FAILURE
		keylset returnList log "ERROR in $procName: \
				dhcpOptions object over protocolStack should exist."
		return $returnList
	}
	set options_obj [ixNet getL ${vport_objref}/protocolStack dhcpOptions]
	
	set ixn_options_args ""
	if {![info exists dhcp_options_params(ixn_param_list)]} {
		keylset returnList status $::FAILURE
		keylset returnList log "ERROR in $procName: \
				Internal error. Missing ixn_param_list."
		return $returnList
	}
	foreach ixn_arg $dhcp_options_params(ixn_param_list) {
		if {[info exists dhcp_options_params($vport_objref,$ixn_arg)]} {
			append ixn_options_args "-$ixn_arg $dhcp_options_params($vport_objref,$ixn_arg) "
		}
	}
	
	if {$ixn_options_args != ""} {
		set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
				"$options_obj"                                          \
				$ixn_options_args                                       \
				-commit                                                 \
			]                   
		if {[keylget tmp_status status] != $::SUCCESS} {
			keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
			return $tmp_status
		}
	} 
    return $returnList
}

#-------------------------------------------------------------------------------
proc ::ixia::ixnetwork_dhcp_group_control { args opt_args man_args } {
    
    set procName [lindex [info level [info level]] 0]
    
    if [catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} errorMsg] {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg."
        return $returnList
    }
    
    array set truth {1 true 0 false enable true disable false}

    keylset returnList status $::SUCCESS
    
    # Check to see if a connection to the IxNetwork TCL server already exists.
    # If it doesn't, establish it.
    set return_status [checkIxNetwork]
    if {[keylget return_status status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to \
                IxNetwork [keylget return_status log]"
        return $returnList
    }
    if {![info exists port_handle] && ![info exists handle]} {
        set stack_type_list { ethernet atm }
        set vport_list [ixNet getList [ixNet getRoot] vport]
        set handle_list {}
        foreach vp $vport_list {
            foreach st $stack_type_list {
                set ret_val [::ixia::ixNetworkValidateSMPlugins $vp $st "dhcpEndpoint"]
                if {[keylget ret_val status] == $::SUCCESS && [keylget ret_val summary] == 3} {
                    set handle_list [concat $handle_list [keylget ret_val ret_val]]
                }
            }
        }
        
        if {$handle_list == ""} {
            keylset returnList status $::FAILURE
            keylset returnList log "There are no DHCP emulations on port(s)"
            return $returnList
        }
        
    } elseif {[info exists port_handle]} {
        set handle_list ""
        foreach port $port_handle {
            set retCode [ixNetworkGetPortObjref $port]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
            set port_objref [keylget retCode vport_objref]
            set l2List    [concat \
                    [ixNet getList $port_objref/protocolStack ethernet] \
                    [ixNet getList $port_objref/protocolStack atm]      \
                    ]
            foreach l2Elem $l2List {
                set handle_list [concat $handle_list \
                        [ixNet getList $l2Elem dhcpEndpoint]]
            }
        }
        if {$handle_list == ""} {
            keylset returnList status $::FAILURE
            keylset returnList log "There are no DHCP emulations on port(s)\
                    provided by -port_handle parameter ($port_handle)."
            return $returnList
        }
        
    } else {
        set handle_list ""
        foreach handleElem $handle {
            set dhcpElem [ixNetworkGetParentObjref $handleElem dhcpEndpoint]
            if {$dhcpElem != [ixNet getNull]} {
                lappend handle_list $dhcpElem
            }
        }
        if {$handle_list == ""} {
            keylset returnList status $::FAILURE
            keylset returnList log "Invalid DHCP handles provided by -handle parameter ($handle)."
            return $returnList
        }
    }
    
    array set action_map {
        abort           {   abort          0   {
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/dhcpEndpoint:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/dhcpEndpoint:[^/]+}
                                        }
                        }
        abort_async     {   abort          1   {
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/dhcpEndpoint:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/dhcpEndpoint:[^/]+}
                                        }
                        }
        bind            {   start          0   {
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/dhcpEndpoint:[^/]+/range:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/dhcpEndpoint:[^/]+/range:[^/]+$}
                                        }
                        }
        release         {   stop          0   {
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/dhcpEndpoint:[^/]+/range:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/dhcpEndpoint:[^/]+/range:[^/]+$}
                                                }
                        }
        renew           {   dhcpClientRenew   0   {
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/dhcpEndpoint:[^/]+/range:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/dhcpEndpoint:[^/]+/range:[^/]+$}
                                        }
                        }
    }
    
    foreach handle $handle_list {
        if {[ixNet exists $handle] == "false" || [ixNet exists $handle] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "invalid or incorect -handle."
            return $returnList
        }
        
        foreach regexp_elem [lindex $action_map($action) 2] {
            if {[regexp $regexp_elem $handle handle_temp]} {
                set handle $handle_temp
                break;
            }
        }
        
        foreach action_elem [lindex $action_map($action) 0] {
            set ixNetworkExecParamsAsync [list $action_elem  $handle]
            set ixNetworkExecParamsSync  [list $action_elem  $handle]
            if {[lindex $action_map($action) 1]} {
                lappend ixNetworkExecParamsAsync async
            }
            
            if {[catch {ixNetworkExec $ixNetworkExecParamsAsync} status]} {
                if {[string first "no matching exec found" $status] != -1} {
                    if {[catch {ixNetworkExec $ixNetworkExecParamsSync} status] && \
                            ([string first "::ixNet::OK" $status] == -1)} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to $action DHCP. Returned status: $status"
                        return $returnList
                    }
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to $action DHCP. Returned status: $status"
                    return $returnList
                }
            } else {
                if {[string first "::ixNet::OK" $status] == -1} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to $action DHCP. Returned status: $status"
                    return $returnList
                }
            }
        }
    }
    return $returnList
}

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------"
proc ::ixia::ixnetwork_dhcp_group_stats { args opt_args} {
    set procName [lindex [info level [info level]] 0]
    
    if [catch {::ixia::parse_dashed_args \
            -args           $args        \
            -optional_args  $opt_args    } errorMsg] {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg."
        return $returnList
    }
    
    if {[info exists action] && $action == "clear"} {
        if {[set retCode [catch {ixNet exec clearStats} retCode]]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to clear statistics."
            return $returnList
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    array set truth {1 true 0 false enable true disable false}
    
    # Enter session block for mode session only --------------------------------
    if {[info exists mode] && $mode == "session"} {
#         set stat_list_per_session [list                     \
#             "Session Name"                                  \
#             "Discovers Sent"                                \
#             "Offers Received"                               \
#             "Requests Sent"                                 \
#             "ACKs Received"                                 \
#             "NACKs Received"                                \
#             "Releases Sent"                                 \
#             "Declines Sent"                                 \
#             "IP Address"                                    \
#             "Gateway Address"                               \
#             "Lease Time"                                    \
#             ]
        array set stat_array_per_session [list              \
            "Port Name"                                     \
                port_name                                   \
            "Session Name"                                  \
                session_name                                \
            "Discovers Sent"                                \
                discovers_sent                              \
            "Offers Received"                               \
                offers_received                             \
            "Requests Sent"                                 \
                requests_sent                               \
            "ACKs Received"                                 \
                acks_received                               \
            "NACKs Received"                                \
                nacks_received                              \
            "Releases Sent"                                 \
                releases_sent                               \
            "Declines Sent"                                 \
                declines_sent                               \
            "IP Address"                                    \
                ip_address                                  \
            "Gateway Address"                               \
                gateway_address                             \
            "Lease Time"                                    \
                lease_time                                  \
            "Solicits Sent"                                 \
                solicits_sent                               \
            "Advertisements Received"                       \
                advertisements_received                     \
            "Advertisements Ignored"                        \
                advertisements_ignored                      \
            "Replies Received"                              \
                replies_received                            \
            ]
            
        array set stats_array_per_session_ixn [list                                         \
            interface_id                        "Interface Identitier"                      \
            session_name                        "Session Name"                              \
            port_name                           "Port Name"                                 \
            discovers_sent                      "Discovers Sent"                            \
            offers_received                     "Offers Received"                           \
            requests_sent                       "Requests Sent"                             \
            acks_received                       "ACKs Received"                             \
            nacks_received                      "NACKs Received"                            \
            releases_sent                       "Releases Sent"                             \
            declines_sent                       "Declines Sent"                             \
            ip_address                          "IP Address"                                \
            gateway_address                     "Gateway Address"                           \
            lease_time                          "Lease Time"                                \
            solicits_sent                       "Solicits Sent"                             \
            advertisements_received             "Advertisements Received"                   \
            advertisements_ignored              "Advertisements Ignored"                    \
            replies_received                    "Replies Received"                          \
            ]

        if {![info exists port_handle] && ![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Parameter\
                    -port_handle or -handle must be provided."
            return $returnList
        }
        
        set build_name [list]
        set latest [::ixia::540IsLatestVersion]
        
        
        if {![info exists port_handle]} {
            set port_handle ""
            set vport_objref_handle ""
            foreach handleElem $handle {
                set retCode [ixNetworkGetPortFromObj $handleElem]
                if {[keylget retCode status] == $::FAILURE} {
                    return $retCode
                }
                lappend port_handle         [keylget retCode port_handle]
                lappend vport_objref_handle [keylget retCode vport_objref]
                set proto_regex [ixNet getA $handleElem/dhcpRange -name]
                set current_build_name "SessionView-[string trim [string range $handle [expr [string first "/range:" $handle] + 7] end] "\"\\"]"
                lappend build_name $current_build_name
                if {$latest} {
                    set drill_result [::ixia::CreateAndDrilldownViews $handleElem handle $current_build_name "dhcp" $proto_regex]
                }
            }
        }
        
        if {![info exists handle]} {
            set vport_objref_handle ""
            foreach handleElem $port_handle {
                set retCode [ixNetworkGetPortObjref $handleElem]
                if {[keylget retCode status] == $::FAILURE} {
                    return $retCode
                }
                lappend vport_objref_handle [keylget retCode vport_objref]
                
                lappend build_name "SessionView-[regsub -all "/" $port_handle "_"]"
            }
            if {$latest} {
                set drill_result [::ixia::CreateAndDrilldownViews $port_handle port_handle $build_name "dhcp" "^(dhcp|(?!server).)*\$"]
            }
        }
        
        if {$latest && [keylget drill_result status] == $::FAILURE} {
            return $drill_result
        }
        
        if {$latest} {
            set returned_stats_list [::ixia::540GetStatView $build_name [array names stat_array_per_session]]
            if {[keylget returned_stats_list status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to retrieve '$build_name' stat view."
                return $returnList
            }
        } else {
            set returned_stats_list [ixNetworkGetStats "DHCPv4 Per Session" [array names stat_array_per_session]]
            if {[keylget returned_stats_list status] == $::FAILURE} {
                set returned_stats_list [ixNetworkGetStats \
                        "DHCPv6 Per Session" [array names stat_array_per_session]]
                if {[keylget returned_stats_list status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to retrieve 'DHCPv4/v6 Per Session' stat view."
                    return $returnList
                }
            }
        }
        
        set portIndex 0
        foreach port $port_handle vport_objref $vport_objref_handle {
            set dhcpRangeList ""
            set ethList       [ixNet getList $vport_objref/protocolStack ethernet]
            set atmList       [ixNet getList $vport_objref/protocolStack atm]
            set l2List        [concat $ethList $atmList]
            foreach l2Elem $l2List {
                set endpointList [ixNet getList $l2Elem dhcpEndpoint]
                foreach endpointElem $endpointList {
                    set rangeList [ixNet getList $endpointElem range]
                    foreach rangeElem $rangeList {
                        set dhcpRangeList [concat $dhcpRangeList [ixNet getList $rangeElem dhcpRange]]
                    }
                }
            }
            
            set found false
            
            if {$latest} {
                set pageCount [keylget returned_stats_list page]
                set rowCount  [keylget returned_stats_list row]
                array set rowsArray [keylget returned_stats_list rows]
                
                # Populate statistics
                for {set i 1} {$i < $pageCount} {incr i} {
                    for {set j 1} {$j < $rowCount} {incr j} {
                        if {![info exists rowsArray($i,$j)]} { continue }
                        set rowName $rowsArray($i,$j)
                        
                        set matched [regexp {(.+)/Card([0-9]+)/Port([0-9]+) - ([0-9]+)$} $rowName matched_str hostname cd pt session_no]
                        
                        if {$matched && [catch {set ch_ip [keylget ::ixia::hosts_to_ips $hostname]} err]} {
                            set ch_ip $hostname
                        }
                        
                        if {!$matched} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to get 'Port Statistics',\
                                    because port number could not be identified. $rowName did not\
                                    match the HLT port format ChassisIP/card/port. This can occur if\
                                    the test was not configured with HLT."
                            return $returnList
                        }
                        
                        if {$matched && ([string first $matched_str $rowName] == 0) && \
                                [info exists ch_ip] && [info exists cd] && [info exists pt] } {
                            set ch [ixNetworkGetChassisId $ch_ip]
                        }
                        set cd [string trimleft $cd 0]
                        set pt [string trimleft $pt 0]
                        set statPort $ch/$cd/$pt
                        
                        if {"$port" eq "$statPort"} {
                            set found true
                            foreach stat [array names stats_array_per_session_ixn] {
                                set ixn_stat $stats_array_per_session_ixn($stat)
                                if {[info exists rowsArray($i,$j,$ixn_stat)] && $rowsArray($i,$j,$ixn_stat) != ""} {
                                    keylset returnList session.$statPort/${session_no}.$stat $rowsArray($i,$j,$ixn_stat)
                                } else {
                                    keylset returnList session.$statPort/${session_no}.$stat "N/A"
                                }
                            }
                        }
                    }
                }
            } else {
                set row_count [keylget returned_stats_list row_count]
                array set rows_array [keylget returned_stats_list statistics]
        
                for {set i 1} {$i <= $row_count} {incr i} {
                    set row_name $rows_array($i)
                    set match [regexp {(.+)/Card(\d+)/Port(\d+) - (\d+)$} \
                            $row_name match_name hostname card_no port_no session_no]
                    if {$match && [catch {set chassis_ip [keylget ::ixia::hosts_to_ips $hostname]} err]} {
                        set chassis_ip $hostname
                    }
                    if {$match && ($match_name == $row_name) && \
                            [info exists chassis_ip] && [info exists card_no] && \
                            [info exists port_no] && [info exists session_no]} {
                        set chassis_no [ixia::ixNetworkGetChassisId $chassis_ip]
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
                        foreach stat [array names stat_array_per_session] {
                            if {[info exists rows_array($i,$stat)] && \
                                    $rows_array($i,$stat) != ""} {
                                
                                keylset returnList session.${session_no}.$stat_array_per_session($stat) \
                                        $rows_array($i,$stat)
                                
                                
                            } else {
                                keylset returnList session.${session_no}.$stat_array_per_session($stat) "N/A"
                            }
                            keylset returnList session.${session_no}.dhcp_group  "N/A"
                            if {$stat_array_per_session($stat) == "session_name"} {
                                set dhcpRangeName [lindex [split $rows_array($i,$stat) :] 0]
                                foreach dhcpRangeElem $dhcpRangeList {
                                    if {[ixNet getAttribute $dhcpRangeElem -name] == $dhcpRangeName} {
                                        keylset returnList session.${session_no}.dhcp_group \
                                                [ixNetworkGetParentObjref $dhcpRangeElem range]
                                    }
                                }
                            }
                            keylset returnList session.${session_no}.port_handle $port
                        }
                        #break - don't break! We need stats from every session available on this port.
                    }
                }
            } ;# version NOT latest ends
            if {!$found} {
                keylset returnList status $::FAILURE
                keylset returnList log "The '$port' port couldn't be\
                        found among the ports from which statistics were\
                        gathered."
                return $returnList
            }
            incr portIndex
        } ;# foreach port ends
        keylset returnList status $::SUCCESS
        return $returnList
    } ;# Session block ends ----------------------------------------------------
    
    # Dhcp Group Statistics
    set stat_list_dhcpv4 {  
        "Port Name"
                port_name
        "Sessions Initiated"                        
                currently_attempting
        "Sessions Failed"                           
                currently_idle
        "Sessions Succeeded"                        
                currently_bound
        "Discovers Sent"                            
                discover_tx_count
        "Requests Sent"                             
                request_tx_count
        "Releases Sent"                             
                release_tx_count
        "Offers Received"                           
                offer_rx_count
        "ACKs Received"                             
                ack_rx_count
        "NACKs Received"                             
                nak_rx_count
        "Declines Sent"                             
                declines_tx_count
        "Enabled Interfaces"                        
                enabled_interfaces
        "Addresses Discovered"
                addr_discovered
        "Setup Initiated"                           
                setup_initiated
        "Setup Success"                             
                setup_success
        "Setup SuccessRate"                         
                setup_success_rate
        "Setup Fail"                                
                setup_fail
        "Teardown Initiated"                        
                teardown_initiated
        "Teardown Success"                          
                teardown_success
        "Teardown Failed"                                           
                teardown_failed
    }  
                
    set stat_list_dhcpv6 {        
         "Port Name"
                port_name
         "Sessions Initiated"
                currently_attempting                        
         "Sessions Failed"
                currently_idle
         "Sessions Succeeded"
                currently_bound
         "Solicits Sent"
                solicits_tx_count
         "Advertisements Received"
                adv_rx_count
         "Advertisements Ignored"
                adv_ignored
         "Requests Sent"
                request_tx_count
         "Addresses Discovered"
                addr_discovered
         "Enabled Interfaces"
                enabled_interfaces
         "Replies Received"
                reply_rx_count
         "Releases Sent"
                release_tx_count
         "Setup Initiated"
                setup_initiated
         "Setup Success"
                setup_success
         "Setup Success Rate"
                setup_success_rate
         "Setup Fail"
                setup_fail
         "Teardown Initiated"
                teardown_initiated
         "Teardown Success"
                teardown_success
         "Teardown Fail"
                teardown_fail
     }  
    
    set statistic_types [list                                       \
        dhcpv4      "DHCPv4"                                        \
        dhcpv6      "DHCPv6"                                        \
        ]

    array set statViewBrowserNamesArray $statistic_types
    set statViewBrowserNamesList ""
    foreach stat_type [array names statViewBrowserNamesArray] {
        lappend statViewBrowserNamesList $statViewBrowserNamesArray($stat_type)
    }
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
        foreach {stat_type stat_name} $statistic_types {
            set stats_list_name  stat_list_${stat_type}
            set stats_array_name stats_array_${stat_type}
            array set $stats_array_name [set $stats_list_name]
            set stats_list [array names $stats_array_name]
            
            array set stats_array [array get $stats_array_name]
            set returned_stats_list [ixNetworkGetStats \
                    $stat_name $stats_list]
            if {[keylget returned_stats_list status] == $::FAILURE} {
                  continue
            }
            
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
                        set return_key ""
                        if {$stat_type == "ipv6"} {
                            set return_key "ipv6."
                        }
                        set return_port_key ${return_key}${port}.aggregate.$stats_array($stat)
                        set return_key      ${return_key}aggregate.$stats_array($stat)
                            
                        if {[info exists rows_array($i,$stat)] && \
                                $rows_array($i,$stat) != ""} {
                            
                            keylset returnList $return_port_key $rows_array($i,$stat)
                            if {$index == 1} {
                                keylset returnList $return_key $rows_array($i,$stat)
                            }
                        } else {
                            keylset returnList $return_port_key "N/A"
                            if {$index == 1} {
                                keylset returnList $return_key "N/A"
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
    
    if {![catch {keylget returnList aggregate.currently_bound} currently_bound] && \
            ![catch {keylget returnList aggregate.currently_attempting} currently_attempting] } {
        if {$currently_attempting != "N/A" && $currently_bound != "N/A"} {
            if {$currently_attempting == 0} {
                keylset returnList aggregate.success_percentage 0
            } else {
                keylset returnList aggregate.success_percentage  \
                        [mpexpr 1. * $currently_bound / $currently_attempting * 100]
            }
        } else {
            keylset returnList aggregate.success_percentage "N/A"
        }
    }
    foreach key [keylkeys returnList] {
        if {[regexp {[0-9]+/[0-9]+/[0-9]+} $key]} {
            if {![catch {keylget returnList $key.aggregate.currently_bound} currently_bound] && \
                    ![catch {keylget returnList $key.aggregate.currently_attempting} currently_attempting] } {
                if {$currently_attempting != "N/A" && $currently_bound != "N/A"} {
                    if {$currently_attempting == 0} {
                        keylset returnList $key.aggregate.success_percentage 0
                    } else {
                        keylset returnList $key.aggregate.success_percentage  \
                                [mpexpr 1. * $currently_bound / $currently_attempting * 100]
                    }
                } else {
                    keylset returnList $key.aggregate.success_percentage "N/A"
                }
            }
        }
    }
        
    keylset returnList status $::SUCCESS
    return $returnList
}
#-------------------------------------------------------------------------------
proc ::ixia::ixnetwork_is_node_type {node_object what_type} {
    # supported types: vport dhcpEndpoint range
    if {$what_type == "range"} {
        return [expr \
                [regexp -all {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[-"0-9a-z]+/dhcpEndpoint:[-"0-9a-z]+/range:[-"0-9a-z]+$} $node_object] || \
                [regexp -all {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[-"0-9a-z]+/dhcpEndpoint:[-"0-9a-z]+/range:[-"0-9a-z]+$} $node_object] \
                ]
    } elseif {$what_type == "dhcpEndpoint"} {
        return [expr \
                [regexp -all {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[-"0-9a-z]+/dhcpEndpoint:[-"0-9a-z]+$} $node_object] || \
                [regexp -all {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[-"0-9a-z]+/dhcpEndpoint:[-"0-9a-z]+$} $node_object] \
                ]
    } elseif {$what_type == "vport"} {
        return [regexp -all {^::ixNet::OBJ-/vport:\d+$} $node_object]
    } else {
        return 0
    }
    return 0
}
