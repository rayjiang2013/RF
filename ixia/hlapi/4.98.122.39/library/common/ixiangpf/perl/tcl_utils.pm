package ixiangpf_utils;

use Tcl;
use File::Spec;
use File::Basename;
use ixiatcl;

sub import() {
    if (defined($ixiangpf_utils::initialized)) {
        return 1;
    }

    # Do a package require Ixia just in case we need it
	ixiatcl::_xeval('package require Ixia');

	# Make an accessor for the RequiresHlapiConnect util
	sub RequiresHlapiConnect() {
		return ixiatcl::_xeval('RequiresHlapiConnect');
	}

	# Make an accessor for the GetPortMapping util
	sub GetPortMapping() {
		return ixiatcl::_xeval('GetPortMapping');
	}	
}

# Return value for the package
return 1;
