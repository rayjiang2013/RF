proc ::ixia::checkIxLoad {protocol} {
    variable ixLoadLoaded
    variable ixLoadChassisConnected
    variable ixload_chassis_list
    variable ixload_tcl_server
    variable ixload_chassis_chain
    variable ixload_logger
    variable ixload_log_engine
    variable ixloadVersion
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
        if {$::tcl_platform(platform) == "unix"} {
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
            $logEngine setLevels $::ixLogger(kLevelDebug) $::ixLogger(kLevelError)
            debug "$logEngine setLevels $::ixLogger(kLevelDebug) $::ixLogger(kLevelError)"
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

    if {$ixLoadLoaded == $::FAILURE} {
        $ixAppPluginManager load "$protocol"
        debug "$ixAppPluginManager load $protocol"
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


proc ::ixia::ixLoadHLTCleanUp {} {
    variable ixLoadLoaded
    variable ixLoadChassisConnected
    variable ixload_handles_array
    variable ixload_chassis_chain
    variable ixload_test_controller
    variable ixload_registered_stats
    variable ixload_returned_stats
    variable ixload_logger
    variable ixload_log_engine
    variable ixload_tcl_server
    variable ixload_chassis_list
    global ixAppPluginManager
    
    if {![info exists ixLoadChassisConnected]} {
        return
    }
    set deletedObjects [list]
    foreach handler [lsort [array names ixload_handles_array]] {
        set ixLoadObject [keylget ixload_handles_array($handler) \
                ixload_handle]
        set index [lsearch $deletedObjects $ixLoadObject]
        if {$index < 0} {
            set _cmd [format "%s" "::IxLoad delete $ixLoadObject"]
            debug $_cmd
            catch {eval $_cmd}
            lappend deletedObjects $ixLoadObject
        }
    }
    
    if {[keylget ixload_test_controller created] == 1} {
        set testController [keylget ixload_test_controller command]
    } else  {
        set testController ""
    }
    set toDeleteMore [list]
    if [info exists ixload_chassis_chain] {
        lappend toDeleteMore $ixload_chassis_chain
    }
    lappend toDeleteMore $ixload_logger
    lappend toDeleteMore $ixload_log_engine
    lappend toDeleteMore $testController
    #    lappend toDeleteMore $ixAppPluginManager
    foreach item $toDeleteMore {
        set _cmd [format "%s" "::IxLoad delete $item"]
        debug $_cmd
        catch {eval $_cmd}
        lappend deletedObjects $item
    }
    
    array set ixload_handles_array ""
    if [info exists ixload_chassis_chain] {
        unset ixload_chassis_chain
    }
    
    set ixload_test_controller {{created 0}}
    array set ixload_registered_stats ""
    set ixload_returned_stats ""
    set ixload_tcl_server ""
    set ixload_chassis_list [list]
    
    set ixLoadLoaded           $::FAILURE
    set ixLoadChassisConnected $::FAILURE
    
    catch {::IxLoad disconnect}
    
    debug "::IxLoad disconnect\nLIST: $deletedObjects"
}


proc ::ixia::ixLoadGetIpType {IpAddress argslist} {
    upvar $IpAddress ipAddress
    upvar $argslist  args_list
    
    if {[isIpAddressValid $ipAddress]} {
        set ipType 1
    } else {
        if {[::ipv6::isValidAddress $ipAddress]} {
            set ipType 2
        } else  {
            # ERROR
            return 1
        }
    }
    lappend args_list "-ipType"
    lappend args_list "$ipType"
    
    # OK
    return 0
}


proc ::ixia::ixLoadGetChassisChain { procName chassis } {
    variable ixload_chassis_chain
    
#    debug "ixLoadGetChassisChain: CHASSIS=$ixload_chassis_chain"
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

proc ::ixia::ixLoadGetCardType { procName chassis card port} {
    variable ixload_cardtype_array
    
    if {[card get $chassis $card]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Can't get card data for \
                card $chassis/$card."
        return $returnList
    }
    set cardType [ card cget -type ]
    set cardName [ card cget -typeName ]
    
    set portMemory 0
    if {[port isValidFeature $chassis $card $port portFeatureLocalCPU] == 0} {
        foreach mem {256 1G} {
            if {[regexp "$mem" $cardName]} {
                set portMemory $mem
                break
            }
        }
    } else  {
        if {[portCpu get $chassis $card $port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Can't get card data for \
                    card $chassis/$card."
            return $returnList
        }
        set portMemory [ portCpu cget -memory ]
        debug "PORT MEMORY = $portMemory"
        if {$portMemory == "0"} {
            foreach mem {256 1G} {
                if {[regexp "$mem" $cardName]} {
                    set portMemory $mem
                    break
                }
            }
        }
    }

#kCardPCDAP
    set supportedCards [list 69 70 79 83 84 85 86 87 89 90 91 92 98]
    if {[lsearch $supportedCards $cardType] < 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Card $cardName is not \
                supported."
        return $returnList
    }
    debug "ixLoadGetCardType:\nCARDTYPE=$cardType\nCARD NAME=$cardName"
    #    debug "portMemory=$portMemory"
    switch -- $portMemory {
        256 {
            set ixload_cardtype_array(69) $::ixCard(kCard1000Sfps4_256)
            set ixload_cardtype_array(70) $::ixCard(kCard1000Txs4_256)
            set ixload_cardtype_array(85) $::ixCard(kCard1000Stxs4_256)
            set ixload_cardtype_array(86) $::ixCard(kCard1000Stxs2_256)
            set ixload_cardtype_array(87) $::ixCard(kCard1000Stxs1_256)
        }
        1G -
        1024 {
            set ixload_cardtype_array(83) $::ixCard(kCard1000AlmT8_1GB)
        }
        default {
            set ixload_cardtype_array(69) $::ixCard(kCard1000Sfps4)
            set ixload_cardtype_array(70) $::ixCard(kCard1000Txs4)
            #set ixload_cardtype_array() $::ixCard(kCard1000Txs1)
            set ixload_cardtype_array(85) $::ixCard(kCard1000Stxs4)
            set ixload_cardtype_array(86) $::ixCard(kCard1000Stxs2)
            set ixload_cardtype_array(87) $::ixCard(kCard1000Stxs1)
            set ixload_cardtype_array(84) $::ixCard(kCard10GEXenpakP)
            set ixload_cardtype_array(91) $::ixCard(kCard10GEEthMultiMsa)
            set ixload_cardtype_array(89) $::ixCard(kCard10GEUniphyP)
            set ixload_cardtype_array(92) $::ixCard(kCard10GEUniphyXfp)
            set ixload_cardtype_array(79) $::ixCard(kCard1000Txs24)
            set ixload_cardtype_array(83) $::ixCard(kCard1000AlmT8)
            set ixload_cardtype_array(90) $::ixCard(kCard10GELsm)
            set ixload_cardtype_array(98) $::ixCard(kCard10GELsmXl6)
        }
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList handles $ixload_cardtype_array($cardType)
    return $returnList
}


proc ::ixia::ixLoadHandlesArrayCommand {args} {
    variable ixload_handles_array
    variable ixload_handles_count
    
    set mandatory_args {
        -mode        CHOICES get_handle get_value save remove
    }
    
    set opt_args {
        -handle                 ANY
        -type                   CHOICES network networkRange
                                CHOICES traffic agent action
                                CHOICES dns pool statistic
                                CHOICES test cookie cookielist
                                CHOICES header headerlist
                                CHOICES page map dut
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
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            
            set _cmd [format "%s" "::ixia::ixLoadGetChildrenHandles \
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
                    set retCode [::ixia::ixLoadHandlesArrayCommand \
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
                set retCode [::ixia::ixLoadGetChildrenHandles \
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


proc ::ixia::ixLoadGetChildrenHandles {args} {
    variable ixload_handles_array
    
    set mandatory_args {
        -mode        CHOICES new_list append_to_list
    }
    
    set optional_args {
        -handle                 ANY
        -type                   CHOICES network networkRange
                                CHOICES traffic agent action
                                CHOICES dns pool statistic
                                CHOICES test cookie cookielist
                                CHOICES header headerlist
                                CHOICES page map dut
        -target                 CHOICES client server
    }
    
    ::ixia::parse_dashed_args -args $args -optional_args $optional_args \
            -mandatory_args $mandatory_args
    
    switch -- $mode {
        append_to_list {
            set childrenList $handle
            foreach {arrayHandle} [array names ixload_handles_array] {
                set retCode [::ixia::ixLoadHandlesArrayCommand \
                        -mode     get_value                    \
                        -key      parent_handle                \
                        -handle   $arrayHandle                 ]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed in\
                            ::ixia::ixLoadGetChildrenHandles. \
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
                set retCode [::ixia::ixLoadHandlesArrayCommand     \
                        -mode     get_value                        \
                        -key      [list parent_handle type target] \
                        -handle   $arrayHandle                     ]
                
                if {[keylget retCode status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed in\
                            ::ixia::ixLoadGetChildrenHandles. \
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


proc ::ixia::ixLoadNetwork { args } {
    variable ixload_handles_array
    set ipType ""
    
    #debug "\n::ixia::ixLoadNetwork $args"
    set opt_args [eval [format "%s %s" ::ixia::ixLoadGetOptionalArgs $args]]
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
        congestion_notification_enable enableCongestionNotification
        time_stamp_enable              enableTimeStamp
        rx_bandwidth_limit_enable      enableRxBwLimit
        tx_bandwidth_limit_enable      enableTxBwLimit
        fin_timeout                    finTimeout
        keep_alive_interval            keepAliveInterval
        keep_alive_probes              keepAliveProbes
        keep_alive_time                keepAliveTime
        receive_buffer_size            receiveBuffer
        retransmit_retries             retransmitRetries
        rx_bandwidth_limit             rxBwLimit
        rx_bandwidth_limit_unit        rxBwLimitUnit
        syn_ack_retries                synAckRetries
        syn_retries                    synRetries
        transmit_buffer_size           transmitBuffer
        tx_bandwidth_limit             txBwLimit
        tx_bandwidth_limit_unit        txBwLimitUnit
    }
    
    if {[info exists emulated_router_gateway]} {
        if {[isIpAddressValid $emulated_router_gateway]} {
            set ipType 1
        } else {
            if {[::ipv6::isValidAddress $emulated_router_gateway]} {
                set ipType 2
                set net_args(emulated_router_gateway) emulatedRouterGatewayIPv6
                set net_args(emulated_router_subnet) emulatedRouterSubnetIPv6
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
            
            set returnList [::ixia::ixLoadGetChassisChain $procName $chassis]
            if {[keylget returnList status] == $::FAILURE} {
                return $returnList
            } else {
                set chassis_chain [keylget returnList handles]
            }
            
################################################################################
#              set returnList [::ixia::ixLoadGetCardType $procName $chassis $card \
#                      $port]
#              if {[keylget returnList status] == $::FAILURE} {
#                  return $returnList
#              } else {
#                  set card_type [keylget returnList handles]
#              }
#              keylset returnList handles ""
################################################################################

            
            # a new name for this IxLoad target Network
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            keylset returnList handles $network_name
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
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode            remove                \
                    -handle          $handle               ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            keylset returnList handles ""
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
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            
            keylset returnList status  $::SUCCESS
            keylset returnList handles $handle
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

proc ::ixia::ixLoadRange { args } {
    variable ixload_handles_array
    
#    debug "\n::ixia::ixLoadRange $args"
    set opt_args [eval [format "%s %s" ::ixia::ixLoadGetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    set mac_args [list mac_address_start mac_increment_step]
    
    foreach {mac_arg} $mac_args {
        if {[info exists $mac_arg]} {
            set $mac_arg [join [::ixia::convertToIxiaMac [set $mac_arg]] :]
        }
    }
    
    array set net_args {
        ipType             ipType
        ip_address_start   firstIp
        mac_address_start  firstMac
        gateway            gateway
        ip_count           ipCount
        ip_increment_step  ipIncrStep
        mac_increment_step macIncrStep
        mss                mss
        mss_enable         mssEnable
        network_mask       networkMask
        vlan_enable        vlanEnable
        vlan_id            vlanId
    }
    
    if {![info exists handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Argument -handle \
                is missing."
        return $returnList
    }
    set command ""
    foreach item [array names net_args] {
        if {[info exists $item]} {
            set _param $net_args($item)
            append command " -$_param \"[set $item]\" "
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
            set retCode [::ixia::ixLoadHandlesArrayCommand -mode get_handle \
                    -type networkRange ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }            
            set range_name [keylget retCode handle]
#            debug "new range handler = $range_name"
            
            set retCode [::ixia::ixLoadHandlesArrayCommand -mode get_value \
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
            
            # reserving this IxLoad Network Range name
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            keylset returnList handles $range_name
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
            set retCode [::ixia::ixLoadHandlesArrayCommand -mode get_value \
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
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode            remove                \
                    -handle          $handle               ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            keylset returnList handles ""
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
            set retCode [::ixia::ixLoadHandlesArrayCommand -mode get_value \
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
            
            keylset returnList status  $::SUCCESS
            keylset returnList handles $handle
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
            set retCode [::ixia::ixLoadHandlesArrayCommand -mode get_value \
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
            keylset returnList handles $handle
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

proc ::ixia::ixLoadPoolAddr { args } {
    variable ixload_handles_array
    
#    debug "\n::ixia::ixLoadPoolAddr $args"
    set opt_args [eval [format "%s %s" ::ixia::ixLoadGetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    set mac_args [list pool_mac_address_start]
    
    foreach {mac_arg} $mac_args {
        if {[info exists $mac_arg]} {
            set $mac_arg [join [::ixia::convertToIxiaMac [set $mac_arg]] :]
        }
    }
    
    array set addr_args {
        ipType                 ipType
        pool_ip_address_start  firstIp
        pool_ip_count          ipCount
        pool_network           networkMask
        pool_mac_address_start firstMac
        pool_vlan_enable       vlanEnable
        pool_vlan_id           vlanId
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
            set retCode [::ixia::ixLoadHandlesArrayCommand -mode get_handle \
                    -type pool ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set pool_name [keylget retCode handle]
#            debug "new pool handler = $pool_name"
            
            set retCode [::ixia::ixLoadHandlesArrayCommand -mode get_value \
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
            
            if {[info exists emulated_router_gateway]} {
                # emulated_router_subnet should be present also
                if {[isIpAddressValid $emulated_router_gateway]} {
                    set ers "-emulatedRouterSubnet"
                    set erg "-emulatedRouterGateway"
                } else {
                    if {[::ipv6::isValidAddress $emulated_router_gateway]} {
                        set ers "-emulatedRouterSubnetIPv6"
                        set erg "-emulatedRouterGatewayIPv6"
                    } else  {
                        set ers "-emulatedRouterSubnet"
                        set erg "-emulatedRouterGateway"
                    }
                }
                    
                set _cmd [format "%s" "$ixLoadHandler config \
                        $ers $emulated_router_subnet \
                        $erg $emulated_router_gateway"]
                debug "$_cmd"
                if {[catch {eval $_cmd} error]} {
                    catch {$ixLoadHandler \
                                emulatedRouterIpAddressPool.deleteItem $index}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Error setting \
                            emulated router gateway to handler $handle.\
                            \n$error."
                    return $returnList
                }
            }
            # reserving this IxLoad Network Range name
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            keylset returnList handles $pool_name
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
            set retCode [::ixia::ixLoadHandlesArrayCommand -mode get_value \
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
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode            remove                \
                    -handle          $handle               ]            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            keylset returnList handles ""
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
            set retCode [::ixia::ixLoadHandlesArrayCommand -mode get_value \
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

            if {[info exists emulated_router_gateway]} {
                # emulated_router_subnet should be present also
                if {[isIpAddressValid $emulated_router_gateway]} {
                    set ers "-emulatedRouterSubnet"
                    set erg "-emulatedRouterGateway"
                } else {
                    if {[::ipv6::isValidAddress $emulated_router_gateway]} {
                        set ers "-emulatedRouterSubnetIPv6"
                        set erg "-emulatedRouterGatewayIPv6"
                    } else  {
                        set ers "-emulatedRouterSubnet"
                        set erg "-emulatedRouterGateway"
                    }
                }
                
                set _cmd [format "%s" "$ixLoadHandler config \
                        $ers $emulated_router_subnet \
                        $erg $emulated_router_gateway"]
                debug "$_cmd"
                if {[catch {eval $_cmd} error]} {
                    catch {$ixLoadHandler \
                                emulatedRouterIpAddressPool.deleteItem $index}
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Error setting \
                            emulated router gateway to handler $handle.\
                            \n$error."
                    return $returnList
                }
            }
            
            keylset returnList status  $::SUCCESS
            keylset returnList handles $handle
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
            set retCode [::ixia::ixLoadHandlesArrayCommand -mode get_value \
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
            keylset returnList handles $handle
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

proc ::ixia::ixLoadDns { args } {
    variable ixload_handles_array
    
#    debug "ixLoadDns $args"
    ::ixia::parse_dashed_args -args $args -optional_args $args
    if {![info exists handle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Argument -handle \
                is missing."
        return $returnList
    }
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
            set retCode [::ixia::ixLoadHandlesArrayCommand -mode get_handle \
                    -type dns ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set dns_name [keylget retCode handle]
#            debug "new dns handler = $dns_name"
            
            set retCode [::ixia::ixLoadHandlesArrayCommand -mode get_value \
                    -handle $handle -key ixload_handle]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [keylget retCode value]
            
            if {[info exists dns_cache_timeout]} {
                set _cmd [format "%s" "$ixLoadHandler dnsParameters.config \
                        -enable 1 -cacheTimeout $dns_cache_timeout"]
                debug "$_cmd"
                if {[catch {eval $_cmd} error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Couldn't set \
                            DNS cache timeout.\n$error"
                    return $returnList
                }
            }
            
            if {[info exists dns_server] || [info exists dns_suffix]} {
                if {[info exists dns_server] && [info exists dns_suffix]} {
                    set _cmd [format "%s" "$ixLoadHandler \
                            dnsParameters.serverList.indexCount"]
                    debug "$_cmd"
                    if {[catch {eval $_cmd} index]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Error \
                                adding a server dns entry.\n$index."
                        return $returnList
                    }
#                    debug "NEW INDEX WOULD BE: $index"
                    # creating the IxLoad dns server entry
                    set _cmd [format "%s" "$ixLoadHandler \
                            dnsParameters.serverList.appendItem -data \
                            $dns_server"]
                    debug "$_cmd"
                    if {[catch {eval $_cmd} error]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Error \
                                adding a server dns entry.\n$error."
                        return $returnList
                    }
                    set _cmd [format "%s" "$ixLoadHandler \
                            dnsParameters.suffixList.appendItem -data \
                            $dns_suffix"]
                    debug "$_cmd"
                    if {[catch {eval $_cmd} error]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Error \
                                adding a suffix dns entry.\n$error."
                        return $returnList
                    }
                    set retCode [::ixia::ixLoadHandlesArrayCommand \
                            -mode            save                  \
                            -handle          $dns_name            \
                            -type            dns                  \
                            -ixload_handle   $ixLoadHandler        \
                            -ixload_index    $index                \
                            -parent_handle   $handle               ]
                    
                    if {[keylget retCode status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                [keylget retCode log]"
                        return $returnList
                    }                    
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument \
                            -dns_server or -dns_suffix missing."
                    return $returnList
                }
            }
            
            keylset returnList status  $::SUCCESS
            keylset returnList handles $dns_name
            return $returnList
        }
        remove {
            # check to see if handler is ok. It should be a dns handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid dns handle."
                return $returnList
            }
            set retCode [::ixia::ixLoadHandlesArrayCommand -mode get_value \
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
                    dnsParameters.serverList.deleteItem $index"]
            debug "$_cmd"
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error deleting \
                        dns entry.\n$error."
                return $returnList
            }
            set _cmd [format "%s" "$ixLoadHandler \
                    dnsParameters.suffixList.deleteItem $index"]
            debug "$_cmd"
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Error deleting \
                        dns entry.\n$error."
                return $returnList
            }
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode            remove                \
                    -handle          $handle               ]
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            keylset returnList handles ""
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
            set retCode [::ixia::ixLoadHandlesArrayCommand -mode get_value \
                    -handle $handle -key [list ixload_handle ixload_index]]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [lindex [keylget retCode value] 0]
            set index         [lindex [keylget retCode value] 1]
            
            if {[info exists dns_cache_timeout]} {
                set _cmd [format "%s" "$ixLoadHandler dnsParameters.config \
                        -enable 1 -cacheTimeout $dns_cache_timeout"]
                debug "$_cmd"
                if {[catch {eval $_cmd} error]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Couldn't set \
                            DNS cache timeout.\n$error"
                    return $returnList
                }
            }
            
            if {[info exists dns_server] || [info exists dns_suffix]} {
                if {[info exists dns_server] && [info exists dns_suffix]} {
                    # creating the IxLoad dns server entry
                    set _cmd [format "%s" "$ixLoadHandler \
                            dnsParameters.serverList($index).config -data \
                            $dns_server"]
                    debug "$_cmd"
                    if {[catch {eval $_cmd} error]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Error \
                                adding a server dns entry.\n$error."
                        return $returnList
                    }
                    set _cmd [format "%s" "$ixLoadHandler \
                            dnsParameters.suffixList($index).config -data \
                            $dns_suffix"]
                    debug "$_cmd"
                    if {[catch {eval $_cmd} error]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: Error \
                                adding a suffix dns entry.\n$error."
                        return $returnList
                    }
                } else {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Argument \
                            -dns_server or -dns_suffix missing."
                    return $returnList
                }
            }
            keylset returnList status  $::SUCCESS
            keylset returnList handles $handle
            return $returnList
        }
        enable -
        disable {
            set flag [expr {( $mode == "disable" ) ? 0 : 1}]
            # check to see if handler is ok. It should be a dns handle
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid dns handle."
                return $returnList
            }
            set retCode [::ixia::ixLoadHandlesArrayCommand -mode get_value \
                    -handle $handle -key ixload_handle]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            set ixLoadHandler [keylget retCode value]
            set _cmd [format "%s" "$ixLoadHandler dnsParameters.config \
                    -enable $flag"]
            debug "$_cmd"
            if {[catch {eval $_cmd} error]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Couldn't $mode \
                        DNS for this configuration.\n$error"
                return $returnList
            }
            keylset returnList status  $::SUCCESS
            keylset returnList handles $handle
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

proc ::ixia::ixLoadTraffic { args } {
    variable ixload_handles_array
    
#    debug "ixLoadTraffic: $args"
    ::ixia::parse_dashed_args -args $args -optional_args $args
    
    array set target_traffic {
        client ixClientTraffic
        server ixServerTraffic
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
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            keylset returnList handles $traffic_name
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
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode            remove                \
                    -handle          $handle               ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            keylset returnList status  $::SUCCESS
            keylset returnList handles ""
            return $returnList
        }
        modify {
            # do nothing. There is nothing to modify
        }
        enable -
        disable {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Arguments -enable \
                    or -disable can't be used on a traffic object."
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


proc ::ixia::ixLoadTrafficNetworkMapping {args} {
    variable ixload_handles_array
    
#    debug "\nixLoadTrafficNetworkMapping: $args"
    set opt_args [eval [format "%s %s" ::ixia::ixLoadGetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    array set valuesHltToIxLoad {
        external           $::ixDut(kTypeExternalServer)
        slb                $::ixDut(kTypeSLB)
        firewall           $::ixDut(kTypeFirewall)
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
    }
    
    array set client_mapping_args {
        enable_mapping               enable
        client_iterations            iterations
        ixLoadNetworkHandler         network
        ixLoadTrafficHandler         traffic
        objective_type               objectiveType
        objective_value              objectiveValue
        client_offline_time          offlineTime
        port_map_policy              portMapPolicy
        ramp_down_time               rampDownTime
        ramp_up_type                 rampUpType
        ramp_up_value                rampUpValue
        client_standby_time          standbyTime
        client_sustain_time          sustainTime
        client_total_time            totalTime
    }
    
    array set server_mapping_args {
        enable_mapping               enable
        ixLoadNetworkHandler         network
        ixLoadTrafficHandler         traffic
        match_client_totaltime       matchClientTotalTime
        server_iterations            iterations
        server_offline_time          offlineTime
        server_standby_time          standbyTime
        server_sustain_time          sustainTime
        server_total_time            totalTime
    }
    
    array set dut_args {
        dut_name                      name
        direct_server_return_enable   enableDirectServerReturn
        ip_address                    ipAddress
        ixLoadNetworkHandler          serverNetwork
        type                          type
    }
    
    switch -- $mode {
        add {
            # check to see if valid handles exist
            set checkValidExistence "0x[info exists         \
                    client_${protocol}_handle][info exists  \
                    client_traffic_handle][info exists      \
                    server_${protocol}_handle][info exists  \
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
                    client_${protocol}_handle  \
                    client_traffic_handle      \
                    server_${protocol}_handle  \
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
                
                set retCode [::ixia::ixLoadHandlesArrayCommand \
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
                set network_handle [set client_${protocol}_handle]
                set traffic_handle $client_traffic_handle
            } else  {
                set network_handle [set server_${protocol}_handle]
                set traffic_handle $server_traffic_handle
            }
            
            # get next map handle
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            set retCode [::ixia::ixLoadTrafficNetworkMappingExistence \
                    $map_name $traffic_handle $network_handle]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            
            if {[info exists match_client_totaltime]} {
                if {$match_client_totaltime == 1} {
                    array unset server_mapping_args
                    array set server_mapping_args {
                        enable_mapping               enable
                        ixLoadNetworkHandler         network
                        ixLoadTrafficHandler         traffic
                        match_client_totaltime       matchClientTotalTime
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
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            if {$handleType != "map"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid map handle."
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
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            
            # check if the provided network_handle has another traffic-network
            # mapping already made
            set retCode [::ixia::ixLoadTrafficNetworkMappingExistence \
                    $handle $traffic_handle $network_handle]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            # check to see if valid handles exist
            set checkValidExistence "0x[info exists             \
                    ${_target}_${protocol}_handle][info exists  \
                    ${_target}_traffic_handle]"
            
            switch -- $checkValidExistence {
                0x11 {
                    set network_handle [set ${_target}_${protocol}_handle]
                    set traffic_handle [set ${_target}_traffic_handle    ]
                }
                0x01 {
                    set traffic_handle [set ${_target}_traffic_handle    ]
                }
                0x10 {
                    set network_handle [set ${_target}_${protocol}_handle]
                }
                default {
                }
            }
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            
            if {[info exists match_client_totaltime]} {
                if {$match_client_totaltime == 1} {
                    array unset server_mapping_args
                    array set server_mapping_args {
                        enable_mapping               enable
                        ixLoadNetworkHandler         network
                        ixLoadTrafficHandler         traffic
                        match_client_totaltime       matchClientTotalTime
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
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $handle                      \
                    -key      [list type ixload_handle ]   ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            set handleType    [lindex [keylget retCode value] 0]
            set ixLoadHandler [lindex [keylget retCode value] 1]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "map"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid map handle."
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


proc ::ixia::ixLoadTrafficNetworkMappingExistence {\
    map_handle traffic_hadle network_handle } {
    
    variable ixload_handles_array
    
    foreach {aName} [array names ixload_handles_array] {
        if {$aName == $map_handle} {
            continue;
        }
        set retCode [::ixia::ixLoadHandlesArrayCommand \
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


proc ::ixia::ixLoadDut {args} {
    variable ixload_handles_array
    
#    debug "\nixLoadDut: $args"
    set opt_args [eval [format "%s %s" ::ixia::ixLoadGetOptionalArgs $args]]
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    array set valuesHltToIxLoad {
        external           $::ixDut(kTypeExternalServer)
        slb                $::ixDut(kTypeSLB)
        firewall           $::ixDut(kTypeFirewall)
    }
    
    array set dut_args {
        dut_name                      name
        direct_server_return_enable   enableDirectServerReturn
        ip_address                    ipAddress
        ixLoadNetworkHandler          serverNetwork
        type                          type
    }
    
    switch -- $mode {
        add {
            # check if server_telnet/http/ftp_handle was provided
            if {(![info exists server_${protocol}_handle]) && \
                    (![info exists ip_address])} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Arguments\
                        -server_${protocol}_handle or -ip_address\
                        must be provided for -mode $mode."
                return $returnList
            }
            if {[info exists server_${protocol}_handle]} {
                set network_handle [set server_${protocol}_handle]
            }
            
            # get next map handle
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
                set retCode [::ixia::ixLoadHandlesArrayCommand \
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
                set retCode [::ixia::ixLoadHandlesArrayCommand \
                        -mode            save                  \
                        -handle          $dut_name             \
                        -type            dut                   \
                        -ixload_handle   $ixLoadDutHandler     \
                        -network_handle  $network_handle       \
                        -parent_handle   $parent_handle        ]
            } else  {
                set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            keylset returnList handles $dut_name
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
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
                    
            if {[info exists server_${protocol}_handle]} {
                set network_handle [set server_${protocol}_handle ]
            } elseif {$network_handle == "N/A"} {
                unset network_handle
            }
            
            if {[info exists network_handle]} {
                set retCode [::ixia::ixLoadHandlesArrayCommand \
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
                set retCode [::ixia::ixLoadHandlesArrayCommand \
                        -mode            save                  \
                        -handle          $handle               \
                        -type            dut                   \
                        -ixload_handle   $ixLoadDutHandler     \
                        -network_handle  $network_handle       \
                        -parent_handle   $parent_handle        ]
            } else  {
                set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode     get_value                    \
                    -handle   $handle                      \
                    -key      [list type ixload_handle ]   ]
            
            if {[keylget retCode status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget retCode log]"
                return $returnList
            }
            
            set handleType    [lindex [keylget retCode value] 0]
            set ixLoadHandler [lindex [keylget retCode value] 1]
            
            # check to see if handle is a valid agent handle
            if {$handleType != "dut"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid agent handle."
                return $returnList
            }
            
            set _cmd [format "%s" "$ixLoadHandler config  -enable $flag"]
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


proc ::ixia::ixLoadGetProperty {handleName protocol} {
    set count [regsub {^([a-zA-Z]+)([0-9]+)$} $handleName {\1} handleName]
    if {$count} {
        switch -- $handleName {
            networkRange  { return network }
            pool          { return router_addr }
            networkClient -
            networkServer {
                return $protocol
            }
            trafficClient -
            trafficServer {
                return traffic
            }
            dns -
            agent -
            action -
            cookielist -
            cookie -
            headerlist -
            header -
            page -
            map -
            dut {
                return $handleName
            }
        }
    }
    return "unknown"
}


proc ::ixia::ixLoadStatistics {args} {
    # Arguments
    set mandatory_args {
        -mode        CHOICES add clear get
    }
    
    set opt_args {
        -handle              ANY
        -aggregation_type    CHOICES sum max min average rate maxrate
                             CHOICES minrate averagerate
                             DEFAULT sum
        -stat_name           ALPHANUM
        -stat_type           CHOICES client server
                             DEFAULT client
        -filter_type         CHOICES port card chassis traffic map
        -filter_value        ANY
        -protocol            CHOICES telnet http ftp
        -procName            ANY
    }
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args \
            -mandatory_args $mandatory_args
    
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
    
    array set aggregationTypesArray [list \
            sum            kSum           \
            max            kMax           \
            min            kMin           \
            average        kAverage       \
            rate           kRate          \
            maxrate        kMaxRate       \
            minrate        kMinRate       \
            averagerate    kAverageRate   \
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
            telnet    Telnet        ]
    
    # Create test controller, if test controller was not created previously
    set tcOptions [list procName results_dir_enable results_dir]
    set tcArgsList ""
    foreach {elem} $tcOptions {
        if {[info exists $elem]} {
            append tcArgsList " -$elem \"[set $elem]\""
        }
    }
    set retCode [eval [format "%s %s" ::ixia::ixLoadTestController \
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
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
                                set retCode [::ixia::ixLoadHandlesArrayCommand \
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
                                set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            
            set retCode [::ixia::ixLoadHandlesArrayCommand  \
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
        clear {
            set _cmd [format "%s" "::statCollectorUtils::ClearStats"]
            debug "$_cmd"
            if {[catch {eval $_cmd} retError]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to\
                        ::statCollectorUtils::ClearStats. \
                        $retError"
                return $returnList
            }
            set ixload_returned_stats ""
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
                set retCode [::ixia::ixLoadHandlesArrayCommand \
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
                if {$type != "statistic"} {
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

proc ::ixia::ixLoadStatCollectorCommand {args} {
    variable ixload_returned_stats
    variable ixload_registered_stats
    
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
        
        keylset ixload_returned_stats                                \
                $regStatHandle.$regStatType.$regStatName.$timestamp  \
                $retStatValue
    }
}


proc ::ixia::ixLoadGetOptionalArgs {args} {
    set retArgList ""
    foreach {elem} $args {
        if {[string first "-" $elem] == 0} {
            append retArgList " $elem ANY \n"
        }
    }
    return $retArgList
}

proc ::ixia::ixLoadControl {args} {
    variable ixload_handles_array
    variable ixload_test_controller
    variable ixload_log_engine
    variable ixloadVersion

    set opt_args [eval [format "%s %s" ::ixia::ixLoadGetOptionalArgs $args]]
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
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode   get_handle \
                    -type   test       ]
            
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            set test_name [keylget retCode handle]
            
            set _cmd [format "%s" "::IxLoad new ixTest -name $test_name"]
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
                set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            set retCode [eval [format "%s %s" ::ixia::ixLoadTestController \
                    $tcArgsList]]
            
            if {[keylget retCode status] == $::FAILURE} {
                catch {::IxLoad delete $ixLoadTestHandler}
                return $retCode
            }
            
            #saving test
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            set retCode [::ixia::ixLoadHandlesArrayCommand \
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
                    set retCode [::ixia::ixLoadHandlesArrayCommand \
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
            set retCode [eval [format "%s %s" ::ixia::ixLoadTestController \
                    $tcArgsList]]
            
            if {[keylget retCode status] == $::FAILURE} {
                catch {::IxLoad delete $ixLoadTestHandler}
                return $retCode
            }
            
            keylset returnList status $::SUCCESS
            return $returnList
        }
        start {
            if {![info exists ixload_handles_array($handle)]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Argument\
                        -handle $handle is not a valid control handle."
                return $returnList
            }
            set retCode [::ixia::ixLoadHandlesArrayCommand \
                    -mode get_value                        \
                    -handle $handle                        \
                    -key ixload_handle                     ]
            if {[keylget retCode status] == $::FAILURE} {
                return $retCode
            }
            set ixLoadHandler  [keylget retCode value]
            set testController [keylget ixload_test_controller command]
            set commands [list]
            
            set _cmd [format "%s" "::statCollectorUtils::StartCollector \
                    -command ::ixia::ixLoadStatCollectorCommand"]
            lappend commands $_cmd
            set _cmd [format "%s" "$testController run $ixLoadHandler"]
            lappend commands $_cmd
            set _cmd [format "%s" "vwait ::ixTestControllerMonitor"]
            lappend commands $_cmd
            set _cmd [format "%s" "::statCollectorUtils::StopCollector"]
            lappend commands $_cmd
            set _cmd [format "%s" "$testController releaseConfigWaitFinish"]
            lappend commands $_cmd
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
                        catch {
                            set nameList [list "${protocol}_Client.csv" \
                                    "${protocol}_Server.csv"            \
                                    "Test_Client.csv"                   \
                                    "Test_Server.csv"                   \
                                    "TestInfo.ini"                      \
                                    "test.xmd"                          ]
                            #mapping
                            foreach map_item [array names ixload_handles_array map*] {
                                set retCode [::ixia::ixLoadHandlesArrayCommand \
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
                                set retCode [::ixia::ixLoadHandlesArrayCommand \
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
                                set fileName "${protocol}_${target}_-_Default_CSV_Logs_"
                                append fileName "${agent_item}_${traffic_handle}@"
                                set network_handle $mapping($traffic_handle)
                                append fileName "${network_handle}.csv"
                                lappend nameList $fileName
                            }
                            foreach fileName $nameList {
                                set _fileId${_countFileIds} ""
                                set theFileId _fileId${_countFileIds}
                                set _newCmd [::ixia::ixLoadRetrieveFileCommand \
                                                $results_dir $fileName]
                                set _toAdd [format "%s %s %s" "set fileId" {[open [file \
                                                join} "$results_dir $fileName\] w\]"]
                                lappend commands $_toAdd
                                lappend commands $_newCmd
                                lappend commands {close $fileId}
                                incr _countFileIds
                            }
                        } _someErr
                        # back
                        cd $_current_dir
                    }
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
            keylset returnList status $::SUCCESS
            return $returnList
        }
    }
}

proc ::ixia::ixLoadRetrieveFileCommand {_results_dir _fileName} {
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

proc ::ixia::ixLoadTestController {args} {
    variable ixload_test_controller
    
    set opt_args [eval [format "%s %s" ::ixia::ixLoadGetOptionalArgs $args]]
    
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
