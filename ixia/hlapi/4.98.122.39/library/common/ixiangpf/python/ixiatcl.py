#!/usr/bin/env python

import Tkinter
from ixiautil import Logger

class IxiaTcl(object):
    ''' 
    Python wrapper class over Tkinter tcl interp 
    __init__ kwargs:
        tcl_autopath=['list of items to append to the TCL interp ::auto_path']

        Defaults:
            on windows: []
            on unix: []

        Examples:
            tcl_autopath=[
                '/home/smurf/IXIA_LATEST/ixos/lib',
                '/home/smurf/IXIA_LATEST/ixn/IxTclProtocol',
                '/home/smurf/IXIA_LATEST/ixn/IxTclNetwork'
            ]
    '''
    def __init__(self, **kwargs):
        self._debug_tcl_eval = False
        self.__logger = Logger('ixiatcl', print_timestamp=False)
        self.__init_tcl_interp(kwargs.get('tcl_autopath', []))
        self.__build_tcl_commands()

        tcl_version = self._eval('info patchlevel')
        self.__logger.info('Tcl version: %s' % tcl_version)
        self.__initialized = tcl_version

    def __tcl_print (self, message, nonewline = "0", out_stderr="0"):
        if out_stderr == "1":
            print >> sys.stderr, message
        else:
            if nonewline == "1":
                print message,
            else:
                print message   

    def __init_tcl_interp(self, tcl_autopath):
        self.__interp = Tkinter.Tcl()
        self.__interp.createcommand('__py_puts', self.__tcl_print )
        self._eval("""
            if { [catch { puts -nonewline {} }] } {
                #stdout is close. Python's IDLE does not have stdout.
                __py_puts "Redirecting Tcl's stdout to Python console output."
                rename puts __tcl_puts
                proc puts {args} {
                    set processed_args $args
                    set keep_current_line 0
                    set write_to_stderr   0
                    set args_size [llength $args] 
                    #check if -nonewline is present
                    set no_new_line_index [lsearch -nocase $processed_args -nonewline]
                    if {$no_new_line_index > -1} {
                        lreplace $processed_args $no_new_line_index $no_new_line_index
                        set keep_current_line 1
                        incr args_size -1
                    }
                    #check if stederr is present
                    set stderr_index [lsearch -nocase $processed_args stderr]
                    if {$stderr_index > -1} {
                        lreplace $processed_args $stderr_index $stderr_index
                        set write_to_stderr 1
                        incr args_size -1
                    }
                    if { $args_size < 2} {
                        # a message for stdout or stderr. Sent to python's print method
                        __py_puts [lindex $processed_args [expr [llength $processed_args] - 1]] $keep_current_line $write_to_stderr 
                    } else {
                        # probably a socket. use native tcl puts
                        set cmd "__tcl_puts $args"
                        eval $cmd
                    }
                }
            }


            """)

        for auto_path_item in tcl_autopath:
            self._eval("lappend ::auto_path %s" % auto_path_item)

    def tcl_error_info(self):
        ''' Return tcl interp ::errorInfo '''
        return self.__interp.eval('set ::errorInfo')

    def _eval(self, code):
        ''' Eval given code in tcl interp '''
        if self._debug_tcl_eval:
            self.__logger.debug('TCL: ' + code)

        ret = self.__interp.eval(code)

        if self._debug_tcl_eval:
            self.__logger.debug('RET: ' + ret)
        return ret

    def _tcl_flatten(self, obj, key_prefix='', first_call=True):
        ''' 
        Flatten a python data structure involving dicts, lists and basic data types
        to a tcl list. For the outermost dictionary do not return as a quoted tcl list
        because the quoting is done at evaluation (first_call=True means dont quote)
        '''
        if isinstance(obj, list):
            retlist = map(lambda x: self.quote_tcl_string(self._tcl_flatten(x, key_prefix, False)), obj)
            tcl_string = ' '.join(retlist)
        elif isinstance(obj, dict):
            retlist = []
            for (k, v) in obj.items():
                if not first_call:
                    vflat = self._tcl_flatten(v, '', False)
                    rettext=k + ' ' + self.quote_tcl_string(vflat)
                    retlist.append(self.quote_tcl_string(rettext))
                else:
                    retlist.append(key_prefix + k)
                    vflat = self._tcl_flatten(v, '', False)
                    retlist.append(self.quote_tcl_string(vflat))

            tcl_string = ' '.join(retlist)
        elif isinstance(obj, str):
            tcl_string = self.__quote_tcl_invalid(obj)
        else:
            tcl_string = str(obj)

        return tcl_string

    def __quote_tcl_invalid(self, tcl_string):
        '''
        For user input string quote any tcl list separators
        in order to get good quoting using Tcl_merge. Otherwise, the 
        function will quote individual characters instead of the whole string.
        '''
        if not isinstance(tcl_string, str):
            raise ValueError('input not a string')

        invalid_chars = ['{', '}', '\\']

        # state 0 - none
        # state 1 - escaping
        state = 0
        ret = ''
        for c in tcl_string:
            if state == 0:
                if c == '\\':
                    state = 1
                elif c in invalid_chars:
                    ret += '\\'
            elif state == 1:
                state = 0
            ret += c
        if state == 1:
            ret += '\\'
        return ret

    def quote_tcl_string(self, tcl_string):
        ''' Returns a tcl string quoting any invalid tcl characters '''
        return self.__interp.merge(tcl_string)

    def convert_tcl_list(self, tcl_string):
        ''' Returns a python list representing the input tcl list '''
        return list(self.__interp.splitlist(tcl_string))

    def keylget (self, dict_input, key ):
        ''' Python implementation of the tcl's keylget command. This can be used with python's dict '''
        if type(dict_input) != type(dict()):
             raise TypeError("Expected a dictionary and received a %s as input" % type(dict_input).__name__)
        if type(key) != type(str()):
             raise TypeError("Expected a string as a key filter and received %s as input" % type(key).__name__)
        resulted_dict = dict_input
        for k in key.split('.'):
            try:
                resulted_dict = resulted_dict[k]
            except KeyError:
                raise KeyError("Key %s is not found is the given dictionary" % key) 
        return resulted_dict

    @staticmethod
    def _make_tcl_method(tcl_funcname, conversion_in=None, conversion_out=None, eval_getter=None):
        def __tcl_method(self, *args, **kwargs):
            if conversion_in:
                tcl_args = ' '.join(conversion_in(args, kwargs))
            else:
                tcl_args = ' '.join(args)
            
            code = tcl_funcname + ' ' + tcl_args
            if eval_getter:
                eval_func = eval_getter(self)
            else:
                eval_func = self._eval
            result = eval_func(code)

            if conversion_out:
                result = conversion_out(result)
            return result

        # strip namespace if any
        __tcl_method.__name__ = tcl_funcname.split(':')[-1]
        return __tcl_method

    def __build_tcl_commands(self):
        ''' Adds the main tcl commands as methods to this class '''
        command_list = [
            "after", "append", "array",
            "bgerror", "binary",
            "cd", "clock", "close", "concat", 
            "encoding", "eof", "error", "expr",
            "fblocked", "fconfigure", "fcopy", "file", "fileevent", "filename", "flush", "format",
            "gets", "glob",
            "incr", "info", "interp", "join", "lappend", "lindex", "linsert", "list", "llength", "load", 
            "lrange", "lreplace", "lsearch", "lset", "lsort",
            "namespace",
            "open",
            "package", "parray", "pid", "proc", "puts", "pwd",
            "read", "regexp", "registry", "regsub", "rename", "resource",
            "scan", "seek", "set", "socket", "source", "split", "string", "subst", "switch",
            "tell", "time", "trace",
            "unknown", "unset", "update", "uplevel", "upvar",
            "variable", "vwait"
        ]

        def convert_in(args, kwargs):
            return tuple(map(lambda x: str(x), args))

        def convert_in_py(args, kwargs):
            return tuple(map(lambda x: self.quote_tcl_string(self._tcl_flatten(x)), args))

        def convert_out_py(tcl_string):
            if tcl_string == '':
                return None
            ret = self.convert_tcl_list(tcl_string)
            if len(ret) == 1:
                return ret[0]
            return ret

        for command in command_list:
            method = self._make_tcl_method(
                command, 
                conversion_in=convert_in
            )
            method_py = self._make_tcl_method(
                command,
                conversion_in=convert_in_py,
                conversion_out=convert_out_py
            )

            method.__doc__ = 'Lowlevel python wrapper over TCL command. The input parameters are TCL-style datatypes'
            method_py.__doc__ = 'Lowlevel python wrapper over TCL command. The input parameters are python datatypes'

            setattr(self.__class__, command, method)
            setattr(self.__class__, command + '_py', method_py)
