##Procedure Header
# Name:
#    ixiangpf::emulation_dhcp_stats
#
# Description:
#    Controls DHCP subscriber group activity.
#
# Synopsis:
#    ixiangpf::emulation_dhcp_stats
#        [-port_handle       ANY]
#        [-action            CHOICES clear]
#        [-handle            ANY]
#        [-mode              CHOICES session
#                            CHOICES aggregate_stats
#                            CHOICES aggregate_stats_relay_agent
#                            DEFAULT aggregate_stats]
#        [-dhcp_version      CHOICES dhcp4 dhcp6]
#x       [-dhcp_relay_type   CHOICES normal lightweight
#x                           DEFAULT normal]
#n       [-no_write          ANY]
#n       [-version           ANY]
#x       [-execution_timeout NUMERIC
#x                           DEFAULT 1800]
#
# Arguments:
#    -port_handle
#        Specifies the port upon which emulation id configured.
#        This parameter is returned from emulation_dhcp_config proc.
#        Emulation must have been previously enabled on the specified port
#        via a call to emulation_dhcp_group_config proc.
#        This option is mandatory when -version is ixtclhal.
#        When -version is ixnetwork, one of -port_handle or -handle parameters
#        should be provided.
#    -action
#        Clear - reset the statistics for the specified port/subscriber group
#        to 0. This parameter will be ignored if it is used.
#    -handle
#        Allows the user to optionally select the groups to which the
#        specified action is to be applied.
#        If this parameter is not specified, then the specified action is
#        applied to all groups configured on the port specified by
#        the -port_handle command. The handle is obtained from the keyed list returned
#        in the call to emulation_dhcp_group_config proc.
#        The port handle parameter must have been initialized and dhcp group
#        emulation must have been configured prior to calling this function.
#        This option is not supported with IxTclAccess and will be ignored if it is used.
#        For IxTclNetwork the statistics will be aggregated at port level (the
#        port on which this handle has been configured). The stats aggregate.<stat key>
#        will represent the aggregated port stats for the first port if multiple
#        handles are provided.
#    -mode
#    -dhcp_version
#x   -dhcp_relay_type
#n   -no_write
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -version
#n       This argument defined by Cisco is not supported for NGPF implementation.
#x   -execution_timeout
#x       This is the timeout for the function.
#x       The setting is in seconds.
#x       Setting this setting to 60 it will mean that the command must complete in under 60 seconds.
#x       If the command will last more than 60 seconds the command will be terminated by force.
#x       This flag can be used to prevent dead locks occuring in IxNetwork.
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status                                             value:$::SUCCESS | $::FAILURE
#    When status is failure, contains more information
#    key:log                                                value:When status is failure, contains more information
#    Port Name
#    key:aggregate.port_name                                value:Port Name
#    Number of currently attempting interfaces. Supported with IxTclHal, IxTclNetwork.
#    key:aggregate.currently_attempting                     value:Number of currently attempting interfaces. Supported with IxTclHal, IxTclNetwork.
#    Number of interfaces not bounded. Supported with IxTclHal, IxTclNetwork.
#    key:aggregate.currently_idle                           value:Number of interfaces not bounded. Supported with IxTclHal, IxTclNetwork.
#    Number of addresses learned. Supported with IxTclHal, IxTclNetwork.
#    key:aggregate.currently_bound                          value:Number of addresses learned. Supported with IxTclHal, IxTclNetwork.
#    Percent rate of addresses learned. Supported with IxTclHal, IxTclNetwork.
#    key:aggregate.success_percentage                       value:Percent rate of addresses learned. Supported with IxTclHal, IxTclNetwork.
#    Number of discovered messages sent. Supported with IxTclHal, IxTclNetwork.
#    key:aggregate.discover_tx_count                        value:Number of discovered messages sent. Supported with IxTclHal, IxTclNetwork.
#    Number of requests sent. Supported with IxTclHal, IxTclNetwork.
#    key:aggregate.request_tx_count                         value:Number of requests sent. Supported with IxTclHal, IxTclNetwork.
#    Number of releases sent. Supported with IxTclHal, IxTclNetwork.
#    key:aggregate.release_tx_count                         value:Number of releases sent. Supported with IxTclHal, IxTclNetwork.
#    Number of acks received. Supported with IxTclHal, IxTclNetwork.
#    key:aggregate.ack_rx_count                             value:Number of acks received. Supported with IxTclHal, IxTclNetwork.
#    Number of nacks received. Supported with IxTclHal, IxTclNetwork.
#    key:aggregate.nak_rx_count                             value:Number of nacks received. Supported with IxTclHal, IxTclNetwork.
#    Number of offers received. Supported with IxTclHal, IxTclNetwork.
#    key:aggregate.offer_rx_count                           value:Number of offers received. Supported with IxTclHal, IxTclNetwork.
#    Number of DHCPv4 DHCPDECLINE messages sent. A DHCPDECLINE message is sent to the server if the DHCP client is assigned any IP address from the 10.0.x.x subnet, any multicast address, or any of the following addresses: 0.0.0.0, 255.255.255.255, 127.0.0.1. Supported with IxTclNetwork.
#    key:aggregate.declines_tx_count                        value:Number of DHCPv4 DHCPDECLINE messages sent. A DHCPDECLINE message is sent to the server if the DHCP client is assigned any IP address from the 10.0.x.x subnet, any multicast address, or any of the following addresses: 0.0.0.0, 255.255.255.255, 127.0.0.1. Supported with IxTclNetwork.
#    Number of enabled DHCPv4 interfaces. Supported with IxTclNetwork.
#    key:aggregate.enabled_interfaces                       value:Number of enabled DHCPv4 interfaces. Supported with IxTclNetwork.
#    Number of addresses learned. Supported with IxTclNetwork.
#    key:aggregate.addr_discovered                          value:Number of addresses learned. Supported with IxTclNetwork.
#    Number of clients that were started. This corresponds to number of started DHCP discovery sessions. Supported with IxTclNetwork.
#    key:aggregate.setup_initiated                          value:Number of clients that were started. This corresponds to number of started DHCP discovery sessions. Supported with IxTclNetwork.
#    Number of addresses that were successful configured. Supported with IxTclNetwork.
#    key:aggregate.setup_success                            value:Number of addresses that were successful configured. Supported with IxTclNetwork.
#    The rate at which addresses were successful configured (addresses set up per second). Supported with IxTclNetwork.
#    key:aggregate.setup_success_rate                       value:The rate at which addresses were successful configured (addresses set up per second). Supported with IxTclNetwork.
#    Number of addresses that could not be configured until the Number of Retransmissions was exceeded. Supported with IxTclNetwork.
#    key:aggregate.setup_fail                               value:Number of addresses that could not be configured until the Number of Retransmissions was exceeded. Supported with IxTclNetwork.
#    Number of address teardowns that were initiated. Supported with IxTclNetwork.
#    key:aggregate.teardown_initiated                       value:Number of address teardowns that were initiated. Supported with IxTclNetwork.
#    Number of addresses that were successful torn down. Supported with IxTclNetwork.
#    key:aggregate.teardown_success                         value:Number of addresses that were successful torn down. Supported with IxTclNetwork.
#    Number of addresses that could not be torn down until the Number of Retransmissions was exceeded. Supported with IxTclNetwork.
#    key:aggregate.teardown_failed                          value:Number of addresses that could not be torn down until the Number of Retransmissions was exceeded. Supported with IxTclNetwork.
#    Number of relay agent sessions that are up. Supported with IxTclNetwork.
#    key:aggregate.relay_agent_sessions_up                  value:Number of relay agent sessions that are up. Supported with IxTclNetwork.
#    Number of relay agent sessions that are down. Supported with IxTclNetwork.
#    key:aggregate.relay_agent_sessions_down                value:Number of relay agent sessions that are down. Supported with IxTclNetwork.
#    Number of relay agent sessions that are not started. Supported with IxTclNetwork.
#    key:aggregate.relay_agent_sessions_not_started         value:Number of relay agent sessions that are not started. Supported with IxTclNetwork.
#    Total number of relay agent sessions. Supported with IxTclNetwork.
#    key:aggregate.relay_agent_sessions_total               value:Total number of relay agent sessions. Supported with IxTclNetwork.
#    Force Renew Rx
#    key:aggregate.rx.force_renew                           value:Force Renew Rx
#    Port Name
#    key:<port_handle>.aggregate.port_name                  value:Port Name
#    Number of enabled interfaces. Supported with IxTclNetwork.
#    key:<port_handle>.aggregate.currently_attempting       value:Number of enabled interfaces. Supported with IxTclNetwork.
#    Number of interfaces not bounded. Supported with IxTclNetwork.
#    key:<port_handle>.aggregate.currently_idle             value:Number of interfaces not bounded. Supported with IxTclNetwork.
#    Number of addresses learned. Supported with IxTclNetwork.
#    key:<port_handle>.aggregate.currently_bound            value:Number of addresses learned. Supported with IxTclNetwork.
#    Percent rate of addresses learned. Supported with IxTclNetwork.
#    key:<port_handle>.aggregate.success_percentage         value:Percent rate of addresses learned. Supported with IxTclNetwork.
#    Number of discovered messages sent. Supported with IxTclNetwork.
#    key:<port_handle>.aggregate.discover_tx_count          value:Number of discovered messages sent. Supported with IxTclNetwork.
#    Number of requests sent. Supported with IxTclNetwork.
#    key:<port_handle>.aggregate.request_tx_count           value:Number of requests sent. Supported with IxTclNetwork.
#    Number of releases sent. Supported with IxTclNetwork.
#    key:<port_handle>.aggregate.release_tx_count           value:Number of releases sent. Supported with IxTclNetwork.
#    Number of acks received. Supported with IxTclNetwork.
#    key:<port_handle>.aggregate.ack_rx_count               value:Number of acks received. Supported with IxTclNetwork.
#    Number of nacks received. Supported with IxTclNetwork.
#    key:<port_handle>.aggregate.nak_rx_count               value:Number of nacks received. Supported with IxTclNetwork.
#    Number of offers received. Supported with IxTclNetwork.
#    key:<port_handle>.aggregate.offer_rx_count             value:Number of offers received. Supported with IxTclNetwork.
#    Number of DHCPv4 DHCPDECLINE messages sent. A DHCPDECLINE message is sent to the server if the DHCP client is assigned any IP address from the 10.0.x.x subnet, any multicast address, or any of the following addresses: 0.0.0.0, 255.255.255.255, 127.0.0.1. Supported with IxTclNetwork.
#    key:<port_handle>.aggregate.declines_tx_count          value:Number of DHCPv4 DHCPDECLINE messages sent. A DHCPDECLINE message is sent to the server if the DHCP client is assigned any IP address from the 10.0.x.x subnet, any multicast address, or any of the following addresses: 0.0.0.0, 255.255.255.255, 127.0.0.1. Supported with IxTclNetwork.
#    Number of enabled DHCPv4 interfaces. Supported with IxTclNetwork.
#    key:<port_handle>.aggregate.enabled_interfaces         value:Number of enabled DHCPv4 interfaces. Supported with IxTclNetwork.
#    Number of addresses learned. Supported with IxTclNetwork.
#    key:<port_handle>.aggregate.addr_discovered            value:Number of addresses learned. Supported with IxTclNetwork.
#    Number of clients that were started. This corresponds to number of started DHCP discovery sessions. Supported with IxTclNetwork.
#    key:<port_handle>.aggregate.setup_initiated            value:Number of clients that were started. This corresponds to number of started DHCP discovery sessions. Supported with IxTclNetwork.
#    Number of addresses that were successful configured. Supported with IxTclNetwork.
#    key:<port_handle>.aggregate.setup_success              value:Number of addresses that were successful configured. Supported with IxTclNetwork.
#    The rate at which addresses were successful configured (addresses set up per second). Supported with IxTclNetwork.
#    key:<port_handle>.aggregate.setup_success_rate         value:The rate at which addresses were successful configured (addresses set up per second). Supported with IxTclNetwork.
#    Number of addresses that could not be configured until the Number of Retransmissions was exceeded. Supported with IxTclNetwork.
#    key:<port_handle>.aggregate.setup_fail                 value:Number of addresses that could not be configured until the Number of Retransmissions was exceeded. Supported with IxTclNetwork.
#    Number of address teardowns that were initiated. Supported with IxTclNetwork.
#    key:<port_handle>.aggregate.teardown_initiated         value:Number of address teardowns that were initiated. Supported with IxTclNetwork.
#    Number of addresses that were successful torn down. Supported with IxTclNetwork.
#    key:<port_handle>.aggregate.teardown_success           value:Number of addresses that were successful torn down. Supported with IxTclNetwork.
#    Number of addresses that could not be torn down until the Number of Retransmissions was exceeded. Supported with IxTclNetwork.
#    key:<port_handle>.aggregate.teardown_failed            value:Number of addresses that could not be torn down until the Number of Retransmissions was exceeded. Supported with IxTclNetwork.
#    Requests NAKed
#    key:<port_handle>.aggregate.rx.nak                     value:Requests NAKed
#    Requests NAKed
#    key:aggregate.rx.nak                                   value:Requests NAKed
#    Reconfigure Received
#    key:<port_handle>.aggregate.reconfigure_rx             value:Reconfigure Received
#    Reconfigure Received
#    key:aggregate.reconfigure_rx                           value:Reconfigure Received
#    Force Renew Rx
#    key:<port_handle>.aggregate.rx.force_renew             value:Force Renew Rx
#    Force Renew Rx
#    key:<device_group>.aggregate.rx.force_renew            value:Force Renew Rx
#    Reconfigure Received
#    key:<device_group>.aggregate.reconfigure_rx            value:Reconfigure Received
#    key:<device_group>.aggregate.rx.nak                    value:
#    Port Name
#    key:ipv6.aggregate.port_name                           value:Port Name
#    Number of currently attempting interfaces. Supported with IxTclHal, IxTclNetwork.
#    key:ipv6.aggregate.currently_attempting                value:Number of currently attempting interfaces. Supported with IxTclHal, IxTclNetwork.
#    Number of interfaces not bounded. Supported with IxTclHal, IxTclNetwork.
#    key:ipv6.aggregate.currently_idle                      value:Number of interfaces not bounded. Supported with IxTclHal, IxTclNetwork.
#    Number of addresses learned. Supported with IxTclHal, IxTclNetwork.
#    key:ipv6.aggregate.currently_bound                     value:Number of addresses learned. Supported with IxTclHal, IxTclNetwork.
#    Number of solicit messages sent. Supported with IxTclHal, IxTclNetwork.
#    key:ipv6.aggregate.solicits_tx_count                   value:Number of solicit messages sent. Supported with IxTclHal, IxTclNetwork.
#    Number of advertisement messages received. Supported with IxTclHal, IxTclNetwork.
#    key:ipv6.aggregate.adv_rx_count                        value:Number of advertisement messages received. Supported with IxTclHal, IxTclNetwork.
#    Number of advertisement messages received but ignored. Supported with IxTclHal, IxTclNetwork.
#    key:ipv6.aggregate.adv_ignored                         value:Number of advertisement messages received but ignored. Supported with IxTclHal, IxTclNetwork.
#    Number of requests sent. Supported with IxTclHal, IxTclNetwork.
#    key:ipv6.aggregate.request_tx_count                    value:Number of requests sent. Supported with IxTclHal, IxTclNetwork.
#    The number of DHCPv6 addresses learned. Supported with IxTclNetwork.
#    key:ipv6.aggregate.addr_discovered                     value:The number of DHCPv6 addresses learned. Supported with IxTclNetwork.
#    The number of DHCPv6 enabled interfaces. Supported with IxTclNetwork.
#    key:ipv6.aggregate.enabled_interfaces                  value:The number of DHCPv6 enabled interfaces. Supported with IxTclNetwork.
#    Number of reply messages received. Supported with IxTclNetwork.
#    key:ipv6.aggregate.reply_rx_count                      value:Number of reply messages received. Supported with IxTclNetwork.
#    Number of release messages sent. Supported with IxTclHal, IxTclNetwork.
#    key:ipv6.aggregate.release_tx_count                    value:Number of release messages sent. Supported with IxTclHal, IxTclNetwork.
#    Number of clients that were started. This corresponds to number of started DHCP discovery sessions. Supported with IxTclNetwork.
#    key:ipv6.aggregate.setup_initiated                     value:Number of clients that were started. This corresponds to number of started DHCP discovery sessions. Supported with IxTclNetwork.
#    Number of addresses that were successful configured. Supported with IxTclNetwork.
#    key:ipv6.aggregate.setup_success                       value:Number of addresses that were successful configured. Supported with IxTclNetwork.
#    The rate at which addresses were successful configured (addresses set up per second). Supported with IxTclNetwork.
#    key:ipv6.aggregate.setup_success_rate                  value:The rate at which addresses were successful configured (addresses set up per second). Supported with IxTclNetwork.
#    Number of addresses that could not be configured until the REQ_MAX_RC was exceeded. Supported with IxTclNetwork.
#    key:ipv6.aggregate.setup_fail                          value:Number of addresses that could not be configured until the REQ_MAX_RC was exceeded. Supported with IxTclNetwork.
#    Number of address teardowns that were initiated. Supported with IxTclNetwork.
#    key:ipv6.aggregate.teardown_initiated                  value:Number of address teardowns that were initiated. Supported with IxTclNetwork.
#    Number of addresses that were successful torn down. Supported with IxTclNetwork.
#    key:ipv6.aggregate.teardown_success                    value:Number of addresses that were successful torn down. Supported with IxTclNetwork.
#    Number of interfaces that could not be configured until the REL_MAX_RC was exceeded. Supported with IxTclNetwork.
#    key:ipv6.aggregate.teardown_failed                     value:Number of interfaces that could not be configured until the REL_MAX_RC was exceeded. Supported with IxTclNetwork.
#    Port Name
#    key:ipv6.<port_handle>.aggregate.port_name             value:Port Name
#    Number of currently attempting interfaces. Supported with IxTclHal, IxTclNetwork.
#    key:ipv6.<port_handle>.aggregate.currently_attempting  value:Number of currently attempting interfaces. Supported with IxTclHal, IxTclNetwork.
#    Number of interfaces not bounded. Supported with IxTclHal, IxTclNetwork.
#    key:ipv6.<port_handle>.aggregate.currently_idle        value:Number of interfaces not bounded. Supported with IxTclHal, IxTclNetwork.
#    Number of addresses learned. Supported with IxTclHal, IxTclNetwork.
#    key:ipv6.<port_handle>.aggregate.currently_bound       value:Number of addresses learned. Supported with IxTclHal, IxTclNetwork.
#    Number of solicit messages sent. Supported with IxTclHal, IxTclNetwork.
#    key:ipv6.<port_handle>.aggregate.solicits_tx_count     value:Number of solicit messages sent. Supported with IxTclHal, IxTclNetwork.
#    Number of advertisement messages received. Supported with IxTclHal, IxTclNetwork.
#    key:ipv6.<port_handle>.aggregate.adv_rx_count          value:Number of advertisement messages received. Supported with IxTclHal, IxTclNetwork.
#    Number of advertisement messages received but ignored. Supported with IxTclHal, IxTclNetwork.
#    key:ipv6.<port_handle>.aggregate.adv_ignored           value:Number of advertisement messages received but ignored. Supported with IxTclHal, IxTclNetwork.
#    Number of requests sent. Supported with IxTclHal, IxTclNetwork.
#    key:ipv6.<port_handle>.aggregate.request_tx_count      value:Number of requests sent. Supported with IxTclHal, IxTclNetwork.
#    The number of DHCPv6 addresses learned. Supported with IxTclNetwork.
#    key:ipv6.<port_handle>.aggregate.addr_discovered       value:The number of DHCPv6 addresses learned. Supported with IxTclNetwork.
#    The number of DHCPv6 enabled interfaces. Supported with IxTclNetwork.
#    key:ipv6.<port_handle>.aggregate.enabled_interfaces    value:The number of DHCPv6 enabled interfaces. Supported with IxTclNetwork.
#    Number of reply messages received. Supported with IxTclNetwork.
#    key:ipv6.<port_handle>.aggregate.reply_rx_count        value:Number of reply messages received. Supported with IxTclNetwork.
#    Number of release messages sent. Supported with IxTclHal, IxTclNetwork.
#    key:ipv6.<port_handle>.aggregate.release_tx_count      value:Number of release messages sent. Supported with IxTclHal, IxTclNetwork.
#    Number of clients that were started. This corresponds to number of started DHCP discovery sessions. Supported with IxTclNetwork.
#    key:ipv6.<port_handle>.aggregate.setup_initiated       value:Number of clients that were started. This corresponds to number of started DHCP discovery sessions. Supported with IxTclNetwork.
#    Number of addresses that were successful configured. Supported with IxTclNetwork.
#    key:ipv6.<port_handle>.aggregate.setup_success         value:Number of addresses that were successful configured. Supported with IxTclNetwork.
#    The rate at which addresses were successful configured (addresses set up per second). Supported with IxTclNetwork.
#    key:ipv6.<port_handle>.aggregate.setup_success_rate    value:The rate at which addresses were successful configured (addresses set up per second). Supported with IxTclNetwork.
#    Number of addresses that could not be configured until the REQ_MAX_RC was exceeded. Supported with IxTclNetwork.
#    key:ipv6.<port_handle>.aggregate.setup_fail            value:Number of addresses that could not be configured until the REQ_MAX_RC was exceeded. Supported with IxTclNetwork.
#    Number of address teardowns that were initiated. Supported with IxTclNetwork.
#    key:ipv6.<port_handle>.aggregate.teardown_initiated    value:Number of address teardowns that were initiated. Supported with IxTclNetwork.
#    Number of addresses that were successful torn down. Supported with IxTclNetwork.
#    key:ipv6.<port_handle>.aggregate.teardown_success      value:Number of addresses that were successful torn down. Supported with IxTclNetwork.
#    Number of interfaces that could not be configured until the REL_MAX_RC was exceeded. Supported with IxTclNetwork.
#    key:ipv6.<port_handle>.aggregate.teardown_failed       value:Number of interfaces that could not be configured until the REL_MAX_RC was exceeded. Supported with IxTclNetwork.
#    No of enabled interfaces on that group. Supported with IxTclHal.
#    key:group.<group>.currently_attempting                 value:No of enabled interfaces on that group. Supported with IxTclHal.
#    No of interfaces not bounded on that group. Supported with IxTclHal.
#    key:group.<group>.currently_idle                       value:No of interfaces not bounded on that group. Supported with IxTclHal.
#    No of addresses learned on that group. Supported with IxTclHal.
#    key:group.<group>.currently_bound                      value:No of addresses learned on that group. Supported with IxTclHal.
#    Port Name
#    key:session.<session ID>.port_name                     value:Port Name
#    Session Name
#    key:session.<session ID>.session_name                  value:Session Name
#    Port handle
#n   key:session.<session ID>.port_handle                   value:Port handle
#    DHCP group handle
#n   key:session.<session ID>.dhcp_group                    value:DHCP group handle
#    Discovers Sent (valid only for DHCPv4)
#    key:session.<session ID>.discovers_sent                value:Discovers Sent (valid only for DHCPv4)
#    Offers Received (valid only for DHCPv4)
#    key:session.<session ID>.offers_received               value:Offers Received (valid only for DHCPv4)
#    Requests Sent
#    key:session.<session ID>.requests_sent                 value:Requests Sent
#    ACKs Received (valid only for DHCPv4)
#    key:session.<session ID>.acks_received                 value:ACKs Received (valid only for DHCPv4)
#    NACKs Received (valid only for DHCPv4)
#    key:session.<session ID>.nacks_received                value:NACKs Received (valid only for DHCPv4)
#    Releases Sent
#    key:session.<session ID>.releases_sent                 value:Releases Sent
#    Declines Sent (valid only for DHCPv4)
#    key:session.<session ID>.declines_sent                 value:Declines Sent (valid only for DHCPv4)
#    IP Address
#    key:session.<session ID>.ip_address                    value:IP Address
#    Gateway Address
#    key:session.<session ID>.gateway_address               value:Gateway Address
#    Lease Time
#    key:session.<session ID>.lease_time                    value:Lease Time
#    Solicits Sent (valid only for DHCPv6)
#    key:session.<session ID>.solicits_sent                 value:Solicits Sent (valid only for DHCPv6)
#    Advertisements Received (valid only for DHCPv6)
#    key:session.<session ID>.advertisements_received       value:Advertisements Received (valid only for DHCPv6)
#    Advertisements Ignored (valid only for DHCPv6)
#    key:session.<session ID>.advertisements_ignored        value:Advertisements Ignored (valid only for DHCPv6)
#    Replies Received (valid only for DHCPv6)
#    key:session.<session ID>.replies_received              value:Replies Received (valid only for DHCPv6)
#    Force Renew (valid only for DHCPv4)
#    key:session.<session ID>.rx.force_renew                value:Force Renew (valid only for DHCPv4)
#    Reconfigure Rx (valid only for DHCPv6)
#    key:session.<session ID>.reconfigure_rx                value:Reconfigure Rx (valid only for DHCPv6)
#    Cisco only
#n   key:aggregate.elapsed_time                             value:Cisco only
#    Cisco only
#n   key:aggregate.total_attempted                          value:Cisco only
#    Cisco only
#n   key:aggregate.total_retried                            value:Cisco only
#    Cisco only
#n   key:aggregate.total_bound                              value:Cisco only
#    Cisco only
#n   key:aggregate.bound_renewed                            value:Cisco only
#    Cisco only
#n   key:aggregate.total_failed                             value:Cisco only
#    Cisco only
#n   key:aggregate.bind_rate                                value:Cisco only
#    Cisco only
#n   key:aggregate.attempted_rate                           value:Cisco only
#    Cisco only
#n   key:aggregate.minimum_setup_time                       value:Cisco only
#    Cisco only
#n   key:aggregate.maximum_setup_time                       value:Cisco only
#    Cisco only
#n   key:aggregate.average_setup_time                       value:Cisco only
#    Cisco only
#n   key:group.<group>.elapsed_time                         value:Cisco only
#    Cisco only
#n   key:group.<group>.total_attempted                      value:Cisco only
#    Cisco only
#n   key:group.<group>.total_retried                        value:Cisco only
#    Cisco only
#n   key:group.<group>.bound_renewed                        value:Cisco only
#    Cisco only
#n   key:group.<group>.total_bound                          value:Cisco only
#    Cisco only
#n   key:group.<group>.total_failed                         value:Cisco only
#    Cisco only
#n   key:group.<group>.bind_rate                            value:Cisco only
#    Cisco only
#n   key:group.<group>.attempt_rate                         value:Cisco only
#    Cisco only
#n   key:group.<group>.request_rate                         value:Cisco only
#    Cisco only
#n   key:group.<group>.release_rate                         value:Cisco only
#    Cisco only
#n   key:group.<group>.discover_tx_count                    value:Cisco only
#    Cisco only
#n   key:group.<group>.request_tx_count                     value:Cisco only
#    Cisco only
#n   key:group.<group>.release_tx_count                     value:Cisco only
#    Cisco only
#n   key:group.<group>.ack_rx_count                         value:Cisco only
#    Cisco only
#n   key:group.<group>.nak_rx_count                         value:Cisco only
#    Cisco only
#n   key:group.<group>.offer_rx_count                       value:Cisco only
#    Cisco only
#n   key:<port_handle>.<group>.inform_tx_count              value:Cisco only
#    Cisco only
#n   key:<port_handle>.<group>.decline_tx_count             value:Cisco only
#
# Examples:
#
# Sample Input:
#    .
#
# Sample Output:
#    .
#
# Notes:
#    When retrieving IxTclHal stats, there will be a difference between the
#    aggregate and per group stats, because they are not extracted at the
#    same time. There is a delay between the time when aggregate are extracted
#    and the time  when per group stats are extracted. But in the end, when
#    all bindings are finished the results should correspond.
#
# See Also:
#

package ixiangpf;

use utils;
use ixiahlt;

sub emulation_dhcp_stats {

	my $args = shift(@_);

	my @notImplementedParams = ();
	my @mandatoryParams = ();
	my @fileParams = ();

	# ixiahlt::logHltapiCommand('emulation_dhcp_stats', $args);
	# ixiahlt::utrackerLog ('emulation_dhcp_stats', $args);

	return ixiangpf::runExecuteCommand('emulation_dhcp_stats', \@notImplementedParams, \@mandatoryParams, \@fileParams, $args);
}

# Return value for the package
return 1;
