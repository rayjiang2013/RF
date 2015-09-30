#Library Header
# $Id: $
# Copyright � 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    ixiaapiutils.tcl
#
# Purpose:
#    A script development library containing general utility APIs for test
#    automation with the Ixia chassis.
#
# Author:
#    Karim Lacasse
#
# Usage:
#    package req Ixia
#
# Description:
#    This library contains general purpose utilities utilized by the ixia HLTAPI
#    namespace library procedures. The procedures contained
#    within this library include:
#
#    ixia_sleep
#    ::ixia::mpexpr_compare
#    ::ixia::convertToIxiaMac
#    ::ixia::decrementHex
#    ::ixia::incrementHex
#    ::ixia::incrementMacAdd
#    ::ixia::incrementHexList
#    ::ixia::incrList
#    ::ixia::decrementMacAdd
#    ::ixia::get_port_type
#    ::ixia::portSupports
#    ::ixia::verify_port_aggregation
#    ::ixia::format_space_port_list
#    ::ixia::get_next_router_number
#    ::ixia::hex2dec_list
#    ::ixia::convert_string_to_hex
#    ::ixia::convert_v4_addr_to_hex
#    ::ixia::convert_v4_addr_to_v6
#    ::ixia::convert_v6_addr_to_hex
#    ::ixia::convert_v6_addr_to_v4
#    ::ixia::ipv6_host
#    ::ixia::ipv6_net
#    ::ixia::ipv6_net_incr
#    ::ixia::increment_ipv6_address
#    ::ixia::val2Bytes
#    ::ixia::list2Val
#    ::ixia::long_to_ip_addr
#    ::ixia::dec2bin
#    ::ixia::bit_mask_32
#    ::ixia::ip_addr_to_num
#    ::ixia::num_to_ip_addr
#    ::ixia::ip_step_from_mask_len
#    ::ixia::incrIpField_hlt_api
#    ::ixia::increment_ipv4_address
#    ::ixia::increment_ipv4_net
#    ::ixia::format_hex
#    ::ixia::format_signature_hex
#    ::ixia::format_field_hex
#    ::ixia::get_default_mac
#    ::ixia::get_default_udf_counter_type
#    ::ixia::keylprint
#    ::ixia::set_factory_defaults
#    ::ixia::reset_filters
#    ::ixia::reset_port_config
#    ::ixia::are_ports_transmitting
#    ::ixia::validate_mac_address
#    ::ixia::validate_choices_and_flag
#    isMacAddressValid
#    isIpAddressValid
#    ::ixia::isValidMacAddress
#    ::ixia::isValidHex
#    ::ixia::isValidIPAddress
#    ::ixia::isValidIPv4Address
#    ::ixia::isValidIPv4AddressAndPrefix
#    ::ixia::isValidIPv6AddressAndPrefix
#    ::ixia::increment_ipv6_address_hltapi
#    ::ixia::increment_ipv4_address_hltapi
#    ::ixia::getStepAndMaskFromIPv6
#    ::ixia::getNextLabel
#    ::ixia::removeDefaultOptionVars
#    ::ixia::is_default_param_value
#    ::ixia::addUdfRangeList
#    ::ixia::addPortToWrite
#    ::ixia::writePortListConfig
#    ::ixia::utracker
#    ::ixia::utrackerLog
#    ::ixia::utrackerLoadLibrary
#    ::ixia::ixNetTracer2
#    ::ixia::ixNetTracer3
#    ::ixia::ixNetTracer4
#    ::ixia::trace::translateObj
#    ::ixia::ixNetTracer5
#    ::ixia::debugTrace
#    ::ixia::debug
#    ::ixia::logHltapiCommand
#    ::ixia::instrument_message
#    ::ixia::getIpV6Type
#    ::ixia::getIpV6NetMaskFromPrefixLen
#    ::ixia::getIpV4NetMaskFromPrefixLen
#    ::ixia::mac2num
#    ::ixia::num2mac
#    ::ixia::hex2list
#    ::ixia::hex2listPadRight
#    ::ixia::incr_mac_addr
#    ::ixia::incr_ipv4_addr
#    ::ixia::incr_ipv6_addr
#    ::ixia::incr_ip_addr
#    ::ixia::expand_ipv6_addr
#    ::ixia::checkInterfacesCreation
#    ::ixia::checkBgpNeighborInterfacesAssignment
#    ::ixia::calcFrameGapRatio
#    ::ixia::byte2millisecond
#    ::ixia::millisecond2byte
#    ::ixia::getIpV6AddressTypeSupported
#    ::ixia::getIpV6MaskRangeFromIncrMode
#    ::ixia::getIpV6TclHalMode
#    ::ixia::getStepValueFromIpV6
#    ::ixia::get_random_mac
#    ::ixia::telnetCmd
#    ::ixia::getVarListFromArgs
#    ixNetShowCmd
#    ::ixia::convert_string_to_ascii_hex
#    ::ixia::convert_ascii_hex_to_string
#    ::ixia::convert_bits_to_int
#    ::ixia::_format_list
#    ::ixia::_validate_vlan_tpid
#    ::ixia::formatRsvpTlv
#    ::ixia::validate_list_range_1_32
#    ::ixia::validate_list_range_1_128 
#    ::ixia::validate_list_range
#    ::ixia::validate_flag_choice_0_1
#    ::ixia::validate_bgp_communities
#    ::ixia::dump_stack_trace
#    ::ixia::get_valid_chassis_id
#    ::ixia::get_valid_chassis_id_ixload
#    ::ixia::get_value_type
#    ::ixia::math_max
#    ::ixia::math_min
#    ::ixia::math_incr
#    ::ixia::isSetupVportCompatible
#    ::ixia::async_operations_array_add
#    ::ixia::async_operations_array_remove
#    ::ixia::async_operations_array_update
#    ::ixia::async_operations_array_get_status
#    ::ixia::get_packet_ip_offset
#    ::ixia::compare_ip_addresses
#    ::ixia::move_flags_last
#    ::ixia::print_keys
#    ::ixia::ixCheckLinkStateTracer
#
#
#    Use this library during the development of a script or
#    procedure library to verify the software in a simulation
#    environment and to perform an internal unit test on the
#    software components.
#
# Requirements:
#    ixiaHLTAPI.tcl , main source of ixia namespace
#    parseddashedargs.tcl , a library containing the procDescr and
#    parsedashedargds.tcl
#
# Variables:
#    To be added
#
# Keywords:
#    To be defined
#
# Category:
#    To be defined
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

;# ----- comment these routines in and the Ixia messages will be silent

;# proc logMsg { args } {
;#
;# }

;# proc ixPuts { args } {
;#
;# }


##Internal Procedure Header
# Name:
#    ixia_sleep
#
# Description:
#    Sleeps for the given duration in milliseconds
#
# Synopsis:
#    ixia_sleep
#        duration
#
# Arguments:
#    duration
#        The number of milliseconds to pause
#
# Return Values:
#
# Examples:
#
proc ixia_sleep {duration} {
   after $duration
}


##Internal Procedure Header
# Name:
#    ::ixia::mpexpr_compare
#
# Description:
#    Compares two numbers on more than 32 bits.
#
# Synopsis:
#    ::ixia::mpexpr_compare
#        a - first number
#        b - second number
#
# Arguments:
#        a - first number
#        b - second number
#
# Return Values:
#
# Examples:
#
proc ::ixia::mpexpr_compare {a b} {
    # Default b > a
    set retValue 1
    if {[mpexpr $a < $b]} {
        set retValue -1
    } elseif {[mpexpr $a == $b]} {
        set retValue 0
    }
    return $retValue
}


##Internal Procedure Header
# Name:
#    ::ixia::convertToIxiaMac
#
# Description:
#    Convert the various mac address styles into the Ixia preferred hex list
#
# Synopsis:
#    ::ixia::convertToIxiaMac
#        macAddress
#
# Arguments:
#    macAddress
#        Supported format:
#            0000.0000.0000
#            0000:0000:0000
#            00 00 00 00 00 00
#            00.00.00.00.00.00
#            00:00:00:00:00:00
#
# Return Values:
#    A mac address in the form {00 00 00 00 00 00}.  If the input is invalid
#    then this returns the input value.
#
# Examples:
#
proc ::ixia::convertToIxiaMac {mac {joinStr ""}} {

    # Replace all colons, periods, and spaces with null.
    regsub -all {\.} $mac "" tempMac
    regsub -all {:} $tempMac "" tempMac
    regsub -all { } $tempMac "" tempMac

    if {[string length $tempMac] != 12} {

        set ixiaMac $mac

    } else {

        set ixiaMac [format "%02s %02s %02s %02s %02s %02s" \
                [string range $tempMac 0 1] \
                [string range $tempMac 2 3] \
                [string range $tempMac 4 5] \
                [string range $tempMac 6 7] \
                [string range $tempMac 8 9] \
                [string range $tempMac 10 11]]
    }
    if {$joinStr != ""} {
        return [string tolower [join $ixiaMac $joinStr]]
    }
    return [string tolower $ixiaMac]
}


##Internal Procedure Header
# Name:
#    ::ixia::decrementHex
#
# Description:
#    Decrement a hex value by 1
#
# Synopsis:
#    ::ixia::decrementHex
#        hexVal
#
# Arguments:
#    hexVal
#        The hex value to be decremented.
#
# Return Values:
#
# Examples:
#
proc ::ixia::decrementHex {hexVal} {
    set num [format "0x$hexVal"]
    incr num -1
    return [format %02x [expr $num & 0xff]]
}


##Internal Procedure Header
# Name:
#    ::ixia::incrementHex
#
# Description:
#    Increments the given hex value by 1
#
# Synopsis:
#    ::ixia::incrementHex
#        hexVal
#
# Arguments:
#    hexVal
#        The hex value to be incremented.
#
# Return Values:
#
# Examples:
#
proc ::ixia::incrementHex {hexVal} {
    set num [format "0x$hexVal"]
    incr num
    return [format %02x [expr $num & 0xff]]
}


##Internal Procedure Header
# Name:
#    incrementMacAdd
#
# Description:
#    Increment the given MAC address by specified amount.
#    (default 00 00 00 00 00 01)
#
# Synopsis:
#    incrementMacAdd
#        macAdd
#        amount
#
# Arguments:
#    macAdd
#        The MAC address to increment
#    amount
#        Increment amount (default 00 00 00 00 00 01)
#
# Return Values:
#
# Examples:
#
proc ::ixia::incrementMacAdd { macAdd { amount 1 } } {
    # Replace all colons, periods, and spaces with null.
    regsub -all {\.} $macAdd "" tempMac
    regsub -all {:} $tempMac "" tempMac
    regsub -all { } $tempMac "" tempMac
    set macAdd "0x$tempMac"

    regsub -all {\.} $amount "" tempMac
    regsub -all {:} $tempMac "" tempMac
    regsub -all { } $tempMac "" tempMac
    set amount "0x$tempMac"

    set result [mpexpr $macAdd + $amount]
    for {set i 0} {$i < 6} {incr i} {
        set b$i [format "%02x" [mpexpr $result & 0xFF]]
        set result [mpexpr $result >> 8]
    }
    return "$b5 $b4 $b3 $b2 $b1 $b0"
}

##Internal Procedure Header
# Name:
#    incrementHexList
#
# Description:

#
# Synopsis:
#    incrementHexList
#        hexList
#        amountList
#
# Arguments:
#    hexList
#    amountList
#
# Return Values:
#
# Examples:
#
proc ::ixia::incrementHexList { hexList { amountList 1 } {joinStr :}} {
    # Replace all colons, periods, and spaces with null.
    set  l1 [regsub -all {\.} $hexList "" tempMac]
    incr l1 [regsub -all {:} $tempMac "" tempMac]
    incr l1 [regsub -all { } $tempMac "" tempMac]
    set hexList "0x$tempMac"

    set  l2 [regsub -all {\.} $amountList "" tempMac]
    incr l2 [regsub -all {:} $tempMac "" tempMac]
    incr l2 [regsub -all { } $tempMac "" tempMac]
    set amountList "0x$tempMac"

    set result [mpexpr $hexList + $amountList]
    set lmax [expr max($l1,$l2) + 1]
    set retVal ""
    for {set i 0} {$i < $lmax} {incr i} {
        set retVal "[format "%02x" [mpexpr $result & 0xFF]] $retVal"
        set result [mpexpr $result >> 8]
    }
    
    return [join $retVal $joinStr]
}

##Internal Procedure Header
# Name:
#    incrList
#
# Description:
#    Increment a list separated with ',' with another list which have 
#    same length. If result overlaps specified range value will be reset
#    to specified minimum
#
# Synopsis:
#    incrList
#        list
#        amount
#
# Arguments:
#    list
#        The comma seperated list to increment
#    amount
#        Increment amount
#
# Return Values:
#
# Examples:
#   incrList 1,2,3 4,5,6
# 

proc ::ixia::incrList {value amount {min 0} {max 4095}} {
    set result [list]
    foreach val_elem [split $value ,] am_elem [split $amount ,] {
        if {$am_elem == ""} {
            set am_elem [lindex [split $amount ,] end]
        }
        set cr_value [expr $val_elem + $am_elem]
        if {$cr_value > $max} {
            set cr_value [expr $cr_value - $max + $min]
        }
        lappend result $cr_value
    }
    return [join $result ,]
}

##Internal Procedure Header
# Name:
#    ::ixia::decrementMacAdd
#
# Description:
#    Decrement the given MAC address by specified amount.
#    (default 00 00 00 00 00 01)
#
# Synopsis:
#    decrementMacAdd
#        macAdd
#        amount
#
# Arguments:
#    macAdd
#        The MAC address to be decremented
#    amount
#        Decrement amount (default 00 00 00 00 00 01)
#
# Return Values:
#
# Examples:
#
proc ::ixia::decrementMacAdd { macAdd { amount 1 } } {
    # Replace all colons, periods, and spaces with null.
    regsub -all {\.} $macAdd "" tempMac
    regsub -all {:} $tempMac "" tempMac
    regsub -all { } $tempMac "" tempMac
    set macAdd "0x$tempMac"

    regsub -all {\.} $amount "" tempMac
    regsub -all {:} $tempMac "" tempMac
    regsub -all { } $tempMac "" tempMac
    set amount "0x$tempMac"

    set result [mpexpr $macAdd - $amount]
    for {set i 0} {$i < 6} {incr i} {
        set b$i [format "%02x" [mpexpr $result & 0xFF]]
        set result [mpexpr $result >> 8]
    }
    return "$b5 $b4 $b3 $b2 $b1 $b0"
}


##Internal Procedure Header
# Name:
#    ::ixia::get_port_type
#
# Description:
#    Get a generic Ixia specific port characterization
#
# Synopsis:
#    ::ixia::get_port_type
#        chassis
#        card
#        port
#
# Arguments:
#    chassis
#        The chassis number
#    card
#        The card number
#    port
#        The port number
#
# Return Values:
#
# Examples:
#
proc ::ixia::get_port_type { chassis card port } {

    if {[port get $chassis $card $port] == $::TCL_OK} {

        switch [port getInterface $chassis $card $port] "
            $::interface10100 -
            $::interfaceUSB {
                set portType ethernet10100
            }
            $::interface10100Gigabit -
            $::interfaceGigabit {
                set portType ethernet1000
            }
            default {
                if [port isValidFeature $chassis $card $port portFeaturePos] {
                    set portType sonet
                } elseif [port isValidFeature $chassis $card $port \
                        portFeatureAtm] {
                    set portType atm
                } elseif {[port isValidFeature $chassis $card $port \
                        portFeature10GigLan] || \
                        [port isValidFeature $chassis $card $port \
                        portFeature10GigWan]} {
                    set portType ethernet10000
                } elseif [port isValidFeature $chassis $card $port \
                        portFeatureBert] {
                    set portType bert
                } else {
                    set portType unknown
                }
            }
        "
        return $portType
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::portSupports
#
# Description:
#    Checks to see if port supports
#        ethernet
#        pos
#
#
# Synopsis:
#    ::ixia::portSupports
#        chassis
#        card
#        port
#        type
#
# Arguments:
#    chassis
#        The chassis number
#    card
#        The card number
#    port
#        The port number
#    type
#        The type of encapsulatin/feature that the port should support.
#        Valid choices are ethernet, pos, usb, atm, poe, bert.
#
# Return Values:
#
# Examples:
#
proc ::ixia::portSupports { chassis card port type} {
    variable port_supports_types
    array set allPorts [list \
            1,1 {
                {type port10100BaseTX}  {name {"10/100 Base TX"}}
                {ethernet {10 100}}
            } \
            2,1 {
                {type port10100BaseMII} {name {"10/100 MII"}}
                {ethernet {10 100}}
            } \
            3,1 {
                {type port100BaseFXMultiMode} {name {"100 Base FX MultiMode"}}
                {ethernet 100}
            } \
            4,1 {
                {type port100BaseFXSingleMode} {name {"100 Base FX SingleMode"}}
                {ethernet 100}
            } \
            5,1 {
                {type portGigabitSXMultiMode} {name {"1000 Base SX MultiMode"}}
                {ethernet 1000}
            } \
            6,1 {
                {type portGigabitLXSingleMode} {name ""}
                {ethernet 1000}
            } \
            7,1 {
                {type portReducedMII} {name {"10/100 Reduced MII"}}
                {ethernet {10 100}}
            } \
            8,1 {
                {type portGbic} {name {"GBIC"}}
                {ethernet 1000}
            } \
            9,1 {
                {type portPacketOverSonet} {name {"OC12c/OC3c POS"}}
                {pos {oc12 oc3}}
            } \
            10,1 {
                {type port10100Level3} {name {"10/100 Base TX - 3"}}
                {ethernet {10 100}}
            } \
            11,1 {
                {type portGigabitLevel3} {name {"1000 Base SX MultiMode - 3"}}
                {ethernet 1000}
            } \
            12,1 {
                {type portGbicLevel3} {name {"GBIC-3"}}
                {pos oc192}
            } \
            13,1 {
                {type portGigCopper} {name {"GBIC"}}
                {ethernet 1000}
            } \
            14,1 {
                {type portPosOc48} {name {"OC48c POS"}}
                {pos oc48}
            } \
            15,1 {
                {type portPosOc48Level3} {name {"OC48c POS-M"}}
                {pos oc48}
            } \
            16,1 {
                {type portPosOc192} {name {"OC192c POS"}}
                {pos oc192}
            } \
            17,1 {
                {type portPosOc192Level3} {name {"OC192c POS-3"}}
                {pos oc192}
            } \
            18,1 {
                {type portUsbUsb} {name {"USB"}}
                {usb 1}
            } \
            19,1 {
                {type portGigaCopperGMii} {name ""}
                {pos oc192}
            } \
            20,1 {
                {type portUsbEthernet} {name {"Ethernet"}}
                {usb 1} {ethernet 100}
            } \
            21,1 {
                {type portPosOc192Fob2} {name ""}
                {pos oc192}
            } \
            22,1 {
                {type portPosOc192Fob1} {name ""}
                {pos oc192}
            } \
            23,1 {
                {type portPosOc192Plm2} {name ""}
                {pos oc192}
            } \
            24,1 {
                {type portPosOc192Plm1} {name ""}
                {pos oc192}
            } \
            26,1 {
                {type portPosOc3}   {name ""}
                {pos oc3}
            } \
            27,1 {
                {type portPosOc48VariableClocking}  {name {"OC48c POS VAR"}}
                {pos oc48}
            } \
            28,1 {
                {type portGigCopperTripleSpeed} {name {"Copper 10/100/1000"}}
                {ethernet {10 100 1000}}
            } \
            29,1 {
                {type portGigSingleMode}    {name {"1000 Base LX SingleMode"}}
                {ethernet 1000}
            } \
            32,1 {
                {type portOc48Bert} {name {"OC48c POS BERT"}}
                {pos oc48}
            } \
            33,1 {
                {type portOc48PosAndBert}   {name {"OC48c POS/BERT"}}
                {pos oc48} {bert 1}
            } \
            36,1 {
                {type port10GEWAN2} {name {"OC192c POS"}}
                {pos oc192}
            } \
            37,1 {
                {type port10GEWAN1}
                {name {"OC192c POS" "OC192c VSR"}}
                {pos oc192}
            } \
            37,2 {
                {type port10GEWAN1}  {name {"OC193c POS/BERT/10GE WAN"}}
                {pos oc192} {ethernet 10000} {wan 1}
            } \
            37,3 {
                {type port10GEWAN1}  {name {"10GE BERT/WAN"}}
                {ethernet 10000} {wan 1} {bert 1}
            } \
            41,1 {
                {type port10GEXGMII1}   {name ""}
                {ethernet 10000}
            } \
            45,1 {
                {type port10GEXAUI1}    {name {"10GE XAUI"}}
                {ethernet 10000}
            } \
            45,2 {
                {type port10GEXAUI1} {name {"10GE XAUI/BERT"}}
                {ethernet 10000} {bert 1}
            } \
            45,3 {
                {type port10GEXAUI1}    {name {"10GE XAUI BERT"}}
                {bert 1}
            } \
            46,1 {
                {type port10GigLanXenpak2_M}    {name ""}
                {ethernet 10000} {lan 1}
            } \
            47,1 {
                {type port10GigLanXenpak1_M}    {name ""}
                {ethernet 10000} {lan 1}
            } \
            48,1 {
                {type port10GigLanXenpak2}  {name ""}
                {ethernet 10000} {lan 1}
            } \
            49,1 {
                {type port10GigLanXenpak1}
                {name {"10GE XENPAK" "10GE XENPAK-M"}}
                {ethernet 10000} {lan 1}
            } \
            49,2 {
                {type port10GigLanXenpak1}
                {name {"10GE XENPAK/BERT" "10GE XENPAK-MA/BERT"}}
                {ethernet 10000} {bert 1} {lan 1}
            } \
            49,3 {
                {type port10GigLanXenpak1}  {name {"10GE XENPAK BERT"}}
                {bert 1} {lan 1}
            } \
            51,1 {
                {type port10GELAN_M}    {name ""}
                {ethernet 10000} {lan 1}
            } \
            53,1 {
                {type port10GELAN1} {name { "10GE LAN" "10GE LAN-M"}}
                {ethernet 10000} {lan 1}
            } \
            55,1 {
                {type port10100UsbSh4}  {name ""}
                {usb 1} {ethernet {10 100}}
            } \
            56,1 {
                {type port10100Sh4} {name ""}
                {ethernet {10 100}}
            } \
            60,1 {{type portLffCarrier1} {name ""}
                {ethernet {10 100}}
            } \
            61,1    {{type portLffCarrier2} {name ""}
                {ethernet {10 100}}
            } \
            63,1 {
                {type port10100Txs} {name {"10/100 Base TX"}}
                {ethernet {10 100}}
            } \
            67,1 {
                {type port1000Sfps4} {name {"1000 Base X" "1000 Base X L7"}}
                {ethernet 1000}
            } \
            68,1 {
                {type port1000Txs4}
                {name {"10/100/1000 Base T" "10/100/1000 Base T L7"}}
                {ethernet {10 100 1000}}
            } \
            69,1 {
                {type portSingleRateBertUnframed}
                {name {"Unframed BERT Single-Rate"}}
                {bert 1}
            } \
            70,1 {
                {type portMultiRateBertUnframed}
                {name {"Unframed BERT Multi-Rate"}}
                {bert 1}
            } \
            71,1 {
                {type port10GeUniphy_MA}    {name ""}
                {ethernet 10000} {pos oc192} {bert 1} {lan 1} {wan 1}
            } \
            72,1 {
                {type port10GeUniphy}
                {name {"10GE LAN/WAN / OC1-192 POS/BERT"}}
                {ethernet 10000} {pos oc192} {bert 1} {lan 1} {wan 1}
            } \
            73,1 {
                {type port40GigBertUnframed}
                {name {"Unframed Bert 40Gig Port"}}
                {bert 1}
            } \
            74,1 {
                {type portOc12Atm}  {name {"ATM/POS 622 Multi-Rate"}}
                {pos {oc3 oc12}} {atm 1}
            } \
            75,1 {
                {type portOc12Pos32Mb}  {name {"OC12 POS 32MB"}}
                {pos oc12}
            } \
            76,1 {
                {type portOc48Txs}  {name ""}
                {pos oc48}
            } \
            77,1 {
                {type port1000Txs24}    {name {"10/100/1000 Base T"}}
                {ethernet {10 100 1000}}
            } \
            78,1 {
                {type portTcpx} {name ""}
                {ethernet 1000}
            } \
            80,1 {
                {type port101001000Layer7}  {name ""}
                {ethernet {10 100 1000}}
            } \
            80,2 {
                {type port101001000ALMT8}   {name "10/100/1000 ALM T8"}
                {ethernet {10 100 1000}}
            } \
            81,1 {
                {type port10GEXenpakP}  {name ""}
                {ethernet 1000}
            } \
            82,1 {
                {type port1000Stxs4}    {name ""}
                {ethernet {10 100 1000}}
            } \
            83,1 {
                {type port10GUniphyP}   {name ""}
                {ethernet 10000} {pos oc192} {bert 1} {lan 1} {wan 1}
            } \
            84,1 {
                {type port10GELSM}  {name "10GE LSM XM3"}
                {ethernet 10000} {lan 1} {wan 1}
            } \
            84,2 {
                {type port10GELSM}  {name "10GE LSM XMR3"}
                {ethernet 10000} {lan 1} {wan 1}
            } \
            84,3 {
                {type port10GELSM}  {name "10GE LSM"}
                {ethernet 10000} {lan 1}
            } \
            84,4 {
                {type port10GELSM}  {name "10GE LSM XL6"}
                {ethernet 10000} {lan 1}
            } \
            85,1 {
                {type port10GEMultiMSA} {name ""}
                {ethernet 10000}
            } \
            86,1 {
                {type port10GUniphyXFP} {name ""}
                {ethernet 10000} {pos oc192} {bert 1} {lan 1} {wan 1}
            } \
            87,1 {
                {type portPowerOverEthernet}    {name ""}
                {poe 1}
            } \
            88,1 {
                {type port2Dot5GMSM}    {name ""}
                {pos oc48}
            } \
            89,1 {
                {type port10GMSM}   {name ""}
                {ethernet 10000} {pos oc192}
            } \
            90,1 {
                {type port101001000Inline}    {name "10/100/1000 Base T - Inline"}
                {ethernet {10 100 1000}}
            } \
            91,1 {
                {type port101001000Monitor}    {name "10/100/1000 Base T - Monitor"}
                {ethernet {10 100 1000}}
            } \
            92,1 {
                {type portLSM101001000XMV16X}    {name "10/100/1000 LSM XMVR16"}
                {ethernet {10 100 1000}}
            } \
            94,1 {
                {type portASM101001000XMV12X}    {name "10/100/1000 ASM XMV12X"}
                {ethernet {10 100 1000}}
            } \
            95,1 {
                {type portASMXMV10GigAggregrated}    {name "10G LAN XFP Aggregate"}
                {ethernet 10000} {lan 1}
            } \
            97,1 {
                {type portLANXFP}    {name "10G LAN/WAN XFP (MACSec)"}
                {ethernet 10000} {lan 1} {wan 1}
            } \
            98,1 {
                {type port10GLANWANXFP}    {name "10GE LSM XM8"}
                {ethernet 10000} {lan 1} {wan 1}
            } \
            99,1 {
                {type portVoiceQualityResourceModule}    {name "Voice quality resource module"}
                {ethernet 10000} {lan 1} {wan 1}
            } \
            100,1 {
                {type port40GE100GELSM}    {name "40GE LSM XMV and 100GE LSM XMV modules"}
                {ethernet {40000 100000}} {lan 1} {bert 1}
            } \
            102,1 {
                {type portFlexAP10G16S}    {name "LAN SFP+ 10GBASE-SR/LR"}
                {ethernet {10000}} {lan 1}
            } \
            103,1 {
                {type portFlexAP40QP}    {name "LAN 40GE QSFP+"}
                {ethernet {40000}} {lan 1}
            } \
            104,1 {
                {type port40GELSMQSFP }    {name "40GE LAN"}
                {ethernet {40000}} {lan 1} {bert 1}
            } \
            105,1 {
                {type portFCMSFP}          {name "FCM SFP+"}
                {ethernet {2000 4000 8000}} {fcm 1}
            } \
            106,1 {
                {type portXDM10G32S}       {name ""}
                {ethernet {10000}} {lan 1}
            } \
            106,2 {
                {type portXDM10G8S}       {name ""}
                {ethernet {10000}} {lan 1}
            } \
            107,1 {
                {type portIxVM}       {name "Ixia Virtual Port"}
                {ethernet {100 1000 10000}}
            } \
            108,1 {
                {type portLava}       {name "40GE/100GE LAN"}
                {ethernet {40000 100000}} {lan 1} {bert 1}
            } \
            118,1 {
                {type portJasper}       {name "100GE LAN"}
                {ethernet {100000}} {lan 1}
            } \
            119,1 {
                {type portJasper}       {name "40GE/10GE LAN w/FANOUT"}
                {ethernet {40000 10000}} {lan 1}
            } \
            121,1 {
                {type portJasper}       {name "10GE/40GE/10GE LAN"}
                {ethernet {40000 10000}} {lan 1}
            } \
            ]
   
    if {![catch {keylget port_supports_types ${chassis}/${card}/${port}}]} {
        set portIndex [keylget port_supports_types ${chassis}/${card}/${port}.portIndex]
        set portName  [keylget port_supports_types ${chassis}/${card}/${port}.portName]
        set indexList [array names allPorts ${portIndex},*]
        foreach {index} $indexList {
            set portNameTemp [keylget allPorts($index) name]
            if {($portNameTemp != "") && ([lsearch $portNameTemp \
                    $portName] != -1) } {
                if {[catch {keylget allPorts($index) $type} value]} {
                    return 0
                } else  {
                    return $value
                }
            }
        }
        foreach {index} $indexList {
            set portNameTemp [keylget allPorts($index) name]
            if {[catch {keylget allPorts($index) $type} value]} {
                continue
            } else  {
                return $value
            }
        }
    }
    return 0
}

##Internal Procedure Header
# Name:
#    ::ixia::verify_port_aggregation
#
# Description:
#    Checks to see if port supports the aggregation resource mode
#
# Synopsis:
#    ::ixia::verify_port_aggregation
#        port_handle
#        aggregation_resource_mode
#
# Arguments:
#    port_handle
#        The chassis number
#    aggregation_resource_mode
#        The card number
#
# Return Values:
#
# Examples:
#

proc ::ixia::verify_port_aggregation {card_type port_list_item agg_res_mode {agg_res_mode_api_name "N/A"}} {
    keylset returnList status $::SUCCESS
    variable new_ixnetwork_api
    variable chassis_list
    foreach {chassis card port} [split $port_list_item /] {}
    
    # validation for Lava cards (the rest of the combo cards follow other rules
    # for aggregation
    if {[string first "Lava AP40/100GE" $card_type] != -1} {
        switch -- $agg_res_mode {
            single_mode_aggregation {
                if {$port==1 || $port==2} {
                    return $returnList
                } else {
                    keylset returnList log "Aggregation mode $agg_res_mode is\
                            not valid for this port."
                    keylset returnList status $::FAILURE
                    return $returnList
                }
            }
            dual_mode_aggregation   {
                if {$port>=3 || $port<=6} {
                    return $returnList
                } else {
                    keylset returnList log "Aggregation mode $agg_res_mode is\
                            not valid for this port."
                    keylset returnList status $::FAILURE
                    return $returnList
                }
            }
            default {
                keylset returnList log "Aggregation mode $agg_res_mode is\
                        not valid for this card."
                keylset returnList status $::FAILURE
                return $returnList
            }
        }
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        # IxNetwork branch
        foreach {chassis card port} [split $port_list_item /] {}
        set hostname [::ixia::getHostname $::ixia::ixnetwork_chassis_list $chassis]
                
        if {$hostname == -1} {
            keylset returnList status $::FAILURE
            keylset returnList log "Unable to find the ID associated to this\
                    chassis."
            return $returnList
        }
        set connected_to "::ixNet::OBJ-/availableHardware/chassis:\"$hostname\"/card:$card/port:$port"
        set card_objref "::ixNet::OBJ-/availableHardware/chassis:\"$hostname\"/card:$card"
    	
		if {[info exists ::ixia::aggregation_map($card_objref,$port,available_port_modes)]} {
			if {[lsearch $::ixia::aggregation_map($card_objref,$port,available_port_modes) $agg_res_mode_api_name] == -1} {
				keylset returnList status $::FAILURE
				keylset returnList log "$agg_res_mode aggregation mode is unsupported for $card_type ($card_objref)."
				return $returnList
			}
		} else {
            if {[info exists ::ixia::aggregation_map($card_objref)]} {
                set available_aggregations $::ixia::aggregation_map($card_objref)
            } else {
                set available_aggregations [ixNet getL $card_objref aggregation]
				set available_modes        [ixNet getA $card_objref -availableModes]
                set ::ixia::aggregation_map($card_objref) $available_aggregations
				set ::ixia::aggregation_map($card_objref,available_modes) $available_modes
            }
            foreach aggregation $available_aggregations {
                set resource_list [ixNet getA $aggregation -resourcePorts]
				set available_port_modes [ixNet getA $aggregation -availableModes]
				set ::ixia::aggregation_map($card_objref,$port,available_port_modes) $available_port_modes
				set ::ixia::aggregation_map($card_objref,$port) $aggregation
            }
			if {[info exists ::ixia::aggregation_map($card_objref,$port,available_port_modes)]} {
				if {[lsearch $::ixia::aggregation_map($card_objref,$port,available_port_modes) $agg_res_mode_api_name] == -1} {
					keylset returnList status $::FAILURE
					keylset returnList log "$agg_res_mode aggregation mode is unsupported for $card_type ($card_objref)."
					return $returnList
				}
			} else {
				keylset returnList log "Failed to determine supported aggregations for $card_objref port $port."
				keylset returnList status $::FAILURE
				return $returnList
			}
        }
    } else {
        # Protocols branch
        # Verify if the Resource Group supports the aggregation type specified
        array set card_agg_support {
            normal                  {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16}
            ten_gig_aggregation     {1 5 9 13}
            forty_gig_aggregation   {17 18 19 20}
        }
        foreach {chassis card port} [split $port_list_item /] {
            if {[lsearch $card_agg_support($agg_res_mode) $port] == -1} {
                keylset returnList log "Aggregation mode $agg_res_mode is not valid for\
                        port ${chassis}/${card}/${port}."
                keylset returnList status $::FAILURE
                return $returnList
            }
        }
    }
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::format_space_port_list
#
# Description:
#    Takes a list of ports in the format a/b/c and makes them into a b c
#
# Synopsis:
#    ::ixia::format_space_port_list
#        intf_list
#
# Arguments:
#    intf_list
#        The interface list.  A list of ports in the form a/b/c
#
# Return Values:
#
# Examples:
#
proc ::ixia::format_space_port_list { intf_list } {
    set portList ""
    foreach {ch ca po} $intf_list {
        if {[info exists ch] && ([string is integer $ch]) && \
                    [info exists ca] && ([string is integer $ca]) && \
                    [info exists po] && ([string is integer $po])} {
            set intf_list [list $intf_list]
        }
    }
    foreach port $intf_list {
        # Input port list is in the format A/B/C, make it A B C
        regsub -all {/} $port " " port
        set portList [lappend portList $port]
    }
    return $portList
}


##Internal Procedure Header
# Name:
#    ::ixia::get_next_router_number
#
# Description:
#
# Synopsis:
#    ::ixia::get_next_router_number
#        protocol
#        interface
#
# Arguments:
#    protocol
#    interface
#
# Return Values:
#
# Examples:
#
proc ::ixia::get_next_router_number { protocol interface } {

    set chassis [lindex $interface 0]
    set card    [lindex $interface 1]
    set port    [lindex $interface 2]
    set router_number 0

    switch -- $protocol {
        ldp {
            ldpServer select $chassis $card $port

            if {[ldpServer getFirstRouter] == 1} {
                set next_router [expr $router_number + 1]
                return ${chassis}/${card}/${port}ldpRouter$next_router
            } else {
                incr router_number
                while { [ldpServer getNextRouter] == 0 } {
                    incr router_number
                }
                set next_router [expr $router_number + 1]
                return ${chassis}/${card}/${port}ldpRouter$next_router
            }
        }
        isis {
            isisServer select $chassis $card $port

            if {[isisServer getFirstRouter] == 1} {
                set next_router [expr $router_number + 1]
                return ${chassis}/${card}/${port}isisRouter$next_router
            } else {
                incr router_number
                while { [isisServer getNextRouter] == 0 } {
                    incr router_number
                }
                set next_router [expr $router_number + 1]
                return ${chassis}/${card}/${port}isisRouter$next_router
            }
        }
        ospf {
            ospfServer select $chassis $card $port

            if {[ospfServer getFirstRouter] == 1} {
                set next_router [expr $router_number + 1]
                return ${chassis}/${card}/${port}ospfRouter$next_router
            } else {
                incr router_number
                while { [ospfServer getNextRouter] == 0 } {
                    incr router_number
                }
                set next_router [expr $router_number + 1]
                return ${chassis}/${card}/${port}ospfRouter$next_router
            }
        }
        mld {
            mldServer select $chassis $card $port

            if {[mldServer getFirstHost] == 1} {
                set next_router [expr $router_number + 1]
                return ${chassis}/${card}/${port}mldHost$next_router
            } else {
                incr router_number
                while { [mldServer getNextHost] == 0 } {
                    incr router_number
                }
                set next_router [expr $router_number + 1]
                return ${chassis}/${card}/${port}mldHost$next_router
            }
        }
        rip {
            ripServer select $chassis $card $port

            if {[ripServer getFirstRouter] == 1} {
                set next_router [expr $router_number + 1]
                return ${chassis}/${card}/${port}ripRouter$next_router
            } else {
                incr router_number
                while { [ripServer getNextRouter] == 0 } {
                    incr router_number
                }
                set next_router [expr $router_number + 1]
                return ${chassis}/${card}/${port}ripRouter$next_router
            }
        }
        ripng {
            ripngServer select $chassis $card $port

            if {[ripngServer getFirstRouter] == 1} {
                set next_router [expr $router_number + 1]
                return ${chassis}/${card}/${port}ripngRouter$next_router
            } else {
                incr router_number
                while { [ripngServer getNextRouter] == 0 } {
                    incr router_number
                }
                set next_router [expr $router_number + 1]
                return ${chassis}/${card}/${port}ripngRouter$next_router
            }
        }
        pim {
            pimsmServer select $chassis $card $port

            if {[pimsmServer getFirstRouter] == 1} {
                set next_router [expr $router_number + 1]
                return ${chassis}/${card}/${port}pimsmRouter$next_router
            } else {
                incr router_number
                while { [pimsmServer getNextRouter] == 0 } {
                    incr router_number
                }
                set next_router [expr $router_number + 1]
                return ${chassis}/${card}/${port}pimsmRouter$next_router
            }
        }
        default {}
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::hex2dec_list
#
# Description:
#
# Synopsis:
#    ::ixia::hex2dec_list
#        hex_list
#
# Arguments:
#    hex_list
#
# Return Values:
#
# Examples:
#
proc ::ixia::hex2dec_list { hex_list } {

    set dec_list [list]

    foreach hex_element $hex_list {
        set hex_element_list [list]

        foreach single_hex_element $hex_element {
            set single_dec_element [hextodec $single_hex_element]
            lappend hex_element_list $single_dec_element
        }
        lappend dec_list $hex_element_list
    }
    return $dec_list
}


##Internal Procedure Header
# Name:
#    ::ixia::convert_string_to_hex
#
# Description:
#
# Synopsis:
#    ::ixia::convert_string_to_hex
#        representation
#
# Arguments:
#    representation
#        The value represented in any of the supported formats
#
# Return Values:
#
# Examples:
#
proc ::ixia::convert_string_to_hex { representation } {
    # Replace all colons, periods, and spaces with null.
    regsub {^0[xX]} $representation "" temp
    regsub -all {\.} $temp "" temp
    regsub -all {:} $temp "" temp
    regsub -all { } $temp "" temp

    return [format "%s" $temp]
}

proc ::ixia::convert_string_to_hex_capture { representation } {
    # Replace all colons, periods, and spaces with null.
    regsub {^0[xX]} $representation "" temp
    regsub -all {\.} $temp "" temp
    regsub -all {:} $temp "" temp

    return [format "%s" $temp]
}

##Internal Procedure Header
# Name:
#    ::ixia::convert_v4_addr_to_hex
#
# Description:
#
# Synopsis:
#    ::ixia::convert_v4_addr_to_hex
#        addr
#
# Arguments:
#    addr
#
# Return Values:
#
# Examples:
#
proc ::ixia::convert_v4_addr_to_hex {addr} {
    set addr [split $addr .]
    set addr_hex ""
    foreach byte $addr {
        lappend addr_hex [format "%02x" [mpexpr $byte & 0xff]]
    }
    return $addr_hex
}

##Internal Procedure Header
# Name:
#    ::ixia::convert_v4_addr_to_v6
#
# Description:
#
# Synopsis:
#    ::ixia::convert_v4_addr_to_v6
#        addr
#
# Arguments:
#    addr
#
# Return Values:
#
# Examples:
#
proc ::ixia::convert_v4_addr_to_v6 {addr} {
    set addr [split $addr .]
    set addr_hex ""
    set byte_count 0
    foreach byte $addr {
        if {[expr $byte_count % 2] == 0} {
            append addr_hex [format "%02x" [mpexpr $byte & 0xff]]
        } else {
            append addr_hex "[format "%02x" [mpexpr $byte & 0xff]]:"
        }
    }
    return 0::[string trim $addr_hex :]
}

##Internal Procedure Header
# Name:
#    ::ixia::convert_v6_addr_to_hex
#
# Description:
#
# Synopsis:
#    ::ixia::convert_v6_addr_to_hex
#        addr
#
# Arguments:
#    addr
#
# Return Values:
#
# Examples:
#
proc ::ixia::convert_v6_addr_to_hex {addr} {
    set addr [split [::ipv6::expandAddress $addr] :]
    set addr_hex ""
    foreach byte $addr {
        lappend addr_hex [format "%02x" [mpexpr 0x$byte >> 8]]
        lappend addr_hex [format "%02x" [mpexpr 0x$byte & 0x00ff]]
    }
    return $addr_hex
}

##Internal Procedure Header
# Name:
#    ::ixia::convert_v6_addr_to_v4
#
# Description:
#
# Synopsis:
#    ::ixia::convert_v6_addr_to_v4
#        addr
#
# Arguments:
#    addr
#
# Return Values:
#
# Examples:
#
proc ::ixia::convert_v6_addr_to_v4 {ipAddr} {
    set ipNum 0
    set ipAddr [::ixia::expand_ipv6_addr $ipAddr]
    scan $ipAddr "%x:%x:%x:%x:%x:%x:%x:%x" a b c d e f g h
    
    set byte4 [mpexpr ($b & 0x00FF)]
    set byte3 [mpexpr ($b & 0xFF00) >> 8]
    set byte2 [mpexpr ($a & 0x00FF)]
    set byte1 [mpexpr ($a & 0xFF00) >> 8]
    
    return "$byte1.$byte2.$byte3.$byte4"
}


########### IPv6 procs ###########


##Internal Procedure Header
# Name:
#    ::ixia::ipv6_host
#
# Description:
#
# Synopsis:
#    ::ixia::ipv6_host
#        ip
#        prefix
#
# Arguments:
#    ip
#    prefix
#
# Return Values:
#
# Examples:
#
proc ::ixia::ipv6_host { ip prefix } {
    return [mpexpr [list2Val [::ipv6::convertIpv6AddrToBytes $ip]] & \
            (int(pow(2,(128 - $prefix)) - 1))]
}


##Internal Procedure Header
# Name:
#    ::ixia::ipv6_net
#
# Description:
#
# Synopsis:
#    ::ixia::ipv6_net
#        ip
#        prefix
#
# Arguments:
#    ip
#    prefix
#
# Return Values:
#
# Examples:
#
proc ::ixia::ipv6_net { ip prefix } {
    return [mpexpr [list2Val [::ipv6::convertIpv6AddrToBytes $ip]] >> \
            (128 - $prefix)]
}


##Internal Procedure Header
# Name:
#    ::ixia::ipv6_net_incr
#
# Description:
#
# Synopsis:
#    ::ixia::ipv6_net_incr
#        ip
#        prefix
#        inc
#
# Arguments:
#    ip
#    prefix
#    inc
#
# Return Values:
#
# Examples:
#
proc ::ixia::ipv6_net_incr { ip prefix {inc 1} } {

    set host [ipv6_host $ip $prefix]
    set netw [ipv6_net  $ip $prefix]
    mpincr   netw $inc

    return [::ipv6::convertBytesToIpv6Address [val2Bytes \
            [mpexpr ($netw << (128 - $prefix)) | $host] 16]]
}


##Internal Procedure Header
# Name:
#    ::ixia::increment_ipv6_address
#
# Description:
#
# Synopsis:
#    ::ixia::increment_ipv6_address
#        ip
#        prefix
#        inc
#
# Arguments:
#    ip
#    prefix
#    inc
#
# Return Values:
#
# Examples:
#
proc ::ixia::increment_ipv6_address { ip {prefix 32} {inc 1} } {
    set ip [::ipv6::expandAddress $ip]
    return [ipv6_net_incr $ip $prefix $inc]
}


##Internal Procedure Header
# Name:
#    ::ixia::val2Bytes
#
# Description:
#
# Synopsis:
#    ::ixia::val2Bytes
#        val
#        width
#
# Arguments:
#    val
#    width
#
# Return Values:
#
# Examples:
#
proc ::ixia::val2Bytes { val width } {
    
    set val [split $val "."]
    set val [split $val ":"]
    if {[llength $val] > 1} {
        set val 0x[join $val ""]
    }
    
    set retVal {}
    while {$width} {
        set insertVal [mpexpr $val & 0xFF]
        set retVal [format "%02x %s" $insertVal $retVal]
        incr width -1
        set val [mpexpr $val >> 8]
    }
        
    return $retVal
}


##Internal Procedure Header
# Name:
#    ::ixia::list2Val
#
# Description:
#
# Synopsis:
#    ::ixia::list2Val
#        str
#
# Arguments:
#    str
#
# Return Values:
#
# Examples:
#
proc ::ixia::list2Val { str } {
    set val 0
    foreach byte $str {
        set val [mpexpr ($val << 8) | 0x$byte]
    }
    return $val
}


##Internal Procedure Header
# Name:
#    ::ixia::long_to_ip_addr
#
# Description:
#
# Synopsis:
#    <using the BNF format>
#
# Arguments:
#
# Return Values:
#
# Examples:
#
proc ::ixia::long_to_ip_addr { value } {
    if [catch {set address [format "%s.%s.%s.%s" \
            [expr {(($value >> 24) & 0xff)}] \
            [expr {(($value >> 16) & 0xff)}] \
            [expr {(($value >> 8 ) & 0xff)}] \
            [expr {$value & 0xff}]]} address] {
        set address 0.0.0.0
    }

    return $address
}

##Internal Procedure Header
# Name:
#    ::ixia::dec2bin
#
# Description:
#   transforms a integer value to a binary number
# Synopsis:
#    ::ixia::dec2bin
#           integer
#           number_of_characters_to_split
#           char_used_to_split
# Arguments:
#
# Return Values:
#
# Examples:
#   ::ixia::dec2bin 17 8 { }
#       00000000 00000000 00000000 00010001
#
proc ::ixia::dec2bin {int {num 8} {char " "}} {
    binary scan [binary format I $int] B* var
    set len     [string length $var]
    set first    [expr $len - $num]
    set x        ""
    while { $len > 0} {
        # grab left num chars
        set lef [string range $var $first end]
        if {[string length $x] > 0} {
            set x   "${lef}$char${x}"
        } else {
            set x   ${lef}
        }
        # grab everything except left num chars
        set var [string range  $var 0 [expr $first -1]]
        set len   [string length $var]
        set first [expr $len - $num]
    }
    return $x
}


##Internal Procedure Header
# Name:
#    ::ixia::bit_mask_32
#
# Description:
#   transforms a integer value to a binary mask
# Synopsis:
#    ::ixia::bit_mask_32
#           integer
#           number_of_characters_to_split
#           char_used_to_split
# Arguments:
#
# Return Values:
#
# Examples:
#   ::ixia::bit_mask_32 12 8 { }
#       00000000 00000000 00001111 11111111
#
proc ::ixia::bit_mask_32 {int {num 8} {char " "}} {
    binary scan [binary format I $int] B* var
    if {($int>0)&($int<33)} {
        set data [list [string repeat 0 [expr 32-$int]] [string repeat 1 $int]]
        set var [join $data ""]
        set len   [string length $var]
        set first [expr $len - $num]
        set x     ""
        while { $len > 0} {
            # grab left num chars
            set lef [string range $var $first end]
            if {[string length $x] > 0} {
                set x   "${lef}$char${x}"
            } else {
                set x   ${lef}
            }
            # grab everything except left num chars
            set var [string range  $var 0 [expr $first -1]]
            set len   [string length $var]
            set first [expr $len - $num]
        }
    } elseif {$int < 1} {
        set x "00000000 00000000 00000000 00000001"
    } else {
        set x "11111111 11111111 11111111 11111111"
    }
    return $x
}


##Internal Procedure Header
# Name:
#    ::ixia::ip_addr_to_num
#
# Description:
#
# Synopsis:
#    ::ixia::ip_addr_to_num
#        ipAddr
#
# Arguments:
#    ipAddr
#
# Return Values:
#
# Examples:
#
proc ::ixia::ip_addr_to_num { ipAddr } {
    set ipNum 0
    
    if {[::isIpAddressValid $ipAddr]} {
        scan $ipAddr "%d.%d.%d.%d" a b c d
        set ipNum [mpformat [mpexpr ($a<<24)|($b<<16)|($c<<8)|$d]]
    } elseif {[::ipv6::isValidAddress $ipAddr]} {
        set ipAddr [::ixia::expand_ipv6_addr $ipAddr]
        scan $ipAddr "%x:%x:%x:%x:%x:%x:%x:%x" a b c d e f g h
        catch {set ipNum [mpformat [mpexpr ($a<<112)|($b<<96)|($c<<80)|($d<<64)|($e<<48)|($f<<32)|($g<<16)|$h]]}
    }

    return $ipNum
}


##Internal Procedure Header
# Name:
#    ::ixia::num_to_ip_addr
#
# Description:
#
# Synopsis:
#    ::ixia::num_to_ip_addr
#        ipNum
#        ipVer
#
# Arguments:
#    ipNum
#    ipVer
#
# Return Values:
#
# Examples:
#
proc ::ixia::num_to_ip_addr { ipNum ipVer } {
    if {$ipVer == 4} {
        set byte4 [mpexpr ($ipNum & 0x000000FF)]
        set byte3 [mpexpr ($ipNum & 0x0000FF00) >> 8]
        set byte2 [mpexpr ($ipNum & 0x00FF0000) >> 16]
        set byte1 [mpexpr ($ipNum & 0xFF000000) >> 24]
    
        return "$byte1.$byte2.$byte3.$byte4"
    } else {
        set word8 [format "%x" \
                [mpexpr ($ipNum & 0x0000000000000000000000000000FFFF)]]
        set word7 [format "%x" \
                [mpexpr ($ipNum & 0x000000000000000000000000FFFF0000) >> 16]]
        set word6 [format "%x" \
                [mpexpr ($ipNum & 0x00000000000000000000FFFF00000000) >> 32]]
        set word5 [format "%x" \
                [mpexpr ($ipNum & 0x0000000000000000FFFF000000000000) >> 48]]
        set word4 [format "%x" \
                [mpexpr ($ipNum & 0x000000000000FFFF0000000000000000) >> 64]]
        set word3 [format "%x" \
                [mpexpr ($ipNum & 0x00000000FFFF00000000000000000000) >> 80]]
        set word2 [format "%x" \
                [mpexpr ($ipNum & 0x0000FFFF000000000000000000000000) >> 96]]
        set word1 [format "%x" \
                [mpexpr ($ipNum & 0xFFFF0000000000000000000000000000) >> 112]]
    
        return "$word1:$word2:$word3:$word4:$word5:$word6:$word7:$word8"
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::ip_step_from_mask_len
#
# Description:
#
# Synopsis:
#    ::ixia::ip_step_from_mask_len
#        maskLen
#        ipVer
#
# Arguments:
#    maskLen
#    ipVer
#
# Return Values:
#
# Examples:
#
proc ::ixia::ip_step_from_mask_len { maskLen ipVer } {
    if {$ipVer == 4} {
        return [::ixia::num_to_ip_addr [expr 1 << (32 - $maskLen)] 4]
    } else {
        return [::ixia::num_to_ip_addr [mpexpr 1 << (128 - $maskLen)] 6]
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::incrIpField_hlt_api
#
# Description:
#
# Synopsis:
#    ::ixia::incrIpField_hlt_api
#        ipAddress
#        byteNum
#        amount
#
# Arguments:
#    ipAddress
#    byteNum
#    amount
#
# Return Values:
#
# Examples:
#
proc ::ixia::incrIpField_hlt_api { ipAddress {byteNum 4} {amount 1} } {
    set one [ip_addr_to_num $ipAddress]
    set two [expr {$amount<<(8*(4-$byteNum))}]

    return  [long_to_ip_addr [expr {$one + $two}]]
}


##Internal Procedure Header
# Name:
#    ::ixia::increment_ipv4_address
#
# Description:
#
# Synopsis:
#    ::ixia::increment_ipv4_address
#        ipAddress
#        byteNum
#        amount
#
# Arguments:
#    ipAddress
#    byteNum
#    amount
#
# Return Values:
#
# Examples:
#
proc ::ixia::increment_ipv4_address { ipAddress {byteNum 4} {amount 1} } {
    return [incrIpField_hlt_api $ipAddress $byteNum $amount]
}


##Internal Procedure Header
# Name:
#    ::ixia::increment_ipv4_net
#
# Description:
#
# Synopsis:
#    ::ixia::increment_ipv4_net
#        ipAddress
#        netmask
#        amount
#
# Arguments:
#    ipAddress
#    netmask
#    amount
#
# Return Values:
#
# Examples:
#
proc ::ixia::increment_ipv4_net {ipAddress {netmask 24} {amount 1}} {
    set ipVal [::ixia::ip_addr_to_num $ipAddress]
    set ipVal [mpexpr ($ipVal >> (32 - $netmask)) + $amount]
    set ipVal [mpexpr ($ipVal << (32 - $netmask)) & 0xFFFFFFFF]

    return  [long_to_ip_addr $ipVal]
}


##Internal Procedure Header
# Name:
#    ::ixia::format_hex
#
# Description:
#
# Synopsis:
#    ::ixia::format_hex
#        hex_val
#        counter_size
#
# Arguments:
#    hex_val
#    counter_size
#
# Return Values:
#
# Examples:
#
proc ::ixia::format_hex { hex_val {counter_size 8} } {

    set counter_size_temp [mpexpr $counter_size - 8]
    set counter_size_a [mpexpr $counter_size / 8]
    set counter_size_b [mpexpr $counter_size % 8]

    if {$counter_size_b > 0} {
        return
    }
    set formatting [string trim [string repeat "%02x " $counter_size_a]]
    set values ""
    while {$counter_size_temp >= 0} {
        lappend values [mpexpr ($hex_val >> $counter_size_temp) & 0xff]
        incr counter_size_temp -8
    }

    set config "format \"$formatting\" $values"
    set values [eval $config]
    return $values
}

##Internal Procedure Header
# Name:
#    ::ixia::format_signature_hex
#
# Description:
#
# Synopsis:
#    ::ixia::format_signature_hex
#        value
#        max
#        min
#
# Arguments:
#    hex_val
#    counter_size
#
# Return Values:
#
# Examples:
#
proc ::ixia::format_signature_hex { value {max 12} {min 0}} {

    if {[string is integer $value]} {
        keylset returnList status $::SUCCESS
        keylset returnList signature \
                [::ixia::format_hex [format "0x%x" $value] [expr $max * 8]]
        return $returnList
    }
    regexp {[0-9a-fA-F]+} $value match_value1
    if {[info exists match_value1] && ($match_value1 == $value)} {
        keylset returnList status $::SUCCESS
        keylset returnList signature \
                [::ixia::format_hex 0x$value [expr $max * 8]]
        return $returnList
    }

    set regexpRet [regexp "^(\[0-9a-fA-F\]{2}\[.: \]{0,1}){$min,[expr $max - 1]}\[0-9a-fA-F\]{2}$" \
            $value match_value2]
    if {![info exists match_value2]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Invalid signature: $value"
        return $returnList
    }

    set value [string map {. "" : "" " " ""} $value]

    keylset returnList status $::SUCCESS
    keylset returnList signature \
            [::ixia::format_hex 0x$value [expr $max * 8]]

    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::format_signature_hex
#
# Description:
#
# Synopsis:
#    ::ixia::format_signature_hex
#        value
#        max
#        min
#
# Arguments:
#    hex_val
#    counter_size
#
# Return Values:
#
# Examples:
#
proc ::ixia::format_field_hex { value } {
    if {[string is integer $value]} {
        set incrv 0
        if {[expr [string length [format "%x" $value]] % 2] > 0} {
            set incrv 1
        } 
        keylset returnList status $::SUCCESS
        keylset returnList hexNumber [::ixia::format_hex \
                [format "0x%x" $value]                   \
                [expr ([string length [format "%x" $value]] / 2 + $incrv) * 8]]
        return $returnList
    }
    regexp {[0-9a-fA-F]+} $value match_value1
    set incrv 0
    if {[expr [string length $value] % 2] > 0} {
        set incrv 1
    }
    if {[info exists match_value1] && ($match_value1 == $value)} {
        keylset returnList status $::SUCCESS
        
        keylset returnList hexNumber          \
                [::ixia::format_hex 0x$value  \
                [expr ([string length $value] / 2 + $incrv) * 8]]
        return $returnList
    }

    set regexpRet [regexp "^(\[0-9a-fA-F\]{2}\[.: \]{0,1})*\[0-9a-fA-F\]{2}$" \
            $value match_value2]
    if {![info exists match_value2]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Invalid signature: $value"
        return $returnList
    }

    set max   [regsub -all {[.: ]} $value {} value_ignore]
    set value [string map {. "" : "" " " ""} $value]

    keylset returnList status $::SUCCESS
    keylset returnList hexNumber \
            [::ixia::format_hex 0x$value [expr ($max + 1) * 8]]

    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::get_default_mac
#
# Description:
#
# Synopsis:
#    ::ixia::get_default_mac
#        chassis
#        card
#        port
#
# Arguments:
#    chassis
#    card
#    port
#
# Return Values:
#
# Examples:
#
proc ::ixia::get_default_mac { chassis card port } {
    return [format "00de.%02x%02x.%02x00" $chassis $card $port]
}


##Internal Procedure Header
# Name:
#    ::ixia::get_default_udf_counter_type
#
# Description:
#
# Synopsis:
#    ::ixia::get_default_udf_counter_type
#
# Arguments:
#
# Return Values:
#
# Examples:
#
proc ::ixia::get_default_udf_counter_type {} {
    switch -- [udf cget -countertype] "
        $::c16 -
        $::c16x8 -
        $::c16x16 {
            set counter_type 16
        }
        $::c16x8x8 {
        $::c24 -
        $::c24x8 -
            set counter_type 24
        }
        $::c32 {
            set counter_type 32
        }
        default {
            set counter_type 8
        }
    "
    return $counter_type
}

##Internal Procedure Header
# Name:
#    ::ixia::keylprint
#
# Description:
#   This procedure shows the keyed list in a proper manner
# Synopsis:
#    ::ixia::keylprint
#
# Arguments:
#
# Return Values:
#
# Examples:
#
proc ::ixia::keylprint {keylist {space ""}} {
    upvar $keylist kl
    set result ""

    foreach key [keylkeys kl] {
            set value [keylget kl $key]
            if {[catch {keylkeys value}]} {
                append result "$space$key: $value\n"
            } else {
                set newspace "$space "
                append result "$space$key:\n[keylprint value $newspace]"
            }
    }
    return $result
}


##Internal Procedure Header
# Name:
#    ::ixia::get_factory_defaults
#
# Description:
#
# Synopsis:
#    ::ixia::get_factory_defaults
#        portList
#        write
#
# Arguments:
#    portList
#    write
#
# Return Values:
#
# Examples:
#
proc ::ixia::set_factory_defaults { portList {write nowrite} } {
    keylset returnList status $::SUCCESS
    
    set atmPortList ""
    foreach port $portList {
        scan $port "%d %d %d" chassisId cardId portId
        if {[port isValidFeature $chassisId $cardId $portId $::portFeatureAtm]} {
            lappend atmPortList [list $chassisId $cardId $portId]
        }
    }
    if {$atmPortList != ""} {
        if {[ixClearStats atmPortList]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in ::ixia::set_factory_defaults: \
                    Resetting ports $portList failed (ixClearStats $atmPortList)"
            return $returnList
        }
    }
    
    foreach port $portList {
        scan $port "%d %d %d" chassisId cardId portId
        # reset interface
        debug "port setFactoryDefaults $chassisId $cardId $portId"
        if {[set retCode [port setFactoryDefaults $chassisId $cardId $portId]]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in ::ixia::set_factory_defaults: \
                    Resetting ports $portList failed (port setFactoryDefaults\
                    $chassisId $cardId $portId - $retCode)"
            return $returnList
        }
        if {[port set $chassisId $cardId $portId]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in ::ixia::set_factory_defaults: \
                    Resetting ports $portList failed (port set)"
            return $returnList
        }
    }

    if {($write == "write") && ($portList != "")} {
        if {[ixWritePortsToHardware portList]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in ::ixia::set_factory_defaults: \
                    Writing ports to hardware $portList failed."
            return $returnList
        }
    }

    return $returnList
}

proc ::ixia::reset_filters { spaced_port_list } {
    
    set cmdList [list]
    
    lappend cmdList "filter --reset"
    lappend cmdList "filter --set-pattern=0/0@0:0"
	set reset_filters_supported 1
	foreach port $spaced_port_list {
		foreach {chassis_id card_id port_id} $port {}
		if {[card get $chassis_id $card_id] == $::TCL_OK} {
			if { [expr [card cget -type] > 190] } {
				# Newer cards (Multis for example) do not support resetting filters using IxTclHal 
				# if any card with id >190 is detected (191 is the first Jasper card) will disable
				# the reset filters command (this command requires 1 CPU/port)
				set reset_filters_supported 0 
				puts "WARNING! Card [card cget -typeName] does not support resetting filters! Filter reset will not be performed."
				break
			} 
		}
	}

	if {$reset_filters_supported == 1} {
		foreach cmd $cmdList {
			debug "issuePcpuCommand $spaced_port_list $cmd"
			catch {issuePcpuCommand spaced_port_list $cmd}
		}
	}
}

##Internal Procedure Header
# Name:
#    ::ixia::reset_port_config
#
# Description:
#    Removes all protocols and configured streams from the port
#
# Synopsis:
#    ::ixia::reset_port_config
#        portList
#        write
#
# Arguments:
#    portList
#    write
#
# Return Values:
#
# Examples:
#
proc ::ixia::reset_port_config { portList {write nowrite} } {
    keylset returnList status $::SUCCESS

    foreach port $portList {
        scan $port "%d %d %d" chassisId cardId portId

        # get the configuration from port
        set retCode [port get $chassisId $cardId $portId]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in ::ixia::reset_streams: \
                    Unable to get the configuration for port: \
                    $chassisId $cardId $portId"
            return $returnList
        }

        # reset protocols
        set ret_val [::ixia::reset_protocol_interface_for_port \
                -port_handle "$chassisId/$cardId/$portId"]
        if {[keylget ret_val status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in ::ixia::reset_port_config: \
                    Resetting ports $portList failed (::ixia::reset_protocol_interface_for_port)"
            return $returnList
        }
        # reset streams
        if {[port isActiveFeature $chassisId $cardId $portId portFeatureAtm]} {
            array unset atmStatsConfig
            streamQueueList select $chassisId $cardId $portId
            streamQueueList clear
        } else  {
            set retCode [port reset $chassisId $cardId $portId]
            if {$retCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in ::ixia::reset_port_config: \
                        Unable to reset port: $chassisId $cardId $portId"
                return $returnList
            }
        }
        if {[port set $chassisId $cardId $portId]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in ::ixia::reset_port_config: \
                    Resetting ports $portList failed (port set)"
            return $returnList
        }
    }

    if {($write == "write") && ($portList != "")} {
        if {[ixWritePortsToHardware portList]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in ::ixia::reset_port_config: \
                    Writing ports to hardware $portList failed."
            return $returnList
        }
    }
    
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::are_ports_transmitting
#
# Description:
#
# Synopsis:
#    ::ixia::are_ports_transmitting
#        port_list
#
# Arguments:
#    port_list
#
# Return Values:
#
# Examples:
#
proc ::ixia::are_ports_transmitting { port_list } {

    # gratuitous wait incase the user did not do one properly before calling
    variable new_ixnetwork_api
    after 1000
    set running 0

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        if {[ixNet getA [ixNet getRoot]/traffic -isTrafficRunning] == "true"} {
            set running 1
        } else {
            set running 0
        }
    } else {
        foreach port $port_list {
            foreach {c l p} $port {}
            if {[stat getTransmitState $c $l $p] == $::statActive} {
                set running 1
            }
            if {$running} {
                break
            }
        }
    }
    return $running
}

##Internal Procedure Header
# Name:
#    ::ixia::validate_latency_and_jitter_bins
#
# Description:
#
# Synopsis:
#
# Arguments:
#
# Return Values:
#
# Examples:
#

proc ::ixia::validate_latency_and_jitter_bins { value } {
    
    if {$value == "enabled"} {
        return 1
    } elseif { [string is integer $value] } {
        return 1
    } else {
        return [list 0 "Valid values can be either a number (between 2-16) or\
                the string \"enabled\""]
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::validate_mac_address
#
# Description:
#
# Synopsis:
#
# Arguments:
#
# Return Values:
#
# Examples:
#

proc ::ixia::validate_mac_address { macAddress } {
    
    set ret_val [isValidMacAddress $macAddress]
    
    if {$ret_val == 0} {
        return [list 0 "Invalid MAC address"]
    }
    
    return 1
}

##Internal Procedure Header
# Name:
#    ::ixia::validate_choices_and_flag
#
# Description:
#
# Synopsis:
#
# Arguments:
#
# Return Values:
#
# Examples:
#

proc ::ixia::validate_choices_and_flag { {value ""} } {
    
    if {$value == "" || \
            $value == 0       || \
            $value == 1       || \
            $value == "true"  || \
            $value == "false" || \
            $value == "True"  || \
            $value == "False"    \
            } {return 1}
    
    return [list 0 "Invalid flag or choice"]
    
}

proc isIpAddressValid {ipAddress} {

    set retCode $::true

    if {[info tclversion] == "8.0"} {
        # Advanced regular expressions are not supported in 8.0

        # First check to see that there are four octets
        if {[regexp {^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$} $ipAddress]} {

            # Now check each octet for a legitimate value
            foreach byte [split $ipAddress .] {
                if {($byte < 0) || ($byte > 255)} {
                    set retCode $::false
                    break
                }
            }
        } else {
            set retCode $::false
        }
    } else {

        # The ip address should be four octets
        if {[regexp {^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$} \
                $ipAddress]} {

            # Now check each octet for a legitimate value
            foreach byte [split $ipAddress .] {
                if {($byte < 0) || ($byte > 255)} {
                    set retCode $::false
                    break
                }
            }
        } else {
            set retCode $::false
        }
    }

    return $retCode
}

proc isMacAddressValid {macAddress} \
{
    set retCode $::TCL_ERROR

    regsub -all { |:} $macAddress " " macAddress
    if {[llength $macAddress] == 6} {

        set retCode $::TCL_OK
        foreach value $macAddress {
            if {[string length $value] == 2} {
                if {![regexp {[0-9a-fA-F]{2}} $value match]} {
                    set retCode $::TCL_ERROR
                    break
                }
            } else {
                set retCode $::TCL_ERROR
                break
            }
        }
    }

    return $retCode
}


proc ::ixia::isValidMacAddress { macAddress } {

    set threeSegment \
            {^[0-9a-fA-F]{4}[.: ]{1}[0-9a-fA-F]{4}[.: ]{1}[0-9a-fA-F]{4}$}

    set twoSegment \
            {^[0-9a-fA-F]{2}[.: ]{1}[0-9a-fA-F]{2}[.: ]{1}[0-9a-fA-F]{2}[.: ]{1}}
    append twoSegment \
            {[0-9a-fA-F]{2}[.: ]{1}[0-9a-fA-F]{2}[.: ]{1}[0-9a-fA-F]{2}$}

    if {[regexp $threeSegment|$twoSegment $macAddress]} {
        set retValue 1
    } else {
        set retValue 0
    }
    return $retValue
}

##Internal Procedure Header
# Name:
#    ::ixia::isValidHex hexNum
#
# Description:
#       Returns 1 if hexNum is in one of the following formats:
#               0xaabbcc
#               aabbcc
#               aa.bb.cc
#               {aa bb cc}
#               aa:bb:cc
#
# Synopsis:
#
# Arguments:
#
# Return Values:
#
# Examples:
#
proc ::ixia::isValidHex { hexNum {maxLength {0} } } {

    set zeroXFormat {(^0x)([0-9a-fA-F])+$}

    set oneSegment {^[0-9a-fA-F]+$}

    set twoSegment \
            {^(([0-9a-fA-F]{2}[\.: ])+)([0-9a-fA-F]{2})$}

    if {[regexp $zeroXFormat|$oneSegment|$twoSegment $hexNum]} {
        set retValue 1
    } else {
        set retValue 0
    }
    
    if {$maxLength != 0 && $retValue != 0} {
        set hexNumAsList [hex2list $hexNum]
        if {[llength $hexNumAsList] > $maxLength} {
            set retValue 0
        }
    }
    
    return $retValue
}

##Internal Procedure Header
# Name:
#    ::ixia::isValidIPAddress
#
# Description:
#
# Synopsis:
#
# Arguments:
#
# Return Values:
#
# Examples:
#
proc ::ixia::isValidIPAddress { ipAddressList } {
    set retVal 1
    foreach ipAddress $ipAddressList {
        set retVal [expr $retVal && ([isIpAddressValid $ipAddress] || [::ipv6::isValidAddress $ipAddress])]
    }
    return $retVal
}

##Internal Procedure Header
# Name:
#    ::ixia::isValidIPv4Address
#
# Description:
#
# Synopsis:
#
# Arguments:
#
# Return Values:
#
# Examples:
#
proc ::ixia::isValidIPv4Address { ipv4address } {

    if {[regexp -all {^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$} $ipv4address]} {
        foreach nibble [split $ipv4address .] {
            if {$nibble > 255} {
                return 0
            }
        }
    } else {
        return 0
    }
    return 1
}

##Internal Procedure Header
# Name:
#    ::ixia::isValidIPv4AddressAndPrefix
#
# Description:
#
# Synopsis:
#
# Arguments:
#
# Return Values:
#
# Examples:
#   ::ixia::isValidIPv4AddressAndPrefix 1.1.1.1/24 reuturns 1
#   ::ixia::isValidIPv4AddressAndPrefix 1.1.1.1/55 reuturns 0
#   ::ixia::isValidIPv4AddressAndPrefix 1.555.1.1/55 reuturns 0
#
proc ::ixia::isValidIPv4AddressAndPrefix { ipv4AddressAndPrefix } {
    if {[regexp -all {^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/\d{1,2}$} $ipv4AddressAndPrefix]} {
        foreach {tmpItemIP tmpItemPrefix} [split $ipv4AddressAndPrefix /] {}
        if {![isValidIPv4Address $tmpItemIP]} {
            return 0
        }
        if {$tmpItemPrefix > 32} {
            return 0
        }
    } else {
        return 0
    }
    
    return 1
}

proc ::ixia::isValidIPv6AddressAndPrefix { ipv6AddressAndPrefix } {
    if {[llength [split $ipv6AddressAndPrefix /]] != 2} {
        return 0
    } else {
        foreach {tmpItemIP tmpItemPrefix} [split $ipv6AddressAndPrefix /] {}
        if {![::ipv6::validateAddress $tmpItemIP]} {
            return 0
        }
        
        if {![string is integer $tmpItemPrefix] || $tmpItemPrefix > 128 || $tmpItemPrefix < 0} {
            return 0
        }
    }
        
    return 1
}

##Internal Procedure Header
# Name:
#    ::ixia::increment_ipv6_address_hltapi
#
# Description:
#    Increments the IPv6 prefix following the step given by the
#    following format (example):
#
#    IPv6 = 0000:0000:0000:0000:0000:0000:0000:0000
#    Step = 10:1::1
#    Next prefix = 0010:0001:0000:0000:0000:0000:0000:0001
#
# Synopsis:
#
# Arguments:
#    prefix
#        Ipv6 address (any acceptable IPv6 format)
#    route_ip_addr_step
#        IPv6 step
#
# Return Values:
#
# Examples:
#
proc ::ixia::increment_ipv6_address_hltapi {prefix route_ip_addr_step} {

    set temp_vpn_route_ip_addr_step [string map {" " ""} \
            [split [::ipv6::expandAddress $route_ip_addr_step] :]]

    set ipv6_addr_length 32

    set ipv6_step_list ""
    for {set k 0} {$k < $ipv6_addr_length} {incr k} {
        lappend ipv6_step_list [string range \
                $temp_vpn_route_ip_addr_step $k $k]
    }
    set ipv6_step_list_index [expr $ipv6_addr_length - 1]

    for {set ipv6_mask 128} { $ipv6_mask >= 4} {incr ipv6_mask -4} {
        set prefix [::ixia::increment_ipv6_address $prefix \
                $ipv6_mask 0x[lindex $ipv6_step_list \
                $ipv6_step_list_index]]
        incr ipv6_step_list_index -1
    }

    return [::ipv6::expandAddress $prefix]
}


##Internal Procedure Header
# Name:
#    ::ixia::increment_ipv4_address_hltapi
#
# Description:
#    Increments the IPv4 prefix following the step given by the
#    following format (example):
#
#    IPv6 = 0000:0000:0000:0000:0000:0000:0000:0000
#    Step = 10:1::1
#    Next prefix = 0010:0001:0000:0000:0000:0000:0000:0001
#
# Synopsis:
#
# Arguments:
#    prefix
#        Ipv6 address (any acceptable IPv6 format)
#    route_ip_addr_step
#        IPv6 step
#
# Return Values:
#
# Examples:
#
proc ::ixia::increment_ipv4_address_hltapi {prefix intf_ip_addr_step} {

    set temp_route_ip_addr_step [split $intf_ip_addr_step .]
    set step_index 3
    set octet_number 4
    while {$octet_number >= 1} {
        set single_octet_step [lindex $temp_route_ip_addr_step\
                $step_index]
        set prefix [increment_ipv4_address \
                $prefix $octet_number \
                $single_octet_step]
        incr octet_number -1
        incr step_index -1
    }
    return $prefix
}


##Internal Procedure Header
# Name:
#    ::ixia::getStepAndMaskFromIPv6
#
# Description:
#
# Synopsis:
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
proc ::ixia::getStepAndMaskFromIPv6 { ipv6Address } {

    # Expand the address and remove the colons
    set ipv6_temp [::ipv6::expandAddress $ipv6Address]
    set ipv6_temp [string map {":" ""} $ipv6_temp]

    # An IPv6 address is 32 digits, LSB = /128 and MSB = /4
    # Evaluate all of the digits in teh list and define the network mask
    # and step value

    set mask 0
    set step 0

    set firstIndex -1
    set lastIndex -1

    for {set ctr 0} {$ctr < 32} {incr ctr} {
        if {[string range $ipv6_temp $ctr $ctr] != 0} {
            # Found the mask
            if {$firstIndex == -1} {
                set firstIndex $ctr
            }
            set lastIndex $ctr
        }
    }

    # Special case of all zeroes
    if {$firstIndex == -1} {
        set mask 128
        set step 0
    } else {
        set mask [mpexpr 4 + (4 * $lastIndex)]
        set step [mpformat %d \
                "0x[string range $ipv6_temp $firstIndex $lastIndex]"]
    }

    keylset returnList mask $mask
    keylset returnList step $step

    return $returnList
}



##Internal Procedure Header
# Name:
#    ::ixia::getNextLabel
#
# Description:
#    This command returns the next label id for ospf/isis router commands.
#    The next label id is derived by calling getFirst/getNext commands.
#
# Synopsis:
#
# Arguments:
#    routerCommand
#        can be any ixTclHal router commands that supports getFirst/getNext
#        sub commands: for example, ospfRouter, ospfV3Router, or isisRouter.
#    subCommand
#        This subCommand is appended to getFirst/getNext to retrieve the
#        desired ixTclHal object from the router command.  For example, if
#        subCommand is "Interface" and the routerCommand is "isisRouter",
#        The command to retrieve the object will be "isisRouter
#        getFirstInterface" and "isisRouter getNextInterface".
#    session_type
#        session type:  ospfv2 or ospfv3; used for OSPF protocol only.
#    port_handle
#        specifies the chassis/card/port
#
# Return Values:
#    The label id
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
proc ::ixia::getNextLabel {routerCommand subCommand session_type port_handle} {
    set label_number 0
    set label ${session_type}${subCommand}
    
    debug "$routerCommand getFirst${subCommand}"
    if {[$routerCommand getFirst${subCommand}] == $::TCL_ERROR} {
        incr label_number
        return "$port_handle$label$label_number"
    } else {
        incr label_number
        debug "$routerCommand getNext${subCommand}"
        while {[$routerCommand getNext${subCommand}] != $::TCL_ERROR} {
            incr label_number
            debug "$routerCommand getNext${subCommand}"
        }
        incr label_number
        return "$port_handle$label$label_number"
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::removeDefaultOptionVars
#
# Description:
#    Compares the two arg list:  all_optional_args and all_provided_args.
#    If an option is in all_optional_args but not in all_provided_args,
#    the option will be unset from the calling proc. This proc should be
#    called to remove any variables created by ::ixia::parse_dashed_args
#    when mode = modify.
#
# Synopsis:
#
# Arguments:
#   all_optional_args - the original optional arguments specified
#   all_provided_args - the arguments provided by the user
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
proc ::ixia::removeDefaultOptionVars {all_optional_args all_provided_args} {
    while {[set optionIndex [lsearch -glob $all_optional_args -*]] != -1} {
        set option [lindex  $all_optional_args $optionIndex]
        if {[lsearch -exact $all_provided_args $option] == -1} {
            set optionName [string trimleft $option "-"]
            if {![string is integer $optionName]} {
                upvar $optionName $optionName
                if {[info exists $optionName]} {
                    unset $optionName
                }
            }
        }
        set all_optional_args [lreplace $all_optional_args \
                $optionIndex $optionIndex]
    }
}

# This procedure returns 1 if the parameter $param_name was set by parse dashed args
# Returns 0 if parameter was set because the user passed it as parameter

proc ::ixia::is_default_param_value {param_name all_provided_args} {
    if {[lsearch $all_provided_args "-$param_name"] != -1} {
        return 0
    } else {
        return 1
    }
}

##Internal Procedure Header
# Name:
#    ::ixia::addUdfRangeList
#
# Description:
#    adds rangeList for the UDF configuration.  The input for the range list
#    is in the udf%d_counter_init_value, udf%d_counter_repeat_count, and
#    udf%d_counter_step variable from the calling scope where $d is the udf
#    number.
#
# Synopsis:
#
# Arguments:
#    udfNum - the udf number.
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:On status of failure, gives detailed information.
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
proc ::ixia::addUdfRangeList {udfNum} {

    set procName [lindex [info level [info level]] 0]

    set counter_init_value   [format udf%d_counter_init_value   $udfNum]
    set counter_repeat_count [format udf%d_counter_repeat_count $udfNum]
    set counter_step         [format udf%d_counter_step         $udfNum]
    set counter_type         [format udf%d_counter_type         $udfNum]

    upvar $counter_init_value   udf_counter_init_value
    upvar $counter_repeat_count udf_counter_repeat_count
    upvar $counter_step         udf_counter_step
    upvar $counter_type         udf_counter_type

    if {![info exists udf_counter_repeat_count] || \
            ![info exists udf_counter_step] || \
            ![info exists udf_counter_init_value]} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: udf_counter_repeat_count\
                udf_counter_init_value, and udf_counter_step options must be\
                present for range_list udf mode"
        return $returnList
    }

    set rangeCount [llength $udf_counter_init_value]
    if {([llength $udf_counter_repeat_count] != $rangeCount) || \
            ([llength $udf_counter_step] != $rangeCount)} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: the number of items in\
                $counter_init_value, $counter_repeat_count, and\
                $counter_step must be the same"
        return $returnList
    }

    for {set j 0} {$j < $rangeCount} {incr j} {
        #Add leading 0x if not there already
        set init_value [lindex $udf_counter_init_value $j]

        if {[string first 0x $init_value] == -1} {
            set init_value [format "0x%s" $init_value]
        }
        set temp_hex [format_hex $init_value $udf_counter_type]
        udf config -initval $temp_hex
        udf config -repeat [lindex $udf_counter_repeat_count $j]
        udf config -step [lindex $udf_counter_step $j]
        if {[udf addRange]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Unable to do\
                    udf addRange for stream. \n$::ixErrorInfo"
            return $returnList
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::addPortToWrite
#
# Description:
#    The procedure adds a port handles to the list of port handles
#    ::ixia::port_handles_write_config. This list of ports is used to write
#    port configuration if -no_write option is nor provided for a protocol
#    call.
#
# Synopsis:
#    ::ixia::addPortToWrite
#        port_handle - chassis/card/port
#
# Arguments:
#        port_handle
#            A list of port handles to be added to the list
#            ::ixia::port_handles_write_config.
#
# Return Values:
#    A key list
#    key:status        value:$::SUCCESS
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

proc ::ixia::addPortToWrite {port_handle_list {type "config"}} {

    variable port_handles_write_config
    variable port_handles_write_ports

    foreach {port_handle} $port_handle_list {
        regsub -all {/} $port_handle " " port_handle
        if {[llength $port_handle] == 3} {
            if {[lsearch [set port_handles_write_$type] $port_handle] \
                        == -1 } {
                lappend port_handles_write_$type $port_handle
            }
        }
    }

    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::writePortListConfig
#
# Description:
#    The procedure removes all port handles from the list of port handles
#    ::ixia::port_handles_write_config and writes the configuration for all
#    ports to hardware. This list of ports is used to write port configuration
#    if -no_write option is nor provided for a protocol call.
#
# Synopsis:
#    ::ixia::writePortListConfig
#
# Arguments:
#
# Return Values:
#    A key list
#    key:status      value:$::SUCCESS | $::FAILURE
#    key:existence   value:0 - the configuration was written to hardware
#                    value:1 - writing the configuration to hardware failed.
#    key:log         value:If status is failure, detailed information provided.
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

proc ::ixia::writePortListConfig {{protocol "yes"}} {

    variable port_handles_write_config
    variable port_handles_write_ports
    
    keylset returnList status $::SUCCESS
    
    if {[llength $port_handles_write_ports] > 0} {
        if {$protocol == "no"} {
            debug "ixWritePortsToHardware $port_handles_write_ports -noProtocolServer"
            if {[ixWritePortsToHardware port_handles_write_ports -noProtocolServer]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to write ports to hardware\
                        for port list $port_handles_write_ports"
            }
        } else  {
            debug "ixWritePortsToHardware $port_handles_write_ports"
            if {[ixWritePortsToHardware port_handles_write_ports]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to write ports to hardware\
                        for port list $port_handles_write_ports"
            }
        }

        # Remove these ports from write config,
        # otherwise we would write the config twice
        if {[llength $port_handles_write_config] > 0} {
            foreach {port_handle} $port_handles_write_ports {
                set index [lsearch $port_handles_write_config $port_handle]
                if {$index != -1} {
                    set port_handles_write_config [lreplace \
                            $port_handles_write_config $index $index]
                }
            }
        }
    }
    set port_handles_write_ports [list ]

    if {[llength $port_handles_write_config] > 0} {
        if {$protocol == "no"} {
            debug "ixWriteConfigToHardware $port_handles_write_config -noProtocolServer"
            if {[ixWriteConfigToHardware port_handles_write_config -noProtocolServer]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to write ports to hardware\
                        for port list $port_handles_write_config"
            }
        } else  {
            debug "ixWriteConfigToHardware $port_handles_write_config"
            if {[ixWriteConfigToHardware port_handles_write_config]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to write ports to hardware\
                        for port list $port_handles_write_config"
            }
        }
    }
    set port_handles_write_config [list ]

    return $returnList
}


## Internal Procedure Header
# Name:
#    ::ixia::utracker
#
# Description:
#
# Synopsis:
#    ::ixia::utracker
#        -state   CHOICES 0 1
#        -server
#
# Arguments:
#    -state
#        Specifies whether the tracker is enabled or disabled.
#    -server
#        Specifies the server to send the messages to.  When the server is
#        changed, a "server changing" message is sent to the default
#        server.
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
#    Coded versus functional specification.
#
# See Also:
#
proc ::ixia::utracker {args} {
    global   tcl_platform
    variable utrackerEnable
    variable utrackerServer
    variable utrackerDefaultServer

    set procName [lindex [info level [info level]] 0]

    set mandatory_args {
        -state   CHOICES 0 1
    }
    set optional_args {
        -server
    }
    ::ixia::parse_dashed_args -args $args -optional_args $optional_args \
            -mandatory_args $mandatory_args

    if {[info exists state]} {
        set utrackerEnable $state
    }

    if {[info exists server]} {
        if {$server != $utrackerServer} {
            set utrackerServer $server
            catch {
                ::utracker $utrackerDefaultServer Ixia $tcl_platform(user) \
                        "server changing" $server
            }
        }
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::utrackerLog
#
# Description:
#     This command sends a tracker message to the configured server for the
#     current user with the specified command and options.
#
# Synopsis:
#    ::ixia::utrackerLog command options
#
# Arguments:
#    command
#    options
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
proc ::ixia::utrackerLog {command options} {
    global   tcl_platform
    variable utrackerEnable
    variable utrackerServer

    if {$utrackerEnable} {
        set options [join $options ,]
        catch {
            ::utracker $utrackerServer Ixia $tcl_platform(user) \
                    $command $options
        }
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::utrackerLoadLibrary
#
# Description:
#     This command sends a tracker message to the configured server for the
#     current user with the specified command and options.
#
# Synopsis:
#    ::ixia::utrackerLog command options
#
# Arguments:
#    command
#    options
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
proc ::ixia::utrackerLoadLibrary {} {
    variable utrackerEnable

    switch -- $::tcl_platform(platform) {
        windows {
            set ::ixia::utrackerEnable 0
#            load [file join $::env(IXIA_HLTAPI_LIBRARY) \
#                   "library/utracker/utracker-win.dll"]
        }
        unix {
            switch -- $::tcl_platform(os) {
                Linux {
                    load [file join $::env(IXIA_HLTAPI_LIBRARY) \
                            "library/utracker/libutracker-linux.so"]
                }
                SunOS {
                    load [file join $::env(IXIA_HLTAPI_LIBRARY) \
                            "library/utracker/libutracker-sunos.so"]
                }
                default {
                    #puts "utracker library not implemented for this os. \
                    #        Will not be loaded."
                }
            }
        }
        default{
            #puts "utracker library not implemented for this os. \
            #        Will not be loaded."
        }
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::ixNetTracer2
#
# Description:
#     This command outputs the ixNet command that was run
#     This should not be called manually
#
# Synopsis:
#    ::ixia::ixNetTracer2
#
# Arguments:
#    cmdstr
#    code
#    ret
#    op
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
proc ::ixia::ixNetTracer2 {cmdstr code ret op} {
    if {[info exists ::ixia::debug_file_name]} {
        set fd [open $::ixia::debug_file_name a+]
        puts $fd $cmdstr
        close $fd
    } else {
        puts $cmdstr
    }
}

##Internal Procedure Header
# Name:
#    ::ixia::ixNetTracer2
#
# Description:
#     This command outputs the ixNet command that was run
#     with the return result
#     This should not be called manually
#
# Synopsis:
#    ::ixia::ixNetTracer2
#
# Arguments:
#    cmdstr
#    code
#    ret
#    op
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
proc ::ixia::ixNetTracer3 {cmdstr code ret op} {
    if {[info exists ::ixia::debug_file_name]} {
        set fd [open $::ixia::debug_file_name a+]
        puts $fd $cmdstr
        puts $fd "\t--> '$ret'"
        close $fd
    } else {
        puts $cmdstr
        puts "\t--> '$ret'"
    }
}

##Internal Procedure Header
# Name:
#    ::ixia::ixNetTracer2
#
# Description:
#     This command configures outputs the ixNet command that was run
#     with the return result and a stack based on ixia::debug_regex
#     This should not be called manually
#
# Synopsis:
#    ::ixia::ixNetTracer2
#
# Arguments:
#    cmdstr
#    code
#    ret
#    op
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
proc ::ixia::ixNetTracer4 {cmdstr code ret op} {
    if {[info exists ::ixia::debug_file_name]} {
        set fd [open $::ixia::debug_file_name a+]
        puts $fd $cmdstr
        puts $fd "\t--> '$ret'"
        if {![catch {regexp "$::ixia::debug_regex" [lindex $cmdstr 1 end]} retRgxp] && $retRgxp} {
            puts $fd "-------- stack trace start ----------"
            ::ixia::dump_stack_trace $fd
            puts $fd "-------- stack trace end ------------"
        }
        close $fd
    } else {
        puts $cmdstr
        puts "\t--> '$ret'"
        if {![catch {regexp $::ixia::debug_regex [lindex $cmdstr 1 end]} retRgxp] && $retRgxp} {
            puts "-------- stack trace start ----------"
            ::ixia::dump_stack_trace stdout
            puts "-------- stack trace end ------------"
        }
    }
}

##Internal Procedure Header
# Name:
#    ::ixia::trace::translateObj
#
# Description:
#     This command translates an object form to a variable defined
#     in the trace var arrays
#
# Synopsis:
#    ::ixia::trace::translateObj
#
# Arguments:
#    obj
#
# Return Values:
#    varname for the object or "" if not found
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
proc ::ixia::trace::translateObj { obj } {
    set obj_split [split $obj /]
    for {set i [llength $obj_split]} {$i >= 1} {incr i -1} {
        set obj [subst [join [lrange $obj_split 0 [expr $i-1]] /]]
        set tail [join [lrange $obj_split $i end] /]
        
        if {$tail != ""} {
            set tail /$tail
        }
        
        # named vars have priority
        if {[info exists ixia::trace::varNameArray($obj)]} {
            return $ixia::trace::varNameArray($obj)$tail
        } elseif {[info exists ixia::trace::tempVarNameArray($obj)]} {
            return $ixia::trace::tempVarNameArray($obj)$tail
        } 
    }
    return ""
}
##Internal Procedure Header
# Name:
#    ::ixia::ixNetTracer5
#
# Description:
#     This command outputs the ixNet command that was run
#     with the return result in ixia::traceLowLevelFileName substituting vars
#     This should not be called manually
#
# Synopsis:
#    ::ixia::ixNetTracer2
#
# Arguments:
#    cmdstr
#    code
#    ret
#    op
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
proc ::ixia::ixNetTracer5 {cmdstr code ret op} {
    
    if {$cmdstr == $ixia::trace::lastValidCommand && [string first "add" $cmdstr] == -1} {
        set ixia::trace::lastCommand $cmdstr
        return
    }
    set valid_command 0
    
    set wait_attrs {
        -state
        -isBusy
        -isLocked
        -stateDetail
        -isLicensesRetrieved
        -runningState
        -isReady
    }
    
    if {$::ixia::trace::fileName != ""} {
        set fd [open $::ixia::trace::fileName "a+"]
        
        if {$ixia::trace::enableOriginal} {
            puts $fd "\n#\t$cmdstr\n#\t\t$ret"
        }
        
        set subcommand [lindex $cmdstr 1]
        
        if {[string first "get" $subcommand] == 0} {
            # get sth
            set obj [subst [lindex $cmdstr 2]]
            set opts [lrange $cmdstr 3 end]
            if {[regexp {^::ixNet::OBJ-/statistics/view:.+$} $obj]} {
                set varname [trace::translateObj $obj]
                if {$varname != ""} { set obj \$$varname }
                
                if {[regexp {available(\w+)Filter} $opts {} filter_type]} {
                    puts $fd "set view_filter_array($filter_type) \[ixNet getL $obj available${filter_type}Filter\]"
                    set trace::lastViewAvailableArray($filter_type) $ret
                }
            } elseif {[regexp {^get(A|Attr|Attribute)$} $subcommand]} {
                set attr [lindex $cmdstr 3]
                if {[lsearch $wait_attrs $attr] != -1} {
                    if {$ixia::trace::lastCommand != $cmdstr} {
                        # isnt that good
                        puts $fd "after 5000"
                    }
                }
            }
        } elseif {[string first "set" $subcommand] == 0} {
            # set sth
            
            # this might be bad for objs with spaces in them
            set obj [subst [lindex $cmdstr 2]]
            set opts [lrange $cmdstr 3 end]
            
            set case 0
            
            if {
                [regexp {^\{?::ixNet::OBJ-/statistics/view:[^/]+/statistic:.+\}?$} $obj] &&
                $opts == "-enabled true"
            } {
                set case 1
            } elseif {
                [regexp {^::ixNet::OBJ-/statistics/view:.+$} $obj] &&
                [lindex $opts 0] == "-portFilterIds"
            } {
                set case 2
            }
            
            if {$case == 1} {
                if {[regexp {^ixNet get(L|List) ::ixNet::OBJ-/statistics/view:[^ ]+ statistic$} $ixia::trace::lastCommand]} {
                
                    set lobj [subst [lindex [split $ixia::trace::lastCommand " "] 2]]
                    set varname [trace::translateObj $lobj]
                    if {$varname != ""} { set lobj \$$varname }
                    
                    puts $fd "foreach obj \[ixNet getL $lobj statistic\] \{"
                    puts $fd "    ixNet setA \$obj -enabled true"
                    puts $fd "\}"
                }
            }
            
            if {$case == 2} {
                set filter_list ""
                foreach filter [lindex $opts 1] {
                    regexp {^::ixNet::OBJ-/statistics/view:[^/]+/available(\w+)Filter:.+$} $filter {} filter_type
                    append filter_list "\[lindex \$view_filter_array($filter_type) [lsearch $trace::lastViewAvailableArray($filter_type) $filter]\] "
                }
                set varname [trace::translateObj $obj]
                if {$varname != ""} { set obj \$$varname }
                puts $fd "ixNet setA $obj -portFilterIds \[list [string range $filter_list 0 end-1]\]"
            }
            
            if {$case == 0} {
                set found 0
                set varname [trace::translateObj $obj]
                if {$varname != ""} {
                    puts $fd "ixNet $subcommand \$$varname [subst $opts]"
                } else {
                    # must be a fixed path thing
                    puts $fd $cmdstr
                }
                
                set valid_command 1
            }
        } else {
            switch -exact -- $subcommand {
                "add" {
                    set varname [regsub -all {[^a-zA-Z0-9_]} $ret _]
                    set ixia::trace::tempVarNameArray($ret) $varname
                    
                    set obj [lindex $cmdstr 2]
                    set child [lindex $cmdstr 3]
                    
                    set ovarname [trace::translateObj $obj]
                    if {$ovarname != ""} { set obj \$$ovarname }
                    
                    puts $fd "set $varname \[ixNet add $obj $child\]"
                    
                    if {$obj == "::ixNet::OBJ-/statistics" && $child == "view"} {
                        puts $fd "set last_view_caption \[ixNet getA \$$varname -caption\]"
                    }
                    
                    set valid_command 1
                }
                "commit" {
                    if {$ixia::trace::connectReached} {                    
                        puts $fd $cmdstr
                        
                        foreach {o var} [array get ixia::trace::tempVarNameArray] {
                            set no [ixNet remapIds $o]
                            if {![info exists ixia::trace::varNameArray($no)]} {
                                set nvarname "[regsub -all {[^a-zA-Z0-9_]} $no _]"
                                set ixia::trace::varNameArray($no) $nvarname
                            }
                        }
                        
                        set valid_command 1
                    }
                }
                "exec" {
                    set exec_cmd [lindex $cmdstr 2]
                    set objs [lrange $cmdstr 3 end]
                    
                    if {$exec_cmd == "TakeViewCSVSnapshot"} {
                        set opts [lindex $cmdstr 4]
                        
                        puts $fd "set opts \[list \\"
                        foreach o $opts {
                            if {[lindex $o 0] == "Snapshot.View.Csv.Location:"} {
                                puts $fd "    \[subst \{[lindex $o 0] \"\$script_dir\\\\\\\\\"\}\] \\"
                            } elseif {[lindex $o 0] == "Snapshot.Settings.Name:"} {
                                puts $fd "    \[subst \{[lindex $o 0] \"\$last_view_caption\"\}\]"
                            } else {
                                puts $fd "    \{$o\} \\"
                            }
                        }
                        puts $fd "\]"
                        
                        puts $fd "ixNet exec TakeViewCSVSnapshot \[list \[list \$last_view_caption\]\] \$opts"
                    } elseif {$objs != ""} {
                        set are_objs 0
                        
                        set objs [subst $objs]
                        if {
                            [string range $objs 0 0] == "\{" && 
                            [string range $objs end end] == "\}"
                        } {
                            set objs [lindex $objs 0]
                        }
                        foreach o $objs {
                            set varname [trace::translateObj $o]
                            if {$varname != ""} {
                                set are_objs 1
                                puts $fd "ixNet exec $exec_cmd \$$varname"
                            }
                        }
                        if {!$are_objs} {
                            if {$cmdstr == "ixNet exec stop ::ixNet::OBJ-/traffic"} {
                                # special fred
                                puts $fd "after 20000"
                            }
                            puts $fd $cmdstr
                        }
                    } else {
                        puts $fd "ixNet exec $exec_cmd"
                    }
                }
                "remapIds" {
                    set objs [lrange [split $cmdstr " "] 2 end]
                    foreach o $objs {
                        set varname [trace::translateObj $o]
                        if {$varname != ""} {
                            set nvarname [regsub -all {[^a-zA-Z0-9_]} $ret _]
                            if {$nvarname != $varname} {
                                puts $fd "set $nvarname \[ixNet remapIds \$$varname\]"
                                
                                # old temp ref may still be used
                                # if {$was_temp} {
                                    # unset ixia::traceLowLevelTempVarNameArray($o)
                                # }
                                
                                set ixia::trace::varNameArray($ret) $nvarname
                            }
                        }
                    }
                    
                    set valid_command 1
                }
                "connect" {
                    set ixia::trace::connectReached 1
                    
                    # prolog
                    set cscript {[join [lrange [split [info script] \\] 0 end-1] \\]}
                    puts $fd "set script_dir $cscript"
                    puts $fd ""
                    
                    puts $fd "package req IxTclNetwork"
                        
                    puts $fd $cmdstr
                    
                    puts $fd ""
                    puts $fd ""
                }
                "exists" {
                }
                default {
                    if {$ixia::trace::connectReached} {
                        puts $fd $cmdstr
                    }
                }
            }
        }
        close $fd
    }
    
    if {$valid_command} {
        set ixia::trace::lastValidCommand $cmdstr
    }
    set ixia::trace::lastCommand $cmdstr
}

##Internal Procedure Header
# Name:
#    ::ixia::debugTrace
#
# Description:
#     This command configures the necessary traces for ixNet command
#     with respect to the ::ixia::debug variable
#     This should not be called manually
#
# Synopsis:
#    ::ixia::debugTrace
#
# Arguments:
#    varName
#    ix
#    op
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
proc ::ixia::debugTrace {varName ix op} {
    variable debug
    
    # remove all debug traces
    set trace_list {
        ::ixia::ixNetTracer2
        ::ixia::ixNetTracer3
        ::ixia::ixNetTracer4
        ::ixia::ixNetTracer5
    }
    foreach trace_cmd $trace_list {
        catch {trace remove execution ixNet leave $trace_cmd}
    }
    
    switch -exact -- $debug {
        2 {
            # Print ixNet commands    
            if {[catch {trace add execution ixNet leave ::ixia::ixNetTracer2} err]} {
                puts "Could not add trace for debug level $debug. Error: $err"
            }
        }
        3 {
            # Print ixNet commands and their return values
            if {[catch {trace add execution ixNet leave ::ixia::ixNetTracer3} err]} {
                puts "Could not add trace for debug level $debug. Error: $err"
            }
        }
        4 {
            # Print ixNet commands and their return values
            # Print stack trace for messages that match ::ixia::debug_regex
            if {[catch {trace add execution ixNet leave ::ixia::ixNetTracer4} err]} {
                puts "Could not add trace for debug level $debug. Error: $err"
            }
        }
        5 {
            # Print ixNet commands and their return values with var subst in trace file
            if {[catch {trace add execution ixNet leave ::ixia::ixNetTracer5} err]} {
                puts "Could not add trace for debug level $debug. Error: $err"
            }
        }
    }
}

##Internal Procedure Header
# Name:
#    ::ixia::debug
#
# Description:
#     This command sends a tracker message to the configured server for the
#     current user with the specified command and options.
#
# Synopsis:
#    ::ixia::debug message
#
# Arguments:
#    command
#    options
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
proc ::ixia::debug { mesg {timer_id {global_timer}} } {
    variable debug
    variable debug_file_name
    
    if {$debug > 0 && $debug != 5} {
        # Print only explicit messages with debug "message"
        set mesg [instrument_message $mesg $timer_id]
        if {[info exists debug_file_name]} {
            set fid [open $debug_file_name "a+"]
            puts $fid "$mesg\n"
            close $fid
        } else {
            puts "$mesg\n"
        }
    }
}

##Internal Procedure Header
# Name:
#    ::ixia::logHltapiCommand
#
# Description:
#     This command prints to stdout or to a file the HLT commands with their parameters.
#
# Synopsis:
#    ::ixia::logHltapiCommand procName args
#
# Arguments:
#    procName
#    args
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
proc ::ixia::logHltapiCommand { procName args } {
    set args [lindex $args 0]
    variable logHltapiCommandsFlag
    variable logHltapiCommandsFileName
    variable logHltapiCommandsFileIndex
    variable logHltapiCommandsFileDescriptor
    
    if {$logHltapiCommandsFlag == 1} {
        if {[info exists logHltapiCommandsFileName] && $logHltapiCommandsFileName != ""} {
            # Check if the file descriptor used for logging already exists
            if {![info exists logHltapiCommandsFileDescriptor] ||\
                    $logHltapiCommandsFileDescriptor == ""} {
                set logHltapiCommandsFileDescriptor [open $logHltapiCommandsFileName "a+"]
            }
            # If the log file is bigger than 10Mg, continue on another log file
            if {[file size $logHltapiCommandsFileName] >= [expr 1024 * 1024 * 10]} {
                close $logHltapiCommandsFileDescriptor
                set temp_name [join [lrange [split [file tail $logHltapiCommandsFileName] .] 0 end-1] .]
                set temp_ext [lindex [split [file tail $logHltapiCommandsFileName] .] end]
                
                incr logHltapiCommandsFileIndex
                if {[regexp {([0-9]+)$} $temp_name temp_index]} {
                    set logHltapiCommandsFileName [string trimright ${temp_name} $temp_index]$logHltapiCommandsFileIndex.$temp_ext
                }
                
                set logHltapiCommandsFileDescriptor [open $logHltapiCommandsFileName "a+"]
            }
            
            set fid $logHltapiCommandsFileDescriptor
            puts $fid "set cmd_status \[$procName $args\]\n"
            puts $fid "if \{\[keylget cmd_status status\] == \$::FAILURE\} \{"
            puts $fid "    puts \[keylget cmd_status log\]"
            puts $fid "    return"
            puts $fid "\}"
            flush $fid
            close $logHltapiCommandsFileDescriptor
			set logHltapiCommandsFileDescriptor ""
        } else {
            puts "$procName $args\n"
        }
    }
}

##Internal Procedure Header
# Name:
#    ::ixia::instrument_message
#
# Description:
#     This command is used for time profiling.
#     It adds information to the message in a csv line:
#       Time of message (%H:%M:%S)
#       Absolute number of seconds as returned by [clock seconds]
#       The time expired in seconds since the last instrumented message when timer_id is 'global_timer'
#       The time expired in seconds since the last instrumented message that had timer_id $timer_id 
#       Absolute number milliseconds as returned by [clock clicks -milliseconds]
#       The time expired in milliseconds since the last instrumented message when timer_id is 'global_timer'
#       The time expired in milliseconds since the last instrumented message that had timer_id $timer_id 
#       The text of the message ($mesg)
#       The Timer ID ('global_timer' or user timer $timer_id)
#       The Timer Type (START or END)
#
# Synopsis:
#    ::ixia::instrument_message message 'user_unique_id'
#
# Arguments:
#    mesg - text of message
#    [timer_id] - user unique timer id or if left default is global_timer
#
# Return Values:
#    csv line - if this is the first time this procedure is called is also returns the csv header
#
# Examples:
#   
# Sample Input:
#   set ::ixia::debug 1
#   set ::ixia::instrumented 1
#   set ::ixia::debug_file_name $path_to_file
#   ::ixia::debug "start of script" my_timer_script
#   ::ixia::debug "starting to configure variables"
#   # configure some variables
#   ::ixia::debug "done configuring variables"
#   ::ixia::debug "Starting a procedure call" my_timer_proc_call_00
#   # procedure call
#   ::ixia::debug "Done procedure call" my_timer_proc_call_00
#   ::ixia::debug "Done Script" my_timer_script
#
# Sample Output:
#   Time,Seconds,Expired Seconds,Milliseconds,Expired Milliseconds,Message Text, Timer ID, Timer Tag
#   15:21:04,1245759664,N/A,219148334,N/A,start of script,my_timer_script,START
#   15:21:04,1245759664,N/A,219148337,N/A,starting to configure variables,global_timer
#   15:21:13,1245759673,0,219157898,2,done configuring variables,global_timer
#   15:21:15,1245759675,N/A,219159714,N/A,Starting a procedure call,my_timer_proc_call_00,START
#   15:21:15,1245759675,0,219160137,423,one procedure call,my_timer_proc_call_00,END
#   15:21:24,1245759684,20,219169065,20728,Done Script,my_timer_script,END
#
# Notes:
#
# See Also:
#   ::ixia::debug
#
proc ::ixia::instrument_message { mesg {timer_id {global_timer}}} {
    
    variable instrumented
    
    if {[info exists instrumented] && $instrumented == 1} {
        set clk_click [clock clicks -milliseconds]
        set clk_sec   [clock seconds]
        
        if {![info exists ::ixia::previous_time]} {
            set prepend_header 1
        } else {
            set prepend_header 0
        }
        
        if {$timer_id == "global_timer"} {
        
            if {[info exists ::ixia::previous_time(global_timer)]} {
                set diff_clicks [mpexpr $clk_click - $::ixia::previous_time(global_timer,clicks)]
                set diff_sec    [mpexpr $clk_sec   - $::ixia::previous_time(global_timer,seconds)]
            } else {
                set diff_clicks "N/A"
                set diff_sec "N/A"
            }
            
            array set ::ixia::previous_time [list global_timer 1 global_timer,clicks $clk_click global_timer,seconds $clk_sec]
            append mesg ",$timer_id"
            
        } else {
            
            if {[info exists ::ixia::previous_time($timer_id)]} {
                set diff_clicks [mpexpr $clk_click - $::ixia::previous_time($timer_id,clicks)]
                set diff_sec    [mpexpr $clk_sec   - $::ixia::previous_time($timer_id,seconds)]
                
                append mesg ",$timer_id,END"
                
                unset ::ixia::previous_time($timer_id)
                unset ::ixia::previous_time($timer_id,clicks)
                unset ::ixia::previous_time($timer_id,seconds)
            } else {
                set diff_clicks "N/A"
                set diff_sec "N/A"
                
                append mesg ",$timer_id,START"
                
                set ::ixia::previous_time($timer_id)          1
                set ::ixia::previous_time($timer_id,clicks)   $clk_click
                set ::ixia::previous_time($timer_id,seconds)  $clk_sec
            }
        }
        
#         return "[clock format $clk_sec -format %H:%M:%S] - Seconds: $clk_sec - Clicks: $clk_click\
#                 - Clicks since last log: $diff_clicks - Seconds since last log: $diff_sec - $mesg"
        set mesg "[clock format $clk_sec -format %H:%M:%S],$clk_sec,$diff_sec,$clk_click,$diff_clicks,$mesg"
        
        if {$prepend_header} {
            set mesg "Time,Seconds,Expired Seconds,Milliseconds,Expired Milliseconds,Message Text, Timer ID, Timer Tag\n$mesg"
        }
        
        return $mesg

    } else {
        return $mesg
    }
}

##Internal Procedure Header
# Name:
#   ::ixia::getIpV6Type
#
# Description:
#    This command return type of the specified ipV6 address
#
# Argumengts:
#    ipv6_addr
#
# Return Values:
#    0 User Defined
#    1 Reserved
#    2 Reserved for NSAP Allocation
#    3 Reserved for IPX Allocation
#    4 Aggregatable Global Unicast Addresses
#    5 Link-Local Unicast Addresses
#    6 Site-Local Unicast Addresses
#    7 Multicast Addresses
#
# Examples:
#    getIpV6Type 2312:231::2
#    getIpV6Type FEBC:21::2
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#
# See Also:
#    RFC 2373
#
proc ::ixia::getIpV6Type { ipv6_addr } {
    set headBits [lindex [split $ipv6_addr :] 0]
    if {$headBits == ""} {
        set headBits 0
    }
    if {[expr 0x$headBits & 0xFF00] == 0} {
        debug "Reserved"
        return 1
    }
    if {[expr 0x$headBits & 0x0200] == 0x0200 && \
        [expr 0x$headBits & 0xFC00] == 0} {
        debug "Reserved for NSAP Allocation"
        return 2
    }
    if {[expr 0x$headBits & 0x0400] == 0x0400 && \
        [expr 0x$headBits & 0xFA00] == 0} {
        debug "Reserved for IPX Allocation"
        return 3
    }
    if {[expr 0x$headBits & 0x2000] == 0x2000 && \
        [expr 0x$headBits & 0xC000] == 0} {
        debug "Aggregatable Global Unicast Addresses"
        return 4
    }
    if {([expr 0x$headBits & 0xFE80] == 0xFE80) && \
           ([expr 0x$headBits & 0x0140] == 0)} {
        debug "Link-Local Unicast Addresses"
        return 5
    }
    if {([expr 0x$headBits & 0xFEC0] == 0xFEC0) && \
           ([expr 0x$headBits & 0x0100] == 0)} {
        debug "Site-Local Unicast Addresses"
        return 6
    }
    if {([expr 0x$headBits & 0xFF00] == 0xFF00)} {
        debug "Multicast address"
        return 7
    }
    return 0
}


##Internal Procedure Header
# Name:
#   ::ixia::getIpV6NetMaskFromPrefixLen
#
# Description:
#    This command takes a prefix length and returns a hex value ipv6 mask
#
# Argumengts:
#    prefixLen
#
# Return Values:
#    -1 Error; Prefix Len out of range
#    Hex value of IPv6 mask
#
# Examples:
#    set hexMask [getIpV6NetMaskFromPrefixLen 96]
#       
#
# Sample Input:
#    getIPv6NetMaskFromPrefixLen 96
# Sample Output:
#    FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:0:0
# Notes:
#
# See Also:
#    
#

proc ::ixia::getIpV6NetMaskFromPrefixLen {prefixLen} {

    if {[regexp {^[0-9]+$} $prefixLen]} {
        if {$prefixLen < 1 || $prefixLen > 128} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR: Network mask out of range"
            return $returnList
        }
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR: Invalid network mask. \
                        Numeric type required"
        return $returnList
    }

    set allOnesByte [expr $prefixLen / 16]
    set partialByte [expr $prefixLen % 16]
    set hexNetAddr ""
    set byte 0

    # Set all bytes with full ones with FFFF
    while {$allOnesByte !=0 && $byte < 8} {
        append hexNetAddr "FFFF"
        if {$byte < 7} {
            append hexNetAddr ":"
        }
        incr allOnesByte -1; incr byte
    }
    
    # If there is a byte that has only some ones AND we didn't allready write 
    # all 8 bytes
    if {$partialByte != 0 && $byte < 8} {
        set maskHexVal 0
        set shiftBy 15
        for {set count 0} {$count < $partialByte} {incr count; incr shiftBy -1} {
            set maskHexVal [expr $maskHexVal | (1 << $shiftBy)]
        }
        append hexNetAddr "[format %X $maskHexVal]"
        if {$byte < 7} {
            append hexNetAddr ":"
        }
        incr byte
    }
    for {} {$byte < 8} {incr byte} {
        if {$byte < 8} {
            append hexNetAddr "0"
            if {$byte < 7} {
                append hexNetAddr ":"
            }
        }
    
    }

    debug "hexNetAddr = $hexNetAddr"
    keylset returnList status $::SUCCESS
    keylset returnList hexNetAddr $hexNetAddr
    return $returnList
}

proc ::ixia::getIpV4NetMaskFromPrefixLen {prefixLen} {

    if {[regexp {^[0-9]+$} $prefixLen]} {
        if {$prefixLen < 0 || $prefixLen > 32} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR: Network mask out of range"
            return $returnList
        }
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR: Invalid network mask. \
                        Numeric type required"
        return $returnList
    }
    
    
    set binary_value [string repeat 1 $prefixLen]
    append binary_value [string repeat 0 [expr 32 - $prefixLen]]
    
    puts $binary_value
    regexp {([01]{8})([01]{8})([01]{8})([01]{8})} $binary_value {} a b c d
    
    set ipv4_mask [convert_bits_to_int $a].[convert_bits_to_int $b].[convert_bits_to_int $c].[convert_bits_to_int $d]
    
    keylset returnList status $::SUCCESS
    keylset returnList ipv4_mask $ipv4_mask
    return $returnList
}

##Internal Procedure Header
# Name:
#   ::ixia::mac2ip
#
# Description:
#    This command convert given mac to integer
#
# Argumengts:
#    mac address to be converted
#
# Return Values:
#   number from mac
# Examples:
#    mac2num 00:00:00:01:02:03
#
# Sample Input:
#
# Sample Output:
#
# Notes:
proc ::ixia::mac2num {mac} {
    regexp -nocase -- "(\[0-9,a-f\]{2,2}).{0,1}(\[0-9,a-f\]{2,2}).{0,1}(\[0-9,a-f\]{2,2}).{0,1}(\[0-9,a-f\]{2,2}).{0,1}(\[0-9,a-f\]{2,2}).{0,1}(\[0-9,a-f\]{2,2})" $mac all b1 b2 b3 b4 b5 b6
    return [mpexpr "0x$b1$b2$b3$b4$b5$b6"]
}

##Internal Procedure Header
# Name:
#   ::ixia::num2mac
#
# Description:
#    This command convert given number to mac
#
# Argumengts:
#    number to be converted
#
# Return Values:
#   mac from number
# Examples:
#    num2mac 14252
#
# Sample Input:
#
# Sample Output:
#
# Notes:
proc ::ixia::num2mac {num} {
    regexp -nocase -- "(\[0-9,a-f\]{2,2})(\[0-9,a-f\]{2,2})(\[0-9,a-f\]{2,2})(\[0-9,a-f\]{2,2})(\[0-9,a-f\]{2,2})(\[0-9,a-f\]{2,2})" [format "%012x" $num] all b1 b2 b3 b4 b5 b6
    return "$b1.$b2.$b3.$b4.$b5.$b6"
}

# This function should transphorm a string like: 0x12ab 12ab 12.ab 12:ab {12 ab} in
#       {12 ab}
# Example: ::ixia::hex2list 333 -> {03 33}
proc ::ixia::hex2list { hex {numBytes 0} } {
    
    set new_hex $hex
    
    if {[llength $hex] == 1} {
        set hex [split $hex '.']
        set new_hex $hex
    }
    
    if {[llength $hex] == 1} {
        set hex [split $hex ':']
        set new_hex $hex
    }
    
    if {[llength $hex] == 1} {
        regexp -nocase -- {^0x([0-9a-f]+$)} $hex {} hex
        set hex_len [string length $hex]
        if {[expr $hex_len % 2] != 0} {
            set hex "0$hex"
        }
        set new_hex {}
        for {set i 0} {$i < $hex_len} {incr i 2} {
            lappend new_hex "[string index $hex $i][string index $hex [expr $i + 1]]"
        }
    }
    if {$numBytes > 0 && [llength $new_hex] < $numBytes} {
        set lengthBytes [expr $numBytes - [llength $new_hex]]
        for {set i 0} {$i < $lengthBytes} {incr i} {
            set new_hex "00 $new_hex"
        }
    }
    return $new_hex
}

# This function should transphorm a string like: 0x12ab 12ab 12.ab {12 ab} in
#       {12 ab}
# Example: ::ixia::hex2list 333 -> {33 30}
proc ::ixia::hex2listPadRight { hex } {
    if {[llength $hex] == 1} {
        set hex [split $hex '.']
    }
    if {[llength $hex] == 1} {
        regexp -nocase -- {^0x([0-9a-f]+$)} $hex {} hex
        set hex_len [string length $hex]
        if {[expr $hex_len % 2] != 0} {
            set hex "${hex}0"
        }
        set new_hex {}
        for {set i 0} {$i < $hex_len} {incr i 2} {
            lappend new_hex "[string index $hex $i][string index $hex [expr $i + 1]]"
        }
        return $new_hex
    }
    return $hex
}

# This only knows how to increment ixNetwork format mac addresses so it makes sure of the format first.
proc ::ixia::incr_mac_addr {mac_addr mac_addr_step} {
    set mac_addr [::ixia::ixNetworkFormatMac $mac_addr]
    set mac_addr_step [::ixia::ixNetworkFormatMac $mac_addr_step]
    set addr_words [split $mac_addr :]
    set step_words [split $mac_addr_step :]
    set index 5
    set result [list]
    set carry 0
    while {$index >= 0} {
        scan [lindex $addr_words $index] "%x" addr_word
        scan [lindex $step_words $index] "%x" step_word
        set value [expr $addr_word + $step_word + $carry]
        set carry [expr $value / 0x100]
        set value [expr $value % 0x100]
        lappend result $value
        incr index -1
    }
    set new_addr [format "%02x" [lindex $result 5]]
    for {set i 4} {$i >= 0} {incr i -1} {
        append new_addr ":[format "%02x" [lindex $result $i]]"
    }
    return $new_addr
}

proc ::ixia::incr_ipv4_addr {ip_addr ip_addr_step} {
    set addr_words [split $ip_addr .]
    set step_words [split $ip_addr_step .]
    set index 3
    set result [list]
    set carry 0
    while {$index >= 0} {
        scan [lindex $addr_words $index] "%u" addr_word
        scan [lindex $step_words $index] "%u" step_word
        set value [expr $addr_word + $step_word + $carry]
        set carry [expr $value / 0x100]
        set value [expr $value % 0x100]
        lappend result $value
        incr index -1
    }
    set new_addr [format "%u" [lindex $result 3]]
    for {set i 2} {$i >= 0} {incr i -1} {
        append new_addr ".[format "%u" [lindex $result $i]]"
    }
    return $new_addr
}

proc ::ixia::incr_ipv6_addr {ip_addr ip_addr_step} {
    
    set ip_addr      [expand_ipv6_addr $ip_addr]
    set ip_addr_step [expand_ipv6_addr $ip_addr_step]
    
    set addr_words [split $ip_addr :]
    set step_words [split $ip_addr_step :]
    set index 7
    set result [list]
    set carry 0
    while {$index >= 0} {
        scan [lindex $addr_words $index] "%x" addr_word
        scan [lindex $step_words $index] "%x" step_word
        set value [expr $addr_word + $step_word + $carry]
        set carry [expr $value / 0x10000]
        set value [expr $value % 0x10000]
        lappend result $value
        incr index -1
    }
    set new_addr [format "%04x" [lindex $result 7]]
    for {set i 6} {$i >= 0} {incr i -1} {
        append new_addr ":[format "%04x" [lindex $result $i]]"
    }
    return $new_addr
}


proc ::ixia::incr_ip_addr {ip_addr ip_addr_step} {
    keylset returnList status $::SUCCESS
    
    set ip_version -1
    
    foreach ip_param {ip_addr ip_addr_step} {
        if {![isIpAddressValid [set $ip_param]]} {
            set ip_version -1
            break;
        } else {
            set ip_version 4
        }
    }
    
    if {$ip_version == -1} {
        foreach ip_param {ip_addr ip_addr_step} {
            if {![::ipv6::isValidAddress [set $ip_param]]} {
                set ip_version -1
                break;
            } else {
                set ip_version 6
            }
        }
    }
    
    switch -- $ip_version {
        4 {
            set new_addr [incr_ipv4_addr $ip_addr $ip_addr_step]
        }
        6 {
            set new_addr [incr_ipv6_addr $ip_addr $ip_addr_step]
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed on 'incr_ip_addr $ip_addr $ip_addr_step'. $ip_addr and $ip_addr_step\
                    are do not have the same IP version or are not valid IP addresses"
            return $returnList
        }
    }
    
    keylset returnList ret_val $new_addr
    
    return $returnList    
}


proc ::ixia::expand_ipv6_addr {ip_addr} {
    if {![regexp {(.*)::(.*)} $ip_addr {} before after]} {
        set ip_addr [split $ip_addr :]
        set new_addr "[format "%04x" 0x[lindex $ip_addr 0]]"
        for {set i 1} {$i < [llength $ip_addr]} {incr i} {
            append new_addr ":[format "%04x" 0x[lindex $ip_addr $i]]"
        }
    } else {
        set before [split $before :]
        set after [split $after :]
        set zeroes_length [expr 8 - [llength $before] - \
                [llength $after]]
        set new_addr ""
        if {[llength $before] > 0} {
            append new_addr "[format "%04x" 0x[lindex $before 0]]"
            for {set i 1} {$i < [llength $before]} {incr i} {
                append new_addr ":[format "%04x" 0x[lindex $before $i]]"
            }
        }
        if {$zeroes_length > 0} {
            if {[llength $before] > 0} {
                append new_addr ":0000"
            } else {
                append new_addr "0000"
            }
            for {set i 1} {$i < $zeroes_length} {incr i} {
                append new_addr ":0000"
            }
        }
        if {[llength $after] > 0} {
            for {set i 0} {$i < [llength $after]} {incr i} {
                append new_addr ":[format "%04x" 0x[lindex $after $i]]"
            }
        }
    }
    return $new_addr
}


proc ::ixia::checkInterfacesCreation {port connected_count {unconnected_count 0} }  {
    variable ixnetwork_port_handles_array
    if {$port == ""} {
        set vport [lindex [ixNet getList [ixNet getRoot] vport] 0]
        set interfaces [ixNet getList $vport interface]
    } elseif {[info exists ixnetwork_port_handles_array($port)]} {
        set vport $ixnetwork_port_handles_array($port)
        set interfaces [ixNet getList $vport interface]
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "Invalid port handle specified to\
                checkInterfacesCreation: $port."
        return $returnList
    }
    
    set connected_via          ""
    set connected_interfaces   ""
    set unconnected_interfaces ""
    foreach interface $interfaces {
        switch -- [ixNet getAttribute $interface -type] {
            default {
                lappend connected_interfaces $interface
            } 
            routed    {
                lappend unconnected_interfaces $interface
                lappend connected_via [ixNet getAttribute \
                        $interface/unconnected -connectedVia]
            }
        }
    }
    if {$connected_count != [llength $connected_interfaces]} {
        keylset returnList status $::FAILURE
        keylset returnList log "The number of connected interfaces\
                created is [llength $connected_interfaces], instead of\
                $connected_count."
        return $returnList
    }
    if {[expr $connected_count * $unconnected_count] != \
            [llength $unconnected_interfaces]} {
        keylset returnList status $::FAILURE
        keylset returnList log "The number of unconnected interfaces\
                created is [llength $unconnected_interfaces], instead of\
                $unconnected_count."
        return $returnList
    }
    if {($unconnected_count > 0) && ([llength $connected_via] != \
            [llength $unconnected_interfaces])} {
        keylset returnList status $::FAILURE
        keylset returnList log "The number of connected via interfaces\
                created is [llength $connected_via], instead of\
                [llength $unconnected_interfaces]."
        return $returnList
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::checkBgpNeighborInterfacesAssignment {neighborObjects} {
    foreach neighborObject $neighborObjects {
        if {[ixNet getAttribute $neighborObject -localIpAddress] == "0.0.0.0"} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not all BGP neighbors have a protocol\
                    interface assigned: $neighborObject."
            return $returnList
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

proc ::ixia::calcFrameGapRatio {frameSize preambleSize frameGapRatio \
    lineSpeed {mode "frameGapRatio2IFG"}} {
    keylset returnList status $::SUCCESS
    set paramList [list frameSize preambleSize frameGapRatio lineSpeed]
    foreach tmpPrm $paramList {
        set tmpVal [set $tmpPrm]
        set $tmpPrm [format %f $tmpVal]
    }
    if {$lineSpeed == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "lineSpeed is 0."
        return $returnList
    }
    if {$mode == "frameGapRatio2IFG"} {
        if {$frameGapRatio == 0} {
            keylset returnList value "infinite"
            return $returnList
        }
        # frameSize - bytes 
        # preambleSize - bytes
        # frameGapRatio - percentage
        # lineSpeed - Mbps
        # Returns IFG in milliseconds
        set tmpInterFrameGap [mpexpr (($frameSize + $preambleSize) *\
                                (100 - $frameGapRatio)) / $frameGapRatio]
        debug "set tmpInterFrameGap \[mpexpr (($frameSize + $preambleSize) *\
                                (100 - $frameGapRatio)) / $frameGapRatio\]"
        debug "tmpInterFrameGap = $tmpInterFrameGap (B)"
        set interFrameGap [::ixia::byte2millisecond $tmpInterFrameGap $lineSpeed]
        debug "interFrameGap = $interFrameGap"
        keylset returnList value $interFrameGap
        return $returnList
    } elseif {$mode == "IFG2frameGapRatio"} {
        # frameSize - bytes 
        # preambleSize - bytes
        # IFG(frameGapRatio) - milliseconds
        # lineSpeed - Mbps
        # Returns frameGapRatio in percentage
        # frameGapRatio is actually IFG in milliseconds in this case
        set tmpInterFrameGap $frameGapRatio
        set interFrameGap [::ixia::millisecond2byte $tmpInterFrameGap $lineSpeed]
        set fgr [mpexpr (($frameSize + $preambleSize) / \
                    ($frameSize + $preambleSize + $interFrameGap)) *100]
        set tmpValue [format %0.2f $fgr]
        if {$tmpValue == 0} {
            set tmpValue $fgr
        }
        keylset returnList value $tmpValue
        return $returnList
    }
}

 

 

proc ::ixia::byte2millisecond {ifg lineSpeed} {
    # Transform IFG from gapUnit bytes to gapUnit milliseconds
    set ifg [format %f $ifg]
    set lineSpeed [format %f $lineSpeed]
    set localIfg [mpexpr $ifg * 8]
    # Get line speed in 
    set localLineSpeed [mpexpr $lineSpeed * pow(10,3)]
    # IFG in millisecons
    set localIfg [mpexpr $localIfg / $localLineSpeed]
    return $localIfg

}

proc ::ixia::millisecond2byte {ifg lineSpeed} {
    # Transform IFG from gapUnit milliseconds to gapUnit bytes
    set ifg [format %f $ifg]
    set lineSpeed [format %f $lineSpeed]
    return [mpexpr (pow(10,3) / 8) * ($ifg * $lineSpeed)]

}

##Internal Procedure Header
# Name:
#    ::ixia::getIpV6AddressTypeSupported
#
# Description:
#    This command returns a list with ipv6 ip types supported by 
#    ipv6_incr_mode.
#
# Synopsis:
#    ::ixia::getIpV6AddressTypeSupported <ipv6_incr_mode>
#
# Arguments:
#    ipv6_incr_mode
#        Value returned by ::ixia::getIpV6TclHalMode
#
# Return Values:
#    A keyed list with following keys:
#       log: if an error was occurred
#       status: return $::SUCCESS if operation succeeded else $::FAILURE
#       address_types: if no error occurred return a list with interface types
#       supported by ipv6_incr_mode. IPv6 types codes can be found in 
#       ::ixia::getIpV6Type description.
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
proc ::ixia::getIpV6AddressTypeSupported {ipv6_incr_mode} {
    array set incrMode2addressType [list                               \
            $::ipV6Idle                              {0 1 2 3 4 5 6 7} \
            $::ipV6IncrHost                          {0 1 2 3}         \
            $::ipV6DecrHost                          {0 1 2 3}         \
            $::ipV6IncrNetwork                       {0 1 2 3}         \
            $::ipV6DecrNetwork                       {0 1 2 3}         \
            $::ipV6IncrInterfaceId                   {4 5 6}           \
            $::ipV6DecrInterfaceId                   {4 5 6}           \
            $::ipV6IncrGlobalUnicastTopLevelAggrId   {4}               \
            $::ipV6DecrGlobalUnicastTopLevelAggrId   {4}               \
            $::ipV6IncrGlobalUnicastNextLevelAggrId  {4}               \
            $::ipV6DecrGlobalUnicastNextLevelAggrId  {4}               \
            $::ipV6IncrGlobalUnicastSiteLevelAggrId  {4}               \
            $::ipV6DecrGlobalUnicastSiteLevelAggrId  {4}               \
            $::ipV6IncrSiteLocalUnicastSubnetId      {6}               \
            $::ipV6DecrSiteLocalUnicastSubnetId      {6}               \
            $::ipV6IncrMulticastGroupId              {7}               \
            $::ipV6DecrMulticastGroupId              {7}               \
    ]
    if {[catch {
        keylset returnList address_types $incrMode2addressType($ipv6_incr_mode)
    }]} {
        keylset returnList log "Specified increment type not supported."
        keylset returnList status $::FAILURE
    } else {
        keylset returnList status $::SUCCESS
    }
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::getIpV6MaskRangeFromIncrMode
#
# Description:
#    This command returns mask range supported by specified ipv6_incr_mode
#
# Synopsis:
#    ::ixia::getIpV6MaskRangeFromIncrMode <ipv6_incr_mode>
#
# Arguments:
#    ipv6_incr_mode
#        Value returned by ::ixia::getIpV6TclHalMode
#
# Return Values:
#    A keyed list with following keys:
#       log: if an error was occurred
#       status: return $::SUCCESS if operation succeeded else $::FAILURE
#       address_range: if no error occurred return range supported by 
#           ipv6_incr_mode
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
proc ::ixia::getIpV6MaskRangeFromIncrMode {ipv6_incr_mode} {
    array set incrType2destMaskRange [list                      \
            $::ipV6Idle                                0-128    \
            $::ipV6DecrMulticastGroupId                96-96    \
            $::ipV6IncrMulticastGroupId                96-96    \
            $::ipV6DecrGlobalUnicastTopLevelAggrId     4-4      \
            $::ipV6IncrGlobalUnicastTopLevelAggrId     4-4      \
            $::ipV6DecrGlobalUnicastNextLevelAggrId    24-24    \
            $::ipV6IncrGlobalUnicastNextLevelAggrId    24-24    \
            $::ipV6DecrGlobalUnicastSiteLevelAggrId    48-48    \
            $::ipV6IncrGlobalUnicastSiteLevelAggrId    48-48    \
            $::ipV6DecrSiteLocalUnicastSubnetId        48-48    \
            $::ipV6IncrSiteLocalUnicastSubnetId        48-48    \
            $::ipV6DecrHost                            96-128   \
            $::ipV6IncrHost                            96-128   \
            $::ipV6DecrNetwork                         0-128    \
            $::ipV6IncrNetwork                         0-128    \
            $::ipV6DecrInterfaceId                     96-128   \
            $::ipV6IncrInterfaceId                     96-128   \
    ]
    if {[catch {
        keylset returnList address_range $incrType2destMaskRange($ipv6_incr_mode)
    }]} {
        debug "getIpV6MaskRangeFromIncrMode: ipv6_incr_mode=$ipv6_incr_mode"
        keylset returnList log "Specified increment type not supported."
        keylset returnList status $::FAILURE
    } else {
        keylset returnList status $::SUCCESS
    }
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::getIpV6TclHalMode
#
# Description:
#    This command returns equivalent ipv6_mode based on HLT mode and address 
#    type.
#
# Synopsis:
#    ::ixia::getIpV6TclHalMode <hlt_mode> <address_type>
#
# Arguments:
#    hlt_mode
#        This is one of following modes: incr_host decr_host incr_network 
#        decr_network incr_intf_id decr_intf_id incr_global_top_level 
#        decr_global_top_level incr_global_next_level decr_global_next_level 
#        incr_global_site_level decr_global_site_level incr_local_site_subnet 
#        decr_local_site_subnet incr_mcast_group decr_mcast_group
#    address_type
#        It is the value returned by ::ixia::getIpV6Type
#
# Return Values:
#    A keyed list with following keys:
#       log: if an error was occurred
#       status: return $::SUCCESS if operation succeeded else $::FAILURE
#       ipv6_mode: if no error occurred return ipv6 mode to be set on IxTclHal
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
proc ::ixia::getIpV6TclHalMode {hlt_mode {address_type 0}} {
    if {$hlt_mode == "increment" || $hlt_mode == "decrement"} {
        # Retrieve a specific ipv6 mode
        set prefix [string range $hlt_mode 0 3]
        array set hlt2specific [list                \
                0       ${prefix}_network           \
                1       ${prefix}_network           \
                2       ${prefix}_network           \
                3       ${prefix}_network           \
                4       ${prefix}_intf_id           \
                5       ${prefix}_intf_id           \
                6       ${prefix}_local_site_subnet \
                7       ${prefix}_mcast_group       \
        ]
        if {[catch {
            set hlt_mode $hlt2specific($address_type)
        }]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Invalid ipv6 address type specified."
            return $returnList
        }
    }
    # convert from HLT to TCL HAL
    array set hlt2hal [list                                                    \
            fixed                   $::ipV6Idle                                \
            emulation               $::ipV6Idle                                \
            decr_mcast_group        $::ipV6DecrMulticastGroupId                \
            incr_mcast_group        $::ipV6IncrMulticastGroupId                \
            decr_global_top_level   $::ipV6DecrGlobalUnicastTopLevelAggrId     \
            incr_global_top_level   $::ipV6IncrGlobalUnicastTopLevelAggrId     \
            decr_global_next_level  $::ipV6DecrGlobalUnicastNextLevelAggrId    \
            incr_global_next_level  $::ipV6IncrGlobalUnicastNextLevelAggrId    \
            decr_global_site_level  $::ipV6DecrGlobalUnicastSiteLevelAggrId    \
            incr_global_site_level  $::ipV6IncrGlobalUnicastSiteLevelAggrId    \
            decr_local_site_subnet  $::ipV6DecrSiteLocalUnicastSubnetId        \
            incr_local_site_subnet  $::ipV6IncrSiteLocalUnicastSubnetId        \
            decr_host               $::ipV6DecrHost                            \
            incr_host               $::ipV6IncrHost                            \
            decr_network            $::ipV6DecrNetwork                         \
            incr_network            $::ipV6IncrNetwork                         \
            decr_intf_id            $::ipV6DecrInterfaceId                     \
            incr_intf_id            $::ipV6IncrInterfaceId                     \
    ]
    if {[catch {
        keylset returnList ipv6_mode $hlt2hal($hlt_mode)
    }]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Invalid IPv6 incrementing mode specified, $hlt_mode."
        return $returnList
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::getStepValueFromIpV6
#
# Description:
#    This command returns mask value to be set on IxTclHal for ipv6 
#    type.
#
# Synopsis:
#    ::ixia::getStepValueFromIpV6 <ipv6_step> <prefix_length>
#
# Arguments:
#    ipv6_step
#        The step to be converted in relative step
#    prefix_length
#        Prefix used to calculate relative step. 
#    tclhal_src_mode
#        tclhal_src_mode
#
# Return Values:
#       prefix_length 
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
proc ::ixia::getStepValueFromIpV6 {ipv6_step prefix_length tclhal_src_mode} {
#     set expanded_step [::ipv6::expandAddress $ipv6_step]
#     set step_hex_value [regsub -all ":" $expanded_step ""]
    switch -- $tclhal_src_mode {
        1 -
        2 -
        5 -
        6 {
            # 1 - ipV6IncrHost
            # 2 - ipV6DecrHost
            # 5 - ipV6IncrInterfaceId
            # 6 - ipV6DecrInterfaceId
            set step [::ixia::ipv6_host $ipv6_step $prefix_length]
            # 0::xxxx:xxxx when mask is 96
            # 0::xxxx      when mask is 112
        }
        3 -
        4 {
            # 3 - ipV6IncrNetwork
            # 4 - ipV6DecrNetwork
            set step [::ixia::ipv6_host $ipv6_step [mpexpr $prefix_length - 32]]; # mask left side
            # $prefix_length - 32 because udf counter will be on 32 bits and we use for counter
            # 32 bits to the left of $prefix_length
            set step [::ixia::num_to_ip_addr $step 6];  # convert back to IPv6 address
            set step [::ixia::ipv6_net $ipv6_step $prefix_length]; # mask right side
            # 0::xxxx:xxxx:0:0 when mask is 96
            # 0::xxxx:xxxx:0   when mask is 112
        }
        7 -
        8 {
            # 7 - ipV6DecrGlobalUnicastTopLevelAggrId
            # 8 - ipV6IncrGlobalUnicastTopLevelAggrId
            set step [::ixia::ipv6_net $ipv6_step 16]
            # xxxx::0
        }
        9 -
        10 {
            # 9 - ipV6IncrGlobalUnicastNextLevelAggrId
            # 10 - ipV6DecrGlobalUnicastNextLevelAggrId
            set step [::ixia::ipv6_host $ipv6_step 24]; # mask first 24 bits
            set step [::ixia::num_to_ip_addr $step 6];  # convert back to IPv6 address
            set step [::ixia::ipv6_net $ipv6_step 48];  # mask 48-128 bits
            # the remainder extracts the step as 0:0xx:xxxx::0
            # x is what is used to step
        }
        11 -
        12 -
        13 -
        14 {
            # 11 - ipV6IncrGlobalUnicastSiteLevelAggrId
            # 12 - ipV6DecrGlobalUnicastSiteLevelAggrId
            # 13 - ipV6IncrSiteLocalUnicastSubnetId
            # 14 - ipV6DecrSiteLocalUnicastSubnetId
            set step [::ixia::ipv6_host $ipv6_step 48]; # mask first 48 bits
            set step [::ixia::num_to_ip_addr $step 6];  # convert back to IPv6 address
            set step [::ixia::ipv6_net $ipv6_step 64];  # mask 64-128 bits
            # the remainder extracts the step as 0:0:0:xxxx::0
            # x is what is used to step
        }
        15 -
        16 {
            # 15 - ipV6IncrMulticastGroupId
            # 16 - ipV6DecrMulticastGroupId
            set step [::ixia::ipv6_host $ipv6_step 96]
            # 0::xxxx:xxxx
        }
    }

    
    keylset returnList step $step
    
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::get_random_mac {} {
    set tmp_val [expr round( rand() * 255)]
    set ret_mac [format %0.2x $tmp_val]
    
    for {set i 1} {$i < 6} {incr i} {
        set tmp_val [expr round( rand() * 255)]
        append ret_mac ":[format %0.2x $tmp_val]"
    }
    
    return $ret_mac
}

proc ::ixia::telnetCmd {chassisIp} {
    if {[catch {set s [socket $chassisIp 23]}]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to open telnet connection to chassis $chassisIp on port 23."
        return $returnList
    }
    fconfigure $s -buffering none -blocking false
    # Read welcome
    set allReadString ""
    set loopCount 10
    while {[set readString [read $s]] == "" && $loopCount} {
        append allReadString $readString
        incr loopCount -1
        after 1000
    }
    append allReadString $readString
    while {[set readString [read $s]] != ""} {
        append allReadString $readString
    }
    #puts "allReadString: $allReadString"
    # Read response for package require IxTclHal
    puts $s "package require IxTclHal"
    set allReadString ""
    set loopCount 10
    while {[set readString [read $s]] == "" && $loopCount} {
        append allReadString $readString
        incr loopCount -1
        after 1000
    }
    append allReadString $readString
    while {[set readString [read $s]] != ""} {
        append allReadString $readString
    }
    #puts "allReadString: $allReadString"
    # Read response for version get
    puts $s "version get"
    set allReadString ""
    set loopCount 10
    while {[set readString [read $s]] == "" && $loopCount} {
        append allReadString $readString
        incr loopCount -1
        after 1000
    }
    append allReadString $readString
    while {[set readString [read $s]] != ""} {
        append allReadString $readString
    }
    #puts "allReadString: $allReadString"
    # Read response for version cget
    puts $s "version cget -ixTclProtocolVersion"
    set allReadString ""
    set loopCount 10
    while {[set readString [read $s]] == "" && $loopCount} {
        append allReadString $readString
        incr loopCount -1
        after 1000
    }
    append allReadString $readString
    while {[set readString [read $s]] != ""} {
        append allReadString $readString
    }
    set version ""
    regexp {[0-9]+.[0-9]+.[0-9]+.[0-9]+} $allReadString version
    
    if {$version == ""} {
        set loopCount 10
        while {[set readString [read $s]] == "" && $loopCount} {
            append allReadString $readString
            incr loopCount -1
            after 1000
        }
        append allReadString $readString
        while {[set readString [read $s]] != ""} {
            append allReadString $readString
        }
        regexp {[0-9]+.[0-9]+.[0-9]+.[0-9]+} $allReadString version
    }
    #puts "allReadString: $allReadString"
    
    close $s
    keylset returnList status $::SUCCESS
    keylset returnList version $version
    return $returnList
}

# Returns the variable names from a parse dashed args list
proc ::ixia::getVarListFromArgs { args_list } {
    set ret_list ""
    
    foreach line [split $args_list \n] {
        if {[regexp -all {(^\s+)(\-)(\w+)} $line {} {} {} p_name]} {
            lappend ret_list $p_name
        }
    }
    
    return $ret_list
}


##Internal Procedure Header
#   Not using namespace for easy of usage
# Name:
#    ixNetShowCmd
#
# Description:
#   showCmd procedure for ixnetwork objects
# Synopsis:
#   ixNetShowCmd $ixnObject
# Arguments:
#   ixnObject = reference to ixnetwork object
# Return Values:
#
# Examples:
#   ixNetShowCmd ::ixNet::OBJ-/traffic/trafficItem:4

proc ixNetShowCmd {ixNetObj} {
    set parse_next_line 0
    
    set lines [split [ixNet h $ixNetObj] \n]
    foreach single_line $lines {

        if {$parse_next_line} {
            if {[regexp {Member execs:} $single_line] || [regexp {^\s+$} $single_line] || \
                    $single_line == ""} {
                set parse_next_line 0
                continue
            }
            
            regexp {^(\s+)-(\w+)(\s+)} $single_line {} {} paramName {}
            
            puts [format {%-40s%-s} $paramName \"[ixNet getA $ixNetObj -$paramName ]\" ]
            
        } elseif {[regexp {Attributes:} $single_line]} {
            set parse_next_line 1
            continue
        } else {
            continue
        }
    }
}


proc ::ixia::convert_string_to_ascii_hex {input_string} {
    
    set ret_val ""
    for {set idx 0} {$idx < [string length $input_string]} {incr idx} {
        scan [string index $input_string $idx] "%c" ascii_code
        append ret_val [format %x $ascii_code]
    }
    
    return $ret_val
}

proc ::ixia::convert_ascii_hex_to_string {input_hex} {
    set ret_val ""
    for {set idx 0} {$idx < [string length $input_hex]} {incr idx 2} {
        set ascii_hex [string range $input_hex $idx [expr {$idx + 1}]]
        if {"00" == $ascii_hex} {
            continue
        }
        append ret_val [format %c [expr 0x$ascii_hex]]
    }
    
    return $ret_val
}


proc ::ixia::convert_bits_to_int {bits} {
    #returns integer equivalent of a bitlist
    set bits [format %032s [join $bits {}]]
    binary scan [binary format B* $bits] I1 x
    set x
}

##Internal Procedure Header
# Name:
#    ::ixia::_format_list
#
# Description:
#
# Options:
#   -format: format' string to use for formatting e.g. -format "0%x"
#
#   -separator $sep: seperator character to use to break apart list. e.g. ","
#   empty strin means the list is a tcl list.
#
#   -list: list to reformat. e.g. -list "123,456,789"
#
#
# Notes: 
#  if any list element conversion fail, the element is left unconverted in
#  the returned list and the list conversion continues on..
#
# Returns: 
#  Re-formatted list 
#


proc ::ixia::_format_list {args} {
    array set o {-seperator ""}; array set o $args
    set rval {}
    if {[string length $o(-seperator)]} {
        set o(-list) [split $o(-list) $o(-seperator)]
    }
    foreach {elem} $o(-list) {
        set failed [catch {format $o(-format) $elem} new_elem]
        if {$failed} { lappend rval $elem } else { lappend rval $new_elem }
    }
    if {[string length $o(-seperator)]} {
        set rval [join $rval $o(-seperator)]
    }
    return $rval
}
proc ::ixia::_validate_vlan_tpid {item} {
    set exp "^0x\[0-9a-fA-F\]+(,0x\[0-9a-fA-F\]+){0,6}$"
    set new_item [::ixia::_format_list \
        -list $item -seperator "," -format "0x%x"]
    if {[regexp -- $exp $new_item]==0} {
        set pre ""
        if {[string compare $item $new_item]} {
            set pre "( converted to $new_item ): "
        }
        return [list 0 "${pre}Should be a value conforming to the regular expression: $exp"]
    }
    return 1
}

proc ::ixia::formatRsvpTlv {item} {
    set item [string trim $item :]
    set item [split $item :]
    set retList ""
    foreach item_elem $item {
        lappend retList [split $item_elem ,]
    }
    return $retList
}

proc ::ixia::validate_list_range_1_32 {item} {
    return [::ixia::validate_list_range 1 32 $item]
}

proc ::ixia::validate_list_range_1_128 {item} {
    return [::ixia::validate_list_range 1 128 $item]
}

proc ::ixia::validate_list_range {low high item} {
    foreach item_elem $item {
        if {$item_elem != "" && ($item_elem < $low || $item_elem > $high)} {
            return [list 0 "Should be a value between $low and $high."]
        }
    }
    return 1
}

proc ::ixia::validate_vlan_id_inner_step {vlan_id_inner_step} {
    set error_msg [list 0 "Failed on parsing the -vlan_id_inner_step option. $vlan_id_inner_step \
                should contain a single value between 0 and 4095 inclusive, or a list of values separated \
                through comma(,)."]

    if {[llength $vlan_id_inner_step] > 1} {
        return $error_msg
    }
    
    # Check that the parameter is a single value or a list of values separated through comma(,)
    if {![regexp {^([0-9])+(,[0-9]+)*$} $vlan_id_inner_step]} {
        return $error_msg
    }

    # Check that each value is between 0 and 4095
    set vlan_id_inner_step_list [split $vlan_id_inner_step ","]
    foreach inner_id $vlan_id_inner_step_list {
        if {!($inner_id >= 0 && $inner_id <= 4095)} {
            return $error_msg
        }
    }
    
    return 1
}

# Procedure used to validate the -egress_custom_offset used in traffic_config
proc ::ixia::validate_egress_custom_offset {item_list} {
    set error 0

    foreach item $item_list { # check each element in the item_list
        if {[string is integer $item]} {;# must be positive integer
            if {$item < 0} {
                set error 1
            }
        } elseif {$item != "NA"} {;# or NA
            set error 1
        }
    }
    
    # if at least one element is different from numeric or NA, return an error
    if {$error} {
        return [list 0 "-egress_custom_offset must be a list of positive integers values or NA, if not defined"]
    }
    
    return 1
}

# Procedure used to validate the -egress_custom_width used in traffic_config
proc ::ixia::validate_egress_custom_width {item_list} {
    set error 0

    foreach item $item_list { # check each element in the item_list
        if {[string is integer $item]} {;# must be positive integer
            if {$item < 0} {
                set error 1
            }
        } elseif {$item != "NA"} {;# or NA
            set error 1
        }
    }
    
    # if at least one element is different from numeric or NA, return an error
    if {$error} {
        return [list 0 "-egress_custom_width must be a list of positive integers values or NA, if not defined"]
    }
    
    return 1
}

proc ::ixia::validate_flag_choice_0_1 {arg} {
    if {$arg == ""} {
        return 1
    } else {
        foreach item_elem $arg {
            if {$item_elem == 0 || $item_elem == 1} {
                return 1
            } else {
                return [list 0 "Should be a list of intergers."]
            }
        }
    }
    return 1
}

proc ::ixia::validate_eui64_or_ipv6 {eui64} {
    set msg {Should be a valid EUI64 value.}
    set eui64_regexp {^([A-Fa-f0-9]{1,4}[ .:]){7,7}([A-Fa-f0-9]{1,4})$}
    if {[regexp $eui64_regexp $eui64]} {
        return 1
    } elseif {([regexp -all :: $eui64] == 1) && [regexp {^[:A-Fa-f0-9]+$} $eui64]} {
        # only exter here if "::" sequence if found once (==1 is to avoid mutliple
        # mathches). Also all characters should be EUI64 compliant.
        set eui64_map [split [string map {:: |} $eui64] |]
        #divide the EUI64 into 2 parts separated by the :: which we will fill with 0
        set first_part [split [lindex $eui64_map 0] :]
        set last_part [split [lindex $eui64_map 1] :]
        if { ([expr [llength $first_part] + [llength $last_part]] < 8) } {
            set zeros [string trimright [string repeat "0 " \
                    [expr 8 - ([llength $first_part] + [llength $last_part])]]]
            set resulted_eui64 [join "$first_part $zeros $last_part" :]
            if {[regexp $eui64_regexp $resulted_eui64]} {
                return 1
            }
        }
    }
    return [list 0 $msg]
}

proc ::ixia::validate_bgp_communities {arg} {
    foreach item_elem $arg {
        if {![string is double $item_elem]} {
            return [list 0 "Should be a list of intergers."]
        }
    }
    return 1
}

proc ::ixia::dump_stack_trace {fd} {
    set current_level [expr [info level] - 1]
    
    for {set lvl $current_level} {$lvl > 0} {incr lvl -1} {
        puts $fd "$lvl \t[info level $lvl]"
    }
}


proc ::ixia::get_valid_chassis_id {{ch_id "0"}} {
    variable ixnetworkVersion
    variable chassisIdIndex
    
    switch -- $chassisIdIndex {
        0 {
            # do nothing
        }
        1 {
            incr ch_id
        }
        default {
            # This is for the "auto" value; which is the default...
            if {[regexp {(P2NO)|(NO)|(P)} $ixnetworkVersion]} {
                incr ch_id
            }
        }
    }
    
    return $ch_id
}


proc ::ixia::get_valid_chassis_id_ixload {{ch_id "0"}} {
    variable ixnetworkVersion
    variable chassisIdIndex
    
    switch -- $chassisIdIndex {
        0 {
            incr ch_id
        }
        1 {
            # do nothing
        }
        default {
            # This is for the "auto" value; which is the default...
            if {![regexp {(P2NO)|(NO)|(P)} $ixnetworkVersion]} {
                incr ch_id
            }
        }
    }
    
    return $ch_id
}

# The math_* functions were created for usage with stats values. If a statistic is not a numeric value 
# it must be treated as such over and over again.
# These functions will do the functions without taking into consideration non numeric strings


proc ::ixia::get_value_type {value} {
    set value_type "unknown"
    if {[regexp {^[0-9]+$} $value]} {
        set value_type "numeric"
    } elseif {[regexp {^0x} $value] || ([regexp {[a-fA-F]} $value] && [regexp {^[0-9a-fA-F]+$} $value])} {
        set value_type "hex"
    } elseif {[string is double $value]} {
        set value_type "double"
    }
    
    return $value_type
}


proc ::ixia::math_max {x y} {
    
    set x_type [get_value_type $x]
    if {$x_type == "hex"} {
        set x 0x[convert_string_to_hex $x]
    }
    
    set y_type [get_value_type $y]
    if {$y_type == "hex"} {
        set y 0x[convert_string_to_hex $y]
    }
    
    if {$x_type != "unknown"} {
        if {$y_type != "unknown"} {
            if {$x > $y} {
                set ret_max $x
            } else {
                set ret_max $y
            }
        } else {
            set ret_max $x
        }
    } else {
        if {$y_type != "unknown"} {
            set ret_max $y
        } else {
            set ret_max $x
        }
    }
    
    return $ret_max
}

proc ::ixia::math_min {x y} {
    
    set x_type [get_value_type $x]
    if {$x_type == "hex"} {
        set x 0x[convert_string_to_hex $x]
    }
    
    set y_type [get_value_type $y]
    if {$y_type == "hex"} {
        set y 0x[convert_string_to_hex $y]
    }
    
    if {$x_type != "unknown"} {
        if {$y_type != "unknown"} {
            if {$x < $y} {
                set ret_min $x
            } else {
                set ret_min $y
            }
        } else {
            set ret_min $x
        }
    } else {
        if {$y_type != "unknown"} {
            set ret_min $y
        } else {
            set ret_min $x
        }
    }
    
    return $ret_min
}

proc ::ixia::math_incr {x {step {1}}} {
    set x_type [get_value_type $x]
    if {$x_type == "hex"} {
        set x 0x[convert_string_to_hex $x]
    }
    
    set step_type [get_value_type $step]
    if {$step_type == "hex"} {
        set step 0x[convert_string_to_hex $step]
    }
    
    if {$x_type != "unknown"} {
        if {$step_type != "unknown"} {
            set ret_val [mpexpr $x + $step]
        } else {
            set ret_val $x
        }
    } else {
        if {$step_type != "unknown"} {
            set ret_val $step
        } else {
            set ret_val $x
        }
    }
}


proc ::ixia::isSetupVportCompatible {args} {
    variable no_more_tclhal
    variable new_ixnetwork_api
    
    # expecting the list "mode vport_list vport_count" in args
    foreach var $args {
        upvar $var ${var}
    }
    
    set compatible 1
    if {([info exists mode] && $mode == "disconnect") ||\
            [info exists vport_list] || [info exists vport_count]} {
        
        if {!$new_ixnetwork_api} {
            set compatible 0
        } else {
            if {!$no_more_tclhal} {
                set compatible 0
            }
        }
    }
    
    return $compatible
}


proc ::ixia::async_operations_array_add {object exec operation_handle {other_info {_placeholder}}} {
    variable ::ixia::ixnetwork_async_operations_array
    
    # ixnetwork_async_operations_array($ixn_obj)        {abort start stop}
    # ixnetwork_async_operations_array($ixn_obj,abort)  {$op_handle _placeholder_for_future_needs}
    # ixnetwork_async_operations_array($ixn_obj,start)  {$op_handle _placeholder_for_future_needs}
    # ixnetwork_async_operations_array($ixn_obj,stop)   {$op_handle _placeholder_for_future_needs}
    
    if {[info exists ixnetwork_async_operations_array($object,$exec)] &&\
            [lindex $ixnetwork_async_operations_array($object,$exec) 0] == $operation_handle &&\
            [lindex $ixnetwork_async_operations_array($object,$exec) 1] == $other_info} {
        
        # don't add the same op twice
        return 1
    }
    
    ::ixia::async_operations_array_update
    
    set current_actions_on_object ""
    if {[info exists ixnetwork_async_operations_array($object)]} {
        if {[lsearch $ixnetwork_async_operations_array($object) $exec] == -1} {
            lappend ixnetwork_async_operations_array($object) $exec
        }
    } else {
        set ixnetwork_async_operations_array($object) $exec
    }
    
    set ixnetwork_async_operations_array($object,$exec) [list $operation_handle $other_info]
    
    return 1
}

proc ::ixia::async_operations_array_remove {object exec} {
    variable ::ixia::ixnetwork_async_operations_array
    
    if {![info exists ixnetwork_async_operations_array($object)]} {
        return 1
    }
    
    set all_operations $ixnetwork_async_operations_array($object)
    
    if {$exec == "_all"} {
        set exec $all_operations
    }
    
    
    foreach exec_item $exec {
        
        # remove element from array
        catch {unset ixnetwork_async_operations_array($object,$exec_item)}
        
        # pop the operation from the operations currently running on the object
        set exec_item_idx [lsearch $all_operations $exec_item]
        if {$exec_item_idx != -1} {
            set all_operations [lreplace $all_operations $exec_item_idx $exec_item_idx]
        }
    }
    
    if {[llength $all_operations] == 0} {
        unset ixnetwork_async_operations_array($object)
    } else {
        set ixnetwork_async_operations_array($object) $all_operations
    }
    
    return 1
}

proc ::ixia::async_operations_array_update {} {
    variable ::ixia::ixnetwork_async_operations_array
    
    foreach array_entry [array names ixnetwork_async_operations_array] {
        if {[llength [split $array_entry ,]] > 1} {
            continue
        }
        
        set ixn_object $array_entry
        
        set new_pending_op_list ""
        foreach pending_operation $ixnetwork_async_operations_array($array_entry) {
            if {![info exists ixnetwork_async_operations_array($array_entry,$pending_operation)]} {
                continue
            }
            
            set operation_handle [lindex $ixnetwork_async_operations_array($array_entry,$pending_operation) 0]
            
            if {![ixNet isDone $operation_handle]} {
                lappend new_pending_op_list $pending_operation
            } else {
                ::ixia::async_operations_array_remove $array_entry $pending_operation
            }
        }
        
        if {[llength $new_pending_op_list] == 0} {
            ::ixia::async_operations_array_remove $array_entry "_all"
        } else {
            set ixnetwork_async_operations_array($array_entry) [lsort -unique $new_pending_op_list]
        }
    }
}


proc ::ixia::async_operations_array_get_status {ixn_obj} {
    variable ::ixia::ixnetwork_async_operations_array
    
    # 0 - no actions pending for ixn_obj
    # 1 - actions are pending
    keylset returnList operation_status 0
    keylset returnList operations_pending ""
    
    ::ixia::async_operations_array_update
    
    if {[array size ixnetwork_async_operations_array] == 0} {
        # No more operations are pending
        return $returnList
    }
    
    # Try an exact match on the handle
    if {[info exists ixnetwork_async_operations_array($ixn_obj)]} {
        keylset returnList operation_status   1
        keylset returnList operations_pending.$ixn_obj $ixnetwork_async_operations_array($ixn_obj)
        return $returnList
    }
    
    # Assuming the ixn_obj is a parent of the objects from ixnetwork_async_operations_array
    set array_names_list [array names ixnetwork_async_operations_array ${ixn_obj}*]
    if {[llength $array_names_list] > 0} {

        foreach ixn_obj_async $array_names_list {
            if {[llength [split $ixn_obj_async ,]] > 1} {
                # it's an object,operation index. I'm looking for object only index
                # they contain lists of operations pending for that object
                continue
            }
            
            keylset returnList operations_pending.$ixn_obj_async $ixnetwork_async_operations_array($ixn_obj_async)
        }
        
        keylset returnList operation_status 1
        
        return $returnList
    }
    
    # Assuming the ixn_obj is a child of the objects from ixnetwork_async_operations_array
    foreach ixn_obj_async [array names ixnetwork_async_operations_array] {
        if {[llength [split $ixn_obj_async ,]] > 1} {
            # it's an object,operation index. I'm looking for object only index
            # they contain lists of operations pending for that object
            continue
        }
        
        if {[regexp $ixn_obj_async $ixn_obj]} {
            keylset returnList status 1
            keylset returnList operations_pending.$ixn_obj_async $ixnetwork_async_operations_array($ixn_obj_async)
        }
    }
    
    return $returnList
}


proc ::ixia::get_packet_ip_offset {ip_addr} {
    # assuming stream get was already performed
    
    set space_ip [split $ip_addr .]
    foreach {one two three four} $space_ip {}
    set ip_to_find [string tolower [format "%02x %02x %02x %02x" \
            $one $two $three $four]]
    set packet_view [string tolower [stream cget -packetView]]
    set first_index [string first $ip_to_find $packet_view]
    
    # Divide by three to account for each byte and its following space
    set first_offset [mpexpr ($first_index / 3)]

    
    # Search if we have another match of the ip in hex. Avoid matching the hex value of
    # mac (BUG571820)
    
    set search_index_start [expr $first_index + [string length $ip_to_find]]
    
    set second_index [string first $ip_to_find $packet_view $search_index_start]
    
    if {$second_index != -1 && $first_offset < 12} {
        # 12 - aproximately in the mac header area
        set offset [mpexpr ($second_index / 3)]
    } else {
        set offset $first_offset
    }
    
    return $offset
}


proc ::ixia::compare_ip_addresses {ip_addr_1 ip_addr_2} {
    ## Return values:
    # -1 if ip_addr_1 < ip_addr_2
    # 0  if ip_addr_1 == ip_addr_2
    # 1  if ip_addr_1 > ip_addr_2
    
    ## The ip version of the 2 ip addresses doesn't matter
    
    set ip_addr_numeric_1 [ip_addr_to_num $ip_addr_1]
    set ip_addr_numeric_2 [ip_addr_to_num $ip_addr_2]
    
    if {[mpexpr $ip_addr_numeric_1 < $ip_addr_numeric_2]} {
        set ret_val -1
    } elseif {[mpexpr $ip_addr_numeric_1 == $ip_addr_numeric_2]} {
        set ret_val 0
    } else {
        set ret_val 1
    }
    
    return $ret_val
}


proc ::ixia::move_flags_last {all_params flags_list} {
    
    # When FLAG type parameters are passed you might get an error like this from parse_dashed_args:
    #       <can't use non-numeric string as operand of "!">
    #
    # This procedure will move the parameters from flags_list at the end of the all_params args list
    # That seems to do the trick
    
    
    foreach flag_name $flags_list {
        if {![catch {string first $flag_name $all_params} flag_pos] && $flag_pos != -1} {
            set last_pos [string first "-" $all_params [mpexpr $flag_pos + 1]]
            if {$last_pos != -1} {
                # It's not the last parameter in the list
                
                # Grab the param and it's value
                set flag_string_seq [string range $all_params $flag_pos [mpexpr $last_pos - 1]]
                set all_params [string replace $all_params $flag_pos [mpexpr $last_pos - 1]]
                append all_params " $flag_string_seq"
            }
        }
    }
    
    return $all_params
    
}


proc ::ixia::print_keys {keylist {space ""}} {
    upvar $keylist kl
    set result ""

    foreach key [keylkeys kl] {
            set value [keylget kl $key]
            if {[catch {keylkeys value}]} {
                append result "$space$key: $value\n"
            } else {
                set newspace "$space "
                append result "$space$key:\n[::ixia::print_keys value $newspace]"
            }
    }
    return $result
}

proc ::ixia::ixCheckLinkStateTracer {cmdstr op} { 
    lappend ::ixia::ixCheckLinkStateTracerVar [lindex [lrange $cmdstr 1 end] 1]
}

##Internal Procedure Header
# Name:
#    ::ixia::compare_obj_settings_array
#
# Description: 
#    Compare the values or the two array with the same name. This is used in fc
#    test scripts
#
# Synopsis:
#    ::ixia::compare_obj_settings_array
#        addr
#
# Arguments:
#    addr
#
# Return Values:
#
# Examples:
#

proc ::ixia::compare_obj_settings_array {array_compare array_expected} {
    upvar $array_compare compare
    upvar $array_expected expected
    puts "compare value ........................."
    set result 0
    set lname [array names compare];
    foreach i $lname {
        if {![info exist expected($i)]} {
            puts "FAIL - There is no value to compare"
            incr result
        } elseif {$compare($i) != $expected($i)} {
            puts "FAIL - The $i = $compare($i) is wrong value"
            incr result
        }
        puts "PASS - The $i = $compare($i) is match expected"
    }
    return $result
}


##Internal Procedure Header
# Name:
#   ::ixia::validate_qt_input_parameters
#
# Description: 
#   Validates that the input_params array ahs the correct length according to
#   the qt_handle length (qt_no). Each element of the array coresponding to
#   a specific qt_handle need to be another array of size 2 (variable value).
#
# Synopsis:
#   ::ixia::compare_obj_settings_array
#
# Arguments:
#   input_params - The input parameters to be validated.
#   qt_no        - The number of qh_handles received.
#   
# Return Values:
#   0 - The input_params are valid and matching the expected length.
#   1 - The length on the input_params is invalid for the qt_handle size (qt_no)
#       received.
#   2 - qt_handle length (qt_no) is less than 1
#
# Examples:
#   ::ixia::validate_qt_input_parameters {{x 2} {x 4} {z 4}} 1
#   ::ixia::validate_qt_input_parameters {{{x 2} {x 4}} {{z 1}}} 2
#

proc ::ixia::validate_qt_input_parameters {input_params {qt_no 1}} {
    if { $qt_no < 1 } { return 2 }
    if { [string trim $input_params] == "" } { return 0 }
    if {$qt_no != 1} {
        if { $qt_no != [llength $input_params] } {
            return 1
        } else {
            foreach input_param_qt_index $input_params {
                foreach input_param_index $input_param_qt_index {
                    if { [llength $input_param_index] != 2 } {
                        return 1
                    }
                }
            }
            return 0
        }
    } else {
        if {[llength $input_params] == 2} {
            if { [llength [lindex $input_params 0]] == 1 } {
                return 0
            }
        }
        foreach input_param_index $input_params {
            if { [llength $input_param_index] != 2 } {
                return 1
            }
        }
        return 0
    }
}

##Internal Procedure Header
# Name:
#   ::ixia::multiply_vlan_parameter
#
# Description: 
#   Multiplies the elements in the vlan_list list in order to have the same
#   length as the precedence_list parameter. The precedence_list and the vlan_list
#   contain a list of elements, each element being a list of values separated through comma.
#   Example:
#   If we have precedence_list [list 1,2,3 4,5,6,7] and vlan_list [list 4], the procedure will
#   return a list containing the following elements:
#   - first element: 4,4,4(the last element is duplicated until it reaches the number of elements
#       in the corresponding precedence_list element)
#   - second element: 1,1,1,1(because the second element is not provided it will be replaced with 1
#       and multiplied the corresponding number of times)
#   
#
# Synopsis:
#   ::ixia::multiply_vlan_parameter
#
# Arguments:
#   precedence_list - The list of elements separated through commas that takes precedence
#   vlan_list       - The list of which elements need to be multiplied
#   
# Return Values:
#   A list of elements in which each element is represented by a list of valus separated through comma.
#
# Examples:
#   ::ixia::multiply_vlan_parameter {1,2,3 4,5} {5,3,4 2} returns {5,4,4 2,2}
#   ::ixia::multiply_vlan_parametr {4,5,6,7 8,9} {1,2} returns {1,2,2,2 1,1}
#

proc ::ixia::multiply_vlan_parameter {precedence_list vlan_list} {
    set ret_list [list]
    set delimiter ","
    
    for {set index 0} {$index < [llength $precedence_list]} {incr index} {
        set precedence_el [lindex $precedence_list $index]
        set inner_length [llength [split $precedence_el $delimiter]]
        set vlan_el [lindex $vlan_list $index]
        if {$vlan_el == ""} {
            set vlan_el 1
        }
        set vlan_el_list [split $vlan_el $delimiter]
        set last_el [lindex $vlan_el_list end]
        
        for {set i [llength $vlan_el_list]} {$i < $inner_length} {incr i} {
            append vlan_el "${delimiter}${last_el}"
        }
        lappend ret_list $vlan_el
    }
    return $ret_list
}

##Internal Procedure Header
# Name:
#   ::ixia::set_comma_separated_vlan
#
# Description:
#   Returns a list in which each element is a list of values separated through comma.
#   The procedure uses two lists 
#   Multiplies the elements in the vlan_list list in order to have the same
#   length as the precedence_list parameter. The precedence_list and the vlan_list
#   contain a list of elements, each element being a list of values separated through comma.
#   Example:
#   If we have precedence_list [list 1,2,3 4,5,6,7] and vlan_list [list 4], the procedure will
#   return a list containing the following elements:
#   - first element: 4,4,4(the last element is duplicated until it reaches the number of elements
#       in the corresponding precedence_list element)
#   - second element: 1,1,1,1(because the second element is not provided it will be replaced with 1
#       and multiplied the corresponding number of times)
#   
#
# Synopsis:
#   ::ixia::set_comma_separated_vlan
#
# Arguments:
#   outer_list - The list of elements separated through commas that takes precedence
#   inner_list - The list of which elements need to be multiplied
#   l23_config_type - Can be "protocol_interface" or "static_endpoint"
#   
# Return Values:
#   A list of elements in which each element is represented by a list of valus separated through comma.
#
# Examples:
#   ::ixia::set_comma_separated_vlan {1 4} {5,3,4 2,3} static_endpoint returns {5,3,4,1 2,3,4}
#   ::ixia::set_comma_separated_vlan {4 8 9} {1,2 3,4,5 6,7} static_endpoint returns {1,2,4 3,4,8 6,7,9}
#

proc ::ixia::set_comma_separated_vlan {outer_list inner_list l23_config_type} {
    set ret_list [list]

    for {set index 0} {$index < [llength $outer_list]} {incr index} {
        set outer_el [lindex $outer_list $index]
        set inner_el [lindex $inner_list $index]
        set delimiter ","
        if {$inner_el == ""} {
            set delimiter ""
        }
        lappend ret_list "${outer_el}${delimiter}${inner_el}"
    }
    return $ret_list
}

##Internal Procedure Header
# Name:
#   ::ixia::multiply_last_list_element
#
# Description:
#   Returns a list that has the last element duplicated until the length of the list
#   reaches count. The list is formed of values separated through the $delimiter parameter.
#   
#
# Synopsis:
#   ::ixia::multiply_last_list_element
#
# Arguments:
#   initial_list - The list that needs the last element to be duplicated
#   count - The maximum number of elements that the list needs to have
#   delimiter - The delimiter used to separate the values in the initial_list
#   
# Return Values:
#   A list of elements in which each element is represented by a list of valus separated through comma.
#
# Examples:
#   ::ixia::multiply_last_list_element [list 1 2 3 4] 10 " " returns [list 1 2 3 4 4 4 4 4 4 4]
#   ::ixia::multiply_last_list_element 1,2,3,4 10 "," returns 1,2,3,4,4,4,4,4,4,4
#

proc ::ixia::multiply_last_list_element {initial_list count {delimiter " "}} {
    set last_element [lindex [split $initial_list $delimiter] end]
    
    for {set i [llength [split $initial_list $delimiter]]} {$i < $count} {incr i} {
        append initial_list "${delimiter}${last_element}"
    }
    
    return $initial_list
}


##Internal Procedure Header
# Name:
#   ::ixia::validate_aggregation_mode
#
# Description:
#   Validates the aggregation_mode parameter with support for list inside lists.
#
# Synopsis:
#   ::ixia::validate_aggregation_mode
#
# Arguments:
#   aggregation_mode - The value if the aggregation_mode given by the user
#   
# Return Values:
#   1 if the input is valid of 0 otherwise
#

proc ::ixia::validate_aggregation_mode { aggregation_mode } {
    set validOpts [list normal mixed not_supported                          \
            single_mode_aggregation dual_mode_aggregation                   \
            hundred_gig_non_fan_out  four_by_twenty_five_gig_non_fan_out    \
            forty_gig_aggregation forty_gig_fan_out forty_gig_normal_mode   \
            ten_gig_aggregation ten_gig_fan_out three_by_ten_gig_fan_out    \
			four_by_ten_gig_fan_out eight_by_ten_gig_fan_out 				]
            
    set isValid 1
    foreach chassis_group_element $aggregation_mode {
        foreach port_group_element $chassis_group_element { 
            if {[lsearch $validOpts $port_group_element] == -1} {
                set isValid 0
            }
        }
    }
    return $isValid
}



##Internal Procedure Header
# Name:
#   ::ixia::validate_aggregation_resource_mode
#
# Description:
#   Validates the aggregation_mode parameter with support for list inside lists.
#
# Synopsis:
#   ::ixia::validate_aggregation_resource_mode
#
# Arguments:
#   aggregation_resource_mode - The value if the aggregation_resource_mode given by the user
#   
# Return Values:
#   1 if the input is valid of 0 otherwise
#


proc ::ixia::validate_aggregation_resource_mode { aggregation_resource_mode } {
    set validOpts [list normal                                              \
            not_supported single_mode_aggregation dual_mode_aggregation     \
            hundred_gig_non_fan_out four_by_twenty_five_gig_non_fan_out     \
            forty_gig_aggregation forty_gig_fan_out forty_gig_normal_mode   \
            ten_gig_aggregation ten_gig_fan_out eight_by_ten_gig_fan_out    \
			three_by_ten_gig_fan_out four_by_ten_gig_fan_out				]
    set isValid 1
    foreach chassis_group_element $aggregation_resource_mode {
        foreach port_group_element $chassis_group_element { 
            if {[lsearch $validOpts $port_group_element] == -1} {
                set isValid 0
            }
        }
    }
    return $isValid
}





##Internal Procedure Header
# Name:
#   ::ixia::compare_by_sr_get_ixnhandle
#
# Description:
#   Performs a character-by-character comparison of strings returned by 
#   ::ixia::session_resume::sr_get_ixnhandle function on the supplied 
#   arguments.
#
# Synopsis:
#   ::ixia::compare_by_sr_get_ixnhandle
#
# Arguments:
#   o1 o2 - The values to be passed to ::ixia::session_resume::sr_get_ixnhandle
#   function when performing the comparison.
#   
# Return Values:
#   Returns -1, 0, or 1, depending on lexicographically comparation.
#

proc ::ixia::compare_by_sr_get_ixnhandle {o1 o2} {
    return [string compare [::ixia::session_resume::sr_get_ixnhandle $o1]\
            [::ixia::session_resume::sr_get_ixnhandle $o2]]
}
