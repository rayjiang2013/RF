#####################################################################
#
# TCL Library for Variable Access Procedures
#
#####################################################################

################################################
#
# CompareVar aggregation varName operator number
# - aggregator = type of aggregation to apply to the list given by 'varName.statName'
#                can be numerical: 'Count', 'Last', 'Avg', 'Min', 'Med', 'Max', 'Sum'
#                or logical: 'All', 'Any'
# - varName = the variable name
# - operator = comparison operator; one of '<' '>' '<=' '>=' '!=' '=='
# - number = reference value to compare to
#
# Returns: the result of the comparison against the list of values given by 'varName'
#
# Note: the logical aggregations perform the comparison on each value in the list,
#       and then aggregate the boolean results
#
################################################

proc CompareVar { aggregation varName operator number } {
    
    switch $aggregation {
    
        All {
            upvar 1 $varName values            
            if { [llength $values] > 0 } {
                set retVal 1
                foreach value $values {
                    if { ![eval Compare "$value" $operator "$number" ] } {
                        set retVal 0
                        break
                    }
                }
            }
        }
        
        Any {
            upvar 1 $varName values
            if { [llength $values] > 0 } {
                set retVal 0
                foreach value $values {
                    if { [eval Compare "$value" $operator "$number" ] } {
                        set retVal 1
                        break
                    }
                }
            }
        }
        
        default {
            upvar 1 $varName values
            set valCount [llength $values]
            if {$aggregation == "Count"} {
                set retVal $valCount
            } else {
                if {$valCount > 0} {
                    switch $aggregation {
                        Last    { set aggValue [eval lastValue $values] }
                        Avg     { set aggValue [eval avgValue $values] }
                        Max     { set aggValue [eval maxValue $values] }
                        Med     { set aggValue [eval medValue $values] }
                        Min     { set aggValue [eval minValue $values] }
                        Sum     { set aggValue [eval sumValue $values] }
                        Merge   { set aggValue [eval mergeValue $values] }
                    }
                }
                set retVal [eval Compare "$aggValue" $operator "$number" ]
            }
        }
    }
    
    return $retVal
}

################################################
#
# CompareValues aggregation varName statName operator number
# - aggregator = type of aggregation to apply to the list given by 'varName.statName'
#                can be numerical: 'Count', 'Last', 'Avg', 'Min', 'Med', 'Max', 'Sum'
#                or logical: 'All', 'Any'
# - varName = the variable group name. e.g. ixiaResult.iteration
# - statName = the name of the statistic column to be returned. e.g. Throughput
# - operator = comparison operator; one of '<' '>' '<=' '>=' '!=' '=='
# - number = reference value to compare to
#
# Returns: the result of the comparison against the list of values given by 'varName.statName'
#
# Note: the logical aggregations perform the comparison on each value in the list,
#       and then aggregate the boolean results
#
################################################

proc CompareValues { aggregation varName statName operator number } {
    
    switch $aggregation {
    
        All {
            set values [eval SgGetValue $varName $statName 0]
            if { [llength $values] > 0 } {
                set retVal 1
                foreach value $values {
                    if { ![eval Compare "$value" $operator "$number" ] } {
                        set retVal 0
                        break
                    }
                }
            }
        }
        
        Any {
            set values [eval SgGetValue $varName $statName 0]
            if { [llength $values] > 0 } {
                set retVal 0
                foreach value $values {
                    if { [eval Compare "$value" $operator "$number" ] } {
                        set retVal 1
                        break
                    }
                }
            }
        }
        
        default {
            set retVal [eval SgGetValue $varName $statName 0]
            set valCount [llength $retVal]
            if {$aggregation == "Count"} {
                set retVal $valCount
            } else {
                if {$valCount > 0} {
                    switch $aggregation {
                        Last    { set aggValue [eval lastValue $retVal] }
                        Avg     { set aggValue [eval avgValue $retVal] }
                        Max     { set aggValue [eval maxValue $retVal] }
                        Med     { set aggValue [eval medValue $retVal] }
                        Min     { set aggValue [eval minValue $retVal] }
                        Sum     { set aggValue [eval sumValue $retVal] }
                        Merge   { set aggValue [eval mergeValue $values] }
                    }
                }
            }
            set retVal [eval Compare "$aggValue" $operator "$number" ]
        }
    }
    
    return $retVal
}

proc Compare { input operator value } {
    set retVal 0
    switch $operator {
        "<"  { if {$input <  $value} { set retVal 1 } }
        ">"  { if {$input >  $value} { set retVal 1 } }
        "<=" { if {$input <= $value} { set retVal 1 } }
        ">=" { if {$input >= $value} { set retVal 1 } }
		"==" { if {$input == $value} { set retVal 1 } }
		"!=" { if {$input != $value} { set retVal 1 } }
    }
    return $retVal
}

################################################
#
# GetValue variableGroupName statName ?dimension1 value1? ...
# - variableGroupName = the variable group name. e.g. ixiaResult.iteration
# - statName = the name of the statistic column to be returned. e.g. Throughput
# - dimension1 value1 = dimension and value for filtering the statistic column
#
# Returns:  the list of statName values for
#           dimensions values matching the values in args' value1 ...
#
################################################

proc GetValue { args } {
    if {[llength $args] < 2} {
        return ""
    }
		
    set compositeVariableName [lindex $args 0]
    set statName [lindex $args 1]
       
    set dimValuePairs [expr ([llength $args] - 2 )/2]
    if {$dimValuePairs > 0} {
		
        set dimValue [lrange $args 2 end]
        set foreachHeader "foreach $statName \$\{[namespace current]::${compositeVariableName}.${statName}\} "
        set ifCommand "if \{ 1 "
        set globals "set getValResult {};"

        for {set i 0} {$i < $dimValuePairs} {incr i} {
			set stat [lindex $dimValue [expr 2*$i]]
            set value [lindex $dimValue [expr 2*$i +1]]
            
            set localstatname "stat$i"
            
            set foreachHeader [concat $foreachHeader "$localstatname \$\{[namespace current]::${compositeVariableName}.${stat}\}" ]
			
			set conditionType "Equals"
            ################################################################################
			# Check if the current filter is a "Contains" condition. The format of a 
			# "Contains" condition is - Contains(<expression>)
            ################################################################################
            set substring [string first "Contains(" $value]
            set substring1 [string last ")" $value] 
			if {$substring == 0 && $substring1 != -1} {
				set conditionType "Contains"
			}

            ############################################################################
            # If we didn't have a "Contains" condition we should check if the current 
			# filter is a "Matches" condition. The format of such a condition is - 
			# Matches(<expression>)
            ############################################################################
			if {$conditionType != "Contains"} {
				set substring [string first "Matches(" $value]
				set substring1 [string last ")" $value] 
				if {$substring == 0 && $substring1 != -1} {
					set conditionType "Matches"
				}
			}
			
            if {$substring == 0 && $substring1 != -1 && $conditionType == "Contains"} {
				# We have a "Contains" condition
                regsub -- "Contains\\(\(.*\)\\)$" $value "\\1" searchString
                        
                ############################################################################
                # Set the Special Characters 
				# NOTE: Do not change the order of the chars here!!! The oder is 
				#	backslash -> square braces -> anything else
				############################################################################
                set specialChars {\\ ] ^ ? + * ( ) | < > ~ ! # % _}
                # Insert \ before the special character	if search string contains special characters
                # We cannot send some of the reserve characters with search string.
                # Since our commands will not support for those characters.
                # We have restricted to enter those characters in UI
                # reserved characters are @,$,&,{,},[,:,"	
                for {set index 0} {$index < [llength $specialChars]} {incr index} {	
                    regsub -all "\\[lindex $specialChars $index]" $searchString "\\\[\\[lindex $specialChars $index]\\]" searchString			
                }

                set ifCommand [concat $ifCommand "&& \[regexp \"(.*$searchString.*)\" \$\{$localstatname\}\] "]
            } elseif {$substring == 0 && $substring1 != -1 && $conditionType == "Matches"} {
				# We have a "Matches" condition			
				regsub -- "Matches\\(\(.*\)\\)$" $value "\\1" searchString
				
                ############################################################################
                # Set the Special Characters 
				# NOTE: Do not change the order of the chars here!!! The oder is 
				#	backslash -> anything else
				# NOTE: Do not attempt to escape special charaters that are used in TCL
				# regular expressions such as \ [ ] ^ ? + * ( )
				############################################################################
                set specialChars {| < > ~ ! # % _}
				
                # Escape the predefined special characters using \  
                for {set index 0} {$index < [llength $specialChars]} {incr index} {
					regsub -all "\\[lindex $specialChars $index]" $searchString "\\\[\\[lindex $specialChars $index]\\]" searchString
                }

                set ifCommand [concat $ifCommand "&& \[regexp \{$searchString\} \$\{$localstatname\}\] "]				
			} elseif {$value != "*"} {
                ################################################################
                ### we must check if the value we must filter from encloses the minus character
                ### since we're using it in the regex to determine if we are filtering a range
                ### if we find such a value, we'll be searching in the values list for that item
                ### should that item exist in the list, we're no longer filtering by range but by that
                ### specific value; normal behavior for the normal(numeric) range input and simple value input
                ################################################################
                set restrictedCharExists [string first "-" $value]
                set listitem 0
                if {$restrictedCharExists >= 0} {
                    foreach element [set ::[namespace current]::${compositeVariableName}.${stat}] {
                        if {$element == $value} {
                            set listitem 1
                            break
                        }
                    }
                }
              
                if { [regexp {([^ -]+)-([^ -]+)} $value all low high] && !$listitem} {
                    set ifCommand [concat $ifCommand "&& \$\{$localstatname\} >= \"$low\" && \$\{$localstatname\} <= \"$high\" "]
                } else {
                    set ifCommand [concat $ifCommand "&& \$\{$localstatname\} == \"$value\" "]
                }
            }
        }
        set ifCommand [concat $ifCommand "\} \{ lappend getValResult \${$statName} \}"]
        set command [concat $globals $foreachHeader "\{ $ifCommand \} ; set getValResult"]
		
        ################################################
        # Following code sample should be created in command
        #
        # set getValResult {} ;
        # global ixia.iteration.throughput;
        # global ixia.iteration.framesize ;
        # global ixia.iteration.iteration ;
        #
        # foreach throughput ${ixia.iteration.throughput} framesize ${ixia.iteration.framesize} iteration ${ixia.iteration.iteration} {
        #       if { 1 && $framesize == "2" && $iteration == "1" } {
        #           lappend getValResult $throughput
        #       }
        #   } ;
        # set getValResult
        #
		# set totallist [eval $command]
        # foreach listval $searchstring
		# {
			# lappend totallist $listval
		# }
		# lappend searchstring $command
		# return $command
		#puts $command

        return [eval $command]
		# return $command
        
    } else {
        return [set ::[namespace current]::${compositeVariableName}.${statName}]
    }
}

################################################
#
# GetValue variableGroupName statName ?dimension1 value1? ...
# - variableGroupName = the variable group name. e.g. ixiaResult.iteration
# - statName = the name of the statistic column to be returned. e.g. Throughput
# - dimension1 value1 = dimension and value for filtering the statistic column
# 
# The difference between the regular GetValue is the placeholder for the composite variables is 2 levels up on stack,
# instead of a specific namespace.
#
# Returns:  the list of statName values for
#           dimensions values matching the values in args' value1 ...
#
################################################

proc SgGetValue { args } {
    if {[llength $args] < 2} {
        return ""
    }
    set compositeVariableName [lindex $args 0]
    set statName [lindex $args 1]
       
    set dimValuePairs [expr ([llength $args] - 2 )/2]
    if {$dimValuePairs > 0} {
        # escape the parenthesis - not to be treated like indexed array
        set nStatName [regsub -all "\\\(|\\\)" $statName "_"]
        set dimValue [lrange $args 2 end]
        set varSection "upvar 2 ${compositeVariableName}.${statName} _${compositeVariableName}.${nStatName};"
        
        set foreachHeader "foreach $statName \$\{_${compositeVariableName}.${nStatName}\} "
        set ifCommand "if \{ 1 "
        set globals "set getValResult {};"
        for {set i 0} {$i < $dimValuePairs} {incr i} {
            set stat [lindex $dimValue [expr 2*$i]]
            # escape the parenthesis - not to be treated like indexed array
            set nStat [regsub -all "\\\(|\\\)" $stat "_"]
            set varSection [concat $varSection "upvar 2 ${compositeVariableName}.${stat} _${compositeVariableName}.${nStat};"]
        }
        
        for {set i 0} {$i < $dimValuePairs} {incr i} {
            set stat [lindex $dimValue [expr 2*$i]]
            set value [lindex $dimValue [expr 2*$i +1]]
			
			# Create a local reference to the filter statistic
			upvar 2 ${compositeVariableName}.${stat} _${compositeVariableName}.${stat}
            
            set localstatname "stat$i"
            # escape the parenthesis - not to be treated like indexed array            
            set nStat [regsub -all "\\\(|\\\)" $stat "_"]
            
            set foreachHeader [concat $foreachHeader "$localstatname \$\{_${compositeVariableName}.${nStat}\}" ]
            
			set conditionType "Equals"
            ################################################################################
			# Check if the current filter is a "Contains" condition. The format of a 
			# "Contains" condition is - Contains(<expression>)
            ################################################################################
            set substring [string first "Contains(" $value]
            set substring1 [string last ")" $value]
			if {$substring == 0 && $substring1 != -1} {
				set conditionType "Contains"
			}			
            
            ############################################################################
            # If we didn't have a "Contains" condition we should check if the current 
			# filter is a "Matches" condition. The format of such a condition is - 
			# Matches(<expression>)
            ############################################################################
			if {$conditionType != "Contains"} {
				set substring [string first "Matches(" $value]
				set substring1 [string last ")" $value] 
				if {$substring == 0 && $substring1 != -1} {
					set conditionType "Matches"
				}
			}
			
            if {$substring == 0 && $substring1 != -1 && $conditionType == "Contains"} {
				# We have a "Contains" condition
                regsub -- "Contains\\(\(.*\)\\)$" $value "\\1" searchString
                        
                # Set the Special Characters -- NOTE: do not change the order of the chars here!! first analyze backslash then square braces then anything else!
                set specialChars {\\ ] ^ ? + * ( ) | < > ~ ! # % _}
                # Insert \ before the special character	if search string contains special characters
                # We cannot send some of the reserve characters with search string.
                # Since our commands will not support for those characters.
                # We have restricted to enter those characters in UI
                # reserve characters are @,$,&,{,},[,:,"	
                for {set index 0} {$index < [llength $specialChars]} {incr index} {	
                    regsub -all "\\[lindex $specialChars $index]" $searchString "\\\[\\[lindex $specialChars $index]\\]" searchString			
                }

                set ifCommand [concat $ifCommand "&& \[regexp \"(.*$searchString.*)\" \$\{$localstatname\}\] "]
            } elseif {$substring == 0 && $substring1 != -1 && $conditionType == "Matches"} {
				# We have a "Matches" condition
				regsub -- "Matches\\(\(.*\)\\)$" $value "\\1" searchString
				
                ############################################################################
                # Set the Special Characters 
				# NOTE: Do not change the order of the chars here!!! The oder is 
				#	backslash -> anything else
				# NOTE: Do not attempt to escape special charaters that are used in TCL
				# regular expressions such as \ [ ] ^ ? + * ( )
				############################################################################
                set specialChars {| < > ~ ! # % _}
				
                # Escape the predefined special characters using \  
                for {set index 0} {$index < [llength $specialChars]} {incr index} {
					regsub -all "\\[lindex $specialChars $index]" $searchString "\\\[\\[lindex $specialChars $index]\\]" searchString
                }

                set ifCommand [concat $ifCommand "&& \[regexp \{$searchString\} \$\{$localstatname\}\] "]
			} elseif {$value != "*"} {
                ################################################################
                ### we must check if the value we must filter from encloses the minus character
                ### since we're using it in the regex to determine if we are filtering a range
                ### if we find such a value, we'll be searching in the values list for that item
                ### should that item exist in the list, we're no longer filtering by range but by that
                ### specific value; normal behavior for the normal(numeric) range input and simple value input
                ################################################################
                set restrictedCharExists [string first "-" $value]
                set listitem 0
                if {$restrictedCharExists >= 0} {
                    foreach element [set _${compositeVariableName}.${stat}] {
                        if {$element == $value} {
                            set listitem 1
                            break
                        }
                    }
                }
                
                if { [regexp {([^ -]+)-([^ -]+)} $value all low high] && !$listitem} {
                    set ifCommand [concat $ifCommand "&& \$\{$localstatname\} >= \"$low\" && \$\{$localstatname\} <= \"$high\" "]
                } else {
                    set ifCommand [concat $ifCommand "&& \$\{$localstatname\} == \"$value\" "]
                }
            }
        }
        set ifCommand [concat $ifCommand "\} \{ lappend getValResult \${$statName} \}"]
        set command [concat $globals $varSection $foreachHeader "\{ $ifCommand \} ; set getValResult"]
        
        ################################################
        # Following code sample should be created in command
        #
        # set getValResult {} ;
        # global ixia.iteration.throughput;
        # global ixia.iteration.framesize ;
        # global ixia.iteration.iteration ;
        #
        # foreach throughput ${ixia.iteration.throughput} framesize ${ixia.iteration.framesize} iteration ${ixia.iteration.iteration} {
        #       if { 1 && $framesize == "2" && $iteration == "1" } {
        #           lappend getValResult $throughput
        #       }
        #   } ;
        # set getValResult
        #

        return [eval $command]
    } else {
        upvar 2 ${compositeVariableName}.${statName} _${compositeVariableName}.${statName}
        set varName _${compositeVariableName}.${statName}
        return [set ${varName}]
    }
}

proc SgAggregateList { aggregation args } {
    set retVal [eval SgGetValue $args]
    set valCount [llength $retVal]

    if {$aggregation == "Count"} {
        return $valCount
    } else {
        if {$valCount > 0} {
            switch $aggregation {
                Last    { set retVal [eval lastValue $retVal] }
                Avg     { set retVal [eval avgValue $retVal] }
                Max     { set retVal [eval maxValue $retVal] }
                Med     { set retVal [eval medValue $retVal] }
                Min     { set retVal [eval minValue $retVal] }
                Sum     { set retVal [eval sumValue $retVal] }
                Merge   { set aggValue [eval mergeValue $values] }
				First	{ set retVal [eval firstValue $retVal] }
            }
        }
    }
    return $retVal
}

proc AggregateList { aggregation args } {
    set retVal [eval GetValue $args]
    set valCount [llength $retVal]

    if {$aggregation == "Count"} {
        return $valCount
    } else {
        if {$valCount > 0} {
            switch $aggregation {
                Last    { set retVal [eval lastValue $retVal] }
                Avg     { set retVal [eval avgValue $retVal] }
                Max     { set retVal [eval maxValue $retVal] }
                Med     { set retVal [eval medValue $retVal] }
                Min     { set retVal [eval minValue $retVal] }
                Sum     { set retVal [eval sumValue $retVal] }
                Merge 	{ set retVal [eval mergeValue $retVal] }
				First	{ set retVal [eval firstValue $retVal] }
            }
        }
    }
    return $retVal
}

proc AggregateVar { aggregation varName } {
    set values [set ::[namespace current]::${varName}]
    set retVal $values
    set valCount [llength $retVal]

    if {$aggregation == "Count"} {
        return $valCount
    } else {
        if {$valCount > 0} {
            switch $aggregation {
                Last    { set retVal [eval lastValue $retVal] }
                Avg     { set retVal [eval avgValue $retVal] }
                Max     { set retVal [eval maxValue $retVal] }
                Med     { set retVal [eval medValue $retVal] }
                Min     { set retVal [eval minValue $retVal] }
                Sum     { set retVal [eval sumValue $retVal] }
                Merge   { set retVal [eval mergeValue $retVal] }
				First	{ set retVal [eval firstValue $retVal] }				
            }
        }
    }
    return $retVal
}

proc lastValue { args } {
    return [lindex $args [expr [llength $args] - 1]]
}

proc firstValue { args } {
	return [lindex $args 0]
}

# filters out any string that is not a number
proc filterNumbers { args } {
    set list [list]
    foreach value $args { if { [string is double -strict $value] } { lappend list $value } }
    return $list    
}

# sums up the given values (only numbers accepted as input)
proc sumOfNumbers { args } {
    set sum 0
    foreach value $args { set sum [expr $sum + $value] }
    return $sum
}

proc avgValue { args } {
    set args [eval filterNumbers $args]
    return [expr [eval sumOfNumbers $args] / [llength $args].0]
}

proc maxValue { args } {
    set args [eval filterNumbers $args]
    set max [lindex $args 0]
    foreach value $args { if {$value > $max} { set max $value } }
    return $max
}

proc medValue { args } {
    set args [eval filterNumbers $args]

    if {[catch {set tempList [lsort -real $args]}]} {set tempList [lsort $args]}

    set len [llength $args]
    set midIdx [expr $len / 2]

    if {[expr $len % 2 != 0]} {
        return [lindex $tempList $midIdx]
    } else {
        set midIdx_ [expr $midIdx - 1]
        return [expr ( [lindex $tempList $midIdx] + [lindex $tempList $midIdx_] ) / 2.0]
    }
}

proc minValue { args } {
    set args [eval filterNumbers $args]
    set min [lindex $args 0]
    foreach value $args { if {$value < $min} { set min $value } }
    return $min
}

proc sumValue { args } {
    return [eval sumOfNumbers [eval filterNumbers $args]]
}

proc mergeValue { args } {
    set ret ""
    # Remove one layer of items merge, if the item is a list that
    # just happens to have other items with "spaces" in them, then 
    # the result simply be one big merged list.
    foreach a $args {
	if {$ret == ""} {
	    set ret $a
	} else {
	    set ret "$ret $a"
        }
    }
    return $ret
}

################################################
#
# GenerateStatsCsv filename variableName1 ?variableName2? ...
# - filename = the name of the output csv file
# - variableName = the name of the tcl variable to display as a csv column
#
################################################

proc GenerateStatsCsv {args } {
    if {[llength $args] < 2} {
        return ""
    }
    
    set filename    [lindex $args 0]
    set localStats  [lindex $args 1]
    set globalStats [lindex $args 2]
    set localTypes	[lindex $args 3]
    set globalTypes	[lindex $args 4]
    
    set outputFile  [open $filename w]
    set maxLength 1
      
    # print the csv header
    set currentIndex 0
    foreach statName $localStats {
        puts -nonewline $outputFile "$statName,"
        if {[info exists ::[namespace current]::${statName}]} {
			if {[lindex $localTypes $currentIndex]} {
				if {[llength [set ::[namespace current]::${statName}]] > $maxLength} {
					set maxLength [llength [set ::[namespace current]::${statName}]]
				}
            }
        }
        incr currentIndex
    }

    set currentIndex 0
    foreach statName $globalStats {
        puts -nonewline $outputFile "$statName,"
        if {[info exists ::NamespaceForGlobalVariables::${statName}]} {
			if {[lindex $localTypes $currentIndex]} {        
				if {[llength [set ::NamespaceForGlobalVariables::${statName}]] > $maxLength} {
					set maxLength [llength [set ::NamespaceForGlobalVariables::${statName}]]
				}
			}
        }
        incr currentIndex
    }
    
    puts $outputFile "";
    
    # print the csv data
    for {set i 0} {$i < $maxLength} {incr i} {
	    set currentIndex 0
        foreach statName $localStats {
            if {[info exists ::[namespace current]::${statName}]} {
				if {[lindex $localTypes $currentIndex]} {
					puts -nonewline $outputFile "[lindex [set ::[namespace current]::${statName}] $i],"
				} else {
					if {[expr $i == 0]} {
						puts -nonewline $outputFile "[set ::[namespace current]::${statName}],"
					} else {
						puts -nonewline $outputFile ","
					}
				}
            } else {
                puts -nonewline $outputFile ","
            }
	        incr currentIndex
        }

	    set currentIndex 0
        foreach statName $globalStats {
            if {[info exists ::NamespaceForGlobalVariables::${statName}]} {
				if {[lindex $localTypes $currentIndex]} {
	                puts -nonewline $outputFile "[lindex [set ::NamespaceForGlobalVariables::${statName}] $i],"
				} else {
					if {[expr $i == 0]} {
						puts -nonewline $outputFile "[set ::NamespaceForGlobalVariables::${statName}],"
					} else {
						puts -nonewline $outputFile ","
					}
				}
            } else {
                puts -nonewline $outputFile ","
            }
	        incr currentIndex
        }
        
        puts $outputFile "";
    }
    
    close $outputFile
}
    
################################################
#
# GenerateStatsCsv filename variableName1 ?variableName2? ...
# - filename = the name of the output csv file
# - variableName = the name of the tcl variable to display as a csv column
#
################################################

proc SgGenerateStatsCsv {args } {
    if {[llength $args] < 1} {
        return ""
    }
    
    set filename    [lindex $args 0]
    set stats       [lrange $args 1 end]
    set outputFile  [open $filename w]
    set maxLength 1
    
    # print the csv header
    foreach statName $stats {
        upvar $statName statPointer
        puts -nonewline $outputFile "$statName,"
        if {[info exists statPointer]} {
            if {[string length $statPointer] > $maxLength} {
                set maxLength [string length $statPointer]
            }
        }
    }
    
    puts $outputFile "";
    
    foreach statName $stats {
        upvar $statName statPointer
        if {[info exists statPointer]} {            
            puts -nonewline $outputFile "$statPointer,"
        } else {
            puts -nonewline $outputFile ","
        }
    }
    
    puts $outputFile "";
    
    close $outputFile
}

proc GenerateCsv {filenamevar header values} {
    set filename    $filenamevar
    set stats       $values
    set csvheader   $header
    
    set writeHeader 1
    if {[file exists $filename]} {
        set writeHeader 0
    }
    set outputFile  [open $filename "a"]
    
    if {$writeHeader} {
        foreach statName $csvheader {
            puts -nonewline $outputFile "$statName,"
        }
        puts $outputFile ""
    }    
    foreach statName $stats {
      puts -nonewline $outputFile "$statName,"
    }     
    puts $outputFile ""
    
    close $outputFile
}

################################################
#
# setbaseline variableName value
# Sets the baseline value for a composer variable.
# Value is saved into the baseline file [namespace current]::outputBaselineComposerFile
# - variableName    = the name of the tcl variable
# - value           = the baseline value
#
################################################

proc SetBaseline {variableName value} {
    
    if {![info exists [namespace current]::outputBaselineComposerFile]} {
        return 1
    }
    
    if {[catch {set fid [open [set [namespace current]::outputBaselineComposerFile] a+]}]} {
        puts "Warning:  Cannot open $[namespace current]::outputBaselineComposerFile file."
        return 1
    }
    puts $fid "set ${variableName}_baseline $value"
    close $fid
    return 0
}

proc setbaseline {variableName value} {
    return [SetBaseline $variableName $value]
}

################################################
#
# getbaseline variableName
# Gets the baseline value for a composer variable.
# Value is got from the baseline file [namespace current]::inputBaselineComposerFile
# - variableName    = the name of the tcl variable
#
################################################

proc GetBaseline {variableName } {
    if {![info exists [namespace current]::inputBaselineComposerFile]} {
        return ""
    }
    if {![file exists [set [namespace current]::inputBaselineComposerFile]]} {
        return ""
    }
    source [set [namespace current]::inputBaselineComposerFile]
    if {[info exists ${variableName}_baseline]} {
        return [set ${variableName}_baseline]
    }
    return ""
}

proc getbaseline {variableName } {
    return [GetBaseline $variableName]
}

proc binarySearchIsBestIteration {conditionResultValues} {
    upvar $conditionResultValues conditionResult
    
    set isBestIteration 1
    for { set bestIterVar 0} { $bestIterVar < [llength $conditionResult]} {incr bestIterVar} {
        if { ! [lindex $conditionResult $bestIterVar] } {
            set isBestIteration 0
            break
        }
    }
    
    return $isBestIteration       
}

proc binarySearchReachEnd {i_minim i_maxim i_resolution} {
    for { set i 0 } { $i < [llength $i_minim] } { incr i } {
        if { [lindex $i_maxim $i]-[lindex $i_minim $i]>[lindex $i_resolution $i] } {
            return 0
        }
    }
    return 1
}

proc binarySearchComputeNextValue {currentValues minimumValues maximumValues conditionResultValues resolutionValues backoffValues} {
    upvar $currentValues current
    upvar $minimumValues minimum
    upvar $maximumValues maximum
    upvar $backoffValues backoff
    upvar $resolutionValues resolution
    upvar $conditionResultValues conditionResult
    
    for { set tmp 0} { $tmp < [llength $conditionResult]} {incr tmp} {
        set _min [lindex $minimum $tmp]
        set _max [lindex $maximum $tmp]
        set _resolution [lindex $resolution $tmp]
        set _condResult [lindex $conditionResult $tmp]
        set _current [lindex $current $tmp]
        set _backoff [lindex $backoff $tmp]
		if {$_max - $_min > $_resolution } {
			if { $_condResult } {
                set _min $_current
                set _max $_max
                set _current [expr $_current + [expr $_max - $_min] * $_backoff]                
                set current [lreplace $current $tmp $tmp $_current]
                set maximum [lreplace $maximum $tmp $tmp $_max]
                set minimum [lreplace $minimum $tmp $tmp $_min]
			} else {
                set _min $_min
                set _max $_current
                set _current [expr $_current - [expr $_max - $_min] * $_backoff]
                set current [lreplace $current $tmp $tmp $_current]
                set maximum [lreplace $maximum $tmp $tmp $_max]
                set minimum [lreplace $minimum $tmp $tmp $_min]
			 }
		} 
	 } 
}

proc linearSearchReachEnd {ignoreResult} {
    upvar $ignoreResult ignoreSearchResult
    for {set i 0} {$i < [llength $ignoreSearchResult]} {incr i} {
        if {! [lindex $ignoreSearchResult $i]} {
            return 0
        }
    }    
    return 1
}

proc linearSearchComputeBestIteration {conditionResult ignoreSearchResult current best} {
    upvar $conditionResult searchCondition
    upvar $ignoreSearchResult ignoreSearch
    upvar $best bestIteration
    upvar $current currentValues
    
    for {set i 0} {$i < [llength $searchCondition]} {incr i} {
        if {[lindex $searchCondition $i] && ! [lindex $ignoreSearch $i]} {
            set bestIteration [lreplace $bestIteration $i $i [lindex $currentValues $i]]
        }
    }
}

proc linearSearchComputeNextIteration {incrementStep limitValue conditionResult current ignoreSearchResult} {
    upvar $incrementStep step
    upvar $limitValue limit
    upvar $conditionResult searchCondition
    upvar $ignoreSearchResult ignoreSearch
    upvar $current currentValues
    
    for {set i 0} {$i < [llength $step]} {incr i} {
        if {! [lindex $ignoreSearch $i]} {
            if {[lindex $searchCondition $i]} {
                set cValue [lindex $currentValues $i]
                set stepValue [lindex $step $i]                
                set newValue [expr $cValue + $stepValue]
                
                set currentValues [lreplace $currentValues $i $i $newValue]
                set ignoreSearch [lreplace $ignoreSearch $i $i [limitIsHit [lindex $limit $i] [lindex $step $i] $newValue]]
            } else  {
                set ignoreSearch [lreplace $ignoreSearch $i $i 1]
            }
        }
    }    
}

proc limitIsHit {limit step current} {
    if {[expr {$step > 0 && $current > $limit}] || [expr {$step < 0 && $current < $limit}] } {
        return 1
    } else  {
        return 0
    }
}


################################################
#
# ParseSleepCommand interval
# Parses the given interval and extracts the total numer of seconds according with the composer sleep command format
# - interval    = interval to parse
#
################################################

proc ParseSleepCommand { interval } {

	if {[string first ":" $interval] >= 0} {
		if {[string last "." $interval] >= 0} {
			set interval [string range $interval 0 [expr [string last "." $interval] - 1]]
		}

		if {[catch {clock scan $interval}]} {
			return ""
		} else {
			return [expr [clock scan $interval] - [clock scan 0]]
		}
	} else {
		set len [string length $interval]
		set endChar [string index $interval [expr $len - 1]]
		set startNumber [string range $interval 0 [expr $len - 2]]
		
		if {[string is integer $startNumber]} {
			if {[string compare $endChar "s"] == 0} {
				return $startNumber
			} elseif {[string compare $endChar "m"] == 0} {
				return [expr $startNumber * 60]
			} else {
				return ""
			}
		} else {
			return ""
		}
	}
}
