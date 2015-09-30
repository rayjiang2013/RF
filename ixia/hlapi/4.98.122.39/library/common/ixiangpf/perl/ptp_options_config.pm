##Procedure Header
# Name:
#    ixiangpf::ptp_options_config
#
# Description:
#    Performs ptp_options configuration.
#    PortGroup settings placeholder for PtpPlugin.
#
# Synopsis:
#    ixiangpf::ptp_options_config
#        -mode                                CHOICES create add modify delete
#        -parent_handle                       ANY
#        [-handle                             ANY]
#n       [-style                              ANY]
#n       [-max_outstanding                    ANY]
#        [-override_global_rate_options       CHOICES 0 1]
#        [-role                               CHOICES master
#                                             CHOICES slave
#                                             CHOICES transparentMaster
#                                             DEFAULT master]
#        [-setup_rate                         RANGE 1-1000
#                                             DEFAULT 5]
#        [-teardown_rate                      RANGE 1-1000
#                                             DEFAULT 5]
#x       [-tos                                ANY]
#x       [-traffic_class                      ANY]
#        [-override_global_start_rate_options CHOICES 0 1]
#        [-override_global_stop_rate_options  CHOICES 0 1]
#x       [-start_rate_interval                ANY]
#x       [-stop_rate_interval                 ANY]
#x       [-start_scale_mode                   CHOICES deviceGroup port
#x                                            DEFAULT port]
#x       [-stop_scale_mode                    CHOICES deviceGroup port
#x                                            DEFAULT port]
#
# Arguments:
#    -mode
#        create - not supported in case of ::ixiangpf::ptp_options_config.
#        add - not supported in case of ::ixiangpf::ptp_options_config.
#        modify - modified attributes on the given object by the -handle param
#        delete - not supported in case of ::ixiangpf::ptp_options_config.
#    -parent_handle
#        The parent handle used for creating this object.
#    -handle
#        A handle returned via a ::ixiangpf::ptp_over_mac_config/ptp_over_ip_config command or the /globals handle. Valid for mode create.
#n   -style
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -max_outstanding
#n       This argument defined by Cisco is not supported for NGPF implementation.
#    -override_global_rate_options
#        If true then all the rate settings defined at Session level will be overriden by
#        rate settings defined on this PortGroup.
#    -role
#        Clock type.
#        Valid choices are:
#        master - Master
#        slave - Slave
#    -setup_rate
#        Initiation rate for the PTP connection establishement.
#        The number of PTP connections initiated in a second.
#    -teardown_rate
#        Teardown rate for the PTP connection establishement.
#        The number of PTP connections torn down in a second.
#x   -tos
#x       TOS/DSCP set for PTP packets over IPv4
#x   -traffic_class
#x       Traffic Class set for PTP packets over IPv6
#    -override_global_start_rate_options
#        If true then all the rate settings defined at Session level will be overriden by
#        rate settings defined on this PortGroup.
#    -override_global_stop_rate_options
#        If true then all the rate settings defined at Session level will be overriden by
#        rate settings defined on this PortGroup.
#x   -start_rate_interval
#x       Time interval used to calculate the rate for triggering an action(rate = count/interval)
#x   -stop_rate_interval
#x       Time interval used to calculate the rate for triggering an action(rate = count/interval)
#x   -start_scale_mode
#x       Indicates whether the control is specified per port or per device group
#x   -stop_scale_mode
#x       Indicates whether the control is specified per port or per device group
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
#
# See Also:
#    External documentation on Tclx keyed lists
#

package ixiangpf;

use utils;
use ixiahlt;

sub ptp_options_config {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('ptp_options_config', $args);
	# ixiahlt::utrackerLog ('ptp_options_config', $args);

	return ixiangpf::runExecuteCommand('ptp_options_config', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
