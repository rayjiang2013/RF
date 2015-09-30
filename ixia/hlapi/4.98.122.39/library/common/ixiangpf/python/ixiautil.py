#!/usr/bin/env python

from datetime import datetime
import sys
import re
import platform
import getpass
import itertools
import xml.etree.ElementTree as ElementTree

from ixiaerror import IxiaError

class Logger(object):
    CAT_INFO = 'info'
    CAT_WARN = 'warn'
    CAT_DEBUG = 'debug'

    def __init__(self, prefix, print_timestamp=True):
        self.prefix = prefix
        self.print_timestamp = print_timestamp

    def log(self, category, msg):
        parts = []
        if self.print_timestamp:
            parts.append(datetime.now().strftime('%H:%M:%S.%f'))
        parts.append(self.prefix)
        parts.append(category)
        parts.append(' ' + msg)

        print(':'.join(parts))

    def info(self, msg):
        self.log(Logger.CAT_INFO, msg)

    def warn(self, msg):
        self.log(Logger.CAT_WARN, msg)

    def debug(self, msg):
        self.log(Logger.CAT_DEBUG, msg)

class _PartialMetaclass(type):
    '''
    Metaclass used for adding methods to existing classes.
    This is needed because of name mangling of __prefixed variabled and methods.
    '''

    def __new__(cls, name, bases, dict):
        if not bases:
            return type.__new__(cls, name, bases, dict)

        if len(bases) != 2:
            raise TypeError("Partial classes need to have exactly 2 bases")

        base = bases[1]
        # add the new methods to the existing base class
        for k, v in dict.items():
            if k == '__module__': continue
            setattr(base, k, v)

        return base

class PartialClass:
    __metaclass__ = _PartialMetaclass

def version_sorted(version_list):
    ''' sort a dotted-style version list '''
    # split versions list and make each sublist item an int for sorting
    split_versions = map(
        lambda x: map(
            lambda y: int(y), 
            x.split('.')
        ), 
        version_list
    )
    # sort by internal list integers and redo the string versions
    return map(
        lambda x: '.'.join(map(
            lambda y: str(y), x
        )), 
        sorted(split_versions)
    )

def get_hostname():
    '''
    This method returns the hostname of the client machine or a predefined 
    string if the hostname cannot be determined
    '''
    hostname = platform.node()
    
    if hostname:
        return hostname
    
    return "UNKNOWN MACHINE"

def get_username():
    '''
    This method returns the username of the client machine. A predified string
    ("UNKNOWN HLAPI USER") will be returned in case of failing to get the current username.
    '''
    username = "UNKNOWN HLAPI USER"
    try:
        username = getpass.getuser()
    except(Exception, ):
        return "UNKNOWN HLAPI USER"
    return username

def extract_specified_args(arguments_to_extract, hlpy_args):
    '''
    This method accepts a list as input and a dict. The method iterates through the elements of the dict and searches
    for the keys that have the same name. All the entries that are found are copied to a new dict which is returned. 
    '''
    return {key: hlpy_args[key] for key in arguments_to_extract if key in hlpy_args}

def merge_dicts(*dicts):
    '''
    This method accepts a list of dictionaries as input and returns a new dictionary with all the items 
    (all elements from the input dictionaries will be merged into the same dictionary)
    '''
    return dict(itertools.chain(*[d.iteritems() for d in dicts])) 

def get_ixnetwork_server_and_port(hlpy_args):
    '''
    This method parses the input arguments and looks for a key called ixnetwork_tcl_server. If the key is found, the
    value of the key is parsed in order to separate the hostname and port by ":" separator. The parsed information is
    returned as a dict with hostname and port keys. If no port is given 8009 will be used as default. If no hostname 
    is given it will default to loopback address. Valid input formats for ixnetwork_tcl_server value: 
        127.0.0.1:8009, hostname:8009, hostname, 127.0.0.1, 
        2005::1, [2005::1]:8009, 
        2005:0:0:0:0:0:0:1, [2005:0:0:0:0:0:0:1]:8009, 
        2005:0000:0000:0000:0000:0000:0000:001, [2005:0001::0001:001]:8009
    Not valid: 2005::1:8009 or 2005:0:0:0:0:0:0:1:8009
    '''
    default_hostname = '127.0.0.1'
    default_port = '8009'
    try:
        ixnetwork_tcl_server = hlpy_args['ixnetwork_tcl_server']
        list = ixnetwork_tcl_server.split(":")
        if len(list) == 1:
            return (ixnetwork_tcl_server, default_port)
        elif len(list) == 2:
            # does not contain ipv6 address
            return (list[0], list[1])
        else:
            # consider the hostname might be an ipv6 address in [ipv6]:port format (ex.: [2005::1]:8009)
            # we don't want to validate that the ipv6 is correct, just to know if port is included or not
            list = ixnetwork_tcl_server.split("]:")
            if len(list) == 1:
                return (list[0], default_port)
            else:
                return (list[0], list[1])
    except (Exception, ):
        return (default_hostname, default_port)

from ixiahlt import IxiaHlt
def make_hltapi_fail(log):
    return {'status': IxiaHlt.FAIL, 'log': log}
