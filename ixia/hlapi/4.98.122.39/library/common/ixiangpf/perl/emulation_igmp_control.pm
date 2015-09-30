##Procedure Header
# Name:
#    ixiangpf::emulation_igmp_control
#
# Description:
#    Stop, start, or restart the protocol. Note that IGMP is only
#    supported on ports with CPUs.
#
# Synopsis:
#    ixiangpf::emulation_igmp_control
#        -mode                   CHOICES stop
#                                CHOICES start
#                                CHOICES restart
#                                CHOICES join
#                                CHOICES leave
#                                CHOICES rejoin
#                                CHOICES releave
#                                CHOICES igmpSendSpecificQuery
#                                CHOICES igmpResumePeriodicGenQuery
#                                CHOICES igmpStopPeriodicGenQuery
#        [-group_member_handle   ANY]
#x       [-source_member_handle  ANY]
#        [-handle                ANY]
#        [-port_handle           REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
#x       [-start_group_address   IPV4
#x                               DEFAULT 125.0.0.1]
#x       [-group_count           NUMERIC
#x                               DEFAULT 1]
#x       [-start_source_address  IPV4
#x                               DEFAULT 10.10.10.0]
#x       [-source_count          NUMERIC
#x                               DEFAULT 0]
#x       [-source_increment_step NUMERIC
#x                               DEFAULT 1]
#
# Arguments:
#    -mode
#        The action that will be performed on the protocol instances.
#    -group_member_handle
#        The IGMP group range handle. This option is available when using IxTclProtocol or IxTclNetwork path.
#        When using IxTclNetwork, this parameter can be also given as an element or a list of elements in the following
#        format: (source IP)/(source IP step)/(source count). Eg: 50.0.1.2/0.0.0.1/3.
#x   -source_member_handle
#x       The IGMP source range handle. This option is available when using IxTclProtocol or IxTclNetwork path.
#x       When using IxTclNetwork, this parameter can be also given as an element or a list of elements in the following
#x       format: (group IP)/(group IP step)/(group count). Eg: 50.0.1.2/0.0.0.1/3.
#    -handle
#        The IGMP session handle (host or querier). When this parameter is used
#        with IxTclNetwork, it can also be provided as an IGMP host IP or a list
#        of IGMP host IPs.
#    -port_handle
#        The port where the IGMP is to be controlled. If IxTclNetwork path is used, and port_handle is used
#        with mode join/leave, the group members on each ports will be enabled/disabled.
#x   -start_group_address
#x       This attribute is used when -mode is "igmp_send_specific_query". The parameter represents the start group address.
#x   -group_count
#x       This attribute is used when -mode is "igmp_send_specific_query". The parameter represents the group count.
#x   -start_source_address
#x       This attribute is used when -mode is "igmp_send_specific_query". The parameter represents the start source address.
#x   -source_count
#x       This attribute is used when -mode is "igmp_send_specific_query". The parameter represents the source count.
#x   -source_increment_step
#x       This attribute is used when -mode is "igmp_send_specific_query". The parameter represents the source increment step.
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status  value:$::SUCCESS | $::FAILURE
#    If status is failure, detailed information provided.
#    key:log     value:If status is failure, detailed information provided.
#
# Examples:
#    See files starting with IGMPv1_, IGMPv2_, or IGMPv3_ in the Samples subdirectory. See the IGMP example in Appendix A, "Example APIs," for one specific example usage.
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    If neither -handle nor -port_handle is provided, the protocol will start on all ports that have IGMP configured. This is valid for IxTclNetwork path only.
#
# See Also:
#

package ixiangpf;

use utils;
use ixiahlt;

sub emulation_igmp_control {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('emulation_igmp_control', $args);
	# ixiahlt::utrackerLog ('emulation_igmp_control', $args);

	return ixiangpf::runExecuteCommand('emulation_igmp_control', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
