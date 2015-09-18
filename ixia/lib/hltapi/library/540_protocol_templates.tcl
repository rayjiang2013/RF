proc ::ixia::540protocolTemplates {args opt_args} {
    keylset returnList status $::FAILURE
    set to_strip "::ixNet::OBJ-/traffic/protocolTemplate:"
    if {[catch {::ixia::parse_dashed_args -args $args -optional_args $opt_args } errorMsg]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$errorMsg."
        return $returnList
    }
    array set truth_array {false 0 true 1}
    set field_values_list {
      field_activeFieldChoice   activeFieldChoice        none
      field_auto                auto                     none
      field_countValue          countValue               none
      field_defaultValue      	defaultValue             readonly
      field_displayName       	displayName              readonly
      field_enumValues        	enumValues               readonly
      field_fieldChoice       	fieldChoice              readonly
      field_fieldValue        	fieldValue               none
      field_fullMesh          	fullMesh                 none
      field_id                	id                       readonly
      field_length            	length                   readonly
      field_level             	level                    readonly
      field_name              	name                     readonly
      field_offset            	offset                   readonly
      field_offsetFromRoot    	offsetFromRoot           readonly
      field_optional          	optional                 readonly
      field_optionalEnabled   	optionalEnabled          none
      field_rateVaried        	rateVaried               readonly
      field_readOnly          	readOnly                 readonly
      field_requiresUdf       	requiresUdf              readonly
      field_singleValue       	singleValue              none
      field_startValue        	startValue               none
      field_stepValue         	stepValue                none
      field_trackingEnabled   	trackingEnabled          none
      field_valueFormat       	valueFormat              readonly
      field_valueList         	valueList                none
      field_valueType         	valueType                none
    }
    if {$mode == "get_available_fields" || $mode == "get_field_values" || $mode == "set_field_values"} {
        if {![regexp {(^::ixNet::OBJ-/traffic/trafficItem:\d+/highLevelStream:\d+/stack)|(^::ixNet::OBJ-/traffic/trafficItem:\d+/configElement:\d+/stack)} $header_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Invalid value '$header_handle' for parameter\
                    -header_handle when mode is $mode. It must be one of the following keys returned\
                    by procedure traffic_config: traffic_item.<trafficItem>.headers,\
                    traffic_item.<trafficItem>.<stream_id>.headers"
            return $returnList
        }
    }
    if {$mode == "add_field_level" || $mode == "remove_field_level"} {
        if {![info exists field_handle] || ![info exists header_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "::ixia::540protocolTemplates -> Both header_handle and field_handle must be provided for mode $mode."
            return $returnList
        }
        if { [llength $field_handle] > 1 } {
            keylset returnList log "The field handle is a list. Please use only one field per call."
            keylset returnList status $::FAILURE
            return $returnList
        }
    }
    switch -- $mode {
        "get_available_protocol_templates" {
            if {[catch {set pt_object_list [ixNet getList [ixNet getRoot]traffic protocolTemplate]}]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to get protocol templates. Try reconnecting to the IxNetwork server."
                keylset returnList pt_handle ""
                return $returnList
            }
            set pt_names [list]
            foreach pt_object $pt_object_list {
                set pt_name [string trim [string range $pt_object [string length $to_strip] end] "\""]
                set pt_name [regsub " " $pt_name "~"]
                lappend pt_names $pt_name
            }
            keylset returnList status $::SUCCESS
            keylset returnList pt_handle $pt_names
            return $returnList
        }
        "append_header" -
        "prepend_header" -
        "replace_header" {
            set stream_id $handle
            if {![regexp {(^::ixNet::OBJ-/traffic/trafficItem:\d+/highLevelStream:\d+/stack)|(^::ixNet::OBJ-/traffic/trafficItem:\d+/configElement:\d+/stack)} $stream_id]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid value '$stream_id' for parameter\
                        -stream_id when mode is $mode. It must be one of the following keys returned\
                        by procedure traffic_config: traffic_item.<trafficItem>.headers,\
                        traffic_item.<trafficItem>.<stream_id>.headers"
                return $returnList
            }
            if {$handle == "::ixNet::OBJ-null" || [ixNet exists $handle] == "false"} {
                keylset returnList status $::FAILURE
                keylset returnList log "Object $handle does not exist."
                return $returnList
            }
            if {[llength $pt_handle] > 1} {
                set pt_object_ref [list]
                foreach pt_process $pt_handle {
                    lappend pt_object_ref "${to_strip}\"[regsub "~" $pt_process " "]\""
                }
            } else {
                set pt_object_ref "${to_strip}\"[regsub "~" $pt_handle " "]\""
            }
            if {$mode == "append_header"} {
                set returned [::ixia::540IxNetAppendProtocolTemplate $pt_object_ref $stream_id]
            } elseif {$mode == "prepend_header"} {
                set returned [::ixia::540IxNetPrependProtocolTemplate $pt_object_ref $stream_id]
            } elseif {$mode == "replace_header"} {
                set returned [::ixia::540IxNetReplaceProtocolTemplate $pt_object_ref $stream_id]
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "The impossible just happened. This code is unreachable!"
                return $returnList
            }
            
            if {[keylget returned status] != $::SUCCESS} {
                return $returned
            }
            
            set ret_handle [keylget returned handle]
            
            set retCode [540IxNetTrafficGenerate $stream_id]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
            
            set returnList [::ixia::540IxNetTrafficReturnHandles $stream_id]
            if {[keylget returnList status] != $::SUCCESS} {
                return $returnList
            }
            
            keylset returnList handle $ret_handle
            
            # Return the stacks... good or bad.
            return $returnList
        }
        "get_available_fields" {
            set list_of_fields [ixNet getList $header_handle field]
            set friendly_list [list]
            foreach available_field $list_of_fields {
                set field_clean [string range $available_field [string last "\"" [string trim $available_field "\" "]] end]
                set field_clean [regsub " " [string trim $field_clean "\""] "~"]
                lappend friendly_list $field_clean
            }
            keylset returnList status $::SUCCESS
            keylset returnList handle $friendly_list
            return $returnList
        }
        "get_field_values" {
            set big_field_object "[regsub "\"" ${header_handle} "\\\""]/field:\\\"[regsub "~" $field_handle " "]\\\""
            keylset returnList status $::SUCCESS
            foreach {x_key x_attribute x_type} $field_values_list {
                if { [catch { set current_value [ixNet getAttribute $big_field_object -$x_attribute] } problems] } {
                    set current_value "N/A"
                    keylset returnList log "Could not get field $x_attribute."
                    keylset returnList status $::FAILURE
                    return $returnList
                }
                if {$current_value == "false" || $current_value == "true"} {
                    set current_value $truth_array($current_value)
                }
                keylset returnList $x_key $current_value
            }
            return $returnList
        }
        "set_field_values" {
            set big_field_object "[regsub "\"" ${header_handle} "\\\""]/field:\\\"[regsub "~" $field_handle " "]\\\""
            keylset returnList status $::SUCCESS
            set current_log ""
            foreach {x_key x_attribute x_type} $field_values_list {
                if {[info exists $x_key]} {
                    if { [ixNet setAttribute $big_field_object -$x_attribute [set $x_key]] != "::ixNet::OK" } {
                        keylset returnList log "Could not set $x_attribute on $big_field_object."
                        keylset returnList status $::FAILURE
                        return $returnList
                    }
                }
            }
            set commit_result [ixNet commit]
            if {$commit_result != "::ixNet::OK"} {
                keylset returnList log "::ixia::540protocolTemplates -> Error commiting field values."
                keylset returnList status $::FAILURE
                return $returnList
            }
            
            set retCode [540IxNetTrafficGenerate $header_handle]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
            
            return $returnList
        }
        "add_field_level" {
            set big_field_object "[regsub "\"" ${header_handle} "\\\""]/field:\\\"[regsub "~" $field_handle " "]\\\""
            keylset returnList status $::SUCCESS
            # Create a list of present levels...
            set all_fields_list   [ixNet getL $header_handle field]
            set level_fields_list [list]
            foreach all_field $all_fields_list {
                set marker_index [string first "groupRecords.groupRecord" $all_field]
                if {$marker_index < 0} {continue}
                lappend level_fields_list $all_field
            }
            # Add level...
            set exec_result [ixNet exec addLevel $big_field_object]
            if {$exec_result != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "::ixia::540protocolTemplates -> $exec_result"
                return $returnList
            }
            # Create a list of present levels... again!
            set all_fields_list   [ixNet getL $header_handle field]
            set new_level_fields_list [list]
            foreach all_field $all_fields_list {
                set marker_index [string first "groupRecords.groupRecord" $all_field]
                if {$marker_index < 0} {continue}
                lappend new_level_fields_list $all_field
            }
            # Get a list of new items only...
            foreach old_element $level_fields_list {
                set element_index [lsearch $new_level_fields_list $old_element]
                if {$element_index < 0} {continue}
                set new_level_fields_list [lreplace $new_level_fields_list $element_index $element_index]
            }
            
            set retCode [540IxNetTrafficGenerate $header_handle]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
            
            # Get all traffic handles on the current traffic item. They might have changed.
            set tritem [::ixia::ixNetworkGetParentObjref $header_handle trafficItem]
            set returnList [::ixia::540IxNetTrafficReturnHandles $tritem]
            # Load up new items...
            keylset returnList handle $new_level_fields_list
            return $returnList
        }
        "remove_field_level" {
            set big_field_object "[regsub "\"" ${header_handle} "\\\""]/field:\\\"[regsub "~" $field_handle " "]\\\""
            keylset returnList status $::SUCCESS
            set exec_result [ixNet exec removeLevel $big_field_object]
            if {$exec_result != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "::ixia::540protocolTemplates -> $exec_result"
                return $returnList
            }
            
            set retCode [540IxNetTrafficGenerate $header_handle]
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
            
            # Get all traffic handles on the current traffic item. They might have changed.
            set tritem [::ixia::ixNetworkGetParentObjref $header_handle trafficItem]
            set returnList [::ixia::540IxNetTrafficReturnHandles $tritem]
            return $returnList
        }
        default {
            return $returnList
        }
    }
}