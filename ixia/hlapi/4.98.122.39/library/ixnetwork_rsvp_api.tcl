##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_rsvp_api.tcl
#
# Purpose:
#     A script development library containing RSVP APIs for test automation with 
#     the Ixia chassis.
#
# Author:
#    Radu Antonescu
#
# Usage:
#    package req Ixia
#
# Description:
#    The procedures contained within this library include:
#    - ixnetwork_rsvp_config
#    - ixnetwork_rsvp_tunnel_config
#    - ixnetwork_rsvp_control
#    - ixnetwork_rsvp_info
#    - ixnetwork_rsvp_tunnel_info
#
# Requirements:
#     ixiaapiutils.tcl , a library containing TCL utilities
#     parseddashedargs.tcl , a library containing the proceDescr and 
#     parsedashedargds.tcl
#
# Variables:
#    To be added
#
# Keywords:
#    To be define
#
# Category:
#    To be define
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

proc ::ixia::ixnetwork_rsvp_config {args man_args opt_args} {
    variable objectMaxCount

    set objectCount 0

    if {[catch {::ixia::parse_dashed_args \
            -args           $args         \
            -optional_args  $opt_args     \
            -mandatory_args $man_args} parseError]} {
        
        keylset returnList status $::FAILURE
        keylset returnList log $parseError
        return $returnList
    }
    
    # Check to see if a connection to the IxNetwork TCL Server already exists. 
    # If it doesn't, establish it.
    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    
    if {[info exists vlan] && $vlan == 0} {
        catch {unset vlan_id}
    }
    
    if {![info exists ip_version]} {
        set ip_version 4
    }
    if {$mode == "create" || $mode == "modify"} {
        catch {set refresh_reduction [expr $refresh_reduction || $reliable_delivery \
                || $bundle_msgs || $summary_refresh]}
        set rsvp_param_list {
                intf_ip_addr                    ourIp
                neighbor_intf_ip_addr           dutIp
                hello_interval                  helloInterval
                hello_retry_count               helloTimeoutMultiplier
                min_label_value                 labelSpaceStart
                max_label_value                 labelSpaceEnd
                srefresh_interval               summaryRefreshInterval
                graceful_restart_start_time     gracefulRestartStartTime
                graceful_restart_up_time        gracefulRestartUpTime
                graceful_restarts_count         numberOfGracefulRestarts
                actual_restart_time             actualRestartTime
                graceful_restart_recovery_time  recoveryTimeInterval
                graceful_restart_restart_time   restartTimeInterval
                hello_tlvs                      helloTlvs
                bfd_registration                enableBfdRegistration
                bundle_msg_sending              enableBundleMessageSending
                graceful_restart_helper_mode    enableGracefulRestartHelperMode
            }
        set rsvp_param_list_flags {
                hello_msgs              enableHello
                refresh_reduction       refreshReduction
                graceful_restart        enableGracefulRestartingMode
            }
    
        if {[info exists hello_tlvs] && $hello_tlvs != ""} {
            foreach hello_tlv_item $hello_tlvs {
                foreach single_hello_tlv_item [split $hello_tlv_item ":"] {
                    if {![regexp -all {^[0-9]+,[0-9]+,[0-9A-Fa-f]+$} $single_hello_tlv_item]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Invalid hello_tlvs item: $single_hello_tlv_item. Accepted \
                                values are {^\[0-9\]+,\[0-9\]+,\[0-9A-Fa-f \]+$}."
                        return $returnList
                    }
                }
            }
        }
        
    }
    if {[info exists reset] && ($mode == "create")} {
        set port $::ixia::ixnetwork_port_handles_array($port_handle)
        debug "ixNet getList $port/protocols/rsvp neighborPair"
        set pairs_list [ixNet getList $port/protocols/rsvp neighborPair]
        foreach pairs $pairs_list {
            debug "ixNet remove $pairs"
            ixNet remove $pairs
        }
        debug "ixNet commit"
        ixNet commit
    }

    # setting tunnel option parameter that will be used in rsvp_tunnel_config
    variable rsvp_tunnel_parameters
    set rsvpOptions {
        refresh_interval
        refresh_retry_count
        path_state_refresh_timeout
        path_state_timeout_count
        record_route
        resv_confirm
        resv_state_refresh_timeout
        resv_state_timeout_count
        egress_label_mode
    }
    
    switch -exact -- $mode {
        create {
            if {![info exists intf_ip_addr]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -mode is $mode, parameter\
                        intf_ip_addr must be provided."
                return $returnList
            }
            if {![info exists gateway_ip_addr]} {
                set gateway_ip_addr        $neighbor_intf_ip_addr
                set gateway_ip_addr_step   $neighbor_intf_ip_addr_step
            }
            # param lists
            set intf_list_params {
                port_handle                 port_handle
                intf_ip_addr                ipv4_address
                intf_ip_addr_step           ipv4_address_step
                intf_prefix_length          ipv4_prefix_length
                gateway_ip_addr             gateway_address
                gateway_ip_addr_step        gateway_address_step
                count                       count
                mac_address_init            mac_address
                mac_address_step            mac_address_step
                atm_encapsulation           atm_encapsulation
                vci                         atm_vci
                vci_step                    atm_vci_step
                vpi                         atm_vpi
                vpi_step                    atm_vpi_step
                vlan                        vlan_enabled
                vlan_id                     vlan_id
                vlan_id_mode                vlan_id_mode
                vlan_id_step                vlan_id_step
                vlan_user_priority          vlan_user_priority
                override_existence_check    override_existence_check
                override_tracking           override_tracking
            }
            
            if {![info exists port_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -mode is $mode, parameter\
                        port_handle must be provided."
                return $returnList
            }
            
            if {![info exists interface_handle]} {
                set intf_command "::ixia::ixNetworkProtocolIntfCfg "
                foreach {param cmd} $intf_list_params {
                    if {[info exists $param]} {
                        append intf_command "-$cmd [set $param] "
                    }
                }
                set retCode [catch {set retList [eval $intf_command]} errroMsg]
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to create protocol\
                            interfaces. $errroMsg"
                    return $returnList
                }
                if {[keylget retList status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log [keylget retList log]
                    return $returnList
                }
                set intf_list [keylget retList connected_interfaces]
                if {[llength $intf_list] < $count} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to create all protocol\
                            interfaces."
                    return $returnList
                }
                set get_ip false
            } else {
                set intf_list $interface_handle
                set get_ip true
            }
            set port $::ixia::ixnetwork_port_handles_array($port_handle)
            # Check if protocols are supported
            set retCode [checkProtocols $port]
            if {[keylget retCode status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Port $port_handle does not support protocol\
                        configuration."
                return $returnList
            }
            # setting RSVP
            debug "ixNet setAttr $port/protocols/rsvp -enabled true"
            ixNet setAttr $port/protocols/rsvp -enabled true
            
            if {[info exists enable_bgp_over_lsp] && $enable_bgp_over_lsp == 1} {
                debug "ixNet setAttr $port/protocols/rsvp -enableBgpOverLsp true"
                ixNet setAttr $port/protocols/rsvp -enableBgpOverLsp true
            } else {
                debug "ixNet setAttr $port/protocols/rsvp -enableBgpOverLsp false"
                ixNet setAttr $port/protocols/rsvp -enableBgpOverLsp false
            }
            
            # create command blocks for static flags parameters
            set flag_command [list]
            foreach {param cmd} $rsvp_param_list_flags {
                if {[info exists $param] && [set $param] == 1} {
                    switch -- [set $param] {
                        0 {set value false}
                        1 {set value true}
                    }
                    debug "ixNet setAttr \$neighPairs -$cmd $value"
                    append flag_command "ixNet setAttr \$neighPairs -$cmd $value;"
                }
            }
            # create command blocks for static value parameters
            set value_command [list]
            foreach {param cmd} $rsvp_param_list {
                if {[info exists $param]} {
                    if {$param == "hello_tlvs"} {
                        debug "ixNet setAttr \$neighPairs -$cmd \{[split [split [set $param] ,] :]\}"
                        append value_command \
                                "ixNet setAttr \$neighPairs -$cmd \{[split [split [set $param] ,] :]\};"
                    } else {
                        debug "ixNet setAttr \$neighPairs -$cmd [set $param]"
                        append value_command \
                                "ixNet setAttr \$neighPairs -$cmd \[set $param\];"
                    }
                }
            }
            set rsvpte {}
            foreach intf $intf_list {
                if {$get_ip == true} {
                    debug "ixNet getList $intf ipv4"
                    set ip [ixNet getList $intf ipv4]
                    if {$ip != ""} {
                        debug "ixNet getAttr $ip -ip"
                        set intf_ip_addr [ixNet getAttr $ip -ip]
                        debug "ixNet getAttr $ip -gateway"
                        if {![info exists neighbor_intf_ip_addr] || [is_default_param_value neighbor_intf_ip_addr $args]} {
                            set neighbor_intf_ip_addr [ixNet getAttr $ip -gateway]
                        }
                        set gateway_ip_addr       [ixNet getAttr $ip -gateway]
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "The specified interface handles\
                                have no IPv4 items."
                        return $returnList
                    }
                }
                debug "ixNet add $port/protocols/rsvp neighborPair"
                set neighPairs [ixNet add $port/protocols/rsvp neighborPair]
                debug "ixNet setAttr $neighPairs -enabled true"
                ixNet setAttr $neighPairs -enabled true
                # setting flags params
                eval [subst $flag_command]
                #setting value parameters
                debug [subst $value_command]
                eval [subst $value_command]
                incr objectCount
                if { $objectCount == $objectMaxCount} {
                    debug "ixNet commit"
                    ixNet commit
                    set objectCount 0
                }
                if {[info exists intf_ip_addr_step]} {
                    set intf_ip_addr [::ixia::increment_ipv4_address_hltapi \
                            $intf_ip_addr $intf_ip_addr_step]
                }
                if {[info exists neighbor_intf_ip_addr_step]} {
                    set neighbor_intf_ip_addr [ \
                            ::ixia::increment_ipv4_address_hltapi \
                            $neighbor_intf_ip_addr $neighbor_intf_ip_addr_step]
                }
                lappend rsvpte $neighPairs
            }
            if {$objectCount > 0} {
                debug "ixNet commit"
                ixNet commit
            }
            
            if {[llength $rsvpte] > 0} {
                debug "ixNet remapIds $rsvpte"
                set rsvpte [ixNet remapIds $rsvpte]
                foreach neighPairs $rsvpte intf_item $intf_list {
                    #prepare tunnel parameters for emulation_rsvp_tunnel_config
                    foreach tunOpt $rsvpOptions {
                        if {[info exists $tunOpt]} {
                            lappend rsvp_tunnel_parameters($neighPairs) $tunOpt
                            lappend rsvp_tunnel_parameters($neighPairs) [set $tunOpt]
                        }
                    }
                    lappend rsvp_tunnel_parameters($neighPairs) intf_handle
                    lappend rsvp_tunnel_parameters($neighPairs) $intf_item
                    
                    if {$get_ip != true} {
                        keylset returnList router_interface_handle.$neighPairs $intf_item
                    }
                }
                keylset returnList handles $rsvpte
            }
        }
        delete {
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -mode is $mode, parameter\
                        -handle must be provided."
                return $returnList
            }
            foreach item $handle {
                debug "ixNet remove $item"
                ixNet remove $item
            }
            debug "ixNet commit"
            ixNet commit

            keylset returnList handles $handle
        }
        disable {
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -mode is $mode, parameter\
                        -handle must be provided."
                return $returnList
            }
            foreach item $handle {
                debug "ixNet setAttr $item -enabled false"
                ixNet setAttr $item -enabled false
            }
            debug "ixNet commit"
            ixNet commit

            keylset returnList handles $handle
        }
        enable {
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -mode is $mode, parameter\
                        -handle must be provided."
                return $returnList
            }
            foreach item $handle {
                debug "ixNet setAttr $item -enabled true"
                ixNet setAttr $item -enabled true
            }
            debug "ixNet commit"
            ixNet commit

            keylset returnList handles $handle
        }
        modify {
            removeDefaultOptionVars $opt_args $args
            if {[info exists refresh_interval]} {
        
                if {![info exists path_state_refresh_timeout]} {
                    set path_state_refresh_timeout $refresh_interval
                }
                if {![info exists resv_state_refresh_timeout]} {
                    set resv_state_refresh_timeout $refresh_interval
                }
            }
    
            if {[info exists refresh_retry_count]} {
                if {![info exists path_state_timeout_count]} {
                    set path_state_timeout_count $refresh_retry_count
                }
                if {![info exists resv_state_timeout_count]} {
                    set resv_state_timeout_count $refresh_retry_count
                }
            }

            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "handle must be \
                        specified in modify mode."
                return $returnList
            }
            if {![info exists gateway_ip_addr]} {
                if {[info exists neighbor_intf_ip_addr] && ![is_default_param_value neighbor_intf_ip_addr $args]} {
                    set gateway_ip_addr $neighbor_intf_ip_addr
                }
            }
            set intf_param_list {
                intf_ip_addr                    ipv4_address
                gateway_ip_addr                 gateway_address
                intf_prefix_length              ipv4_prefix_length
                vci                             atm_vci
                vpi                             atm_vpi
                atm_encapsulation               atm_encapsulation
                vlan                            vlan_enabled
                vlan_id                         vlan_id
                vlan_user_priority              vlan_user_priority
                mac_address_init                mac_address
            }
            set rsvpTunnelOptions {
                refresh_interval             refreshInterval    destinationRange/ingress/senderRange
                refresh_retry_count          timeoutMultiplier  destinationRange/ingress/senderRange
                path_state_refresh_timeout   refreshInterval    destinationRange/ingress/senderRange
                path_state_timeout_count     timeoutMultiplier  destinationRange/ingress/senderRange
                resv_state_refresh_timeout   refreshInterval    destinationRange/egress
                resv_state_timeout_count     timeoutMultiplier  destinationRange/egress
                egress_label_mode            labelValue         destinationRange/egress
                record_route                 reflectRro         destinationRange/egress
                resv_confirm                 sendResvConfirmation    destinationRange/egress
                enableFixedLabelForResv      enableFixedLabelForResv destinationRange/egress
            }
            set option_index 0
            set handle_no [llength $handle]
            foreach handle_item $handle {
                # Modify interface
                if {[info exists ::ixia::rsvp_tunnel_parameters($handle_item)]} {
                    array set rsvp_param $::ixia::rsvp_tunnel_parameters($handle_item)
                    set intf_handle $rsvp_param(intf_handle)
                    set retCode [ixia::ixNetworkGetPortFromObj $handle_item]
                    if {[keylget retCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "invalid object \
                                specified $handle_item."
                        return $returnList
                    }
                    set port_handle [keylget retCode port_handle]
                    if {[string equal $port_handle ""]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "invalid \
                                interface handle found."
                        return $returnList
                    }
                    
                    set ixn_port_handle [::ixia::ixNetworkGetPortObjref $port_handle]
                    if {[keylget ixn_port_handle status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Port handle $port_handle was not registered \
                                in IxNetwork. Verify if -handle $handle_item is valid."
                        return $returnList
                    }
                    set ixn_port_handle [keylget ixn_port_handle vport_objref]
                    
                    set intf_cmd_modify ""
                    foreach {hlt_param intf_param} $intf_param_list {
                        if {[info exists $hlt_param]} {
                            set option_value_list [set $hlt_param]
                            if {[llength $option_value_list] == 1} {
                                set option_value $option_value_list
                            } elseif {[llength $option_value_list] == \
                                    $handle_no} {
                                set option_value [lindex $option_value_list \
                                        $option_index]
                                debug "$hlt_param=$option_value"
                            } else {
                                debug "debug: option_value_list = $option_value_list"
                                debug "debug: handle_no = $handle_no"
                                keylset returnList status $::FAILURE
                                keylset returnList log "list\
                                        length mismatch."
                                return $returnList
                            }
                            append intf_cmd_modify " -$intf_param $option_value"
                        }
                    }
                    if {![string equal $intf_cmd_modify ""]} {
                        set intf_cmd_modify "::ixia::ixNetworkConnectedIntfCfg \
                                -prot_intf_objref $intf_handle -port_handle \
                                $port_handle $intf_cmd_modify"
                        if {[catch {set retCode [eval $intf_cmd_modify]} errorMsg]} {
                            debug "debug: $intf_cmd_modify"
                            keylset returnList status $::FAILURE
                            keylset returnList log "$errorMsg."
                            return $returnList
                        }
                        if {[keylget retCode status] != $::SUCCESS} {
                            return $retCode
                        }
                    }
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "handle \
                            $handle_item does not exists in internal structure."
                    return $returnList
                }
                # Setting tunnel parameters
                foreach param $rsvpOptions {
                    if {[info exists $param]} {
                        set $param [set $param]
                        set rsvp_param($param) [set $param]
                    }
                }
                catch {
                    unset objref_path_array
                    array set objref_path_array {}
                }
                
                # this sequence should create an array with objects needed by 
                # tunnel parameters configuration from emulation_rsvp_config
                foreach path_item {destinationRange/ingress/senderRange \
                        destinationRange/egress} {
                    # begin creating tree from neighborPair object as root
                    set obj_list $handle_item
                    foreach obj_name [split $path_item /] {
                        set new_list [list]
                        # create next level in tree
                        foreach obj_item $obj_list {
                            append new_list "[ixNet getList $obj_item $obj_name] "
                        }
                        # set current level to next level
                        set obj_list $new_list
                    }
                    set objref_path_array($path_item) $obj_list
                }
                
                set ::ixia::rsvp_tunnel_parameters($handle_item) \
                        [array get rsvp_param]
                foreach {hlt_param ixn_param path} $rsvpTunnelOptions {
                    if {[info exists $hlt_param]} {
                        if {[llength [set $hlt_param]] == 1} {
                            set value [set $hlt_param]
                        } elseif {[llength [set $hlt_param]] == $handle_no} {
                            set value [lindex [set $hlt_param] $option_index]
                        } else {
                            debug "debug: $hlt_param = [set $hlt_param]"
                            debug "debug: handle_no = $handle_no"
                            keylset returnList status $::FAILURE
                            keylset returnList log "list \
                                    value mismatch."
                            return $returnList
                        }
                        switch -exact -- $value {
                            nextlabel {
                                set value routerAlert
                            }
                            imnull {
                                set value implicitNull
                                set enableFixedLabelForResv 1
                            }
                            exnull {
                                set value explicitNull
                                set enableFixedLabelForResv 1
                            }
                        }
                        foreach obj_item $objref_path_array($path) {
                            debug "ixNet setAttr $obj_item -$ixn_param $value"
                            ixNet setAttr $obj_item -$ixn_param $value
                        }
                    }
                }
                # setting flags params
                foreach {param flag} $rsvp_param_list_flags {
                    if {[info exists $param]} {
                        if {[llength [set $param]] == 1} {
                            set value [set $param]
                        } elseif {[llength [set $param]] == $handle_no} {
                            set value [lindex [set $param] $option_index]
                        } else {
                            debug "debug: $hlt_param = [set $hlt_param]"
                            debug "debug: handle_no = $handle_no"
                            keylset returnList status $::FAILURE
                            keylset returnList log "list \
                                    $param length mismatch."
                            return $returnList
                        }
                        catch {
                            if {$value == 1} {
                                debug "ixNet setAttr $handle_item -$flag true"
                                ixNet setAttr $handle_item -$flag true
                            } else {
                                debug "ixNet setAttr $handle_item -$flag false"
                                ixNet setAttr $handle_item -$flag false
                            }
                        } retCode
                        if {[regexp "^failure" $retCode]} {
                            debug "debug: $param = [set $param]"
                            debug "debug: handle_no = $handle_no"
                            keylset returnList status $::FAILURE
                            keylset returnList log "ixNet \
                                setAttr $handle_item -$flag true/false"
                            return $returnList
                        }
                    }
                }
                
                if {[info exists enable_bgp_over_lsp]} {
                    if {[llength $enable_bgp_over_lsp] == 1} {
                        set value $enable_bgp_over_lsp
                    } elseif {[llength $enable_bgp_over_lsp] == $handle_no} {
                        set value [lindex $enable_bgp_over_lsp $option_index]
                    }
                    if [catch {
                                if {$value == 1} {
                                    debug "ixNet setAttr $ixn_port_handle/protocols/rsvp -enableBgpOverLsp true"
                                    ixNet setAttr $ixn_port_handle/protocols/rsvp -enableBgpOverLsp true
                                } else {
                                    debug "ixNet setAttr $ixn_port_handle/protocols/rsvp -enableBgpOverLsp false"
                                    ixNet setAttr $ixn_port_handle/protocols/rsvp -enableBgpOverLsp false
                                }
                            } retCode] {
                        debug "debug: enable_bgp_over_lsp = $enable_bgp_over_lsp"
                        debug "debug: handle_no = $handle_no"
                        keylset returnList status $::FAILURE
                        keylset returnList log "ixNet \
                            setAttr $ixn_port_handle/protocols/rsvp -enableBgpOverLsp true/false; $retCode"
                        return $returnList
                    }
                }
                                
                foreach {param cmd} $rsvp_param_list {
                    if {[info exists $param]} {
                        if {[llength [set $param]] == 1} {
                            set value [set $param]
                        } elseif {[llength [set $param]] == $handle_no} {
                            set value [lindex [set $param] $option_index]
                        } else {
                            debug "debug: $param = [set $param]"
                            debug "debug: handle_no = $handle_no"
                            keylset returnList status $::FAILURE
                            keylset returnList log "list \
                                    $param length mismatch."
                            return $returnList
                        }
                        if {$param == "hello_tlvs"} {
                            debug "ixNet setAttr $handle_item -$cmd [split [split $value ,] :]"
                            if [catch {ixNet setAttr $handle_item -$cmd [split [split $value ,] :]}] {
                                keylset returnList status $::FAILURE 
                                keylset returnList log "cannot set \
                                    ixNet setAttr $handle_item -$cmd $value"
                                return $returnList
                            }
                        } else {
                            debug "ixNet setAttr $handle_item -$cmd $value"
                            if [catch {ixNet setAttr $handle_item -$cmd $value}] {
                                keylset returnList status $::FAILURE 
                                keylset returnList log "cannot set \
                                    ixNet setAttr $handle_item -$cmd $value"
                                return $returnList
                            }
                        }
                    }
                }
                
                incr option_index
            }
            debug "ixNet commit"
            ixNet commit

            keylset returnList handles $handle
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::ixnetwork_rsvp_tunnel_config {args man_args opt_args} {
    variable objectMaxCount
    variable rsvp_tunnel_parameters

    set objectCount 0
    set procName [lindex [info level [info level]] 0]

    if {[catch {::ixia::parse_dashed_args \
            -args           $args         \
            -optional_args  $opt_args     \
            -mandatory_args $man_args     } parseError]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parseError"
        return $returnList
    }
    
    # Check to see if a connection to the IxNetwork TCL Server already exists. 
    # If it doesn't, establish it.
    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    
    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
    }
    
    if {$mode == "create" || $mode == "modify"} {
        if {$mode == "create" && ![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode, parameter -handle\
                    must be provided."
            return $returnList
        }
        variable rsvp_tunnel_parameters
        set rsvpOptions {
            refresh_interval
            refresh_retry_count
            path_state_refresh_timeout
            path_state_timeout_count
            resv_state_refresh_timeout
            resv_state_timeout_count
            egress_label_mode
        }
        
        set rsvpOptionsFlag {
            record_route
            resv_confirm
        }
        if {$mode == "create" && [info exists rsvp_tunnel_parameters($handle)]} {
            foreach {param value} $rsvp_tunnel_parameters($handle) {
                if {![info exists $param]} {
                    if {[lsearch $rsvpOptionsFlag $param] == -1} {
                        set $param $value
                    } else {
                        if {$value == 1} {
                            set $param true
                        } else {
                            set $param false
                        }
                    }
                }
            }
        }
        
        if {![info exists rro] && [info exists record_route]} {
            set rro $record_route
        }

        if {[info exists refresh_interval]} {
            if {![info exists path_state_refresh_timeout]} {
                set path_state_refresh_timeout $refresh_interval
            }
            if {![info exists resv_state_refresh_timeout]} {
                set resv_state_refresh_timeout $refresh_interval
            }
        }

        if {[info exists refresh_retry_count]} {
            if {![info exists path_state_timeout_count]} {
                set path_state_timeout_count $refresh_retry_count
            }
            if {![info exists resv_state_timeout_count]} {
                set resv_state_timeout_count $refresh_retry_count
            }
        }
        
        # setting ERO
        if {[info exists ero] && $ero == 1} {
            if {$ero_list_type == "as" && (![info exists ero_list_as_num])} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -ero_list_type is |as| parameter\
                        -ero_list_as_num must be provided."
                return $returnList
            } elseif {$ero_list_type == "ipv4" && (![info exists ero_list_ipv4])} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -ero_list_type is |ipv4| parameter\
                        -ero_list_ipv4 must be provided."
                return $returnList
            }
            set ero_list {}
            if {[info exists ero_list_loose]} {
                set i 0
                foreach ero_loose $ero_list_loose {
                    if {![info exists ero_list_pfxlen]} {
                        set ero_list_pfxlen 32
                    } elseif {[lindex $ero_list_pfxlen $i] == ""} {
                        lappend ero_list_pfxlen 32
                    }
                    if {[lindex $ero_list_loose $i] == 1} {
                        set loose True
                    } else {
                        set loose False
                    }
                    if {$ero_list_type == "as"} {
                        lappend ero_list [list as \
                            [lindex $ero_list_as_num $i] \
                            [lindex $ero_list_pfxlen $i] \
                            $loose ]
                    } else {
                        lappend ero_list [list ip \
                            [lindex $ero_list_ipv4 $i] \
                            [lindex $ero_list_pfxlen $i] \
                            $loose ]
                    }
                    incr i
                }
            }
            if {$ero_list == ""} {
                unset ero_list
            } elseif {$mode == "create"} {
                set ero_list [list $ero_list]
            }
        }
        # setting RRO params
        if {![info exists rro_list_ctype]} {
            set rro_list_ctype 0
        }
        if {[info exists rro_list_flags] && [info exists rro]} {
            if {![info exists rro_list_type]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When parameters -rro_list_flags\
                        and -rro are provided, parameter rro_list_type should\
                        be provided also."
                return $returnList
            }
            if {$rro_list_type == "label" && (![info exists rro_list_label])} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -rro_list_type is $rro_list_type\
                        parameter -rro_list_label must be provided."
                return $returnList
            } elseif {$rro_list_type == "ipv4" && (![info exists rro_list_ipv4])} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -rro_list_type is $rro_list_type\
                        parameter -rro_list_ipv4 must be provided."
                return $returnList
            }
            set rro_list {}
            set i 0
            foreach flag_value $rro_list_flags {
                if {[expr $flag_value & 1] == 1} {
                    set rro_protection_available true
                } else {
                    set rro_protection_available false
                }
                if {[expr $flag_value & 2] == 2} {
                    set rro_protection_in_use true
                } else {
                    set rro_protection_in_use false
                }
                if {[expr $flag_value & 4] == 4} {
                    set rro_bandwidth_protection true
                } else {
                    set rro_bandwidth_protection false
                }
                if {[expr $flag_value & 8] == 8} {
                    set rro_node_protection true
                } else {
                    set rro_node_protection false
                }
                if {![info exists rro_list_type]} {
                    keylset returnList log "Parameter -rro_list_type\
                            must be provided."
                    keylset returnList status $::FAILURE
                    return $returnList
                }
                if {$rro_list_type == "label"} {
                    if {![info exists rro_list_label] || $rro_list_label == ""} {
                        keylset returnList log "When -rro_list_type is\
                                $rro_list_type, parameter -rro_list_label\
                                must be provided and should noy be a null value."
                        keylset returnList status $::FAILURE
                        return $returnList
                    }
                    lappend rro_list [list label \
                        "[lindex $rro_list_label $i]" \
                        $rro_protection_available \
                        $rro_protection_in_use \
                        [lindex $rro_list_ctype $i] \
                        true $rro_bandwidth_protection \
                        $rro_node_protection]
                } else {
                    if {![info exists rro_list_ipv4] && $rro_list_ipv4 == ""} {
                        keylset returnList log "When -rro_list_type is\
                                $rro_list_type, parameter -rro_list_ipv4\
                                must be provided and should noy be a null value."
                        keylset returnList status $::FAILURE
                        return $returnList
                    }
                    lappend rro_list [list ip \
                        "[lindex $rro_list_ipv4 $i]" \
                        $rro_protection_available \
                        $rro_protection_in_use \
                        [lindex $rro_list_ctype $i] \
                        false $rro_bandwidth_protection \
                        $rro_node_protection]
                }
                incr i
            }
            if {$rro_list == ""} {
                unset rro_list
            } elseif {$mode == "create"} {
                set rro_list [list $rro_list]
            }
        }
        # PLR_id
        if {[info exists plr_id] && [info exists avoid_node_id]} {
            set plr_avoid {}
            foreach plr $plr_id avoid_node $avoid_node_id {
                lappend plr_avoid [list "$plr" "$avoid_node"]
            }
            if {$plr_avoid == ""} {
                unset plr_avoid
            } elseif {$mode == "create"} {
                set plr_avoid [list $plr_avoid]
            }
        }
        
        set ip_count 1
        if {[info exists emulation_type] && $emulation_type == "rsvptep2mp"} {
            if {[info exists p2mp_id]} {
                if {[::ixia::isValidIPv4Address $p2mp_id]} {
                    # Do nothing. We have to pass this parameter as IP
                } elseif {[string is double $p2mp_id]} {
                    # transform to IP
                    set p2mp_id [::ixia::long_to_ip_addr $p2mp_id]
                } else {
                    #error. must be IP or number
                    keylset returnList log "Invalid format for p2mp_id parameter.\
                            Please provide this parameter as either IPv4 address or
                            number."
                    keylset returnList status $::FAILURE
                    return $returnList
                }
            }
            if {[info exists p2mp_id_step]} {
                if {[::ixia::isValidIPv4Address $p2mp_id_step]} {
                    # Do nothing. We have to pass this parameter as IP
                } elseif {[string is double $p2mp_id_step]} {
                    # transform to IP
                    set p2mp_id_step [::ixia::long_to_ip_addr $p2mp_id_step]
                } else {
                    #error. must be IP or number
                    keylset returnList log "Invalid format for p2mp_id_step parameter.\
                            Please provide this parameter as either IPv4 address or
                            number."
                    keylset returnList status $::FAILURE
                    return $returnList
                }
            }
        }
        set common_params {
                behavior                rsvp_behavior
                ipAddressFrom           tmp_egress_ip_addr
                ipCount                 egress_ip_count
                emulationType           emulation_type
                isConnectedIpAppended   enable_append_connected_ip
                isHeadIpPrepended       enable_prepend_tunnel_head_ip
                isLeafIpPrepended       enable_prepend_tunnel_leaf_ip
                isSendingAsRro          enable_send_as_rro
                isSendingAsSrro         enable_send_as_srro
        }
        if {[info exists emulation_type] && $emulation_type == "rsvptep2mp"} {
            append common_params {p2mpId                  p2mp_id
            }
        }
                
        set ingress_options {
            enableEro                       ero
            ero                             ero_list
            prefixLength                    ero_dut_pfxlen
            prependDutToEro                 ero_mode
            rro                             rro_list
            sendRro                         rro
            tunnelIdsCount                  tunnel_id_count
            tunnelIdsStart                  tunnel_id_start
            reservationErrorTlv             reservation_error_tlv
        }
        
        set enableFixedLabelForResv false   
        if {[info exists egress_label_mode]} {
            set enableFixedLabelForResv true
            switch -exact -- $egress_label_mode {
                nextlabel {
                    set egress_label_mode routerAlert
                }
                imnull {
                    set egress_label_mode implicitNull
                }
                exnull {
                    set egress_label_mode explicitNull
                }
            }
        }
        
        set egress_options {
            bandwidth                       ingress_bandwidth
            enableFixedLabelForResv         enableFixedLabelForResv
            labelValue                      egress_label_mode
            refreshInterval                 resv_state_refresh_timeout
            rro                             rro_list
            sendResvConfirmation            resv_confirm
            reflectRro                      record_route
            timeoutMultiplier               resv_state_timeout_count 
            egressBehavior                  egress_behavior
            pathErrorTlv                    path_error_tlv
            reservationStyle                reservation_style
            reservationTearTlv              reservation_tear_tlv
            reservationTlv                  reservation_tlv
        }
                                   
        set senderRanges_options {
            ipStart                          ingress_ip_addr                
            ipCount                          ingress_ip_count               
            lspIdStart                       lsp_id_start                   
            lspIdCount                       lsp_id_count                   
            timeoutMultiplier                path_state_timeout_count       
            tokenBucketRate                  sender_tspec_token_bkt_rate    
            tokenBucketSize                  sender_tspec_token_bkt_size    
            peakDataRate                     sender_tspec_peak_data_rate    
            minimumPolicedUnit               sender_tspec_min_policed_size  
            maximumPacketSize                sender_tspec_max_pkt_size      
            sessionName                      session_attr_name              
            setupPriority                    session_attr_setup_priority    
            holdingPriority                  session_attr_hold_priority     
            excludeAny                       session_attr_ra_exclude_any    
            includeAny                       session_attr_ra_include_any    
            includeAll                       session_attr_ra_include_all    
            bandwidth                        ingress_bandwidth              
            refreshInterval                  path_state_refresh_timeout     
            timeoutMultiplier                path_state_timeout_count       
            fastRerouteDetour                plr_avoid                      
            fastRerouteBandwidth             fast_reroute_bandwidth         
            fastRerouteExcludeAny            fast_reroute_exclude_any       
            fastRerouteHoldingPriority       fast_reroute_holding_priority  
            fastRerouteHopLimit              fast_reroute_hop_limit         
            fastRerouteIncludeAll            fast_reroute_include_all       
            fastRerouteIncludeAny            fast_reroute_include_any       
            fastRerouteSetupPriority         fast_reroute_setup_priority
            pathTearTlv                      path_tear_tlv
            pathTlv                          path_tlv
        }
        
        if {[info exists session_attr_name] && [string length $session_attr_name] == 0} {
            unset session_attr_name
        }
        
        if {[info exists session_attr_reroute] && [info exists fast_reroute]} {
            set fast_reroute [expr $session_attr_reroute | $fast_reroute]
            catch {unset session_attr_reroute}
        }
        
        set senderRanges_options_flags {
            enableResourceAffinities         session_attr_resource_affinities 
            bandwidthProtectionDesired       session_attr_bw_protect        
            nodeProtectionDesired            session_attr_node_protect      
            localProtectionDesired           session_attr_local_protect     
            seStyleDesired                   session_attr_merge             
            enableFastReroute                session_attr_reroute           
            labelRecordingDesired            session_attr_label_record      
            seStyleDesired                   session_attr_se_style          
            fastRerouteOne2OneBackupDesired  one_to_one_backup              
            fastRerouteFacilityBackupDesired facility_backup               
            enableFastReroute                fast_reroute                  
            fastRerouteSendDetour            send_detour
        }
        
        
        # Verify if the "Tunnel Head To Leaf Info" parameters are ok
        # Do this so we can pass all of them to a procedure that configures them
        # without worrying if they are consistent 
        set tun_head2leaf_info_params {
            dutHopType                      h2l_info_dut_hop_type
            dutPrefixLength                 h2l_info_dut_prefix_length
            isAppendTunnelLeaf              h2l_info_enable_append_tunnel_leaf
            isPrependDut                    h2l_info_enable_prepend_dut
            isSendingAsEro                  h2l_info_enable_send_as_ero
            isSendingAsSero                 h2l_info_enable_send_as_sero
            tunnelLeafCount                 h2l_info_tunnel_leaf_count
            tunnelLeafHopType               h2l_info_tunnel_leaf_hop_type
            tunnelLeafIpStart               h2l_info_tunnel_leaf_ip_start
            tunnelLeafPrefixLength          h2l_info_tunnel_leaf_prefix_length
            h2l_info_ero_sero_list          h2l_info_ero_sero_list
        }
        
        # First check if they have the correct length
        # If there are multiple tunnels configured (-count > 1) they will be
        # identical for all tunnels.
        # To configured different head2leaf info parameters per tunnel configure
        # one tunnel at a time (separate tunnel_config calls)
        set length_list       ""
        set length_list_error ""
        foreach {ixn_param hlt_param} $tun_head2leaf_info_params {
            if {![info exists $hlt_param]} {
                continue
            }
            if {[is_default_param_value $hlt_param $args]} {
                continue
            }
            if {$hlt_param == "h2l_info_ero_sero_list" && [string length $h2l_info_ero_sero_list] == 0} {
                continue
            }
            lappend length_list       [llength [set $hlt_param]]
            lappend length_list_error $hlt_param:[llength [set $hlt_param]]
        }
        set length_list [lsort -unique -dictionary $length_list]
        if {$length_list != "" && [llength $length_list] != 1} {
            if {[llength $length_list] == 2 && [lsearch $length_list 1] != 1} {
                # Do nothing - we accept parameters with 1 value and parameters with N values
            } else {
                keylset returnList log "One or more parameters that configure\
                        'Tunnel Head To Leaf Info' do not have the same length.\
                        Head to Leaf Info parameters are:\
                        h2l_info_dut_hop_type, h2l_info_dut_prefix_length, h2l_info_head_ip_start,\
                        h2l_info_enable_append_tunnel_leaf, h2l_info_enable_prepend_dut, h2l_info_enable_send_as_ero,\
                        h2l_info_enable_send_as_sero, h2l_info_tunnel_leaf_count, h2l_info_tunnel_leaf_hop_type,\
                        h2l_info_tunnel_leaf_ip_start, h2l_info_tunnel_leaf_prefix_length, h2l_info_ero_sero_list.\n\
                        $length_list_error"
                keylset returnList status $::FAILURE
                return $returnList
            }
        }
        set h2l_info_tunnel_leaf_count_temp [lindex $length_list end]
        set head2leaf_parameters            ""
        foreach {ixn_param hlt_param} $tun_head2leaf_info_params {
            if {![info exists $hlt_param]} {
                continue
            }
            
            append head2leaf_parameters "-$hlt_param [set $hlt_param] "
        }
        
        # Tunnel Head Traffic Items
        set tun_head_traffic_params {
            endPointType                            head_traffic_ip_type
            ipCount                                 head_traffic_ip_count
            ipStart                                 head_traffic_start_ip
            head_traffic_inter_tunnel_ip_step       head_traffic_inter_tunnel_ip_step
            insertIpv6ExplicitNull                  explicit_traffic_item
        }
        
        set head_traffic_parameters ""
        foreach {ixn_param hlt_param} $tun_head_traffic_params {
            if {![info exists $hlt_param]} {
                continue
            }
            append head_traffic_parameters "-$hlt_param [set $hlt_param] "
        }
        
        # Tunnel Tail Traffic Items
        set tun_tail_traffic_params {
            endPointType                            tail_traffic_ip_type
            ipCount                                 tail_traffic_ip_count
            ipStart                                 tail_traffic_start_ip
            tail_traffic_inter_tunnel_ip_step       tail_traffic_inter_tunnel_ip_step
        }
        
        set tail_traffic_parameters ""
        foreach {ixn_param hlt_param} $tun_tail_traffic_params {
            if {![info exists $hlt_param]} {
                continue
            }
            append tail_traffic_parameters "-$hlt_param [set $hlt_param] "
        }
        
        # Verify if h2l_info_ero_sero_list parameter is ok
        if {[info exists h2l_info_ero_sero_list] && $h2l_info_ero_sero_list != ""} {
            foreach ero_sero_item $h2l_info_ero_sero_list {
                # Each Head To Leaf Info can have a list of ero items                
                foreach ero_sero_single_item [split $ero_sero_item :] {
                    # Each ero/seroo item in the list of ero/Sero items in this Head To Leaf Info
                    set ero_sero_params [split $ero_sero_single_item ,]
                    set ero_sero_param_count [llength $ero_sero_params]
                    # ero/sero IP format strict {ip,<ipv4_address>/<prefix_length>,s}
                    # ero/sero IP format loose  {ip,<ipv4_address>/<prefix_length>,l}
                    # ero/sero AS format strict {as,<as_number>,s}
                    # ero/sero AS format strict {as,<as_number>,l}
                    set errTxtHeadToLeaf "Invalid item in h2l_info_ero_sero_list: $ero_sero_single_item.\
                                Accepted format is 'ip,<ipv4_address>/<prefix_length>,s' or\
                                as,<as_number>,s"
                    if {$ero_sero_param_count != 3} {
                        keylset returnList log $errTxtHeadToLeaf
                        keylset returnList status $::FAILURE
                        return $returnList
                    }
                    switch -- [lindex $ero_sero_params 0] {
                        ip {
                            if {![::ixia::isValidIPv4AddressAndPrefix [lindex $ero_sero_params 1]]} {
                                keylset returnList log $errTxtHeadToLeaf
                                keylset returnList status $::FAILURE
                                return $returnList
                            }
                            if {![regexp -all {^[sl]$} [lindex $ero_sero_params 2]]} {
                                keylset returnList log $errTxtHeadToLeaf
                                keylset returnList status $::FAILURE
                                return $returnList
                            }
                        }
                        as {
                            if {![regexp -all {^\d+$} [lindex $ero_sero_params 1]]} {
                                #error
                            }
                            if {![regexp -all {^[sl]$} [lindex $ero_sero_params 2]]} {
                                keylset returnList log $errTxtHeadToLeaf
                                keylset returnList status $::FAILURE
                                return $returnList
                            }
                        }
                        default {
                            keylset returnList log $errTxtHeadToLeaf
                            keylset returnList status $::FAILURE
                            return $returnList
                        }
                    }
                }
            }
        }
    }
    switch $mode {
        create {
            if {$rsvp_behavior == "rsvpEgress" && [info exists egress_ip_addr]} {
                set ingress_ip_addr $egress_ip_addr
            }
            if {$rsvp_behavior == "rsvpIngress"} {
                set rsvp_behavior ingress
            } else {
                set rsvp_behavior egress
            }
            if {[info exists egress_ip_addr]} {
                foreach egress_ip_addr_elem $egress_ip_addr  {
                    if {[ipv6::isValidAddress $egress_ip_addr_elem]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "When -mode is $mode, parameters\
                                -egress_ip_addr or -egress_ip_step should be provided\
                                as valid IPv4 addresses."
                        return $returnList
                    }
                }
            }
            if {[info exists egress_ip_step]} {
                foreach egress_ip_step_elem $egress_ip_step  {
                    if {[ipv6::isValidAddress $egress_ip_step_elem]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "When -mode is $mode, parameters\
                                -egress_ip_addr or -egress_ip_step should be provided\
                                as valid IPv4 addresses."
                        return $returnList
                    }
                }
            }
            if {[info exists egress_ip_addr] && [info exists egress_ip_step]} {
                if {[llength $egress_ip_addr] > [llength $egress_ip_step] } {
                    set tmpList [string repeat " [lindex $egress_ip_step end]" \
                            [expr [llength $egress_ip_addr] - [llength $egress_ip_step]]]
                    set egress_ip_step [concat $egress_ip_step $tmpList]
                }
            }
            # Create unconnected interfaces
            set tmp_port_handle [::ixia::ixNetworkGetPortFromObj $handle]
            if {[keylget tmp_port_handle status] != $::SUCCESS} {
                return $tmp_port_handle
            } else {
                set tmp_port_handle [keylget tmp_port_handle port_handle]
            }
            set intf_params "::ixia::ixNetworkProtocolIntfCfg -port_handle $tmp_port_handle"

            set ingress_unconnected_intf_list ""
            set egress_unconnected_intf_list ""

            if {[info exists emulation_type] && $emulation_type == "rsvptep2mp"} {
                # Unconnected interfaces for P2MP RSVP
                if {$rsvp_behavior == "ingress"} {
#                     ingress_ip_addr
#                     ingress_ip_step
                    if {$ingress_enable_interface_creation == 1} {
                        set connected_ip_addr [ixNet getAttribute $handle -ourIp]
                        append intf_params " -ipv4_address $connected_ip_addr"
                        if {[info exists ingress_ip_addr]} {
                            append intf_params " -loopback_ipv4_address $ingress_ip_addr"
                        }
                        if {[info exists ingress_ip_step]} {
                            append intf_params " -loopback_ipv4_address_step $ingress_ip_step"
                        }
                        if {[info exists count]} {
                            append intf_params " -loopback_count $count"
                        }
                        # call procedure to create interfaces
                        set prot_intf_status [eval $intf_params]
                        if {[keylget prot_intf_status status] != $::SUCCESS} {
                            return $prot_intf_status
                        }
                        set ingress_unconnected_intf_list [keylget prot_intf_status routed_interfaces]
                    }
                } else {
                    set connected_ip_addr [ixNet getAttribute $handle -ourIp]
                    if {[info exists egress_ip_addr]} {
                        if {$egress_leaf_range_param_type == "single_value"} {
                            set lo_ip_tmp_outer $egress_ip_addr
                            set lo_ip_tmp_inner $egress_ip_addr
        
                            for {set i 0} {$i < $count} {incr i} {
                                #create loopback ip ranges for each ip
                                for {set j 0} {$j < $egress_leaf_range_count} {incr j} {
                                    set prot_intf_status [::ixia::ixNetworkProtocolIntfCfg     \
                                           -port_handle                $tmp_port_handle        \
                                           -ipv4_address               $connected_ip_addr      \
                                           -loopback_ipv4_address      $lo_ip_tmp_inner        \
                                           -loopback_ipv4_address_step 0.0.0.1                 \
                                           -loopback_count             $egress_leaf_ip_count   \
                                       ]
                                    if {[keylget prot_intf_status status] != $::SUCCESS} {
                                        return $prot_intf_status
                                    }
                                    
                                    lappend egress_unconnected_intf_list [keylget prot_intf_status routed_interfaces] 
                                    set egress_unconnected_intf_list [join $egress_unconnected_intf_list]
                                    
                                    set lo_ip_tmp_inner [::ixia::incr_ipv4_addr $lo_ip_tmp_inner $egress_leaf_range_step]
                                }
                                set lo_ip_tmp_outer [::ixia::incr_ipv4_addr $lo_ip_tmp_outer $egress_ip_step]
                                set lo_ip_tmp_inner $lo_ip_tmp_outer
                            }
                        } else {
                            set lo_ip_tmp_outer $egress_ip_addr
                            for {set i 0} {$i < $count} {incr i} {
                                #create loopback ip ranges for each ip
                                for {set j 0} {$j < $egress_leaf_range_count} {incr j} {
                                    set prot_intf_status [::ixia::ixNetworkProtocolIntfCfg               \
                                           -port_handle                $tmp_port_handle                  \
                                           -ipv4_address               $connected_ip_addr                \
                                           -loopback_ipv4_address      [lindex $lo_ip_tmp_outer $j]      \
                                           -loopback_ipv4_address_step 0.0.0.1                           \
                                           -loopback_count             [lindex $egress_leaf_ip_count $j] \
                                       ]
                                    if {[keylget prot_intf_status status] != $::SUCCESS} {
                                        return $prot_intf_status
                                    }
                                    
                                    lappend egress_unconnected_intf_list [keylget prot_intf_status routed_interfaces] 
                                    set egress_unconnected_intf_list [join $egress_unconnected_intf_list]
                                }
                                set tmpList ""
                                foreach lo_ip_tmp_outer_elem $lo_ip_tmp_outer egress_ip_step_elem $egress_ip_step {
                                    lappend tmpList [::ixia::incr_ipv4_addr $lo_ip_tmp_outer_elem $egress_ip_step_elem]
                                }
                                set lo_ip_tmp_outer $tmpList
                            }
                        }
                    }
                }
            } else {
                # Unconnected interfaces for P2P RSVP
                if {$rsvp_behavior == "ingress"} {
                    if {$ingress_enable_interface_creation == 1} {
                        set connected_ip_addr [ixNet getAttribute $handle -ourIp]
                        append intf_params " -ipv4_address $connected_ip_addr"
                        if {[info exists ingress_ip_addr]} {
                            append intf_params " -loopback_ipv4_address [lindex $ingress_ip_addr 0]"
                        }
                        if {[info exists ingress_ip_step]} {
                            append intf_params " -loopback_ipv4_address_step [lindex $ingress_ip_step]"
                        }
                        if {[info exists count]} {
                            append intf_params " -loopback_count $count"
                        }
                        # call procedure to create interfaces
                        set prot_intf_status [eval $intf_params]
                        if {[keylget prot_intf_status status] != $::SUCCESS} {
                            return $prot_intf_status
                        }
                        
                        set ingress_unconnected_intf_list [keylget prot_intf_status routed_interfaces]
                    }
                } else {
                    set connected_ip_addr [ixNet getAttribute $handle -ourIp]
                    append intf_params " -ipv4_address $connected_ip_addr"
                    if {[info exists egress_ip_addr]} {
                        append intf_params " -loopback_ipv4_address [lindex $egress_ip_addr 0] -loopback_ipv4_prefix_length 32"
                    }
                    if {[info exists egress_ip_step]} {
                        append intf_params " -loopback_ipv4_address_step [lindex $egress_ip_step 0]"
                    }
                    
                    if {[info exists count]} {
                        append intf_params " -loopback_count $count"
                    }
                    # call procedure to create interfaces
                    set prot_intf_status [eval $intf_params]
                    if {[keylget prot_intf_status status] != $::SUCCESS} {
                        return $prot_intf_status
                    }
                    
                    lappend egress_unconnected_intf_list [keylget prot_intf_status routed_interfaces] 
                    set egress_unconnected_intf_list [join $egress_unconnected_intf_list]

                }
            }
            
            foreach reroute_item {session_attr_ra_exclude_any \
                                  session_attr_ra_include_all \
                                  session_attr_ra_include_any \
                                  fast_reroute_exclude_any \
                                  fast_reroute_include_all \
                                  fast_reroute_include_any} {
                if {[info exists $reroute_item]} {
                    if {[catch {set $reroute_item [mpexpr "0x[set $reroute_item]"]}] || \
                        [catch {set $reroute_item [mpexpr   "[set $reroute_item]"]}]} {
                        if {[regexp -nocase -- {^([0-9,a-f]+).([0-9,a-f]+).([0-9,a-f]+).([0-9,a-f]+)$} \
                            [set $reroute_item] all a b c d] == 1} {
                            set $reroute_item [mpexpr 0x$a$b$c$d]
                        } else {
                            keylset returnList log "Invalid value\
                                    [set $reroute_item] for parameter\
                                    -$reroute_item. The format should match the\
                                    following regular expression:\
                                    \^(\[0-9,a-f\]+).(\[0-9,a-f\]+).(\[0-9,a-f\]+).(\[0-9,a-f\]+)\$."
                            keylset returnList status $::FAILURE
                            return $returnList
                        }
                    }
                }
            }
            # setting fixed parameters before main loop
            set command_common_params [list]
            foreach {cmd param} $common_params {
                # This is done to support incrementing tmp_ params (eg. tmp_egress_ip_addr)
                set tmp_param place_holder
                if {([string first tmp_ $param] != -1)} {
                    set tmp_param [string replace $param 0 3 ""]
                }
                #
                if {[info exists $param] || [info exists $tmp_param]} {
                    if {$param == "emulation_type"} {
                        if {[set $param] == "rsvpte"} {
                            set value rsvpTe
                        } else {
                            set value rsvpTeP2mP
                        }
                    } elseif {$param == "tmp_egress_ip_addr" && $egress_leaf_range_param_type == "list"} {
                        set value "\[lindex \[set $param\] \$item\]"
                    } else {
                        set value "\[set $param\]"
                    }
                    debug "ixNet setAttr \$dstRange -$cmd $value"
                    append command_common_params \
                            "ixNet setAttr \$dstRange -$cmd $value;"
                }
            }
            if {[info exists egress_ip_addr]} {
                set tmp_egress_ip_addr $egress_ip_addr
            }
            for {set item 0} {$item < $count} {incr item} {
                if {[catch {
                    debug "ixNet add $handle destinationRange"
                    set dstRange [ixNet add $handle destinationRange]
                } retError]} {
                    keylset returnList log "Failed to add destination range.\
                            $retError"
                    keylset returnList status $::FAILURE
                    return $returnList
                }
                debug [subst $command_common_params]
                eval [subst $command_common_params]
                if {[info exists tmp_egress_ip_addr]} {
                    set tmpList ""
                    foreach tmp_egress_ip_addr_elem $tmp_egress_ip_addr egress_ip_step_elem $egress_ip_step {
                        lappend tmpList [::ixia::increment_ipv4_address_hltapi \
                                $tmp_egress_ip_addr_elem $egress_ip_step_elem]
                    }
                    set tmp_egress_ip_addr $tmpList
                }
                
                if {[info exists emulation_type] && $emulation_type == "rsvptep2mp" && [info exists p2mp_id]} {
                    set p2mp_id [::ixia::increment_ipv4_address_hltapi $p2mp_id $p2mp_id_step]
                }
                
                ixNet setAttr $dstRange -enabled true
                set dstRange_tmp($item) $dstRange
                incr objectCount
                if { $objectCount == $objectMaxCount} {
                    ixNet commit
                    set objectCount 0
                }
            }
            if {$objectCount > 0} {
                ixNet commit
            }
            set handle_list [list]
            if {$rsvp_behavior == "ingress"} {
                if {[info exists ero] && $ero == 1} {
                    set ero true
                } else {
                    set ero false
                }
                if {[info exists rro] && $rro == 1} {
                    set rro true
                } elseif {[info exists rro]} {
                    set rro false
                }
                if {[info exists ero_mode]} {
                    switch -- $ero_mode {
                        loose {set ero_mode prependLoose}
                        strict {set ero_mode prependStrict}
                        none {set ero_mode none}
                    }
                    set ero_mode [list $ero_mode]
                }
                # setting fixed command list before loop
                set command_ingress_options [list]
                foreach {cmd param} $ingress_options {
                    if {[info exists $param]} {

                        if {$param == "reservation_error_tlv"} {
                            append command_ingress_options \
                                    "ixNet setAttr \$dstRangeasd(\$item) -$cmd \"\[::ixia::formatRsvpTlv \[set $param\]\]\";"
                        } else {
                            append command_ingress_options \
                                    "ixNet setAttr \$dstRangeasd(\$item) -$cmd \[set $param\];"
                        }
                    }
                }
                set command_senderRanges_options_flags [list]
                foreach {cmd param} $senderRanges_options_flags {
                    if {[info exists $param]} {
                        switch -exact -- [set $param] {
                            0 {set value false}
                            1 {set value true}
                            default {debug "bad flags list senderRanges_options_flags"}
                        }
                        debug "ixNet setAttr \$sendRange -$cmd $value"
                        append command_senderRanges_options_flags \
                                "ixNet setAttr \$sendRange -$cmd $value;"
                    }
                }
                set command_senderRanges_options [list]
                foreach {cmd param} $senderRanges_options {
                    if {[info exists $param]} {
                        if {$param == "path_tear_tlv" || $param == "path_tlv"} {
                            append command_senderRanges_options \
                                "ixNet setAttr \$sendRange -$cmd \"\[::ixia::formatRsvpTlv \[set $param\]\]\";"
                        } else {
                            debug "ixNet setAttr \$sendRange -$cmd \[set $param\]"
                            append command_senderRanges_options \
                                "ixNet setAttr \$sendRange -$cmd \[set $param\];"
                        }
                    }
                }
                for {set item 0} {$item < $count} {incr item} {
                    set dstRangeasd($item) [ixNet remapIds $dstRange_tmp($item)]/ingress
                    debug "ixNet remapIds $dstRange_tmp($item)"
                    lappend handle_list $dstRangeasd($item)
                    debug "eval [subst $command_ingress_options]"
                    eval [subst $command_ingress_options]
                    if {[info exists tunnel_id_start] && [info exists tunnel_id_step]} {
                        incr tunnel_id_start $tunnel_id_step
                    }
                    incr objectCount
                    if { $objectCount == $objectMaxCount} {
                        debug "ixNet commit"
                        ixNet commit
                        set objectCount 0
                    }
                    debug "ixNet add $dstRangeasd($item) senderRange"
                    set sendRange [ixNet add $dstRangeasd($item) senderRange]
                    debug "ixNet setAttr $sendRange -enabled true"
                    ixNet setAttr $sendRange -enabled true
                    if {[info exists session_attr_name]} {
                        debug "ixNet setAttr $sendRange -autoGenerateSessionName false"
                        ixNet setAttr $sendRange -autoGenerateSessionName false
                    }
                    if {[info exists local_lsp_id_end] && [info exists lsp_id_start]} {
                        set lsp_id_count [expr $local_lsp_id_end - $lsp_id_start]
                    }
                    eval [subst $command_senderRanges_options_flags]
                    eval [subst $command_senderRanges_options]
                    if {[info exists ingress_ip_addr] && [info exists ingress_ip_step]} {
                        set ingress_ip_addr [::ixia::increment_ipv4_address_hltapi \
                            $ingress_ip_addr $ingress_ip_step]
                    }
                    if {[info exists lsp_id_start] && [info exists lsp_id_step]} {
                        incr lsp_id_start $lsp_id_step
                    }

                        
                    if {$head2leaf_parameters != ""} {
                        set h2l_status [::ixia::ixnetwork_rsvp_add_head2leaf_info $sendRange $h2l_info_tunnel_leaf_count_temp $head2leaf_parameters]
                        if {[keylget h2l_status status] != $::SUCCESS} {
                            return $h2l_status
                        }
                    }
                    incr objectCount
                    if { $objectCount == $objectMaxCount} {
                        debug "ixNet commit"
                        ixNet commit
                        set objectCount 0
                    }
                }
                if {$objectCount > 0} {
                    debug "ixNet commit"
                    ixNet commit
                }
                for {set item 0} {$item < $count} {incr item} {
                    set sendRange [ixNet getList $dstRangeasd($item) senderRange]
                    if {[info exists emulation_type] && $emulation_type == "rsvptep2mp"} {
                        set h_traffic_status [::ixia::ixnetwork_rsvp_add_head_traffic_item $sendRange $item $head_traffic_parameters]
                        if {[keylget h_traffic_status status] != $::SUCCESS} {
                            return $h_traffic_status
                        }
                    }
                }
            } else {
                if {[info exists sendResvConfirmation] && \
                        $sendResvConfirmation == 1} {
                    set sendResvConfirmation true
                } elseif {[info exists sendResvConfirmation]} {
                    set sendResvConfirmation false
                }
                # setting command list
                set command_egress_options [list]
                foreach {cmd param} $egress_options {
                    if {[info exists $param]} {
                        if {$param == "path_error_tlv" || $param == "reservation_tear_tlv" || $param == "reservation_tlv"} {
                            append command_egress_options \
                                    "ixNet setAttr \$handle -$cmd \"[::ixia::formatRsvpTlv [set $param]]\";"
                        } elseif {$param == "egress_behavior"} {
                            switch -- [set $param] {
                                "always_use_configured_style" {
                                    set value "alwaysUseConfiguredStyle"
                                }
                                "use_se_when_indicated_in_session_attribute" {
                                    set value "useSeWhenIndicatedInSessionAttribute"
                                }
                            }
                            debug "ixNet setAttr \$handle -$cmd $value"
                            append command_egress_options \
                                    "ixNet setAttr \$handle -$cmd $value;"
                        } else {
                            debug "ixNet setAttr $handle -$cmd [set $param]"
                            append command_egress_options \
                                    "ixNet setAttr \$handle -$cmd [set $param];"
                        }
                    }
                }
                for {set item 0} {$item < $count} {incr item} {
                    debug "ixNet remapIds $dstRange_tmp($item)"
                    set handle [ixNet remapIds $dstRange_tmp($item)]/egress
                    if {[info exists rro] && (![info exists rro_list_flags]) && \
                            $rro == 1} {
                        debug "ixNet setAttr $handle -reflectRro true"
                        ixNet setAttr $handle -reflectRro true
                    } else {
                        debug "ixNet setAttr $handle -reflectRro false"
                        ixNet setAttr $handle -reflectRro false
                    }
                    lappend handle_list [ixNet remapIds $dstRange_tmp($item)]
                    debug [subst $command_egress_options]
                    eval [subst $command_egress_options]
                    
                    incr objectCount
                    if { $objectCount == $objectMaxCount} {
                        debug "ixNet commit"
                        ixNet commit
                        set objectCount 0
                    }
                }
                
                if {$objectCount > 0} {
                    debug "ixNet commit"
                    ixNet commit
                }
            }
            
            if {[info exists egress_ip_addr]} {
                set tmp_outer_egress_ip_addr $egress_ip_addr
            }
            
            for {set item 0} {$item < $count} {incr item} {
                debug "ixNet remapIds $dstRange_tmp($item)"
                set dest_handle [ixNet remapIds $dstRange_tmp($item)]

                # Add tunnel leaf
                if {[info exists emulation_type] && $emulation_type == "rsvptep2mp"} {
                    if {[info exists tmp_outer_egress_ip_addr]} {
                        if {![info exists egress_leaf_range_count]} {
                            set egress_leaf_range_count 1
                        }
                        set tunnel_leaves_list ""
                        if {$egress_leaf_range_param_type == "single_value"} {
                            set tmp_inner_egress_ip_addr $tmp_outer_egress_ip_addr
                            for {set leaf_item 0} {$leaf_item < $egress_leaf_range_count} {incr leaf_item} {
                                set leaf_status [::ixia::ixNetworkNodeAdd $dest_handle "tunnelLeafRange"\
                                                        [list -enabled    1                             \
                                                        -ipCount    $egress_leaf_ip_count               \
                                                        -ipStart    $tmp_inner_egress_ip_addr]                \
                                                        -commit     ]
                                if {[keylget leaf_status status] != $::SUCCESS} {
                                    return $leaf_status
                                }
                                set tmp_inner_egress_ip_addr [::ixia::incr_ipv4_addr $tmp_inner_egress_ip_addr $egress_leaf_range_step]
                                lappend tunnel_leaves_list [keylget leaf_status node_objref]
                            }                   
                        } else {
                            set tmp_inner_egress_ip_addr $tmp_outer_egress_ip_addr
                            for {set leaf_item 0} {$leaf_item < $egress_leaf_range_count} {incr leaf_item} {
                                set leaf_status [::ixia::ixNetworkNodeAdd $dest_handle "tunnelLeafRange"            \
                                                        [list -enabled    1                                         \
                                                        -ipCount    [lindex $egress_leaf_ip_count     $leaf_item]           \
                                                        -ipStart    [lindex $tmp_inner_egress_ip_addr $leaf_item] ] \
                                                        -commit     ]
                                if {[keylget leaf_status status] != $::SUCCESS} {
                                    return $leaf_status
                                }                                
                                lappend tunnel_leaves_list [keylget leaf_status node_objref]
                            }
                        }
                        if {$rsvp_behavior == "ingress"} {
                            keylset returnList tunnel_leaves_handle.$dest_handle/ingress $tunnel_leaves_list
                        } else {
                            keylset returnList tunnel_leaves_handle.$dest_handle $tunnel_leaves_list
                        }
                        set tmpList ""
                        foreach tmp_outer_egress_ip_addr_elem $tmp_outer_egress_ip_addr egress_ip_step_elem $egress_ip_step {
                            set tmpList [::ixia::incr_ipv4_addr $tmp_outer_egress_ip_addr_elem $egress_ip_step_elem]
                        }
                        set tmp_outer_egress_ip_addr $tmpList
                        set tmp_egress_ip_addr       $tmp_outer_egress_ip_addr
                    }
                    
                    set t_traffic_status [::ixia::ixnetwork_rsvp_add_tail_traffic_item $dest_handle $item $tail_traffic_parameters]
                    if {[keylget t_traffic_status status] != $::SUCCESS} {
                        return $t_traffic_status
                    }
                }
            }
            
            # Add unconnected interfaces handles to return list
            if {[info exists emulation_type] && $emulation_type == "rsvptep2mp"} {
                if {$rsvp_behavior == "egress"} {
                    if {![info exists egress_leaf_range_count]} {
                        set egress_leaf_range_count 1
                    }
                    if {![info exists egress_leaf_ip_count]} {
                        set egress_leaf_ip_count 1
                    }
                    if {$egress_leaf_range_param_type == "single_value"} {
                        set per_destination_range_intf_count [mpexpr $egress_leaf_range_count * $egress_leaf_ip_count]
                    } else {
                        set per_destination_range_intf_count  [mpexpr [join $egress_leaf_ip_count +]]
                    }
                }
            }
            set intfIndex 0
            for {set item 0} {$item < $count} {incr item} {
                debug "ixNet remapIds $dstRange_tmp($item)"
                set dest_handle [ixNet remapIds $dstRange_tmp($item)]
                
                if {$rsvp_behavior == "ingress"} {
                    if {[info exists ingress_unconnected_intf_list] && $ingress_unconnected_intf_list != ""} {
                        set tmpIntfH [lindex $ingress_unconnected_intf_list $item]
                        keylset returnList routed_interfaces.$dest_handle/ingress $tmpIntfH
                    }
                } else {
                    if {[info exists emulation_type] && $emulation_type == "rsvptep2mp"} {
                        if {[info exists egress_unconnected_intf_list] && $egress_unconnected_intf_list != ""} {
                            keylset returnList routed_interfaces.$dest_handle [lrange \
                                    $egress_unconnected_intf_list $intfIndex [mpexpr $intfIndex + $per_destination_range_intf_count - 1]]
                                    
                            incr intfIndex $per_destination_range_intf_count
                        }
                    } else {
                        if {[info exists egress_unconnected_intf_list] && $egress_unconnected_intf_list != ""} {
                            set tmpIntfH [lindex $egress_unconnected_intf_list $item]
                            keylset returnList routed_interfaces.$dest_handle $tmpIntfH
                        }
                    }
                }
            }

            keylset returnList tunnel_handle $handle_list
        }
        delete {
            if {![info exists tunnel_pool_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -mode is $mode, please provide\
                        parameter -tunnel_pool_handle."
                return $returnList
            }
            foreach item $tunnel_pool_handle {
                if {[regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/rsvp/neighborPair:\d+/destinationRange:\d+/ingress$} $item]} {
                    set item [ixNetworkGetParentObjref $item destinationRange]
                }
                debug "ixNet remove $item"
                ixNet remove $item
            }
            debug "ixNet commit"
            ixNet commit
        }
        modify {
            if {![info exists tunnel_pool_handle] && ![info exists port_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -mode is $mode, please provide\
                        parameter -tunnel_pool_handle or parameter -port_handle."
                return $returnList
            }
            if {[info exists port_handle]} {
                set port $::ixia::ixnetwork_port_handles_array($port_handle)
                debug "ixNet getList $port/protocols/rsvp neighborPair"
                set neighList [ixNet getList $port/protocols/rsvp neighborPair]
                if {![info exists tunnel_pool_handle]} {set tunnel_pool_handle ""}
                set handle {}
                foreach neigh $neighList {
                    debug "ixNet getList $neigh destinationRange"
                    set dstRange_list [ixNet getList $neigh destinationRange]
                    lappend handle $dstRange_list
                    set tunnel_pool_handle [join [list $handle $tunnel_pool_handle]]
                }
            }
            if {[info exists ero_mode]} {
                switch -- $ero_mode {
                    loose {set ero_mode prependLoose}
                    strict {set ero_mode prependStrict}
                    none {set ero_mode None}
                }
                set ero_mode [list $ero_mode]
            }
            
            foreach reroute_item {session_attr_ra_exclude_any \
                                  session_attr_ra_include_all \
                                  session_attr_ra_include_any \
                                  fast_reroute_exclude_any \
                                  fast_reroute_include_all \
                                  fast_reroute_include_any} {
                if {[info exists $reroute_item]} {
                    if {[catch {set $reroute_item [mpexpr "0x[set $reroute_item]"]}] || \
                        [catch {set $reroute_item [mpexpr   "[set $reroute_item]"]}]} {
                        if {[regexp -nocase -- {^([0-9,a-f]+).([0-9,a-f]+).([0-9,a-f]+).([0-9,a-f]+)$} \
                            [set $reroute_item] all a b c d] == 1} {
                            set $reroute_item [mpexpr 0x$a$b$c$d]
                        } else {
                            keylset returnList log "Invalid value\
                                    [set $reroute_item] for parameter\
                                    -$reroute_item. The format should match the\
                                    following regular expression:\
                                    \^(\[0-9,a-f\]+).(\[0-9,a-f\]+).(\[0-9,a-f\]+).(\[0-9,a-f\]+)\$."
                            keylset returnList status $::FAILURE
                            return $returnList
                        }
                    }
                }
            }
            
            set handle $tunnel_pool_handle
            foreach handle_item $handle {
                if {[regexp -- {::ixNet::OBJ-/vport:\d+/protocols/rsvp/neighborPair:\d+/destinationRange:\d+} \
                        $handle_item dstRange] != 1} {
                    if {[regexp -- {::ixNet::OBJ-/vport:\d+/protocols/rsvp/neighborPair:\d+/destinationRange:\d+/ingress} \
                            $handle_item dstRange] != 1} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Invalid tunnel handle $handle_item."
                        return $returnList
                    } else {
                        set handle [::ixia::ixNetworkGetParentObjref $handle]
                    }
                }

                set emulation_type [ixNet getAttr $dstRange -emulationType]
                
                debug "ixNet getAttr $dstRange -behavior"
                if {[ixNet getAttr $dstRange -behavior] == "ingress"} {
                    if {[info exists ero] && $ero == 1} {
                        set ero true
                    } elseif {[info exists ero]} {
                        set ero false
                    }
                    if {[info exists rro] && $rro == 1} {
                        set rro true
                    } elseif {[info exists rro]} {
                        set rro false
                    }
                    foreach {cmd param} $ingress_options {
                        if {[info exists $param]} {
                            if {$param == "reservation_error_tlv"} {
                                if [catch {ixNet setAttr $dstRange/ingress -$cmd "[::ixia::formatRsvpTlv [set $param]]"} retError] {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Failed to configure parameter $param. $retError"
                                    return $returnList
                                }
                            } else {
                                debug "ixNet setAttr $dstRange/ingress -$cmd [set $param]"
                                if [catch {ixNet setAttr $dstRange/ingress -$cmd [set $param]} retError] {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Failed to configure parameter $param. $retError"
                                    return $returnList
                                }
                            }
                        }
                    }

                    debug "ixNet getList $dstRange/ingress senderRange"
                    set senderRanges_list [ixNet getList $dstRange/ingress senderRange]
                    foreach sndRange $senderRanges_list {
                        foreach {cmd param} $senderRanges_options_flags {
                            if {[info exists $param]} {
                                switch -exact -- [set $param] {
                                    0 {set value false}
                                    1 {set value true}
                                    default {debug "bad flags list senderRanges_options_flags"}
                                }
                                debug "ixNet setAttr $sndRange -$cmd $value"
                                if [catch {ixNet setAttr $sndRange -$cmd $value} retError] {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Failed to configure parameter $param. $retError"
                                    return $returnList
                                }
                            }
                        }
                        foreach {cmd param} $senderRanges_options {
                            if {[info exists $param]} {
                                if {$param == "path_tear_tlv" || $param == "path_tlv"} {
                                    if [catch {ixNet setAttr $sndRange -$cmd "[::ixia::formatRsvpTlv [set $param]]"} retError] {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "Failed to configure parameter $param. $retError"
                                        return $returnList
                                    }
                                } else {
                                    debug "ixNet setAttr $sndRange -$cmd [set $param]"
                                    if [catch {ixNet setAttr $sndRange -$cmd [set $param]} retError] {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "Failed to configure parameter $param. $retError"
                                        return $returnList
                                    }
                                }
                            }
                        }
                        
                        if {[info exists emulation_type] && $emulation_type == "rsvpTeP2mP" && $head_traffic_parameters != ""} {
                            set h_traffic_status [::ixia::ixnetwork_rsvp_add_head_traffic_item $sndRange 0 $head_traffic_parameters]
                            if {[keylget h_traffic_status status] != $::SUCCESS} {
                                return $h_traffic_status
                            }
                            
                            if {$head2leaf_parameters != ""} {
                                # Delete all head2leaf objects
                                foreach h2lObj [ixNet getList $sndRange tunnelHeadToLeaf] {
                                    if {[catch {ixNet remove $h2lObj} retError]} {
                                        keylset returnList status $::FAILURE
                                        keylset returnList log "Failed to remove 'Head to Leaf object' $retError."
                                        return $returnList
                                    }
                                }
                                
                                set h2l_status [::ixia::ixnetwork_rsvp_add_head2leaf_info $sndRange $h2l_info_tunnel_leaf_count_temp $head2leaf_parameters]
                                if {[keylget h2l_status status] != $::SUCCESS} {
                                    return $h2l_status
                                }
                            }
                        }
                    }
                } else {
                    if {[info exists reflectRro] && $reflectRro == 1} {
                        set reflectRro true
                    } elseif {[info exists reflectRro]} {
                        set reflectRro false
                    }
                    if {[info exists sendResvConfirmation] && \
                            $sendResvConfirmation == 1} {
                        set sendResvConfirmation true
                    } elseif {[info exists sendResvConfirmation]} {
                        set sendResvConfirmation false
                    }
                    foreach {cmd param} $egress_options {
                        if {[info exists $param]} {
                            if {$param == "path_error_tlv" || $param == "reservation_tear_tlv" || $param == "reservation_tlv"} {
                                if [catch {ixNet setAttr $dstRange/egress -$cmd "[::ixia::formatRsvpTlv [set $param]]"} retError] {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Failed to configure parameter $param. $retError"
                                    return $returnList
                                }
                            } elseif {$param == "egress_behavior"} {
                                switch -- [set $param] {
                                    "always_use_configured_style" {
                                        set value "alwaysUseConfiguredStyle"
                                    }
                                    "use_se_when_indicated_in_session_attribute" {
                                        set value "useSeWhenIndicatedInSessionAttribute"
                                    }
                                }
                                debug "ixNet setAttr $dstRange/egress -$cmd $value"
                                if [catch {ixNet setAttr $dstRange/egress -$cmd $value} retError] {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Failed to configure parameter $param. $retError"
                                    return $returnList
                                }
                            } else {
                                debug "ixNet setAttr $dstRange/egress -$cmd [set $param]"
                                if [catch {ixNet setAttr $dstRange/egress -$cmd [set $param]} retError] {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Failed to configure parameter $param. $retError"
                                    return $returnList
                                }
                            }
                            
                        }
                    }
                }
                
                if {[info exists emulation_type] && $emulation_type == "rsvpTeP2mP" && $tail_traffic_parameters != ""} {
                    set t_traffic_status [::ixia::ixnetwork_rsvp_add_tail_traffic_item $dstRange 0 $tail_traffic_parameters]
                    if {[keylget t_traffic_status status] != $::SUCCESS} {
                        return $t_traffic_status
                    }
                }
            }
            debug "ixNet commit"
            ixNet commit
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::ixnetwork_rsvp_control {args man_args opt_args} {
    if {[catch {::ixia::parse_dashed_args \
            -args           $args         \
            -mandatory_args $man_args     \
            -optional_args  $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    # Check to see if a connection to the IxNetwork TCL Server already exists. 
    # If it doesn't, establish it.
    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    
    if {$mode == "sub_lsp_down" || $mode == "sub_lsp_up"} {
        foreach tun_leaf_handle $handle {
            if {![regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/rsvp/neighborPair:\d+/destinationRange:\d+/tunnelLeafRange:\d+$} $tun_leaf_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid tunnel leaf handle $tun_leaf_handle"
                return $returnList
            }
        }
        
        if {$mode == "sub_lsp_down"} {
            set sub_lsp_down_status [::ixia::ixNetworkNodeSetAttr $tun_leaf_handle \
                                    [list -subLspDown 1] -commit]
        } else {
            set sub_lsp_down_status [::ixia::ixNetworkNodeSetAttr $tun_leaf_handle \
                                    [list -subLspDown 0] -commit]
        }
        
        if {[keylget sub_lsp_down_status status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to mark tunnel $tun_leaf_handle as $mode.\
                    [keylget sub_lsp_down_status log]"
            return $returnList
        }
        
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    if {[info exists handle] && ([info exists teardown] || [info exists restore])} {
        foreach hnd $handle {
            if {[info exists teardown]} {
                debug "ixNet setAttribute $hnd -enabled false"
                ixNet setAttribute $hnd -enabled false
            }
            if {[info exists restore]} {
                debug "ixNet setAttribute $hnd -enabled true"
                ixNet setAttribute $hnd -enabled true
            }
        }
        debug "ixNet commit"
        ixNet commit
    }
    
    return [ixNetworkProtocolControl     \
                "-protocol rsvp $args"   \
                "-protocol $man_args"    \
                $opt_args                ]
}

proc ::ixia::ixnetwork_rsvp_info {args opt_args} {
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    set procName [lindex [info level [info level]] 0]
    if {![info exists handle] && ![info exists port_handle]} {
        keylset returnList log "ERROR in $procName: Parameter -handle or\
                parameter -port_handle must be provided."
        keylset returnList status $::FAILURE
        return $returnList
    }
    
    # Check to see if a connection to the IxNetwork TCL Server already exists. 
    # If it doesn't, establish it.
    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    
    if {![info exists handle]} {
        set handle {}
        foreach port $port_handle {
            set oref_port $::ixia::ixnetwork_port_handles_array($port)
            debug "ixNet getList $oref_port/protocols/rsvp neighborPair"
            lappend handle [ixNet getList $oref_port/protocols/rsvp neighborPair]
        }
        set handle [join $handle]
    }  
    if {![info exists port_handle]} {
        set port_handle {}
        foreach handle_item $handle {
            regexp {::ixNet::OBJ-/vport:\d+} $handle_item port_objRef
            if {![info exists port_objRef]} {
                keylset returnList log "FAIL ixnetwork_rsvp_info: input handle corrupted!"
                keylset returnList status $::FAILURE
                return $returnList
            }
            lappend port_handle [::ixia::ixNetworkGetRouterPort $port_objRef]
        }
    }
    set port_handles $port_handle
    
    if {$mode == "stats"} {
        # read stats
        array set stats_array_aggregate {
            "Port Name"                          port_name
            "Ingress LSPs Configured"            inbound_lsp_count
            "Egress LSPs Up"                     outbound_lsp_count
            "Ingress SubLSPs Configured"         ingress_sub_lsp_configured_count
            "Ingress LSPs Up"                    ingress_lsp_up_count
            "Ingress SubLSPs Up"                 ingress_sub_lsp_up_count
            "Egress SubLSPs Up"                  egress_sub_lsp_up_count
            "Paths Rx"                           egress_path_rx
            "Path Tears Rx"                      egress_pathtear_rx
            "RESVs Tx"                           egress_resv_tx
            "RESV Tears Tx"                      egress_resvtear_tx
            "RESV-ERRs Rx"                       ingress_resverr_rx
            "RESV Lifetime Expirations"          ingress_resv_timeout
            "RESV-CONFs Tx"                      ingress_resvconf_tx
            "Egress Out of Order Msgs Rx"        egress_out_of_order_msg_rx
            "Path-ERRs Tx"                       ingress_patherr_tx
            "Paths Tx"                           ingress_path_tx
            "Path Tears Tx"                      ingress_pathtear_tx
            "RESVs Rx"                           ingress_resv_rx
            "RESV Tears Rx"                      ingress_resvtear_rx
            "RESV-ERRs Tx"                       egress_resverr_tx
            "PATH Lifetime Expirations"          path_timeout_expirations
            "RESV-CONFs Rx"                      egress_resvconf_rx
            "Path-ERRs Rx"                       egress_patherr_rx
            "HELLOs Tx"                          hellos_tx
            "HELLOs Rx"                          hellos_rx
            "ACKs Tx"                            ack_tx
            "ACKs Rx"                            ack_rx
            "NACKs Tx"                           nack_tx
            "NACKs Rx"                           nack_rx
            "SREFRESHs Tx"                       srefresh_tx
            "SREFRESHs Rx"                       srefresh_rx
            "Bundle Messages Tx"                 bundle_tx
            "Bundle Messages Rx"                 bundle_rx
            "Paths with Recovery-Label Tx"       paths_recovery_label_tx
            "Paths with Recovery-Label Rx"       paths_recovery_label_rx
            "UnRecovered RESVs Deleted"          unrecovered_resvs_deleted
            "Own Graceful-Restarts"              own_graceful_restarts
            "Peer Graceful-Restarts"             peer_graceful_restarts
            "Down State Count"                   down_state_count
            "Path Sent State Count"              path_sent_state_count
            "Up State Count"                     up_state_count
        }
        
        set statistic_types {
            aggregate "RSVP Aggregated Statistics"
        }
        
        foreach {stat_type stat_name} $statistic_types {
            set stats_array_name stats_array_${stat_type}
            array set stats_array [array get $stats_array_name]

            set returned_stats_list [ixNetworkGetStats \
                    $stat_name [array names stats_array]]
            if {[keylget returned_stats_list status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to read\
                        $stat_name from stat view browser.\
                        [keylget returned_stats_list log]"
                return $returnList
            }

            set found_ports ""
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
                if {[lsearch $port_handles "$chassis_no/$card_no/$port_no"] != -1} {
                    set port_key $chassis_no/$card_no/$port_no
                    lappend found_ports $port_key
                    foreach stat [array names stats_array] {
                        if {[info exists rows_array($i,$stat)] && \
                                $rows_array($i,$stat) != ""} {
                            keylset returnList $stats_array($stat) \
                                    $rows_array($i,$stat)
                        } else {
                            keylset returnList $stats_array($stat) "N/A"
                        }
                    }
                }
            }
            if {[llength [lsort -unique $found_ports]] != \
                    [llength [lsort -unique $port_handles]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Retrieved statistics only for the\
                        following ports: $found_ports."
                return $returnList
            }
        }
        
        if {[keylget returnList inbound_lsp_count] == "N/A"} {
            if {[keylget returnList outbound_lsp_count] == "N/A"} {
                keylset returnList total_lsp_count "N/A"
            } else {
                keylset returnList total_lsp_count [keylget returnList outbound_lsp_count]
            }
        } else {
            if {[keylget returnList outbound_lsp_count] == "N/A"} {
                keylset returnList total_lsp_count [keylget returnList inbound_lsp_count]
            } else {
                keylset returnList total_lsp_count     \
                    [mpexpr [keylget returnList inbound_lsp_count] + [keylget returnList outbound_lsp_count]]
            }
        }

        # getting learned/assigned info
        set retCode [::ixia::getNeighborsLables $handle]
        if {[keylget retCode status] != $::SUCCESS} {
            keylset returnList log [keylget retCode log]
            keylset returnList status $::FAILURE
            return $returnList
        }
        set neighbors [keylget retCode neighbors]
        set lsps [keylget retCode lsps]
        keylset returnList lsp_count [keylget returnList total_lsp_count]
        keylset returnList num_lsp_setup [llength $lsps]
        keylset returnList peer_count [llength $neighbors]
    }
    if {$mode == "labels"} {
        set retCode [::ixia::getNeighborsLables $handle]
        if {[keylget retCode status] != $::SUCCESS} {
            keylset returnList log [keylget retCode log]
            keylset returnList status $::FAILURE
            return $returnList
        }
        keylset returnList labels [keylget retCode labels]
    }
    if {$mode == "neighbors"} {
        set retCode [::ixia::getNeighborsLables $handle]
        if {[keylget retCode status] != $::SUCCESS} {
            keylset returnList log [keylget retCode log]
            keylset returnList status $::FAILURE
            return $returnList
        }
        keylset returnList neighbors [keylget retCode neighbors]
    }
    if {$mode == "settings"} {
        set intf_ip_addr {}
        set neighbor_intf_ip_addr {}
        foreach handle_item $handle {
            regexp {::ixNet::OBJ-/vport:\d+/protocols/rsvp/neighborPair:\d+} \
                $handle_item cr_handle
            if {![info exists cr_handle]} {
                keylset returnList log "FAIL ixnetwork_rsvp_info: invalid input handle"
                keylset returnList status $::SUCCESS
            }
            debug "ixNet getAttr $cr_handle -ourIp"
            lappend intf_ip_addr [ixNet getAttr $cr_handle -ourIp]
            debug "ixNet getAttr $cr_handle -dutIp"
            lappend neighbor_intf_ip_addr [ixNet getAttr $cr_handle -dutIp]
        }
        keylset returnList intf_ip_addr $intf_ip_addr
        keylset returnList neighbor_intf_ip_addr $neighbor_intf_ip_addr
    }

    if {$mode == "clear_stats" && [info exists port_handle]} {
        debug "ixNet exec clearStats"
        if {[set retCode [catch {ixNet exec clearStats} retCode]]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to clear statistics."
            return $returnList
        }

#         foreach port $port_handle {
#             ::ixia::ixNetworkRemoveUserStats $port "RSVP"
#         }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::ixnetwork_rsvp_tunnel_info {args opt_args} {
    set procName [lindex [info level [info level]] 0]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    if {![info exists handle] && ![info exists port_handle]} {
        keylset returnList log "ERROR in $procName: Parameter -handle or\
                parameter -port_handle must be provided."
        keylset returnList status $::FAILURE
        return $returnList
    }
    
    # Check to see if a connection to the IxNetwork TCL Server already exists. 
    # If it doesn't, establish it.
    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    
    if {![info exists handle]} {
        set handle {}
        foreach port $port_handle {
            set oref_port $::ixia::ixnetwork_port_handles_array($port)
            lappend handle [ixNet getList $oref_port/protocols/rsvp neighborPair]
            debug "ixNet getList $oref_port/protocols/rsvp neighborPair"
        }
        set handle [join $handle]
    }  
    if {![info exists port_handle]} {
        set port_handle {}
        foreach handle_item $handle {
            regexp {::ixNet::OBJ-/vport:\d+} $handle_item port_objRef
            if {![info exists port_objRef]} {
                keylset returnList log "FAIL ixnetwork_rsvp_info: input handle corrupted!"
                keylset returnList status $::FAILURE
                return $returnList
            }
            lappend port_handle [::ixia::ixNetworkGetRouterPort $port_objRef]
        }
    }
    set port_handles $port_handle
    
    array set stats_array_aggregate {
        "Port Name"                          port_name
        "Ingress LSPs Configured"            outbound_lsp_count
        "Egress LSPs Up"                     inbound_lsp_count
        "Ingress LSPs Up"                    outbound_up_count
    }
    
    set statistic_types {
        aggregate "RSVP Aggregated Statistics"
    }

    foreach {stat_type stat_name} $statistic_types {
        set stats_array_name stats_array_${stat_type}
        array set stats_array [array get $stats_array_name]
    
        set returned_stats_list [ixNetworkGetStats \
                $stat_name [array names stats_array]]
        if {[keylget returned_stats_list status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to read\
                    $stat_name from stat view browser.\
                    [keylget returned_stats_list log]"
            return $returnList
        }
        set found_ports ""
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
            if {[lsearch $port_handles "$chassis_no/$card_no/$port_no"] != -1} {
                set port_key $chassis_no/$card_no/$port_no
                lappend found_ports $port_key
                foreach stat [array names stats_array] {
                    if {[info exists rows_array($i,$stat)] && \
                            $rows_array($i,$stat) != ""} {
                        keylset returnList $stats_array($stat) \
                                $rows_array($i,$stat)
                    } else {
                        keylset returnList $stats_array($stat) "N/A"
                    }
                }
            }
        }
        if {[llength [lsort -unique $found_ports]] != \
                [llength [lsort -unique $port_handles]]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Retrieved statistics only for the\
                    following ports: $found_ports."
            return $returnList
        }
    }

    
    set inbound_lsp_count   [keylget returnList inbound_lsp_count   ]
    set outbound_lsp_count  [keylget returnList outbound_lsp_count  ]
    set outbound_up_count   [keylget returnList outbound_up_count   ]
    
    if {$inbound_lsp_count == "N/A"} {
        if {$outbound_lsp_count == "N/A"} {
            keylset returnList total_lsp_count "N/A"
        } else {
            keylset returnList total_lsp_count $outbound_lsp_count
        }
    } else {
        if {$outbound_lsp_count == "N/A"} {
            keylset returnList total_lsp_count $inbound_lsp_count
        } else {
            keylset returnList total_lsp_count     \
                [mpexpr $inbound_lsp_count  + $outbound_lsp_count]
        }
    }
    
    if {$outbound_up_count == "N/A"} {
        if {$outbound_lsp_count == "N/A"} {
            keylset returnList outbound_down_count "N/A"
        } else {
            keylset returnList outbound_down_count $outbound_lsp_count
        }
    } else {
        if {$outbound_lsp_count == "N/A"} {
            keylset returnList outbound_down_count "N/A"
        } else {
            keylset returnList outbound_down_count \
                [mpexpr $outbound_lsp_count - $outbound_up_count ]
        }
    }
    
    
    # read with getList    
    set labels {}
    set handle_list $handle
    unset handle
    foreach handle_item $handle_list {
        set isP2MP 0
        set srcIP {}
        set dstIP {}
        set tunnelID {}
        set leafIp {}
        set lspId {}
        set reservationStateForGracefulRestart {}
        regexp {::ixNet::OBJ-/vport:\d+/protocols/rsvp/neighborPair:\d+} \
            $handle_item handle
        if {![info exists handle]} {
            keylset returnList log "FAIL on getNeighborsLables: \
            handle $handle_item invalid"
            keylset returnList status ::FAILURE
            return $returnList
        }
        
        set count 0

        if {$info_type == "assigned_info" || $info_type == "both"} {
            debug "ixNet exec refreshAssignedLabelInfo $handle"
            ixNet exec refreshAssignedLabelInfo $handle

            debug "ixNet getAttr $handle -isAssignedInfoRefreshed"
            while {![ixNet getAttr $handle -isAssignedInfoRefreshed]} {
                after 500
                if {$count > 100} {
                    debug "ixNet getAttr $handle -isAssignedInfoRefreshed"
                    keylset returnList status $::FAILURE
                    keylset returnList log "FAILURE on ixnetwork_rsvp_tunnel_info: \
                        timeout occured retriving stats!"
                    return $returnList
                }
                incr count
            }
            # because of "as designed" 119948 we wait more....
            after 1000
            debug "ixNet getList $handle assignedLabel"
            set assignedLabelInfo [ixNet getList $handle assignedLabel]
            foreach assignedLabel $assignedLabelInfo {
                debug "ixNet getAttr $assignedLabel -label"
                lappend labels [ixNet getAttr $assignedLabel -label]
                debug "ixNet getAttr $assignedLabel -sourceIp"
                lappend srcIP [ixNet getAttr $assignedLabel -sourceIp]
                debug "ixNet getAttr $assignedLabel -destinationIp"
                lappend dstIP [ixNet getAttr $assignedLabel -destinationIp]
                debug "ixNet getAttr $assignedLabel -tunnelId"
                lappend tunnelID [ixNet getAttr $assignedLabel -tunnelId]
                if {[ixNet getAttr $assignedLabel -type] == "P2MP"} {
                    set isP2MP 1
                    debug "ixNet getAttr $assignedLabel -leafIp"
                    lappend leafIp [ixNet getAttr $assignedLabel -leafIp]
                    debug "ixNet getAttr $assignedLabel -lspId"
                    lappend lspId [ixNet getAttr $assignedLabel -lspId]
                    debug "ixNet getAttr $assignedLabel -reservationState"
                    lappend reservationStateForGracefulRestart [ixNet getAttr $assignedLabel -reservationState]
                }
            }
        }
        
        if {$info_type == "received_info" || $info_type == "both"} {
            debug "ixNet exec refreshReceivedLabelInfo $handle"
            ixNet exec refreshReceivedLabelInfo $handle

            while {![ixNet getAttr $handle -isLearnedInfoRefreshed]} {
                after 500
                if {$count > 100} {
                    debug "ixNet getAttr $handle -isLearnedInfoRefreshed"
                    keylset returnList status $::FAILURE
                    keylset returnList log "FAILURE on ixnetwork_rsvp_tunnel_info: \
                        timeout occured retriving stats!"
                    return $returnList
                }
                incr count
            }
            
            # because of "as designed" 119948 we wait more....
            after 1000
            debug "ixNet getList $handle receivedLabel"
            set receivedLabelInfo [ixNet getList $handle receivedLabel]
            foreach receivedLabel $receivedLabelInfo {
                debug "ixNet getAttr $receivedLabel -label"
                lappend labels [ixNet getAttr $receivedLabel -label]
                debug "ixNet getAttr $receivedLabel -sourceIP"
                lappend srcIP [ixNet getAttr $receivedLabel -sourceIp]
                debug "ixNet getAttr $receivedLabel -destinationIp"
                lappend dstIP [ixNet getAttr $receivedLabel -destinationIp]
                debug "ixNet getAttr $receivedLabel -tunnelId"
                lappend tunnelID [ixNet getAttr $receivedLabel -tunnelId]
                if {[ixNet getAttr $receivedLabel -type] == "P2MP"} {
                    set isP2MP 1
                    debug "ixNet getAttr $receivedLabel -leafIp"
                    lappend leafIp [ixNet getAttr $receivedLabel -leafIp]
                    debug "ixNet getAttr $receivedLabel -lspId"
                    lappend lspId [ixNet getAttr $receivedLabel -lspId]
                    debug "ixNet getAttr $receivedLabel -reservationState"
                    lappend reservationStateForGracefulRestart [ixNet getAttr $receivedLabel -reservationState]
                }
            }
        }
        
        keylset returnList ingress_ip.$handle_item [lsort -unique $srcIP]
        keylset returnList egress_ip.$handle_item  [lsort -unique $dstIP]
        keylset returnList tunnel_id.$handle_item  [lsort -unique $tunnelID]
        
        if {$leafIp == ""} {
            set leafIp "NA"
        }
        if {$lspId == ""} {
            set lspId "NA"
        }
        if {$reservationStateForGracefulRestart == ""} {
            set graceful_restart_reservation_state "NA"
        }
        
        keylset returnList leaf_ip.$handle_item  [lsort -unique $leafIp]
        keylset returnList lsp_id.$handle_item  [lsort -unique $lspId]
        keylset returnList graceful_restart_reservation_state.$handle_item  [lsort -unique $reservationStateForGracefulRestart]
        
    }
    keylset returnList label [lsort -unique $labels]
    keylset returnList status $::SUCCESS
    return $returnList
}
