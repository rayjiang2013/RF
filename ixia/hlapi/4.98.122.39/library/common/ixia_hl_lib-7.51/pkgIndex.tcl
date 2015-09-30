#
# ixiahltgenerated
#
proc _load_ixiahltgenerated_7.51 {dir} {
    foreach {f} [lsort [glob $dir/*.x.tcl]] { uplevel #0 [list source $f] }
    uplevel #0 {package provide ixiahltgenerated 7.51}
}
package ifneeded ixiahltgenerated 7.51 [list _load_ixiahltgenerated_7.51 $dir]

