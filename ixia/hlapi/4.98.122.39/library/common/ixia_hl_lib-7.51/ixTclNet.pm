#
# ixTclNet.pm
#
use Tcl;
use warnings;
use strict;
use Carp;
use ixiatcl;
use ixiaixn;

package ixTclNet;
sub initialize_package() {
    $ixTclNet::initialized = "1.0.0";

    sub AssignPorts {
     ::ixiatcl::_xinvoke('::ixTclNet::AssignPorts', @_);
    };
    sub ApplyTraffic {
     ::ixiatcl::_xinvoke('::ixTclNet::ApplyTraffic', @_);
    };
    sub StartTraffic {
     ::ixiatcl::_xinvoke('::ixTclNet::StartTraffic', @_);
    };
    sub StopTraffic {
     ::ixiatcl::_xinvoke('::ixTclNet::StopTraffic', @_);
    };
    sub GetProtocolHeaderFromPacket {
     ::ixiatcl::_xinvoke('::ixTclNet::GetProtocolHeaderFromPacket', @_);
    };
    sub GetFieldFromProtocolHeader {
     ::ixiatcl::_xinvoke('::ixTclNet::GetFieldFromProtocolHeader', @_);
    };
};
ixTclNet::initialize_package();
## return value for package
1;
