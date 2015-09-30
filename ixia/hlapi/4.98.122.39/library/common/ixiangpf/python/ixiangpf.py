import sys
import ixiautil
from ixiaerror import IxiaError
from ixiautil import Logger
from ixiahlt import IxiaHlt

class IxiaNgpf(object):
    ''' 
    Python wrapper class over the NGPF commands
    '''
    def __init__(self, ixiahlt):
        self.__logger = Logger('ixiangpf', print_timestamp=False)
        try:
            import IxNetwork
        except (ImportError, ):
            raise IxiaError(IxiaError.IXNETWORK_API_NOT_FOUND)
        self.ixiahlt = ixiahlt
        self.ixnet = IxNetwork.IxNet()
        self.__IxNetwork = IxNetwork
        self.__session_id = None
        self.NONE = "NO-OPTION-SELECTED-ECF9612A-0DA3-4096-88B3-3941A60BA0F5"

    def __ixn_call(self, func_name, *args, **kwargs):
        try:
            return getattr(self.ixnet, func_name)(*args, **kwargs)
        except (self.__IxNetwork.IxNetError, ):
            e = sys.exc_info()[1]
            raise IxiaError(IxiaError.IXNET_ERROR, e.message)

    def __get_session_status(self):
        '''
        This method blocks the client until the execution of the current command on the opened session is completed
        Notes:
            1.  The method will display intermediate messages that are available, including the command's final status.
            2.  The method returns the result (in a dict format) of the command currently executing 
        '''

        while True:
            # Below command will block until a command response or a message is available
            # We need to run it in a loop until a result is available.
            return_string = self.__ixn_call('execute', 'GetSessionStatus', self.__session_id)
            session_status = eval(return_string)

            def _print_messages(category):
                if 'messages' in session_status:
                    for (k, v) in session_status['messages'].iteritems(): 
                        self.__logger.log(category, v)

            if session_status['status'] == IxiaHlt.SUCCESS:
                # Print any status messages that are found
                _print_messages(Logger.CAT_INFO)

                if 'result' in session_status:
                    return session_status['result']
            else:
                # Command was not handled on IxNet side and we have no result
                # If there are messages received log them as warn
                _print_messages(Logger.CAT_WARN)

                # Return the user the entire dict as it might contain error info.
                return session_status

    def __set_command_parameters(self, command_id, hlpy_args):
        '''
        This method requires the following input parameters:
        1.  A dict whose keys represent attribute names and whose values represent the corresponding attribute values.
        The method uses the specified ixnetwork connection to set the sdm attributes of the specified command and
        commits the changes at the end of the call.
        '''
        for (k, v) in hlpy_args.iteritems():
            # Required format for IxN setA: objRef, -name, value
            self.__ixn_call('setAttribute', command_id, '-' + k, v)
        return self.__ixn_call('commit')

    def __execute_command(self, command_name, not_implemented_params, mandatory_params, file_params, hlpy_args):
        '''
        This method will call the specified high level API command using the specified arguments on the currently 
        opened session.  The method will also display any intermediate status messages  that are available before 
        the command execution is finished.
        '''
        legacy_result = {}

        if self.__session_id is None:
            raise IxiaError(IxiaError.HLAPI_NO_SESSION)

        # Extract the arguments that are not implemented by the ixiangpf namespace
        not_implemented_args = ixiautil.extract_specified_args(not_implemented_params, hlpy_args)
        # Extract the mandatory arguments
        mandatory_args = ixiautil.extract_specified_args(mandatory_params, hlpy_args)
        # Extract and process file arguments
        file_args = ixiautil.extract_specified_args(file_params, hlpy_args)
        self.__process_file_args(hlpy_args, file_args)
        
        if not_implemented_params and mandatory_args:
            legacy_result = getattr(self.ixiahlt, command_name)(**not_implemented_args)
            if legacy_result['status'] == IxiaHlt.FAIL:
                return legacy_result

        # Create the command node under the current session
        command_node = self.__ixn_call('add', self.__session_id, command_name)
        self.__ixn_call('commit')
        
        # Populate the command's arguments
        hlpy_args['args_to_validate'] = self.__get_args_to_validate(hlpy_args)

        # Call the ixiangpf function
        self.__set_command_parameters(command_node, hlpy_args)
        self.__ixn_call('execute', 'executeCommand', command_node)
        # Block until the command's execution completes and return the result
        ixiangpf_result = self.__get_session_status()

        if not int(ixiangpf_result['command_handled']):
            # Ignore framework's response and call the ixiahlt implementation instead
            del hlpy_args['args_to_validate']
            return getattr(self.ixiahlt, command_name)(**hlpy_args)

        # Just remove the command_handled key before returning
        del ixiangpf_result['command_handled']
        return ixiautil.merge_dicts(legacy_result, ixiangpf_result)

    def __get_port_mapping(self):
        ''' Accessor for the GetPortMapping util '''
        mapping_string = self.ixiahlt.ixiatcl._eval('GetPortMapping')
        return mapping_string[1:-1]

    def __requires_hlapi_connect(self):
        ''' Accessor for the RequiresHlapiConnect util '''
        return self.ixiahlt.ixiatcl._eval('RequiresHlapiConnect')
    
    def __get_args_to_validate(self, hlpy_args):
        '''
        This method accepts the following input parameter:
         1. A dict whose keys represent attribute names and whose values represent the corresponding attribute values.
        The method parses the references and create a string that can be passed to the HLAPI in order to validate the
        corresponding arguments.
        '''
        tcl_string = self.ixiahlt.ixiatcl._tcl_flatten(hlpy_args, key_prefix='-')
        return tcl_string

    def __process_file_args(self, hlpy_args, file_args):
        '''
        This method takes the file_args dict and copies all files to the  IxNetwork server.
        The original file names are then replaced with the new locations from the server.
        '''
        server_file_args = {}
        for (i, (k, v)) in enumerate(file_args.iteritems()):
            server_file_args[k] = "pythonServerFile%s" % i
            client_stream = self.__ixn_call('readFrom', v)
            server_stream = self.__ixn_call('writeTo', server_file_args[k], '-ixNetRelative', '-overwrite')
            self.__ixn_call('execute', 'copyFile', client_stream, server_stream)
        hlpy_args.update(server_file_args)

# attach all hlapi_framework commands
import ixiangpf_commands.cleanup_session
import ixiangpf_commands.connect
import ixiangpf_commands.dhcp_client_extension_config
import ixiangpf_commands.dhcp_extension_stats
import ixiangpf_commands.dhcp_server_extension_config
import ixiangpf_commands.emulation_ancp_config
import ixiangpf_commands.emulation_ancp_control
import ixiangpf_commands.emulation_ancp_stats
import ixiangpf_commands.emulation_ancp_subscriber_lines_config
import ixiangpf_commands.emulation_bgp_config
import ixiangpf_commands.emulation_bgp_control
import ixiangpf_commands.emulation_bgp_info
import ixiangpf_commands.emulation_bgp_route_config
import ixiangpf_commands.emulation_dhcp_config
import ixiangpf_commands.emulation_dhcp_control
import ixiangpf_commands.emulation_dhcp_group_config
import ixiangpf_commands.emulation_dhcp_server_config
import ixiangpf_commands.emulation_dhcp_server_control
import ixiangpf_commands.emulation_dhcp_server_stats
import ixiangpf_commands.emulation_dhcp_stats
import ixiangpf_commands.emulation_igmp_config
import ixiangpf_commands.emulation_igmp_control
import ixiangpf_commands.emulation_igmp_group_config
import ixiangpf_commands.emulation_igmp_info
import ixiangpf_commands.emulation_igmp_querier_config
import ixiangpf_commands.emulation_isis_config
import ixiangpf_commands.emulation_isis_control
import ixiangpf_commands.emulation_isis_info
import ixiangpf_commands.emulation_isis_network_group_config
import ixiangpf_commands.emulation_lacp_control
import ixiangpf_commands.emulation_lacp_info
import ixiangpf_commands.emulation_lacp_link_config
import ixiangpf_commands.emulation_ldp_config
import ixiangpf_commands.emulation_ldp_control
import ixiangpf_commands.emulation_ldp_info
import ixiangpf_commands.emulation_ldp_route_config
import ixiangpf_commands.emulation_mld_config
import ixiangpf_commands.emulation_mld_control
import ixiangpf_commands.emulation_mld_group_config
import ixiangpf_commands.emulation_mld_info
import ixiangpf_commands.emulation_mld_querier_config
import ixiangpf_commands.emulation_multicast_group_config
import ixiangpf_commands.emulation_multicast_source_config
import ixiangpf_commands.emulation_ospf_config
import ixiangpf_commands.emulation_ospf_control
import ixiangpf_commands.emulation_ospf_info
import ixiangpf_commands.emulation_ospf_lsa_config
import ixiangpf_commands.emulation_ospf_network_group_config
import ixiangpf_commands.emulation_ospf_topology_route_config
import ixiangpf_commands.emulation_pim_config
import ixiangpf_commands.emulation_pim_control
import ixiangpf_commands.emulation_pim_group_config
import ixiangpf_commands.emulation_pim_info
import ixiangpf_commands.emulation_vxlan_config
import ixiangpf_commands.emulation_vxlan_control
import ixiangpf_commands.emulation_vxlan_stats
import ixiangpf_commands.get_execution_log
import ixiangpf_commands.interface_config
import ixiangpf_commands.internal_compress_overlays
import ixiangpf_commands.internal_legacy_control
import ixiangpf_commands.ixnetwork_traffic_control
import ixiangpf_commands.ixvm_config
import ixiangpf_commands.ixvm_control
import ixiangpf_commands.ixvm_info
import ixiangpf_commands.l2tp_config
import ixiangpf_commands.l2tp_control
import ixiangpf_commands.l2tp_stats
import ixiangpf_commands.legacy_commands
import ixiangpf_commands.multivalue_config
import ixiangpf_commands.multivalue_subset_config
import ixiangpf_commands.network_group_config
import ixiangpf_commands.pppox_config
import ixiangpf_commands.pppox_control
import ixiangpf_commands.pppox_stats
import ixiangpf_commands.protocol_info
import ixiangpf_commands.ptp_globals_config
import ixiangpf_commands.ptp_options_config
import ixiangpf_commands.ptp_over_ip_config
import ixiangpf_commands.ptp_over_ip_control
import ixiangpf_commands.ptp_over_ip_stats
import ixiangpf_commands.ptp_over_mac_config
import ixiangpf_commands.ptp_over_mac_control
import ixiangpf_commands.ptp_over_mac_stats
import ixiangpf_commands.test_control
import ixiangpf_commands.tlv_config
import ixiangpf_commands.topology_config
import ixiangpf_commands.traffic_handle_translator
import ixiangpf_commands.traffic_l47_config
import ixiangpf_commands.traffic_tag_config
