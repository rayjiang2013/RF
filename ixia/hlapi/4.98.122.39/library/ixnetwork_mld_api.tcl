proc ::ixia::ixnetwork_mld_config { args man_args opt_args } {
    variable objectMaxCount
    variable truth
    variable mld_attributes_array

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    keylset returnList status $::SUCCESS

    array set translate_mode [list              \
            enable          true                \
            disable         false               \
            enable_all      true                \
            disable_all     false               \
            ]

    array set translate_mld_version [list       \
            v1              version1            \
            v2              version2            \
            ]

    array set translate_mldv2_report_type [list \
            143             type143             \
            206             type206             \
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
                    keylset returnList log "Failure in ixnetwork_mld_config:\
                            encountered an error while executing: \
                            ixNetworkNodeSetAttr $objref\
                            [subst {-enabled $translate_mode($mode)}]\
                            - [keylget result log]"
                    keylset returnList status $::FAILURE
                    return $returnList
                }
            }
        }
        ixNet commit

        keylset returnList handle $handle
    }

    if {($mode == "enable_all") || ($mode == "disable_all")} {
        if {![info exists port_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode, the -port_handle\
                    option must be used. Please set this value."
            return $returnList
        }

        set mld_handle_list [list]

        foreach port $port_handle {
            set result [ixNetworkGetPortObjref $port]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to find the port object\
                        reference associated to the $port port handle -\
                        [keylget result log]."
                return $returnList
            } else {
                set protocol_objref [keylget result vport_objref]/protocols/mld
            }
    
            set host_list [ixNet getList $protocol_objref host]
            foreach host $host_list {
                set result [ixNetworkNodeSetAttr $host \
                        [subst {-enabled $translate_mode($mode)}]]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList log "Failure in ixnetwork_mld_config:\
                            encountered an error while executing: \
                            ixNetworkNodeSetAttr $host\
                            [subst {-enabled $translate_mode($mode)}]]\
                            - [keylget result log]"
                    keylset returnList status $::FAILURE
                    return $returnList
                }        
            }

            set mld_handle_list [concat $mld_handle_list $host_list]
        }
        ixNet commit

        keylset returnList handle $mld_handle_list
    }

    if {$mode == "create"} {
        if {![info exists intf_ip_addr] && ![info exists interface_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode,\
                    the -intf_ip_addr or -interface_handle options must be provided."
            return $returnList
        }
        
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
        set protocol_objref [keylget result vport_objref]/protocols/mld
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
            set result [ixNetworkNodeRemoveList $protocol_objref \
                    { {child remove host} {} } -commit]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not reset the mld protocol\
                        - [keylget result log]."
                return $returnList
            }
        }

        ## Protocol options
        # Start creating list of global MLD options
        set mld_protocol_args [list -enabled true \
                -enableDoneOnStop true]

        if {[info exists mldv2_report_type] && \
                [info exists translate_mldv2_report_type($mldv2_report_type)]} {
            lappend mld_protocol_args \
                    -mldv2Report $translate_mldv2_report_type($mldv2_report_type)
        }

        # List of global options for MLD
        set globalMldOptions {
            msg_count_per_interval  numberOfGroups
            msg_interval            timePeriod
        }

        # Check MLD options existence and append parameters that exist
        foreach {hltOpt ixnOpt} $globalMldOptions {
            if {[info exists $hltOpt]} {
                lappend mld_protocol_args -$ixnOpt [set $hltOpt]
            }
        }

        # Apply configurations
        set result [ixNetworkNodeSetAttr $protocol_objref $mld_protocol_args \
                -commit]
        if {[keylget result status] == $::FAILURE} {
            keylset returnList log "Failure in ixnetwork_mld_config:\
                    encountered an error while executing: \
                    ixNetworkNodeSetAttr $protocol_objref $mld_protocol_args\
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
        set ppp_int_count 1
        if {[info exists interface_handle] && [info exists count] && \
                [llength $interface_handle] != $count} {
            keylset returnList status $::FAILURE
            keylset returnList log "The -interface_handle list doesn't\
                    have the size specified with the -count argument."
            return $returnList
        } elseif {[info exists interface_handle]} {
            set intf_list [list]
            set no_ipv6 false
            foreach intf $interface_handle {
                foreach {intf_actual_handle intf_actual_idx intf_actual_type} [split $intf |] {}
                
                switch -- $intf_actual_type {
                    "ProtocolIntf" {
                        if {[llength [ixNet getList $intf_actual_handle ipv6]] > 0} {
                            lappend intf_list $intf
                        } else {
                            # intf_actual_handle is not a typo. We use this list only for logging the error
                            # message so we want it to be a simple list of interface handles
                            lappend no_ipv6_intf_list $intf_actual_handle
                            set no_ipv6 true
                        }
                    }
                    "PPP" {
                        set ret_code [ixNetworkEvalCmd [list ixNet getA ${intf_actual_handle}/pppoxRange -ncpType]]
                        if {[keylget ret_code status] != $::SUCCESS} {
                            return $ret_code
                        }
                        if {[keylget ret_code ret_val] == "IPv6"} {
                            lappend intf_list $intf
                        } else {
                            lappend no_ipv6_intf_list $intf_actual_handle
                            set no_ipv6 true
                        }
                        incr ppp_int_count
                    }
                    default {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Internal error. Unexpected interface handle type.\
                                Known interface handle types are: PPP and ProtocolIntf."
                        return $returnList
                    }
                }
            }
            if {$no_ipv6} {
                keylset returnList status $::FAILURE
                keylset returnList log "The following interfaces don't have\
                        IPv6 addresses configured: $no_ipv6_intf_list"
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
                    -ipv6_address               intf_ip_addr                \
                    -ipv6_address_step          intf_ip_addr_step           \
                    -ipv6_prefix_length         intf_prefix_len             \
                    -ipv6_gateway               neighbor_intf_ip_addr       \
                    -ipv6_gateway_step          neighbor_intf_ip_addr_step  \
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

        # Start creating list of static MLD router options
        set mld_host_static_args [list -enabled true]

        # The -mld_version attribute must not be modified
        if {$mode == "modify" && [info exists mld_version]} {
            unset mld_version
        }

        # List of static (non-incrementing) options for MLD host
        set staticMldHostOptions {
            general_query               enableQueryResMode      truth
            group_query                 enableSpecificResMode   truth
            mld_version                 version	                translate
            immediate_response          enableImmediateResp     truth
            ip_router_alert             enableRouterAlert       truth
            suppress_report             enableSuppressReport    truth
            robustness                  robustnessVariable      value
        }
        
        # Check MLD host options existence and append parameters that exist
        foreach {hltOpt ixnOpt optType} $staticMldHostOptions {
            if {[info exists $hltOpt]} {
                switch $optType {
                    translate {
                        lappend mld_host_static_args -$ixnOpt \
                                [set translate_${hltOpt}([set $hltOpt])]
                    }
                    truth {
                        lappend mld_host_static_args -$ixnOpt \
                                $truth([set $hltOpt])
                    }
                    value {
                        lappend mld_host_static_args -$ixnOpt \
                                [set $hltOpt]
                    }
                }
            }
        }

        # Particular static (non-incrementing) options for MLD host
        if {[info exists unsolicited_report_interval]} {
            lappend mld_host_static_args -enableUnsolicitedResMode true
            lappend mld_host_static_args -reportFreq \
                    $unsolicited_report_interval
        } else {
            lappend mld_host_static_args -enableUnsolicitedResMode false
        }
        # This "after" is due to BUG663130
        if {[llength $intf_list] != 0 && $ppp_int_count > 0} {
            after [expr 2000 * int(ceil(log($ppp_int_count)))]
        }
        ## Host(s) creation
        set objectCount    0
        foreach intf_objref $intf_list {
            set mld_host_args $mld_host_static_args

            foreach {intf_objref intf_objref_index intf_objref_type} [split $intf_objref |] {}

            set ixn_version [join [lrange [split [ixNet getAttribute [ixNet getRoot]globals -buildNumber] .] 0 1] .]

            switch -- $intf_objref_type {
                "ProtocolIntf" {
                    if {$ixn_version >= 5.50} {
                        lappend mld_host_args -interfaceType "Protocol Interface"
                        lappend mld_host_args -interfaces    $intf_objref
                    } else {
                        lappend mld_host_args -protocolInterface   $intf_objref
                    }
                }
                "PPP" {
                    if {$ixn_version < 5.50} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Internal error. Unexpected interface handle type.\
                                Interface handle type PPP is only supported starting with IxNetwork 5.50."
                        return $returnList
                    }
                    lappend mld_host_args -interfaces     $intf_objref
                    lappend mld_host_args -interfaceType  $intf_objref_type
                    lappend mld_host_args -interfaceIndex $intf_objref_index
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
                    $mld_host_args]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not add a new host to the\
                        following protocol object reference: $protocol_objref -\
                        [keylget result log]."
                return $returnList
            }
            set host_objref [keylget result node_objref]
            lappend mld_host_list $host_objref

            # Add to array the attributes to be passed to the
            # ::ixia::ixnetwork_mld_group_config procedure
            set remote_args_list [list      \
                    enable_packing          \
                    filter_mode             \
                    max_groups_per_pkts     \
                    max_sources_per_group   \
                    ]

            foreach arg $remote_args_list {
                if {[info exists $arg]} {
                    set mld_attributes_array($host_objref,$arg) [set $arg]
                }
            }

            # Commit
            incr objectCount
            if {[expr $objectCount % $objectMaxCount] == 0} {
                ixNet commit
            }
        }

        # Done
        if {[expr $objectCount % $objectMaxCount] != 0} {
            ixNet commit
        }

        # Update the array containing the attributes to be passed to the
        # ::ixia::ixnetwork_mld_group_config procedure and create
        # the returned value
        set mld_attributes_list [array get mld_attributes_array]
        foreach mld_host $mld_host_list {
            set old_mld_host $mld_host
            set new_mld_host [ixNet remapIds $mld_host]
            regsub -all $old_mld_host $mld_attributes_list \
                    $new_mld_host mld_attributes_list
            lappend new_mld_host_list $new_mld_host
        }

        if {[info exists mld_attributes_array]} {
            unset mld_attributes_array
        }
        array set mld_attributes_array $mld_attributes_list
        keylset returnList handle $new_mld_host_list
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
            set found [regexp {(.*mld)/host:\d+} $objref {} protocol_objref]
            if {!$found} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to get the MLD protocol\
                        object reference out of the handle received as\
                        input: $objref"
                return $returnList
            }
    
            ## Protocol options
            # Start creating list of global MLD options
            set mld_protocol_args [list -enabled true ]
            
            # List of global options for MLD
            set globalMldOptions {
                msg_count_per_interval  numberOfGroups
                msg_interval            timePeriod
            }
    
            # Check MLD options existence and append parameters that exist
            foreach {hltOpt ixnOpt} $globalMldOptions {
                if {[info exists $hltOpt]} {
                    if {[lindex [set $hltOpt] $index] != {}} {
                        lappend mld_protocol_args -$ixnOpt [lindex [set $hltOpt] $index]
                    } else {
                        lappend mld_protocol_args -$ixnOpt [lindex [set $hltOpt] end]
                    }
                }
            }
    
            # Apply configurations
            set result [ixNetworkNodeSetAttr $protocol_objref $mld_protocol_args \
                    -commit]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList log "Failure in ixnetwork_mld_config:\
                        encountered an error while executing: \
                        ixNetworkNodeSetAttr $protocol_objref $mld_protocol_args\
                        - [keylget result log]"
                keylset returnList status $::FAILURE
                return $returnList
            }
    
            ## Interfaces
            if {[catch {ixNet getAttribute $objref -interfaces} intf_objref]} {
                set intf_objref [ixNet getAttribute $objref -protocolInterface]
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
                        
                        set protocol_intf_options_1 "                              \
                                -atm_encapsulation      atm_encapsulation          \
                                -atm_vci                vci                        \
                                -atm_vpi                vpi                        \
                                -ipv6_address           intf_ip_addr               \
                                -ipv6_prefix_length     intf_prefix_len            \
                                -ipv6_gateway           neighbor_intf_ip_addr      \
                                -ipv6_gateway_step      neighbor_intf_ip_addr_step \
                                -mac_address            mac_address_init           \
                                -vlan_enabled           vlan                       \
                                -vlan_id                vlan_id                    \
                                -vlan_user_priority     vlan_user_priority         \
                                "
                        # Options that will always exist
                        set protocol_intf_options_2 "                           \
                                -port_handle            port_handle             \
                                -prot_intf_objref       intf_objref             \
                                "
                    }
                }
    
                # Passed in only those options that exists
                set protocol_intf_opt_exist 0
                set protocol_intf_args ""
                foreach {option value_name} $protocol_intf_options_1 {
                    if {[info exists $value_name]} {
                        if {[lindex [set $value_name] $index] != {}} {
                            append protocol_intf_args " $option [lindex [set $value_name] $index]"
                        } else {
                            append protocol_intf_args " $option [lindex [set $value_name] end]"
                        }
                    }
                }
                if {$protocol_intf_args != ""} {
                    set protocol_intf_opt_exist 1
                }
                foreach {option value_name} $protocol_intf_options_2 {
                    if {[info exists $value_name]} {
                        if {[lindex [set $value_name] $index] != {}} {
                            append protocol_intf_args " $option [lindex [set $value_name] $index]"
                        } else {
                            append protocol_intf_args " $option [lindex [set $value_name] end]"
                        }
                    }
                }
                # (Re)configure interfaces
                if {$protocol_intf_opt_exist} {
                    set intf_list ""
                    switch -- $intf_type {
                        default {
                            set intf_list [eval ixNetworkConnectedIntfCfg \
                                    $protocol_intf_args]
                        }
                    }
        
                    if {[keylget intf_list status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to modify the IPv6\
                                configuration from the $intf_objref interface -\
                                [keylget intf_list log]."
                        return $returnList
                    }
                    if {[catch {ixNet commit} err_msg]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Unable to commit the IPv6\
                            configuration modifications from the $intf_objref\
                            interface - $err_msg."
                        return $returnList
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
    
            # Start creating list of static MLD router options
            set mld_host_static_args [list -enabled true]
    
            # The -mld_version attribute must not be modified
            if {$mode == "modify" && [info exists mld_version]} {
                unset mld_version
            }
    
            # List of static (non-incrementing) options for MLD host
            set staticMldHostOptions {
                general_query               enableQueryResMode      truth
                group_query                 enableSpecificResMode   truth
                mld_version                 version	            translate
                immediate_response          enableImmediateResp     truth
                ip_router_alert             enableRouterAlert       truth
                suppress_report             enableSuppressReport    truth
                robustness                  robustnessVariable      value
            }
            
            # Check MLD host options existence and append parameters that exist
            foreach {hltOpt ixnOpt optType} $staticMldHostOptions {
                if {[info exists $hltOpt]} {
                    if {[lindex [set $hltOpt] $index] != {}} {
                        switch $optType {
                            translate {
                                lappend mld_host_static_args -$ixnOpt \
                                        $translate_${hltOpt}([set \
                                        [lindex [set $hltOpt] $index]])
                            }
                            truth {
                                lappend mld_host_static_args -$ixnOpt \
                                        $truth([lindex [set $hltOpt] $index])
                            }
                            value {
                                lappend mld_host_static_args -$ixnOpt \
                                        [lindex [set $hltOpt] $index]
                            }
                        }
                    } else {
                        switch $optType {
                            translate {
                                lappend mld_host_static_args -$ixnOpt \
                                        $translate_${hltOpt}([set \
                                        [lindex [set $hltOpt] end]])
                            }
                            truth {
                                lappend mld_host_static_args -$ixnOpt \
                                        $truth([lindex [set $hltOpt] end])
                            }
                            value {
                                lappend mld_host_static_args -$ixnOpt \
                                        [lindex [set $hltOpt] end]
                            }
                        }
                    }
                }
            }

            # Particular static (non-incrementing) options for MLD host
            if {[info exists unsolicited_report_interval]} {
                lappend mld_host_static_args -upResponseMode true
                lappend mld_host_static_args -reportFreq \
                        $unsolicited_report_interval
            }
    
            ## Host(s) modification
            # Apply modified configurations
            set result [ixNetworkNodeSetAttr $objref $mld_host_static_args \
                    -commit]
            if {[keylget result status] == $::FAILURE} {
                keylset returnList log "Failure in ixnetwork_mld_config:\
                        encountered an error while executing: \
                        ixNetworkNodeSetAttr $objref $mld_host_static_args\
                        - [keylget result log]"
                keylset returnList status $::FAILURE
                return $returnList
            }
    
            # Add to array the attributes to be passed to the
            # ::ixia::ixnetwork_mld_group_config procedure
            set remote_args_list [list      \
                    enable_packing          \
                    filter_mode             \
                    max_groups_per_pkts     \
                    max_sources_per_group   \
                    ]
    
            # Array of group range attributes
            array set group_attributes [list                    \
                    enable_packing          enablePacking       \
                    filter_mode             sourceMode          \
                    max_groups_per_pkts     recordsPerFrame     \
                    max_sources_per_group   sourcesPerRecord    \
                    ]
    
            # List of MLD group range options
            set mld_group_attr [list]
    
            # Check MLD group range options existence and append parameters that exist
            foreach arg $remote_args_list {
                if {[info exists $arg]} {
                    if {[lindex [set $arg] $index] != {}} {
                        set mld_attributes_array($objref,$arg) [lindex [set $arg] $index]
                        lappend mld_group_attr -$group_attributes($arg) [lindex [set $arg] $index]
                    } else {
                        set mld_attributes_array($objref,$arg) [lindex [set $arg] end]
                        lappend mld_group_attr -$group_attributes($arg) [lindex [set $arg] end]
                    }
                }
            }
    
            # Update existing group ranges
            set group_list [ixNetworkNodeGetList $objref groupRange -all]
            if {$group_list != [ixNet getNull]} {
                foreach group_objref $group_list {
                    set result [ixNetworkNodeSetAttr $group_objref \
                            $mld_group_attr]
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList log "Failure in\
                                ixnetwork_mld_config: encountered an error\
                                while executing: ixNetworkNodeSetAttr\
                                $group_objref $mld_group_attr\
                                - [keylget result log]"
                        keylset returnList status $::FAILURE
                        return $returnList
                    }
                }
                if {[catch {ixNet commit} err_msg]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Unable to commit the\
                        modifications for the group ranges of the $objref\
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


proc ::ixia::ixnetwork_mld_control { args man_args opt_args } {
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    keylset returnList status $::SUCCESS

    if {![info exists port_handle] && ![info exists handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Neither 'port_handle' nor 'handle'\
                options have been specified. Please specify at least one of\
                the 'port_handle' or 'handle' options."
        return $returnList
    }
    array set protocol_objref_array [list]
    if {[info exists port_handle]} {
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
                set protocol_objref_array([keylget result vport_objref]/protocols/mld) true
            }
        }
    }
    if {[info exists handle]} {
        foreach item $handle {
            set found [regexp {(.*mld)/host:\d+} $item {} found_protocol_objref]
            if {$found} {
                set protocol_objref_array($found_protocol_objref) true
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to get the MLD protocol\
                        object reference out of the handle received as input:\
                        $item"
                return $returnList
            }
        }
    }
    set protocol_objref_list [array names protocol_objref_array]

    # Check link state
    after 10000
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
            keylset returnList log "Failed to start MLD on the $vport_objref\
                    port. Port state is $portState, $portStateD."
            return $returnList
        }
    }

    switch -exact $mode {
        restart {
            foreach protocol_objref $protocol_objref_list {
                if {[catch {ixNet exec stop $protocol_objref} retCode] || \
                        ([string first "::ixNet::OK" $retCode] == -1)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to start MLD on the\
                            $vport_objref port. Error code: $retCode."
                    return $returnList
                }
                after 1000
                if {[catch {ixNetworkExec [list start $protocol_objref]} retCode] || \
                        ([string first "::ixNet::OK" $retCode] == -1)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to start MLD on the\
                            $vport_objref port. Error code: $retCode."
                    return $returnList
                }
            }
            after 1000
        }
        start {
            foreach protocol_objref $protocol_objref_list {
                if {[catch {ixNetworkExec [list start $protocol_objref]} retCode] || \
                        ([string first "::ixNet::OK" $retCode] == -1)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to start MLD on the\
                            $vport_objref port. Error code: $retCode."
                    return $returnList
                }
            }
            after 1000
        }
        stop {
            foreach protocol_objref $protocol_objref_list {
                if {[catch {ixNet exec stop $protocol_objref} retCode] || \
                        ([string first "::ixNet::OK" $retCode] == -1)} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to start MLD on the\
                            $vport_objref port. Error code: $retCode."
                    return $returnList
                }
            }
            after 1000
        }
        default {
            if {$mode == "join"} {
                set enable_state true
            } elseif {$mode == "leave"} {
                set enable_state false
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "Unknown mode: '$mode'. Please use \
                        'start' or 'stop' when using MLD with IxNetwork."
                return $returnList
            }
            if {[info exists handle]} {
                foreach item $handle {
                    if {[catch {
                        debug "ixNet getL $item groupRange"
                        set group_range_list [ixNet getL $item groupRange]
                    } errorMsg]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Value of -handle is corrupted.$errorMsg"
                        return $returnList
                    }
                    foreach group_range $group_range_list {
                        debug "ixNet setAttr $group_range -enabled $enable_state"
                        ixNet setAttr $group_range -enabled $enable_state
                    }
                }
            } elseif {[info exists group_member_handle]} {

                foreach group_member $group_member_handle {
                    if {[catch {
                        if {([ixNet exists $group_member] == "true" || [ixNet exists $group_member] == 1) && [regexp\
                                "::ixNet::OBJ-/vport:\\d+/protocols/mld/host:\\d+/groupRange:\\d+"\
                                $group_member]} {
                            debug "ixNet setAttr $group_member -enabled $enable_state"
                            ixNet setAttr $group_member -enabled $enable_state
                        } else {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Wrong -group_member_handle specified."
                            return $returnList
                        }
                    } errorMsg]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Wrong -group_member_handle specified.$errorMsg"
                        return $returnList
                    }
                }
            } elseif {[info exists port_handle]} {
                set result [::ixia::ixNetworkGetPortObjref $port_handle]
                if {[keylget result status] == $::FAILURE} {
                    return $result
                }
                debug "ixNet getL [keylget result vport_objref]/protocols/mld host"
                set host_list [ixNet getL [keylget result vport_objref]/protocols/mld host]
                foreach host $host_list {
                    debug "ixNet getL $host groupRange"
                    set group_range_list [ixNet getL $host groupRange]
                    foreach group_range $group_range_list {
                        debug "ixNet setAttr $group_range -enabled $enable_state"
                        ixNet setAttr $group_range -enabled $enable_state
                    }
                }
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "One of -port_handle,\
                        -group_member_handle, -handle must be specified when\
                        -mode is $mode"
                return $returnList
            }
            if {[catch {ixNet commit} errorMsg]} {
                keylset returnList status $::FAILURE
                keylset returnList log $errorMsg
                return $returnList
            }
        }
    }

    return $returnList
}


proc ::ixia::ixnetwork_mld_group_config { args man_args opt_args } {
    variable objectMaxCount
    variable truth
    variable multicast_group_array
    variable multicast_source_array
    variable mld_attributes_array

    set objectCount 0

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    keylset returnList status $::SUCCESS
    array set translate_g_filter_mode [list   \
            include             include     \
            exclude             exclude     \
            ]

    array set translate_filter_mode [list   \
            include             include     \
            exclude             exclude     \
            ]

    # Verify conditions for getting started
    # For delete we need a -handle argument
    if {$mode == "delete"} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode, you must provide one\
                    argument for -handle."
            return $returnList
        }
        
    }
    # For create and clear_all we need -session_handle argument
    if {$mode == "create" || ($mode == "clear_all")} {
        if {![info exists session_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "If -mode is $mode you must provide one\
                    argument for -session_handle."
            return $returnList
        } elseif {[llength $session_handle] > 1}  {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode, -session_handle may\
                    only contain one value."
            return $returnList
            
        }
    }
    # For create you also need a -group_pool_handle argument
    if {$mode == "create"} {
        if {![info exists group_pool_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "If -mode is $mode you must provide one\
                    argument for -group_pool_handle."
            return $returnList
        } elseif {[llength $group_pool_handle] > 1} {
            keylset returnList status $::FAILURE
            keylset returnList log "If -mode is $mode -group_pool_handle may\
                    only contain one value."
            return $returnList
        }
    }
    if {$mode == "create" || $mode == "modify"} {
        if {[catch {
            if {![::ipv6::isValidAddress\
                    $multicast_group_array($group_pool_handle,ip_addr_start)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid group_pool_handle. Addresses\
                        should be IPv6."
            }
        } errorMsg]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Invalid group_pool_handle. Specified value\
                    not defined."
        }
        if {[keylget returnList status] == $::FAILURE} {
            return $returnList
        }
        if {[info exists source_pool_handle]} {
            foreach pool_handle $source_pool_handle {
                if {[catch {
                    if {![::ipv6::isValidAddress\
                            $multicast_source_array($pool_handle,ip_addr_start)]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Wrong ip start in source_pool_handle."
                    }
                }]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Wrong source_pool_handle specified."
                }
                if {[keylget returnList status] == $::FAILURE} {
                    return $returnList
                }
            }
        }
    }
    # For modify you also need a -handle and
    # a -group_pool_handle single argument or a -source_pool_handle
    if {$mode == "modify"} {
        # Remove defaults
        removeDefaultOptionVars $opt_args $args

        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode, you must provide one\
                    argument for -handle."
            return $returnList
        } elseif {[llength $handle] > 1} {
            keylset returnList status $::FAILURE
            keylset returnList log "When -mode is $mode, -handle may only\
                    contain one value."
            return $returnList
        }
        if {![info exists group_pool_handle] && \
                ![info exists source_pool_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "If -mode is $mode you must provide one\
                    argument for -group_pool_handle or -source_pool_handle."
            return $returnList
        } elseif {[info exists group_pool_handle]} {
            if {[llength $group_pool_handle] > 1} {
                keylset returnList status $::FAILURE
                keylset returnList log "If -mode is $mode -group_pool_handle\
                        may only contain one value."
                return $returnList
            }
        }
    }
    
    if {$mode == "delete"} {
        foreach objref $handle {
            if {[ixNet exists $objref] == "true" || [ixNet exists $objref] == 1} {
                ixNet remove $objref
            }
        }
        ixNet commit
    }

    if {$mode == "clear_all"} {
        set groups_range_list [ixNet getList $session_handle groupRange]
        foreach group_range $groups_range_list {
            ixNet remove $group_range
        }
        ixNet commit
    }

    if {$mode == "create" || $mode == "modify"} {
        if {$mode == "create"} {
            # Resetting everything makes sense only with -mode create
            if {[info exists reset]} {
                set result [ixNetworkNodeRemoveList $session_handle \
                        { {child remove groupRange} {} } -commit]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not reset the $session_handle\
                            MLD host - [keylget result log]."
                    return $returnList
                }
            }
            set handle $session_handle
        }

        if {$mode == "modify"} {
            keylset returnList handle $handle
        }

        if {[info exists group_pool_handle]} {
            # Prepare MLD group range options variables
            if {![info exists multicast_group_array($group_pool_handle,ip_addr_start)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "The '$group_pool_handle' group range\
                        pool handle is invalid."
                return $returnList
            }
            set ip_addr_start \
                    $multicast_group_array($group_pool_handle,ip_addr_start)
            if {[::ipv6::isValidAddress $ip_addr_start]} {
                set ip_addr_start [expand_ipv6_addr $ip_addr_start]
            }
            set increment_step \
                    $multicast_group_array($group_pool_handle,ip_addr_step)
            if {[::ipv6::isValidAddress $increment_step]} {
                set increment_step [expand_ipv6_addr $increment_step]
            }
            set increment_step \
                    [::ixia::ip_addr_to_num $increment_step]
            if {[mpexpr $increment_step > 4294967295]} {
                keylset returnList status $::FAILURE
                keylset returnList log "The step specified for the multicast\
                        group is too large for MLD group configuration.\
                        Please provide a step within the following range:\
                        0-4294967295, or the corresponding IP address."
                return $returnList
            }
            
            set num_groups \
                    $multicast_group_array($group_pool_handle,num_groups)
            if {$mode == "modify"} {
                set found [regexp {(.*host:\d+)/groupRange:\d+} $handle {} \
                        session_handle]
                if {!$found} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to get the MLD host\
                            object reference out of the handle received as\
                            input: $handle"
                    return $returnList
                }
            }
            if {[ixNet getAttribute $session_handle -version] != "version2" && \
                    [info exists filter_mode]} {
                unset filter_mode
            }

            # Start creating list of static MLD groupRange options
            set mld_group_args [list -enabled true]
            
            # List of global options for MLD
            set staticMldGroupOptions [list                                                                         \
                    {enable_packing        g_enable_packing}        enablePacking       truth       {remote local}  \
                    {filter_mode           g_filter_mode}           sourceMode          translate   {remote local}  \
                    ip_addr_start                                   groupIpFrom         default     local           \
                    increment_step                                  incrementStep       default     local           \
                    {max_groups_per_pkts   g_max_groups_per_pkts}   recordsPerFrame     default     {remote local}  \
                    {max_sources_per_group g_max_sources_per_group} sourcesPerRecord    default     {remote local}  \
                    num_groups                                      groupCount          default     local           \
                    ]

            # Check MLD group options existence and append parameters 
            # that exist
            foreach {hltOpts ixnOpt optType srcTypes} $staticMldGroupOptions {
                foreach hltOpt $hltOpts srcType $srcTypes {
                    if {$srcType == "remote"} {
                        if {[info exists mld_attributes_array($handle,$hltOpt)]} {
                            set $hltOpt $mld_attributes_array($handle,$hltOpt)
                        }
                    }
                    if {[info exists $hltOpt]} {
                        switch $optType {
                            translate {
                                lappend mld_group_args -$ixnOpt \
                                        [set translate_${hltOpt}([set $hltOpt])]
                            }
                            truth {
                                lappend mld_group_args -$ixnOpt \
                                        $truth([set $hltOpt])
                            }
                            default {
                                lappend mld_group_args -$ixnOpt \
                                        [set $hltOpt]
                            }
                        }
                    }
                }
            }

            if {$mode == "create"} {
                # Create groupRange
                set result [ixNetworkNodeAdd $session_handle groupRange \
                        $mld_group_args -commit]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not add a new group range to\
                            the following MLD host object reference:\
                            $session_handle - [keylget result log]."
                    return $returnList
                }
                set group_handle [keylget result node_objref]
                set group_handle [ixNet remapIds $group_handle]
                if {![info exists source_pool_handle]} {
                    set source_pool_handle [list]
                }
                keylset returnList handle $group_handle
                keylset returnList group_pool_handle $group_pool_handle
                keylset returnList source_pool_handles $source_pool_handle
            } else {
                # Apply configurations
                set result [ixNetworkNodeSetAttr $handle $mld_group_args \
                        -commit]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList log "Failure in ixnetwork_mld_config:\
                            encountered an error while executing: \
                            ixNetworkNodeSetAttr $handle $mld_group_args\
                            - [keylget result log]"
                    keylset returnList status $::FAILURE
                    return $returnList
                }
            }
        }

        # Add MLDv2 source group ranges
        if {[info exists source_pool_handle]} {
            if {$mode == "modify"} {
                # Remove all source ranges from the group range specified using 
                # the -handle attribute
                set result [ixNetworkNodeRemoveList $handle \
                        { {child remove sourceRange} {} } -commit]
                if {[keylget result status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Could not reset the $handle\
                            MLD group range - [keylget result log]."
                    return $returnList
                }
                set group_handle $handle
            }

            foreach pool_handle $source_pool_handle {
                if {![info exists multicast_source_array($pool_handle,ip_addr_start)]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "The '$pool_handle' source range\
                            pool handle is invalid."
                    if {[info exists group_handle]} {
                        ixNet remove $group_handle
                        ixNet commit
                    }
                    return $returnList
                }
                if {![::ipv6::isValidAddress $multicast_source_array($pool_handle,ip_addr_start)] || \
                        ![::ipv6::isValidAddress $multicast_source_array($pool_handle,ip_addr_step)]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid IPv6 address \
                            ($multicast_source_array($pool_handle,ip_addr_start))\
                            or step ($multicast_source_array($pool_handle,ip_addr_step))\
                            for the multicast source."
                    if {[info exists group_handle]} {
                        ixNet remove $group_handle
                        ixNet commit
                    }
                    return $returnList
                }
                # Prepare MLDv2 source range options variables
                set src_ip_addr_start [expand_ipv6_addr $multicast_source_array($pool_handle,ip_addr_start)]
                set src_ip_addr_step  [expand_ipv6_addr $multicast_source_array($pool_handle,ip_addr_step)]
                if {[ip_addr_to_num $src_ip_addr_step] == 1} {
                    set src_count       $multicast_source_array($pool_handle,num_sources)
                    set src_range_count 1
                } else {
                    set src_count       1
                    set src_range_count $multicast_source_array($pool_handle,num_sources)
                }
                # List of global options for MLDv2
                set staticMldSourceRangeOptions {
                    src_ip_addr_start   ipFrom
                    src_count           count
                }

                for {set iii 0} {$iii < $src_range_count} {incr iii} {
                    # Start creating list of static MLDv2 group range options
                    set mld_source_range_args [list]
                    # Check MLDv2 source range options existence and append 
                    # parameters that exist
                    foreach {hltOpt ixnOpt} $staticMldSourceRangeOptions {
                        if {[info exists $hltOpt]} {
                            lappend mld_source_range_args -$ixnOpt [set $hltOpt]
                        }
                    }
    
                    # Create source range
                    set result [ixNetworkNodeAdd $group_handle sourceRange \
                            $mld_source_range_args]
                    if {[keylget result status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Could not add a new source range to\
                                the following MLDv2 group range object reference:\
                                $group_handle - [keylget result log]."
                        return $returnList
                    }
    
                    # Commit
                    incr objectCount
                    if { $objectCount == $objectMaxCount} {
                        ixNet commit
                        set objectCount 0
                    }
                    set src_ip_addr_start  [incr_ipv6_addr $src_ip_addr_start $src_ip_addr_step]
                }
            }
        }

        # Commit
        if {$objectCount > 0} {
            ixNet commit
        }
    }

    return $returnList
}


proc ::ixia::ixnetwork_mld_info { args opt_args } {
    variable truth

    if {[catch {::ixia::parse_dashed_args -args $args -optional_args \
            $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing. $parse_error"
        return $returnList
    }

    set return_status [ixNetworkGetPortObjref $port_handle]
    if {[keylget return_status status] == $::FAILURE} {
        keylset returnList status $::FAILURE
        keylset returnList log "The '$port_handle' port has not been added to\
                HLT. - [keylget return_status log]"
        return $returnList
    }

    keylset returnList status $::SUCCESS
    
    if {$mode == "aggregate"} {
        set stat_views_list [list]
        set stat_view_stats_list [list]
        set stat_view_arrays_list [list]

        lappend stat_views_list "MLD Aggregated Statistics"

        set stats_list [list                                    \
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
        lappend stat_view_stats_list $stats_list

        set stats_array [list                                   \
                "Host v1 Membership Rpts. Rx"                   \
                        rprt_v1_rx                              \
                "Host v2 Membership Rpts. Rx"                   \
                        rprt_v2_rx                              \
                "v1 Membership Rpts. Tx"                        \
                        rprt_v1_tx                              \
                "v2 Membership Rpts. Tx"                        \
                        rprt_v2_tx                              \
                "v3 Membership Rpts. Tx"                        \
                        rprt_v3_tx                              \
                "v2 Leave Tx"                                   \
                        leave_v2_tx                             \
                "Host Total Frames Tx"                          \
                        total_tx                                \
                "Host Total Frames Rx"                          \
                        total_rx                                \
                "Host Invalid Packets Rx"                       \
                        invalid_rx                              \
                "General Queries Rx"                            \
                        gen_query_rx                            \
                "Grp. Specific Queries Rx"                      \
                        grp_query_rx                            \
                "v3 Grp. & Src. Specific Queries Rx"            \
                        rprt_v3_rx                              \
                ]
        lappend stat_view_arrays_list $stats_array

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

            set returned_stats_list [ixNetworkGetStats \
                    $stat_view_name $stats_list]
            if {[keylget returned_stats_list status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Unable to read the\
                        '$stat_view_name' stat view browser -\
                        [keylget returned_stats_list log]"
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
                                    $handle.mld.aggregate.$stats_hash($stat) \
                                    $rows_array($i,$stat)
                        } else {
                            keylset returnList \
                                    $handle.mld.aggregate.$stats_hash($stat) \
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

    return $returnList
}
