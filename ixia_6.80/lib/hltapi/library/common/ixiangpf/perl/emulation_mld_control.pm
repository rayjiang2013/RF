##Procedure Header
# Name:
#    ixiangpf::emulation_mld_control
#
# Description:
#    Controls MLD sessions.
#
# Synopsis:
#    ixiangpf::emulation_mld_control
#        -mode                   CHOICES start
#                                CHOICES stop
#                                CHOICES restart
#                                CHOICES join
#                                CHOICES leave
#                                CHOICES rejoin
#                                CHOICES releave
#                                CHOICES mld_send_specific_query
#                                CHOICES mld_resume_periodic_gen_query
#                                CHOICES mld_stop_periodic_gen_query
#        [-handle                ANY]
#        [-port_handle           REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
#        [-group_member_handle   ANY]
#        [-source_member_handle  ANY]
#x       [-start_group_address   IPV6
#x                               DEFAULT ff03:0:0:0:0:0:0:1]
#x       [-group_count           NUMERIC
#x                               DEFAULT 1]
#x       [-start_source_address  IPV6
#x                               DEFAULT aaaa:0:0:0:0:0:0:0]
#x       [-source_count          NUMERIC
#x                               DEFAULT 0]
#x       [-source_increment_step NUMERIC
#x                               DEFAULT 1]
#
# Arguments:
#    -mode
#        This option defines the action to be taken.
#    -handle
#        If -mode is join or leave, all group pools belonging to the MLD
#        session specified with this option will join or leave.
#        Example :-
#        ::ixiangpf::emulation_mld_control -handle $device1handle -mode [start or stop]
#    -port_handle
#        This option is required to specify the port where to take the action.
#    -group_member_handle
#        If -mode is join or leave this option specifies the group pools
#        to join or leave.
#    -source_member_handle
#        If -mode is join or leave this option specifies the source pools
#        to join or leave. If -port_handle is provided along with -source_member_handle and -mode join/leave, the specified source will be enabled/disabled.
#        If -source_member_handle is provided only with -mode join/leave, the source will execute join/leave.
#x   -start_group_address
#x       Start group address for the mld host on which the action defined by the –mode parameter will be applied
#x   -group_count
#x       Group count for the mld host on which the action defined by the –mode parameter will be applied
#x   -start_source_address
#x       Start source address for the mld host address on which the action defined by the –mode parameter will be applied
#x   -source_count
#x       Source count for the mld host on which the action defined by the –mode parameter will be applied
#x   -source_increment_step
#x       Source Increment Step for the mld host on which the action defined by the –mode parameter will be applied
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status  value:$::SUCCESS | $::FAILURE
#    When status is failure, contains more information
#    key:log     value:When status is failure, contains more information
#
# Examples:
#    See files starting with MLD_ in the Samples subdirectory.
#    See the MLD example in Appendix A, "Example APIs," for one specific example usage.
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    1) MLD implementation using IxTclNetwork is NOT SUPPORTED in HLTAPI 3.20.
#
# See Also:
#

package ixiangpf;

use utils;
use ixiahlt;

sub emulation_mld_control {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('emulation_mld_control', $args);
	# ixiahlt::utrackerLog ('emulation_mld_control', $args);

	return ixiangpf::runExecuteCommand('emulation_mld_control', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
