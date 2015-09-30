##Library Header
# $Id: $
# Copyright © 2003-2009 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_twamp_api.tcl
#
# Purpose:
#    A script development library containing TWAMP APIs for test automation with 
#    the Ixia chassis.
#
# Author:
#    Ixia engineering, direct all communication to support@ixiacom.com
#
# Usage:
#
# Description:
#    The procedures contained within this library include:
#
#    -emulation_twamp_config
#    -emulation_twamp_control_range_config 
#    -emulation_twamp_test_range_config
#    -emulation_twamp_server_range_config
#    -emulation_twamp_control
#    -emulation_twamp_info
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


proc ::ixia::emulation_twamp_config { args } {
    variable executeOnTclServer
    
    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
	
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::emulation_twamp_config $args\}]
        
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
    }
    
    set opt_args {
        -error_estimate_multiplier  NUMERIC
                                    DEFAULT 9
        -error_estimate_scale       NUMERIC
                                    DEFAULT 8
        -global_max_outstanding     NUMERIC
                                    DEFAULT 20
        -global_setup_rate          NUMERIC
                                    DEFAULT 5
        -global_teardown_rate       NUMERIC
                                    DEFAULT 5
        -handle                     ANY
        -mode                       CHOICES create modify remove
                                    DEFAULT create
        -port_handle                REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -port_max_outstanding       NUMERIC
                                    DEFAULT 20
        -port_override_globals      CHOICES 0 1
                                    DEFAULT 0
        -port_setup_rate            NUMERIC
                                    DEFAULT 5
        -port_teardown_rate         NUMERIC
                                    DEFAULT 5
        -session_timeout            NUMERIC
                                    DEFAULT 240
    }

    if [catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            } errorMsg] {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg."
        return $returnList
    }

    array set truth {1 true 0 false enable true disable false}
    
    if {[catch {package present IxTclNetwork} versionIxNetwork] || \
            ($versionIxNetwork < 5.30)} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: IxNetwork version not supported. \
            Please upgrade."
        return $returnList
    }        

    set global_params {
        global_max_outstanding     maxOutstanding              value    _none
        global_setup_rate          setupRate                   value    _none
        global_teardown_rate       teardownRate                value    _none    
    }
    
	set options_params {
        error_estimate_multiplier  errorEstimateMultiplier     value    _none
        error_estimate_scale       errorEstimateScale          value    _none
        port_max_outstanding       maxOutstanding              value    _none
        port_override_globals      overrideGlobalRateOptions   truth    _none
        port_setup_rate            setupRate                   value    _none
        port_teardown_rate         teardownRate                value    _none
        session_timeout            sessionTimeout              value    _none
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

            set retCode [ixNetworkGetPortObjref $port_handle]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Unable to find the port object reference \
                        associated to the $port_handle port handle -\
                        [keylget retCode log]."
                return $returnList
            }

            set vport_objref    [keylget retCode vport_objref]

            # TWAMP globals tree may not exist at this point. Create it.
            if {[llength [ixNet getL ::ixNet::OBJ-/globals/protocolStack twampGlobals]] == 0} {
                set globals_obj [ixNet add ::ixNet::OBJ-/globals/protocolStack twampGlobals]
                if {[ixNet commit] != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Calling IxNet commit.\
                            The twamp global options object could not be initiated."
                    return $returnList
                }
                set globals_obj [ixNet remapIds $globals_obj]
            } else {
                set globals_obj [ixNet getL ::ixNet::OBJ-/globals/protocolStack twampGlobals]
            }
            
            # Configure twamp global params
            set ixn_global_args ""
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
                    append ixn_global_args "-$ixn_param $ixn_param_value "
                }
            }
            
            if {$ixn_global_args != ""} {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                        "$globals_obj"                                          \
                        $ixn_global_args                                        \
                        -commit                                                 \
                    ]
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
            }

            # TWAMP options tree may not exist at this point. Create it.
            if {[llength [ixNet getL ${vport_objref}/protocolStack twampOptions]] == 0} {
                set options_obj [ixNet add ${vport_objref}/protocolStack twampOptions]
                if {[ixNet commit] != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Calling IxNet commit.\
                            Could not create twampOptions object over protocolStack."
                    return $returnList
                }
                set options_obj [ixNet remapIds $options_obj]
            } else {
                set options_obj [ixNet getL ${vport_objref}/protocolStack twampOptions]            
            }
            
            # Configure twamp options params
            set ixn_options_args ""
            foreach {hlt_param ixn_param p_type extensions} $options_params {
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
                    append ixn_options_args "-$ixn_param $ixn_param_value "
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
        "modify" {
            # Remove defaults
            removeDefaultOptionVars $opt_args $args
            
            foreach vport_handle $handle {
                set validate_message [::ixia::validateHandleObjectRef $vport_handle {^::ixNet::OBJ-/vport:\d+$}]
                if {$validate_message != "ok"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : $validate_message"
                    return $returnList
                }
                
                set vport_objref $vport_handle
                # Configure twamp global params
                set ixn_global_args ""
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
                        append ixn_global_args "-$ixn_param $ixn_param_value "
                    }
                }
                
                set twamp_globals [ixNet getL ::ixNet::OBJ-/globals/protocolStack twampGlobals]
                if {$ixn_global_args != ""} {
                    set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                            "$twamp_globals"    \
                            $ixn_global_args                                        \
                            -commit                                                 \
                        ]
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                }
                
                # Configure twamp options params            
                set ixn_options_args ""
                set options_obj [ixNet getL ${vport_objref}/protocolStack twampOptions]            
                foreach {hlt_param ixn_param p_type extensions} $options_params {
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
                        append ixn_options_args "-$ixn_param $ixn_param_value "
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
            } ;# foreach vport_handle
            
            keylset returnList  handle  "${vport_objref}"
            keylset returnList  status  $::SUCCESS
            return $returnList
        }
        "remove" {
            foreach vport_handle $handle {
                set validate_message [::ixia::validateHandleObjectRef $vport_handle {^::ixNet::OBJ-/vport:\d+$}]
                if {$validate_message != "ok"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : $validate_message"
                    return $returnList
                }
                
                set vport_objref $vport_handle
                set globalsList [ixNet getL ::ixNet::OBJ-/globals/protocolStack twampGlobals]
                set optionsList [ixNet getL "${vport_objref}/protocolStack" twampOptions]
                
                if {[catch {ixNet remove $globalsList} err]} {
                    # Do nothing.
                    # The global list is only one and may have been removed by a
                    # previous call with another handle.
                }
                if {[catch {ixNet remove $optionsList} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : \
                            failed to remove -handle $optionsList.\n$err"
                    return $returnList
                }
            }
            if {[catch {ixNet commit} err]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : \
                        failed to commit while removing TWAMP config.\n$err"
                return $returnList
            }
        }
    }
    
    keylset returnList status $::SUCCESS       
    return $returnList
}

proc ::ixia::emulation_twamp_control_range_config { args } {
    variable executeOnTclServer
    variable objectMaxCount

    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args

    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::emulation_twamp_control_range_config $args\}]
        
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
        -handle                        ANY   
    }
    
    set opt_args {
        -control_mode                  CHOICES unauthenticated authenticated encrypted
                                       DEFAULT unauthenticated
        -count                         NUMERIC
                                       DEFAULT 1
        -key_id                        ANY
        -mode                          CHOICES create modify enable disable remove
                                       DEFAULT create
        -server_ip                     IP
                                       DEFAULT 10.10.0.2
        -server_ip_intra_range_step    IP
                                       DEFAULT 0.0.0.1
        -server_port                   NUMERIC
                                       DEFAULT 862
        -shared_secret                 ANY
    }

    if [catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} errorMsg] {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg."
        return $returnList
    }

    if {[catch {package present IxTclNetwork} versionIxNetwork] || \
            ($versionIxNetwork < 5.30)} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: IxNetwork version not supported.\
            Please upgrade."
        return $returnList
    }       
    
    array set truth {1 true 0 false enable true disable false}
    
    set control_range_params {
        control_mode                  mode                     translate  _none
        count                         count                    value      _none
        key_id                        keyId                    value      _none        
        server_ip                     controlStartServerIp     value      _none
        server_ip_intra_range_step    controlServerIpIncrement value      _none
        server_port                   controlServerPort        value      _none
        shared_secret                 secret                   value      _none
    }
    
    array set options_map {
        unauthenticated  unauthenticated  \
        authenticated    authenticated    \
        encrypted        encrypted        \
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

    set objectsToCommit 0

    if {$mode == "enable" || $mode == "disable"} {
        set twamp_ref_list [list]
        foreach twamp_ref $handle {
            set validate_message [::ixia::validateHandleObjectRef $twamp_ref {^::ixNet::OBJ-/vport:\d+/protocolStack/[^/]+/ipEndpoint:[-"0-9a-z]+/range:[-"0-9a-z]+/twampControlRange:[-"0-9a-z]+$}]
            if {$validate_message != "ok"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : $validate_message"
                return $returnList
            }
    
            set twamp_control_range_object_ref    $twamp_ref
    
            set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                    "$twamp_control_range_object_ref"                       \
                    "-enabled $truth($mode)"                                \
                    -commit                                                 \
                ]                                 
    
            if {[keylget tmp_status status] != $::SUCCESS} {
                keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                return $tmp_status
            } else {
                lappend twamp_ref_list $twamp_control_range_object_ref
            }
        }
        keylset returnList  handle  $twamp_ref_list
        keylset returnList  status  $::SUCCESS
        return $returnList 
    }
    
    switch -- $mode {
        "create" {
            set enabled 1
            
            set validate_message [::ixia::validateHandleObjectRef $handle {^::ixNet::OBJ-/vport:\d+/protocolStack/[^/]+/ipEndpoint:[-"0-9a-z]+/range:[-"0-9a-z]+$}]
            if {$validate_message != "ok"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : $validate_message"
                return $returnList
            }

            set range_object_ref $handle
            set ipendpoint_objref [::ixia::ixNetworkGetParentObjref $range_object_ref]
            set twamp_control_range_list [list]
            
            # Configure twamp control range params --------------------------------------
            set temporary_object [ixNet add $range_object_ref twampControlRange]
            if {[ixNet commit] != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Unable to commit after attempt to create twampControlRange object."
                return $returnList
            } else {
                set twamp_control_range_object_ref [ixNet remapIds $temporary_object]
            }

            lappend twamp_control_range_list $twamp_control_range_object_ref
            
            set ixn_twamp_range_args ""
            foreach {hlt_param ixn_param p_type extensions} $control_range_params {
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
                            set ixn_param_value $options_map($hlt_param_value)
                        }
                    }
                    append ixn_twamp_range_args "-$ixn_param $ixn_param_value "
                }
            }
            if {$ixn_twamp_range_args != ""} {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                        "$twamp_control_range_object_ref"                       \
                        $ixn_twamp_range_args                                   \
                        -no_commit                                              \
                    ]                                 
        
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
                if {$objectsToCommit >= $::ixia::objectMaxCount} {
                    ixNet commit
                    set objectsToCommit 0
                } else {
                    incr objectsToCommit
                }
            }   
            
            if {$objectsToCommit > 0} {
                ixNet commit
                set objectsToCommit 0
            }
        
            # Create twampClient object...
            set client_object_ref [ixNet getL $ipendpoint_objref twampClient]
            if {[llength $client_object_ref] == 0} {
                set temporary_object [ixNet add $ipendpoint_objref twampClient]
                if {[ixNet commit] != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Unable to commit after attempt to create twampClient object."
                    return $returnList
                } else {
                    set client_object_ref [ixNet remapIds $temporary_object]
                }
            }
            
            keylset returnList  handle  "${twamp_control_range_list}"
            keylset returnList  status  $::SUCCESS
            return $returnList
        }
        "modify" {
            # Remove defaults
            removeDefaultOptionVars $opt_args $args
            set twamp_list [list]
            foreach twamp_ref $handle {
                set validate_message [::ixia::validateHandleObjectRef $twamp_ref {^::ixNet::OBJ-/vport:\d+/protocolStack/[^/]+/ipEndpoint:[-"0-9a-z]+/range:[-"0-9a-z]+/twampControlRange:[-"0-9a-z]+$}]
                if {$validate_message != "ok"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : $validate_message"
                    return $returnList
                }
    
                # Assuming handle type is twampControlRange... 
                set twamp_control_range_object_ref    $twamp_ref  
    
                set ixn_twamp_range_args ""
                foreach {hlt_param ixn_param p_type extensions} $control_range_params {
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
                                set ixn_param_value $options_map($hlt_param_value)
                            }
                        }
                        append ixn_twamp_range_args "-$ixn_param $ixn_param_value "
                    }
                }
                if {$ixn_twamp_range_args != ""} {
                    set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                            "$twamp_control_range_object_ref"                       \
                            $ixn_twamp_range_args                                   \
                            -no_commit                                              \
                        ]                                 
            
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                    if {$objectsToCommit >= $::ixia::objectMaxCount} {
                        ixNet commit
                        set objectsToCommit 0
                    } else {
                        incr objectsToCommit
                    }
                }
                lappend twamp_list $twamp_control_range_object_ref
            } ;# foreach twamp_ref
            
            if {$objectsToCommit > 0} {
                ixNet commit
                set objectsToCommit 0
            }
            
            keylset returnList  handle  "${twamp_list}"
            keylset returnList  status  $::SUCCESS
            return $returnList
        }
        "remove" {
            foreach twamp_ref $handle {
                set validate_message [::ixia::validateHandleObjectRef $twamp_ref {^::ixNet::OBJ-/vport:\d+/protocolStack/[^/]+/ipEndpoint:[-"0-9a-z]+/range:[-"0-9a-z]+/twampControlRange:[-"0-9a-z]+$}]
                if {$validate_message != "ok"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : $validate_message"
                    return $returnList
                }
     
                set twamp_control_range_object_ref    $twamp_ref
                set associated_ipendpoint [::ixia::ixNetworkGetParentObjref $twamp_control_range_object_ref ipEndpoint]
                set twampclient [ixNet getL $associated_ipendpoint twampClient]
                if {[llength $twampclient] > 0} {
                    set remove_result [ixNet remove $twampclient]
                    if {$remove_result != "::ixNet::OK"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Unable to remove object handle $twampclient."
                        return $returnList
                    }
                    if {$objectsToCommit >= $::ixia::objectMaxCount} {
                        ixNet commit
                        set objectsToCommit 0
                    } else {
                        incr objectsToCommit
                    }
                }
            }

            if {$objectsToCommit > 0} {
                if {[catch {ixNet commit} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : \
                            failed to commit while removing TWAMP client object.\n$err"
                    return $returnList
                }
                set objectsToCommit 0
            }
            
            keylset returnList  handle  [string range $twamp_control_range_object_ref 0 [expr [string first "/range" $twamp_control_range_object_ref] - 1]]
            keylset returnList  status  $::SUCCESS
            return $returnList            
        }

    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}

##Procedure Header
# Name:
#    ::ixia::emulation_twamp_test_range_config
#
# Description:
#    Create a new TWAMP test range on the IP endpoint range specified with -handle 
#    and create an association with the corresponding TWAMP control range using 
#    the -control_range_handle parameter.
#
# Synopsis:
#    ::ixia::emulation_twamp_test_range_config
#        [-control_range_handle         ANY]
#        [-handle                       ANY]
#        [-mode                         CHOICES create modify enable disable remove DEFAULT create]
#        [-num_pkts                     NUMERIC DEFAULT 1000]
#        [-padding_with_zero            CHOICES 0 1 DEFAULT 0]
#        [-pkt_length                   NUMERIC DEFAULT 64]
#        [-pps                          NUMERIC DEFAULT 10]
#        [-session_reflector_port       NUMERIC DEFAULT 12001]
#        [-session_reflector_port_step  NUMERIC DEFAULT 0]
#        [-session_sender_port          NUMERIC DEFAULT 11001]
#        [-session_sender_port_step     NUMERIC DEFAULT 1]
#        [-test_sessions_count          NUMERIC DEFAULT 1]
#        [-timeout                      NUMERIC DEFAULT 1]
#        [-type_p_descriptor            NUMERIC DEFAULT 1]
#
# Arguments:
#    -control_range_handle
#        For -mode create or modify, parameter -control_range_handle handle 
#        specifies the TWAMP control 
#        range to which the TWAMP test range is related. 
#    -handle
#        For -mode create, parameter -handle specifies the IP endpoint range 
#        (previously configured with interface_config) where the TWAMP 
#        test range is to be configured. For -mode modify/enable/disable/remove, 
#        this is the TWAMP test range handle to be modified/enabled/disabled/removed.
#    -mode
#        Action to perform.
#    -num_pkts
#        Number of packets to be sent by the Session-Sender
#    -padding_with_zero
#        Per RFC465, data in the packets is random, unless it is configured to be zero.
#    -pkt_length
#        Packet length including padding length as defined by the RFC4656.
#    -pps
#        Rate at which packets will be sent 
#    -session_reflector_port
#        Port on which the reflector receives the packets from the stream initiated by Session-Sender
#    -session_reflector_port_step
#        The port step used by the reflector port within this range.
#    -session_sender_port
#        Source Port of the stream initiated by Session-Sender
#    -session_sender_port_step
#        The port step used by the session sender port.
#    -test_sessions_count
#        Number of test sessions.
#    -timeout
#        Timeout for receiving packets on Session-Reflector after Stop-Sessions is received.
#    -type_p_descriptor
#        Set to 0 for phase1
#
# Return Values:
#    A keyed list 
#    key:status      value:$::SUCCESS | $::FAILURE 
#    key:log         value:When status is failure, contains more info 
#    key:handle      value:Handle of the twamp test range that was configured or modified
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
proc ::ixia::emulation_twamp_test_range_config { args } {
    variable executeOnTclServer
    variable objectMaxCount

    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::emulation_twamp_test_range_config $args\}]
        
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
        -handle                       ANY
    }
    
    set opt_args {
        -control_range_handle         ANY
        -mode                         CHOICES create modify enable disable remove
                                      DEFAULT create
        -num_pkts                     NUMERIC
                                      DEFAULT 1000
        -padding_with_zero            CHOICES 0 1
                                      DEFAULT 0
        -pkt_length                   NUMERIC
                                      DEFAULT 64
        -pps                          NUMERIC
                                      DEFAULT 10
        -session_reflector_port       NUMERIC
                                      DEFAULT 12001
        -session_reflector_port_step  NUMERIC
                                      DEFAULT 0
        -session_sender_port          NUMERIC
                                      DEFAULT 11001
        -session_sender_port_step     NUMERIC
                                      DEFAULT 1
        -test_sessions_count          NUMERIC
                                      DEFAULT 1
        -timeout                      NUMERIC
                                      DEFAULT 1
        -type_p_descriptor            NUMERIC
                                      DEFAULT 1
    }

    if [catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} errorMsg] {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg."
        return $returnList
    }

    if {[catch {package present IxTclNetwork} versionIxNetwork] || \
            ($versionIxNetwork < 5.30)} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: IxNetwork version not supported.\
            Please upgrade."
        return $returnList
    }       
    
    array set truth {1 true 0 false enable true disable false}
    
#        control_range_handle         controlRangeId                value    _none
    set test_range_params {
        num_pkts                     numberOfPackets               value    _none
        padding_with_zero            paddingWithZero               truth    _none
        pkt_length                   packetLength                  value    _none
        pps                          packetsPerSecond              value    _none
        session_reflector_port       sessionReflectorPort          value    _none
        session_reflector_port_step  sessionReflectorPortIncrement value    _none
        session_sender_port          sessionSenderPort             value    _none
        session_sender_port_step     sessionSenderPortIncrement    value    _none
        test_sessions_count          testSessionsCount             value    _none
        timeout                      timeout                       value    _none
        type_p_descriptor            typepDescriptor               value    _none
    } 

    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    } 

    set objectsToCommit 0

    if {$mode == "enable" || $mode == "disable"} {
        foreach twamp_ref $handle {
            set validate_message [::ixia::validateHandleObjectRef $twamp_ref {^::ixNet::OBJ-/vport:\d+/protocolStack/[^/]+/ipEndpoint:[-"0-9a-z]+/range:[-"0-9a-z]+/twampTestRange:[-"0-9a-z]+$}]
            if {$validate_message != "ok"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : $validate_message"
                return $returnList
            }
    
            set twamp_test_range_object_ref    $twamp_ref
    
            set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                    "$twamp_test_range_object_ref"                          \
                    "-enabled $truth($mode)"                                \
                    -no_commit                                              \
                ]
                
            if {[keylget tmp_status status] != $::SUCCESS} {
                keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                return $tmp_status
            }
            
            if {$objectsToCommit >= $::ixia::objectMaxCount} {
                ixNet commit
                set objectsToCommit 0
            } else {
                incr objectsToCommit
            }
        }
        
        if {$objectsToCommit > 0} {
            if {[catch {ixNet commit} err]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : \
                        failed to commit while changing the ENABLED attribute.\n$err"
                return $returnList
            }
            set objectsToCommit 0
        }
        
        keylset returnList  handle  $twamp_test_range_object_ref
        keylset returnList  status  $::SUCCESS
        return $returnList 
    }
    
    switch -- $mode {
        "create" {
            if {![info exists control_range_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When -mode is $mode\
                        parameter -control_range_handle must be provided."
                return $returnList
            }
            set enabled 1

            set validate_message [::ixia::validateHandleObjectRef $handle {^::ixNet::OBJ-/vport:\d+/protocolStack/[^/]+/ipEndpoint:[-"0-9a-z]+/range:[-"0-9a-z]+$}]
            if {$validate_message != "ok"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : $validate_message"
                return $returnList
            }
            set range_object_ref $handle
            set validate_message [::ixia::validateHandleObjectRef $control_range_handle {^::ixNet::OBJ-/vport:\d+/protocolStack/[^/]+/ipEndpoint:[-"0-9a-z]+/range:[-"0-9a-z]+/twampControlRange:[-"0-9a-z]+$}]
            
            set twamp_test_range_list [ixNet getList $range_object_ref twampTestRange]
                        
            # Configure twamp test range params --------------------------------------
            if {$twamp_test_range_list == "" } {
                set temporary_object [ixNet add $range_object_ref twampTestRange]
                if {[ixNet commit] != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Unable to commit after attempt to create twampTestRange object."
                    return $returnList
                }
                set twamp_test_range_object_ref [ixNet remapIds $temporary_object]
            } else {
                set twamp_test_range_object_ref [lindex $twamp_test_range_list 0]
            }

            set ixn_twamp_range_args ""
            foreach {hlt_param ixn_param p_type extensions} $test_range_params {
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
                    append ixn_twamp_range_args "-$ixn_param $ixn_param_value "
                }
            }

            if {$ixn_twamp_range_args != ""} {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                        "$twamp_test_range_object_ref"                          \
                        $ixn_twamp_range_args                                   \
                        -no_commit                                              \
                    ]                                 

                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
                if {$objectsToCommit >= $::ixia::objectMaxCount} {
                    ixNet commit
                    set objectsToCommit 0
                } else {
                    incr objectsToCommit
                }
            }   

            if {$objectsToCommit > 0} {
                ixNet commit
                set objectsToCommit 0
            }

            keylset returnList  handle  $twamp_test_range_object_ref
            keylset returnList  status  $::SUCCESS
            return $returnList
        }
        "modify" {
            # Remove defaults
            removeDefaultOptionVars $opt_args $args
            set twamp_list [list]
            foreach twamp_ref $handle {
                set validate_message [::ixia::validateHandleObjectRef $twamp_ref {^::ixNet::OBJ-/vport:\d+/protocolStack/[^/]+/ipEndpoint:[-"0-9a-z]+/range:[-"0-9a-z]+/twampTestRange:[-"0-9a-z]+$}]
                if {$validate_message != "ok"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : $validate_message"
                    return $returnList
                }
    
                # Assuming handle type is twampControlRange... 
                set twamp_test_range_object_ref    $twamp_ref  
    
                set ixn_twamp_range_args ""
                foreach {hlt_param ixn_param p_type extensions} $test_range_params {
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
                                set ixn_param_value $options_map($hlt_param_value)
                            }
                        }
                        append ixn_twamp_range_args "-$ixn_param $ixn_param_value "
                    }
                }
                if {$ixn_twamp_range_args != ""} {
                    set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                            "$twamp_test_range_object_ref"                          \
                            $ixn_twamp_range_args                                   \
                            -no_commit                                              \
                        ]                                 
            
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                    if {$objectsToCommit >= $::ixia::objectMaxCount} {
                        ixNet commit
                        set objectsToCommit 0
                    } else {
                        incr objectsToCommit
                    }
                }
                lappend twamp_list $twamp_test_range_object_ref
            } ;# foreach twamp_ref
            
            if {$objectsToCommit > 0} {
                ixNet commit
                set objectsToCommit 0
            }
            
            keylset returnList  handle  "${twamp_list}"
            keylset returnList  status  $::SUCCESS
            return $returnList
        }
        "remove" {
            foreach twamp_ref $handle {
                set validate_message [::ixia::validateHandleObjectRef $twamp_ref {^::ixNet::OBJ-/vport:\d+/protocolStack/[^/]+/ipEndpoint:[-"0-9a-z]+/range:[-"0-9a-z]+/twampTestRange:[-"0-9a-z]+$}]
                if {$validate_message != "ok"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : $validate_message"
                    return $returnList
                }
    
                # Assuming handle type is twampControlRange... 
                set twamp_test_range_object_ref    $twamp_ref
                
                set remove_result [ixNet remove $twamp_test_range_object_ref]
                if {$remove_result != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Unable to remove object handle $twamp_test_range_object_ref."
                    return $returnList
                }
                if {$objectsToCommit >= $::ixia::objectMaxCount} {
                    ixNet commit
                    set objectsToCommit 0
                } else {
                    incr objectsToCommit
                }
            }

            if {$objectsToCommit > 0} {
                if {[catch {ixNet commit} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : \
                            failed to commit while removing TWAMP test range object.\n$err"
                    return $returnList
                }
                set objectsToCommit 0
            }
            
            keylset returnList  handle  [string range $twamp_test_range_object_ref 0 [expr [string first "/range" $twamp_test_range_object_ref] - 1]]
            keylset returnList  status  $::SUCCESS
            return $returnList  
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}

##Procedure Header
# Name:
#    ::ixia::emulation_twamp_server_range_config
#
# Description:
#    Create a new TWAMP server range and associate it with the 
#    corresponding TWAMP test range using the -handle parameter.
#
# Synopsis:
#    ::ixia::emulation_twamp_server_range_config
#        [-control_port                   NUMERIC DEFAULT 862]
#        [-count                          NUMERIC]
#        [-enable_access_control          CHOICES 0 1 DEFAULT 1]
#        [-handle                         ANY]
#        [-iteration_count                NUMERIC]
#        [-key_id                         ANY]
#        [-mode                           CHOICES create modify enable disable remove DEFAULT create]
#        [-permitted_ip                   IP DEFAULT 0.0.0.0]
#        [-permitted_ip_intra_range_step  IP DEFAULT 0.0.0.0]
#        [-permitted_pkt_size             NUMERIC DEFAULT 64]
#        [-permitted_sender_port          NUMERIC DEFAULT 11001]
#        [-permitted_timeout              NUMERIC DEFAULT 1]
#        [-reflector_port                 NUMERIC DEFAULT 12001]
#        [-server_mode                    CHOICES unauthenticated authenticated encrypted DEFAULT unauthenticated]
#        [-shared_secret                  ANY]
#
# Arguments:
#    -control_port
#        Port on which the Server listens for Control-Sessions.
#    -count
#        Number of server ranges.
#    -enable_access_control
#        Enables or disables access control for this server range.
#    -handle
#        For -mode create, parameter -handle specifies the TWAMP control 
#        range to which the TWAMP test range is related. For -mode 
#        modify/enable/disable/remove, this is the TWAMP test range handle 
#        to be modified/enabled/disabled/removed.
#    -iteration_count
#        The number of iterations for this range.
#    -key_id
#        The key used for this session.
#    -mode
#        Action to perform.
#    -permitted_ip
#        The permitted IP address used by the server.
#    -permitted_ip_intra_range_step
#        The IP step used by the permitted IP address for this range.
#    -permitted_pkt_size
#        The permitted packet size used by the server.
#    -permitted_sender_port
#        The permitted source port of the stream initiated by Session-Sender.
#    -permitted_timeout
#        The permitted timeout for receiving packets on Session-Reflector after 
#        Stop-Sessions is received.
#    -reflector_port
#        Port on which the reflector receives the packets from the stream initiated 
#        by Session-Sender.
#    -server_mode
#        Unauthenticated (for phase1). Read-only field in GUI. Tool tip should 
#        indicate that current version does not support changing it. This will 
#        hopefully forestall some questions by different users at our initial 
#        customer.
#    -shared_secret
#        The shared secret key used for this session in encrypted mode.
#
# Return Values:
#    A keyed list 
#    key:status      value:$::SUCCESS | $::FAILURE 
#    key:log         value:When status is failure, contains more info 
#    key:handle      value:Handle of the twamp server range that was configured or modified
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
proc ::ixia::emulation_twamp_server_range_config { args } {
    variable executeOnTclServer
    variable objectMaxCount

    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::emulation_twamp_server_range_config $args\}]
        
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
        -handle                       ANY
    }
    
    set opt_args {
        -control_port                   NUMERIC
                                        DEFAULT 862
        -count                          NUMERIC
                                        DEFAULT 1
        -enable_access_control          CHOICES 0 1
                                        DEFAULT 1
        -iteration_count                NUMERIC
        -key_id                         ANY
        -mode                           CHOICES create modify enable disable remove
                                        DEFAULT create
        -permitted_ip                   IP
                                        DEFAULT 0.0.0.0
        -permitted_ip_intra_range_step  IP
                                        DEFAULT 0.0.0.0
        -permitted_pkt_size             NUMERIC
                                        DEFAULT 64
        -permitted_sender_port          NUMERIC
                                        DEFAULT 11001
        -permitted_timeout              NUMERIC
                                        DEFAULT 1
        -reflector_port                 NUMERIC
                                        DEFAULT 12001
        -server_mode                    CHOICES unauthenticated authenticated encrypted
                                        DEFAULT unauthenticated
        -shared_secret                  ANY
    }

    if [catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} errorMsg] {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg."
        return $returnList
    }

    if {[catch {package present IxTclNetwork} versionIxNetwork] || \
            ($versionIxNetwork < 5.30)} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: IxNetwork version not supported.\
            Please upgrade."
        return $returnList
    }       
    
    array set truth {1 true 0 false enable true disable false}

    set server_range_params {
        control_port                   controlPort             value        _none
        count                          count                   value        _none
        enable_access_control          enableAccessControl     truth        _none
        iteration_count                iterationCount          value        _none
        key_id                         keyId                   value        _none
        permitted_ip                   permittedIp             value        _none
        permitted_ip_intra_range_step  permittedIpIncrement    value        _none
        permitted_sender_port          permittedSenderPort     value        _none
        reflector_port                 reflectorPort           value        _none
        server_mode                    mode                    translate    _none
        shared_secret                  secret                  value        _none
    }
# BUG516087 
#         permitted_pkt_size             permittedPacketSize     value        _none
#         permitted_timeout              permittedTimeout        value        _none
    
    array set options_map {
        unauthenticated  unauthenticated  \
        authenticated    authenticated    \
        encrypted        encrypted        \
    } 

    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    } 

    set objectsToCommit 0

    if {$mode == "enable" || $mode == "disable"} {
        foreach twamp_ref $handle {
            set validate_message [::ixia::validateHandleObjectRef $twamp_ref {^::ixNet::OBJ-/vport:\d+/protocolStack/[^/]+/ipEndpoint:[-"0-9a-z]+/range:[-"0-9a-z]+/twampServerRange:[-"0-9a-z]+$}]
            if {$validate_message != "ok"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : $validate_message"
                return $returnList
            }
    
            set twamp_server_range_object_ref    $twamp_ref
    
            set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                    "$twamp_server_range_object_ref"                        \
                    "-enabled $truth($mode)"                                \
                    -no_commit                                              \
                ]                                 
    
            if {[keylget tmp_status status] != $::SUCCESS} {
                keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                return $tmp_status
            }
            
            if {$objectsToCommit >= $::ixia::objectMaxCount} {
                ixNet commit
                set objectsToCommit 0
            } else {
                incr objectsToCommit
            }
        }
        
        if {$objectsToCommit > 0} {
            if {[catch {ixNet commit} err]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : \
                        failed to commit while changing the ENABLED attribute.\n$err"
                return $returnList
            }
            set objectsToCommit 0
        }
        
        keylset returnList  handle  $twamp_server_range_object_ref
        keylset returnList  status  $::SUCCESS
        return $returnList 
    }
    
    switch -- $mode {
        "create" {
            set enabled 1
            
            set validate_message [::ixia::validateHandleObjectRef $handle {^::ixNet::OBJ-/vport:\d+/protocolStack/[^/]+/ipEndpoint:[-"0-9a-z]+/range:[-"0-9a-z]+$}]
            if {$validate_message != "ok"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : $validate_message"
                return $returnList
            }
            
            set range_object_ref $handle
            set ipendpoint_objref    [::ixia::ixNetworkGetParentObjref $range_object_ref]
            
            set twamp_server_range_list [list]
            
            # Configure twamp server range params --------------------------------------
            set temporary_object [ixNet add $range_object_ref twampServerRange]
            if {[ixNet commit] != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Unable to commit after attempt to create twampServerRange object."
                return $returnList
            } else {
                set twamp_server_range_object_ref [ixNet remapIds $temporary_object]
            }

            lappend twamp_server_range_list $twamp_server_range_object_ref
            
            set ixn_twamp_range_args ""
            foreach {hlt_param ixn_param p_type extensions} $server_range_params {
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
                            set ixn_param_value $options_map($hlt_param_value)
                        }
                    }
                    append ixn_twamp_range_args "-$ixn_param $ixn_param_value "
                }
            }
            if {$ixn_twamp_range_args != ""} {
                set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                        "$twamp_server_range_object_ref"                        \
                        $ixn_twamp_range_args                                   \
                        -no_commit                                              \
                    ]                                 
        
                if {[keylget tmp_status status] != $::SUCCESS} {
                    keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                    return $tmp_status
                }
                if {$objectsToCommit >= $::ixia::objectMaxCount} {
                    ixNet commit
                    set objectsToCommit 0
                } else {
                    incr objectsToCommit
                }
            }   

            if {$objectsToCommit > 0} {
                ixNet commit
                set objectsToCommit 0
            }
        
            # Create twampServer object...
            set server_object_ref [ixNet getL $ipendpoint_objref twampServer]
            if {[llength $server_object_ref] == 0} {
                set temporary_object [ixNet add $ipendpoint_objref twampServer]
                if {[ixNet commit] != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Unable to commit after attempt to create twampServer object."
                    return $returnList
                } else {
                    set server_object_ref [ixNet remapIds $temporary_object]
                }
            }
            
            keylset returnList  handle  "${twamp_server_range_list}"
            keylset returnList  status  $::SUCCESS
            return $returnList
        }
        "modify" {
            # Remove defaults
            removeDefaultOptionVars $opt_args $args
            set twamp_list [list]
            foreach twamp_ref $handle {
                set validate_message [::ixia::validateHandleObjectRef $twamp_ref {^::ixNet::OBJ-/vport:\d+/protocolStack/[^/]+/ipEndpoint:[-"0-9a-z]+/range:[-"0-9a-z]+/twampServerRange:[-"0-9a-z]+$}]
                if {$validate_message != "ok"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : $validate_message"
                    return $returnList
                }
    
                # Assuming handle type is twampControlRange... 
                set twamp_server_range_object_ref    $twamp_ref  
    
                set ixn_twamp_range_args ""
                foreach {hlt_param ixn_param p_type extensions} $server_range_params {
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
                                set ixn_param_value $options_map($hlt_param_value)
                            }
                        }
                        append ixn_twamp_range_args "-$ixn_param $ixn_param_value "
                    }
                }
                if {$ixn_twamp_range_args != ""} {
                    set tmp_status [::ixia::ixNetworkNodeSetAttr                    \
                            "$twamp_server_range_object_ref"                        \
                            $ixn_twamp_range_args                                   \
                            -no_commit                                              \
                        ]                                 
            
                    if {[keylget tmp_status status] != $::SUCCESS} {
                        keylset tmp_status log "ERROR in $procName: [keylget tmp_status log]"
                        return $tmp_status
                    }
                    if {$objectsToCommit >= $::ixia::objectMaxCount} {
                        ixNet commit
                        set objectsToCommit 0
                    } else {
                        incr objectsToCommit
                    }
                }
                lappend twamp_list $twamp_server_range_object_ref
            } ;# foreach twamp_ref
            
            if {$objectsToCommit > 0} {
                ixNet commit
                set objectsToCommit 0
            }
            
            keylset returnList  handle  "${twamp_list}"
            keylset returnList  status  $::SUCCESS
            return $returnList
        }
        "remove" {
            foreach twamp_ref $handle {
                set validate_message [::ixia::validateHandleObjectRef $twamp_ref {^::ixNet::OBJ-/vport:\d+/protocolStack/[^/]+/ipEndpoint:[-"0-9a-z]+/range:[-"0-9a-z]+/twampServerRange:[-"0-9a-z]+$}]
                if {$validate_message != "ok"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : $validate_message"
                    return $returnList
                }
    
                set twamp_server_range_object_ref    $twamp_ref
                set associated_ipendpoint [::ixia::ixNetworkGetParentObjref $twamp_server_range_object_ref ipEndpoint]
                set twampserver [ixNet getL $associated_ipendpoint twampServer]
                if {[llength $twampserver] > 0} {
                    set remove_result [ixNet remove $twampserver]
                    if {$remove_result != "::ixNet::OK"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Unable to remove object handle $twampserver."
                        return $returnList
                    }
                    if {$objectsToCommit >= $::ixia::objectMaxCount} {
                        ixNet commit
                        set objectsToCommit 0
                    } else {
                        incr objectsToCommit
                    }
                }
            }

            if {$objectsToCommit > 0} {
                if {[catch {ixNet commit} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : \
                            failed to commit while removing TWAMP server object.\n$err"
                    return $returnList
                }
                set objectsToCommit 0
            }
            
            keylset returnList  handle  [string range $twamp_server_range_object_ref 0 [expr [string first "/range" $twamp_server_range_object_ref] - 1]]
            keylset returnList  status  $::SUCCESS
            return $returnList  
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::emulation_twamp_control { args } {

    variable executeOnTclServer

    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args

    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::emulation_twamp_control $args\}]
        
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
        -mode         CHOICES abort abort_async start stop restart
    }
    
    set opt_args {
        -handle        ANY
        -port_handle   REGEXP ^[0-9]+/[0-9]+/[0-9]+$
    }

    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg"
        return $returnList
    }
    
    # Check to see if a connection to the IxNetwork TCL server already exists.
    # If it doesn't, establish it.
    set return_status [checkIxNetwork]
    if {[keylget return_status status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to \
                IxNetwork [keylget return_status log]"
        return $returnList
    }
    
    set ipendpoint_objref_list [list]

    if {[info exists handle]} {
        set validate_message [::ixia::validateHandleObjectRef $handle {^::ixNet::OBJ-/vport:\d+/protocolStack/[^/]+/ipEndpoint:[-\"0-9a-z]+$}]
        if {$validate_message != "ok"} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : $validate_message"
            return $returnList
        }
        set ipendpoint_objref_list    $handle
    } elseif {[info exists port_handle]} {
        set valid_port_list [::ixia::ixNetworkGetPortObjref $port_handle]
        set vport_object_ref [keylget valid_port_list vport_objref]
        if {[keylget valid_port_list status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to find associated vport for port $port_handle."
            return $returnList
        }
        set ethernet_object_ref [ixNet getL "${vport_object_ref}/protocolStack" "ethernet"]
        if {[llength $ethernet_object_ref] != 0} {
            set ipendpoint_objref_list [ixNet getL $ethernet_object_ref "ipEndpoint"]
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to find any ethernet object references under ${vport_object_ref}/protocolStack"
            return $returnList
        }
    } else {
        # if -handle and -port_handle don't exist
        set vport_list [ixNet getList [ixNet getRoot] vport]
        foreach vp $vport_list {
            set ret_val [::ixia::ixNetworkValidateSMPlugins $vp "ethernet" "ipEndpoint"]
            if {[keylget ret_val status] == $::SUCCESS && [keylget ret_val summary] == 3} {
                set ipendpoint_objref_list [concat $ipendpoint_objref_list [keylget ret_val ret_val]]
            }
        }
    }
    
    
    array set action_map {
        abort           {   abort          0   {
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ipEndpoint:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/ipEndpoint:[^/]+}
                                        }
                        }
        abort_async     {   abort          1   {
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ipEndpoint:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/ipEndpoint:[^/]+}
                                        }
                        }
        start            {   start          0   {
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ipEndpoint:[^/]+/range:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/ipEndpoint:[^/]+/range:[^/]+$}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ipEndpoint:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/ipEndpoint:[^/]+}
                                        }
                        }
        stop         {   stop          0   {
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ipEndpoint:[^/]+/range:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/ipEndpoint:[^/]+/range:[^/]+$}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ipEndpoint:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/ipEndpoint:[^/]+}
                                                }
                        }
        restart           {   {stop start}   0   {
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ipEndpoint:[^/]+/range:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/ipEndpoint:[^/]+/range:[^/]+$}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ipEndpoint:[^/]+}
                {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/ipEndpoint:[^/]+}
                                        }
                        }
    }
    
    foreach handle $ipendpoint_objref_list {
        
        # Check link state
        regexp {(::ixNet::OBJ-/vport:\d).*} $handle {} vport_objref
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
            keylset returnList log "ERROR in $procName: Failed to $mode TWAMP on the\
                    $vport_objref port. Port state is $portState, $portStateD."
            return $returnList
        }
        
        foreach regexp_elem [lindex $action_map($mode) 2] {
            if {[regexp $regexp_elem $handle handle_temp]} {
                set handle $handle_temp
                break;
            }
        }
        
        foreach action_elem [lindex $action_map($mode) 0] {
            set ixNetworkExecParamsAsync [list $action_elem  $handle]
            set ixNetworkExecParamsSync  [list $action_elem  $handle]
            if {[lindex $action_map($mode) 1]} {
                lappend ixNetworkExecParamsAsync async
            }
            
            if {[catch {ixNetworkExec $ixNetworkExecParamsAsync} status]} {
                if {[string first "no matching exec found" $status] != -1} {
                    if {[catch {ixNetworkExec $ixNetworkExecParamsSync} status] && \
                            ([string first "::ixNet::OK" $status] == -1)} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to $mode TWAMP. Returned status: $status"
                        return $returnList
                    }
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to $mode TWAMP. Returned status: $status"
                    return $returnList
                }
            } else {
                if {[string first "::ixNet::OK" $status] == -1} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to $mode TWAMP. Returned status: $status"
                    return $returnList
                }
            }
        }
    }

    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::emulation_twamp_info { args } {

    set procName [lindex [info level [info level]] 0]
    
    ::ixia::utrackerLog $procName $args
    ::ixia::logHltapiCommand $procName $args
    
    set man_args {
        -port_handle  REGEXP ^[0-9]+/[0-9]+/[0-9]+$
    }
    
    set opt_args {
        -action       CHOICES clear
        -handle       ANY
    }
    
    if [catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} errorMsg] {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: $errorMsg."
        return $returnList
    }
    
    array set truth {1 true 0 false enable true disable false}

    keylset returnList status $::SUCCESS
    
    # TWAMP Statistics
                    
    set stat_list_twamp_control {
        "Port Name"
                port_name
        "Sessions Initiated"
                sess_initiated
        "Sessions Succeeded"
                sess_successful
        "Sessions Failed"
                sess_failed
        "Active Sessions"
                sess_active
        "Initiated Sessions Rate"
                sess_initiated_rate
        "Successful Sessions Rate"
                sess_successful_rate
        "Failed Sessions Rate"
                sess_failed_rate
    }  
                
     set stat_list_twamp_data {        
        "Datagram Tx"
                datagram_tx
        "Datagram Rx"
                datagram_rx
        "Datagram Lost"
                datagram_lost
        "Datagram Unexpected"
                datagram_unexpected
        "Data Streams Initiated"
                data_streams_initiated
        "Data Streams Successful"
                data_streams_successful
        "Data Streams Failed"
                data_streams_failed
     }
     
     set stat_list_twamp_test {        
        "Initiated Sessions"
                sess_initiated
        "Successful Sessions"
                sess_successful
        "Failed Sessions"
                sess_failed
        "Active Sessions"
                sess_active
        "Initiated Sessions Rate"
                sess_initiated_rate
        "Successful Sessions Rate"
                sess_successful_rate
        "Failed Sessions Rate"
                sess_failed_rate
     } 
    
    set statistic_types [list                                           \
        twamp_control   "TWAMP Control"                                 \
        twamp_data      "TWAMP Data"                                    \
        twamp_test      "TWAMP Test"                                    \
        ]
     
    # Changing the statistic_types list if a twampServer is used
    if {[info exists ::ixia::ixnetwork_port_handles_array($port_handle)]} {
        set vport_objref $::ixia::ixnetwork_port_handles_array($port_handle)
        set protocolStack $vport_objref/protocolStack
        set ethernet [lindex [ixNet getList $protocolStack ethernet] 0]
        set ipEndpoint [lindex [ixNet getList $ethernet ipEndpoint] 0]
        set twampServer [ixNet getList $ipEndpoint twampServer]
        
        if {[llength $twampServer] > 0} {
            set statistic_types [list                                      \
                twamp_control   "TWAMP Server Control"                     \
                twamp_data      "TWAMP Server Data"                        \
                twamp_test      "TWAMP Server Test"                        \
            ]
        }
    } 

    array set statViewBrowserNamesArray $statistic_types
    set statViewBrowserNamesList ""
    foreach stat_type [array names statViewBrowserNamesArray] {
        lappend statViewBrowserNamesList \
                $statViewBrowserNamesArray($stat_type)
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
    if {[info exists action] && $action == "clear"} {
        set port_handle [ixNetworkGetRouterPort $port_objref]
        if {$port_handle != "0/0/0"} {
            if {[set retCode [catch \
                    {ixNet exec clearStats} retCode]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to clear statistics."
                return $returnList
            }
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to determine the port handle\
                    of the port on which the '$handle' router is emulated."
            return $returnList
        }
    }
    return $returnList
}

# Helper procedure ------------------------------------------------------------#
# Validate handle object ref --------------------------------------------------#
proc ::ixia::validateHandleObjectRef { what_handle pattern } {
    if {![info exists what_handle]} {
        return "Handle parameter missing."
    } else {
        if {[ixNet exists $what_handle] == "false" || [ixNet exists $what_handle] == 0} {
            return "Invalid or incorrect handle."
        }
    }            
    if {![regexp -all $pattern $what_handle]} {
        return "Handle is not a valid one."
    }
    return "ok"
}
# -----------------------------------------------------------------------------#

