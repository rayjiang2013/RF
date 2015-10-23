#
#
#
set T ::ixia::hag::ixn::types

#
# Override some default properties when a (hag) bgp object is created
#
# Return value should be a list of the form:
#
# {-option default_value .... -option default_value}
#
snit::method ${T}::/vport/protocols/bgp \
_alterations_to_option_defaults {} {
    return {
        -enabled true
    }
}
