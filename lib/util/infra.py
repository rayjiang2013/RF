import xml.etree.ElementTree as ET
import threading
from misc import *
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

class infra(object):

    def show_resource_db(self):
        '''
        This python API shows the connect of resource_db in indented fation
        '''
        nested_print(resource_db)

    def reset_resource_db(self):
        '''
        This python API reset resource_db
        '''
        global resource_db
        resource_db = {}

    def get_resource_db(self, testbed):
        '''
        This python API return resource for a testbed
        '''
        func_name = 'get_resource_db'
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

    def get_resource_db_available(self, testbed):
        '''
        This python API return available resource in a testbed
        '''
        func_name = 'get_resource_db_available'
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

    def get_resource_db_inuse(self, testbed):
        '''
        This python API return inuse resource in a testbed
        '''
        func_name = 'get_resource_db_inuse'
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

    def _set_resource_db(self, testbed, available_resource, inuse_resource=None):
        '''
        This is a API for internal use only
        This python API manipulate resource_db while protect the data's integrity 
        '''
        func_name = '_set_resource_db'
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

    def _init_resource_db(self, testbed, tbinfo_dict):
        '''
        This is a API for internal use only
        This python API initialize resource_db for a particular testbed
        '''
        func_name = '_init_resource_db'
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

    def _parse_tbinfo(self, tbinfo):
        '''
        This is a API for internal use only
        This python API parses tbinfo file in xml format and returns the data in dict format
        '''
        func_name = '_parse_tbinfo'
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
                        elif gchild.tag == 'tftp':
                            device_data['tftp'] = {
                                'ip':gchild.attrib['ip'],
                                'local_ip':gchild.attrib['local_ip'],
                                'gateway':gchild.attrib['gateway'],
                                'netmask':gchild.attrib['netmask'],
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

    def _parse_virtaul_topo(self, vtopo):
        '''
        This is a API for internal use only
        This python API parses vritual topo file in xml format and returns the data in dict format
        '''
        func_name = '_parse_virtaul_topo'
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

    def _allocate_test_topo(self, testbed, vtopo_dict):
        '''
        This is a API for internal use only
        This python API allocate test topo resource. Return it if it is available
        '''
        func_name = '_allocate_test_topo'
        try:
            # default status is failure
            status_data = {'status':0}
    
            # temp dict used to keep all matching resources. An allocation only start if
            # all resources required by by vtopo_dict are found
            tmp_db = {}
    
            # same as tmp_db. The deference is that tmp_db halds the physical resource  which uses during release
            # vtmp_db holds the the physical resource with the virtual name which uses in script
            vtmp_db = {}
    
            # keep all matching device names. name in vtopo_dict will be the key and name in
            # resource_db will be the value. used for match connections
            match_resources = {}
    
            # fetch available resources
            available = self.get_resource_db_available(testbed)
            if available['status'] != 1:
                raise Exception('get_resource_db_available %s fail %s' % (testbed, available))
    
            available_resource = available['available']
            if available_resource == {}:
                nested_print('Unable to allocate test topo because available resource for testbed %s is empty' % \
                     testbed)

            # this resource buffer is for handling multiple traffic gen topo because we should
            # delete trafgen as a shared resource in resource_db
            available_trafgen_resource = available_resource.copy()
    
            inuse = self.get_resource_db_inuse(testbed)
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
                                 vtmp_db[vkey] = available_resource[dkey]
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
                                 vtmp_db[vkey] = available_trafgen_resource[dkey]
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
                    vtmp_db['connections'] = {}
    
            if unmatch_resource != {}:
                nested_print('Unable to allocate following resources required by virtual test topo:')
                nested_print(unmatch_resource)
                return(status_data)
                          
            # search a match connections
            matrix_device = {}
            if vconnections != 0:
                for vkey, vlink in vconnections.iteritems():
                    for dkey, dlink in dconnections.iteritems():
                        if vlink['type'] == dlink['type'] and \
                           vlink['mode'] == dlink['mode']:
                             vsrc, vdst = vlink['link'].split(',')
                             lsrc, ldst = dlink['link'].split(',')
                             lsrc_index = lsrc.find('-')
                             if lsrc_index != -1:
                                 src = re.search(r'(matrix[0-9]+):(port[0-9]+)', lsrc)
                                 if src:
                                     lsrc_matrix = src.group(1)
                                 lsrc = lsrc[:lsrc_index]
                             ldst_index = ldst.find('-')
                             if ldst_index != -1:
                                 dst = re.search(r'(matrix[0-9])+:(port[0-9]+)', ldst)
                                 if dst:
                                     ldst_matrix = dst.group(1)
                                 ldst_index += 1
                                 ldst = ldst[ldst_index:]
                             dsrc, dummy = lsrc.split(':')
                             ddst, dummy = ldst.split(':')
                             if vsrc in match_resources and vdst in match_resources and \
                                 match_resources[vsrc] == dsrc and match_resources[vdst] == ddst or \
                                 match_resources[vsrc] == ddst and match_resources[vdst] == dsrc:
                                 if lsrc_matrix != 0 and ldst_matrix != 0:
                                     if lsrc_matrix != ldst_matrix:
                                        raise Exception('%s, src_matrix and dst_matrix have to be equal %s,%s' % (testbed, lsrc_matrix, ldst_matrix))
                                     if lsrc_matrix not in matrix_device:
                                         matrix_device[lsrc_matrix] = {}
                                         matrix_device[lsrc_matrix] = [[src.group(2), dst.group(2)]]
                                     else:
                                         matrix_device[lsrc_matrix].append([src.group(2), dst.group(2)])
                                 tmp_db['connections'][dkey] = dlink
                                 vtmp_db['connections'][vkey] = dlink
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
            status_data = self._set_resource_db(testbed, available_resource, inuse)
            if status_data['status'] != 1:
                raise Exception('_set_resource_db %s Exception: %s' % (testbed, status_data))
               
            matrixs = {}
            if len(matrix_device) != 0:
                for matrix in matrix_device:
                    matrixs[matrix] = {
                        'matrix':available_resource[matrix],
                        'port_pairs':matrix_device[matrix],
                    }
            status_data = {
                'status':1,
                'physical_topo':tmp_db,
                'test_topo':vtmp_db,
            }
        except Exception as msg:
            e = '%s, %s Exception: %s' % (func_name, testbed, msg)
            status_data = {'status':0, 'msg':e}
        except:
            e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
            status_data = {'status':0, 'msg':e}
        finally:
            return(status_data)

    def _allocate_availabe(self, testbed):
        '''
        This is a API for internal use only
        This python API allocate all available resource
        '''
        func_name = '_allocate_availabe'
        try:
            # default status is failure
            status_data = {'status':0}
    
            # fetch available resources
            available = self.get_resource_db_available(testbed)
            if available['status'] != 1:
                raise Exception('get_resource_db_available %s fail %s' % (testbed, available))
    
            available_resource = available['available']
            if available_resource == {}:
                nested_print('Unable to allocate test topo because available resource for testbed %s is empty' % \
                     testbed)
            else:
                test_topo = available_resource.copy()
                inuse = self.get_resource_db_inuse(testbed)
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
                status_data = self._set_resource_db(testbed, available_resource, inuse)
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

    def release_test_topo(self, testbed, test_topo):
        '''
        This python API release test topo resource
        '''
        func_name = 'release_test_topo'
        try:
            # fetch available resources
            available = self.get_resource_db_available(testbed)
            if available['status'] != 1:
                raise Exception('get_resource_db_available %s fail %s' % (testbed, available))
    
            available_resource = available['available']
    
            inuse = self.get_resource_db_inuse(testbed)
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
            status_data = self._set_resource_db(testbed, available_resource, inuse)
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

    def suite_test_init(self, testbed, tbinfo, vtopo=None):
        '''
        This python API allocate testbed resources for a test topo
        '''
        func_name = 'suite_test_init'
        try:
            # fetch testbed resource from resource_db
            tb_resource_db = self.get_resource_db(testbed)
    
            # initial testbed resource in resource_db if it does exist yet
            if tb_resource_db['status'] != 1:
                tbinfo_dict = self._parse_tbinfo(tbinfo)
                if tbinfo_dict['status'] != 1:
                    raise Exception('%s, %s fail %s' % (func_name, testbed, tbinfo_dict))
    
                status = self._init_resource_db(testbed, tbinfo_dict)
                if status['status'] != 1:
                    raise Exception('%s, %s fail %s' % (func_name, testbed, status))
    
            # fetch inuse resourc
            inuse = self.get_resource_db_inuse(testbed)
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
                test_topo = self._allocate_availabe(testbed)
                if test_topo['status'] != 1:
                    raise Exception('%s, %s fail: %s' % (func_name, testbed, test_topo))

                matrix_device = {}
                if 'connections' in test_topo['test_topo']:
                    for dkey, dlink in test_topo['test_topo']['connections'].iteritems():
                        lsrc_matrix = 0
                        ldst_matrix = 0
                        lsrc, ldst = dlink['link'].split(',')
                        if lsrc.find('-') != -1:
                            src = re.search(r'(matrix[0-9]+):(port[0-9]+)', lsrc)
                            if src:
                                lsrc_matrix = src.group(1)
                        if ldst.find('-') != -1:
                            dst = re.search(r'(matrix[0-9])+:(port[0-9]+)', ldst)
                            if dst:
                                ldst_matrix = dst.group(1)
                        if lsrc_matrix != 0 and ldst_matrix != 0:
                            if lsrc_matrix != ldst_matrix:
                                raise Exception('%s, src_matrix and dst_matrix have to be equal %s,%s' % (testbed, lsrc_matrix, ldst_matrix))
                            if lsrc_matrix not in matrix_device:
                                matrix_device[lsrc_matrix] = {}
                                matrix_device[lsrc_matrix] = [[src.group(2), dst.group(2)]]
                            else:
                                matrix_device[lsrc_matrix].append([src.group(2), dst.group(2)])
                matrixs = {}
                if len(matrix_device) != 0:
                    for matrix in matrix_device:
                        matrixs[matrix] = {
                            'matrix':test_topo['test_topo'][matrix],
                            'port_pairs':matrix_device[matrix],
                        }
                status = self._allocate_availabe(testbed)
                if status['status'] != 1:
                    raise Exception('%s, %s fail: %s' % (func_name, testbed, status))
    
                status_data = {
                    'status':1,
                    'test_topo':status['test_topo'],
                    'physical_topo':status['test_topo'],
                }
            else:
                # parse virtaul topo data
                vtopo_dict = self._parse_virtaul_topo(vtopo)
                if vtopo_dict['status'] != 1:
                    raise Exception('%s, %s fail: %s' % (func_name, testbed, vtopo_dict))
                else:
                    test_topo = self._allocate_test_topo(testbed, vtopo_dict)
                    if test_topo['status'] != 1:
                        raise Exception('%s, %s fail: %s' % (func_name, testbed, test_topo))
                    status_data = test_topo
        except Exception as msg:
            e = '%s, %s Exception: %s' % (func_name, testbed, msg)
            status_data = {'status':0, 'msg':e}
        except:
            e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
            status_data = {'status':0, 'msg':e}
        finally:
            if 'test_topo' in status_data:
                nested_print(status_data['test_topo'])
            return(status_data)

if __name__ == "__main__":
    inf = infra()
    test_topo = inf.suite_test_init('jim-tb', '/home/jimhe/git-repo/automation/cfg/jim-tb/tbinfo.xml', '/home/jimhe/git-repo/automation/cfg/virtual_topos/twoSw2trafgens.xml')
    #nested_print(test_topo)
    print('---------------------------')
    if 'matrixs' in test_topo:
        nested_print(test_topo['matrixs'])
    print('---------------------------')
    if 'test_topo' in test_topo:
        forti_devices = inf.get_forti_device_info(test_topo['test_topo'])
        nested_print(forti_devices)
    test_topo = inf.suite_test_init('wireless-tb', '/home/jimhe/git-repo/automation/cfg/wireless-tb/tbinfo.xml', '/home/jimhe/git-repo/automation/cfg/virtual_topos/FGateFAPMacBook.xml')
