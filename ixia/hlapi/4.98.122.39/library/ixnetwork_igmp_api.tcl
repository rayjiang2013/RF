proc ::ixia::ixnetwork_igmp_config { args man_args opt_args } {
    variable objectMaxCount
    variable truth
    variable igmp_attributes_array
    variable igmp_host_ip_handles_array
    variable multicast_group_ip_to_handle
    variable multicast_source_ip_to_handle
    variable multicast_group_array
    variable multicast_source_array

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    keylset returnList status $::SUCCESS
    
    array set translate_mode [list          \
            enable          true            \
            disable         false           \
            enable_all      true            \
            disable_all     false           \
            ]

    array set translate_igmp_version [list  \
            v1              igmpv1          \
            v2              igmpv2          \
            v3              igmpv3          \
            ]

    # Check to see if a connection to the IxNetwork TCL server already exists. 
    # If it doesn't, establish it.
    set return_status [checkIxNetwork]
    if {[keylget return_status status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to IxNetwork - \
                [keylget return_status log]"
        return $returnList
    }

    if {($mode == "delete") || ($mode == "enable") || ($mode == "disable")} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode,\
                    the -handle option must be used. Please set this value."
            return $returnList
        }

        if {$mode == "delete"} {
            foreach objref $handle {
                ixNet remove $objref
                
                # remove the internal keys for the deleted group members and sources
                foreach {gkey gvalue} [array get multicast_group_ip_to_handle] {
                    if {![string first $objref $gvalue]} {
                        # remove the sources from multicast_source_ip_to_handle array
                        foreach {skey svalue} [array get multicast_source_ip_to_handle] {
                            if {![string first $gvalue $svalue]} {
                                unset multicast_source_ip_to_handle($skey)
                                if {[regexp {^(\d+.\d+.\d+.\d+)/(\d+.\d+.\d+.\d+)/(\d+)$} $skey all src_addr]} {
                                    foreach {mskey msvalue} [array get multicast_source_array] {
                                        if {[regexp {([a-zA-z0-9]+),ip_addr_start} $mskey full_value found_source]} {
                                            if {$src_addr == $msvalue} {
                                                unset multicast_source_array($found_source,ip_addr_start)
                                                unset multicast_source_array($found_source,ip_addr_step)
                                                unset multicast_source_array($found_source,ip_prefix_len)
                                                unset multicast_source_array($found_source,num_sources)
                                            } else {
                                                continue
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        # remove the group ranges from multicast_group_ip_to_handle array
                        if {[regexp {^(\d+.\d+.\d+.\d+)/(\d+.\d+.\d+.\d+)/(\d+)$} $gkey all gr_addr]} {
                            foreach {mgkey mgvalue} [array get multicast_group_array] {
                                if {[regexp {([a-zA-z0-9]+),ip_addr_start} $mgkey full_value found_group]} {
                                    if {$gr_addr == $mgvalue} {
                                        set result [::ixia::igmp_array_operations multicast_group_array \
                                                remove $found_group]
                                        if {[keylget result status] == $::FAILURE} {
                                            keylset returnList log "Failure in ixnetwork_igmp_config:\
                                                    encountered an error while executing igmp_array_operations \
                                                    - [keylget result log]"
                                            keylset returnList status $::FAILURE
                                            return $returnList
                                        }
                                    } else {
                                        continue
                                    }
                                }
                            }
                        }
                        
                        set result [::ixia::igmp_array_operations multicast_group_ip_to_handle \
                                remove $gkey $objref]
                        if {[keylget result status] == $::FAILURE} {
                            keylset returnList log "Failure in ixnetwork_igmp_config:\
                                    encountered an error while executing igmp_array_operations \
                                    - [keylget result log]"
                            keylset returnList status $::FAILURE
                            return $returnList
                        }
                    }
                }
                foreach {index key_value} [array get igmp_host_ip_handles_array] {
                    if {[regexp $objref $key_value]} {
                        set result [::ixia::igmp_array_operations igmp_host_ip_handles_array \
                                remove $index]
                        if {[keylget result status] == $::FAILURE} {
                            keylset returnList log "Failure in ixnetwork_igmp_config:\
                                    encountered an error while executing igmp_array_operations \
                                    - [keylget result log]"
                            keylset returnList status $::FAILURE
                            return $returnList
                        }
                    }
                }
            }
        } else {
            foreach objref $handle {
                set result [ixNetworkNodeSetAttr $objref \
                        [subst {-enabled $translate_mode($mode)}]]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList log "Failure in ixnetwork_igmp_config:\
                            encountered an error while executing: \
                            ixNetworkNodeSetAttr $objref\
                            [subst {-enabled $translate_mode($mode)}]\
                            - [keylget result log]"
                    keylset returnList status $::FAILURE
                    return $returnList
                }
            }
        }
        # when mode modify is used (delete, enable, disable) the handle key must be returned
        keylset returnList handle $handle
        if {![info exists no_write]} {
            ixNet commit
        }
    }

    if {($mode == "enable_all") || ($mode == "disable_all")} {
        if {![info exists port_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode, the -port_handle\
                    option must be used. Please set this value."
            return $returnList
        }

        set handle_list [list]
        foreach port $port_handle {
            set result [ixNetworkGetPortObjref $port]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to find the port object\
                        reference associated to the $port port handle -\
                        [keylget result log]."
                return $returnList
            } else {
                set protocol_objref [keylget result vport_objref]/protocols/igmp
            }
    
            set host_list [ixNet getList $protocol_objref host]
            foreach host $host_list {
                set result [ixNetworkNodeSetAttr $host \
                        [subst {-enabled $translate_mode($mode)}]]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList log "Failure in ixnetwork_igmp_config:\
                            encountered an error while executing: \
                            ixNetworkNodeSetAttr $host\
                            [subst {-enabled $translate_mode($mode)}]]\
                            - [keylget result log]"
                    keylset returnList status $::FAILURE
                    return $returnList
                }        
            }
            set handle_list [concat $handle_list $host_list]
        }
        if {![info exists no_write]} {
            ixNet commit
        }

        keylset returnList handle $handle_list
    }

    if {$mode == "create"} {
        ## Add port
        if {[llength $port_handle]>1} {
            keylset returnList status $::FAILURE
            keylset returnList log "Please provide a single port_handle."
            return $returnList
        }
        set return_status [ixNetworkPortAdd $port_handle {} force]
        if {[keylget return_status status] != $::SUCCESS} {
            return $return_status
        }

        set result [ixNetworkGetPortObjref $port_handle]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to find the port object reference \
                    associated to the $port_handle port handle -\
                    [keylget result log]."
            return $returnList
        }
        set protocol_objref [keylget result vport_objref]/protocols/igmp
        
        # Check if protocols are supported
        set retCode [checkProtocols [keylget result vport_objref]]
        if {[keylget retCode status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Port $port_handle does not support protocol\
                    configuration."
            return $returnList
        }
        
        # Resetting everything makes sense only with -mode create
        if {[info exists reset]} {
            if {![info exists no_write]} {
                set result [ixNetworkNodeRemoveList $protocol_objref { {child remove host} {} } -commit]
            } else {
                set result [ixNetworkNodeRemoveList $protocol_objref { {child remove host} {} }]
            }
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not reset the IGMP protocol\
                        - [keylget result log]."
                return $returnList
            }
        }

        ## Protocol options
        # Start creating list of global IGMP options
        set igmp_protocol_args [list -enabled true -statsEnabled true \
                -sendLeaveOnStop true]
        
        # List of global options for IGMP
        set globalIgmpOptions {
            msg_count_per_interval  numberOfGroups
            msg_interval            timePeriod
        }

        # Check IGMP options existence and append parameters that exist
        foreach {hltOpt ixnOpt} $globalIgmpOptions {
            if {[info exists $hltOpt]} {
                lappend igmp_protocol_args -$ixnOpt [set $hltOpt]
            }
        }

        # Apply configurations
        if {![info exists no_write]} {
            set result [ixNetworkNodeSetAttr $protocol_objref $igmp_protocol_args -commit]
        } else {
            set result [ixNetworkNodeSetAttr $protocol_objref $igmp_protocol_args]
        }
        if {[keylget result status] == $::FAILURE} {
            keylset returnList log "Failure in ixnetwork_igmp_config:\
                    encountered an error while executing: \
                    ixNetworkNodeSetAttr $protocol_objref $igmp_protocol_args\
                    - [keylget result log]"
            keylset returnList status $::FAILURE
            return $returnList
        }

        ## Interfaces
        # Configure the necessary interfaces
        
        if {[info exists interface_handle]} {
            set tmp_interface_handle ""
            
            foreach single_intf_h $interface_handle {
                if {[llength [split $single_intf_h |]] > 1} {
                    # We're dealing with pppox ranges interfaces
                    foreach {sm_range intf_idx_group} [split $single_intf_h |] {}
                    
                    # Validate sm_range
                    if {![regexp {^::ixNet::OBJ-/vport:\d+/protocolStack/((ethernet)|(atm)):[^/]+/pppoxEndpoint:[^/]+/range:[^/]+$} $sm_range]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Invalid handle '$single_intf_h' for -interface_handle\
                                parameter. Expected handle returned by pppox_config procedure."
                        return $returnList
                    } else {
                        set intf_type "PPP"
                    }
                    
                    foreach single_intf_idx_group [split $intf_idx_group ,] {
                        switch -- [regexp -all {\-} $single_intf_idx_group] {
                            0 {
                                # It's a single index
                                if {![string is integer $single_intf_idx_group] || $single_intf_idx_group <= 0} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Invalid interface index $single_intf_idx_group\
                                            in interface_handle $single_intf_h. Accepted values are numeric\
                                            greater than 0."
                                    return $returnList
                                }
                                
                                lappend tmp_interface_handle "${sm_range}|${single_intf_idx_group}|${intf_type}"
                            }
                            1 {
                                # It's a range of indexes
                                foreach {range_start range_end} [split $single_intf_idx_group -] {}
                                
                                if {!([string is integer $range_start]) || !([string is integer $range_end]) ||\
                                        !($range_start <= $range_end) || !($range_start > 0)} {
                                    
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Invalid interface index range $single_intf_idx_group\
                                            in interface_handle $single_intf_h. Accepted values are numeric\
                                            greater than 0."
                                    return $returnList
                                }
                                
                                for {set i $range_start} {$i <= $range_end} {incr i} {
                                    lappend tmp_interface_handle "${sm_range}|${i}|${intf_type}"
                                }
                            }
                            default {
                                # It's not valid
                                keylset returnList status $::FAILURE
                                keylset returnList log "Invalid interface index range in $single_intf_h."
                                return $returnList
                            }
                        }
                    }
                    
                    catch {unset sm_range}
                    catch {unset intf_idx_group}
                    catch {unset single_intf_idx_group}
                } else {
                    # Validate protocol interface range
                    if {![regexp {^::ixNet::OBJ-/vport:\d+/interface:\d+$} $single_intf_h]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Invalid handle '$single_intf_h' for -interface_handle\
                                parameter. Expected handle returned by interface_config procedure."
                        return $returnList
                    } else {
                        set intf_type "ProtocolIntf"
                    }

                    lappend tmp_interface_handle "${single_intf_h}|dummy|${intf_type}"
                }
            }
            
            set interface_handle $tmp_interface_handle
            
            catch {unset tmp_interface_handle}
        }
        
        if {[info exists interface_handle] && [info exists count] && \
                [llength $interface_handle] != $count} {
            keylset returnList status $::FAILURE
            keylset returnList log "The -interface_handle list doesn't\
                    have the size specified with the -count argument."
            return $returnList
        } elseif {[info exists interface_handle]} {
            set intf_list [list]
            set no_ipv4 false
            foreach intf $interface_handle {
                foreach {intf_actual_handle intf_actual_idx intf_actual_type} [split $intf |] {}
                
                switch -- $intf_actual_type {
                    "ProtocolIntf" {
                        if {[llength [ixNet getList $intf_actual_handle ipv4]] > 0} {
                            lappend intf_list $intf
                        } else {
                            # intf_actual_handle is not a typo. We use this list only for logging the error
                            # message so we want it to be a simple list of interface handles
                            lappend no_ipv4_intf_list $intf_actual_handle
                            set no_ipv4 true
                        }
                    }
                    "PPP" {
                        set ret_code [ixNetworkEvalCmd [list ixNet getA ${intf_actual_handle}/pppoxRange -ncpType]]
                        if {[keylget ret_code status] != $::SUCCESS} {
                            return $ret_code
                        }
                        if {[keylget ret_code ret_val] == "IPv4"} {
                            lappend intf_list $intf
                        } else {
                            lappend no_ipv4_intf_list $intf_actual_handle
                            set no_ipv4 true
                        }
                    }
                    default {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Internal error. Unexpected interface handle type.\
                                Known interface handle types are: PPP and ProtocolIntf."
                        return $returnList
                    }
                }
            }
            if {$no_ipv4} {
                keylset returnList status $::FAILURE
                keylset returnList log "The following interfaces don't have\
                        IPv4 addresses configured: $no_ipv4_intf_list"
                return $returnList
            }
        } else {
            set protocol_intf_options "                                     \
                    -atm_encapsulation          atm_encapsulation           \
                    -atm_vci                    vci                         \
                    -atm_vci_step               vci_step                    \
                    -atm_vpi                    vpi                         \
                    -atm_vpi_step               vpi_step                    \
                    -count                      count                       \
                    -gateway_address            neighbor_intf_ip_addr       \
                    -gateway_address_step       neighbor_intf_ip_addr_step  \
                    -ipv4_address               intf_ip_addr                \
                    -ipv4_address_step          intf_ip_addr_step           \
                    -ipv4_prefix_length         intf_prefix_len             \
                    -loopback_count             0                           \
                    -mac_address                mac_address_init            \
                    -mac_address_step           mac_address_step            \
                    -override_existence_check   override_existence_check    \
                    -override_tracking          override_tracking           \
                    -port_handle                port_handle                 \
                    -vlan_enabled               vlan                        \
                    -vlan_id                    vlan_id                     \
                    -vlan_id_mode               vlan_id_mode                \
                    -vlan_id_step               vlan_id_step                \
                    -vlan_user_priority         vlan_user_priority          \
                    "

            # Passed in only those options that exists
            foreach {option value_name} $protocol_intf_options {
                if {[info exists $value_name]} {
                    append protocol_intf_args " $option [set $value_name]"
                }
            }

            # Create the necessary interfaces
            set intf_list [eval ixNetworkProtocolIntfCfg \
                    $protocol_intf_args]
            if {[keylget intf_list status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to create the\
                        protocol interfaces. [keylget intf_list log]"
                return $returnList
            }
            set intf_list [keylget intf_list connected_interfaces]
            set tmp_intf_list ""
            foreach tmp_intf $intf_list {
                lappend tmp_intf_list "${tmp_intf}|dummy|ProtocolIntf"
            }
            set intf_list $tmp_intf_list
            catch {unset tmp_intf}
            catch {unset tmp_intf_list}
        }

        ## Host options
        # Get the immediate response configuration
        if {![info exists max_response_control]} {
            set temp_control 0
        } else  {
            set temp_control $max_response_control
        }
        if {![info exists max_response_time]} {
            set temp_time ""
        } else  {
            set temp_time $max_response_time
        }
        set temp_switch "${temp_control}SEP${temp_time}"
        switch -regexp $temp_switch {
            {1SEP0}             { set immediate_response 1 }
            {1SEP([^0]+)\d*}    { set immediate_response 0 }
            {1SEP}              {  }
            {0SEP(.*)}          { set immediate_response 0 }
            {SEP}               {  }
        }

        # Start creating list of static IGMP router options
        set igmp_host_static_args [list -enabled true]

        # The -igmp_version attribute must not be modified
        if {$mode == "modify" && [info exists igmp_version]} {
            unset igmp_version
        }

        # List of static (non-incrementing) options for IGMP host
        set staticIgmpHostOptions {
            general_query               gqResponseMode          truth
            group_query                 sqResponseMode          truth
            igmp_version                version                 translate
            immediate_response          respToQueryImmediately  truth
            ip_router_alert             routerAlert             truth
            suppress_report             suppressReports         truth
        }
        
        # Check IGMP host options existence and append parameters that exist
        foreach {hltOpt ixnOpt optType} $staticIgmpHostOptions {
            if {[info exists $hltOpt]} {
                switch $optType {
                    translate {
                        lappend igmp_host_static_args -$ixnOpt \
                                [set translate_${hltOpt}([set $hltOpt])]
                    }
                    truth {
                        lappend igmp_host_static_args -$ixnOpt \
                                $truth([set $hltOpt])
                    }
                }
            }
        }

        # Particular static (non-incrementing) options for IGMP host
        if {[info exists unsolicited_report_interval]} {
            lappend igmp_host_static_args -upResponseMode true
            lappend igmp_host_static_args -reportFreq \
                    $unsolicited_report_interval
        } else {
            lappend igmp_host_static_args -upResponseMode false
        }

        set ixn_version [join [lrange [split [ixNet getAttribute [ixNet getRoot]globals -buildNumber] .] 0 1] .]
        
        ## Host(s) creation
        set objectCount    0
        foreach intf_objref $intf_list {
            set igmp_host_args $igmp_host_static_args
            
            foreach {intf_objref intf_objref_index intf_objref_type} [split $intf_objref |] {}
            
            switch -- $intf_objref_type {
                "ProtocolIntf" {
                    if {$ixn_version >= 5.50} {
                        lappend igmp_host_args -interfaceType "Protocol Interface"
                        lappend igmp_host_args -interfaces    $intf_objref
                    } else {
                        lappend igmp_host_args -interfaceId   $intf_objref
                    }
                }
                "PPP" {
                    if {$ixn_version < 5.50} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Internal error. Unexpected interface handle type.\
                                Interface handle type PPP is only supported starting with IxNetwork 5.50."
                        return $returnList
                    }
                    lappend igmp_host_args -interfaces     $intf_objref
                    lappend igmp_host_args -interfaceType  $intf_objref_type
                    lappend igmp_host_args -interfaceIndex $intf_objref_index
                }
                default {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Internal error. Unexpected interface handle type.\
                            Known interface handle types are: PPP and ProtocolIntf."
                    return $returnList
                }
            }
            # Create host
            set result [ixNetworkNodeAdd $protocol_objref host \
                    $igmp_host_args]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not add a new host to the\
                        following protocol object reference: $protocol_objref -\
                        [keylget result log]."
                return $returnList
            }
            set host_objref [keylget result node_objref]
            lappend igmp_host_list $host_objref

            # Add to array the attributes to be passed to the
            # ::ixia::ixnetwork_igmp_group_config procedure
            set remote_args_list [list      \
                    enable_packing          \
                    filter_mode             \
                    max_groups_per_pkts     \
                    max_sources_per_group   \
                    ]

            foreach arg $remote_args_list {
                if {[info exists $arg]} {
                    set igmp_attributes_array($host_objref,$arg) [set $arg]
                }
            }
            
            # Commit
            incr objectCount
            if {[expr $objectCount % $objectMaxCount] == 0 && ![info exists no_write]} {
                ixNet commit
            }
        }

        # Done
        if {[expr $objectCount % $objectMaxCount] != 0} {
            if {[catch {ixNetworkCommit} error_msg]} {
                keylset returnList log "Encountered an error while commiting changes.\
                        Please verify the igmp host input parameters and make sure that the protocol \
                        interface handle is not used on a different igmp host. Error message: $error_msg. "
                keylset returnList status $::FAILURE
                return $returnList
            }
        }

        # Update the array containing the attributes to be passed to the
        # ::ixia::ixnetwork_igmp_group_config procedure and create
        # the returned value
        set igmp_attributes_list [array get igmp_attributes_array]
        foreach igmp_host $igmp_host_list {
            set old_igmp_host $igmp_host
            set new_igmp_host [ixNet remapIds $igmp_host]
            regsub -all $old_igmp_host $igmp_attributes_list \
                    $new_igmp_host igmp_attributes_list
            lappend new_igmp_host_list $new_igmp_host
        }

        if {[info exists igmp_attributes_array]} {
            unset igmp_attributes_array
        }
        array set igmp_attributes_array $igmp_attributes_list
        
        # create the ::ixia::igmp_host_ip_handles_array used by other procedures
        # like ::ixia::emulation_igmp_group_config
        foreach host_objref $new_igmp_host_list {
            set host_interface_id [ixNet getA $host_objref -interfaces]
            if {$host_interface_id != [ixNet getNull]} {
                if {$intf_objref_type=="ProtocolIntf"} {
                    set host_interface_ip [ixNet getA "::ixNet::OBJ-/${host_interface_id}/ipv4" -ip]
                }
                if {[info exists host_interface_ip] && ![info exists igmp_host_ip_handles_array($host_interface_ip)]} {
                    set igmp_host_ip_handles_array($host_interface_ip) $host_objref
                }
            }
        }
        
        keylset returnList handle $new_igmp_host_list
    }

    if {$mode == "modify"} {
        # Remove defaults
        removeDefaultOptionVars $opt_args $args

        ## Port check
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode,\
                    the -handle option must be used. Please set this value."
            return $returnList
        }

        set index 0
        foreach objref $handle {
            set found [regexp {(.*igmp)/host:\d+} $objref {} protocol_objref]
            if {!$found} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to get the IGMP protocol\
                        object reference out of the handle received as\
                        input: $objref"
                return $returnList
            }
    
            ## Protocol options
            # Start creating list of global IGMP options
            set igmp_protocol_args [list -enabled true -statsEnabled true \
                    -sendLeaveOnStop true]
            
            # List of global options for IGMP
            set globalIgmpOptions {
                msg_count_per_interval  numberOfGroups
                msg_interval            timePeriod
            }
    
            # Check IGMP options existence and append parameters that exist
            foreach {hltOpt ixnOpt} $globalIgmpOptions {
                if {[info exists $hltOpt]} {
                    if {[lindex [set $hltOpt] $index] != {}} {
                        lappend igmp_protocol_args -$ixnOpt [lindex [set $hltOpt] $index]
                    } else {
                        lappend igmp_protocol_args -$ixnOpt [lindex [set $hltOpt] end]
                    }
                }
            }
    
            # Apply configurations
            if {![info exists no_write]} {
                set result [ixNetworkNodeSetAttr $protocol_objref $igmp_protocol_args -commit]
            } else {
                set result [ixNetworkNodeSetAttr $protocol_objref $igmp_protocol_args ]
            }
            if {[keylget result status] == $::FAILURE} {
                keylset returnList log "Failure in ixnetwork_igmp_config:\
                        encountered an error while executing: \
                        ixNetworkNodeSetAttr $protocol_objref $igmp_protocol_args\
                        - [keylget result log]"
                keylset returnList status $::FAILURE
                return $returnList
            }
    
            ## Interfaces
            if {[catch {ixNet getAttribute $objref -interfaces} intf_objref]} {
                set intf_objref [ixNet getAttribute $objref -interfaces]
            }
            
            if {[regexp {^::ixNet::OBJ-/vport:\d+/interface:\d+$} $intf_objref]} {
                
                # Modify only if it's a protocol interface
                
                set intf_type [ixNet getAttribute $intf_objref -type]
                if {![regexp {^(.*)/interface:\d+$} $intf_objref {} port_objref]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The the port object reference could not\
                            be determined from the '$intf_objref' interface object\
                            reference."
                    return $returnList
                } else {
                    set port_handle [ixNetworkGetRouterPort $port_objref]
                }
        
                set protocol_intf_options ""
                switch -- $intf_type {
                    default {
                        set protocol_intf_options "                             \
                                -atm_encapsulation      atm_encapsulation       \
                                -atm_vci                vci                     \
                                -atm_vpi                vpi                     \
                                -gateway_address        neighbor_intf_ip_addr   \
                                -ipv4_address           intf_ip_addr            \
                                -ipv4_prefix_length     intf_prefix_len         \
                                -mac_address            mac_address_init        \
                                -port_handle            port_handle             \
                                -prot_intf_objref       intf_objref             \
                                -vlan_enabled           vlan                    \
                                -vlan_id                vlan_id                 \
                                -vlan_user_priority     vlan_user_priority      \
                                "
                    }
                }
    
                # Passed in only those options that exists
                set protocol_intf_args ""
                foreach {option value_name} $protocol_intf_options {
                    if {[info exists $value_name]} {
                        if {[lindex [set $value_name] $index] != {}} {
                            append protocol_intf_args " $option [lindex [set $value_name] $index]"
                        } else {
                            append protocol_intf_args " $option [lindex [set $value_name] end]"
                        }
                    }
                }
        
                # (Re)configure interfaces
                if {[llength $protocol_intf_args] > 0} {
                    set intf_list ""
                    # BUG1131529 - if igmp host is created with -mode create and -override_tracking 1
                    # pa_inth_idx will not contain the protocol interface
                    append protocol_intf_args " -override_tracking 1"
                    switch -- $intf_type {
                        default {
                            set intf_list [eval ixNetworkConnectedIntfCfg \
                                    $protocol_intf_args]
                        }
                    }
        
                    if {[keylget intf_list status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to modify the IPv4\
                                configuration from the $intf_objref interface -\
                                [keylget intf_list log]."
                        return $returnList
                    }
                    if {![info exists no_write] && [catch {ixNet commit} err_msg]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to commit the IPv4\
                            configuration modifications from the $intf_objref\
                            interface - $err_msg."
                        return $returnList
                    }
                }
                if {[info exists intf_ip_addr]} {
                    set igmp_array [array get igmp_host_ip_handles_array]
                    foreach {ip value} $igmp_array {
                        if {$value == $objref} {
                            unset igmp_host_ip_handles_array($ip)
                            if {[lindex $intf_ip_addr $index] != {}} {
                                set igmp_host_ip_handles_array([lindex $intf_ip_addr $index]) $value
                            } else {
                                set igmp_host_ip_handles_array([lindex $intf_ip_addr end]) $value
                            }
                        }
                    }
                }
            }
            
            ## Host options
            # Get the immediate response configuration
            if {![info exists max_response_control]} {
                set temp_control 0
            } else  {
                set temp_control $max_response_control
            }
            if {![info exists max_response_time]} {
                set temp_time ""
            } else  {
                set temp_time $max_response_time
            }
            set temp_switch "${temp_control}SEP${temp_time}"
            switch -regexp $temp_switch {
                {1SEP0}             { set immediate_response 1 }
                {1SEP([^0]+)\d*}    { set immediate_response 0 }
                {1SEP}              {  }
                {0SEP(.*)}          { set immediate_response 0 }
                {SEP}               {  }
            }
    
            # Start creating list of static IGMP router options
            set igmp_host_static_args [list -enabled true]
    
            # The -igmp_version attribute must not be modified
            if {$mode == "modify" && [info exists igmp_version]} {
                unset igmp_version
            }
    
            # List of static (non-incrementing) options for IGMP host
            set staticIgmpHostOptions {
                general_query               gqResponseMode          truth
                group_query                 sqResponseMode          truth
                igmp_version                version                 translate
                immediate_response          respToQueryImmediately  truth
                ip_router_alert             routerAlert             truth
                suppress_report             suppressReports         truth
            }

            # Check IGMP host options existence and append parameters that exist
            foreach {hltOpt ixnOpt optType} $staticIgmpHostOptions {
                if {[info exists $hltOpt]} {
                    if {[lindex [set $hltOpt] $index] != {}} {
                        switch $optType {
                            translate {
                                lappend igmp_host_static_args -$ixnOpt \
                                        $translate_${hltOpt}([set \
                                        [lindex [set $hltOpt] $index]])
                            }
                            truth {
                                lappend igmp_host_static_args -$ixnOpt \
                                        $truth([lindex [set $hltOpt] $index])
                            }
                        }
                    } else {
                        switch $optType {
                            translate {
                                lappend igmp_host_static_args -$ixnOpt \
                                        $translate_${hltOpt}([set \
                                        [lindex [set $hltOpt] end]])
                            }
                            truth {
                                lappend igmp_host_static_args -$ixnOpt \
                                        $truth([lindex [set $hltOpt] end])
                            }
                        }
                    }
                }
            }

            # Particular static (non-incrementing) options for IGMP host
            if {[info exists unsolicited_report_interval]} {
                lappend igmp_host_static_args -upResponseMode true
                if {[llength $unsolicited_report_interval]>1} {
                    lappend igmp_host_static_args -reportFreq [lindex $unsolicited_report_interval $index]
                } else {
                    lappend igmp_host_static_args -reportFreq $unsolicited_report_interval
                }
            }
    
            ## Host(s) modification
            # Apply modified configurations
            if {![info exists no_write]} {
                set result [ixNetworkNodeSetAttr $objref $igmp_host_static_args -commit]
            } else {
                set result [ixNetworkNodeSetAttr $objref $igmp_host_static_args ]
            }
            if {[keylget result status] == $::FAILURE} {
                keylset returnList log "Failure in ixnetwork_igmp_config:\
                        encountered an error while executing: \
                        ixNetworkNodeSetAttr $objref $igmp_host_static_args\
                        - [keylget result log]"
                keylset returnList status $::FAILURE
                return $returnList
            }
    
            # Add to array the attributes to be passed to the
            # ::ixia::ixnetwork_igmp_group_config procedure
            set remote_args_list [list      \
                    enable_packing          \
                    filter_mode             \
                    max_groups_per_pkts     \
                    max_sources_per_group   \
                    ]
    
            # Array of group attributes
            array set group_attributes [list                    \
                    enable_packing          enablePacking       \
                    filter_mode             sourceMode          \
                    max_groups_per_pkts     recordsPerFrame     \
                    max_sources_per_group   sourcesPerRecord    \
                    ]
    
            # List of IGMP group options
            set igmp_group_attr [list]
    
            # Check IGMP group options existence and append parameters that exist
            foreach arg $remote_args_list {
                if {[info exists $arg]} {
                    if {[lindex [set $arg] $index] != {}} {
                        set igmp_attributes_array($objref,$arg) [lindex [set $arg] $index]
                        lappend igmp_group_attr -$group_attributes($arg) [lindex [set $arg] $index]
                    } else {
                        set igmp_attributes_array($objref,$arg) [lindex [set $arg] end]
                        lappend igmp_group_attr -$group_attributes($arg) [lindex [set $arg] end]
                    }
                }
            }
    
            # Update existing groups
            set group_list [ixNetworkNodeGetList $objref group -all]
            if {$group_list != [ixNet getNull]} {
                foreach group_objref $group_list {
                    set result [ixNetworkNodeSetAttr $group_objref \
                            $igmp_group_attr]
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList log "Failure in\
                                ixnetwork_igmp_config: encountered an error\
                                while executing: ixNetworkNodeSetAttr\
                                $group_objref $igmp_group_attr\
                                - [keylget result log]"
                        keylset returnList status $::FAILURE
                        return $returnList
                    }
                }
                if {![info exists no_write] && [catch {ixNet commit} err_msg]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to commit the\
                        modifications for the groups of the $objref\
                        host - $err_msg."
                    return $returnList
                }
            }

            incr index
        }

        keylset returnList handle $handle
    }

    return $returnList
}

proc ::ixia::ixnetwork_igmp_querier_config { args man_args opt_args } {
    variable objectMaxCount
    variable truth

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    keylset returnList status $::SUCCESS
    
    array set translate_mode [list          \
            enable          true            \
            disable         false           \
            enable_all      true            \
            disable_all     false           \
            ]

    array set translate_igmp_version [list  \
            v1              igmpv1          \
            v2              igmpv2          \
            v3              igmpv3          \
            ]

    # Check to see if a connection to the IxNetwork TCL server already exists. 
    # If it doesn't, establish it.
    set return_status [checkIxNetwork]
    if {[keylget return_status status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to IxNetwork - \
                [keylget return_status log]"
        return $returnList
    }

    if {($mode == "delete") || ($mode == "enable") || ($mode == "disable")} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode,\
                    the -handle option must be used. Please set this value."
            return $returnList
        }

        if {$mode == "delete"} {
            foreach objref $handle {
                ixNet remove $objref
            }
        } else {
            foreach objref $handle {
                set result [ixNetworkNodeSetAttr $objref \
                        [subst {-enabled $translate_mode($mode)}]]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList log "Failure in\
                            ixnetwork_igmp_querier_config: encountered an error\
                            while executing: ixNetworkNodeSetAttr $objref\
                            [subst {-enabled $translate_mode($mode)}]\
                            - [keylget result log]"
                    keylset returnList status $::FAILURE
                    return $returnList
                }
            }
        }
        # when mode modify is used (delete, enable, disable) 
        # the handle key must be returned
        keylset returnList handle $handle
        if {![info exists no_write]} {
            ixNet commit
        }
    }

    if {$mode == "create"} {
        ## Add port
        set return_status [ixNetworkPortAdd $port_handle {} force]
        if {[keylget return_status status] != $::SUCCESS} {
            return $return_status
        }

        set result [ixNetworkGetPortObjref $port_handle]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to find the port object reference \
                    associated to the $port_handle port handle -\
                    [keylget result log]."
            return $returnList
        }
        set protocol_objref [keylget result vport_objref]/protocols/igmp
        
        # Check if protocols are supported
        set retCode [checkProtocols [keylget result vport_objref]]
        if {[keylget retCode status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Port $port_handle does not support protocol\
                    configuration."
            return $returnList
        }
        
        # Resetting everything makes sense only with -mode create
        if {[info exists reset]} {
            if {![info exists no_write]} {
                set result [ixNetworkNodeRemoveList $protocol_objref { \
                        {child remove querier} {} } -commit]
            } else {
                set result [ixNetworkNodeRemoveList $protocol_objref { \
                        {child remove querier} {} }]
            }
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not reset the IGMP protocol\
                        - [keylget result log]."
                return $returnList
            }
        }

        ## Protocol options
        # Start creating list of global IGMP options
        set igmp_protocol_args [list -enabled true -statsEnabled true \
                -sendLeaveOnStop true]

        # List of global options for IGMP
        set globalIgmpOptions {
            msg_count_per_interval  numberOfQueries
            msg_interval            queryTimePeriod
        }

        # Check IGMP options existence and append parameters that exist
        foreach {hltOpt ixnOpt} $globalIgmpOptions {
            if {[info exists $hltOpt]} {
                lappend igmp_protocol_args -$ixnOpt [set $hltOpt]
            }
        }

        # Apply configurations
        if {![info exists no_write]} {
            set result [ixNetworkNodeSetAttr $protocol_objref $igmp_protocol_args -commit]
        } else {
            set result [ixNetworkNodeSetAttr $protocol_objref $igmp_protocol_args]
        }
        if {[keylget result status] == $::FAILURE} {
            keylset returnList log "Failure in ixnetwork_igmp_querier_config:\
                    encountered an error while executing: \
                    ixNetworkNodeSetAttr $protocol_objref $igmp_protocol_args\
                    - [keylget result log]"
            keylset returnList status $::FAILURE
            return $returnList
        }

        ## Interfaces
        # Configure the necessary interfaces
        
        if {[info exists interface_handle]} {
            set tmp_interface_handle ""
            
            foreach single_intf_h $interface_handle {
                if {[llength [split $single_intf_h |]] > 1} {
                    # We're dealing with pppox ranges interfaces
                    foreach {sm_range intf_idx_group} [split $single_intf_h |] {}
                    
                    # Validate sm_range
                    if {![regexp {^::ixNet::OBJ-/vport:\d+/protocolStack/((ethernet)|(atm)):[^/]+/pppoxEndpoint:[^/]+/range:[^/]+$} $sm_range]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Invalid handle '$single_intf_h' for -interface_handle\
                                parameter. Expected handle returned by pppox_config procedure."
                        return $returnList
                    } else {
                        set intf_type "PPP"
                    }
                    
                    foreach single_intf_idx_group [split $intf_idx_group ,] {
                        switch -- [regexp -all {\-} $single_intf_idx_group] {
                            0 {
                                # It's a single index
                                if {![string is integer $single_intf_idx_group] || $single_intf_idx_group <= 0} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Invalid interface index $single_intf_idx_group\
                                            in interface_handle $single_intf_h. Accepted values are numeric\
                                            greater than 0."
                                    return $returnList
                                }
                                
                                lappend tmp_interface_handle "${sm_range}|${single_intf_idx_group}|${intf_type}"
                            }
                            1 {
                                # It's a range of indexes
                                foreach {range_start range_end} [split $single_intf_idx_group -] {}
                                
                                if {!([string is integer $range_start]) || !([string is integer $range_end]) ||\
                                        !($range_start <= $range_end) || !($range_start > 0)} {
                                    
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Invalid interface index range $single_intf_idx_group\
                                            in interface_handle $single_intf_h. Accepted values are numeric\
                                            greater than 0."
                                    return $returnList
                                }
                                
                                for {set i $range_start} {$i <= $range_end} {incr i} {
                                    lappend tmp_interface_handle "${sm_range}|${i}|${intf_type}"
                                }
                            }
                            default {
                                # It's not valid
                                keylset returnList status $::FAILURE
                                keylset returnList log "Invalid interface index range in $single_intf_h."
                                return $returnList
                            }
                        }
                    }
                    
                    catch {unset sm_range}
                    catch {unset intf_idx_group}
                    catch {unset single_intf_idx_group}
                } else {
                    # Validate protocol interface range
                    if {![regexp {^::ixNet::OBJ-/vport:\d+/interface:\d+$} $single_intf_h]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Invalid handle '$single_intf_h' for -interface_handle\
                                parameter. Expected handle returned by interface_config procedure."
                        return $returnList
                    } else {
                        set intf_type "ProtocolIntf"
                    }

                    lappend tmp_interface_handle "${single_intf_h}|dummy|${intf_type}"
                }
            }
            
            set interface_handle $tmp_interface_handle
            
            catch {unset tmp_interface_handle}
        }
        
        if {[info exists interface_handle] && [info exists count] && \
                [llength $interface_handle] != $count} {
            keylset returnList status $::FAILURE
            keylset returnList log "The -interface_handle list doesn't\
                    have the size specified with the -count argument."
            return $returnList
        } elseif {[info exists interface_handle]} {
            set intf_list [list]
            set no_ipv4 false
            foreach intf $interface_handle {
                foreach {intf_actual_handle intf_actual_idx intf_actual_type} [split $intf |] {}
                
                switch -- $intf_actual_type {
                    "ProtocolIntf" {
                        if {[llength [ixNet getList $intf_actual_handle ipv4]] > 0} {
                            lappend intf_list $intf
                        } else {
                            # intf_actual_handle is not a typo. We use this list only for logging the error
                            # message so we want it to be a simple list of interface handles
                            lappend no_ipv4_intf_list $intf_actual_handle
                            set no_ipv4 true
                        }
                    }
                    "PPP" {
                        set ret_code [ixNetworkEvalCmd [list ixNet getA ${intf_actual_handle}/pppoxRange -ncpType]]
                        if {[keylget ret_code status] != $::SUCCESS} {
                            return $ret_code
                        }
                        if {[keylget ret_code ret_val] == "IPv4"} {
                            lappend intf_list $intf
                        } else {
                            lappend no_ipv4_intf_list $intf_actual_handle
                            set no_ipv4 true
                        }
                    }
                    default {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Internal error. Unexpected interface handle type.\
                                Known interface handle types are: PPP and ProtocolIntf."
                        return $returnList
                    }
                }
            }
            if {$no_ipv4} {
                keylset returnList status $::FAILURE
                keylset returnList log "The following interfaces don't have\
                        IPv4 addresses configured: $no_ipv4_intf_list"
                return $returnList
            }
        } else {
            set protocol_intf_options "                                     \
                    -atm_encapsulation          atm_encapsulation           \
                    -atm_vci                    vci                         \
                    -atm_vci_step               vci_step                    \
                    -atm_vpi                    vpi                         \
                    -atm_vpi_step               vpi_step                    \
                    -count                      count                       \
                    -gateway_address            neighbor_intf_ip_addr       \
                    -gateway_address_step       neighbor_intf_ip_addr_step  \
                    -ipv4_address               intf_ip_addr                \
                    -ipv4_address_step          intf_ip_addr_step           \
                    -ipv4_prefix_length         intf_prefix_len             \
                    -loopback_count             0                           \
                    -mac_address                mac_address_init            \
                    -mac_address_step           mac_address_step            \
                    -override_existence_check   override_existence_check    \
                    -override_tracking          override_tracking           \
                    -port_handle                port_handle                 \
                    -vlan_enabled               vlan                        \
                    -vlan_id                    vlan_id                     \
                    -vlan_id_mode               vlan_id_mode                \
                    -vlan_id_step               vlan_id_step                \
                    -vlan_user_priority         vlan_user_priority          \
                    "

            # Passed in only those options that exists
            foreach {option value_name} $protocol_intf_options {
                if {[info exists $value_name]} {
                    append protocol_intf_args " $option [set $value_name]"
                }
            }

            # Create the necessary interfaces
            set intf_list [eval ixNetworkProtocolIntfCfg \
                    $protocol_intf_args]
            if {[keylget intf_list status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to create the\
                        protocol interfaces. [keylget intf_list log]"
                return $returnList
            }
            set intf_list [keylget intf_list connected_interfaces]
            set tmp_intf_list ""
            foreach tmp_intf $intf_list {
                lappend tmp_intf_list "${tmp_intf}|dummy|ProtocolIntf"
            }
            set intf_list $tmp_intf_list
            catch {unset tmp_intf}
            catch {unset tmp_intf_list}
        }

        # Start creating list of static IGMP router options
        set igmp_querier_static_args [list -enabled true]

        # List of static options for IGMP querier
        set staticIgmpQuerierOptions {
            igmp_version                      version                     translate
            ip_router_alert                   routerAlert                 truth
            discard_learned_info              discardLearnedInfo          truth
            support_election                  supportElection             truth
            robustness_variable               robustnessVariable          int
            query_interval                    generalQueryInterval        int
            general_query_response_interval   gqResponseInterval          int
            startup_query_count               startupQueryCount           int
        }
        
        # Below options are not valid for IGMP version 1
        if {![info exists igmp_version]} {
            keylset returnList log "Failure in ixnetwork_igmp_querier_config:\
                    igmp_version argument is mandatory for -mode create"
            keylset returnList status $::FAILURE
            return $returnList
        } elseif {$igmp_version != "v1"} {
            # specific_query_response_interval and specific_query_transmission_count
            # are only valid if discard_learned_info is not enabled
            if {[info exists discard_learned_info] && (! $discard_learned_info)} {
                set staticIgmpQuerierOptions "$staticIgmpQuerierOptions
                    specific_query_response_interval    sqResponseInterval     int 
                    specific_query_transmission_count   sqTransmissionCount    int
                "
            }
            set staticIgmpQuerierOptions "$staticIgmpQuerierOptions    
                support_older_version_host        supportOlderVersionHost     truth
            "
            # support_older_version_querier is only valid when support_election 
            # is enabled
            if {[info exists support_election] && $support_election} {
                set staticIgmpQuerierOptions "$staticIgmpQuerierOptions    
                    support_older_version_querier  supportOlderVersionQuerier  truth 
                "
            }
        }
        # Check IGMP querier options existence and append parameters that exist
        foreach {hltOpt ixnOpt optType} $staticIgmpQuerierOptions {
            if {[info exists $hltOpt]} {
                switch $optType {
                    translate {
                        lappend igmp_querier_static_args -$ixnOpt \
                                [set translate_${hltOpt}([set $hltOpt])]
                    }
                    truth {
                        lappend igmp_querier_static_args -$ixnOpt \
                                $truth([set $hltOpt])
                    }
                    int {
                        lappend igmp_querier_static_args -$ixnOpt [set $hltOpt]
                    }
                }
            }
        }
        
        set ixn_version [join [lrange [split [ixNet getAttribute [ixNet getRoot]globals -buildNumber] .] 0 1] .]
        
        ## Querier(s) creation
        set objectCount    0
        foreach intf_objref $intf_list {
            set staticIgmpQuerierOptions $igmp_querier_static_args
            
            foreach {intf_objref intf_objref_index intf_objref_type} [split $intf_objref |] {}
            
            switch -- $intf_objref_type {
                "ProtocolIntf" {
                    if {$ixn_version >= 5.50} {
                        lappend staticIgmpQuerierOptions -interfaceType "Protocol Interface"
                        lappend staticIgmpQuerierOptions -interfaces    $intf_objref
                    } else {
                        lappend staticIgmpQuerierOptions -interfaceId   $intf_objref
                    }
                }
                "PPP" {
                    if {$ixn_version < 5.50} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Internal error. Unexpected interface handle type.\
                                Interface handle type PPP is only supported starting with IxNetwork 5.50."
                        return $returnList
                    }
                    lappend staticIgmpQuerierOptions -interfaces     $intf_objref
                    lappend staticIgmpQuerierOptions -interfaceType  $intf_objref_type
                    lappend staticIgmpQuerierOptions -interfaceIndex $intf_objref_index
                }
                default {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Internal error. Unexpected interface handle type.\
                            Known interface handle types are: PPP and ProtocolIntf."
                    return $returnList
                }
            }
            # Create querier
            set result [ixNetworkNodeAdd $protocol_objref querier \
                    $staticIgmpQuerierOptions]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not add a new querier to the\
                        following protocol object reference: $protocol_objref -\
                        [keylget result log]."
                return $returnList
            }
            set querier_objref [keylget result node_objref]
            lappend igmp_querier_list $querier_objref
            # Commit
            incr objectCount
            if {[expr $objectCount % $objectMaxCount] == 0 && ![info exists no_write]} {
                ixNet commit
            }
        }

        # Done
        if {[expr $objectCount % $objectMaxCount] != 0} {
            ixNet commit
        }
        foreach local_id $igmp_querier_list {
            lappend new_igmp_querier_list [ixNet remapIds $local_id]
        }
       
        keylset returnList handle $new_igmp_querier_list
    }

    if {$mode == "modify"} {
        # Remove defaults
        removeDefaultOptionVars $opt_args $args

        ## Port check
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode,\
                    the -handle option must be used. Please set this value."
            return $returnList
        }

        set index 0
        foreach objref $handle {
            set found [regexp {(.*igmp)/querier:\d+} $objref {} protocol_objref]
            if {!$found} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to get the IGMP protocol\
                        object reference out of the handle received as\
                        input: $objref"
                return $returnList
            }
            
        ## Protocol options
        # Start creating list of global IGMP options
        set igmp_protocol_args [list -enabled true -statsEnabled true \
                -sendLeaveOnStop true]

        # List of global options for IGMP
        set globalIgmpOptions {
            msg_count_per_interval  numberOfQueries
            msg_interval            queryTimePeriod
        }

        # Check IGMP options existence and append parameters that exist
        foreach {hltOpt ixnOpt} $globalIgmpOptions {
            if {[info exists $hltOpt]} {
                lappend igmp_protocol_args -$ixnOpt [set $hltOpt]
            }
        }

        # Apply configurations
        if {![info exists no_write]} {
            set result [ixNetworkNodeSetAttr $protocol_objref $igmp_protocol_args -commit]
        } else {
            set result [ixNetworkNodeSetAttr $protocol_objref $igmp_protocol_args]
        }
        if {[keylget result status] == $::FAILURE} {
            keylset returnList log "Failure in ixnetwork_igmp_querier_config:\
                    encountered an error while executing: \
                    ixNetworkNodeSetAttr $protocol_objref $igmp_protocol_args\
                    - [keylget result log]"
            keylset returnList status $::FAILURE
            return $returnList
        }

        ## Interfaces
            if {[catch {ixNet getAttribute $objref -interfaces} intf_objref]} {
                set intf_objref [ixNet getAttribute $objref -interfaces]
            }
            
            if {[regexp {^::ixNet::OBJ-/vport:\d+/interface:\d+$} $intf_objref]} {
                # Modify only if it's a protocol interface
                set intf_type [ixNet getAttribute $intf_objref -type]
                if {![regexp {^(.*)/interface:\d+$} $intf_objref {} port_objref]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The the port object reference could not\
                            be determined from the '$intf_objref' interface object\
                            reference."
                    return $returnList
                } else {
                    set port_handle [ixNetworkGetRouterPort $port_objref]
                }
        
                set protocol_intf_options ""
                switch -- $intf_type {
                    default {
                        set protocol_intf_options "                             \
                                -atm_encapsulation      atm_encapsulation       \
                                -atm_vci                vci                     \
                                -atm_vpi                vpi                     \
                                -gateway_address        neighbor_intf_ip_addr   \
                                -ipv4_address           intf_ip_addr            \
                                -ipv4_prefix_length     intf_prefix_len         \
                                -mac_address            mac_address_init        \
                                -port_handle            port_handle             \
                                -prot_intf_objref       intf_objref             \
                                -vlan_enabled           vlan                    \
                                -vlan_id                vlan_id                 \
                                -vlan_user_priority     vlan_user_priority      \
                                "
                    }
                }
    
                # Passed in only those options that exists
                set protocol_intf_args ""
                foreach {option value_name} $protocol_intf_options {
                    if {[info exists $value_name]} {
                        if {[lindex [set $value_name] $index] != {}} {
                            append protocol_intf_args " $option [lindex [set $value_name] $index]"
                        } else {
                            append protocol_intf_args " $option [lindex [set $value_name] end]"
                        }
                    }
                }
        
                # (Re)configure interfaces
                if {[llength $protocol_intf_args] > 0} {
                    set intf_list ""
                    # BUG1131529 - if igmp host is created with -mode create and -override_tracking 1
                    # pa_inth_idx will not contain the protocol interface
                    append protocol_intf_args " -override_tracking 1"
                    switch -- $intf_type {
                        default {
                            set intf_list [eval ixNetworkConnectedIntfCfg \
                                    $protocol_intf_args]
                        }
                    }
        
                    if {[keylget intf_list status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to modify the IPv4\
                                configuration from the $intf_objref interface -\
                                [keylget intf_list log]."
                        return $returnList
                    }
                    if {![info exists no_write] && [catch {ixNet commit} err_msg]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to commit the IPv4\
                            configuration modifications from the $intf_objref\
                            interface - $err_msg."
                        return $returnList
                    }
                }
            }
            
            # Start creating list of static IGMP router options
            set igmp_querier_static_args [list -enabled true]
    
            # List of static (non-incrementing) options for IGMP querier
            set staticIgmpQuerierOptions {
                igmp_version                      version                     translate
                ip_router_alert                   routerAlert                 truth
                discard_learned_info              discardLearnedInfo          truth
                support_election                  supportElection             truth
                robustness_variable               robustnessVariable          int
                query_interval                    generalQueryInterval        int
                general_query_response_interval   gqResponseInterval          int
                startup_query_count               startupQueryCount           int
            }
            # Below options are not valid for IGMP version 1
            if {![info exists igmp_version]} {
                keylset returnList log "Failure in ixnetwork_igmp_querier_config:\
                        igmp_version argument is mandatory for -mode create"
                keylset returnList status $::FAILURE
                return $returnList
            } elseif {$igmp_version != "v1"} {
                # specific_query_response_interval and specific_query_transmission_count
                # are only valid if discard_learned_info is not enabled
                if {[info exists discard_learned_info] && (! $discard_learned_info)} {
                    set staticIgmpQuerierOptions "$staticIgmpQuerierOptions
                        specific_query_response_interval    sqResponseInterval     int 
                        specific_query_transmission_count   sqTransmissionCount    int
                    "
                }
                set staticIgmpQuerierOptions "$staticIgmpQuerierOptions    
                    support_older_version_host        supportOlderVersionHost     truth
                "
                # support_older_version_querier is only valid when support_election 
                # is enabled
                if {[info exists support_election] && $support_election} {
                    set staticIgmpQuerierOptions "$staticIgmpQuerierOptions    
                        support_older_version_querier  supportOlderVersionQuerier  truth 
                    "
                }
            }
            # Check IGMP querier options existence and append parameters that exist
            foreach {hltOpt ixnOpt optType} $staticIgmpQuerierOptions {
                if {[info exists $hltOpt]} {
                    switch $optType {
                        translate {
                            lappend igmp_querier_static_args -$ixnOpt \
                                    [set translate_${hltOpt}([set $hltOpt])]
                        }
                        truth {
                            lappend igmp_querier_static_args -$ixnOpt \
                                    $truth([set $hltOpt])
                        }
                        int {
                            lappend igmp_querier_static_args -$ixnOpt [set $hltOpt]
                        }
                    }
                }
            }
            
            set ixn_version [join [lrange [split [ixNet getAttribute [ixNet getRoot]globals -buildNumber] .] 0 1] .]
            
   
            ## querier(s) modification
            # Apply modified configurations
            if {![info exists no_write]} {
                set result [ixNetworkNodeSetAttr $objref $igmp_querier_static_args -commit]
            } else {
                set result [ixNetworkNodeSetAttr $objref $igmp_querier_static_args ]
            }
            if {[keylget result status] == $::FAILURE} {
                keylset returnList log "Failure in ixnetwork_igmp_querier_config:\
                        encountered an error while executing: \
                        ixNetworkNodeSetAttr $objref $igmp_querier_static_args\
                        - [keylget result log]"
                keylset returnList status $::FAILURE
                return $returnList
            }
            incr index
        }

        keylset returnList handle $handle
    }

    return $returnList
}


proc ::ixia::ixnetwork_igmp_control { args man_args opt_args } {
    variable ixnetwork_port_handles_array
    variable igmp_host_ip_handles_array
    variable multicast_group_ip_to_handle
    variable multicast_source_ip_to_handle
    
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    

    keylset returnList status $::SUCCESS

    array set protocol_objref_array [list]
    if {![info exists port_handle] && ![info exists handle]} {
        foreach {port_handle handle_elem} [array get ::ixia::ixnetwork_port_handles_array] {
            if {[llength [ixNet getL ${handle_elem}/protocols/igmp host]]>0} {
                set protocol_objref_array(${handle_elem}/protocols/igmp) true
            }
            if {[llength [ixNet getL ${handle_elem}/protocols/igmp querier]]>0} {
                set protocol_objref_array(${handle_elem}/protocols/igmp) true
            }
        }
    }
    set group_range_handle ""
    set exists_ip_group_range 0
    if {[info exists port_handle]} {
        set vport_handles ""
        foreach item $port_handle {
            set result [ixNetworkGetPortObjref $item]
            if {[keylget result status] == $::FAILURE} {
                if {![info exists handle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to find the port object\
                            reference associated to the $item port handle -\
                            [keylget result log]."
                    return $returnList
                }
            } else {
                set protocol_objref_array([keylget result vport_objref]/protocols/igmp) true
                lappend vport_handles [keylget result vport_objref]
            }
        }
        if {($mode == "leave" || $mode == "join") && 
                ![info exists group_member_handle] && ![info exists handle]} {
            set group_array [array get multicast_group_ip_to_handle]
            foreach item $vport_handles {
                foreach {key value} $group_array {
                    if {[regexp $item $value]} {
                        lappend group_range_handle $value
                    }
                }
            }
        }
    }
    
    if {[info exists handle]} {
        foreach item $handle {
            if {[isIpAddressValid $item]} {
                # the handle is a host IP
                if {[info exists igmp_host_ip_handles_array($item)]} {
                    set item $igmp_host_ip_handles_array($item)
                    foreach {gkey gvalue} [array get multicast_group_ip_to_handle] {
                        # get the groups created on the host
                        if  {![string first $item $gvalue]} {
                            lappend group_range_handle $gvalue
                        }
                    }
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "IP $item is not a valid host IP. Unable to find $item in the host IPs."
                    return $returnList
                }
            }
            set found [regexp {(.*igmp)/(host|querier):\d+} $item {} found_protocol_objref]
            if {$found} {
                set protocol_objref_array($found_protocol_objref) true
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to get the IGMP protocol\
                        object reference out of the handle received as input:\
                        $item"
                return $returnList
            }
        }
    }
    if {[info exists group_member_handle]} {
        # Group range handles
        foreach group_handle $group_member_handle {
            if {[regexp {^(\d+.\d+.\d+.\d+)/(\d+.\d+.\d+.\d+)/(\d+)$} $group_handle all ip step count] && \
                    [info exists multicast_group_ip_to_handle($group_handle)]} {
                # get ixnetwork version
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
                if {$ixn_version_major>6} {
                    set exists_ip_group_range 1
                    if {($mode=="join" && [catch {ixNet exec igmpJoin $ip $count} err]) ||\
                        ($mode=="leave" && [catch {ixNet exec igmpLeave $ip $count} err])} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Operation $mode failed for $group_handle. ixNet error: $err"
                        return $returnList
                    }
                } else {
                    set exists_ip_group_range 0
                    lappend group_range_handle $multicast_group_ip_to_handle($group_handle)
                }

                
            } elseif {[regexp {^::ixNet::OBJ-/vport:[0-9]+/protocols/igmp/host:[0-9]+/group:[0-9]+$} $group_handle]} {
                lappend group_range_handle $group_handle
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "The group member handle provided is not \
                        a valid group handle: $group_handle"
                return $returnList
            }
        }
    }
    set protocol_objref_list [array names protocol_objref_array]
    # Check link state
    # after 10000 => BUG660413: HLTAPI: ::ixia::emulation_igmp_control -mode "start" is too slow (11 seconds) 
    foreach protocol_objref $protocol_objref_list {
        regexp {(::ixNet::OBJ-/vport:\d+).*} $protocol_objref {} vport_objref
        set retries 60
        set portState  [ixNet getAttribute $vport_objref -state]
        set portStateD [ixNet getAttribute $vport_objref -stateDetail]
        while {($retries > 0) && ( \
                ($portStateD != "idle") || ($portState  == "busy"))} {
            after 1000
            set portState  [ixNet getAttribute $vport_objref -state]
            set portStateD [ixNet getAttribute $vport_objref -stateDetail]
            incr retries -1
        }
        if {($portStateD != "idle") || ($portState == "busy")} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to start IGMP on the $vport_objref\
                    port. Port state is $portState, $portStateD."
            return $returnList
        }
    }
    set commit_needed 0
    switch -exact $mode {
        restart {
            foreach protocol_objref $protocol_objref_list {
                if {[catch {ixNet exec stop $protocol_objref} retCode] || \
                        ([string first "::ixNet::OK" $retCode] == -1)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to start IGMP on the\
                            $vport_objref port. Error code: $retCode."
                    return $returnList
                }
                after 1000
                if {[catch {ixNetworkExec [list start $protocol_objref]} retCode] || \
                        ([string first "::ixNet::OK" $retCode] == -1)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to start IGMP on the\
                            $vport_objref port. Error code: $retCode."
                    return $returnList
                }
            }
            after 1000
        }
        start {
            if {$group_range_handle!="" && ![info exists handle]} {
                foreach group_range $group_range_handle {
                    if {[ixNet getAttr $group_range -enabled] == "false"} {
                        ixNet setAttr $group_range -enabled true
                        set commit_needed 1
                    }
                }
            }
            foreach protocol_objref $protocol_objref_list {
                if {[catch {ixNetworkExec [list start $protocol_objref]} retCode] || \
                        ([string first "::ixNet::OK" $retCode] == -1)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to start IGMP on the\
                            $vport_objref port. Error code: $retCode."
                    return $returnList
                }
            }
            after 1000
        }
        stop {
            if {$group_range_handle!=""} {
                foreach group_range $group_range_handle {
                    if {[ixNet getAttr $group_range -enabled] == "true"} {
                        ixNet setAttr $group_range -enabled false
                        set commit_needed 1
                    }
                }
            }
            foreach protocol_objref $protocol_objref_list {
                if {[catch {ixNet exec stop $protocol_objref} retCode] || \
                        ([string first "::ixNet::OK" $retCode] == -1)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to start IGMP on the\
                            $vport_objref port. Error code: $retCode."
                    return $returnList
                }
            }
            after 1000
        }
        join {
            if {$group_range_handle!="" && $exists_ip_group_range==0} {
                foreach group_range $group_range_handle {
                    if {[ixNet getAttr $group_range -enabled] == "true"} {
                        ixNet setAttr $group_range -enabled false
                        ixNet setAttr $group_range -enabled true
                    } else {
                        ixNet setAttr $group_range -enabled true
                    }
                }
                set commit_needed 1
            }
        }
        leave {
            if {$group_range_handle!="" && $exists_ip_group_range==0} {
                foreach group_range [join $group_range_handle] {
                    if {[ixNet getAttr $group_range -enabled] == "true"} {
                        ixNet setAttr $group_range -enabled false
                    } else {
                        ixNet setAttr $group_range -enabled true
                        ixNet setAttr $group_range -enabled false
                    }
                }
                set commit_needed 1
            }
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "Unknown mode: '$mode'. Please use \
                    'start' or 'stop' when using IGMP with IxNetwork."
            return $returnList
        }
    }
    if {$commit_needed == 1} {
        ixNet commit
    }
    return $returnList
}


proc ::ixia::ixnetwork_igmp_group_config { args man_args opt_args } {
    variable objectMaxCount
    variable truth
    variable multicast_group_array
    variable multicast_source_array
    variable igmp_attributes_array
    variable igmp_host_ip_handles_array
    variable multicast_group_ip_to_handle
    variable multicast_source_ip_to_handle
    
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    keylset returnList status $::SUCCESS
    
    array set translate_g_filter_mode [list \
            include             include     \
            exclude             exclude     \
            ]
    
    array set translate_filter_mode [list   \
            include             include     \
            exclude             exclude     \
            ]
    
    array set translate_mode [list          \
            enable          true            \
            disable         false           \
            ]
    set single_ip_multiple_handles 0
    # Verify conditions for getting started
    # For delete we need a -handle argument
    if {$mode == "delete" || $mode == "modify" || $mode == "enable" || $mode == "disable"} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode, you must provide the\
                    -handle argument."
            return $returnList
        }
    }
    # For create and clear_all we need -session_handle
    if {$mode == "create" || ($mode == "clear_all")} {
        if {![info exists session_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "If -mode is $mode you must provide -session_handle"
            return $returnList
        } elseif {[llength $session_handle] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -mode is $mode, -session_handle may\
                        only contain one value."
                return $returnList
        } else {
            if {[isIpAddressValid $session_handle]} {
                if {[info exists igmp_host_ip_handles_array($session_handle)]} {
                    set session_handle $igmp_host_ip_handles_array($session_handle)
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The -session_handle provided was not found\
                            in the protocol interfaces IPs"
                    return $returnList
                }
            }
        }
    }
    # For create you also need a -group_pool_handle argument
    if {$mode == "create"} {
        if {![info exists group_pool_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "If -mode is $mode you must provide one\
                    argument for -group_pool_handle."
            return $returnList
        }
    }
    # For modify you also need a -handle and
    # a -group_pool_handle single argument or a -source_pool_handle
    if {$mode == "modify"} {
        # Remove defaults
        removeDefaultOptionVars $opt_args $args

        set group_members_handle ""
        set handle_is_group_member 0
        foreach handle_elem $handle {
            if {[regexp {^(\d+.\d+.\d+.\d+)/(\d+.\d+.\d+.\d+)/(\d+)$} $handle_elem] && [info exists multicast_group_ip_to_handle($handle_elem)]} {
                # append is used instead of lappend because multicast_group_ip_to_handle($handle_elem)
                # may contain a list of elements
                if {[llength $multicast_group_ip_to_handle($handle_elem)]>1} {
                    # flag used to mark the group IPs that map on several handles
                    set single_ip_multiple_handles 1
                }
                append group_members_handle " $multicast_group_ip_to_handle($handle_elem)"
                set handle_is_group_member 1
            }
        }
        if {$handle_is_group_member} {
            set handle $group_members_handle
        }
        if {![info exists group_pool_handle] && \
                ![info exists source_pool_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "If -mode is $mode you must provide the\
                    -group_pool_handle or -source_pool_handle argument."
            return $returnList
        }
    }
    
    if {$mode == "delete"} {
        foreach objref $handle {
            if {[regexp {(\d+.\d+.\d+.\d+)/(\d+.\d+.\d+.\d+)/(\d+)} $objref]} {
                set new_handle ""
                foreach group_handle_item $objref {
                    if {[info exists multicast_group_ip_to_handle($group_handle_item)]} {
                        append new_handle " $multicast_group_ip_to_handle($group_handle_item)"
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "The handle element $group_handle_item was not found\
                                in the configured Group Ranges."
                        return $returnList
                    }
                }
                # set the low level handle
                set objref $new_handle
            } elseif {[regexp {^group[0-9]+$} $objref]} {
                # get the low level handle
                set ip_addr_start $multicast_group_array($objref,ip_addr_start)
                set ip_addr_step $multicast_group_array($objref,ip_addr_step)
                set num_groups $multicast_group_array($objref,num_groups)
                set objref $multicast_group_ip_to_handle($ip_addr_start/$ip_addr_step/$num_groups)
            } else {
                if {![regexp {^::ixNet::OBJ-/vport:[0-9]+/protocols/igmp/host:[0-9]+/group:[0-9]+} $objref]} {
                    # if the handle is not even a low level handle, display error
                    keylset returnList status $::FAILURE
                    keylset returnList log "The handle element $objref is not a valid Group Range."
                    return $returnList
                }
            }
            ixNet remove [concat $objref]
            
            # remove the internal keys for the deleted elements
            foreach {gkey gvalue} [array get multicast_group_ip_to_handle] {
                if {[concat $gvalue] == [concat $objref]} {
                    # remove the sources from multicast_source_ip_to_handle array
                    foreach {skey svalue} [array get multicast_source_ip_to_handle] {
                        if {![string first $gvalue $svalue]} {
                            unset multicast_source_ip_to_handle($skey)
                            if {[regexp {^(\d+.\d+.\d+.\d+)/(\d+.\d+.\d+.\d+)/(\d+)$} $skey all src_addr]} {
                                foreach {mskey msvalue} [array get multicast_source_array] {
                                    if {[regexp {([a-zA-z0-9]+),ip_addr_start} $mskey full_value found_source]} {
                                        if {$src_addr == $msvalue} {
                                            unset multicast_source_array($found_source,ip_addr_start)
                                            unset multicast_source_array($found_source,ip_addr_step)
                                            unset multicast_source_array($found_source,ip_prefix_len)
                                            unset multicast_source_array($found_source,num_sources)
                                        } else {
                                            continue
                                        }
                                    }
                                }
                            }
                        }
                    }
                    # remove the group ranges from multicast_group_ip_to_handle array
                    if {[regexp {^(\d+.\d+.\d+.\d+)/(\d+.\d+.\d+.\d+)/(\d+)$} $gkey all gr_addr]} {
                        foreach {mgkey mgvalue} [array get multicast_group_array] {
                            if {[regexp {([a-zA-z0-9]+),ip_addr_start} $mgkey full_value found_group]} {
                                if {$gr_addr == $mgvalue} {
                                    set result [::ixia::igmp_array_operations multicast_group_array \
                                            remove $found_group]
                                    if {[keylget result status] == $::FAILURE} {
                                        keylset returnList log "Failure in ixnetwork_igmp_config:\
                                                encountered an error while executing igmp_array_operations \
                                                - [keylget result log]"
                                        keylset returnList status $::FAILURE
                                        return $returnList
                                    }
                                } else {
                                    continue
                                }
                            }
                        }
                    }
                    set result [::ixia::igmp_array_operations \
                            multicast_group_ip_to_handle remove $gkey ]
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList log "Failure in ixnetwork_igmp_config:\
                                encountered an error while executing igmp_array_operations \
                                - [keylget result log]"
                        keylset returnList status $::FAILURE
                        return $returnList
                    }
                }
            }
        }
        ixNet commit
    }

    if {$mode == "enable" || $mode == "disable"} {
        set return_handle_list ""
        foreach objref $handle {
            if {[regexp {^(\d+.\d+.\d+.\d+)/(\d+.\d+.\d+.\d+)/(\d+)$} $objref]} {
                if {[catch {set objref $multicast_group_ip_to_handle($objref)} array_error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Handle $objref is not valid for this IGMP configuration.\
                            Please check the available group member parameters."
                    return $returnList
                }
            }
            foreach obj $objref {
                
                set result [ixNetworkNodeSetAttr $obj \
                        [subst {-enabled $translate_mode($mode)}]]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList log "Failure in ixnetwork_igmp_group_config:\
                            encountered an error while executing: \
                            ixNetworkNodeSetAttr $objref\
                            [subst {-enabled $translate_mode($mode)}]\
                            - [keylget result log]"
                    keylset returnList status $::FAILURE
                    return $returnList
                }
                lappend return_handle_list $obj
            }
        }
        keylset returnList handle $return_handle_list
        if {[catch {ixNet commit} err_msg]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to commit the\
                modifications for $handle"
            return $returnList
        }
    }

    if {$mode == "clear_all"} {
        if {[isIpAddressValid $session_handle]} {
            set session_handle $igmp_host_ip_handles_array($session_handle)
        }
        set groups_list [ixNet getList $session_handle group]
        foreach group $groups_list {
            ixNet remove $group
        }
        ixNet commit
        # Clear the arrays
        foreach group_handle_item $groups_list {
            # remove the internal keys for the deleted elements
            foreach {gkey gvalue} [array get multicast_group_ip_to_handle] {
                if {[concat $gvalue] == [concat $group_handle_item]} {
                    # remove the sources from multicast_source_ip_to_handle array
                    foreach {skey svalue} [array get multicast_source_ip_to_handle] {
                        if {![string first $gvalue $svalue]} {
                            unset multicast_source_ip_to_handle($skey)
                            if {[regexp {^(\d+.\d+.\d+.\d+)/(\d+.\d+.\d+.\d+)/(\d+)$} $skey all src_addr]} {
                                foreach {mskey msvalue} [array get multicast_source_array] {
                                    if {[regexp {([a-zA-z0-9]+),ip_addr_start} $mskey full_value found_source]} {
                                        if {$src_addr == $msvalue} {
                                            unset multicast_source_array($found_source,ip_addr_start)
                                            unset multicast_source_array($found_source,ip_addr_step)
                                            unset multicast_source_array($found_source,ip_prefix_len)
                                            unset multicast_source_array($found_source,num_sources)
                                        } else {
                                            continue
                                        }
                                    }
                                }
                            }
                        }
                    }
                    # remove the group ranges from multicast_group_ip_to_handle array
                    if {[regexp {^(\d+.\d+.\d+.\d+)/(\d+.\d+.\d+.\d+)/(\d+)$} $gkey all gr_addr]} {
                        foreach {mgkey mgvalue} [array get multicast_group_array] {
                            if {[regexp {([a-zA-z0-9]+),ip_addr_start} $mgkey full_value found_group]} {
                                if {$gr_addr == $mgvalue} {
                                    set result [::ixia::igmp_array_operations multicast_group_array \
                                            remove $found_group]
                                    if {[keylget result status] == $::FAILURE} {
                                        keylset returnList log "Failure in ixnetwork_igmp_config:\
                                                encountered an error while executing igmp_array_operations \
                                                - [keylget result log]"
                                        keylset returnList status $::FAILURE
                                        return $returnList
                                    }
                                } else {
                                    continue
                                }
                            }
                        }
                    }
                    set result [::ixia::igmp_array_operations \
                            multicast_group_ip_to_handle remove $gkey ]
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList log "Failure in ixnetwork_igmp_config:\
                                encountered an error while executing igmp_array_operations \
                                - [keylget result log]"
                        keylset returnList status $::FAILURE
                        return $returnList
                    }
                }
            }
        }
    }

    if {$mode == "create" || $mode == "modify"} {
        # check if the number of source handles is the same as the number 
        # of group handles
        if {[info exists group_pool_handle] && \
            [info exists source_pool_handle] && \
            [llength $group_pool_handle] != [llength $source_pool_handle] && \
            [llength $group_pool_handle] != 1 \
        } {
            keylset returnList status $::FAILURE
            keylset returnList log "The number of sources provided must be\
                    the same as the number of group pool handles provided."
            return $returnList
        }
        if {$mode == "create"} {
            # Resetting everything makes sense only with -mode create
            if {[info exists reset]} {
                if {[info exists no_write]} {
                    set result [ixNetworkNodeRemoveList $session_handle { {child remove group} {} }]
                } else {
                    set result [ixNetworkNodeRemoveList $session_handle { {child remove group} {} } -commit]
                }
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not reset the $session_handle\
                            IGMP host - [keylget result log]."
                    return $returnList
                }
            }
            set handle $session_handle
        }

        if {$mode == "modify"} {
            # check if the number of handles is equal to the number of
            # group handles or source handles
            if {[info exists group_pool_handle] && ([llength $handle]!=[llength $group_pool_handle]) && ($single_ip_multiple_handles!=1)} {
                keylset returnList status $::FAILURE
                keylset returnList log "The number of group pool handles provided must be\
                        the same as the number of handles provided."
                return $returnList
            }
            if {[info exists source_pool_handle] && ([llength $handle]!=[llength $source_pool_handle])} {
                keylset returnList status $::FAILURE
                keylset returnList log "The number of source pool handles provided must be\
                        the same as the number of handles provided."
                return $returnList
            }
            foreach handle_elem $handle {
                set found [regexp {(.*host:\d+)/group:\d+} $handle_elem {} \
                        session_handle]
                if {!$found} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to get the IGMP host\
                            object reference out of the handle received as\
                            input: $handle_elem"
                    return $returnList
                }
            }
            keylset returnList handle $handle
        }
        if {[info exists group_pool_handle]} {
            # Prepare IGMP group options variables
            set group_index 0
            set group_handle_list ""
            if {$mode == "modify"} {
                if {[llength $group_pool_handle]!=[llength $handle]} {
                    if {$single_ip_multiple_handles==1} {
                        # if there is an IP that map on multiple handles, multiply the length of
                        # parameter -group_pool_handle to match the length of -handle
                        set length_diff [expr [llength $group_pool_handle] - [llength $handle]]
                        if {$length_diff>0} {
                            for {set i 0} {$i<[expr abs($length_diff)]} {incr i} {
                                set group_pool_handle [lreplace $group_pool_handle [llength $group_pool_handle] end]
                            }
                        } else {
                            for {set i 0} {$i<[expr abs($length_diff)]} {incr i} {
                                lappend group_pool_handle [lindex $group_pool_handle end end]
                            }
                        }
                    } else {
                        keylset returnList status $::FAILURE
                        keylset returnList log "The number of -group_pool_handle elements ([llength $group_pool_handle]) must be the same as \
                                the number of -handle arguments ([llength $handle]) provided."
                        return $returnList
                    }
                }
            }
            foreach group_pool_elem $group_pool_handle {
                if {$group_pool_elem == ""} {
                    continue
                }
                set group_handle_is_ip 0
                if {[regexp {^(\d+.\d+.\d+.\d+)/(\d+.\d+.\d+.\d+)/(\d+)$} $group_pool_elem all ip_addr_start ip_addr_step num_groups]} {
                    # the regexp will set the ip_addr_start, increment_step and num_groups
                    if {[lindex [split $ip_addr_start .] 0] < 224} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Please provide a\
                                multicast IP instead of $ip_addr_start."
                        return $returnList
                    }
                    set increment_step [::ixia::ip_addr_to_num $ip_addr_step]
                    set group_handle_is_ip 1
                } else {
                    if {![info exists multicast_group_array($group_pool_elem,ip_addr_start)]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "The '$group_pool_elem' group\
                                pool handle is invalid."
                        return $returnList
                    }
                    set ip_addr_start $multicast_group_array($group_pool_elem,ip_addr_start)
                    set ip_addr_step $multicast_group_array($group_pool_elem,ip_addr_step)
                    set increment_step [::ixia::ip_addr_to_num $ip_addr_step]
                    set num_groups $multicast_group_array($group_pool_elem,num_groups)
                }

                if {[ixNet getAttribute $session_handle -version] != "igmpv3" && \
                        [info exists filter_mode]} {
                    unset filter_mode
                }

                # Start creating list of static IGMP group options
                set igmp_group_args [list -enabled true]

                # List of global options for IGMP
                set staticIgmpGroupOptions [list                                                                        \
                        {enable_packing        g_enable_packing}        enablePacking       truth       {remote local}  \
                        {filter_mode           g_filter_mode}           sourceMode          translate   {remote local}  \
                        ip_addr_start                                   groupFrom           default     local           \
                        increment_step                                  incrementStep       default     local           \
                        {max_groups_per_pkts   g_max_groups_per_pkts}   recordsPerFrame     default     {remote local}  \
                        {max_sources_per_group g_max_sources_per_group} sourcesPerRecord    default     {remote local}  \
                        num_groups                                      groupCount          default     local           \
                        ]

                # Check IGMP group options existence and append parameters 
                # that exist
                foreach {hltOpts ixnOpt optType srcTypes} $staticIgmpGroupOptions {
                    foreach hltOpt $hltOpts srcType $srcTypes {
                        if {$srcType == "remote"} {
                            if {[info exists igmp_attributes_array($handle,$hltOpt)]} {
                                set $hltOpt $igmp_attributes_array($handle,$hltOpt)
                            }
                        }
                        if {[info exists $hltOpt]} {
                            if {[llength [set $hltOpt]]>1} {
                                set hlt_value [lindex [set $hltOpt] $group_index]
                            } else {
                                set hlt_value [set $hltOpt]
                            }
                            switch $optType {
                                translate {
                                    lappend igmp_group_args -$ixnOpt \
                                            [set translate_${hltOpt}($hlt_value)]
                                }
                                truth {
                                    lappend igmp_group_args -$ixnOpt \
                                            $truth($hlt_value)
                                }
                                default {
                                    lappend igmp_group_args -$ixnOpt \
                                            $hlt_value
                                }
                            }
                        }
                    }
                }
                if {$group_handle_is_ip} {
                    set mcast [::ixia::emulation_multicast_group_config \
                                -mode create  -num_groups $num_groups  \
                                -ip_addr_start $ip_addr_start -ip_addr_step $ip_addr_step ]
                    if {[keylget mcast status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "[keylget mcast log]. Could not add a new group to the internal arrays."
                        return $returnList
                    }
                }
                if {$mode == "create"} {
                    # Create group
                    if {[info exists no_write]} {
                        set result [ixNetworkNodeAdd $session_handle group $igmp_group_args]
                    } else {
                        set result [ixNetworkNodeAdd $session_handle group $igmp_group_args -commit]
                    }
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Could not add a new group to the\
                                following IGMP host object reference:\
                                $session_handle - [keylget result log]."
                        return $returnList
                    }
                    set group_handle [keylget result node_objref]
                    set group_handle [ixNet remapIds $group_handle]
                    # Add the group handle to the group members array
                    if {$group_handle_is_ip} {
                        if {[info exists multicast_group_ip_to_handle($group_pool_elem)]} {
                            lappend multicast_group_ip_to_handle($group_pool_elem) $group_handle
                        } else {
                            set multicast_group_ip_to_handle($group_pool_elem) $group_handle
                        }
                    } else {
                        if {[info exists multicast_group_ip_to_handle($ip_addr_start/$ip_addr_step/$num_groups)]} {
                            lappend multicast_group_ip_to_handle($ip_addr_start/$ip_addr_step/$num_groups) $group_handle
                        } else {
                            set multicast_group_ip_to_handle($ip_addr_start/$ip_addr_step/$num_groups) $group_handle
                        }
                    }
                    lappend group_handle_list $group_handle
                } else {
                    # Apply configurations
                    set handle_element [lindex $handle $group_index]
                    if {[info exists no_write]} {
                        set result [ixNetworkNodeSetAttr $handle_element $igmp_group_args]
                    } else {
                        set result [ixNetworkNodeSetAttr $handle_element $igmp_group_args -commit]
                    }
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList log "Failure in ixnetwork_igmp_config:\
                                encountered an error while executing: \
                                ixNetworkNodeSetAttr [lindex $handle $group_index] $igmp_group_args\
                                - [keylget result log]"
                        keylset returnList status $::FAILURE
                        return $returnList
                    }
                    lappend group_handle_list $handle_element
                    # remove the old group ranges from multicast_group_ip_to_handle array
                    foreach {key value} [array get multicast_group_ip_to_handle] {
                        if {[regexp $handle_element $value]} {
                            set result [::ixia::igmp_array_operations \
                                    multicast_group_ip_to_handle remove $key $handle_element]
                            if {[keylget result status] == $::FAILURE} {
                                keylset returnList log "Failure in ixnetwork_igmp_config:\
                                        encountered an error while executing igmp_array_operations \
                                        - [keylget result log]"
                                keylset returnList status $::FAILURE
                                return $returnList
                            }
                            regexp {^(\d+.\d+.\d+.\d+)/(\d+.\d+.\d+.\d+)/(\d+)$} $key all remove_ip remove_step remove_count
                            foreach index [array names multicast_group_array] {
                                if {[regexp {([a-zA-z0-9]+),ip_addr_start} $index full_value found_group]} {
                                    if {$remove_ip == $multicast_group_array($index)} {
                                        set result [::ixia::igmp_array_operations multicast_group_array \
                                                remove $found_group]
                                        if {[keylget result status] == $::FAILURE} {
                                            keylset returnList log "Failure in ixnetwork_igmp_config:\
                                                    encountered an error while executing igmp_array_operations \
                                                    - [keylget result log]"
                                            keylset returnList status $::FAILURE
                                            return $returnList
                                        }
                                    }
                                } else {
                                    continue
                                }
                            }
                        }
                    }
                    # add the new group ranges to multicast_group_ip_to_handle array
                    if {$group_handle_is_ip} {
                        if {[info exists multicast_group_ip_to_handle($group_pool_elem)]} {
                            lappend multicast_group_ip_to_handle($group_pool_elem) $handle_element
                        } else {
                            set multicast_group_ip_to_handle($group_pool_elem) $handle_element
                        }
                    } else {
                        if {[info exists multicast_group_ip_to_handle($ip_addr_start/$ip_addr_step/$num_groups)]} {
                            lappend multicast_group_ip_to_handle($ip_addr_start/$ip_addr_step/$num_groups) $handle_element
                        } else {
                            set multicast_group_ip_to_handle($ip_addr_start/$ip_addr_step/$num_groups) $handle_element
                        }
                    }
                }
                incr group_index
            }
            
            if {$mode == "create"} {
                if {![info exists source_pool_handle]} {
                    set source_pool_handle [list]
                }
                keylset returnList handle $group_handle_list
                keylset returnList group_pool_handle $group_pool_handle
                keylset returnList source_pool_handles $source_pool_handle
            }
        } elseif {$mode == "modify"} {
            # BUG716162: if mode is modify and group_pool_handle does not exist,
            # modify the parameters for the groups provided by -handle parameter
            if {![info exists group_pool_handle]} {
                set handle_index 0
                set commit_needed 0
                set gr_modif_params [list                   \
                    g_enable_packing        enablePacking   \
                    g_max_groups_per_pkts   recordsPerFrame \
                    g_max_sources_per_group sourcesPerRecord\
                    g_filter_mode           sourceMode      \
                ]
                foreach group_item $handle {
                    set ixn_args ""
                    foreach {hlt_p ixn_p} $gr_modif_params {
                        if {[info exists $hlt_p]} {
                            if {[llength [set $hlt_p]]>1 && [lindex [set $hlt_p] $handle_index]!=""} {
                                append ixn_args "-$ixn_p [lindex [set $hlt_p] $handle_index] "
                            } else {
                                append ixn_args "-$ixn_p [set $hlt_p] "
                            }
                        }
                    }
                    if {$ixn_args!=""} {
                        set result [ixNetworkNodeSetAttr $group_item $ixn_args]
                        if {[keylget result status] == $::FAILURE} {
                            keylset returnList log "Failure in ixnetwork_igmp_config:\
                                    encountered an error while executing: \
                                    ixNetworkNodeSetAttr $ixn_args $ixn_args\
                                    - [keylget result log]"
                            keylset returnList status $::FAILURE
                            return $returnList
                        }
                        set commit_needed 1
                    }
                    incr handle_index
                }
                if {$commit_needed && ![info exists no_write]} {
                    if {[catch {ixNet commit} err_msg]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to commit the\
                            modifications for $handle"
                        return $returnList
                    }
                }
            }
        }
        
        # Add IGMPv3 source groups
        if {[info exists source_pool_handle]} {
            # if group_pool_handle is not provided, modify source_pool_handle
            if {$mode == "modify"} {
                set group_handle_list $handle
            }
            # check the lenght of group_handle_list and source_pool_handle
            set group_list_length [llength $group_handle_list]
            set sources_list_length [llength $source_pool_handle]
            set length_diff [expr $group_list_length - $sources_list_length]
            if {$length_diff<0 && $group_list_length>1} {
                set source_pool_handle [lreplace $source_pool_handle $group_list_length end]
            } elseif {$length_diff<0 && $group_list_length==1} {
                for {set i 0} {$i<[expr abs($length_diff)]} {incr i} {
                    lappend group_handle_list [lindex $group_handle_list end end]
                }
            }
            set source_handle_list ""
            foreach source_pool_elem $source_pool_handle group_handle $group_handle_list {
                if {$source_pool_elem == ""} {
                    continue
                }
                if {$mode == "modify"} {
                    # Remove all source ranges from the group specified using 
                    # the -handle attribute
                    if {[info exists no_write]} {
                        set result [ixNetworkNodeRemoveList $group_handle { {child remove source} {} }]
                    } else {
                        set result [ixNetworkNodeRemoveList $group_handle { {child remove source} {} } -commit]
                    }
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Could not reset the $group_handle\
                                IGMP group - [keylget result log]."
                        return $returnList
                    }
                    set removed_items [keylget result removed_items]
                    set source_array_values [array get multicast_source_ip_to_handle]
                    foreach removed_item $removed_items {
                        foreach {key value} $source_array_values {
                            if {$value == $removed_item} {
                                unset multicast_source_ip_to_handle($key)
                                regexp {^(\d+.\d+.\d+.\d+)/(\d+.\d+.\d+.\d+)/(\d+)$} $key all remove_ip remove_step remove_count
                                foreach index [array names multicast_source_array] {
                                    if {[regexp {([a-zA-z0-9]+),ip_addr_start} $index full_value found_source]} {
                                        if {$remove_ip == $multicast_source_array($index)} {
                                            unset multicast_source_array($found_source,ip_addr_start)
                                            unset multicast_source_array($found_source,ip_addr_step)
                                            unset multicast_source_array($found_source,ip_prefix_len)
                                            unset multicast_source_array($found_source,num_sources)
                                        }
                                    } else {
                                        continue
                                    }
                                }
                            }
                        }
                    }
                    # set group_handle $handle
                }
                
                set source_handle_is_ip 0
                set source_handle ""
                foreach pool_handle [split $source_pool_elem ,] {
                    if {[regexp {^(\d+.\d+.\d+.\d+)/(\d+.\d+.\d+.\d+)/(\d+)$} $pool_handle all src_ip_addr_start increment_step num_sources]} {
                        # do nothing
                        # the regexp will set the ip_addr_start, increment_step and num_sources
                        set source_handle_is_ip 1
                    } else {
                        if {![info exists multicast_source_array($pool_handle,ip_addr_start)]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "The '$pool_handle' source\
                                    pool handle is invalid."
                            if {[info exists group_handle]} {
                                ixNet remove $group_handle
                                if {![info exists no_write]} {
                                    ixNet commit
                                }
                            }
                            return $returnList
                        }
                        # Prepare IGMPv3 source range options variables
                        set src_ip_addr_start \
                                $multicast_source_array($pool_handle,ip_addr_start)
                        set num_sources \
                                $multicast_source_array($pool_handle,num_sources)
                    }
                    
                    # Start creating list of static IGMPv3 group options
                    set igmp_source_range_args [list]
        
                    # List of global options for IGMPv3
                    set staticIgmpSourceRangeOptions {
                        src_ip_addr_start   sourceRangeStart
                        num_sources         sourceRangeCount
                    }

                    # Check IGMPv3 source range options existence and append 
                    # parameters that exist
                    foreach {hltOpt ixnOpt} $staticIgmpSourceRangeOptions {
                        if {[info exists $hltOpt]} {
                            lappend igmp_source_range_args -$ixnOpt [set $hltOpt]
                        }
                    }

                    # Create source range
                    if {[info exists no_write]} {
                        set result [ixNetworkNodeAdd $group_handle source $igmp_source_range_args]
                    } else {
                        set result [ixNetworkNodeAdd $group_handle source $igmp_source_range_args -commit]
                    }
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Could not add a new source range to\
                                the following IGMPv3 group object reference:\
                                $group_handle - [keylget result log]."
                        return $returnList
                    }
                    set source_elem_handle [keylget result node_objref]
                    # Add the entries to the internal arrays
                    if {$source_handle_is_ip} {
                        set multicast_source_ip_to_handle($pool_handle) $source_elem_handle
                        set mcast [::ixia::emulation_multicast_source_config \
                                -mode create  -num_sources $num_sources  \
                                -ip_addr_start $src_ip_addr_start -ip_addr_step $increment_step ]
                        if {[keylget mcast status] != $::SUCCESS} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "[keylget mcast log]. Could not add a new source to the internal arrays."
                            return $returnList
                        }
                    } else {
                        set multicast_source_ip_to_handle($src_ip_addr_start/$multicast_source_array($pool_handle,ip_addr_step)/$num_sources) $source_elem_handle
                    }
                    lappend source_handle $source_elem_handle
                }
                if {$source_handle != ""} {
                    set ceva [ixNet remapIds $source_handle]
                    lappend source_handle_list [ixNet remapIds $source_handle]
                }
            }
            keylset returnList source_handle $source_handle_list
        }
    }
    
    # This commit is only for no_write.
    if {[info exists no_write] && ($mode=="create" || $mode=="modify")} {
        if {[catch {ixNet commit} err_msg]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to commit the changes"
            return $returnList
            
        }
        # Modify the arrays
        if {[info exists group_pool_handle]} {
            set result [::ixia::igmp_array_operations \
                multicast_group_ip_to_handle remapIds $group_handle_list]
            set remap_group_handle [keylget result remap_handle_list]
            keylset returnList handle $remap_group_handle
        }
        if {[info exists source_pool_handle]} {
            set result [::ixia::igmp_array_operations \
                multicast_source_ip_to_handle remapIds $source_handle_list]
            set remap_source_handle [keylget result remap_handle_list]
            keylset returnList source_handle $remap_source_handle
        }
    }

    return $returnList
}


proc ::ixia::ixnetwork_igmp_info { args opt_args } {
    variable truth

    if {[catch {::ixia::parse_dashed_args -args $args -optional_args \
            $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }
    
    if {[regexp igmp $type]} {
        puts  "WARNING: -type $type is deprecated. Valid options for -type are:\
                host, querier and both. Default option (host) will be used."
    }
    if {$mode == "aggregate"} {
        if {[info exists port_handle]} {
            set return_status [ixNetworkGetPortObjref $port_handle]
            if {[keylget return_status status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "The '$port_handle' port has not been added to HLT. - [keylget return_status log]"
                return $returnList
            }
            set vport_objref [keylget return_status vport_objref]
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "Parameter -port_handle is required for -mode $mode"
            return $returnList
        }
    } elseif {$mode == "learned_info"} {
        if {[info exists handle]} {
        } elseif {[info exists port_handle]} {
            set return_status [ixNetworkGetPortObjref $port_handle]
            if {[keylget return_status status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "The '$port_handle' port has not been added to HLT. - [keylget return_status log]"
                return $returnList
            }
            set vport_objref [keylget return_status vport_objref]
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "One of the parameters -port_handle or -handle parameter is required for -mode $mode"
            return $returnList
        }
    } elseif {$mode == "clear_stats"} {
        if {[set retCode [catch {ixNet exec clearStats} retCode]]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to clear statistics."
            return $returnList
        }
    }
    
    regexp {^(\d+.\d+)(P|N|NO|P2NO)?$} $::ixia::ixnetworkVersion {} version product]
    keylset returnList status $::SUCCESS
    switch $mode  {
        aggregate       {
            set stat_views_list         [list]
            set stat_view_stats_list    [list]
            set stat_view_arrays_list   [list]

            if {$type =="host" || $type == "both" } { 
                lappend stat_views_list "IGMP Aggregated Statistics"
                set stats_list [list                                \
                    "Port Name"                                     \
                    "Host v1 Membership Rpts. Rx"                   \
                    "Host v2 Membership Rpts. Rx"                   \
                    "v1 Membership Rpts. Tx"                        \
                    "v2 Membership Rpts. Tx"                        \
                    "v3 Membership Rpts. Tx"                        \
                    "v2 Leave Tx"                                   \
                    "Host Total Frames Tx"                          \
                    "Host Total Frames Rx"                          \
                    "Host Invalid Packets Rx"                       \
                    "General Queries Rx"                            \
                    "Grp. Specific Queries Rx"                      \
                    "v3 Grp. & Src. Specific Queries Rx"            \
                    ]
                set stats_array [list                                             \
                    "Port Name"                           aggregate.port_name     \
                    "Host v1 Membership Rpts. Rx"         aggregate.rprt_v1_rx    \
                    "Host v2 Membership Rpts. Rx"         aggregate.rprt_v2_rx    \
                    "v1 Membership Rpts. Tx"              aggregate.rprt_v1_tx    \
                    "v2 Membership Rpts. Tx"              aggregate.rprt_v2_tx    \
                    "v3 Membership Rpts. Tx"              aggregate.rprt_v3_tx    \
                    "v2 Leave Tx"                         aggregate.leave_v2_tx   \
                    "Host Total Frames Tx"                aggregate.total_tx      \
                    "Host Total Frames Rx"                aggregate.total_rx      \
                    "Host Invalid Packets Rx"             aggregate.invalid_rx    \
                    "General Queries Rx"                  aggregate.gen_query_rx  \
                    "Grp. Specific Queries Rx"            aggregate.grp_query_rx  \
                    "v3 Grp. & Src. Specific Queries Rx"  aggregate.rprt_v3_rx    \
                    ]
                if {$version <= 6.30} {
                    set stats_list [lrange $stats_list 1 end]
                    set stats_array [lrange $stats_array 2 end]
                }
                lappend stat_view_stats_list $stats_list
                lappend stat_view_arrays_list $stats_array
                foreach {stat_name stat_key} $stats_array {
                    keylset returnList $port_handle.igmp.$stat_key  "N/A"
                }
            }
            
            if {$type =="querier" || $type == "both" } { 
                lappend stat_views_list "IGMP Querier Aggregated Statistics"
                set querier_stats_list [list                        \
                    "Port Name"                                     \
                    "Querier v1 Membership Rpts. Rx"                \
                    "Querier v2 Membership Rpts. Rx"                \
                    "v1 General Query Tx"                           \
                    "v2 General Query Tx"                           \
                    "v3 General Query Tx"                           \
                    "v2 Grp. specific Query Tx"                     \
                    "v3 Grp. Specific Query Tx"                     \
                    "v3 Grp. and Src. Specific Query Tx"            \
                    "Leave Rx"                                      \
                    "v3 Membership Rpts. Rx"                        \
                    "Querier Total Frames Tx"                       \
                    "Querier Total Frames Rx"                       \
                    "Querier Invalid Packets Rx"                    \
                    "General Queries Rx"                            \
                    "Grp. Specific Queries Rx"                      \
                    ]
                set querier_stats_array [list                       \
                    "Port Name"                                     \
                            querier.aggregate.port_name             \
                    "Querier v1 Membership Rpts. Rx"                \
                            querier.aggregate.rprt_v1_rx            \
                    "Querier v2 Membership Rpts. Rx"                \
                            querier.aggregate.rprt_v2_rx            \
                    "v3 Membership Rpts. Rx"                        \
                            querier.aggregate.rprt_v3_rx            \
                    "v1 General Query Tx"                           \
                            querier.aggregate.gen_query_v1_tx       \
                    "v2 General Query Tx"                           \
                            querier.aggregate.gen_query_v2_tx       \
                    "v3 General Query Tx"                           \
                            querier.aggregate.gen_query_v3_tx       \
                    "v2 Grp. specific Query Tx"                     \
                            querier.aggregate.grp_v2_query_tx       \
                    "v3 Grp. Specific Query Tx"                     \
                            querier.aggregate.grp_v3_query_tx       \
                    "v3 Grp. and Src. Specific Query Tx"            \
                            querier.aggregate.grp_src_v3_query_tx   \
                    "Leave Rx"                                      \
                            querier.aggregate.leave_rx              \
                    "Querier Total Frames Tx"                       \
                            querier.aggregate.total_tx              \
                    "Querier Total Frames Rx"                       \
                            querier.aggregate.total_rx              \
                    "Querier Invalid Packets Rx"                    \
                            querier.aggregate.invalid_rx            \
                    "General Queries Rx"                            \
                            querier.aggregate.gen_query_rx          \
                    "Grp. Specific Queries Rx"                      \
                            querier.aggregate.grp_query_rx          \
                ]
                if {$version <= 6.30} {
                    set querier_stats_list [lrange $querier_stats_list 1 end]
                    set querier_stats_array [lrange $querier_stats_array 2 end]
                }
                lappend stat_view_stats_list $querier_stats_list
                lappend stat_view_arrays_list $querier_stats_array
                foreach {stat_name stat_key} $querier_stats_array {
                    keylset returnList \
                                $port_handle.igmp.$stat_key \
                                "N/A"
                }  
            }
            set igmp_obj $vport_objref/protocols/igmp
            if {[ixNet getAttribute $igmp_obj -enabled] == "true"} {
                # Gather the statistics from the tables in the stat view browser
                foreach stat_view_name $stat_views_list \
                        stats_list $stat_view_stats_list \
                        stats_array $stat_view_arrays_list {
                    if {[info exists ports]} {
                        unset ports
                    }
                    array set ports [list]
                    foreach port $port_handle {
                        # An array is used for easily searching for a particular port
                        # handle.
                        # The value stored for each key has the following meaning:
                        #    1 - the port has been found in the gathered stats
                        #    0 - the port has not been found (yet) in the gathered stats
                        set ports($port) 0
                    }
                    
                    # detecting if at least one group/querier is enabled per port
                    #if no group/querier enabled skip to next view
                    set skip_this_type 1
                    switch $stat_view_name {
                        "IGMP Aggregated Statistics" {
                            foreach obj [ixNet getL $igmp_obj host] {
                                if {[ixNet getA $obj -enabled] == "true"} {
                                    set skip_this_type 0
                                    break
                                }
                            }
                            if {$skip_this_type} {continue}
                        }
                        "IGMP Querier Aggregated Statistics" {
                            foreach obj [ixNet getL $igmp_obj querier] {
                                if {[ixNet getA $obj -enabled] == "true"} {
                                    set skip_this_type 0
                                    break
                                }
                            }
                            if {$skip_this_type} {continue}
                        }
                    }
                    set returned_stats_list \
                            [ixNetworkGetStats $stat_view_name $stats_list]
                    if {[keylget returned_stats_list status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to read the '$stat_view_name'\
                                stat view browser - [keylget returned_stats_list log]"
                        return $returnList
                    }
        
                    set found false
                    set row_count [keylget returned_stats_list row_count]
                    if {[info exists stats_hash]} {
                        unset stats_hash
                    }
                    array set stats_hash $stats_array
                    array set rows_array [keylget returned_stats_list statistics]
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
                        if {[info exists ports($handle)]} {
                            set ports($handle) 1
                            foreach stat $stats_list {
                                if {[info exists rows_array($i,$stat)] && \
                                        $rows_array($i,$stat) != ""} {
                                    keylset returnList \
                                            $handle.igmp.$stats_hash($stat) \
                                            $rows_array($i,$stat)
                                } else {
                                    keylset returnList \
                                            $handle.igmp.$stats_hash($stat) \
                                            "N/A"
                                }
                            }
                        }
                    }
        
                    # Return an error if any of the ports sent via the -port_handle 
                    # attribute to this procedure has not been found.
                    set not_found [list]
                    foreach port [array names ports] {
                        if {$ports($port) == 0} {
                            lappend not_found $port
                        }
                    }
                    if {[llength $not_found] > 0} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "The '$not_found' port(s) couldn't be\
                                found among the ports from which statistics were\
                                gathered using the '$stat_view_name' stat view browser."
                        return $returnList
                    }
                }
            }
        }
        
        
        
        
        learned_info    {
            if {[info exists handle]} {
                set igmp_querier_list $handle
            } else {
                set igmp_querier_list [ixNet getL $vport_objref/protocols/igmp querier]
            }
            if {![info exists timeout]} {
                set timeout [expr 30 * [llength $igmp_querier_list]]
            }
            set timeout_counter 0
            
            set querier_modif_params [list                          \
                    compatibility_mode          compatibilityMode   \
                    compatibility_timer         compatibilityTimer  \
                    filter_mode                 filterMode          \
                    group_adress                groupAddress        \
                    group_timer                 groupTimer          \
                    source_address              sourceAddress       \
                    source_timer                sourceTimer         \
                ]
        
            foreach querier_obj $igmp_querier_list {
                #set querier_obj [ixNet getRoot]/vport:1/protocols/igmp/querier:1
                set retCode [ixNet exec refreshLearnedInfo $querier_obj]
                if {[string first "::ixNet::OK" $retCode] == -1 } {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to refresh learned info for\
                            IGMP querier $querier_obj."
                    return $returnList
                }
                set tries 0
                while {$timeout_counter < $timeout} {
                    after 1000
                    incr timeout_counter
                    set refresh_complete [ixNet getA  $querier_obj  -isRefreshComplete]
                    if {$refresh_complete} {break}
                    incr tries
                    if {$timeout_counter >= $timeout} {
                        break
                    }
                }
                if {$timeout_counter >= $timeout} {
                    break
                }
                if {! $refresh_complete} {
                    puts  "WARNING: Learned information is not completely refreshed\
                            after 60 seconds. The returned information might not be\
                            complete."
                }
                keylset returnList $port_handle.$querier_obj.querier_version \
                        [ixNet getA  $querier_obj -querierWorkingVersion]
                keylset returnList $port_handle.$querier_obj.querier_address \
                        [ixNet getA  $querier_obj -querierAddress]
                set record 1
                foreach learned_info_row [ixNet getL  $querier_obj learnedGroupInfo] {
                    foreach {hlt_attr ixn_attr} $querier_modif_params   {
                        keylset returnList $port_handle.$querier_obj.record.$record.$hlt_attr \
                                [ixNet getA $learned_info_row -$ixn_attr]
                    }
                    incr record
                }
            }
        }
    }
    # Check the returnList to see if returnList contains only the status key
    if {[keylkeys returnList] == "status" && [info exists timeout_counter] && [info exists timeout] && $timeout_counter >= $timeout} {
        keylset returnList status $::FAILURE
        keylset returnList log "Timeout value too small. In order for the igmp querier values to be populated a larger timeout value must be set."
    } elseif {[info exists timeout_counter] && [info exists timeout] && $timeout_counter >= $timeout} {
        puts "WARNING: Timeout value too small. Incomplete statistics have been retrieved."
        update idletasks
        keylset returnList log "Timeout value to small. Incomplete statistics have been retrieved"
    }
    return $returnList
}
