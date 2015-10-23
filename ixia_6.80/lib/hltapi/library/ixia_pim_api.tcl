##Library Header
# $Id: $
# Copyright © 2003-2009 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_pim_api.tcl
#
# Purpose:
#     A script development library containing PIM APIs for test automation
#     with the Ixia chassis.
#
# Author:
#    T. Kong
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures contained within this library include:
#
#    - emulation_pim_config
#    - emulation_pim_group_config
#    - emulation_pim_control
#    - emulation_pim_info
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

proc ::ixia::emulation_pim_config { args } {
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
                \{::ixia::emulation_pim_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    variable bgp_neighbor_handles_array
    variable bgp_route_handles_array
    variable new_ixnetwork_api

    ::ixia::utrackerLog $procName $args

    # Arguments
    set man_args {
        -port_handle    REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -mode           CHOICES create modify delete disable enable enable_all disable_all
                        DEFAULT create
    }

    set opt_args {
        -handle
        -interface_handle
        -pim_mode                   CHOICES sm ssm
                                    DEFAULT sm
        -type                       CHOICES remote_rp
        -ip_version                 CHOICES 4 6
                                    DEFAULT 4
        -bootstrap_enable           CHOICES 0 1
                                    DEFAULT 0
        -bootstrap_support_unicast  CHOICES 0 1
                                    DEFAULT 1
        -bootstrap_hash_mask_len    RANGE   0-128
        -bootstrap_interval         RANGE   0-65535
                                    DEFAULT 60
        -bootstrap_priority         RANGE   0-255
                                    DEFAULT 64
        -bootstrap_timeout          RANGE   0-65535
                                    DEFAULT 130
        -count                      NUMERIC
                                    DEFAULT 1
        -intf_ip_addr               IP
        -intf_ip_addr_step          IP
        -intf_ip_prefix_length      RANGE 1-128
        -intf_ip_prefix_len         RANGE 1-128
        -learn_selected_rp_set      CHOICES 0 1
                                    DEFAULT 1
        -discard_learnt_rp_info     CHOICES 0 1
                                    DEFAULT 0
        -router_id                  IP
        -router_id_step             IP
        -gateway_intf_ip_addr       IP
        -gateway_intf_ip_addr_step  IP
        -neighbor_intf_ip_addr      IP
        -neighbor_intf_ip_addr_step IP
        -dr_priority                NUMERIC
                                    DEFAULT 0
        -bidir_capable              CHOICES 0 1
                                    DEFAULT 0
        -hello_interval             NUMERIC
                                    DEFAULT 30
        -hello_holdtime             NUMERIC
                                    DEFAULT 105
        -join_prune_interval        NUMERIC
                                    DEFAULT 60
        -join_prune_holdtime        NUMERIC
                                    DEFAULT 180
        -prune_delay_enable         CHOICES 0 1
                                    DEFAULT 0
        -prune_delay                RANGE 100-32767
                                    DEFAULT 500
        -override_interval          RANGE 100-65535
                                    DEFAULT 2500
        -vlan_id                    RANGE 0-4096
        -vlan_id_mode               CHOICES fixed increment
                                    DEFAULT increment
        -vlan_id_step               RANGE 0-4096
                                    DEFAULT 1
        -vlan_user_priority         RANGE 0-7
                                    DEFAULT 0
        -vlan_cfi                   CHOICES 0 1
        -mvpn_enable                CHOICES 0 1
                                    DEFAULT 0
        -mvpn_pe_count              NUMERIC
                                    DEFAULT 1
        -mvpn_pe_ip                 IP
        -mvpn_pe_ip_incr            IP
        -mvrf_count                 NUMERIC
        -mvrf_unique                CHOICES 0 1
                                    DEFAULT 0
        -default_mdt_ip             IP
        -default_mdt_ip_incr        IP
        -gre_checksum_enable        CHOICES 0 1
                                    DEFAULT 0
        -gre_key_enable             CHOICES 0 1
                                    DEFAULT 0
        -gre_key_in                 RANGE 0-4294967295
                                    DEFAULT 0
        -gre_key_out                RANGE 0-4294967295
                                    DEFAULT 0
        -reset
        -generation_id_mode         CHOICES increment random constant
        -prune_delay_tbit           CHOICES 0 1
        -send_generation_id         CHOICES 0 1
        -mac_address_init           MAC
        -mac_address_step           MAC
                                    DEFAULT 0000.0000.0001
        -vlan                       CHOICES 0 1
        -writeFlag                  CHOICES write nowrite
                                    DEFAULT write
        -no_write                   FLAG
        -gre                        CHOICES 0 1
                                    DEFAULT 0
        -gre_enable                 CHOICES 0 1
                                    DEFAULT 0
        -gre_unique                 CHOICES 0 1
                                    DEFAULT 1
        -gre_dst_ip_addr            IP
        -gre_count                  NUMERIC
                                    DEFAULT 1
        -gre_ip_addr                IP
        -gre_ip_addr_step           IP
        -gre_ip_addr_lstep          IP
        -gre_ip_addr_cstep          IP
        -gre_ip_prefix_length       RANGE   1-128
        -gre_dst_ip_addr_step       IP
        -gre_dst_ip_addr_lstep      IP
        -gre_dst_ip_addr_cstep      IP
        -gre_key_in_step            RANGE 0-4294967295
                                    DEFAULT 0
        -gre_key_out_step           RANGE 0-4294967295
                                    DEFAULT 0
        -gre_src_ip_addr_mode       CHOICES routed connected
                                    DEFAULT connected
        -gre_seq_enable             CHOICES 0 1
                                    DEFAULT 0
        -loopback_count             NUMERIC
                                    DEFAULT 0
        -loopback_ip_address        IP
        -loopback_ip_address_step   IP
        -loopback_ip_address_cstep  IP
    }
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_pim_config $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList log "ERROR in $procName:\
                    [keylget returnList log]"
        }
        return $returnList
    }

    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg."
        return $returnList
    }

    if {[info exists intf_ip_prefix_len]} {
        set intf_ip_prefix_length $intf_ip_prefix_len
    }

    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
    }

    array set enumList [list \
            increment       $::pimsmGenerationIdModeIncremental \
            random          $::pimsmGenerationIdModeRandom      \
            constant        $::pimsmGenerationIdModeConstant    \
            ]

    ###############################################################
    ### Map Ixia IxTclHal Command Options to Cisco's HLTAPI Options
    ###############################################################

    array set pimsmInterface [list \
            enable                          enable                      \
            ipType                          local_ip_version            \
            neighborIp                      neighbor_intf_ip_addr       \
            enableSendBidirectionalOption   bidir_capable               \
            helloInterval                   hello_interval              \
            helloHoldTime                   hello_holdtime              \
            enablePruneDelay                prune_delay_enable          \
            pruneDelay                      prune_delay                 \
            overrideInterval                override_interval           \
            enablePruneDelayTBit            prune_delay_tbit            \
            enableSendGenerationId          send_generation_id          \
            generationIdMode                generation_id_mode          \
            enableBootstrap                 bootstrap_enable            \
            supportUnicastBootstrap         bootstrap_support_unicast   \
            bootstrapHashMaskLen            bootstrap_hash_mask_len     \
            bootstrapInterval               bootstrap_interval          \
            bootstrapPriority               bootstrap_priority          \
            bootstrapTimeout                bootstrap_timeout           \
            learnSelectedRPSet              learn_selected_rp_set       \
            discardLearntRPInfo             discard_learnt_rp_info      \
            ]

    array set pimsmRouter [list \
            enable                          enable                      \
            routerId                        router_id                   \
            drPriority                      dr_priority                 \
            joinPruneHoldTime               join_prune_holdtime         \
            joinPruneInterval               join_prune_interval         \
            ]

    set port_list [format_space_port_list $port_handle]
    set interface [lindex $port_list 0]
    # Set chassis card port
    foreach {chasNum cardNum portNum} $interface {}
    ::ixia::addPortToWrite $chasNum/$cardNum/$portNum
    
    # Check if PIMSM protocol is supported
    if {![port isValidFeature $chasNum $cardNum $portNum \
                portFeatureProtocolPIMSM]} {
        
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName : This card does not\
                support PIMSM protocol."
        return $returnList
    }

    # Check if PIM package has been installed on the port
    if {[catch {pimsmServer select $chasNum $cardNum $portNum} retCode]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The PIM protocol\
                has not been installed on port or is not supported on port: \
                $chasNum/$cardNum/$portNum."
        return $returnList
    }
    
    if { $mode == "create" || $mode == "modify" || $mode == "enable" || \
            $mode == "enable_all"} {
        set enable $::true
    } else {
        set enable $::false
    }

    set pimsm_modify_flag 0
    
    # Check if the call is for modify or delete
    if {$mode == "modify" || $mode == "enable" || $mode == "disable"} {
        if {![info exists handle]} {
            keylset returnList log "ERROR in $procName: No -handle was\
                    passed to modify the pimsm TE on port\
                    $chasNum $cardNum $portNum."
            keylset returnList status $::FAILURE
            return $returnList
        } elseif {[llength $handle] > 1} {
            keylset returnList log "ERROR in $procName: When -mode is modify,\
                -handle may only contain one value."
            keylset returnList status $::FAILURE
            return $returnList
        } else {
            set pimsm_modify_flag 1
        }
        if {![info exists count]} {
            set count 1
        }
    }
    
    if {($mode != "create") && ($mode != "modify")} {
        if {[pimsmServer select $chasNum $cardNum $portNum]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to do\
                    pimsmServer select on port $chasNum $cardNum  $portNum."
            return $returnList
        }
    }
    
    if {$mode == "delete"} {
        if {[info exists handle]} {
            foreach item $handle {
                if {[pimsmServer delRouter $handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to\
                            delete the pimsm $handle on port\
                            $chasNum $cardNum $portNum."
                    return $returnList
                }
            }
            if {[pimsmServer set]} {
                keylset returnList log "ERROR in $procName: \
                        Failed pimsmServer set call after deleting \
                        the handle $handle on port $chasNum $cardNum $portNum."
                keylset returnList status $::FAILURE
                return $returnList
            }
            
            set retCode [::ixia::updatePimsmHandleArray \
                    -mode         delete                \
                    -handle_name  $handle               ]
            
            if {[keylget retCode status] == 0} {
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]."
                keylset returnList status $::FAILURE
                return $returnList
            }

            keylset returnList handle $handle
        } else {
            if {[initializePimsm $chasNum $cardNum $portNum]} {
                keylset returnList log "ERROR in $procName: Failed to\
                        initialize pimsm on port $chasNum.$cardNum.$portNum."
                keylset returnList status $::FAILURE
                return $returnList
            }
            
            set retCode [::ixia::updatePimsmHandleArray \
                    -mode                reset          \
                    -handle_name_pattern $port_handle   ]
            
            if {[keylget retCode status] == 0} {
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]."
                keylset returnList status $::FAILURE
                return $returnList
            }

            keylset returnList handle [getAllPimsmRouterHandles $port_handle]
        }
    }

    if {$mode == "disable" || $mode == "enable"} {
        foreach item $handle {
            if {[pimsmServer getRouter $handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to issue\
                        pimsmServer getRouter $handle command on port $chasNum\
                        $cardNum $portNum."
                return $returnList
            }
            pimsmRouter config -enable $enable
            if {[pimsmServer setRouter $handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to issue\
                        pimsmServer setRouter $handle command on port $chasNum\
                        $cardNum $portNum."
                return $returnList
            }
        }
        if {[pimsmServer set]} {
            keylset returnList log "ERROR in $procName: Failed to issue\
                    pimsmServer set command on port $chasNum $cardNum $portNum."
            keylset returnList status $::FAILURE
            return $returnList
        }

        keylset returnList handle $handle
    }

     if {$mode == "disable_all" || $mode == "enable_all"} {
        if {[pimsmServer getFirstRouter]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to issue\
                    pimsmServer getFirstRouter command on port $chasNum\
                    $cardNum $portNum."
            return $returnList
        }
        pimsmRouter config -enable $enable
        if {[pimsmServer setRouter]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to issue\
                    pimsmServer setRouter command on port $chasNum $cardNum\
                    $portNum."
            return $returnList
        }
        while {![pimsmServer getNextRouter]} {
            pimsmRouter config -enable $enable
            if {[pimsmServer setRouter]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to issue\
                        pimsmServer setRouter command on port $chasNum\
                        $cardNum $portNum."
                return $returnList
            }
        }
        if {[pimsmServer set]} {
            keylset returnList log "ERROR in $procName: Failed to issue\
                    pimsmServer set on port $chasNum $cardNum $portNum."
            keylset returnList status $::FAILURE
            return $returnList
        }

        keylset returnList handle [getAllPimsmRouterHandles $port_handle]
    }
    
    if {($mode != "create") && ($mode != "modify")} {
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
    
    set max_nodes    $count

    ### Ixia only supports one neighbor per pimsmInterface
    if {[info exists neighbor_intf_ip_addr]} {
        set neighbor_intf_ip_addr  [lindex $neighbor_intf_ip_addr 0]
    }

    if {$pimsm_modify_flag == 0} {
        #################################
        #  CONFIGURE THE IXIA INTERFACES
        #################################
        if {![info exists vlan] && [info exists vlan_id]} {
            set vlan $::true
        }

        if {$ip_version == "4"} {
            set param_value_list [list \
                intf_ip_addr            0.0.0.0 \
                intf_ip_addr_step       0.0.1.0 \
                intf_ip_prefix_length   24      \
                neighbor_intf_ip_addr   0.0.0.0 \
                gateway_intf_ip_addr    0.0.0.0 \
                gateway_intf_ip_addr_step 0.0.0.1 \
                gre_ip_addr_step          0.0.1.0 \
                ]
        } else {
            set param_value_list [list \
                intf_ip_addr            0::1        \
                intf_ip_addr_step       0:0:0:1::0  \
                intf_ip_prefix_length   64          \
                neighbor_intf_ip_addr   0::1        \
                gateway_intf_ip_addr    0::0 \
                gateway_intf_ip_addr_step 0::1 \
                gre_ip_addr_step          0::1:0 \
                ]
        }

        foreach {param value} $param_value_list {
            if {![info exists $param]} {
                set $param $value
            }
        }
        
        if {![info exists router_id]} {
            if {$ip_version == "4"} {
                set router_id      $intf_ip_addr
            } else {
                set router_id      0.0.0.1
            }
        }
        
        if {![info exists router_id_step]} {
            if {$ip_version == "4"} {
                set router_id_step $intf_ip_addr_step
            } else {
                set router_id_step 0.0.0.1
            }
        }

        if {$mvpn_enable} {
            set config_options \
                    "-port_handle             port_handle              \
                    -count                    max_nodes                \
                    -ip_address               intf_ip_addr             \
                    -ip_address_step          intf_ip_addr_step        \
                    -gateway_ip_address       gateway_intf_ip_addr     \
                    -gateway_ip_address_step  gateway_intf_ip_addr_step\
                    -netmask                  intf_ip_prefix_length    \
                    -ip_version               ip_version               \
                    -mac_address              mac_address_init         \
                    -vlan_id                  vlan_id                  \
                    -vlan_id_mode             vlan_id_mode             \
                    -vlan_id_step             vlan_id_step             \
                    -vlan_user_priority       vlan_user_priority       \
                    -loopback_ip_address      mvpn_pe_ip               \
                    -loopback_ip_address_step mvpn_pe_ip_incr          \
                    -loopback_count           mvpn_pe_count            \
                    -gre_enable               mvpn_enable              \
                    -gre_unique               mvrf_unique              \
                    -gre_dst_ip_address       default_mdt_ip           \
                    -gre_dst_ip_address_step  default_mdt_ip_incr      \
                    -gre_count                mvrf_count               \
                    -gre_checksum_enable      gre_checksum_enable      \
                    -gre_seq_enable           gre_seq_enable           \
                    -gre_key_enable           gre_key_enable           \
                    -gre_key_in               gre_key_in               \
                    -gre_key_out              gre_key_out              \
                    -no_write                 no_write                 "
        } else  {
            if {[info exists gre] && $gre} {
                # This is done to make sure we are compatible with a workaround implemented
                # at the customer site.
                set config_options \
                    "-port_handle             port_handle              \
                    -count                    max_nodes                \
                    -ip_address               intf_ip_addr             \
                    -ip_address_step          intf_ip_addr_step        \
                    -gateway_ip_address       gateway_intf_ip_addr     \
                    -gateway_ip_address_step  gateway_intf_ip_addr_step\
                    -netmask                  intf_ip_prefix_length    \
                    -ip_version               ip_version               \
                    -mac_address              mac_address_init         \
                    -vlan_id                  vlan_id                  \
                    -vlan_id_mode             vlan_id_mode             \
                    -vlan_id_step             vlan_id_step             \
                    -vlan_user_priority       vlan_user_priority       \
                    -loopback_ip_address      mvpn_pe_ip               \
                    -loopback_ip_address_step mvpn_pe_ip_incr          \
                    -loopback_count           mvpn_pe_count            \
                    -gre_enable               gre                      \
                    -gre_unique               mvrf_unique              \
                    -gre_dst_ip_address       default_mdt_ip           \
                    -gre_dst_ip_address_step  default_mdt_ip_incr      \
                    -gre_count                mvrf_count               \
                    -gre_checksum_enable      gre_checksum_enable      \
                    -gre_seq_enable           gre_seq_enable           \
                    -gre_key_enable           gre_key_enable           \
                    -gre_key_in               gre_key_in               \
                    -gre_key_out              gre_key_out              \
                    -no_write                 no_write                 "
                    
            } else {
                
                set use_advanced_prot_intf 1
                
                set config_options \
                        "-port_handle              port_handle              \
                        -count                     max_nodes                \
                        -ip_address                intf_ip_addr             \
                        -ip_address_step           intf_ip_addr_step        \
                        -gateway_ip_address        gateway_intf_ip_addr     \
                        -gateway_ip_address_step   gateway_intf_ip_addr_step\
                        -netmask                   intf_ip_prefix_length    \
                        -ip_version                ip_version               \
                        -mac_address               mac_address_init         \
                        -vlan_id                   vlan_id                  \
                        -vlan_id_mode              vlan_id_mode             \
                        -vlan_id_step              vlan_id_step             \
                        -vlan_user_priority        vlan_user_priority       \
                        -gre_enable                gre_enable               \
                        -gre_checksum_enable       gre_checksum_enable      \
                        -gre_key_enable            gre_key_enable           \
                        -gre_key_in                gre_key_in               \
                        -gre_key_out               gre_key_out              \
                        -gre_unique                gre_unique               \
                        -gre_dst_ip_addr           gre_dst_ip_addr          \
                        -gre_count                 gre_count                \
                        -gre_ip_addr               gre_ip_addr              \
                        -gre_ip_addr_step          gre_ip_addr_step         \
                        -gre_ip_addr_lstep         gre_ip_addr_lstep        \
                        -gre_ip_addr_cstep         gre_ip_addr_cstep        \
                        -gre_ip_prefix_length      gre_ip_prefix_length     \
                        -gre_dst_ip_addr_step      gre_dst_ip_addr_step     \
                        -gre_dst_ip_addr_lstep     gre_dst_ip_addr_lstep    \
                        -gre_dst_ip_addr_cstep     gre_dst_ip_addr_cstep    \
                        -gre_key_in_step           gre_key_in_step          \
                        -gre_key_out_step          gre_key_out_step         \
                        -gre_src_ip_addr_mode      gre_src_ip_addr_mode     \
                        -loopback_count            loopback_count           \
                        -loopback_ip_address       loopback_ip_address      \
                        -loopback_ip_address_step  loopback_ip_address_step \
                        -loopback_ip_address_cstep loopback_ip_address_cstep\
                        -no_write                  no_write                 "
            }
        }

        ## passed in only those options that exists
        set config_param ""
        foreach {option value_name} $config_options {
            if {[info exists $value_name]} {
                append config_param "$option [set $value_name] "
            }
        }

        if {[info exists interface_handle] && !$mvpn_enable} {
            foreach item $interface_handle {
                lappend description_list [rfget_interface_description_from_handle $item]
            }
        } else {
            if {[info exists use_advanced_prot_intf] && $use_advanced_prot_intf} {
                set intf_status [eval ixia::protocol_interface_config_advanced \
                        $config_param]
                if {[keylget intf_status status] == $::FAILURE} {
                    keylset returnList log "ERROR in $procName: Failed in\
                            protocol_interface_config_advanced call on\
                            port $chasNum $cardNum $portNum. \
                            [keylget intf_status log] \n$::ixErrorInfo"
                    keylset returnList status $::FAILURE
                    return $returnList
                }
                set description_list [keylget intf_status description]
            } else {
                set intf_status [eval ixia::protocol_interface_config \
                        $config_param]
                
                if {[keylget intf_status status] == $::FAILURE} {
                    keylset returnList log "ERROR in $procName: Failed in\
                            protocol_interface_config call on\
                            port $chasNum $cardNum $portNum. \
                            [keylget intf_status log] \n$::ixErrorInfo"
                    keylset returnList status $::FAILURE
                    return $returnList
                }
                set description_list [keylget intf_status description]
            }
        }
    }

    if {[pimsmServer select $chasNum $cardNum $portNum]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed to do\
                pimsmServer select on port $chasNum $cardNum  $portNum."
        return $returnList
    }
    
    if {[info exists reset]} {
        if {[pimsmServer clearAllRouters]} {
            keylset returnList log "ERROR in $procName: Failed on pimsmServer\
                    clearAllRouter call."
            keylset returnList status $::FAILURE
            return $returnList
        }
        
        set retCode [::ixia::updatePimsmHandleArray \
                -mode                reset          \
                -handle_name_pattern $port_handle   ]
                
        if {[keylget retCode status] == 0} {
            keylset returnList log "ERROR in $procName: \
                    [keylget retCode log]."
            keylset returnList status $::FAILURE
            return $returnList
        }
    }

    if {$ip_version == 4} {
        set local_ip_version $::addressTypeIpV4
    } else {
        set local_ip_version $::addressTypeIpV6
    }
    
    set pimsm_router_list [list]
    set pimsm_interface_list [list]
    for {set nodeId 1} {$nodeId <= $max_nodes} {incr nodeId} {
        pimsmRouter clearAllInterfaces
        if {$pimsm_modify_flag} {
            set next_pim_router $handle
            set retCode [::ixia::getAllPimsmInterfaceHandles \
                    $chasNum/$cardNum/$portNum $handle]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]."
                return $returnList
            }
            set pimsmIntfList [keylget retCode handles]
            
            if {[pimsmServer getRouter $next_pim_router]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed on\
                        pimsmServer getRouter $next_pim_router call on port\
                        $chasNum $cardNum $portNum."
                return $returnList
            }
            foreach {pimsmIntfElem} [lsort -dictionary $pimsmIntfList] {
                if {[pimsmRouter getInterface $pimsmIntfElem]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed on\
                            pimsmRouter getInterface $pimsmIntfElem call on port\
                            $chasNum $cardNum $portNum. $::ixErrorInfo"
                    return $returnList
                }
                foreach item [array names pimsmInterface] {
                    if {![catch {set $pimsmInterface($item)} value] } {
                        if {[lsearch [array names enumList] $value] != -1} {
                            set value $enumList($value)
                        }
                        catch {pimsmInterface config -$item $value}
                    }
                }
                if {[pimsmRouter setInterface $pimsmIntfElem]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed on\
                            pimsmRouter setInterface $pimsmIntfElem call on port\
                            $chasNum $cardNum $portNum."
                    return $returnList
                }
            }
            
            foreach item [array names pimsmRouter] {
                if {![catch {set $pimsmRouter($item)} value] } {
                    if {[lsearch [array names enumList] $value] != -1} {
                        set value $enumList($value)
                    }
                    catch {pimsmRouter config -$item $value}
                }
            }
        } else {
            # Add PIM-SM Router (MVPN - PROVIDER)
            
            # Get next router handle
            set retCode [::ixia::getNextPimsmLabel \
                    -port_handle      $port_handle \
                    -handle_name      pimsmRouter  \
                    -handle_type      session      ]
            if {[keylget retCode status] == 0} {
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]."
                keylset returnList status $::FAILURE
                return $returnList
            }
            set next_pim_router [keylget retCode next_handle]
            
            # Configure interface options
            if $gre {
                set loopDescription \
                    [keylget intf_status [lindex $description_list [expr $nodeId - 1]].loopback] 
                set intfDesc [lindex [keylget intf_status \
                    [lindex $description_list [expr $nodeId - 1]].[lindex $loopDescription 0]] 0]
                
            } elseif {[info exists use_advanced_prot_intf] && $use_advanced_prot_intf} {
                
                if {[info exists gre_enable] && $gre_enable && $gre_count > 0} {
                    # Use GRE protocol interfaces as pim interfaces
                    
                    if {[info exists gre_src_ip_addr_mode] && $gre_src_ip_addr_mode == "routed"} {
                        # gre type is routed
                        
                        set intfDesc ""
                        set loopDescription \
                            [keylget intf_status [lindex $description_list [expr $nodeId - 1]].loopback]
                        
                        foreach tmp_loop_descr $loopDescription {
                            foreach tmp_gre_descr [keylget intf_status [lindex $description_list [expr $nodeId - 1]].$tmp_loop_descr] {
                                lappend intfDesc $tmp_gre_descr
                            }
                        }
                        
                        catch {unset tmp_loop_descr}
                        catch {unset tmp_gre_descr}
                        
                    } else {
                        # gre type is connected
                        set intfDesc \
                            [keylget intf_status [lindex $description_list [expr $nodeId - 1]].gre]
                    }
                    
                } elseif {[info exists loopback_count] && $loopback_count > 0} {
                    # Use UNCONNECTED protocol interfaces as pim interfaces
                    set intfDesc \
                        [keylget intf_status [lindex $description_list [expr $nodeId - 1]].loopback]
                    
                } else {
                    set intfDesc [lindex $description_list [expr $nodeId - 1]]
                }
                
            } else {
                
                set intfDesc [lindex $description_list [expr $nodeId - 1]]
            }
            
            if {![regexp "^\{\{" $intfDesc]} {
                set intfDesc [list $intfDesc]
            }
            foreach singleIntfDesc $intfDesc {
                # Set default interface
                pimsmInterface setDefault

                if {[llength $description_list] >= $nodeId} {
                    if {[llength $singleIntfDesc] > 1} {
                        pimsmInterface config -protocolInterfaceDescription \
                                $singleIntfDesc
                    } else {
                        pimsmInterface config -protocolInterfaceDescription \
                                [lindex $singleIntfDesc 0]
                    }
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: The protocol\
                            interface table setup did not return the proper\
                            descriptions to be used.  Please check setup."
                    return $returnList
                }
                
                foreach item [array names pimsmInterface] {
                    if {![catch {set $pimsmInterface($item)} value] } {
                        if {[lsearch [array names enumList] $value] != -1} {
                            set value $enumList($value)
                        }
                        catch {pimsmInterface config -$item $value}
                    }
                }
                
                # Get the next interface handle
                set retCode [::ixia::getNextPimsmLabel    \
                        -port_handle      $port_handle    \
                        -handle_name      pimsmInterface  \
                        -handle_type      interface       ]
                if {[keylget retCode status] == 0} {
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]."
                    keylset returnList status $::FAILURE
                    return $returnList
                }
                set next_pim_intf [keylget retCode next_handle]
                
                # Add interface to hardware
                if {[pimsmRouter addInterface $next_pim_intf]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to\
                            pimsmRouter addInterface $next_pim_intf\
                            on port $chasNum $cardNum $portNum."
                    return $returnList
                }
                lappend pimsm_interface_list $next_pim_intf
                
                # Add interface to internal array
                set param_list "\
                        -mode                create           \
                        -handle_name         $next_pim_intf   \
                        -handle_type         interface        \
                        -handle_value        $next_pim_router "
                
                if {$mvpn_enable} {
                    append param_list "\
                            -mvpn_enable          1            \
                            -mvrf_unique          $mvrf_unique "
                }
                
                set retCode [eval ::ixia::updatePimsmHandleArray $param_list]
                if {[keylget retCode status] == 0} {
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]."
                    keylset returnList status $::FAILURE
                    return $returnList
                }
            }
            
            # Set default router
            pimsmRouter setDefault
            
            # Configure router options
            foreach item [array names pimsmRouter] {
                if {![catch {set $pimsmRouter($item)} value] } {
                    if {[lsearch [array names enumList] $value] != -1} {
                        set value $enumList($value)
                    }
                    catch {pimsmRouter config -$item $value}
                }
            }
            
            # Add router to hardware
            if {[pimsmServer addRouter $next_pim_router]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to\
                        pimsmServer addRouter $next_pim_router on port\
                        $chasNum $cardNum $portNum."
                return $returnList
            }
            
            # Add router to return list
            lappend pimsm_router_list $next_pim_router
            
            # Add router to internal array
            set param_list "\
                    -mode                create           \
                    -handle_name         $next_pim_router \
                    -handle_type         session          \
                    -handle_value        $port_handle     "
            
            if {$mvpn_enable} {
                append param_list "\
                        -mvpn_enable          1            \
                        -mvrf_unique          $mvrf_unique "
            }
            set retCode [eval ::ixia::updatePimsmHandleArray $param_list]
            if {[keylget retCode status] == 0} {
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]."
                keylset returnList status $::FAILURE
                return $returnList
            }
            
            if {$mvpn_enable} {
                set default_mdt_ip_start $default_mdt_ip
                foreach {loop_description} [keylget intf_status \
                        [lindex $description_list [expr $nodeId - 1]].loopback] {
                    
                    # Get next router handle
                    set retCode [::ixia::getNextPimsmLabel \
                            -port_handle      $port_handle \
                            -handle_name      pimsmRouter  \
                            -handle_type      session      ]
                    if {[keylget retCode status] == 0} {
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]."
                        keylset returnList status $::FAILURE
                        return $returnList
                    }
                    set next_pim_router [keylget retCode next_handle]
                    
                    set default_mdt_ip_list [list]
                    if {$mvrf_unique == 0} {
                        set default_mdt_ip $default_mdt_ip_start
                    }
                    foreach {gre_description} [keylget intf_status  \
                            [lindex $description_list [expr $nodeId \
                            - 1]].$loop_description] {
                        # Set default interface
                        pimsmInterface setDefault
                        
                        # Configure interface options
                        pimsmInterface config -protocolInterfaceDescription \
                                $gre_description
                        
                        foreach item [array names pimsmInterface] {
                            if {![catch {set $pimsmInterface($item)} value] } {
                                if {[lsearch [array names enumList] $value] != -1} {
                                    set value $enumList($value)
                                }
                                catch {pimsmInterface config -$item $value}
                            }
                        }
                        
                        # Get next interface handle
                        set retCode [::ixia::getNextPimsmLabel    \
                                -port_handle      $port_handle    \
                                -handle_name      pimsmInterface  \
                                -handle_type      interface       ]
                        if {[keylget retCode status] == 0} {
                            keylset returnList log "ERROR in $procName: \
                                    [keylget retCode log]."
                            keylset returnList status $::FAILURE
                            return $returnList
                        }
                        set next_pim_intf [keylget retCode next_handle]
                        
                        # Add interface to hardware
                        if {[pimsmRouter addInterface $next_pim_intf]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Failed to\
                                    pimsmRouter addInterface $next_pim_intf\
                                    on port $chasNum $cardNum $portNum."
                            return $returnList
                        }
                        lappend pimsm_interface_list $next_pim_intf
                        # Add interface to internal array
                        set param_list "\
                                -mode                create           \
                                -handle_name         $next_pim_intf   \
                                -handle_type         interface        \
                                -handle_value        $next_pim_router "
                        
                        if {$mvpn_enable} {
                            append param_list "\
                                    -mvpn_enable     1               \
                                    -default_mdt_ip  $default_mdt_ip \
                                    -mvrf_unique     $mvrf_unique    "
                            
                            lappend default_mdt_ip_list $default_mdt_ip
                        }
                        set retCode [eval ::ixia::updatePimsmHandleArray \
                                $param_list]
                        if {[keylget retCode status] == 0} {
                            keylset returnList log "ERROR in $procName: \
                                    [keylget retCode log]."
                            keylset returnList status $::FAILURE
                            return $returnList
                        }
                        if {[isIpAddressValid $default_mdt_ip]} {
                            set default_mdt_ip [::ixia::increment_ipv4_address_hltapi \
                                    $default_mdt_ip $default_mdt_ip_incr]
                        } else  {
                            set default_mdt_ip [::ixia::increment_ipv6_address_hltapi \
                                    $default_mdt_ip $default_mdt_ip_incr]
                        }
                    }
                    
                    if {$pim_mode == "sm"} {
                        # Set default interface
                        pimsmInterface setDefault
                        
                        # Configure interface options
                        pimsmInterface config -protocolInterfaceDescription \
                                $loop_description
                        
                        foreach item [array names pimsmInterface] {
                            if {![catch {set $pimsmInterface($item)} value] } {
                                if {[lsearch [array names enumList] $value] != -1} {
                                    set value $enumList($value)
                                }
                                catch {pimsmInterface config -$item $value}
                            }
                        }
                        
                        # Get next interface handle
                        set retCode [::ixia::getNextPimsmLabel    \
                                -port_handle      $port_handle    \
                                -handle_name      pimsmInterface  \
                                -handle_type      interface       ]
                        if {[keylget retCode status] == 0} {
                            keylset returnList log "ERROR in $procName: \
                                    [keylget retCode log]."
                            keylset returnList status $::FAILURE
                            return $returnList
                        }
                        set next_pim_intf [keylget retCode next_handle]
                        
                        # Add interface to hardware
                        if {[pimsmRouter addInterface $next_pim_intf]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Failed to\
                                    pimsmRouter addInterface $next_pim_intf\
                                    on port $chasNum $cardNum $portNum."
                            return $returnList
                        }
                        lappend pimsm_interface_list $next_pim_intf
                        # Add interface to internal array
                        set param_list "\
                                -mode                create           \
                                -handle_name         $next_pim_intf   \
                                -handle_type         interface        \
                                -handle_value        $next_pim_router "
                        
                        if {$mvpn_enable} {
                            append param_list "\
                                    -mvpn_enable          1            \
                                    -mvrf_unique          $mvrf_unique "
                            
                            if {$default_mdt_ip_list != ""} {
                                append param_list "\
                                        -default_mdt_ip  $default_mdt_ip_list "
                            }
                        }
                        set retCode [eval ::ixia::updatePimsmHandleArray \
                                $param_list]
                        if {[keylget retCode status] == 0} {
                            keylset returnList log "ERROR in $procName: \
                                    [keylget retCode log]."
                            keylset returnList status $::FAILURE
                            return $returnList
                        }
                    }
                    
                    # Set default router
                    pimsmRouter setDefault
                    
                    # Configure router options
                    set retCode [::ixia::get_interface_parameter \
                            -port_handle $port_handle            \
                            -description $loop_description       \
                            -parameter   ipv4_address            ]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]."
                        return $returnList
                    }
                    
                    set pe_router_id [keylget retCode ipv4_address]
                    if {$pe_router_id == ""} {
                        unset pe_router_id
                    }
                    set pimsmRouter(routerId)  pe_router_id
                    foreach item [array names pimsmRouter] {
                        if {![catch {set $pimsmRouter($item)} value] } {
                            if {[lsearch [array names enumList] $value] != -1} {
                                set value $enumList($value)
                            }
                            catch {pimsmRouter config -$item $value}
                        }
                    }
                    
                    # Add router to hardware
                    if {[pimsmServer addRouter $next_pim_router]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed to\
                                pimsmServer addRouter $next_pim_router on port\
                                $chasNum $cardNum $portNum."
                        return $returnList
                    }
                    
                    # Add router to return list
                    lappend pimsm_router_list $next_pim_router
                    
                    # Add router to internal array
                    set param_list "\
                            -mode                create           \
                            -handle_name         $next_pim_router \
                            -handle_type         session          \
                            -handle_value        $port_handle     "
                    
                    if {$mvpn_enable} {
                        append param_list "\
                                -mvpn_enable          1            \
                                -mvrf_unique          $mvrf_unique "
                    }
                    set retCode [eval ::ixia::updatePimsmHandleArray \
                            $param_list]
                    
                    if {[keylget retCode status] == 0} {
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]."
                        keylset returnList status $::FAILURE
                        return $returnList
                    }
                }
            }
        }
        
        set pimsmRouter(routerId)  router_id
        if {[info exists router_id]} {
            if {[isIpAddressValid $router_id]} {
                set router_id [::ixia::increment_ipv4_address_hltapi $router_id\
                        $router_id_step]
            }
        }
    }
    
    if {[pimsmServer set]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed to\
                pimsmServer set on port: $chasNum/$cardNum/$portNum."
        return $returnList
    }
    
    stat config -enablePimsmStats $::true
    if {[stat set $chasNum $cardNum $portNum ]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed on stat set $chasNum\
                $cardNum $portNum call."
        return $returnList
    }
    
    if {[protocolServer get $chasNum $cardNum $portNum]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed on protocolServer\
                get $chasNum $cardNum $portNum call."
        return $returnList
    }
    protocolServer config -enablePimsmService true
    if {[protocolServer set $chasNum $cardNum $portNum]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed on protocolServer\
                set $chasNum $cardNum $portNum call."
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

    keylset returnList interfaces $pimsm_interface_list
    keylset returnList handle $pimsm_router_list
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::emulation_pim_group_config { args } {
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
                \{::ixia::emulation_pim_group_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    variable pimsm_handles_array
    variable multicast_group_array
    variable multicast_source_array

    ::ixia::utrackerLog $procName $args

    keylset returnList status $::SUCCESS

    # Arguments
    set opt_args {
        -mode                           CHOICES create delete modify clear_all
                                        DEFAULT create
        -session_handle
        -group_pool_handle
        -source_pool_handle
        -handle
        -adv_hold_time                  RANGE 2-65535
                                        DEFAULT 150
        -back_off_interval              RANGE 0-255
                                        DEFAULT 3
        -crp_ip_addr                    IP
        -rp_ip_addr                     IP
        -rp_ip_addr_step                IP
        -group_pool_mode                CHOICES send register candidate_rp
        -join_prune_aggregation_factor  NUMERIC
        -wildcard_group                 CHOICES 0 1
        -s_g_rpt_group                  CHOICES 0 1
        -rate_control                   CHOICES 0 1
        -interval                       RANGE 50-1000
        -join_prune_per_interval        NUMERIC
        -register_per_interval          NUMERIC
        -register_stop_per_interval     NUMERIC
        -flap_interval                  RANGE 1-65535
        -periodic_adv_interval          RANGE 1-65535
                                        DEFAULT 60
        -pri_change_interval            RANGE 1-65535
                                        DEFAULT 60
        -pri_type                       CHOICES same incremental random
        -pri_value                      RANGE 0-255
                                        DEFAULT 192
        -register_tx_iteration_gap      RANGE 100-2147483647
        -register_stop_trigger_count    RANGE 1-127
        -register_udp_destination_port  RANGE 1-65535
        -register_udp_source_port       RANGE 1-65535
        -register_triggered_sg          CHOICES 0 1
        -router_count                   RANGE 1-65535
                                        DEFAULT 1
        -spt_switchover                 CHOICES 0 1
        -source_group_mapping           CHOICES fully_meshed one_to_one
        -switch_over_interval           RANGE 1-65535
        -send_null_register             CHOICES 0 1
                                        DEFAULT 0
        -trigger_crp_msg_count          RANGE 1-3
                                        DEFAULT 3
        -writeFlag                      CHOICES write nowrite
                                        DEFAULT write
        -no_write                       FLAG
        -default_mdt_mode               CHOICES neighbor auto
                                        DEFAULT neighbor
    }
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_pim_group_config $args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList log "ERROR in $procName:\
                    [keylget returnList log]"
        }
        return $returnList
    }

    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args}\
            errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    if {[info exists mode] && $mode == "modify"} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName:\
                Mode modify is not supported with HLTSET: [string toupper\
                $::ixia::hltsetUsed]."
        return $returnList
    }

    ########  Limitation Notes ##############
    # Code for modify and delete mode exists; however, it is not quite working
    # due to the ixTclHal limitation of getItem/setItem with label on the fly
    ##############
    if {$mode == "modify"} {
        removeDefaultOptionVars $opt_args $args
    }
    
    if {($mode == "create") || ($mode == "clear_all")} {
        if {![info exists session_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: If mode is $mode,\
                    -session_handle option must be present."
            return $returnList
        }
        if {![info exists pimsm_handles_array($session_handle,session)]} {
            set session_handle [ixNet remapIds $session_handle]
            if {![info exists pimsm_handles_array($session_handle,session)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Invalid -session_handle\
                        $session_handle."
                return $returnList
            }
        }
        
        set mvpn_enable [keylget pimsm_handles_array($session_handle,session)\
                mvpn_enable]
        
        set mvrf_unique [keylget pimsm_handles_array($session_handle,session)\
                mvrf_unique]
        
        set pimsmIntefaceList [list]
        foreach {pimsmName} [array names pimsm_handles_array "*,interface"] {
            if {[keylget pimsm_handles_array($pimsmName) value] == \
                    $session_handle} {
                lappend pimsmIntefaceList [lindex [split $pimsmName ,] 0]
            }
        }
    }
    
    if {($mode == "modify") || ($mode == "delete")} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: If mode is $mode,\
                    -handle option must be present."
            return $returnList
        }
        set handle_type [::ixia::getPimsmHandleType $handle]
        if {![info exists pimsm_handles_array($handle,$handle_type)]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Invalid -handle\
                    $handle."
            return $returnList
        }
        set pimsmIntefaceList  [keylget \
                pimsm_handles_array($handle,$handle_type) value]
                
        set session_handle     [keylget \
                pimsm_handles_array([lindex $pimsmIntefaceList 0],interface) value]
        
        set mvpn_enable [keylget pimsm_handles_array($session_handle,session)\
                mvpn_enable]
        
        switch -- $handle_type {
            joinprune { set tcl_handle_name JoinPrune }
            source    { set tcl_handle_name Source    }
            crp       { set tcl_handle_name CRPRange  }
        }
    }
    
    if { $mode == "create" || $mode == "modify" } {
        set enable $::true
    } else {
        set enable $::false
    }
    
    array set enumList [list \
            fully_meshed            $::pimsmMappingFullyMeshed      \
            one_to_one              $::pimsmMappingOneToOne         \
    ]
    array set pimsmSource [list \
            enable                       enable                          \
            groupAddress                 group_ip_addr_start             \
            groupAddressCount            num_groups                      \
            rpAddress                    rp_ip_addr                      \
            sourceAddress                source_ip_addr_start            \
            sourceAddressCount           num_sources                     \
            sourceGroupMapping           source_group_mapping            \
            txIterationGap               register_tx_iteration_gap       \
            udpDestinationPort           register_udp_destination_port   \
            udpSourcePort                register_udp_source_port        \
            enableSendNullRegAtBeginning send_null_register              \
    ]
    
    array set pimsmJoinPrune [list \
            enable                  enable                          \
            enablePacking           local_enable_packing            \
            flapInterval            flap_interval                   \
            groupAddress            group_ip_addr_start             \
            groupAddressCount       num_groups                      \
            groupMaskWidth          group_ip_prefix_len             \
            groupAddressCount       num_groups                      \
            pruneSourceAddress      source_ip_addr_start            \
            pruneSourceAddressCount num_sources                     \
            pruneSourceMaskWidth    source_ip_prefix_len            \
            rangeType               local_range_type                \
            registerStopTriggerCount register_stop_trigger_count    \
            rpAddress               rp_ip_addr                      \
            sourceAddress           source_ip_addr_start            \
            sourceAddressCount      num_sources                     \
            sourceGroupMapping      source_group_mapping            \
            sourceMaskWidth         source_ip_prefix_len            \
            switchoverInterval      switch_over_interval            \
    ]

    array set pimsmCrpRange [list \
        advertisementHoldTime           adv_hold_time               \
        backOffInterval                 back_off_interval           \
        cRPAddress                      crp_ip_addr                 \
        enable                          enable                      \
        groupAddress                    group_ip_addr_start         \
        groupCount                      num_groups                  \
        groupMaskLen                    group_ip_prefix_len         \
        meshingType                     source_group_mapping        \
        periodicAdvertisementInterval   periodic_adv_interval       \
        priorityChangeInterval          pri_change_interval         \
        priorityType                    pri_type                    \
        priorityValue                   pri_value                   \
        routerCount                     router_count                \
        triggeredCRPMessageCount        trigger_crp_msg_count       \
    ]

    array set pimsmServer [list \
        enableRateControl               rate_control                \
        interval                        interval                    \
        sourceMessagesPerInterval       register_per_interval       \
        joinPruneMessagesPerInterval    join_prune_per_interval     \
        registerStopMessagesPerInterval register_stop_per_interval  \
    ]
    
    set port_handle [keylget pimsm_handles_array($session_handle,session) value]
    scan $port_handle "%d/%d/%d" chasNum cardNum portNum
    ::ixia::addPortToWrite $chasNum/$cardNum/$portNum
    set port_list [list [list $chasNum $cardNum $portNum]]

    # Check if PIM package has been installed on the port
    if {[catch {pimsmServer select $chasNum $cardNum $portNum} retCode]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The PIM protocol\
                has not been installed on port or is not supported on port: \
                $chasNum/$cardNum/$portNum."
        return $returnList
    }
    
    if {[pimsmServer get]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed to do\
                pimsmServer get on port $chasNum $cardNum  $portNum."
        return $returnList
    }
    
    if {[pimsmServer getRouter $session_handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed to do\
                pimsmServer getRouter $session_handle on port\
                $chasNum $cardNum $portNum."
        return $returnList
    }
    
    if {$mode == "delete"} {
        foreach {pimsmInterfaceLabel} $pimsmIntefaceList {
            if {[pimsmRouter getInterface $pimsmInterfaceLabel]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to do\
                        pimsmRouter getInterface $pimsmInterfaceLabel on port\
                        $chasNum $cardNum $portNum."
                return $returnList
            }
            
            if {[pimsmInterface del${tcl_handle_name} $handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to do\
                        pimsmInterface del${tcl_handle_name} $handle on port\
                        $chasNum $cardNum $portNum."
                return $returnList
            }
            
            if {[pimsmRouter setInterface $pimsmInterfaceLabel]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to do\
                        pimsmRouter setInterface $pimsmInterfaceLabel on port\
                        $chasNum $cardNum $portNum."
                return $returnList
            }
            
            set retCode [::ixia::updatePimsmHandleArray      \
                    -mode                delete              \
                    -handle_name         $handle             ]
            
            if {[keylget retCode status] == 0} {
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                keylset returnList status $::FAILURE
                return $returnList
            }
        }
    }

    if {$mode == "clear_all"} {
        foreach {pimsmInterfaceLabel} $pimsmIntefaceList {
            if {[pimsmRouter getInterface $pimsmInterfaceLabel]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to do\
                        pimsmRouter getInterface $pimsmInterfaceLabel on port\
                        $chasNum $cardNum $portNum."
                return $returnList
            }
            if {[pimsmInterface clearAllJoinsPrunes]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to do\
                        pimsmInterface clearAllJoinsPrunes on port\
                        $chasNum $cardNum $portNum."
                return $returnList
            }
            
            if {[pimsmInterface clearAllSources]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to do\
                        pimsmInterface clearAllSources on port\
                        $chasNum $cardNum $portNum."
                return $returnList
            }
            
            if {[pimsmInterface clearAllCRPRanges]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to do\
                        pimsmInterface clearAllSources on port\
                        $chasNum $cardNum $portNum."
                return $returnList
            }
            
            if {[pimsmRouter setInterface $pimsmInterfaceLabel]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to do\
                        pimsmRouter setInterface $pimsmInterfaceLabel on port\
                        $chasNum $cardNum $portNum."
                return $returnList
            }
            
            set retCode [::ixia::updatePimsmHandleArray    \
                    -mode                 reset            \
                    -handle_name          $session_handle  ]
            
            if {[keylget retCode status] == 0} {
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                keylset returnList status $::FAILURE
                return $returnList
            }
        }
        
    }

    if {$mode == "delete" || $mode == "clear_all"} {
        if {[pimsmServer set]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to do\
                    pimsmServer set on port $chasNum $cardNum $portNum."
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
        return $returnList
    }
    
    if {[info exists group_pool_handle]} {
        if {![llength [array names multicast_group_array \
                ${group_pool_handle}* ]]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Invalid\
                   group_pool_handle $group_pool_handle. The group_pool_handle\
                   must be created first with emulation_multicast_group_config"
            return $returnList
        }
        set num_groups $multicast_group_array($group_pool_handle,num_groups)
        
        set group_ip_addr_start \
                $multicast_group_array($group_pool_handle,ip_addr_start)
        
        set group_ip_addr_step \
                $multicast_group_array($group_pool_handle,ip_addr_step)
        
        set group_ip_prefix_len \
                $multicast_group_array($group_pool_handle,ip_prefix_len)
        
        set group_ip_addr_pool [list]
        set group_ip_addr $group_ip_addr_start
        if {[isIpAddressValid $group_ip_addr_start]} {
            for {set i 0} {$i < $num_groups} {incr i} {
                lappend group_ip_addr_pool $group_ip_addr
                set group_ip_addr [::ixia::increment_ipv4_net \
                        $group_ip_addr $group_ip_prefix_len]
            }
        } else  {
            for {set i 0} {$i < $num_groups} {incr i} {
                lappend group_ip_addr_pool $group_ip_addr
                set group_ip_addr [::ixia::ipv6_net_incr \
                        $group_ip_addr $group_ip_prefix_len]
            }
        }
    }

    if {[info exists source_pool_handle]} {
        if {$mode == "modify"} {
            set maxRanges 1
        } else {
            set maxRanges [llength $source_pool_handle]
        }
        set local_range_type $::pimsmJoinsPrunesTypeSG
    } else {
        set maxRanges 1
        set local_range_type $::pimsmJoinsPrunesTypeG
    }

    if {[info exists join_prune_aggregation_factor] && \
            $join_prune_aggregation_factor > 0} {
        set local_enable_packing 1
    } else {
        set local_enable_packing 0
    }

    if {[info exists wildcard_group] && $wildcard_group && \
            (![info exists source_pool_handle])} {
        set local_range_type $::pimsmJoinsPrunesTypeRP
    }

    set modeCount  0
    if {[info exists s_g_rtp_group] && $s_g_rtp_group && \
        [info exists source_pool_handle]} {
        incr modeCount
        set local_range_type $::pimsmJoinsPrunesTypeG
    }
    if {[info exists spt_switchover] && $spt_switchover && \
            [info exists source_pool_handle]} {
        incr modeCount
        set local_range_type $::pimsmJoinsPrunesTypeSPTSwitchOver
    }
    if {[info exists register_triggered_sg] && $register_triggered_sg && \
            [info exists source_pool_handle]} {
        incr modeCount
        set local_range_type $::pimsmJoinsPrunesTypeRegisterTriggeredSG
    }
    if {$modeCount > 1} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: only one of the following\
                options can be enabled:  s_g_rtp_group, spt_switchover,\
                and register_triggered_sg"
        return $returnList
    }
    
    if {(![info exists rp_ip_addr_step]) && [info exists rp_ip_addr]} {
        if {[isIpAddressValid $rp_ip_addr]} {
            set rp_ip_addr_step 0.0.0.0
        } else  {
            set rp_ip_addr_step 0::0
        }
    }
      
    for {set i 0} {$i < $maxRanges} {incr i} {
        if {[info exists source_pool_handle]} {
            set sourceIndex [lindex $source_pool_handle $i]
            if {![llength [array names multicast_source_array \
                    ${sourceIndex}* ]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Invalid\
                        source_pool_handle $source_pool_handle. The\
                        source_pool_handle must be created first with\
                        emulation_multicast_source_config"
                return $returnList
            }
            set num_sources $multicast_source_array($sourceIndex,num_sources)
            set source_ip_addr_start \
                    $multicast_source_array($sourceIndex,ip_addr_start)
            set source_ip_prefix_len \
                    $multicast_source_array($sourceIndex,ip_prefix_len)
            set source_ip_addr_step \
                    $multicast_source_array($sourceIndex,ip_addr_step)
        }
        foreach {pimsmInterfaceLabel} [lsort -dictionary $pimsmIntefaceList] {
            if {[pimsmRouter getInterface $pimsmInterfaceLabel]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to do\
                        pimsmRouter getInterface $pimsmInterfaceLabel on port\
                        $chasNum $cardNum $portNum."
                return $returnList
            }
            
            if {$mvpn_enable == 1} {
                set pimsmDescr [pimsmInterface cget -protocolInterfaceDescription]
                set retCode [::ixia::get_interface_parameter \
                        -port_handle $port_handle \
                        -description $pimsmDescr  \
                        -parameter   type         ]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]."
                    return $returnList
                }
                set interfaceType [keylget retCode type]
                set default_mdt_ip [keylget                                 \
                        pimsm_handles_array($pimsmInterfaceLabel,interface) \
                        default_mdt_ip]
                
                if {[info exists group_pool_handle]} {
                    set mdt_list [lsort -unique \
                            [concat $default_mdt_ip $group_ip_addr_pool]]
                    # On routed interfaces we can only add the default mdt group
                    # address
                    if {($interfaceType == "routed") && ([llength $mdt_list] >= \
                            [mpexpr [llength $default_mdt_ip] + [llength        \
                            $group_ip_addr_pool]])} {
                        continue
                    }
                    # On gre tunnels we cannot add the default mdt group address
                    if {($interfaceType == "gre")    && ([llength $mdt_list] <  \
                            [mpexpr [llength $default_mdt_ip] + [llength        \
                            $group_ip_addr_pool]])} {
                        continue
                    }
                }
            }
            if {$mode == "modify"} {
                if {$handle_type == "joinprune"} {
                    set group_pool_mode send
                } elseif {$handle_type == "crp"} {
                    set group_pool_mode candidate_rp
                } else {
                    set group_pool_mode register
                }
                if {[pimsmInterface get${tcl_handle_name} $handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to do\
                            pimsmInterface get${tcl_handle_name} $handle on\
                            port $chasNum $cardNum $portNum."
                    return $returnList
                }
            } else {
                if {![info exists group_pool_mode]} {
                    set group_pool_mode send
                }
                # Get next handle
                if {$group_pool_mode == "register"} {
                    set retCode [::ixia::getNextPimsmLabel \
                            -port_handle      $port_handle \
                            -handle_name      pimsmSource  \
                            -handle_type      source       ]
                    if {[keylget retCode status] == 0} {
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]."
                        keylset returnList status $::FAILURE
                        return $returnList
                    }
                    set handle      [keylget retCode next_handle]
                    set handle_type source
                } elseif {$group_pool_mode == "candidate_rp"} {
                    set retCode [::ixia::getNextPimsmLabel \
                            -port_handle      $port_handle  \
                            -handle_name      pimsmCRPRange \
                            -handle_type      crp           ]
                    if {[keylget retCode status] == 0} {
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]."
                        keylset returnList status $::FAILURE
                        return $returnList
                    }
                    set handle      [keylget retCode next_handle]
                    set handle_type crp
                } else {
                    set retCode [::ixia::getNextPimsmLabel    \
                            -port_handle      $port_handle    \
                            -handle_name      pimsmJoinPrune  \
                            -handle_type      joinprune       ]
                    if {[keylget retCode status] == 0} {
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]."
                        keylset returnList status $::FAILURE
                        return $returnList
                    }
                    set handle      [keylget retCode next_handle]
                    set handle_type joinprune
                }
            }
            
            switch $group_pool_mode {
                "send" {
                    if {[info exists group_pool_handle] || \
                            [info exists source_pool_handle]} {
                        foreach item [array names pimsmJoinPrune] {
                            if {![catch {set $pimsmJoinPrune($item)} value] } {
                                if {[lsearch [array names enumList] \
                                            $value] != -1} {
                                    set value $enumList($value)
                                }
                                catch {pimsmJoinPrune config -$item $value}
                            }
                        }
                        if {$mode == "create"} {
                            if {[pimsmInterface addJoinPrune $handle]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: \
                                        Failed to do\
                                        pimsmInterface getJoinPrune $handle\
                                        on port $chasNum $cardNum $portNum. \
                                        \n$::ixErrorInfo"
                                return $returnList
                            }
                            
                            # Add joinprune to internal array
                            set pha pimsm_handles_array($handle,joinprune)
                            if {[info exists $pha] } {
                                set pimsm_handle_value [keylget $pha value]
                            } else  {
                                set pimsm_handle_value ""
                            }
                            lappend pimsm_handle_value $pimsmInterfaceLabel
                            set retCode [::ixia::updatePimsmHandleArray      \
                                    -mode                create              \
                                    -handle_name         $handle             \
                                    -handle_type         joinprune           \
                                    -handle_value        $pimsm_handle_value ]
                            
                            if {[keylget retCode status] == 0} {
                                keylset returnList log "ERROR in $procName: \
                                        [keylget retCode log]"
                                keylset returnList status $::FAILURE
                                return $returnList
                            }
                        } else {
                            if {[pimsmInterface setJoinPrune $handle]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: \
                                        Failed to do\
                                        pimsmInterface setJoinPrune $handle\
                                        on port $chasNum $cardNum $portNum. \
                                        \n$::ixErrorInfo"
                                return $returnList
                            }
                        }
                    }
                }
                "receive" {
                    ### does not make sense to configure
                }
                "register" {
                    if {[info exists source_pool_handle]} {
                        foreach item [array names pimsmSource] {
                            if {![catch {set $pimsmSource($item)} value] } {
                                if {[lsearch [array names enumList] \
                                        $value] != -1} {
                                    set value $enumList($value)
                                }
                                catch {pimsmSource config -$item $value}
                            }
                        }
                        if {$mode == "create"} {
                            if {[pimsmInterface addSource $handle]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: \
                                        Failed to do\
                                        pimsmInterface addSource $handle\
                                        on port $chasNum $cardNum $portNum."
                                return $returnList
                            }
                            
                            # Add source to internal array
                            set pha pimsm_handles_array($handle,source)
                            if {[info exists $pha] } {
                                set pimsm_handle_value [keylget $pha value]
                            } else  {
                                set pimsm_handle_value ""
                            }
                            lappend pimsm_handle_value $pimsmInterfaceLabel
                            set retCode [::ixia::updatePimsmHandleArray      \
                                    -mode                create              \
                                    -handle_name         $handle             \
                                    -handle_type         source              \
                                    -handle_value        $pimsm_handle_value ]
                            
                            if {[keylget retCode status] == 0} {
                                keylset returnList log "ERROR in $procName: \
                                        [keylget retCode log]"
                                keylset returnList status $::FAILURE
                                return $returnList
                            }
                        } else {
                            if {[pimsmInterface setSource $handle]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: \
                                        Failed to do\
                                        pimsmInterface setSource $handle\
                                        on port $chasNum $cardNum $portNum."
                                return $returnList
                            }
                        }
                    }
                }
                "candidate_rp" {
                    if {[info exists group_pool_handle]} {
                        foreach item [array names pimsmCrpRange] {
                            if {![catch {set $pimsmCrpRange($item)} value] } {
                                if {[lsearch [array names enumList] \
                                            $value] != -1} {
                                    set value $enumList($value)
                                }
                                array set priority_type_array [list \
                                    same        0   \
                                    incremental 1   \
                                    random      2   \
                                ]
                                if {$item == "priorityType"} {
                                    set value $priority_type_array($value)
                                }
                                catch {pimsmCRPRange config -$item $value}
                            }
                        }
                        if {$mode == "create"} {
                            if {[pimsmInterface addCRPRange $handle]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: \
                                        Failed to do\
                                        pimsmInterface addCRPRange $handle\
                                        on port $chasNum $cardNum $portNum. \
                                        \n$::ixErrorInfo"
                                return $returnList
                            }
                            
                            # Add CrpRange to internal array
                            set pha pimsm_handles_array($handle,crp)
                            if {[info exists $pha] } {
                                set pimsm_handle_value [keylget $pha value]
                            } else  {
                                set pimsm_handle_value ""
                            }
                            lappend pimsm_handle_value $pimsmInterfaceLabel
                            set retCode [::ixia::updatePimsmHandleArray      \
                                    -mode                create              \
                                    -handle_name         $handle             \
                                    -handle_type         crp                 \
                                    -handle_value        $pimsm_handle_value ]
                            
                            if {[keylget retCode status] == 0} {
                                keylset returnList log "ERROR in $procName: \
                                        [keylget retCode log]"
                                keylset returnList status $::FAILURE
                                return $returnList
                            }
                        } else {
                            if {[pimsmInterface setCRPRange $handle]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: \
                                        Failed to do\
                                        pimsmInterface setCRPRange $handle\
                                        on port $chasNum $cardNum $portNum. \
                                        \n$::ixErrorInfo"
                                return $returnList
                            }
                        }
                    }
                }
            }
            if {[pimsmRouter setInterface $pimsmInterfaceLabel]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to do\
                        pimsmRouter setInterface $pimsmInterfaceLabel on port\
                        $chasNum $cardNum $portNum."
                return $returnList
            }
            
            if {$mode == "create"} {
                if {[info exists group_pool_handle]} {
                    if {[isIpAddressValid $group_ip_addr_start]} {
                        set group_ip_addr_start \
                                [::ixia::increment_ipv4_address_hltapi \
                                $group_ip_addr_start $group_ip_addr_step]
                    } else  {
                        set group_ip_addr_start \
                                [::ixia::increment_ipv6_address_hltapi \
                                $group_ip_addr_start $group_ip_addr_step]
                    }
                }
                if {[info exists source_pool_handle]} {
                    if {[isIpAddressValid $source_ip_addr_start]} {
                        set source_ip_addr_start \
                                [::ixia::increment_ipv4_address_hltapi \
                                $source_ip_addr_start $source_ip_addr_step]
                    } else  {
                        set source_ip_addr_start \
                                [::ixia::increment_ipv6_address_hltapi \
                                $source_ip_addr_start $source_ip_addr_step]
                    }
                }
            }
            if {[info exists rp_ip_addr]} {
                if {[isIpAddressValid $rp_ip_addr]} {
                    set rp_ip_addr [::ixia::increment_ipv4_address_hltapi \
                            $rp_ip_addr $rp_ip_addr_step]
                } else  {
                    set rp_ip_addr [::ixia::increment_ipv6_address_hltapi \
                            $rp_ip_addr $rp_ip_addr_step]
                }
            }
        }
    }
    
    foreach item [array names pimsmServer] {
        if {![catch {set $pimsmServer($item)} value] } {
            if {[lsearch [array names enumList] $value] != -1} {
                set value $enumList($value)
            }
            catch {pimsmServer config -$item $value}
        }
    }

    if {[pimsmServer set]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed to do\
                pimsmServer set on port $chasNum $cardNum $portNum."
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
    keylset returnList handle $handle
    keylset returnList group_pool_handle $group_pool_handle
    if {[info exists source_pool_handle]} {
        keylset returnList source_pool_handles $source_pool_handle
    }
    return $returnList
}

proc ::ixia::emulation_pim_control { args } {
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
                \{::ixia::emulation_pim_control $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    
    variable pimsm_handles_array

    ::ixia::utrackerLog $procName $args

    keylset returnList status $::SUCCESS

    # Arguments
    set man_args {
            -mode           CHOICES stop start restart
    }

    set opt_args {
            -port_handle    REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
            -handle
            -flap           CHOICES 0 1
            -flap_interval  RANGE 1-65535
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

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_pim_control $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList log "ERROR in $procName:\
                    [keylget returnList log]"
        }
        return $returnList
    }

    keylset returnList clicks [format "%u" $retValueClicks]
    keylset returnList seconds [format "%u" $retValueSeconds]

    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }

    ### Limitations:
    ### group_member_handle option is not supported because of the
    ### ixTclHal problem:  pimsmInterface getJoinPrune label command fails.
    ### join and prune mode are not supported.  These modes require the
    ### group_member_handle option.

    ### If port_handle option is not passed in, use the port_handle stored in
    ### the session handle
    if {[info exists port_handle]} {
        # Need to replace the slashes with spaces for IxTclHal api calls using
        # port lists
        set port_list [list]
        for {set index 0} {$index < [llength $port_handle]} {incr index} {
            regsub -all "/" [lindex $port_handle $index] " " temp_port
            lappend port_list $temp_port
        }
    } else {
        if {![info exists handle]} {
            keylset returnList log "$procName: must have either session\
                    handle or port handle option"
            keylset returnList status $::FAILURE
            return $returnList
        }
        if {[array names pimsm_handles_array $handle,session] == ""} {
            keylset returnList log "$procName: cannot find the session handle\
                    $handle in the pimsm_handles_array"
            keylset returnList status $::FAILURE
            return $returnList
        }
        
        set port_handle [keylget pimsm_handles_array($handle,session) value]
        foreach {chasNum cardNum portNum} [split $port_handle /] {}
        set port_list [list [list $chasNum $cardNum $portNum]]
    }
    
    
    
    if {[info exists flap]} {
        if {[info exists group_member_handle]} {
            set returnList [pimsmGroupFlapConfig enableFlap $flap $port_list \
                    $handle $group_member_handle ]
        } elseif {[info exists handle]} {
            set returnList [pimsmGroupFlapConfig enableFlap $flap $port_list \
                    $handle]
        } else {
            set returnList [pimsmGroupFlapConfig enableFlap $flap $port_list]
        }
        if {[keylget returnList status] == $::FAILURE} {
            return $returnList
        }

        if {[pimsmServer write]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName:\
                    Failed on pimsmServer write."
            return $returnList
        }
    }

    if {[info exists flap_interval]} {
        if {[info exists group_member_handle]} {
            set returnList [pimsmGroupFlapConfig flapInterval $flap_interval\
                    $port_list $handle $group_member_handle ]
        } elseif {[info exists handle]} {
            set returnList [pimsmGroupFlapConfig flapInterval $flap_interval\
                    $port_list $handle]
        } else {
            set returnList [pimsmGroupFlapAction flapInterval $flap_interval \
                    $port_list]
        }
        if {[keylget returnList status] == $::FAILURE} {
            return $returnList
        }

        if {[pimsmServer write]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName:\
                    Failed on pimsmServer write."
            return $returnList
        }
    }
    
    # Check if PIMSM package has been installed on the port
    foreach port_i $port_list {
        foreach {chs_i crd_i prt_i} $port_i {}
        if {[catch {pimsmServer select $chs_i $crd_i $prt_i } error]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: The PIM\
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
    
    switch -exact $mode {
        restart {
            if {[info exists group_member_handle]} {
                set returnList [pimsmGroupMemberAction $port_list $handle \
                        $group_member_handle $::false]
                if {[keylget returnList status] == $::FAILURE} {
                    return $returnList
                }

                if {[pimsmServer write]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            Failed on pimsmServer write."
                    return $returnList
                }
            } elseif {[info exists handle]} {
                set returnList [pimsmRouterAction $port_list \
                        $handle $::false]
                if {[keylget returnList status] == $::FAILURE} {
                    return $returnList
                }

                if {[pimsmServer write]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            Failed on pimsmServer write."
                    return $returnList
                }
            } elseif {[ixStopPimsm port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error stopping\
                        PIMSM on the port list $port_list."
                return $returnList
            }  
            if {[info exists group_member_handle]} {
                set returnList [pimsmGroupMemberAction $port_list $handle \
                        $group_member_handle $::true]
                if {[keylget returnList status] == $::FAILURE} {
                    return $returnList
                }
                if {[pimsmServer write]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            Failed on pimsmServer write."
                    return $returnList
                }
            }
            if {[info exists handle]} {
                set returnList [pimsmRouterAction $port_list \
                        $handle $::true]
                if {[keylget returnList status] == $::FAILURE} {
                    return $returnList
                }
                if {[pimsmServer write]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            Failed on pimsmServer write."
                    return $returnList
                }
            } 
            if {[ixStartPimsm port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error starting\
                        PIMSM on the port list $port_list."
                return $returnList
            }       
        }
        start {
            if {[info exists group_member_handle]} {
                set returnList [pimsmGroupMemberAction $port_list $handle \
                        $group_member_handle $::true]
                
                if {[keylget returnList status] == $::FAILURE} {
                    return $returnList
                }
                
                if {[pimsmServer write]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            Failed on pimsmServer write."
                    return $returnList
                }
            }
            if {[info exists handle]} {
                set returnList [pimsmRouterAction $port_list \
                        $handle $::true]
                
                if {[keylget returnList status] == $::FAILURE} {
                    return $returnList
                }

                if {[pimsmServer write]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            Failed on pimsmServer write."
                    return $returnList
                }
            } 
            if {[ixStartPimsm port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error starting\
                        PIMSM on the port list $port_list."
                return $returnList
            }
        }
        stop {
            if {[info exists group_member_handle]} {
                set returnList [pimsmGroupMemberAction $port_list $handle \
                        $group_member_handle $::false]
                if {[keylget returnList status] == $::FAILURE} {
                    return $returnList
                }

                if {[pimsmServer write]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            Failed on pimsmServer write."
                    return $returnList
                }
            } elseif {[info exists handle]} {
                set returnList [pimsmRouterAction $port_list \
                        $handle $::false]
                if {[keylget returnList status] == $::FAILURE} {
                    return $returnList
                }
                if {[pimsmServer write]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            Failed on pimsmServer write."
                    return $returnList
                }
            } elseif {[ixStopPimsm port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error stopping\
                        PIMSM on the port list $port_list."
                return $returnList
            }
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::emulation_pim_info { args } {
    variable new_ixnetwork_api
    variable executeOnTclServer

    set procName [lindex [info level [info level]] 0]

    ::ixia::logHltapiCommand $procName $args

    set procName [lindex [info level [info level]] 0]

    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::emulation_pim_info $args\}]
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
        -handle
    }
    set opt_args {
        -mode       CHOICES aggregate learned_crp
                    DEFAULT aggregate
    }
        
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        
        set returnList [::ixia::ixnetwork_pim_info $args $man_args $opt_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
    } else {
        # IxOS
        keylset returnList status $::SUCCESS
        if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args\
                $man_args -optional_args $opt_args} errorMsg]} {
            keylset returnList status $::FAILURE
            keylset returnList log "$errorMsg."
            return $returnList
        }
        if {[info exists mode] && ($mode == "learned_crp")} {
            set learned_crp_list {
                cRPAddress              crp_addr
                mappingExpiryTimerValue expiry_timer
                groupAddress            group_addr
                groupMaskWidth          group_mask_width
                cRPPriority             priority
            }
            set learned_bsr_list {
                bSRAddress          bsr_addr
                bSRTimerValue       last_bsm_send_recv
                bSRState            our_bsm_state
                bSRPriority         priority
            }
            if {[regexp {^([0-9]+)/([0-9]+)/([0-9]+)pimsmRouter([0-9]+)$} $handle match chasNum cardNum portNum rNum]} {
                set retCode [::ixia::getAllPimsmInterfaceHandles \
                    $chasNum/$cardNum/$portNum $handle]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]."
                    return $returnList
                }
                set pimsmIntfList [keylget retCode handles]
            } else {
                keylset returnList log "ERROR in $procName: The handle provided\
                        is not a valid router handle: $handle."
                keylset returnList status $::FAILURE
                return $returnList
            }
            if {[pimsmServer select $chasNum $cardNum $portNum]} {
                keylset returnList log "ERROR in $procName: Failed on pimsmServer\
                        select $chasNum $cardNum $portNum call."
                keylset returnList status $::FAILURE
                return $returnList
            }
            if {[pimsmServer getRouter $handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to issue\
                        pimsmServer getRouter $handle command on port $chasNum\
                        $cardNum $portNum."
                return $returnList
            }
            keylset returnList log ""
            foreach intf_handle $pimsmIntfList {
                if {[pimsmRouter getInterface $intf_handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to do\
                            pimsmRouter getInterface $pimsmInterfaceLabel on port\
                            $chasNum $cardNum $portNum."
                    return $returnList
                }
                set numRetries 5
                while {$numRetries && [set refreshResult [pimsmInterface requestLearnedCRPBSRInfo]]} {
                    incr numRetries -1
                }
                if {$refreshResult} {
                    keylset returnList log [concat [keylget returnList log] "There is no learned information for\
                            interface $intf_handle. The returned error was $refreshResult."]
                    continue
                }
                after 1000
                if {[pimsmInterface getLearnedBSRInfo]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to get\
                            Learned BSR Info on port $chasNum $cardNum $portNum."
                    return $returnList
                }
                set bsr_index 1
                foreach {ixosOpt hltOpt} $learned_bsr_list {
                    keylset returnList learned_bsr.$intf_handle.$bsr_index.$hltOpt \
                            [pimsmLearnedBSR cget -$ixosOpt]
                }
                set crp_index 1
                if {![pimsmInterface getFirstLearnedCRPInfo]} {
                    foreach {ixosOpt hltOpt} $learned_crp_list {
                        keylset returnList learned_crp.$intf_handle.$crp_index.$hltOpt \
                                [pimsmLearnedCRP cget -$ixosOpt]
                    }
                    incr crp_index
                    while {![pimsmInterface getNextLearnedCRPInfo]} {
                        foreach {ixosOpt hltOpt} $learned_crp_list {
                            keylset returnList learned_crp.$intf_handle.$crp_index.$hltOpt \
                                    [pimsmLearnedCRP cget -$ixosOpt]
                        }
                        incr crp_index
                    }
                } else {
                    keylset returnList log [concat [keylget returnList log] "There is no learned information for\
                            interface $intf_handle. The returned error was $refreshResult."]
                }
            }
            if {[keylget returnList log] == ""} {
                keyldel returnList log
            }
            if {![keylget returnList learned_crp retvar] && ![keylget returnList learned_bsr retvar]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR on $procName: Failed to get Learned BSR Info\
                            and Learned CRP Info on port $chasNum $cardNum $portNum."
                return $returnList
            }
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR on $procName: -mode aggregate \
                    is not supported with IxTclProtocol API."
            return $returnList
        }
    }
    return $returnList
}
