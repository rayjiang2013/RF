package ixiangpf;

use utils;
use ixiahlt;

# For descriptions please refer to the corresponding ixiahlt commands.

sub atm {
	my $args = shift(@_);
	return ixiahlt::atm($args);
}

sub atm_config {
	my $args = shift(@_);
	return ixiahlt::atm_config($args);
}

sub atm_control {
	my $args = shift(@_);
	return ixiahlt::atm_control($args);
}

sub atm_stats {
	my $args = shift(@_);
	return ixiahlt::atm_stats($args);
}

sub capture_packets {
	my $args = shift(@_);
	return ixiahlt::capture_packets($args);
}

sub dcbxrange {
	my $args = shift(@_);
	return ixiahlt::dcbxrange($args);
}

sub dcbxrange_config {
	my $args = shift(@_);
	return ixiahlt::dcbxrange_config($args);
}

sub dcbxrange_control {
	my $args = shift(@_);
	return ixiahlt::dcbxrange_control($args);
}

sub dcbxrange_stats {
	my $args = shift(@_);
	return ixiahlt::dcbxrange_stats($args);
}

sub dcbxtlv {
	my $args = shift(@_);
	return ixiahlt::dcbxtlv($args);
}

sub dcbxtlv_config {
	my $args = shift(@_);
	return ixiahlt::dcbxtlv_config($args);
}

sub dcbxtlv_control {
	my $args = shift(@_);
	return ixiahlt::dcbxtlv_control($args);
}

sub dcbxtlv_stats {
	my $args = shift(@_);
	return ixiahlt::dcbxtlv_stats($args);
}

sub dcbxtlvqaz {
	my $args = shift(@_);
	return ixiahlt::dcbxtlvqaz($args);
}

sub dcbxtlvqaz_config {
	my $args = shift(@_);
	return ixiahlt::dcbxtlvqaz_config($args);
}

sub dcbxtlvqaz_control {
	my $args = shift(@_);
	return ixiahlt::dcbxtlvqaz_control($args);
}

sub dcbxtlvqaz_stats {
	my $args = shift(@_);
	return ixiahlt::dcbxtlvqaz_stats($args);
}

sub device_info {
	my $args = shift(@_);
	return ixiahlt::device_info($args);
}

sub emulation_bfd_config {
	my $args = shift(@_);
	return ixiahlt::emulation_bfd_config($args);
}

sub emulation_bfd_controls {
	my $args = shift(@_);
	return ixiahlt::emulation_bfd_controls($args);
}

sub emulation_bfd_info {
	my $args = shift(@_);
	return ixiahlt::emulation_bfd_info($args);
}

sub emulation_bfd_session_config {
	my $args = shift(@_);
	return ixiahlt::emulation_bfd_session_config($args);
}

sub emulation_cfm_config {
	my $args = shift(@_);
	return ixiahlt::emulation_cfm_config($args);
}

sub emulation_cfm_control {
	my $args = shift(@_);
	return ixiahlt::emulation_cfm_control($args);
}

sub emulation_cfm_custom_tlv_config {
	my $args = shift(@_);
	return ixiahlt::emulation_cfm_custom_tlv_config($args);
}

sub emulation_cfm_info {
	my $args = shift(@_);
	return ixiahlt::emulation_cfm_info($args);
}

sub emulation_cfm_links_config {
	my $args = shift(@_);
	return ixiahlt::emulation_cfm_links_config($args);
}

sub emulation_cfm_md_meg_config {
	my $args = shift(@_);
	return ixiahlt::emulation_cfm_md_meg_config($args);
}

sub emulation_cfm_mip_mep_config {
	my $args = shift(@_);
	return ixiahlt::emulation_cfm_mip_mep_config($args);
}

sub emulation_cfm_vlan_config {
	my $args = shift(@_);
	return ixiahlt::emulation_cfm_vlan_config($args);
}

sub emulation_efm_config {
	my $args = shift(@_);
	return ixiahlt::emulation_efm_config($args);
}

sub emulation_efm_control {
	my $args = shift(@_);
	return ixiahlt::emulation_efm_control($args);
}

sub emulation_efm_org_var_config {
	my $args = shift(@_);
	return ixiahlt::emulation_efm_org_var_config($args);
}

sub emulation_efm_stat {
	my $args = shift(@_);
	return ixiahlt::emulation_efm_stat($args);
}

sub emulation_eigrp_config {
	my $args = shift(@_);
	return ixiahlt::emulation_eigrp_config($args);
}

sub emulation_eigrp_control {
	my $args = shift(@_);
	return ixiahlt::emulation_eigrp_control($args);
}

sub emulation_eigrp_info {
	my $args = shift(@_);
	return ixiahlt::emulation_eigrp_info($args);
}

sub emulation_eigrp_route_config {
	my $args = shift(@_);
	return ixiahlt::emulation_eigrp_route_config($args);
}

sub emulation_ftp_config {
	my $args = shift(@_);
	return ixiahlt::emulation_ftp_config($args);
}

sub emulation_ftp_control {
	my $args = shift(@_);
	return ixiahlt::emulation_ftp_control($args);
}

sub emulation_ftp_control_config {
	my $args = shift(@_);
	return ixiahlt::emulation_ftp_control_config($args);
}

sub emulation_ftp_stats {
	my $args = shift(@_);
	return ixiahlt::emulation_ftp_stats($args);
}

sub emulation_ftp_traffic_config {
	my $args = shift(@_);
	return ixiahlt::emulation_ftp_traffic_config($args);
}

sub emulation_http_config {
	my $args = shift(@_);
	return ixiahlt::emulation_http_config($args);
}

sub emulation_http_control {
	my $args = shift(@_);
	return ixiahlt::emulation_http_control($args);
}

sub emulation_http_control_config {
	my $args = shift(@_);
	return ixiahlt::emulation_http_control_config($args);
}

sub emulation_http_stats {
	my $args = shift(@_);
	return ixiahlt::emulation_http_stats($args);
}

sub emulation_http_traffic_config {
	my $args = shift(@_);
	return ixiahlt::emulation_http_traffic_config($args);
}

sub emulation_http_traffic_type_config {
	my $args = shift(@_);
	return ixiahlt::emulation_http_traffic_type_config($args);
}

sub emulation_isis_topology_route_config {
	my $args = shift(@_);
	return ixiahlt::emulation_isis_topology_route_config($args);
}

sub emulation_lacp_control {
	my $args = shift(@_);
	return ixiahlt::emulation_lacp_control($args);
}

sub emulation_lacp_info {
	my $args = shift(@_);
	return ixiahlt::emulation_lacp_info($args);
}

sub emulation_lacp_link_config {
	my $args = shift(@_);
	return ixiahlt::emulation_lacp_link_config($args);
}

sub emulation_mplstp_config {
	my $args = shift(@_);
	return ixiahlt::emulation_mplstp_config($args);
}

sub emulation_mplstp_control {
	my $args = shift(@_);
	return ixiahlt::emulation_mplstp_control($args);
}

sub emulation_mplstp_info {
	my $args = shift(@_);
	return ixiahlt::emulation_mplstp_info($args);
}

sub emulation_mplstp_lsp_pw_config {
	my $args = shift(@_);
	return ixiahlt::emulation_mplstp_lsp_pw_config($args);
}

sub emulation_oam_config_msg {
	my $args = shift(@_);
	return ixiahlt::emulation_oam_config_msg($args);
}

sub emulation_oam_config_topology {
	my $args = shift(@_);
	return ixiahlt::emulation_oam_config_topology($args);
}

sub emulation_oam_control {
	my $args = shift(@_);
	return ixiahlt::emulation_oam_control($args);
}

sub emulation_oam_info {
	my $args = shift(@_);
	return ixiahlt::emulation_oam_info($args);
}

sub emulation_pbb_config {
	my $args = shift(@_);
	return ixiahlt::emulation_pbb_config($args);
}

sub emulation_pbb_control {
	my $args = shift(@_);
	return ixiahlt::emulation_pbb_control($args);
}

sub emulation_pbb_custom_tlv_config {
	my $args = shift(@_);
	return ixiahlt::emulation_pbb_custom_tlv_config($args);
}

sub emulation_pbb_info {
	my $args = shift(@_);
	return ixiahlt::emulation_pbb_info($args);
}

sub emulation_pbb_trunk_config {
	my $args = shift(@_);
	return ixiahlt::emulation_pbb_trunk_config($args);
}

sub emulation_rip_config {
	my $args = shift(@_);
	return ixiahlt::emulation_rip_config($args);
}

sub emulation_rip_control {
	my $args = shift(@_);
	return ixiahlt::emulation_rip_control($args);
}

sub emulation_rip_route_config {
	my $args = shift(@_);
	return ixiahlt::emulation_rip_route_config($args);
}

sub emulation_rsvp_config {
	my $args = shift(@_);
	return ixiahlt::emulation_rsvp_config($args);
}

sub emulation_rsvp_control {
	my $args = shift(@_);
	return ixiahlt::emulation_rsvp_control($args);
}

sub emulation_rsvp_info {
	my $args = shift(@_);
	return ixiahlt::emulation_rsvp_info($args);
}

sub emulation_rsvp_tunnel_config {
	my $args = shift(@_);
	return ixiahlt::emulation_rsvp_tunnel_config($args);
}

sub emulation_rsvp_tunnel_info {
	my $args = shift(@_);
	return ixiahlt::emulation_rsvp_tunnel_info($args);
}

sub emulation_stp_bridge_config {
	my $args = shift(@_);
	return ixiahlt::emulation_stp_bridge_config($args);
}

sub emulation_stp_control {
	my $args = shift(@_);
	return ixiahlt::emulation_stp_control($args);
}

sub emulation_stp_info {
	my $args = shift(@_);
	return ixiahlt::emulation_stp_info($args);
}

sub emulation_stp_lan_config {
	my $args = shift(@_);
	return ixiahlt::emulation_stp_lan_config($args);
}

sub emulation_stp_msti_config {
	my $args = shift(@_);
	return ixiahlt::emulation_stp_msti_config($args);
}

sub emulation_stp_vlan_config {
	my $args = shift(@_);
	return ixiahlt::emulation_stp_vlan_config($args);
}

sub emulation_telnet_config {
	my $args = shift(@_);
	return ixiahlt::emulation_telnet_config($args);
}

sub emulation_telnet_control {
	my $args = shift(@_);
	return ixiahlt::emulation_telnet_control($args);
}

sub emulation_telnet_control_config {
	my $args = shift(@_);
	return ixiahlt::emulation_telnet_control_config($args);
}

sub emulation_telnet_stats {
	my $args = shift(@_);
	return ixiahlt::emulation_telnet_stats($args);
}

sub emulation_telnet_traffic_config {
	my $args = shift(@_);
	return ixiahlt::emulation_telnet_traffic_config($args);
}

sub emulation_twamp_config {
	my $args = shift(@_);
	return ixiahlt::emulation_twamp_config($args);
}

sub emulation_twamp_control {
	my $args = shift(@_);
	return ixiahlt::emulation_twamp_control($args);
}

sub emulation_twamp_control_range_config {
	my $args = shift(@_);
	return ixiahlt::emulation_twamp_control_range_config($args);
}

sub emulation_twamp_info {
	my $args = shift(@_);
	return ixiahlt::emulation_twamp_info($args);
}

sub emulation_twamp_server_range_config {
	my $args = shift(@_);
	return ixiahlt::emulation_twamp_server_range_config($args);
}

sub emulation_twamp_test_range_config {
	my $args = shift(@_);
	return ixiahlt::emulation_twamp_test_range_config($args);
}

sub esmc {
	my $args = shift(@_);
	return ixiahlt::esmc($args);
}

sub esmc_config {
	my $args = shift(@_);
	return ixiahlt::esmc_config($args);
}

sub esmc_control {
	my $args = shift(@_);
	return ixiahlt::esmc_control($args);
}

sub esmc_stats {
	my $args = shift(@_);
	return ixiahlt::esmc_stats($args);
}

sub ethernet {
	my $args = shift(@_);
	return ixiahlt::ethernet($args);
}

sub ethernet_config {
	my $args = shift(@_);
	return ixiahlt::ethernet_config($args);
}

sub ethernet_control {
	my $args = shift(@_);
	return ixiahlt::ethernet_control($args);
}

sub ethernet_stats {
	my $args = shift(@_);
	return ixiahlt::ethernet_stats($args);
}

sub ethernetrange {
	my $args = shift(@_);
	return ixiahlt::ethernetrange($args);
}

sub ethernetrange_config {
	my $args = shift(@_);
	return ixiahlt::ethernetrange_config($args);
}

sub ethernetrange_control {
	my $args = shift(@_);
	return ixiahlt::ethernetrange_control($args);
}

sub ethernetrange_stats {
	my $args = shift(@_);
	return ixiahlt::ethernetrange_stats($args);
}

sub fc_client_config {
	my $args = shift(@_);
	return ixiahlt::fc_client_config($args);
}

sub fc_client_global_config {
	my $args = shift(@_);
	return ixiahlt::fc_client_global_config($args);
}

sub fc_client_options_config {
	my $args = shift(@_);
	return ixiahlt::fc_client_options_config($args);
}

sub fc_client_stats {
	my $args = shift(@_);
	return ixiahlt::fc_client_stats($args);
}

sub fc_control {
	my $args = shift(@_);
	return ixiahlt::fc_control($args);
}

sub fc_fport_config {
	my $args = shift(@_);
	return ixiahlt::fc_fport_config($args);
}

sub fc_fport_global_config {
	my $args = shift(@_);
	return ixiahlt::fc_fport_global_config($args);
}

sub fc_fport_options_config {
	my $args = shift(@_);
	return ixiahlt::fc_fport_options_config($args);
}

sub fc_fport_stats {
	my $args = shift(@_);
	return ixiahlt::fc_fport_stats($args);
}

sub fc_fport_vnport_config {
	my $args = shift(@_);
	return ixiahlt::fc_fport_vnport_config($args);
}

sub fcoe {
	my $args = shift(@_);
	return ixiahlt::fcoe($args);
}

sub fcoe_client_globals {
	my $args = shift(@_);
	return ixiahlt::fcoe_client_globals($args);
}

sub fcoe_client_globals_config {
	my $args = shift(@_);
	return ixiahlt::fcoe_client_globals_config($args);
}

sub fcoe_client_globals_control {
	my $args = shift(@_);
	return ixiahlt::fcoe_client_globals_control($args);
}

sub fcoe_client_globals_stats {
	my $args = shift(@_);
	return ixiahlt::fcoe_client_globals_stats($args);
}

sub fcoe_client_options {
	my $args = shift(@_);
	return ixiahlt::fcoe_client_options($args);
}

sub fcoe_client_options_config {
	my $args = shift(@_);
	return ixiahlt::fcoe_client_options_config($args);
}

sub fcoe_client_options_control {
	my $args = shift(@_);
	return ixiahlt::fcoe_client_options_control($args);
}

sub fcoe_client_options_stats {
	my $args = shift(@_);
	return ixiahlt::fcoe_client_options_stats($args);
}

sub fcoe_config {
	my $args = shift(@_);
	return ixiahlt::fcoe_config($args);
}

sub fcoe_control {
	my $args = shift(@_);
	return ixiahlt::fcoe_control($args);
}

sub fcoe_fwd {
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd($args);
}

sub fcoe_fwd_config {
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_config($args);
}

sub fcoe_fwd_control {
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_control($args);
}

sub fcoe_fwd_globals {
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_globals($args);
}

sub fcoe_fwd_globals_config {
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_globals_config($args);
}

sub fcoe_fwd_globals_control {
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_globals_control($args);
}

sub fcoe_fwd_globals_stats {
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_globals_stats($args);
}

sub fcoe_fwd_options {
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_options($args);
}

sub fcoe_fwd_options_config {
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_options_config($args);
}

sub fcoe_fwd_options_control {
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_options_control($args);
}

sub fcoe_fwd_options_stats {
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_options_stats($args);
}

sub fcoe_fwd_stats {
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_stats($args);
}

sub fcoe_fwd_vnport {
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_vnport($args);
}

sub fcoe_fwd_vnport_config {
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_vnport_config($args);
}

sub fcoe_fwd_vnport_control {
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_vnport_control($args);
}

sub fcoe_fwd_vnport_stats {
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_vnport_stats($args);
}

sub fcoe_stats {
	my $args = shift(@_);
	return ixiahlt::fcoe_stats($args);
}

sub find_in_csv {
	my $args = shift(@_);
	return ixiahlt::find_in_csv($args);
}

sub format_space_port_list {
	my $args = shift(@_);
	return ixiahlt::format_space_port_list($args);
}

sub get_nodrop_rate {
	my $args = shift(@_);
	return ixiahlt::get_nodrop_rate($args);
}

sub interface_control {
	my $args = shift(@_);
	return ixiahlt::interface_control($args);
}

sub interface_stats {
	my $args = shift(@_);
	return ixiahlt::interface_stats($args);
}

sub iprange {
	my $args = shift(@_);
	return ixiahlt::iprange($args);
}

sub iprange_config {
	my $args = shift(@_);
	return ixiahlt::iprange_config($args);
}

sub iprange_control {
	my $args = shift(@_);
	return ixiahlt::iprange_control($args);
}

sub iprange_stats {
	my $args = shift(@_);
	return ixiahlt::iprange_stats($args);
}

sub keylprint {
	my $args = shift(@_);
	return ixiahlt::keylprint($args);
}

sub L47_client_mapping {
	my $args = shift(@_);
	return ixiahlt::L47_client_mapping($args);
}

sub L47_dut {
	my $args = shift(@_);
	return ixiahlt::L47_dut($args);
}

sub L47_ftp_client {
	my $args = shift(@_);
	return ixiahlt::L47_ftp_client($args);
}

sub L47_ftp_server {
	my $args = shift(@_);
	return ixiahlt::L47_ftp_server($args);
}

sub L47_http_client {
	my $args = shift(@_);
	return ixiahlt::L47_http_client($args);
}

sub L47_http_server {
	my $args = shift(@_);
	return ixiahlt::L47_http_server($args);
}

sub L47_network {
	my $args = shift(@_);
	return ixiahlt::L47_network($args);
}

sub L47_server_mapping {
	my $args = shift(@_);
	return ixiahlt::L47_server_mapping($args);
}

sub L47_sip_client {
	my $args = shift(@_);
	return ixiahlt::L47_sip_client($args);
}

sub L47_sip_server {
	my $args = shift(@_);
	return ixiahlt::L47_sip_server($args);
}

sub L47_stats {
	my $args = shift(@_);
	return ixiahlt::L47_stats($args);
}

sub L47_telnet_client {
	my $args = shift(@_);
	return ixiahlt::L47_telnet_client($args);
}

sub L47_telnet_server {
	my $args = shift(@_);
	return ixiahlt::L47_telnet_server($args);
}

sub L47_test {
	my $args = shift(@_);
	return ixiahlt::L47_test($args);
}

sub L47_video_client {
	my $args = shift(@_);
	return ixiahlt::L47_video_client($args);
}

sub L47_video_server {
	my $args = shift(@_);
	return ixiahlt::L47_video_server($args);
}

sub logHltapiCommand {
	my $args = shift(@_);
	return ixiahlt::logHltapiCommand($args);
}

sub packet_config_buffers {
	my $args = shift(@_);
	return ixiahlt::packet_config_buffers($args);
}

sub packet_config_filter {
	my $args = shift(@_);
	return ixiahlt::packet_config_filter($args);
}

sub packet_config_triggers {
	my $args = shift(@_);
	return ixiahlt::packet_config_triggers($args);
}

sub packet_control {
	my $args = shift(@_);
	return ixiahlt::packet_control($args);
}

sub packet_stats {
	my $args = shift(@_);
	return ixiahlt::packet_stats($args);
}

sub parse_dashed_args {
	my $args = shift(@_);
	return ixiahlt::parse_dashed_args($args);
}

sub ptp_globals {
	my $args = shift(@_);
	return ixiahlt::ptp_globals($args);
}

sub ptp_globals_control {
	my $args = shift(@_);
	return ixiahlt::ptp_globals_control($args);
}

sub ptp_globals_stats {
	my $args = shift(@_);
	return ixiahlt::ptp_globals_stats($args);
}

sub ptp_options {
	my $args = shift(@_);
	return ixiahlt::ptp_options($args);
}

sub ptp_options_control {
	my $args = shift(@_);
	return ixiahlt::ptp_options_control($args);
}

sub ptp_options_stats {
	my $args = shift(@_);
	return ixiahlt::ptp_options_stats($args);
}

sub ptp_over_ip {
	my $args = shift(@_);
	return ixiahlt::ptp_over_ip($args);
}

sub ptp_over_mac {
	my $args = shift(@_);
	return ixiahlt::ptp_over_mac($args);
}

sub reboot_port_cpu {
	my $args = shift(@_);
	return ixiahlt::reboot_port_cpu($args);
}

sub reset_port {
	my $args = shift(@_);
	return ixiahlt::reset_port($args);
}

sub session_control {
	my $args = shift(@_);
	return ixiahlt::session_control($args);
}

sub session_info {
	my $args = shift(@_);
	return ixiahlt::session_info($args);
}

sub session_resume {
	my $args = shift(@_);
	return ixiahlt::session_resume($args);
}

sub test_stats {
	my $args = shift(@_);
	return ixiahlt::test_stats($args);
}

sub traffic_config {
	my $args = shift(@_);
	return ixiahlt::traffic_config($args);
}

sub traffic_control {
	my $args = shift(@_);
	return ixiahlt::traffic_control($args);
}

sub traffic_stats {
	my $args = shift(@_);
	return ixiahlt::traffic_stats($args);
}

sub uds_config {
	my $args = shift(@_);
	return ixiahlt::uds_config($args);
}

sub uds_filter_pallette_config {
	my $args = shift(@_);
	return ixiahlt::uds_filter_pallette_config($args);
}

sub utracker {
	my $args = shift(@_);
	return ixiahlt::utracker($args);
}

sub utrackerLoadLibrary {
	my $args = shift(@_);
	return ixiahlt::utrackerLoadLibrary($args);
}

sub utrackerLog {
	my $args = shift(@_);
	return ixiahlt::utrackerLog($args);
}

sub vport_info {
	my $args = shift(@_);
	return ixiahlt::vport_info($args);
}

sub convert_porthandle_to_vport {
	my $args = shift(@_);
	return ixiahlt::convert_porthandle_to_vport($args);
}

sub convert_vport_to_porthandle {
	my $args = shift(@_);
	return ixiahlt::convert_vport_to_porthandle($args);
}

# Return value for the package
return 1;