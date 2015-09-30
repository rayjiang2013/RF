##Procedure Header
# Name:
#    ixiangpf::connect
#
# Description:
#    This command connects to the Ixia Chassis, takes ownership of selected
#    ports, and optionally loads a configuration on the chassis or resets the
#    targeted ports to factory defaults.
#    <p> When using an HLTSET that loads a network only version (*NO or
#    *P2NO + ixnetwork_tcl_server present) it is possible to resume a
#    previously configured session. This feature is triggered if the -reset
#    parameter is missing and the following scenarios are possible: </p>
#    <p> 1. Connect to IxNetwork Tcl Server (-ixnetwork_tcl_server) and pull the
#    existing configuration. The current configuration will be returned
#    as a keyed list (see the Return Values section). </p>
#    <p> 2. Connect to IxNetwork Tcl Server (-ixnetwork_tcl_server), load an
#    ixncfg (-config_file) and pull the configuration into HLT. The current
#    configuration will be returned as a keyed list (see Return Values section). </p>
#    <p> 3. Connect to IxNetwork Tcl Server (-ixnetwork_tcl_server), load an
#    ixncfg (-config_file), load an hlt configuration file (-config_file_hlt).
#    The configuration will not be returned because it is assumed that the
#    handles were initialized in a previous session. The hardware from IxNetwork
#    must be the same as the one from the 'config_file_hlt', otherwise the information
#    from the config file will not match the information from IxNetwork Tcl Server
#    and it will result in unpredictable errors. </p>
#    <p> 4. Save the current configuration using -mode save. If -config_file parameter
#    is specified, the ixncfg file will be saved in the <config_file> file. If
#    config_file_hlt parameter is specified, the hlt configuration file will be
#    saved in the <config_file_hlt> file. At least one of these parameters must be
#    specified. </p>
#    <p> If the -device and -port_list parameters are specified they will be mapped over the chassis
#    and ports detected on IxNetwork Tcl Server (available only if -config_file_hlt is not specified).
#    Otherwise, the hardware found on ixnetwork tcl server will be used for configuration.
#    Session resume is performed only on the first connect call from the script. Subsequent calls will
#    not load the configuration from the IxNetwork Tcl Server. </p>
#    <p> When using Unix, loading an ixncfg (-config_file) works only if HLT commands are executed locally,
#    on the Unix client machine. </p>
#
# Synopsis:
#    ixiangpf::connect
#        [-port_list                     REGEXP ^({*(\[0-9\]+/\[0-9\]+\[\\\ \]*)*}*\[\\\ \]*)+$]
#x       [-aggregation_mode              CHOICES normal
#x                                       CHOICES mixed
#x                                       CHOICES not_supported
#x                                       CHOICES single_mode_aggregation
#x                                       CHOICES dual_mode_aggregation
#x                                       CHOICES hundred_gig_non_fan_out
#x                                       CHOICES forty_gig_aggregation
#x                                       CHOICES forty_gig_fan_out
#x                                       CHOICES forty_gig_normal_mode
#x                                       CHOICES four_by_twenty_five_gig_non_fan_out
#x                                       CHOICES ten_gig_aggregation
#x                                       CHOICES ten_gig_fan_out
#x                                       CHOICES three_by_ten_gig_fan_out
#x                                       CHOICES four_by_ten_gig_fan_out
#x                                       CHOICES eight_by_ten_gig_fan_out]
#x       [-aggregation_resource_mode     CHOICES normal
#x                                       CHOICES dual_mode_aggregation
#x                                       CHOICES single_mode_aggregation
#x                                       CHOICES forty_gig_aggregation
#x                                       CHOICES hundred_gig_non_fan_out
#x                                       CHOICES forty_gig_fan_out
#x                                       CHOICES forty_gig_normal_mode
#x                                       CHOICES four_by_twenty_five_gig_non_fan_out
#x                                       CHOICES ten_gig_aggregation
#x                                       CHOICES ten_gig_fan_out
#x                                       CHOICES eight_by_ten_gig_fan_out
#x                                       CHOICES three_by_ten_gig_fan_out
#x                                       CHOICES four_by_ten_gig_fan_out]
#        [-device                        ANY]
#        [-break_locks                   CHOICES 0 1
#                                        DEFAULT 1]
#        [-close_server_on_disconnect    CHOICES 0 1
#                                        DEFAULT 1]
#x       [-config_file                   ANY]
#        [-config_file_hlt               ANY]
#x       [-connect_timeout               NUMERIC
#x                                       DEFAULT 10]
#x       [-enable_win_tcl_server         CHOICES 0 1
#x                                       DEFAULT 0]
#x       [-guard_rail                    CHOICES statistics none
#x                                       DEFAULT none]
#x       [-protocol_stacking_mode        CHOICES parallel sequential]
#x       [-interactive                   CHOICES 0 1]
#x       [-ixnetwork_tcl_server          ANY]
#x       [-ixnetwork_license_servers     ANY]
#x       [-ixnetwork_license_type        CHOICES perpetual
#x                                       CHOICES subscription_tier0
#x                                       CHOICES subscription_tier1
#x                                       CHOICES subscription_tier2
#x                                       CHOICES subscription_tier3
#x                                       CHOICES mixed]
#x       [-logging                       CHOICES hltapi_calls]
#x       [-log_path                      ANY]
#x       [-ixnetwork_tcl_proxy           ANY]
#x       [-master_device                 ANY]
#x       [-chain_sequence                ANY]
#x       [-chain_cables_length           ANY]
#x       [-chain_type                    CHOICES none daisy star
#x                                       DEFAULT none]
#        [-reset                         FLAG]
#x       [-session_resume_keys           CHOICES 0 1
#x                                       CHOICES 0 1
#x                                       DEFAULT 1]
#x       [-session_resume_include_filter ANY
#x                                       DEFAULT {}]
#        [-sync                          CHOICES 0 1
#                                        DEFAULT 1]
#        [-tcl_proxy_username            ANY]
#x       [-tcl_server                    ANY]
#        [-username                      ANY
#                                        DEFAULT \]
#x       [-mode                          CHOICES connect
#x                                       CHOICES disconnect
#x                                       CHOICES reconnect_ports
#x                                       CHOICES save
#x                                       DEFAULT connect]
#x       [-vport_count                   RANGE 1-600]
#x       [-vport_list                    REGEXP ^\[0-9\]+/\[0-9\]+/\[0-9\]
#x       [-execution_timeout             NUMERIC
#x                                       DEFAULT 0]
#x       [-return_detailed_handles       CHOICES 0 1
#x                                       DEFAULT 1]
#n       [-timeout                       ANY]
#n       [-nobios                        ANY]
#n       [-forceload                     ANY]
#
# Arguments:
#    -port_list
#        List of Ixia ports of which to take ownership.If multiple devices are
#        specified, then this is a list of lists.A single item is of the
#        form card number / port number.So card 2, port 4 would look like 2/4.
#        This parameter depends on 'vport_list' and 'vport_count' parameters. More details
#        are available in the description for parameter 'device'.
#x   -aggregation_mode
#x       This parameter represents the aggregation mode that can be set on the card.
#x   -aggregation_resource_mode
#x       This parameter represents the aggregation mode on each resource group on the card.
#    -device
#        IP address or name of the chassis. May contain a list of devices. When
#        IxNetwork Tcl API is used this parameter can have one of the following 4
#        meanings:
#        1. When 'vport_list' and 'vport_count' parameters are missing, a new chassis
#        is added, virtual ports are created and connected to
#        the real ports specified with 'port_list' parameter.
#        2. When 'vport_count' is specified this parameter is ignored and 'vport_count'
#        virtual ports are created. They will not be connected.
#        3. When 'vport_list' exists and -mode is 'connect' a connection to the
#        'device' chassis will be established. The real ports specified
#        with 'port_list' will be connected to the virtual ports specified
#        with 'vport_list'. The length and structure of the parameters
#        'port_list' and 'vport_list' must be the same
#        (e.g. -port_list {{2/3 2/4} {1/2 1/3 1/4}} -vport_list {{0/0/1 0/0/2} {0/0/3 0/0/4 0/0/5}}).
#        4. When 'vport_list' exists and -mode is 'disconnect' this parameter will be
#        ignored and the virtual ports specified with 'vport_list' will be
#        disconnected from the real ports they are currently connected to.
#    -break_locks
#        <p> Valid choices are: </p>
#        <table>
#        <tr><td>0</td><td>Force option is not used.</td></tr>
#        <tr><td>1</td><td>Force option is used when taking ownership.</td></tr>
#        </table>
#    -close_server_on_disconnect
#        When connecting to an IxNetwork Proxy Server this flag will be used to
#        determine if the IxNetwork session will be closed (shutdown) after the user
#        disconnects or it will remain Idle to allow future session resume.
#        <p> This parameter is ignored when not connecting to a IxNetwork Proxy Server
#        using IxTclNetwork (new API). </p>
#x   -config_file
#x       and/or the hlt configuration to the file specified with -config_file_hlt.
#    -config_file_hlt
#        Name of a file containing HLT configuration information. Valid only with an IxNetwork HLTSET
#        as part of the session resume capabilities.
#x   -connect_timeout
#x       Timeout in seconds to wait before failing connection to chassis when using IxNetwork TCL API is used.
#x       <p> From IxNetwork the connection to chassis is performed when
#x       ::<namespace>::interface_config procedure is called. The timeout will not apply to
#x       the chassis connection performed in ::<namespace>::connect procedure by IxTclHal. </p>
#x   -enable_win_tcl_server
#x       Enables running entire HLT API commands on Tcl Server's
#x       machine. Valid only on Windows platforms.
#x   -guard_rail
#x       This parameter will protect the application from exceeding the memory limits and
#x       by limiting the maximum number of views and statistics provided to the user.
#x   -protocol_stacking_mode
#x       This parameter enables the parallel/sequential start/stop of protocol layers when multiple protocols
#x       are stacked together.
#x   -interactive
#x       This argument is used to specify whether the console in which the
#x       script is run will work in the interactive mode or not.
#x   -ixnetwork_tcl_server
#x       IP address or name of the IxNetwork TCL server, followed optionally by
#x       :<port number>.
#x       <p> When using IxTclProtocol (old API), this parameter is ignored on both
#x       Windows and Unix platforms. </p>
#x       <p> When using IxTclNetwork (new API), on Windows platform, if
#x       both ixnetwork_tcl_server and tcl_server are not specified, the
#x       default value for ixnetwork_tcl_server is 127.0.0.1:8009. </p>
#x       <p> Otherwise, if tcl_server option is present and in use, the default
#x       value is equal to tcl_server:8009. </p>
#x       <p> When using IxTclNetwork (new API), on Unix platform, if
#x       ixnetwork_tcl_server is not specified, the default value is equal to
#x       tcl_server:8009. This means that, on Unix, if ixnetwork_tcl_server is
#x       not specified, then tcl_server must be specified. </p>
#x   -ixnetwork_license_servers
#x       If set this will set the central license server from where you can request a license.
#x       Any computer where Ixia Licensing Utility is installed can act as a License Server. Multiple servers can be provided as a list.
#x   -ixnetwork_license_type
#x       Valid if ixnetwork_license_servers argument is used. This argument is used to specify which type of license is used.
#x   -logging
#x       This parameter enables logging HLTAPI commands.
#x   -log_path
#x       Sets the path for hltapi logs, when parameter -logging is used.
#x   -ixnetwork_tcl_proxy
#x       The presence of this flag loads the IxTclNetworkConnector package and
#x       enables connection to the IxNetwork TCL Proxy Server. This parameter is
#x       valid only when using IxTclNetwork (new API).The address for
#x       the TCL proxy will be the value specified by the ixnetwork_tcl_server
#x       parameter.
#x   -master_device
#x       IP address or name of the master chassis, if -device is a slave chassis.
#x       May contain a list of devices. In this case, the string "none" can be
#x       added when the master chassis IP is not applicable.
#x   -chain_sequence
#x       SequenceID for chassis chain. Only valid for slave chassis when master_device parameter is used.
#x       For more info please consult Ixia chassis chaining user guide from IxOS or IxNetwork products.
#x   -chain_cables_length
#x       Cable length in ft used for the chassis chain. This can be a value of a list of values for each slave chassis.
#x       Valid values are: '0' (not applicabale), '3' (3 ft) or '6' (6 ft). Only valid for slave chassis when master_device parameter is used. If not specified it will default to 3 for each slave chassis.
#x   -chain_type
#x       This optional parameter specifices the chassis chain type used by IxNetwork.
#    -reset
#        Resets the card to factory defaults.
#        <p> When IxTclNetwork is used, the presence of this flag will reset all
#        previous connections to chassis and ports. If this flag is missing and this
#        is the first connect call from the script, the configuration will be imported from
#        the IxNetwork Tcl Server and will be returned as keyed list (see Return Values section). </p>
#x   -session_resume_keys
#x       Using this parameter when loading an ixncfg file allows you to choose
#x       whether to show the session resume keys or not. This parameter is valid only
#x       when using IxTclNetwork. If global parameter ::<namespace>::session_resume_keys does not
#x       exist, it will be overwritten by ::<namespace>::connect local parameter -session_resume_keys.
#x       Valid choices are:
#x   -session_resume_include_filter
#x       May contains a list of value that specify an inclusion filter for the returned session resume
#x       dictionary keys when -session_resume_keys is 1. The keys that have items in <typepath> are dependent on
#x       the command that generated that kind of typepath. Generally the procedure that generated those objects has
#x       the same name as the first part in the key.
#x       <p> Eg. in emulation_bgp_route_config.bgp_sites.<vport/protocols/bgp/neighborRange/l2Site> objects of type
#x       vport/protocols/bgp/neighborRange/l2Site are generated by the emulation_bgp_route_config command. </p>
#x       <p> Valid values are: </p>
#x       <ul>
#x       <li> connect</li>
#x       <li> connect.vport_list </li>
#x       <li> interface_config </li>
#x       <li> interface_config.interface_handle </li>
#x       <li> interface_config.routed_interface_handle </li>
#x       <li> interface_config.gre_interface_handle </li>
#x       <li> interface_config.atm_endpoints </li>
#x       <li> interface_config.fr_endpoints </li>
#x       <li> interface_config.ip_endpoints </li>
#x       <li> interface_config.lan_endpoints </li>
#x       <li> interface_config.ig_endpoints</li>
#x       <li> emulation_bfd_config </li>
#x       <li> emulation_bfd_config.router_handles </li>
#x       <li> emulation_bfd_config.router_interface_handles </li>
#x       <li> emulation_bfd_config.router_interface_handles.<vport/protocols/bfd/router </li>
#x       <li> emulation_bfd_config.interface_handles </li>
#x       <li> emulation_bfd_config.interface_handles.<vport/protocols/bfd/router> </li>
#x       <li> emulation_bfd_session_config.session_handles </li>
#x       <li> emulation_bgp_config </li>
#x       <li> emulation_bgp_config.handles </li>
#x       <li> emulation_bgp_route_config </li>
#x       <li> emulation_bgp_route_config.bgp_routes </li>
#x       <li> emulation_bgp_route_config.bgp_sites </li>
#x       <li> emulation_bgp_route_config.bgp_sites.<vport/protocols/bgp/neighborRange/l2Site> </li>
#x       <li> emulation_bgp_route_config.bgp_sites.<vport/protocols/bgp/neighborRange/l3Site> </li>
#x       <li> emulation_cfm_config </li>
#x       <li> emulation_cfm_config.handle </li>
#x       <li> emulation_cfm_config.interface_handles </li>
#x       <li> emulation_cfm_custom_tlv_config </li>
#x       <li> emulation_cfm_custom_tlv_config.handle </li>
#x       <li> emulation_cfm_links_config </li>
#x       <li> emulation_cfm_links_config.handle </li>
#x       <li> emulation_cfm_md_meg_config </li>
#x       <li> emulation_cfm_md_meg_config.handle </li>
#x       <li> emulation_cfm_mip_mep_config </li>
#x       <li> emulation_cfm_mip_mep_config.handle </li>
#x       <li> emulation_cfm_vlan_config </li>
#x       <li> emulation_cfm_vlan_config.handle </li>
#x       <li> emulation_cfm_vlan_config.mac_range_handles </li>
#x       <li> emulation_cfm_vlan_config.mac_range_handles.<vport/protocols/cfm/bridge/vlans> </li>
#x       <li> emulation_dhcp_config </li>
#x       <li> emulation_dhcp_config.handle </li>
#x       <li> emulation_dhcp_group_config </li>
#x       <li> emulation_dhcp_group_config.handle </li>
#x       <li> emulation_dhcp_server_config </li>
#x       <li> emulation_dhcp_server_config.handle </li>
#x       <li> emulation_dhcp_server_config.handle </li>
#x       <li> dhcp_client_extension_config </li>
#x       <li> dhcp_client_extension_config.handle </li>
#x       <li> dhcp_server_extension_config </li>
#x       <li> dhcp_server_extension_config.handle </li>
#x       <li> emulation_efm_config </li>
#x       <li> emulation_efm_config.information_oampdu_id </li>
#x       <li> emulation_efm_config.event_notification_oampdu_id </li>
#x       <li> emulation_efm_org_var_config </li>
#x       <li> emulation_efm_org_var_config.handle </li>
#x       <li> emulation_eigrp_config </li>
#x       <li> emulation_eigrp_config.router_handles </li>
#x       <li> emulation_eigrp_config.interface_handles </li>
#x       <li> emulation_eigrp_route_config </li>
#x       <li> emulation_eigrp_route_config.session_handles </li>
#x       <li> emulation_igmp_config </li>
#x       <li> emulation_igmp_config.handle </li>
#x       <li> emulation_igmp_group_config </li>
#x       <li> emulation_igmp_group_config.handle </li>
#x       <li> emulation_igmp_group_config.source_handle </li>
#x       <li> emulation_igmp_group_config.group_pool_handle </li>
#x       <li> emulation_igmp_group_config.source_pool_handle </li>
#x       <li> emulation_isis_config </li>
#x       <li> emulation_isis_config.handle </li>
#x       <li> emulation_isis_topology_route_config </li>
#x       <li> emulation_isis_topology_route_config.elem_handle </li>
#x       <li> emulation_isis_topology_route_config.stub </li>
#x       <li> emulation_isis_topology_route_config.external </li>
#x       <li> emulation_isis_topology_route_config.grid </li>
#x       <li> emulation_isis_topology_route_config.grid.connected_session.<vport/protocols/isis/router>.row </li>
#x       <li> emulation_isis_topology_route_config.grid.connected_session.<vport/protocols/isis/router>.col </li>
#x       <li> l2tp_config </li>
#x       <li> l2tp_config.handles </li>
#x       <li> emulation_lacp_link_config </li>
#x       <li> emulation_lacp_link_config.handle </li>
#x       <li> emulation_ldp_config </li>
#x       <li> emulation_ldp_config.handle </li>
#x       <li> emulation_ldp_route_config </li>
#x       <li> emulation_ldp_route_config.lsp_handle </li>
#x       <li> emulation_ldp_route_config.lsp_intf </li>
#x       <li> emulation_ldp_route_config.lsp_vc_range_handles </li>
#x       <li> emulation_ldp_route_config.lsp_vc_ip_range_handles </li>
#x       <li> emulation_ldp_route_config.lsp_vc_mac_range_handles </li>
#x       <li> emulation_mld_config </li>
#x       <li> emulation_mld_config.handle </li>
#x       <li> emulation_mld_group_config </li>
#x       <li> emulation_mld_group_config.handle </li>
#x       <li> emulation_mld_group_config.group_pool_handle </li>
#x       <li> emulation_mld_group_config.source_pool_handles </li>
#x       <li> emulation_oam_config_msg </li>
#x       <li> emulation_oam_config_msg.handle </li>
#x       <li> emulation_oam_config_topology </li>
#x       <li> emulation_oam_config_topology.handle </li>
#x       <li> emulation_oam_config_topology.traffic_handles </li>
#x       <li> emulation_ospf_config </li>
#x       <li> emulation_ospf_config.handle </li>
#x       <li> emulation_ospf_topology_route_config </li>
#x       <li> emulation_ospf_topology_route_config.elem_handle </li>
#x       <li> emulation_pbb_config </li>
#x       <li> emulation_pbb_config.handle </li>
#x       <li> emulation_pbb_config.interface_handles </li>
#x       <li> emulation_pbb_trunk_config </li>
#x       <li> emulation_pbb_trunk_config.trunk_handle </li>
#x       <li> emulation_pbb_trunk_config.mr_handle </li>
#x       <li> emulation_pim_config </li>
#x       <li> emulation_pim_config.handle </li>
#x       <li> emulation_pim_config.interfaces </li>
#x       <li> emulation_pim_group_config </li>
#x       <li> emulation_pim_group_config.handle </li>
#x       <li> emulation_pim_group_config.group_pool_handle </li>
#x       <li> emulation_pim_group_config.source_pool_handles </li>
#x       <li> pppox_config </li>
#x       <li> pppox_config.handles </li>
#x       <li> emulation_rip_config </li>
#x       <li> emulation_rip_config.handle </li>
#x       <li> emulation_rip_route_config </li>
#x       <li> emulation_rip_route_config.route_handle </li>
#x       <li> emulation_rsvp_config </li>
#x       <li> emulation_rsvp_config.handles </li>
#x       <li> emulation_rsvp_config.router_interface_handle </li>
#x       <li> emulation_rsvp_tunnel_config </li>
#x       <li> emulation_rsvp_tunnel_config.tunnel_handle </li>
#x       <li> emulation_rsvp_tunnel_config.tunnel_leaves_handle </li>
#x       <li> emulation_rsvp_tunnel_config.tunnel_leaves_handle.<vport/protocols/rsvp/neighborPair/destinationRange> </li>
#x       <li> emulation_rsvp_tunnel_config.tunnel_leaves_handle.<vport/protocols/rsvp/neighborPair/destinationRange>/ingress </li>
#x       <li> emulation_rsvp_tunnel_config.routed_interfaces </li>
#x       <li> emulation_stp_msti_config </li>
#x       <li> emulation_stp_msti_config.handle </li>
#x       <li> emulation_stp_bridge_config </li>
#x       <li> emulation_stp_bridge_config.bridge_handle </li>
#x       <li> emulation_stp_bridge_config.bridge_interface_handles </li>
#x       <li> emulation_stp_bridge_config.bridge_interface_handles.<vport/protocols/stp/bridge> </li>
#x       <li> emulation_stp_bridge_config.interface_handles </li>
#x       <li> emulation_stp_bridge_config.interface_handles.<vport/protocols/stp/bridge> </li>
#x       <li> emulation_twamp_config </li>
#x       <li> emulation_twamp_config.handle </li>
#x       <li> emulation_twamp_control_range_config </li>
#x       <li> emulation_twamp_control_range_config.handle </li>
#x       <li> emulation_twamp_test_range_config </li>
#x       <li> emulation_twamp_test_range_config.handle </li>
#x       <li> emulation_twamp_server_range_config </li>
#x       <li> emulation_twamp_server_range_config.handle </li>
#x       <li> emulation_ancp_config </li>
#x       <li> emulation_ancp_config.handle </li>
#x       <li> emulation_ancp_subscriber_lines_config </li>
#x       <li> emulation_ancp_subscriber_lines_config.handle </li>
#x       <li> fc_client_config </li>
#x       <li> fc_client_config.handle </li>
#x       <li> fc_fport_config </li>
#x       <li> fc_fport_config.handle </li>
#x       <li> fc_fport_vnport_config </li>
#x       <li> fc_fport_vnport_config.handle </li>
#x       <li> traffic_config </li>
#x       <li> traffic_config.stream_id </li>
#x       <li> traffic_config.traffic_item </li>
#x       <li> emulation_multicast_group_config </li>
#x       <li> emulation_multicast_source_config </li>
#x       </ul>
#    -sync
#        If enabled, the ixClearTimeStamps routine is called for the
#        reserved port list.
#    -tcl_proxy_username
#        Username for logging in IxNetwork Tcl Proxy server.
#        <p> This parameter is ignored when IxNetwork Tcl Proxy server is not used for connecting
#        to IxNetwork. In this case, the username will be configured
#        automatically at ::<namespace>::interface_config and will have the value
#        'IxNetwork/$(COMPUTERNAME)/$(USERNAME)'. </p>
#        <p> However, when connecting to an IxNetwork Tcl Proxy Server this parameter is used
#        to determine the username of the IxNetwork instance to which the Proxy Server
#        will connect to. </p>
#x   -tcl_server
#x       IP address or name of the ixTclServer.
#x       When using IxTclProtocol (old API), this parameter is ignored on
#x       Windows platforms. On Unix platforms, the default value is the
#x       first item in option "device" list.
#x       <p> When using IxTclNetwork (new API) on Windows platform, if
#x       both tcl_server and ixnetwork_tcl_server
#x       are not specified, the default value is 127.0.0.1. If
#x       ixnetwork_tcl_server is present, the default value is equal to
#x       ixnetwork_tcl_server and if this fails it will fallback to the value
#x       of the first item in option "device" list.
#x       When using IxTclNetwork (new API) on Unix platform, if
#x       tcl_server is not specified, the default value is equal to
#x       ixnetwork_tcl_server. This means that, on Unix, if tcl_server is
#x       not specified, then ixnetwork_tcl_server must be specified. </p>
#    -username
#        Username for logging on to the chassis.
#        <p> This parameter is ignored when using IxTclNetwork (new API). In this case,
#        the username will be configured automatically at ::<namespace>::interface_config
#        and will have the value 'IxNetwork/$(COMPUTERNAME)/$(USERNAME)'. </p>
#x   -mode
#x       This parameter depends on 'vport_list' and 'vport_count' parameters. More details
#x       are available in the description for parameter 'device'.
#x       This parameter is valid only when IxNetwork Tcl API is used.
#x   -vport_count
#x       More details are available in the description for parameter 'device'.
#x       This parameter is valid only when IxNetwork Tcl API is used and it configures
#x       the number of virtual ports to be created. When this parameter is specified
#x       the parameters 'device' , 'port_list', 'vport_list', 'mode' are ignored. The
#x       virtual port handles created are returned with 'vport_handle' key.
#x   -vport_list
#x       More details are available in the description for parameter 'device'.
#x       This parameter is valid only when IxNetwork Tcl API is used. When parameter
#x       'mode' is 'disconnect', the virtual ports specified will be disconnected from
#x       the real ports they are connected to. Parameters 'device' and 'port_list' are
#x       ignored. When parameter 'mode' is 'connect' parameters 'device' and 'port_list'
#x       are mandatory. The virtual ports specified with 'vport_list' will be connected
#x       to the real ports specified with 'port_list' and 'device'.
#x   -execution_timeout
#x       This is the timeout for each individual HLT command. Applies to all HLT commands.
#x       The setting is in seconds.
#x       Setting this setting to 60 it will mean that each command (ex: interface_config) must complete in under 60 seconds.
#x       If the command will last more than 60 seconds the command will be terminated by force.
#x       This flag can be used to guard against dead locks occurring in IxNetwork.
#x       Default is 0, meaning no execution timeout.
#x   -return_detailed_handles
#x       This argument determines if individual interface, session or router handles are returned by ixiangpf commands.
#x       This applies to all HLT commands from the current session.
#x       Setting this to 0 means that only NGPF-specific protocol stack handles will be returned. This will significantly
#x       decrease the size of command results and speed up script execution. Individual item handles can still be retrieved
#x       using the protocol_info command with -mode handles.
#x       The default is 1, meaning all possible handles will be returned.
#n   -timeout
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -nobios
#n       This argument defined by Cisco is not supported for NGPF implementation.
#n   -forceload
#n       This argument defined by Cisco is not supported for NGPF implementation.
#
# Return Values:
#    $::SUCCESS | $::FAILURE
#    key:status                                                value:$::SUCCESS | $::FAILURE
#    On status of failure, gives detailed information.
#    key:log                                                   value:On status of failure, gives detailed information.
#    Port in the form of c/l/p.
#    key:port_handle.$device.$port                             value:Port in the form of c/l/p.
#    List of virtual port handles.
#    key:vport_list                                            value:List of virtual port handles.
#    keyed list with the following keys "vport_list"
#    key:$port_handle.connect                                  value:keyed list with the following keys "vport_list"
#    keyed list with the following keys "router_handles router_interface_handles.__parent interface_handles.__parent"
#    key:$port_handle.emulation_bfd_config                     value:keyed list with the following keys "router_handles router_interface_handles.__parent interface_handles.__parent"
#    keyed list with the following keys "session_handles"
#    key:$port_handle.emulation_bfd_session_config             value:keyed list with the following keys "session_handles"
#    keyed list with the following keys "handles"
#    key:$port_handle.emulation_bgp_config                     value:keyed list with the following keys "handles"
#    keyed list with the following keys "bgp_routes bgp_sites.__parent bgp_sites.__parent"
#    key:$port_handle.emulation_bgp_route_config               value:keyed list with the following keys "bgp_routes bgp_sites.__parent bgp_sites.__parent"
#    keyed list with the following keys "handle interface_handles"
#    key:$port_handle.emulation_cfm_config                     value:keyed list with the following keys "handle interface_handles"
#    keyed list with the following keys "handle"
#    key:$port_handle.emulation_cfm_custom_tlv_config          value:keyed list with the following keys "handle"
#    keyed list with the following keys "handle"
#    key:$port_handle.emulation_cfm_links_config               value:keyed list with the following keys "handle"
#    keyed list with the following keys "handle"
#    key:$port_handle.emulation_cfm_md_meg_config              value:keyed list with the following keys "handle"
#    keyed list with the following keys "handle"
#    key:$port_handle.emulation_cfm_mip_mep_config             value:keyed list with the following keys "handle"
#    keyed list with the following keys "handle mac_range_handles.__parent"
#    key:$port_handle.emulation_cfm_vlan_config                value:keyed list with the following keys "handle mac_range_handles.__parent"
#    keyed list with the following keys "handle"
#    key:$port_handle.emulation_dhcp_config                    value:keyed list with the following keys "handle"
#    keyed list with the following keys "handle"
#    key:$port_handle.emulation_dhcp_group_config              value:keyed list with the following keys "handle"
#    keyed list with the following keys "handle handle.dhcp_handle"
#    key:$port_handle.emulation_dhcp_server_config             value:keyed list with the following keys "handle handle.dhcp_handle"
#    keyed list with the following keys "information_oampdu_id event_notification_oampdu_id"
#    key:$port_handle.emulation_efm_config                     value:keyed list with the following keys "information_oampdu_id event_notification_oampdu_id"
#    keyed list with the following keys "handle"
#    key:$port_handle.emulation_efm_org_var_config             value:keyed list with the following keys "handle"
#    keyed list with the following keys "router_handles interface_handles __parent.connected_interface_handles __parent.gre_interface_handles"
#    key:$port_handle.emulation_eigrp_config                   value:keyed list with the following keys "router_handles interface_handles __parent.connected_interface_handles __parent.gre_interface_handles"
#    keyed list with the following keys "session_handles"
#    key:$port_handle.emulation_eigrp_route_config             value:keyed list with the following keys "session_handles"
#    keyed list with the following keys "handle"
#    key:$port_handle.emulation_igmp_config                    value:keyed list with the following keys "handle"
#    keyed list with the following keys "handle source_handle"
#    key:$port_handle.emulation_igmp_group_config              value:keyed list with the following keys "handle source_handle"
#    keyed list with the following keys "handle"
#    key:$port_handle.emulation_isis_config                    value:keyed list with the following keys "handle"
#    keyed list with the following keys "elem_handle version route_range stub.num_networks external.num_networks grid.connected_session__parent.row grid.connected_session__parent.col grid.connected_session.__parent.row grid.connected_session.__parent.col"
#    key:$port_handle.emulation_isis_topology_route_config     value:keyed list with the following keys "elem_handle version route_range stub.num_networks external.num_networks grid.connected_session__parent.row grid.connected_session__parent.col grid.connected_session.__parent.row grid.connected_session.__parent.col"
#    keyed list with the following keys "handle"
#    key:$port_handle.emulation_lacp_link_config               value:keyed list with the following keys "handle"
#    keyed list with the following keys "handle"
#    key:$port_handle.emulation_ldp_config                     value:keyed list with the following keys "handle"
#    keyed list with the following keys "lsp_handle lsp_intf lsp_vc_range_handles lsp_vc_ip_range_handles lsp_vc_mac_range_handles"
#    key:$port_handle.emulation_ldp_route_config               value:keyed list with the following keys "lsp_handle lsp_intf lsp_vc_range_handles lsp_vc_ip_range_handles lsp_vc_mac_range_handles"
#    keyed list with the following keys "handle"
#    key:$port_handle.emulation_mld_config                     value:keyed list with the following keys "handle"
#    keyed list with the following keys "handle group_pool_handle source_pool_handles"
#    key:$port_handle.emulation_mld_group_config               value:keyed list with the following keys "handle group_pool_handle source_pool_handles"
#    keyed list with the following keys "handle"
#    key:$port_handle.emulation_oam_config_msg                 value:keyed list with the following keys "handle"
#    keyed list with the following keys "handle traffic_handles"
#    key:$port_handle.emulation_oam_config_topology            value:keyed list with the following keys "handle traffic_handles"
#    keyed list with the following keys "handle"
#    key:$port_handle.emulation_ospf_config                    value:keyed list with the following keys "handle"
#    keyed list with the following keys "elem_handle"
#    key:$port_handle.emulation_ospf_topology_route_config     value:keyed list with the following keys "elem_handle"
#    keyed list with the following keys "handle interface_handles"
#    key:$port_handle.emulation_pbb_config                     value:keyed list with the following keys "handle interface_handles"
#    keyed list with the following keys "trunk_handle mr_handle"
#    key:$port_handle.emulation_pbb_trunk_config               value:keyed list with the following keys "trunk_handle mr_handle"
#    keyed list with the following keys "handle interfaces"
#    key:$port_handle.emulation_pim_config                     value:keyed list with the following keys "handle interfaces"
#    keyed list with the following keys "handle group_pool_handle source_pool_handles"
#    key:$port_handle.emulation_pim_group_config               value:keyed list with the following keys "handle group_pool_handle source_pool_handles"
#    keyed list with the following keys "handle handle"
#    key:$port_handle.emulation_rip_config                     value:keyed list with the following keys "handle handle"
#    keyed list with the following keys "route_handle"
#    key:$port_handle.emulation_rip_route_config               value:keyed list with the following keys "route_handle"
#    keyed list with the following keys "handles router_interface_handle.__parent"
#    key:$port_handle.emulation_rsvp_config                    value:keyed list with the following keys "handles router_interface_handle.__parent"
#    keyed list with the following keys "tunnel_handle tunnel_leaves_handle.__parent/ingress routed_interfaces.__parent/ingress tunnel_leaves_handle.__parent"
#    key:$port_handle.emulation_rsvp_tunnel_config             value:keyed list with the following keys "tunnel_handle tunnel_leaves_handle.__parent/ingress routed_interfaces.__parent/ingress tunnel_leaves_handle.__parent"
#    keyed list with the following keys "bridge_handle bridge_interface_handles.__parent interface_handles.__parent"
#    key:$port_handle.emulation_stp_bridge_config              value:keyed list with the following keys "bridge_handle bridge_interface_handles.__parent interface_handles.__parent"
#    keyed list with the following keys "handle"
#    key:$port_handle.emulation_stp_msti_config                value:keyed list with the following keys "handle"
#    keyed list with the following keys "interface_handle routed_interface_handle gre_interface_handle"
#    key:$port_handle.interface_config                         value:keyed list with the following keys "interface_handle routed_interface_handle gre_interface_handle"
#    keyed list with the following keys "handles"
#    key:$port_handle.l2tp_config                              value:keyed list with the following keys "handles"
#    keyed list with the following keys "handles"
#    key:$port_handle.pppox_config                             value:keyed list with the following keys "handles"
#    keyed list with the following keys "handle"
#    key:$port_handle.emulation_twamp_config                   value:keyed list with the following keys "handle"
#    keyed list with the following keys "handle"
#    key:$port_handle.emulation_twamp_control_range_config     value:keyed list with the following keys "handle"
#    keyed list with the following keys "handle"
#    key:$port_handle.emulation_twamp_test_range_config        value:keyed list with the following keys "handle"
#    keyed list with the following keys "handle"
#    key:$port_handle.emulation_twamp_server_range_config      value:keyed list with the following keys "handle"
#    keyed list with the following keys "handle"
#    key:$port_handle.emulation_ancp_config                    value:keyed list with the following keys "handle"
#    keyed list with the following keys "handle"
#    key:$port_handle.emulation_ancp_subscriber_lines_config   value:keyed list with the following keys "handle"
#    keyed list with the following keys "handle"
#    key:$port_handle.fc_client_config                         value:keyed list with the following keys "handle"
#    keyed list with the following keys "handle"
#    key:$port_handle.fc_fport_config                          value:keyed list with the following keys "handle"
#    keyed list with the following keys "handle"
#    key:$port_handle.fc_fport_vnport_config                   value:keyed list with the following keys "handle"
#    a list having as elements the names of the existing traffic items (the name of the traffic item is normally returned when traffic_config creates a new traffic item by the stream_id key)
#    key:traffic_config                                        value:a list having as elements the names of the existing traffic items (the name of the traffic item is normally returned when traffic_config creates a new traffic item by the stream_id key)
#    keyed list with all the keys that the traffic_config procedure would return when configuring the $stream_id traffic item
#    key:$stream_id.traffic_config                             value:keyed list with all the keys that the traffic_config procedure would return when configuring the $stream_id traffic item
#    keyed list containing the vport protocols handle
#    key:vport_protocols_handle                                value:keyed list containing the vport protocols handle
#    The IxNetwork version found on client
#    key:connection.client_version                             value:The IxNetwork version found on client
#    The hostname of the chassis
#    key:connection.chassis.$device.hostname                   value:The hostname of the chassis
#    The ip address of the chassis
#    key:connection.chassis.$device.ip                         value:The ip address of the chassis
#    The IxNetwork Protocols version found on the chassis
#    key:connection.chassis.$device.chassis_protocols_version  value:The IxNetwork Protocols version found on the chassis
#    The type of the chassis
#    key:connection.chassis.$device.chassis_type               value:The type of the chassis
#    The IxOS version found on the chassis
#    key:connection.chassis.$device.chassis_version            value:The IxOS version found on the chassis
#
# Examples:
#
# Sample Input:
#
# Sample Output:
#
# Notes:
#    1. Coded versus functional specification.
#    2. Once a vport_handle or port_handle is returned, the handle will not change if the
#    virtual port is disconnected and connected to another real port.
#    Example1: '::<namespace>::connect -device X -port_list 1/1'. This call returns the port handle 0/1/1
#    and virtual port handle 0/1/1.
#    '::<namespace>::connect -device Y -port_list 2/1 -vport_list 0/1/1 -mode connect'. This call returns
#    the port_handle 0/1/1 and virtual port handle 0/1/1.
#    Conclusion: even if the device and real port has changed, the port handle hasn't changed.
#    Example2: '::<namespace>::connect -vport_count 1'. This call does not return a port handle but it returns
#    the virtual port handle '0/0/1'.
#    '::<namespace>::connect -device X -port_list 4/2 -vport_list 0/0/1'. This call returns port handle 0/0/1
#    and virtual port handle 0/0/1.
#    3. Session resume will be done only for the first ::<namespace>::connect call from the script. Subsequent
#    calls will not perform session resume, even if -reset flag is not specified
#    4. Available only for *NO HLTSET
#    5. Only when HLT commands are executed locally (not sent to tclServer)
#    6. The following protocols cannot be restored when the configuration is autodetected by
#    HLT (not loaded from an config_file_hlt file)
#    6.1 OAM - configurations done with emulation_oam_* procedures
#    6.2 Multicast sources and group handles will not be available anymore. They need to be recreated
#    6.3 Autogenerated protocols cannot be restored: DCBX, FcOE, FCF, ESMC (ESync)
#    7. Port handles that were "shuffled" are not supported (e.g. port 0/2/1 is disconnected and reconnected to
#    0/2/2; or vport 0/0/1 is created, then connected to 0/3/1). Port handle for ports that are connected
#    will be $ch/$ca/$po. Port handles for unconnected ports will be 0/0/$vport_item (e.g. the third
#    virtual port that is not connected will have handle 0/0/2)
#
# See Also:
#

