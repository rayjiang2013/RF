##Library Header
# $Id: $
# Copyright © 2003-2012 by IXIA
# All Rights Reserved
#
# Name:
#    ixia_fc_api.tcl
#
# Purpose:
#    A script development library containing FC APIs for test automation
#    with the Ixia chassis.
#
# Author:
#    Tien Ho
#
# Usage:
#    package require Ixia
#
# Description:
#    The procedures contained within this library include:
#    - fc_client_config
#    - fc_fport_config
#    - fc_fport_vnport_config
#    - fc_control
#    - fc_fport_control
#    - fc_client_stats
#    - fc_fport_stats
#    - fc_client_global_config
#    - fc_fport_global_config
#    - fc_client_options_config
#    - fc_fport_options_config
#
# Requirements:
#    parseddashedargs.tcl
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


proc ::ixia::fc_client_config { args } {
    variable executeOnTclServer
    variable new_ixnetwork_api
    set procName [lindex [info level [info level]] 0]
    ::ixia::logHltapiCommand $procName $args
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::fc_client_config $args\}]
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args

    set mandatory_args {
        -mode           CHOICES add disable enable modify remove
    }
    set optional_args {
        -port_handle                        REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -handle                             ANY
        -fdisc_count                        NUMERIC 
                                            DEFAULT 1
        -fdisc_name                         DEFAULT "NPORT-FDISC-R"
        -fdisc_name_server_query            CHOICES 0 1
                                            DEFAULT 0
        -fdisc_name_server_query_command    CHOICES gid_a ga_nxt gpn_id gnn_id gid_pn gid_pt
                                            DEFAULT gid_a
        -fdisc_name_server_registration     CHOICES 0 1
                                            DEFAULT 1
        -fdisc_state_change_registration    CHOICES 0 1
                                            DEFAULT 0
        -fdisc_state_change_registration_option  CHOICES fabric_detected nxport_detected all
                                            DEFAULT fabric_detected
        -fdisc_node_wwn_override            CHOICES 0 1
                                            DEFAULT 0
        -fdisc_node_wwn_increment           ANY
                                            DEFAULT 00:00:00:00:00:00:00:00
        -fdisc_node_wwn_start               ANY
                                            DEFAULT 21:11:0E:FC:00:00:00:00
        -fdisc_port_wwn_increment           ANY
                                            DEFAULT 00:00:00:00:00:00:00:01
        -fdisc_port_wwn_start               ANY
                                            DEFAULT 41:11:0E:FC:00:00:00:00
        -fdisc_source_oui_increment         ANY
                                            DEFAULT 00.00.01
        -fdisc_name_server_query_parameter_type  CHOICES port_identifier port_type port_name
                                            DEFAULT port_identifier
        -fdisc_name_server_query_parameter_value  ANY
        -fdisc_plogi_enabled                CHOICES 0 1
                                            DEFAULT 0
        -fdisc_plogi_dest_id                ANY
                                            DEFAULT 01.B6.69
        -fdisc_plogi_target_name            ANY
        -fdisc_plogi_mesh_mode              CHOICES one_to_one many_to_many
                                            DEFAULT one_to_one
        -fdisc_prli_enabled                 CHOICES 0 1
                                            DEFAULT 0
        -fdisc_enabled                      CHOICES 0 1
                                            DEFAULT 0
        -flogi_count                        NUMERIC 
                                            DEFAULT 1
        -flogi_name                         DEFAULT "NPORT-FLOGI-R"
        -flogi_name_server_query            CHOICES 0 1
                                            DEFAULT 0
        -flogi_name_server_query_command    CHOICES gid_a ga_nxt gpn_id gnn_id gid_pn gid_pt
                                            DEFAULT gid_a
        -flogi_name_server_registration     CHOICES 0 1
                                            DEFAULT 1
        -flogi_state_change_registration    CHOICES 0 1
                                            DEFAULT 0
        -flogi_state_change_registration_option  CHOICES fabric_detected nxport_detected all
                                            DEFAULT fabric_detected
        -flogi_node_wwn_increment           ANY
                                            DEFAULT 00:00:00:00:00:00:00:01
        -flogi_node_wwn_start               ANY
                                            DEFAULT 21:11:0E:FC:00:00:00:00
        -flogi_port_wwn_increment           ANY
                                            DEFAULT 00:00:00:00:00:00:00:01
        -flogi_port_wwn_start               ANY
                                            DEFAULT 31:11:0E:FC:00:00:00:00
        -flogi_source_oui_increment         ANY
                                            DEFAULT 00.00.01
        -flogi_name_server_query_parameter_type  CHOICES port_identifier port_type port_name
                                            DEFAULT port_identifier
        -flogi_name_server_query_parameter_value  ANY
        -flogi_plogi_enabled                CHOICES 0 1
                                            DEFAULT 0
        -flogi_plogi_dest_id                ANY
                                            DEFAULT 01.B6.69
        -flogi_plogi_target_name            ANY
        -flogi_plogi_mesh_mode              CHOICES one_to_one many_to_many
                                            DEFAULT one_to_one
        -flogi_prli_enabled                 CHOICES 0 1
                                            DEFAULT 0
    }
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_fc_client_config $args $mandatory_args \
                $optional_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        return $returnList
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                IxTclHal or IxTclProtocol API is not supported for FC client configurations."
        return $returnList
    }
}


proc ::ixia::fc_fport_config { args } {
    variable executeOnTclServer
    variable new_ixnetwork_api
    set procName [lindex [info level [info level]] 0]
    ::ixia::logHltapiCommand $procName $args
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::fc_fport_config $args\}]
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args

    # Arguments
    set mandatory_args {
        -mode           CHOICES add enable disable remove modify
    }

    set optional_args {
        -port_handle                REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -handle
        -name                       ANY
                                    DEFAULT "F_PORT-FCFP-R1"
        -operating_mode             ANY
                                    DEFAULT F_PORT
        -switch_name                ANY
                                    DEFAULT A0:00:0E:FC:00:00:00:00
        -fabric_name                ANY
                                    DEFAULT B0:00:0E:FC:00:00:00:00
        -b2b_rx_size                RANGE 64-4095
                                    DEFAULT 2112
        -name_server                CHOICES 0 1
                                    DEFAULT 1
        -flogi_reject_interval      RANGE 0-9999
                                    DEFAULT 0
        -fdisc_reject_interval      RANGE 0-9999
                                    DEFAULT 0
        -logo_reject_interval       RANGE 0-9999
                                    DEFAULT 0
        -plogi_reject_interval      RANGE 0-9999
                                    DEFAULT 0
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_fc_fport_config $args $mandatory_args \
                $optional_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        return $returnList
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                IxTclHal or IxTclProtocol API is not supported for FC fport configurations."
        return $returnList
    }
}


proc ::ixia::fc_fport_vnport_config { args } {
    variable executeOnTclServer
    variable new_ixnetwork_api
    set procName [lindex [info level [info level]] 0]
    ::ixia::logHltapiCommand $procName $args
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::fc_fport_vnport_config $args\}]
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args

    # Arguments
    set mandatory_args {
        -mode           CHOICES add enable disable remove modify
    }

    set optional_args {
        -handle                    ANY
        -name                      DEFAULT "N_PORT-FCFP-R1"
        -count                     RANGE 1-16000
                                   DEFAULT 256
        -simulated                 CHOICES 0 1
                                   DEFAULT 0
        -port_id_start             ANY
                                   DEFAULT 01.00.01
        -port_id_incr              ANY
                                   DEFAULT 00.00.01
        -node_wwn_start            ANY
                                   DEFAULT 20:00:0E:FC:00:00:00:00
        -node_wwn_incr             ANY
                                   DEFAULT 00:00:00:00:00:00:00:01
        -port_wwn_start            ANY
                                   DEFAULT 30:00:0E:FC:00:00:00:00
        -port_wwn_incr             ANY
                                   DEFAULT 00:00:00:00:00:00:00:01
        -b2b_rx_size               RANGE 64-4095
                                   DEFAULT 2112
        -vx_port_name              ANY
                                   DEFAULT "F_PORT-FCFP-R1"
        -plogi_enable              CHOICES 0 1
                                   DEFAULT 0
        -plogi_dest_id             ANY
                                   DEFAULT 01.B6.69
        -plogi_mesh_mode           CHOICES one_one many_many
                                   DEFAULT one_one
        -plogi_target_name         ANY
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_fc_fport_vnport_config $args $mandatory_args \
                $optional_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        return $returnList
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                IxTclHal or IxTclProtocol API is not supported for FC fport configurations."
        return $returnList
    }
}


proc ::ixia::fc_control { args } {
    variable executeOnTclServer
    variable new_ixnetwork_api
    set procName [lindex [info level [info level]] 0]
    ::ixia::logHltapiCommand $procName $args
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle\
                \{::ixia::fc_control $args\}]
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args

    # Arguments
    set mandatory_args {
        -action             CHOICES abort clear_stats\
                            fc_client_fdisc fc_client_fdisc_plogi\
                            fc_client_fdisc_plogo fc_client_flogi\
                            fc_client_flogo fc_client_npiv_flogo\
                            fc_client_plogi fc_client_plogo\
                            is_done pause resume start stop
    }

    set optional_args {
        -handle
        -port_handle         REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
        -action_mode         CHOICES sync async
                             DEFAULT sync
        -result
    }
    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_fc_control $args $mandatory_args\
                $optional_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName:\
                    [keylget returnList log]"
        }
        return $returnList
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName:\
                IxAccess API is not supported"
        return $returnList
    }
}


proc ::ixia::fc_client_stats { args } {
    variable executeOnTclServer
    variable new_ixnetwork_api
    set procName [lindex [info level [info level]] 0]
    ::ixia::logHltapiCommand $procName $args
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle\
                \{::ixia::fc_client_stats $args\}]
        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    ::ixia::utrackerLog $procName $args

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_fc_client_stats $args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName:\
                    [keylget returnList log]"
        }
        return $returnList
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName:\
                IxAccess API is not supported"
        return $returnList
    }
}


proc ::ixia::fc_fport_stats { args } {
    variable executeOnTclServer
    variable new_ixnetwork_api
    set procName [lindex [info level [info level]] 0]
    ::ixia::logHltapiCommand $procName $args
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle\
                \{::ixia::fc_fport_stats $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }
    ::ixia::utrackerLog $procName $args

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_fport_stats $args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName:\
                    [keylget returnList log]"
        }
        return $returnList
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName:\
                IxAccess API is not supported"
        return $returnList
    }
}


proc ::ixia::fc_client_global_config { args } {
    variable executeOnTclServer
    variable new_ixnetwork_api

    set procName [lindex [info level [info level]] 0]

    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle \
                \{::ixia::fc_client_global_config $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args

    # Arguments
    set mandatory_args {
        -mode                        CHOICES add remove modify
    }

    set optional_args {
        -accept_partial_config      CHOICES 0 1
                                    DEFAULT 0
        -max_packets_per_second     RANGE 1-2000
                                    DEFAULT 500
        -max_retries                RANGE 1-9999
                                    DEFAULT 5
        -retry_interval             RANGE 1-1000
                                    DEFAULT 2
        -setup_rate                 RANGE 1-2000
                                    DEFAULT 100
        -teardown_rate              RANGE 1-2000
                                    DEFAULT 100
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_fc_client_global_config $args $mandatory_args \
                $optional_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName: \
                    [keylget returnList log]"
        }
        return $returnList
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName: \
                IxTclHal or IxTclProtocol API is not supported for FC fport configurations."
        return $returnList
    }

}


proc ::ixia::fc_fport_global_config { args } {
    variable executeOnTclServer
    variable new_ixnetwork_api

    set procName [lindex [info level [info level]] 0]

    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle\
                \{::ixia::fc_fport_global_config $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args

    # Arguments
    set mandatory_args {
        -mode           CHOICES add remove modify
    }

    set optional_args {
        -accept_partial_config     CHOICES 0 1
                                   DEFAULT 0
        -max_packets_per_second    RANGE 1-2000
                                   DEFAULT 500
        -max_retries               RANGE 1-9999
                                   DEFAULT 5
        -retry_interval            RANGE 1-1000
                                   DEFAULT 2
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_fc_fport_global_config $args $mandatory_args \
                $optional_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName:\
                    [keylget returnList log]"
        }
        return $returnList
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName:\
                IxTclHal or IxTclProtocol API is not supported for FC fport configurations."
        return $returnList
    }
}


proc ::ixia::fc_client_options_config { args } {
    variable executeOnTclServer
    variable new_ixnetwork_api

    set procName [lindex [info level [info level]] 0]

    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle\
                \{::ixia::fc_client_options_config $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args

    # Arguments
    set mandatory_args {
       -mode                         CHOICES add remove modify
       -port_handle                  REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
    }
    set optional_args {
       -associates                   ANY
                                     DEFAULT {}
       -b2b_credit                   RANGE 1-65635
                                     DEFAULT 128
       -b2b_rx_size                  RANGE 64-4095
                                     DEFAULT 2112
       -ed_tov                       RANGE 100-85000
                                     DEFAULT 2000
       -ed_tov_mode                  CHOICES obtain_from_login over_ride
                                     DEFAULT obtain_from_login
       -max_packets_per_second       RANGE 1-2000
                                     DEFAULT 500
       -override_global_rate         CHOICES 0 1
                                     DEFAULT 0
       -rt_tov                       RANGE 10-85000
                                     DEFAULT 10
       -rt_tov_mode                  CHOICES obtain_from_login over_ride
                                     DEFAULT obtain_from_login
       -setup_rate                   RANGE 1-2000
                                     DEFAULT 100
       -teardown_rate                RANGE 1-2000
                                     DEFAULT 100
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_fc_client_options_config $args $mandatory_args \
                $optional_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName:\
                    [keylget returnList log]"
        }
        return $returnList
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName:\
                IxTclHal or IxTclProtocol API is not supported for FC fport configurations."
        return $returnList
    }
}


proc ::ixia::fc_fport_options_config { args } {
    variable executeOnTclServer
    variable new_ixnetwork_api

    set procName [lindex [info level [info level]] 0]

    ::ixia::logHltapiCommand $procName $args
    
    if {$::ixia::executeOnTclServer} {
        if {![info exists ::ixTclSvrHandle]} {
            keylset returnList status $::FAILURE
            keylset returnList log "Not connected to TclServer."
            return $returnList
        }
        set retValue [eval ::ixia::SendToIxTclServer $::ixTclSvrHandle\
                \{::ixia::fc_fport_options_config $args\}]

        set startIndex [string last "\r" $retValue]
        if {$startIndex >= 0} {
            set retData [string range $retValue [expr $startIndex + 1] end]
            return $retData
        } else {
            return $retValue
        }
    }

    ::ixia::utrackerLog $procName $args

    # Arguments
    set mandatory_args {
        -mode                      CHOICES add remove modify
        -port_handle               REGEXP  ^[0-9]+/[0-9]+/[0-9]+$
    }

    set optional_args {

        -b2b_credit                RANGE 1-65535 DEFAULT 128
        -ed_tov                    RANGE 100-85000 DEFAULT 2000
        -max_packets_per_second    RANGE 1-2000 DEFAULT 500
        -override_global_rate      CHOICES 0 1 DEFAULT 0
        -rt_tov                    RANGE 10-85000 DEFAULT 100
    }

    if {[info exists new_ixnetwork_api] && $new_ixnetwork_api} {
        set returnList [::ixia::ixnetwork_fc_fport_options_config $args $mandatory_args \
                $optional_args]
        if {[keylget returnList status] == $::FAILURE} {
            keylset returnList status $::FAILURE
            keylset returnList log "ERROR in $procName:\
                    [keylget returnList log]"
        }
        return $returnList
    } else {
        keylset returnList status $::FAILURE
        keylset returnList log "ERROR in $procName:\
                IxTclHal or IxTclProtocol API is not supported for FC fport configurations."
        return $returnList
    }
}