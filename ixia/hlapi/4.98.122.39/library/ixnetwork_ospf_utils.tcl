##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_ospf_api.tcl
#
# Purpose:
#    A script development library containing OSPF APIs for test automation with
#    the Ixia chassis.
#
# Usage:
#    package req Ixia
#
# Description:
#    The procedures contained within this library include:
#
#    - ixnetwork_configureOspfv2UserLsaParams
#    - ixnetwork_configureOspfv3UserLsaParams
#
# Requirements:
#    ixiaapiutils.tcl , a library containing TCL utilities
#    parseddashedargs.tcl , a library containing the proceDescr and
#    parsedashedargds.tcl
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

##Internal Procedure Header
# Name:
#    ::ixia::ixnetwork_configureOspfv2UserLsaParams
#
# Description:
#    Configures the OSPFV2 User Lsa parameters for IxNetwork 5.30 and later
#
# Synopsis:
#
# Arguments:
#    ospfv2ArrayList
#        list of array names which hold the User Lsa parameters
#    refVarList
#        lists of variables defined in the parent scope.  Need to 
#        call upvar on each element
#    userLsaType
#        type is one of:  router, network, summary_pool, asbr_summary,
#        and ext_pool
#
# Return Values:
#    returnList with status of $::SUCCESS or $::FAILURE
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::ixnetwork_configureOspfv2UserLsaParams {
    lsa_hnd ospfv2ArrayList refVarList userLsaType {commit "-no_commit"}
} {
    
    ### Make arrays in the ospfv2ArrayList accessable from local proc
    foreach arrayName $ospfv2ArrayList {
       upvar $arrayName $arrayName
    }
    
    ### Make variable accessable from local proc
    foreach varName $refVarList {
        upvar $varName $varName
    }
    debug "ixNetworkSetAttr $lsa_hnd -enabled true"
    ixNetworkSetAttr $lsa_hnd -enabled true
    foreach {param cmd} $userLSAList {
        if {[catch {upvar $param $param} errorMsg]} {
            keylset returnList log "${errorMsg}."
            keylset returnList status $::FAILURE
            return $returnList
        }
        if {[info exists $param]} {
            debug "ixNetworkSetAttr $lsa_hnd -$cmd [set $param]"
            ixNetworkSetAttr $lsa_hnd -$cmd [set $param]
        }
    }


    switch -exact -- $userLsaType {
        router {
            set lsa_hnd "$lsa_hnd/router"
            set list_name routerList
            
            if {[info exists router_link_id] && \
                [info exists router_link_data] && \
                [info exists router_link_type] && \
                [info exists router_link_metric]} {
                
                if {![info exists router_link_mode]} {
                    set router_link_mode [string repeat "create " [llength $router_link_id]]
                } else {
                    set router_link_mode $router_link_mode[string repeat " create" [expr [llength $router_link_id] - [llength $router_link_mode]]]
                }
                
                foreach router_link_mode_elem   $router_link_mode   \
                        router_link_id_elem     $router_link_id     \
                        router_link_data_elem   $router_link_data   \
                        router_link_type_elem   $router_link_type   \
                        router_link_metric_elem $router_link_metric {
                    switch -exact -- $router_link_mode_elem {
                        create {
                            array set linkTypeArray $linkTypeList
                            
                            lappend intf_list [list \
                                    $router_link_id_elem   \
                                    $router_link_data_elem \
                                    $linkTypeArray($router_link_type_elem) \
                                    $router_link_metric_elem]
                        }
                        modify {
                            # will be supported soon
                        }
                        delete {
                            # will be supported soon
                        }
                    }
                }
            }
        }
        network {
            if {[info exists net_prefix_length]} {
                set net_prefix_length [::ixia::getNetMaskFromPrefixLen \
                        $net_prefix_length]
            }
            set lsa_hnd "$lsa_hnd/network"
            set list_name networkList
            upvar attached_router_id attached_router_id
            if {[info exists attached_router_id]} {
                if {[catch {set attached_router_id_list [ixNetworkGetAttr \
                        $lsa_hnd -neighborRouterIds]} errorMsg] == 0} {
                    switch -exact -- $net_attached_router {
                        create {
                            eval "lappend attached_router_id_list $attached_router_id"
                        }
                        delete {
                            if {[set pos [lindex $attached_router_id_list \
                                $attached_router_id]] >= 0} {
                                set $attached_router_id_list \
                                        [lreplace $attached_router_id_list $pos $pos]
                            }
                        }
                        reset {
                            set attached_router_id_list {}
                        }
                    }
                    set attached_router_id_list [join $attached_router_id_list]
                } else {
                    # error
                    keylset returnList log $errorMsg
                    keylset returnList status $::FAILURE
                    return $returnList
                }
            }
        }
        summary_pool {
            # same think for summary_pool and asbr_summary
            set lsa_hnd "$lsa_hnd/summaryIp"
            set list_name summaryIpList
            if {[info exists summary_prefix_length]} {
                set summary_prefix_length [getIpV4MaskFromWidth \
                    $summary_prefix_length]
            }
        }
        asbr_summary {
            set list_name summaryAS
            set summaryAS {}
        }
        ext_pool {
            set lsa_hnd "$lsa_hnd/external"
            set list_name externalList
            if {[info exists external_prefix_length]} {
                set external_prefix_length [getIpV4MaskFromWidth \
                    $external_prefix_length]
            }
        }
        opaque_type_9 -
        opaque_type_10 -
        opaque_type_11 {
#             opaque_enable_link_id                   enableLinkId                Bool
#             opaque_enable_link_metric               enableLinkMetric            Bool
#             opaque_enable_link_resource_class       enableLinkResourceClass     Bool
#             opaque_enable_link_type                 enableLinkType              Bool
#             opaque_enable_link_local_ip_addr        enableLocalIpAddress        Bool
#             opaque_enable_link_max_bw               enableMaxBandwidth          Bool
#             opaque_enable_link_max_resv_bw          enableMaxResBandwidth       Bool
#             opaque_enable_link_remote_ip_addr       enableRemoteIpAddress       Bool
#             opaque_enable_link_unresv_bw            enableUnreservedBandwidth   Bool
#             opaque_link_id                          linkId                      IPv4
#             opaque_link_local_ip_addr               linkLocalIpAddress          IPv4
#             opaque_link_metric                      linkMetric                  Integer
#             opaque_link_remote_ip_addr              linkRemoteIpAddress         IPv4
#             opaque_link_resource_class              linkResourceClass           Blob
#             opaque_link_type                        linkType                    EnumValue
#             opaque_link_unresv_bw_priority          linkUnreservedBandwidth     Array
#             opaque_link_max_bw                      maxBandwidth                Double
#             opaque_link_max_resv_bw                 maxResBandwidth             Double
#             opaque_link_subtlvs                     subTlvs                     Array
#             opaque_router_addr                      routerAddress               IPv4
            
            if {${opaque_tlv_type} == "router"} {
                ixNetworkSetAttr $lsa_hnd/opaque -enableRouterTlv true
            } else {
                ixNetworkSetAttr $lsa_hnd/opaque -enableRouterTlv false
            }
            
            set lsa_hnd "$lsa_hnd/opaque/${opaque_tlv_type}Tlv"
            set list_name ${opaque_tlv_type}_opaqueList
            
            foreach {param cmd p_type} [set $list_name] {
                if {![info exists $param]} {
                    upvar $param $param
                }
            }
            if {[info exists opaque_link_resource_class]} {
                set opaque_link_resource_class [::ixia::hex2list \
                        $opaque_link_resource_class 4]
            }
            
            if {[info exists opaque_link_other_subtlvs]} {
                set new_value ""
                foreach subtlv $opaque_link_other_subtlvs {
                    set subtlv [split $subtlv :]
                    set subtlv_type   [lindex $subtlv 0]
                    set subtlv_length [lindex $subtlv 1]
                    set subtlv_value  [::ixia::hex2list [lindex $subtlv 2] [lindex $subtlv 1]]
                    lappend new_value [list $subtlv_value [expr $subtlv_length * 2] $subtlv_type]
                }
                set opaque_link_other_subtlvs $new_value
            }
            
            if {[info exists opaque_link_subtlvs]} {
                set new_value ""
                foreach subtlv $opaque_link_subtlvs {
                    set subtlv [split $subtlv .]
                    foreach {b1 b2 b3 b4} $subtlv {
                        set b1 [format %02x $b1]
                        set b2 [format %02x $b2]
                        set b3 [format %02x $b3]
                        set b4 [format %02x $b4]
                    }
                    set subtlv_value  [list $b1 $b2 $b3 $b4]
                    set subtlv_type   10
                    set subtlv_length 4
                    lappend new_value [list $subtlv_value [expr $subtlv_length * 2] $subtlv_type]
                }
                set opaque_link_subtlvs $new_value
            }
            if {[info exists opaque_link_type]} {
                array set translate_opaqueList {
                    ptop        pointToPoint
                    multiaccess multiaccess
                }
                set opaque_link_type $translate_opaqueList($opaque_link_type)
            }
        }
        default {
            # error
        }
    }
    foreach {param cmd p_type} [set $list_name] {
        if {![info exists $param]} {
            upvar $param $param
        }
        if {[info exists $param]} {
            switch -exact -- $p_type {
                bool -
                flag {
                    if {[set $param] == 1} {
                        set $param true
                    } else {
                        set $param false
                    }
                }
                translate {
                    if {[info exists translate_${list_name}([set $param])]} {
                        set $param [set translate_${list_name}([set $param])]
                    }
                }
            }
            debug "ixNetworkSetAttr $lsa_hnd -$cmd [set $param]"
            if [catch {ixNetworkSetAttr $lsa_hnd -$cmd [set $param]} retError] {
                keylset returnList log "Failed to set parameter $param. $retError"
                keylset returnList status $::FAILURE
                return $returnList
            }
        }
    }
    
    if {$commit == "-commit"} {
        debug "ixNetworkCommit"
        ixNetworkCommit
    }
    keylset returnList status $::SUCCESS
    keylset returnList handle $lsa_hnd
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::configureOspfv2UserLsaParams
#
# Description:
#    Configures the OSPFV3 User Lsa parameters for IxNetwork 5.30 and later
#
# Synopsis:
#
# Arguments:
#    ospfv2ArrayList
#        list of array names which hold the User Lsa parameters
#    refVarList
#        lists of variables defined in the parent scope.  Need to 
#        call upvar on each element
#    userLsaType
#        type is one of:  router, network, summary_pool, asbr_summary,
#        and ext_pool
#
# Return Values:
#    returnList with status of $::SUCCESS or $::FAILURE
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::ixnetwork_configureOspfv3UserLsaParams {
    lsa_hnd
    ospfv3ArrayList 
    refVarList
    userLsaType
    {commit "-no_commit"}
} {
    ### Make arrays in the ospfv2ArrayList accessable from local proc
    foreach arrayName $ospfv3ArrayList {
       upvar $arrayName $arrayName
    }
        
    ### Make variable accessable from local proc
    foreach varName $refVarList {
        upvar $varName $varName
    }
    
    array set enumList [list                     \
            ptop             PointToPoint        \
            transit          Transit             \
            stub             Stub                \
            virtual          Virtual             \
            ]
            
    # Setting common values
    foreach {param cmd} $ospfV3CommonList {
        upvar $param $param
        if {[info exists $param]} {
            debug "ixNetworkSetAttr $lsa_hnd -$cmd [set $param]"
            if [catch {ixNetworkSetAttr $lsa_hnd -$cmd [set $param]} retError] {
                keylset returnList log "Failed to set $param\
                        parameter on common LSA attributes. $retError."
                keylset returnList status $::FAILURE
                return $retrunList
            }
        }
    }
    
    switch -exact $userLsaType {
        router {
            set lsa_hnd "$lsa_hnd/router"
            set lsa_options_list ospfV3LsaRouterList
            ### only supporting -router_link_mode of create for now
            ### due to ixTclHal limitation
            if {[info exists router_link_mode] && !$router_link_mode_is_default} {
                switch -exact -- $router_link_mode {
                    create {
                        if {![info exists router_link_id]} {
                            set router_link_id 0
                        } else {
                            set router_link_id [ip2num $router_link_id]
                        }
                        if {![info exists router_link_data]} {
                            set router_link_data 0.0.0.0
                        }
                        if {![info exists router_link_type]} {
                            set router_link_type transit
                        }
                        if {![info exists router_link_metric]} {
                            set router_link_metric 1
                        }
                        # Creating interface list
                         array set lsaRouterIfcTypeArray [list \
                                ptop                pointToPoint \
                                transit             transit    \
                                stub                stub       \
                                virtual             virtual    \
                                ]
                        set intf_list [list [list $router_link_id 0 \
                        $router_link_data $lsaRouterIfcTypeArray($router_link_type) \
                        $router_link_metric]]
                    }
                    default {
                        keylset returnList log "Router link mode\
                                $router_link_mode is not supported."
                        keylset returnList status $::FAILURE
                        return $returnList
                    }
                }
            }
        }
        network {
            set lsa_hnd "$lsa_hnd/network"
            set lsa_options_list ospfV3LsaNetworkList 
            upvar attached_router_id attached_router_id
            if {[info exists attached_router_id]} {
                if {[catch {set attached_routers_list [ixNetworkGetAttr \
                        $lsa_hnd -attachedRouters]} errorMsg] == 0} {
                    switch -exact -- $net_attached_router {
                        create {
                            append attached_routers_list " $attached_router_id"
                        }
                        delete {
                            foreach attached_router_id_elem $attached_router_id {
                                if {[set pos [lindex $attached_routers_list \
                                    $attached_router_id_elem]] >= 0} {
                                    set $attached_routers_list \
                                       [lreplace $attached_routers_list $pos $pos]
                                }
                            }
                        }
                        reset {
                            set attached_routers_list {}
                        }
                    }
                    set attached_routers_list [join $attached_routers_list]
                } else {
                    keylset returnList log $errorMsg
                    keylset returnList status $::FAILURE
                    return $returnList
                }
            }
        }
        summary_pool {
            set lsa_hnd "$lsa_hnd/interAreaPrefix"
            set lsa_options_list ospfV3LsaInterAreaPrefixList
            upvar link_state_id_step link_state_id_step
            upvar summary_prefix_step summary_prefix_step
            if {[info exists summary_prefix_step]} {
                set summary_prefix_step [ip_addr_to_num $summary_prefix_step]
            }
            if {![info exists link_state_id_step]} {
                if {[info exists summary_prefix_step]} {
                    set link_state_id_step $summary_prefix_step
                    set link_state_id_step [num_to_ip_addr $link_state_id_step 4]
                } else {
                    set link_state_id_step 0.0.0.0
                }
            }
        }
        asbr_summary {
            set lsa_hnd "$lsa_hnd/interAreaRouter"
            set lsa_options_list ospfV3LsaInterAreaRouterList
        }
        ext_pool {
            set lsa_hnd "$lsa_hnd/asExternal"
            set lsa_options_list ospfV3LsaAsExternalList
        }
        default {
            keylset returnList log "LSA type $userLsaType is not supported."
            keylset returnList status $::FAILURE
            return $returnList    
        }
    }
        
    foreach {param cmd type} [set $lsa_options_list] {
        if {![info exists $param]} {
            upvar $param $param
        }
        if {[info exists $param]} {
            switch -exact -- $type {
                value {set value [set $param]}
                flag {
                    if {[set $param] == 0} {
                        set value false
                    } else {
                        set value true
                    }
                }
                default {
                    keylset returnList log "Type $type is not supported."
                    keylset returnList status $::FAILURE
                    return $returnList    
                }
            }
            debug "ixNetworkSetAttr $lsa_hnd -$cmd $value"
            if [catch {ixNetworkSetAttr $lsa_hnd -$cmd $value} retError] {
                keylset returnList log "Failed to set\
                        parameter $param. $retError."
                keylset returnList status $::FAILURE
                return $returnList
            }
        }
    }
    
    if {$commit == "-commit"} {
        debug "ixNetworkCommit"
        ixNetworkCommit
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList handle $lsa_hnd
    return $returnList
}
