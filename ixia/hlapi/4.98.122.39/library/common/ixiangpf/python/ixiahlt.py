#!/usr/bin/env python

import os
import os.path
import sys
from glob import glob
from ixiaerror import *
from ixiautil import *
from Tkinter import TclError

class IxiaHlt(object):
    ''' 
    Python wrapper class over the HLTAPI commands 
    __init__ kwargs:
        ixia_version='specific HLTSET to use'
            The environment variable IXIA_VERSION has precedence.
        hltapi_path_override='path to a specific HLTAPI installation to use'
        tcl_packages_path='path to external TCL interp path from which to load additional packages'

        Defaults:
            ixia_version:
                on windows: latest HLTAPI set taken from Ixia TCL package
                on unix: latest HLTAPI set taken from Ixia TCL package
            hltapi_path_override: 
                on windows: latest HLTAPI version installed in Ixia folder
                on unix: none
            tcl_packages_path:
                on windows: path of packages from the latest TCL version installed in Ixia folder
                on unix: none

        Examples:
            ixia_version='HLTSET165'
            hltapi_path_override='C:\Program Files (x86)\Ixia\hltapi\4.90.0.16'
            tcl_packages_path='C:\Program Files (x86)\Ixia\Tcl\8.5.12.0\lib\teapot\package\win32-ix86\lib'
    '''
    SUCCESS = '1'
    FAIL = '0'
    
    def __init__(self, ixiatcl, **kwargs):
        # overrides
        self.hltapi_path_override = kwargs.get('hltapi_path_override', None)
        self.tcl_packages_path = kwargs.get('tcl_packages_path', None)

        self.__logger = Logger('ixiahlt', print_timestamp=False)

        self.ixiatcl = ixiatcl
        self.__prepare_tcl_interp(self.ixiatcl)

        # check whether ixia_version param is passed
        # env variable takes precedence
        ixia_version = kwargs.get('ixia_version', None)
        if ixia_version:
            if not os.environ.has_key('IXIA_VERSION'):
                os.environ['IXIA_VERSION'] = ixia_version
            else:
                self.__logger.warn('IXIA_VERSION specified by env; ignoring parameter ixia_version')
        
        if os.name == 'nt':
            if os.getenv('IXIA_PY_DEV'):
                self.__logger.debug('!! IXIA_PY_DEV enabled => Dev mode')

                # dev access to hltapi version
                hlt_init_glob = 'C:/Program Files*/Ixia/hltapi/4.90.0.16/TclScripts/bin/hlt_init.tcl'
                hlt_init_files = glob(hlt_init_glob)
                if not len(hlt_init_files):
                    raise IxiaError(IxiaError.HLTAPI_NOT_FOUND, additional_info='Tried glob %s' % hlt_init_glob)

                hlt_init_path = hlt_init_files[0]
                self.__logger.debug('!! using %s' % hlt_init_path)
            else:
                tcl_scripts_path = self.__get_hltapi_path()
                # cut /lib/hltapi
                for i in range(2):
                    tcl_scripts_path = os.path.dirname(tcl_scripts_path)
                hlt_init_path = os.path.join(tcl_scripts_path, 'bin', 'hlt_init.tcl')

            try:
                # sourcing this might throw errors
                self.ixiatcl.source(self.ixiatcl.quote_tcl_string(hlt_init_path))
            except (TclError,):
                raise IxiaError(IxiaError.HLTAPI_NOT_PREPARED, additional_info=ixiatcl.tcl_error_info())
        else:
            # path to ixia package, dependecies should be specified in tcl ::auto_path
            self.ixiatcl.lappend('::auto_path', self.__get_hltapi_path())
        
        try:
            self.ixiatcl.package('require', 'Ixia')
        except (TclError,):
            raise IxiaError(IxiaError.HLTAPI_NOT_INITED, additional_info=ixiatcl.tcl_error_info())
        
        try:
            pythonIxNetworkLib = ixiatcl._eval("set env(IXTCLNETWORK_[ixNet getVersion])")
            if os.name == 'nt':
                #cut  /TclScripts/lib/IxTclNetwork
                for i in range(3):
                    pythonIxNetworkLib = os.path.dirname(pythonIxNetworkLib)
                pythonIxNetworkLib = os.path.join(pythonIxNetworkLib, 'api', 'python')
            else:
                pythonIxNetworkLib = os.path.dirname(pythonIxNetworkLib)
                pythonIxNetworkLib = os.path.join(pythonIxNetworkLib, 'PythonApi')
            sys.path.append(pythonIxNetworkLib)

        except (TclError,):
            raise IxiaError(IxiaError.IXNETWORK_API_NOT_FOUND, additional_info=ixiatcl.tcl_error_info())

        self.__build_hltapi_commands()

    def __get_bitness(self):
        machine = '32bit'
        if os.name == 'nt' and sys.version_info[:2] < (2,7):
            machine = os.environ.get('PROCESSOR_ARCHITEW6432', os.environ.get('PROCESSOR_ARCHITECTURE', ''))
        else:
            import platform
            machine = platform.machine()

        mapping = {
            'AMD64': '64bit', 
            'x86_64': '64bit', 
            'i386': '32bit', 
            'x86': '32bit'
        }
        return mapping[machine]

    def __get_reg_subkeys(self, regkey):
        from _winreg import EnumKey

        keys = []
        try:
            i = 0
            while True:
                matchObj = re.match( r'\d+\.\d+\.\d+\.\d+', EnumKey(regkey, i), re.M|re.I)
                if matchObj:
                    keys.append(EnumKey(regkey, i))
                i += 1
        except (WindowsError,):
            e = sys.exc_info()[1]
            # 259 is no more subkeys
            if e.winerror != 259:
                raise e

        return keys

    def __get_reg_product_path(self, product, force_version=None):
        from _winreg import OpenKey, QueryValueEx
        from _winreg import HKEY_LOCAL_MACHINE, KEY_READ

        wowtype = ''
        if self.__get_bitness() == '64bit':
            wowtype = 'Wow6432Node'
        
        key_path = '\\'.join(['SOFTWARE', wowtype, 'Ixia Communications', product])
        try:
            with OpenKey(HKEY_LOCAL_MACHINE, key_path, KEY_READ) as key:
                version_keys = version_sorted(self.__get_reg_subkeys(key))
                if not len(version_keys):
                    return None

                version_key = version_keys[-1]
                if force_version:
                    if force_version in version_keys:
                        version_key = force_version
                    else:
                        return None

                info_key_path = '\\'.join([key_path, version_key, 'InstallInfo'])
                with OpenKey(HKEY_LOCAL_MACHINE, info_key_path, KEY_READ) as info_key:
                    return QueryValueEx(info_key, 'HOMEDIR')[0]
        except (WindowsError,):
            e = sys.exc_info()[1]
            # WindowsError: [Error 2] The system cannot find the file specified
            if e.winerror == 2:
                raise IxiaError(IxiaError.WINREG_NOT_FOUND, 'Product name: %s' % product)
            raise e

        return None

    def __get_tcl_packages_path(self):
        if self.tcl_packages_path:
            return self.tcl_packages_path

        if os.name == 'nt':
            tcl_path = self.__get_reg_product_path('Tcl')
            if not tcl_path:
                raise IxiaError(IxiaError.TCL_NOT_FOUND)
            
            return os.path.join(tcl_path, 'lib\\teapot\\package\\win32-ix86\\lib')
        else:
            #TODO
            raise NotImplementedError()

    def __get_hltapi_path(self):
        if self.hltapi_path_override:
            return self.hltapi_path_override

        hltapi_path = os.path.realpath(__file__)
        # cut /library/common/ixiangpf/python/ixiahlt.py
        for i in range(5):
            hltapi_path = os.path.dirname(hltapi_path)

        return hltapi_path

    def __prepare_tcl_interp(self, ixiatcl):
        ''' 
        Sets any TCL interp variables, commands or other items
        specifically needed by HLTAPI
        '''
        if os.name == 'nt':
            tcl_packages_path = self.__get_tcl_packages_path()
            ixiatcl.lappend('::auto_path', self.ixiatcl.quote_tcl_string(tcl_packages_path))

        # hltapi tries to use some wish console things; invalidate them -ae
        ixiatcl.proc('console', 'args', '{}')
        ixiatcl.proc('wm', 'args', '{}')
        ixiatcl.set('::tcl_interactive', '0')

        # this function generates unique variables names
        # they are needed when parsing hlt return values -ae
        ixiatcl.namespace('eval', '::tcl::tmp', '''{
            variable global_counter 0
            namespace export unique_name
        }''')
        ixiatcl.proc('tcl::tmp::unique_name', 'args', '''{
            variable global_counter
            set pattern "[namespace current]::unique%s" 
            set result {}

            set num [llength $args]
            set num [expr {($num)? $num : 1}]

            for {set i 0} {$i < $num} {incr i} {
                set name [format $pattern [incr global_counter]]
                while {
                    [info exists $name] ||
                    [namespace exists $name] ||
                    [llength [info commands $name]]
                } {
                    set name [format $pattern [incr global_counter]]
                }
                lappend result $name
            }

            if { [llength $args] } {
                foreach varname $args name $result {
                    uplevel set $varname $name
                }
            }
            return [lindex $result 0]
        }''')

    def __build_hltapi_commands(self):
        ''' Adds all supported HLTAPI commands as methods to this class '''
        ixia_ns = '::ixia::'
        command_list = [
            {'name': 'connect', 'namespace': ixia_ns, 'parse_io': True},
            {'name': 'cleanup_session', 'namespace': ixia_ns, 'parse_io': True},
            {'name': 'reboot_port_cpu', 'namespace': ixia_ns, 'parse_io': True},

            {'name': 'convert_vport_to_porthandle', 'namespace': ixia_ns, 'parse_io': True},
            {'name': 'convert_porthandle_to_vport', 'namespace': ixia_ns, 'parse_io': True},
            {'name': 'convert_portname_to_vport', 'namespace': ixia_ns, 'parse_io': True},

            {'name': 'session_info', 'namespace': ixia_ns, 'parse_io': True},
            {'name': 'device_info', 'namespace': ixia_ns, 'parse_io': True},
            {'name': 'vport_info', 'namespace': ixia_ns, 'parse_io': True},
            
            {'name': 'interface_config', 'namespace': ixia_ns, 'parse_io': True},
            {'name': 'interface_control', 'namespace': ixia_ns, 'parse_io': True},
            {'name': 'interface_stats', 'namespace': ixia_ns, 'parse_io': True},

            {'name': 'traffic_config', 'namespace': ixia_ns, 'parse_io': True},
            {'name': 'traffic_control', 'namespace': ixia_ns, 'parse_io': True},
            {'name': 'traffic_stats', 'namespace': ixia_ns, 'parse_io': True},
            {'name': 'get_nodrop_rate', 'namespace': ixia_ns, 'parse_io': True},
            {'name': 'find_in_csv', 'namespace': ixia_ns, 'parse_io': True},
            
            {'name': 'test_control', 'namespace': ixia_ns, 'parse_io': True},
            {'name': 'test_stats', 'namespace': ixia_ns, 'parse_io': True},

            {'name': 'packet_config_buffers', 'namespace': ixia_ns, 'parse_io': True},
            {'name': 'packet_config_filter', 'namespace': ixia_ns, 'parse_io': True},
            {'name': 'packet_config_triggers', 'namespace': ixia_ns, 'parse_io': True},
            {'name': 'packet_control', 'namespace': ixia_ns, 'parse_io': True},
            {'name': 'packet_stats', 'namespace': ixia_ns, 'parse_io': True},
            {'name': 'uds_config', 'namespace': ixia_ns, 'parse_io': True},
            {'name': 'uds_filter_pallette_config', 'namespace': ixia_ns, 'parse_io': True},
            {'name': 'capture_packets', 'namespace': ixia_ns, 'parse_io': True},
            {'name': 'get_packet_content', 'namespace': ixia_ns, 'parse_io': True},

            {'name': 'increment_ipv4_address', 'namespace': ixia_ns, 'parse_io': False},
            {'name': 'increment_ipv6_address', 'namespace': ixia_ns, 'parse_io': False},
        ]

        def convert_in_kwargs(args, kwargs):
            return [self.ixiatcl._tcl_flatten(kwargs, '-')]

        def convert_out_list(tcl_string):
            if tcl_string == '':
                return None
            ret = self.ixiatcl.convert_tcl_list(tcl_string)
            if len(ret) == 1:
                return ret[0]
            return ret

        def convert_out_dict(tcl_string):
            # populate a tcl keyed list variable
            unique_list_name = self.ixiatcl._eval('::tcl::tmp::unique_name')
            unique_catch_name = self.ixiatcl._eval('::tcl::tmp::unique_name')
            self.ixiatcl.set(unique_list_name, self.ixiatcl.quote_tcl_string(tcl_string))

            ret = {}
            for key in self.ixiatcl.convert_tcl_list(self.ixiatcl._eval('keylkeys %s' % unique_list_name)):
                qualified_key = self.ixiatcl.quote_tcl_string(key)
                key_value = self.ixiatcl._eval('keylget %s %s' % (unique_list_name, qualified_key))

                catch_result = self.ixiatcl._eval(
                    'catch {{keylkeys {0} {1}}} {2}'.format(
                        unique_list_name, 
                        qualified_key, 
                        unique_catch_name
                    )
                )
                if catch_result == '1' or self.ixiatcl.llength('$' + unique_catch_name) == '0':
                    # no more subkeys
                    ret[key] = key_value
                else:
                    if '\\' in key_value and "{" not in key_value:
                        # Tcl BUG -> Whe value conains \ keylkeys will wronfully report that element is a keylist
                        # even when is not. A keylist always has a { and }, so if { is not present, but \ is assume
                        # the value is not a keylist
                        ret[key] = key_value
                    else:
                        ret[key] = convert_out_dict(key_value)

            # clear any stale errorInfo from the above catches
            self.ixiatcl.set('::errorInfo', '{}')
            
            return ret

        for command in command_list:
            # note: this may change in the future if alternate conversions are needed -ae
            convert_in = None
            convert_out = convert_out_list
            if command['parse_io']:
                convert_in = convert_in_kwargs
                convert_out = convert_out_dict

            method = self.ixiatcl._make_tcl_method(
                command['namespace'] + command['name'],
                conversion_in=convert_in, 
                conversion_out=convert_out,
                eval_getter=lambda self_hlt: self_hlt.ixiatcl._eval
            )
            setattr(self.__class__, command['name'], method)
