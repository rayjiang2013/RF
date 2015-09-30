namespace eval ix_tc {}

proc ix_tc::attachLogger {logDir} {
    variable logFile
    set logFile [open "${logDir}/tcl_client_log.txt" "a"]
}

proc ix_tc::initLogger {} {
    variable logFile
    if {[catch {set th_id [tsv::keylget tasks th_str [thread::id]]}]} {
        global run_dir
        set timestamp [clock format [clock seconds] -format "%Y_%m_%d_%H_%M_%S"]
        global testname
        if {[info exists testname]} {
            set run_sub_dir [format "%s_%s" $timestamp $testname]
        } else  {
            set run_sub_dir $timestamp
        }
        set run_dir "./${ix_tc::results_dir}/$run_sub_dir"
        file mkdir $run_dir
        set logFile [open "${run_dir}/tcl_client_log.txt" "a"]
    
        # keep a mapping between the allocated threadId and an user friendly message
        tsv::keylset tasks th_str [thread::id] main
    }
}

proc ix_tc::closeLogger {} {
    if {[catch {set th_id [tsv::keylget tasks th_str [thread::id]]}]} {
        return
    }
    if {![string equal $th_id "main"]} {
        return;
    }
    variable logFile
    close $logFile
    tsv::keyldel tasks th_str [thread::id]
}

proc ix_tc::logInfo {msg} {
    ix_tc::log $msg INFO
}

proc ix_tc::logWarn {msg} {
    ix_tc::log $msg WARN
}

proc ix_tc::logDebug {msg} {
    ix_tc::log $msg DEBUG
}

proc ix_tc::logError {msg} {
    ix_tc::log $msg ERROR
}

proc ix_tc::getLogger {} {
    variable logFile
    return $logFile
}

proc ix_tc::setLogger {logger} {
    variable logFile
    set logFile $logger
}

proc ix_tc::sendOutMsg {args} {
    set tId [tsv::get tasks main]
    if {[llength $args] == 2} {
        set msg [lindex $args 1]
        thread::send -async $tId "puts -nonewline {$msg}"
    } else  {
        set msg [lindex $args 0]
        thread::send -async $tId "puts {$msg}"
    }    
}

proc ix_tc::log {msg level} {
    variable logFile
    
    set th_id "\[[tsv::keylget tasks th_str [thread::id]]\]"
    set timestamp [clock format [clock seconds] -format "%D %H:%M:%S"]
    set logMessage "$th_id $timestamp <${level}> $msg"    
    puts $logFile $logMessage
    flush $logFile
    if {[string equal $th_id "\[main\]"]} {
        if {[catch { puts "$logMessage" } err]} {
            puts "Logging error $err"
        }
        update        
    } else {
        sendOutMsg $logMessage
    }
}