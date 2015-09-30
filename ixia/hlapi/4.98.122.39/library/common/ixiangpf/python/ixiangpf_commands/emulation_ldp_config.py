# -*- coding: utf-8 -*-

import sys
from ixiaerror import IxiaError
from ixiangpf import IxiaNgpf
from ixiautil import PartialClass, make_hltapi_fail

class IxiaNgpf(PartialClass, IxiaNgpf):
	def emulation_ldp_config(self, **kwargs):
		r'''
		#Procedure Header
		 Name:
		    emulation_ldp_config
		
		 Description:
		    This procedure configures LDP simulated routers and the router interfaces.
		
		 Synopsis:
		    emulation_ldp_config
		        [-handle                         ANY]
		        [-mode                           CHOICES create
		                                         CHOICES delete
		                                         CHOICES disable
		                                         CHOICES enable
		                                         CHOICES modify]
		n       [-port_handle                    ANY]
		        [-label_adv                      CHOICES unsolicited on_demand
		                                         DEFAULT unsolicited]
		n       [-peer_discovery                 ANY]
		        [-count                          NUMERIC
		                                         DEFAULT 1]
		n       [-interface_handle               ANY]
		n       [-interface_mode                 ANY]
		        [-intf_ip_addr                   IPV4
		                                         DEFAULT 0.0.0.0]
		        [-intf_prefix_length             RANGE 1-32
		                                         DEFAULT 24]
		        [-intf_ip_addr_step              IPV4
		                                         DEFAULT 0.0.1.0]
		x       [-loopback_ip_addr               IPV4]
		x       [-loopback_ip_addr_step          IPV4
		x                                        DEFAULT 0.0.1.0]
		        [-lsr_id                         IPV4]
		        [-label_space                    RANGE 0-65535]
		        [-lsr_id_step                    IPV4
		                                         DEFAULT 0.0.1.0]
		        [-mac_address_init               MAC]
		x       [-mac_address_step               MAC
		x                                        DEFAULT 0000.0000.0001]
		        [-remote_ip_addr                 IPV4]
		        [-remote_ip_addr_step            IPV4]
		        [-hello_interval                 RANGE 0-65535]
		        [-hello_hold_time                RANGE 0-65535]
		        [-keepalive_interval             RANGE 0-65535]
		        [-keepalive_holdtime             RANGE 0-65535]
		        [-discard_self_adv_fecs          CHOICES 0 1]
		x       [-vlan                           CHOICES 0 1
		x                                        DEFAULT 0]
		        [-vlan_id                        RANGE 0-4095]
		        [-vlan_id_mode                   CHOICES fixed increment
		                                         DEFAULT increment]
		        [-vlan_id_step                   RANGE 0-4096
		                                         DEFAULT 1]
		        [-vlan_user_priority             RANGE 0-7
		                                         DEFAULT 0]
		n       [-vpi                            ANY]
		n       [-vci                            ANY]
		n       [-vpi_step                       ANY]
		n       [-vci_step                       ANY]
		n       [-atm_encapsulation              ANY]
		x       [-auth_mode                      CHOICES null md5
		x                                        DEFAULT null]
		x       [-auth_key                       ANY]
		n       [-bfd_registration               ANY]
		n       [-bfd_registration_mode          ANY]
		n       [-atm_range_max_vpi              ANY]
		n       [-atm_range_min_vpi              ANY]
		n       [-atm_range_max_vci              ANY]
		n       [-atm_range_min_vci              ANY]
		n       [-atm_vc_dir                     ANY]
		n       [-enable_explicit_include_ip_fec ANY]
		n       [-enable_l2vpn_vc_fecs           ANY]
		n       [-enable_remote_connect          ANY]
		n       [-enable_vc_group_matching       ANY]
		x       [-gateway_ip_addr                IPV4]
		x       [-gateway_ip_addr_step           IPV4
		x                                        DEFAULT 0.0.1.0]
		x       [-graceful_restart_enable        CHOICES 0 1]
		n       [-no_write                       ANY]
		x       [-reconnect_time                 RANGE 0-300000]
		x       [-recovery_time                  RANGE 0-300000]
		x       [-reset                          FLAG]
		x       [-targeted_hello_hold_time       RANGE 0-65535]
		x       [-targeted_hello_interval        RANGE 0-65535]
		n       [-override_existence_check       ANY]
		n       [-override_tracking              ANY]
		n       [-cfi                            ANY]
		n       [-config_seq_no                  ANY]
		n       [-egress_label_mode              ANY]
		n       [-label_start                    ANY]
		n       [-label_step                     ANY]
		n       [-label_type                     ANY]
		n       [-loop_detection                 ANY]
		n       [-max_lsps                       ANY]
		n       [-max_pdu_length                 ANY]
		n       [-message_aggregation            ANY]
		n       [-mtu                            ANY]
		n       [-path_vector_limit              ANY]
		n       [-timeout                        ANY]
		n       [-transport_ip_addr              ANY]
		n       [-user_priofity                  ANY]
		n       [-vlan_cfi                       ANY]
		x       [-peer_count                     NUMERIC]
		x       [-interface_name                 ALPHA]
		x       [-interface_multiplier           NUMERIC]
		x       [-interface_active               CHOICES 0 1]
		x       [-target_name                    ALPHA]
		x       [-target_multiplier              NUMERIC]
		x       [-target_auth_key                ANY]
		x       [-initiate_targeted_hello        CHOICES 0 1]
		x       [-target_auth_mode               CHOICES null md5]
		x       [-target_active                  CHOICES 0 1]
		x       [-router_name                    ALPHA]
		x       [-router_multiplier              NUMERIC]
		x       [-router_active                  CHOICES 0 1]
		x       [-targeted_peer_name             ALPHA]
		x       [-start_rate_scale_mode          CHOICES port device_group
		x                                        DEFAULT port]
		x       [-start_rate_enabled             CHOICES 0 1]
		x       [-start_rate                     NUMERIC]
		x       [-start_rate_interval            NUMERIC]
		x       [-stop_rate_scale_mode           CHOICES port device_group
		x                                        DEFAULT port]
		x       [-stop_rate_enabled              CHOICES 0 1]
		x       [-stop_rate                      NUMERIC]
		x       [-stop_rate_interval             NUMERIC]
		x       [-lpb_interface_name             ALPHA]
		x       [-lpb_interface_active           CHOICES 0 1]
		
		 Arguments:
		    -handle
		        A LDP handle returned from this procedure and now being used when
		        the -mode is anything but create.
		        When -handle is provided with the /globals value the arguments that configure global protocol
		        setting accept both multivalue handles and simple values.
		        When -handle is provided with a a protocol stack handle or a protocol session handle, the arguments
		        that configure global settings will only accept simple values. In this situation, these arguments will
		        configure only the settings of the parent device group or the ports associated with the parent topology.
		    -mode
		        Which mode is being performed.All but create require the use of
		        the -handle option.
		n   -port_handle
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -label_adv
		        The mode by which the simulated router advertises its FEC ranges.
		n   -peer_discovery
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -count
		        Defines the number of LDP interfaces to create.
		n   -interface_handle
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -interface_mode
		n       This argument defined by Cisco is not supported for NGPF implementation.
		    -intf_ip_addr
		        Interface IP address of the LDP session router. Mandatory when -mode is create.
		        When using IxTclNetwork (new API) this parameter can be omitted if -interface_handle is used.
		        For IxTclProtocol (old API), when -mode is modify and one of the layer
		        2-3 parameters (-intf_ip_addr, -gateway_ip_addr, -loopback_ip_addr, etc)
		        needs to be modified, the emulation_ldp_config command must be provided
		        with the entire list of layer 2-3 parameters. Otherwise they will be
		        set to their default values.
		    -intf_prefix_length
		        Prefix length on the interface.
		    -intf_ip_addr_step
		        Define interface IP address for multiple sessions.
		        Valid only for -mode create.
		x   -loopback_ip_addr
		x       The IP address of the unconnected protocol interface that will be
		x       created behind the intf_ip_addr interface. The loopback(unconnected)
		x       interface is the one that will be used for LDP emulation. This type
		x       of interface is needed when creating extended Martini sessions.
		x   -loopback_ip_addr_step
		x       Valid only for -mode create.
		x       The incrementing step for the loopback_ip_addr parameter.
		    -lsr_id
		        The ID of the router to be emulated.
		    -label_space
		        The label space identifier for the interface.
		    -lsr_id_step
		        Used to define the lsr_id step for multiple interface creations.
		        Valid only for -mode create.
		    -mac_address_init
		        MAC address to be used for the first session.
		x   -mac_address_step
		x       Valid only for -mode create.
		x       The incrementing step for the MAC address configured on the dirrectly
		x       connected interfaces. Valid only when IxNetwork Tcl API is used.
		    -remote_ip_addr
		        The IPv4 address of a targeted peer.
		    -remote_ip_addr_step
		        When creating multiple sessions and using the -remote_ip_addr, tells
		        how to increment between sessions.
		        Valid only for -mode create.
		    -hello_interval
		        The amount of time, expressed in seconds, between transmitted
		        HELLO messages.
		    -hello_hold_time
		        The amount of time, expressed in seconds, that an LDP adjacency
		        will be maintained in the absence of a HELLO message.
		    -keepalive_interval
		        The amount of time, expressed in seconds, between keep-alive messages
		        sent from simulated routers to their adjacency in the absence of
		        other PDUs sent to the adjacency.
		    -keepalive_holdtime
		        The amount of time, expressed in seconds, that an LDP adjacency
		        will be maintained in the adbsence of a PDU received from the adjacency.
		    -discard_self_adv_fecs
		        Discard learned labels from the DUT that match any of the enabled
		        configured IPv4 FEC ranges.This flag is only set when LDP is
		        started.If it is to be changed later, LDP should be stopped,
		        the value changed and then restart LDP.
		x   -vlan
		x       Enables vlan on the directly connected LDP router interface.
		x       Valid options are: 0 - disable, 1 - enable.
		x       This option is valid only when -mode is create or -mode is modify
		x       and -handle is a LDP router handle.
		x       This option is available only when IxNetwork tcl API is used.
		    -vlan_id
		        VLAN ID for protocol interface.
		    -vlan_id_mode
		        For multiple neighbor configuration, configures the VLAN ID mode.
		    -vlan_id_step
		        Valid only for -mode create.
		        Defines the step for the VLAN ID when the VLAN ID mode is increment.
		        When vlan_id_step causes the vlan_id value to exceed its maximum value the
		        increment will be done modulo <number of possible vlan ids>.
		        Examples: vlan_id = 4094; vlan_id_step = 2-> new vlan_id value = 0
		        vlan_id = 4095; vlan_id_step = 11 -> new vlan_id value = 10
		    -vlan_user_priority
		        VLAN user priority assigned to protocol interface.
		n   -vpi
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -vci
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -vpi_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -vci_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -atm_encapsulation
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -auth_mode
		x       Select the type of cryptographic authentication to be used for this targeted peer.
		x   -auth_key
		x       Active only when "md5" is selected in the Authentication Type field.
		x       (String) Enter a value to be used as a "secret" MD5 key for authentication.
		x       The maximum length allowed is 255 characters.
		x       One MD5 key can be configured per interface.
		n   -bfd_registration
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -bfd_registration_mode
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -atm_range_max_vpi
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -atm_range_min_vpi
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -atm_range_max_vci
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -atm_range_min_vci
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -atm_vc_dir
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -enable_explicit_include_ip_fec
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -enable_l2vpn_vc_fecs
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -enable_remote_connect
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -enable_vc_group_matching
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -gateway_ip_addr
		x       Gives the gateway IP address for the protocol interface that will
		x       be created for use by the simulated routers.
		x   -gateway_ip_addr_step
		x       Valid only for -mode create.
		x       Gives the step for the gateway IP address.
		x   -graceful_restart_enable
		x       Will enable graceful restart (HA) on the LDP neighbor.
		n   -no_write
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -reconnect_time
		x       (in milliseconds) This Fault Tolerant (FT) Reconnect Timer value is
		x       advertised in the FT Session TLV in the Initialization message sent by
		x       a neighbor LSR. It is a request sent by an LSR to its neighbor(s) - in
		x       the event that the receiving neighbor detects that the LDP session has
		x       failed, the receiver should maintain MPLS forwarding state and wait
		x       for the sender to perform a restart of the control plane and LDP
		x       protocol. If the value = 0, the sender is indicating that it will not
		x       preserve its MPLS forwarding state across the restart.
		x       If -graceful_restart_enable is set.
		x   -recovery_time
		x       If -graceful_restart_enable is set; (in milliseconds)
		x       The restarting LSR is advertising the amount of time that it will
		x       retain its MPLS forwarding state. This time period begins when it
		x       sends the restart Initialization message, with the FT session TLV,
		x       to the neighbor LSRs (to re-establish the LDP session). This timer
		x       allows the neighbors some time to resync the LSPs in an orderly
		x       manner. If the value = 0, it means that the restarting LSR was not
		x       able to preserve the MPLS forwarding state.
		x   -reset
		x       If set, then all existing simulated routers will be removed
		x       before creating a new one.
		x   -targeted_hello_hold_time
		x       The amount of time, expressed in seconds, that an LDP adjacency will
		x       be maintained for a targeted peer in the absence of a HELLO message.
		x   -targeted_hello_interval
		x       The amount of time, expressed in seconds, between transmitted HELLO
		x       messages to targeted peers.
		n   -override_existence_check
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -override_tracking
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -cfi
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -config_seq_no
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -egress_label_mode
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -label_start
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -label_step
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -label_type
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -loop_detection
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -max_lsps
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -max_pdu_length
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -message_aggregation
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -mtu
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -path_vector_limit
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -timeout
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -transport_ip_addr
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -user_priofity
		n       This argument defined by Cisco is not supported for NGPF implementation.
		n   -vlan_cfi
		n       This argument defined by Cisco is not supported for NGPF implementation.
		x   -peer_count
		x       Peer Count(multiplier)
		x   -interface_name
		x       NOT DEFINED
		x   -interface_multiplier
		x       number of layer instances per parent instance (multiplier)
		x   -interface_active
		x       Flag.
		x   -target_name
		x       NOT DEFINED
		x   -target_multiplier
		x       number of this object per parent object
		x   -target_auth_key
		x       MD5Key
		x   -initiate_targeted_hello
		x       Initiate Targeted Hello
		x   -target_auth_mode
		x       Authentication
		x   -target_active
		x       Flag.
		x   -router_name
		x       NOT DEFINED
		x   -router_multiplier
		x       number of layer instances per parent instance (multiplier)
		x   -router_active
		x       Flag.
		x   -targeted_peer_name
		x       Targted Peer Name.
		x   -start_rate_scale_mode
		x       Indicates whether the control is specified per port or per device group
		x   -start_rate_enabled
		x       Enabled
		x   -start_rate
		x       Number of times an action is triggered per time interval
		x   -start_rate_interval
		x       Time interval used to calculate the rate for triggering an action (rate = count/interval)
		x   -stop_rate_scale_mode
		x       Indicates whether the control is specified per port or per device group
		x   -stop_rate_enabled
		x       Enabled
		x   -stop_rate
		x       Number of times an action is triggered per time interval
		x   -stop_rate_interval
		x       Time interval used to calculate the rate for triggering an action (rate = count/interval)
		x   -lpb_interface_name
		x       Name of NGPF element
		x   -lpb_interface_active
		x       Flag.
		
		 Return Values:
		    A list containing the ipv4 loopback protocol stack handles that were added by the command (if any).
		x   key:ipv4_loopback_handle            value:A list containing the ipv4 loopback protocol stack handles that were added by the command (if any).
		    A list containing the ipv4 protocol stack handles that were added by the command (if any).
		x   key:ipv4_handle                     value:A list containing the ipv4 protocol stack handles that were added by the command (if any).
		    A list containing the ethernet protocol stack handles that were added by the command (if any).
		x   key:ethernet_handle                 value:A list containing the ethernet protocol stack handles that were added by the command (if any).
		    A list containing the ldp basic router protocol stack handles that were added by the command (if any).
		x   key:ldp_basic_router_handle         value:A list containing the ldp basic router protocol stack handles that were added by the command (if any).
		    A list containing the ldp connected interface protocol stack handles that were added by the command (if any).
		x   key:ldp_connected_interface_handle  value:A list containing the ldp connected interface protocol stack handles that were added by the command (if any).
		    A list containing the ldp targeted router protocol stack handles that were added by the command (if any).
		x   key:ldp_targeted_router_handle      value:A list containing the ldp targeted router protocol stack handles that were added by the command (if any).
		    $::SUCCESS | $::FAILURE
		    key:status                          value:$::SUCCESS | $::FAILURE
		    If status is failure, detailed information provided.
		    key:log                             value:If status is failure, detailed information provided.
		    List of LDP routers created Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		    key:handle                          value:List of LDP routers created Please note that this key will be omitted if the current session or command were run with -return_detailed_handles 0.
		
		 Examples:
		    See files starting with LDP_ in the Samples subdirectory.  Also see some of the L2VPN, L3VPN, MPLS, and MVPN sample files for further examples of the LDP usage.
		    See the LDP example in Appendix A, "Example APIs," for one specific example usage.
		
		 Sample Input:
		
		 Sample Output:
		
		 Notes:
		    Coded versus functional specification.
		    If one wants to modify the ineterface to which the protocol interface is
		    connected, one has to specify the correct MAC address of that interface.
		    If this requirement is not fulfilled, the interface is not guaranteed to
		    be correctly determined because more interfaces can have the exact same
		    configuration.
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
				'emulation_ldp_config', 
				not_implemented_params, mandatory_params, file_params, 
				hlpy_args
			)
		except (IxiaError, ):
			e = sys.exc_info()[1]
			return make_hltapi_fail(e.message)
