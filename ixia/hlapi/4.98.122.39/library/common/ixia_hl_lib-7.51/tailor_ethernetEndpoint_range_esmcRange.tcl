#
#
#

set _ENDPOINT_T "ethernetEndpoint"
set _RANGE_T "esmcRange"
set T ::ixia::hag::ixn::types
eval {
    #
    # Ixnetwork only allows abort/start/stop at the endpoint level it seems
    # so override abort/start/stop to abort/start/stop
    # our grandparent when someone asks us to abort/start/stop
    #
    snit::method \
    ${T}::/vport/protocolStack/$_ENDPOINT_T/range/$_RANGE_T \
    abort {} { $Shell abort [$self _ancestor 2] }
    
    snit::method \
    ${T}::/vport/protocolStack/$_ENDPOINT_T/range/$_RANGE_T \
    abort_async {} { $Shell abort_async [$self _ancestor 2]}
    
    snit::method \
    ${T}::/vport/protocolStack/$_ENDPOINT_T/range/$_RANGE_T \
    start {} { $Shell start [$self _ancestor 2] }

    snit::method \
    ${T}::/vport/protocolStack/$_ENDPOINT_T/range/$_RANGE_T \
    stop {} { $Shell stop [$self _ancestor 2] }
    
    
    #
    # Override to allow a classis hlt port_handle", which is just a chassis
    # "chassisN/cardN/portN" string, to be supplied as the parent_handle
    # for a .../$_RANGE_T 
    # note: the element that must be returned is a hag object
    # representing the parent of the highest level ancestor auto-generated 
    # by the target object ($self). it should not the immediate parent 
    # of target object
    #
    snit::method \
    ${T}::/vport/protocolStack/$_ENDPOINT_T/range/$_RANGE_T \
    _cast_handle_to_parent_obj {i_handle args} {
        array set o $args

        set is_codegen_handle 1
        if {[catch {$i_handle _typepath}]} {
            set is_codegen_handle 0
        }

        if {$is_codegen_handle} {
            if {$o(-mode) == "create"} {
                if {[$i_handle _typepath_tail [$i_handle _typepath]] != "macRange"} {
                    return -code error "$self: Illegal parent handle $i_handle: typepath = [$i_handle _typepath]"
                }
                return [$i_handle _parent]
            } else {
                return $i_handle
            }
        }

        if {$o(-mode) != "create"} {
            return -error "$self: invalid mode $o(-mode) when specifying an ixn handle $i_handle"
        }
        
        # assume now it's a hlt handle
        set ixn_handle [string trim $i_handle {{}}]

        set path_parts [split $ixn_handle /]
        for {set i 0} {$i < [llength $path_parts]} {incr i} {
            if {[lindex $path_parts $i] == "protocolStack"} {
                break
            }
        }
        set port_handle [join [lrange $path_parts 0 $i] /]
        set ixn_ethEndpoint [join [lrange $path_parts 0 [incr i]] /]
        set ixn_ethEndpoint_range [join [lrange $path_parts 0 [incr i]] /]

        set l2_flavor "ethernetEndpoint"
        if {[string match "*/atm/*" [$self _typepath]]} {
            set l2_flavor "atmEndpoint"
        }
        
        set l2range_inst [$Shell _create_instance "/vport/protocolStack/$l2_flavor"]
        set own_ixn_handle 0
        $l2range_inst _set_ixn_handle $ixn_ethEndpoint $own_ixn_handle

        # this links the parents and children
        $Shell _make_endpoint_ancestors_from_flavor_inst $self $l2range_inst

        set range_inst [$Shell _inject_ixn_handle \
            [$l2range_inst _typepath]/range $ixn_ethEndpoint_range \
            $l2range_inst \
            [$l2range_inst _get_var Children] \
        ]

        # force add parent to ancestors in order to destroy the range
        $self _set_var Ancestors [concat [$self _get_var Ancestors] [list $range_inst]]

        return $range_inst
    }

    #
    # This override declares the (aggregate) stats for this type
    #
    snit::typemethod \
    ${T}::/vport/protocolStack/$_ENDPOINT_T/range/$_RANGE_T \
    _aggregate_stat_decl {inst} {
      set decl {
        gen "ESMC" {}
      }; # end set decl
      return $decl
    }

    snit::typemethod \
    ${T}::/vport/protocolStack/$_ENDPOINT_T/range/$_RANGE_T \
    _gen_config_arg_callback {param_name param_desc_ref} {
        upvar $param_desc_ref p_description

        switch -- $param_name {
            "-mode" {
                set p_description    "create - creates and configures a new object\n"
                append p_description "add - adds a child object to the one specified by the -handle param\n"
                append p_description "modify - modified attributes on the given object by the -handle param\n"
                append p_description "delete - this mode cannot be used.\n"
                append p_description "@         In order to delete ESMC ranges the ethernetrange_config command must be used\n"
                append p_description "@         with -mode delete on the parent handle of the ESMC range that has typepath:\n"
                append p_description "@         //vport/protocolStack/ethernetEndpoint/range/macRange"
            }
        }
    }
}
