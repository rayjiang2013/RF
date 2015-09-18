package ixiangpf;

use utils;
use tcl_utils;
use ixiahlt;

sub cleanup_session {

	if (defined($ixiangpf::sessionId)) {
		
		# Try to cleanup the corresponding session node
		if (defined($ixiangpf::ixNet)) {
			
			$ixiangpf::ixNet->remove($ixiangpf::sessionId);
			my $ixNetCommitResult = CommitChangesAndHandlePublisherErrors($ixiangpf::ixNet);
			if ($ixNetCommitResult == $ixiangpf::FAIL) {
				return $ixiangpf::FAIL;
			}
			
			# Cleanup the IxNetwork connection
			$ixiangpf::ixNet = undef;
		}
		$ixiangpf::sessionId = undef;
	}
	return ixiahlt::cleanup_session(@_);
}

# Return value for the package
return 1;
