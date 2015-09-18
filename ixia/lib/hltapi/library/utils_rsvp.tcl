##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    utils_rsvp.tcl
#
# Purpose:
#     A script development library containing RSVP APIs for test automation 
#     with the Ixia chassis.
#
# Author:
#    Hasmik Shakaryan
#
# Usage:
#    package req Ixia
#
# Description:
#    The procedures contained within this library include:
#
# Requirements:
#     ixiaapiutils.tcl , a library containing TCL utilities
#     parseddashedargs.tcl , a library containing the proceDescr and 
#     parsedashedargds.tcl
#
# Variables:
#    To be added
#
# Keywords:
#    To be define
#
# Category:
#    To be define
#
################################################################################
#                                                                              #
#                                LEGAL  NOTICE:                                #
#                                ==============                                #
# The following code and documentation (hereinafter "the script") is an        #
# example script for demonstration purposes only.                              #
# The script is not a standard commercial product offered by Ixia and have     #
# been developed and is being provided for use only as indicated herein. The   #
# script [and all modifications, enhancements and updates thereto (whether     #
# made by Ixia and/or by the user and/or by a third party)] shall at all times #
# remain the property of Ixia.                                                 #
#                                                                              #
# Ixia does not warrant (i) that the functions contained in the script will    #
# meet the user's requirements or (ii) that the script will be without         #
# omissions or error-free.                                                     #
# THE SCRIPT IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, AND IXIA        #
# DISCLAIMS ALL WARRANTIES, EXPRESS, IMPLIED, STATUTORY OR OTHERWISE,          #
# INCLUDING BUT NOT LIMITED TO ANY WARRANTY OF MERCHANTABILITY AND FITNESS FOR #
# A PARTICULAR PURPOSE OR OF NON-INFRINGEMENT.                                 #
# THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SCRIPT  IS WITH THE #
# USER.                                                                        #
# IN NO EVENT SHALL IXIA BE LIABLE FOR ANY DAMAGES RESULTING FROM OR ARISING   #
# OUT OF THE USE OF, OR THE INABILITY TO USE THE SCRIPT OR ANY PART THEREOF,   #
# INCLUDING BUT NOT LIMITED TO ANY LOST PROFITS, LOST BUSINESS, LOST OR        #
# DAMAGED DATA OR SOFTWARE OR ANY INDIRECT, INCIDENTAL, PUNITIVE OR            #
# CONSEQUENTIAL DAMAGES, EVEN IF IXIA HAS BEEN ADVISED OF THE POSSIBILITY OF   #
# SUCH DAMAGES IN ADVANCE.                                                     #
# Ixia will not be required to provide any software maintenance or support     #
# services of any kind (e.g., any error corrections) in connection with the    #
# script or any part thereof. The user acknowledges that although Ixia may     #
# from time to time and in its sole discretion provide maintenance or support  #
# services for the script, any such services are subject to the warranty and   #
# damages limitations set forth herein and will not obligate Ixia to provide   #
# any additional maintenance or support services.                              #
#                                                                              #
################################################################################


##Internal Procedure Header
# Name:
#    ::ixia::initializeRsvp
#
# Description:
#    This command initializes the rsvp to its initial default configuration.
#
# Synopsis:
#
# Arguments:
#    chasNum - chassis ID
#    cardNum - load module number
#    portNum - port number
#
# Return Values:
#    0 - no error found
#    1 - error found
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::initializeRsvp {chasNum cardNum portNum} \
{
    set retCode $::TCL_OK

    if {[rsvpServer select $chasNum $cardNum $portNum]} {
        set retCode $::TCL_ERROR
    }

    if {[rsvpServer clearAllNeighborPair]} {
        set retCode $::TCL_ERROR
    }

    return $retCode
}


##Internal Procedure Header
# Name:
#    ::ixia::getNextNeighborPair
#
# Description:
#    This command gets the next neigbor pair value
#
# Synopsis:
#
# Arguments:
#
# Return Values:
#    Returns the next neighbor pair value to be used
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::getNextNeighborPair {portHandle} \
{
    # This is a static variable only used in this procedure
    variable sCurrNeighborPair

    if {![info exists sCurrNeighborPair]} {
        set sCurrNeighborPair  1
    } else {
        incr sCurrNeighborPair
    }

    return NeighborPair${portHandle}_$sCurrNeighborPair        
}


##Internal Procedure Header
# Name:
#    ::ixia::getNextDestinationRange
#
# Description:
#    This command gets the next destination range value
#
# Synopsis:
#
# Arguments:
#
# Return Values:
#    Returns the next destination range to be used
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::getNextDestinationRange {} \
{
    # This is a static variable only used in this procedure
    variable sCurrDestinationRange

    if {![info exists sCurrDestinationRange]} {
        set sCurrDestinationRange  1
    } else {
        incr sCurrDestinationRange
    }

    return DestinationRange$sCurrDestinationRange        
}


##Internal Procedure Header
# Name:
#    ::ixia::getNextSenderRange
#
# Description:
#    This command gets the next SenderRange value
#
# Synopsis:
#
# Arguments:
#
# Return Values:
#    Returns the next sender range value to use
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::getNextSenderRange {} \
{
    # This is a static variable only used in this procedure
    variable sCurrSenderRange

    if {![info exists sCurrSenderRange]} {
        set sCurrSenderRange  1
    } else {
        incr sCurrSenderRange
    }

    return SenderRange$sCurrSenderRange        
}


##Internal Procedure Header
# Name:
#    ::ixia::resetRsvpGlobals
#
# Description:
#    Unsets the namespace variables for RSVP information
#
# Synopsis:
#    ::ixia::resetRsvpGlobals
#
# Arguments:
#
# Return Values:
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::resetRsvpGlobals {} \
{
    variable sCurrSenderRange
    variable sCurrDestinationRange
    variable sCurrNeighborPair

    catch { unset sCurrSenderRange }
    catch { unset sCurrDestinationRange }
    catch { unset sCurrNeighborPair }
}


##Internal Procedure Header
# Name:
#    ::ixia::updateRsvpHandleArray
#
# Description:
#    This command creates or deletes an element in rsvp_handles_array.
#
#    An element in rsvp_handles_array is in the form of
#         (session_handle,session)        value:port_handle
#           or
#         (tunnel_handle,tunnel)          value:session_handle
#           or
#         (session_handle,tunnelOptions)  value:list of {option value} pair
#         for example:
#                   {mtu                            512}
#                   {path_state_refresh_timeout     100}
#                   {path_state_refresh_count       5  }
#                   {record_route                   2  }
#                   {resv_confirm                   1  }
#                   {path_state_refresh_timeout     50 }
#                   {path_state_refresh_count       3  }
#                   {egress_label_mode              next}
#                   ....
#    where session_handle and tunnel_handle is the rsvp handles.
#
# Synopsis:
#    [-mode        CHOICES create delete reset]
#    [-handle_type CHOICES session tunnel]
#    [-handle ]
#    [-handle_value ]
#
# Arguments:
#    -mode
#        create - creates a new handle in rsvp_handles_array
#        delete - deletes an existing handle in rsvp_handles_array
#        reset  - resets a session handle by deleting all tunnel handles
#                 created on that session or resets a port handle by deleting
#                 all sessions and tunnels on that port
#    -handle_type
#        The type of handle that needs to be added: session or tunnel.
#    -handle
#        The name of the handle that needs to be created/deleted.
#    -handle_value
#        The value in rsvp_handles_array that needs to be added or that needs
#        to be checked for reset.
#
# Return Values:
#    A keyed list
#    key:status              value:$::SUCCESS | $::FAILURE
#    key:log                 value:If status is failure, detailed information
#                                  provided.
#
# Examples:
#    [array get rsvp_handles_array] shows:
#    NeighborPair1/1/3_1,session       1/1/3
#    NeighborPair1/1/3_1,tunnelOptions {
#        {refresh_interval 200}
#        {path_state_refresh_timeout 77}
#        {path_state_timeout_count 5}
#        {record_route 1}
#        {resv_confirm 1}
#        {resv_state_refresh_timeout 5}
#        {resv_state_timeout_count 5}
#        {egress_label_mode nextlabel}
#    }
#    DestinationRange1,tunnel          NeighborPair1/1/3_1
#    DestinationRange2,tunnel          NeighborPair1/1/3_1
#    DestinationRange3,tunnel          NeighborPair1/1/3_1
# 
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::updateRsvpHandleArray {args} {
    variable  rsvp_handles_array
    
    # Arguments
    set opt_args {
        -mode        CHOICES create delete reset
        -handle_type CHOICES session tunnel
        -handle
        -handle_value
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args  \
                    -optional_args $opt_args} retCode]} {
        keylset returnList status $::FAILURE
        keylset returnList log $retCode
        return $returnList
    }
    
    switch $mode {
        create {
            # Parameters needed: -handle, -handle_type, -handle_value
            set rsvp_handles_array($handle,$handle_type) [list $handle_value]
        }
        delete {
            # Parameters needed: -handle
            # 
            # Unset the handle in array
            array unset rsvp_handles_array ${handle}*
            # Unset all handles created on $handle
            foreach {index value} [array get rsvp_handles_array] {
                if {$value == $handle} {
                    unset rsvp_handles_array($index)
                }
            }
        }
        reset {
            # Parameters needed: -handle_value
            # 
            # Unset all handles that have the value $handle_value
            set unsetHandles ""
            foreach {index value} [array get rsvp_handles_array] {
                if {$value == $handle_value} {
                    array unset rsvp_handles_array \
                            "[lindex [split $index ,] 0]*"
                    lappend unsetHandles [lindex [split $index ,] 0]
                }
            }
            # Unset all handles that have the value $handle
            foreach {handle} $unsetHandles {
                foreach {index value} [array get rsvp_handles_array] {
                    if {$value == $handle} {
                        array unset rsvp_handles_array \
                                "[lindex [split $index ,] 0]*"
                    }
                }
            }
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::writeRsvpHandleOptions
#
# Description:
#    Creates an entry in rsvp_handles_array with optionType
#
# Synopsis:
#    ::ixia::writeRsvpHandleOptions
#
# Arguments:
#    handle - rsvp handle
#    optionType - entry type
#    optionList - value for the new entry
#
# Return Values:
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::writeRsvpHandleOptions {handle optionType optionsList} {                                           
    variable  rsvp_handles_array

    set rsvp_handles_array($handle,$optionType) $optionsList

}


##Internal Procedure Header
# Name:
#    :ixia::getRsvpHandleOptions
#
# Description:
#    Returns the value of the entry in rsvp_handles_array for a optionType
#
# Synopsis:
#    
# Arguments:
#    handle - rsvp handle
#    optionType - entry type
#
# Return Values:
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::getRsvpHandleOptions {handle optionType} {                                           
    variable  rsvp_handles_array

    set procName [lindex [info level [info level]] 0]       
    set retCode $::TCL_OK

    set rsvpHandleList [array get rsvp_handles_array]
    set match [lsearch $rsvpHandleList $handle,$optionType]
    if {$match >= 0} {
        return $rsvp_handles_array($handle,$optionType)
    } else {
        puts "Error in $procName:  Cannot find the options for $handle in \
                                   rsvp_handle_array"
        set retCode $::TCL_ERROR
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::rsvpAddRroItems
#
# Description:
#    Adds the RRO items to the rsvpDestinationRange object
#
# Synopsis:    
#
# Arguments:
#
# Return Values:
#    returnList with status indicating $::FAILURE or $::SUCCESS
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::rsvpAddRroItems {} {

    set procName [lindex [info level [info level]] 0]       
    
    set rro_var_list {
        mode 
        rro_list_type
        rro_list_ipv4
        rro_list_label
        rro_list_flags
        rro_list_ctype
        rsvpRroItem
        rsvpEroItem
        enumList
    }
    foreach item $rro_var_list {
        upvar $item $item
    }
    if {$mode == "modify"} {
        foreach item $rro_var_list {
            if {![info exists $item]} {
                keylset returnList status $::SUCCESS
                return $returnList
            }
        }
    }
    

    if {![info exists rro_list_type]} {
        keylset returnList log "Parameter rro_list_type must be provided."
        keylset returnList status $::FAILURE
        return $returnList
    }

    if {$rro_list_type == "ipv4"} {
        set rro_ipv4_var_list {rro_list_ipv4 rro_list_flags}
        foreach option $rro_ipv4_var_list {
            if {![info exists $option]} {
                keylset returnList log "Parameter $option must be provided"
                keylset returnList status $::FAILURE
                return $returnList
            }
        }

        set num_item [llength $rro_list_ipv4]
        if {([llength $rro_list_flags] != $num_item)} {
            keylset returnList log "ERROR in $procName: number of\
                  items in rro_list_ipv4 and rro_list_flags must be the same."                    
            keylset returnList status $::FAILURE
            return $returnList
        }

        for {set i 0} {$i < $num_item} {incr i} {
            set local_rro_ipv4 [lindex $rro_list_ipv4 $i]
            set rro_flags [lindex $rro_list_flags $i]
            set local_protection_in_use [expr ($rro_flags & 0x02) >> 1]
            set local_protection_available [expr $rro_flags & 0x01]
            set local_bandwidth_protection [expr ($rro_flags & 0x04) >> 2]                                                                        
            set local_node_protection      [expr ($rro_flags & 0x08) >> 3]
            foreach item [array names rsvpRroItem] {
                if {![catch {set $rsvpRroItem($item)} value] } {
                    if {[lsearch [array names enumList] $value] != -1} {
                        set value $enumList($value)
                    }
                    catch { rsvpRroItem config -$item $value }
                }
            }
            if {[rsvpDestinationRange addRroItem]} {
                keylset returnList log "Failed on\
                        rsvpDestinationRange addRroItem on \
                        port $chasNum $cardNum $portNum."
                keylset returnList status $::FAILURE
                return $returnList
            }
       }
    } elseif {$rro_list_type == "label"} { 
        ### note rro_list_ctype is Ixia only option; therefore not mandatory
        set rro_label_var_list {rro_list_label rro_list_flags}
        foreach option $rro_label_var_list {
            if {![info exists $option]} {
                keylset returnList log "Parameter $option must be provided."
                keylset returnList status $::FAILURE
                return $returnList
            }
        }

        set num_item [llength $rro_list_label]
        if {([llength $rro_list_flags] != $num_item)} {
            keylset returnList log "The number of items in \
                    rro_list_label and rro_list_flags must be the same."                    
            keylset returnList status $::FAILURE
            return $returnList
        }

        for {set i 0} {$i < $num_item} {incr i} {
            set local_rro_label [lindex $rro_list_label $i]
            set rro_flags [lindex $rro_list_flags $i]
            catch {set local_rro_ctype [lindex $rro_list_ctype $i]}
            set local_enable_global_label [expr $rro_flags & 0x01]       
            set local_bandwidth_protection [expr ($rro_flags & 0x04) >> 2]                                                                        
            set local_node_protection      [expr ($rro_flags & 0x08) >> 3]
            foreach item [array names rsvpRroItem] {
                if {![catch {set $rsvpRroItem($item)} value] } {
                    if {[lsearch [array names enumList] $value] != -1} {
                        set value $enumList($value)
                    }
                    catch { rsvpRroItem config -$item $value }
                }
            }
            if {[rsvpDestinationRange addRroItem]} {
                keylset returnList log "Failed on\
                        rsvpDestinationRange addRroItem on \
                        port $chasNum $cardNum $portNum."
                keylset returnList status $::FAILURE
                return $returnList
            }
       }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}



##Internal Procedure Header
# Name:
#    ::ixia::rsvpAddEroItems
#
# Description:
#    Adds the ERO items to the rsvpDestinationRange object  
#
# Synopsis:   
#
# Arguments:
#
# Return Values:
#    returnList with status indicating $::FAILURE or $::SUCCESS
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::rsvpAddEroItems {} {

    set procName [lindex [info level [info level]] 0]       
    
    set ero_var_list {ero_list_type ero_list_loose ero_list_ipv4 \
             ero_list_pfxlen ero_list_as_num rsvpEroItem enumList}

    foreach item $ero_var_list {
        upvar $item $item
    }

    if {![info exists ero_list_type]} {
        keylset returnList log "ERROR in $procName:\
                ero_list_type does not exist."
        keylset returnList status $::FAILURE
        return $returnList
    }

    if {$ero_list_type == "ipv4"} {
        set ero_ipv4_var_list {ero_list_ipv4 ero_list_loose ero_list_pfxlen}
        foreach option $ero_ipv4_var_list {
            if {![info exists $option]} {
                keylset returnList log "ERROR in $procName:\
                        $option does not exist."
                keylset returnList status $::FAILURE
                return $returnList
            }
        }

        set num_item [llength $ero_list_ipv4]
        if {([llength $ero_list_loose] != $num_item) || \
                    ([llength $ero_list_pfxlen] != $num_item) } {
            keylset returnList log "ERROR in $procName: number of\
                    items in ero_list_ipv4, and ero_list_loose and\
                    ero_list_pfxlen must be the same."                                    
            keylset returnList status $::FAILURE
            return $returnList
        }

        for {set i 0} {$i < $num_item} {incr i} {
            set local_ero_ipv4 [lindex $ero_list_ipv4 $i]
            set local_ero_loose [lindex $ero_list_loose $i]
            set local_ero_pfxlen [lindex $ero_list_pfxlen $i]
            foreach item [array names rsvpEroItem] {
                if {![catch {set $rsvpEroItem($item)} value] } {
                    if {[lsearch [array names enumList] $value] != -1} {
                        set value $enumList($value)
                    }
                    catch { rsvpEroItem config -$item $value }
                }
            }
            if {[rsvpDestinationRange addEroItem]} {
                keylset returnList log "ERROR in $procName: Failed on\
                        rsvpDestinationRange addEroItem on \
                        port $chasNum $cardNum $portNum."
                keylset returnList status $::FAILURE
                return $returnList
            }
       }
    } elseif {$ero_list_type == "as"} { 
        set ero_label_var_list {ero_list_as_num ero_list_loose}
        foreach option $ero_label_var_list {
            if {![info exists $option]} {
                keylset returnList log "ERROR in $procName:\
                        $option does not exists"
                keylset returnList status $::FAILURE
                return $returnList
            }
        }

        set num_item [llength $ero_list_as_num]
        if {([llength $ero_list_loose] != $num_item) } {
            keylset returnList log "ERROR in $procName: number of\
                    items in ero_list_as_num, and ero_list_loose\
                    must be the same."                                      
            keylset returnList status $::FAILURE
            return $returnList
        }


        for {set i 0} {$i < $num_item} {incr i} {
            set local_ero_as_num [lindex $ero_list_as_num $i]
            set local_ero_loose [lindex $ero_list_loose $i]
            foreach item [array names rsvpEroItem] {
                if {![catch {set $rsvpEroItem($item)} value] } {
                    if {[lsearch [array names enumList] $value] != -1} {
                        set value $enumList($value)
                    }
                    catch { rsvpEroItem config -$item $value }
                }
            }
            if {[rsvpDestinationRange addEroItem]} {
                keylset returnList log "ERROR in $procName: Failed on\
                        rsvpDestinationRange addEroItem on \
                        port $chasNum $cardNum $portNum."
                keylset returnList status $::FAILURE
                return $returnList
            }
       }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}      



##Internal Procedure Header
# Name:
#    ::ixia::getRsvpTunnelLabelList
#
# Description:
#    This proc returns the list of tunnel id & label pair for a RSVP neighbor
#    or all configured RSVP neighbors on the specified port
#
# Synopsis:   
#
# Arguments:
#   portHandle      - port handle
#   neighborPairId  - neiborPair label Id.  If this is NULL,  all the RSVP neibor
#                     neibor pair configured on the port is checked for the label.
#
# Return Values:
#    returnList key::status indicating $::FAILURE or $::SUCCESS
#    returnList key::labelList  list of tunnel label pair
#    returnList key::log        log messages
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#  
#################################################################################
proc ::ixia::getRsvpTunnelLabelList {portHandle {neighborPairId NULL}} \
{       
    set procName [lindex [info level [info level]] 0] 
          
    scan $portHandle "%d/%d/%d" chas card port

    if {[rsvpServer select $chas $card $port]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to\
                rsvpServer select $chas $card $port."
        return $returnList
    }
    
    set rsvpLabelList [list]
    if {$neighborPairId == "NULL"} {
        if {[rsvpServer getFirstNeighborPair]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to rsvpServer getFirstNeighborPair. \
                    There are no RSVP sessions on port $chas $card $port."
            return $returnList
        }
        if {[rsvpNeighborPair requestRxLabels]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to rsvpNeighborPair requestRxLabels"
            return $returnList
        }

        set getLabelStatus  [getRsvpLabels rsvpLabelList]
        set getNextNeighbor [rsvpServer getNextNeighborPair]
        while {$getNextNeighbor == 0} {
            if {[rsvpNeighborPair requestRxLabels]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to\
                        rsvpNeighborPair requestRxLabels"
                return $returnList
            }
            set getLabelStatus  [getRsvpLabels rsvpLabelList]
            set getNextNeighbor [rsvpServer getNextNeighborPair]
        }
     } else {
        if {[rsvpServer getNeighborPair $neighborPairId]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to\
                    rsvpServer getNeighborPair $neighborPairId"
            return $returnList
        }

        if {[rsvpNeighborPair requestRxLabels]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to rsvpNeighborPair requestRxLabels"
            return $returnList
        }

        set getLabelStatus [getRsvpLabels rsvpLabelList]
     }
     keylset returnList status    $::SUCCESS
     keylset returnList labelList $rsvpLabelList
     return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::getRsvpLabels
#
# Description:
#    returns rsvpLabelList for the current RSVP neighborPair.  Prior to calling  
#    this function,  "rsvpServer getNeighborPair" & "rsvpNeighborPair
#    requestRxLabels" must be called first.
#
# Synopsis:   
#
# Arguments:
#   RsvpLabelList - list of label IDs and lsp_tunnel pair.  This is filled
#                   in by this proc.
#
# Return Values:
#    returnList key::status indicating $::FAILURE or $::SUCCESS
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#  
#################################################################################
proc ::ixia::getRsvpLabels {RsvpLabelList} \
{
    upvar $RsvpLabelList rsvpLabelList

    set procName [lindex [info level [info level]] 0]       
    set delayTime   10  

    for {set timer 0} {$timer < $delayTime } {incr timer} {         
        if [rsvpNeighborPair getLabels] {
            ixPuts "Getting labels ..."
            after 1000
        }  else {
            break
        }
    }

    if { [rsvpNeighborPair getFirstLabel] } {
        keylset returnList status $::FAILURE
        return $returnList
    } else {
        lappend rsvpLabelList [list [rsvpNeighborPair cget -lsp_tunnel]\
                             [rsvpNeighborPair cget -rxLabel]]

        while {![rsvpNeighborPair getNextLabel]} {
          lappend rsvpLabelList [list [rsvpNeighborPair cget -lsp_tunnel]\
                            [rsvpNeighborPair cget -rxLabel]]
        } 
    }
    keylset returnList status $::SUCCESS
    return $returnList
}



##Internal Procedure Header
# Name:
#    ::ixia::rsvpNeighborPairAction
#
# Description:
#    This proc enables or disables the rsvpNeighborPair
#
# Synopsis:   
#
# Arguments:
#    portList   - port list
#    rsvpHandle - rsvp neighborPair handle
#    action     - $::true for enable; $::false for disable
#
# Return Values:
#    returnList key::status indicating $::FAILURE or $::SUCCESS
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#  
###############################################################################
proc ::ixia::rsvpNeighborPairAction {portList rsvpHandle action} \
{
    set procName [lindex [info level [info level]] 0]

    scan [lindex $portList 0] "%d %d %d" chasNum cardNum portNum
    if {[rsvpServer select $chasNum $cardNum $portNum]} {
        keylset returnList log "ERROR in $procName: Failed on rsvpServer select\
                $chasNum $cardNum $portNum call."
        keylset returnList status $::FAILURE
        return $returnList
    }

    if {[rsvpServer getNeighborPair $rsvpHandle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed on rsvpServer\
                getNeighborPair $rsvpHandle call on port $chasNum $cardNum\
                $portNum."
        return $returnList
    }

    rsvpNeighborPair config -enableNeighborPair $action

    if {[rsvpServer setNeighborPair $rsvpHandle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed on rsvpServer\
                setNeighborPair $rsvpHandle call on port $chasNum $cardNum\
                $portNum."
        return $returnList
    }

    keylset returnList status $::SUCCESS
    return $returnList
}



##Internal Procedure Header
# Name:
#    ::ixia::rsvpTunnelAction
#
# Description:
#
# Synopsis:   
#    This proc enables or disables the rsvp tunnels 
#
# Synopsis:   
#
# Arguments:
#    portList - port list
#    rsvpHandle - rsvp neighborPair handle
#    tunnelHandleList - list of tunnel handles
#    action     - $::true for enable; $::false for disable
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#  
###############################################################################
proc ::ixia::rsvpTunnelAction {portList rsvpHandle tunnelHandleList action} \
{
    set procName [lindex [info level [info level]] 0]
    
    scan [lindex $portList 0] "%d %d %d" chasNum cardNum portNum
    if {[rsvpServer select $chasNum $cardNum $portNum]} {
        keylset returnList log "ERROR in $procName: Failed on rsvpServer\
                select $chasNum $cardNum $portNum call."
        keylset returnList status $::FAILURE
        return $returnList
    }

    if {[rsvpServer getNeighborPair $rsvpHandle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed on rsvpServer\
                getNeighborPair $rsvpHandle call on port $chasNum $cardNum\
                $portNum."
        return $returnList
    }

    foreach tunnelHandle $tunnelHandleList {
        if {[rsvpNeighborPair getDestinationRange $tunnelHandle] } {
            keylset returnList log "ERROR in $procName: Failed on\
                    rsvpNeighborPair getDestinationRange $tunnelHandle on\
                    port $chasNum $cardNum $portNum."
            keylset returnList status $::FAILURE
            return $returnList
        }
        rsvpDestinationRange config -enableDestinationRange $action

        if {[rsvpNeighborPair setDestinationRange $tunnelHandle] } {
            keylset returnList log "ERROR in $procName: Failed on\
                    rsvpNeighborPair setDestinationRange $tunnelHandle on\
                    port $chasNum $cardNum $portNum."
            keylset returnList status $::FAILURE
            return $returnList
        }
    }

    if {[rsvpServer setNeighborPair $rsvpHandle]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed on rsvpServer\
                setNeighborPair $rsvpHandle call on port $chasNum $cardNum\
                $portNum."
        return $returnList
    }

    keylset returnList status $::SUCCESS
    return $returnList
}