namespace eval ix_tc {}

global isThreadEnabled
if {[catch {package require Thread} err]} {
    set isThreadEnabled 0
}

tsv::set tasks ready 1
tsv::set tasks auto_path $::auto_path

################################################################################
# Spawn a new procedure on a separate thread.
# The function returns after the execution context is prepared and the procedure is ready for execution
# 
# Args:
# - list of key-value pairs
# - -parallelName <parallelName>, unique identifier for the parallel procedure
# - -procedure <procedure>, the name of the procedure and arguments that will be executed in parallel
# - -returnVar <variableName>, the return variable if exists
# 
# Return:
# - the id of the thread executing the procedure
# 
################################################################################
proc ix_tc::spawn {args} {
    global isThreadEnabled
    if { !$isThreadEnabled } {
        ix_tc::logWarn "The step is not executed because the thread support is not enabled."
        return
    }
   
    set ready_mutex [thread::mutex create]
    set ready_cond [thread::cond create]

    set started_mutex [thread::mutex create]
    set started_cond [thread::cond create]
    
    logInfo "Spawn $args ... "    
    thread::mutex lock $ready_mutex
    while {![tsv::get tasks ready]} {
        logInfo "Waiting for acquire lock"
        thread::cond wait $ready_cond $ready_mutex
    }
    thread::mutex unlock $ready_mutex
    # lookup for all available procedures within the script and compute the proc body for beeing evaluated in
    # the interpreter of the events processor
    if {[catch {
        set script [info script]
        set f [open $script r]
        set hasProcs 0
        while {[gets $f line] >= 0} {
            if {[regexp {(\s*proc\s+)([a-zA-Z0-9:_!@#%^&*()=+,<>?\-]+)} $line _line _proc procName]} {
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
    
    tsv::set tasks ready 0
    tsv::set tasks started 0
    
    tsv::set tasks ready_cond $ready_cond
    tsv::set tasks started_cond $started_cond
    tsv::set tasks ready_mutex $ready_mutex
    tsv::set tasks started_mutex $started_mutex
    
    tsv::set tasks args $args
    tsv::set tasks logger $::run_dir
    tsv::set tasks parent [thread::id]
    tsv::set tasks testname $::testname
    tsv::set tasks testfile $::testfile
    
    set threadId [thread::create -joinable {
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
            
            if {[tsv::exists tasks procBody]} {
                set procBody [tsv::get tasks procBody]
                eval $procBody
                tsv::unset tasks procBody
            }
            
            set ready_mutex [tsv::get tasks ready_mutex]
            set ready_cond [tsv::get tasks ready_cond]
            set started_mutex [tsv::get tasks started_mutex]
            set started_cond [tsv::get tasks started_cond]
            
            set args [tsv::get tasks args]            
            set run_dir [tsv::get tasks logger]
            set parent [tsv::get tasks parent]
            set testname [tsv::get tasks testname]
            set testfile [tsv::get tasks testfile]

            # parse the arguments
            array set arg_vars $args
            set name $arg_vars(-parallelName)
            set procedure $arg_vars(-exec)
            if {[catch {set var $arg_vars(-returnVar)} err]} {set var ""}
            
            # mapping between the parallelName and the tcl thread id
            tsv::keylset tasks ids $name [thread::id]
            tsv::keylset tasks th_str [thread::id] $name

            #### loading the ix_tc package
            set ::auto_path [tsv::get tasks auto_path]
            package require ix_tc            
            ix_tc::attachLogger $run_dir
            
            set cre_host [tsv::get tasks cre_host]
            set cre_port [tsv::get tasks cre_port]
            ix_tc::connect $cre_host $cre_port
            
            set sessionId [tsv::get tasks sessionId]
            ix_tc::spawnTest $sessionId
                
            thread::mutex lock $started_mutex
            tsv::set tasks started 1
            thread::cond notify $started_cond
            thread::mutex unlock $started_mutex

            thread::mutex lock $ready_mutex
            tsv::set tasks ready 1
            thread::cond notify $ready_cond
            thread::mutex unlock $ready_mutex
            
            if {[catch {
                if {$var != ""} {
                    set ret [eval $procedure]
                    # that's a procedure
                    if {$ret != ""} {
                        tsv::keylset tasks $parent $var $ret
                    } else {
                        # that's a step executed in parallel
                        foreach var [split $var] {
                            tsv::keylset tasks $parent $var [set $var]
                        }
                    }
                } else {
                    eval $procedure
                }
                ix_tc::disconnect
                
            } err]} {
                ix_tc::logError "Error during the $name execution: $err"
                ix_tc::disconnect
            }
        }
    ]   
    
    thread::mutex lock $started_mutex
    while {![tsv::get tasks started]} {
        logInfo "Waiting for thread to be started."
        thread::cond wait $started_cond $started_mutex
    }
    thread::mutex unlock $started_mutex    
    
    array set arg_vars $args    
    if {[catch {set var $arg_vars(-returnVar)} err]} {set var ""}
    if {$var != ""} {
        foreach _var [split $var] {
            uplevel "trace add variable $_var read ix_tc::var"
        }        
    }

    logInfo "Thread started $args ."
    return $threadId
}


################################################################################
# Callback registered with the trace command on the result variable.
# 
# Args:
#     - name1, name of the variable
#     - name2 is empty as the result variable is not an array
#     - op, the operation on the registered variable
#     
################################################################################
proc ix_tc::var {name1 name2 op} {    
    upvar $name1 var
    set threadId [thread::id]
    if { [catch {set value [tsv::keylget tasks $threadId $name1]}] } {
        #logInfo "Unable to read the variable $name1"
        return
    }    
    
    set var $value
}


#######################################################
# Join the threads received as arguments.
# The threads are semicolon separated, e.g.: "t1; t2"
# Args:
#     - threads, the thread this command is waiting for
#######################################################
proc ix_tc::join {threads args} {
    global isThreadEnabled
    if { !$isThreadEnabled } {
        ix_tc::logWarn "The step is not executed because the thread support is not enabled."
        return
    }
    
    set forceKill 0
    if {$args != ""} {
        array set arg_vars $args
        # validation routine
        foreach key [array names arg_vars] {
            if {![string equal $key "-forceKill"]} {
                logError "Join args error: unknown option $key"
            }
        }
        if {[info exists arg_vars(-forceKill)]} {
            set forceKill $arg_vars(-forceKill)
        }
    }
    
    foreach _thread [split $threads ";"] {
        set thread [string trim $_thread]
        if {$thread == ""} {
            continue
        }        
        if { [catch {set vThread [tsv::keylget tasks ids $thread]} err]} {
            logInfo "The thread $thread is already completed - no need for join."
            continue
        }
        
        logInfo "Join on thread $thread $vThread ."
        set isAlive 0
        foreach th [thread::names] {
            if {$th == $vThread} {
                set isAlive 1
            }
        }
        if {$isAlive} {
            if {$forceKill} {
                thread::release $vThread
            } else  {
                thread::join $vThread
            }
            logInfo "Join on thread $thread $vThread completed."
        } else  {
            logWarn "The thread $thread $vThread is not alive."
        }
    }
}


proc getProcedureBody {args} {
    # the received argumens should be like a regular procedure call format <procedureName> <arg1> <arg2> ... <argn>
    set args [string trimleft $args "{"]
    set args [string trimleft $args "}"]        
    set procCall [split $args " "]
    set procName [lindex $procCall 0]
    
    if {[string trimleft [info commands $procName] ":"] != $procName} {
        return 0
    }    
    set procNamespace [lindex [split $procName ":"] 0] 
    if {$procNamespace != $procName} {
        append procedure "namespace eval $procNamespace {}" "\n"
    }
    
    set listArgs [info args $procName]
    append procSignature "proc $procName {"
    foreach arg $listArgs {
        if {[info default $procName $arg argDefaultValue]} {
            append procSignature " {" $arg " {" $argDefaultValue "} } "
        } else  {
            # no default value
            append procSignature $arg " "
        }        
    }
    append procSignature " } {"    
    append procedure $procSignature "\n"
    append procedure [info body $procName]
    append procedure "\n" "}"
    
    return $procedure
}

################################################################################
# proc ix_tc::spawn {args} {
#     puts "ARGS $args"    
#     if { [catch {open "| \"[info nameofexecutable]\" tcl_client_spawn.tcl $::testname $args 2>@stdout" r+} ::pipe] } {
#         puts "ERROR: cannot open pipe"
#     }    
#     fconfigure $::pipe -buffering none
#         
#     set threadId [thread::create]
#     thread::transfer $threadId $::pipe
#     thread::send $threadId [list set fid $::pipe]
#     
#     thread::send -async $threadId {        
#         while { [gets $fid data] >= 0 } {            
#             puts $data
#         }
#     }    
# }
# 
################################################################################

################################################################################
# 
# proc ix_tc::spawn {args} {   
#     set ready_mutex [thread::mutex create]
#     set ready_cond [thread::cond create]
# 
#     set started_mutex [thread::mutex create]
#     set started_cond [thread::cond create]
#     
#     logInfo "Spawn $args ... "    
#     thread::mutex lock $ready_mutex
#     while {![tsv::get tasks ready]} {
#         logInfo "Waiting for acquire lock"
#         thread::cond wait $ready_cond $ready_mutex
#     }
#     thread::mutex unlock $ready_mutex
#     
#     tsv::set tasks ready 0
#     tsv::set tasks started 0
#     
#     tsv::set tasks ready_cond $ready_cond
#     tsv::set tasks started_cond $started_cond
#     tsv::set tasks ready_mutex $ready_mutex
#     tsv::set tasks started_mutex $started_mutex
# 
#     tsv::set tasks args $args
#     tsv::set tasks logger $::run_dir    
#     
#     set threadId [thread::create -joinable {
#             
#             proc exit_thread {} {
#                 global i1
#                 #interp eval $i1 {ix_tc::disconnect}
#                 interp delete $i1
#                 
#                 puts "!!!!!!!!!!!!!!!!! EXIT THREAD "
#             }
#             
#             set ready_mutex [tsv::get tasks ready_mutex]
#             set ready_cond [tsv::get tasks ready_cond]
#             
#             set started_mutex [tsv::get tasks started_mutex]
#             set started_cond [tsv::get tasks started_cond]
#             
#             set args [tsv::get tasks args]            
#             set run_dir [tsv::get tasks logger]
#             
#             global i1
#             set i1 [interp create]
#             tsv::lappend tasks interps $i1
#             tsv::lappend tasks threads [thread::id]
#             tsv::keylset tasks ids [lindex $args 0] [thread::id]
#             tsv::keylset tasks th_str [thread::id] [lindex $args 0]
# 
#             source {./tcl_client_logger.tcl}
#             ix_tc::initLogger $run_dir            
#             ix_tc::logInfo "Starting $args"
# 
#             #### global test variables
#             interp eval $i1 {set testname test_sg}
#             interp eval $i1 {set testfile test_sg.tcp}
#             interp eval $i1 "set run_dir $run_dir"
#         
#             #### loading the ix_tc package
#             interp eval $i1 {source {./tcl_client_logger.tcl}}
#             interp eval $i1 {source {./tcl_client_step.tcl}}
#             interp eval $i1 {source {./tcl_client_comm.tcl}}
#             interp eval $i1 {source {./tcl_client_parallelism.tcl}}
#             interp eval $i1 {source {./tclLib.tbc}}
#         
#             #### source the procedures file
#             interp eval $i1 {source {./test_sg_procs.tcl}}
#             
#             #interp transfer {} $logger $i1
#             
#             interp eval $i1 {ix_tc::initLogger $run_dir}
#             interp eval $i1 {ix_tc::connect localhost 11001}
#             interp eval $i1 {ix_tc::spawnTest $::testname}
#                 
#             thread::mutex lock $started_mutex
#             tsv::set tasks started 1
#             thread::cond notify $started_cond
#             thread::mutex unlock $started_mutex
# 
#             thread::mutex lock $ready_mutex
#             tsv::set tasks ready 1
#             thread::cond notify $ready_cond
#             thread::mutex unlock $ready_mutex
#     
#             interp eval $i1 "set cmd \"[lrange $args 1 end]\""
#             interp eval $i1 {eval $cmd}
#             
#             interp eval $i1 {ix_tc::disconnect}
#             interp delete $i1
#         }
#     ]
#     
#     thread::mutex lock $started_mutex
#     while {![tsv::get tasks started]} {
#         logInfo "Waiting for thread to be started."
#         thread::cond wait $started_cond $started_mutex
#     }
#     thread::mutex unlock $started_mutex    
#     
#     return $threadId
# }
# 
# 
################################################################################