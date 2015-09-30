##Library Header
# $Id: $
# Copyright © 2003-2007 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_session_info.tcl
#
# Purpose:
#     A script development library containing API for retrieving IxNetwork session info
#
# Author:
#    Adrian Enache
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures contained within this library include:
#
#    - session_info
#
# Requirements:
#   ixiaapiutils.tcl , a library containing TCL utilities
#   parseddashedargs.tcl , a library containing the parse_dashed_args proc
#   ixia_util.tcl  
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

namespace eval ::ixia::session_info {}
proc ::ixia::session_info { args } {

    ixia::util::proc_prolog $args
    
    set man_args {
        -mode               CHOICES get_session_keys 
                            CHOICES get_traffic_items get_traffic_ce get_traffic_hls get_traffic_headers
                            CHOICES get_traffic_application_profiles get_traffic_applib_profiles
    }
    set opt_args {
        -session_keys_include_filter    ANY
                                        DEFAULT {}
        -port_handle                    REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -traffic_handle                 ANY
    }
    # dont publish these args
    set internal_opt_args {
        -detect_required_session_variables  CHOICES 0 1
                                            DEFAULT 1
    }
    # ixia::parse_dashed_args expects endlines... (in a list)
    append opt_args $internal_opt_args

    try_eval {
        parse_dashed_args_prefixed      \
            -args $args                 \
            -mandatory_args $man_args   \
            -optional_args $opt_args
    } {
        return [make_error "Failed on parsing. $errorResult"]
    }

    if {[info exists ixia::new_ixnetwork_api] && $ixia::new_ixnetwork_api} {
        set returnList [session_info::mode_$arg_mode]
        if {[keylget returnList status] != $::SUCCESS} {
            return [make_error "mode get_session_keys: [keylget returnList log]"]
        }
    } else {
        return [make_error "session_info is only supported with IxTclNetwork API"]
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
#
# Description:
#   Returns a list of session resume keys (protocols related)
#
# Input:
#   See $upvar_list
#
proc ::ixia::session_info::mode_get_session_keys {} {

    ixia::util::import_namespace_procs "::ixia::util" {
        make_error
        upvar_variable_list
    }

    set upvar_list {
        arg_session_keys_include_filter
        arg_port_handle
        arg_detect_required_session_variables
    }
    upvar_variable_list $upvar_list

    ixia::util::import_namespace_procs "::ixia::session_resume" {
        sr_initialize
        sr_finalize
    }

    if {[info exists arg_port_handle]} {
        regexp {(\d+)\.(\d+)} $::ixia::ixnetworkVersion {} ixn_major ixn_minor
        if {$ixn_major < 7 || ($ixn_major == 7 && $ixn_minor < 10)} {
            return [make_error "argument -port_handle isnt supported on IxNetwork version lower than 7.10"]
        }
    }

    try_eval {
        # filter for session_resume_build_key_list
        # sr_initialize will drop items w/o filter inclusion
        validate_session_keys_include_filter $arg_session_keys_include_filter
        set rval [filter_build_key_list $arg_session_keys_include_filter]
        set keymap   [lindex $rval 0]
        set req_list [lindex $rval 1]
    } {
        return [make_error $errorResult]
    }

    # there are keys that depend on internal HLT data which arent updated while working in GUI (not through HLT commands)
    # need to reconstruct each time internal protocol dependent data
    if {$arg_detect_required_session_variables} {
        set rval [ixia::detect_session_variables]
        if {[keylget rval status] != $::SUCCESS} {
            error [keylget rval log]
        }
        set rval [ixia::detect_port_variables "_na"]
        if {[keylget rval status] != $::SUCCESS} {
            error [keylget rval log]
        }

        set req_list_internal [ixia::session_resume::filter_build::detect_protocol_variables]
        set req_list [concat_filter_map $req_list $req_list_internal]
    }

    # remove dashes and uniquify
    array set filter_map $req_list
    foreach key [array names filter_map] {
        # some string manip even if list, remove dashes from attributes
        set filter_map($key) [string map {"-" ""} [lsort -unique $filter_map($key)]]
    }
    set req_list [array get filter_map]

    # specialize for given port handles
    if {[info exists arg_port_handle]} {
        set vport_list [list]
        foreach ph [lsort -unique $arg_port_handle] {
            set rval [ixia::ixNetworkGetPortObjref $ph]
            if {[keylget rval status] != $::SUCCESS} {
                return [make_error "Cannot get vport from port handle $ph"]
            }
            lappend vport_list [keylget rval vport_objref]
        }

        # specialize everything that starts with a vport
        set specialize_paths [list]
        foreach {req_elem _} $req_list {
            if {[string first "/vport" $req_elem] == 0} {
                lappend specialize_paths $req_elem
            }
        }
        set req_list [specialize_filter $req_list $specialize_paths $vport_list]
    }

    # if traffic, include filter
    # blaim legacy keys for the complexity
    set include_filter [list]
    if {[info exists arg_session_keys_include_filter]} {
        set include_filter $arg_session_keys_include_filter
    }
    set app_lib_filter_handles   [expr [lsearch $include_filter "traffic_l47_config"] != -1 ||  \
                                       [lsearch $include_filter "traffic_l47_config.traffic_l47_handle.applib_profile"] != -1 ||    \
                                       [lsearch $include_filter "traffic_l47_config.traffic_l47_handle.applib_profile.applib_flow"] != -1 ||    \
                                       [lsearch $include_filter "traffic_l47_config.traffic_l47_handle.applib_profile.applib_flow.parameter"] != -1 ||  \
                                       [lsearch $include_filter "traffic_l47_config.traffic_l47_handle.applib_profile.applib_flow.connection"] != -1 || \
                                       [lsearch $include_filter "traffic_l47_config.traffic_l47_handle.applib_profile.applib_flow.connection.parameter"] != -1]

    if {[llength $include_filter] == 0 || [lsearch $include_filter "traffic_config"] != -1} {
        # add all include filters, needed for traffic modes called with -do_serialize 0
        set ce_req_list    [mode_get_traffic_ce                   -get_serialize_req_list 1]
        set hls_req_list   [mode_get_traffic_hls                  -get_serialize_req_list 1]
        set app_req_list   [mode_get_traffic_application_profiles -get_serialize_req_list 1]
        set app_lib_req_list   [mode_get_traffic_applib_profiles  -get_serialize_req_list 1]
        set stack_req_list [mode_get_traffic_headers              -get_serialize_req_list 1]

        set req_list [concat_filter_map $req_list $ce_req_list]
        set req_list [concat_filter_map $req_list $hls_req_list]
        set req_list [concat_filter_map $req_list $app_req_list]
        set req_list [concat_filter_map $req_list $app_lib_req_list]
        set req_list [concat_filter_map $req_list $stack_req_list]

    } elseif {[llength $include_filter] == 0 || [lsearch $include_filter "traffic_config.traffic_item"] != -1} {
        # need just app profiles, ce's because of returned keys
        set ce_req_list         [mode_get_traffic_ce                   -get_serialize_req_list 1]
        set app_req_list        [mode_get_traffic_application_profiles -get_serialize_req_list 1]
        set app_lib_req_list    [mode_get_traffic_applib_profiles -get_serialize_req_list 1]

        set req_list [concat_filter_map $req_list $ce_req_list]
        set req_list [concat_filter_map $req_list $app_req_list]
        set req_list [concat_filter_map $req_list $app_lib_req_list]
    } elseif {$app_lib_filter_handles} {    
        set app_lib_req_list    [mode_get_traffic_applib_profiles -get_serialize_req_list 1]
        set req_list [concat_filter_map $req_list $app_lib_req_list]
    }
    # if {[lsearch $include_filter "traffic_config.stream_id"] != -1} {}, nothing needed for stream_id

    try_eval {
        sr_initialize "session_info" $req_list

        if {$arg_detect_required_session_variables} {
            # need to reconstruct each time internal protocol dependent data, see previous comment
            set rval [ixia::detect_protocol_variables]
            if {[keylget rval status] != $::SUCCESS} {
                error [keylget rval log]
            }
        }

        set returnList [build_key_list $keymap $include_filter]
        build_traffic_key_list -dict_ref returnList
    } {
        # catch
        return [make_error $errorResult]
    } {
        # finally
        sr_finalize
    }

    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
#
# Description:
#   Returns a list of traffic items present in the config
#
proc ::ixia::session_info::mode_get_traffic_items { args } {

    ixia::util::import_namespace_procs "::ixia::util" {
        upvar_variable_list
        parse_dashed_args_no_verifs
    }

    set dashed_args {
        -dict_ref
    }
    parse_dashed_args_no_verifs $args $dashed_args

    # this may be called inline from get_session_keys, add to an existing dict
    if {[info exists argi_dict_ref]} {
        upvar_variable_list [list $argi_dict_ref]
        set returnList [set $argi_dict_ref]
    }

    # no need to serialize for this
    array set ti_name_info_l23 [list]
    array set ti_name_info_l47 [list]
    array set ti_name_info_l47_app_lib [list]
    set l23_ordered_list [list]
    set l47_ordered_list [list]
    set l47_app_lib_ordered_list [list]
    set l47_app_lib_traffic_list [list]
    foreach ti [ixNet getL ::ixNet::OBJ-/traffic trafficItem] {
        if {[ixNet getA $ti -trafficItemType] == "l2L3"} {
            set ti_name_info_l23([ixNet getA $ti -name]) [ixNet getA $ti "-warnings"]
            lappend l23_ordered_list [ixNet getA $ti -name]
        } elseif {[ixNet getA $ti -trafficItemType] == "applicationLibrary"} {
            set ti_name_info_l47_app_lib([ixNet getA $ti -name]) [ixNet getA $ti "-warnings"]
            lappend l47_app_lib_ordered_list [ixNet getA $ti -name]
            set ret_val [regsub -all {::ixNet::OBJ-} $ti "" ti]
            lappend l47_app_lib_traffic_list $ti
        } else {
            set ti_name_info_l47([ixNet getA $ti -name]) [ixNet getA $ti "-warnings"]
            lappend l47_ordered_list [ixNet getA $ti -name]
        }
    }
    if {[array size ti_name_info_l23] > 0} {
        foreach ti_name $l23_ordered_list {
            keylset returnList ${ti_name}.traffic_config.warnings $ti_name_info_l23($ti_name)
        }
        keylset returnList traffic_config $l23_ordered_list
    }
    if {[array size ti_name_info_l47] > 0} {
        foreach ti_name $l47_ordered_list {
            keylset returnList ${ti_name}.traffic_config.warnings $ti_name_info_l47($ti_name)
        }
        keylset returnList traffic_config_L47 $l47_ordered_list
    }
    if {[array size ti_name_info_l47_app_lib] > 0} {
        keylset returnList traffic_l47_config.traffic_l47_handle $l47_app_lib_traffic_list
    }
    # this may be called inline from get_session_keys, update the existing dict
    if {[info exists argi_dict_ref]} {
        set $argi_dict_ref $returnList
    }

    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
#
# Description:
#   Returns a list of config elements given a traffic item
#
# Input:
#   See $upvar_list
#   args, dashed form
# Output:
#   serialize req list or ce related keys
#
proc ::ixia::session_info::mode_get_traffic_ce { args } {

    ixia::util::import_namespace_procs "::ixia::util" {
        make_error
        upvar_variable_list
        parse_dashed_args_no_verifs
    }

    set upvar_list {
        arg_traffic_handle
    }
    upvar_variable_list $upvar_list

    set dashed_args {
        -dict_ref
        -do_serialize               DEFAULT 1
        -skip_single_optimization   DEFAULT 0
        -get_serialize_req_list     DEFAULT 0
    }
    parse_dashed_args_no_verifs $args $dashed_args

    set serialize_req_list [list                                    \
        /traffic/trafficItem                {name trafficItemType}  \
        /traffic/trafficItem/configElement  {}                      \
    ]
    if {$argi_get_serialize_req_list} {
        return $serialize_req_list
    }

    # this may be called inline from get_session_keys, add to an existing dict
    if {[info exists argi_dict_ref]} {
        upvar_variable_list [list $argi_dict_ref]
        set returnList [set $argi_dict_ref]
    }

    if {[info exists arg_traffic_handle] && [llength $arg_traffic_handle] == 1 && !$argi_skip_single_optimization} {
        set ti_name [lindex $arg_traffic_handle 0]
        set ti [ixia::540getTrafficItemByName $ti_name]
        if {$ti == "_none"} {
            return [make_error "Invalid traffic_handle '$ti_name'. It must be a traffic item name"]
        }
        if {[ixNet getA $ti "-trafficItemType"] != "l2L3"} {
            return [make_error "Invalid traffic_handle '$ti_name'. It must be an L2L3 traffic item name"]
        }

        set ce_list [ixNet getL $ti configElement]
        keylset returnList $ti_name.traffic_config.traffic_item $ce_list
    } else {
        # more than 1 ti, serialize
        ixia::util::import_namespace_procs "::ixia::session_resume" {
            sr_initialize
            sr_finalize

            sr_get_ixnhandle
            sr_get_node_by_ixnhandle
            sr_get_attribute
            sr_get_child_list
        }

        try_eval {
            if {$argi_do_serialize} {
                # need all objects because identification is based on ti name
                sr_initialize "session_info" $serialize_req_list
            }
            
            # same as ixia::540getTrafficItemByName
            array set ti_name_map [list]
            set traffic [sr_get_node_by_ixnhandle "::ixNet::OBJ-/traffic"]
            set ti_list [sr_get_child_list $traffic "trafficItem"]
            foreach ti $ti_list {
                set ti_name_map([sr_get_attribute $ti "-name"]) $ti
            }

            if {[info exists arg_traffic_handle]} {
                set ti_list [list]
                foreach ti_name $arg_traffic_handle {
                    if {[info exists ti_name_map($ti_name)]} {
                        if {[sr_get_attribute $ti_name_map($ti_name) "-trafficItemType"] != "l2L3"} {
                            error "Invalid traffic_handle '$ti_name'. It must be an L23 traffic item name"
                        }
                        lappend ti_list $ti_name_map($ti_name)
                    } else {
                        error "Invalid traffic_handle '$ti_name'. It must be a traffic item name"
                    }
                }
            }

            # build keys
            foreach ti $ti_list {
                # !exists arg_traffic_handle, pick only l23
                if {[sr_get_attribute $ti "-trafficItemType"] != "l2L3"} {
                    continue
                }
                set ce_list [sr_get_ixnhandle [sr_get_child_list $ti "configElement"]]
                set ti_name [sr_get_attribute $ti "-name"]
                keylset returnList $ti_name.traffic_config.traffic_item $ce_list
            }
        } {
            # catch
            return [make_error $errorResult]
        } {
            # finally
            if {$argi_do_serialize} {
                sr_finalize
            }
        }
    }

    # this may be called inline from get_session_keys, update the existing dict
    if {[info exists argi_dict_ref]} {
        set $argi_dict_ref $returnList
    }

    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
#
# Description:
#   Returns a list of high level streams (flow groups) given a traffic item
#
# Input:
#   See $upvar_list
#   args, dashed form
# Output:
#   serialize req list or hls related keys
#
proc ::ixia::session_info::mode_get_traffic_hls { args } {

    ixia::util::import_namespace_procs "::ixia::util" {
        make_error
        upvar_variable_list
        parse_dashed_args_no_verifs
    }

    set upvar_list {
        arg_traffic_handle
    }
    upvar_variable_list $upvar_list

    set dashed_args {
        -dict_ref
        -do_serialize               DEFAULT 1
        -skip_single_optimization   DEFAULT 0
        -get_serialize_req_list     DEFAULT 0
    }
    parse_dashed_args_no_verifs $args $dashed_args

    set serialize_req_list [list                                        \
        /traffic/trafficItem                  {name trafficItemType}    \
        /traffic/trafficItem/configElement    {encapsulationName}       \
        /traffic/trafficItem/highLevelStream  {encapsulationName}       \
    ]
    if {$argi_get_serialize_req_list} {
        return $serialize_req_list
    }

    # this may be called inline from get_session_keys, add to an existing dict
    if {[info exists argi_dict_ref]} {
        upvar_variable_list [list $argi_dict_ref]
        set returnList [set $argi_dict_ref]
    }

    if {[info exists arg_traffic_handle] && [llength $arg_traffic_handle] == 1 && !$argi_skip_single_optimization} {
        set ti_name [lindex $arg_traffic_handle 0]
        set ti [ixia::540getTrafficItemByName $ti_name]
        if {$ti == "_none"} {
            return [make_error "Invalid traffic_handle '$ti_name'. It must be a traffic item name"]
        }
        if {[ixNet getA $ti "-trafficItemType"] != "l2L3"} {
            return [make_error "Invalid traffic_handle '$ti_name'. It must be an L2L3 traffic item name"]
        }

        array set ce_hls [list]
        foreach hls [ixNet getL $ti highLevelStream] {
            set rval [ixia::540trafficGetCEforHLS $hls]
            set ce [keylget rval handle]
            lappend ce_hls($ce) $hls
        }
        foreach ce [array names ce_hls] {
            keylset returnList $ti_name.traffic_config.$ce.stream_ids $ce_hls($ce)
        }
    } else {
        # more than 1 ti, serialize
        ixia::util::import_namespace_procs "::ixia::session_resume" {
            sr_initialize
            sr_finalize

            sr_get_ixnhandle
            sr_get_node_by_ixnhandle
            sr_get_attribute
            sr_get_child_list
        }

        try_eval {
            if {$argi_do_serialize} {
                # need all objects because identification is based on ti name
                sr_initialize "session_info" $serialize_req_list
            }
            
            # same as ixia::540getTrafficItemByName
            array set ti_name_map [list]
            set traffic [sr_get_node_by_ixnhandle "::ixNet::OBJ-/traffic"]
            set ti_list [sr_get_child_list $traffic "trafficItem"]
            foreach ti $ti_list {
                set ti_name_map([sr_get_attribute $ti "-name"]) $ti
            }

            if {[info exists arg_traffic_handle]} {
                set ti_list [list]
                foreach ti_name $arg_traffic_handle {
                    if {[info exists ti_name_map($ti_name)]} {
                        if {[sr_get_attribute $ti_name_map($ti_name) "-trafficItemType"] != "l2L3"} {
                            error "Invalid traffic_handle '$ti_name'. It must be an L23 traffic item name"
                        }
                        lappend ti_list $ti_name_map($ti_name)
                    } else {
                        error "Invalid traffic_handle '$ti_name'. It must be a traffic item name"
                    }
                }
            }

            # build keys
            foreach ti $ti_list {
                # !exists arg_traffic_handle, pick only l23
                if {[sr_get_attribute $ti "-trafficItemType"] != "l2L3"} {
                    continue
                }

                # make an encap name -> ce map
                set ce_list [sr_get_child_list $ti "configElement"]
                array set ce_encap_map [list]
                foreach ce $ce_list {
                    set ce_encap_map([sr_get_attribute $ce "-encapsulationName"]) $ce
                }

                # make a ce->hls list map, because the keys need to split hls' by generating ce
                array set ce_hls [list]
                set hls_list [sr_get_child_list $ti "highLevelStream"]
                foreach hls $hls_list {
                    if {![info exists ce_encap_map([sr_get_attribute $hls "-encapsulationName"])]} {
                        error "Unable to find associated config element for '$hls'"
                    }
                    set assoc_ce $ce_encap_map([sr_get_attribute $hls "-encapsulationName"])
                    lappend ce_hls($assoc_ce) $hls
                }

                array unset ce_encap_map

                set ti_name [sr_get_attribute $ti "-name"]
                foreach ce [array names ce_hls] {
                    set hls_list [sr_get_ixnhandle $ce_hls($ce)]
                    set ce [sr_get_ixnhandle $ce]
                    keylset returnList $ti_name.traffic_config.$ce.stream_ids $hls_list
                }

                array unset ce_hls
            }
        } {
            # catch
            return [make_error $errorResult]
        } {
            # finally
            if {$argi_do_serialize} {
                sr_finalize
            }
        }
    }

    # this may be called inline from get_session_keys, update the existing dict
    if {[info exists argi_dict_ref]} {
        set $argi_dict_ref $returnList
    }

    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
#
# Description:
#   Returns a list of l47 application profiles given a traffic item
#
# Input:
#   See $upvar_list
#   args, dashed form
# Output:
#   serialize req list or L47 traffic keys
#
proc ::ixia::session_info::mode_get_traffic_application_profiles { args } {

    ixia::util::import_namespace_procs "::ixia::util" {
        make_error
        upvar_variable_list
        parse_dashed_args_no_verifs
    }

    set upvar_list {
        arg_traffic_handle
    }
    upvar_variable_list $upvar_list

    set dashed_args {
        -dict_ref
        -do_serialize               DEFAULT 1
        -skip_single_optimization   DEFAULT 0
        -get_serialize_req_list     DEFAULT 0
    }
    parse_dashed_args_no_verifs $args $dashed_args

    set serialize_req_list [list                                        \
        /traffic/trafficItem                    {name trafficItemType}  \
    ]
    if {$argi_get_serialize_req_list} {
        return $serialize_req_list
    }

    # this may be called inline from get_session_keys, add to an existing dict
    if {[info exists argi_dict_ref]} {
        upvar_variable_list [list $argi_dict_ref]
        set returnList [set $argi_dict_ref]
    }

    if {[info exists arg_traffic_handle] && [llength $arg_traffic_handle] == 1 && !$argi_skip_single_optimization} {
        set ti_name [lindex $arg_traffic_handle 0]
        set ti [ixia::540getTrafficItemByName $ti_name]
        if {$ti == "_none"} {
            return [make_error "Invalid traffic_handle '$ti_name'. It must be a traffic item name"]
        }
        if {[ixNet getA $ti "-trafficItemType"] != "application"} {
            return [make_error "Invalid traffic_handle '$ti_name'. It must be an L47 traffic item name"]
        }

        keylset returnList ${ti_name}.traffic_config.traffic_item [ixNet getL $ti "applicationProfile"]
    } else {
        # more than 1 ti, serialize
        ixia::util::import_namespace_procs "::ixia::session_resume" {
            sr_initialize
            sr_finalize

            sr_get_ixnhandle
            sr_get_node_by_ixnhandle
            sr_get_attribute
            sr_get_child_list
        }

        try_eval {
            if {$argi_do_serialize} {
                sr_initialize "session_info" $serialize_req_list
            }
            
            # same as ixia::540getTrafficItemByName
            array set ti_name_map [list]
            set traffic [sr_get_node_by_ixnhandle "::ixNet::OBJ-/traffic"]
            set ti_list [sr_get_child_list $traffic "trafficItem"]
            foreach ti $ti_list {
                set ti_name_map([sr_get_attribute $ti "-name"]) $ti
            }

            if {[info exists arg_traffic_handle]} {
                set ti_list [list]
                foreach ti_name $arg_traffic_handle {
                    if {[info exists ti_name_map($ti_name)]} {
                        if {[sr_get_attribute $ti_name_map($ti_name) "-trafficItemType"] != "application"} {
                            error "Invalid traffic_handle '$ti_name'. It must be an L47 traffic item name"
                        }
                        lappend ti_list $ti_name_map($ti_name)
                    } else {
                        error "Invalid traffic_handle '$ti_name'. It must be a traffic item name"
                    }
                }
            }

            # build keys
            foreach ti $ti_list {
                if {[sr_get_attribute $ti "-trafficItemType"] != "application"} {
                    continue
                }
                set profile [sr_get_ixnhandle [sr_get_child_list $ti "applicationProfile"]]
                set ti_name [sr_get_attribute $ti "-name"]

                keylset returnList ${ti_name}.traffic_config.traffic_item $profile
            }
        } {
            # catch
            return [make_error $errorResult]
        } {
            # finally
            if {$argi_do_serialize} {
                sr_finalize
            }
        }
    }

    # this may be called inline from get_session_keys, update the existing dict
    if {[info exists argi_dict_ref]} {
        set $argi_dict_ref $returnList
    }

    keylset returnList status $::SUCCESS
    return $returnList
}
##Internal Procedure Header
#
# Description:
#   Returns a list of l47 appLib Traffic profiles given a traffic item
#
# Input:
#   See $upvar_list
#   args, dashed form
# Output:
#   serialize req list or L47 traffic keys
#
proc ::ixia::session_info::mode_get_traffic_applib_profiles { args } {

    ixia::util::import_namespace_procs "::ixia::util" {
        make_error
        upvar_variable_list
        parse_dashed_args_no_verifs
    }
    set upvar_list {
        arg_traffic_handle
        arg_session_keys_include_filter
    }
    upvar_variable_list $upvar_list

    set dashed_args {
        -dict_ref
        -do_serialize               DEFAULT 1
        -skip_single_optimization   DEFAULT 0
        -get_serialize_req_list     DEFAULT 0
    }
    parse_dashed_args_no_verifs $args $dashed_args

    set serialize_req_list [list                                                                        \
        /traffic/trafficItem                                                    {name trafficItemType}  \
        /traffic/trafficItem/appLibProfile                                      {}                      \
        /traffic/trafficItem/appLibProfile/appLibFlow                           {}                      \
        /traffic/trafficItem/appLibProfile/appLibFlow/parameter                 {}                      \
        /traffic/trafficItem/appLibProfile/appLibFlow/connection                {}                      \
        /traffic/trafficItem/appLibProfile/appLibFlow/connection/parameter      {}                      \
    ]
    if {$argi_get_serialize_req_list} {
        return $serialize_req_list
    }

    # this may be called inline from get_session_keys, add to an existing dict
    if {[info exists argi_dict_ref]} {
        upvar_variable_list [list $argi_dict_ref]
        set returnList [set $argi_dict_ref]
    }
    
    set include_filter [list]
    if {[info exists arg_session_keys_include_filter]} {
        set include_filter $arg_session_keys_include_filter
    }

    #Initialize traffic_l47_config_ret
    set traffic_l47_config_ret [list]
    set traffic_l47_config_enable    [expr [llength $include_filter] == 0 || [lsearch $include_filter "traffic_l47_config"] != -1]
    
    if {[info exists arg_traffic_handle] && [llength $arg_traffic_handle] == 1 && !$argi_skip_single_optimization} {
        set ti_name [lindex $arg_traffic_handle 0]
        set ti [ixia::540getTrafficItemByName $ti_name]        
        if {$ti == "_none"} {
            return [make_error "Invalid traffic_handle '$ti_name'. It must be a traffic item name"]
        }
        
        if {$traffic_l47_config_enable} {
            keylset traffic_l47_config_ret traffic_l47_handle $ti
        }

        if {[ixNet getA $ti "-trafficItemType"] != "applicationLibrary"} {
            return [make_error "Invalid traffic_handle '$ti_name'. It must be an L47 traffic item name"]
        }
        
        set appLibProfile   [ixNet getL $ti "appLibProfile"]
        if {[lsearch $include_filter "traffic_l47_config.traffic_l47_handle.applib_profile"] != -1} {
            keylset traffic_l47_config_ret ${ti}.applib_profile $appLibProfile
        }        
        
        set appLibFlows     [ixNet getL $appLibProfile appLibFlow]
        if {[lsearch $include_filter "traffic_l47_config.traffic_l47_handle.applib_profile.applib_flow"] != -1} {
            keylset traffic_l47_config_ret ${ti}.${appLibProfile}.applib_flow $appLibFlows
        }
        
        foreach appLibFlow $appLibFlows { 
            if {[lsearch $include_filter "traffic_l47_config.traffic_l47_handle.applib_profile.applib_flow.parameter"] != -1} {
                set parameter       [ixNet getL $appLibFlow parameter]
                keylset traffic_l47_config_ret ${ti}.${appLibProfile}.${appLibFlow}.parameter $parameter
            }            
            if {[lsearch $include_filter "traffic_l47_config.traffic_l47_handle.applib_profile.applib_flow.connection"] != -1} {
                set connections      [ixNet getL $appLibFlow connection]
                keylset traffic_l47_config_ret ${ti}.${appLibProfile}.${appLibFlow}.connection $connections
            }
            if {[lsearch $include_filter "traffic_l47_config.traffic_l47_handle.applib_profile.applib_flow.connection.parameter"] != -1} {
                set connections      [ixNet getL $appLibFlow connection]     
                foreach conn $connections {
                    set connParameters   [ixNet getL $conn parameter]                    
                    keylset traffic_l47_config_ret ${ti}.${appLibProfile}.${appLibFlow}.${conn}.parameter $connParameters
                }
            }            
        }        
    } else {
        # more than 1 ti, serialize
        ixia::util::import_namespace_procs "::ixia::session_resume" {
            sr_initialize
            sr_finalize

            sr_get_ixnhandle
            sr_get_node_by_ixnhandle
            sr_get_attribute
            sr_get_child_list
        }
        try_eval {
            if {$argi_do_serialize} {
                sr_initialize "session_info" $serialize_req_list
            }
            # same as ixia::540getTrafficItemByName
            array set ti_name_map [list]
            set traffic [sr_get_node_by_ixnhandle "::ixNet::OBJ-/traffic"]
            set ti_list [sr_get_child_list $traffic "trafficItem"]
            foreach ti $ti_list {
                set ti_name_map([sr_get_attribute $ti "-name"]) $ti
            }

            if {[info exists arg_traffic_handle]} {
                set ti_list [list]
                foreach ti_name $arg_traffic_handle {
                    if {[info exists ti_name_map($ti_name)]} {
                        if {[sr_get_attribute $ti_name_map($ti_name) "-trafficItemType"] != "applicationLibrary"} {
                            error "Invalid traffic_handle '$ti_name'. It must be an L47 traffic item name"
                        }
                        lappend ti_list $ti_name_map($ti_name)
                    } else {
                        error "Invalid traffic_handle '$ti_name'. It must be a traffic item name"
                    }
                }
            }

            # build keys
            set traffic_l47_handle_list [list]
            foreach ti $ti_list {
                if {[sr_get_attribute $ti "-trafficItemType"] != "applicationLibrary"} {
                    continue
                }
                
                set ti_name [sr_get_attribute $ti "-name"]
                set traffic_l47_handle [sr_get_ixnhandle $ti]
                lappend traffic_l47_handle_list $traffic_l47_handle                
                
                set profile [sr_get_child_list $ti "appLibProfile"]
                set appLibProfile [sr_get_ixnhandle $profile]
                if {[lsearch $include_filter "traffic_l47_config.traffic_l47_handle.applib_profile"] != -1} {
                    keylset traffic_l47_config_ret ${traffic_l47_handle}.applib_profile $appLibProfile
                }
                
                set appLibFlows     [sr_get_child_list $profile "appLibFlow"]
                set flow_handle_list [list]
                foreach appLibFlow $appLibFlows {
                    set flow_handle     [sr_get_ixnhandle $appLibFlow]
                    lappend flow_handle_list $flow_handle                    
                    if {[lsearch $include_filter "traffic_l47_config.traffic_l47_handle.applib_profile.applib_flow.parameter"] != -1} {
                        set parameter       [sr_get_ixnhandle [sr_get_child_list $appLibFlow "parameter"]]
                        keylset traffic_l47_config_ret ${traffic_l47_handle}.${appLibProfile}.${flow_handle}.parameter $parameter
                    }
                    
                    if {[lsearch $include_filter "traffic_l47_config.traffic_l47_handle.applib_profile.applib_flow.connection"] != -1} {
                        set connection      [sr_get_child_list $appLibFlow "connection"]
                        foreach conn $connection {
                            set con_handle [sr_get_ixnhandle $conn]
                            lappend conn_handle_list $con_handle    
                        }
                        keylset traffic_l47_config_ret ${traffic_l47_handle}.${appLibProfile}.${flow_handle}.connection $conn_handle_list
                    }
                    
                    if {[lsearch $include_filter "traffic_l47_config.traffic_l47_handle.applib_profile.applib_flow.connection.parameter"] != -1} {                            
                        set connection      [sr_get_child_list $appLibFlow "connection"]
                        foreach conn $connection {
                            set con_handle [sr_get_ixnhandle $conn]
                            set connParameter   [sr_get_child_list $conn "parameter"]
                            set con_param_handle [list]
                            foreach conn_param $connParameter {
                                lappend con_param_handle [sr_get_ixnhandle $conn_param]
                            }
                            keylset traffic_l47_config_ret ${traffic_l47_handle}.${appLibProfile}.${flow_handle}.${con_handle}.parameter $con_param_handle
                        }
                    }
                }
                
                if {[lsearch $include_filter "traffic_l47_config.traffic_l47_handle.applib_profile.applib_flow"] != -1} {
                    keylset traffic_l47_config_ret ${traffic_l47_handle}.${appLibProfile}.applib_flow $flow_handle_list
                }
            }
            if {[llength $traffic_l47_handle_list] > 0 && $traffic_l47_config_enable} {
                keylset traffic_l47_config_ret traffic_l47_handle $traffic_l47_handle_list
            }
        } {
            # catch
                return [make_error $errorResult]
        } {
            # finally
            if {$argi_do_serialize} {
                sr_finalize
            }
        }
    }

    # this may be called inline from get_session_keys, update the existing dict
    if {[info exists argi_dict_ref]} {
        set $argi_dict_ref $returnList
    }
    if {$traffic_l47_config_ret != ""} {
        set ret_val [regsub -all {::ixNet::OBJ-} $traffic_l47_config_ret "" traffic_l47_config_ret]
        keylset returnList traffic_l47_config $traffic_l47_config_ret
    }
    keylset returnList status $::SUCCESS
    return $returnList
}
##Internal Procedure Header
#
# Description:
#   Returns a list of headers given a traffic config element
#
# Input:
#   See $upvar_list
#   args, dashed form
# Output:
#   serialize req list or L23 ce/hls stacks
#
proc ::ixia::session_info::mode_get_traffic_headers { args } {

    ixia::util::import_namespace_procs "::ixia::util" {
        make_error
        upvar_variable_list
        parse_dashed_args_no_verifs
    }

    set upvar_list {
        arg_traffic_handle
    }
    upvar_variable_list $upvar_list

    set dashed_args {
        -dict_ref
        -do_serialize               DEFAULT 1
        -skip_single_optimization   DEFAULT 0
        -get_serialize_req_list     DEFAULT 0
    }
    parse_dashed_args_no_verifs $args $dashed_args

    set serialize_req_list [list                                        \
        /traffic/trafficItem                        {name}              \
        /traffic/trafficItem/configElement          {encapsulationName} \
        /traffic/trafficItem/configElement/stack    {}                  \
        /traffic/trafficItem/highLevelStream        {encapsulationName} \
        /traffic/trafficItem/highLevelStream/stack  {}                  \
    ]
    if {$argi_get_serialize_req_list} {
        return $serialize_req_list
    }

    # this may be called inline from get_session_keys, add to an existing dict
    if {[info exists argi_dict_ref]} {
        upvar_variable_list [list $argi_dict_ref]
        set returnList [set $argi_dict_ref]
    }

    if {[info exists arg_traffic_handle] && [llength $arg_traffic_handle] == 1 && !$argi_skip_single_optimization} {
        set t_elem [lindex $arg_traffic_handle 0]
        set rval [ixia::540IxNetValidateObject $t_elem {config_element high_level_stream}]
        if {[keylget rval status] != $::SUCCESS} {
            return [make_error "Invalid traffic_handle '$t_elem'. It must be a config element or high level stream"]
        }
        set handle_type [keylget rval value]
        set ti [ixia::ixNetworkGetParentObjref $t_elem "trafficItem"]
        set ti_name [ixNet getA $ti "-name"]

        set stack_list [ixNet getL $t_elem "stack"]
        switch -- $handle_type {
            "config_element" {
                keylset returnList $ti_name.traffic_config.$t_elem.headers $stack_list
            }
            "high_level_stream" {
                set rval [::ixia::540trafficGetCEforHLS $t_elem]
                set ce [keylget rval handle]
                keylset returnList $ti_name.traffic_config.$ce.$t_elem.headers $stack_list   
            }
        }
    } else {
        # more than 1 ce/hls, serialize
        ixia::util::import_namespace_procs "::ixia::session_resume" {
            sr_initialize
            sr_finalize

            sr_get_ixnhandle
            sr_get_node_by_ixnhandle
            sr_get_attribute
            sr_get_child_list
            sr_get_parent
        }

        try_eval {
            if {$argi_do_serialize} {
                set req_list $serialize_req_list

                if {[info exists arg_traffic_handle]} {
                    set ti_list [list]
                    foreach t_elem $arg_traffic_handle {
                        lappend ti_list [ixia::ixNetworkGetParentObjref $t_elem "trafficItem"]
                    }
                    set ti_list [lsort -unique $ti_list]
                    set specialize_paths [list]
                    foreach {req_elem _} $req_list {
                        lappend specialize_paths $req_elem
                    }
                    set req_list [specialize_filter $req_list $specialize_paths $ti_list]
                }

                sr_initialize "session_info" $req_list
            }

            set traffic_handle_list [list]
            if {[info exists arg_traffic_handle]} {
                foreach t_elem $arg_traffic_handle {
                    lappend traffic_handle_list [sr_get_node_by_ixnhandle $t_elem]
                }
            }
            
            array set ti_name_map [list]
            set traffic [sr_get_node_by_ixnhandle "::ixNet::OBJ-/traffic"]
            set ti_list [sr_get_child_list $traffic "trafficItem"]
            foreach ti $ti_list {
                set ti_name_map([sr_get_attribute $ti "-name"]) $ti

                # get all ce/hls if no input specified
                if {![info exists arg_traffic_handle]} {
                    set traffic_handle_list [concat $traffic_handle_list [sr_get_child_list $ti "configElement"]]
                    set traffic_handle_list [concat $traffic_handle_list [sr_get_child_list $ti "highLevelStream"]]
                }
            }

            # make a ti -> [list {ce/hls type}] map
            array set ti_handle_map [list]
            foreach t_elem $traffic_handle_list {
                set rval [ixia::540IxNetValidateObject [sr_get_ixnhandle $t_elem] {config_element high_level_stream}]
                if {[keylget rval status] != $::SUCCESS} {
                    error "Invalid traffic_handle '[1sr_get_ixnhandle $t_elem]'. It must be a config element or high level stream"
                }
                set handle_type [keylget rval value]

                set ti [sr_get_parent $t_elem "trafficItem"]
                lappend ti_handle_map($ti) $t_elem $handle_type
            }

            # build keys
            foreach ti [array names ti_handle_map] {
                set ti_name [sr_get_attribute $ti "-name"]

                # make an encap name -> ce map
                set ce_list [sr_get_child_list $ti "configElement"]
                array set ce_encap_map [list]
                foreach ce $ce_list {
                    set ce_encap_map([sr_get_attribute $ce "-encapsulationName"]) $ce
                }

                foreach {t_elem handle_type} $ti_handle_map($ti) {
                    set stack_list [sr_get_ixnhandle [sr_get_child_list $t_elem "stack"]]
                    switch -- $handle_type {
                        "config_element" {
                            set t_elem [sr_get_ixnhandle $t_elem]
                            keylset returnList $ti_name.traffic_config.$t_elem.headers $stack_list
                        }
                        "high_level_stream" {
                            set assoc_ce [sr_get_ixnhandle $ce_encap_map([sr_get_attribute $t_elem "-encapsulationName"])]
                            set t_elem [sr_get_ixnhandle $t_elem]
                            keylset returnList $ti_name.traffic_config.$assoc_ce.$t_elem.headers $stack_list   
                        }
                    }
                }

                array unset ce_encap_map
            }
        } {
            # catch
            return [make_error $errorResult]
        } {
            # finally
            if {$argi_do_serialize} {
                sr_finalize
            }
        }
    }

    # this may be called inline from get_session_keys, update the existing dict
    if {[info exists argi_dict_ref]} {
        set $argi_dict_ref $returnList
    }

    keylset returnList status $::SUCCESS
    return $returnList
}

namespace eval ::ixia::session_info::build_key_list {}
proc ::ixia::session_info::build_key_list::add_keymap_item {arg} {
    set ::ixia::session_info::build_key_list::proc_2_keys_map_1 [concat \
        $::ixia::session_info::build_key_list::proc_2_keys_map_1        \
        $arg                                                            \
    ]
}
set ::ixia::session_info::build_key_list::proc_2_keys_map_1 {
    connect     vport_list  vport   __vport
}

# interface_config
::ixia::session_info::build_key_list::add_keymap_item {
    interface_config    interface_handle            vport/interface                             {__obj_if -type default}
    interface_config    interface_handle            {
                                                        vport/protocols/static/atm                                                               
                                                        vport/protocols/static/fr                                                                
                                                        vport/protocols/static/ip                                                                
                                                        vport/protocols/static/lan                                                               
                                                        vport/protocols/static/interfaceGroup
                                                    }                                           __obj
    interface_config    routed_interface_handle     vport/interface                             {__obj_if -type routed}
    interface_config    gre_interface_handle        vport/interface                             {__obj_if -type gre}
    interface_config    atm_endpoints               vport/protocols/static/atm                  __obj
    interface_config    fr_endpoints                vport/protocols/static/fr                   __obj
    interface_config    ip_endpoints                vport/protocols/static/ip                   __obj
    interface_config    lan_endpoints               vport/protocols/static/lan                  __obj
    interface_config    ig_endpoints                vport/protocols/static/interfaceGroup       __obj
}

# bfd
::ixia::session_info::build_key_list::add_keymap_item {
    emulation_bfd_config            router_handles                      vport/protocols/bfd/router                      __obj
    emulation_bfd_config            router_interface_handles.__parent   vport/protocols/bfd/router/interface            __obj
    emulation_bfd_config            interface_handles.__parent          vport/protocols/bfd/router/interface            {__attr -interfaces}
    emulation_bfd_session_config    session_handles                     vport/protocols/bfd/router/interface/session    __obj
}

# bgp
::ixia::session_info::build_key_list::add_keymap_item {
    emulation_bgp_config        handles             vport/protocols/bgp/neighborRange                       __obj
    emulation_bgp_route_config  bgp_routes          {
                                                        vport/protocols/bgp/neighborRange/routeRange
                                                        vport/protocols/bgp/neighborRange/mplsRouteRange
                                                        vport/protocols/bgp/neighborRange/l3Site
                                                        vport/protocols/bgp/neighborRange/l2Site
                                                    }                                                       __obj
    emulation_bgp_route_config  bgp_sites.__parent  vport/protocols/bgp/neighborRange/l3Site/vpnRouteRange  __obj
    emulation_bgp_route_config  bgp_sites.__parent  vport/protocols/bgp/neighborRange/l2Site/labelBlock     __obj
}

# cfm
::ixia::session_info::build_key_list::add_keymap_item {
    emulation_cfm_config                handle                      vport/protocols/cfm/bridge                  __obj
    emulation_cfm_config                interface_handles           vport/protocols/cfm/bridge/interface        {__attr -interfaceId}
    emulation_cfm_custom_tlv_config     handle                      vport/protocols/cfm/bridge/customTlvs       __obj
    emulation_cfm_links_config          handle                      vport/protocols/cfm/bridge/link             __obj
    emulation_cfm_md_meg_config         handle                      vport/protocols/cfm/bridge/mdLevel          __obj
    emulation_cfm_mip_mep_config        handle                      vport/protocols/cfm/bridge/mp               __obj
    emulation_cfm_vlan_config           handle                      vport/protocols/cfm/bridge/vlans            __obj
    emulation_cfm_vlan_config           mac_range_handles.__parent  vport/protocols/cfm/bridge/vlans/macRanges  __obj
}

# dhcp
::ixia::session_info::build_key_list::add_keymap_item {
    emulation_dhcp_config           handle              vport                                                                       {__obj_if_exists_any {
                                                                                                                                        vport/protocolStack/ethernet/dhcpEndpoint/range
                                                                                                                                        vport/protocolStack/atm/dhcpEndpoint/range
                                                                                                                                    } vport}
    emulation_dhcp_group_config     handle              {
                                                            vport/protocolStack/ethernet/dhcpEndpoint/range
                                                            vport/protocolStack/atm/dhcpEndpoint/range
                                                        }                                                                           __obj
    emulation_dhcp_server_config    handle              vport                                                                       __skip
    emulation_dhcp_server_config    handle.dhcp_handle  {
                                                            vport/protocolStack/ethernet/dhcpServerEndpoint/range/dhcpServerRange
                                                            vport/protocolStack/atm/dhcpServerEndpoint/range/dhcpServerRange
                                                        }                                                                           __obj
    dhcp_client_extension_config    handle              {
                                                            vport/protocolStack/ethernet/ip/l2tpEndpoint/range/dhcpv6ClientRange
                                                            vport/protocolStack/atm/ip/l2tpEndpoint/range/dhcpv6ClientRange
                                                            vport/protocolStack/ethernet/pppoxEndpoint/range/dhcpv6ClientRange
                                                            vport/protocolStack/atm/pppoxEndpoint/range/dhcpv6ClientRange
                                                        }                                                                           __obj
    dhcp_server_extension_config    handle              {
                                                            vport/protocolStack/ethernet/ip/l2tpEndpoint/range/dhcpv6ServerRange
                                                            vport/protocolStack/atm/ip/l2tpEndpoint/range/dhcpv6ServerRange
                                                            vport/protocolStack/ethernet/pppoxEndpoint/range/dhcpv6ServerRange
                                                            vport/protocolStack/atm/pppoxEndpoint/range/dhcpv6ServerRange
                                                        }                                                                           __obj
}

# efm
::ixia::session_info::build_key_list::add_keymap_item {
    emulation_efm_config            information_oampdu_id           vport                                                           {__obj_if_exists_any {
                                                                                                                                        vport/protocols/linkOam/link/organizationSpecificEventTlv
                                                                                                                                        vport/protocols/linkOam/link/variableResponseDatabase
                                                                                                                                        vport/protocols/linkOam/link/varDescriptor
                                                                                                                                    } vport}
    emulation_efm_config            event_notification_oampdu_id    vport                                                           {__obj_if_exists_any {
                                                                                                                                        vport/protocols/linkOam/link/organizationSpecificEventTlv
                                                                                                                                        vport/protocols/linkOam/link/variableResponseDatabase
                                                                                                                                        vport/protocols/linkOam/link/varDescriptor
                                                                                                                                    } vport}
    emulation_efm_org_var_config    handle                          {
                                                                        vport/protocols/linkOam/link/organizationSpecificEventTlv
                                                                        vport/protocols/linkOam/link/variableResponseDatabase
                                                                        vport/protocols/linkOam/link/varDescriptor
                                                                    }                                                               __obj
}

# eigrp
::ixia::session_info::build_key_list::add_keymap_item {
    emulation_eigrp_config          router_handles                          vport/protocols/eigrp/router                __obj
    emulation_eigrp_config          interface_handles                       vport/protocols/eigrp/router/interface      {__attr -interfaces}
    emulation_eigrp_config          __parent.connected_interface_handles    vport/protocols/eigrp/router/interface      __skip
    emulation_eigrp_config          __parent.gre_interface_handles          vport/protocols/eigrp/router/interface      __skip
    emulation_eigrp_route_config    session_handles                         vport/protocols/eigrp/router/routeRange     __obj
}

# elmi
::ixia::session_info::build_key_list::add_keymap_item {
    emulation_elmi_config               uni_handles                 vport/protocols/elmi/uni                        __obj
    emulation_elmi_config               interface_handles           vport/protocols/elmi/uni                        {__attr -protocolInterface}
    emulation_elmi_config               uni_status_handles          vport/protocols/elmi/uni/uniStatus              __obj
    emulation_elmi_config               bw_profile_handles          vport/protocols/elmi/uni/uniStatus/bwProfile    __obj
    emulation_elmi_config               evc_handles                 vport/protocols/elmi/uni/evc                    __obj
    emulation_elmi_config               bw_profile_handles          vport/protocols/elmi/uni/evc/bwProfile          __obj
    emulation_elmi_config               ce_vlan_id_range_handles    vport/protocols/elmi/uni/evc/ceVlanIdRange      __obj
}

# igmp
::ixia::session_info::build_key_list::add_keymap_item {
    emulation_igmp_config           handle              vport/protocols/igmp/host               __obj
    emulation_igmp_querier_config   handle              vport/protocols/igmp/querier            __obj
    emulation_igmp_group_config     handle              vport/protocols/igmp/host/group         __obj
    emulation_igmp_group_config     source_handle       vport/protocols/igmp/host/group/source  __obj
    emulation_igmp_group_config     group_pool_handle   placeholder                             __skip
    emulation_igmp_group_config     source_pool_handle  placeholder                             __skip
}

# isis
::ixia::session_info::build_key_list::add_keymap_item {
    emulation_isis_config                   handle                                  vport/protocols/isis/router                 __obj
    emulation_isis_topology_route_config    elem_handle                             vport/protocols/isis/router/networkRange    __obj
    emulation_isis_topology_route_config    version                                 vport/protocols/isis/router/networkRange    __skip
    emulation_isis_topology_route_config    elem_handle                             vport/protocols/isis/router/routeRange      __isis_rr
    emulation_isis_topology_route_config    stub.num_networks                       vport/protocols/isis/router/routeRange      {__obj_count -routeOrigin False}
    emulation_isis_topology_route_config    external.num_networks                   vport/protocols/isis/router/routeRange      {__obj_count -routeOrigin True}
    emulation_isis_topology_route_config    grid.connected_session.__parent.row     vport/protocols/isis/router/networkRange    {__attr -noOfRows}
    emulation_isis_topology_route_config    grid.connected_session.__parent.col     vport/protocols/isis/router/networkRange    {__attr -noOfCols}
}

# emulation_multicast_*_config
::ixia::session_info::build_key_list::add_keymap_item {
    emulation_multicast_source_config   {}  vport   {__multicast_config multicast_source_array}
    emulation_multicast_group_config    {}  vport   {__multicast_config multicast_group_array}
}

# l2tp
# vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6PdClientRange
# vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range/dhcpv6PdClientRange
# vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6ServerRange
# vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range/dhcpv6ServerRange
::ixia::session_info::build_key_list::add_keymap_item {
    l2tp_config     handles     {
                                    vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range
                                    vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range
                                    vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range
                                    vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range
                                    vport/protocolStack/ethernet/ip/l2tpEndpoint/range
                                    vport/protocolStack/atm/ip/l2tpEndpoint/range
                                }                                                                                       __obj
}

# lacp
::ixia::session_info::build_key_list::add_keymap_item {
    emulation_lacp_link_config  handle  vport/protocols/lacp/link   __obj
}

# ldp
::ixia::session_info::build_key_list::add_keymap_item {
    emulation_ldp_route_config  lsp_handle                  {
                                                                vport/protocols/ldp/router/advFecRange
                                                                vport/protocols/ldp/router/reqFecRange
                                                                vport/protocols/ldp/router/l2Interface
                                                            }                                                               __obj
    emulation_ldp_route_config  lsp_intf                    vport/protocols/ldp/router/l2Interface                          __obj
    emulation_ldp_route_config  lsp_vc_range_handles        vport/protocols/ldp/router/l2Interface/l2VcRange                __obj
    emulation_ldp_route_config  lsp_vc_ip_range_handles     vport/protocols/ldp/router/l2Interface/l2VcRange/l2VcIpRange    __obj
    emulation_ldp_route_config  lsp_vc_mac_range_handles    vport/protocols/ldp/router/l2Interface/l2VcRange/l2MacVlanRange __obj
    emulation_ldp_config        handle                      vport/protocols/ldp/router                                      __obj
}

# mld
::ixia::session_info::build_key_list::add_keymap_item {
    emulation_mld_group_config  handle                  vport/protocols/mld/host/groupRange     __obj
    emulation_mld_group_config  group_pool_handle       placeholder                             __skip
    emulation_mld_group_config  source_pool_handles     placeholder                             __skip
    emulation_mld_config        handle                  vport/protocols/mld/host                __obj
}

# oam
::ixia::session_info::build_key_list::add_keymap_item {
    emulation_oam_config_msg        handle              placeholder     __skip
    emulation_oam_config_topology   handle              placeholder     __skip
    emulation_oam_config_topology   traffic_handles     placeholder     __skip
}

# ospf
::ixia::session_info::build_key_list::add_keymap_item {
    emulation_ospf_topology_route_config    elem_handle     {
                                                                vport/protocols/ospf/router/interface
                                                                vport/protocols/ospfV3/router/networkRange
                                                                vport/protocols/ospf/router/routeRange
                                                                vport/protocols/ospfV3/router/routeRange
                                                            }                                               __obj
    emulation_ospf_config                   handle          {
                                                                vport/protocols/ospf/router
                                                                vport/protocols/ospfV3/router
                                                            }                                               __obj
}

# pbb
::ixia::session_info::build_key_list::add_keymap_item {
    emulation_pbb_config        handle              vport/protocols/cfm/bridge/interface        __obj
    emulation_pbb_config        interface_handles   vport/protocols/cfm/bridge/interface        {__attr -interfaceId}
    emulation_pbb_trunk_config  trunk_handle        vport/protocols/cfm/bridge/trunk            __obj
    emulation_pbb_trunk_config  mr_handle           vport/protocols/cfm/bridge/trunk/macRanges  __obj
}

# pim
::ixia::session_info::build_key_list::add_keymap_item {
    emulation_pim_config        handle                  vport/protocols/pimsm/router                         __obj
    emulation_pim_config        interfaces              vport/protocols/pimsm/router/interface               __obj
    emulation_pim_group_config  handle                  {
                                                            vport/protocols/pimsm/router/interface/joinPrune
                                                            vport/protocols/pimsm/router/interface/source
                                                            vport/protocols/pimsm/router/interface/crpRange
                                                        }                                                    __obj
    emulation_pim_group_config  group_pool_handle       placeholder                                          __skip
    emulation_pim_group_config  source_pool_handles     placeholder                                          __skip
}

# pppox
::ixia::session_info::build_key_list::add_keymap_item {
    pppox_config    handles {
                                vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range
                                vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range
                                vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range
                                vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range
                                vport/protocolStack/ethernet/pppoxEndpoint/range
                                vport/protocolStack/atm/pppoxEndpoint/range
                            }                                                                   __obj
}

# rip
::ixia::session_info::build_key_list::add_keymap_item {
    emulation_rip_config        handle          vport/protocols/rip/router              __obj
    emulation_rip_route_config  route_handle    vport/protocols/rip/router/routeRange   __obj
    emulation_rip_config        handle          vport/protocols/rip/router              __obj
}

# rsvp
::ixia::session_info::build_key_list::add_keymap_item {
    emulation_rsvp_config           handles                                 vport/protocols/rsvp/neighborPair                                   __obj
    emulation_rsvp_config           router_interface_handle.__parent        placeholder                                                         __skip
    emulation_rsvp_tunnel_config    tunnel_handle                           vport/protocols/rsvp/neighborPair/destinationRange                  __obj
    emulation_rsvp_tunnel_config    tunnel_leaves_handle.__parent/ingress   vport/protocols/rsvp/neighborPair/destinationRange/tunnelLeafRange  __obj
    emulation_rsvp_tunnel_config    routed_interfaces.__parent/ingress      vport/protocols/rsvp/neighborPair/destinationRange/tunnelLeafRange  __skip
    emulation_rsvp_tunnel_config    tunnel_leaves_handle.__parent           vport/protocols/rsvp/neighborPair/destinationRange/tunnelLeafRange  __obj
}

# stp
::ixia::session_info::build_key_list::add_keymap_item {
    emulation_stp_msti_config       handle                              vport/protocols/stp/bridge/msti         __obj
    emulation_stp_bridge_config     bridge_handle                       vport/protocols/stp/bridge              __obj
    emulation_stp_bridge_config     bridge_interface_handles.__parent   vport/protocols/stp/bridge/interface    __obj
    emulation_stp_bridge_config     interface_handles.__parent          vport/protocols/stp/bridge/interface    {__attr -interfaceId}
}

# twamp
::ixia::session_info::build_key_list::add_keymap_item {
    emulation_twamp_config                  handle  vport/protocolStack/twampOptions                                    {__obj_parent vport}
    emulation_twamp_config                  handle  vport/protocolStack/ethernet/ipEndpoint/range/twampServerRange      {__obj_parent vport}
    emulation_twamp_config                  handle  vport/protocolStack/atm/ipEndpoint/range/twampServerRange           {__obj_parent vport}        
    emulation_twamp_control_range_config    handle  vport/protocolStack/ethernet/ipEndpoint/range/twampControlRange     __obj
    emulation_twamp_control_range_config    handle  vport/protocolStack/atm/ipEndpoint/range/twampControlRange          __obj
    emulation_twamp_test_range_config       handle  vport/protocolStack/ethernet/ipEndpoint/range/twampTestRange        __obj
    emulation_twamp_test_range_config       handle  vport/protocolStack/atm/ipEndpoint/range/twampTestRange             __obj
    emulation_twamp_server_range_config     handle  vport/protocolStack/ethernet/ipEndpoint/range/twampServerRange      __obj
    emulation_twamp_server_range_config     handle  vport/protocolStack/atm/ipEndpoint/range/twampServerRange           __obj
}

# ancp
::ixia::session_info::build_key_list::add_keymap_item {
    emulation_ancp_config                   handle  {
                                                        vport/protocolStack/ethernet/ipEndpoint/range/ancpRange
                                                        vport/protocolStack/ethernet/ip/l2tpEndpoint/range/ancpRange
                                                        vport/protocolStack/ethernet/ip/l2tp/dhcpoLnsEndpoint/range/ancpRange
                                                        vport/protocolStack/ethernet/ip/l2tp/dhcpoLacEndpoint/range/ancpRange
                                                        vport/protocolStack/ethernet/dhcpEndpoint/range/ancpRange
                                                        vport/protocolStack/ethernet/pppoxEndpoint/range/ancpRange
                                                        vport/protocolStack/ethernet/pppox/dhcpoPppServerEndpoint/range/ancpRange
                                                        vport/protocolStack/ethernet/pppox/dhcpoPppClientEndpoint/range/ancpRange
                                                        vport/protocolStack/atm/ipEndpoint/range/ancpRange
                                                        vport/protocolStack/atm/ip/l2tpEndpoint/range/ancpRange
                                                        vport/protocolStack/atm/ip/l2tp/dhcpoLnsEndpoint/range/ancpRange
                                                        vport/protocolStack/atm/ip/l2tp/dhcpoLacEndpoint/range/ancpRange
                                                        vport/protocolStack/atm/dhcpEndpoint/range/ancpRange
                                                        vport/protocolStack/atm/pppoxEndpoint/range/ancpRange
                                                        vport/protocolStack/atm/pppox/dhcpoPppServerEndpoint/range/ancpRange
                                                        vport/protocolStack/atm/pppox/dhcpoPppClientEndpoint/range/ancpRange
                                                    }                                                                               __obj
    emulation_ancp_subscriber_lines_config  handle  {
                                                        globals/protocolStack/ancpGlobals/ancpDslProfile
                                                        globals/protocolStack/ancpGlobals/ancpDslResyncProfile
                                                    }                                                                               __globals

    emulation_ancp_subscriber_lines_config  handle  vport                                                                           __ancp_dsl_profile
}

# fc
::ixia::session_info::build_key_list::add_keymap_item {
    fc_client_config        handle  vport/protocolStack/fcClientEndpoint/range              __obj
    fc_fport_config         handle  vport/protocolStack/fcFportFwdEndpoint/range            __obj
    fc_fport_vnport_config  handle  vport/protocolStack/fcFportFwdEndpoint/secondaryRange   __obj
}

proc ::ixia::session_info::validate_session_keys_include_filter {filter} {
    if {[llength $filter] == 0} {
        return
    }

    set session_resume_keys {}
    set session_resume_keys_wildcard {}

    # special + legacy keys
    lappend session_resume_keys "traffic_config"
    lappend session_resume_keys "traffic_config.traffic_item"
    lappend session_resume_keys "traffic_config.stream_id"
    lappend session_resume_keys "traffic_l47_config"
    lappend session_resume_keys "traffic_l47_config.traffic_l47_handle.applib_profile"
    lappend session_resume_keys "traffic_l47_config.traffic_l47_handle.applib_profile.applib_flow"
    lappend session_resume_keys "traffic_l47_config.traffic_l47_handle.applib_profile.applib_flow.parameter"
    lappend session_resume_keys "traffic_l47_config.traffic_l47_handle.applib_profile.applib_flow.connection"
    lappend session_resume_keys "traffic_l47_config.traffic_l47_handle.applib_profile.applib_flow.connection.parameter"

    foreach \
        {hlt_proc_name hlt_return_key ixn_object_shape_list key_rule_list} \
        $::ixia::session_info::build_key_list::proc_2_keys_map_1 \
    {
        # build key w/o __parent
        set key_parts [split $hlt_return_key "."]
        set ll [llength $key_parts]
        
        set sr_key_list [concat [list $hlt_proc_name] $key_parts]
        set ll [llength $sr_key_list]
        for {set i 0} {$i < $ll} {incr i} {
            set sr_key_list_current [lrange $sr_key_list 0 $i]
            set possible_key [join $sr_key_list_current "."]

            # may add here other special tokens like __parent
            if {[lsearch $sr_key_list_current "__parent"] != -1} {
                lappend session_resume_keys_wildcard [regsub {__parent} $possible_key "*"]
            } else {
                lappend session_resume_keys $possible_key
            }
        }
    }

    # check value
    foreach item $filter {
        if {[lsearch $session_resume_keys $item] == -1} {
            set item_part_list [split $item "."]
            set found_wildcard 0
            foreach wild $session_resume_keys_wildcard {
                set wild_part_list [split $wild "."]
                if {[llength $wild_part_list] != [llength $item_part_list]} {
                    continue
                }

                set invalid 0
                foreach wild_part $wild_part_list item_part $item_part_list {
                    if {$wild_part != "*" && $wild_part != $item_part} {
                        set invalid 1
                        break
                    }
                }
                if {$invalid} {
                    continue
                }
                # found a matching wildcard
                set found_wildcard 1
                break
            }
            if {!$found_wildcard} {
                error "invalid filter key $item"
            }
        }
    }
}

##Internal Procedure Header
#
# Description:
#   Returns 1 if key is to be included given the filter
#
#   Also used for mutable keys (eg. ones with __parent).
#   Filtering is done in 2 stages:
#       level 1: sr_initialize request list
#       level 2: build_key_list __parent filtering (mutable keys)
#   This is slow, use only when needed.
#
# Input: 
#   args
#
proc ::ixia::session_info::is_filter_included {filter key} {
    if {[llength $filter] == 0} {
        return 1
    }

    set found_key_ancestor 0
    set key_part_list [split $key "."]
    set ll [llength $key_part_list]
    for {set i 0} {$i < $ll} {incr i} {
        set key [join [lrange $key_part_list 0 end-$i] "."]
        if {[string first "__parent" $key] != -1} {
            set key [regsub -all {\.} $key {\\.}]
            set key [regsub -all {__parent} $key {[^\.$]+}]
            
            if {[lsearch -regexp $filter $key] != -1} {
                set found_key_ancestor 1
                break
            }
            continue
        }
        
        if {[lsearch $filter $key] != -1} {
            set found_key_ancestor 1
            break
        }
    }
    return $found_key_ancestor
}

##Internal Procedure Header
#
# Description:
#   Filters the given keymap
#
# Input: 
#   args
#   ref ::ixia::session_resume::session_resume_include_filter
# Output:
#   filtered keymap
#
proc ::ixia::session_info::apply_keymap_filter {keymap filter} {
    if {[llength $filter] == 0} {
        return $keymap
    }

    set new_keymap [list]

    foreach {hlt_proc_name hlt_return_key ixn_object_shape_list key_rule_list} $keymap {
        if {$key_rule_list == "__skip"} {
            continue
        }

        if {[is_filter_included $filter "${hlt_proc_name}.${hlt_return_key}"]} {
            lappend new_keymap $hlt_proc_name $hlt_return_key $ixn_object_shape_list $key_rule_list    
        }
    }

    return $new_keymap
}

##Internal Procedure Header
#
# Description:
#   Returns a filter with instanced items. The item typepaths are given by specialize_paths
#
# Input: 
#   args
#
proc ::ixia::session_info::specialize_filter {filter specialize_paths instance_list} {
    set ret [list]
    
    # get all filters that start with spath and replace with instances
    foreach {fitem fattr} $filter {
        set done_fitem 0

        foreach spath $specialize_paths {
            if {$spath == $fitem} {
                foreach instance $instance_list {
                    if {[string first "::ixNet::OBJ-" $instance] == 0} {
                        set instance [string range $instance 13 end]
                    }
                    set instance_tp [regsub -all {:[^/]+(/|$)} $instance "\\1"]
                    lappend ret [string replace $fitem 0 [expr [string length $instance_tp]-1] $instance] $fattr
                }
                set done_fitem 1
            }
        }

        if {!$done_fitem} {
            lappend ret $fitem $fattr
        }
    }
    return $ret
}

##Internal Procedure Header
#
# Description:
#   Returns a filter map that is the concatenation of fmap1 and fmap2. If they have common obj typepaths, the attribute
#   lists are concatenated
#
# Input: 
#   args
# Output:
#   concatenated filter map
#
proc ::ixia::session_info::concat_filter_map {fmap1 fmap2} {
    array set f1 $fmap1
    array set f2 $fmap2
    foreach name2 [array names f2] {
        if {![info exists f1($name2)]} {
            set f1($name2) $f2($name2)
        } else {
            set f1($name2) [concat $f1($name2) $f2($name2)]
        }
    }
    foreach name1 [array names f1] {
        set f1($name1) [lsort -unique $f1($name1)]
    }
    return [array get f1]
}

##Internal Procedure Header
#
# Description:
#   Returns a filter map for session_info keys requested
#
# Input: 
#   args
#   ref ::ixia::session_info::build_key_list::proc_2_keys_map_1
# Output:
#   [list keymap filter_map]
#
proc ::ixia::session_info::filter_build_key_list {filter} {
    set keymap [apply_keymap_filter $::ixia::session_info::build_key_list::proc_2_keys_map_1 $filter]

    array set filter_map [list]
    foreach {hlt_proc_name hlt_return_key ixn_object_shape_list key_rule_list} $keymap {
        set attr_list [list]
        switch -- [lindex $key_rule_list 0] {
            __obj_if -
            __obj_count {
                foreach {attr_name attr_val} [lrange $key_rule_list 1 end] {
                    lappend attr_list $attr_name
                }
            }
            __attr {
                set attr_list [lindex $key_rule_list 1]
            }
            __isis_rr {
                set attr_list "-type"
            }
            __vport {
                set attr_list "-connectedTo"
            }
            __obj_if_exists_any {
                foreach type_path [lindex $key_rule_list 1] {
                    set filter_map(/$type_path) [list]
                }
            }
            default {}
        }

        if {$ixn_object_shape_list == "placeholder"} {
            continue
        }
        foreach shape $ixn_object_shape_list {
            set type_path "/$shape"
            if {[info exists filter_map($type_path)]} {
                set filter_map($type_path) [concat $filter_map($type_path) $attr_list]
            } else {
                set filter_map($type_path) $attr_list
            }
        }
    }

    return [list $keymap [array get filter_map]]
}

##Internal Procedure Header
#
# Description:
#   Returns a keyed list with requested session_info keys related to protocols config
#
# Input: 
#   args
# Output:
#   keyed list with requested objects
#
proc ::ixia::session_info::build_key_list {keymap include_filter} {
    array set all_ixn_objects_array [list]
    set ixnet_null [ixNet getNull]
    
    ixia::util::import_namespace_procs "::ixia::session_resume" {
        sr_get_ixnhandle
        sr_get_node_by_ixnhandle
        sr_get_attribute
        sr_get_child_list
        sr_get_parent
        sr_is_valid_obj
        sr_get_objs_with_typepaths
        sr_is_key_filter_included
    }

    if {[info exists ::ixia::session_get_full_tree] && $::ixia::session_get_full_tree == 1} {
        # Get all ixnetwork objects using ixNet help command. Very slow.
        array set all_ixn_objects_array [::ixia::get_ixn_obj_list [ixNet getRoot]]
    } else {
        # Get only the ixnetwork objects from the keymap array.
        set obj_shapes [list]
        foreach {hlt_proc_name hlt_return_key ixn_object_shape_list key_rule_list} $keymap {
            set obj_shapes [concat $obj_shapes $ixn_object_shape_list]
        }
        sr_get_objs_with_typepaths $obj_shapes all_ixn_objects_array
        unset obj_shapes
    }

    # this is to avoid sorting each return dict entry each time an element is appended
    # all the sorting/unique will happen at the end (in nlogn as opposed to n^2logn)
    set uniquify_list [list]

    foreach {hlt_proc_name hlt_return_key ixn_object_shape_list key_rule_list} $keymap {
        set rule [lindex $key_rule_list 0]
        if {$rule == "__skip"} {
            continue
        }
        if {[info commands ::ixia::session_info::build_key_list::$rule] == ""} {
            error "Internal error in session_resume_build_key_list.\
                    Unexpected key_rule: '[lindex $key_rule_list 0]'"
        }

        # magic happens here, functions defined lower
        ixia::session_info::build_key_list::$rule                                \
            $hlt_proc_name $hlt_return_key $ixn_object_shape_list $key_rule_list \
            all_ixn_objects_array returnList uniquify_list include_filter        \
    }

    set uniquify_list [lsort -unique $uniquify_list]
    foreach key $uniquify_list {
        set ret_list [keylget returnList $key]
        if {$key != "vport_list"} {
            keylset returnList $key [lsort -unique $ret_list]
        } else {
            keylset returnList $key $ret_list
        }
    }

    # ensure
    unset all_ixn_objects_array

    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
#
# Description:
#   Called in each rule proc to setup the proc context
#
proc ::ixia::session_info::build_key_list::build_key_list_prolog {} {
    uplevel 1 {
        set ixnet_null [ixNet getNull]
    
        ixia::util::import_namespace_procs "::ixia::session_resume" {
            sr_get_ixnhandle
            sr_get_node_by_ixnhandle
            sr_get_attribute
            sr_get_child_list
            sr_get_parent
            sr_is_valid_obj
            sr_get_objs_with_typepaths
            sr_is_key_filter_included
        }

        upvar 1 $all_ixn_objects_array_ref all_ixn_objects_array
        upvar 1 $dict_ref rdict
        upvar 1 $include_filter_ref include_filter
        upvar 1 $uniquify_list_ref uniquify_list
    }
}

##Internal Procedure Header
#
# Description:
#   Populates dict_ref with session_info keys related to the specific rule the proc name states
#   Applies to all lower functions from ::ixia::session_info::build_key_list namespace
#
# Input: 
#   args
#
proc ::ixia::session_info::build_key_list::__obj {
    hlt_proc_name hlt_return_key ixn_object_shape_list key_rule_list 
    all_ixn_objects_array_ref dict_ref uniquify_list_ref include_filter_ref
} {
    build_key_list_prolog

    foreach ixn_object_shape $ixn_object_shape_list { 
        if {![info exists all_ixn_objects_array($ixn_object_shape)]} {
            # No objects with ixn_object_shape are configured
            continue
        }
        set key_val_ixn_objects $all_ixn_objects_array($ixn_object_shape)
    
        foreach key_val_ixn_obj $key_val_ixn_objects {
            set common_err_msg "Iteration: hlt_proc_name = $hlt_proc_name;\
                    hlt_return_key = $hlt_return_key; ixn_object_shape_list = $ixn_object_shape_list;\
                    ixn_object_shape = $ixn_object_shape; key_rule_list = $key_rule_list;\
                    key_val_ixn_obj = [sr_get_ixnhandle $key_val_ixn_obj]"
            
            set vport_obj [sr_get_parent $key_val_ixn_obj "vport"]
            if {![sr_is_valid_obj $vport_obj]} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get vport object from [sr_get_ixnhandle $key_val_ixn_obj] object.\
                        $common_err_msg"
            }
            
            set key_val_ixn_obj_parent [sr_get_parent $key_val_ixn_obj]
            if {![sr_is_valid_obj $key_val_ixn_obj_parent]} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get parent object from [sr_get_ixnhandle $key_val_ixn_obj] object.\
                        $common_err_msg"
            }

            # note: this may present performance issues -ae
            if {[string first "__parent" $hlt_return_key] != -1} {
                set hlt_return_key_tmp [regsub -all {__parent} $hlt_return_key [sr_get_ixnhandle $key_val_ixn_obj_parent]]
                # level 2 filtering
                if {![ixia::session_info::is_filter_included $include_filter "${hlt_proc_name}.$hlt_return_key_tmp"]} {
                    continue
                }
            } else {
                set hlt_return_key_tmp $hlt_return_key
            }
            
            set ret_code [ixia::ixNetworkGetPortFromObj [sr_get_ixnhandle $vport_obj]]
            if {[keylget ret_code status] != $::SUCCESS} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get port handle from [sr_get_ixnhandle $vport_obj] object.\
                        $common_err_msg. [keylget ret_code log]"
            }
            
            set port_handle [keylget ret_code port_handle]

            set already_existing_keyed_list ""
            if {![catch {keylget rdict ${port_handle}.${hlt_proc_name}} out]} {
                set already_existing_keyed_list $out
            }
            
            if {![catch {keylget already_existing_keyed_list $hlt_return_key_tmp} tmp_val]} {
                lappend tmp_val [sr_get_ixnhandle $key_val_ixn_obj]
            } else {
                set tmp_val [list [sr_get_ixnhandle $key_val_ixn_obj]]
            }

            keylset already_existing_keyed_list $hlt_return_key_tmp $tmp_val
            keylset rdict ${port_handle}.${hlt_proc_name} $already_existing_keyed_list
            lappend uniquify_list ${port_handle}.${hlt_proc_name}.${hlt_return_key_tmp}
        }
    }

    keylset ret status $::SUCCESS
    return $ret
}

proc ::ixia::session_info::build_key_list::__globals {
    hlt_proc_name hlt_return_key ixn_object_shape_list key_rule_list 
    all_ixn_objects_array_ref dict_ref uniquify_list_ref include_filter_ref
} {
    build_key_list_prolog

    foreach ixn_object_shape $ixn_object_shape_list {
        if {![info exists all_ixn_objects_array($ixn_object_shape)]} {
            # No objects with ixn_object_shape are configured
            continue
        }
        set key_val_ixn_objects $all_ixn_objects_array($ixn_object_shape)
        
        foreach key_val_ixn_obj $key_val_ixn_objects {
            
            set common_err_msg "Iteration: hlt_proc_name = $hlt_proc_name;\
                    hlt_return_key = $hlt_return_key; ixn_object_shape_list = $ixn_object_shape_list;\
                    ixn_object_shape = $ixn_object_shape; key_rule_list = $key_rule_list;\
                    key_val_ixn_obj = [sr_get_ixnhandle $key_val_ixn_obj]"
            
            set key_val_ixn_obj_parent [sr_get_parent $key_val_ixn_obj]
            if {![sr_is_valid_obj $key_val_ixn_obj_parent]} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get parent object from [sr_get_ixnhandle $key_val_ixn_obj] object.\
                        $common_err_msg"
            }
            
            # note: this may present performance issues -ae
            if {[string first "__parent" $hlt_return_key] != -1} {
                set hlt_return_key_tmp [regsub -all {__parent} $hlt_return_key [sr_get_ixnhandle $key_val_ixn_obj_parent]]
                # level 2 filtering
                if {![ixia::session_info::is_filter_included $include_filter "${hlt_proc_name}.$hlt_return_key_tmp"]} {
                    continue
                }
            } else {
                set hlt_return_key_tmp $hlt_return_key
            }
            
            set already_existing_keyed_list ""
            if {![catch {keylget rdict globals.${hlt_proc_name}} out]} {
                set already_existing_keyed_list $out
            }
            
            if {![catch {keylget already_existing_keyed_list $hlt_return_key_tmp} tmp_val]} {
                lappend tmp_val [sr_get_ixnhandle $key_val_ixn_obj]
            } else {
                set tmp_val [list [sr_get_ixnhandle $key_val_ixn_obj]]
            }
            
            keylset already_existing_keyed_list $hlt_return_key_tmp $tmp_val
            keylset rdict globals.${hlt_proc_name} $already_existing_keyed_list
            lappend uniquify_list globals.${hlt_proc_name}.${hlt_return_key_tmp}
        }
    }

    keylset ret status $::SUCCESS
    return $ret
}

proc ::ixia::session_info::build_key_list::__obj_count {
    hlt_proc_name hlt_return_key ixn_object_shape_list key_rule_list 
    all_ixn_objects_array_ref dict_ref uniquify_list_ref include_filter_ref
} {
    build_key_list_prolog

    foreach ixn_object_shape $ixn_object_shape_list {
        if {![info exists all_ixn_objects_array($ixn_object_shape)]} {
            # No objects with ixn_object_shape are configured
            continue
        }
        set key_val_ixn_objects $all_ixn_objects_array($ixn_object_shape)
        
        foreach key_val_ixn_obj $key_val_ixn_objects {
            
            set continue_flag 0
            foreach {attr_name attr_val} [lrange $key_rule_list 1 end] {
                # NOTE: attribute should always exist in SDM tree -ae
                set attr_val_read [sr_get_attribute $key_val_ixn_obj $attr_name]
                if {[string compare -nocase $attr_val $attr_val_read] != 0} {
                    set continue_flag 1
                    break
                }
            }
            
            if {$continue_flag} {
                continue
            }
            
            set common_err_msg "Iteration: hlt_proc_name = $hlt_proc_name;\
                    hlt_return_key = $hlt_return_key; ixn_object_shape_list = $ixn_object_shape_list;\
                    ixn_object_shape = $ixn_object_shape; key_rule_list = $key_rule_list;\
                    key_val_ixn_obj = [sr_get_ixnhandle $key_val_ixn_obj]"
            
            set vport_obj [sr_get_parent $key_val_ixn_obj "vport"]
            if {![sr_is_valid_obj $vport_obj]} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get vport object from [sr_get_ixnhandle $key_val_ixn_obj] object.\
                        $common_err_msg"
            }
            
            set key_val_ixn_obj_parent [sr_get_parent $key_val_ixn_obj]
            if {![sr_is_valid_obj $key_val_ixn_obj_parent]} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get vport object from [sr_get_ixnhandle $key_val_ixn_obj] object.\
                        $common_err_msg"
            }
            
            # note: this may present performance issues -ae
            if {[string first "__parent" $hlt_return_key] != -1} {
                set hlt_return_key_tmp [regsub -all {__parent} $hlt_return_key [sr_get_ixnhandle $key_val_ixn_obj_parent]]
                # level 2 filtering
                if {![ixia::session_info::is_filter_included $include_filter "${hlt_proc_name}.$hlt_return_key_tmp"]} {
                    continue
                }
            } else {
                set hlt_return_key_tmp $hlt_return_key
            }
            
            set ret_code [ixia::ixNetworkGetPortFromObj [sr_get_ixnhandle $vport_obj]]
            if {[keylget ret_code status] != $::SUCCESS} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get port handle from [sr_get_ixnhandle $vport_obj] object.\
                        $common_err_msg. [keylget ret_code log]"
            }
            
            set port_handle [keylget ret_code port_handle]
            
            set already_existing_keyed_list ""
            if {![catch {keylget rdict ${port_handle}.${hlt_proc_name}} out]} {
                set already_existing_keyed_list $out
            }
            
            if {![catch {keylget already_existing_keyed_list $hlt_return_key_tmp} tmp_val]} {
                incr tmp_val
            } else {
                set tmp_val 1
            }
            
            keylset already_existing_keyed_list $hlt_return_key_tmp $tmp_val
            keylset rdict ${port_handle}.${hlt_proc_name} $already_existing_keyed_list
        }
    }

    keylset ret status $::SUCCESS
    return $ret
}

proc ::ixia::session_info::build_key_list::__attr {
    hlt_proc_name hlt_return_key ixn_object_shape_list key_rule_list 
    all_ixn_objects_array_ref dict_ref uniquify_list_ref include_filter_ref
} {
    build_key_list_prolog

    foreach ixn_object_shape $ixn_object_shape_list { 
        if {![info exists all_ixn_objects_array($ixn_object_shape)]} {
            # No objects with ixn_object_shape are configured
            continue
        }
        set key_val_ixn_objects $all_ixn_objects_array($ixn_object_shape)
        
        foreach key_val_ixn_obj $key_val_ixn_objects {
            
            set common_err_msg "Iteration: hlt_proc_name = $hlt_proc_name;\
                    hlt_return_key = $hlt_return_key; ixn_object_shape_list = $ixn_object_shape_list;\
                    ixn_object_shape = $ixn_object_shape; key_rule_list = $key_rule_list;\
                    key_val_ixn_obj = [sr_get_ixnhandle $key_val_ixn_obj]"
            
            set attr_name [lindex $key_rule_list 1]
            if {[catch {sr_get_attribute $key_val_ixn_obj $attr_name} out]} {
                error "Error in session_resume_build_key_list.\
                        Could not 'sr_get_attribute [sr_get_ixnhandle $key_val_ixn_obj] $attr_name'. $out.\
                        $common_err_msg"
            }
            
            set attr_object $out
            # BUG733047
            # we keep no value type so guess that this param is an kObjRef
            if {$attr_name == "-interfaces"} {
                set attr_object "::ixNet::OBJ-$attr_object"
            }
            
            set vport_obj [sr_get_parent $key_val_ixn_obj "vport"]
            if {![sr_is_valid_obj $vport_obj]} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get vport object from [sr_get_ixnhandle $key_val_ixn_obj] object.\
                        $common_err_msg"
            }
            
            set key_val_ixn_obj_parent [sr_get_parent $key_val_ixn_obj]
            if {![sr_is_valid_obj $key_val_ixn_obj_parent]} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get vport object from [sr_get_ixnhandle $key_val_ixn_obj] object.\
                        $common_err_msg"
            }
            
            # note: this may present performance issues -ae
            if {[string first "__parent" $hlt_return_key] != -1} {
                set hlt_return_key_tmp [regsub -all {__parent} $hlt_return_key [sr_get_ixnhandle $key_val_ixn_obj_parent]]
                # level 2 filtering
                if {![ixia::session_info::is_filter_included $include_filter "${hlt_proc_name}.$hlt_return_key_tmp"]} {
                    continue
                }
            } else {
                set hlt_return_key_tmp $hlt_return_key
            }
            
            set ret_code [ixia::ixNetworkGetPortFromObj [sr_get_ixnhandle $vport_obj]]
            if {[keylget ret_code status] != $::SUCCESS} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get port handle from [sr_get_ixnhandle $vport_obj] object.\
                        $common_err_msg. [keylget ret_code log]"
            }
            
            set port_handle [keylget ret_code port_handle]
            
            set already_existing_keyed_list ""
            if {![catch {keylget rdict ${port_handle}.${hlt_proc_name}} out]} {
                set already_existing_keyed_list $out
            }
            
            if {![catch {keylget already_existing_keyed_list $hlt_return_key_tmp} tmp_val]} {
                lappend tmp_val $attr_object
            } else {
                set tmp_val $attr_object
            }
            
            keylset already_existing_keyed_list $hlt_return_key_tmp $tmp_val
            keylset rdict ${port_handle}.${hlt_proc_name} $already_existing_keyed_list
            lappend uniquify_list ${port_handle}.${hlt_proc_name}.${hlt_return_key_tmp}
        }
    }

    keylset ret status $::SUCCESS
    return $ret
}

proc ::ixia::session_info::build_key_list::__isis_rr {
    hlt_proc_name hlt_return_key ixn_object_shape_list key_rule_list 
    all_ixn_objects_array_ref dict_ref uniquify_list_ref include_filter_ref
} {
    build_key_list_prolog

    # ISIS Route range special case
                
    #{[vport/protocols/isis/router/routeRange -type] (map ipv4 4 ipv6 6)} vport/protocols/isis/router/routeRange
    # key value must be a pair with ipversion and ixnobj: {4 $ixnobj}
    
    foreach ixn_object_shape $ixn_object_shape_list {
        if {![info exists all_ixn_objects_array($ixn_object_shape)]} {
            # No objects with ixn_object_shape are configured
            continue
        }
        set key_val_ixn_objects $all_ixn_objects_array($ixn_object_shape)
        
        foreach key_val_ixn_obj $key_val_ixn_objects {
            set common_err_msg "Iteration: hlt_proc_name = $hlt_proc_name;\
                    hlt_return_key = $hlt_return_key; ixn_object_shape_list = $ixn_object_shape_list;\
                    ixn_object_shape = $ixn_object_shape; key_rule_list = $key_rule_list;\
                    key_val_ixn_obj = [sr_get_ixnhandle $key_val_ixn_obj]"
            
            set attr_name "-type"
            if {[catch {sr_get_attribute $key_val_ixn_obj $attr_name} out]} {
                error "Error in session_resume_build_key_list.\
                        Could not 'sr_get_attribute [sr_get_ixnhandle $key_val_ixn_obj] $attr_name'. $out.\
                        $common_err_msg"
            }
            
            if {$out == "ipv4"} {
                set attr_value 4
            } else {
                set attr_value 6
            }
            
            set vport_obj [sr_get_parent $key_val_ixn_obj "vport"]
            if {![sr_is_valid_obj $vport_obj]} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get vport object from [sr_get_ixnhandle $key_val_ixn_obj] object.\
                        $common_err_msg"
            }
            
            set ret_code [ixia::ixNetworkGetPortFromObj [sr_get_ixnhandle $vport_obj]]
            if {[keylget ret_code status] != $::SUCCESS} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get port handle from [sr_get_ixnhandle $vport_obj] object.\
                        $common_err_msg. [keylget ret_code log]"
            }
            
            set port_handle [keylget ret_code port_handle]
            
            set already_existing_keyed_list ""
            if {![catch {keylget rdict ${port_handle}.${hlt_proc_name}} out]} {
                set already_existing_keyed_list $out
            }
            
            if {![catch {keylget already_existing_keyed_list $hlt_return_key} tmp_val]} {
                # appending values to the return list for isis_rr
				if {[catch {keylget already_existing_keyed_list $hlt_return_key.$attr_value} tmp_val_rr]} {
					# BUG1353865 => remove the key parent key for v4/v6 inclusion
					keyldel already_existing_keyed_list $hlt_return_key
					keylset already_existing_keyed_list $hlt_return_key.$attr_value [sr_get_ixnhandle $key_val_ixn_obj]
				} else {
					set final_rr_value $tmp_val_rr
					lappend final_rr_value [sr_get_ixnhandle $key_val_ixn_obj]
					keylset already_existing_keyed_list $hlt_return_key.$attr_value $final_rr_value
				}
            } else {
                # creating the return list for isis_rr
				keylset already_existing_keyed_list $hlt_return_key.$attr_value [sr_get_ixnhandle $key_val_ixn_obj]
            }
			
            keylset rdict ${port_handle}.${hlt_proc_name} $already_existing_keyed_list
        }
    }

    keylset ret status $::SUCCESS
    return $ret
}

proc ::ixia::session_info::build_key_list::__vport {
    hlt_proc_name hlt_return_key ixn_object_shape_list key_rule_list 
    all_ixn_objects_array_ref dict_ref uniquify_list_ref include_filter_ref
} {
    build_key_list_prolog

    foreach ixn_object_shape $ixn_object_shape_list {  
        if {![info exists all_ixn_objects_array($ixn_object_shape)]} {
            # No objects with ixn_object_shape are configured
            continue
        }
        set key_val_ixn_objects $all_ixn_objects_array($ixn_object_shape)
        set key_val_ixn_objects [lsort -command ::ixia::compare_by_sr_get_ixnhandle $key_val_ixn_objects]
        foreach vport_obj $key_val_ixn_objects {
            set common_err_msg "Iteration: hlt_proc_name = $hlt_proc_name;\
                    hlt_return_key = $hlt_return_key; ixn_object_shape_list = $ixn_object_shape_list;\
                    ixn_object_shape = $ixn_object_shape; key_rule_list = $key_rule_list;\
                    key_val_ixn_obj = [sr_get_ixnhandle $vport_obj]"
            
            set ret_code [ixia::ixNetworkGetPortFromObj [sr_get_ixnhandle $vport_obj]]
            if {[keylget ret_code status] != $::SUCCESS} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get port handle from [sr_get_ixnhandle $vport_obj] object.\
                        $common_err_msg. [keylget ret_code log]"
            }
            
            set port_handle [keylget ret_code port_handle]
            
            if {![catch {keylget rdict vport_list} tmp_val]} {
                lappend tmp_val $port_handle
            } else {
                set tmp_val $port_handle
            }
            
            keylset rdict vport_list $tmp_val
            lappend uniquify_list vport_list
            
            set connected_hw [sr_get_attribute $vport_obj -connectedTo]
            if {[ \
                regexp {(/availableHardware/chassis:")(.+)("/card:)(\d+)(/port:)(\d+)$} \
                $connected_hw {} {} ch_ip {} ca {} po] \
            } { 
                keylset rdict port_handle.${ch_ip}.${ca}/${po} $port_handle
            }
        }
    }

    keylset ret status $::SUCCESS
    return $ret
}

proc ::ixia::session_info::build_key_list::__obj_if {
    hlt_proc_name hlt_return_key ixn_object_shape_list key_rule_list 
    all_ixn_objects_array_ref dict_ref uniquify_list_ref include_filter_ref
} {
    build_key_list_prolog

    foreach ixn_object_shape $ixn_object_shape_list {
        if {![info exists all_ixn_objects_array($ixn_object_shape)]} {
            # No objects with ixn_object_shape are configured
            continue
        }
        set key_val_ixn_objects $all_ixn_objects_array($ixn_object_shape)

        foreach key_val_ixn_obj $key_val_ixn_objects {
            set common_err_msg "Iteration: hlt_proc_name = $hlt_proc_name;\
                    hlt_return_key = $hlt_return_key; ixn_object_shape_list = $ixn_object_shape_list;\
                    ixn_object_shape = $ixn_object_shape; key_rule_list = $key_rule_list;\
                    key_val_ixn_obj = [sr_get_ixnhandle $key_val_ixn_obj]"
            
            set continue_flag 0
            foreach {attr_name attr_val} [lrange $key_rule_list 1 end] {
                # NOTE: attribute should always exist in SDM tree -ae
                set attr_val_read [sr_get_attribute $key_val_ixn_obj $attr_name]
                if {$attr_val != $attr_val_read} {
                    set continue_flag 1
                    break
                }
            }
            if {$continue_flag} {
                continue
            }

            set vport_obj [sr_get_parent $key_val_ixn_obj "vport"]
            if {![sr_is_valid_obj $vport_obj]} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get vport object from [sr_get_ixnhandle $key_val_ixn_obj] object.\
                        $common_err_msg"
            }
            
            set key_val_ixn_obj_parent [sr_get_parent $key_val_ixn_obj]
            if {![sr_is_valid_obj $key_val_ixn_obj_parent]} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get vport object from [sr_get_ixnhandle $key_val_ixn_obj] object.\
                        $common_err_msg"
            }
            
            # note: this may present performance issues -ae
            if {[string first "__parent" $hlt_return_key] != -1} {
                set hlt_return_key_tmp [regsub -all {__parent} $hlt_return_key [sr_get_ixnhandle $key_val_ixn_obj_parent]]
                # level 2 filtering
                if {![ixia::session_info::is_filter_included $include_filter "${hlt_proc_name}.$hlt_return_key_tmp"]} {
                    continue
                }
            } else {
                set hlt_return_key_tmp $hlt_return_key
            }
            
            set ret_code [ixia::ixNetworkGetPortFromObj [sr_get_ixnhandle $vport_obj]]
            if {[keylget ret_code status] != $::SUCCESS} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get port handle from [sr_get_ixnhandle $vport_obj] object.\
                        $common_err_msg. [keylget ret_code log]"
            }
            
            set port_handle [keylget ret_code port_handle]

            set already_existing_keyed_list ""
            if {![catch {keylget rdict ${port_handle}.${hlt_proc_name}} out]} {
                set already_existing_keyed_list $out
            }
            
            if {![catch {keylget already_existing_keyed_list $hlt_return_key_tmp} tmp_val]} {
                lappend tmp_val [sr_get_ixnhandle $key_val_ixn_obj]
            } else {
                set tmp_val [sr_get_ixnhandle $key_val_ixn_obj]
            }
            
            keylset already_existing_keyed_list $hlt_return_key_tmp $tmp_val
            keylset rdict ${port_handle}.${hlt_proc_name} $already_existing_keyed_list
            lappend uniquify_list ${port_handle}.${hlt_proc_name}.${hlt_return_key_tmp}
        }
    }

    keylset ret status $::SUCCESS
    return $ret
}

proc ::ixia::session_info::build_key_list::__obj_if_exists_any {
    hlt_proc_name hlt_return_key ixn_object_shape_list key_rule_list 
    all_ixn_objects_array_ref dict_ref uniquify_list_ref include_filter_ref
} {
    build_key_list_prolog

    foreach ixn_object_shape $ixn_object_shape_list {
        if {![info exists all_ixn_objects_array($ixn_object_shape)]} {
            # No objects with ixn_object_shape are configured
            continue
        }
        set key_val_ixn_objects $all_ixn_objects_array($ixn_object_shape)

        set obj_tp_part_list [split $ixn_object_shape "/"]
        set common_tp [lindex $key_rule_list 2]
        if {[string first $common_tp $ixn_object_shape]} {
            continue
        }

        foreach key_val_ixn_obj $key_val_ixn_objects {
            set common_err_msg "Iteration: hlt_proc_name = $hlt_proc_name;\
                    hlt_return_key = $hlt_return_key; ixn_object_shape_list = $ixn_object_shape_list;\
                    ixn_object_shape = $ixn_object_shape; key_rule_list = $key_rule_list;\
                    key_val_ixn_obj = [sr_get_ixnhandle $key_val_ixn_obj]"

            set continue_flag 1
            foreach check_tp [lindex $key_rule_list 1] {
                if {$continue_flag == 0} {
                    # got one valid object
                    break
                }
                
                if {[info exists all_ixn_objects_array($check_tp)]} {
                    foreach check_obj [sr_get_ixnhandle $all_ixn_objects_array($check_tp)] {
                        if {[string first $common_tp $check_tp] != 0} {
                            continue
                        }

                        set common_tp_len [llength [split $common_tp "/"]]

                        set check_obj [regsub {^::ixNet::OBJ-/} $check_obj {}]
                        set check_obj_part_list [split $check_obj "/"]

                        set obj [sr_get_ixnhandle $key_val_ixn_obj]
                        set obj [regsub {^::ixNet::OBJ-/} $obj {}]
                        set obj_part_list [split $obj "/"]

                        for {set i 0} {$i < $common_tp_len} {incr i} {
                            if {[lindex $check_obj_part_list $i] != [lindex $obj_part_list $i]} {
                                break
                            }
                        }
                        if {$i == $common_tp_len} {
                            set continue_flag 0
                        }
                    }
                }
            }
            if {$continue_flag} {
                continue
            }

            set vport_obj [sr_get_parent $key_val_ixn_obj "vport"]
            if {![sr_is_valid_obj $vport_obj]} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get vport object from [sr_get_ixnhandle $key_val_ixn_obj] object.\
                        $common_err_msg"
            }
            
            set key_val_ixn_obj_parent [sr_get_parent $key_val_ixn_obj]
            if {![sr_is_valid_obj $key_val_ixn_obj_parent]} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get vport object from [sr_get_ixnhandle $key_val_ixn_obj] object.\
                        $common_err_msg"
            }
            
            # note: this may present performance issues -ae
            if {[string first "__parent" $hlt_return_key] != -1} {
                set hlt_return_key_tmp [regsub -all {__parent} $hlt_return_key [sr_get_ixnhandle $key_val_ixn_obj_parent]]
                # level 2 filtering
                if {![ixia::session_info::is_filter_included $include_filter "${hlt_proc_name}.$hlt_return_key_tmp"]} {
                    continue
                }
            } else {
                set hlt_return_key_tmp $hlt_return_key
            }
            
            set ret_code [ixia::ixNetworkGetPortFromObj [sr_get_ixnhandle $vport_obj]]
            if {[keylget ret_code status] != $::SUCCESS} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get port handle from [sr_get_ixnhandle $vport_obj] object.\
                        $common_err_msg. [keylget ret_code log]"
            }
            
            set port_handle [keylget ret_code port_handle]

            set already_existing_keyed_list ""
            if {![catch {keylget rdict ${port_handle}.${hlt_proc_name}} out]} {
                set already_existing_keyed_list $out
            }
            
            if {![catch {keylget already_existing_keyed_list $hlt_return_key_tmp} tmp_val]} {
                lappend tmp_val [sr_get_ixnhandle $key_val_ixn_obj]
            } else {
                set tmp_val [sr_get_ixnhandle $key_val_ixn_obj]
            }
            
            keylset already_existing_keyed_list $hlt_return_key_tmp $tmp_val
            keylset rdict ${port_handle}.${hlt_proc_name} $already_existing_keyed_list
            lappend uniquify_list ${port_handle}.${hlt_proc_name}.${hlt_return_key_tmp}
        }
    }

    keylset ret status $::SUCCESS
    return $ret
}

proc ::ixia::session_info::build_key_list::__obj_parent {
    hlt_proc_name hlt_return_key ixn_object_shape_list key_rule_list 
    all_ixn_objects_array_ref dict_ref uniquify_list_ref include_filter_ref
} {
    build_key_list_prolog

    # If __obj_parent does not have any attributes, the key will be the direct parent of the object
    # If __obj_parent has attributes, the key will be the parent having name $attr
    
    foreach ixn_object_shape $ixn_object_shape_list {
        if {![info exists all_ixn_objects_array($ixn_object_shape)]} {
            # No objects with ixn_object_shape are configured
            continue
        }
        set key_val_ixn_objects $all_ixn_objects_array($ixn_object_shape)
        
        foreach key_val_ixn_obj $key_val_ixn_objects {
            set common_err_msg "Iteration: hlt_proc_name = $hlt_proc_name;\
                    hlt_return_key = $hlt_return_key; ixn_object_shape_list = $ixn_object_shape_list;\
                    ixn_object_shape = $ixn_object_shape; key_rule_list = $key_rule_list;\
                    key_val_ixn_obj = [sr_get_ixnhandle $key_val_ixn_obj]"
            
            set vport_obj [sr_get_parent $key_val_ixn_obj "vport"]
            if {![sr_is_valid_obj $vport_obj]} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get vport object from [sr_get_ixnhandle $key_val_ixn_obj] object.\
                        $common_err_msg"
            }
            
            set key_val_ixn_obj_parent [sr_get_parent $key_val_ixn_obj]
            if {![sr_is_valid_obj $key_val_ixn_obj_parent]} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get vport object from [sr_get_ixnhandle $key_val_ixn_obj] object.\
                        $common_err_msg"
            }
            
            # note: this may present performance issues -ae
            if {[string first "__parent" $hlt_return_key] != -1} {
                set hlt_return_key_tmp [regsub -all {__parent} $hlt_return_key [sr_get_ixnhandle $key_val_ixn_obj_parent]]
                # level 2 filtering
                if {![ixia::session_info::is_filter_included $include_filter "${hlt_proc_name}.$hlt_return_key_tmp"]} {
                    continue
                }
            } else {
                set hlt_return_key_tmp $hlt_return_key
            }
            
            if {[llength $key_rule_list] == 1} {
                set attr_object $key_val_ixn_obj_parent
            } else {
                set parent_name [lindex $key_rule_list 1]
                set attr_object [sr_get_parent $key_val_ixn_obj $parent_name]
                if {![sr_is_valid_obj $attr_object]} {
                    error "Internal error in session_resume_build_key_list.\
                            Could not get parent '$parent_name' of object [sr_get_ixnhandle $key_val_ixn_obj] object.\
                            $common_err_msg"
                }
            }
            
            set ret_code [ixia::ixNetworkGetPortFromObj [sr_get_ixnhandle $vport_obj]]
            if {[keylget ret_code status] != $::SUCCESS} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get port handle from [sr_get_ixnhandle $vport_obj] object.\
                        $common_err_msg. [keylget ret_code log]"
            }
            
            set port_handle [keylget ret_code port_handle]
            
            set already_existing_keyed_list ""
            if {![catch {keylget rdict ${port_handle}.${hlt_proc_name}} out]} {
                set already_existing_keyed_list $out
            }
            
            if {![catch {keylget already_existing_keyed_list $hlt_return_key_tmp} tmp_val]} {
                lappend tmp_val [sr_get_ixnhandle $attr_object]
            } else {
                set tmp_val [sr_get_ixnhandle $attr_object]
            }
            
            keylset already_existing_keyed_list $hlt_return_key_tmp $tmp_val
            keylset rdict ${port_handle}.${hlt_proc_name} $already_existing_keyed_list
            lappend uniquify_list ${port_handle}.${hlt_proc_name}.${hlt_return_key_tmp}
        }
    }

    keylset ret status $::SUCCESS
    return $ret
}

proc ::ixia::session_info::build_key_list::__multicast_config {
    hlt_proc_name hlt_return_key ixn_object_shape_list key_rule_list 
    all_ixn_objects_array_ref dict_ref uniquify_list_ref include_filter_ref
} {
    build_key_list_prolog

    set array_name [lindex $key_rule_list 1]
    variable ::ixia::$array_name

    set mcast_handle_list [list]
    foreach {k v} [array get ::ixia::$array_name] {
        set ksplit [split $k ","]
        set mcast_handle [lindex $ksplit 0]
        set mcast_key    [lindex $ksplit 1]

        lappend mcast_handle_list $mcast_handle
        keylset rdict ${hlt_proc_name}.${mcast_handle}.$mcast_key $v
    }
    if {[llength $mcast_handle_list] > 0} {
        keylset rdict ${hlt_proc_name}.handle [lsort -unique $mcast_handle_list]
    }

    keylset ret status $::SUCCESS
    return $ret
}

proc ::ixia::session_info::build_key_list::__ancp_dsl_profile {
    hlt_proc_name hlt_return_key ixn_object_shape_list key_rule_list 
    all_ixn_objects_array_ref dict_ref uniquify_list_ref include_filter_ref
} {
    build_key_list_prolog

    set ports_with_ancp_sl [list]
    foreach idx [array names ::ixia::handles_state_evidence_array] {
        foreach {dsl_profile ancp_range _} [split $idx ,] {
            
            set vport_obj [ixia::ixNetworkGetParentObjref $ancp_range "vport"]
            if {$vport_obj == $ixnet_null} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get vport object from $ancp_range object while building ancp\
                        subscriber lines config keys"
            }
            
            set ret_code [ixia::ixNetworkGetPortFromObj $vport_obj]
            if {[keylget ret_code status] != $::SUCCESS} {
                error "Internal error in session_resume_build_key_list.\
                        Could not get port handle from $vport_obj object while building ancp\
                        subscriber lines config keys. [keylget ret_code log]"
            }
            set port_handle [keylget ret_code port_handle]
            
            lappend ${port_handle}_list $dsl_profile
            lappend ports_with_ancp_sl $port_handle
        }
    }
    
    foreach port_handle [lsort -unique $ports_with_ancp_sl] {
        keylset inner_keylist handle [set ${port_handle}_list]
        keylset rdict ${port_handle}.emulation_ancp_subscriber_lines_config $inner_keylist
    }

    keylset ret status $::SUCCESS
    return $ret
}

##Internal Procedure Header
#
# Description:
#   Returns a keyed list with requested session_info keys related to traffic
#
# Input: 
#   args
# Output:
#   keyed list with requested objects
#
proc ::ixia::session_info::build_traffic_key_list { args } {

    ixia::util::import_namespace_procs "::ixia::util" {
        make_error
        upvar_variable_list
        parse_dashed_args_no_verifs
    }

    set upvar_list {
        arg_session_keys_include_filter
    }
    upvar_variable_list $upvar_list

    set dashed_args {
        -dict_ref
    }
    parse_dashed_args_no_verifs $args $dashed_args

    # this may be called inline from get_session_keys, add to an existing dict
    if {[info exists argi_dict_ref]} {
        upvar_variable_list [list $argi_dict_ref]
        set returnList [set $argi_dict_ref]
    } else {
        set returnList [list]
    }

    set include_filter [list]
    if {[info exists arg_session_keys_include_filter]} {
        set include_filter $arg_session_keys_include_filter
    }

    set traffic_config_enable    [expr [llength $include_filter] == 0 || [lsearch $include_filter "traffic_config"] != -1]
    set traffic_item_enable      [expr [lsearch $include_filter "traffic_config.traffic_item"] != -1]
    set traffic_stream_id_enable [expr [lsearch $include_filter "traffic_config.stream_id"] != -1]
    set app_lib_filter_handles   [expr [lsearch $include_filter "traffic_l47_config"] != -1 ||  \
                                       [lsearch $include_filter "traffic_l47_config.traffic_l47_handle.applib_profile"] != -1 ||    \
                                       [lsearch $include_filter "traffic_l47_config.traffic_l47_handle.applib_profile.applib_flow"] != -1 ||    \
                                       [lsearch $include_filter "traffic_l47_config.traffic_l47_handle.applib_profile.applib_flow.parameter"] != -1 ||  \
                                       [lsearch $include_filter "traffic_l47_config.traffic_l47_handle.applib_profile.applib_flow.connection"] != -1 || \
                                       [lsearch $include_filter "traffic_l47_config.traffic_l47_handle.applib_profile.applib_flow.connection.parameter"] != -1]

    # legacy keys means traffic_config.traffic_item, traffic_config.stream_id
    set only_legacy_keys 0
    if {!$traffic_config_enable && ($traffic_item_enable || $traffic_stream_id_enable)} {
        set only_legacy_keys 1
    }

    if {$traffic_config_enable || $traffic_item_enable || $traffic_stream_id_enable} {
        # add ti info
        mode_get_traffic_items -dict_ref returnList

        if {!$only_legacy_keys} {
            # eat all the cake!
            mode_get_traffic_ce -dict_ref returnList -do_serialize 0 -skip_single_optimization 1
            mode_get_traffic_hls -dict_ref returnList -do_serialize 0 -skip_single_optimization 1
            mode_get_traffic_headers -dict_ref returnList -do_serialize 0 -skip_single_optimization 1
            mode_get_traffic_application_profiles -dict_ref returnList -do_serialize 0 -skip_single_optimization 1
            mode_get_traffic_applib_profiles -dict_ref returnList -do_serialize 0 -skip_single_optimization 1
        } else {
            array set ti_name_ti_legacy [list]

            # get the minimum of keys to support the legacy items
            set rval [mode_get_traffic_ce -do_serialize 0 -skip_single_optimization 1]
            mode_get_traffic_application_profiles -dict_ref rval -do_serialize 0 -skip_single_optimization 1

            # legacy stuff, traffic_config.traffic_item needs to return just the $ti_name.traffic_config.traffic_item keys
            if {$traffic_item_enable && $only_legacy_keys} {
                foreach ti_name [keylget returnList traffic_config] {
                    set ce_list [keylget rval ${ti_name}.traffic_config.traffic_item]
                    keylset returnList ${ti_name}.traffic_config.traffic_item $ce_list
                }
                foreach ti_name [keylget returnList traffic_config_L47] {
                    set app_profile [keylget rval ${ti_name}.traffic_config]
                    keylset returnList ${ti_name}.traffic_config $app_profile
                }
            }
            # legacy stuff, traffic_config.traffic_item needs to return just the $ti_name.traffic_config.stream_id keys
            if {$traffic_stream_id_enable && $only_legacy_keys} {
                foreach ti_name [keylget returnList traffic_config] {
                    keylset returnList ${ti_name}.traffic_config.stream_id $ti_name
                }
            }
        }
    } elseif {$app_lib_filter_handles} {
        mode_get_traffic_applib_profiles -dict_ref returnList -do_serialize 0 -skip_single_optimization 1
    }

    # this may be called inline from get_session_keys, update the existing dict
    if {[info exists argi_dict_ref]} {
        set $argi_dict_ref $returnList
    }

    keylset returnList status $::SUCCESS
    return $returnList
}
