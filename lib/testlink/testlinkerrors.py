#! /usr/bin/python
# -*- coding: UTF-8 -*-

class TestLinkError(Exception):
    """ Basic error 
    Return message pass as argument
    """
#    def __init__(self, msg):
#        self.__msg = msg
#
#    def __str__(self):
#        return self.__msg

class TLConnectionError(TestLinkError):
    """ Connection error 
    - wrong url? - server not reachable? """
    
class TLAPIError(TestLinkError):
    """ API error 
    - wrong method name ? - misssing required args? """
