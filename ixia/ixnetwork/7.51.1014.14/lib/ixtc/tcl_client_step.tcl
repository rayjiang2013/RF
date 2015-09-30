namespace eval ix_tc {}

proc ix_tc::startSession {args} {
    if {![validateStartSessionArgs args]} {
        ix_tc::disconnect
        exit 1    
    }    
    array set arg_vars $args
    logInfo "Sending StartSession Session = $arg_vars(-session)"
    set step [ix_tc::step StartSession args]
    ix_tc::send $step
}

proc ix_tc::watch {args} {
    array set arg_vars $args    
    logInfo "Sending Watch Step Session = $arg_vars(-session)"
    
    set step [ix_tc::step Watch args]
    ix_tc::send $step
}

proc ix_tc::runProcess {args} {
    logInfo "Sending RunProcess args $args"
    set step [ix_tc::step RunProcess args]
    ix_tc::send $step
}

proc ix_tc::writeCsv {args} {
    logInfo "Sending WriteCsv args $args"
    set step [ix_tc::step WriteCsv args]
    ix_tc::send $step    
}

proc ix_tc::formatColumn {column} {
    set result $column
    set len [string length $column]
    for {set i 0} {$i < $len} {incr i} {
        set ch [string index $result $i]
        if {[string is space $ch]} {
            set result [string replace $result $i $i "_"]
        }
    }
    return $result
}

proc ix_tc::readFile {args} {

    array set arg_vars $args    
   	
    # keep the intial args
    set initialArgs $args
    
	logInfo "Arguements is $args"
    ### this command is intended to trigger the FileTransfer - informs CRE about the next file transfer
    set step [ix_tc::step ReadFile args]
    ix_tc::send $step 
}

proc ix_tc::showMessage {args} {
    logInfo "ShowMessage: $args"
    set step [ix_tc::step ShowMessage args]
    ix_tc::send $step
}

################################################################################
# The function is broken up in 4 different flows, each one handling one of the 
# following cases:
#	FLOW1. GetValue with an aggregator that returns multiple statistics
#	FLOW2. GetValue with an aggregator that returns a single statistic
#	FLOW3. GetValue without an aggregator that returns multiple statistics
#	FLOW4. GetValue without an aggregator that returns a single statistic
# Detailed comments are available inside the procedure.
################################################################################
proc ix_tc::getValue {args} {
	array set arg_vars $args
	if {[info exists arg_vars(-resultVar)]} {
	    upvar 1 $arg_vars(-resultVar) myvar
	}
	
	set aggVal $arg_vars(-aggregatefunction)
	
	if {$aggVal != ""} {	
		# We need to use an aggregator. Store the selected one locally.
		set aggregation [lindex $arg_vars(-expression) 0]
	
		################################################################################
		# Figure out how many columns we will return
		# Note: When we have an aggregator, the first element in $arg_vars(-expression)
		#		is the aggregator. Because we are handling the aggregation in this 
		#		function and we already stored its value locally we'll skip it when we 
		#		create a local version of the GetValue expression.
		################################################################################
		set getValueArgs [lrange $arg_vars(-expression)	1 end]
		set retStats [lindex $getValueArgs 1]
		set numStats [llength $retStats]
		
		if { $numStats > 1 } {
			################################################################################
			#	FLOW1. GetValue with an aggregator that returns multiple statistics
			################################################################################
			# We have to return more than one statistic with this command. To do this we
			# iterate through the return statistics and for each one we do the following:
			# 	1. Run a Getvalue command that returns the current statistic only
			#	2. Apply the aggregator to the results
			#	3. Create a new variable that will be named $arg_vars(-resultVar).$stat
			#	   where $arg_vars(-resultVar) is the specified return variable and $stat
			#	   is the return statistic we are currently processing.
			# Notes:
			#	1. A new return variable will be created for each of the returned statistics
			#	2. The return variables need to be accessible in the execution context that 
			#	   called this function so we will need to use upvar 1 and uplevel 1 when 
			#	   creating them.
			################################################################################
			
			foreach stat $retStats {
				################################################################################
				# Create the arguments for a GetValue command that uses the same parameters as 
				# our initial GetValue with the exception of the aggregator and returns only the 
				# current column ($stat).
				################################################################################
				set newArgs [lreplace $getValueArgs 1 1 $stat]
				set retVal [eval SgGetValue $newArgs]
				
				# Apply the selected aggregator to the partial results
				set valCount [llength $retVal]
				if { $aggregation == "Count" } {
					set retVal $valCount   
				} else {
					if {$valCount > 0} {
						set retVal [regsub -all {]} [regsub -all {\[} $retVal {\\[}] {\\]}]
						if { [llength [eval filterNumbers $retVal]] > 0 } {
							switch $aggregation {
								Last	{ set retVal [eval lastValue $retVal] }
								First	{ set retVal [eval firstValue $retVal] }
								Avg     { set retVal [eval avgValue $retVal] }
								Max		{ set retVal [eval maxValue $retVal] }
								Med     { set retVal [eval medValue $retVal] }
								Min     { set retVal [eval minValue $retVal] }
								Sum     { set retVal [eval sumValue $retVal] }
								Merge	{ set retVal [eval mergeValue $retVal] }
							}
						} elseif { $aggregation == "Merge" } {
							# Merge applies to strings too
							set retVal [eval mergeValue $retVal] 
						} elseif { $aggregation == "Last" } {
							# Last applies to strings too
							set retVal [eval lastValue $retVal]
						} elseif { $aggregation == "First" } {
							# First applies to strings too
							set retVal [eval firstValue $retVal]
						} else {
							set retVal ""
						}
					}
				}
				
				################################################################################
				# At this point $retVal contains the final result for the current statistic.
				# Let's create the corresponding return variable. 
				#
				# As noted above, the variable will use the TC 'composite variable' naming 
				# scheme and needs to be created in the execution context that called this 
				# procedure.
				#
				# NOTE: Only do this is a result variable exists.
				################################################################################
				
				if {[info exists arg_vars(-resultVar)]} {
					uplevel 1 { set newVarName dummyText }
					upvar 1 newVarName tmpNameReference
					set tmpNameReference $arg_vars(-resultVar).$stat
				
					uplevel 1 { set $newVarName dummyText }
					upvar 1 $arg_vars(-resultVar).$stat tmpValReference
					set tmpValReference $retVal			
				}
			}
			################################################################################
			#	END OF FLOW1. GetValue with an aggregator that returns multiple statistics
			################################################################################
		} else {
			################################################################################
			#	FLOW2. GetValue with an aggregator that returns a single statistic
			################################################################################
			################################################################################
			# We need to return only one statistic with this command so we will follow these 
			# steps:
			# 	1. Run a GetValue command without the aggregator 
			#	2. Apply the current aggregator to the results from 1.
			# 	3. Store the final result in $myvar
			# Note: $myvar is a reference to the specified return variable
			################################################################################
			set retVal [eval SgGetValue [lrange $arg_vars(-expression) 1 end]]

			set valCount [llength $retVal]
			if { $aggregation == "Count" } {
				set retVal $valCount   
			} else {
				if { $valCount > 0 } {
					set retVal [regsub -all {]} [regsub -all {\[} $retVal {\\[}] {\\]}]
					if { [llength [eval filterNumbers $retVal]] > 0 } {
						switch $aggregation {
							Last    { set retVal [eval lastValue $retVal] }
							Avg     { set retVal [eval avgValue $retVal] }
							Max		{ set retVal [eval maxValue $retVal] }
							Med     { set retVal [eval medValue $retVal] }
							Min     { set retVal [eval minValue $retVal] }
							Sum     { set retVal [eval sumValue $retVal] }
							Merge	{ set retVal [eval mergeValue $retVal] }
							First	{ set retVal [eval firstValue $retVal] }
						}
					} elseif { $aggregation == "Merge" } {
						# Merge applies to strings too
						set retVal [eval mergeValue $retVal]
					} elseif { $aggregation == "Last" } {
						# Last applies to strings too
						set retVal [eval lastValue $retVal]
					} elseif { $aggregation == "First" } {
						# First applies to strings too
						set retVal [eval firstValue $retVal]
					} else {
						set retVal ""
					}
				}
			}
		}
        set myvar $retVal
			################################################################################
			#	END OF FLOW2. GetValue with an aggregator that returns a single statistic
			################################################################################
    } else {
		################################################################################
		# Figure out how many columns we will return.
		# Note: We don't have aggregators so the first element in $arg_vars(-expression)
		#		is the variable we are running our GetValue on.
		################################################################################
		set getValueArgs $arg_vars(-expression)	
		set retStats [lindex $getValueArgs 1]
		set numStats [llength $retStats]
		
		if { $numStats > 1 } {
			################################################################################
			#	FLOW3. GetValue without an aggregator that returns multiple statistics
			################################################################################		
			################################################################################
			# We have to return more than one statistic with this command. To do this we
			# iterate through the return statistics and for each one we do the following:
			# 	1. Run a Getvalue command that returns the current statistic only
			#	2. Create a new variable that will be named $arg_vars(-resultVar).$stat
			#	   where $arg_vars(-resultVar) is the specified return variable and $stat
			#	   is the return statistic we are currently processing.
			# Notes:
			#	1. A new return variable will be created for each of the returned statistics
			#	2. The return variables need to be accessible in the execution context that 
			#	   called this function so we will need to use upvar 1 and uplevel 1 when 
			#	   creating them.
			################################################################################
			foreach stat $retStats {
				################################################################################
				# Create the arguments for a GetValue command that uses the same parameters as 
				# our initial GetValue and returns only the current column ($stat).
				################################################################################
				set newArgs [lreplace $getValueArgs 1 1 $stat]
				set retVal [eval SgGetValue $newArgs]
				
				################################################################################
				# At this point $retVal contains the final result for the current statistic.
				# Let's create the corresponding return variable. 
				#
				# As noted above, the variable will use the TC 'composite variable' naming 
				# scheme and needs to be created in the execution context that called this 
				# procedure.
				#
				# NOTE: Only do this is a result variable exists.
				################################################################################
				if {[info exists arg_vars(-resultVar)]} {
					uplevel 1 { set newVarName dummyText }
					upvar 1 newVarName tmpNameReference
					set tmpNameReference $arg_vars(-resultVar).$stat
				
					uplevel 1 { set $newVarName dummyText }
					upvar 1 $arg_vars(-resultVar).$stat tmpValReference
					set tmpValReference $retVal
				}
			}
			################################################################################
			#	END OF FLOW3. GetValue without an aggregator that returns multiple statistics
			################################################################################
		} else {
			################################################################################
			#	FLOW4. GetValue without an aggregator that returns a single statistic
			################################################################################
			################################################################################
			# We need to return only one statistic with this command so we will follow these 
			# steps:
			# 	1. Run a GetValue command without the aggregator 
			# 	2. Store the final result in $myvar
			# Note: $myvar is a reference to the specified return variable
			################################################################################		
			set cmd [format "SgGetValue %s" $arg_vars(-expression)]
			set myvar [eval $cmd]
			################################################################################
			#	END OF FLOW4. GetValue without an aggregator that returns a single statistic
			################################################################################
		}
	}
}

proc ix_tc::execute {args} {
    if {![validateExecArgs args]} {
        ix_tc::disconnect
        exit 1    
    }
    array set arg_vars $args    
    logInfo "Sending Execute Session = $arg_vars(-session) Command = $arg_vars(-command)"
    set step [ix_tc::step Execute args]
    ix_tc::send $step
    logInfo "Command completed."
}

proc ix_tc::sesc {args} {

    # args is a good way to automatically "escape" but the one case it doesn't do such a good job is when
    # the user is passing in a single variable which contains a "space" e.g.
    # ixtc::esc $file1
    # If $file1 contains a space, this gets set as {C:/Documents and Settings/.../}
    # When we return it, we return the {}'s with it and that is not right.
    # In this scenario we should strip the {}'s
    if {[llength $args] == 1 && [string index $args 0] == "\{" && [string index $args end] == "\}"} {
        return [lindex $args 0]
    }
    # Nothing to do, Tcl has done the escaping for us.
    return $args
}

proc ix_tc::esc {args} {

    # Nothing to do, Tcl has done the escaping for us.
    return $args
}

proc ix_tc::subst {value} {
    # The purpose of this call is to do variable substitution on the "value" using uplevel.
    # That is, value will contain variables from the calling context.
    # Secondly, for each item in the returned list, we want to escape quotes (") but only if
    # it is not escaped. This mimics the behavior seen in the C# code in TokenizerHelper.EscapeSpecialCharacters.
    # We don't need to emulate all the behavior because the Tcl interpreter does a lot of it
    # for us when we run through ScriptGen
    set ret ""
    set val [string trim $value]

    # Emulate the C# call in TclInterpreter.ResolveExpression in which we
    # escape [ and ] characters.
    regsub -all \\\[ $val \\\[ val
    regsub -all {([^\\])(\\\\\[)} $val \\1\\\[ val
    regsub -all \] $val \\\] val
    regsub -all {([^\\])(\\\\\])} $val \\1\\\] val
#   Don't substitue $ symbols because tcl matchs \\\$ to $.
#   regsub -all \\\$ $val \\\\\$ val
    regsub -all " " $val "\\\ " val
#   Don't substiture " with \" because this should have been done once already at Scriptgen time
#    regsub -all \" $val \\\" val
# We shouldn't escape {}'s here because the quotes around the $val will tell Tcl to
# ignore the {}'s. Escaping will also cause other side effects like not being able to find variables
# like {interface.ID} (i.e. composites).
    set val [uplevel set tcl_scriptgen_temp "$val"]
# Now that we've gone through this we need to handle the case where quotes are being used.
# StatQuery in particular doesn't like using quotes, so we should go through and replace then with
# {}'s. This used to be done automatically when we used ix_tc::esc but now we need to do this
# ourselves.
#Since we're going to do a foreach we need to make sure we're substituted quotes and back slash characters
#However, if the quote is already escapted then don't escape again
    regsub -all {\\} $val {\\\\} val
    regsub -all {\\\\"} $val {\\"} val
    foreach v $val {
        regsub -all \\\" $v \" v
        regsub -all \" $v \\\" v
        if {[string first " " $v] >= 0} {
            set ret "$ret \{$v\}"
        } else {
            if {[string length $v] == 0} {
                set ret "$ret {}"
            } else {
                set ret "$ret $v"
            }
        }
    }
    return [string trim $ret]
}

proc ix_tc::stopSession {args} {
    if {![validateStopSessionArgs args]} {
        ix_tc::disconnect
        exit 1    
    }    
    array set arg_vars $args
    logInfo "Sending StopSession Session = $arg_vars(-session)"
    set step [ix_tc::step StopSession args]
    ix_tc::send $step
}

proc ix_tc::step {type args} {
    upvar $args list_args
    array set a $list_args    
    
    variable step_system_timeout_event
    catch {unset step_system_timeout_event}
    
    variable step_system_error_event
    catch {unset step_system_error_event}

    if {[info exists a(-timeoutEvent)]} {
        set step_system_timeout_event $a(-timeoutEvent)
    }

    if {[info exists a(-errorEvent)]} {
        set step_system_error_event $a(-errorEvent)
    }
    
    catch {set procName [info level -2]}
    append step "000"
    append step "_____BEGIN_____"
    if {[info exists procName]} {
        append step "000" [format "%06d" [string length procedure]] procedure
        append step "001" [format "%06d" [string length $procName]] $procName    
    }    
    append step "000" [format "%06d" [string length type]] type
    append step "001" [format "%06d" [string length $type]] $type
    foreach key [array names a] {
        if {[string equal $a($key) "encrypted"]} {
            continue
        }
        if {[string equal $key "-globalEvent"]} {
            continue
        }

        set key_str [string trimleft $key -]	  
        append step "000" [format "%06d" [string length $key_str]] $key_str
        append step "001" [format "%06d" [string length $a($key)]] $a($key)
    }    
    append step "___END___"
    
    return $step
}

proc ix_tc::validateStopSessionArgs {args} {
    upvar $args list_args
    array set a $list_args
    if {![info exists a(-session)]} {
        logError "Argument -session is mandatory."
        return 0
    }    
    return 1    
}

proc ix_tc::validateStartSessionArgs {args} {
    upvar $args list_args
    array set a $list_args
    if {![info exists a(-session)]} {
        logError "Argument -session is mandatory."
        return 0
    }    
    return 1    
}

proc ix_tc::validateExecArgs {args} {
    upvar $args list_args
    array set a $list_args
    if {![info exists a(-session)]} {
        logError "Argument -session is mandatory."
        return 0
    }
    if {![info exists a(-command)]} {
        logError "Argument -command is mandatory."
        return 0
    }
    return 1    
}

proc ix_tc::systemEvent {args} {
    variable test_timeout
    variable test_error
    variable proc_timeout
    variable proc_error
    
    array set options $args
    
    switch -- $options(-scope) {
        test {
            if {[string equal $options(-type) "Step TimeOut"]} {
                set test_timeout [array get options]
            } elseif {[string equal $options(-type) "Step Error"]} { 
                set test_error [array get options]
            }
        }
        
        procedure {
            if {[string equal $options(-type) "Step TimeOut"]} {
                set proc_timeout($options(-procedureName)) [array get options]
            } elseif {[string equal $options(-type) "Step Error"]} { 
                set proc_error($options(-procedureName)) [array get options]
            }            
        }
        
        step {
            return [array get options]
        }        
    }
}


proc ix_tc::setGlobalVar {globalVar value} {
    logInfo "Assign global variable $globalVar <- $value"
    tsv::set tasks $globalVar $value
}


proc ix_tc::getGlobalVar {globalVar} {
    logInfo "Read value of the global variable $globalVar"
    return [tsv::get tasks $globalVar]
}
