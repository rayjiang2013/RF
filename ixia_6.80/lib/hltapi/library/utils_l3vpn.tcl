##Library Header
# $Id: $
# Copyright © 2003-2005 by IXIA
# All Rights Reserved.
#
# Name:
#    utils_l3vpn_streams.tcl
#
# Purpose:
#     A script development library containing utility procs for L3VPN
#     stream generation APIs for test automation with the Ixia chassis.
#
# Author:
#    D. Rusu
#
# Usage:
#
# Description:
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
#    ::ixia::l3vpnBgpGetLearnedVpnRoutes
#
# Description:
#    This command returns the networks and received labels learned in VRF on 
#    the specified BGP routers on the specified port. When the router handle 
#    list is not specified the labels from all routers on the port are 
#    returned.
#
# Synopsis:
#    ::ixia::l3vpnBgpGetLearnedVpnRoutes chassis card port handleList
# 
# Arguments:
#    chassis
#    card
#    port
#    handleList
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:On status of failure, gives detailed information.
#    key:record    value:A keyed list containing learned records.
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
proc ::ixia::l3vpnBgpGetLearnedVpnRoutes {chassis card port {handleList ""}} {
    upvar procName procName
    variable    peBgpLearnedRoutes
    array unset peBgpLearnedRoutes
    array set   peBgpLearnedRoutes ""
    
    set retCode [bgp4Server select $chassis $card $port]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Call to bgp4Server\
                select $chassis $card $port failed.  Return code\
                was $retCode."
        return $returnList
    }
    
    if {$handleList != ""} {
        foreach handle $handleList {
            set neighborRetCode [bgp4Server getNeighbor $handle]
            if {$neighborRetCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to bgp4Server\
                        getNeighbor $handle failed.  Return code\
                        was $neighborRetCode."
                return $returnList
            }
            ::ixia::l3vpnBgpGetLearnedRoutesCurrentNeighbor
        }
    } else  {
        debug "bgp4Server getFirstNeighbor"
        set neighborRetCode [bgp4Server getFirstNeighbor]
        while {$neighborRetCode == 0} {
            ::ixia::l3vpnBgpGetLearnedRoutesCurrentNeighbor
            set neighborRetCode [bgp4Server getNextNeighbor]
        }
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList record [array get peBgpLearnedRoutes]
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::l3vpnBgpGetLearnedRoutesCurrentNeighbor
#
# Description:
#    This command returns the networks and received labels learned in VRF on
#    the current BGP router.
#
# Synopsis:
#    ::ixia::l3vpnBgpGetLearnedRoutesCurrentNeighbor
#
# Arguments:
#
# Return Values:
#    A keyed list
#    key:nextHop   value:Next hop information for the learned route.
#    key:network   value:Learned route.
#    key:netmask   value:Learned route netmask.
#    key:label     value:Learned label associated with the route.
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
proc ::ixia::l3vpnBgpGetLearnedRoutesCurrentNeighbor {} {
    variable  peBgpLearnedRoutes
    
    # When neighbor is disabled don't do anything
    if {![bgp4Neighbor cget -enable]} {
        return
    }
    
    set siteRetCode [bgp4Neighbor getFirstL3Site]
    debug "bgp4Neighbor getFirstL3Site"
    while {$siteRetCode == 0} {
        debug "bgp4VpnL3Site requestLearnedRoutes"
        bgp4VpnL3Site requestLearnedRoutes
        set requestResult [bgp4VpnL3Site getLearnedRouteList]
        for {set i 0} {($requestResult != 0) && ($i < 5)} {incr i} {
            after 3000
            set requestResult [bgp4VpnL3Site getLearnedRouteList]
        }
        
        if {$requestResult == 0} {
            debug "bgp4LearnedRoute getFirst bgp4FamilyIpV4MplsVpn"
            set learnedRetCode [bgp4LearnedRoute getFirst bgp4FamilyIpV4MplsVpn]
            while {$learnedRetCode == 0} {
                set ipAddress          [bgp4LearnedRoute cget -ipAddress          ]
                set prefixLen          [bgp4LearnedRoute cget -prefixLength       ]
                set label              [bgp4LearnedRoute cget -label              ]
                set routeDistinguisher [bgp4LearnedRoute cget -routeDistinguisher ]
                set neighborIp         [bgp4Neighbor     cget -localIpAddress]
                
                if {[bgp4Neighbor cget -enableNextHop]} {
                    set nextHop [bgp4Neighbor cget -nextHop]
                } else  {
                    set nextHop [bgp4Neighbor cget -dutIpAddress]
                }
                
                if {[info exists peBgpLearnedRoutes($ipAddress/$prefixLen)]} {
                    set result $peBgpLearnedRoutes($ipAddress/$prefixLen)
                    set neighborIp [concat $neighborIp [keylget \
                            peBgpLearnedRoutes($ipAddress/$prefixLen) neighbor]]
                    
                    set neighborIp [lsort -unique $neighborIp]
                }
                
                keylset result                        \
                        nextHop   $nextHop            \
                        network   $ipAddress          \
                        netmask   $prefixLen          \
                        label     $label              \
                        rd        $routeDistinguisher \
                        neighbor  $neighborIp
                
                set peBgpLearnedRoutes($ipAddress/$prefixLen) $result
                debug "bgp4LearnedRoute getNext  bgp4FamilyIpV4MplsVpn"
                set learnedRetCode [bgp4LearnedRoute getNext \
                        bgp4FamilyIpV4MplsVpn]
            }
        }
        debug "bgp4Neighbor getNextL3Site"
        set siteRetCode [bgp4Neighbor getNextL3Site]
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnLdpGetLearnedLabels
#
# Description:
#    This command returns the networks and received labels learned on 
#    the specified LDP routers on the specified port. When the router 
#    handle list is not specified the labels from all routers on the 
#    port are returned.
#
# Synopsis:
#    ::ixia::l3vpnLdpGetLearnedLabels chassis card port handleList
#
# Arguments:
#    chassis
#    card
#    port
#    handleList
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:On status of failure, gives detailed information.
#    key:record    value:A keyed list containing learned records.
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
proc ::ixia::l3vpnLdpGetLearnedLabels {chassis card port {handleList ""}} {
    upvar procName procName
    set result ""
    
    set retCode [ldpServer select $chassis $card $port]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Call to ldpServer\
                select $chassis $card $port failed.  Return code\
                was $retCode."
        return $returnList
    }
    
    if {$handleList != ""} {
        foreach handle $handleList {
            set routerRetCode [ldpServer getRouter $handle]
            if {$routerRetCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to ldpServer\
                        getRouter $handle failed.  Return code\
                        was $routerRetCode."
                return $returnList
            }
            set result [concat $result \
                    [::ixia::l3vpnLdpGetLabelsCurrentRouter]]
        }
    } else  {
        set routerRetCode [ldpServer getFirstRouter]
        while {$routerRetCode == 0} {
            set result [concat $result \
                    [::ixia::l3vpnLdpGetLabelsCurrentRouter]]
            set routerRetCode [ldpServer getNextRouter]
        }
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList record $result
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::l3vpnLdpGetLabelsCurrentRouter
#
# Description:
#    This command returns the networks and received labels learned on
#    the current LDP router.
#
# Synopsis:
#    ::ixia::l3vpnLdpGetLabelsCurrentRouter
#
# Arguments:
#
# Return Values:
#    A keyed list
#    key:network   value:Learned route.
#    key:netmask   value:Learned route netmask.
#    key:label     value:Learned label associated with the route.
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
proc ::ixia::l3vpnLdpGetLabelsCurrentRouter {} {
    set result ""
    
    # When router is disabled don't do anything
    if {![ldpRouter cget -enable]} {
        return $result
    }
    
    set interfaceRetCode [ldpRouter getFirstInterface]
    while {$interfaceRetCode == 0} {
        ldpInterface requestLearnedLabels
        set requestResult [ldpInterface getLearnedLabelList]
        for {set i 0} {($requestResult != 0) && ($i < 5)} {incr i} {
            after 3000
            set requestResult [ldpInterface getLearnedLabelList]
        }
        
        if {$requestResult == 0} {
            set labelRetCode [ldpInterface getFirstLearnedIpV4Label]
            while {$labelRetCode == 0} {
                set fec          [ldpLearnedIpV4Label cget -fec             ]
                set prefixLen    [ldpLearnedIpV4Label cget -fecPrefixLength ]
                set label        [ldpLearnedIpV4Label cget -label           ]
                set key [::ixia::ip_addr_to_num $fec]/$prefixLen
                
                keylset result                          \
                        $key.network      $fec          \
                        $key.netmask      $prefixLen    \
                        $key.label        $label
                
                set labelRetCode [ldpInterface getNextLearnedIpV4Label]
            }
        }
        
        set interfaceRetCode [ldpRouter getNextInterface]
    }
    
    return $result
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnRsvpGetLearnedLabels
#
# Description:
#    This command returns the networks and received labels learned on
#    the specified RSVP routers on the specified port. When the router
#    handle list is not specified the labels from all routers on the
#    port are returned.
#
# Synopsis:
#    ::ixia::l3vpnRsvpGetLearnedLabels chassis card port handleList
#
# Arguments:
#    chassis
#    card
#    port
#    handleList
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:On status of failure, gives detailed information.
#    key:record    value:A keyed list containing learned records.
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
proc ::ixia::l3vpnRsvpGetLearnedLabels {chassis card port {handleList ""}} {
    upvar procName procName
    set result ""
    
    set retCode [rsvpServer select $chassis $card $port]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Call to ldpServer\
                select $chassis $card $port failed.  Return code\
                was $retCode."
        return $returnList
    }
    
    if {$handleList != ""} {
        foreach handle $handleList {
            set routerRetCode [rsvpServer getNeighborPair $handle]
            if {$routerRetCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to rsvpServer\
                        getNeighborPair $handle failed.  Return code\
                        was $routerRetCode."
                return $returnList
            }
            set result [concat $result \
                    [::ixia::l3vpnRsvpGetLabelsCurrentNeighbor]]
        }
    } else  {
        set routerRetCode [rsvpServer getFirstNeighborPair]
        while {$routerRetCode == 0} {
            set result [concat $result \
                    [::ixia::l3vpnRsvpGetLabelsCurrentNeighbor]]
            set routerRetCode [rsvpServer getNextNeighborPair]
        }
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList record $result
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnRsvpGetLabelsCurrentNeighbor
#
# Description:
#    This command returns the networks and received labels learned on
#    the current RSVP router.
#
# Synopsis:
#    ::ixia::l3vpnRsvpGetLabelsCurrentNeighbor
#
# Arguments:
#
# Return Values:
#    A keyed list
#    key:network   value:Learned route.
#    key:netmask   value:Learned route netmask.
#    key:label     value:Learned label associated with the route.
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
proc ::ixia::l3vpnRsvpGetLabelsCurrentNeighbor {} {
    array set labels ""
    set result ""
    
    # When router is disabled don't do anything
    if {![rsvpNeighborPair cget -enableNeighborPair]} {
        return $result
    }
    # Get the labels
    rsvpNeighborPair requestRxLabels
    set requestResult [rsvpNeighborPair getLabels]
    for {set i 0} {($requestResult != 0) && ($i < 5)} {incr i} {
        after 3000
        set requestResult [rsvpNeighborPair getLabels]
    }
    if {$requestResult == 0} {
        set labelRetCode [rsvpNeighborPair getFirstLabel]
        while {$labelRetCode == 0} {
            set lspTunnel [rsvpNeighborPair cget -lsp_tunnel]
            set label     [rsvpNeighborPair cget -rxLabel]
            
            set indexStart [expr [string first "Dst: T" $lspTunnel] + 6]
            set indexEnd   [expr [string first ":" $lspTunnel $indexStart] - 1]
            
            set ipAddress  [string range $lspTunnel $indexStart $indexEnd]
            set netmask 32
            set key [::ixia::ip_addr_to_num $ipAddress]/$netmask
            
            keylset result                          \
                    $key.network      $ipAddress    \
                    $key.netmask      $netmask    \
                    $key.label        $label
        
            set labelRetCode [rsvpNeighborPair getNextLabel]
        }
    }
    return $result
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnPEBgpGetRoutes
#
# Description:
#    This command returns the VRF route ranges configured to be advertised
#    on the specified port and BGP router. When the router list is not
#    specified, all VRF route ranges on the port are returned.
#
# Synopsis:
#    ::ixia::l3vpnPEBgpGetRoutes chassis card port neighbor routeRange
#
# Arguments:
#    chassis
#    card
#    port
#    neighbor
#    routeRange
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:On status of failure, gives detailed information.
#    key:route     value:A keyed list containing configured routes.
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
proc ::ixia::l3vpnPEBgpGetRoutes {ch cd pt {neighbor ""} {routeRange ""}} {
    upvar procName procName
    variable    peBgpCfgRoutes
    array unset peBgpCfgRoutes
    array set   peBgpCfgRoutes ""
    
    variable peCurrentBgpRouterIntfParams
    set      peCurrentBgpRouterIntfParams ""
    
    
    set retCode [bgp4Server select $ch $cd $pt]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Call to bgp4Server\
                select $ch $cd $pt failed.  Return code was $retCode."
        return $returnList
    }
    
    if {$neighbor != ""} {
        set i 0
        foreach handle $neighbor {
            set neighborRetCode [bgp4Server getNeighbor $handle]
            if {$neighborRetCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to bgp4Server\
                        getNeighbor $handle failed.  Return code\
                        was $neighborRetCode."
                return $returnList
            }
            if {$routeRange != ""} {
                set rangeHandle [lindex $routeRange $i]
            } else  {
                set rangeHandle ""
            }
            
            set peCurrentBgpRouterIntfParams                   \
                    [::ixia::l3vpnGetBgpInterfaceCurrentRouter \
                    $ch $cd $pt]
            
            if {[keylget peCurrentBgpRouterIntfParams status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget peCurrentBgpRouterIntfParams log]"
                return $returnList
            }
            
            set routeList [::ixia::l3vpnBgpGetVpnRoutesCurrentNeighbor \
                    $rangeHandle]
            if {[keylget routeList status] != $::SUCCESS} {
                return $routeList
            }
            incr i
        }
    } else  {
        set neighborRetCode [bgp4Server getFirstNeighbor]
        while {$neighborRetCode == 0} {
            set peCurrentBgpRouterIntfParams                   \
                    [::ixia::l3vpnGetBgpInterfaceCurrentRouter \
                    $ch $cd $pt]
            
            if {[keylget peCurrentBgpRouterIntfParams status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget peCurrentBgpRouterIntfParams log]"
                return $returnList
            }
            
            set routeList [::ixia::l3vpnBgpGetVpnRoutesCurrentNeighbor]
            if {[keylget routeList status] != $::SUCCESS} {
                return $routeList
            }
            
            set neighborRetCode [bgp4Server getNextNeighbor]
        }
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList route  [array get peBgpCfgRoutes]
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnBgpGetVpnRoutesCurrentNeighbor
#
# Description:
#    This command returns the VRF route ranges configured to be advertised
#    on the current BGP router. When the L3 site list is not specified, all
#    VRF route ranges on the router are returned.
#
# Synopsis:
#    ::ixia::l3vpnBgpGetVpnRoutesCurrentNeighbor routeRange
#
# Arguments:
#    routeRange
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:On status of failure, gives detailed information.
#    key:route     value:A keyed list containing configured routes.
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
proc ::ixia::l3vpnBgpGetVpnRoutesCurrentNeighbor {{routeRange ""}} {
    upvar procName procName
    
    # When neighbor is disabled don't do anything
    if {![bgp4Neighbor cget -enable]} {
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    if {$routeRange != ""} {
        foreach l3Site $routeRange {
            set siteRetCode [bgp4Neighbor getL3Site $l3Site]
            if {$siteRetCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to \
                        bgp4Neighbor getL3Site $l3Site failed.  Return\
                        code was $siteRetCode."
                return $returnList
            }
            ::ixia::l3vpnBgpGetVpnRoutesCurrentSite
        }
    } else  {
        set siteRetCode [bgp4Neighbor getFirstL3Site]
        while {$siteRetCode == 0} {
            ::ixia::l3vpnBgpGetVpnRoutesCurrentSite
            set siteRetCode [bgp4Neighbor getNextL3Site]
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnBgpGetVpnRoutesCurrentSite
#
# Description:
#    This command returns the VRF route ranges configured to be advertised
#    on the current BGP L3 site.
#
# Synopsis:
#    ::ixia::l3vpnBgpGetVpnRoutesCurrentSite
#
# Arguments:
#
# Return Values:
#    A keyed list
#    key:network   value:Advertised network.
#    key:netmask   value:Advertised network mask. 
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
proc ::ixia::l3vpnBgpGetVpnRoutesCurrentSite {} {
    variable peBgpCfgRoutes
    variable peCurrentBgpRouterIntfParams
    
    if {![bgp4VpnL3Site cget -enable]} {
        return
    }
    
    set routeRetCode [bgp4VpnL3Site getFirstVpnRouteRange]
    while {$routeRetCode == 0} {
        if {[bgp4VpnRouteRange cget -enable]} {
            set network         [bgp4VpnRouteRange cget -networkIpAddress]
            set fromPrefix      [bgp4VpnRouteRange cget -fromPrefix]
            set toPrefix        [bgp4VpnRouteRange cget -toPrefix]
            set prefixIncrement [bgp4RouteItem     cget -iterationStep]
            set numRoutes       [bgp4VpnRouteRange cget -numRoutes]
            set rdType          [bgp4VpnRouteRange cget -distinguisherType]
            set rdAssignedNum   [bgp4VpnRouteRange cget -distinguisherAssignedNumber]
            set rdAsNum         [bgp4VpnRouteRange cget -distinguisherAsNumber]
            set rdIp            [bgp4VpnRouteRange cget -distinguisherIpAddress]
            
            if {$rdType == $::bgp4DistinguisherTypeAS} {
                set rd "$rdAsNum:$rdAssignedNum"
            } else  {
                set rd "$rdIp:$rdAssignedNum"
            }
            
            set net $network
            set netmask $fromPrefix
            for {set i 1} {($i <= $numRoutes)} {incr i} {
                #set key [::ixia::ip_addr_to_num $net]/$netmask
                keylset peCurrentBgpRouterIntfParams  \
                        network $net                  \
                        netmask $netmask              \
                        rd      $rd
                
                set peBgpCfgRoutes($net/$netmask) $peCurrentBgpRouterIntfParams
                
                set previousVal [::ixia::ip_addr_to_num $net]
                set net [::ixia::increment_ipv4_net $net $netmask \
                        $prefixIncrement]
                set actualVal [::ixia::ip_addr_to_num $net]
                
                if {($previousVal > $actualVal) && ($netmask < $toPrefix)} {
                    set net $network
                    incr netmask
                }
            }
        }
        set routeRetCode [bgp4VpnL3Site getNextVpnRouteRange]
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnCEGetConfiguredRoutes
#
# Description:
#    This command returns the route ranges configured to be advertised
#    on the specified port and specified router. When the router list
#    is not specified, all route ranges on the port are returned. The
#    router type is specified by the type parameter.
#
# Synopsis:
#    ::ixia::l3vpnCEGetConfiguredRoutes type chassis card port router routeRange
#
# Arguments:
#    type      CHOICES bgp isis ospf rip
#    chassis
#    card
#    port
#    router
#    routeRange
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:On status of failure, gives detailed information.
#    key:route     value:A keyed list containing configured routes.
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
proc ::ixia::l3vpnCEGetConfiguredRoutes {type ch cd pt {router ""} {routeRange ""}} {
    upvar procName procName
    
    switch -- $type {
        bgp {
            set routeList [l3vpnCEBgpGetRoutes $ch $cd $pt $router $routeRange]
        }
        ospf {
            set routeList [l3vpnCEOspfGetRoutes $ch $cd $pt $router $routeRange]
        }
        rip {
            set routeList [l3vpnCERipGetRoutes $ch $cd $pt $router $routeRange]
        }
        isis {
            set routeList [l3vpnCEIsisGetRoutes $ch $cd $pt $router $routeRange]
        }
        default {}
    }
    
    return $routeList
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnCEBgpGetRoutes
#
# Description:
#    This command returns the route ranges configured to be advertised
#    on the specified port and BGP router. When the router list is not
#    specified, all route ranges on the port are returned.
#
# Synopsis:
#    ::ixia::l3vpnCEBgpGetRoutes chassis card port neighbor routeRange
#
# Arguments:
#    chassis
#    card
#    port
#    neighbor
#    routeRange
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:On status of failure, gives detailed information.
#    key:route     value:A keyed list containing configured routes.
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
proc ::ixia::l3vpnCEBgpGetRoutes {ch cd pt {neighbor ""} {routeRange ""}} {
    upvar procName procName
    variable  ceBgpCfgRoutes
    array unset ceBgpCfgRoutes
    array set ceBgpCfgRoutes ""
    
    variable currentBgpRouterIntfParams
    set currentBgpRouterIntfParams ""
    
    set retCode [bgp4Server select $ch $cd $pt]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Call to bgp4Server\
                select $ch $cd $pt failed.  Return code was $retCode."
        return $returnList
    }
    
    if {$neighbor != ""} {
        set i 0
        foreach handle $neighbor {
            set neighborRetCode [bgp4Server getNeighbor $handle]
            if {$neighborRetCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to bgp4Server\
                        getNeighbor $handle failed.  Return code\
                        was $neighborRetCode."
                return $returnList
            }
            if {$routeRange != ""} {
                set rangeHandle [lindex $routeRange $i]
            } else  {
                set rangeHandle ""
            }
            
            set currentBgpRouterIntfParams                     \
                    [::ixia::l3vpnGetBgpInterfaceCurrentRouter \
                    $ch $cd $pt]
            
            if {[keylget currentBgpRouterIntfParams status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget currentBgpRouterIntfParams log]"
                return $returnList
            }
            
            set routeList [::ixia::l3vpnBgpGetRoutesCurrentNeighbor \
                    $rangeHandle]
            if {[keylget routeList status] != $::SUCCESS} {
                return $routeList
            }
            
            incr i
        }
    } else {
        set neighborRetCode [bgp4Server getFirstNeighbor]
        while {$neighborRetCode == 0} {
            set currentBgpRouterIntfParams                     \
                    [::ixia::l3vpnGetBgpInterfaceCurrentRouter \
                    $ch $cd $pt]
            
            if {[keylget currentBgpRouterIntfParams status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget currentBgpRouterIntfParams log]"
                return $returnList
            }
            
            set routeList [::ixia::l3vpnBgpGetRoutesCurrentNeighbor]
            if {[keylget routeList status] != $::SUCCESS} {
                return $routeList
            }
            
            set neighborRetCode [bgp4Server getNextNeighbor]
        }
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList route  [array get ceBgpCfgRoutes]
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnBgpGetRoutesCurrentNeighbor
#
# Description:
#    This command returns the route ranges configured to be advertised
#    on the current BGP router. When the route range list is not specified,
#    all route ranges on the router are returned.
#
# Synopsis:
#    ::ixia::l3vpnBgpGetRoutesCurrentNeighbor routeRange
#
# Arguments:
#    routeRange
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:On status of failure, gives detailed information.
#    key:route     value:A keyed list containing configured routes.
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
proc ::ixia::l3vpnBgpGetRoutesCurrentNeighbor {{routeRange ""}} {
    upvar procName procName
    
    # When neighbor is disabled don't do anything
    if {![bgp4Neighbor cget -enable]} {
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    if {$routeRange != ""} {
        foreach handle $routeRange {
            set routeRetCode [bgp4Neighbor getRouteRange $handle]
            if {$routeRetCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to \
                        bgp4Neighbor getRouteRange $handle failed. \
                        Return code was $routeRetCode."
                return $returnList
            }
            ::ixia::l3vpnBgpGetRoutesCurrentRouteItem
        }
    } else  {
        set routeRetCode [bgp4Neighbor getFirstRouteRange]
        while {$routeRetCode == 0} {
            ::ixia::l3vpnBgpGetRoutesCurrentRouteItem
            set routeRetCode [bgp4Neighbor getNextRouteRange]
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnBgpGetRoutesCurrentRouteItem
#
# Description:
#    This command returns the current BGP route range.
#
# Synopsis:
#    ::ixia::l3vpnBgpGetRoutesCurrentRouteItem
#
# Arguments:
#
# Return Values:
#    A keyed list
#    key:network   value:Advertised network.
#    key:netmask   value:Advertised network mask.
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
proc ::ixia::l3vpnBgpGetRoutesCurrentRouteItem {} {
    variable ceBgpCfgRoutes
    variable currentBgpRouterIntfParams
    
    if {[bgp4RouteItem cget -enableRouteRange] && \
                ([bgp4RouteItem cget -ipType] == $::addressTypeIpV4)} {
        set network         [bgp4RouteItem cget -networkAddress]
        set fromPrefix      [bgp4RouteItem cget -fromPrefix]
        set toPrefix        [bgp4RouteItem cget -thruPrefix]
        set prefixIncrement [bgp4RouteItem cget -iterationStep]
        set numRoutes       [bgp4RouteItem cget -numRoutes]
        
        set net $network
        set netmask $fromPrefix
        for {set i 1} {($i <= $numRoutes)} {incr i} {
            # set key [::ixia::ip_addr_to_num $net]/$netmask
            keylset currentBgpRouterIntfParams  \
                    network $net                \
                    netmask $netmask
            
            set ceBgpCfgRoutes($net/$netmask) $currentBgpRouterIntfParams
            
            set previousVal [::ixia::ip_addr_to_num $net]
            set net [::ixia::increment_ipv4_net $net $netmask \
                    $prefixIncrement]
            set actualVal [::ixia::ip_addr_to_num $net]
            
            if {($previousVal > $actualVal) && ($netmask < $toPrefix)} {
                set net $network
                incr netmask
            }
        }
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnCEOspfGetRoutes
#
# Description:
#    This command returns the route ranges configured to be advertised
#    on the specified port and OSPF router. When the router list is not
#    specified, all route ranges on the port are returned.
#
# Synopsis:
#    ::ixia::l3vpnCEOspfGetRoutes chassis card port neighbor routeRange
#
# Arguments:
#    chassis
#    card
#    port
#    neighbor
#    routeRange
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:On status of failure, gives detailed information.
#    key:route     value:A keyed list containing configured routes.
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
proc ::ixia::l3vpnCEOspfGetRoutes {ch cd pt neighbor routeRange} {
    upvar procName procName
    variable    ceOspfCfgRoutes
    array unset ceOspfCfgRoutes
    array set   ceOspfCfgRoutes ""
    
    variable currentOspfRouterIntfParams
    set currentOspfRouterIntfParams ""
    
    set retCode [ospfServer select $ch $cd $pt]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Call to ospfServer\
                select $ch $cd $pt failed.  Return code was $retCode."
        return $returnList
    }
    
    if {$neighbor != ""} {
        set i 0
        foreach handle $neighbor {
            set routerRetCode [ospfServer getRouter $handle]
            if {$routerRetCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to ospfServer\
                        getRouter $handle failed.  Return code\
                        was $routerRetCode."
                return $returnList
            }
            if {$routeRange != ""} {
                set rangeHandle [lindex $routeRange $i]
            } else  {
                set rangeHandle ""
            }
            set currentOspfRouterIntfParams                     \
                    [::ixia::l3vpnGetOspfInterfaceCurrentRouter \
                    $ch $cd $pt]
            
            if {[keylget currentOspfRouterIntfParams status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget currentOspfRouterIntfParams log]"
                return $returnList
            }
            
            set routeList [::ixia::l3vpnOspfGetRoutesCurrentRouter $rangeHandle]
            if {[keylget routeList status] != $::SUCCESS} {
                return $routeList
            }
            
            incr i
        }
    } else {
        set routerRetCode [ospfServer getFirstRouter]
        while {$routerRetCode == 0} {
            set currentOspfRouterIntfParams                     \
                    [::ixia::l3vpnGetOspfInterfaceCurrentRouter \
                    $ch $cd $pt]
            
            if {[keylget currentOspfRouterIntfParams status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget currentOspfRouterIntfParams log]"
                return $returnList
            }
            
            set routeList [::ixia::l3vpnOspfGetRoutesCurrentRouter]
            if {[keylget routeList status] != $::SUCCESS} {
                return $routeList
            }
            
            set routerRetCode [ospfServer getNextRouter]
        }
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList route  [array get ceOspfCfgRoutes]
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnOspfGetRoutesCurrentRouter
#
# Description:
#    This command returns the route ranges configured to be advertised
#    on the current OSPF router. When the route range list is not specified,
#    all route ranges on the router are returned.
#
# Synopsis:
#    ::ixia::l3vpnOspfGetRoutesCurrentRouter routeRange
#
# Arguments:
#    routeRange
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:On status of failure, gives detailed information.
#    key:route     value:A keyed list containing configured routes.
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
proc ::ixia::l3vpnOspfGetRoutesCurrentRouter {{routeRange ""}} {
    upvar procName procName
    
    # When router is disabled don't do anything
    if {![ospfRouter cget -enable]} {
        keylset returnList status $::SUCCESS
        return $returnList
    }
    if {$routeRange != ""} {
        foreach handle $routeRange {
            set routeRetCode [ospfRouter getRouteRange $handle]
            if {$routeRetCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        ospfRouter getRouteRange $handle failed. \
                        Return code was $routeRetCode."
                return $returnList
            }
            ::ixia::l3vpnOspfGetRoutesCurrentRouteRange
        }
    } else {
        set routeRetCode [ospfRouter getFirstRouteRange]
        while {$routeRetCode == 0} {
            ::ixia::l3vpnOspfGetRoutesCurrentRouteRange
            set routeRetCode [ospfRouter getNextRouteRange]
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnOspfGetRoutesCurrentRouteRange
#
# Description:
#    This command returns the current OSPF route range.
#
# Synopsis:
#    ::ixia::l3vpnOspfGetRoutesCurrentRouteRange
#
# Arguments:
#
# Return Values:
#    A keyed list
#    key:network   value:Advertised network.
#    key:netmask   value:Advertised network mask.
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
proc ::ixia::l3vpnOspfGetRoutesCurrentRouteRange {} {
    variable ceOspfCfgRoutes
    variable currentOspfRouterIntfParams
    
    if {[ospfRouteRange cget -enable]} {
        set network   [ospfRouteRange cget -networkIpAddress]
        set netmask   [ospfRouteRange cget -prefix]
        set numRoutes [ospfRouteRange cget -numberOfNetworks]
        
        set net [::ixia::l3vpnGetIpV4Network $network $netmask]
        for {set i 1} {($i <= $numRoutes) && ($net != "0.0.0.0")} {incr i} {
            #set key [::ixia::ip_addr_to_num $net]/$netmask
            keylset currentOspfRouterIntfParams  \
                    network $net            \
                    netmask $netmask
            
            set ceOspfCfgRoutes($net/$netmask) $currentOspfRouterIntfParams
            
            set net [::ixia::increment_ipv4_net $net $netmask 1]
        }
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnCERipGetRoutes
#
# Description:
#    This command returns the route ranges configured to be advertised
#    on the specified port and RIP router. When the router list is not
#    specified, all route ranges on the port are returned.
#
# Synopsis:
#    ::ixia::l3vpnCERipGetRoutes chassis card port neighbor routeRange
#
# Arguments:
#    chassis
#    card
#    port
#    neighbor
#    routeRange
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:On status of failure, gives detailed information.
#    key:route     value:A keyed list containing configured routes.
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
proc ::ixia::l3vpnCERipGetRoutes {ch cd pt {router ""} {routeRange ""}} {
    upvar procName procName
    variable  ceRipCfgRoutes
    array unset ceRipCfgRoutes
    array set ceRipCfgRoutes ""
    
    variable currentRipRouterIntfParams
    set currentRipRouterIntfParams ""
    
    set retCode [ripServer select $ch $cd $pt]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Call to ripServer\
                select $ch $cd $pt failed.  Return code was $retCode."
        return $returnList
    }
    
    if {$router != ""} {
        set i 0
        foreach handle $router {
            set routerRetCode [ripServer getRouter $handle]
            if {$routerRetCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to ripServer\
                        getRouter $handle failed.  Return code\
                        was $routerRetCode."
                return $returnList
            }
            if {$routeRange != ""} {
                set rangeHandle [lindex $routeRange $i]
            } else {
                set rangeHandle ""
            }
            set currentRipRouterIntfParams                     \
                    [::ixia::l3vpnGetRipInterfaceCurrentRouter \
                    $ch $cd $pt]
            
            if {[keylget currentRipRouterIntfParams status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget currentRipRouterIntfParams log]"
                return $returnList
            }
            
            set routeList [::ixia::l3vpnRipGetRoutesCurrentRouter $rangeHandle]
            if {[keylget routeList status] != $::SUCCESS} {
                return $routeList
            }
            
            incr i
        }
    } else {
        set routerRetCode [ripServer getFirstRouter]
        while {$routerRetCode == 0} {
            set currentRipRouterIntfParams                     \
                    [::ixia::l3vpnGetRipInterfaceCurrentRouter \
                    $ch $cd $pt]
            
            if {[keylget currentRipRouterIntfParams status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget currentRipRouterIntfParams log]"
                return $returnList
            }
            
            set routeList [::ixia::l3vpnRipGetRoutesCurrentRouter]
            if {[keylget routeList status] != $::SUCCESS} {
                return $routeList
            }
            
            set routerRetCode [ripServer getNextRouter]
        }
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList route  [array get ceRipCfgRoutes]
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnRipGetRoutesCurrentRouter
#
# Description:
#    This command returns the route ranges configured to be advertised
#    on the current RIP router. When the route range list is not specified,
#    all route ranges on the router are returned.
#
# Synopsis:
#    ::ixia::l3vpnRipGetRoutesCurrentRouter routeRange
#
# Arguments:
#    routeRange
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:On status of failure, gives detailed information.
#    key:route     value:A keyed list containing configured routes.
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
proc ::ixia::l3vpnRipGetRoutesCurrentRouter {{routeRange ""}} {
    upvar procName procName
    
    # When router is disabled don't do anything
    if {![ripInterfaceRouter cget -enableRouter]} {
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    if {$routeRange != ""} {
        foreach handle $routeRange {
            set routeRetCode [ripInterfaceRouter getRouteRange $handle]
            if {$routeRetCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        ripInterfaceRouter getRouteRange $handle failed. \
                        Return code was $routeRetCode."
                return $returnList
            }
            ::ixia::l3vpnRipGetRoutesCurrentRouteRange
        }
    } else {
        set siteRetCode [ripInterfaceRouter getFirstRouteRange]
        while {$siteRetCode == 0} {
            ::ixia::l3vpnRipGetRoutesCurrentRouteRange
            set siteRetCode [ripInterfaceRouter getNextRouteRange]
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnRipGetRoutesCurrentRouteRange
#
# Description:
#    This command returns the current RIP route range.
#
# Synopsis:
#    ::ixia::l3vpnRipGetRoutesCurrentRouteRange
#
# Arguments:
#
# Return Values:
#    A keyed list
#    key:network   value:Advertised network.
#    key:netmask   value:Advertised network mask.
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
proc ::ixia::l3vpnRipGetRoutesCurrentRouteRange {} {
    variable ceRipCfgRoutes
    variable currentRipRouterIntfParams
    
    if {[ripRouteRange cget -enableRouteRange]} {
        set network   [ripRouteRange cget -networkIpAddress]
        set netmask   [ripRouteRange cget -networkMaskWidth]
        set numRoutes [ripRouteRange cget -numberOfNetworks]
        
        set net [::ixia::l3vpnGetIpV4Network $network $netmask]
        for {set i 1} {($i <= $numRoutes) && ($net != "0.0.0.0")} {incr i} {
            #set key [::ixia::ip_addr_to_num $net]/$netmask
            keylset currentRipRouterIntfParams  \
                    network $net                \
                    netmask $netmask
            
            set ceRipCfgRoutes($net/$netmask) $currentRipRouterIntfParams
            
            set net [::ixia::increment_ipv4_net $net $netmask 1]
        }
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnCEIsisGetRoutes
#
# Description:
#    This command returns the route ranges configured to be advertised
#    on the specified port and ISIS router. When the router list is not
#    specified, all route ranges on the port are returned.
#
# Synopsis:
#    ::ixia::l3vpnCEIsisGetRoutes chassis card port neighbor routeRange
#
# Arguments:
#    chassis
#    card
#    port
#    neighbor
#    routeRange
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:On status of failure, gives detailed information.
#    key:route     value:A keyed list containing configured routes.
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
proc ::ixia::l3vpnCEIsisGetRoutes {ch cd pt {router ""} {routeRange ""}} {
    upvar procName procName
    variable  ceIsisCfgRoutes
    array unset ceIsisCfgRoutes
    array set ceIsisCfgRoutes ""
    
    variable currentIsisRouterIntfParams
    set currentIsisRouterIntfParams ""
        
    set retCode [isisServer select $ch $cd $pt]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Call to isisServer\
                select $ch $cd $pt failed.  Return code was $retCode."
        return $returnList
    }
    
    if {$router != ""} {
        set i 0
        foreach handle $router {
            set routerRetCode [isisServer getRouter $handle]
            if {$routerRetCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to isisServer\
                        getRouter $handle failed.  Return code\
                        was $routerRetCode."
                return $returnList
            }
            if {$routeRange != ""} {
                set rangeHandle [lindex $routeRange $i]
            } else {
                set rangeHandle ""
            }
            
            set currentIsisRouterIntfParams                     \
                    [::ixia::l3vpnGetIsisInterfaceCurrentRouter \
                    $ch $cd $pt]
            
            if {[keylget currentIsisRouterIntfParams status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget currentIsisRouterIntfParams log]"
                return $returnList
            }
            
            
            set routeList [::ixia::l3vpnIsisGetRoutesCurrentRouter $rangeHandle]
            if {[keylget routeList status] != $::SUCCESS} {
                return $routeList
            }
            incr i
        }
    } else {
        set routerRetCode [isisServer getFirstRouter]
        while {$routerRetCode == 0} {
            set currentIsisRouterIntfParams                     \
                    [::ixia::l3vpnGetIsisInterfaceCurrentRouter \
                    $ch $cd $pt]
            
            if {[keylget currentIsisRouterIntfParams status] == $::FAILURE} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: \
                        [keylget currentIsisRouterIntfParams log]"
                return $returnList
            }
            
            set routeList [::ixia::l3vpnIsisGetRoutesCurrentRouter]
            if {[keylget routeList status] != $::SUCCESS} {
                return $routeList
            }
            
            set routerRetCode [isisServer getNextRouter]
        }
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList route  [array get ceIsisCfgRoutes]
    return $returnList
}

proc ::ixia::l3vpnGetIsisInterfaceCurrentRouter {ch cd pt} {
    for {set intfRetCode [isisRouter getFirstInterface]}  \
            {$intfRetCode == 0}                           \
            {set intfRetCode [isisRouter getFirstInterface]} {
        
        set protIntfDescr [isisInterface cget \
                -protocolInterfaceDescription ]
                
        if {$protIntfDescr == ""} {
            continue;
        }
        set parameterList [list \
                vlan_id mac_address atm_encap atm_vpi atm_vci]
        
        set retParam [::ixia::get_interface_parameter \
                -port_handle $ch/$cd/$pt    \
                -description $protIntfDescr \
                -parameter   $parameterList ]
        
        return $retParam
    }
}

proc ::ixia::l3vpnGetOspfInterfaceCurrentRouter {ch cd pt} {
    for {set intfRetCode [ospfRouter getFirstInterface]}  \
            {$intfRetCode == 0}                           \
            {set intfRetCode [ospfRouter getFirstInterface]} {
        
        set protIntfDescr [ospfInterface cget \
                -protocolInterfaceDescription ]
        
        if {$protIntfDescr == ""} {
            continue;
        }
        set parameterList [list \
                vlan_id mac_address atm_encap atm_vpi atm_vci]
        
        set retParam [::ixia::get_interface_parameter \
                -port_handle $ch/$cd/$pt    \
                -description $protIntfDescr \
                -parameter   $parameterList ]
        
        return $retParam
    }
}

proc ::ixia::l3vpnGetRipInterfaceCurrentRouter {ch cd pt} {
    set protIntfDescr [ripInterfaceRouter cget \
            -protocolInterfaceDescription ]
    
    set parameterList [list \
            vlan_id mac_address atm_encap atm_vpi atm_vci]
    
    set retParam [::ixia::get_interface_parameter \
            -port_handle $ch/$cd/$pt    \
            -description $protIntfDescr \
            -parameter   $parameterList ]
    
    return $retParam
}

proc ::ixia::l3vpnGetBgpInterfaceCurrentRouter {ch cd pt} {
    
    set routedRet [::ixia::interface_exists            \
            -ip_address  [bgp4Neighbor cget -localIpAddress ] \
            -ip_version  4                                    \
            -port_handle $ch/$cd/$pt                          \
            -type        routed                               ]
    
    if {[keylget routedRet status] != 0} {
        set routedDescr [keylget routedRet description]
        set paramList [list \
                vlan_id mac_address atm_encap atm_vpi atm_vci ipv4_gateway]
        
        set routedRetParam [::ixia::get_interface_parameter \
                -port_handle $ch/$cd/$pt      \
                -description $routedDescr     \
                -parameter   $paramList       ]
        
        if {[keylget routedRetParam status] == 0} {
            return $routedRetParam
        }
        
        set connectedRet [::ixia::interface_exists                 \
                -ip_address  [keylget routedRetParam ipv4_gateway] \
                -ip_version  4                                     \
                -port_handle $ch/$cd/$pt                           ]
        
        if {[keylget connectedRet status] == 0} {
            return $connectedRet
        }
        set connectedDescr [keylget connectedRet description]
        
        set connectedRetParam [::ixia::get_interface_parameter \
                -port_handle $ch/$cd/$pt      \
                -description $connectedDescr  \
                -parameter   $paramList       ]
        
        if {[keylget connectedRetParam status] == 0} {
            return $connectedRetParam
        }
        
        keylset routedRetParam vlan_id     [keylget connectedRetParam vlan_id]
        keylset routedRetParam mac_address [keylget connectedRetParam mac_address]
        
        debug "Routed: $routedRetParam"
        return $routedRetParam
    }
    
    set protIntfDescrRet [::ixia::interface_exists            \
            -ip_address  [bgp4Neighbor cget -localIpAddress ] \
            -ip_version  4                                    \
            -port_handle $ch/$cd/$pt                          ]
    
    if {[keylget protIntfDescrRet status] == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "Cannot find interface with IP\
                [bgp4Neighbor cget -localIpAddress ]"
    }
    
    set protIntfDescr [keylget protIntfDescrRet description]
    set parameterList [list \
            vlan_id mac_address atm_encap atm_vpi atm_vci]
    
    set retParam [::ixia::get_interface_parameter \
            -port_handle $ch/$cd/$pt    \
            -description $protIntfDescr \
            -parameter   $parameterList ]
    
    debug "Connected: $retParam"
    return $retParam
}

##Internal Procedure Header
# Name:
#    ::ixia::l3vpnIsisGetRoutesCurrentRouter
#
# Description:
#    This command returns the route ranges configured to be advertised
#    on the current ISIS router. When the route range list is not specified,
#    all route ranges on the router are returned.
#
# Synopsis:
#    ::ixia::l3vpnIsisGetRoutesCurrentRouter routeRange
#
# Arguments:
#    routeRange
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:On status of failure, gives detailed information.
#    key:route     value:A keyed list containing configured routes.
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
proc ::ixia::l3vpnIsisGetRoutesCurrentRouter {{routeRange ""}} {
    upvar procName procName
    
    # When router is disabled don't do anything
    if {![isisRouter cget -enable]} {
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    if {$routeRange != ""} {
        foreach handle $routeRange {
            set routeRetCode [isisRouter getRouteRange $handle]
            if {$routeRetCode} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: Call to\
                        isisRouter getRouteRange $handle failed. \
                        Return code was $routeRetCode."
                return $returnList
            }
            ::ixia::l3vpnIsisGetRoutesCurrentRouteRange
        }
    } else {
        set routeRetCode [isisRouter getFirstRouteRange]
        while {$routeRetCode == 0} {
            ::ixia::l3vpnIsisGetRoutesCurrentRouteRange
            set routeRetCode [isisRouter getNextRouteRange]
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnIsisGetRoutesCurrentRouteRange
#
# Description:
#    This command returns the current ISIS route range.
#
# Synopsis:
#    ::ixia::l3vpnIsisGetRoutesCurrentRouteRange
#
# Arguments:
#
# Return Values:
#    A keyed list
#    key:network   value:Advertised network.
#    key:netmask   value:Advertised network mask.
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
proc ::ixia::l3vpnIsisGetRoutesCurrentRouteRange {} {
    variable ceIsisCfgRoutes
    variable currentIsisRouterIntfParams
    
    if {[isisRouteRange cget -enable] && \
            ([isisRouteRange cget -ipType] == $::addressTypeIpV4)} {
        set network   [isisRouteRange cget -networkIpAddress]
        set netmask   [isisRouteRange cget -prefix]
        set numRoutes [isisRouteRange cget -numberOfNetworks]
        
        set net [::ixia::l3vpnGetIpV4Network $network $netmask]
        for {set i 1} {($i <= $numRoutes) && ($net != "0.0.0.0")} {incr i} {
            #set key [::ixia::ip_addr_to_num $net]/$netmask
            keylset currentIsisRouterIntfParams  \
                    network $net            \
                    netmask $netmask
            
            set ceIsisCfgRoutes($net/$netmask) $currentIsisRouterIntfParams
            
            set net [::ixia::increment_ipv4_net $net $netmask 1]
        }
    }
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnGenerateCEStream
#
# Description:
#     This command configures traffic streams on the specified CE port
#     based on the specified routeList, which is a keyed list.
#     The last parameter specifies the parameters for traffic_config.
#
# Synopsis:
#    ::ixia::l3vpnGenerateCEStream chassis card port routeList trafficArgs
#
# Arguments:
#    chassis
#    card
#    port
#    routeList
#    vpnRouteList
#    trafficArgs
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:On status of failure, gives detailed information.
#    key:stream    value:Stream identifiers for traffic sent out the CE port.
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
proc ::ixia::l3vpnGenerateCEStream {ch cd pt peCfgRouteList ceMatchedRouteList trafficArgs} {
    upvar procName procName
    array unset peCfgRoutes
    array set peCfgRoutes $peCfgRouteList
    upvar $ceMatchedRouteList ceMatchedRoutes
    set streamList ""
    
    set table_udf_column_name   ""
    set table_udf_column_type   ""
    set table_udf_column_size   ""
    set table_udf_column_offset ""
    set table_udf_rows          ""
    set count 0
    foreach {ce_key} [keylkeys ceMatchedRoutes] {
        set ipHeaderOffset  14
        set macHeaderOffset 0
        if {[keylget ceMatchedRoutes $ce_key.vlan_id] != ""} {
            incr ipHeaderOffset 4
            set vlan   "enable"
            set vlanId [keylget ceMatchedRoutes $ce_key.vlan_id]
            set table_udf_column_name   { "Src Ip" "Dst Ip"  "Mac Address" "Vlan"}
            set table_udf_column_type   {ipv4 ipv4  mac decimal}
            set table_udf_column_size   { 4   4     6   2      }
            set table_udf_column_offset [list    \
                    [expr $ipHeaderOffset  + 12] \
                    [expr $ipHeaderOffset  + 16] \
                    [expr $macHeaderOffset + 6]  \
                    [expr $ipHeaderOffset  - 4]  ]
        } else {
            set vlan   "disable"
            set vlanId 0
            set table_udf_column_name   { "Src Ip" "Dst Ip"  "Mac Address" }
            set table_udf_column_type   {ipv4 ipv4 mac}
            set table_udf_column_size   { 4   4     6 }
            set table_udf_column_offset [list    \
                    [expr $ipHeaderOffset  + 12] \
                    [expr $ipHeaderOffset  + 16] \
                    [expr $macHeaderOffset + 6]  ]
        }
        set srcMac [keylget ceMatchedRoutes $ce_key.mac_address]
        set srcIp  [::ixia::increment_ipv4_address_hltapi \
                [keylget ceMatchedRoutes $ce_key.network] 0.0.0.1]
        
        set rdIntf [keylget ceMatchedRoutes $ce_key.rd]
        
        foreach key [array names peCfgRoutes] {
            set network  [keylget peCfgRoutes($key) network]
            set netmask  [keylget peCfgRoutes($key) netmask]
            set rd       [keylget peCfgRoutes($key) rd]
            if {$rd != $rdIntf} { continue }
            
            set dstIp [::ixia::increment_ipv4_address_hltapi \
                    $network 0.0.0.1]
            
            if {$vlan == "enable"} {
                keylset table_udf_rows row_$count [list \
                        $srcIp $dstIp $srcMac $vlanId]
            } else  {
                keylset table_udf_rows row_$count [list \
                        $srcIp $dstIp $srcMac]
            }
            incr count
        }
    }
    
    if {$table_udf_rows == ""} {
        keylset returnList status $::FAILURE
        keylset returnList log    "ERROR in $procName: \
                Failed to create CE streams. There is no information available\
                to create table udf."
        return $returnList
    }
    
    set trafficCommand [list ::ixia::traffic_config       \
            -mode          create                         \
            -port_handle   $ch/$cd/$pt                    \
            -ip_src_addr   0.0.0.0                        \
            -ip_src_mode   fixed                          \
            -ip_dst_addr   0.0.0.0                        \
            -ip_dst_mode   fixed                          \
            -l3_protocol   ipv4                           \
            -vlan          $vlan                          \
            -mac_dst_mode  discovery                      \
            -mac_src_mode  fixed                          \
            -table_udf_column_name      $table_udf_column_name   \
            -table_udf_column_size      $table_udf_column_size   \
            -table_udf_column_type      $table_udf_column_type   \
            -table_udf_column_offset    $table_udf_column_offset \
            -table_udf_rows             $table_udf_rows          \
            -no_write                                            ]
    
    if {$vlan == "enable"} {
        lappend trafficCommand           \
                -vlan_id       $vlanId   \
                -vlan_id_count 1
    }
    debug "$trafficCommand $trafficArgs"
    set trafficList [eval $trafficCommand $trafficArgs]
    
    if {[keylget trafficList status] != $::SUCCESS} {
        return $trafficList
    }
    lappend streamList [keylget trafficList stream_id]
    
    keylset returnList status $::SUCCESS
    keylset returnList stream $streamList
    return $returnList
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnGeneratePEStream
#
# Description:
#     This command configures traffic streams on the specified PE port
#     based on the specified routeList, which is a keyed list. labelProtocol
#     parameter specifies which protocol is used for retriving the labels.
#     The last parameter specifies the parameters for traffic_config.
#
# Synopsis:
#    ::ixia::l3vpnGeneratePEStream labelProtocol chassis card port routeList
#
# Arguments:
#    labelProtocol
#    chassis
#    card
#    port
#    routeList
#    trafficArgs
#
# Return Values:
#    A keyed list
#    key:status    value:$::SUCCESS | $::FAILURE
#    key:log       value:On status of failure, gives detailed information.
#    key:stream    value:Stream identifiers for traffic sent out the PE port.
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
proc ::ixia::l3vpnGeneratePEStream {
    ch cd pt peCfgRouteList ceMatchedRouteList learnedLabelRouteList
    trafficArgs
} {
    
    upvar procName procName
    array unset peCfgRoutes
    array set   peCfgRoutes      $peCfgRouteList
    upvar $ceMatchedRouteList    ceMatchedRoutes
    upvar $learnedLabelRouteList learnedLabelRoutes
    
    set streamList ""
    
    set portMode [::ixia::l3vpnIsEthernetInterface $ch $cd $pt]
    if {[keylget portMode status] == $::FAILURE} {
        return $portMode
    }
    
    set table_udf_column_name   ""
    set table_udf_column_type   ""
    set table_udf_column_offset ""
    set table_udf_column_size   ""
    set table_udf_rows          ""
    set i 1
    foreach {peCfgRoute} [array names peCfgRoutes] {
        set peRd      [keylget peCfgRoutes($peCfgRoute) rd]
        set peNetwork [keylget peCfgRoutes($peCfgRoute) network]
        set peNetmask [keylget peCfgRoutes($peCfgRoute) netmask]
        set peVlan    [keylget peCfgRoutes($peCfgRoute) vlan_id]
        set peIp      [::ixia::increment_ipv4_address_hltapi \
                $peNetwork 0.0.0.1]
        
        if {$peVlan == ""} {
            set vlan   "disable"
            set vlanId 0
        } else  {
            set vlan   "enable"
            set vlanId $peVlan
        }
        
        foreach {ceMatchedRoute} [keylkeys ceMatchedRoutes] {
            set ipHeaderOffset  14
            set macHeaderOffset 0
            
            set ceRd       [keylget ceMatchedRoutes $ceMatchedRoute.rd]
            set ceNetwork  [keylget ceMatchedRoutes $ceMatchedRoute.network]
            set ceNetmask  [keylget ceMatchedRoutes $ceMatchedRoute.netmask]
            set ceNextHop  [keylget ceMatchedRoutes $ceMatchedRoute.nextHop]
            set ceVpnLabel [keylget ceMatchedRoutes $ceMatchedRoute.label]
            set ceIp       [::ixia::increment_ipv4_address_hltapi \
                    $ceNetwork 0.0.0.1]
            
            if {$peRd != $ceRd} {
                continue;
            }
            set ceMplsLabel [::ixia::l3vpnGetMatchingLabel \
                    $ceNextHop learnedLabelRoutes]
            
            if {$ceMplsLabel == ""} {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: No label found\
                        for next hop $ceNextHop."
                return $returnList
            }
            set mplsLabels ""
            if {$ceMplsLabel != 3} {
                lappend mplsLabels $ceMplsLabel
            }
            lappend mplsLabels [list $ceVpnLabel]
            
            set table_udf_column_name   { "Src Ip" "Dst Ip"  "Mac Address" }
            set table_udf_column_type   {ipv4 ipv4 mac}
            set table_udf_column_size   {4    4    6}
            set table_udf_column_offset {
                [expr $ipHeaderOffset  + 12]
                [expr $ipHeaderOffset  + 16]
                [expr $macHeaderOffset + 6]
            }
            set table_udf_row_list [list $peIp $ceIp \
                    "00 00 [::ixia::convert_v4_addr_to_hex $peIp]"]
            
            if {$peVlan != ""} {
                lappend table_udf_column_name    "VlanId"
                lappend table_udf_column_type    decimal
                lappend table_udf_column_size    4
                append  table_udf_column_offset  " $ipHeaderOffset"
                lappend table_udf_row_list       $peVlan
                incr ipHeaderOffset 4
            }
            set count 1
            if {[set precedence_pos [lsearch $trafficArgs \
                        "-ip_precedence"]] != -1} {
                
                set ip_precedence [lindex $trafficArgs \
                        [expr $precedence_pos + 1]]
            } else  {
                set ip_precedence 0
            }
            foreach {mplsLabel} $mplsLabels {
                if {$count < [llength $mplsLabels]} {
                    set stack_bit 0x0
                } else  {
                    # set bottom of stack bit on the last label
                    set stack_bit 0x1
                }
                set hex1_5 [format %05x $mplsLabel]
                set hex6   [format %1x  [expr \
                        ($ip_precedence << 1) | $stack_bit]]
                
                set hex7_8 40
                
                set mplsHex "${hex1_5}${hex6}${hex7_8}"
                
                lappend table_udf_column_name    "MPLS $count"
                lappend table_udf_column_type    hex
                lappend table_udf_column_size    4
                append  table_udf_column_offset  " $ipHeaderOffset"
                lappend table_udf_row_list       $mplsHex
                incr ipHeaderOffset 4
                incr count
            }
            
            set table_udf_column_offset   [subst $table_udf_column_offset]
            keylset table_udf_rows row_$i $table_udf_row_list
            incr i
        }
    }
    
    if {$table_udf_rows == ""} {
        keylset returnList status $::FAILURE
        keylset returnList log    "ERROR in $procName: \
                Failed to create PE streams. There is no information available\
                to create table udf."
        return $returnList
    }
    
    set trafficCommand [list ::ixia::traffic_config                     \
            -mode                         create                        \
            -port_handle                  $ch/$cd/$pt                   \
            -ip_src_addr                  0.0.0.0                       \
            -ip_src_mode                  fixed                         \
            -ip_dst_addr                  0.0.0.0                       \
            -ip_dst_mode                  fixed                         \
            -l3_protocol                  ipv4                          \
            -vlan                         $vlan                         \
            -mac_dst_mode                 discovery                     \
            -mac_src_mode                 fixed                         \
            -table_udf_column_name        $table_udf_column_name        \
            -table_udf_column_size        $table_udf_column_size        \
            -table_udf_column_type        $table_udf_column_type        \
            -table_udf_column_offset      $table_udf_column_offset      \
            -table_udf_rows               $table_udf_rows               \
            -mpls                         enable                        \
            -mpls_bottom_stack_bit        1                             \
            -mpls_type                    unicast                       \
            -mpls_labels                  $mplsLabels                   \
            -no_write                                                   \
            ]
    
    if {$vlan == "enable"} {
        lappend trafficCommand          \
                -vlan_id        $vlanId \
                -vlan_id_count  1
    }
    
    debug "$trafficCommand $trafficArgs"
    set trafficList [eval $trafficCommand $trafficArgs]
    if {[keylget trafficList status] != $::SUCCESS} {
        return $trafficList
    }
    lappend streamList [keylget trafficList stream_id]
    
    keylset returnList status $::SUCCESS
    keylset returnList stream $streamList
    return $returnList
}




##Internal Procedure Header
# Name:
#    ::ixia::l3vpnInterfaceIPv4Address
#
# Description:
#    This command returns the first IPv4 address found on the port. It also
#    returns VLAN ID, MAC address for the interface on which IPv4 address
#    was found. Destination MAC address returned is the MAC address of the
#    gateway, discovered using ARP.
#
# Synopsis:
#    ::ixia::l3vpnInterfaceIPv4Address chassis card port
#
# Arguments:
#    chassis
#    card
#    port
#
# Return Values:
#    A keyed list:
#    key:status       value:$::SUCCESS | $::FAILURE
#    key:log          value:On status of failure, gives detailed information.
#    key:addr.vlan    value:enable|disable
#    key:addr.vlanId  value:VLAN ID
#    key:addr.srcIp   value:Source IP address
#    key:addr.srcMac  value:Source MAC address
#    key:addr.dstMac  value:Destination MAC address
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
proc ::ixia::l3vpnInterfaceIPv4Address {ch cd pt} {
    upvar procName procName
    
    set retCode [interfaceTable select $ch $cd $pt]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Call to\
                interfaceTable select $ch $cd $pt failed. \
                Return code was $retCode."
        return $returnList
    }
    
    # Find the first IPv4 address on the port
    set found 0
    
    set intfRetCode [interfaceTable getFirstInterface]
    while {$intfRetCode == 0} {
        if {[interfaceEntry cget -enable]} {
            if {[interfaceEntry cget -enableVlan]} {
                set vlan   "enable"
                set vlanId [interfaceEntry cget -vlanId]
            } else {
                set vlan   "disable"
                set vlanId 0
            }
            set srcMac [interfaceEntry cget -macAddress]
            
            set ipIntRetCode [interfaceEntry getFirstItem $::addressTypeIpV4]
            if {$ipIntRetCode == 0} {
                set srcIp     [interfaceIpV4 cget -ipAddress]
                set gatewayIp [interfaceIpV4 cget -gatewayIpAddress]
                set found 1
                break
            }
        }
        
        set intfRetCode [interfaceTable getNextInterface]
    }
    
    if {$found == 0} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: No IPv4 address was\
                found on port $ch $cd $pt."
        return $returnList
    }
    
    # Discover the gateway
    if {$gatewayIp == "0.0.0.0"} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: No gateway configured\
                for IP address $srcIp on port $ch $cd $pt."
        return $returnList
    }
    
    set portMode [::ixia::l3vpnIsEthernetInterface $ch $cd $pt]
    if {[keylget portMode status] == $::FAILURE} {
        return $portMode
    }
    if {[keylget portMode result]} {
        set retCode [interfaceTable sendArp]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Could not ARP on\
                    port $ch $cd $pt.  Return code was $retCode"
            return $returnList
        }
        
        after 5000
        
        set retCode [interfaceTable requestDiscoveredTable]
        if {$retCode} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to interfaceTable\
                    requestDiscoveredTable failed on port $ch $cd $pt. \
                    Return code was $retCode"
            return $returnList
        }
        
        for {set count 0} {[interfaceTable getDiscoveredList] != 0 && \
                ($count < 10)} {incr count} {
            after 1000
        }
        if {$count == 10} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Call to interfaceTable\
                    getDiscoveredList failed."
            return $returnList
        }
    
        set found 0
        set neighborRetCode [discoveredList getFirstNeighbor]
        while {($neighborRetCode == 0) && ($found == 0)} {
            set addrRetCode [discoveredNeighbor getFirstAddress]
            while {$addrRetCode == 0} {
                if {[discoveredAddress cget -ipAddress] == $gatewayIp} {
                    set dstMac [discoveredNeighbor cget -macAddress]
                    set found 1
                    break
                }
                set addrRetCode [discoveredNeighbor getNextAddress]
            }
            set neighborRetCode [discoveredList getNextNeighbor]
        }
        
        if {$found == 0} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: Neighbor $gatewayIp\
                    was not discovered on port $ch $cd $pt."
            return $returnList
        }
    } else {
        set dstMac "00:00:00:00:00:00"
    }
    
    keylset returnList status      $::SUCCESS
    keylset returnList addr.vlan   $vlan
    keylset returnList addr.vlanId $vlanId
    keylset returnList addr.srcIp  $srcIp
    keylset returnList addr.srcMac $srcMac
    keylset returnList addr.dstMac $dstMac
    return $returnList
}




##Internal Procedure Header
# Name:
#    ::ixia::l3vpnGetMatchingLabel
#
# Description:
#    This command returns the label matching the specified IP address. The
#    IP address is matched against the ldpRoutes parameter, which is a keyed
#    list.
#
# Synopsis:
#    ::ixia::l3vpnGetMatchingLabel ipAddress ldpRoutes
#
# Arguments:
#    ipAddress
#    ldpRoutes
#
# Return Values:
#    label when a match was found; "" when no match found
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
proc ::ixia::l3vpnGetMatchingLabel {ipAddress ldpRoutes} {
    upvar $ldpRoutes routes
    
    foreach routeEntry [keylkeys routes] {
        set network [keylget routes $routeEntry.network]
        set netmask [keylget routes $routeEntry.netmask]
        set label   [keylget routes $routeEntry.label]
        
        if {[::ixia::l3vpnCompareIpV4Addresses $ipAddress $network $netmask]} {
            return $label
        }
    }
    return ""
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnGetMatchingRd
#
# Description:
#    This command returns the route distinguisher matching the specified IP
#    address. The IP address is matched against the routeList parameter,
#    which is a keyed list.
#
# Synopsis:
#    ::ixia::l3vpnGetMatchingRd ipAddress routeList
#
# Arguments:
#    ipAddress
#    routeList
#
# Return Values:
#    rd when a match was found; "" when no match found
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

proc ::ixia::l3vpnGetMatchingCEPERoutes {ceCfgRoutesArray peLearnedRoutesArray} {
    array unset ceCfgRoutes
    array unset peLearnedRoutes
    array set   ceCfgRoutes     $ceCfgRoutesArray
    array set   peLearnedRoutes $peLearnedRoutesArray
    
    set routes ""
    set unMatchedRoutes ""
    foreach ceRouteEntry [array names ceCfgRoutes] {
        set ceNetwork [keylget ceCfgRoutes($ceRouteEntry) network]
        set ceNetmask [keylget ceCfgRoutes($ceRouteEntry) netmask]
        
        if {[info exists peLearnedRoutes($ceRouteEntry)]} {
            keylset routes [::ixia::ip_addr_to_num                \
                    $ceNetwork]/$ceNetmask [lsort -unique [concat \
                    $ceCfgRoutes($ceRouteEntry)                   \
                    $peLearnedRoutes($ceRouteEntry)]]
        } else  {
            lappend unMatchedRoutes $ceNetwork/$ceNetmask
        }
    }
    
    keylset returnList status    $::SUCCESS
    keylset returnList routes    $routes
    keylset returnList unmatched $unMatchedRoutes
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::l3vpnCompareIpV4Addresses
#
# Description:
#    This command compares the net part of two IP addresses. The netmask
#    parameter is used to determine the net. Returns true if the net parts
#    of the addresses are the same.
#
# Synopsis:
#    ::ixia::l3vpnCompareIpV4Addresses ipAddress1 ipAddress2 netmask
#
# Arguments:
#    ipAddress1
#    ipAddress2
#    netmask
#
# Return Values:
#    1|0
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
proc ::ixia::l3vpnCompareIpV4Addresses {ipAddr1 ipAddr2 {netmask 32}} {
    set mask [mpexpr (0xffffffff << (32 - $netmask)) & 0xffffffff]
    set net1 [mpexpr [::ixia::ip_addr_to_num $ipAddr1] & $mask]
    set net2 [mpexpr [::ixia::ip_addr_to_num $ipAddr2] & $mask]
    
    return [mpexpr $net1 == $net2]
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnGetIpV4Network
#
# Description:
#    This command returns the network IP address for the specified IP
#    address and network mask.
#
# Synopsis:
#    ::ixia::l3vpnGetIpV4Network ipAddress netmask
#
# Arguments:
#    ipAddress
#    netmask
#
# Return Values:
#    ipNetworkAddress
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
proc ::ixia::l3vpnGetIpV4Network {ipAddr netmask} {
    set mask [mpexpr (0xffffffff << (32 - $netmask)) & 0xffffffff]
    set net  [mpexpr [::ixia::ip_addr_to_num $ipAddr] & $mask]
    
    return [::ixia::long_to_ip_addr $net]
}


##Internal Procedure Header
# Name:
#    ::ixia::l3vpnIsEthernetInterface
#
# Description:
#    This command returns the network IP address for the specified IP
#    address and network mask.
#
# Synopsis:
#    ::ixia::l3vpnIsEthernetInterface chassis card port
#
# Arguments:
#    chassis
#    card
#    port
#
# Return Values:
#    key:status       value:$::SUCCESS | $::FAILURE
#    key:log          value:On status of failure, gives detailed information.
#    key:result       value:0 - Port is not in ethernet mode.
#                           1 - Port is in ethernet mode.
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
proc ::ixia::l3vpnIsEthernetInterface {ch cd pt} {
    upvar procName procName
    
    set retCode [port get $ch $cd $pt]
    if {$retCode} {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: Call to port get\
                $ch $cd $pt failed.  Return code was $retCode."
        return $returnList
    }
    
    set portMode [port cget -portMode]
    if {($portMode == $::portEthernetMode) || \
            ($portMode == $::port10GigLanMode)} {
        set result 1
    } else  {
        set result 0
    }
    
    keylset returnList status $::SUCCESS
    keylset returnList result $result
    return $returnList
}