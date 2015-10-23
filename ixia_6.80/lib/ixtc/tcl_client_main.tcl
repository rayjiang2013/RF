namespace eval ix_tc {}

package provide ix_tc 3.60.0.4

set currDir [file dirname [info script]]
source [file join $currDir tcl_client_logger.tcl]
source [file join $currDir tcl_client_comm.tcl]
source [file join $currDir tcl_client_step.tcl]
source [file join $currDir tcl_client_parallelism.tcl]
source [file join $currDir tcl_client_event_processor.tcl]
source [file join $currDir tclLib.tcl]