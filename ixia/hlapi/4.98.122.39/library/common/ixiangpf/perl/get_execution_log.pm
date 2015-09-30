##Procedure Header
# Name:
#    ixiangpf::get_execution_log
#
# Description:
#    this method returns the current hl execution log file path
#    The result key is "execution_log"
#
# Synopsis:
#    ixiangpf::get_execution_log
#
# Arguments:
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
#

package ixiangpf;

use utils;
use ixiahlt;

sub get_execution_log {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('get_execution_log', $args);
	# ixiahlt::utrackerLog ('get_execution_log', $args);

	return ixiangpf::runExecuteCommand('get_execution_log', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
