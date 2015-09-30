##Library Header.
# $Id: $
# Copyright © 2003-2009 by IXIA
# All Rights Reserved
#
# Name:
#    ixiaHLTAPI.tcl
#
# Purpose:
#    A script development library containing general APIs for test automation
#    with the Ixia chassis
#
# Author:
#    Karim Lacasse
#
# Usage:
#    package require Ixia
#
# Description:
#    This library contains general purpose procedures that can
#    be used during the TCL software development process utilize and configure
#    the Ixia chassis and load modules.  The procedures contained
#    within this library include:
#
#    - Traffic configuration
#    - Interface configuration
#    - Protocol Emulation
#    - Traffic and Protocol Statictics
#    - Capture
#
#    Use this library during the development of a script or
#    procedure library to verify the software in a simulation
#    environment and to perform an internal unit test on the
#    software components.
#
# Requirements:
#    ixiaapiutils.tcl
#    parseddashedargs.tcl
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


proc ::ixia::legacy_connect { args } {
    variable executeOnTclServer
    variable hltsetUsed
    variable no_more_tclhal
    variable ixnetworkVersion
    variable loadProtOrNetw
    variable file_debug
    variable ixnetwork_rp2vp_handles_array
    variable first_connect_in_session
    variable aggregation_mode
    variable aggregation_resource_mode
    variable tcl_server_fallback
        
    # Variables to be sent on Tcl Server also
    set globalVariablesLst {
        chassis_list 
        connect_timeout 
        connected_tcl_srv 
        hltConnectCall
        ixload_chassis_list 
        ixload_tcl_server 
        ixn_traffic_version
        ixnetwork_chassis_list
        ixnetwork_tcl_server 
        ixnetwork_tcl_proxy
        ixnetwork_tcl_server_reset 
        ixtclhal_version
        new_ixnetwork_api 
        port_supports_types 
        reserved_port_list
        session_owner_tclhal
        ixnetworkVersion
        file_debug
        snapshot_stats
        session_get_full_tree
        csv_path
        tcl_proxy_username
        ixnetwork_license_servers
        ixnetwork_license_type
        close_server_on_disconnect
        conToken
        username
        }
    foreach globalVar $globalVariablesLst {
        variable $globalVar
    }
    set hltConnectCall 1
    set conToken ""
    # Variables to be sent on Tcl Server also
    set globalVariablesArr {
        emulation_handles_array
        ixnetwork_port_handles_array
        ixnetwork_real_port_handles_array
        ixnetwork_port_handles_array_vport2rp
        master_chassis_array
        ixnetwork_master_chassis_array
        pgid_to_stream
        port_queue_num
        clear_csv_stats
        stream_to_queue_map
        ixnetwork_rp2vp_handles_array
        ::_device
    }
    foreach globalArr $globalVariablesArr {
        variable $globalArr
    }

    set procName {::ixia::connect}

    ::ixia::utrackerLog $procName $args
    ::ixia::logHltapiCommand $procName $args

    set man_args {
    }

    set defUName "[pid] [clock format [clock seconds] -format %c]"

    eval set opt_args "\{
        -port_list                  REGEXP ^({*(\[0-9\]+/\[0-9\]+\[\\\ \]*)*}*\[\\\ \]*)+$
        -aggregation_mode           VCMD ::ixia::validate_aggregation_mode
        -aggregation_resource_mode  VCMD ::ixia::validate_aggregation_resource_mode
        -device                     ANY
        -break_locks                CHOICES 0 1
                                    DEFAULT 1
        -close_server_on_disconnect CHOICES 0 1
        -config_file
        -config_file_hlt
        -connect_timeout            NUMERIC
                                    DEFAULT 10
        -enable_win_tcl_server      CHOICES 0 1
                                    DEFAULT 0
        -guard_rail                 CHOICES statistics none
                                    DEFAULT none
        -interactive                CHOICES 0 1
        -ixnetwork_tcl_server       ANY
        -logging                    CHOICES hltapi_calls
        -log_path                   SHIFT
        -ixnetwork_tcl_proxy
        -master_device
		-chain_type					CHOICES daisy star none
                                    DEFAULT none
        -chain_sequence             NUMERIC
        -chain_cables_length        CHOICES 0 3 6
        -reset
        -session_resume_keys        CHOICES 0 1
                                    DEFAULT 1
        -session_resume_include_filter ANY
                                    DEFAULT {}
        -sync                       CHOICES 0 1
                                    DEFAULT 1
        -tcl_proxy_username         ANY
        -ixnetwork_license_servers  ANY
        -ixnetwork_license_type     CHOICES perpetual subscription_tier0 subscription_tier1 subscription_tier2 subscription_tier3 mixed
                                    DEFAULT perpetual
        -tcl_server                 ANY
        -username                   DEFAULT \"$defUName\"
        -vport_count                RANGE   1-600
        -mode                       CHOICES connect disconnect save reconnect_ports
                                    DEFAULT connect
        -vport_list                 REGEXP  ^\[0-9\]+/\[0-9\]+/\[0-9\]+$
        \}"
    
    # append CPF specific optional arguments so the parsing function won't crash
    eval set cpf_opt_args "\{
        -execution_timeout          NUMERIC
                                    DEFAULT 0
        -return_detailed_handles    CHOICES 0 1
                                    DEFAULT 1
        \}"
    append opt_args $cpf_opt_args
    
    # BUG342346, BUG666488, BUG674433
    # The tcl_interactive variable is not set to a default value 
    # if the -interactive parameter is not given.
    if {[regexp -- {-interactive[ ]+(0|1)} $args i_ignore i_mode]} {
        set ::tcl_interactive $i_mode
    }

    if {[catch {::ixia::parse_dashed_args \
            -args           $args         \
            -optional_args  $opt_args     } parseError]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed on parsing.\
                $parseError."
        return $returnList
    }

    # BUG1300751, side effect: on windows the backslashes are incorrectly escaped by parse_dashed_args
    if {![isUNIX] } {
         if {[info exists config_file]} {
             set config_file [file normalize [lindex $args [expr [lsearch $args -config_file] +1]]]
         }
         if {[info exists config_file_hlt]} {
             set config_file_hlt [file normalize [lindex $args [expr [lsearch $args -config_file_hlt] +1]]]
         }
    }

    # unset all the arrays used in the traffic_stats procedure
    if {[info exists reset]} {
        ::ixia::cleanupTrafficStatsArrays
    }
    
    if {![info exists log_path]} {
        if {[catch {set log_path [file join [ats_get_logdir]]}]} {
            set log_path ""
        }
    }

    if { [info exists logging] && [lcontain $logging hltapi_calls] } {
        # enable HLTAPI logging
        set ::ixia::logHltapiCommandsFlag 1
        # define log file name and path
        set ::ixia::logHltapiCommandsFileName [file join $log_path hltCmdLog[clock clicks -milliseconds].txt]
    }

    if {![info exists ::ixia::session_resume_keys]} {
        set ::ixia::session_resume_keys $session_resume_keys
    }
    set connect_timeout $connect_timeout
    
    # Moved this here in order to set the interactivity mode correctly
    set cleanup false
    if {$::ixia::executeOnTclServer && [info exists tcl_server] && \
            $::ixia::connected_tcl_srv == $tcl_server} {
        
        # If 'enable_win_tcl_server' exists we don't want to send it to the tcl server (BUG548154)
        set pos [lsearch $args -enable_win_tcl_server]
        if {$pos != -1} {
            set args [lreplace $args $pos $pos] ;# remove -enable_win_tcl_server var
            # remove -enable_win_tcl_server value (it will have $pos index because we already removed
            # enable_win_tcl_server
            set args [lreplace $args $pos $pos] 
        }
        
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::legacy_connect $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    } elseif {[info exists tcl_server] && \
            $::ixia::connected_tcl_srv != $tcl_server && \
            $::ixia::connected_tcl_srv != ""} {
                
        set cleanup true
    }
    
    # _device is a global used to provide ip address to host name conversions
    global _device
    
    # Decide whether or not it is necessary to initialize the auto_path on the 
    # IxTclServer machine.
    if {$::ixia::connected_tcl_srv == "" || $cleanup} {
        set hlt_init_flag true
    } else {
        set hlt_init_flag false
    }
    
    if {[info exists aggregation_mode]} {
        set ::ixia::aggregation_mode $aggregation_mode
    }
    if {[info exists aggregation_resource_mode]} {
        set ::ixia::aggregation_resource_mode $aggregation_resource_mode
    }
    # If P2NO is used than we don't know if new_ixnetwork_api is 1
    # I'll do the following just to determine this
    # The actual loading of Network will be done lower in the proc
    if {$loadProtOrNetw} {
        set loadProtOrNetw 0
        
        # IxNetwork/IxTclProtocol Package has not been loaded
        if {$ixnetworkVersion != "NA"} {
            if {[regexp {^(\d+.\d+)(P2NO)$} $ixnetworkVersion {} version product]} {
                if {[info exists ixnetwork_tcl_server] && [llength $ixnetwork_tcl_server] != 0} {
                    puts "\nUsing IxTclNetwork API"
                    set ::ixia::new_ixnetwork_api 1
                    set ::ixia::no_more_tclhal    1
                } else {
                    puts "\nUsing IxTclProtocol API"
                    set ::ixia::new_ixnetwork_api 0
                    set ::ixia::no_more_tclhal    0
                }
            }
        }
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api } {
        
        if {[isUNIX]} {
            # IxTclNetwork, Unix
            # Tcl Server must be the same with IxN Tcl Server and they 
            # shouldn't be on chassis machine
            if {![info exists tcl_server] &&\
                    (![info exists ixnetwork_tcl_server] || $ixnetwork_tcl_server == "")} {
                        
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When running on\
                        Unix Platform and using IxTclNetwork  package, please\
                        provide ixnetwork_tcl_server."
                return $returnList
            } elseif {![info exists tcl_server]} {
                set tcl_server          [lindex [split $ixnetwork_tcl_server :] 0]
                set ::ixia::ixnetwork_tcl_server $ixnetwork_tcl_server
                if {[info exists device]} {
                    set tcl_server_fallback [lindex $device 0]
                }
            } elseif {![info exists ixnetwork_tcl_server] || $ixnetwork_tcl_server == ""} {
                set ixnetwork_tcl_server ${tcl_server}
                set ::ixia::ixnetwork_tcl_server ${tcl_server}
            }
        } elseif {$::tcl_platform(platform) == "windows"} {
            if {!$enable_win_tcl_server} {
                # If enable_win_tcl_server is 0, we ignore Tcl Server
                if {[info exists tcl_server]} {
					unset tcl_server
				}
                if {![info exists ixnetwork_tcl_server] || ($ixnetwork_tcl_server == "")} {
                    set ixnetwork_tcl_server 127.0.0.1
                    set ::ixia::ixnetwork_tcl_server 127.0.0.1
                }
            } else {
                if {![info exists tcl_server] && (![info exists ixnetwork_tcl_server] || $ixnetwork_tcl_server == "") } {
                    set ixnetwork_tcl_server 127.0.0.1
                    set ::ixia::ixnetwork_tcl_server 127.0.0.1
                    set tcl_server           127.0.0.1
                } elseif {![info exists tcl_server]} {
                    set tcl_server [lindex [split $ixnetwork_tcl_server :] 0]
                    set ::ixia::ixnetwork_tcl_server $ixnetwork_tcl_server
                } elseif {![info exists ixnetwork_tcl_server] || $ixnetwork_tcl_server == ""} {
                    set ixnetwork_tcl_server $tcl_server
                    set ::ixia::ixnetwork_tcl_server $ixnetwork_tcl_server
                }
            }
        }
		
		if {[isUNIX] && [info exists no_more_tclhal] && $no_more_tclhal == 1} {
			if {[info exists tcl_server]} {
                unset tcl_server
            }
		}
        
            
        #chassis chain
        set chassis_chain ""
        if {[info exists device]} {
            foreach single_device $device {
                keylset chassis_chain device.$single_device.master none
            }
        }
        
        
        if {[info exists master_device] && [info exists device]} {
            set devices_no [llength $device]
            set master_devices_len [llength $master_device]
            set master_chassis_list [list]
            
            # making sure master_device  has same length as devices. 
            if { $devices_no != $master_devices_len} {
                if { $master_devices_len == 1 } {
                    set master_device [lrepeat $devices_no $master_device]
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR: $devices_no devices provided, but only $master_devices_len master_devices. Expecting\
                            0, 1 or $devices_no elements in master_device argument."
                    return $returnList
                }
            }
            
            
            foreach mc $master_device {
                if {$mc != "none" && [string trim $mc] != ""} {
                    lappend master_chassis_list $mc
                    if {$chain_type == "none"} {
                        debug "WARNING: master_device provided, but no chain_type. Setting chain_type to 'daisy'."
                        set chain_type daisy
                    }
                    keylset chassis_chain master_device.$mc.type $chain_type
                }
            }
            set master_chassis_list [lsort -nocase -unique $master_chassis_list]
            set master_chassis_count [llength $master_chassis_list]
            
            if {$master_chassis_count >0} {
                if {![info exists chain_cables_length]} {
                    puts "WARNING: master_device provided, but no chain_cables_length. '3' ft cable length will be\
                            used as default for all chassis in the chain."
                    # adding 3 for all devices in the device list
                    set chain_cables_length [lrepeat $devices_no 3]
                } else {
                    if { [llength $chain_cables_length] != $devices_no} {
                        if { [llength $chain_cables_length] == 1} {
                            debug "Only one value provided for chain_cables_length ($chain_cables_length). Repeating\
                                    the value for all devices."
                            set chain_cables_length [lrepeat $devices_no [expr $chain_cables_length]]
                        } else {
                            puts "WARNING: the number of values in chain_cables_length does not match the number of\
                                    devices ($devices_no). '3' ft cable length will be used as default where\
                                    not specified."
                        # making sure chain_cables_length has same length as devices. Filling missing values with 3
                        # and trucating if more values provided.
                            set chain_cables_length "$chain_cables_length [lrepeat $devices_no 3]" 
                            set chain_cables_length [lrange $chain_cables_length 0 [expr $devices_no - 1]]
                        }
                    }
                }
                # chain_sequence 1 is reserved for master chasiss
                set calculated_chain_sequence 2
                for {set did 0} { $did <$devices_no } {incr did} {
                    set current_device [lindex $device $did]
                    if { [lsearch $master_device $current_device] > -1 } {
                        # master chassis have id 1
                        keylset chassis_chain device.$current_device.id     1
                        if { (![info exists chain_sequence]) } {
                            # master chassis should have the the id smaller than the smallest slave
                            keylset chassis_chain device.$current_device.id  1
                        } else {
                            keylset chassis_chain device.$current_device.id [lindex $chain_sequence $did]
                        }
                        keylset chassis_chain device.$current_device.master none
                    } else {
                        #slave chassis. 
                        keylset chassis_chain device.$current_device.cable  [lindex $chain_cables_length $did]
                        keylset chassis_chain device.$current_device.master [lindex $master_device $did]
                        if { $chain_type == "daisy" } {
                            # sequence only used by daisy chain
                            if { (![info exists chain_sequence]) } {
                                #we will add a sequence id based on the device order
                                keylset chassis_chain device.$current_device.id $calculated_chain_sequence
                            } else {
                                keylset chassis_chain device.$current_device.id [lindex $chain_sequence $did]
                            }
                        incr calculated_chain_sequence
                        }
                    }
                }
            }
            keylset chassis_chain type $chain_type
            set ::ixia::chassis_chain $chassis_chain
            debug "Chassis chain:\n [::ixia::keylprint chassis_chain]"
        }
        
        # Use session resume/save feature
        if {![info exists reset] && $mode != "disconnect" && ($first_connect_in_session || $mode == "save")} {
            set first_connect_in_session 0
            
            set param_map {
                mode                            mode
                config_file                     file_ixncfg
                config_file_hlt                 file_name
                ixnetwork_tcl_server            ixnetwork_tcl_server
                device                          device
                port_list                       port_list
                tcl_server                      tcl_server
            }
            
            array set param_map_choices {
                connect         load
                save            save
            }
            
            set cmd "session_control"
            foreach {param_x param_y} $param_map {
                if {[info exists $param_x]} {
                    set param_x_val [set $param_x]
                    if {[info exists param_map_choices($param_x_val)]} {
                        set param_x_val $param_map_choices($param_x_val)
                    }
                    # BUG1300751, side effect: on windows the backslashes are incorrectly escaped
                    if {![isUNIX] && ($param_x == "config_file" || $param_x == "config_file_hlt")} {
                        set param_x_val [string map {\\ \\\\} $param_x_val]
                    }
                    lappend cmd -$param_y $param_x_val
                }
            }

            if {[catch {eval $cmd} cmd_out]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to execute '$cmd'. $cmd_out"
                return $returnList
            }
            if {[keylget cmd_out status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: [keylget cmd_out log]"
                return $returnList
            }

            # ensure finalization of serialization xml, used for session resume
            # this is needed because session_info will do another serialization for protocols
            ixia::session_resume::sr_finalize
            
            if {![info exists ::ixia::session_resume_keys] || $::ixia::session_resume_keys == 1} {
                set ret_code [ixia::session_info                                \
                    -mode get_session_keys                                      \
                    -session_keys_include_filter $session_resume_include_filter \
                    -detect_required_session_variables 0                        \
                ]
                if {[keylget ret_code status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: [keylget ret_code log]"
                    return $returnList
                }
                set returnList $ret_code
            } else {
                set returnList [list]
            }
            
            if {[keylget cmd_out status] == $::SUCCESS} {
                set _conToken $conToken
                #puts "_conToken: $_conToken"
                set return_code [::ixia::connection_key_builder $_conToken]
                #puts "return_code: $return_code"
                keylset returnList connection $return_code            
            }
            
            set return_code [::ixia::guardrail_info]
            if {[keylget return_code status] == $::SUCCESS} {
                keylset returnList guardrail_messages [keylget return_code guardrail_messages]    
            }
            
            # ENH685139: HLTAPI: ixia::connect needs to return the ixNet protocols object handle
            set protocol_handle ""
            foreach ph_elem [ixNet getList [ixNet getRoot] vport] {
                lappend protocol_handle ${ph_elem}/protocols
            }
            keylset returnList vport_protocols_handle $protocol_handle
            
            if {$mode == "save" || (![info exists device] && ![info exists port_list] &&\
                    ![info exists vport_list] && ![info exists vport_count])} {
                
                keylset returnList status $::SUCCESS
                return $returnList
            }
            
            if {[info exists device] && [info exists port_list]} {
                if {[catch {keylget cmd_out port_handle_pool} port_handle_pool]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Internal error on session resume.\
                            Procedure '$cmd' did not return the 'port_handle_pool' when -device\
                            and -port_list were specified. Returned keys are: '$cmd_out'"
                    return $returnList
                }
                
                set vport_list $port_handle_pool
            }
        }
        
        set first_connect_in_session 0
        
    } else {
        
        set first_connect_in_session 0
        
        if {[isUNIX]} {
            # IxTclProtocol, Unix
            # If not provided by the user, Tcl Server should be by default 
            # equal to the first chassis in the list
            if {![info exists tcl_server]} {
                # This code is safe for vports because it's ixos and 
                # connect_mode is "legacy"
				if {[info exists no_more_tclhal] && $no_more_tclhal == 1} {
					if {[info exists tcl_server]} {
						unset tcl_server
					}
				} elseif {[info exists device]} {
                    set tcl_server [lindex $device 0]
                }
            }
        } elseif {$::tcl_platform(platform) == "windows"} {
            # IxTclProtocol, Windows
            # Tcl Server is ignored
            if {[info exists tcl_server]} {
                unset tcl_server
            }
        }
        # IxTclProtocol, Unix and Windows
        # IxN Tcl Server is ignored
        if {![info exists ixnetwork_tcl_server] || $ixnetwork_tcl_server != ""} {
            set ixnetwork_tcl_server ""
        }
    }
    
    if {!$first_connect_in_session && (![info exists vport_list] || [llength vport_list] == 0) &&\
            ![info exists device] && ![info exists port_list] && ![info exists vport_count] && ($mode != "reconnect_ports") } {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: None of the\
                parameters '-device', '-port_list', '-vport_list',\
                '-vport_count' was specified. Session resume can be done\
                only at the first ::ixia::connect call in the script."
        return $returnList
    }
    
    if {[info exists tcl_server]} {
        set ixload_tcl_server $tcl_server
    }
    
    # Connect only if we're not connected to tcl server OR
    #       if we are connected but to another tcl server than the one requested
	#       and only if IxTclHal is being used
	
	if {  ![info exists ::ixia::no_more_tclhal] || $::ixia::no_more_tclhal == 0 } {
		if {(![info exists tcl_server] || $::ixia::connected_tcl_srv != $tcl_server) &&\
				(![info exists tcl_server_fallback] || $::ixia::connected_tcl_srv != $tcl_server_fallback)} {
			
			if {[info exists tcl_server]} {
				
				# Set environment variable - this variable needs to be set here(see bug 428510)
				if {[regexp "^HLTSET" $::env(IXIA_VERSION)]} {
					set IXIA_VERSION_bak $::env(IXIA_VERSION)
					set ixtclhal_list [split [package present IxTclHal]]
					set ::env(IXIA_VERSION) [lindex $ixtclhal_list 0].[lindex $ixtclhal_list 1]
				}
				
				if {$connected_tcl_srv != ""} {
					catch {ixDisconnectTclServer}
					set connected_tcl_srv ""
				}
				
				if {[connect_to_tcl_server $tcl_server]} {
					set bak_err_msg $::ixErrorInfo
					if {[info exists tcl_server_fallback]} {
						if {[connect_to_tcl_server $tcl_server_fallback]} {
							set connected_tcl_srv ""
							keylset returnList status $::FAILURE
							keylset returnList log "ERROR in $procName: Could not connect\
									to tcl_server $tcl_server ($bak_err_msg) or $tcl_server_fallback ($::ixErrorInfo)"
							return $returnList
						} else {
							set warning_message_return "WARNING: Could not connect to tcl server\
									$tcl_server ($bak_err_msg). Curently connected to $tcl_server_fallback\
									tcl server."
							set tcl_server          $tcl_server_fallback
							set connected_tcl_srv   $tcl_server_fallback
						}
					} else {
						set connected_tcl_srv ""
						keylset returnList status $::FAILURE
						keylset returnList log "ERROR in $procName: Could not connect\
								to tcl_server $tcl_server ($bak_err_msg)"
						return $returnList
					}
				} else {
					set connected_tcl_srv $tcl_server
				}
				set ::ixia::ixtclhal_version [version cget -ixTclHALVersion]
				if {[info exists IXIA_VERSION_bak]} {
					set ::env(IXIA_VERSION)      $IXIA_VERSION_bak
				}
			} 
		}
    } elseif {[info exists tcl_server]} {
                unset tcl_server
		
	}
    # If the IxTclAccess package is available, call their connect to make sure
    # all definitions are in place.  If already connected, it does not hurt
    # to call theirs again.
    if {![catch {package present IxTclAccess} err]} {
        if {[isUNIX]} {
            ixAccessUtil::connectToTclServer $tcl_server err
        }
    }
    
    # This is going to try and set up the tcl server connection so that we
    # can pass entire procedure calls through it to be executed solely on
    # the windows side.  To do this, we will attempt to require the HLT
    # package there.  If it does not require, then everything will just
    # run normally and slowly through the tcl server
    
    if {[info exists tcl_server]} {
        # Prepare the auto_path on the IxTclServer, if necessary.
        if {$hlt_init_flag} {
            ## AppInfo path
            if {![info exists ::ixTclSvrHandle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Not connected to TclServer."
                return $returnList
            }
            set result [::ixia::SendToIxTclServer $::ixTclSvrHandle "set ::backup_auto_path \$::auto_path"]
            if {![info exists ::ixTclSvrHandle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Not connected to TclServer."
                return $returnList
            }
            set result [::ixia::SendToIxTclServer $::ixTclSvrHandle "if { !\[catch { package req registry }\] && \[catch { set ::appinfo_path \[registry get {HKEY_LOCAL_MACHINE\\SOFTWARE\\Ixia Communications\\AppInfo\\InstallInfo} HOMEDIR\] } result\] } { return -1 }"]
            if { $result == -1 } {
                puts "Tcl Server's machine($tcl_server): AppInfo path not found ..."
                puts "Tcl Server's machine($tcl_server): Falling back to any non multi-version HLT API build ..."
            } else {
                if {![info exists ::ixTclSvrHandle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Not connected to TclServer."
                    return $returnList
                }
                set result [::ixia::SendToIxTclServer $::ixTclSvrHandle "set ::appinfo_cmd \[file join \$::appinfo_path appinfo.exe\]"]
    
                ## HLTAPI path
                if {![info exists ::ixTclSvrHandle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Not connected to TclServer."
                    return $returnList
                }
                set result [::ixia::SendToIxTclServer $::ixTclSvrHandle "set cmd \"{\$::appinfo_cmd} --get-regkey --app-name HLTAPI --app-version $::ixia::hltapi_version\""]
                if {![info exists ::ixTclSvrHandle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Not connected to TclServer."
                    return $returnList
                }
                set result [::ixia::SendToIxTclServer $::ixTclSvrHandle "if { \[catch { set ::hltapi_regkey \[eval exec \$cmd\] } regResult\] } { return \$regResult } else { return ok }"]

                if { $result != "ok" } {
                    set strToFind "bad file number"
                    if {[string first $strToFind $result] != -1} {
                        puts "Tcl Server's machine($tcl_server): HLT API $::ixia::hltapi_version path was not retrieved using AppInfo ..."
                        puts "Tcl Server's machine($tcl_server): Tcl Server on the chassis might be the cause ..."
                        puts "Tcl Server's machine($tcl_server): Continue to load Ixia package from existing path ..."
                    }
                } else {
                    if {![info exists ::ixTclSvrHandle]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Not connected to TclServer."
                        return $returnList
                    }
                    set result [::ixia::SendToIxTclServer $::ixTclSvrHandle "if { !\[regsub \"HLTAPI: \" \$::hltapi_regkey \"\" ::hltapi_regkey\] } { return -3 }"]
                    if { $result == -3 } {
                        debug "Tcl Server's machine($tcl_server): HLT API $::ixia::hltapi_version path not found in registry key ..."
                        debug "Tcl Server's machine($tcl_server): Continue to load Ixia package from existing path ..."
                    } else {
                        if {![info exists ::ixTclSvrHandle]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Not connected to TclServer."
                            return $returnList
                        }
                        set result [::ixia::SendToIxTclServer $::ixTclSvrHandle "if { \$::hltapi_regkey != \"\" } { set ::hltapi_path \[registry get \$::hltapi_regkey HOMEDIR\]; source \"\${::hltapi_path}TclScripts\\\\bin\\\\tcl_init.tcl\" }"]
                    }
                }
            }
        }
        # Check the HLT API on the IxTclServer machine
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        if {[catch {::ixia::SendToIxTclServer $::ixTclSvrHandle "set env(IXIA_VERSION) $hltsetUsed"} retError]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to send HLTSET \
                    version to Tcl Server. $retError"
            return $returnList
        }
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        if {![catch {::ixia::SendToIxTclServer $::ixTclSvrHandle {package require Ixia}} retValue]} {
            # Do this to get the Ixia package version, because there were other
            # messages in the previous retValue and this reduces the risk of a
            # mess up in dealing with it
            catch {::ixia::SendToIxTclServer $::ixTclSvrHandle {package present Ixia}} retValue
            set startIndex [string last "\r" $retValue]
            if {$startIndex >= 0} {
                set ixiaVersion [string range $retValue [expr $startIndex + 1] end]
            } else {
                if {[isValidPositiveFloat $retValue]} {
                    set ixiaVersion $retValue
                } else {
                    set ixiaVersion 0.0
                }
            }
            if {$ixiaVersion == $::ixia::hltVersion} {
                puts "Executing HLT API commands on Tcl Server's machine ..."
                set ::ixia::executeOnTclServer 1
            } else {
                puts "Version mismatch between client and Tcl Server's machine ..."
                puts "Executing HLT API commands on local machine ... "
                set ::ixia::executeOnTclServer 0
            }
        } else {
            debug "HLT API not found on Tcl Server's machine ..."
            puts "Executing HLT API commands on local machine ..."
            set ::ixia::executeOnTclServer 0
            if {![info exists ::ixTclSvrHandle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Not connected to TclServer."
                return $returnList
            }
            catch {::ixia::SendToIxTclServer $::ixTclSvrHandle {package require IxAccessGUI}} retValue
        }
    }
    
    
    
    if {$::ixia::executeOnTclServer && [info exists tcl_server] && \
            $::ixia::connected_tcl_srv == $tcl_server} {
        
        # If 'enable_win_tcl_server' exists we don't want to send it to the tcl server (BUG548154)
        set pos [lsearch $args -enable_win_tcl_server]
        if {$pos != -1} {
            set args [lreplace $args $pos $pos] ;# remove -enable_win_tcl_server var
            # remove -enable_win_tcl_server value (it will have $pos index because we already removed
            # enable_win_tcl_server
            set args [lreplace $args $pos $pos] 
        }
        
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        catch {::ixia::SendToIxTclServer $::ixTclSvrHandle "set ::tcl_interactive $::tcl_interactive"}
        lappend $globalVariablesLst session_resume_keys
        foreach globalVariable $globalVariablesLst {
            if {[info exists $globalVariable]} {
                set globalVariableValue [set $globalVariable]
                if {![info exists ::ixTclSvrHandle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Not connected to TclServer."
                    return $returnList
                }
                set commandToSend [format "%s" "::ixia::SendToIxTclServer $::ixTclSvrHandle {set \
                                ::ixia::$globalVariable \"$globalVariableValue\"}"]
                catch {eval $commandToSend} retValue
                debug "$commandToSend"
            }
        }
        foreach globalVariable $globalVariablesArr {
            if {[info exists $globalVariable]} {
                set globalVariableValue [array get $globalVariable]
                set varName "::ixia::$globalVariable"
                if {[string first "::" $globalVariable] == 0} {
                    set varName $globalVariable
                }
                if {![info exists ::ixTclSvrHandle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Not connected to TclServer."
                    return $returnList
                }
                set commandToSend [format "%s" "::ixia::SendToIxTclServer $::ixTclSvrHandle \
                    {array set $varName \"$globalVariableValue\"}"]
                catch {eval $commandToSend} retValue
                debug "$commandToSend"
            }
        }
    
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::legacy_connect $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end] 
            # Temporary fix for BUG697535
            # This fix will enable the creation of two connections to the chassis
            # one established from the local machine and the second from the 
            # tcl_server machine.
            # This is currently needed because when using the Load libraries
            # and the commands are being executed on the tcl_server machine
            # the functions called after the ::ixia::connect fail to execute.
            if {$::ixia::temporary_fix_122311 == 0} { 
                return $retData
            }    
        } else {
            if {$::ixia::temporary_fix_122311 == 0} { 
                return $retValue
            }
        }
    } elseif {[info exists tcl_server] && \
            $::ixia::connected_tcl_srv != $tcl_server && \
            $::ixia::connected_tcl_srv != ""} {
                
        set cleanup true
    }
    
    if {![info exists ::ixia::no_more_tclhal] || $::ixia::no_more_tclhal == 0 } {
    # Set environment variable - this variable needs to be set here(see bug 428510)
		if {[regexp "^HLTSET" $::env(IXIA_VERSION)]} {
			set ixtclhal_list [split [package present IxTclHal]]
			set ::env(IXIA_VERSION) [lindex $ixtclhal_list 0].[lindex $ixtclhal_list 1]
		}
    }
	
    if {![isSetupVportCompatible mode vport_list vport_count]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The virtual ports feature is available only with *NO or\
                *P2NO HLTSET."
        return $returnList
    }
    
    if {![info exists chassis_list] || $cleanup} {
        set chassis_list                    [list]
        set ixload_chassis_list             [list]
        array set master_chassis_array      [list]
        set reserved_port_list              [list]
    }

    # For IxN there all chassis and ports need to be removed when -reset is present
    if {[info exists reset] || ![info exists chassis_list] || $cleanup} {
        set ixnetwork_tcl_server_reset   1
        set ixnetwork_chassis_list  [list]
        array set ixnetwork_master_chassis_array  [list]
        if {[info exists ::ixia::new_ixnetwork_api] && \
             $::ixia::new_ixnetwork_api == 1 && \
            [info exists ::ixia::ixnetwork_port_handles_array] && \
            [info exists ::ixia::ixnetwork_port_handles_array_vport2rp] && \
            [array get ::ixia::ixnetwork_port_handles_array] != ""} {
            
            if {![info exists no_more_tclhal] || $no_more_tclhal == 0} {
                if {[ixLogout]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed logout."
                    return $returnList
                }
            }
            
            foreach objref [array names ::ixia::ixnetwork_port_handles_array_vport2rp] {
                catch {
                    debug "ixNet remove $objref"
                    ixNet remove $objref
                }
            }
            debug "ixNet commit"
            catch {ixNet commit}
            
            set arrays_clearlist {
                ixnetwork_port_handles_array
                ixnetwork_port_names_array
                ixnetwork_real_port_handles_array
                ixnetwork_port_handles_array_vport2rp
                dhcp_globals_params
                dhcp_options_params
                multicast_group_array
                multicast_source_array
                ixnetwork_rp2vp_handles_array
            }
            
            foreach arr $arrays_clearlist {
                catch { array unset ::ixia::$arr }
            }
        }
        array set ::ixia::ixnetwork_port_handles_array ""
        array set ::ixia::ixnetwork_port_handles_array_vport2rp ""
        array set ::ixia::ixnetwork_rp2vp_handles_array ""
    }
    
    # Determine the connect mode we'll use
    #
    # connect_mode         conditions
    # ----------------------------------------------------------------------------------
    # legacy            == +ixos
    #                   == +ixnetwork +device +port_list -vport_list +mode+connect
    #                   == +ixnetwork +device +port_list -vport_list +mode+disconnect
    # connect_vp_rp     == +ixnetwork +device +port_list +vport_list +mode+connect
    # add_vp            == +ixnetwork -device -port_list -vport_list +mode+connect
    # disconnect_vp     == +ixnetwork -device -port_list +vport_list +mode+disconnect
    #
    
    if {[info exists ::ixia::new_ixnetwork_api] && \
             $::ixia::new_ixnetwork_api == 1} {
       
        # +ixnetwork

        # If vport_count is provided device, port_list, vport_list and mode parameters
        # should be ignored.
        if {[info exists vport_count]} {
            catch {unset device}
            catch {unset port_list}
            catch {unset vport_list}
            set mode connect
        }
        
        if {$mode == "reconnect_ports"} {
            keylset returnList status $::SUCCESS
            puts "Releasing all ports and waiting for release to complete..."
            if {[catch {ixNet exec releaseAllPorts} err] || $err != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR: Failed to release ports: $err"
                return $returnList
            }
            
            foreach vport [ixNet getL / vport] {
                for {set i 0} {$i < 30} {incr i} {
                    if {[ixNet getA $vport -isMapped] == "false" || ([ixNet getA $vport -state] != "busy" && [ixNet getA $vport -isConnected] == "false")} {
                        break
                    }
                    after 1000
                }
            }
            puts "Connecting all assigned ports and waiting for port to be usable..."
            ixNet exec connectAllPorts
            set logs [list]
            foreach vport [ixNet getL / vport] {
                for {set i 0} {$i < 30} {incr i} {
                    if {[ixNet getA $vport -isMapped] == "false" || ([ixNet getA $vport -state] != "busy" && [ixNet getA $vport -isConnected] == "true")} {
                        break
                    }
                    if {[ixNet getA $vport -isMapped] == "true" && ([ixNet getA $vport -state] != "busy" && [ixNet getA $vport -isConnected] == "false")} {
                        set msg "Port [ixNet getA $vport -assignedTo] is not connected - [ixNet getA $vport -connectionStatus]"
                        lappend logs $msg 
                        keylset returnList log [join $logs "\n"]
                        keylset returnList status $::FAILURE
                        break
                    }
                    after 1000
                }
            }
            ::ixia::guardrail_info
            return $returnList
        }
        
        if {$mode == "connect"} {
            # +ixnetwork +mode+connect

            if {![info exists vport_list] || [llength $vport_list] < 1} {
                # +ixnetwork -vport_list +mode+connect
                
                if {[info exists device] && [info exists port_list]} {

                    # +ixnetwork +device +port_list -vport_list +mode+connect
                    set connect_mode "legacy"
                    
                } else {
                    # +ixnetwork -device -port_list -vport_list +mode+connect
                    set connect_mode "add_vp"
                }
                
            } else {
                # +ixnetwork +vport_list +mode+connect 

                if {[info exists device] && [info exists port_list]} {
                    
                    # +ixnetwork +device +port_list +vport_list +mode+connect
                    set connect_mode "connect_vp_rp"

                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Mandatory args missing: -device and -port_list."
                    return $returnList
                }
            }
        } else {
            # +ixnetwork +mode+disconnect
            if {![info exists vport_list] || [llength $vport_list] < 1} {
                # +ixnetwork -vport_list +mode+disconnect
                
                if {[info exists device] && [info exists port_list]} {
                    
                    # +ixnetwork +device +port_list -vport_list +mode+disconnect
                    set connect_mode "legacy"

                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Mandatory args missing: -device and -port_list."
                    return $returnList
                }
                
            } else {
                
                # +ixnetwork -device -port_list +vport_list +mode+disconnect
                set connect_mode "disconnect_vp"
                
            }
        }
    } else {
        # +ixos
        set connect_mode "legacy"
    }
    
    # Make sure all parameters are ok depending on the "mode"
    
    switch -- $connect_mode {
        "add_vp" {
            # Nothing to test
        }
        "connect_vp_rp" -
        "disconnect_vp" {
            # Make sure all port handles are valid
            set invalid_vp_hlt_handle_list ""
            foreach vp_hlt_handle [join $vport_list] {
                if {![info exists ::ixia::ixnetwork_port_handles_array($vp_hlt_handle)]} {
                    lappend invalid_vp_hlt_handle_list $vp_hlt_handle
                }
            }
            
            if {[llength $invalid_vp_hlt_handle_list] > 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The following vport handles are\
                        not valid: $invalid_vp_hlt_handle_list."
                return $returnList
            }
            
            # make sure port_list and vport_list have the same structure
            if {$connect_mode == "connect_vp_rp"} {
                set invalid_port_structure 0
                if {[llength $vport_list] != [llength $port_list]} {
                    set invalid_port_structure 1
                }
                
                foreach inner_item $port_list inner_vitem $vport_list {
                    if {[llength $inner_item] != [llength $inner_vitem]} {
                        set invalid_port_structure 1
                    }
                }
                
                if {$invalid_port_structure} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Parameters 'port_list'\
                            'vport_list' must have the same number of elements and the\
                            same structure."
                    return $returnList
                }
            }
        }
        "legacy" {
            if {![info exists device] || ![info exists port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Mandatory args missing: -device and -port_list."
                return $returnList
            }
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Internal error. Unhandled connect_mode $connect_mode."
            return $returnList
        }
    }
    
    if {$connect_mode == "disconnect_vp" || $connect_mode == "connect_vp_rp"} {
        # Disconnect vports here
        set commit_needed 0
        foreach vp_hlt_handle [join $vport_list] {
            set vp_hlt_objref $::ixia::ixnetwork_port_handles_array($vp_hlt_handle)
            
            if {[ixNetworkPortIsConnected $vp_hlt_objref]} {
                # Check if hardware isn't locked
                for {set i 0} {$i < 10} {incr i} {
                    set is_locked [ixNet getA [ixNet getRoot]availableHardware -isLocked]
                    debug "ixNet getA [ixNet getRoot]availableHardware -isLocked --> $is_locked"
                    if {$is_locked == "false"} {
                        break
                    }
                    after 1000
                }
                
                # Release port
                if {[catch {ixNet exec releasePort $vp_hlt_objref} err] || $err != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to release port $vp_hlt_objref.\
                            $err"
                    return $returnList
                }
            }
            
            if {![ixNetworkPortIsDecoupled $vp_hlt_objref]} {
                
                set result [ixNetworkNodeSetAttr $vp_hlt_objref \
                        [list -connectedTo [ixNet getNull]]]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to disconnect\
                            vport $vp_hlt_objref: [keylget result log]"
                    return $returnList
                }
                set commit_needed 1
            }
        }
        
        if {$commit_needed} {
            # Check if hardware isn't locked
            for {set i 0} {$i < 10} {incr i} {
                set is_locked [ixNet getA [ixNet getRoot]availableHardware -isLocked]
                debug "ixNet getA [ixNet getRoot]availableHardware -isLocked --> $is_locked"
                if {$is_locked == "false"} {
                    break
                }
                after 1000
            }
            
            if {[set retCode [ixNet commit]] != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to disconnect vports. $retCode"
                return $returnList
            }
        }
        
        if {$connect_mode == "disconnect_vp"} {
            
            set ret_code [ixNetworkBuildRp2VpArray]
            if {[keylget ret_code status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: [keylget ret_code log]"
                return $returnList
            }
            
            # For disconnect exit here!
            
            keylset returnList vport_list [join $vport_list]
            keylset returnList status $::SUCCESS
            return $returnList
        }
    }
    
    # Check mandatory args to see if we will be handling multiple devices, verify
    # that there are sufficient port lists for each device, if not, exit.
    if {$connect_mode == "legacy" || $connect_mode == "connect_vp_rp"} {
        if {[llength $device] > 1} {
            if {[llength $device] != [llength $port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The number of devices\
                        and the number of port_lists are not equal."
                return $returnList
            }
        }
        
        set device_ip_address [list]
        # Check and convert any names to ip addresses in the device list
        foreach single_device $device {
            if {[isIpAddressValid $single_device]} {
                lappend device_ip_address $single_device
            } else {
                if {[info exists _device($single_device)]} {
                    if {[isIpAddressValid $_device($single_device)]} {
                        lappend device_ip_address $_device($single_device)
                        keylset ::ixia::ips_to_hosts $_device($single_device) $single_device
                        keylset ::ixia::hosts_to_ips $single_device $_device($single_device)
                        keylset ::ixia::chassis_chain device.$single_device.host $single_device
                        keylset ::ixia::chassis_chain device.$single_device.ip $_device($single_device)
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: An invalid IP\
                                address was found for $single_device in _device"
                        return $returnList
                    }
                } elseif {[catch {set ip_list [host_info addresses $single_device]} err]\
                        || $ip_list == ""} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Could not get\
                            $single_device IP addresses. DNS query returned: $err"
                    return $returnList
                } else {
                    set _device($single_device) [lindex $ip_list 0]
                    lappend device_ip_address $_device($single_device)
                    keylset ::ixia::ips_to_hosts $_device($single_device) $single_device
                    keylset ::ixia::hosts_to_ips $single_device $_device($single_device)
                    keylset ::ixia::chassis_chain device.$single_device.ip $single_device
                    keylset ::ixia::chassis_chain device.$single_device.host $_device($single_device)
                }
            }
        }
        
        # Check and convert any names to ip addresses in the master device list
        keylset ::ixia::chassis_chain master_device_iterator [list]
        if {[info exists master_device]} {
            set master_device_iterator [list]
            foreach single_device $master_device {
                if {$single_device == "none"} {
                    lappend master_device_ip_address $single_device
                } elseif {[isIpAddressValid $single_device]} {
                    set _device($single_device) $single_device
                    lappend master_device_ip_address $single_device
                    lappend master_device_iterator $single_device
                    keylset master_ips_to_hosts $_device($single_device) $single_device
                    keylset ::ixia::chassis_chain master_device.$single_device.host $_device($single_device)
                    keylset ::ixia::chassis_chain master_device.$single_device.ip $single_device
                } else {
                    if {[info exists _device($single_device)]} {
                        if {[isIpAddressValid $_device($single_device)]} {
                            lappend master_device_ip_address $_device($single_device)
                            lappend master_device_iterator $single_device
                            keylset master_ips_to_hosts $_device($single_device) $single_device
                            keylset ::ixia::chassis_chain master_device.$single_device.ip $_device($single_device)
                            keylset ::ixia::chassis_chain master_device.$single_device.host $single_device
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: An invalid IP\
                                    address was found for $single_device in _device"
                            return $returnList
                        }
                    } elseif {[catch {set ip_list [host_info addresses $single_device]}]\
                            || $ip_list == ""} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: $single_device cannot be resolved by DNS - $ip_list "
                        return $returnList
                    } else {
                        set _device($single_device) [lindex $ip_list 0]
                        lappend master_device_ip_address $_device($single_device)
                        lappend master_device_iterator $single_device
                        keylset master_ips_to_hosts $_device($single_device) $single_device
                        keylset ::ixia::chassis_chain master_device.$single_device.host $_device($single_device)
                        keylset ::ixia::chassis_chain master_device.$single_device.ip $single_device
                    }
                }
            }
            keylset ::ixia::chassis_chain master_device_iterator [lsort -unique $master_device_iterator]
        }
    }
    # Put back the login in place for both IxTclNetwork and IxTclHal because of BUG488219   
    if {![info exists no_more_tclhal] || $no_more_tclhal == 0} {
        ixLogin $username
    }
    
    set session_owner_tclhal $username
    
    if {$connect_mode == "legacy" || $connect_mode == "connect_vp_rp"} {

        # Need to see if any of the chassis are already connected, no need to repeat
        # Also have to find out the next chassis id to use.
        set next_chassis_id [get_valid_chassis_id [expr [llength $chassis_list]]]
        set chassis_to_add              ""
        set ixnetwork_chassis_to_add    ""
        set chassis_ids                 ""
        set ixnetwork_chassis_ids       ""
        set chassis_cables              ""
        set local_ixnetwork_chassis_ids ""
        
        set ch_index 0
        foreach chassis $device_ip_address {
            set ixos_index [lsearch -regexp $chassis_list           $chassis]
            set ixn_index  [lsearch -regexp $ixnetwork_chassis_list $chassis]
            if {$ixos_index < 0} {
                lappend chassis_to_add           $chassis
                lappend chassis_cables           cable3feet
                lappend chassis_ids              $next_chassis_id
                if {[info exists master_device]} {
                    set master_chassis_array($next_chassis_id) [lindex $master_device_ip_address $ch_index]
                }
            }
            if {$ixn_index < 0} {
                catch {unset ixn_next_chassis_id }
                # BUG531800 - clearing errorInfo - "COSMETIC ISSUE"
                set ::errorInfo ""
                #
                if {$ixos_index < 0} {
                    set ixn_next_chassis_id $next_chassis_id
                } else {
                    set ixn_next_chassis_id [lindex [lindex $chassis_list $ixos_index] 1]
                }
                lappend ixnetwork_chassis_to_add $chassis
                lappend ixnetwork_chassis_ids    $ixn_next_chassis_id
    
                lappend local_ixnetwork_chassis_ids $ixn_next_chassis_id
                if {[info exists master_device]} {
                    set ixnetwork_master_chassis_array($ixn_next_chassis_id) [lindex $master_device_ip_address $ch_index]
                }
            } else {
                lappend local_ixnetwork_chassis_ids [get_valid_chassis_id $ixn_index]
            }
            if {$ixos_index < 0} {
                incr next_chassis_id
            }
            incr ch_index
        }
    
        catch {set ::ixErrorInfo ""}
        if {![info exists no_more_tclhal] || $no_more_tclhal == 0} {
            if {[connectToChassis $chassis_to_add $chassis_cables $chassis_ids]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error connecting to\
                        chassis $chassis_to_add. $::ixErrorInfo"
                return $returnList
            }
        }
        
        foreach chassis $chassis_to_add id $chassis_ids {
            lappend chassis_list            [list $chassis $id]
            lappend ixload_chassis_list     [list $id $chassis]
        }
        
        foreach chassis $ixnetwork_chassis_to_add id $ixnetwork_chassis_ids {
            lappend ixnetwork_chassis_list  [list $id $chassis]
        }
    
        # Create list of chassis ids
        if {![info exists no_more_tclhal] || $no_more_tclhal == 0} {
            set chassis_ids {}
            set vm_ports_detected 0
            foreach device $device_ip_address {
                if {![chassis get $device]} {
                    lappend chassis_ids [chassis cget -id]
                    # detect if chassis is IxVM (ixVM does not have pcpu so 
                    # if IxVM is found we wont reset port filters to avoid
                    # ixOS error).
                    if {$vm_ports_detected == 0} {
                        # IxVM chassis has the id 24
                        set vm_ports_detected [expr [chassis cget -type] == 24]
                    }
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failure to get chassis\
                            id for $device after connection"
                    return $returnList
                }
            }
        } else {
            set chassis_ids $local_ixnetwork_chassis_ids
        }
        
        # If only one device, then the port list needs a little special attention
        if {[llength $chassis_ids] == 1} {
            set port_list [list $port_list]
            if {$connect_mode == "connect_vp_rp"} {
                set vport_list [list $vport_list]
            }
        }
    
        set list_index 0
        set port_count 0
        set port_handle_list [list]
        set spaced_port_handle_list [list]
        catch {array unset cp2vp_array}
        array set cp2vp_array ""
        
        foreach id $chassis_ids {
            set this_port_list  [lindex $port_list         $list_index]
            set this_device     [lindex $device_ip_address $list_index]
            set this_chassis_id [lindex $chassis_ids       $list_index]
            
            if {$connect_mode == "connect_vp_rp"} {
                set this_vport_list [lindex $vport_list    $list_index]
            } else {
                set this_vport_list [lindex $port_list     $list_index]
            }
    
            incr port_count [llength $this_port_list]
    
            # Return the port handle list to the user
            foreach port $this_port_list vport $this_vport_list {
                
                regsub -all {/} $port " " port
                scan $port "%d %d" card_id port_id
                
                if {$connect_mode == "connect_vp_rp"} {
                    scan $vport "%d/%d/%d" vchassis_id vcard_id vport_id
                } else {
                    foreach {vchassis_id vcard_id vport_id} \
                            [split [ixNetworkGetNextVportHandle $this_chassis_id/$card_id/$port_id] /] {}
                }
                set cp2vp_array($this_chassis_id/$card_id/$port_id) $vchassis_id/$vcard_id/$vport_id
                
                # Do not add any ports to the reserved list if we are not breaking
                # locks and they are not available
                if {$break_locks} {
                    if {[lsearch $reserved_port_list \
                                [list $vchassis_id $vcard_id $vport_id]] == -1} {
    
                        lappend reserved_port_list \
                                [list $vchassis_id $vcard_id $vport_id]
                    }
                    if {[lsearch $port_handle_list \
                                $this_chassis_id/$card_id/$port_id] == -1} {
    
                        lappend port_handle_list "$this_chassis_id/$card_id/$port_id"
                        lappend spaced_port_handle_list "$this_chassis_id $card_id $port_id"
                    }
                } else {
                    if {![info exists no_more_tclhal] || $no_more_tclhal == 0} {
                        if {![ixCheckOwnership [list [list $this_chassis_id $card_id \
                                $port_id]]]} {
        
                            if {[lsearch $reserved_port_list [list \
                                        $vchassis_id $vcard_id $vport_id]] == -1} {
        
                                lappend reserved_port_list \
                                        [list $vchassis_id $vcard_id $vport_id]
                            }
                            if {[lsearch $port_handle_list \
                                        $this_chassis_id/$card_id/$port_id] == -1} {
        
                                lappend port_handle_list "$this_chassis_id/$card_id/$port_id"
                                lappend spaced_port_handle_list "$this_chassis_id $card_id $port_id"
                            }
                        }
                    } else {
                        
                        if {[lsearch $reserved_port_list [list \
                                    $vchassis_id $vcard_id $vport_id]] == -1} {
    
                            lappend reserved_port_list \
                                    [list $vchassis_id $vcard_id $vport_id]
                        }
                        if {[lsearch $port_handle_list \
                                    $this_chassis_id/$card_id/$port_id] == -1} {
    
                            lappend port_handle_list "$this_chassis_id/$card_id/$port_id"
                            lappend spaced_port_handle_list "$this_chassis_id $card_id $port_id"
                        }
                    }
                }
            }
    
            if {[info exists config_file] && (![info exists no_more_tclhal] || $no_more_tclhal == 0)} {
                
                if {[chassis import $config_file $this_device]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: chassis import\
                         $config_file to $this_device - $::ixErrorInfo"
                    return $returnList
                } else {
                    chassis get $this_device
                    chassis config -id [lindex $chassis_ids [lsearch \
                            $device_ip_address $this_device ]]
                    chassis set $this_device
                    ixWritePortsToHardware spaced_port_handle_list
                    after 1000
                    ixCheckLinkState spaced_port_handle_list
                }
            }
    
            incr list_index
        }

        
        
        if {$connect_mode == "legacy"} {
            if {![info exists new_ixnetwork_api] || !$new_ixnetwork_api} {
                # Put card in aggregated mode
                if {[info exists aggregation_mode]} {
                    set agg_mode_status [set_aggregated_mode $port_handle_list]
                    if {[keylget agg_mode_status status] != $::SUCCESS} {
                        return $agg_mode_status
                    }
                }
                if {[info exists aggregation_resource_mode]} {
                    set agg_resource_mode_status [set_aggregation_resource_mode $port_handle_list]
                    if {[keylget agg_resource_mode_status status] != $::SUCCESS} {
                        return $agg_resource_mode_status
                    }
                }
            }
            
            foreach port $port_handle_list {
                foreach {chassis_id card_id port_id} [split $port /] {}
                set index_value [lsearch -exact $chassis_ids $chassis_id]
                set device [lindex $device_ip_address $index_value]

                keylset returnList port_handle.$device.${card_id}/${port_id} \
                        $cp2vp_array($port)
                        
                # If we kept a host name for the ip, save using that also
                if {![catch {keylget ::ixia::ips_to_hosts $device} hostname]} {
                    keylset returnList port_handle.$hostname.${card_id}/${port_id} \
                            $cp2vp_array($port)
                }
            }
        } else {
            foreach port $port_handle_list vport [join $vport_list] {
                
                foreach {chassis_id card_id port_id} [split $port /] {}
                foreach {vch vca vpo} [split $vport /] {}
                
                set index_value [lsearch -exact $chassis_ids $chassis_id]
                set device [lindex $device_ip_address $index_value]
                keylset returnList port_handle.$device.${card_id}/${port_id} \
                        "${vch}/${vca}/${vpo}"
                # If we kept a host name for the ip, save using that also
                if {![catch {keylget ::ixia::ips_to_hosts $device} hostname]} {
                    keylset returnList port_handle.$hostname.${card_id}/${port_id} \
                            "${vch}/${vca}/${vpo}"
                }
            }
        }
        
        
        
        
        
        if {$port_count > 0} {
            if {$break_locks} {
                set force force
            } else {
                set force notForce
            }
            
            if {([info exists new_ixnetwork_api] && $new_ixnetwork_api ) && \
                    ![info exists reset]} {
                set list_to_clear_owner [list]
                foreach port_id $spaced_port_handle_list {
                    set slashed_port [regsub -all " " [string trim $port_id] "/"]
                    set slashed_vport $cp2vp_array($slashed_port)
                    if {[lsearch [array names ixnetwork_port_handles_array]\
                            $slashed_vport] == -1} {
                        lappend list_to_clear_owner $port_id
                    }
                }
                set spaced_port_handle_list $list_to_clear_owner
            }
    
            if {([llength $spaced_port_handle_list] > 0) && (![info exists no_more_tclhal] || $no_more_tclhal == 0)} {
            
                if {[ixTakeOwnership $spaced_port_handle_list $force]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to take\
                            ownership within this port list: $spaced_port_handle_list"
                    ixClearOwnership $spaced_port_handle_list
                    return $returnList
                }
                # Workaround for IxTracker 410569
                set retries 10
                while {[ixCheckOwnership $spaced_port_handle_list] && ($retries > 0)} {
                    if {[ixTakeOwnership $spaced_port_handle_list $force]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Failed to take\
                                ownership within this port list: $spaced_port_handle_list"
                        ixClearOwnership $spaced_port_handle_list
                        return $returnList
                    }
                    incr retries -1
                }
                if {[ixCheckOwnership $spaced_port_handle_list]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to take\
                            ownership within this port list: $spaced_port_handle_list"
                    ixClearOwnership $spaced_port_handle_list
                    return $returnList
                }
            }
            
            if {[info exists reset]} {
                if {![info exists no_more_tclhal] || $no_more_tclhal == 0} {
                    if {[llength $spaced_port_handle_list] > 0} {
                        
                        if {$vm_ports_detected == 0} {
                        
                            debug "::ixia::reset_filters $spaced_port_handle_list"
                            reset_filters $spaced_port_handle_list
                        } else {
                            puts "WARNING: IxVM ports detected. Some operations might take longer\
                                    time to complete."
                        }
                        set_factory_defaults    $spaced_port_handle_list
                        reset_port_config       $spaced_port_handle_list
                    }
        
                    # If resetting, need to clear out any port stream pgid values
                    foreach port $spaced_port_handle_list {
                        foreach {chassis_id card_id port_id} $port {}
                        foreach pgid [array names ::ixia::pgid_to_stream] {
                            foreach {chassis_num card_num port_num stream_num} \
                                    [split $::ixia::pgid_to_stream($pgid) ,] {}
                            if {($chassis_num == $chassis_id) && \
                                    ($card_num == $card_id) && \
                                    ($port_num == $port_id)} {
                                catch {array unset ::ixia::pgid_to_stream $pgid}
                                catch {unset ::ixia::stream_to_queue_map($pgid)}
                                catch {unset ::ixia::port_queue_num(${chassis_num},${card_num},${port_num})}
                            }
                        }
        
                        # Need to clear out all protocol and routing interfaces
                        port get $chassis_id $card_id $port_id
        
                        catch {interfaceTable select $chassis_id $card_id $port_id }
                        catch {interfaceTable clearAllInterfaces }
                        catch {bgp4Server   select $chassis_id $card_id $port_id }
                        catch {bgp4Server   clearAllNeighbors }
                        catch {igmpVxServer select $chassis_id $card_id $port_id }
                        catch {igmpVxServer clearAllHosts }
                        catch {isisServer   select $chassis_id $card_id $port_id }
                        catch {isisServer   clearAllRouters }
                        catch {lacpServer   select $chassis_id $card_id $port_id }
                        catch {lacpServer   clearAllLinks }
                        catch {ldpServer    select $chassis_id $card_id $port_id }
                        catch {ldpServer    clearAllRouters }
                        catch {mldServer    select $chassis_id $card_id $port_id }
                        catch {mldServer    clearAllHosts }
                        catch {ospfServer   select $chassis_id $card_id $port_id }
                        catch {ospfServer   clearAllRouters }
                        catch {ospfV3Server select $chassis_id $card_id $port_id }
                        catch {ospfV3Server clearAllRouters }
                        catch {pimsmServer  select $chassis_id $card_id $port_id }
                        catch {pimsmServer  clearAllRouters }
                        catch {ripServer    select $chassis_id $card_id $port_id }
                        catch {ripServer    clearAllRouters }
                        catch {ripngServer  select $chassis_id $card_id $port_id }
                        catch {ripngServer  clearAllRouters }
                        catch {rsvpServer   select $chassis_id $card_id $port_id }
                        catch {rsvpServer   clearAllNeighborPair }
                    }
                    catch {set ::ixia::gateway_list [list]}
                    catch {unset ixn_traffic_version}
    
                    if {[llength $spaced_port_handle_list] > 0} {
                        ixWritePortsToHardware spaced_port_handle_list
                    }
                    # Clean up ixAccess
                    catch {ixAccessCleanupPorts $spaced_port_handle_list}
        
                    # Set the port into advanced TX mode and PG mode if possible.
                    foreach port $spaced_port_handle_list {
                        scan $port "%d %d %d" chassis_id card_id port_id
        
                        port setTransmitMode portTxModeAdvancedScheduler \
                                $chassis_id $card_id $port_id
                        port setReceiveMode  portPacketGroup \
                                $chassis_id $card_id $port_id
                    }
        
                    if {[llength $spaced_port_handle_list] > 0} {
                        ixWritePortsToHardware spaced_port_handle_list
                    }
                } else {
                    
                    # If resetting, need to clear out any port stream pgid values
                    foreach port $spaced_port_handle_list {
                        foreach {chassis_id card_id port_id} $port {}
                        foreach pgid [array names ::ixia::pgid_to_stream] {
                            foreach {chassis_num card_num port_num stream_num} \
                                    [split $::ixia::pgid_to_stream($pgid) ,] {}
                            if {($chassis_num == $chassis_id) && \
                                    ($card_num == $card_id) && \
                                    ($port_num == $port_id)} {
                                catch {array unset ::ixia::pgid_to_stream $pgid}
                                catch {unset ::ixia::stream_to_queue_map($pgid)}
                                catch {unset ::ixia::port_queue_num(${chassis_num},${card_num},${port_num})}
                            }
                        }
                        
                        # reset protocols
                        set ret_val [::ixia::reset_protocol_interface_for_port \
                                -port_handle "$chassis_id/$card_id/$port_id"]
                        if {[keylget ret_val status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    Resetting ports $port failed (::ixia::reset_protocol_interface_for_port)"
                            return $returnList
                        }
                    }
                    
                    # Need to clear out all protocol and routing interfaces
                    catch {set ::ixia::gateway_list [list]}
                    catch {unset ixn_traffic_version}
                }
            }
    
            # Start with a clean set of statistics
            if {![info exists no_more_tclhal] || $no_more_tclhal == 0} {
                if {![info exists list_to_clear_owner] && \
                        ([llength $spaced_port_handle_list] > 0) && \
                        [ixClearStats spaced_port_handle_list]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Clearing stats on ports\
                            $spaced_port_handle_list failed."
                    return $returnList
                }
            
            
                # Start packet groups on the ports so that per stream stats will be
                # available if the user does not call control for clear_stats or
                # sync_run
                debug "ixStartPacketGroups $spaced_port_handle_list"
                if {![info exists list_to_clear_owner] && \
                        ([llength $spaced_port_handle_list] > 0) && \
                        [catch {ixStartPacketGroups spaced_port_handle_list} errMsg]} {
                    ixPuts "Warning on $procName: Could not start PGID retrieval \
                            on ports $spaced_port_handle_list. $errMsg"
                }
            }
        }
        
        if {![info exists no_more_tclhal] || $no_more_tclhal == 0} {
            if {$sync && ![info exists list_to_clear_owner] && \
                    ([llength $spaced_port_handle_list] > 0)} {
                if {[ixClearTimeStamp spaced_port_handle_list]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Clearing timestamps on\
                            ports $spaced_port_handle_list failed."
                    return $returnList
                }
            }
        }
        
        
        if {![info exists no_more_tclhal] || $no_more_tclhal == 0} {
            foreach port $spaced_port_handle_list {
                # Construct keyed list for ::ixia::portSupports
                foreach {chassis_id card_id port_id} $port {}
                if {[catch {keylget port_supports_types ${chassis_id}/${card_id}/${port_id}}]} {
                    if {[port get $chassis_id $card_id $port_id] == $::TCL_OK} {
                        keylset port_supports_types ${chassis_id}/${card_id}/${port_id}.portIndex \
                                [port cget -type]
                        keylset port_supports_types ${chassis_id}/${card_id}/${port_id}.portName \
                                [port cget -typeName]
                    }
                }
            }
        }
    }
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        
        # Establish ixnetwork connection
        set retCode [checkIxNetwork]
        if {[keylget retCode status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Unable to connect to IxNetwork - \
                    [keylget retCode log]"
            return $returnList
        } else {
            set _conToken $conToken
            #puts "_conToken: $_conToken"
            set return_code [::ixia::connection_key_builder $_conToken]
            #puts "return_code: $return_code"
            keylset returnList connection $return_code            
        }

        
        # handle GuardRail option for statistics
        regexp {^(\d.\d)} $::ixia::ixnetworkVersion ixn_version
        if {[info exists guard_rail] && ($ixn_version >= 6.30)} {
            array set guard_rail_array {
                none            false
                statistics      true
            }
            ixNet setAttr [ixNet getRoot]statistics -guardrailEnabled $guard_rail_array($guard_rail)
        }
        
        switch -- $connect_mode {
            "add_vp" {
                
                debug "Multiple Ports Add" mpa_tag0
                set return_status [ixNetworkMultiplePortsAdd $vport_count "add_vp" force]
                if {[keylget return_status status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "[keylget return_status log]"
                    return $returnList
                }
                debug "Multiple Ports Add" mpa_tag0

                if {[info exists reset]} {
                    foreach port [keylget return_status vport_list] {
                        regexp {([0-9]+)/([0-9]+)/([0-9]+)} $port match_str chassis_id card_id port_id
                        foreach pgid [array names ::ixia::pgid_to_stream] {
                            foreach {chassis_num card_num port_num stream_num} \
                                    [split $::ixia::pgid_to_stream($pgid) ,] {}
                            if {($chassis_num == $chassis_id) && \
                                    ($card_num == $card_id) && \
                                    ($port_num == $port_id)} {
                                catch {array unset ::ixia::pgid_to_stream $pgid}
                                catch {unset ::ixia::stream_to_queue_map($pgid)}
                                catch {unset ::ixia::port_queue_num(${chassis_num},${card_num},${port_num})}
                            }
                        }
                        
                        set ret_val [::ixia::reset_protocol_interface_for_port \
                                -port_handle "$chassis_id/$card_id/$port_id"]
                        if {[keylget ret_val status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    Resetting ports $port failed (::ixia::reset_protocol_interface_for_port)"
                            return $returnList
                        }
                    }
                    
                    # Need to clear out all protocol and routing interfaces
                    set ::ixia::gateway_list [list]
                    catch {unset ixn_traffic_version}
                }
                keylset returnList vport_list [keylget return_status vport_list]
            }
            "legacy" {
                debug "Multiple Ports Add" mpa_tag0
                set return_status [ixNetworkMultiplePortsAdd $port_handle_list "legacy" force]
                if {[keylget return_status status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "[keylget return_status log]"
                    return $returnList
                }
                debug "Multiple Ports Add" mpa_tag0
                set ret_vport_list ""
                foreach port $port_handle_list {
                    lappend ret_vport_list $cp2vp_array($port)
                }
                keylset returnList vport_list $ret_vport_list
            }
            "connect_vp_rp" {
                debug "Multiple Ports Add" mpa_tag0
                set return_status [ixNetworkMultiplePortsAdd $port_handle_list [join $vport_list] force]
                if {[keylget return_status status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "[keylget return_status log]"
                    return $returnList
                }
                debug "Multiple Ports Add" mpa_tag0
                keylset returnList vport_list [join $vport_list]
                
            }
        }
        # ENH685139: HLTAPI: ixia::connect needs to return the ixNet protocols object handle
        set protocol_handle ""
        set vm_ports_detected 0
		set pineflag_detected 0
        if {[info exists port_handle_list]} {
            foreach prot_obj $port_handle_list {
                if {[info exists ixnetwork_port_handles_array(${prot_obj})]} {
                    set prot_obj $ixnetwork_port_handles_array(${prot_obj})
                    lappend protocol_handle ${prot_obj}/protocols
                } else {
                    set prot_obj $ixnetwork_real_port_handles_array(${prot_obj})
                    lappend protocol_handle ${prot_obj}/protocols
                }
                
            }
        }
        foreach prot_obj [array names ixnetwork_port_handles_array_vport2rp] {
            if {[lsearch $protocol_handle ${prot_obj}/protocols] == -1 } {
                lappend protocol_handle ${prot_obj}/protocols
            }
            # Once a port is detected as VM we do not check for the rest of the ports
            # to minimize the IxNet calls
            if {($vm_ports_detected == 0) && ([ixNet getA $prot_obj  -isVMPort] == true)} {
                set vm_ports_detected 1
            }
			if {($pineflag_detected == 0) && ([ixNet getA $prot_obj  -isDirectConfigModeEnabled] == true)} {
                set pineflag_detected 1
            }
        }
        keylset returnList vport_protocols_handle $protocol_handle
        
        if {$vm_ports_detected == 1} {
            puts "WARNING: IxVM ports detected. Some operations might take longer\
                    time to complete."
        }
        
		if {$pineflag_detected == 1} {
		    puts "Warning! Port CPU Traffic configuration detected. IxTclHal API is disabled in this mode.\
				Some high level operations depending on IxTclHal might fail.\
				Please reconnect ports in order to disable this feature and restore IxTclHal functionality"
        }
        
        set ret_code [ixNetworkBuildRp2VpArray]
        if {[keylget ret_code status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: [keylget ret_code log]"
            return $returnList
        }
        set return_code [::ixia::guardrail_info]
        if {[keylget return_code status] == $::SUCCESS} {
            keylset returnList guardrail_messages [keylget return_code guardrail_messages]    
        }
    }
    
    if {[info exists warning_message_return]} {
        keylset returnList log $warning_message_return
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::legacy_cleanup_session { args } {
    variable executeOnTclServer
    variable pending_operations
    variable temporary_fix_122311
    variable ixnetwork_port_handles_array
    variable chassis_list
    variable current_streamid
    variable pgid_to_stream
    variable new_ixnetwork_api
    variable ixNetworkChassisConnected
    variable no_more_tclhal
    variable ixnetwork_rp2vp_handles_array
    variable clear_csv_stats

    set procName {::ixia::cleanup_session}
    
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer && $::ixia::temporary_fix_122311 != 2} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::legacy_cleanup_session $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args

    set opt_args {
        -port_handle                     REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -maintain_lock                   CHOICES 0 1
        -clear_csv                       CHOICES 0 1
        -skip_wait_pending_operations    FLAG
        -reset                           FLAG
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args} \
            parseError]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName:\
                Failed on parsing: $parseError."
        return $returnList
    }
    
    # unset all the arrays used in the traffic_stats procedure
    if {[info exists reset]} {
        ::ixia::cleanupTrafficStatsArrays
    }
    
    if {[info exists new_ixnetwork_api] && ($new_ixnetwork_api == 1)} {
        if {[info exists ixNetworkChassisConnected] && \
                ($ixNetworkChassisConnected == $::SUCCESS)} {
            foreach {hnd obj_ref} [array get ixnetwork_port_handles_array] {
                
                # Get pppox handle, if any and call pppox_control -mode reset
                set pppox_rst_status [ixnetwork_pppox_reset $obj_ref]
                if {[keylget pppox_rst_status status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to cleanup session.\
                            [keylget pppox_rst_status log]"
                    return $returnList
                }
                
                if {[info exists reset]} {
                    # Set to factory defaults only if the virtual port si connected
                    # to a real port
                    if {[ixNet getAttribute $obj_ref -isConnected] == "true"} {
                        debug "ixNet exec setFactoryDefaults $obj_ref"
                        ixNet exec setFactoryDefaults $obj_ref
                        set skip_factory_defaults_tclhal 1
                    }
                }
                
                if {[info exists maintain_lock] && !$maintain_lock} {
                    debug "ixNet exec releasePort $obj_ref"
                    ixNet exec releasePort $obj_ref
                    debug "ixNet remove $obj_ref"
                    if {[catch {ixNet remove $obj_ref} err]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                Failed to remove port $hnd."
                        return $returnList
                    }
                }
            }
            debug "ixNet -timeout 0 commit"
            if {([catch {ixNet -timeout 0 commit} commitErr]) || ($commitErr != "::ixNet::OK")} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        Failed to remove ports [array names\
                        ixnetwork_port_handles_array]. $commitErr"
                return $returnList
            }
            set remove_chassis_list [ixNet getList [ixNet getRoot]availableHardware chassis]
            # BUG531248
            # foreach remove_chassis_elem $remove_chassis_list {
            #     debug "ixNet remove $remove_chassis_elem"
            #     if {[catch {ixNet remove $remove_chassis_elem} err]} {
            #         keylset returnList status $::FAILURE
            #         keylset returnList log "ERROR in $procName:\
            #                 Failed to remove chassis $remove_chassis_elem."
            #         return $returnList
            #     }
            # }
            # debug "ixNet -timeout 0 commit"
            # if {([catch {ixNet -timeout 0 commit} commitErr]) || ($commitErr != "::ixNet::OK")} {
            #     keylset returnList status $::FAILURE
            #     keylset returnList log "ERROR in $procName:\
            #             Failed to remove chassis list $remove_chassis_list."
            #     return $returnList
            # }
        }
        if {[info exists reset]} {
            catch {
                if {[ixNet exists ::ixNet::OBJ-/traffic/splitPgidSettings] == "true"} {
                    foreach setting_obj [ixNet getL ::ixNet::OBJ-/traffic/splitPgidSettings setting] {
                        set tmp_out [ixNet remove $setting_obj]
                        debug "ixNet remove $setting_obj --> $tmp_out"
                    }
                    set tmp_out [ixNet commit]
                    debug "ixNet remove $setting_obj; commit --> $tmp_out"
                }
            } tmp_out
            debug "Split PGID Cleanup returned --> $tmp_out"
            catch {ixNet exec newConfig} tmp_out
            debug "ixNet exec newConfig returned --> $tmp_out"
        }
        
        if {![info exists no_more_tclhal] || $no_more_tclhal == 0} {
            if {[ixLogout]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed logout."
                return $returnList
            }
        }
        
        debug "ixNet disconnect $::ixia::ixnetwork_tcl_server"
        if {[catch {ixNet disconnect $::ixia::ixnetwork_tcl_server} discError] || \
                (($discError != "::ixNet::OK") && \
                ($discError != "not connected"))} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName:\
                    Failed to disconnect from IxNetwork Tcl Server\
                    $::ixia::ixnetwork_tcl_server."
            return $returnList
        }
        if {[info exists clear_csv] && $clear_csv == 1} {
            foreach csv_item [array names ::ixia::clear_csv_stats] {
                file delete -force $csv_item
                file delete -force ${csv_item}.columns
            }
        }
        set ixnetwork_variables {ixNetworkChassisConnected ixnetwork_chassis_list \
            ixnetwork_tcl_server ixnetwork_tcl_server_reset ixn_traffic_version \
            tcl_proxy_username close_server_on_disconnect}
        foreach ixnetwork_variable $ixnetwork_variables {
            catch {unset ::ixia::$ixnetwork_variable}
        }
        set arrays_clearlist {
            ixnetwork_port_handles_array
            ixnetwork_port_handles_array_vport2rp
            dhcp_globals_params
            dhcp_options_params
            multicast_group_array
            multicast_source_array
            ixnetwork_rp2vp_handles_array
        }
        foreach arr $arrays_clearlist {
            catch {    array unset ::ixia::$arr }
        }
    }

    if {![info exists skip_wait_pending_operations] && \
            [info exists pending_operations] && [array get pending_operations] != ""} {
        set op_status [::ixia::wait_pending_operations]
        if {[keylget op_status status] != $::SUCCESS} {
            set operationError [keylget op_status log]
        }
    }
    # reset the streamid
    set current_streamid 0
    catch {array unset pgid_to_stream}
    set pgid_to_stream(-1) {0,0,0,0}

    if {!([info exists new_ixnetwork_api] && ($new_ixnetwork_api == 1)) && \
            [info exists port_handle] && [info exists chassis_list]} {
        regsub -all {([0-9]+)/[0-9]+/[0-9]+} $port_handle {\1} chassis_ids
        set chassis_ids [lsort -unique $chassis_ids]
        set chassis_list_id {}
        foreach chassis_item $chassis_list {
            lappend chassis_list_id [lindex $chassis_item 1]
        }
        foreach {ch_id1} $chassis_ids {
            if {[lsearch $chassis_list_id $ch_id1] == -1 } {
                regsub -all "$ch_id1/\[0-9\]+/\[0-9\]+" $port_handle {} \
                    port_handle
            }
        }
        set port_list [format_space_port_list $port_handle]
        
        if {[info exists reset] && (![info exists no_more_tclhal] || $no_more_tclhal == 0)} {
            
            debug "::ixia::reset_filters $port_list"
            reset_filters $port_list
        
            set retCode [updatePatternMismatchFilter $port_list "reset"]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName:\
                        [keylget retCode log]"
                return $returnList
            }
            
            foreach port $port_list {
                # Call reset procedure for ixaccess
                foreach {tmpCh tmpCa tmpPo} $port {}
                debug "set rstStatus \[::ixia::ixaccess_reset_traffic $tmpCh $tmpCa $tmpPo\]"
                set rstStatus [::ixia::ixaccess_reset_traffic $tmpCh $tmpCa $tmpPo]
                if {[keylget rstStatus status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName:\
                            [keylget rstStatus log]"
                    return $returnList
                }  
                catch {ixAccessCleanupPorts [list $port]}
                debug "ixAccessCleanupPorts [list $port]"
            }
            
            if {[info exists reset]} {
                
                foreach command [list set_factory_defaults reset_port_config] {
                    set ret_val_status [$command $port_list write]
                    if {[keylget ret_val_status status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Setting\
                                ports $port_list to factory defaults failed. \
                                [keylget ret_val_status log]"
                        return $returnList
                    }
                }
            }
            
            if {[info exists maintain_lock] && !$maintain_lock} {
                if {[ixClearOwnership $port_list]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Unable to clear\
                            ownership on ports $port_list"
                    return $returnList
                }
            }
            
            # Logout from session
            if {[ixLogout]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed logout."
                return $returnList
            }
        }
    } elseif {([info exists new_ixnetwork_api] && ($new_ixnetwork_api == 1)) && \
            [info exists port_handle] && !([info exists skip_factory_defaults_tclhal] && $skip_factory_defaults_tclhal)} {
        
        if {![info exists no_more_tclhal] || $no_more_tclhal == 0} {
            set port_list [format_space_port_list $port_handle]
            
            if {[info exists reset]} {
                foreach command [list set_factory_defaults] {
                    set ret_val_status [$command $port_list write]
                    if {[keylget ret_val_status status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Setting\
                                ports $port_list to factory defaults failed. \
                                [keylget ret_val_status log]"
                        return $returnList
                    }
                }
            }
            
            if {[info exists maintain_lock] && !$maintain_lock} {
                if {[ixClearOwnership $port_list]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Unable to clear\
                            ownership on ports $port_list"
                    return $returnList
                }
            }
            
            # Logout from session
            if {[ixLogout]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed logout."
                return $returnList
            }
        }
    }

    # If the IxLoad package is available, call their cleanup
    if {[catch {ixDisconnectFromChassis} err]} {
        debug "ixDisconnectFromChassis returned $err"
    }

    if {![catch {package present IxLoad} err]} {
        ixLoadHLTCleanUp
    }

    # Closes the file descriptor used for logging
    catch {close $::ixia::logHltapiCommandsFileDescriptor} closeResult]

    # Initialize the variables defined in Ixia.tcl
    ::ixia::set_init

    catch {ixDisconnectTclServer} 
    catch {unset chassis_list}

    if {[info exists operationError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $operationError
    } else {
        keylset returnList status $::SUCCESS
    }
    puts "Ixia cleanup session completed."
    return $returnList
}

proc ::ixia::device_info { args } {
    variable ::ixia::executeOnTclServer
    variable ::ixia::chassis_list
    variable new_ixnetwork_api
    variable ixnetworkVersion
    
    set procName [lindex [info level [info level]] 0]
    
    ::ixia::logHltapiCommand $procName $args

    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::device_info $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args
    
    set opt_args {
        -fspec_version  FLAG
        -ports          REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -port_handle    REGEXP ^[0-9]+/[0-9]+/[0-9]+$
    }
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args

    if {[info exists fspec_version] && $fspec_version == 1} {
        keylset returnList fspec_version 5.2
    }
    
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        # Get the version and product from the ixnetworkVersion variable
        regexp {^(\d+.\d+)(P|N|NO|P2NO)?$} $ixnetworkVersion {} version product
    
        if {[info exists ports]} {
            foreach port [lsort -unique [join $ports]] {
                if {[regexp -- {(^\d+)/(\d+)/(\d+)} $port {} chassis_id card_id port_id] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR on $procName: invalid handle\
                            specified."
                    return $returnList
                }
                
                set hostname [::ixia::getHostname $::ixia::ixnetwork_chassis_list $chassis_id]
                
                if {$hostname == -1} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to find the ID associated to this\
                            chassis."
                    return $returnList
                }
         
                set chassis "[ixNet getRoot]availableHardware/chassis:\"$hostname\""
                set port_ref "[ixNet getRoot]availableHardware/chassis:\"$hostname\"/card:$card_id/port:$port_id"
                
                if {[info exists version] && $version >= 7.10} {
                    if {[catch {ixNet exec refreshInfo $chassis} err] || $err != "::ixNet::OK" } {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Cannot perform refresh on chassis $hostname"
                        return $returnList
                    }
                }
                
                if {[ixNet exists $port_ref] == false} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Cannot find port for port_handle $port"
                    return $returnList
                }
                                
                set value [ixNet getAttribute $port_ref -owner]
                set description [ixNet getAttribute $port_ref -description]
   
                if {$value != ""} {
                   keylset returnList $hostname.inuse.$port.owner $value
                }
                keylset returnList $hostname.inuse.$port.type $description
            }
        }
        
        if {[info exists port_handle]} {
            foreach port $port_handle {
                set retCode [::ixia::vport_info  \
                                -mode get_info   \
                                -port_list $port \
                            ]
                            
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Error while trying to get port name for port_handle $port. \
                            [keylget retCode log]"
                    return $returnList
                }
                
                set port_name [keylget retCode ${port}.port_name]
                keylset returnList port_handle.$port.port_name $port_name
            }
        } 
        
        keylset returnList status $::SUCCESS
        return $returnList
    }

    if {[info exists ports]} {
        set port_handle_list $ports
        foreach port [lsort -unique [join $port_handle_list]] {
            if {[regexp -- {(^\d+)/} $port {} chassis_id] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR on $procName: invalid handle\
                        specified."
                return $returnList
            }
            foreach {ch_ip ch_id} [join $::ixia::chassis_list] {
                if {$ch_id == $chassis_id} {
                    set chassis_ip $ch_ip
                    break
                }
            }
            if {![info exists chassis_ip]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR on $procName: not connected to\
                        chassis $chassis_id."
                return $returnList
            }
            if {[regexp -- "^(\\d+)/(\\d+)/(\\d+)$" $port {} ch ca po] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR on $procName: invalid handle\
                        specified $port."
                return $returnList
            }
            if {[port get $ch $ca $po] != 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR on $procName: cannot retrive info\
                        about $port"
                return $returnList
            }
            set value [port cget -owner]
            if {$value != {}} {
                keylset returnList $chassis_ip.inuse.$port.owner $value
                keylset returnList $chassis_ip.inuse.$port.type "[port cget -typeName]"
            } else {
                keylset returnList $chassis_ip.available.$port.type "[port cget -typeName]"
            }
        }
    }
    
    if {[info exists port_handle]} {
        set port_handle_list $port_handle
        foreach port [lsort -unique [join $port_handle_list]] {
            if {[regexp -- {(\d+)/(\d+)/(\d+)} $port {} ch ca po] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR on $procName: invalid handle\
                        specified $port_handle."
                return $returnList
            }
            if {[port get $ch $ca $po] != 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR on $procName: cannot retrive info\
                        about $port_handle."
                return $returnList
            }
            set portName [port cget -name]
            if {$portName == ""} {
                set portName "N/A"
            }
            keylset returnList port_handle.$port.port_name $portName
        }
    }

    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::vport_info { args } {

    set procName [lindex [info level [info level]] 0]
    
    ::ixia::logHltapiCommand $procName $args

    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::vport_info $args\}]

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
        -mode               CHOICES get_info set_info
    }
    
    set opt_args {
        -port_list          REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -port_name_list     ANY
    }
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args -mandatory_args $man_args
    
    if { $mode == "set_info" && ![info exists port_name_list] } {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR on $procName: -port_name_list is mandatory when mode is $mode"
        return $returnList
    }
    
    if { $mode == "set_info" && ![info exists port_list] } {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR on $procName: -port_list is mandatory when mode is $mode"
        return $returnList
    }
    
    if { $mode == "set_info" && [info exists port_name_list] && [llength $port_name_list] != [llength $port_list] } {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR on $procName: -port_name_list list must have the same length as -port_list"
        return $returnList
    }
    
    switch $mode {
        set_info {
            foreach hport $port_list pname $port_name_list {
                set vport [ixNetworkGetPortObjref $hport]
                if {[keylget vport status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not get ixnetwork object reference for\
                            port $hport. Possible cause: port was not added with \
                            ::ixia::connect procedure. [keylget vport log]"
                    return $returnList
                }
                set vport [keylget vport vport_objref]
                ixNet setA $vport -name $pname
            }
            
            ixNet commit
        }
        get_info {
            if {![info exists port_list]} {
                set port_list [array names ::ixia::ixnetwork_port_handles_array]
            }
            foreach hport $port_list {
                set vport [ixNetworkGetPortObjref $hport]
                if {[keylget vport status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not get ixnetwork object reference for\
                            port $hport. Possible cause: port was not added with \
                            ::ixia::connect procedure. [keylget vport log]"
                    return $returnList
                }
                set vport [keylget vport vport_objref]
                
                set found 0
                foreach {rp vp} [array get ::ixia::ixnetwork_rp2vp_handles_array] {
                    if {$vp == $hport} {
                        set found 1
                        break
                    }
                }
                
                if {$found} {
                    keylset returnList $hport.real_port_handle $rp
                } else {
                    keylset returnList $hport.real_port_handle N/A
                }
                keylset returnList $hport.port_name [ixNet getA $vport -name]
            }
        }
    }
 
    keylset returnList status $::SUCCESS
    return $returnList 
}

proc ::ixia::session_control {args} {
    
    variable connected_tcl_srv
    variable tcl_server_fallback
    variable conToken
    
    set procName [lindex [info level [info level]] 0]
    
    set man_args {
        -mode           CHOICES save load
    }
    
    set opt_args {
        -file_ixncfg            ANY
        -file_name              ANY
        -ixnetwork_tcl_server   ANY
        -device                 ANY
        -port_list              ANY
        -tcl_server             ANY
    }
    
    ::ixia::parse_dashed_args -args $args -mandatory_args $man_args -optional_args $opt_args
    
    if {$mode == "save"} {
        if {![info exist file_name] && ![info exist file_ixncfg]} {
            # BUG1300401 - display the corresponding error to tue user.
            # session_control is called only from legacy_connect, where we have the following mapping:
            #   config_file_hlt => file_name
            #   config_file     => file_ixncfg
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: At least one of the\
                    parameters -config_file or -config_file_hlt must be specified when -mode is 'save'"
            return $returnList
        }
        
        if {[info exists file_name]} {
            set ret_code [configuration_save $file_name]
            if {[keylget ret_code status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: [keylget ret_code log]"
                return $returnList
            }
        }
        
        if {[info exists file_ixncfg]} {
            if {[catch {ixNet exec saveConfig [ixNet writeTo $file_ixncfg -overwrite]} err]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to save IxNetwork configuration to\
                        '$file_ixncfg'. $err"
                return $returnList
            }
        }
        
    } elseif {$mode == "load"} {
        if {[info exist file_name]} {
            
            if {[info exist ixnetwork_tcl_server]} {
                puts "\nWarning in $procName: When -file_name is specified\
                        -ixnetwork_tcl_server parameter is ignored and connection\
                        is restored according to the configurations from -file_name\n"
            }
            
            set ret_code [session_resume $file_name]
            if {[keylget ret_code status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: [keylget ret_code log]"
                return $returnList
            } else {
                set _conToken $conToken
                #puts "_conToken: $_conToken"
                set return_code [::ixia::connection_key_builder $_conToken]
                #puts "return_code: $return_code"
                keylset returnList connection $return_code            
            }
            
            if {[info exists file_ixncfg]} {
                if {[catch {ixNet exec loadConfig [ixNet readFrom $file_ixncfg]} err]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to load IxNetwork configuration from\
                            '$file_ixncfg'. $err"
                    return $returnList
                }
            }
            
        } else {
            
            if {[info exists device] && ![info exist port_list]} {
                
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -device was specified\
                        but parameter port_list is missing."
                return $returnList
            }
            
            if {![info exists device] && [info exist port_list]} {
                
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Parameter -port_list was specified\
                        but parameter device is missing."
                return $returnList
            }
            
            if {[info exists device] && [info exists port_list]} {
                puts "\nParameters -device and -port_list were specified on session resume.\
                        The virtual ports will be connected to the hardware specified with\
                        parameters -device and -port_list"
            } else {
                set device    "_na"
                set port_list "_na"
            }
            
            if {![info exist ixnetwork_tcl_server]} {
                set ixnetwork_tcl_server 127.0.0.1
            }
            
            if {[isUNIX]} {
                # IxTclNetwork, Unix
                # Tcl Server must be the same with IxN Tcl Server and they 
                # shouldn't be on chassis machine
                if {![info exists tcl_server] && (![info exists ::ixia::no_more_tclhal] || $::ixia::no_more_tclhal == 0) } {
                    
                    if {[info exists ixnetwork_tcl_server] && $ixnetwork_tcl_server != ""} {
                        set tcl_server          [lindex [split $ixnetwork_tcl_server :] 0]
                        set ::ixia::ixnetwork_tcl_server $ixnetwork_tcl_server
                    }
                    
                    if {[info exists device]} {
                        set tcl_server_fallback [lindex $device 0]
                    }
                }
                
                # Connect only if we're not connected to tcl server OR
                #       if we are connected but to another tcl server than the one requested
                if {(![info exists tcl_server] || $::ixia::connected_tcl_srv != $tcl_server) &&\
                        (![info exists tcl_server_fallback] || $::ixia::connected_tcl_srv != $tcl_server_fallback)} {
                    
                    if {[info exists tcl_server]} {
                        
                        # Set environment variable - this variable needs to be set here(see bug 428510)
                        if {[regexp "^HLTSET" $::env(IXIA_VERSION)]} {
                            set IXIA_VERSION_bak $::env(IXIA_VERSION)
                            set ixtclhal_list [split [package present IxTclHal]]
                            set ::env(IXIA_VERSION) [lindex $ixtclhal_list 0].[lindex $ixtclhal_list 1]
                        }
                        
                        if {$connected_tcl_srv != ""} {
                            catch {ixDisconnectTclServer}
                            set connected_tcl_srv ""
                        }
                        if {[connect_to_tcl_server $tcl_server]} {
                            set bak_err_msg $::ixErrorInfo
                            if {[info exists tcl_server_fallback]} {
                                if {[connect_to_tcl_server $tcl_server_fallback]} {
                                    set connected_tcl_srv ""
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Could not connect\
                                            to tcl_server $tcl_server ($bak_err_msg) or $tcl_server_fallback ($::ixErrorInfo)"
                                    return $returnList
                                } else {
                                    set warning_message_return "WARNING: Could not connect to tcl server\
                                            $tcl_server ($bak_err_msg). Curently connected to $tcl_server_fallback\
                                            tcl server."
                                    set tcl_server          $tcl_server_fallback
                                    set connected_tcl_srv   $tcl_server_fallback
                                }
                            } else {
                                set connected_tcl_srv ""
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: Could not connect\
                                        to tcl_server $tcl_server ($bak_err_msg)"
                                return $returnList
                            }
                        } else {
                            set connected_tcl_srv $tcl_server
                        }
                        set ::ixia::ixtclhal_version [version cget -ixTclHALVersion]
                        if {[info exists IXIA_VERSION_bak]} {
                            set ::env(IXIA_VERSION)      $IXIA_VERSION_bak
                        }
                    }
                }
            }
            
            
            if {![info exists file_ixncfg]} {
                set ret_code [session_detect_and_restore $ixnetwork_tcl_server 0 _na          $device $port_list]
            } else {
                set ret_code [session_detect_and_restore $ixnetwork_tcl_server 1 $file_ixncfg $device $port_list]
            }
            
            if {[keylget ret_code status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: [keylget ret_code log]"
                return $returnList
            }            
            keylset returnList port_handle_pool [keylget ret_code port_handle_pool]
            
        }
            
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}

