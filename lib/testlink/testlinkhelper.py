#! /usr/bin/python
# -*- coding: UTF-8 -*-

import os
from argparse import ArgumentParser
from version import VERSION


class TestLinkHelper(object):
    """ Helper Class to find out the TestLink connection parameters.
    a) TestLink Server URL of XMLRPC
       environment variable - TESTLINK_API_PYTHON_SERVER_URL
       default value        - http://localhost/testlink/lib/api/xmlrpc.php
       command line arg     - server_url
    b) Users devKey generated by TestLink
       environment variable - TESTLINK_API_PYTHON_DEVKEY
       default value        - 42 
       command line arg     - devKey
    """

    __slots__ = ['_server_url', '_devkey', '_testProjectName', '_testPlanName', '_buildName', '_platform', '_testResultFile']

    ENVNAME_SERVER_URL  = 'http://10.160.37.35/testlink/lib/api/xmlrpc/v1/xmlrpc.php'
    ENVNAME_DEVKEY      = '90a7e6f457a709b74e270bf5b5bd6693'
    DEFAULT_SERVER_URL  = 'http://10.160.37.35/testlink/lib/api/xmlrpc/v1/xmlrpc.php'
    DEFAULT_DEVKEY      = '90a7e6f457a709b74e270bf5b5bd6693'
    DEFAULT_DESCRIPTION = 'Python XMLRPC client for the TestLink API v%s' \
                            % VERSION

    def __init__(self, server_url=None, devkey=None):
        """ fill slots _server_url and _devkey
        Priority:
        1. init args 
        2. environment variables 
        3. default values
        """
        self._server_url = server_url
        self._devkey     = devkey
        self._testProjectName  = None
        self._testPlanName  = None
        self._buildName  = None
        self._platform  = None
        self._testResultFile  = None
        self._setParamsFromEnv()
        
    def _setParamsFromEnv(self):
        """ fill empty slots _server_url and _devkey from environment variables
        _server_url <- TESTLINK_API_PYTHON_SERVER_URL
        _devkey     <- TESTLINK_API_PYTHON_DEVKEY
        
        If environment variables are not defined, defaults values are set.
        """
        if self._server_url == None:
            self._server_url = os.getenv(self.ENVNAME_SERVER_URL, 
                                         self.DEFAULT_SERVER_URL)
        if self._devkey == None:
            self._devkey = os.getenv(self.ENVNAME_DEVKEY, self.DEFAULT_DEVKEY)

    def _createArgparser(self, usage):
        """ returns a parser for command line arguments """
        
        a_parser = ArgumentParser( description=usage)
        # optional command line parameters
        a_parser.add_argument('--server_url', default=self._server_url,
                help='TestLink Server URL of XMLRPC (default: %(default)s) ')
        a_parser.add_argument('--devKey', default=self._devkey,
            help='devKey generated by TestLink (default: %(default)s) ')
        a_parser.add_argument('--testProjectName', default=self._testProjectName,
            help='testProjectName defined in TestLink (default: %(default)s) ')
        a_parser.add_argument('--testPlanName', default=self._testPlanName,
            help='testPlanName defined in TestLink (default: %(default)s) ')
        a_parser.add_argument('--buildName', default=self._buildName,
            help='buildName defined in TestLink (default: %(default)s) ')
        a_parser.add_argument('--platform', default=self._platform,
            help='platform defined in TestLink (default: %(default)s) ')
        a_parser.add_argument('--testResultFile', default=self._testResultFile,
            help='testResultFile generated by pybot in JUNIT.XML format (default: %(default)s) ')
        return a_parser

    def setParamsFromArgs(self, usage=DEFAULT_DESCRIPTION, args=None):
        """ fill slots _server_url and _devkey from command line arguments 
        _server_url <- --server_url
        _devkey     <- --devKey
        
        uses current values of these slots as default values 
        """
        a_parser = self._createArgparser(usage)
        args     = a_parser.parse_args(args)
        self._server_url = args.server_url
        self._devkey     = args.devKey
        self._testProjectName  = args.testProjectName
        self._testPlanName  = args.testPlanName
        self._buildName  = args.buildName
        self._platform  = args.platform
        self._testResultFile  = args.testResultFile
        
    def connect(self, tl_api_class):
        """ returns a new instance of TL_API_CLASS """
        return tl_api_class(self._server_url, self._devkey)
