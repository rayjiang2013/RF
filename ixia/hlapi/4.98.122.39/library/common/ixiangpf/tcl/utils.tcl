# --------------------------------------------------------------------------- #
# ---------------------------- runExecuteCommand ---------------------------- #
# --------------------------------------------------------------------------- #
# This method will call the specified high level API command using the		  #
# specified arguments on the currently opened session. The method will also	  #
# display any intermediate status messages that are available before the	  #
# command execution is finished.											  #
# --------------------------------------------------------------------------- #

proc runExecuteCommand { command notImplementedParams mandatoryParams fileParams args } {

    if {![info exist ::ixiangpf::sessionId]} {
        keylset errorResult status 0
        keylset errorResult log "No session id is available. Please make sure you connected to an IxNetwork TCL server during the connect call."
        return $errorResult
    }
	
	# Extract the arguments that are not implemented by the ixiangpf namespace
	set notImplementedArgs [ExtractParamsFromList $args $notImplementedParams]
	
	# Extract the mandatory arguments
	set mandatoryArgs [ExtractParamsFromList $args $mandatoryParams]

	# Extract and process the file arguments
	set fileArgs [ExtractParamsFromList $args $fileParams]
	set processedFileArgs [ProcessFileArgsFromList $fileArgs]

	# Replace the argument values in the main list and ensure args are escaped
	set processedArgs [ReplaceWithLocalFileNames $args $processedFileArgs]		
	
	if {$notImplementedArgs != "" && $mandatoryArgs != ""} {
		# If we have parameters that are implemented only by the ixia namespace call the ixia namespace method
		set ixiaResult [eval ::ixia::$command $notImplementedArgs]

		# If the call failed return the result of the ixia call
		if {[keylget ixiaResult status] != $::SUCCESS} {
			return $ixiaResult
		}
	}
	
	# Create the command node under the current session and populate its attributes with the parameter values
	set commandNode [eval ixNet add $::ixiangpf::sessionId $command $processedArgs -args_to_validate {$args}]

	# Catch any commit errors are report them in the keyed list format
	if { [catch {ixNet commit} ixNetError] } {
		keylset errorResult status 0
		keylset errorResult log $ixNetError
		return $errorResult
	}
	set commandNode [ixNet remapIds $commandNode]

	# Call the ixiangpf function
	ixNet exec executeCommand "$commandNode"

	# Call runGetSessionStatus to block th execution until the function completes
	set ixiaHlapiConnect [runGetSessionStatus]

	# Forward the execution to the ixia implementation if needed
	set commandHandled [keylget ixiaHlapiConnect command_handled]
	keyldel ixiaHlapiConnect command_handled
	if {$commandHandled == 0} {
		set ixiaHlapiConnect [eval ::ixia::$command $args]
	}

	PostExecution $command $ixiaHlapiConnect $args

	return $ixiaHlapiConnect
}


# --------------------------------------------------------------------------- #
# -------------------------- runGetSessionStatus ---------------------------- #
# --------------------------------------------------------------------------- #
# This method blocks the client until the execution of the current command on #
# the opened session is completed. 											  #
#																			  #
# Notes:																	  #
# 	1.	The method will display any intermediate status messages that are	  #
#		available before the command execution is finished.					  #
#	2.	The method returns the execution command result						  #
# --------------------------------------------------------------------------- #

proc runGetSessionStatus {} {

    if {![info exist ::ixiangpf::sessionId]} {
        keylset errorResult status 0
        keylset errorResult log "No session id is available. Please make sure you connected to an IxNetwork TCL server during the connect call."
        return $errorResult
    }
	
	while {1} {

		# Call the GetSessionStatus exec
		set rez [StripIxNetResultDecoration [ixNet exec GetSessionStatus "$::ixiangpf::sessionId"]]

		if { [keylget rez status] == $::SUCCESS } {

			if { [KeyExists $rez messages] } {
				set messages [keylget rez messages]
				set messageKeys [keylkeys messages]

				foreach message $messageKeys {
					puts [keylget messages $message]
				}
			}

			if { [KeyExists $rez result] } {
				return [keylget rez result]
			}

		} else {
			return $rez
		}
	}
}


# --------------------------------------------------------------------------- #
# ------------------------------- KeyExists --------------------------------- #
# --------------------------------------------------------------------------- #
# This method checks if the specified keyed list contains keyName.			  #
# --------------------------------------------------------------------------- #

proc KeyExists {varName keyName} {
	set ret 0

	catch {
		keylget varName $keyName
		set ret 1
	}

	return $ret
}


# --------------------------------------------------------------------------- #
# ------------------------ StripIxNetResultDecoration ----------------------- #
# --------------------------------------------------------------------------- #
# This method will process the string returned by the ixNet server and strip  #
# the decoration added to the actual response.								  #
# --------------------------------------------------------------------------- #

proc StripIxNetResultDecoration { result } {
	set successPattern "::ixNet::OK-\{kString,"
	set undecoratedResult [regsub $successPattern $result ""]
	set length [string length $undecoratedResult]
	return [string replace $undecoratedResult [expr $length - 1] $length ""]
}


# --------------------------------------------------------------------------- #
# -------------------------- ExtractParamsFromList -------------------------- #
# --------------------------------------------------------------------------- #
# This method takes the fullArgs list, parses it and extracts the parameter	  #
# names and values that are specified in the argNamesToExtract array. The	  #
# resulting list is returned as the procedure's result.						  #
#																			  #
# Note:																		  #
#	- The call works correctly with flag arguments which have no value		  #
# --------------------------------------------------------------------------- #

proc ExtractParamsFromList { fullArgs argNamesToExtract } {

	set extractedArgs ""
	set foundArgument 0

	# Add an empty char at end of argument list
	set argNamesToExtract "$argNamesToExtract "
	foreach arg $fullArgs {

		if {[string first "-" $arg] == 0} {
			
			if {$foundArgument} {
				# Add a dummy value for flag arguments
				lappend extractedArgs ""
			}
			set foundArgument 0
			if {[string first $arg $argNamesToExtract] >= 0 } {
				lappend extractedArgs $arg
				set foundArgument 1
			}
		} else {
			if {$foundArgument} {
				lappend extractedArgs $arg
				set foundArgument 0
			}
		}
	}
	
	if {$foundArgument} {
		# Add a dummy value for the final flag argument
		lappend extractedArgs ""
		set foundArgument 0
	}
	
	return $extractedArgs
}

# --------------------------------------------------------------------------- #
# ------------------------- ProcessFileArgsFromList ------------------------- #
# --------------------------------------------------------------------------- #
# This method takes the fileArgs list and copies all files to the IxNetwork	  #
# server machine. The original file names are then replaced with the new	  #
# locations from the server.												  #
# --------------------------------------------------------------------------- #

proc ProcessFileArgsFromList { fileArgs } {

	set processedArgs ""
	set currentArgName ""
	set fileIndex 0
	foreach arg $fileArgs {

		if {[string first "-" $arg] == 0} {		
			# This is the argument name
			set currentArgName $arg
		
		} else {		
			# This is the actual file

			set clientFile $arg
			
			# Generate a server file name
			set serverFile "tclServerFile$fileIndex"
			incr fileIndex
			
			# Copy it to the server
			set clientStream [ixNet readFrom $clientFile]
			set serverStream [ixNet writeTo $serverFile -ixNetRelative -overwrite]
			ixNet exec copyFile $clientStream $serverStream
			
			# Add the argument name and the name of the server file as a new key-value pair
			keylset processedArgs $currentArgName $serverFile
		}
	}

	return $processedArgs
}


# --------------------------------------------------------------------------- #
# ------------------------ ReplaceWithLocalFileNames ------------------------ #
# --------------------------------------------------------------------------- #
# This method takes the full argument list and the processed fileArgs keyed	  #
# list and replaces the original file names with the ones which were made	  # 
# available on the IxNetwork server.										  #
# --------------------------------------------------------------------------- #

proc ReplaceWithLocalFileNames { fullArgs processedFileArgs } {

	set processedArgs ""
	set foundProcessedFileArg 0
	set serverFile ""
	set foundArgument 0
	
	foreach arg $fullArgs {
		
		if {[string first "-" $arg] == 0} {
			
			if {$foundArgument} {
				# Add a dummy value for flag arguments
				lappend processedArgs ""
			}
			
			set foundArgument 1
			set foundProcessedFileArg 0
			lappend processedArgs $arg
			if {[keylget processedFileArgs $arg serverFile] == 1} {
				set foundProcessedFileArg 1
			}
		} else {
			set argValue $arg
			if {$foundProcessedFileArg == 1} {
				set argValue $serverFile
				set foundProcessedFileArg 0
			}
			lappend processedArgs $argValue
			set foundArgument 0
		}
	}
	if {$foundArgument} {
		# Add a dummy value for the final flag argument (if any)
		lappend processedArgs ""
		set foundArgument 0
	}	

	return $processedArgs
}


# --------------------------------------------------------------------------- #
# ------------------------------ GetPortMapping ----------------------------- #
# --------------------------------------------------------------------------- #
# This method creates a mapping of HLT port handles to actual port object	  #
# references that can be used by the HLAPI framework.						  #
# --------------------------------------------------------------------------- #

proc GetPortMapping { } {

	set portMapping ""

	# Get the vports directly from the interal HLT API
	set portHandles [array names ::ixia::ixnetwork_port_handles_array]

	foreach port $portHandles {
		# Get the port handle in the format that HLTAPI expects
		set vportData [::ixia::ixNetworkGetPortObjref $port]
		set vportObjref [keylget vportData vport_objref]

		# Add a new entry that maps the current port handle to the
		# corresponding vport object reference
		keylset portMapping $port $vportObjref
	}

	# Return all the mappings
	return "\{\"$portMapping\"\}"
}


# --------------------------------------------------------------------------- #
# ------------------------------- GetHostName ------------------------------- #
# --------------------------------------------------------------------------- #
# This method returns the hostname of the client machine.					  #
# --------------------------------------------------------------------------- #

proc GetHostName {} {
	return [info hostname]
}


# --------------------------------------------------------------------------- #
# ------------------------------- GetUserName ------------------------------- #
# --------------------------------------------------------------------------- #
# This method returns the username of the current user on the client		  #
# machine or a predefined string if the username cannot be determined.		  #
# --------------------------------------------------------------------------- #

proc GetUserName {} {
	info globals env
	# Assume we have a Windows environment
	set username [lindex [array get ::env USERNAME] 1]
	if {$username == ""} {
		# Try with the most common Unix environment
		set username [lindex [array get ::env USER] 1]
	}
	if {$username == ""} {
		# Try with alternate Unix environment
		set username [lindex [array get ::env LOGNAME] 1]
	}
	if {$username == ""} {
		# Set a default value that is unlikely to conflict with any actual usernames
		set username "UNKNOWN HLAPI USER"
	}

	return $username
}


# --------------------------------------------------------------------------- #
# ------------------------------ Merge2Keylsets ----------------------------- #
# --------------------------------------------------------------------------- #
# This method takes 2 keyed lists and returns a new kweyed list which		  #
# contains their merged contents.								      		  #
# --------------------------------------------------------------------------- #

proc Merge2Keylsets {sourceList destinationList} {

	foreach hlapiKey [keylkeys destinationList] {
		if {[lsearch [keylkeys sourceList] $hlapiKey] < 0} {
			keylset sourceList $hlapiKey "[keylget destinationList $hlapiKey]"
		} else {
			# I already have this key.
			if { $hlapiKey == "status" } {
				# Set the status to failure and the update the error message
				if {[keylget destinationList status] != $::SUCCESS} {
					keylset sourceList status $::FAILURE
					keylset sourceList log [keylget destinationList log]
				}
			}
		}
	}

	return $sourceList
}


# --------------------------------------------------------------------------- #
# ------------------------------ PostExecution ------------------------------ #
# --------------------------------------------------------------------------- #
# This method is called at the end of each command's execution and it will	  #
# print the correct command message to the console and throw an exception if  #
# the command failed and it was being run inside a regression.				  #
#																			  #
# Note:																		  #
# 	-	Regression environments are identified by setting the global		  #
#		regression_running variable    		  								  #
# --------------------------------------------------------------------------- #

proc PostExecution {commandName resultKeylset args} {

	set commandStatus [keylget resultKeylset status]

	# If we're in a regression and we failed, throw an error
	global regression_running
	if [info exists regression_running] {
		if ($regression_running) {
			if {$commandStatus != $::SUCCESS} {
				error "$commandName with parameters: $args \n [keylget resultKeylset log]"
			}
		}
	}
}


# --------------------------------------------------------------------------- #
# ------------------------ HLTSETRequiresHlapiConnect ----------------------- #
# --------------------------------------------------------------------------- #
# This method will return a keyed list and can be used to determine if the	  #
# HLAPI framework connect needs to be called based on current HLTSET value	  #
#																			  #
# Note:																		  #
#	1.	The	mapping lists the possible use cases that can be encountered	  #
#		during connect as well as the expected outcome						  #
#	P		- IxOS + IxTclProtocols											  #
#	N		- IxNetwork + IxOS    							 				  #
#	NO		- IxNetwork only												  #
#	P2NO	- IxNetwork only if ixnetwork_tcl_server was specified     		  #
#	P2NO	- IxOS and IxTclProtocols without ixnetwork_tcl_server present	  #
#																			  #
# Possible return values for the require key are							  #
#	0 	- Do not connect to IxNetwork										  #
#	1	- Connect to IxNetwork												  #
#	-1	- Connect if the ixnetwork_tcl_server argument is present			  #
# --------------------------------------------------------------------------- #

proc HLTSETRequiresHlapiConnect { } {

    if {[info exists ::ixiaHltVersions($::ixia::hltsetUsed)]} {
		keylset returnList status $::SUCCESS
		set ixn_version [lindex $::ixiaHltVersions($::ixia::hltsetUsed) 3]

		if { [ StringEndsWidth $ixn_version "P2NO" ] } {
			set ixn [string range $ixn_version 0 [expr [string length $ixn_version] - 5]]

			# We should connect only if we can find "-ixnetwork_tcl_server" in the argument list
			keylset returnList require -1

		} elseif { [ StringEndsWidth $ixn_version "NO" ] } {
			set ixn [string range $ixn_version 0 [expr [string length $ixn_version] - 3]]

			keylset returnList require 1

		} elseif { [ StringEndsWidth $ixn_version "P" ] } {
			set ixn [string range $ixn_version 0 [expr [string length $ixn_version] - 2]]

			keylset returnList require 0

		} elseif { [ StringEndsWidth $ixn_version "N" ] } {
			set ixn [string range $ixn_version 0 [expr [string length $ixn_version] - 2]]

			keylset returnList require 1

		} else {
			keylset returnList status $::FAILURE
			keylset returnList log "Invalid ixn_version: $ixn_version"
		}

    } else {
		keylset returnList status $::FAILURE
		keylset returnList log "Canot find HLTSET: $::ixia::hltsetUsed"
	}

	if {[keylget returnList status] == $::SUCCESS} {
		if {$ixn == "7.0"} {
			keylset returnList require 0
		}
	}

	return $returnList
}


# --------------------------------------------------------------------------- #
# ----------------------------- StringEndsWidth ----------------------------- #
# --------------------------------------------------------------------------- #
# Returns 1 if the specified string end with the specified sequence and 0	  #
# otherwise.										 						  #
# --------------------------------------------------------------------------- #

proc StringEndsWidth { string ending } {
	set stringLength [string length $string]
	set endingLength [string length $ending]

	if { [string range $string [expr $stringLength - $endingLength] $stringLength] == $ending } {
		return 1
	} else {
		return 0
	}
}


# --------------------------------------------------------------------------- #
# ------------------------- RequiresTclHlapiConnect ------------------------- #
# --------------------------------------------------------------------------- #
# This method will return a keyed list and can be used to determine if the	  #
# HLAPI framework connect needs to be called based on current HLTSET value	  #
# and the input argument of the command.									  #
#																			  #
# Possible return values for the required key are							  #
#	0 	- Do not connect to IxNetwork										  #
#	1	- Connect to IxNetwork												  #
# --------------------------------------------------------------------------- #

proc RequiresTclHlapiConnect { args } {

	set tclHlapiConnectRequired [HLTSETRequiresHlapiConnect]
	if {[keylget tclHlapiConnectRequired status] == $::SUCCESS} {
		if {[keylget tclHlapiConnectRequired require] == -1} {

			# Check if the -ixnetwork_tcl_server argument was specified
			if {[string first "-ixnetwork_tcl_server" $args] >= 0} {
				keylset tclHlapiConnectRequired require 1

			} else {
				keylset tclHlapiConnectRequired require 0
			}
		}
	}

	return $tclHlapiConnectRequired
}


# --------------------------------------------------------------------------- #
# ------------------------- RequiresHlapiConnect ------------------------ #
# --------------------------------------------------------------------------- #
# This method will return an integer value and can be used to determine if	  #
# the HLAPI framework connect needs to be called based on current HLTSET 	  #
# value.																	  #
#																			  #
# Possible return values for the required key are							  #
#	0 	- Do not connect to IxNetwork										  #
#	1	- Connect to IxNetwork												  #
#	-1	- Connect if the ixnetwork_tcl_server argument is present			  #
# --------------------------------------------------------------------------- #

proc RequiresHlapiConnect {} {

	set perlHlapiConnectRequired [HLTSETRequiresHlapiConnect]
	if {[keylget perlHlapiConnectRequired status] == $::SUCCESS} {

		# Return the value that corresponds to the reqquired key
		return [keylget perlHlapiConnectRequired require]
	}
	return 0
}










