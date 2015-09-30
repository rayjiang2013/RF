package ixiangpf;

use utils;
use ixiahlt;

sub ixnetwork_traffic_control {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('ixnetwork_traffic_control', $args);
	# ixiahlt::utrackerLog ('ixnetwork_traffic_control', $args);

	return ixiangpf::runExecuteCommand('ixnetwork_traffic_control', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
