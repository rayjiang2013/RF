##Library Header
# $Id: $
# Copyright © 2003-2006 by IXIA
# All Rights Reserved.
#
# Name:
#    ixia_multicast_api.tcl
#
# Purpose:
#     A script development library containing multicast utilities for test
#     automation with the Ixia chassis.
#
# Author:
#    Michael Githens
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures contained within this library include:
#
#    - emulation_multicast_group_config
#    - emulation_multicast_source_config
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

proc ::ixia::emulation_multicast_group_config { args } {
    variable executeOnTclServer

    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::emulation_multicast_group_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    variable multicast_group_array
    variable multicast_group_number
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set mandatory_args {
        -mode          CHOICES create delete modify
    }

    set optional_args {
        -handle
        -num_groups    NUMERIC
        -ip_addr_start IP
        -ip_addr_step  IP
        -ip_prefix_len RANGE   1-128
    }

    ::ixia::parse_dashed_args -args $args -optional_args $optional_args \
            -mandatory_args $mandatory_args

    # validate input parameters
    if {($mode == "delete") || ($mode == "modify")} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the mode is \
                    $mode, the -handle argument must be used.  Please set this\
                    argument."
            return $returnList
        } elseif {[llength $handle] > 1} {
            puts "WARNING: This method supports a single \
                    element for -handle parameter."
        }
    }
    
    if {$mode == "create" || $mode == "modify"} {
        if {$mode == "create" && ![info exists num_groups]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When -mode is create, the\
                    -num_groups option must be set.  Please set this value."
            return $returnList
        }
        set ip_version 46
        if {![info exists ip_addr_start]} {
            if {$mode == "modify"} {
                if {[catch {
                    set ip_addr_start $multicast_group_array($handle,ip_addr_start)
                }]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Invalid -handle\
                            specified."
                    return $returnList
                }
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When -mode is\
                        create, the -ip_addr_start option must be set.  Please\
                        set this value."
                return $returnList
            }
        }
        foreach param {ip_addr_start ip_addr_step ip_prefix_len} {
            if {[info exists $param]} {
                switch -exact -- $param {
                    ip_addr_start {
                        if {[info exists ip_addr_start]} {
                            if {[isIpAddressValid $ip_addr_start]} {
                                # chech if address is multicast ipv4
                                if {[lindex [split $ip_addr_start .] 0] < 224} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: No\
                                            multicast ip specified."
                                    return $returnList
                                }
                                set ip_version 4
                            } else {
                                if {[getIpV6Type $ip_addr_start] != 7} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName: No\
                                            multicast ip specified."
                                    return $returnList
                                }
                                set ip_version 6
                            }
                        }
                    }
                    ip_addr_step {
                        # The ip_addr_step is either IPv4 or IPv6(the check type in parse_dashed args is IP)
                        if {($ip_version == 4 && ![isIpAddressValid $ip_addr_step]) || \
                                ($ip_version == 6 && [isIpAddressValid $ip_addr_step])} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Ip version of step mismatch."
                            return $returnList
                        }
                    }
                    ip_prefix_len {
                        if {$ip_version == 4 && $ip_prefix_len > 32} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Invalid -ip_prefix_len for\
                                    -ip_addr_start value."
                            return $returnList
                        }
                    }
                }
            }
        }
    }

    if {$mode == "delete"} {
        catch {unset multicast_group_array(${handle},num_groups)}
        catch {unset multicast_group_array(${handle},ip_addr_start)}
        catch {unset multicast_group_array(${handle},ip_addr_step)}
        catch {unset multicast_group_array(${handle},ip_prefix_len)}

        keylset returnList handle $handle
        keylset returnList status $::SUCCESS
        return $returnList
    }

    if {$mode == "modify"} {
        
        if {[info exists num_groups]} {
            set multicast_group_array(${handle},num_groups)    $num_groups
        }
        if {[info exists ip_addr_start]} {
            set multicast_group_array(${handle},ip_addr_start) $ip_addr_start
        }
        if {[info exists ip_addr_step]} {
            set multicast_group_array(${handle},ip_addr_step)  $ip_addr_step
        }
        if {[info exists ip_prefix_len]} {
            set multicast_group_array(${handle},ip_prefix_len) $ip_prefix_len
        }

        keylset returnList handle $handle
        keylset returnList status $::SUCCESS
        return $returnList
    }
    
    # Find the next available handle to use.  We are going to name the handle,
    # group followed by a number.  We shall start at 1 and increment, without
    # worrying about filling in any gaps caused by deleted handles.
    if {![info exists multicast_group_number]} {
        set multicast_group_number 0
    }
    set multicast_group_number [mpexpr $multicast_group_number + 1]
    set new_handle group$multicast_group_number
    
    
    set multicast_group_array(${new_handle},num_groups)    $num_groups
    set multicast_group_array(${new_handle},ip_addr_start) $ip_addr_start
    if {[info exists ip_addr_step]} {
        set multicast_group_array(${new_handle},ip_addr_step)  $ip_addr_step
    } else  {
        if {[isIpAddressValid $ip_addr_start]} {
            set multicast_group_array(${new_handle},ip_addr_step) 0.0.0.1
        } else  {
            set multicast_group_array(${new_handle},ip_addr_step) 0::1
        }
    }
    if {[info exists ip_prefix_len]} {
        set multicast_group_array(${new_handle},ip_prefix_len) $ip_prefix_len
    } else  {
        if {[isIpAddressValid $ip_addr_start]} {
            set multicast_group_array(${new_handle},ip_prefix_len) 32
        } else  {
            set multicast_group_array(${new_handle},ip_prefix_len) 128
        }
    }

    keylset returnList handle $new_handle
    keylset returnList status $::SUCCESS
    return $returnList
}


proc ::ixia::emulation_multicast_source_config { args } {
    variable executeOnTclServer

    set procName [lindex [info level [info level]] 0]
	
    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval clientSend $::ixTclSvrHandle \
                \{::ixia::emulation_multicast_source_config $args\}]
        
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    variable multicast_source_array
    variable multicast_source_number
    
    ::ixia::utrackerLog $procName $args
    
    # Arguments
    set mandatory_args {
        -mode          CHOICES create delete modify
    }

    set optional_args {
        -handle
        -num_sources   NUMERIC
        -ip_addr_start IP
        -ip_addr_step  IP
        -ip_prefix_len RANGE   1-128
    }

    ::ixia::parse_dashed_args -args $args -optional_args $optional_args \
            -mandatory_args $mandatory_args

    # validate input parameters
    if {($mode == "delete") || ($mode == "modify")} {
        if {![info exists handle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When the mode is \
                    $mode, the -handle argument must be used.  Please set this\
                    argument."
            return $returnList
        } elseif {[llength $handle] > 1} {
            puts "WARNING: This method supports a single \
                    element for -handle parameter."
        }
    }

    if {$mode == "create" || $mode == "modify"} {
        if {$mode == "create" && ![info exists num_sources]} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: When -mode is create, the\
                    -num_sources option must be set.  Please set this value."
            return $returnList
        }
        set ip_version 46
        if {![info exists ip_addr_start]} {
            if {$mode == "modify"} {
                if {[catch {
                    set ip_addr_start $multicast_source_array($handle,ip_addr_start)
                }]} {
                    keylset returnList status $::FAILURE
                    keylset returnList log "ERROR in $procName: Invalid -handle\
                            specified."
                    return $returnList
                }
            } else {
                keylset returnList status $::FAILURE
                keylset returnList log "ERROR in $procName: When -mode is\
                        create, the -ip_addr_start option must be set.  Please\
                        set this value."
                return $returnList
            }
        }
        foreach param {ip_addr_start ip_addr_step ip_prefix_len} {
            if {[info exists $param]} {
                switch -exact -- $param {
                    ip_addr_start {
                        if {[info exists ip_addr_start]} {
                            if {[isIpAddressValid $ip_addr_start]} {
                                # chech if address is multicast ipv4
                                if {[lindex [split $ip_addr_start .] 0] >= 224} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName:\
                                            Parameter -ip_addr_start should not\
                                            be multicast address."
                                    return $returnList
                                }
                                set ip_version 4
                            } else {
                                if {[getIpV6Type $ip_addr_start] == 7} {
                                    keylset returnList status $::FAILURE
                                    keylset returnList log "ERROR in $procName:\
                                            Parameter -ip_addr_start should not\
                                            be multicast address."
                                    return $returnList
                                }
                                set ip_version 6
                            }
                        }
                    }
                    ip_addr_step {
                        # The ip_addr_step is either IPv4 or IPv6(the check type in parse_dashed args is IP)
                        if {($ip_version == 4 && ![isIpAddressValid $ip_addr_step]) || \
                                ($ip_version == 6 && [isIpAddressValid $ip_addr_step])} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Ip version of step mismatch."
                            return $returnList
                        }
                    }
                    ip_prefix_len {
                        if {$ip_version == 4 && $ip_prefix_len > 32} {
                            keylset returnList status $::FAILURE
                            keylset returnList log "ERROR in $procName: Invalid -ip_prefix_len for\
                                    -ip_addr_start value."
                            return $returnList
                        }
                    }
                }
            }
        }
    }

    if {$mode == "delete"} {
        catch { unset multicast_source_array(${handle},num_sources)}
        catch { unset multicast_source_array(${handle},ip_addr_start)}
        catch { unset multicast_source_array(${handle},ip_addr_step)}
        catch { unset multicast_source_array(${handle},ip_prefix_len)}

        keylset returnList status $::SUCCESS
        return $returnList
    }

    if {$mode == "modify"} {

        if {[info exists num_sources]} {
            set multicast_source_array(${handle},num_sources)   $num_sources
        }
        if {[info exists ip_addr_start]} {
            set multicast_source_array(${handle},ip_addr_start) $ip_addr_start
        }
        if {[info exists ip_addr_step]} {
            set multicast_source_array(${handle},ip_addr_step)  $ip_addr_step
        }
        if {[info exists ip_prefix_len]} {
            set multicast_source_array(${handle},ip_prefix_len) $ip_prefix_len
        }

        keylset returnList status $::SUCCESS
        return $returnList
    }

    # Find the next available handle to use.  We are going to name the handle,
    # source followed by a number.  We shall start at 1 and increment, without
    # worrying about filling in any gaps caused by deleted handles.
    if {![info exists multicast_source_number]} {
        set multicast_source_number 0
    }
    set multicast_source_number [mpexpr $multicast_source_number + 1]
    set new_handle source$multicast_source_number

    set multicast_source_array(${new_handle},num_sources)   $num_sources
    set multicast_source_array(${new_handle},ip_addr_start) $ip_addr_start
    if {[info exists ip_addr_step]} {
        set multicast_source_array(${new_handle},ip_addr_step)  $ip_addr_step
    } else  {
        if {[isIpAddressValid $ip_addr_start]} {
            set multicast_source_array(${new_handle},ip_addr_step) 0.0.0.1
        } else  {
            set multicast_source_array(${new_handle},ip_addr_step) 0::1
        }
    }
    if {[info exists ip_prefix_len]} {
        set multicast_source_array(${new_handle},ip_prefix_len) $ip_prefix_len
    } else  {
        if {[isIpAddressValid $ip_addr_start]} {
            set multicast_source_array(${new_handle},ip_prefix_len) 32
        } else  {
            set multicast_source_array(${new_handle},ip_prefix_len) 128
        }
    }

    keylset returnList handle $new_handle
    keylset returnList status $::SUCCESS
    return $returnList
}
