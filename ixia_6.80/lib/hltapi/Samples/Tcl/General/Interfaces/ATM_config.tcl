################################################################################
# Version 1.0    $Revision: 1 $
# $Author: M Ridichie $
#
#    Copyright � 1997 - 2007 by IXIA
#    All Rights Reserved.
#
#    Revision Log:
#    06-02-2006 MRidichie - created sample
#    10-17-2007 LRaicea   - corrected indentation
#
################################################################################

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

################################################################################
#                                                                              #
# Description:                                                                 #
#    This sample configures an ATM header counter.                             #
#                                                                              #
# Module:                                                                      #
#    The sample was tested on a LM622MR module.                                #
#    The sample was tested with HLTSET26.                                      #
#                                                                              #
################################################################################
lappend auto_path {D:\p4\hltapi\main}
set env(IXIA_VERSION) HLTSET26
package require Ixia

set test_name [info script]

set chassisIP 127.0.0.1
set port_list [list 43/1]

# Connect to the chassis, reset to factory defaults and take ownership
set connect_status [::ixia::connect \
        -reset                      \
        -device    $chassisIP       \
        -port_list $port_list       \
        -username  ixiaApiUser      ]
if {[keylget connect_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget connect_status log]"
}
set port_0 [keylget connect_status port_handle.$chassisIP.$port_list]
################################################################################
# Configure interface in the test IPv4 
################################################################################
set interface_status [::ixia::interface_config          \
        -port_handle                    $port_0         \
        -intf_ip_addr                   11.22.33.44     \
        -gateway                        11.22.33.1      \
        -netmask                        255.255.255.0   \
        -intf_mode                      atm             \
        -speed                          oc3             \
        -atm_enable_coset               0               \
        -atm_enable_pattern_matching    0               \
        -atm_filler_cell                idle            \
        -atm_interface_type             uni             \
        -atm_packet_decode_mode         cell            \
        -atm_reassembly_timeout         111             ]

if {[keylget interface_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget interface_status log]"
}

################################################################################
# Delete all the streams first
################################################################################
set traffic_status [::ixia::traffic_config \
        -mode        reset                 \
        -port_handle $port_0               ]
if {[keylget traffic_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget traffic_status log]"
}

################################################################################
# Configure stream
################################################################################
set traffic_status [::ixia::traffic_config                          \
        -mode                               create                  \
        -port_handle                        $port_0                 \
        -l3_protocol                        ipv4                    \
        -ip_src_addr                        11.22.33.44             \
        -ip_dst_addr                        55.66.77.88             \
        -l3_length                          62                      \
        -rate_percent                       50                      \
        -vpi                                34                      \
        -vpi_step                           2                       \
        -vpi_count                          5                       \
        -atm_header_aal5error               bad_crc                 \
        -atm_header_cell_loss_priority      1                       \
        -atm_header_enable_cpcs_length      1                       \
        -atm_header_cpcs_length             29                      \
        -atm_header_enable_auto_vpi_vci     0                       \
        -atm_header_enable_cl               1                       \
        -atm_header_encapsulation           vcc_mux_bridged_eth_fcs \
        -atm_header_generic_flow_ctrl       14                      \
        -atm_header_hec_errors              7                       \
        -atm_counter_vci_data_item_list     "10 20 30"              \
        -atm_counter_vpi_mode               decr                    \
        -atm_counter_vpi_type               counter                 \
        -atm_counter_vci_type               table                   ]

if {[keylget traffic_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget traffic_status log]"
}
set stream_id [keylget traffic_status stream_id]
################################################################################
# Modify stream
################################################################################
set traffic_status [::ixia::traffic_config                          \
        -mode                               modify                  \
        -port_handle                        $port_0                 \
        -stream_id                          $stream_id              \
        -l3_protocol                        ipv4                    \
        -ip_src_addr                        11.22.33.44             \
        -ip_dst_addr                        11.22.33.1              \
        -l3_length                          54                      \
        -rate_percent                       60                      \
        -vci                                66                      \
        -vci_step                           6                       \
        -atm_header_aal5error               no_error                \
        -atm_header_cell_loss_priority      0                       \
        -atm_header_enable_cpcs_length      1                       \
        -atm_header_cpcs_length             555                     \
        -atm_header_enable_auto_vpi_vci     0                       \
        -atm_header_enable_cl               0                       \
        -atm_header_generic_flow_ctrl       13                      \
        -atm_header_hec_errors              6                       \
        -atm_counter_vpi_type               random                  \
        -atm_counter_vpi_mask_select        1235                    \
        -atm_counter_vpi_mask_value         aabb                    \
        -atm_counter_vci_type               counter                 \
        -atm_counter_vci_mode               cont_incr               ]

if {[keylget traffic_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget traffic_status log]"
}

return "SUCCESS - $test_name - [clock format [clock seconds]]"
