namespace eval ::ixia::util {}

##Internal Procedure Header
#
# Description:
#   Imports ixia namespace variables in the calling context
#
proc ::ixia::util::import_ixia_ns_variables {{operation "import"}} {
    set var_list [list      \
        executeOnTclServer  \
        new_ixnetwork_api   \
    ]

    switch -- $operation {
        "import" {
            foreach var_name $var_list {
                uplevel 1 [list variable ::ixia::$var_name]
            }
        }
    }
}

##Internal Procedure Header
#
# Description:
#   Upvar a list of variables
#   To be used in internal functions
#
proc ::ixia::util::upvar_variable_list {var_list} {
    foreach var_name $var_list {
        uplevel 1 [list upvar 1 $var_name $var_name]
    }
}

##Internal Procedure Header
#
# Description:
#   To be used at the begining of ixia::* public functions
#
proc ::ixia::util::proc_prolog { args } {
    set procLevel [expr [info level] - 1]
    set procName [lindex [info level $procLevel] 0]

    uplevel 1 "ixia::logHltapiCommand $procName $args"

    uplevel 1 {
        ixia::util::import_namespace_procs "::ixia::util" {
            import_ixia_ns_variables 
            make_error
            parse_dashed_args_prefixed
        }
        import_ixia_ns_variables
    }

    if {$ixia::executeOnTclServer} {
        set retValue [clientSend $::ixTclSvrHandle "$procName $args"]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    uplevel 1 "ixia::utrackerLog $procName $args"
}

##Internal Procedure Header
#
# Description:
#   Builds a dictionary with keys specifying that the calling function failed
#
proc ::ixia::util::make_error {log} {
    set caller [lindex [info level [expr [info level] - 1]] 0]
    keylset returnList status $::FAILURE
    keylset returnList log "ERROR in $caller: $log"
    return $returnList
}

##Internal Procedure Header
#
# Description:
#   Runs ixia::parse_dashed_args and generated prefixed variables in calling context
#
set ::ixia::util::parse_dashed_args_prefix_name "arg_"
set ::ixia::util::parse_dashed_args_noverif_prefix_name "argi_"

# this function should not change, it was manually optimized for best performance
# the average overhead over just calling ::ixia::parse_dashed_args is about 1ms (tcl bytecode caching disabled)
proc ::ixia::util::parse_dashed_args_prefixed {args} {
    # tcl 8.4
    if 1 "::ixia::parse_dashed_args $args"
    # tcl 8.5
    # ::ixia::parse_dashed_args {*}$args

    unset args
    foreach var_name [info vars] {
        uplevel 1 [list set ${::ixia::util::parse_dashed_args_prefix_name}$var_name [set $var_name]]
    }
}

##Internal Procedure Header
#
# Description:
#   Analogous to ixia::parse_dashed_args. Doesn't do verifications
#   Return void, throw exception on error
#

proc ::ixia::util::parse_dashed_args_no_verifs {args arg_list} {
    if {[llength $args] % 2 == 1} {
        error [make_error "Odd number of args"]
    }
    array set opts $args

    # mini parser
    set state "arg_name"
    set i 0
    set llen [llength $arg_list]

    set has_default 0
    set arg_name ""
    set parser_done 0

    # outputs
    array set known_names [list]
    array set create_values [list]

    while {!$parser_done} {
        set token [lindex $arg_list $i]
        switch -- $state {
            "arg_name" {
                if {[string range $token 0 0] != "-"} {
                    error [make_error "Invalid arg name $token"]
                }
                set arg_name $token
                if {[lindex $arg_list [expr $i+1]] == "DEFAULT"} {
                    set state "default"
                } else {
                    set state "arg_end"
                }
                incr i
            }
            "default" {
                set default_value [lindex $arg_list [incr i]]
                set has_default 1
                set state "arg_end"
                incr i
            }
            "arg_end" {
                if {[info exists opts($arg_name)]} {
                    set create_values($arg_name) $opts($arg_name)
                } elseif {$has_default} {
                    set create_values($arg_name) $default_value
                }
                
                set known_names($arg_name) 1
                set has_default 0
                set state "arg_name"

                if {$i == $llen} {
                    set parser_done 1
                }
            }
        }
    }

    # check for invalid args
    foreach {k v} $args {
        if {![info exist known_names($k)]} {
            error [make_error "Unknown arg name $k"]
        }
    }
    foreach k [array names known_names] {
        if {![info exists create_values($k)]} {
            set var_name [string range $k 1 end]
            set var_name "${::ixia::util::parse_dashed_args_noverif_prefix_name}$var_name"
            if {[uplevel 1 [list info exists $var_name]]} {
                # make sure this doesnt actually exist in the caller context
                # helps with debugging in case there are also local vars with the same name
                uplevel 1 [list unset $var_name]
            }
        }
    }

    # commit point, create the vars
    foreach {k v} [array get create_values] {
        set var_name [string range $k 1 end]
        set var_name "${::ixia::util::parse_dashed_args_noverif_prefix_name}$var_name"
        uplevel 1 [list set $var_name $v]
    }
}

proc ::ixia::util::import_namespace_procs {ns proc_list} {
    foreach proc_name $proc_list {
        uplevel 1 [list namespace import -force ${ns}::$proc_name]
    }
}

proc ::ixia::util::import_all_namespace_procs {ns} {
    if {$::tcl_version == "8.5"} {
        uplevel 1 [list namespace eval $ns {namespace ensemble create}]
    } else {
        uplevel 1 [list namespace import -force $ns::*]
    }
}

namespace eval ::ixia::util {
    namespace export import_ixia_ns_variables
    namespace export upvar_variable_list

    namespace export proc_prolog
    namespace export make_error

    namespace export parse_dashed_args_prefixed
    namespace export parse_dashed_args_no_verifs
}