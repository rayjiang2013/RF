
# export the namespace to the outside world
namespace eval ::ixiangpf:: {
    namespace export \
        compile type widget widgetadaptor typemethod method macro
}

# define constants
set ::ixiangpf::NONE "NO-OPTION-SELECTED-ECF9612A-0DA3-4096-88B3-3941A60BA0F5"

# now, source all tcl files in the folder
foreach fileName [glob -nocomplain *.tcl] {
	if {$fileName != "ixiangpf.tcl"} {
		if { [catch {
		source $fileName
		} errmsg] } {puts "Error sourcing $fileName: $errmsg"}
	}
}
