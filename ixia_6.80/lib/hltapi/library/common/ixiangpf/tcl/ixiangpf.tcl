
# export the namespace to the outside world
namespace eval ::ixiangpf:: {
    namespace export \
        compile type widget widgetadaptor typemethod method macro
}

# now, source all tcl files in the folder
foreach fileName [glob -nocomplain *.tcl] {
	if {$fileName != "ixiangpf.tcl"} {
		if { [catch {
		source $fileName
		} errmsg] } {puts "Error sourcing $fileName: $errmsg"}
	}
}
