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

class TestFap(object): 
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
                             [(variables.INFO_8, {'status': 1, 'data': {'system virtual-switch': {'"internal"': {'A': 'B', 'C': {'D': {'X': 'Y'}}, 'E': {'F': {'X': 'Y'}}, 'G': 'H'}}}}),
                              (variables.INFO_7, {'status': 1, 'data': {'system virtual-switch': {'"internal"': {'A': 'B', 'physical-switch': '"sw0"', 'port': {'"internal1"': {'X': 'Y', 'alias': "''", 'status': 'up'}}}}}}),
                              (variables.INFO_6, {'status': 1, 'data': {'system virtual-switch': {'"internal"': {'physical-switch': '"sw0"', 'port': {'"internal1"': {'status': 'up', 'alias': "''", 'X': 'Y'}}}}}}),
                              (variables.INFO_5, {'status': 1, 'data': {'system virtual-switch': {'"internal"': {'physical-switch': '"sw0"', 'port': {'"internal2"': {'alias': "''", 'speed': 'auto'}, '"internal1"': {'status': 'up', 'alias': "''"}}}}, 'system global': {'admin-concurrent': 'enable'}}})])
    def test_general_parser_show(self, info, expected_return):
        fap_obj = wireless()
        assert fap_obj.general_parser_show(info)[3] == expected_return    