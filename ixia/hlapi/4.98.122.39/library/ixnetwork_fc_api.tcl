proc ::ixia::ixnetwork_fc_client_config { args man_args opt_args} {
    set procName [lindex [info level [info level]] 0]
    ::ixia::utrackerLog $procName $args
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args $man_args \
                -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    keylset returnList status $::SUCCESS
    #translate array
    array set fc_client_translate_array {             \
            gid_a                  kGidA              \
            ga_nxt                 kGaNxt             \
            gpn_id                 kGpnId             \
            gid_pn                 kGidPn             \
            gnn_id                 kGnnId             \
            gid_pt                 kGidPt             \
            port_identifier        kPortIdentifier    \
            port_type              kPortType          \
            port_name              kPortName          \
            fabric_detected        kFabricDetected    \
            nxport_detected        kNXPortDetected    \
            all                    kAll               \
            one_to_one             one-to-one         \
            many_to_many           many-to-many       \
    }
    #fcClientFdiscRange
    set fcClientFdiscRange_param_map {
        count                           fdisc_count                               value
        name                            fdisc_name                                value
        enabled                         fdisc_enabled                             bool
        nameServerQuery                 fdisc_name_server_query                   bool
        nameServerQueryParameterValue   fdisc_name_server_query_parameter_value   value
        nameServerRegistration          fdisc_name_server_registration            bool
        nodeWwnIncrement                fdisc_node_wwn_increment                  value
        nodeWwnStart                    fdisc_node_wwn_start                      value
        overrideNodeWwn                 fdisc_node_wwn_override                   bool
        plogiDestId                     fdisc_plogi_dest_id                       value
        plogiEnabled                    fdisc_plogi_enabled                       bool
        plogiTargetName                 fdisc_plogi_target_name                   value
        portWwnIncrement                fdisc_port_wwn_increment                  value
        portWwnStart                    fdisc_port_wwn_start                      value
        prliEnabled                     fdisc_prli_enabled                        bool
        sourceOuiIncrement              fdisc_source_oui_increment                value
        stateChangeRegistration         fdisc_state_change_registration           bool
        nameServerQueryCommand          fdisc_name_server_query_command           translate
        nameServerQueryParameterType    fdisc_name_server_query_parameter_type    translate
        plogiMeshMode                   fdisc_plogi_mesh_mode                     translate
        stateChangeRegistrationOption   fdisc_state_change_registration_option    translate
    }
    set para_map_fdisc [::ixia::ixNetworkmapping $args $man_args $opt_args fc_client_translate_array $fcClientFdiscRange_param_map]
    #fcClientFlogiRange 
    set fcClientFlogiRange_param_map {
        count                           flogi_count                               value
        name                            flogi_name                                value
        nameServerQuery                 flogi_name_server_query                   bool
        nameServerQueryParameterValue   flogi_name_server_query_parameter_value   value
        nameServerRegistration          flogi_name_server_registration            bool
        nodeWwnIncrement                flogi_node_wwn_increment                  value
        nodeWwnStart                    flogi_node_wwn_start                      value
        plogiDestId                     flogi_plogi_dest_id                       value
        plogiEnabled                    flogi_plogi_enabled                       bool
        plogiTargetName                 flogi_plogi_target_name                   value
        portWwnIncrement                flogi_port_wwn_increment                  value
        portWwnStart                    flogi_port_wwn_start                      value
        prliEnabled                     flogi_prli_enabled                        bool
        sourceOuiIncrement              flogi_source_oui_increment                value
        stateChangeRegistration         flogi_state_change_registration           bool
        nameServerQueryCommand          flogi_name_server_query_command           translate
        nameServerQueryParameterType    flogi_name_server_query_parameter_type    translate
        plogiMeshMode                   flogi_plogi_mesh_mode                     translate
        stateChangeRegistrationOption   flogi_state_change_registration_option    translate
        }
    set para_map_flogi [::ixia::ixNetworkmapping $args $man_args $opt_args fc_client_translate_array $fcClientFlogiRange_param_map]

# Command add
    if {$mode == "add"} {
        if {![info exists port_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName:\
                    On -mode $mode, parameter -port_handle must be provided."
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
    # Add port
        set return_status [ixNetworkPortAdd $port_handle {} force]
        if {[keylget return_status status] != $::SUCCESS} {
            return $return_status
        }
        set result [ixNetworkGetPortObjref $port_handle]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName :Unable to find the port \
                    object reference associated to the $port_handle port handle -\
                    [keylget result log]."
            return $returnList
        }
        set port_handle [keylget result vport_objref]/protocolStack
    # Need to add fc and put this in node_obj_ref
        if {[set node_objref [ixNet getList $port_handle fcClientEndpoint]] == ""} {
             set result [::ixia::ixNetworkNodeAdd \
                    $port_handle                  \
                    fcClientEndpoint              \
                    {}                            \
                    -commit                       \
                    ]
            if {[keylget result status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : [keylget result log]"
                return $returnList
            }
            set node_objref [keylget result node_objref]
        }
        set result [::ixia::ixNetworkNodeAdd \
                $node_objref                 \
                range                        \
                {}                           \
                -commit                      \
                ]
        if {[keylget result status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : [keylget result log]"
            ::ixia::ixnetwork_fc_rollback $node_objref $mode
            return $returnList
        }
        set handle [keylget result node_objref]
        if {[::ixia::ixNetworkNodeGetList $handle fcClientFdiscRange] == [ixNet getNull] ||\
                [::ixia::ixNetworkNodeGetList $handle fcClientFdiscRange] == ""} {
            set result [::ixia::ixNetworkNodeAdd          \
                    $handle                               \
                    fcClientFdiscRange                    \
                    [keylget para_map_fdisc handle]       \
                    -commit                               \
            ]
            if {[keylget result status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : [keylget result log]"
                return $returnList
            }
        } else {
            if {[llength [keylget para_map_fdisc handle]] > 0} {
                set result [::ixia::ixNetworkNodeSetAttr                          \
                        [::ixia::ixNetworkNodeGetList $handle fcClientFdiscRange] \
                        [keylget para_map_fdisc handle]                           \
                        -commit                                                  \
                ]
                if {[keylget result status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : [keylget result log]"
                    return $returnList
                }
            }
        }
        if {[::ixia::ixNetworkNodeGetList $handle fcClientFlogiRange] == [ixNet getNull] ||\
                [::ixia::ixNetworkNodeGetList $handle fcClientFlogiRange] == ""} {
            set result [::ixia::ixNetworkNodeAdd          \
                    $handle                               \
                    fcClientFlogiRange                    \
                    [keylget para_map_flogi handle]       \
                    -commit                               \
            ]
            if {[keylget result status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : [keylget result log]"
                return $returnList
            }
        } else {
            if {[llength [keylget para_map_flogi handle]] > 0} {
                set result [::ixia::ixNetworkNodeSetAttr \
                        [::ixia::ixNetworkNodeGetList $handle fcClientFlogiRange] \
                        [keylget para_map_flogi handle]                           \
                        -commit                                                   \
                ]
                if {[keylget result status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName : [keylget result log]"
                    return $returnList
                }
            }
        }
        keylset returnList status $::SUCCESS
        keylset returnList handle $handle
        return $returnList
    }
# End command add

# Command remove
    if {$mode == "remove"} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : \
                    -handle parameter missing when -mode is $mode."
            return $returnList
        }
        if {[::ixia::ixNetworkRemove $handle] != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : [ixNet remove $handle]"
            return $returnList
        }
        ::ixia::ixNetworkCommit
        keylset returnList status $::SUCCESS
        return $returnList
    }

    if {$mode == "modify"} {
        foreach handle_ele $handle {
            if {[llength [keylget para_map_fdisc handle]] > 0} {
                set attr_set [::ixia::ixNetworkNodeSetAttr     \
                        $handle_ele/fcClientFdiscRange         \
                        [keylget para_map_fdisc handle]        \
                ]
                if {[keylget attr_set status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "[keylget attr_set log]"
                    return $returnList
                }
            }
            if {[llength [keylget para_map_flogi handle]] > 0} {
                set attr_set [::ixia::ixNetworkNodeSetAttr     \
                        $handle_ele/fcClientFlogiRange         \
                        [keylget para_map_flogi handle]        \
                ]
                if {[keylget attr_set status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "[keylget attr_set log]"
                    return $returnList
                }
            }
        }
        ::ixia::ixNetworkCommit
        keylset returnList handle $handle
    }

# Command enable
    if {$mode == "enable"} {
        set enabled "-enabled true"
        foreach handle_ele $handle {
            set attr_set [::ixia::ixNetworkNodeSetAttr     \
                    $handle_ele/fcClientFlogiRange         \
                    $enabled                               \
                ]
            if {[keylget attr_set status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "[keylget attr_set log]"
                return $returnList
            }
        }
        ::ixia::ixNetworkCommit
        keylset returnList handle $handle
    }
# End enable

# Command disable
    if {$mode == "disable"} {
        set enabled "-enabled false"
        foreach handle_ele $handle {
            set attr_set [::ixia::ixNetworkNodeSetAttr     \
                    $handle_ele/fcClientFlogiRange         \
                    $enabled                               \
            ]
            if {[keylget attr_set status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "[keylget attr_set log]"
                return $returnList
            }
        }
        ::ixia::ixNetworkCommit
        keylset returnList handle $handle
    }
# End disable
    return $returnList
}
#End proc ::ixia::ixnetwork_fc_client_config

proc ::ixia::ixnetwork_fc_client_stats { args } {
    set args [lindex $args 0]
    variable executeOnTclServer

    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::ixnetwork_fc_client_stats $args\}]
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    set procName [lindex [info level [info level]] 0]
    ::ixia::utrackerLog $procName $args
    # Arguments
    set man_args {
        -mode         CHOICES aggregate session range
    }
    set opt_args {
        -handle       ANY
        -port_handle  ANY
    }
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    if {![info exists port_handle] && ![info exists handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "When -mode is $mode, one of the parameters\
                -port_handle or -handle must be provided."
        return $returnList
    }
    keylset returnList status $::SUCCESS
# Aggregate mode
    if {$mode == "aggregate"} {
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
        # Define the statistics to be gathered from the tables in the
        # stat view browser
        # Statistics
        array set stats_array_per_aggregate_ixn [list             \
                "port_name"               "Port Name"             \
                "fdisc_tx"                "FDISC Tx"              \
                "fdisc_ls_acc_rx"         "FDISC LS_ACC Rx"       \
                "fdisc_ls_rjt_rx"         "FDISC LS_RJT Rx"       \
                "flogi_tx"                "FLOGI Tx"              \
                "flogi_ls_acc_rx"         "FLOGI LS_ACC Rx"       \
                "flogi_ls_rjt_rx"         "FLOGI LS_RJT Rx"       \
                "f_bsy_rx"                "F_BSY Rx"              \
                "f_rjt_rx"                "F_RJT Rx"              \
                "flogo_tx"                "FLOGO Tx"              \
                "plogi_tx"                "PLOGI Tx"              \
                "plogi_requests_rx"       "PLOGI Requests Rx"     \
                "plogi_ls_acc_rx"         "PLOGI LS_ACC Rx"       \
                "plogi_ls_rjt_rx"         "PLOGI LS_RJT Rx"       \
                "plogo_tx"                "PLOGO Tx"              \
                "plogo_rx"                "PLOGO Rx"              \
                "ns_registration_tx"      "NS Registration Tx"    \
                "ns_registration_ok"      "NS Registration OK"    \
                "ns_queries_tx"           "NS Queries Tx"         \
                "ns_queries_ok"           "NS Queries OK"         \
                "scr_tx"                  "SCR Tx"                \
                "scr_acc_rx"              "SCR ACC Rx"            \
                "rscn_rx"                 "RSCN Rx"               \
                "rscn_acc_tx"             "RSCN ACC Tx"           \
                "prli_tx"                 "PRLI Tx"               \
                "prli_requests_rx"        "PRLI Requests Rx"      \
                "prli_ls_acc_rx"          "PRLI LS_ACC Rx"        \
                "prli_ls_rjt_rx"          "PRLI LS_RJT Rx"        \
                "interface_up"            "Interfaces Up"         \
                "interface_down"          "Interfaces Down"       \
                "inteface_fail"           "Interfaces Fail"       \
                "inteface_outstanding"    "Interfaces Outstanding"\
                "sessions_initiated"      "Sessions Initiated"    \
                "sessions_succeeded"      "Sessions Succeeded"    \
                "sessions_fail"           "Sessions Failed"       \
        ]
        set port_index 0
        foreach stat [array names stats_array_per_aggregate_ixn] {
            lappend stat_list_aggregate $stats_array_per_aggregate_ixn($stat)
        }
        set returned_stats_list [::ixia::ixNetworkGetStats \
                    "FC Client" $stat_list_aggregate]
        if {[keylget returned_stats_list status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to read the\
                         stat view browser -\
                        [keylget returned_stats_list log]"
                return $returnList
            }
        set enableStatus [::ixia::enableStatViewList {"FC Client"}]
        if {[keylget enableStatus status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Enable fail\
                   [keylget enableStatus log]"
            return $returnList
        }
        after 2000
        foreach port $port_handle {
            foreach port $port_handle {
                set ports($port) $port_index
                incr port_index
            }
            set row_count [keylget returned_stats_list row_count]
            array set rowsArray [keylget returned_stats_list statistics]
            for {set i 1} {$i <= $row_count} {incr i} {
                set row_name $rowsArray($i)
                set match [regexp {(.+)/Card([0-9]{2})/Port([0-9]{2})} \
                        $row_name match_name hostname cd pt]
                if {$match && [catch {set ch_ip [keylget ::ixia::hosts_to_ips $hostname]} err]} {
                    set ch_ip $hostname
                }
                if {$match && ($match_name == $row_name) && \
                        [info exists ch_ip] && \
                        [info exists cd] && \
                        [info exists pt] } {
                    set chassis_no [::ixia::ixNetworkGetChassisId $ch_ip]
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to interpret the\
                            '$row_name' row name."
                    return $returnList
                }
                regsub {^0} $cd "" cd
                regsub {^0} $pt "" pt
                set statPort $chassis_no/$cd/$pt
                if {[info exists ports($statPort)]} {
                    foreach stat [array names stats_array_per_aggregate_ixn] {
                        set ixn_stat $stats_array_per_aggregate_ixn($stat)
                        if {[info exists rowsArray($i,$ixn_stat)] && \
                                $rowsArray($i,$ixn_stat) != ""} {
                            if {$statPort == [lindex $port_handle \
                                    $ports($statPort)]} {
                                keylset returnList \
                                        $statPort.aggregate.$stat \
                                        $rowsArray($i,$ixn_stat)
                            }
                        } elseif {$statPort == [lindex $port_handle $ports($statPort)]} {
                            keylset returnList $statPort.aggregate.$stat "N/A"
                        }
                    }
                }
            }
        }
# End aggregate mode

# Per session mode
    } elseif {$mode == "session"} {
        set latest [::ixia::540IsLatestVersion]
        if {$latest} {
            set build_name [list]
            set build_name_flogi [list]
            set build_name_fdisc [list]
            if {[info exists handle]} {
                foreach small_handle $handle {
                    set build_name_flogi "FlogiSessionView-[string trim [string range $small_handle [expr [string first "/range:" $small_handle] + 7] end] "\"\\"]"
                    set build_name_fdisc "FdiscSessionView-[string trim [string range $small_handle [expr [string first "/range:" $small_handle] + 7] end] "\"\\"]"
                    lappend build_name $build_name_flogi $build_name_fdisc
                    set proto_regex_fdisc [ixNetworkGetAttr $small_handle/fcClientFdiscRange -name]
                    set proto_regex_flogi [ixNetworkGetAttr $small_handle/fcClientFlogiRange -name]
                    set drill_result_fdisc [::ixia::CreateAndDrilldownViews $handle handle $build_name_fdisc "fcClient" $proto_regex_fdisc]
                    if {[keylget drill_result_fdisc status] == $::FAILURE} {
                        return $drill_result_fdisc
                    }
                    set drill_result_flogi [::ixia::CreateAndDrilldownViews $handle handle $build_name_flogi "fcClient" $proto_regex_flogi]
                    if {[keylget drill_result_flogi status] == $::FAILURE} {
                        return $drill_result_flogi
                    }
                }
            } else {
                foreach small_port_handle $port_handle {
                    set build_name_fdisc "FdiscSessionView-[regsub -all "/" $small_port_handle "_"]"
                    set build_name_flogi "FlogiSessionView-[regsub -all "/" $small_port_handle "_"]"
                    lappend build_name $build_name_flogi $build_name_fdisc
                    set port_filter [::ixia::ixNetworkGetPortFilterName $small_port_handle]
                    regexp {(\d):(.+)} [keylget port_filter port_filter_name] port_filter_name
                    if {[regexp {(\d)/(\d)/(\d)} $port_filter_name {} chass_id cd pt]} {
                        set proto_regex $chass_id$cd$pt
                    } else {
                        set proto_regex $port_filter_name
                    }
                    set drill_result_fdisc [::ixia::CreateAndDrilldownViews $small_port_handle handle $build_name_fdisc "fcClient" "($proto_regex)(.+)(FDISC)"]
                    if {[keylget drill_result_fdisc status] == $::FAILURE} {
                        return $drill_result_fdisc
                    }
                    set drill_result_flogi [::ixia::CreateAndDrilldownViews $small_port_handle handle $build_name_flogi "fcClient" "($proto_regex)(.+)(FLOGI)"]
                    if {[keylget drill_result_flogi status] == $::FAILURE} {
                        return $drill_result_flogi
                    }
                }
            }
        }
        # Per session stats
        array set stats_array_per_session_ixn [list               \
                "port_name"               "Port Name"             \
                "fdisc_tx"                "FDISC Tx"              \
                "fdisc_ls_acc_rx"         "FDISC LS_ACC Rx"       \
                "fdisc_ls_rjt_rx"         "FDISC LS_RJT Rx"       \
                "flogi_tx"                "FLOGI Tx"              \
                "flogi_ls_acc_rx"         "FLOGI LS_ACC Rx"       \
                "flogi_ls_rjt_rx"         "FLOGI LS_RJT Rx"       \
                "f_bsy_rx"                "F_BSY Rx"              \
                "f_rjt_rx"                "F_RJT Rx"              \
                "flogo_tx"                "FLOGO Tx"              \
                "plogi_tx"                "PLOGI Tx"              \
                "plogi_requests_rx"       "PLOGI Requests Rx"     \
                "plogi_ls_acc_rx"         "PLOGI LS_ACC Rx"       \
                "plogi_ls_rjt_rx"         "PLOGI LS_RJT Rx"       \
                "plogo_tx"                "PLOGO Tx"              \
                "plogo_rx"                "PLOGO Rx"              \
                "ns_registration_tx"      "NS Registration Tx"    \
                "ns_registration_ok"      "NS Registration OK"    \
                "ns_queries_tx"           "NS Queries Tx"         \
                "ns_queries_ok"           "NS Queries OK"         \
                "scr_tx"                  "SCR Tx"                \
                "scr_acc_rx"              "SCR ACC Rx"            \
                "rscn_rx"                 "RSCN Rx"               \
                "rscn_acc_tx"             "RSCN ACC Tx"           \
                "prli_tx"                 "PRLI Tx"               \
                "prli_requests_rx"        "PRLI Requests Rx"      \
                "prli_ls_acc_rx"          "PRLI LS_ACC Rx"        \
                "prli_ls_rjt_rx"          "PRLI LS_RJT Rx"        \
                "interface_id"            "Interface Identifier"  \
                "session_name"            "Session Name"          \
                "port_name"               "Port Name"             \
                "interface_status"        "Interface Status"      \
                "failure_reason"          "Failure Reason"        \
                "source_id"               "Source ID"             \
                "plogi_dest_id"           "PLOGI Destination ID"  \
                "e_d_tov"                 "E_D_TOV"               \
                "remote_bb_credit"        "Remote BB_Credit"      \
        ]
        if {$latest} {
            foreach stats_view_name $build_name {
                set returned_stats_list [::ixia::540GetStatView $stats_view_name]
                if {[keylget returned_stats_list status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to retrieve '$stats_view_name' stat view."
                    return $returnList
                }
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
                            set ch [::ixia::ixNetworkGetChassisId $ch_ip]
                        }
                        set cd [string trimleft $cd 0]
                        set pt [string trimleft $pt 0]
                        set statPort $ch/$cd/$pt
                        foreach stat [array names stats_array_per_session_ixn] {
                            set ixn_stat $stats_array_per_session_ixn($stat)
                            if {[info exists rowsArray($i,$j,$ixn_stat)] && $rowsArray($i,$j,$ixn_stat) != ""} {
                                keylset returnList session.$statPort/$session_no.$stat $rowsArray($i,$j,$ixn_stat)
                            } else {
                                keylset returnList session.$statPort/$session_no.$stat "N/A"
                            }
                        }
                    }
                }
            }
        }
# End per session mode

# Per range mode
    } elseif {$mode == "range"} {
        set latest [::ixia::540IsLatestVersion]
        if {$latest} {
            set build_name [list]
            set build_name_flogi [list]
            set build_name_fdisc [list]
            if {[info exists handle]} {
                foreach small_handle $handle {
                    set build_name_flogi "FlogiRangeView-[string trim [string range $small_handle [expr [string first "/range:" $small_handle] + 7] end] "\"\\"]"
                    set build_name_fdisc "FdiscRangeView-[string trim [string range $small_handle [expr [string first "/range:" $small_handle] + 7] end] "\"\\"]"
                    lappend build_name $build_name_flogi $build_name_fdisc
                    set proto_regex_fdisc [ixNetworkGetAttr $small_handle/fcClientFdiscRange -name]
                    set proto_regex_flogi [ixNetworkGetAttr $small_handle/fcClientFlogiRange -name]
                    set drill_result_fdisc [::ixia::CreateAndDrilldownViews $handle handle_pr $build_name_fdisc "fcClient" $proto_regex_fdisc]
                    if {[keylget drill_result_fdisc status] == $::FAILURE} {
                        return $drill_result_fdisc
                    }
                    set drill_result_flogi [::ixia::CreateAndDrilldownViews $handle handle_pr $build_name_flogi "fcClient" $proto_regex_flogi]
                    if {[keylget drill_result_flogi status] == $::FAILURE} {
                        return $drill_result_flogi
                    }
                }
            } else {
                foreach small_port_handle $port_handle {
                    set build_name_fdisc "FdiscRangeView-[regsub -all "/" $small_port_handle "_"]"
                    set build_name_flogi "FlogiRangeView-[regsub -all "/" $small_port_handle "_"]"
                    lappend build_name $build_name_flogi $build_name_fdisc
                    set port_filter [::ixia::ixNetworkGetPortFilterName $small_port_handle]
                    regexp {(\d):(.+)} [keylget port_filter port_filter_name] port_filter_name
                    if {[regexp {(\d)/(\d)/(\d)} $port_filter_name {} chass_id cd pt]} {
                        set proto_regex $chass_id$cd$pt
                    } else {
                        set proto_regex $port_filter_name
                    }
                    set drill_result_fdisc [::ixia::CreateAndDrilldownViews $small_port_handle handle_pr $build_name_fdisc "fcClient" "($proto_regex)(.+)(FDISC)"]
                    if {[keylget drill_result_fdisc status] == $::FAILURE} {
                        return $drill_result_fdisc
                    }
                    set drill_result_flogi [::ixia::CreateAndDrilldownViews $small_port_handle handle_pr $build_name_flogi "fcClient" "($proto_regex)(.+)(FLOGI)"]
                    if {[keylget drill_result_flogi status] == $::FAILURE} {
                        return $drill_result_flogi
                    }
                }
            }
        }
        # Per range stats
        array set stats_array_per_range_ixn [list                 \
                "port_name"               "Port Name"             \
                "fdisc_tx"                "FDISC Tx"              \
                "fdisc_ls_acc_rx"         "FDISC LS_ACC Rx"       \
                "fdisc_ls_rjt_rx"         "FDISC LS_RJT Rx"       \
                "flogi_tx"                "FLOGI Tx"              \
                "flogi_ls_acc_rx"         "FLOGI LS_ACC Rx"       \
                "flogi_ls_rjt_rx"         "FLOGI LS_RJT Rx"       \
                "f_bsy_rx"                "F_BSY Rx"              \
                "f_rjt_rx"                "F_RJT Rx"              \
                "flogo_tx"                "FLOGO Tx"              \
                "plogi_tx"                "PLOGI Tx"              \
                "plogi_requests_rx"       "PLOGI Requests Rx"     \
                "plogi_ls_acc_rx"         "PLOGI LS_ACC Rx"       \
                "plogi_ls_rjt_rx"         "PLOGI LS_RJT Rx"       \
                "plogo_tx"                "PLOGO Tx"              \
                "plogo_rx"                "PLOGO Rx"              \
                "ns_registration_tx"      "NS Registration Tx"    \
                "ns_registration_ok"      "NS Registration OK"    \
                "ns_queries_tx"           "NS Queries Tx"         \
                "ns_queries_ok"           "NS Queries OK"         \
                "scr_tx"                  "SCR Tx"                \
                "scr_acc_rx"              "SCR ACC Rx"            \
                "rscn_rx"                 "RSCN Rx"               \
                "rscn_acc_tx"             "RSCN ACC Tx"           \
                "prli_tx"                 "PRLI Tx"               \
                "prli_requests_rx"        "PRLI Requests Rx"      \
                "prli_ls_acc_rx"          "PRLI LS_ACC Rx"        \
                "prli_ls_rjt_rx"          "PRLI LS_RJT Rx"        \
                "range_id"                "Range Identifier"      \
                "range_name"              "Range Name"            \
                "e_d_tov"                 "E_D_TOV"               \
                "remote_bb_credit"        "Remote_BB_Credit"      \
        ]
        if {$latest} {
            foreach stats_view_name $build_name {
                set returned_stats_list [::ixia::540GetStatView $stats_view_name]
                if {[keylget returned_stats_list status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to retrieve '$stats_view_name' stat view."
                    return $returnList
                }
                set pageCount [keylget returned_stats_list page]
                set rowCount  [keylget returned_stats_list row]
                array set rowsArray [keylget returned_stats_list rows]
                # Populate statistics
                for {set i 1} {$i < $pageCount} {incr i} {
                    for {set j 1} {$j < $rowCount} {incr j} {
                        if {![info exists rowsArray($i,$j)]} { continue }
                        set rowName $rowsArray($i,$j)
                        set matched [regexp {(.+)/Card([0-9]+)/Port([0-9]+) - ([0-9]+)$} $rowName matched_str hostname cd pt range_no]
                        
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
                            set ch [::ixia::ixNetworkGetChassisId $ch_ip]
                        }
                        set cd [string trimleft $cd 0]
                        set pt [string trimleft $pt 0]
                        set statPort $ch/$cd/$pt
                        foreach stat [array names stats_array_per_range_ixn] {
                            set ixn_stat $stats_array_per_range_ixn($stat)
                            if {[info exists rowsArray($i,$j,$ixn_stat)] && $rowsArray($i,$j,$ixn_stat) != ""} {
                                keylset returnList range.$statPort/$range_no.$stat $rowsArray($i,$j,$ixn_stat)
                            } else {
                                keylset returnList range.$statPort/$range_no.$stat "N/A"
                            }
                        }
                    }
                }
            }
        }
    }
# End per range mode
    return $returnList
}
#End proc ::ixia::ixnetwork_fc_client_stats

proc ::ixia::ixnetwork_fc_client_global_config { args man_args opt_args } {
    set procName [lindex [info level [info level]] 0]
    ::ixia::utrackerLog $procName $args
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args $man_args \
                -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
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
    set fcClientGlobal_param_map {
        maxPacketsPerSecond        max_packets_per_second             value
        maxRetries                 max_retries                        value
        retryInterval              retry_interval                     value
        acceptPartialConfig        accept_partial_config              bool
        setupRate                  setup_rate                         value
        teardownRate               teardown_rate                      value
        }
    set para_map_global [::ixia::ixNetworkmapping $args $man_args $opt_args {} $fcClientGlobal_param_map]
# Add port
    if {$mode == "add"} {
        set objref [ixNet getRoot]/globals/protocolStack
        #Need to add global and put this in objref
        if {[set node_objref [ixNet getList $objref fcClientGlobals]] == ""} {
            set result [::ixia::ixNetworkNodeAdd \
                    $objref                 \
                    fcClientGlobals         \
                    {}                      \
                    -commit                 \
            ]
            if {[keylget result status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : [keylget result log]"
                return $returnList
                }
            set objref [keylget result node_objref]
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "fcClientGlobals is already existed"
            return $returnList
        }
        #Set attribute
        if {[llength [keylget para_map_global handle]] > 0} {
            set attr_set [::ixia::ixNetworkNodeSetAttr     \
                    $objref                                \
                    [keylget para_map_global handle]       \
                    -commit                                \
            ]
            if {[keylget attr_set status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "[keylget attr_set log]"
                return $returnList
            }
            keylset returnList handle $objref
        }
        keylset returnList handle $objref
    }
#End command add

#Modify
    if {$mode == "modify"} {
        set objref [ixNet getRoot]/globals/protocolStack
        if {[set node_objref [ixNet getList $objref fcClientGlobals]] == ""} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : fcClientGlobal is not existed"
            return $returnList
        }
        if {[llength [keylget para_map_global handle]] > 0} {
            set attr_set [::ixia::ixNetworkNodeSetAttr     \
                    $node_objref                           \
                    [keylget para_map_global handle]       \
                    -commit                                \
            ]
            if {[keylget attr_set status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "[keylget attr_set log]"
                return $returnList
            }
            keylset returnList handle $node_objref
        }
    }
#End modify
#Remove port
    if {$mode == "remove"} {
        set objref [ixNet getRoot]/globals/protocolStack
        if {[set node_objref [ixNet getList $objref fcClientGlobals]] == ""} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : fcClientGlobal is not existed"
            return $returnList
        }
        if {[::ixia::ixNetworkRemove $node_objref] != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : [ixNet remove $node_objref]"
            return $returnList
        }
        ::ixia::ixNetworkCommit
        keylset returnList handle $node_objref
    }
#End command remove
    return $returnList
}
#End proc ::ixia::ixnetwork_fc_client_global_config

proc ::ixia::ixnetwork_fc_client_options_config { args man_args opt_args } {
    set procName [lindex [info level [info level]] 0]
    ::ixia::utrackerLog $procName $args
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args $man_args \
                -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
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
    array set options_translate_array {
          obtain_from_login        kObtainFromLogin
          over_ride                kOverride
    }
    set fcClientOption_param_map {
        associates                 associates                         value
        maxPacketsPerSecond        max_packets_per_second             value
        b2bCredit                  b2b_credit                         value
        b2bRxSize                  b2b_rx_size                        value
        edTovMode                  ed_tov_mode                        translate
        rtTovMode                  rt_tov_mode                        translate
        overrideGlobalRate         override_global_rate               bool
        edTov                      ed_tov                             value
        rtTov                      rt_tov                             value
        setupRate                  setup_rate                         value
        teardownRate               teardown_rate                      value
    }
    set para_map_option [::ixia::ixNetworkmapping $args $man_args $opt_args options_translate_array $fcClientOption_param_map]

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
# Add port
    if {$mode == "add"} {
        set result [::ixia::ixNetworkGetPortObjref $port_handle]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName :Unable to find the port \
                    object reference associated to the $port_handle port handle -\
                    [keylget result log]."
            return $returnList
        }
        set objref [keylget result vport_objref]/protocolStack
        #Need to add global and put this in handle
        if {[set node_objref [ixNet getList $objref fcClientOptions]] == ""} {
            set result [::ixia::ixNetworkNodeAdd \
                    $objref                      \
                    fcClientOptions              \
                    {}                           \
                    -commit                      \
            ]
            if {[keylget result status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : [keylget result log]"
                return $returnList
                }
            set objref [keylget result node_objref]
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "fcClientOptions is already existed"
            return $returnList
        }
        #Set attribute
        if {[llength [keylget para_map_option handle]] > 0} {
            set attr_set [::ixia::ixNetworkNodeSetAttr      \
                    $objref                                 \
                    [keylget para_map_option handle]        \
                    -commit                                 \
            ]
            if {[keylget attr_set status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "[keylget attr_set log]"
                return $returnList
            }
            keylset returnList handle $objref
        }
        keylset returnList handle $objref
    }
#End command add

#Modify
    if {$mode == "modify"} {
        foreach port_ele $port_handle {
            set result [::ixia::ixNetworkGetPortObjref $port_ele]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName :Unable to find the port \
                        object reference associated to the $port_handle port handle -\
                        [keylget result log]."
                return $returnList
            }
            set objref [keylget result vport_objref]/protocolStack 
            if {[set node_objref [ixNet getList $objref fcClientOptions]] == ""} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : fcClientOptions does not existed"
                return $returnList
            } elseif {[llength [keylget para_map_option handle]] > 0} {
                set attr_set [::ixia::ixNetworkNodeSetAttr            \
                        $node_objref                                  \
                        [keylget para_map_option handle]              \
                ]
                if {[keylget attr_set status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "[keylget attr_set log]"
                    return $returnList
                }
                lappend handle $node_objref
            }
        }
        ::ixia::ixNetworkCommit
        keylset returnList handle $handle
    }
#End modify

#Remove port
    if {$mode == "remove"} {
        foreach port_ele $port_handle {
            set result [::ixia::ixNetworkGetPortObjref $port_ele]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName :Unable to find the port \
                        object reference associated to the $port_handle port handle -\
                        [keylget result log]."
                return $returnList
            }
            set objref [keylget result vport_objref]/protocolStack
            if {[set node_objref [ixNet getList $objref fcClientOptions]] == ""} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : fcClientOptions does not existed"
                return $returnList
            } else {
                lappend handle $node_objref
            }
        }
        if {[::ixia::ixNetworkRemove $handle] != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : [ixNet remove $handle]"
            return $returnList
        }
        ::ixia::ixNetworkCommit
        keylset returnList handle $handle
    }
#End command remove
    return $returnList
}
#End proc ::ixia::ixnetwork_fc_client_options_config

proc ::ixia::ixnetwork_fc_fport_config { args man_args opt_args} {

    set procName [lindex [info level [info level]] 0]
    ::ixia::utrackerLog $procName $args

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args $man_args \
                -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    # Check dependencies
    # if -mode is add, I need port_handle
    # if -mode is other than add, I need handle
    if {$mode == "add" && ![info exists port_handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                On -mode $mode, parameter -port_handle must be provided."
        return $returnList
    }
    if {($mode == "modify" || $mode == "remove" || $mode == "enable" || $mode == "disable") && ![info exists handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                On -mode $mode, parameter -handle must be provided."
        return $returnList
    }
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

    set fcFportRange_param_map {
        name                   name                     value
        operatingMode          operating_mode           value
        switchName             switch_name              value
        fabricName             fabric_name              value
        b2bRxSize              b2b_rx_size              value
        nameServer             name_server              value
        flogiRejectInterval    flogi_reject_interval    value
        fdiscRejectInterval    fdisc_reject_interval    value
        plogiRejectInterval    plogi_reject_interval    value
        logoRejectInterval     logo_reject_interval     value
    }

    set para_map [::ixia::ixNetworkmapping $args $man_args $opt_args {} $fcFportRange_param_map]

# Add port
    if {$mode == "add"} {
        set return_status [ixNetworkPortAdd $port_handle {} force]
        if {[keylget return_status status] != $::SUCCESS} {
            return $return_status
        }

        set result [::ixia::ixNetworkGetPortObjref $port_handle]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName :Unable to find the port \
                    object reference associated to the $port_handle port handle -\
                    [keylget result log]."
            return $returnList
        }
        set port_handle [keylget result vport_objref]/protocolStack

        if {[set node_objref [ixNet getList $port_handle fcFportFwdEndpoint]] == ""} {
            set result [::ixia::ixNetworkNodeAdd \
                    $port_handle           \
                    fcFportFwdEndpoint     \
                    {}                     \
                    -commit                \
            ]
            if {[keylget result status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : [keylget result log]"
                return $returnList
            }
            set node_objref [keylget result node_objref]
        }

        set result [::ixia::ixNetworkNodeAdd \
                $node_objref     \
                range            \
                {}               \
                -commit          \
        ]
        if {[keylget result status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : [keylget result log]"
            ::ixia::ixnetwork_fc_rollback $node_objref $mode
            return $returnList
        }

        #Set attribute
        if {[llength [keylget para_map handle]] > 0} {
            set attr_set [::ixia::ixNetworkNodeSetAttr         \
                    [keylget result node_objref]/fcFportVxPort \
                    [keylget para_map handle]                  \
                    -commit                                    \
            ]
            if {[keylget attr_set status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName :[keylget attr_set log]"
                return $returnList
            }
        }
        set handle [keylget result node_objref]
        keylset returnList handle $handle
    }
#End command add

#Enable
    if {$mode == "enable"} {
        set enable [list -enabled true]
        foreach handle_ele $handle {
            set attr_set [::ixia::ixNetworkNodeSetAttr    \
                        $handle_ele/fcFportVxPort         \
                        $enable                           \
            ]
            if {[keylget attr_set status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName :[keylget attr_set log]"
                    return $returnList
            }
        }
        ::ixia::ixNetworkCommit
        keylset returnList handle $handle
    }
#End enable command

#Disable
    if {$mode == "disable"} {
        set disable [list -enabled false]
        foreach handle_ele $handle {
            set attr_set [::ixia::ixNetworkNodeSetAttr    \
                        $handle_ele/fcFportVxPort         \
                        $disable                          \
            ]
            if {[keylget attr_set status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName :[keylget attr_set log]"
                    return $returnList
            }
        }
        ::ixia::ixNetworkCommit
        keylset returnList handle $handle
    }
#End disable command

#Modify
    if {$mode == "modify"} {
        foreach handle_ele $handle {
            if {[llength [keylget para_map handle]] > 0} {
                set attr_set [::ixia::ixNetworkNodeSetAttr     \
                        $handle_ele/fcFportVxPort              \
                        [keylget para_map handle]              \
                ]
                if {[keylget attr_set status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "[keylget attr_set log]"
                    return $returnList
                }
            }
        }
        ::ixia::ixNetworkCommit
        keylset returnList handle $handle
    }
#End modify

#Remove port
    if {$mode == "remove"} {
        if {[::ixia::ixNetworkRemove $handle] != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : [ixNet remove $handle]"
            return $returnList
        }
        ::ixia::ixNetworkCommit
        keylset returnList handle $handle
    }
#End command remove

    return $returnList
}
#End proc ::ixia::ixnetwork_fc_fport_config

proc ::ixia::ixnetwork_fc_fport_vnport_config { args man_args opt_args} {

    set procName [lindex [info level [info level]] 0]
    ::ixia::utrackerLog $procName $args

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args $man_args \
            -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    # Check dependencies
    # if -mode is add, I need port_handle
    # if -mode is other than add, I need handle
    if {[info exists mode] && ![info exists handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                On -mode $mode, parameter -handle must be provided."
        return $returnList
    }
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
   array set plogi_mesh_mode_map {
        one_one            one-to-one
        many_many        many-to-many
   }
    set fcFportSecondaryRange_param_map {
        name                   name                     value
        count                  count                    value
        simulated              simulated                value
        portIdStart            port_id_start            value
        portIdIncrement        port_id_incr             value
        nodeWwnStart           node_wwn_start           value
        nodeWwnIncrement       node_wwn_incr            value
        portWwnStart           port_wwn_start           value
        portWwnIncrement       port_wwn_incr            value
        b2bRxSize              b2b_rx_size              value
        vxPortName             vx_port_name             value
        plogiEnabled           plogi_enable             bool
        plogiDestId            plogi_dest_id            value
        plogiMeshMode          plogi_mesh_mode          translate
        plogiTargetName        plogi_target_name        value
        }

    set para_map [::ixia::ixNetworkmapping $args $man_args $opt_args plogi_mesh_mode_map $fcFportSecondaryRange_param_map]

# Add port
    if {$mode == "add"} {
        set vx_port_name [ixNet getA $handle/fcFportVxPort -name]
        set node_objref [::ixia::ixNetworkGetParentObjref $handle]
        set result [::ixia::ixNetworkNodeAdd \
                $node_objref     \
                secondaryRange   \
                {}               \
                -commit          \
        ]
        if {[keylget result status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : [keylget result log]"
            ::ixia::ixnetwork_fc_rollback $node_objref $mode
            return $returnList
        }

        #Set attribute
        if {[llength [keylget para_map handle]] > 0} {
            set attr_set [::ixia::ixNetworkNodeSetAttr              \
                    [keylget result node_objref]/fcFportVnPortRange \
                    [keylget para_map handle]                       \
                    -commit                                         \
            ]
            if {[keylget attr_set status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName :[keylget attr_set log]"
                return $returnList
            }
        }
        set handle [keylget result node_objref]
        keylset returnList handle $handle
    }
#End command add

#Enable
    if {$mode == "enable"} {
        set enable [list -enabled true]
        foreach handle_ele $handle {
            set attr_set [::ixia::ixNetworkNodeSetAttr    \
                        $handle_ele/fcFportVnPortRange    \
                        $enable                           \
            ]
            if {[keylget attr_set status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName :[keylget attr_set log]"
                    return $returnList
            }
        }
        ::ixia::ixNetworkCommit
        keylset returnList handle $handle
    }
#End enable command

#Disable
    if {$mode == "disable"} {
        set disable [list -enabled false]
        foreach handle_ele $handle {
            set attr_set [::ixia::ixNetworkNodeSetAttr    \
                        $handle_ele/fcFportVnPortRange    \
                        $disable                          \
            ]
            if {[keylget attr_set status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName :[keylget attr_set log]"
                    return $returnList
            }
        }
        ::ixia::ixNetworkCommit
        keylset returnList handle $handle
    }
#End disable command

#Modify
    if {$mode == "modify"} {
        foreach handle_ele $handle {
            if {[llength [keylget para_map handle]] > 0} {
                set attr_set [::ixia::ixNetworkNodeSetAttr         \
                        $handle_ele/fcFportVnPortRange             \
                        [keylget para_map handle]                  \
                ]
                if {[keylget attr_set status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "[keylget attr_set log]"
                    return $returnList
                }
            }
        }
        ::ixia::ixNetworkCommit
        keylset returnList handle $handle
    }
#End modify

#Remove port
    if {$mode == "remove"} {
        if {[::ixia::ixNetworkRemove $handle] != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : [ixNet remove $handle]"
            return $returnList
        }
        ::ixia::ixNetworkCommit
        keylset returnList handle $handle
    }
#End command remove

    return $returnList
}
#End proc ::ixia::ixnetwork_fc_fport_vnport_config

proc ::ixia::ixnetwork_fc_control { args man_args opt_args} {

    set procName [lindex [info level [info level]] 0]
    ::ixia::utrackerLog $procName $args

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args $man_args \
            -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    keylset returnList status $::SUCCESS
    # Check to see if handle or port_handle already exist.
    if {$action != "is_done" && !([info exists handle] || [info exists port_handle])} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                On -action $action, parameter -handle or -port_handle must be provided."
        return $returnList
    }
    if {$action == "is_done" && ![info exists result]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                On -action $action, parameter -result must be provided."
        return $returnList
    }
    # Support abort and clear_stats even when the user give handles not port_handle
    if {($action == "clear_stats" || $action == "abort") && ![info exists port_handle]} {
        foreach handle_ele $handle {
            set tmp [::ixia::ixNetworkGetPortFromObj $handle_ele]
            lappend temp [keylget tmp port_handle]
        }
        set port_handle $temp
        puts "WARNING : This action only must be provided -port_handle parameter"
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
    array set action_map {                                            \
            start,Endpoint,Fport                       start              \
            start,range,Fport                          fcFportStart       \
            start,Endpoint,Client                      start              \
            start,range,Client                         start              \
            stop,Endpoint,Fport                        stop               \
            stop,range,Fport                           fcFportStop        \
            stop,Endpoint,Client                       stop               \
            stop,range,Client                          stop               \
            clear_stats,Endpoint,Client                fcClientClearStats \
            clear_stats,Endpoint,Fport                 fcFportClearStats  \
            pause,Endpoint,Client                      fcClientPause      \
            resume,Endpoint,Client                     fcClientResume     \
            pause,Endpoint,Fport                       fcFportPause       \
            pause,range,Fport                          fcFportPause       \
            resume,Endpoint,Fport                      fcFportResume      \
            resume,range,Fport                         fcFportResume      \
            fc_client_fdisc,Endpoint,Client            fcClientFdisc      \
            fc_client_fdisc,range,Client               fcClientFdisc      \
            fc_client_npiv_flogo,Endpoint,Client       fcClientNpivFlogo  \
            fc_client_npiv_flogo,range,Client          fcClientNpivFlogo  \
            fc_client_flogi,Endpoint,Client            fcClientFlogi      \
            fc_client_flogi,range,Client               fcClientFlogi      \
            fc_client_flogo,range,Client               fcClientFlogo      \
            fc_client_flogo,Endpoint,Client            fcClientFlogo      \
            fc_client_plogi,range,Client               fcClientPlogi      \
            fc_client_fdisc_plogi,range,Client         fcClientPlogi      \
            fc_client_fdisc_plogo,range,Client         fcClientPlogo      \
            fc_client_plogi,Endpoint,Client            fcClientPlogi      \
            fc_client_plogo,range,Client               fcClientPlogo      \
            fc_client_plogo,Endpoint,Client            fcClientPlogo      \
            abort,Endpoint,Client                      abort              \
            abort,Endpoint,Fport                       abort              \
    }
    if {$action == "is_done"} {
        set status_list [::ixia::ixNetworkIsDone $result]
        keylset returnList log $status_list
        return $returnList
    }
#If port_handle exists,translate it to Endpoint
    if {[info exists handle]} {
        if {[info exists port_handle]} {
            puts "WARNING : $action only execute -handle parameter"
            unset port_handle
        }
        foreach handle_ele $handle {
            if {[regexp -nocase "fport" $handle_ele]} {
                lappend handle_list $handle_ele
                set level "range"
                set kind($handle_ele) "Fport"
            } elseif {[regexp -nocase "client" $handle_ele]} {
                if { $action == "fc_client_fdisc_plogi" || $action == "fc_client_npiv_flogo"\
                        || $action == "fc_client_fdisc" || $action == "fc_client_fdisc_plogo"} {
                    set handle_ele $handle_ele/fcClientFdiscRange
                }
                lappend handle_list $handle_ele
                set level "range"
                set kind($handle_ele) "Client"
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not find an FC configuration on the following port: $handle_ele"
                return $returnList
            }
        }
    } elseif {[info exists port_handle]} {
        foreach port_ele $port_handle {
            set result [::ixia::ixNetworkGetPortObjref $port_ele]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to find the port \
                        object reference associated to the $port_ele port handle -\
                        [keylget result log]."
                return $returnList
            }
            set objref [keylget result vport_objref]/protocolStack
            if {[set handle_ele [ixNet getL $objref fcFportFwdEndpoint]] == ""} {
                if {[set handle_ele [ixNet getL $objref fcClientEndpoint]] == ""} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not find an FC configuration on the following port: $port_ele"
                    return $returnList
                } else {
                    lappend handle_list $handle_ele
                    set level "Endpoint"
                    set kind($handle_ele) "Client"
                }
            } else {
                lappend handle_list $handle_ele
                set level "Endpoint"
                set kind($handle_ele) "Fport"
            }
        }
    }
    set execute_list [list]
    foreach handle_ele $handle_list {
        if {[info exists action_map($action,$level,$kind($handle_ele))]} {
            #Create a list of action map
            if {[lsearch $execute_list $action_map($action,$level,$kind($handle_ele))] < 0} {
                lappend execute_list $action_map($action,$level,$kind($handle_ele))
            }
            #Create a list of handles of the same action map
            lappend action_exec($action_map($action,$level,$kind($handle_ele))) $handle_ele
        } else {
            puts "WARNING : The action $action is not supported for FC Fport"
        }
    }
    if {$execute_list == ""} {
        keylset returnList status $::FAILURE
        keylset returnList log "There is no $action for handle/port_handle"
        return $returnList
    }
    if {$action_mode == "async"} {
        foreach execute_handle $execute_list {
            set action_handle [list $execute_handle $action_exec($execute_handle) async]
            set control_status [ixNetworkExec $action_handle]
            foreach handle_child $action_exec($execute_handle) {
                if {[info exists port_handle]} {
                    set port [ixNetworkGetPortFromObj $handle_child]
                    keylset returnList result.[keylget port port_handle]\
                            [lindex $::ixia::ixnetwork_async_operations_array($action_exec($execute_handle),$execute_handle) 0]
                } else {
                    keylset returnList result.$handle_child\
                            [lindex $::ixia::ixnetwork_async_operations_array($action_exec($execute_handle),$execute_handle) 0]
                }
            }
        }
    } else {
        foreach execute_handle $execute_list {
            set action_handle [list $execute_handle $action_exec($execute_handle)]
            catch {::ixia::ixNetworkExec $action_handle} control_status
            if {[string first "::ixNet::OK" $control_status] == -1} {
                keylset returnList status $::FAILURE
                lappend log_tempt "Failed to $action FC. Returned status: $control_status"
                keylset returnList log $log_tempt
            }
            foreach handle_child $action_exec($execute_handle) {
                if {[info exists port_handle]} {
                    set port [ixNetworkGetPortFromObj $handle_child]
                    set port_name [keylget port port_handle]
                    keylset returnList $port_name $control_status
                } else {
                    keylset returnList $handle_child $control_status
                }
            }
        }
    }
    return $returnList
}
#End proc ::ixia::ixnetwork_fc_fport_control

proc ::ixia::ixnetwork_fc_fport_global_config { args man_args opt_args} {
    set procName [lindex [info level [info level]] 0]
    ::ixia::utrackerLog $procName $args

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args $man_args \
                -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

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

    set fcFportGlobal_param_map {
        maxPacketsPerSecond        max_packets_per_second            value
        maxRetries                 max_retries                       value
        retryInterval              retry_interval                    value
        acceptPartialConfig        accept_partial_config             bool
        }    

    set para_map [::ixia::ixNetworkmapping $args $man_args $opt_args {} $fcFportGlobal_param_map]
    
# Add port
    if {$mode == "add"} {
        set objref [ixNet getRoot]/globals/protocolStack

        #Need to add global and put this in handle

        if {[set node_objref [ixNet getList $objref fcFportGlobals]] == ""} {
            set result [::ixia::ixNetworkNodeAdd \
                    $objref                \
                    fcFportGlobals         \
                    {}                     \
                    -commit                \
            ]
            if {[keylget result status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : [keylget result log]"
                return $returnList
                }
            set objref [keylget result node_objref]
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "fcFportGlobals is already existed"
            return $returnList
        }
        #Set attribute
        if {[llength [keylget para_map handle]] > 0} {
            set attr_set [::ixia::ixNetworkNodeSetAttr   \
                    $objref                              \
                    [keylget para_map handle]            \
                    -commit                              \
            ]
            if {[keylget attr_set status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName :[keylget attr_set log]"
                return $returnList
            }
        }
        keylset returnList handle $objref
    }
#End command add

#Modify
    if {$mode == "modify"} {
        set objref [ixNet getRoot]/globals/protocolStack
        if {[set node_objref [ixNet getList $objref fcFportGlobals]] == ""} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : fcFportGlobal is not existed"
            return $returnList
        }
        if {[llength [keylget para_map handle]] > 0} {
            set attr_set [::ixia::ixNetworkNodeSetAttr    \
                    $node_objref                          \
                    [keylget para_map handle]             \
                    -commit                               \
            ]
            if {[keylget attr_set status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName :[keylget attr_set log]"
                return $returnList
            }
            keylset returnList handle $objref
        }
    }
#End modify

#Remove port
    if {$mode == "remove"} {
        set objref [ixNet getRoot]/globals/protocolStack
        if {[set node_objref [ixNet getList $objref fcFportGlobals]] == ""} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : fcFportGlobal is not existed"
            return $returnList
        }

        if {[::ixia::ixNetworkRemove $node_objref] != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName : [ixNet remove $handle]"
            return $returnList
        }
        ::ixia::ixNetworkCommit
        keylset returnList handle $node_objref
    }
#End command remove
    return $returnList
}
#End proc ::ixia::ixnetwork_fc_fport_global_config

proc ::ixia::ixnetwork_fc_fport_options_config { args man_args opt_args} {
    set procName [lindex [info level [info level]] 0]
    ::ixia::utrackerLog $procName $args

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args $man_args \
            -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
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
    set fcFportOption_param_map {
        maxPacketsPerSecond        max_packets_per_second       value
        b2bCredit                  b2b_credit                   value
        edTov                      ed_tov                       value
        rtTov                      rt_tov                       value
        overrideGlobalRate         override_global_rate         bool
    }

    set para_map [::ixia::ixNetworkmapping $args $man_args $opt_args {} $fcFportOption_param_map]
    if {![info exists port_handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "When -mode is $mode, one of the parameters\
                -port_handle or -handle must be provided."
        return $returnList
    }

    set result [::ixia::ixNetworkGetPortObjref $port_handle]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName :Unable to find the port \
                    object reference associated to the $port_handle port handle -\
                    [keylget result log]."
            return $returnList
        }
    set objref [keylget result vport_objref]/protocolStack 

# Add port
    if {$mode == "add"} {
        #Need to add global and put this in handle

        if {[set node_objref [ixNet getList $objref fcFportOptions]] == ""} {
            set result [::ixia::ixNetworkNodeAdd \
                    $objref                \
                    fcFportOptions         \
                    {}                     \
                    -commit                \
            ]
            if {[keylget result status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : [keylget result log]"
                return $returnList
                }
            set handle [keylget result node_objref]
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "fcFportOption is already existed"
            return $returnList
        }

        #Set attribute
        if {[llength [keylget para_map handle]] > 0} {
            set attr_set [::ixia::ixNetworkNodeSetAttr  \
                    $handle                             \
                    [keylget para_map handle]           \
                    -commit                             \
            ]
            if {[keylget attr_set status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName :[keylget attr_set log]"
                return $returnList
            }
        }
        keylset returnList handle $handle
    }
#End command add

#Modify
    if {$mode == "modify"} {
        foreach port_ele $port_handle {
            set result [::ixia::ixNetworkGetPortObjref $port_ele]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName :Unable to find the port \
                        object reference associated to the $port_ele port handle -\
                        [keylget result log]."
                return $returnList
            }
            set objref [keylget result vport_objref]/protocolStack 
            if {[set node_objref [ixNet getList $objref fcFportOptions]] == ""} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : fcFportOptions does not existed"
                return $returnList
            } elseif {[llength [keylget para_map handle]] > 0} {
                set attr_set [::ixia::ixNetworkNodeSetAttr   \
                        $node_objref                         \
                        [keylget para_map handle]            \
                        -commit                              \
                ]
                if {[keylget attr_set status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName :[keylget attr_set log]"
                    return $returnList
                }
                lappend handle $node_objref
            }
        }
        keylset returnList handle $handle
    }
#End modify

#Remove port
    if {$mode == "remove"} {
        foreach port_ele $port_handle {
            set result [::ixia::ixNetworkGetPortObjref $port_ele]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName :Unable to find the port \
                        object reference associated to the $port_handle port handle -\
                        [keylget result log]."
                return $returnList
            }
            set objref [keylget result vport_objref]/protocolStack
            if {[set node_objref [ixNet getList $objref fcFportOptions]] == ""} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : fcFportOptions does not existed"
                return $returnList
            } elseif {[::ixia::ixNetworkRemove $node_objref] != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName : [ixNet remove $handle]"
                return $returnList
            }
            ::ixia::ixNetworkCommit
            lappend handle $node_objref
        }
        keylset returnList handle $node_objref
    }
#End command remove

    return $returnList
}
#End proc ::ixia::ixnetwork_fc_fport_options_config

proc ::ixia::ixnetwork_fport_stats { args } {
    set args [lindex $args 0]
    variable executeOnTclServer

    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::ixnetwork_fport_stats $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    set procName [lindex [info level [info level]] 0]
    ::ixia::utrackerLog $procName $args

    # Arguments
    set man_args {
        -mode         CHOICES aggregate session range
    }
    set opt_args {
        -handle       ANY
        -port_handle  REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
    }

    keylset returnList status $::SUCCESS

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    if {![info exists port_handle] && ![info exists handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "When -mode is $mode, one of the parameters\
                -port_handle or -handle must be provided."
        return $returnList
    }

    if {$mode == "aggregate"} {
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
        # Per aggregate stats
        array set stats_array_per_aggregate_ixn {           \
                "port_name"           "Port Name"           \
                "fdisc_ls_acc_tx"     "FDISC LS_ACC Tx"     \
                "fdisc_ls_rjt_tx"     "FDISC LS_RJT Tx"     \
                "fdisc_requests_rx"   "FDISC Requests Rx"   \
                "flogi_ls_acc_tx"     "FLOGI LS_ACC Tx"     \
                "flogi_ls_rjt_tx"     "FLOGI LS_RJT Tx"     \
                "flogi_requests_rx"   "FLOGI Requests Rx"   \
                "flogo_ls_acc_tx"     "FLOGO LS_ACC Tx"     \
                "flogo_ls_rjt_tx"     "FLOGO LS_RJT Tx"     \
                "flogo_requests_rx"   "FLOGO Requests Rx"   \
                "nports_registered"   "N_Ports Registered"  \
                "ns_accepts_tx"       "NS Accepts Tx"       \
                "ns_rejects_tx"       "NS Rejects Tx"       \
                "ns_requests_rx"      "NS Requests Rx"      \
                "plogi_ls_acc_rx"     "PLOGI LS_ACC Rx"     \
                "plogi_ls_acc_tx"     "PLOGI LS_ACC Tx"     \
                "plogi_ls_rjt_rx"     "PLOGI LS_RJT Rx"     \
                "plogi_ls_rjt_tx"     "PLOGI LS_RJT Tx"     \
                "plogi_requests_rx"   "PLOGI Requests Rx"   \
                "plogi_requests_tx"   "PLOGI Requests Tx"   \
                "plogo_ls_acc_rx"     "PLOGO LS_ACC Rx"     \
                "plogo_ls_acc_tx"     "PLOGO LS_ACC Tx"     \
                "plogo_ls_rjt_rx"     "PLOGO LS_RJT Rx"     \
                "plogo_ls_rjt_tx"     "PLOGO LS_RJT Tx"     \
                "plogo_requests_rx"   "PLOGO Requests Rx"   \
                "plogo_requests_tx"   "PLOGO Requests Tx"   \
                "scr_requests_rx"     "SCR Requests Rx"     \
                "scr_accepts_tx"      "SCR Accepts Tx"      \
                "scr_rejects_tx"      "SCR Rejects Tx"      \
        }
        foreach stat [array names stats_array_per_aggregate_ixn] {
            lappend stat_list_aggregate $stats_array_per_aggregate_ixn($stat)
        }
        set returned_stats_list [::ixia::ixNetworkGetStats \
                {FC F_Port} $stat_list_aggregate]
        if {[keylget returned_stats_list status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to read the\
                    stat view browser -\
                    [keylget returned_stats_list log]"
            return $returnList
        }
        set enableStatus [enableStatViewList {{FC F_Port}}]
        if {[keylget enableStatus status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Enable fail\
                    [keylget enableStatus log]"
            return $returnList
        }
        set row_count [keylget returned_stats_list row_count]
        array set rows_array [keylget returned_stats_list statistics]
        foreach port $port_handle {
            for {set i 1} {$i <= $row_count} {incr i} {
                set row_name $rows_array($i) 
                set match [regexp {(.+)/Card([0-9]{2})/Port([0-9]{2})} \
                        $row_name match_name hostname card_no port_no]
                if {$match && [catch {set chassis_ip [keylget ::ixia::hosts_to_ips $hostname]} err]} {
                    set chassis_ip $hostname
                }
                if {$match && ($match_name == $row_name) && \
                        [info exists chassis_ip] && \
                        [info exists card_no] && \
                        [info exists port_no] } {
                    set chassis_no [ixNetworkGetChassisId $chassis_ip]
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to interpret the\
                            '$row_name' row name."
                    return $returnList
                }
                regsub {^0} $card_no "" card_no
                regsub {^0} $port_no "" port_no
                set handle $chassis_no/$card_no/$port_no
                if {"$port" eq "$handle"} {
                    foreach stat [array names stats_array_per_aggregate_ixn] {
                        set ixn_stat $stats_array_per_aggregate_ixn($stat)
                        if {[info exists rows_array($i,$ixn_stat)] && \
                                $rows_array($i,$ixn_stat) != ""} {
                                keylset returnList \
                                        $handle.aggregate.$stat $rows_array($i,$ixn_stat)
                        } else {
                                keylset returnList $handle.aggregate.$stat "N/A"
                        }
                    }
                }
            }
        }
    } elseif {$mode == "range"} {
        set latest [::ixia::540IsLatestVersion]
        if {$latest} {
            set build_name [list]
            if {[info exists handle]} {
                foreach small_handle $handle {
                    set build_name "RangeView-[string trim [string range $small_handle [expr [string first "/range:" $small_handle] + 7] end] "\"\\"]"
                    lappend build_name_list $build_name
                    set proto_regex [::ixia::ixNetworkGetAttr $small_handle/fcFportVxPort -name]
                    set drill_result [::ixia::CreateAndDrilldownViews $small_handle handle_pr $build_name "fcFport" "$proto_regex"]
                    if {[keylget drill_result status] == $::FAILURE} {
                        return $drill_result
                    }
                }
            } else {
                foreach small_port_handle $port_handle {
                    set build_name "RangeView-[regsub -all "/" $small_port_handle "_"]"
                    lappend build_name_list $build_name
                    set port_filter [::ixia::ixNetworkGetPortFilterName $small_port_handle]
                    regexp {(\d):(.+)} [keylget port_filter port_filter_name] port_filter_name
                    if {[regexp {(\d)/(\d)/(\d)} $port_filter_name {} chass_id cd pt]} {
                        set proto_regex $chass_id$cd$pt
                    } else {
                        set proto_regex $port_filter_name
                    }
                    set drill_result [::ixia::CreateAndDrilldownViews $small_port_handle handle_pr $build_name "fcFport" "$proto_regex"]
                    if {[keylget drill_result status] == $::FAILURE} {
                        return $drill_result
                    }
                }
            }
        }
        # Per range stats
        array set stats_array_per_range_ixn {                \
                "port_name"          "Port Name"             \
                "range_name"         "Range Name"            \
                "nports_registered"  "N_Ports Registered"    \
                "ns_requests_rx"     "NS Requests Rx"        \
                "ns_accepts_tx"      "NS Accepts Tx"         \
                "ns_rejects_tx"      "NS Rejects Tx"         \
                "scr_requests_rx"    "SCR Requests Rx"       \
                "scr_accepts_tx"     "SCR Accepts Tx"        \
                "scr_rejects_tx"     "SCR Rejects Tx"        \
                "flogi_requests_rx"  "FLOGI Requests Rx"     \
                "flogi_ls_acc_tx"    "FLOGI LS_ACC Tx"       \
                "flogi_ls_rjt_tx"    "FLOGI LS_RJT Tx"       \
                "fdisc_requests_rx"  "FDISC Requests Rx"     \
                "fdisc_ls_acc_tx"    "FDISC LS_ACC Tx"       \
                "fdisc_ls_rjt_tx"    "FDISC LS_RJT Tx"       \
                "flogo_requests_rx"  "FLOGO Requests Rx"     \
                "flogo_ls_acc_tx"    "FLOGO LS_ACC Tx"       \
                "flogo_ls_rjt_tx"    "FLOGO LS_RJT Tx"       \
                "plogi_requests_rx"  "PLOGI Requests Rx"     \
                "plogi_ls_acc_tx"    "PLOGI LS_ACC Tx"       \
                "plogi_ls_rjt_tx"    "PLOGI LS_RJT Tx"       \
                "plogo_requests_rx"  "PLOGO Requests Rx"     \
                "plogo_ls_acc_tx"    "PLOGO LS_ACC Tx"       \
                "plogo_ls_rjt_tx"    "PLOGO LS_RJT Tx"       \
                "plogi_requests_tx"  "PLOGI Requests Tx"     \
                "plogi_ls_acc_rx"    "PLOGI LS_ACC Rx"       \
                "plogi_ls_rjt_rx"    "PLOGI LS_RJT Rx"       \
                "plogo_requests_tx"  "PLOGO Requests Tx"     \
                "plogo_ls_acc_rx"    "PLOGO LS_ACC Rx"       \
                "plogo_ls_rjt_rx"    "PLOGO LS_RJT Rx"       \
        }
        if {$latest} {
            foreach stats_view_name $build_name_list {
                set returned_stats_list [::ixia::540GetStatView $stats_view_name]
                if {[keylget returned_stats_list status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to retrieve '$stats_view_name' stat view."
                    return $returnList
                }
                set pageCount [keylget returned_stats_list page]
                set rowCount  [keylget returned_stats_list row]
                array set rowsArray [keylget returned_stats_list rows]
                # Populate statistics
                for {set i 1} {$i < $pageCount} {incr i} {
                    for {set j 1} {$j < $rowCount} {incr j} {
                        if {![info exists rowsArray($i,$j)]} { continue }
                        set rowName $rowsArray($i,$j)
                        set matched [regexp {(.+)/Card([0-9]+)/Port([0-9]+) - ([0-9]+)$} $rowName matched_str hostname cd pt range_no]
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
                            set ch [::ixia::ixNetworkGetChassisId $ch_ip]
                        }
                        set cd [string trimleft $cd 0]
                        set pt [string trimleft $pt 0]
                        set statPort $ch/$cd/$pt
                        foreach stat [array names stats_array_per_range_ixn] {
                            set ixn_stat $stats_array_per_range_ixn($stat)
                            if {[info exists rowsArray($i,$j,$ixn_stat)] && $rowsArray($i,$j,$ixn_stat) != ""} {
                                keylset returnList range.$statPort/${range_no}.$stat $rowsArray($i,$j,$ixn_stat)
                            } else {
                                keylset returnList range.$statPort/${range_no}.$stat "N/A"
                            }
                        }
                    }
                }
            }
        }
    } elseif {$mode == "session"} {
        set latest [::ixia::540IsLatestVersion]
        if {$latest} {
            set build_name [list]
            if {[info exists handle]} {
                foreach small_handle $handle {
                    set build_name "SessionView-[string trim [string range $small_handle [expr [string first "/range:" $small_handle] + 7] end] "\"\\"]"
                    lappend build_name_list $build_name
                    set proto_regex [::ixia::ixNetworkGetAttr $small_handle/fcFportVxPort -name]
                    set drill_result [::ixia::CreateAndDrilldownViews $small_handle handle $build_name "fcFport" "$proto_regex"]
                    if {[keylget drill_result status] == $::FAILURE} {
                        return $drill_result
                    }
                }
            } else {
                foreach small_port_handle $port_handle {
                    set build_name "SessionView-[regsub -all "/" $small_port_handle "_"]"
                    lappend build_name_list $build_name
                    set port_filter [::ixia::ixNetworkGetPortFilterName $small_port_handle]
                    regexp {(\d):(.+)} [keylget port_filter port_filter_name] port_filter_name
                    if {[regexp {(\d)/(\d)/(\d)} $port_filter_name {} chass_id cd pt]} {
                        set proto_regex $chass_id$cd$pt
                    } else {
                        set proto_regex $port_filter_name
                    }
                    set drill_result [::ixia::CreateAndDrilldownViews $small_port_handle handle $build_name "fcFport" "$proto_regex"]
                    if {[keylget drill_result status] == $::FAILURE} {
                        return $drill_result
                    }
                }
            }
        }

        # Per session stats
        array set stats_array_per_session_ixn {           \
                "port_name"          "Port Name"          \
                "session_name"       "Session Name"       \
                "session_status"     "Session Status"     \
                "source_id"          "Source ID"          \
                "port_name"          "Port Name"          \
                "node_name"          "Node Name"          \
                "flogi_requests_rx"  "FLOGI Requests Rx"  \
                "flogi_ls_acc_tx"    "FLOGI LS_ACC Tx"    \
                "flogi_ls_rjt_tx"    "FLOGI LS_RJT Tx"    \
                "fdisc_requests_rx"  "FDISC Requests Rx"  \
                "fdisc_ls_acc_tx"    "FDISC LS_ACC Tx"    \
                "fdisc_ls_rjt_tx"    "FDISC LS_RJT Tx"    \
                "flogo_requests_rx"  "FLOGO Requests Rx"  \
                "flogo_ls_acc_tx"    "FLOGO LS_ACC Tx"    \
                "flogo_ls_rjt_tx"    "FLOGO LS_RJT Tx"    \
                "plogi_requests_rx"  "PLOGI Requests Rx"  \
                "plogi_ls_acc_tx"    "PLOGI LS_ACC Tx"    \
                "plogi_ls_rjt_tx"    "PLOGI LS_RJT Tx"    \
                "plogo_requests_rx"  "PLOGO Requests Rx"  \
                "plogo_ls_acc_tx"    "PLOGO LS_ACC Tx"    \
                "plogo_ls_rjt_tx"    "PLOGO LS_RJT Tx"    \
                "ns_requests_rx"     "NS Requests Rx"     \
                "ns_accepts_tx"      "NS Accepts Tx"      \
                "ns_rejects_tx"      "NS Rejects Tx"      \
                "scr_requests_rx"    "SCR Requests Rx"    \
                "scr_accepts_tx"     "SCR Accepts Tx"     \
                "scr_rejects_tx"     "SCR Rejects Tx"     \
        }
        if {$latest} {
            foreach stats_view_name $build_name_list {
                set returned_stats_list [::ixia::540GetStatView $stats_view_name]
                if {[keylget returned_stats_list status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to retrieve '$stats_view_name' stat view."
                    return $returnList
                }
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
                            set ch [::ixia::ixNetworkGetChassisId $ch_ip]
                        }
                        set cd [string trimleft $cd 0]
                        set pt [string trimleft $pt 0]
                        set statPort $ch/$cd/$pt
                        foreach stat [array names stats_array_per_session_ixn] {
                            set ixn_stat $stats_array_per_session_ixn($stat)
                            if {[info exists rowsArray($i,$j,$ixn_stat)] && $rowsArray($i,$j,$ixn_stat) != ""} {
                                keylset returnList session.$statPort/$session_no.$stat $rowsArray($i,$j,$ixn_stat)
                            } else {
                                keylset returnList session.$statPort/$session_no.$stat "N/A"
                            }
                        }
                    }
                }
            }
        }
    }
    return $returnList
}
#End proc ::ixia::ixnetwork_fc_fport_stats

proc ::ixia::ixNetworkmapping { args man_args opt_args translate_array {paraList {}} } {

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args $man_args \
                -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
     removeDefaultOptionVars $opt_args $args
    upvar $translate_array translate
    set ixn_args [list]
    foreach {ixn_p hlt_p p_type} $paraList {
        if {[info exists $hlt_p]} {
            
            set hlt_p_val [set $hlt_p]
            switch -- $p_type {
                value {
                    set ixn_p_val $hlt_p_val
                }
                translate {
                    if {[info exists translate($hlt_p_val)]} {
                        set ixn_p_val $translate($hlt_p_val)
                    } else {
                        set ixn_p_val $hlt_p_val
                    }
                }
                bool {
                    if {$hlt_p_val == 1} {
                        set ixn_p_val true
                    } else {
                        set ixn_p_val false
                    }
                    
                }
                semicolon_list {
                    regsub -all { } $hlt_p_val {; } ixn_p_val
                }
                default {
                    set ixn_p_val $hlt_p_val
                }
            }
            
            lappend ixn_args -$ixn_p $ixn_p_val

        }
    }
    keylset returnList handle $ixn_args
    return $returnList
}
#End proc ::ixia::ixNetworkmapping

proc ::ixia::ixnetwork_fc_rollback {handle mode} {
    if {$mode == "add"} {
        upvar returnList retList
        set log [keylget retList log]
        
        if {[set rmv_handle [ixNetworkGetParentObjref $handle range] == [ixNet getNull]]} {
            set rmv_handle [ixNetworkGetParentObjref $handle secondaryRange]
        }
        
        if {$rmv_handle != [ixNet getNull]} {
        
            debug "ixNet remove $rmv_handle"
            if {[catch {ixNet remove $rmv_handle} err]} {
                append log ". Failed to remove object $rmv_handle - $err"
            } else {
                debug "ixNet commit"
                if {[catch {ixNet commit} err]} {
                    append log ". Failed to commit object $rmv_handle - $err"
                }
            }
            
            keylset retList log $log
        }
    }
}
#End proc ::ixia::ixnetwork_fc_rollback
