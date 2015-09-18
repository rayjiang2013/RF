package ixiangpf;


# Avoid "Smartmatch is experimental" warning in newer perl versions
no if $] >= 5.017011, warnings => 'experimental::smartmatch';


use tcl_utils;

use ixiahlt;
use XML::Simple;

# Define global variables for success and failure
our $SUCCESS = 1;
our $FAIL = 0;

# Define global variables for the IxNetwork connection and the session id
our $ixNet = undef;
our $sessionId = undef;

# Define global variables used to handle command responses
our $hlapiHashResultRef = undef;
our $checkIxiaResult = 0;

# --------------------------------------------------------------------------- #
# ---------------------------- runExecuteCommand ---------------------------- #
# --------------------------------------------------------------------------- #
# This method will call the specified high level API command using the		  #
# specified arguments on the currently opened session. The method will also	  #
# display any intermediate status messages that are available before the	  #
# command execution is finished.											  #
# --------------------------------------------------------------------------- #

sub runExecuteCommand ($@@@$) {

	my $commandName = shift(@_);
	my $notImplementedParams = shift(@_);
	my $mandatoryParams = shift(@_);
	my $fileParams = shift(@_);
	my $argsHashRef = shift(@_);

	# Create the legacy command name in case we need it
	my $legacyCommandName = "ixiahlt::" . $commandName;

	# Clear the results of the previous command
	$ixiangpf::checkIxiaResult = 0;
	$hlapiHashResultRef = undef;

	# Declare the result vars
	my $ixiaResult = undef;
	my $ixiangpfResult = undef;
	my $commandResult = undef;

	# Extract the arguments that are not implemented by the ixiangpf namespace
	my $notImplementedArgs = ExtractSpecifiedArguments($notImplementedParams, $argsHashRef);

	# Extract the mandatory arguments
	my $mandatoryArgs = ExtractSpecifiedArguments($mandatoryParams, $argsHashRef);
	
	# Extract the file arguments, process them and update the initial arguments
	my $fileArgs = ExtractSpecifiedArguments($fileParams, $argsHashRef);
	my $processedFileArgs = ProcessFileArgsFromList($ixiangpf::ixNet, $fileArgs);
	my $processedArgs = ReplaceWithLocalFileNames($argsHashRef, $processedFileArgs);

	if (defined($notImplementedArgs) && keys(%$notImplementedArgs) && defined($mandatoryArgs) && keys(%$mandatoryArgs) ) {

		# If we have parameters that are implemented only by the ixiahlt
		# namespace call the legacy method
		$ixiaResult = &$legacyCommandName($notImplementedArgs);
		$ixiangpf::checkIxiaResult = 1;

		# Use an ixiahlt call to get the actual status of the command
		if (ixiahlt::status_item('status') != $ixiangpf::SUCCESS) {
			# Return immediately if the ixiahlt call failed
			return $ixiaResult
		}

		# Set the command's result to the legacy result
		$commandResult = $ixiaResult;
	}

	# Create the command node under the current session
	my $commandNode = $ixiangpf::ixNet->add($sessionId, $commandName);
	my $ixNetCommitResult = CommitChangesAndHandlePublisherErrors($ixiangpf::ixNet);
	if ($ixNetCommitResult == $ixiangpf::FAIL) {
		return $ixiangpf::FAIL;
	}
	
	# Populate the command's arguments
	my $argsToValidate = GetArgsToValidate($processedArgs);
	$newArgs = {
		'args_to_validate'	=>	$argsToValidate,
	};
	my $commandArgs = MergeHashes($processedArgs, $newArgs);
	
	my $setParamsResult = SetCommandParameters($ixiangpf::ixNet, $commandNode, $commandArgs);
	if ($setParamsResult == $ixiangpf::FAIL) {
		return $ixiangpf::FAIL;
	}

	# Call the ixiangpf function
	$ixiangpf::ixNet->execute('executeCommand', $commandNode);

	# Call runGetSessionStatus to block until the command's execution completes
	$ixiangpfResult = runGetSessionStatus();

	# Check the result to see if the execution needs to be forwarded
	# to the ixiahlt implementation
	if ($ixiangpf::hlapiHashResultRef->{'command_handled'} == $ixiangpf::FAIL) {

		# Delete the framework's response and call the ixiahlt implementation
		$ixiaResult = &$legacyCommandName($argsHashRef);
		$ixiangpf::checkIxiaResult = 1;
		$ixiangpf::hlapiHashResultRef = undef;

		# Use an ixiahlt call to get the actual status of the command
		if (ixiahlt::status_item('status') != $ixiangpf::SUCCESS) {
			# Return immediately if the ixiahlt call failed
			return $ixiaResult
		}

		# Set the command's result to the legacy result
		$commandResult = $ixiaResult;

	} else {

		# Just remove the command_handled key
		delete ($ixiangpf::hlapiHashResultRef->{'command_handled'});

		# Set the command's result to the framework result
		$commandResult = $ixiangpfResult;
	}

	return $ixiangpfResult;
}


# --------------------------------------------------------------------------- #
# --------------------------- runGetSessionStatus --------------------------- #
# --------------------------------------------------------------------------- #
# This method blocks the client until the execution of the current command on #
# the opened session is completed. 											  #
# Notes:																	  #
# 	1.	The method will display any intermediate status messages that are	  #
#		available, including the command's final status.					  #
#	2.	The method returns the status of the command currently executing	  #
#		command	and updates the hash that stores the result returned by the	  #
#		last framework command.												  #
# --------------------------------------------------------------------------- #

sub runGetSessionStatus() {

	if (defined($ixiangpf::ixNet) && defined($ixiangpf::sessionId)) {

		my $xmlParser = new XML::Simple();
		while (1) {

			# Block until a command response is available
			my $sessionStatus = $ixiangpf::ixNet->execute('GetSessionStatus', $ixiangpf::sessionId);

			# Decode the XML string into a hash
			my $rawHashRef = $xmlParser->XMLin($sessionStatus);

			# Flatten the resulting hash to eliminate redundant keys
			my $decodedHashRef = ProcessHash($rawHashRef);
			FlattenDoubleKeys($decodedHashRef);
		
			if ($decodedHashRef->{'status'} == $ixiangpf::SUCCESS) {

				# Print any status messages that are found
				if (exists($decodedHashRef->{'messages'}) && defined($decodedHashRef->{'messages'})) {

					my $messageHashRef = $decodedHashRef->{'messages'};
					while (my ($key, $value) = each(%$messageHashRef) ) {
						print "$value\n";
					}
				}

				# Check if the command's result is available
				if (exists($decodedHashRef->{'result'}) && defined($decodedHashRef->{'result'})) {

					# Update the hash that stores the framework's result
					$ixiangpf::hlapiHashResultRef = $decodedHashRef->{'result'};

					# Return the status of the command
					return $ixiangpf::hlapiHashResultRef->{'status'};
				}

			} else {

				# Return the FAIL result immediately
				$ixiangpf::hlapiHashResultRef = $decodedHashRef;
				return $ixiangpf::FAIL;
			}
		}
	}
}


# --------------------------------------------------------------------------- #
# ------------------------------- ProcessHash ------------------------------- #
# --------------------------------------------------------------------------- #
# This method flattens the input hash by removing all the keys named *key* or #
# *value* from it and shifting the corresponding value to the parent key.	  #
# --------------------------------------------------------------------------- #

sub ProcessHash(%$) {

	my $hashRef = shift(@_);
	my $parentKey = shift(@_);

	my $processedHashRef = {};

	if (defined($hashRef) && keys(%$hashRef) > 0) {
		while( my ($key, $value) = each %$hashRef ) {

			my $processedValue = {};
			if (defined($value)) {

				# Check what type of value we have
				my $valueType = ref($value);

				if ($valueType eq 'HASH') {

					# The current value is a HASH
					# Recursively process the child hash
					$processedValue = ProcessHash($value, $key);

					my $hashSize = scalar(keys(%$processedValue));
					if ($hashSize == 1) {

						# The processed hash has a single key
						# Check what type of value it has
						my $processedValueType = ref($processedValue->{$key});
						if ($processedValueType eq 'HASH') {

							# See if the hash is misprocessed key-name pair
							my $statusHashRef = $processedValue->{$key};
							my @statusHashKeys = keys(%$statusHashRef);
							if ('name' ~~ @statusHashKeys && 'key' ~~ @statusHashKeys) {
								$processedValue = {};
								$processedValue->{$statusHashRef->{'name'}} = $statusHashRef->{'key'};
							}

						} else {

							# The value is a scalar. Flatten it.
							if (defined($processedValue->{$key})) {
								$processedValue = $processedValue->{$key};
							} elsif (defined($processedValue->{$parentKey})) {
								$processedValue = $processedValue->{$parentKey};
							}
						}
					}
				}
				unless ($valueType) {

					# The current value is a scalar.
					$processedValue = $value;
				}
			}

			if (($key eq 'value') || ($key eq 'key')) {
				if (defined($parentKey) && ($parentKey ne 'value')) {
					$processedHashRef->{$parentKey} = $processedValue;
				} else {
					$processedHashRef = $processedValue;
				}
			} else {
				$processedHashRef->{$key} = $processedValue;
			}
		}
	}

	return $processedHashRef

}


# --------------------------------------------------------------------------- #
# ---------------------------- FlattenDoubleKeys ---------------------------- #
# --------------------------------------------------------------------------- #
# This method removes doubled keys from the specified hash by shifting the	  #
# corresponding value to the previous level.								  #
# Note:																		  #
#	The method will alter the hash whose reference is passed as an input	  #
#	argument directly.														  #
# --------------------------------------------------------------------------- #

sub FlattenDoubleKeys(%) {

	my $hashRef = shift(@_);

	while (my ($key, $value) = each(%$hashRef)) {

		if (defined($value)) {

			# Check if we have a hash value
			my $valueType = ref($value);
			if ($valueType eq 'HASH') {

				# First flatten the child hash
				FlattenDoubleKeys($value);

				# Now check for doubled keys
				my @childKeys = keys(%$value);
				if ($key ~~ @childKeys) {

					# Deduplicate the key by shifting its value to the parent
					$hashRef->{$key} = $value->{$key};
				}
			}
		}
	}
}


# --------------------------------------------------------------------------- #
# ------------------------------- status_item ------------------------------- #
# --------------------------------------------------------------------------- #
# This method returns the value associated with the specified key in the	  #
# response of the last API command.											  #
#																			  #
# Note:																		  #
#	1.	The returned value is TCL formatted in order to preserve the legacy	  #
#		HLP API behavior.													  #
#	2.	If the key is found in both the framework and the legacy results, the #
#		resulting value will contain both results.							  #
# --------------------------------------------------------------------------- #

sub status_item($) {

	my $keyToLookup = shift(@_);

	my $ngpfResult = undef;
	my $ixiahltResult = undef;

	if (defined($keyToLookup)) {

		my @keyList = ();
		if (defined($ixiangpf::hlapiHashResultRef)) {

			@keyList = split(/\./, $keyToLookup);
			$ngpfResult = GetStatusItem($ixiangpf::hlapiHashResultRef, \@keyList);
			
			# Remove the enclosing curly brackets to preserve
			# compatibility with ixiahlt formatting
			my $openBrackerCount = ($ngpfResult =~ tr/{//);
			if ((index($ngpfResult, "{") == 0) && ($openBrackerCount == 1)) {
				$ngpfResult = substr($ngpfResult, 1, -1, '');
			}
		}
		if ($ixiangpf::checkIxiaResult) {

			my @ixiahltKeys = ixiahlt::status_item_keys();
			@keyList = split(/\./, $keyToLookup);
			if ($keyList[0] ~~ @ixiahltKeys) {
				$ixiahltResult = ixiahlt::status_item($keyToLookup);
			}
		}
	}

	# If the key was not found in either result, return an empty string
	if (!defined($ngpfResult) && !defined($ixiahltResult)) {
		return "";
	}

	# If one of the variables is undefined, simply return the other one
	if (!defined($ixiahltResult)) {
		return $ngpfResult;
	}
	if (!defined($ngpfResult)) {
		return $ixiahltResult;
	}

	# The key was found in both results. Merge the values!
	if ($keyToLookup eq 'status') {

		# Return success only if both statuses indicate success
		if ($ == $ixiangpf::SUCCESS && $ixiahltResult == $ixiangpf::SUCCESS) {
			return $ixiangpf::SUCCESS;
		} else {
			return $ixiangpf::FAIL;
		}
	} else {

		return "$ngpfResult $ixiahltResult";
	}
}


# --------------------------------------------------------------------------- #
# ----------------------------- status_item_keys ---------------------------- #
# --------------------------------------------------------------------------- #
# This method returns an array that contains the list of keys that are		  #
# available for the last API command.										  #
# --------------------------------------------------------------------------- #

sub status_item_keys() {

	my @hlapiKeys = ();
	my @ixiahltKeys = ();

	if (defined($ixiangpf::hlapiHashResultRef)) {
		@hlapiKeys = keys(%$ixiangpf::hlapiHashResultRef);
	}
	if ($ixiangpf::checkIxiaResult) {
		@ixiahltKeys = ixiahlt::status_item_keys();
	}

	# Merge the local keys with the ones from ixiahlt
	return MergeArrays(\@hlapiKeys,\@ixiahltKeys);
}


# --------------------------------------------------------------------------- #
# ----------------------------- get_result_hash ----------------------------- #
# --------------------------------------------------------------------------- #
# This method returns a hash reference that contains the entire response of	  #
# the last API command.														  #
#																			  #
# Note:																		  #
#	1.	The returned hash only contains the data that was returned by the	  #
#		HLAPI framework.													  #
# --------------------------------------------------------------------------- #

sub get_result_hash() {

	return $ixiangpf::hlapiHashResultRef;
}


# --------------------------------------------------------------------------- #
# ------------------------------ GetPortMapping ----------------------------- #
# --------------------------------------------------------------------------- #
# This method returns a mapping of HLT port handles to actual port object	  #
# references that can be used by the HLAPI framework.						  #
# --------------------------------------------------------------------------- #

sub GetPortMapping() {
	my $tclPortMapping = ixiangpf_utils::GetPortMapping();
	my $portMapping = substr($tclPortMapping, 1, -1, '');
	return $portMapping;
}


# --------------------------------------------------------------------------- #
# --------------------------- RequiresHlapiConnect -------------------------- #
# --------------------------------------------------------------------------- #
# This method returns one of the following values:							  #
#	0	- do not connect to IxNetwork										  #
#	1	- conect to IxNetwork												  #
# --------------------------------------------------------------------------- #

sub RequiresHlapiConnect($) {

	my $connectArgs = shift(@_);
	my $connectRequiredByHLTSET = ixiangpf_utils::RequiresHlapiConnect();
	my $connectPossibleWithArgs = GetIxNetworkServerAndPort($connectArgs);

	if (defined($connectPossibleWithArgs->{'hostname'}) && $connectRequiredByHLTSET != 0) {
		return 1;
	} else {
		return 0;
	}
}


# --------------------------------------------------------------------------- #
# ------------------------------ GetHostName -------------------------------- #
# --------------------------------------------------------------------------- #
# This method returns the hostname of the client machine or a predefined	  #
# string if the username cannot be determined.								  #
# --------------------------------------------------------------------------- #

sub GetHostName() {
	use Sys::Hostname;

	my $hostname = hostname();
	if (length($hostname) == 0) {
		return "UNKNOWN MACHINE";
	}
	return $hostname;
}


# --------------------------------------------------------------------------- #
# ------------------------------- GetUserName ------------------------------- #
# --------------------------------------------------------------------------- #
# This method returns the username of the current user on the client		  #
# machine or a predefined string if the username cannot be determined.		  #
# --------------------------------------------------------------------------- #

sub GetUserName() {
	my $username = getlogin();

	if (length($username) == 0) {
		return "UNKNOWN HLAPI USER";
	}
	return $username;
}


# --------------------------------------------------------------------------- #
# -------------------------- TrimLeadingWhitespace -------------------------- #
# --------------------------------------------------------------------------- #
# This method removes any whitespace characters from the start of the input	  #
# string and returns the trimmed value.										  #
# --------------------------------------------------------------------------- #

sub TrimLeadingWhitespace($) {

	my $string = shift(@_);

	# Remove leading spaces
	$string =~ s/^\s+//;
	return $string;
}


# --------------------------------------------------------------------------- #
# -------------------------- TrimTrailingWhitespace ------------------------- #
# --------------------------------------------------------------------------- #
# This method removes any whitespace characters from the end of the input	  #
# string and returns the trimmed value.										  #
# --------------------------------------------------------------------------- #

sub TrimTrailingWhitespace($) {

    my $string = shift(@_);

	# Remove trailing spaces
    $string =~ s/\s+$//;
    return $string;
}


# --------------------------------------------------------------------------- #
# ------------------------ GetIxNetworkServerAndPort ------------------------ #
# --------------------------------------------------------------------------- #
# This method parses the input arguments and looks for a key called			  #
# ixnetwork_tcl_server. If the key is found, the value of the key is parsed	  #
# in order to separate the hostname and port.								  #
# The parsed information is returned in a hash. Keys that do not contain any  #
# information will be added to the array but will have undefined values.	  #
# --------------------------------------------------------------------------- #

sub GetIxNetworkServerAndPort($) {
	my $ixNetServerData = {
		'hostname'	=> undef,
		'port'		=> 8009,
	};

	my $inputHashRef = shift(@_);
	if (defined($inputHashRef) && exists($inputHashRef->{'ixnetwork_tcl_server'}) && defined($inputHashRef->{'ixnetwork_tcl_server'})) {

		my @splitConnectData = split(/:/, $inputHashRef->{'ixnetwork_tcl_server'});
		if (exists($splitConnectData[0]) && defined($splitConnectData[0])) {
			$ixNetServerData->{'hostname'} = $splitConnectData[0];
		}
		if (exists($splitConnectData[1]) && defined($splitConnectData[1])) {
			$ixNetServerData->{'port'} = $splitConnectData[1];
		}
	}

	return $ixNetServerData;
}


# --------------------------------------------------------------------------- #
# --------------------------- SetCommandParameters -------------------------- #
# --------------------------------------------------------------------------- #
# This method requires the following imput parameters:						  #
#	1. 	An IxNetwork connection object.										  #
#	2. 	A valid SdmId for an existing command.								  #
#	3. 	A hash reference whose keys represent attribute names and whose		  #
#		values represent the corresponding attribute values.				  #
# The method uses the specified ixnetwork connection to set the attributes of #
# the specified command and commits the changes at the end of the call.		  #
# --------------------------------------------------------------------------- #

sub SetCommandParameters($$$) {
	my $ixNetConnection = shift(@_);
	my $commandId = shift(@_);
	my $attributeHashRef = shift(@_);

	while( my ($attrName, $attrValue) = each %$attributeHashRef ) {
		$attrNameArgument = "-$attrName";
		$ixNetConnection->setAttribute($commandId, $attrNameArgument, $attrValue);
	}
	
	return CommitChangesAndHandlePublisherErrors($ixNetConnection);
}


# --------------------------------------------------------------------------- #
# ------------------ CommitChangesAndHandlePublisherErrors ------------------ #
# --------------------------------------------------------------------------- #
# This method performs a commit and catches any exceptions that are thrown by #
# publishers. 																  #
# If commit errors are found, the ixiangpf result hash will be	updated to	  #
# indicate that the command has failed and what the error was.				  #
# The method returns $ixiangpf::FAIL if any commit errors were detected.	  #
# --------------------------------------------------------------------------- #

sub CommitChangesAndHandlePublisherErrors($) {
	my $ixNetConnection = shift(@_);
	
	eval {
		$ixNetConnection->commit();
	};
    if ($@) {
		my $ixNetCommitError = $@;
		$ixiangpf::hlapiHashResultRef = {
			'status'	=> 	$ixiangpf::FAIL,
			'log'		=>	$ixNetCommitError,
		};
		return $ixiangpf::FAIL;
	};
	return $ixiangpf::SUCCESS;	
}


# --------------------------------------------------------------------------- #
# ---------------------------- GetArgsToValidate ---------------------------- #
# --------------------------------------------------------------------------- #
# This method accepts the following input parameter:						  #
#	1. 	A hash reference whose keys represent attribute names and whose		  #
#		values represent the corresponding attribute values.				  #
# The method parses the references hash and create a string that can be		  #
# passed to the HLAPI in order to validate the corresponding arguments.		  #
# --------------------------------------------------------------------------- #

sub GetArgsToValidate($) {

	my $argsHashRef = shift(@_);
	my $argsToValidateString = undef;

	while( my ($argName, $argValue) = each %$argsHashRef ) {

		if (defined($argName) && defined($argValue)) {
			# Append the argument name and value in the correct format
			if (index($argValue, " ") != -1) {
				$argsToValidateString .= "-$argName \"$argValue\" ";
			} else {
				$argsToValidateString .= "-$argName $argValue ";
			}
		}
	}

	if (defined($argsToValidateString)) {
		$argsToValidateString = TrimTrailingWhitespace($argsToValidateString);
	}

	return $argsToValidateString;
}


# --------------------------------------------------------------------------- #
# ------------------------ ExtractSpecifiedArguments ------------------------ #
# --------------------------------------------------------------------------- #
# This method accepts an array and a hash reference as input. The method	  #
# iterates through the elements of the array and searches the hash for keys	  #
# that have the same name. All the entries that are found are copies to a new #
# hash.								 										  #
# The method return a reference to a hash that will contain only keys that	  #
# were specified in the input array and their corresponding values.			  #
# --------------------------------------------------------------------------- #

sub ExtractSpecifiedArguments(@$) {

	my $argumentsToExtract = shift(@_);
	my $inputsArgsHashRef = shift(@_);

	# Create a new hash reference to an empty hash
	my $outputHashRef = {};

	if (!IsEmptyArray(\@$argumentsToExtract)) {
		foreach (@$argumentsToExtract)
		{
			if (exists($inputsArgsHashRef->{$_})) {
				$outputHashRef->{$_} = $inputsArgsHashRef->{$_};
			}
		}
	}

	return $outputHashRef;
}


# --------------------------------------------------------------------------- #
# ------------------------- ProcessFileArgsFromList ------------------------- #
# --------------------------------------------------------------------------- #
# This method takes the fileArgs hash reference and copies all files to the	  #
# IxNetwork	server. The original file names are then replaced with the new	  #
# locations from the server.												  #
# --------------------------------------------------------------------------- #

sub ProcessFileArgsFromList($$) {

	my $ixNetConnection = shift(@_);
	my $fileArgs = shift(@_);
	my $fileIndex = 0;
	
	# Create a new hash reference to an empty hash
	my $outputHashRef = {};
	while( my ($argName, $argValue) = each %$fileArgs ) {

		if (defined($argName) && defined($argValue)) {
			# Process the new file names
			my $clientFile = $argValue;
			my $serverFile = "perlServerFile$fileIndex";
			$fileIndex++;
			
			# Copy the local file to the IxNetwork server
			my $ixNetCopyError = undef;
			eval {
				my $clientStream = $ixNetConnection->readFrom($clientFile);
				my $serverStream = $ixNetConnection->writeTo($serverFile, '-ixNetRelative', '-overwrite');			
				$ixNetConnection->execute('copyFile', $clientStream, $serverStream);
			};
			if ($@) {
				$ixNetCopyError = $@;
				print("Copy error: $ixNetCopyError");
			}
			
			# Append the argument name and value in the correct format
			if (!defined($ixNetCopyError)) {
				$outputHashRef->{$argName} = $serverFile;
			}
		}
	}

	return $outputHashRef;
}


# --------------------------------------------------------------------------- #
# ------------------------ ReplaceWithLocalFileNames ------------------------ #
# --------------------------------------------------------------------------- #
# This method takes the full argument hash ref and the processed fileArgs 	  #
# hash ref and replaces the original file names with the ones which were made # 
# available on the IxNetwork server.										  #
# --------------------------------------------------------------------------- #

sub ReplaceWithLocalFileNames ($$) {

	my $fullArgs = shift(@_);
	my $processedFileArgs = shift(@_);

	# There are no processed file arguments so there's nothing to be done
	if (scalar(keys(%$processedFileArgs)) == 0) {
		return $fullArgs;
	}
	
	# Create a new hash reference to an empty hash
	my $outputHashRef = {};
	
	while( my ($argName, $argValue) = each %$fullArgs ) {
		
		my $processedValue = $argValue;
		if (defined($argName) && defined($argValue)) {
			if (exists($processedFileArgs->{$argName})) {
				$processedValue = $processedFileArgs->{$argName};
			}
		}
		$outputHashRef->{$argName} = $processedValue;
	}

	return $outputHashRef;
}


# --------------------------------------------------------------------------- #
# ------------------------------- IsEmptyArray ------------------------------ #
# --------------------------------------------------------------------------- #
# This method accepts an array as input and returns 1 if the array exists and #
# contains at least one element or 0 otherwise.								  #
# --------------------------------------------------------------------------- #

sub IsEmptyArray(@) {
	my $list = shift(@_);
	my $listLength = @$list;
	if (defined(@$list[0]) && $listLength > 0) {
		return 0;
	}
	return 1;
}


# --------------------------------------------------------------------------- #
# ------------------------------- MergeHashes ------------------------------- #
# --------------------------------------------------------------------------- #
# This method accepts a list hash references as input and returns a new hash  #
# that contains the merger of the input hashes.								  #
# --------------------------------------------------------------------------- #

sub MergeHashes {

	my $mergedHash = {};
	my $continueToNextParameter = 1;

	while ($continueToNextParameter) {

		my $currentHashRef = shift(@_);
		if (defined($currentHashRef)) {
			while( my ($key, $value) = each %$currentHashRef) {

				if (exists($mergedHash->{$key}) && defined($mergedHash->{$key})) {
					# TODO: Deal with concatenation for various types later
					$mergedHash->{$key} = $value;
				} else {
					$mergedHash->{$key} = $value;
				}
			}
		} else {
			$continueToNextParameter = 0;
		}
	}
	return $mergedHash;
}


# --------------------------------------------------------------------------- #
# ------------------------------- MergeArrays ------------------------------- #
# --------------------------------------------------------------------------- #
# This method accepts a list array references as input and returns a new	  #
# array that contains the merger of the input lists. 						  #
# Duplicate entries will only be added to the resulting array once.			  #
# --------------------------------------------------------------------------- #

sub MergeArrays {

	my @mergedArray = ();
	my $continueToNextParameter = 1;

	while ($continueToNextParameter) {

		my $currentRef = shift(@_);
		if (defined($currentRef)) {
			foreach(@$currentRef) {

				# Only add the new value if it's not already present
				if (!($_ ~~ @mergedArray)) {
					push(@mergedArray, $_);
				}
			}
		} else {
			$continueToNextParameter = 0;
		}
	}
	return @mergedArray;
}


# --------------------------------------------------------------------------- #
# -------------------------- FormatValueAsTclString ------------------------- #
# --------------------------------------------------------------------------- #
# This method accepts a single scalar or reference as input and returns a	  #
# string  that contains an HLPAPI-compatible formatting of the input value.	  #
#																			  #
# Note:																		  #
#	1.	This method is primarily used to provide consistent formatting of	  #
#		results retrieved from the new framework and the old HLPAPI			  #
#		implementation.														  #
# --------------------------------------------------------------------------- #

sub FormatValueAsTclString($) {

	my $value = shift(@_);
	my $formattedValue = "";

	if (defined($value)) {

		# First determine what type of value we have
		my $valueType = ref($value);
		my $formattedCurrentValue = undef;

		if ($valueType eq 'HASH') {

			# The value is a hash reference
			while( my($currentKey, $currentValue) = each %$value) {
				$formattedCurrentValue = FormatValueAsTclString($currentValue);
				$formattedValue .= "{ $currentKey $formattedCurrentValue} ";
			}
		}
		elsif ($valueType eq 'ARRAY') {

			# The value is an array reference
			$formattedValue .= "{";
			foreach(@$value) {
				$formattedCurrentValue = FormatValueAsTclString($_);
				$formattedValue .= "$formattedCurrentValue ";
			}
			$formattedValue = TrimTrailingWhitespace($formattedValue);
			$formattedValue .= "} ";
		}
		unless ($valueType) {

			# The value is a scalar
			if (index($value, ' ') > 0) {
				$formattedValue = "{$value}";
			} else {
				$formattedValue = $value;
			}
		}

	} else {
		$formattedValue = undef;
	}

	return TrimTrailingWhitespace($formattedValue);
}


# --------------------------------------------------------------------------- #
# ------------------------------ GetStatusItem ------------------------------ #
# --------------------------------------------------------------------------- #
# This method accepts a hash reference and an array reference as input and	  #
# returns the equivalent of running a TCL keylget command on the specified	  #
# hash reference using the specified list of successive keys.				  #
#																			  #
# Note:																		  #
#	1.	This method is primarily used to provide consistent formatting of	  #
#		results retrieved from the new framework and the old HLPAPI			  #
#		implementation.														  #
# --------------------------------------------------------------------------- #

sub GetStatusItem(%@) {

	my $hashRef = shift(@_);
	my $keys = shift(@_);

	my $numKeys = @$keys;
	if ($numKeys == 1) {

		# We have the final key piece and I can return the value
		my $finalKey = @$keys[0];
		return FormatValueAsTclString($hashRef->{$finalKey});

	} else {

		# We have an intermediate key. We need to:
		#	- get the hash reference that it corresponds to
		#	- remove the first entry from the list of keys
		#	- call GetStatusItem for the new hash reference and list of keys

		my $currentKey = shift(@$keys);
		my $nextHashRef = $hashRef->{$currentKey};

		return GetStatusItem($nextHashRef, $keys);
	}
}


# --------------------------------------------------------------------------- #
# -------------------------------- PrintHash -------------------------------- #
# --------------------------------------------------------------------------- #
# This method accepts a hash reference as input and prints it to the console. #
# Note:																		  #
#	An additional integer value can be specified and will be used to print	  #
#	the hash using the specified number of tabs. If no tab count is specified #
#	the value will be initialized to 0.										  #
# --------------------------------------------------------------------------- #

sub PrintHash {

	my $hashRef = shift(@_);
	my $tabCount = shift(@_);

	if (!defined($tabCount)) {
		$tabCount = 1;
	} else {
		$tabCount++;
	}

	if (defined($hashRef) && keys(%$hashRef) > 0) {
		while( my ($key, $value) = each %$hashRef ) {

			for (1..($tabCount-1)) {
				print "  ";
			}

			if (defined($value)) {

				# Check what type of value we have
				my $valueType = ref($value);
				if ($valueType eq 'HASH') {
					print "$key =>\n";

					PrintHash($value, $tabCount);
				}
				unless ($valueType) {
					print "$key => $value\n";
				}
			} else {
				print "$key => undef\n";
			}
		}
	} else {
		print "The specified hash was empty or undefined!\n";
	}

	$tabCount--;
}

# Return value for the package
return 1;