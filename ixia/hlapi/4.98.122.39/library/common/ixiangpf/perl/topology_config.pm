##Procedure Header
# Name:
#    ixiangpf::topology_config
#
# Description:
#    This command will create a topology and one or multiple device groups.
#    This is the building block of creating a new scenario in IxNetwork.
#
# Synopsis:
#    ixiangpf::topology_config
#        [-mode                    CHOICES config modify destroy
#                                  DEFAULT config]
#x       [-topology_name           ALPHA]
#x       [-topology_handle         ANY]
#        [-port_handle             REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
#x       [-device_group_name       ALPHA]
#x       [-device_group_multiplier NUMERIC
#x                                 DEFAULT 10]
#x       [-device_group_enabled    CHOICES 0 1]
#x       [-device_group_handle     ANY]
#x       [-protocol_stacking_mode  CHOICES parallel sequential
#x                                 DEFAULT sequential]
#x       [-protocol_rate_mode      CHOICES basic smooth
#x                                 DEFAULT basic]
#
# Arguments:
#    -mode
#        Action to be taken on the interface selected.
#        This option takes a list of values when -port_handle is a list of
#        port handles.
#        This option is valid for the old and the new APIs.
#        When ::ixia::interface_config is provided with -port_handle
#        parameter, -mode modify and other supported parameters,
#        except -interface_handle, the modification is supported
#        for L1 parameters only.
#        When ::ixia::interface_config is provided with -port_handle
#        parameter, -mode modify and other supported parameters,
#        including -interface_handle, the modification is supported
#        for L2-L3 parameters also, but only for protocol
#        interfaces (-l23_config_type protocol_interface). This argument does not support lists.
#x   -topology_name
#x       The name of the topology that will be shown in the IxNetwork GUI.
#x       You can create at most one topology with a topology_config command.
#x       This argument is optional and does not suuport lists.
#x   -topology_handle
#x       Handle for the topology that the user wants to modify or delete. This argument does not support lists.
#    -port_handle
#        List of ports to be added to the topology.
#x   -device_group_name
#x       The name of the device group that will be shown in the IxNetwork GUI.
#x       This argument is optional and does not support lists.
#x   -device_group_multiplier
#x       The number of devices that will be simulated for each port assigned to the
#x       parent topology or each device simulated in the parent device group. This argument does not support lists.
#x   -device_group_enabled
#x       This argument can be used to disable or enable individual devices within
#x       the specified device group. This argument does not support lists.
#x   -device_group_handle
#x       Handle for the device group that the user wants to modify,
#x       delete or use as a parent for a new device group. This argument does not support lists.
#x   -protocol_stacking_mode
#x       Decides whether NGPF sessions will be started sequentially or in parallel across the protocols layers.
#x   -protocol_rate_mode
#x       Decides how the rate of starting and stopping NGPF sessions will be controlled.
#
# Return Values:
#    A list containing the topology protocol stack handles that were added by the command (if any).
#x   key:topology_handle      value:A list containing the topology protocol stack handles that were added by the command (if any).
#    A list containing the device group protocol stack handles that were added by the command (if any).
#x   key:device_group_handle  value:A list containing the device group protocol stack handles that were added by the command (if any).
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    When -handle is provided with the /globals value the arguments that configure global protocol
#    setting accept both multivalue handles and simple values.
#    When -handle is provided with a a protocol stack handle or a protocol session handle, the arguments
#    that configure global settings will only accept simple values. In this situation, these arguments will
#    configure only the settings of the parent device group or the ports associated with the parent topology.
#
# See Also:
#

package ixiangpf;

use utils;
use ixiahlt;

sub topology_config {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('topology_config', $args);
	# ixiahlt::utrackerLog ('topology_config', $args);

	return ixiangpf::runExecuteCommand('topology_config', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
