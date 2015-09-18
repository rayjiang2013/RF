#! /usr/bin/python
# -*- coding: UTF-8 -*-

from robot.api import logger
import sys, os
import xml.etree.ElementTree as ET
from argparse import ArgumentParser
from version import VERSION
import pdb
 
class xmlParser(object):
    '''
    parse Jenkins test result file in xml format (juint.xml) file and returns a dictionary
    '''
    __slots__ = ['_testResultFile']

    DEFAULT_TESTRESULTFILE  = '/var/www/html/Jenkins/workspace/juint.xml'
    DEFAULT_DESCRIPTION = 'Parse test result file in xml format (juint.xml) v%s' \
                            % VERSION

    def __init__(self, testResultFile=None):
        """ fill slots _testResultFile
        Priority:
        1. init args
        2. environment variables
        3. default values
        """
        self._testResultFile = testResultFile
        self._setParamsFromEnv()

    def _setParamsFromEnv(self):
        """ fill empty slots _testResultFile from environment variables
        _testResultFile <- DEFAULT_TESTRESULTFILE
        If environment variables are not defined, defaults values are set.
        """
        if self._testResultFile == None:
            self._testResultFile = os.getenv(self.DEFAULT_TESTRESULTFILE,
                                         self.DEFAULT_TESTRESULTFILE)

    def _createArgparser(self, usage):
        """ returns a parser for command line arguments """

        a_parser = ArgumentParser( description=usage)
        # optional command line parameters
        a_parser.add_argument('--testResultFile', default=self._testResultFile,
                help='xmlParser argument (default: %(default)s) ')
        return a_parser

    def setParamsFromArgs(self, usage=DEFAULT_DESCRIPTION, args=None):
        """ fill slots _testResultFile from command line arguments
        _testResultFile <- --testResultFile
        uses current values of these slots as default values
        """
        a_parser = self._createArgparser(usage)
        args     = a_parser.parse_args(args)
        self._testResultFile = args.testResultFile

def xml_parser(testResultFile):
    """
    This method is for robot framework specifically
    """
    if not os.path.exists(testResultFile):
        logger.console("Please provides a valid testResultFile: %s" % testResultFile)
        return {}

    xmlp = xmlParser(testResultFile)
    tree = ET.parse(xmlp._testResultFile)
    root = tree.getroot()

    parsed_data = {}
    suite_data = {
        'failures':root.attrib['failures'],
        'name':root.attrib['name'],
        'tests':root.attrib['tests'],
        'errors':root.attrib['errors'],
        'skip':root.attrib['skip'],
    }
    parsed_data['suite'] = suite_data

    for child in root:
        if child.tag == 'testcase':
            child_data = {
                'classname':child.attrib['classname'],
                'time':child.attrib['time'],
                'status':'p'
            }
            for status in child:
                if status.tag == 'failure':
                    child_data['status']='f'
                elif status.tag == 'error':
                    child_data['status']='e'
                elif status.tag == 'skip':
                    child_data['status']='s'
                else:
                    child_data['status']='n'
                    
            parsed_data[child.attrib['name']] = child_data

    return(parsed_data)

def main():
    """
    Usage: python parseXml.py --testResultFile '/var/www/html/Jenkins/workspace/fswConfig/junit.xml''
           python testlink.py -h for a help
    """
    xmlp = xmlParser()
    xmlp.setParamsFromArgs()

    if xmlp._testResultFile is None:
        logger.console("Missing Argument: testResultFile. Get help using 'python parseXml.py -h'")
        return 0

    if not os.path.exists(xmlp._testResultFile):
        logger.console("testResultFile has to exists. Get help using 'python parseXml.py -h'")
        return 0

    tree = ET.parse(xmlp._testResultFile)
    root = tree.getroot()

    parsed_data = {}
    suite_data = {
        'failures':root.attrib['failures'],
        'tests':root.attrib['tests'],
        'errors':root.attrib['errors'],
        'name':root.attrib['name'],
        'skip':root.attrib['skip'],
    }
    parsed_data['suite'] = suite_data
    
    for child in root:
        if child.tag == 'testcase':
            child_data = {
                'classname':child.attrib['classname'],
                'time':child.attrib['time'],
            }
            parsed_data[child.attrib['name']] = child_data

    return parsed_data

if __name__ == "__main__":
    pdata = main()
    logger.console(pdata)
