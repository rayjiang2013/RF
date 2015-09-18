# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def dhcp_client_extension_config(self, handle, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    dhcp_client_extension_config
		
		 Description:
		    Configures DHCPv6 client extension for the specified protocol stack (PPP, L2TP etc).
		
		 Synopsis:
		    dhcp_client_extension_config
		x       -handle                                       ANY
		x       [-dhcp6_client_range_duid_enterprise_id       RANGE 1-2147483647
		x                                                     DEFAULT 10]
		x       [-dhcp6_client_range_duid_type                CHOICES duid_en duid_llt duid_ll
		x                                                     DEFAULT duid_llt]
		x       [-dhcp6_client_range_duid_vendor_id           RANGE 1-2147483647
		x                                                     DEFAULT 10]
		x       [-dhcp6_client_range_duid_vendor_id_increment RANGE 1-2147483647
		x                                                     DEFAULT 1]
		n       [-dhcp6_client_range_param_request_list       ANY]
		n       [-dhcp6_client_range_use_vendor_class_id      ANY]
		n       [-dhcp6_client_range_vendor_class_id          ANY]
		x       [-dhcp6_global_rel_max_rc                     RANGE 1-100
		x                                                     DEFAULT 10]
		x       [-dhcp6_global_reb_max_rt                     RANGE 1-10000
		x                                                     DEFAULT 30]
		x       [-dhcp6_global_reb_timeout                    RANGE 1-100
		x                                                     DEFAULT 10]
		n       [-dhcp6_global_max_outstanding_requests       ANY]
		n       [-dhcp6_global_setup_rate_increment           ANY]
		n       [-dhcp6_global_setup_rate_initial             ANY]
		n       [-dhcp6_global_setup_rate_max                 ANY]
		x       [-dhcp6_pgdata_max_outstanding_requests       RANGE 1-100000
		x                                                     DEFAULT 20]
		x       [-dhcp6_pgdata_override_global_setup_rate     CHOICES 0 1
		x                                                     DEFAULT 0]
		n       [-dhcp6_pgdata_setup_rate_increment           ANY]
		x       [-dhcp6_pgdata_setup_rate_initial             RANGE 1-100000
		x                                                     DEFAULT 10]
		n       [-dhcp6_pgdata_setup_rate_max                 ANY]
		n       [-dhcp6_pgdata_associates                     ANY]
		x       [-mode                                        CHOICES add
		x                                                     CHOICES remove
		x                                                     CHOICES enable
		x                                                     CHOICES disable
		x                                                     CHOICES modify
		x                                                     DEFAULT add]
		x       [-dhcp6_global_echo_ia_info                   CHOICES 0 1
		x                                                     DEFAULT 0]
		n       [-dhcp6_global_max_outstanding_releases       ANY]
		x       [-dhcp6_global_rel_timeout                    RANGE 1-100
		x                                                     DEFAULT 1]
		x       [-dhcp6_global_ren_max_rt                     RANGE 1-10000
		x                                                     DEFAULT 600]
		x       [-dhcp6_global_ren_timeout                    RANGE 1-100
		x                                                     DEFAULT 10]
		x       [-dhcp6_global_req_max_rc                     RANGE 1-100
		x                                                     DEFAULT 10]
		x       [-dhcp6_global_req_max_rt                     RANGE 1-10000
		x                                                     DEFAULT 30]
		x       [-dhcp6_global_req_timeout                    RANGE 1-100
		x                                                     DEFAULT 1]
		x       [-dhcp6_global_sol_max_rc                     RANGE 1-100
		x                                                     DEFAULT 3]
		x       [-dhcp6_global_sol_max_rt                     RANGE 1-10000
		x                                                     DEFAULT 120]
		x       [-dhcp6_global_sol_timeout                    RANGE 1-100
		x                                                     DEFAULT 4]
		n       [-dhcp6_global_teardown_rate_increment        ANY]
		n       [-dhcp6_global_teardown_rate_initial          ANY]
		n       [-dhcp6_global_teardown_rate_max              ANY]
		n       [-dhcp6_global_wait_for_completion            ANY]
		x       [-dhcp6_pgdata_max_outstanding_releases       RANGE 1-100000
		x                                                     DEFAULT 500]
		x       [-dhcp6_pgdata_override_global_teardown_rate  CHOICES 0 1
		x                                                     DEFAULT 0]
		n       [-dhcp6_pgdata_teardown_rate_increment        ANY]
		x       [-dhcp6_pgdata_teardown_rate_initial          RANGE 1-100000
		x                                                     DEFAULT 50]
		n       [-dhcp6_pgdata_teardown_rate_max              ANY]
		
		 Arguments:
		x   -handle
		x       The protocol stack on top of which DHCpv6 client extension is to be
		x       created (for -mode add).
		x       The DHCpv6 client extension that needs to be modified/removed/enabled/disabled
		x       (for -mode modify/remove/enable/disable).
		x       When -handle is provided with the /globals value the arguments that configure global protocol
		x       setting accept both multivalue handles and simple values.
		x       When -handle is provided with a a protocol stack handle or a protocol session handle, the arguments
		x       that configure global settings will only accept simple values. In this situation, these arguments will
		x       configure only the settings of the parent device group or the ports associated with the parent topology.
		x   -dhcp6_client_range_duid_enterprise_id
		x       Define the vendor s registered Private Enterprise Number as maintained by IANA.
		x       Valid when dhcp6_client_range_duid_type is 'duid_en'.
		x   -dhcp6_client_range_duid_type
		x       Define the DHCP unique identifier type.
		x   -dhcp6_client_range_duid_vendor_id
		x       Define the vendor-assigned unique ID for this range. This ID is incremented
		x       automatically for each DHCP client.
		x       Dependencies: Valid when dhcp6_client_range_duid_type is  duid_en .
		x   -dhcp6_client_range_duid_vendor_id_increment
		x       Define the step to increment the vendor ID for each DHCP client.
		x       Dependencies: Valid when dhcp6_client_range_duid_type is  duid_en .
		n   -dhcp6_client_range_param_request_list
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -dhcp6_client_range_use_vendor_class_id
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -dhcp6_client_range_vendor_class_id
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -dhcp6_global_rel_max_rc
		x       RFC 3315 max request retry attempts.
		x       This parameter applies globally for all the ports in the configuration.
		x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
		x       Valid when port_role is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
		x   -dhcp6_global_reb_max_rt
		x       RFC 3315 max request timeout value in secons.
		x       This parameter applies globally for all the ports in the configuration.
		x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
		x       Valid when port_role is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
		x   -dhcp6_global_reb_timeout
		x       RFC 3315 initial request timeout value in secons.
		x       This parameter applies globally for all the ports in the configuration.
		x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
		x       Valid when port_role is 'access'; dhcpv6_hosts_enable is 1; ip_cp is 'ipv6_cp' or 'dual_stack'.
		n   -dhcp6_global_max_outstanding_requests
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -dhcp6_global_setup_rate_increment
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -dhcp6_global_setup_rate_initial
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -dhcp6_global_setup_rate_max
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -dhcp6_pgdata_max_outstanding_requests
		x       The maximum number of requests to be sent by all DHCP clients during session
		x       startup. This parameter applies globally for all the ports in the configuration.
		x       Available starting with HLT API 3.90 IxNetwork is used for PPPoX configurations.
		x       Valid when port_role is  access ; dhcpv6_hosts_enable is 1; ip_cp is  ipv6_cp  or
		x        dual_stack .
		x   -dhcp6_pgdata_override_global_setup_rate
		x       This parameter refers to the DHCPv6 Client Port Group Data. This parameter
		x       applies at the port level.
		x       Dependencies: Available starting with HLT API 3.90. Valid when port_role is
		x        access ; dhcpv6_hosts_enable is 1; ip_cp is  ipv6_cp  or  dual_stack .
		n   -dhcp6_pgdata_setup_rate_increment
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -dhcp6_pgdata_setup_rate_initial
		x       This parameter refers to the DHCPv6 Client Port Group Data. This parameter
		x       applies at the port level.
		x       Dependencies: Available starting with HLT API 3.90. Valid when port_role
		x       is  access ; dhcpv6_hosts_enable is 1; ip_cp is  ipv6_cp  or  dual_stack .
		x       Parameter dhcp6_pgdata_override_global_setup_rate is  1 
		n   -dhcp6_pgdata_setup_rate_max
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -dhcp6_pgdata_associates
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -mode
		x       The action to be performed: add, modify, remove, enable, disable.
		x   -dhcp6_global_echo_ia_info
		n   -dhcp6_global_max_outstanding_releases
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -dhcp6_global_rel_timeout
		x   -dhcp6_global_ren_max_rt
		x   -dhcp6_global_ren_timeout
		x   -dhcp6_global_req_max_rc
		x   -dhcp6_global_req_max_rt
		x   -dhcp6_global_req_timeout
		x   -dhcp6_global_sol_max_rc
		x   -dhcp6_global_sol_max_rt
		x   -dhcp6_global_sol_timeout
		n   -dhcp6_global_teardown_rate_increment
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -dhcp6_global_teardown_rate_initial
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -dhcp6_global_teardown_rate_max
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -dhcp6_global_wait_for_completion
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -dhcp6_pgdata_max_outstanding_releases
		x   -dhcp6_pgdata_override_global_teardown_rate
		n   -dhcp6_pgdata_teardown_rate_increment
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -dhcp6_pgdata_teardown_rate_initial
		n   -dhcp6_pgdata_teardown_rate_max
		n       This argument defined by Cisco is not supported for NGPF implementation.
		
		 Return Values:
		    A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		x   key:handle   value:A list containing individual interface, session and/or router handles that were added by the command (if any). Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    $::SUCCESS | $::FAILURE
		    key:status   value:$::SUCCESS | $::FAILURE
		    <dhcpv6 client extension handles>
		    key:handles  value:<dhcpv6 client extension handles>
		    When status is failure, contains more information
		    key:log      value:When status is failure, contains more information
		
		 Examples:
		    See files in the Samples/IxNetwork/DHCPv6 Client Extension subdirectory.
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    When -handle is provided with the /globals value the arguments that configure global protocol
		    setting accept both multivalue handles and simple values.
		    When -handle is provided with a a protocol stack handle or a protocol session handle, the arguments
		    that configure global settings will only accept simple values. In this situation, these arguments will
		    configure only the settings of the parent device group or the ports associated with the parent topology.
		    If the current session or command was run with -return_detailed_handles 0 the following keys will be omitted from the command response:  handle
		
		 See Also:
		
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
				'dhcp_client_extension_config', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
