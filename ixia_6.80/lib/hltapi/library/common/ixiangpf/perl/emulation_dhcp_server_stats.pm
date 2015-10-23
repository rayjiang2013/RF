##Procedure Header
# Name:
#    ixiangpf::emulation_dhcp_server_stats
#
# Description:
#    This procedure retrieves DHCP Server stats.
#
# Synopsis:
#    ixiangpf::emulation_dhcp_server_stats
#        [-dhcp_handle       ANY]
#        [-handle            ANY]
#        [-port_handle       ANY]
#        [-ip_version        CHOICES 4 6
#                            DEFAULT 4]
#        -action             CHOICES clear collect
#x       [-execution_timeout NUMERIC
#x                           DEFAULT 1800]
#
# Arguments:
#    -dhcp_handle
#        DHCP Server range to perform action for. This parameter is supported using
#        the following APIs: IxTclNetwork. The DHCP Server stats per handle are not supported.
#        The aggregated ones will be returned instead, for the port_handle on which the DHCP Server handle belongs.
#        This parameter acts in the same way as handle. It is implemented for backwards compatibility.
#    -handle
#        DHCP Server range to perform action for. This parameter is supported using
#        the following APIs: IxTclNetwork. The DHCP Server stats per handle are not supported.
#        The aggregated ones will be returned instead, for the port_handle on which the DHCP Server handle belongs.
#    -port_handle
#        The port handle to perform action for. This parameter is supported using
#        the following APIs: IxTclNetwork.
#    -ip_version
#        DHCP Server IP type. This parameter is supported using
#        the following APIs: IxTclNetwork. The DHCP Server stats per handle are not supported.
#        The aggregated ones will be returned instead, for the port_handle on which the DHCP Server handle belogs.
#    -action
#        This is a mandatory argument. Used to select the task to perform.
#        This parameter is supported using the following APIs: IxTclNetwork.Valid choices are: clear collect.
#x   -execution_timeout
#x       This is the timeout for the function.
#x       The setting is in seconds.
#x       Setting this setting to 60 it will mean that the command must complete in under 60 seconds.
#x       If the command will last more than 60 seconds the command will be terminated by force.
#x       This flag can be used to prevent dead locks occuring in IxNetwork.
#
# Return Values:
#    $::SUCCESS | $::FAILURE Status of procedure call.
#    key:status                                               value:$::SUCCESS | $::FAILURE Status of procedure call.
#    When status is failure, contains more information.
#    key:log                                                  value:When status is failure, contains more information.
#    Valid for ip_version 4
#x   key:aggregate.<port_handle>.tx.advertisement             value:Valid for ip_version 4
#    Valid for ip_version 6
#x   key:aggregate.<port_handle>.rx.confirm                   value:Valid for ip_version 6
#    Valid for ip_version 4,6
#    key:aggregate.<port_handle>.rx.decline                   value:Valid for ip_version 4,6
#    Valid for ip_version 4
#    key:aggregate.<port_handle>.rx.discover                  value:Valid for ip_version 4
#    Valid for ip_version 4,6
#    key:aggregate.<port_handle>.rx.inform                    value:Valid for ip_version 4,6
#n   key:aggregate.<port_handle>.rx.offer                     value:
#    Valid for ip_version 6
#x   key:aggregate.<port_handle>.rx.rebind                    value:Valid for ip_version 6
#    Valid for ip_version 6
#x   key:aggregate.<port_handle>.rx.relay_forward             value:Valid for ip_version 6
#    Valid for ip_version 6
#x   key:aggregate.<port_handle>.rx.relay_reply               value:Valid for ip_version 6
#    Valid for ip_version 6
#x   key:aggregate.<port_handle>.reconfigure_tx               value:Valid for ip_version 6
#    Valid for ip_version 6
#x   key:aggregate.<port_handle>.nak_sent                     value:Valid for ip_version 6
#    Valid for ip_version 6
#x   key:aggregate.<port_handle>.solicits_ignored             value:Valid for ip_version 6
#    Valid for ip_version 4,6
#    key:aggregate.<port_handle>.rx.release                   value:Valid for ip_version 4,6
#    Valid for ip_version 6
#x   key:aggregate.<port_handle>.rx.renew                     value:Valid for ip_version 6
#    Valid for ip_version 4,6
#    key:aggregate.<port_handle>.rx.request                   value:Valid for ip_version 4,6
#    Valid for ip_version 6
#    key:aggregate.<port_handle>.rx.solicit                   value:Valid for ip_version 6
#n   key:aggregate.<port_handle>.rx.ack                       value:
#n   key:aggregate.<port_handle>.rx.nak                       value:
#n   key:aggregate.<port_handle>.rx.force_renew               value:
#n   key:aggregate.<port_handle>.rx.relay_agent               value:
#n   key:aggregate.<port_handle>.tx.discover                  value:
#    Valid for ip_version 4
#    key:aggregate.<port_handle>.tx.offer                     value:Valid for ip_version 4
#n   key:aggregate.<port_handle>.tx.request                   value:
#    Valid for ip_version 4
#x   key:aggregate.<port_handle>.tx.reply                     value:Valid for ip_version 4
#n   key:aggregate.<port_handle>.tx.decline                   value:
#    Valid for ip_version 4
#    key:aggregate.<port_handle>.tx.ack                       value:Valid for ip_version 4
#    Valid for ip_version 4
#    key:aggregate.<port_handle>.tx.nak                       value:Valid for ip_version 4
#n   key:aggregate.<port_handle>.tx.release                   value:
#n   key:aggregate.<port_handle>.tx.inform                    value:
#    key:aggregate.<port_handle>.tx.force_renew               value:
#n   key:aggregate.<port_handle>.allocated.ip                 value:
#n   key:aggregate.<port_handle>.port_name                    value:
#x   key:aggregate.<port_handle>.total_leases_allocated       value:
#x   key:aggregate.<port_handle>.total_leases_renewed         value:
#x   key:aggregate.<port_handle>.current_leases_allocated     value:
#    Valid for ip_version 6
#x   key:aggregate.<port_handle>.total_addresses_allocated    value:Valid for ip_version 6
#    Valid for ip_version 6
#x   key:aggregate.<port_handle>.total_addresses_renewed      value:Valid for ip_version 6
#    Valid for ip_version 6
#x   key:aggregate.<port_handle>.current_addresses_allocated  value:Valid for ip_version 6
#    Valid for ip_version 6
#x   key:aggregate.<port_handle>.total_prefixes_allocated     value:Valid for ip_version 6
#    Valid for ip_version 6
#x   key:aggregate.<port_handle>.total_prefixes_renewed       value:Valid for ip_version 6
#    Valid for ip_version 6
#x   key:aggregate.<port_handle>.current_prefixes_allocated   value:Valid for ip_version 6
#    key:<device_group>.aggregate.force_renew_count           value:
#    Valid for ip_version 6
#    key:<device_group>.aggregate.reconfigure_count           value:Valid for ip_version 6
#    Valid for ip_version 6
#    key:<device_group>.aggregate.nak_sent                    value:Valid for ip_version 6
#    Valid for ip_version 6
#    key:<device_group>.aggregate.solicits_ignored            value:Valid for ip_version 6
#n   key:dhcp_handle.<dhcp_handle>.rx.discover                value:
#n   key:dhcp_handle.<dhcp_handle>.rx.offer                   value:
#n   key:dhcp_handle.<dhcp_handle>.rx.request                 value:
#n   key:dhcp_handle.<dhcp_handle>.rx.decline                 value:
#n   key:dhcp_handle.<dhcp_handle>.rx.ack                     value:
#n   key:dhcp_handle.<dhcp_handle>.rx.nak                     value:
#n   key:dhcp_handle.<dhcp_handle>.rx.release                 value:
#n   key:dhcp_handle.<dhcp_handle>.rx.inform                  value:
#n   key:dhcp_handle.<dhcp_handle>.rx.force_renew             value:
#n   key:dhcp_handle.<dhcp_handle>.rx.relay_agent             value:
#    Valid for ip_version 6
#n   key:aggregate.<port_handle>.tx.discover                  value:Valid for ip_version 6
#    Valid for ip_version 6
#n   key:aggregate.<port_handle>.tx.offer                     value:Valid for ip_version 6
#n   key:dhcp_handle.<dhcp_handle>.tx.request                 value:
#n   key:dhcp_handle.<dhcp_handle>.tx.decline                 value:
#n   key:dhcp_handle.<dhcp_handle>.tx.ack                     value:
#n   key:dhcp_handle.<dhcp_handle>.tx.nak                     value:
#n   key:dhcp_handle.<dhcp_handle>.tx.release                 value:
#n   key:dhcp_handle.<dhcp_handle>.tx.inform                  value:
#n   key:dhcp_handle.<dhcp_handle>.tx.force_renew             value:
#n   key:dhcp_handle.<dhcp_handle>.allocated.ipn              value:
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    1) The not supported parameters or options of the parameters will be
#    silently ignored.
#
# See Also:
#

package ixiangpf;

use utils;
use ixiahlt;

sub emulation_dhcp_server_stats {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('emulation_dhcp_server_stats', $args);
	# ixiahlt::utrackerLog ('emulation_dhcp_server_stats', $args);

	return ixiangpf::runExecuteCommand('emulation_dhcp_server_stats', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
