proc ::ixia::l2StackCreate {stack_object encap} {
    array set encap_map {
        ethernet           ethernet
    	ethernetFcoe       ethernet
    	fc                 ethernet
    	hundredGigLan      ethernet
    	pos                atm
    	tenGigLan          ethernet
    	tenGigLanFcoe      ethernet
    	tenGigWan          ethernet
    	tenGigWanFcoe      ethernet
        eth                ethernet
        atm                atm
    }
    
    set endpoint_type_list {
    	dhcpServerEndpoint
    	emulatedRouter
    	emulatedRouterEndpoint
    	ip
    	ipEndpoint
    	pppox
    	pppoxEndpoint
    }
    
    # Verify stack ...
    set next_object [ixNet getL $stack_object $encap_map($encap)]
    if {[llength $next_object] == 0} {
        set temporary_object [ixNet add $stack_object $encap_map($encap)]
        if {[ixNet commit] != "::ixNet::OK"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to commit after attempt to create $encap_map($encap) object."
            return $returnList
        } else {
            set next_object [ixNet remapIds $temporary_object]
        }
    } else {
        set next_object [lindex $next_object 0]
        set create_flag 0
        foreach endpoint_type $endpoint_type_list {
            if {[ixNet getL $next_object $endpoint_type] != ""} {
                set create_flag 1
                break;
            }
        }
        if {$create_flag} {
            set temporary_object [ixNet add $stack_object $encap_map($encap)]
            if {[ixNet commit] != "::ixNet::OK"} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Unable to commit after attempt to create $encap_map($encap) object."
                return $returnList
            } else {
                set next_object [ixNet remapIds $temporary_object]
            }
        }
    }
    keylset returnList status $::SUCCESS
    keylset returnList objref $next_object
    return $returnList
}
