##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    utils_dhcp.tcl
#
# Purpose:
#    A script development library containing DHCP APIs for test automation with
#    the Ixia chassis.
#
# Author:
#    Ixia engineering, direct all communication to support@ixiacom.com
#
# Usage:
#
# Description:
#    The procedures contained within this library include:
#
#    -dhcpCreateInterfaces
#    -dhcpGetNextHandle
#    -dhcpRequestDiscoveredTable
#    -resetDhcpHandleArray
#    -ixa_emulation_dhcp_config
#    -ixa_emulation_dhcp_group_config
#    -ixa_emulation_dhcp_stats
#    -ixaDhcpCreateInterfaces
#    -ixaResetDhcpHandleArray
#
# Requirements:
#    ixiaapiutils.tcl, a library containing TCL utilities
#    parseddashedargs.tcl, a library containing the procDescr
#
# Variables:
#
# Keywords:
#
# Category:
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
# meet the user’s requirements or (ii) that the script will be without         #
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
#    ::ixia::dhcpGetNextHandle
#
# Description:
#    Given a handle name and a handle type (session|group)
#    it returns the next session|group handle from dhcp_handles_array.
#
# Synopsis:
#    ::ixia::dhcpGetNextHandle
#        handle_name
#        handle_type
#
# Arguments:
#        handle_name
#            dhcpSession or dhcpGroup
#        handle_type
#            session or group
#
# Return Values:
#    A key list
#    key:status       value:$::SUCCESS | $::FAILURE
#    key:log          value:If status is failure, detailed information
#                     provided
#    key:next_handle  value:the next available session|group handle
#                     from dhcp_handles_array
#    key:next_id      value: the id of the next available handle
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
#
proc ::ixia::dhcpGetNextHandle {handle_name handle_type} {
    variable dhcp_handles_array
    keylset returnList status $::SUCCESS

    set allHandles ""
    foreach {index value} [array get dhcp_handles_array] {
        set i1 [lindex [split $index ,] 0]
        set i2 [lindex [split $index ,] 1]
        if {$i2 == $handle_type} {
            lappend allHandles $i1
        }
    }

    if {[llength $allHandles] == 0} {
        keylset returnList next_handle ${handle_name}1
        keylset returnList next_id     1
        return $returnList
    } else  {
        set allHandles [lsort -dictionary $allHandles]
        set pattern ""
        append pattern $handle_name "(\[0-9\]+)"
        regsub -all $pattern $allHandles {\1} allHandles

        if {[llength $allHandles] == 1} {
            incr allHandles
            keylset returnList next_handle ${handle_name}${allHandles}
            keylset returnList next_id     $allHandles
            return $returnList
        }
        if {[lindex $allHandles 0]>1} {
            keylset returnList next_handle ${handle_name}1
            keylset returnList next_id     1
            return $returnList
        }

        set i 0
        while {([mpexpr \
                    [lindex $allHandles [mpexpr $i + 1]] \
                    - \
                    [lindex $allHandles $i]] == 1) && \
                    ($i < [llength $allHandles])} {
            incr i
        }

        if {$i == [llength $allHandles]} {
            set handle_num [mpexpr [lindex $allHandles end] + 1]
        } else  {
            set handle_num [mpexpr [lindex $allHandles $i] + 1]
        }

        keylset returnList next_handle ${handle_name}${handle_num}
        keylset returnList next_id     $handle_num
        return $returnList
    }
}

##Internal Procedure Header
# Name:
#    ::ixia::dhcpCreateInterfaces
#
# Description:
#     Creates interfaces for a given group handle.
#
# Synopsis:
#    ::ixia::dhcpCreateInterfaces
#            List of all params:
#            - defaults or user specified - for Create mode
#            - changed (user specified) or the old values - for Modify mode
#
# Arguments:
#    mode num_sessions handle encap vlan_id vlan_id_step vlan_id_count vci vpi
#    vci_count vci_step vpi_count vpi_step sessions_per_vc pvc_incr_mode
#    mac_addr mac_addr_step vlan_priority
#
# Return Values:
#    A key list
#    key:status       value:$::SUCCESS | $::FAILURE
#    key:log          value:If status is failure, detailed information provided
#    key:next_handle  value:
#
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
#
proc ::ixia::dhcpCreateInterfaces {args} {
    variable dhcp_handles_array

    set procName [lindex [info level [info level]] 0]

    set mandatory_args {
        -mode               CHOICES create modify
        -handle
    }

    set optional_args {
        -mac_addr           MAC
        -mac_addr_step      MAC
        -num_sessions       RANGE 1-65536
        -encap              CHOICES ethernet_ii ethernet_ii_vlan vc_mux llcsnap
        -vlan_id            RANGE 0-4095
        -vlan_id_step       RANGE 0-4095
        -vlan_id_count      RANGE 0-4095
        -vci                RANGE 0-65535
        -vpi                RANGE 0-255
        -vci_count          RANGE 0-65535
        -vci_step           NUMERIC
        -vpi_count          RANGE 0-255
        -vpi_step           NUMERIC
        -sessions_per_vc    RANGE 1-65535
        -pvc_incr_mode      CHOICES vci vpi
        -vlan_priority      RANGE 0-7
        -server_id          IP
        -vendor_id
        -lease_time         RANGE 0-65535
        -max_dhcp_msg_size  RANGE 0-65535
        -target_subport     RANGE 0-3
                            DEFAULT 0
        -group_handle
    }

    set retCode [::ixia::parse_dashed_args -args $args -optional_args \
            $optional_args -mandatory_args $mandatory_args]

    set dhcpParamList [list mode num_sessions handle group_handle encap vlan_id \
            vlan_id_step vlan_id_count vci vpi vci_count vci_step vpi_count \
            vpi_step sessions_per_vc pvc_incr_mode mac_addr mac_addr_step \
            vlan_priority server_id vendor_id]

    if {$encap == "ethernet_ii"} {
        set useless_params [list vlan_id vlan_id_step vlan_id_count vlan_priority \
                vci vpi vci_count vpi_count vci_step vpi_step sessions_per_vc \
                pvc_incr_mode]
        foreach param $useless_params {
            if {[info exists $param]} {
                unset $param
            }
        }
    }

    set vlan_enable 0
    if {$encap == "ethernet_ii_vlan"} {
        set vlan_enable 1
        set useless_params [list vci vpi vci_count vpi_count vci_step vpi_step \
                sessions_per_vc pvc_incr_mode]
        foreach param $useless_params {
            if {[info exists $param]} {
                unset $param
            }
        }
    }

    # Initial vlan_id
    if {$vlan_enable} {
        if {[info exists vlan_id]} {
            set initVlanId $vlan_id
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the -mode is \
                    $mode and encapsulation is ethernet_ii_vlan a -vlan_id \
                    is required. Please supply this value."
            return $returnList
        }
    }

    set vcmux_llcsnap_enable 0
    if {$encap == "vc_mux" || $encap == "llcsnap"} {
        set vcmux_llcsnap_enable 1
        set useless_params [list vlan_id vlan_id_step vlan_id_count vlan_priority]
        foreach param $useless_params {
            if {[info exists $param]} {
                unset $param
            }
        }
    }

    # Initial vci/vpi
    if {$vcmux_llcsnap_enable} {
        if {[info exists vci] && [info exists vpi]} {
            set initVci $vci
            set initVpi $vpi
            set counterVci 1
            set counterVpi 1
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the -mode is\
                    $mode and encapsulation is vc_mux or a llcsnap,\
                    -vci and -vpi are required. Please supply these values."
            return $returnList
        }
    }

    # Encapsulation
    array set enumList [list                                        \
        ethernet_ii      NULL                                       \
        ethernet_ii_vlan NULL                                       \
        vc_mux           atmEncapsulationVccMuxBridgedEthernetNoFCS \
        llcsnap          atmEncapsulationLLCBridgedEthernetNoFCS    ]

    # HLT - Ixia
    array set intfEntryArray [list       \
        mac_addr        macAddress       \
        intfDescription description      \
        vci             atmVci           \
        vpi             atmVpi           \
        vlan_enable     enableVlan       \
        vlan_id         vlanId           \
        vlan_priority   vlanPriority     \
        encap           atmEncapsulation ]

    if {$mode == "modify"} {
        set sessionHandle [keylget dhcp_handles_array($handle,group) session]
        set portHandle \
                [keylget dhcp_handles_array($sessionHandle,session) port_handle]
    } else {
        set portHandle [keylget dhcp_handles_array($handle,session) port_handle]
    }

    set port_list [format_space_port_list $portHandle]
    set interface [lindex $port_list 0]
    set mac_addr      [string tolower [::ixia::convertToIxiaMac $mac_addr]]
    set mac_addr_step [string tolower [::ixia::convertToIxiaMac $mac_addr_step]]

    foreach {chassis card port} $interface {}
    ::ixia::addPortToWrite $chassis/$card/$port
    set intfDescription [::ixia::make_interface_description \
            $chassis/$card/$port $mac_addr]

    if {[interfaceTable select $chassis $card $port]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failure on call to\
                interfaceTable select $chassis $card $port."
        return $returnList
    }

    if {$mode == "modify"} {

        set groupDescription [keylget dhcp_handles_array($handle,group) description]

        # Loop through all interfaces; Clear existing interfaces for that group
        set bRes [interfaceTable getFirstInterface]
        while {$bRes == 0} {
            set interfaceDescription [interfaceEntry cget -description]
            if {[set pos [lsearch $groupDescription $interfaceDescription]] != -1} {
                # Delete the interface to recreate it below
                if {[interfaceTable delInterface $interfaceDescription]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failure on call to\
                            interfaceTable delInterface $interfaceDescription\
                            on port $chassis $card $port."
                    return $returnList
                }
            }
            set bRes [interfaceTable getNextInterface]
        }

        interfaceTable clearAllInterfaces

        # Erase all the clients of that group
        foreach clientIndex [array names dhcp_handles_array *,client] {
            set index1 [mpexpr [string length $clientIndex] - 1]
            set strNew [string replace $clientIndex [mpexpr $index1 - 6] $index1]
            if {[keylget dhcp_handles_array($strNew,client) group] \
                    == $handle } {
                unset dhcp_handles_array($strNew,client)
            }
        }

        keylset dhcp_handles_array($handle,group) description ""
        foreach elem $groupDescription {
            set retCode [::ixia::modify_protocol_interface_info \
                    -port_handle $interface                     \
                    -description $elem                          \
                    -mode        delete                         ]
        }
    }

    set handleList [list ]
    set counterVlanId 1
    set sessionsCounter 1
    set desc_list_local ""
    set intf_handle_list_local ""

    for {set intfIndex 1} {$intfIndex <= $num_sessions} {incr intfIndex } {

        # New Client
        set dhcpValue ""
        if {$mode == "modify"} {
            keylset dhcpValue group             $handle
        } else {
            keylset dhcpValue group             $group_handle
        }

        set retCode [::ixia::dhcpGetNextHandle dhcpClient client]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to\
                    ::ixia::dhcpGetNextHandle dhcpClient client."
            return $returnList
        }

        set nextHandle [keylget retCode next_handle]

        set dhcp_handles_array($nextHandle,client) $dhcpValue

        dhcpV4Properties setDefault
        dhcpV4Properties removeAllTlvs
        # Run this check so that the client ID of the DHCP client will be 
        # set to the MAC address of the requesting interface, for those 
        # interfaces that have MAC addresses. This is accomplished by not 
        # assigning any client ID. This is done in order to fix bug no. 112399.
        if {$encap != "ethernet_ii" && $encap != "ethernet_ii_vlan"} {
            dhcpV4Properties config -clientId $nextHandle
        }
        dhcpV4Properties config -serverId   $server_id
        dhcpV4Properties config -vendorId   $vendor_id
        dhcpV4Properties config -renewTimer $lease_time

        # Define a type 51 Tlv (Addresses lease time = 32-bit value)
        dhcpV4Tlv config -type  51


        if {[catch {set a [format "%08x" $lease_time]} value] } {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to\
                    convert $lease_time into a 32-bit hexa value."
            return $returnList
        }
        set val [string toupper "[string range $a 0 1] \
                                 [string range $a 2 3] \
                                 [string range $a 4 5] \
                                 [string range $a 6 7]"]

        dhcpV4Tlv config -value $val

        if [dhcpV4Properties addTlv] {
            keylset returnList status $::FAILURE
            keylset returnList log "Error in dhcpV4Properties addTlv."
            return $returnList
        }

        # Define a type 57 Tlv (Max DHCP message size = 16-bit value)
        dhcpV4Tlv config -type  57

        if {[catch {set a [format "%04x" $max_dhcp_msg_size]} value] } {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to\
                    convert $max_dhcp_msg_size into a 16-bit hexa value."
            return $returnList
        }
        set val [string toupper "[string range $a 0 1] \
                                 [string range $a 2 3] "]

        dhcpV4Tlv config -value $val

        if [dhcpV4Properties addTlv] {
            keylset returnList status $::FAILURE
            keylset returnList log "Error in dhcpV4Properties addTlv."
            return $returnList
        }

        interfaceEntry setDefault
        interfaceEntry clearAllItems addressTypeIpV4
        interfaceEntry clearAllItems addressTypeIpV6
        interfaceEntry config -enable        false
        interfaceEntry config -enableDhcp    true

        foreach item [array names intfEntryArray] {
            if {![catch {set $item} value] } {
                if {[lsearch [array names enumList] $value] != -1} {
                    set value $enumList($value)
                }
                if {$value != "NULL" } {
                    if {($intfEntryArray($item) == "enableVlan") && \
                                ($value == 0)} {
                    } else {
                        catch {interfaceEntry config -$intfEntryArray($item) \
                                    $value}
                    }
                }
            }
        }

        if {[interfaceTable addInterface]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure on call to interfaceTable\
                    addInterface on port $chassis $card $port. $::ixErrorInfo"
            return $returnList
        }

        # Send the interface table to the chassis
        if {![info exists no_write]} {
            if {[interfaceTable write]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failure on call to\
                        interfaceTable write."
                return $returnList
            }
        }

         # Tell the stream to use the interface
        stream config -enableSourceInterface true
        stream config -sourceInterfaceDescription $intfDescription
        if [stream set $chassis $card $port 1] {
            keylset returnList status $::FAILURE
            keylset returnList log "Error in interfaceEntry addInterface"
            return $returnList
        }
        set intfHandle [::ixia::get_next_interface_handle]
        
        # Start update protocol interfaces
        set config_params "\
                -port_handle      $portHandle        \
                -description      {$intfDescription} \
                -mode             add                \
                -dhcp_enable      1                  \
                -ixnetwork_objref $intfHandle        \
                "

        set config_options {
            -vlan_id       vlan_id
            -vlan_priority vlan_priority
            -mac_address   mac_addr
            -atm_encap     encap
            -atm_vpi       vpi
            -atm_vci       vci
        }

        
        foreach {_elem _name} $config_options {
            if {[info exists $_name]} {
                append config_params " $_elem [set $_name]"
            }
        }
        
        set modify_status [eval ::ixia::modify_protocol_interface_info $config_params]
        if {[keylget modify_status status] == $::FAILURE} {
            return $modify_status
        }
        set dhcpValue ""
        if {$mode == "create"} {
            keylset dhcpValue session       $handle
        } else {
            keylset dhcpValue session       $sessionHandle
        }

        lappend desc_list_local        $intfDescription
        lappend intf_handle_list_local $intfHandle
        keylset dhcpValue description      $desc_list_local
        keylset dhcpValue interface_handle $intf_handle_list_local

        foreach dhcpParam $dhcpParamList {
            if {[info exists $dhcpParam]} {
                keylset dhcpValue $dhcpParam  [set $dhcpParam]
            }
        }

        if {$mode == "create"} {
            set dhcp_handles_array($group_handle,group) $dhcpValue
        } else {
            set dhcp_handles_array($handle,group) $dhcpValue
        }

        # Next vlan Id (only if encap == ethernet_ii_vlan)
        if {[info exists initVlanId]} {
            incr counterVlanId
            if {$counterVlanId > $vlan_id_count} {
                set counterVlanId  1
                set vlan_id  $initVlanId
            } else {
                incr vlan_id $vlan_id_step
            }
        }

        # Next Vci|Vpi (only if encap == vc_mux or llcsnap)
        if {[info exists initVci] && [info exists initVpi]} {
            if {$vpi==$initVpi && ($intfIndex<=$sessions_per_vc)} {
            set lim [expr $sessions_per_vc - 1]
            } else {
            set lim $sessions_per_vc
            }
            if {$sessionsCounter > $lim} {
                switch -exact $pvc_incr_mode {
                    vci {
                        incr counterVci
                        if {$counterVci > $vci_count} {
                            set couterVci 1
                            set vci $initVci
                            incr counterVpi
                            if {$counterVpi>$vpi_count} {
                                set couterVpi 1
                                set vpi $initVpi
                                set counterVci 1
                                set counterVpi 1
                            } else {
                                incr vpi $vpi_step
                                set counterVci 1
                            }
                        } else {
                                incr vci $vci_step
                        }
                    }
                    vpi {
                        incr counterVpi
                        if {$counterVpi > $vpi_count} {
                            set couterVpi 1
                            set vpi $initVpi
                            incr counterVci
                            if {$counterVci>$vci_count} {
                                set couterVci 1
                                set vci $initVci
                                set counterVpi 1
                                set counterVci 1
                            } else {
                                incr vci $vci_step
                                set counterVpi 1
                            }
                        } else {
                                incr vpi $vpi_step
                        }
                    }
                }
                set sessionsCounter 2
            } else {
                incr sessionsCounter
            }
        }

        # Next mac address
        set mac_addr [string tolower [::ixia::incrementMacAdd \
                $mac_addr $mac_addr_step]]

        set intfDescription [::ixia::make_interface_description \
                $chassis/$card/$port $mac_addr]
    }

    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::dhcpRequestDiscoveredTable
#
# Description:
#     Tries 10 times to requestDiscoveredTable, using a delay within the trials.
#
# Return Values:
#    A key list
#    key:status       value:$::SUCCESS | $::FAILURE
#    key:log          value:If status is failure, detailed information provided
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
#
proc ::ixia::dhcpRequestDiscoveredTable { interface } {
    set cmd "interfaceTable getDhcpV4DiscoveredInfo {$interface}"
    set numRetries 3
    set retCode    1
    while {$retCode && $numRetries} {
        set retCode [eval $cmd]
        debug $cmd
        debug $retCode
        incr numRetries -1
        if {$retCode} {
            after 1
        }
    }
    if {$retCode} {
        keylset returnList status     $::SUCCESS
        keylset returnList discovered $::FAILURE
        return $returnList
    }
    keylset returnList status     $::SUCCESS
    keylset returnList discovered $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::resetDhcpHandleArray
#
# Description:
#    This command resets the elements in dhcp_handles_array
#    and clears the hardware accordingly.
#
#    An element in ldp_handles_array is one of the following forms:
#         dhcp_handles_array($session_handle,session)  port_handle
#         dhcp_handles_array($group_handle,group)      session_handle
#         dhcp_handles_array($client_handle,client)    group_handle
#
#    where port_handle is in the form of $chassNum/$cardNum/$portNum.
#
# Synopsis:
#
# Arguments:
#    mode        - reset (default NULL)
#                - when reset, clears the hardware also, not only the array
#    port_handle - specifies the chassis/card/port (default NULL)
#                - specified when called from ::ixia::emulation_dhcp_config
#    handle      - session_handle (default NULL)
#                - specified when called from ::ixia::emulation_dhcp_group_config
#
# Return Values:
#    $::TCL_OK for success
#    $::TCL_ERROR for failure to delete an element
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
proc ::ixia::resetDhcpHandleArray {mode port_handle handle} {
    variable  dhcp_handles_array
    keylset returnList status $::SUCCESS
    if {[info exists ::ixia::no_more_tclhal] && $::ixia::no_more_tclhal == 1} { return }
    set procName [lindex [info level [info level]] 0]
    set retCode $::TCL_OK

    if {$mode == "reset"} {
        if {($port_handle != "") && ($handle == "")} {
            # Erase all the interfaces of that port from the hardware
            set portIntfDesc ""
            foreach sessionIndex [array names dhcp_handles_array *,session] {
                set index1 [mpexpr [string length $sessionIndex] - 1]
                set strNew1 [string replace $sessionIndex [mpexpr $index1 - 7] \
                        $index1]
                if {[keylget dhcp_handles_array($strNew1,session) port_handle] \
                            == $port_handle } {
                    foreach groupIndex [array names dhcp_handles_array *,group] {
                        set index1 [mpexpr [string length $groupIndex] - 1]
                        set strNew2 [string replace $groupIndex [mpexpr \
                                $index1 - 5] $index1]
                        if {[keylget dhcp_handles_array($strNew2,group) session] \
                                == $strNew1 } {
                            lappend portIntfDesc [keylget \
                            dhcp_handles_array($strNew2,group) \
                            description]
                        }
                    }
                }
            }

            set bRes [interfaceTable getFirstInterface]
            set portIntfDescLocal {}
            
            # prepare portIntfDesc for 'lsearch' call
            if {"[lindex $portIntfDesc 0]" == "$port_handle"} {
                set portIntfDescLocal [list portIntfDesc]
            } else {
                if {"[lindex [lindex [lindex $portIntfDesc 0] 0] 0]" == "$port_handle"} {
                    foreach {i} "$portIntfDesc" {
                        foreach {j} "$i" {
                            lappend portIntfDescLocal $j
                        }
                    }
                }
            }
            
            set isFirstRow 1
            set isFirstIntf 0
            while {$bRes == 0} {
                set interfaceDescription [interfaceEntry cget -description]
                debug "lsearch $portIntfDescLocal --- $interfaceDescription"
                if {[lsearch $portIntfDescLocal $interfaceDescription] != -1} {
                    if {[interfaceTable delInterface $interfaceDescription]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failure on call to\
                                interfaceTable delInterface\
                                $interfaceDescription on port\
                                $chassis $card $port."
                        return $returnList
                    }
                    if {$isFirstRow == 1} {
                        set isFirstIntf 1
                    }            
                }
                if {$isFirstIntf == 1} {
                    set bRes [interfaceTable getFirstInterface]
#                    set isFirstRow 1
                    set isFirstIntf 0
                 } else {
                    set bRes [interfaceTable getNextInterface]
                    set isFirstRow 0
                }
            }
        }

        if {($handle != "") && ($port_handle == "")} {
            # Erase all the interfaces of that session from the hardware
            set sessionIntfDesc ""
            foreach groupIndex [array names dhcp_handles_array *,group] {
                set index1 [mpexpr [string length $groupIndex] - 1]
                set strNew2 [string replace $groupIndex [mpexpr $index1 - 5] \
                        $index1]
                if {[keylget dhcp_handles_array($strNew2,group) session] \
                        == $handle } {
                    lappend sessionIntfDesc [keylget \
                    dhcp_handles_array($strNew2,group) \
                    description]
                }
            }
            set bRes [interfaceTable getFirstInterface]
            while {$bRes == 0} {
                set interfaceDescription [interfaceEntry cget -description]
                if {[lsearch $sessionIntfDesc $interfaceDescription] != -1} {
                    if {[interfaceTable delInterface $interfaceDescription]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failure on call to\
                                interfaceTable delInterface\
                                $interfaceDescription\
                                on port $chassis $card $port."
                        return $returnList
                    }
                }
                set bRes [interfaceTable getNextInterface]
            }

            interfaceTable clearAllInterfaces
        }
    }

    if {($port_handle != "") && ($handle == "")} {
        # Erase all the sessions of that port, all the groups of that
        # sessions and all the clients of that groups
        # from dhcp_handles_array
        foreach sessionIndex [array names dhcp_handles_array *,session] {
            set index1 [mpexpr [string length $sessionIndex] - 1]
            set strNew1 [string replace $sessionIndex [mpexpr $index1 - 7] \
                    $index1]
            if {[keylget dhcp_handles_array($strNew1,session) port_handle] \
                    == $port_handle } {
                unset dhcp_handles_array($strNew1,session)
                foreach groupIndex [array names dhcp_handles_array *,group] {
                    set index1 [mpexpr [string length $groupIndex] - 1]
                    set strNew2 [string replace $groupIndex [mpexpr $index1 \
                            - 5] $index1]
                    if {[keylget dhcp_handles_array($strNew2,group) session] \
                            == $strNew1 } {
                        unset dhcp_handles_array($strNew2,group)

                        foreach clientIndex [array names \
                                dhcp_handles_array *,client] {
                            set index1 [mpexpr [string length \
                                    $clientIndex] - 1]
                            set strNew3 [string replace $clientIndex \
                                    [mpexpr $index1 - 6] $index1]
                            if {[keylget dhcp_handles_array($strNew3,client) \
                                    group] == $strNew2} {
                                unset dhcp_handles_array($strNew3,client)
                            }
                        }

                    }
                }

            }
        }
    }

    if {($handle != "") && ($port_handle == "")} {
        # Erase all groups of that session and all the clients of that groups
        # from dhcp_handles_array
        foreach groupIndex [array names dhcp_handles_array *,group] {
            set index1 [mpexpr [string length $groupIndex] - 1]
            set strNew2 [string replace $groupIndex [mpexpr $index1 - 5] \
                    $index1]
            if {[keylget dhcp_handles_array($strNew2,group) session] \
                    == $handle } {

                unset dhcp_handles_array($strNew2,group)
                foreach clientIndex [array names dhcp_handles_array \
                        *,client] {
                    set index1 [mpexpr [string length $clientIndex] - 1]
                    set strNew3 [string replace $clientIndex [mpexpr \
                            $index1 - 6] $index1]
                    if {[keylget dhcp_handles_array($strNew3,client) \
                            group] == $strNew2 } {
                        unset dhcp_handles_array($strNew3,client)
                    }
                }

            }
        }
    }
    return $returnList
}


## Internal Procedure Header
# Name:
#    ::ixia::ixa_dhcp_config
#
# Description:
#    Configures DHCP emulation for the specified test port or handle.
#
# Synopsis:
#    ::ixia::emulation_dhcp_config
#        [-port_handle                 ^\[0-9\]+/\[0-9\]+/\[0-9\]+$]
#        -mode                         CHOICES create modify reset
#        [-handle]
#        [-lease_time                  RANGE 0-65535]
#        [-max_dhcp_msg_size           RANGE 0-65535]
#x       [-reset                       FLAG]
#x       [-version                     CHOICES ixtclhal ixaccess
#x                                     DEFAULT ixtclhal]
#x       [-no_write                    FLAG]
#n       [-msg_timeout                 NUMERIC]
#n       [-outstanding_sessions_count  NUMERIC]
#n       [-release_rate                RANGE 0-2000]
#n       [-request_rate                RANGE 0-2000]
#n       [-response_wait               NUMERIC]
#n       [-retry_count                 NUMERIC]
#n       [-retry_timer                 NUMERIC]
#
# Arguments:
#    -port_handle
#        This parameter specifies the port upon which emulation is configured.
#        Mandatory for the mode -create only.
#    -mode
#        This option defines the action to be taken on the port specified by
#        the port_handle argument. Valid choices are:
#        create - Creates an DHCP session,  requires the use of -port_handle.
#        modify - Modifies an DHCP session, requires the use of -handle.
#        reset  - Stops the emulation locally without attempting to clear the
#                 bound address from the DHCP server.
#    -handle
#        Specifies the handle of the port upon which emulation is configured.
#        Mandatory for the modes -modify and -reset only.
#    -lease_time
#        Specify the lease time in seconds suggested by the emulated client
#        that is sent in the discover message.
#    -max_dhcp_msg_size
#        Sets the maximum size of the dhcp message.
#x   -reset
#x       Clears the hardware
#x   -version
#x       Permits the selection between ixtclhal and ixaccess. This option must
#x       be set to ixaccess so that ixAccess Api is used.
#x   -no_write
#x       If this option is present, the configuration is not written to the
#x       hardware. This option can be used to queue up multiple configurations
#x       before writing to the hardware.
#n   -msg_timeout
#n       Specifies the maximum time to wait in milliseconds for receipt of an
#n       offer or ack message after the sending of a corresponding discover or
#n       request message.
#n   -outstanding_sessions_count
#n       Specifies the maximum number of outstanding sessions (unacknowledged
#n       discover or request message) allowed to exist. In effect, this is a
#n       rate limiting mechanism that stops dhcp servers from being
#n       overwhelmed with reqests.
#n   -release_rate
#n       Specified the desired release rate in sessions per second.
#n   -request_rate
#n       Specified the desired request rate in sessions per second.
#n   -response_wait
#n
#n   -retry_count
#n       Limits the number of additional transmissions of either a discover or
#n       request message when no acknowledgement is received.
#n   -retry_timer
#n       Limits the number of seconds the emulation will wait between
#n       attempting to reestablish a failed session.
#
# Return Values:
#    A keyed list
#    key:status        value:$::SUCCESS | $::FAILURE
#    key:log           value:Error message if command returns {status 0}
#    key:port_handle   value:Port handle on which DHCP emulation was configured
#
# Examples:
#    See files starting with DHCP_ in the Samples subdirectory. See the DHCP
#    example in Appendix A, "Example APIs," for one specific example usage.
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::ixa_dhcp_config { args } {
    variable dhcp_handles_array

    set args [lindex $args 0]
    set procName [lindex [info level [info level]] 0]

    set mandatory_args {
        -mode                        CHOICES create modify reset
    }

    set optional_args {
        -port_handle                 REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -handle
        -lease_time                  RANGE 0-65535
        -max_dhcp_msg_size           RANGE 0-65535
        -reset                       FLAG
        -version                     CHOICES ixtclhal ixaccess
                                     DEFAULT ixtclhal
        -no_write                    FLAG
    }

    ::ixia::parse_dashed_args -args $args -optional_args $optional_args \
            -mandatory_args $mandatory_args

    if {$mode == "modify"} {
        if {[info exists reset]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the -mode is\
                    $mode, a -reset parameter is not required.  Please \
                    do not supply this value."
            return $returnList
        }
        set port_handle [keylget dhcp_handles_array($handle,session) port_handle]
    }

    set port_list [format_space_port_list $port_handle]
    set interface [lindex $port_list 0]
    foreach {chassis card port} $interface {}
    set clientPortList [list "$chassis $card $port"]

    if {($mode == "create")} {
        # When mode is create check if port_handle is present
        if {![info exists port_handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the -mode is\
                    $mode, a -port_handle is required.  Please supply\
                    this value."
            return $returnList
        }

        if {![port isValidFeature $chassis $card $port \
                    portFeatureProtocolDHCP]} {

            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: This card does not\
                    support DHCP protocol."
            return $returnList
        }

        if {[info exists reset]} {
            set retCode [::ixia::ixaResetDhcpHandleArray reset $port_handle ""]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to\
                        ::ixia::resetDhcpHandleArray reset $port_handle."
                return $returnList
            }
        }

        set param_value_list [list      \
                lease_time         8640 \
                max_dhcp_msg_size  576  ]

        foreach {param value} $param_value_list {
            if {![info exists $param]} {
                set $param $value
            }
        }

        set dhcpValue ""
        keylset dhcpValue port_handle       $port_handle
        keylset dhcpValue lease_time        $lease_time
        keylset dhcpValue max_dhcp_msg_size $max_dhcp_msg_size

        set allHandles ""
        foreach {index value} [array get dhcp_handles_array] {
            set i1 [lindex [split $index ,] 0]
            set i2 [lindex [split $index ,] 1]
            if {$i2 == "session"} {
                lappend allHandles $i1
            }
        }

        set retCode [::ixia::dhcpGetNextHandle dhcpSession session]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to\
                    ::ixia::dhcpGetNextHandle dhcpSession session."
            return $returnList
        }

        set nextHandle [keylget retCode next_handle]
        set nextAddrHandle [keylget retCode next_id]
        keylset dhcpValue idAddr $nextAddrHandle
        set dhcp_handles_array($nextHandle,session) $dhcpValue
        keylset returnList handle $nextHandle
    }

    if {($mode == "modify")} {
        # Check if the session handle is present in dhcp_handles_array
        if {! [info exists dhcp_handles_array($handle,session)]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: The provided session\
                    handle does not exist in dhcp_handles_array."
            return $returnList
        }

        set port_handle [keylget dhcp_handles_array($handle,session) \
                port_handle]

        if {![port isValidFeature $chassis $card $port \
                    portFeatureProtocolDHCP]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: This card does not\
                    support DHCP protocol."
            return $returnList
        }

        set dhcpValue $dhcp_handles_array($handle,session)
        if {[info exists lease_time]} {
            keylset dhcpValue lease_time        $lease_time
        }
        if {[info exists max_dhcp_msg_size]} {
            keylset dhcpValue max_dhcp_msg_size $max_dhcp_msg_size
        }
        set dhcp_handles_array($handle,session) $dhcpValue

        # Change all the groups of that session
        foreach groupIndex [array names dhcp_handles_array *,group] {

            if {[keylget dhcp_handles_array($groupIndex) session] == $handle} {

                set retCode [::ixia::emulation_dhcp_group_config \
                        -mode modify $no_write]

                if {[keylget retCode status] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Failed to\
                            ::ixia::emulation_dhcp_group_config."
                    return $returnList
                }
            }
        }
    }

    if {$mode == "reset"} {
        if {[info exists reset]} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When the -mode is\
                        $mode, a -reset parameter is not required.  Please \
                        do not supply this value."
                return $returnList
        }

        # Check if protocol is supported
        foreach {chassis card port} [split $port_handle /] {}
        if {![port isValidFeature $chassis $card $port \
                    portFeatureProtocolDHCP]} {

            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: This card does not\
                    support DHCP protocol."
            return $returnList
        }

        # Reset the dhcp_handles_array for that port
        set retCode [::ixia::ixaResetDhcpHandleArray reset $port_handle ""]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to\
                    ::ixia::ixaResetDhcpHandleArray $port_handle."
            return $returnList
        }

        keylset returnList status $::SUCCESS
        return $returnList
    }

    keylset returnList status $::SUCCESS
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::ixaResetDhcpHandleArray
#
# Description:
#    This command resets the elements in dhcp_handles_array.
#
#    An element in ldp_handles_array is one of the following forms:
#         dhcp_handles_array($session_handle,session)  port_handle
#         dhcp_handles_array($group_handle,group)      session_handle
#
#    where port_handle is in the form of $chassNum/$cardNum/$portNum.
#
# Synopsis:
#
# Arguments:
#    mode        - reset (default NULL)
#                - when reset, clears the hardware also, not only the array
#    port_handle - specifies the chassis/card/port (default NULL)
#                - specified when called from ::ixia::emulation_dhcp_config
#    handle      - session_handle (default NULL)
#                - specified when called from ::ixia::emulation_dhcp_group_config
#
# Return Values:
#    $::TCL_OK for success
#    $::TCL_ERROR for failure to delete an element
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
proc ::ixia::ixaResetDhcpHandleArray {mode port_handle handle} {
    variable  dhcp_handles_array

    if {($port_handle != "") && ($handle == "")} {
        # Erase all the sessions of that port, all the groups of that
        # sessions and all the clients of that groups
        # from dhcp_handles_array
        foreach sessionIndex [array names dhcp_handles_array *,session] {
            set index1 [mpexpr [string length $sessionIndex] - 1]
            set strNew1 [string replace $sessionIndex [mpexpr $index1 - 7] \
                    $index1]
            if {[keylget dhcp_handles_array($strNew1,session) port_handle] \
                    == $port_handle } {
                unset dhcp_handles_array($strNew1,session)
                foreach groupIndex [array names dhcp_handles_array *,group] {
                    set index1 [mpexpr [string length $groupIndex] - 1]
                    set strNew2 [string replace $groupIndex [mpexpr $index1 \
                            - 5] $index1]
                    if {[keylget dhcp_handles_array($strNew2,group) session] \
                            == $strNew1 } {
                        unset dhcp_handles_array($strNew2,group)

                        foreach clientIndex [array names \
                                dhcp_handles_array *,client] {
                            set index1 [mpexpr [string length \
                                    $clientIndex] - 1]
                            set strNew3 [string replace $clientIndex \
                                    [mpexpr $index1 - 6] $index1]
                            if {[keylget dhcp_handles_array($strNew3,client) \
                                    group] == $strNew2} {
                                unset dhcp_handles_array($strNew3,client)
                            }
                        }

                    }
                }

            }
        }
    }

    if {($handle != "") && ($port_handle == "")} {
        # Erase all groups of that session ($handle) from dhcp_handles_array
        foreach groupIndex [array names dhcp_handles_array *,group] {
            set index1 [mpexpr [string length $groupIndex] - 1]
            set strNew2 [string replace $groupIndex [mpexpr $index1 - 5] \
                    $index1]
            if {[keylget dhcp_handles_array($strNew2,group) session] \
                    == $handle } {
                unset dhcp_handles_array($strNew2,group)
            }
        }
    }

    keylset returnList status $::SUCCESS
    return $returnList
}


## Internal Procedure Header
# Name:
#    ::ixia::ixa_dhcp_group_config
#
# Description:
#    Configures and modifies a group of DHCP subscribers where each
#    group share a set of common characteristics.
#    This proc can be invoked multiple times to create multiple
#    groups of subscribers on a port with characteristics different
#    from other groups or for independent control purposes.
#    This command allows the user to configure a specified number of
#    DHCP client sessions which belong to a subscriber group with
#    specific Layer 2 network settings. Once the subscriber group has
#    been configured a handle is created, which can be used to modify
#    the parameters or reset sessions for the subscriber group or
#    to control the binding, renewal and release of the DHCP sessions.
#
# Synopsis:
#    ::ixia::emulation_dhcp_group_config
#        -mode                  CHOICES create modify reset
#        -mac_addr              MAC
#        -mac_addr_step         MAC
#        [-num_sessions         RANGE 1-65536]
#        [-handle]
#        [-encap                CHOICES
#                                     ethernet_ii
#                                     ethernet_ii_vlan
#                                     vc_mux
#                                     llcsnap
#        [-vlan_id              RANGE 0-4095]
#        [-vlan_id_step         RANGE 0-4095]
#        [-vlan_id_count        RANGE 0-4095]
#        [-vci                  RANGE 0-65535]
#        [-vpi                  RANGE 0-255]
#        [-vci_count            RANGE 0-65535]
#        [-vci_step             NUMERIC]
#        [-vpi_count            RANGE 0-255]
#        [-vpi_step             NUMERIC]
#        [-sessions_per_vc      RANGE 1-65535]
#        [-pvc_incr_mode        CHOICES vci vpi]
#x       [-server_id            IP]
#x       [-vendor_id]
#x       [-no_write             FLAG]
#x       [-version              CHOICES ixtclhal ixaccess
#x                              DEFAULT ixtclhal]
#x       [-vlan_priority        RANGE 0-7]
#n       [-qinq_incr_mode       CHOICES inner outer]
#n       [-release_rate_sps     RANGE 0-2000]
#n       [-request_rate_sps     RANGE 0-2000]
#n       [-vlan_id_outer        RANGE 0-4095]
#n       [-vlan_id_outer_count  RANGE 0-4095]
#n       [-vlan_id_outer_step   RANGE 0-4095]
#
# Arguments:
#    -mode
#        Action to take on the port specified the handle argument.
#        Create starts emulation on the port.
#        Modify applies the parameters specified in subsequent arguments.
#        Reset stops the emulation locally without attempting to clear
#        the bound addresses from the DHCP server.
#    -handle
#        Specifies the port and group upon which emulation is configured.
#    -num_sessions
#        Indicates the number of DHCP clients emulated.
#    -encap
#        Note: ethernet_ii_qinq is not supported. Valid choices are:
#        ethernet          - Ethernet II
#        ethernet_ii_vlan  - Ethernet II with a single vlan tag
#        vc_mux            - ATM encapsulation
#        llcsnap           - ATM encapsulation
#    -mac_addr
#        Specifies the base (first) MAC address to use when emulating
#        multiple clients.
#    -mac_addr_step
#        Specifies the step value applied to the base MAC address for each
#        subsequent emulated client. The step MAC address is arithmetically
#        to the base MAC address with any overflow beyond 48 bits silently
#        discarded.
#    -vci
#        Specifies the base (first) VCI (virtual circuit) value applied
#        used when emulating multiple DHCP clients over ATM interfaces.
#    -vpi
#        Specifies the base (first) VPI (virtual path) value applied
#        used when emulating multiple DHCP clients over ATM interfaces.
#    -vlan_id
#        Specifies the starting vlan id for ethernet_ii_vlan encapsulation.
#        Applies to Ethernet vlan interfaces only.
#    -vlan_id_step
#        Specifies the increment for the vlan id for ethernet_ii_vlan
#        encapsulation. Applies to Ethernet interfaces only.
#    -vlan_id_count
#        Specifies the number of vlan id for ethernet_ii_vlan encapsulation.
#        Only applies to Ethernet interfaces. The increment is applied via
#        addition modulo 4096.
#    -sessions_per_vc
#        Specifies the the number of VPI's or VCI's sessions used for
#        emulation of clients over ATM interfaces. Used in conjuction with
#        the -pvc_incr_mode to allow multiple sessions per VCC. Valid for ATM
#        interfaces only.
#    -vci_count
#        Specifies the the number of VCI's used for the emulation of clients
#        over ATM interfaces. Valid for ATM interfaces only.
#    -vci_step
#        Specifies the increment to be used when selecting the next VCI value
#        to be used for emulation of clients over ATM interfaces. Valid for
#        ATM interfaces only. VCI values are incremented by addition modulo
#        65536.
#    -vpi_count
#        Specifies the the number of VPI's used for the emulation of clients
#        over ATM interfaces. Valid for ATM interfaces only.
#    -vpi_step
#        Specifies the increment to be used when selecting the next VPI value
#        to be used for emulation of clients over ATM interfaces. Valid for
#        ATM interfaces only. VCI values are incremented by addition modulo
#        256.
#    -pvc_incr_mode
#        Specifies the increment to be used when selecting the next VPI value
#        to be used for emulation of clients over ATM interfaces. Valid for
#        ATM interfaces only.
#x   -no_write
#x       If this option is present, the configuration is not written to the
#x       hardware. This option can be used to queue up multiple configurations
#x       before writing to the hardware.
#x   -version
#x       Permits the selection between ixtclhal and ixaccess. This option must
#x       be set to ixaccess so that ixAccess Api is used.
#x   -server_id
#x       An IP address (default 1.1.1.1) - DHCP negotiation will only occur
#x       with a particular server.
#x   -vendor_id
#x       The vendor ID associated with the client (default "Ixia").
#x   -vlan_priority
#x       If -encap is ethernet_ii_vlan, specifies the priority of the vlan_id.
#x       (DEFAULT 0)
#n   -qinq_incr_mode
#n   -release_rate_sps
#n   -request_rate_sps
#n   -vlan_id_outer
#n   -vlan_id_outer_count
#n   -vlan_id_outer_step
#
# Return Values:
#    A keyed list
#    key:status      value:$::SUCCESS | $::FAILURE
#    key:log         value:When status is failure, contains more info
#    key:port_handle value:Port handle on which DHCP emulation was configured
#    key:group       value:Handle of the group that was configured or modified
#
# Examples:
#    See files starting with DHCP_ in the Samples subdirectory.
#    See the DHCP example in Appendix A, "Example APIs," for one specific
#    example usage.
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::ixa_dhcp_group_config {args} {
    variable portListWritten
    variable dhcp_handles_array
    variable debug

    set args [lindex $args 0]

    set procName [lindex [info level [info level]] 0]

    ::ixia::utrackerLog $procName $args

    set man_args {
        -mode               CHOICES create modify reset
        -handle
    }

    set opt_args {
        -mac_addr           MAC
        -mac_addr_step      ANY
        -num_sessions       RANGE 1-16000
                            DEFAULT 1
        -encap              CHOICES ethernet_ii ethernet_ii_vlan
                            CHOICES vcmux_ipv4_routed vcmux_eth_fcs vcmux_eth_nofcs
                            CHOICES llc_routerd_clip llc_eth_fcs llc_eth_nofcs
                            CHOICES llc_pppoa vcmux_pppoa
        -vlan_id            RANGE 1-4094
        -vlan_id_step       RANGE 0-4094
        -vlan_id_count      RANGE 1-4094
        -vci                RANGE 0-65535
        -vpi                RANGE 0-255
        -vci_count          RANGE 0-65535
        -vci_step           NUMERIC
        -vpi_count          RANGE 0-255
        -vpi_step           NUMERIC
        -sessions_per_vc    RANGE 1-16000
        -pvc_incr_mode      CHOICES vci vpi
        -vlan_priority      RANGE 0-7
        -server_id          IP
        -vendor_id
        -version            CHOICES ixtclhal ixaccess
                            DEFAULT ixtclhal
        -target_subport     RANGE 0-3
                            DEFAULT 0
        -no_write           FLAG
    }

    if {[catch {::ixia::parse_dashed_args \
            -args           $args         \
            -optional_args  $opt_args     \
            -mandatory_args $man_args} parseError]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed on\
                parsing. $parseError."
        return $returnList
    }
    
    # RESETs the emulation locally
    if {$mode == "reset"} {
        # Reset the dhcp_handles_array for that session ($handle)
        set retCode [::ixia::ixaResetDhcpHandleArray "" "" $handle]
        if {[keylget retCode status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to\
                    reset DHCP protocol for $handle."
            return $returnList
        }

        keylset returnList handle $handle
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    if {[info exists mac_addr_step]} {
        if {$version == "ixaccess"} {
            if {[regexp -- {\d+\.\d+} $mac_addr_step] != 0} {
                set mac_addr_step [mac2num $mac_addr_step]
            }
        } else {
            if {[regexp -- {^\d+$} $mac_addr_step] != 0} {
                set mac_addr_step [num2mac $mac_addr_step]
            }
        }
    }
        
    if {[info exists mac_addr_step] && ![string is integer $mac_addr_step]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The provided mac_addr_step\
                must be an integer number."
        return $returnList
    }

    if {($mode == "create") && ![info exists mac_addr]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: When mode is $mode the \
                mac_addr parameter must be provided. Please supply this value."
        return $returnList
    }

set dhcpParamList [list   \
        mode              \
        num_sessions      \
        handle            \
        encap             \
        vlan_id           \
        vlan_id_step      \
        vlan_id_count     \
        vci               \
        vpi               \
        vci_count         \
        vci_step          \
        vpi_count         \
        vpi_step          \
        sessions_per_vc   \
        pvc_incr_mode     \
        mac_addr          \
        mac_addr_step     \
        vlan_priority     \
        vendor_id         \
        server_id         \
        lease_time        \
        max_dhcp_msg_size \
        target_subport]

    if {$mode == "modify"} {
        set session_handle [keylget dhcp_handles_array($handle,group) session]
        set port_handle [keylget dhcp_handles_array($session_handle,session) port_handle]
        set target_subport [keylget dhcp_handles_array($handle,group) target_subport]
    } else {
        set port_handle [keylget dhcp_handles_array($handle,session) port_handle]
    }

    set port_list [format_space_port_list $port_handle]
    set interface [lindex $port_list 0]
    foreach {chassis card port} $interface {}
    set clientPortList [list "$chassis $card $port"]

    if {(![info exists portListWritten] || !$portListWritten) && \
            ($mode != "reset")} {
debug "ixaSetPortList \"client\" \"ip\" $clientPortList"
        set retCode [ixaSetPortList "client" "ip" $clientPortList]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure on call to ixaSetPortList \
                    \"client\" \"ip\" $clientPortList."
            return $returnList
        }
        set portListWritten 1
    }

    set num_addresses $num_sessions
    foreach var [array names dhcp_handles_array *,group] {
        if {[keylget dhcp_handles_array($var) target_subport] == \
                    $target_subport} {
            set num_addresses [mpexpr $num_addresses + \
                [keylget dhcp_handles_array($var) num_sessions]]
        }
    }

debug "ixAccessSubPort get $chassis $card $port $target_subport"
    set retCode [ixAccessSubPort get $chassis $card $port $target_subport]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failure on call to ixAccessSubPort get\
                $chassis $card $port $target_subport."
        return $returnList
    }

debug "ixAccessSubPort config -numSessions $num_addresses"
    set retCode [ixAccessSubPort config -numSessions $num_addresses]

    set _pm $::kIxAccessIP
    ixAccessSubPort config -portMode $_pm
    debug "ixAccessSubPort config -portMode $_pm"

debug "ixAccessSubPort set $chassis $card $port $target_subport"
    set retCode [ixAccessSubPort set $chassis $card $port $target_subport]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failure on call to ixAccessSubPort set \
                $chassis $card $port 0."
        return $returnList
    }

    # CREATEs a new group range
    if {$mode == "create"} {

        # Default values
        set param_value_list [list             \
                num_sessions       4096        \
                encap              ethernet_ii \
                vlan_id_step       1           \
                vlan_id_count      1           \
                vci_count          1           \
                vci_step           1           \
                vpi_count          1           \
                vpi_step           1           \
                sessions_per_vc    1           \
                pvc_incr_mode      vci         \
                vlan_priority      0           \
                server_id          0.0.0.0     \
                vendor_id          Ixia        \
                target_subport     0           \
                mac_addr_step      1           ]

        foreach {param value} $param_value_list {
            if {![info exists $param]} {
                set $param $value
            }
        }

        # Check if the session handle is present in dhcp_handles_array
        if {! [info exists dhcp_handles_array($handle,session)]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: The provided session\
                    handle does not exist in dhcp_handles_array."
            return $returnList
        }

        set found 0
        foreach var [array names dhcp_handles_array *,group] {
            if {[keylget dhcp_handles_array($var) session] == $handle} {
                set found 1
                break
            }
        }
        if {$found} {
            set group_handle [lindex [split $var ","] 0]
            if {![info exists mac_addr_step]} {
                set retCode [::ixia::macIsUniq "existing" "$mac_addr" ""\
                        "$num_sessions" "$group_handle"]
                if {[keylget retCode status] == 0} {
                    return $retCode
                }
            } else  {
                set retCode [::ixia::macIsUniq "existing" "$mac_addr" "$mac_addr_step"\
                        "$num_sessions" "$group_handle"]
                if {[keylget retCode status] == 0} {
                    return $retCode
                }
            }
        } else  {
            if {![info exists mac_addr_step]} {
                set retCode [::ixia::macIsUniq "new" "$mac_addr" ""\
                        "$num_sessions" ""]
                if {[keylget retCode status] == 0} {
                    return $retCode
                }
            } else  {
                set retCode [::ixia::macIsUniq "new" "$mac_addr" "$mac_addr_step"\
                        "$num_sessions" ""]
                if {[keylget retCode status] == 0} {
                    return $retCode
                }
            }
            set retCode [::ixia::dhcpGetNextHandle dhcpGroup group]

            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to\
                        ::ixia::dhcpGetNextHandle dhcpGroup group."
                return $returnList
            }

            set group_handle [keylget retCode next_handle]

        }

        set config_param ""
        foreach value $dhcpParamList {
            if {[info exists $value]} {
                append config_param " -$value [set $value] "
            }
        }

        append config_param " -group_handle $group_handle "

        set retCode [eval ::ixia::ixaDhcpCreateInterfaces $config_param]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ::ixia::ixaDhcpCreateInterfaces. [keylget retCode log]"
            return $returnList
        }
        keylset returnList handle $group_handle
        keylset returnList port_handle $handle
    }

    # MODIFIes an existing group range
    if {$mode == "modify"} {

        # Check if the group handle is present in dhcp_handles_array
        if {! [info exists dhcp_handles_array($handle,group)]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: The provided group\
                    handle does not exist in dhcp_handles_array."
            return $returnList
        }

        set session_handle [keylget dhcp_handles_array($handle,group) session]
        set port_handle \
                [keylget dhcp_handles_array($session_handle,session) port_handle]

        set lease_time [keylget dhcp_handles_array($session_handle,session) \
                lease_time]
        set max_dhcp_msg_size \
                [keylget dhcp_handles_array($session_handle,session) \
                 max_dhcp_msg_size]

        # List of new params
        set dhcpValue $dhcp_handles_array($handle,group)
        foreach dhcpParam $dhcpParamList {
            if {(![info exists $dhcpParam]) && \
                        (![catch {keylget dhcpValue $dhcpParam} \
                        dhcpParamValue])} {
                set $dhcpParam  $dhcpParamValue
            }
        }

        if {![info exists mac_addr_step]} {
            set retCode [::ixia::macIsUniq "existing" "$mac_addr" ""\
                    "$num_sessions" "$handle"]
            if {[keylget retCode status] == 0} {
                return $retCode
            }
        } else {
            set retCode [::ixia::macIsUniq "existing" "$mac_addr" "$mac_addr_step"\
                    "$num_sessions" "$handle"]
            if {[keylget retCode status] == 0} {
                return $retCode
            }
        }

        set config_param ""
        foreach value $dhcpParamList {
            if {[info exists $value]} {
                if {$value == "mac_addr"} {
                    # mac address most likely now contains spaces
                    set mac_addr [string tolower \
                            [::ixia::convertToIxiaMac [set $value]]]
                    set mac_addr [join $mac_addr .]
                    append config_param " -$value $mac_addr "
                } else {
                    append config_param " -$value [set $value] "
                }
            }
        }

        set retCode [eval ::ixia::ixaDhcpCreateInterfaces $config_param]
        if {[keylget retCode status] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failed to\
                    ::ixia::ixaDhcpCreateInterfaces. [keylget retCode log]"
            return $returnList
        }

        keylset returnList handle $handle
    }

    if {![info exists no_write]} {
        set portListWritten 0
debug "ixAccessWriteConfig $clientPortList"
        set retCode [ixAccessWriteConfig $clientPortList]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to\
                    ixAccessWriteConfig $clientPortList."
            return $returnList
        }
    }

    keylset returnList status $::SUCCESS
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::ixaDhcpCreateInterfaces
#
# Description:
#     Creates interfaces for a given group handle.
#
# Synopsis:
#    ::ixia::ixaDhcpCreateInterfaces
#            List of all params:
#            - defaults or user specified - for Create mode
#            - changed (user specified) or the old values - for Modify mode
#
# Arguments:
#    mode num_sessions handle encap vlan_id vlan_id_step vlan_id_count vci vpi
#    vci_count vci_step vpi_count vpi_step sessions_per_vc pvc_incr_mode
#    mac_addr mac_addr_step vlan_priority server_id vendor_id lease_time
#    max_dhcp_msg_size group_handle
#
# Return Values:
#    A key list
#    key:status       value:$::SUCCESS | $::FAILURE
#    key:log          value:If status is failure, detailed information provided
#    key:next_handle  value:
#
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
#
proc ::ixia::ixaDhcpCreateInterfaces {args} {
    variable dhcp_handles_array
    variable debug

    set procName [lindex [info level [info level]] 0]

    set mandatory_args {
        -mode               CHOICES create modify
        -handle
    }

    set optional_args {
        -mac_addr           MAC
        -mac_addr_step      ANY
        -num_sessions       RANGE 1-16000
                            DEFAULT 1
        -encap              CHOICES ethernet_ii ethernet_ii_vlan
                            CHOICES vcmux_ipv4_routed vcmux_eth_fcs vcmux_eth_nofcs
                            CHOICES llc_routerd_clip llc_eth_fcs llc_eth_nofcs
                            CHOICES llc_pppoa vcmux_pppoa
        -vlan_id            RANGE 1-4094
        -vlan_id_step       RANGE 0-4094
        -vlan_id_count      RANGE 1-4094
        -vci                RANGE 0-65535
        -vpi                RANGE 0-255
        -vci_count          RANGE 0-65535
        -vci_step           NUMERIC
        -vpi_count          RANGE 0-255
        -vpi_step           NUMERIC
        -sessions_per_vc    RANGE 1-16000
        -pvc_incr_mode      CHOICES vci vpi
        -vlan_priority      RANGE 0-7
        -server_id          IP
        -vendor_id
        -lease_time         RANGE 0-65535
        -max_dhcp_msg_size  RANGE 0-65535
        -target_subport     RANGE 0-3
                            DEFAULT 0
        -group_handle
    }

    set retCode [::ixia::parse_dashed_args -args $args -optional_args \
            $optional_args -mandatory_args $mandatory_args]

    set dhcpParamList [list mode num_sessions handle group_handle encap vlan_id \
            vlan_id_step vlan_id_count vci vpi vci_count vci_step vpi_count \
            vpi_step sessions_per_vc pvc_incr_mode mac_addr mac_addr_step \
            vlan_priority server_id vendor_id target_subport]

    # List of encaps that support vlan:
    set encapVlanList [list ethernet_ii_vlan vcmux_eth_fcs vcmux_eth_nofcs \
            llc_eth_fcs llc_eth_nofcs]
    set vlan_enable 1
    if {[lsearch $encapVlanList $encap] < 0} {
        set vlan_enable 0
        set useless_params [list vlan_id vlan_id_step vlan_id_count vlan_priority]
        if {$encap == "ethernet_ii"} {
            lappend useless_params vci vpi vci_count vci_step sessions_per_vc \
                    pvc_incr_mode vpi_count vpi_step
        }
        foreach param $useless_params {
            if {[info exists $param]} {
                unset $param
            }
        }
    }

    if {$encap == "ethernet_ii_vlan"} {
        set useless_params [list vci vpi vci_count vci_step sessions_per_vc \
                pvc_incr_mode vpi_count vpi_step]
        foreach param $useless_params {
            if {[info exists $param]} {
                unset $param
            }
        }
    }

    if {$vlan_enable} {
        if {![info exists vlan_id]} {
            set vlan_id 1
        }
    }

    if {$mode == "modify"} {
        set sessionHandle [keylget dhcp_handles_array($handle,group) session]
        set portHandle \
                [keylget dhcp_handles_array($sessionHandle,session) port_handle]
    } else {
        set portHandle [keylget dhcp_handles_array($handle,session) port_handle]
    }

    set port_list [format_space_port_list $portHandle]
    set interface [lindex $port_list 0]
    if {[info exists mac_addr]} {
        set mac_addr [string tolower [::ixia::convertToIxiaMac $mac_addr]]
    }

    foreach {chassis card port} $interface {}

    set dhcpValue ""
    if {$mode == "create"} {
        keylset dhcpValue session       $handle
        set desc_list_local [keylget \
            dhcp_handles_array($handle,session) idAddr]
    } else {
        keylset dhcpValue session       $sessionHandle
        set desc_list_local [keylget \
            dhcp_handles_array($sessionHandle,session) idAddr]
    }
    keylset dhcpValue description $desc_list_local
    foreach dhcpParam $dhcpParamList {
        if {[info exists $dhcpParam]} {
            keylset dhcpValue $dhcpParam [set $dhcpParam]
        }
    }
    # Update the internal array:
    if {$mode == "create"} {
        set found 0
        foreach var [array names dhcp_handles_array *,group] {
            if {[keylget dhcp_handles_array($var) session] == $handle} {
                set found 1
                break
            }
        }
        if {$found} {
            set dhcp_handles_array($var) $dhcpValue
        } else {
            set retCode [::ixia::dhcpGetNextHandle dhcpGroup group]
            if {[keylget retCode status] == 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failed to\
                        ::ixia::dhcpGetNextHandle dhcpGroup group."
                return $returnList
            }
            set group_handle [keylget retCode next_handle]
            set dhcp_handles_array($group_handle,group) $dhcpValue
        }
    }

    if {$mode == "modify"} {
        set dhcp_handles_array($handle,group) $dhcpValue
    }

    if {[info exists encap]} {
        switch $encap {
            vcmux_ipv4_routed {
                set encap $::atmEncapsulationVccMuxIPV4Routed
            }
            vcmux_eth_fcs {
                set encap $::atmEncapsulationVccMuxBridgedEthernetFCS
            }
            vcmux_eth_nofcs {
                set encap $::atmEncapsulationVccMuxBridgedEthernetNoFCS
            }
            llc_routerd_clip {
                set encap $::atmEncapsulationLLCRoutedCLIP
            }
            llc_eth_fcs {
                set encap $::atmEncapsulationLLCBridgedEthernetFCS
            }
            llc_eth_nofcs {
                set encap $::atmEncapsulationLLCBridgedEthernetNoFCS
            }
            llc_pppoa {
                set encap $::atmEncapsulationLLCPPPoA
            }
            vcmux_pppoa {
                set encap $::atmEncapsulationVccMuxPPPoA
            }
            ethernet_ii {
                set encap 0
            }
            ethernet_ii_vlan {
                unset encap
            }
            default {
                set encap $::atmEncapsulationNone
            }
        }
    } else {
        set encap $::atmEncapsulationNone
    }

debug "ixAccessAddrList get $chassis $card $port $target_subport"
    ixAccessAddrList get $chassis $card $port $target_subport
debug "ixAccessAddrList configure -enableDhcp    1"
    ixAccessAddrList configure -enableDhcp    1

if {[info exists encap]} {
    debug "ixAccessAddrList configure -encapsulation $encap"
    ixAccessAddrList configure -encapsulation $encap
}
    if {$vlan_enable} {
debug "ixAccessAddrList configure -enableVlan 1"
        ixAccessAddrList configure -enableVlan 1
    }
debug "ixAccessAddrList set $chassis $card $port $target_subport"
    ixAccessAddrList set $chassis $card $port $target_subport
debug "ixAccessAddrList select $chassis $card $port $target_subport"
    ixAccessAddrList select $chassis $card $port $target_subport

    if {$mode == "modify" || $found == 1} {
        debug "ixAccessAddrList delAddr            $desc_list_local"
        set retcode [ixAccessAddrList delAddr            $desc_list_local]
        puts $retcode
    }

    if {$mode == "create"} {
debug "ixAccessAddr setDefault"
        ixAccessAddr setDefault
        }

    if {[info exists desc_list_local]} {
        debug "ixAccessAddr config -addrId     $desc_list_local"
        ixAccessAddr config -addrId     $desc_list_local
    }

    if {[info exists sessions_per_vc]} {
debug "ixAccessAddr config -addressPerVc   $sessions_per_vc"
        ixAccessAddr config -addressPerVc   $sessions_per_vc
    }
    if {[info exists mac_addr]} {
debug "ixAccessAddr config -baseMac        $mac_addr"
        ixAccessAddr config -baseMac        $mac_addr
    }
    if {[info exists vlan_priority]} {
debug "ixAccessAddr config -firstPriority  $vlan_priority"
        ixAccessAddr config -firstPriority  $vlan_priority
    }
    if {[info exists vci]} {
debug "ixAccessAddr config -firstVci       $vci"
        ixAccessAddr config -firstVci       $vci
    }
    if {[info exists vlan_id]} {
debug "ixAccessAddr config -firstVlanId    $vlan_id"
        ixAccessAddr config -firstVlanId    $vlan_id
    }
    if {[info exists vpi]} {
debug "ixAccessAddr config -firstVpi       $vpi"
        ixAccessAddr config -firstVpi       $vpi
    }
    if {[info exists mac_addr_step]} {
debug "ixAccessAddr config -macAddressIncr $mac_addr_step"
        ixAccessAddr config -macAddressIncr $mac_addr_step
    }
    if {[info exists num_sessions]} {
debug "ixAccessAddr config -numAddress     $num_sessions"
        ixAccessAddr config -numAddress     $num_sessions
    }
    if {[info exists vci_count]} {
debug "ixAccessAddr config -vciCount       $vci_count"
        ixAccessAddr config -vciCount       $vci_count
    }
    if {[info exists vci_step]} {
debug "ixAccessAddr config -vciStep        $vci_step"
        ixAccessAddr config -vciStep        $vci_step
    }
    if {[info exists vlan_id_count]} {
debug "ixAccessAddr config -vlanIdCount    $vlan_id_count"
        ixAccessAddr config -vlanIdCount    $vlan_id_count
    }
    if {[info exists vlan_id_step]} {
debug "ixAccessAddr config -vlanIdStep     $vlan_id_step"
        ixAccessAddr config -vlanIdStep     $vlan_id_step
    }
    if {[info exists vpi_count]} {
debug "ixAccessAddr config -vpiCount       $vpi_count"
        ixAccessAddr config -vpiCount       $vpi_count
    }
    if {[info exists vpi_step]} {
debug "ixAccessAddr config -vpiStep        $vpi_step"
        ixAccessAddr config -vpiStep        $vpi_step
    }
    if {[info exists pvc_incr_mode]} {
        if {$pvc_incr_mode == "vci"} {
            ixAccessAddr config -pvcIncrMode $::kIxAccessPvcIncrVciFirst
debug "ixAccessAddr config -pvcIncrMode $::kIxAccessPvcIncrVciFirst"
        } else  {
            ixAccessAddr config -pvcIncrMode $::kIxAccessPvcIncrVpiFirst
debug "ixAccessAddr config -pvcIncrMode $::kIxAccessPvcIncrVpiFirst"
        }
    }

debug "ixAccessAddrList addAddr"
    set retCode [ixAccessAddrList addAddr]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed to\
                ixAccessAddrList addAddr."
        return $returnList
    }

    if {$mode == "create"} {
        set lease_time [keylget dhcp_handles_array($handle,session) lease_time]
        set max_dhcp_msg_size \
                [keylget dhcp_handles_array($handle,session) max_dhcp_msg_size]
    } else {
        set lease_time [keylget dhcp_handles_array($sessionHandle,session) lease_time]
        set max_dhcp_msg_size \
                [keylget dhcp_handles_array($sessionHandle,session) max_dhcp_msg_size]
    }

debug "ixAccessDhcp setDefault"
    ixAccessDhcp setDefault
debug "ixAccessDhcp config -clientId   \"${desc_list_local}$target_subport%1:${num_sessions}:1i\""
    ixAccessDhcp config -clientId   "${desc_list_local}$target_subport%1:${num_sessions}:1i"
debug "ixAccessDhcp config -serverId         $server_id"
    ixAccessDhcp config -serverId         $server_id
debug "ixAccessDhcp config -vendorClassId    $vendor_id"
    ixAccessDhcp config -vendorClassId    $vendor_id
debug "ixAccessDhcp config -releaseTimer     $lease_time"
    ixAccessDhcp config -releaseTimer     $lease_time
debug "ixAccessDhcp set $chassis $card $port $target_subport"
    set status [ixAccessDhcp set $chassis $card $port $target_subport]
    if { $status } {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Failed to\
                ixAccessDhcp set $chassis $card $port $target_subport."
        return $returnList
    }
    keylset returnList status $::SUCCESS
    return $returnList
}


## Internal Procedure Header
# Name:
#    ::ixia::ixa_dhcp_stats
#
# Description:
#    Controls DHCP subscriber group activity.
#
# Synopsis:
#    ::ixia::emulation_dhcp_stats
#        -port_handle
#        [-action       CHOICES clear]
#        [-handle]
#x       [-no_write     FLAG]
#x       [-version      CHOICES ixtclhal ixaccess
#x                      DEFAULT ixtclhal]]
#
# Arguments:
#    -port_handle
#        Specifies the port upon which emulation id configured.
#        This parameter is returned from emulation_dhcp_config proc.
#        Emulation must have been previously enabled on the specified port
#        via a call to emulation_dhcp_group_config proc.
#    -action
#        Clear - reset the statistics for the specified port/subscriber group
#        to 0.
#    -handle
#        Allows the user to optionally select the groups to which the
#        specified action is to be applied.
#        If this parameter is not specified, then the specified action is
#        applied to all groups configured on the port specified by
#        the -port_handle command. The handle is obtained from the keyed list returned
#        in the call to emulation_dhcp_group_config proc.
#        The port handle parameter must have been initialized and dhcp group
#        emulation must have been configured prior to calling this function.
#x   -no_write
#x       If this option is present, the configuration is not written to the
#x       hardware. This option can be used to queue up multiple configurations
#x       before writing to the hardware.
#x   -version
#x       Permits the selection between ixtclhal and ixaccess. This option must
#x       be set to ixaccess so that ixAccess Api is used.
#
# Return Values:
#    A keyed list
#    key:status        value:$::SUCCESS | $::FAILURE
#    key:log           value:When status is failure, contains more information
#    key:aggregate.currently_attempting  value:Total no of enabled interfaces
#    key:aggregate.currently_idle        value:Total no of interfaces not bounded
#    key:aggregate.currently_bound       value:Total no of addresses learned
#    key:aggregate.success_percentage    value:Percent rate of addresses learned
#    key:aggregate.discover_tx_count     value:Total no of discovered messages sent
#    key:aggregate.request_tx_count      value:Total no of requests sent
#    key:aggregate.release_tx_count      value:Total no of releases sent
#    key:aggregate.ack_rx_count          value:Total no of acks received
#    key:aggregate.nak_rx_count          value:Total no of nacks received
#    key:aggregate.offer_rx_count        value:Total no of offers received
#n   key:group.<group#>.currently_attempting
#n   key:group.<group#>.currently_idle
#n   key:group.<group#>.currently_bound
#n   key:aggregate.elapsed_time               value:Cisco only
#n   key:aggregate.total_attempted            value:Cisco only
#n   key:aggregate.total_retried              value:Cisco only
#n   key:aggregate.total_bound                value:Cisco only
#n   key:aggregate.bound_renewed              value:Cisco only
#n   key:aggregate.total_failed               value:Cisco only
#n   key:aggregate.bind_rate                  value:Cisco only
#n   key:aggregate.attempted_rate             value:Cisco only
#n   key:aggregate.minimum_setup_time        value:Cisco only
#n   key:aggregate.maximum_setup_time        value:Cisco only
#n   key:aggregate.average_setup_time        value:Cisco only
#n   key:group.<group#>.elapsed_time         value:Cisco only
#n   key:group.<group#>.total_attempted      value:Cisco only
#n   key:group.<group#>.total_retried        value:Cisco only
#n   key:group.<group#>.bound_renewed        value:Cisco only
#n   key:group.<group#>.total_bound          value:Cisco only
#n   key:group.<group#>.total_failed         value:Cisco only
#n   key:group.<group#>.bind_rate            value:Cisco only
#n   key:group.<group#>.attempt_rate         value:Cisco only
#n   key:group.<group#>.request_rate         value:Cisco only
#n   key:group.<group#>.release_rate         value:Cisco only
#n   key:group.<group#>.discover_tx_count    value:Cisco only
#n   key:group.<group#>.request_tx_count     value:Cisco only
#n   key:group.<group#>.release_tx_count     value:Cisco only
#n   key:group.<group#>.ack_rx_count         value:Cisco only
#n   key:group.<group#>.nak_rx_count         value:Cisco only
#n   key:group.<group#>.offer_rx_count       value:Cisco only
#n   key:<port_handle>.<group#>.inform_tx_count        value:Cisco only
#n   key:<port_handle>.<group#>.decline_tx_count       value:Cisco only
#
# Examples:
#    See files starting with DHCP_ in the Samples subdirectory. See the DHCP
#    example in Appendix A, "Example APIs," for one specific example usage.
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#
proc ::ixia::ixa_dhcp_stats {args} {
    variable dhcp_handles_array
    set args [lindex $args 0]

    set procName [lindex [info level [info level]] 0]

    ::ixia::utrackerLog $procName $args

    set mandatory_args {
        -port_handle
    }

    set optional_args {
        -handle
        -action       CHOICES clear
        -version      CHOICES ixtclhal ixaccess
                      DEFAULT ixtclhal
        -no_write
    }

    ::ixia::parse_dashed_args -args $args -optional_args $optional_args \
            -mandatory_args $mandatory_args

    # Check if the session handle is present in dhcp_handles_array

    set session_handle $port_handle

    if {! [info exists dhcp_handles_array($session_handle,session)]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The provided session\
                handle does not exist in dhcp_handles_array."
        return $returnList
    }

    # Check if the group handle is present in dhcp_handles_array
    if {[info exists handle]} {
        if {! [info exists dhcp_handles_array($handle,group)]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: The provided group\
                    handle does not exist in dhcp_handles_array."
            return $returnList
        } else {
            set s_handle [keylget dhcp_handles_array($handle,group) session]
            if {$s_handle != $session_handle} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: The provided session\
                        handle does not exist in \
                        dhcp_handles_array($handle,group)."
                return $returnList
            }
        }
        set target_subport [keylget dhcp_handles_array($handle,group) \
                target_subport]
    }

    set portHandle [keylget dhcp_handles_array($session_handle,session) \
            port_handle]
    set port_list [format_space_port_list $portHandle]

    if {![info exists target_subport]} {
        foreach temp_group_handle [array names dhcp_handles_array *,group] {
            set temp_session_handle [keylget dhcp_handles_array($temp_group_handle) \
                    session]
            if {$temp_session_handle == $session_handle} {
                set target_subport [keylget dhcp_handles_array($temp_group_handle) \
                        target_subport]
            }
        }
     }




    set interface [lindex $port_list 0]
    foreach {chassis card port} $interface {}

    if {![port isValidFeature $chassis $card $port \
                portFeatureProtocolDHCP]} {

        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: This card does not\
                support DHCP protocol."
        return $returnList
    }

    if {[info exists action]} {
        # Resetting all the stats for the selected port
        set portList [list $chassis,$card,$port]
        if {[ixClearStats portList]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure on call to\
                    ixClearStats $portList."
            return $returnList
        }
        keylset returnList status $::SUCCESS
        return $returnList
    }
    after 30000
    # Aggregate stats:
    if {[ixAccessPortStats get $chassis $card $port $target_subport]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failure on call to\
                ixAccessPortStats get $chassis $card $port $target_subport."
        return $returnList
    }

    set currently_attempting [ixAccessPortStats cget -dhcpEnabledInterfaces]
    set currently_bound      [ixAccessPortStats cget -dhcpAddressesDiscovered]
    set currently_idle       [mpexpr $currently_attempting - $currently_bound]

    if {$currently_attempting == 0} {
        set success_percentage 0
    } else {
        set success_percentage \
                [mpexpr 1.*$currently_bound/$currently_attempting*100]
    }

    set discover_tx_count [ixAccessPortStats cget -dhcpDiscoversTx]
    set request_tx_count  [ixAccessPortStats cget -dhcpRequestsTx]
    set release_tx_count  [ixAccessPortStats cget -dhcpReleasesTx]
    set ack_rx_count      [ixAccessPortStats cget -dhcpAckRx]
    set nak_rx_count      [ixAccessPortStats cget -dhcpNakRx]
    set offer_rx_count    [ixAccessPortStats cget -dhcpOffersRx]
    set interfaces_up     [ixAccessPortStats cget -ifsUp]

    keylset returnList aggregate.currently_attempting $currently_attempting
    keylset returnList aggregate.currently_bound      $currently_bound
    keylset returnList aggregate.currently_idle       $currently_idle
    keylset returnList aggregate.success_percentage   $success_percentage
    keylset returnList aggregate.discover_tx_count    $discover_tx_count
    keylset returnList aggregate.request_tx_count     $request_tx_count
    keylset returnList aggregate.release_tx_count     $release_tx_count
    keylset returnList aggregate.ack_rx_count         $ack_rx_count
    keylset returnList aggregate.nak_rx_count         $nak_rx_count
    keylset returnList aggregate.offer_rx_count       $offer_rx_count
    keylset returnList aggregate.interfaces_up        $interfaces_up

    keylset returnList status $::SUCCESS
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::macIsUniq
#
# Description:
#     If mode = "new" the procedure verifies if the range of mac addresses
#         provided is unique.
#     If mode = "existing", it will check if the range of mac addresses is
#         unique, but discarding the range of addresses that it will replace.
#     When mode is "existing", the handle of the group which contains this
#     mac address range MUST be specified.
#
#     The parameters mode, mac_addr, num_sessions are mandatory.
#
# Synopsis:
#    ::ixia::checkIaId {mode mac_addr mac_addr_step num_sessions handle}
#
# Return Values:
#     A keyed list
#     key:status      value:$::SUCCESS | $::FAILURE
#                     $::SUCCESS if mac is unique
#                     $::FAILURE if mac is duplicate
#     key:log         value:When status is failure, contains info
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
#
proc ::ixia::macIsUniq {mode mac_addr mac_addr_step num_sessions handle } {
    variable dhcp_handles_array

    set procName [lindex [info level [info level]] 0]

    set duplicate_mac 0
    set t_mac [::ixia::convertToIxiaMac $mac_addr]
    foreach var [array names dhcp_handles_array] {
        if {[regexp {,group} $var]} {
            if {($mode == "existing" && [lindex [split $var ","] 0] != $handle)\
                    || $mode == "new"} {
                set _mac [keylget dhcp_handles_array($var) mac_addr]
                if {[string compare -nocase $t_mac $_mac] == 0} {
                    set duplicate_mac 1
                    break
                } elseif {[string compare -nocase $t_mac $_mac] == 1} {
                    set _step [keylget dhcp_handles_array($var) mac_addr_step]
                    if {![info exists _step]} {
                        set _step 1
                    }
                    set _sess [mpexpr ([keylget dhcp_handles_array($var)\
                            num_sessions] - 1) * $_step]
                    set _mac_sup [::ixia::incrementMacAdd $_mac \
                            [format "%x" $_sess]]
                    if {[string compare -nocase $t_mac $_mac_sup] != 1} {
                        set duplicate_mac 2
                        break
                    }
                } elseif {[string compare -nocase $t_mac $_mac] == -1} {
                    if {$mac_addr_step == ""} {
                        set _step 1
                    } else  {
                        set _step $mac_addr_step
                    }
                    set _sess [mpexpr ($num_sessions - 1) * $_step]
                    set _mac_sup [::ixia::incrementMacAdd $mac_addr \
                            [format "%x" $_sess]]
                    if {[string compare -nocase $_mac_sup $_mac] != -1} {
                        set duplicate_mac 3
                        break
                    }
                }
            }
        }
    }

    if {$duplicate_mac == 1} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The base mac address \
                ($t_mac) is identical with the mac address ($_mac) from \
                [split $var ","]. Please supply a range of unique mac addresses."
        return $returnList
    } elseif {$duplicate_mac == 2} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The range of mac \
                addreses provided overlaps the \
                range of mac addresses starting with ($_mac) and ending\
                with ($_mac_sup) from [split $var ","]. Please supply a\
                range of unique mac addresses."
        return $returnList
    } elseif {$duplicate_mac == 3} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: The range of mac \
                addreses provided overlaps the range of mac addresses\
                starting with ($_mac) from [split $var ","]. Please \
                supply a range of unique mac addresses."
        return $returnList
    }

    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::ixaDHCPv6ResetSettingsHandle { port_handle handle } {
    variable dhcpv6_groups_list
    variable dhcpv6_settings_list

    set handles_list [list]
    if {$port_handle != "" && $handle == ""} {
        set dhcpv6_settings_list_regexp "^\\d*,$port_handle,.*,.*,.*,.*\$"
        set to_be_removed [lsearch -regexp -all $dhcpv6_settings_list \
                $dhcpv6_settings_list_regexp]
        if {$to_be_removed != -1} {
            for {set i [expr [llength $to_be_removed] - 1]} \
                    {$i >= 0} \
                    {incr i -1} {
                regexp "^(\\d*),.*,.*,.*,.*,.*\$" [lindex $dhcpv6_settings_list [lindex $to_be_removed $i]] \
                        {} handle_id
                lappend handles_list $handle_id
                set dhcpv6_settings_list [lreplace $dhcpv6_settings_list \
                        [lindex $to_be_removed $i] [lindex $to_be_removed $i]]
            }
        }
    } elseif {$port_handle == "" && $handle != ""} {
        set dhcpv6_settings_list_regexp "^$handle,.*,.*,.*,.*,.*\$"
        set to_be_removed [lsearch -regexp $dhcpv6_settings_list \
                $dhcpv6_settings_list_regexp]
        if {$to_be_removed != -1} {
            lappend handles_list $handle
            set dhcpv6_settings_list [lreplace $dhcpv6_settings_list \
                    $to_be_removed $to_be_removed]
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR: the $handle handle was not found in\
                    the DHCPv6 settings objects list."
            return $returnList
        }
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR: please use a non-null value for only one\
                of the -port_handle and -handle arguments."
        return $returnList
    }

    # Reset the groups associated with the settings objects' handles reset by 
    # this procedure. Pay some extra attention to the situation when the group
    # list contains only one group.
    if {[llength $handles_list] == 1} {
        set handles_list [list $handles_list]
    }
    # Create a regular expression that matches any of these handles.
    set index 1
    set handle_regex "([lindex $handles_list 0]"
    if {[llength $handles_list] > 1} {
        append handle_regex "|[lindex $handles_list $index]"
        incr index
    }
    append handle_regex ")"
    # Look for the groups defined using this settings object
    set dhcpv6_groups_list_regexp "^.*,$handle_regex,.*,.*,.*,.*,.*,.*,.*,.*,.*"
    append dhcpv6_groups_list_regexp ",.*,.*,.*,.*,.*,.*,.*,.*,.*,.*,.*,.*,.*"
    append dhcpv6_groups_list_regexp ",.*,.*,.*,.*,.*\$"
    set to_be_removed [lsearch -regexp -all $dhcpv6_groups_list \
            $dhcpv6_groups_list_regexp]
    if {$to_be_removed != -1} {
        for {set i [expr [llength $to_be_removed] - 1] } {$i >= 0} {incr i -1} {
            set regex "^(.*),.*,.*,.*,.*,.*,.*,.*,.*,.*,.*,.*,.*,.*,.*,.*,.*,.*"
            append regex ",.*,.*,.*,.*,.*,.*,.*,.*,.*,.*,.*\$"
            regexp $regex [lindex $dhcpv6_groups_list [lindex $to_be_removed \
                    $i]] {} group_handle
            ::ixia::ixaDHCPv6ResetGroupHandle $group_handle
        }
    }

    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::ixaDHCPv6ResetGroupHandle { handle } {
    variable dhcpv6_groups_list

    if {$handle != ""} {
        # Look for the settings object.
        set dhcpv6_groups_list_regexp "^$handle,.*,.*,.*,.*,.*,.*,.*,.*,.*"
        append dhcpv6_settings_list_regexp ",.*,.*,.*,.*,.*,.*,.*,.*,.*"
        append dhcpv6_settings_list_regexp ",.*,.*,.*,.*,.*,.*,.*,.*,.*"
        append dhcpv6_settings_list_regexp ",.*,.*,.*,.*,.*,.*,.*,.*,.*\$"
        set to_be_removed [lsearch -regexp $dhcpv6_groups_list \
                $dhcpv6_groups_list_regexp]
        if {$to_be_removed != -1} {
            set dhcpv6_groups_list [lreplace $dhcpv6_groups_list \
                    $to_be_removed $to_be_removed]
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR: the $handle handle was not found in\
                    the DHCPv6 groups list."
            return $returnList
        }
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR: please use a non-null value for the\
                -handle argument."
        return $returnList
    }


    keylset returnList status $::SUCCESS
    return $returnList
}
