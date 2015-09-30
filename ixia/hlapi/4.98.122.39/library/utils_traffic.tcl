##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    utils_traffic.tcl
#
# Purpose:
#    A script development library containing Traffic APIs for test automation
#    with the Ixia chassis.
#
# Usage:
#    package req Ixia
#
# Description:
#    The procedures contained within this library include:
#
#    - ::ixia::addIpV6ExtensionHeaders
#    - ::ixia::addIpV6HopByHopExtension
#    - ::ixia::getHltStreamIds
#    - ::ixia::getIxiaStreamIds
#    - ::ixia::ipv6ExtHdrSize
#
# Requirements:
#    utils_traffic.tcl , a library containing traffic TCL utilities
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

##Internal Procedure Header
# Name:
#    ::ixia::addIpV6ExtensionHeaders
#
# Description:
#    This command adds an IPv6 Extension Header.
#
# Synopsis:
#    ::ixia::addIpV6ExtensionHeaders
#         -ipv6_extension_header        CHOICES none hop_by_hop routing
#                                       CHOICES destination authentication
#                                       CHOICES fragment
#        [-ipv6_frag_offset             RANGE   0-8191
#                                       DEFAULT 100]
#        [-ipv6_frag_more_flag          FLAG
#                                       CHOICES 0 1
#                                       DEFAULT 0]
#        [-ipv6_frag_id                 RANGE   0-4294967295
#                                       DEFAULT 286335522]
#        [-ipv6_hop_by_hop_options]
#        [-ipv6_routing_node_list       IPV6]
#        [-ipv6_routing_res             REGEXP ^([0-9a-fA-F]{2}[.:]{1}){3}[0-9a-fA-F]{2}$
#                                       DEFAULT 00:00:00:00]
#        [-ipv6_frag_res_2bit           RANGE 0-3
#                                       DEFAULT 3]
#        [-ipv6_frag_res_8bit           RANGE 0-127
#                                       DEFAULT 30]
#        [-ipv6_auth_string             REGEXP ^([0-9a-fA-F]{2}[.:]{1})+[0-9a-fA-F]{2}$
#                                       DEFAULT 00:00:00:00]
#        [-ipv6_auth_payload_len        RANGE   0-4294967295
#                                       DEFAULT 2]
#        [-ipv6_auth_spi                RANGE   0-4294967295
#                                       DEFAULT 0]
#        [-ipv6_auth_seq_num            RANGE   0-4294967295
#                                       DEFAULT 0]
#
#
# Arguments:
#    -ipv6_frag_offset
#        This is only for "-ipv6_extension_header fragment".
#        Fragment offset in the fragment extension header of an IPv6 stream.
#       (DEFAULT 100)
#    -ipv6_frag_more_flag
#        This is only for "-ipv6_extension_header fragment".
#        Whether the M Flag in the fragment extension header of an IPv6 stream
#        is set. (DEFAULT 0)
#    -ipv6_frag_id
#        This is only for "-ipv6_extension_header fragment".
#        Identification field in the fragment extension header of an IPv6
#        stream. (DEFAULT 286335522)
#    -ipv6_extension_header
#        The type of the next extension header. Valid choices are:
#        none           - There is no next header.
#        hop_by_hop     - Next header is hop-by-hop options.
#        routing        - Next header has routing options.
#        destination    - Next header has destination options.
#        authentication - Next header is an IPSEC AH.
#        fragment       - Payload is a fragment.
#        tcp            - Next header is TCP.
#        udp            - Next header is UDP.
#        icmp           - Next header is ICMP V6.
#        gre            - Next header is GRE.
#    -ipv6_hop_by_hop_options
#        This is only for "-ipv6_extension_header hop_by_hop".
#        This option will represent a list of keyed values, like below:
#        key:type         <CHOICES pad1 padn jumbo router_alert binding_update
#                         binding_ack binding_req
#                         mipv6_unique_id_sub mipv6_alternative_coa_sub
#                         user_define>
#                         (This is a mandatory key)
#        key:length       <RANGE 0-255>
#                         (This applies to all key types except pad1)
#        key:value        <HEX BYTES separated by “:” or “.”>
#                         (This applies to padn, user_define types)
#        key:payload      <RANGE 0-4294967295>
#                         (This applies to jumbo type)
#        key:sub_unique   <RANGE 0-65535>
#                         (This applies to mipv6_unique_id_sub type)
#        key:alert_type   <CHOICES mld rsvp active_net>
#                         (This applies to router_alert type>
#        key:ack          <CHOICES 0 1>  (This applies to binding_update type)
#        key:bicast       <CHOICES 0 1>  (This applies to binding_update type)
#        key:duplicate    <CHOICES 0 1>  (This applies to binding_update type)
#        key:home         <CHOICES 0 1>  (This applies to binding_update type)
#        key:map          <CHOICES 0 1>  (This applies to binding_update type)
#        key:router       <CHOICES 0 1>  (This applies to binding_update type)
#        key:prefix_len   <RANGE 0-255>  (This applies to binding_update type)
#        key:life_time    <RANGE 0-4294967295>
#                         (This applies to binding_update, binding_ack types)
#        key:seq_num      <RANGE 0-65535>
#                         (This applies to binding_update, binding_ack types)
#        key:status       <RANGE 0-255>
#                         (This applies to binding_ack type)
#        key:refresh      <RANGE 0-4294967295>
#                         (This applies to binding_ack type)
#        key:address      <IPV6>
#                         (This applies to mipv6_alternative_coa_sub type)
#    -ipv6_routing_node_list
#        This is only for "-ipv6_extension_header routing".
#        A list of 128-bit IPv6 addresses.
#    -ipv6_routing_res
#        This is only for "-ipv6_extension_header routing".
#        A 32-bit reserved field.
#        <4 HEX BYTES separated by “:” or “.”>
#    -ipv6_frag_res_2bit
#        This is only for "-ipv6_extension_header fragment".
#        A 2-bit reserved field. (DEFAULT 3)
#    -ipv6_frag_res_8bit
#        This is only for "-ipv6_extension_header fragment".
#        An 8-bit reserved field. (DEFAULT 30)
#    -ipv6_auth_string
#        This is only for "-ipv6_extension_header authentication".
#        A variable length string containing the packets integrity check value
#        (ICV). (DEFAULT 00:00:00:00)
#    -ipv6_auth_payload_len
#        This is only for "-ipv6_extension_header authentication".
#        The length of the authentication data, expressed in 32-bit words.
#        (DEFAULT 2)
#    -ipv6_auth_spi
#        This is only for "-ipv6_extension_header authentication".
#        The security parameter index (SPI) associated with the authentication
#        header. (DEFAULT 0)
#    -ipv6_auth_seq_num
#        This is only for "-ipv6_extension_header authentication".
#        A sequence counter for the authentication header.
#        (DEFAULT 0)
#
# Return Values:
#    A key list
#    key:status        value:$::SUCCESS | $::FAILURE.
#    key:log           value:When status is failure, contains more information
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
proc ::ixia::addIpV6ExtensionHeaders {args} {
    # The validation for the parameters is done in the calling proc, so
    # all the types will be set to any
    set mand_args {
        -ipv6_extension_header        ANY
    }

    set opt_args {
        -ipv6_frag_offset             ANY
        -ipv6_frag_more_flag          ANY
        -ipv6_frag_id                 ANY
        -ipv6_frag_res_2bit           ANY
        -ipv6_frag_res_8bit           ANY
        -ipv6_hop_by_hop_options      ANY
        -ipv6_routing_node_list       ANY
        -ipv6_routing_res             ANY
        -ipv6_auth_string             ANY
        -ipv6_auth_payload_len        ANY
        -ipv6_auth_spi                ANY
        -ipv6_auth_seq_num            ANY
    }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args      \
            $mand_args -optional_args $opt_args} parseError]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed in ::ixia::addIpV6ExtensionHeaders. \
                $parseError"
        return $returnList
    }

    array set ipV6ExtensionHeadersArray [list                             \
            hop_by_hop      \
            {{cmd ipV6HopByHop}       {extension ipV6HopByHopOptions}}    \
            routing         \
            {{cmd ipV6Routing}        {extension ipV6Routing}}            \
            fragment        \
            {{cmd ipV6Fragment}       {extension ipV6Fragment}}           \
            authentication  \
            {{cmd ipV6Authentication} {extension ipV6Authentication}}     \
            none            \
            {{cmd ipV6NoNextHeader}   {extension ipV6NoNextHeader}}       \
            destination     \
            {{cmd ipV6Destination}    {extension ipV6DestinationOptions}} \
            ]

    # Need at least an empty array for each cmd name above
    array set ipV6HopByHopArray [list ]

    array set ipV6RoutingArray [list                                            \
            ipv6_routing_node_list {{parameter nodeList} {commands {}}}         \
            ipv6_routing_res       {{parameter reserved} {commands {split .|:}}}]

    array set ipV6FragmentArray [list                                       \
            ipv6_frag_offset     {{parameter fragmentOffset} {commands {}}} \
            ipv6_frag_id         {{parameter identification} {commands {}}} \
            ipv6_frag_more_flag  {{parameter enableFlag}     {commands {}}} \
            ipv6_frag_res_2bit   {{parameter res}            {commands {}}} \
            ipv6_frag_res_8bit   {{parameter reserved}       {commands {}}} ]

    array set ipV6AuthenticationArray [list                               \
            ipv6_auth_string {{parameter authentication} {commands {split .|:}}} \
            ipv6_auth_payload_len {{parameter payloadLength}     {commands {}}} \
            ipv6_auth_spi        {{parameter securityParamIndex} {commands {}}} \
            ipv6_auth_seq_num    {{parameter sequenceNumberField} {commands {}}}]

    array set ipV6NoNextHeaderArray [list ]

    array set ipV6DestinationArray [list ]

    # Length validation
    array set optionsArrayByHeader {
        ipv6_frag_offset        fragment
        ipv6_frag_more_flag     fragment
        ipv6_frag_id            fragment
        ipv6_frag_res_2bit      fragment
        ipv6_frag_res_8bit      fragment
        ipv6_hop_by_hop_options hop_by_hop
        ipv6_routing_node_list  routing
        ipv6_routing_res        routing
        ipv6_auth_string        authentication
        ipv6_auth_payload_len   authentication
        ipv6_auth_spi           authentication
        ipv6_auth_seq_num       authentication
    }
    set optionsList {
        ipv6_frag_offset       
        ipv6_frag_more_flag 
        ipv6_frag_id
        ipv6_frag_res_2bit     
        ipv6_frag_res_8bit  
        ipv6_hop_by_hop_options
        ipv6_routing_node_list 
        ipv6_routing_res    
        ipv6_auth_string
        ipv6_auth_payload_len  
        ipv6_auth_spi       
        ipv6_auth_seq_num
    }

    set numOptions [llength $ipv6_extension_header]

    # If the list of option name types is longer than 1, check all the other
    # inputs and make sure their list lengths match.
    if {$numOptions > 1} {
        foreach {option} $optionsList {
            if {[info exists $option] && ([lsearch $ipv6_extension_header \
                    $optionsArrayByHeader($option)] != -1)} {
                if {[llength [set $option]] != $numOptions} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Invalid number\
                            of elements for -$option {[set $option]}. \
                            The number must be the same with the number of\
                            -ipv6_extension_header values."
                    return $returnList
                }
            }
        }
    }

    set index 0
    foreach {ipv6_extension} $ipv6_extension_header {
        if {[info exists ipV6ExtensionHeadersArray($ipv6_extension)]} {
            set extValue     $ipV6ExtensionHeadersArray($ipv6_extension)
            set extCommand   [keylget extValue cmd]
            set extExtension [keylget extValue extension]
            set extArray     ${extCommand}Array
            switch -- $ipv6_extension {
                none {
                    set retCode [ipV6 clearAllExtensionHeaders]
                    if {$retCode} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to\
                                ipV6 clearAllExtensionHeaders. \
                                Return code was: $retCode.\n$::ixErrorInfo"
                        return $returnList
                    }
                }
                hop_by_hop {
                    $extCommand setDefault
                    set retCode [$extCommand clearAllOptions]
                    if {$retCode} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Failed to $extCommand\
                                clearAllOptions.  Return code was:\
                                $retCode.\n$::ixErrorInfo"
                        return $returnList
                    }

                    if {![info exists ipv6_hop_by_hop_options]} {
                        set hopByHopOpts ""
                    } else {
                        if {$numOptions > 1} {
                            set hopByHopOpts \
                                    [lindex $ipv6_hop_by_hop_options $index]
                        } else {
                            set hopByHopOpts $ipv6_hop_by_hop_options
                        }
                    }
                    # This might be more than one hop by hop set of data.
                    # type is mandatory, so if we have more than one "type"
                    # substring in our string, it's a list
                    if {[regexp -all {type} $hopByHopOpts] > 1} {
                        
                        # The call failed, so we need to make the existing
                        # data into a list
                            
                        foreach optionSet $hopByHopOpts {

                            if {[catch {keylkeys optionSet} ipv6Keys]} {
                                
                                set ipv6Keys ""
                            }

                            set ipv6Args ""
                            foreach key $ipv6Keys {
                                append ipv6Args " -$key [keylget optionSet $key]"
                            }
                            set retCode [eval ::ixia::addIpV6HopByHopExtension \
                                    $ipv6Args]
                            if {[keylget retCode status] == 0} {
                                keylset returnList status $::FAILURE
                                keylset returnList log [keylget retCode log]
                                return $returnList
                            }
                        }
                        
                    } else {
                        
                        if {[catch {keylkeys hopByHopOpts} ipv6Keys]} {
                            set hopByHopOpts [list $hopByHopOpts]
                            if {[catch {keylkeys hopByHopOpts} ipv6Keys]} {
                                set ipv6Keys ""
                            }
                        }

                        set ipv6Args ""
                        foreach key $ipv6Keys {
                            append ipv6Args " -$key [keylget hopByHopOpts $key]"
                        }
                        set retCode [eval ::ixia::addIpV6HopByHopExtension \
                                $ipv6Args]
                        if {[keylget retCode status] == 0} {
                            keylset returnList status $::FAILURE
                            keylset returnList log [keylget retCode log]
                            return $returnList
                        }
                    }
                }
                destination {
                    $extCommand setDefault
                    $extCommand clearAllOptions 
                    ipV6OptionPADN setDefault 
                    ipV6OptionPADN config -length 4
                    ipV6OptionPADN config -value  "00 00 00 00"
                    if {[$extCommand addOption ipV6OptionPADN]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Error calling $extCommand addOption ipV6OptionPADN"
                        return $returnList
                    }
                }
                default {
                    $extCommand setDefault
                    foreach {arrItem arrValue} [array get $extArray] {
                        if {![catch {set $arrItem} value]} {
                            if {[llength $ipv6_extension_header] > 1} {
                                set value [lindex [set $arrItem] $index]
                            } else  {
                                set value [set $arrItem]
                            }

                            if {$value != "N/A"} {
                                set arrParam [keylget arrValue parameter]
                                set arrCmd   [keylget arrValue commands]
                                if {$arrCmd != ""} {
                                    set cmdName  [lindex $arrCmd 0]
                                    set cmdParam [lindex $arrCmd 1]
                                    set value [$cmdName $value $cmdParam]
                                }
                                catch {$extCommand config -$arrParam $value}
                            }
                        }
                    }
                }
            }
            if {$ipv6_extension != "none"} {
                if {[ipV6 addExtensionHeader $extExtension]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "Failed to ipV6 addExtensionHeader\
                            $extExtension.\n$::ixErrorInfo"
                    return $returnList
                }
            }
        }
        incr index
    }

    keylset returnList status $::SUCCESS
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::addIpV6HopByHopExtension
#
# Description:
#    This command adds an IPv6 Hop by Hop Option.
#
# Synopsis:
#    ::ixia::addIpV6HopByHopExtension
#         -type           CHOICES pad1 padn jumbo router_alert binding_update
#                         CHOICES binding_ack binding_req user_define
#                         CHOICES mipv6_unique_id_sub mipv6_alternative_coa_sub
#         -length         RANGE 0-255
#         -value          REGEXP ^([0-9a-fA-F]{2}[.:]{1})+[0-9a-fA-F]{2}$
#         -payload        RANGE 0-4294967295
#         -sub_unique     RANGE 0-65535
#         -alert_type     CHOICES mld rsvp active_net
#         -ack            CHOICES 0 1
#                         DEFAULT 0
#         -bicast         CHOICES 0 1
#                         DEFAULT 0
#         -duplicate      CHOICES 0 1
#                         DEFAULT 0
#         -home           CHOICES 0 1
#                         DEFAULT 0
#         -map            CHOICES 0 1
#                         DEFAULT 0
#         -router         CHOICES 0 1
#                         DEFAULT 0
#         -prefix_len     RANGE 0-255
#         -life_time      RANGE 0-4294967295
#         -seq_num        RANGE 0-65535
#         -status         RANGE 0-255
#         -refresh        RANGE 0-4294967295
#         -address        IPV6
#
# Arguments:
#    -type
#        The type of IPv6 Hop by Hop option that needs to be added.
#    -length
#        The length value for the IPv6 Hop by Hop option.
#        This applies to all option types except pad1.
#    -value
#        The value for the IPv6 Hop by Hop option.
#        This applies to padn, user_define types and is provided as hex bytes
#        separated by ":" or ".".
#    -payload
#        The payload for the IPv6 Hop by Hop option.
#        This applies to jumbo type.
#    -sub_unique
#        A unique ID for the binding request.
#        This applies to mipv6_unique_id_sub type.
#    -alert_type
#        Specifies the type of router alert to include with the packet.
#        This applies to router_alert type.
#    -ack
#        This flag sets the Acknowledge (A) bit to indicate that the sending
#        mobile node is requesting that a Binding Acknowledgement be sent by
#        the receiving node when it gets the Binding Update.
#        (DEFAULT 0)
#    -bicast
#        Enables the bicasting flag for the Binding Update header.
#        (DEFAULT 0)
#    -duplicate
#        This flag sets the Duplicate Address Detection (D) bit, to indicate
#        that the sending node wants the receiving node to perform Duplicate
#        Address Detection for the mobile node’s home address in this binding.
#        The H and A bits MUST also be set for this action to be performed.
#        (DEFAULT 0)
#    -home
#        This flag sets the Home Registration (H) bit to indicate that the
#        sending node wants the receiving node to act as its home agent.
#        (DEFAULT 0)
#    -map
#        Enables the map flag for the Binding Update header.
#        (DEFAULT 0)
#    -router
#        This flag indicates if the binding cache entry is for a mobile node
#        advertised as a router by this node, on the behalf of the mobile node,
#        in proxy Neighbor Advertisements.
#        (DEFAULT 0)
#    -prefix_len
#         If the H-bit is set, this is the length of the routing prefix for the
#         home address.
#    -life_time
#         32-bit integer. The number of seconds remaining for the Binding
#         Cache entry. When the value reaches zero, the binding MUST be
#         considered expired and the Binding Cache entry MUST be deleted for
#         he mobile node.
#    -seq_num
#         16-bit integer.
#         For type binding_update: The mobile node uses this number in the
#         Binding Update. The receiving node uses the same number in its
#         Binding Acknowledgement, for matching. The Sequence number in each
#         Binding Update to one destination address must be greater than the
#         last.
#         For type binding_ack: This integer is copied from the received Binding
#         Update into the corresponding Binding ACK message.
#    -status
#         8-bit integer. This value indicates the disposition of the
#         Binding Update:
#             0-127   = Binding Update was accepted.
#             >/= 128 = Binding Update was rejected.
#    -refresh
#         32-bit interger (in seconds).  The mobile node SHOULD send a new
#         Binding Update at this recommended interval, to refresh the binding.
#         The receiving node (the node which sends the Binding ACK) determines
#         the refresh interval.
#    -address
#         For type mipv6_alternative_coa_sub: The IPv6 address.
#
# Return Values:
#    A key list
#    key:status        value:$::SUCCESS | $::FAILURE.
#    key:log           value:When status is failure, contains more information
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
proc ::ixia::addIpV6HopByHopExtension {args} {
    set mand_args {
        -type           CHOICES pad1 padn jumbo router_alert binding_update
                        CHOICES binding_ack binding_req user_define
                        CHOICES mipv6_unique_id_sub mipv6_alternative_coa_sub
    }
    set opt_args {
        -length         RANGE 0-255
        -value          REGEXP ^[0-9a-fA-F]{2}([.:]{1}[0-9a-fA-F]{2})*$
        -payload        RANGE 0-4294967295
        -sub_unique     RANGE 0-65535
        -alert_type     CHOICES mld rsvp active_net
        -ack            CHOICES 0 1
                        DEFAULT 0
        -bicast         CHOICES 0 1
                        DEFAULT 0
        -duplicate      CHOICES 0 1
                        DEFAULT 0
        -home           CHOICES 0 1
                        DEFAULT 0
        -map            CHOICES 0 1
                        DEFAULT 0
        -router         CHOICES 0 1
                        DEFAULT 0
        -prefix_len     RANGE 0-255
        -life_time      RANGE 0-4294967295
        -seq_num        RANGE 0-65535
        -status         RANGE 0-255
        -refresh        RANGE 0-4294967295
        -address        IPV6
    }

    if {[catch {::ixia::parse_dashed_args -args $args -mandatory_args   \
                    $mand_args -optional_args $opt_args} parseError]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Failed in ::ixia::addIpV6HopByHopExtension. \
                $parseError"
        return $returnList
    }

    array set typeArray [list                                          \
            pad1                      ipV6OptionPAD1                   \
            padn                      ipV6OptionPADN                   \
            jumbo                     ipV6OptionJumbo                  \
            router_alert              ipV6OptionRouterAlert            \
            binding_update            ipV6OptionBindingUpdate          \
            binding_ack               ipV6OptionBindingAck             \
            binding_req               ipV6OptionBindingRequest         \
            mipv6_unique_id_sub       ipV6OptionMIpV6UniqueIdSub       \
            mipv6_alternative_coa_sub ipV6OptionMIpV6AlternativeCoaSub \
            user_define               ipV6OptionUserDefine             ]

    # Need at least an empty array for each of the ipV6 options from typeArray
    array set ipV6OptionPAD1Array [list ]

    array set ipV6OptionPADNArray [list  \
            length        length         \
            value         value          ]

    array set ipV6OptionJumboArray [list \
            length        length         \
            payload       payload        ]

    array set ipV6OptionRouterAlertArray [list \
            length        length               \
            alert_type    routerAlert          ]

    array set ipV6OptionBindingUpdateArray [list  \
            length        length                  \
            ack           enableAcknowledge       \
            bicast        enableBicasting         \
            duplicate     enableDuplicate         \
            home          enableHome              \
            map           enableMAP               \
            router        enableRouter            \
            life_time     lifeTime                \
            prefix_len    prefixLength            \
            seq_num       sequenceNumber          ]

    array set ipV6OptionBindingAckArray [list   \
            length        length                \
            life_time     lifeTime              \
            seq_num       sequenceNumber        \
            status        status                \
            refresh       refresh               ]

    array set ipV6OptionBindingRequestArray [list \
            length        length                  ]

    array set ipV6OptionMIpV6UniqueIdSubArray [list \
            length        length                    \
            sub_unique    subUniqueId               ]

    array set ipV6OptionMIpV6AlternativeCoaSubArray [list \
            length        length                          \
            address       address                         ]

    array set ipV6OptionUserDefineArray [list \
            length        length              \
            value         value               ]

    array set ipV6EnumArray [list                \
            mld         ipV6RouterAlertMLD       \
            rsvp        ipV6RouterAlertRSVP      \
            active_net  ipV6RouterAlertActiveNet ]

    if {[info exists typeArray($type)]} {
        set extCommand $typeArray($type)
        set extArray   ${extCommand}Array
        catch {$extCommand setDefault}
        foreach {arrItem arrValue} [array get $extArray] {
            if {![catch {set $arrItem} extValue] } {
                if {[lsearch [array names ipV6EnumArray] $extValue] != -1} {
                    set extValue $ipV6EnumArray($extValue)
                }
                switch -- $arrItem {
                    value {
                        regsub -all {[.:]} $extValue { } extValue
                    }
                    address {
                        set extValue [::ipv6::expandAddress $extValue]
                    }
                    default {}
                }
            }
            catch {$extCommand config -$arrValue $extValue}
        }
        set retCode [ipV6HopByHop addOption $extCommand]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed ipV6HopByHop addOption $extCommand. \
                    Return code was: $retCode.\n$::ixErrorInfo"
            return $returnList
        }
    }

    keylset returnList status $::SUCCESS
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::getHltStreamIds
#
# Description:
#    This command returns the stream ids that belong on the provided port.
#
# Synopsis:
#    ::ixia::getHltStreamIds
#         port_handle
#
# Arguments:
#    port_handle
#        The port where the streams belong.
#
# Return Values:
#    The list of stream ids.
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

proc ::ixia::getHltStreamIds {port_handle} {
    variable pgid_to_stream

    foreach {c l p} [split $port_handle /] {}

    set tx_streams_argument_list ""

    # Extracts $c,$l,$p leaving only the stream_ids
    catch {regsub -all "(\[0-9\-\]+) $c,$l,$p,(\[0-9\]+)"  \
                [array get pgid_to_stream] {\1} tx_streams_argument_list}

    # Extracts all names and values from other ports
    catch {regsub -all "(\[0-9\-\]+) (\[0-9\]+),(\[0-9\]+),(\[0-9\]+),(\[0-9\]+)" \
                $tx_streams_argument_list {} tx_streams_argument_list}

    # Extracts multiple spaces
    catch {regsub -all "\[ \]+" $tx_streams_argument_list { } \
                tx_streams_argument_list}

    set tx_streams_argument_list [string trim $tx_streams_argument_list]

    return $tx_streams_argument_list
}


##Internal Procedure Header
# Name:
#    ::ixia::getIxiaStreamIds
#
# Description:
#    This command returns the stream ids that belong on the provided port.
#
# Synopsis:
#    ::ixia::getIxiaStreamIds
#         port_handle
#
# Arguments:
#    port_handle
#        The port where the streams belong.
#
# Return Values:
#    The list of stream ids.
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

proc ::ixia::getIxiaStreamIds {port_handle} {
    variable pgid_to_stream

    foreach {c l p} [split $port_handle /] {}

    set stream_ids_on_port ""
    # Extracts all array names leaving only array values
    regsub -all \
            "(\[0-9\-\]+) (\[0-9\]+),(\[0-9\]+),(\[0-9\]+),(\[0-9\]+)" \
            [array get pgid_to_stream] {\2,\3,\4,\5} stream_ids_on_port

    # Extracts $c,$l,$p leaving only the stream_ids
    regsub -all "$c,$l,$p,(\[0-9\]+)" \
            $stream_ids_on_port {\1} stream_ids_on_port
    # Extracts the streams from other ports
    regsub -all "(\[0-9\]+),(\[0-9\]+),(\[0-9\]+),(\[0-9\]+)" \
            $stream_ids_on_port {} stream_ids_on_port
    # Extracts multiple spaces
    regsub -all "\[ \]+" $stream_ids_on_port { } stream_ids_on_port

    set stream_ids_on_port [string trim $stream_ids_on_port]

    return $stream_ids_on_port
}


##Internal Procedure Header
# Name:
#    ::ixia::ipv6ExtHdrSize
#
# Description:
#    This command returns the size of the ipv6 extension headers being used
#    in bytes.
#
# Synopsis:
#    ::ixia::ipv6ExtHdrSize
#
# Arguments:
#
# Return Values:
#    The size of the ipv6 extension headers in bytes
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
proc ::ixia::ipv6ExtHdrSize { args } {
    # Default the size to 0, including any errors hit
    set ipv6Size 0

    # All of these were technically checked in a previous procedure, so type
    # can be ANY
    set optional_args {
        -ipv6_extension_header   ANY
        -ipv6_auth_string        ANY
        -ipv6_auth_payload_len   ANY
        -ipv6_auth_spi           ANY
        -ipv6_auth_seq_num       ANY
        -ipv6_frag_id            ANY
        -ipv6_frag_more_flag     ANY
        -ipv6_frag_offset        ANY
        -ipv6_frag_res_2bit      ANY
        -ipv6_frag_res_8bit      ANY
        -ipv6_hop_by_hop_options ANY
        -ipv6_routing_node_list  ANY
        -ipv6_routing_res        ANY
    }

    if {[catch {::ixia::parse_dashed_args -args $args -optional_args \
            $optional_args} err]} {
        return $ipv6Size
    }

    if {![info exists ipv6_extension_header]} {
        return $ipv6Size
    }

    # Step through each type in the list
    set index 0
    foreach extType $ipv6_extension_header {
        switch -exact -- $extType {
            authentication {
                # ipv6_auth_payload_len, ipv6_auth_spi, ipv6_auth_seq_num,
                # ipv6_auth_string
                if {[info exists ipv6_auth_payload_len]} {
                    set data [lindex $ipv6_auth_payload_len $index]
                    set tempSize 12
                    incr tempSize [expr ($data - 1) * 4]
                    incr ipv6Size $tempSize
                }
            }
            destination {
                # none
            }
            fragment {
                # ipv6_frag_offset, ipv6_frag_more, ipv6_frag_id,
                # ipv6_frag_res_2bit and ipv6_frag_res_8bit
                incr ipv6Size 8
            }
            hop_by_hop {
                # ipv6_hop_by_hop_options
                if {[info exists ipv6_hop_by_hop_options]} {
                    set hopByHopOpts [lindex $ipv6_hop_by_hop_options $index]
                    if {![catch {keylkeys hopByHopOpts} test]} {
                        # The call failed, so we need to make the existing
                        # data into a list
                        set hopByHopOpts [list $hopByHopOpts]
                    }

                    foreach optionSet $hopByHopOpts {
                        if {[catch {keylkeys optionSet} ipv6Keys]} {
                            set ipv6Keys ""
                        }

                        set typeIndex [lsearch $ipv6Keys type]

                        if {$typeIndex == -1} {
                            continue
                        }

                        switch -exact -- [keylget optionSet type] {
                            padn {
                                set index [lsearch $ipv6Keys length]
                                if {$index != -1} {
                                    incr ipv6Size \
                                            [expr 2 + [keylget optionSet length]]
                                }
                            }
                            pad1 {
                                incr ipv6Size 1
                            }
                            jumbo {
                                set index [lsearch $ipv6Keys length]
                                if {$index != -1} {
                                    incr ipv6Size \
                                            [expr 2 + [keylget optionSet length]]
                                }
                            }
                            router_alert {
                                set index [lsearch $ipv6Keys length]
                                if {$index != -1} {
                                    incr ipv6Size \
                                            [expr 2 + [keylget optionSet length]]
                                }
                            }
                            binding_update {
                                incr ipv6Size 10
                            }
                            binding_ack {
                                incr ipv6Size 13
                            }
                            binding_req {
                                incr ipv6Size 2
                            }
                            mipv6_unique_id_sub {
                                incr ipv6Size 4
                            }
                            mipv6_alternative_coa_sub {
                                incr ipv6Size 18
                            }
                            default {
                            }
                        }
                    }

                }
            }
            routing {
                # ipv6_routing_node_list and ipv6_routing_res
                set tempSize 8
                if {[info exists ipv6_routing_node_list]} {
                    set data [lindex $ipv6_routing_node_list $index]
                    incr tempSize [expr 16 * [llength $data]]
                }
                incr ipv6Size $tempSize
            }
            none -
            default {
                # Nothing in size to add
            }
        }

        incr index
    }

    return $ipv6Size
}


##Internal Procedure Header
# Name:
#    ::ixia::setTableUdf
#
# Description:
#    This command sets the table udf for a stream.
#
# Synopsis:
#    ::ixia::setTableUdf
#
# Arguments:
#
# Return Values:
#    A key list
#    key:status        value:$::SUCCESS | $::FAILURE.
#    key:log           value:When status is failure, contains more information
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
proc ::ixia::setTableUdf {args} {

    set mandatory_args {
        -port_handle
        -mode
    }

    set opt_args {
        -table_udf_column_name
        -table_udf_column_type
        -table_udf_column_offset
        -table_udf_column_size
        -table_udf_rows
    }

    if {[catch {::ixia::parse_dashed_args -args $args \
            -optional_args $opt_args          \
            -mandatory_args $mandatory_args} parseError]} {

        keylset returnList status $::FAILURE
        keylset returnList log $parseError
        return $returnList
    }

    foreach {chassis card port} [split $port_handle /] {}

    # Table UDF
    set table_udf_params [list      \
            table_udf_column_name   \
            table_udf_column_type   \
            table_udf_column_size   \
            table_udf_column_offset \
            table_udf_rows          ]

    set table_udf_num_cols   0
    set table_udf_num_params 0

    # Check if all -table_udf options are provided
    foreach {table_param} $table_udf_params {
        if {[info exists $table_param]} {
            incr table_udf_num_params
            if {$table_param != "table_udf_rows" && $table_param != "table_udf_column_name"} {
                if {$table_udf_num_cols == 0} {
                    set table_udf_num_cols [llength [set $table_param]]
                } else {
                    if {$table_udf_num_cols != [llength [set $table_param]]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "Table udf arguments\
                                -table_udf_column_name,\
                                -table_udf_column_type,\
                                -table_udf_column_size,\
                                -table_udf_column_offset\
                                must have the same length on port: $chassis\
                                $card $port to be used."
                        return $returnList
                    }
                }
            } elseif {$table_param == "table_udf_rows"} {
                if {[llength table_udf_rows] == 0} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "-table_udf_rows must have at least\
                            one element on port: $chassis $card $port to be\
                            able to be used."
                    return $returnList
                }
            }
        }
    }
    
    if {$table_udf_num_cols == 1 && [info exists table_udf_column_name]} {
        if {[llength $table_udf_column_name] > $table_udf_num_cols} {
            set table_udf_column_name [list $table_udf_column_name]
        }
    }
    array set tableUdfColumnTypes [list \
            hex      formatTypeHex      \
            ascii    formatTypeAscii    \
            mac      formatTypeMAC      \
            binary   formatTypeBinary   \
            ipv4     formatTypeIPv4     \
            ipv6     formatTypeIPv6     \
            decimal  formatTypeDecimal  \
            custom   formatTypeCustom   ]

    # Configure table udf if all -table_udf options were provided
    if {$table_udf_num_params == [llength $table_udf_params]} {
        # Check if table udf is valid feature on port
        if {![port isValidFeature $chassis $card $port \
                portFeatureTableUdf]} {

            keylset returnList status $::FAILURE
            keylset returnList log "\
                    Table UDF is not a valid feature for\
                    port $chassis $card $port."
            return $returnList
        }

        tableUdf setDefault
        tableUdf clearColumns
        tableUdf clearRows
        tableUdf config -enable $::true
        set column_type_mac ""
        set column_type_ipv6 ""
        # Add columns
        for {set i 0} {$i < $table_udf_num_cols} {incr i} {
            tableUdfColumn setDefault

            # Remove extra spaces from column name and add ""
            set column_name_temp [lindex $table_udf_column_name   $i]
            set column_name_temp [string trim $column_name_temp]
            set column_name_temp [string trim $column_name_temp {\"}]
            set column_name_temp [string trim $column_name_temp]
            set column_name_temp "\"${column_name_temp}\""

            tableUdfColumn config -name  $column_name_temp
            tableUdfColumn config -offset       \
                    [lindex $table_udf_column_offset $i]
            tableUdfColumn config -size         \
                    [lindex $table_udf_column_size   $i]

            set column_type_temp [lindex $table_udf_column_type $i]
            # Create the list of indices for mac/ipv6 address types
            if {$column_type_temp == "mac"} {
                lappend column_type_mac $i
            } elseif {$column_type_temp == "ipv6"} {
                lappend column_type_ipv6 $i
            }
            # Add custom types if provided
            if {[info exists tableUdfColumnTypes($column_type_temp)]} {
                tableUdfColumn config -formatType   \
                        $tableUdfColumnTypes($column_type_temp)
            } else  {
                tableUdfColumn config -formatType   \
                        $tableUdfColumnTypes(custom)
                tableUdfColumn config -customFormat \
                        [lindex $table_udf_column_type $i]
            }

            if {[tableUdf addColumn]} {
                keylset returnList status $::FAILURE
                keylset returnList log "\
                        Failed to tableUdf addColumn, with formatType\
                        [lindex $table_udf_column_type $i],\
                        $::ixErrorInfo"
                return $returnList
            }
        }

        # If only one row is provided then the provided list must be
        # set as a keyed list
        if {([llength [lindex $table_udf_rows 0]] != 2) && \
                ([llength $table_udf_rows] == 2)} {

            set table_udf_temp $table_udf_rows
            unset table_udf_rows
            keylset table_udf_rows [lindex $table_udf_temp 0] \
                    [lindex $table_udf_temp 1]
        }

        # Add rows
        set tableRows [lsort -dictionary [keylkeys table_udf_rows]]
        foreach rowItem $tableRows {
            set rowValue [keylget table_udf_rows $rowItem]
            foreach c_index $column_type_mac {
                set rowValue [lreplace $rowValue $c_index $c_index  \
                        [::ixia::convertToIxiaMac [lindex $rowValue \
                        $c_index]]]
            }
            foreach c_index $column_type_ipv6 {
                set rowValue [lreplace $rowValue $c_index $c_index \
                        [::ipv6::expandAddress [lindex $rowValue   \
                        $c_index]]]
            }
            if {[tableUdf addRow $rowValue]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Failed to\
                        tableUdf addRow $rowValue, $::ixErrorInfo"
                return $returnList
            }
        }
        if {[tableUdf set $chassis $card $port]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Failed to \
                    tableUdf set $chassis $card $port"
            return $returnList
        }
    }
    keylset returnList status $::SUCCESS
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::startTraffic
#
# Description:
#    This command starts the traffic on the given ports, using duration
#    if given
#
# Synopsis:
#    ::ixia::startTraffic
#
# Arguments:
#
# Return Values:
#    A key list
#    key:status        value:$::SUCCESS | $::FAILURE.
#    key:log           value:When status is failure, contains more information
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
proc ::ixia::startTraffic { Port_list duration } {

    upvar $Port_list port_list

    keylset returnList status $::SUCCESS

    if {$duration != 0} {
        set retCode [ixSetScheduledTransmitTime port_list $duration]
        puts "ixSetScheduledTransmitTime port_list $duration: $retCode"
        if {$retCode} {
            # Failed to set the duration via this command, so use a blocking call
            if {[ixStartTransmit port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not start\
                        traffic on port(s): $port_list"
            }
            after $duration
            if {[ixStopTransmit port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not stop\
                        traffic on port(s): $port_list"
            }
        } else {
            if {[ixStartTransmit port_list]} {
                keylset returnList status $::FAILURE
                keylset returnList log "Could not start\
                        traffic on port(s): $port_list"
            }
        }
    } else {
        if {[ixStartTransmit port_list]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Could not start traffic\
                    on port(s): $port_list"
        }
    }

    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::addDhcpOptions
#
# Description:
#    Sets the DHCP header options
#
# Synopsis:
#    ::ixia::addDhcpOptions
#        procName
#        dhcp_option
#        [dhcp_option_data]
#
# Arguments:
#        procName         - the procedure where ::ixia::addDhcpOptions is called
#        dhcp_option      - the option types that should be added to the header
#        dhcp_option_data - the data contained by each DHCP option
#
# Return Values:
#    A key list
#    key:status        value:$::SUCCESS | $::FAILURE.
#    key:log           value:When status is failure, contains more information
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
proc ::ixia::addDhcpOptions {procName dhcp_option {dhcp_option_data ""} } {
    array set dhcpOptionsArray {
        dhcp_pad                           {dhcpPad                       none                none}
        dhcp_end                           {dhcpEnd                       none                none}
        dhcp_subnet_mask                   {dhcpSubnetMask                ip                  1}
        dhcp_time_offset                   {dhcpTimeOffset                0-4294967295        1}
        dhcp_gateways                      {dhcpGateways                  ip                  array}
        dhcp_time_server                   {dhcpTimeServer                ip                  array}
        dhcp_name_server                   {dhcpNameServer                ip                  array}
        dhcp_domain_name_server            {dhcpDomainNameServer          ip                  array}
        dhcp_log_server                    {dhcpLogServer                 ip                  array}
        dhcp_cookie_server                 {dhcpCookieServer              ip                  array}
        dhcp_lpr_server                    {dhcpLPRServer                 ip                  array}
        dhcp_impress_server                {dhcpImpressServer             ip                  array}
        dhcp_resource_location_server      {dhcpResourceLocationServer    ip                  array}
        dhcp_host_name                     {dhcpHostName                  string              1}
        dhcp_boot_file_size                {dhcpBootFileSize              0-65535             1}
        dhcp_merit_dump_file               {dhcpMeritDumpFile             string              1}
        dhcp_domain_name                   {dhcpDomainName                string              1}
        dhcp_swap_server                   {dhcpSwapServer                ip                  1}
        dhcp_root_path                     {dhcpRootPath                  string              1}
        dhcp_extension_path                {dhcpExtensionPath             string              1}
        dhcp_ip_forwarding_enable          {dhcpIpForwardingEnable        bit                 1}
        dhcp_non_local_src_routing_enable  {dhcpNonLocalSrcRoutingEnable  bit                 1}
        dhcp_policy_filter                 {dhcpPolicyFilter              ip                  array}
        dhcp_max_datagram_reassembly_size  {dhcpMaxDatagramReassemblySize 0-65535             1}
        dhcp_default_ip_ttl                {dhcpDefaultIpTTL              hex_byte            1}
        dhcp_path_mtu_aging_timeout        {dhcpPathMTUAgingTimeout       0-4294967295        1}
        dhcp_path_mtu_plateau_table        {dhcpPathMTUPlateauTable       0-65535             array}
        dhcp_interface_mtu                 {dhcpInterfaceMTU              0-65535             1}
        dhcp_all_subnets_are_local         {dhcpAllSubnetsAreLocal        bit                 1}
        dhcp_broadcast_address             {dhcpBroadcastAddress          ip                  1}
        dhcp_perform_mask_discovery        {dhcpPerformMaskDiscovery      bit                 1}
        dhcp_mask_supplier                 {dhcpMaskSupplier              bit                 1}
        dhcp_perform_router_discovery      {dhcpPerformRouterDiscovery    bit                 1}
        dhcp_router_solicit_addr           {dhcpRouterSolicitAddr         ip                  1}
        dhcp_static_route                  {dhcpStaticRoute               ip                  array}
        dhcp_trailer_encapsulation         {dhcpTrailerEncapsulation      bit                 1}
        dhcp_arp_cache_timeout             {dhcpARPCacheTimeout           0-4294967295        1}
        dhcp_ethernet_encapsulation        {dhcpEthernetEncapsulation     bit                 1}
        dhcp_tcp_default_ttl               {dhcpTCPDefaultTTL             bit                 1}
        dhcp_tcp_keep_alive_interval       {dhcpTCPKeepAliveInterval      0-4294967295        1}
        dhcp_tcp_keep_garbage              {dhcpTCPKeepGarbage            bit                 1}
        dhcp_nis_domain                    {dhcpNISDomain                 string              1}
        dhcp_nis_server                    {dhcpNISServer                 ip                  array}
        dhcp_ntp_server                    {dhcpNTPServer                 ip                  array}
        dhcp_vendor_specific_info          {dhcpVendorSpecificInfo        hex_byte            1}
        dhcp_net_bios_name_svr             {dhcpNetBIOSNameSvr            ip                  array}
        dhcp_net_bios_datagram_dist_svr    {dhcpNetBIOSDatagramDistSvr    ip                  1}
        dhcp_net_bios_node_type            {dhcpNetBIOSNodeType           hex_byte            1}
        dhcp_net_bios_scope                {dhcpNetBIOSScope              hex_byte            array}
        dhcp_xwin_sys_font_svr             {dhcpXWinSysFontSvr            ip                  1}
        dhcp_requested_ip_addr             {dhcpRequestedIPAddr           ip                  1}
        dhcp_ip_addr_lease_time            {dhcpIPAddrLeaseTime           0-4294967295        1}
        dhcp_option_overload               {dhcpOptionOverload            bit                 1}
        dhcp_tftp_svr_name                 {dhcpTFTPSvrName               string              1}
        dhcp_boot_file_name                {dhcpBootFileName              string              1}
        dhcp_message_type                  {dhcpMessageType               1-9                 1}
        dhcp_svr_identifier                {dhcpSvrIdentifier             ip                  1}
        dhcp_param_request_list            {dhcpParamRequestList          hex_byte            array}
        dhcp_message                       {dhcpMessage                   string              1}
        dhcp_max_message_size              {dhcpMaxMessageSize            0-65535             1}
        dhcp_renewal_time_value            {dhcpRenewalTimeValue          0-4294967295        1}
        dhcp_rebinding_time_value          {dhcpRebindingTimeValue        0-4294967295        1}
        dhcp_vendor_class_id               {dhcpVendorClassId             hex_byte            array}
        dhcp_client_id                     {dhcpClientId                  hex_byte            array}
        dhcp_xwin_sys_display_mgr          {dhcpXWinSysDisplayMgr         ip                  1}
        dhcp_nis_plus_domain               {dhcpNISplusDomain             string              1}
        dhcp_nis_plus_server               {dhcpNISplusServer             ip                  array}
        dhcp_mobile_ip_home_agent          {dhcpMobileIPHomeAgent         ip                  array}
        dhcp_smtp_svr                      {dhcpSMTPSvr                   ip                  1}
        dhcp_pop3_svr                      {dhcpPOP3Svr                   ip                  1}
        dhcp_nntp_svr                      {dhcpNNTPSvr                   ip                  1}
        dhcp_www_svr                       {dhcpWWWSvr                    ip                  1}
        dhcp_default_finger_svr            {dhcpDefaultFingerSvr          ip                  1}
        dhcp_default_irc_svr               {dhcpDefaultIRCSvr             ip                  1}
        dhcp_street_talk_svr               {dhcpStreetTalkSvr             ip                  1}
        dhcp_stda_svr                      {dhcpSTDASvr                   ip                  1}
        dhcp_agent_information_option      {dhcpAgentInformationOption    hex_byte            array}
        dhcp_netware_ip_domain             {dhcpNetwareIpDomain           ip                  1}
        dhcp_network_ip_option             {dhcpNetworkIpOption           hex_byte            array}
    }

    if {([llength $dhcp_option] == 1) && ([llength $dhcp_option_data] > 1) || \
            ([llength $dhcp_option] == 2) && ([lindex $dhcp_option 1] == "dhcp_end") && \
            ([llength $dhcp_option_data] > 1)} {
        set dhcp_option_data [list $dhcp_option_data]
        debug "here"
    }

    set dhcp_index 0
    set dhcp_options_size 0

    foreach {dhcpOpt} $dhcp_option {
        if {![info exists dhcpOptionsArray($dhcpOpt)]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    Invalid dhcp option $dhcpOpt."
            return $returnList
        }
        set dhcpOption       [lindex $dhcpOptionsArray($dhcpOpt) 0]
        set dhcpOptType      [lindex $dhcpOptionsArray($dhcpOpt) 1]
        set dhcpOptNumValues [lindex $dhcpOptionsArray($dhcpOpt) 2]
        set dhcpData         [lindex $dhcp_option_data $dhcp_index]

        # Check for a list of predefined dhcp options
        set regNum [regsub -all {(dhcp_[a-zA-Z0-9_]+)} $dhcpData \
                {[lindex $dhcpOptionsArray(\1) 0]} dhcpDataTemp]

        set invalidDhcpOption [catch {set dhcpData [subst $dhcpDataTemp]}]

        if {($regNum != [llength $dhcpData]) || $invalidDhcpOption} {
            switch -- $dhcpOptType {
                ip {
                    if {([llength $dhcpData] > 1) && ($dhcpOptNumValues != "array")} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                Invalid number of values for dhcp\
                                option $dhcpOpt."
                        return $returnList
                    }

                    if {([expr [llength $dhcpData] % 2] == 1) && \
                            ($dhcpOpt == "dhcp_static_route")} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                the DHCP Static Route option must take a pair \
                                of IPs as argument: the first is the \
                                destination IP address and the second is the \
                                next hop address."
                        return $returnList
                    }

                    if {([expr [llength $dhcpData] % 2] == 1) && \
                            ($dhcpOpt == "dhcp_policy_filter")} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                the DHCP Policy Filter option must take a pair \
                                of IPs as argument: the first is the \
                                destination IP address and the second is the \
                                netmask of the destination address."
                        return $returnList
                    }

                    foreach {dhcpIp} $dhcpData {
                        if {![isIpAddressValid $dhcpIp]} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    Invalid IP address $dhcpIp for dhcp\
                                    option $dhcpOpt."
                            return $returnList
                        }
                    }

                    set dhcp_options_size [expr $dhcp_options_size + [expr [llength $dhcpData] * 4] + 2]
                }
                hex_byte {
                    if {([llength $dhcpData] > 1) && ($dhcpOptNumValues != "array")} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                Invalid number of values for dhcp\
                                option $dhcpOpt."
                        return $returnList
                    }

                    if {$dhcpOptNumValues == 1} {
                        set reg "\[0-9a-fA-F\]{2}"
                    } elseif {$dhcpOptNumValues == "array"} {
                        set reg "\[0-9a-fA-F\]{2}((.|:)\[0-9a-fA-F\]{2})*"
                    }

                    if {![regexp $reg $dhcpData dhcpDataIgnore]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                Invalid hex value $dhcpData for dhcp\
                                option $dhcpOpt."
                        return $returnList
                    }

                    set elemIndex 1
                    set dhcpDataTemp ""
                    foreach {dhcpElem} $dhcpData {
                        regsub -all {[.]{1}} $dhcpElem { } dhcpElem
                        regsub -all {[:]{1}} $dhcpElem { } dhcpElem

                        if {([llength $dhcpElem] > 1) && ($dhcpOptNumValues != "array")} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    Invalid number of values for dhcp\
                                    option $dhcpOpt."
                            return $returnList
                        }

                        if {$dhcpOpt == "dhcp_network_ip_option"} {
                            set dhcpElem "[format %02x $elemIndex] [format %02x \
                                    [llength $dhcpElem]] $dhcpElem"
                        }

                        if {$dhcpOpt == "dhcp_default_ip_ttl" || \
                                $dhcpOpt == "dhcp_net_bios_node_type"} {
                            append dhcpDataTemp " [format %d 0x$dhcpElem]"
                        } else {
                            append dhcpDataTemp " $dhcpElem"
                        }

                        incr elemIndex

                        set dhcp_options_size [expr $dhcp_options_size + [llength $dhcpElem]]
                    }
                    set dhcpData [string trim $dhcpDataTemp]

                    set dhcp_options_size [expr $dhcp_options_size + 2]
                }
                bit {
                    if {$dhcpOptNumValues == 1} {
                        set reg "\[0-1\]"
                    } elseif {$dhcpOptNumValues == "array"} {
                        set reg "\[0-1\]+"
                    }

                    if {![regexp $reg $dhcpData dhcpDataIgnore]} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                Invalid bit value $dhcpData for dhcp\
                                option $dhcpOpt."
                        return $returnList
                    }

                    set dhcp_options_size [expr $dhcp_options_size + [llength $dhcpData] + 2]
                }
                1-9 {
                    if {([llength $dhcpData] > 1) && ($dhcpOptNumValues != "array")} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                Invalid number of values for dhcp\
                                option $dhcpOpt."
                        return $returnList
                    }
                    foreach {dhcpNum} $dhcpData {
                        if {($dhcpNum < 1) || ($dhcpNum > 9)} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    Invalid numeric value $dhcpNum for dhcp\
                                    option $dhcpOpt. A number between\
                                    [lindex [split $dhcpOptType "-"] 0]\
                                    and [lindex [split $dhcpOptType "-"] 1]\
                                    is required."
                            return $returnList
                        }
                    }

                    set dhcp_options_size [expr $dhcp_options_size + [llength $dhcpData] + 2]
                }
                0-65535 {
                    if {([llength $dhcpData] > 1) && ($dhcpOptNumValues != "array")} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                Invalid number of values for dhcp\
                                option $dhcpOpt."
                        return $returnList
                    }
                    foreach {dhcpNum} $dhcpData {
                        if {($dhcpNum < 0) || ($dhcpNum > 65535)} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    Invalid numeric value $dhcpNum for dhcp\
                                    option $dhcpOpt. A number between\
                                    [lindex [split $dhcpOptType "-"] 0]\
                                    and [lindex [split $dhcpOptType "-"] 1]\
                                    is required."
                            return $returnList
                        }
                    }

                    set dhcp_options_size [expr $dhcp_options_size + [expr [llength $dhcpData] * 2] + 2]
                }
                0-4294967295 {
                    if {([llength $dhcpData] > 1) && ($dhcpOptNumValues != "array")} {
                        keylset returnList status $::FAILURE
                        keylset returnList log "ERROR in $procName: \
                                Invalid number of values for dhcp\
                                option $dhcpOpt."
                        return $returnList
                    }
                    foreach {dhcpNum} $dhcpData {
                        if {($dhcpNum < 0) || ($dhcpNum > 4294967295)} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: \
                                    Invalid numeric value $dhcpNum for dhcp\
                                    option $dhcpOpt. A number between\
                                    [lindex [split $dhcpOptType "-"] 0]\
                                    and [lindex [split $dhcpOptType "-"] 1]\
                                    is required."
                            return $returnList
                        }
                    }

                    set dhcp_options_size [expr $dhcp_options_size + [expr [llength $dhcpData] * 4] + 2]
                }
                string {
                    set dhcp_options_size [expr $dhcp_options_size + [string length $dhcpData] + 3]
                }
            }
        }
        
        if {$dhcpOption == "dhcpEnd"} {
            incr dhcp_options_size
        }

        dhcp config -optionData $dhcpData
        debug "dhcp config -optionData {$dhcpData}"

        debug "dhcp setOption $dhcpOption"
        if {[dhcp setOption $dhcpOption]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    Failed to set dhcp option $dhcpOption. $::ixErrorInfo"
            return $returnList
        }
        incr dhcp_index
    }

    keylset returnList status $::SUCCESS
    keylset returnList size $dhcp_options_size
    return $returnList
}

proc ::ixia::setFrameGapRatio {portHandle frameGapRatio} {
    # The frameGapRatio will be:
    # ( (frame_size + preamble)/(frame_size + preamble + frame_gap) )*100
    
    variable ::ixia::frameGapMessage
    keylset returnList status $::SUCCESS
    
    set stdErrorMsg "Failed to configure frame_gap_ratio on port $portHandle"
    
    scan $portHandle "%d %d %d" ch ca po
    
    if {[catch {port getFeature $ch $ca $po "minimumInterFrameGap"} retVal]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$stdErrorMsg. Port getFeature\
                'minimumInterFrameGap' returned $retVal"
        return $returnList
    }
    
    if {$retVal == ""} {
        keylset returnList status $::FAILURE
        keylset returnList log "$stdErrorMsg. Frame Gap options are not supported"
        return $returnList
    }
    
    # MIN IFG in nanoseconds
    set minIfg [lindex [keylget retVal minimumInterFrameGap] 0]
    debug "minIfg = $minIfg"
    
    if {[catch {port getFeature $ch $ca $po "maximumInterFrameGap"} retVal]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$stdErrorMsg. Port getFeature\
                'maximumInterFrameGap' returned $retVal"
        return $returnList
    }
    
    if {$retVal == ""} {
        keylset returnList status $::FAILURE
        keylset returnList log "$stdErrorMsg. Frame Gap options are not supported"
        return $returnList
    }
    
    # MAX IFG in nanoseconds
    set maxIfg [lindex [keylget retVal maximumInterFrameGap] 0]
    debug "maxIfg = $maxIfg"
    
    if {[catch {port getFeature $ch $ca $po "minimumPreambleSize"} retVal]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$stdErrorMsg. Port getFeature\
                'minimumPreambleSize' returned $retVal"
        return $returnList
    }

    if {$retVal == "" || [port isActiveFeature $ch $ca $po portFeaturePos] || \
            [port isActiveFeature $ch $ca $po portFeatureAtm]} {
        set preambleSize 0
    } else {
        if {[catch {stream cget -preambleSize} retVal]} {
            keylset returnList status $::FAILURE
            keylset returnList log "$stdErrorMsg. Unable to get stream\
                    preambleSize."
            return $returnList
        }
        set preambleSize $retVal
    }
    
    debug "preambleSize = $preambleSize"
    
    if {[catch {stream cget -framesize} retVal]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$stdErrorMsg. Unable to get stream framesize."
        return $returnList
    }
    # Frame size in bytes
    set frameSize $retVal
    debug "frameSize = $frameSize"
    
    if {[catch {stat getLineSpeed $ch $ca $po} retVal]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$stdErrorMsg. Unable to get port line speed."
        return $returnList
    }
    # Line speed in Mbps
    set lineSpeed $retVal
    
    set tmpStatus [::ixia::calcFrameGapRatio $frameSize $preambleSize \
            $frameGapRatio $lineSpeed]
    if {[keylget tmpStatus status] != $::SUCCESS} {
        keylset returnList status $::FAILURE
        keylset returnList log "$stdErrorMsg. [keylget tmpStatus log]"
        return $returnList
    }
    # IFG in milliseconds
    set interFrameGap [keylget tmpStatus value]
    debug "interFrameGap = $interFrameGap"
    
    #############################################################################
    # Determine if requested frame_gap_ratio will result in an IFG out of range #
    #############################################################################
    
    # Inferior Limit for frame gap ratio in milliseconds
    set infIFGLimit [mpexpr $minIfg * pow(10,-6)]
    debug "infIFGLimit=$infIFGLimit"

    # Superior Limit for frame gap ratio in milliseconds
    set supIFGLimit [mpexpr $maxIfg * pow(10,-6)]
    debug "supIFGLimit=$supIFGLimit"
    
    if {$interFrameGap == "infinite"} {
        # rate_frame_gap was 0. Assign it the largest frame gap possible.
        set interFrameGap [mpexpr $supIFGLimit + 1]
    }
    
    if {$interFrameGap < $infIFGLimit} {
        set interFrameGap $infIFGLimit
        
        set tmpStatus [::ixia::calcFrameGapRatio $frameSize $preambleSize \
                $interFrameGap $lineSpeed "IFG2frameGapRatio"]
                
        if {[keylget tmpStatus status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "$stdErrorMsg. [keylget tmpStatus log]"
            return $returnList
        }
        set tmpMessage "Adjusted Frame Gap Ratio to maximum value\
                [keylget tmpStatus value]%"
        if {![info exists frameGapMessage] || $frameGapMessage != $tmpMessage} {
            set frameGapMessage $tmpMessage
            puts $tmpMessage
        }
    } elseif {$interFrameGap > $supIFGLimit} {
        set interFrameGap $supIFGLimit
        
        set tmpStatus [::ixia::calcFrameGapRatio $frameSize $preambleSize \
                $interFrameGap $lineSpeed "IFG2frameGapRatio"]
                
        if {[keylget tmpStatus status] != $::SUCCESS} {
            keylset returnList status $::FAILURE
            keylset returnList log "$stdErrorMsg. [keylget tmpStatus log]"
            return $returnList
        }
        set tmpMessage "Adjusted Frame Gap Ratio to minimum value\
                [keylget tmpStatus value]%"
        if {![info exists frameGapMessage] || $frameGapMessage != $tmpMessage} {
            set frameGapMessage $tmpMessage
            puts $tmpMessage
        }
    }
    
    debug "stream configure -ifg $interFrameGap"
    if {[catch {stream configure -ifg $interFrameGap} retVal]} {
        keylset returnList status $::FAILURE
        keylset returnList log "$stdErrorMsg. Unable to configure stream\
                inter frame gap."
        return $returnList
    }
    
    return $returnList
}


proc ::ixia::setStreamConfig {               \
        chassis                              \
        card                                 \
        port                                 \
        queue_id                             \
        stream_id                            \
        ixaccess_emulated_stream_status      \
        protocolOffsetEnable                 \
        rate_frame_gap                       \
        customSet                            \
        {mode "create"}                      } {

    # If new parameters are added to this procedure leave "mode" parameter 
    # the last one, because it is added only in certain situations and it is
    # always added after all other parameters
    
    # customSet is a way to force 'stream set' to act in one of the predefined
    # ways:
    # '_noVal_' - (DEFAULT) All parameters are taken into account
    # 'set_then_get' - Only 'stream set' then 'stream get' is performed
    # 'set_only' - Only 'stream set' is performed
    
    keylset returnList status $::SUCCESS
    
    if {$customSet == "_noVal_"} {
        if {$ixaccess_emulated_stream_status != "_noVal_" && \
                    $protocolOffsetEnable == 1} {
            set __frame_size [stream cget -framesize]
            set retCode [::ixia::setPPPoXPayloadFramesize \
                        $ixaccess_emulated_stream_status $__frame_size $chassis $card $port]
    
            if {[keylget retCode status] != $::SUCCESS} {
                return $retCode
            }
        }
    
        
        if {$rate_frame_gap != "_noVal_"} {
            set frame_gap_status [::ixia::setFrameGapRatio \
                    [list $chassis $card $port] $rate_frame_gap]
            if {[keylget frame_gap_status status] != $::SUCCESS} {
                keylset returnList status $::FAILURE
                keylset returnList log "[keylget frame_gap_status log]"
                return $returnList
            }
        }
    }
    
    if {[port isActiveFeature $chassis $card $port portFeatureAtm]} {
        set retCode [stream setQueue $chassis $card $port $queue_id \
                $stream_id]
        if {$retCode == 0 && $mode == "create" && $customSet != "set_only"} {
            set retCode [stream getQueue $chassis $card $port $queue_id \
                    $stream_id]
        }
    } else  {
        set retCode [stream set $chassis $card $port $stream_id]
        if {$retCode == 0 && $mode == "create" && $customSet != "set_only"} {
            set retCode [stream get $chassis $card $port $stream_id]
        }
    }
    
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "Unable to set stream: $stream_id on port:\
                {$chassis $card $port}"
        return $returnList
    }
    
    return $returnList
}

proc ::ixia::waitForTrafficState { ixn_traffic tr_generator target_action wait_limit } {
    if { $target_action == "start" } {
        set state4new   started
        set state4old   true
    } elseif { $target_action == "stop"} {
        set state4new   stopped
        set state4old   false
    } else {
        # implement if new states are considered
        set state4new   none
        set state4old   none
    }
    if {$tr_generator == "ixnetwork_540"} {
        set target_attribute state
        set desired_state    $state4new
    } else {
        set target_attribute isTrafficRunning
        set desired_state    $state4old
    }
    set moved_to_desired_state 0
    set wait_timer 0
    set wait_limit [expr $wait_limit * 1000]
    after 200
    set traffic_response [ixNet getAttribute $ixn_traffic -$target_attribute]
    while {$traffic_response != $desired_state} {
        after 200
        set traffic_response [ixNet getAttribute $ixn_traffic -$target_attribute]
        incr wait_timer 200
        
        if {[string first $desired_state $traffic_response] != -1} {
            set moved_to_desired_state 1
            continue
        }
        
        if {$moved_to_desired_state == 1} {
            break
        }
        
        if {$wait_timer > $wait_limit} {
            return timed_out
        }
    }
    return $::SUCCESS
}


##Internal Procedure Header
# Name:
#    ::ixia::cleanupTrafficStatsArrays
#
# Description:
#    Unsets the array created in the traffic_stats procedure.
#
# Arguments:
#        array_list       - list of array names that must be unset
#
# Notes:
#    Each array name must be global and start with the ::ixia:: prefix
#    If the array_list parameter is empty then the procedure will unset
#    all the available ::ixia::traffic_stats_returned_keyed_array_<id> arrays
#
# traffic_stats_returned_keyed_array_$traffic_stats_num_calls
proc ::ixia::cleanupTrafficStatsArrays { {array_list ""} } {
    if { $array_list == "" } {;# erase all the traffic_stats existing arrays
        for {set i 0} {$i < $::ixia::traffic_stats_num_calls} {incr i} {
            catch {array unset ::ixia::traffic_stats_returned_keyed_array_$i}
        }
    } else {;# erase only the arrays that are given as list
        foreach array_name $array_list {
            catch {array unset $array_name}
        }
    }
}
