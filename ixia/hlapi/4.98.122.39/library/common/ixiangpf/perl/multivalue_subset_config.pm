package ixiangpf;

use utils;
use ixiahlt;

sub multivalue_subset_config {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('multivalue_subset_config', $args);
	# ixiahlt::utrackerLog ('multivalue_subset_config', $args);

	return ixiangpf::runExecuteCommand('multivalue_subset_config', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
