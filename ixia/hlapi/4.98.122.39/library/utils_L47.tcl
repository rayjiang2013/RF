proc ::ixia::checkL47 {protocol} {
    variable ixLoadLoaded
    variable ixLoadChassisConnected
    variable ixload_chassis_list
    variable ixload_tcl_server
    variable ixload_chassis_chain
    variable ixload_logger
    variable ixload_log_engine
    variable ixloadVersion
    variable ixload_csv_protocols
    variable debug
    global ixAppPluginManager
   
    if {![info exists ixLoadLoaded]} {
        set ixLoadLoaded $::FAILURE
    }
    
    if {![info exists ixLoadChassisConnected]} {
        set ixLoadChassisConnected $::FAILURE
    }
    
    if {$ixLoadLoaded == $::FAILURE} {
        #
        # Set up paths to IxLoad tcl code relative to install directory
        # This script does nothing unless it is running on a windows platform
        # (*nix scripters must set up their own auto_path)
        #
        if {$::tcl_platform(platform) != "windows"} {
            variable temporary_fix_122311
            if {$::ixia::temporary_fix_122311 != 0} {
                set ::ixia::temporary_fix_122311 2
            }
        }
        # The global variable contains the version we are trying to use
        if {[llength [split $ixloadVersion "."]] == 2} {
            set _cmd "package require IxLoad $ixloadVersion"
        } else {
            set _cmd "package require -exact IxLoad $ixloadVersion"
        }
        if {[catch {eval $_cmd} err]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Package IxLoad can not be loaded. \
                    $_cmd returned $err"
            return $returnList
        }
    }

    if {$ixLoadChassisConnected == $::FAILURE} {
        if {$ixload_tcl_server == ""} {
            if {[isUNIX]} {
                keylset returnList status $::FAILURE
                keylset returnList log "-tcl_server option from \
                    ::ixia::connect procedure must have an IP value."
                return $returnList
            } else  {
                # windows
                set ixload_tcl_server [lindex [lindex $ixload_chassis_list 0] 1]
            }
        }
        set remoteService $ixload_tcl_server
        set _cmd [format "%s" "::IxLoad connect $remoteService"]
        debug $_cmd
        if {[catch {eval $_cmd} error]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not connect to Remote Server: \
                $remoteService"
            return $returnList
        }
        
        if {$ixLoadLoaded == $::FAILURE} {
            set logtag    "IxLoad-api"
            set logName   "[info script]-log"
            set logger    [::IxLoad new ixLogger $logtag 1]
            set ixload_logger $logger
            debug "::IxLoad new ixLogger $logtag 1"
            set logEngine [$logger getEngine]
            set ixload_log_engine $logEngine
            debug "$logger getEngine"
            if {[info exists debug] && $debug == 1} {
                $logEngine setLevels $::ixLogger(kLevelDebug) $::ixLogger(kLevelInfo)
                debug "$logEngine setLevels $::ixLogger(kLevelDebug) $::ixLogger(kLevelInfo)"
            } else {
                $logEngine setLevels $::ixLogger(kLevelDebug) $::ixLogger(kLevelError)
                debug "$logEngine setLevels $::ixLogger(kLevelDebug) $::ixLogger(kLevelError)"
            }
            $logEngine setFile [file tail $logName] 2 256 1
            debug "$logEngine setFile [file tail $logName] 2 256 1"
        }
        
        # connecting to chassis
        set chassisCount [llength $ixload_chassis_list]
        if {$chassisCount > 0} {
            if {![info exists ixload_chassis_chain]} {
                set chassisChain [::IxLoad new ixChassisChain]
                debug "::IxLoad new ixChassisChain"
                set ixload_chassis_chain $chassisChain
            } else  {
                set chassisChain ixload_chassis_chain
            }
            set count 0
            foreach chassis_item [lsort -dictionary $ixload_chassis_list] {
                set chassis [lindex $chassis_item 1]
                set _cmd [format "%s" "$chassisChain addChassis $chassis"]
                debug $_cmd
                catch {eval $_cmd} _chassis_error
                if {$_chassis_error != ""} {
                    ixPuts $_chassis_error
                }
                incr count
            }
            if {$count > 0} {
                set ixLoadChassisConnected $::SUCCESS
            } else  {
                keylset returnList status $::FAILURE
                keylset returnList log "No connection to a chassis or device \
                        has been made."
                return $returnList
            }
        } else  {
            keylset returnList status $::FAILURE
            keylset returnList log "No connection to a chassis or device \
                    has been made."
            return $returnList
        }
    }

    if {$ixLoadLoaded == $::FAILURE && $protocol != "none"} {
        $ixAppPluginManager load "$protocol"
        debug "$ixAppPluginManager load $protocol"
        
        set ixload_csv_protocols($protocol) 1
        
        if {[catch {package require statCollectorUtils} scuVersion]} {
            keylset returnList status $::SUCCESS
            keylset returnList log "Package statCollectorUtils can't be \
                    loaded. Statistics will not be available."
            return $returnList
        }
        debug "package require statCollectorUtils"
        set ixLoadLoaded $::SUCCESS
    }

    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixL47GetChassisChain { procName chassis } {
    variable ixload_chassis_chain
    
#    debug "ixL47GetChassisChain: CHASSIS=$ixload_chassis_chain"
    if {![info exists ixload_chassis_chain]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Not connected to chassis \
                $chassis."
        return $returnList
    } else {
        keylset returnList status $::SUCCESS
        keylset returnList handles $ixload_chassis_chain
        return $returnList
    }
}


proc ::ixia::ixL47HandlesArrayCommand {args} {
    variable ixload_handles_array
    variable ixload_handles_count
    
    set mandatory_args {
        -mode        CHOICES get_handle get_value save remove modify
    }
    
    set opt_args {
        -handle                 ANY
        -type                   CHOICES network networkRange
                                CHOICES traffic agent action
                                CHOICES dns_server dns_suffix pool statistic
                                CHOICES test cookie cookielist realFile
                                CHOICES header headerlist profile requestHeader
                                CHOICES page map dut per_interface_statistic
                                CHOICES rulesTable audioClipsTable scenarios
                                CHOICES predefined_tos_for_sip predefined_tos_for_rtp
                                CHOICES profile_table commands channelviewTable
                                CHOICES rule videoList stream program
        -target                 CHOICES client server
        -ixload_index           ANY
        -ixload_handle          ANY
        -parent_handle          ANY
        -traffic_handle         ANY
        -network_handle         ANY
        -command_type           CHOICES open login password
                                CHOICES send exit think
        -key                    CHOICES type target ixload_index ixload_handle
                                CHOICES parent_handle command_type
                                CHOICES traffic_handle network_handle
    }
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $mandatory_args

    switch -- $mode {
        get_handle {
            if {![info exists type]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -mode is $mode you must provide \
                        -type options."
                return $returnList
            }
            set  index $ixload_handles_count
            incr index
            
            if {[info exists target]} {
                set  returnedHandle "$type[string totitle $target]$index"
            } else  {
                set  returnedHandle "$type$index"
            }
            
            keylset returnList status $::SUCCESS
            keylset returnList handle $returnedHandle
            return $returnList
        }
        get_value {
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -mode is $mode you must provide \
                        -handle option."
                return $returnList
            }
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid handle $handle."
                return $returnList
            }
            if {![info exists key]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -mode is $mode you must provide \
                        -key option."
                return $returnList
            }
            set retValues ""
            foreach {key_elem} $key {
                if {[catch {keylget ixload_handles_array($handle) $key_elem} \
                        key_value]} {
                    lappend retValues N/A
                } else  {
                    lappend retValues $key_value
                }
            }
            
            keylset returnList status $::SUCCESS
            keylset returnList value  $retValues
            return $returnList
        }
        save {
            set mandatoryArgs [list \
                    handle type ixload_handle parent_handle]
            foreach {mandatoryArg} $mandatoryArgs {
                if {![info exists $mandatoryArg]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "When -mode is $mode you must provide\
                             -$mandatoryArg option."
                    return $returnList
                }
            }
            
            set keysList [list \
                    type target ixload_index ixload_handle parent_handle \
                    command_type traffic_handle network_handle]
            
            set arrayValue ""
            
            foreach {key} $keysList {
                if {[info exists $key]} {
                    keylset arrayValue $key [set $key]
                }
            }
            
            set ixload_handles_array($handle) $arrayValue
            incr ixload_handles_count
            
            keylset returnList status $::SUCCESS
            return $returnList
        }
        modify {
            set mandatoryArgs [list handle]
            
            foreach {mandatoryArg} $mandatoryArgs {
                if {![info exists $mandatoryArg]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "When -mode is $mode you must provide\
                             -$mandatoryArg option."
                    return $returnList
                }
            }
            
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid handle $handle."
                return $returnList
            }
            
            set keysList [list \
                    type target ixload_index ixload_handle parent_handle \
                    command_type traffic_handle network_handle]
            
            set arrayValue $ixload_handles_array($handle)
            
            foreach {key} $keysList {
                if {[info exists $key]} {
                    keylset arrayValue $key [set $key]
                }
            }
            
            set ixload_handles_array($handle) $arrayValue

            keylset returnList status $::SUCCESS
            return $returnList
        }
        remove {
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "When -mode is $mode you must provide \
                        -handle option."
                return $returnList
            }            
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Invalid handle $handle."
                return $returnList
            }
            # Get key values for this handle
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            get_value             \
                    -handle          $handle               \
                    -key             [list parent_handle   \
                    target type ixload_index] ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set handle_parent [lindex [keylget retCode value] 0]
            set handle_target [lindex [keylget retCode value] 1]
            set handle_type   [lindex [keylget retCode value] 2]
            set handle_index  [lindex [keylget retCode value] 3]
            
            set _cmd [format "%s" "::ixia::ixL47GetChildrenHandles \
                    -mode   new_list        \
                    -handle $handle_parent  \
                    -type   $handle_type    "]
                    
            if {$handle_target != "" && $handle_target != "N/A"} {
                append _cmd " -target $handle_target"
            }
            # If this handle has an ixload index then decrement all
            # handles that are after it in the list
            if {$handle_index != "N/A"} {
                set retCode [eval $_cmd]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log [keylget retCode log]
                    return $returnList
                }
                set childrenList [keylget retCode children]
                
                foreach {child} $childrenList {
                    set retCode [::ixia::ixL47HandlesArrayCommand \
                            -mode            get_value             \
                            -handle          $child                \
                            -key             ixload_index          ]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    
                    if {([keylget retCode value] != "N/A") && \
                            ([keylget retCode value] > $handle_index)} {
                        
                        set ixload_array_value $ixload_handles_array($child)
                        keylset ixload_array_value ixload_index [mpexpr \
                                [keylget ixload_array_value ixload_index] - 1]
                        
                        set ixload_handles_array($child) $ixload_array_value
                    }
                }
            }
            
            # Remove the handle from the array along with all children
            set elementsToRemove      ""
            set elementsToRemoveTemp  $handle
            
            while {$elementsToRemove != $elementsToRemoveTemp} {
                set elementsToRemove [lsort -unique $elementsToRemoveTemp]
                set retCode [::ixia::ixL47GetChildrenHandles \
                        -mode    append_to_list               \
                        -handle  $elementsToRemoveTemp        ]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log [keylget retCode log]
                    return $returnList
                }
                set elementsToRemoveTemp [lsort -unique \
                        [keylget retCode children]]
            }
            
            foreach {element} $elementsToRemove {
                unset ixload_handles_array($element)
            }
            
            keylset returnList status $::SUCCESS
            keylset returnList log ""
            keylset returnList handles ""
            return $returnList
        }
    }
}


proc ::ixia::ixL47GetChildrenHandles {args} {
    variable ixload_handles_array
    
    set mandatory_args {
        -mode        CHOICES new_list append_to_list
    }
    
    set optional_args {
        -handle                 ANY
        -type                   CHOICES network networkRange
                                CHOICES traffic agent action
                                CHOICES dns_server dns_suffix pool statistic
                                CHOICES test cookie cookielist realFile
                                CHOICES rulesTable audioClipsTable scenarios
                                CHOICES header headerlist requestHeader
                                CHOICES profile profile_table commands
                                CHOICES page map dut per_interface_statistic
                                CHOICES channelviewTable rule videoList stream
                                CHOICES program
        -target                 CHOICES client server 
    }
    
    ::ixia::parse_dashed_args -args $args -optional_args $optional_args \
            -mandatory_args $mandatory_args
    
    switch -- $mode {
        append_to_list {
            set childrenList $handle
            foreach {arrayHandle} [array names ixload_handles_array] {
                set retCode [::ixia::ixL47HandlesArrayCommand \
                        -mode     get_value                    \
                        -key      parent_handle                \
                        -handle   $arrayHandle                 ]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed in\
                            ::ixia::ixL47GetChildrenHandles. \
                            [keylget retCode log]"
                    return $returnList
                }
                if {[lsearch $childrenList [keylget retCode value]] != -1} {
                    lappend childrenList $arrayHandle
                }
            }
        }
        new_list {
            set handlesList $handle
            set childrenList ""
            foreach {arrayHandle} [array names ixload_handles_array] {
                set retCode [::ixia::ixL47HandlesArrayCommand     \
                        -mode     get_value                        \
                        -key      [list parent_handle type target] \
                        -handle   $arrayHandle                     ]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed in\
                            ::ixia::ixL47GetChildrenHandles. \
                            [keylget retCode log]"
                    return $returnList
                }
                set cond1 [expr [lsearch $handlesList [lindex \
                        [keylget retCode value] 0]] != -1]
                
                set cond2 [expr {(([info exists type] && ($type  == [lindex \
                            [keylget retCode value] 1])) || (![info exists type])) ? 1 : 0}]
                
                set cond3 [expr {(([info exists target] && ($target == [lindex \
                            [keylget retCode value] 2])) || (![info exists target]))? 1 : 0}]
                
                if {$cond1 && $cond2 && $cond3} {
                    lappend childrenList $arrayHandle
                }
            }
        }
    }
    
    keylset returnList status   $::SUCCESS
    keylset returnList children [lsort -unique $childrenList]
    return $returnList
}


proc ::ixia::ixL47Network { args } {
    variable ixload_handles_array
    set ipType ""
    
    #debug "\n::ixia::ixL47Network $args"
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    array set valuesHltToIxLoad [list                        \
            macip    $::ixClientNetwork(kMacMappingModeIp)   \
            macport  $::ixClientNetwork(kMacMappingModePort) \
            kb       $::ixTcpParametersFull(kUnitKbps)       \
            mb       $::ixTcpParametersFull(kUnitMbps)       ]

    array set target_net {
        client ixClientNetwork
        server ixServerNetwork
    }
    
    array set net_args {
        mac_mapping_mode               macMappingMode
        source_port_from               ipSourcePortFrom
        source_port_to                 ipSourcePortTo
        emulated_router_gateway        emulatedRouterGateway
        emulated_router_subnet         emulatedRouterSubnet
    }
    
    array set tcp_args {
        tcp_enable_congestion_notification enableCongestionNotification
        tcp_enable_timestamp               enableTimeStamp
        tcp_enable_rx_bw_limit             enableRxBwLimit
        tcp_enable_tx_bw_limit             enableTxBwLimit
        tcp_fin_timeout                    finTimeout
        tcp_keep_alive_interval            keepAliveInterval
        tcp_keep_alive_probes              keepAliveProbes
        tcp_keep_alive_time                keepAliveTime
        tcp_receive_buffer_size            receiveBuffer
        tcp_retransmit_retries             retransmitRetries
        tcp_rx_bw_limit                    rxBwLimit
        tcp_rx_bw_limit_unit               rxBwLimitUnit
        tcp_syn_ack_retries                synAckRetries
        tcp_syn_retries                    synRetries
        tcp_transmit_buffer_size           transmitBuffer
        tcp_tx_bw_limit                    txBwLimit
        tcp_tx_bw_limit_unit               txBwLimitUnit
    }
    
    array set dns_args {
        dns_enable                         enable
        dns_cache_timeout                  cacheTimeout
    }
    
    if {[info exists emulated_router_gateway]} {
        if {[isIpAddressValid $emulated_router_gateway]} {
            set ipType 1
        } else {
            if {[::ipv6::isValidAddress $emulated_router_gateway]} {
                set ipType 2
                set net_args(emulated_router_gateway) emulatedRouterGatewayIPv6
                set net_args(emulated_router_subnet) emulatedRouterSubnetIPv6
                if [info exists emulated_router_subnet] {
                    set emulated_router_subnet_status \
                        [getIpV6NetMaskFromPrefixLen $emulated_router_subnet]
                    if {[keylget emulated_router_subnet_status status] != $::SUCCESS} {
                        return $emulated_router_subnet_status
                    }
                    set emulated_router_subnet [keylget \
                                        emulated_router_subnet_status hexNetAddr]
                }
            } else  {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument \
                        -emulated_router_gateway is not a valid IP address."
                return $returnList
            }
        }
    }
    
    switch -- $mode {
        add {
            if {[info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            if {![info exists target]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -target \
                        must be specified."
                return $returnList
            }
            if {![info exists port_handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument \
                        -port_handle must be specified."
                return $returnList
            } else {
                set port_list [format_space_port_list $port_handle]
                # we take only the first port to find card type and chassis
                # Is illegal in IxLoad to use ports from different types of
                # cards with the same client network
                foreach {chassis card port} [lindex $port_list 0] {}
                set chassis [get_valid_chassis_id_ixload $chassis]
            }
            
            set returnList [::ixia::ixL47GetChassisChain $procName $chassis]
            if {[keylget returnList status] == $::FAILURE} {
                return $returnList
            } else {
                set chassis_chain [keylget returnList handles]
            }
            
################################################################################
#              set returnList [::ixia::ixL47GetCardType $procName $chassis $card \
#                      $port]
#              if {[keylget returnList status] == $::FAILURE} {
#                  return $returnList
#              } else {
#                  set card_type [keylget returnList handles]
#              }
#              keylset returnList handles ""
################################################################################

            
            # a new name for this IxLoad target Network
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode   get_handle \
                    -target $target    \
                    -type   network    ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            set network_name [keylget retCode handle]
            
            # creating the IxLoad network
            set _cmd [format "%s" "::IxLoad new $target_net($target) \
                    $chassis_chain -name $network_name"]
            
            debug "$_cmd"
            if {[catch {eval $_cmd} handler]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error adding a \
                        new configuration.\n$handler."
                return $returnList
            }
            # building IxLoad API command
            set command ""
            foreach item [array names net_args] {
                if {[info exists $item]} {
                    set _param $net_args($item)
                    set _val [set $item]
                    if {[info exists valuesHltToIxLoad($_val)]} {
                        set _val $valuesHltToIxLoad($_val)
                    }
                    append command " -$_param $_val "
                }
            }
            
            # configuring the IxLoad network
            if {$command != ""} {
                set _cmd [format "%s" "$handler config [set command]"]
                debug $_cmd
                if {[catch {eval $_cmd} error]} {
                    catch {::IxLoad delete $handler}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $error."
                    return $returnList
                }
            }
            
            # gratuitous ARP
            if {[info exists grat_arp_enable]} {
                set _cmd "$handler arpSettings.config -gratuitousArp \
                        $grat_arp_enable"
                debug $_cmd
                if {[catch {eval $_cmd} error]} {
                    catch {::IxLoad delete $handler}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $error."
                    return $returnList
                }
            }
            
            # setting TCP parameters. building IxLoad TCP API command
            set command ""
            foreach item [array names tcp_args] {
                if {[info exists $item]} {
                    set _param $tcp_args($item)
                    set _val [set $item]
                    if {[info exists valuesHltToIxLoad($_val)]} {
                        set _val $valuesHltToIxLoad($_val)
                    }
                    append command " -$_param $_val "
                }
            }
            
            if {$command != ""} {
                set _cmd [format "%s" "$handler \
                        tcpParameters.tcpParametersFull.config $command"]
                debug $_cmd
                if {[catch {eval $_cmd} error]} {
                    catch {::IxLoad delete $handler}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $error."
                    return $returnList
                }
            }
            
            # setting DNS parameters. building IxLoad TCP API command
            set command ""
            foreach item [array names dns_args] {
                if {[info exists $item]} {
                    set _param $dns_args($item)
                    set _val [set $item]
                    if {[info exists valuesHltToIxLoad($_val)]} {
                        set _val $valuesHltToIxLoad($_val)
                    }
                    append command " -$_param $_val "
                }
            }
            
            if {$command != ""} {
                set _cmd [format "%s" "$handler dnsParameters.config $command"]
                debug $_cmd
                if {[catch {eval $_cmd} error]} {
                    catch {::IxLoad delete $handler}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $error."
                    return $returnList
                }
            }
            
            # adding ports
            set port_list [format_space_port_list $port_handle]
            foreach port_item $port_list {
                scan $port_item "%s %s %s" chassis card port
                set chassis [get_valid_chassis_id_ixload $chassis]
                set _cmd [format "%s" "$handler portList.appendItem -chassisId \
                        $chassis -cardId $card -portId $port"]
                
                debug $_cmd
                
                if {[catch {eval $_cmd} error]} {
                    catch {::IxLoad delete $handler}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Can not add \
                            port $chassis $card $port to configuration: $error."
                    return $returnList
                }
            }
            
            # reserving this IxLoad Network name
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            save                  \
                    -handle          $network_name         \
                    -ixload_handle   $handler              \
                    -target          $target               \
                    -type            network               \
                    -parent_handle   $port_handle          ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            keylset returnList network_handle $network_name
            return $returnList
        }
        remove {
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        is missing."
                return $returnList
            }
            # check to see if handler is ok
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid configuration handle."
                return $returnList
            }
            # deleting object
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            get_value             \
                    -handle          $handle               \
                    -key             ixload_handle         ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]."
                return $returnList
            }
            set ixLoadHandle [keylget retCode value]
            
            set _cmd [format "%s" "::IxLoad delete $ixLoadHandle"]
            debug $_cmd
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error removing \
                        configuration.\n$error"
                return $returnList
            }
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            remove                \
                    -handle          $handle               ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        modify {
            # check handle
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        is missing."
                return $returnList
            }
            # check to see if handler is ok
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid configuration handle."
                return $returnList
            }
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            get_value             \
                    -handle          $handle               \
                    -key             ixload_handle         ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]."
                return $returnList
            }
            set handler [keylget retCode value]
            
            # check grat ARP
            if {[info exists grat_arp_enable]} {
                set _cmd [format "%s" "$handler arpSettings.config \
                        -gratuitousArp $grat_arp_enable"]
                debug $_cmd
                if {[catch {eval $_cmd} error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $error."
                    return $returnList
                }
            }
            # check ports. User wants the ports changed
            if {[info exists port_handle]} {
                set port_list [format_space_port_list $port_handle]
                debug "$handler portList.clear"
                if {[catch {$handler portList.clear} error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Can not remove \
                            ports from configuration: $error."
                    return $returnList
                }
                foreach item $port_list {
                    scan $item "%s %s %s" chassis card port
                    set chassis [get_valid_chassis_id_ixload $chassis]
                    set _cmd [format "%s" "$handler portList.appendItem \
                            -chassisId $chassis -cardId $card -portId $port"]
                    debug "$_cmd"
                    if {[catch {eval $_cmd} error]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Can not \
                                add port $chassis $card $port to configuration:\
                                $error."
                        return $returnList
                    }
                }
            }
            # building IxLoad API command
            set command ""
            foreach item [array names net_args] {
                if {[info exists $item]} {
                    set _param $net_args($item)
                    set _val [set $item]
                    if {[info exists valuesHltToIxLoad($_val)]} {
                        set _val $valuesHltToIxLoad($_val)
                    }
                    append command " -$_param $_val "
                }
            }
            
            # configuring the IxLoad network
            if {$command != ""} {
                set _cmd [format "%s" "$handler config [set command]"]
                debug "$_cmd"
                if {[catch {eval $_cmd} error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $error."
                    return $returnList
                }
            }
            
            # setting TCP parameters. building IxLoad TCP API command
            set command ""
            foreach item [array names tcp_args] {
                if {[info exists $item]} {
                    set _param $tcp_args($item)
                    set _val [set $item]
                    if {[info exists valuesHltToIxLoad($_val)]} {
                        set _val $valuesHltToIxLoad($_val)
                    }
                    append command " -$_param $_val "
                }
            }
            
            if {$command != ""} {
                set _cmd [format "%s" "$handler \
                        tcpParameters.tcpParametersFull.config $command"]
                debug "$_cmd"
                if {[catch {eval "$_cmd"} error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $error."
                    return $returnList
                }
            }
            
            # setting DNS parameters. building IxLoad TCP API command
            set command ""
            foreach item [array names dns_args] {
                if {[info exists $item]} {
                    set _param $dns_args($item)
                    set _val [set $item]
                    if {[info exists valuesHltToIxLoad($_val)]} {
                        set _val $valuesHltToIxLoad($_val)
                    }
                    append command " -$_param $_val "
                }
            }
            
            if {$command != ""} {
                set _cmd [format "%s" "$handler dnsParameters.config $command"]
                debug $_cmd
                if {[catch {eval $_cmd} error]} {
                    catch {::IxLoad delete $handler}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $error."
                    return $returnList
                }
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        enable -
        disable {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Arguments -enable \
                    or -disable can't be used on a configuration."
            return $returnList
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -mode \
                    must be specified."
            return $returnList
        }
    }
}


proc ::ixia::ixL47GetOptionalArgs {args} {
    set retArgList ""
    foreach {elem} $args {
        if {[string first "-" $elem] == 0} {
            append retArgList " $elem ANY \n"
        }
    }
    return $retArgList
}


proc ::ixia::escapeSpecialChars {str {char_list {"\{" "\[" "\(" "\}" "\]" "\)" "\\"} }} {
    
    set strLen [string length $str]
    
    foreach {char_item} $char_list  {
        for {set idx 0} {$idx < $strLen} {incr idx} {
            set char [string index $str $idx]
            if {$char == $char_item} {
                set str [string replace $str $idx $idx "\\$char_item"]
                incr idx
            }
        }
    }
    
    return $str
}

proc ::ixia::escapeBackslash {_args _parameter_name} {
    set _parameter_name "-$_parameter_name"
    set pos [lsearch $_args $_parameter_name]
    if {$pos > -1} {
        set path [lindex $_args [expr $pos + 1]]
        set path [::ixia::escapeSpecialChars $path]
        set _args [lreplace $_args [expr $pos + 1] [expr $pos + 1] $path]
    }
    
    return $_args
}

proc ::ixia::ixL47PoolAddr { args } {
    variable ixload_handles_array
    
#    debug "\n::ixia::ixL47PoolAddr $args"
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    set mac_args [list rp_fist_mac]
    
    foreach {mac_arg} $mac_args {
        if {[info exists $mac_arg]} {
            set $mac_arg [join [::ixia::convertToIxiaMac [set $mac_arg]] :]
        }
    }
    
    if {[info exists ip_type]} {
        if {$ip_type == "ipv4"} {
            set ip_type 1
        } elseif {$ip_type == "ipv6"} {
            set ip_type 2
        }
    }
    
    array set addr_args {
        ip_type                ipType
        rp_first_ip            firstIp
        rp_ip_count            ipCount
        rp_first_mac           firstMac
        rp_vlan_enable         vlanEnable
        rp_vlan_id             vlanId
        rp_network_mask        networkMask
    }
    if {![info exists handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Argument -handle \
                is missing."
        return $returnList
    }
    
    set command ""
    foreach item [array names addr_args] {
        if {[info exists $item]} {
            if {$item == "rp_network_mask" && [info exists ip_type] \
                                                    && $ip_type == "2"} {
                set rp_network_mask_status [getIpV6NetMaskFromPrefixLen \
                                                            $rp_network_mask]
                if {[keylget rp_network_mask_status status] != $::SUCCESS} {
                    return $rp_network_mask_status
                }
                set rp_network_mask [keylget rp_network_mask_status hexNetAddr]
            }
            set _param $addr_args($item)
            append command " -$_param \"[set $item]\" "
        }
    }
    
    switch -- $mode {
        add {
            # check to see if handler is ok. It should be a network handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid configuration handle."
                return $returnList
            }
            # a new name for this IxLoad target Network
            set retCode [::ixia::ixL47HandlesArrayCommand -mode get_handle \
                    -type pool ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set pool_name [keylget retCode handle]
#            debug "new pool handler = $pool_name"
            
            set retCode [::ixia::ixL47HandlesArrayCommand -mode get_value \
                    -handle $handle -key ixload_handle]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [keylget retCode value]
            
            # finding the future index of this element
            set _cmd [format "%s" "$ixLoadHandler \
                    emulatedRouterIpAddressPool.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error adding a \
                        network to handler $handle.\n$index."
                return $returnList
            }
#            debug "ixLoad INDEX=$index"
            # creating the IxLoad router addr
            set _cmd [format "%s" "$ixLoadHandler \
                emulatedRouterIpAddressPool.appendItem -enable 1 $command"]
            debug "$_cmd"
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error adding a \
                        network to handler $handle.\n$error."
                return $returnList
            }
            
            # reserving this IxLoad Network Range name
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            save                  \
                    -handle          $pool_name            \
                    -type            pool                  \
                    -ixload_handle   $ixLoadHandler        \
                    -ixload_index    $index                \
                    -parent_handle   $handle               ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            keylset returnList router_pool_handle $pool_name
            return $returnList
        }
        remove {
            # check to see if handler is ok. It should be a pool handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid router_addr handle."
                return $returnList
            }
            set retCode [::ixia::ixL47HandlesArrayCommand -mode get_value \
                    -handle $handle -key [list ixload_handle ixload_index]]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [lindex [keylget retCode value] 0]
            set index         [lindex [keylget retCode value] 1]
            set _cmd [format "%s" "$ixLoadHandler \
                    emulatedRouterIpAddressPool.deleteItem $index"]
            debug "$_cmd"
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error deleting \
                        address pool.\n$error."
                return $returnList
            }
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            remove                \
                    -handle          $handle               ]            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        modify {
            # check to see if handler is ok. It should be a pool handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid network range handle."
                return $returnList
            }
            set retCode [::ixia::ixL47HandlesArrayCommand -mode get_value \
                    -handle $handle -key [list ixload_handle ixload_index]]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [lindex [keylget retCode value] 0]
            set index         [lindex [keylget retCode value] 1]
            set _cmd [format "%s" "$ixLoadHandler \
                    emulatedRouterIpAddressPool($index).config $command"]
            debug "$_cmd"
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Couldn't modify \
                        this address pool.\n$error"
                return $returnList
            }

            keylset returnList status  $::SUCCESS
            keylset returnList router_pool_handle $handle
            return $returnList
        }
        enable -
        disable {
            set flag [expr {( $mode == "disable" ) ? 0 : 1}]
            # check to see if handler is ok. It should be a pool handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid network range handle."
                return $returnList
            }
            set retCode [::ixia::ixL47HandlesArrayCommand -mode get_value \
                    -handle $handle -key [list ixload_handle ixload_index]]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [lindex [keylget retCode value] 0]
            set index         [lindex [keylget retCode value] 1]
            set _cmd [format "%s" "$ixLoadHandler \
                    emulatedRouterIpAddressPool($index).config -enable $flag"]
            debug "$_cmd"
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Couldn't $mode \
                        this address pool.\n$error"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -mode \
                    must be specified."
            return $returnList
        }
    }
}


proc ::ixia::ixL47GetIpType {IpAddress argslist ipType} {
    upvar $IpAddress ipAddress
    upvar $argslist  args_list
    upvar $ipType    _ip_type
    
    if {[isIpAddressValid $ipAddress]} {
        if {[info exists _ip_type] && $_ip_type != "ipv4"} {
            return 1
        }
        set _ip_type 1
    } else {
        if {[::ipv6::isValidAddress $ipAddress]} {
            if {[info exists _ip_type] && $_ip_type != "ipv6"} {
                return 1
            }
            set _ip_type 2
        } else  {
            # ERROR
            return 1
        }
    }
    
    if {[lsearch $args_list "-$ipType"] == -1 } {
        lappend args_list "-$ipType"
        lappend args_list "$_ip_type"
    }
    # OK
    return 0
}


proc ::ixia::ixL47Range { args } {
    variable ixload_handles_array
    
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    set mac_args [list np_first_mac np_mac_incr_step]
    
    foreach {mac_arg} $mac_args {
        if {[info exists $mac_arg]} {
            set $mac_arg [join [::ixia::convertToIxiaMac [set $mac_arg]] :]
        }
    }
    
    array set valuesHltToIxLoad [list                       \
            ethernet        $::ixIP(kEthernet)              \
            dhcp            $::ixIP(kDHCP)                  \
            pppoe           $::ixIP(kPPPoE)                 \
            ipsec           $::ixIP(kIPSec)                 \
            inner_first     $::ixNetworkRange(kVlanIncrModeInnerFirst) \
            outer_first     $::ixNetworkRange(kVlanIncrModeOuterFirst) \
            md5             $::ixIpsec(kHashAlgMd5)         \
            sha1            $::ixIpsec(kHashAlgSha1)        \
            ah              $::ixIpsec(kAhEspModeAhOnly)    \
            esp             $::ixIpsec(kAhEspModeEspOnly)   \
            ah_and_esp      $::ixIpsec(kAhEspModeBoth)      \
            dh1             $::ixIpsec(kDh1)                \
            dh2             $::ixIpsec(kDh2)                \
            dh5             $::ixIpsec(kDh5)                \
            dh14            $::ixIpsec(kDh14)               \
            dh15            $::ixIpsec(kDh15)               \
            dh16            $::ixIpsec(kDh16)               \
            main            $::ixIpsec(kIkeModeMain)        \
            aggressive      $::ixIpsec(kIkeModeAggressive)  \
            des             $::ixIpsec(kEncrAlgDes)         \
            3des            $::ixIpsec(kEncrAlg3Des)        \
            aes128          $::ixIpsec(kEncrAlgAes128)      \
            aes192          $::ixIpsec(kEncrAlgAes192)      \
            aes256          $::ixIpsec(kEncrAlgAes256)      \
            none            $::ixIpsec(kEncrAlgNull)        \
            p2p_initiator   $::ixIpsec(kRoleP2PInitiator)   \
            p2p_responder   $::ixIpsec(kRoleP2PResponder)   \
            dut_initiator   $::ixIpsec(kRoleDutInitiator)   \
            match_name      $::ixPppoe(kMatchName)          \
            match_service   $::ixPppoe(kMatchService)       \
            match_first     $::ixPppoe(kMatchFirst)         \
            none            $::ixPppoe(kAuthTypeNone)       \
            pap             $::ixPppoe(kAuthTypePap)        \
            chap            $::ixPppoe(kAuthTypeChap)       \
            pap_or_chap     $::ixPppoe(kAuthTypePapOrChap)  \
            ipv4            1                               \
            ipv6            2                               ]

    array set net_args {
        ip_type                             ipType
        np_range_type                       rangeType
        np_enable_stats                     enableStats
        np_first_ip                         firstIp
        np_first_mac                        firstMac
        np_mac_incr_step                    macIncrStep
        np_gateway                          gateway
        np_gateway_incr_step                gatewayIncrStep
        np_ip_count                         ipCount
        np_ip_incr_step                     ipIncrStep
        np_inner_vlan_enable                innerVlanEnable
        np_inner_vlan_id                    innerVlanId
        np_inner_vlan_count                 innerVlanCount
        np_inner_vlan_incr_step             innerVlanIncrStep
        np_inner_vlan_priority              innerVlanPriority
        np_inner_vlan_unique_count          innerVlanUniqueCount
        np_mss_enable                       mssEnable
        np_mss                              mss
        np_network_mask                     networkMask
        np_vlan_increment_mode              vlanIncrementMode
        np_vlan_enable                      vlanEnable
        np_vlan_id                          vlanId
        np_vlan_count                       vlanCount
        np_vlan_incr_step                   vlanIncrStep
        np_vlan_priority                    vlanPriority
        np_vlan_unique_count                vlanUniqueCount
    }
    
    array set dhcp_args {
        np_circuit_id                           circuitId
        np_circuit_id_group_size                circuitIdGroupSize
        np_circuit_id_enable                    enableCircuitId
        np_enable_cid_byte_stream               enableCIdByteStream
        np_enable_remote_id                     enableRemoteId
        np_enable_rid_byte_stream               enableRIdByteStream
        np_enable_vendor_class_identifier       enableVendorClassIdentifier
        np_first_server_reply                   firstServerReply
        np_first_relay_ip                       firstRelayIp
        np_max_outstanding_requests             maxOutstandingRequests
        np_max_client_per_second                maxClientsPerSecond
        np_num_relay_agents                     numRelayAgents
        np_packet_forward_mode                  packetForwardMode
        np_remote_id                            remoteId
        np_ra_server_ip                         raServerIp
        np_remote_id_group_size                 remoteIdGroupSize
        np_server_ip                            serverIp
        np_timeout                              timeout
        np_vendor_class_identifier              vendorClassIdentifier
        np_relay_vlan_enable                    vlanEnable
        np_relay_vlan_id                        vlanId
        np_relay_vlan_count                     vlanCount
        np_relay_vlan_incr_step                 vlanIncrStep
    }
    
    array set ipsec_args {
        np_ah_esp_options                       ahEspOptions
        np_dh_group                             dhGroup
        np_emulated_subnet                      emulatedSubnet
        np_emulated_subnet_mask                 emulatedSubnetMask
        np_emulated_hosts                       emulatedHosts
        np_enable_pfs                           enablePfs
        np_ike_mode                             ikeMode
        np_increment_by                         incrementBy
        np_num_retries                          numRetries
        np_protected_subnet                     protectedSubnet
        np_protected_subnet_mask                protectedSubnetMask
        np_peer_public_ip                       peerPublicIp
        np_pre_shared_key                       preSharedKey
        np_phase1_hash_algorithm                phase1HashAlgorithm
        np_phase1_encryption_algorithm          phase1EncryptionAlgorithm
        np_phase1_lifetime                      phase1Lifetime
        np_phase2_hash_algorithm                phase2HashAlgorithm
        np_phase2_encryption_algorithm          phase2EncryptionAlgorithm
        np_phase2_lifetime                      phase2Lifetime
        np_pfs_group                            pfsGroup
        np_retry_interval                       retryInterval
        np_retry_delay                          retryDelay
        np_role                                 role
    }

    array set pppoe_args {
        np_ac_name                              acName
        np_ac_selection                         acSelection
        np_auth_type                            authType
        np_auth_timeout                         authTimeout
        np_auth_retries                         authRetries
        np_chap_name                            chapName
        np_chap_secret                          chapSecret
        np_enable_throttling                    enableThrottling
        np_enable_redial                        enableRedial
        np_enable_echo_reply                    enableEchoReply
        np_enable_echo_request                  enableEchoRequest
        np_echo_request_interval                echoRequestInterval
        np_lcp_timeout                          lcpTimeout
        np_lcp_retries                          lcpRetries
        np_max_outstanding_sessions             maxOutstandingSessions
        np_mtu                                  mtu
        np_ncp_timeout                          ncpTimeout
        np_ncp_retries                          ncpRetries
        np_padi_timeout                         padiTimeout
        np_padr_timeout                         padrTimeout
        np_padi_retries                         padiRetries
        np_padr_retries                         padrRetries
        np_pap_user                             papUser
        np_pap_password                         papPassword
        np_redial_timeout                       redialTimeout
        np_redial_max                           redialMax
        np_setup_rate                           setupRate
        np_server_response_timeout              serverResponseTimeout
        np_service_name                         serviceName
    }
    
    if {![info exists handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Argument -handle \
                is missing."
        return $returnList
    }

    if {[info exists ip_type]} {
        if {$ip_type == "ipv4"} {
            set ip_type 1
        } elseif {$ip_type == "ipv6"} {
            set ip_type 2
        }
    }

    set command ""
    foreach item [array names net_args] {
        if {$item == "np_gateway" && ![info exists $item] &&\
                [info exists ip_type] && $ip_type == "2"} {
            
            # Needed because ixload 5.0 will configure gw default
            # to 0.0.0.0 even for ipv6 wich will cause an error
            # BUG549345
            set $item 0::0
        }
        if {[info exists $item]} {
            if {$item == "np_network_mask" && [info exists ip_type] \
                                                    && $ip_type == "2"} {
                set np_network_mask_status [getIpV6NetMaskFromPrefixLen \
                                                            $np_network_mask]
                if {[keylget np_network_mask_status status] != $::SUCCESS} {
                    return $np_network_mask_status
                }
                set np_network_mask [keylget np_network_mask_status hexNetAddr]
            }
            set _param $net_args($item)
            set _val [set $item]
            if {[info exists valuesHltToIxLoad($_val)]} {
                set _val $valuesHltToIxLoad($_val)
            }
            append command " -$_param $_val "
        }
    }

#    debug "MODE=$mode"
    switch -- $mode {
        add {
            # check to see if handler is ok. It should be a configuration
            # handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid configuration handle."
                return $returnList
            }
            # a new name for this IxLoad target Network
            set retCode [::ixia::ixL47HandlesArrayCommand -mode get_handle \
                    -type networkRange ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }            
            set range_name [keylget retCode handle]
#            debug "new range handler = $range_name"
            
            set retCode [::ixia::ixL47HandlesArrayCommand -mode get_value \
                    -handle $handle -key ixload_handle]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [keylget retCode value]            
            
            # finding the future index of this element
            set _cmd [format "%s" "$ixLoadHandler networkRangeList.indexCount"]
            debug "$_cmd"
            if {[catch {eval $_cmd} index]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error adding a \
                        network to handler $handle.\n$index."
                return $returnList
            }
#            debug "ixLoad INDEX=$index"
            
            set range_parameter ""
            set dhcpParameters ""
            set pppoeParameters ""
            set ipsecParameters ""
            switch -- $np_range_type {
                dhcp {
                    set range_parameter dhcpParameters 
                    foreach item [array names dhcp_args] {
                        if {[info exists $item]} {
                            set _param $dhcp_args($item)
                            set _val [set $item]
                            if {[info exists valuesHltToIxLoad($_val)]} {
                                set _val $valuesHltToIxLoad($_val)
                            }
                            if {$item == "np_circuit_id" || \
                                    $item == "np_remote_id"} {
                                append dhcpParameters " -$_param \{$_val\} "
                            } else {
                                append dhcpParameters " -$_param \"$_val\" "
                            }
                        }
                    }
                }
                pppoe {
                    set range_parameter pppoeParameters
                    foreach item [array names pppoe_args] {
                        if {[info exists $item]} {
                            set _param $pppoe_args($item)
                            set _val [set $item]
                            if {[info exists valuesHltToIxLoad($_val)]} {
                                set _val $valuesHltToIxLoad($_val)
                            }
                            append pppoeParameters " -$_param \"$_val\" "
                        }
                    }
                }
                ipsec {
                    set range_parameter ipsecParameters
                    foreach item [array names ipsec_args] {
                        if {[info exists $item]} {
                            set _param $ipsec_args($item)
                            set _val [set $item]
                            if {[info exists valuesHltToIxLoad($_val)]} {
                                set _val $valuesHltToIxLoad($_val)
                            }
                            append ipsecParameters " -$_param \"$_val\" "
                        }
                    }
                }
            }
            
            # creating the IxLoad network range
            set _cmd [format "%s" "$ixLoadHandler networkRangeList.appendItem \
                    -name $range_name -enable 1 $command"]
            debug "$_cmd"
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error adding a \
                        network to handler $handle.\n$error."
                return $returnList
            }
            
            # configure pppoe or ipsec or dhcp parameters
            if {$range_parameter != "" && [set $range_parameter] != ""} {
                set _cmd [format "%s" "$ixLoadHandler \
                        networkRangeList($index).$range_parameter.config \
                        [set $range_parameter]"]
                debug "$_cmd"
                if {[catch {eval $_cmd} error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Error adding a \
                            network to handler $handle.\n$error."
                    return $returnList
                }
            }
            
            # reserving this IxLoad Network Range name
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            save                  \
                    -handle          $range_name           \
                    -type            networkRange          \
                    -ixload_handle   $ixLoadHandler        \
                    -ixload_index    $index                \
                    -parent_handle   $handle               ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            keylset returnList network_pool_handle $range_name
            return $returnList
        }
        remove {
            # check to see if handler is ok. It should be a range handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid network range handle."
                return $returnList
            }
            set retCode [::ixia::ixL47HandlesArrayCommand -mode get_value \
                    -handle $handle -key [list ixload_handle ixload_index]]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [lindex [keylget retCode value] 0]
            set index         [lindex [keylget retCode value] 1]
            set _cmd [format "%s" "$ixLoadHandler networkRangeList.deleteItem \
                    $index"]
            debug "$_cmd"
            
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error deleting \
                        network.\n$error."
                return $returnList
            }
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            remove                \
                    -handle          $handle               ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        modify {
            # check to see if handler is ok. It should be a range handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid network range handle."
                return $returnList
            }
            set retCode [::ixia::ixL47HandlesArrayCommand -mode get_value \
                    -handle $handle -key [list ixload_handle ixload_index]]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [lindex [keylget retCode value] 0]
            set index         [lindex [keylget retCode value] 1]
            set _cmd [format "%s" "$ixLoadHandler \
                    networkRangeList($index).config $command"]
            debug "$_cmd"
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Couldn't modify \
                        this network.\n$error"
                return $returnList
            }
            
            if {![info exists np_range_type]} {
                set _cmd [format "%s" "$ixLoadHandler \
                    networkRangeList($index).cget -rangeType"]
                debug "$_cmd"
                if {[catch {eval $_cmd} error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Couldn't modify \
                            this network.\n$error"
                    return $returnList
                } else {
                    set np_range_type [string tolower $error]
                }
            }
            
            set range_parameter ""
            set dhcpParameters ""
            set pppoeParameters ""
            set ipsecParameters ""            
            switch -- $np_range_type {
                dhcp {
                    set range_parameter dhcpParameters 
                    foreach item [array names dhcp_args] {
                        if {[info exists $item]} {
                            set _param $dhcp_args($item)
                            set _val [set $item]
                            if {[info exists valuesHltToIxLoad($_val)]} {
                                set _val $valuesHltToIxLoad($_val)
                            }
                            if {$item == "np_circuit_id" || \
                                    $item == "np_remote_id"} {
                                append dhcpParameters " -$_param \{$_val\} "
                            } else {
                                append dhcpParameters " -$_param \"$_val\" "
                            }
                        }
                    }
                }
                pppoe {
                    set range_parameter pppoeParameters
                    foreach item [array names pppoe_args] {
                        if {[info exists $item]} {
                            set _param $pppoe_args($item)
                            set _val [set $item]
                            if {[info exists valuesHltToIxLoad($_val)]} {
                                set _val $valuesHltToIxLoad($_val)
                            }
                            append pppoeParameters " -$_param \"$_val\" "
                        }
                    }
                }
                ipsec {
                    set range_parameter ipsecParameters
                    foreach item [array names ipsec_args] {
                        if {[info exists $item]} {
                            set _param $ipsec_args($item)
                            set _val [set $item]
                            if {[info exists valuesHltToIxLoad($_val)]} {
                                set _val $valuesHltToIxLoad($_val)
                            }
                            append ipsecParameters " -$_param \"$_val\" "
                        }
                    }
                }
            }
            
            # configure pppoe or ipsec or dhcp parameters
            if {$range_parameter != "" && [set $range_parameter] != ""} {
                set _cmd [format "%s" "$ixLoadHandler \
                        networkRangeList($index).$range_parameter.config \
                        [set $range_parameter]"]
                debug "$_cmd"
                if {[catch {eval $_cmd} error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Error adding a \
                            network to handler $handle.\n$error."
                    return $returnList
                }
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        enable -
        disable {
            set flag [expr {( $mode == "disable" ) ? 0 : 1}]
            # check to see if handler is ok. It should be a range handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid network range handle."
                return $returnList
            }
            set retCode [::ixia::ixL47HandlesArrayCommand -mode get_value \
                    -handle $handle -key [list ixload_handle ixload_index]]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [lindex [keylget retCode value] 0]
            set index         [lindex [keylget retCode value] 1]
            set _cmd [format "%s" "$ixLoadHandler \
                    networkRangeList($index).config -enable $flag"]
            debug "$_cmd"
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Couldn't $mode \
                        this network.\n$error"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -mode is \
                    missing."
            return $returnList
        }
    }
}


proc ::ixia::ixL47Dns { args } {
    variable ixload_handles_array
    
#    debug "ixL47Dns $args"
    ::ixia::parse_dashed_args -args $args -optional_args $args
    if {![info exists handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Argument -handle \
                is missing."
        return $returnList
    }
    
    set dns_options ""
    if {[info exists dns_server]} {
        lappend dns_options dns_server
    }
    if {[info exists dns_suffix]} {
        lappend dns_options dns_suffix
    }
    
    switch -- $mode {
        add {
            foreach dns_option $dns_options {
                set dns_handle_list ""
                foreach dns_single_option  [set $dns_option] {
                    # check to see if handler is ok. It should be a configuration
                    # handle 
                            
                    if {![info exists ixload_handles_array($handle)]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Argument\
                                -handle $handle is not a valid configuration handle."
                        return $returnList              
                    }                                   
                    # a new name for this IxLoad target Network
                    set retCode [::ixia::ixL47HandlesArrayCommand -mode get_handle \
                            -type $dns_option ]                 
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"  
                        return $returnList              
                    }                                   
                    set dns_name [keylget retCode handle]
        #            debug "new dns handler = $dns_name"
                                                        
                    set retCode [::ixia::ixL47HandlesArrayCommand -mode get_value \
                            -handle $handle -key ixload_handle]
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"  
                        return $returnList              
                    }                                   
                    set ixLoadHandler [keylget retCode value]
                                                        
                    switch -- $dns_option {
                        dns_server {
                            set dnsList serverList
                        }
                        dns_suffix {
                            set dnsList suffixList
                        }
                    }
                        
                    set _cmd [format "%s" "$ixLoadHandler \
                            dnsParameters.${dnsList}.indexCount"]
                    debug "$_cmd"               
                    if {[catch {eval $_cmd} index]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Error \
                                adding a $dns_option entry.\n$index."
                        return $returnList      
                    }                           
    #                    debug "NEW INDEX WOULD BE: $index"
                    # creating the IxLoad dns server/suffix entry
                    set _cmd [format "%s" "$ixLoadHandler \
                            dnsParameters.${dnsList}.appendItem -data \
                            $dns_single_option"]       
                    debug "$_cmd"               
                    if {[catch {eval $_cmd} error]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Error \
                                adding a $dns_option entry.\n$error."
                        return $returnList      
                    }                           
                                      
                    set retCode [::ixia::ixL47HandlesArrayCommand \
                            -mode            save                  \
                            -handle          $dns_name             \
                            -type            $dns_option           \
                            -ixload_handle   $ixLoadHandler        \
                            -ixload_index    $index                \
                            -parent_handle   $handle               ]
                                                
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList      
                    }                           
                    
                    lappend dns_handle_list $dns_name
                }
                keylset returnList ${dns_option}_handle $dns_handle_list
            }
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        remove {
            foreach single_handle $handle {
                # check to see if handler is ok. It should be a dns handle
                if {![info exists ixload_handles_array($single_handle)]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument\
                            -handle $single_handle is not a valid dns handle."
                    return $returnList
                }
                set retCode [::ixia::ixL47HandlesArrayCommand -mode get_value \
                        -handle $single_handle -key [list ixload_handle ixload_index type]]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]"
                    return $returnList
                }
                set ixLoadHandler [lindex [keylget retCode value] 0]
                set index         [lindex [keylget retCode value] 1]
                set dns_type      [lindex [keylget retCode value] 2]
                
                switch -- $dns_type {
                    dns_server {
                        set dnsList serverList
                    }
                    dns_suffix {
                        set dnsList suffixList
                    }
                }
                    
                set _cmd [format "%s" "$ixLoadHandler \
                        dnsParameters.${dnsList}.deleteItem $index"]
                debug "$_cmd"
                if {[catch {eval $_cmd} error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Error deleting \
                            dns entry.\n$error."
                    return $returnList
                }
                
                set retCode [::ixia::ixL47HandlesArrayCommand \
                        -mode            remove                \
                        -handle          $single_handle               ]
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]"
                    return $returnList
                }
            }
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        modify {
            # check to see if handler is ok. It should be a dns handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid dns handle."
                return $returnList
            }
            set retCode [::ixia::ixL47HandlesArrayCommand -mode get_value \
                    -handle $handle -key [list ixload_handle ixload_index type]]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [lindex [keylget retCode value] 0]
            set index         [lindex [keylget retCode value] 1]
            set dns_type      [lindex [keylget retCode value] 2]
 
            switch -- $dns_type {
                dns_server {
                    set dnsList serverList
                }
                dns_suffix {
                    set dnsList suffixList
                }
            }
            
            # creating the IxLoad dns server entry
            if {[info exists $dns_type]} {
                set _cmd [format "%s" "$ixLoadHandler \
                        dnsParameters.${dnsList}($index).config -data \
                        [set $dns_type]"]
                debug "$_cmd"
                if {[catch {eval $_cmd} error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Error \
                            adding a $dns_type entry.\n$error."
                    return $returnList
                }
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        enable -
        disable {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Arguments -enable \
                    or -disable can't be used on dns configuration."
            return $returnList
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -mode \
                    must be specified."
            return $returnList
        }
    }
}


proc ::ixia::ixL47Dut {args} {
    variable ixload_handles_array
#    debug "\nixL47Dut: $args"

    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    array set valuesHltToIxLoad {
        external           $::ixDut(kTypeExternalServer)
        slb                $::ixDut(kTypeSLB)
        firewall           $::ixDut(kTypeFirewall)
    }
    
    array set dut_args {
        dut_name                      name
        enable_direct_server_return   enableDirectServerReturn
        ip_address                    ipAddress
        ixLoadNetworkHandler          serverNetwork
        type                          type
    }
    
    switch -- $mode {
        add {
            # check if server_telnet/http/ftp_handle was provided
            if {(![info exists server_network]) && \
                    (![info exists ip_address])} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Arguments\
                        -server_network or -ip_address\
                        must be provided for -mode $mode."
                return $returnList
            }
            if {[info exists server_network]} {
                set network_handle $server_network
            }
            
            # get next map handle
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode    get_handle                    \
                    -type    dut                           ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set dut_name [keylget retCode handle]
#            debug "new map handler = $dut_name"
            
            if {[info exists network_handle]} {
                set retCode [::ixia::ixL47HandlesArrayCommand \
                        -mode     get_value                    \
                        -handle   $network_handle              \
                        -key      [list ixload_handle parent_handle]  ]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]"
                    return $returnList
                }
                set ixLoadNetworkHandler [lindex [keylget retCode value] 0]
                set parent_handle        [lindex [keylget retCode value] 1]
            }
            
            set _cmd "::IxLoad new ixDut"
            debug $_cmd
            if {[catch {eval $_cmd} ixLoadDutHandler]} {
                debug "::IxLoad delete $ixLoadDutHandler"
                catch {::IxLoad delete $ixLoadDutHandler}
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $ixLoadDutHandler."
                return $returnList
            }
            
            set enable_dut 1
            set _command ""
            foreach item [array names dut_args] {
                if {[info exists $item]} {
                    set _param [set dut_args($item)]
                    if {[info exists valuesHltToIxLoad([set $item])]} {
                        set $item $valuesHltToIxLoad([set $item])
                    }
                    if {[set $item] != "na"} {
                        append _command " -$_param \"[set $item]\" "
                    }
                }
            }
            
            if {$_command != ""} {
                set _cmd "$ixLoadDutHandler config $_command"
                debug $_cmd
                if {[catch {eval $_cmd} error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $error."
                    return $returnList
                }
            }
            
            if {[info exists network_handle]} {
                set retCode [::ixia::ixL47HandlesArrayCommand \
                        -mode            save                  \
                        -handle          $dut_name             \
                        -type            dut                   \
                        -ixload_handle   $ixLoadDutHandler     \
                        -network_handle  $network_handle       \
                        -parent_handle   $parent_handle        ]
            } else  {
                set retCode [::ixia::ixL47HandlesArrayCommand \
                        -mode            save                  \
                        -handle          $dut_name             \
                        -type            dut                   \
                        -ixload_handle   $ixLoadDutHandler     \
                        -parent_handle   ""                    ]
            }
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            keylset returnList dut_handle $dut_name
            return $returnList
        }
        remove {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid map handle."
                return $returnList
            }
            # get handle properties
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $handle                      \
                    -key      [list ixload_handle type]    ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [lindex [keylget retCode value] 0]
            set handleType    [lindex [keylget retCode value] 1]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "dut"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid dut handle."
                return $returnList
            }
            
            set _cmd [format "%s" "::IxLoad delete $ixLoadHandler"]
            debug "$_cmd"
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error deleting \
                        dut.\n$error."
                return $returnList
            }
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            remove                \
                    -handle          $handle               ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        modify {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid map handle."
                return $returnList
            }
            # get handle properties
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $handle                      \
                    -key      [list ixload_handle type network_handle]    ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadDutHandler   [lindex [keylget retCode value] 0]
            set handleType         [lindex [keylget retCode value] 1]
            set network_handle     [lindex [keylget retCode value] 2]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "dut"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid dut handle."
                return $returnList
            }
                    
            if {[info exists server_network]} {
                set network_handle $server_network
            } elseif {$network_handle == "N/A"} {
                unset network_handle
            }
            
            if {[info exists network_handle]} {
                set retCode [::ixia::ixL47HandlesArrayCommand \
                        -mode     get_value                    \
                        -handle   $network_handle              \
                        -key      [list ixload_handle parent_handle]  ]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]"
                    return $returnList
                }
                set ixLoadNetworkHandler [lindex [keylget retCode value] 0]
                set parent_handle        [lindex [keylget retCode value] 1]
                
            }
            
            set _command ""
            foreach item [array names dut_args] {
                if {[info exists $item]} {
                    set _param [set dut_args($item)]
                    if {[info exists valuesHltToIxLoad([set $item])]} {
                        set $item $valuesHltToIxLoad([set $item])
                    }
                    if {[set $item] != "na"} {
                        append _command " -$_param \"[set $item]\" "
                    }
                }
            }
            
            if {$_command != ""} {
                set _cmd "$ixLoadDutHandler config $_command"
                debug $_cmd
                if {[catch {eval $_cmd} error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $error."
                    return $returnList
                }
            }
            
            if {[info exists network_handle]} {
                set retCode [::ixia::ixL47HandlesArrayCommand \
                        -mode            save                  \
                        -handle          $handle               \
                        -type            dut                   \
                        -ixload_handle   $ixLoadDutHandler     \
                        -network_handle  $network_handle       \
                        -parent_handle   $parent_handle        ]
            } else  {
                set retCode [::ixia::ixL47HandlesArrayCommand \
                        -mode            save                  \
                        -handle          $handle               \
                        -type            dut                   \
                        -ixload_handle   $ixLoadDutHandler     \
                        -parent_handle   ""                    ]
            }
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -mode \
                    must be specified."
            return $returnList
        }
    }
}


proc ::ixia::ixL47Traffic { args } {
    variable ixload_handles_array
    
#    debug "ixLoadTraffic: $args"
    ::ixia::parse_dashed_args -args $args -optional_args $args
    
    array set target_traffic {
        client ixClientTraffic
        server ixServerTraffic
    }
    
    if {[info exists target]} {
        set target [string tolower $target]
    }
    switch -- $mode {
        add {
            if {[info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            if {![info exists target]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -target \
                        must be specified."
                return $returnList
            }
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode   get_handle \
                    -target $target    \
                    -type   traffic    ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set traffic_name [keylget retCode handle]
            
            # creating the IxLoad network
            set _cmd [format "%s" "::IxLoad new $target_traffic($target) \
                    -name $traffic_name"]
            
            debug $_cmd
            if {[catch {eval $_cmd} handler]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error adding a \
                        new $target traffic.\n$handler."
                return $returnList
            }
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            save                  \
                    -handle          $traffic_name         \
                    -ixload_handle   $handler              \
                    -target          $target               \
                    -type            traffic               \
                    -parent_handle   $traffic_name         ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            keylset returnList status  $::SUCCESS
            keylset returnList ${target}_handle $traffic_name
            return $returnList
        }
        remove {
#            debug "TRAFFIC HANDLE=$handle"
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        is missing."
                return $returnList
            }
            # check to see if handler is ok
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid configuration handle."
                return $returnList
            }
            # deleting object
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            get_value             \
                    -handle          $handle               \
                    -key             ixload_handle         ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]."
                return $returnList
            }
            set ixLoadHandle [keylget retCode value]
            
            set _cmd [format "%s" "::IxLoad delete $ixLoadHandle"]
            debug $_cmd
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error removing \
                        traffic.\n$error"
                return $returnList
            }
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            remove                \
                    -handle          $handle               ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        modify {
            # do nothing. There is nothing to modify
        }
        enable -
        disable {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Arguments -enable \
                    or -disable can't be used on a $target object."
            return $returnList
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -mode \
                    must be specified."
            return $returnList
        }
    }
}


proc ::ixia::ixL47TrafficNetworkMapping {args} {
    variable ixload_handles_array
    
#     debug "\nixL47TrafficNetworkMapping: $args"
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args


    array set valuesHltToIxLoad {
        users              $::ixObjective(kObjectiveTypeSimulatedUsers)
        connections        $::ixObjective(kObjectiveTypeConcurrentConnections)
        sessions           $::ixObjective(kObjectiveTypeConcurrentSessions)
        crate              $::ixObjective(kObjectiveTypeConnectionRate)
        trate              $::ixObjective(kObjectiveTypeTransactionRate)
        tputmb             $::ixObjective(kObjectiveTypeThroughputMBps)
        tputkb             $::ixObjective(kObjectiveTypeThroughputKBps)
        pairs              $::ixPortMap(kPortMapRoundRobin)
        mesh               $::ixPortMap(kPortMapFullMesh)
        users_per_second   $::ixTimeline(kRampUpTypeUsersPerSecond)
        max_pending_users  $::ixTimeline(kRampUpTypeMaxPendingUsers)
        user_agents        userAgents
        calls_per_second   callsPerSecond
        bhca               bhca
        registrations_initiated registrationsinitiated
        redirections_initiated  redirectionsinitiated 
    }

    
    array set client_mapping_args {
        ixLoadNetworkHandler                network
        ixLoadTrafficHandler                traffic
        iterations                          iterations
        objective_type                      objectiveType
        objective_value                     objectiveValue
        offline_time                        offlineTime
        port_map_policy                     portMapPolicy
        ramp_down_time                      rampDownTime
        ramp_up_type                        rampUpType
        ramp_up_value                       rampUpValue
        ramp_up_interval                    rampUpInterval
        standby_time                        standbyTime
        sustain_time                        sustainTime
        total_time                          totalTime
    }
    
    array set activity_args {
        objective_type_for_activity         setObjectiveTypeForActivity
        objective_value_for_activity        setObjectiveValueForActivity
        port_map_for_activity               setPortMapForActivity
    }
    
    set map_option_list  [list procName mode handle                        \
            server_network_handle server_traffic_handle                    \
            iterations match_client_total_time                             \
            offline_time standby_time sustain_time total_time              ]
            
    array set server_mapping_args {
        ixLoadNetworkHandler                network
        ixLoadTrafficHandler                traffic
        match_client_total_time             matchClientTotalTime
        iterations                          iterations
        offline_time                        offlineTime
        standby_time                        standbyTime
        sustain_time                        sustainTime
        total_time                          totalTime
    }
    
    switch -- $mode {
        add {
            # check to see if valid handles exist
            set checkValidExistence "0x[info exists         \
                    client_network_handle][info exists      \
                    client_traffic_handle][info exists      \
                    server_network_handle][info exists      \
                    server_traffic_handle]"
            
            switch -- $checkValidExistence {
                0x0011 { set _target server }
                0x1100 { set _target client }
                default {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Client or\
                            server traffic and network handles must be\
                            provided."
                    return $returnList
                }
            }
            
            set handleArgs [list \
                    client_network_handle      \
                    client_traffic_handle      \
                    server_network_handle      \
                    server_traffic_handle      ]
            
            foreach {handleArg} $handleArgs {
                # check to see if handle is a valid handle
                if {![info exists $handleArg]} {
                    continue;
                }
                if {![info exists ixload_handles_array([set $handleArg])]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument\
                            -$handleArg [set $handleArg] is not a valid\
                            handle."
                    return $returnList
                }
                set retCode [::ixia::ixL47HandlesArrayCommand  \
                        -mode     get_value                    \
                        -handle   [set $handleArg]             \
                        -key      target                       ]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]"
                    return $returnList
                }
                
                if {[keylget retCode value] != $_target} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument\
                            -$handleArg [set $handleArg] is not a valid\
                            $_target handle."
                    return $returnList
                }
            }
            
            if {$_target == "client"} {
                set network_handle [set client_network_handle]
                set traffic_handle $client_traffic_handle
            } else  {
                set network_handle [set server_network_handle]
                set traffic_handle $server_traffic_handle
            }
            
            # get next map handle
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode    get_handle                    \
                    -type    map                           ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set map_name [keylget retCode handle]
#            debug "new map handler = $map_name"
            
            # check if the provided network_handle has another traffic-network
            # mapping already made
            set retCode [::ixia::ixL47TrafficNetworkMappingExistence \
                    $map_name $traffic_handle $network_handle]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $network_handle              \
                    -key      [list ixload_handle parent_handle]  ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadNetworkHandler [lindex [keylget retCode value] 0]
            set parent_handle        [lindex [keylget retCode value] 1]
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $traffic_handle              \
                    -key      ixload_handle                ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadTrafficHandler [keylget retCode value]
            
            if {[info exists match_client_total_time]} {
                if {$match_client_total_time == 1} {
                    array unset server_mapping_args
                    array set server_mapping_args {
                        enable_mapping               enable
                        ixLoadNetworkHandler         network
                        ixLoadTrafficHandler         traffic
                        match_client_total_time       matchClientTotalTime
                    }
                }
            }
            
            set _command [format "%s" "::IxLoad new ix[string totitle \
                    $_target]TrafficNetworkMapping"]
            set enable_mapping 1
            foreach item [array names ${_target}_mapping_args] {
                if {[info exists $item]} {
                    set _param [set ${_target}_mapping_args($item)]
                    if {[info exists valuesHltToIxLoad([set $item])]} {
                        set $item $valuesHltToIxLoad([set $item])
                    }
                    if {[set $item] != "na"} {
                        append _command " -$_param \"[set $item]\" "
                    }
                }
            }
            
            debug $_command
            if {[catch {eval $_command} handler]} {
                catch {::IxLoad delete $handler}
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: $handler."
                return $returnList
            }
            
            set temp_command $handler
            if {$_target == "client" && [info exists agent_handle]} {
                set agent_handle_length [llength $agent_handle]
                foreach single_agent $agent_handle {
                    set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $single_agent                \
                    -key      parent_handle                ]
                
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    if {[keylget retCode value] != $traffic_handle} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                agent_handle $single_agent is not part of \
                                -traffic_handle $traffic_handle"
                        return $returnList
                    }
                }
                foreach item [array names activity_args] {
                    if {[info exists $item]} {
                        set _param $activity_args($item)
                        if {[llength [set $item]] > $agent_handle_length} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    the list length of the $item parameter is \
                                    is longer than the -agent_handle list \
                                    parameter"
                            return $returnList
                        }
                        foreach activity_value [set $item] {
                            set temp_index [lsearch [set $item] $activity_value]
                            if {[info exists valuesHltToIxLoad($activity_value)]} {
                                set activity_value $valuesHltToIxLoad($activity_value)
                            }
                            set temp_agent_handle [lindex $agent_handle $temp_index]
                            if {$activity_value != "na"} {
                                debug "$temp_command $_param \"$temp_agent_handle\" \"$activity_value\""
                                if {[catch {eval "$temp_command $_param \"$temp_agent_handle\" \"$activity_value\""} tmp_ret]} {
                                    catch {::IxLoad delete $temp_command}
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: $tmp_ret."
                                    return $returnList
                                }
                            }
                        }
                    }
                } 
            }
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            save                  \
                    -handle          $map_name             \
                    -type            map                   \
                    -target          $_target              \
                    -ixload_handle   $handler              \
                    -traffic_handle  $traffic_handle       \
                    -network_handle  $network_handle       \
                    -parent_handle   $parent_handle        ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            keylset returnList status  $::SUCCESS
            keylset returnList handles $map_name
            return $returnList
        }
        remove {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid map handle."
                return $returnList
            }
            # get handle properties
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $handle                      \
                    -key      [list ixload_handle type target]]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [lindex [keylget retCode value] 0]
            set handleType    [lindex [keylget retCode value] 1]
            set _target       [lindex [keylget retCode value] 2]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "map"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid map handle."
                return $returnList
            }
            
            if {$_target != $target} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a $target map handle."
                return $returnList
            }
            
            set _cmd [format "%s" "::IxLoad delete $ixLoadHandler"]
            debug "$_cmd"
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error deleting \
                        map.\n$error."
                return $returnList
            }
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            remove                \
                    -handle          $handle               ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        modify {
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid map handle."
                return $returnList
            }
            # get handle properties
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $handle                      \
                    -key      [list ixload_handle target   \
                    traffic_handle network_handle type]    ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler  [lindex [keylget retCode value] 0]
            set _target        [lindex [keylget retCode value] 1]
            set traffic_handle [lindex [keylget retCode value] 2]
            set network_handle [lindex [keylget retCode value] 3]
            set handleType     [lindex [keylget retCode value] 4]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "map"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid map handle."
                return $returnList
            }
            
            if {$_target != $target} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a $target map handle."
                return $returnList
            }
            
            # check if the provided network_handle has another traffic-network
            # mapping already made
            set retCode [::ixia::ixL47TrafficNetworkMappingExistence \
                    $handle $traffic_handle $network_handle]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            # check to see if valid handles exist
            set checkValidExistence "0x[info exists             \
                    ${_target}_network_handle][info exists  \
                    ${_target}_traffic_handle]"
            
            switch -- $checkValidExistence {
                0x11 {
                    set network_handle [set ${_target}_network_handle]
                    set traffic_handle [set ${_target}_traffic_handle    ]
                }
                0x01 {
                    set traffic_handle [set ${_target}_traffic_handle    ]
                }
                0x10 {
                    set network_handle [set ${_target}_network_handle]
                }
                default {
                }
            }

            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $network_handle              \
                    -key      [list ixload_handle parent_handle]  ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadNetworkHandler [lindex [keylget retCode value] 0]
            set parent_handle        [lindex [keylget retCode value] 1]
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $traffic_handle              \
                    -key      ixload_handle                ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadTrafficHandler [keylget retCode value]
            
            if {[info exists match_client_total_time]} {
                if {$match_client_total_time == 1} {
                    array unset server_mapping_args
                    array set server_mapping_args {
                        enable_mapping               enable
                        ixLoadNetworkHandler         network
                        ixLoadTrafficHandler         traffic
                        match_client_total_time       matchClientTotalTime
                        server_iterations            iterations
                    }
                }
            }
            
            set _command ""
            foreach item [array names ${_target}_mapping_args] {
                if {[info exists $item]} {
                    set _param [set ${_target}_mapping_args($item)]
                    if {[info exists valuesHltToIxLoad([set $item])]} {
                        set $item $valuesHltToIxLoad([set $item])
                    }
                    if {[set $item] != "na"} {
                        append _command " -$_param \"[set $item]\" "
                    }
                }
            }
            if {$_command != ""} {
                set _cmd "$ixLoadHandler config $_command"
                debug $_cmd
                if {[catch {eval $_cmd} handler]} {
                    catch {::IxLoad delete $handler}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $handler."
                    return $returnList
                }
            }
            
            if {$_target == "client" && [info exists agent_handle]} {
                set agent_handle_length [llength $agent_handle]
                foreach single_agent $agent_handle {
                    set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $single_agent                \
                    -key      parent_handle                ]
                
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                    if {[keylget retCode value] != $traffic_handle} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                agent_handle $single_agent is not part of \
                                -traffic_handle $traffic_handle"
                        return $returnList
                    }
                }
                foreach item [array names activity_args] {
                    if {[info exists $item]} {
                        set _param $activity_args($item)
                        if {[llength [set $item]] > $agent_handle_length} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    the list length of the $item parameter is \
                                    is longer than the -agent_handle list \
                                    parameter"
                            return $returnList
                        }
                        foreach activity_value [set $item] {
                            set temp_index [lsearch [set $item] $activity_value]
                            if {[info exists valuesHltToIxLoad($activity_value)]} {
                                set activity_value $valuesHltToIxLoad($activity_value)
                            }
                            set temp_agent_handle [lindex $agent_handle $temp_index]
                            set temp_command "$ixLoadHandler $_param \"$temp_agent_handle\" \"$activity_value\""
                            debug "$temp_command"
                            if {$activity_value != "na"} {
                                if {[catch {eval $temp_command} handler]} {
                                    catch {::IxLoad delete $handler}
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: $handler."
                                    return $returnList
                                }
                            }
                        }
                    }
                } 
            }
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            save                  \
                    -handle          $handle               \
                    -type            map                   \
                    -target          $_target              \
                    -ixload_handle   $ixLoadHandler        \
                    -traffic_handle  $traffic_handle       \
                    -network_handle  $network_handle       \
                    -parent_handle   $parent_handle        ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        enable -
        disable {
            set flag [expr {( $mode == "disable" ) ? 0 : 1}]
            
            # check to see if handle exists
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # check to see if handle is a valid handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }
            
            # get handle properties
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $handle                      \
                    -key      [list type ixload_handle target]]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            set handleType    [lindex [keylget retCode value] 0]
            set ixLoadHandler [lindex [keylget retCode value] 1]
            set _target       [lindex [keylget retCode value] 2]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "map"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid map handle."
                return $returnList
            }
            
            if {$_target != $target} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a $target map handle."
                return $returnList
            }
            
            set _cmd [format "%s" "$ixLoadHandler config -enable $flag"]
            debug "$_cmd"
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Couldn't $mode \
                        this agent.\n$error"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            return $returnList
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Argument -mode \
                    must be specified."
            return $returnList
        }
    }
}


proc ::ixia::ixL47TrafficNetworkMappingExistence {\
    map_handle traffic_hadle network_handle } {
    
    variable ixload_handles_array
    
    foreach {aName} [array names ixload_handles_array] {
        if {$aName == $map_handle} {
            continue;
        }
        set retCode [::ixia::ixL47HandlesArrayCommand \
                -mode     get_value                    \
                -handle   $aName                       \
                -key      [list type traffic_handle    \
                network_handle]                        ]
        
        if {[keylget retCode status] == $::FAILURE} {
            return $retCode
        }
        
        set _type           [lindex [keylget retCode value] 0]
        set _traffic_handle [lindex [keylget retCode value] 1]
        set _network_handle [lindex [keylget retCode value] 2]
        
        if {($_type != "map")} {
            continue;
        }
        
        if {$network_handle == $_network_handle} {
            keylset returnList status $::FAILURE
            keylset returnList log "This network\
                    already has a traffic mapped."
            return $returnList
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixL47Control {args} {
    variable ixload_handles_array
    variable ixload_test_controller
    variable ixload_log_engine
    variable ixload_clear_per_interface_stats
    variable ixload_csv_protocols
    variable ixloadVersion
    variable debug
    
    set protocols_list [list FTP HTTP Telnet]
    
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    set args [::ixia::escapeBackslash $args results_dir]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args

    if {[info exists results_dir]} {
        set results_dir [::ixia::escapeSpecialChars $results_dir]
    }
    
    array set control_args {
        force_ownership_enable         enableForceOwnership
        release_config_afterrun_enable enableReleaseConfigAfterRun
        reset_ports_enable             enableResetPorts
        stats_required                 statsRequired
    }
    
    switch -- $mode {
        add {
            if {[info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument -handle \
                        invalid for -mode $mode."
                return $returnList
            }
            # a new handle for the test
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode   get_handle \
                    -type   test       ]
            
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            set test_name [keylget retCode handle]
            
            set _cmd [format "%s" "::IxLoad new ixTest -name $test_name -csvInterval 2"]
            debug "$_cmd"
            if {[catch {eval $_cmd} ixLoadTestHandler]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Can't create a \
                        new control."
                return $returnList
            }
            
            set command ""
            foreach item [array names control_args] {
                if {[info exists $item]} {
                    set _param $control_args($item)
                    append command "-$_param [set $item] "
                }
            }
            if {$command != ""} {
                set _cmd [format "%s" "$ixLoadTestHandler config $command"]
                debug $_cmd
                if {[catch {eval $_cmd} error]} {
                    debug "::IxLoad delete $ixLoadTestHandler"
                    catch {::IxLoad delete $ixLoadTestHandler}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $error."
                    return $returnList
                }
            }
            
            # test is created. Now let's see about CommunityList            
            foreach {map_elem} $map_handle {
                set retCode [::ixia::ixL47HandlesArrayCommand \
                        -mode     get_value                    \
                        -handle   $map_elem                    \
                        -key      [list target ixload_handle]  ]
                if {[keylget retCode status] == $::FAILURE} {
                    catch {::IxLoad delete $ixLoadTestHandler}
                    return $retCode
                }
                set target        [lindex [keylget retCode value] 0]
                set ixload_handle [lindex [keylget retCode value] 1]
                set _cmd "$ixLoadTestHandler $target"
                append _cmd "CommunityList.appendItem -object $ixload_handle"
                set _cmd [format "%s" "$_cmd"]
                debug "$_cmd"
                if {[catch {eval $_cmd} error]} {
                    debug "::IxLoad delete $ixLoadTestHandler"
                    catch {::IxLoad delete $ixLoadTestHandler}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $error."
                    return $returnList
                }
            }
            # create test controller
            set tcOptions [list procName results_dir_enable results_dir]
            set tcArgsList ""
            foreach {elem} $tcOptions {
                if {[info exists $elem]} {
                    append tcArgsList " -$elem {[set $elem]}"
                }
            }
            set retCode [eval [format "%s %s" ::ixia::ixL47TestController \
                    $tcArgsList]]
            
            if {[keylget retCode status] == $::FAILURE} {
                catch {::IxLoad delete $ixLoadTestHandler}
                return $retCode
            }
            
            #saving test
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode            save                  \
                    -handle          $test_name            \
                    -ixload_handle   $ixLoadTestHandler    \
                    -type            test                  \
                    -parent_handle   $ixLoadTestHandler    ]
            if {[keylget retCode status] == $::FAILURE} {
                catch {::IxLoad delete $ixLoadTestHandler}
                return $retCode
            }
            
            keylset returnList status  $::SUCCESS
            keylset returnList handles $test_name
            return $returnList
        }
        modify {
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: For -mode $mode\
                        -handle otption must be provided."
                return $returnList
            }
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid control handle."
                return $returnList
            }
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode get_value                        \
                    -handle $handle                        \
                    -key ixload_handle                     ]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            set ixLoadHandler [keylget retCode value]
            set command ""
            foreach item [array names control_args] {
                if {[info exists $item]} {
                    set _param $control_args($item)
                    append command "-$_param [set $item] "
                }
            }
            if {$command != ""} {
                set _cmd [format "%s" "$ixLoadHandler config $command"]
                debug $_cmd
                if {[catch {eval $_cmd} error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $error."
                    return $returnList
                }
            }
            if {[info exists map_handle]} {
                foreach community {clientCommunityList serverCommunityList} {
                    set _cmd "$ixLoadHandler $community.indexCount"
                    set _cmd [format "%s" "$_cmd"]
                    debug $_cmd
                    if {[catch {eval $_cmd} count]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: $count."
                        return $returnList
                    }
                    for {set index 0} {$index < $count} {incr index} {
                        set _cmd [format "%s" "$ixLoadHandler \
                                $community.deleteItem $index"]
                        debug $_cmd
                        if {[catch {eval $_cmd} error]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    $error."
                            return $returnList
                        }
                    }
                }
                foreach {map_elem} $map_handle {
                    set retCode [::ixia::ixL47HandlesArrayCommand \
                            -mode     get_value                    \
                            -handle   $map_elem                    \
                            -key      [list target ixload_handle]  ]
                    if {[keylget retCode status] == $::FAILURE} {
                        return $retCode
                    }
                    set target        [lindex [keylget retCode value] 0]
                    set ixload_handle [lindex [keylget retCode value] 1]
                    set _cmd "$ixLoadHandler $target"
                    append _cmd "CommunityList.appendItem -object \
                            $ixload_handle"
                    set _cmd [format "%s" "$_cmd"]
                    debug "$_cmd"
                    if {[catch {eval $_cmd} error]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: $error."
                        return $returnList
                    }
                }
            }
            
            # modify test controller
            set tcOptions [list procName results_dir_enable results_dir]
            set tcArgsList ""
            foreach {elem} $tcOptions {
                if {[info exists $elem]} {
                    append tcArgsList " -$elem \"[set $elem]\""
                }
            }
            set retCode [eval [format "%s %s" ::ixia::ixL47TestController \
                    $tcArgsList]]
            
            if {[keylget retCode status] == $::FAILURE} {
                catch {::IxLoad delete $ixLoadTestHandler}
                return $retCode
            }
            
            keylset returnList status $::SUCCESS
            return $returnList
        }
        start {
            if {[isUNIX]} {
                if {![info exists ::ixTclSvrHandle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Not connected to TclServer."
                    return $returnList
                }
                set retValueClicks [eval "::ixia::SendToIxTclServer $::ixTclSvrHandle \
                        {clock clicks}"]
                set retValueSeconds [eval "::ixia::SendToIxTclServer $::ixTclSvrHandle \
                        {clock seconds}"]
            } else {
                set retValueClicks [clock clicks]
                set retValueSeconds [clock seconds]
            }
            keylset returnList clicks [format "%u" $retValueClicks]
            keylset returnList seconds [format "%u" $retValueSeconds]
        
            set args [::ixia::escapeBackslash $args results_dir]
            ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
                    -mandatory_args $mandatory_args
    
            if {![info exists handle]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: For -mode $mode\
                        -handle otption must be provided."
                return $returnList
            }
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid control handle."
                return $returnList
            }
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode get_value                        \
                    -handle $handle                        \
                    -key ixload_handle                     ]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            set ixLoadHandler  [keylget retCode value]
            set testController [keylget ixload_test_controller command]
            set commands [list]
            
            # Clear grid stats (per interface stats) if necessary and add/or
            # add per interface stats (grid stats)
            set pi_stat_cmd [format "%s" "$ixLoadHandler clearGridStats"]
            debug "$pi_stat_cmd"
            if {[catch {eval $pi_stat_cmd} retError]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to\
                        $pi_stat_cmd - $retError"
                return $returnList
            }
            set ixload_clear_per_interface_stats 0
                   
            foreach {arrayHandle} [array names ixload_handles_array] {
                set _retCode [::ixia::ixL47HandlesArrayCommand            \
                        -mode     get_value                               \
                        -key      [list parent_handle type ixload_handle] \
                        -handle   $arrayHandle                            ]
                
                if {[keylget _retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed in ::ixia::ixL47Control. \
                            [keylget _retCode log]"
                    return $returnList
                }
                set ret_parent_handle [lindex [keylget _retCode value] 0]
                set ret_type [lindex [keylget _retCode value] 1]
                if { $ret_type == "per_interface_statistic"} {
                    if {$ret_parent_handle == "N/A" || $ret_parent_handle == ""} {
                        
                        set pi_stat_cmd [lindex [keylget _retCode value] 2]
                        append pi_stat_cmd "-test $ixLoadHandler"
                        debug "$pi_stat_cmd"
                        if {[catch {eval $pi_stat_cmd} retError]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Failed to\
                                    $pi_stat_cmd - $retError"
                            return $returnList
                        }
                        
                        set _retCode [::ixia::ixL47HandlesArrayCommand \
                            -mode            modify                    \
                            -handle          $arrayHandle              \
                            -parent_handle   $ixLoadHandler             \
                            -ixload_handle   $pi_stat_cmd              ]
                                        
                        if {[keylget _retCode status] == $::FAILURE} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    [keylget _retCode log]"
                            return $returnList
                        }
                    }
                }
            }
            
            set checkStatAggr [::ixia::ixL47CheckStatAggr $ixLoadHandler]
            if {[keylget checkStatAggr status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                                [keylget checkStatAggr log]."
                return $returnList
            }
            
            set _cmd [format "%s" "::statCollectorUtils::StartCollector \
                    -command ::ixia::ixL47StatCollectorCommand"]
            lappend commands $_cmd
            
            if {[info exists debug] && $debug == 1} {
                set _cmd [format "%s" "$testController run $ixLoadHandler -autorepository test.rxf"]
            } else {
                set _cmd [format "%s" "$testController run $ixLoadHandler"]
            }
            
            lappend commands $_cmd
            set _cmd [format "%s" "vwait ::ixTestControllerMonitor"]
            lappend commands $_cmd
            set _cmd [format "%s" "::statCollectorUtils::StopCollector"]
            lappend commands $_cmd
            set _cmd [format "%s" "$testController releaseConfigWaitFinish"]
            lappend commands $_cmd
            
            foreach cmdItem $commands {
                debug "$cmdItem"
                if {[catch {eval $cmdItem} error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: $error."
                    return $returnList
                }
            }
            
            set commands ""
            set _countFileIds 0
            if {[isUNIX]} {
                # retrieve log file on the UNIX machine in current dir
                set _logFileName [$ixload_log_engine getFileName]
		        catch {
                    set _cmd [format "%s %s %s" {set _fileId [open} "$_logFileName" {w]} ]
                    lappend commands $_cmd
                    set tmpFilePath [::IxLoad eval set ::_IXLOAD_INSTALL_ROOT]
                    regsub -all {\\} $tmpFilePath / tmpFilePath
                    
                    if {$ixloadVersion >= 3.40} {
                        set tmpFilePath [file join $tmpFilePath TclScripts/remoteScriptingService]
                    } else {
                        set tmpFilePath [file join $tmpFilePath Client/tclext/remoteScriptingService]
                    }
                    debug "tmpFilePath = $tmpFilePath"
                    set _cmd [format "%s" {puts $_fileId [::IxLoad \
                            retrieveFile [file join $tmpFilePath $_logFileName] ]}]
                    lappend commands $_cmd
                    lappend commands {close $_fileId}
                } _error
                set results_dir [keylget ixload_test_controller dir]

                if {$results_dir != ""} {
                    # retrieve CSV files
                    if {[catch {file mkdir $results_dir} dir_err]} {
                        ixPuts "WARNING: $dir_err"
                    } else {
                        set _current_dir [pwd]
                        
                        cd $results_dir
                        debug "results_dir = $results_dir"
                        catch {
                            set nameList [list "Test_Client.csv"        \
                                    "Test_Server.csv"                   \
                                    "TestInfo.ini"                      \
                                    "test.xmd"                          ]

                            foreach protocol $protocols_list {
                                if {[info exists ixload_csv_protocols($protocol)]} {
                                    lappend nameList "${protocol}_Client.csv" \
                                            "${protocol}_Server.csv"
                                }
                            }

                            #mapping
                            foreach map_item [array names ixload_handles_array map*] {
                                set retCode [::ixia::ixL47HandlesArrayCommand \
                                        -mode            get_value             \
                                        -handle          $map_item             \
                                        -key             [list traffic_handle  \
                                        network_handle ]                       ]
                                if {[keylget retCode status] == $::FAILURE} {
                                    return $retCode
                                }
                                set _tHandle [lindex [keylget retCode value] 0]
                                set _nHandle [lindex [keylget retCode value] 1]
                                set mapping($_tHandle) $_nHandle 
                            }

                            #searching traffic
                            foreach agent_item [array names ixload_handles_array agent*] {
                                set retCode [::ixia::ixL47HandlesArrayCommand \
                                        -mode            get_value             \
                                        -handle          $agent_item           \
                                        -key             [list parent_handle   \
                                        target] ]                    
                                if {[keylget retCode status] == $::FAILURE} {
                                    return $retCode
                                }
                                set traffic_handle [lindex [keylget retCode value] 0]
                                set target         [lindex [keylget retCode value] 1]
                                switch -- $target {
                                    client {
                                        set target "Client"
                                    }
                                    server {
                                        set target "Server"
                                    }
                                }
                                
                                foreach protocol $protocols_list {
                                    if {[info exists ixload_csv_protocols($protocol)]} {
                                        set fileName "${protocol}_${target}_-_Default_CSV_Logs_"
                                        append fileName "${agent_item}_${traffic_handle}@"
                                        set network_handle $mapping($traffic_handle)
                                        append fileName "${network_handle}.csv"
                                        lappend nameList $fileName
                                    }
                                }
                            }

                            foreach fileName $nameList {
                                set tmp_file_name [file join $results_dir \
                                                                    $fileName]

                                if {![info exists ::ixTclSvrHandle]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "Not connected to TclServer."
                                    return $returnList
                                }
                                set tmp_file_name [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                                            \{file normalize $tmp_file_name\}]
                                if {![eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                                            \{file exists \{$tmp_file_name\}\}]} {
                                    continue
                                }
                                set _fileId${_countFileIds} ""
                                set theFileId _fileId${_countFileIds}
                                set _newCmd [::ixia::ixL47RetrieveFileCommand \
                                                $results_dir $fileName]
                                set _toAdd [format "%s %s %s" "set fileId" {[open [file \
                                                join} "$results_dir $fileName\] w\]"]
                                lappend commands $_toAdd
                                lappend commands $_newCmd
                                lappend commands {close $fileId}
                                incr _countFileIds
                            }
                        } _someErr
                        debug "==== _someErr = $_someErr"
                        # back
                        cd $_current_dir
                    }
                }
                foreach cmdItem $commands {
                    debug "$cmdItem"
                    if {[catch {eval $cmdItem} error]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: $error."
                        return $returnList
                    }
                    debug "Ret value: $error"
                }
            }
            
            keylset returnList status $::SUCCESS
            return $returnList
        }
    }
}


proc ::ixia::ixL47TestController {args} {
    variable ixload_test_controller
    
    set opt_args [eval [format "%s %s" ::ixia::ixL47GetOptionalArgs $args]]
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    # Create test controller, if test controller was not created
    # previously
    set test_controller_exists [keylget ixload_test_controller created]
    if {$test_controller_exists == 0} {
        if {![info exists results_dir_enable]} {
            set results_dir_enable 0
        }
        set _cmd [format "%s" "::IxLoad new ixTestController \
                -outputDir $results_dir_enable"]
        debug "$_cmd"
        if {[catch {eval $_cmd} testController]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to\
                    ::IxLoad new ixTestController -outputDir 1. \
                    $testController"
            return $returnList
        }
        
        keylset ixload_test_controller created 1
        keylset ixload_test_controller command $testController
    } else  {
        set testController [keylget ixload_test_controller command]
        if {[info exists results_dir_enable] && \
                ([$testController cget -outputDir] != $results_dir_enable)} {
            set _cmd "$testController config -outputDir $results_dir_enable"
            debug "$_cmd"
            if {[catch {eval $_cmd} retError]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to $_cmd. \
                        $retError"
                return $returnList
            }
            if {$results_dir_enable == 0} {
                catch {keyldel ixload_test_controller dir}
            }
        }
    }
    
    if {[info exists results_dir_enable] && $results_dir_enable && \
            [info exists results_dir] && ($results_dir != "")} {
        
        set retCatch [catch {keyget ixload_test_controller dir} _results_dir]
        
        if {$retCatch || ((!$retCatch) && ($_results_dir != $results_dir))} {
            set _cmd [format "%s" "$testController setResultDir \
                    {$results_dir}"]
            debug "$_cmd"
            if {[catch {eval $_cmd} retError]} {
                catch {::IxLoad delete $testController}
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to\
                        $testController setResultDir $results_dir. \
                        $retError"
                return $returnList
            }
            keylset ixload_test_controller dir $results_dir
        }
    }
    
    if {$test_controller_exists == 0} {
        set _cmd [format "%s" "::statCollectorUtils::Initialize \
                -testServerHandle [$testController getTestServerHandle]"]
        debug "$_cmd"
        if {[catch {eval $_cmd} error]} {
            catch {::IxLoad delete $testController}
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to\
                    initialize ::statCollectorUtils.\n$error"
            return $returnList
        }
        set _cmd [format "%s" "::statCollectorUtils::ClearStats"]
        debug "$_cmd"
        if {[catch {eval $_cmd} error]} {
            catch {::IxLoad delete $testController}
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: $error."
            return $returnList
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixL47StatCollectorCommand {args} {
    variable ixload_returned_stats
    variable ixload_registered_stats
    debug "args = $args"
    set ixLoadVersion [package provide IxLoad]
    
    set timestamp [lindex [lindex $args 1] 1]
    set stats     [lindex [lindex $args 1] 3]
    
    foreach {regStat} [lsort -dictionary [array names ixload_registered_stats]] \
            {retStat} $stats {
        
        set retStatValue [lindex $retStat 1]
        set regStatHandle [keylget ixload_registered_stats($regStat) \
                stat_handle]
        
        set regStatName   [keylget ixload_registered_stats($regStat) \
                stat_name]
        set regStatType   [keylget ixload_registered_stats($regStat) \
                stat_type]
        
        if {[llength $regStatName] > 1} {
            set stName [lindex $regStatName 1]
            set stIp   [lindex $regStatName 0]
            regsub -all {\.} $stIp { } stIp 
            keylset ixload_returned_stats                                \
                    $regStatHandle.$regStatType.$stIp.$stName.$timestamp \
                    $retStatValue
        } else {
            keylset ixload_returned_stats                                \
                    $regStatHandle.$regStatType.$regStatName.$timestamp  \
                    $retStatValue
        }
    }
}


proc ::ixia::ixL47RetrieveFileCommand {_results_dir _fileName} {
    if {[file exists $_fileName]} {
        set _newFileName $_fileName
        set _cs [clock seconds]
        set _c [clock format $_cs -format %Y%m%d]
        append _newFileName $_c
        set _c [clock format $_cs -format %H%M%S]
        append _newFileName $_c
        file rename $_fileName $_newFileName
    }
    set fileId [open $_fileName w]
    lappend fileList $fileId

    set tmpFilePath [::IxLoad eval set ::_IXLOAD_INSTALL_ROOT]
    regsub -all {\\} $tmpFilePath / tmpFilePath
    set tmpFilePath [file join $tmpFilePath Client/tclext/remoteScriptingService]
    set _cmd [format "%s %s %s" {puts $fileId [::IxLoad \
                retrieveFile [file join \
                $tmpFilePath} "$_results_dir" "$_fileName\]\]"]
    return $_cmd    
}


proc ::ixia::ixL47Statistics {args} {

    # Arguments
    set mandatory_args {
        -mode        CHOICES add clear get
    }
    
    set opt_args {
        -handle              ANY
        -aggregation_type    CHOICES sum max min average rate maxrate
                             CHOICES minrate averagerate
                             CHOICES weighted_average string 
                             DEFAULT sum
        -stat_name           ALPHANUM
        -stat_type           CHOICES client server
                             DEFAULT client
        -filter_type         CHOICES port card chassis traffic map
        -filter_value        ANY
        -protocol            CHOICES telnet http ftp sip video
        -procName            ANY
        -ip_list             IP
    }
    
    if {[catch  {::ixia::parse_dashed_args -args $args -optional_args $opt_args \
                    -mandatory_args $mandatory_args} retError]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retError
        return $returnList
    }   

    if {[info exists aggregation_type] && $aggregation_type == "string"} {
        keylset returnList status $::FAILURE
        keylset returnList log "Error: aggregation_type $aggregation_type not \
                supported with this protocol."
        return $returnList
    }

    if {[info exists ip_list] || $mode != "add"} {
        set returnList [::ixia::ixL47PerInterfaceStatistics $args]
        return $returnList
    }

    if {$mode != "add"} {
        removeDefaultOptionVars $opt_args $args
    }
    
    variable ixload_${protocol}_client_stats
    variable ixload_${protocol}_server_stats
    variable ixload_registered_stats
    variable ixload_returned_stats
    variable ixload_handles_array
    
    array set statTypesArray [list  \
            client         Client   \
            server         Server   \
            ]
    
    array set aggregationTypesArray [list       \
            sum                 kSum            \
            max                 kMax            \
            min                 kMin            \
            average             kAverage        \
            rate                kRate           \
            maxrate             kMaxRate        \
            minrate             kMinRate        \
            averagerate         kAverageRate    \
            weighted_average    kWeightedAverage\
            string              kString         \
            ]
    
    array set filterTypesArray [list           \
            port        Port                   \
            card        Card                   \
            chassis     Chassis                \
            traffic     Activity               \
            map         Traffic-NetworkMapping ]
    
    
    array set protocol_names [list  \
            http      HTTP          \
            ftp       FTP           \
            telnet    Telnet        \
            sip       SIP           \
            video     Video         ]
    
    # Create test controller, if test controller was not created previously
    set tcOptions [list procName results_dir_enable results_dir]
    set tcArgsList ""
    foreach {elem} $tcOptions {
        if {[info exists $elem]} {
            append tcArgsList " -$elem \"[set $elem]\""
        }
    }
    set retCode [eval [format "%s %s" ::ixia::ixL47TestController \
            $tcArgsList]]
    
    if {[keylget retCode status] == $::FAILURE} {
        return $retCode
    }
    
    switch -- $mode {
        add {
            if {![info exists stat_name]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When\
                        -mode is $mode -stat_name must be provided."
                return $returnList
            }
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode get_handle \
                    -type statistic  ]
            
            if {[keylget retCode status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]."
                return $returnList
            }
            set nextStatHandle [keylget retCode handle]
            while {[llength $stat_name] > [llength $stat_type]} {
                lappend stat_type [lindex $stat_type end]
            }
            while {[llength $stat_name] > [llength $aggregation_type]} {
                lappend aggregation_type [lindex $aggregation_type end]
            }
            if {[info exists filter_type]} {
                while {[llength $stat_name] > [llength $filter_type]} {
                    lappend filter_type  [lindex $filter_type end]
                }
            }
            if {[info exists filter_value]} {
                while {[llength $stat_name] > [llength $filter_value]} {
                    lappend filter_value [lindex $filter_value end]
                }
            }
            
            set statIndex 0
            
            # Option -stat_name can support a list of statistics
            foreach {statName} $stat_name {
                set statisticType $statTypesArray([lindex $stat_type \
                        $statIndex])
                
                if {$statisticType == "Client"} {
                    if {![info exists \
                            ixload_${protocol}_client_stats($statName)]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Invalid\
                                client statistic $statName."
                        return $returnList
                    }
                    set statisticName [set \
                            ixload_${protocol}_client_stats($statName)]
                } else  {
                    if {![info exists \
                            ixload_${protocol}_server_stats($statName)]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Invalid\
                                server statistic $statName."
                        return $returnList
                    }
                    set statisticName [set \
                            ixload_${protocol}_server_stats($statName)]
                }
                
                set statisticFilter      {}
                set statisticAggregation $aggregationTypesArray([lindex \
                        $aggregation_type $statIndex])
                
                if {[info exists filter_type] && [info exists filter_value]} {
                    set filterTypes  [lindex $filter_type  $statIndex]
                    set filterValues [lindex $filter_value $statIndex]
                    
                    # Each statistic supports a list of filters
                    foreach {filterType} $filterTypes filterValue $filterValues {
                        switch -- $filterType {
                            port {
                                if {![regexp {^[0-9]+/[0-9]+/[0-9]+$} \
                                        $filterValue]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName:\
                                            Invalid filter value $filterValue. \
                                            The correct format is\
                                            chassis/card/port."
                                    return $returnList
                                }
                                lappend statisticFilter \
                                        "$filterTypesArray($filterType)"
                                
                                lappend statisticFilter \
                                        "Chassis[get_valid_chassis_id_ixload [lindex [split $filterValue /] \
                                        0]]/Card[lindex [split $filterValue /]  \
                                        1]/Port[lindex [split $filterValue /] 2]"
                            }
                            card {
                                if {![regexp {^[0-9]+/[0-9]+$}  $filterValue]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName:\
                                            Invalid filter value $filterValue. \
                                            The correct format is\
                                            chassis/card."
                                    return $returnList
                                }
                                lappend statisticFilter \
                                        "$filterTypesArray($filterType)"
                                
                                lappend statisticFilter \
                                        "Chassis[get_valid_chassis_id_ixload [lindex [split $filterValue /] \
                                        0]]/Card[lindex [split $filterValue /] 1]"
                            }
                            chassis {
                                if {![regexp {^[0-9]+$} $filterValue]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName:\
                                            Invalid filter value $filterValue. \
                                            The correct format is\
                                            chassis/card."
                                    return $returnList
                                }
                                lappend statisticFilter \
                                        "$filterTypesArray($filterType)"
                                
                                lappend statisticFilter \
                                        "Chassis[get_valid_chassis_id_ixload [lindex [split $filterValue /] 0]]"
                            }
                            traffic {
                                if {![info exists ixload_handles_array($filterValue)]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName:\
                                            Invalid filter value $filterValue. \
                                            Cannot find filter value in\
                                            ixload_handles_array."
                                    return $returnList
                                }
                                # get handle properties
                                set retCode [::ixia::ixL47HandlesArrayCommand \
                                        -mode     get_value                    \
                                        -handle   $filterValue                 \
                                        -key      type                         ]
                                
                                if {[keylget retCode status] == $::FAILURE} {
                                    return $retCode
                                }
                                # check to see if handle is a valid traffic handle
                                if {[keylget retCode value] != "traffic"} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName:\
                                            Argument -filter_value $filterValue\
                                            is not a valid traffic handle."
                                    return $returnList
                                }
                                lappend statisticFilter \
                                        "$filterTypesArray($filterType)"
                                
                                lappend statisticFilter $filterValue
                            }
                            map {
                                # This condition should be changed when adding
                                # Traffic-Network mapping
                                if {![info exists ixload_handles_array($filterValue)]} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName:\
                                            Invalid filter value $filterValue. \
                                            Cannot find filter value in\
                                            ixload_handles_array."
                                    return $returnList
                                }
                                # get handle properties
                                set retCode [::ixia::ixL47HandlesArrayCommand \
                                        -mode     get_value                    \
                                        -handle   $filterValue                 \
                                        -key      type                         ]
                                
                                if {[keylget retCode status] == $::FAILURE} {
                                    return $retCode
                                }
                                # check to see if handle is a valid map handle
                                if {[keylget retCode value] != "map"} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName:\
                                            Argument -filter_value $filterValue\
                                            is not a valid traffic-network map\
                                            handle."
                                    return $returnList
                                }
                                lappend statisticFilter \
                                        "$filterTypesArray($filterType)"
                                
                                lappend statisticFilter $filterValue
                            }
                        }
                    }
                }
                
                set indexList [lsort -dictionary \
                        [array names ixload_registered_stats]]
                
                if {$indexList == ""} {
                    set nextStatIndex 1
                } else  {
                    set nextStatIndex [mpexpr [lindex $indexList end] + 1]
                }
                
                set _protocol $protocol_names([string tolower ${protocol}])
                
                set _stat_cmd "::statCollectorUtils::AddStat               \
                        -caption         Watch_Stat_${nextStatIndex}       \
                        -statSourceType  {$_protocol ${statisticType}}     \
                        -statName        {$statisticName}                  \
                        -aggregationType $statisticAggregation             \
                        -filterList      {$statisticFilter}                "
                
                debug $_stat_cmd
                set retCode [catch {eval $_stat_cmd} retError]
                if {$retCode} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to\
                            ::statCollectorUtils::AddStat. \
                            Return code was: $retError."
                    return $returnList
                }
                
                set kStatList ""
                
                keylset kStatList stat_handle      $nextStatHandle
                
                keylset kStatList stat_caption     "Watch_Stat_${nextStatIndex}"
                
                keylset kStatList stat_type        [lindex $stat_type $statIndex]
                
                keylset kStatList stat_name        $statName
                
                keylset kStatList stat_aggregation [lindex \
                        $aggregation_type $statIndex]
                
                keylset kStatList stat_filter      $statisticFilter
                
                set ixload_registered_stats($nextStatIndex) $kStatList
                
                incr statIndex
            }
            
            set retCode [::ixia::ixL47HandlesArrayCommand  \
                    -mode            save                   \
                    -handle          $nextStatHandle        \
                    -type            statistic              \
                    -target          $stat_type             \
                    -ixload_handle   ::statCollectorUtils:: \
                    -parent_handle   ""                     ]
            
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            
            keylset returnList handles $nextStatHandle
        }
        default {
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixL47PerInterfaceStatistics {args} {
    # Arguments
    set args [lindex $args 0]
    
    set mandatory_args {
        -mode        CHOICES add clear get
    }
    
    set opt_args {
        -handle              ANY
        -procName            ANY
        -stat_type           CHOICES client server
                             DEFAULT client
        -aggregation_type    CHOICES sum max min average rate maxrate
                             CHOICES minrate averagerate
                             CHOICES weighted_average string 
                             DEFAULT sum
        -ip_list             IP
        -stat_name           ALPHANUM
        -protocol            CHOICES telnet http ftp
    }
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $mandatory_args

    if {[llength $stat_type] > 1} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: For per_interface_stats\
                -stat_type argument can only have one value"
        return $returnList
    }

    variable ixload_per_interface_stats
    variable ixload_registered_stats
    variable ixload_returned_stats
    variable ixload_handles_array
    variable ixload_clear_per_interface_stats
    
    array set statTypesArray [list  \
            client         Client   \
            server         Server   \
            ]
    
    array set aggregationTypesArray [list       \
            sum                 kSum            \
            max                 kMax            \
            min                 kMin            \
            average             kAverage        \
            rate                kRate           \
            maxrate             kMaxRate        \
            minrate             kMinRate        \
            averagerate         kAverageRate    \
            weighted_average    kWeightedAverage\
            string              kString         \
            ]
    
    # Create test controller, if test controller was not created previously
    switch -- $mode {
        add {
            if {![info exists stat_name] || ![info exists ip_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: For \
                per_interface_stats -stat_name and -ip_list must be provided."
                return $returnList
            }
            
            set retCode [::ixia::ixL47HandlesArrayCommand \
                    -mode get_handle \
                    -type per_interface_statistic  ]
            
            if {[keylget retCode status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]."
                return $returnList
            }
            set nextStatHandle [keylget retCode handle]
            set per_interface_aggregation_type $aggregation_type
            
            while {[llength $stat_name] > [llength $per_interface_aggregation_type]} {
                lappend per_interface_aggregation_type [lindex \
                        $per_interface_aggregation_type end]
            }
            
            set tmp_first_ip [lindex $ip_list 0]
            if {[isIpAddressValid $tmp_first_ip]} {
                set ipType IPv4
            } else {
                if {[::ipv6::isValidAddress $tmp_first_ip]} {
                    set ipType IPv6
                } else  {
                    # ERROR
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            invalid IP address $tmp_first_ip."
                    return $returnList
                }
            }
            
            set pi_stat_list ""
            
            foreach pi_ip $ip_list {
                if {[isIpAddressValid $pi_ip]} {
                    set pi_ipType IPv4
                } else {
                    if {[::ipv6::isValidAddress $pi_ip]} {
                        set pi_ipType IPv6
                    } else  {
                        # ERROR
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                invalid IP address $pi_ip."
                        return $returnList
                    }
                }
                if {$pi_ipType != $ipType} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            All IP addresses must be of same type, \
                            IPv4 or IPv6."
                    return $returnList
                }
                foreach pi_stat_name $stat_name {
                    lappend pi_stat_list [list $pi_ip $pi_stat_name]
                }
            }
            
            set statisticType $statTypesArray($stat_type)            
            set cmd_stat_list ""
            foreach tmp_stat_name $stat_name tmp_agg_type \
                                            $per_interface_aggregation_type {
                if {$statisticType == "Client"} {
                    if {![info exists \
                            ixload_per_interface_stats($tmp_stat_name)]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Invalid\
                                client statistic $tmp_stat_name."
                        return $returnList
                    }
                    set statisticName [set \
                            ixload_per_interface_stats($tmp_stat_name)]
                } else  {
                    if {![info exists \
                            ixload_per_interface_stats($tmp_stat_name)]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Invalid\
                                server statistic $tmp_stat_name."
                        return $returnList
                    }
                    set statisticName [set \
                            ixload_per_interface_stats($tmp_stat_name)]
                }
                
                set statisticAggregation $aggregationTypesArray($tmp_agg_type)
                lappend cmd_stat_list "\"$statisticName\" \"$statisticAggregation\""
            }
                    
            # Option -stat_name can support a list of statistics
            foreach {statName} $pi_stat_list {
                set tmp_stat_name [lindex $statName 1]
                
                set statIndex [lsearch $stat_name $tmp_stat_name]
                
                set indexList [lsort -dictionary \
                        [array names ixload_registered_stats]]
                
                if {$indexList == ""} {
                    set nextStatIndex 1
                } else  {
                    set nextStatIndex [mpexpr [lindex $indexList end] + 1]
                }
                
                
                set kStatList ""
                
                keylset kStatList stat_handle      $nextStatHandle
                
                keylset kStatList stat_caption     "Watch_Stat_${nextStatIndex}"
                
                keylset kStatList stat_type        $stat_type
                
                keylset kStatList stat_name        $statName
                
#                keylset kStatList stat_ip          [lindex $statName 0]
                
                keylset kStatList stat_aggregation [lindex \
                        $per_interface_aggregation_type $statIndex]
                
                set ixload_registered_stats($nextStatIndex) $kStatList
            }
            
            set cmd_ip_list ""
            foreach tmp_ip $ip_list {
                if {[lsearch $cmd_ip_list $tmp_ip] == -1} {
                    append cmd_ip_list "\"$tmp_ip\" "
                }
            }
            
            set _stat_cmd "::statCollectorUtils::AddPerInterfaceStats       \
                    -statSourceType  \"Interface $ipType - $statisticType\" \
                    -statList        {$cmd_stat_list}                       \
                    -ipList          [list $cmd_ip_list]                    "
            
            set retCode [::ixia::ixL47HandlesArrayCommand   \
                    -mode            save                   \
                    -handle          $nextStatHandle        \
                    -type            per_interface_statistic\
                    -target          $stat_type             \
                    -ixload_handle   $_stat_cmd             \
                    -parent_handle   ""                     ]
            
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            keylset returnList handles $nextStatHandle
        }
        clear {
            set ixload_clear_per_interface_stats 1
            set _cmd [format "%s" "::statCollectorUtils::ClearStats"]
            debug "$_cmd"
            if {[catch {eval $_cmd} retError]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to\
                        ::statCollectorUtils::ClearStats. \
                        $retError"
                return $returnList
            }
            
            foreach {arrayHandle} [array names ixload_handles_array] {
                set retCode [::ixia::ixL47HandlesArrayCommand      \
                        -mode     get_value                        \
                        -key      [list parent_handle type]        \
                        -handle   $arrayHandle                     ]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed in\
                            ::ixia::ixL47PerInterfaceStatistics. \
                            [keylget retCode log]"
                    return $returnList
                }
                set ret_parent_handle [lindex [keylget retCode value] 0]
                set ret_type [lindex [keylget retCode value] 1]
                if { $ret_type == "per_interface_statistic" || \
                                                    $ret_type == "statistic"} {
                    if { $ret_type == "per_interface_statistic"} {
                        if {$ret_parent_handle != "N/A" && $ret_parent_handle != ""} {
                            set _cmd [format "%s" "$ret_parent_handle clearGridStats"]
                            debug "$_cmd"
                            if {[catch {eval $_cmd} retError]} {
                                keylset returnList status $::FAILURE
                                keylset returnList log "ERROR in $procName: Failed to\
                                        $_cmd - $retError"
                                return $returnList
                            }
                            set ixload_clear_per_interface_stats 0
                        }
                    }
                    set retCode [::ixia::ixL47HandlesArrayCommand \
                        -mode            remove                   \
                        -handle          $arrayHandle             ]            
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }
                }
            }
            set ixload_returned_stats ""
            array unset ixload_registered_stats
            array set ixload_registered_stats ""
        }
        get {
            if {![info exists handle]} {
                set returnList $ixload_returned_stats
            } else  {
                # check to see if handler is ok
                if {![info exists ixload_handles_array($handle)]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument\
                            -handle $handle is not a valid configuration handle."
                    return $returnList
                }
                # getting object properties
                set retCode [::ixia::ixL47HandlesArrayCommand \
                        -mode            get_value             \
                        -handle          $handle               \
                        -key             type                  ]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: \
                            [keylget retCode log]."
                    return $returnList
                }
                
                set type [keylget retCode value]
                if {$type != "per_interface_statistic" && $type != "statistic"} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument\
                            -handle $handle is not a valid statistic handle."
                    return $returnList
                }
                if {[catch {keylget ixload_returned_stats $handle}]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: There are no\
                            available statistics for -handle $handle."
                    return $returnList
                }
                keylset returnList $handle \
                        [keylget ixload_returned_stats $handle]
            }
        }
        default {
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixL47GetProperty {handleName protocol} {
    set count [regsub {^([a-zA-Z_]+)([0-9]+)$} $handleName {\1} handleName]
    if {$count} {
        switch -- $handleName {
            networkRange  { return network_pool }
            pool          { return router_pool }
            networkClient -
            networkServer {
                return network
            }
            trafficClient {
                return client
            }
            trafficServer {
                return server
            }
            dns_server -
            dns_suffix {
                return dns
            }
            agent -
            action -
            headerlist -
            profile -
            map {
                return $handleName
            }
            requestHeader {
                return request_header
            }
            page {
                return web_page
            }
            header {
                return response_header
            }
            cookielist {
                return cookie
            }
            cookie {
                return cookie_content
            }
            realFile {
                return real_file
            }
        }
    }
    return "unknown"
}


proc ::ixia::ixL47buildStatsCatalog {testHandle} {
    variable ::ixia::ixload_stat_catalog

    array set aggTypes {
        0 sum
        1 max
        2 min
        3 average
        4 weighted_average
        5 rate
        6 maxrate
        7 minrate
        8 averagerate
    }

    debug "$testHandle getStatCatalog"
    if {[catch {$testHandle getStatCatalog} statCatalog]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Error: $statCatalog"
        return $returnList
    }

    foreach statItemList $statCatalog {
        if {[catch {$statItemList cget -statSpecList} statSpecList]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Error: $statSpecList"
            return $returnList
        }
        foreach statObj $statSpecList {
            if {[catch {$statObj cget -name} statName]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Error: $statName"
                return $returnList
            }
            set ixload_stat_catalog($statName) ""
            if {[catch {$statObj cget -availableAggregationTypeList} \
                                            availableAggregationTypeList]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Error: $statName"
                return $returnList
            }
            foreach statAggr $availableAggregationTypeList {
                if {[info exists aggTypes($statAggr)]} {
                    lappend ixload_stat_catalog($statName) $aggTypes($statAggr)
                }
            }
        }
    }

    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::ixL47CheckStatAggr {testHandle} {
    variable ::ixia::ixload_stat_catalog
    variable ::ixia::ixload_registered_stats

    set statCatalog [::ixia::ixL47buildStatsCatalog $testHandle]
    if {[keylget statCatalog status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "[keylget statCatalog log]."
        return $returnList
    }

    foreach statName [array names ixload_registered_stats] {
        set statInfo $ixload_registered_stats($statName)
        set stat_name [keylget statInfo stat_name]
        if {[llength $stat_name] > 1} {
            # This is a per interface statistic
            continue
        }
        set protocol [lindex [split [keylget statInfo stat_name] {_}] 0]
        set type     [keylget statInfo stat_type]

        set statRealName [set ::ixia::ixload_${protocol}_${type}_stats($stat_name)]

        set aggregation [keylget statInfo stat_aggregation]
        if {![info exists ixload_stat_catalog($statRealName)]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Error: Could not find statistic \
                            $statRealName in statCatalog"
            return $returnList
        } else {
            if {[lsearch $ixload_stat_catalog($statRealName) $aggregation] == -1} {
                keylset returnList status $::FAILURE
                keylset returnList log "Error: Aggregation type $aggregation \
                        is not supported for statistic $stat_name"
                return $returnList
            }
        }
    }

    keylset returnList status $::SUCCESS
    return $returnList
}
