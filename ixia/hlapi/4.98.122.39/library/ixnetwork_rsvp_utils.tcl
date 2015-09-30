
proc ::ixia::getNeighborsLables {handle_list} {
    set neighbors {}
    set labels {}
    set lsps {}
    set srcIP {}
    set dstIP {}
    set tunnelID {}
    foreach handle_item $handle_list {
        regexp {::ixNet::OBJ-/vport:\d+/protocols/rsvp/neighborPair:\d+} \
            $handle_item handle
        if {![info exists handle]} {
            keylset returnList log "FAIL on getNeighborsLables: \
            handle $handle_item invalid"
            keylset returnList status ::FAILURE
            return $returnList
        }
        debug "ixNet exec refreshAssignedLabelInfo $handle"
        ixNet exec refreshAssignedLabelInfo $handle
        set count 0
        while {![ixNet getAttr $handle -isAssignedInfoRefreshed]} {
            after 500
            if {$count > 100} {
                keylset returnList status $::FAILURE
                keylset returnList log "FAILURE on getNeighborsLables: timeout \
                    occured retriving stats!"
                return $returnList
            }
            incr count
        }
        # because of "as designed" 119948 we wait more....
        after 1000
        debug "ixNet getList $handle assignedLabel"
        set assignedLabelInfo [ixNet getList $handle assignedLabel]
        foreach assignedLabel $assignedLabelInfo {
            debug "ixNet getAttr $assignedLabel -sourceIp"
            debug "ixNet getAttr $assignedLabel -destinationIp"
            debug "ixNet getAttr $assignedLabel -tunnelId"
            if {[ixNet getAttr $assignedLabel -type] == "P2MP"} {
                lappend neighbors "Type: P2MP \
                    Src: [ixNet getAttr $assignedLabel -sourceIp] \
                    Dst: [ixNet getAttr $assignedLabel -destinationIp] \
                    T: [ixNet getAttr $assignedLabel -tunnelId] \
                    Leaf: [ixNet getAttr $assignedLabel -leafIp] \
                    Label: [ixNet getAttr $assignedLabel -label] \
                    ReservationStateForGracefulRestart: [ixNet getAttr $assignedLabel -reservationState]"
            } else {
                lappend neighbors "Src: [ixNet getAttr $assignedLabel -sourceIp] \
                    Dst: [ixNet getAttr $assignedLabel -destinationIp] \
                    T: [ixNet getAttr $assignedLabel -tunnelId]"
            }
            lappend lsps [ixNet getAttr $assignedLabel -lspId]
            lappend labels [list [ixNet getAttr $assignedLabel -lspId] [ixNet getAttr $assignedLabel -label]]
            lappend srcIP [ixNet getAttr $assignedLabel -sourceIp]
            lappend dstIP [ixNet getAttr $assignedLabel -destinationIp]
            lappend tunnelID [ixNet getAttr $assignedLabel -tunnelId]
            if {[ixNet getAttr $assignedLabel -type] == "P2MP"} {
                lappend leafIp [ixNet getAttr $assignedLabel -leafIp]
                lappend reservationStates [ixNet getAttr $assignedLabel -reservationState]
            }
        }
        
        debug "ixNet exec refreshReceivedLabelInfo $handle"
        ixNet exec refreshReceivedLabelInfo $handle
        set count 0
        debug "ixNet getAttr $handle -isLearnedInfoRefreshed"
        while {![ixNet getAttr $handle -isLearnedInfoRefreshed]} {
            after 500
            if {$count > 100} {
                keylset returnList status $::FAILURE
                keylset returnList log "FAILURE on getNeighborsLables: timeout \
                    occured retriving stats!"
                return $returnList
            }
            incr count
        }
        
        # because of "as designed" 119948 we wait more....
        after 1000
        debug "ixNet getList $handle receivedLabel"
        set receivedLabelInfo [ixNet getList $handle receivedLabel]
        foreach receivedLabel $receivedLabelInfo {
            if {[ixNet getAttr $receivedLabel -type] == "P2MP"} {
                lappend neighbors "Type: P2MP \
                    Src: [ixNet getAttr $receivedLabel -sourceIp] \
                    Dst: [ixNet getAttr $receivedLabel -destinationIp] \
                    T: [ixNet getAttr $receivedLabel -tunnelId] \
                    Leaf: [ixNet getAttr $receivedLabel -leafIp] \
                    Label: [ixNet getAttr $receivedLabel -label] \
                    ReservationStateForGracefulRestart: [ixNet getAttr $receivedLabel -reservationState]"
            } else {
                lappend neighbors "Src: [ixNet getAttr $receivedLabel -sourceIp] \
                    Dst: [ixNet getAttr $receivedLabel -destinationIp] \
                    T: [ixNet getAttr $receivedLabel -tunnelId]"
            
            }
            lappend lsps [ixNet getAttr $receivedLabel -lspId]
            lappend labels [list [ixNet getAttr $receivedLabel -lspId] [ixNet getAttr $receivedLabel -label]]
            lappend srcIP [ixNet getAttr $receivedLabel -sourceIp]
            lappend dstIP [ixNet getAttr $receivedLabel -destinationIp]
            lappend tunnelID [ixNet getAttr $receivedLabel -tunnelId]
            if {[ixNet getAttr $receivedLabel -type] == "P2MP"} {
                lappend leafIp [ixNet getAttr $receivedLabel -leafIp]
                lappend reservationStates [ixNet getAttr $receivedLabel -reservationState]
            }
        }
    }
    set labels    [lsort -unique $labels]
    set neighbors [lsort -unique $neighbors]
    set lsps      [lsort -unique $lsps]
    set srcIP     [lsort -unique $srcIP]
    set dstIP     [lsort -unique $dstIP]
    set tunnelID  [lsort -unique $tunnelID]
    
    if {[info exists leafIP]} {
        set leafIP    [lsort -unique $leafIp]
    }
    if {[info exists reservationStates]} {
        set reservationState    [lsort -unique $reservationStates]
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList neighbors $neighbors
    keylset returnList lsps $lsps
    keylset returnList labels $labels
    return $returnList
}

proc ::ixia::ixnetwork_rsvp_add_head2leaf_info {sendRange head2leaf_count args} {
    debug "sendRange head2leaf_count args $sendRange $head2leaf_count $args"
    keylset returnList status $::SUCCESS

    set args [lindex $args 0]
    # Arguments
    set opt_args {
        -h2l_info_dut_hop_type                  CHOICES strict loose
                                                DEFAULT loose
        -h2l_info_dut_prefix_length             RANGE   1-32
                                                DEFAULT 32
        -h2l_info_head_ip_start                 IP
        -h2l_info_enable_append_tunnel_leaf     CHOICES 0 1
                                                DEFAULT 1
        -h2l_info_enable_prepend_dut            CHOICES 0 1
                                                DEFAULT 1
        -h2l_info_enable_send_as_ero            CHOICES 0 1
                                                DEFAULT 1
        -h2l_info_enable_send_as_sero           CHOICES 0 1
                                                DEFAULT 0
        -h2l_info_tunnel_leaf_count             RANGE   1-4294967295
                                                DEFAULT 1
        -h2l_info_tunnel_leaf_hop_type          CHOICES strict loose
                                                DEFAULT loose
        -h2l_info_tunnel_leaf_ip_start          IP
                                                DEFAULT 0.0.0.0
        -h2l_info_tunnel_leaf_prefix_length     RANGE   1-32
                                                DEFAULT 32
        -h2l_info_ero_sero_list                 ANY
    }
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
        
    set tun_head2leaf_info_params {
        dutHopType                      h2l_info_dut_hop_type
        dutPrefixLength                 h2l_info_dut_prefix_length
        headIpStart                     h2l_info_head_ip_start
        isAppendTunnelLeaf              h2l_info_enable_append_tunnel_leaf
        isPrependDut                    h2l_info_enable_prepend_dut
        isSendingAsEro                  h2l_info_enable_send_as_ero
        isSendingAsSero                 h2l_info_enable_send_as_sero
        tunnelLeafCount                 h2l_info_tunnel_leaf_count
        tunnelLeafHopType               h2l_info_tunnel_leaf_hop_type
        tunnelLeafIpStart               h2l_info_tunnel_leaf_ip_start
        tunnelLeafPrefixLength          h2l_info_tunnel_leaf_prefix_length
    }
    
    for {set H2LIndex 0} {$H2LIndex < $head2leaf_count} {incr H2LIndex} {
        set h2lIxNParams ""
        foreach {ixn_param hlt_param} $tun_head2leaf_info_params {
            if {![info exists $hlt_param]} {
                continue
            }
            if {[llength [set $hlt_param]] == 1} {
                append h2lIxNParams "-$ixn_param [set $hlt_param] "
            } else {
                append h2lIxNParams "-$ixn_param [lindex [set $hlt_param] $H2LIndex] "
            }
        }

        if {[info exists h2l_info_ero_sero_list]} {
            if {[llength $h2l_info_ero_sero_list] == 1} {
                set head2leaf_ero_sero $h2l_info_ero_sero_list
            } else {
                set head2leaf_ero_sero [lindex $h2l_info_ero_sero_list $H2LIndex]
            }

            # Example of transformation desired:
            #   initial ip,1.1.1.1/24,l:as,45,s
            #   after   IP:1.1.1.1/24:L;AS:45:S
            regsub -all {:} $head2leaf_ero_sero {;} head2leaf_ero_sero
            regsub -all {,} $head2leaf_ero_sero {:} head2leaf_ero_sero
            set head2leaf_ero_sero [string toupper $head2leaf_ero_sero]
            append h2lIxNParams "-subObjectList \{$head2leaf_ero_sero\;\} "
        }

        if {$h2lIxNParams != ""} {
            set returnList [::ixia::ixNetworkNodeAdd $sendRange "tunnelHeadToLeaf"\
                    "-enabled 1 $h2lIxNParams" 1]
            if {[keylget returnList status] != $::SUCCESS} {
                return $returnList
            }
        }
    }
    return $returnList
}


proc ::ixia::ixnetwork_rsvp_add_head_traffic_item {sendRange item args} {
    keylset returnList status $::SUCCESS

    set args [lindex $args 0]
    
    # Arguments
    set opt_args {
        -head_traffic_ip_type                   CHOICES ipv4 ipv6
                                                DEFAULT ipv4
        -head_traffic_ip_count                  RANGE   1-4294967295
                                                DEFAULT 1
        -head_traffic_start_ip                  IP
        -head_traffic_inter_tunnel_ip_step      IP
        -explicit_traffic_item                  CHOICES 0 1
                                                DEFAULT 0
    }
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    # Tunnel Head Traffic Items
    set tun_head_traffic_params {
        endPointType                            head_traffic_ip_type                value
        ipCount                                 head_traffic_ip_count               value
        ipStart                                 head_traffic_start_ip               value
        head_traffic_inter_tunnel_ip_step       head_traffic_inter_tunnel_ip_step   value
        insertIpv6ExplicitNull                  explicit_traffic_item               bool
    }
    
    array set boolTranslate {
        1 True
        0 False
    }
    
    if {![info exists head_traffic_inter_tunnel_ip_step]} {
        if {$head_traffic_ip_type == "ipv4"} {
            set head_traffic_inter_tunnel_ip_step 0.0.1.0
        } else {
            set head_traffic_inter_tunnel_ip_step ::1:0
        }
    }
    
    if {![info exists head_traffic_start_ip]} {
        if {$head_traffic_ip_type == "ipv4"} {
            set head_traffic_start_ip 0.0.0.0
        } else {
            set head_traffic_start_ip 0::0
        }
    }
    
    switch -- $head_traffic_ip_type {
        "ipv4" {
            for {set i 0} {$i < $item} {incr i} {
                set head_traffic_start_ip [::ixia::incr_ipv4_addr \
                        $head_traffic_start_ip $head_traffic_inter_tunnel_ip_step]
            }
        }
        "ipv6" {
            for {set i 0} {$i < $item} {incr i} {
                set head_traffic_start_ip [::ixia::incr_ipv6_addr \
                        $head_traffic_start_ip $head_traffic_inter_tunnel_ip_step]
            }
        }
    }
    
    set ixnHeadTrafficParams ""
    foreach {ixn_param hlt_param datatype} $tun_head_traffic_params {
        if {![info exists $hlt_param]} {
            continue
        }
        if {$hlt_param == "head_traffic_inter_tunnel_ip_step"} {
            continue
        }
        if {$datatype == "bool"} {
            append ixnHeadTrafficParams "-$ixn_param $boolTranslate([set $hlt_param]) "
        } else {
            append ixnHeadTrafficParams "-$ixn_param [set $hlt_param] "
        }
    }
    
    if {$ixnHeadTrafficParams != ""} {
        set returnList [::ixia::ixNetworkNodeSetAttr $sendRange/tunnelHeadTrafficEndPoint:1 \
                $ixnHeadTrafficParams -commit]
        if {[keylget returnList status] != $::SUCCESS} {
            return $returnList
        }
    }
    
    return $returnList
}

proc ::ixia::ixnetwork_rsvp_add_tail_traffic_item {destRange item args} {
    keylset returnList status $::SUCCESS

    set args [lindex $args 0]
    
    # Arguments
    set opt_args {
        -tail_traffic_ip_type                   CHOICES ipv4 ipv6
                                                DEFAULT ipv4
        -tail_traffic_ip_count                  RANGE   1-4294967295
                                                DEFAULT 1
        -tail_traffic_start_ip                  IP
        -tail_traffic_inter_tunnel_ip_step      IP
    }
    
    ::ixia::parse_dashed_args -args $args -optional_args $opt_args
    
    # Tunnel tail Traffic Items
    set tun_tail_traffic_params {
        endPointType                            tail_traffic_ip_type
        ipCount                                 tail_traffic_ip_count
        ipStart                                 tail_traffic_start_ip
        tail_traffic_inter_tunnel_ip_step     tail_traffic_inter_tunnel_ip_step
    }
    
    if {![info exists tail_traffic_inter_tunnel_ip_step]} {
        if {$tail_traffic_ip_type == "ipv4"} {
            set tail_traffic_inter_tunnel_ip_step 0.0.1.0
        } else {
            set tail_traffic_inter_tunnel_ip_step ::1:0
        }
    }
    
    if {![info exists tail_traffic_start_ip]} {
        if {$tail_traffic_ip_type == "ipv4"} {
            set tail_traffic_start_ip 0.0.0.0
        } else {
            set tail_traffic_start_ip 0::0
        }
    }
    
    switch -- $tail_traffic_ip_type {
        "ipv4" {
            for {set i 0} {$i < $item} {incr i} {
                set tail_traffic_start_ip [::ixia::incr_ipv4_addr \
                        $tail_traffic_start_ip $tail_traffic_inter_tunnel_ip_step]
            }
        }
        "ipv6" {
            for {set i 0} {$i < $item} {incr i} {
                set tail_traffic_start_ip [::ixia::incr_ipv6_addr \
                        $tail_traffic_start_ip $tail_traffic_inter_tunnel_ip_step]
            }
        }
    }
    
    set ixntailTrafficParams ""
    foreach {ixn_param hlt_param} $tun_tail_traffic_params {
        if {![info exists $hlt_param]} {
            continue
        }
        if {$hlt_param == "tail_traffic_inter_tunnel_ip_step"} {
            continue
        }
        append ixntailTrafficParams "-$ixn_param [set $hlt_param] "
    }
    
    if {$ixntailTrafficParams != ""} {
        set returnList [::ixia::ixNetworkNodeSetAttr $destRange/tunnelTailTrafficEndPoint:1 \
                $ixntailTrafficParams -commit]
        if {[keylget returnList status] != $::SUCCESS} {
            return $returnList
        }
    }
    
    return $returnList
}

proc ::ixia::ixnetwork_rsvp_get_valid_traffic_endpoint {endpointHandle} {
    # RSVP traffic endpoints contain the full objectRef if there are multiple objects
    # configured, but only [ixNet getRoot]vport:1/protocols if there's only one object.
    # HLT RSVP handles are in the forms:
    #   ::ixNet::OBJ-/vport:1/protocols/rsvp/neighborPairs:1/destinationRange:1/ingress for ingress
    #   ::ixNet::OBJ-/vport:1/protocols/rsvp/neighborPairs:1/destinationRange:1 for egress
    # We must bring them to a valid form
    
    keylset returnList status $::SUCCESS
    
    if {[regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/rsvp/neighborPair:\d+/destinationRange:\d+/ingress$} $endpointHandle]} {
        set role "ingress"
        set endpointHandle [::ixia::ixNetworkGetParentObjref $endpointHandle]
        if {$endpointHandle == [ixNet getNull]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal procedure error. Failed to ::ixia::ixNetworkGetParentObjref $endpointHandle destinationRange."
            return $returnList
        }
    } elseif {[regexp -all {^::ixNet::OBJ-/vport:\d+/protocols/rsvp/neighborPair:\d+/destinationRange:\d+$} $endpointHandle]} {
        set role "egress"
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "Invalid RSVP endpoint handle $endpointHandle."
        return $returnList
    }
    
    if {$role == "ingress"} {
        # Check if there are multiple senderRanges configured
        if {[llength [ixNet getList $endpointHandle/ingress senderRange]] > 1} {
            keylset returnList status $::SUCCESS
            keylset returnList endpointRef [regsub neighborPair $endpointHandle neighborPairs]
            return $returnList
        }
    }
    
    set tmpEH [::ixia::ixNetworkGetParentObjref $endpointHandle]
    
    # Check if there is more than one destinationRange configured 
    if {[llength [ixNet getList $tmpEH destinationRange]] > 1} {
        keylset returnList status $::SUCCESS
        keylset returnList endpointRef [regsub neighborPair $endpointHandle neighborPairs]
        return $returnList
    } else {
        set endpointHandle $tmpEH
        set tmpEH [::ixia::ixNetworkGetParentObjref $endpointHandle]
    }
    
    # Check if there are multiple neighborPairs configured
    if {[llength [ixNet getList $tmpEH neighborPair]] > 1} {
        keylset returnList status $::SUCCESS
        keylset returnList endpointRef [regsub neighborPair $endpointHandle neighborPairs]
        return $returnList
    } else {
        set endpointHandle $tmpEH
    }
    
    if {$role == "egress"} {
        keylset returnList status $::SUCCESS
        keylset returnList endpointRef $endpointHandle
        return $returnList
    } else {
        keylset returnList status $::SUCCESS
        keylset returnList endpointRef [::ixia::ixNetworkGetParentObjref $endpointHandle]
        return $returnList
    }
}
