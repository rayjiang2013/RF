
Dependencies:
1. TCL interpreter >= version 8.4


Instructions for testing:

1. Extract the compressed tar file on a client system with a TCL interpreter >= version 8.4 
2. Start the TCL shell or wish console on the client system and execute the following commands: 
	- lappend auto_path <directory where the compressed tar file was extracted to>
	- package req IxTclNetwork # should return a version number
	- ixNet connect <IxNetwork TCL Server address> # should return ::ixNet::OK

