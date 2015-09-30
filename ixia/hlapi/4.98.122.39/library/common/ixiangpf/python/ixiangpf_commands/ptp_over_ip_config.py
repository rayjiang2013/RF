# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def ptp_over_ip_config(self, mode, parent_handle, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    ptp_over_ip_config
		
		 Description:
		    Performs ptp_over_ip configuration. Manages a device group of PTP clocks.
		
		 Synopsis:
		    ptp_over_ip_config
		        -mode                                 CHOICES create add modify delete
		        -parent_handle                        ANY
		        [-handle                              ANY]
		n       [-style                               ANY]
		        [-announce_current_utc_offset_valid   CHOICES 0 1]
		        [-announce_drop_rate                  RANGE 0-100
		                                              DEFAULT 0]
		        [-announce_frequency_traceable        CHOICES 0 1
		                                              DEFAULT 0]
		        [-announce_leap59                     CHOICES 0 1
		                                              DEFAULT 0]
		        [-announce_leap61                     CHOICES 0 1
		                                              DEFAULT 0]
		        [-announce_ptp_timescale              CHOICES 0 1
		                                              DEFAULT 0]
		        [-announce_receipt_timeout            RANGE 0-128
		                                              DEFAULT 3]
		        [-announce_time_traceable             CHOICES 0 1
		                                              DEFAULT 0]
		        [-slave_count                         RANGE 1-500
		                                              DEFAULT 1]
		        [-slave_ip_address                    ANY
		                                              DEFAULT 10.10.0.1]
		        [-slave_ip_increment_by               ANY
		                                              DEFAULT 0.0.0.1]
		        [-slave_mac_address                   ANY
		                                              DEFAULT aa:bb:cd:00:00:00]
		        [-slave_mac_increment_by              ANY
		                                              DEFAULT 00:00:00:00:00:01]
		        [-clock_accuracy                      CHOICES 32
		                                              CHOICES 33
		                                              CHOICES 34
		                                              CHOICES 35
		                                              CHOICES 36
		                                              CHOICES 37
		                                              CHOICES 38
		                                              CHOICES 39
		                                              CHOICES 40
		                                              CHOICES 41
		                                              CHOICES 42
		                                              CHOICES 43
		                                              CHOICES 44
		                                              CHOICES 45
		                                              CHOICES 46
		                                              CHOICES 47
		                                              CHOICES 48
		                                              CHOICES 49
		                                              DEFAULT 47]
		        [-clock_class                         RANGE 0-255
		                                              DEFAULT 6]
		n       [-clock_increment                     ANY]
		        [-communication_mode                  CHOICES multicast
		                                              CHOICES unicast
		                                              CHOICES mixedMode
		                                              CHOICES g8265
		                                              DEFAULT multicast]
		        [-delay_mechanism                     CHOICES E2E P2P 1WAY
		                                              DEFAULT E2E]
		        [-delay_resp_drop_rate                RANGE 0-100
		                                              DEFAULT 0]
		        [-delay_resp_receipt_timeout          RANGE 1-1000
		                                              DEFAULT 100]
		        [-delay_response_delay                RANGE 0-1000000000
		                                              DEFAULT 0]
		        [-delay_response_delay_insertion_rate RANGE 0-100
		                                              DEFAULT 0]
		        [-domain                              RANGE 0-255
		                                              DEFAULT 0]
		        [-drop_signal_req_announce            CHOICES 0 1]
		        [-drop_signal_req_delay_resp          CHOICES 0 1]
		        [-drop_signal_req_sync                CHOICES 0 1]
		n       [-enabled                             ANY]
		        [-first_clock                         ANY
		                                              DEFAULT 00:00:00:00:00:00:11:11]
		        [-follow_up_bad_crc_rate              RANGE 0-100
		                                              DEFAULT 0]
		        [-follow_up_delay                     RANGE 0-1000000000
		                                              DEFAULT 0]
		        [-follow_up_delay_insertion_rate      RANGE 0-100
		                                              DEFAULT 0]
		        [-follow_up_drop_rate                 RANGE 0-100
		                                              DEFAULT 0]
		        [-grant_delay_resp_duration_interval  RANGE 5-1200
		                                              DEFAULT 300]
		        [-grant_sync_duration_interval        RANGE 5-1200
		                                              DEFAULT 300]
		        [-grant_unicast_duration_interval     RANGE 5-1200
		                                              DEFAULT 300]
		        [-ip_tos                              RANGE 0-255
		                                              DEFAULT 0]
		        [-learn_port_id                       CHOICES 0 1]
		        [-log_announce_interval               CHOICES 247
		                                              CHOICES 248
		                                              CHOICES 249
		                                              CHOICES 250
		                                              CHOICES 251
		                                              CHOICES 252
		                                              CHOICES 253
		                                              CHOICES 254
		                                              CHOICES 255
		                                              CHOICES 0
		                                              CHOICES 1
		                                              CHOICES 2
		                                              CHOICES 3
		                                              CHOICES 4
		                                              CHOICES 5
		                                              CHOICES 6
		                                              CHOICES 7
		                                              CHOICES 8
		                                              CHOICES 9
		                                              DEFAULT 0]
		        [-log_delay_req_interval              CHOICES 247
		                                              CHOICES 248
		                                              CHOICES 249
		                                              CHOICES 250
		                                              CHOICES 251
		                                              CHOICES 252
		                                              CHOICES 253
		                                              CHOICES 254
		                                              CHOICES 255
		                                              CHOICES 0
		                                              CHOICES 1
		                                              CHOICES 2
		                                              CHOICES 3
		                                              CHOICES 4
		                                              CHOICES 5
		                                              CHOICES 6
		                                              CHOICES 7
		                                              CHOICES 8
		                                              CHOICES 9
		                                              DEFAULT 0]
		        [-log_sync_interval                   CHOICES 247
		                                              CHOICES 248
		                                              CHOICES 249
		                                              CHOICES 250
		                                              CHOICES 251
		                                              CHOICES 252
		                                              CHOICES 253
		                                              CHOICES 254
		                                              CHOICES 255
		                                              CHOICES 0
		                                              CHOICES 1
		                                              CHOICES 2
		                                              CHOICES 3
		                                              CHOICES 4
		                                              CHOICES 5
		                                              CHOICES 6
		                                              CHOICES 7
		                                              CHOICES 8
		                                              CHOICES 9
		                                              DEFAULT 0]
		        [-master_count                        RANGE 1-500
		                                              DEFAULT 1]
		        [-master_ip_address                   ANY
		                                              DEFAULT 10.10.0.1]
		        [-master_ip_increment_by              ANY
		                                              DEFAULT 0.0.0.1]
		n       [-master_ip_increment_inter_entity    ANY]
		        [-master_mac_address                  ANY
		                                              DEFAULT aa:bb:cd:00:00:00]
		        [-master_mac_increment_by             ANY
		                                              DEFAULT 00:00:00:00:00:01]
		        [-master_mac_increment_inter_entity   ANY
		                                              DEFAULT 00:00:00:00:00:00]
		        [-name                                ALPHA]
		        [-port_number                         RANGE 1-65535
		                                              DEFAULT 1]
		n       [-port_number_increment               ANY]
		        [-priority1                           RANGE 0-255
		                                              DEFAULT 128]
		        [-priority2                           RANGE 0-255
		                                              DEFAULT 128]
		        [-renewal_invited                     CHOICES 0 1]
		        [-request_attempts                    RANGE 1-100
		                                              DEFAULT 3]
		        [-request_holddown                    RANGE 10-1000
		                                              DEFAULT 60]
		        [-request_interval                    RANGE 1-100
		                                              DEFAULT 1]
		        [-residence_time                      RANGE 0-1000000000
		                                              DEFAULT 0]
		        [-rx_calibration                      RANGE 0-10000
		                                              DEFAULT 0]
		        [-send_announce_multicast             CHOICES 0 1]
		        [-send_announce_tlv                   CHOICES 0 1]
		        [-send_cancel_tlv                     CHOICES 0 1]
		        [-signal_interval                     RANGE 3-1200
		                                              DEFAULT 64]
		        [-signal_unicast_handling             CHOICES individually
		                                              CHOICES allInOne
		                                              CHOICES doNotSend
		                                              DEFAULT individually]
		        [-step_mode                           CHOICES two-step single-step
		                                              DEFAULT two-step]
		        [-steps_removed                       RANGE 0-655535
		                                              DEFAULT 0]
		        [-strict_grant                        CHOICES 0 1]
		        [-sync_drop_rate                      RANGE 0-100
		                                              DEFAULT 0]
		        [-sync_receipt_timeout                RANGE 1-1000
		                                              DEFAULT 100]
		        [-time_source                         CHOICES 0X10
		                                              CHOICES 0X20
		                                              CHOICES 0X30
		                                              CHOICES 0X40
		                                              CHOICES 0X50
		                                              CHOICES 0X60
		                                              CHOICES 0X90
		                                              CHOICES 0XA0
		                                              DEFAULT 0X20]
		        [-timestamp_offset                    RANGE 0-10000000000
		                                              DEFAULT 0]
		n       [-timestamp_offset_variation          ANY]
		        [-tx_calibration                      RANGE 0-10000
		                                              DEFAULT 0]
		        [-use_alternate_master_flag           CHOICES 0 1]
		        [-use_clock_identity                  CHOICES 0 1]
		x       [-one_way                             CHOICES 0 1]
		x       [-simulate_transparent                CHOICES 0 1]
		x       [-sync_residence_time                 ANY]
		x       [-follow_up_residence_time            ANY]
		x       [-delay_req_residence_time            ANY]
		x       [-delay_resp_residence_time           ANY]
		x       [-p_delay_follow_up_residence_time    ANY]
		x       [-offset_scaled_log_variance          ANY]
		x       [-role                                CHOICES slave master]
		x       [-profile                             CHOICES ieee1588 g82651]
		x       [-master_ipv6_address                 ANY]
		x       [-master_ipv6_increment_by            ANY]
		x       [-slave_ipv6_address                  ANY]
		x       [-slave_ipv6_increment_by             ANY]
		        [-mtu                                 RANGE 68-9216]
		x       [-mac_address_init                    MAC]
		x       [-mac_address_step                    MAC
		x                                             DEFAULT 0000.0000.0001]
		x       [-vlan                                CHOICES 0 1]
		        [-vlan_id_mode                        CHOICES fixed increment
		                                              DEFAULT increment]
		        [-vlan_id                             RANGE 0-4096]
		        [-vlan_id_step                        RANGE 0-4096
		                                              DEFAULT 1]
		        [-vlan_user_priority                  RANGE 0-7
		                                              DEFAULT 0]
		        [-ip_type                             CHOICES ipv4 ipv6
		                                              DEFAULT ipv4]
		        [-intf_ip_addr                        IP]
		        [-intf_ip_addr_step                   IP
		                                              DEFAULT 0.0.1.0]
		        [-intf_prefix_length                  RANGE 1-128
		                                              DEFAULT 24]
		        [-neighbor_intf_ip_addr               IP
		                                              DEFAULT 0.0.0.0]
		        [-neighbor_intf_ip_addr_step          IP
		                                              DEFAULT 0.0.0.0]
		        [-intf_ipv6_addr                      IP]
		        [-intf_ipv6_addr_step                 IP
		                                              DEFAULT 0000:0000:0000:0000:0000:0000:0000:0001]
		        [-intf_prefixv6_length                RANGE 1-128
		                                              DEFAULT 64]
		        [-neighbor_intf_ipv6_addr             IP]
		        [-neighbor_intf_ipv6_addr_step        IP
		                                              DEFAULT 0000:0000:0000:0000:0000:0000:0000:0001]
		x       [-num_sessions                        RANGE 1-100000000
		x                                             DEFAULT 10]
		
		 Arguments:
		    -mode
		        create - creates and configures a new object
		        add - not supported in case of ::ixiangpf::ptp_over_ip_config.
		        modify - modified attributes on the given object by the -handle param
		        delete - deletes the object given by the -handle param
		    -parent_handle
		        The parent handle used for creating this object. It can be a topology, or a device group, or an ethernet or an ipv4/v6.
		    -handle
		        A handle returned via a ::ixiangpf::ptp_over_ip_config command. This is used for mode modify.
		n   -style
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -announce_current_utc_offset_valid
		        Set Announce currentUtcOffsetValid bit.
		    -announce_drop_rate
		        Percentage rate of the dropped Announce messages.
		    -announce_frequency_traceable
		        Set Announce frequency traceable bit.
		    -announce_leap59
		        Set Announce leap59 bit.
		    -announce_leap61
		        Set Announce leap61 bit.
		    -announce_ptp_timescale
		        Set Announce ptpTimescale bit.
		    -announce_receipt_timeout
		        The number of announceInterval that has to pass without receipt of an Announce message.
		    -announce_time_traceable
		        Set Announce time traceable bit.
		    -slave_count
		        The total number of Unicast slaves to be used for the device group.
		    -slave_ip_address
		        Defines the base address to be used for enumerating all the addresses in the device group.
		    -slave_ip_increment_by
		        Defines the increment to be used for enumerating all the addresses in the device group.
		    -slave_mac_address
		        Defines the base address to be used for enumerating all the addresses
		        in the device group.
		    -slave_mac_increment_by
		        Defines the increment to be used for enumerating all the addresses in the range.
		    -clock_accuracy
		        Clock accuracy.
		        Valid choices are:
		        32 - {The time is accurate to within 25 ns}
		        33 - {The time is accurate to within 100 ns}
		        34 - {The time is accurate to within 250 ns}
		        35 - {The time is accurate to within 1 us}
		        36 - {The time is accurate to within 2.5 us}
		        37 - {The time is accurate to within 10 us}
		        38 - {The time is accurate to within 25 us}
		        39 - {The time is accurate to within 100 us}
		        40 - {The time is accurate to within 250 us}
		        41 - {The time is accurate to within 1 ms}
		        42 - {The time is accurate to within 2.5 ms}
		        43 - {The time is accurate to within 10 ms}
		        44 - {The time is accurate to within 25 ms}
		        45 - {The time is accurate to within 100 ms}
		        46 - {The time is accurate to within 250 ms}
		        47 - {The time is accurate to within 1 s}
		        48 - {The time is accurate to within 10 s}
		        49 - {The time is accurate to greater than 10 s}
		    -clock_class
		        Traceability of the time or frequency distributed by the grandmaster clock.
		n   -clock_increment
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -communication_mode
		        Communication mode (unicast/multicast).
		        Valid choices are:
		        multicast - Multicast
		        unicast - Unicast
		        mixedMode - MixedMode
		        g8265 - deprecated for ixngpf command
		    -delay_mechanism
		        Clock delay mechanism.
		        Valid choices are:
		        E2E - RequestResponse
		        P2P - PeerDelay
		        1WAY- deprecated for ixngpf command
		    -delay_resp_drop_rate
		        Percentage rate of the dropped Delay_Resp messages.
		    -delay_resp_receipt_timeout
		        DelayResponse Receipt Timeout in seconds.
		    -delay_response_delay
		        Additional delay introduced in the Delay_Resp message timestamp (nanoseconds).
		    -delay_response_delay_insertion_rate
		        Percentage rate of the Delay_Resp messages in which the delay is introduced.
		    -domain
		        PTP Domain.
		    -drop_signal_req_announce
		        Select this check box to drop any Signal Request that contains Announce TLV.
		    -drop_signal_req_delay_resp
		        Select this check box to drop any Signal Request that contains DelayResp TLV.
		    -drop_signal_req_sync
		        Select this check box to drop any Signal Request that contains Sync TLV.
		n   -enabled
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -first_clock
		        Defines the first ClockIdentity to be used in this device group.
		    -follow_up_bad_crc_rate
		        Percentage rate of the bad crc Follow_Up messages.
		    -follow_up_delay
		        Additional delay introduced in the Follow_Up message timestamp (nanoseconds).
		    -follow_up_delay_insertion_rate
		        Percentage rate of the Follow_Up messages in which the delay is introduced.
		    -follow_up_drop_rate
		        Percentage rate of the dropped Follow_Up messages.
		    -grant_delay_resp_duration_interval
		        Value of DurationField in REQUEST_UNICAST_TRANSMISSION_TLV for DelayResp messages.
		    -grant_sync_duration_interval
		        Value of DurationField in REQUEST_UNICAST_TRANSMISSION_TLV for Sync messages.
		    -grant_unicast_duration_interval
		        Value of DurationField in REQUEST_UNICAST_TRANSMISSION_TLV.
		    -ip_tos
		        IP TOS or DS.
		    -learn_port_id
		        Slave learns Master Port ID.
		    -log_announce_interval
		        The log mean time interval between successive Announce messages.
		        Valid choices are:
		        minus 9 - {-9 (512 per second)}
		        minus 8 - {-8 (256 per second)}
		        minus 7 - {-7 (128 per second)}
		        minus 6 - {-6 (64 per second)}
		        minus 5- {-5 (32 per second)}
		        minus 4 - {-4 (16 per second)}
		        minus 3 - {-3 (8 per second)}
		        minus 2 - {-2 (4 per second)}
		        minus 1 - {-1 (2 per second)}
		        0 - {0 (1 per second)}
		        1 - {1 (1 per 2 seconds)}
		        2 - {2 (1 per 4 seconds)}
		        3 - {3 (1 per 8 seconds)}
		        4 - {4 (1 per 16 seconds)}
		        5 - {5 (1 per 32 seconds)}
		        6 - {6 (1 per 64 seconds)}
		        7 - {7 (1 per 128 seconds)}
		        8 - {8 (1 per 256 seconds)}
		        9 - {9 (1 per 512 seconds)}
		    -log_delay_req_interval
		        The log mean time interval between successive Delay_Req messages.
		        Valid choices are:
		        minus 9 - {-9 (512 per second)}
		        minus 8 - {-8 (256 per second)}
		        minus 7 - {-7 (128 per second)}
		        minus 6 - {-6 (64 per second)}
		        minus 5- {-5 (32 per second)}
		        minus 4 - {-4 (16 per second)}
		        minus 3 - {-3 (8 per second)}
		        minus 2 - {-2 (4 per second)}
		        minus 1 - {-1 (2 per second)}
		        0 - {0 (1 per second)}
		        1 - {1 (1 per 2 seconds)}
		        2 - {2 (1 per 4 seconds)}
		        3 - {3 (1 per 8 seconds)}
		        4 - {4 (1 per 16 seconds)}
		        5 - {5 (1 per 32 seconds)}
		        6 - {6 (1 per 64 seconds)}
		        7 - {7 (1 per 128 seconds)}
		        8 - {8 (1 per 256 seconds)}
		        9 - {9 (1 per 512 seconds)}
		    -log_sync_interval
		        The log mean time interval between successive Sync messages.
		        Valid choices are:
		        minus 9 - {-9 (512 per second)}
		        minus 8 - {-8 (256 per second)}
		        minus 7 - {-7 (128 per second)}
		        minus 6 - {-6 (64 per second)}
		        minus 5- {-5 (32 per second)}
		        minus 4 - {-4 (16 per second)}
		        minus 3 - {-3 (8 per second)}
		        minus 2 - {-2 (4 per second)}
		        minus 1 - {-1 (2 per second)}
		        0 - {0 (1 per second)}
		        1 - {1 (1 per 2 seconds)}
		        2 - {2 (1 per 4 seconds)}
		        3 - {3 (1 per 8 seconds)}
		        4 - {4 (1 per 16 seconds)}
		        5 - {5 (1 per 32 seconds)}
		        6 - {6 (1 per 64 seconds)}
		        7 - {7 (1 per 128 seconds)}
		        8 - {8 (1 per 256 seconds)}
		        9 - {9 (1 per 512 seconds)}
		    -master_count
		        The total number of Unicast masters to be used for the device group.
		    -master_ip_address
		        Defines the base address to be used for enumerating all the addresses
		        in the device group.
		    -master_ip_increment_by
		        Defines the increment to be used for enumerating all the addresses
		        in the device group.
		n   -master_ip_increment_inter_entity
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -master_mac_address
		        Defines the base address to be used for enumerating all the addresses
		        in the device group.
		    -master_mac_increment_by
		        Defines the increment to be used for enumerating all the addresses
		        in the device group.
		    -master_mac_increment_inter_entity
		        Defines the increment to be used for the start address of Master.
		    -name
		        Name of protocol.
		    -port_number
		        Port number.
		n   -port_number_increment
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -priority1
		        PTP priority1
		    -priority2
		        PTP priority2.
		    -renewal_invited
		        Set the Renewal Invited flag in Grant Unicast Transmission TLV.
		    -request_attempts
		        How many succesive requests a slave can request before entering into holddown.
		    -request_holddown
		        Time between succesive requests if denied/timeout for Signal Request.
		    -request_interval
		        Time between succesive requests if denied/timeout for Signal Request.
		    -residence_time
		        Master to slave residence time of the associated transparent clock.
		    -rx_calibration
		        The amount of time (in ns) that the Receive side timestamp needs to be offset to allow for error.
		    -send_announce_multicast
		        Send multicast Announce messages.
		    -send_announce_tlv
		        Send and respond to Announce TLV unicast requests in signal messages.
		    -send_cancel_tlv
		        Send and respond to Cancel TLV unicast requests in signal messages.
		    -signal_interval
		        Time between Signal Request messages, in seconds.
		    -signal_unicast_handling
		        Valid choices are:
		        individually - {Send Individually}
		        allInOne - {Send In One Message}
		        doNotSend - {Do Not Send}
		    -step_mode
		        Clock step mode.
		        Valid choices are:
		        two-step - TwoStep
		        single-step - SingleStep
		    -steps_removed
		        The number of hops between the Grandmaster Clock and the emulated clock. Valid values: 0 to 65,535.
		    -strict_grant
		        If selected, server will not grant values that are above maximum offered values.
		    -sync_drop_rate
		        Percentage rate of the dropped Sync messages.
		    -sync_receipt_timeout
		        Sync Receipt Timeout in seconds.
		    -time_source
		        Time source for the PTP device.
		        Valid choices are:
		        0X10 - AtomicClock
		        0X20 - GPS
		        0X30 - TerrestrialRadio
		        0X40 - PTP
		        0X50 - NTP
		        0X60 - HandSet
		        0X90 - Other
		        0XA0 - InternalOscilator
		    -timestamp_offset
		        Timestamp offset.
		n   -timestamp_offset_variation
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -tx_calibration
		        The amount of time (in ns) that the Transmit side timestamp needs to be offset to allow for error.
		    -use_alternate_master_flag
		        Select this check box to set the Alternate Master flag in all Announce and Sync messages.
		    -use_clock_identity
		        Use the ClockIdentity configured below.
		x   -one_way
		x       Do not send Delay Requests.
		x   -simulate_transparent
		x       Simulate a transparent clock in front of this master clock.
		x   -sync_residence_time
		x       Master to slave residence time of the associated transparent clock for Sync messages.
		x   -follow_up_residence_time
		x       Master to slave residence time of the associated transparent clock for FollowUp messages.
		x   -delay_req_residence_time
		x       Slave to master residence time of the associated transparent clock for DelayReq messages.
		x   -delay_resp_residence_time
		x       Master to slave residence time of the associated transparent clock for DelayResp messages.
		x   -p_delay_follow_up_residence_time
		x       Master to slave residence time of the associated transparent clock for PdelayFollowUp messages.
		x   -offset_scaled_log_variance
		x       Static Offset Scaled Log Variance of this clock.
		x   -role
		x       The desired role of this clock.
		x   -profile
		x       The profile used by this clock.
		x   -master_ipv6_address
		x       Defines the base address to be used for enumerating all the addresses in device group.
		x   -master_ipv6_increment_by
		x       Defines the increment to be used for enumerating all the addresses in the device group.
		x   -slave_ipv6_address
		x       Defines the base address to be used for enumerating all the addresses in the device group.
		x   -slave_ipv6_increment_by
		x       Defines the increment to be used for enumerating all the addresses in the device group.
		    -mtu
		        The advertised MTU value in database entries sent to other routers
		        create on the Ixia interface. RANGE 68-9216.
		x   -mac_address_init
		x       This option defines the MAC address that will be configured on
		x       the Ixia interface. This parameter is not valid on mode modify when
		x       IxTclProtocol is used.
		x   -mac_address_step
		x       This option defines the incrementing step for the MAC address that
		x       will be configured on the Ixia interface.
		x   -vlan
		x       Enables vlan.
		    -vlan_id_mode
		        If the user configures more than one interface on the Ixia with
		        VLAN, he can choose to automatically increment the VLAN tag or
		        leave it idle for each interface. CHOICES fixed increment.
		        This parameter is not valid on mode modify when IxTclProtocol is used.
		    -vlan_id
		        If VLAN is enable on the Ixia interface, this option will configure
		        the VLAN number.
		    -vlan_id_step
		        If the -vlan_id_mode is increment, this will be the step value by
		        which the VLAN tags are incremented. RANGE 0-4095
		        When vlan_id_step causes the vlan_id value to exceed it's maximum value the
		        increment will be done modulo <number of possible vlan ids>.
		        Examples: vlan_id = 4094; vlan_id_step = 2-> new vlan_id value = 0
		        vlan_id = 4095; vlan_id_step = 11 -> new vlan_id value = 10
		    -vlan_user_priority
		    -ip_type
		        ipv4
		        ipv6
		    -intf_ip_addr
		        The IP address of the IP Protocol from underneath PTP Protocol
		    -intf_ip_addr_step
		        What step will be use for incrementing the -intf_ip_addr option.
		    -intf_prefix_length
		        Defines the mask of the IP address used for the Ixia (-intf_ip_addr)
		        and the DUT interface.
		    -neighbor_intf_ip_addr
		        The IPv4 address of the gateway.
		    -neighbor_intf_ip_addr_step
		        What step will be use for incrementing the -neighbor_intf_ip_addr option.
		    -intf_ipv6_addr
		        The IPv6 address of the IP Protocol from underneath the PTP Protocol.
		    -intf_ipv6_addr_step
		        What step will be use for incrementing the -intf_ipv6_addr option.
		    -intf_prefixv6_length
		        Defines the mask of the IPv6 address used for the Ixia (-intf_ipv6_addr)
		        and the DUT interface.
		    -neighbor_intf_ipv6_addr
		        The IPv6 address of the gateway.
		    -neighbor_intf_ipv6_addr_step
		        What step will be use for incrementing the -neighbor_intf_ipv6_addr option.
		x   -num_sessions
		x       The number of PTP sessions to configure.
		
		 Return Values:
		    A list containing the ptp protocol stack handles that were added by the command (if any).
		x   key:ptp_handle  value:A list containing the ptp protocol stack handles that were added by the command (if any).
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:handle      value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    $::SUCCESS | $::FAILURE
		    key:status      value:$::SUCCESS | $::FAILURE
		    ptp_over_ip handles
		    key:handles     value:ptp_over_ip handles
		    When status is failure, contains more information
		    key:log         value:When status is failure, contains more information
		
		 Examples:
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  handle
		
		 See Also:
		    External documentation on Tclx keyed lists
		
		'''
		hlpy_args = locals().copy()
		hlpy_args.update(kwargs)
		del hlpy_args['self']
		del hlpy_args['kwargs']

		not_implemented_params = []
		mandatory_params = []
		file_params = []

		try:
			return self.__execute_command(
				'ptp_over_ip_config', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
