#
#
#

set T ::ixia::hag::ixn::types

foreach x { atm ethernet } {

    set PS "${T}::/vport/protocolStack/$x"
    set PRE dhcpServer
    set RANGE "${PS}/${PRE}Endpoint/range/${PRE}Range"

    if {0} {
        #
        # when a xxx sub object is created override default so that
        # -select is set to be true
        #
        snit::method ${RANGE}/xxx _alterations_to_option_defaults {} {
            return {
                -select true
            }
        }
    }

    #
    # Ixnetwork only allows start/stop at the XxxEndpoint level it seems
    # so override start/stop to start/stop of
    # our grandparent when someone asks us to start/stop
    #
    snit::method ${RANGE} start {} { $Shell start [$self _ancestor 2] }
    snit::method ${RANGE} stop {} { $Shell stop [$self _ancestor 2] }

    #
    # Override to allow a classis hlt port_handle", which is just a chassis
    # "chassisN/cardN/portN" string, to be supplied as the parent_handle
    # for a .../XxxRange 
    # note: the element that must be returned is a hag object
    # representing the parent of the highest level ancestor auto-generated 
    # by the
    # target object ($self). it should not the immediate parent of target object
    #
    snit::method ${RANGE} _cast_handle_to_parent_obj {i_handle args} {
        # If the thing passed in is a simple chassisN/cardN/portN string
        # we need to morph it into a hag object
        if {![regexp -- {^[0-9]+/[0-9]+/[0-9]+$} $i_handle]} {
            # not a port string, assume we've been passed a hag object
            return $i_handle; 
        } 
        set port_str $i_handle
        set protocol_stack_type "ethernet"
        if {[string match "*/atm/*" [$self _typepath]]} {
            set protocol_stack_type "atm"
        }
        set rval [$Shell _make_endpoint_ancestors_from_port_str \
            $self $port_str $protocol_stack_type]
        return $rval
    }

    #
    # This override declares the (aggregate) stats for this type
    #
    snit::typemethod ${RANGE} _aggregate_stat_decl {inst} {
      set decl {
        dhcpv4 "DHCPv4 Server" {
            "Discovers Received" "discovers_received"
            "Offers Sent" "offers_sent"
            "Requests Received" "requests_received"
            "ACKs Sent" "acks_sent"
            "NACKs Sent" "nacks_sent"
            "Declines Received" "declines_received"
            "Releases Received" "releases_received"
            "Informs Received" "informs_received"
            "Total Leases Allocated" "total_leases_allocated"
            "Total Leases Renewed" "total_leases_renewed"
            "Current Leases Allocated" "current_leases_allocated"
            "Port Name" "port_name"
        }
      }; # end set decl
      return $decl
    }
}
