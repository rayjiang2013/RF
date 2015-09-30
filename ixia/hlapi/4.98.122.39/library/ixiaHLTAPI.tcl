##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    ixiaHLTAPI.tcl
#
# Purpose:
#    A script development library containing general APIs for test automation 
#    with the Ixia chassis.
#
# Author:
#    Karim Lacasse
#
# Usage:
#    package req Ixia
#
# Description:
#    This library contains general purpose procedures that can 
#    be used during the TCL software development process utilize and configure 
#    the Ixia chassis and load modules.  The procedures contained 
#    within this library include: 
#    
#    - Traffic configuration
#    - Interface configuration
#    - Protocol Emulation
#    - Traffic and Protocol Statictics
#    - Capture
#
#    Use this library during the development of a script or 
#    procedure library to verify the software in a simulation 
#    environment and to perform an internal unit test on the 
#    software components.
#
# Requirements:
#    ixiaapiutils.tcl , a library containing TCL utilities
#    parseddashedargs.tcl , a library containing the procDescr and 
#        parse_dashed_args procedures
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


##Procedure Header
# Name:
#x   ::ixia::capture_packets
#
# Description:
#x   This command configures the capture filter and trigger, starting and 
#x   stopping packet capture on Ixia interfaces.
#
# Synopsis:
#x   ::ixia::capture_packets
#x       -port_handle           REGEXP ^[0-9]+/[0-9]+/[0-9]+$
#x       [-start                FLAG]
#x       [-stop                 FLAG]
#x       [-filter               CHOICES source_ipv4_address 
#x                              source_ipv6_address packet_size]
#x       [-get_all_packets      FLAG]
#x       [-get_packets          RANGE 0-1000000]
#x       [-packet_size          RANGE 40-64000]
#x       [-source_ipv4_address  IP]
#x       [-source_ipv6_address  IP]
#x       [-source_offset        NUMERIC]
#
# Arguments:
#x   -port_handle
#x       List of ports where the capture will take place.
#x   -start
#x       Start packet capture on the specified interface list.
#x   -stop
#x       Stop packet capture on the specified interface list.
#x   -filter
#x       Before starting the packet capture, you can configure the capture 
#x       buffer to filter packets based on their source IP address or packet 
#x       size. This prevents other packets like protocol hellos or keepalives 
#x       from being captured. 
#x           Valid choices are:
#x              source_ipv4_address
#x              source_ipv6_address
#x              packet_size
#x   -get_all_packets
#x       When true, it will return all packets captured.
#x   -get_packets
#x       When capture is done (that is, capture started and stopped), you can 
#x       use this option to grab packets from the capture buffer. You must 
#x       specify a number of packets to get from the buffer.
#x   -packet_size
#x       For option "filter" set to packet_size, this option specifies the 
#x       size of the packets to filter.
#x   -source_ipv4_address
#x       For option "filter" set to source_ipv4_address, this option specifies 
#x       the value of the IPv4 source IP address.
#x   -source_ipv6_address
#x       For option "filter" set to source_ipv6_address, this option specifies 
#x       the value of the IPv6 source IP address.
#x   -source_offset
#x       For option "filter" set to either source address, the offset of this 
#x       address in the packet must be supplied, so the filters can be set up 
#x       correctly.
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:On status of failure, gives detailed information.
#    key:$chassis/$card/$port.packets    value:$port_packet_content.
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
proc ::ixia::capture_packets { args } {

    set procName [lindex [info level [info level]] 0]
    ::ixia::logHltapiCommand $procName $args
    ::ixia::utrackerLog $procName $args

    # default values for optional args
    set reset 0
    set ex_ip ""
    set ex_range ""
    set optional_args {
        -start               FLAG
        -stop                FLAG
        -filter              CHOICES packet_size source_ipv4_address
                             CHOICES source_ipv6_address
        -get_all_packets     FLAG
        -get_packets         RANGE   0-1000000
        -packet_size         RANGE   40-64000
        -source_ipv4_address IP
        -source_ipv6_address IP
        -source_offset       NUMERIC
    }

    set mandatory_args {
        -port_handle REGEXP ^[0-9]+/[0-9]+/[0-9]+$
    }

    ::ixia::parse_dashed_args -args $args -optional_args $optional_args \
            -mandatory_args $mandatory_args

    set portList [format_space_port_list $port_handle]

    ############################
    # Configure Capture filter #
    ############################
    if {[info exists filter]} {

        foreach port $portList {

            set chassis [lindex $port 0]
            set card    [lindex $port 1]
            set port    [lindex $port 2]

            filter setDefault
            filterPallette setDefault

            if { $filter == "source_ipv4_address" } {
                # Configure Capture for source IPV4 ADDRESS
                if {![info exists source_ipv4_address]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: No\
                            source_ipv4_address input exists."
                    return $returnList
                } else {
                    set hexIpv4Address \
                            [convert_v4_addr_to_hex $source_ipv4_address]
                }

                if {![info exists source_offset]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: No\
                            source_offset option, which is required when\
                            the -filter option is source_ipv4_address."
                    return $returnList
                }

                filter config -captureTriggerPattern  pattern1
                filter config -captureFilterPattern   pattern1
                filterPallette config -pattern1       $hexIpv4Address
                filterPallette config -patternOffset1 $source_offset

            } elseif { $filter == "source_ipv6_address" } {

                # Configure Capture for source IPV6 ADDRESS
                if ![info exists source_ipv6_address] {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: No\
                            source_ipv6_address input exists."
                    return $returnList
                } else {
                    set hexIpv6Address [::ipv6::convertIpv6AddrToBytes \
                            $source_ipv6_address]
                }

                if {![info exists source_offset]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: No\
                            source_offset option, which is required when\
                            the -filter option is source_ipv6_address."
                    return $returnList
                }

                if {![info exists source_offset]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: No\
                            source_offset option, which is required when\
                            the -filter option is source_ipv6_address."
                    return $returnList
                }

                filter config  -captureTriggerPattern  pattern1
                filter config  -captureFilterPattern   pattern1
                filterPallette config -pattern1        $hexIpv6Address
                filterPallette config -patternMask1    {FF FF FF FF 00 00 00 \
                        00 00 00 00 00 00 00 00 00}
                filterPallette config -patternOffset1  $source_offset
            }

            # Configure Capture for PACKET_SIZE
            if { $filter == "packet_size" } {

                if ![info exists packet_size] {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: No\
                            exists_packet_size input exists."
                    return $returnList
                }
                filter config -captureTriggerFrameSizeEnable $::true
                filter config -captureTriggerFrameSizeFrom   $packet_size
                filter config -captureTriggerFrameSizeTo     $packet_size
                filter config -captureFilterFrameSizeEnable  $::true
                filter config -captureFilterFrameSizeFrom    $packet_size
                filter config -captureFilterFrameSizeTo      $packet_size
            }

            filter config -captureTriggerEnable $::true
            filter config -captureFilterEnable $::true
            set retCode [filter set $chassis $card $port]
            if {$retCode != 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failure in call to\
                        filter set $chassis $card $port.  Return code was\
                        $retCode."
                return $returnList
            }
            set retCode [filterPallette set $chassis $card $port]
            if {$retCode != 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Failure in call to\
                        filterPallette set $chassis $card $port.  Return code\
                        was $retCode."
                return $returnList
            }
        }

        if {[ixWriteConfigToHardware portList]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failure in\
                    ixWriteConfigToHardware."
            return $returnList
        }

        keylset returnList status $::SUCCESS
        return $returnList
    }

    #########################
    # Get Packets in Buffer #
    #########################
    set over_all_packet_content ""
    set port_packet_content     ""

    if {[info exists get_packets] || [info exists get_all_packets]} {

        if {[info exists get_packets]} {
            set numberOfPackets2Get $get_packets
            puts "\tGetting $get_packets packets from buffer on port: $portList"
        }

        foreach port $portList {

            set chassis [lindex $port 0]
            set card    [lindex $port 1]
            set port    [lindex $port 2]

            set port_packet_content     ""

            capture get $chassis $card $port
            set numberOfPacketsCaptured [capture cget -nPackets]

            if {[info exists get_all_packets]} {
                set numberOfPackets2Get $numberOfPacketsCaptured
            }

            if { $numberOfPacketsCaptured == 0 } {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: No packets were\
                        captured."
                return $returnList
            } elseif { $numberOfPackets2Get > $numberOfPacketsCaptured  } {

                puts "\tWarning :: Captured $numberOfPacketsCaptured packets\
                        on port $chassis:$card:$port, lower then the number\
                        of packets wanted ($numberOfPackets2Get)"

                set numberOfPackets2Get $numberOfPacketsCaptured
            }

            # Get the batch of frames
            captureBuffer get $chassis $card $port 1 $numberOfPackets2Get

            for {set i 1} {$i <= $numberOfPackets2Get} {incr i} {

                captureBuffer getframe $i

                # Get the actual frame data
                # --> SLICESIZE is default to 8191 bytes
                set frame_data [captureBuffer cget -frame]
                lappend port_packet_content $frame_data
            }

            #Create a list of lists for all the ports
            #lappend over_all_packet_content $port_packet_content
            keylset returnList $chassis/$card/$port.packets $port_packet_content
        }

        keylset returnList status $::SUCCESS
        return $returnList
    }

    ###  NOTE - DON'T NEED THIS; SIMPLY READING THE CAP BUFFER STOPS CAP
    ################
    # Stop Capture #
    ################
    if {[ info exists stop ]} {
        if {[ixStopCapture portList]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failure in\
                    ixStopCapture."
            return $returnList
        }
    }

    #################
    # Start Capture #
    #################
    if {[ info exists start ]} {
        # Make sure link is up on all ports before attempting to start capture
        if {[ixCheckLinkState portList] != 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Link on all ports\
                    is not up, cannot start capture."
            return $returnList
        }

        if {[ixStartCapture portList]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Failure in\
                    ixStartCapture."
            return $returnList
        }
    }

    keylset returnList status $::SUCCESS
    return $returnList
}


##Procedure Header
# Name:
#x   ::ixia::get_packet_content
#
# Description:
#x    This command gets a certain packet slice from the content of a packet. 
#x    From a list of packets passed by the user, the procedure extracts slices 
#x    from the packets and returns a list. The offset and slice_size are 
#x    decimal values that define the number of bytes.
#
# Synopsis:
#x   ::ixia::get_packet_content
#x       -offset            NUMERIC
#x       -slice_size        NUMERIC
#x       -packet_list
#x       [-enable_hex2dec]
#
# Arguments:
#x   -offset
#x       Decimal, number of bytes. Specifes where to start slicing the packets. 
#x       Valid choices start with 0.
#x   -slice_size
#x       Decimal, number of bytes to extract. Specifies the number of bytes to 
#x       extract from packet and return.
#x   -packet_list
#x       List of packets passed by the user to the procedure get_packet_content.
#x   -enable_hex2dec
#x       Enables the packet output to be shown as base ten values instead of 
#x       hexadecimal values.
#
# Return Values:
#    A keyed list
#    key:status            value:$::SUCCESS | $::FAILURE
#    key:packet_content    value:List of packet slices.
#
# Examples:
#
# Sample Output:
#
# Notes:
#
proc ::ixia::get_packet_content { args } {

    set procName [lindex [info level [info level]] 0]
    ::ixia::logHltapiCommand $procName $args
    ::ixia::utrackerLog $procName $args

    # default values for optional args
    set reset 0
    set optional_args [list \
            -enable_hex2dec]

    set mandatory_args [list            \
            -offset<-RANGE:0-64000>     \
            -slice_size<-RANGE:0-64000> \
            -packet_list]

    ::ixia::parse_dashed_args -args $args -optional_args $optional_args \
            -mandatory_args $mandatory_args

    set packet_content_list ""

    foreach packet $packet_list {
        set packet [string map {" " ""} $packet]
        set packet_slice [string range $packet $offset \
                [expr $offset + $slice_size - 1]]
        lappend packet_content_list $packet_slice
    }

    if {[info exists enable_hex2dec]} {
        # CONVERT THE HEX TO DECIMAL BEFORE!
        # Remove any spaces between hex groups
        set no_space_packet_content_list ""
        foreach packet_content $packet_content_list {
            set packet_content [string map {" " ""} $packet_content]
            lappend no_space_packet_content_list $packet_content
        }
        set packet_content_list [hex2dec_list $no_space_packet_content_list]
    }

    if {$packet_content_list == ""} {
        keylset returnList status $::FAILURE
    } else {
        keylset returnList status $::SUCCESS
        keylset returnList packet_content $packet_content_list
    }

    return $returnList
}
