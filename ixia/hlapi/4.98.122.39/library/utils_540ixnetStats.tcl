proc ::ixia::540GetStatView {statViewName {mode "all"} {is_latency_view "0"} {type ""}} {
    # mode - create - creates the stat view if the stat view was not found
    # mode - all - returns SUCCESS and empty list of stats when the stat view was not found
    # mode - other - returns FAILURE when the stat view was not found
    
    keylset returnList status $::SUCCESS
    
    set statViewRoot [ixNet getRoot]statistics
    
    set statViewList [ixNet getList $statViewRoot view]

    set view ""
    foreach statView $statViewList {
        if {[ixNet getAttribute $statView -caption] == $statViewName} {
            set view $statView
            break
        }
    }
   
    if {$view == ""} {
        if {$mode == "create" && $type != ""} {
            set retCode [540CreateUserDefinedView $statViewName $type]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
            set view    [keylget retCode view]
        } elseif {$mode != "all"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not find $statViewName view. Possible causes:\
                    traffic was not started or statistics collected too soon after traffic was started."
            return $returnList
        } else {
            keylset returnList rows ""
            keylset returnList page 0
            keylset returnList row  0
            return $returnList
        }
    }
    
    set commit_needed 0
    foreach {statistic} [ixNet getList $view statistic] {
        if {[ixNet getAttribute $statistic -enabled] != "true"} {
            if {[catch {ixNet setAttribute $statistic -enabled true} err] || $err != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Commit failed while extracting statistics for\
                        '[ixNet getA $view -caption]' on 'ixNet setAttribute $statistic -enabled true'. $err"
                return $returnList
            }
            set commit_needed 1
        }
    }
    
    if {[ixNet getAttribute $view -enabled] != "true"} {
        if {[catch {ixNet setAttribute $view -enabled true} err] || $err != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Commit failed while extracting statistics for\
                    '[ixNet getA $view -caption]' on 'ixNet setAttribute $view -enabled true'. $err"
            return $returnList
        }
        set commit_needed 1
    }
    
    if {$commit_needed} {
        if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Commit failed while extracting statistics for\
                    '[ixNet getA $view -caption]'. $err"
            return $returnList
        }
    }
    
    set statViewObjRef "$view/page"

    if {[catch {ixNet getAttribute $statViewObjRef -totalPages} totalPages]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to get total number of pages for\
                    '[ixNet getA $view -caption]' statistic view. $totalPages"
        return $returnList
    }

    set retry_count 10
    for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
        if {[ixNet getAttribute $statViewObjRef -isReady] == "true"} {
            break
        }
        after 1000
    }
    
    if {[ixNet getAttribute $statViewObjRef -isReady] != "true"} {
        keylset returnList status $::FAILURE
        keylset returnList log "'[ixNet getA $view -caption]' statistic view is not ready."
        return $returnList
    }
    
    set columnCaptions [ixNet getAttribute $statViewObjRef -columnCaptions]
    
    if {$statViewName == "Flow Statistics" || $is_latency_view} {
        
        # max_trk_count is the number of fields that are tracked

        if {$statViewName == "Flow Statistics"} {
            
            # We must add a key called flow_name which is composed by the first columns that
            # represent the tracking used
            set ret_code [::ixia::540trafficGetMaxTiTrack]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set max_trk_count [keylget ret_code ret_val]
            
            # We must add tx port, rx port and traffic item name to the count
            incr max_trk_count 3
            
        } elseif {$is_latency_view} {

            # the traffic item name is not available as stat.
            # Get it from view details
            set ret_code [ixNetworkEvalCmd [list ixNet getA $view/layer23TrafficFlowFilter -trafficItemFilterId]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            set tmp_ti_filter [keylget ret_code ret_val]
            
            set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_ti_filter -name]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            set ti_name [keylget ret_code ret_val]
            
            set tmp_ti_obj [540getTrafficItemByName $ti_name]
            if {$tmp_ti_obj == "_none"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not find a traffic item with '$ti_name' name."
                return $returnList
            }
            
            # We must add a key called flow_name which is composed by the first columns that
            # represent the tracking used
            set ret_code [::ixia::540trafficGetMaxTiTrack $tmp_ti_obj]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set max_trk_count [keylget ret_code ret_val]
            
            # We must add rx port
            incr max_trk_count 1
            
            catch {unset tmp_ti_obj}
            catch {unset tmp_ti_filter}
        }
    }
    
    set currentRow      1
    if {$totalPages == 0} {
        set totalPages 1
    }
    set captionsList ""
    set turn_egress_page true
    set skipFirstRow false
    for {set pageNumber 1} {$pageNumber <= $totalPages} {incr pageNumber} {
        if {[set egress_list [ixNet getList $statViewObjRef egress]] != ""} {
            set is_egress_view 1
            set egress [lindex $egress_list 0]
            set egressRowCount [ixNet getAttribute $egress -rowCount]
        } else {
            set is_egress_view 0
            set egress ""
            set egressRowCount 0
        }
        while {$turn_egress_page} {
            update idletasks
            set turn_egress_page true
            
            if {[catch {ixNet setAttribute $statViewObjRef -currentPage $pageNumber} err] || $err != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not change page number to $pageNumber for $statViewObjRef. $err"
                return $returnList
            }
            
            if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not change page number to $pageNumber for $statViewObjRef. Failed on commit. $err"
                return $returnList
            }
            
            set retry_count 5
            for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
                if {[set rowGroups [ixNet getA $statViewObjRef -rowValues]] != ""} {
                    break
                }
                after 1000
            }

            foreach rows $rowGroups {
                # If rows contains a single element then we must stop
                # because there are no more statistics left
                if {$is_egress_view && [llength $rows] == 1} {
                    set turn_egress_page false
                }
                
                if {$skipFirstRow} {
                    set rows [lrange $rows 1 end]
                }
                
                foreach row $rows {
                    
                    if {$statViewName == "Flow Statistics" || $is_latency_view} {
                        
                        set cellList [lrange $row 0 end]
                        set currentColumn 0
                        if {$statViewName == "Flow Statistics"} {
                            set row_name ""
                        } elseif {$is_latency_view} {
                            
                            set row_name "[lindex $row 0] $ti_name "
                        }
                        
                        foreach tmpCell [lrange $row 1 [expr $max_trk_count - 1]] {
                            if {[llength $tmpCell] > 0} {
                                append row_name "$tmpCell "
                            } else {
                                append row_name "N/A "
                            }
                        }
                        
                        set row_name [string trim $row_name]
                        
                        catch {unset tmpCell}
                    } else {

                        set row_name [lindex $row 0]
                        set cellList [lrange $row 0 end]
                        set currentColumn 0
                    }
                    
                    
                    foreach cell $cellList {
                        set stat_name [lindex $columnCaptions $currentColumn]
                        if {[lsearch $captionsList $stat_name] == -1} {
                            lappend captionsList $stat_name
                        }
                        set stat_value $cell
                        if {[llength $stat_value] == 0} {
                            set stat_value "N/A"
                        }
                        
                        if {[regexp {TimeStamp} $stat_name] && $stat_value == 0} {
                            set stat_value "00:00:00.000"
                        }
                        
                        set rowsArray($pageNumber,$currentRow,$stat_name) $stat_value
                        incr currentColumn
                    }
                    
                    set rowsArray($pageNumber,$currentRow) $row_name
                    incr currentRow
                }
            }
            if {$is_egress_view} {
                # Turn the egress page
                foreach egress_item $egress_list {
                    ixNet setAttribute $egress_item -commitEgressPage true
                }
                ixNet commit
                set skipFirstRow true
            } else {
                set turn_egress_page false
            }
        }
    }
    
    keylset returnList rows     [array get rowsArray]
    keylset returnList captions $captionsList
    keylset returnList page     $pageNumber
    keylset returnList row      $currentRow

    return $returnList
}


proc ::ixia::540GetStatViewStatistic {statViewName {mode "all"} {type ""}} {
    # mode - create - creates the stat view if the stat view was not found
    # mode - all - returns SUCCESS and empty list of stats when the stat view was not found
    # mode - other - returns FAILURE when the stat view was not found
    
    variable ${statViewName}_replace_stat_names_array
    
    keylset returnList status $::SUCCESS
    
    set statViewRoot [ixNet getRoot]statistics
    
    set statViewList [ixNet getList $statViewRoot view]

    set view ""
    foreach statView $statViewList {
        if {[ixNet getAttribute $statView -caption] == $statViewName} {
            set view $statView
            break
        }
    }
   
    if {$view == ""} {
        if {$mode == "create" && $type != ""} {
            set retCode [540CreateUserDefinedView $statViewName $type]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
            set view    [keylget retCode view]
        } elseif {$mode != "all"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not find $statViewName view. Possible causes:\
                    traffic was not started or statistics collected too soon after traffic was started."
            return $returnList
        } else {
            keylset returnList rows ""
            keylset returnList page 0
            keylset returnList row  0
            return $returnList
        }
    }
    
    set commit_needed 0
    set statisticList ""
    set statistics_list [ixNet getList $view statistic]
    
    # if at first you don't succeed
    for {set tries 0} {$tries < 3 && 0 == [llength statistics_list]} {incr tries} {
        # sleep on it, then try again
        after 1000
        set statistics_list [ixNet getList $view statistic]
    }
    
    foreach {statistic} $statistics_list {
        regexp "::ixNet::OBJ-/statistics/view:\"${statViewName}\"/statistic:\"(.+)\"" \
                $statistic statistic_ignore statistic_match
        if {[info exists statistic_match]} {
            regsub -all {\.} $statistic_match {} statistic_match_temp
            if {![info exists statistic_match_temp]} {
                set statistic_match_temp $statistic_match
            }
            set ${statViewName}_replace_stat_names_array($statistic_match_temp) $statistic_match
            lappend statisticList $statistic_match_temp
            catch {unset statistic_match}
            catch {unset statistic_match_temp}
        }
    }
    
    keylset returnList statistics $statisticList

    return $returnList
}

proc ::ixia::540CreateEgressStatsView {args} {
    
    # Returns view with egress tracking enabled for the traffic item specified with
    # -traffic_item parameter
    
    debug "540CreateEgressStatsView $args"
    
    keylset returnList status $::SUCCESS
    
    set man_args {
        -traffic_item          REGEXP ^::ixNet::OBJ-/traffic/trafficItem:\d+$
    }
    
    set opt_args {
        -port_handles          REGEXP ^[0-9]+/[0-9]+/[0-9]+$
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    set ret_code [ixNetworkEvalCmd [list ixNet getA $traffic_item/tracking/egress -enabled]]
    
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    if {[keylget ret_code ret_val] != "true"} {
        debug "540CreateEgressStatsView --> egress not enabled on $traffic_item/tracking/egress"
        keylset returnList status $::FAILURE
        keylset returnList log "egress tracking is not enabled"
        keylset returnList egress_view ""
        return $returnList
    }
    
    # Create a list with standard port_filters
    debug "540CreateEgressStatsView --> Searching for existing view"
    set vport_obj_list ""
    set port_filters_requested ""
    if {[info exists port_handles]} {
        foreach single_port $port_handles {
            set ret_code [ixNetworkGetPortObjref $single_port]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            lappend vport_obj_list [keylget ret_code vport_objref]
        }
        
        foreach vport_obj $vport_obj_list {
            set ret_code [ixNetworkEvalCmd [list ixNet getA $vport_obj -connectedTo]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set parse_string [keylget ret_code ret_val]
            
            foreach {dummy0 dummy1 ch ca po} [split $parse_string /] {}
            
            set ch [lindex [split $ch :] 1]
            regsub -all {\"} $ch {} ch
            
            regsub -all {\:} $ca {} ca
            set ca [string totitle $ca]
            
            regsub -all {\:} $po {} po
            set po [string totitle $po]
            
            if {[llength $ch] == 0 || [llength $ca] == 0 || [llength $po] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to parse '$parse_string'. Parsed chassis is: '$ch'.\
                        Parsed card is: '$ca'. Parsed port is: '$po'."
                return $returnList
            }
            
            lappend port_filters_requested $ch/$ca/$po
        }
    }
    
    debug "540CreateEgressStatsView --> port filters requested are $port_filters_requested"
    
    # Create standard traffic_item_filter name
    set traffic_item_filter_requested ""
    set ret_code [ixNetworkEvalCmd [list ixNet getA $traffic_item -name]]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    set traffic_item_filter_requested [keylget ret_code ret_val]
    debug "540CreateEgressStatsView --> traffic item filter requested is $traffic_item_filter_requested"
    
    # Search to see if there already is such a view
    set ret_code [ixNetworkEvalCmd [list ixNet getL [ixNet getRoot]statistics view]]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    set view_list [keylget ret_code ret_val]
    
    set view_found ""
    foreach existing_view $view_list {
        
        set ret_code [ixNetworkEvalCmd [list ixNet getA $existing_view -type]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        # Check only views of type layer23TrafficFlow
        if {[keylget ret_code ret_val] != "layer23TrafficFlow"} {
            continue
        }
        
        # Check if it's in paged mode
        if {![catch {ixNetworkGetList $existing_view page} page_obj_ref] &&\
            [llength $page_obj_ref] > 0} {
        
            if {[ixNet getAttr $page_obj_ref -egressMode] != "conditional"} {
                continue
            }
        }
        
        # Check if traffic item filter is the one requested
        set ret_code [ixNetworkEvalCmd [list ixNet getA $existing_view/layer23TrafficFlowFilter -trafficItemFilterId]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set tmp_tfid [keylget ret_code ret_val]
        
        if {[llength $tmp_tfid] == 0} {
            continue
        }
        
        set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_tfid -name]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set tmp_tfid_name [keylget ret_code ret_val]
        
        # HLT Egress traffic item filter id must be the same
        if {$tmp_tfid_name != $traffic_item_filter_requested} {
            debug "540CreateEgressStatsView --> Traffic item filter id $tmp_tfid_name is different from what was requested $traffic_item_filter_requested."
            continue
        }
        
        set ret_code [ixNetworkEvalCmd [list ixNet getL $existing_view/layer23TrafficFlowFilter trackingFilter]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        # HLT Egress view will not have trackingFilter
        if {[llength [keylget ret_code ret_val]] > 0} {
            debug "540CreateEgressStatsView --> trackingFilters detected for $existing_view/layer23TrafficFlowFilter. not an egress view."
            continue
        }
        
        set ret_code [ixNetworkEvalCmd [list ixNet getA $existing_view/layer23TrafficFlowFilter -egressLatencyBinDisplayOption]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        # Egress view must be enabled
        if {[keylget ret_code ret_val] != "showEgressRows"} {
            debug "540CreateEgressStatsView --> egressLatencyBinDisplayOption is [keylget ret_code ret_val]. not a valid egress view."
            continue
        }
        
        # Remove from the list with requested port filters, the ones that are not good for this traffic item
        set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_tfid -constraints]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set ti_filter_new_constraints [keylget ret_code ret_val]
        
        set tmp_port_filters_requested ""
        foreach pf_req $port_filters_requested {
            if {[lsearch $ti_filter_new_constraints $pf_req] != -1} {
                lappend tmp_port_filters_requested $pf_req
            }
        }
        
        if {[llength $tmp_port_filters_requested] < 1} {
            keylset returnList status $::FAILURE
            keylset returnList log "Ports '$port_filters_requested' are not valid port filters for\
                    traffic item '$traffic_item'. Valid port filters are: '$ti_filter_new_constraints'."
            return $returnList
        } else {
            set port_filters_requested $tmp_port_filters_requested
            catch {unset tmp_port_filters_requested}
        }
        
        set ret_code [ixNetworkEvalCmd [list ixNet getA $existing_view/layer23TrafficFlowFilter -portFilterIds]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set actual_port_filters ""
        foreach tmp_port_filter [keylget ret_code ret_val] {
            set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_port_filter -name]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            lappend actual_port_filters [keylget ret_code ret_val]
        }
        debug "540CreateEgressStatsView --> Port filters found are $actual_port_filters."
        # Port filter must be equal to what was requested
        
        if {[llength $port_filters_requested] < 1} {
            # Use all accepted ports for filtering
            set ret_code [ixNetworkEvalCmd [list ixNet getL $existing_view availablePortFilter]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            foreach tmp_port_filter [keylget ret_code ret_val] {
                set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_port_filter -name]]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                lappend port_filters_requested [keylget ret_code ret_val]
            }
        }
        
        debug "540CreateEgressStatsView --> Port filters requested are $port_filters_requested."
        
        # Make sure all port filters requested are present in the view
        set continue_flag 0
        foreach requested_pf $port_filters_requested {
            if {[lsearch $actual_port_filters $requested_pf] == -1} {
                debug "540CreateEgressStatsView --> Port filter $requested_pf was not found in the view. View is not identical to our view"
                set continue_flag 1
                break
            }
        }
        if {$continue_flag} {
            continue
        }
        
        #
        # Verify that enumeration filter exists and that it has the egress tracking fields
        #
        
        # Build list with configured egress tracking filters
        set ret_code [ixNetworkEvalCmd [list ixNet getL $existing_view/layer23TrafficFlowFilter enumerationFilter]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set actual_enumeration_filters ""
        foreach tmp_ef [keylget ret_code ret_val] {
            set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_ef -trackingFilterId]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set tmp_tfid [keylget ret_code ret_val]
            lappend actual_enumeration_filters $tmp_tfid
            
        }
        
        debug "540CreateEgressStatsView --> Enumeration filters are: $actual_enumeration_filters"
        
        # Build list with all possible egress tracking filters
        set ret_code [ixNetworkEvalCmd [list ixNet getL $existing_view availableTrackingFilter]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set requested_enumeration_filter ""
        foreach tmp_tfid [keylget ret_code ret_val] {
            
            set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_tfid -constraints]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set trk_constraints_list [keylget ret_code ret_val]
            foreach trk_constraint $trk_constraints_list {
                foreach {constr_type constr_val} [split $trk_constraint =] {}
                if {$constr_type == "trafficItem"} {
                    if {$constr_val == $traffic_item_filter_requested} {
                        lappend requested_enumeration_filter $tmp_tfid
                    }
                }
            }
        }
        
        debug "540CreateEgressStatsView --> Available tracking filters are: $requested_enumeration_filter"
        
        # Compare lists
        set continue_flag 0
        foreach tmp_enum_filter $requested_enumeration_filter {
            if {[lsearch $actual_enumeration_filters $tmp_enum_filter] == -1} {
                debug "540CreateEgressStatsView --> Available tracking filter $tmp_enum_filter is not configured on the view. Not the view we're looking for."
                set continue_flag 1
                break
            }
        }
        if {$continue_flag} {
            continue
        }
        
        # Looks like we found what we want. The view already exists. Use it.
        set view_found $existing_view
        break
    }
    
    # Return the existing view for query
    if {[llength $view_found] > 0} {
        debug "540CreateEgressStatsView --> View found: $view_found."
        keylset returnList egress_view $view_found
        return $returnList
    }
    
    debug "540CreateEgressStatsView --> View not found: Creating it."
    # View does not exist. Create it.
    set result [ixNetworkNodeAdd [ixNet getRoot]statistics view [list \
            -type layer23TrafficFlow -visible true] -commit]
    if {[keylget result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to create new stat view -\
                [keylget result log]."
        return $returnList
    }
    
    set new_view_obj_ref [keylget result node_objref]
    
    # Get available traffic items filters. Match against requested one
    set ret_code [ixNetworkEvalCmd [list ixNet getL $new_view_obj_ref availableTrafficItemFilter]]
    if {[keylget ret_code status] != $::SUCCESS} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        return $ret_code
    }
    set available_ti_filters [keylget ret_code ret_val]
    debug "540CreateEgressStatsView --> Available traffic item filters are: $available_ti_filters"
    
    set ti_filter_new ""
    foreach ti_filter_available $available_ti_filters {
        set ret_code [ixNetworkEvalCmd [list ixNet getA $ti_filter_available -name]]
        if {[keylget ret_code status] != $::SUCCESS} {
            catch {ixNet remove $new_view_obj_ref}
            catch {ixNet commit}
            return $ret_code
        }
        
        set ti_filter_available_name [keylget ret_code ret_val]
        
        if {$ti_filter_available_name == $traffic_item_filter_requested} {
            set ti_filter_new $ti_filter_available
        }
    }
    
    if {[llength $ti_filter_new] < 1} {
        debug "540CreateEgressStatsView --> Traffic item filter $traffic_item_filter_requested was not found\
                among available $available_ti_filters."
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        keylset returnList status $::FAILURE
        keylset returnList log "Traffic item '$traffic_item' is not a vaild traffic item filter.\
                Available traffic item filters are: $available_ti_filters."
        return $returnList
    }
    
    set ret_code [ixNetworkEvalCmd [list ixNet getA $ti_filter_new -constraints]]
    if {[keylget ret_code status] != $::SUCCESS} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        return $ret_code
    }
    
    set ti_filter_new_constraints [keylget ret_code ret_val]
    
    # Get available port filters. Match against requested ones
    
    set ret_code [ixNetworkEvalCmd [list ixNet getL $new_view_obj_ref availablePortFilter]]
    if {[keylget ret_code status] != $::SUCCESS} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        return $ret_code
    }
    set available_port_filters [keylget ret_code ret_val]
    debug "540CreateEgressStatsView --> Available port filters are: $available_port_filters"
    
    set port_filters_new ""
    if {[llength $port_filters_requested] < 1} {
        # Use all available ports
        foreach tmp_port_filter $available_port_filters {
            if {[lsearch $ti_filter_new_constraints [ixNet getA $tmp_port_filter -name]] != -1} {
                lappend port_filters_new $tmp_port_filter
            }
        }
    } else {
        
        # Remove from the list with requested port filters, the ones that are not good for this traffic item
        set tmp_port_filters_requested ""
        foreach pf_req $port_filters_requested {
            if {[lsearch $ti_filter_new_constraints $pf_req] != -1} {
                lappend tmp_port_filters_requested $pf_req
            }
        }
        
        if {[llength $tmp_port_filters_requested] < 1} {
            catch {ixNet remove $new_view_obj_ref}
            catch {ixNet commit}
            keylset returnList status $::FAILURE
            keylset returnList log "Ports '$port_filters_requested' are not a valid for\
                    traffic item '$traffic_item'. Valid port filters are: '$ti_filter_new_constraints'."
            return $returnList
        } else {
            set port_filters_requested $tmp_port_filters_requested
            catch {unset tmp_port_filters_requested}
        }
        
        # Find the requested port filters
        array set available_port_filters_array ""
        foreach port_filter_available $available_port_filters {
            set ret_code [ixNetworkEvalCmd [list ixNet getA $port_filter_available -name]]
            if {[keylget ret_code status] != $::SUCCESS} {
                catch {ixNet remove $new_view_obj_ref}
                catch {ixNet commit}
                return $ret_code
            }
            
            set available_port_filters_array([keylget ret_code ret_val]) $port_filter_available
        }
        
        set available_port_filter_names [array names available_port_filters_array]
        foreach requested_port_filter $port_filters_requested {
            debug "1--> lsearch $available_port_filter_names $requested_port_filter"
            debug "2--> lsearch $ti_filter_new_constraints $requested_port_filter"
            if {[lsearch $available_port_filter_names $requested_port_filter] == -1 || \
                    [lsearch $ti_filter_new_constraints $requested_port_filter] == -1} {
                catch {ixNet remove $new_view_obj_ref}
                catch {ixNet commit}
                keylset returnList status $::FAILURE
                keylset returnList log "Port '$requested_port_filter' is not valid port filter for\
                        traffic item '$traffic_item'. Valid port filters are: '$available_port_filter_names'."
                return $returnList
            }
            
            lappend port_filters_new $available_port_filters_array($requested_port_filter)
        }
    }
    
    debug "540CreateEgressStatsView --> Port filters are: $port_filters_new"
    
    # Configure port filters and traffic item filter for the view
    set result [ixNetworkNodeSetAttr ${new_view_obj_ref}/layer23TrafficFlowFilter \
            [list \
                -egressLatencyBinDisplayOption showEgressRows       \
                -portFilterIds                 $port_filters_new    \
                -trafficItemFilterId           $ti_filter_new      ]\
            -commit]
    if {[keylget result status] == $::FAILURE} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to configure view port and traffic item filters -\
                [keylget result log]."
        return $returnList
    }
    
    # Build a list with all the available egress tracking filters and add them as
    # enumeration filters
    # Build list with all possible egress tracking filters
    set ret_code [ixNetworkEvalCmd [list ixNet getL $new_view_obj_ref availableTrackingFilter]]
    if {[keylget ret_code status] != $::SUCCESS} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        return $ret_code
    }
    
    set requested_enumeration_filter ""
    foreach tmp_tfid [keylget ret_code ret_val] {
        
        set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_tfid -constraints]]
        if {[keylget ret_code status] != $::SUCCESS} {
            catch {ixNet remove $new_view_obj_ref}
            catch {ixNet commit}
            return $ret_code
        }
        
        set trk_constraints_list [keylget ret_code ret_val]
        foreach trk_constraint $trk_constraints_list {
            foreach {constr_type constr_val} [split $trk_constraint =] {}
            if {$constr_type == "trafficItem"} {
                if {$constr_val == $traffic_item_filter_requested} {
                    lappend requested_enumeration_filter $tmp_tfid
                }
            }
        }
    }
    debug "540CreateEgressStatsView --> Tracking filters that will be configured in enumerationFilters are: $requested_enumeration_filter"
    
    set commit_needed 0
    foreach egress_tracking_filter $requested_enumeration_filter {
        set result [ixNetworkNodeAdd ${new_view_obj_ref}/layer23TrafficFlowFilter enumerationFilter\
                [list -trackingFilterId  $egress_tracking_filter ]]
        if {[keylget result status] == $::FAILURE} {
            catch {ixNet remove $new_view_obj_ref}
            catch {ixNet commit}
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to enumeration filter for '${new_view_obj_ref}/layer23TrafficFlowFilter'\
                    with trackingFilterId '$egress_tracking_filter'. [keylget result log]."
            return $returnList
        }
        set commit_needed 1
    }
    
    if {![catch {ixNetworkGetList $new_view_obj_ref page} page_obj_ref] &&\
            [llength $page_obj_ref] > 0} {
        
        if {[ixNet getAttr $page_obj_ref -egressMode] != "conditional"} {
            ixNet setAttr $page_obj_ref -egressMode conditional
            set commit_needed 1
        }
        
        if {![catch {ixNetworkGetList $page_obj_ref egress} egress_obj_ref_list] &&\
                [llength $egress_obj_ref_list] > 0} {
            
            foreach egress_obj_ref $egress_obj_ref_list {
                if {![catch {ixNetworkGetList $egress_obj_ref flowCondition} fc_obj_ref] &&\
                        [llength $fc_obj_ref] > 0} {
                    
                    if {[catch {ixNet setAttr $fc_obj_ref -operator isEqualOrGreater} err] || $err != "::ixNet::OK"} {
                        catch {ixNet remove $new_view_obj_ref}
                        catch {ixNet commit}
                        keylset returnList status $::FAILURE
                        keylset returnList log "Could not ixNet setAttr $fc_obj_ref -operator isEqualOrGreater. $err"
                        return $returnList
                    }
                    
                    set commit_needed 1
                }
            }
        }
    }
    
    #if {$commit_needed} {
        #set ret_code [ixNetworkEvalCmd [list ixNet commit] "ok"]
        #if {[keylget ret_code status] != $::SUCCESS} {
            #catch {ixNet remove $new_view_obj_ref}
            #catch {ixNet commit}
            #return $ret_code
        #}
    #}
    
    foreach stat_key [ixNet getL ${new_view_obj_ref} statistic] {
        set ret_val [ixNet setA $stat_key -enabled true]
        if {$ret_val != "::ixNet::OK"} {
            catch {ixNet remove $new_view_obj_ref}
            catch {ixNet commit}
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to enable $stat_key. $ret_val."
            return $returnList
        }
    }
    
    # Enable statistics here because of bug BUG521961
    set ret_val [ixNet setA ${new_view_obj_ref} -enabled true]
    if {$ret_val != "::ixNet::OK"} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to enable ${new_view_obj_ref}. $ret_val."
        return $returnList
    }
    
    set ret_code [ixNetworkEvalCmd [list ixNet commit] "ok"]
    if {[keylget ret_code status] != $::SUCCESS} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        return $ret_code
    }
    
    set statViewObjRef "$new_view_obj_ref/page"

    set retry_count 10
    for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
        if {[ixNet getAttribute $statViewObjRef -isReady] == "true"} {
            break
        }
        after 1000
    }
    
    if {[ixNet getAttribute $statViewObjRef -isReady] != "true"} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        keylset returnList status $::FAILURE
        keylset returnList log "'[ixNet getA $new_view_obj_ref -caption]' statistic view is not ready."
        return $returnList
    }
    
    keylset returnList egress_view $new_view_obj_ref
    return $returnList
}



proc ::ixia::540CreateEgressStatsViewMultipleTi {args} {
    
    # Returns view with egress tracking enabled for the traffic item specified with
    # -traffic_item parameter
    
    debug "540CreateEgressStatsViewMultipleTi $args"
    
    keylset returnList status $::SUCCESS
    
    set man_args {
        -traffic_items         REGEXP ^::ixNet::OBJ-/traffic/trafficItem:\d+$
    }
    
    set opt_args {
        -port_handles          REGEXP ^[0-9]+/[0-9]+/[0-9]+$
        -egress_stats_list     ANY
        -egress_mode           CHOICES conditional paged
                               DEFAULT paged
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $man_args} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    
    set traffic_items_egress ""
    set traffic_items_non_egress ""
    foreach traffic_item $traffic_items {
        
        set ret_code [ixNetworkEvalCmd [list ixNet getA $traffic_item/tracking/egress -enabled]]
        
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        if {[keylget ret_code ret_val] != "true"} {
            lappend traffic_items_non_egress $traffic_item
        } else {
            lappend traffic_items_egress $traffic_item
        }
    }
    
    if {[llength $traffic_items_egress] == 0} {
        debug "540CreateEgressStatsViewMultipleTi --> egress not enabled on $traffic_items"
        keylset returnList status $::FAILURE
        keylset returnList log "None of the traffic items '$traffic_items' have egress\
                tracking is not enabled"
        keylset returnList egress_view ""
        return $returnList
    }
    
    if {[llength $traffic_items_non_egress] > 0} {
        puts "\nWarning: the following traffic items don't have egress tracking enabled: $traffic_items\
                . The egress statistics will not have information on them.\n"
    }
    
    set traffic_items $traffic_items_egress
    
    # Create a list with standard port_filters
    debug "540CreateEgressStatsViewMultipleTi --> Searching for existing view"
    set vport_obj_list ""
    set port_filters_requested ""
    if {[info exists port_handles]} {
        foreach single_port $port_handles {
            set ret_code [ixNetworkGetPortObjref $single_port]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            lappend vport_obj_list [keylget ret_code vport_objref]
        }
        
        foreach vport_obj $vport_obj_list {
            set ret_code [ixNetworkEvalCmd [list ixNet getA $vport_obj -connectedTo]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set parse_string [keylget ret_code ret_val]
            
            foreach {dummy0 dummy1 ch ca po} [split $parse_string /] {}
            
            set ch [lindex [split $ch :] 1]
            regsub -all {\"} $ch {} ch
            
            regsub -all {\:} $ca {} ca
            set ca [string totitle $ca]
            
            regsub -all {\:} $po {} po
            set po [string totitle $po]
            
            if {[llength $ch] == 0 || [llength $ca] == 0 || [llength $po] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to parse '$parse_string'. Parsed chassis is: '$ch'.\
                        Parsed card is: '$ca'. Parsed port is: '$po'."
                return $returnList
            }
            
            lappend port_filters_requested $ch/$ca/$po
        }
    }
    
    debug "540CreateEgressStatsViewMultipleTi --> port filters requested are $port_filters_requested"
    
    # Create standard traffic_item_filter name
    set traffic_item_filters_requested ""
    foreach traffic_item $traffic_items {
        set ret_code [ixNetworkEvalCmd [list ixNet getA $traffic_item -name]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        lappend traffic_item_filters_requested [keylget ret_code ret_val]
    }
    debug "540CreateEgressStatsViewMultipleTi --> traffic item filters requested is $traffic_item_filters_requested"
    
    # Search to see if there already is such a view
    set ret_code [ixNetworkEvalCmd [list ixNet getL [ixNet getRoot]statistics view]]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    set view_list [keylget ret_code ret_val]
    
    set view_found ""
    foreach existing_view $view_list {
        
        set ret_code [ixNetworkEvalCmd [list ixNet getA $existing_view -type]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        # Check only views of type layer23TrafficFlow
        if {[keylget ret_code ret_val] != "layer23TrafficFlow"} {
            continue
        }
        
        # Check if it's in paged mode
        if {![catch {ixNetworkGetList $existing_view page} page_obj_ref] &&\
                [llength $page_obj_ref] > 0} {
            if {$egress_mode == "paged"} {
                # Check if it's in paged mode
                if {[ixNet getAttr $page_obj_ref -egressMode] != "paged"} {
                    continue
                }
            } else {
                # Check if it's in conditional mode
                if {[ixNet getAttr $page_obj_ref -egressMode] != "conditional"} {
                    continue
                }
            }
        }
        
        # Check if traffic item filter is the one requested
        set ret_code [ixNetworkEvalCmd [list ixNet getA $existing_view/layer23TrafficFlowFilter -trafficItemFilterIds]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set tmp_tfids [keylget ret_code ret_val]
        
        if {[llength $tmp_tfids] == 0 || [llength $tmp_tfids] != [llength $traffic_item_filters_requested]} {
            continue
        }
        
        set tfid_match 1
        foreach tmp_tfid $tmp_tfids {
            set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_tfid -name]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set tmp_tfid_name [keylget ret_code ret_val]
            
            # HLT Egress traffic item filter id must be the same
            if {[lsearch $traffic_item_filters_requested $tmp_tfid_name] == -1} {
                debug "540CreateEgressStatsViewMultipleTi --> Traffic item filter id $tmp_tfid_name is different from what was requested $traffic_item_filters_requested."
                set tfid_match 0
                break
            }
        }
        
        if {!$tfid_match} {
            continue
        }
        
        set ret_code [ixNetworkEvalCmd [list ixNet getL $existing_view/layer23TrafficFlowFilter trackingFilter]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        # HLT Egress view will not have trackingFilter
        if {[llength [keylget ret_code ret_val]] > 0} {
            debug "540CreateEgressStatsViewMultipleTi --> trackingFilters detected for $existing_view/layer23TrafficFlowFilter. not an egress view."
            continue
        }
        
        set ret_code [ixNetworkEvalCmd [list ixNet getA $existing_view/layer23TrafficFlowFilter -egressLatencyBinDisplayOption]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        # Egress view must be enabled
        if {[keylget ret_code ret_val] != "showEgressRows"} {
            debug "540CreateEgressStatsViewMultipleTi --> egressLatencyBinDisplayOption is [keylget ret_code ret_val]. not a valid egress view."
            continue
        }
        
        # Remove from the list with requested port filters, the ones that are not good for this traffic item
        set ti_filter_new_constraints ""
        foreach tmp_tfid $tmp_tfids {
            set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_tfid -constraints]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            append ti_filter_new_constraints " [keylget ret_code ret_val]"
        }
        
        set tmp_port_filters_requested ""
        foreach pf_req $port_filters_requested {
            if {[lsearch $ti_filter_new_constraints $pf_req] != -1} {
                lappend tmp_port_filters_requested $pf_req
            }
        }
        
        if {[llength $tmp_port_filters_requested] < 1} {
            keylset returnList status $::FAILURE
            keylset returnList log "Ports '$port_filters_requested' are not valid port filters for\
                    traffic item '$traffic_items'. Valid port filters are: '$ti_filter_new_constraints'."
            return $returnList
        } else {
            set port_filters_requested $tmp_port_filters_requested
            catch {unset tmp_port_filters_requested}
        }
        
        set ret_code [ixNetworkEvalCmd [list ixNet getA $existing_view/layer23TrafficFlowFilter -portFilterIds]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set actual_port_filters ""
        foreach tmp_port_filter [keylget ret_code ret_val] {
            set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_port_filter -name]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            lappend actual_port_filters [keylget ret_code ret_val]
        }
        debug "540CreateEgressStatsViewMultipleTi --> Port filters found are $actual_port_filters."
        # Port filter must be equal to what was requested
        
        if {[llength $port_filters_requested] < 1} {
            # Use all accepted ports for filtering
            set ret_code [ixNetworkEvalCmd [list ixNet getL $existing_view availablePortFilter]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            foreach tmp_port_filter [keylget ret_code ret_val] {
                set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_port_filter -name]]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                lappend port_filters_requested [keylget ret_code ret_val]
            }
        }
        
        debug "540CreateEgressStatsViewMultipleTi --> Port filters requested are $port_filters_requested."
        
        # Make sure all port filters requested are present in the view
        set continue_flag 0
        foreach requested_pf $port_filters_requested {
            if {[lsearch $actual_port_filters $requested_pf] == -1} {
                debug "540CreateEgressStatsViewMultipleTi --> Port filter $requested_pf was not found in the view. View is not identical to our view"
                set continue_flag 1
                break
            }
        }
        if {$continue_flag} {
            continue
        }
        
        #
        # Verify that enumeration filter exists and that it has the egress tracking fields
        #
        
        # Build list with configured egress tracking filters
        set ret_code [ixNetworkEvalCmd [list ixNet getL $existing_view/layer23TrafficFlowFilter enumerationFilter]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set actual_enumeration_filters ""
        foreach tmp_ef [keylget ret_code ret_val] {
            set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_ef -trackingFilterId]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set tmp_tfid [keylget ret_code ret_val]
            lappend actual_enumeration_filters $tmp_tfid
            
        }
        
        debug "540CreateEgressStatsViewMultipleTi --> Enumeration filters are: $actual_enumeration_filters"
        
        # Build list with all possible egress tracking filters
        set ret_code [ixNetworkEvalCmd [list ixNet getL $existing_view availableTrackingFilter]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set requested_enumeration_filter ""
        foreach tmp_tfid [keylget ret_code ret_val] {
            
            set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_tfid -constraints]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set trk_constraints_list [keylget ret_code ret_val]
            foreach trk_constraint $trk_constraints_list {
                foreach {constr_type constr_val} [split $trk_constraint =] {}
                if {$constr_type == "trafficItem"} {
                    if {[lsearch $traffic_item_filters_requested $constr_val] != -1} {
                        lappend requested_enumeration_filter $tmp_tfid
                    }
                }
            }
        }
        
        debug "540CreateEgressStatsViewMultipleTi --> Available tracking filters are: $requested_enumeration_filter"
        
        # Compare lists
        set continue_flag 0
        foreach tmp_enum_filter $requested_enumeration_filter {
            if {[lsearch $actual_enumeration_filters $tmp_enum_filter] == -1} {
                debug "540CreateEgressStatsViewMultipleTi --> Available tracking filter $tmp_enum_filter is not configured on the view. Not the view we're looking for."
                set continue_flag 1
                break
            }
        }
        if {$continue_flag} {
            continue
        }
        
        # Looks like we found what we want. The view already exists. Use it.
        set view_found $existing_view
        break
    }
    
    # Return the existing view for query
    if {[llength $view_found] > 0} {
        debug "540CreateEgressStatsViewMultipleTi --> View found: $view_found."
        
        if {![catch {ixNetworkGetList $view_found page} page_obj_ref] &&\
                [llength $page_obj_ref] > 0} {
            
            set current_egress_mode [ixNet getAttr $page_obj_ref -egressMode]
            set need_commit 0
            if {($egress_mode == "paged") && ($current_egress_mode != "paged")} {
                ixNet setAttr $page_obj_ref -egressMode paged
                set need_commit 1
            } elseif {($egress_mode == "conditional") && ($current_egress_mode != "conditional")} {
                ixNet setAttr $page_obj_ref -egressMode conditional
                set need_commit 1
            }
            if {$need_commit} {
                # This commit is needed here. DON'T REMOVE IT!
                set ret_code [ixNetworkEvalCmd [list ixNet commit] "ok"]
                if {[keylget ret_code status] != $::SUCCESS} {
                    catch {ixNet remove $view_found}
                    catch {ixNet commit}
                    return $ret_code
                }
            }
            # If view already exists, go to the first ingress page
            if {($egress_mode == "conditional") && (![catch {ixNetworkGetList $page_obj_ref egress} egress_obj_ref_list] &&\
                    [llength $egress_obj_ref_list] > 0)} {
                
                foreach egress_obj_ref $egress_obj_ref_list {
                    if {![catch {ixNetworkGetList $egress_obj_ref flowCondition} fc_obj_ref] &&\
                            [llength $fc_obj_ref] > 0} {
                        
                        if {[catch {ixNet setAttr $fc_obj_ref -operator isEqualOrGreater} err] || $err != "::ixNet::OK"} {
                            catch {ixNet remove $view_found}
                            catch {ixNet commit}
                            keylset returnList status $::FAILURE
                            keylset returnList log "Could not ixNet setAttr $fc_obj_ref -operator isEqualOrGreater. $err"
                            return $returnList
                        }
                        
                        if {[catch {ixNet setAttr $fc_obj_ref -values [list 0]} err] || $err != "::ixNet::OK"} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Could not ixNet setAttr $fc_obj_ref -values [list 0]. $err"
                            return $returnList
                        }
                        
                        set commit_needed 1
                    }
                }
                if {[info exists commit_needed] && $commit_needed} {
                    if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Commit failed while setting flowCondition operator. $err"
                        return $returnList
                    }
                }
            }
        }
        
        keylset returnList egress_view $view_found
        return $returnList
    }
    
    debug "540CreateEgressStatsViewMultipleTi --> View not found: Creating it."
    # View does not exist. Create it.
    set result [ixNetworkNodeAdd [ixNet getRoot]statistics view [list \
            -type layer23TrafficFlow -visible true] -commit]
    if {[keylget result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to create new stat view -\
                [keylget result log]."
        return $returnList
    }
    
    set new_view_obj_ref [keylget result node_objref]
    
    # Get available traffic items filters. Match against requested one
    set ret_code [ixNetworkEvalCmd [list ixNet getL $new_view_obj_ref availableTrafficItemFilter]]
    if {[keylget ret_code status] != $::SUCCESS} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        return $ret_code
    }
    set available_ti_filters [keylget ret_code ret_val]
    debug "540CreateEgressStatsViewMultipleTi --> Available traffic item filters are: $available_ti_filters"
    
    set ti_filter_names ""
    foreach ti_filter_available $available_ti_filters {
        set ret_code [ixNetworkEvalCmd [list ixNet getA $ti_filter_available -name]]
        if {[keylget ret_code status] != $::SUCCESS} {
            catch {ixNet remove $new_view_obj_ref}
            catch {ixNet commit}
            return $ret_code
        }
        
        set ti_filter_available_name [keylget ret_code ret_val]
        
        lappend ti_filter_names $ti_filter_available_name
    }
    
    set ti_filters_new ""
    set non_matching_ti_filters ""
    foreach traffic_item_filter_requested $traffic_item_filters_requested {
        set idx [lsearch $ti_filter_names $traffic_item_filter_requested]
        if {$idx == -1} {
            lappend non_matching_ti_filters $traffic_item_filter_requested
        } else {
            # available_ti_filters and ti_filter_names have the same length and same information, only in different format
            # it's safe to get the corresponding item at index $idx from $available_ti_filters
            lappend ti_filters_new [lindex $available_ti_filters $idx]
        }
    }
    
    if {[llength $ti_filters_new] < 1} {
        debug "540CreateEgressStatsViewMultipleTi --> Traffic item filters $non_matching_ti_filters were not found\
                among available $available_ti_filters."
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        keylset returnList status $::FAILURE
        keylset returnList log "Traffic items '$traffic_items' is not a vaild traffic item filter.\
                Available traffic item filters are: $available_ti_filters."
        return $returnList
    }
    
    set ti_filter_new_constraints ""
    foreach ti_filter_new $ti_filters_new {
        set ret_code [ixNetworkEvalCmd [list ixNet getA $ti_filter_new -constraints]]
        if {[keylget ret_code status] != $::SUCCESS} {
            catch {ixNet remove $new_view_obj_ref}
            catch {ixNet commit}
            return $ret_code
        }
        
        append ti_filter_new_constraints " [keylget ret_code ret_val]"
    }
    
    set ti_filter_new_constraints [lsort -unique $ti_filter_new_constraints]
    
    # Get available port filters. Match against requested ones
    
    set ret_code [ixNetworkEvalCmd [list ixNet getL $new_view_obj_ref availablePortFilter]]
    if {[keylget ret_code status] != $::SUCCESS} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        return $ret_code
    }
    set available_port_filters [keylget ret_code ret_val]
    debug "540CreateEgressStatsViewMultipleTi --> Available port filters are: $available_port_filters"
    
    set port_filters_new ""
    if {[llength $port_filters_requested] < 1} {
        # Use all available ports
        foreach tmp_port_filter $available_port_filters {
            if {[lsearch $ti_filter_new_constraints [ixNet getA $tmp_port_filter -name]] != -1} {
                lappend port_filters_new $tmp_port_filter
            }
        }
    } else {
        
        # Remove from the list with requested port filters, the ones that are not good for this traffic item
        set tmp_port_filters_requested ""
        foreach pf_req $port_filters_requested {
            if {[lsearch $ti_filter_new_constraints $pf_req] != -1} {
                lappend tmp_port_filters_requested $pf_req
            }
        }
        
        if {[llength $tmp_port_filters_requested] < 1} {
            catch {ixNet remove $new_view_obj_ref}
            catch {ixNet commit}
            keylset returnList status $::FAILURE
            keylset returnList log "Ports '$port_filters_requested' are not a valid for\
                    traffic items '$traffic_items'. Valid port filters are: '$ti_filter_new_constraints'."
            return $returnList
        } else {
            set port_filters_requested [lsort -unique $tmp_port_filters_requested]
            catch {unset tmp_port_filters_requested}
        }
        
        # Find the requested port filters
        array set available_port_filters_array ""
        foreach port_filter_available $available_port_filters {
            set ret_code [ixNetworkEvalCmd [list ixNet getA $port_filter_available -name]]
            if {[keylget ret_code status] != $::SUCCESS} {
                catch {ixNet remove $new_view_obj_ref}
                catch {ixNet commit}
                return $ret_code
            }
            
            set available_port_filters_array([keylget ret_code ret_val]) $port_filter_available
        }
        
        set available_port_filter_names [array names available_port_filters_array]
        foreach requested_port_filter $port_filters_requested {
            debug "1--> lsearch $available_port_filter_names $requested_port_filter"
            debug "2--> lsearch $ti_filter_new_constraints $requested_port_filter"
            if {[lsearch $available_port_filter_names $requested_port_filter] == -1 || \
                    [lsearch $ti_filter_new_constraints $requested_port_filter] == -1} {
                catch {ixNet remove $new_view_obj_ref}
                catch {ixNet commit}
                keylset returnList status $::FAILURE
                keylset returnList log "Port '$requested_port_filter' is not valid port filter for\
                        traffic items '$traffic_items'. Valid port filters are: '$available_port_filter_names'."
                return $returnList
            }
            
            lappend port_filters_new $available_port_filters_array($requested_port_filter)
        }
    }
    
    debug "540CreateEgressStatsViewMultipleTi --> Port filters are: $port_filters_new"
    
    # Configure port filters and traffic item filter for the view
    set result [ixNetworkNodeSetAttr ${new_view_obj_ref}/layer23TrafficFlowFilter \
            [list \
                -egressLatencyBinDisplayOption showEgressRows       \
                -portFilterIds                 $port_filters_new    \
                -trafficItemFilterIds          $ti_filters_new     ]\
            -commit]
    if {[keylget result status] == $::FAILURE} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to configure view port and traffic item filters -\
                [keylget result log]."
        return $returnList
    }
    
    # Build a list with all the available egress tracking filters and add them as
    # enumeration filters
    # Build list with all possible egress tracking filters
    set ret_code [ixNetworkEvalCmd [list ixNet getL $new_view_obj_ref availableTrackingFilter]]
    if {[keylget ret_code status] != $::SUCCESS} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        return $ret_code
    }
    
    set requested_enumeration_filter ""
    foreach tmp_tfid [keylget ret_code ret_val] {
        
        set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_tfid -constraints]]
        if {[keylget ret_code status] != $::SUCCESS} {
            catch {ixNet remove $new_view_obj_ref}
            catch {ixNet commit}
            return $ret_code
        }
        
        set trk_constraints_list [keylget ret_code ret_val]
        foreach trk_constraint $trk_constraints_list {
            foreach {constr_type constr_val} [split $trk_constraint =] {}
            if {$constr_type == "trafficItem"} {
                if {[lsearch $traffic_item_filters_requested $constr_val] != -1} {
                    lappend requested_enumeration_filter $tmp_tfid
                }
            }
        }
    }
    
    
    set requested_enumeration_filter [lsort -unique $requested_enumeration_filter]
    debug "540CreateEgressStatsViewMultipleTi --> Tracking filters that will be configured in enumerationFilters are: $requested_enumeration_filter"
    
    set commit_needed 0
    foreach egress_tracking_filter $requested_enumeration_filter {
        set result [ixNetworkNodeAdd ${new_view_obj_ref}/layer23TrafficFlowFilter enumerationFilter\
                [list -trackingFilterId  $egress_tracking_filter]]
        if {[keylget result status] == $::FAILURE} {
            catch {ixNet remove $new_view_obj_ref}
            catch {ixNet commit}
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to add enumeration filter for '${new_view_obj_ref}/layer23TrafficFlowFilter'\
                    with trackingFilterId '$egress_tracking_filter'. [keylget result log]."
            return $returnList
        }
    }
    
    if {![catch {ixNetworkGetList $new_view_obj_ref page} page_obj_ref] &&\
            [llength $page_obj_ref] > 0} {
        
        set current_egress_mode [ixNet getAttr $page_obj_ref -egressMode]
        set need_commit 0
        if {($egress_mode == "paged") && ($current_egress_mode != "paged")} {
            ixNet setAttr $page_obj_ref -egressMode paged
            set need_commit 1
        } elseif {($egress_mode == "conditional") && ($current_egress_mode != "conditional")} {
            ixNet setAttr $page_obj_ref -egressMode conditional
            set need_commit 1
        }
        if {$need_commit} {
            # This commit is needed here. DON'T REMOVE IT!
            # If it's removed you'll get this error:
            #       ::ixNet::ERROR-statviewer.api.PagingException: View Info Provider is not found for this view. Please check to see if this is a flow aggregation view.
            set ret_code [ixNetworkEvalCmd [list ixNet commit] "ok"]
            if {[keylget ret_code status] != $::SUCCESS} {
                catch {ixNet remove $new_view_obj_ref}
                catch {ixNet commit}
                return $ret_code
            }
        }
        
    }
    
    
    if {$egress_stats_list == "all"} {
        set stat_key_list [ixNet getL ${new_view_obj_ref} statistic]
    } else {
        set trafficStatsList {
            "Tx Frames"                     tx.total_pkts
            "Rx Expected Frames"            rx.expected_pkts
            "Rx Frames"                     rx.total_pkts
            "Frames Delta"                  rx.loss_pkts
            "Loss %"                        rx.loss_percent
            "Packet Loss Duration (ms)"     rx.pkt_loss_duration
            "Tx Frame Rate"                 tx.total_pkt_rate
            "Rx Frame Rate"                 rx.total_pkt_rate
            "Rx Bytes"                      rx.total_pkts_bytes
            "Tx Rate (Bps)"                 tx.total_pkt_byte_rate
            "Rx Rate (Bps)"                 rx.total_pkt_byte_rate
            "Tx Rate (bps)"                 tx.total_pkt_bit_rate
            "Rx Rate (bps)"                 rx.total_pkt_bit_rate
            "Tx Rate (Kbps)"                tx.total_pkt_kbit_rate
            "Rx Rate (Kbps)"                rx.total_pkt_kbit_rate
            "Tx Rate (Mbps)"                tx.total_pkt_mbit_rate
            "Rx Rate (Mbps)"                rx.total_pkt_mbit_rate
            "Store-Forward Avg Latency (ns)" rx.avg_delay
            "Store-Forward Min Latency (ns)" rx.min_delay
            "Store-Forward Max Latency (ns)" rx.max_delay
            "First Timestamp"               rx.first_tstamp
            "Last Timestamp"                rx.last_tstamp
        }
        set stat_key_list ""
        foreach key_elem $egress_stats_list {
            foreach {ixn_caption hlt_key} $trafficStatsList {
                if {$hlt_key == $key_elem} {
                    lappend stat_key_list "${new_view_obj_ref}/statistic:\"${ixn_caption}\""
                    break
                }
            }
        }
    }
    
    foreach stat_key $stat_key_list {
        set ret_val [ixNet setA $stat_key -enabled true]
        if {$ret_val != "::ixNet::OK"} {
            catch {ixNet remove $new_view_obj_ref}
            catch {ixNet commit}
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to enable $stat_key. $ret_val."
            return $returnList
        }
    }
    
    # Enable statistics here because of bug BUG521961
    set ret_val [ixNet setA ${new_view_obj_ref} -enabled true]
    if {$ret_val != "::ixNet::OK"} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to enable ${new_view_obj_ref}. $ret_val."
        return $returnList
    }
    
    set ret_code [ixNetworkEvalCmd [list ixNet commit] "ok"]
    if {[keylget ret_code status] != $::SUCCESS} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        return $ret_code
    }
    
    set statViewObjRef "$new_view_obj_ref/page"

    set retry_count 10
    for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
        if {[ixNet getAttribute $statViewObjRef -isReady] == "true"} {
            break
        }
        after 1000
    }
    
    if {[ixNet getAttribute $statViewObjRef -isReady] != "true"} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        keylset returnList status $::FAILURE
        keylset returnList log "'[ixNet getA $new_view_obj_ref -caption]' statistic view is not ready."
        return $returnList
    }
    
    keylset returnList egress_view $new_view_obj_ref
    return $returnList
}


proc ::ixia::540CreateLatencyStatsView {args} {
    
    # Returns view with latency tracking enabled for the traffic item specified with
    # -traffic_item parameter
    
    debug "540CreateLatencyStatsView $args"
    
    keylset returnList status $::SUCCESS
    
    set man_args {
        -traffic_item          REGEXP ^::ixNet::OBJ-/traffic/trafficItem:\d+$
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args \
            -mandatory_args $man_args} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    set ret_code [ixNetworkEvalCmd [list ixNet getA $traffic_item/tracking/latencyBin -enabled]]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    if {[keylget ret_code ret_val] != "true"} {
        debug "540CreateLatencyStatsView --> latencyBins not enabled on $traffic_item/tracking/latencyBin"
        keylset returnList latency_view ""
        return $returnList
    }
    
    # Create a list with standard port_filters
    debug "540CreateLatencyStatsView --> Searching for existing view"
    set vport_obj_list ""
    
    # Create standard traffic_item_filter name
    set traffic_item_filter_requested ""
    set ret_code [ixNetworkEvalCmd [list ixNet getA $traffic_item -name]]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    set traffic_item_filter_requested [keylget ret_code ret_val]
    debug "540CreateLatencyStatsView --> traffic item filter requested is $traffic_item_filter_requested"
    
    # Search to see if there already is such a view
    set ret_code [ixNetworkEvalCmd [list ixNet getL [ixNet getRoot]statistics view]]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    set view_list [keylget ret_code ret_val]
    
    set view_found 0
    foreach existing_view $view_list {
        
        set ret_code [ixNetworkEvalCmd [list ixNet getA $existing_view -type]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        # Check only views of type layer23TrafficFlow
        if {[keylget ret_code ret_val] != "layer23TrafficFlow"} {
            continue
        }
        
        # Check if traffic item filter is the one requested
        set ret_code [ixNetworkEvalCmd [list ixNet getA $existing_view/layer23TrafficFlowFilter -trafficItemFilterId]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set tmp_tfid [keylget ret_code ret_val]
        
        if {$tmp_tfid != ""} {
            set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_tfid -name]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set tmp_tfid_name [keylget ret_code ret_val]
        } else {
            continue
        }
        
        # HLT Latency traffic item filter id must be the same
        if {$tmp_tfid_name != $traffic_item_filter_requested} {
            debug "540CreateLatencyStatsView --> Traffic item filter id $tmp_tfid_name is different from what was requested $traffic_item_filter_requested."
            continue
        }
        
        set ret_code [ixNetworkEvalCmd [list ixNet getL $existing_view/layer23TrafficFlowFilter trackingFilter]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        # HLT Latency view will not have trackingFilter
        if {[llength [keylget ret_code ret_val]] > 0} {
            debug "540CreateLatencyStatsView --> trackingFilters detected for $existing_view/layer23TrafficFlowFilter. not an latency view."
            continue
        }
        
        set ret_code [ixNetworkEvalCmd [list ixNet getA $existing_view/layer23TrafficFlowFilter -egressLatencyBinDisplayOption]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        # Latency view must be enabled
        if {[keylget ret_code ret_val] != "showLatencyBinStats"} {
            debug "540CreateLatencyStatsView --> egressLatencyBinDisplayOption is [keylget ret_code ret_val]. not a valid latency view."
            continue
        }
        
        set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_tfid -constraints]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set port_filters_accepted_by_ti [keylget ret_code ret_val]
        debug "540CreateLatencyStatsView --> Port filters constraints on $tmp_tfid are $port_filters_accepted_by_ti."
        
        set ret_code [ixNetworkEvalCmd [list ixNet getA $existing_view/layer23TrafficFlowFilter -portFilterIds]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set ret_val [keylget ret_code ret_val]
        
        set actual_port_filters ""
        if {[llength $ret_val] > 0} {
            foreach tmp_port_filter $ret_val {
                set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_port_filter -name]]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                lappend actual_port_filters [keylget ret_code ret_val]
            }
        }
        debug "540CreateLatencyStatsView --> Port filters found are $actual_port_filters."
        # Port filter must be equal to what was requested
        
        set continue_flag 0
        foreach port_filter $port_filters_accepted_by_ti {
            if {[lsearch $actual_port_filters $port_filter] == -1} {
                debug "540CreateLatencyStatsView --> Port filters accepted $port_filter is not configured as filter."
                set continue_flag 1
                break
            }
        }
        
        if {$continue_flag} {
            continue
        }
        
        #
        # Verify that enumeration filter exists and that it has the latency tracking fields
        #
        
        # Build list with configured ingress tracking filters
        set ret_code [ixNetworkEvalCmd [list ixNet getL $existing_view/layer23TrafficFlowFilter enumerationFilter]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set actual_enumeration_filters ""
        foreach tmp_ef [keylget ret_code ret_val] {
            set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_ef -trackingFilterId]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set tmp_tfid [keylget ret_code ret_val]
            
            set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_tfid -trackingType]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            if {[keylget ret_code ret_val] == "kPerTrafficItem"} {
                lappend actual_enumeration_filters $tmp_tfid
            } 
        }
        
        debug "540CreateViewLatencyStats --> Enumeration filters are: $actual_enumeration_filters"
        
        # Build list with all possible latency tracking filters
        set ret_code [ixNetworkEvalCmd [list ixNet getL $existing_view availableTrackingFilter]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        set requested_enumeration_filter ""
        foreach tmp_tfid [keylget ret_code ret_val] {
            
            set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_tfid -trackingType]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            if {[keylget ret_code ret_val] == "kPerTrafficItem"} {
                lappend requested_enumeration_filter $tmp_tfid
            } 
        }
        
        debug "540CreateViewLatencyStats --> Available tracking filters are: $requested_enumeration_filter"
        
        # Compare lists
        set continue_flag 0
        foreach tmp_enum_filter $requested_enumeration_filter {
            if {[lsearch $actual_enumeration_filters $tmp_enum_filter] == -1} {
                debug "540CreateViewLatencyStats --> Available tracking filter $tmp_enum_filter is not configured on the view. Not the view we're looking for."
                set continue_flag 1
                break
            }
        }
        if {$continue_flag} {
            continue
        }
        
        # Looks like we found what we want. The view already exists. Use it.
        set view_found 1
        break
    }

    # Return the existing view for query
    if {$view_found} {
        debug "540CreateViewLatencyStats --> View found: $existing_view."
        keylset returnList latency_view $existing_view
        return $returnList
    }
    
    debug "540CreateViewLatencyStats --> View not found: Creating it."
    # View does not exist. Create it.
    set result [ixNetworkNodeAdd [ixNet getRoot]statistics view [list \
            -type layer23TrafficFlow -visible true] -commit]
    if {[keylget result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to create new stat view -\
                [keylget result log]."
        return $returnList
    }
    
    set new_view_obj_ref [keylget result node_objref]
    
    # Get available traffic items filters. Match against requested one
    set ret_code [ixNetworkEvalCmd [list ixNet getL $new_view_obj_ref availableTrafficItemFilter]]
    if {[keylget ret_code status] != $::SUCCESS} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        return $ret_code
    }
    set available_ti_filters [keylget ret_code ret_val]
    debug "540CreateViewLatencyStats --> Available traffic item filters are: $available_ti_filters"
    
    set ti_filter_new ""
    foreach ti_filter_available $available_ti_filters {
        set ret_code [ixNetworkEvalCmd [list ixNet getA $ti_filter_available -name]]
        if {[keylget ret_code status] != $::SUCCESS} {
            catch {ixNet remove $new_view_obj_ref}
            catch {ixNet commit}
            return $ret_code
        }
        
        set ti_filter_available_name [keylget ret_code ret_val]
        
        if {$ti_filter_available_name == $traffic_item_filter_requested} {
            set ti_filter_new $ti_filter_available
            break
        }
    }
    
    if {[llength $ti_filter_new] < 1} {
        debug "540CreateViewLatencyStats --> Traffic item filter $traffic_item_filter_requested was not found\
                among available $available_ti_filters."
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        keylset returnList status $::SUCCESS
        keylset returnList latency_view ""
        return $returnList
    }
    
    set ret_code [ixNetworkEvalCmd [list ixNet getA $ti_filter_new -constraints]]
    if {[keylget ret_code status] != $::SUCCESS} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        return $ret_code
    }
    
    set ti_filter_new_constraints [keylget ret_code ret_val]
    
    # Get available port filters. Match against requested ones
    
    set ret_code [ixNetworkEvalCmd [list ixNet getL $new_view_obj_ref availablePortFilter]]
    if {[keylget ret_code status] != $::SUCCESS} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        return $ret_code
    }
    set available_port_filters [keylget ret_code ret_val]
    debug "540CreateViewLatencyStats --> Available port filters are: $available_port_filters"
    
    set port_filters_new ""
    # Use all available ports
    foreach tmp_port_filter $available_port_filters {
        if {[lsearch $ti_filter_new_constraints [ixNet getA $tmp_port_filter -name]] != -1} {
            lappend port_filters_new $tmp_port_filter
        }
    }
    
    debug "540CreateViewLatencyStats --> Port filters are: $port_filters_new"
    
    # Configure port filters and traffic item filter for the view
    set result [ixNetworkNodeSetAttr ${new_view_obj_ref}/layer23TrafficFlowFilter \
            [list \
                -egressLatencyBinDisplayOption showLatencyBinStats  \
                -portFilterIds                 $port_filters_new    \
                -trafficItemFilterId           $ti_filter_new      ]\
            -commit]
    if {[keylget result status] == $::FAILURE} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to configure view port and traffic item filters -\
                [keylget result log]."
        return $returnList
    }
    
    # Build a list with all the available ingress tracking filters and add them as
    # enumeration filters
    # Build list with all possible ingress tracking filters
    set ret_code [ixNetworkEvalCmd [list ixNet getL $new_view_obj_ref availableTrackingFilter]]
    if {[keylget ret_code status] != $::SUCCESS} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        return $ret_code
    }
    set requested_enumeration_filter ""
    foreach tmp_tfid [keylget ret_code ret_val] {
        
        set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_tfid -trackingType]]
        if {[keylget ret_code status] != $::SUCCESS} {
            catch {ixNet remove $new_view_obj_ref}
            catch {ixNet commit}
            return $ret_code
        }
        
        if {[keylget ret_code ret_val] == "kPerTrafficItem"} {
            lappend requested_enumeration_filter $tmp_tfid
        } 
    }
    debug "540CreateViewLatencyStats --> Tracking filters that will be configured in enumerationFilters are: $requested_enumeration_filter"
    
    set commit_needed 0
    foreach ingress_tracking_filter $requested_enumeration_filter {
        set result [ixNetworkNodeAdd ${new_view_obj_ref}/layer23TrafficFlowFilter enumerationFilter\
                [list -trackingFilterId  $ingress_tracking_filter ]]
        if {[keylget result status] == $::FAILURE} {
            catch {ixNet remove $new_view_obj_ref}
            catch {ixNet commit}
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to add enumeration filter for '${new_view_obj_ref}/layer23TrafficFlowFilter'\
                    with trackingFilterId '$ingress_tracking_filter'. [keylget result log]."
            return $returnList
        }
        set commit_needed 1
    }
    
    if {$commit_needed} {
        set ret_code [ixNetworkEvalCmd [list ixNet commit] "ok"]
        if {[keylget ret_code status] != $::SUCCESS} {
            catch {ixNet remove $new_view_obj_ref}
            catch {ixNet commit}
            return $ret_code
        }
    }
    
    foreach stat_key [ixNet getL ${new_view_obj_ref} statistic] {
        set ret_val [ixNet setA $stat_key -enabled true]
        if {$ret_val != "::ixNet::OK"} {
            catch {ixNet remove $new_view_obj_ref}
            catch {ixNet commit}
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to enable $stat_key. $ret_val."
            return $returnList
        }
    }
    
    # Enable statistics here because of bug BUG521961
    set ret_val [ixNet setA ${new_view_obj_ref} -enabled true]
    if {$ret_val != "::ixNet::OK"} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to enable ${new_view_obj_ref}. $ret_val."
        return $returnList
    }
    
    set ret_code [ixNetworkEvalCmd [list ixNet commit] "ok"]
    if {[keylget ret_code status] != $::SUCCESS} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        return $ret_code
    }
    
    set statViewObjRef "$new_view_obj_ref/page"

    set retry_count 10
    for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
        if {[ixNet getAttribute $statViewObjRef -isReady] == "true"} {
            break
        }
        after 1000
    }
    
    if {[ixNet getAttribute $statViewObjRef -isReady] != "true"} {
        keylset returnList status $::FAILURE
        keylset returnList log "'[ixNet getA $new_view_obj_ref -caption]' statistic view is not ready."
        return $returnList
    }
    
    keylset returnList latency_view $new_view_obj_ref
    return $returnList
}


proc ::ixia::540CreateUserDefinedView {caption type {mode "reuse"}} {
    # mode - reuse - reuses existing user defined view
    # mode - other - deletes existing user defined view and creates a new one
    foreach {view} [ixNet getList [ixNet getRoot]statistics view] {
        if {[ixNet getAttribute $view -caption] == $caption } {
            if {$mode == "reuse" && ([ixNet getAttribute $view -type] == $type)} {
                keylset returnList status $::SUCCESS
                keylset returnList view   $view
                return $returnList
            } else {
                if {[catch {set retCode [ixNet remove $view]} retCode] || $retCode != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to remove existing view - $view. $retCode"
                    return $returnList
                }
                if {[catch {set retCode [ixNet commit]} retCode] || $retCode != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to remove existing view - $view. $retCode"
                    return $returnList
                }
            }
        }
    }
    # this after is due to BUG1125050:	Jasper Native QSFP 
    after 1000
    set view [ixNet add [ixNet getRoot]statistics view]
    ixNet setAttribute $view -caption     $caption
    ixNet setAttribute $view -type        $type
    
    if {[catch {set retCode [ixNet commit]} retCode] || $retCode != "::ixNet::OK"} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to add view - $view. $retCode"
        return $returnList
    }
    keylset returnList status $::SUCCESS
    keylset returnList view   [lindex [ixNet remapIds $view] end]
    return $returnList
}

proc ::ixia::540ReturnUserDefinedViewValues {} {
    uplevel {
        
        
        set pageCount [keylget retCode page]
        set rowCount  [keylget retCode row]
        
        array set rowsArray [keylget retCode rows]
        set captionsList    [keylget retCode captions]
        set statType ""
        set resetPortList ""
        set k 1
        for {set i 1} {$i < $pageCount} {incr i} {
            for {set j 1} {$j < $rowCount} {incr j} {
                if {![info exists rowsArray($i,$j)]} { continue }
                
                # set rowName $rowsArray($i,$j)
                
                set rowName $k
                regsub -all {\.} $rowName {_} rowName
                foreach statName $captionsList {
                    regsub -all {\.} $statName {} statNameTemp
                    if {![info exists statNameTemp]} {
                        set statNameTemp $statName
                    }
                    set ${uds_type}_replace_stat_names_array($statNameTemp) $statName
                    if {![info exists rowsArray($i,$j,$statName)] } {
                        set [subst $keyed_array_name]($rowName.$statNameTemp) "N/A"
                        incr keyed_array_index
                        continue
                    }
                    if {[catch {set [subst $keyed_array_name]($rowName.$statNameTemp)} oldValue]} {
                        set [subst $keyed_array_name]($rowName.$statNameTemp) $rowsArray($i,$j,$statName)
                        if {$statType == "avg"} {
                            set avg_calculator_array([subst $keyed_array_name],$rowName.$statNameTemp) 1
                        }
                        incr keyed_array_index
                    } else {
                        if {$statType == "sum"} {
                            if {$oldValue != ""} {
                                set [subst $keyed_array_name]($rowName.$statNameTemp) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                incr keyed_array_index
                            }
                        } elseif {$statType == "avg"} {
                            if {$oldValue != ""} {
                                set [subst $keyed_array_name]($rowName.$statNameTemp) [mpexpr $rowsArray($i,$j,$statName) + $oldValue]
                                incr avg_calculator_array([subst $keyed_array_name],$rowName.$statNameTemp)
                                incr keyed_array_index
                            }
                        } else {
                            set [subst $keyed_array_name]($rowName.$statNameTemp) $rowsArray($i,$j,$statName)
                            incr keyed_array_index
                        }
                    }
                }
                incr k
            }
        }
        set [subst $keyed_array_name](row_count) [expr $k - 1]
        incr keyed_array_index
    }
}


proc ::ixia::540GetEgressStatView {statViewName {mode "all"}} {
    
    keylset returnList status $::SUCCESS
    
    set statViewRoot [ixNet getRoot]statistics
    
    set statViewList [ixNet getList $statViewRoot view]

    set view ""
    foreach statView $statViewList {
        if {[ixNet getAttribute $statView -caption] == $statViewName} {
            set view $statView
            break
        }
    }
   
    if {$view == ""} {
        if {$mode != "all"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not find $statViewName view. Possible causes:\
                    traffic was not started or statistics collected too soon after traffic was started."
            return $returnList
        } else {
            keylset returnList rows ""
            keylset returnList page 0
            keylset returnList row  0
            return $returnList
        }
    }

    set commit_needed 0
    foreach {statistic} [ixNet getList $view statistic] {
        if {[ixNet getAttribute $statistic -enabled] != "true"} {
            if {[catch {ixNet setAttribute $statistic -enabled true} err] || $err != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Commit failed while extracting statistics for\
                        '[ixNet getA $view -caption]' on 'ixNet setAttribute $statistic -enabled true'. $err"
                return $returnList
            }
            set commit_needed 1
        }
    }
    
    if {[ixNet getAttribute $view -enabled] != "true"} {
        if {[catch {ixNet setAttribute $view -enabled true} err] || $err != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Commit failed while extracting statistics for\
                    '[ixNet getA $view -caption]' on 'ixNet setAttribute $view -enabled true'. $err"
            return $returnList
        }
        set commit_needed 1
    }
    
    if {$commit_needed} {
        if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Commit failed while extracting statistics for\
                    '[ixNet getA $view -caption]'. $err"
            return $returnList
        }
    }
    
    set statViewObjRef  "$view/page"

    if {[catch {ixNet getAttribute $statViewObjRef -totalPages} totalPages]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to get total number of pages for\
                    '[ixNet getA $view -caption]' statistic view. $totalPages"
        return $returnList
    }
    
    set egressPageSize [ixNet getAttr $statViewObjRef -egressPageSize]
    
    if {[catch {ixNet getList $statViewObjRef egress} estatViewObjRefList] ||\
            [llength $estatViewObjRefList] == 0} {
                
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to get total number of pages for\
                    '[ixNet getA $view -caption]' statistic view. Egress object is\
                    missing: $estatViewObjRefList"
        return $returnList
    }
    
    set commit_needed 0
    foreach estatViewObjRef $estatViewObjRefList {
        if {[catch {ixNet getList $estatViewObjRef flowCondition} efcstatViewObjRef] ||\
                [llength $efcstatViewObjRef] == 0} {
                    
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to get flowCondition object for\
                        '[ixNet getA $view -caption]' statistic view. flowCondition object is\
                        missing: $efcstatViewObjRef"
            return $returnList
        }
        
        if {[catch {ixNet getA $efcstatViewObjRef -operator} err] || $err != "isEqualOrGreater"} {
            set commit_needed 1
        
            if {[catch {ixNet setAttr $efcstatViewObjRef -operator isEqualOrGreater} err] || $err != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not ixNet setAttr $efcstatViewObjRef -operator isEqualOrGreater. $err"
                return $returnList
            }
        }
        
        if {[catch {ixNet getA $efcstatViewObjRef -values} err] || $err != "0"} {
            set commit_needed 1
        
            if {[catch {ixNet setAttr $efcstatViewObjRef -values [list 0]} err] || $err != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not ixNet setAttr $efcstatViewObjRef -values [list 0]. $err"
                return $returnList
            }
        }
    }
    
    if {$commit_needed} {
        if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Commit failed while extracting statistics for\
                    '[ixNet getA $view -caption]'. $err"
            return $returnList
        }
    }
    
    set retry_count 10
    for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
        if {[ixNet getAttribute $statViewObjRef -isReady] == "true"} {
            break
        }
        after 1000
    }
    
    if {[ixNet getAttribute $statViewObjRef -isReady] != "true"} {
        keylset returnList status $::FAILURE
        keylset returnList log "'[ixNet getA $view -caption]' statistic view is not ready."
        return $returnList
    }
    
    set columnCaptions [ixNet getAttribute $statViewObjRef -columnCaptions]
    set rx_port_column_idx [lsearch $columnCaptions "Rx Port"]
    if {$rx_port_column_idx == -1} {
        debug "Rx Port column not found while gathering egress stats. ixNet getAttribute $statViewObjRef -columnCaptions\
                returned $columnCaptions"
        set rx_port_column_idx 0
    }
    
    set egress_tracking_column_idx [lsearch -glob $columnCaptions "Egress Tracking*"]
    if {$rx_port_column_idx == -1} {
        # Can't live without it
        keylset returnList status $::FAILURE
        keylset returnList log "Egress Tracking column not found while gathering egress stats. ixNet getAttribute $statViewObjRef -columnCaptions\
                returned $columnCaptions"
        return $returnList
    }
    
    keylset returnList egress_tracking_col [lindex $columnCaptions $egress_tracking_column_idx]
    
    # max_trk_count is the number of fields that are tracked

    # the traffic item name is not available as stat.
    # Get it from view details
    set ret_code [ixNetworkEvalCmd [list ixNet getA $view/layer23TrafficFlowFilter -trafficItemFilterId]]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    set tmp_ti_filter [keylget ret_code ret_val]
    
    set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_ti_filter -name]]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    set ti_name [keylget ret_code ret_val]
    
    set tmp_ti_obj [540getTrafficItemByName $ti_name]
    if {$tmp_ti_obj == "_none"} {
        keylset returnList status $::FAILURE
        keylset returnList log "Could not find a traffic item with '$ti_name' name."
        return $returnList
    }
    
    # We must add a key called flow_name which is composed by the first columns that
    # represent the tracking used
    set ret_code [::ixia::540trafficGetMaxTiTrack $tmp_ti_obj]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    set max_trk_count [keylget ret_code ret_val]
    
    # We must add rx port
    incr max_trk_count 1
    
    catch {unset tmp_ti_obj}
    catch {unset tmp_ti_filter}
    
    set currentRow      1
    if {$totalPages == 0} {
        set totalPages 1
    }
    set captionsList ""
    for {set pageNumber 1} {$pageNumber <= $totalPages} {incr pageNumber} {
        
        if {[catch {ixNet setAttribute $statViewObjRef -currentPage $pageNumber} err] || $err != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not change page number to $pageNumber for $statViewObjRef. $err"
            return $returnList
        }
        
        catch {array unset estatViewArray}
        foreach estatViewObjRef $estatViewObjRefList {
            # egressPageSize is the maximum number of flows (egress values) displayed on a page
            # erow_count will be the actual number of flows (egress values) displayed on a page
            # I want the while loop to end when the number of egress flows returned is smaller than
            #   the maximum number of flows. That means that there are no more flows and the flowCondition
            #   doesn't have to change anymore
            set estatViewArray($estatViewObjRef,erow_count) $egressPageSize
            
            set estatViewArray($estatViewObjRef,max_egress_val)     0
            # If the maximum egress value will not change the while loop will be stopped
            set estatViewArray($estatViewObjRef,max_egress_val_bak) 0
        }
        
        if {![info exists ::ixia::egress_timeout]} {
            set ::ixia::egress_timeout 3600; # 1 hour
        }
        set done_egress 0
        set start_time [clock seconds]
        while {!$done_egress} {
            
            set retry_count 5
            for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
                if {[set rowList [ixNet getA $statViewObjRef -rowValues]] != ""} {
                    break
                }
                after 1000
            }
            
            set done_egress 1
            #set egress_row_countdown ""
            foreach estatViewObjRef $estatViewObjRefList {
                set estatViewArray($estatViewObjRef,erow_count)\
                        [ixNet getAttr $estatViewObjRef -rowCount]
                
                if {$egressPageSize == $estatViewArray($estatViewObjRef,erow_count)} {
                    # Found a full page
                    set done_egress 0
                }
                
            }
            
            
            foreach row_items $rowList egress_current_row_obj $estatViewObjRefList {
                set row_inner_idx 0
                foreach row $row_items {
                    set cellList [lrange $row 0 end]
                    set currentColumn 0
                        
                    if {$row_inner_idx == 0} {
                        
                        set rx_port [lindex $row $rx_port_column_idx]
                        set rx_port_status [GetVportByNameFromArray $rx_port]
                        if {[keylget rx_port_status status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Failed to get rx port of egress stats.\
                                    [keylget rx_port_status log]"
                            return $returnList
                        }
                        set rx_port [keylget rx_port_status port_handle]
                        
                        set row_name "[lindex $row 0] $ti_name "
                        
                        foreach tmpCell [lrange $row 1 [expr $max_trk_count - 1]] {
                            if {[llength $tmpCell] > 0} {
                                append row_name "$tmpCell "
                            } else {
                                append row_name "N/A "
                            }
                        }
                        
                        set row_name [string trim $row_name]
                        catch {unset tmpCell}
                        
                    } else {

                        foreach cell $cellList {
                              
                            set stat_name [lindex $columnCaptions $currentColumn]
                            if {[lsearch $captionsList $stat_name] == -1} {
                                lappend captionsList $stat_name
                            }

                            set stat_value $cell

                            set rowsArray($pageNumber,$currentRow,$stat_name) $stat_value
                            incr currentColumn
                        }
                        
                        set rowsArray($pageNumber,$currentRow,Rx\ Port) $rx_port
                        set rowsArray($pageNumber,$currentRow) $row_name
                        
                        if {[info exists rowsArray($pageNumber,$currentRow,Egress\ Tracking)]} {
                            if {$estatViewArray($egress_current_row_obj,max_egress_val) < $rowsArray($pageNumber,$currentRow,Egress\ Tracking)} {
                                set estatViewArray($egress_current_row_obj,max_egress_val) $rowsArray($pageNumber,$currentRow,Egress\ Tracking)
                            }
                        }
                        
                        
                        incr currentRow
                    }
                    
                    incr row_inner_idx
                }
            }
            
            
            if {[mpexpr [clock seconds] - $start_time] > $::ixia::egress_timeout} {
                keylset returnList status $::FAILURE
                keylset returnList log "Timeout 3600 occured while gathering egress\
                        statistics for '[ixNet getA $view -caption]' statistic view. To\
                        increase the timeout value set the ::ixia::egress_timeout variable\
                        to the desired value in seconds"
                return $returnList
            }
            
            set done_egress 1
            foreach estatViewObjRef $estatViewObjRefList {
                if {$estatViewArray($estatViewObjRef,max_egress_val) != $estatViewArray($estatViewObjRef,max_egress_val_bak)} {
                    set done_egress 0
                    break
                }
            }
            
            if {$done_egress} {
                # The maximum value did not change => stop changing the flowCondition
                #   because there are no more flows
                continue
            }
            
            
            foreach estatViewObjRef $estatViewObjRefList {
                
                set estatViewArray($estatViewObjRef,max_egress_val) [expr $estatViewArray($estatViewObjRef,max_egress_val) + 1]
                set estatViewArray($estatViewObjRef,max_egress_val_bak) $estatViewArray($estatViewObjRef,max_egress_val)
                
                # change the flowCondition so we get the next set of flows
                
                if {[catch {ixNet getList $estatViewObjRef flowCondition} efcstatViewObjRef] ||\
                        [llength $efcstatViewObjRef] == 0} {
                            
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to get flowCondition object for\
                                '[ixNet getA $view -caption]' statistic view. flowCondition object is\
                                missing: $efcstatViewObjRef"
                    return $returnList
                }
                if {[catch {ixNet setAttr $efcstatViewObjRef -values [list $estatViewArray($estatViewObjRef,max_egress_val)]} err] || $err != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not ixNetworkSet $efcstatViewObjRef -values [list $estatViewArray($estatViewObjRef,max_egress_val)]. $err"
                    return $returnList
                }
            }
            
            if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not commit egress flowCondition changes. Failed on commit. $err"
                return $returnList
            }
            
            # Wait for stat view to be ready
            set retry_count 10
            for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
                if {[ixNet getAttribute $statViewObjRef -isReady] == "true"} {
                    break
                }
                after 1000
            }
            
            if {[ixNet getAttribute $statViewObjRef -isReady] != "true"} {
                keylset returnList status $::FAILURE
                keylset returnList log "'[ixNet getA $view -caption]' statistic view is not ready."
                return $returnList
            }
        } ; # end of while
    }
    
    keylset returnList rows     [array get rowsArray]
    keylset returnList captions $captionsList
    keylset returnList page     $pageNumber
    keylset returnList row      $currentRow

    return $returnList
}


proc ::ixia::540GetEgressStatViewMultipleTi {statViewName {mode "all"}  {egress_stats_list "all"}} {
    
    variable ixnetwork_port_handles_array
    keylset returnList status $::SUCCESS
    
    set statViewRoot [ixNet getRoot]statistics
    
    set statViewList [ixNet getList $statViewRoot view]

    set view ""
    foreach statView $statViewList {
        if {[ixNet getAttribute $statView -caption] == $statViewName} {
            set view $statView
            break
        }
    }
   
    if {$view == ""} {
        if {$mode != "all"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not find $statViewName view. Possible causes:\
                    traffic was not started or statistics collected too soon after traffic was started."
            return $returnList
        } else {
            keylset returnList rows ""
            keylset returnList page 0
            keylset returnList row  0
            return $returnList
        }
    }

    set commit_needed 0
    if {$egress_stats_list == "all"} {
        foreach {statistic} [ixNet getList $view statistic] {
            if {[ixNet getAttribute $statistic -enabled] != "true"} {
                if {[catch {ixNet setAttribute $statistic -enabled true} err] || $err != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Commit failed while extracting statistics for\
                            '[ixNet getA $view -caption]' on 'ixNet setAttribute $statistic -enabled true'. $err"
                    return $returnList
                }
                set commit_needed 1
            }
        }
    }
    
    if {[ixNet getAttribute $view -enabled] != "true"} {
        if {[catch {ixNet setAttribute $view -enabled true} err] || $err != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Commit failed while extracting statistics for\
                    '[ixNet getA $view -caption]' on 'ixNet setAttribute $view -enabled true'. $err"
            return $returnList
        }
        set commit_needed 1
    }
    
    if {$commit_needed} {
        if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Commit failed while extracting statistics for\
                    '[ixNet getA $view -caption]'. $err"
            return $returnList
        }
    }
    
    set statViewObjRef  "$view/page"

    if {[catch {ixNet getAttribute $statViewObjRef -totalPages} totalPages]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to get total number of pages for\
                    '[ixNet getA $view -caption]' statistic view. $totalPages"
        return $returnList
    }
    
    set egressPageSize [ixNet getAttr $statViewObjRef -egressPageSize]
    
    if {[catch {ixNet getList $statViewObjRef egress} estatViewObjRefList] ||\
            [llength $estatViewObjRefList] == 0} {
                
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to get total number of pages for\
                    '[ixNet getA $view -caption]' statistic view. Egress object is\
                    missing: $estatViewObjRefList"
        return $returnList
    }
    
    set retry_count 10
    set retry_status false
    for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
        if {[set retry_status [ixNet getAttribute $statViewObjRef -isReady]] == "true"} {
            break
        }
        after 1000
    }
    
    if {($retry_status != "true") && ([ixNet getAttribute $statViewObjRef -isReady] != "true")} {
        keylset returnList status $::FAILURE
        keylset returnList log "'[ixNet getA $view -caption]' statistic view is not ready."
        return $returnList
    }
    
    ###############################################
    # Determine the optimum pageSize/egressPageSize
    ###############################################
    if {[catch {ixNet getAttribute $statViewObjRef -totalPages} totalPages]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to get total number of pages for\
                    '[ixNet getA $view -caption]' statistic view. $totalPages"
        return $returnList
    }
    
    set maxEgressTotalPages 0
    set maxEgressRowCount   0
    foreach egress_obj $estatViewObjRefList {
        set tmp_egress_total_pages [ixNet getAttr $egress_obj -totalPages]
        if {$tmp_egress_total_pages > $maxEgressTotalPages} {
            set maxEgressTotalPages $tmp_egress_total_pages
        }
        
        set tmp_egress_row_count [ixNet getAttr $egress_obj -rowCount]
        if {$tmp_egress_row_count > $maxEgressRowCount} {
            set maxEgressRowCount $tmp_egress_row_count
        }
    }
    
    set rowCount [ixNet getA $statViewObjRef -rowCount]
    
    if {$totalPages > 1 || $maxEgressTotalPages > 1} {
        # If it's only 1 page we don't need to change anything
        # In this case there are multiple pages so we need to adjust the pageSize
        
        # The maximum number of rows that can be displayed is 500
        # The actual number of rows is: rowCount * maxEgressRowCount + rowCount
        
        if {[expr $rowCount * $maxEgressRowCount] < 500} {
            # Not using the maximum number of rows
            if {$totalPages == 1} {
                # rowCount is the total number of ingress flows
                set new_ingress_page_size $rowCount
                set new_egress_page_size [expr 500 / $new_ingress_page_size - 1]
            } elseif {$maxEgressTotalPages == 1} {
                set new_egress_page_size $maxEgressRowCount
                set new_ingress_page_size [expr 500 / ($new_egress_page_size + 1)]
            } else {
                # Both ingress and ingress page count are > 1
                set ingress_total_rows [mpexpr $rowCount * $totalPages]
                set egress_total_rows  [mpexpr $maxEgressRowCount * $maxEgressTotalPages]
                
                if {$egress_total_rows >= 499} {
                    set new_ingress_page_size 1
                    set new_egress_page_size  499
                } elseif {$ingress_total_rows >= 250} {
                    set new_ingress_page_size 250
                    set new_egress_page_size  1
                } else {
                    set new_ingress_page_size  $ingress_total_rows
                    set new_egress_page_size   [expr 500 / $new_ingress_page_size - 1]
                }
            }
        }
        
        if {$new_ingress_page_size != [ixNet getAttribute $statViewObjRef -pageSize] ||\
                $new_egress_page_size != [ixNet getAttribute $statViewObjRef -egressPageSize]} {
            
            ixNet setA $statViewObjRef -pageSize            $new_ingress_page_size
            ixNet setA $statViewObjRef -egressPageSize      $new_egress_page_size
            
            if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not commit pageSize changes. Failed on commit. $err"
                return $returnList
            }
            
            set retry_count 10
            for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
                if {[ixNet getAttribute $statViewObjRef -isReady] == "true"} {
                    break
                }
                after 1000
            }
            
            if {[ixNet getAttribute $statViewObjRef -isReady] != "true"} {
                keylset returnList status $::FAILURE
                keylset returnList log "'[ixNet getA $view -caption]' statistic view is not ready."
                return $returnList
            }
        }
    }
    
    #################### Done changing pageSize ######################################
    
    if {[catch {ixNet getAttribute $statViewObjRef -totalPages} totalPages]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to get total number of pages for\
                    '[ixNet getA $view -caption]' statistic view. $totalPages"
        return $returnList
    }
    
    if {[catch {ixNet getList $statViewObjRef egress} estatViewObjRefList] ||\
            [llength $estatViewObjRefList] == 0} {
                
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to get total number of pages for\
                    '[ixNet getA $view -caption]' statistic view. Egress object is\
                    missing: $estatViewObjRefList"
        return $returnList
    }
        
    set columnCaptions [ixNet getAttribute $statViewObjRef -columnCaptions]
    set rx_port_column_idx [lsearch $columnCaptions "Rx Port"]
    if {$rx_port_column_idx == -1} {
        debug "Rx Port column not found while gathering egress stats. ixNet getAttribute $statViewObjRef -columnCaptions\
                returned $columnCaptions"
        set rx_port_column_idx 0
    }
    
    set egress_tracking_column_idx [lsearch -glob $columnCaptions "Egress Tracking*"]
    if {$rx_port_column_idx == -1} {
        # Can't live without it
        keylset returnList status $::FAILURE
        keylset returnList log "Egress Tracking column not found while gathering egress stats. ixNet getAttribute $statViewObjRef -columnCaptions\
                returned $columnCaptions"
        return $returnList
    }
    
    keylset returnList egress_tracking_col [lindex $columnCaptions $egress_tracking_column_idx]
    
    # max_trk_count is the number of fields that are tracked

    # the traffic item name is not available as stat.
    # Get it from view details
    set ret_code [ixNetworkEvalCmd [list ixNet getA $view/layer23TrafficFlowFilter -trafficItemFilterIds]]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    set tmp_ti_filters [keylget ret_code ret_val]
    
    # Get the available traffic items
    set ti_handles_list [ixNet getList [ixNet getRoot]traffic trafficItem]
    # Get the traffic items names
    foreach ti_handle $ti_handles_list {
        set ti_name [ixNet getA $ti_handle -name]
        array set ti_names_array [list $ti_handle $ti_name]
    }
    set tmp_ti_obj_list ""
    foreach tmp_ti_filter $tmp_ti_filters {
        set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_ti_filter -name]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        set ti_name [keylget ret_code ret_val]
        
        set found 0
        foreach {traffic_item_handle traffic_item_name} [array get ti_names_array] { 
            if {$traffic_item_name == $ti_name} {
                set found 1
                break
            }
        }
        
        if {$found} {
            set tmp_ti_obj $traffic_item_handle
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not find a traffic item with '$ti_name' name."
            return $returnList
        }
        
        lappend tmp_ti_obj_list $tmp_ti_obj
    }
    
    # We must add a key called flow_name which is composed by the first columns that
    # represent the tracking used
    
    set ret_code [::ixia::540trafficGetMaxTiTrack $tmp_ti_obj_list]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    set max_trk_count [keylget ret_code ret_val]
    
    # We must add rx port
    incr max_trk_count 1
    
    catch {unset tmp_ti_obj}
    catch {unset tmp_ti_filter}
    
    set currentRow      1
    if {$totalPages == 0} {
        set totalPages 1
    }
    
    # Set ids for the aggregate rows
    set index 1
    foreach estatViewObjRef $estatViewObjRefList {
        set aggregateIds($estatViewObjRef) $index
        incr index
    }
    
    set captionsList ""
    for {set pageNumber 1} {$pageNumber <= $totalPages} {incr pageNumber} {
        
        if {[catch {ixNet setAttribute $statViewObjRef -currentPage $pageNumber} err] || $err != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not change page number to $pageNumber for $statViewObjRef. $err"
            return $returnList
        }
        
        if {([catch {ixNet commit} err] || $err != "::ixNet::OK")} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not commit change page number to $pageNumber for $statViewObjRef. Failed on commit. $err"
            return $returnList
        }
        
        catch {array unset estatViewArray}
        set max_egress_page_count 0
        foreach estatViewObjRef $estatViewObjRefList {
            
            set estatViewArray($estatViewObjRef,starting_page) [ixNet getAttr $estatViewObjRef -currentPage]
            
            set page_count [ixNet getAttr $estatViewObjRef -totalPages]
            set estatViewArray($estatViewObjRef,total_pages)  $page_count
            
            if {$page_count > $max_egress_page_count} {
                set max_egress_page_count $page_count
            }
        }
        
        for {set current_egress_page 0} {$current_egress_page <= $max_egress_page_count} {incr current_egress_page} {
            if {$current_egress_page == 0} {
                # using page 0 as dummy page to get the current page number.
                # If if didn't do this and set the page to 1 from the start i would lose a page flip time
            } else {
                
                # change the page
                set commit_needed 0
                foreach estatViewObjRef $estatViewObjRefList {
                    if {$estatViewArray($estatViewObjRef,total_pages) < $current_egress_page || \
                            $estatViewArray($estatViewObjRef,starting_page) == $current_egress_page} {
                                
                        # pages for this egress view have ended || page was queried with current_egress_page was 0 (starting page)
                        continue
                    } else {
                        # Flip the egress page
                        if {[catch {ixNet setAttribute $estatViewObjRef -currentPage $current_egress_page} err] || $err != "::ixNet::OK"} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Could not change page number to $current_egress_page for $estatViewObjRef. $err"
                            return $returnList
                        }
                        set commit_needed 1
                    }
                }
                
                if {$commit_needed && ([catch {ixNet commit} err] || $err != "::ixNet::OK")} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not commit egress page changes. Failed on commit. $err"
                    return $returnList
                }
                
                # Wait for stat view to be ready
                set retry_count 10
                set retry_status "false"
                for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
                    if {[set retry_status [ixNet getAttribute $statViewObjRef -isReady]] == "true"} {
                        break
                    }
                    after 1000
                }
                
                if {($retry_status != "true") && ([ixNet getAttribute $statViewObjRef -isReady] != "true")} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "'[ixNet getA $view -caption]' statistic view is not ready."
                    return $returnList
                }
            }
            
            set retry_count 5
            for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
                if {[set rowList [ixNet getA $statViewObjRef -rowValues]] != ""} {
                    break
                }
                after 1000
            }
            
            foreach row_items $rowList estatViewObjRef $estatViewObjRefList {
                if {$estatViewArray($estatViewObjRef,total_pages) < $current_egress_page || \
                            $estatViewArray($estatViewObjRef,starting_page) == $current_egress_page} {
                    continue
                }
                
                set row_inner_idx 0
                foreach row $row_items {
                    set cellList [lrange $row 0 end]
                    set currentColumn 0
                        
                    if {$row_inner_idx == 0} {
                        
                        set rx_port [lindex $row $rx_port_column_idx]
                        set vport_found 0
                        foreach vport_name [array names ixnetwork_port_handles_array] {
                            if {$vport_name == $rx_port} {
                                set vport_found $vport_name
                                break
                            }
                        }
                        if {$vport_found!=0} {
                            set rx_port $vport_found
                        }
                        
                        set row_name "[lindex $row 0] $ti_name "
                        
                        foreach tmpCell [lrange $row 1 [expr $max_trk_count - 1]] {
                            if {[llength $tmpCell] > 0} {
                                append row_name "$tmpCell "
                            } else {
                                append row_name "N/A "
                            }
                        }
                        
                        set row_name [string trim $row_name]
                        catch {unset tmpCell}
                        
                        foreach cell $cellList {
                            set stat_name [lindex $columnCaptions $currentColumn]
                            if {[lsearch $captionsList $stat_name] == -1} {
                                lappend captionsList $stat_name
                            }
                            set stat_value $cell
                            
                            set aggregateRowsArray($aggregateIds($estatViewObjRef),$stat_name) $stat_value
                            
                            incr currentColumn
                        }
                        set aggregateRowsArray($aggregateIds($estatViewObjRef),rx_port) $rx_port
                        if {![info exists aggregateRowsArray(ids)]} {
                            set aggregateRowsArray(ids) [list]
                        }
                        
                        # If the current id is not in the list append it
                        if {[lsearch $aggregateRowsArray(ids) $aggregateIds($estatViewObjRef)] == -1} {
                            lappend aggregateRowsArray(ids) $aggregateIds($estatViewObjRef)
                        }
                        
                    } else {

                        foreach cell $cellList {
                              
                            set stat_name [lindex $columnCaptions $currentColumn]
                            if {[lsearch $captionsList $stat_name] == -1} {
                                lappend captionsList $stat_name
                            }

                            set stat_value $cell

                            set rowsArray($pageNumber,$currentRow,$stat_name) $stat_value
                            incr currentColumn
                        }
                        
                        set rowsArray($pageNumber,$currentRow,Rx\ Port) $rx_port
                        set rowsArray($pageNumber,$currentRow) $row_name
                        set rowsArray($pageNumber,$currentRow,aggregateId) $aggregateIds($estatViewObjRef)
                        
                        incr currentRow
                    }
                    
                    incr row_inner_idx
                }
            }
            
        }
    }
    keylset returnList rows     [array get rowsArray]
    keylset returnList aggregate [array get aggregateRowsArray]
    keylset returnList captions $captionsList
    keylset returnList page     $pageNumber
    keylset returnList row      $currentRow

    return $returnList
}



proc ::ixia::540CreateCustomStatView { the_handle the_view_name proto_particle} {
    variable ixn_traffic_version

    if {[info exists ixn_traffic_version]} {
        if {$ixn_traffic_version == "5.30" || $ixn_traffic_version == "ixos"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Warning: IxNetwork version is lower than 5.40. Skipping custom stat view creation."
            return $returnList
        }
    }
    
    if { [regexp {^(\d+)/(\d+)/(\d+)$} $the_handle {} chassis_id card_id port_id] } {
        set extract_result [::ixia::ixNetworkGetPortObjref $the_handle]
        if {[keylget extract_result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not get vport handle from port handle."
            return $returnList
        }
        set target_vport [keylget extract_result vport_objref]
    } else {
        set target_vport [ixNetworkGetParentObjref $the_handle "vport"]
        if {$target_vport == [ixNet getNull]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal error. Failed to get vport object from '$handle'."
            return $returnList
        }
    }
    
    set specificOptionsList [ixNet getL "${target_vport}/protocolStack" "${proto_particle}Options"]
    if {[llength $specificOptionsList] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Could not get ${proto_particle}Options on $target_vport."
        return $returnList
    }
    set specificOptions [lindex $specificOptionsList 0]
    
    catch {ixNet setA $specificOptions -enablePerSessionStatGeneration true}
    
    # Check if view is already created...
    set view_already_there 0
    foreach old_view [ixNet getL ::ixNet::OBJ-/statistics view] {
        if {[ixNet getA $old_view -caption] == $the_view_name} {
            if { [llength [ixNet getL $old_view statistic]]>0} {
                set good_view $old_view
                set view_already_there 1
            } else {
                ixNet remove $old_view
                ixNet commit
            }
            break
        }
    }
    
    if {$view_already_there} {
        keylset returnList view_age old
    } else {
        set local_view [ixNet add ::ixNet::OBJ-/statistics view]
        ixNet setA $local_view -type layer23ProtocolStack
        ixNet setA $local_view -caption $the_view_name 
        keylset returnList view_age new
    }

    catch {ixNet commit} have_problems
    if { [info exists have_problems] && $have_problems != "::ixNet::OK" } {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to commit after creating statistics view."
        return $returnList
    }
          
    if {!$view_already_there} {
        set good_view [ixNet remapIds $local_view]
    }
      
    keylset returnList status $::SUCCESS
    keylset returnList view $good_view
    return $returnList
}
# Procedure that returns a list of available regex for availableProtocolStackFilter objects
# for a given port_handle
# Return: list of object //l2tp/<chassis><card><port>/l2tp-r<id>
proc ::ixia::getValidL2tpRegexRangeNames {port_handle} {
    set root [ixNet getRoot]
    set vport_list [ixNet getList $root vport]
    set valid_port false
    set valid_port $::ixia::ixnetwork_port_handles_array($port_handle)
    set protocolStack_list [ixNet getList $valid_port protocolStack]
    set l2tpRange_names [list]
    
    # Creates a list of -name attributes for objects of the following type:
    # /vport/protocolStack/ethernet/ip/l2tpEndpoint/range/l2tpRange
    foreach protocolStack $protocolStack_list {
        set ethernet_list [ixNet getList $protocolStack ethernet]
        foreach ethernet $ethernet_list {
            set ip_list [ixNet getList $ethernet ip]
            foreach ip $ip_list {
                set l2tpEndpoint_list [ixNet getList $ip l2tpEndpoint]
                foreach l2tpEndpoint $l2tpEndpoint_list {
                    set range_list [ixNet getList $l2tpEndpoint range]
                    foreach range $range_list {
                        set l2tpRange_list [ixNet getList $range l2tpRange]
                        # The following foreach can iterate through multiple items
                        # the previous ones have only one element
                        foreach l2tpRange $l2tpRange_list {
                            lappend l2tpRange_names [ixNet getAttribute $l2tpRange -name]
                        }
                    }
                }
            }
        }
    }

    if {[llength $l2tpRange_names] == 0} {
        set pattern ".*"
    } else {
        set pattern [list]
        set delimiter ""
        foreach l2tpRange $l2tpRange_names {
            append pattern $delimiter "[string tolower (//L2TP/[regsub -all "/" $port_handle ""]/$l2tpRange)]"
            set delimiter "|"
        }
    }
    
    return $pattern
}

proc ::ixia::540DrillDownStatView { view2drill proto_regex granularity {the_handle empty}} {
    set protocol_stack_counter 10
    # Implemented while in order to fix BUG663550. Protocol stack filter
    # becomes available few seconds after pppox protocol is started.
    while {$protocol_stack_counter>0} {
        set filters_list [ixNet getL $view2drill availableProtocolStackFilter]
        if {[llength $filters_list] == 0} {
            incr protocol_stack_counter -1
            after 1000
        } else {
            keylset returnList drilldown_ready 1
            break
        }
    }
    if {$protocol_stack_counter == 0} {
        keylset returnList protocol_stack_counter 0
        keylset returnList status $::SUCCESS
        keylset returnList drilldown_ready 0
        return $returnList
    }
    set filter_selection "none"
    
    if {$the_handle == "empty"} {
        puts "Warning: port_handle used instead of handle. Using the first available protocol stat filter."
        set view_particle [string trim [string range $view2drill [string first "SessionView-" $view2drill] end] "\"\\"]
		
		set chassisPortId [regsub -all {[^0-9]} $view_particle ""]
		if {$chassisPortId != "" && [regexp $chassisPortId $filters_list]} {
			foreach single_filter $filters_list {
				if {[string first $view_particle $single_filter] >= 0 && \
					[regexp [string tolower $proto_regex] [string tolower $single_filter]] && \
					[regexp $chassisPortId $single_filter]} {
					set filter_selection $single_filter
					break
				}
			}
		} else {
			foreach single_filter $filters_list {
				if {[string first $view_particle $single_filter] >= 0 && [regexp [string tolower $proto_regex] [string tolower $single_filter]]} {
					set filter_selection $single_filter
					break
				}
			}
		}
    } else {
        if {[regexp {^::ixNet::OBJ-/vport:\d+/protocolStack/.+/range:[^/]+$} $the_handle] &&\
                $granularity == "perRange" && $proto_regex == "pppox"} {
            # If the handle is a range and perRange stats are polled, use the filters that have the same name
            # as the range
            set pppoxRange [ixNet getL $the_handle pppoxRange]
            if {[llength $pppoxRange] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "No pppoxRange was found on $the_handle while doing perRange drilldown."
                return $returnList
            }
            set range_name [ixNet getA $pppoxRange -name]
            foreach single_filter $filters_list {
                set filter_name [ixNet getA $single_filter -name]
                if {[regexp "$range_name\$" $filter_name]} {
                    set filter_selection $single_filter
                    break
                }
            }
        } else {
            set filter_selection [lindex $filters_list 0]
            set range_particle [string trim [string range $the_handle [expr [string first "/range:" $the_handle] + 7] end] "\"\\"]
            foreach single_filter $filters_list {
                if { [regexp {^(.+)SessionView-([0-9a-z-]+)\"(.+)$} $single_filter {} target1 filter_particle] && [regexp $proto_regex [string tolower $single_filter]] }  {
                    if {$filter_particle == $range_particle} {
                        set filter_selection $single_filter
                        break
                    }
                }
                if {[regexp $proto_regex $single_filter]} {
                    # per session custom view
                    set filter_selection $single_filter
                    break
                }
            }
        }
    }
 
    if {$filter_selection == "none"} {
        keylset returnList status $::FAILURE
        keylset returnList log "None of the protocol stat filters matched the specified criteria $the_handle. This\
                can occur when the protocol was not started for the specified handle or when statistics are polled\
                immediately after the protocol was started"
        return $returnList
    }
    
    ixNet setA "${view2drill}/layer23ProtocolStackFilter" -protocolStackFilterId "\{$filter_selection\}"
    ixNet setA "${view2drill}/layer23ProtocolStackFilter" -drilldownType $granularity
    catch {ixNet commit} have_problems
    if { [info exists have_problems] && $have_problems != "::ixNet::OK" } {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to commit after setting per session drilldown."
        return $returnList
    }
    after 500
    
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::CreateAndDrilldownViews { x_handle handle_mode v_name proto_particle {proto_regex ".*"} } {
    set name_index 0
    set view_age_flag 0
    foreach particular_handle $x_handle {
        set view_result [::ixia::540CreateCustomStatView $particular_handle [lindex $v_name $name_index] $proto_particle]
        if {[keylget view_result status] == $::FAILURE} {
            return $view_result
        }
        set current_view [keylget view_result view]
        if {[keylget view_result view_age] == "new"} {
            set view_age_flag 1
            if {$proto_regex == ".*"} {
                if {$proto_particle != "dhcpv6PdClient"} {
                    set proto_regex $proto_particle
                } else {
                    set proto_regex "dhcpv6client"
                }
            }
            if {$handle_mode == "handle"} {
                set drilldown_result [::ixia::540DrillDownStatView $current_view $proto_regex "perSession" $particular_handle]
            } elseif {$handle_mode == "handle_pr"} {
                set drilldown_result [::ixia::540DrillDownStatView $current_view $proto_regex "perRange"   $particular_handle]
            } else {
                set drilldown_result [::ixia::540DrillDownStatView $current_view $proto_regex "perSession"]
            }
            if {[keylget drilldown_result status] == $::FAILURE} {
                return $drilldown_result
            }
        }
        incr name_index
    }
    if {$view_age_flag == 0} {
        keylset returnList drilldown_status 1
    } else {
        keylset returnList drilldown_status [keylget drilldown_result drilldown_ready]
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::540IsLatestVersion {} {
    variable ixn_traffic_version
    if {[info exists ixn_traffic_version]} {
        if {$ixn_traffic_version == "ixos" || $ixn_traffic_version == "5.30"} {
            return 0
        } else {
            return 1
        }
    }
    # Assume it is the latest.
    return 1
}


proc ::ixia::ixNetworkGetLatencyNamePrefix {} {
    
    if {[catch {ixNet getA [ixNet getRoot]traffic/statistics/latency -mode} lat_value]} {
        return "Cut-Through"
    }
    
    switch -- $lat_value {
        cutThrough {
            return "Cut-Through"
        }
        forwardingDelay {
            return "FD"
        }
        mef {
            return "MEF"
        }
        storeForward {
            return "Store-Forward"
        }
        default {
            return "Cut-Through"
        }
    }
}


proc ::ixia::540GetStatViewSnapshot {statViewName {mode "all"} {is_latency_view "0"} {type ""} {only_csv 0} {get_enabled_and_is_ready 1}} {
    # mode - create - creates the stat view if the stat view was not found
    # mode - all - returns SUCCESS and empty list of stats when the stat view was not found
    # mode - other - returns FAILURE when the stat view was not found
    variable csv_path
    keylset returnList status $::SUCCESS
    
    set statViewRoot [ixNet getRoot]statistics
    
    set statViewList [ixNet getList $statViewRoot view]

    set view ""
    foreach statView $statViewList {
        if {[ixNet getAttribute $statView -caption] == $statViewName} {
            set view $statView
            break
        }
    }
   
    if {$view == ""} {
        if {$mode == "create" && $type != ""} {
            set retCode [540CreateUserDefinedView $statViewName $type]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
            set view    [keylget retCode view]
        } elseif {$mode != "all"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not find $statViewName view. Possible causes:\
                    traffic was not started or statistics collected too soon after traffic was started."
            return $returnList
        } else {
            keylset returnList rows ""
            keylset returnList page 0
            keylset returnList row  0
            return $returnList
        }
    }
    
    set commit_needed 0
    
    if {$get_enabled_and_is_ready == 1} {
        foreach {statistic} [ixNet getList $view statistic] {
            if {[ixNet getAttribute $statistic -enabled] != "true"} {
                if {[catch {ixNet setAttribute $statistic -enabled true} err] || $err != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Commit failed while extracting statistics for\
                            '[ixNet getA $view -caption]' on 'ixNet setAttribute $statistic -enabled true'. $err"
                    return $returnList
                }
                set commit_needed 1
            }
        }
        
        if {[ixNet getAttribute $view -enabled] != "true"} {
            if {[catch {ixNet setAttribute $view -enabled true} err] || $err != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Commit failed while extracting statistics for\
                        '[ixNet getA $view -caption]' on 'ixNet setAttribute $view -enabled true'. $err"
                return $returnList
            }
            set commit_needed 1
        }
        
        if {$commit_needed} {
            if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Commit failed while extracting statistics for\
                        '[ixNet getA $view -caption]'. $err"
                return $returnList
            }
        }
    }
    
    set statViewObjRef "$view/page"
    
    if {$get_enabled_and_is_ready == 1} {
        set retry_count 4
        for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
            if {[ixNet getAttribute $statViewObjRef -isReady] == "true"} {
                break
            }
            after 1000
        }
    }
    
    if {[ixNet getAttribute $statViewObjRef -isReady] != "true"} {
        keylset returnList status $::FAILURE
        keylset returnList log "'[ixNet getA $view -caption]' statistic view is not ready."
        return $returnList
    }
    
    if {$statViewName == "Flow Statistics" || $is_latency_view} {
        
        # max_trk_count is the number of fields that are tracked

        if {$statViewName == "Flow Statistics"} {
            
            # We must add a key called flow_name which is composed by the first columns that
            # represent the tracking used
            set ret_code [::ixia::540trafficGetMaxTiTrack]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set max_trk_count [keylget ret_code ret_val]
            
            # We must add tx port, rx port and traffic item name to the count
            incr max_trk_count 3
            
        } elseif {$is_latency_view} {

            # the traffic item name is not available as stat.
            # Get it from view details
            set ret_code [ixNetworkEvalCmd [list ixNet getA $view/layer23TrafficFlowFilter -trafficItemFilterId]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            set tmp_ti_filter [keylget ret_code ret_val]
            
            set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_ti_filter -name]]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            set ti_name [keylget ret_code ret_val]
            
            set tmp_ti_obj [540getTrafficItemByName $ti_name]
            if {$tmp_ti_obj == "_none"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not find a traffic item with '$ti_name' name."
                return $returnList
            }
            
            # We must add a key called flow_name which is composed by the first columns that
            # represent the tracking used
            set ret_code [::ixia::540trafficGetMaxTiTrack $tmp_ti_obj]
            if {[keylget ret_code status] != $::SUCCESS} {
                return $ret_code
            }
            
            set max_trk_count [keylget ret_code ret_val]
            
            # We must add rx port
            incr max_trk_count 1
            
            catch {unset tmp_ti_obj}
            catch {unset tmp_ti_filter}
        }
    }
    
    set totalPages 1
    
    set opts [::ixia::stats_util::get_default_snapshot_settings]
    
    if {[regsub {DefaultSnapshotSettings} $opts $statViewName opts] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to customize the csv file name. regsub {DefaultSnapshotSettings} $opts $statViewName opts"
        return $returnList
    }
    
    if {![regexp {kOverwriteCSVFile} $opts]} {
        # Only try to replace kNewCSVFile with kOverwriteCSVFile if 
        # kOverwriteCSVFile is not present (the user might change IxN 
        # default to be kOverwriteCSVFile
        if {[regsub {kNewCSVFile} $opts {kOverwriteCSVFile} opts] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to customize the csv file name. regsub\
                    {kNewCSVFile} $opts {kOverwriteCSVFile} opts"
            return $returnList
        }
    }
    if {[catch {::ixTclNet::TakeViewCSVSnapshot \{$statViewName\} $opts} out] || $out != 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to '::ixTclNet::TakeViewCSVSnapshot \{$statViewName\} $opts':\
                $out"
        return $returnList
    }

    array set measure_mode_suffix {
        instantaneousMode   _Instantaneous
        cumulativeMode      _Cumulative
        mixedMode           ""
    }
    
    if {![ixNetworkGetAttr "::ixNet::OBJ-/traffic" -enableInstantaneousStatsSupport]} {
        set measure_mode mixedMode
    } else {
        set measure_mode [ixNetworkGetAttr "::ixNet::OBJ-/statistics/measurementMode" -measurementMode]
    }
    
    regsub -all {\\} $opts {\\\\} opts
    
    foreach opt $opts {
        foreach {opt_key opt_val} $opt {
            if {$opt_key == "Snapshot.View.Csv.Location:"} {
                if {![isUNIX]} {
                    set file_dir [regsub -all {\\\\} $opt_val {/}]
                } else {
                    set file_dir $opt_val
                }
            }
            if {$opt_key == "Snapshot.Settings.Name:"} {
                if {![regexp "^application_" $mode]} {
                    set view_type [ixNetworkGetAttr $view -viewCategory]
                    if { $view_type == "L23Traffic" } {
                        set file_name "${opt_val}$measure_mode_suffix($measure_mode)"
                    } else {
                        set file_name $opt_val
                    }
                }
                debug "$view_type ==> $file_name"
            }
        }
    }
    
    if {![info exists file_dir] || ![info exists file_name]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Could not find csv location in keyed string: $opts"
        return $returnList
    }
    
    set csv_file [file join $file_dir ${file_name}.csv]
    
    set csv_file [copy_csv_fileName $csv_file $file_name $csv_path $mode]
    
    if {$only_csv == 1} {
        keylset returnList status $::SUCCESS
        keylset returnList csv_file $csv_file
        return $returnList
    }
    
    set csv_ok 0
    set retry_count 10
    for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
        if {[catch {open $csv_file r} csv_fd]} {
            after 500
        } else {
            set csv_file_content [read $csv_fd]
            if {$csv_file_content == ""} {
                close $csv_fd
                after 500
            } else {
                set csv_ok 1
                break
            }
        }
    }
    
    if {!$csv_ok} {
        keylset returnList status $::FAILURE
        keylset returnList log "Could not open csv '$csv_file'"
        return $returnList
    }
    
    if {[catch {close $csv_fd} err]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Could not close csv file '$csv_file' with descriptor $csv_fd. $err"
        return $returnList
    }
    
    if {[isUNIX] && !$::ixia::debug} {
        catch {file delete $csv_file}
    }
    
    set csv_file_lines [split $csv_file_content \n]
    
    if {[llength $csv_file_lines] < 2} {
        keylset returnList status $::FAILURE
        keylset returnList log "Csv file '$csv_file' doesn't have any values.\
                Only columns were found. $err"
        return $returnList
    }
    
    #puts "$csv_file_lines"
    set columnCaptions [split [lindex $csv_file_lines 0] ,]
    #puts "columnCaptions == $columnCaptions"
    if {$statViewName == "Flow Statistics" || $is_latency_view} {
        set rowsArray(columnCaptions) $columnCaptions
        set rowsArray(max_trk_count) $max_trk_count
    }

    
    set currentRow      1
    set pageNumber      1; # normally it starts from one and gets incremented. The calling proc expects num of pages + 1
    
    set captionsList ""
    
    set rowList [lrange $csv_file_lines 1 end]
    
    foreach row $rowList {
        
        #puts "row == $row"
        
        if {$row == ""} {
            continue
        }
        
        set row [split $row ,]
        
        if {$statViewName == "Flow Statistics" || $is_latency_view} {
            
            set cellList [lrange $row 0 end]
            set currentColumn 0
            if {$statViewName == "Flow Statistics"} {
                set row_name ""
            } elseif {$is_latency_view} {
                set row_name "[regsub -all {\"} [lindex $row 0] {}] $ti_name "
            }
            
            foreach tmpCell [lrange $row 1 [expr $max_trk_count - 1]] {
                if {[llength $tmpCell] > 0} {
                    append row_name "[regsub -all {\"} $tmpCell {}] "
                } else {
                    append row_name "N/A "
                }
            }
            
            set row_name [string trim $row_name]
            
            catch {unset tmpCell}
        } else {
             #puts "row --> $row"
            set row_name [regsub -all {\"} [lindex $row 0] {}]
             #puts "row_name --> $row_name"
            set cellList [lrange $row 0 end]
             #puts "cellList --> $cellList"
            set currentColumn 0
        }
        
        
        foreach cell $cellList {
                 #puts "\tcell --> $cell"
            regsub -all {\"} $cell {} cell
            set stat_name [lindex $columnCaptions $currentColumn]
            regsub -all {\"} $stat_name {} stat_name
            if {[lsearch $captionsList $stat_name] == -1} {
                lappend captionsList $stat_name
            }
                 #puts "\tstat_name --> $stat_name"
                  if {$stat_name == "Tx Port" || $stat_name == "Rx Port"} {
                   set rx_port_status [GetVportByNameFromArray $cell]
                   if {[keylget rx_port_status status] != $::SUCCESS} {
                       keylset returnList status $::FAILURE
                       keylset returnList log "Failed to get statistics because the virtual port with the\
                               '$cell' name could not be found. [keylget rx_port_status log]"
                       return $returnList
                    }
                    set cell [keylget rx_port_status port_handle]
                 }
            set stat_value $cell
                 #puts "\tset rowsArray($pageNumber,$currentRow,$stat_name) $stat_value"
            if {[llength $stat_value] == 0} {
                set stat_value "N/A"
            }
            set rowsArray($pageNumber,$currentRow,$stat_name) $stat_value
            incr currentColumn
        }
        
             #puts "set rowsArray($pageNumber,$currentRow) $row_name"
        set rowsArray($pageNumber,$currentRow) $row_name
        incr currentRow
    }
    
    incr pageNumber      1; # The calling proc expects num of pages + 1
    
    keylset returnList rows     [array get rowsArray]
    keylset returnList captions $captionsList
    keylset returnList page     $pageNumber
    keylset returnList row      $currentRow

    return $returnList
}

# If Unix it copies the csv file_name from the Windows machine where IxNetwork runs
# in a unique filename in the current directory structure.
# If Windows and the ixnetwork_tcl_server is different from localhost copies the 
# file_name from the remote machine to the current one
#   Parameters:
# - csv_file: the full csv path on the remote windows machine
# - file_name: the filename(without the csv extension) on the remote machine
# - csv_path: the directory where the file_name will be copied(used only on Unix)
#        If the user doesn't have writing permissions on the csv_path directory
#        the filename will be created in the current directory and if that also fails
#        it will try to create it in the /tmp directory
# - mode: The type of traffic statistics to be collected.
#          If csv_path is not empty
#          csv files will be copied to the specified path in the csv_path.
#          For all other modes csv files will be copied to the specified path
#          If IxNetwork TCL Server is NOT running on the local machine or if its unix 
proc ::ixia::copy_csv_fileName {csv_file file_name {csv_path {}} {mode "all"}} {
    if {[isUNIX]} {
        # Create a list of possible writable directories
        set path_list [list $csv_path "." "/tmp"]
        
        set found_writable_path 0
        # keep the first path which is writable
        foreach path $path_list {
            if {[file writable $path]} {
                set found_writable_path 1
                break
            }
        }
        
        if { $found_writable_path != 1} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not find a writeable folder in $path_list"
            return $returnList
        }
        
        # Create a unique file in the path directory
        set counter 1
        while {$counter < 5} {
            set local_csv_file "${file_name}_[clock format [clock seconds] -format "%Y%m%d%H%M%S"].csv"
            set local_csv_file [regsub -all { } $local_csv_file {_}]
            set local_csv_file "$path/$local_csv_file"
            regsub -all { } $local_csv_file "\x20" local_csv_file
            set local_csv_file [file normalize $local_csv_file]
            # if the filename doesn't exists in the path directory, it's a valid name
            if {[file exists $local_csv_file] == 0} {
                set counter 0
                break
            }
            # if another snapshot was taken at same second wait 1 sec before retrying
            after 1000 
            incr counter
        }
        
        if { $counter != 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not create $local_csv_file. Check for permissions and whether the file is in use."
            return $returnList
        }
        
        catch {ixNet exec copyFile [ixNet readFrom "$csv_file" -ixNetRelative] \
                [ixNet writeTo "$local_csv_file" -overwrite]}
        
        if {![file exists $local_csv_file]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not create $local_csv_file on local machine from csv snapshot ($csv_file) on IxNetwork side. Check that $csv_file exists on the IxNetwork host."
            return $returnList
        }
        
        set csv_file $local_csv_file
    } else {
        # If IxNetwork TCL Server is NOT running on the local machine, copy the csv file
        # from the IxNetwork TCL Server machine to the local machine
        set me [socket -server xxx -myaddr [info hostname] 0]
        set win_local_ip [lindex [fconfigure $me -sockname] 0]
        close $me
        if {($::ixia::ixnetwork_tcl_server != "localhost") && ($::ixia::ixnetwork_tcl_server != $win_local_ip)} {
            # If IxNetwork TCL Server is not running on local machine
            # and csv_path is given and mode is application_****
            # csv files are copied to the csv_path location
            if {$csv_path != {}} {
                set win_local_csv_file [file join $csv_path "${file_name}_[clock format [clock seconds] -format "%Y%m%d%H%M%S"].csv"]
                set win_local_csv_file [regsub -all { } $win_local_csv_file {_}]
            } else {
                set win_local_csv_file "${file_name}_[clock format [clock seconds] -format "%Y%m%d%H%M%S"].csv"
                set win_local_csv_file [regsub -all { } $win_local_csv_file {_}]
            }    
            ixNet exec copyFile [ixNet readFrom "$csv_file" -ixNetRelative] \
                [ixNet writeTo "$win_local_csv_file" -overwrite]
            if {![file exists $win_local_csv_file]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not find local $win_local_csv_file"
                return $returnList
            }
            set csv_file $win_local_csv_file
        } elseif {[file exists $csv_file] && $csv_path != {}} {
            # If IxNetwork TCL Server is running on local machine
            # and csv_path is given and mode is application_****
            # csv files are copied to the csv_path location
            set win_local_csv_file [file join $csv_path "${file_name}_[clock format [clock seconds] -format "%Y%m%d%H%M%S"].csv"]
            set win_local_csv_file [regsub -all { } $win_local_csv_file {_}]

            ixNet exec copyFile [ixNet readFrom "$csv_file" -ixNetRelative] \
                [ixNet writeTo "$win_local_csv_file" -overwrite]
            if {![file exists $win_local_csv_file]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not find local $win_local_csv_file"
                return $returnList
            }
            set csv_file $win_local_csv_file
        } elseif {![file exists $csv_file]} {
            # If IxNetwork TCL Server is running on local machine
            keylset returnList status $::FAILURE
            keylset returnList log "Could not find local $csv_file."
            return $returnList
        } else {
            # If csv_path is not given copy the csv file in the current folder
            set win_local_csv_file "${file_name}_[clock format [clock seconds] -format "%Y%m%d%H%M%S"].csv"
            set win_local_csv_file [regsub -all { } $win_local_csv_file {_}]
            
            ixNet exec copyFile [ixNet readFrom "$csv_file" -ixNetRelative] \
                [ixNet writeTo "$win_local_csv_file" -overwrite]
            if {![file exists $win_local_csv_file]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not find local $win_local_csv_file"
                return $returnList
            }
            set csv_file $win_local_csv_file
        }
    }
    
    return $csv_file
}

proc ::ixia::540GetMultipleStatViewSnapshot {statViewNameList {mode "all"} {is_latency_view "0"} {type ""}} {
    # mode - create - creates the stat view if the stat view was not found
    # mode - all - returns SUCCESS and empty list of stats when the stat view was not found
    # mode - other - returns FAILURE when the stat view was not found

    variable csv_path
    keylset returnList status $::SUCCESS
    
    set statViewRoot [ixNet getRoot]statistics
    set statViewList [ixNet getList $statViewRoot view]
    set csv_file_list      ""
    set max_trk_count_list ""

    # stat view name -> stat view object
    array set stat_view_name_array {}

    foreach statViewName $statViewNameList {
        set view ""
        foreach statView $statViewList {
            if {[ixNet getAttribute $statView -caption] == $statViewName} {
                set view $statView
                set stat_view_name_array($statViewName) $statView
                break
            }
        }
        if {$view == ""} {
            if {$mode == "create" && $type != ""} {
                set retCode [540CreateUserDefinedView $statViewName $type]
                if {[keylget retCode status] != $::SUCCESS} {
                    return $retCode
                }
                set view    [keylget retCode view]
            } elseif {$mode != "all"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not find $statViewName view. Possible causes:\
                        traffic was not started or statistics collected too soon after traffic was started."
                return $returnList
            } else {
                keylset returnList rows ""
                keylset returnList page 0
                keylset returnList row  0
                return $returnList
            }
        }
        set commit_needed 0
        foreach {statistic} [ixNet getList $view statistic] {
            if {[ixNet getAttribute $statistic -enabled] != "true"} {
                if {[catch {ixNet setAttribute $statistic -enabled true} err] || $err != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Commit failed while extracting statistics for\
                            '[ixNet getA $view -caption]' on 'ixNet setAttribute $statistic -enabled true'. $err"
                    return $returnList
                }
                set commit_needed 1
            }
        }
        if {[ixNet getAttribute $view -enabled] != "true"} {
            if {[catch {ixNet setAttribute $view -enabled true} err] || $err != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Commit failed while extracting statistics for\
                        '[ixNet getA $view -caption]' on 'ixNet setAttribute $view -enabled true'. $err"
                return $returnList
            }
            set commit_needed 1
        }
        if {$commit_needed} {
            if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Commit failed while extracting statistics for\
                        '[ixNet getA $view -caption]'. $err"
                return $returnList
            }
        }
        
        set statViewObjRef "$view/page"
        
        set retry_count 10
        for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
            if {[ixNet getAttribute $statViewObjRef -isReady] == "true"} {
                break
            }
            after 1000
        }
        if {[ixNet getAttribute $statViewObjRef -isReady] != "true"} {
            keylset returnList status $::FAILURE
            keylset returnList log "'[ixNet getA $view -caption]' statistic view is not ready."
            return $returnList
        }
        if {$statViewName == "Flow Statistics" || $is_latency_view} {
            
            # max_trk_count is the number of fields that are tracked

            if {$statViewName == "Flow Statistics"} {
                
                # We must add a key called flow_name which is composed by the first columns that
                # represent the tracking used
                set ret_code [::ixia::540trafficGetMaxTiTrack]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                set max_trk_count [keylget ret_code ret_val]
                
                # We must add tx port, rx port and traffic item name to the count
                incr max_trk_count 3
                
            } elseif {$is_latency_view} {

                # the traffic item name is not available as stat.
                # Get it from view details
                set ret_code [ixNetworkEvalCmd [list ixNet getA $view/layer23TrafficFlowFilter -trafficItemFilterId]]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                set tmp_ti_filter [keylget ret_code ret_val]
                
                set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_ti_filter -name]]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                set ti_name [keylget ret_code ret_val]
                
                set tmp_ti_obj [540getTrafficItemByName $ti_name]
                if {$tmp_ti_obj == "_none"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not find a traffic item with '$ti_name' name."
                    return $returnList
                }
                
                # We must add a key called flow_name which is composed by the first columns that
                # represent the tracking used
                set ret_code [::ixia::540trafficGetMaxTiTrack $tmp_ti_obj]
                if {[keylget ret_code status] != $::SUCCESS} {
                    return $ret_code
                }
                
                set max_trk_count [keylget ret_code ret_val]
                
                # We must add rx port
                incr max_trk_count 1
                
                catch {unset tmp_ti_obj}
                catch {unset tmp_ti_filter}
            }
        } else {
            set max_trk_count 0
        }
        lappend max_trk_count_list $max_trk_count
    }
    
    set totalPages 1
    set opts [::ixia::stats_util::get_default_snapshot_settings]
    
    if {[regsub {DefaultSnapshotSettings} $opts "CombinedSnapshot" opts] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to customize the csv file name. regsub {DefaultSnapshotSettings} $opts $statViewNameList opts"
        return $returnList
    }
    
    if {![regexp {kOverwriteCSVFile} $opts]} {
        # Only try to replace kNewCSVFile with kOverwriteCSVFile if 
        # kOverwriteCSVFile is not present (the user might change IxN 
        # default to be kOverwriteCSVFile
        if {[regsub {kNewCSVFile} $opts {kOverwriteCSVFile} opts] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to customize the csv file name. regsub\
                    {kNewCSVFile} $opts {kOverwriteCSVFile} opts"
            return $returnList
        }
    }
    if {[catch {::ixTclNet::TakeViewCSVSnapshot $statViewNameList $opts} out] || $out != 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to '::ixTclNet::TakeViewCSVSnapshot \{$statViewNameList\} $opts':\
                $out"
        return $returnList
    }

    array set measure_mode_suffix {
        instantaneousMode   _Instantaneous
        cumulativeMode      _Cumulative
        mixedMode           ""
    }
    
    if {![ixNetworkGetAttr "::ixNet::OBJ-/traffic" -enableInstantaneousStatsSupport]} {
        set measure_mode mixedMode
    } else {
        set measure_mode [ixNetworkGetAttr "::ixNet::OBJ-/statistics/measurementMode" -measurementMode]
    }
    
    regsub -all {\\} $opts {\\\\} opts
    
    set file_dir ""
    foreach opt $opts {
        foreach {opt_key opt_val} $opt {
            if {$opt_key == "Snapshot.View.Csv.Location:"} {
                if {![isUNIX]} {
                    set file_dir [regsub -all {\\\\} $opt_val {/}]
                } else {
                    set file_dir $opt_val
                }
                break;
            }
        }
    }
    if {$file_dir == ""} {
        keylset returnList status $::FAILURE
        keylset returnList log "Could not find csv location in keyed string: $opts"
        return $returnList
    }
    
    foreach statViewName $statViewNameList {
        
        set file_name $statViewName
        # application traffic doesnt follow the naming rules
        if {![regexp "^application_" $mode]} {
            set view_obj $stat_view_name_array($statViewName)
            set view_type [ixNetworkGetAttr $view_obj -viewCategory ]
            if { $view_type == "L23Traffic" } {
                set file_name "${statViewName}$measure_mode_suffix($measure_mode)"
            } else {
                set file_name "${statViewName}"
            }
        }
        debug "$view_type ==> $file_name"
        set csv_file [file join $file_dir ${file_name}.csv]
        
        set csv_file [copy_csv_fileName $csv_file $file_name $csv_path $mode]        
        lappend csv_file_list $csv_file
    }
    
    keylset returnCode status             $::SUCCESS 
    keylset returnCode csv_file_list      $csv_file_list
    keylset returnCode max_trk_count_list $max_trk_count_list
    return $returnCode
}


proc ::ixia::540ParseCsvFromSnapshot {csv_file max_trk_count statViewName {is_latency_view "0"}} {
    set csv_ok 0
    set retry_count 10
    for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
        if {[catch {open $csv_file r} csv_fd]} {
            after 500
        } else {
            set csv_file_content [read $csv_fd]
            if {$csv_file_content == ""} {
                close $csv_fd
                after 500
            } else {
                set csv_ok 1
                break
            }
        }
    }
    
    if {!$csv_ok} {
        keylset returnList status $::FAILURE
        keylset returnList log "Could not open csv '$csv_file'"
        return $returnList
    }
    
    if {[catch {close $csv_fd} err]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Could not close csv file '$csv_file' with descriptor $csv_fd. $err"
        return $returnList
    }
    
    if {[isUNIX] && !$::ixia::debug} {
        catch {file delete $csv_file}
    }
    
    set csv_file_lines [split $csv_file_content \n]
    
    if {[llength $csv_file_lines] < 2} {
        keylset returnList status $::FAILURE
        keylset returnList log "Csv file '$csv_file' doesn't have any values.\
                Only columns were found. $err"
        return $returnList
    }
    
    #puts "$csv_file_lines"
    set columnCaptions [split [lindex $csv_file_lines 0] ,]
    #puts "columnCaptions == $columnCaptions"
    

    
    set currentRow      1
    set pageNumber      1; # normally it starts from one and gets incremented. The calling proc expects num of pages + 1
    
    set captionsList ""
    
    set rowList [lrange $csv_file_lines 1 end]
    
    foreach row $rowList {
        
        #puts "row == $row"
        
        if {$row == ""} {
            continue
        }
        
        set row [split $row ,]
        
        if {$statViewName == "Flow Statistics" || $is_latency_view} {
            
            set cellList [lrange $row 0 end]
            set currentColumn 0
            if {$statViewName == "Flow Statistics"} {
                set row_name ""
            } elseif {$is_latency_view} {
                set row_name "[regsub -all {\"} [lindex $row 0] {}] $ti_name "
            }
            
            foreach tmpCell [lrange $row 1 [expr $max_trk_count - 1]] {
                if {[llength $tmpCell] > 0} {
                    append row_name "[regsub -all {\"} $tmpCell {}] "
                } else {
                    append row_name "N/A "
                }
            }
            
            set row_name [string trim $row_name]
            
            catch {unset tmpCell}
        } else {
             #puts "row --> $row"
            set row_name [regsub -all {\"} [lindex $row 0] {}]
             #puts "row_name --> $row_name"
            set cellList [lrange $row 0 end]
             #puts "cellList --> $cellList"
            set currentColumn 0
        }
        
        
        foreach cell $cellList {
                 #puts "\tcell --> $cell"
            regsub -all {\"} $cell {} cell
            set stat_name [lindex $columnCaptions $currentColumn]
            regsub -all {\"} $stat_name {} stat_name
            if {[lsearch $captionsList $stat_name] == -1} {
                lappend captionsList $stat_name
            }
                 #puts "\tstat_name --> $stat_name"
            set stat_value $cell
                 #puts "\tset rowsArray($pageNumber,$currentRow,$stat_name) $stat_value"
            if {[llength $stat_value] == 0} {
                set stat_value "N/A"
            }
            set rowsArray($pageNumber,$currentRow,$stat_name) $stat_value
            incr currentColumn
        }
        
             #puts "set rowsArray($pageNumber,$currentRow) $row_name"
        set rowsArray($pageNumber,$currentRow) $row_name
        incr currentRow
    }
    
    incr pageNumber      1; # The calling proc expects num of pages + 1
    keylset returnList status   $::SUCCESS
    keylset returnList rows     [array get rowsArray]
    keylset returnList captions $captionsList
    keylset returnList page     $pageNumber
    keylset returnList row      $currentRow

    return $returnList
}


proc ::ixia::540CreateProtocolPortView {args} {
    
    debug "540CreateProtocolPortView $args"
    
    keylset returnList status $::SUCCESS
    
    set man_args {
        -port_handle          REGEXP ^[0-9]+/[0-9]+/[0-9]+$
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args \
            -mandatory_args $man_args} errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    
    # Create a list with requested port_filters
    debug "540CreateProtocolPortView --> Searching for existing view"
    set pf_name_requested_list ""
    foreach port_h $port_handle {
        set ret_code [ixNetworkGetPortFilterName $port_h]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        lappend pf_name_requested_list [keylget ret_code port_filter_name]
    }
    
    # Search to see if there already is such a view
    set ret_code [ixNetworkEvalCmd [list ixNet getL [ixNet getRoot]statistics view]]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    set view_list [keylget ret_code ret_val]
    
    set view_found 0
    foreach existing_view $view_list {
        
        set ret_code [ixNetworkEvalCmd [list ixNet getA $existing_view -type]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        # Check only views of type layer23ProtocolPort
        if {[keylget ret_code ret_val] != "layer23ProtocolPort"} {
            continue
        }
        
        # Check if port filters are the ones requested
        set continue_flag 0
        
        set ret_code [ixNetworkEvalCmd [list ixNet getA $existing_view/layer23ProtocolPortFilter -portFilterIds]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        set tmp_pfid_list [keylget ret_code ret_val]
        if {$tmp_pfid_list != ""} {
            set tmp_pfid_name_list ""
            foreach tmp_pfid $tmp_pfid_list {
                lappend tmp_pfid_name_list [ixNetworkGetAttr $tmp_pfid -name]
            }
            
            
            foreach pf_name_req $pf_name_requested_list {
                if {[lsearch $tmp_pfid_name_list $pf_name_req] == -1} {
                    set continue_flag 1
                    break
                }
            }
            
        }
        
        if {$continue_flag} {
            continue
        }
        
        # Looks like we found what we want. The view already exists. Use it.
        set view_found 1
        break
    }

    # Return the existing view for query
    if {$view_found} {
        debug "540CreateProtocolPortView --> View found: $existing_view"
        keylset returnList protocol_port_view $existing_view
        return $returnList
    }
    
    debug "540CreateProtocolPortView --> View not found: Creating it."
    # View does not exist. Create it.
    set result [ixNetworkNodeAdd [ixNet getRoot]statistics view [list \
            -type layer23ProtocolPort -visible true] -commit]
    if {[keylget result status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to create new stat view -\
                [keylget result log]."
        return $returnList
    }
    
    set new_view_obj_ref [keylget result node_objref]
    
    
    # Get available port filters. Match against requested ones
    set ret_code [ixNetworkEvalCmd [list ixNet getL $new_view_obj_ref availablePortFilter]]
    if {[keylget ret_code status] != $::SUCCESS} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        return $ret_code
    }
    set available_port_filters [keylget ret_code ret_val]
    debug "540CreateProtocolPortView --> Available port filters are: $available_port_filters"
    
    array set tmp_pfid_name_array ""
    foreach tmp_pfid $available_port_filters {
        set tmp_pfid_name_array([ixNetworkGetAttr $tmp_pfid -name]) $tmp_pfid
    }
    
    set pf_final_list ""
    foreach pf_name_req $pf_name_requested_list {
        if {![info exists tmp_pfid_name_array($pf_name_req)]} {
            debug "Virtual port with internalId:name $pf_name_req was not found in available port filters"
            continue
        }
        
        lappend pf_final_list $tmp_pfid_name_array($pf_name_req)
    }
    
    if {[llength $pf_final_list] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to create protocol port user defined statistic view because non of the\
                requested ports: '$port_handle' is a valid available port filter"
        return $returnList
    }
    
    set result [ixNetworkNodeSetAttr ${new_view_obj_ref}/layer23ProtocolPortFilter \
            [list -portFilterIds $pf_final_list] -commit]
    if {[keylget result status] == $::FAILURE} {
        catch {ixNet remove $new_view_obj_ref}
        catch {ixNet commit}
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to configure port filters for\
                protocol port user defined statistic view $new_view_obj_ref -[keylget result log]"
        return $returnList
    }
    
    
    foreach stat_key [ixNet getL ${new_view_obj_ref} statistic] {
        set ret_val [ixNet setA $stat_key -enabled true]
        if {$ret_val != "::ixNet::OK"} {
            catch {ixNet remove $new_view_obj_ref}
            catch {ixNet commit}
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to enable $stat_key. $ret_val."
            return $returnList
        }
    }
    
    # Enable statistics here because of bug BUG521961
    set retry_count 5
    while {$retry_count > 0} {
        set ret_val [ixNet setA ${new_view_obj_ref} -enabled true]
        if {$ret_val != "::ixNet::OK"} {
            catch {ixNet remove $new_view_obj_ref}
            catch {ixNet commit}
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to enable ${new_view_obj_ref}. $ret_val."
            return $returnList
        }
        
        set ret_code [ixNetworkEvalCmd [list ixNet commit] "ok"]
        if {[keylget ret_code status] != $::SUCCESS} {
            catch {ixNet remove $new_view_obj_ref}
            catch {ixNet commit}
            return $ret_code
        }
        
        if {[ixNet getA ${new_view_obj_ref} -enabled] == "true"} {
            break
        }
        incr retry_count -1
    }
    
    set statViewObjRef "$new_view_obj_ref/page"

    set retry_count 4
    for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
        if {[ixNet getAttribute $statViewObjRef -isReady] == "true"} {
            break
        }
        after 1000
    }
    
    if {[ixNet getAttribute $statViewObjRef -isReady] != "true"} {
        keylset returnList status $::FAILURE
        keylset returnList log "'[ixNet getA $new_view_obj_ref -caption]' statistic view is not ready."
        return $returnList
    }
    
    keylset returnList protocol_port_view $new_view_obj_ref
    return $returnList
}


proc ::ixia::540TrafficIsWaitingForStats {timeout} {
    
    set ret_val 1
    
    for {set i 0} {$i < $timeout} {incr i} {
        
        catch {set trafficState [ixNet getAttribute [ixNet getRoot]traffic -state]}
        
        if {$trafficState == "started" || $trafficState == "stopped"} {
            set ret_val 0
            break
        }
        
        after 1000
    }
    
    return $ret_val
}




proc ::ixia::540GetEgressStatViewConditional {statViewName {mode "all"} {egress_stats_list "all"}} {
    
    variable ixnetwork_port_handles_array
    keylset returnList status $::SUCCESS
    
    set statViewRoot [ixNet getRoot]statistics
    
    set statViewList [ixNet getList $statViewRoot view]

    set view ""
    foreach statView $statViewList {
        if {[ixNet getAttribute $statView -caption] == $statViewName} {
            set view $statView
            break
        }
    }
    if {$view == ""} {
        if {$mode != "all"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not find $statViewName view. Possible causes:\
                    traffic was not started or statistics collected too soon after traffic was started."
            return $returnList
        } else {
            keylset returnList rows ""
            keylset returnList page 0
            keylset returnList row  0
            return $returnList
        }
    }
    
    set commit_needed 0
    if {$egress_stats_list == "all"} {
        foreach {statistic} [ixNet getList $view statistic] {
            if {[ixNet getAttribute $statistic -enabled] != "true"} {
                if {[catch {ixNet setAttribute $statistic -enabled true} err] || $err != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Commit failed while extracting statistics for\
                            '[ixNet getA $view -caption]' on 'ixNet setAttribute $statistic -enabled true'. $err"
                    return $returnList
                }
                set commit_needed 1
            }
        }
    }
    
    if {[ixNet getAttribute $view -enabled] != "true"} {
        if {[catch {ixNet setAttribute $view -enabled true} err] || $err != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Commit failed while extracting statistics for\
                    '[ixNet getA $view -caption]' on 'ixNet setAttribute $view -enabled true'. $err"
            return $returnList
        }
        set commit_needed 1
    }
    
    if {$commit_needed} {
        if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Commit failed while extracting statistics for\
                    '[ixNet getA $view -caption]'. $err"
            return $returnList
        }
    }
    
    set statViewObjRef  "$view/page"

    if {[catch {ixNet getAttribute $statViewObjRef -totalPages} totalPages]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to get total number of pages for\
                    '[ixNet getA $view -caption]' statistic view. $totalPages"
        return $returnList
    }
    
    set egressPageSize [ixNet getAttr $statViewObjRef -egressPageSize]
    
    if {[catch {ixNet getList $statViewObjRef egress} estatViewObjRefList] ||\
            [llength $estatViewObjRefList] == 0} {
                
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to get total number of pages for\
                    '[ixNet getA $view -caption]' statistic view. Egress object is\
                    missing: $estatViewObjRefList"
        return $returnList
    }
    
    # Determine the optimum egressPageSize value
    # set maxRowCount 0
    # foreach egress $estatViewObjRefList {
        # set rowCount [ixNet getAttribute $egress -rowCount]
        # if {$rowCount > $maxRowCount} {
            # set maxRowCount $rowCount
        # }
    # }
    
    set retry_count 10
    for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
        if {[ixNet getAttribute $statViewObjRef -isReady] == "true"} {
            break
        }
        after 1000
    }
    
    if {[ixNet getAttribute $statViewObjRef -isReady] != "true"} {
        keylset returnList status $::FAILURE
        keylset returnList log "'[ixNet getA $view -caption]' statistic view is not ready."
        return $returnList
    }
    
    set columnCaptions [ixNet getAttribute $statViewObjRef -columnCaptions]
    set rx_port_column_idx [lsearch $columnCaptions "Rx Port"]
    if {$rx_port_column_idx == -1} {
        debug "Rx Port column not found while gathering egress stats. ixNet getAttribute $statViewObjRef -columnCaptions\
                returned $columnCaptions"
        set rx_port_column_idx 0
    }
    
    set egress_tracking_column_idx [lsearch -glob $columnCaptions "Egress Tracking*"]
    if {$rx_port_column_idx == -1} {
        # Can't live without it
        keylset returnList status $::FAILURE
        keylset returnList log "Egress Tracking column not found while gathering egress stats. ixNet getAttribute $statViewObjRef -columnCaptions\
                returned $columnCaptions"
        return $returnList
    }
    
    keylset returnList egress_tracking_col [lindex $columnCaptions $egress_tracking_column_idx]
    
    # max_trk_count is the number of fields that are tracked

    # the traffic item name is not available as stat.
    # Get it from view details
    set ret_code [ixNetworkEvalCmd [list ixNet getA $view/layer23TrafficFlowFilter -trafficItemFilterIds]]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    set tmp_ti_filters [keylget ret_code ret_val]
    
    # Get the available traffic items
    set ti_handles_list [ixNet getList [ixNet getRoot]traffic trafficItem]
    # Get the traffic items names
    foreach ti_handle $ti_handles_list {
        set ti_name [ixNet getA $ti_handle -name]
        array set ti_names_array [list $ti_handle $ti_name]
    }
    set tmp_ti_obj_list ""
    foreach tmp_ti_filter $tmp_ti_filters {
        set ret_code [ixNetworkEvalCmd [list ixNet getA $tmp_ti_filter -name]]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        set ti_name [keylget ret_code ret_val]
        
        set found 0
        foreach {traffic_item_handle traffic_item_name} [array get ti_names_array] { 
            if {$traffic_item_name == $ti_name} {
                set found 1
                break
            }
        }
        
        if {$found} {
            set tmp_ti_obj $traffic_item_handle
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not find a traffic item with '$ti_name' name."
            return $returnList
        }
        
        lappend tmp_ti_obj_list $tmp_ti_obj
    }
    
    # We must add a key called flow_name which is composed by the first columns that
    # represent the tracking used
    set ret_code [::ixia::540trafficGetMaxTiTrack $tmp_ti_obj_list]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    set max_trk_count [keylget ret_code ret_val]
    
    # We must add rx port
    incr max_trk_count 1
    
    catch {unset tmp_ti_obj}
    catch {unset tmp_ti_filter}
    
    set currentRow      1
    if {$totalPages == 0} {
        set totalPages 1
    }
    # Set ids for the aggregate rows
    set index 1
    for {set pageNumber 1} {$pageNumber <= $totalPages} {incr pageNumber} {
        foreach estatViewObjRef $estatViewObjRefList {
            set aggregateIds($pageNumber,$estatViewObjRef) $index
            incr index
        }
    }
    
    # The current stat viewer implementation for turning egress row page
    # duplicates some egress elements, so we need to keep track of all the 
    # distinct elements
    set flow_name_list [list]
    array set flow_name_array [list]
    
    set captionsList ""
    for {set pageNumber 1} {$pageNumber <= $totalPages} {incr pageNumber} { 
        update idletasks 
        
        if {[ixNet getAttribute $statViewObjRef -currentPage] != $pageNumber} {
            if {[catch {ixNet setAttribute $statViewObjRef -currentPage $pageNumber} err] || $err != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not change page number to $pageNumber for $statViewObjRef. $err"
                return $returnList
            }
            
            if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not commit changing current page for stat view. Failed on commit. $err"
                return $returnList
            }
        }
        
        catch {array unset estatViewArray}
        foreach estatViewObjRef $estatViewObjRefList {
            # egressPageSize is the maximum number of flows (egress values) displayed on a page
            # erow_count will be the actual number of flows (egress values) displayed on a page
            # I want the while loop to end when the number of egress flows returned is smaller than
            #   the maximum number of flows. That means that there are no more flows and the flowCondition
            #   doesn't have to change anymore
            set estatViewArray($estatViewObjRef,erow_count) $egressPageSize
            
            set estatViewArray($estatViewObjRef,max_egress_val)     0
            # If the maximum egress value will not change the while loop will be stopped
            set estatViewArray($estatViewObjRef,max_egress_val_bak) 0
        }
        
        if {![info exists ::ixia::egress_timeout]} {
            set ::ixia::egress_timeout 3600; # 1 hour
        }
        set done_egress 0
        set start_time [clock seconds]
        while {!$done_egress} {
            set done_egress 1
            update idletasks
        
            set parse_egress_pages 1
            while {$parse_egress_pages} {
                set parse_egress_pages 0
                
                # Wait for stat view to be ready
                set retry_count 10
                for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
                    if {[ixNet getAttribute $statViewObjRef -isReady] == "true"} {
                        break
                    }
                    after 1000
                }
                
                if {[ixNet getAttribute $statViewObjRef -isReady] != "true"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "'[ixNet getA $view -caption]' statistic view is not ready."
                    return $returnList
                }
                
                # Get the statistics for the current page
                set retry_count 5
                for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
                    if {[set rowList [ixNet getA $statViewObjRef -rowValues]] != ""} {
                        break
                    }
                    after 1000
                }
                
                update idletasks
               
                foreach row_items $rowList egress_current_row_obj $estatViewObjRefList {
                    update idletasks
                    set row_inner_idx 0
                    foreach row $row_items {
                        update idletasks
                        set cellList [lrange $row 0 end]
                        set currentColumn 0
                            
                        # The first row cotains the aggregated statistics
                        if {$row_inner_idx == 0} {
                            update idletasks
                            set rx_port [lindex $row $rx_port_column_idx]
                            
                            set vport_found 0
                            foreach vport_name [array names ixnetwork_port_handles_array] {
                                if {$vport_name == $rx_port} {
                                    set vport_found $vport_name
                                    break
                                }
                            }
                            if {$vport_found!=0} {
                                set rx_port $vport_found
                            }
                            set row_name "[lindex $row 0] [lindex $row 3] "
                            foreach tmpCell [lrange $row 1 [expr $max_trk_count - 1]] {
                                if {[llength $tmpCell] > 0} {
                                    append row_name "$tmpCell "
                                } else {
                                    append row_name "N/A "
                                }
                            }
                            
                            set row_name [string trim $row_name]
                            catch {unset tmpCell}
                            
                            foreach cell $cellList {
                                set stat_name [lindex $columnCaptions $currentColumn]
                                if {[lsearch $captionsList $stat_name] == -1} {
                                    lappend captionsList $stat_name
                                }
                                set stat_value $cell
                                
                                # Set the values for the aggregated statistics
                                set aggregateRowsArray($aggregateIds($pageNumber,$egress_current_row_obj),$stat_name) $stat_value
                                
                                incr currentColumn
                            }
                            set aggregateRowsArray($aggregateIds($pageNumber,$egress_current_row_obj),rx_port) $rx_port
                            if {![info exists aggregateRowsArray(ids)]} {
                                set aggregateRowsArray(ids) [list]
                            }
                            
                            # If the current id is not in the list append it to the aggregated statistics
                            if {[lsearch $aggregateRowsArray(ids) $aggregateIds($pageNumber,$egress_current_row_obj)] == -1} {
                                lappend aggregateRowsArray(ids) $aggregateIds($pageNumber,$egress_current_row_obj)
                            }
                            
                        } else {
                            update idletasks
                            # We have statistics on the current page, so it is possible to have statistics
                            # on another page.
                            set skip_row false
                            foreach cell $cellList {
                                  
                                set stat_name [lindex $columnCaptions $currentColumn]
                                set stat_value $cell
                                
                                if {[lsearch $captionsList $stat_name] == -1} {
                                    lappend captionsList $stat_name
                                }

                                # The value contained by the Egress Tracking statistic represents the flow_name
                                if {$stat_name == "Egress Tracking" && [info exists flow_name_array($aggregateIds($pageNumber,$egress_current_row_obj),$stat_value))]} {
                                    set skip_row true
                                    break
                                }
                                
                                # The current egress row is unique, we must add it to the list
                                if {$stat_name == "Egress Tracking"} {
                                    set flow_name_array($aggregateIds($pageNumber,$egress_current_row_obj),$stat_value)) "$stat_value"
                                }
                                
                                if {[llength $stat_value] != 0} {
                                    set rowsArray($pageNumber,$currentRow,$stat_name) $stat_value
                                }
                                incr currentColumn
                            }
                            
                            # If the current row is not duplicate we must keep the statistics
                            if {$skip_row == false} {
                                set rowsArray($pageNumber,$currentRow,Rx\ Port) $rx_port
                                set rowsArray($pageNumber,$currentRow) $row_name
                                set rowsArray($pageNumber,$currentRow,aggregateId) $aggregateIds($pageNumber,$egress_current_row_obj)
                                
                                if {[info exists rowsArray($pageNumber,$currentRow,Egress\ Tracking)]} {
                                    if {$estatViewArray($egress_current_row_obj,max_egress_val) < $rowsArray($pageNumber,$currentRow,Egress\ Tracking)} {
                                        set estatViewArray($egress_current_row_obj,max_egress_val) $rowsArray($pageNumber,$currentRow,Egress\ Tracking)
                                    }
                                }
                                incr currentRow
                            }
                        }
                        
                        incr row_inner_idx
                    }
                    
                    if {$row_inner_idx > $egressPageSize} {
                        set parse_egress_pages 1
                    }
                }
                
                # If the current page contains less than egressPageSize elements
                if {$parse_egress_pages == 0} {
                    break
                }
                
                set egress_list [ixNet getList $statViewObjRef egress]
                foreach egress $egress_list {
                    ixNet setAttribute $egress -commitEgressPage true
                }
                
                update idletasks
                if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not commit when trying to change the egress flow page. Failed on commit. $err"
                    return $returnList
                }
            }
            
            if {[mpexpr [clock seconds] - $start_time] > $::ixia::egress_timeout} {
                keylset returnList status $::FAILURE
                keylset returnList log "Timeout 3600 occured while gathering egress\
                        statistics for '[ixNet getA $view -caption]' statistic view. To\
                        increase the timeout value set the ::ixia::egress_timeout variable\
                        to the desired value in seconds"
                return $returnList
            }
        }
    }
    
    array get rowsArray
    keylset returnList rows     [array get rowsArray]
    keylset returnList aggregate [array get aggregateRowsArray]
    keylset returnList captions $captionsList
    keylset returnList page     $pageNumber
    keylset returnList row      $currentRow

    return $returnList
}

proc ::ixia::540GetAppLibTrafficViewStats {statViewNameList mode drill_down_type filter_list keyed_array_name} {

    set keyed_array_index 0
    variable $keyed_array_name

    set statViewRoot [ixNet getRoot]statistics
    set statViewList [ixNet getList $statViewRoot view]
    keylset returnList status $::SUCCESS 
    
    foreach statViewName $statViewNameList {
        set view ""
        foreach statView $statViewList {
            if {[ixNet getAttribute $statView -caption] == $statViewName} {
                set view $statView
                break
            }
        }
        if {$view == ""} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not find $statViewName view. Possible causes:\
                    traffic was not started or statistics collected too soon after traffic was started."
                    return $returnList
        }

        set commit_needed 0

        if {[ixNet getAttribute $view -enabled] != "true"} {
            if {[catch {ixNet setAttribute $view -enabled true} err] || $err != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Cannot enable statistics view $view: $err"
                return $returnList
            }
            set commit_needed 1
        }

        if {$commit_needed} {
            if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Commit failed while extracting statistics for\
                        '[ixNet getA $view -caption]'. $err"
                return $returnList
            }
        }

        set statViewObjRef "$view/page"

        if {[catch {ixNet getAttribute $statViewObjRef -totalPages} totalPages]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to get total number of pages for\
                    '[ixNet getA $view -caption]' statistic view. $totalPages"
        return $returnList
        }

        set retry_count 10
        for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
        if {[ixNet getAttribute $statViewObjRef -isReady] == "true"} {
            break
        }
        after 1000
        }

        if {[ixNet getAttribute $statViewObjRef -isReady] != "true"} {
        keylset returnList status $::FAILURE
        keylset returnList log "'[ixNet getA $view -caption]' statistic view is not ready."
        return $returnList
        }
        if {$drill_down_type != "none"} {
            return [::ixia::540GetAppLibTrafficDrillDownViewStats $mode $view $drill_down_type $filter_list $keyed_array_name]
        }
        set columnCaptions [ixNet getAttribute $statViewObjRef -columnCaptions]
        set columnCount [ixNet getAttribute $statViewObjRef -columnCount]

        set rowValues [ixNet getAttribute $statViewObjRef -rowValues]
        set rowCount [ixNet getAttribute $statViewObjRef -rowCount]

        
        for {set i 0} {$i < $rowCount} {incr i} {
            set statList [list]            
            set traffic_item [lindex [lindex [lindex $rowValues $i] 0] 0]
            #Removing Traffic Item name from the values
            set valueList [lreplace [lindex [lindex $rowValues $i] 0] 0 0]
            set columnNames [lreplace $columnCaptions 0 0]
            set columnNo [expr $columnCount - 1]            
            set key $traffic_item
            
            if {$mode != "L47_traffic_item" && $mode != "L47_traffic_item_tcp"} {
                set application_flow_name [string map {" - " _ - _ "." "" ( "" ) "" " " _} [lindex $valueList 0]]
                #Removing Application Flow name from the values
                set valueList [lreplace $valueList 0 0]
                set columnNames [lreplace $columnNames 0 0]
                set columnNo [expr $columnNo - 1]
                set key $key.$application_flow_name                
            }
            
            for {set j 0} {$j < $columnNo} {incr j} {
                set ret_val [regsub -all {[\(\)%]} [lindex $columnNames $j] "" stat]
                set ret_val [regsub -all {[\.\s-]} [string trim $stat] "_" stat]
                set statName [string tolower $stat]           
                set value [lindex $valueList $j]
                set [subst $keyed_array_name]($mode.$key.$statName) $value
                incr keyed_array_index            
            }                 
        }
    }
    keylset returnList stat_count $keyed_array_index
    return $returnList
}

proc ::ixia::540GetAppLibTrafficDrillDownViewStats {mode view drill_down_type filter_list keyed_array_name {drill_down_row_index_list ""}} {

    set keyed_array_index 0
    variable $keyed_array_name
    keylset returnList status $::SUCCESS
    
    set statViewRoot [ixNet getRoot]statistics
    
    #intialize filter value array
    array set drill_down_filter $filter_list  
    array set drill_down_map [list  per_ips {Application Traffic:Per IPs}                           \
                                    per_ports {Application Traffic:Per Ports}                       \
                                    per_initiator_flows {Application Traffic:Per Initiator Flows}   \
                                    per_responder_flows {Application Traffic:Per Responder Flows}   \
                                    per_initiator_ports {Application Traffic:Per Initiator Ports}   \
                                    per_initiator_ips   {Application Traffic:Per Initiator IPs}     \
                                    per_responder_ports {Application Traffic:Per Responder Ports}   \
                                    per_listening_ports {Application Traffic:Per Listening Ports}   \
                                    per_responder_port  {Application Traffic:Per Responder Port}   \
                                    per_responder_ips   {Application Traffic:Per Responder IPs}     ]

    if {$drill_down_row_index_list == ""} {    
        #Get available target row count
        set available_target_row_filters [ixNet getList $view/drillDown availableTargetRowFilters]
        set available_target_row_count [llength $available_target_row_filters]        
        set pattern ""
        append pattern $view /drillDown/availableTargetRowFilters: {"Traffic Item=(.+)"}
        for {set index 0} {$index < $available_target_row_count} {incr index} {
            set target_row [lindex $available_target_row_filters $index]
            set ret_code [regexp $pattern  $target_row matchVar subVar]
            if {$subVar == $drill_down_filter(drill_down_traffic_item)} {
                lappend drill_down_row_index_list $index
            }
        }
    }
    #set the drill_down_option
    set enable_next_level_drill_down 0
    #check for three level drill down
    set return_val [regexp "(per_.+)_((per_.+)_(per_.+))" $drill_down_type matchVar level_one_drill_down next_level_drill_down]
    if {!$return_val} {
        #check for two level drill down
        set return_val [regexp "(per_.+)_(per_.+)" $drill_down_type matchVar level_one_drill_down next_level_drill_down]
    }
    if {$return_val} {    
        set enable_next_level_drill_down 1
        set drill_down_type $level_one_drill_down
    }
    set got_statistics 0
    set drill_down_option $drill_down_map(${drill_down_type})
    foreach row_index $drill_down_row_index_list {
        if {$got_statistics == 1} {
            break
        }
        set ret_code [::ixia::doDrillDownOperation $row_index $view $drill_down_option]
        if {[keylget ret_code status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "[keylget ret_code log]"
                return $returnList
        }
        set drill_down_view [keylget ret_code drill_down_view]
        set columnCaptions  [keylget ret_code column_captions]
        set columnCount     [keylget ret_code column_count]
        set rowValues       [keylget ret_code row_values]
        set rowCount        [keylget ret_code row_count]
        for {set row_no 0} {$row_no < $rowCount} {incr row_no} {
            set statList [list]
            set stat_value_list [lindex [lindex $rowValues $row_no] 0]
            switch -- $drill_down_type {
                "per_responder_port" {
                    set traffic_item [lindex $stat_value_list 0]
                    set listening_port [lindex $stat_value_list 1]
                    if {$listening_port != $drill_down_filter(drill_down_listening_port)} {
                        break
                    }
                    if {![info exists drill_down_filter(drill_down_listening_port)]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "drill_down_listening_port value is necessary for retrieving $drill_down_type stats"
                        return $returnList
                    }
                    set port_name [lindex $stat_value_list 2]
                    if {$enable_next_level_drill_down} {
                        if {$port_name == $drill_down_filter(drill_down_port)} {
                            set retCode [540GetAppLibTrafficDrillDownViewStats $mode $drill_down_view $next_level_drill_down $filter_list $keyed_array_name $row_no]
                            return $retCode
                        } else {
                            continue
                        }
                    }
                    set stat_value_list [lreplace $stat_value_list 0 2]
                    set columnNames [lreplace $columnCaptions 0 2]
                    set columnNo [expr $columnCount - 3]
                    set key ${traffic_item}.${listening_port}.${port_name}
                }
                "per_responder_ports" {
                    set traffic_item [lindex $stat_value_list 0]
                    set application_flow_name [string map {" - " _ - _ "." "" ( "" ) "" " " _} [lindex $stat_value_list 1]]
                    if {$application_flow_name != $drill_down_filter(drill_down_flow)} {
                        break
                    }
                    set port_name [lindex $stat_value_list 2]
                    if {$enable_next_level_drill_down} {
                        if {$port_name == $drill_down_filter(drill_down_port)} {
                            set retCode [540GetAppLibTrafficDrillDownViewStats $mode $drill_down_view $next_level_drill_down $filter_list $keyed_array_name $row_no]
                            return $retCode
                        } else {
                            continue
                        }
                    }
                    set role [lindex $stat_value_list 3]
                    set stat_value_list [lreplace $stat_value_list 0 3]
                    set columnNames [lreplace $columnCaptions 0 3]
                    set columnNo [expr $columnCount - 4]            
                    set key ${traffic_item}.${application_flow_name}.${port_name}.${role}
                }
                "per_initiator_ports" {
                    set traffic_item [lindex $stat_value_list 0]
                    set application_flow_name [string map {" - " _ - _ "." "" ( "" ) "" " " _} [lindex $stat_value_list 1]]
                    if {$application_flow_name != $drill_down_filter(drill_down_flow)} {
                        break
                    }
                    set port_name [lindex $stat_value_list 2]
                    if {$enable_next_level_drill_down} {
                        if {$port_name == $drill_down_filter(drill_down_port)} {
                            set retCode [540GetAppLibTrafficDrillDownViewStats $mode $drill_down_view $next_level_drill_down $filter_list $keyed_array_name $row_no]
                            return $retCode
                        } else {
                            continue
                        }
                    }
                    set got_statistics 1
                    set role [lindex $stat_value_list 3]
                    set stat_value_list [lreplace $stat_value_list 0 3]
                    set columnNames [lreplace $columnCaptions 0 3]
                    set columnNo [expr $columnCount - 4]            
                    set key ${traffic_item}.${application_flow_name}.${port_name}.${role}
                }
                "per_ports" {
                    #retreive Traffic Item , Port Name and Role for key                    
                    set traffic_item [lindex $stat_value_list 0]
                    set port_name [lindex $stat_value_list 1]
                    set role [lindex $stat_value_list 2]
                    set stat_value_list [lreplace $stat_value_list 0 2]
                    set columnNames [lreplace $columnCaptions 0 2]
                    set columnNo [expr $columnCount - 3]            
                    set key ${traffic_item}.${port_name}.${role}
                    if {$enable_next_level_drill_down} {
                        if {$port_name == $drill_down_filter(drill_down_port)} {
                            set retCode [540GetAppLibTrafficDrillDownViewStats $mode $drill_down_view $next_level_drill_down $filter_list $keyed_array_name $row_no]
                            return $retCode
                        } else {
                            continue
                        }
                    }
                }
                "per_ips" -
                "per_responder_ips" {
                    #retreive Traffic Item , Port Name, Application Flow, Role and IP for key
                    set traffic_item [lindex $stat_value_list 0]
                    set port_name [lindex $stat_value_list 1]
                    set application_flow_name [string map {" - " _ - _ "." "" ( "" ) "" " " _} [lindex $stat_value_list 2]]
                    if {$drill_down_type != "per_ips"} {
                        if {[info exists drill_down_filter(drill_down_flow)] && $application_flow_name != $drill_down_filter(drill_down_flow)} {
                            break
                        }
                    }
                    set ret_val [regsub -all {[\.\s-]} [lindex $stat_value_list 5] "_" role]
                    set ret_val [regsub -all {[\.\s-]} [lindex $stat_value_list 3] "_" ip_value]
                    set ipv6_value [lindex $stat_value_list 4]
                    set stat_value_list [lreplace $stat_value_list 0 5]
                    set columnNames [lreplace $columnCaptions 0 5]
                    set columnNo [expr $columnCount - 6]
                    set key ${traffic_item}.${port_name}.${application_flow_name}.${role}.${ip_value}_${ipv6_value}
                }
                "per_initiator_ips" {
                    #retreive Traffic Item , Port Name, Application Flow, Role and IP for key
                    set traffic_item [lindex $stat_value_list 0]
                    set port_name [lindex $stat_value_list 1]
                    set application_flow_name [string map {" - " _ - _ "." "" ( "" ) "" " " _} [lindex $stat_value_list 2]]
                    if {[info exists drill_down_filter(drill_down_flow)] && $application_flow_name != $drill_down_filter(drill_down_flow)} {
                        continue
                    }
                    set ret_val [regsub -all {[\.\s-]} [lindex $stat_value_list 4] "_" ipv6_value]
                    set ret_val [regsub -all {[\.\s-]} [lindex $stat_value_list 3] "_" ip_value]
                    set role [lindex $stat_value_list 5]
                    set stat_value_list [lreplace $stat_value_list 0 5]
                    set columnNames [lreplace $columnCaptions 0 5]
                    set columnNo [expr $columnCount - 6]            
                    set key ${traffic_item}.${port_name}.${application_flow_name}.${role}.${ip_value}_${ipv6_value}
                }
                "per_listening_ports" {
                    #retreive Traffic Item and Application Flow for key
                    set traffic_item [lindex $stat_value_list 0]
                    set listening_port [string map {" - " _ - _ "." "" ( "" ) "" " " _} [lindex $stat_value_list 1]]
                    set stat_value_list [lreplace $stat_value_list 0 1]
                    set columnNames [lreplace $columnCaptions 0 1]
                    set columnNo [expr $columnCount - 2]
                    set key ${traffic_item}.${listening_port}
                    if {$enable_next_level_drill_down} {
                        if {![info exists drill_down_filter(drill_down_listening_port)]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "drill_down_listening_port value is necessary for retrieving $drill_down_type stats"
                            return $returnList
                        }
                        if {$listening_port == $drill_down_filter(drill_down_listening_port)} {
                            set retCode [540GetAppLibTrafficDrillDownViewStats $mode $drill_down_view $next_level_drill_down $filter_list $keyed_array_name $row_no]
                            return $retCode
                        } else {
                            continue
                        }
                    }
                }
                "per_initiator_flows" -
                "per_responder_flows" {
                    #retreive Traffic Item and Application Flow for key
                    set traffic_item [lindex $stat_value_list 0]
                    set application_flow_name [string map {" - " _ - _ "." "" ( "" ) "" " " _} [lindex $stat_value_list 1]]
                    set stat_value_list [lreplace $stat_value_list 0 1]
                    set columnNames [lreplace $columnCaptions 0 1]
                    set columnNo [expr $columnCount - 2]
                    set key ${traffic_item}.${application_flow_name}
                    if {$enable_next_level_drill_down} {
                        if {![info exists drill_down_filter(drill_down_flow)]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "drill_down_flow value is necessary for retrieving $drill_down_type stats"
                            return $returnList
                        }
                        if {$application_flow_name == $drill_down_filter(drill_down_flow)} {
                            set retCode [540GetAppLibTrafficDrillDownViewStats $mode $drill_down_view $next_level_drill_down $filter_list $keyed_array_name $row_no]
                            return $retCode
                        } else {
                            continue
                        }
                    }
                }
            }
            for {set j 0} {$j < $columnNo} {incr j} {
                set ret_val [regsub -all {[\(\)%]} [lindex $columnNames $j] "" stat]
                set ret_val [regsub -all {[\.\s-]} [string trim $stat] "_" stat]
                set statName [string tolower $stat]
                set value [lindex $stat_value_list $j]
                set [subst $keyed_array_name]($mode.$key.$statName) $value
                incr keyed_array_index
            }
        }
        
    }
    keylset returnList stat_count $keyed_array_index
    return $returnList
}

proc ::ixia::doDrillDownOperation {row_index view drill_down_option} {

    keylset returnList status $::SUCCESS
    set statViewRoot [ixNet getRoot]statistics
    
    ixNet setAttribute $view/drillDown -targetRowIndex $row_index
    ixNet setAttribute $view/drillDown -targetDrillDownOption $drill_down_option
            
    if {[catch {ixNet commit} err] || $err != "::ixNet::OK"} {
        keylset returnList status $::FAILURE
        keylset returnList log "Commit failed while doing drill down statistics for\
                '[ixNet getA $view -caption]'. $err"
        return $returnList
    }
    if {[catch {ixNet exec doDrillDown $view/drillDown} err] != 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Drill Down Failed: $err"
        return $returnList
    } else {
        set stat_view_map "Application Traffic Drill Down"
        set drill_down_view ""
        set statViewList [ixNet getList $statViewRoot view]
        foreach statView $statViewList {
            if {[ixNet getAttribute $statView -caption] == $stat_view_map} {
                set drill_down_view $statView
                break
            }
        }
        if {$drill_down_view == ""} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not find $stat_view_map view. Possible causes:\
                    traffic was not started or statistics collected too soon after traffic was started."
                    return $returnList
        }
        #Refresh Stats
        if {[catch {ixNet exec refresh $drill_down_view} err] != 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "Refreshing Drill Down view: $stat_view_map Failed: $err"
            return $returnList
        } else { \
            set statViewObjRef "${drill_down_view}/page"
       
            set retry_count 30
            set retry_status false
            for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
                after 1000
                if {[set retry_status [ixNet getAttribute $statViewObjRef -isReady]] == "true"} {
                    break
                }
            }
            if {$retry_status != "true"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Refreshing Drill Down view $stat_view_map failed:\
                        View is not ready after $retry_count seconds."
                return $returnList
            }
            after [expr [ixNet getAttribute $statViewRoot -pollInterval] * 1000 + 1000]
            
            if {[catch {ixNet getAttribute $statViewObjRef -totalPages} totalPages]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to get total number of pages for\
                        '[ixNet getA $drill_down_view -caption]' statistic view. $totalPages"
                return $returnList
            }
            
            if {$totalPages == 0} {
                set totalPages 1
            }
            set rowCount 0
            set rowValues {}
            for {set pageNumber 1} {$pageNumber <= $totalPages} {incr pageNumber} {        
                if {[catch {ixNet setAttribute $statViewObjRef -currentPage $pageNumber} err] || $err != "::ixNet::OK"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not change page number to $pageNumber for $statViewObjRef. $err"
                    return $returnList
                }
                
                if {([catch {ixNet commit} err] || $err != "::ixNet::OK")} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not commit change page number to $pageNumber for $statViewObjRef. Failed on commit. $err"
                    return $returnList
                }
                
                set retry_status false
                for {set retry_iteration 0} {$retry_iteration < $retry_count} {incr retry_iteration} {
                    after 1000
                    if {[set retry_status [ixNet getAttribute $statViewObjRef -isReady]] == "true"} {
                        break
                    }
                }
                if {$retry_status != "true"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Refreshing Drill Down view $stat_view_map failed:\
                            View is not ready after $retry_count seconds."
                    return $returnList
                }

                append rowValues [ixNet getAttribute $statViewObjRef -rowValues] " "
                set rowCount [expr $rowCount + [ixNet getAttribute $statViewObjRef -rowCount]]
            }

            keylset returnList drill_down_view $drill_down_view
            keylset returnList column_captions [ixNet getAttribute $statViewObjRef -columnCaptions]
            keylset returnList column_count [ixNet getAttribute $statViewObjRef -columnCount]
            keylset returnList row_values [string trimright $rowValues]
            keylset returnList row_count $rowCount
        }
    }
    return $returnList
}

