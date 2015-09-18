##Procedure Header
# Name:
#    ixiangpf::traffic_tag_config
#
# Description:
#    This method is used to configure traffic tag for a protocol stack
#
# Synopsis:
#    ixiangpf::traffic_tag_config
#x       [-handle  ANY]
#        [-mode    CHOICES create modify delete
#                  DEFAULT create]
#x       [-enabled CHOICES 0 1]
#x       [-name    ALPHA]
#x       [-id      NUMERIC]
#
# Arguments:
#x   -handle
#x       For create: protocol stack handle needed to configure traffic tag.
#x       For modify/delete: tag handle that must be modified/deleted
#    -mode
#        Which mode is being performed.
#x   -enabled
#x       Enables/disables tags
#x   -name
#x       specifies the name of the tag the entity will be part of
#x   -id
#x       the tag ids that this entity will use/publish
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status              value:$::SUCCESS | $::FAILURE
#    On status of failure, gives detailed information.
#    key:log                 value:On status of failure, gives detailed information.
#    A handle that can be used to modify/delete the tag
#    key:traffic_tag_handle  value:A handle that can be used to modify/delete the tag
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

sub traffic_tag_config {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('traffic_tag_config', $args);
	# ixiahlt::utrackerLog ('traffic_tag_config', $args);

	return ixiangpf::runExecuteCommand('traffic_tag_config', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
