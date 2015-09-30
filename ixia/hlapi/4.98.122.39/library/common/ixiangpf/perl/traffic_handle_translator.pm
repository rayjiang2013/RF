package ixiangpf;

use utils;
use ixiahlt;

sub traffic_handle_translator {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('traffic_handle_translator', $args);
	# ixiahlt::utrackerLog ('traffic_handle_translator', $args);

	return ixiangpf::runExecuteCommand('traffic_handle_translator', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
