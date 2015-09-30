package ixiangpf;

use utils;
use ixiahlt;

sub internal_compress_overlays {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('internal_compress_overlays', $args);
	# ixiahlt::utrackerLog ('internal_compress_overlays', $args);

	return ixiangpf::runExecuteCommand('internal_compress_overlays', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
