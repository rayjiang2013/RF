proc ::ixia::checkIxNetwork { {version {latest}} } {
    variable ixNetworkChassisConnected
    variable ixnetwork_chassis_list
    variable ixnetwork_master_chassis_array
    variable ixnetwork_tcl_server
    variable ixnetwork_tcl_proxy
    variable ixnetwork_tcl_server_reset
    variable hltConnectCall
    variable connect_timeout
    variable ixn_traffic_version
    variable no_more_tclhal
    variable tcl_proxy_username
    variable ixnetwork_license_servers
    variable ixnetwork_license_type
    variable close_server_on_disconnect
    variable conToken
    array set truth [list  1 True 0 False]
    
    if {$hltConnectCall} {
        if {[catch {ixNet getList [ixNet getRoot]} retCode] &&\
                [regexp "not connected to IxNetwork" $retCode]} {
            set ixNetworkChassisConnected $::FAILURE
            set hltConnectCall 0
        }
    }
    
    if {![info exists ixNetworkChassisConnected]} {
        set ixNetworkChassisConnected $::FAILURE
    }
    
    if {$version == "latest"} {
        if {[catch {set ::ixia::ixnetworkVersion} ixn_version]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal error. Failed to get IxNetwork version - $ixn_version.\
                    Possible causes: not connected to IxNetwork Tcl Server."
            return $returnList
        }
        
        if {![regexp {(^\d+)(\.)(\d+)} $ixn_version {} ixn_version_major {} ixn_version_minor]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal error. Failed to get IxNetwork version major and minor - $ixn_version."
            return $returnList
        }
        
        if {($ixn_version_major < 5) || (($ixn_version_major == 5) && ($ixn_version_minor <= 30))} {
            set version 5.30
        } else {
            set version ${ixn_version_major}.${ixn_version_minor}
#            set version 5.40
        }
    } else {
        set version [string trim $version NO]
    }
    
    if {![info exists ixn_traffic_version] \
            || $ixn_traffic_version != $version} {
        
        # Connecting to IxNetwork TCL server
        if {$ixnetwork_tcl_server == ""} {
            keylset returnList status $::FAILURE
            keylset returnList log "Invalid option\
                    -ixnetwork_tcl_server. Please provide an IP value."
            return $returnList
        }
        
        set remoteIp   [lindex [split $ixnetwork_tcl_server ":"] 0]
        set remotePort [lindex [split $ixnetwork_tcl_server ":"] 1]
        set remoteService $remoteIp
        if {$remotePort != ""} {
            append remoteService " -port $remotePort"
        } else {
            set remotePort 8009
        }
        set ixn_major [lindex [split $::ixia::ixnetworkVersion .] 0]
        regexp {(^\d+)} [lindex [split $::ixia::ixnetworkVersion .] 1] ixn_minor
        set ixnVersionTemp $ixn_major.$ixn_minor
        if {$ixnVersionTemp < 5.40} {
            set _cmd [format "%s" "ixNet connect $remoteService"]
            debug $_cmd
        } else {
            if {[info exists close_server_on_disconnect]} {
                # Translate close_server_on_disconnect from 0/1 to False/True (format required by ixNet api)
                append remoteService " -closeServerOnDisconnect $truth($close_server_on_disconnect)"
            }
            if {[info exists tcl_proxy_username]} {
                append remoteService " -serverusername $tcl_proxy_username"
            }
            set _cmd [format "%s" "ixNet connect $remoteService -version $version"]
            debug $_cmd
        }
        if {[info exists _connect_result]} {
            unset _connect_result
        }
        
        if {![info exists ixn_traffic_version]} {
            puts "Connecting to IxNetwork Tcl Server $remoteService ..."
        } elseif {[info exists ixn_traffic_version] && $ixn_traffic_version != $version} {
            catch {ixNet disconnect}
            if {$version == "5.30"} {
                if {$ixn_traffic_version == "ixos"} {
                    puts "Changing traffic generator from 'ixos' to 'ixnetwork' (Legacy Traffic)"
                } else {
                    puts "Changing traffic generator from 'ixnetwork_540' (Next Gen Traffic) to 'ixnetwork' (Legacy Traffic)"
                }
            } else {
                if {$ixn_traffic_version == "ixos"} {
                    puts "Changing traffic generator from 'ixos' to 'ixnetwork_540' (Next Gen Traffic)"
                } else {
                    puts "Changing traffic generator from 'ixnetwork' (Legacy Traffic) to 'ixnetwork_540' (Next Gen Traffic)"
                }
            }
        }
        
        
        update idletasks
        catch {eval $_cmd} _connect_result
        if {!([info exists _connect_result] && \
                $_connect_result == "::ixNet::OK")} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not connect to IxNetwork TCL Server: \
                    $remoteService"
            return $returnList
        } else {
            set _conToken [ixNet connectiontoken]
            set conToken ""
            if {$_conToken != ""} {
                set res [regsub -all {\-} $_conToken "" conToken]
                lappend conToken usingTclProxy 1 serverversion [ixNet getA [ixNet getRoot]/globals -buildNumber]
            } else {
                lappend conToken usingTclProxy 0 serverversion [ixNet getA [ixNet getRoot]/globals -buildNumber] \
                        port $remotePort
            }
        }
        catch {
            if {[regexp {setAttribute strict}  [ixNet setSessionParameters]]} {
                puts "WARNING: IxNetwork sessionParameter setAttribute is set to strict mode! This can cause unexpected results while running HLT tests. Setting it back to default (looseNoWarning)"
                ixNet setSessionParameters setAttribute looseNoWarning
            }
        }
        after 500
        set ixn_traffic_version $version
    }

    # Resetting IxNetwork TCL server
    if {$ixnetwork_tcl_server_reset} {
        set ixnetwork_tcl_server_reset 0
        
        # Reset configuration
        
        if {$version < 5.40} {
            # Split PGID does not exists in 5.40 and newer IxNetwork
            catch {
                foreach setting_obj [ixNet getL ::ixNet::OBJ-/traffic/splitPgidSettings setting] {
                    set tmp_out [ixNet remove $setting_obj]
                    debug "ixNet remove $setting_obj --> $tmp_out"
                }
                set tmp_out [ixNet commit]
                debug "ixNet remove $setting_obj; commit --> $tmp_out"
            } tmp_out
            debug "Split PGID Cleanup returned --> $tmp_out"
        }
        if {![info exists no_more_tclhal] || $no_more_tclhal == 0} {
            if {[ixLogout]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed logout."
                return $returnList
            }
        }
        
        ixNet exec newConfig
        debug "ixNet exec newConfig"
        # Remove user stat views
        debug "ixNet getList [ixNet getRoot]statistics userStatView"
        set userStatViewList [ixNet getList [ixNet getRoot]statistics \
                userStatView]
        foreach userView $userStatViewList {
            ixNet remove $userView
            debug "ixNet remove $userView"
        }
        
        catch {ixNet commit}
        debug "ixNet commit"
    }

    ::ixia::set_license_servers
    # Connecting to chassis
    set ixn_chassis_list [list]
    set ixn_master_chassis_list [list]
    set ixn_cable_length_list [list]
    set ixn_sequence_id_list [list]
    foreach chassis $ixnetwork_chassis_list {
        if {[catch {keylget ::ixia::ips_to_hosts [lindex $chassis 1]} err]} {
            lappend ixn_chassis_list [lindex $chassis 1]
        } else {
            lappend ixn_chassis_list [keylget ::ixia::ips_to_hosts [lindex $chassis 1]]
        }
        if {[info exists ixnetwork_master_chassis_array([lindex $chassis 0])]} {
            lappend ixn_master_chassis_list [set ixnetwork_master_chassis_array([lindex $chassis 0])]
        } else {
            lappend ixn_master_chassis_list none
        }
    }

    set chassisCount [llength $ixnetwork_chassis_list]
    if {$chassisCount > 0} {
        set _cmd [format "%s" "::ixia::ixNetworkConnectToChassis \
                {$ixn_chassis_list} $connect_timeout"]
        
        set _connect_result [eval $_cmd]
        if {[keylget _connect_result status] == $::SUCCESS} {
            set ixNetworkChassisConnected $::SUCCESS
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "[keylget _connect_result log]"
            return $returnList
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::checkProtocols {vportObjRef} {
    set stateDetail [ixNet getAttribute $vportObjRef -stateDetail]
    set type        [ixNet getAttribute $vportObjRef -type]
    if {$type == "pos"} {
        set payloadType [ixNet getAttribute $vportObjRef/l1Config/pos -payloadType]
        if {($payloadType == "ciscoFrameRelay") || ($payloadType == "frameRelay")} {
            keylset returnList status $::FAILURE
            return $returnList
        }
    }
    if {$stateDetail == "protocolsNotSupported"} {
        keylset returnList status $::FAILURE
        return $returnList
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::ixNetworkConnectToChassis { hostnameList {timeoutCount 100} } {
    set retCode 0
    set notConnectedList {}

    set availHwId [ixNet getRoot]availableHardware
    set forceDisablePortDirectConfigMode [ixNet  getA [ixNet getRoot]/availableHardware -forceDisablePortDirectConfigMode]
    if {$forceDisablePortDirectConfigMode != "true"} {
        ixNet setA [ixNet getRoot]/availableHardware -forceDisablePortDirectConfigMode true
		ixNet commit
    }
    # If the chassis is already connected don't bother connecting again.
    set chassisList [ixNetworkNodeGetList $availHwId chassis -all]

    # Remove connected chassis from the list.
    foreach chassisId $chassisList {
        debug "ixNet getAttr $chassisId -hostname"
        set chassisIp [ixNet getAttr $chassisId -hostname]
        debug "ixNet getAttr $chassisId -state"
        set connected [ixNet getAttr $chassisId -state]
        
        if {$connected == "ready"} {
            set ipIndex [lsearch $hostnameList $chassisIp] 
            if {$ipIndex != -1} {
                set hostnameList       [lreplace $hostnameList       $ipIndex $ipIndex]
            }
        }
    }

    if {[llength $hostnameList] == 0} {
        debug "All Chassis in the list already connected..."
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    set errMsg ""
    # first we need to add master chassis 
    if {[info exists ::ixia::chassis_chain] && [regexp master_device [keylkeys ::ixia::chassis_chain]]} {
        foreach masterHostname [keylget ::ixia::chassis_chain master_device_iterator] {
            debug "Adding master chassis $masterHostname"
            set ch_obj_ref [ixNet add $availHwId chassis]
            ixNet setAttribute $ch_obj_ref -hostname $masterHostname
            set retCode [catch {ixNet commit} resCode]
            if {$resCode != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not add the following master chassis: $masterHostname - $resCode."
                return $returnList
            }
            set chassisRef [ixNet remapIds $ch_obj_ref]
            if {[keylget ::ixia::chassis_chain type] == "star"} {
                # star can only be set after commiting chassis add as the option is only valid for some chassis types
                ixNet setAttribute $chassisRef -chainTopology [keylget ::ixia::chassis_chain type]
                set retCode [catch {ixNet commit} resCode]
                if {$resCode != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not add set the chassis chain topology to [keylget ::ixia::chassis_chain type]\
                            for $masterHostname chassis. Please check if your chassis is master and if the topology is supported.\n \
                            IxNetwork error: $resCode."
                    return $returnList
                }
            } else {
                if { [catch {keylget ::ixia::chassis_chain device.${masterHostname}.id}] } {
                    ixNet setAttribute $chassisRef -sequenceId 1
                } else {
                    ixNet setAttribute $chassisRef -sequenceId [keylget ::ixia::chassis_chain device.${masterHostname}.id]
                }
                set retCode [catch {ixNet commit} resCode]
                if {$resCode != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not add set the chassis chain topology to [keylget ::ixia::chassis_chain type]\
                            for $masterHostname chassis. IxNetwork error: $resCode."
                    return $returnList
                }
            }
            keylset ::ixia::chassis_chain master_device.$masterHostname.handle $chassisRef
            set initTime [clock seconds]
            while {[ixNet getAttribute $chassisRef -state] != "ready" && \
                    ([expr [clock seconds] - $initTime]) < $timeoutCount} {
                
                after 1000
                
                if {[ixNet getAttribute $chassisRef -state] != "ready" && \
                        ([expr [clock seconds] - $initTime]) >= $timeoutCount && \
                        [ixNet getAttribute $chassisRef -connectRetries] < 3} {
                    set initTime [clock seconds]
                    ixPuts "Chassis $masterHostname is not ready. Waiting to become available..."
                }
            }
        }
    }
    foreach hostname $hostnameList {
        if {    [info exists ::ixia::chassis_chain] &&  \
                [regexp master_device_iterator [keylkeys ::ixia::chassis_chain]] && \
                [lsearch [keylget ::ixia::chassis_chain master_device_iterator] $hostname] > -1} {
            debug "chassis $hostname allready added"
            # chassis allready added above
            set chassisId [keylget ::ixia::chassis_chain master_device.$hostname.handle]
        } else {
            debug "Adding chassis $hostname"
            # need to add regular chassis or slave chassis
            set ch_obj_ref [ixNet add $availHwId chassis]
            catch {ixNet setAttribute $ch_obj_ref -hostname $hostname}
            # we need to commit before setting the chassis chain parameters (BUG1310462 and BUG1312606)
            set retCode [catch {ixNet commit} resCode]
            if {$resCode != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not add the following chassis: $hostname - $resCode."
                return $returnList
            } else {
                keylset result status $::SUCCESS
                set chassisId [ixNet remapIds $ch_obj_ref]
                keylset result node_objref $chassisId
            }
            
            if { ![catch {set masterHostname [keylget ::ixia::chassis_chain device.${hostname}.master]}] } {
                if {$masterHostname != "" && $masterHostname != "none" && $masterHostname != $hostname} {
                    ixNet setAttribute $chassisId -masterChassis $masterHostname
                    ixNet setAttribute $chassisId -cableLength [keylget ::ixia::chassis_chain device.${hostname}.cable]
                    if {[keylget ::ixia::chassis_chain type] == "daisy"} {
                        ixNet setAttribute $chassisId -sequenceId [keylget ::ixia::chassis_chain device.${hostname}.id]
                    }
                }
                set retCode [catch {ixNet commit} resCode]
                if {$resCode != "::ixNet::OK"} {
                    keylset result status $::FAILURE
                    keylset result log $resCode
                } else {
                    keylset result status $::SUCCESS
                    keylset result node_objref $chassisId
                }
            }
    #         after 1000  
            
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not add the following chassis: $hostname - [keylget result log]."
                return $returnList
            } else {
                set chassisId [keylget result node_objref]
                keylset ::ixia::chassis_chain device.$hostname.handle $chassisId
            }
        }
        
        foreach chassisRef $chassisId {}
        set initTime [clock seconds]
        while {[ixNet getAttribute $chassisRef -state] != "ready" && \
                ([expr [clock seconds] - $initTime]) < $timeoutCount} {
            
            after 1000
            
            if {[ixNet getAttribute $chassisRef -state] != "ready" && \
                    ([expr [clock seconds] - $initTime]) >= $timeoutCount && \
                    [ixNet getAttribute $chassisRef -connectRetries] < 3} {
                set initTime [clock seconds]
                ixPuts "Chassis $hostname is not ready. Waiting to become available..."
            }
        }
        
        if {[ixNet getAttribute $chassisRef -state] != "ready"} {
            set tmp_retries [ixNet getAttribute $chassisRef -connectRetries]
            set tmp_state [ixNet getAttribute $chassisRef -state]

            ixNet remove $chassisRef
            
            incr retCode
            lappend notConnectedList $hostname
            
            if {$retCode > 1} {
                append errMsg "; "
            }
            
            if {$tmp_state == "polling"} {
                append errMsg "$hostname fail reason: timeout after $tmp_retries retries."
            } else {
                append errMsg "$hostname fail reason: host is down after $tmp_retries retries."
            }
            
        }
    }

    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "Could not connect to the following hosts:\
                $notConnectedList. $errMsg"
        keylset returnList not_connected $notConnectedList
        return $returnList
    }

    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::ixNetworkDisconnectAllChassis {} {
    set root [ixNet getRoot]

    set connected_chassis_list [ixNetworkNodeGetList ${root}availableHardware \
            chassis -all]
    foreach chassis $connected_chassis_list {
        catch {ixNet remove $chassis} _remove_result
        debug "ixNet remove $chassis"
        if {!([info exists _remove_result] && \
                $_remove_result == "::ixNet::OK")} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to remove the chassis: \
                    $chassis."
            return $returnList
        }
    }

    catch {ixNet commit} _remove_result
    debug "ixNet commit"
    if {!([info exists _remove_result] && \
            $_remove_result == "::ixNet::OK")} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to commit the modifications on \
                chassis: $chassis."
        return $returnList
    }

    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::ixNetworkRemoveAllPorts {} {
    set root [ixNet getRoot]
    
    set vport_list [ixNetworkNodeGetList $root vport -all]
    foreach vport $vport_list {
        catch {ixNet remove $vport} _remove_result
        debug "ixNet remove $vport"
        if {!([info exists _remove_result] && \
                $_remove_result == "::ixNet::OK")} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to remove the vport: \
                    $vport."
            return $returnList
        }
    }

    catch {ixNet commit} _remove_result
    debug "ixNet commit"
    if {!([info exists _remove_result] && \
            $_remove_result == "::ixNet::OK")} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to commit the modifications on \
                vport: $vport."
        return $returnList
    }

    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::ixNetworkClearPorts { port_handles_list } {
    set root [ixNet getRoot]

    foreach port_handle $port_handles_list {
        set result [ixNetworkGetPortObjref $port_handle]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not find any vport which uses the\
                    $port_handle port - [keylget result log]."
            return $returnList
        } else {
            set port_objref [keylget result vport_objref]
        }
        set intf_list [ixNetworkNodeGetList $port_objref interface -all] 
        foreach intf_objref $intf_list {
            catch {ixNet remove $intf_objref} _remove_result
            debug "ixNet remove $intf_objref"
            if {!([info exists _remove_result] && \
                    $_remove_result == "::ixNet::OK")} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to remove the interface: \
                        $intf_objref."
                return $returnList
            }
        }

        catch {ixNet commit} _remove_result
        debug "ixNet commit"
        if {!([info exists _remove_result] && \
                $_remove_result == "::ixNet::OK")} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to commit the modifications on \
                    vport: $port_objref."
            return $returnList
        }
    }

    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::getHostname {ixnetwork_chassis_list chassis_id} {
    set hostname -1
        
    foreach chassisId $ixnetwork_chassis_list {
        if {[lindex $chassisId 0] == $chassis_id} {
            set hostname [lindex $chassisId 1]
            break
        }
    }
    if {[catch {keylget ::ixia::ips_to_hosts $hostname} err] == 0} {
        set hostname [keylget ::ixia::ips_to_hosts $hostname]
    }
    
    return $hostname
}

proc ::ixia::ixNetworkMultiplePortsAdd {
    realPortList
    vportObjRefList
    {forcedClearOwnership no_force}
    } {
    variable ixnetwork_chassis_list
    variable ixnetwork_port_handles_array
    variable ixnetwork_real_port_handles_array
    variable ixnetwork_port_handles_array_vport2rp
    variable session_owner_tclhal
    variable no_more_tclhal
    variable ixnetwork_rp2vp_handles_array
    variable connect_timeout
    variable aggregation_mode
    variable aggregation_resource_mode
    
    set root [ixNet getRoot]
    
    switch -- $vportObjRefList {
        "add_vp" {
            # realPortList == number of vports to add
            # vportObjRefList == "add_vp"
            set vport_requested_count $realPortList
            set mode "add_vp"
        }
        "legacy" {
            # realPortList == ch/ca/po handles (where ch ca and po are the real ids)
            # vportObjRefList == "legacy"
            set mode "legacy"
        }
        default {
            # realPortList == ch/ca/po handles (where ch ca and po are the real ids)
            # vportObjRefList == list of port handle ids (e.g. 0/0/3 1/2/3 0/5/3) don't have to be real ch/ca/po ids, just some ids
            set mode "connect_vp_rp"
        }
    }
    
    if {$mode != "add_vp"} {
        # Make sure that the port list contains unique ports - BUG500530
        set idx 0
        set tmpRealPortList ""
        set tmpVPortList    ""
        array set rp_vp_array ""
        foreach realPort $realPortList {
            if {[lsearch $tmpRealPortList $realPort] == -1} {
                lappend tmpRealPortList $realPort
                if {$mode == "connect_vp_rp"} {
                    lappend tmpVPortList [lindex $vportObjRefList $idx]
                    set rp_vp_array($realPort) [lindex $vportObjRefList $idx]
                } else {
                    set rp_vp_array($realPort) [ixNetworkGetNextVportHandle $realPort]
                    #if {[info exists ixnetwork_rp2vp_handles_array($realPort)]} {
                        #set rp_vp_array($realPort) $ixnetwork_rp2vp_handles_array($realPort)
                    #} else {
                        #set rp_vp_array($realPort) _tbd
                    #}
                }
            }
            incr idx
        }
        
        set realPortList $tmpRealPortList
        catch {unset tmpRealPortList}
        
        if {$mode == "connect_vp_rp"} {
            
            set vportObjRefList $tmpVPortList
            catch {unset tmpVPortList}
            
            # Make sure vport ids are unique
            foreach item $vportObjRefList {
                if {[llength [lsearch -all $vportObjRefList $item]] > 1} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Parameter vport_list does not contain unique\
                            handles."
                    return $returnList
                }
            }
        }
    
        ::ixia::debug "Clear Ownership Start" clr_own_00
        if {$forcedClearOwnership == "force"} {
            # Do cleanup on all ports first. It's much faster
            if {[catch {set ::ixia::ixnetworkVersion} ixn_version]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Internal error. Failed to get IxNetwork version - $ixn_version.\
                        Possible causes: not connected to IxNetwork Tcl Server."
                return $returnList
            }
            
            if {![regexp {(^\d+)(\.)(\d+)} $ixn_version {} ixn_version_major {} ixn_version_minor]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Internal error. Failed to get IxNetwork version major and minor - $ixn_version."
                return $returnList
            }
            
            if {($ixn_version_major < 5) || (($ixn_version_major == 5) && ($ixn_version_minor <= 40))} {
                set clear_ownership_group 0
            } else {
                set clear_ownership_group 1
            }
            
            set realPortObjRefList ""
            foreach realPort $realPortList {
                
                # If the port is already assigned, don't add it again.
                # Look for the port handle.
                set result [ixNetworkGetPortObjref $realPort]
                if {([keylget result status] == $::SUCCESS && [ixNetworkIsOwnershipTaken $realPort]) \
                        || [info exists ixnetwork_rp2vp_handles_array($realPort)]} {
                    continue
                }
                
                # The port wasn't found. Add it.
                set root [ixNet getRoot]
                
                regexp {^(\d+)/(\d+)/(\d+)$} $realPort {} chassis_id card_id port_id
                set hostname [::ixia::getHostname $ixnetwork_chassis_list $chassis_id]
                
                if {$hostname == -1} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to find the ID associated to this\
                            chassis."
                    return $returnList
                }
                
                # Find the objref of real port.
                set realPortObjRef ::ixNet::OBJ-/availableHardware/chassis:\"$hostname\"/card:$card_id/port:$port_id
                lappend realPortObjRefList $realPortObjRef
            }
            
            if {[llength $realPortObjRefList] > 0} {
                if {$clear_ownership_group == 0} {
                    
                    set hw_ready_start_time [clock seconds]
                    
                    foreach realPortObjRef $realPortObjRefList {
                        set realChassisObjRef [ixNetworkGetParentObjref $realPortObjRef "chassis"]
                                                
                        # Wait for hardware to become available
                        set hw_ready 0
                        for {set ahw_it 0} {$ahw_it < [expr $connect_timeout * 2]} {incr ahw_it} {
                            if {[ixNet getAttr $realPortObjRef    -isBusy]      == "false"} {
                                
                                set hw_ready 1
                                break
                            }
                            
                            after 500
                            
                            if {[expr [clock seconds] - $hw_ready_start_time] > $connect_timeout} {
                                # The total amount of wait time for ALL ports must not exceed $connect_timeout
                                break
                            }
                        }
                        
                        set debug_msg "ixNet getAttr $realPortObjRef -isBusy -> [ixNet getAttr $realPortObjRef -isBusy]"
                        
                        if {!$hw_ready} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Timeout: port $realPortObjRef is not ready after\
                                    $connect_timeout seconds. The timeout can be configured using the\
                                    parameter -connect_timeout"
                            debug $debug_msg
                            return $returnList
                        }
                        
                        debug "ixNet exec clearOwnership $realPortObjRef"
                        if {[catch {ixNet exec clearOwnership $realPortObjRef} err]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to clear ownership on $realPortObjRef. $err"
                            debug $debug_msg
                            return $returnList
                        }
                    }
                } else {
                    set debug_msg ""
                    set hw_ready_start_time [clock seconds]
                    set hw_ready 0
                    foreach realPortObjRef $realPortObjRefList {
                        set realChassisObjRef [ixNetworkGetParentObjref $realPortObjRef "chassis"]
                                                
                        # Wait for hardware to become available
                        for {set ahw_it 0} {$ahw_it < [expr $connect_timeout * 2]} {incr ahw_it} {
                            if {[ixNet getAttr $realPortObjRef    -isBusy]      == "false"} {
                                
                                incr hw_ready
                                break
                            }
                            after 500
                            
                            if {[expr [clock seconds] - $hw_ready_start_time] > $connect_timeout} {
                                # The total amount of wait time for ALL ports must not exceed $connect_timeout
                                break
                            }
                        }
                        
                        append debug_msg "ixNet getAttr $realPortObjRef -isBusy -> [ixNet getAttr $realPortObjRef -isBusy]; "

                        if {[expr [clock seconds] - $hw_ready_start_time] > $connect_timeout} {
                            # The total amount of wait time for ALL ports must not exceed $connect_timeout
                            break
                        }
                    }
                    
                    if {$hw_ready != [llength $realPortObjRefList]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Timeout: hardware is not ready.\
                                Only $hw_ready out of [llength $realPortObjRefList] ports are ready\
                                after $connect_timeout seconds. The timeout can be configured using the\
                                parameter -connect_timeout"
                        debug $debug_msg
                        return $returnList
                    }
                    
                    debug "ixNet exec clearOwnership $realPortObjRefList"
                    if {[catch {ixNet exec clearOwnership $realPortObjRefList} err]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to clear ownership on port list. $err"
                        debug $debug_msg
                        return $returnList
                    }
                    set ports_to_clear_owner ""
                    if {[info exists aggregation_resource_mode] || [info exists aggregation_mode]} { 
                        array unset ::ixia::aggregation_map
                        array unset ::ixia::resource_ports_map
                        foreach clear_port_elem $realPortObjRefList {
                            if {[regexp {(::ixNet::OBJ-/availableHardware/chassis:".+"/card:[0-9]+)/port:([0-9]+)$} $clear_port_elem value card_objref port_no]} {
                                if {[info exists ::ixia::aggregation_map($card_objref)]} {
                                    set available_aggregations $::ixia::aggregation_map($card_objref)
                                } else {
                                    set available_aggregations [ixNet getL $card_objref aggregation]
                                    set available_modes        [ixNet getA $card_objref -availableModes]
                                    set ::ixia::aggregation_map($card_objref) $available_aggregations
                                    set ::ixia::aggregation_map($card_objref,available_modes) $available_modes
                                }
                                if {[info exists ::ixia::resource_ports_map($card_objref,$port_no)]} {
                                    set resource_ports $::ixia::resource_ports_map($card_objref,$port_no)
                                } else {
                                    foreach aggregation $available_aggregations {
                                        set resource_ports [ixNet getA $aggregation -resourcePorts]
                                        set available_port_modes [ixNet getA $aggregation -availableModes]
                                        foreach port_obj $resource_ports {
                                            set port_obj_no [lindex [regexp -inline {/port:(\d+)$} $port_obj] 1]
                                            set ::ixia::resource_ports_map($card_objref,$port_obj_no) $resource_ports
                                            set ::ixia::aggregation_map($card_objref,$port_obj_no,available_port_modes) $available_port_modes
                                            set ::ixia::aggregation_map($card_objref,$port_obj_no) $aggregation
                                        }
                                    }
                                }
                                if {[info exists ::ixia::resource_ports_map($card_objref,$port_no)]} {
                                    set resource_ports $::ixia::resource_ports_map($card_objref,$port_no)
                                    foreach port_in_resource $resource_ports {
                                        debug "adding $port_in_resource to the clear ownership list"
                                        lappend ports_to_clear_owner $port_in_resource
                                    }
                                } else {
                                    debug "port $port_no was not found in the resource_ports_map array\
                                            for card $card_objref: [array names ::ixia::resource_ports_map]"
                                }
                            }
                        }
                        if {$ports_to_clear_owner != ""} {
                            if {[catch {ixNet exec clearOwnership $ports_to_clear_owner} err]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Failed to clear ownership on port list. $err"
                                debug $debug_msg
                                return $returnList
                            }
                        }
                    }
                }
            }
        }
        ::ixia::debug "Clear Ownership Done" clr_own_00
        
        if {[info exists aggregation_mode]} {
            set aggregation_mode [string map {\{ "" \} ""} $aggregation_mode]   
            set agg_mode_status [ixNetworkSetAggregatedMode $realPortList $aggregation_mode]
            if {[keylget agg_mode_status status] != $::SUCCESS} {
                return $agg_mode_status
            }
        }
        if {[info exists aggregation_resource_mode]} {
            set aggregation_resource_mode [string map {\{ "" \} ""} $aggregation_resource_mode]   
            set agg_mode_status [ixNetworkSetResourceAggregatedMode $realPortList $aggregation_resource_mode]
            if {[keylget agg_mode_status status] != $::SUCCESS} {
                return $agg_mode_status
            }
        }
        
        
        set global_retry_count 3
        
        set chassis_obj_list ""
        
        while {[llength $realPortList] > 0 && $global_retry_count >= 0} {
            
            ::ixia::debug "Global retry $global_retry_count"
            
            catch {unset vport_array_list}
            array set vport_array_list ""
            
            if {$mode != "connect_vp_rp"} {
                
                # Create all the vports before assigning them. Otherwise ixnetwork adds them one by one 
                # even if there's only 1 commit BUG618500
                
                catch {unset vports_legacy_array}
                array set vports_legacy_array ""
                foreach realPort $realPortList {
                    
                    set rp_vp_handle $rp_vp_array($realPort)
                
                    # If the port is already assigned, don't add it again.
                    # Look for the port handle.
                    
                    set result [ixNetworkGetPortObjref $rp_vp_handle]
                    if {([keylget result status] == $::SUCCESS) &&\
                            ([ixNet getA [keylget result vport_objref] -connectionInfo] != "")} {
                        continue
                    }
                    
                    set result [ixNetworkNodeAdd $root vport]
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Could not create vport - [keylget result log]."
                        return $returnList
                    }
                    set vports_legacy_array($realPort) [keylget result node_objref]
                }
                
                if {[set retCode [ixNet commit]] != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not create all vports: $retCode"
                    return $returnList
                }
                
                set tmp_vport_list ""
                foreach real_port_tmp [array names vports_legacy_array] {
                    set vport_tmp [ixNet remapIds $vports_legacy_array($real_port_tmp)]
                    lappend tmp_vport_list $vport_tmp
                    set vports_legacy_array($real_port_tmp) $vport_tmp
                }
                
                # Configure arp for all protocols (objects must be grouped based on hierarchy)
                set retCode [ixNetworkEnableArp $tmp_vport_list]
                if {[keylget retCode status] != $::SUCCESS} {
                    return $retCode
                }
                
                # Configure ping for all protocols (objects must be grouped based on hierarchy)
                set retCode [ixNetworkEnablePing $tmp_vport_list]
                if {[keylget retCode status] != $::SUCCESS} {
                    return $retCode
                }
                
                if {[set retCode [ixNet commit]] != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not enable PING and ARP on all vports: $retCode"
                    return $returnList
                }
            }
            
            set commit_needed 0
            foreach realPort $realPortList {
                
                set rp_vp_handle $rp_vp_array($realPort)
                
                # If the port is already assigned, don't add it again.
                # Look for the port handle.
                
                set result [ixNetworkGetPortObjref $rp_vp_handle]
                if {([keylget result status] == $::SUCCESS) &&\
                        ([ixNet getA [keylget result vport_objref] -connectionInfo] != "")} {
                    continue
                }
                
                regexp {^(\d+)/(\d+)/(\d+)$} $realPort {} chassis_id card_id port_id
                set hostname [::ixia::getHostname $ixnetwork_chassis_list $chassis_id]
                
                if {$hostname == -1} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to find the ID associated to this\
                            chassis."
                    return $returnList
                }
                
                # Find the objref of real port.
                set realPortObjRef ::ixNet::OBJ-/availableHardware/chassis:\"$hostname\"/card:$card_id/port:$port_id
                
                # Build chassis object list to check license on them after all ports are added
                set tmpChObj ::ixNet::OBJ-/availableHardware/chassis:\"$hostname\"
                if {[lsearch $chassis_obj_list $tmpChObj] == -1} {
                    lappend chassis_obj_list $tmpChObj
                }
                catch {unset tmpChObj}
                
                if {[ixNet exists $realPortObjRef] == "false" || [ixNet exists $realPortObjRef] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to find the objref of the following\
                            port: $hostname/$card_id/$port_id."
                    return $returnList
                }
                
                if {$mode == "connect_vp_rp"} {
                    # Connect existing vport
                    set ret_val [ixNetworkGetPortObjref $rp_vp_handle]
                    if {[keylget ret_val status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Invalid port $rp_vp_handle. Not found in\
                                internal array."
                        return $returnList
                    }
                    set rp_vp_handle_obj [keylget ret_val vport_objref]
                    
                    set result [ixNetworkNodeSetAttr $rp_vp_handle_obj \
                            [list -connectedTo $realPortObjRef]]
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Could not create/connect $rp_vp_handle virtual port to\
                                real port: $realPort - [keylget result log]."
                        return $returnList
                    }
                    set vport_array_list($rp_vp_handle_obj) $rp_vp_handle
                    set tmp_port_object $rp_vp_handle_obj
                } else {
                    # Connect to vport previously created
                    set result [ixNetworkNodeSetAttr [ixNet remapIds $vports_legacy_array($realPort)] \
                            [list -connectedTo $realPortObjRef -name $rp_vp_handle]]
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Could not create a vport on the following\
                                port: $realPort - [keylget result log]."
                        return $returnList
                    }
                    set tmp_port_object $vports_legacy_array($realPort)
                    set vport_array_list($tmp_port_object) $rp_vp_handle
                }
                
                catch {unset tmp_port_object}
                
                set commit_needed 1
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
                
                debug "ixNet commit"
                if {[set retCode [ixNet commit]] != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not create/connect all vports on the following\
                                ports: $realPortList"
                    return $returnList
                }
            }
            
            
        
            set realPortList ""
            set commit_needed 0
            
            debug "Checking ports" chk_ports_ready_00
            foreach vportObjRef [array names vport_array_list] {
                
                if {$mode == "connect_vp_rp"} {
                    if {![ixNetworkPortIsConnected $vportObjRef]} {
                        if {[catch {ixNet exec connectPort $vportObjRef} err] || $err != "::ixNet::OK"} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to connect virtual port $vportObjRef. $err"
                            return $returnList
                        }
                    }
                }
                set realPort $vport_array_list($vportObjRef)
                debug "ixNet remapIds $vportObjRef"
                set vportObjRef [ixNet remapIds $vportObjRef]
                
#                 set chcapo_ref_idx [expr [lsearch [array get rp_vp_array] $realPort] - 1]
#                 set chcapo_ref [lindex [array get rp_vp_array] $chcapo_ref_idx]
                foreach rp_vp_elem [array names rp_vp_array] {
                    if {$rp_vp_array($rp_vp_elem) == $realPort} {
                        break;
                    }
                }
                set chcapo_ref $rp_vp_elem
                
                foreach {chassis_id card_id port_id} [split $chcapo_ref /] {}
                
                if {($chcapo_ref != "_tbd") && ($chassis_id == "" || $card_id == "" || $port_id == "")} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Internal error. Array index $chcapo_ref does not\
                            exist in internal array:\nrp_vp_array = [array get rp_vp_array]"
                    return $returnList
                }
                
                # Check if the port if in the correct aggregation mode
                 debug "Checking if port is usable in the current aggregation mode"
                if {![ixNet getAttribute [ixNet getAttribute $vportObjRef -connectedTo] -isUsable]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR: $vportObjRef port is not usable! Please\
                            check that the current aggregation mode of the card or the\
                            resource is valid for this port type"
                    return $returnList
                }
                
                # Reboot port CPU if necessary
                debug "ixNet getAttribute $vportObjRef -stateDetail"
                if {$::ixia::reboot_port_cpu && \
                        [ixNet getAttribute $vportObjRef -stateDetail] == "cpuNotReady"} {
                    ixNet exec resetPortCpu $vportObjRef
                    after 1000
                }
                
                # Loop while port state is unstable
                set num_retries 120
                debug "ixNet getAttribute $vportObjRef -stateDetail"
                while {([ixNet getAttribute $vportObjRef -stateDetail] != "idle") && \
                        ($num_retries > 0) } {
                    debug "ixNet getAttribute $vportObjRef -stateDetail"
                    after 500
                    incr num_retries -1
                }
                debug "ixNet getAttribute $vportObjRef -stateDetail"
                set result [ixNet getAttribute $vportObjRef -stateDetail]
                if {$result == "cpuNotReady" || \
                        $result == "l1ConfigFailed" || \
                        $result == "versionMismatched"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "'$result' encountered while connecting the\
                            $realPort real port to the following vport: $vportObjRef."
                    return $returnList
                }
                if {$result == "protocolsNotSupported"} {
                    ixPuts "Warning: Protocols are not supported for port $realPort ..."
                }
                # End loop
                
                # Reconnect port if necessary, Elmira's workaround for 401846
                set connection_info_retries 10
                set connection_info_status  ""
                set connection_status ""
                while {($connection_info_retries > 0) && \
                        ([set connection_info_status [ixNet getAttribute $vportObjRef -connectionInfo]] == "")} {
                    debug "ixNet getAttribute $vportObjRef -connectionInfo >> $connection_info_status"
                    set connection_status [ixNet getAttribute $vportObjRef -connectionStatus]
                    if { [regexp {Port Released} $connection_status] && [string trim $connection_status] != "Port Released"} {
                        ::ixia::guardrail_info
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to connect $realPort :$connection_status"
                        return $returnList
                    }
                    after 500
                    incr connection_info_retries -1
                }
                
                if {$connection_info_status == ""} {
                    lappend realPortList $chassis_id/$card_id/$port_id
                    if {$mode == "legacy"} {
                        debug "ixNet remove $vportObjRef"
                        ixNet remove $vportObjRef
                        set commit_needed 1
                    }
                    continue
                }
                
                # Enable statViewBrowser views
                if {[llength [array names ixnetwork_port_handles_array]] == 0} {
                    set _commit_needed 0
                    foreach statView [ixNet getList [ixNet getRoot]statistics statViewBrowser] {
                        if {[ixNet getAttribute $statView -enabled] == "false"} {
                            debug "ixNet setAttribute $statView -enabled true"
                            ixNet setAttribute $statView -enabled true
                            set _commit_needed 1
                        }
                    }
                    
                    if {$_commit_needed && [set retCode [ixNet commit]] != "::ixNet::OK"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Could not create/connect all vports on the following\
                                    ports: $realPortList"
                        return $returnList
                    }
                }
                
                # Add port to list(array actually...).
                # these 2 make a bidirectional dict
                set ixnetwork_port_handles_array($realPort) $vportObjRef
                set ixnetwork_port_handles_array_vport2rp($vportObjRef) $realPort
                set ixnetwork_real_port_handles_array($chcapo_ref) $vportObjRef
                #set ixnetwork_real_port_handles_array_vport2rp($vportObjRef) $chcapo_ref

                if {![info exists no_more_tclhal] || $no_more_tclhal == 0} {
                    set empty_owner 1
                    for {set i 0} {$i < 10} {incr i} {
                        debug "Retry $i to get port owner"
                        # Check if tclHal ownership matches ixTclNetwork ownership
                        debug "port get $chassis_id $card_id $port_id"
                        if {[port get $chassis_id $card_id $port_id]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to retrieve port $realPort configuration.\
                                    $::ixErrorInfo"
                            return $returnList
                        }
                        
                        debug "port cget -owner"
                        set port_owner [port cget -owner]
                        
                        # Added $i > 0 because the port is sometimes not ready the first time.
                        # there is no way to check it from tclHal
                        if {$port_owner != "" && $i > 0} {
                            set empty_owner 0
                        }
                
                        if {!$empty_owner} {
                            break
                        }
                
                        after 500
                    }
                
                    if {(!$empty_owner) && (![info exists session_owner_tclhal] || $session_owner_tclhal != $port_owner)} {
                        puts "\nWARNING: Forcing port ownership on port $realPort to '$port_owner'\
                                because IxNetwork default port ownership name can not be modified.\n"
                        set session_owner_tclhal $port_owner
                    }
                }
            }
            
            debug "Checking ports Done" chk_ports_ready_00
            
            incr global_retry_count -1
            
            if {$commit_needed} {
                debug "ixNet commit"
                ixNet commit
            }
        }
        
        
        if {[llength $realPortList] > 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to connect the following ports: $realPortList."
            return $returnList
        }
        
        foreach chassisObjRef $chassis_obj_list {
            # Check if license is retrived with a timeout - BUG492713
            ::ixia::debug "Checking license for $chassisObjRef"
            set waitCount     1
            set timeoutCount 30
            while {$waitCount < $timeoutCount} {
                if {[ixNet getAttribute $chassisObjRef -isLicensesRetrieved] == true} {
                    break;     
                }
                incr waitCount
                after 1000
            }
            if {$waitCount == $timeoutCount} {
                ixPuts "Warning: License retrival timed out for : $hostname"             
            }
            
            # Wait for license to be broadcast - BUG492713
            ixNet exec waitForLicenseBroadcast 5000
        }
        
        if {![info exists no_more_tclhal] || $no_more_tclhal == 0} {
            # When IxNetwork Tcl API is used, no tclHal ownership is taken.
            # We should always login here but display warning only if tclHal owner is 
            # different from IxNetwork owner
            if {[info exists port_owner]} {
                # port_owner exists only if the port is added (does not exists from previous configs)
                ixLogin $port_owner
            }
        }
    } else {
        # Add virtual ports
        # Get the id of the last vport (e.g. ::ixNet::OBJ-/vport:3 has id 3 and the handle will be 0/0/3)
        
        set vp_id [ixNetworkGetNextVportHandle]
        
        set ret_vport_list ""
        
        for {set i 0} {$i < $vport_requested_count} {incr i} {
            
            if {[info exists ixnetwork_port_handles_array($vp_id)]} {
                # This should never happen. ixNetworkGetNextVportHandle should return a unique handle
                keylset returnList status $::FAILURE
                keylset returnList log "Internal error. A port with handle '$vp_id'\
                        already exists and is connected to $ixnetwork_port_handles_array($vp_id)."
                return $returnList
            }
            
            # Create a new vport.
            set result [ixNetworkNodeAdd $root vport \
                    [list -name $vp_id]]
                    
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not create a vport on the following\
                        port: $realPort - [keylget result log]."
                return $returnList
            }
            
            set vport_array_list([keylget result node_objref]) $vp_id
            
            lappend ret_vport_list "$vp_id"
            
            scan $vp_id "%d/%d/%d" ch_id cd_id po_id
            incr po_id
            set vp_id $ch_id/$cd_id/$po_id
        }
        
        if {[set retCode [ixNet commit]] != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not create all vports on the following\
                        ports: $realPortList"
            return $returnList
        }
        
        set tmp_vport_list ""
        foreach vportObjRef [array names vport_array_list] {
            
            set realPort    $vport_array_list($vportObjRef)
            set vportObjRef [ixNet remapIds $vportObjRef]

            set ixnetwork_port_handles_array($realPort) $vportObjRef
            set ixnetwork_port_handles_array_vport2rp($vportObjRef) $realPort

            lappend tmp_vport_list $vportObjRef
        }
        
        # Configure arp for all protocols (objects must be grouped based on hierarchy)
        set retCode [ixNetworkEnableArp $tmp_vport_list]
        if {[keylget retCode status] != $::SUCCESS} {
            return $retCode
        }
        
        # Configure ping for all protocols (objects must be grouped based on hierarchy)
        set retCode [ixNetworkEnablePing $tmp_vport_list]
        if {[keylget retCode status] != $::SUCCESS} {
            return $retCode
        }
        
        if {[set retCode [ixNet commit]] != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not enable PING and ARP on all vports: $retCode"
            return $returnList
        }
        
        keylset returnList vport_list $ret_vport_list
    }
    
    
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::ixNetworkPortAdd {
    realPort
    vportObjRef
    {forcedClearOwnership no_force} 
    } {

    variable ixnetwork_chassis_list
    variable ixnetwork_port_handles_array
    variable ixnetwork_port_handles_array_vport2rp
    variable session_owner_tclhal

    # If the port is already assigned, don't add it again.
    # Look for the port handle.
    set result [ixNetworkGetPortObjref $realPort]
    if {[keylget result status] == $::SUCCESS} {
        keylset returnList status $::SUCCESS
        keylset returnList vport [keylget result vport_objref]
        return $returnList
    }

    # The port wasn't found. Add it.
    set root [ixNet getRoot]

    regexp {^(\d+)/(\d+)/(\d+)$} $realPort {} chassis_id card_id port_id
    set hostname [::ixia::getHostname $ixnetwork_chassis_list $chassis_id]
    
    if {$hostname == -1} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to find the ID associated to this\
                chassis."
        return $returnList
    }

    # Find the objref of real port.
    set chassisObjRef  ::ixNet::OBJ-/availableHardware/chassis:\"$hostname\"
    set realPortObjRef ::ixNet::OBJ-/availableHardware/chassis:\"$hostname\"/card:$card_id/port:$port_id
    
    if {[ixNet exists $realPortObjRef] == "false" || [ixNet exists $realPortObjRef] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to find the objref of the following\
                port: $hostname/$card_id/$port_id."
        return $returnList
    }
    
    if {$forcedClearOwnership == "force"} {
        debug "ixNet exec clearOwnership $realPortObjRef"
        if {[catch {ixNet exec clearOwnership $realPortObjRef} err]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to clear ownership on $hostname $card_id/$port_id. $err"
            return $returnList
        }
        
        debug "ixNet commit"
        if {[ixNet commit] != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not clear ownership on $hostname/$card_id/$port_id."
            return $returnList
        }
    }
    
    # Check if hardware isn't locked
    for {set i 0} {$i < 10} {incr i} {
        set is_locked [ixNet getA [ixNet getRoot]availableHardware -isLocked]
        debug "ixNet getA [ixNet getRoot]availableHardware -isLocked --> $is_locked"
        if {$is_locked == "false"} {
            break
        }
        after 1000
    }
    
    # Create a new vport.
    set result [ixNetworkNodeAdd $root vport \
            [list -connectedTo $realPortObjRef -name $realPort] -commit]
    if {[keylget result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Could not create a vport on the following\
                port: $realPort - [keylget result log]."
        return $returnList
    }
    set vportObjRef [keylget result node_objref]
    # Reboot port CPU if necessary
    if {$::ixia::reboot_port_cpu && \
            [ixNet getAttribute $vportObjRef -stateDetail] == "cpuNotReady"} {
        ixNet exec resetPortCpu $vportObjRef
        after 1000
    }
    # Loop while port state is unstable
    set num_retries 120
    debug "ixNet getAttribute $vportObjRef -stateDetail"
    while {([ixNet getAttribute $vportObjRef -stateDetail] != "idle") && \
            ($num_retries > 0) } {
        debug "ixNet getAttribute $vportObjRef -stateDetail"
        after 500
        incr num_retries -1
    }
    debug "ixNet getAttribute $vportObjRef -stateDetail"
    set result [ixNet getAttribute $vportObjRef -stateDetail]
    if {$result == "cpuNotReady" || \
            $result == "l1ConfigFailed" || \
            $result == "versionMismatched"} {
        keylset returnList status $::FAILURE
        keylset returnList log "'$result' encountered while connecting the\
                $realPort real port to the following vport: $vportObjRef."
        return $returnList
    }
    if {$result == "protocolsNotSupported"} {
        ixPuts "Warning: Protocols are not supported for port $realPort ..."
    }
    # End loop
    
    # Reconnect port if necessary, Elmira's workaround for 401846
    set reconnect_retries 3
    while {([ixNet getAttribute $vportObjRef -connectionInfo] == "") && \
            ($reconnect_retries > 0)} {
        debug "ixNet exec connectPort $vportObjRef"
        if {[catch {ixNet exec connectPort $vportObjRef} _err] && \
                ![regexp {already connected} $_err]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to run the connectPort on the\
                    $vportObjRef port object reference."
            return $returnList
        }
        after 1000
        incr reconnect_retries -1
        
        # Loop while port state is unstable
        set num_retries 120
        debug "ixNet getAttribute $vportObjRef -stateDetail"
        while {([ixNet getAttribute $vportObjRef -stateDetail] != "idle") && \
                ($num_retries > 0) } {
            debug "ixNet getAttribute $vportObjRef -stateDetail"
            after 500
            incr num_retries -1
        }
        debug "ixNet getAttribute $vportObjRef -stateDetail"
        set result [ixNet getAttribute $vportObjRef -stateDetail]
        if {$result == "cpuNotReady" || \
                $result == "l1ConfigFailed" || \
                $result == "versionMismatched"} {
            keylset returnList status $::FAILURE
            keylset returnList log "'$result' encountered while connecting the\
                    $realPort real port to the following vport: $vportObjRef."
            return $returnList
        }
        if {$result == "protocolsNotSupported"} {
            ixPuts "Warning: Protocols are not supported for port $realPort ..."
        }
        # End loop
    }
    
    if {[ixNet getAttribute $vportObjRef -connectionInfo] == ""} {
        keylset returnList status $::FAILURE
        keylset returnList log "Error encountered while connecting the\
                $realPort real port to the following vport: $vportObjRef."
        return $returnList
    }

    # Check if license is retrived with a timeout - BUG492713
    set waitCount     1
    set timeoutCount 30
    while {$waitCount < $timeoutCount} {
        if {[ixNet getAttribute $chassisObjRef -isLicensesRetrieved] == true} {
            break;     
        }
        incr waitCount
        after 1000
    }
    if {$waitCount == $timeoutCount} {
        ixPuts "Warning: License retrival timed out for : $hostname"             
    }
    
    # Wait for license to be broadcast - BUG492713
    ixNet exec waitForLicenseBroadcast 5000
    
    # Enable statViewBrowser views
    if {[llength [array names ixnetwork_port_handles_array]] == 0} {
        foreach statView [ixNet getList [ixNet getRoot]statistics statViewBrowser] {
            if {[ixNet getAttribute $statView -enabled] == "false"} {
                debug "ixNet setAttribute $statView -enabled true"
                ixNet setAttribute $statView -enabled true
                debug "ixNet commit"
                ixNet commit
            }
        }
    }
    
    # Add port to list(array actually...).
    # bidirectional dict
    set ixnetwork_port_handles_array($realPort) $vportObjRef
    set ixnetwork_port_handles_array_vport2rp($vportObjRef) $realPort
    
    if {![info exists no_more_tclhal] || $no_more_tclhal == 0} {
        set empty_owner 1
        for {set i 0} {$i < 10} {incr i} {
            debug "Retry $i to get port owner"
            # Check if tclHal ownership matches ixTclNetwork ownership
            debug "port get $chassis_id $card_id $port_id"
            if {[port get $chassis_id $card_id $port_id]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to retrieve port $realPort configuration.\
                        $::ixErrorInfo"
                return $returnList
            }
            
            debug "port cget -owner"
            set port_owner [port cget -owner]
            
            if {$port_owner != ""} {
                set empty_owner 0
            }
    
            if {!$empty_owner} {
                break
            }
    
            after 500
        }
    
        if {(!$empty_owner) && (![info exists session_owner_tclhal] || $session_owner_tclhal != $port_owner)} {
            puts "\nWARNING: Forcing port ownership on port $realPort to '$port_owner'\
                    because IxNetwork default port ownership name can not be modified.\n"
            set session_owner_tclhal $port_owner
        }
    
    
        # When IxNetwork Tcl API is used, no tclHal ownership is taken.
        # We should always login here but display warning only if tclHal owner is 
        # different from IxNetwork owner
        if {[info exists port_owner]} {
            ixLogin $port_owner
        }
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList vport  $vportObjRef
    return $returnList
}


proc ::ixia::IxNetworkPortL1Config {} {
    uplevel {
        keylset return_status status $::SUCCESS
        if {$proc_nr == 2} {
            set intf_type_list ""
        }
        foreach interface $intf_list {
            scan $interface "%d %d %d" chassis card port
            
            set ixnetwork_port_handle $chassis/$card/$port
            
            if {$do_set_default == 0} {
                continue
            }
            
            # Configure the physical layer of the port
            if {[lsearch $unique_intf_list $interface] == -1} {
                # Passed in only the options that exist
                set l1_port_args ""
                foreach {option value_name} [set l1_port_options$proc_nr] {
                    if {[info exists $value_name]} {
                        if {[llength $l1_port_args] > 0} {
                            if {[llength [set $value_name]] > 1 && $value_name != "fcoe_priority_groups"} {
                                append l1_port_args " $option [lindex [set $value_name] $option_index]"
                            } else {
                                append l1_port_args " $option [set $value_name]"
                            }
                        } else {
                            append l1_port_args "$option [lindex [set $value_name] $option_index]"
                        }
                    } elseif {![info exists mode] || \
                            ([info exists mode] && ([lindex $mode $option_index] == "config"))} {
                        set default_pos [lsearch $l1_port_default_options $value_name]
                        if {$default_pos != -1} {
                            if {[llength $l1_port_args] > 0} {
                                append l1_port_args " $option [lindex \
                                        $l1_port_default_options [expr $default_pos + 1]]"
                            } else {
                                append l1_port_args "$option [lindex \
                                        $l1_port_default_options [expr $default_pos + 1]]"
                            }
                        }
                    }
                }
                # Check whether any physical layer attributes have been passed to
                # this procedure
                
                if {[llength $l1_port_args] > 0} {
                    append l1_port_args " -port_handle $ixnetwork_port_handle"
                    set return_status [eval ixNetworkPortL1Config$proc_nr $l1_port_args]
                    if {[keylget return_status status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName:\
                                [keylget return_status log]"
                        return $returnList
                    }
                    if {$proc_nr == 2} {
                        lappend intf_type_list [keylget return_status intf_type_key]
                    }
                } else {
                    keylset return_status status $::SUCCESS
                }
                lappend unique_intf_list $interface
            }
            incr option_index
        }
    }
}

# this procedure is called by ::ixia::ixNetworkPortL1Config
proc ::ixia::ixNetworkPortL1Config1 { args } {
    variable truth
    keylset returnList commit_needed 0
    
    set man_args {
        -port_handle
    }
    set opt_args {
        -autonegotiation                CHOICES 0 1
        -duplex                         CHOICES half full auto
        -intf_mode                      CHOICES atm pos_hdlc pos_ppp ethernet ethernet_vm
                                        CHOICES multis multis_fcoe
                                        CHOICES frame_relay1490
                                        CHOICES frame_relay2427
                                        CHOICES frame_relay_cisco ethernet_fcoe
                                        CHOICES fc
        -phy_mode                       CHOICES copper fiber
        -speed                          CHOICES ether10 ether100 ether1000
                                        CHOICES auto oc3 oc12 oc48 oc192
                                        CHOICES ether10000wan ether10000lan 
                                        CHOICES ether40000lan ether100000lan
                                        CHOICES ether10Gig ether40Gig ether100Gig
                                        CHOICES fc2000 fc4000 fc8000
                                        CHOICES ether100vm ether1000vm ether10000vm
                                        CHOICES ether2000vm ether3000vm ether4000vm
                                        CHOICES ether5000vm ether6000vm ether7000vm
                                        CHOICES ether8000vm ether9000vm
        -ignore_link                    CHOICES 0 1
        -clause73_autonegotiation       CHOICES 0 1
        -laser_on                       CHOICES 0 1
        -tx_ignore_rx_link_faults       CHOICES 0 1
    }
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing.\
                Parameter or parameter value is not supported with IxTclNetwork. $parse_error. "
        return $returnList
    }
    set not_supported       N/A
    set otherwise_supported  /A
    
    # Get the port object reference
    set result [ixNetworkGetPortObjref $port_handle]
    if {[keylget result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Could not find any vport which uses the\
                $port_handle port - [keylget result log]."
        return $returnList
    } else {
        set port_objref [keylget result vport_objref]
    }
        
    # Setting ignore link when transmit attribute if it is present
    if {[info exists ignore_link]} {
        debug "ixNet setAttr $port_objref -transmitIgnoreLinkStatus\
                $ignore_link"
        if {[catch {ixNet setAttr $port_objref -transmitIgnoreLinkStatus\
                $ignore_link} errorMsg]} {
            keylset returnList status $::FAILURE
            keylset returnList log "$errorMsg."
            return $returnList
        }
    }

    # Determine the interface type
    if {[info exists intf_mode]} {
        switch -- $intf_mode {
            "atm" {
                set intf_type atm
            }
            "pos_ppp" -
            "pos_hdlc" -
            "frame_relay1490" -
            "frame_relay2427" -
            "frame_relay_cisco" {
                set intf_type pos
            }
            "ethernet_vm"
            {
                set intf_type "ethernetvm"
            }
            "multis"
            {
                set intf_type "tenFortyHundredGigLan"
            }
            "multis_fcoe"
            {
                set intf_type "tenFortyHundredGigLanFcoe"
            }
            "ethernet_fcoe" {
                if {[info exists speed]} {
                    switch -- $speed {
                        "ether10000lan" {
                            set intf_type tenGigLanFcoe
                        }
                        "ether10000wan" {
                            set intf_type tenGigWanFcoe
                        }
                        "ether40000lan" -
                        "ether40Gig" {
                            set intf_type fortyGigLanFcoe
                        }
                        "ether100000lan" -
                        "ether100Gig" {
                            set intf_type hundredGigLanFcoe
                        }
                        default {
                            set intf_type ethernetFcoe
                        }
                    }
                } else {
                    set intf_type ethernetFcoe
                }
            }
            "fc" {
                set intf_type fc
            }
            "ethernet" {
                if {[info exists speed]} {
                    switch -- $speed {
                        "ether10000lan" {
                            set intf_type tenGigLan
                        }
                        "ether10000wan" {
                            set intf_type tenGigWan
                        }
                        "ether40000lan" -
                        "ether40Gig" {
                            if {[ixNet getAttribute $port_objref -type] == "hundredGigLan"} {
                                set intf_type hundredGigLan
                            } else {
                                set intf_type fortyGigLan
                            }
                        }
                        "ether100000lan" -
                        "ether100Gig" {
                            set intf_type hundredGigLan
                        }
                        default {
                            set intf_type "ethernet"
                        }
                    }
                } else {
                    set intf_type "ethernet"
                }
            }
            default {
                set intf_type [ixNet getAttribute $port_objref/l1Config -currentType]
            }
        }
    } else {
        # Get the default port mode
        if {[catch {set intf_type [ixNet getAttribute $port_objref -type]} \
                error_msg]} {
            keylset returnList log "Failure in ixNetworkPortL1Config:\
                    encountered an error while executing: \
                    ixNet getAttribute $port_objref -type\
                    - $error_msg"
            keylset returnList status $::FAILURE
            return $returnList
        }
        
        set tmpPort [::ixia::ixNetworkGetRouterPort $port_objref]
        if {$tmpPort != "0/0/0"} {
            foreach {tmpCh tmpCa tmpPo} [split $tmpPort "/"] {}
        } else {
            keylset returnList log "Failure in ixNetworkPortL1Config:\
                    encountered an error while executing: \
                    ::ixia::ixNetworkGetRouterPort $port_objref"
            keylset returnList status $::FAILURE
            return $returnList
        }
        
        # Check the rest of the options for relevant information
        if {[info exists speed] && $speed == "ether40000lan"} {
            if {[ixNet getAttribute $port_objref -type] == "hundredGigLan"} {
                set intf_type hundredGigLan
            } else {
                set intf_type fortyGigLan
            }
        } elseif {[info exists speed] && $speed == "ether100000lan"} {
            set intf_type hundredGigLan
        } elseif {[info exists speed] && $speed == "ether40Gig"} {
            if {[ixNet getAttribute $port_objref -type] == "hundredGigLan"} {
                set intf_type hundredGigLan
            } else {
                set intf_type fortyGigLan
            }
        } elseif {[info exists speed] && $speed == "ether100Gig"} {
            set intf_type hundredGigLan
        } elseif {[info exists speed] && $speed == "ether10000lan"} {
            set intf_type tenGigLan
        } elseif {[info exists speed] && $speed == "ether10Gig"} {
            set intf_type tenGigLan
        } elseif {[info exists speed] && $speed == "ether10000wan"} {
            set intf_type tenGigWan
        } elseif {[info exists phy_mode]  || \
                ([info exists speed] && \
                ($speed == "auto" || $speed == "ether10" || \
                $speed == "ether100" || $speed == "ether1000"))} {
            set intf_type ethernet
            if {[info exists phy_mode] && ![info exists speed]} {
                if {$phy_mode == "copper"} {
                    set speed ether100
                } else {
                    set speed ether1000
                }
            }
            if {[info exists speed] && $speed == "ether1000"} {
                set duplex auto
            }
        } elseif {[info exists fcs]} {
            set intf_type pos
            set intf_mode "pos_hdlc"
        } else {
            if {![info exists no_more_tclhal] || $no_more_tclhal == 0} {
                if {[port isValidFeature $tmpCh $tmpCa $tmpPo portFeaturePos]} {
                    set intf_type pos
                    set intf_mode "pos_ppp"
                }
            } else {
                set card_obj_ref_real [ixNetworkGetParentObjref [ixNet getA $port_objref -connectedTo] "card"]
                if {[regexp -nocase {pos} [ixNet getA $card_obj_ref_real -description]]} {
                    set intf_type pos
                    set intf_mode "pos_ppp"
                }
            }
        }
    }
   
    # Check if autonegotiation is enabled on Ethernet
    if {!([info exists autonegotiation] && $autonegotiation == 0) && \
            $intf_type == "ethernet"} {
        if {[info exists duplex]} {
            unset duplex
        }
        if {[info exists speed]} {
            unset speed
        }
    }
    # Configure the port type
    if {[ixNet getAttribute $port_objref/l1Config -currentType] != $intf_type} {
        set result [ixNetworkNodeSetAttr $port_objref/l1Config \
                [list -currentType $intf_type]]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList log "Failure in ixNetworkPortL1Config:\
                    encountered an error while executing: \
                    ixNetworkNodeSetAttr $port_objref/l1Config [list -currentType\
                    $intf_type] - [keylget result log]"
            keylset returnList status $::FAILURE
            return $returnList
        }
        keylset returnList commit_needed 1
    }
    
    # Check if the port type was correctly configured
    if {[ixNet getAttribute $port_objref/l1Config -currentType] != $intf_type} {
        keylset returnList log "The port interface type is determined based on\
                the values provided to parameters like -intf_mode, -speed, -autonegotiation, duplex, -clocksource.\
                In this case the combination provided is not a valid combination for this card.\
                Current card type is '[ixNet getAttribute $port_objref/l1Config -currentType]'.\
                The requested interface type is '$intf_type'.\
                The value is an invalid option for the '$port_handle' port."
        keylset returnList status $::FAILURE
        return $returnList
    }
    
    # Check if clause 73 autonegotiation is valid for Multis
    if {([info exists clause73_autonegotiation] && $clause73_autonegotiation == 1)} {
        if {$intf_type != "tenFortyHundredGigLan" &&  $intf_type != "tenFortyHundredGigLanFcoe" } {
            keylset returnList log "The clause73_autonegotiation argument is valid only for 40G/100G Multis cards that \
                support 802.3ba auto negotiation. Your card type ($intf_type) is not valid."
            keylset returnList status $::FAILURE
            return $returnList
        }
    }
    
     # Check if clause laser_on is valid for Multis
    if {([info exists laser_on] && $laser_on == 1)} {
        if {$intf_type != "tenFortyHundredGigLan" &&  $intf_type != "tenFortyHundredGigLanFcoe" } {
            keylset returnList log "The laser_on argument is valid only for Multis cards.\
                Your card type ($intf_type) is not valid."
            keylset returnList status $::FAILURE
            return $returnList
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}
# this procedure is called by ::ixia::ixNetworkPortL1Config
proc ::ixia::ixNetworkPortL1Config2 { args } {
    variable truth
    keylset returnList commit_needed 0
    set man_args {
        -port_handle
    }
    set opt_args {
        -auto_detect_instrumentation_type CHOICES end_of_frame floating
        -autonegotiation                CHOICES 0 1
        -atm_enable_coset               CHOICES 0 1
        -atm_enable_pattern_matching    CHOICES 0 1
        -atm_filler_cell                CHOICES idle unassigned
        -atm_interface_type             CHOICES uni nni
        -atm_reassembly_timeout         NUMERIC
        -clocksource                    CHOICES internal loop external
        -clause73_autonegotiation       CHOICES 0 1
        -laser_on                       CHOICES 0 1
        -duplex                         CHOICES half full auto
        -framing                        CHOICES sonet sdh
                                        DEFAULT sonet
        -internal_ppm_adjust            ANY
        -intf_mode                      CHOICES atm pos_hdlc pos_ppp ethernet
                                        CHOICES multis multis_fcoe ethernet_vm
                                        CHOICES frame_relay1490
                                        CHOICES frame_relay2427
                                        CHOICES frame_relay_cisco ethernet_fcoe
                                        CHOICES fc
        -op_mode                        CHOICES loopback normal sim_disconnect
        -phy_mode                       CHOICES copper fiber
        -port_rx_mode                   CHOICES capture_and_measure capture packet_group data_integrity sequence_checking wide_packet_group echo auto_detect_instrumentation
        -rx_c2
        -speed                          CHOICES ether10 ether100 ether1000
                                        CHOICES auto oc3 oc12 oc48 oc192
                                        CHOICES ether10000wan ether10000lan 
                                        CHOICES ether40000lan ether100000lan
                                        CHOICES ether40Gig ether100Gig
                                        CHOICES fc2000 fc4000 fc8000
                                        CHOICES ether100vm ether1000vm ether10000vm
                                        CHOICES ether2000vm ether3000vm ether4000vm
                                        CHOICES ether5000vm ether6000vm ether7000vm
                                        CHOICES ether8000vm ether9000vm
        -transmit_clock_source          CHOICES internal bits loop external internal_ppm_adj
        -tx_c2
        -rx_fcs                         CHOICES 16 32
        -rx_scrambling                  CHOICES 0 1
        -tx_fcs                         CHOICES 16 32
        -tx_scrambling                  CHOICES 0 1
        -enable_flow_control            CHOICES 0 1
        -flow_control_directed_addr     ANY
        -fcoe_priority_groups           ANY
        -fcoe_support_data_center_mode  CHOICES 0 1
        -fcoe_priority_group_size       CHOICES 4 8
        -fcoe_flow_control_type         CHOICES ieee802.3x ieee802.1Qbb
        -fc_credit_starvation_value     NUMERIC
        -fc_no_rrdy_after               NUMERIC
        -tx_ignore_rx_link_faults       CHOICES 0 1 
        -fc_max_delay_for_random_value  NUMERIC
        -fc_tx_ignore_available_credits CHOICES 0 1
        -fc_min_delay_for_random_value  NUMERIC
        -fc_rrdy_response_delays        CHOICES credit_starvation fixed_delay no_delay random_delay
        -fc_fixed_delay_value           NUMERIC
        -fc_force_errors                CHOICES no_errors no_rrdy no_rrdy_every
    }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing.\
                Parameter or parameter value is not supported with IxTclNetwork. $parse_error. "
        return $returnList
    }
    set result [ixNetworkGetPortObjref $port_handle]
    if {[keylget result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Could not find any vport which uses the\
                $port_handle port - [keylget result log]."
        return $returnList
    } else {
        set port_objref [keylget result vport_objref]
    }
    set intf_type [ixNet getAttribute $port_objref/l1Config -currentType]
    

    # Check if autonegotiation is enabled on Ethernet
    if {!([info exists autonegotiation] && $autonegotiation == 0) && \
            $intf_type == "ethernet"} {
        if {[info exists duplex]} {
            unset duplex
        }
        if {[info exists speed]} {
            unset speed
        }
    }
    
    if {[info exists op_mode]} {
        if {$op_mode == "sim_disconnect"} {
            unset op_mode
        }
    }
    
    if [info exists internal_ppm_adjust] {
        regsub (^@) $internal_ppm_adjust - internal_ppm_adjust
    }
    
    set not_supported       N/A
    set otherwise_supported  /A
    
    
    array set translate_adit {
        end_of_frame    endOfFrame
        floating        floating
    }

    if {![info exists auto_detect_instrumentation_type]} {
        if {[info exists port_rx_mode] && $port_rx_mode == "auto_detect_instrumentation"} {
            set auto_detect_instrumentation_type floating
        } else {
            set auto_detect_instrumentation_type end_of_frame
        }
    }

    if {[info exists rx_scrambling] && ![info exists tx_scrambling]} {
        set scrambling $rx_scrambling
    } elseif {![info exists rx_scrambling] && [info exists tx_scrambling]} {
        set scrambling $tx_scrambling
    } elseif {[info exists rx_scrambling] && [info exists tx_scrambling]}  {
        set scrambling [expr $rx_scrambling || $tx_scrambling]
    } else {
        set scrambling 1
    }

    if {[info exists rx_fcs] && ![info exists tx_fcs]} {
        set fcs $rx_fcs
    } elseif {![info exists rx_fcs] && [info exists tx_fcs]} {
        set fcs $tx_fcs
    } elseif {[info exists rx_fcs] && [info exists tx_fcs]} {
        if {$rx_fcs == 32 || $tx_fcs == 32} { set fcs 32 } else { set fcs 16 }
    } else {
        set fcs 16
    }
    
    array set translate_op_mode [list               \
        loopback                    true            \
        normal                      false           \
    ]

    array set translate_phy_mode [list              \
        copper                      copper          \
        fiber                       fiber           \
    ]
    
    
    array set translate_40g_speed [list            \
        ether40000lan               speed40g       \
        ether40Gig                  speed40g       \
        auto                        speed40g       \
    ]
    
    array set translate_100g_speed [list            \
        ether100000lan              speed100g       \
        ether100Gig                 speed100g       \
        ether40000lan               speed40g        \
        ether40Gig                  speed40g        \
        ether10000lan               speed10g        \
        ether10Gig                  speed10g        \
        auto                        speed100g       \
    ]
    
    array set translate_vm_speed [list            \
        ether100vm     speed100     \
        ether1000vm    speed1000    \
        ether2000vm    speed2000    \
        ether3000vm    speed3000    \
        ether4000vm    speed4000    \
        ether5000vm    speed5000    \
        ether6000vm    speed6000    \
        ether7000vm    speed7000    \
        ether8000vm    speed8000    \
        ether9000vm    speed9000    \
        ether10000vm   speed10g     \
        ether100       speed100     \
        ether10Gig     speed10g     \
        ether1000      speed1000    \
    ]
    
    array set translate_ethernet_speed [list        \
        auto,auto                   $not_supported  \
        ether10,auto                $not_supported  \
        ether100,auto               $not_supported  \
        ether1000,auto              speed1000       \
        auto,half                   $not_supported  \
        ether10,half                speed10hd       \
        ether100,half               speed100hd      \
        ether1000,half              speed1000       \
        auto,full                   $not_supported  \
        ether10,full                speed10fd       \
        ether100,full               speed100fd      \
        ether1000,full              speed1000       \
    ]

    array set translate_atm_interface_type [list    \
        uni                         uni             \
        nni                         nni             \
    ]

    array set translate_atm_filler_cell [list       \
        idle                        idle            \
        unassigned                  unassigned      \
    ]

    array set translate_atm_speed [list             \
        oc3,sonet                   oc3             \
        oc3,sdh                     stm1            \
        oc12,sonet                  oc12            \
        oc12,sdh                    stm4            \
    ]

    array set translate_clocksource [list           \
        internal                    internal        \
        loop                        recovered       \
        external                    external        \
    ]

    array set translate_fcs [list                   \
         16                         crc16           \
         32                         crc32           \
    ]

    array set translate_pos_intf_mode [list        \
        pos_ppp                    ppp             \
        pos_hdlc                   ciscoHdlc       \
        frame_relay1490            frameRelay      \
        frame_relay2427            frameRelay      \
        frame_relay_cisco          ciscoFrameRelay \
    ]

    array set translate_pos_speed [list             \
        oc3,sonet                   oc3             \
        oc3,sdh                     stm1            \
        oc12,sonet                  oc12            \
        oc12,sdh                    stm4            \
        oc48,sonet                  oc48            \
        oc48,sdh                    stm16           \
        oc192,sonet                 oc192           \
        oc192,sdh                   stm64           \
    ]

    array set translate_framing [list               \
        sonet                       wanSonet        \
        sdh                         wanSdh          \
    ]
    
    array set translate_ppm [list           \
        internal_ppm_adj        true        \
        internal                false       \
        bits                    false       \
        loop                    false       \
        external                false       \
    ]
    array set translate_fc_speed [list      \
        fc2000                  speed2000   \
        fc4000                  speed4000   \
        fc8000                  speed8000   \
    ]
    array set translate_response_delays [list\
        credit_starvation       creditStarvation\
        fixed_delay             fixedDelay  \
        no_delay                noDelay     \
        random_delay            randomDelay \
    ]
    array set translate_force_errors [list  \
        no_errors                noErrors   \
        no_rrdy                  noRRDY     \
        no_rrdy_every            noRRDYEvery\
    ]
    switch -- $intf_type {
        "atm" {
            # Create ATM attributes list
            set l1_port_options "                                                                   \
                    -c2Expected         hex                             rx_c2                       \
                    -c2Tx               hex                             tx_c2                       \
                    -cellHeader         translate_atm_interface_type    atm_interface_type          \
                    -cosetActive        truth                           atm_enable_coset            \
                    -dataScrambling     truth                           scrambling                  \
                    -enablePPM          translate_ppm                   transmit_clock_source       \
                    -fillerCell         translate_atm_filler_cell       atm_filler_cell             \
                    -interfaceType      translate_atm_speed             speed,framing               \
                    -loopback           translate_op_mode               op_mode                     \
                    -patternMatching    truth                           atm_enable_pattern_matching \
                    -ppm                range                           internal_ppm_adjust         \
                    -reassemblyTimeout  none                            atm_reassembly_timeout      \
                    -transmitClocking   translate_clocksource           clocksource                 \
                    "
        }
        "ethernetvm"  {
            set l1_port_options "                                                                         \
                    -speed                          translate_vm_speed          speed                     \
                    "
        }
        "ethernet" -
        "ethernetFcoe" {
            # Create ethernet attributes list
            set l1_port_options "                                                                         \
                    -autoNegotiate                  truth                       autonegotiation           \
                    -loopback                       translate_op_mode           op_mode                   \
                    -media                          translate_phy_mode          phy_mode                  \
                    -speed                          translate_ethernet_speed    speed,duplex              \
                    -enabledFlowControl             truth                       enable_flow_control       \
                    -flowControlDirectedAddress     mac                         flow_control_directed_addr\
                    -enablePPM                      translate_ppm               transmit_clock_source     \
                    -ppm                            range                       internal_ppm_adjust       \
                    -autoInstrumentation            translate_adit              auto_detect_instrumentation_type\
                    "
            
            set l1_fcoe_options "
                    -pfcPriorityGroups              priority_groups_parse       fcoe_priority_groups      \
                    -supportDataCenterMode          truth                       fcoe_support_data_center_mode\
                    -priorityGroupSize              p_group_translate           fcoe_priority_group_size  \
                    -flowControlType                none                        fcoe_flow_control_type    \
                    "
        }
        "fc" {
            # Create fc attributes list
            set l1_port_options "                                                                         \
                    -creditStarvationValue          none                        fc_credit_starvation_value\
                    -noRRDYAfter                    none                        fc_no_rrdy_after          \
                    -txIgnoreRxLinkFaults           truth                       tx_ignore_rx_link_faults  \
                    -enablePPM                      translate_ppm               transmit_clock_source     \
                    -speed                          translate_fc_speed          speed                     \
                    -loopback                       translate_op_mode           op_mode                   \
                    -maxDelayForRandomValue         none                        fc_max_delay_for_random_value\
                    -txIgnoreAvailableCredits       truth                       fc_tx_ignore_available_credits\
                    -minDelayForRandomValue         none                        fc_min_delay_for_random_value\
                    -rrdyResponseDelays             translate_response_delays   fc_rrdy_response_delays      \
                    -fixedDelayValue                none                        fc_fixed_delay_value         \
                    -forceErrors                    translate_force_errors      fc_force_errors              \
                    -ppm                            range                       internal_ppm_adjust       \
                    "
        }
        "fortyGigLan"   {
            # Create 40G LAN ethernet attributes list
            set l1_port_options "                                                                         \
                    -loopback                       translate_op_mode           op_mode                   \
                    -speed                          translate_40g_speed        speed                     \
                    -enablePPM                      translate_ppm               transmit_clock_source     \
                    -ppm                            range                       internal_ppm_adjust       \
                    -autoInstrumentation            translate_adit              auto_detect_instrumentation_type\
                    -txIgnoreRxLinkFaults           truth                       tx_ignore_rx_link_faults\
                    "
        }
        "hundredGigLan" {
            # Create 100G LAN ethernet attributes list
            set l1_port_options "                                                                         \
                    -loopback                       translate_op_mode           op_mode                   \
                    -speed                          translate_100g_speed        speed                     \
                    -enablePPM                      translate_ppm               transmit_clock_source     \
                    -ppm                            range                       internal_ppm_adjust       \
                    -autoInstrumentation            translate_adit              auto_detect_instrumentation_type\
                    -txIgnoreRxLinkFaults           truth                       tx_ignore_rx_link_faults\
                    "
        }
        "fortyGigLanFcoe"   {
            # Create 40G LAN Fcoe ethernet attributes list
            set l1_port_options "                                                                         \
                    -loopback                       translate_op_mode           op_mode                   \
                    -speed                          translate_40g_speed         speed                     \
                    -enablePPM                      translate_ppm               transmit_clock_source     \
                    -ppm                            range                       internal_ppm_adjust       \
                    -autoInstrumentation            translate_adit              auto_detect_instrumentation_type\
                    -txIgnoreRxLinkFaults           truth                       tx_ignore_rx_link_faults\
                    "
            set l1_fcoe_options "
                    -pfcPriorityGroups              priority_groups_parse       fcoe_priority_groups      \
                    -supportDataCenterMode          truth                       fcoe_support_data_center_mode\
                    -priorityGroupSize              p_group_translate           fcoe_priority_group_size  \
                    -flowControlType                none                        fcoe_flow_control_type    \
                    "
        }
        "hundredGigLanFcoe" {
            # Create 100G LAN Fcoe ethernet attributes list
            set l1_port_options "                                                                         \
                    -loopback                       translate_op_mode           op_mode                   \
                    -speed                          translate_100g_speed        speed                     \
                    -enablePPM                      translate_ppm               transmit_clock_source     \
                    -ppm                            range                       internal_ppm_adjust       \
                    -autoInstrumentation            translate_adit              auto_detect_instrumentation_type\
                    -txIgnoreRxLinkFaults           truth                       tx_ignore_rx_link_faults\
                    "
            set l1_fcoe_options "
                    -pfcPriorityGroups              priority_groups_parse       fcoe_priority_groups      \
                    -supportDataCenterMode          truth                       fcoe_support_data_center_mode\
                    -priorityGroupSize              p_group_translate           fcoe_priority_group_size  \
                    -flowControlType                none                        fcoe_flow_control_type    \
                    "
        }
        "tenFortyHundredGigLan" {
            # Create 10G/40G/100G LAN ethernet attributes list
            set l1_port_options "                                                                         \
                    -loopback                       translate_op_mode           op_mode                   \
                    -speed                          translate_100g_speed        speed                     \
                    -enablePPM                      translate_ppm               transmit_clock_source     \
                    -ppm                            range                       internal_ppm_adjust       \
                    -autoInstrumentation            translate_adit              auto_detect_instrumentation_type\
                    -enabledFlowControl             truth                       enable_flow_control       \
                    -flowControlDirectedAddress     mac                         flow_control_directed_addr\
                    -enableAutoNegotiation          truth                       clause73_autonegotiation  \
                    -laserOn                        truth                       laser_on                  \
                    -txIgnoreRxLinkFaults           truth                       tx_ignore_rx_link_faults\
                    "
        }
        "tenFortyHundredGigLanFcoe" {
            # Create 10G/40G/100G LAN ethernet attributes list
            set l1_port_options "                                                                         \
                    -loopback                       translate_op_mode           op_mode                   \
                    -speed                          translate_100g_speed        speed                     \
                    -enablePPM                      translate_ppm               transmit_clock_source     \
                    -ppm                            range                       internal_ppm_adjust       \
                    -autoInstrumentation            translate_adit              auto_detect_instrumentation_type\
                    -enabledFlowControl             truth                       enable_flow_control       \
                    -flowControlDirectedAddress     mac                         flow_control_directed_addr\
                    -enableAutoNegotiation          truth                       clause73_autonegotiation  \
                    -laserOn                        truth                       laser_on                  \
                    -txIgnoreRxLinkFaults           truth                       tx_ignore_rx_link_faults\
                    "
            set l1_fcoe_options "
                    -pfcPriorityGroups              priority_groups_parse       fcoe_priority_groups      \
                    -supportDataCenterMode          truth                       fcoe_support_data_center_mode\
                    -priorityGroupSize              p_group_translate           fcoe_priority_group_size  \
                    -flowControlType                none                        fcoe_flow_control_type    \
                    "
        }        
        "tenGigLan" {
            # Create 10G LAN ethernet attributes list
            set l1_port_options "                                                                         \
                    -loopback                       translate_op_mode           op_mode                   \
                    -transmitClocking               translate_clocksource       clocksource               \
                    -enabledFlowControl             truth                       enable_flow_control       \
                    -flowControlDirectedAddress     mac                         flow_control_directed_addr\
                    -enablePPM                      translate_ppm               transmit_clock_source     \
                    -ppm                            range                       internal_ppm_adjust       \
                    -autoInstrumentation            translate_adit              auto_detect_instrumentation_type\
                    -txIgnoreRxLinkFaults           truth                       tx_ignore_rx_link_faults\
                    "
        }
        "tenGigLanFcoe" {
            # Create 10G LAN Fcoe ethernet attributes list
            set l1_port_options "                                                                         \
                    -loopback                       translate_op_mode           op_mode                   \
                    -transmitClocking               translate_clocksource       clocksource               \
                    -enabledFlowControl             truth                       enable_flow_control       \
                    -flowControlDirectedAddress     mac                         flow_control_directed_addr\
                    -enablePPM                      translate_ppm               transmit_clock_source     \
                    -ppm                            range                       internal_ppm_adjust       \
                    -autoInstrumentation            translate_adit              auto_detect_instrumentation_type\
                    -txIgnoreRxLinkFaults           truth                       tx_ignore_rx_link_faults\
                    "
            
            set l1_fcoe_options "
                    -pfcPriorityGroups              priority_groups_parse       fcoe_priority_groups      \
                    -supportDataCenterMode          truth                       fcoe_support_data_center_mode\
                    -priorityGroupSize              p_group_translate           fcoe_priority_group_size  \
                    -flowControlType                none                        fcoe_flow_control_type    \
                    "
        }
        "tenGigWan" {
            # Create 10G WAN ethernet attributes list
            set l1_port_options "                                                                         \
                    -c2Expected                     hex                         rx_c2                     \
                    -c2Tx                           hex                         tx_c2                     \
                    -interfaceType                  translate_framing           framing                   \
                    -loopback                       translate_op_mode           op_mode                   \
                    -transmitClocking               translate_clocksource       clocksource               \
                    -enabledFlowControl             truth                       enable_flow_control       \
                    -flowControlDirectedAddress     mac                         flow_control_directed_addr\
                    -enablePPM                      translate_ppm               transmit_clock_source     \
                    -ppm                            range                       internal_ppm_adjust       \
                    -autoInstrumentation            translate_adit              auto_detect_instrumentation_type\
                    -txIgnoreRxLinkFaults           truth                       tx_ignore_rx_link_faults\
                    "
        }
        "tenGigWanFcoe" {
            # Create 10G WAN Fcoe ethernet attributes list
            set l1_port_options "                                                                         \
                    -c2Expected                     hex                         rx_c2                     \
                    -c2Tx                           hex                         tx_c2                     \
                    -interfaceType                  translate_framing           framing                   \
                    -loopback                       translate_op_mode           op_mode                   \
                    -transmitClocking               translate_clocksource       clocksource               \
                    -enabledFlowControl             truth                       enable_flow_control       \
                    -flowControlDirectedAddress     mac                         flow_control_directed_addr\
                    -enablePPM                      translate_ppm               transmit_clock_source     \
                    -ppm                            range                       internal_ppm_adjust       \
                    -autoInstrumentation            translate_adit              auto_detect_instrumentation_type\
                    -txIgnoreRxLinkFaults           truth                       tx_ignore_rx_link_faults\
                    "
            
            set l1_fcoe_options "
                    -pfcPriorityGroups              priority_groups_parse       fcoe_priority_groups      \
                    -supportDataCenterMode          truth                       fcoe_support_data_center_mode\
                    -priorityGroupSize              p_group_translate           fcoe_priority_group_size  \
                    -flowControlType                none                        fcoe_flow_control_type    \
                    "
        }
        "pos" {
            # Create POS attributes list
            set l1_port_options "                                                         \
                    -c2Expected         hex                     rx_c2                     \
                    -c2Tx               hex                     tx_c2                     \
                    -crcSize            translate_fcs           fcs                       \
                    -dataScrambling     truth                   scrambling                \
                    -interfaceType      translate_pos_speed     speed,framing             \
                    -loopback           translate_op_mode       op_mode                   \
                    -payloadType        translate_pos_intf_mode intf_mode                 \
                    -transmitClocking   translate_clocksource   clocksource               \
                    -enablePPM          translate_ppm           transmit_clock_source     \
                    -ppm                range                   internal_ppm_adjust       \
                    "
        }
        default {
            # fallback to ethernet if not match for current port type
            set intf_type "ethernet"
            set l1_port_options "                                                                         \
                    -autoNegotiate                  truth                       autonegotiation           \
                    -loopback                       translate_op_mode           op_mode                   \
                    -media                          translate_phy_mode          phy_mode                  \
                    -speed                          translate_ethernet_speed    speed,duplex              \
                    -enabledFlowControl             truth                       enable_flow_control       \
                    -flowControlDirectedAddress     mac                         flow_control_directed_addr\
                    -enablePPM                      translate_ppm               transmit_clock_source     \
                    -ppm                            range                       internal_ppm_adjust       \
                    -autoInstrumentation            translate_adit              auto_detect_instrumentation_type\
                    "
        }
    }

    # Add only the attributes that exist
    set l1_port_args ""
    foreach {option array_name value_name} $l1_port_options {
        if {[regexp {(.*),(.*)} $value_name {} 1 2]} {
            if {[info exists $1]} {
                # adding a default value for the duplex parameter
                if {![info exists $2] && $1 == "speed" && $2 == "duplex"} {
                    set $2 "full"
                }
                if {[info exists $2]} {
                    set value "$array_name"
                    append value "[subst ($$1,$$2)]"
                    if { (![info exists $value]) || [subst $$value] == $not_supported} {
                        keylset returnList log "Failure in ixNetworkPortL1Config:\
                                '[subst $$1]' and '[subst $$2]' is not a valid\
                                combination of values for the '$1' and '$2' options\
                                in IxTclNetwork API."
                        keylset returnList status $::FAILURE
                        return $returnList
                    } elseif {[subst $$value] != $otherwise_supported} {
                        append l1_port_args " $option [subst $$value]"
                    } else {
                        #
                    }
                } else {
                    puts "\nWARNING: The $1 parameter will not be configured because \
                         the $2 parameter is missing"
                }
            }
        } elseif {[info exists $value_name]} {
            if {$array_name == "none"} {
                append l1_port_args " $option [subst $$value_name]"
            } elseif {$array_name == "range"} {
                if {[subst $$value_name]>105} {
                    append l1_port_args " $option 105"
                } elseif {[subst $$value_name]<-105} {
                    append l1_port_args " $option -105"
                } else {
                    append l1_port_args " $option [subst $$value_name]"
                }
            } elseif {$array_name == "hex"} {
                append l1_port_args " $option [format %u 0x[subst $$value_name]]"
            } elseif {$array_name == "mac"} {
                if {![::ixia::isValidMacAddress [subst $$value_name]]} {
                    keylset returnList log "Failure in ixNetworkPortL1Config:\
                            '[subst $$value_name]' is not a MAC value for the\
                            '$value_name' option in IxTclNetwork API."
                    keylset returnList status $::FAILURE
                    return $returnList
                }
                
                append l1_port_args " $option \"[convertToIxiaMac [subst $$value_name]]\""
                
            } else {
                if {[array exists $array_name]} {
                    set value "$array_name"
                    append value "[subst ($$value_name)]"
                    if { (![info exists $value]) || [subst $$value] == $not_supported} {
                        keylset returnList log "Failure in ixNetworkPortL1Config:\
                                '[subst $$value_name]' is not a valid value for the\
                                '$value_name' option in IxTclNetwork API."
                        keylset returnList status $::FAILURE
                        return $returnList
                    } elseif {[subst $$value] != $otherwise_supported} {
                        append l1_port_args " $option [subst $$value]"
                    } else {
                        #
                    }
                }
            }
        }
    }

    set intf_type [regsub "Fcoe" $intf_type ""]
    
    # Configure the port
    set result [ixNetworkNodeSetAttr $port_objref/l1Config/$intf_type \
            $l1_port_args]
    if {[keylget result status] == $::FAILURE} {
        keylset returnList log "Failure in ixNetworkPortL1Config:\
                encountered an error while executing: \
                ixNetworkNodeSetAttr $port_objref/l1Config/$intf_type\
                $l1_port_args - [keylget result log]"
        keylset returnList status $::FAILURE
        return $returnList
    }
    keylset returnList commit_needed 1
    
    set notFcoePort [catch {ixNet getList $port_objref/l1Config/$intf_type fcoe} fcoePortRef]
    
    if {[info exists l1_fcoe_options] && !$notFcoePort && $fcoePortRef != ""} {
        set l1_fcoe_args ""
        foreach {option array_name value_name} $l1_fcoe_options {
            if {[info exists $value_name]} {
                if {$array_name == "none"} {
                    append l1_fcoe_args " $option [subst $$value_name]"
                } elseif {$array_name == "mac"} {
                    if {![::ixia::isValidMacAddress [subst $$value_name]]} {
                        keylset returnList log "Failure in ixNetworkPortL1Config:\
                                '[subst $$value_name]' is not a MAC value for the\
                                '$value_name' option in IxTclNetwork API."
                        keylset returnList status $::FAILURE
                        return $returnList
                    }
                    
                    append l1_fcoe_args " $option \"[convertToIxiaMac [subst $$value_name]]\""
                    
                } elseif {$array_name == "priority_groups_parse"} {
                    if {[info exists priority_group_size]} {
                        set priority_group_size_temp ""
                        regexp {^[a-zA-Z]*([0-9]+)$} $priority_group_size priority_group_size_ignore priority_group_size_temp
                        if {$priority_group_size_temp == ""} {
                            keylset returnList log "Failure in ixNetworkPortL1Config:\
                                    Invalid format for -priority_group_size, this must be 4 or 8."
                            keylset returnList status $::FAILURE
                            return $returnList
                        }
                    } else {
                        set priority_group_size_temp [ixNet getAttribute \
                                $port_objref/l1Config/$intf_type/fcoe -priorityGroupSize]
                    }
                    set tmp_value [subst $$value_name]
                    
                    if {[llength $tmp_value] > 8} {
                        if {$priority_group_size_temp == 4} {
                            keylset returnList log "Failure in ixNetworkPortL1Config:\
                                    '[subst $$value_name]' is not valid. It must be a list\
                                    of maximum 8 elements and each element can be '0', '1',\
                                    '2', '3' or 'none'."
                            keylset returnList status $::FAILURE
                            return $returnList
                        } else {
                            keylset returnList log "Failure in ixNetworkPortL1Config:\
                                    '[subst $$value_name]' is not valid. It must be a list\
                                    of maximum 8 elements and each element can be '0', '1',\
                                    '2', '3', '4', '5', '6', '7' or 'none'."
                            keylset returnList status $::FAILURE
                            return $returnList
                        }
                    }
                    
                    set new_value ""
                    for {set i 0} {$i < 8} {incr i} {
                        set idx_value [lindex $tmp_value $i]
                        switch -- $idx_value {
                            0 -
                            1 -
                            2 -
                            3 {
                                lappend new_value $idx_value
                            }
                            4 -
                            5 -
                            6 -
                            7 {
                                if {$priority_group_size_temp == 4} {
                                    keylset returnList log "Failure in ixNetworkPortL1Config:\
                                            '$idx_value' is not valid. It must be a list\
                                            of maximum 8 elements and each element can be '0', '1',\
                                            '2', '3' or 'none'."
                                    keylset returnList status $::FAILURE
                                    return $returnList
                                    lappend new_value $idx_value
                                }
                                lappend new_value $idx_value
                            }
                            "" -
                            none {
                                lappend new_value -1
                            }
                            default {
                                if {$priority_group_size_temp == 4} {
                                    keylset returnList log "Failure in ixNetworkPortL1Config:\
                                            '$idx_value' is not valid. It must be a list\
                                            of maximum 8 elements and each element can be '0', '1',\
                                            '2', '3' or 'none'."
                                    keylset returnList status $::FAILURE
                                    return $returnList
                                } else {
                                    keylset returnList log "Failure in ixNetworkPortL1Config:\
                                            '[subst $$value_name]' is not valid. It must be a list\
                                            of maximum 8 elements and each element can be '0', '1',\
                                            '2', '3', '4', '5', '6', '7' or 'none'."
                                    keylset returnList status $::FAILURE
                                    return $returnList
                                }
                            }
                        }
                    }
                    
                    append l1_fcoe_args " $option \{$new_value\}"
                    
                    catch {unset tmp_value}
                } elseif {$array_name == "p_group_translate"} {
                    append l1_fcoe_args " $option \"priorityGroupSize-[subst $$value_name]\""                     
                } else {
                    set value "$array_name"
                    append value "[subst ($$value_name)]"
                    if {[subst $$value] == $not_supported} {
                        keylset returnList log "Failure in ixNetworkPortL1Config:\
                                '[subst $$value_name]' is not a valid value for the\
                                '$value_name' option in IxTclNetwork API."
                        keylset returnList status $::FAILURE
                        return $returnList
                    } elseif {[subst $$value] != $otherwise_supported} {
                        append l1_fcoe_args " $option [subst $$value]"
                    } else {
                        #
                    }
                }
            }
        }
    
        # Configure the port fcoe
        if {$l1_fcoe_args != ""} {
            set result [ixNetworkNodeSetAttr $port_objref/l1Config/$intf_type/fcoe \
                    $l1_fcoe_args]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList log "Failure in ixNetworkPortL1Config:\
                        encountered an error while executing: \
                        ixNetworkNodeSetAttr $port_objref/l1Config/$intf_type/fcoe\
                        $l1_fcoe_args - [keylget result log]"
                keylset returnList status $::FAILURE
                return $returnList
            }
            keylset returnList commit_needed 1
        }
    }
    if {[info exists intf_type]} {
        keylset returnList intf_type_key $intf_type
    }
    keylset returnList status $::SUCCESS
    return $returnList
}
# this procedure is called by ::ixia::ixNetworkPortL1Config
proc ::ixia::ixNetworkPortL1Config3 { args } {
    variable truth
    variable egress_tracking_global_array
    variable egress_tracking_global_array_legacy
    
    keylset returnList commit_needed 0
    
    set man_args {
        -port_handle
    }

    set opt_args {
        -data_integrity                 CHOICES 0 1
        -intf_mode                      CHOICES atm pos_hdlc pos_ppp ethernet
                                        CHOICES multis multis_fcoe ethernet_vm
                                        CHOICES frame_relay1490
                                        CHOICES frame_relay2427
                                        CHOICES frame_relay_cisco ethernet_fcoe
                                        CHOICES fc
        -port_rx_mode                   CHOICES capture_and_measure capture packet_group data_integrity sequence_checking wide_packet_group echo auto_detect_instrumentation
        -ppp_ipv4_address               IP
        -ppp_ipv4_negotiation           CHOICES 0 1
        -ppp_ipv6_negotiation           CHOICES 0 1
        -ppp_mpls_negotiation           CHOICES 0 1
        -ppp_osi_negotiation            CHOICES 0 1
        -transmit_mode                  CHOICES advanced stream advanced_coarse stream_coarse flow echo
        -tx_gap_control_mode            CHOICES fixed average
    }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing.\
                Parameter or parameter value is not supported with IxTclNetwork. $parse_error. "
        return $returnList
    }
    
    set not_supported       N/A
    set otherwise_supported  /A
    
    array set translate_port_rx_mode [list          \
        capture                     capture         \
        packet_group                measure         \
        wide_packet_group           measure         \
        echo                        $not_supported  \
        data_integrity              $otherwise_supported  \
        sequence_checking           $not_supported  \
        auto_detect_instrumentation measure  \
        capture_and_measure         captureAndMeasure
    ]
    
    array set translate_tx_gap_control_mode [list   \
        fixed           fixedMode                   \
        average         averageMode                 \
    ]
    
    array set translate_transmit_mode [list           \
        advanced                    interleaved       \
        stream                      sequential        \
        advanced_coarse             interleavedCoarse \
        stream_coarse               sequentialCoarse  \
        flow                        $not_supported    \
        echo                        $not_supported    \
    ]
    
    array set translate_atm_interface_type [list    \
        uni                         uni             \
        nni                         nni             \
    ]
    set result [ixNetworkGetPortObjref $port_handle]
    if {[keylget result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Could not find any vport which uses the\
                $port_handle port - [keylget result log]."
        return $returnList
    } else {
        set port_objref [keylget result vport_objref]
    }
    # Configure the POS PPP settings
    if {[info exists intf_mode] && $intf_mode == "pos_ppp"} {
        set ppp_pos_options "                                       \
                -enableIpV4         truth   ppp_ipv4_negotiation    \
                -enableIpV6         truth   ppp_ipv6_negotiation    \
                -enableMpls         truth   ppp_mpls_negotiation    \
                -enableOsi          truth   ppp_osi_negotiation     \
                -localIpAddress     none    ppp_ipv4_address        \
                "

        # Add only the attributes that exist
        set ppp_pos_args "-enabled true"
        foreach {option array_name value_name} $ppp_pos_options {
            if {[info exists $value_name]} {
                if {$array_name == "none"} {
                    append ppp_pos_args " $option [subst $$value_name]"
                } else {
                    set value "$array_name"
                    append value "[subst ($$value_name)]"
                    if {[subst $$value] == $not_supported} {
                        keylset returnList log "Failure in\
                                ixNetworkPortL1Config: '$value_name' is not a\
                                valid value for the '$option' option."
                        keylset returnList status $::FAILURE
                        return $returnList
                    } elseif {[subst $$value] != $otherwise_supported} {
                        append ppp_pos_args " $option [subst $$value]"
                    } else {
                        #
                    }
                }
            }
        }

        # Write the POS configuration first, in order to be able to configure
        # PPP over POS correctly
        ixNet commit
        keylset returnList commit_needed 1

        # Configure PPP
        set result [ixNetworkNodeSetAttr $port_objref/l1Config/pos/ppp \
                $ppp_pos_args]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not add the PPP settings to the POS\
                    port connected through the $port_objref vport using the\
                    following command: ixNetworkSetAttr\
                    $port_objref/l1Config/pos/ppp $ppp_pos_args -\
                    [keylget result log]."
            return $returnList
        }
        keylset returnList commit_needed 1
    }

    # Create vport transmission attributes list
    set l1_port_options "                                       \
            -rxMode     translate_port_rx_mode  port_rx_mode    \
            -txMode     translate_transmit_mode transmit_mode   \
            -txGapControlMode translate_tx_gap_control_mode tx_gap_control_mode \
            "

    # Add only the transmission attributes that exist
    set l1_port_args ""
    foreach {option array_name value_names} $l1_port_options {
        if {[info exists $value_names]} {
            foreach value_name $value_names {
                set value "$array_name"
                append value "[subst ($$value_name)]"
                if {[subst $$value] == $not_supported} {
                    keylset returnList log "Failure in ixNetworkPortL1Config:\
                            '[subst $$value_name]' is not a valid value for the\
                            '$value_name' option in IxTclNetwork API."
                    keylset returnList status $::FAILURE
                    return $returnList
                } elseif {[subst $$value] != $otherwise_supported} {
                    append l1_port_args " $option [subst $$value]"
                } else {
                    #
                }
            }
        }
    }

    # Configure the transmission attributes
    set result [ixNetworkNodeSetAttr $port_objref $l1_port_args]
    if {[keylget result status] == $::FAILURE} {
        keylset returnList log "Failure in ixNetworkPortL1Config:\
                encountered an error while executing: \
                ixNetworkNodeSetAttr $port_objref $l1_port_args\
                - [keylget result log]"
        keylset returnList status $::FAILURE
        return $returnList
    }
    keylset returnList commit_needed 1
    keylset returnList status $::SUCCESS
    return $returnList
}
# this procedure is called by ::ixia::ixNetworkPortL1Config
proc ::ixia::ixNetworkPortL1Config4 { args } {
    variable truth
    variable egress_tracking_global_array
    variable egress_tracking_global_array_legacy
    
    keylset returnList commit_needed 0
    set man_args {
        -port_handle
    }
    set opt_args {
        -data_integrity                 CHOICES 0 1
        -intf_mode                      CHOICES atm pos_hdlc pos_ppp ethernet
                                        CHOICES multis multis_fcoe ethernet_vm
                                        CHOICES frame_relay1490
                                        CHOICES frame_relay2427
                                        CHOICES frame_relay_cisco ethernet_fcoe
                                        CHOICES fc
        -intf_type                      ANY
        -op_mode                        CHOICES loopback normal sim_disconnect
        -port_rx_mode                   CHOICES capture_and_measure capture packet_group data_integrity sequence_checking wide_packet_group echo auto_detect_instrumentation
        -pgid_mode                      CHOICES dscp ipv6TC mplsExp split 
                                        CHOICES outer_vlan_priority outer_vlan_id_4
                                        CHOICES outer_vlan_id_6 outer_vlan_id_8
                                        CHOICES outer_vlan_id_10 outer_vlan_id_12
                                        CHOICES inner_vlan_priority inner_vlan_id_4
                                        CHOICES inner_vlan_id_6 inner_vlan_id_8
                                        CHOICES inner_vlan_id_10 inner_vlan_id_12
                                        CHOICES tos_precedence ipv6TC_bits_0_2
                                        CHOICES ipv6TC_bits_0_5
        -pgid_encap                     CHOICES LLCRoutedCLIP 
                                        CHOICES LLCPPPoA                 
                                        CHOICES LLCBridgedEthernetFCS
                                        CHOICES LLCBridgedEthernetNoFCS 
                                        CHOICES VccMuxPPPoA 
                                        CHOICES VccMuxIPV4Routed 
                                        CHOICES VccMuxBridgedEthernetFCS
                                        CHOICES VccMuxBridgedEthernetNoFCS
        -pgid_split1_offset             NUMERIC
        -pgid_split1_width              RANGE 0-12
    }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing.\
                Parameter or parameter value is not supported with IxTclNetwork. $parse_error. "
        return $returnList
    }
    set result [ixNetworkGetPortObjref $port_handle]
    if {[keylget result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Could not find any vport which uses the\
                $port_handle port - [keylget result log]."
        return $returnList
    } else {
        set port_objref [keylget result vport_objref]
    }

    set not_supported       N/A
    set otherwise_supported  /A
    
    # Set cable disconnect state
    if {[info exists op_mode]} {
        if {$op_mode == "sim_disconnect"} {
            unset op_mode
            set sim_disconnect 1
        } else {
            set sim_disconnect 0
        }
    }
    
    # Exec cable connect/disconnect
    if {[info exists sim_disconnect] && [ixNet getAttr $port_objref -isConnected] == "true"} {
        if {$sim_disconnect == 1} {
            debug "ixNet exec linkUpDn $port_objref down"
            ixNet exec linkUpDn $port_objref down 
        } else {
            debug "ixNet exec linkUpDn $port_objref up"
            ixNet exec linkUpDn $port_objref up
        }
    }
    
    # Check the state of the port
    set num_retries 200
    while {[ixNet getAttribute $port_objref -stateDetail] == "busy" && \
            ($num_retries > 0) } {
        after 100
        incr num_retries -1
    }
    set result [ixNet getAttribute $port_objref -stateDetail]
    if {$result == "cpuNotReady" || \
            $result == "l1ConfigFailed" || \
            $result == "versionMismatched"} {
        keylset returnList status $::FAILURE
        keylset returnList log "'$result' encountered while configuring\
                $port_handle."
        return $returnList
    }
    if {$result == "protocolsNotSupported"} {
        ixPuts "Warning: Protocols are not supported for port $port_handle ..."
    }
    
    # Configure Egress tracking
    if {[info exists pgid_mode]} {
        
        set egress_tracking_global_string ""
        set egress_tracking_global_string_legacy ""

        keylset egress_tracking_global_string_legacy pgid_mode $pgid_mode
        
        if {$pgid_mode == "split"} {
            
            keylset egress_tracking_global_string egress_tracking custom
            
            if {[info exists pgid_split1_offset]} {
                keylset egress_tracking_global_string egress_custom_offset [mpexpr $pgid_split1_offset * 8]
                keylset egress_tracking_global_string_legacy pgid_split1_offset $pgid_split1_offset
            }
            
            if {[info exists pgid_split1_width]} {
                keylset egress_tracking_global_string egress_custom_width $pgid_split1_width
                keylset egress_tracking_global_string_legacy pgid_split1_width $pgid_split1_width
            }
            
        } else {
            # determine port mode and encapsulation
            switch -- $intf_type {
                "atm" {
                    if {![info exists pgid_encap]} {
                        set tracking_encap LLCRoutedCLIP
                    } else {
                        set tracking_encap $pgid_encap
                    }
                }
                "pos" {
                    if {![info exists intf_mode]} {
                        set tracking_encap "pos_hdlc"
                    } else {
                        set tracking_encap $intf_mode
                    }
                }
                default {
                    set tracking_encap "ethernet"
                }
            }
            keylset egress_tracking_global_string_legacy tracking_encap $tracking_encap
            keylset egress_tracking_global_string egress_tracking_encap $tracking_encap
            keylset egress_tracking_global_string egress_tracking $pgid_mode
        }
        
        if {[llength $egress_tracking_global_string] > 0} {
            set egress_tracking_global_array($port_objref) $egress_tracking_global_string
        }
        if {[llength $egress_tracking_global_string_legacy] > 0} {
            set egress_tracking_global_array_legacy($port_objref) $egress_tracking_global_string_legacy
        }
    }
    
    if {[info exists port_rx_mode] && [lsearch [split $port_rx_mode |] data_integrity] != -1} {
        # Enable data integrity
        set result [ixNetworkNodeSetAttr [ixNet getRoot]traffic     \
                        [list -enableDataIntegrityCheck true]       \
                        ]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList log "Failed to configure data integrity on port $port_handle\
                    - [keylget result log]"
            keylset returnList status $::FAILURE
            return $returnList
        }
        keylset returnList commit_needed 1
    }
    if {[info exists data_integrity]} {
        # Enable data integrity
        set result [ixNetworkNodeSetAttr [ixNet getRoot]traffic     \
                        [list -enableDataIntegrityCheck $truth($data_integrity)] \
                        ]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList log "Failed to configure data integrity on port $port_handle\
                    - [keylget result log]"
            keylset returnList status $::FAILURE
            return $returnList
        }
        keylset returnList commit_needed 1
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}



proc ::ixia::ixNetworkGetPortObjref { realPort } {
    variable ixnetwork_port_handles_array
    
    if {![catch {set ixnetwork_port_handles_array($realPort)} vport]} {
        keylset returnList vport_objref $vport
        keylset returnList status $::SUCCESS
        return $returnList
    } else {
        keylset returnList log "Port $realPort could not be found in the list\
                of configured ports."
        keylset returnList status $::FAILURE
        return $returnList
    }
}

proc ::ixia::ixNetworkGetPortFromObj { objRef } {
    variable ixnetwork_port_handles_array_vport2rp
    
    if {[regexp {^(/vport:\d+)} $objRef]} {
        set objRef "::ixNet::OBJ-$objRef"
    }
    set vportObjRef ""
    regsub {^(::ixNet::OBJ-/vport:\d+)/(.*)$} $objRef {\1} vportObjRef

    if {$vportObjRef == ""} {
        return [ixia::util::make_error "Failure to extract vport object from handle $objRef"]
    }
    
    set vportHandle ""
    if {[catch {set ixnetwork_port_handles_array_vport2rp($vportObjRef)} vportHandle]} {
        return [ixia::util::make_error "Failure to extract port object reference from handle $objRef"]
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList vport_objref $vportObjRef
    keylset returnList port_handle  $vportHandle
    return $returnList
}

proc ::ixia::ixNetworkGetIntfObjref { interface_description } {
    
    set intf_handle [rfget_interface_handle_by_description $interface_description]
    if {[llength $intf_handle] == 0} {
        return [ixNet getNull]
    } else {
        return $intf_handle
    }
}


proc ::ixia::ixNetworkGetProtocolObjref { objRef protocol } {
    set initialObjref $objRef
    while {$objRef != [ixNet getRoot]} {
        if {![regexp "$protocol\$" $objRef]} {
            if {[catch {set objRef [ixNet getParent $objRef]} retCode]} {
                keylset returnList status $::FAILURE
                keylset returnList status "Invalid object reference\
                        ${initialObjref}. $retCode"
                return $returnList
            }
        } else {
            break;
        }
    }
    keylset returnList status $::SUCCESS
    keylset returnList objref $objRef
    return $returnList
}


proc ::ixia::ixNetworkGetOwner {} {
    variable ixnetwork_port_handles_array

    # Get the first used vport
    set key [lindex [array names ixnetwork_port_handles_array] 0]
    set checked_vport $ixnetwork_port_handles_array($key)

    # Get the port attached to that vport
    set checked_port [ixNet getAttribute $checked_vport -connectedTo]
    
    # Get the owner of the port
    set owner [ixNet getAttribute $checked_port -owner]

    keylset returnList status $::SUCCESS
    keylset returnList owner $owner
    return $returnList
}

proc ::ixia::ixNetworkNodeAdd {
    parentObjRef
    child
    {attributeList {}}
    {commit -no_commit}
    } {
    
    if {$commit == "-commit"} {
        if {[catch {set childObjRef [ixNetworkAdd $parentObjRef $child "hlt_no_register"]} error_msg]} {
            keylset returnList log "Failure in ixNetworkNodeAdd:\
                    encountered an error while executing: ixNetworkAdd $parentObjRef\
                    $child - $error_msg"
            keylset returnList status $::FAILURE
            return $returnList
        }
    } else {
        if {[catch {set childObjRef [ixNetworkAdd $parentObjRef $child]} error_msg]} {
            keylset returnList log "Failure in ixNetworkNodeAdd:\
                    encountered an error while executing: ixNetworkAdd $parentObjRef\
                    $child - $error_msg"
            keylset returnList status $::FAILURE
            return $returnList
        }
    }

    if {$attributeList != {}} {
        #if {$commit == "-commit"} {
            #set result [ixNetworkNodeSetAttr $childObjRef $attributeList -commit]
        #} else {
            set result [ixNetworkNodeSetAttr $childObjRef $attributeList]
        #}
        
        if {[keylget result status] == $::FAILURE} {
            keylset returnList log "Failure in ixNetworkNodeAdd:\
                    encountered an error while executing: \
                    ixNetworkNodeSetAttr $childObjRef $attributeList\
                    - [keylget result log]"
            keylset returnList status $::FAILURE
            return $returnList
        }
    }
    
    if {$commit == "-commit"} {
        if {[catch {ixNetworkCommit} error_msg]} {
            keylset returnList log "Failure in ixNetworkNodeAdd:\
                    encountered an error while executing: ixNetworkCommit -\
                    $error_msg"
            keylset returnList status $::FAILURE
            return $returnList
        }
        
        debug "ixNet remapIds $childObjRef"
        if {[catch {set childObjRef [ixNet remapIds $childObjRef]} error_msg]} {
            keylset returnList log "Failure in ixNetworkNodeAdd:\
                    encountered an error while executing: ixNet add\
                    $parentObjRef $child - $error_msg"
            keylset returnList status $::FAILURE
            return $returnList
        }
    }
        
    keylset returnList node_objref $childObjRef
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixNetworkNodeSetAttr {
    nodeObjRef
    attributeList
    {commit -no_commit}
    } {
    
    if {[regsub -all {([^\\]{1}) } $nodeObjRef {\1\\ } nodeObjRef]} {
        set nodeObjRef [list $nodeObjRef]
    } elseif {[regexp { } $nodeObjRef]} {
        set nodeObjRef [list $nodeObjRef]
    }
    
    if {[llength $attributeList] > 0} {
        if {$commit == "-commit"} {
            set cmd [join [list ixNetworkSetAttr $nodeObjRef $attributeList "hlt_no_register"]]
        } else {
            set cmd [join [list ixNetworkSetAttr $nodeObjRef $attributeList]]
        }
        
        if {[catch {eval $cmd} error_msg]} {
            keylset returnList log "Failure in ixNetworkNodeSetAttr:\
                    encountered an error while executing: \
                    $cmd - $error_msg"
            keylset returnList status $::FAILURE
            return $returnList
        }
    }
    
    if {$commit == "-commit"} {
        if {[catch {ixNetworkCommit} error_msg]} {
            keylset returnList log "Failure in ixNetworkNodeSetAttr:\
                    encountered an error while executing: ixNet commit -\
                    $error_msg"
            keylset returnList status $::FAILURE
            return $returnList
        }
    }
    
    keylset returnList status $::SUCCESS   
    return $returnList
}


proc ::ixia::ixNetworkCommit {} {

    #variable uncommitted_objects_array
    
    #catch {unset uncommitted_objects_array}
    debug "ixNet commit"
    return [ixNet commit]
}


proc ::ixia::ixNetworkAdd {args} {
    
    #variable uncommitted_objects_array
    
    set parent_obj [lindex $args 0]
    set child_name [lindex $args 1]
    set attributes [lrange $args 2 end]
    
    if {[lindex $args end] == "hlt_no_register"} {
        set attributes [lreplace $attributes end end]
        set hlt_no_register 1
    } else {
        set hlt_no_register 0
    }
    
    #set parent_obj [ixNet remapIds $parent_obj]
    
    #debug "ixNet add $parent_obj $child_name"
    #set child_obj [ixNet add $parent_obj $child_name]
    
    #if {!$hlt_no_register} {
        #if {![info exists uncommitted_objects_array($child_obj)]} {
            #set uncommitted_objects_array($child_obj) ""
        #}
    #}
    
    #if {[llength $attributes] > 0} {
        #if {$hlt_no_register} {
            #set cmd [join [list ixNetworkSetAttr $child_obj $attributes "hlt_no_register"]]
        #} else {
            #set cmd [join [list ixNetworkSetAttr $child_obj $attributes]]
        #}
        #eval $cmd
    #}
    
    #if {!$hlt_no_register} {
        ## We must register the object as the child of the parent
        ## Even if the parent is permanent we still need to know it's local children
        #set tmp_keyd_list ""
        #if {[info exists uncommitted_objects_array($parent_obj)]} {
            #set tmp_keyd_list $uncommitted_objects_array($parent_obj)
        #}
        
        #if {[catch {keylget tmp_keyd_list $child_name} child_list]} {
            #set child_list $child_obj
        #} elseif {[lsearch $child_list $child_obj] == -1} {
            #lappend child_list $child_obj
        #}
        
        #keylset tmp_keyd_list $child_name $child_list
        #set uncommitted_objects_array($parent_obj) $tmp_keyd_list
    #}
    
    #return $child_obj
    
    set cmd [join [list ixNet add $parent_obj $child_name $attributes]]
    debug $cmd
    return [eval $cmd]
    
}


proc ::ixia::ixNetworkNodeGetList { parentObjRef child {index 0} } {
    
    set childObjRef [ixNetworkGetList $parentObjRef $child]
    if {[info exists childObjRef]} {
        if {$index == "-all"} {
            return $childObjRef
        } else {
            set childObjRefList [lindex $childObjRef $index]
            return $childObjRefList
        }
    } else {
        return [ixNet getNull]
    }
}


proc ::ixia::ixNetworkGetList {parentObjRef child} {
    
    #variable uncommitted_objects_array
    
    #set parentObjRef [ixNet remapIds $parentObjRef]
    
    #set child_list ""
    
    #if {![regexp {:L\d+} $parentObjRef]} {
        ## This is a permanent object. Return children using ixnet low level
        #set child_list [ixNet getList $parentObjRef $child]
    #}
    
    ## If it has temporary (local) children return them too
    #if {![catch {keylget uncommitted_objects_array($parentObjRef) $child} ret_list]} {
        #lappend child_list $ret_list
    #}
    
    #set child_list [join $child_list]
    
    #return $child_list
    
    set child_list [ixNet getList $parentObjRef $child]
    return $child_list
}


proc ::ixia::ixNetworkGetAttr {obj_ref attr_name} {
    
    #variable uncommitted_objects_array
    
    #set obj_ref [ixNet remapIds $obj_ref]
    
    #if {![regexp {:L\d+} $obj_ref]} {
        #return [ixNet getA $obj_ref $attr_name]
    #} else {
        #if {![catch {keylget uncommitted_objects_array($obj_ref) $attr_name} attr_val]} {
            #return $attr_val
        #} else {
            #return _hlt_noval
        #}
    #}
    
    return [ixNet getA $obj_ref $attr_name]
}


proc ::ixia::ixNetworkSetAttr {args} {
    
    # $attr_name must be the dashed argument
    
    variable uncommitted_objects_array
    
    set obj_ref [lindex $args 0]
    set attributes [lrange $args 1 end]
    
    if {[lindex $args end] == "hlt_no_register"} {
        set attributes [lreplace $attributes end end]
        set hlt_no_register 1
    } else {
        set hlt_no_register 0
    }
    
    #set obj_ref [ixNet remapIds $obj_ref]
    
    #if {!$hlt_no_register} {
        #if {[regexp {:L\d+} $obj_ref]} {
            
            #if {[catch {set keyd_list $uncommitted_objects_array($obj_ref)}]} {
                #set keyd_list ""
            #}
            
            #foreach {attr_name attr_value} $attributes {
                #keylset keyd_list $attr_name $attr_value
            #}
            
            #set uncommitted_objects_array($obj_ref) $keyd_list
        #}
    #}
    
    set cmd [join [list ixNet setMultiAttrs $obj_ref $attributes]]
    debug $cmd
    return [eval $cmd]
}

proc ::ixia::ixNetworkSetMultiAttr {obj_ref lst} {
    upvar 1 $lst attributes
    set cmd [join [list ixNet setMultiAttrs $obj_ref $attributes]]
    debug $cmd
    return [eval $cmd]
}


proc ::ixia::ixNetworkRemove {obj_ref} {
    #variable uncommitted_objects_array
    
    #set obj_ref [ixNet remapIds $obj_ref]
    
    #set obj_name [ixNetworkGetObjectName $obj_ref]
    #set parent_obj [ixNetworkGetParentObjref $obj_ref]
    
    ## remove object from parent's object list
    #if {![catch {keylget uncommitted_objects_array($parent_obj) $obj_name} child_obj_list]} {
        #set pos [lsearch $child_obj_list $obj_ref]
        #if {$pos != -1} {
            #set child_obj_list [lreplace $child_obj_list $pos $pos]
            #keylset uncommitted_objects_array($parent_obj) $obj_name $child_obj_list
        #}
    #}
    
    ## remove child object and all it's children
    #ixNetworkNodeRemoveUncommitedChild $obj_ref
    
    if {[llength $obj_ref] > 1} {
        foreach single_obj_ref $obj_ref {
            set result [ixNet remove $single_obj_ref]
            if {$result != "::ixNet::OK"} {
                return $result
            }
        }
        return ::ixNet::OK
    } else {
        return [ixNet remove $obj_ref]
    }
}


proc ::ixia::ixNetworkNodeRemoveUncommitedChild {obj_ref} {
    
    # recursevly remove all child objects from internal array
    variable uncommitted_objects_array
    
    if {[info exists uncommitted_objects_array($obj_ref)]} {
        set keyd_list $uncommitted_objects_array($obj_ref)
        
        # keys that don't begin with dash '-' are child objects
        
        foreach key [keylkeys keyd_list] {
            if {![regexp {^-} $key]} {
                set child_obj_list [keylget keyd_list $key]
                foreach child_obj $child_obj_list {
                    ixNetworkNodeRemoveUncommitedChild $child_obj
                }
            }
        }
        
        unset uncommitted_objects_array($obj_ref)
    }
}


proc ::ixia::ixNetworkGetObjectName {obj_ref} {
    return [lindex [split [lindex [split $obj_ref  /] end] :] 0]
}


proc ::ixia::ixNetworkNodeRemoveList {
    parentObjRef
    child_list
    {commit -no_commit}
    } {

    # Take care of the children types on this level
    foreach {thisStep nextStep} $child_list {
        if {[lindex $thisStep 0] == "child"} {
            set childObjRefList [ixNet getList $parentObjRef \
                    [lindex $thisStep 2]]
        } elseif {[lindex $thisStep 0] == "attr"} {
            set childObjRefList [ixNet getAttribute $parentObjRef \
                    -[lindex $thisStep 2]]
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log  "Unknown child type '[lindex $thisStep 0]'.\
                    Use 'child' or 'attr'."
            return $returnList
        }
        keylset returnList removed_items $childObjRefList
        # Take care of the children of the selected type
        if {[info exists childObjRefList]} {
            foreach childObjRef $childObjRefList {
                if {[llength $nextStep] > 0} {
                    ixNetworkNodeRemoveList $childObjRef $nextStep
                }
                if {[lindex $thisStep 1] == "remove"} {
                    debug "ixNet remove $childObjRef"
                    ixNet remove $childObjRef
                } elseif {[lindex $thisStep 1] != "keep"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log  "Unknown action\
                            '[lindex $thisStep 1]'. Use\
                            'remove' or 'keep'."
                    return
                }
            }
            if {$commit == "-commit"} {
                debug "ixNet commit"
                ixNet commit
            }
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

proc  ::ixia::ixNetworkFormatMac { {mac_addr} } {
    if {(![info exists mac_addr]) || ([llength $mac_addr] == 0)} {
        ixPuts "WARNING: null MAC address; using default 00:00:00:00:00:00"
        return 00:00:00:00:00:00
    }

    if {[llength $mac_addr] == 6} {
        return [string tolower "[lindex \
                $mac_addr 0]:[lindex $mac_addr 1]:[lindex \
                $mac_addr 2]:[lindex $mac_addr 3]:[lindex \
                $mac_addr 4]:[lindex $mac_addr 5]"]
    } elseif {[llength $mac_addr] == 1} {
        set format1 "^(\[0-9,a-f,A-F\]{2})\[\:\. \]{1}(\[0-9,a-f,A-F\]{2})\[\:\. \]{1}(\[0-9,a-f,A-F\]{2})\[\:\. \]{1}(\[0-9,a-f,A-F\]{2})\[\:\. \]{1}(\[0-9,a-f,A-F\]{2})\[\:\. \]{1}(\[0-9,a-f,A-F\]{2})$"
        set format2 "^(\[0-9,a-f,A-F\]{2})(\[0-9,a-f,A-F\]{2})\[\:\. \]{1}(\[0-9,a-f,A-F\]{2})(\[0-9,a-f,A-F\]{2})\[\:\. \]{1}(\[0-9,a-f,A-F\]{2})(\[0-9,a-f,A-F\]{2})$"
        if {[regexp -nocase -- $format1 $mac_addr all gr1 gr2 gr3 gr4 gr5 gr6] == 1} {
            return [string tolower "$gr1:$gr2:$gr3:$gr4:$gr5:$gr6"]
        }
        if {[regexp -nocase -- $format2 $mac_addr all gr1 gr2 gr3 gr4 gr5 gr6] == 1} {
            return [string tolower "$gr1:$gr2:$gr3:$gr4:$gr5:$gr6"]
        }
    } else {
        ixPuts "WARNING: invalid MAC address format; using default 00:00:00:00:00:00"
        return 00:00:00:00:00:00
    }
}

proc ::ixia::ixNetworkFindInterfaceObjref { port_objref ip_address ip_version } {
    set intf_list [ixNet getList $port_objref interface]
    foreach intf $intf_list {
        if { [ixNet getAttr $intf/IPv$ip_version -ip] == $ip_address } {
            return $intf
        }
    }
    return [ixNet getNull]
}

proc ::ixia::ixNetworkSetupUserStats { realPort sourceType {statNameList ""} } {
    variable ixnetwork_chassis_list

    # Create the filter name
    regexp {^(\d+)/(\d+)/(\d+)$} $realPort {} chassis_id card_id port_id
    set hostname [::ixia::getHostname $ixnetwork_chassis_list $chassis_id]
    
    if {$hostname == -1} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to determine the IP address of the\
                chassis with id $chassis_id."
        return $returnList
    }
    set filter1 "$hostname/Card[format %02u $card_id]/Port[format %02u $port_id]"
    set filter2 "$hostname/Card${card_id}/Port[format %02u $port_id]"
    set filter3 "$hostname/Card[format %02u $card_id]/Port${port_id}"
    set filter4 "$hostname/Card${card_id}/Port${port_id}"
    # Get list of available filters
    set validFilterValueList {}
    set catalogList [ixNet getList [ixNet getRoot]statistics catalog]
    foreach catalog $catalogList {
        if {[ixNet getAttribute $catalog -sourceType] == $sourceType} {
            set filterList [ixNet getList $catalog filter]
            foreach filterItem $filterList {
                if {[ixNet getAttribute $filterItem -name] == "Port"} {
                    set validFilterValueList [ixNet getAttribute $filterItem \
                            -filterValueList]
                    break
                }
            }
            break
        }
    }

    # Filter error handling
    if {[llength $validFilterValueList] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "There is no filter for the selected sourceType\
                in the catalog."
        return $returnList
    }
    set found_filter1 [lsearch $validFilterValueList $filter1]
    set found_filter2 [lsearch $validFilterValueList $filter2]
    set found_filter3 [lsearch $validFilterValueList $filter3]
    set found_filter4 [lsearch $validFilterValueList $filter4]
    if {($found_filter1 == -1) && ($found_filter2 == -1) && \
            ($found_filter3 == -1) && ($found_filter4 == -1)} {
        keylset returnList status $::FAILURE
        keylset returnList log "The used port is missing from the filter list\
                from the catalog."
        return $returnList
    }
    for {set fi 1} {$fi < 5} {incr fi} {
        if {[set found_filter$fi] != -1} {
            set filter [set filter$fi]
            if {$sourceType == "RSVP"} {
                set filter $filter4
            }
        }
    }

    # If the statName list is in form of wild card get all stats name for 
    # for the sourceType from catalog.
    if {$statNameList == ""} {
        # At this moment getFilterList is not working for C# publishers
        # so I loop through of each catalog to find selected sourceType.
        set statNameList {}
        set catalogList [ixNet getList [ixNet getRoot]/statistics catalog]
        foreach catalog $catalogList {
            if {[ixNet getAttribute $catalog -sourceType] == $sourceType} {
                set statList [ixNet getList $catalog stat]
                foreach statItem $statList {
                    lappend statNameList [ixNet getAttribute $statItem -name]
                }
                break
            }
        }
    }

    # Create userStatView
    # First search whether we have already added a userStatView for that
    # sourceType.
    set existFlag false
    set userStatViewList [ixNet getList [ixNet getRoot]/statistics userStatView]
    foreach userView $userStatViewList {
        if {[ixNet getAttribute $userView -viewCaption] == \
                "$realPort/$sourceType"} {
            set userStatViewObjRef $userView
            set existFlag true
            break
        }
    }

    if {$existFlag == "true"} {
        set retCode [ixNetworkNodeSetAttr $userStatViewObjRef \
                {-enabled false} -commit]
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to disable user stat view.\
                    [keylget retCode log]"
            return $returnList
        }
    } else {
        set correctly_added false
        set initTime [clock seconds]
        set timeoutCount 300; # Try for 300 seconds.
        while {!$correctly_added && \
                ([expr [clock seconds] - $initTime]) < $timeoutCount} {
            set result [ixNetworkNodeAdd [ixNet getRoot]/statistics \
                    userStatView [subst {-viewCaption $realPort/$sourceType}] \
                    -commit]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not add an user stat view using\
                        the following caption: $realPort/$sourceType -\
                        [keylget result log]."
                return $returnList
            }
            set userStatViewObjRef [keylget result node_objref]
            if {[ixNet getAttribute $userStatViewObjRef -viewCaption] == \
                    "$realPort/$sourceType"} {
                set correctly_added true
            } else {
                debug "ixNet remove $userStatViewObjRef"
                ixNet remove $userStatViewObjRef
                after 1000
            }
        }
        if {!$correctly_added} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to create a user stat view using the\
                        supplied caption name."
            return $returnList
        }
    }

    # Add tracked stats to the view
    foreach statName $statNameList {
        # First search whether we have already added a stat for that statName.
        set stat_missing 1
        set existing_stats [ixNetworkNodeGetList $userStatViewObjRef stat -all]
        foreach stat_objref $existing_stats {
            if {[ixNet getAttribute $stat_objref -statName] == $statName} {
                set stat_missing 0
                break
            }
        }
        # Add stat.
        if {$stat_missing} {
            set result [ixNetworkNodeAdd $userStatViewObjRef stat [subst {  \
                    -statName           {$statName}                         \
                    -sourceType         $sourceType                         \
                    -aggregationType    sum                                 \
                    -filterValueList    $filter                             \
                    -filterName         "Port"                              \
                    }] -commit]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not add a stat to the\
                        $userStatViewObjRef user stat view -\
                        [keylget result log]."
                return $returnList
            }
        }
    }
    
    set retCode [ixNetworkNodeSetAttr $userStatViewObjRef {-enabled true} -commit]
    if {[keylget retCode status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to enable user stat view.\
                [keylget retCode log]"
        return $returnList
    }

    keylset returnList status $::SUCCESS
    keylset returnList user_stat_view_objref $userStatViewObjRef
    return $returnList
}


proc ::ixia::ixNetworkGetDrillDownStats { port_handle mode {rowName IGNORE}} {
    if {$mode == "egress_by_flow"} {
        # Per flow
        set statChild "egressByFlow"
    } else {
        # Per port
        set statChild "egressByPort"
    }
    
    foreach stat_obj [ixNet getList [ixNet getRoot]statistics/drilldown $statChild] {
        if {[ixNet getAttribute $stat_obj -rxPort] == $port_handle} {
            if {$statChild == "egressByFlow" && ($rowName != "IGNORE")} {
                ixNet setAttribute $stat_obj -rowLabel $rowName
                ixNet commit
                # If we do not wait for at least 1 second the calls below will fail
                after 1000
            } elseif {$statChild == "egressByPort" && ($rowName == "IGNORE")} {
                ixNet setAttribute $stat_obj -rxPort $port_handle
                ixNet commit
                after 500
            }
            set ddobject $stat_obj
            break
        }
    }
    
    if {![info exists ddobject]} {
        if {$statChild == "egressByFlow" && ($rowName != "IGNORE")} {
            set result [ixNetworkNodeAdd                \
                    [ixNet getRoot]statistics/drilldown \
                    $statChild                          \
                    [list -rxPort $port_handle -rowLabel $rowName] \
                    -commit                             \
                    ]
        } else {
            set result [ixNetworkNodeAdd                \
                    [ixNet getRoot]statistics/drilldown \
                    $statChild                          \
                    [list -rxPort $port_handle]         \
                    -commit                             \
                    ]
        }
        if {[keylget result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to enable Egress Tracking statistics on port\
                    $port_handle. [keylget result log]."
            return $returnList
        }
        
        set ddobject [keylget result node_objref]
    }
    
    set obj_name_list ""
    # Enable drilldown views
    set stat_view_list [ixNet getList $ddobject view]
    foreach stat_view $stat_view_list {
        set numRetries 20
        while {([catch {set retCode [ixNet getAttribute $stat_view -isReady]}] || ($retCode  != "true")) && \
                ($numRetries > 0)} {
            after 1000
            incr numRetries -1
        }
        set numRetries 20
        while {[catch {lappend obj_name_list [ixNet getAttribute $stat_view -name]}] && \
                ($numRetries > 0)} {
            after 1000
            incr numRetries -1
        }
        
    }
    
    keylset returnList root_obj         $ddobject
    keylset returnList obj_name_list    $obj_name_list
    keylset returnList status           $::SUCCESS
    return $returnList
}

proc ::ixia::ixNetworkGetStatValue { statViewName {statNameList ""} } {
    set stats_list [list]

    set statViewList [ixNet getList [ixNet getRoot]/statistics statViewBrowser]
    set statViewObjRef ""
    foreach statView $statViewList {
        if {[ixNet getAttribute $statView -name] == $statViewName} {
            if {[ixNet getAttribute $statView -enabled] == "false"} {
                debug "ixNet setAttribute $statView -enabled true"
                ixNet setAttribute $statView -enabled true
                debug "ixNet commit"
                ixNet commit
            }
            set statViewObjRef $statView
            break
        }
    }
   
    if {$statViewObjRef == ""} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to get stat view '$statViewName'."
        return $returnList
    }
    set numRetries 10
    while {(([ixNet getAttribute $statViewObjRef -enabled] != "true") || \
            ([ixNet getAttribute $statViewObjRef -isReady] != "true")) && \
            ($numRetries > 0)} {
        after 1000
        incr numRetries -1
    }
    set pageNumber 1
    set totalPages [ixNet getAttribute $statViewObjRef -totalPages]
    set currentPage [ixNet getAttribute $statViewObjRef -currentPageNumber]
    set localTotalPages $totalPages

    if {$totalPages > 0 && $currentPage != $pageNumber} {
        debug "ixNet setAttribute $statViewObjRef -currentPageNumber $pageNumber"
        ixNet setAttribute $statViewObjRef -currentPageNumber $pageNumber
        debug "ixNet commit"
        ixNet commit
    }

    set continueFlag "true"
    set initTime [clock seconds]
    set timeoutCount 300; # Try for 300 seconds.
    while {$continueFlag == "true" && \
            ([expr [clock seconds] - $initTime]) < $timeoutCount} {
        if {[ixNet getAttribute $statViewObjRef -isReady] == true} {
            while {[set rowList [ixNet getList $statViewObjRef row]] == ""} {
                if {[expr [clock seconds] - $initTime] >= $timeoutCount} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The stat view is ready, but there\
                            are no statistics available."
                    return $returnList
                }
            }
            foreach row $rowList {
                while {[set cellList [ixNet getList $row cell]] == ""} {
                    if {[expr [clock seconds] - $initTime] >= $timeoutCount} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "The stat view is ready, but there\
                                are no statistics available."
                        return $returnList
                    }
                }
                foreach cell $cellList {
                    set outcome ERROR
                    while {$outcome == "ERROR" && \
                            ([expr [clock seconds] - $initTime]) < \
                            $timeoutCount} {
                        catch {ixNet getAttribute $cell -catalogStatName} \
                                stat_name
                        set matched [regexp {^::ixNet::(OK|ERROR|OBJ|LIST)-} \
                                $stat_name {} outcome]
                        if {$matched && $outcome == "ERROR"} {
                            after 100
                        } else {
                            set outcome ""
                        }
                    }
                    if {[lsearch $statNameList $stat_name] != -1} {
                        set outcome ERROR
                        while {$outcome == "ERROR" && \
                                ([expr [clock seconds] - $initTime]) < \
                                $timeoutCount} {
                            catch {ixNet getAttribute $cell -statValue} \
                                    stat_value
                            set matched [regexp {^::ixNet::(OK|ERROR|OBJ|LIST)-} \
                                    $stat_value {} outcome]
                            if {$matched && $outcome == "ERROR"} {
                                after 100
                            } else {
                                set outcome ""
                            }
                        }
                        keylset returnList $stat_name $stat_value
                    }
                }
            }

            set currentPage [ixNet getAttribute $statViewObjRef \
                    -currentPageNumber]
            if {$totalPages > 0 && $currentPage < $localTotalPages} {
                incr totalPages -1
                incr pageNumber
                debug "ixNet setAttribute $statViewObjRef -currentPageNumber \
                        $pageNumber"
                ixNet setAttribute $statViewObjRef -currentPageNumber \
                        $pageNumber
                debug "ixNet commit"
                ixNet commit
            } else {
                set continueFlag false
            }
        } else {
            after 1000
        }
    }
    if {$continueFlag == true} {
        keylset returnList status $::FAILURE
        keylset returnList log "Requested stat view is not ready."
    } else {
        keylset returnList status $::SUCCESS
    }
    return $returnList
}

proc ::ixia::enableStatViewList {statViews {statViewRoot "statViewBrowser"}\
        {retries 10}} {
    
    set statViewNo [llength $statViews]

    set statViewList [ixNet getList [ixNet getRoot]/statistics $statViewRoot]
    set statViewObjRefs ""
    foreach statView $statViewList {
        if {[lsearch $statViews [ixNet getAttribute $statView -name]] != -1 } {
            if {[ixNet getAttribute $statView -enabled] == "false"} {
                debug "ixNet setAttribute $statView -enabled true"
                ixNet setAttribute $statView -enabled true
            }
            lappend statViewObjRefs $statView
        }
    }
    debug "ixNet commit"
    ixNet commit
    
    if {[lempty $statViewObjRefs]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to get stat views: ${statViews}."
        return $returnList
    }
    set retry 0
    set success 0
    while {$retry < $retries} {
        set statViewsAreEnabled 1
        set statViewsAreReady 1
        foreach statViewObjRef $statViewObjRefs {
            # enable statView objects
            if {[ixNet getAttribute $statViewObjRef -enabled] != "true"} {
                debug "ixNet setAttribute $statViewObjRef -enabled true"
                ixNet setAttribute $statViewObjRef -enabled true
                set statViewsAreEnabled 0
            }
            # isReady statView objects
            if {$statViewsAreEnabled && \
                    [ixNet getAttribute $statViewObjRef -isReady] != "true"} {
                debug "ixNet setAttribute $statViewObjRef -enabled true"
                ixNet setAttribute $statViewObjRef -enabled true
                set statViewsAreReady 0
            }
            
            debug "ixNet commit"
            ixNet commit
        }
        if {$statViewsAreEnabled == 0 || $statViewsAreReady == 0} {
            after 1000
        } else {
            after 2000
            set success 1
            break
        }
        incr retry 1
    }
    if {$success} {
        keylset returnList status $::SUCCESS
        return $returnList
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "Timeout occured waiting statView objects to\
                become ready."
        return $returnList
    }
}

proc ::ixia::ixNetworkGetStats {
    statViewName
    {statNameList ""}
    {statViewRoot "statViewBrowser"}
    {statViewType "list"}
    } {

    set statViewObjRef ""
    
    set wait_needed 0
    
    set retry_no 1
    while {$statViewObjRef=="" && $retry_no<=10} {
        set statViewList [ixNet getList [ixNet getRoot]/statistics $statViewRoot]
        foreach statView $statViewList {
            if {[ixNet getAttribute $statView -name] eq $statViewName} {
                if {[ixNet getAttribute $statView -enabled] == "false"} {
                    debug "ixNet setAttribute $statView -enabled true"
                    ixNet setAttribute $statView -enabled true
                    debug "ixNet commit"
                    ixNet commit
                    set wait_needed 1
                }
                set statViewObjRef $statView
                break
            }
        }
        if {$statViewObjRef==""} {
            after 1000
            puts "Waiting for $statViewName to become available. Retry $retry_no ..."
        }
        incr retry_no
    }
    
    if {$statViewObjRef == ""} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to get stat view '$statViewName'."
        return $returnList
    }
    if {$wait_needed} {
        debug "wait needed"
        set numRetries 10
        while {(([ixNet getAttribute $statViewObjRef -enabled] != "true") || \
                [ixNet getAttribute $statViewObjRef -isReady] != "true") && \
                ($numRetries > 0)} {
            debug "ixNet setAttribute $statViewObjRef -enabled true"
            ixNet setAttribute $statViewObjRef -enabled true
            debug "ixNet commit"
            ixNet commit
            after 1000
            incr numRetries -1
        }
        after 2000
    } else {
        debug "wait not needed"
    }
    if {$statViewType == "list"} {
        set pageNumber 1
        set currentRow 1
        set totalPages [ixNet getAttribute $statViewObjRef -totalPages]
        set currentPage [ixNet getAttribute $statViewObjRef -currentPageNumber]
        set localTotalPages $totalPages

        if {$totalPages > 0 && $currentPage != $pageNumber} {
            debug "ixNet setAttribute $statViewObjRef -currentPageNumber\
                    $pageNumber"
            ixNet setAttribute $statViewObjRef -currentPageNumber $pageNumber
            debug "ixNet commit"
            ixNet commit
        }

        array set stats [list]
        set continueFlag "true"
        set initTime [clock seconds]
        set timeoutCount 300; # Try for 300 seconds.
        while {$continueFlag == "true" && \
                ([expr [clock seconds] - $initTime]) < $timeoutCount} {
            if {[ixNet getAttribute $statViewObjRef -isReady] == true} {
                while {[set rowList [ixNet getList $statViewObjRef row]] == ""} {
                    if {[expr [clock seconds] - $initTime] >= $timeoutCount} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "The stat view is ready, but there\
                                are no statistics available."
                        return $returnList
                    }
                }
                foreach row $rowList {
                    # get the row name
                    if {[info exists row_name]} {
                        unset row_name
                    }
                    catch {ixNet getAttribute $row -name} row_name
                    if {[info exists row_name]} {
                        set stats($currentRow) $row_name
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to get row name \
                                when reading from stat view '$statViewName'."
                        return $returnList
                    }
                    # get the stats
                    while {[set cellList [ixNet getList $row cell]] == ""} {
                        if {[expr [clock seconds] - $initTime] >= $timeoutCount} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "The stat view is ready, but there\
                                    are no statistics available."
                            return $returnList
                        }
                    }
                    foreach cell $cellList {
                        set outcome ERROR
                        while {$outcome == "ERROR" && \
                                ([expr [clock seconds] - $initTime]) < \
                                $timeoutCount} {
                            catch {ixNet getAttribute $cell -columnName} \
                                    stat_name
                            set matched [regexp {^::ixNet::(OK|ERROR|OBJ|LIST)-} \
                                    $stat_name {} outcome]
                            if {$matched && $outcome == "ERROR"} {
                                after 100
                            } else {
                                set outcome ""
                            }
                        }
                        if {$outcome == "ERROR"} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Unable to get cell\
                                    columnName from stat view '$statViewName'."
                            return $returnList
                        }

                        set stat_name_esc [regsub -all {\]} [regsub -all {\[} $stat_name {(}] {)}]
                        if {[lsearch $statNameList $stat_name_esc] != -1} {
                            set outcome ERROR
                            while {$outcome == "ERROR" && \
                                    ([expr [clock seconds] - $initTime]) < \
                                    $timeoutCount} {
                                catch {ixNet getAttribute $cell -statValue} \
                                        stat_value
                                set matched [regexp {^::ixNet::(OK|ERROR|OBJ|LIST)-} \
                                        $stat_value {} outcome]
                                if {$matched && $outcome == "ERROR"} {
                                    after 100
                                } else {
                                    set outcome ""
                                }
                            }
                            if {$outcome == "ERROR"} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Unable to get value of\
                                        cell '$stat_name' from stat view\
                                        '$statViewName'."
                                return $returnList
                            }
                            set stats($currentRow,$stat_name_esc) $stat_value
                        }
                    }
                    incr currentRow
                }

                set currentPage [ixNet getAttribute $statViewObjRef \
                        -currentPageNumber]
                if {$totalPages > 0 && $currentPage < $localTotalPages} {
                    incr totalPages -1
                    incr pageNumber
                    debug "ixNet setAttribute $statViewObjRef\
                            -currentPageNumber $pageNumber"
                    ixNet setAttribute $statViewObjRef -currentPageNumber \
                            $pageNumber
                    debug "ixNet commit"
                    ixNet commit
                } else {
                    set continueFlag false
                }
            } else {
                after 1000
            }
        }
        if {$continueFlag == true} {
            keylset returnList status $::FAILURE
            keylset returnList log "Requested stat view is not ready."
        } else {
            keylset returnList status $::SUCCESS
            keylset returnList row_count [expr $currentRow - 1]
            keylset returnList statistics [array get stats]
        }
    } elseif {$statViewType == "chart"} {
        array set stats [list]
        set continueFlag "true"
        set initTime [clock seconds]
        set timeoutCount 30; # Try for 300 seconds.
        while {$continueFlag == "true" && \
                ([expr [clock seconds] - $initTime]) < $timeoutCount} {
            if {[ixNet getAttribute $statViewObjRef -isReady] == true} {
                while {[set rowList [ixNet getList $statViewObjRef row]] == ""} {
                    if {[expr [clock seconds] - $initTime] >= $timeoutCount} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "The stat view is ready, but there\
                                are no statistics available."
                        return $returnList
                    }
                }
                foreach row $rowList {
                    set outcome ERROR
                    while {$outcome == "ERROR" && \
                            ([expr [clock seconds] - $initTime]) < \
                            $timeoutCount} {
                        catch {ixNet getAttribute $row -name} \
                                stat_name
                        set matched [regexp {^::ixNet::(OK|ERROR|OBJ|LIST)-} \
                                $stat_name {} outcome]
                        if {$matched && $outcome == "ERROR"} {
                            after 100
                        } else {
                            set outcome ""
                        }
                    }
                    if {$outcome == "ERROR"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to get row name\
                                from stat view '$statViewName'."
                        return $returnList
                    }
                    while {[set cellList [ixNet getList $row cell]] == ""} {
                        if {[expr [clock seconds] - $initTime] >= $timeoutCount} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "The stat view is ready, but there\
                                    are no statistics available."
                            return $returnList
                        }
                    }
                    foreach cell $cellList {}
                    if {[lsearch $statNameList $stat_name] != -1} {
                        set outcome ERROR
                        while {$outcome == "ERROR" && \
                                ([expr [clock seconds] - $initTime]) < \
                                $timeoutCount} {
                            catch {ixNet getAttribute $cell -statValue} \
                                    stat_value
                            set matched [regexp {^::ixNet::(OK|ERROR|OBJ|LIST)-} \
                                    $stat_value {} outcome]
                            if {$matched && $outcome == "ERROR"} {
                                after 100
                            } else {
                                set outcome ""
                            }
                        }
                        if {$outcome == "ERROR"} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Unable to get value of\
                                    cell '$stat_name' of stat view\
                                    '$statViewName'."
                            return $returnList
                        }
                        set stats($stat_name) $stat_value
                    }
                }
                set continueFlag false
            } else {
                after 1000
            }
        }
        if {$continueFlag == true} {
            keylset returnList status $::FAILURE
            keylset returnList log "Requested stat view is not ready."
        } else {
            keylset returnList status $::SUCCESS
            keylset returnList statistics [array get stats]
        }
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "'$statViewName' is not a valid value for the\
                statViewType parameter. The statViewType must be set either to\
                'list' or to 'chart'."
        return $returnList
    }

    return $returnList
}

proc ::ixia::ixNetworkRemoveUserStats { realPort sourceType } {
    set user_stat_views [ixNetworkNodeGetList [ixNet getRoot]/statistics \
            userStatView -all]
    foreach user_stat_view $user_stat_views {
        if {[ixNet getAttribute $user_stat_view -viewCaption] == \
                "$realPort/$sourceType"} {
            debug "ixNet remove $user_stat_view"
            ixNet remove $user_stat_view
            debug "ixNet commit"
            ixNet commit
            break
        }
    }
}

proc ::ixia::ixNetworkGetRouterPort { objRef } {
    variable ixnetwork_port_handles_array_vport2rp

    if {[info exists ixnetwork_port_handles_array_vport2rp($objRef)]} {
        return $ixnetwork_port_handles_array_vport2rp($objRef)
    }

    # If the port handle is not found, return 0/0/0
    return "0/0/0"
}

proc ::ixia::ixNetworkCheckEndpoint {
    endpoint_handle
    endpoint_type
    circuit_type
    circuit_endpoint_type
    } {
    
    variable truth

    # Source regexp lists
    set eth_src [list]
    lappend eth_src {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+$}
    lappend eth_src {^::ixNet::OBJ-/vport:\d+/protocols/static/lan:\d+$}
    lappend eth_src {^::ixNet::OBJ-/vport:\d+/protocols/ldp/router:\d+/l2Interface:\d+/l2VcRange:\d+$}
    lappend eth_src {^::ixNet::OBJ-/vport:\d+/protocols/ldp/router:\d+/l2Interface:\d+$}
    lappend eth_src {^::ixNet::OBJ-/vport:\d+/protocols/ldp/router:\d+$}
    
    set ipv4_src [list]
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+/routeRange:\d+$}
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+$}
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/protocols/ldp/router:\d+$}
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/protocols/ldp/router:\d+/l2Interface:\d+$}
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/protocols/ldp/router:\d+/l2Interface:\d+/l2VcRange:\d+$}
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/protocols/pimsm/router:\d+/interface:\d+/source:\d+$}
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/protocols/(eigrp|isis|ospf|rip)/router:\d+/routeRange:\d+$}
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/protocols/(eigrp|isis|ospf|pimsm|rip)/router:\d+$}
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppoxEndpoint:[^/]+/range:[^/]+$}
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppoxEndpoint:[^/]+$}
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppoxEndpoint:[^/]+/range:[^/]+$}
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppoxEndpoint:[^/]+$}
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+/range:[^/]+$}
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+$}
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+/range:[^/]+$}
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+$}
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/interface:\d+$}
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/protocols/static/ip:\d+$}
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ipEndpoint:[^/]+/range:[^/]+$}
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+/range:[^/]+$}
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+$}
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+/range:[^/]+$}
    lappend ipv4_src {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+$}
    
    set ipv6_src [list]
    lappend ipv6_src {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+/routeRange:\d+$}
    lappend ipv6_src {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+$}
    lappend ipv6_src {^::ixNet::OBJ-/vport:\d+/protocols/pimsm/router:\d+/interface:\d+/source:\d+$}
    lappend ipv6_src {^::ixNet::OBJ-/vport:\d+/protocols/pimsm/router:\d+/interface:\d+/joinPrune:\d+$}
    lappend ipv6_src {^::ixNet::OBJ-/vport:\d+/protocols/(eigrp|isis|ospfV3|ripng)/router:\d+/routeRange:\d+$}
    lappend ipv6_src {^::ixNet::OBJ-/vport:\d+/protocols/(eigrp|isis|ospfV3|pimsm|ripng)/router:\d+$}
    lappend ipv6_src {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppoxEndpoint:[^/]+/range:[^/]+$}
    lappend ipv6_src {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppoxEndpoint:[^/]+$}
    lappend ipv6_src {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppoxEndpoint:[^/]+/range:[^/]+$}
    lappend ipv6_src {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppoxEndpoint:[^/]+$}
    lappend ipv6_src {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+/range:[^/]+$}
    lappend ipv6_src {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+$}
    lappend ipv6_src {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+/range:[^/]+$}
    lappend ipv6_src {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+$}
    lappend ipv6_src {^::ixNet::OBJ-/vport:\d+/interface:\d+$}
    lappend ipv6_src {^::ixNet::OBJ-/vport:\d+/protocols/static/ip:\d+$}
    lappend ipv6_src {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+/range:[^/]+$}
    lappend ipv6_src {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+$}
    lappend ipv6_src {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+/range:[^/]+$}
    lappend ipv6_src {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+$}
    

    set l2vpn_src [list]
    lappend l2vpn_src {^::ixNet::OBJ-/vport:\d+/protocols/ldp/router:\d+/l2Interface:\d+/l2VcRange:\d+$}
    lappend l2vpn_src {^::ixNet::OBJ-/vport:\d+/protocols/ldp/router:\d+/l2Interface:\d+$}
    lappend l2vpn_src {^::ixNet::OBJ-/vport:\d+/protocols/ldp/router:\d+$}
    lappend l2vpn_src {^::ixNet::OBJ-/vport:\d+/protocols/ldp$}

    set vrf_src [list]
    lappend vrf_src {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+/l3Site:\d+/vpnRouteRange:\d+$}
    lappend vrf_src {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+/l3Site:\d+$}
    lappend vrf_src {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+$}
    lappend vrf_src {^::ixNet::OBJ-/vport:\d+/protocols/bgp$}

    set mpls_src [list]
    lappend mpls_src {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+/mplsRouteRange:\d+$}
    lappend mpls_src {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+$}
    lappend mpls_src {^::ixNet::OBJ-/vport:\d+/protocols/ldp/router:\d+/advFECRange:\d+$}
    lappend mpls_src {^::ixNet::OBJ-/vport:\d+/protocols/ldp/router:\d+$}
    lappend mpls_src {^::ixNet::OBJ-/vport:\d+/protocols/(ldp|bgp)$}
    lappend mpls_src {^::ixNet::OBJ-/vport:\d+/protocols/rsvp/neighborPair:\d+/destinationRange:\d+/ingress$}

    set 6pe_src [list]
    lappend 6pe_src {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+/mplsRouteRange:\d+$}
    lappend 6pe_src {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+$}
    lappend 6pe_src {^::ixNet::OBJ-/vport:\d+/protocols/bgp$}

    set vpls_src [list]
    lappend vpls_src {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+/l2Site:\d+/macAddressRange:\d+$}
    lappend vpls_src {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+/l2Site:\d+$}
    lappend vpls_src {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+$}
    lappend vpls_src {^::ixNet::OBJ-/vport:\d+/protocols/bgp$}

    # Destination regexp lists
    set ipv4_dst [list]
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+/l3Site:\d+/vpnRouteRange:\d+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+/l3Site:\d+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+/mplsRouteRange:\d+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+/routeRange:\d+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocols/igmp/host:\d+/group:\d+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocols/igmp/host:\d+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocols/ldp/router:\d+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocols/ldp/router:\d+/advFECRange:\d+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocols/ldp/router:\d+/l2Interface:\d+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocols/ldp/router:\d+/l2Interface:\d+/l2VcRange:\d+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocols/pimsm/router:\d+/interface:\d+/joinPrune:\d+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocols/(eigrp|isis|ospf|rip)/router:\d+/routeRange:\d+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocols/(eigrp|isis|ldp|ospf|pimsm|rip)/router:\d+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppoxEndpoint:[^/]+/range:[^/]+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppoxEndpoint:[^/]+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppoxEndpoint:[^/]+/range:[^/]+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppoxEndpoint:[^/]+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+/range:[^/]+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+/range:[^/]+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/interface:\d+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocols/pimsm/router:\d+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocols/pimsm/router:\d+/interface:\d+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocols/pimsm$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocols/rsvp/neighborPair:\d+/destinationRange:\d+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocols/static/ip:\d+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ipEndpoint:[^/]+/range:[^/]+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+/range:[^/]+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+/range:[^/]+$}
    lappend ipv4_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+$}
    
    set ipv6_dst [list]
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+/l3Site:\d+/vpnRouteRange:\d+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+/l3Site:\d+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+/mplsRouteRange:\d+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+/routeRange:\d+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocols/mld/host:\d+/groupRange:\d+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocols/mld/host:\d+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocols/pimsm/router:\d+/interface:\d+/joinPrune:\d+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocols/(eigrp|isis|ospfV3|ripng)/router:\d+/routeRange:\d+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocols/(eigrp|isis|ospfV3|pimsm|ripng)/router:\d+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppoxEndpoint:[^/]+/range:[^/]+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppoxEndpoint:[^/]+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppoxEndpoint:[^/]+/range:[^/]+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppoxEndpoint:[^/]+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+/range:[^/]+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+/range:[^/]+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/interface:\d+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocols/pimsm/router:\d+/interface:\d+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocols/pimsm/router:\d+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocols/pimsm$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocols/rsvp/neighborPair:\d+/destinationRange:\d+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocols/static/ip:\d+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+/range:[^/]+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+/range:[^/]+$}
    lappend ipv6_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+$}
    

    set rsvp_dst [list]
    lappend rsvp_dst {^::ixNet::OBJ-/vport:\d+/protocols/rsvp/neighborPair:\d+/destinationRange:\d+$}

    set l2vpn_dst [list]
    lappend l2vpn_dst {^::ixNet::OBJ-/vport:\d+/protocols/ldp/router:\d+/l2Interface:\d+/l2VcRange:\d+$}
    lappend l2vpn_dst {^::ixNet::OBJ-/vport:\d+/protocols/ldp/router:\d+/l2Interface:\d+$}
    lappend l2vpn_dst {^::ixNet::OBJ-/vport:\d+/protocols/ldp/router:\d+$}
    lappend l2vpn_dst {^::ixNet::OBJ-/vport:\d+/protocols/ldp$}
    lappend l2vpn_dst {^::ixNet::OBJ-/vport:\d+/protocols/static/(ip|lan|fr|atm):\d+$}

    set eth_dst [list]
    lappend eth_dst {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+/l2Site:\d+/macAddressRange:\d+$}
    lappend eth_dst {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+/l2Site:\d+$}
    lappend eth_dst {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+$}
    lappend eth_dst {^::ixNet::OBJ-/vport:\d+/protocols/ldp/router:\d+/l2Interface:\d+/l2VcRange:\d+$}
    lappend eth_dst {^::ixNet::OBJ-/vport:\d+/protocols/ldp/router:\d+/l2Interface:\d+$}
    lappend eth_dst {^::ixNet::OBJ-/vport:\d+/protocols/ldp/router:\d+$}
    lappend eth_dst {^::ixNet::OBJ-/vport:\d+/protocols/(ldp|bgp)$}
    lappend eth_dst {^::ixNet::OBJ-/vport:\d+/protocols/static/(ip|lan|fr|atm):\d+$}
    lappend eth_dst {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+$}

    # Raw traffic endpoint regexp
    set raw [list]
    lappend raw {^::ixNet::OBJ-/vport:\d+$}
    lappend raw {^::ixNet::OBJ-/vport:\d+/protocols$}
    
    # STP endpoint regexp    
    set stp_lan [list]
    lappend stp_lan {^::ixNet::OBJ-/vport:\d+/protocols/stp/lan:\d+}

    # CFM Mac Range endpoint regexp    
    set cfm_mr [list]
    lappend cfm_mr {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/vlan:\d+/mac:\d+$}

    # PBB Mac Range endpoint regexp    
    set pbb_mr [list]
    lappend pbb_mr {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+$}
    lappend pbb_mr {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/trunk:\d+$}
    lappend pbb_mr {^::ixNet::OBJ-/vport:\d+/protocols/cfm/bridge:\d+/trunk:\d+/macRanges:\d+$}
    
    # DCBX Range endpoint regexp    
    set dcbx_range [list]
    lappend dcbx_range {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:"[0-9a-zA-Z\-]+"/dcbxEndpoint:"[0-9a-zA-Z\-]+"$}
    lappend dcbx_range {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:"[0-9a-zA-Z\-]+"/dcbxEndpoint:"[0-9a-zA-Z\-]+"/range:"[0-9a-zA-Z\-]+"$}
    lappend dcbx_range {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:"[0-9a-zA-Z\-]+"/dcbxEndpoint:"[0-9a-zA-Z\-]+"/range:"[0-9a-zA-Z\-]+"/macRange$}
    
    set all_ppp  [list]
    set all_fcoe [list]
    set all_fc   [list]
    lappend all_fcoe {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:"[0-9a-zA-Z\-]+"/fcoeClientEndpoint:"[0-9a-zA-Z\-]+"/range:"[0-9a-zA-Z\-]+"$}
    lappend all_fcoe {^::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:"[0-9a-zA-Z\-]+"/fcoeFwdEndpoint:"[0-9a-zA-Z\-]+"/secondaryRange:"[0-9a-zA-Z\-]+"$}
    lappend all_fc   {^::ixNet::OBJ-/vport:\d+/protocolStack/fcClientEndpoint:"[0-9a-zA-Z\-]+"/range:"[0-9a-zA-Z\-]+"$}
    lappend all_fc   {^::ixNet::OBJ-/vport:\d+/protocolStack/fcFwdEndpoint:"[0-9a-zA-Z\-]+"/range:"[0-9a-zA-Z\-]+"$}
    lappend all_fc   {^::ixNet::OBJ-/vport:\d+/protocolStack/fcFwdEndpoint:"[0-9a-zA-Z\-]+"/secondaryRange:"[0-9a-zA-Z\-]+"$}
    
    set all_eth_vlan_src [join [list $cfm_mr $eth_src $l2vpn_src $vpls_src $stp_lan $pbb_mr $dcbx_range]]
    set all_eth_vlan_dst [join [list $cfm_mr $eth_dst $stp_lan $pbb_mr $dcbx_range]]
    
    set all_atm_src $l2vpn_src
    set all_atm_dst $l2vpn_dst
    
    set all_fr_src []
    set all_fr_dst []
    
    set all_hdlc_src []
    set all_hdlc_dst []
    
    set all_ipv4_src [join [list $ipv4_src $vrf_src $mpls_src]]
    set all_ipv4_dst $ipv4_dst
    
    set all_ipv4_ap_src [join [list $ipv4_src $mpls_src]]
    set all_ipv4_ap_dst $ipv4_dst
    
    set all_ipv6_src [join [list $ipv6_src $mpls_src $6pe_src $vrf_src]]
    set all_ipv6_dst [join [list $ipv6_dst $rsvp_dst]]
    
    set all_ipv6_ap_src $ipv6_src
    set all_ipv6_ap_dst $ipv6_dst
    
    # List of valid combinations (protocol-wise)
    set circuit_config_list [list                                                       \
            {none       ipv4                        ipv4_src            ipv4_dst    }   \
            {none       ipv4_application_traffic    ipv4_src            ipv4_dst    }   \
            {none       ipv6                        ipv6_src            ipv6_dst    }   \
            {none       ipv6_application_traffic    ipv6_src            ipv6_dst    }   \
            {none       ethernet_vlan               cfm_mr              cfm_mr      }   \
            {l2vpn      atm                         l2vpn_src           l2vpn_dst   }   \
            {l2vpn      ethernet_vlan               l2vpn_src           eth_dst     }   \
            {l3vpn      ipv4                        vrf_src             ipv4_dst    }   \
            {l3vpn      ipv4_application_traffic    vrf_src             ipv4_dst    }   \
            {mpls       ipv4                        mpls_src            ipv4_dst    }   \
            {mpls       ipv4_application_traffic    mpls_src            ipv4_dst    }   \
            {mpls       ipv6                        mpls_src            rsvp_dst    }   \
            {6pe        ipv6                        6pe_src             ipv6_dst    }   \
            {6vpe       ipv6                        vrf_src             ipv6_dst    }   \
            {raw        atm                         raw                 raw         }   \
            {raw        ethernet_vlan               raw                 raw         }   \
            {vpls       ethernet_vlan               vpls_src            eth_dst     }   \
            {stp        ethernet_vlan               stp_lan             stp_lan     }   \
            {mac_in_mac ethernet_vlan               pbb_mr              pbb_mr      }   \
            {all        atm                         all_atm_src         all_atm_dst }   \
            {all        ethernet_vlan               all_eth_vlan_src    all_eth_vlan_dst} \
            {all        fcoe                        all_fcoe            all_fcoe    }   \
            {all        fc                          all_fc              all_fc      }   \
            {all        frame_relay                 all_fr_src          all_fr_dst  }   \
            {all        hdlc                        all_hdlc_src        all_hdlc_dst}   \
            {all        ipv4                        all_ipv4_src        all_ipv4_dst}   \
            {all        ipv4_application_traffic    all_ipv4_ap_src     all_ipv4_ap_dst } \
            {all        ipv6                        all_ipv6_src        all_ipv6_dst}   \
            {all        ipv6_application_traffic    all_ipv6_ap_src     all_ipv6_ap_dst }  \
            {all        ppp                         all_ppp             all_ppp         }   \
            {all        raw                         raw                 raw         }   \
            {raw        fcoe                        raw                 raw         }   \
            {raw        fc                          raw                 raw         }   \
            {raw        frame_relay                 raw                 raw         }   \
            {raw        hdlc                        raw                 raw         }   \
            {raw        ipv4                        raw                 raw         }   \
            {raw        ipv4_application_traffic    raw                 raw         }   \
            {raw        ipv6                        raw                 raw         }   \
            {raw        ipv6_application_traffic    raw                 raw         }   \
            {raw        ppp                         raw                 raw         }   \
            {raw        raw                         raw                 raw         }   \
        ]

    # Check if the circuit_type - circuit_endpoint_type combination is valid
    set found 0
    foreach circuit_pair $circuit_config_list {
        if {[lindex $circuit_pair 0] == $circuit_type && \
                [lindex $circuit_pair 1] == $circuit_endpoint_type} {
            set found 1
            set src_regex [subst $[lindex $circuit_pair 2]]
            set dst_regex [subst $[lindex $circuit_pair 3]]
            break
        }
    }
    if {$found == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "The (${circuit_type},${circuit_endpoint_type}) \
                circuit settings pair is not supported."
        return $returnList
    }

    # Get the IP version (if that's the case)
    regexp {^ipv(4|6)} $circuit_endpoint_type {} ip_version

    # Get the circuit end
    if {$endpoint_type == "src"} {
        set endpoint_regex $src_regex
        # Possible source dual-stack endpoints
        set dual_stack [list]
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+)/(routeRange):\d+$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocols/bgp)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocols/isis/router:\d+)/(routeRange):\d+$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocols/isis/router:\d+)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocols/isis)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppoxEndpoint:[^/]+)/(range:[^/]+)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppoxEndpoint:[^/]+)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppoxEndpoint:[^/]+)/(range:[^/]+)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppoxEndpoint:[^/]+)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+)/(range:[^/]+)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+)/(range:[^/]+)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/interface:\d+)$}
    } elseif {$endpoint_type == "dst"} {
        set endpoint_regex $dst_regex
        # Possible destination dual-stack endpoints
        set dual_stack [list]
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+/l3Site:\d+)/(vpnRouteRange):\d+$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+/l3Site:\d+)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+)/(mplsRouteRange):\d+$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+)/(routeRange):\d+$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocols/bgp)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocols/isis/router:\d+)/(routeRange):\d+$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocols/isis/router:\d+)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocols/isis)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppoxEndpoint:[^/]+)/(range:[^/]+)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/pppoxEndpoint:[^/]+)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppoxEndpoint:[^/]+)/(range:[^/]+)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/pppoxEndpoint:[^/]+)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+)/(range:[^/]+)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocolStack/ethernet:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+)/(range:[^/]+)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/protocolStack/atm:[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+)$}
        lappend dual_stack {^(::ixNet::OBJ-/vport:\d+/interface:\d+)$}
    }

    keylset returnList status $::SUCCESS

    set error_log_list ""

    # Check the endpoint handles
    set endpoint_handle [lindex $endpoint_handle 0]
    foreach handle $endpoint_handle {
        # Check each handle using each matching regular expression
        set objref_match false
        foreach regex $endpoint_regex {
            # If a match is found, check if the objref exists
            if {[regexp $regex $handle]} {
                set objref_match true
                if {[ixNet exists $handle] == "false" || [ixNet exists $handle] == 0} {
                    # If it doesn't, error
                    keylset returnList status $::FAILURE
                    append error_log_list "The '$handle'\
                            endpoint handle does not exist."
                } elseif {[info exists ip_version] && \
                        ($ip_version == 4 || $ip_version == 6)} {
                    # If it does, check its IP type
                    set ip_version_match true
                    foreach regex $dual_stack {
                        if {[regexp $regex $handle {} obj chld]} {
                            set ip_version_match false
                            if {$chld == ""} {
                                if {[regexp {interface} $handle]} {
                                    if {[llength [ixNet getList $handle \
                                            ipv$ip_version]] > 0} {
                                        set ip_version_match true
                                    }
                                } else {
                                    if {[regexp {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+/l3Site:\d+$} $handle]} {
                                        set ip_version_match $truth([ixNetworkNodeTreeSearch ipv$ip_version $handle {{child step vpnRouteRange} {{attr get ipType} {}}}])
                                    } elseif {[regexp {^::ixNet::OBJ-/vport:\d+/protocols/bgp/neighborRange:\d+$} $handle]} {
                                        set ip_version_match $truth([ixNetworkNodeTreeSearch ipv$ip_version $handle {{child step routeRange} {{attr get ipType} {}}}])
                                        if {$ip_version_match == false} { set ip_version_match $truth([ixNetworkNodeTreeSearch ipv$ip_version $handle {{child step mplsRouteRange} {{attr get ipType} {}}}]) }
                                        if {$ip_version_match == false} { set ip_version_match $truth([ixNetworkNodeTreeSearch ipv$ip_version $handle {{child step l3Site} {{child step vpnRouteRange} {{attr get ipType} {}}}}]) }
                                    } elseif {[regexp {^::ixNet::OBJ-/vport:\d+/protocols/bgp$} $handle]} {
                                        set ip_version_match $truth([ixNetworkNodeTreeSearch ipv$ip_version $handle {{child step neighborRange} {{child step routeRange} {{attr get ipType} {}}}}])
                                        if {$ip_version_match == false} { set ip_version_match $truth([ixNetworkNodeTreeSearch ipv$ip_version $handle {{child step neighborRange} {{child step mplsRouteRange} {{attr get ipType} {}}}}]) }
                                        if {$ip_version_match == false} { set ip_version_match $truth([ixNetworkNodeTreeSearch ipv$ip_version $handle {{child step neighborRange} {{child step l3Site} {{child step vpnRouteRange} {{attr get ipType} {}}}}}]) }
                                    } elseif {[regexp {^::ixNet::OBJ-/vport:\d+/protocols/isis/router:\d+$} $handle]} {
                                        set ip_version_match $truth([ixNetworkNodeTreeSearch ipv$ip_version $handle {{child step routeRange} {{attr get type} {}}}])
                                    } elseif {[regexp {^::ixNet::OBJ-/vport:\d+/protocols/isis$} $handle]} {
                                        set ip_version_match $truth([ixNetworkNodeTreeSearch ipv$ip_version $handle {{child step router} {{child step routeRange} {{attr get type} {}}}}])
                                    } elseif {[regexp {^::ixNet::OBJ-/vport:\d+/protocolStack/(atm|ethernet):[^/]+/pppoxEndpoint:[^/]+$} $handle]} {
                                        set ip_version_match $truth([ixNetworkNodeTreeSearch IPv$ip_version $handle {{child step range} {{child step pppoxRange} {{attr get ncpType} {}}}}])
                                    } elseif {[regexp {^::ixNet::OBJ-/vport:\d+/protocolStack/(atm|ethernet):[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+$} $handle]} {
                                        set ip_version_match $truth([ixNetworkNodeTreeSearch IPv$ip_version $handle {{child step range} {{child step l2tpRange} {{attr get ncpType} {}}}}])
                                    }
                                }
                            } else {
                                if {[regexp {isis} $handle]} {
                                    if {[string match -nocase "*ipv${ip_version}*" \
                                            [ixNet getAttribute $handle -type]]} {
                                        set ip_version_match true
                                    }
                                } elseif {[regexp {bgp} $handle]} {
                                    if {[string match -nocase "*ipv${ip_version}*" \
                                            [ixNet getAttribute $handle -ipType]] } {
                                        set ip_version_match true
                                    }
                                } else {
                                    if {[info exists range_type]} {
                                        unset range_type
                                    }
                                    if {[regexp {l2tpEndpoint} $obj]} {
                                        set range_type l2tpRange
                                    } elseif {[regexp {pppoxEndpoint} $obj]} {
                                        set range_type pppoxRange
                                    }
                                    if {[info exists range_type] && \
                                            [string match -nocase "*ipv${ip_version}*" \
                                            [ixNet getAttribute $handle/$range_type -ncpType]]} {
                                        set ip_version_match true
                                    }
                                }
                            }
                            break
                        }
                    }
                    if {$ip_version_match == false} {
                        keylset returnList status $::FAILURE
                        append error_log_list "The '$handle' source\
                                endpoint handle does not have any IPv$ip_version\
                                endpoint configured."
                    }
                }
                break
            }
        }

        if {$objref_match == false} {
            keylset returnList status $::FAILURE
            append error_log_list "The '$handle' endpoint handle does\
                    not match any valid format for the '$circuit_type' circuit\
                    type and the '$circuit_endpoint_type' circuit endpoint\
                    type."
        }
    }

    if {$error_log_list != ""} {
        keylset returnList log $error_log_list
    }
    return $returnList
}

proc ::ixia::ixNetworkCheckValueList { override_value_list track_by } {
    array set translate_tos_monetary [list                  \
        normal                      0                       \
        minimize                    1                       \
    ]

    array set translate_tos_reliability [list               \
        normal                      0                       \
        high                        1                       \
    ]

    array set translate_tos_throughput [list                \
        normal                      0                       \
        high                        1                       \
    ]

    array set translate_tos_delay [list                     \
        normal                      0                       \
        low                         1                       \
    ]

    array set translate_tos_precedence [list                \
        routine                      0                      \
        priority                     1                      \
        immediate                    2                      \
        flash                        3                      \
        flash_override               4                      \
        critical_ecp                 5                      \
        internetwork_contol          6                      \
        network_contol               7                      \
    ]

    array set translate_assured_forwarding_phb [list        \
        class_1,low_drop             10                     \
        class_1,medium_drop          12                     \
        class_1,high_drop            14                     \
        class_2,low_drop             18                     \
        class_2,medium_drop          20                     \
        class_2,high_drop            22                     \
        class_3,low_drop             26                     \
        class_3,medium_drop          28                     \
        class_3,high_drop            30                     \
        class_4,low_drop             34                     \
        class_4,medium_drop          36                     \
        class_4,high_drop            38                     \
    ]

    keylset returnList status $::SUCCESS

    set error_log_list ""
    set processed_override_value_list [list]

    switch -- $track_by {
        "assured_forwarding_phb" {
            if {[llength $override_value_list] == 3 && \
                    [llength [lindex $override_value_list 0]] == 1} {
                set override_value_list [list $override_value_list]
            }
            foreach nuple $override_value_list {
                if {[lindex $nuple 0] < 0 || [lindex $nuple 0] > 3} {
                    keylset returnList status $::FAILURE
                    append error_log_list "The '$nuple' line from the\
                            -override_value_list argument array has an invalid\
                            value ([lindex $nuple 0]) in the 'unused bits'\
                            field. The value should be an interger in the 0:3\
                            range. "
                }
                if {![regexp {class_(1|2|3|4)} [lindex $nuple 1]]} {
                    keylset returnList status $::FAILURE
                    append error_log_list "The '$nuple' line from the\
                            -override_value_list argument array has an invalid\
                            value ([lindex $nuple 1]) in the 'AF class' field.\
                            The value should be 'class_1', 'class_2', 'class_3'\
                            or 'class_4'. "
                }
                if {![regexp {(low|medium|high)_drop} [lindex $nuple 2]]} {
                    keylset returnList status $::FAILURE
                    append error_log_list "The '$nuple' line from the\
                            -override_value_list argument array has an invalid\
                            value ([lindex $nuple 2]) in the 'codepoint' field.\
                            The value should be 'low_drop', 'medium_drop' or\
                            'high_drop'. "
                }
                catch {lappend processed_override_value_list [expr [expr \
                        $translate_assured_forwarding_phb([lindex $nuple \
                        1],[lindex $nuple 2]) << 2] + [lindex $nuple 0]]}
            }
        }
        "class_selector_phb" {
            if {[llength $override_value_list] == 2 && \
                    [llength [lindex $override_value_list 0]] == 1} {
                set override_value_list [list $override_value_list]
            }
            foreach nuple $override_value_list {
                if {[lindex $nuple 0] < 0 || [lindex $nuple 0] > 3} {
                    keylset returnList status $::FAILURE
                    append error_log_list "The '$nuple' line from the\
                            -override_value_list argument array has an invalid\
                            value ([lindex $nuple 0]) in the 'unused bits'\
                            field. The value should be an interger in the 0:3\
                            range. "
                }
                if {[lindex $nuple 1] < 1 || [lindex $nuple 1] > 7} {
                    keylset returnList status $::FAILURE
                    append error_log_list "The '$nuple' line from the\
                            -override_value_list argument array has an invalid\
                            value ([lindex $nuple 1]) in the 'precedence'\
                            field. The value should be an interger in the 1:7\
                            range. "
                }
                catch {lappend processed_override_value_list [expr [expr \
                        [lindex $nuple 1] << 5] + [lindex $nuple 0]]}
            }
        }
        "default_phb" -
        "expedited_forwarding_phb" {
            if {[llength $override_value_list] == 2 && \
                    [llength [lindex $override_value_list 0]] == 1} {
                set override_value_list [list $override_value_list]
            }
            foreach nuple $override_value_list {
                if {[lindex $nuple 0] < 0 || [lindex $nuple 0] > 3} {
                    keylset returnList status $::FAILURE
                    append error_log_list "The '$nuple' line from the\
                            -override_value_list argument array has an invalid\
                            value ([lindex $nuple 0]) in the 'unused bits'\
                            field. The value should be an interger in the 0:3\
                            range. "
                }
                if {[lindex $nuple 1] < 0 || [lindex $nuple 1] > 63} {
                    keylset returnList status $::FAILURE
                    append error_log_list "The '$nuple' line from the\
                            -override_value_list argument array has an invalid\
                            value ([lindex $nuple 1]) in the 'codepoint'\
                            field. The value should be an interger in the 0:63\
                            range. "
                }
                catch {lappend processed_override_value_list [expr [expr \
                        [lindex $nuple 1] << 2] + [lindex $nuple 0]]}
            }
        }
        "tos" {
           if {[llength $override_value_list] == 6 && \
                    [llength [lindex $override_value_list 0]] == 1} {
                set override_value_list [list $override_value_list]
            }
            foreach nuple $override_value_list {
                if {[lindex $nuple 0] < 0 || [lindex $nuple 0] > 1} {
                    keylset returnList status $::FAILURE
                    append error_log_list "The '$nuple' line from the\
                            -override_value_list argument array has an invalid\
                            value ([lindex $nuple 0]) in the 'unused bits'\
                            field. The value should be an interger in the 0:1\
                            range. "
                }
                if {![regexp {(normal|minimize)} [lindex $nuple 1]]} {
                    keylset returnList status $::FAILURE
                    append error_log_list "The '$nuple' line from the\
                            -override_value_list argument array has an invalid\
                            value ([lindex $nuple 1]) in the 'monetary'\
                            field. The value should be 'normal' or 'minimize'. "
                }
                if {![regexp {(normal|high)} [lindex $nuple 2]]} {
                    keylset returnList status $::FAILURE
                    append error_log_list "The '$nuple' line from the\
                            -override_value_list argument array has an invalid\
                            value ([lindex $nuple 2]) in the 'reliability'\
                            field. The value should be 'normal' or 'high'. "
                }
                if {![regexp {(normal|high)} [lindex $nuple 3]]} {
                    keylset returnList status $::FAILURE
                    append error_log_list "The '$nuple' line from the\
                            -override_value_list argument array has an invalid\
                            value ([lindex $nuple 3]) in the 'throughput'\
                            field. The value should be 'normal' or 'high'. "
                }
                if {![regexp {(normal|low)} [lindex $nuple 4]]} {
                    keylset returnList status $::FAILURE
                    append error_log_list "The '$nuple' line from the\
                            -override_value_list argument array has an invalid\
                            value ([lindex $nuple 4]) in the 'delay'\
                            field. The value should be 'normal' or 'low'. "
                }
                set precedence "(routine|priority|immediate|flash|"
                append precedence "flash_override|critical_ecp|"
                append precedence "internetwork_contol|network_contol)"
                if {![regexp $precedence [lindex $nuple 5]]} {
                    keylset returnList status $::FAILURE
                    append error_log_list "The '$nuple' line from the\
                            -override_value_list argument array has an invalid\
                            value ([lindex $nuple 5]) in the 'precedence'\
                            field. The value should be 'routine', 'priority',\
                            'immediate', 'flash', 'flash_override',\
                            'critical_ecp', 'internetwork_contol' or\
                            'network_contol'. "
                }
                catch {lappend processed_override_value_list [expr \
                        [expr $translate_tos_precedence([lindex $nuple 5]) \
                        << 5] + \
                        [expr $translate_tos_delay([lindex $nuple 4]) \
                        << 4] + \
                        [expr $translate_tos_throughput([lindex $nuple 3]) \
                        << 3] + \
                        [expr $translate_tos_reliability([lindex $nuple 2]) \
                        << 2] + \
                        [expr $translate_tos_monetary([lindex $nuple 1]) \
                        << 1] + [lindex $nuple 0]]}
            }
        }
        "inner_vlan" {
            if {[llength $override_value_list] == 3 && \
                    [llength [lindex $override_value_list 0]] == 1} {
                set override_value_list [list $override_value_list]
            }
            foreach nuple $override_value_list {
                if {[lindex $nuple 0] < 0 || [lindex $nuple 0] > 4095} {
                    keylset returnList status $::FAILURE
                    append error_log_list "The '$nuple' line from the\
                            -override_value_list argument array has an invalid\
                            value ([lindex $nuple 0]) in the 'vlan id' field.\
                            The value should be an interger in the 0:4095\
                            range. "
                }
                if {[lindex $nuple 1] < 0 || [lindex $nuple 1] > 1} {
                    keylset returnList status $::FAILURE
                    append error_log_list "The '$nuple' line from the\
                            -override_value_list argument array has an invalid\
                            value ([lindex $nuple 1]) in the 'canonical format\
                            indicator' field. The value should be an interger\
                            in the 0:1 range. "
                }
                if {[lindex $nuple 2] < 1 || [lindex $nuple 2] > 7} {
                    keylset returnList status $::FAILURE
                    append error_log_list "The '$nuple' line from the\
                            -override_value_list argument array has an invalid\
                            value ([lindex $nuple 2]) in the 'user prority'\
                            field. The value should be an interger in the 1:7\
                            range. "
                }
                catch {lappend processed_override_value_list [expr [expr \
                        [lindex $nuple 2] << 13] + [expr [lindex $nuple 1] << \
                        12] + [lindex $nuple 0]]}
            }
        }
        "raw_priority" -
        "custom_8bit" -
        "custom_16bit" -
        "custom_24bit" -
        "custom_32bit" {
            if {[llength $override_value_list] == 1} {
                set override_value_list [list $override_value_list]
            }
            foreach nuple $override_value_list {
                if {($track_by == "raw_priority" || $track_by == "custom_8bit")\
                        && ($nuple < 0 || $nuple > 0xFF)} {
                    keylset returnList status $::FAILURE
                    append error_log_list "The '$nuple' line from the\
                            -override_value_list argument array has an invalid\
                            value ($nuple). The value should be an interger in\
                            the 0:255 range. "
                }
                if {$track_by == "custom_16bit" \
                        && ($nuple < 0 || $nuple > 0xFFFF)} {
                    keylset returnList status $::FAILURE
                    append error_log_list "The '$nuple' line from the\
                            -override_value_list argument array has an invalid\
                            value ($nuple). The value should be an interger in\
                            the 0:65535 range. "
                }
                if {$track_by == "custom_24bit" \
                        && ($nuple < 0 || $nuple > 0xFFFFFFF)} {
                    keylset returnList status $::FAILURE
                    append error_log_list "The '$nuple' line from the\
                            -override_value_list argument array has an invalid\
                            value ($nuple). The value should be an interger in\
                            the 0:16777215 range. "
                }
                if {$track_by == "custom_32bit" \
                        && ($nuple < 0 || $nuple > 0xFFFFFFFFF)} {
                    keylset returnList status $::FAILURE
                    append error_log_list "The '$nuple' line from the\
                            -override_value_list argument array has an invalid\
                            value ($nuple). The value should be an interger in\
                            the 0:4294967295 range. "
                }
                catch {lappend processed_override_value_list $nuple}
            }
        }
    }
    
    if {$error_log_list != ""} {
        keylset returnList log "$error_log_list"
    } else {
        keylset returnList override_value_list $processed_override_value_list
    }
    return $returnList
}

proc ::ixia::ixNetworkNodeTreeSearch { search_key parentObjRef child_list } {
    # Take care of the children types on this level
    foreach {thisStep nextStep} $child_list {
        if {[lindex $thisStep 0] == "child"} {
            set childObjRefList [ixNet getList $parentObjRef \
                    [lindex $thisStep 2]]
        } elseif {[lindex $thisStep 0] == "attr"} {
            if {[lindex $thisStep 1] == "step"} {
                set childObjRefList [ixNet getAttribute $parentObjRef \
                        -[lindex $thisStep 2]]
            }
        } else {
            ixPuts "Unknown child type '[lindex $thisStep 0]'. Use\
                    'child' or 'attr'."
            return -1
        }
        # Take care of the children of the selected type
        if {[lindex $thisStep 1] == "get"} {
            if {[ixNet getAttribute $parentObjRef -[lindex $thisStep 2]] == \
                    $search_key} {
                return 1
            }
        } elseif {[lindex $thisStep 1] != "step"} {
            ixPuts "Unknown action '[lindex $thisStep 1]'. Use\
                    'get' or 'step'."
            return -1
        }
        if {[info exists childObjRefList]} {
            foreach childObjRef $childObjRefList {
                if {[llength $nextStep] > 0} {
                    if {[ixNetworkNodeTreeSearch $search_key $childObjRef \
                            $nextStep] == 1} {
                        return 1
                    }
                }
            }
            return 0
        }
    }
}

proc ::ixia::ixNetworkNodeGetChildren {parent child_list returnList} {
    set child [lindex $child_list 0]
    set parent_list [ixNet getList $parent $child]
    if {$child == [lindex $child_list end]} {
        append returnList " $parent_list"
        return $returnList
    } else {
        foreach parent_elem $parent_list {
            append returnList " [ixNetworkNodeGetChildren $parent_elem [lrange $child_list 1 end] {}]"
        }
        return $returnList
    }
}

proc ::ixia::ixNetworkTrafficRollback { rollback_list } {
    variable ixnetwork_stream_ids

    foreach name $rollback_list {
        ixNet remove $ixnetwork_stream_ids($name)
        debug "ixNet remove $ixnetwork_stream_ids($name)"
        unset ixnetwork_stream_ids($name)
    }
    debug "ixNet commit"
    ixNet commit
}

proc ::ixia::ixNetworkGetBrowserStats {
    {statViewBrowser "trafficStatViewBrowser"} 
    {statViewName    "Traffic Statistics"}
    {statViewRoot    "statistics"}   
    } {
  
    array set rowsArray    ""
    
    if {$statViewRoot == "statistics"} {
        set statViewRoot [ixNet getRoot]/$statViewRoot
    }
    
    set statViewList [ixNet getList $statViewRoot $statViewBrowser]
    set statViewObjRef ""
    foreach statView $statViewList {
        if {[ixNet getAttribute $statView -name] == $statViewName} {
            if {[ixNet getAttribute $statView -enabled] == "false"} {
                debug "ixNet setAttribute $statView -enabled true"
                ixNet setAttribute $statView -enabled true
                debug "ixNet commit"
                ixNet commit
            }
            set statViewObjRef $statView
            break
        }
    }
   
    if {$statViewObjRef == ""} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to get stat view '$statViewName'."
        return $returnList
    }

    set pageNumber 1
    set totalPages  [ixNet getAttribute $statViewObjRef -totalPages]
    set currentPage [ixNet getAttribute $statViewObjRef -currentPageNumber]
    set localTotalPages $totalPages

    if {$totalPages > 0 && $currentPage != $pageNumber} {
        debug "ixNet setAttribute $statViewObjRef -currentPageNumber $pageNumber"
        ixNet setAttribute $statViewObjRef -currentPageNumber $pageNumber
        debug "ixNet commit"
        ixNet commit
        after 1000
    }

    set continueFlag "true"
    set initTime [clock seconds]

    set timeoutCount    [expr 300 + ($totalPages - 1) * 100]; # Try for at least 300 seconds.
    set currentRow      1
    set maxColumn       0
    set timeoutNotExpired "expr (\[expr \[clock seconds\] - \$initTime\] < \$timeoutCount)"
    while {$continueFlag == "true" && [eval $timeoutNotExpired]} {
        if {[ixNet getAttribute $statViewObjRef -isReady] == true} {
            while {[set rowList [ixNet getList $statViewObjRef row]] == ""} {
                if {![eval $timeoutNotExpired]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The stat view is ready, but there\
                            are no statistics available."
                    return $returnList
                }
            }
            foreach row $rowList {
                catch {ixNet getAttribute $row -name} row_name
                while {[set cellList [ixNet getList $row cell]] == ""} {
                    if {![eval $timeoutNotExpired]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "The stat view is ready, but there\
                                are no statistics available."
                        return $returnList
                    }
                }
                set currentColumn 1
                foreach cell $cellList {
                    set outcome ERROR
                    while {$outcome == "ERROR" && [eval $timeoutNotExpired]} {
                        catch {ixNet getAttribute $cell -columnName} stat_name
                        set matched [regexp -- {^::ixNet::(OK|ERROR|OBJ|LIST)-} \
                                $stat_name {} outcome]
                        if {($matched || $stat_name == "") && $outcome == "ERROR"} {
                            #after 100
                        } else {
                            set outcome ""
                        }                                    
                    }
                    set outcome ERROR
                    set statValueRetries 5
                    while {$outcome == "ERROR" && [eval $timeoutNotExpired] && $statValueRetries} {
                        catch {ixNet getAttribute $cell -statValue} stat_value
                        if {$stat_value == 0} {
                            catch {ixNet getAttribute $cell -statValue} stat_value
                        }
                        
                        set matched [regexp -- {^::ixNet::(OK|ERROR|OBJ|LIST)-} \
                                $stat_value {} outcome]
                        if {($matched || $stat_value == "") && $outcome == "ERROR"} {
                            #after 100
                            incr statValueRetries -1
                        } else {
                            set outcome ""
                        }
                    }
                    set rowsArray($pageNumber,$currentRow,$stat_name) $stat_value
                    incr currentColumn
                }
                set rowsArray($pageNumber,$currentRow) $row_name
                incr currentRow
            }
            set currentPage [ixNet getAttribute $statViewObjRef \
                    -currentPageNumber]
            
            if {$totalPages > 0 && $currentPage < $localTotalPages} {
                incr totalPages -1
                incr pageNumber
                debug "ixNet setAttribute $statViewObjRef -currentPageNumber $pageNumber"
                ixNet setAttribute $statViewObjRef -currentPageNumber $pageNumber
                debug "ixNet commit"
                ixNet commit
                after 1000
            } else {
                set continueFlag false
            }
            
        } else {
            after 1000
        }
    }
    
    if {$continueFlag == true} {
        keylset returnList status $::FAILURE
        keylset returnList log "Traffic stat view is not ready."
    } else {
        keylset returnList status $::SUCCESS
    }

    keylset returnList rows [array get rowsArray]
    keylset returnList page [expr $pageNumber + 1]
    keylset returnList row $currentRow
    return $returnList
}


proc ::ixia::ixNetworkGetBrowserStatRows {
    {statViewBrowser "trafficStatViewBrowser"} 
    {statViewName    "Traffic Statistics"}
    {statViewRoot    "statistics"}   
    } {
    
    if {$statViewRoot == "statistics"} {
        set statViewRoot [ixNet getRoot]/$statViewRoot
    }
    
    set statViewList [ixNet getList $statViewRoot $statViewBrowser]
    set statViewObjRef ""
    foreach statView $statViewList {
        if {[ixNet getAttribute $statView -name] == $statViewName} {
            if {[ixNet getAttribute $statView -enabled] == "false"} {
                debug "ixNet setAttribute $statView -enabled true"
                ixNet setAttribute $statView -enabled true
                debug "ixNet commit"
                ixNet commit
            }
            set statViewObjRef $statView
            break
        }
    }
   
    if {$statViewObjRef == ""} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to get stat view '$statViewName'."
        return $returnList
    }

    set pageNumber 1
    set totalPages  [ixNet getAttribute $statViewObjRef -totalPages]
    set currentPage [ixNet getAttribute $statViewObjRef -currentPageNumber]
    set localTotalPages $totalPages

    if {$totalPages > 0 && $currentPage != $pageNumber} {
        debug "ixNet setAttribute $statViewObjRef -currentPageNumber $pageNumber"
        ixNet setAttribute $statViewObjRef -currentPageNumber $pageNumber
        debug "ixNet commit"
        ixNet commit
        after 1000
    }

    set continueFlag "true"
    set initTime [clock seconds]

    set timeoutCount    [expr 300 + ($totalPages - 1) * 100]; # Try for at least 300 seconds.
    set currentRow      1
    set maxColumn       0
    set timeoutNotExpired "expr (\[expr \[clock seconds\] - \$initTime\] < \$timeoutCount)"
    set rowNameList ""
    while {$continueFlag == "true" && [eval $timeoutNotExpired]} {
        if {[ixNet getAttribute $statViewObjRef -isReady] == true} {
            while {[set rowList [ixNet getList $statViewObjRef row]] == ""} {
                if {![eval $timeoutNotExpired]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The stat view is ready, but there\
                            are no statistics available."
                    return $returnList
                }
            }
            foreach row $rowList {
                catch {ixNet getAttribute $row -name} row_name
                lappend rowNameList $row_name
                incr currentRow
            }
            set currentPage [ixNet getAttribute $statViewObjRef \
                    -currentPageNumber]
            
            if {$totalPages > 0 && $currentPage < $localTotalPages} {
                incr totalPages -1
                incr pageNumber
                debug "ixNet setAttribute $statViewObjRef -currentPageNumber $pageNumber"
                ixNet setAttribute $statViewObjRef -currentPageNumber $pageNumber
                debug "ixNet commit"
                ixNet commit
                after 1000
            } else {
                set continueFlag false
            }
            
        } else {
            after 1000
        }
    }
    
    if {$continueFlag == true} {
        keylset returnList status $::FAILURE
        keylset returnList log "Traffic stat view is not ready."
    } else {
        keylset returnList status $::SUCCESS
    }

    keylset returnList names $rowNameList
    return $returnList
}

proc ::ixia::ixNetworkGetChassisId {chassis_ip} {
    set chassis_id ""
    variable ixnetwork_chassis_list
    
    foreach {ch_elem} $ixnetwork_chassis_list {
        set ch_index [lindex $ch_elem 0]
        set ch_ip    [lindex $ch_elem 1]
        if {$ch_ip == $chassis_ip} {
            return $ch_index
        }
    }
    return $chassis_id
}

proc ::ixia::ixNetworkParseRowName {rowName} {
    keylset returnList status $::SUCCESS
    set trafficItem      ""
    set trafficParamsStr ""
    regsub {(.+) \((.+)} $rowName {\1} trafficItem
    regsub {(.+) \((.+)} $rowName {\2} trafficParamsStr
    set trafficParams [split $trafficParamsStr "|"]
    keylset returnList  stream_name $trafficItem
    keylset returnList  pgid        [lindex $trafficParams 1]
    keylset returnList  rx_port     [lindex $trafficParams 2]
    keylset returnList  flow        [lindex $trafficParams 3]
    keylset returnList  tx_port     [lindex $trafficParams 4]
    return $returnList
}

proc ::ixia::ixNetworkConnectedIntfCfg { args } {
    
    set commit_needed 0
    
    set man_args {
        -port_handle                        REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
    }

    set opt_args {
        -atm_encapsulation                  CHOICES VccMuxIPV4Routed
                                            CHOICES VccMuxIPV6Routed
                                            CHOICES VccMuxBridgedEthernetFCS
                                            CHOICES VccMuxBridgedEthernetNoFCS
                                            CHOICES LLCRoutedCLIP
                                            CHOICES LLCBridgedEthernetFCS
                                            CHOICES LLCBridgedEthernetNoFCS
                                            CHOICES VccMuxMPLSRouted
                                            CHOICES VccMuxPPPoA
                                            CHOICES LLCNLPIDRouted
                                            CHOICES LLCPPPoA
        -atm_vci                            RANGE   0-65535
        -atm_vpi                            RANGE   0-255
        -check_gateway_exists               CHOICES 0 1
                                            DEFAULT 0
        -gateway_address                    IPV4
        -intf_mode                          CHOICES create modify
        -ipv4_address                       IPV4
        -ipv4_prefix_length                 RANGE   0-32
        -ipv6_address                       IPV6
        -ipv6_address_step                  IPV6
        -ipv6_prefix_length                 RANGE   0-128
        -ipv6_gateway                       IPV6
        -ipv6_gateway_step                  IPV6
        -mac_address
        -mtu                                NUMERIC
        -override_existence_check           CHOICES 0 1
        -override_tracking                  CHOICES 0 1
        -prot_intf_objref
        -target_link_layer_address          CHOICES 0 1
        -vlan_enabled                       CHOICES 0 1
        -vlan_id                            REGEXP ^[0-9]{1,4}(,[0-9]{1,4})*$
        -vlan_tpid                          REGEXP ^0x[0-9a-fA-F]+(,0x[0-9a-fA-F]+)*$
        -vlan_user_priority                 REGEXP ^[0-7](,[0-7])*$
        -check_opposite_ip_version          CHOICES 0 1
    }
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    # Process the VLAN configuration data
    if {[info exists vlan_enabled] && $vlan_enabled == 1} {
        if {[info exists vlan_id]} {
            set vlan_id_temp_list [split $vlan_id ,]
            set vlan_id_list [list]
            foreach vlan_id $vlan_id_temp_list {
                if {$vlan_id >= 0 && $vlan_id <= 4095} {
                    lappend vlan_id_list $vlan_id
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed on parsing the -vlan_id option. $vlan_id is not a valid VLAN ID."
                    return $returnList
                }
            }
            set vlan_id [join $vlan_id_list ,]
        }
    }
    
    if {[info exists vlan_user_priority] && [info exists vlan_enabled] && $vlan_enabled} {
        set vlan_user_priority_list [split $vlan_user_priority ,]
        if {[llength $vlan_user_priority_list] != [llength $vlan_id_list]} {
            keylset returnList status $::FAILURE
            keylset returnList log "The length of the -vlan_user_priority option must be the same as that of the -vlan_id option."
            return $returnList
        }
        set vlan_user_priority [join $vlan_user_priority_list ,]
    }
    if {[info exists vlan_tpid] && [info exists vlan_enabled] && $vlan_enabled} {
        set vlan_tpid_list [split $vlan_tpid ,]
        if {[llength $vlan_tpid_list] != [llength $vlan_id_list]} {
            keylset returnList status $::FAILURE
            keylset returnList log "The length of the -vlan_tpid option must be the same as that of the -vlan_id option."
            return $returnList
        }
        set vlan_tpid [join $vlan_tpid_list ,]
    }

    if {[info exists override_tracking] && $override_tracking == 1} {
        set override_existence_check 1
    }

    if {[info exists atm_encapsulation]} {
        array set translate_atm_encapsulation [list             \
                VccMuxIPV4Routed            vcMuxIpv4           \
                VccMuxIPV6Routed            vcMuxIpv6           \
                VccMuxBridgedEthernetFCS    vcMuxBridgeFcs      \
                VccMuxBridgedEthernetNoFCS  vcMuxBridgeNoFcs    \
                LLCRoutedCLIP               llcClip             \
                LLCBridgedEthernetFCS       llcBridgeFcs        \
                LLCBridgedEthernetNoFCS     llcBridgeNoFcs      \
                ]

        # Check the encapsulation because some encapsulations
        # aren't supported anymore.
        if {[catch {set translate_atm_encapsulation($atm_encapsulation)}]} {
            keylset returnList status $::FAILURE
            keylset returnList log "The '$atm_encapsulation' encapsulation isn't\
                    supported anymore. Please use 'VccMuxIPV4Routed',\
                    'VccMuxIPV6Routed', 'VccMuxBridgedEthernetFCS',\
                    'VccMuxBridgedEthernetNoFCS', 'LLCBridgedEthernetFCS' or\
                    'LLCBridgedEthernetNoFCS'."
            return $returnList
        }
    }

    if {[info exists ipv4_address] && ![info exists ipv6_address]} {
        set ip_version 4
    } elseif {![info exists ipv4_address] && [info exists ipv6_address]} {
        set ip_version 6
    } elseif {[info exists ipv4_address] && [info exists ipv6_address]} {
        set ip_version 4_6
    }
    if {[info exists mac_address] && [info exists prot_intf_objref] && \
            ([ixNetworkGetAttr $prot_intf_objref/ethernet -macAddress] == \
            [::ixia::ixNetworkFormatMac $mac_address]) && [info exists intf_mode] && \
            $intf_mode != "modify"} {
        unset mac_address
    } elseif {[info exists mac_address]} {
        set mac_address [::ixia::convertToIxiaMac $mac_address]
    }

    if {[info exists gateway_address] && [info exists check_gateway_exists] && $check_gateway_exists == 1} {
        # Check if the interface with ip addr equal to this current gateway
        # note: this will only work with ipv4 interfaces
        #    create_interface - create a new interface
        #    modify_interface - modify an existing interface

        # Prepare the interface existance check call
        set intf_existence "::ixia::dual_stack_interface_exists \
                -port_handle     $port_handle                   \
                "

        set intf_existence_args ""
        append intf_existence_args " -ip_version 4"
        append intf_existence_args " -ipv4_address $gateway_address"
        append intf_existence_args " -type connected"
        if {[info exists check_opposite_ip_version]} {
            append intf_existence_args " -check_opposite_ip_version $check_opposite_ip_version"
        }
        append intf_existence $intf_existence_args

        # Perform interface existence check
        set results [eval $intf_existence]
        set status  [keylget results status]
        # Analyze the results
        switch -- $status {
            -1 {
                # The call to interface exists failed, fail this too.
                keylset returnList status $::FAILURE
                keylset returnList log [keylget results log]
                return $returnList
            }
            0 {
                # The interface doesn't exist, this is a new connected interface
                # do nothing
            }
            1 {
                # The interface exists with the same ip configuration.
                # Found another connected interface through which this intf is routed
                # Create new unconnected interface
                
                set intf_connected_via [ixNetworkGetIntfObjref [keylget results description]]
                set mac_address [split [ixNetworkGetAttr $intf_connected_via/ethernet -macAddress ] :]
            }
            2 {
                # The interface exists but with the opposite version.
                # no support for ipv6
                # Just create the connected interface
            }
        }
    }
    
    if {[info exists ipv6_gateway] && [info exists check_gateway_exists] && $check_gateway_exists == 1} {
        # Check if the interface with ip addr equal to this current gateway
        # note: this will only work with ipv6 interfaces
        #    create_interface - create a new interface
        #    modify_interface - modify an existing interface

        # Prepare the interface existance check call
        set intf_existence "::ixia::dual_stack_interface_exists \
                -port_handle     $port_handle                   \
                "

        set intf_existence_args ""
        append intf_existence_args " -ip_version 6"
        append intf_existence_args " -ipv6_address $ipv6_gateway"
        append intf_existence_args " -type connected"
        if {[info exists check_opposite_ip_version]} {
            append intf_existence_args " -check_opposite_ip_version $check_opposite_ip_version"
        }
        append intf_existence $intf_existence_args

        # Perform interface existence check
        set results [eval $intf_existence]
        set status  [keylget results status]
        # Analyze the results
        switch -- $status {
            -1 {
                # The call to interface exists failed, fail this too.
                keylset returnList status $::FAILURE
                keylset returnList log [keylget results log]
                return $returnList
            }
            0 {
                # The interface doesn't exist, this is a new connected interface
                # do nothing
            }
            1 {
                # The interface exists with the same ip configuration.
                # Found another connected interface through which this intf is routed
                # Create new unconnected interface
                
                set intf_connected_via [ixNetworkGetIntfObjref [keylget results description]]
                set mac_address [split [ixNetworkGetAttr $intf_connected_via/ethernet -macAddress ] :]
            }
            2 {
                # The interface exists but with the opposite version.
                # no support for ipv4
                # Just create the connected interface
            }
        }
    }

    if {![info exists override_existence_check] || $override_existence_check == 0} {
        # Check if interface already exists and decide on the action to take:
        #    create_interface - create a new interface
        #    modify_interface - modify an existing interface

        # Prepare the interface existance check call
        set intf_existence "::ixia::dual_stack_interface_exists \
                -port_handle     $port_handle                   \
                "

        set intf_existence_args ""
        if {[info exists ip_version]} {
            append intf_existence_args " -ip_version $ip_version"
            if {[info exists ipv4_address]} {
                append intf_existence_args " -ipv4_address $ipv4_address"
            }
            if {[info exists ipv6_address]} {
                append intf_existence_args " -ipv6_address $ipv6_address"
            }
            if {[info exists gateway_address]} {
                if {[info exists intf_connected_via]} {
                    append intf_existence_args " -gateway_address $intf_connected_via"
                } else {
                    append intf_existence_args " -gateway_address $gateway_address"
                }
            }
            if {[info exists ipv6_gateway]} {
                if {[info exists intf_connected_via]} {
#                    append intf_existence_args " -gateway_address_v6 $intf_connected_via"
                } else {
                    append intf_existence_args " -gateway_address_v6 $ipv6_gateway"
                }
            }
        }
        if {[info exists mac_address] && ![info exists intf_connected_via]} {
            append intf_existence_args " -mac_address $mac_address"
        }
        if {[info exists intf_connected_via]} {
            append intf_existence_args " -type routed"
        }
        if {[info exists check_opposite_ip_version]} {
            append intf_existence_args " -check_opposite_ip_version $check_opposite_ip_version"
        }
        
        if {$intf_existence_args != ""} {
            append intf_existence $intf_existence_args

            # Perform interface existence check
            set results [eval $intf_existence]
            set status  [keylget results status]
            # Analyze the results
            switch -- $status {
                -1 {
                    # The call to interface exists failed, fail this too.
                    keylset returnList status $::FAILURE
                    keylset returnList log [keylget results log]
                    return $returnList
                }
                0 {
                    # The interface doesn't exist and we need to create it.
                    set intf_action   create_interface
                    set ip_action     create_ip
                    set commit_needed 1
                    if {[info exists ip_version]} {
                        set version $ip_version
                    }
                    if {![info exists mac_address]} {
                        set retCode [::ixia::get_next_mac_address]
                        if {[keylget retCode status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log [keylget results log]
                            return $returnList
                        }
                        set mac_address [keylget retCode mac_address]
                    }
                }
                1 {
                    # The interface exists with the same ip configuration.
                    set intf_action modify_interface
                    set ip_action modify_ip
                    
                    # we will modify the interface only if there is someting to modify, so we're not
                    #       setting commit_needed to 1 yet
                    
                    if {[info exists ip_version]} {
                        set version $ip_version
                    }
                    set mac_address [keylget results mac_address]
                }
                2 {
                    # The interface exists but with the opposite version.
                    set commit_needed   1
                    set intf_action     modify_interface
                    set ip_action       create_ip
                    set version         4_6
                    set mac_address     [keylget results mac_address]
                }
                3 {
                    # Found the mac address on another interface on this port.
                    # The new API allows to easily modify a protocol interface's IP.
                    if {[info exists intf_mode] && $intf_mode == "modify"} {
                        # break
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Another interface has the same MAC\
                                address. The Mac address is unique per port."
                        return $returnList
                    }
                }
            }
        } else {
            set commit_needed   1
            set intf_action     create_interface
            set ip_action       create_ip
            if {[info exists ip_version]} {
                set version $ip_version
            }
            if {![info exists mac_address]} {
                set retCode [::ixia::get_next_mac_address]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log [keylget results log]
                    return $returnList
                }
                set mac_address [keylget retCode mac_address]
            }
        }
    } else {
        set commit_needed   1
        set intf_action     create_interface
        set ip_action       create_ip
        if {[info exists ip_version]} {
            set version $ip_version
        }
        if {![info exists mac_address]} {
            set retCode [::ixia::get_next_mac_address]
            if {[keylget retCode status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log [keylget results log]
                return $returnList
            }
            set mac_address [keylget retCode mac_address]
        }
    }

    if {![info exists prot_intf_objref]} {
        # Take the action decided upon
        switch -- $intf_action {
            create_interface {
                ## Create new interface
                set mode add
                if {[info exists intf_connected_via]} {
                    set interface_description [::ixia::make_interface_description \
                            $port_handle $mac_address routed]
                } else {
                    set interface_description [::ixia::make_interface_description \
                            $port_handle $mac_address]
                }
                # Get vport
                set result [ixNetworkGetPortObjref $port_handle]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not find any vport which uses\
                            the $port_handle port - [keylget result log]."
                    return $returnList
                } else {
                    set port_objref [keylget result vport_objref]
                }
                # Add interface
                set result [ixNetworkNodeAdd $port_objref interface \
                        [list -enabled true \
                        -description $interface_description]]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not add an interface on the\
                            following vport: $port_objref -\
                            [keylget result log]."
                    return $returnList
                } else {
                    set intf_objref [keylget result node_objref]
                }
                set retCode [ixNetworkNodeSetAttr \
                        $port_objref/protocols/arp {-enabled true}]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to enable ARP on port\
                            $port_handle. [keylget retCode log]"
                    return $returnList
                }
                set retCode [ixNetworkNodeSetAttr \
                        $port_objref/protocols/ping {-enabled true}]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to enable PING on port\
                            $port_handle. [keylget retCode log]"
                    return $returnList
                }
                
                if {[info exists intf_connected_via]} {
                    set retCode [ixNetworkNodeSetAttr $intf_objref "-type routed"]
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to set interface type ro routed on\
                                $port_handle. [keylget retCode log]"
                        return $returnList
                    }
                    set retCode [ixNetworkNodeSetAttr \
                            $intf_objref/unconnected "-connectedVia $intf_connected_via"]
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to bind unconnected interface to a connected interface on port\
                                $port_handle. [keylget retCode log]"
                        return $returnList
                    }
                }
            }
            modify_interface {
                ## Get the object reference of the found interface
                set mode modify
                set interface_description [keylget results description]
                # Get interface
                set intf_objref [ixNetworkGetIntfObjref $interface_description]
                if {$intf_objref == [ixNet getNull]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failure finding the required\
                            interface."
                    return $returnList
                }
                if {![regexp -- "^::ixNet::OBJ-/vport:\\d+/interface:\\d+$" $intf_objref]} {
                    keylset returnList status $::SUCCESS
                    keylset returnList description $interface_description
                    keylset returnList interface_handle $intf_objref
                    return $returnList
                }
            }
        }
    } else {
        # Remove defaults
        removeDefaultOptionVars $opt_args $args

        # Get the interface object reference
        set intf_objref $prot_intf_objref

        if {![info exists override_tracking] || $override_tracking == 0} {
            # Verify whether this interface is tracked 
            
            if {[llength [rfget_interface_details_by_handle $intf_objref]] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "The $intf_objref interface object\
                        reference is not used by any interface configured by\
                        this instance of HLT."
                return $returnList
            }
        }

        # Get the interface description
        set interface_description [ixNetworkGetAttr $intf_objref -description]

        # Get the MAC address from the interface if the -mac_address
        # attribute is not specified
        if {![info exists mac_address]} {
            set mac_address [::ixia::convertToIxiaMac \
                    [ixNetworkGetAttr $intf_objref/ethernet -macAddress]]
        }
        # Get the current interface version
        #    version will be the ip_version that the interface currently has
        #    ip_version is the what we want it to have
        #    they will be used together to determine the new ip_version of the interface
        set v4 false
        set v6 false
        if {[llength [ixNetworkGetList $intf_objref ipv4]] != 0} {
            set v4 true
        }
        if {[llength [ixNetworkGetList $intf_objref ipv6]] != 0} {
            set v6 true
        }
        if {$v4 && $v6} {
            set version 4_6
        } elseif {$v4} {
            set version 4
        } else {
            set version 6
        }

        # Set the actions to be taken
        set ip_action create_ip
        set mode modify
    }

    # MTU configuration
    if {[info exists mtu] && [ixNetworkIsCommitNeeded $intf_objref [list -mtu $mtu]]} {
        set commit_needed 1
        set retCode [ixNetworkNodeSetAttr $intf_objref [list -mtu $mtu]]
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to set MTU on interface.\
                    [keylget retCode log]"
            return $returnList
        }
    }

    # ATM configuration
    set attributes_list [list]
    if {[info exists atm_encapsulation]} {
        lappend attributes_list -encapsulation \
            $translate_atm_encapsulation($atm_encapsulation)
    }
    if {[info exists atm_vci]} {
        lappend attributes_list -vci $atm_vci
    }
    if {[info exists atm_vpi]} {
        lappend attributes_list -vpi $atm_vpi
    }
    if {[llength $attributes_list] != 0 &&\
            [ixNetworkIsCommitNeeded $intf_objref/atm $attributes_list]} {
        
        set commit_needed 1
        
        set retCode [ixNetworkNodeSetAttr $intf_objref/atm $attributes_list]
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to set ATM parameters on interface.\
                    [keylget retCode log]"
            return $returnList
        }
    }

    # MAC address
    set ixnetwork_mac_address [ixNetworkFormatMac $mac_address]
    if {[ixNetworkIsCommitNeeded $intf_objref/ethernet [list -macAddress $ixnetwork_mac_address]]} {
        set commit_needed 1
        set retCode [ixNetworkNodeSetAttr $intf_objref/ethernet \
                [list -macAddress $ixnetwork_mac_address]]
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to set MAC address on interface.\
                    [keylget retCode log]"
            return $returnList
        }
    }
    
    # VLAN configuration
    set attributes_list [list]
    if {[info exists vlan_enabled] && $mode != "modify"} {
        
        if {$vlan_enabled == 0} {
            lappend attributes_list -vlanEnable false
        } else {
            lappend attributes_list -vlanEnable true
            if {[info exists vlan_id]} {
                lappend attributes_list -vlanId $vlan_id
            }
            if {[info exists vlan_tpid]} {
                lappend attributes_list -tpid         $vlan_tpid
            }
            if {[info exists vlan_user_priority]} {
                lappend attributes_list -vlanPriority $vlan_user_priority
            }
        }
    } else {
        if {$mode == "modify"} {
            if {[info exists vlan_enabled]} {
                lappend attributes_list -vlanEnable $vlan_enabled
            }
            if {[info exists vlan_id]} {
                lappend attributes_list -vlanId $vlan_id
            }
            if {[info exists vlan_tpid]} {
                lappend attributes_list -tpid         $vlan_tpid
            }
            if {[info exists vlan_user_priority]} {
                lappend attributes_list -vlanPriority $vlan_user_priority
            }
        }
    }
    
    if {[llength $attributes_list] != 0 &&\
            [ixNetworkIsCommitNeeded $intf_objref/vlan $attributes_list]} {

        set commit_needed 1
        
        set retCode [ixNetworkNodeSetAttr $intf_objref/vlan $attributes_list]
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to set VLAN parameters on interface.\
                    [keylget retCode log]"
            return $returnList
        }
    }
    
    # IP configuration
    if {[info exists ipv4_address]} {
        set attributes_list [list -ip $ipv4_address]
        if {[info exists ipv4_prefix_length]} {
            lappend attributes_list -maskWidth $ipv4_prefix_length
        }
        if {[info exists gateway_address]} {
            lappend attributes_list -gateway $gateway_address
        }
        if {$ip_action == "create_ip" && \
                [llength [ixNetworkGetList $intf_objref ipv4]] == 0} {
            set commit_needed 1
            set result [ixNetworkNodeAdd $intf_objref ipv4 $attributes_list]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not add an IPv4 address on the\
                        following interface: $intf_objref -\
                        [keylget result log]."
                return $returnList
            }
        } else {
            if {[ixNetworkIsCommitNeeded $intf_objref/ipv4 $attributes_list]} {
                
                set commit_needed 1
                
                set retCode [ixNetworkNodeSetAttr $intf_objref/ipv4 $attributes_list]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to set IPv4 parameters on interface.\
                            [keylget retCode log]"
                    return $returnList
                }
            }
        }
    } elseif {[info exists version] && ($version == "4" || $version == "4_6")} {
        set attributes_list [list]
        if {[info exists ipv4_prefix_length]} {
            lappend attributes_list -maskWidth $ipv4_prefix_length
        }
        if {[info exists gateway_address]} {
            lappend attributes_list -gateway $gateway_address
        }
        if {[ixNetworkIsCommitNeeded $intf_objref/ipv4 $attributes_list]} {
            
            set commit_needed 1
            
            set retCode [ixNetworkNodeSetAttr $intf_objref/ipv4 $attributes_list]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to set IPv4 parameters on interface.\
                        [keylget retCode log]"
                return $returnList
            }
        }
    }
    if {[info exists ipv6_address]} {
        set attributes_list [list -ip $ipv6_address]
        if {[info exists ipv6_prefix_length]} {
            lappend attributes_list -prefixLength $ipv6_prefix_length
        }
        if {[info exists ipv6_gateway]} {
            lappend attributes_list -gateway $ipv6_gateway
        }
        if {[info exists target_link_layer_address]} {
            lappend attributes_list -targetLinkLayerAddressOption $target_link_layer_address
        }
        
        if {$ip_action == "create_ip" && \
                [llength [ixNetworkGetList $intf_objref ipv6]] == 0} {
            
            set commit_needed 1
            
            set result [ixNetworkNodeAdd $intf_objref ipv6 $attributes_list]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not add an IPv6 address on the\
                        following interface: $intf_objref -\
                        [keylget result log]."
                return $returnList
            }
        } else {
            if {[ixNetworkIsCommitNeeded $intf_objref/ipv6:1 $attributes_list]} {
                
                set commit_needed 1
                
                set retCode [ixNetworkNodeSetAttr $intf_objref/ipv6:1 $attributes_list]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to set IPv6 parameters on interface.\
                            [keylget retCode log]"
                    return $returnList
                }
            }
        }
    } elseif {[info exists version] && ($version == "6" || $version == "4_6")} {
        set attributes_list [list]
        if {[info exists ipv6_prefix_length]} {
            lappend attributes_list -prefixLength $ipv6_prefix_length
        }
        if {[info exists ipv6_gateway]} {
            lappend attributes_list -gateway $ipv6_gateway
        }
        if {[ixNetworkIsCommitNeeded $intf_objref/ipv6:1 $attributes_list]} {
            set commit_needed 1
            set retCode [ixNetworkNodeSetAttr $intf_objref/ipv6:1 $attributes_list]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to set IPv6 parameters on interface.\
                        [keylget retCode log]"
                return $returnList
            }
        }
    }

    # Log the changes
    keylset returnList interface_handle $intf_objref

    if {(![info exists override_tracking] || $override_tracking == 0) &&\
            $commit_needed} {
        
        # commit_needed is set only if there were changes done on the interfaces
        #    no need to update internal arrays if nothing was changed
        
        set add_interface_args "
                -description \"$interface_description\" \
                -ixnetwork_objref $intf_objref          \
                -mac_address $mac_address               \
                -mode $mode                             \
                -port_handle $port_handle               \
                "
        # BUG647106 - modify with single stack ipversion overrides the dual stack ip version
        if {![info exists intf_action] || $intf_action != "modify_interface" || \
                    ![info exists ip_action] || $ip_action != "modify_ip"} {
            if {[info exists version]} {
                append add_interface_args " -ip_version $version"
            }
        }
        
        if {[info exists version] && $version == "4_6"} {
            if {[info exists ip_version] && $ip_version == "4"} {
                # Get IPv6 settings
                set ipv6_address \
                        [ixNetworkGetAttr $intf_objref/ipv6:1 -ip]
                set ipv6_prefix_length \
                        [ixNetworkGetAttr $intf_objref/ipv6:1 -prefixLength]
                set ipv6_gateway \
                        [ixNetworkGetAttr $intf_objref/ipv6:1 -gateway]
                append add_interface_args " -ipv6_address $ipv6_address"
                if {[info exists ipv6_prefix_length]} {
                    append add_interface_args " -ipv6_mask $ipv6_prefix_length"
                }
                append add_interface_args " -ipv6_gateway $ipv6_gateway"

            } elseif {[info exists ip_version] && $ip_version == "6"} {
                # Get IPv4 settings
                set ipv4_address \
                        [ixNet getAttribute $intf_objref/ipv4 -ip]
                set ipv4_prefix_length \
                        [ixNet getAttribute $intf_objref/ipv4 -maskWidth]
                set gateway_address [ixNet getAttribute $intf_objref/ipv4 -gateway]
                if {[info exists gateway_address]} {
                    append add_interface_args " -ipv4_gateway $gateway_address"
                }
                append add_interface_args " -ipv4_address $ipv4_address"
                if {[info exists ipv4_prefix_length]} {
                    append add_interface_args " -ipv4_mask $ipv4_prefix_length"
                }
            }
        }

        if {[info exists ip_version] && $ip_version == "4"} {
            append add_interface_args " -ipv4_address $ipv4_address"
            if {[info exists ipv4_prefix_length]} {
                append add_interface_args " -ipv4_mask $ipv4_prefix_length"
            }
            if {[info exists intf_connected_via]} {
                append add_interface_args " -ipv4_gateway $intf_connected_via"
            } elseif {[info exists gateway_address]} {
                append add_interface_args " -ipv4_gateway $gateway_address"
            }
        }

        if {[info exists ip_version] && $ip_version == "6"} {
            append add_interface_args " -ipv6_address $ipv6_address"
            if {[info exists ipv6_prefix_length]} {
                append add_interface_args " -ipv6_mask $ipv6_prefix_length"
            }
            if {[info exists intf_connected_via] && \
                    [string first {-ipv4_gateway} $add_interface_args] == -1} {
                        
                append add_interface_args " -ipv4_gateway $intf_connected_via"
            }
            if {[info exists ipv6_gateway]} {
                append add_interface_args " -ipv6_gateway $ipv6_gateway"
            }
        }

        if {[info exists ip_version] && $ip_version == "4_6"} {
            append add_interface_args " -ipv4_address $ipv4_address"
            if {[info exists ipv4_prefix_length]} {
                append add_interface_args " -ipv4_mask $ipv4_prefix_length"
            }
            if {[info exists intf_connected_via]} {
                append add_interface_args " -ipv4_gateway $intf_connected_via"
            } elseif {[info exists gateway_address]} {
                append add_interface_args " -ipv4_gateway $gateway_address"
            }
            append add_interface_args " -ipv6_address $ipv6_address"
            if {[info exists ipv6_prefix_length]} {
                append add_interface_args " -ipv6_mask $ipv6_prefix_length"
            }
            if {[info exists ipv6_gateway]} {
                append add_interface_args " -ipv6_gateway $ipv6_gateway"
            }
        }  
        
        if {[info exists intf_connected_via]} {
            append add_interface_args " -type routed"
        }
        
       
        set retCode [eval ::ixia::modify_protocol_interface_info \
                $add_interface_args ]

        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to set protocol interface information. \
                    [keylget retCode log]"
            return $returnList
        }
    }
    
    if {[info exists intf_connected_via]} {
        keylset returnList routing_interface $intf_connected_via
    }    
    keylset returnList commit_needed $commit_needed
    keylset returnList status        $::SUCCESS
    keylset returnList description   $interface_description
    return $returnList
}

proc ::ixia::ixNetworkUnconnectedIntfCfg { args } {
    
    set commit_needed 0
    
    set man_args {
        -port_handle                        REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
    }

    set opt_args {
        -connected_via
        -loopback_ipv4_address              IPV4
        -loopback_ipv4_prefix_length        RANGE   0-32
        -loopback_ipv6_address              IPV6
        -loopback_ipv6_prefix_length        RANGE   0-128
        -override_existence_check           CHOICES 0 1
        -override_tracking                  CHOICES 0 1
        -check_opposite_ip_version          CHOICES 0 1
        -prot_intf_objref
    }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    if {[info exists override_tracking] && $override_tracking == 1} {
        set override_existence_check 1
    }

    if {[info exists loopback_ipv4_address] && ![info exists loopback_ipv6_address]} {
        set ip_version 4
    } elseif {![info exists loopback_ipv4_address] && [info exists loopback_ipv6_address]} {
        set ip_version 6
    } elseif {[info exists loopback_ipv4_address] && [info exists loopback_ipv6_address]} {
        set ip_version 4_6
    }
    if {[info exists connected_via]} {
        set mac_address [::ixia::convertToIxiaMac [ixNetworkGetAttr \
                $connected_via/ethernet -macAddress]]
    }

    if {![info exists override_existence_check] || $override_existence_check == 0} {
        # Check if interface already exists and decide on the action to take:
        #    create_interface - create a new interface
        #    modify_interface - modify an existing interface

        # Prepare the interface existance check call
        set intf_existence "::ixia::dual_stack_interface_exists \
                -port_handle     $port_handle                   \
                -type            routed                         \
                "

        set intf_existence_args ""
        if {[info exists ip_version]} {
            append intf_existence_args " -ip_version $ip_version"
            if {[info exists loopback_ipv4_address]} {
                append intf_existence_args " -ipv4_address $loopback_ipv4_address"
            }
            if {[info exists loopback_ipv6_address]} {
                append intf_existence_args " -ipv6_address $loopback_ipv6_address"
            }
        }
        if {[info exists mac_address]} {
            append intf_existence_args " -mac_address $mac_address"
        }
        if {[info exists connected_via]} {
            append intf_existence_args " -gateway_address $connected_via"
        }
        if {[info exists check_opposite_ip_version]} {
            append intf_existence_args " -check_opposite_ip_version $check_opposite_ip_version"
        }
        if {$intf_existence_args != ""} {
            append intf_existence $intf_existence_args

            # Perform interface existence check
            set results [eval $intf_existence]
            set status  [keylget results status]
    
            # Analyze the results
            switch -- $status {
                -1 {
                    # The call to interface exists failed, fail this too.
                    keylset returnList status $::FAILURE
                    keylset returnList log [keylget results log]
                    return $returnList
                }
                0 {
                    # The interface doesn't exist and we need to create it.
                    set commit_needed   1
                    set intf_action     create_interface
                    set ip_action       create_ip
                    
                    if {[info exists ip_version]} {
                        set version $ip_version
                    }
                }
                1 {
                    # The interface exists with the same ip configuration.
                    set intf_action modify_interface
                    set ip_action   modify_ip
                    
                    if {[info exists ip_version]} {
                        set version $ip_version
                    }
                }
                2 {
                    # The interface exists but with the opposite version.
                    set commit_needed   1
                    set intf_action     modify_interface
                    set ip_action       create_ip
                    set version 4_6
                }
                3 {
                    # The interface doesn't exist and we need to create it.
                    set commit_needed   1
                    set intf_action     create_interface
                    set ip_action       create_ip
                    
                    if {[info exists ip_version]} {
                        set version $ip_version
                    }
                }
            }
        }
    } else {
        set commit_needed   1
        set intf_action     create_interface
        set ip_action       create_ip
        if {[info exists ip_version]} {
            set version $ip_version
        }
    }

    if {![info exists prot_intf_objref]} {
        # Take the action decided upon
        switch -- $intf_action {
            create_interface {
                ## Check for the existence of the connected_via argument
                if {![info exists connected_via]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The connected_via argument\
                            MUST be specified when adding a new interface."
                    return $returnList
                }
                ## Create new interface
                set mode add
                set interface_description [::ixia::make_interface_description \
                        $port_handle $mac_address routed]
                # Get vport
                set result [ixNetworkGetPortObjref $port_handle]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not find any vport which uses\
                            the $port_handle port - [keylget result log]."
                    return $returnList
                } else {
                    set port_objref [keylget result vport_objref]
                }
                # Add interface
                set result [ixNetworkNodeAdd $port_objref interface \
                        [list -enabled true \
                        -description $interface_description -type routed]]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not add an interface on the\
                            following vport: $port_objref -\
                            [keylget result log]."
                    return $returnList
                } else {
                    set intf_objref [keylget result node_objref]
                }
            }
            modify_interface {
                ## Get the object reference of the found interface
                set mode modify
                set interface_description [keylget results description]
                # Get interface
                set intf_objref [ixNetworkGetIntfObjref $interface_description]
                if {$intf_objref == [ixNet getNull]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failure finding the required\
                            interface."
                    return $returnList
                }
            }
        }
    } else {
        # Remove defaults
        removeDefaultOptionVars $opt_args $args

        # Get the interface object reference
        set intf_objref $prot_intf_objref

        if {![info exists override_tracking] || $override_tracking == 0} {
            # Verify whether this interface is tracked 
            
            if {[llength [rfget_interface_details_by_handle $intf_objref]] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "The $intf_objref interface object\
                        reference is not used by any interface configured by\
                        this instance of HLT."
                return $returnList
            }
        }

        # Get the interface description
        set interface_description [ixNetworkGetAttr $intf_objref -description]

        # Get the current interface version
        set v4 false
        set v6 false
        if {[llength [ixNetworkGetList $intf_objref ipv4]] != 0} {
            set v4 true
        }
        if {[llength [ixNetworkGetList $intf_objref ipv6]] != 0} {
            set v6 true
        }
        if {$v4 && $v6} {
            set version 4_6
        } elseif {$v4} {
            set version 4
        } else {
            set version 6
        }

        # Set the actions to be taken
        set ip_action create_ip
        set mode modify
    }

    # IP configuration
    if {[info exists loopback_ipv4_address]} {
        set attributes_list [list -ip $loopback_ipv4_address]
        if {[info exists loopback_ipv4_prefix_length]} {
            lappend attributes_list -maskWidth $loopback_ipv4_prefix_length
        }
        if {$ip_action == "create_ip" && \
                [llength [ixNetworkGetList $intf_objref ipv4]] == 0} {
            set result [ixNetworkNodeAdd $intf_objref ipv4 $attributes_list]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not add an IPv4 address on the\
                        following interface: $intf_objref -\
                        [keylget result log]."
                return $returnList
            }
        } else {
            set ipv4_obj [ixNetworkGetList $intf_objref ipv4]
            if {[ixNetworkIsCommitNeeded $ipv4_obj $attributes_list]} {
                set commit_needed 1
                set retCode [ixNetworkNodeSetAttr $ipv4_obj $attributes_list]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to set IPv4 parameters on interface.\
                            [keylget retCode log]"
                    return $returnList
                }
            }
        }
    } elseif {[info exists version] && ($version == "4" || $version == "4_6")} {
        set attributes_list [list]
        if {[info exists loopback_ipv4_prefix_length]} {
            lappend attributes_list -maskWidth $loopback_ipv4_prefix_length
        }
        set ipv4_obj [ixNetworkGetList $intf_objref ipv4]
        if {[ixNetworkIsCommitNeeded $ipv4_obj $attributes_list]} {
            set commit_needed 1
            set retCode [ixNetworkNodeSetAttr $ipv4_obj $attributes_list]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to set IPv4 parameters on interface.\
                        [keylget retCode log]"
                return $returnList
            }
        }
    }
    if {[info exists loopback_ipv6_address]} {
        set attributes_list [list -ip $loopback_ipv6_address]
        if {[info exists loopback_ipv6_prefix_length]} {
            lappend attributes_list -prefixLength $loopback_ipv6_prefix_length
        }
        if {$ip_action == "create_ip" && \
                [llength [ixNetworkGetList $intf_objref ipv6]] == 0} {
            set result [ixNetworkNodeAdd $intf_objref ipv6 $attributes_list]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not add an IPv6 address on the\
                        following interface: $intf_objref -\
                        [keylget result log]."
                return $returnList
            }
        } else {
            if {[ixNetworkIsCommitNeeded $intf_objref/ipv6:1 $attributes_list]} {
                set commit_needed 1
                set retCode [ixNetworkNodeSetAttr $intf_objref/ipv6:1 $attributes_list]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to set IPv6 parameters on interface.\
                            [keylget retCode log]"
                    return $returnList
                }
            }
        }
    } elseif {[info exists version] && ($version == "6" || $version == "4_6")} {
        set attributes_list [list]
        if {[info exists loopback_ipv4_prefix_length]} {
            lappend attributes_list -prefixLength $loopback_ipv6_prefix_length
        }
        if {[ixNetworkIsCommitNeeded $intf_objref/ipv6:1 $attributes_list]} {
            set commit_needed 1
            set retCode [ixNetworkNodeSetAttr $intf_objref/ipv6:1 $attributes_list]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to set IPv6 parameters on interface.\
                        [keylget retCode log]"
                return $returnList
            }
        }
    }

    # Associate the loopback to a connected interface
    if {[info exists connected_via]} {
        if {[ixNetworkIsCommitNeeded $intf_objref/unconnected \
                [list -connectedVia $connected_via]]} {

            set commit_needed 1
            set retCode [ixNetworkNodeSetAttr $intf_objref/unconnected \
                    [list -connectedVia $connected_via]]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to set connected via parameter on\
                        loopback interface.\
                        [keylget retCode log]"
                return $returnList
            }
        }
    }

    # Log the changes
    keylset returnList interface_handle $intf_objref

    if {(![info exists override_tracking] || $override_tracking == 0) &&\
            $commit_needed} {

        set add_interface_args "
                -description \"$interface_description\" \
                -ixnetwork_objref $intf_objref          \
                -mode $mode                             \
                -port_handle $port_handle               \
                -type routed                            \
                "

        if {[info exists mac_address]} {
            append add_interface_args " -mac_address $mac_address"
        }

        if {[info exists version]} {
            append add_interface_args " -ip_version $version"
        }

        if {[info exists connected_via]} {
            append add_interface_args " -ipv4_gateway $connected_via"
        }

        if {[info exists version] && $version == "4_6"} {
            if {[info exists ip_version] && $ip_version == "4"} {
                # Get IPv6 settings
                set loopback_ipv6_address \
                        [ixNetworkGetAttr $intf_objref/ipv6:1 -ip]
                set loopback_ipv6_prefix_length \
                        [ixNetworkGetAttr $intf_objref/ipv6:1 -prefixLength]
                append add_interface_args " -ipv6_address $loopback_ipv6_address"
                if {[info exists loopback_ipv6_prefix_length]} {
                    append add_interface_args " -ipv6_mask $loopback_ipv6_prefix_length"
                }
            } elseif {[info exists ip_version] && $ip_version == "6"} {
                # Get IPv4 settings
                set ipv4_obj [ixNetworkGetList $intf_objref ipv4]
                set loopback_ipv4_address \
                        [ixNetworkGetAttr $ipv4_obj -ip]
                set loopback_ipv4_prefix_length \
                        [ixNetworkGetAttr $ipv4_obj -maskWidth]
                append add_interface_args " -ipv4_address $loopback_ipv4_address"
                if {[info exists loopback_ipv4_prefix_length]} {
                    append add_interface_args " -ipv4_mask $loopback_ipv4_prefix_length"
                }
            }
        }

        if {[info exists ip_version] && $ip_version == "4"} {
            append add_interface_args " -ipv4_address $loopback_ipv4_address"
            if {[info exists loopback_ipv4_prefix_length]} {
                append add_interface_args " -ipv4_mask $loopback_ipv4_prefix_length"
            }
        }

        if {[info exists ip_version] && $ip_version == "6"} {
            append add_interface_args " -ipv6_address $loopback_ipv6_address"
            if {[info exists loopback_ipv6_prefix_length]} {
                append add_interface_args " -ipv6_mask $loopback_ipv6_prefix_length"
            }
        }

        if {[info exists ip_version] && $ip_version == "4_6"} {
            append add_interface_args " -ipv4_address $loopback_ipv4_address"
            if {[info exists loopback_ipv4_prefix_length]} {
                append add_interface_args " -ipv4_mask $loopback_ipv4_prefix_length"
            }
            append add_interface_args " -ipv6_address $loopback_ipv6_address"
            if {[info exists loopback_ipv6_prefix_length]} {
                append add_interface_args " -ipv6_mask $loopback_ipv6_prefix_length"
            }
        }

        set retCode [eval ::ixia::modify_protocol_interface_info \
                $add_interface_args ]

        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to set protocol interface information. \
                    [keylget retCode log]"
            return $returnList
        }
    }
    
    keylset returnList commit_needed $commit_needed
    keylset returnList status        $::SUCCESS
    keylset returnList description   $interface_description
    return $returnList
}

proc ::ixia::ixNetworkGreIntfCfg { args } {
    
    set commit_needed 0
    
    set man_args {
        -port_handle                        REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
    }

    set opt_args {
        -gre_checksum_enable                CHOICES 0 1
        -gre_dst_ip_address                 IP
        -gre_ipv4_address                   IPV4
        -gre_ipv4_prefix_length             RANGE   0-32
        -gre_ipv6_address                   IPV6
        -gre_ipv6_prefix_length             RANGE   0-128
        -gre_key_enable                     CHOICES 0 1
        -gre_key_in                         NUMERIC
        -gre_key_out                        NUMERIC
        -gre_seq_enable                     CHOICES 0 1
        -gre_src_objref                     
        -override_existence_check           CHOICES 0 1
        -override_tracking                  CHOICES 0 1
        -check_opposite_ip_version          CHOICES 0 1
        -prot_intf_objref
    }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    if {[info exists override_tracking] && $override_tracking == 1} {
        set override_existence_check 1
    }

    if {[info exists gre_src_objref]} {
        if {[ixNetworkGetAttr $gre_src_objref -type] == "default"} {
            set mac_address [::ixia::convertToIxiaMac [ixNetworkGetAttr \
                    $gre_src_objref/ethernet -macAddress]]
        } elseif {[ixNetworkGetAttr $gre_src_objref -type] == "routed"} {
            set mac_address [::ixia::convertToIxiaMac [ixNetworkGetAttr \
                    [ixNetworkGetAttr $gre_src_objref/unconnected \
                    -connectedVia]/ethernet -macAddress]]
        } else  {
            keylset returnList status $::FAILURE
            keylset returnList log "The value from the gre_src_objref attribute\
                    is invalid: '$gre_src_objref' is not a valid object\
                    reference of a connected or unconnected interface."
            return $returnList
        }
    }
    if {[info exists gre_ipv4_address] && ![info exists gre_ipv6_address]} {
        set ip_version 4
    } elseif {![info exists gre_ipv4_address] && [info exists gre_ipv6_address]} {
        set ip_version 6
    } elseif {[info exists gre_ipv4_address] && [info exists gre_ipv6_address]} {
        set ip_version 4_6
    }
    set intf_action   create_interface
    if {![info exists override_existence_check] || $override_existence_check == 0} {
        # Check if interface already exists and decide on the action to take:
        #    create_interface - create a new interface
        #    modify_interface - modify an existing interface

        # Prepare the interface existance check call
        set intf_existence "::ixia::dual_stack_interface_exists \
                -port_handle     $port_handle               \
                -type            gre                        \
                "

        set intf_existence_args ""
        if {[info exists ip_version]} {
            append intf_existence_args " -ip_version $ip_version"
            if {[info exists gre_ipv4_address]} {
                append intf_existence_args " -ipv4_address $gre_ipv4_address"
            }
            if {[info exists gre_ipv6_address]} {
                append intf_existence_args " -ipv6_address $gre_ipv6_address"
            }
        }
        if {[info exists gre_dst_ip_address]} {
            append intf_existence_args " -dst_ip_address $gre_dst_ip_address"
        }
        if {[info exists mac_address]} {
            append intf_existence_args " -mac_address $mac_address"
        }
        if {[info exists check_opposite_ip_version]} {
            append intf_existence_args " -check_opposite_ip_version $check_opposite_ip_version"
        }
        
        if {$intf_existence_args != ""} {
            append intf_existence $intf_existence_args

            # Perform interface existence check
            set results [eval $intf_existence]
            set status  [keylget results status]
            # Analyze the results
            switch -- $status {
                -1 {
                    # The call to interface exists failed, fail this too.
                    keylset returnList status $::FAILURE
                    keylset returnList log [keylget results log]
                    return $returnList
                }
                0 {
                    # The interface doesn't exist and we need to create it.
                    # Set default parameters' values
                    set default_values_list {
                        gre_ipv4_prefix_length          24
                        gre_ipv6_prefix_length          64
                        gre_checksum_enable             0
                        gre_seq_enable                  0
                        gre_key_enable                  0
                    }
                    foreach {var_name default_value} $default_values_list {
                        if {![info exists $var_name]} {
                            set $var_name $default_value
                        }
                    }
                    
                    set commit_needed   1
                    set intf_action     create_interface
                    set ip_action       create_ip
                    if {[info exists ip_version]} {
                        set version $ip_version
                    }
                }
                1 {
                    # The interface exists with the same ip configuration.
                    set intf_action modify_interface
                    set ip_action modify_ip
                    if {[info exists ip_version]} {
                        set version $ip_version
                    }
                }
                2 {
                    # The interface exists but with the opposite version.
                    set commit_needed   1
                    set intf_action     modify_interface
                    set ip_action       create_ip
                    set version         4_6
                }
                3 {
                    # The interface doesn't exist and we need to create it.
                    set commit_needed   1
                    set intf_action     create_interface
                    set ip_action       create_ip
                    if {[info exists ip_version]} {
                        set version $ip_version
                    }
                }
            }
        }
    } else {
        set commit_needed   1
        set intf_action     create_interface
        set ip_action       create_ip
        if {[info exists ip_version]} {
            set version $ip_version
        }
        
        # The interface doesn't exist and we need to create it.
        # Set default parameters' values
        set default_values_list {
            gre_ipv4_prefix_length          24
            gre_ipv6_prefix_length          64
            gre_checksum_enable             0
            gre_seq_enable                  0
            gre_key_enable                  0
        }
        foreach {var_name default_value} $default_values_list {
            if {![info exists $var_name]} {
                set $var_name $default_value
            }
        }
    }

    if {![info exists prot_intf_objref]} {
        
        # Take the action decided upon
        switch -- $intf_action {
            create_interface {
                ## Check for the existence of the gre_src_objref argument
                if {![info exists gre_src_objref]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The gre_src_objref argument\
                            MUST be specified when adding a new interface."
                    return $returnList
                }
                ## Check for the existence of the gre_dst_ip_address argument
                if {![info exists gre_dst_ip_address]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The gre_dst_ip_address argument\
                            MUST be specified when adding a new interface."
                    return $returnList
                }
                ## Create new interface
                set mode add
                set interface_description [::ixia::make_interface_description \
                        $port_handle $mac_address gre]
                # Get vport
                set result [ixNetworkGetPortObjref $port_handle]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not find any vport which uses\
                            the $port_handle port - [keylget result log]."
                    return $returnList
                } else {
                    set port_objref [keylget result vport_objref]
                }
                # Add interface
                set result [ixNetworkNodeAdd $port_objref interface \
                        [list -enabled true \
                        -description $interface_description -type gre]]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not add an interface on the\
                            following vport: $port_objref -\
                            [keylget result log]."
                    return $returnList
                }
                set intf_objref [keylget result node_objref]
            }
            modify_interface {
                ## Get the object reference of the found interface
                set mode modify
                set interface_description [keylget results description]
                # Get interface
                set intf_objref [ixNetworkGetIntfObjref $interface_description]
                if {$intf_objref == [ixNet getNull]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failure finding the required\
                            interface."
                    return $returnList
                }
            }
        }
    } else {
        # Remove defaults
        removeDefaultOptionVars $opt_args $args

        # Get the interface object reference
        set intf_objref $prot_intf_objref

        if {![info exists override_tracking] || $override_tracking == 0} {
            # Verify whether this interface is tracked 
            if {[llength [rfget_interface_details_by_handle $intf_objref]] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "The $intf_objref interface object\
                        reference is not used by any interface configured by\
                        this instance of HLT."
                return $returnList
            }
        }

        # Get the interface description
        set interface_description [ixNetworkGetAttr $intf_objref -description]

        # Get the current interface version
        set v4 false
        set v6 false
        if {[llength [ixNetworkGetList $intf_objref ipv4]] != 0} {
            set v4 true
        }
        if {[llength [ixNetworkGetList $intf_objref ipv6]] != 0} {
            set v6 true
        }
        if {$v4 && $v6} {
            set version 4_6
        } elseif {$v4} {
            set version 4
        } else {
            set version 6
        }

        # Set the actions to be taken
        set ip_action create_ip
        set mode modify
    }

    # IP configuration
    if {[info exists gre_ipv4_address]} {
        set attributes_list [list -ip $gre_ipv4_address]
        if {[info exists gre_ipv4_prefix_length]} {
            lappend attributes_list -maskWidth $gre_ipv4_prefix_length
        }
        if {$ip_action == "create_ip" && \
                [llength [ixNetworkGetList $intf_objref ipv4]] == 0} {
            set result [ixNetworkNodeAdd $intf_objref ipv4 $attributes_list]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not add an IPv4 address on the\
                        following interface: $intf_objref -\
                        [keylget result log]."
                return $returnList
            }
        } else {
            set ipv4_obj [ixNetworkGetList $intf_objref ipv4]
            if {[ixNetworkIsCommitNeeded $ipv4_obj $attributes_list]} {
                set commit_needed 1
                set retCode [ixNetworkNodeSetAttr $ipv4_obj $attributes_list]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to set IPv4 parameters on interface.\
                            [keylget retCode log]"
                    return $returnList
                }
            }
        }
    } elseif {[info exists version] && ($version == "4" || $version == "4_6")} {
        set attributes_list [list]
        if {[info exists gre_ipv4_prefix_length]} {
            lappend attributes_list -maskWidth $gre_ipv4_prefix_length
        }
        set ipv4_obj [ixNetworkGetList $intf_objref ipv4]
        if {[ixNetworkIsCommitNeeded $ipv4_obj $attributes_list]} {
            set commit_needed 1
            set retCode [ixNetworkNodeSetAttr $ipv4_obj $attributes_list]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to set IPv4 parameters on interface.\
                        [keylget retCode log]"
                return $returnList
            }
        }
    }
    if {[info exists gre_ipv6_address]} {
        set attributes_list [list -ip $gre_ipv6_address]
        if {[info exists gre_ipv6_prefix_length]} {
            lappend attributes_list -prefixLength $gre_ipv6_prefix_length
        }
        if {$ip_action == "create_ip" && \
                [llength [ixNetworkGetList $intf_objref ipv6]] == 0} {
            set result [ixNetworkNodeAdd $intf_objref ipv6 $attributes_list]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not add an IPv6 address on the\
                        following interface: $intf_objref -\
                        [keylget result log]."
                return $returnList
            }
        } else {
            if {[ixNetworkIsCommitNeeded $intf_objref/ipv6:1 $attributes_list]} {
                set commit_needed 1
                set retCode [ixNetworkNodeSetAttr $intf_objref/ipv6:1 $attributes_list]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to set IPv6 parameters on interface.\
                            [keylget retCode log]"
                    return $returnList
                }
            }
        }
    } elseif {[info exists version] && ($version == "6" || $version == "4_6")} {
        set attributes_list [list]
        if {[info exists gre_ipv6_prefix_length]} {
            lappend attributes_list -prefixLength $gre_ipv6_prefix_length
        }
        if {[ixNetworkIsCommitNeeded $intf_objref/ipv6:1 $attributes_list]} {
            set commit_needed
            set retCode [ixNetworkNodeSetAttr $intf_objref/ipv6:1 $attributes_list]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to set IPv6 parameters on interface.\
                        [keylget retCode log]"
                return $returnList
            }
        }
    }

    # Setting GRE parameters
    if {[info exists gre_dst_ip_address] && [info exists gre_src_objref]} {
        if {[::isIpAddressValid $gre_dst_ip_address]} {
            set ipv4_obj [ixNetworkGetList $gre_src_objref ipv4]
            set interface_handle $ipv4_obj
        } else {
            set ipv6_obj [ixNetworkGetList $gre_src_objref ipv6]
            set interface_handle $ipv6_obj
        }
    }

    # Start creating a list of GRE options
    set gre_intf_args ""

    # List of options for GRE interfaces
    set gre_intf_args_pool {
        source          interface_handle    \
        dest            gre_dst_ip_address  \
        inKey           gre_key_in          \
        outKey          gre_key_out         \
        useChecksum     gre_checksum_enable \
        useKey          gre_key_enable      \
        useSequence     gre_seq_enable      \
    }

    # Check GRE options existence and append parameters that exist
    foreach {ixn_opt hlt_opt} $gre_intf_args_pool {
        if {[info exists $hlt_opt]} {
            lappend gre_intf_args -$ixn_opt [set $hlt_opt]
        }
    }
    
    # Configure the GRE settings on the GRE interface
    if {$gre_intf_args != "" && [ixNetworkIsCommitNeeded $intf_objref/gre $gre_intf_args]} {
        set commit_needed 1
        set retCode [ixNetworkNodeSetAttr $intf_objref/gre $gre_intf_args]
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to set GRE interface information. \
                    [keylget retCode log]"
            return $returnList
        }
    }
    
    
    # Log the changes
    keylset returnList interface_handle $intf_objref

    if {(![info exists override_tracking] || $override_tracking == 0) &&\
            $commit_needed} {
                
        set add_interface_args "
                -description \"$interface_description\" \
                -ixnetwork_objref $intf_objref          \
                -mode $mode                             \
                -port_handle $port_handle               \
                -type gre                               \
                "

        if {[info exists mac_address]} {
            append add_interface_args " -mac_address $mac_address"
        }

        if {[info exists version]} {
            append add_interface_args " -ip_version $version"
        }

        if {[info exists gre_dst_ip_address]} {
            append add_interface_args " -ipv4_dst_address $gre_dst_ip_address"
        }

        if {[info exists version] && $version == "4_6"} {
            if {[info exists ip_version] && $ip_version == "4"} {
                # Get IPv6 settings
                set gre_ipv6_address \
                        [ixNetworkGetAttr $intf_objref/ipv6:1 -ip]
                set gre_ipv6_prefix_length \
                        [ixNetworkGetAttr $intf_objref/ipv6:1 -prefixLength]
                append add_interface_args " -ipv6_address $gre_ipv6_address"
                if {[info exists gre_ipv6_prefix_length]} {
                    append add_interface_args " -ipv6_mask $gre_ipv6_prefix_length"
                }
            } elseif {$ip_version == "6"} {
                # Get IPv4 settings
                set ipv4_obj [ixNetworkGetList $intf_objref ipv4]
                set gre_ipv4_address \
                        [ixNetworkGetAttr $ipv4_obj -ip]
                set gre_ipv4_prefix_length \
                        [ixNetworkGetAttr $ipv4_obj -maskWidth]
                append add_interface_args " -ipv4_address $gre_ipv4_address"
                if {[info exists gre_ipv4_prefix_length]} {
                    append add_interface_args " -ipv4_mask $gre_ipv4_prefix_length"
                }
            }
        }

        if {[info exists ip_version] && $ip_version == "4"} {
            append add_interface_args " -ipv4_address $gre_ipv4_address"
            if {[info exists gre_ipv4_prefix_length]} {
                append add_interface_args " -ipv4_mask $gre_ipv4_prefix_length"
            }
        }

        if {[info exists ip_version] && $ip_version == "6"} {
            append add_interface_args " -ipv6_address $gre_ipv6_address"
            if {[info exists gre_ipv6_prefix_length]} {
                append add_interface_args " -ipv6_mask $gre_ipv6_prefix_length"
            }
        }

        if {[info exists ip_version] && $ip_version == "4_6"} {
            append add_interface_args " -ipv4_address $gre_ipv4_address"
            if {[info exists gre_ipv4_prefix_length]} {
                append add_interface_args " -ipv4_mask $gre_ipv4_prefix_length"
            }
            append add_interface_args " -ipv6_address $gre_ipv6_address"
            if {[info exists gre_ipv6_prefix_length]} {
                append add_interface_args " -ipv6_mask $gre_ipv6_prefix_length"
            }
        }

        set retCode [eval ::ixia::modify_protocol_interface_info \
                $add_interface_args ]

        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to set protocol interface information. \
                    [keylget retCode log]"
            return $returnList
        }
    }
    
    keylset returnList commit_needed $commit_needed
    keylset returnList status        $::SUCCESS
    keylset returnList description   $interface_description
    return $returnList
}

proc ::ixia::ixNetworkGreIntfParamsCfg {} {
    uplevel {
        # Create the gre tunnels for each unconnected interface
        for {set gre_index 0} {$gre_index < $gre_count} {incr gre_index} {
            set ixnetwork_interface_options "       \
                    -port_handle    $port_handle    \
                    "
            set ixnetwork_gre_options {
                gre_ipv4_address            tmp_gre_ipv4_address
                gre_ipv4_prefix_length      gre_ipv4_prefix_length
                gre_ipv6_address            tmp_gre_ipv6_address
                gre_ipv6_prefix_length      gre_ipv6_prefix_length
                gre_dst_ip_address          tmp_gre_dst_ip_address
                gre_src_objref              gre_src_objref
                gre_checksum_enable         gre_checksum_enable
                gre_seq_enable              gre_seq_enable
                gre_key_enable              gre_key_enable
                gre_key_in                  gre_key_in
                gre_key_out                 gre_key_out
                override_existence_check    override_existence_check
                override_tracking           override_tracking
                check_opposite_ip_version   check_opposite_ip_version
            }
            foreach {hlt_opt var_name} $ixnetwork_gre_options {
                if {[info exists $var_name]} {
                    append ixnetwork_interface_options \
                            " -$hlt_opt [set $var_name]"
                }
            }
            # Create a new GRE interface 
            set new_interface [eval ixNetworkGreIntfCfg \
                    $ixnetwork_interface_options]
            if {[keylget new_interface status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log [keylget new_interface log]
                return $returnList
            }
            
            if {![catch {keylget new_interface commit_needed} ret_val] &&\
                    $ret_val == 1} {
                
                set commit_needed 1
            }
            
            # Add its handle to the output list
            lappend gre_objref_list \
                    [keylget new_interface interface_handle]
            
            # GRE increment values
            if {[info exists tmp_gre_ipv4_address] && \
                    [info exists gre_ipv4_address_step]} {
                set tmp_gre_ipv4_address \
                        [::ixia::incr_ipv4_addr \
                        $tmp_gre_ipv4_address   \
                        $gre_ipv4_address_step  ]
            }
            if {[info exists tmp_gre_ipv6_address] && \
                    [info exists gre_ipv6_address_step]} {
                set tmp_gre_ipv6_address \
                        [::ixia::incr_ipv6_addr \
                        $tmp_gre_ipv6_address   \
                        $gre_ipv6_address_step  ]
            }
            if {[info exists tmp_gre_dst_ip_address] && \
                    [info exists gre_dst_ip_address_step]} {
                set tmp_gre_dst_ip_address \
                        [::ixia::incr_ipv${gre_dst_ip_version}_addr \
                        $tmp_gre_dst_ip_address   \
                        $gre_dst_ip_address_step  ]
            }
            if {[info exists gre_key_in] && \
                    [info exists gre_key_in_step]} {
                set gre_key_in  [expr \
                        $gre_key_in + $gre_key_in_step  ]
            }
            if {[info exists gre_key_out] && \
                    [info exists gre_key_out_step]} {
                set gre_key_out  [expr \
                        $gre_key_out + $gre_key_out_step  ]
            }

            # Commit the unconnected interfaces configuration
            incr objectCount
            if { $objectCount >= $objectMaxCount && $commit_needed} {
                debug "ixNetworkCommit"
                ixNetworkCommit
                set objectCount 0
            }
        }
        keylset returnList commit_needed $commit_needed
        keylset returnList status        $::SUCCESS
        return $returnList
    }
}

proc ::ixia::ixNetworkProtocolIntfCfg { args } {
    variable objectMaxCount
    set objectCount   0
    set commit_needed 0
    
    set man_args {
        -port_handle                                REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
    }

    set opt_args {
        -atm_encapsulation                          CHOICES VccMuxIPV4Routed
                                                    CHOICES VccMuxIPV6Routed
                                                    CHOICES VccMuxBridgedEthernetFCS
                                                    CHOICES VccMuxBridgedEthernetNoFCS
                                                    CHOICES LLCRoutedCLIP
                                                    CHOICES LLCBridgedEthernetFCS
                                                    CHOICES LLCBridgedEthernetNoFCS
                                                    CHOICES VccMuxMPLSRouted
                                                    CHOICES VccMuxPPPoA
                                                    CHOICES LLCNLPIDRouted
                                                    CHOICES LLCPPPoA
        -atm_vci                                    RANGE   0-65535
        -atm_vci_step                               RANGE   0-65535
        -atm_vpi                                    RANGE   0-255
        -atm_vpi_step                               RANGE   0-255
        -count                                      NUMERIC
                                                    DEFAULT 1
        -check_gateway_exists                       CHOICES 0 1
                                                    DEFAULT 0
        -check_opposite_ip_version                  CHOICES 0 1
                                                    DEFAULT 1
        -gateway_address                            IPV4
        -gateway_address_step                       IPV4
        -gre_count                                  NUMERIC
                                                    DEFAULT 1
        -gre_ipv4_address                           IPV4
        -gre_ipv4_prefix_length                     NUMERIC
        -gre_ipv4_address_step                      IPV4
        -gre_ipv4_address_outside_connected_reset   CHOICES 0 1
                                                    DEFAULT 1
        -gre_ipv4_address_outside_connected_step    IPV4
        -gre_ipv4_address_outside_loopback_step     IPV4
        -gre_ipv6_address                           IPV6
        -gre_ipv6_prefix_length                     NUMERIC
        -gre_ipv6_address_step                      IPV6
        -gre_ipv6_address_outside_connected_reset   CHOICES 0 1
                                                    DEFAULT 1
        -gre_ipv6_address_outside_connected_step    IPV6
        -gre_ipv6_address_outside_loopback_step     IPV6
        -gre_dst_ip_address                         IP
        -gre_dst_ip_address_step                    IP
        -gre_dst_ip_address_reset                   CHOICES 0 1
                                                    DEFAULT 1
        -gre_dst_ip_address_outside_connected_step  IP
        -gre_dst_ip_address_outside_loopback_step   IP
        -gre_src_ip_address                         CHOICES connected routed
                                                    DEFAULT connected
        -gre_checksum_enable                        CHOICES 0 1
        -gre_seq_enable                             CHOICES 0 1
        -gre_key_enable                             CHOICES 0 1
        -gre_key_in                                 NUMERIC
        -gre_key_in_step                            NUMERIC
        -gre_key_out                                NUMERIC
        -gre_key_out_step                           NUMERIC
        -ipv4_address                               IPV4
        -ipv4_address_step                          IPV4
        -ipv4_prefix_length                         NUMERIC
        -ipv6_address                               IPV6
        -ipv6_prefix_length                         NUMERIC
        -ipv6_address_step                          IPV6
        -ipv6_gateway                               IPV6
        -ipv6_gateway_step                          IPV6
        -loopback_count                             NUMERIC
                                                    DEFAULT 1
        -loopback_ipv4_address                      IPV4
        -loopback_ipv4_address_outside_step         IPV4
        -loopback_ipv4_address_step                 IPV4
        -loopback_ipv4_prefix_length                RANGE 0-32
        -loopback_ipv6_address                      IPV6
        -loopback_ipv6_address_outside_step         IPV6
        -loopback_ipv6_address_step                 IPV6
        -loopback_ipv6_prefix_length                RANGE 0-128
        -mac_address
        -mac_address_step
        -mtu
        -override_existence_check                   CHOICES 0 1
        -override_tracking                          CHOICES 0 1
        -target_link_layer_address                  CHOICES 0 1
        -vlan_enabled                               CHOICES 0 1
        -vlan_id                                    REGEXP ^[0-9]{1,4}(,[0-9]{1,4})*$
        -vlan_id_mode                               REGEXP ^(fixed|increment)(,(fixed|increment))*$ 
        -vlan_id_step                               REGEXP ^[0-9]{1,4}(,[0-9]{1,4})*$
        -vlan_tpid                                  REGEXP ^0x[0-9a-fA-F]+(,0x[0-9a-fA-F]+)*$
        -vlan_user_priority                         REGEXP ^[0-7](,[0-7])*$
        -vlan_user_priority_step                    REGEXP ^[0-7](,[0-7])*$
    }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    ## Enable VLAN tags if vlan_id was provided
    # This is done for backwards compatibility, when vlan_enabled did not exist
    # and VLAN tags were enabled when vlan_id was present
    if {![info exists vlan_enabled] && [info exists vlan_id]} {
        set vlan_enabled 1
    }
    
    # Process the VLAN configuration data
    if {[info exists vlan_enabled] && $vlan_enabled == 1} {
        set default_vlan_values_list {
            vlan_id                 1
            vlan_id_mode            increment
            vlan_id_step            1
            vlan_tpid               0x8100
            vlan_user_priority      0
            vlan_user_priority_step 0
        }
        foreach {var_name default_value} $default_vlan_values_list {
            if {![info exists $var_name]} {
                set $var_name $default_value
            }
        }
        # expand the parameters that have a single value
        # check the VLAN ID value
        # check the VLAN ID mode value
        # check the VLAN ID step value
        # check the VLAN TPID value
        # check the VLAN user priority value
        # check the VLAN user priority step value
        set ret_code [protintf_svlan_csv_prepare                    \
                -vlan_id                 $vlan_id                   \
                -vlan_id_mode            $vlan_id_mode              \
                -vlan_id_step            $vlan_id_step              \
                -vlan_tpid               $vlan_tpid                 \
                -vlan_user_priority      $vlan_user_priority        \
                -vlan_user_priority_step $vlan_user_priority_step   ]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        foreach vlan_param {vlan_id vlan_id_mode vlan_id_step vlan_tpid vlan_user_priority vlan_user_priority_step} {
            # Function protintf_svlan_csv_prepare returned a key for each parameter
            # We must overwrite our vars with the values provided by the function
            if {[keylget ret_code $vlan_param pval]} {
                set $vlan_param $pval
            }
        }
        
        set vlan_id_list                    [split $vlan_id ,]
        set vlan_id_mode_list               [split $vlan_id_mode ,]
        set vlan_id_step_list               [split $vlan_id_step ,]
        set vlan_tpid_list                  [split $vlan_tpid ,]
        set vlan_user_priority_list         [split $vlan_user_priority ,]
        set vlan_user_priority_step_list    [split $vlan_user_priority_step ,]
    }

    # Used for the returned values
    set connected_intf_list     [list]
    set unconnected_intf_list   [list]
    set gre_intf_list           [list]

    # Used for the temporary object references
    set connected_objref_list   [list]
    set unconnected_objref_list [list]
    set gre_objref_list         [list]

    ## Connected interfaces
    # Prepare the MAC address
    if {[info exists mac_address]} {
        set mac_address [::ixia::ixNetworkFormatMac $mac_address]
    }
    if {[info exists mac_address_step]} {
        set mac_address_step [::ixia::ixNetworkFormatMac $mac_address_step]
    }

    if {$count > 0} {
        # Expand the IP6 addresses
        set ipv6_params_list {
            ipv6_address
            ipv6_address_step
            ipv6_gateway
            ipv6_gateway_step
        }
        foreach {ip_param} $ipv6_params_list {
            if {[info exists $ip_param]} {
                set $ip_param  [::ixia::expand_ipv6_addr [set $ip_param]]
            }
        }

        # Set default parameters' values
        set default_values_list {
            atm_vci_step            1
            atm_vpi_step            1
            gateway_address_step    0.0.1.0
            ipv4_address_step       0.0.1.0
            ipv6_address_step       0000:0000:0000:0001:0000:0000:0000:0000
            ipv6_gateway_step       0000:0000:0000:0001:0000:0000:0000:0000
        }
        foreach {var_name default_value} $default_values_list {
            if {![info exists $var_name]} {
                set $var_name $default_value
            }
        }

        for {set intf_index 0} {$intf_index < $count} {incr intf_index} {
            set ixnetwork_connected_options {
                atm_encapsulation           atm_encapsulation
                atm_vci                     atm_vci
                atm_vpi                     atm_vpi
                gateway_address             gateway_address
                ipv4_address                ipv4_address
                ipv4_prefix_length          ipv4_prefix_length
                ipv6_address                ipv6_address
                ipv6_prefix_length          ipv6_prefix_length
                ipv6_gateway                ipv6_gateway
                mac_address                 mac_address
                mtu                         mtu
                override_existence_check    override_existence_check
                override_tracking           override_tracking
                check_gateway_exists        check_gateway_exists
                check_opposite_ip_version   check_opposite_ip_version
                target_link_layer_address   target_link_layer_address
            }
            
            if {[info exists vlan_enabled]} {
                append ixnetwork_connected_options {   \
                    vlan_enabled            vlan_enabled
                }
                if {$vlan_enabled == 1} {
                    append ixnetwork_connected_options {   \
                        vlan_id                 vlan_id
                        vlan_tpid               vlan_tpid
                        vlan_user_priority      vlan_user_priority
                    }
                }
            }
            
            # Passed in only those options that exists
            set ixnetwork_interface_options "-port_handle $port_handle"
            foreach {hlt_opt var_name} $ixnetwork_connected_options {
                if {[info exists $var_name]} {
                    append ixnetwork_interface_options " -$hlt_opt [set $var_name]"
                }
            }

            # Create a new connected interface 
            debug "ixNetworkConnectedIntfCfg \
                    $ixnetwork_interface_options"
            set new_interface [eval ixNetworkConnectedIntfCfg \
                    $ixnetwork_interface_options]
            if {[keylget new_interface status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log [keylget new_interface log]
                return $returnList
            }
            
            if {![catch {keylget new_interface commit_needed} ret_val] &&\
                    $ret_val == 1} {
                
                set commit_needed 1
            }
            
            # Add its handle to the output list
            lappend connected_objref_list \
                    [keylget new_interface interface_handle]
            if {[lsearch [keylkeys new_interface] "routing_interface"] != -1} {
                set conn_routing_intf [keylget new_interface routing_interface]
            }

            # Increment interface parameters

            # ATM
            if {[info exists atm_vci]} {
                incr atm_vci $atm_vci_step
                set atm_vci [mpexpr $atm_vci % 65536]
            }
            if {[info exists atm_vpi]} {
                incr atm_vpi $atm_vpi_step
                set atm_vpi [mpexpr $atm_vpi % 256]
            }

            # MAC Address
            if {[info exists mac_address]} {
                if {[info exists mac_address_step]} {
                    set mac_address [::ixia::incr_mac_addr $mac_address \
                            $mac_address_step]
                } else {
                    set mac_address [::ixia::incr_mac_addr $mac_address \
                            00:00:00:00:00:01]
                }
            }

            # VLAN
            if {[info exists vlan_enabled] && $vlan_enabled} {
                protintf_svlan_csv_increment "vlan_id" "vlan_id_mode" "vlan_id_step" "vlan_user_priority" "vlan_user_priority_step"
            }

            # IP Address
            if {[info exists ipv4_address]} {
                set ipv4_address [::ixia::incr_ipv4_addr \
                        $ipv4_address $ipv4_address_step]
                
                if {[info exists gateway_address]} {
                    set gateway_address [::ixia::incr_ipv4_addr\
                            $gateway_address $gateway_address_step]
                }
            }
            if {[info exists ipv6_address]} {
                set ipv6_address [::ixia::incr_ipv6_addr \
                        $ipv6_address $ipv6_address_step]
            }
            
            if {[info exists ipv6_gateway]} {
                set ipv6_gateway [::ixia::incr_ipv6_addr \
                        $ipv6_gateway $ipv6_gateway_step]
            }
            
            # Commit the connected interfaces configuration
            incr objectCount
            if { $objectCount == $objectMaxCount && $commit_needed} {
                debug "ixNetworkCommit"
                ixNetworkCommit
                set objectCount 0
            }
        }

        # Commit the rest of the connected interfaces
        if {$objectCount > 0 && $commit_needed} {
            debug "ixNetworkCommit"
            ixNetworkCommit
            set objectCount 0
        }

        # Prepare the connected_intf_list - keyed list with the return value
        # The protocol interfaces list has to be updated before moving on to
        # adding the unconnected interfaces
        if {(![info exists override_tracking] || $override_tracking == 0) && $commit_needed} {
            set ret_code [rfremap_interface_handle "all"]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
        }

        set connected_intf_list [list]
        if {$commit_needed} {
            set connected_intf_list [ixNet remapIds $connected_objref_list]
        } else {
            set connected_intf_list $connected_objref_list
        }
        
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to create connected protocol interface.\
                When creating protocol interfaces, please provide a value\
                greater than 0 for -count parameter."
        return $returnList
    }
    
    ## Unconnected interfaces
    if {($loopback_count > 0) && \
            ([info exists loopback_ipv4_address] || \
            [info exists loopback_ipv6_address]) && \
            ($connected_objref_list != "")} {
        # Expand the IP6 addresses
        set ipv6_params_list {
            loopback_ipv6_address
            loopback_ipv6_address_step
            loopback_ipv6_address_outside_step
        }
        foreach {ip_param} $ipv6_params_list {
            if {[info exists $ip_param]} {
                set $ip_param  [::ixia::expand_ipv6_addr [set $ip_param]]
            }
        }

        # Set default parameters' values
        set default_values_list {
            loopback_ipv4_address_step      0.0.1.0
            loopback_ipv4_prefix_length     24
            loopback_ipv6_address_step      0000:0000:0000:0001:0000:0000:0000:0000
            loopback_ipv6_prefix_length     64
        }
        foreach {var_name default_value} $default_values_list {
            if {![info exists $var_name]} {
                set $var_name $default_value
            }
        }

        if {[info exists loopback_ipv4_address]} {
            set tmp_loopback_ipv4_address $loopback_ipv4_address
        }
        if {[info exists loopback_ipv6_address]} {
            set tmp_loopback_ipv6_address $loopback_ipv6_address
        }

        foreach intf_objref $connected_intf_list {
            # Create the unconnected interfaces for each connected interface
            for {set loop_index 0} {$loop_index < $loopback_count} {incr loop_index} {
                # Use temporary variables for the loopback IP addresses because 
                # the outer loopback address step must be applied to the correct 
                # IP address.
                set ixnetwork_unconnected_options {
                    loopback_ipv4_address           tmp_loopback_ipv4_address
                    loopback_ipv4_prefix_length     loopback_ipv4_prefix_length
                    loopback_ipv6_address           tmp_loopback_ipv6_address
                    loopback_ipv6_prefix_length     loopback_ipv6_prefix_length
                    override_existence_check        override_existence_check
                    override_tracking               override_tracking
                    check_opposite_ip_version       check_opposite_ip_version
                }

                # Passed in only those options that exists
                set ixnetwork_interface_options "-port_handle $port_handle\
                        -connected_via $intf_objref"
                foreach {hlt_opt var_name} $ixnetwork_unconnected_options {
                    if {[info exists $var_name]} {
                        append ixnetwork_interface_options \
                                " -$hlt_opt [set $var_name]"
                    }
                }

                # Create a new unconnected interface 
                set new_interface [eval ixNetworkUnconnectedIntfCfg \
                        $ixnetwork_interface_options]
                if {[keylget new_interface status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log [keylget new_interface log]
                    return $returnList
                }
                
                if {![catch {keylget new_interface commit_needed} ret_val] &&\
                        $ret_val == 1} {
                    
                    set commit_needed 1
                }
                
                # Add its handle to the output list
                lappend unconnected_objref_list \
                        [keylget new_interface interface_handle]

                # Loopback IP Address
                if {[info exists tmp_loopback_ipv4_address]} {
                    set tmp_loopback_ipv4_address \
                            [::ixia::incr_ipv4_addr \
                            $tmp_loopback_ipv4_address \
                            $loopback_ipv4_address_step]
                } 
                if {[info exists tmp_loopback_ipv6_address]} {
                    set tmp_loopback_ipv6_address \
                            [::ixia::incr_ipv6_addr \
                            $tmp_loopback_ipv6_address \
                            $loopback_ipv6_address_step]
                }

                # Commit the unconnected interfaces configuration
                incr objectCount
                if { $objectCount == $objectMaxCount && $commit_needed} {
                    debug "ixNetworkCommit"
                    ixNetworkCommit
                    set objectCount 0
                }
            }

            # Loopback IP Address
            if {[info exists loopback_ipv4_address]} {
                if {[info exists loopback_ipv4_address_outside_step]} {
                    set tmp_loopback_ipv4_address [::ixia::incr_ipv4_addr \
                            $loopback_ipv4_address \
                            $loopback_ipv4_address_outside_step]
                    set loopback_ipv4_address $tmp_loopback_ipv4_address
                }
            } 
            if {[info exists loopback_ipv6_address]} {
                if {[info exists loopback_ipv6_address_outside_step]} {
                    set tmp_loopback_ipv6_address [::ixia::incr_ipv6_addr \
                            $loopback_ipv6_address \
                            $loopback_ipv6_address_outside_step]
                    set loopback_ipv6_address $tmp_loopback_ipv6_address
                }
                
            }
        }

        # Commit the rest of the unconnected interfaces
        if {$objectCount > 0 && $commit_needed} {
            debug "ixNetworkCommit"
            ixNetworkCommit
            set objectCount 0
        }

        # The protocol interfaces list has to be updated before moving on
        # Prepare the keyed list with the return value
        if {(![info exists override_tracking] || $override_tracking == 0) &&\
                $commit_needed} {
                    
            set ret_code [rfremap_interface_handle "all"]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
        }

        set unconnected_intf_list [list]
        if {$commit_needed} {
            set unconnected_intf_list [ixNet remapIds $unconnected_objref_list]
        } else {
            set unconnected_intf_list $unconnected_objref_list
        }
    }

    # GRE interfaces
    if {($gre_count > 0) && \
            ([info exists gre_ipv4_address] || \
            [info exists gre_ipv6_address]) && \
            [info exists gre_dst_ip_address]} {
        if {[::isIpAddressValid $gre_dst_ip_address]} {
            set gre_dst_ip_version 4
            if {![info exists gre_dst_ip_address_step]} {
                set gre_dst_ip_address_step 0.0.1.0
            }
        } else {
            set gre_dst_ip_version 6
            set gre_dst_ip_address [::ixia::expand_ipv6_addr \
                    $gre_dst_ip_address]
            if {![info exists gre_dst_ip_address_step]} {
                set gre_dst_ip_address_step \
                        0000:0000:0000:0001:0000:0000:0000:0000
            } else {
                set gre_dst_ip_address_step [::ixia::expand_ipv6_addr \
                        $gre_dst_ip_address_step]
            }
            if {[info exists gre_dst_ip_address_outside_connected_step]} {
                if {[::ipv6::isValidAddress $gre_dst_ip_address_outside_connected_step]} {
                    set gre_dst_ip_address_outside_connected_step \
                            [::ixia::expand_ipv6_addr \
                            $gre_dst_ip_address_outside_connected_step]
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The\
                            -gre_dst_ip_address_outside_connected_step\
                            attribute does not have the same IP version as the\
                            -gre_dst_ip_address_step attribute."
                    return $returnList
                }
            }
            if {[info exists gre_dst_ip_address_outside_loopback_step]} {
                if {[::ipv6::isValidAddress $gre_dst_ip_address_outside_loopback_step]} {
                    set gre_dst_ip_address_outside_loopback_step \
                            [::ixia::expand_ipv6_addr \
                            $gre_dst_ip_address_outside_loopback_step]
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The\
                            -gre_dst_ip_address_outside_loopback_step\
                            attribute does not have the same IP version as the\
                            -gre_dst_ip_address_step attribute."
                    return $returnList
                }
            }
        }

        # Expand the IP6 addresses
        set ipv6_expansion_list {
            gre_ipv6_address  
            gre_ipv6_address_step
            gre_ipv6_address_outside_connected_step
            gre_ipv6_address_outside_loopback_step
        }
        foreach ipv6_expansion_arg $ipv6_expansion_list {
            if {[info exists $ipv6_expansion_arg]} {
                set $ipv6_expansion_arg [::ixia::expand_ipv6_addr \
                        [set $ipv6_expansion_arg]]
            }
        }

        # Set default parameters' values
        set default_values_list {
            gre_ipv4_address_step           0.0.1.0
            gre_ipv6_address_step           0000:0000:0000:0001:0000:0000:0000:0000
            gre_key_in_step                 1
            gre_key_out_step                1
        }
        foreach {var_name default_value} $default_values_list {
            if {![info exists $var_name]} {
                set $var_name $default_value
            }
        }

        if {$gre_src_ip_address == "routed"} {
            if {![info exists loopback_ipv${gre_dst_ip_version}_address]} {
                keylset returnList status $::FAILURE
                keylset returnList log "The source of the GRE tunnel must be\
                        an IPv${gre_dst_ip_version} address. The\
                        -loopback_ipv${gre_dst_ip_version}_address parameter\
                        is not present."
                return $returnList
            }
            # If one of the outside steps is not provided, then unset both
            set outside_list {
                gre_ipv4_address
                gre_ipv6_address
                gre_dst_ip_address
            }
            foreach {elem_outside} $outside_list {
                set temp_outside ""
                append temp_outside \
                    [info exists ${elem_outside}_outside_loopback_step] \
                    [info exists ${elem_outside}_outside_connected_step]
                
                if {$temp_outside == "10" || $temp_outside == "01"  } {
                    catch {unset ${elem_outside}_outside_loopback_step}
                    catch {unset ${elem_outside}_outside_connected_step}
                }
            }
            # Set initial parameters
            if {[info exists gre_ipv4_address] } {
                set tmp_gre_ipv4_address     $gre_ipv4_address
                set loop_gre_ipv4_address    $gre_ipv4_address
            }
            if {[info exists gre_ipv6_address] } {
                set tmp_gre_ipv6_address     $gre_ipv6_address
                set loop_gre_ipv6_address    $gre_ipv6_address
            }
            set tmp_gre_dst_ip_address   $gre_dst_ip_address
            set loop_gre_dst_ip_address  $gre_dst_ip_address
            set conn_index 0
            for {set intf_index 0} {$intf_index < $count} {incr intf_index} {
                for {set loop_index 0} {$loop_index < $loopback_count} {incr loop_index} {
                    set gre_src_objref [lindex $unconnected_intf_list \
                            [expr $intf_index * $loopback_count + $loop_index]]
                    set retCode [ixNetworkGreIntfParamsCfg]
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log [keylget retCode log]
                        return $returnList
                    }
                    
                    if {![catch {keylget retCode commit_needed} ret_val] &&\
                            $ret_val == 1} {
                        
                        set commit_needed 1
                    }
                    
                    if {[info exists gre_ipv4_address]} {
                        if {[info exists gre_ipv4_address_outside_loopback_step]} {
                            set tmp_gre_ipv4_address [::ixia::incr_ipv4_addr \
                                    $loop_gre_ipv4_address \
                                    $gre_ipv4_address_outside_loopback_step]
                            set loop_gre_ipv4_address $tmp_gre_ipv4_address
                        }
                    } 
                    if {[info exists gre_ipv6_address]} {
                        if {[info exists gre_ipv6_address_outside_loopback_step]} {
                            set tmp_gre_ipv6_address [::ixia::incr_ipv6_addr \
                                    $loop_gre_ipv6_address \
                                    $gre_ipv6_address_outside_loopback_step]
                            set loop_gre_ipv6_address $tmp_gre_ipv6_address
                        }
                    }
                    if {[info exists gre_dst_ip_address_outside_loopback_step] &&\
                            $gre_dst_ip_address_reset} {
                        set tmp_gre_dst_ip_address [\
                                ::ixia::incr_ipv${gre_dst_ip_version}_addr \
                                $loop_gre_dst_ip_address \
                                $gre_dst_ip_address_outside_loopback_step]
                        set loop_gre_dst_ip_address $tmp_gre_dst_ip_address
                    }
                    if {[info exists gre_dst_ip_address_outside_loopback_step] &&\
                            !$gre_dst_ip_address_reset} {
                        set tmp_gre_dst_ip_address [\
                                ::ixia::incr_ipv${gre_dst_ip_version}_addr \
                                $tmp_gre_dst_ip_address \
                                $gre_dst_ip_address_outside_loopback_step]
                        set loop_gre_dst_ip_address $tmp_gre_dst_ip_address
                    }
                }
                if {[info exists gre_ipv4_address]} {
                    if {[info exists gre_ipv4_address_outside_connected_step] && \
                            $gre_ipv4_address_outside_connected_reset} {
                        set tmp_gre_ipv4_address [::ixia::incr_ipv4_addr \
                                $gre_ipv4_address \
                                $gre_ipv4_address_outside_connected_step]
                        set gre_ipv4_address  $tmp_gre_ipv4_address
                        set loop_gre_ipv4_address $tmp_gre_ipv4_address
                    }
                    if {[info exists gre_ipv4_address_outside_connected_step] && \
                            $gre_ipv4_address_outside_connected_reset == 0} {
                        set tmp_gre_ipv4_address [::ixia::incr_ipv4_addr \
                                $tmp_gre_ipv4_address\
                                $gre_ipv4_address_outside_connected_step]
                        set gre_ipv4_address  $tmp_gre_ipv4_address
                        set loop_gre_ipv4_address $tmp_gre_ipv4_address
                    }
                } 
                if {[info exists gre_ipv6_address] && \
                            $gre_ipv6_address_outside_connected_reset} {
                    if {[info exists gre_ipv6_address_outside_connected_step]} {
                        set tmp_gre_ipv6_address [::ixia::incr_ipv6_addr \
                                $gre_ipv6_address \
                                $gre_ipv6_address_outside_connected_step]
                        set gre_ipv6_address $tmp_gre_ipv6_address
                        set loop_gre_ipv6_address $tmp_gre_ipv6_address
                    }
                }
                if {[info exists gre_ipv6_address] && \
                            !$gre_ipv6_address_outside_connected_reset == 0} {
                    if {[info exists gre_ipv6_address_outside_connected_step]} {
                        set tmp_gre_ipv6_address [::ixia::incr_ipv6_addr \
                                $tmp_gre_ipv6_address \
                                $gre_ipv6_address_outside_connected_step]
                        set gre_ipv6_address $tmp_gre_ipv6_address
                        set loop_gre_ipv6_address $tmp_gre_ipv6_address
                    }
                }
                if {[info exists gre_dst_ip_address_outside_connected_step] &&\
                        $gre_dst_ip_address_reset} {
                    set tmp_gre_dst_ip_address [\
                            ::ixia::incr_ipv${gre_dst_ip_version}_addr \
                            $gre_dst_ip_address \
                            $gre_dst_ip_address_outside_connected_step]
                    set gre_dst_ip_address  $tmp_gre_dst_ip_address
                    set loop_gre_dst_ip_address $tmp_gre_dst_ip_address
                }
                if {[info exists gre_dst_ip_address_outside_connected_step] &&\
                        !$gre_dst_ip_address_reset} {
                    set tmp_gre_dst_ip_address [\
                            ::ixia::incr_ipv${gre_dst_ip_version}_addr \
                            $tmp_gre_dst_ip_address \
                            $gre_dst_ip_address_outside_connected_step]
                    set gre_dst_ip_address  $tmp_gre_dst_ip_address
                    set loop_gre_dst_ip_address $tmp_gre_dst_ip_address
                }
            }
        } else {
            if {![info exists ipv${gre_dst_ip_version}_address]} {
                keylset returnList status $::FAILURE
                keylset returnList log "The source of the GRE tunnel must be\
                        an IPv${gre_dst_ip_version} address. The\
                        -ipv${gre_dst_ip_version}_address parameter\
                        is not present."
                return $returnList
            }
            if {[info exists gre_ipv4_address] } {
                set tmp_gre_ipv4_address $gre_ipv4_address
            }
            if {[info exists gre_ipv6_address] } {
                set tmp_gre_ipv6_address  $gre_ipv6_address
            }
            set tmp_gre_dst_ip_address  $gre_dst_ip_address
            foreach gre_src_objref $connected_intf_list {
                set retCode [ixNetworkGreIntfParamsCfg]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log [keylget retCode log]
                    return $returnList
                }
                
                if {![catch {keylget retCode commit_needed} ret_val] &&\
                        $ret_val == 1} {
                    
                    set commit_needed 1
                }
                
                if {[info exists gre_ipv4_address]} {
                    if {[info exists gre_ipv4_address_outside_connected_step]} {
                        set tmp_gre_ipv4_address [::ixia::incr_ipv4_addr \
                                $gre_ipv4_address \
                                $gre_ipv4_address_outside_connected_step]
                        set gre_ipv4_address $tmp_gre_ipv4_address
                    }
                } 
                if {[info exists gre_ipv6_address]} {
                    if {[info exists gre_ipv6_address_outside_connected_step]} {
                        set tmp_gre_ipv6_address [::ixia::incr_ipv6_addr \
                                $gre_ipv6_address \
                                $gre_ipv6_address_outside_connected_step]
                        set gre_ipv6_address $tmp_gre_ipv6_address
                    }
                }
                if {[info exists gre_dst_ip_address_outside_connected_step]} {
                    set tmp_gre_dst_ip_address [\
                            ::ixia::incr_ipv${gre_dst_ip_version}_addr \
                            $gre_dst_ip_address \
                            $gre_dst_ip_address_outside_connected_step]
                    set gre_dst_ip_address $tmp_gre_dst_ip_address
                }
            }
        }

        # Commit the rest of the gre interfaces
        if {$objectCount > 0 && $commit_needed} {
            debug "ixNetworkCommit"
            ixNetworkCommit
        }
        
        # The protocol interfaces list has to be updated before moving on
        # Prepare the keyed list with the return value
        if {(![info exists override_tracking] || $override_tracking == 0) &&\
                $commit_needed} {
                    
            set ret_code [rfremap_interface_handle "all"]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
        }

        set gre_intf_list [list]
        if {$commit_needed} {
            set gre_intf_list [ixNet remapIds $gre_objref_list]
        } else {
            set gre_intf_list $gre_objref_list
        }
    }

    # an unconnected interface was created in the ixNetworkConnectedIntfCfg
    # because it had the flag check_gateway_exists, so return the unconn intf
    if {[info exists conn_routing_intf]} {
        keylset returnList routed_interfaces    $connected_intf_list
        keylset returnList connected_interfaces $conn_routing_intf
    } else {
        keylset returnList connected_interfaces $connected_intf_list
        keylset returnList routed_interfaces    $unconnected_intf_list
    }
    keylset returnList gre_interfaces       $gre_intf_list
    keylset returnList status $::SUCCESS
    return  $returnList
}

proc ::ixia::ixNetworkProtocolControl { args man_args opt_args} {
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args $man_args \
            -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    if {![info exists port_handle] && ![info exists handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "When -mode is $mode, parameter -port_handle or\
                parameter -handle must be provided."
        return $returnList
    }
    if {[info exists port_handle]} {
        set _handles $port_handle
        set protocol_objref_list ""
        foreach {_handle} $_handles {
            set retCode [ixNetworkGetPortObjref $_handle]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            set protocol_objref [keylget retCode vport_objref]
            lappend protocol_objref_list $protocol_objref/protocols/$protocol
        }
        if {$protocol_objref_list == "" } {
            keylset returnList status $::FAILURE
            keylset returnList log "All handles provided through -port_handle\
                    parameter are invalid."
            return $returnList
        }
    }
    if {[info exists handle]} {
        set _handles $handle
        set protocol_objref_list ""
        foreach {_handle} $_handles {
           if {[regexp "^\[0-9\]+/\[0-9\]+/\[0-9\]+$" $_handle]} {
                set retCode [ixNetworkGetPortObjref $_handle]
                if {[keylget retCode status] == $::FAILURE} {
                    return $retCode
                }
                set protocol_objref [keylget retCode vport_objref]
                lappend protocol_objref_list $protocol_objref/protocols/$protocol
            } else {
                set retCode [ixNetworkGetProtocolObjref $_handle $protocol]
                if {[keylget retCode status] == $::FAILURE} {
                    return $retCode
                }
                set protocol_objref [keylget retCode objref]
                if {$protocol_objref != [ixNet getRoot]} {
                    lappend protocol_objref_list $protocol_objref
                }
            }
        }
        if {$protocol_objref_list == "" } {
            keylset returnList status $::FAILURE
            keylset returnList log "All handles provided through -handle\
                    parameter are invalid."
            return $returnList
        }
    }
    set protocol_objref_list [lsort -unique $protocol_objref_list]
    # Check link state
    foreach protocol_objref $protocol_objref_list {
        regexp {(::ixNet::OBJ-/vport:[0-9]+).*} $protocol_objref {} vport_objref
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
            keylset returnList log "Failed to $mode [string toupper $protocol]\
                    on the $vport_objref port.\
                    Port state is $portState, $portStateD."
            return $returnList
        }
    }
    # Set what operations will be executed
    if {$mode == "restart"} {
        set operations [list stop start]
    } else {
        set operations $mode
    }
    
    # Check if it's protocols over SM-IP (PoSM)
    if {($operations == "start") && [info exists interfaces_relative_path_from_protocol]} {
        set ip_ranges_list ""
        foreach protocol_objref $protocol_objref_list {
            set ip_ranges_per_port_list ""
            regexp {(::ixNet::OBJ-/vport:\d).*} $protocol_objref {} vport_objref
            set interface_level_list [ixNetworkNodeGetChildren \
                    $protocol_objref                           \
                    [split $interfaces_relative_path_from_protocol "/"] \
                    {} ]
            foreach interface_level_objref $interface_level_list {
                if {[ixNet getAttribute $interface_level_objref -interfaceType] == "IP"} {
                    lappend ip_ranges_per_port_list [ixNetworkGetParentObjref [ixNet getAttribute $interface_level_objref -interfaces] ipEndpoint]
                }
            }
            lappend ip_ranges_list $ip_ranges_per_port_list
        }
    }
    
    # timeout in seconds waiting for start/stop
    set timeout 300
    foreach operation $operations {
        set po_index 0
        foreach protocol_objref $protocol_objref_list {
            keylset returnList status $::SUCCESS
            for {set retry_counter 0} {$retry_counter < 5} {incr retry_counter} {
                if {[info exists ip_ranges_list] && ([lindex $ip_ranges_list $po_index] != "") && \
                        ([catch {ixNetworkExec [list $operation [lindex $ip_ranges_list $po_index]]} retCode] || \
                        ([string first "::ixNet::OK" $retCode] == -1))} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to ${operation}\
                            [lindex $ip_ranges_list $po_index] on the\
                            $protocol_objref port. $retCode."
                   after 5000
                   continue
                }
                debug "ixNetworkExec [list $operation $protocol_objref]"
                if {[catch {ixNetworkExec [list $operation $protocol_objref]} retCode] || \
                        ([string first "::ixNet::OK" $retCode] == -1)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to ${operation}\
                            [string toupper $protocol] on the\
                            $protocol_objref port. $retCode."
                   after 5000
                   continue
                }
                
                break
            }
            
            if {[keylget returnList status] != $::SUCCESS} {
                return $returnList
            }
            incr po_index
        }
        set not_yet_started 1
        set start_time [clock seconds]
        while {[expr [clock seconds] - $start_time] < $timeout &&\
                $not_yet_started} {
            set not_yet_started 0
            foreach protocol_objref $protocol_objref_list {
                set current_state [ixNet getAttribute $protocol_objref\
                        -runningState]
                if {$current_state == "starting" ||\
                        $current_state == "stopping"} {
                    set not_yet_started 1
                    after 1000
                    break
                }
            }
        }
        if {$current_state == "unknown"} {
            keylset returnList status $::FAILURE
            keylset returnList log "State 'unknown' found on $protocol_objref."
            return $returnList
        }
        if {$not_yet_started} {
            keylset returnList status $::FAILURE
            keylset returnList log "Timeout $timeout occur waiting protocol to\
                    start."
            return $returnList
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixNetworkAtmStaticEndpointCfg { args } {
    set man_args {
        -port_objref
    }

    set opt_args {
        -vci                        RANGE 0-4294967295
        -vci_increment              RANGE 0-4294967295
        -vpi                        RANGE 0-4294967295
        -vpi_increment              RANGE 0-4294967295
        -pvc_count                  RANGE 0-4294967295
        -atm_header_encapsulation   CHOICES llc_bridged_eth_fcs
                                    CHOICES llc_bridged_eth_no_fcs
                                    CHOICES llc_ppp
                                    CHOICES llc_routed_snap
                                    CHOICES vcc_mux_bridged_eth_fcs
                                    CHOICES vcc_mux_bridged_eth_no_fcs
                                    CHOICES vcc_mux_ppp
                                    CHOICES vcc_mux_routed
                                    DEFAULT llc_routed_snap
        }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
                    $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    array set translate_atm_header_encapsulation [list                  \
            llc_bridged_eth_fcs         llcBridged802p3WithFcs          \
            llc_bridged_eth_no_fcs      llcBridged802p3WithOutFcs       \
            llc_ppp                     ppp                             \
            llc_routed_snap             llcRoutedSnap                   \
            vcc_mux_bridged_eth_fcs     vcMultiBridged802p3WithFcs      \
            vcc_mux_bridged_eth_no_fcs  vcMultiBridged802p3WithOutFcs   \
            vcc_mux_ppp                 vcMultiplexedPpp                \
            vcc_mux_routed              vcMultiRouted                   \
            ]

    # Start creating list ATM enpoint options
    set atm_endpoint_args [list -enabled true]

    # List of global options for ATM enpoints
    set atm_endpoint_options {
        vci                         vci                 default
        vci_increment               incrementVci        default
        vpi                         vpi                 default
        vpi_increment               incrementVpi        default
        pvc_count                   count               default
        atm_header_encapsulation    atmEncapsulation    translate
    }

    # Check ATM enpoint options existence and append parameters that exist
    foreach {hlt_opt ixn_opt opt_type} $atm_endpoint_options {
        if {[info exists $hlt_opt]} {
            switch $opt_type {
                translate {
                    lappend atm_endpoint_args -$ixn_opt \
                            [set translate_${hlt_opt}([set $hlt_opt])]
                }
                default {
                    lappend atm_endpoint_args -$ixn_opt \
                            [set $hlt_opt]
                }
            }
        }
    }

    # Apply configurations
    set result [ixNetworkNodeAdd $port_objref atm $atm_endpoint_args]
    if {[keylget result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failure in\
                ixNetworkAtmStaticEndpointCfg:\
                encountered an error while executing: \
                ixNetworkNodeAdd $port_objref atm $atm_endpoint_args\
                - [keylget result log]"
        return $returnList
    }

    keylset returnList status $::SUCCESS
    keylset returnList endpoint_handle [keylget result node_objref]
    return $returnList
}

proc ::ixia::ixNetworkFrameRelayStaticEndpointCfg { args } {
    set man_args {
        -port_objref
    }

    set opt_args {
        -dlci_value                 RANGE 0-4294967295
        -dlci_count_mode            CHOICES fixed increment
        -dlci_repeat_count          RANGE 0-4294967295
    }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
                    $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    array set increment [list   \
            fixed       false   \
            increment   true    \
            ]

    # Start creating list Frame Relay enpoint options
    set fr_endpoint_args [list -enabled true]

    # List of global options for Frame Relay enpoints
    set fr_endpoint_options {
        dlci_value                  dlci                default
        dlci_count_mode             enableIncrement     increment
        dlci_repeat_count           count               default
    }

    # Check Frame Relay enpoint options existence and append parameters that exist
    foreach {hlt_opt ixn_opt opt_type} $fr_endpoint_options {
        if {[info exists $hlt_opt]} {
            switch $opt_type {
                increment {
                    lappend fr_endpoint_args -$ixn_opt \
                            [set increment([set $hlt_opt])]
                }
                default {
                    lappend fr_endpoint_args -$ixn_opt \
                            [set $hlt_opt]
                }
            }
        }
    }

    # Apply configurations
    set result [ixNetworkNodeAdd $port_objref fr $fr_endpoint_args]
    if {[keylget result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failure in\
                ixNetworkFrameRelayStaticEndpointCfg:\
                encountered an error while executing: \
                ixNetworkNodeAdd $port_objref fr $fr_endpoint_args\
                - [keylget result log]"
        return $returnList
    }

    keylset returnList status $::SUCCESS
    keylset returnList endpoint_handle [keylget result node_objref]
    return $returnList
}

proc ::ixia::ixNetworkIpStaticEndpointCfg { args } {
    set man_args {
        -port_objref
    }

    set opt_args {
        -intf_handle
        -l3_protocol                CHOICES ipv4 ipv6
                                    DEFAULT ipv4
        -ip_dst_addr                IP
        -ip_dst_prefix_len          RANGE 0-128
        -ip_dst_increment           IP
        -ip_dst_count               RANGE 1-4294967295
    }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
                    $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    array set translate_l3_protocol [list   \
            ipv4        ipv4                \
            ipv6        ipv6                \
            ]

    # IP version check
    if {$l3_protocol == "ipv4"} {
        foreach ip_param {ip_dst_addr ip_dst_increment} {
            if {[info exists $ip_param] && \
                    ![::isIpAddressValid [set $ip_param]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "[set $ip_param] is not a\
                        valid IPv4 value for the -$ip_param\
                        attribute."
                return $returnList
            }
        }
        if {[info exists ip_dst_prefix_len] && $ip_dst_prefix_len > 32} {
            keylset returnList status $::FAILURE
            keylset returnList log "$ip_dst_prefix_len is not a\
                    valid value of the -ip_dst_prefix_len attribute\
                    for IPv4 enpoints."
            return $returnList
        }
    } else {
        foreach ip_param {ip_dst_addr ip_dst_increment} {
            if {[info exists $ip_param] && \
                    ![::ipv6::isValidAddress [set $ip_param]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "[set $ip_param] is not a\
                        valid IPv6 value for the -$ip_param\
                        attribute."
                return $returnList
            }
        }
    }
    
    ## The maximum value for the step is 4294967295 -> ::ffff:ffff
    if {[info exists ip_dst_increment] && [compare_ip_addresses $ip_dst_increment 0::ffff:ffff] > 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "The maximum value for -ip_dst_increment is\
                ::ffff:ffff. The parameter value provided is '$ip_dst_increment'."
        return $returnList
    }
    
    # Start creating list IP enpoint options
    set ip_endpoint_args [list -enabled true]

    # List of global options for IP enpoints
    set ip_endpoint_options {
        intf_handle                 protocolInterface   default
        l3_protocol                 ipType              translate
        ip_dst_addr                 ipStart             default
        ip_dst_prefix_len           mask                default
        ip_dst_increment            step                ip2num
        ip_dst_count                count               deafult
    }

    # Check IP enpoint options existence and append parameters that exist
    foreach {hlt_opt ixn_opt opt_type} $ip_endpoint_options {
        if {[info exists $hlt_opt]} {
            switch $opt_type {
                translate {
                    lappend ip_endpoint_args -$ixn_opt \
                            [set translate_${hlt_opt}([set $hlt_opt])]
                }
                ip2num {
                    lappend ip_endpoint_args -$ixn_opt \
                            [ip_addr_to_num [set $hlt_opt]]
                }
                default {
                    lappend ip_endpoint_args -$ixn_opt \
                            [set $hlt_opt]
                }
            }
        }
    }

    # Apply configurations
    set result [ixNetworkNodeAdd $port_objref ip $ip_endpoint_args]
    if {[keylget result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failure in\
                ixNetworkIpStaticEndpointCfg:\
                encountered an error while executing: \
                ixNetworkNodeAdd $port_objref ip $ip_endpoint_args\
                - [keylget result log]"
        return $returnList
    }

    keylset returnList status $::SUCCESS
    keylset returnList endpoint_handle [keylget result node_objref]
    return $returnList
}

proc ::ixia::ixNetworkLanStaticEndpointCfg { args } {

    set man_args {
        -port_objref
    }
    
    set vlan_user_priority_regexp      "^\[0-7\](,\[0-7\]){0,6}$"
    
    set opt_args {
        -intermediate_objref
        -mac_dst
        -mac_dst_mode               CHOICES fixed increment
                                    DEFAULT increment
        -mac_dst_count              RANGE 1-4294967295
        -vlan_id                    ANY
        -vlan_id_mode               CHOICES inner outer fixed increment
                                    DEFAULT increment
        -site_id_enable             CHOICES 0 1
                                    DEFAULT 0
        -site_id                    RANGE 0-4294967295
        -lan_count_per_vc           NUMERIC
        -lan_incr_per_vc_vlan_mode  CHOICES inner outer fixed increment
        -lan_mac_range_mode         CHOICES normal bundled
        -lan_number_of_vcs          NUMERIC
        -lan_skip_vlan_id_zero      CHOICES 0 1
        -lan_tpid                   ANY
        -lan_vlan_priority          ANY
        -lan_vlan_stack_count       NUMERIC
        -vlan_enable                CHOICES 0 1
    }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
                    $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    array set increment [list   \
            fixed       false   \
            increment   true    \
            ]
    
    array set translate_array [list               \
            inner       innerFirst          \
            outer       outerFirst          \
            increment   parallelIncrement   \
            fixed       noIncrement         \
            1           true                \
            0           false               \
        ]
    
    # Start creating list LAN enpoint options
    set lan_endpoint_args [list -enabled true]

    # List of global options for LAN enpoints
    set lan_endpoint_options {
        intermediate_objref         {atmEncapsulation frEncapsulation}    default
        mac_dst_mode                enableIncrementMac  increment
        mac_dst_count               count               default
        vlan_enable                 enableVlan          deafult
        vlan_id                     vlanId              qinq
        vlan_id_mode                incrementVlanMode   translate
        site_id_enable              enableSiteId        deafult
        site_id                     siteId              default
        lan_count_per_vc            countPerVc          default
        lan_incr_per_vc_vlan_mode   incrementPerVcVlanMode translate
        lan_mac_range_mode          macRangeMode        default
        lan_number_of_vcs           numberOfVcs         default
        lan_skip_vlan_id_zero       skipVlanIdZero      translate
        lan_tpid                    tpid                qinq
        lan_vlan_priority           vlanPriority        qinq
        lan_vlan_stack_count        vlanCount           default
    }

    # Check LAN enpoint options existence and append parameters that exist
    if {[info exists mac_dst]} {
        if {![isValidMacAddress $mac_dst]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Invalid mac address '$mac_dst' provided with\
                    -static_mac_dst parameter"
            return $returnList
        }
        
        lappend lan_endpoint_args -mac [ixNetworkFormatMac $mac_dst]
    }
    foreach {hlt_opt ixn_opt opt_type} $lan_endpoint_options {
        if {[info exists $hlt_opt]} {
            
            if {$hlt_opt == "intermediate_objref"} {
                if {[regexp {^::ixNet::OBJ-/vport:\d+/protocols/static/atm:\d+} [set $hlt_opt]]} {
                    set ixn_opt [lindex $ixn_opt 0]
                } else {
                    set ixn_opt [lindex $ixn_opt 1]
                }
            }
            
            switch $opt_type {
                increment {
                    lappend lan_endpoint_args -$ixn_opt \
                            [set increment([set $hlt_opt])]
                }
                translate {
                    lappend lan_endpoint_args -$ixn_opt \
                            [set translate_array([set $hlt_opt])]
                }
                qinq {
                    lappend lan_endpoint_args -$ixn_opt \
                            [regsub -all {:} [set $hlt_opt] {,}]
                }
                default {
                    lappend lan_endpoint_args -$ixn_opt \
                            [set $hlt_opt]
                }
            }
        }
    }

    # Apply configurations
    set result [ixNetworkNodeAdd $port_objref lan $lan_endpoint_args]
    if {[keylget result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failure in\
                ixNetworkLanStaticEndpointCfg:\
                encountered an error while executing: \
                ixNetworkNodeAdd $port_objref lan $lan_endpoint_args\
                - [keylget result log]"
        return $returnList
    }

    keylset returnList status $::SUCCESS
    keylset returnList endpoint_handle [keylget result node_objref]
    return $returnList
}

proc ::ixia::ixNetworkIgStaticEndpointCfg { args } {
    set man_args {
        -port_objref
    }
    
    set opt_args {
        -static_ig_atm_encap            CHOICES LLCRoutedCLIP
                                        CHOICES LLCBridgedEthernetFCS
                                        CHOICES LLCBridgedEthernetNoFCS
                                        CHOICES VccMuxIPV4Routed
                                        CHOICES VccMuxIPV6Routed
                                        CHOICES VccMuxBridgedEthernetFCS
                                        CHOICES VccMuxBridgedEthernetNoFCS
        -static_ig_vlan_enable          CHOICES 0 1
        -static_ig_ip_type              CHOICES ipv4 ipv6
        -static_ig_interface_enable_list    ANY
        -static_ig_interface_handle_list    ANY
    }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
                    $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    array set translate_atm_encapsulation [list                      \
        LLCBridgedEthernetFCS        llcBridgedEthernetWithFcs       \
        LLCBridgedEthernetNoFCS      llcBridgedEthernetWithOutFcs    \
        LLCRoutedCLIP                llcRoutedAal5Snap               \
        VccMuxBridgedEthernetFCS     vcMuxBridgedEth802p3WithFcs   \
        VccMuxBridgedEthernetNoFCS   vcMuxBridgedEth802p3WithOutFcs\
        VccMuxIPV4Routed             vcMuxIpv4Routed               \
        VccMuxIPV6Routed             vcMuxIpv6Routed               \
    ]
    
    # Start creating list LAN enpoint options
    set ig_endpoint_args [list -enabled true]
    
    # List of global options for LAN enpoints
    set ig_endpoint_options {
        static_ig_atm_encap         atmEncapsulation    translate
        static_ig_vlan_enable       enableVlan          default
        static_ig_ip_type           ip                  default
    }
    
    foreach {hlt_opt ixn_opt opt_type} $ig_endpoint_options {
        if {[info exists $hlt_opt]} {
            
            switch $opt_type {
                translate {
                    lappend ig_endpoint_args -$ixn_opt \
                            [set translate_atm_encapsulation([set $hlt_opt])]
                }
                default {
                    lappend ig_endpoint_args -$ixn_opt \
                            [set $hlt_opt]
                }
            }
        }
    }
    
    # Apply configurations
    set result [ixNetworkNodeAdd $port_objref interfaceGroup $ig_endpoint_args]
    if {[keylget result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failure in\
                ixNetworkIgStaticEndpointCfg:\
                encountered an error while executing: \
                ixNetworkNodeAdd $port_objref lan $ig_endpoint_args\
                - [keylget result log]"
        return $returnList
    }

    set endpoint_handle [keylget result node_objref]
    
    set intf_g_intf_h_options {
        tmp_ena         enabled
        tmp_protIntf    protocolInterface
    }
    
    set static_ig_intf_ena      ""
    set static_ig_intf_handle   ""
    
    if {[info exists static_ig_interface_enable_list]} {
        set static_ig_intf_ena    [split $static_ig_interface_enable_list :]
    }
    
    if {[info exists static_ig_interface_handle_list]} {
        set static_ig_intf_handle [regsub -all {:::} $static_ig_interface_handle_list { }]
    }
    
    # Acronym -> interfaceGroup interfaceHandle index
    set ig_ih_idx 0
    foreach static_ig_ih $static_ig_intf_handle {
        catch {unset tmp_ena}
        catch {unset tmp_protIntf}
        
        if {$static_ig_ih == {}} {
            continue
        }
        
        if {$ig_ih_idx > 0} {
            set static_ig_ih "::$static_ig_ih"
        }
        
        set tmp_protIntf $static_ig_ih
        
        if {![regexp {::ixNet::OBJ-/vport:\d+/interface:\d+} $tmp_protIntf]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure in ixNetworkIgStaticEndpointCfg:\
                    invalid value '$tmp_protIntf' for parameter '-static_ig_interface_handle_list'.\
                    Accepted values are handles returned by ::ixia::interface_config procedure with\
                    'interface_handle' key when '-static_enable' is '0' and '-l23_config_type' is\
                    'protocol_interface'"
            
            catch {ixNet rollback}
            
            return $returnList
        }
        
        set tmp_ena [lindex $static_ig_intf_ena $ig_ih_idx]
        if {$tmp_ena == {}} {
            unset tmp_ena
        }
        
        set ig_ih_args ""
        
        foreach {hlt_p ixn_p} $intf_g_intf_h_options {
            if {[info exists $hlt_p]} {
                lappend ig_ih_args -$ixn_p [set $hlt_p]
            }
        }
        
        set result [ixNetworkNodeAdd $endpoint_handle interface $ig_ih_args]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure in\
                    ixNetworkIgStaticEndpointCfg:\
                    encountered an error while executing: \
                    ixNetworkNodeAdd $endpoint_handle interface $ig_ih_args\
                    - [keylget result log]"
            return $returnList
        }
        
        incr ig_ih_idx
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList endpoint_handle $endpoint_handle
    return $returnList
}

proc ::ixia::ixNetworkStaticEndpointCfg { args } {
    
    set man_args {
        -port_objref
    }
    
    set vlan_user_priority_regexp      "^\[0-7\](,\[0-7\]){0,6}$"
    #set static_lan_intermediate_objref_regexp "^(::ixNet::OBJ-/vport:\\d+/protocols/static/atm:\\d+)|(::ixNet::OBJ-/vport:\\d+/protocols/static/fr:\\d+)"
    
    
    set opt_args {
        -atm_range_count            NUMERIC
        -vpi_step                   NUMERIC
        -vpi_increment_step         NUMERIC
        -vci_step                   NUMERIC
        -vci_increment_step         NUMERIC
        -pvc_count_step             NUMERIC

        -vci                        RANGE 0-4294967295
        -vci_increment              RANGE 0-4294967295
        -vpi                        RANGE 0-4294967295
        -vpi_increment              RANGE 0-4294967295
        -pvc_count                  RANGE 0-4294967295

        -atm_header_encapsulation   CHOICES llc_bridged_eth_fcs
                                    CHOICES llc_bridged_eth_no_fcs
                                    CHOICES llc_ppp
                                    CHOICES llc_routed_snap
                                    CHOICES vcc_mux_bridged_eth_fcs
                                    CHOICES vcc_mux_bridged_eth_no_fcs
                                    CHOICES vcc_mux_ppp
                                    CHOICES vcc_mux_routed

        -fr_range_count             NUMERIC
        -dlci_value_step            NUMERIC
        -dlci_repeat_count_step     NUMERIC

        -dlci_value                 RANGE 0-4294967295
        -dlci_count_mode            CHOICES fixed increment
        -dlci_repeat_count          RANGE 0-4294967295

        -ip_range_count             NUMERIC
        -ip_dst_range_step          IP
        -ip_dst_prefix_len_step     NUMERIC
        -ip_dst_increment_step      IP
        -ip_dst_count_step          NUMERIC

        -intf_handle

        -l3_protocol                CHOICES ipv4 ipv6

        -ip_dst_addr                IP
        -ip_dst_prefix_len          RANGE 0-128
        -ip_dst_increment           IP
        -ip_dst_count               RANGE 1-4294967295

        -lan_range_count            NUMERIC
        -indirect                   CHOICES 0 1
        -range_per_spoke            RANGE 1-4294967295
                                    DEFAULT 1
        -intermediate_objref        REGEXP ^(::ixNet::OBJ-/vport:\d+/protocols/static/atm:\d+)|(::ixNet::OBJ-/vport:\d+/protocols/static/fr:\d+)
        -mac_dst_step               NUMERIC
        -mac_dst_count_step         NUMERIC
        -vlan_id_step               REGEXP (^[0-9]+(,[0-9]+)*$)|(^[0-9]+(:[0-9]+)*$)
        -site_id_step               NUMERIC
        
        -mac_dst
        -mac_dst_mode               CHOICES fixed increment
        -mac_dst_count              RANGE 1-4294967295
        -vlan_enable                CHOICES 0 1
        -vlan_id                    REGEXP ^[0-9]+(:[0-9]+)*$
        -vlan_id_mode               CHOICES fixed increment inner outer
        -site_id_enable             CHOICES 0 1
        -site_id                    RANGE 0-4294967295
        -lan_count_per_vc           NUMERIC
        -lan_incr_per_vc_vlan_mode  CHOICES fixed increment inner outer
        -lan_mac_range_mode         CHOICES normal bundled
        -lan_number_of_vcs          NUMERIC
        -lan_skip_vlan_id_zero      CHOICES 0 1
        -lan_tpid                   REGEXP ^[0x8100|0x88a8|0x88A8|0x9100|0x9200]+(:[0x8100|0x88a8|0x88A8|0x9100|0x9200]+)*$
        -lan_vlan_priority          REGEXP ^[0-9]+(:[0-9]+)*$
        -lan_vlan_stack_count       NUMERIC
        -static_ig_atm_encap                ANY
        -static_ig_vlan_enable              ANY
        -static_ig_ip_type                  ANY
        -static_ig_interface_enable_list    ANY
        -static_ig_interface_handle_list    ANY
        -static_ig_range_count              NUMERIC
    }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
                    $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    set atm_args_list [list atm_header_encapsulation pvc_count vci \
            vci_increment vpi vpi_increment]
    set fr_args_list [list dlci_count_mode dlci_repeat_count dlci_value]
    set ip_args_list [list intf_handle ip_dst_addr ip_dst_count \
            ip_dst_increment ip_dst_prefix_len l3_protocol]
    set lan_args_list [list mac_dst mac_dst_count mac_dst_mode site_id \
            site_id_enable vlan_enable vlan_id vlan_id_mode \
            lan_count_per_vc lan_incr_per_vc_vlan_mode lan_mac_range_mode lan_number_of_vcs\
            lan_skip_vlan_id_zero lan_tpid lan_vlan_priority lan_vlan_stack_count]
    set ig_args_list [list static_ig_atm_encap static_ig_vlan_enable static_ig_ip_type\
            static_ig_interface_enable_list static_ig_interface_handle_list]
    
    
    set atm_endpoints [list]
    set fr_endpoints  [list]
    set ip_endpoints  [list]
    set lan_endpoints [list]
    set ig_endpoints  [list]
    
    set static_objref $port_objref/protocols/static
    set port_objref_type [ixNet getA $port_objref -type]
    
    # ATM
    if {$port_objref_type == "atm"} {
        if {([info exists atm_header_encapsulation] || \
                [info exists pvc_count] || \
                [info exists vci] || \
                [info exists vci_increment] || \
                [info exists vpi] || \
                [info exists vpi_increment]) && ![info exists atm_range_count]} {
            set atm_range_count 1
        } elseif {![info exists atm_range_count]} {
            set atm_range_count 0
        }
        for {set i 0} {$i < $atm_range_count} {incr i} {
            # Prepare ATM endpoint parameters
            set atm_args "-port_objref $static_objref"
            foreach item $atm_args_list {
                if {[info exists $item]} {
                    if {[llength [set $item]] > 1} {
                        if {[lindex [set $item] $i] != {}} {
                            append atm_args " -$item [lindex [set $item] $i]"
                        }
                    } else {
                        append atm_args " -$item [set $item]"
                    }
                }
            }

            # Create ATM endpoint
            set result [eval ixNetworkAtmStaticEndpointCfg $atm_args]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failure in\
                        ixNetworkStaticEndpointCfg:\
                        encountered an error while executing: \
                        ixNetworkAtmStaticEndpointCfg\
                        - [keylget result log]"
                return $returnList
            }

            if {![catch {keylget result endpoint_handle} ret_val]} {
                lappend atm_endpoints $ret_val
            }

            # Increment ATM endpoint parameters
            if {[info exists vpi] && [llength $vpi] == 1 && \
                    [info exists vpi_step] && [llength $vpi_step] == 1} {
                incr vpi $vpi_step
            }
            if {[info exists vpi_increment] && [llength $vpi_increment] == 1 &&\
                    [info exists vpi_increment_step] && [llength $vpi_increment_step] == 1} {
                incr vpi_increment $vpi_increment_step
            }
            if {[info exists vci] && [llength $vci] == 1 &&\
                    [info exists vci_step] && [llength $vci_step] == 1} {
                incr vci $vci_step
            }
            if {[info exists vci_increment] && [llength $vci_increment] == 1 &&\
                    [info exists vci_increment_step] && [llength $vci_increment_step] == 1} {
                incr vci_increment $vci_increment_step
            }
            if {[info exists pvc_count] && [llength $pvc_count] == 1 &&\
                    [info exists pvc_count_step] && [llength $pvc_count_step] == 1} {
                incr pvc_count $pvc_count_step
            }
        }
        debug "ixNet commit"
        ixNet commit
        if {[llength $atm_endpoints] > 0} {
            debug "ixNet remapIds $atm_endpoints"
            set atm_endpoints [ixNet remapIds $atm_endpoints]
        }
    }
    
    # Frame Relay
    if {$port_objref_type == "pos"} {
        if {([info exists dlci_count_mode] || \
                [info exists dlci_count_mode] || \
                [info exists dlci_value]) && ![info exists fr_range_count]} {
            set fr_range_count 1
        } elseif {![info exists fr_range_count]} {
            set fr_range_count 0
        }
        for {set i 0} {$i < $fr_range_count} {incr i} {
            # Prepare Frame Relay endpoint parameters
            set fr_args "-port_objref $static_objref"
            foreach item $fr_args_list {
                if {[info exists $item]} {
                    if {[llength [set $item]] > 1} {
                        if {[lindex [set $item] $i] != {}} {
                            append fr_args " -$item [lindex [set $item] $i]"
                        }
                    } else {
                        append fr_args " -$item [set $item]"
                    }
                }
            }

            # Create Frame Relay endpoint
            set result [eval ixNetworkFrameRelayStaticEndpointCfg $fr_args]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failure in\
                        ixNetworkStaticEndpointCfg:\
                        encountered an error while executing: \
                        ixNetworkFrameRelayStaticEndpointCfg\
                        - [keylget result log]"
                return $returnList
            }

            if {![catch {keylget result endpoint_handle} ret_val]} {
                lappend fr_endpoints $ret_val
            }

            # Increment Frame Relay endpoint parameters
            if {[info exists dlci_repeat_count] && [llength $dlci_repeat_count] == 1 &&\
                    [info exists dlci_repeat_count_step] && [llength $dlci_repeat_count_step] == 1} {
                incr dlci_repeat_count $dlci_repeat_count_step
            }
            if {[info exists dlci_value] && [llength $dlci_value] == 1 &&\
                    [info exists dlci_value_step] && [llength $dlci_value_step] == 1} {
                incr dlci_value $dlci_value_step
            }
        }
        debug "ixNet commit"
        ixNet commit
        if {[llength $fr_endpoints] > 0} {
            debug "ixNet remapIds $fr_endpoints"
            set fr_endpoints [ixNet remapIds $fr_endpoints]
        }
    }
    
    # IP
    if {([info exists intf_handle] || \
            [info exists ip_dst_addr] || \
            [info exists ip_dst_count] || \
            [info exists ip_dst_increment] || \
            [info exists ip_dst_prefix_len] || \
            [info exists l3_protocol]) && ![info exists ip_range_count]} {
        set ip_range_count 1
    } elseif {![info exists ip_range_count]} {
        set ip_range_count 0
    }
    for {set i 0} {$i < $ip_range_count} {incr i} {
        # Prepare IP endpoint parameters
        set ip_args "-port_objref $static_objref"
        foreach item $ip_args_list {
            if {[info exists $item]} {
                if {[llength [set $item]] > 1} {
                    if {[lindex [set $item] $i] != {}} {
                        append ip_args " -$item [lindex [set $item] $i]"
                    }
                } else {
                    append ip_args " -$item [set $item]"
                }
            }
        }

        # Create IP endpoint
        set result [eval ixNetworkIpStaticEndpointCfg $ip_args]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure in\
                    ixNetworkStaticEndpointCfg:\
                    encountered an error while executing: \
                    ixNetworkIpStaticEndpointCfg\
                    - [keylget result log]"
            return $returnList
        }

        if {![catch {keylget result endpoint_handle} ret_val]} {
            lappend ip_endpoints $ret_val
        }

        # Increment IP endpoint parameters
        if {[info exists ip_dst_addr] && [llength $ip_dst_addr] == 1 &&\
                [info exists ip_dst_range_step] && [llength $ip_dst_range_step] == 1} {
            
            set ret_status [incr_ip_addr $ip_dst_addr $ip_dst_range_step]
            if {![keylget ret_status status]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid parameters 'static_ip_dst_addr', 'static_ip_dst_range_step'.\
                        [keylget ret_status log]"
                return $returnList
            }
            
            keylget ret_status ret_val ip_dst_addr
            
        }
        if {[info exists ip_dst_count] && [llength $ip_dst_count] == 1 &&\
                [info exists ip_dst_count_step] && [llength $ip_dst_count_step] == 1} {
            incr ip_dst_count $ip_dst_count_step
        }
        
        if {[info exists ip_dst_increment] && [llength $ip_dst_increment] == 1 &&\
                [info exists ip_dst_increment_step] && [llength $ip_dst_increment_step] == 1} {
            
            set ret_status [incr_ip_addr $ip_dst_increment $ip_dst_increment_step]
            if {![keylget ret_status status]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid parameters 'static_ip_dst_increment', 'static_ip_dst_increment_step'.\
                        [keylget ret_status log]"
                return $returnList
            }
            
            keylget ret_status ret_val ip_dst_increment
        }
        if {[info exists ip_dst_prefix_len] && [llength $ip_dst_prefix_len] == 1 &&\
                [info exists ip_dst_prefix_len_step] && [llength $ip_dst_prefix_len_step] == 1} {
            incr ip_dst_prefix_len $ip_dst_prefix_len_step
        }
    }
    debug "ixNet commit"
    ixNet commit
    if {[llength $ip_endpoints] > 0} {
        debug "ixNet remapIds $ip_endpoints"
        set ip_endpoints [ixNet remapIds $ip_endpoints]
    }

    # LAN
    # Get the port type
    if {([info exists mac_dst] || \
            [info exists mac_dst_count] || \
            [info exists mac_dst_mode] || \
            [info exists site_id] || \
            [info exists site_id_enable] || \
            [info exists vlan_enable] || \
            [info exists vlan_id] || \
            [info exists vlan_id_mode])} {
            if {![info exists lan_range_count] || $lan_range_count == 0} {
                set lan_range_count 1
                puts "\nWARNING:Static lan parameters are detected. Setting the -static_lan_range_count value to 1"
            }
    } elseif {![info exists lan_range_count]} {
        set lan_range_count 0
    }
    
    if {$lan_range_count > 0} {
        if {$port_objref_type == "atm" || $port_objref_type == "pos"} {
            if {![info exists indirect] || !$indirect} {
                keylset returnList status $::FAILURE
                keylset returnList log "The LAN range won't be usable on a(n) $port_objref_type\
                        port if it isn't connected, indirectly, through a $port_objref_type\
                        endpoint."
                return $returnList
            }
        } else {
            if {[info exists indirect] && $indirect} {
                keylset returnList status $::FAILURE
                keylset returnList log "The LAN range can't be connected indirectly\
                        on a(n) $port_objref_type endpoint."
                return $returnList
            }
        }
        
        if {[info exists indirect] && $indirect} {
            if {[info exists intermediate_objref]} {
                if {[llength $intermediate_objref] < [mpexpr $lan_range_count / $range_per_spoke]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "When port is '$port_objref_type' and parameter '-static_intermediate_objref' is specified,\
                            it must have a length at least equal to -static_lan_range_count divided by -static_range_per_spoke."
                    return $returnList
                }
            } else {
                if {$port_objref_type == "atm"} {
                    if {[llength $atm_endpoints] < [mpexpr $lan_range_count / $range_per_spoke]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "When port is '$port_objref_type' and parameter '-static_intermediate_objref' is missing,\
                                parameter '-static_atm_range_count' at least equal to -static_lan_range_count\
                                divided by -static_range_per_spoke."
                        return $returnList
                    }
                } elseif {$port_objref_type == "pos"} {
                    if {[llength $fr_endpoints] < [mpexpr $lan_range_count / $range_per_spoke]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "When port is '$port_objref_type' and parameter '-static_intermediate_objref' is missing,\
                                parameter '-static_fr_range_count' at least equal to -static_lan_range_count\
                                divided by -static_range_per_spoke."
                        return $returnList
                    }
                }
            }
        }
        
        ## If it's a single mac address make sure it doesn't have any spaces
        #  Otherwise it will be fragmented
        if {[info exists mac_dst]} {
            if {[isValidMacAddress $mac_dst]} {
                set mac_dst [ixNetworkFormatMac $mac_dst]
            }
        }
        
        for {set i 0} {$i < $lan_range_count} {incr i} {
            # Prepare LAN endpoint parameters
            set lan_args "-port_objref $static_objref"
            foreach item $lan_args_list {
                if {[info exists $item]} {
                    if {[llength [set $item]] > 1} {
                        if {[lindex [set $item] $i] != {}} {
                            append lan_args " -$item [lindex [set $item] $i]"
                        }
                    } else {
                        append lan_args " -$item [set $item]"
                    }
                }
            }
            if {[info exists indirect] && $indirect} {
                if {[info exists intermediate_objref]} {
                    
                    set endpoint_objref [lindex $intermediate_objref \
                            [expr $i / $range_per_spoke]]
                    
                } else {
                    switch $port_objref_type {
                        atm {
                            set endpoint_objref [lindex $atm_endpoints \
                                    [expr $i / $range_per_spoke]]
                        }
                        pos {
                            set endpoint_objref [lindex $fr_endpoints \
                                    [expr $i / $range_per_spoke]]
                        }
                    }
                }
                
                if {$endpoint_objref != {}} {
                    append lan_args " -intermediate_objref $endpoint_objref"
                }
            }

            # Create LAN endpoint
            set result [eval ixNetworkLanStaticEndpointCfg $lan_args]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failure in\
                        ixNetworkStaticEndpointCfg:\
                        encountered an error while executing: \
                        ixNetworkLanStaticEndpointCfg\
                        - [keylget result log]"
                return $returnList
            }

            if {![catch {keylget result endpoint_handle} ret_val]} {
                lappend lan_endpoints $ret_val
            }

            # Increment LAN endpoint parameters
            if {[info exists mac_dst] && [llength $mac_dst] == 1 &&\
                    [info exists mac_dst_step] && [llength $mac_dst_step] == 1} {
                set mac_dst [::ixia::incrementMacAdd $mac_dst $mac_dst_step]
                set mac_dst [ixNetworkFormatMac $mac_dst]
            }
            if {[info exists mac_dst_count] && [llength $mac_dst_count] == 1 &&\
                    [info exists mac_dst_count_step] && [llength $mac_dst_count_step] == 1} {
                incr mac_dst_count $mac_dst_count_step
            }
            if {[info exists site_id] && [llength $site_id] == 1 &&\
                    [info exists site_id_step] && [llength $site_id_step] == 1} {
                incr site_id $site_id_step
            }
            if {[info exists vlan_id] && [info exists vlan_id_step]} {
                if {[regexp {^[0-9]+(:[0-9]+)*$} $vlan_id]} {
                    set vlan_id_split       [split $vlan_id :]
                } elseif {[regexp {^[0-9]+(\s[0-9]+)*$} $vlan_id]} {
                    set vlan_id_split   $vlan_id
                }
                if {[regexp {^[0-9]+(:[0-9]+)*$} $vlan_id_step]} {
                    set vlan_id_step_split       [split $vlan_id_step :]
                } elseif {[regexp {^[0-9]+(\s[0-9]+)*$} $vlan_id_step]} {
                    set vlan_id_step_split  $vlan_id_step
                }
                
                if {[llength $vlan_id_split] != [llength $vlan_id_step_split]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failure in\
                            ixNetworkStaticEndpointCfg:\
                            The number of qinq tags is different in parameters\
                            -static_vlan_id and -static_vlan_id_step"
                    return $returnList
                }
                
                set vlan_id_after_incr ""
                
                foreach tmp_vlan $vlan_id_split tmp_vlan_step $vlan_id_step_split {
                    lappend vlan_id_after_incr [expr $tmp_vlan + $tmp_vlan_step]
                }
                
                set vlan_id [join $vlan_id_after_incr :]
            }
        }
        
        debug "ixNet commit"
        ixNet commit
        if {[llength $lan_endpoints] > 0} {
            debug "ixNet remapIds $lan_endpoints"
            set lan_endpoints [ixNet remapIds $lan_endpoints]
        }
    }
    
    # InterfaceGroup
    
    if {([info exists static_ig_atm_encap] || \
            [info exists static_ig_vlan_enable] || \
            [info exists static_ig_ip_type] || \
            [info exists static_ig_interface_enable_list] || \
            [info exists static_ig_interface_handle_list]) && ![info exists static_ig_range_count]} {
        set static_ig_range_count 1
    } elseif {![info exists static_ig_range_count]} {
        set static_ig_range_count 0
    }
    for {set i 0} {$i < $static_ig_range_count} {incr i} {
        # Prepare InterfaceGroup endpoint parameters
        set ig_args "-port_objref $static_objref"
        foreach item $ig_args_list {
            if {[info exists $item]} {
                if {[llength [set $item]] > 1} {
                    if {[lindex [set $item] $i] != {}} {
                        append ig_args " -$item [lindex [set $item] $i]"
                    }
                } else {
                    append ig_args " -$item [set $item]"
                }
            }
        }

        # Create InterfaceGroup endpoint
        set result [eval ixNetworkIgStaticEndpointCfg $ig_args]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure in\
                    ixNetworkStaticEndpointCfg:\
                    encountered an error while executing: \
                    ixNetworkIgStaticEndpointCfg\
                    - [keylget result log]"
            return $returnList
        }

        if {![catch {keylget result endpoint_handle} ret_val]} {
            lappend ig_endpoints $ret_val
        }
    }
    debug "ixNet commit"
    ixNet commit
    if {[llength $ig_endpoints] > 0} {
        debug "ixNet remapIds $ig_endpoints"
        set ig_endpoints [ixNet remapIds $ig_endpoints]
    }
    
    keylset returnList status        $::SUCCESS
    keylset returnList atm_endpoints $atm_endpoints
    keylset returnList fr_endpoints  $fr_endpoints
    keylset returnList ip_endpoints  $ip_endpoints
    keylset returnList lan_endpoints $lan_endpoints
    keylset returnList ig_endpoints  $ig_endpoints
    return $returnList
}

proc ::ixia::ixNetworkApplyTraffic {{traffic_generator ixnetwork}} {
    variable 540IxNetTrafficGenerate
    variable 540IxNetTrafficState
    set trafficState ""
    
    catch {set trafficState [ixNet getAttribute [ixNet getRoot]traffic -state]}
    if {[info exists 540IxNetTrafficState] && ($540IxNetTrafficState == "unapplied")} {
        set trafficState            $540IxNetTrafficState
        set 540IxNetTrafficState    "" 
    }
    switch $trafficState {
        error                   {}
        locked          {
            keylset returnList status $::FAILURE
            keylset returnList log "Cannot apply traffic at thsi moment, plaese try again in a few moments."
            return $returnList
        }
        started -
        startedWaitingForStats -
        stopped                -
        stoppedWaitingForStats -
        txStopWatchExpected     {
            keylset returnList status $::SUCCESS
            return $returnList
        }
        unapplied               {}
        default                 {}
    }
    
    uplevel {
        set vport_objrefs ""
        # Check link state
        set trafficItems [ixNet getList [ixNet getRoot]traffic trafficItem]
        if {[llength $trafficItems] < 1} {
            keylset returnList status $::FAILURE
            keylset returnList log "Cannot apply traffic. No traffic items found. Possible cause:\
                    traffic was configured with a different traffic generator than '$traffic_generator'."
            return $returnList
        }
        foreach trafficItem $trafficItems {
            if {$traffic_generator == "ixnetwork_540"} {
                set trafficPairs [ixNet getList $trafficItem endpointSet]
            } else {
                set trafficPairs [ixNet getList $trafficItem pair]
            }
            foreach trafficPair $trafficPairs {
                set destinations [ixNet getAttribute $trafficPair -destinations]
                set sources [ixNet getAttribute $trafficPair -sources]
                set all_objrefs [concat $destinations $sources]
                foreach {ixn_objref} $all_objrefs {
                    if {[regsub "^([ixNet getRoot]vport:\[0-9\]+)(.*)$" \
                            $ixn_objref {\1} ixn_objref]} {
                        lappend vport_objrefs $ixn_objref
                    }
                }
            }
            if {[info exists 540IxNetTrafficGenerate] && ($540IxNetTrafficGenerate == 0)} {
                set retCode [540IxNetTrafficGenerate $trafficItem]
                if {[keylget retCode status] != $::SUCCESS} {
                    return $retCode
                }
            }
        }
        if {$vport_objrefs != ""} {
            set vport_objrefs [lsort -unique $vport_objrefs]
            set vport_cmd ""
            set vport_count 0
            foreach vport_objref $vport_objrefs {
                if {![catch {ixNet getAttribute $vport_objref \
                        -transmitIgnoreLinkStatus} result] && \
                        $result != "true"} {
                    append vport_cmd " \[ixNet getAttribute $vport_objref -state\]"
                    incr vport_count
                }
            }
            set numRetries 20
            while {(([set linkState [subst $vport_cmd]] != [string repeat " up" \
                    $vport_count]) && ($numRetries > 0))} {
                incr numRetries -1
                ixPuts "Waiting for port links to be up ..."
                after 1000
            }
            if {$linkState != [string repeat " up" $vport_count]} {
                keylset returnList status $::FAILURE
                keylset returnList log "The link is not up on all ports. \
                        Failed to apply traffic configuration."
                return $returnList
            } else {
                ixPuts "Links on all ports are up ..."
            }
        }
        
        # Apply the traffic items
        set continueFlag "true"
        set initTime [clock seconds]
        set timeoutCount 30; # Try for 30 seconds.
        while {$continueFlag == "true" && \
                ([expr [clock seconds] - $initTime]) < $timeoutCount} {
            
            foreach apply_item $applyType {
                if {$apply_item == "applyApplicationTraffic"} {
                    # only one L47 traffic item can be enabled once => IxNetwork limitation
                    set l47_traffic_item [ixNet getL [ixNet getRoot]traffic trafficItem]
                    set only_one 0
                    foreach l47_tr $l47_traffic_item {
                        if {[ixNet getA $l47_tr -trafficItemType] == "application"} {
                            if {$only_one} {
                                ixNet setA $l47_tr -enabled false
                            }
                            set only_one 1
                        }
                    }
                    if {$only_one} {
                        ixNet commit
                    }
                }
                debug "ixNet exec $apply_item [ixNet getRoot]traffic"
                if {[catch {ixNet exec $apply_item [ixNet getRoot]traffic} retCode] || $retCode != "::ixNet::OK"} {
                    after 1000
                } else {
                    set continueFlag "false"
                    if {$traffic_generator == "ixnetwork_540"} {
                        foreach trafficItem $trafficItems {
                            if {[catch {ixNet getA $trafficItem -errors} ti_errors]} {
                                continue
                            }
                            
                            if {$ti_errors != ""} {
                                set continueFlag "true"
    #                             set retCode [540IxNetTrafficGenerate $trafficItem]
    #                             if {[keylget retCode status] != $::SUCCESS} {
    #                                 return $retCode
    #                             }
                            }
                        }
                    }
                }
            }
        }
        if {$continueFlag == true} {
            keylset returnList status $::FAILURE
            set logMsg ""

            if {$traffic_generator == "ixnetwork_540"} {
                foreach trafficItem $trafficItems {
                    if {[catch {ixNet getA $trafficItem -name} ti_name]} {
                        continue
                    }
                    if {[catch {ixNet getA $trafficItem -errors} ti_errors]} {
                        continue
                    }
                    
                    append logMsg " Errors on traffic item $ti_name:"
                    
                    set err_idx 0
                    foreach ixn_ti_err $ti_errors {
                        if {$err_idx == 0} {
                            append logMsg " $ixn_ti_err"
                        } else {
                            append logMsg "; $ixn_ti_err"
                        }
                        incr err_idx
                    }
                    
                    append logMsg "."
                    
                    if {![catch {ixNet getA $trafficItem -warnings} ti_warning]} {
                        debug "Traffic item $trafficItem warnings: $ti_warning"
                    }
                }
            }

            keylset returnList log "Failed to apply traffic configuration - $retCode.$logMsg"
            return $returnList
        }
    }
    
    # Enable trafficStatViewBrowser views
    set retries 5
    while {([catch {set statViewsTraffic \
            [ixNet getList [ixNet getRoot]statistics trafficStatViewBrowser]}] || \
            ($statViewsTraffic == "") || \
            ($statViewsTraffic == "unhandledExceptionInGetChildren")) && \
            ($retries > 0)} {
        incr retries -1
        after 1000
    }
    
    if {($statViewsTraffic != "") && \
            ($statViewsTraffic != "unhandledExceptionInGetChildren")} {
        foreach statView $statViewsTraffic {
            set retries 5
            while {([ixNet exists $statView] == "false" || [ixNet exists $statView] == 0) && $retries > 0} {
                after 1000
                incr retries -1
            }
            if {$retries <= 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "StatView object $statView is not available."
                return $returnList
            }
            if {[ixNet getAttribute $statView -enabled] == "false"} {
                debug "ixNet setAttribute $statView -enabled true"
                ixNet setAttribute $statView -enabled true
                debug "ixNet commit"
                ixNet commit
            }
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixNetworkGetParentObjref { objRef {parentName {}} } {
    set objRef [string trim $objRef]
    set objectsList [split $objRef /]
    
    # This is [ixNet getRoot] object
    if {[llength $objectsList] == 1} {
        return $objRef
    }
    
    if {$parentName == ""} {
        # Get first parent
        set objectsList [lreplace $objectsList end end]
        
        return [join $objectsList /]
    
    } else {
        set found 0
        # Get parent with name "$parentName"
        set retObj "[lindex $objectsList 0]"
        for {set i 1} {$i < [llength $objectsList]} {incr i} {
            set currentObject [lindex $objectsList $i]

            append retObj "/$currentObject"

            if {[lindex [split $currentObject :] 0] == $parentName} {
               set found 1
               break
            }
        }
        
        if {$found} {
            return $retObj
        } else {
            return [ixNet getNull]
        }
    }
}


proc ::ixia::ixNetworkStaticEndpointAtmMacRangeCfg { args } {
    set procName [lindex [info level [info level]] 0]
    
    set opt_args {
        -mode           CHOICES create modify 
                        DEFAULT create
        -src_mac_addr        
        -src_mac_addr_step   
        -mtu                 NUMERIC
        -atm_encapsulation   ANY
        -range_objref
        -commit              CHOICES commit no_commit
                             DEFAULT commit
        -connected_count     NUMERIC
    }

    if {[catch {::ixia::parse_dashed_args -args $args  \
                    -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing ($procName). $parse_error"
        return $returnList
    }
    
    array set translate {
        VccMuxIPV4Routed            1
        VccMuxBridgedEthernetFCS    2
        VccMuxBridgedEthernetNoFCS  3
        VccMuxIPV6Routed            4
        VccMuxMPLSRouted            10
        LLCRoutedCLIP               6
        LLCBridgedEthernetFCS       7
        LLCBridgedEthernetNoFCS     8
        LLCPPPoA                    9
        VccMuxPPPoA                 10
        LLCNLPIDRouted              6
    }
    
    # Start creating list LAN enpoint options
    set lan_endpoint_args [list -enabled true]
    
    # List of global options for LAN enpoints
    set lan_endpoint_options {
        src_mac_addr        mac                 MAC
        src_mac_addr_step   incrementBy         MAC
        mtu                 mtu                 identity
        connected_count     count               identity
    }
    
    if {[regexp {^::ixNet::OBJ-/vport:[0-9]+/protocolStack/atm:} $range_objref]} {
        set obj_type atmRange
        lappend lan_endpoint_options atm_encapsulation encapsulation translate
    } else {
        set obj_type macRange
    }
    
    foreach {hlt_opt ixn_opt opt_type} $lan_endpoint_options {
        if {[info exists $hlt_opt]} {
            switch $opt_type {
                MAC {
                    lappend lan_endpoint_args -$ixn_opt \
                            [::ixia::convertToIxiaMac [set $hlt_opt] :]
                }
                identity {
                    lappend lan_endpoint_args -$ixn_opt \
                            [set $hlt_opt]
                }
                translate {
                    if {[info exists translate([set $hlt_opt])]} {
                        lappend lan_endpoint_args -$ixn_opt \
                                [set translate([set $hlt_opt])]
                    }
                }
                default {
                    lappend lan_endpoint_args -$ixn_opt \
                            [set $hlt_opt]
                }
            }
        }
    }

    keylset returnList status $::FAILURE
    # Apply configurations
    if {$mode == "create"} {
        set lanList [ixNet getList $range_objref $obj_type]
        if {$lanList == ""} {
            set result [ixNetworkNodeAdd $range_objref $obj_type $lan_endpoint_args -$commit]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed while executing:\
                        ixNetworkNodeAdd $range_objref lan $lan_endpoint_args ($procName).\
                        [keylget result log]"
                return $returnList
            }
            keylset returnList status $::SUCCESS
            keylset returnList handle [keylget result node_objref]
        } else {
            set result [ixNetworkNodeSetAttr [lindex $lanList 0] $lan_endpoint_args -$commit]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed while executing:\
                        ixNetworkNodeSetAttr [lindex $lanList 0] $lan_endpoint_args ($procName).\
                        [keylget result log]"
                return $returnList
            }
            keylset returnList status $::SUCCESS
            keylset returnList handle [lindex $lanList 0]
        }
    }
    if {$mode == "modify"} {
        set result [ixNetworkNodeSetAttr $range_objref $lan_endpoint_args -$commit]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed while executing:\
                    ixNetworkNodeSetAttr $range_objref $lan_endpoint_args ($procName).\
                    [keylget result log]"
            return $returnList
        }
    
        keylset returnList status $::SUCCESS
        keylset returnList handle $range_objref
    }
    return $returnList
}

proc ::ixia::ixNetworkStaticEndpointVlanRangeCfg { args } {
    set procName [lindex [info level [info level]] 0]
    
    set opt_args {
        -mode           CHOICES create modify 
                        DEFAULT create
        -vlan
        -vlan_id
        -vlan_id_step
        -vlan_id_count
        -vlan_user_priority
        -vlan_tpid
        -qinq_incr_mode
        -addresses_per_vlan
        -addresses_per_svlan
        -range_objref
        -commit              CHOICES commit no_commit
                             DEFAULT commit
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args  \
            -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing ($procName). $parse_error"
        return $returnList
    }

    array set translate {
        outer 0
        inner 1
        both  2
    }
    
    # Array used to translate the options in IdInfo elements
    array set translateIdInfo {
    
    }
    
    set vlan_endpoint_args [list ]
    
    # List of global options for VLAN
    set vlan_endpoint_options {
        vlan                    
        vlan_id                 
        vlan_id_step            
        vlan_id_count           
        vlan_user_priority      
        qinq_incr_mode          
        addresses_per_vlan      
        addresses_per_svlan      
        vlan_tpid
    }
    
    # Start creating list VLAN options
    if {[info exists vlan]} {
        if {$vlan == 1} {
            lappend vlan_endpoint_args -enabled true
        } else {
            lappend vlan_endpoint_args -enabled false
        }
    }
    if {[info exists vlan_id] && ([llength [split $vlan_id ,]] > 1)} {
        lappend vlan_endpoint_args -innerEnable true
    } else {
        lappend vlan_endpoint_args -innerEnable false
    }

    # List of global options for VLAN
    set vlan_endpoint_options {
        vlan_id                 firstId,innerFirstId              identity
        vlan_id_step            increment,innerIncrement          identity
        vlan_id_count           uniqueCount,innerUniqueCount      identity
        vlan_user_priority      priority,innerPriority            identity
        qinq_incr_mode          idIncrMode                        translate
        addresses_per_vlan      incrementStep                     identity
        addresses_per_svlan     innerIncrementStep                identity
        vlan_tpid               tpid,innerTpid                    identity
    }
        
    # The translation map used for the IdInfo elements
    set vlan_idInfo_options {
        vlan_id             firstId         identity
        vlan_id_step        increment       identity
        vlan_id_count       uniqueCount     identity
        vlan_user_priority  priority        identity
        addresses_per_vlan  incrementStep   onlyInFirst
        addresses_per_svlan incrementStep   onlyInSecond
        vlan_tpid           tpid            identity
        vlan                enabled         identity
    }
      
    foreach {hlt_opt ixn_opt opt_type} $vlan_endpoint_options {
        if {[info exists $hlt_opt]} {
            set $hlt_opt [split [set $hlt_opt] ,]
        }
    }
    # Multiplying the last vlan element in order to have 
    # the same number of elements as the vlan_id list
    if {[info exists vlan]} {
        set last_vlan_element [lindex $vlan end]
        if {[info exists vlan_id]} {
            set count [llength $vlan_id]
            for {set i 1} {$i < $count} {incr i} {
                lappend vlan $last_vlan_element
            }
        }
    }
    
      
    set max_index 0;# The number of idInfo elements configured    
    foreach {hlt_opt ixn_opt opt_type} $vlan_idInfo_options {
        set vlan_endpoint_args ""
        if {[info exists $hlt_opt]} {
            if {[llength [set $hlt_opt]] > 0} {
                set index 0
                foreach hlt_element [set $hlt_opt] {
                    if {![info exists vlan_endpoint_args_$index]} {
                        set vlan_endpoint_args [list]
                    }
                    switch $opt_type {
                        translate {
                            lappend vlan_endpoint_args_$index -$ixn_opt $translateIdInfo([set $hlt_element])
                        }
                        onlyInFirst {
                                if {[llength [set $hlt_opt]] > 1} {
                                    lappend vlan_endpoint_args_$index -$ixn_opt $hlt_element
                                } else {
                                    lappend vlan_endpoint_args_0 -$ixn_opt $hlt_element
                                }
                        }
                        onlyInSecond {
                                if {([llength $addresses_per_vlan] > 1) || ([llength $hlt_opt] > 1)} {
                                    lappend vlan_endpoint_args_[expr [llength $addresses_per_vlan] + $index] -$ixn_opt $hlt_element
                                } else {
                                    lappend vlan_endpoint_args_1 -$ixn_opt $hlt_element
                                }
                        }
                        default {
                            lappend vlan_endpoint_args_$index -$ixn_opt $hlt_element
                        }
                    }
                    incr index
                }
            }
            if {$max_index < $index} {
                set max_index $index
            }
        }
    }
   
    foreach {hlt_opt ixn_opt opt_type} $vlan_endpoint_options {
        if {[info exists $hlt_opt]} {
            set length [llength [set $hlt_opt]]
            set hlt_1  [lindex  [set $hlt_opt] 0]
            set hlt_2  [lindex  [set $hlt_opt] 1]
            
            set ixn_1 [lindex [split $ixn_opt ,] 0]
            set ixn_2 [lindex [split $ixn_opt ,] 1]
            
            # Switch values when stacked vlan enabled
            if {$length > 1} {
                set hlt_v1 $hlt_2
                set hlt_v2 $hlt_1
            } else {
                set hlt_v1 $hlt_1
            }

            switch $opt_type {
                identity {
                    if {$ixn_1 != "" && [info exists hlt_v1]} {
                        lappend vlan_endpoint_args -$ixn_1 $hlt_v1
                    }
                    if {$ixn_2 != "" && [info exists hlt_v2]} {
                        lappend vlan_endpoint_args -$ixn_2 $hlt_v2
                    }
                }
                translate {
                    lappend vlan_endpoint_args -$ixn_opt $translate([set $hlt_opt])
                }
                default {
                    if {$ixn_1 != "" && [info exists hlt_v1]} {
                        lappend vlan_endpoint_args -$ixn_1 $hlt_v1
                    }
                    if {$ixn_2 != "" && [info exists hlt_v2]} {
                        lappend vlan_endpoint_args -$ixn_2 $hlt_v2
                    }
                }
            }
            catch {unset hlt_v1}
            catch {unset hlt_v2}
        }
    }
    keylset returnList status $::FAILURE
    # Apply configurations
    if {$mode == "create"} {
        set vlanList [ixNet getList $range_objref vlanRange]
        if {$vlanList == ""} {
            set result [ixNetworkNodeAdd $range_objref vlanRange $vlan_endpoint_args -$commit]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed while executing:\
                        ixNetworkNodeAdd $range_objref vlanRange $vlan_endpoint_args ($procName).\
                        [keylget result log]"
                return $returnList
            }
            keylset returnList status $::SUCCESS
            keylset returnList handle [keylget result node_objref]
        } else {
            set result [ixNetworkNodeSetAttr [lindex $vlanList 0] $vlan_endpoint_args -$commit]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed while executing:\
                        ixNetworkNodeSetAttr [lindex $vlanList 0] $vlan_endpoint_args ($procName).\
                        [keylget result log]"
                return $returnList
            }
            keylset returnList status $::SUCCESS
            keylset returnList handle [lindex $vlanList 0]
        }
        set vlanList [ixNet getList $range_objref vlanRange]
        set vlanList [lindex $vlanList 0]
       
        for {set i 0} {$i < $max_index} {incr i} {
            if {[info exists vlan_endpoint_args_$i]} {
                set result [ixNetworkNodeAdd $vlanList vlanIdInfo [set vlan_endpoint_args_$i] -$commit]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed while executing:\
                            ixNetworkNodeAdd $vlanList vlanIdInfo [set vlan_endpoint_args_$i] -$commit ($procName).\
                            [keylget result log]"
                    return $returnList
                }
            }
        }
    }       
    
    if {$mode == "modify"} {
        set result [ixNetworkNodeSetAttr $range_objref $vlan_endpoint_args]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed while executing:\
                    ixNetworkNodeSetAttr $range_objref $vlan_endpoint_args ($procName).\
                    [keylget result log]"
            return $returnList
        }
         
        set vlanIdInfoList [ixNet getList $vlanList vlanIdInfo]
        for {set i 0} {$i < $max_index} {incr i} {
            set vlanIdInfo [lindex $vlanIdInfoList $i]
            set result [ixNetworkNodeSetAttr $vlanIdInfo [set vlan_endpoint_args_$i]]
                        
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed while executing:\
                        ixNetworkNodeSetAttr $vlanList vlanIdInfo [set vlan_endpoint_args_$i] ($procName).\
                        [keylget result log]"
                return $returnList
            }
        }
        
        keylset returnList status $::SUCCESS
        keylset returnList handle $range_objref
    }
    return $returnList
}

proc ::ixia::ixNetworkStaticEndpointPvcRangeCfg { args } {
    set procName [lindex [info level [info level]] 0]
    
    set opt_args {
        -mode           CHOICES create modify 
                        DEFAULT create
        -vci
        -vci_count
        -vci_step
        -addresses_per_vci
        -vpi
        -vpi_count
        -vpi_step
        -addresses_per_vpi
        -pvc_incr_mode
        -range_objref
        -commit              CHOICES commit no_commit
                             DEFAULT commit
    }

    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing ($procName). $parse_error"
        return $returnList
    }
    
    if {[regexp {^::ixNet::OBJ-/vport:[0-9]+/protocolStack/ethernet:} $range_objref]} {
        keylset returnList status $::SUCCESS
        keylset returnList handle $range_objref
        return $returnList
    }
    
    array set translate {
        vpi  2
        vci  0
        both 1
    }
    
    # Start creating list PVC options
    set pvc_endpoint_args [list -enabled true]
    
    # List of global options for PVC enpoints
    set pvc_endpoint_options {
        vci                 vciFirstId          identity
        vci_count           vciUniqueCount      identity
        vci_step            vciIncrement        identity
        addresses_per_vci   vciIncrementStep    identity
        vpi                 vpiFirstId          identity
        vpi_count           vpiUniqueCount      identity
        vpi_step            vpiIncrement        identity
        addresses_per_vpi   vpiIncrementStep    identity
        pvc_incr_mode       incrementMode       translate
    }
    
    foreach {hlt_opt ixn_opt opt_type} $pvc_endpoint_options {
        if {[info exists $hlt_opt]} {
            switch $opt_type {
                identity {
                    lappend pvc_endpoint_args -$ixn_opt \
                            [set $hlt_opt]
                }
                translate {
                    if {[info exists translate([set $hlt_opt])]} {
                        lappend pvc_endpoint_args -$ixn_opt \
                                [set translate([set $hlt_opt])]
                    }
                }
                default {
                    lappend pvc_endpoint_args -$ixn_opt \
                            [set $hlt_opt]
                }
            }
        }
    }

    keylset returnList status $::FAILURE
    # Apply configurations
    if {$mode == "create"} {
        set pvcList [ixNet getList $range_objref pvcRange]
        if {$pvcList == ""} {
            set result [ixNetworkNodeAdd $range_objref pvcRange $pvc_endpoint_args -$commit]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed while executing:\
                        ixNetworkNodeAdd $range_objref pvcRange $pvc_endpoint_args ($procName).\
                        [keylget result log]"
                return $returnList
            }
            keylset returnList status $::SUCCESS
            keylset returnList handle [keylget result node_objref]
        } else {
            set result [ixNetworkNodeSetAttr [lindex $pvcList 0] $pvc_endpoint_args -$commit]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed while executing:\
                        ixNetworkNodeSetAttr [lindex $pvcList 0] $pvc_endpoint_args ($procName).\
                        [keylget result log]"
                return $returnList
            }
            keylset returnList status $::SUCCESS
            keylset returnList handle [lindex $pvcList 0]
        }
    }
    if {$mode == "modify"} {
        set result [ixNetworkNodeSetAttr $range_objref $pvc_endpoint_args]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed while executing:\
                    ixNetworkNodeSetAttr $range_objref $pvc_endpoint_args ($procName).\
                    [keylget result log]"
            return $returnList
        }
    
        keylset returnList status $::SUCCESS
        keylset returnList handle $range_objref
    }
    return $returnList
}


proc ::ixia::ixNetworkStaticEndpointIpRangeCfg { args } {
    set procName [lindex [info level [info level]] 0]
    
    set man_args {
        -range_objref
    }

    set opt_args {
        -mode           CHOICES create modify 
                        DEFAULT create
        -connected_count
        -gateway
        -gateway_step
        -intf_ip_addr
        -intf_ip_addr_step
        -netmask
        -ipv6_gateway
        -ipv6_gateway_step
        -ipv6_intf_addr
        -ipv6_intf_addr_step
        -ipv6_prefix_length
        -gateway_incr_mode
        -mss
        -src_mac_addr
        -commit              CHOICES commit no_commit
                             DEFAULT commit
    }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
                    $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing ($procName). $parse_error"
        return $returnList
    }
    
    if {$mode == "create"} {
        if {[info exists intf_ip_addr]} {
            set ip_type 4
        } else {
            set ip_type 6
        }
        
    }
    if {$mode == "modify"} {
        set ip_type [ixNet getAttribute $range_objref -ipType]
    }
    if {[info exists src_mac_addr]} {
        set auto_mac_generation 1
    }
    array set translate {
        every_subnet    perSubnet
        every_interface perInterface
        4               IPv4
        6               IPv6
    }
    
    # Start creating list ip options
    set ip_endpoint_args [list -enabled true]
    
    # List of global options for ip enpoints
    set ip_endpoint_options {
        ip_type                     ipType                  4_6     translate
        auto_mac_generation         autoMacGeneration       4_6     identity
        connected_count             count                   4_6     identity
        intf_ip_addr                ipAddress               4       identity
        ipv6_intf_addr              ipAddress               6       identity
        intf_ip_addr_step           incrementBy             4       identity
        ipv6_intf_addr_step         incrementBy             6       identity
        netmask                     prefix                  4       identity
        ipv6_prefix_length          prefix                  6       identity
        gateway                     gatewayAddress          4       identity
        gateway_step                gatewayIncrement        4       identity
        ipv6_gateway                gatewayAddress          6       identity
        ipv6_gateway_step           gatewayIncrement        6       identity
        gateway_incr_mode           gatewayIncrementMode    4_6     translate
        mss                         mss                     4_6     identity
    }
    
    if {[info exists netmask]} {
        # Switch from IP to length...
        set netmask [getIpV4MaskWidth $netmask]
    }

    foreach {hlt_opt ixn_opt opt_ip_type opt_type} $ip_endpoint_options {
        if {[info exists $hlt_opt] && ([lsearch [split $opt_ip_type _] $ip_type] != -1)} {
            switch $opt_type {
                identity {
                    lappend ip_endpoint_args -$ixn_opt \
                            [set $hlt_opt]
                }
                translate {
                    if {[info exists translate([set $hlt_opt])]} {
                        lappend ip_endpoint_args -$ixn_opt \
                                [set translate([set $hlt_opt])]
                    }
                }
                default {
                    lappend ip_endpoint_args -$ixn_opt \
                            [set $hlt_opt]
                }
            }
        }
    }

    keylset returnList status $::FAILURE
    # Apply configurations
    if {$mode == "create"} {
        set ipList [ixNet getList $range_objref ipRange]
        if {$ipList == ""} {
            set result [ixNetworkNodeAdd $range_objref ipRange $ip_endpoint_args -$commit]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed while executing:\
                        ixNetworkNodeAdd $range_objref ipRange $ip_endpoint_args ($procName).\
                        [keylget result log]"
                return $returnList
            }
            keylset returnList status $::SUCCESS
            keylset returnList handle [keylget result node_objref]
        } else {
            set result [ixNetworkNodeSetAttr [lindex $ipList 0] $ip_endpoint_args -$commit]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed while executing:\
                        ixNetworkNodeSetAttr [lindex $ipList 0] $ip_endpoint_args ($procName).\
                        [keylget result log]"
                return $returnList
            }
            keylset returnList status $::SUCCESS
            keylset returnList handle [lindex $ipList 0]
        }
    }
    if {$mode == "modify"} {
        set result [ixNetworkNodeSetAttr $range_objref $ip_endpoint_args]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed while executing:\
                    ixNetworkNodeSetAttr $range_objref $ip_endpoint_args ($procName).\
                    [keylget result log]"
            return $returnList
        }
    
        keylset returnList status $::SUCCESS
        keylset returnList handle $range_objref
    }
    return $returnList
}

proc ::ixia::ixNetworkAddIpEndpoint { args } {
    set procName [lindex [info level [info level]] 0]
    
    set man_args {
        -port_handle
    }
    set opt_args {
        -commit CHOICES 0 1 
                DEFAULT 0
    }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing ($procName). $parse_error"
        return $returnList
    }
    set retCode [ixNetworkGetPortObjref $port_handle]
    if {[keylget retCode status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to get port object reference for port $handle ($procName)."
        return $returnList
    }
    set vport_objref [keylget retCode vport_objref]
    set intf_type [ixNet getAttribute $vport_objref -type]
    switch -- $intf_type {
        "atm" {
            set type atm
        }
        "ethernet" {
            set type ethernet
        }
        "tenGigLan" {
            set type ethernet
        }
        "tenGigWan" {
            set type ethernet
        }
        "pos" {
            set type ethernet
        }
        default {
            set type ethernet
        }
    }
    
    set result [ixNetworkGetSMPlugin $vport_objref $type "ipEndpoint"]
    if {[keylget result status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName : [keylget result log]"
        return $returnList
    }
    
    set ip_objref [keylget result ret_val]
    
    set range_objref     [ixNet getList $ip_objref range]
    if {$range_objref == ""} {
        set range_objref [ixNet add $ip_objref range]
    }
#     set l2_objref    [ixNet add $vport_objref/protocolStack $type]
#     set ip_objref    [ixNet add $l2_objref ipEndpoint]
#     set range_objref [ixNet add $ip_objref range]
    
    if {$commit} {
        if {[set retCode [ixNet commit]] != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to add IP endpoint port\
                    $port_handle ($procName). $retCode."
            return $returnList
        }
        set l2_objref    [ixNet remapIds $l2_objref]
        set ip_objref    [ixNet remapIds $ip_objref]
        set range_objref [ixNet remapIds $range_objref]
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList handle $range_objref
    return $returnList
}


proc ::ixia::ixNetworkEvalCmd {cmd {expected_ret_val ""} } {
    
    keylset returnList status $::SUCCESS
    
    if {[catch {eval $cmd} out]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Low level call '$cmd' returned: $out."
        return $returnList
    }
    
    if {$expected_ret_val == "ok"} {
        if {$out != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Low level call '$cmd' returned: $out."
            return $returnList
        }
    } elseif {[llength $expected_ret_val] != 0} {
        if {$out != $expected_ret_val} {
            keylset returnList status $::FAILURE
            keylset returnList log "Low level call '$cmd' failed. Expected return value is '$expected_ret_val'.\
                    Actual return value is '$out'."
            return $returnList
        }
    }
    
    keylset returnList ret_val $out
    return $returnList
}


proc ::ixia::ixNetworkSplitPgidConfig {} {
    
    variable egress_tracking_global_array_legacy
    
    # Configure Egress tracking
    keylset returnList status $::SUCCESS
    
    if {![info exists egress_tracking_global_array_legacy] ||\
            [array get egress_tracking_global_array_legacy] == ""} {
        
        return $returnList
    }
    
    foreach port_objref [array names egress_tracking_global_array_legacy] {
        
        set egress_tracking_global_string_legacy $egress_tracking_global_array_legacy($port_objref)
        
        set pgid_mode [keylget egress_tracking_global_string_legacy pgid_mode]
        
        # Enable egress tracking
        set result [ixNetworkNodeSetAttr [ixNet getRoot]traffic     \
                        [list -flowMeasurementMode "splitPGID"]     \
                        -commit                                     ]
        
        if {[keylget result status] == $::FAILURE} {
            keylset returnList log "Failed to enable Egress Tracking\
                    - [keylget result log]"
            keylset returnList status $::FAILURE
            return $returnList
        }
        
        # Determine which is the port that we'll configure with egress tracking
        set found 0
        set port_obj_id [ixNet getA $port_objref -internalId]
        foreach egress_candidate [ixNet getList [ixNet getRoot]traffic/splitPgidSettings setting] {
            set port_name [ixNet getA $egress_candidate -portId]
    #             10.205.19.231:03:03-Ethernet
            if {$port_name == "ports.$port_obj_id"} {
                set found 1
                break
            }
        }
        
        if {!$found} {
            keylset returnList log "Failed to enable Egress Tracking on port $port_handle.\
                    The port could not be found in the Egress Tracking port list. Global\
                    tracking might have not been enabled."
            keylset returnList status $::FAILURE
            return $returnList
        }
        
        if {$pgid_mode == "split"} {
            
            set tracking_encap          ${egress_candidate}/encapsulation:\"None\"
            set tracking_predef_offset  ${egress_candidate}/predefinedOffset:\"Custom\"
            
            # custom width and offset
            set egress_trk_pmap {
                tracking_encap                  encapsulation
                tracking_predef_offset          predefinedOffset
                pgid_split1_offset              customOffset
                pgid_split1_width               customWidth
            }
            
            if {![catch {keylget egress_tracking_global_string_legacy pgid_split1_offset} err]} {
                set pgid_split1_offset $err
            }
            
            if {![catch {keylget egress_tracking_global_string_legacy pgid_split1_width} err]} {
                set pgid_split1_width $err
            }
            
        } else {
            
            # determine port mode and encapsulation
            set tracking_encap [keylget egress_tracking_global_string_legacy tracking_encap]
            
            array set translate_encap {    
                LLCRoutedCLIP               {encapsulation:"LLC/Snap Routed Protocol"}
                LLCPPPoA                    {encapsulation:"LLC Encapsulated PPP"}
                LLCBridgedEthernetFCS       {encapsulation:"LLC Bridged Ethernet/802.3"}
                LLCBridgedEthernetNoFCS     {encapsulation:"LLC Bridged Ethernet/802.3 no FCS"}
                VccMuxPPPoA                 {encapsulation:"VC Multiplexed PPP"}
                VccMuxIPV4Routed            {encapsulation:"VC Mux Routed Protocol"}
                VccMuxBridgedEthernetFCS    {encapsulation:"VC Mux Bridged Ethernet/802.3"}
                VccMuxBridgedEthernetNoFCS  {encapsulation:"VC Mux Bridged Ethernet/802.3 no FCS"}
                ethernet                    {encapsulation:"Ethernet"}
                pos_ppp                     {encapsulation:"PPP"}
                pos_hdlc                    {encapsulation:"CISCO HDLC"}
                frame_relay1490             {encapsulation:"Frame Relay"}
                frame_relay2427             {encapsulation:"Frame Relay"}
                frame_relay_cisco           {encapsulation:"Cisco Frame Relay"}
            }
            
            set tracking_encap ${egress_candidate}/$translate_encap($tracking_encap)
            if {[lsearch [ixNet getList $egress_candidate encapsulation] $tracking_encap] == -1} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to configure Egress tracking with $tracking_encap.\
                        Port $port_handle does not support egress tracking using this encapsulation."
                return $returnList
            }
            
            array set translate_offset {    
                outer_vlan_priority         {predefinedOffset:"Outer VLAN Priority (3 bits)"}
                outer_vlan_id_4             {predefinedOffset:"Outer VLAN ID (4 bits)"}
                outer_vlan_id_6             {predefinedOffset:"Outer VLAN ID (6 bits)"}
                outer_vlan_id_8             {predefinedOffset:"Outer VLAN ID (8 bits)"}
                outer_vlan_id_10            {predefinedOffset:"Outer VLAN ID (10 bits)"}
                outer_vlan_id_12            {predefinedOffset:"Outer VLAN ID (12 bits)"}
                inner_vlan_priority         {predefinedOffset:"Inner VLAN Priority (3 bits)"}
                inner_vlan_id_4             {predefinedOffset:"Inner VLAN ID (4 bits)"}
                inner_vlan_id_6             {predefinedOffset:"Inner VLAN ID (6 bits)"}
                inner_vlan_id_8             {predefinedOffset:"Inner VLAN ID (8 bits)"}
                inner_vlan_id_10            {predefinedOffset:"Inner VLAN ID (10 bits)"}
                inner_vlan_id_12            {predefinedOffset:"Inner VLAN ID (12 bits)"}
                mplsExp                     {predefinedOffset:"MPLS Exp (3 bits)"}
                tos_precedence              {predefinedOffset:"IPv4 TOS Precedence (3 bits)"}
                dscp                        {predefinedOffset:"IPv4 DSCP (6 bits)"}
                ipv6TC                      {predefinedOffset:"IPv6 Traffic Class (8 bits)"}
                ipv6TC_bits_0_2             {predefinedOffset:"IPv6 Traffic Class Bits 0-2 (3 bits)"}
                ipv6TC_bits_0_5             {predefinedOffset:"IPv6 Traffic Class Bits 0-5 (6 bits) "}
            }
            
            set tracking_predef_offset ${egress_candidate}/$translate_offset($pgid_mode)
            if {[lsearch [ixNet getList $egress_candidate predefinedOffset] $tracking_predef_offset] == -1} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to configure Egress tracking with $tracking_predef_offset.\
                        Port $port_handle does not support egress tracking using this predefined offset."
                return $returnList
            }
            
            set egress_trk_pmap {
                tracking_encap              encapsulation
                tracking_predef_offset      predefinedOffset
            }
        }
        
        set egress_trk_args ""
        foreach {hlt_p ixn_p} $egress_trk_pmap {
            if {[info exists $hlt_p]} {
                
                if {$hlt_p == "pgid_split1_offset"} {
                    set $hlt_p [mpexpr [set $hlt_p] * 8]
                }
                
                append egress_trk_args "-$ixn_p \{[set $hlt_p]\} "
            }
        }
        
        if {$egress_trk_args != ""} {
            set result [ixNetworkNodeSetAttr                                \
                            [ixNet getList $egress_candidate component]     \
                            $egress_trk_args -commit                        ]
                            
            if {[keylget result status] == $::FAILURE} {
                keylset returnList log "Failed to configure Egress Tracking on port $port_handle\
                        - [keylget result log]"
                keylset returnList status $::FAILURE
                return $returnList
            }
        }
        
        
        catch {unset pgid_split1_offset}
        catch {unset pgid_split1_width}
        catch {unset egress_tracking_global_array_legacy($port_objref)}
    }
    
    return $returnList
}


proc ::ixia::ixNetworkPortIsConnected {vportObjRef} {
    
    # 0 - port is released
    # 1 - port is connected
    
    if {[ixNet getAttribute $vportObjRef -connectionInfo] == ""} {
        return 0
    } else {
        return 1
    }
}


proc ::ixia::ixNetworkPortIsDecoupled {vportObjRef} {
    
    # 0 - Vport to Real port association still exists
    # 1 - Vport to Real port association was deleted
    
    if {[ixNet getAttribute $vportObjRef -connectedTo] == [ixNet getNull]} {
        return 1
    } else {
        return 0
    }
}


proc ::ixia::ixNetworkBuildRp2VpArray {} {
    
    # Build an array indexed by Real ports (ch/ca/po)
    # Values are actual port handles in HLT (vch/vca/vpo)
    
    keylset returnList status $::SUCCESS
    
    variable ixnetwork_chassis_list
    variable ixnetwork_port_handles_array
    variable ixnetwork_rp2vp_handles_array
    
    catch {array unset ixnetwork_rp2vp_handles_array}
    array set ixnetwork_rp2vp_handles_array ""
    
    foreach vport_handle [array names ixnetwork_port_handles_array] {
        
        set vport_obref $ixnetwork_port_handles_array($vport_handle)
        
        set connected_hw [ixNet getA $vport_obref -connectedTo]
        
        if {![regexp {^(::ixNet::OBJ-/availableHardware/chassis:")(.+)("/card:)(\d+)(/port:)(\d+)$}\
                $connected_hw {} {} ch_ip {} ca {} po]} {
            continue
        }
        
        # If the user gave in a hostname instead of an ip we must find the ip
        if {![catch {keylget ::ixia::hosts_to_ips $ch_ip}]} {
            set ch_ip [keylget ::ixia::hosts_to_ips $ch_ip]
        }
        
        set ixn_index  [lsearch -regexp $ixnetwork_chassis_list $ch_ip]
        if {$ixn_index == -1} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to create internal mapping array real ports (ch/ca/po)\
                    to virtual ports (vch/vca/vpo). Could not find chassis with ip $ch_ip in\
                    internal list ixnetwork_chassis_list. Possible cause: virtual port $vport_obref\
                    was not connected using ::ixia::connect procedure (it was connected from GUI)."
            return $returnList
        }
        
        set ch_idx [lindex [lindex $ixnetwork_chassis_list $ixn_index] 0]
        
        set ixnetwork_rp2vp_handles_array($ch_idx/$ca/$po) $vport_handle
    }
    
    return $returnList
}


proc ::ixia::ixNetworkExec { args {enable_object_name ""}} {
    
    set exec_type      [lindex $args 0]
    set exec_object    [lindex $args 1]
    
    
    set async_flag 0
    
    # Uncomment this code when bug BUG584563 is resolved
    if {[lindex $args end] == "async"} {
        set async_flag 1
        set args [lreplace $args end end]
    }
    
    set skip_enable_check 0
    
    if {[llength $enable_object_name] == 0} {
        if {[regexp {^(::ixNet::OBJ-/vport:\d+/protocols/[a-zA-Z]+)(/)(.*)$} $exec_object {} enable_object]} {
            # If we're dealing with vport/protocols then we should inspect the object right
            # after protocols
            # The enable object is in 'enable_object' variable
        } else {
            # It's a protocolStack object
            
            if {[regexp {^::ixNet::OBJ-/vport:\d+/protocolStack/(ethernet|atm):[^/]+/pppoxEndpoint:[^/]+/range:[^/]+$} \
                    $exec_object]} {
                
                # If it's a ppp range object we must check the pppoxRange object
                set enable_object [lindex [ixNet getList $exec_object pppoxRange] 0]
                
            } elseif {[regexp {^::ixNet::OBJ-/vport:\d+/protocolStack/(ethernet|atm):[^/]+/ip:[^/]+/l2tpEndpoint:[^/]+/range:[^/]+$} \
                    $exec_object]} {
                
                # If it's a l2tp range object we must check the l2tpRange object
                set enable_object [lindex [ixNet getList $exec_object l2tpRange] 0]
                
            } elseif {[regexp {^::ixNet::OBJ-/vport:\d+/protocolStack/(ethernet|atm):[^/]+/pppox:[^/]+/dhcpoPppClientEndpoint:[^/]+/range:[^/]+$} \
                    $exec_object]} {
                
                # If it's a dhcpOppp range object we must check the pppoxRange object
                set enable_object [lindex [ixNet getList $exec_object pppoxRange] 0]
                
            } else {
                
                # Recurse in object path until we find an object with "enabled" attribute
                # Assume it's not deeper than 50 objects in the object path because
                # i want to avoid while 
                
                set tmp_object $exec_object
                set found 0
                
                for {set depth 50} {$depth > 0} {incr depth -1} {
                    if {![catch {ixNet getAttribute $tmp_object -enabled} ena_val] && \
                            [regexp -nocase {(true)|(false)} $ena_val]} {
                        set found 1
                        break
                    }
                    set tmp_object2 [ixNetworkGetParentObjref $tmp_object]
                    if {$tmp_object2 == $tmp_object} {
                        # no more objects to inspect
                        break
                    }
                    
                    set tmp_object $tmp_object2
                }
                
                if {$found} {
                    set enable_object $tmp_object
                }
            }
        }
        
    } else {
        set enable_object [ixNetworkGetParentObjref $exec_object $enable_object_name]
    }
    
    if {(![info exists enable_object]) || ([llength $enable_object] == 0) ||\
            $enable_object == [ixNet getNull]} {
        
        set skip_enable_check 1
        debug "ixNetworkExec  --> !!! Skipping enabled check for object $exec_object - ixNet exec $args !!! <--"
    }
    
    if {!$skip_enable_check} {
        switch -- $exec_type {
            "start" {
                if {[ixNet getAttribute $enable_object -enabled] != "true"} {
                    # Exit from procedure here. Do not perform exec
                    debug "ixNetworkExec -> Object $enable_object is not enabled. Skipping 'ixNet exec $args'"
                    return ::ixNet::OK
                }
            }
            default {
                if {[ixNet getAttribute $enable_object -enabled] != "true"} {
                    # Exit from procedure here. Do not perform exec
                    debug "ixNetworkExec -> Object $enable_object is not enabled. Skipping 'ixNet exec $args'"
                    return ::ixNet::OK
                }
            }
        } ; # end switch
        debug "ixNetworkExec -> Object $enable_object is enabled. Performing 'ixNet exec $args'"
    }
    if {$async_flag} {
        set cmd "ixNet -async exec $args"
    } else {
        set cmd "ixNet exec $args"
    }
    
    debug $cmd
    set retVal [eval $cmd]
    if {$async_flag} {
        if {[regexp {::ixNet::RESULT-} $retVal]} {
            ::ixia::async_operations_array_add $exec_object $exec_type $retVal
            set retVal "::ixNet::OK"
        }
    }
    
    return $retVal
    # Procedure does not catch errors. Call procedure in catch block
    
} ; # end proc


proc ::ixia::ixNetworkGetNextVportHandle {{real_port_handle "_default"}} {
    
    # This procedure will provide a valid virtual port handle for a given 
    # real port handle.
    # If real_port_handle is free it will return $real_port_handle
    # else if real_port_handle is already connected return the vport_handle
    # else (not connected but vport_handle $real_port_handle already in use)
    #     generate a new 0/0/$vp_id handle
    
    variable ixnetwork_port_handles_array
    variable ixnetwork_rp2vp_handles_array
    
    if {$real_port_handle == "_default"} {
        set next_id [ixNetworkGetNextAvailableVportId]
        return 0/0/$next_id
    }
    
    if {![info exists ixnetwork_port_handles_array($real_port_handle)]} {
        # A vport_handle identical to $real_port_handle does not exist (as strings)
        
        # Make sure that this $real_port_handle isn't already connected but with another vport_handle
        if {[info exists ixnetwork_rp2vp_handles_array($real_port_handle)]} {
            # Real port $real_port_handle is already connected. Return vport_handle
            return $ixnetwork_rp2vp_handles_array($real_port_handle)
        } else {
            # String $real_port_handle isn't used as virtual port handle or real port handle
            return $real_port_handle
        }
    } else {
        # A vport_handle identical to $real_port_handle (as strings) exist
        # This means one of 2 things:
            # 1. real_port_handle is already connected
            # 2. a vport handle identical to $real_port_handle exists, but it's connected 
                # to another port. In this case generate a new port handle
        
        if {[info exists ixnetwork_rp2vp_handles_array($real_port_handle)]} {

            # Case 1
            return $ixnetwork_rp2vp_handles_array($real_port_handle)

        } else {
            # Case 2
            set next_id [ixNetworkGetNextAvailableVportId]
            return 0/0/$next_id
        }
    }
}

proc ::ixia::ixNetworkGetNextAvailableVportId {} {
    
    # Gets the next virtual port internal Id. It is used the making of
    # vport handle 0/0/$internal_id
    
    set last_vport [lindex [ixNet getL [ixNet getRoot] vport] end]
    if {[llength $last_vport] < 1} {
        # No vports exist. The first id will be 1
        set vp_id 1
    } else {
        set vp_id [mpexpr [ixNet getA $last_vport -internalId] + 1]
    }
    
    return $vp_id
}


# returns a keyed list with the stack_type (ethernet|atm) sm stacks and the plugins (if any)
# configured on them
# Also returns summary:
#       0 - stack_type does not exist
#       1 - stack_type exists but it doesn't have any plugins configured
#       2 - stack_type exists with a plugin (but not one specified with plugin_filter)
#       3 - stack_type exists with the plugin specified in plugin_filter

proc ::ixia::ixNetworkValidateSMPlugins {vport_handle stack_type plugin_filter} {
    
    keylset returnList status $::SUCCESS
    
    switch -- $stack_type {
        ethernetEndpoint -
        ethernet -
        atm {
            set base_stack $stack_type
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed in ixNetworkValidateSMPlugins. Invalid stack_type '$stack_type'."
            return $returnList
        }
    }
    
    set vport_handle [ixNetworkGetParentObjref $vport_handle "vport"]
    
    array set all_plugins {
        ipEndpoint          {atm ethernet}
        dhcpServerEndpoint  {atm ethernet}
        dhcpEndpoint        {atm ethernet}
        pppoxEndpoint       {atm ethernet}
        pppox               {atm ethernet}
        dcbxEndpoint        {ethernet}
        fcoeFwdEndpoint     {ethernet}
        fcoeClientEndpoint  {ethernet}
        fcFwdEndpoint       {fc}
        fcClientEndpoint    {fc}
    }
    
    set plugin_index [lsearch [array names all_plugins] $plugin_filter]
    if {$plugin_index != -1} {
        # Remove plugin filter from all plugins list
        unset all_plugins($plugin_filter)
    }
    
    set ret_code [ixNetworkEvalCmd [list ixNet getL $vport_handle/protocolStack $base_stack]]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed in ixNetworkValidateSMPlugins. [keylget ret_code log]"
        return $returnList
    }
    
    set base_stack_list [keylget ret_code ret_val]
    if {[llength $base_stack_list] == 0} {
        # No stacks exist
        keylset returnList summary 0
        return $returnList
    }
    
    # Browse all stacks. Discover the plugins they have (if any)
    set summary 1
    
    if {$plugin_filter != "none"} {
        foreach stack $base_stack_list {
            set ret_code [ixNetworkEvalCmd [list ixNet getL $stack $plugin_filter]]
            if {[keylget ret_code status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed in ixNetworkValidateSMPlugins. [keylget ret_code log]"
                return $returnList
            }
            
            # Check if plugin_filter plugin exists on this stack
            set tmp_plugin [keylget ret_code ret_val]
            if {$tmp_plugin != [ixNet getNull] && [llength $tmp_plugin] > 0} {
                set summary 3
                keylset returnList summary $summary
                keylset returnList ret_val $tmp_plugin
                return $returnList
            }
            
            # Check if any plugin exists
            foreach plugin_item [array names all_plugins] {
                if {[lsearch $all_plugins($plugin_item) $stack_type] == -1} {continue}
                set ret_code [ixNetworkEvalCmd [list ixNet getL $stack $plugin_item]]
                if {[keylget ret_code status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed in ixNetworkValidateSMPlugins. [keylget ret_code log]"
                    return $returnList
                }
                
                set tmp_plugin [keylget ret_code ret_val]
                if {$tmp_plugin != [ixNet getNull] && [llength $tmp_plugin] > 0} {
                    set summary 2
                }
            }
            
            if {$summary == 1} {
                # No plugins exist on this stack. Save it
                set empty_stack $stack
            }
            
        }
    } else {
        # Not intrested in the endpoint children. I just want the base stack (added for ethernetEndpoint base stack)
    }
    
    
    if {[info exists empty_stack]} {
        keylset returnList summary 1
        keylset returnList ret_val $empty_stack
    } else {
        keylset returnList summary 2
    }
    
    return $returnList
}



proc ::ixia::ixNetworkGetSMPlugin {port_handle stack_type plugin_filter} {
    
    keylset returnList status $::SUCCESS
    
    set port_handle [ixNetworkGetParentObjref $port_handle "vport"]
    
    set ret_code [ixNetworkValidateSMPlugins $port_handle $stack_type $plugin_filter]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    switch -- [keylget ret_code summary] {
        0 -
        2 {
            # 0 - stack_type does not exist, create it
            # 2 - stack_type exists with a plugin (but not one specified with plugin_filter)
            #       we need a new one for our configuration
            set result [::ixia::ixNetworkNodeAdd \
                    $port_handle/protocolStack     \
                    $stack_type      \
                    {}               \
                    -commit          \
                    ]
            if {[keylget result status] != $::SUCCESS} {
                return $result
            }
            set stack_objref [keylget result node_objref]

        }
        1 {
            # stack_type exists but it doesn't have any plugins configured; use it
            set stack_objref [keylget ret_code ret_val]
        }
        3 {
            # stack_type exists with the plugin specified in plugin_filter
            # return it
            keylset returnList ret_val [keylget ret_code ret_val]
            return $returnList
        }
    }
    
    if {$plugin_filter != "none"} {
        set result [::ixia::ixNetworkNodeAdd \
                $stack_objref     \
                $plugin_filter    \
                {}                \
                -commit           \
                ]
        if {[keylget result status] != $::SUCCESS} {
            return $result
        }
        
        keylset returnList ret_val [keylget result node_objref]
    } else {
        # plugin_filter "none" means that i only want the base stack object, not the plugin
        # added for ethernetEndpoint base stack (ixnetwork sm static endpoints feature
        keylset returnList ret_val $stack_objref
    }
    return $returnList
}


proc ::ixia::ixNetworkIsCommitNeeded {objref attributes_list} {
    # objref - ixnetwork object
    # attributes list - list with elements "-attr_name1 attr_value1 -attr_name2 attr_value2...."
    # The procedure checks if the properties attr_name* from objref have the same values
    #       as attr_value*
    # If the values are the same, the procedure returns 0 - commit is not needed because
    #       there will not be any changes
    # If at least one of the values is different the procedure returns 1 - commit is needed
    #       because there will be changes done to the object
    
    set commit_needed 0
    
    set objref [ixNet remapIds $objref]
    
    if {[regexp {:L\d+} $objref]} {
        # It's a temporary object and commit is needed
        return 1
    }
    
    foreach {attr_name attr_value} $attributes_list {
        if {[ixNetworkGetAttr $objref $attr_name] != $attr_value} {
            set commit_needed 1
            break
        }
    }
    
    return $commit_needed
}


proc ::ixia::ixNetworkGetVportByName {port_name} {
    
    keylset returnList status $::SUCCESS
    
    foreach vport_obj [ixNet getList [ixNet getRoot] vport] {
        if {[ixNet getA $vport_obj -name] == $port_name} {
            set vport_found $vport_obj
            break
        }
    }
    
    if {[info exists vport_found]} {
        set vport_handle $vport_found
        set ret_code [ixNetworkGetPortFromObj $vport_handle]
        if {[keylget ret_code status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to ixNetworkGetVportByName $port_name.\
                    [keylget ret_code log]"
            return $returnList
        }
        
        set port_handle [keylget ret_code port_handle]
        
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to ixNetworkGetVportByName $port_name.\
                There are no ports with name '$port_name'"
        return $returnList
    }
    
    keylset returnList port_handle $port_handle
    keylset returnList vport_handle $vport_handle
    return $returnList
}


proc ::ixia::ixNetworkTrafficExec {action} {
    keylset returnList status $::SUCCESS
    
    set trafficState ""
    
    catch {set trafficState [ixNet getAttribute [ixNet getRoot]traffic -state]}
    
    switch $trafficState {
        error                   {}
        locked          {
            keylset returnList status $::FAILURE
            keylset returnList log "Cannot $action traffic at this moment,\
                    please try again in a few moments."
            return $returnList
        }
        started                   -
        startedWaitingForStreams  -
        startedWaitingForStats {
            if {[regexp {^start} $action]} {
                keylset returnList status $::SUCCESS
                return $returnList
            }
        }
        stopped                -
        txStopWatchExpected    -
        stoppedWaitingForStats {
            if {[regexp {^stop} $action]} {
                keylset returnList status $::SUCCESS
                return $returnList
            }
        }
        txStopWatchExpected     {
            keylset returnList status $::SUCCESS
            return $returnList
        }
        unapplied               {}
        default                 {}
    }
    
    foreach action_item $action {
        debug "ixNet exec $action_item [ixNet getRoot]traffic"
        if {[catch {ixNet exec $action_item [ixNet getRoot]traffic} retCode]} {
            keylset returnList status $::FAILURE
            keylset returnList log "$retCode"
            return $returnList
        }
    }
    return $returnList
}


proc ::ixia::ixNetworkVportIsReady {vport_obj} {
    variable connect_timeout
    keylset returnList status $::SUCCESS
    
    for {set retry 0} {$retry < $connect_timeout} {incr retry} {
        if {![catch {ixNet getAttr $vport_obj -state} state] && $state != "busy" &&\
                ![catch {ixNet getAttr $vport_obj -stateDetail} stateDetail] && $stateDetail == "idle"} {
            
            if {$state == "versionMismatch"} {
                keylset returnList status $::FAILURE
                keylset returnList log "State for $vport_obj is versionMismatch. Please check\
                        if the IxNetwork version from the chassis is the same with the\
                        IxNetwork version from the client machine"
                return $returnList
            }
           
            if {[ixNet getAttr $vport_obj -isMapped]== "true"} {
                if {[ixNet getA $vport_obj -isConnected] == "false"} {
                    #keylset returnList log "Port $vport_obj is not connected - [ixNet getA $vport_obj -connectionStatus]"
                    #keylset returnList status $::FAILURE
                    #return $returnList
                    debug "Port $vport_obj is [ixNet getA $vport_obj -connectionStatus]"
                    break
                }
                if {$state != "unassigned"} {
                    # port is ready and link is either Up or Down so no need to wait anymore
                    debug "Port $vport_obj is $state"
                    break
                }
            } else {
                #port is vport (not mapped)
                debug "Port $vport_obj is not mapped. Will not wait to become ready."
                break
            }
        }
        debug "Waiting 1s for port $vport_obj to become ready..."
        after 1000
    }
    
    if {$state != "busy" && $stateDetail == "idle"} {
        return $returnList
    } else {
        keylset returnList status $::FAILURE
        set error "Failed while waiting for port $vport_obj. State is '$state'."
        if {[info exists stateDetail]} { 
            append error " State detailed is: $stateDetail.[ixNet getA $vport_obj -connectionStatus]"
        }
        keylset returnList log $error 
        return $returnList
    }  
}


proc ::ixia::ixnetwork_wait_pending_operations {handles_list pending_operations_timeout} {
    
    keylset returnList status $::SUCCESS
        
    set start_time [clock seconds]
    while {[expr [clock seconds] - $start_time] < $pending_operations_timeout} {
        
        set operations_ok 1
        
        foreach ixn_handle $handles_list {
            set ret_code [async_operations_array_get_status $ixn_handle]
            if {[keylget ret_code operation_status] > 0} {
                set operations_ok 0
                break
            }
        }
        
        if {$operations_ok} {
            break
        }
        after 1000
    }
    
    if {!$operations_ok} {
        
        set operations_ok 1; # last chance
        
        set err_msg "Pending operations detected:"
        foreach ixn_handle $handles_list {
            set ret_code [async_operations_array_get_status $ixn_handle]
            if {[keylget ret_code operation_status] > 0} {
                
                set operations_ok 0
                
                foreach pending_handle [keylkeys ret_code operations_pending] {
                    append err_msg " '[keylget ret_code operations_pending.$pending_handle]'\
                            on $pending_handle;"
                }
            }
        }
    }
    
    if {!$operations_ok} {
        keylset returnList status $::FAILURE
        keylset returnList log $err_msg
    }
    
    return $returnList
}


proc ::ixia::ixNetworkGetObjWithShape {obj_shape all_ixn_objects_array_ref {parent_obj {::ixNet::OBJ-/}} {current_index {0}}} {
    upvar 1 $all_ixn_objects_array_ref all_ixn_objects_array
    
    set current_obj_item [lindex [split $obj_shape /] $current_index]
    if {![catch {ixNet getList $parent_obj $current_obj_item} child_obj_list]} {
        if {[info exists child_obj_list] && [llength $child_obj_list] > 0} {
            if {$current_index == [expr [llength [split $obj_shape /]] - 1]} {
                # last element in object shape. add children to keys array

                if {[info exists all_ixn_objects_array($obj_shape)]} {
                    foreach child_obj $child_obj_list {
                        lappend all_ixn_objects_array($obj_shape) $child_obj
                    }
                    
                    set all_ixn_objects_array($obj_shape) [lsort -unique $all_ixn_objects_array($obj_shape)]
                } else {
                    set all_ixn_objects_array($obj_shape) $child_obj_list
                }
                
                lappend obj_shape_children $child_obj_list
            } else {
                foreach child_obj $child_obj_list {
                    ixNetworkGetObjWithShape $obj_shape all_ixn_objects_array $child_obj [expr $current_index+1]
                }
            }
        }
    }
}


proc ::ixia::ixNetworkGetPortFilterName {port_handle} {
    
    # Get vport
    set result [ixNetworkGetPortObjref $port_handle]
    if {[keylget result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Could not find any vport which uses\
                the $port_handle port - [keylget result log]."
        return $returnList
    }
    
    set port_objref [keylget result vport_objref]
    
    set internal_id [ixNetworkGetAttr $port_objref -internalId]
    set name        [ixNetworkGetAttr $port_objref -name]
    
    keylset returnList status $::SUCCESS
    keylset returnList port_filter_name "${internal_id}:${name}"
    return $returnList
    
}


proc ::ixia::ixNetworkSetAggregatedMode {realPortList aggregation_mode} {
    
    variable connect_timeout
    variable ixnetwork_chassis_list
    
    keylset returnList status $::SUCCESS
    
    if {([llength $aggregation_mode] == 1) && [llength $realPortList]>1} {
        set all_agg_mode ""
        foreach real_port $realPortList {
            lappend all_agg_mode $aggregation_mode
        }
    } else {
        set all_agg_mode $aggregation_mode
    }
    unset ::ixia::aggregation_mode
    
    array set processed_cards ""
    array set processed_chassis ""
    
    set modified_ports ""
    
    array set translate_mode_ixn2hlt {
        normal                  normal
        notSupported            not_supported
        mixed                   mixed
        tenGigAggregation       ten_gig_aggregation
        threeByTenGigFanOut     three_by_ten_gig_fan_out
        fourByTenGigFanOut      four_by_ten_gig_fan_out
        oneByTenGigFanOut       ten_gig_fan_out
        eightByTenGigFanOut     eight_by_ten_gig_fan_out
        fortyGigAggregation     forty_gig_aggregation
        fortyGigFanOut          forty_gig_fan_out
        fortyGigNonFanOut       forty_gig_normal_mode
        hundredGigNonFanOut     hundred_gig_non_fan_out
        singleMode              single_mode_aggregation
        dualMode                dual_mode_aggregation
    }
    
    array set translate_mode_hlt2ixn {
        normal                   normal
        not_supported            notSupported
        mixed                    mixed
        ten_gig_aggregation      tenGigAggregation
        ten_gig_fan_out          oneByTenGigFanOut
        three_by_ten_gig_fan_out threeByTenGigFanOut
        four_by_ten_gig_fan_out  fourByTenGigFanOut
        eight_by_ten_gig_fan_out eightByTenGigFanOut     
        forty_gig_aggregation    fortyGigAggregation
        forty_gig_fan_out        fortyGigFanOut
        forty_gig_normal_mode    fortyGigNonFanOut
        hundred_gig_non_fan_out  hundredGigNonFanOut
        single_mode_aggregation  singleMode
        dual_mode_aggregation    dualMode
    }
        
    set commit_needed 0
    foreach realPort $realPortList local_agg_mode $all_agg_mode {
        
        if {$local_agg_mode == "mixed" || $local_agg_mode == "not_supported"} {
            continue        
        }
        
        regexp {^(\d+)/(\d+)/(\d+)$} $realPort {} chassis_id card_id port_id
        
        if {[info exists processed_cards(${chassis_id}/${card_id})]} {
            continue
        }
        
        set processed_cards(${chassis_id}/${card_id}) 1
        
        if {[info exists processed_chassis($chassis_id)]} {
            set hostname $processed_chassis($chassis_id)
        } else {
            set hostname [::ixia::getHostname $ixnetwork_chassis_list $chassis_id]
            
            if {$hostname == -1} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to find the a chassis with id $chassis_id."
                return $returnList
            }
        }
        
        set processed_chassis($chassis_id) $hostname
        
        # Find the objref of real card
        set realCardObjRef ::ixNet::OBJ-/availableHardware/chassis:\"$hostname\"/card:$card_id
              
        set card_type [ixNet getA $realCardObjRef -description]   
     
        if {[catch {ixNet getA $realCardObjRef -aggregationSupported} out] || $out == "false"} {
            puts "WARNING! Card $card_type does not support aggregation! aggregation_mode $local_agg_mode will be ignored."
            continue
        }
        
        set currentMode [ixNetworkGetAttr $realCardObjRef -aggregationMode]
        set currentSupportedModes [ixNetworkGetAttr $realCardObjRef -availableModes]
        debug "Searching for $local_agg_mode / $translate_mode_hlt2ixn($local_agg_mode) in $currentSupportedModes"
        if {[lsearch $currentSupportedModes $translate_mode_hlt2ixn($local_agg_mode)] == -1} {
            keylset returnList status $::FAILURE
            keylset returnList log "$local_agg_mode aggregation mode is unsupported for $card_type ($realCardObjRef)."
            return $returnList
        }
        
        if {    ($currentMode != "") && \
                [info exists translate_mode_ixn2hlt($currentMode)] && \
                ($translate_mode_ixn2hlt($currentMode) == $local_agg_mode)} {
            continue
        }
        
        lappend modified_ports ::ixNet::OBJ-/availableHardware/chassis:\"$hostname\"/card:$card_id/port:$port_id
        
        if {![info exists translate_mode_hlt2ixn($local_agg_mode)]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Invalid aggregation mode($local_agg_mode) for $realCardObjRef."
            return $returnList
        }
        ixNetworkSetAttr $realCardObjRef -aggregationMode $translate_mode_hlt2ixn($local_agg_mode)
        set commit_needed 1
    }
    
    if {$commit_needed} {
        if {[catch {set retCode [ixNet commit]} retError]} {
            keylset returnList status $::FAILURE
            if {[regexp "Ports owned by other users" $retError]} {
                keylset returnList log "Failed to change card -aggregation_mode to $local_agg_mode. \
                        Parameter -aggregation_mode will change the aggregation mode for the entire card. \
                        You must clear ownership on all ports previous to connecting from HLT or provide at \
                        least one port from each resource group in the card to ::ixia::connect -port_list. \
                        If you need to change the aggregation on a per port (or resource group) basis, \
                        please use -aggregation_resource_mode parameter instead of aggregation_mode. $retError"
            } else {
                keylset returnList log "Failed to change card aggregation_mode to $local_agg_mode. $retError"
            }
            return $returnList
        } elseif {$retCode != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to change card aggregation_mode to $local_agg_mode. $retCode"
            return $returnList
        }
    }
    
    # Wait for hardware to become available
    set hw_ready_start_time [clock seconds]
    for {set ahw_it 0} {$ahw_it < [expr $connect_timeout * 2]} {incr ahw_it} {
        
        set break_all 0
        set hw_ready 1

        foreach realPortObjRef $modified_ports {

            if {[ixNet getAttr $realPortObjRef -isBusy] == "true"} {
                set hw_ready 0
                break
            } else {
                # Check if the port if in the correct aggregation mode
                debug "Checking if port is usable in the current aggregation mode"
                if {![ixNet getAttribute $realPortObjRef -isUsable]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR: $realPortObjRef port is not usable!\
                            Please check that the current aggregation mode of the card\
                            or the resource is valid for this port type"
                    return $returnList
                }
            }
            
            if {[expr [clock seconds] - $hw_ready_start_time] > $connect_timeout} {
                # The total amount of wait time for ALL ports must not exceed $connect_timeout
                set break_all 1
                break
            }
        }
        
        if {$break_all || $hw_ready} {
            break
        }
        
        after 500
    }
    
    if {!$hw_ready} {
        keylset returnList status $::FAILURE
        keylset returnList log "Timeout while changing aggregated mode: ports are not ready after\
                $connect_timeout seconds. The timeout can be configured using the\
                parameter -connect_timeout"
        return $returnList
    }
    
    return $returnList
}


proc ::ixia::ixNetworkSetResourceAggregatedMode {port_handle_list aggregation_resource_mode} {
    
    variable connect_timeout
    variable ixnetwork_chassis_list
    variable aggregation_mode
    
    keylset returnList status $::SUCCESS
    if {([llength $aggregation_resource_mode] == 1) && [llength $port_handle_list]>1} {
        set local_aggregation_mode ""
        foreach real_port $port_handle_list {
            lappend local_aggregation_mode $aggregation_resource_mode
        }
    } else {
        set local_aggregation_mode $aggregation_resource_mode
    }
    unset ::ixia::aggregation_resource_mode
    
    array set processed_cards ""
    array set processed_chassis ""
    
    set modified_ports ""
    
    array set translate_mode_ixn2hlt {
        normal                  normal
        tenGig                  ten_gig_aggregation
        threeByTenGigFanOut     three_by_ten_gig_fan_out
        fourByTenGigFanOut      four_by_ten_gig_fan_out
        oneByTenGigFanOut       ten_gig_fan_out
        eightByTenGigFanOut     eight_by_ten_gig_fan_out
        fortyGig                forty_gig_aggregation
        fortyGigFanOut          forty_gig_fan_out
        fortyGigNonFanOut       forty_gig_normal_mode
        hundredGigNonFanOut     hundred_gig_non_fan_out
        singleMode              single_mode_aggregation
        dualMode                dual_mode_aggregation
    }
    
    array set translate_mode_hlt2ixn {
        normal                   normal
        ten_gig_aggregation      tenGig
        ten_gig_fan_out          oneByTenGigFanOut
        three_by_ten_gig_fan_out threeByTenGigFanOut
        four_by_ten_gig_fan_out  fourByTenGigFanOut
        eight_by_ten_gig_fan_out eightByTenGigFanOut 
        forty_gig_aggregation    fortyGig
        forty_gig_fan_out        fortyGigFanOut
        forty_gig_normal_mode    fortyGigNonFanOut
        hundred_gig_non_fan_out  hundredGigNonFanOut
        single_mode_aggregation  singleMode
        dual_mode_aggregation    dualMode
    }

    set commit_needed 0
    foreach port $port_handle_list local_aggr_res_mode $local_aggregation_mode {
        
        if {$local_aggr_res_mode == "not_supported"} {continue}
        foreach {chassis_id card_id port_id} [split $port /] {}
        # get the chassis hostname or ip      
        set hostname [::ixia::getHostname $ixnetwork_chassis_list $chassis_id]
            
        if {$hostname == -1} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to find the a chassis with id $chassis_id."
            return $returnList
        }
        
        set current_card "[ixNet getRoot]availableHardware/chassis:\"$hostname\"/card:$card_id"
        set card_type [ixNet getA $current_card -description]
        
        if {![info exists translate_mode_hlt2ixn($local_aggr_res_mode)]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Invalid aggregation mode($local_aggr_res_mode) for $current_card."
            return $returnList
        }
        
        if {[catch {ixNet getA $current_card -aggregationSupported} out] || $out == "false"} {
            if {$local_aggr_res_mode != "normal" } {
                puts "WARNING! $current_card does not support aggregation! aggregation_resource_mode $local_aggr_res_mode will be ignored."
            }
            continue
        }
        
        set verifiy_port [::ixia::verify_port_aggregation $card_type $port $local_aggr_res_mode $translate_mode_hlt2ixn($local_aggr_res_mode)]
        if {[keylget verifiy_port status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Error setting aggregation mode on $port. [keylget verifiy_port log]"
            return $returnList
        }
        set aggregation_obj_list $::ixia::aggregation_map($current_card)
        if { [info exists ::ixia::aggregation_map($current_card,$port_id)] } {
            set agg_item $::ixia::aggregation_map($current_card,$port_id)
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "The port $port_id from card $current_card does not exist in the available ports list\
                    for the current aggregation mode."
            return $returnList
        }
        set currentMode [ixNetworkGetAttr $agg_item -mode]
        if {    ($currentMode!= "") && \
                [info exists translate_mode_ixn2hlt($currentMode)] && \
                ($translate_mode_ixn2hlt($currentMode) == $local_aggr_res_mode)} {
            continue
        }
        ixNetworkSetAttr $agg_item -mode $translate_mode_hlt2ixn($local_aggr_res_mode)
        lappend modified_ports ${current_card}/port:$port_id
        set commit_needed 1
    }
    
    if {$commit_needed} {
        if {[set retCode [ixNet commit]] != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to change card aggregation aggregation_resource_mode to $local_aggr_res_mode"
            return $returnList
        }
    }
    
    set hw_ready_start_time [clock seconds]
    for {set ahw_it 0} {$ahw_it < [expr $connect_timeout * 2]} {incr ahw_it} {
        
        set break_all 0
        set hw_ready 1

        foreach realPortObjRef $modified_ports {

            if {[ixNet getAttr $realPortObjRef -isBusy] == "true"} {
                set hw_ready 0
                break
            } else {
                # Check if the port if in the correct aggregation mode
                debug "Checking if port is usable in the current aggregation mode"
                if {![ixNet getAttribute $realPortObjRef -isUsable]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR: $realPortObjRef port is not usable!\
                            Please check that the current aggregation mode of the card\
                            or the resource is valid for this port type"
                    return $returnList
                }
            }
            
            if {[expr [clock seconds] - $hw_ready_start_time] > $connect_timeout} {
                # The total amount of wait time for ALL ports must not exceed $connect_timeout
                set break_all 1
                break
            }
        }
        
        if {$break_all || $hw_ready} {
            break
        }
        
        after 500
    }
    
    if {!$hw_ready} {
        keylset returnList status $::FAILURE
        keylset returnList log "Timeout while changing card aggregation mode: ports are not ready after\
                $connect_timeout seconds. The timeout can be configured using the\
                parameter -connect_timeout"
        return $returnList
    }
    
    return $returnList
}


proc ::ixia::ixNetworkEnablePing {vport_list} {
    
    keylset returnList status $::SUCCESS
    
    foreach real_port_tmp $vport_list {
        set retCode [ixNetworkNodeSetAttr \
                $real_port_tmp/protocols/ping {-enabled true}]
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to enable PING on vport\
                    $real_port_tmp. [keylget retCode log]"
            return $returnList
        }
    }
    return $returnList
}

proc ::ixia::ixNetworkEnableArp {vport_list} {
    
    keylset returnList status $::SUCCESS
    
    foreach real_port_tmp $vport_list {
        set retCode [ixNetworkNodeSetAttr \
                $real_port_tmp/protocols/arp {-enabled true}]
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to enable ARP on vport\
                    $real_port_tmp. [keylget retCode log]"
            return $returnList
        }
    }
    return $returnList
}


proc ::ixia::ixNetworkIsOwnershipTaken {realPort} {
    # realPort is ch/ca/po
    variable ixnetwork_chassis_list
    
    set root [ixNet getRoot]
    
    regexp {^(\d+)/(\d+)/(\d+)$} $realPort {} chassis_id card_id port_id
    set hostname [::ixia::getHostname $ixnetwork_chassis_list $chassis_id]
    
    if {$hostname == -1} {
        return 0
    }
    
    # Find the objref of real port.
    set realPortObjRef ::ixNet::OBJ-/availableHardware/chassis:\"$hostname\"/card:$card_id/port:$port_id
    set owner [ixNet getA $realPortObjRef -owner]
    set ixn_owner [ixNet getA ${root}/globals -username]
    if {$owner != $ixn_owner} {
        return 0
    }
    
    return 1
}
proc ::ixia::ixNetworkIsDone {exec_object} {
    foreach exec_object_ele $exec_object {
        set cmd "ixNet isDone $exec_object_ele"
        set retVal [eval $cmd]
        if {$retVal == "false"} {
            keylset returnList $exec_object_ele $retVal
        } else {
            catch {ixNet getResult $exec_object_ele} retVal
            keylset returnList $exec_object_ele $retVal
        }
    }
    return $returnList
}

proc ::ixia::set_license_servers {} {
    uplevel 1 {
        if {[info exists ixnetwork_license_servers]} {
                set ixn_l [ixNet getA [ixNet getRoot]/globals/licensing -licensingServers]
                set ixn_m [ixNet getA [ixNet getRoot]/globals/licensing -mode]
                set ixn_t [ixNet getA [ixNet getRoot]/globals/licensing -tier]
                set release_required 0
                if { $ixn_l != $ixnetwork_license_servers} {
                    debug "Setting license server to $ixnetwork_license_servers from $ixn_l"
                    ixNet setA [ixNet getRoot]/globals/licensing -licensingServers $ixnetwork_license_servers
                    set release_required 1
                }
                set license_type_and_tier [split $ixnetwork_license_type _]
                if { $ixn_m != [lindex $license_type_and_tier 0]} {
                    debug "Setting license server mode to [lindex $license_type_and_tier 0] from $ixn_m"
                    ixNet setA [ixNet getRoot]/globals/licensing -mode [lindex $license_type_and_tier 0]
                    set release_required 1
                }
                if {[llength $license_type_and_tier] == 2 && $ixn_t != [lindex $license_type_and_tier 1] } {
                    debug "Setting license server tier to [lindex $license_type_and_tier 1] from $ixn_t"
                    ixNet setA [ixNet getRoot]/globals/licensing -tier [lindex $license_type_and_tier 1]
                }
                if { $release_required == 1 } {
                    debug "Commiting license changes..."
                    ixNet exec releaseAllPorts
                     foreach vport [ixNet getL / vport] {
                        for {set i 0} {$i < 30} {incr i} {
                            if {[ixNet getA $vport -isMapped] == "false" || ([ixNet getA $vport -state] != "busy" && [ixNet getA $vport -isConnected] == "false")} {
                                break
                            }
                            after 1000
                        }
                    }
                    ixNet commit
                    ixNet exec connectAllPorts
                    foreach vport [ixNet getL / vport] {
                        for {set i 0} {$i < 30} {incr i} {
                            if {[ixNet getA $vport -isMapped] == "false" || ([ixNet getA $vport -state] != "busy" && [ixNet getA $vport -isConnected] == "true")} {
                                break
                            }
                            if {[ixNet getA $vport -isMapped] == "true" && ([ixNet getA $vport -state] != "busy" && [ixNet getA $vport -isConnected] == "false")} {
                                break
                            }
                            after 1000
                        }
                    }
                }

            }
    }
}

proc ::ixia::ixNetworkControlIndividualTrafficTtem {action handle} {
    keylset returnList status $::SUCCESS

    array set action_map {
        stopStatelessTraffic    stopped
        startStatelessTraffic   started
    }
    
    array set action_map_app_lib {
        stopStatelessTraffic    Configured
        startStatelessTraffic   Running
    }
    
    foreach traffic_handle $handle {
        set tmp_handle [::ixia::540getTrafficItemByName $traffic_handle]
        # Check if traffic_handle is trafficItem name or ixNet handle
        if {$tmp_handle == "_none"} {
            set traffic_handle [::ixia::ixNetworkGetParentObjref $traffic_handle trafficItem]
        } else {
            set traffic_handle $tmp_handle
        }
        if {[regexp {::ixNet::OBJ-/traffic/trafficItem:[0-9]+} $traffic_handle traffic_item]} {
            # the given handle is correct
            set trafficItemType [ixNet getAttr $traffic_item -trafficItemType]
            if {$trafficItemType != "l2L3" && $trafficItemType != "applicationLibrary"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to start traffic configuration.\
                        The traffic item correponding to the \"$traffic_handle\" handle \
                        is not a L2-L3 traffic item or a L4-7 AppLibrary traffic item."
                return $returnList
            }
            switch -- $trafficItemType {
                "l2L3" {
                    if {[ixNet getAttr $traffic_item -state] != $action_map($action)} {
                        set exec true
                        set no_retries 0
                        while { $exec } {
                            incr no_retries
                            if {[catch {ixNet exec $action $traffic_item} error]} {
                                if {[string first "::ixNet::ERROR-7007-Could not start or stop transmit" $error] >= 0} {
                                    after 500
                                    continue
                                }
                                keylset returnList status $::FAILURE
                                keylset returnList log "Failed to start traffic configuration $error on $traffic_handle"
                                return $returnList
                            } else {
                                break
                            }
                            if { $no_retries == 10 } {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Failed to start $traffic_item."
                                return $returnList
                            }
                        }
                    }
                }
                "applicationLibrary" {
                    set app_lib_profile [ixNet getL $traffic_item appLibProfile]
                    if {[ixNet getAttr $app_lib_profile -trafficState] != $action_map_app_lib($action)} {
                        set exec true
                        set no_retries 0
                        while { $exec } {
                            incr no_retries
                            set ret_val [regsub -all {StatelessTraffic} $action "" l47_action] 
                            if {[catch {ixNet exec $l47_action $app_lib_profile} error]} {
                                if {[string first "::ixNet::ERROR-7007-Could not $l47_action transmit" $error] >= 0} {
                                    after 500
                                    continue
                                }
                                keylset returnList status $::FAILURE
                                keylset returnList log "Failed to $l47_action traffic configuration $error on $traffic_handle"
                                return $returnList
                            } else {
                                break
                            }
                            if { $no_retries == 10 } {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Failed to $l47_action $traffic_item."
                                return $returnList
                            }
                        }
                    }
                }
            }
        } else {;# The given handle is not valid
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to start traffic configuration. \
                    \"$traffic_handle\" is not a valid traffic item."
            return $returnList
        }
    }
    return $returnList
}
