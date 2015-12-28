'''
Created on 11/15/2015

@author: lei
'''
import sys
import os
sys.path.append(os.path.dirname(__file__))
sys.path.append(os.path.dirname(os.path.dirname(__file__)))
import pytest
import variables
from ..util.wireless import wireless

class TestWireless(object): 
    @pytest.mark.parametrize("info, radio_number, expected_return", 
                             [(variables.INFO, unicode(2), {'status': 1, 'beacon_interval': '50'}),
                              (variables.INFO, 2, {'status': 1, 'beacon_interval': '50'}),
                              (variables.INFO, unicode(1), {'status': 1, 'beacon_interval': '100'}),
                              (variables.INFO_NEG, unicode(2), {'status': 0}),
                              (variables.INFO_2, unicode(2), {'status': 1, 'beacon_interval': '50'}),
                              ("", unicode(2), {'status': 0}),
                              (12345, unicode(2), {'status': 0, 'msg': "get_beacon_interval, Unexpected error: <type 'exceptions.TypeError'>"}),
                              (variables.INFO, 'unexpected', {'status': 0, 'msg': "get_beacon_interval, Unexpected error: <type 'exceptions.ValueError'>"}),])
    def test_parse_beacon_interval(self, info, radio_number, expected_return):
        fap_obj = wireless()
        assert fap_obj.parse_beacon_interval(info, radio_number) == expected_return
        
    @pytest.mark.parametrize("info, expected_return", 
                             [(variables.INFO_3, {'status': 1, 'data': {'comment': '', 'lbs': {'ekahau-blink-mode': 'disable'}, 'wan-port-mode': 'wan-only', 'name': 'FAP320C-default', 'radio-1': {'mode': 'ap'}, 'radio-2': {'mode': 'ap'}, 'platform': {'type': '320C'}, 'max-clients': '0', 'channel': '"36" "40" "44" "48"'}}),
                              (variables.INFO_4, {'status': 1, 'data': {'comment': '', 'lbs': {'ekahau-blink-mode': 'disable'}, 'wan-port-mode': 'wan-only', 'name': 'FAP320C-default', 'radio-1': {'mode': 'ap'}, 'radio-2': {'mode': 'ap'}, 'platform': {'type': '320C'}, 'max-clients': '0', 'channel': '"36" "40" "44" "48"'}})])
    def test_general_parser_get(self, info, expected_return):
        fap_obj = wireless()
        assert fap_obj.general_parser_get(info) == expected_return        

    @pytest.mark.parametrize("info, expected_return", 
                             [(variables.INFO_20, {'status': 1, 'data': {'system virtual-switch': {'"internal"': {'physical-switch': '"sw0"', 'port': {'"internal1"': {'status': 'up', 'alias': "''", 'X': 'Y'}}}}}}),
                              (variables.INFO_8, {'status': 1, 'data': {'system virtual-switch': {'"internal"': {'A': 'B', 'C': {'D': {'X': 'Y'}}, 'E': {'F': {'X': 'Y'}}, 'G': 'H'}}}}),
                              (variables.INFO_7, {'status': 1, 'data': {'system virtual-switch': {'"internal"': {'A': 'B', 'physical-switch': '"sw0"', 'port': {'"internal1"': {'X': 'Y', 'alias': "''", 'status': 'up'}}}}}}),
                              (variables.INFO_6, {'status': 1, 'data': {'system virtual-switch': {'"internal"': {'physical-switch': '"sw0"', 'port': {'"internal1"': {'status': 'up', 'alias': "''", 'X': 'Y'}}}}}}),
                              (variables.INFO_5, {'status': 1, 'data': {'system virtual-switch': {'"internal"': {'physical-switch': '"sw0"', 'port': {'"internal2"': {'alias': "''", 'speed': 'auto'}, '"internal1"': {'status': 'up', 'alias': "''"}}}}, 'system global': {'admin-concurrent': 'enable'}}})])
    def test_general_parser_show(self, info, expected_return):
        fap_obj = wireless()
        assert fap_obj.general_parser_show(info)[3] == expected_return
        
    @pytest.mark.parametrize("info, expected_return", 
                             [(variables.INFO_10, {'status': 1, 'data': [['bssid', 'ssid', 'intf', 'x:y', 'wtp-id', 'vfid:ip-port', 'rId', 'wId'], ['08:5b:0e:79:16:0c', 'fortinet', 'wifi', 'ab', 'FP320C3X14006196', 'ws(0-192.168.1.111:5246)', '0', '0'], ['08:5b:0e:ae:2d:38', 'fortinet', 'wifi', 'cd', 'FWF90D-WIFI0', 'ws(0-127.0.0.1:15246)', '0', '0']]}),
                              (variables.INFO_9, {'status': 1, 'data': [['bssid', 'ssid', 'intf', 'wtp-id', 'vfid:ip-port', 'rId', 'wId'], ['08:5b:0e:79:16:0c', 'fortinet', 'wifi', 'FP320C3X14006196', 'ws(0-192.168.1.111:5246)', '0', '0'], ['08:5b:0e:ae:2d:38', 'fortinet', 'wifi', 'FWF90D-WIFI0', 'ws(0-127.0.0.1:15246)', '0', '0']]})])
    def test_general_parser_diagnose_table(self, info, expected_return):
        fap_obj = wireless()
        assert fap_obj.general_parser_diagnose_table(info) == expected_return

    @pytest.mark.parametrize("info, expected_return", 
                             [(variables.INFO_15, {'status': 1, 'data': [{'wlan': 'wifi', 'vf': '0', 'ip': '0.0.0.0', 'chan': '6', 'cp_authed': 'no', 'vlan_id': '0', 'use': '4', 'group': '', 'vci': '', 'online': 'yes', 'wtp': '3', 'noise': '0', 'radio_type': '11N', 'host': '', 'bw': '0', 'user': '', 'encrypt': 'aes', 'rId': '1', 'signal': '0', 'mac': '08:5b:0e:ae:2d:38', 'idle': '396733', 'security': 'wpa2_only_personal'}, {'wtp': '3', 'use': '4', 'base': '08:5b:0e:ae:2d:38 127.0.0.1:1024<->127.0.0.1:5247', 'vf': '0'}, {'wtp': '3', 'use': '5', 'wlan': 'wifi', 'vf': '0', 'bssid': '08:5b:0e:ae:2d:38', 'lan': '0', 'idx': '0', 'in_kern': '1', 'tun': '01', 'vlan_id': '0', 'monitor': '0'}]}),
                              (variables.INFO_14, {'status': 1, 'data': [{'use': '4', 'lbr': '0', 'wlan': 'wifi UP', 'cpauth': '0', 'ip': '0.0.0.0/0', 'fast_roaming': '1', 'lsw': '1', 'mac': '00:ff:db:8c:96:70', 'bc_suppression': '3', 'sta_cnt': '1', 'intra_priv': '0', 'dynamic_vlan': '0'}, {'wtp': '3', 'use': '4', 'base': '08:5b:0e:ae:2d:38 127.0.0.1:1024<->127.0.0.1:5247', 'vf': '0'}, {'wtp': '3', 'lan': '0', 'wlan': 'wifi', 'vf': '0', 'bssid': '08:5b:0e:ae:2d:38', 'use': '5', 'idx': '0', 'in_kern': '1', 'tun': '01', 'vlan_id': '0', 'monitor': '0'}]}),
                              (variables.INFO_13, {'status': 1, 'data': [{'use': '4', 'lbr': '0', 'wlan': 'wifi UP', 'cpauth': '0', 'ip': '0.0.0.0/0', 'fast_roaming': '1', 'lsw': '1', 'mac': '00:ff:db:8c:96:70', 'bc_suppression': '3', 'sta_cnt': '1', 'intra_priv': '0', 'dynamic_vlan': '0'}]}),
                              (variables.INFO_12, {'status': 1, 'data': [{'wtp': '3', 'use': '4', 'base': '08:5b:0e:ae:2d:38 127.0.0.1:1024<->127.0.0.1:5247', 'vf': '0'}]}),
                              (variables.INFO_11, {'status': 1, 'data': [{'wlan': 'wifi', 'vf': '0', 'ip': '0.0.0.0', 'chan': '6', 'cp_authed': 'no', 'vlan_id': '0', 'use': '4', 'group': '', 'vci': '', 'online': 'yes', 'wtp': '3', 'noise': '0', 'radio_type': '11N', 'host': '', 'bw': '0', 'user': '', 'encrypt': 'aes', 'rId': '1', 'signal': '0', 'mac': '08:5b:0e:ae:2d:38', 'idle': '396733', 'security': 'wpa2_only_personal'}]})])
    def test_general_parser_diagnose_equal(self, info, expected_return):
        fap_obj = wireless()
        assert fap_obj.general_parser_diagnose_equal(info) == expected_return
        
    @pytest.mark.parametrize("info, expected_return", 
                             [(variables.INFO_16, {'status': 1, 'data': [{'LLDP': 'disabled', 'WTP': {'vd': 'root', 'name': '', 'refcnt': '3 own(1) wtpprof(1) ws(1)', 'location': ''}, 'Radio 1': {'txpower': '100% (calc 27 oper 0 max 0 dBm)', 'WIDS profile': {'wlan  0': 'wifi'}, 'max vaps': '8'}}, {'Radio 3': 'Not Exist', 'Radio 2': {'WIDS profile': '---'}, 'WTP': {'vd': 'root', 'last failure': '0 -- N/A', 'split-tunneling-local-ap-subnet': 'disabled'}, 'Radio 1': {'WIDS profile': {'wlan  0': 'wifi'}, 'country name': 'NA', 'max vaps': '8'}}]})])
    def test_general_parser_diagnose_colon(self, info, expected_return):
        fap_obj = wireless()
        assert fap_obj.general_parser_diagnose_colon(info) == expected_return

    @pytest.mark.parametrize("info, expected_return", 
                             [(variables.INFO_22, {'status': 1, 'data': {'WLAN (001/001)': {'mf acl cfg': 'disabled, allow, 0 entries', 'refcnt, deleted': '37  own(1) wtpprof(36) r', 'vlanid': '0 (auto vlan intf disabled)', 'vdom,name': 'root, wifi', 'ip, mac': '0.0.0.0, 00:ff:db:8c:96:70'}, 'WTP 0001': '0, FP320C3X14006196', 'C': 'D', 'WTP 0002': '0, FWF90D-WIFI0'}}),
                              (variables.INFO_21, {'status': 1, 'data': {'WLAN (001/001)': {'mf acl cfg': 'disabled, allow, 0 entries', 'refcnt, deleted': '37  own(1) wtpprof(36) r', 'vlanid': '0 (auto vlan intf disabled)', 'vdom,name': 'root, wifi', 'ip, mac': '0.0.0.0, 00:ff:db:8c:96:70'}, 'WTP 0001': '0, FP320C3X14006196', 'WTP 0002': '0, FWF90D-WIFI0'}}),
                              (variables.INFO_19, {'status': 1, 'data': {'WTP': {'vd': 'root', 'name': '', 'refcnt': '3 own(1) wtpprof(1) ws(1)', 'location': ''}, 'LLDP': 'disabled', 'Radio 1': {'txpower': '100% (calc 27 oper 0 max 0 dBm)', 'WIDS profile': {'A B': 'C', 'D': 'E', 'wlan  0': 'wifi'}, 'max vaps': '8'}}}),
                              (variables.INFO_18, {'status': 1, 'data': {'WTP': {'vd': 'root', 'name': '', 'refcnt': '3 own(1) wtpprof(1) ws(1)', 'location': ''}, 'LLDP': 'disabled', 'Radio 1': {'txpower': '100% (calc 27 oper 0 max 0 dBm)', 'WIDS profile': {'A B': 'C', 'D': 'E', 'wlan  0': 'wifi'}, 'max vaps': '8'}}}),
                              (variables.INFO_17, {'status': 1, 'data': {'LLDP': 'disabled', 'WTP': {'vd': 'root', 'name': '', 'refcnt': '3 own(1) wtpprof(1) ws(1)', 'location': ''}, 'Radio 1': {'txpower': '100% (calc 27 oper 0 max 0 dBm)', 'WIDS profile': {'wlan  0': 'wifi'}, 'max vaps': '8'}}})])
    def test_general_parser_colon(self, info, expected_return):
        fap_obj = wireless()
        assert fap_obj.general_parser_colon(info)[3] == expected_return