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
        