
proc ::ixia::ixnetwork_stp_bridge_config { args opt_args } {
    # global variable initialization
    variable objectMaxCount
    variable ixnetwork_port_handles_array
    
    set objectCount 0

    if {[catch {::ixia::parse_dashed_args \
            -args           $args         \
            -optional_args  $opt_args     \
            } parseError]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$parseError."
        return $returnList
    }
    
    if {([lsearch $optional_args "-vlan_id"] != -1) &&\
            ([lsearch $optional_args "-vlan"] == -1) &&\
            ($mode == "create")} {
        set vlan 1
    } 

    set retCode [checkIxNetwork]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to connect to IxNetwork - \
                [keylget retCode log]"
        return $returnList
    }
    
    set retCode [stpBridgeDependencies]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log [keylget retCode log]
        return $returnList
    }
    
    # Convert mac address for ixNetwork
    foreach mac_it {bridge_mac cist_external_root_mac cist_reg_root_mac\
            cst_root_mac_address mac_address_bridge_step mac_address_init\
            mac_address_intf_step root_mac bridge_mac_step} {
        if {[info exists $mac_it]} {
            set mac_value [set $mac_it]
            if {[catch {
                set $mac_it [ixia::ixNetworkFormatMac $mac_value]
            } errorMessage]} {
                keylset returnList status $::FAILURE
                keylset returnList log "$errorMessage"
                return $returnList
            }
        }
    }
    # expand ipv6 address
    foreach ipv6_param {intf_ipv6_addr intf_ipv6_addr_step\
            intf_ipv6_addr_bridge_step} {
        if {[info exists $ipv6_param]} {
            set $ipv6_param [ipv6::expandAddress [set $ipv6_param]]
        }
    }
    
    # Setting parameters list for mode create/modify
    if {$mode == "create" || $mode == "modify"} {
        array set link_type_array {
            point_to_point      pointToPoint
            shared              shared
        }
    
        set stpBridgeInterfaceList {
            -autoPick           auto_pick_port          value
            -bdpuGap            inter_bdpu_gap          value
            -cost               intf_cost               value
            -interfaceId        interface_id            value
            -jitterEnabled      enable_jitter           value
            -jitterPercentage   jitter_percentage       value
            -linkType           link_type               array
            -mstiOrVlanId       bridge_msti_vlan        value
            -portNo             port_no                 value
            -pvid               pvid                    value
        }
    
        set stpBridgeCommonAttrList {
            -autoPickBridgeMac   auto_pick_bridge_mac   bool
            -mode                bridge_mode            value
            -bridgeMac           bridge_mac             mac
            -bridgePriority      bridge_priority        value
            -forwardDelay        forward_delay          value
            -helloInterval       hello_interval         value
            -maxAge              max_age                value
            -messageAge          message_age            value
            -portPriority        port_priority          value
        }
        
        set stpBridgeRstpAttrList {
            -bridgeSystemId      bridge_system_id       value
            -rootCost            root_cost              value
            -rootMac             root_mac               mac
            -rootPriority        root_priority          value
            -rootSystemId        root_system_id         value
        }
        
        set stpBridgeMstpAttrList {
            -cistRegRootCost         cist_reg_root_cost          value
            -cistRegRootMac          cist_reg_root_mac           mac
            -cistRegRootPriority     cist_reg_root_priority      enum
            -cistRemainingHop        cist_remaining_hop          value
            -externalRootCost        cist_external_root_cost     value
            -externalRootMac         cist_external_root_mac      mac
            -externalRootPriority    cist_external_root_priority enum
            -mstcName                mstc_name                   value
            -mstcRevisionNumber      mstc_revision               value
            -mstpEnable
        }
        
        set stpBridgePvstRpvstList {
            -vlanPortPriority           cst_vlan_port_priority  value
            -vlanRootMac                cst_root_mac_address    mac
            -vlanRootPathCost           cst_root_path_cost      value
            -vlanRootPriority           cst_root_priority       value
        }
        if {$bridge_msti_vlan == "all"} {
            set bridge_msti_vlan ::ixNet::OBJ-/vport/protocols/stp/bridge/all
        } elseif {$bridge_msti_vlan == "none"} {
            set bridge_msti_vlan [ixNet getNull]
        }
    }
    
    # Set parameters lists to be set for create or modify mode
    if {$mode == "create"} {
        if {[catch {set port_obj\
                $ixnetwork_port_handles_array($port_handle)} errorMsg]} {
            keylset returnList log $errorMsg
            keylset returnList status $::FAILURE
            return $returnList
        }
        if {[info exists reset]} {
            set stp_bridge_list [ixNet getList $port_obj/protocols/stp bridge]
            foreach bridge_objref $stp_bridge_list {
                ixNet remove $bridge_objref
            }
            ixNet commit
        }
        # Configure interfaces
        set all_bridge_interface_handles [list]
        if {[info exists interface_handle]} {
            if {[llength $interface_handle] != [expr $intf_count * $count]} {
                keylset returnList status $::FAILURE
                keylset returnList log "The length of the interface_handle\
                        list, must be equal to count * intf_count =\
                        [expr $count * $intf_count] elements."
                return $returnList
            }
            for {set i 0} {$i < $count} {incr i} {
                set intf_list [list]
                for {set j 0} {$j < $intf_count} {incr j} {
                    lappend intf_list [lindex $interface_handle [expr $i * ($count - 1) + $j]]
                }
                lappend all_bridge_interface_handles $intf_list
            }
        } else {
            # interface parameters for create
            set intfParamsList {
                -port_handle                    port_handle
                -count                          intf_count
                -gateway_address                intf_gw_ip_addr
                -gateway_address_step           intf_gw_ip_addr_step
                -ipv4_address                   intf_ip_addr
                -ipv4_prefix_length             intf_ip_prefix_length
                -ipv4_address_step              intf_ip_addr_step
                -ipv6_address                   intf_ipv6_addr
                -ipv6_prefix_length             intf_ipv6_prefix_length
                -ipv6_address_step              intf_ipv6_addr_step
                -mac_address                    mac_address_init
                -mac_address_step               mac_address_intf_step
                -mtu                            mtu
                -vlan_enabled                   vlan
                -vlan_id                        vlan_id
                -vlan_id_mode                   vlan_id_mode
                -vlan_id_step                   vlan_id_intf_step
                -vlan_user_priority             vlan_user_priority
                 NA                             vlan_user_priority_intf_step
                -override_existence_check       override_existence_check
                -override_tracking              override_tracking
            }
            # configure vlan mode
            if {$vlan} {
                if {[lmatch -regexp [split $vlan_id_intf_step ,] "\[1-9\]+"] != ""} {
                    set vlan_id_mode increment
                } else {
                    set vlan_id_mode fixed
                }
            }
            for {set i 0} {$i < $count} {incr i} {
                set intf_args "ixNetworkProtocolIntfCfg"
                foreach {intf_param hlt_param} $intfParamsList {
                    if {[info exists $hlt_param] &&\
                            [string compare $intf_param "NA"] != 0} {
                        set value [set $hlt_param]
                        append intf_args " $intf_param $value"
                    }
                }
                if {[catch {set intfRetList [eval $intf_args]} errorMsg]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "$errorMsg"
                    return $returnList
                }
                if {[keylget intfRetList status] != $::SUCCESS} {
                    return $intfRetList
                }
                lappend all_bridge_interface_handles\
                        [keylget intfRetList connected_interfaces]
                # increment between bridges
                set mac_address_init [incrementMacAdd $mac_address_init\
                        $mac_address_bridge_step]
                set mac_address_init [join $mac_address_init :]
                if {$vlan} {
                    set vlan_user_priority [incrList $vlan_user_priority\
                            $vlan_user_priority_bridge_step 0 7]
                    set vlan_id [incrList $vlan_id $vlan_id_bridge_step]
                }
                if {[info exists intf_ip_addr]} {
                    set intf_ip_addr [incr_ipv4_addr\
                            $intf_ip_addr $intf_ip_addr_bridge_step]
                }
                if {[info exists intf_gw_ip_addr]} {
                    set intf_gw_ip_addr [incr_ipv4_addr\
                            $intf_gw_ip_addr $intf_gw_ip_addr_bridge_step]
                }
                if {[info exists intf_ipv6_addr]} {
                    set intf_ipv6_addr [incr_ipv6_addr\
                            $intf_ipv6_addr $intf_ipv6_addr_bridge_step]
                }
            }
        }
        # create parameter list to be set for current bridge type
        set stp_bridge_all_attr $stpBridgeCommonAttrList
        switch $bridge_mode {
            stp -
            rstp {
                append stp_bridge_all_attr " $stpBridgeRstpAttrList"
            }
            mstp {
                append stp_bridge_all_attr " $stpBridgeMstpAttrList"
            }
            pvst -
            rpvst - 
            pvstp {
                append stp_bridge_all_attr " $stpBridgePvstRpvstList"
            }
        }
        # enable stp on specified port
        ixNet setAttr $port_obj/protocols/stp -enabled true
        # set interface_id to be added in command list
        set interface_id 0
        # prepare command for bridge nodes creation
        set br_cmnd_list "ixNetworkNodeAdd $port_obj/protocols/stp bridge {-enabled true"
        foreach {ixn hlt type} $stp_bridge_all_attr {
            if {[info exists $hlt]} {
                # we add $<hlt var> because there are variable which will be
                # changed when nodes are created. subst will be used later
                if {$type == "array"} {
                    set value "\$[set hlt]_array([set $hlt])"
                } else {
                    set value "\$$hlt"
                }
                append br_cmnd_list " $ixn $value"
            }
        
        }
        append br_cmnd_list "}"
        # prepare command for stp interfaces creation
        set br_intf_cmnd_list "ixNetworkNodeAdd \$bridge_obj interface {-enabled true"
        foreach {ixn hlt type} $stpBridgeInterfaceList {
            if {[info exists $hlt]} {
                if {$type == "array"} {
                    set value "\$[set hlt]_array([set $hlt])"
                } else {
                    set value "\$$hlt"
                }
                append br_intf_cmnd_list " $ixn $value"
            }
        }
        append br_intf_cmnd_list "}"
        # initialize variables which will contain return values
        set bridge_handles [list]
        array set bridge_interface_array {}
        array set interface_array {}
        set objectCount 0
        foreach per_bridge_interface_handles $all_bridge_interface_handles {
            # we need this value saved for increment section
            set first_port_no $port_no
            # bridge creation
            if {[catch {set br_ret_code [eval [subst $br_cmnd_list]]}\
                    errorMsg]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Error on bridge creation: $errorMsg"
                return $returnList
            }
            if {[keylget br_ret_code status] != $::SUCCESS} {
                return $br_ret_code
            }
            set bridge_obj [keylget br_ret_code node_objref]
            if {$objectCount >= $objectMaxCount} {
                ixNet commit
                # if commit we must make remapIds because we cannot add 
                # interface on temporary objref. 
                set bridge_obj [ixNet remapIds $bridge_obj]
                set objectCount 0
            } else {
                incr objectCount
            }
            lappend bridge_handles $bridge_obj
            set interface_array($bridge_obj) $per_bridge_interface_handles
            # create and assign STP interfaces
            # interface_id is parameter which will be associated in subst call
            foreach interface_id $per_bridge_interface_handles {                
                if {[catch {set br_ret_code [eval [subst $br_intf_cmnd_list]]}\
                        errorMsg]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Error on bridge intf: $errorMsg"
                    return $returnList
                }
                if {[keylget br_ret_code status] != $::SUCCESS} {
                    return $br_ret_code
                }
                lappend bridge_interface_array($bridge_obj) [keylget br_ret_code\
                        node_objref]
                if {$objectCount >= $objectMaxCount} {
                    ixNet commit
                    set objectCount 0
                } else {
                    incr objectCount
                }
                # interface increment section
                incr port_no $port_no_intf_step
            }
            # set port_no to first value from the bridge - prepare to increment 
            # between bridges
            set port_no $first_port_no
            # bridge increment section
            incr port_no $port_no_bridge_step
            set bridge_mac [::ixia::incrementMacAdd $bridge_mac $bridge_mac_step]
            # convert from IxOS MAC format to ixNetwork format
            set bridge_mac [join $bridge_mac :]
        }
        if {$objectCount > 0} {
            ixNet commit
        }
        # creating return list for mode create
        keylset returnList bridge_handles [ixNet remapIds $bridge_handles]
        foreach tmp_bridge_handle $bridge_handles {
            set bridge_handle [ixNet remapIds $tmp_bridge_handle]
            keylset returnList bridge_interface_handles.$bridge_handle \
                    [ixNet remapIds $bridge_interface_array($tmp_bridge_handle)]
            keylset returnList interface_handles.$bridge_handle \
                    $interface_array($tmp_bridge_handle)
        }
    } elseif {$mode == "modify"} {
        # modify
        # remove default values
        removeDefaultOptionVars $opt_args $args
        foreach handle_item $handle {
            if {[regexp "^::ixNet::OBJ-/vport:\\d+/protocols/stp/bridge:\\d+$"\
                    $handle_item] } {
                set stp_mode [ixNet getAttr $handle_item -mode]
                set all_bridge_parameters $stpBridgeCommonAttrList
                switch -exact $stp_mode {
                    stp -
                    rstp {
                        append all_bridge_parameters " $stpBridgeRstpAttrList"
                    }
                    mstp {
                        append all_bridge_parameters " $stpBridgeMstpAttrList"
                    }
                    pvst -
                    rpvst - 
                    pvstp {
                        append all_bridge_parameters " $stpBridgePvstRpvstList"
                    }
                }
                # configure common bridge parameters
                set stp_bridge_set_attr_cmnd "ixNetworkNodeSetAttr $handle_item {"
                foreach {ixn hlt type} $all_bridge_parameters {
                    if {[info exists $hlt]} {
                        if {$type != "array"} {
                            set value [set $hlt]
                        } else {
                            set var_name "\$[set hlt]_array([set $hlt])"
                            set value [subst $var_name]
                        }
                        append stp_bridge_set_attr_cmnd " $ixn $value"
                    }
                }
                append stp_bridge_set_attr_cmnd "}"
                set retCode [eval $stp_bridge_set_attr_cmnd]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log [keylget retCode log]
                    return $returnList
                }
                set stp_intf_handle_list [ixNet getList $handle_item interface]
            } elseif {[regexp "^::ixNet::OBJ-/vport:\\d+/protocols/stp/bridge:\\d+/interface:\\d+$"\
                    $handle_item] } {
                set stp_intf_handle_list $handle_item
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "invalid handle specified."
                return $returnList
            }
            # prepare command for config STP interface
            set stp_intf_cmnd "ixNetworkNodeSetAttr \$intf_handle {"
            foreach {ixn hlt type} $stpBridgeInterfaceList {
                if {[info exists $hlt]} {
                    if {$type != "array"} {
                        set value [set $hlt]
                    } else {
                        set var_name "\$[set hlt]_array([set $hlt])"
                        set value [subst $var_name]
                    }
                    append stp_intf_cmnd " $ixn $value"
                }
            }
            append stp_intf_cmnd "}"
            # interface parameters for modify
            set intfParamsList {
                -gateway_address                intf_gw_ip_addr
                -ipv4_address                   intf_ip_addr
                -ipv4_prefix_length             intf_ip_prefix_length
                -intf_ipv6_addr                 ipv6_address
                -intf_ipv6_prefix_length        ipv6_prefix_length
                -mac_address                    mac_address_init
                -mtu                            mtu
                -vlan_enabled                   vlan
                -vlan_id                        vlan_id
                -vlan_id_mode                   vlan_id_mode
                -vlan_user_priority             vlan_user_priority
            }
            # prepare interface config command
            set intf_cmnd "ixNetworkConnectedIntfCfg\
                    -port_handle      \$port_handle\
                    -prot_intf_objref \$interface_id"
            foreach {intf_param hlt_param} $intfParamsList {
                if {[info exists $hlt_param] &&\
                        [string compare $intf_param "NA"] != 0} {
                    set value [set $hlt_param]
                    append intf_cmnd " $intf_param $value"
                }
            }
            # configure STP interface parameters
            foreach intf_handle $stp_intf_handle_list {
                # set protocol interface parameters
                if {[catch {set stp_intf_res [eval [subst $stp_intf_cmnd]]} errorMsg]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "$errorMsg"
                    return $returnList
                }
                if {[keylget stp_intf_res status] != $::SUCCESS} {
                    return $stp_intf_res
                }
                # configure interface parameters
                set interface_id [ixNet getAttr $intf_handle -interfaceId]
                set retCode [ixNetworkGetPortFromObj $interface_id]
                if {[keylget retCode status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log [keylget retCode log]
                    return $returnList
                }
                set port_handle [keylget retCode port_handle]
                if {[catch {set intf_ret_list [eval [subst $intf_cmnd]]} errorMsg]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "$errorMsg"
                    return $returnList
                }
                if {[keylget intf_ret_list status] != $::SUCCESS} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ixNetworkConnectedIntfCfg failed"
                    return $returnList
                }
            }
            # end of interfaces config
        }
        ixNet commit

        keylset returnList bridge_handles $handle
    }
    if {$mode == "enable" || $mode == "disable"} {
        array set enable_array {
            enable  true
            disable false
        }
        if [catch {
            foreach handle_item $handle {
                ixNet setAttr $handle_item -enabled $enable_array($mode)
            }
            ixNet commit
        } errorMsg] {
            keylset returnList status $::FAILURE
            keylset returnList log $errorMsg
            return $returnList
        }

        keylset returnList bridge_handles $handle
    }
    if {$mode == "delete"} {
        if [catch {
            foreach handle_item $handle {
                ixNet remove $handle_item
            }
            ixNet commit
        } errorMsg] {
            keylset returnList status $::FAILURE
            keylset returnList log $errorMsg
            return $returnList
        } 

        keylset returnList bridge_handles $handle
    }
    keylset returnList status $::SUCCESS
    return $returnList
}
 
proc ::ixia::ixnetwork_stp_msti_config { args opt_args } {
    # global variable initialization
    variable objectMaxCount
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
    set retCode [stpMstiDependencies]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log [keylget retCode log]
        return $returnList
    }
    if {$mode == "enable" || $mode == "disable"} {
        if {[catch {
            array set enableDisableArray {
                enable  true
                disable false
            }
            foreach handle_item $handle {
                ixNet setAttr $handle_item -enabled $enableDisableArray($mode)
            }
            ixNet commit
        } errorMsg]} {
            keylset returnList status $::FAILURE
            keylset returnList log $errorMsg
            return $returnList
        }

        keylset returnList handle $handle
        keylset returnList status $::SUCCESS
        return $returnList
    }
    if {$mode == "delete"} {
        if {[catch {
            foreach handle_item $handle {
                ixNet remove $handle_item
            }
            ixNet commit
        } errorMsg]} {
            keylset returnList status $::FAILURE
            keylset returnList log $errorMsg
            return $returnList
        }

        keylset returnList handle $handle
        keylset returnList status $::SUCCESS
        return $returnList
    }
    # Modify and create mode
    set msti_mac [ixNetworkFormatMac $msti_mac]
    set mstiParametersList {
        -internalRootPathCost   msti_internal_root_path_cost
        -mac                    msti_mac
        -mstiHops               msti_hops
        -mstiId                 msti_id
        -mstiName               msti_name
        -portPriority           msti_port_priority
        -priority               msti_priority
        -updateRequired         msti_update_required
        -vlanStart              msti_vlan_start
        -vlanStop               msti_vlan_stop
    }
    set mstiIncrementList {
        msti_id             incr                       1  4094
        msti_mac            ::ixia::incrementMacAdd    NA NA
        msti_vlan_start     incr                       1  4094
        msti_vlan_stop      incr                       1  4094
    }
    if {[llength $msti_name] > 1} {
        set msti_name [list $msti_name]
    }
    if {$mode == "create"} {
        set config_cmnd "ixNetworkNodeAdd $bridge_handle msti \{-enabled true"
    } else {
        removeDefaultOptionVars $opt_args $args
        set config_cmnd "ixNetworkNodeSetAttr \$handle_item \{"
    }
    set changes false
    foreach {ixn hlt} $mstiParametersList {
        if {[info exists $hlt]} {
            set changes true
            append config_cmnd " $ixn \$$hlt"
        }
    }
    append config_cmnd "\}"
    set objectCount 0
    if {$mode == "create"} {
        set need_replace_percent $msti_wildcard_percent_enable
        set msti_name_orig $msti_name
        set handle_list [list]
        for {set i 1} {$i <= $count} {incr i} {
            if {$msti_wildcard_percent_enable && $need_replace_percent} {
                set replace_count [regsub -all {%} $msti_name_orig\
                        $msti_wildcard_percent_start tmp_msti_name]
                if {$replace_count > 0} {
                    if {[llength $tmp_msti_name] > 1} {
                        set msti_name [list $tmp_msti_name]
                    } else {
                        set msti_name $tmp_msti_name
                    }
                } else {
                    set need_replace_percent 0
                }
            }
            set retCode [eval [subst $config_cmnd]]
            if {[keylget retCode status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log [keylget retCode log]
                return $returnList
            }
            lappend handle_list [keylget retCode node_objref]
            if {$objectCount < $objectMaxCount} {
                incr objectCount
            } else {
                ixNet commit
                set objectCount 0
            }
            foreach {var incr_cmd min max} $mstiIncrementList {
                if {[info exists $var]} {
                    if {$incr_cmd == "incr"} {
                        incr $var [set ${var}_step]
                        if {[set $var] > $max} {
                            set $var [expr $var - $max + $min]
                        }
                    } else {
                        set $var [$incr_cmd [set $var] [set ${var}_step]]
                    }
                }
            }
            if {$need_replace_percent} {
                incr msti_wildcard_percent_start $msti_wildcard_percent_step
            }
            set msti_mac [join $msti_mac :]
        }
        if {$objectCount > 0} {
            ixNet commit
        }
        keylset returnList handle [ixNet remapIds $handle_list]
    } elseif {$changes} {
        foreach handle_item $handle {
            set retCode [eval [subst $config_cmnd]]
            if {[keylget retCode status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log [keylget retCode log]
                return $returnList
            }
            if {$objectCount < $objectMaxCount} {
                incr objectCount
            } else {
                ixNet commit
                set objectCount 0
            }
        }
        if {$objectCount > 0} {
            ixNet commit
        }

        keylset returnList handle $handle
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::ixnetwork_stp_vlan_config { args opt_args } {
    # global variable initialization
    variable objectMaxCount
    
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
    set retCode [stpVlanDependencies]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log [keylget retCode log]
        return $returnList
    }
    if {$mode == "enable" || $mode == "disable"} {
        if {[catch {
            array set enableDisableArray {
                enable  true
                disable false
            }
            foreach handle_item $handle {
                ixNet setAttr $handle_item -enabled $enableDisableArray($mode)
            }
            ixNet commit
        } errorMsg]} {
            keylset returnList status $::FAILURE
            keylset returnList log $errorMsg
            return $returnList
        }

        keylset returnList handle $handle
        keylset returnList status $::SUCCESS
        return $returnList
    }
    if {$mode == "delete"} {
        if {[catch {
            foreach handle_item $handle {
                ixNet remove $handle_item
            }
            ixNet commit
        } errorMsg]} {
            keylset returnList status $::FAILURE
            keylset returnList log $errorMsg
            return $returnList
        }

        keylset returnList handle $handle
        keylset returnList status $::SUCCESS
        return $returnList
    }
    # Modify and create mode
    set root_mac_address [ixNetworkFormatMac $root_mac_address]
    set vlanParametersList {
        -internalRootPathCost   internal_root_path_cost
        -mac                    root_mac_address
        -portPriority           vlan_port_priority
        -priority               root_priority
        -vlanId                 vlan_id
    }
    set vlanIncrementList {
        root_mac_address       ::ixia::incrementMacAdd    NA NA
        vlan_id                incr                       1  4094
        vlan_port_priority     incr                       0  63
    }
    if {$mode == "create"} {
        set config_cmnd "ixNetworkNodeAdd $bridge_handle vlan \{-enabled true"
    } else {
        removeDefaultOptionVars $opt_args $args
        set config_cmnd "ixNetworkNodeSetAttr \$handle_item \{"
    }
    set changes false
    foreach {ixn hlt} $vlanParametersList {
        if {[info exists $hlt]} {
            set changes true
            append config_cmnd " $ixn \$$hlt"
        }
    }
    append config_cmnd "\}"
    set objectCount 0
    if {$mode == "create"} {
        set handle_list [list]
        for {set i 1} {$i <= $count} {incr i} {
            set retCode [eval [subst $config_cmnd]]
            if {[keylget retCode status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log [keylget retCode log]
                return $returnList
            }
            lappend handle_list [keylget retCode node_objref]
            if {$objectCount < $objectMaxCount} {
                incr objectCount
            } else {
                ixNet commit
                set objectCount 0
            }
            foreach {var incr_cmd min max} $vlanIncrementList {
                if {[info exists $var]} {
                    if {$incr_cmd == "incr"} {
                        incr $var [set ${var}_step]
                        if {[set $var] > $max} {
                            set $var [expr [set $var] - $max + $min]
                        }
                    } else {
                        set $var [$incr_cmd [set $var] [set ${var}_step]]
                    }
                }
            }
            set root_mac_address [join $root_mac_address :]
        }
        if {$objectCount > 0} {
            ixNet commit
        }
        keylset returnList handle [ixNet remapIds $handle_list]
    } elseif {$changes} {
        foreach handle_item $handle {
            set retCode [eval [subst $config_cmnd]]
            if {[keylget retCode status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log [keylget retCode log]
                return $returnList
            }
            if {$objectCount < $objectMaxCount} {
                incr objectCount
            } else {
                ixNet commit
                set objectCount 0
            }
        }
        if {$objectCount > 0} {
            ixNet commit
        }

        keylset returnList handle $handle
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::ixnetwork_stp_lan_config { args opt_args } {
    # global variable initialization
    variable objectMaxCount
    
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
    set retCode [stpLanDependencies]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log [keylget retCode log]
        return $returnList
    }
    if {$mode == "enable" || $mode == "disable"} {
        if {[catch {
            array set enableDisableArray {
                enable  true
                disable false
            }
            foreach handle_item $handle {
                ixNet setAttr $handle_item -enabled $enableDisableArray($mode)
            }
            ixNet commit
        } errorMsg]} {
            keylset returnList status $::FAILURE
            keylset returnList log $errorMsg
            return $returnList
        }

        keylset returnList handle $handle
        keylset returnList status $::SUCCESS
        return $returnList
    }
    if {$mode == "delete"} {
        if {[catch {
            foreach handle_item $handle {
                ixNet remove $handle_item
            }
            ixNet commit
        } errorMsg]} {
            keylset returnList status $::FAILURE
            keylset returnList log $errorMsg
            return $returnList
        }

        keylset returnList handle $handle
        keylset returnList status $::SUCCESS
        return $returnList
    }
    # Modify and create mode
    set mac_address [ixNetworkFormatMac $mac_address]
    set vlanParametersList {
        -macCount            count
        -macAddress          mac_address
        -macIncrement        mac_incr_enable
        -vlanEnabled         vlan_enable
        -vlanId              vlan_id
        -vlanIncrement       vlan_incr_enable
    }
    if {$mode == "create"} {
        set retCode [ixNetworkGetPortObjref $port_handle]
        if {[keylget retCode status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log [keylget retCode log]
            return $returnList
        }
        set port_objref [keylget retCode vport_objref]
        set config_cmnd "ixNetworkNodeAdd $port_objref/protocols/stp lan \{-enabled true"
    } else {
        removeDefaultOptionVars $opt_args $args
        set config_cmnd "ixNetworkNodeSetAttr \$handle_item \{"
    }
    set changes false
    foreach {ixn hlt} $vlanParametersList {
        if {[info exists $hlt]} {
            set changes true
            append config_cmnd " $ixn [set $hlt]"
        }
    }
    append config_cmnd "\}"
    set objectCount 0
    if {$mode == "create"} {
        set retCode [eval $config_cmnd]
        if {[keylget retCode status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log [keylget retCode log]
            return $returnList
        }
        set handle_list [keylget retCode node_objref]
        ixNet commit
        keylset returnList handle [ixNet remapIds $handle_list]
    } elseif {$changes} {
        foreach handle_item $handle {
            set retCode [eval [subst $config_cmnd]]
            if {[keylget retCode status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log [keylget retCode log]
                return $returnList
            }
            if {$objectCount < $objectMaxCount} {
                incr objectCount
            } else {
                ixNet commit
                set objectCount 0
            }
        }
        if {$objectCount > 0} {
            ixNet commit
        }

        keylset returnList handle $handle
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::ixnetwork_stp_control { args opt_args } {
    # global variable initialization
    variable objectMaxCount
    set retry_max_count 10
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
    set retCode [stpControlDependencies]
    if {[keylget retCode status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log [keylget retCode log]
        return $returnList
    }
    if {$mode == "start" || $mode == "stop" || $mode == "restart"} {
        set returnList [::ixia::ixNetworkProtocolControl \
                "-protocol stp $args"   \
                "-protocol ANY"         \
                $opt_args               ]
        return $returnList
    }
    set bridge_obj_list [list]
    if {[info exists port_handle]} {
        foreach port_h $port_handle {
            set retCode [ixNetworkGetPortObjref $port_h]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log [keylget retCode log]
                return $returnList
            }
            lappend bridge_obj_list [ixNet getList \
                    [keylget retCode vport_objref]/protocols/stp bridge]
        }
    }
    if {[info exists handle]} {
        foreach handle_item $handle {
            if {[regexp "^::ixNet::OBJ-/vport:\\d+/protocols/stp/bridge:\\d+"\
                    $handle_item bridge_objref] == 1} {
                lappend bridge_obj_list $bridge_objref
            }
        }
    }
    if {[lempty $bridge_obj_list]} {
        keylset returnList status $::FAILURE
        keylset returnList log "No STP bridge selected. You should specify a\
                port which contain STP bridges or STP bridge handles."
        return $returnList
    }
    set bridge_obj_list [lsort -unique $bridge_obj_list]
    foreach bridge_obj $bridge_obj_list {
        if {[regexp "^::ixNet::OBJ-/vport:\\d+" $bridge_obj port_obj]} {
            if {![info exists port_checked_array($port_obj)] &&\
                    [ixNet getAttr $port_obj/protocols/stp -runningState]\
                    != "started"} {
                keylset returnList status $::FAILURE
                keylset returnList log "-mode $mode is allowed when STP is\
                        running."
                return $returnList
            } else {
                set port_checked_array($port_obj) true
            }
        }
        switch $mode {
            bridge_topology_change {
                ixNet exec bridgeTopologyChange $bridge_obj
            }
            cist_topology_change {
                if {[ixNet getAttr $bridge_obj -mode] != "mstp"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "-mode $mode is allowed with mstp\
                            bridge only."
                    return $returnList
                }
                ixNet exec cistTopologyChange $bridge_obj
            }
            update_parameters {
                if {[ixNet getAttr $bridge_obj -updateRequired]} {
                    ixNet exec updateParameters $bridge_obj
                }
                foreach vlan_obj [ixNet getList $bridge_obj vlan] {
                    if {[ixNet getAttr $vlan_obj -updateRequired]} {
                        ixNet exec updateParameters $vlan_obj
                    }
                }
            }
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}
 
proc ::ixia::ixnetwork_stp_info { args opt_args } {
    # global variable initialization
    variable objectMaxCount
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
        set bridge_handles ""
        set port_handles   ""
        set port_objrefs   ""
        foreach {port} $port_handle {
            set retCode [ixNetworkGetPortObjref $port]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            set vport_objref [keylget retCode vport_objref]
            lappend port_objrefs $vport_objref
            set protocol_objref $vport_objref/protocols/stp
            set bridge_objref [ixNet getList $protocol_objref bridge]
            append bridge_handles " $bridge_objref"
            append port_handles [string repeat " $port" [llength $bridge_objref]]
        }
        if {$bridge_handles == "" } {
            keylset returnList status $::FAILURE
            keylset returnList log "There are no STP bridge on the ports\
                    provided through -port_handle."
            return $returnList
        }
    }
    if {[info exists handle]} {
        set port_handles   ""
        set port_objrefs   ""
        foreach {_handle} $handle {
            if {![regexp {^(.*)/protocols/stp/bridge:\d$} $_handle {} port_objref]} {
                keylset returnList status $::FAILURE
                keylset returnList log "The handle $handle is not a valid\
                        STP bridge handle."
                return $returnList
            }
            set retCode [ixNetworkGetPortFromObj $_handle]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            lappend port_handles  [keylget retCode port_handle]
            lappend port_objrefs  [keylget retCode vport_objref]
        }
        set bridge_handles $handle
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
    if {$mode == "learned_info"} {
        if {[lempty $bridge_handles]} {
            keylset returnList status $::FAILURE
            keylset returnList log "No STP bridge found on specified\
                    -port_handle/-handle parameter."
            return $returnList
        }
        set all_learned_lists {
            bridge_stats_list           learnedInfo
            bridge_intf_stats_list      interface/learnedInfo
            bridge_msti_stats           msti/learnedInfo
            bridge_msti_intf_stats      msti/learnedInterface
            bridge_vlan_stats           vlan/learnedInfo
            bridge_vlan_intf_stats      vlan/learnedInterface
            bridge_cist_stats           cist/cistLearnedInfo
            bridge_cist_intf_stats      cist/learnedInterface
        }
        
        array set all_hlt_params_depencencies [list                                         \
                bridge_stats_list           {port_handle bridge_handle}                     \
                bridge_intf_stats_list      {port_handle bridge_handle stp_intf}            \
                bridge_msti_stats           {port_handle bridge_handle msti_id}             \
                bridge_msti_intf_stats      {port_handle bridge_handle stp_intf msti_id}    \
                bridge_vlan_stats           {port_handle bridge_handle vlan_id}             \
                bridge_vlan_intf_stats      {port_handle bridge_handle stp_intf vlan_id}    \
                bridge_cist_stats           {port_handle bridge_handle}                     \
                bridge_cist_intf_stats      {port_handle bridge_handle stp_intf}            \
        ]
        # ::ixNet::OBJ-/vport:1/protocols/stp/bridge:1/learnedInfo
        set bridge_stats_list {
            bridgeMac       $port_handle.$bridge_handle.stp.bridge_mac_address
            rootCost        $port_handle.$bridge_handle.stp.root_cost
            rootMac         $port_handle.$bridge_handle.stp.root_mac_address
            rootPriority    $port_handle.$bridge_handle.stp.root_priority
        }
        # ::ixNet::OBJ-/vport:1/protocols/stp/bridge:1/interface/learnedInfo
        set bridge_intf_stats_list {
            designatedCost     $port_handle.$bridge_handle.stp_intf.$stp_intf.disagnated_cost
            designatedPortId   $port_handle.$bridge_handle.stp_intf.$stp_intf.designated_port_id
            designatedPriority $port_handle.$bridge_handle.stp_intf.$stp_intf.designated_priority
            rootMac            $port_handle.$bridge_handle.stp_intf.$stp_intf.root_mac_address
            rootPriority       $port_handle.$bridge_handle.stp_intf.$stp_intf.root_priority
            interfaceDesc      $port_handle.$bridge_handle.stp_intf.$stp_intf.interface_description
            interfaceRole      $port_handle.$bridge_handle.stp_intf.$stp_intf.interface_role
            interfaceState     $port_handle.$bridge_handle.stp_intf.$stp_intf.interface_state
        }
        # ::ixNet::OBJ-/vport:1/protocols/stp/bridge:1/msti/learnedInfo
        set bridge_msti_stats {
            actualId           $port_handle.$bridge_handle.msti.$msti_id.actual_id
            rootCost           $port_handle.$bridge_handle.msti.$msti_id.root_cost
            rootMac            $port_handle.$bridge_handle.msti.$msti_id.root_mac_address
            rootPriority       $port_handle.$bridge_handle.msti.$msti_id.root_priority
        }
        # ::ixNet::OBJ-/vport:1/protocols/stp/bridge:1/msti/learnedInterface
        set bridge_msti_intf_stats {
            designatedMac      $port_handle.$bridge_handle.msti_intf.$msti_id.$stp_intf.designated_mac_address
            designatedPortId   $port_handle.$bridge_handle.msti_intf.$msti_id.$stp_intf.designated_port_id
            designatedPriority $port_handle.$bridge_handle.msti_intf.$msti_id.$stp_intf.designated_priority
            interfaceDesc      $port_handle.$bridge_handle.msti_intf.$msti_id.$stp_intf.interface_description
            interfaceRole      $port_handle.$bridge_handle.msti_intf.$msti_id.$stp_intf.interface_role
            interfaceState     $port_handle.$bridge_handle.msti_intf.$msti_id.$stp_intf.interface_state
        }
        # ::ixNet::OBJ-/vport:1/protocols/stp/bridge:1/vlan/learnedInfo
        set bridge_vlan_stats {
            actualId           $port_handle.$bridge_handle.vlan.$vlan_id.actual_vlan_id
            rootCost           $port_handle.$bridge_handle.vlan.$vlan_id.root_cost
            rootMac            $port_handle.$bridge_handle.vlan.$vlan_id.root_mac
            rootPriority       $port_handle.$bridge_handle.vlan.$vlan_id.root_priority
        }
        # ::ixNet::OBJ-/vport:1/protocols/stp/bridge:1/vlan/learnedInterface
        set bridge_vlan_intf_stats {
            designatedMac      $port_handle.$bridge_handle.vlan_intf.$vlan_id.$stp_intf.designated_mac_address
            designatedPortId   $port_handle.$bridge_handle.vlan_intf.$vlan_id.$stp_intf.designated_port_id
            designatedPriority $port_handle.$bridge_handle.vlan_intf.$vlan_id.$stp_intf.designated_priority
            interfaceDesc      $port_handle.$bridge_handle.vlan_intf.$vlan_id.$stp_intf.interface_description
            interfaceRole      $port_handle.$bridge_handle.vlan_intf.$vlan_id.$stp_intf.interface_role
            interfaceState     $port_handle.$bridge_handle.vlan_intf.$vlan_id.$stp_intf.interface_state
       }
       # ::ixNet::OBJ-/vport:1/protocols/stp/bridge:1/cist/cistLearnedInfo
       set bridge_cist_stats {
            regRootCost        $port_handle.$bridge_handle.cist.reg_root_cost
            regRootMac         $port_handle.$bridge_handle.cist.reg_root_mac
            regRootPriority    $port_handle.$bridge_handle.cist.reg_root_priority
            rootCost           $port_handle.$bridge_handle.cist.root_cost
            rootMac            $port_handle.$bridge_handle.cist.root_mac
            rootPriority       $port_handle.$bridge_handle.cist.root_priority
        }
        # ::ixNet::OBJ-/vport:1/protocols/stp/bridge:1/cist/learnedInterface
        set bridge_cist_intf_stats {
            designatedMac          $port_handle.$bridge_handle.cist_intf.$stp_intf.disagnated_mac_address
            designatedPortId       $port_handle.$bridge_handle.cist_intf.$stp_intf.disagnated_port_id
            designatedPriority     $port_handle.$bridge_handle.cist_intf.$stp_intf.disagnated_priority
            interfaceDesc          $port_handle.$bridge_handle.cist_intf.$stp_intf.interface_description
            interfaceRole          $port_handle.$bridge_handle.cist_intf.$stp_intf.interface_role
            interfaceState         $port_handle.$bridge_handle.cist_intf.$stp_intf.interface_state
        }
        foreach {bridge} $bridge_handles {port_handle} $port_handles {
            debug "ixNet exec refreshLearnedInfo $bridge"
            set retCode [ixNet exec refreshLearnedInfo $bridge]
            if {[string first "::ixNet::OK" $retCode] == -1 } {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to refresh learned info for\
                        STP bridge $bridge."
                return $returnList
            }
            set retries 10
            while {[ixNet getAttribute $bridge -isRefreshComplete] != "true"} {
                after 500
                incr retries -1
                if {$retries < 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Refreshing learned info for\
                            STP bridge $bridge has timed out.\
                            Please try again later."                    
                    return $returnList
                }
            }
            foreach {stat_list_name ixn_path} $all_learned_lists {
                # obtain leafs of ixNetwork tree using bridge object as root
                # of tree.
                set learned_info_objrefs $bridge
                foreach ixn_child [split $ixn_path /] {
                    set learned_info_objrefs_tmp [list]
                    foreach learned_info_objref $learned_info_objrefs {
                        debug "ixNet getList $learned_info_objref $ixn_child"
                        append learned_info_objrefs_tmp "[ixNet getList $learned_info_objref $ixn_child] "
                    }
                    set learned_info_objrefs $learned_info_objrefs_tmp
                }
                # setting result values if any
                if {![lempty $learned_info_objrefs]} {
                    foreach learned_info_objref $learned_info_objrefs {
                        catch {
                            unset stp_intf
                            unset vlan_id
                            unset msti_id
                        }
                        # initialize variable required in subst operation
                        if {![regexp -- "^::ixNet::OBJ-/vport:\\d+/protocols/stp/bridge:\\d+"\
                                $learned_info_objref bridge_handle]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "Wrong handle retuned by\
                                    IxNetwork as STP learned obj - $learned_info_objref."
                            return $returnList
                        }
                        regexp -- "^::ixNet::OBJ-/vport:\\d+/protocols/stp/bridge:\\d+/interface:\\d+"\
                                $learned_info_objref stp_intf
                        if [regexp -- "^::ixNet::OBJ-/vport:\\d+/protocols/stp/bridge:\\d+/vlan:\\d+"\
                                $learned_info_objref vlan_id_objref] {
                            debug "ixNet getAttribute $vlan_id_objref -vlanId"
                            set vlan_id [ixNet getAttribute $vlan_id_objref -vlanId]
                            if {[regexp -- "\\d+$" $learned_info_objref intf_id]} {
                                set stp_intf "$bridge_handle/interface:$intf_id"
                            }
                        }
                        if [regexp -- "^::ixNet::OBJ-/vport:\\d+/protocols/stp/bridge:\\d+/msti:\\d+"\
                                $learned_info_objref msti_objref] {
                            debug "ixNet getAttribute $msti_objref -mstiId"
                            set msti_id [ixNet getAttribute $msti_objref -mstiId]
                            if {[regexp -- "\\d+$" $learned_info_objref intf_id]} {
                                set stp_intf "$bridge_handle/interface:$intf_id"
                            }
                        }
                        if [regexp -- "^::ixNet::OBJ-/vport:\\d+/protocols/stp/bridge:\\d+/cist/learnedInterface:\(\\d+\)$"\
                                $learned_info_objref {} intf_id] {
                            set stp_intf "$bridge_handle/interface:$intf_id"
                        }
                        # check if we have all varibles defined for subst
                        foreach hlt_param $all_hlt_params_depencencies($stat_list_name) {
                            if {![info exists $hlt_param]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "Invalid handle\
                                        ($learned_info_objref) returned\
                                        by IxNetwork used to get $hlt_param."
                                return $returnList
                            }
                        }
                        # setting return list keys
                        foreach {ixn_stat hlt_stat} [set $stat_list_name] {
                            debug "ixNet getAttribute $learned_info_objref -$ixn_stat"
                            if [catch {set stat_value [ixNet getAttribute $learned_info_objref -$ixn_stat ]}] {
                                set stat_value "N/A"
                            }
                            keylset returnList [subst $hlt_stat] $stat_value
                        }
                    }
                } else {
                    debug "empty list: $stat_list_name"
                }
            }
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }
    # Aggregate statistics retrieve
    array set stats_array_aggregate {
        "Port Name"
        port_name                 
        "Discarding State Count"
        discarding_state_count    
        "Listening State Count"
        listening_state_count     
        "Learning State Count"
        learning_state_count      
        "Forwarding State Count"
        forwarding_state_count    
        "STP BPDUs Rx"
        stp_bpdus_rx              
        "STP BPDUs Rx Config TC"
        stp_bpdus_rx_config_tc    
        "STP BPDUs Rx Config TCA"
        stp_bpdus_rx_config_tca   
        "STP BPDUs Rx TCN"
        stp_bpdus_rx_config_tcn   
        "STP BPDUs Tx"
        stp_bpdus_tx              
        "STP BPDUs Tx Config TC"
        stp_bpdus_tx_config_tc    
        "STP BPDUs Tx Config TCA"
        stp_bpdus_tx_config_tca   
        "STP BPDUs Tx TCN"
        stp_bpdus_tx_config_tcn   
        "RSTP BPDUs Rx"
        rstp_bpdus_rx             
        "RSTP BPDUs Rx TC"
        rstp_bpdus_rx_config_tc   
        "RSTP BPDUs Tx"
        rstp_bpdus_tx             
        "RSTP BPDUs Tx TC"
        rstp_bpdus_tx_tc          
        "MSTP BPDUs Rx"
        mstp_bpdus_rx             
        "MSTP BPDUs Tx"
        mstp_bpdus_tx             
        "PVST+ BPDUs Rx"
        pvst_bpdus_rx             
        "PVST+ BPDUs Rx Config TC"
        pvst_bpdus_rx_config_tc   
        "PVST+ BPDUs Rx Config TCA"
        pvst_bpdus_rx_config_tca  
        "PVST+ BPDUs Rx TCN"
        pvst_bpdus_rx_tcn_tcl     
        "PVST+ BPDUs Tx"
        pvst_bpdus_tx             
        "PVST+ BPDUs Tx Config TC"
        pvst_bpdus_tx_config_tc   
        "PVST+ BPDUs Tx Config TCA"
        pvst_bpdus_tx_config_tca  
        "PVST+ BPDUs Tx TCN"
        pvst_bpdus_tx_tcn         
        "RPVST BPDUs Rx"
        rpvst_bpdus_rx            
        "RPVST BPDUs Rx TC"
        rpvst_bpdus_rx_tc         
        "RPVST BPDUs Tx"
        rpvst_bpdus_tx            
        "RPVST BPDUs Tx TC"
        rpvst_bpdus_tx_tc         
    }
    set statistic_types {
        aggregate "STP Aggregated Statistics"
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
    keylset returnList status $::SUCCESS
    return $returnList
}
