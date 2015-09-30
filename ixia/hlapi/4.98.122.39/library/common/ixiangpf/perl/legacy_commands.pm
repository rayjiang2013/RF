package ixiangpf;

use utils;
use ixiahlt;

# For descriptions please refer to the corresponding ixiahlt commands.

sub atm {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::atm($args);
}

sub atm_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::atm_config($args);
}

sub atm_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::atm_control($args);
}

sub atm_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::atm_stats($args);
}

sub capture_packets {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::capture_packets($args);
}

sub dcbxrange {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::dcbxrange($args);
}

sub dcbxrange_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::dcbxrange_config($args);
}

sub dcbxrange_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::dcbxrange_control($args);
}

sub dcbxrange_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::dcbxrange_stats($args);
}

sub dcbxtlv {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::dcbxtlv($args);
}

sub dcbxtlv_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::dcbxtlv_config($args);
}

sub dcbxtlv_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::dcbxtlv_control($args);
}

sub dcbxtlv_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::dcbxtlv_stats($args);
}

sub dcbxtlvqaz {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::dcbxtlvqaz($args);
}

sub dcbxtlvqaz_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::dcbxtlvqaz_config($args);
}

sub dcbxtlvqaz_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::dcbxtlvqaz_control($args);
}

sub dcbxtlvqaz_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::dcbxtlvqaz_stats($args);
}

sub device_info {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::device_info($args);
}

sub emulation_bfd_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_bfd_config($args);
}

sub emulation_bfd_controls {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_bfd_controls($args);
}

sub emulation_bfd_info {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_bfd_info($args);
}

sub emulation_bfd_session_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_bfd_session_config($args);
}

sub emulation_cfm_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_cfm_config($args);
}

sub emulation_cfm_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_cfm_control($args);
}

sub emulation_cfm_custom_tlv_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_cfm_custom_tlv_config($args);
}

sub emulation_cfm_info {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_cfm_info($args);
}

sub emulation_cfm_links_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_cfm_links_config($args);
}

sub emulation_cfm_md_meg_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_cfm_md_meg_config($args);
}

sub emulation_cfm_mip_mep_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_cfm_mip_mep_config($args);
}

sub emulation_cfm_vlan_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_cfm_vlan_config($args);
}

sub emulation_efm_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_efm_config($args);
}

sub emulation_efm_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_efm_control($args);
}

sub emulation_efm_org_var_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_efm_org_var_config($args);
}

sub emulation_efm_stat {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_efm_stat($args);
}

sub emulation_eigrp_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_eigrp_config($args);
}

sub emulation_eigrp_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_eigrp_control($args);
}

sub emulation_eigrp_info {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_eigrp_info($args);
}

sub emulation_eigrp_route_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_eigrp_route_config($args);
}

sub emulation_ftp_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_ftp_config($args);
}

sub emulation_ftp_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_ftp_control($args);
}

sub emulation_ftp_control_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_ftp_control_config($args);
}

sub emulation_ftp_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_ftp_stats($args);
}

sub emulation_ftp_traffic_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_ftp_traffic_config($args);
}

sub emulation_http_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_http_config($args);
}

sub emulation_http_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_http_control($args);
}

sub emulation_http_control_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_http_control_config($args);
}

sub emulation_http_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_http_stats($args);
}

sub emulation_http_traffic_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_http_traffic_config($args);
}

sub emulation_http_traffic_type_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_http_traffic_type_config($args);
}

sub emulation_isis_topology_route_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_isis_topology_route_config($args);
}

sub emulation_mplstp_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_mplstp_config($args);
}

sub emulation_mplstp_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_mplstp_control($args);
}

sub emulation_mplstp_info {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_mplstp_info($args);
}

sub emulation_mplstp_lsp_pw_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_mplstp_lsp_pw_config($args);
}

sub emulation_oam_config_msg {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_oam_config_msg($args);
}

sub emulation_oam_config_topology {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_oam_config_topology($args);
}

sub emulation_oam_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_oam_control($args);
}

sub emulation_oam_info {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_oam_info($args);
}

sub emulation_pbb_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_pbb_config($args);
}

sub emulation_pbb_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_pbb_control($args);
}

sub emulation_pbb_custom_tlv_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_pbb_custom_tlv_config($args);
}

sub emulation_pbb_info {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_pbb_info($args);
}

sub emulation_pbb_trunk_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_pbb_trunk_config($args);
}

sub emulation_rip_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_rip_config($args);
}

sub emulation_rip_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_rip_control($args);
}

sub emulation_rip_route_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_rip_route_config($args);
}

sub emulation_rsvp_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_rsvp_config($args);
}

sub emulation_rsvp_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_rsvp_control($args);
}

sub emulation_rsvp_info {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_rsvp_info($args);
}

sub emulation_rsvp_tunnel_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_rsvp_tunnel_config($args);
}

sub emulation_rsvp_tunnel_info {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_rsvp_tunnel_info($args);
}

sub emulation_stp_bridge_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_stp_bridge_config($args);
}

sub emulation_stp_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_stp_control($args);
}

sub emulation_stp_info {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_stp_info($args);
}

sub emulation_stp_lan_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_stp_lan_config($args);
}

sub emulation_stp_msti_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_stp_msti_config($args);
}

sub emulation_stp_vlan_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_stp_vlan_config($args);
}

sub emulation_telnet_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_telnet_config($args);
}

sub emulation_telnet_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_telnet_control($args);
}

sub emulation_telnet_control_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_telnet_control_config($args);
}

sub emulation_telnet_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_telnet_stats($args);
}

sub emulation_telnet_traffic_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_telnet_traffic_config($args);
}

sub emulation_twamp_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_twamp_config($args);
}

sub emulation_twamp_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_twamp_control($args);
}

sub emulation_twamp_control_range_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_twamp_control_range_config($args);
}

sub emulation_twamp_info {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_twamp_info($args);
}

sub emulation_twamp_server_range_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_twamp_server_range_config($args);
}

sub emulation_twamp_test_range_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::emulation_twamp_test_range_config($args);
}

sub esmc {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::esmc($args);
}

sub esmc_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::esmc_config($args);
}

sub esmc_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::esmc_control($args);
}

sub esmc_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::esmc_stats($args);
}

sub ethernet {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::ethernet($args);
}

sub ethernet_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::ethernet_config($args);
}

sub ethernet_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::ethernet_control($args);
}

sub ethernet_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::ethernet_stats($args);
}

sub ethernetrange {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::ethernetrange($args);
}

sub ethernetrange_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::ethernetrange_config($args);
}

sub ethernetrange_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::ethernetrange_control($args);
}

sub ethernetrange_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::ethernetrange_stats($args);
}

sub fc_client_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fc_client_config($args);
}

sub fc_client_global_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fc_client_global_config($args);
}

sub fc_client_options_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fc_client_options_config($args);
}

sub fc_client_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fc_client_stats($args);
}

sub fc_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fc_control($args);
}

sub fc_fport_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fc_fport_config($args);
}

sub fc_fport_global_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fc_fport_global_config($args);
}

sub fc_fport_options_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fc_fport_options_config($args);
}

sub fc_fport_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fc_fport_stats($args);
}

sub fc_fport_vnport_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fc_fport_vnport_config($args);
}

sub fcoe {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe($args);
}

sub fcoe_client_globals {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_client_globals($args);
}

sub fcoe_client_globals_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_client_globals_config($args);
}

sub fcoe_client_globals_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_client_globals_control($args);
}

sub fcoe_client_globals_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_client_globals_stats($args);
}

sub fcoe_client_options {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_client_options($args);
}

sub fcoe_client_options_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_client_options_config($args);
}

sub fcoe_client_options_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_client_options_control($args);
}

sub fcoe_client_options_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_client_options_stats($args);
}

sub fcoe_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_config($args);
}

sub fcoe_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_control($args);
}

sub fcoe_fwd {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd($args);
}

sub fcoe_fwd_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_config($args);
}

sub fcoe_fwd_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_control($args);
}

sub fcoe_fwd_globals {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_globals($args);
}

sub fcoe_fwd_globals_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_globals_config($args);
}

sub fcoe_fwd_globals_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_globals_control($args);
}

sub fcoe_fwd_globals_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_globals_stats($args);
}

sub fcoe_fwd_options {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_options($args);
}

sub fcoe_fwd_options_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_options_config($args);
}

sub fcoe_fwd_options_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_options_control($args);
}

sub fcoe_fwd_options_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_options_stats($args);
}

sub fcoe_fwd_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_stats($args);
}

sub fcoe_fwd_vnport {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_vnport($args);
}

sub fcoe_fwd_vnport_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_vnport_config($args);
}

sub fcoe_fwd_vnport_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_vnport_control($args);
}

sub fcoe_fwd_vnport_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_fwd_vnport_stats($args);
}

sub fcoe_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::fcoe_stats($args);
}

sub find_in_csv {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::find_in_csv($args);
}

sub format_space_port_list {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::format_space_port_list($args);
}

sub get_nodrop_rate {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::get_nodrop_rate($args);
}

sub interface_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::interface_control($args);
}

sub interface_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::interface_stats($args);
}

sub iprange {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::iprange($args);
}

sub iprange_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::iprange_config($args);
}

sub iprange_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::iprange_control($args);
}

sub iprange_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::iprange_stats($args);
}

sub keylprint {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::keylprint($args);
}

sub L47_client_mapping {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::L47_client_mapping($args);
}

sub L47_dut {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::L47_dut($args);
}

sub L47_ftp_client {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::L47_ftp_client($args);
}

sub L47_ftp_server {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::L47_ftp_server($args);
}

sub L47_http_client {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::L47_http_client($args);
}

sub L47_http_server {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::L47_http_server($args);
}

sub L47_network {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::L47_network($args);
}

sub L47_server_mapping {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::L47_server_mapping($args);
}

sub L47_sip_client {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::L47_sip_client($args);
}

sub L47_sip_server {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::L47_sip_server($args);
}

sub L47_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::L47_stats($args);
}

sub L47_telnet_client {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::L47_telnet_client($args);
}

sub L47_telnet_server {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::L47_telnet_server($args);
}

sub L47_test {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::L47_test($args);
}

sub L47_video_client {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::L47_video_client($args);
}

sub L47_video_server {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::L47_video_server($args);
}

sub logHltapiCommand {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::logHltapiCommand($args);
}

sub packet_config_buffers {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::packet_config_buffers($args);
}

sub packet_config_filter {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::packet_config_filter($args);
}

sub packet_config_triggers {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::packet_config_triggers($args);
}

sub packet_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::packet_control($args);
}

sub packet_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::packet_stats($args);
}

sub parse_dashed_args {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::parse_dashed_args($args);
}

sub ptp_globals {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::ptp_globals($args);
}

sub ptp_globals_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::ptp_globals_control($args);
}

sub ptp_globals_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::ptp_globals_stats($args);
}

sub ptp_options {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::ptp_options($args);
}

sub ptp_options_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::ptp_options_control($args);
}

sub ptp_options_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::ptp_options_stats($args);
}

sub ptp_over_ip {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::ptp_over_ip($args);
}

sub ptp_over_mac {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::ptp_over_mac($args);
}

sub reboot_port_cpu {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::reboot_port_cpu($args);
}

sub reset_port {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::reset_port($args);
}

sub session_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::session_control($args);
}

sub session_info {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::session_info($args);
}

sub session_resume {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::session_resume($args);
}

sub test_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::test_stats($args);
}

sub traffic_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::traffic_config($args);
}

sub traffic_control {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::traffic_control($args);
}

sub traffic_stats {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::traffic_stats($args);
}

sub uds_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::uds_config($args);
}

sub uds_filter_pallette_config {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::uds_filter_pallette_config($args);
}

sub utracker {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::utracker($args);
}

sub utrackerLoadLibrary {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::utrackerLoadLibrary($args);
}

sub utrackerLog {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::utrackerLog($args);
}

sub vport_info {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::vport_info($args);
}

sub convert_porthandle_to_vport {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::convert_porthandle_to_vport($args);
}

sub convert_vport_to_porthandle {
	$ixiangpf::hlapiHashResultRef = undef;
	$ixiangpf::checkIxiaResult = 1;
	my $args = shift(@_);
	return ixiahlt::convert_vport_to_porthandle($args);
}

# Return value for the package
return 1;