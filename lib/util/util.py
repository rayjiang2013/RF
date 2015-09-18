from robot.api import logger
import xml.etree.ElementTree as ET
import threading
import os, sys, re, time
import pdb

#
# This is a global buffer for all testbeds info in dict format
# It is used to record available resurce for each testbeds
#
resource_db = {}

#
# This semaphore is used to ensure the data integrity in resource_db
#
semaphore = threading.Semaphore()

def log_result(log, msg):
    log.append('%s: %s\n' % (time.strftime("%H:%M:%S"), msg))

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
    This python API returns the value of nested keys in the diction since Robor Framework does not provide it
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

def list_to_string(*args):
    '''
    This python API converts a list to string. Because Robot Framework canot pass in a list 
    as single argument, we have to convert the list to string
    '''
    tcs = ""
    for arg in args:
        tcs += arg + '\n'
    return(tcs)

def show_resource_db():
    '''
    This python API shows the connect of resource_db in indented fation
    '''
    nested_print(resource_db)

def reset_resource_db():
    '''
    This python API reset resource_db
    '''
    global resource_db
    resource_db = {}

def get_resource_db(testbed):
    '''
    This python API return resource for a testbed
    '''
    func_name = get_resource_db.__name__
    try:
        # default status is failure
        if testbed in resource_db:
            status_data = {
                'status':1,
                testbed:resource_db[testbed]
            }
        else:
            status_data = {'status':0}
    except Exception as msg:
        e = '%s Exception: %s' % (func_name, msg)
        status_data = {'status':0, 'msg':e}
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'msg':e}
    finally:
        return(status_data)

def get_resource_db_available(testbed):
    '''
    This python API return available resource in a testbed
    '''
    func_name = get_resource_db_available.__name__
    try:
        # default status is failure
        status_data = {
            'status':1,
            'available':resource_db[testbed]['available']
        }
    except Exception as msg:
        e = '%s Exception: %s' % (func_name, msg)
        status_data = {'status':0, 'msg':e}
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'msg':e}
    finally:
        return(status_data)

def get_resource_db_inuse(testbed):
    '''
    This python API return inuse resource in a testbed
    '''
    func_name = get_resource_db_inuse.__name__
    try:
        # default status is failure
        status_data = {
            'status':1,
            'inuse':resource_db[testbed]['inuse']
        }
    except Exception as msg:
        e = '%s Exception: %s' % (func_name, msg)
        status_data = {'status':0, 'msg':e}
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'msg':e}
    finally:
        return(status_data)

def _set_resource_db(testbed, available_resource, inuse_resource=None):
    '''
    This is a API for internal use only
    This python API manipulate resource_db while protect the data's integrity 
    '''
    func_name = _set_resource_db.__name__
    try:
        status_data = {}
        # default status is failure
        semaphore.acquire()
        resource_db[testbed] = {
            'available':available_resource,
            'inuse':inuse_resource,
        }
        status_data['status'] = 1
    except Exception as msg:
        e = '%s, %s Exception: %s' % (func_name, testbed, msg)
        status_data = {'status':0, 'msg':e}
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'msg':e}
    finally:
        semaphore.release()
        return(status_data)

def _init_resource_db(testbed, tbinfo_dict):
    '''
    This is a API for internal use only
    This python API initialize resource_db for a particular testbed
    '''
    func_name = _init_resource_db.__name__
    try:
        # default status is failure
        status_data = {}
        semaphore.acquire()
        resource_db[testbed] = {
            'available':tbinfo_dict,
            'inuse':{},
        }
        status_data['status'] = 1
    except Exception as msg:
        e = '%s Exception: %s' % (func_name, msg)
        status_data = {'status':0, 'msg':e}
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'msg':e}
    finally:
        semaphore.release()
        return(status_data)

def _parse_tbinfo(tbinfo):
    '''
    This is a API for internal use only
    This python API parses tbinfo file in xml format and returns the data in dict format
    '''
    func_name = _parse_tbinfo.__name__
    try:
        status_data = {}
        # confirm tbinfo file exist
        if not os.path.exists(tbinfo):
            raise Exception("Invalid testbed info file: %s" % tbinfo)
        # parse xml format tbinfo file
        tree = ET.parse(tbinfo)
        root = tree.getroot()
        # save parsed data in dict
        status_data['testbedname'] = root.attrib['name']
        for child in root:
            if re.search(r'dev[0-9]+', child.tag):
                device_data = {
                    'type':child.attrib['type'],
                    'hostname':child.attrib['hostname'],
                    'model':child.attrib['model'],
                }
                for gchild in child:
                    if gchild.tag == 'console':
                        device_data['console'] = {
                            'ip': gchild.attrib['ip'],
                            'line':gchild.attrib['line'],
                        }
                    elif gchild.tag == 'login':
                        device_data['login'] = {
                            'username':gchild.attrib['username'],
                            'password':gchild.attrib['password'],
                        }
                    elif gchild.tag == 'mgmt':
                        device_data['mgmt'] = {
                            'ip':gchild.attrib['ip'],
                            'netmask':gchild.attrib['netmask'],
                            'gateway':gchild.attrib['gateway'],
                            'port':gchild.attrib['port'],
                        }
                    elif gchild.tag == 'pdu':
                        device_data['pdu'] = {
                            'model':gchild.attrib['model'],
                            'ip':gchild.attrib['ip'],
                            'port':gchild.attrib['port'],
                        }
                status_data[child.tag] = device_data
            elif re.search(r'trafgen[0-9]+', child.tag):
                trafgen_data = {
                    'type':child.attrib['type'],
                    'model':child.attrib['model'],
                    'chassis_ip':child.attrib['chassis_ip'],
                    'tcl_server_ip':child.attrib['tcl_server_ip'],
                    'ixnetwork_server_ip':child.attrib['ixnetwork_server_ip'],
                }
                '''
                # we need define trafgen ports because it is a shared resource
                gchild_data = {}
                for gchild in child:
                    ggchild_data = {}
                    for ggchild in gchild:
                        ggchild_data[ggchild.tag] = {
                            'name':ggchild.attrib['name'],
                            'mode':ggchild.attrib['mode'],
                        }
                    trafgen_data[gchild.tag] = ggchild_data
                '''
                status_data[child.tag] = trafgen_data
            elif child.tag == 'connections':
                gchild_data = {}
                for gchild in child:
                    gchild_data[gchild.tag] = {
                        'link':gchild.attrib['link'],
                        'type':gchild.attrib['type'],
                        'mode':gchild.attrib['mode'],
                    }              
                status_data[child.tag] = gchild_data
        status_data['status']=1
    except Exception as msg:
        e = '%s, parse testbed info file Exception: %s' % (func_name, msg)
        status_data = {'status':0, 'msg':e}
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'msg':e}
    finally:
        return(status_data)

def _parse_virtaul_topo(vtopo):
    '''
    This is a API for internal use only
    This python API parses vritual topo file in xml format and returns the data in dict format
    '''
    func_name = _parse_virtaul_topo.__name__
    try:
        status_data = {}
        # confirm tbinfo file exist
        if not os.path.exists(vtopo):
            nested_print("Invalid virtual info file: %s" % vtopo)
            return(status_data)
        # parse xml format tbinfo file
        tree = ET.parse(vtopo)
        root = tree.getroot()
        # save parsed data in dict
        for child in root:
            if child.tag == 'connections':
                gchild_data = {}
                for gchild in child:
                    gchild_data[gchild.tag] = {
                        'link':gchild.attrib['link'],
                        'type':gchild.attrib['type'],
                        'mode':gchild.attrib['mode'],
                    }              
                status_data[child.tag] = gchild_data
            else:
                child_data = {}
                child_data = {
                    'type':child.attrib['type'],
                    'model':child.attrib['model'],
                    'role':child.attrib['role'],
                }              
                status_data[child.tag] = child_data
        status_data['status']=1
    except Exception as msg:
        e = '%s, parse virtaul topo info file Exception: %s' % (func_name, msg)
        status_data = {'status':0, 'msg':e}
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'msg':e}
    finally:
        return(status_data)

def _allocate_test_topo(testbed, vtopo_dict):
    '''
    This is a API for internal use only
    This python API allocate test topo resource. Return it if it is available
    '''
    func_name = _allocate_test_topo.__name__
    try:
        # default status is failure
        status_data = {'status':0}

        # temp dict used to keep all matching resources. An allocation only start if
        # all resources required by by vtopo_dict are found
        tmp_db = {}

        # keep all matching device names. name in vtopo_dict will be the key and name in
        # resource_db will be the value. used for match connections
        match_resources = {}

        # fetch available resources
        available = get_resource_db_available(testbed)
        if available['status'] != 1:
            raise Exception('get_resource_db_available %s fail %s' % (testbed, available))

        available_resource = available['available']
        if available_resource == {}:
            nested_print('Unable to allocate test topo because available resource for testbed %s is empty' % \
                 testbed)

        # this resource buffer is for handling multiple traffic gen topo because we should
        # delete trafgen as a shared resource in resource_db
        available_trafgen_resource = available_resource.copy()

        inuse = get_resource_db_inuse(testbed)
        if inuse['status'] != 1:
            raise Exception('get_resource_db_inuse %s Exception: %s' % (testbed, inuse))
        inuse = inuse['inuse']

        # for unable matched resourse
        unmatch_resource = {}

        # Initialize this varaible. Otherwise topo without comnections fails
        vconnections = 0

        # walk throught vtopo_dict and find match in available resources
        for vkey, vvalue in vtopo_dict.iteritems():
            if re.search(r'dev[0-9]+', vkey):
                # search a match sku
                find_sku = 0
                for dkey in available_resource:
                    if re.search(r'dev[0-9]+', dkey):
                        if vtopo_dict[vkey]['type'] == available['available'][dkey]['type'] and \
                           vtopo_dict[vkey]['model'] == available['available'][dkey]['model']:
                             match_resources[vkey] = dkey
                             tmp_db[dkey] = available_resource[dkey]
                             # have to delete this allocated sku to void reuse
                             del available_resource[dkey]
                             find_sku = 1
                             break
                if find_sku == 0:
                    unmatch_resource[vkey] = vvalue
            elif re.search(r'trafgen[0-9]+', vkey):
                # search a match trafgen
                find_trafgen = 0
                for dkey in available_trafgen_resource:
                    if re.search(r'trafgen[0-9]+', dkey):
                        if vtopo_dict[vkey]['type'] == available['available'][dkey]['type'] and \
                           vtopo_dict[vkey]['model'] == available['available'][dkey]['model']:
                             match_resources[vkey] = dkey
                             tmp_db[dkey] = available_trafgen_resource[dkey]
                             # should not delete the trafgen available_trafgen_resource since
                             # it is a shared resource
                             del available_trafgen_resource[dkey]
                             find_trafgen = 1
                             break
                if find_trafgen == 0:
                    unmatch_resource[vkey] = vvalue
            elif re.search(r'connections', vkey):
                # find connection match has to postpone after sku and trafgen being found
                find_connections = 0
                vconnections = vtopo_dict['connections']
                vconnections_len = len(vconnections)
                dconnections = available_resource['connections']
                tmp_db['connections'] = {}

        if unmatch_resource != {}:
            nested_print('Unable to allocate following resources required by virtual test topo:')
            nested_print(unmatch_resource)
            return(status_data)
                      
        # search a match connections
        if vconnections != 0:
            for vkey, vlink in vconnections.iteritems():
                for dkey, dlink in dconnections.iteritems():
                    if vlink['type'] == dlink['type'] and \
                       vlink['mode'] == dlink['mode']:
                         vsrc, vdst = vlink['link'].split(',')
                         lsrc, ldst = dlink['link'].split(',')
                         dsrc, dummy = lsrc.split(':')
                         ddst, dummy = ldst.split(':')
                         if vsrc in match_resources and vdst in match_resources and \
                             match_resources[vsrc] == dsrc and match_resources[vdst] == ddst or \
                             match_resources[vsrc] == ddst and match_resources[vdst] == dsrc:
                             tmp_db['connections'][dkey] = dlink
                             # have to delete this allocated link to void reuse
                             del dconnections[dkey]
                             find_connections += 1
                             break
                else:
                    unmatch_resource[vkey] = vlink
                    continue
            if find_connections != vconnections_len:
                nested_print('Unable to allocate following resources required by virtual test topo:')
                nested_print(unmatch_resource)
                return(status_data)
                      
        # remove aloocated resources from available
        for dkey, dvalue in tmp_db.iteritems():
            if re.search(r'connections', dkey):
                for link, linkvalue in dvalue.iteritems():
                    if dkey not in inuse:
                        inuse[dkey] = {}
                    inuse[dkey][link] = linkvalue
            else:
                if dkey not in inuse:
                    inuse[dkey] = {}
                inuse[dkey] = dvalue

        # modify resource_db. move allocated resource from available in inuse
        status_data = _set_resource_db(testbed, available_resource, inuse)
        if status_data['status'] != 1:
            raise Exception('_set_resource_db %s Exception: %s' % (testbed, status_data))
           
        status_data = {
            'status':1,
            'test_topo':tmp_db,
        }
    except Exception as msg:
        e = '%s, %s Exception: %s' % (func_name, testbed, msg)
        status_data = {'status':0, 'msg':e}
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'msg':e}
    finally:
        return(status_data)

def _allocate_availabe(testbed):
    '''
    This is a API for internal use only
    This python API allocate all available resource
    '''
    func_name = _allocate_availabe.__name__
    try:
        # default status is failure
        status_data = {'status':0}

        # fetch available resources
        available = get_resource_db_available(testbed)
        if available['status'] != 1:
            raise Exception('get_resource_db_available %s fail %s' % (testbed, available))

        available_resource = available['available']
        if available_resource == {}:
            nested_print('Unable to allocate test topo because available resource for testbed %s is empty' % \
                 testbed)
        else:
            test_topo = available_resource.copy()
            inuse = get_resource_db_inuse(testbed)
            if inuse['status'] != 1:
                raise Exception('get_resource_db_inuse %s Exception: %s' % (testbed, inuse))
            inuse = inuse['inuse']

            # walk throught vtopo_dict and find match in available resources
            for akey, avalue in test_topo.iteritems():
                if re.search(r'dev[0-9]+', akey):
                    # add device into inuse resource db and delete it from available
                    inuse[akey] = avalue
                    del available_resource[akey]
                elif re.search(r'trafgen[0-9]+', akey):
                    # only add trafgen into inuse resource db
                    inuse[akey] = avalue
                elif re.search(r'connections', akey):
                    # allocate all links to inuse and delete them from available
                    for key, link in avalue.iteritems():
                        if akey not in inuse:
                            inuse[akey] = {}
                        inuse[akey][key] = link
                    del available_resource[akey]
            available_resource['connections'] = {}
            # modify resource_db. move allocated resource from available in inuse
            status_data = _set_resource_db(testbed, available_resource, inuse)
            if status_data['status'] != 1:
                raise Exception('_set_resource_db %s Exception: %s' % (testbed, status_data))
            status_data = {
                'status':1,
                'test_topo':test_topo,
            }
    except Exception as msg:
        e = '%s, %s Exception: %s' % (func_name, testbed, msg)
        status_data = {'status':0, 'msg':e}
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'msg':e}
    finally:
        return(status_data)

def release_test_topo(testbed, test_topo):
    '''
    This python API release test topo resource
    '''
    func_name = release_test_topo.__name__
    try:
        # fetch available resources
        available = get_resource_db_available(testbed)
        if available['status'] != 1:
            raise Exception('get_resource_db_available %s fail %s' % (testbed, available))

        available_resource = available['available']

        inuse = get_resource_db_inuse(testbed)
        if inuse['status'] != 1:
            raise Exception('get_resource_db_inuse %s Exception: %s' % (testbed, inuse))
        inuse = inuse['inuse']

        # unable released resources
        unable_released_devices = {}
        unable_released_connections = {}

        # we cannot delte trafgen until no remaining connecions does not need it
        del_trafgen_list = []

        # release all resources in test_topo from inuse resource to available resourse
        for tkey, tvalue in test_topo.iteritems():
            if re.search(r'dev[0-9]+', tkey):
                # search a match sku in inuse resource
                if tkey not in inuse:
                    unable_released_devices[tkey] = tvalue
                else:
                    del inuse[tkey]
                    available_resource[tkey] = tvalue
            elif re.search(r'trafgen[0-9]+', tkey):
                if tkey not in inuse:
                    unable_released_devices[tkey] = tvalue
                else:
                    del_trafgen_list.append(tkey)
            elif re.search(r'connections', tkey):
                inuse_connections = inuse['connections']
                unable_released_connections['connections'] = {}
                for tlink, tlinkvalue in tvalue.iteritems():
                    if tlink in inuse_connections:
                        available_resource['connections'][tlink] = tlinkvalue
                        del inuse[tkey][tlink]
                    else:
                        unable_released_connections['connections'][tlink] = tlinkvalue
                if inuse[tkey] == {}:
                    del inuse[tkey]

        if unable_released_devices != {}:
            nested_print('Unable release following devices to resource DB:')
            nested_print(unable_released_devices)
            return(status_data)

        if 'connections' in unable_released_connections and unable_released_connections['connections'] != {}:
            nested_print('Unable release following connectios to resource DB:')
            nested_print(unable_released_connections)
            return(status_data)

        if 'connections' in inuse:
            for frafgen in del_trafgen_list:
                inuse_trafgen = 0
                for key, value in inuse['connections'].iteritems():
                    if re.search(frafgen, value['link']):
                        inuse_trafgen = 1
                        break
                if inuse_trafgen == 0:
                    del inuse[frafgen]
        else:
           for frafgen in del_trafgen_list:
               del inuse[frafgen]

        # modify resource_db. move allocated resource from available in inuse
        status_data = _set_resource_db(testbed, available_resource, inuse)
        if status_data['status'] != 1:
            raise Exception('_set_resource_db %s Exception: %s' % (testbed, status_data))
        msg = '%s, Test topo released' % testbed
        status_data = {'status':1, 'msg':msg}
    except Exception as msg:
        e = '%s, %s Exception: %s' % (func_name, testbed, msg)
        status_data = {'status':0, 'msg':e}
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'msg':e}
    finally:
        nested_print(status_data)
        return(status_data)

def unset_string(set_str):
    '''
    This python API returns unset string
    '''
    func_name = unset_string.__name__

    # convert unicode to dictionary
    try:
        # default status is failure
        status_data = {'status':0}

        set_str = set_str.strip()
        s_list = set_str.split()
        s_len = len(s_list)
        action = 'dummy1'
        target = 'dummy2'
        if s_len > 0:
            action = s_list[0]
        if s_len > 1:
            target = s_list[1]
        if action == 'edit':
            if re.search(r'^[0-9]+$', target):
                s_li = ""
                for s_l in s_list[2:]:
                    s_li = s_li + ' ' + s_l
                unset_s = 'delete ' + target + s_li
                status_data = {
                    'status':1,
                    'unset_string':unset_s
                }
            else:
                status_data = {
                    'status':1,
                    'unset_string':set_str
                }
        elif action == 'set':
            s_li = ""
            for s_l in s_list[1:]:
                s_li = s_li + ' ' + s_l
            unset_s = 'unset ' + s_li
            status_data = {
                'status':1,
                'unset_string':unset_s
            }
        else:
            status_data = {
                'status':1,
                'unset_string':set_str
            }
    except Exception as msg:
        error_string = '%s crash: %s' % (func_name, msg)
        status_data = {
            'status':0,
            'error_string':error_string
        }
    except:
        error_string = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {
            'status':0,
            'error_string':error_string
        }
    finally:
        return(status_data)

def unset_config(configs):
    '''
    This python API returns unset config
    '''
    func_name = unset_config.__name__

    # convert unicode to dictionary
    try:
        # default status is failure
        status_data = {'status':0}

        # unconfig string
        unset_config_string = ""

        for config in configs.split('\n'):
            status_data = unset_string(config)
            if status_data['status'] != 1:
                raise Exception('%s Unable convert %s' % (func_name, status_data))
            unset_config_string += status_data['unset_string'] + '\n'
        status_data = {
            'status':1,
            'unconfig_string':unset_config_string
        }

    except Exception as msg:
        error_string = '%s crash: %s' % (func_name, msg)
        status_data = {
            'status':0,
            'unconfig_string':error_string
        }
    except:
        error_string = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {
            'status':0,
            'unconfig_string':error_string
        }
    finally:
        return(status_data)

def suite_test_init(testbed, tbinfo, vtopo=None):
    '''
    This python API allocate testbed resources for a test topo
    '''
    func_name = suite_test_init.__name__
    try:
        # fetch testbed resource from resource_db
        tb_resource_db = get_resource_db(testbed)

        # initial testbed resource in resource_db if it does exist yet
        if tb_resource_db['status'] != 1:
            tbinfo_dict = _parse_tbinfo(tbinfo)
            if tbinfo_dict['status'] != 1:
                raise Exception('%s, %s fail %s' % (func_name, testbed, tbinfo_dict))

            status = _init_resource_db(testbed, tbinfo_dict)
            if status['status'] != 1:
                raise Exception('%s, %s fail %s' % (func_name, testbed, status))

        # fetch inuse resourc
        inuse = get_resource_db_inuse(testbed)
        if inuse['status'] != 1:
            raise Exception('%s, %s Exception: %s' % (func_name, testbed, inuse))
        inuse = inuse['inuse']

        # due to the limitation of Robotframework, we have to use this way to check
        # whether vtopo has been given
        try:
            vtopo_name, vtopo_extension = os.path.splitext(vtopo)
        except:
            vtopo_extension = ""
        if not re.search(r'xml',vtopo_extension):
            vtopo = None

        # allocate entire available resource to test topo if vtopo is None
        if vtopo == None:
            status = _allocate_availabe(testbed)
            if status['status'] != 1:
                raise Exception('%s, %s fail: %s' % (func_name, testbed, status))

            status_data = {
                'status':1,
                'test_topo':status['test_topo'],
            }
        else:
            # parse virtaul topo data
            vtopo_dict = _parse_virtaul_topo(vtopo)
            if vtopo_dict['status'] != 1:
                raise Exception('%s, %s fail: %s' % (func_name, testbed, vtopo_dict))
            else:
                test_topo = _allocate_test_topo(testbed, vtopo_dict)
                if test_topo['status'] != 1:
                    raise Exception('%s, %s fail: %s' % (func_name, testbed, test_topo))
                status_data = {
                    'status':1,
                    'test_topo':test_topo['test_topo']
                }
    except Exception as msg:
        e = '%s, %s Exception: %s' % (func_name, testbed, msg)
        status_data = {'status':0, 'msg':e}
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'msg':e}
    finally:
        nested_print(status_data)
        return(status_data)

def get_adapter_data(info, adapter_type):
    '''
    This python API return adapter data in a dictionary format
    '''
    func_name = get_adapter_data.__name__
    try:
        status_data = {'status':0}
        t_info = re.sub(r'(\\r)+', '', info, re.DOTALL)
        adapter_data = {}
        in_adapter = 0
        for line in t_info.split('\n'):
            if len(line) <= 5:
                continue
            if re.search(adapter_type, line):
                in_adapter = 1
                continue
            if in_adapter == 1:
                if not re.search(r'^\s', line, re.U):
                    in_adapter = 0
                    continue
                #a = re.search(r'(.*)(\. | \. )+: (.*)', line)
                a2 = ''
                a = re.search(r'(.*):(.*)', line)
                if a:
                    a1 =  re.sub(r'(\.\s)+', '', a.group(1), re.DOTALL)
                    a1 =  a1.strip()
                    a2 =  a.group(2).strip()
                else:
                    a1 =  line.strip()
                if a1 not in adapter_data:
                    adapter_data[a1] = [a2]
                else:
                    adapter_data[a1].append(a2)
        status_data = {
            'status':1,
            'data':adapter_data
        }
    except Exception as msg:
        e = '%s Exception: %s' % (func_name, msg)
        status_data = {'status':0, 'msg':e}
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'msg':e}
    finally:
        return(status_data)

def get_WTPID(info):
    '''
    This python API return WTP ID data in a dictionary format
    '''
    func_name = get_WTPID.__name__
    try:
        status_data = {'status':0}
        t_info = re.sub(r'(\\r)+', '', info, re.DOTALL)
        wtpid_data = []
        for line in t_info.split('\n'):
            r = re.search(r'wtp-id: (.*)', line, re.U)
            if r:
                wtpid_data.append(r.group(1).strip())
        if len(wtpid_data) != 0:
            status_data = {
                'status':1,
                'wtp_id':wtpid_data,
        }
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'msg':e}
    finally:
        return(status_data)

def check_platform(info, platform):
    '''
    This python API check platform containing in info
    '''
    func_name = check_platform.__name__
    try:
        status_data = {'status':0}
        t_info = re.sub(r'(\\r)+', '', info, re.DOTALL)
        for line in t_info.split('\n'):
            r = re.search(r'type(\s)+: %s' % platform, line, re.U)
            if r:
                status_data = {'status':1}
                break
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'msg':e}
    finally:
        return(status_data)

def check_login_status(info, connection_name):
    '''
    This python API check login status
    '''
    func_name = check_login_status.__name__
    try:
        status_data = {'status':0}
        t_info = re.sub(r'(\\r)+', '', info, re.DOTALL)
        for line in t_info.split('\n'):
            r = re.search(r'%s login:' % connection_name, line, re.U)
            if r:
                status_data = {'status':1}
                break
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'msg':e}
    finally:
        return(status_data)

def verify_ping_packets_loss(info):
    '''
    This python API check ping packets loss
    '''
    func_name = verify_ping_packets_loss.__name__
    try:
        status_data = {'status':0}
        t_info = re.sub(r'(\\r)+', '', info, re.DOTALL)
        for line in t_info.split('\n'):
            r = re.search(r'0% packet loss', line, re.U)
            if r:
                status_data = {'status':1}
                break
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'msg':e}
    finally:
        return(status_data)

def verify_fap_ping_packets_loss(info):
    '''
    This python API check ping packets loss
    '''
    func_name = verify_fap_ping_packets_loss.__name__
    try:
        status_data = {'status':0}
        t_info = re.sub(r'(\\r)+', '', info, re.DOTALL)
        for line in t_info.split('\n'):
            r = re.search(r'Lost = 0', line, re.U)
            if r:
                status_data = {'status':1}
                break
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'msg':e}
    finally:
        return(status_data)

def get_WTP_state(info):
    '''
    This python API parses and return WTP Status data in a dictionary format
    '''
    func_name = get_WTP_state.__name__
    try:
        status_data = {'status':0}
        t_info = re.sub(r'(\\r)+', '', info, re.DOTALL)
        status_data = {'status':0}
        wtp_status_data = {}
        wtp_line = 0
        radio_1_line = 0
        radio_2_line = 0
        for line in t_info.split('\n'):
            # parsing each lines
            wtp_s = re.search(r'(.*): (.*)', line, re.U)
            if len(line) < 5:
                # ignore invalid lines
                continue
            if wtp_s:
                # parsing WTP line with title and value
                title = wtp_s.group(1).strip()
                value = wtp_s.group(2).strip()
            else:
                # parsing WTP line with title and empty value
                title = re.sub(r':', '', line).strip()
                value = ''
            if title == 'WTP':
                wtp_info = value.split()
                wtp_status_data[wtp_info[0]] = {
                    'ip_group':wtp_info[1],
                }
                wtp_line = 1
                continue
            radio_s = re.search(r'Radio ([0-9])', title)
            if radio_s:
                if radio_s.group(1) == '1':
                    wtp_status_data[wtp_info[0]]['Radio 1'] = {
                        'mode':value,
                    }
                    radio_1_line = 1
                    continue
                if radio_s.group(1) == '2':
                    wtp_status_data[wtp_info[0]]['Radio 2'] = {
                        'mode':value,
                    }
                    radio_2_line = 1
                    continue
                if radio_s.group(1) == '3':
                    wtp_status_data[wtp_info[0]]['Radio 3'] = {
                        'mode':value,
                    }
                    wtp_line = 0
                    radio_1_line = 0
                    radio_2_line = 0
                    continue
            if wtp_line == 1 and radio_1_line == 0 and radio_2_line == 0:
                wtp_status_data[wtp_info[0]][title] = value
                continue
            if wtp_line == 1 and radio_1_line == 1 and radio_2_line == 0:
                wtp_status_data[wtp_info[0]]['Radio 1'][title] = value
                continue
            if wtp_line == 1 and radio_1_line == 1 and radio_2_line == 1:
                wtp_status_data[wtp_info[0]]['Radio 2'][title] = value
        status_data = {
            'status':1,
            'WTP':wtp_status_data
        }
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'msg':e}
    finally:
        return(status_data)

def parse_FAP_radio_info(info):
    '''
    This python API parses and return WTP Client Radio Info data in a dictionary format
    '''
    func_name = parse_FAP_radio_info.__name__
    try:
        status_data = {'status':0}
        t_info = re.sub(r'(\\r)+', '', info, re.DOTALL)
        status_data = {'status':0}
        Radio_info = {}
        radio_0_line = 0
        radio_1_line = 0
        for line in t_info.split('\n'):
            if len(line) < 16:
                # ignore invalid lines
                continue
            if re.match(r'^\s*==+', line, re.U):
                # ignore '====' line
                continue
            # parsing each lines
            radio_s = re.search(r'(.*): (.*)', line, re.U)
            if radio_s:
                # parsing WTP line with title and value
                title = radio_s.group(1).strip()
                value = radio_s.group(2).strip()
            else:
                # parsing WTP line with title and empty value
                title = re.sub(r':', '', line).strip()
                value = ''
            if title == 'Radio 0':
                Radio_info[title] = {
                    'Radio 0':value,
                }
                radio_0_line = 1
                radio_1_line = 0
                continue
            if title == 'Radio 1':
                Radio_info[title] = {
                    'Radio 1':value,
                }
                radio_0_line = 0
                radio_1_line = 1
                continue
            if radio_0_line == 1 and radio_1_line == 0:
                Radio_info['Radio 0'][title] = value
                continue
            if radio_0_line == 0 and radio_1_line == 1:
                Radio_info['Radio 1'][title] = value
                continue
        if Radio_info != {}:
            status_data = {
                'status':1,
                'radio_info':Radio_info,
        }
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'msg':e}
    finally:
        return(status_data)

def get_SSID_data(info):
    '''
    This python API return SSID data in a dictionary format
    '''
    func_name = get_SSID_data.__name__
    try:
        status_data = {'status':0}
        t_info = re.sub(r'(\\r)+', '', info, re.DOTALL)
        ssid_data = {}
        ssid_saw = 0
        for line in t_info.split('\n'):
            if len(line) <= 5:
                ssid_saw = 0
                continue
            s = re.search(r'(SSID [0-9]+) : (.*)', line)
            if s:
                s1 =  s.group(1).strip()
                s2 =  s.group(2).strip()
                ssid_data[s2] = {
                    'ssid':s1,
                }
                ssid_saw = 1
                continue
            if ssid_saw == 1:
                a = re.search(r'(.*):(.*)', line)
                if a:
                    a1 =  a.group(1).strip()
                    a2 =  a.group(2).strip()
                    ssid_data[s2][a1] = a2
                else:
                    a1 =  line.strip()
                    ssid_data[s2][a1] = ''
        if ssid_data != {}:
            status_data = {
                'status':1,
                'data':ssid_data
            }
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'msg':e}
    finally:
        return(status_data)

def check_SSID_presence(info, ssid):
    '''
    This python API checks if ssid presence
    '''
    func_name = check_SSID_presence.__name__
    try:
        status_data = {'status':0}
        t_info = re.sub(r'(\\r)+', '', info, re.DOTALL)
        for line in t_info.split('\n'):
            if re.search(r'(SSID [0-9]+) : %s' % ssid, line):
                status_data = {'status':1}
                break
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'msg':e}
    finally:
        return(status_data)

def parse_wlan_interface_data(info):
    '''
    This python API parses wlan interface data, returns them in a dictionary
    '''
    func_name = parse_wlan_interface_data.__name__
    try:
        status_data = {'status':0}
        t_info = re.sub(r'(\\r)+', '', info, re.DOTALL)
        wlan_interface_data = {}
        wlan_interface_count = 0
        for line in t_info.split('\n'):
            if len(line) <= 5:
                continue
            t = re.search(r'There is ([0-9]+) interface on the system:', line)
            if t:
                wlan_interface_data = {
                    'wlan_interface_count':t.group(1),
                }
                continue
            s = re.search(r'(.*): (.*)', line, re.U)
            if s:
                s1 =  s.group(1).strip()
                s2 =  s.group(2).strip()
                if s1 == 'Name':
                    wlan_interface_count += 1
                    wlan_interface_count_str = 'intf' + str(wlan_interface_count)
                    wlan_interface_data[wlan_interface_count_str] = {
                        s1:s2,
                    }
                    continue
                wlan_interface_data[wlan_interface_count_str][s1] = s2

        if wlan_interface_data != {}:
            status_data = {
                'status':1,
                'wlan_interfaces':wlan_interface_data,
            }
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'msg':e}
    finally:
        return(status_data)

if __name__ == "__main__":
    info = '''
    FC220C  #
    FC220C  # get radio info
        Radio 0       : AP
        Radio type    : 11N_2.4G
        PS optimize   : 0
        11g prot mode : 0
        HT20/40 coext : 1
        Beacon intv   : 100
        Tx power      : 1
        HT param      : mcs=15 gi=disabled bw=20MHz
        Ack timeout   : 0
        AC MAX dista  : 0 ackt_2G=64 ackt_5G=25
        AC chan       : num=0 age=264753
        Channel       : num=0
        Oper channel  : 1
        AC md_cap     : 1   6   11
        AC chan list  : 1   6   11
        Chan list     : 1   6   11
        HW_chan list  : 1   2   3   4   5   6   7   8   9   10  11
        NOL list      :

        Radio 1       : AP
        Radio type    : 11AC
        PS optimize   : 0
        11g prot mode : 0
        HT20/40 coext : 1
        Beacon intv   : 100
        Tx power      : 20
        VHT param     : mcs=9 gi=disabled bw=80MHz
        Ack timeout   : 25
        AC MAX dista  : 0 ackt_2G=64 ackt_5G=25
        AC chan       : num=0 age=264753
        Channel       : num=0
        Oper channel  : 36
        AC md_cap     : 36  40  44  48
        AC chan list  : 36  40  44  48
        Chan list     : 36  40  44  48
        HW_chan list  : 36  40  44  48  52  56  60  64  100 104 108 112 116
                        132 136 140 149 153 157 161 165
        NOL list      :

    ==================================================

    Total: 2
    FC220C  #
    '''
    Status = parse_FAP_radio_info(info)
    nested_print(Status)
