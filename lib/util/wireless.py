from misc import *
import pdb

"""
   wireless class for all wireless related methods
"""
class wireless(object):

    def get_adapter_data(self, info, adapter_type):
        '''
        This python API return adapter data in a dictionary format
        '''
        func_name = 'get_adapter_data'
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

    def get_WTPID(self, info):
        '''
        This python API return WTP ID data in a dictionary format
        '''
        func_name = 'get_WTPID'
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

    def check_platform(self, info, platform):
        '''
        This python API check platform containing in info
        '''
        func_name = 'check_platform'
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

    def check_login_status(self, info, connection_name):
        '''
        This python API check login status
        '''
        func_name = 'check_login_status'
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

    def verify_ping_packets_loss(self, info):
        '''
        This python API check ping packets loss
        '''
        func_name = 'verify_ping_packets_loss'
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

    def verify_fap_ping_packets_loss(self, info):
        '''
        This python API check ping packets loss
        '''
        func_name = 'verify_fap_ping_packets_loss'
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

    def get_WTP_state(self, info):
        '''
        This python API parses and return WTP Status data in a dictionary format
        '''
        func_name = 'get_WTP_state'
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

    def parse_FAP_radio_info(self, info):
        '''
        This python API parses and return WTP Client Radio Info data in a dictionary format
        '''
        func_name = 'parse_FAP_radio_info'
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

    def parse_beacon_interval(self, info, radio_number):
        '''
        This python API parses output from FAP output and return beacon interval
        '''
        func_name = 'get_beacon_interval'
        try:
            status_data = {'status':0}
            s = re.search(r'Radio %s:[.\s:\n\w=/\-,]+?beacon\sintv\s+\:\s+(\d+)' % str(int(radio_number) - 1), info)
            if s:
                status_data = {
                    'status':1,
                    'beacon_interval':s.group(1)
                }
        except:
            e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
            status_data = {'status':0, 'msg':e}
        finally:
            return(status_data)

    def parse_beacon_interval_from_wtp_profile(self, info, radio_number):
        '''
        This python API parses output from controller output and return beacon interval
        '''
        func_name = 'get_beacon_interval'
        try:
            status_data = {'status':0}
            s = re.search(r'radio-%s:[.\s:\n\w=/\-,]+?beacon-interval\s+\:\s+(\d+)' % str(int(radio_number)), info)
            if s:
                status_data = {
                    'status':1,
                    'beacon_interval':s.group(1)
                }
        except:
            e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
            status_data = {'status':0, 'msg':e}
        finally:
            return(status_data)


    def get_SSID_data(self, info):
        '''
        This python API return SSID data in a dictionary format
        '''
        func_name = 'get_SSID_data'
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

    def check_SSID_presence(self, info, ssid):
        '''
        This python API checks if ssid presence
        '''
        func_name = 'check_SSID_presence'
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

    def parse_wlan_interface_data(self, info):
        '''
        This python API parses wlan interface data, returns them in a dictionary
        '''
        func_name = 'parse_wlan_interface_data'
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

    def get_wifi_info(self, info, gateway):
        '''
        This python API parses apple ifconfig interface data, returns them in a dictionary
        '''
        func_name = 'get_wifi_info'
        try:
            status_data = {'status':0}
            t_info = re.sub(r'(\\r)+', '', info, re.DOTALL)
            wifi_info = {}
            for line in t_info.split('\n'):
                if re.search(r'~', line, re.U):
                    continue
                s = re.search(r':', line, re.U)
                if s:
                    ss = re.search(r'(.*): (.*)', line, re.U)
                    if ss:
                        ss1 = ss.group(1).strip()
                        ss2 = ss.group(2).strip()
                    else:
                        ss1 = line.strip()
                        ss2 = ''
                    wifi_info[ss1] = ss2
                    continue
            if 'Router' in wifi_info:
                router_ip = wifi_info['Router']
                if router_ip == gateway:
                    if wifi_info != {}:
                        status_data = {
                            'status':1,
                            'wifi':wifi_info,
                        }
        except:
            e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
            status_data = {'status':0, 'msg':e}
        finally:
            return(status_data)

    def get_wifi_interface_info(self, info):
        '''
        This python API parses apple networksetup -listallhardwareports interface data, returns them in a dictionary
        '''
        func_name = 'get_wifi_interface_info'
        try:
            status_data = {'status':0}
            t_info = re.sub(r'(\\r)+', '', info, re.DOTALL)
            wifi_interface_info = {}
            wifi_interface = 0
            for line in t_info.split('\n'):
                if len(line) < 5:
                    wifi_interface = 0
                    continue
                if re.search(r'Hardware Port: Wi-Fi', line, re.U):
                    wifi_interface = 1
                    continue
                s = re.search(r'(.*): (.*)', line, re.U)
                if s and wifi_interface == 1:
                    s1 = s.group(1).strip()
                    s2 = s.group(2).strip()
                    wifi_interface_info[s1] = s2
                    continue
                if wifi_interface_info != {}:
                    status_data = {
                        'status':1,
                        'wifi':wifi_interface_info,
                    }
        except:
            e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
            status_data = {'status':0, 'msg':e}
        finally:
            return(status_data)

    def get_resolved_ipv4_address(self, info, interface_name, gateway):
        '''
        This python API parses win ipconfig /all and Wireless LAN adapter Wireless Network Connection: info, returns IPv4 Address in a dictionary
        '''
        func_name = 'get_resolved_ipv4_address'
        try:
            status_data = {'status':0}
            t_info = re.sub(r'(\\r)+', '', info, re.DOTALL)
            wireless_interface_info = {}
            wireless_interface = 0
            for line in t_info.split('\n'):
                if len(line) < 5:
                    if wireless_interface == 1:
                        wireless_interface = 2
                    else:
                        wireless_interface = 0
                    continue
                if re.search(r'Wireless LAN adapter %s:' % interface_name, line, re.U):
                    nested_print(line)
                    wireless_interface = 1
                    continue
                if wireless_interface == 2:
                    nested_print(line)
                    s = re.search(r'(.*): (.*)', line, re.U)
                    if s:
                        s1 =  re.sub(r'(\.\s)+', '', s.group(1), re.DOTALL)
                        s1 =  s1.strip()
                        s2 = s.group(2).strip()
                        wireless_interface_info[s1] = s2
                        continue
                    if wireless_interface_info != {}:
                        if 'Default Gateway' in wireless_interface_info:
                            if wireless_interface_info['Default Gateway'] == gateway:
                                status_data = {
                                    'status':1,
                                    'ipv4':wireless_interface_info['Default Gateway'],
                                }
        except:
            e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
            status_data = {'status':0, 'msg':e}
        finally:
            return(status_data)

    def parse_wireless_network_attributes(self, info):
        '''
        This python API parses airport -I data, returns them in a dictionary
        '''
        func_name = 'parse_wireless_network_attributes'
        try:
            status_data = {'status':0}
            t_info = re.sub(r'(\\r)+', '', info, re.DOTALL)
            attributes_info = {}
            for line in t_info.split('\n'):
                if len(line) < 5:
                    continue
                s = re.search(r'(.*): (.*)', line, re.U)
                if s:
                    s1 = s.group(1).strip()
                    s2 = s.group(2).strip()
                    attributes_info[s1] = s2
                    continue
            if attributes_info != {}:
                status_data = {
                    'status':1,
                    'data':attributes_info,
                }
        except:
            e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
            status_data = {'status':0, 'msg':e}
        finally:
            return(status_data)


    def general_parser_get(self, info):
        '''
        This python API parses the output of get command and return the data in a dictionary format
        '''
        func_name = 'general_parser_get'
        try:
            status_data = {'status':1}
            t_info = re.sub(r'(\r)+', '', info, re.DOTALL)
            data = {'data' : {}}
            last_key = ''
            for line in t_info.split('\n'):
                # parsing each lines
                space_s = re.search(r'^(\s+)\w+', line)
                line = line.strip()
                if line == '':
                    # ignore empty line
                    continue
                if space_s:
                    # there is spaces before the characters at the beginning of string; it means it is second level key/value pairs
                    data_pair = re.search(r'(.*): (.*)', line, re.U)
                    if data_pair:
                        # parsing key and value
                        key = data_pair.group(1).strip()
                        value = data_pair.group(2).strip()
                    else:
                        # parsing key and empty value
                        key = re.sub(r':', '', line).strip()
                        value = ''
                    data['data'][last_key] = {}
                    data['data'][last_key][key] = value
                else:
                    data_pair = re.search(r'(.*): (.*)', line, re.U)
                    if data_pair:
                        # parsing key and value
                        key = data_pair.group(1).strip()
                        value = data_pair.group(2).strip()
                    else:
                        # parsing key and empty value
                        key = re.sub(r':', '', line).strip()
                        value = ''
                    data['data'][key] = value
                    last_key = key
            status_data.update(data)
        except Exception, error:
            e = '%s, Unexpected error: %s: %s' % (func_name,  sys.exc_info()[0], error)
            status_data = {'status':0, 'msg':e}
        finally:
            return(status_data)

    def general_parser_show(self, info, current_line='', lvl=0, parent_key='', start=True, status_data={}, prev_num_sp=0):
        '''
        This python API parses the output of show command and return the data in a dictionary format
        '''
        func_name = 'general_parser_show'
        try:
            if start == True:
                t_info = re.sub(r'(\r)+', '', info, re.DOTALL)
                data = {}
                status_data = {'status':1, 'data':data}
                prev_num_sp = 0
                start = False
            else:
                t_info = info
                #status_data = {'status':1, 'data':data}
            current_line = re.search(r'^(.*)\n', t_info).group(1)
            while current_line != '' and t_info != '':
                # parsing each lines
                t_info = t_info.replace(current_line + '\n', '', 1)
                space_s = re.search(r'^(\s+)\w+', current_line)
                if space_s != None:
                    sp = space_s.group(1)
                    num_sp = len(sp)
                else:
                    sp = ''
                    num_sp = 0
                current_line = current_line.strip()
                s1 = re.search(r'^config\s(.*)', current_line)
                s2 = re.search(r'^edit\s(.*)', current_line)
                if s1 != None or s2 != None:
                    current_key = s1.group(1) if s1 != None else s2.group(1)
                    next_line = re.search(r'^(.*)\n', t_info).group(1)
                    if prev_num_sp < num_sp:
                        status_data['data'][parent_key] = {}
                        status_data['data'][parent_key][current_key] = ''
                        #parent_key = current_key
                        lvl+=1                       
                        t_info, current_line, lvl, update_status_data, num_sp = self.general_parser_show(t_info, next_line, lvl, current_key, start, {'status':1, 'data':{}}, num_sp)
                        status_data['data'][parent_key].update(update_status_data['data'])
                    elif prev_num_sp == num_sp:
                        status_data['data'][current_key] = ''
                        t_info, current_line, lvl, update_status_data, num_sp = self.general_parser_show(t_info, next_line, lvl, current_key, start, {'status':1, 'data':{}}, num_sp)
                        status_data['data'].update(update_status_data['data'])
                s3 = re.search(r'^set\s(.*)?\s(.*)?', current_line)
                if s3 != None:
                    current_key = s3.group(1)
                    current_value = s3.group(2)
                    if prev_num_sp < num_sp:
                        lvl+=1
                        status_data['data'][parent_key] = {}
                        status_data['data'][parent_key][current_key] = current_value
                        #parent_key = current_key
                        next_line = re.search(r'^(.*)\n', t_info).group(1)
                        t_info, current_line, lvl, update_status_data, num_sp = self.general_parser_show(t_info, next_line, lvl, current_key, start, {'status':1, 'data':status_data['data'][parent_key]}, num_sp)
                        status_data['data'][parent_key].update(update_status_data['data'])
                        #return 
                    elif prev_num_sp == num_sp:
                        status_data['data'][current_key] = current_value
                        next_line = re.search(r'^(.*)\n', t_info).group(1)
                        t_info, next_line, lvl, update_status_data, num_sp = self.general_parser_show(t_info, next_line, lvl, current_key, start, {'status':1, 'data':{current_key : current_value}}, num_sp)
                        status_data['data'].update(update_status_data['data'])
                        return 
                        
                s4 = re.search(r'^next', current_line)
                if s4 != None:
                    #if prev_num_sp > num_sp:
                        lvl-=1
                        next_line = re.search(r'^(.*)\n', t_info).group(1)
                        #t_info = t_info.replace(next_line + '\n', '')
                        return     
                s5 = re.search(r'^end', current_line)
                if s5 != None:
                    #if prev_num_sp > num_sp:
                        lvl-=1
                        #data[parent_key] = {}
                        #data[parent_key][current_key] = current_value
                        #parent_key = current_key
                        if t_info != '':
                            next_line = re.search(r'^(.*)\n', t_info).group(1)
                            #t_info = t_info.replace(next_line + '\n', '')
                        return 
                prev_num_sp = num_sp
                #current_line = next_line
            #parent_key = current_key
        except Exception, error:
            e = '%s, Unexpected error: %s: %s' % (func_name,  sys.exc_info()[0], error)
            status_data = {'status':0, 'msg':e}
        finally:
            return(t_info, next_line, lvl, status_data, num_sp)            

    def general_parser_diagnose_table(self, info):
        '''
        This python API parses the output of diagnose command and return the data in a 2-D list
        '''
        func_name = 'general_parser_diagnose_table'
        try:
            status_data = {'status':1}
            t_info = re.sub(r'(\r)+', '', info, re.DOTALL)
            data = {'data' : []}
            counter = 0
            combine_i_lst = []
            for line in t_info.split('\n'):
                # parsing each lines
                line = line.strip()
                if line == '':
                    # ignore empty line
                    continue
                items = line.split()
                if counter == 0:
                    data['data'].append(items)
                    for i in xrange(0, len(items)):
                        if ':' in items[i]:
                            combine_i_lst.append(i)
                else:
                    if combine_i_lst != []:
                        for combine_i in combine_i_lst:
                            items[combine_i] = items[combine_i] + items[combine_i+1]
                            del items[combine_i+1]
                    data['data'].append(items)
                counter+=1
            status_data.update(data)
        except Exception, error:
            e = '%s, Unexpected error: %s: %s' % (func_name,  sys.exc_info()[0], error)
            status_data = {'status':0, 'msg':e}
        finally:
            return status_data

    def general_parser_diagnose_equal(self, info):
        '''
        This python API parses the output of diagnose command and return the data in a list of dictionary -2
        '''
        func_name = 'general_parser_diagnose_equal'
        try:
            status_data = {'status':1}
            t_info = re.sub(r'(\r)+', '', info, re.DOTALL)
            data = {'data' : []}
            counter =0 
            for line in t_info.split('\n'):
                # parsing each lines
                line = line.strip()
                if line == '':
                    # ignore empty line
                    continue
                items = line.split()
                diction = {}
                for item in items:
                    pair_re = re.search(r'(.*)=(.*)', item)
                    if pair_re != None:
                        key = pair_re.group(1)
                        value = pair_re.group(2)                             
                        diction[key] = value
                    else:
                        if counter == 0 and item == '*':
                            continue
                        else:
                            value = value + ' ' + item
                            diction[key] = value
                data['data'].append(diction)
                counter+=1
            status_data.update(data)
        except Exception, error:
            e = '%s, Unexpected error: %s: %s' % (func_name,  sys.exc_info()[0], error)
            status_data = {'status':0, 'msg':e}
        finally:
            return status_data            

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
    wr = wireless()
    Status = wr.parse_FAP_radio_info(info)
    nested_print(Status)

