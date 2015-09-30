proc ::ixia::ixnetwork_elmi_info { args opt_args } {

    if {[catch {::ixia::parse_dashed_args \
            -args           $args         \
            -optional_args  $opt_args     \
            } parseError]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$parseError."
        return $returnList
    }
    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    
    if {[info exists port_handle]} {
        set uni_handles ""
        set port_handles   ""
        set port_objrefs   ""
        foreach {port} $port_handle {
            set retCode [ixNetworkGetPortObjref $port]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            set vport_objref [keylget retCode vport_objref]
            lappend port_objrefs $vport_objref
            set protocol_objref $vport_objref/protocols/elmi
            set uni_objref [ixNet getList $protocol_objref uni]
            lappend uni_handles $uni_objref
            for {set i 0} {$i < [llength $uni_objref]} {incr i} {
                lappend port_handles $port
            }    
        }
        if {$uni_handles == "" } {
            keylset returnList status $::FAILURE
            keylset returnList log "There are no UNI on the ports\
                    provided through -port_handle."
            return $returnList
        }
    }
    if {[info exists handle]} {
        set port_handles   ""
        set port_objrefs   ""
        foreach {_handle} $handle {
            if {![regexp {^(.*)/protocols/elmi/uni:\d$} $_handle {} port_objref]} {
                keylset returnList status $::FAILURE
                keylset returnList log "The handle $handle is not a valid\
                        ELMI uni handle."
                return $returnList
            }
            set retCode [ixNetworkGetPortFromObj $_handle]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            lappend port_handles  [keylget retCode port_handle]
            lappend port_objrefs  [keylget retCode vport_objref]
        }
        set uni_handles $handle
    }
    if {$mode == "clear_stats"} {
        foreach {port} $port_handles {
            debug "ixNet exec clearStats"
            if {[set retCode [catch {ixNet exec clearStats} retCode]]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to clear statistics."
                return $returnList
            }
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }

    if {[lempty $uni_handles]} {
        keylset returnList status $::FAILURE
        keylset returnList log "No ELMI uni found on specified\
                -port_handle/-handle parameter."
        return $returnList
    }
    
    if {$mode == "evc_status_learned_info" || $mode == "uni_learned_info"} {
        set evc_stats_list {
            cbs_multiplier              cbsMultiplier
            cbs_magnitude               cbsMagnitude
            cf                          cf
            cir_multiplier              cirMultiplier
            cir_magnitude               cirMagnitude
            cm                          cm
            default_evc                 defaultEvc
            ebs_multiplier              ebsMultiplier
            ebs_magnitude               ebsMagnitude
            eir_multiplier              eirMultiplier
            eir_magnitude               eirMagnitude
            evc_id_length               evcIdLength
            evc_id                      evcId
            evc_type                    evcType
            per_cos                     perCos
            reference_id                referenceId
            status_type                 statusType
            un_tagged_priority_tag      untaggedPriorityTag
            user_priority_bits_000      userPriorityBits000
            user_priority_bits_001      userPriorityBits001
            user_priority_bits_010      userPriorityBits010
            user_priority_bits_011      userPriorityBits011
            user_priority_bits_100      userPriorityBits100
            user_priority_bits_101      userPriorityBits101
            user_priority_bits_110      userPriorityBits110
            user_priority_bits_111      userPriorityBits111
            vlan_id                     vlanId
        }            
        foreach {_handle} $uni_handles {port_handle} $port_handles {
            # refresh evc learned info
            debug "ixNet exec refreshEvcStatusLearnedInfo $_handle"
            set retCode [ixNet exec refreshEvcStatusLearnedInfo $_handle]
            if {[string first "::ixNet::OK" $retCode] == -1 } {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to refresh learned info for\
                        ELMI evc status $_handle."
                return $returnList
            }
            # retry for 10 times
            set retries 10
            while {[ixNet getAttribute $_handle -isEvcStatusLearnedInfoRefreshed] != "true"} {
                after 500
                incr retries -1
                if {$retries < 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Refreshing learned info for\
                            ELMI evc status $_handle has timed out.\
                            Please try again later."                    
                    return $returnList
                }
            }
            
            #retreive evc learned info list for the given uni handle
            set evc_learned_info_list [ixNet getList $_handle evcStatusLearnedInfo]

            #collect learned info for each evc learned info object
            foreach evc_learned_info $evc_learned_info_list {
                foreach {hlt_stat ixn_stat} $evc_stats_list {
                    debug "ixNet getAttribute $evc_learned_info -$ixn_stat"
                    if [catch {set stat_value [ixNet getAttribute $evc_learned_info -$ixn_stat ]}] {
                        set stat_value "N/A"
                    }
                    keylset returnList $port_handle.$_handle.$evc_learned_info.$hlt_stat $stat_value
                    
                }
            }
        }
    }


    if {$mode == "uni_status_learned_info" || $mode == "uni_learned_info"} {
        set uni_status_stats_list {
            cbs_multiplier              cbsMultiplier
            cbs_magnitude               cbsMagnitude
            cf                          cf
            cir_multiplier              cirMultiplier
            cir_magnitude               cirMagnitude
            cm                          cm
            ebs_multiplier              ebsMultiplier
            ebs_magnitude               ebsMagnitude
            eir_multiplier              eirMultiplier
            eir_magnitude               eirMagnitude
            evc_map_type                evcMapType
            per_cos                     perCos
            uni_id_length               uniIdLength
            uni_id                      uniId
            user_priority_bits_000      userPriorityBits000
            user_priority_bits_001      userPriorityBits001
            user_priority_bits_010      userPriorityBits010
            user_priority_bits_011      userPriorityBits011
            user_priority_bits_100      userPriorityBits100
            user_priority_bits_101      userPriorityBits101
            user_priority_bits_110      userPriorityBits110
            user_priority_bits_111      userPriorityBits111
         }            
        foreach {_handle} $uni_handles {port_handle} $port_handles {
            # refresh evc learned info
            debug "ixNet exec refreshUniStatusLearnedInfo $_handle"
            set retCode [ixNet exec refreshUniStatusLearnedInfo $_handle]
            if {[string first "::ixNet::OK" $retCode] == -1 } {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to refresh learned info for\
                        ELMI uni status $_handle."
                return $returnList
            }
            # retry for 10 times
            set retries 10
            while {[ixNet getAttribute $_handle -isUniStatusLearnedInfoRefreshed] != "true"} {
                after 500
                incr retries -1
                if {$retries < 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Refreshing learned info for\
                            ELMI uni status $_handle has timed out.\
                            Please try again later."                    
                    return $returnList
                }
            }
            
            #retreive uni status learned info list for the given uni handle
            set uni_status_learned_info_list [ixNet getList $_handle uniStatusLearnedInfo]
            
            #collect learned info for each uni status learned info object
            foreach uni_status_learned_info $uni_status_learned_info_list {
                foreach {hlt_stat ixn_stat} $uni_status_stats_list {
                    debug "ixNet getAttribute $uni_status_learned_info -$ixn_stat"
                    if [catch {set stat_value [ixNet getAttribute $uni_status_learned_info -$ixn_stat ]}] {
                        set stat_value "N/A"
                    }
                    keylset returnList $port_handle.$_handle.$uni_status_learned_info.$hlt_stat $stat_value
                    
                }
            }
        }
    } 

    if {$mode == "lmi_status_learned_info" || $mode == "uni_learned_info"} {
        set lmi_stats_list {
            data_instance               dataInstance
            duplicated_ie               duplicatedIe
            invalid_evc_reference_id    invalidEvcReferenceId
            invalid_mandatory_ie        invalidMandatoryIe
            invalid_msg_type            invalidMsgType
            invalid_non_mandatory_ie    invalidNonMandatoryIe
            invalid_protocol_version    invalidProtocolVersion
            lmi_status                  lmiStatus
            mandatory_ie_missing        MandatoryIeMissing
            out_of_sequence_ie          OutOfSequenceIe
            protocol_version            protocolVersion
            receive_sequence_number     receiveSequenceNumber
            send_sequence_number        sendSequenceNumber
            short_msg_counter           shortMsgCounter
            unexpected_ie               unexpectedIe
            uncrecognized_ie            uncrecognizedIe
        }            
        foreach {_handle} $uni_handles {port_handle} $port_handles {
            # refresh lmi learned info
            debug "ixNet exec refreshLmiStatusLearnedInfo $_handle"
            set retCode [ixNet exec refreshLmiStatusLearnedInfo $_handle]
            if {[string first "::ixNet::OK" $retCode] == -1 } {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to refresh learned info for\
                        ELMI Lmi status $_handle."
                return $returnList
            }
            # retry for 10 times
            set retries 10
            while {[ixNet getAttribute $_handle -isLmiStatusLearnedInfoRefreshed] != "true"} {
                after 500
                incr retries -1
                if {$retries < 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Refreshing learned info for\
                            ELMI Lmi status $_handle has timed out.\
                            Please try again later."                    
                    return $returnList
                }
            }
            
            #retreive lmi status learned info list for the given uni handle
            set lmi_status_learned_info_list [ixNet getList $_handle lmiStatusLearnedInfo]

            #collect learned info for each lmi status learned info object
            foreach lmi_status_learned_info $lmi_status_learned_info_list {
                foreach {hlt_stat ixn_stat} $lmi_stats_list {
                    debug "ixNet getAttribute $lmi_status_learned_info -$ixn_stat"
                    if [catch {set stat_value [ixNet getAttribute $lmi_status_learned_info -$ixn_stat ]}] {
                        set stat_value "N/A"
                    }
                    keylset returnList $port_handle.$_handle.$lmi_status_learned_info.$hlt_stat $stat_value
                    
                }
            }
        }
    }

    if {$mode == "aggregate"} {
        array set stats_array_aggregate {
            "Port Name"
            port_name
            "UNI-C Configured"
            uni_c_configured
            "UNI-C Running"
            uni_c_running
            "UNI-N Configured"
            uni_n_configured
            "UNI-N Running"
            uni_n_running
            "Session Operational"
            session_operational
            "Session Flap"
            session_flap
            "Check Tx"
            check_tx
            "Check Rx"
            check_rx
            "Full Status Enquiry Tx"
            full_status_enquiry_tx
            "Full Status Enquiry Rx"
            full_status_enquiry_rx
            "Full Status Tx"
            full_status_tx
            "Full Status Rx"
            full_status_rx
            "Full Status Continued Enquiry Tx"
            full_status_continued_enquiry_tx
            "Full Status Continued Enquiry Rx"
            full_status_continued_enquiry_rx
            "Full Status Continued Tx"
            full_status_continued_tx
            "Full Status Continued Rx"
            full_status_continued_rx
            "Single EVC Asynchronous Status Tx"
            single_evc_asynchronous_status_tx
            "Single EVC Asynchronous Status Rx"
            single_evc_asynchronous_status_rx
            "UNI Status Tx"
            uni_status_tx
            "UNI Status Rx"
            uni_status_rx
            "EVC Status Tx"
            evc_status_tx
            "EVC Status Rx"
            evc_status_rx
            "CE-VLAN ID/EVC MAP Tx"
            ce_vlan_id_evc_map_tx
            "CE-VLAN ID/EVC MAP Rx"
            ce_vlan_id_evc_map_rx
            "Remote Protocol Version"
            remote_protocol_version
            "Invalid Message Type Rx"
            invalid_message_type_rx
            "Out of Sequence IE Rx"
            out_of_sequence_ie_rx
            "Duplicated IE Rx"
            duplicated_ie_rx
            "Mandatory IE Missing Rx"
            mandatory_ie_missing_rx
            "Invalid Mandatory IE Rx"
            invalid_mandatory_ie_rx
            "Unrecognized IE Rx"
            unrecognized_ie_rx
            "Unexpected IE Rx"
            unexpected_ie_rx
            "Short Message Rx"
            short_message_rx
            "Unsolicited Status Rx"
            unsolicited_status_rx
            "Invalid Status Rx"
            invalid_status_rx
        }
        
        set statistic_types {
            aggregate "ELMI Aggregated Statistics"
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
                            keylset returnList ${port_key}.${stat_type}.$stats_array($stat) \
                                    $rows_array($i,$stat)
                        } else {
                            keylset returnList ${port_key}.${stat_type}.$stats_array($stat) "N/A"
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
    }    

    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::ixnetwork_elmi_control {args opt_args} {
    
    if {[catch {::ixia::parse_dashed_args -args $args \
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
            lappend protocol_objref_list $protocol_objref/protocols/elmi
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
            set protocol_objref [ixNetworkGetProtocolObjref $_handle elmi]
            if {$protocol_objref != [ixNet getRoot]} {
                lappend protocol_objref_list $protocol_objref
            }
        }
        if {$protocol_objref_list == "" } {
            keylset returnList status $::FAILURE
            keylset returnList log "All handles provided through -handle\
                    parameter are invalid."
            return $returnList
        }
    }
    
    # Check link state
    foreach protocol_objref $protocol_objref_list {
        regexp {(::ixNet::OBJ-/vport:\d).*} $protocol_objref {} vport_objref
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
            keylset returnList log "Failed to $mode ELMI on the $vport_objref\
                    port. Port state is $portState, $portStateD."
            return $returnList
        }
    }
    
    if {$mode == "restart"} {
        set operations [list stop start]
    } else {
        set operations $mode
    }
    foreach operation $operations {
        foreach protocol_objref $protocol_objref_list {
            debug "ixNetworkExec [list $operation $protocol_objref]"
            if {[catch {ixNetworkExec [list $operation $protocol_objref]} retCode] || \
                    ([string first "::ixNet::OK" $retCode] == -1)} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to $operation ELMI on the\
                        $vport_objref port. Error code: $retCode."
                return $returnList
            }
        }
        after 1000
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

