##Procedure Header
# Name:
#    ixiangpf::emulation_ancp_control
#
# Description:
#    This procedure controls ANCP actions.
#
# Synopsis:
#    ixiangpf::emulation_ancp_control
#n       [-action_control      ANY]
#        -action               CHOICES send-reset
#                              CHOICES enable
#                              CHOICES disable
#                              CHOICES reset
#                              CHOICES flap_start
#                              CHOICES flap_stop
#                              CHOICES send_port_up
#                              CHOICES send_port_down
#n       [-action_control_type ANY]
#        [-ancp_handle         ANY]
#        [-ancp_subscriber     ANY]
#n       [-batch_size          ANY]
#n       [-interval            ANY]
#n       [-interval_unit       ANY]
#n       [-iteration_count     ANY]
#n       [-job_handle          ANY]
#n       [-peer_count          ANY]
#
# Arguments:
#n   -action_control
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -action
#        This is a mandatory argument. Used to select the task to perform.
#        Flapping is applicable for line subscriber devices only. This parameter
#        is supported using the following APIs: IxTclNetwork.Valid choices are:
#        send-reset - Not Supported.
#        enable - Enable ANCP protocol.
#        disable - Disable ANCP configuration.
#        reset - Not Supported.
#        flap_start - Not Supported.
#        flap_stop - Not Supported.
#n   -action_control_type
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -ancp_handle
#        ANCP range to start|stop ANCP emulation on. Emulation is started |
#        stopped for all ANCP ranges on port. This parameter is supported using
#        the following APIs: IxTclNetwork.
#    -ancp_subscriber
#        Used to specify the ANCP line subscriber device handle.
#n   -batch_size
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -interval
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -interval_unit
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -iteration_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -job_handle
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -peer_count
#n       This argument defined by Cisco is not supported for NGPF implementation.
#
# Return Values:
#    $::SUCCESS | $::FAILURE Status of procedure call.
#    key:status  value:$::SUCCESS | $::FAILURE Status of procedure call.
#    When status is failure, contains more information.
#    key:log     value:When status is failure, contains more information.
#    ANCP device handles.
#    key:handle  value:ANCP device handles.
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    1) Unsupported parameters or unsupported parameter options will be
#    silently ignored.
#
# See Also:
#

package ixiangpf;

use utils;
use ixiahlt;

sub emulation_ancp_control {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('emulation_ancp_control', $args);
	# ixiahlt::utrackerLog ('emulation_ancp_control', $args);

	return ixiangpf::runExecuteCommand('emulation_ancp_control', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
