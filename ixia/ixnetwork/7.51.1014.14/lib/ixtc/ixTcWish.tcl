namespace eval ix_tc_install {
    # this file should be in $installDir/ptixia\bin\win\client\script_gen,
    # and should add current directory to auto_path.
    set runningFromDir [file dirname [info script]]
    
    lappend ::auto_path $runningFromDir
}

catch {
    # Try to set things up for Wish.
    if {[lsearch [package names] "Tk"] >= 0} {
        console show
    }
}
