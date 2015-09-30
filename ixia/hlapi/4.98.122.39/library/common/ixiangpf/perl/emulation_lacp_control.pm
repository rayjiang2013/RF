##Procedure Header
# Name:
#    ixiangpf::emulation_lacp_control
#
# Description:
#    Control Operation on the LACP/Static LAG Protocol
#    The following operations are done:
#    1. Restart
#    2. Send Marker Request
#    3. Start
#    4. Start PDU
#    5. Stop
#    6. Stop PDU
#
# Synopsis:
#    ixiangpf::emulation_lacp_control
#        -mode          CHOICES restart
#                       CHOICES send_marker_req
#                       CHOICES start
#                       CHOICES restart_down
#                       CHOICES start_pdu
#                       CHOICES stop
#                       CHOICES stop_pdu
#                       CHOICES abort
#        [-port_handle  REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
#        [-handle       ANY]
#        [-session_type CHOICES lacp staticLag
#                       DEFAULT lacp]
#
# Arguments:
#    -mode
#        What is being done to the protocol.Valid choices are:
#        restart - Restart the protocol.
#        start- Start the protocol.
#        stop- Stop the protocol.
#        start_pdu- start_pdu the protocol.
#        stop_pdu- stop_pdu the protocol.
#        send_marker_req- send_marker_req the protocol.
#    -port_handle
#        The port on which to perform action.
#    -handle
#    -session_type
#        The LACP to be emulated. CHOICES: lacp staticLag.
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status  value:$::SUCCESS | $::FAILURE
#    If status is failure, detailed information provided.
#    key:log     value:If status is failure, detailed information provided.
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

sub emulation_lacp_control {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('emulation_lacp_control', $args);
	# ixiahlt::utrackerLog ('emulation_lacp_control', $args);

	return ixiangpf::runExecuteCommand('emulation_lacp_control', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
