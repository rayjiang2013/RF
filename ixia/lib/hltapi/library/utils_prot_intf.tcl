#Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    utils_prot_intf.tcl
#
# Purpose:
#    A script development library containing general utility APIs for test
#    automation with the Ixia chassis.
#
# Author:
#
# Usage:
#
# Description:
#    This library contains general purpose utilities utilized by the ixia HLTAPI
#    namespace library procedures. The procedures contained within this 
#    library include:
#
#    ::ixia::get_dut_ip
#    ::ixia::get_interface_by_description
#    ::ixia::get_interface_ip
#    ::ixia::get_interface_parameter
#    ::ixia::get_next_interface_handle
#    ::ixia::get_next_mac_address
#    ::ixia::get_number_of_intf
#    ::ixia::gre_tunnel_config
#    ::ixia::interface_exists
#    ::ixia::make_interface_description
#    ::ixia::modify_protocol_interface_info
#    ::ixia::protocol_interface_config
#    ::ixia::reset_protocol_interface_for_port
#
#    Use this library during the development of a script or
#    procedure library to verify the software in a simulation
#    environment and to perform an internal unit test on the
#    software components.
#
# Requirements:
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
#    ::ixia::modify_protocol_interface_info
#
# Description:
#    Add, delete, or modify the necessary protocol information to the storage
#    array.
#
# Synopsis:
#    ::ixia::modify_protocol_interface_info
#        -port_handle
#
# Arguments:
#
# Return Values:
#    A keyed list
#    key: status     value: $::SUCCESS or $::FAILURE
#    key: log        value: If $::FAILURE, then returns more information
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
proc ::ixia::modify_protocol_interface_info { args } {
    variable protocol_interfaces_mac_address
    variable cmdProtIntfParamsList
    variable cmdProtIntfParamsPositions
    
    set procName [lindex [info level [info level]] 0]
    #debug "$procName $args"
        
    set mandatory_args {
        -port_handle REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -description
        -mode        CHOICES add delete modify
    }

    set opt_args {
        -ip_version        CHOICES 4 6 4_6 46 0
        -type              CHOICES connected routed gre
                           DEFAULT connected
        -ipv4_address      IPV4
        -ipv4_dst_address  IP
        -ipv4_mask
        -ipv4_gateway
        -ipv6_address      IPV6
        -ipv6_mask
        -ipv6_gateway      IPV6
        -vlan_id           
        -vlan_priority     
        -mac_address
        -atm_encap
        -atm_vpi
        -atm_vci
        -dhcp_enable
        -ixnetwork_objref
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $mandatory_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Parsing error occurred in\
                ::ixia::modify_protocol_interface_info.  $parse_error"
        return $returnList
    }
    
    if {$mode == "delete"} {
        set rmv_status [::ixia::rfremove_interface_by_description $description]
        return  $rmv_status
    }

    if {[info exists ipv6_address] && [::ipv6::isValidAddress $ipv6_address]} {
        set ipv6_address [::ipv6::expandAddress $ipv6_address]
    }
    
    if {[info exists ipv6_gateway] && [::ipv6::isValidAddress $ipv6_gateway]} {
        set ipv6_gateway [::ipv6::expandAddress $ipv6_gateway]
    }
    
    if {![info exists mac_address]} {
        if {![regexp {(UN|GRE)( - \d+/\d+/\d+ - )([0-9a-fA-F][0-9a-fA-F] ){6}(- \d+)} $description {} {} {} mac_address {}]} {
            if {![regexp {(\d+/\d+/\d+ - )([0-9a-fA-F][0-9a-fA-F] ){6}(- \d+)} $description {} {} mac_address {}]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Internal error: Invalid description format '$description'"
                return $returnList
            }
        }
        
        set mac_address [string trim $mac_address]
    }
    
    
    
    if {$mode == "modify"} {
        # Get the existing data, and if no new input for it, set to the existing
        # value.
        
        set cs_intf_details_new ""
        foreach {dataInput} $cmdProtIntfParamsList {
            if {[info exists $dataInput]} {
                # Vlans use commas to define stackedVlan. Replace them with colon
                lappend cs_intf_details_new [regsub -all , [set $dataInput] :]
            } else  {
                lappend cs_intf_details_new (.*)
            }
        }
        
        set cs_intf_details_new [join $cs_intf_details_new ,]
        
        set cmd rfupdate_interface_description
        lappend cmd $description
        lappend cmd $cs_intf_details_new
        if {[info exists ip_version]} {
            lappend cmd $ip_version
        }

        set ret_code [eval $cmd]
        if {[keylget ret_code status] != $::SUCCESS} {
            keylset ret_code log "Failed to update interface description '$description'\
                    to '$cs_intf_details_new' [keylget ret_code log]"
            return $ret_code
        }
    }
    
    if {$mode == "add"} {
        
        if {![info exists ixnetwork_objref] || [llength $ixnetwork_objref] == 0} {
            set ixnetwork_objref [get_next_interface_handle]
        }
        
        set index_list ""
        foreach {dataInput} $cmdProtIntfParamsList {
            if {[info exists $dataInput]} {
                # Vlans use commas to define stackedVlan. Replace them with colon
                lappend index_list [regsub -all , [set $dataInput] :]
            } else  {
                lappend index_list (.*)
            }
        }
        
        set index_cs [join $index_list ,]
        set cmd rfadd_interface_by_details
        lappend cmd $index_cs
        
        if {[info exists ip_version]} {
            lappend cmd "$ip_version"
        }
        
        set ret_code [eval $cmd]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        if {[info exists mac_address]} {
            set int_mac 0x[join $mac_address ""]
            if {[mpexpr $protocol_interfaces_mac_address < $int_mac]} {
                set protocol_interfaces_mac_address $int_mac
            }
        }
    }
    
    keylset returnList status $::SUCCESS
    return  $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::interface_exists
#
# Description:
#    Checks if an interface is already configured in the Protocol Server
#    for a specific port
#
# Synopsis:
#    ::ixia::interface_exists
#        -port_handle      REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
#        -ip_version       CHOICES 4 6
#        -ip_address       IP
#        [-gateway_address IPV4]
#        [-mac_address     MAC]
#        [-description]
#
# Arguments:
#    -port_handle
#        The port to be checked.
#    -ip_version
#        Which ip version on the interface we are checking
#    -ip_address
#        The ip address on the interface we are going to look for, can be 
#        IPv4 or IPv6.
#    -gateway_address
#        Only for -ip_version 4.  If given, used in conjunction with 
#        the -ip_address option to find the exact interface with both values.
#    -mac_address
#        If given, then all of the interfaces on the -port will be checked 
#        to see if they contain this mac address.  A list of the interface 
#        numbers will be returned if it exists.
#    -description
#
# Return Values:
#    A keyed list
#    key: status  value: -1 : script failed without completing
#                         0 : matching interface was not found
#                         1 : matching interface was found
#                         2 : matching mac, different ip was found
#    key: log     value: When status is -1, returns more info
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
proc ::ixia::interface_exists { args } {
    variable cmdProtIntfParamsList
    variable cmdProtIntfParamsPositions
    
    set procName [lindex [info level [info level]] 0]

    debug "$procName $args"
    
    set mandatory_args {
        -port_handle     REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -ip_version      CHOICES 4 6
    }

    set opt_args {
        -ip_address      IP
        -ip_dst_address  IP
        -gateway_address IP
        -mac_address
        -type            CHOICES connected routed gre
                         DEFAULT connected
    }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $mandatory_args -optional_args $opt_args} parse_error]} {
        keylset returnList status -1
        keylset returnList log "Parsing error occurred in\
                ::ixia::interface_exists.  $parse_error"
        return $returnList
    }

    if {[info exists ip_address] && [::ipv6::isValidAddress $ip_address]} {
        set ip_address [::ipv6::expandAddress $ip_address]
    }
    
    if {[info exists gateway_address] && [::ipv6::isValidAddress $gateway_address]} {
        set gateway_address [::ipv6::expandAddress $gateway_address]
    }
    
    array set ip_version_array [list 4 6 6 4]
    set rev_ip_version $ip_version_array($ip_version)
    if {[info exists ip_address]} {
        set ipv${ip_version}_address $ip_address
    }
    if {[info exists gateway_address]} {
        set ipv${ip_version}_gateway $gateway_address
    }
    if {[info exists ip_dst_address]} {
        set ipv4_dst_address $ip_dst_address
    }

    set index_list ""
    foreach {dataInput} $cmdProtIntfParamsList {
        if {[info exists $dataInput]} {
            lappend index_list [set $dataInput]
        } else  {
            lappend index_list (.*)
        }
    }

    # Search if interface exists with parameters provided by the user
    set tempIndexList [join $index_list ,]
    set match_index_list [protocol_interfaces_operation \
            -reg $tempIndexList -ret_type value -ip_version $ip_version]
    
    if {[llength $match_index_list] == 1} {
        set match_mac_address [lindex [split $match_index_list ,] \
                $cmdProtIntfParamsPositions(mac_address)]

        set match_description [lindex [split $match_index_list ,] \
                $cmdProtIntfParamsPositions(description)]

        keylset returnList status 1
        keylset returnList mac_address $match_mac_address
        keylset returnList description $match_description
        return  $returnList
    } elseif {[llength $match_index_list] > 1} {
        set match_index_list [lindex $match_index_list 0]
        set match_mac_address [lindex [split $match_index_list ,] \
                $cmdProtIntfParamsPositions(mac_address)]

        set match_description [lindex [split $match_index_list ,] \
                $cmdProtIntfParamsPositions(description)]

        keylset returnList status 1
        keylset returnList mac_address $match_mac_address
        keylset returnList description $match_description
        return  $returnList
    }

    # If no match found, then search for an opposite ip_version interface
    # with the same mac address because we can expect for a dual IPv4 | IPv6
    # interface
    if {[info exists mac_address]} {
        if {[info exists ip_address]} {
            catch {unset ipv${ip_version}_address}
        }
        if {[info exists gateway_address]} {
            catch {unset ipv${ip_version}_gateway}
        }
        if {[info exists ip_dst_address]} {
            catch {unset ipv4_dst_address}
        }
        
        set index_list ""
        foreach {dataInput} $cmdProtIntfParamsList {
            if {[info exists $dataInput]} {
                lappend index_list [set $dataInput]
            } else  {
                lappend index_list (.*)
            }
        }
        
        set tempIndexList [join $index_list ,]
        set match_index_list [protocol_interfaces_operation \
                -reg $tempIndexList -ret_type value -ip_version $rev_ip_version]
        
        if {[llength $match_index_list] == 0} {
            # Reversed ip version not found
            # Try to find mac only
            set match_index_list [protocol_interfaces_operation \
                -reg $tempIndexList -ret_type value -ip_version 0]
        }
        
        if {[llength $match_index_list] == 1} {
            set match_mac_address [lindex [split $match_index_list ,] \
                    $cmdProtIntfParamsPositions(mac_address)]

            set match_description [lindex [split $match_index_list ,] \
                    $cmdProtIntfParamsPositions(description)]

            keylset returnList status 2
            keylset returnList mac_address $match_mac_address
            keylset returnList description $match_description
            return  $returnList
        } elseif {[llength $match_index_list] > 1} {
            set match_index_list [lindex $match_index_list 0]
            set match_mac_address [lindex [split $match_index_list ,] \
                    $cmdProtIntfParamsPositions(mac_address)]

            set match_description [lindex [split $match_index_list ,] \
                    $cmdProtIntfParamsPositions(description)]

            keylset returnList status 2
            keylset returnList mac_address $match_mac_address
            keylset returnList description $match_description
            return  $returnList
        } else {
            # Reversed IP version or mac only interface not found
            # Try to find same IP version same mac
            set match_index_list [protocol_interfaces_operation \
                -reg $tempIndexList -ret_type value -ip_version $ip_version]
            
            if {[llength $match_index_list] == 1} {
                set match_mac_address [lindex [split $match_index_list ,] \
                        $cmdProtIntfParamsPositions(mac_address)]

                set match_description [lindex [split $match_index_list ,] \
                        $cmdProtIntfParamsPositions(description)]

                keylset returnList status 3
                keylset returnList mac_address $match_mac_address
                keylset returnList description $match_description
                return  $returnList
            } elseif {[llength $match_index_list] > 1} {
                set match_index_list [lindex $match_index_list 0]
                set match_mac_address [lindex [split $match_index_list ,] \
                        $cmdProtIntfParamsPositions(mac_address)]

                set match_description [lindex [split $match_index_list ,] \
                        $cmdProtIntfParamsPositions(description)]

                keylset returnList status 3
                keylset returnList mac_address $match_mac_address
                keylset returnList description $match_description
                return  $returnList
            }
        }
    }
    
    keylset returnList status 0
    return  $returnList
}


proc ::ixia::dual_stack_interface_exists { args } {
    variable cmdProtIntfParamsList
    variable cmdProtIntfParamsPositions
    
    set procName [lindex [info level [info level]] 0]
    debug "$procName $args"
    set mandatory_args {
        -port_handle        REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
    }

    set opt_args {
        -check_opposite_ip_version CHOICES 0 1
                            DEFAULT 1
        -ip_version         CHOICES 4 6 4_6 0
        -ipv4_address       IPV4
        -ipv6_address       IPV6
        -gateway_address
        -gateway_address_v6 IPV6
        -dst_ip_address     IP
        -mac_address
        -type               CHOICES connected routed gre
                            DEFAULT connected
    }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $mandatory_args -optional_args $opt_args} parse_error]} {
        keylset returnList status -1
        keylset returnList log "Parsing error occurred in\
                ::ixia::interface_exists.  $parse_error"
        return $returnList
    }
    
    if {![info exists ipv4_address] && ![info exists ipv6_address] &&\
            ![info exists mac_address]} {
        puts "\nWARNING: Interface search will be very slow because $procName\
                was called without any of the parameters: ipv4_address, ipv6_address,\
                mac_address.\n"
    }
    
    if {[info exists ipv6_address] && [::ipv6::isValidAddress $ipv6_address]} {
        set ipv6_address [::ipv6::expandAddress $ipv6_address]
    }
    
    if {[info exists ip_version] && $ip_version == "4_6"} {
        set ip_version 46
    }
    
    # Map ::ixia::dual_stack_interface_exists arguments' names to 
    # the arguments names from cmdProtIntfParamsList and 
    # cmdProtIntfParamsPositions
    if {[info exists gateway_address]} {
        set ipv4_gateway $gateway_address
    }

    if {[info exists gateway_address_v6]} {
        set ipv6_gateway $gateway_address_v6
    }

    if {[info exists dst_ip_address]} {
        set ipv4_dst_address $dst_ip_address
    }

    set index_list ""
    foreach {dataInput} $cmdProtIntfParamsList {
        if {[info exists $dataInput]} {
            lappend index_list [set $dataInput]
        } else  {
            lappend index_list (.*)
        }
    }

    # Search if interface exists with parameters provided by the user
    set tempIndexList [join $index_list ,]
    set cmd "protocol_interfaces_operation \
            -reg $tempIndexList -ret_type value"
    if {[info exists ip_version]} {
        append cmd " -ip_version $ip_version"
    }
    set match_index_list [eval $cmd]
    
    if {[llength $match_index_list] == 1} {
        set match_mac_address [lindex [split $match_index_list ,] \
                $cmdProtIntfParamsPositions(mac_address)]

        set match_description [lindex [split $match_index_list ,] \
                $cmdProtIntfParamsPositions(description)]

        keylset returnList status 1
        keylset returnList mac_address $match_mac_address
        keylset returnList description $match_description
        return  $returnList
    } elseif {[llength $match_index_list] > 1} {
        set match_index_list [lindex $match_index_list 0]
        set match_mac_address [lindex [split $match_index_list ,] \
                $cmdProtIntfParamsPositions(mac_address)]

        set match_description [lindex [split $match_index_list ,] \
                $cmdProtIntfParamsPositions(description)]

        keylset returnList status 1
        keylset returnList mac_address $match_mac_address
        keylset returnList description $match_description
        return  $returnList
    }
    
    if {[info exists ip_version] && $ip_version != "46"} {
        # If no match found, then search for an opposite ip_version interface
        # with the same mac address because we can expect for a dual IPv4 | IPv6
        # interface
        array set ip_version_array [list 4 6 6 4]
        set rev_ip_version $ip_version_array($ip_version)
        
        set ipv${rev_ip_version}_args_list [list port_handle ipv${rev_ip_version}_address \
                ipv${rev_ip_version}_gateway ipv${rev_ip_version}_dst_address mac_address type]
        array set ipv${rev_ip_version}_args [list]

        foreach arg [set ipv${rev_ip_version}_args_list] {
            if {[info exists $arg]} {
                set ipv${rev_ip_version}_args($arg) [subst $$arg]
            }
        }

        set index_list ""
        foreach {dataInput} $cmdProtIntfParamsList {
            if {[info exists ipv${rev_ip_version}_args($dataInput)]} {
                lappend index_list [set ipv${rev_ip_version}_args($dataInput)]
            } else  {
                lappend index_list (.*)
            }
        }

        # Search if interface exists
        set tempIndexList [join $index_list ,]
        set match_index_list [protocol_interfaces_operation \
                -reg $tempIndexList -ret_type value -ip_version $rev_ip_version]
        
        if {[llength $match_index_list] != 0} {
            
            foreach match_index_list_item $match_index_list {
                
                set match_mac_address [lindex [split $match_index_list_item ,] \
                        $cmdProtIntfParamsPositions(mac_address)]
         
                set match_description [lindex [split $match_index_list_item ,] \
                        $cmdProtIntfParamsPositions(description)]
               
                ## Found a matching interface with at least the same MAC and Type
                # If it has the oposite ip version return code 2
                set match_ip_addr [lindex [split $match_index_list_item ,] \
                        $cmdProtIntfParamsPositions(ipv${rev_ip_version}_address)]
                
                set match_current_ip_addr [lindex [split $match_index_list_item ,] \
                        $cmdProtIntfParamsPositions(ipv${ip_version}_address)]
                
                if {[isValidIPAddress $match_ip_addr]} {
                    if {![isValidIPAddress $match_current_ip_addr]} {
                        if {$check_opposite_ip_version == 1} {
                            keylset returnList status 2
                            keylset returnList mac_address $match_mac_address
                            keylset returnList description $match_description
                            return  $returnList
                        }
                    }
                } else {
                    ## Is it mac only?
                    set match_ip_addr [lindex [split $match_index_list_item ,] \
                            $cmdProtIntfParamsPositions(ipv${ip_version}_address)]
                    if {![isValidIPAddress $match_ip_addr]} {
                        keylset returnList status 2
                        keylset returnList mac_address $match_mac_address
                        keylset returnList description $match_description

                        return  $returnList
                    } elseif {$type == "connected"} {
                        keylset returnList status 3
                        keylset returnList mac_address $match_mac_address
                        keylset returnList description $match_description
                    }
                }
            }
        }
    } else {
        # If no match found and the new interface is dual stack, chech whether
        # there is an interface that has only one of the two protocol
        # stacks configured.
        # Try to find a matching IPv4 interface first if ipv4_address exists
        #   or if neither ipv4 or ipv6 addresses exist
        if {[info exists ipv4_address]} {
            # Try to find the matching ipv4 interface.  It's much faster if ipv4 address is specified
            set ipv4_args_list [list port_handle ipv4_address \
                    ipv4_gateway ipv4_dst_address mac_address type]
            array set ipv4_args [list]

            foreach arg $ipv4_args_list {
                if {[info exists $arg]} {
                    set ipv4_args($arg) [subst $$arg]
                }
            }

            set index_list ""
            foreach {dataInput} $cmdProtIntfParamsList {
                if {[info exists ipv4_args($dataInput)]} {
                    lappend index_list [set ipv4_args($dataInput)]
                } else  {
                    lappend index_list (.*)
                }
            }

            # Search if interface exists with parameters provided by the user
            set tempIndexList [join $index_list ,]
            set cmd "protocol_interfaces_operation \
                    -reg $tempIndexList -ret_type value"
            if {[info exists ip_version]} {
                append cmd " -ip_version $ip_version"
            }
            set match_index_list [eval $cmd]
            
                    
        } elseif {[info exists ipv6_address]} {
            
            # Try to find a matching IPv6 interface. It's much faster if ipv6 address is specified
            set ipv6_args_list [list port_handle ipv6_address \
                    ipv6_gateway ipv4_dst_address mac_address type]
            array set ipv6_args [list]
    
            foreach arg $ipv6_args_list {
                if {[info exists $arg]} {
                    set ipv6_args($arg) [subst $$arg]
                }
            }

            set index_list ""
            foreach {dataInput} $cmdProtIntfParamsList {
                if {[info exists ipv6_args($dataInput)]} {
                    lappend index_list [set ipv6_args($dataInput)]
                } else  {
                    lappend index_list (.*)
                }
            }
    
            # Search if interface exists with parameters provided by the user
            set tempIndexList [join $index_list ,]
            set cmd "protocol_interfaces_operation \
                    -reg $tempIndexList -ret_type value"
            if {[info exists ip_version]} {
                append cmd " -ip_version $ip_version"
            }
            set match_index_list [eval $cmd]
            
        } else {
            # Try to find the matching ipv4 interface. IPv4 address not specified. Will go slower
            set ipv4_args_list [list port_handle ipv4_address \
                    ipv4_gateway ipv4_dst_address mac_address type]
            array set ipv4_args [list]

            foreach arg $ipv4_args_list {
                if {[info exists $arg]} {
                    set ipv4_args($arg) [subst $$arg]
                }
            }

            set index_list ""
            foreach {dataInput} $cmdProtIntfParamsList {
                if {[info exists ipv4_args($dataInput)]} {
                    lappend index_list [set ipv4_args($dataInput)]
                } else  {
                    lappend index_list (.*)
                }
            }

            # Search if interface exists with parameters provided by the user
            set tempIndexList [join $index_list ,]
            set cmd "protocol_interfaces_operation \
                    -reg $tempIndexList -ret_type value"
            if {[info exists ip_version]} {
                append cmd " -ip_version $ip_version"
            }
            set match_index_list [eval $cmd]
            
            if {[llength $match_index_list] == 0} {
                # Try to find the IPv6 interface
                set ipv6_args_list [list port_handle ipv6_address \
                        ipv6_gateway ipv4_dst_address mac_address type]
                array set ipv6_args [list]
        
                foreach arg $ipv6_args_list {
                    if {[info exists $arg]} {
                        set ipv6_args($arg) [subst $$arg]
                    }
                }

                set index_list ""
                foreach {dataInput} $cmdProtIntfParamsList {
                    if {[info exists ipv6_args($dataInput)]} {
                        lappend index_list [set ipv6_args($dataInput)]
                    } else  {
                        lappend index_list (.*)
                    }
                }
        
                # Search if interface exists with parameters provided by the user
                set tempIndexList [join $index_list ,]
                set cmd "protocol_interfaces_operation \
                        -reg $tempIndexList -ret_type value"
                if {[info exists ip_version]} {
                    append cmd " -ip_version $ip_version"
                }
                set match_index_list [eval $cmd]
            }
        }
        
        if {[llength $match_index_list] == 1} {
            set match_mac_address [lindex [split $match_index_list ,] \
                    $cmdProtIntfParamsPositions(mac_address)]
    
            set match_description [lindex [split $match_index_list ,] \
                    $cmdProtIntfParamsPositions(description)]
    
            keylset returnList status 2
            keylset returnList mac_address $match_mac_address
            keylset returnList description $match_description
            return  $returnList
        } elseif {[llength $match_index_list] > 1} {
            set match_index_list [lindex $match_index_list 0]
            set match_mac_address [lindex [split $match_index_list ,] \
                    $cmdProtIntfParamsPositions(mac_address)]
    
            set match_description [lindex [split $match_index_list ,] \
                    $cmdProtIntfParamsPositions(description)]
    
            keylset returnList status 2
            keylset returnList mac_address $match_mac_address
            keylset returnList description $match_description
            return  $returnList
        }
    }

    # If no match found, then search for same mac
    if {[info exists mac_address]} {
        set mac_args_list [list port_handle mac_address type]
        array set mac_args [list]

        foreach arg $mac_args_list {
            if {[info exists $arg]} {
                set mac_args($arg) [subst $$arg]
            }
        }

        set index_list ""
        foreach {dataInput} $cmdProtIntfParamsList {
            if {[info exists mac_args($dataInput)]} {
                lappend index_list [set mac_args($dataInput)]
            } else  {
                lappend index_list (.*)
            }
        }

        # Search if interface exists with only mac params
        set tempIndexList [join $index_list ,]
        set match_index_list [protocol_interfaces_operation \
                -reg $tempIndexList -ret_type value]
        if {[llength $match_index_list] > 0} {
            keylset returnList status 3
            keylset returnList mac_address $mac_address
            keylset returnList description \
                    [lindex $match_index_list 0]

            return  $returnList
        }
    }

    keylset returnList status 0
    return  $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::get_next_mac_address
#
# Description:
#    Returns the next unique mac address to create an interface with.
#
# Synopsis:
#    ::ixia::get_next_mac_address
#
# Arguments:
#
# Return Values:
#    A keyed list
#    key: status           value: $::SUCCESS - script performed its function
#                                 $::FAILURE - script failed without completing
#    key: log              value: When status is $::FAILURE, returns more info
#    key: mac_address      value: Mac address
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
proc ::ixia::get_next_mac_address {} {
    variable protocol_interfaces_mac_address
    
    set protocol_interfaces_mac_address [mpexpr \
            $protocol_interfaces_mac_address + 1]
    
    #while {[info exists protocol_interfaces_mac_type([::ixia::format_hex \
                #$protocol_interfaces_mac_address 48],connected)]} {
        
        #set protocol_interfaces_mac_address [mpexpr \
                #$protocol_interfaces_mac_address + 1]
    #}
    
    keylset returnList status 1
    keylset returnList mac_address [::ixia::format_hex \
            $protocol_interfaces_mac_address 48]
    
    return  $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::get_interface_parameter
#
# Description:
#    Get the interface for the given index
#
# Synopsis:
#    ::ixia::get_interface_parameter
#
# Arguments:
#    interface
#        Chassis, card, and port in the format a b c
#    interface_index
#        The index of the interface to get
#
# Return Values:
#
# Examples:
#
proc ::ixia::get_interface_parameter {args} {

    variable cmdProtIntfParamsList
    variable cmdProtIntfParamsPositions

    set mandatory_args {
        -description
        -parameter      CHOICES type ipv4_address ipv4_dst_address ipv4_mask
                        CHOICES ipv4_gateway ipv6_address ipv6_mask vlan_id
                        CHOICES vlan_priority mac_address atm_encap atm_vpi
                        CHOICES atm_vci dhcp_enable port_handle ixnetwork_objref
                        CHOICES ipv6_gateway
    }
    set opt_args {
        -port_handle    REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -input          CHOICES description intf_handle
                        DEFAULT description
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
                    $mandatory_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing.  $parse_error"
        return $returnList
    }
    
    if {$input == "description"} {
        set ret_code [rfget_interface_details_by_description $description]
        if {[keylget ret_code status] != $::SUCCESS} {
            keylset ret_code log "Failed to get interface parameters.\
                    [keylget ret_code log]"
            return $ret_code
        }
        
        set index [keylget ret_code ret_val]
        
    } else {
        set index [rfget_interface_details_by_handle $description]
    }
    
    
        
    if {$index == ""} {
        keylset returnList status $::FAILURE
        keylset returnList log "Interface $description doesn't exist."
        return  $returnList
    }
    
    foreach {dataInput} $cmdProtIntfParamsList {
        foreach {param} $parameter {
            if {[lsearch $param $dataInput] != -1} {
                set retValue [lindex [split $index ,] \
                        $cmdProtIntfParamsPositions($dataInput)]
                
                if {$retValue != "(.*)"} {
                    switch -- $dataInput {
                        vlan_id -
                        vlan_priority {
                            # Vlans use commas to define stackedVlan. Internally they are 
                            # stored using colon as separator. Replace it with commas before
                            # returning
                            regsub -all : retValue , retValue
                        }
                    }
                    keylset returnList $dataInput $retValue
                } else  {
                    keylset returnList $dataInput ""
                }
            }
        }
    }

    keylset returnList status $::SUCCESS
    return  $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::get_interface_by_description
#
# Description:
#    Get the interface given the port and description, so that it is accessable
#    via the interfaceEntry command.
#
# Synopsis:
#    ::ixia::get_interface_by_description
#        port_handle
#        description
#
# Arguments:
#    port_handle
#        The port on which the interface exists.
#    description
#        The description of the interface to load for the port.
#
# Return Values:
#
# Examples:
#
proc ::ixia::get_interface_by_description { chasNum cardNum portNum \
        description } {

    if {[interfaceTable select $chasNum $cardNum $portNum]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on call to interfaceTable select\
                $chasNum $cardNum $portNum."
        return $returnList
    }

    if {[interfaceTable getFirstInterface] != 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on call to interfaceTable\
                getFirstInterface.  No interfaces exist on $chasNum $cardNum\
                $portNum."
        return $returnList
    } else {

        # See if the description for the first item matches
        set temp_desc [interfaceEntry cget -description]
        if {$description == $temp_desc} {
            keylset returnList status $::SUCCESS
            return $returnList
        }

        # Loop through any other existing interfaces and check them
        set finished 0
        set found 0
        while {!$finished} {
            if {[interfaceTable getNextInterface]} {
                set finished 1
            } else {
                set temp_desc [interfaceEntry cget -description]
                if {$description == $temp_desc} {
                    set found 1
                    set finished 1
                }
            }
        }
        if {$found} {
            keylset returnList status $::SUCCESS
        } else {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not find an interface with this\
                    description : $description on $chasNum $cardNum $portNum."
        }
        return $returnList
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::make_interface_description
#
# Description:
#    Make a new description.
#
# Synopsis:
#    ::ixia::make_interface_description
#        port_handle
#        mac_address
#        type
#
# Arguments:
#
# Return Values:
#
# Examples:
#
proc ::ixia::make_interface_description {port_handle mac_address \
            {type connected}} {

    variable current_intf

    switch -- $type {
        connected { set front ""     }
        routed    { set front "UN - "  }
        gre       { set front "GRE - " }
    }
    set intf_description \
            "${front}${port_handle} - [string tolower $mac_address] - ${current_intf}"

    incr current_intf

    return $intf_description
}


##Internal Procedure Header
# Name:
#    ::ixia::get_interface_ip
#
# Description:
#    Get the IP address of an interface
#
# Synopsis:
#    ::ixia::get_interface_ip
#        interface
#        interface_index
#        ip_version
#
# Arguments:
#    interface
#        Chassis, card, and port in the form a b c
#    interface_index
#        The index of the interface wanted
#    ip_version
#        One of 4 or 6, representing the IP version
#
# Return Values:
#
# Examples:
#
proc ::ixia::get_interface_ip { interface interface_index ip_version } {

    scan $interface "%d %d %d" chassis card port

    if {[interfaceTable select $chassis $card $port]} {
        return -1
    }

    if {$interface_index == 1} {
        if {[interfaceTable getFirstInterface] != 0} {
            return -1
        } else {
            if { $ip_version == 4 } {
                if {[interfaceEntry getFirstItem addressTypeIpV4]} {
                    return -1
                }
                return [interfaceIpV4 cget -ipAddress]
            } elseif { $ip_version == 6 } {
                if {[interfaceEntry getFirstItem addressTypeIpV6]} {
                    return -1
                }

                return [::ipv6::expandAddress [interfaceIpV6 cget -ipAddress]]
            }
        }

    } else {
        set ixia_interface_table 2
        if {[interfaceTable getFirstInterface]} {
            return -1
        }

        while {$ixia_interface_table <= $interface_index} {
            if {[interfaceTable getNextInterface] != 0} {
                return -1
            }
            incr ixia_interface_table
        }
        if { $ip_version == 4 } {
            if {[interfaceEntry getFirstItem addressTypeIpV4]} {
                return -1
            }
            return [interfaceIpV4 cget -ipAddress]
        } elseif { $ip_version == 6 } {
            if {[interfaceEntry getFirstItem addressTypeIpV6]} {
                return -1
            }

            return [::ipv6::expandAddress [interfaceIpV6 cget -ipAddress]]
        }
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::get_dut_ip
#
# Description:
#    Get the gateway ip address from an interface
#
# Synopsis:
#    ::ixia::get_dut_ip
#        interface
#        interface_index
#        ip_version
#
# Arguments:
#    interface
#        Chassis, card, and port in the form a b c
#    interface_index
#        The index of the interface wanted
#    ip_version
#        One of 4 or 6, representing the IP version
#
# Return Values:
#
# Examples:
#
proc ::ixia::get_dut_ip { interface interface_index ip_version } {

    scan $interface "%d %d %d" chassis card port

    interfaceTable select $chassis $card $port

    if {$interface_index == 1} {
        if {[interfaceTable getFirstInterface] != 0} {
            return -1
        } else {
            if { $ip_version == 4 } {
                interfaceEntry getFirstItem addressTypeIpV4
                return [interfaceIpV4 cget -gatewayIpAddress]
            }
        }

    } else {
        set ixia_interface_table 2
        interfaceTable getFirstInterface
        while {$ixia_interface_table <= $interface_index} {
            if {[interfaceTable getNextInterface] != 0} {
                return -1
            }
            incr ixia_interface_table
        }
        if { $ip_version == 4 } {
            interfaceEntry getFirstItem addressTypeIpV4
            return [interfaceIpV4 cget -gatewayIpAddress]
        }
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::get_number_of_intf
#
# Description:
#    Gives the number of interfaces on a port
#
# Synopsis:
#    ::ixia::get_number_of_intf
#        interface
#
# Arguments:
#    interface
#        Chassis, card, and port in the format a b c
#
# Return Values:
#
# Examples:
#
proc ::ixia::get_number_of_intf { interface } {

    scan $interface "%d %d %d" chassis card port

    interfaceTable select $chassis $card $port

    set number_of_interface 0

    if {[interfaceTable getFirstInterface]} {
        return $number_of_interface
    } else {
        incr number_of_interface
        while { [interfaceTable getNextInterface] == 0 } {
            incr number_of_interface
        }
        return $number_of_interface
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::protocol_interface_config
#
# Description:
#    Configures interface(s) in the Protocol Server
#    Parameter -type can be provided only as connected or routed and it was added 
#    to allow the creation of a routed interface by calling protocol_interface_config 
#    with the parameters that correspond to connected interfaces.
#    Parameter connected_via is to be used only for -type routed.
#
# Synopsis:
#    ::ixia::protocol_interface_config
#
# Arguments:
#
# Return Values:
#    Keyed List of parameters from the Interface
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
proc ::ixia::protocol_interface_config {args} {
    
    set procName [lindex [info level [info level]] 0]
    #debug "$procName $args"
    
    set man_args {
        -port_handle REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -ip_address  IP
        -ip_version  CHOICES 4 6
    }

    set opt_args {
        -atm_encapsulation        CHOICES vc_mux_ipv4_routed vc_mux_ipv6_routed
                                  CHOICES llc_bridge_ethernet_fcs 
                                  CHOICES vc_mux_bridged_ethernet_fcs
                                  CHOICES vc_mux_bridged_ethernet_no_fcs
                                  CHOICES vc_mux_mpls_routed
                                  CHOICES llc_bridge_ethernet_no_fcs llc_pppoa
                                  CHOICES vcc_mux_pppoa llc_nlpid_routed
        -atm_mode                 CHOICES routed bridged
        -atm_vci                  RANGE   0-65535
        -atm_vci_step             RANGE   0-65535
                                  DEFAULT 1
        -atm_vpi                  RANGE   0-255
        -atm_vpi_step             RANGE   0-255
                                  DEFAULT 1
        -count                    RANGE   1-10000
                                  DEFAULT 1
        -gateway_ip_address       IP
        -gateway_ip_address_step  IP
        -ip_address_step          IP
        -loopback_ip_address      IP
                                  DEFAULT 0.0.0.0
        -loopback_ip_address_step IP
                                  DEFAULT 0.0.0.1
        -loopback_count           NUMERIC
                                  DEFAULT 1
        -mac_address
        -mtu
        -netmask
        -vlan_id                  RANGE   0-4096
        -vlan_id_mode             CHOICES fixed increment
                                  DEFAULT increment
        -vlan_id_step             RANGE   0-4096
                                  DEFAULT 0
        -vlan_user_priority       RANGE   0-7
                                  DEFAULT 0
        -gre_enable               CHOICES 0 1
                                  DEFAULT 0
        -gre_unique               CHOICES 0 1
                                  DEFAULT 1
        -gre_dst_ip_address       IP
        -gre_dst_ip_address_step  IP
        -gre_count                NUMERIC
                                  DEFAULT 1
        -gre_checksum_enable      CHOICES 0 1
                                  DEFAULT 0
        -gre_seq_enable           CHOICES 0 1
                                  DEFAULT 0
        -gre_key_enable           CHOICES 0 1
                                  DEFAULT 0
        -gre_key_in               RANGE 0-4294967295
                                  DEFAULT 0
        -gre_key_out              RANGE 0-4294967295
                                  DEFAULT 0
        -no_write
        -type                     CHOICES connected routed
        -connected_via
    }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing.  $parse_error"
        return $returnList
    }

    set port_list [::ixia::format_space_port_list $port_handle]
    set interface [lindex $port_list 0]
    foreach {chasNum cardNum portNum} $interface {}

    if {[interfaceTable select $chasNum $cardNum $portNum]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failure on call to interfaceTable select\
                $chasNum $cardNum $portNum."
        return $returnList
    }

    if {[info exists mac_address]} {
        set mac_address [::ixia::convertToIxiaMac $mac_address]
        set mac_address_exists 1
    } else  {
        set mac_address_exists 0
    }
    
    set desc_list ""
    set loop_list ""

    for {set intf_index 0} {$intf_index < $count} {incr intf_index} {

        if {$ip_version == 6} {
            set ip_address [::ipv6::expandAddress $ip_address]
        }

        # We will work on the interface itself first.  Then do the work 
        # necessary for the loopback interface if it applies.

        # Check if interface already exists.  0 = do not create, 1 = create
        set create_interface 0
        
        
        set intf_existence "::ixia::interface_exists         \
                -port_handle     $chasNum/$cardNum/$portNum  \
                -ip_version      $ip_version                 \
                -ip_address      $ip_address                 "
        
        if {[info exists type]} {
            append intf_existence "\
                    -type            $type               "
        }
        
        if {![info exists gateway_ip_address]} {
            if {$ip_version == 4} {
           	    set gateway_ip_address 0.0.0.0
            } else {
                set gateway_ip_address 0::0
            }
        }
        
        if {$ip_version == 6} {
            set gateway_ip_address [::ipv6::expandAddress $gateway_ip_address]
        }
        
        append intf_existence "\
            -gateway_address $gateway_ip_address "
        
        if {$mac_address_exists}  {
            append intf_existence "\
                    -mac_address     $mac_address        "
        }

        set results [eval $intf_existence]
        set status  [keylget results status]
        switch -- $status {
            -1 {
                # The call to interface exists failed, fail this too.
                keylset returnList status $::FAILURE
                keylset returnList log [keylget results log]
                return $returnList
            }
            0 {
                # The interface doesn't exist and we need to create it
                set create_interface 1
                if {!$mac_address_exists} {
                    set retCode [::ixia::get_next_mac_address]
                    if {[keylget retCode status] != $::SUCCESS} {
                        keylset returnList status $::FAILURE
                        keylset returnList log [keylget results log]
                        return $returnList
                    }
                    set mac_address  [keylget retCode mac_address]
                }
            }
            1 -
            2 {
                # The interface exists with the same ip and all configuration
                # The interface exists but with the opposite version
                set interface_description [keylget results description]
                set mac_address           [keylget results mac_address]
            }
            3 {
                # Found the mac address on another interface on this port.
                # Fail this because to create would mean one of them would
                # have to be disabled, confusing for the user.
                keylset returnList status $::FAILURE
                keylset returnList log "Creating the protocol interface failed. \
                        An interface with this MAC address was found, but the\
                        IP address was different."
                return $returnList
            }
        }
        
        # If create_interface = 1, means that the interface must be created in
        # the Protocol Server
        if {$create_interface == 1} {

            interfaceEntry clearAllItems addressTypeIpV6
            interfaceEntry clearAllItems addressTypeIpV4

            interfaceIpV4 setDefault
            interfaceIpV6 setDefault
            if {[info exists type]} {
                set interface_description [::ixia::make_interface_description \
                    $chasNum/$cardNum/$portNum $mac_address $type]
            } else {
                set interface_description [::ixia::make_interface_description \
                    $chasNum/$cardNum/$portNum $mac_address]
            }
            
            interfaceEntry setDefault
            interfaceEntry config -enable      true
            interfaceEntry config -description $interface_description
            interfaceEntry config -macAddress  $mac_address
            
            if {$ip_version == 6} {
                interfaceEntry config -ipV6Gateway $gateway_ip_address
            }
            
            if {[info exists type] && ($type == "routed") && [info exists connected_via]} {
                catch {interfaceEntry config -connectedVia \
                        $connected_via}
            }
            
            # Configure IP table
            if {$ip_version == 4} {
                interfaceIpV4 config -gatewayIpAddress $gateway_ip_address
                interfaceIpV4 config -maskWidth $netmask
                interfaceIpV4 config -ipAddress $ip_address
            } elseif {$ip_version == 6} {
                interfaceIpV6 config -maskWidth $netmask
                interfaceIpV6 config -ipAddress $ip_address
            }

            set retCode [interfaceEntry addItem addressTypeIpV$ip_version]
            if {$retCode != 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failure on call interfaceEntry\
                        addItem addressTypeIpV$ip_version.  Port is $chasNum\
                        $cardNum $portNum.  Return code was $retCode."
                return $returnList
            }

            # Set up a parameter list of the items required to save to
            # the protocol interface
            set intf_params "-port_handle $chasNum/$cardNum/$portNum \
                    -description [list $interface_description]       \
                    -mac_address [list $mac_address] "
            if {$ip_version == 4} {
                append intf_params " -ipv4_address $ip_address \
                        -ipv4_gateway $gateway_ip_address      \
                        -ipv4_mask $netmask "
            } elseif {$ip_version == 6} {
                append intf_params " -ipv6_address $ip_address \
                        -ipv6_mask $netmask \
                        -ipv6_gateway $gateway_ip_address "
            }
            append intf_params " -ip_version $ip_version"
            
            # Configure ATM parameters
            if {[info exists atm_encapsulation]} {
                append intf_params " -atm_encap $atm_encapsulation "

                switch -- $atm_encapsulation {
                    llc_bridge_ethernet_fcs {
                        interfaceEntry config -atmEncapsulation \
                                atmEncapsulationLLCBridgedEthernetFCS
                    }
                    vc_mux_ipv4_routed {
                        interfaceEntry config -atmEncapsulation \
                                atmEncapsulationVccMuxIPV4Routed
                    }
                    vc_mux_bridged_ethernet_fcs {
                        interfaceEntry config -atmEncapsulation \
                                atmEncapsulationVccMuxBridgedEthernetFCS
                    }
                    vc_mux_bridged_ethernet_no_fcs {
                        interfaceEntry config -atmEncapsulation \
                                atmEncapsulationVccMuxBridgedEthernetNoFCS
                    }
                    vc_mux_ipv6_routed {
                        interfaceEntry config -atmEncapsulation \
                                atmEncapsulationVccMuxIPV6Routed
                    }
                    vc_mux_mpls_routed {
                        interfaceEntry config -atmEncapsulation \
                                atmEncapsulationVccMuxMPLSRouted
                    }
                    llc_routed_clip {
                        interfaceEntry config -atmEncapsulation \
                                atmEncapsulationLLCRoutedCLIP
                    }
                    llc_bridge_ethernet_no_fcs {
                        interfaceEntry config -atmEncapsulation \
                                atmEncapsulationLLCBridgedEthernetNoFCS
                    }
                    llc_pppoa {
                        interfaceEntry config -atmEncapsulation \
                                atmEncapsulationLLCPPPoA
                    }
                    vcc_mux_pppoa {
                        interfaceEntry config -atmEncapsulation \
                                atmEncapsulationVccMuxPPPoA
                    }
                    llc_nlpid_routed {
                        interfaceEntry config -atmEncapsulation \
                                atmEncapsulationLLCNLPIDRouted
                    }
                }
            }

            if {[info exists atm_mode]} {
                switch -- $atm_mode {
                    routed {
                        interfaceEntry config -atmMode atmRouted
                    }
                    bridged {
                        interfaceEntry config -atmMode atmBridged
                    }
                }
            }

            if {[info exists atm_vpi]} {
                append intf_params " -atm_vpi $atm_vpi "
                interfaceEntry config -atmVpi $atm_vpi
            }
            if {[info exists atm_vci]} {
                append intf_params " -atm_vci $atm_vci "
                interfaceEntry config -atmVci $atm_vci
            }
            
            if {[info exists mtu]} {
                interfaceEntry config -mtu $mtu
            }

            # Configure VLAN
            if {[info exists vlan_id]} {
                append intf_params " -vlan_id $vlan_id \
                        -vlan_priority $vlan_user_priority "

                interfaceEntry config -enableVlan   true
                interfaceEntry config -vlanId       $vlan_id
                interfaceEntry config -vlanPriority $vlan_user_priority
            }

            # Add interface
            set cmd ""
            if {[info exists type] && ($type == "routed")} {
                set cmd "interfaceTable addInterface interfaceTypeRouted"
            } else {
                set cmd "interfaceTable addInterface"
            }
            if {[eval $cmd]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failure on call to interfaceTable\
                        addInterface.  Port is $chasNum $cardNum $portNum."
                return $returnList
            } else {
                # Save the rest of the protocol interface information
                if {$create_interface} {
                    append intf_params " -mode add "
                } else {
                    append intf_params " -mode modify "
                }
                
                if {[info exists type]} {
                    append intf_params " -type $type "
                }
                
                set retList [eval modify_protocol_interface_info $intf_params]
                if {[keylget retList status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failure to save interface\
                            information internally in data structures. [keylget retList log]"
                    return $returnList
                }
            }

            interfaceEntry clearAllItems addressTypeIpV$ip_version

            keylset returnList created 1
        } else {

            if {[interfaceTable select $chasNum $cardNum $portNum]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failure on call to interfaceTable\
                        select $chasNum $cardNum $portNum."
            }

            # Add the configuration to a current interface, possibly a
            # dual-stack (v4v6).  Cannot use the direct getInterface call.
            # Must step thru using getFirst, getNext, limitation in IxTclHal.
            set results [::ixia::get_interface_by_description \
                    $chasNum $cardNum $portNum $interface_description]

            if {[keylget results status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failure finding interface by\
                        description on port.  Log : [keylget results log]"
                return $returnList
            }

            # Get what is configured in the interface.  Need this information
            # to re-create it.
            set v4_exists 0
            set v6_exists 0

            if {![interfaceEntry getFirstItem  $::addressTypeIpV4]} {
                set gw_ip_addr_v4 [interfaceIpV4 cget -gatewayIpAddress]
                set mask_v4       [interfaceIpV4 cget -maskWidth]
                set ip_addr_v4    [interfaceIpV4 cget -ipAddress]
                set v4_exists 1
            }

            if {![interfaceEntry getFirstItem  $::addressTypeIpV6]} {
                set mask_v6    [interfaceIpV6 cget -maskWidth]
                set ip_addr_v6 [interfaceIpV6 cget -ipAddress]
                set v6_exists 1
            }

            # Only need to delete/recreate the interface if we are making 
            # it into an IPv4/IPv6 combined interface or if it's a MAC only interface
            if {(!($v4_exists && $v6_exists) && ($ip_version == 4) && $v6_exists) || \
                    (!($v4_exists && $v6_exists) && ($ip_version == 6) && $v4_exists) || \
                    (($ip_version != 0) && !$v4_exists && !$v6_exists)} {
                
                # Depends on IxOS version BUG537614
                if {[package provide IxTclHal] < "5.60"} {
                    ## Delete the interface to recreate it below
                    if {[interfaceTable delInterface $interface_description]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failure on call to interfaceTable\
                                delInterface $interface_description on port\
                                $chasNum $cardNum $portNum."
                        return $returnList
                    }
                    interfaceEntry clearAllItems addressTypeIpV6
                    interfaceEntry clearAllItems addressTypeIpV4
                }
                
                set intf_params " -port_handle $chasNum/$cardNum/$portNum \
                    -description [list $interface_description] "

                # Configure IP table
                if {$ip_version == 4} {
                    interfaceIpV4  setDefault
                    interfaceIpV4  config -gatewayIpAddress $gateway_ip_address
                    interfaceIpV4  config -maskWidth $netmask
                    interfaceIpV4  config -ipAddress $ip_address

                    append intf_params " -ipv4_gateway $gateway_ip_address \
                            -ipv4_mask $netmask -ipv4_address $ip_address "

                    if {$v6_exists} {
                        interfaceIpV6  setDefault
                        interfaceIpV6  config -maskWidth $mask_v6
                        interfaceIpV6  config -ipAddress $ip_addr_v6

                        append intf_params " -ipv6_mask $mask_v6 \
                                -ipv6_address $ip_addr_v6 "
                    }

                } elseif {$ip_version == 6} {
                    interfaceIpV6  setDefault
                    interfaceIpV6  config -maskWidth $netmask
                    interfaceIpV6  config -ipAddress $ip_address

                    append intf_params " -ipv6_mask $netmask \
                            -ipv6_address $ip_address "

                    if {$v4_exists} {
                        interfaceIpV4  setDefault
                        interfaceIpV4  config -gatewayIpAddress $gw_ip_addr_v4
                        interfaceIpV4  config -maskWidth $mask_v4
                        interfaceIpV4  config -ipAddress $ip_addr_v4

                        append intf_params " -ipv4_gateway $gw_ip_addr_v4 \
                                -ipv4_mask $mask_v4 -ipv4_address $ip_addr_v4 "
                    }
                }

                # Configure ATM parameters
                if {[info exists atm_encapsulation]} {
                    append intf_params " -atm_encap $atm_encapsulation "
                    interfaceEntry config -atmEncapsulation \
                            atmEncapsulationLLCBridgedEthernetFCS
                }
                if {[info exists atm_mode]} {
                    interfaceEntry config -atmMode atmBridged
                }
                if {[info exists atm_vpi]} {
                    append intf_params " -atm_vpi $atm_vpi "
                    interfaceEntry config -atmVpi $atm_vpi
                }
                if {[info exists atm_vci]} {
                    append intf_params " -atm_vci $atm_vci "
                    interfaceEntry config -atmVci $atm_vci
                }

                # Configure VLAN
                if {[info exists vlan_id]} {
                    interfaceEntry config -enableVlan   true
                    interfaceEntry config -vlanId       $vlan_id
                    interfaceEntry config -vlanPriority $vlan_user_priority

                    append intf_params " -vlan_id $vlan_id \
                            -vlan_priority $vlan_user_priority "
                }

                if {($ip_version == 4) || ($v4_exists && [package provide IxTclHal] < "5.60")} {
                    if {[interfaceEntry addItem addressTypeIpV4]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failure on call to\
                                interfaceEntry addItem addressTypeIpV4 on port\
                                $chasNum $cardNum $portNum."
                        return $returnList
                    }
                }

                if {($ip_version == 6) || ($v6_exists && [package provide IxTclHal] < "5.60")} {
                    if {[interfaceEntry addItem addressTypeIpV6]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failure on call to\
                                interfaceEntry addItem addressTypeIpV6 on port\
                                $chasNum $cardNum $portNum."
                        return $returnList
                    }
                }
                
                if {$ip_version == 4} {
                    if {$v6_exists} {
                        append intf_params " -ip_version 4_6 "
                    } else {
                        append intf_params " -ip_version 4 "
                    }
                } else {
                    if {$v4_exists} {
                        append intf_params " -ip_version 4_6 "
                    } else {
                        append intf_params " -ip_version 6 "
                    }
                }
                
                ## Add interface
                # Depends on IxOS version BUG537614
                set cmd ""
                if {[package provide IxTclHal] < "5.60"} {
                    if {[info exists type] && ($type == "routed")} {
                        set cmd "interfaceTable addInterface interfaceTypeRouted"
                    } else {
                        set cmd "interfaceTable addInterface"
                    }
                } else {
                    set cmd [list interfaceTable setInterface $interface_description]
                }


                if {[eval $cmd]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failure on call to interfaceTable\
                            addInterface on port $chasNum $cardNum $portNum."
                    return $returnList
                } else {
                    # Save the rest of the protocol interface information
                    if {$create_interface} {
                        append intf_params " -mode add "
                    } else {
                        append intf_params " -mode modify "
                    }
                    
                    if {[info exists type]} {
                        append intf_params " -type $type "
                    }
                
                    set retList [eval modify_protocol_interface_info \
                            $intf_params]
                    
                    if {[keylget retList status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failure to save interface\
                                information internally in data structures. [keylget retList log]"
                        return $returnList
                    }
                }
            }

            interfaceEntry clearAllItems addressTypeIpV4
            interfaceEntry clearAllItems addressTypeIpV6
            
            keylset returnList created 0
        }

        # Keep a list of the interfaces created to return to the user.
        lappend desc_list $interface_description
        
        # Handle the loopback address here
        if {$loopback_ip_address != "0.0.0.0" && $loopback_ip_address != "0::0"} {
            set intf_loop_list ""
            if {$gre_enable} {
                set gre_dst_ip_address_start $gre_dst_ip_address
            }
                
            if {[isIpAddressValid $loopback_ip_address]} {
                set unconnected_ip_version 4
            } else {
                set unconnected_ip_version 6
            }
            for {set loop_i 0} {$loop_i < $loopback_count} {incr loop_i} {
                # Check for interface existence
                set create_loopback 0
                set intf_existence_params "\
                        -port_handle     $chasNum/$cardNum/$portNum    \
                        -ip_version      $unconnected_ip_version       \
                        -ip_address      $loopback_ip_address          \
                        -gateway_address $ip_address                   \
                        -type            routed                        "
                
                
                set results [eval "::ixia::interface_exists $intf_existence_params"]
                set status [keylget results status]
                switch -- $status {
                    -1 {
                        # The call to interface exists failed, fail this too.
                        keylset returnList status $::FAILURE
                        keylset returnList log "The call to ::ixia::interface_exists\
                                failed.  Log: [keylget results log]"
                        return $returnList
                    }
                    0 {
                        set create_loopback 1
                    }
                    1 -
                    2 {
                        set loopback_description [keylget results description]
                        lappend loop_list      $loopback_description
                        lappend intf_loop_list $loopback_description
                    }
                    3 {
                        # Found the mac address on another interface on this port.
                        # Fail this because to create would mean one of them would
                        # have to be disabled, confusing for the user.
                        keylset returnList status $::FAILURE
                        keylset returnList log "Creating the loopback interface failed. \
                                An interface with this MAC address was found, but the\
                                IP address was different."
                        return $returnList
                    }
                    default {}
                }
                
                if {$create_loopback} {
                    set loopback_mac_address  $mac_address
                    set loopback_description [\
                            ::ixia::make_interface_description               \
                            $chasNum/$cardNum/$portNum $loopback_mac_address \
                            routed ]
                    
                    
                    # Configure the Loopback Interface
                    set intf_params "\
                            -port_handle $chasNum/$cardNum/$portNum   \
                            -description [list $loopback_description] "
                    # Configure IP table
                    if {$unconnected_ip_version == 4} {
                        interfaceIpV4  setDefault
                        # Configure the gateway Ip address only if it's the same version
                        # Otherwise the gateway will be configured with connectedVia
                        if {[isValidIPv4Address $ip_address]} {
                            interfaceIpV4  config -gatewayIpAddress $ip_address
                        }
                        interfaceIpV4  config -maskWidth 32
                        interfaceIpV4  config -ipAddress $loopback_ip_address
                        
                        append intf_params " -ipv4_gateway $ip_address \
                                -ipv4_mask 32 -ipv4_address $loopback_ip_address \
                                -ip_version 4 "
                    } elseif {$unconnected_ip_version == 6} {
                        interfaceIpV6  setDefault
                        interfaceIpV6  config -maskWidth 128
                        interfaceIpV6  config -ipAddress $loopback_ip_address
    
                        
                        
                        append intf_params " -ipv4_gateway $ip_address -ipv6_mask 64 \
                                -ipv6_address $loopback_ip_address -ip_version 6 "
                        
                    }

                    if {[interfaceEntry addItem addressTypeIpV$unconnected_ip_version]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failure on call to\
                                interfaceEntry addItem\
                                addressTypeIpV$unconnected_ip_version.  Port is\
                                $chasNum $cardNum $portNum."
                        return $returnList
                    }
                    interfaceEntry setDefault
                    interfaceEntry config -enable      true
                    interfaceEntry config -description $loopback_description
                    catch {interfaceEntry config -connectedVia \
                            $interface_description}
                    
                    # Add interface
                    if {[interfaceTable addInterface interfaceTypeRouted]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failure on call to interfaceTable\
                                addInterface on port $chasNum $cardNum $portNum. \
                                This is the loopback interface."
                        return $returnList
                    }
                    # Save the rest of the protocol interface information
                    append intf_params " -mode add -type routed"
                    
                    set retList [eval modify_protocol_interface_info \
                            $intf_params]
                    
                    if {[keylget retList status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failure to save loopback\
                                interface information internally in data\
                                structures. [keylget retList log]"
                        return $returnList
                    }
                    
                    lappend loop_list      $loopback_description
                    lappend intf_loop_list $loopback_description
                    
                    interfaceEntry clearAllItems addressTypeIpV$unconnected_ip_version
                }
                
                if {$gre_enable} {
                    set config_options "\
                            -port_handle             port_handle              \
                            -count                   gre_count                \
                            -ip_address              loopback_ip_address      \
                            -ip_address_step         gre_loopback_ip_address_step \
                            -gateway_ip_address      ip_address               \
                            -gateway_ip_address_step gre_ip_address_step      \
                            -ip_version              ip_version               \
                            -src_ip_address          loopback_ip_address      \
                            -dst_ip_address          gre_dst_ip_address       \
                            -src_ip_address_step     gre_loopback_ip_address_step  \
                            -dst_ip_address_step     gre_dst_ip_address_step  \
                            -gre_checksum_enable     gre_checksum_enable      \
                            -gre_seq_enable          gre_seq_enable           \
                            -gre_key_enable          gre_key_enable           \
                            -gre_key_in              gre_key_in               \
                            -gre_key_out             gre_key_out              \
                            -mac_address             mac_address              \
                            -no_write                no_write                 "
                    
                    ## passed in only those options that exists
                    set gre_vlan_id_step 0
                    set ipCheckList [list \
                            loopback_ip_address ip_address]
                    
                    foreach {ipCheck} $ipCheckList {
                        if {[info exists $ipCheck]} {
                            if {[isIpAddressValid [set $ipCheck]]} {
                                set gre_${ipCheck}_step 0.0.0.0
                            } else  {
                                set gre_${ipCheck}_step 0::0
                            }
                        }
                    }
                    
                    if {[info exists gre_src_ip_address]} {
                        if {[isIpAddressValid $gre_src_ip_address]} {
                            set gre_src_ip_address_step 0.0.0.0
                        } else  {
                            set gre_src_ip_address_step 0::0
                        }
                    }
                    
                    set config_param ""
                    foreach {option value_name} $config_options {
                        if {[info exists $value_name]} {
                            append config_param "$option [set $value_name] "
                        }
                    }
                    
                    set intf_status [eval ::ixia::gre_tunnel_config \
                            $config_param]
                    
                    if {[keylget intf_status status] == $::FAILURE} {
                        keylset returnList log "Failed in gre_tunnel_config\
                                call on port $chasNum $cardNum $portNum. \
                                [keylget intf_status log]"
                        keylset returnList status $::FAILURE
                        return $returnList
                    }
                    keylset returnList                                   \
                            $interface_description.$loopback_description \
                            [keylget intf_status description]
                    
                    if {[info exists gre_dst_ip_address]} {
                        if {$gre_unique} {
                            if {[isIpAddressValid $gre_dst_ip_address]} {
                                if {![info exists gre_dst_ip_address_step]} {
                                    set gre_dst_ip_address_step 0.0.0.1
                                }
                                for {set i 0} {$i < $gre_count} {incr i} {
                                    set gre_dst_ip_address      \
                                            [::ixia::increment_ipv4_address_hltapi \
                                            $gre_dst_ip_address \
                                            $gre_dst_ip_address_step]
                                }
                                
                            } else  {
                                if {![info exists ip_address_step]} {
                                    set gre_dst_ip_address_step 0::1
                                }
                                for {set i 0} {$i < $gre_count} {incr i} {
                                    set gre_dst_ip_address      \
                                            [::ixia::increment_ipv6_address_hltapi \
                                            $gre_dst_ip_address \
                                            $gre_dst_ip_address_step]
                                }
                            }
                        } else  {
                            set gre_dst_ip_address $gre_dst_ip_address_start
                        }
                    }
                }
                
                set loopback_ip_address [::ixia::increment_ipv${unconnected_ip_version}_address_hltapi\
                        $loopback_ip_address $loopback_ip_address_step]
                #
                # End of Configure the Loopback Interface in Protocol Server
                #########
            }
            keylset returnList $interface_description.loopback $intf_loop_list
        }
        
        #####
        # Increment Interface parameters

        # VLAN
        if {[info exists vlan_id] && ($vlan_id_mode == "increment")} {
            incr vlan_id $vlan_id_step
            set vlan_id [mpexpr $vlan_id % 4096]
        }
        
        # IP Address
        if {$ip_version == 4} {
            if {![info exists ip_address_step]} {
                set ip_address_step 0.0.1.0
            } else  {
                if {![::isIpAddressValid $ip_address_step]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid IPv4 interface ip\
                            address step."
                    return $returnList
                }
            }
            
            set ip_address [::ixia::increment_ipv4_address_hltapi $ip_address \
                    $ip_address_step]
            
            if {[info exists gateway_ip_address_step]} {
                set gateway_ip_address [::ixia::increment_ipv4_address_hltapi\
                        $gateway_ip_address $gateway_ip_address_step]
            }
            
        } else {
            if {![info exists ip_address_step]} {
                set ip_address_step 0::1
            } else  {
                if {![::ipv6::isValidAddress $ip_address_step]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid IPv6 interface ip\
                            address step."
                    return $returnList
                }
            }
            set ip_address [::ixia::increment_ipv6_address_hltapi $ip_address \
                    $ip_address_step]
            
            if {[info exists gateway_ip_address_step]} {
                set gateway_ip_address [::ixia::increment_ipv6_address_hltapi\
                        $gateway_ip_address $gateway_ip_address_step]
            }
        }

        # MAC Address
        if {$mac_address_exists} {
            set mac_address [::ixia::format_hex [mpexpr \
                    0x[join $mac_address ""] + 1] 48]
        }

        # ATM VPI/VCI
        if {[info exists atm_vpi]} {
            incr atm_vpi $atm_vpi_step
            set atm_vpi [mpexpr $atm_vpi % 256]
        }
        if {[info exists atm_vci]} {
            incr atm_vci $atm_vci_step
            set atm_vci [mpexpr $atm_vci % 65536]
        }
    }

    if {![info exists no_write]} {
        if {[ixWritePortsToHardware port_list]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure on call to ixWritePortsToHardware\
                    port_list, where port_list is $port_list."
            return $returnList
        }
    }

    keylset returnList status               $::SUCCESS
    keylset returnList description          $desc_list
    keylset returnList loopback_description $loop_list
    return  $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::gre_tunnel_config
#
# Description:
#    Configures GRE tunnel(s) in the Protocol Server
#
# Synopsis:
#    ::ixia::gre_tunnel_config
#
# Arguments:
#
# Return Values:
#    Keyed List of parameters from the Interface
#    status               $::SUCCESS
#    description: list of the itnerface description configured
#    ixia_ip    : list of IP address of the interfaces created
#    ::FAILURE or ::SUCCESS
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
proc ::ixia::gre_tunnel_config {args} {
    
    set procName [lindex [info level [info level]] 0]
    #debug "$procName $args"
        
    set mandatory_args {
        -port_handle                REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -ip_address                 IP
        -src_ip_address             IP
        -dst_ip_address             IP
        -ip_version                 CHOICES 4 6
        -count                      RANGE   1-4000
        -mac_address
    }

    set optional_args {
        -netmask                  DEFAULT 32
        -gateway_ip_address       ANY
        -gateway_ip_address_step  ANY
                                  DEFAULT 0.0.1.0
        -src_ip_address_step      IP
        -dst_ip_address_step      IP
        -ip_address_step          IP
        -gre_checksum_enable      CHOICES 0 1
                                  DEFAULT 0
        -gre_seq_enable           CHOICES 0 1
                                  DEFAULT 0
        -gre_key_enable           CHOICES 0 1
                                  DEFAULT 0
        -gre_key_in               RANGE 0-4294967295
                                  DEFAULT 0
        -gre_key_out              RANGE 0-4294967295
                                  DEFAULT 0
        -no_write
    }
    
    # gateway_ip_address and gateway_ip_address_step will not be configured anymore
    # they are properties that are not used for GRE
    
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
                    $mandatory_args -optional_args $optional_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing(::ixia::gre_tunnel_config). \
                $parse_error"
        return $returnList
    }
    
    set port_list [::ixia::format_space_port_list $port_handle]
    set interface [lindex $port_list 0]
    foreach {chasNum cardNum portNum} $interface {}
    
    if {[interfaceTable select $chasNum $cardNum $portNum]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failure on call to interfaceTable select\
                $chasNum $cardNum $portNum."
        return $returnList
    }
    
    set desc_list ""
    
    for {set intf_index 0} {$intf_index < $count} {incr intf_index} {
        
        if {$ip_version == 6} {
            set ip_address [::ipv6::expandAddress $ip_address]
        }
        
        # Check if interface already exists.  0 = do not create, 1 = create
        set create_interface 0
        
        set intf_existence "::ixia::interface_exists         \
                -port_handle     $chasNum/$cardNum/$portNum  \
                -ip_version      $ip_version                 \
                -ip_address      $ip_address                 \
                -type            gre                         \
                -ip_dst_address  $dst_ip_address             "
        
        set results [eval $intf_existence]
        
        set status  [keylget results status]
        switch -- $status {
            -1 {
                # The call to interface exists failed, fail this too.
                keylset returnList status $::FAILURE
                keylset returnList log "The call to ::ixia::interface_exists\
                        failed.  Log: [keylget results log]"
                return $returnList
            }
            0 {
                set create_interface 1
            }
            1 -
            2 {
                set interface_description [keylget results description]
            }
            3 {
                # Found the mac address on another interface on this port.
                # Fail this because to create would mean one of them would
                # have to be disabled, confusing for the user.
                keylset returnList status $::FAILURE
                keylset returnList log "Creating the protocol interface failed. \
                        An interface with this MAC address was found, but the\
                        IP address was different."
                return $returnList
            }
        }
        
        # If create_interface = 1, means that the interface must be created in
        # the Protocol Server
        if {$create_interface == 1} {
            interfaceEntry clearAllItems addressTypeIpV6
            interfaceEntry clearAllItems addressTypeIpV4
            
            interfaceIpV4 setDefault
            interfaceIpV6 setDefault
            
            set interface_description [::ixia::make_interface_description  \
                    $chasNum/$cardNum/$portNum $mac_address gre ]
            
            interfaceEntry setDefault
            
            array set greInterface [list \
                    enable             create_interface       \
                    description        interface_description  \
                    greSourceIpAddress src_ip_address         \
                    greDestIpAddress   dst_ip_address         \
                    enableGreChecksum  gre_checksum_enable    \
                    enableGreKey       gre_key_enable         \
                    enableGreSequence  gre_seq_enable         \
                    greInKey           gre_key_in             \
                    greOutKey          gre_key_out            \
                    ]
            
            foreach item [array names greInterface] {
                if {![catch {set $greInterface($item)} value] } {
                    if {[lsearch [array names enumList] $value] != -1} {
                        set value $enumList($value)
                    }
                    catch {interfaceEntry config -$item $value}
                }
            }
            
            # Configure IP table
            if {$ip_version == 4} {
                interfaceIpV4 config -maskWidth $netmask
                interfaceIpV4 config -ipAddress $ip_address
            } elseif {$ip_version == 6} {
                interfaceIpV6 config -maskWidth $netmask
                interfaceIpV6 config -ipAddress $ip_address
            }
            
            set retCode [interfaceEntry addItem addressTypeIpV$ip_version]
            if {$retCode != 0} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failure on call interfaceEntry\
                        addItem addressTypeIpV$ip_version.  Port is $chasNum\
                        $cardNum $portNum.  Return code was $retCode."
                return $returnList
            }
            # Set up a parameter list of the items required to save to
            # the protocol interface
            set intf_params "\
                    -port_handle      $chasNum/$cardNum/$portNum     \
                    -description      [list $interface_description]  \
                    -ipv4_dst_address $dst_ip_address                "
            if {$ip_version == 4} {
                append intf_params "\
                        -ipv4_address $ip_address         \
                        -ipv4_mask    $netmask            "
            } elseif {$ip_version == 6} {
                append intf_params "\
                        -ipv6_address $ip_address \
                        -ipv6_mask    $netmask    "
            }
            
            # Add interface
            if {[interfaceTable addInterface interfaceTypeGre]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failure to interfaceTable addInterface\
                        interfaceTypeGre on port $chasNum $cardNum $portNum."
                return $returnList
            } else {
                # Save the rest of the protocol interface information
                if {$create_interface} {
                    append intf_params " -mode add "
                } else {
                    append intf_params " -mode modify "
                }
                append intf_params " -type gre "
                set retList [eval modify_protocol_interface_info $intf_params]
                
                if {[keylget retList status] == $::FAILURE} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failure to save interface\
                            information internally in data structures. [keylget retList log]"
                    return $returnList
                }
            }
            interfaceEntry clearAllItems addressTypeIpV$ip_version
            
        } else {
            
            if {[interfaceTable select $chasNum $cardNum $portNum]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failure on call to interfaceTable\
                        select $chasNum $cardNum $portNum."
            }
            
            # Add the configuration to a current interface, possibly a
            # dual-stack (v4v6).  Cannot use the direct getInterface call.
            # Must step thru using getFirst, getNext, limitation in IxTclHal.
            set results [::ixia::get_interface_by_description \
                    $chasNum $cardNum $portNum $interface_description]
            
            if {[keylget results status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failure finding interface by\
                        description on port.  Log : [keylget results log]"
                return $returnList
            }
            
            # Get what is configured in the interface.  Need this information
            # to re-create it.
            set v4_exists 0
            set v6_exists 0
            
            if {![interfaceEntry getFirstItem  $::addressTypeIpV4]} {
                set mask_v4       [interfaceIpV4 cget -maskWidth]
                set ip_addr_v4    [interfaceIpV4 cget -ipAddress]
                set v4_exists 1
            }
            
            if {![interfaceEntry getFirstItem  $::addressTypeIpV6]} {
                set mask_v6    [interfaceIpV6 cget -maskWidth]
                set ip_addr_v6 [interfaceIpV6 cget -ipAddress]
                set v6_exists 1
            }
            
            # Only need to delete/recreate the interface if we are making
            # it into an IPv4/IPv6 combined interface
            if {(($ip_version == 4) && $v6_exists) || \
                    (($ip_version == 6) && $v4_exists) || \
                    (($ip_version != 0) && !$v4_exists && !$v6_exists)} {
                
                ## Delete the interface to recreate it below
                if {[interfaceTable delInterface $interface_description]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failure on call to interfaceTable\
                            delInterface $interface_description on port\
                            $chasNum $cardNum $portNum."
                    return $returnList
                }
                interfaceEntry clearAllItems addressTypeIpV6
                interfaceEntry clearAllItems addressTypeIpV4
                
                set intf_params " -port_handle $chasNum/$cardNum/$portNum \
                        -description [list $interface_description] "
                
                # Configure IP table
                if {$ip_version == 4} {
                    interfaceIpV4  setDefault
                    interfaceIpV4  config -maskWidth $netmask
                    interfaceIpV4  config -ipAddress $ip_address
                    
                    append intf_params " -ipv4_mask $netmask -ipv4_address $ip_address "
                    
                    if {$v6_exists} {
                        interfaceIpV6  setDefault
                        interfaceIpV6  config -maskWidth $mask_v6
                        interfaceIpV6  config -ipAddress $ip_addr_v6
                        
                        append intf_params " -ipv6_mask $mask_v6 \
                                -ipv6_address $ip_addr_v6 "
                    }
                    
                } elseif {$ip_version == 6} {
                    interfaceIpV6  setDefault
                    interfaceIpV6  config -maskWidth $netmask
                    interfaceIpV6  config -ipAddress $ip_address
                    
                    append intf_params " -ipv6_mask $netmask \
                            -ipv6_address $ip_address "
                    
                    if {$v4_exists} {
                        interfaceIpV4  setDefault
                        interfaceIpV4  config -maskWidth $mask_v4
                        interfaceIpV4  config -ipAddress $ip_addr_v4
                        
                        append intf_params " -ipv4_gateway $gw_ip_addr_v4 \
                                -ipv4_mask $mask_v4 -ipv4_address $ip_addr_v4 "
                    }
                }
                
                if {($ip_version == 4) || $v4_exists} {
                    if {[interfaceEntry addItem addressTypeIpV4]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failure on call to\
                                interfaceEntry addItem addressTypeIpV4 on port\
                                $chasNum $cardNum $portNum."
                        return $returnList
                    }
                }
                
                if {($ip_version == 6) || $v6_exists} {
                    if {[interfaceEntry addItem addressTypeIpV6]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failure on call to\
                                interfaceEntry addItem addressTypeIpV6 on port\
                                $chasNum $cardNum $portNum."
                        return $returnList
                    }
                }
                
                ## Add interface
                if {[interfaceTable addInterface interfaceTypeGre]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to interfaceTable addInterface\
                            interfaceTypeGre on port $chasNum $cardNum $portNum."
                    return $returnList
                } else {
                    # Save the rest of the protocol interface information
                    if {$create_interface} {
                        append intf_params " -mode add "
                    } else {
                        append intf_params " -mode modify "
                    }
                    append intf_params " -type gre "
                    set retList [eval modify_protocol_interface_info \
                            $intf_params]
                    
                    if {[keylget retList status] == $::FAILURE} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failure to save interface\
                                information internally in data structures. [keylget retList log]"
                        return $returnList
                    }
                }
            }
            
            interfaceEntry clearAllItems addressTypeIpV4
            interfaceEntry clearAllItems addressTypeIpV6
        }
        
        # Keep a list of the interfaces created to return to the user.
        lappend desc_list $interface_description
        
        
        #####
        # Increment Interface parameters
        
        # IP Address
        set ipCheckList [list \
                ip_address src_ip_address dst_ip_address gateway_ip_address]
        
        foreach {ipCheck} $ipCheckList {
            if {[info exists $ipCheck]} {
                if {[isIpAddressValid [set $ipCheck]]} {
                    if {![info exists ${ipCheck}_step]} {
                        set ${ipCheck}_step 0.0.0.1
                    }
                    set $ipCheck [::ixia::increment_ipv4_address_hltapi \
                            [set $ipCheck]  [set ${ipCheck}_step]]
                    
                } else  {
                    if {![info exists ${ipCheck}_step]} {
                        set ${ipCheck}_step 0::1
                    }
                    set $ipCheck [::ixia::increment_ipv6_address_hltapi \
                            [set $ipCheck]  [set ${ipCheck}_step]]
                }
            }
        }
    }
    
    if {![info exists no_write]} {
        if {[ixWritePortsToHardware port_list]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failure on call to ixWritePortsToHardware\
                    port_list, where port_list is $port_list."
            return $returnList
        }
    }
    
    keylset returnList status               $::SUCCESS
    keylset returnList description          $desc_list
    return  $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::reset_protocol_interface_for_port
#
# Description:
#    Deletes all of the information in the protocol interface array for a 
#    given port.
#
# Synopsis:
#    ::ixia::reset_protocol_interface_for_port
#        -port_handle
#
# Arguments:
#
# Return Values:
#    A keyed list
#    key: status     value: $::SUCCESS or $::FAILURE
#    key: log        value: If $::FAILURE, then returns more information
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
proc ::ixia::reset_protocol_interface_for_port { args } {

    set mandatory_args {
        -port_handle REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
    }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $mandatory_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing.  $parse_error"
        return $returnList
    }

    set temp_port [split $port_handle /]
    foreach {chasNum cardNum portNum} $temp_port {}
    
    set resList [rfremove_all_interfaces_from_port $port_handle]
            
    # Clean up the various arrays for the individual protocols
    # BGP
    ::ixia::updateBgpHandleArray -mode reset -port_handle $port_handle

    # IGMP
    ::ixia::igmp_clear_all_hosts $chasNum $cardNum $portNum

    # ISIS
    ::ixia::updateIsisHandleArray reset $port_handle
    
    # LACP
    ::ixia::updateLacpHandleArray reset $port_handle
    
    # LDP
    ::ixia::updateLdpHandleArray reset $port_handle

    # MLD
    ::ixia::updateMldHandleArray -mode delete -port [list $chasNum $cardNum \
            $portNum]

    # OSPF
    ::ixia::updateOspfHandleArray reset $port_handle NULL ospfv2
    ::ixia::updateOspfHandleArray reset $port_handle NULL ospfv3

    # PIM
    ::ixia::updatePimsmHandleArray -mode reset -handle_name_pattern $port_handle

    # RSVP
    ::ixia::updateRsvpHandleArray -mode reset -handle_value $port_handle
    if {[info exists ::ixia::rsvp_tunnel_parameters]} {
        unset ::ixia::rsvp_tunnel_parameters
    }
    array set ::ixia::rsvp_tunnel_parameters {}
    
    # RIP
    ::ixia::ripClearAllRouters $chasNum $cardNum $portNum
    
    # L2TPv3
    ::ixia::updateL2tpv3CcHandleArray -mode delete -port $port_handle
    
    # DHCP
    ::ixia::resetDhcpHandleArray reset $port_handle ""
    
    # ANCP
    catch {array unset ::ixia::ancp_profile_handles_array}
    array set ::ixia::ancp_profile_handles_array ""
    
    keylset returnList status $::SUCCESS
    return  $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::get_next_interface_handle
#
# Description:
#    Gets the next interface handle value to be used in this session
#
# Synopsis:
#    ::ixia::get_next_interface_handle
#
# Arguments:
#
# Return Values:
#    The next interface handle name to use
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
proc ::ixia::get_next_interface_handle { args } {
    variable interface_handle

    set handle intf$interface_handle
    incr interface_handle
    return $handle
}

proc ::ixia::protocol_interfaces_operation {args} {
    variable cmdProtIntfParamsPositions
    variable pa_mac_idx
    variable pa_ip_idx
    variable pa_inth_idx
    variable pa_descr_idx
    
    # pa_mac_idx stands for protocol interfaces array indexed by mac
    # pa_ip_idx stands for protocol interfaces array indexed by ip
    # pa_inth_idx stands for protocol interaces array indexed by interface_handle
    # pa_descr_idx stands for protocol interaces array indexed by interface description
    # sl_* variables stand for 'sub_list'. Because values at array indexes are actually lists of
    #       interfaces that match that index
    
    set procName [lindex [info level [info level]] 0]
    debug "$procName $args"
        
    set mandatory_args {
        -reg
    }
    
    set optional_args {
        -operation                DEFAULT ""
        -ip_version               CHOICES 4 6 46 0
        -ret_type                 CHOICES value
                                  DEFAULT value
    }
    
    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
                    $mandatory_args -optional_args $optional_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing(::ixia::protocol_interfaces_operation). \
                $parse_error"
        return $returnList
    }
    
    set retIndicesList ""
    set retValuesList  ""
    
    # sl_* stands for sub list (see start of procedure for more details)
    set sl_reg_split   [split $reg ,]
    set sl_port_handle [lindex $sl_reg_split $cmdProtIntfParamsPositions(port_handle)]
    set sl_intf_type   [lindex $sl_reg_split $cmdProtIntfParamsPositions(type)]
    set sl_mac_address [lindex $sl_reg_split $cmdProtIntfParamsPositions(mac_address)]
    set sl_ipv4_addr   [lindex $sl_reg_split $cmdProtIntfParamsPositions(ipv4_address)]
    set sl_ipv6_addr   [lindex $sl_reg_split $cmdProtIntfParamsPositions(ipv6_address)]
    
    if {[isValidMacAddress $sl_mac_address]} {
        regsub -all { } $sl_mac_address {\ } sl_mac_address
    } else {
        set sl_mac_address "(.*)"
    }
    
    if {![info exists ip_version]} {
        # Auto detect ip_version
        # Try to search in the array indexed by IP
        if {[isValidIPAddress $sl_ipv4_addr]} {
            # sl_ip_address will be the index that we'll search by
            set sl_ip_address $sl_ipv4_addr
            set sl_ip_version 4
            set array_to_search_in "pa_ip_idx"
        }
        
        if {[isValidIPAddress $sl_ipv6_addr]} {
            if {[info exists sl_ip_version] && $sl_ip_version == 4} {
                set sl_ip_version 46
                set array_to_search_in "pa_ip_idx"
            } else {
                set sl_ip_address $sl_ipv6_addr
                set sl_ip_version 6
                set array_to_search_in "pa_ip_idx"
            }
        }
        
        if {![info exists sl_ip_version]} {
            # IP version could not be detected (ipv4 and ipv6 addresses were not specified as search criteria)
            # We will search the mac indexed array

            set array_to_search_in "pa_mac_idx"
            set sl_ip_version      "(.*)"
            
        }
    } else {
        # An interface with a specific ip version will be searched
        set sl_ip_version $ip_version
        switch -- $sl_ip_version {
            4 {
                if {[isValidIPAddress $sl_ipv4_addr]} {
                    # Searching for an IPv4 interface having $sl_ipv4_addr address
                    set sl_ip_address $sl_ipv4_addr
                    set array_to_search_in "pa_ip_idx"
                } else {
                    # Searching for an IPv4 interface but ipv4 address was not specified
                    # It's better to search the mac indexed array (because the ip indexed array might contain duplicat entries for dual stack interfaces)
                    set sl_ip_address "(.*)"
                    set array_to_search_in "pa_mac_idx"
                }
            }
            6 {
                if {[isValidIPAddress $sl_ipv6_addr]} {
                    # Searching for an IPv6 interface having $sl_ipv6_addr address
                    set sl_ip_address $sl_ipv6_addr
                    set array_to_search_in "pa_ip_idx"
                } else {
                    # Searching for an IPv6 interface but ipv6 address was not specified
                    # It's better to search the mac indexed array (because the ip indexed array might contain duplicat entries for dual stack interfaces)
                    set sl_ip_address "(.*)"
                    set array_to_search_in "pa_mac_idx"
                }
            }
            46 {
                if {[isValidIPAddress $sl_ipv4_addr]} {
                    # Searching for a dual stack interface having $sl_ipv4_addr address
                    set sl_ip_address $sl_ipv4_addr
                    set array_to_search_in "pa_ip_idx"
                } elseif {[isValidIPAddress $sl_ipv6_addr]} {
                    # Searching for a dual stack interface having $sl_ipv6_addr address
                    set sl_ip_address $sl_ipv6_addr
                    set array_to_search_in "pa_ip_idx"
                } else {
                    # Searching for a dual stack interface but ipv6 and ipv4 address were not specified
                    # It's better to search the mac indexed array (because the ip indexed array might contain duplicat entries for dual stack interfaces)
                    set sl_ip_address "(.*)"
                    set array_to_search_in "pa_mac_idx"
                }
            }
            0 {
                # Searching for a mac only interface. Search the mac indexed array
                set sl_ip_address "(.*)"
                set array_to_search_in "pa_mac_idx"
            }
        }
    }
    
    switch -- $array_to_search_in {
        "pa_mac_idx" {
            set sl_variables {sl_port_handle sl_intf_type sl_mac_address}
        }
        "pa_ip_idx" {
            set sl_variables {sl_port_handle sl_intf_type sl_ip_address}
        }
    }
    
    # Build the search_by index
    set array_search_index ""
    
    foreach sl_variable $sl_variables {
        append array_search_index "[set $sl_variable],"
    }
    
    set matched_indexes ""
    
    # If we have all the search data available except for sl_ip_version it's
    # better to do info exists for each sl_ip_version than to do array names
    if {[string first * $array_search_index] == -1} {
        if {[string first * $sl_ip_version] != -1} {
            foreach tmp_val {4 6 46 0} {
                set search_cmd "info exists [subst $array_to_search_in](${array_search_index}${tmp_val})"
                debug $search_cmd
                if {[eval $search_cmd]} {
                    set tmp_cmd "lappend matched_indexes ${array_search_index}${tmp_val}"
                    debug $tmp_cmd
                    eval $tmp_cmd
                }
            }
        } elseif {$sl_ip_version == 4} {
            foreach tmp_val {4 46} {
                set search_cmd "info exists [subst $array_to_search_in](${array_search_index}${tmp_val})"
                debug $search_cmd
                if {[eval $search_cmd]} {
                    set tmp_cmd "lappend matched_indexes ${array_search_index}${tmp_val}"
                    debug $tmp_cmd
                    eval $tmp_cmd
                }
            }
        } elseif {$sl_ip_version == 6} {
            foreach tmp_val {6 46} {
                set search_cmd "info exists [subst $array_to_search_in](${array_search_index}${tmp_val})"
                debug $search_cmd
                if {[eval $search_cmd]} {
                    set tmp_cmd "lappend matched_indexes ${array_search_index}${tmp_val}"
                    debug $tmp_cmd
                    eval $tmp_cmd
                }
            }
        } else {
            append array_search_index $sl_ip_version
            set search_cmd "info exists [subst $array_to_search_in]($array_search_index)"
            debug $search_cmd
            if {[eval $search_cmd]} {
                set matched_indexes $array_search_index
            }
        }
    } else {
        
        append array_search_index $sl_ip_version
    
        set search_cmd "array names $array_to_search_in -regexp ($array_search_index)"
        
        set matched_indexes [eval $search_cmd]
        debug "$search_cmd -> returned [llength $matched_indexes] results"
    }
    
    foreach prot_intf_idx $matched_indexes {
        set sub_list [set [subst $array_to_search_in]($prot_intf_idx)]
        
        set adjust_index_by 0
        
        foreach {intf_h} $sub_list {
            set elem [rfget_interface_details_by_handle $intf_h]
            
            if {![regexp $reg $elem]} {
                continue
            }
            
            lappend retValuesList  $elem

            switch -- $operation {
                delete {
                    # Not supported anymore/obsolete
                }
                default {
                }
            }
        }
    }
    
    if {[llength $retValuesList] > 0} {
        return $retValuesList
    }
    
    
    # If this code is reached it means that regex didn't match any of the
    # interfaces from matched_indexes
    # In this case i'll remove the restriction on ipv4_gateway and ipv6_gateway
    # because they're not mandatory. If we found an interface that is identical
    # except for the gateway, the desired behavior is to change the gateway, so we 
    # have to report the interface found (BUG633350)
    set reg_spaced [split $reg ,]
    set reg_any_gw_spaced ""
    set reg_gw_v4  [lindex $reg_spaced $cmdProtIntfParamsPositions(ipv4_gateway)]
    set reg_gw_v6  [lindex $reg_spaced $cmdProtIntfParamsPositions(ipv6_gateway)]
    if {[string first * $reg_gw_v4] == -1} {
        set reg_any_gw_spaced [lreplace $reg_spaced          \
                $cmdProtIntfParamsPositions(ipv4_gateway)   \
                $cmdProtIntfParamsPositions(ipv4_gateway)   \
                (.*)]
    }
    
    if {[string first * $reg_gw_v6] == -1} {
        set reg_any_gw_spaced [lreplace $reg_spaced          \
                $cmdProtIntfParamsPositions(ipv6_gateway)   \
                $cmdProtIntfParamsPositions(ipv6_gateway)   \
                (.*)]
    }
    
    set reg_any_gw [join $reg_any_gw_spaced ,]
    
    if {$reg_any_gw == ""} {
        return $retValuesList
    }
    
    foreach prot_intf_idx $matched_indexes {
        set sub_list [set [subst $array_to_search_in]($prot_intf_idx)]
        
        set adjust_index_by 0
        
        foreach {intf_h} $sub_list {
            set elem [rfget_interface_details_by_handle $intf_h]
            
            if {![regexp $reg_any_gw $elem]} {
                continue
            }
            
            lappend retValuesList  $elem

            switch -- $operation {
                delete {
                    # Not supported anymore/obsolete
                }
                default {
                }
            }
        }
    }
    
    return $retValuesList    
}


proc ::ixia::protocol_interface_config_advanced {args} {
    
    keylset returnList status $::SUCCESS
    
    set procName [lindex [info level [info level]] 0]
    #debug "$procName $args"
    
    set man_args {
        -port_handle REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -ip_address  IP
        -ip_version  CHOICES 4 6
    }

    set opt_args {
        -atm_encapsulation        CHOICES vc_mux_ipv4_routed vc_mux_ipv6_routed
                                  CHOICES llc_bridge_ethernet_fcs 
                                  CHOICES vc_mux_bridged_ethernet_fcs
                                  CHOICES vc_mux_bridged_ethernet_no_fcs
                                  CHOICES vc_mux_mpls_routed
                                  CHOICES llc_bridge_ethernet_no_fcs llc_pppoa
                                  CHOICES vcc_mux_pppoa llc_nlpid_routed
        -atm_mode                 CHOICES routed bridged
        -atm_vci                  RANGE   0-65535
        -atm_vci_step             RANGE   0-65535
                                  DEFAULT 1
        -atm_vpi                  RANGE   0-255
        -atm_vpi_step             RANGE   0-255
                                  DEFAULT 1
        -count                    RANGE   1-10000
                                  DEFAULT 1
        -gateway_ip_address       IP
        -gateway_ip_address_step  IP
        -ip_address_step          IP
        -mac_address
        -mac_address_step
        -mtu
        -netmask
        -vlan_id                  RANGE   0-4096
        -vlan_id_mode             CHOICES fixed increment
                                  DEFAULT increment
        -vlan_id_step             RANGE   0-4096
                                  DEFAULT 0
        -vlan_user_priority       RANGE   0-7
                                  DEFAULT 0
        -no_write
        -gre_enable               CHOICES 0 1
                                  DEFAULT 0
        -gre_unique               CHOICES 0 1
                                  DEFAULT 1
        -gre_dst_ip_addr          IP
        -gre_count                NUMERIC
                                  DEFAULT 1
        -gre_checksum_enable      CHOICES 0 1
                                  DEFAULT 0
        -gre_seq_enable           CHOICES 0 1
                                  DEFAULT 0
        -gre_key_enable           CHOICES 0 1
                                  DEFAULT 0
        -gre_key_in               RANGE 0-4294967295
                                  DEFAULT 0
        -gre_key_out              RANGE 0-4294967295
                                  DEFAULT 0
        -type                     CHOICES connected routed
        -gre_ip_addr                     IP
        -gre_ip_addr_step                IP
                                         DEFAULT 0.0.1.0
        -gre_ip_addr_lstep               IP
        -gre_ip_addr_cstep               IP
        -gre_ip_prefix_length            RANGE   1-128
        -gre_dst_ip_addr_step            IP
        -gre_dst_ip_addr_lstep           IP
        -gre_dst_ip_addr_cstep           IP
        -gre_key_in_step                 RANGE 0-4294967295
                                         DEFAULT 0
        -gre_key_out_step                RANGE 0-4294967295
                                         DEFAULT 0
        -gre_src_ip_addr_mode            CHOICES routed connected
                                         DEFAULT connected
        -loopback_count                  NUMERIC
                                         DEFAULT 0
        -loopback_ip_address             IP
        -loopback_ip_address_step        IP
        -loopback_ip_address_cstep       IP
    }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args \
            $man_args -optional_args $opt_args} parse_error]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed on parsing.  $parse_error"
        return $returnList
    }
    
    # This variable will determine on which interface configuration call the write to hardware
    # will be done
    set commit_when "connected"
    
    if {[info exists mac_address]} {
        if {![isValidMacAddress $mac_address]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Invalid MAC address '$mac_address' for parameter -mac_address."
            return $returnList
        }
        
        set mac_address [ixNetworkFormatMac $mac_address]
    }
    
    if {[info exists mac_address_step]} {
        if {![isValidMacAddress $mac_address_step]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Invalid MAC address '$mac_address_step' for parameter -mac_address_step."
            return $returnList
        }
    } else {
        set mac_address_step 00:00:00:00:00:01
    }
    
    set mac_address_step [ixNetworkFormatMac $mac_address_step]
    
    # Set default parameters' values
    if {![info exists gateway_address_step]} {
        if {$ip_version == 4} {
            set gateway_address_step 0.0.1.0
        } else {
            set gateway_address_step 0000:0000:0000:0001:0000:0000:0000:0000
        }
    }
    
    for {set intf_connected_idx 0} {$intf_connected_idx < $count} {incr intf_connected_idx} {
        
        set connected_intf_args {
            port_handle
            ip_address
            ip_version
            atm_encapsulation
            atm_vci
            atm_vpi
            gateway_ip_address
            mac_address
            mtu
            netmask
            vlan_id
            vlan_user_priority
        }
        
        if {[info exists loopback_count] && $loopback_count > 0} {
            
            set commit_when "connected_loopback"
            
            if {![info exists loopback_ip_address]} {
                switch -- $ip_version {
                    4 {
                        set loopback_ip_address 0.0.0.0
                        set lo_ip_version 4
                    }
                    6 {
                        set loopback_ip_address 0::0
                        set lo_ip_version 6
                    }
                }
            } else {
                if {[::ipv6::isValidAddress $loopback_ip_address]} {
                    set lo_ip_version 6
                } else {
                    set lo_ip_version 4
                }
            }
            
            if {$lo_ip_version == 4} {
                
                if {![info exists loopback_ip_address_step]} {
                    set loopback_ip_address_step 0.0.0.1
                } elseif {![isValidIPv4Address $loopback_ip_address_step]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value for loopback_ip_address_step\
                            '$loopback_ip_address_step'. Please provide a valid IPv4 address."
                    return $returnList
                }
                
                if {![info exists loopback_ip_address_cstep]} {
                    set loopback_ip_address_cstep $loopback_ip_address_step
                } elseif {![isValidIPv4Address $loopback_ip_address_cstep]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value for loopback_ip_address_cstep\
                            '$loopback_ip_address_cstep'. Please provide a valid IPv4 address."
                    return $returnList
                }
                
            } else {
                if {![info exists loopback_ip_address_step]} {
                    set loopback_ip_address_step 0::1
                } elseif {![::ipv6::isValidAddress $loopback_ip_address_step]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value for loopback_ip_address_step\
                            '$loopback_ip_address_step'. Please provide a valid IPv6 address."
                    return $returnList
                }
                
                if {![info exists loopback_ip_address_cstep]} {
                    set loopback_ip_address_cstep $loopback_ip_address_step
                } elseif {![::ipv6::isValidAddress $loopback_ip_address_cstep]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value for loopback_ip_address_cstep\
                            '$loopback_ip_address_cstep'. Please provide a valid IPv6 address."
                    return $returnList
                }
            }
            set tmp_loopback_ip_address $loopback_ip_address
        }
        
        # Create GRE Interfaces if necessary
        if {$gre_enable && $gre_count > 0} {
            if {$gre_src_ip_addr_mode == "routed" && [info exists loopback_count] && $loopback_count > 0} {
                if {$commit_when == "connected_loopback"} {
                    set commit_when "connected_gre_routed_loopback"
                } else {
                    set commit_when "connected_gre_routed"
                }
                set global_ip_version $lo_ip_version
            } else {
                if {$commit_when == "connected_loopback"} {
                    set commit_when "connected_gre_connected_loopback"
                } else {
                    set commit_when "connected_gre_connected"
                }
                set global_ip_version $ip_version
            }
            
            if {![info exists gre_ip_addr]} {
                switch -- $global_ip_version {
                    4 {
                        set gre_ip_addr 0.0.0.0
                        set gre_ip_version 4
                    }
                    6 {
                        set gre_ip_addr 0::0
                        set gre_ip_version 6
                    }
                }
            } else {
                if {[::ipv6::isValidAddress $gre_ip_addr]} {
                    set gre_ip_version 6
                } else {
                    set gre_ip_version 4
                }
            }
            
            if {$gre_ip_version == 4} {
                if {![info exists gre_ip_addr_step]} {
                    set gre_ip_addr_step 0.0.0.1
                } elseif {![isValidIPv4Address $gre_ip_addr_step]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value for gre_ip_addr_step\
                            '$gre_ip_addr_step'. Please provide a valid IPv4 address."
                    return $returnList
                }
                
                if {![info exists gre_ip_addr_cstep]} {
                    set gre_ip_addr_cstep $gre_ip_addr_step
                } elseif {![isValidIPv4Address $gre_ip_addr_cstep]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value for gre_ip_addr_cstep\
                            '$gre_ip_addr_cstep'. Please provide a valid IPv4 address."
                    return $returnList
                }
                
                if {![info exists gre_ip_addr_lstep]} {
                    set gre_ip_addr_lstep $gre_ip_addr_step
                } elseif {![isValidIPv4Address $gre_ip_addr_lstep]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value for gre_ip_addr_lstep\
                            '$gre_ip_addr_lstep'. Please provide a valid IPv4 address."
                    return $returnList
                }
                
            } else {
            
                if {![info exists gre_ip_addr_step]} {
                    set gre_ip_addr_step 0::1
                } elseif {![::ipv6::isValidAddress $gre_ip_addr_step]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value for gre_ip_addr_step\
                            '$gre_ip_addr_step'. Please provide a valid IPv6 address."
                    return $returnList
                }
                
                if {![info exists gre_ip_addr_cstep]} {
                    set gre_ip_addr_cstep $gre_ip_addr_step
                } elseif {![::ipv6::isValidAddress $gre_ip_addr_cstep]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value for gre_ip_addr_cstep\
                            '$gre_ip_addr_cstep'. Please provide a valid IPv6 address."
                    return $returnList
                }
                
                if {![info exists gre_ip_addr_lstep]} {
                    set gre_ip_addr_lstep $gre_ip_addr_step
                } elseif {![::ipv6::isValidAddress $gre_ip_addr_lstep]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value for gre_ip_addr_lstep\
                            '$gre_ip_addr_lstep'. Please provide a valid IPv6 address."
                    return $returnList
                }
            }
            
            set tmp_gre_ip_address $gre_ip_addr
            set tmp_gre_lo_ip_address $gre_ip_addr
            
            if {$global_ip_version == 4} {
            
                if {![info exists gre_dst_ip_addr]} {
                    set gre_dst_ip_addr 0.0.0.0
                } elseif {![isValidIPv4Address $gre_dst_ip_addr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value for gre_dst_ip_addr\
                            '$gre_dst_ip_addr'. Please provide a valid IPv4 address."
                    return $returnList
                }
                
                if {![info exists gre_dst_ip_addr_step]} {
                    set gre_dst_ip_addr_step 0.0.0.1
                } elseif {![isValidIPv4Address $gre_dst_ip_addr_step]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value for gre_dst_ip_addr_step\
                            '$gre_dst_ip_addr_step'. Please provide a valid IPv4 address."
                    return $returnList
                }
                
                if {![info exists gre_dst_ip_addr_cstep]} {
                    set gre_dst_ip_addr_cstep $gre_dst_ip_addr_step
                } elseif {![isValidIPv4Address $gre_dst_ip_addr_cstep]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value for gre_dst_ip_addr_cstep\
                            '$gre_dst_ip_addr_cstep'. Please provide a valid IPv4 address."
                    return $returnList
                }
                
                if {![info exists gre_dst_ip_addr_lstep]} {
                    set gre_dst_ip_addr_lstep $gre_dst_ip_addr_step
                } elseif {![isValidIPv4Address $gre_dst_ip_addr_lstep]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value for gre_dst_ip_addr_lstep\
                            '$gre_dst_ip_addr_lstep'. Please provide a valid IPv4 address."
                    return $returnList
                }
                
            } else {
                
                if {![info exists gre_dst_ip_addr]} {
                    set gre_dst_ip_addr 0:::0
                } elseif {![::ipv6::isValidAddress $gre_dst_ip_addr]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value for gre_dst_ip_addr\
                            '$gre_dst_ip_addr'. Please provide a valid IPv6 address."
                    return $returnList
                }
                
                if {![info exists gre_dst_ip_addr_step]} {
                    set gre_dst_ip_addr_step 0::1
                } elseif {![::ipv6::isValidAddress $gre_dst_ip_addr_step]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value for gre_dst_ip_addr_step\
                            '$gre_dst_ip_addr_step'. Please provide a valid IPv6 address."
                    return $returnList
                }
                
                if {![info exists gre_dst_ip_addr_cstep]} {
                    set gre_dst_ip_addr_cstep $gre_dst_ip_addr_step
                } elseif {![::ipv6::isValidAddress $gre_dst_ip_addr_cstep]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value for gre_dst_ip_addr_cstep\
                            '$gre_dst_ip_addr_cstep'. Please provide a valid IPv6 address."
                    return $returnList
                }
                
                if {![info exists gre_dst_ip_addr_lstep]} {
                    set gre_dst_ip_addr_lstep $gre_dst_ip_addr_step
                } elseif {![::ipv6::isValidAddress $gre_dst_ip_addr_lstep]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid value for gre_dst_ip_addr_lstep\
                            '$gre_dst_ip_addr_lstep'. Please provide a valid IPv6 address."
                    return $returnList
                }
                
            }
            
            set tmp_gre_dst_ip_address $gre_dst_ip_addr
            set tmp_gre_dst_lo_ip_address $gre_dst_ip_addr
            
        }
        
        if {[info exists loopback_count] && $loopback_count > 0} {
            
            # We should append the loopback parameters
            for {set lo_connected_idx 0} {$lo_connected_idx < $loopback_count} {incr lo_connected_idx} {
                
                set lo_intf_args {
                    loopback_ip_address         tmp_loopback_ip_address
                }
    
                # Append the loopback parameters to the call list
                set prot_intf_cmd "protocol_interface_config"
                foreach con_param $connected_intf_args {
                    if {[info exists $con_param]} {
                        lappend prot_intf_cmd -$con_param [set $con_param]
                    }
                }
                
                foreach {lo_param lo_param_var} $lo_intf_args {
                    if {[info exists $lo_param_var]} {
                        lappend prot_intf_cmd -$lo_param [set $lo_param_var]
                    }
                }
                
                # Decide if we should append no_write
                if {[info exists no_write] || \
                        ($commit_when == "connected_loopback" && ([expr $lo_connected_idx + 1] < $loopback_count ||\
                                [expr $intf_connected_idx + 1] < $count)) || ($commit_when != "connected_loopback")} {
                    lappend prot_intf_cmd -no_write
                }
                
                set intf_status [eval $prot_intf_cmd]
                if {[keylget intf_status status] != $::SUCCESS} {
                    return $intf_status
                }
                
                # Take the keyed values and integrate them into returnList
                set tmp_con_description [keylget intf_status description]
                set tmp_loo_description [keylget intf_status loopback_description]
                
                if {[catch {keylget returnList description} current_descriptions]} {
                    
                    keylset returnList description                      [list $tmp_con_description]
                    keylset returnList loopback_description             [list $tmp_loo_description]
                    keylset returnList ${tmp_con_description}.loopback  [list $tmp_loo_description]
                    
                } else {
                    
                    if {[lsearch $current_descriptions $tmp_con_description] == -1} {
                        lappend current_descriptions $tmp_con_description
                        keylset returnList description $current_descriptions
                    }
                }
                
                if {[catch {keylget returnList loopback_description} current_lo_descriptions]} {
                    keylset returnList loopback_description [list $tmp_loo_description]
                } else {
                    if {[lsearch $current_lo_descriptions $tmp_loo_description] == -1} {
                        lappend current_lo_descriptions $tmp_loo_description
                        keylset returnList loopback_description $current_lo_descriptions
                    }
                }
                
                if {[catch {keylget returnList ${tmp_con_description}.loopback} current_lo_descriptions]} {
                    keylset returnList ${tmp_con_description}.loopback [list $tmp_loo_description]
                } else {
                    if {[lsearch $current_lo_descriptions $tmp_loo_description] == -1} {
                        lappend current_lo_descriptions $tmp_loo_description
                        keylset returnList ${tmp_con_description}.loopback $current_lo_descriptions
                    }
                }
                
                catch {unset current_lo_descriptions}
                catch {unset current_descriptions}
                
                
                if {$gre_enable && $gre_count > 0 && $gre_src_ip_addr_mode == "routed"} {
                    
                    # We should create the gre intf create call
                    for {set gre_idx 0} {$gre_idx < $gre_count} {incr gre_idx} {
                        
                        # Mapping for gre_tunnel_config
                        set gre_intf_args {
                                port_handle              port_handle
                                ip_address               tmp_gre_ip_address
                                src_ip_address           tmp_loopback_ip_address
                                dst_ip_address           tmp_gre_dst_ip_address
                                ip_version               gre_ip_version
                                mac_address              mac_address
                                netmask                  gre_ip_prefix_length
                                gre_checksum_enable      gre_checksum_enable
                                gre_seq_enable           gre_seq_enable
                                gre_key_enable           gre_key_enable
                                gre_key_in               gre_key_in
                                gre_key_out              gre_key_out
                                gateway_ip_address       gateway_ip_address
                                gateway_ip_address_step  gateway_ip_address_step
                            }
                        
                        set gre_intf_cmd [list gre_tunnel_config -count 1]
                        foreach {gre_param gre_param_var} $gre_intf_args {
                           if {[info exists $gre_param_var]} {
                               lappend gre_intf_cmd -$gre_param [set $gre_param_var]
                           }
                        }

                        if {[llength $gre_intf_cmd] > 3} {
                            
                            if {![info exists mac_address]} {
                                lappend gre_intf_cmd -mac_address [string trim [lindex [split $tmp_con_description \-] 1]]
                            }
                            
                            # Decide if we should append no_write
                            if {![info exists no_write] && [expr $intf_connected_idx + 1] == $count &&\
                                    [expr $lo_connected_idx + 1] == $loopback_count && [expr $gre_idx + 1] == $gre_count} {
                                # Don't add no_write
                            } else {
                                lappend gre_intf_cmd -no_write
                            }
                            
                            set intf_status [eval $gre_intf_cmd]
                            if {[keylget intf_status status] != $::SUCCESS} {
                                return $intf_status
                            }
                            
                            # Take the keyed values and integrate them into returnList
                            set tmp_gre_description [keylget intf_status description]
                            
                            if {[catch {keylget returnList gre_description} current_gre_descriptions]} {
                                
                                keylset returnList gre_description [list $tmp_gre_description]
                            
                            } else {
                                
                                if {[lsearch $current_gre_descriptions $tmp_gre_description] == -1} {
                                    lappend current_gre_descriptions $tmp_gre_description
                                    keylset returnList gre_description $current_gre_descriptions
                                }
                            }
                            
                            if {[catch {keylget returnList ${tmp_con_description}.${tmp_loo_description}} current_gre_descriptions]} {
                                keylset returnList ${tmp_con_description}.${tmp_loo_description} [list $tmp_gre_description]
                            } else {
                                if {[lsearch $current_gre_descriptions $tmp_gre_description] == -1} {
                                    lappend current_gre_descriptions $tmp_gre_description
                                    keylset returnList ${tmp_con_description}.${tmp_loo_description} $current_gre_descriptions
                                }
                            }
                            
                            catch {unset current_gre_descriptions}
                            catch {unset tmp_gre_description}
                        }

                        # Increment GRE inner loop
                        if {$gre_ip_version == 4} {
                            set tmp_gre_ip_address [incr_ipv4_addr $tmp_gre_ip_address $gre_ip_addr_step]
                        } else {
                            set tmp_gre_ip_address [incr_ipv6_addr $tmp_gre_ip_address $gre_ip_addr_step]
                        }
                        
                        if {$lo_ip_version == 4} {
                            set tmp_gre_dst_ip_address [incr_ipv4_addr $tmp_gre_dst_ip_address $gre_dst_ip_addr_step]
                        } else {
                            set tmp_gre_dst_ip_address [incr_ipv6_addr $tmp_gre_dst_ip_address $gre_dst_ip_addr_step]
                        }
                        
                        if {[info exists gre_key_in] && [info exists gre_key_in_step]} {
                            set gre_key_in [mpexpr $gre_key_in + $gre_key_in_step]
                        }
                        
                        if {[info exists gre_key_out] && [info exists gre_key_out_step]} {
                            set gre_key_out [mpexpr $gre_key_out + $gre_key_out_step]
                        }
                    }
                    
                    # Increment GRE loopback steps
                    if {$gre_ip_version == 4} {
                        set tmp_gre_ip_address [incr_ipv4_addr $tmp_gre_lo_ip_address $gre_ip_addr_lstep]
                    } else {
                        set tmp_gre_ip_address [incr_ipv6_addr $tmp_gre_lo_ip_address $gre_ip_addr_lstep]
                    }
                    
                    if {$lo_ip_version == 4} {
                        set tmp_gre_dst_ip_address [incr_ipv4_addr $tmp_gre_dst_lo_ip_address $gre_dst_ip_addr_lstep]
                    } else {
                        set tmp_gre_dst_ip_address [incr_ipv6_addr $tmp_gre_dst_lo_ip_address $gre_dst_ip_addr_lstep]
                    }
                }
                
                
                # Increment stuff for inner loopback loop
                if {$lo_ip_version == 4} {
                    set tmp_loopback_ip_address [incr_ipv4_addr $tmp_loopback_ip_address $loopback_ip_address_step]
                } else {
                    set tmp_loopback_ip_address [incr_ipv6_addr $tmp_loopback_ip_address $loopback_ip_address_step]
                }
                
            }
            
            # Increment stuff for outer loopback loop
            if {$lo_ip_version == 4} {
                set loopback_ip_address [incr_ipv4_addr $loopback_ip_address $loopback_ip_address_cstep]
            } else {
                set loopback_ip_address [incr_ipv6_addr $loopback_ip_address $loopback_ip_address_cstep]
            }
            
            # Increment GRE connected steps
            if {$gre_enable && $gre_count > 0 && $gre_src_ip_addr_mode == "routed"} {
                if {$gre_ip_version == 4} {
                    set gre_ip_addr [incr_ipv4_addr $gre_ip_addr $gre_ip_addr_cstep]
                } else {
                    set gre_ip_addr [incr_ipv6_addr $gre_ip_addr $gre_ip_addr_cstep]
                }
                
                if {$lo_ip_version == 4} {
                    set gre_dst_ip_addr [incr_ipv4_addr $gre_dst_ip_addr $gre_dst_ip_addr_cstep]
                } else {
                    set gre_dst_ip_addr [incr_ipv6_addr $gre_dst_ip_addr $gre_dst_ip_addr_cstep]
                }
            }
            
            catch {unset tmp_loo_description}
        }
        
        if {![info exists loopback_count] || $loopback_count == 0} {
            # Create connected interfaces here because they were not created in the 
            # loopback area.
            set prot_intf_cmd "protocol_interface_config"
            foreach con_param $connected_intf_args {
                if {[info exists $con_param]} {
                    lappend prot_intf_cmd -$con_param [set $con_param]
                }
            }
            
            # Decide if we should append no_write
            if {[info exists no_write] || ($commit_when == "connected" &&\
                    [expr $intf_connected_idx + 1] < $count) || ($commit_when == "connected_gre_connected")} {
                    
                lappend prot_intf_cmd -no_write
            }
            
            set intf_status [eval $prot_intf_cmd]
            if {[keylget intf_status status] != $::SUCCESS} {
                return $intf_status
            }
            
            # Take the keyed values and integrate them into returnList
            set tmp_con_description [keylget intf_status description]
            
            if {[catch {keylget returnList description} current_descriptions]} {
                
                keylset returnList description                      [list $tmp_con_description]
                
            } else {
                
                if {[lsearch $current_descriptions $tmp_con_description] == -1} {
                    lappend current_descriptions $tmp_con_description
                    keylset returnList description $current_descriptions
                }
            }
            
            catch {unset current_descriptions}
        }
        
        # Create GRE Interfaces if necessary
        if {$gre_enable && $gre_count > 0 && $gre_src_ip_addr_mode == "connected"} {
            # We should create the gre intf create call
            for {set gre_idx 0} {$gre_idx < $gre_count} {incr gre_idx} {
                
                # Mapping for gre_tunnel_config
                set gre_intf_args {
                        port_handle              port_handle
                        ip_address               tmp_gre_ip_address
                        src_ip_address           ip_address
                        dst_ip_address           tmp_gre_dst_ip_address
                        ip_version               gre_ip_version
                        mac_address              mac_address
                        netmask                  gre_ip_prefix_length
                        gre_checksum_enable      gre_checksum_enable
                        gre_seq_enable           gre_seq_enable
                        gre_key_enable           gre_key_enable
                        gre_key_in               gre_key_in
                        gre_key_out              gre_key_out
                        gateway_ip_address       gateway_ip_address
                        gateway_ip_address_step  gateway_ip_address_step
                    }
                
                set gre_intf_cmd [list gre_tunnel_config -count 1]
                foreach {gre_param gre_param_var} $gre_intf_args {
                   if {[info exists $gre_param_var]} {
                       lappend gre_intf_cmd -$gre_param [set $gre_param_var]
                   }
                }
                
                if {[llength $gre_intf_cmd] > 3} {
                    
                    if {![info exists mac_address]} {
                        lappend gre_intf_cmd -mac_address "[lindex [split $tmp_con_description \-] 1]"
                    }
                    
                    # Decide if we should append no_write
                    if {[info exists no_write] || [expr $intf_connected_idx + 1] < $count ||\
                            [expr $gre_idx + 1] < $gre_count} {
                            
                        lappend gre_intf_cmd -no_write
                    }
                    
                    set intf_status [eval $gre_intf_cmd]
                    if {[keylget intf_status status] != $::SUCCESS} {
                        return $intf_status
                    }
                    
                    # Take the keyed values and integrate them into returnList
                    set tmp_gre_description [keylget intf_status description]
                    
                    if {[catch {keylget returnList gre_description} current_gre_descriptions]} {
                        
                        keylset returnList gre_description [list $tmp_gre_description]
                    
                    } else {
                        
                        if {[lsearch $current_gre_descriptions $tmp_gre_description] == -1} {
                            lappend current_gre_descriptions $tmp_gre_description
                            keylset returnList gre_description $current_gre_descriptions
                        }
                    }
                    
                    if {[catch {keylget returnList ${tmp_con_description}.gre} current_gre_descriptions]} {
                        keylset returnList ${tmp_con_description}.gre [list $tmp_gre_description]
                    } else {
                        if {[lsearch $current_gre_descriptions $tmp_gre_description] == -1} {
                            lappend current_gre_descriptions $tmp_gre_description
                            keylset returnList ${tmp_con_description}.gre $current_gre_descriptions
                        }
                    }
                    
                    catch {unset current_gre_descriptions}
                    catch {unset tmp_gre_description}
                }

                # Increment GRE inner loop
                if {$gre_ip_version == 4} {
                    set tmp_gre_ip_address [incr_ipv4_addr $tmp_gre_ip_address $gre_ip_addr_step]
                } else {
                    set tmp_gre_ip_address [incr_ipv6_addr $tmp_gre_ip_address $gre_ip_addr_step]
                }
                
                if {$ip_version == 4} {
                    set tmp_gre_dst_ip_address [incr_ipv4_addr $tmp_gre_dst_ip_address $gre_dst_ip_addr_step]
                } else {
                    set tmp_gre_dst_ip_address [incr_ipv6_addr $tmp_gre_dst_ip_address $gre_dst_ip_addr_step]
                }
                
                if {[info exists gre_key_in] && [info exists gre_key_in_step]} {
                    set gre_key_in [mpexpr $gre_key_in + $gre_key_in_step]
                }
                
                if {[info exists gre_key_out] && [info exists gre_key_out_step]} {
                    set gre_key_out [mpexpr $gre_key_out + $gre_key_out_step]
                }
            }
            
            
            # Increment GRE connected steps
            if {$gre_ip_version == 4} {
                set gre_ip_addr [incr_ipv4_addr $gre_ip_addr $gre_ip_addr_cstep]
            } else {
                set gre_ip_addr [incr_ipv6_addr $gre_ip_addr $gre_ip_addr_cstep]
            }
            
            if {$ip_version == 4} {
                set gre_dst_ip_addr [incr_ipv4_addr $gre_dst_ip_addr $gre_dst_ip_addr_cstep]
            } else {
                set gre_dst_ip_addr [incr_ipv6_addr $gre_dst_ip_addr $gre_dst_ip_addr_cstep]
            }
        }
        
        set con_param_step_map [list                       \
            ip_address              ip_address_step        \
            gateway_ip_address      gateway_ip_address_step\
            atm_vci                 atm_vci_step           \
            atm_vpi                 atm_vpi_step           \
            vlan_id                 vlan_id_step           \
            mac_address             mac_address_step       \
        ]
        
        foreach {con_param con_param_step} $con_param_step_map {
            if {![info exists $con_param] || ![info exists $con_param_step]} {
                continue
            }
            
            switch -- $con_param {
                ip_address {
                    if {$ip_version == 4} {
                        set $con_param [incr_ipv4_addr [set $con_param] [set $con_param_step]]
                    } else {
                        set $con_param [incr_ipv6_addr [set $con_param] [set $con_param_step]]
                    }
                }
                gateway_ip_address {
                    if {$ip_version == 4} {
                        set $con_param [incr_ipv4_addr [set $con_param] [set $con_param_step]]
                    } else {
                        set $con_param [incr_ipv6_addr [set $con_param] [set $con_param_step]]
                    }
                }
                atm_vci {
                    incr $con_param [set $con_param_step]
                    if {[set $con_param] > 65535} {
                        set $con_param [mpexpr [set $con_param] - 65536]
                    }
                }
                atm_vpi {
                    incr $con_param [set $con_param_step]
                    if {[set $con_param] > 255} {
                        set $con_param [mpexpr [set $con_param] - 256]
                    }
                }
                vlan_id {
                    if {[info exists vlan_id_mode] && $vlan_id_mode != "fixed"} {
                        incr $con_param [set $con_param_step]
                        if {[set $con_param] > 4096} {
                            set $con_param [mpexpr [set $con_param] - 4097]
                        }
                    }
                }
                mac_address {
                    set $con_param [incr_mac_addr [set $con_param] [set $con_param_step]]
                }
            }
        }
        
        catch {unset tmp_con_description}
    }
    
    return $returnList
}


proc ::ixia::rfremove_interface_by_description {intf_description} {
    # Removes the interface with $intf_description from all internal arrays
    keylset returnList status $::SUCCESS
    
    set details [list   type        \
                        ipv4_address\
                        ipv6_address\
                        mac_address \
                        port_handle \
                        ixnetwork_objref]
    
    # Check if interface with intf_description exists
    set ret_code [get_interface_parameter       \
            -description    $intf_description  \
            -parameter      $details            ]
    if {[keylget ret_code status] != $::SUCCESS} {
        # get_interface_parameter fails only if interface was not found
        # in this case it means that we don't have to delete it anymore
        return $returnList
    }
    
    foreach param_detail $details {
        set $param_detail [keylget ret_code $param_detail]
    }
    
    set ip_type 0
    
    if {[llength $ipv4_address] > 0} {
        set ip_type 4
    }
    
    if {[llength $ipv6_address] > 0} {
        if {$ip_type == 4} {
            set ip_type 46
        } else {
            set ip_type 6
        }
    }
    
    set int_status [rfget_interface_handles_list mac $port_handle $type $mac_address $ip_type]
    if {[keylget int_status status] != $::SUCCESS} {
        keylset int_status log "Failed to remove interface with description\
                '$intf_description'. [keylget int_status log]"
        return $int_status 
    }
    
    set interface_handles [keylget int_status ret_val]
    # ixnetwork_objref could be an ixnetwork interface object or a protocols
    #   interface handle
    set pos [lsearch $interface_handles $ixnetwork_objref]
    if {$pos != -1} {
        set interface_handles [lreplace $interface_handles $pos $pos]
        set ret_code [rfset_interface_handles_list mac $port_handle $type $mac_address $ip_type $interface_handles]
        if {[keylget ret_code status] != $::SUCCESS} {
            keylset ret_code log "Failed to remove interface with description\
                '$intf_description'. [keylget ret_code log]"
            return $ret_code
        }
    }
    
    if {$ip_type == 4 || $ip_type == 46} {
        set int_status [rfget_interface_handles_list ip $port_handle $type $ipv4_address $ip_type]
        if {[keylget int_status status] != $::SUCCESS} {
            keylset int_status log "Failed to remove interface with description\
                    '$intf_description'. [keylget int_status log]"
            return $int_status 
        }
        set interface_handles [keylget int_status ret_val]
        # ixnetwork_objref could be an ixnetwork interface object or a protocols
        #   interface handle
        set pos [lsearch $interface_handles $ixnetwork_objref]
        if {$pos != -1} {
            set interface_handles [lreplace $interface_handles $pos $pos]
            set ret_code [rfset_interface_handles_list ip $port_handle $type $ipv4_address $ip_type $interface_handles]
            if {[keylget ret_code status] != $::SUCCESS} {
                keylset ret_code log "Failed to remove interface with description\
                    '$intf_description'. [keylget ret_code log]"
                return $ret_code
            }
        }
    }
    
    if {$ip_type == 6 || $ip_type == 46} {
        set int_status [rfget_interface_handles_list ip $port_handle $type $ipv6_address $ip_type]
        if {[keylget int_status status] != $::SUCCESS} {
            keylset int_status log "Failed to remove interface with description\
                    '$intf_description'. [keylget int_status log]"
            return $int_status 
        }
        set interface_handles [keylget int_status ret_val]
        # ixnetwork_objref could be an ixnetwork interface object or a protocols
        #   interface handle
        set pos [lsearch $interface_handles $ixnetwork_objref]
        if {$pos != -1} {
            set interface_handles [lreplace $interface_handles $pos $pos]
            set ret_code [rfset_interface_handles_list ip $port_handle $type $ipv6_address $ip_type $interface_handles]
            if {[keylget ret_code status] != $::SUCCESS} {
                keylset ret_code log "Failed to remove interface with description\
                    '$intf_description'. [keylget ret_code log]"
                return $ret_code
            }
        }
    }
    
    # Remove the interface from ::ixia::gateway_list
    remove_gateway_list_item $port_handle $ixnetwork_objref $ip_type

    # Remove item from pa_inth_idx (array indexed by interface handle)
    set ret_code [rfremove_interface_details_by_handle $ixnetwork_objref]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset ret_code log "Failed to remove interface with description\
                '$intf_description'. [keylget ret_code log]"
        return $ret_code
    }
    
    # Remove item from pa_descr_idx (array indexed by description)
    set ret_code [rfremove_interface_handle_by_description $intf_description]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset ret_code log "Failed to remove interface with description\
                '$intf_description'. [keylget ret_code log]"
        return $ret_code
    }
    
    return $returnList
}


proc ::ixia::rfget_interface_handles_list {array_idx_type port_handle type address ip_type} {
    # Given the port_handle, type (connected, routed or gre), address and ip_type (4 6 46 0)
    #      it returns the interface handle list that match the criteria
    # array_idx_type can be
    #       mac - the interface handles list is taken from the array indexed by mac
    #             address is a mac address
    #       ip  - the interface handles list is taken from the array indexed by ip
    #             address is an ip address (v4 or v6)
    
    
    variable pa_ip_idx
    variable pa_mac_idx
    
    keylset returnList status $::SUCCESS
    
    switch -- $array_idx_type {
        mac {
            if {[isValidMacAddress $address]} {
                regsub -all { } $address {\ } address
            }
            set cmd_exists  "info exists pa_mac_idx($port_handle,$type,$address,$ip_type)"
            set cmd_extract "set interface_handles_list \$pa_mac_idx($port_handle,$type,$address,$ip_type)"
        }
        ip {
            set cmd_exists  "info exists pa_ip_idx($port_handle,$type,$address,$ip_type)"
            set cmd_extract "set interface_handles_list \$pa_ip_idx($port_handle,$type,$address,$ip_type)"
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "Invalid argument '$array_idx_type' in rfget_interface_handles_list"
            return $returnList
        }
    }
    
    if {[catch {eval $cmd_exists} out]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Inconsistent internal array.\
                Command '$cmd_exists' failed with '$out'"
        return $returnList
    } elseif {$out == 1} {    
        if {[catch {eval $cmd_extract} err]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal error. Inconsistent internal array.\
                    Command '$cmd_extract' failed with '$err'"
            return $returnList
        }
    } else {
        set interface_handles_list ""
    }
    
    keylset returnList ret_val $interface_handles_list
    return $returnList
}


proc ::ixia::rfget_interface_details_by_description {intf_description} {
    # Given the interface description this procedure returns the coma separated
    # list of interface properties
    
    keylset returnList status $::SUCCESS
    
    set intf_handle [rfget_interface_handle_by_description $intf_description]
    if {[llength $intf_handle] == 0} {
        # Interfaces does not exist
        keylset returnList ret_val ""
        return $returnList
    }
    
    set intf_details [rfget_interface_details_by_handle $intf_handle]
    if {[llength $intf_details] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Internal error. Inconsistent internal array. Interface handle\
                '$intf_handle' is missing but an interface description '$intf_description'\
                exists"
        return $returnList
    }
    
    keylset returnList ret_val $intf_details
    
    return $returnList
}


proc ::ixia::rfget_interface_handle_by_description {intf_description} {
    # Given the interface description this procedure returns the interface handle
    
    variable pa_descr_idx
    
    if {![info exists pa_descr_idx($intf_description)]} {
        # Not found
        return ""
    } else {
        return $pa_descr_idx($intf_description)
    }
}


proc ::ixia::rfget_interface_details_by_handle {intf_handle} {
    # Given the interface handle this procedure returns the coma separated
    # list of interface properties
    
    variable pa_inth_idx
    
    if {![info exists pa_inth_idx($intf_handle)]} {
        # Not found
        return ""
    } else {
        return $pa_inth_idx($intf_handle)
    }
}


proc ::ixia::rfset_interface_handles_list {array_idx_type port_handle type address ip_type interface_handles} {
    # Writes the interface_handles list in pa_ip_idx or pa_mac_idx array depending
    #       on array_idx_type (mac | ip)
    
    variable pa_ip_idx
    variable pa_mac_idx
    
    keylset returnList status $::SUCCESS
    
    switch -- $array_idx_type {
        mac {
            if {[isValidMacAddress $address]} {
                regsub -all { } $address {\ } address
            }
            if {[llength $interface_handles] == 0} {
                # remove the array entry entirely
                set cmd_exists "info exists pa_mac_idx($port_handle,$type,$address,$ip_type)"
                set cmd "unset pa_mac_idx($port_handle,$type,$address,$ip_type)"
            } else {
                set cmd "set pa_mac_idx($port_handle,$type,$address,$ip_type) \$interface_handles"
            }
        }
        ip {
            if {[llength $interface_handles] == 0} {
                # remove the array entry entirely
                set cmd_exists "info exists pa_ip_idx($port_handle,$type,$address,$ip_type)"
                set cmd "unset pa_ip_idx($port_handle,$type,$address,$ip_type)"
            } else {
                set cmd "set pa_ip_idx($port_handle,$type,$address,$ip_type) \$interface_handles"
            }
        }
        default {
            keylset returnList status $::FAILURE
            keylset returnList log "Invalid argument '$array_idx_type' in rfset_interface_handles_list"
            return $returnList
        }
    }
    
    if {[info exists cmd_exists]} {
        if {[catch {eval $cmd_exists} out]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Command '$cmd_exists' failed with '$out'"
            return $returnList
        } elseif {$out == 0} {
            # Array entry already removed
            return $returnList
        }
    }
    
    if {[catch {eval $cmd} err]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Command '$cmd' failed with '$err'"
        return $returnList
    }
    
    return $returnList
}


proc ::ixia::rfadd_interface_by_details {comma_separated_details {ip_version "detect"}} {
    # Given the interface details add the interface in all internal arrays
    
    variable cmdProtIntfParamsPositions
    
    keylset returnList status $::SUCCESS
    
    if {$ip_version == "detect"} {
        set ip_version [rfget_ip_type_from_cs_details $comma_separated_details]
    }
    
    if {$ip_version == "4_6"} {
        set ip_version 46
    }
    
    set details_list [split $comma_separated_details ,]
    
    set index_list ""
    foreach {dataInput dataIndex} [array get cmdProtIntfParamsPositions] {
        set $dataInput [lindex $details_list $dataIndex]
    }
    
    # Add interface in array indexed by mac
    set ret_code [::ixia::rfadd_interface_handle "mac" $port_handle $type $mac_address $ip_version $ixnetwork_objref]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    # Add interface in array indexed by ip
    if {($ip_version == 4 || $ip_version == 46) && [isValidIPAddress $ipv4_address]} {
        set ret_code [::ixia::rfadd_interface_handle "ip" $port_handle $type $ipv4_address $ip_version $ixnetwork_objref]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        # Add interface in ::ixia::gateway_list
        if {[isValidIPv4Address $ipv4_gateway]} {
            set_gateway_list [list ipV4Gateway $ipv4_gateway ipVersion 4] $ixnetwork_objref $port_handle
        }
    }
    
    if {($ip_version == 6 || $ip_version == 46) && [isValidIPAddress $ipv6_address]} {
        set ret_code [::ixia::rfadd_interface_handle "ip" $port_handle $type $ipv6_address $ip_version $ixnetwork_objref]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
        
        # Add interface in ::ixia::gateway_list
        set_gateway_list [list ipVersion 6] $ixnetwork_objref $port_handle
    }
    
    # Add interface in array indexed by interface_handle
    set ret_code [::ixia::rfadd_interface_details_by_handle $ixnetwork_objref $comma_separated_details]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    # Add interface in array indexed by description
    set ret_code [::ixia::rfadd_interface_handle_by_description $description $ixnetwork_objref]
    if {[keylget ret_code status] != $::SUCCESS} {
        return $ret_code
    }
    
    return $returnList
}


proc ::ixia::rfget_ip_type_from_cs_details {comma_separated_details} {
    # Given the interface details return the ip_type of the interface
    
    variable cmdProtIntfParamsPositions
    
    set details_list [split $comma_separated_details ,]
    
    set index_list ""
    foreach {dataInput dataIndex} [array get cmdProtIntfParamsPositions] {
        set $dataInput [lindex $details_list $dataIndex]
    }
    
    set ip_type 0
    
    if {[isValidIPAddress $ipv4_address]} {
        set ip_type 4
    }
    
    if {[isValidIPAddress $ipv6_address]} {
        if {$ip_type == 4} {
            set ip_type 46
        } else {
            set ip_type 6
        }
    }
    
    return $ip_type    
}

proc ::ixia::rfadd_interface_handle {array_idx_type port_handle type address ip_type interface_handle} {
    # Add the interface_handle pa_ip_idx or pa_mac_idx array depending
    #       on array_idx_type (mac | ip)
    
    keylset returnList status $::SUCCESS
    
    set int_status [rfget_interface_handles_list $array_idx_type $port_handle $type $address $ip_type]
    if {[keylget int_status status] != $::SUCCESS} {
        return $int_status
    }
    set interface_handles [keylget int_status ret_val]
    set pos [lsearch $interface_handles $interface_handle]
    
    if {$pos == -1} {
        lappend interface_handles $interface_handle
        set ret_code [rfset_interface_handles_list $array_idx_type $port_handle $type $address $ip_type $interface_handles]
        if {[keylget ret_code status] != $::SUCCESS} {
            return $ret_code
        }
    }
    
    return $returnList
}

proc ::ixia::rfremove_interface_details_by_handle {interface_handle} {
    # Remove the array index $interface_handle from the array indexed by
    #       interface handle
    variable pa_inth_idx
    keylset returnList status $::SUCCESS
    
    catch {unset pa_inth_idx($interface_handle)}
    
    return $returnList
}


proc ::ixia::rfremove_interface_handle_by_description {description} {
    # Remove the array index $description from the array indexed by
    #       interface description
    
    variable pa_descr_idx
    keylset returnList status $::SUCCESS
    
    catch {unset pa_descr_idx($description)}
    
    return $returnList
}

proc ::ixia::rfadd_interface_details_by_handle {interface_handle cs_intf_details} {
    # Adds a new comma separated interface details value in array indexed by interface handle
    variable pa_inth_idx
    keylset returnList status $::SUCCESS
    
    set pa_inth_idx($interface_handle) $cs_intf_details
    
    return $returnList
}


proc ::ixia::rfadd_interface_handle_by_description {description interface_handle} {
    # Adds a new interface handle value in array indexed by interface description
    variable pa_descr_idx
    keylset returnList status $::SUCCESS
    
    set pa_descr_idx($description) $interface_handle
    
    return $returnList
}

proc ::ixia::rfupdate_interface_description {description_old cs_intf_details_new {ip_version "detect"}} {
    # Replaces interface with description $description_ld with the interface 
    #       that has the comma separated details cs_intf_details_new and ip_version $ip_version
    # The old interface details will be retrieved
    # The new interface details will be merged with the old interface details
    # The old interface will be removed from all arrays
    # The new interface will be added in the arrays

    variable cmdProtIntfParamsPositions
    
    keylset returnList status $::SUCCESS
    
    set spaced_intf_details_new [split $cs_intf_details_new ,]
    
    set ret_code [rfget_interface_details_by_description $description_old]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset ret_code log "Failed to get interface details for interface with\
                description '$description_old'. [keylget ret_code log]"
        return $ret_code
    }
    
    set cs_intf_details_old [keylget ret_code ret_val]

    if {[llength $cs_intf_details_old] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Cannot find interface with description\
                '$description_old'"
        return $returnList
    }

    set index_old $cs_intf_details_old
    set index_new $index_old
    foreach {dataInput dataIndex} [array get cmdProtIntfParamsPositions] {
        set dataInputNewVal [lindex $spaced_intf_details_new $dataIndex]
        if {[string first * $dataInputNewVal] == -1} {
            set index_list [split $index_new ,]
            set index_list [lreplace $index_list            \
                    $cmdProtIntfParamsPositions($dataInput) \
                    $cmdProtIntfParamsPositions($dataInput) \
                    $dataInputNewVal                        ]
            
            set index_new [join $index_list ,]
        }
    }
    
    # index_old contains the comma separated interface details of the old interface
    # index_new contains the comma separated interface details of the new interface
    
    if {$ip_version == "detect"} {
        set ip_version [rfget_ip_type_from_cs_details $index_new]
        set ip_version_new $ip_version
    } else {
        set ip_version_new $ip_version
    }
    
    set ip_version_old [rfget_ip_type_from_cs_details $index_old]
    
    set params_to_remove {}
    switch -- $ip_version_new {
        0 {
            # Replace the ipv4 and ipv6 parameters with (.*)
            set params_to_remove {ipv4_address ipv4_mask ipv4_gateway ipv4_dst_address
                    ipv6_address ipv6_mask ipv6_gateway}
        }
        4 {
            # Replace the ipv6 parameters with (.*)
            set params_to_remove {ipv6_address ipv6_mask ipv6_gateway}
        }
        6 {
            # Replace the ipv4 parameters with (.*)
            set params_to_remove {ipv4_address ipv4_mask ipv4_gateway}
        }
        46 {
            set params_to_remove {}
        }
    }
    
    set index_new_list [split $index_new ,]
    foreach param_to_remove $params_to_remove {
        set index_new_list [lreplace $index_new_list $cmdProtIntfParamsPositions($param_to_remove)\
                $cmdProtIntfParamsPositions($param_to_remove) "(.*)"]
    }
    set index_new [join $index_new_list ,]
    
    # Remove original interface from internal array
    set rmv_status [rfremove_interface_by_description $description_old]
    if {[keylget rmv_status status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to remove old interface with description '$description_old'.\
                [keylget rmv_status log]"
        return $returnList
    }
    
    # Add modified interface in internal arrays
    set ret_code [rfadd_interface_by_details $index_new $ip_version_new]
    if {[keylget ret_code status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed to add modified interface with details '$index_new'\
                and ip_version '$ip_version_new'. [keylget ret_code log]"
        return $returnList
    }
    
    return $returnList
}


proc ::ixia::rfremap_interface_handle {interface_handles} {
    # Use this procedure when remapIds on interface handles that were
    #       already added in internal arrays
    # parameter interface_handles can be:
    #       1 handle
    #       list of handles
    #       word "all"
    
    variable pa_inth_idx
    variable cmdProtIntfParamsPositions
    
    keylset returnList status $::SUCCESS
    
    if {$interface_handles == "all"} {
        set interface_handles [array names pa_inth_idx]
    }
    
    #set interface_handles_new [ixNet remapIds $interface_handles]
    set interface_handles_new ""
    
    foreach intf_handle $interface_handles {
        if {![regexp {:L(\d+)$} $intf_handle]} {
            # Not a temporary object
            lappend interface_handles_new $intf_handle
            continue
        }
        
        set intf_handle_new  [ixNet remapIds $intf_handle]
        set intf_details_old [rfget_interface_details_by_handle $intf_handle]
        if {[llength $intf_details_old] == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "Internal error in rfremap_interface_handle.\
                    Interface with handle '$intf_handle' does not exist in internal\
                    arrays."
            return $returnList
        }
        
        set intf_details_old_list [split $intf_details_old ,]
        set intf_description_old [lindex $intf_details_old_list $cmdProtIntfParamsPositions(description)]
        set intf_details_new_list [lreplace $intf_details_old_list \
                $cmdProtIntfParamsPositions(ixnetwork_objref)      \
                $cmdProtIntfParamsPositions(ixnetwork_objref)      \
                $intf_handle_new                                   ]
        
        set intf_details_new [join $intf_details_new_list ,]
        
        set ret_code [rfupdate_interface_description $intf_description_old $intf_details_new]
        if {[keylget ret_code status] != $::SUCCESS} {
            keylset ret_code log "Failed to remap interface handle '$intf_handle'\
                    [keylget ret_code log]"
            return $ret_code
        }
    }
    
    return $returnList
}


proc ::ixia::rfget_interface_description_from_handle {interface_handle} {
    # Given an interface handle it returns the interface description
    
    variable cmdProtIntfParamsPositions
    
    set intf_details [rfget_interface_details_by_handle $interface_handle]
    if {[llength $intf_details] == 0} {
        # Interface with handle interface_handle is not tracked
        return ""
    }
    
    set intf_details_list [split $intf_details ,]
    set intf_description [lindex $intf_details_list $cmdProtIntfParamsPositions(description)]
    
    return $intf_description
}


proc ::ixia::rfremove_all_interfaces_from_port {port_handle} {
    variable pa_descr_idx
    
    foreach description [array names pa_descr_idx] {
        if {![regexp "$port_handle" $description]} {
            continue
        }
        
        set ret_code [rfremove_interface_by_description $description]
        if {[keylget ret_code status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed in rfremove_all_interfaces_from_port $handle.\
                    rfremove_interface_by_description failed with '[keylget ret_code log]'"
            return $returnList
        }
    }
    
    # Remove interfaces from gateway list
    remove_gateway_list_by_port $port_handle
    
    keylset returnList status $::SUCCESS
    return $returnList
}
