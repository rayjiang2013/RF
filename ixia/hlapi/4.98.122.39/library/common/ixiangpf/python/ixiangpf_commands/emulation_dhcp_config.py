# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def emulation_dhcp_config(self, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    emulation_dhcp_config
		
		 Description:
		    Configures DHCP emulation for the specified test port or handle.
		
		 Synopsis:
		    emulation_dhcp_config
		        [-handle                        ANY]
		        [-mode                          CHOICES create modify reset
		                                        DEFAULT create]
		        [-msg_timeout                   NUMERIC
		                                        DEFAULT 4]
		        [-outstanding_releases_count    RANGE 1-100000
		                                        DEFAULT 500]
		        [-outstanding_session_count     NUMERIC
		                                        DEFAULT 50]
		        [-port_handle                   REGEXP ^[0-9]+/[0-9]+/[0-9]+$]
		        [-release_rate                  RANGE 1-100000
		                                        DEFAULT 50]
		n       [-release_rate_increment        ANY]
		        [-request_rate                  RANGE 1-100000
		                                        DEFAULT 10]
		n       [-request_rate_increment        ANY]
		        [-retry_count                   RANGE 1-65536
		                                        DEFAULT 3]
		        [-client_port                   NUMERIC
		                                        DEFAULT 68]
		        [-start_scale_mode              CHOICES device_group port
		                                        DEFAULT port]
		        [-stop_scale_mode               CHOICES device_group port
		                                        DEFAULT port]
		        [-interval_stop                 NUMERIC
		                                        DEFAULT 1000]
		        [-interval_start                NUMERIC
		                                        DEFAULT 1000]
		        [-min_lifetime                  NUMERIC
		                                        DEFAULT 1]
		        [-max_restarts                  NUMERIC
		                                        DEFAULT 10]
		        [-max_lifetime                  NUMERIC
		                                        DEFAULT 10]
		        [-enable_restart                CHOICES 0 1
		                                        DEFAULT 0]
		        [-enable_lifetime               CHOICES 0 1
		                                        DEFAULT 0]
		x       [-unlimited_restarts            CHOICES 0 1
		x                                       DEFAULT 0]
		        [-server_port                   RANGE 0-65535
		                                        DEFAULT 67]
		x       [-dhcp6_echo_ia_info            CHOICES 0 1
		x                                       DEFAULT 0]
		x       [-dhcp6_reb_max_rt              RANGE 1-10000
		x                                       DEFAULT 600]
		x       [-dhcp6_reb_timeout             RANGE 1-100
		x                                       DEFAULT 10]
		x       [-dhcp6_rel_max_rc              RANGE 1-100
		x                                       DEFAULT 5]
		x       [-dhcp6_rel_timeout             RANGE 1-100
		x                                       DEFAULT 1]
		x       [-dhcp6_ren_max_rt              RANGE 1-10000
		x                                       DEFAULT 600]
		x       [-dhcp6_ren_timeout             RANGE 1-100
		x                                       DEFAULT 10]
		x       [-dhcp6_req_max_rc              RANGE 1-100
		x                                       DEFAULT 5]
		x       [-dhcp6_req_max_rt              RANGE 1-10000
		x                                       DEFAULT 30]
		x       [-dhcp6_req_timeout             RANGE 1-100
		x                                       DEFAULT 1]
		x       [-dhcp6_sol_max_rc              RANGE 1-65536
		x                                       DEFAULT 3]
		x       [-dhcp6_sol_max_rt              RANGE 1-10000
		x                                       DEFAULT 120]
		x       [-dhcp6_sol_timeout             RANGE 1-100
		x                                       DEFAULT 1]
		x       [-dhcp6_info_req_timeout        NUMERIC
		x                                       DEFAULT 4]
		x       [-dhcp6_info_req_max_rt         NUMERIC
		x                                       DEFAULT 120]
		x       [-dhcp6_info_req_max_rc         NUMERIC
		x                                       DEFAULT 3]
		x       [-msg_timeout_factor            RANGE 1-100
		x                                       DEFAULT 2]
		x       [-msg_max_timeout               RANGE 1-100
		x                                       DEFAULT 2]
		x       [-override_global_setup_rate    CHOICES 0 1
		x                                       DEFAULT 1]
		x       [-override_global_teardown_rate CHOICES 0 1
		x                                       DEFAULT 1]
		x       [-skip_release_on_stop          CHOICES 0 1
		x                                       DEFAULT 0]
		x       [-renew_on_link_up              CHOICES 0 1
		x                                       DEFAULT 0]
		n       [-accept_partial_config         ANY]
		n       [-lease_time                    ANY]
		n       [-max_dhcp_msg_size             ANY]
		n       [-wait_for_completion           ANY]
		n       [-associates                    ANY]
		n       [-no_write                      ANY]
		n       [-release_rate_max              ANY]
		n       [-request_rate_max              ANY]
		n       [-reset                         ANY]
		n       [-version                       ANY]
		n       [-response_wait                 ANY]
		n       [-retry_timer                   ANY]
		x       [-ip_version                    CHOICES 4 6
		x                                       DEFAULT 4]
		x       [-dhcp4_arp_gw                  CHOICES 0 1]
		x       [-dhcp6_ns_gw                   CHOICES 0 1]
		
		 Arguments:
		    -handle
		        Specifies the handle of the port upon which emulation is configured.
		        Mandatory for the mode -modify.
		        Valid for -version ixtclhal, ixnetwork.
		        When -handle is provided with the /globals value the arguments that configure global protocol
		        setting accept both multivalue handles and simple values.
		        When -handle is provided with a a protocol stack handle or a protocol session handle, the arguments
		        that configure global settings will only accept simple values. In this situation, these arguments will
		        configure only the settings of the parent device group or the ports associated with the parent topology.
		    -mode
		        This option defines the action to be taken on the port specified by
		        the port_handle argument.
		        Valid for -version ixtclhal, ixnetwork.
		    -msg_timeout
		        Specifies the maximum time to wait in milliseconds for receipt of an
		        offer or ack message after the sending of a corresponding discover or
		        request message.
		        Valid for -version ixnetwork.
		    -outstanding_releases_count
		        The maximum number of release sessions opened at any time by the DHCPv6
		        network stack element. The default is 500.
		        Valid for -version ixnetwork.
		    -outstanding_session_count
		        Specifies the maximum number of outstanding sessions (unacknowledged
		        discover or request message) allowed to exist. In effect, this is a
		        rate limiting mechanism that stops dhcp servers from being
		        overwhelmed with reqests.
		        Valid for -version ixnetwork.
		    -port_handle
		        This parameter specifies the port upon which emulation is configured.
		        Mandatory for the modes -create and -reset.
		        Valid for -version ixtclhal, ixnetwork.
		    -release_rate
		        The number of addresses to release in the first second after stop command
		        is received. The default is 50.
		        Valid for -version ixnetwork.
		n   -release_rate_increment
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -request_rate
		        Specifies the desired request rate in sessions per second.
		        Valid for -version ixnetwork.
		n   -request_rate_increment
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -retry_count
		        Limits the number of additional transmissions of either a discover or
		        request message when no acknowledgement is received.
		        Valid for -version ixnetwork.
		    -client_port
		        UDP port that the client listens on for DHCP responses.
		        Valid for dhcpv4 client.
		    -start_scale_mode
		        Indicates whether the control is specified per port or per device group.
		        This setting is global for all the dhcp client protocols configured in the ixncfg
		        and can be configured just when handle is /globals (when the user wants to configure just the global settings)
		    -stop_scale_mode
		        Indicates whether the control is specified per port or per device group.
		        This setting is global for all the dhcp client protocols configured in the ixncfg
		        and can be configured just when handle is /globals (when the user wants to configure just the global settings)
		    -interval_stop
		        Time interval used to calculate the rate for triggering an action.
		        Valid for both dhcpv4 and dhcpv6 client.
		    -interval_start
		        Time interval used to calculate the rate for triggering an action.
		        Valid for both dhcpv4 and dhcpv6 client.
		    -min_lifetime
		        Minimum session lifetime (in seconds).
		        Valid for both dhcpv4 and dhcpv6 client.
		    -max_restarts
		        Maximum number of times each session is automatically restarted.
		        Valid for both dhcpv4 and dhcpv6 client.
		    -max_lifetime
		        Maximum session lifetime(in seconds).
		        Valid for both dhcpv4 and dhcpv6 client.
		    -enable_restart
		        Enable automatic session restart after stop at lifetime expiry.
		        Valid for both dhcpv4 and dhcpv6 client.
		    -enable_lifetime
		        Enable session lifetime.
		        Valid for both dhcpv4 and dhcpv6 client.
		x   -unlimited_restarts
		x       Allow each session to always be automatically restarted
		x       Valid for both dhcpv4 and dhcpv6 client.
		    -server_port
		        The UDP port to which the client addresses its server requests. The
		        default value port number is 67.
		        Valid for -version ixnetwork.
		x   -dhcp6_echo_ia_info
		x       If true, the DHCPv6 client will send Request messages to any server that has the
		x       same IA information (addresses and options) as presented in the previous
		x       Advertisement message.
		x       Valid for -version ixnetwork.
		x   -dhcp6_reb_max_rt
		x       The maximum rebind timeout value, in seconds. The default value is 600.
		x       Valid for -version ixnetwork.
		x   -dhcp6_reb_timeout
		x       The initial rebind timeout, in seconds. The default value is 10.
		x       Valid for -version ixnetwork.
		x   -dhcp6_rel_max_rc
		x       The number of release attempts. The default value is 5.
		x       Valid for -version ixnetwork.
		x   -dhcp6_rel_timeout
		x       The initial release timeout, in seconds. The default value is 1.
		x       Valid for -version ixnetwork.
		x   -dhcp6_ren_max_rt
		x       The maximum renew request timeout value, in seconds. The default value
		x       is 600.
		x       Valid for -version ixnetwork.
		x   -dhcp6_ren_timeout
		x       The initial renew timeout, in seconds. The default value is 10.
		x       Valid for -version ixnetwork.
		x   -dhcp6_req_max_rc
		x       The number of release attempts. The default value is 5.
		x       Valid for -version ixnetwork.
		x   -dhcp6_req_max_rt
		x       The maximum request timeout value, in seconds. The default value is 30.
		x       Valid for -version ixnetwork.
		x   -dhcp6_req_timeout
		x       The initial request timeout value, in seconds. The default value is 1.
		x       Valid for -version ixnetwork.
		x   -dhcp6_sol_max_rc
		x       The maximum solicit retry attempts. The default value is 3.
		x       Valid for -version ixnetwork.
		x   -dhcp6_sol_max_rt
		x       The maximum solicit timeout value, in seconds. The default value is 120.
		x       Valid for -version ixnetwork.
		x   -dhcp6_sol_timeout
		x       The Initial solicit timeout, in seconds. The default value is 1.
		x       Valid for -version ixnetwork.
		x   -dhcp6_info_req_timeout
		x       Initial information-request timeout value, in seconds.
		x       Valid for dhcpv6 client.
		x   -dhcp6_info_req_max_rt
		x       Max Information-request timeout value, in seconds.
		x       Valid for dhcpv6 client.
		x   -dhcp6_info_req_max_rc
		x       Info request attempts.
		x       Valid for dhcpv6 client.
		x   -msg_timeout_factor
		x       The value by which the timeout will be multiplied each time the response
		x       timeout has been reached.
		x       Valid for -version ixnetwork.
		x   -msg_max_timeout
		x       The max value, in seconds, that the discover timeout can reach though Discover Timeout Factor.
		x   -override_global_setup_rate
		x       If enabled, all the rate settings defined at the global level will be
		x       overridden by the rate settings defined on this port.
		x       Valid for -version ixnetwork.
		x   -override_global_teardown_rate
		x       If enabled, all the rate settings defined at the session level will be
		x       overridden by rate settings defined on this port.
		x       Valid for -version ixnetwork.
		x   -skip_release_on_stop
		x       If enabled, the client does not send a DHCP release packet when the stop command is given.
		x       Valid for both dhcpv4 and dhcpv6 client.
		x   -renew_on_link_up
		x       Indicate to renew the active DHCP sessions after link status goes down and up.
		x       Valid for both dhcpv4 and dhcpv6 client.
		n   -accept_partial_config
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -lease_time
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -max_dhcp_msg_size
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -wait_for_completion
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -associates
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -no_write
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -release_rate_max
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -request_rate_max
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -reset
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -version
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -response_wait
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -retry_timer
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -ip_version
		x       DHCP Client type: IPv4 or IPv6.
		x   -dhcp4_arp_gw
		x       If enabled, DHCP clients ARP to find their Gateway MAC Addresses.
		x   -dhcp6_ns_gw
		x       If enabled, DHCP clients NS to find their Gateway MAC Addresses.
		
		 Return Values:
		    $::SUCCESS | $::FAILURE
		    key:status  value:$::SUCCESS | $::FAILURE
		    Error message if command returns {status 0}
		    key:log     value:Error message if command returns {status 0}
		    Port handle on which DHCP emulation was configured
		    key:handle  value:Port handle on which DHCP emulation was configured
		
		 Examples:
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    When -handle is provided with the /globals value the arguments that configure global protocol
		    setting accept both multivalue handles and simple values.
		    When -handle is provided with a a protocol stack handle or a protocol session handle, the arguments
		    that configure global settings will only accept simple values. In this situation, these arguments will
		    configure only the settings of the parent device group or the ports associated with the parent topology.
		
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
				'emulation_dhcp_config', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
