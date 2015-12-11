from robot.api import logger
import os, sys, re, time

"""
    This is a common library for all other libraries
"""
def nested_print(obj, nested_level=0, output=sys.stdout):
    '''
    This python API display the given message in indented fation
    '''
    spacing = '   '
    if type(obj) == dict:
        logger.console('%s' % ((nested_level) * spacing))
        for k, v in obj.items():
            if hasattr(v, '__iter__'):
                logger.console('%s%s:' % ((nested_level + 1) * spacing, k))
                nested_print(v, nested_level + 1, output)
            else:
                logger.console('%s%s: %s' % ((nested_level + 1) * spacing, k, v))
        logger.console('%s' % (nested_level * spacing))
    elif type(obj) == list:
        logger.console('%s[' % ((nested_level) * spacing))
        for v in obj:
            if hasattr(v, '__iter__'):
                nested_print(v, nested_level + 1, output)
            else:
                logger.console('%s%s' % ((nested_level + 1) * spacing, v))
        logger.console('%s]' % ((nested_level) * spacing))
    else:
        logger.console('%s%s' % (nested_level * spacing, obj))

def get_nested_diction(d, keys):
    '''
    This python API returns the value of nested keys in the diction since Robot Framework does not provide it
    '''
    for k in keys.split('.'):
        if type(d) != dict:
            break
        else:
            d = d[k]
    return(d)

def remove_whitespace(instring):
    '''
    This python API removes whitespace and returns the trimed string
    '''
    return instring.strip()

def list_to_string(*args):
    '''
    This python API converts a list to string. Because Robot Framework canot pass in a list 
    as single argument, we have to convert the list to string
    '''
    tcs = ""
    for arg in args:
        tcs += arg + '\n'
    return(tcs)

def restruct_dev_ports(link_ports):
    '''
    This python API returns a diction with key as device and value as ports
    '''
    link_ports_dict = {}
    link_ports = link_ports.split()
    for link_port in link_ports:
        for link in link_port.split(','):
            link = re.sub(r':', ' ', link).split()
            dev = link[0]
            port = link[1]
            if dev in link_ports_dict:
                dev_ports = link_ports_dict[dev]
                dev_ports = dev_ports + ' ' + port
                link_ports_dict[dev] = dev_ports
            else:
                link_ports_dict[dev] = port
    return(link_ports_dict)

def increment_mac(mac, offset):
    '''
    This python API increment mac address
    '''
    if mac.find(":")>0:
        mac = mac.replace(":","")
        mac_out = "{:012X}".format(int(str(mac), 16) + int(offset))
        mac_out = ':'.join(s.encode('hex') for s in mac_out.decode('hex'))
    elif mac.find(".")>0:
        mac = mac.replace(".","")
        mac_out = "{:012X}".format(int(str(mac), 16) + int(offset))
        mac_out = '.'.join(s.encode('hex') for s in mac_out.decode('hex'))
    else :
        mac_out = "{:012X}".format(int(str(mac), 16) + int(offset))
       
    return mac_out

