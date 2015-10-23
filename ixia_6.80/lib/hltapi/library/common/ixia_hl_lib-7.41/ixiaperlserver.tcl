#
#
#
lappend ::auto_path \
    [file normalize [file dirname [info script]]]
lappend ::auto_path \
    [file normalize [file join [file dirname [info script]] ..]]
lappend ::auto_path \
    [file normalize [file join [file dirname [info script]] .. ..]]
lappend ::auto_path \
    [file normalize [file join [file dirname [info script]] .. .. ..]]
lappend ::auto_path \
    [file normalize [file join [file dirname [info script]] .. .. .. ..]]
puts stderr $::auto_path

package require comm
package require snit

namespace eval ::ix_psvr {}

snit::type ::ix_psvr::session_service {
    option -ephemeral-port-first 49152
    option -ephemeral-port-last 65535
    option -make-session 1
    option -portmap-service-port 5678
    method trace {s} { puts stderr "$self: $s" }
    method log {s} { puts stderr "$self: $s" }
    constructor {args} { 
        $self configurelist $args 
    }
    method alloc_port {} {
        set found_p -1
        set p [$self cget -ephemeral-port-first]
        set last_p [$self cget -ephemeral-port-last]
        while {$p <= $last_p} {
            set failed [catch {
                ::comm::comm config -local 0 -listen 1 -port $p
            } result]
            if {$failed} {
                incr p
            } else {
                set found_p $p
                break
            }
        }
        return $found_p
    }
    method run {args} {
        set failed [catch {$self alloc_port} p]
        if {$failed} {
            set h $p/$::errorInfo 
            set p -2
        } else {
            set p 
            # special value that means use the same host that the portmap
            # server itself is on
            set h "use.portmap.server"
        }
        puts stdout $h:$p; flush stdout
        # if we could not find a port, exit
        if {$p < 0} {exit 0}
        # as soon as the (first) connection is lost we are done
        ::comm::comm hook lost { exit 0 }
        set ::ix_psvr::sessionwaitvar {-1 ???}
        vwait ::ix_psvr::sessionwaitvar
        exit 0
    }
}

proc ::bgerror {args} {
    puts stderr "bgerror: $args"
    puts stderr "----------------------------------------------------------"
    puts stderr "$::errorInfo\n"
    puts stderr "----------------------------------------------------------"
}


proc ::ix_psvr::rdr {f} {
    if {[eof $f]} {
        catch {close $f}
        #puts stderr "closed session chan $f"
    } else {
        if {![catch {gets $f ln} r]} {
            if {$r >= 0} { puts stdout $ln }
        }
    }
}

snit::type ::ix_psvr::portmap_service {
    option -portmap-service-port 5678
    option -ephemeral-port-first 49152
    option -ephemeral-port-last 65535
    option -make-session 0

    constructor {args} { 
        $self configurelist $args 
    }

    method trace {s} { puts stderr "$self: $s" }
    method log {s} { puts stderr "$self: $s" }
    method run {} {
        ::comm::comm config -local 0 -listen 1 \
            -port $options(-portmap-service-port)
        $self log "starting: [array get options]"

        set p [$self cget -portmap-service-port]
        set ::ix_psvr::portmap_waitvar_$p [list -1 "???"]
        vwait ::ix_psvr::portmap_waitvar_$p
        set l [set ::ix_psvr::portmap_waitvar_$p]

        $self log "exiting [lindex $l 1]"
        exit [lindex $l 0]
    }
    method new_session {args} {
        if {[llength $args] == 1} {set args [lindex $args 0]}
        array set o {
        }; array set o $args
        $self trace "new session start [array get o]"


        lappend cmd [file normalize [info nameofexecutable]] [info script]
        set cmd [concat $cmd [array get options]]
        lappend cmd -make-session 1
        set cmd "|$cmd" 
        #$self log "command is: $cmd"
        set fin [open $cmd "r+"]
        set session_comm_id [gets $fin]
        fconfigure $fin -blocking 0
        fileevent $fin readable [list ::ix_psvr::rdr $fin]

        #$self trace "session comm_id is [list $session_comm_id]"
        #$self trace "new session end"
        return $session_comm_id
    }
}

array set _tmp_opts {
    -tcl-init-command ""
    -make-session 0 
    -portmap-service-port 5678
}; array set _tmp_opts $::argv

if {[string length $_tmp_opts(-tcl-init-command)]} {
    proc console {args} {}; proc wm {args} {}
    set savedir [pwd];
    eval $_tmp_opts(-tcl-init-command)
    cd $savedir
}
unset _tmp_opts(-tcl-init-command)

if {!$_tmp_opts(-make-session)} {
    # we are running as the port mapper
    # we are running as a session
    set o [eval [concat [list ::ix_psvr::portmap_service \
        ::ix_psvr::portmap.$_tmp_opts(-portmap-service-port)] \
        [array get _tmp_opts]]]
    $o run 
} else {
    # we are running as a session
    set o [eval [concat [list ::ix_psvr::session_service %AUTO%] \
        [array get _tmp_opts]]]
    $o run 
}
