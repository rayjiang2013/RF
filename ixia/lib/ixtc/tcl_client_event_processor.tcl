namespace eval ix_tc {}

#package require Thread

################################################################################
# Starts a dedicated thread for processing the received user events
# 
################################################################################
proc ix_tc::startProcessor {} {
    variable workerThread
    tsv::set tasks testname $::testname
    tsv::set tasks testfile $::testfile
    tsv::set tasks events_ready 0
    
    # lookup for all available procedures within the script and compute the proc body for beeing evaluated in
    # the interpreter of the events processor
    if {[catch {
        
        
        set script [info script]
        set f [open $script r]
        set hasProcs 0
        while {[gets $f line] >= 0} {
            if {[regexp {(^\s*proc\s+)([a-zA-Z0-9:_!@#%^&*()=+,<>?\-]+)} $line _line _proc procName]} {
                lappend procs $procName
                set hasProcs 1            
            }        
        }
        close $f    
        if {$hasProcs} {
            foreach _proc $procs {
                set procBody [getProcedureBody $_proc]
                if {$procBody != 0} {
                    append procedures $procBody "\n"
                } else  {
                    ix_tc::logWarn "Unable to load the procedure $_proc into the events processor interpreter."
                }
            }
            tsv::set tasks procBody $procedures
        }
    } err]} {
        ix_tc::logWarn "Unable to load the procedures into the events processor interpreter."
    }
        
    set workerThread [thread::create {
        # redefine the puts on the thread's interpreter
        # wish console doesn't have 'real' stdout per thread's intrepreter
        # all the the puts calls are redirected to the maint thread
        rename puts putsOld
        proc puts {args} {
            if {[llength $args] > 3 || [llength $args] == 0} {
                error "Invalid number of arguments"
                return
            }
            
            if {[string equal [lindex $args 0] "-nonewline"]} {
                if {[llength $args] > 2} {
                    putsOld -nonewline [lindex $args 1] [lindex $args 2]
                } else  {
                    ix_tc::sendOutMsg -nonewline [lindex $args 1]
                }
            } else  {
                if {[llength $args] > 1} {
                    putsOld [lindex $args 0] [lindex $args 1]
                } else  {
                    ix_tc::sendOutMsg [lindex $args 0]
                }                
            }
        }        
        
        
        tsv::keylset tasks th_str [thread::id] "Events Processor"        
        set run_dir [tsv::get tasks logger]
        set testname [tsv::get tasks testname]
        set testfile [tsv::get tasks testfile]
        
        #### loading the ix_tc package
        set ::auto_path [tsv::get tasks auto_path]
        package require ix_tc
        ### load the procedures available for events
        if {[tsv::exists tasks procBody]} {
            set procBody [tsv::get tasks procBody]
            eval $procBody
        }

        ix_tc::attachLogger $run_dir
        ix_tc::logInfo "Waiting for events ... $testname "


        set cre_host [tsv::get tasks cre_host]
        set cre_port [tsv::get tasks cre_port]
        ix_tc::connect $cre_host $cre_port
        
        set sessionId [tsv::get tasks sessionId]
        ix_tc::spawnTest $sessionId
        tsv::set tasks events_ready 1
        
        thread::wait
    }]    
    
    while {! [tsv::get tasks events_ready]} {
        after 500
        update
    }
    tsv::set tasks runner_id $workerThread
}


################################################################################
# Start the TCP server waiting for connection signalling user events occurances
################################################################################
proc ix_tc::startEventServer {port} {
    variable srvThreadId
    
    tsv::set tasks logger $::run_dir
    tsv::set tasks port $port
    tsv::set tasks sock_ready 0
    set srvThreadId [thread::create {
        tsv::keylset tasks th_str [thread::id] "Events Server"
        set run_dir [tsv::get tasks logger]
        
        #loading the ix_tc package (logging reasons)
        set ::auto_path [tsv::get tasks auto_path]
        package require ix_tc
        ix_tc::attachLogger $run_dir

        proc readEvent {sock} {            
            if { [catch {gets $sock line} len] || [eof $sock] } {
                catch {close $sock}
                #thread::release
            } else {
                ix_tc::logInfo "Execution event $line"
                if {[tsv::exists tasks runner_id]} {
                    set runner [tsv::get tasks runner_id]
                    thread::send $runner [list eval $line]                    
                } else  {
                    ix_tc::logWarn "The even is not executed because the asynchronous events processing behavior is not enabled."
                }
            }
        }

        proc clientConnect {channel clientaddr clientport} {
            ix_tc::logInfo "Connection accepted from CRE."
            fconfigure $channel -buffering line -blocking 0
            fileevent $channel readable [list readEvent $channel]
        }
        
        proc _clientConnect {channel clientaddr clientport} {
            after 0 [list clientConnect $channel $clientaddr $clientport]
        }
        
        set port [tsv::get tasks port]
        if {[tsv::exists tasks sockError]} {
            tsv::unset tasks sockError
        }        
        if {[catch {set eventServer [socket -server _clientConnect $port]} err]} {
            tsv::set tasks sockError $err
            tsv::set tasks sock_ready 1
        } else  {
            tsv::set tasks sock_ready 1
            ix_tc::logInfo "Waiting for processing events on TCP port $port ."
            thread::wait
        }
    }]
    
    while {! [tsv::get tasks sock_ready]} {
        after 500
    }
    
    if {[tsv::exists tasks sockError]} {        
        return [tsv::get tasks sockError]
    } else  {
        return 0
    }
}


################################################################################
# Close the server socket waiting for user events
################################################################################
proc ix_tc::stopEventListener {} {
    variable srvThreadId
    thread::send $srvThreadId {close $eventServer}
    thread::release $srvThreadId
    
    variable workerThread
    thread::send $workerThread {ix_tc::disconnect}
    thread::release $workerThread    
}