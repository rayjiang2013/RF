proc ::ixiangpf::cleanup_session { args } {

	variable sessionId
	if {[info exists sessionId]} {
		catch {
			eval ixNet remove $sessionId
			
			# Catch any commit errors are report them in the keyed list format
			if { [catch {ixNet commit} ixNetError] } {
				keylset errorResult status 0
				keylset errorResult log $ixNetError
				return $errorResult
			}
		}
		unset sessionId
	}
	
	return [eval ::ixia::legacy_cleanup_session $args]
}

# --------------------------------------------------------------------------- #
# Export the cleanup_session function										  #
# --------------------------------------------------------------------------- #
namespace eval ::ixiangpf {
	namespace export cleanup_session
}

