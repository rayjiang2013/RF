#
#
#

set _ENDPOINT_T "dcbxEndpoint"
set _RANGE_T "dcbxRange"
set _TLV_T "dcbxTlv"
set T ::ixia::hag::ixn::types

foreach x { ethernet } {

    snit::method \
    ${T}::/vport/protocolStack/$x/$_ENDPOINT_T/range/$_RANGE_T/$_TLV_T \
    _configure_args_multiplier {m n args} {
        if {[llength $args] == 1} {set args [lindex $args 0]}
        catch {
            set tlvqaz_feature_type [$Shell arg_pluck -feature_type args "dcbxTlv::_configure_args_multiplier"]
            set args [linsert $args 0 -feature_type $tlvqaz_feature_type]
        }
        $Shell _configure_args_multiplier $self $m $n $args
    }
    
}
