

proc isUNIX {} {
	if {$::tcl_platform(platform) == "windows"} {
		return 0
	}
	return 1
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

   namespace eval ipv6 {

            variable ipV6AddressSize 128
            variable ipV4AddressSize 32
            variable macAddressSize  48

            # IPv6 Addresses can be mixed with Ipv4 address as:
            # 66:66:66:66:66:66:444.444.444.444
            # In this case the first 6 segements are the hex V6 address, the 
            # lower 4 segment are decimal V4 address (traditional format). 
            # For example: fffe:0000:0a3d:0001:0dce:1234:192.168.10.1

            # Known IPv6 addresses.
            variable addressUnspecified      ::0
            variable addressLoopback         ::1
            variable addressTest             03ff:e0::00
            variable addressUnicastLinkLocal fe80::00
            variable addressUnicastSiteLocal fec0::00
            variable addressIsatap           00005efe

            #
            # Multicast addresses
            #
            variable addressMulticast         ff::00

            variable addressMulticastAllNodes [list \
                    ff:01::01 \
                    ff:02::01 ]

            variable addressMulticastAllRouters [list \
                    ff:01::02 \
                    ff:02::02 \
                    ff:05::02 ]

            # Well known multicast addresses
            variable reservedMCAddressList
            set reservedMCAddressList [list \
                    ff01:0000:0000:0000:0000:0000:0000:0001 \
                    ff01:0000:0000:0000:0000:0000:0000:0002 \
                    ff02:0000:0000:0000:0000:0000:0000:0001 \
                    ff02:0000:0000:0000:0000:0000:0000:0002 \
                    ff02:0000:0000:0000:0000:0000:0000:0003 \
                    ff02:0000:0000:0000:0000:0000:0000:0004 \
                    ff02:0000:0000:0000:0000:0000:0000:0005 \
                    ff02:0000:0000:0000:0000:0000:0000:0006 \
                    ff02:0000:0000:0000:0000:0000:0000:0007 \
                    ff02:0000:0000:0000:0000:0000:0000:0008 \
                    ff02:0000:0000:0000:0000:0000:0000:0009 \
                    ff02:0000:0000:0000:0000:0000:0000:000a \
                    ff02:0000:0000:0000:0000:0000:0000:000b \
                    ff02:0000:0000:0000:0000:0000:0000:000c \
                    ff02:0000:0000:0000:0000:0000:0000:000d \
                    ff02:0000:0000:0000:0000:0000:0000:000e \
                    ff02:0000:0000:0000:0000:0000:0001:0001 \
                    ff02:0000:0000:0000:0000:0000:0001:0002 \
                    ff05:0000:0000:0000:0000:0000:0000:0002 \
                    ff05:0000:0000:0000:0000:0000:0001:0003 \
                    ff05:0000:0000:0000:0000:0000:0001:0004 ]

            # The reservedMCAddressList also contains addresses in the following
            # range, ff02:0000:0000:0000:0000:0001:FFXX:XXXX, where X is a place
            # holder for a variable scope value,
            # ff05:0000:0000:0000:0000:0000:0001:1000 to
            # ff05:0000:0000:0000:0000:0000:0001:13FF

            variable fieldNames
            set fieldNames [list           \
                    topLevelAggregationId  \
                    nextLevelAggregationId \
                    siteLevelAggregationId \
                    subnetId               \
                    interfaceId            ]

            variable fieldListByPrefix
            array set fieldListByPrefix [list                \
                    0 interfaceId                          \
                    1 interfaceId                          \
                    2 interfaceId                          \
                    3 [list topLevelAggregationId reserved \
                    nextLevelAggregationId siteLevelAggregationId interfaceId] \
                    4 interfaceId                         \
                    5 [list subnetId interfaceId]         \
                    7 [list interfaceId                   \
                    topLevelAggregationId nextLevelAggregationId \
                    siteLevelAggregationId subnetId]]

            variable fieldNamesByPrefix
            array set fieldNamesByPrefix [list \
                    0 "Interface Id"                    \
                    1 "Interface Id"                    \
                    2 "Interface Id"                    \
                    3 [list "Interface Id"              \
                    "Top-Level Aggregation Id" "Next-Level Aggregation Id"    \
                    "Site-Level Aggregation Id"]                              \
                    5 [list "Interface Id" "Subnet Id"] \
                    4 "Interface Id"                    \
                    7 [list "Interface Id"              \
                    "Top-Level Aggregation Id" "Next-Level Aggregation Id"    \
                    "Site-Level Aggregation Id" "Subnet Id"] ]

            variable  fieldPositions
            array set fieldPositions {
                prefix                 4
                topLevelAggregationId  16
                nextLevelAggregationId 48
                siteLevelAggregationId 64
                subnetId               64
                interfaceId            128
                groupId                128
            }

            variable  fieldOffsets
            array set fieldOffsets {
                prefix                 0
                topLevelAggregationId  0
                nextLevelAggregationId 3
                siteLevelAggregationId 6
                subnetId               6
                interfaceId            8
            }

            variable  fieldMasks
            array set fieldMasks {
                prefix                  0xE0000000000000000000000000000000
                topLevelAggregationId   0x1FFF0000000000000000000000000000
                nextLevelAggregationId  0x000000FFFFFF00000000000000000000
                siteLevelAggregationId  0x000000000000FFFF0000000000000000
                subnetId                0x000000000000FFFF0000000000000000
                interfaceId             0x0000000000000000FFFFFFFFFFFFFFFF
                groupId                 0xFF00FFFFFFFFFFFFFFFFFFFFFFFFFFFF
            }
        }






#########################################################################
#
#   Conversion Utilities
#
#########################################################################

########################################################################
# Procedure: hexlist2Value
#
# Description:	This command converts a hex list into a number
#
# Argument(s):
#       hexlist		- the hex list ( example {01 02 03 04} )
#
#########################################################################
proc hexlist2Value { hexlist } {
    set retValue 0
    foreach byte $hexlist {
        set retValue [mpexpr ($retValue << 8) | 0x$byte]
    }
    return $retValue
       }

##Internal Procedure Header
#
# Name:
#    ::ipv6::host2addr
#
proc ::ipv6::host2addr {address} {
    variable ipV6AddressSize
    set bytes {}

    if {[isValidAddress $address] || [isMixedVersionAddress $address]} {

        set address [expandAddress $address]

        set length [expr $ipV6AddressSize / 8]
        regsub -all ":" $address {} address
        for {set i 0} {$i < $length} {incr i} {
        lappend bytes [string range   $address 0 1]
            set address   [string replace $address 0 1]
        }
    }

    return $bytes
       }


##Internal Procedure Header
#
# Name:
#    ::ipv6::expandAddress
#
proc ::ipv6::expandAddress {address} {
    variable ipV6AddressSize
    variable ipV4AddressSize

    set retValue    {}
    set segments    8

    if {[isValidAddress $address]} {

# Convert IPv4 address to Hex.
        if {[isMixedVersionAddress $address]} {
set end [expr [llength [split $address :]] - 1]
set ipv4Address [lindex [split $address :] $end]
            regsub "$ipv4Address" $address {} address
            regsub -all {(.*)\.(.*)\.(.*)\.(.*)} $ipv4Address \
            {[format "%02x%02x:%02x%02x" \1 \2 \3 \4]} \
            ipv4Address
            set ipv4Address [subst $ipv4Address]
            append address $ipv4Address
        }

# Check for Zero Compression operator, if found split into before
# and after.
        set segmentsBefore {}
        set segmentsAfter  $address

        regexp {(.*)::(.*)} $address result segmentsBefore segmentsAfter

# Fill in the zeroes needed to expand.
set segmentsBefore [split $segmentsBefore :]
set segmentsAfter  [split $segmentsAfter  :]
        set segmentsNeeded [expr  $segments - \
                            ([llength $segmentsBefore] + \
                             [llength $segmentsAfter])]
        set segmentList "$segmentsBefore\
        [string repeat " 0" $segmentsNeeded] $segmentsAfter"

# Build it back into a list as the expanded address in 8 segments
# of 2 bytes each.
        set expandedAddress [list]
        foreach segment $segmentList {
            lappend expandedAddress [format "%04x" 0x$segment]
        }
set retValue [join $expandedAddress :]
    }

    return $retValue
       }



##Internal Procedure Header
#
# Name:
#    ::ipv6::convertAddress
#
proc ::ipv6::convertAddress {address sourceType destType {args ""}} {
    set retValue {}

    array set conversion {
        mac,ip              ipv6::convertNoop
        mac,ipV6            ipv6::convertMacToIpV6
        ip,mac              ipv6::convertNoop
        ip,ipV6             ipv6::convertIpToIpV6
        ip,isatap           ipv6::convertIpToIsatap
        ip,ipV4Compatible   ipv6::convertIptoIpV4Compatible
        ip,6to4             ipv6::convertIpTo6to4
        isatap,ip           ipv6::convertIpV6ToIp
        ipV4Compatible,ip   ipv6::convertIpV6ToIp
        6to4,ip             ipv6::convertIpV6ToIp
        ipV6,mac            ipv6::convertIpV6ToMac
        ipV6,ip             ipv6::convertIpV6ToIp
    }

    if {[info exists conversion($sourceType,$destType)]} {
        set command $conversion($sourceType,$destType)
        if {$command != {}} {
        set retValue [eval $command $address $args]
        }
    }

    return $retValue
       }


##Internal Procedure Header
#
# Name:
#    ::ipv6::convertMacToIpV6
#
proc ::ipv6::convertMacToIpV6 {address {prefix 0}} {
    variable ipV6AddressSize
    variable macAddressSize

    set retValue {}
    if {[isMacAddressValid $address] == $::TCL_OK} {

# Convert the address and prefix to a string of bytes.
        regsub -all ":" $prefix { } prefixList
        set prefix {}
        foreach segment $prefixList {
            lappend prefix [format "%04X" 0x$segment]
        }
        regsub -all " " $prefix "" prefix
        regsub -all ":" $address {} address

# Expand if necessary.
        set prefixLength [expr [string length $prefix]/2]
        set expand [expr ($ipV6AddressSize / 8) - ($macAddressSize / 8) \
                    - $prefixLength]
        for {set i $expand} {$i} {incr i -1} {
        append prefix "00"
    }
    append prefix $address

# Build prefix-address string into IPv6 style address
    set address {}
    while {[string length $prefix] > 0} {
            append address "[string range $prefix 0 3]:"
            set prefix [string replace $prefix 0 3]
        }
        regexp {(.*):$} $address match address
                set retValue $address
            }

    return $retValue
       }


##Internal Procedure Header
#
# Name:
#    ::ipv6::convertIpToIpV6
#
       proc ::ipv6::convertIpToIpV6 {address {prefix 0} \
                                     {option addressAtTheEnd}} {
    variable ipV4AddressSize
    variable ipV6AddressSize

    set retValue {}

    if {[isIpAddressValid $address]} {

# Convert prefix to string.
        regsub -all ":" $prefix { } prefixList
        set prefix {}
        foreach segment $prefixList {
            lappend prefix [format "%04X" "0x$segment"]
        }
        regsub -all " " $prefix "" prefix

# Convert ip address to string.
        regsub -all {(.*)\.(.*)\.(.*)\.(.*)} $address \
        {[format "%02x%02x%02x%02x" \1 \2 \3 \4]} address
        set address [subst $address]

# Expand if necessary.
        set prefixLength [expr [string length $prefix]/2]
        set expand [expr ($ipV6AddressSize / 8) - \
                    ($ipV4AddressSize / 8) - $prefixLength]
        if {$option == "addressFollowPrefix"} {
        append prefix $address
### append the rest with 00...01
### because host address cannot be all 0's
        incr expand -1
        for {set i $expand} {$i} {incr i -1} {
            append prefix "00"
        }
        append prefix "01"
    } else {
        for {set i $expand} {$i} {incr i -1} {
            append prefix "00"
        }
        append prefix $address
    }

# Break it up into IPv6 address seperated by colons.
    set address {}
    while {[string length $prefix] > 0} {
            append address "[string range $prefix 0 3]:"
            set prefix [string replace $prefix 0 3]
        }
        regexp {(.*):$} $address match address
        set retValue $address
    }

    return $retValue
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::convertIpToIsatap
#
proc ::ipv6::convertIpToIsatap {address {prefix 0}} {
    variable ipV4AddressSize
    variable ipV6AddressSize
    variable addressIsatap

    set retValue {}

    if {[isIpAddressValid $address]} {

# Convert prefix to string.
        regsub -all ":" $prefix { } prefixList
        set prefix {}
        foreach segment $prefixList {
            lappend prefix [format "%04X" "0x$segment"]
        }
        regsub -all " " $prefix "" prefix

# Convert ip address to string.
        regsub -all {(.*)\.(.*)\.(.*)\.(.*)} $address \
        {[format "%02x%02x%02x%02x" \1 \2 \3 \4]} address
        set address [subst $address]
        set address [format "%08x%08x" 0x$addressIsatap 0x$address]

        set isatapSize [expr [string length $addressIsatap]/2]

# Expand if necessary.
        set prefixLength [expr [string length $prefix]/2]
        set expand [expr ($ipV6AddressSize / 8) - \
        ($ipV4AddressSize / 8) - $prefixLength - $isatapSize]
        for {set i $expand} {$i} {incr i -1} {
        append prefix "00"
    }
    append prefix $address

# Break it up into IPv6 address seperated by colons.
    set address {}
    while {[string length $prefix] > 0} {
            append address "[string range $prefix 0 3]:"
            set prefix [string replace $prefix 0 3]
        }
        regexp {(.*):$} $address match address
        set retValue $address
    }

    return $retValue
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::convertIpToIpV4Compatible
#
proc ::ipv6::convertIpToIpV4Compatible {address {prefix 0}} {
    set retValue [convertIpToIpV6 $address $prefix]
    return $retValue
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::convertIpTo6To4
#
proc ::ipv6::convertIpTo6to4 {address {prefix 2002}} {
    set retValue [convertIpToIpV6 $address $prefix addressFollowPrefix]
    return $retValue
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::convertIpV6ToMac
#
proc ::ipv6::convertIpV6ToMac {address {args ""}} {
    variable macAddressSize
    variable ipV6AddressSize

    set retValue {}

    if {[isValidAddress $address]} {
        set address [expandAddress $address]
        regsub -all ":" $address {} address

        set start [expr ($ipV6AddressSize / 4) - ($macAddressSize / 4)]
        set end   [expr ($ipV6AddressSize / 4) - 1]
        set byteString [string range $address $start $end]

        set address {}
        while {[string length $byteString] > 0} {
            append address "[string range $byteString 0 1]:"
            set byteString [string replace $byteString 0 1]
        }
        regexp {(.*):$} $address match address
        set retValue $address
    }

    return $retValue
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::convertIpV6ToIp
#
proc ::ipv6::convertIpV6ToIp {address {args ""}} {
    variable ipV4AddressSize
    variable ipV6AddressSize

    set retValue {}

    if {[isValidAddress $address]} {
        set address [expandAddress $address]
        regsub -all ":" $address {} address

        set start [expr ($ipV6AddressSize / 4) - ($ipV4AddressSize / 4)]
        set end   [expr ($ipV6AddressSize / 4) - 1]
        set byteString [string range $address $start $end]

        set address {}
        while {[string length $byteString] > 0} {
            lappend address "[string range $byteString 0 1]"
            set byteString [string replace $byteString 0 1]
        }
        regsub -all {(.*) (.*) (.*) (.*)} $address \
        {[format "%d.%d.%d.%d" 0x\1 0x\2 0x\3 0x\4]} address
        set address [subst $address]
        set retValue $address
    }

    return $retValue
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::convertNoop
#
proc ::ipv6::convertNoop {address {args ""}} {
}


#########################################################################
#
#   Field 'get' Utilities
#
#########################################################################


##Internal Procedure Header
#
# Name:
#    ::ipv6::getAddressFields
#
proc ::ipv6::getAddressFields {} {
    variable fieldNames
    return  $fieldNames
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::getFieldListByPrefix
#
proc ::ipv6::getFieldListByPrefix {address} {
    variable fieldListByPrefix

    set retValue {}

    if {![ipV6Address decode $address]} {
        set prefixType [ipV6Address cget -prefixType]
        if {[info exists fieldListByPrefix($prefixType)]} {
            set retValue $fieldListByPrefix($prefixType)
        }
    }

    return $retValue
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::getFieldNamesByPrefix
#
proc ::ipv6::getFieldNamesByPrefix {address} {
    variable fieldNamesByPrefix

    set retValue {}

    if {![ipV6Address decode $address]} {
        set prefixType [ipV6Address cget -prefixType]
        if {[info exists fieldNamesByPrefix($prefixType)]} {
            set retValue $fieldNamesByPrefix($prefixType)
        }
    }

    return $retValue
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::getFormatPrefix
#
proc ::ipv6::getFormatPrefix {address} {
    set retValue {}

    if {![ipV6Address decode $address]} {
        set retValue [list [ipV6Address cget -prefixValue]]
    }

    return $retValue
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::getTopLevelAggregationId
#
proc ::ipv6::getTopLevelAggregateId {address} {
    set retValue {}

    if {![ipV6Address decode $address]} {
        if {[ipV6Address cget -prefixType] == $::ipV6GlobalUnicast} {
            set retValue [ipV6Address cget -topLevelAggregationId]
        }
    }

    return $retValue
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::getNextLevelAggregationId
#
proc ::ipv6::getNextLevelAggregateId {address} {
    set retValue {}

    if {![ipV6Address decode $address]} {
        if {[ipV6Address cget -prefixType] == $::ipV6GlobalUnicast} {
            set retValue [ipV6Address cget -nextLevelAggregationId]
        }
    }

    return $retValue
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::getSiteLevelAggregationId
#
proc ::ipv6::getSiteLevelAggregateId {address} {
    set retValue {}

    if {![ipV6Address decode $address]} {
        if {[ipV6Address cget -prefixType] == $::ipV6GlobalUnicast} {
            set retValue [ipV6Address cget -siteLevelAggregationId]
        }
    }

    return $retValue
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::getSubnetId
#
proc ::ipv6::getSubnetId {address} {
    set retValue {}

    if {![ipV6Address decode $address]} {
        if {[ipV6Address cget -prefixType] == $::ipV6SiteLocalUnicast} {
            set retValue [ipV6Address cget -subnetId]
        }
    }

    return $retValue
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::getInterfaceId
#
proc ::ipv6::getInterfaceId {address} {
    set retValue {}

    if {![ipV6Address decode $address]} {
        switch [ipV6Address cget -prefixType] "
            $::ipV6GlobalUnicast -
            $::ipV6SiteLocalUnicast -
            $::ipV6LinkLocalUnicast {
            set retValue [list [ipV6Address cget -interfaceId]]
        }
            "
        }

    return $retValue
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::getLoopbackAddress
#
proc ::ipv6::getLoopbackAddress {} {
    variable addressLoopback
    return $addressLoopback
}


#########################################################################
#
#   Validation Utilities
#
#########################################################################


##Internal Procedure Header
#
# Name:
#    ::ipv6::isValidAddress
#
proc ::ipv6::isValidAddress {address {type unicast}} {
    variable ipV4AddressSize

    set retCode $::false

    set segments        8
    set nibbleSize      4

    set segmentsBefore  {}
    set segmentsAfter   $address
    set ipv4Address     {}

    set count [regsub -all ":" $address ":" address]
    if {$count > 0 && $count <= [expr $segments-1]} {

        if {[isMixedVersionAddress $address]} {
set end [expr [llength [split $address :]] - 1]
set ipv4Address [lindex [split $address :] $end]
            regsub "$ipv4Address" $address {} address
            regsub -all {(.*)\.(.*)\.(.*)\.(.*)} $ipv4Address \
            {[format "%02x%02x:%02x%02x" \1 \2 \3 \4]} \
            ipv4Address
            set ipv4Address [subst $ipv4Address]
            append address $ipv4Address
        }

#
# Fill in the zeroes needed to expand.
        set segmentsBefore {}
        set segmentsAfter  $address

        if {[regexp {(.*)::(.*)} $address match segmentsBefore \
            segmentsAfter]} {
set segmentsBefore [split $segmentsBefore :]
set segmentsAfter  [split $segmentsAfter  :]
            set segmentsNeeded [expr  $segments - \
            ([llength $segmentsBefore] + \
            [llength $segmentsAfter])]
            set segmentList "$segmentsBefore\
            [string repeat " 0" $segmentsNeeded] $segmentsAfter"
        } else {
set segmentList [split $address :]
        }

        if {[llength [join $segmentList]] == 8} {
            set retCode $::true
            foreach segment $segmentList {
                if {[regexp {[^0-9a-fA-f]} $segment match] > 0} {
                    set retCode $::false
                    break
                }
                if {[mpexpr 0x$segment > 0xffff]} {
                    set retCode $::false
                    break
                }
            }
        }
    }

    return $retCode
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::validAddress
#
proc ::ipv6::validateAddress {address {type unicast}} {
    set retCode $::true

    set retCode [isValidAddress $address]

    if { $retCode } {

    switch $type {
        multicast {
            set retCode [isValidMCAddress $address]
            }
            unicast -
            anycast {
            }
        default {
                set retCode $::false
            }
        }
    }

    return $retCode
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::isReservedMCAddress
#
proc ::ipv6::isReservedMCAddress {address} {
    variable reservedMCAddressList
    set retCode $::false

    set expand_address [ipv6::expandAddress $address]
    if { [llength expand_address] } {

# Check in the list for predefined multicast addresses
        if { [lsearch $reservedMCAddressList $expand_address] < 0 } {

# Check for Solicited-node addresses
            if {[string first "ff02:0000:0000:0000:0000:0001:ff" \
            $expand_address] < 0 } {

# Check for Service location addresses
                if { [string first "ff05:0000:0000:0000:0000:0000:0001" \
                $expand_address] == 0} {

                    set splittedAddr [split $expand_address ":"]
                    set comparedPart [format "0x%s" \
                    [lindex $splittedAddr 7]]
                    if {($comparedPart >= 0x1000) &&  \
                        ($comparedPart <= 0x13ff)} {
                        set retCode $::true
                    }
                }
            } else {
                set retCode $::true
            }
        } else {
            set retCode $::true
        }
    }

    return $retCode
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::isValidMCAddress
#
proc ::ipv6::isValidMCAddress {address} {
    set retCode $::false

    set expand_address [ipv6::expandAddress $address]
    if { [llength expand_address] } {

        set splittedAddr [split $expand_address ":"]
        set mcastPart [format "0x%s" [lindex $splittedAddr 0]]
        if { $mcastPart >= 0xff00 &&  $mcastPart <= 0xff1f } {
        set retCode $::true
    }
}

return $retCode
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::isMixedVersionAddress
#
proc ::ipv6::isMixedVersionAddress {address} {
set retCode $::false
set address [lindex [split $address :] end]
    if {[llength [split $address .]] == 4} {
        set retCode $::true
    }

    return $retCode
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::incrIpV6Field
#
proc ::ipv6::incrIpField {address {prefix 128} {increment 1} } {
    variable  fieldPositions

    set newAddress {}
    set errorFlag  0

    if {[info exists fieldPositions($prefix)]} {
        set prefix $fieldPositions($prefix)
    } else {
        if {[isValidInteger $prefix] } {
            if { $prefix  > 128 || $prefix  < 0 } {
            errorMsg "Error: Invalid prefix value, must be between\
            0 - 128, inclusive"
            set errorFlag 1
        }
    } else {
        set errorFlag 1
        errorMsg "Error: Invalid predefined field enumeration"
    }
}

if { !$errorFlag } {
    ipV6Address setDefault
    if  {![ipV6Address decode $address]} {

            set prefixType [ipV6Address cget -prefixType]
            set newAddress [incIpv6AddressByPrefix $address $prefix \
            $increment]

# Invalid if increment overflows into the format prefix.
            if  {![ipV6Address decode $newAddress]} {
                set newAddress [ipV6Address encode]
                if {[ipV6Address cget -prefixType] != $prefixType} {
                    set newAddress {}
                }
            }
        } else {
            errorMsg "Error: Invalid ipV6 address:$address"
        }
    }

    return $newAddress
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::convertIpv6AddrToBytes
#
proc ::ipv6::convertIpv6AddrToBytes { address } {
    set expand_address [expandAddress $address]
    regsub -all ":" $expand_address " " expand_address
    regsub -all {([0-9a-fA-F]{2})([0-9a-fA-F]{2})} $expand_address \
    {\1 \2} addrList
    return $addrList
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::incIpv6AddressByPrefix
#
proc ::ipv6::incIpv6AddressByPrefix {ipAddress {prefix 32} {inc 1}} {
    variable ipV6AddressSize

    set retAddress {}

    if {[isValidInteger $prefix] } {
        if { $prefix  > 128 || $prefix  < 0 } {
        errorMsg "Error: Invalid prefix value, must be between\
        0 - 128, inclusive"
        set errorFlag 1
    } else {
        set ipAddress [expandAddress $ipAddress]
            set host [mpexpr [hexlist2Value [convertIpv6AddrToBytes \
            $ipAddress]] & (int(pow(2,($ipV6AddressSize - \
            $prefix)) - 1))]
            set network [mpexpr [hexlist2Value [convertIpv6AddrToBytes \
            $ipAddress]] >> ($ipV6AddressSize - $prefix)]

            mpincr network $inc

            set retAddress [convertBytesToIpv6Address [value2Hexlist \
            [mpexpr ($network << ($ipV6AddressSize - $prefix)) \
            | $host] 16]]
        }
    } else {
        errorMsg "Error: Expecting integer prefix value between\
        0 - 128, inclusive."
    }
    return $retAddress
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::getFieldMask
#
proc ::ipv6::getFieldMask {{field interfaceId}} {
    variable fieldPositions

    set mask 64

    switch $field {
    interfaceId {
        set mask 64
    }
    subnetId -
    siteLevelAggregationId -
    nextLevelAggregationId -
    topLevelAggregationId {
        if {[info exists fieldPositions($field)]} {
                set mask $fieldPositions($field)
            }
        }
    }

    return $mask
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::getMinimumValidFramesize
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
proc ::ipv6::getMinimumValidFramesize {{useUdf true} {useFir true}} {
    global kFirSize kCrcSize kUdfSize kHeaderLength

    if {$useFir == "true"} {
    set firSize $kFirSize
} else {
    set firSize 0
}

if {$useUdf == "true"} {
    set udfSize $kUdfSize
} else {
    set udfSize 0
}

set minimum [expr [getHeaderLength] + $firSize + $udfSize + \
$kCrcSize]

    set minimum [expr $minimum & 0xfffffffe]
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::getHeaderLength
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
proc ::ipv6::getHeaderLength {} {
    global kHeaderLength

    set headerLength 0

    if {[protocol cget -name] == $::ipV6} {
        set headerLength   $::DaSaLength
        switch [protocol cget -ethernetType] "
            $::ethernetII -
            $::ieee8023 -
            $::ieee8022 {
            incr headerLength   2
        }
            $::ieee8023snap {
            incr headerLength   10
        }
            "
            incr headerLength [expr $::kHeaderLength(ipV6) + \
            $::udpHeaderLength]
        }

    return $headerLength
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::getAddressFieldOffset
#
proc ::ipv6::getAddressFieldOffset {field} {
    variable  fieldOffsets

    set retValue 0

    if {[info exists fieldOffsets($field)]} {
        set retValue $fieldOffsets($field)
    }

    return $retValue
}




##Internal Procedure Header
#
# Name:
#    ::ipv6::convertBytesToIpv6Address
#
proc ::ipv6::convertBytesToIpv6Address { bytes } {

    set str {}
    foreach {b1 b2} $bytes {
        lappend str "$b1$b2"
    }
    set str [join $str ":"]
    return [join $str ""]
}


##Internal Procedure Header
#
# Name:
#    ::ipv6::compressAddress
#
proc ::ipv6::compressAddress { address } {

regsub -all {(:0{1,3})+} $address ":" stripZeros
regsub {(:0)+} $stripZeros ":" dc
    if {[string index $dc end] == ":"} {
set num_colons [regsub -all {:} $dc " " dc_ignore]
        if {$num_colons < 7} {
append dc :0
    } else  {
        append dc 0
    }
}
regsub {^(0{1,3})(.*):(.*)} $dc {\2:\3} dc
    return $dc
}



if {![regexp mpformat [info commands mpformat]]} {
    proc mpformat {args} {return [eval format $args]}
}

if {![regexp mpincr [info commands mpincr]]} {
    proc mpincr {args} \
            {
                set Item [lindex $args 0]
                upvar $Item item
                set args [lrange $args 1 end]
                return [eval incr item $args]
            }
}    


set ::frameRelayRandom 1
set ::frameRelayIdle 1
set ::frameRelayContDecrement 1
set ::frameRelayDecrement 1
set ::frameRelayContIncrement 1
set ::frameRelayIncrement 1
set ::appinfo_path ""

proc isValidPositiveFloat { valueToCheck } \
{
    # Special case to handle the singular plus and period
    if {($valueToCheck == "+") || ($valueToCheck == ".")} {
        set retCode $::false
    } else {
        # The expression for a legal float is an optional + followed by either
        # (zero or more digits followed by decimal followed by one or more digits)
        # or one or more digits.
        set validPositiveFloat {^[+]?[0-9]+([\.]?[0-9]+)?$}
        if {[regexp $validPositiveFloat $valueToCheck]} {
            set retCode $::true
        } else {
            set retCode $::false
        }
    }
    return $retCode
}

################ Extra Procedures #####################
#######################################################

set ::ixErrorInfo ""
set ::TCL_OK 0
if {![regexp ixPuts [info commands ixPuts]]} {
			proc ixPuts {str} {
				puts $str
				update idletasks
			}
		}

proc redefineIxTclHalCommands {} {
	uplevel {
		if {![regexp session [info commands session]]} {
			proc session { args } { return 0 }
		}

		set ::halRedefineCommands [join [list chassis card port stream captureBuffer tableUdf ]]
		foreach c $::halRedefineCommands {
			if {![regexp $c [info commands $c]]} {
				proc $c { args } { error "ERROR - IxTclHal API is not supported when using NO(Network-Only) HLTSET" } 
			}
		}
		
	}
}



