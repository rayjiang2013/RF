proc ::ixiangpf::connect { args } {
	
	# First call the legacy connect
	set ixiaConnect [eval ::ixia::legacy_connect $args]

	if {[keylget ixiaConnect status] == $::SUCCESS} {
			
		# Check if the connection to IxNetwork was already established
		variable sessionId	
		set portMapping [GetPortMapping]
		set needNewId 1

		# Check if this is a new session or an update to an existing one
		if {[info exists sessionId]} {
			catch {
				# Update the current session using the correct arguments				
				eval ixNet setMultiAtt $sessionId -HLApiPortMapping $portMapping $args -args_to_validate {$args}

				# Catch any commit errors are report them in the keyed list format
				if { [catch {ixNet commit} ixNetError] } {
					keylset errorResult status 0
					keylset errorResult log $ixNetError
					return $errorResult
				}
				set needNewId 0
			}
		}

		# If this is the first time we execute connect we should 
		# check the HLTSET to make sure we need to perform our connect
		if {$needNewId == 1} {
			set shouldConnectToIxNetwork [RequiresTclHlapiConnect $args]
		} else {
			keylset shouldConnectToIxNetwork status $::SUCCESS
			keylset shouldConnectToIxNetwork require 1
		}

		if {[keylget shouldConnectToIxNetwork status] == $::SUCCESS} {
			
		    if {[keylget shouldConnectToIxNetwork require] == $::SUCCESS} {
			
				if {$needNewId} {
					# Create a new session node and use the connect arguments to set values
					# for the corresponding attributes
					set machineName		[GetHostName]
					set userName		[GetUserName]
					set outputLanguage	tcl
					set newSessionId [eval ixNet add [ixNet getRoot]hlapi session -HLApiClientMachineName $machineName -HLApiClientUserName $userName -HLApiOutputLanguageName $outputLanguage -HLApiPortMapping $portMapping $args -args_to_validate {$args}]

					# Catch any commit errors are report them in the keyed list format
					if { [catch {ixNet commit} ixNetError] } {
						keylset errorResult status 0
						keylset errorResult log $ixNetError
						return $errorResult
					}
					# If the session was successfully updated we can create a global
					# variable that stores its ID and use it for all subsequent commands
					set sessionId [ixNet remapIds $newSessionId ]
                    
                    if {[info exists ::ixia::executeOnTclServer] && $::ixia::executeOnTclServer && \
                        [info exists ::ixia::connected_tcl_srv] && [info exists ::ixTclSvrHandle]} {
                        foreach var [info vars ::ixiangpf::*] {
                                clientSend $::ixTclSvrHandle \
                                            "set $var [set $var]"
                                }
                    }
				}
		
				# At this point we have a new session object and we need to call the
				# exec that triggers the internal updating of the arguments
				eval ixNet exec executeCommand "$sessionId"
				set ixiaHlapiConnect [runGetSessionStatus]
				keyldel ixiaHlapiConnect command_handled
			
				# Merge the result of the ::ixia::connect call with the result of
				# the framework's connect call
				set ixiaConnect [Merge2Keylsets $ixiaConnect $ixiaHlapiConnect]
			}
		} else {
			set ixiaConnect $shouldConnectToIxNetwork
		}
	}
	
	# Update the command status message
	PostExecution "connect" $ixiaConnect $args
	
	# Return the result generated by the ::ixia::connect call. This will
	# contain essential information, such as port handles.
	return $ixiaConnect
}

# --------------------------------------------------------------------------- #
# Export the connect function												  #
# --------------------------------------------------------------------------- #
namespace eval ::ixiangpf {
	namespace export connect
}
