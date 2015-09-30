
namespace eval ::ixia::session_resume {
    variable inited             0
    variable use_tdom           0
    variable xml_doc            {}
    variable xml_root           {}
    variable show_warning       1
    
    variable session_resume_include_filter {}
}

package req struct::list

##Internal Procedure Header
#
# Description:
#   Checks if 2 dom nodes are equal
#
proc ::ixia::session_resume::dom_equal_nodes {elem1 elem2} {
    # variable names for xml nodes are all different, based on mem ptr
    # so we can just compare names instead of deep comparison, is faster
    return [expr ![string compare $elem1 $elem2]]
}

##Internal Procedure Header
#
# Description:
#   Returns the equivalent ::ixNet::OBJ-/* handle for the given dom node
#
proc ::ixia::session_resume::dom_get_ixnhandle {dom_elem} {
    if {!$::ixia::session_resume::inited} {
        error "::ixia::session_resume::dom_get_ixnhandle without initialization"
    }
    if {![$dom_elem hasAttribute SDMObjId]} {
        # var name string comparison, see 
        if {[dom_equal_nodes $dom_elem [$::ixia::session_resume::xml_doc documentElement]]} {
            return "::ixNet::OBJ-/"
        } else {
            return "::ixNet::OBJ-null"
        }
    }
    return ::ixNet::OBJ-[$dom_elem @SDMObjId]
}

##Internal Procedure Header
#
# Description:
#   Returns a xml dom node by given ::ixNet::OBJ-/* handle or empty if none is found
#
proc ::ixia::session_resume::dom_get_node_by_ixnhandle {ixnhandle} {
    if {!$::ixia::session_resume::inited} {
        error "::ixia::session_resume::dom_get_node_by_ixnhandle without initialization"
    }

    # remove prefix
    if {[string first ::ixNet::OBJ-/ $ixnhandle] == 0} {
        set ixnhandle [string range $ixnhandle 13 end]
    }

    # should only return one item if the xml is correctly constructed
    return [$::ixia::session_resume::xml_doc selectNodes //SDMObject\[@SDMObjId='$ixnhandle'\]]
}

##Internal Procedure Header
#
# Description:
#   Returns an attribute of the given dom elem
#
proc ::ixia::session_resume::dom_get_attribute {dom_elem attribute} {
    if {!$::ixia::session_resume::inited} {
        error "::ixia::session_resume::dom_get_attribute without initialization"
    }

    set attribute [string trimleft $attribute -]
    return [$dom_elem getAttribute $attribute]
}

##Internal Procedure Header
#
# Description:
#   Returns the given dom element's children that have a specific type
#
proc ::ixia::session_resume::dom_get_child_list {dom_elem child_type} {
    if {!$::ixia::session_resume::inited} {
        error "::ixia::session_resume::dom_get_child_list without initialization"
    }

    # using xpath because it is handled by tdom in C which is faster than TCL regex
    set xq "SDMObject\[@SDMObjIdPiece='$child_type'\]"
    return [$dom_elem selectNodes $xq]
}

##Internal Procedure Header
#
# Description:
#   Returns the dom element that is a parent to the argument.
#   The 2nd argument specifies the parent type, it may exist on any ancestry level
#
proc ::ixia::session_resume::dom_get_parent {elem parent_name} {
    if {!$::ixia::session_resume::inited} {
        error "::ixia::session_resume::dom_get_parent without initialization"
    }

    variable xml_root
    if {$parent_name == ""} {
        # get one level up
        if {[dom_equal_nodes $elem $xml_root]} {
            return ""
        } else {
            return [$elem parentNode]
        }
    }

    # this method is faster than xpath selection by manipulating the ixnhandle string
    # also, apparently this is needed to accept any ancestor, including self
    set cnode $elem
    while {![dom_equal_nodes $cnode $xml_root]} {
        set path [dom_get_ixnhandle $cnode]
        set tail [lrange [split $path /] end end]
        if {[lindex [split $tail :] 0] == $parent_name} {
            return $cnode
        }
        set cnode [$cnode parentNode]
    }

    return $xml_root
}

##Internal Procedure Header
#
# Description:
#   Checks if element is a valid dom object
#
proc ::ixia::session_resume::dom_is_valid_obj {elem} {
    if {!$::ixia::session_resume::inited} {
        error "::ixia::session_resume::dom_is_valid_obj without initialization"
    }
    
    return [expr ![dom_equal_nodes $elem ""]]
}

##Internal Procedure Header
#
# Description:
#   Returns all dom elements with given typepath
#
proc ::ixia::session_resume::dom_get_objs_with_typepaths {type_paths tp_ixn_obj_ref} {
    if {!$::ixia::session_resume::inited} {
        error "::ixia::session_resume::dom_get_objs_with_typepaths without initialization"
    }

    upvar 1 $tp_ixn_obj_ref tp_ixn_obj
    catch {array unset tp_ixn_obj}
    array set tp_ixn_obj [list]

    # the array is built hierarchically, this ensures non-overlapping parsing
    set type_paths [lsort -unique $type_paths]

    set done_paths [list]

    set len [llength $type_paths]
    for {set i 0} {$i < $len} {incr i} {
        set curr_path [lindex $type_paths $i]
        set cpath_parts [split $curr_path /]
        set parts_len [llength $cpath_parts]

        variable xml_root
        for {set j 0} {$j < $parts_len} {incr j} {

            set curr_path_part [lindex $cpath_parts $j]
            set partial_path [join [lrange $cpath_parts 0 $j] /]
            if {[lsearch $done_paths $partial_path] == -1} {
                # get parents for this typepath
                set prev_path [join [lrange $cpath_parts 0 [expr $j-1]] /]
                set prev_obj_list [list $xml_root]
                if {[llength $prev_path]} {
                    if {![info exists tp_ixn_obj($prev_path)]} {
                        # force exit loop because none of the children will exist
                        set j $parts_len
                        continue
                    }
                    set prev_obj_list $tp_ixn_obj($prev_path)
                }
                
                # got the list of all objects/dom with the parent path, now add them
                set all_children_of_type [list]
                foreach dom_elem $prev_obj_list {
                    set all_children_of_type [concat \
                        $all_children_of_type \
                        [dom_get_child_list $dom_elem $curr_path_part] \
                    ]
                }

                # no children, no array entry
                if {[llength $all_children_of_type]} {
                    set tp_ixn_obj($partial_path) $all_children_of_type
                }
                lappend done_paths $partial_path
            }
        }
    }

    # free some memory
    foreach tp [array names tp_ixn_obj] {
        if {[lsearch $type_paths $tp] == -1} {
            unset tp_ixn_obj($tp)
        } else {
            set tp_ixn_obj($tp) [lsort -unique $tp_ixn_obj($tp)]
        }
    }
}

##Internal Procedure Header
#
# Description:
#   Makes a temporary filename in the OS's temp directory
#   If connected to a remote tcl server, will return a remote filename
#   If not, a local filename
#
proc ::ixia::session_resume::util_make_temp_filename {{fn_prefix ""} {force_make_local 0}} {
    set commands {
        {set tmpdir [pwd]}
        {if {[file exists "/tmp"]} {set tmpdir "/tmp"}}
        {catch {set tmpdir $::env(TMP)}}
        {catch {set tmpdir $::env(TEMP)}}
    }
    lappend commands [subst -nocommands {return [file join \$tmpdir [join [list $fn_prefix [pid] [clock seconds]] _]]}]

    set remote_execution [expr ![::ixia::session_resume::util_is_executing_locally_on_ixnet_win]]

    foreach cmd $commands {
        if {$remote_execution && !$force_make_local && [info exists ixTclSvrHandle]} {
            set retValue [ \
                if {![info exists ::ixTclSvrHandle]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Not connected to TclServer."
                    return $returnList
                }
                eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                "\{$cmd\}" \
            ]
        } else {
            eval $cmd
        }
    }
    # only interested in the last returned value
    if {$remote_execution && [info exists ixTclSvrHandle]} {
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    } 
}
##Internal Procedure Header
#
# Description:
#   Returns 1 if the code is executing on the IxNetwork windows machine
#   NOTE: This assumes that the current computer has only one NIC and that it's connected
#
proc ::ixia::session_resume::util_is_executing_locally_on_ixnet_win {} {
    # !check if unix machine, IxNetwork doesnt work on unix
    if {[isUNIX]} {
        return 0
    }
    
    # get the hostname and remove the DNS part 
    # the above section was added to work also in environments without DNS resolution
    set hostNamefromIxN [lindex [split [ixNet getA /eventScheduler -hostName] .] 0]
    set hostNamefromTcl [lindex [split [info hostname] .] 0]
    
    #compare the hostname from IxNetwork with the local hostname
    ::ixia::debug "IxNetwork hostname is $hostNamefromIxN and local hostname is $hostNamefromTcl"
    if { [string compare -nocase $hostNamefromIxN $hostNamefromTcl] != 0} {
        return 0
    }
    return 1
}
##Internal Procedure Header
#
# Description:
#   Copies the remote_file_name to a local location $file_path (or system temp dir)
#   The local file will have a $file_name derived name
#
proc ::ixia::session_resume::util_make_file_local {remote_file_name {file_name {}}} {
    # assume running locally
    set ret $remote_file_name
    if {[file exists $ret]} {
        return $ret
    }
    if {![::ixia::session_resume::util_is_executing_locally_on_ixnet_win]} {
        set localfn $file_name
        if {$localfn == ""} {
            # make a local temp file
            set localfn [::ixia::session_resume::util_make_temp_filename "" 1]
        }
        # copy the remote file locally
        ixNet exec copyFile \
            [ixNet readFrom $remote_file_name -ixNetRelative] \
            [ixNet writeTo $localfn -overwrite]
        
        if {![file exists $localfn]} {
            return ""
        }
        
        # the file is now local
        set ret $localfn
    } elseif {![file exists $remote_file_name]} {
        # If IxNetwork TCL Server is running on local machine
        return ""
    }
    
    return $ret
}

# @exported
##Internal Procedure Header
#
# Description:
#   Checks if 2 objects are equal. They may be dom elements or ixNet handles
#
proc ::ixia::session_resume::sr_equal_obj {elem1 elem2} {
    if {$::ixia::session_resume::use_tdom} {
        return [dom_equal_nodes $elem1 $elem2]
    } else {
        return [expr ![string compare $elem1 $elem2]]
    }
}

# @exported
##Internal Procedure Header
#
# Description:
#   If elem is dom elem: returns the equivalent ::ixNet::OBJ-/* handle for the given dom node
#   If elem is ixNet handle: returns the handle
#
proc ::ixia::session_resume::sr_get_ixnhandle {elem} {
    if {$::ixia::session_resume::use_tdom} {
        set rval [struct::list mapfor x $elem {
            dom_get_ixnhandle $x
        }]
        # hack because ixNet doesnt properly quote the output
        if {[string first "\\\"" $rval]} {
            set rval [regsub -all {\\\"} $rval "\""]
        }
        return $rval
    } else {
        return $elem
    }
}

# @exported
##Internal Procedure Header
#
# Description:
#   If elem is dom elem: returns a xml dom node by given ::ixNet::OBJ-/* handle or empty if none is found
#   If elem is ixNet handle: returns the handle
#
proc ::ixia::session_resume::sr_get_node_by_ixnhandle {elem} {
    if {$::ixia::session_resume::use_tdom} {
        return [dom_get_node_by_ixnhandle $elem]
    } else {
        return $elem
    }
}

# @exported
# @exported
##Internal Procedure Header
#
# Description:
#   Returns the xml dom root if use_tdom is 1, else ixNet root
#
proc ::ixia::session_resume::sr_get_root {} {
    if {$::ixia::session_resume::use_tdom} {
        return $::ixia::session_resume::xml_root
    } else {
        return "::ixNet::OBJ-/"
    }
}

# @exported
##Internal Procedure Header
#
# Description:
#   Returns an attribute of the given elem. It may be a dom element or ixNet handle
#
proc ::ixia::session_resume::sr_get_attribute {elem attribute} {
    if {$::ixia::session_resume::use_tdom} {
        return [dom_get_attribute $elem $attribute]
    } else {
        return [ixNet getAttribute $elem $attribute]
    }
}

# @exported
##Internal Procedure Header
#
# Description:
#   Returns the given element's children that have a specific type
#
proc ::ixia::session_resume::sr_get_child_list {elem child_type} {
    if {$::ixia::session_resume::use_tdom} {
        return [dom_get_child_list $elem $child_type]
    } else {
        return [ixNet getList $elem $child_type]
    }
}

# @exported
##Internal Procedure Header
#
# Description:
#   Returns the element that is a parent to the argument.
#   The 2nd argument specifies the parent type, it may exist on any ancestry level
#
proc ::ixia::session_resume::sr_get_parent {elem {parent_name ""}} {
    if {$::ixia::session_resume::use_tdom} {
        return [dom_get_parent $elem $parent_name]
    } else {
        return [::ixia::ixNetworkGetParentObjref $elem $parent_name]
    }
}

# @exported
##Internal Procedure Header
#
# Description:
#   Checks if element is a valid dom object if use_tdom is 1 or is not ixNet null
#
proc ::ixia::session_resume::sr_is_valid_obj {elem} {
    if {$elem == ""} {
        return 0
    }
    if {$::ixia::session_resume::use_tdom} {
        return [dom_is_valid_obj $elem]
    } else {
        # this is limited to actual usage, it doesnt check for ::ixNet::OBJ- form
        return [string compare $elem "::ixNet::OBJ-null"]
    }
}

# @exported
##Internal Procedure Header
#
# Description:
#   Returns all elements with given typepath
#
proc ::ixia::session_resume::sr_get_objs_with_typepaths {type_paths tp_ixn_obj_ref} {
    upvar 1 $tp_ixn_obj_ref tp_ixn_obj
    if {$::ixia::session_resume::use_tdom} {
        dom_get_objs_with_typepaths $type_paths tp_ixn_obj
    } else {
        ::ixia::get_ixn_obj_list_filtered $type_paths tp_ixn_obj
    }
}

# @exported
##Internal Procedure Header
#
# Description:
#   Initializes the session_resume variables and checks whether the package tdom is available.
#   If so, it uses the ixNet serialize to generate an xml and parses it to xml_dom. Subsequent
#   sr_* commands will use the dom.
#   If not, the sr_* commands will default to ixNet commands
#   May be called multiple times
#
proc ::ixia::session_resume::sr_initialize {{mode "session_resume"} {filter_req_list {}}} {
    if {$::ixia::session_resume::inited} {
        return
    }
    
    if {[catch {package req tdom}]} {
        set ::ixia::session_resume::inited          1
        if {$::ixia::session_resume::show_warning} {
            set ::ixia::session_resume::show_warning  0
            puts "Warning: Tcl package tdom could not be found. Installing tdom\
                    package will improve performance for session resume and session\
                    info features."
        }
        return
    }
    set ::ixia::session_resume::use_tdom 1

    proc build_filter {filter_array_ref} {
        upvar $filter_array_ref filter_array

        set filter_list_all [list]
        foreach cmd [info commands ::ixia::session_resume::filter_build::*] {
            set filter_list_all [concat $filter_list_all [eval $cmd]]
        }

        array set tp_attr_array {}
        foreach {type_path attr_list} $filter_list_all {
            if {[info exists filter_array($type_path)]} {
                set filter_array($type_path) [concat $filter_array($type_path) $attr_list]
            } else {
                set filter_array($type_path) $attr_list
            }
        }
        foreach key [array names filter_array] {
            # some string manip even if list, remove dashes from attributes
            set filter_array($key) [string map {"-" ""} [lsort -unique $filter_array($key)]]
        }
    }
    switch -- $mode {
        "session_resume" {
            array set filter_array [list]
            build_filter filter_array
            if {[llength $filter_req_list] > 0} {
                #foreach {k v} $filter_req_list {
                #    if {[info exists ]}
                #}
            }
        }
        "session_info" {
            if {[llength $filter_req_list] == 0} {
                error "<internal>: mode $mode must have a valid filter_req_list"
            }
            array set filter_array $filter_req_list
        }
        default {
            error "<internal>: mode $mode doesnt exist"
        }
    }

    set xml_filename [::ixia::session_resume::util_make_temp_filename "${mode}_"]

    # note: left for testing purposes
    # puts $xml_filename
    # set t0 [clock clicks -milliseconds]

    set ixnet_fd [ixNet writeTo $xml_filename]
    set ixnet_obj_list [lsort [array names filter_array]]
    set ixnet_obj_attr_filter [list]
    foreach {k v} [array get filter_array] {
        lappend ixnet_obj_attr_filter [list $k $v]
    }
    # puts "ixNet exec serialize $ixnet_fd $ixnet_obj_list false $ixnet_obj_attr_filter"
    ixNet exec serialize $ixnet_fd $ixnet_obj_list false $ixnet_obj_attr_filter

    # puts "serialization [expr [clock clicks -milliseconds]-$t0]ms"

    set local_xml_filename [::ixia::session_resume::util_make_file_local $xml_filename]

    try_eval {
        set fin [open $local_xml_filename "r"]
        set ::ixia::session_resume::xml_doc [dom parse -simple [read $fin]]
        set ::ixia::session_resume::xml_root [$::ixia::session_resume::xml_doc documentElement]
        close $fin

        file delete $local_xml_filename
        if {![::ixia::session_resume::util_is_executing_locally_on_ixnet_win]} {
            # someone else might have deleted the file, not important for session_resume
            if {![info exists ::ixTclSvrHandle]} {
                error "Not connected to TclServer."
            }
            # might not have delete access
            catch {::ixia::SendToIxTclServer $::ixTclSvrHandle "file delete $xml_filename"}
        }
        set ::ixia::session_resume::inited 1
    } {
        set ::ixia::session_resume::use_tdom 0
        set ::ixia::session_resume::inited 0
    }
}

# exported
##Internal Procedure Header
#
# Description:
#   Finalizes the session_resume variables and frees the memory
#
proc ::ixia::session_resume::sr_finalize {} {
    if {!$::ixia::session_resume::inited} {
        return
    }

    if {$::ixia::session_resume::use_tdom} {
        $::ixia::session_resume::xml_doc delete
    }

    set ::ixia::session_resume::inited   0
    set ::ixia::session_resume::xml_doc  {}
    set ::ixia::session_resume::xml_root {}

    set ::ixia::session_resume::session_resume_include_filter {}
}

namespace eval ::ixia::session_resume {
    namespace export sr_equal_obj
    namespace export sr_get_ixnhandle
    namespace export sr_get_node_by_ixnhandle
    namespace export sr_get_root
    namespace export sr_get_attribute
    namespace export sr_get_child_list
    namespace export sr_get_parent
    namespace export sr_is_valid_obj
    namespace export sr_get_objs_with_typepaths

    namespace export sr_initialize
    namespace export sr_finalize
}