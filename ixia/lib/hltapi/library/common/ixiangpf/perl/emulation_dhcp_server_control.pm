##Procedure Header
# Name:
#    ixiangpf::emulation_dhcp_server_control
#
# Description:
#    This procedure controls DHCP Server actions.
#
# Synopsis:
#    ixiangpf::emulation_dhcp_server_control
#        [-dhcp_handle ANY]
#        [-port_handle ANY]
#n       [-args        ANY]
#        -action       CHOICES abort
#                      CHOICES abort_async
#                      CHOICES renew
#                      CHOICES reset
#                      CHOICES collect
#                      CHOICES restart_down
#                      CHOICES force_renew
#                      CHOICES reconfigure
#
# Arguments:
#    -dhcp_handle
#        DHCP Server range to perform action for. This parameter is supported using
#        the following APIs: IxTclNetwork.
#    -port_handle
#        The port handle to perform action for. This parameter is supported using
#        the following APIs: IxTclNetwork.
#n   -args
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -action
#        This is a mandatory argument. Used to select the task to perform.
#        This parameter is supported using the following APIs: IxTclNetwork.
#        Valid choices are: abort abort_async renew reset collect restart_down force_renew reconfigure.
#
# Return Values:
#    $::SUCCESS | $::FAILURE Status of procedure call.
#    key:status  value:$::SUCCESS | $::FAILURE Status of procedure call.
#    When status is failure, contains more information.
#    key:log     value:When status is failure, contains more information.
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

sub emulation_dhcp_server_control {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('emulation_dhcp_server_control', $args);
	# ixiahlt::utrackerLog ('emulation_dhcp_server_control', $args);

	return ixiangpf::runExecuteCommand('emulation_dhcp_server_control', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
