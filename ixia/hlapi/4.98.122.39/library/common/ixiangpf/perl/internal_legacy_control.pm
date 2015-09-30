package ixiangpf;

use utils;
use ixiahlt;

sub internal_legacy_control {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('internal_legacy_control', $args);
	# ixiahlt::utrackerLog ('internal_legacy_control', $args);

	return ixiangpf::runExecuteCommand('internal_legacy_control', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
