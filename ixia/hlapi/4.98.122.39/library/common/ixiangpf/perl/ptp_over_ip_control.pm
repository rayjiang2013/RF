##Procedure Header
# Name:
#    ixiangpf::ptp_over_ip_control
#
# Description:
#    Perform control plane operations on an endpoint created
#    by a ::ixiangpf::ptp_over_ip_config command
#
# Synopsis:
#    ixiangpf::ptp_over_ip_control
#        -handle  ANY
#        -action  CHOICES abort
#                 CHOICES abort_async
#                 CHOICES start
#                 CHOICES connect
#                 CHOICES stop
#                 CHOICES disconnect
#
# Arguments:
#    -handle
#        A handle returned via a ::<namespace>::ptp_over_ip_config
#        command. This is the object on which the action will take place.
#    -action
#        Action to be executed. Valid choices are:
#        abort- abort all sessions on the same port with the target
#        endpoint designated by -handle. The control is
#        returned when the operation is completed.
#        abort_async- abort all sessions on the same port with the target
#        endpoint designated by -handle. The control is
#        returned immediately. The operation is executed in the background.
#        start/connect - start and/or negotiate session for the target endpoint
#        designated by -handle. Start and connect offer the same functionality.
#        stop/disconnect - stop and/or release session for the target endpoint
#        designated by -handle. Stop and disconnect offer the same functionality.
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status  value:$::SUCCESS | $::FAILURE
#    When status is failure, contains more information
#    key:log     value:When status is failure, contains more information
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    This command applies only to IxNetwork.
#
# See Also:
#

package ixiangpf;

use utils;
use ixiahlt;

sub ptp_over_ip_control {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('ptp_over_ip_control', $args);
	# ixiahlt::utrackerLog ('ptp_over_ip_control', $args);

	return ixiangpf::runExecuteCommand('ptp_over_ip_control', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
