#
# ixiahlt.pm
#
use Tcl;
use File::Spec;
use File::Basename;
use warnings;
use strict;
use Carp;
use ixiatcl;

package ixiahlt;
sub import() {
    if (defined($ixiahlt::initialized)) {
        return 1;
    }

    # $_[0] is first word after use (e.g. ixiahlt)
    # next "argument" is assumed to be a hash reference
    # with various optional directives for the use / import process
    my $use_ixnetworktclconnector = 0;
    my $hlp_return_on_failure = 0;
    if (@_ > 1) {
        my %opts = %{$_[1]}; 
        # Syntax use ixiahlt {IXIA_VERSION => 'HLTSET99'};
        # Note: if the environment has an IXIA_VERSION 
        # it overrides anything provided in the use statement
        #
        if ($ENV{IXIA_VERSION}) {
            # environment has an IXIA_VERSION 
            # it overrides anything provided in use stmt
        } else {
            if (exists $opts{IXIA_VERSION}) {
                ixiatcl::set('::env(IXIA_VERSION)', $opts{IXIA_VERSION});
            }
        }
        # Syntax:
        # use ixiahlt {IxTclNetworkConnector => 1};
        # use ixiahlt {IxTclNetworkConnector => 0};
        #
        if (exists $opts{IxTclNetworkConnector}) {
            if ($opts{IxTclNetworkConnector}) {
                $use_ixnetworktclconnector = 1;
            }
        }
        # Syntax:
        # use ixiahlt {TclAutoPath => ['c:/tcl/libA', 'c:/tcl/libB']};
        #
        if (exists $opts{TclAutoPath}) {
            my @ap_list = @{$opts{TclAutoPath}};
            foreach my $ap (@ap_list) {
                ixiatcl::lappend('::auto_path', $ap);
            }
            undef @ap_list;
        }
        
        if (exists $opts{hlpReturnOnFailure}) {
            if ($opts{hlpReturnOnFailure}) {
                $hlp_return_on_failure = 1;
            }
        }
    }

    #-----
    # Make a few dummy commands related to the tk that the hlt_init.tcl file
    # tries to use to hide/show windows etc..
    ixiatcl::_xinvoke("proc", "console", 'args', '');
    ixiatcl::_xinvoke("proc", "wm", 'args', '');
    #-----

    #-----
    # Load Ixia tcl pkg
    #
    my $a_dir = File::Spec->rel2abs(File::Basename::dirname(__FILE__));
    $a_dir = File::Basename::dirname($a_dir);
    $a_dir = File::Basename::dirname($a_dir);
    $a_dir = File::Basename::dirname($a_dir);
    ixiatcl::lappend('::auto_path', $a_dir);
    $a_dir = File::Basename::dirname($a_dir);
    ixiatcl::lappend('::auto_path', $a_dir);

    if (ixiatcl::is_windows()) {
        if ($ENV{IXIA_PM_DEV}) {
            print("!! IXIA_PM_DEV is enabled !!\n");
            ixiatcl::_xeval(
            'source [set _fn [lindex [glob {c:/Program Files/Ixia/hltapi/*.*/TclScripts/bin/hlt_init.tcl}] end]]; puts stdout "!! using $_fn ... !!"'
            );
        } else {
            $a_dir = File::Basename::dirname($a_dir);
            ixiatcl::source($a_dir . "\\bin\\" . 'hlt_init.tcl');
        }
    } else {
        ixiatcl::_xeval('package require Ixia');
    }
    #-----

    #
    # HLT/HAG specific stuff
    #
    ixiatcl::_xeval('namespace eval ::ixia {}');
    ixiatcl::_xeval('namespace eval ::ixia::hag {}');
    ixiatcl::_xeval('namespace eval ::ixia::hag::ixn {}');

    # util used by other bindings in this file
    ixiatcl::_xeval(
        '
        proc ::KLVGET {k} {
            keylget ::KLV $k
        }
        proc ::KLVKEYS {args} {
            set cmd [linsert $args 0 keylkeys ::KLV]
            ##puts stderr CMD>>>$cmd
            ##puts stderr KEYS>>[keylkeys ::KLV]
            eval $cmd
        }
        '
    );

    #
    # Some other random hlt utils..
    #
    sub increment_ipv4_address { 
        ixiatcl::_xinvoke("::ixia::increment_ipv4_address", @_);
    };
    sub increment_ipv6_address { 
        ixiatcl::_xinvoke("::ixia::increment_ipv6_address", @_);
    };
    sub get_port_list_from_connect { 
        ixiatcl::_xinvoke("::ixia::get_port_list_from_connect", @_);
    };
    

    #
    # Make a set of bindings for (classic) hlt
    # Every new command should be added like this: ["hlt_command", "status", "log", "status"]
    my @cmd_spec_list = (
       
        ["connect", "status", "log", "status"],
        ["device_info", "status", "log", "status"],
        ["vport_info", "status", "log", "status"],
        ["capture_packets", "status", "log", "status"],
        ["get_packet_content", "status", "log", "status"],
                
        ["interface_config", "status", "log", "status"],
        ["interface_control", "status", "log", "status"],
        ["interface_stats", "status", "log", "status"],
        
        ["traffic_config", "status", "log", "status"],
        ["traffic_control", "status", "log", "status"],
        ["traffic_stats", "status", "log", "*"],
        
        ["emulation_bgp_config", "status", "log", "handles"],
        ["emulation_bgp_info", "status", "log", "*"],
        ["emulation_bgp_route_config", "status", "log", "bgp_routes"],
        ["emulation_bgp_control", "status", "log", "*"],

        ["emulation_cfm_config", "status", "log", "status"],
        ["emulation_cfm_info", "status", "log", "status"],
        ["emulation_cfm_md_meg_config", "status", "log", "status"],
        ["emulation_cfm_mip_mep_config", "status", "log", "status"],
        ["emulation_cfm_custom_tlv_config", "status", "log", "status"],
        ["emulation_cfm_vlan_config", "status", "log", "status"],
        ["emulation_cfm_links_config", "status", "log", "status"],
        ["emulation_cfm_control", "status", "log", "status"],
        
        ["emulation_elmi_control", "status", "log", "status"],
        ["emulation_elmi_info", "status", "log", "status"],

        ["emulation_ospf_config", "status", "log", "handle"],
        ["emulation_ospf_topology_route_config", "status", "log", "*"],
        ["emulation_ospf_lsa_config", "status", "log", "*"],
        ["emulation_ospf_control", "status", "log", "*"],
        ["emulation_ospf_info", "status", "log", "*"],
            
        ["emulation_ldp_config", "status", "log", "handle"],
        ["emulation_ldp_route_config", "status", "log", "*"],
        ["emulation_ldp_control", "status", "log", "*"],
        ["emulation_ldp_info", "status", "log", "*"],
            
        ["emulation_rsvp_config", "status", "log", "handles"],
        ["emulation_rsvp_tunnel_config", "status", "log", "*"],
        ["emulation_rsvp_control", "status", "log", "*"],
        ["emulation_rsvp_info", "status", "log", "*"],
        ["emulation_rsvp_tunnel_info", "status", "log", "*"],
            
        ["emulation_igmp_config", "status", "log", "handle"],
        ["emulation_igmp_group_config", "status", "log", "*"],
        ["emulation_igmp_querier_config", "status", "log", "status"],
        ["emulation_igmp_control", "status", "log", "*"],
        ["emulation_igmp_info", "status", "log", "*"],
        
        ["emulation_isis_config", "status", "log", "handle"],
        ["emulation_isis_topology_route_config", "status", "log", "*"],
        ["emulation_isis_control", "status", "log", "*"],
        ["emulation_isis_info", "status", "log", "*"],

        ["emulation_rip_config", "status", "log", "handle"],
        ["emulation_rip_route_config", "status", "log", "*"],
        ["emulation_rip_control", "status", "log", "*"],
        
        ["emulation_dhcp_config", "status", "log", "handle"],
        ["emulation_dhcp_group_config", "status", "log", "handle"],
        ["emulation_dhcp_control", "status", "log", "*"],
        ["emulation_dhcp_stats", "status", "log", "*"],
        
        ["dhcp_client_extension_config", "status", "log", "status"],
        ["dhcp_server_extension_config", "status", "log", "status"],
        ["dhcp_extension_stats", "status", "log", "status"],
        
        ["emulation_dhcp_server_config", "status", "log", "handle"],
        ["emulation_dhcp_server_control", "status", "log", "*"],
        ["emulation_dhcp_server_stats", "status", "log", "*"],
        
        ["emulation_eigrp_config", "status", "log", "router_handles"],
        ["emulation_eigrp_route_config", "status", "log", "*"],
        ["emulation_eigrp_control", "status", "log", "*"],
        ["emulation_eigrp_info", "status", "log", "*"],
        
        ["emulation_ftp_config", "status", "log", "status"],
        ["emulation_ftp_traffic_config", "status", "log", "status"],
        ["emulation_ftp_control", "status", "log", "status"],
        ["emulation_ftp_control_config", "status", "log", "status"],
        ["emulation_ftp_stats", "status", "log", "status"],
                
        ["emulation_http_config", "status", "log", "status"],
        ["emulation_http_traffic_config", "status", "log", "status"],
        ["emulation_http_traffic_type_config", "status", "log", "status"],
        ["emulation_http_control", "status", "log", "status"],
        ["emulation_http_stats", "status", "log", "status"],
        ["emulation_http_control_config", "status", "log", "status"],
                
        ["emulation_telnet_config", "status", "log", "status"],
        ["emulation_telnet_traffic_config", "status", "log", "status"],
        ["emulation_telnet_stats", "status", "log", "status"],
        ["emulation_telnet_control_config", "status", "log", "status"],
        ["emulation_telnet_control", "status", "log", "status"],
        
        ["emulation_bfd_config", "status", "log", "status"],
        ["emulation_bfd_session_config", "status", "log", "status"],
        ["emulation_bfd_control", "status", "log", "status"],
        ["emulation_bfd_info", "status", "log", "status"],
        
        ["emulation_efm_config", "status", "log", "status"],
        ["emulation_efm_control", "status", "log", "status"],
        ["emulation_efm_org_var_config", "status", "log", "status"],
        ["emulation_efm_stat", "status", "log", "status"],
        
        ["emulation_lacp_link_config", "status", "log", "status"],
        ["emulation_lacp_control", "status", "log", "status"],
        ["emulation_lacp_info", "status", "log", "status"],
        
        ["emulation_twamp_config", "status", "log", "status"],
        ["emulation_twamp_control_range_config", "status", "log", "status"],
        ["emulation_twamp_test_range_config", "status", "log", "status"],
        ["emulation_twamp_server_range_config", "status", "log", "status"],
        ["emulation_twamp_control", "status", "log", "status"],
        ["emulation_twamp_info", "status", "log", "status"],
        
        ["emulation_oam_config_topology", "status", "log", "status"],
        ["emulation_oam_config_msg", "status", "log", "status"],
        ["emulation_oam_control", "status", "log", "status"],
        ["emulation_oam_info", "status", "log", "status"],
        
        ["emulation_pbb_config", "status", "log", "status"],
        ["emulation_pbb_trunk_config", "status", "log", "status"],
        ["emulation_pbb_custom_tlv_config", "status", "log", "status"],
        ["emulation_pbb_info", "status", "log", "status"],
        ["emulation_pbb_control", "status", "log", "status"],
       
        ["emulation_mld_config", "status", "log", "handle"],
        ["emulation_mld_group_config", "status", "log", "*"],
        ["emulation_mld_control", "status", "log", "*"],
        ["emulation_multicast_group_config", "status", "log", "handle"],
        ["emulation_multicast_source_config", "status", "log", "handle"],
        
        ["fc_fport_options_config", "status", "log", "status"],
        ["fc_client_options_config", "status", "log", "status"],
        ["fc_fport_global_config", "status", "log", "status"],
        ["fc_client_global_config", "status", "log", "status"],
        ["fc_fport_stats", "status", "log", "status"],
        ["fc_client_stats", "status", "log", "status"],
        ["fc_control", "status", "log", "status"],
        ["fc_fport_vnport_config", "status", "log", "status"],
        ["fc_fport_config", "status", "log", "status"],
        ["fc_client_config", "status", "log", "status"],
        
        ["pppox_config", "status", "log", "handle"],
        ["pppox_control", "status", "log", "*"],
        ["pppox_stats", "status", "log", "*"],
        
        ["l2tp_config", "status", "log", "handle"],
        ["l2tp_control", "status", "log", "*"],
        ["l2tp_stats", "status", "log", "*"],

        ["emulation_ancp_config", "status", "log", "handle"],
        ["emulation_ancp_stats", "status", "log", "*"],
        ["emulation_ancp_control", "status", "log", "*"],
        ["emulation_ancp_subscriber_lines_config", "status", "log", "*"],
        
        ["emulation_pim_config", "status", "log", "handle"],
        ["emulation_pim_group_config", "status", "log", "*"],
        ["emulation_pim_control", "status", "log", "*"],
        ["emulation_pim_info", "status", "log", "*"],
        
        ["emulation_stp_bridge_config", "status", "log", "bridge_handles"],
        ["emulation_stp_msti_config", "status", "log", "handle"],
        ["emulation_stp_vlan_config", "status", "log", "handle"],
        ["emulation_stp_lan_config", "status", "log", "handle"],
        ["emulation_stp_control", "status", "log", "*"],
        ["emulation_stp_info", "status", "log", "*"],
        
        ["emulation_mplstp_config", "status", "log", "status"],
        ["emulation_mplstp_lsp_pw_config", "status", "log", "*"],
        ["emulation_mplstp_control", "status", "log", "*"],
        ["emulation_mplstp_info", "status", "log", "*"],
        
        ["L47_network", "status", "log", "status"],
        ["L47_dut", "status", "log", "status"],
        ["L47_client_mapping", "status", "log", "status"],
        ["L47_server_mapping", "status", "log", "status"],
        ["L47_test", "status", "log", "status"],
        ["L47_stats", "status", "log", "status"],
                
        ["L47_ftp_client", "status", "log", "status"],
        ["L47_ftp_server", "status", "log", "status"],
                
        ["L47_http_client", "status", "log", "status"],
        ["L47_http_server", "status", "log", "status"],
        ["l3vpn_generate_stream", "status", "log", "status"],
        
        ["L47_telnet_client", "status", "log", "status"],
        ["L47_telnet_server", "status", "log", "status"],
        
        ["convert_vport_to_porthandle", "status", "*", "*"],
        ["convert_porthandle_to_vport", "status", "*", "*"],
		["convert_portname_to_vport", "status", "log", "*"],
        ["get_nodrop_rate", "status", "log", "status"],    
        
        ["test_control", "status", "log", "*"],
        ["test_stats", "status", "log", "*"],
        ["cleanup_session", "status", "log", "status"],
        ["reboot_port_cpu", "status", "log", "*"],
        
        ["find_in_csv", "status", "log", "status"],
        ["reset_port", "status", "log", "status"],
        
        ["packet_config_buffers", "status", "log", "*"],
        ["packet_config_filter", "status", "log", "*"],
        ["packet_config_triggers", "status", "log", "*"],
        ["packet_control", "status", "log", "*"],
        ["packet_stats", "status", "log", "*"],
        ["session_info", "status", "log", "status"],
        ["uds_config", "status", "log", "*"],
        ["uds_filter_pallette_config", "status", "log", "*"]
    );
    #"if (\"$returnk\" == "") { return(\@l); }\n"
    for (my $i=0; $i<=$#cmd_spec_list; $i++) {
        my $cmd = $cmd_spec_list[$i][0];
        # key that holds the status
        my $statusk = $cmd_spec_list[$i][1];
        # key that holds the error msg (if status was not ::SUCCESS)
        my $logk = $cmd_spec_list[$i][2];
        # key that holds the value to return
        my $returnk = $cmd_spec_list[$i][3];
        my $return_on_failure = "";
        if ($hlp_return_on_failure == 1) {
            $return_on_failure = "  my \$err=ixiatcl::errorInfo();\n".
            "  my \$log=ixiahlt::status_item('log');\n".
            "  Carp::confess(\"error: $cmd: ( \$log ): \\n--------\\n\$err\\n\\n/\\\\ tcl ====================================================== perl \\\\/\\n\\n\");\n";
        } else {
            $return_on_failure = "return ixiatcl::_xeval(\"keylget ::KLV log\");\n ";
        }
        my $ss = 
        "sub $cmd {\n" . 
        'my $klv = "";'. "\n". 
        'eval {$klv=ixiatcl::_xinvoke('."\"::ixia::$cmd\"".',ixiatcl::_flatten(@_));} or do { Carp::confess($@."\n".ixiatcl::errorInfo()."\n\n/\\\\ tcl ====================================================== perl\\\\/\n\n");};'. "\n" .
        'ixiatcl::set("::KLV", $klv);' . "\n" .
        "if (ixiahlt::status_item('status')!=1) {\n" .$return_on_failure.
        "}\n" .
        "if (\"$returnk\" eq \"*\") {return \$klv;}" . "\n" .
        "return ixiatcl::_xeval(\"keylget ::KLV $returnk\");\n" .
        '};';
        #-----------------------------------------------------------        
        #print("<\n" . $ss . "\n>\n");
        eval($ss);
    }

    #
    # Make an accessor to the last keyed list returned by a ixiahlt::XXX cmd
    #
    sub status_item {
      my $key = shift;
      ixiatcl::_xinvoke('::KLVGET', $key);
    };
    sub status_item_keys {
      return ixiatcl::_xinvoke('::KLVKEYS', @_);
    };

    ixiatcl::package("require", "Ixia");
    # Put the connection manager shim in place if requested
    #
    if ($use_ixnetworktclconnector) {
        my $tctmp = ixiatcl::_xeval('package require IxTclNetworkConnector');
        print("ixiahlt: IxTclNetworkConnector version: $tctmp\n");
    }
    $ixiahlt::initialized = "1.0.0";
}

#------------
# The Ixia pkg loads IxTclHal which does not handle Ctrl+C well, 
# It crashes and puts up a windows dialog box even when tk is not loaded
# sig_int_handler is installed to mitigate that behavior.
#
sub sig_int_handler {
    warn("Received interrupt, exiting.");
    # plain perl and tclsh interps on windows 
    # produce an exit code of 58 on sigint so we will do the same
    $ixiatcl::interp->invoke("exit", "58");
}
use sigtrap 'handler' , \&sig_int_handler, 'INT';
#------------

## return value for package
1;
