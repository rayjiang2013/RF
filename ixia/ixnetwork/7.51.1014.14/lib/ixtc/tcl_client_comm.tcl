namespace eval ix_tc {
    variable cmd_output
    variable step_error
    variable protocol_error
    variable cmd_return_var
    variable system_error
    
    variable results_dir "./RESULTS"
}

global isThreadEnabled
set isThreadEnabled 1

proc ix_tc::disconnect {} {    
    global ix_client_socket
    ix_tc::logInfo "Disconnect from CRE."
    close $ix_client_socket
    
    # close the logging component
    ix_tc::closeLogger
}


proc ix_tc::connect {host port} {
    global ix_client_socket
    
    # init logging component
    ix_tc::initLogger

    tsv::set tasks cre_host $host
    tsv::set tasks cre_port $port
    logInfo "Connecting to CRE $host port $port"
    after 5000
    if { [catch { set ix_client_socket [socket $host $port] } err] } {
            error "Unable to connect to target system. Check your connection parameters for IP address, hostname, domain etc.. $err"
            return
        }
    fconfigure $ix_client_socket -encoding ascii -buffering full -translation lf -blocking 1
    logInfo "Connected successfully."
}


proc ix_tc::spawnTest {test} {
    global ix_client_socket

    append packet "003"
    append packet "_____BEGIN_____"
    append packet "000" [format "%06d" [string length test]] test
    append packet "001" [format "%06d" [string length $test]] $test
    append packet "___END___"

    puts $ix_client_socket $packet
    flush $ix_client_socket    
    readResponse  
}


proc ix_tc::startTest {test} {
    tsv::set tasks main [thread::id]    
    global isThreadEnabled
    
    if {! $isThreadEnabled } {
        ix_tc::logWarn "The thread support is not enabled - the application continue without parallelism support."
        ix_tc::logWarn "Please note that asynchronous events processing, ix_tc::spawn and ix_tc::join steps are disabled for this run."
    }
    
    set trials 0
    while {$trials < 20} {        
        set randPort [expr {rand()}]    
        set srvPort [expr { int([format "%0.2f" $randPort] * 100) + 9900}]
        # start the TCP server waiting for connection carrying the user events
        set status [ix_tc::startEventServer $srvPort]        
        if {$status != 0} {
            logWarn "Failed to open server for events ... try again."
            incr trials
        } else  {
            break
        }
    }    
    if {$trials == 20} {
        logError "Fatal error: unable to create server socket for events. System halts."
        exit
    }

    # send the test
    sendTestFile $test $srvPort
    
    if {$isThreadEnabled} {
        # start the dedicated thread for processing user events
        ix_tc::startProcessor
    }    
    # set the file variables
	setFileVariables    
}


proc ix_tc::stopTest {test} {    
    global ix_client_socket    
    
    logInfo "Stopping the test $test ... "
    set isError [catch {
        set sessionId [tsv::get tasks sessionId]    
        append packet "002"
        append packet "_____BEGIN_____"
        append packet "000" [format "%06d" [string length test]] test
        append packet "001" [format "%06d" [string length $sessionId]] $sessionId
        append packet "___END___"
        
        puts $ix_client_socket $packet
        if { [catch { flush $ix_client_socket } err] } {
            regsub -all {.*\:} $err "" err
            error "$err"
            return
        }
        
        global run_dir
        logInfo "Collecting files ... "
        readTestResultFiles $run_dir    
        #readTestResultFiles $run_dir
        
        global isThreadEnabled
        if {$isThreadEnabled} {
            logInfo "Shutdown the events server ... "
            ix_tc::stopEventListener
        }
        
        set thId [thread::id]
        set mainId [tsv::get tasks main]
        
        if {[string equal $thId $mainId]} {
            # copy the executed script into RESULTS folder - only from the main thread
            global run_dir
            set scriptFile [info script]
            file copy -force $scriptFile [file join $run_dir [file tail $scriptFile]]
            
            global testfile
            if {[info exists testfile]} {
                file copy -force $testfile [file join $run_dir [file tail $testfile]]
            }
        }
        logInfo "Test ended."    
    } stopErr] 
        
    if {$isError} {
        logWarn "Error while stopping the test: $stopErr"
        logInfo "Test ended."        
    }
    
    tsv::unset tasks main
}

proc ix_tc::readTestResultFiles {outDir} {
    global ix_client_socket    
    # read the length of the message
    gets $ix_client_socket length
    set resp [read $ix_client_socket $length]
        
    while {$resp != "END"} {        
        switch $resp {
            "filename"
            {
                gets $ix_client_socket length
                set filename [read $ix_client_socket $length]
            }
            "size"
            {
                gets $ix_client_socket length
                set size [read $ix_client_socket $length]
                set destFile "${outDir}/${filename}"                
                
                readBinaryFile $destFile $size
            }
        }
        
        gets $ix_client_socket length
        set resp [read $ix_client_socket $length]
    }    
}


proc ix_tc::setFileVariables {args} {
	global ix_client_socket
	
	# add service id
	append packet "004"
	append packet "_____BEGIN_____"
	append packet "___END___"
	puts $ix_client_socket $packet
	flush $ix_client_socket 

	readFileVariables $args
}


proc ix_tc::generatePassFailStats {args} {
    global run_dir    
    set passFailStatsFile [file join $run_dir "PassFailStats.csv"]
    uplevel SgGenerateStatsCsv $passFailStatsFile $args
}

proc ix_tc::setReservedVariables {args} {
	global ix_client_socket

	# add service id
	append packet "005"
	append packet "_____BEGIN_____"
	append packet "___END___"
	puts $ix_client_socket $packet
	flush $ix_client_socket 

	readReservedVariables 
}

proc ix_tc::readFileVariables {args} {
    global ix_client_socket
    
	# read the length of the message
    gets $ix_client_socket length
    set resp [read $ix_client_socket $length]    
	
	#trim the chars "{" and "}"
	set args [string trimleft $args "{"]
	set args [string trimright $args "}"]

	eval [list lappend argslist] $args

    while {$resp != "END"} {        
        switch $resp {
            "fileVariable"
            {
                gets $ix_client_socket length
                set filevars [read $ix_client_socket $length]
                set fileVarArray [split $filevars ~]

                for {set i 0} {$i < [llength $fileVarArray]} {set i [expr $i+2]} {
					foreach v $argslist {
						if { $v eq [lindex $fileVarArray $i]} {
							#puts "Matches"
							upvar 2 [lindex $fileVarArray $i] myvar
							set myvar [lindex $fileVarArray [expr $i+1]]
						}
					}
                }
            }
        }
        gets $ix_client_socket length
        set resp [read $ix_client_socket $length]
    }    
}

proc ix_tc::readReservedVariables {} {
    global ix_client_socket
        
    # read the length of the message
    gets $ix_client_socket length
    set resp [read $ix_client_socket $length]    

    while {$resp != "END"} {        
        switch $resp {
            "reservedVariable"
            {
                gets $ix_client_socket length
                set resvars [read $ix_client_socket $length]
                set resVarArray [split $resvars ~]
                #puts "After split [llength $resVarArray]"
                for {set i 0} {$i < [llength $resVarArray]} {set i [expr $i+2]} {
                    upvar 2 [lindex $resVarArray $i] myvar
                    set myvar [lindex $resVarArray [expr $i+1]]
                }
            }
        }
        gets $ix_client_socket length
        set resp [read $ix_client_socket $length]
    }    
}

proc ix_tc::readBinaryFile {dest size} {
    global ix_client_socket    
    set bufferSize [expr 1024 * 1024]
    set f [open $dest "w+"]
    fconfigure $f -translation binary
    
    set fileLength 0
    set tail [expr {$size % $bufferSize}]    
    set nrChunks [expr {$size / $bufferSize}]
    for {set i 0} {$i < $nrChunks} {incr i} {
        set readBytes [read $ix_client_socket $bufferSize]
        puts $f $readBytes
    }
    set readBytes [read $ix_client_socket $tail]
    puts $f $readBytes
    close $f    
}

proc ix_tc::readResponse {} {
    global ix_client_socket

    # read the length of the message
    gets $ix_client_socket length
    set resp [read $ix_client_socket $length]
    #ix_tc::logInfo "Response $resp "    
    while {$resp != "END"} {
        switch $resp {
            "protocol_error"
            {
                gets $ix_client_socket length
                set ::ix_tc::protocol_error [read $ix_client_socket $length]
            }
            "response"
            {
                gets $ix_client_socket length
                set ::ix_tc::cmd_output [read $ix_client_socket $length]
            }
            "system_error"
            {
                gets $ix_client_socket length
                set ::ix_tc::system_error [read $ix_client_socket $length]
            }
            "step_error"
            {
                gets $ix_client_socket length
                set ::ix_tc::step_error [read $ix_client_socket $length]
            }
            "return_variable"
            {
                gets $ix_client_socket length
                set ::ix_tc::cmd_return_var [read $ix_client_socket $length]
            }
            "step_timeout"
            {
                set ::ix_tc::step_timeout 1
            }
            "sessionId"
            {
                gets $ix_client_socket length
                set ::sessionId  [read $ix_client_socket $length]
                tsv::set tasks sessionId $::sessionId
            }
        }
        
        gets $ix_client_socket length
        set resp [read $ix_client_socket $length]
	    #ix_tc::logInfo "Response $resp"    
    }
}

proc ix_tc::send {step} {
    global ix_client_socket
    global cmd_done
    
    # send the step
    puts $ix_client_socket $step
    flush $ix_client_socket
        
    # wait for completion    
    readResponse
    
    if {[info exists ix_tc::system_error]} {
        logError "Protocol error: $ix_tc::system_error"
        unset ix_tc::system_error
    }    
    if {[info exists ix_tc::protocol_error]} {
        logError "Protocol error: $ix_tc::protocol_error"
        unset ix_tc::protocol_error
    }    
    if {[info exists ix_tc::cmd_output]} {
        logInfo "Command response: $ix_tc::cmd_output"
        unset ix_tc::cmd_output
    }
    if {[info exists ix_tc::step_error]} {
        logError "Command error: $ix_tc::step_error"
        unset ix_tc::step_error        
        ix_tc::processEvent "error"        
    }    
    if {[info exists ix_tc::step_timeout]} {
        unset ix_tc::step_timeout
        ix_tc::processEvent "timeout"        
    }
    
    if {[info exists ix_tc::cmd_return_var]} {
        uplevel 2 "$ix_tc::cmd_return_var"
        unset ix_tc::cmd_return_var
    }
}

proc ix_tc::sendTestFile {filename eventServerPort} {
    global ix_client_socket
    set size [file size $filename]    
    logInfo "Sending file = $filename size = $size"
    
    # add service id
    append packet "001"
    append packet "_____BEGIN_____"
    append packet "000" [format "%06d" [string length test]] test
    append packet "001" [format "%06d" [string length $filename]] $filename
    append packet "000" [format "%06d" [string length filename]] filename
    append packet "001" [format "%06d" [string length $filename]] $filename
    append packet "000" [format "%06d" [string length size]] size
    append packet "001" [format "%06d" [string length $size]] $size
    append packet "000" [format "%06d" [string length eventServerPort]] eventServerPort
    append packet "001" [format "%06d" [string length $eventServerPort]] $eventServerPort

    append packet "___END___"
    
    puts $ix_client_socket $packet
    flush $ix_client_socket    
    readResponse
    
    sendBinaryFile $filename
}

proc ix_tc::sendBinaryFile {filename} {
    global ix_client_socket

    fconfigure $ix_client_socket -buffering full -encoding binary -translation binary -blocking 1
    set bufferSize [expr {1024 * 1024}]
    set f [open $filename]    
    fconfigure $f -translation binary    
    while {1} {
        set data [read $f $bufferSize]
        if {[eof $f]} {
            puts -nonewline $ix_client_socket $data
            close $f
            break
        }        
        puts -nonewline $ix_client_socket $data
    }
    flush $ix_client_socket
    
    fconfigure $ix_client_socket -encoding ascii -buffering full -translation lf -blocking 1
    readResponse    
}

proc ix_tc::processEvent {eventType} {
    variable test_timeout
    variable test_error
    variable step_system_timeout_event
    variable step_system_error_event
    variable proc_timeout
    variable proc_error
    
    logInfo "Processing event : $eventType"
    set currentStackLevel [info level]
    
    if {[string equal $eventType "timeout"]} {        
        if {[info exists step_system_timeout_event]} {
            execEvent $step_system_timeout_event
        } elseif {$currentStackLevel - 4 > 0} {
            set procedure [info level [expr {$currentStackLevel - 4}]]
            if {[info exists proc_timeout($procedure)]} {
                execEvent $proc_timeout($procedure)
            }
            
        } elseif {[info exists test_timeout]} {
            execEvent $test_timeout
        }   
    } elseif {[string equal $eventType "error"]} {
        if {[info exists step_system_error_event]} {
            execEvent $step_system_error_event
        } elseif {$currentStackLevel - 4 > 0} {
            set procedure [info level [expr {$currentStackLevel - 4}]]
            if {[info exists proc_error($procedure)]} {
                execEvent $proc_error($procedure)
            }
            
        } elseif {[info exists test_error]} {
            execEvent $test_error
        }   
    }
}

proc ix_tc::execEvent {systemEvent} {
    array set evnt $systemEvent
    set procedure $evnt(-procedure)
    if {$procedure != ""} {
        logInfo "Execute procedure $procedure"
        uplevel 4 "$procedure"
    }
    
    set action $evnt(-action)
    if {[string equal $action "Exit Test"]} {
        error "The execution ended due to error or timeout event."
    }
}
