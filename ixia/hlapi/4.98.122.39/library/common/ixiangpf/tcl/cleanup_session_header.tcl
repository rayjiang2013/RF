##Procedure Header
# Name:
#    ::ixiangpf::cleanup_session
#
# Description:
#    This command disconnects from chassis, IxNetwork Tcl Server and Tcl Server,
#    resets to factory defaults, and removes ownership from a list of ports.
#    This command can be used after a script is run.
#
# Synopsis:
#    ::ixiangpf::cleanup_session
#x       [-port_handle                  REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
#        [-maintain_lock                CHOICES 1 0
#                                       CHOICES 0 1]
#x       [-clear_csv                    CHOICES 0 1]
#x       [-skip_wait_pending_operations FLAG]
#x       [-reset                        FLAG]
#n       [-handle                       ANY]
#
# Arguments:
#x   -port_handle
#x       List ports to release.
#x       When using IxTclHal, IxTclProtocol or IxTclAccess, -port_handle option
#x       should always be present, otherwise only the disconnect part will be
#x       completed.
#    -maintain_lock
#        When using IxNetwork with the -reset option, this parameter will be
#        ignored.
#x   -clear_csv
#x       Valid choices are:
#x       0 - The CSV files are not deleted after cleanup_session procedure is called
#x       1 - The CSV files created after calling traffic_stats are deleted
#x   -skip_wait_pending_operations
#x       If there are any disconnect operations issued, this flag will prevent
#x       procedure from waiting for them to end. If this flag is used then
#x       there is no warrantythat the disconnect operations have ended and
#x       exiting the script with these operations still running can be the
#x       source of errors.
#x   -reset
#x       Reset the ports to factory defaults before releasing them.
#x       When using IxTclHal and IxTclProtocol, -port_handle option should be
#x       present also, otherwise the reset will not be completed.
#n   -handle
#n       This argument defined by Cisco is not supported for NGPF implementation.
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status  value:$::SUCCESS | $::FAILURE
#    On status of failure, gives detailed information.
#    key:log     value:On status of failure, gives detailed information.
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    Coded versus functional specification.
#
# See Also:
#

