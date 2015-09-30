##Procedure Header
# Name:
#    ixiangpf::emulation_isis_control
#
# Description:
#    Stop, start or restart the protocol.
#
# Synopsis:
#    ixiangpf::emulation_isis_control
#        -mode                CHOICES start
#                             CHOICES stop
#                             CHOICES restart
#                             CHOICES abort
#                             CHOICES restart_down
#                             CHOICES stop_hello
#                             CHOICES resume_hello
#                             CHOICES age_out_routes
#                             CHOICES readvertise_routes
#                             CHOICES disconnect
#                             CHOICES reconnect
#x       [-age_out_percent    NUMERIC]
#n       [-port_handle        ANY]
#        [-handle             ANY]
#n       [-advertise          ANY]
#n       [-flap_count         ANY]
#n       [-flap_down_time     ANY]
#n       [-flap_interval_time ANY]
#n       [-flap_routes        ANY]
#n       [-withdraw           ANY]
#
# Arguments:
#    -mode
#x   -age_out_percent
#x       The percentage of addresses that will be aged out. This argument is ignored when mode is not age_out_routes and *must* be specified in such circumstances.
#n   -port_handle
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -handle
#        ISIS session handle where the ISIS control action is applied.
#n   -advertise
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -flap_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -flap_down_time
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -flap_interval_time
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -flap_routes
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -withdraw
#n       This argument defined by Cisco is not supported for NGPF implementation.
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status  value:$::SUCCESS | $::FAILURE
#    If status is failure, detailed information provided.
#    key:log     value:If status is failure, detailed information provided.
#
# Examples:
#    See files starting with ISIS_ in the Samples subdirectory.  Also see some of the L3VPN, MPLS, and MVPN sample files for further examples of ISIS usage. See the ISIS example in Appendix A, "Example APIs," for one specific example usage.
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    Coded versus functional specification.
#
# See Also:
#

package ixiangpf;

use utils;
use ixiahlt;

sub emulation_isis_control {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('emulation_isis_control', $args);
	# ixiahlt::utrackerLog ('emulation_isis_control', $args);

	return ixiangpf::runExecuteCommand('emulation_isis_control', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
