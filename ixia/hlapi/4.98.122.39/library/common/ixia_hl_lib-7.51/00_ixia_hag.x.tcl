#
#
#
package require snit
foreach ns { 
    ::ixia ::ixia::hag:: ::ixia::hag::ixn ::ixia::hag::ixn::types 
    ::ixia::hag::ixn::paths
} {
    namespace eval $ns {}
}

set ::ixia::hag::ixn::serialno 0

array set ::ixia::hag::ixn::Opts {}
foreach {__k __v} {
    keyedListReturnValues 1
    useIxnPathAliases 0
} {
    if {![info exists ::ixia::hag::ixn::Opts($__k)]} {
        set ::ixia::hag::ixn::Opts($__k) $__v
    }
}; unset __k; unset __v;

if {[llength [info commands ::ixia::hag::ixn::types::oh]] == 0} {
    snit::type ::ixia::hag::ixn::types::oh {
        option -xxxyyyzzz ""
    }
    set tmpcmd [list ::ixia::hag::ixn::types::oh nooptionhandler]
    namespace eval ::ixia::hag::ixn::types $tmpcmd
    unset tmpcmd
}

if {[llength [info commands ::ixia::hag::ixn::types::sharedref]] == 0} {
snit::type ::ixia::hag::ixn::types::sharedref {
    #
    # wrapper for shared reference typepath objects
    #
    option -share-creator 0 
    option -share-typepath 
    option -share-key
    option -share-referrer-object
    option -share-object -readonly true -cgetmethod _soget
    method _soget {args} { return $_SharedObject }
    delegate option * to _SharedObject 
    delegate method * to _SharedObject 
    variable _SharedObject ""
    typevariable Shell ::ixia::hag::ixn::types::shell

    # prevent getting "self" via _ancestor from returning _SharedObject 
    # instead of $self
    method _ancestor {lvl} {
     if {$lvl == 0} {return $self} else {return [$_SharedObject _ancestor $lvl]}
    }

    constructor {args} {
        $self configurelist $args
        if {[info exists options(-share-object)]} {
            set _SharedObject $options(-share-object)
        }
        set referrer_obj [$self cget -share-referrer-object]

        set share_key [$self cget -share-key]
        if {[string match "*:*" $share_key]} {
            # share key is already a ixn_handle use as is
        } else {
            # Here we need to transform -share-key from it's simple type
            # form to the ixn handle form. 
            # e.g. from /vport to -> ::ixNet::OBJ-/vport:2
            # and then compound via concatentation with -share-typepath
            set tmp_obj [$referrer_obj _ancestor \
                [$referrer_obj _typepath_relativity $share_key]]
            set dp [string trimleft $share_key "./"]
            set tmp_obj [$tmp_obj _descendant $dp]
            set share_key [$tmp_obj _ixn_handle]
            $self configure -share-key $share_key![$self cget -share-typepath]
        }

        set _SharedObject [$type _create_shared_ref $self]
    }
    destructor {
        set failed [catch {$type _delete_shared_ref $self} err]
        if {$failed} {
            puts stderr \
            "------\nWarning: cannot delete $self:\n$err:\n$::errorInfo\n------"
        }
    }

    #
    # Keyed by a ixn typepath, values are of the form:
    # {$sharedobj {list of objs that ref $sharedobj}}
    # if this gets more complex we'll move it into a 
    # distinct snit object.
    #
    typevariable _SharedRefs -array {}
    typemethod _create_shared_ref {inst} {
        set share_key [$inst cget -share-key]
        set share_typepath [$inst cget -share-typepath]
        set referrer_obj [$inst cget -share-referrer-object]


        if {[info exists _SharedRefs($share_key)]} {
            $inst configure -share-creator 0
            set mode "SHARE"
            set shared_obj [lindex $_SharedRefs($share_key) 0]
            set tmp [lindex $_SharedRefs($share_key) 1]
            if {[lsearch $tmp $referrer_obj] != -1} {
                return -code error \
                "internal error: $referrer_obj already in _SharedRefs, $share_key == key"
                #return $shared_object
            }
            lappend tmp $referrer_obj
            lset _SharedRefs($share_key) {1} $tmp
        } else {
            $inst configure -share-creator 1
            set mode "CREATE"
            if {[string length [$inst cget -share-object]] == 0} {
                set shared_obj [$Shell _create_instance $share_typepath]
            } else {
                # passed in when constructing 
                set mode "CREATE-SUPPLIED-OBJ"
                set shared_obj [$inst cget -share-object]
            }
            set tmp [list $shared_obj [list $referrer_obj]]
            set _SharedRefs($share_key) $tmp
        }
        #puts stderr "!!!!!!! ++++ $mode ++++ $shared_obj >> $share_key"
        return $shared_obj
    }
    typemethod _delete_shared_ref {inst} {
        set share_key [$inst cget -share-key]
        set referrer_obj [$inst cget -share-referrer-object]
        if {[string length $referrer_obj] == 0} {
            return;
        }
        if {![info exists _SharedRefs($share_key)]} {
            return -code error \
                "Cannot find shared object for pool $share_key"
        }
        set tmp [lindex $_SharedRefs($share_key) 1]
        set idx [lsearch $tmp $referrer_obj]
        if {$idx < 0} {
            return -code error \
                "Cannot find reference $referrer_obj for pool $share_key"
        }

        set tmp [lreplace $tmp $idx $idx]
        if {[set ll [llength $tmp]] < 1}  {
            set mode "DELETE"
            unset _SharedRefs($share_key)
            #puts stderr "!!!!!!!! [$inst cget -share-object]"
            [$inst cget -share-object] destroy
        } else {
            set mode "DE-REF ($ll) "
            lset _SharedRefs($share_key) {1} $tmp
        }
        #puts stderr "!!!!!!!! ---- $mode ---- >> $share_key"
    }
    #!!!! you should probably not be calling this method...
    typemethod _clobber_all_shared_ref {} {
        set dellist {}
        foreach {t v} {array get _SharedRefs} {lappend dellist [lindex $v 0]}
        foreach {t v} {array names _SharedRefs} { unset _SharedRefs($t) }
        foreach {del_obj} $dellist {
            set failed [catch {$del_obj destroy} err]
            if {$failed} {
              puts stderr "cannot destory shared object $del_obj: $err"
            }
        }
    }

}}

if {[llength [info commands ::ixia::hag::ixn::types::shell]==0]} {
snit::type ::ixia::hag::ixn::types::shell {
    option -config-typepathways -readonly yes
    option -config-multiplier-option-groups -readonly yes
    typevariable _HandleRegistry -array {}
    typevariable _LastHandleOfType -array {}
    typemethod _get_handle_registry {} {
        array get _HandleRegistry
    }
    typemethod _handle_registry_exists {inst} {
        info exists _HandleRegistry($inst)
    }
    typemethod _handle_registry_add {inst typepath} {
        set inst [$type _alias_add $inst]
        set _HandleRegistry($inst) $typepath
        set _LastHandleOfType($typepath) $inst
    }
    typemethod _handle_registry_remove {inst} {
        $type _alias_remove $inst
        unset _HandleRegistry($inst)
    }
    typemethod _alias_add {i_handle} {
        if {$::ixia::hag::ixn::Opts(useIxnPathAliases)} {
            set a [$i_handle _ixn_handle]
            regsub {^::ixNet::OBJ-} $a {::ixia::hag::ixn::paths::} a 
              interp alias {} $a {} $i_handle
              set a [subst -nocommands -novariables $a]
            return $a
        } else {
            # no aliases being made just return handles as is
            return $i_handle
        }
    }
    typemethod _alias_remove {i_alias} {
        if {$::ixia::hag::ixn::Opts(useIxnPathAliases)} {
            interp alias {} $i_alias {}; # delete the alias 
        } else {
            # no aliases being made. do nothing
        }
    }

    method _pathways_match {match_pat {debug 0}} {
        set rval {}
        foreach pathway [$self cget -config-typepathways] {
            set mpathway [string trimright $pathway "/"]/
            if {$debug} {
                puts stderr \
                "_pathways_match PPPP: string match \n\"$match_pat\"\n\"$pathway\"\n"
            }
            if {[string match $match_pat $mpathway]} {
                if {$debug} {puts stderr "PPPP:MATCH!"}
                lappend rval $pathway
            }
        }
        return $rval
    }

    method _trace {args} {if $_TRACE(HAG)] {puts stderr "$self: [join $args]"}}
    method _tr {args} {if $_TRACE(HAG)] {puts stderr "    [join $args]"}}
    method _get_var {n} {set $n}

    typemethod _log_error {s} { puts stderr "Error: $s" }
    typemethod _log {s} { puts stderr $s }
    typemethod _log_warning {s} { puts stderr "Warning: $s" }
    constructor {args} {
        $self configurelist $args
    }
    destructor {
    }

    typemethod defaulted_arg_pluck {tag alistN default_value} {
        upvar 1 $alistN alist
        set li [lsearch -exact $alist $tag]
        set ll [llength $alist]
        if {($li < 0)} { return $default_value }
        set rval [lindex $alist [expr $li+1]]
        set alist [lreplace $alist $li [expr $li+1]]
        return $rval
    }

    typemethod arg_pluck {tag alistN errtxt} {
        upvar 1 $alistN alist
        set li [lsearch -exact $alist $tag]
        set ll [llength $alist]
        if {($li < 0)} {
            return -code error "$tag is a required attribute: $errtxt"
        }
        set rval [lindex $alist [expr $li+1]]
        set alist [lreplace $alist $li [expr $li+1]]
        return $rval
    }
    typevariable _TRACE -array {}
    typeconstructor {
        set _TRACE(IXN) 0
        set _TRACE(HAG) 0
        set _TRACE(FC) 0; # FC = frequent commit
        if {[info exists ::env(IXIA_HLT_TRACE)]} {
            if {[string match *IXN* $::env(IXIA_HLT_TRACE)]} {
                set _TRACE(IXN) 1
            }
            if {[string match *HAG* $::env(IXIA_HLT_TRACE)]} {
                set _TRACE(HAG) 1
            }
            if {[string match *FC* $::env(IXIA_HLT_TRACE)]} {
                set _TRACE(FC) 1
            }
        }
    }
    typemethod _ixn_eval {args} {
      if {$_TRACE(IXN)} {
          puts stderr "++++++++++++++++++++++"
          puts stderr "IXN -> $args"
      }
      if {$_TRACE(IXN)} {
          #set t [time {set rval [eval $args]}]
          set failed [catch {set rval [eval $args]} err]
      } else {
          set rval [eval $args]
      }
      if {$_TRACE(IXN)} {
          if {$failed} {
              puts stderr "    <- $err"
              puts stderr "++++++++++++++++++++++"
              flush stderr
              return -code error $err
          } else {
              puts stderr "    <- $rval"
              puts stderr "++++++++++++++++++++++"
              flush stderr
          }
      }
      return $rval
    }
    typemethod _check_ixnhandle {inst} {
        if {![string length [$inst _ixn_handle]]} {
            set msg "IxNetwork Handle has not been bound to object ( $inst )"
            return -code error $msg
        }
    }
    typemethod _create_instance {typepath args} {
        if {[llength $args] == 1} {set args [lindex $args 0]}
        array set o { 
            -element_index ""
            -share-key "-" 
            -share-referrer-object "UNDEFINED" 
        }
        array set o $args

        set instname \
            [lindex [split $typepath "/"] end]-[incr ::ixia::hag::ixn::serialno]
        if {$o(-share-key) == "-"} {
            set cmd [list ::ixia::hag::ixn::types::$typepath $instname]
            set inst [namespace eval ::ixia::hag::ixn::auto $cmd \
                -element_index $o(-element_index)]
        } else {
            append instname "-sharedref"
            set cmd [list ::ixia::hag::ixn::types::sharedref $instname \
                -share-referrer-object $o(-share-referrer-object) \
                -share-typepath $typepath \
                -share-key $o(-share-key) \
            ]
            set inst [namespace eval ::ixia::hag::ixn::auto $cmd]
        }
        return $inst
    }

    # rbaact -- (r)ead (b)ack (a)ttributes (a)nd (c)heck (t)hem
    typemethod _rbaact_instance {inst arg_list} {
        puts "readback;inst;$inst;[$inst _ixn_handle]"
        foreach {t expected} $arg_list {
            set failed [catch {$inst cget $t} actual]
            if {![string equal $expected $actual]} {
              puts "readback;error;\t\t;$t;\t;expected '$expected', got '$actual'"
            } else {
              puts "readback;ok;\t\t;$t;\t;$actual"
            }
        }
    }
    typemethod _cget_instance {inst t} { $inst cget $t }
    typemethod _configure_instance {inst arg_list} {
        $inst _trace "Configure: $arg_list"
        set err ""
        if {$_TRACE(FC)} {
            foreach {t v} $arg_list {
                set failed [catch {$inst configure $t $v} err]
                $type _ixn_eval ixNet commit
            }
        } else {
            set failed [catch {$inst configurelist $arg_list} err]
            if {$failed} {
                set helpfailed [catch {
                    set hdl [$inst _ixn_handle]
                    ixNet help $hdl
                } hlptxt]
                if {!$helpfailed} {
                    append err "\n---- help for \n$inst:\n$hdl\n$hlptxt\n----\n"
                }
            }
            $type _ixn_eval ixNet commit
        }
        if {$failed} {
            return -code error $err
        }
        $inst _tr "configure [lrange $arg_list 0 2] ... complete"
    }
    typemethod _delete_instance {inst} {
        $inst _trace "Delete:"
        $inst destroy
    }


    typemethod _configure_args_multiplier {inst m n args} {
        if {[llength $args] == 1} {set args [lindex $args 0]}
        set original_args $args
        set new_args {}
        array set processed {}
        while {[llength $args]} {
            set opt [lindex $args 0]
            set val [lindex $args 1]
            if {[string range $opt 0 0] != "-"} {
                return -code error "Unexpected value $opt, expected an option."
            }
            if {[llength $args] < 2} {
                return -code error \
                    "Option \"$opt\" is has no accompanying value. for args:\n$original_args"
            }
            if {[info exists processed($opt)]} {
                return -code error \
                    "option $opt already stated as \"$processed($opt)\"."
            }

            set mogdata [$inst _multiplier_opt_group $opt args]
            if {[llength $mogdata]} {
                set processed($opt) "multiplier options [lindex $mogdata 1]"
                lappend mogdata $m $n $args
                set ovlist [eval [linsert $mogdata 0 $inst]]
                set new_args [concat $new_args $ovlist]
            } else {
                lappend new_args $opt $val
                set processed($opt) "simple option $opt $val"
                set args [lrange $args 2 end]
            }
        }
        return $new_args
    }

    typemethod _create_clan {inst initial_parent_handle ancestor_inc_level} {
        $inst _create_ancestry \
            -parent-handle $initial_parent_handle -mode naive
        $inst _create_relatives
    }

    typemethod _parent_for_relative {inst relative_tp} {
        # this really should be cleaned up
        set p_tp [file dirname $relative_tp]
        if {[string equal "." $p_tp]} {
            return $inst
        } elseif {[string match "./*" $p_tp]} {
            # strip leading ./
            return [$inst _descendant [string range $p_tp 2 end]]
        } elseif {[string match "..*" $p_tp]} {
          return [$inst _ancestor [$inst _typepath_relativity $relative_tp]]
        } else {
          return -code error "bad path: $relative_tp"
        }
    }
    typemethod _create_relatives {inst} {
        array set already_added {}
        set new_relatives {}
        set relatives [$inst _get_var Relatives]
        foreach {relative_tp share_tp r_inst} $relatives {
            $inst _trace \
            "Creating relative $relative_tp (share typepath = $share_tp)"

            set fq_tp [$inst _typepath_normalize \
              [$inst _typepath_join [$inst _typepath] $relative_tp]]

            if {[info exists already_added($fq_tp)]} {
                continue
            }
            set omit 0
            set ancestors [$inst _get_var Ancestors]
            foreach {a} $ancestors {
                if {[string equal [$a _typepath] $fq_tp]} {
                    #we already have an ancestor made for this typepath
                    #omit it from the relatives
                    set omit 1
                    break;
                }
            }
            if {$omit} {
                set already_added($fq_tp) $fq_tp
                continue
            }

            #---------------
            # Here's where relatives get instantiated
            # this includes ./xx/xx type relatives
            #
            if {[string equal $share_tp "-"]} {
                #
                # Not shared -- make it in a straightforward way.
                #
                set r_inst [$type _create_instance $fq_tp]
                set parent [$type _parent_for_relative $inst $relative_tp]

                # link item to it's parent, sets up _ixn_handle linkage etc..
                $r_inst _bind_to_parent -parent $parent -tight-binding 1
            } else {
                #
                # Shared -- do some extra instantiation work
                #
                $inst _trace \
                "Creating shared relative: $relative_tp"

                set r_inst [$type _create_instance $fq_tp \
                    -share-referrer-object $inst \
                    -share-key $share_tp]

                if {[$r_inst cget -share-creator]} {
                    #
                    # we allow auto-created ancestors for -shared-includes
                    #
                    set ancestor_inc_level \
                        [$r_inst _get_var AncestorIncludeLevelForCreate]

                    set initial_parent_handle [$inst _top_ancestor]

                    set s_inst [$r_inst cget -share-object]
                    $s_inst _create_clan \
                        $initial_parent_handle $ancestor_inc_level

                    if {$ancestor_inc_level == 0} {
                        set parent [$type \
                            _parent_for_relative $inst $relative_tp]
                        $r_inst _bind_to_parent -parent $parent -tight-binding 0
                    }
                }
                $inst _tr "share key=$share_tp"
                $inst _tr "done"
            }
            #---------------

            lappend new_relatives $relative_tp $share_tp $r_inst
            set already_added($fq_tp) $fq_tp
        }

        $inst _set_var Relatives $new_relatives
    }

    typemethod _create_ancestry {inst args} {
      upvar #0 ::ixia::hag::ixn::serialno sn
      if {[llength $args] == 1} {set args [lindex $args 0]}
      array set o  {
          -parent-handle "UNDEFINED"
          -mode "UNDEFINED"
      }; array set o $args
      set c_level [$inst _get_var AncestorIncludeLevelForCreate]
      set a_level [$inst _get_var AncestorIncludeLevelForAdd]
      set switch_to_add_handle_count [expr $c_level - $a_level]

      $inst _trace "Creating ancestry, $c_level ( $a_level for add ) levels"

      set ancestors {}
      if {$c_level == 0} {
          $inst _trace "No ancestry to create"
          set pl {}
      } else {
          set path_list {}
          set tp [$inst _typepath]
          set pl [$inst _typepath_split [$inst _typepath_parent $tp]]
          set pll [llength $pl]
          set tmp_l [lrange $pl 0 end-$c_level]
          if {[llength $tmp_l] == 0} {
              set path_prefix "/"
          } else {
              set path_prefix [eval [concat {$inst _typepath_join} $tmp_l]]
          }
          set pl [lrange $pl end-[expr $c_level-1] end]
      }

      # method here provides a way to convert a 
      # handle that came from whereever
      # for example, into a suitable typepath object
      set failed [catch {
        set parent_obj \
          [$inst _cast_handle_to_parent_obj $o(-parent-handle) -mode $o(-mode)]
      } err]
      if {$failed} {
          return -code error \
            "$inst: _cast_handle_to_parent_obj $o(-parent-handle) failed\n\n$::errorInfo"
      }
      $inst _tr ">>> initparent_hdl=$o(-parent-handle) parentobj=$parent_obj"

      set count 0
      foreach elem $pl {
          if {$count == 0} {
              set path [$inst _typepath_join $path_prefix $elem]

              # note: we allow parent to be empty string (undefined)
              # for cases like  unrelated shared-includes 
              # there are is no parent handle to provide
              if {$path != "/" && ($parent_obj != "")} {
                  if {$parent_obj == "none"} {
                      return -code error \
                      "ancestry handle for $inst is defined as 'none'"
                  }
                  set top_ancestor $parent_obj
                  if {$o(-mode) == "add"} {
                      set top_ancestor [$parent_obj _ancestor \
                          [expr $c_level - $a_level]]
                  }

                  set a [$top_ancestor _typepath]
                  set b [eval [concat {$inst _typepath_join} $pl]]
                  set tmppath [$inst _typepath_join \
                      $a $b [$inst _typepath_tail $tp] \
                  ]
                  if {![string equal $tmppath $tp]} {
                      set msg "$tmppath != $tp";
                      return -code error \
                          "$inst: Illegal -parent-handle:\n-parent-handle $a this does not match up with $tp properly:\n$msg"
                  }
              }
          } else {
              set path [$inst _typepath_join $path $elem]
          }
          $inst _tr "Creating $path"
          set instnm "[lindex [split $path "/"] end]-a"

          if {($c_level - $count) > $a_level} {
              set doing_unshared_section_of_ancestry 0
          } else {
              set doing_unshared_section_of_ancestry 1
          }

          #
          # make an object along the ancestral path
          #
          if {($o(-mode) == "naive") || $doing_unshared_section_of_ancestry} {
            set obj [namespace eval ::ixia::hag::ixn::auto [list \
              ::ixia::hag::ixn::types::$path "${instnm}-[incr sn]" \
              ]]
            if {$path != "/" && ($parent_obj != "")} {
              $obj _bind_to_parent -parent $parent_obj -tight-binding 0
            }

          } elseif {($o(-mode) == "create") || ($o(-mode) == "add")} {
            if {$o(-mode) == "create"} {
              # make shared section of ancestry
              set s_obj [namespace eval ::ixia::hag::ixn::auto [list \
                ::ixia::hag::ixn::types::$path ${instnm}-[incr sn] \
              ]]
              # (A) For create we have to call bind_to_parent here
              # to get a realized _ixn_handle
              set path_not_at_top 0
              if {$path != "/" && ($parent_obj != "")} {
                  set path_not_at_top 1
              }
              if {$path_not_at_top} {
                $s_obj _bind_to_parent -parent $parent_obj \
                  -binding-mode ifneeded \
                  -tight-binding 0
              }
              # (B) Then make the shared ref
              set cmd [list ::ixia::hag::ixn::types::sharedref \
                ${instnm}-share-[incr sn] \
                -share-object $s_obj \
                -share-referrer-object $inst \
                -share-typepath $path \
                -share-key [$s_obj _ixn_handle]!$path \
              ]
              set obj [namespace eval ::ixia::hag::ixn::auto $cmd]
              # (C) then re-wire the parents child to be the 
              # shared ref
              if {$path_not_at_top} {
                set rewired_children [$parent_obj _get_var Children]
                set rewired_children \
                    [lreplace $rewired_children end-1 end-1 $obj]
                $parent_obj _set_var Children $rewired_children
              }
              unset s_obj

            } else {
              # when called in -add mode, -parent handle is << the
              # ancestor at the level where the sharing ends >>
              set s_obj [$o(-parent-handle) _ancestor \
                  [expr $c_level - $a_level - $count - 1]]
              set s_obj [$s_obj _soget]
              set cmd [list ::ixia::hag::ixn::types::sharedref \
                ${instnm}-share-[incr sn] \
                -share-object $s_obj \
                -share-referrer-object $inst \
                -share-typepath $path \
                -share-key [$s_obj _ixn_handle]!$path \
              ]
              set obj [namespace eval ::ixia::hag::ixn::auto $cmd]
              if {$path != "/" && ($parent_obj != "")} {
                $obj _bind_to_parent -parent $parent_obj \
                  -binding-mode ifneeded \
                  -tight-binding 0
              }
              unset s_obj

            }


          } else {
              return -code error "bad mode $o(-mode)"
          }

          lappend ancestors $obj
          $inst _tr "\t => $obj"
          set parent_obj $obj
          incr count
      }
      $inst _set_var Ancestors [concat [$inst _get_var Ancestors] $ancestors]
      $inst _bind_to_parent -parent $parent_obj -tight-binding 0
    }


    typemethod _destroy_clan {inst} {
        set no_parent 0
        $inst _destroy_children
        $inst _destroy_relatives
        set parent [$inst _parent]
        if {[string length $parent] == 0} {
            set no_parent 1
        } elseif {[llength [info commands $parent]] == 0} {
            set no_parent 1
            #puts stderr \
            #"Warning: $inst: $parent is no longer present in ancestry"
        } else {
            set no_parent 0
            if {[$inst _own_ixn_handle]} {
                $parent _delete_ixn_subelement [$inst _ixn_handle]
            }
        }
        if {$no_parent} {
            # No parent. Object was probably crafted
            # via _cast_handle_to_parent_obj so just
            # just delete the ixn handle ourselves
            # another way this can happen is by stuffing a place holder
            # root object into a shared-include object because it's in 
            # totally disjoint cfg tree.
            if {[$inst _own_ixn_handle]} {
                set rval [$type _ixn_eval ixNet remove [$inst _ixn_handle]]
                $type _ixn_eval ixNet commit
            }
        }
        $inst _destroy_ancestry
    }
    typemethod _destroy_children {inst} {
        set children [$inst _get_var Children]
        set ll [llength $children]
        for {set x 0} {$x < $ll} {incr x} {
            set child_mode [lindex $children end-$x]
            incr x
            set child [lindex $children end-$x]
            if {[string equal $child_mode "tight"]} {
                $inst _trace "destroy child $x: $child"
                # may have been destroyed earlier. make sure it's there
                if {[llength [info commands $child]]} {
                    $child destroy
                }
            } elseif {[string equal $child_mode "loose"]} {
                # do nothing
            } else {
                return -code error "Bad child mode $child_mode"
            }
        }
    }
    typemethod _destroy_relatives {inst} {
        # destroy in reverse of order that they appear in list
        set relatives [$inst _get_var Relatives]
        set ll [llength $relatives]
        for {set x 0} {$x < $ll} {incr x 3} {
            set xxx [expr $x+2]
            set xx [expr $x+1]
            set relative_tp [lindex $relatives end-$xxx]
            set share_tp [lindex $relatives end-$xx]
            set relative_obj [lindex $relatives end-$x]
            $inst _trace "destroy relative: $relative_obj"
            # may have been destroyed as a child already
            if {[llength [info commands $relative_obj]]} {
                $relative_obj destroy
            }
        }
    }
    typemethod _destroy_ancestry {inst} {
        # destroy in reverse of order that they were added
        set ancestors [$inst _get_var Ancestors]
        set ll [llength $ancestors]
        for {set x 0} {$x < $ll} {incr x} {
            set managed_ancestor [lindex $ancestors end-$x]
            $inst _trace "destroy ancestor: $managed_ancestor"
            $managed_ancestor destroy
        }
    }

    typemethod _ixn_subelement_multiplicity {inst} {
        set r [$inst _get_var Multiplicity]
        return $r
    }
    typemethod _delete_ixn_subelement {inst i_ixn_handle} {
        set c_style [$type _ixn_subelement_multiplicity $inst]
        $type _delete_ixn_subelement_${c_style} $inst $i_ixn_handle
    }
    typemethod _add_ixn_subelement {inst element_inst element_name} {
        set c_style [$type _ixn_subelement_multiplicity $inst]
        set c_style [$type _ixn_subelement_multiplicity $element_inst]
        set rval [$type _add_ixn_subelement_${c_style} \
            $inst $element_inst $element_name]
        return $rval
    }

    typemethod _delete_ixn_subelement_kManaged {inst i_ixn_handle} {
        $type _delete_ixn_subelement_kList $inst $i_ixn_handle
    }
    typemethod _add_ixn_subelement_kManaged  {inst element_inst element_name} {
        #
        # There is no operation such as ixNet add for managed items.
        # Apparently, you simply configure the element w/ the managed index
        # as part of the name
        # 
        set rval [$inst _ixn_handle]
        append rval "/$element_name:"
        append rval [$element_inst cget -element_index]
        $type _ixn_eval ixNet commit
        catch {
            set rval [lindex [$type _ixn_eval ixNet remapIds $rval] 0]
        } err
        #$element_inst _set_ixn_handle $rval
        return $rval
    }

    # as it stands now, technically the caller could just remove the item
    # itself we have this in order to keep the add remove process symetric
    # in case we need to more things besides the ixNet remove command
    typemethod _delete_ixn_subelement_kList {inst i_ixn_handle} {
        set failed [catch {
            $type _ixn_eval ixNet remove $i_ixn_handle
            $type _ixn_eval ixNet commit
        } err]
        if {$failed} {
            if {[string match "*ixNet::ERROR*-5500-*" $err]} {
              # not a delete-able thing ignore it
            } else {
              return -code error \
              "$err\nFor commmand:\nixNet remove $i_ixn_handle"
            }
        }
    }
    typemethod _add_ixn_subelement_kList {inst element_inst element_name} {
        set failed [catch {
            set rval [$type \
                _ixn_eval ixNet add [$inst _ixn_handle] $element_name]
            $type _ixn_eval ixNet commit
            set rval [lindex [$type _ixn_eval ixNet remapIds $rval] 0]
            if {[string match {*:L[0-9]*} $rval]} {
                # remap did not do anything.. lovely.
                # ixn did not error out when it should have
                error "ixNet::ERROR -5500- bogus commit/remapIds by ixn.."
            }
        } err]
        if {$failed} {
            if {[string match "*ixNet::ERROR*-5500-*" $err]} {
              set rval [$inst _typepath_join [$inst _ixn_handle] $element_name]
            } else {
              return -code error \
              "$err\nFor commmand:\nixNet add [$inst _ixn_handle] $element_name"
            }
        }
        return $rval
    }
    typemethod _add_ixn_subelement_kOptional {inst element_inst element_name} {
        $type _add_ixn_subelement_kList $inst $element_inst $element_name
    }
    typemethod _delete_ixn_subelement_kOptional {inst i_ixn_handle} {
        $type _delete_ixn_subelement_kList $inst $i_ixn_handle
    }

    typemethod _add_ixn_subelement_kRequired {inst element_inst element_name} {
        set rval [$inst _typepath_join [$inst _ixn_handle] $element_name]
        return $rval
    }
    typemethod _delete_ixn_subelement_kRequired {inst i_ixn_handle} {
        $type _delete_ixn_subelement_kList $inst $i_ixn_handle
    }


    typemethod _m_kInteger {inst mog_args m n other_args pre} {
        array set o $mog_args
        set v [expr {$o(${pre}_base) + $o(${pre}_incr) * ($m - 1)}]
        return [list $pre $v]
    }
    typemethod _m_kInteger64 {inst mog_args m n other_args pre} {
        array set o $mog_args
        set v [expr {$o(${pre}_base) + $o(${pre}_incr) * ($m - 1)}]
        return [list $pre $v]
    }
    typemethod _m_kString {inst mog_args m n other_args pre} {
        array set o $mog_args
        set v [expr {$o(${pre}_base) + $o(${pre}_incr) * ($m - 1)}]
        set v [format $o(${pre}_format) $v]
        return [list $pre $v]
    }
    typemethod _m_kMac {inst mog_args m n other_args pre} {
        array set o $mog_args
        set macAdd $o(${pre}_base)
        set amount [expr {$o(${pre}_incr) * ($m - 1)}]
        set v [::ixia::incrementMacAdd $macAdd $amount]
        return [list $pre $v]
    }


    #
    # Note: if protocol_flavor is the empty string then 
    #
    # just do to the /vport/protocolStack level
    #
    # otherwise do to the /vport/protocolStack/{atm|ethernet} flavor level
    #
    typemethod _ixn_port_handle_from_port_str {port_str} {
        set return_status [::ixia::ixNetworkPortAdd $port_str {} force]
        if {[keylget return_status status] != $::SUCCESS} {
            return -code error \
                "Cannot get ixnetwork port $port_str:\n$return_status"
        }
        set result [::ixia::ixNetworkGetPortObjref $port_str]
        if {[keylget result status] == $::FAILURE} {
            return -code error \
            "Unable to find the port object w/ the $port_str port handle"
        } else {
            set port_handle [keylget result vport_objref]/protocolStack
        }
        return $port_handle
    }
    typemethod _ixn_l2handle_from_target_inst {
        port_handle target_inst {l2_flavor "auto"}
    } {
        if {[string equal $l2_flavor "auto"]} {
            set l2_flavor "ethernet"
            if {[string match "*/atm/*" [$target_inst _typepath]]} {
                set l2_flavor "atm"
            }
        }
        ##puts stderr "MMM target_inst = $target_inst"
        set tmp_node_list [::ixia::ixNetworkNodeGetList \
            $port_handle $l2_flavor]
        #----------------------------------------------------------------
        # re_use_node logic - i don't understand the logic in hlt of 
        # re-using eth/atm nodes so this adaptation is subject to question.
        #
        set re_use_node ""
        foreach {r_inst r_type} [$type _get_handle_registry] {
            ##puts stderr "MMM r_inst = $r_inst"
            if {$r_inst == $target_inst} {
                ##puts stderr "MMM-      SKIPPING SELF"
                continue
            }
            if {[$r_inst _typepath] != [$target_inst _typepath]} {
                ##puts stderr "MMM-     [$r_inst _typepath] different type"
                continue
            }
            # r_inst and target_inst are two insts w/ the same type
            foreach n $tmp_node_list {
                ##puts stderr "MMM $n CHECK $n vs [$r_inst _ixn_handle]"
                set lend [string length $n]
                incr lend -1
                set chopped_rh [string range [$r_inst _ixn_handle] 0 $lend]
                ##puts stderr "MMM CHOPPED $n vs $chopped_rh"

                if {[string equal $n $chopped_rh]} {
                    ##puts stderr "MMM+     REUSE $n"
                    set re_use_node $n
                    break
                } else {
                    ##puts stderr "MMM-     no for $n"
                }
            }
            if {[string length $re_use_node]} {
                ##puts stderr "MMM REUSE $re_use_node"
                break
            }
        }
        #----------------------------------------------------------------
        if {[string length $re_use_node] == 0} {
            set result [::ixia::ixNetworkNodeAdd \
                $port_handle $l2_flavor {} -commit]
            if {[keylget result status] != $::SUCCESS} {
                return -code error \
                    "error getting $l2_flavor element:\n$result"
            }
            set ixnh [keylget result node_objref]
        } else {
            set ixnh $re_use_node
        }

        set tmp_typepath "/vport/protocolStack/$l2_flavor"
        set flavor_inst [$type _create_instance $tmp_typepath]
        set own_ixn_handle 0
        $flavor_inst _set_ixn_handle $ixnh $own_ixn_handle
        return $flavor_inst
    }

    typemethod _inject_ixn_handle {
        typepath ixn_handle {parent {}} {children {}}
    } {
        set inst [$type _create_instance $typepath]
        $inst _set_ixn_handle $ixn_handle
        # force add
        if {![$type _handle_registry_exists $inst]} {
            $type _handle_registry_add $inst [$inst _typepath]
        }
        
        if {$parent != {}} {
            $inst _set_var Parent $parent
        }
        if {$children != {}} {
            $inst _set_var Children [concat $children "loose" [$inst _get_var Children]]
        }
        return $inst
    }

    typemethod _make_ipEndpoint_range_ancestors_from_port_str {
        target_inst port_str l2_flavor
    } {
        if {![regexp -- {^[0-9]+/[0-9]+/[0-9]+$} $port_str]} {
            # not a port string, assume we've been passed a hag object
            return $port_str;
        }
        set own_ixn_handle 0

        #--
        set eth_inst [$type _make_endpoint_ancestors_from_port_str \
            $target_inst $port_str $l2_flavor]
        set eth_ixnh [$eth_inst _ixn_handle]

        #--
        set ip_inst [$type _create_instance [$eth_inst _typepath]/ipEndpoint]
        set tmp_list [::ixia::ixNetworkNodeGetList $eth_ixnh "ipEndpoint"]
        if {[llength $tmp_list] == 0} {
            # make missing ipEndpoint:XXX/range:XXX elems in obj hierarchy
            set ip_ixnh [ixNet add $eth_ixnh "ipEndpoint"]; ixNet commit
            set ip_ixnh [ixNet remapIds $ip_ixnh]
            set tmp [ixNet add $ip_ixnh "range"]; ixNet commit
            set tmp [ixNet remapIds $tmp]
        } else {
            set ip_ixnh [lindex $tmp_list 0] 
        }
        $ip_inst _set_ixn_handle $ip_ixnh $own_ixn_handle
        $ip_inst _set_var Parent $eth_inst
        $eth_inst _set_var Children [linsert \
            [$eth_inst _get_var Children] 0 $ip_inst "loose"]

        #--
        set range_inst [$type _create_instance [$ip_inst _typepath]/range]
        set tmp_list [::ixia::ixNetworkNodeGetList $ip_ixnh "range"]
        if {[llength $tmp_list] == 0} {
            return -code error "cannot find range element"
        } elseif {[llength $tmp_list] > 1} {
            return -code error "too many range elements"
        }
        set range_ixnh [lindex $tmp_list 0]
        $range_inst _set_ixn_handle $range_ixnh $own_ixn_handle
        $range_inst _set_var Parent $ip_inst
        $ip_inst _set_var Children [linsert \
            [$ip_inst _get_var Children] 0 $range_inst "loose"]

        return $range_inst
    }

    typemethod _make_protocolStack_ancestors_from_port_str {
        target_inst port_str l2_flavor
    } {
        if {![regexp -- {^[0-9]+/[0-9]+/[0-9]+$} $port_str]} {
            # not a port string, assume we've been passed a hag object
            return $port_str;
        }
        set own_ixn_handle 0

        set port_handle [$type _ixn_port_handle_from_port_str $port_str]
        set ixnh $port_handle

        set protocol_inst [$type _create_instance "/vport/protocolStack"]
        $protocol_inst _set_ixn_handle $ixnh $own_ixn_handle

        set ixnh [$target_inst _typepath_parent $ixnh]
        set vport_inst [$type _create_instance "/vport"]
        $vport_inst _set_ixn_handle $ixnh $own_ixn_handle
        set root_inst [$type _create_instance "/"]

        # ancestors should be listed in top down order..
        # this ensures proper deletion order
        $target_inst _set_var Ancestors \
            [linsert [$target_inst _get_var Ancestors] 0 \
                $root_inst $vport_inst $protocol_inst]

        #
        # Link parents to children and vice versa
        #
        # -- Vport level
        $protocol_inst _set_var Parent $vport_inst
        $vport_inst _set_var Children [linsert \
            [$vport_inst _get_var Children] 0 $protocol_inst "loose"]
        # -- Root level
        $vport_inst _set_var Parent $root_inst
        $root_inst _set_var Children [linsert \
            [$root_inst _get_var Children] 0 $vport_inst "loose"]

        return $protocol_inst
    }

    typemethod _make_endpoint_ancestors_from_port_str {
        target_inst port_str l2_flavor
    } {
        set port_handle [$type _ixn_port_handle_from_port_str $port_str]
        if {[string length $l2_flavor]} {
            set flavor_inst [$type _ixn_l2handle_from_target_inst \
                $port_handle $target_inst $l2_flavor]
            set ixnh [$flavor_inst _ixn_handle]
            set ixnh [$flavor_inst _typepath_parent $ixnh]
            set ixnh [$flavor_inst _typepath_parent $ixnh]
        } else {
            set ixnh $port_handle
        }

        set own_ixn_handle 0

        set protocol_inst [$type _create_instance "/vport/protocolStack"]
        $protocol_inst _set_ixn_handle $ixnh $own_ixn_handle

        set ixnh [$target_inst _typepath_parent $ixnh]
        set vport_inst [$type _create_instance "/vport"]
        $vport_inst _set_ixn_handle $ixnh $own_ixn_handle
        set root_inst [$type _create_instance "/"]

        # ancestors should be listed in top down order..
        # this ensures proper deletion order
        if {[string length $l2_flavor]} {
            $target_inst _set_var Ancestors \
                [linsert [$target_inst _get_var Ancestors] 0 \
                    $root_inst $vport_inst $protocol_inst $flavor_inst]
        } else {
            $target_inst _set_var Ancestors \
                [linsert [$target_inst _get_var Ancestors] 0 \
                    $root_inst $vport_inst $protocol_inst]
        }
        #
        # Link parents to children and vice versa
        #
        # -- Flavor level
        if {[string length $l2_flavor]} {
          $flavor_inst _set_var Parent $protocol_inst
          $protocol_inst _set_var Children [linsert \
            [$flavor_inst _get_var Children] 0 $flavor_inst "loose"]
        }
        # -- Vport level
        $protocol_inst _set_var Parent $vport_inst
        $vport_inst _set_var Children [linsert \
            [$vport_inst _get_var Children] 0 $protocol_inst "loose"]
        # -- Root level
        $vport_inst _set_var Parent $root_inst
        $root_inst _set_var Children [linsert \
            [$root_inst _get_var Children] 0 $vport_inst "loose"]

        if {[string length $l2_flavor]} {
            return $flavor_inst
        } else {
            return $vport_inst
        }
    }
    typemethod _make_endpoint_ancestors_from_flavor_inst {
        target_inst flavor_inst
    } {
        set l2_flavor "ethernet"
        if {[string match "*/atm/*" [$target_inst _typepath]]} {
            set l2_flavor "atm"
        }
        
        set ixnh [$flavor_inst _ixn_handle]
        set ixnh [$flavor_inst _typepath_parent $ixnh]
        set ixnh [$flavor_inst _typepath_parent $ixnh]

        set own_ixn_handle 0

        set protocol_inst [$type _create_instance "/vport/protocolStack"]
        $protocol_inst _set_ixn_handle $ixnh $own_ixn_handle

        set ixnh [$target_inst _typepath_parent $ixnh]
        set vport_inst [$type _create_instance "/vport"]
        $vport_inst _set_ixn_handle $ixnh $own_ixn_handle
        set root_inst [$type _create_instance "/"]

        # ancestors should be listed in top down order..
        # this ensures proper deletion order
        if {[string length $l2_flavor]} {
            $target_inst _set_var Ancestors \
                [linsert [$target_inst _get_var Ancestors] 0 \
                    $root_inst $vport_inst $protocol_inst $flavor_inst]
        } else {
            $target_inst _set_var Ancestors \
                [linsert [$target_inst _get_var Ancestors] 0 \
                    $root_inst $vport_inst $protocol_inst]
        }
        #
        # Link parents to children and vice versa
        #
        # -- Flavor level
        if {[string length $l2_flavor]} {
          $flavor_inst _set_var Parent $protocol_inst
          $protocol_inst _set_var Children [linsert \
            [$flavor_inst _get_var Children] 0 $flavor_inst "loose"]
        }
        # -- Vport level
        $protocol_inst _set_var Parent $vport_inst
        $vport_inst _set_var Children [linsert \
            [$vport_inst _get_var Children] 0 $protocol_inst "loose"]
        # -- Root level
        $vport_inst _set_var Parent $root_inst
        $root_inst _set_var Children [linsert \
            [$root_inst _get_var Children] 0 $vport_inst "loose"]

        if {[string length $l2_flavor]} {
            return $flavor_inst
        } else {
            return $vport_inst
        }
    }     
    typemethod \
    _std_vport_protocolstack_secondaryRange_cast_handle_to_parent_obj {
        i_inst i_handle i_primary_typepath_pattern
    } {
        # If the thing passed in is a simple chassisN/cardN/portN string
        # it's wrong
        if {[regexp -- {^[0-9]+/[0-9]+/[0-9]+$} $i_handle]} {
            # a hlt port string, wd don't accept those
            return -code error "$i_handle is not a valid handle"
        }
        if {![string match $i_primary_typepath_pattern [$i_handle _typepath]]} {
            # we are not explicitly tryng to morph a object with 
            # ixn type that matches i_primary_typepath_pattern
            # so we are probabaly doing somehing like building an 
            # ancestor tree so return the object unmorphed
            return $i_handle
        }
        #
        # If we got this far, then i_handle  should be the handle to 
        # the primary range that is associated w/ to the secondaryRange.
        #
        # get the endpoint ancestor of the primary_range
        set endpoint_inst [[$i_handle _parent] _parent]
        return $endpoint_inst
    }
    typemethod _std_vport_protocolstack_range_cast_handle_to_parent_obj {
        i_inst i_handle
    } {
        # If the thing passed in is a simple chassisN/cardN/portN string
        # we need to morph it into a hag object
        if {![regexp -- {^[0-9]+/[0-9]+/[0-9]+$} $i_handle]} {
            # not a port string, assume we've been passed a hag object
            return $i_handle;
        }
        set port_str $i_handle
        set protocol_stack_type "ethernet"
        if {[string match "*/atm/*" [$i_inst _typepath]]} {
            set protocol_stack_type "atm"
        }
        set rval [$type _make_endpoint_ancestors_from_port_str \
            $i_inst $port_str $protocol_stack_type]
        return $rval
    }
    typemethod _std_vport_protocolstack_options_cast_handle_to_parent_obj {
        i_inst i_handle
    } {
        # If the thing passed in is a simple chassisN/cardN/portN string
        # we need to morph it into a hag object
        if {![regexp -- {^[0-9]+/[0-9]+/[0-9]+$} $i_handle]} {
            # not a port string, assume we've been passed a hag object
            return $i_handle;
        }
        set port_str $i_handle
        set protocol_stack_type ""; # don't include the ethernet|atm level
        set rval [$type _make_endpoint_ancestors_from_port_str \
           $i_inst $port_str $protocol_stack_type]
        return $rval
    }

    #
    # Get list of chassis ip's from ixn. this is used to 
    # so we can convert chassis address to chassis number
    # see (Parse) comment below. 
    # ** They are returned in the order they are registered in w/ ixn **
    # ** This is a requirement **
    #
    typemethod _ixn_chassis_ip_list {} {
        set rval {}
        set ch_list [$type _ixn_eval \
            ixNet getList [ixNet getRoot]/availableHardware chassis]
        foreach {ch} $ch_list {
          lappend rval [string trim [lindex [split $ch ":"] end] "\"\\"]
        }
        return $rval
    }

    #
    # we assume enableStats had been called already
    #
    typemethod _stats_get {statsRef statViewName statNameList {inst {}} } {
        upvar 1 $statsRef stats;
        
        set port_name ""
        if {$inst != ""} {
            set hlt_port_str [$type _hlt_port_string_for_inst $inst]
            set ixn_chassis [$type _ixn_chassis_ip_list]
            
            if {[regexp {([0-9]+)/([0-9]+)/([0-9]+)} $hlt_port_str matched_str ch_id cd pt]} {
                if {$pt < 10} {
                    set pt "0${pt}"
                }
                if {$cd < 10} {
                    set cd "0${cd}"
                }
                set port_name "[lindex $ixn_chassis [expr {$ch_id - 1}]]/Card${cd}/Port${pt}"
            }
        }
        
        foreach {n} [array names stats] {
            unset stats$(n)
        }
        set statViewRoot "statViewBrowser"

        set statViewList [$type \
            _ixn_eval ixNet getList [ixNet getRoot]/statistics $statViewRoot]

        set statViewObjRef ""
        foreach statView $statViewList {
            if {[$type _ixn_eval ixNet getAttribute $statView -name] \
                eq $statViewName} {
                set statViewObjRef $statView
                break
            }
        }
        if {[string length $statViewObjRef] == 0} {
            return -code error "Cannot find '$statViewName'"
        }

        set pageNumber 1
        set currentRow 1
        set totalPages [$type _ixn_eval \
            ixNet getAttribute $statViewObjRef -totalPages]
        set currentPage [$type _ixn_eval \
            ixNet getAttribute $statViewObjRef -currentPageNumber]
        set localTotalPages $totalPages

        if {$totalPages > 0 && $currentPage != $pageNumber} {
            $type _ixn_eval \
             ixNet setAttribute $statViewObjRef -currentPageNumber $pageNumber
            $type _ixn_eval ixNet commit
        }

        array set stats [list]
        set continueFlag "true"
        set itime [clock seconds]
        set tmo 300; # Try for 300 seconds.
        while {$continueFlag == "true" && \
            ([expr [clock seconds] - $itime]) < $tmo \
        } {

            set is_ready true

            if {1} {
            set is_ready [$type _ixn_eval \
                ixNet getAttribute $statViewObjRef -isReady]
            }

            if {$is_ready == true} {

                while {[set rowList [$type _ixn_eval \
                    ixNet getList $statViewObjRef row]] == ""} {
                    if {[expr [clock seconds] - $itime] >= $tmo} {
                        return -code error "The stat view is ready, but there\
                                are no statistics available."
                    }
                }

                if {$port_name != ""} {
                    set auxList $rowList
                    set rowList ""
                    foreach row $auxList {
                        if {[string first $port_name $row] != -1} {
                            lappend rowList $row
                        }
                    }
                }
                
                foreach row $rowList {
                    # get the row name
                    set row_name ""
                    catch {$type _ixn_eval ixNet getAttribute $row -name} \
                        row_name
                    if {[string length $row_name]} {
                        set stats($currentRow) $row_name
                    } else {
                        return -code error "Unable to get row name \
                            when reading from stat view '$statViewName'."
                    }

                    # get the stats
                    while {[set cellList [ixNet getList $row cell]] == ""} {
                        if {[expr [clock seconds] - $itime] >= $tmo} {
                            return -code error \
                            "The stat view is ready, but there\
                                are no row=$row (cell) statistics available."
                            return $returnList
                        }
                        after 100
                    }
                    foreach cell $cellList {
                        set outcome ERROR
                        while {$outcome == "ERROR" && \
                            ([expr [clock seconds] - $itime]) < $tmo \
                        } {
                            catch {$type _ixn_eval \
                                ixNet getAttribute $cell -columnName} stat_name

                            set matched \
                                [regexp {^::ixNet::(OK|ERROR|OBJ|LIST)-} \
                                $stat_name {} outcome]

                            if {$matched && $outcome == "ERROR"} {
                                after 100
                            } else {
                                set outcome ""
                            }
                        }
                        if {$outcome == "ERROR"} {
                            return -code error "Unable to get cell\
                                columnName from stat view '$statViewName'."
                        }

                        set stat_name_esc \
                            [string map {"\[" "(" "\]" ")"} $stat_name]

                        #set include \
                        # [expr [lsearch $statNameList $stat_name_esc] != -1]
                        set include 1
                        if {$include} {
                            set outcome ERROR
                            while {$outcome == "ERROR" && \
                                ([expr [clock seconds] - $itime]) < $tmo \
                            } {
                                catch {$type _ixn_eval \
                                 ixNet getAttribute $cell -statValue} stat_value

                                set matched \
                                    [regexp {^::ixNet::(OK|ERROR|OBJ|LIST)-} \
                                    $stat_value {} outcome]
                                if {$matched && $outcome == "ERROR"} {
                                    after 100
                                } else {
                                    set outcome ""
                                }
                            }
                            if {$outcome == "ERROR"} {
                                return -code error "Unable to get value of\
                                    cell '$stat_name' from stat view\
                                    '$statViewName'."
                            }
                            set stats($currentRow,$stat_name_esc) $stat_value
                        }
                    }
                    incr currentRow
                }

                set currentPage [ixNet getAttribute $statViewObjRef \
                        -currentPageNumber]
                if {$totalPages > 0 && $currentPage < $localTotalPages} {
                    incr totalPages -1
                    incr pageNumber
                    $type _ixn_eval ixNet setAttribute \
                        $statViewObjRef -currentPageNumber $pageNumber
                    $type _ixn_eval ixNet commit
                } else {
                    set continueFlag false
                }
            } else {
                after 1000
            }
        }

        if {$continueFlag == true} {
            return -code error "Requested stat view is not ready."
        } else {
            return [expr $currentRow - 1]
        }
    }

    typemethod _stats_enable_view_list {
        statViews {statViewRoot "statViewBrowser"} {retries 10}
    } {
        set ixn_root [$type _ixn_eval ixNet getRoot]
        set statViewList \
            [$type _ixn_eval ixNet getList $ixn_root/statistics $statViewRoot]

        set statViewObjRefs {}
        set foundViews {}
        foreach statView $statViewList {
            set nm [$type _ixn_eval ixNet getAttribute $statView -name]
            lappend foundViews $nm
            if {[lsearch $statViews $nm] == -1} {
                continue
            }
            set enabled \
              [$type _ixn_eval ixNet getAttribute $statView -enabled]
            if {$enabled == "false"} {
                $type _ixn_eval ixNet setAttribute $statView -enabled true
            }
            lappend statViewObjRefs $statView
        }
        $type _ixn_eval ixNet commit
        
        if {[llength $statViewObjRefs]==0} {
            set msg "Unable to get stat views.\n"
            append msg "Looking for views:\n[list $statViews]\n--------\n" 
            append msg "Found views:\n[list $foundViews]\n--------\n\n"
            return -code error $msg
        }

        set retry 0; set success 0
        while {$retry < $retries} {
            set statViewsAreEnabled 1
            set statViewsAreReady 1
            foreach statViewObjRef $statViewObjRefs {
                # enable statView objects
                set enabled [$type _ixn_eval \
                    ixNet getAttribute $statViewObjRef -enabled]
                if {$enabled != "true"} {
                    $type _ixn_eval \
                      ixNet setAttribute $statViewObjRef -enabled true
                    set statViewsAreEnabled 0
                }
                # isReady statView objects
                if {$statViewsAreEnabled && \
                [$type _ixn_eval ixNet getAttribute $statViewObjRef -isReady] != "true"} {

                    $type _ixn_eval \
                        ixNet setAttribute $statViewObjRef -enabled true
                    set statViewsAreReady 0
                }
                $type _ixn_eval ixNet commit
            }
            if {$statViewsAreEnabled == 0 || $statViewsAreReady == 0} {
                after 1000
            } else {
                after 2000
                set success 1
                break
            }
            incr retry 1
        }
        if {!$success} {
            return -code error \
              "Timeout occured waiting for statView objects to become ready."
        }
    }

    method _resolve_typepath {arglistN} {
        upvar $arglistN args
        #
        # if there is just one pathway, ignore -style...
        #
        set pathways [$self _pathways_match *]
        if {[llength $pathways] == 1} {
          set err ""
          # ignore -style if it's there..
          catch { set style [$type arg_pluck -style args $err] }
        }
        #
        # more than one pathway try to narrow it down via -style directive
        #
        if {[llength $pathways] != 1} {
          set choices "Choices are:\n"
          foreach p [$self _pathways_match "*"] {
              set p [file dirname $p]
              append choices "\t\"$p\"\n"
          }
          set err "-mode create requires a \"-style \$style\" option pair\n$choices"
          set style [$type arg_pluck -style args $err]
          set style */[string trim $style "/"]/*
          set pathways [$self _pathways_match $style]
        }
        if {[llength $pathways] == 0} {
            set choices "Choices are:\n"
            foreach p [$self _pathways_match "*"] {
                set p [file dirname $p]
                append choices "\t\"$p\"\n"
            }
            return -code error \
            "No configuration style found for -style \"$style\":\n$choices"
        }
        if {[llength $pathways] != 1} {
            set msg "Change your style to match only 1 of the following:\n"
            foreach p $pathways {
                append msg "\t\"$p\"\n"
            }
            return -code error "Style '$style' is ambiguous: $msg"
        }
        set typepath [lindex $pathways 0]
        return $typepath
    }

    typemethod _multi_create {count parent_handle typepath args} {
        if {[llength $args] == 1} {set args [lindex $args 0]}
        set rval {}
        set mn_args $args
        for {set cx 1} {$cx <= $count} {incr cx} {
            lappend rval [$type _create_m_of_n \
                $parent_handle $typepath $cx $count $mn_args]
            if {$cx == 1} {
                lappend mn_args -alongside_handle [lindex $rval 0]
            }
        }
        return $rval
    }
    typemethod _create_m_of_n {parent_handle typepath m n args} {
        if {[llength $args] == 1} {set args [lindex $args 0]}
        if {$m == 1} {
            return [$type _create $parent_handle $typepath $m $n $args]
        } else {
            return [$type _add $m $n $args]
        }
    }
    typemethod _create {parent_handle typepath m n args} {
        if {[llength $args] == 1} {set args [lindex $args 0]}
        set err ""
        set tight_binding "internal_default"
        catch {set tight_binding [$type arg_pluck -tight-binding args $err]}
        set element_index ""
        catch {set element_index [$type arg_pluck -element_index args $err]}
        set inst [::ixia::hag::ixn::types::shell \
            _create_instance $typepath -element_index $element_index]
        set args [$inst _configure_args_multiplier $m $n $args]

        #---------------------------------------------------------------
        # Note: there is an element of finnese here.
        # We need to create the ancestors before we bind
        # and the relatives (including children)
        # after we bind so don't use create_clan 
        # 
        $inst _create_ancestry -parent-handle $parent_handle -mode create
        $inst _bind_to_parent -parent $parent_handle \
            -tight-binding $tight_binding
        $inst _create_relatives
        #---------------------------------------------------------------

        set rbaact [$type defaulted_arg_pluck \
            -read-back-attributes-and-check-them args 0]
        ::ixia::hag::ixn::types::shell _configure_instance $inst $args
        $inst _post_construct_callback [concat {-mode create} $args]
        if {$rbaact} {
            ::ixia::hag::ixn::types::shell _rbaact_instance $inst $args
        }

        set r [$type _handle_registry_add $inst $typepath]
        return $r
    }
    typemethod _add {m n args} {
        if {[llength $args] == 1} {set args [lindex $args 0]}
        set err ""
        set tight_binding "internal_default"
        catch {set tight_binding [$type arg_pluck -tight-binding args $err]}

        set err "Missing -alongside_handle option."
        set alongside_handle [$type arg_pluck -alongside_handle args $err] 
        set typepath [$alongside_handle _typepath]

        # Make a new object w/ the same immediate parentage 
        # as $alongside_handle
        set element_index ""
        catch {set element_index [$type arg_pluck -element_index args $err]}
        set inst [::ixia::hag::ixn::types::shell _create_instance $typepath \
            -element_index $element_index]
        set args [$inst _configure_args_multiplier $m $n $args]

        #---------------------------------------------------------------
        # Note: there is an element of finnese here.
        # We need to create the ancestors before we bind
        # and the relatives (including children)
        # after we bind so don't use create_clan 
        # 
        set alvl [$inst _get_var AncestorIncludeLevelForAdd]
        $inst _create_ancestry \
            -parent-handle [$alongside_handle _ancestor [expr ($alvl+1)]] \
            -mode add
        # note: if tight binding is "" or "none", this is a no-op
        $inst _bind_to_parent -parent [$alongside_handle _parent] \
            -tight-binding $tight_binding
        $inst _create_relatives
        #---------------------------------------------------------------

        set rbaact [$type defaulted_arg_pluck \
            -read-back-attributes-and-check-them args 0]
        ::ixia::hag::ixn::types::shell _configure_instance $inst $args
        $inst _post_construct_callback [concat {-mode add} $args]
        if {$rbaact} {
            ::ixia::hag::ixn::types::shell _rbaact_instance $inst $args
        }

        set r [$type _handle_registry_add $inst $typepath]
        return $r
    }

    method _resolving_add {m n args} {
        if {[llength $args] == 1} {set args [lindex $args 0]}
        set typepath [$self _resolve_typepath args]
        set alongside_handle ""
        set parent_handle ""
        set err ""
        #
        # If parent_handle if supplied, devine an appropriate
        # alongside_handle from it.
        #
        catch { 
            set parent_handle [$type arg_pluck -parent_handle args $err] 
        }
        if {[string length $parent_handle]} {
            set is_hps [$type is_hlt_port_str $parent_handle]
            if {$is_hps} {
                set found 0
                foreach {r_inst r_typepath} [$type _get_handle_registry] {
                    if {$typepath != $r_typepath} {
                        continue
                    }
                    set tmp_hps [$type _hlt_port_string_for_inst $r_inst]
                    if {$tmp_hps == $parent_handle} {
                        set args [linsert $args 0 -alongside_handle $r_inst]
                        set found 1
                        break
                    }
                }
                if {!$found} {
                    return -code error \
                        "Illegal -parent_handle \"$parent_handle\""
                }
            } else {
                return -code error \
                    "Illegal -parent_handle \"$parent_handle\""
            }
        }
        if {[string length $alongside_handle]==0} {
            set err ""; catch { 
             set alongside_handle [$type arg_pluck -alongside_handle args $err] 
            }
        }
        if {[string length $alongside_handle]} {
            set args [linsert $args 0 -alongside_handle $alongside_handle]
            return [$type _add $m $m $args]
        } 
        # if no -alongside_handle was supplied yet 
        # try to find the last handle made of the same typepath 
        # and use that..
        #
        # look for last handle of same type that was made
        if {[info exists _LastHandleOfType($typepath)]} {
              set alongside_handle $_LastHandleOfType($typepath)
              # make sure handle is not stale...
              if {[llength [info commands $alongside_handle]] != 1} {
                  unset _LastHandleOfType($typepath)
                  set alongside_handle ""
              }
        }
        if {[string length $alongside_handle] == 0} {
            return -code error \
            "-mode add: cannot find the last handle made of type $typepath -alongside_handle is required. args were:\n$args"
        }
        return [$type _add $m $m \
            [linsert $args 0 -alongside_handle $alongside_handle]]
    }


    method config {args} {
        set syntax {Available -modes are:
        -mode create -style $style_designator -parent_handle $handle
        -mode add -style $style_designator ?-alongside_handle $previously_created_handle_of_same_type?
        -mode modify -handle $instance
        -mode delete -handle $instance}

        set mode [$type arg_pluck -mode args $syntax]

        set valid_modes {create add modify delete enable disable}

        if {[lsearch -exact $valid_modes $mode] < 0} {
            return -code error "Illegal mode $mode: $syntax"
        }


        if {[string equal $mode "create"]} {
            set typepath [$self _resolve_typepath args]
            set parent_handle "none"
            set err \
             "-mode create requires a \"-parent_handle \$handle\" option pair"
            catch {
                set parent_handle [$type arg_pluck -parent_handle args $err]
            }

            if [$self cget -config-multiplier-option-groups] {
                # if no -multiplier supplied default value is 1
                set multiplier 1
                set err "???"
                catch { set multiplier [$type arg_pluck -multiplier args $err] }
            } else {
                # $type does not use the old multiplier option group
                # features. it's most likley a CPF capable object that uses
                # multivalues instead. So.. hardcode the param passed to
                # _multi_create below to '1'
                set multiplier 1
            }

            set rval [$type \
                _multi_create $multiplier $parent_handle $typepath $args]

            return $rval

        } elseif {[string equal $mode "add"]} {
            return [$self _resolving_add 1 1 $args]

        } elseif {[string equal $mode "modify"]} {
            set err "-mode create requires a \"-handle \$instance\" option pair"
            set inst [$type arg_pluck -handle args $err]
            if {![$type _handle_registry_exists $inst]} {
                return -code error "Cannot find -handle \"$inst\""
            }
            set rbaact [$type defaulted_arg_pluck \
                -read-back-attributes-and-check-them args 0]
            ::ixia::hag::ixn::types::shell _configure_instance $inst $args
            if {$rbaact} {
                ::ixia::hag::ixn::types::shell _rbaact_instance $inst $args
            }
            set inst_type  [$inst info type]
            array set gen_opts [set ${inst_type}::GenerateOptions]
            if {[lsearch $gen_opts(-sub-commands) "control"]>=0} {
                if {[catch {ixNet exec apply [$inst _ixn_handle]} err]} {
                    if {[string first "::ixNet::ERROR-no matching exec found" $err]<0} {
                        set parent_inst [$inst _ancestor 1];#-
                        set ixn_handle [$parent_inst _ixn_handle];#-
                        
                        if {[catch {ixNet exec apply $ixn_handle} err]} {
                            if {[string first "::ixNet::ERROR-no matching exec found" $err]<0} {
                                # CR1336323
                                # error $err
                            }
                        }
                    }
                }
            }

        } elseif {[string equal $mode "delete"]} {

            set err "-mode create requires a \"-handle \$instance\" option pair"
            set inst [$type arg_pluck -handle args $err]
            if {![$type _handle_registry_exists $inst]} {
                return -code error "Cannot find -handle \"$inst\""
            }
            if {[llength $args] != 0} {
                return -code error "illegal args \"$args\""
            }
            ::ixia::hag::ixn::types::shell _delete_instance $inst
            $type _handle_registry_remove $inst

        } else {
            return -code error "Uknown mode \"$mode\""
        }
    }

    typemethod abort {inst} {
        $inst _trace "Abort.. "
        $type _ixn_eval ixNet exec abort [$inst _ixn_handle]
        $inst _tr "done"
    }
    typemethod abort_async {inst} {
        $inst _trace "Abort async.. "
        $type _ixn_eval ixNet exec abort [$inst _ixn_handle] async
        $inst _tr "done"
    }
    typemethod start {inst} {
        $inst _trace "Start.. "
        $type _ixn_eval ixNet exec start [$inst _ixn_handle]
        $inst _tr "done"
    }
    typemethod stop {inst} {
        $inst _trace "Stop.. "
        $type _ixn_eval ixNet exec stop [$inst _ixn_handle]
        $inst _tr "done"
    }
    method control {args} {
        array set o $args
        set syntax {Available -actions are:
        -action abort|start|stop -handles $list_of_handles
        -mode delete -handle $instance}
        set action [$type arg_pluck -action args $syntax]
        array set valid_actions {
            abort             abort
            abort_async       abort_async
            start             start
            stop              stop
            connect           start
            disconnect        stop
        }
        if {[lsearch -exact [array names valid_actions] $action] < 0} {
            return -code error "Illegal action $action: $syntax"
        }
        set action $valid_actions($action)
        set err "missing '-handles \$handle_list' option pair" 
        # allow either -handle or -handles
        catch {set handles [$type arg_pluck -handle args $err]}
        if {![info exists handles]} {
            set handles [$type arg_pluck -handles args $err]
        }
        foreach {inst} $handles {
            if {![$type _handle_registry_exists $inst]} {
                return -code error "Cannot find handle \"$inst\""
            }
            $inst $action
        }
        return ""
    }

    typemethod _hlt_port_string_for_inst {inst} {
        set vport_ixn_handle \
            [join [lrange [split [$inst _ixn_handle] "/"] 0 1] "/"]
        set connected_to [$type _ixn_eval \
            ixNet getAttribute $vport_ixn_handle -connectedTo]
        #---
        # (Get) list of chassis ip from ixn. this is used to 
        # so we can convert chassis address to chassis number
        # see (Parse) comment below
        #
        set ch_list [$type _ixn_chassis_ip_list]
        #---
        # (Parse)
        # ::ixNet::OBJ-/availableHardware/chassis:"10.1.1.1"/card:2/port:3
        #    into
        # chassis var w/ 10.1.1.1 
        # card var w/ 2  
        # port var w/ 3
        # and make a classic hlt style hlt_port_str 
        # using ::ixia::get_valid_chassis_id because chassis id is based on hltset
        #
        set tmp [lrange [split $connected_to "/"] end-2 end]
        set tmp [string map \
            {"\\" "" chassis: "" card: "" port: ""} $tmp]
        set tmp
        foreach {chassis card port} $tmp {break;}; #namedsplit
        # See (Get) comment above
        set chassis [::ixia::get_valid_chassis_id [expr [lsearch $ch_list $chassis]]]
        set hlt_port_str $chassis/$card/$port
        return $hlt_port_str
    }

    typemethod is_hlt_port_str {thing} {
        if {[regexp {^[0-9]+/[0-9]+/[0-9]+$} $thing]} {
            return 1 
        }
        return 0
    }

    method stats {args} {
        if {[llength $args] == 1} {set args [lindex $args 0]}
        set orig_args $args
        array set o $args
        set syntax {option pair: -handles $handle_list required}
        # allow either -port_handle -handle or -handles
        # _aggregate_stats is smart enought to tell the differerence
        # between a classic hlt 1/2/3 port designator 
        # and a hag instance handle
        catch {set ph [$type arg_pluck -port_handle args $syntax]}
        if {[info exists ph]} {
            if {![$type is_hlt_port_str $ph]} {
                return -code error "Illegal format '$handles' for -port_handle"
            }
            set type_pathways [$self cget -config-typepathways] 
            set hlist {}
            set available {}
            foreach {r_inst r_type} [$type _get_handle_registry] {
                # Make sure this handle is even in the /vport/* ixn domain
                # if not skip it
                if {![string match /vport/* $r_type]} {
                    continue
                }
                set hlt_port_string [$type _hlt_port_string_for_inst $r_inst]
                lappend available $hlt_port_string 
                if {[string equal $ph $hlt_port_string]} {
                    if {[lsearch -exact $type_pathways $r_type] >= 0} {
                        lappend hlist $r_inst
                    }
                }
            }
            if {[llength $hlist] == 0} {
                return -code error \
                "Cannot find instance for -port_handle string from options: $orig_args available handles are: [lsort -unique $available]"
            }
            set handles $hlist
        }

        if {![info exists handles]} {
            set handles [$type arg_pluck -handles args $syntax]
        }
        if {[llength $handles] == 0} {
            return
        }
        set first_type [[lindex $handles 0] _typepath]
        foreach {inst} $handles {
            if {![$type _handle_registry_exists $inst]} {
                return -code error "Cannot find handle \"$inst\""
            }
            if {[set t [[lindex $handles 0] _typepath]] != $first_type} {
                return -code error \
                "There are mixed types '$first_type' & '$t' in -handles"
            }
        }
        #
        # Call _aggregate_stats typemethod for 'inst' 
        #
        [$inst _get_var type] _aggregate_stats $handles
    }
}}

if {[llength [info commands ::ixia::hag::ixn::types::/]==0]} {
snit::type ::ixia::hag::ixn::types::/ {
  method _typepath {} {return "/"}
  method _typepath_split {p} { file split $p }
  method _typepath_parent {p} { file dirname $p }
  method _typepath_join {args} { eval [concat {file join} $args] }
  method _typepath_tail {p} { file tail $p}
  method _typepath_normalize {p} { regsub {[^/]+} [file normalize $p] {} }
  method _typepath_relativity {p} {
    set l 0; foreach {x} [$self _typepath_split $p] {
        if {$x !=  ".."} {break} else {incr l}
    }
    return $l
  }
  # Holds utils like _create_instance, etc..
  variable Shell ::ixia::hag::ixn::types::shell
  variable Multiplicity "kRequired"
  option -element_index -default "" -readonly true

  typevariable _TRACE -array {}
  typeconstructor {
      set _TRACE(IXN) 0
      if {[info exists ::env(IXIA_HLT_TRACE)]} {
          if {[string match *IXN* $::env(IXIA_HLT_TRACE)]} {
              set _TRACE(IXN) 1
          }
      }
  }

  method _add_ixn_subelement {element_inst element_name} {
    $Shell _add_ixn_subelement $self $element_inst $element_name
  }
  method _delete_ixn_subelement {i_ixn_handle} {
    set rval [$Shell _ixn_eval ixNet remove $i_ixn_handle]
    $Shell _ixn_eval ixNet commit
  }
  method _own_ixn_handle {} {return 0}
  method _ixn_handle {} {
    set rval [$Shell _ixn_eval ixNet getRoot]
    return $rval
  }
  method _set_ixn_handle {x {i_own_ixnhandle 0}} {
    if {[string equal $x [$self _ixn_handle]]} {
        return
    }
    return -code error "Bad value '$x'"
  }

  # Children created by us (not attached via external handle)
  variable Children ""; 
  method _get_var {n} {set $n}
  method _set_var {n v} {
    if {![info exists $n]} {
      return -code error "No such variable \"$n\""
    }
    set $n $v
  }
  method _descendant {i_typepath} {
    set rval $self
    foreach {elem} [$self _typepath_split $i_typepath] {
        set found 0
        set children [$rval _get_var Children]
        foreach {child child_mode} [$rval _get_var Children] {
            set t [$child _typepath_tail [$child _typepath]]
            if {[string equal $t $elem]} {
                set rval $child
                set found 1
                break;
            }
        }
        if {$found == 0} {
            return -code error \
                "$self: cannot find descendant $i_typepath"
        }
    }
    return $rval
  }

  method _parent {} {return ""}

}}


namespace eval ::ixia::hag::ixn::validate {}
if {[llength [info commands ::ixia::hag::ixn::validate::kInteger64]==0]} {
#----
proc ::ixia::hag::ixn::validate::kDouble {t v args} {
    if {![string is double $v] != 0} {
        return -code error "$t: $v is not a legal doulble."
    }
}
proc ::ixia::hag::ixn::validate::kInteger64 {t v args} {
    if {![string is integer $v] != 0} {
        return -code error "$t: $v is not a legal integer."
    }
}
proc ::ixia::hag::ixn::validate::kInteger {t v args} {
    if {![string is integer $v] != 0} {
        return -code error "$t: $v is not a legal integer."
    }
}
proc ::ixia::hag::ixn::validate::kBool {t v args} {
    if {![string is boolean $v] != 0} {
        return -code error "$t: $v is not a legal boolean."
    }
}
proc ::ixia::hag::ixn::validate::kSelect {t v args} {
}
proc ::ixia::hag::ixn::validate::kMultiValue {t v args} {
}
proc ::ixia::hag::ixn::validate::kString {t v args} {
}
proc ::ixia::hag::ixn::validate::kMAC {t v args} {
}
proc ::ixia::hag::ixn::validate::kEnumValue {t v args} {
}
proc ::ixia::hag::ixn::validate::kIP {t v args} {
}
proc ::ixia::hag::ixn::validate::kIPv4 {t v args} {
}
proc ::ixia::hag::ixn::validate::kIPv4 {t v args} {
}
proc ::ixia::hag::ixn::validate::kArray {t v args} {
}
proc ::ixia::hag::ixn::validate::kObjref {t v args} {
}
proc ::ixia::hag::ixn::noop {args} {
}

#----
}
