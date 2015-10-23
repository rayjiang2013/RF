##Library Header
# $Id: $
# Copyright © 2003-2007 by IXIA
# All Rights Reserved.
#
# Name:
#    utils_ixprotocol_lacp.tcl
#
# Purpose:
#    Utility functions to support LACP protocol config/control
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
#    ::ixia::removeLacpLinkFromLag
#
# Description:
#    This command removes an LACP from the internal array.
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

proc ::ixia::removeLacpLinkFromLag {lagId lacpLink} {
    variable internal_lacp_lag_settings_array
    
    regsub {^lacpLink([0-9]+/[0-9]+/[0-9]+)/[0-9]+$} $lacpLink {\1} lagPort
    if {![info exists lagPort]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Invalid link handle $lacpLink."
        return $returnList
    }
    # Reset active link
    if {$internal_lacp_lag_settings_array($lagId,$lagPort,active_link) == $lacpLink} {
        set internal_lacp_lag_settings_array($lagId,$lagPort,active_link) ""
    }
    # Remove link
    set linkIndices [lsearch -all $internal_lacp_lag_settings_array($lagId,$lagPort,links) $lacpLink]
    foreach linkIndex $linkIndices {
        set internal_lacp_lag_settings_array($lagId,$lagPort,links) \
                [lreplace $internal_lacp_lag_settings_array($lagId,$lagPort,links) $linkIndex $linkIndex]
    }
    # Remove port
    if {$internal_lacp_lag_settings_array($lagId,$lagPort,links) == ""} {
        catch {unset internal_lacp_lag_settings_array($lagId,$lagPort,links)}
        catch {unset internal_lacp_lag_settings_array($lagId,$lagPort,active_link)}
        set portIndices [lsearch -all $internal_lacp_lag_settings_array($lagId,ports) $lagPort]
        foreach portIndex $portIndices {
            set internal_lacp_lag_settings_array($lagId,ports) \
                    [lreplace $internal_lacp_lag_settings_array($lagId,ports) $portIndex $portIndex]
        }
    }
    # Remove lag
    if {$internal_lacp_lag_settings_array($lagId,ports) == ""} {
        catch {unset internal_lacp_lag_settings_array($lagId,ports)}
        catch {unset internal_lacp_lag_settings_array($internal_lacp_lag_settings_array($lagId,actor_system_id),$internal_lacp_lag_settings_array($lagId,actor_system_pri),$internal_lacp_lag_settings_array($lagId,actor_key),id)}
        catch {unset internal_lacp_lag_settings_array($lagId,actor_system_id)}
        catch {unset internal_lacp_lag_settings_array($lagId,actor_system_pri)}
        catch {unset internal_lacp_lag_settings_array($lagId,actor_key)}
        catch {unset internal_lacp_lag_settings_array($lagId)}
    }
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::addLacpLinkToLag
#
# Description:
#    This command removes an LACP from the internal array.
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

proc ::ixia::addLacpLinkToLag {lagId lacpLink actorSystemId actorSystemPri actorKey} {
    variable internal_lacp_lag_settings_array
    
    regsub {^lacpLink([0-9]+/[0-9]+/[0-9]+)/[0-9]+$}  $lacpLink {\1} lagPort
    if {![info exists lagPort]} {
        keylset returnList status $::FAILURE
        keylset returnList log "Invalid link handle $lacpLink."
        return $returnList
    }
    # Add lag
    set internal_lacp_lag_settings_array($lagId)                                      1
    set internal_lacp_lag_settings_array($lagId,actor_system_id)                      $actorSystemId
    set internal_lacp_lag_settings_array($lagId,actor_system_pri)                     $actorSystemPri
    set internal_lacp_lag_settings_array($lagId,actor_key)                            $actorKey
    set internal_lacp_lag_settings_array($actorSystemId,$actorSystemPri,$actorKey,id) $lagId
    
    # Add port
    lappend internal_lacp_lag_settings_array($lagId,ports)            $lagPort
    set internal_lacp_lag_settings_array($lagId,ports)          [lsort -unique \
            $internal_lacp_lag_settings_array($lagId,ports)]
    
    # Add link
    lappend internal_lacp_lag_settings_array($lagId,$lagPort,links)   $lacpLink
    set internal_lacp_lag_settings_array($lagId,$lagPort,links) [lsort -unique \
            $internal_lacp_lag_settings_array($lagId,$lagPort,links)]
    
    # Set as active link
    set internal_lacp_lag_settings_array($lagId,$lagPort,active_link) $lacpLink
    
    keylset returnList status $::SUCCESS
    return $returnList
}

##Internal Procedure Header
# Name:
#    ::ixia::updateLacpHandleArray
#
# Description:
#    This command removes an LACP from the internal array.
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

proc ::ixia::updateLacpHandleArray {mode port_handle} {
    variable internal_lacp_lag_settings_array
    variable internal_lacp_lag_index
    
    for {set lagId 1} {$lagId <= $internal_lacp_lag_index} {incr lagId} {
        if {![info exists internal_lacp_lag_settings_array($lagId)] || \
                $internal_lacp_lag_settings_array($lagId) == 0} { continue }
        
        if {![info exists internal_lacp_lag_settings_array($lagId,ports)] || \
                ($internal_lacp_lag_settings_array($lagId,ports) == "")} { continue }
                
        foreach lagPort $internal_lacp_lag_settings_array($lagId,ports) {
            if {$lagPort != $port_handle} { continue }
            
            # Remove port
            catch {unset internal_lacp_lag_settings_array($lagId,$lagPort,links)}
            catch {unset internal_lacp_lag_settings_array($lagId,$lagPort,active_link)}
            set portIndices [lsearch -all $internal_lacp_lag_settings_array($lagId,ports) $lagPort]
            foreach portIndex $portIndices {
                set internal_lacp_lag_settings_array($lagId,ports) \
                        [lreplace $internal_lacp_lag_settings_array($lagId,ports) $portIndex $portIndex]
            }
            # Remove lag
            if {$internal_lacp_lag_settings_array($lagId,ports) == ""} {
                catch {unset internal_lacp_lag_settings_array($lagId,ports)}
                catch {unset internal_lacp_lag_settings_array($internal_lacp_lag_settings_array($lagId,actor_system_id),$internal_lacp_lag_settings_array($lagId,actor_system_pri),$internal_lacp_lag_settings_array($lagId,actor_key),id)}
                catch {unset internal_lacp_lag_settings_array($lagId,actor_system_id)}
                catch {unset internal_lacp_lag_settings_array($lagId,actor_system_pri)}
                catch {unset internal_lacp_lag_settings_array($lagId,actor_key)}
                catch {unset internal_lacp_lag_settings_array($lagId)}
            }
        }
    }
    
    keylset returnList status $::SUCCESS
    return $returnList
}

