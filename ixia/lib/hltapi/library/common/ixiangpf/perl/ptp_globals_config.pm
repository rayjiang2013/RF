##Procedure Header
# Name:
#    ixiangpf::ptp_globals_config
#
# Description:
#    Not supported in ixiangpf namespace.
#
# Synopsis:
#    ixiangpf::ptp_globals_config
#        -mode             CHOICES create add modify delete
#        -parent_handle    ANY
#        [-handle          ANY]
#        [-style           ANY]
#        [-max_outstanding RANGE 1-10000
#                          DEFAULT 20]
#        [-setup_rate      RANGE 1-20000
#                          DEFAULT 5]
#        [-teardown_rate   RANGE 1-20000
#                          DEFAULT 5]
#
# Arguments:
#    -mode
#        Not supported in ixiangpf namespace.
#    -parent_handle
#        Not supported in ixiangpf namespace.
#    -handle
#        Not supported in ixiangpf namespace.
#    -style
#        Not supported in ixiangpf namespace.
#    -max_outstanding
#        Not supported in ixiangpf namespace.
#    -setup_rate
#        Not supported in ixiangpf namespace.
#    -teardown_rate
#        Not supported in ixiangpf namespace.
#
# Return Values:
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#    External documentation on Tclx keyed lists
#

package ixiangpf;

use utils;
use ixiahlt;

sub ptp_globals_config {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('ptp_globals_config', $args);
	# ixiahlt::utrackerLog ('ptp_globals_config', $args);

	return ixiangpf::runExecuteCommand('ptp_globals_config', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
