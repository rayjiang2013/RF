from ixiahlt import IxiaHlt
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass

class IxiaNgpf(PartialClass, IxiaNgpf):
	def atm(self, **kwargs):
		if hasattr(self.ixiahlt, 'atm'):
			return self.ixiahlt.atm(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def atm_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'atm_config'):
			return self.ixiahlt.atm_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def atm_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'atm_control'):
			return self.ixiahlt.atm_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def atm_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'atm_stats'):
			return self.ixiahlt.atm_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def capture_packets(self, **kwargs):
		if hasattr(self.ixiahlt, 'capture_packets'):
			return self.ixiahlt.capture_packets(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def dcbxrange(self, **kwargs):
		if hasattr(self.ixiahlt, 'dcbxrange'):
			return self.ixiahlt.dcbxrange(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def dcbxrange_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'dcbxrange_config'):
			return self.ixiahlt.dcbxrange_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def dcbxrange_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'dcbxrange_control'):
			return self.ixiahlt.dcbxrange_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def dcbxrange_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'dcbxrange_stats'):
			return self.ixiahlt.dcbxrange_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def dcbxtlv(self, **kwargs):
		if hasattr(self.ixiahlt, 'dcbxtlv'):
			return self.ixiahlt.dcbxtlv(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def dcbxtlv_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'dcbxtlv_config'):
			return self.ixiahlt.dcbxtlv_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def dcbxtlv_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'dcbxtlv_control'):
			return self.ixiahlt.dcbxtlv_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def dcbxtlv_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'dcbxtlv_stats'):
			return self.ixiahlt.dcbxtlv_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def dcbxtlvqaz(self, **kwargs):
		if hasattr(self.ixiahlt, 'dcbxtlvqaz'):
			return self.ixiahlt.dcbxtlvqaz(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def dcbxtlvqaz_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'dcbxtlvqaz_config'):
			return self.ixiahlt.dcbxtlvqaz_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def dcbxtlvqaz_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'dcbxtlvqaz_control'):
			return self.ixiahlt.dcbxtlvqaz_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def dcbxtlvqaz_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'dcbxtlvqaz_stats'):
			return self.ixiahlt.dcbxtlvqaz_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def device_info(self, **kwargs):
		if hasattr(self.ixiahlt, 'device_info'):
			return self.ixiahlt.device_info(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_bfd_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_bfd_config'):
			return self.ixiahlt.emulation_bfd_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_bfd_controls(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_bfd_controls'):
			return self.ixiahlt.emulation_bfd_controls(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_bfd_info(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_bfd_info'):
			return self.ixiahlt.emulation_bfd_info(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_bfd_session_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_bfd_session_config'):
			return self.ixiahlt.emulation_bfd_session_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_cfm_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_cfm_config'):
			return self.ixiahlt.emulation_cfm_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_cfm_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_cfm_control'):
			return self.ixiahlt.emulation_cfm_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_cfm_custom_tlv_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_cfm_custom_tlv_config'):
			return self.ixiahlt.emulation_cfm_custom_tlv_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_cfm_info(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_cfm_info'):
			return self.ixiahlt.emulation_cfm_info(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_cfm_links_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_cfm_links_config'):
			return self.ixiahlt.emulation_cfm_links_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_cfm_md_meg_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_cfm_md_meg_config'):
			return self.ixiahlt.emulation_cfm_md_meg_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_cfm_mip_mep_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_cfm_mip_mep_config'):
			return self.ixiahlt.emulation_cfm_mip_mep_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_cfm_vlan_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_cfm_vlan_config'):
			return self.ixiahlt.emulation_cfm_vlan_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_efm_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_efm_config'):
			return self.ixiahlt.emulation_efm_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_efm_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_efm_control'):
			return self.ixiahlt.emulation_efm_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_efm_org_var_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_efm_org_var_config'):
			return self.ixiahlt.emulation_efm_org_var_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_efm_stat(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_efm_stat'):
			return self.ixiahlt.emulation_efm_stat(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_eigrp_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_eigrp_config'):
			return self.ixiahlt.emulation_eigrp_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_eigrp_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_eigrp_control'):
			return self.ixiahlt.emulation_eigrp_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_eigrp_info(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_eigrp_info'):
			return self.ixiahlt.emulation_eigrp_info(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_eigrp_route_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_eigrp_route_config'):
			return self.ixiahlt.emulation_eigrp_route_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_ftp_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_ftp_config'):
			return self.ixiahlt.emulation_ftp_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_ftp_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_ftp_control'):
			return self.ixiahlt.emulation_ftp_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_ftp_control_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_ftp_control_config'):
			return self.ixiahlt.emulation_ftp_control_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_ftp_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_ftp_stats'):
			return self.ixiahlt.emulation_ftp_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_ftp_traffic_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_ftp_traffic_config'):
			return self.ixiahlt.emulation_ftp_traffic_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_http_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_http_config'):
			return self.ixiahlt.emulation_http_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_http_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_http_control'):
			return self.ixiahlt.emulation_http_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_http_control_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_http_control_config'):
			return self.ixiahlt.emulation_http_control_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_http_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_http_stats'):
			return self.ixiahlt.emulation_http_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_http_traffic_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_http_traffic_config'):
			return self.ixiahlt.emulation_http_traffic_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_http_traffic_type_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_http_traffic_type_config'):
			return self.ixiahlt.emulation_http_traffic_type_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_isis_topology_route_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_isis_topology_route_config'):
			return self.ixiahlt.emulation_isis_topology_route_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_lacp_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_lacp_control'):
			return self.ixiahlt.emulation_lacp_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_lacp_info(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_lacp_info'):
			return self.ixiahlt.emulation_lacp_info(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_lacp_link_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_lacp_link_config'):
			return self.ixiahlt.emulation_lacp_link_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_mplstp_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_mplstp_config'):
			return self.ixiahlt.emulation_mplstp_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_mplstp_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_mplstp_control'):
			return self.ixiahlt.emulation_mplstp_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_mplstp_info(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_mplstp_info'):
			return self.ixiahlt.emulation_mplstp_info(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_mplstp_lsp_pw_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_mplstp_lsp_pw_config'):
			return self.ixiahlt.emulation_mplstp_lsp_pw_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_oam_config_msg(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_oam_config_msg'):
			return self.ixiahlt.emulation_oam_config_msg(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_oam_config_topology(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_oam_config_topology'):
			return self.ixiahlt.emulation_oam_config_topology(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_oam_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_oam_control'):
			return self.ixiahlt.emulation_oam_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_oam_info(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_oam_info'):
			return self.ixiahlt.emulation_oam_info(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_pbb_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_pbb_config'):
			return self.ixiahlt.emulation_pbb_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_pbb_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_pbb_control'):
			return self.ixiahlt.emulation_pbb_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_pbb_custom_tlv_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_pbb_custom_tlv_config'):
			return self.ixiahlt.emulation_pbb_custom_tlv_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_pbb_info(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_pbb_info'):
			return self.ixiahlt.emulation_pbb_info(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_pbb_trunk_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_pbb_trunk_config'):
			return self.ixiahlt.emulation_pbb_trunk_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_rip_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_rip_config'):
			return self.ixiahlt.emulation_rip_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_rip_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_rip_control'):
			return self.ixiahlt.emulation_rip_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_rip_route_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_rip_route_config'):
			return self.ixiahlt.emulation_rip_route_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_rsvp_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_rsvp_config'):
			return self.ixiahlt.emulation_rsvp_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_rsvp_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_rsvp_control'):
			return self.ixiahlt.emulation_rsvp_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_rsvp_info(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_rsvp_info'):
			return self.ixiahlt.emulation_rsvp_info(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_rsvp_tunnel_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_rsvp_tunnel_config'):
			return self.ixiahlt.emulation_rsvp_tunnel_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_rsvp_tunnel_info(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_rsvp_tunnel_info'):
			return self.ixiahlt.emulation_rsvp_tunnel_info(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_stp_bridge_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_stp_bridge_config'):
			return self.ixiahlt.emulation_stp_bridge_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_stp_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_stp_control'):
			return self.ixiahlt.emulation_stp_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_stp_info(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_stp_info'):
			return self.ixiahlt.emulation_stp_info(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_stp_lan_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_stp_lan_config'):
			return self.ixiahlt.emulation_stp_lan_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_stp_msti_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_stp_msti_config'):
			return self.ixiahlt.emulation_stp_msti_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_stp_vlan_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_stp_vlan_config'):
			return self.ixiahlt.emulation_stp_vlan_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_telnet_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_telnet_config'):
			return self.ixiahlt.emulation_telnet_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_telnet_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_telnet_control'):
			return self.ixiahlt.emulation_telnet_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_telnet_control_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_telnet_control_config'):
			return self.ixiahlt.emulation_telnet_control_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_telnet_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_telnet_stats'):
			return self.ixiahlt.emulation_telnet_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_telnet_traffic_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_telnet_traffic_config'):
			return self.ixiahlt.emulation_telnet_traffic_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_twamp_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_twamp_config'):
			return self.ixiahlt.emulation_twamp_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_twamp_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_twamp_control'):
			return self.ixiahlt.emulation_twamp_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_twamp_control_range_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_twamp_control_range_config'):
			return self.ixiahlt.emulation_twamp_control_range_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_twamp_info(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_twamp_info'):
			return self.ixiahlt.emulation_twamp_info(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_twamp_server_range_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_twamp_server_range_config'):
			return self.ixiahlt.emulation_twamp_server_range_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def emulation_twamp_test_range_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'emulation_twamp_test_range_config'):
			return self.ixiahlt.emulation_twamp_test_range_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def esmc(self, **kwargs):
		if hasattr(self.ixiahlt, 'esmc'):
			return self.ixiahlt.esmc(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def esmc_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'esmc_config'):
			return self.ixiahlt.esmc_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def esmc_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'esmc_control'):
			return self.ixiahlt.esmc_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def esmc_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'esmc_stats'):
			return self.ixiahlt.esmc_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def ethernet(self, **kwargs):
		if hasattr(self.ixiahlt, 'ethernet'):
			return self.ixiahlt.ethernet(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def ethernet_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'ethernet_config'):
			return self.ixiahlt.ethernet_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def ethernet_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'ethernet_control'):
			return self.ixiahlt.ethernet_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def ethernet_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'ethernet_stats'):
			return self.ixiahlt.ethernet_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def ethernetrange(self, **kwargs):
		if hasattr(self.ixiahlt, 'ethernetrange'):
			return self.ixiahlt.ethernetrange(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def ethernetrange_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'ethernetrange_config'):
			return self.ixiahlt.ethernetrange_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def ethernetrange_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'ethernetrange_control'):
			return self.ixiahlt.ethernetrange_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def ethernetrange_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'ethernetrange_stats'):
			return self.ixiahlt.ethernetrange_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fc_client_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'fc_client_config'):
			return self.ixiahlt.fc_client_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fc_client_global_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'fc_client_global_config'):
			return self.ixiahlt.fc_client_global_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fc_client_options_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'fc_client_options_config'):
			return self.ixiahlt.fc_client_options_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fc_client_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'fc_client_stats'):
			return self.ixiahlt.fc_client_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fc_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'fc_control'):
			return self.ixiahlt.fc_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fc_fport_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'fc_fport_config'):
			return self.ixiahlt.fc_fport_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fc_fport_global_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'fc_fport_global_config'):
			return self.ixiahlt.fc_fport_global_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fc_fport_options_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'fc_fport_options_config'):
			return self.ixiahlt.fc_fport_options_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fc_fport_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'fc_fport_stats'):
			return self.ixiahlt.fc_fport_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fc_fport_vnport_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'fc_fport_vnport_config'):
			return self.ixiahlt.fc_fport_vnport_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe'):
			return self.ixiahlt.fcoe(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_client_globals(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_client_globals'):
			return self.ixiahlt.fcoe_client_globals(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_client_globals_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_client_globals_config'):
			return self.ixiahlt.fcoe_client_globals_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_client_globals_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_client_globals_control'):
			return self.ixiahlt.fcoe_client_globals_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_client_globals_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_client_globals_stats'):
			return self.ixiahlt.fcoe_client_globals_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_client_options(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_client_options'):
			return self.ixiahlt.fcoe_client_options(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_client_options_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_client_options_config'):
			return self.ixiahlt.fcoe_client_options_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_client_options_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_client_options_control'):
			return self.ixiahlt.fcoe_client_options_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_client_options_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_client_options_stats'):
			return self.ixiahlt.fcoe_client_options_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_config'):
			return self.ixiahlt.fcoe_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_control'):
			return self.ixiahlt.fcoe_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_fwd(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_fwd'):
			return self.ixiahlt.fcoe_fwd(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_fwd_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_fwd_config'):
			return self.ixiahlt.fcoe_fwd_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_fwd_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_fwd_control'):
			return self.ixiahlt.fcoe_fwd_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_fwd_globals(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_fwd_globals'):
			return self.ixiahlt.fcoe_fwd_globals(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_fwd_globals_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_fwd_globals_config'):
			return self.ixiahlt.fcoe_fwd_globals_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_fwd_globals_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_fwd_globals_control'):
			return self.ixiahlt.fcoe_fwd_globals_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_fwd_globals_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_fwd_globals_stats'):
			return self.ixiahlt.fcoe_fwd_globals_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_fwd_options(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_fwd_options'):
			return self.ixiahlt.fcoe_fwd_options(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_fwd_options_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_fwd_options_config'):
			return self.ixiahlt.fcoe_fwd_options_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_fwd_options_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_fwd_options_control'):
			return self.ixiahlt.fcoe_fwd_options_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_fwd_options_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_fwd_options_stats'):
			return self.ixiahlt.fcoe_fwd_options_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_fwd_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_fwd_stats'):
			return self.ixiahlt.fcoe_fwd_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_fwd_vnport(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_fwd_vnport'):
			return self.ixiahlt.fcoe_fwd_vnport(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_fwd_vnport_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_fwd_vnport_config'):
			return self.ixiahlt.fcoe_fwd_vnport_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_fwd_vnport_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_fwd_vnport_control'):
			return self.ixiahlt.fcoe_fwd_vnport_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_fwd_vnport_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_fwd_vnport_stats'):
			return self.ixiahlt.fcoe_fwd_vnport_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def fcoe_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'fcoe_stats'):
			return self.ixiahlt.fcoe_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def find_in_csv(self, **kwargs):
		if hasattr(self.ixiahlt, 'find_in_csv'):
			return self.ixiahlt.find_in_csv(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def format_space_port_list(self, **kwargs):
		if hasattr(self.ixiahlt, 'format_space_port_list'):
			return self.ixiahlt.format_space_port_list(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def get_nodrop_rate(self, **kwargs):
		if hasattr(self.ixiahlt, 'get_nodrop_rate'):
			return self.ixiahlt.get_nodrop_rate(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def interface_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'interface_control'):
			return self.ixiahlt.interface_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def interface_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'interface_stats'):
			return self.ixiahlt.interface_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def iprange(self, **kwargs):
		if hasattr(self.ixiahlt, 'iprange'):
			return self.ixiahlt.iprange(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def iprange_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'iprange_config'):
			return self.ixiahlt.iprange_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def iprange_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'iprange_control'):
			return self.ixiahlt.iprange_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def iprange_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'iprange_stats'):
			return self.ixiahlt.iprange_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def keylprint(self, **kwargs):
		if hasattr(self.ixiahlt, 'keylprint'):
			return self.ixiahlt.keylprint(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def L47_client_mapping(self, **kwargs):
		if hasattr(self.ixiahlt, 'L47_client_mapping'):
			return self.ixiahlt.L47_client_mapping(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def L47_dut(self, **kwargs):
		if hasattr(self.ixiahlt, 'L47_dut'):
			return self.ixiahlt.L47_dut(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def L47_ftp_client(self, **kwargs):
		if hasattr(self.ixiahlt, 'L47_ftp_client'):
			return self.ixiahlt.L47_ftp_client(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def L47_ftp_server(self, **kwargs):
		if hasattr(self.ixiahlt, 'L47_ftp_server'):
			return self.ixiahlt.L47_ftp_server(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def L47_http_client(self, **kwargs):
		if hasattr(self.ixiahlt, 'L47_http_client'):
			return self.ixiahlt.L47_http_client(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def L47_http_server(self, **kwargs):
		if hasattr(self.ixiahlt, 'L47_http_server'):
			return self.ixiahlt.L47_http_server(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def L47_network(self, **kwargs):
		if hasattr(self.ixiahlt, 'L47_network'):
			return self.ixiahlt.L47_network(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def L47_server_mapping(self, **kwargs):
		if hasattr(self.ixiahlt, 'L47_server_mapping'):
			return self.ixiahlt.L47_server_mapping(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def L47_sip_client(self, **kwargs):
		if hasattr(self.ixiahlt, 'L47_sip_client'):
			return self.ixiahlt.L47_sip_client(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def L47_sip_server(self, **kwargs):
		if hasattr(self.ixiahlt, 'L47_sip_server'):
			return self.ixiahlt.L47_sip_server(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def L47_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'L47_stats'):
			return self.ixiahlt.L47_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def L47_telnet_client(self, **kwargs):
		if hasattr(self.ixiahlt, 'L47_telnet_client'):
			return self.ixiahlt.L47_telnet_client(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def L47_telnet_server(self, **kwargs):
		if hasattr(self.ixiahlt, 'L47_telnet_server'):
			return self.ixiahlt.L47_telnet_server(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def L47_test(self, **kwargs):
		if hasattr(self.ixiahlt, 'L47_test'):
			return self.ixiahlt.L47_test(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def L47_video_client(self, **kwargs):
		if hasattr(self.ixiahlt, 'L47_video_client'):
			return self.ixiahlt.L47_video_client(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def L47_video_server(self, **kwargs):
		if hasattr(self.ixiahlt, 'L47_video_server'):
			return self.ixiahlt.L47_video_server(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def logHltapiCommand(self, **kwargs):
		if hasattr(self.ixiahlt, 'logHltapiCommand'):
			return self.ixiahlt.logHltapiCommand(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def packet_config_buffers(self, **kwargs):
		if hasattr(self.ixiahlt, 'packet_config_buffers'):
			return self.ixiahlt.packet_config_buffers(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def packet_config_filter(self, **kwargs):
		if hasattr(self.ixiahlt, 'packet_config_filter'):
			return self.ixiahlt.packet_config_filter(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def packet_config_triggers(self, **kwargs):
		if hasattr(self.ixiahlt, 'packet_config_triggers'):
			return self.ixiahlt.packet_config_triggers(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def packet_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'packet_control'):
			return self.ixiahlt.packet_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def packet_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'packet_stats'):
			return self.ixiahlt.packet_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def parse_dashed_args(self, **kwargs):
		if hasattr(self.ixiahlt, 'parse_dashed_args'):
			return self.ixiahlt.parse_dashed_args(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def ptp_globals(self, **kwargs):
		if hasattr(self.ixiahlt, 'ptp_globals'):
			return self.ixiahlt.ptp_globals(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def ptp_globals_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'ptp_globals_control'):
			return self.ixiahlt.ptp_globals_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def ptp_globals_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'ptp_globals_stats'):
			return self.ixiahlt.ptp_globals_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def ptp_options(self, **kwargs):
		if hasattr(self.ixiahlt, 'ptp_options'):
			return self.ixiahlt.ptp_options(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def ptp_options_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'ptp_options_control'):
			return self.ixiahlt.ptp_options_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def ptp_options_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'ptp_options_stats'):
			return self.ixiahlt.ptp_options_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def ptp_over_ip(self, **kwargs):
		if hasattr(self.ixiahlt, 'ptp_over_ip'):
			return self.ixiahlt.ptp_over_ip(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def ptp_over_mac(self, **kwargs):
		if hasattr(self.ixiahlt, 'ptp_over_mac'):
			return self.ixiahlt.ptp_over_mac(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def reboot_port_cpu(self, **kwargs):
		if hasattr(self.ixiahlt, 'reboot_port_cpu'):
			return self.ixiahlt.reboot_port_cpu(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def reset_port(self, **kwargs):
		if hasattr(self.ixiahlt, 'reset_port'):
			return self.ixiahlt.reset_port(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def session_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'session_control'):
			return self.ixiahlt.session_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def session_info(self, **kwargs):
		if hasattr(self.ixiahlt, 'session_info'):
			return self.ixiahlt.session_info(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def session_resume(self, **kwargs):
		if hasattr(self.ixiahlt, 'session_resume'):
			return self.ixiahlt.session_resume(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def test_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'test_stats'):
			return self.ixiahlt.test_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def traffic_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'traffic_config'):
			return self.ixiahlt.traffic_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def traffic_control(self, **kwargs):
		if hasattr(self.ixiahlt, 'traffic_control'):
			return self.ixiahlt.traffic_control(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def traffic_stats(self, **kwargs):
		if hasattr(self.ixiahlt, 'traffic_stats'):
			return self.ixiahlt.traffic_stats(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def uds_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'uds_config'):
			return self.ixiahlt.uds_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def uds_filter_pallette_config(self, **kwargs):
		if hasattr(self.ixiahlt, 'uds_filter_pallette_config'):
			return self.ixiahlt.uds_filter_pallette_config(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def utracker(self, **kwargs):
		if hasattr(self.ixiahlt, 'utracker'):
			return self.ixiahlt.utracker(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def utrackerLoadLibrary(self, **kwargs):
		if hasattr(self.ixiahlt, 'utrackerLoadLibrary'):
			return self.ixiahlt.utrackerLoadLibrary(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def utrackerLog(self, **kwargs):
		if hasattr(self.ixiahlt, 'utrackerLog'):
			return self.ixiahlt.utrackerLog(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def vport_info(self, **kwargs):
		if hasattr(self.ixiahlt, 'vport_info'):
			return self.ixiahlt.vport_info(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def convert_porthandle_to_vport(self, **kwargs):
		if hasattr(self.ixiahlt, 'convert_porthandle_to_vport'):
			return self.ixiahlt.convert_porthandle_to_vport(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

	def convert_vport_to_porthandle(self, **kwargs):
		if hasattr(self.ixiahlt, 'convert_vport_to_porthandle'):
			return self.ixiahlt.convert_vport_to_porthandle(**kwargs)
		return {'status': IxiaHlt.FAIL, 'log': 'This command is not implemented in NGPF'}

