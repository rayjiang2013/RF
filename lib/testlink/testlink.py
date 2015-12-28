#! /usr/bin/python
# -*- coding: UTF-8 -*-

from robot.api import logger
from testlinkapi import TestlinkAPIClient, TestLinkHelper
from testlinkerrors import TestLinkError, TLAPIError
from datetime import date
import parseXml
import re, os
import pdb

class TestLink(TestlinkAPIClient):
    """
    TestLink API library 
    provide a user friendly library, with more robustness and error management
    """

    def __init__(self, server_url, key):
        """
        Class initialisation
        """
        super(TestLink, self).__init__(server_url, key)

    def getTestCaseIDByName(self, testCaseName, testSuiteName, testProjectName):
        """
        Find a test case by its name, by its suite and its project
        Suite name must not be duplicate, so only one test case must be found 
        Return test case id if success 
        or raise TestLinkError exception with error message in case of error
        """    
        results = super(TestLink, self).getTestCaseIDByName(testCaseName, testSuiteName, testProjectName)
        if results[0].has_key("message"):
            raise TestLinkError(results[0]["message"])
        elif len(results) > 1:
            raise TestLinkError("(getTestCaseIDByName) - Several case test found. Suite name must not be duplicate for the same project")
        else:
            if results[0]["name"] == testCaseName:
                    return results[0]["id"]
            raise TestLinkError("(getTestCaseIDByName) - Internal server error. Return value is not expected one!")


    def reportResult(self, testResult, testCaseName, testSuiteName, testNotes="", **kwargs):
        """
        Report results for test case
        Arguments are:
        - testResult: "p" for passed, "b" for blocked, "f" for failed
        - testCaseName: the test case name to report
        - testSuiteName: the test suite name that support the test case
        - testNotes: optional, if empty will be replace by a default string. To let it blank, just set testNotes to " " characters
        - an anonymous dictionnary with followings keys:
            - testProjectName: the project to fill
            - testPlanName: the active test plan
            - buildName: the active build.
            - platform: the active build.
        Raise a TestLinkError error with the error message in case of trouble
        Return the execution id needs to attach files to test execution
        """
        
        try:
            # Check parameters
            for data in ["testProjectName", "testPlanName", "buildName"]:
                if not kwargs.has_key(data):
                    raise TestLinkError("(reportResult) - Missing key %s in anonymous dictionnary" % data)

            # Get project id
            project = self.getTestProjectByName(kwargs["testProjectName"])

            # Check if project is active
            if project['active'] != '1':
                raise TestLinkError("(reportResult) - Test project %s is not active" % kwargs["testProjectName"])

            # Check test plan name
            plan = self.getTestPlanByName(kwargs["testProjectName"], kwargs["testPlanName"])

            # Check is test plan is open and active
            if plan['is_open'] != '1' or plan['active'] != '1':
                raise TestLinkError("(reportResult) - Test plan %s is not active or not open" % kwargs["testPlanName"])
            # Memorise test plan id
            planId = plan['id']

            # Check build name
            build = self.getBuildByName(kwargs["testProjectName"], kwargs["testPlanName"], kwargs["buildName"])

            # Check if build is open and active
            if build['is_open'] != '1' or build['active'] != '1':
                raise TestLinkError("(reportResult) - Build %s in not active or not open" % kwargs["buildName"])

            # Get test case id
            caseId = self.getTestCaseIDByName(testCaseName, testSuiteName, kwargs["testProjectName"])

            # Check results parameters
            if testResult not in "pbf":
                raise TestLinkError("(reportResult) - Test result must be 'p', 'f' or 'b'")

            if testNotes == "":
                # Builds testNotes if empty
                today = date.today()
                testNotes = "%s - Test performed automatically" % today.strftime("%c")
            elif testNotes == " ":
                #No notes
                testNotes = ""

            logger.console("testNotes: %s" % testNotes)
            # Now report results
            results = self.reportTCResult(caseId, planId, kwargs["buildName"], testResult, testNotes, kwargs["platformname"])
            # Check errors
            if results[0]["message"] != "Success!":
                raise TestLinkError(results[0]["message"])
        except Exception as msg:
            logger.console(msg)
            return -1
        except:
            logger.console('System Unexpected error: %s' % sys.exc_info()[0])
            return -1

        return results[0]['id']

    def getTestProjectByName(self, testProjectName):
        """
        Return project
        A TestLinkError is raised in case of error
        """
        results = super(TestLink, self).getTestProjectByName(testProjectName)
        if results[0].has_key("message"):
            raise TestLinkError(results[0]["message"])

        return results[0]

    def getTestPlanByName(self, testProjectName, testPlanName):
        """
        Return test plan
        A TestLinkError is raised in case of error
        """
        results = super(TestLink, self).getTestPlanByName(testProjectName, testPlanName)
        if results[0].has_key("message"):
            raise TestLinkError(results[0]["message"])

        return results[0]

    def getBuildByName(self, testProjectName, testPlanName, buildName):
        """
        Return build corresponding to buildName
        A TestLinkError is raised in case of error
        """
        plan = self.getTestPlanByName(testProjectName, testPlanName)
        builds = self.getBuildsForTestPlan(plan['id'])

        # Check if a builds exists
        if builds == '':
            raise TestLinkError("(getBuildByName) - Builds %s does not exists for test plan %s" % (buildName, testPlanName))

        # Search the correct build name in the return builds list
        for build in builds:
            if build['name'] == buildName:
                return build
        
        # No build found with builName name
        raise TestLinkError("(getBuildByName) - Builds %s does not exists for test plan %s" % (buildName, testPlanName))

def report_test_result(testProjectName, testPlanName, buildName, platform, testResultFile):
    """
    This method is for robot framework specifically
    """
    try:
        pdata = parseXml.xml_parser(testResultFile)
        if len(pdata) == 0:
            logger.console("Test result wouldn't log to Testlink due to cannot locate the test result file")
            return 1

        tl_helper = TestLinkHelper()
        myTestLink = tl_helper.connect(TestLink)

        suiteName = pdata['suite']['name']
        suiteFailures = pdata['suite']['failures']
        suiteTests = pdata['suite']['tests']
        suiteErrors = pdata['suite']['errors']
        suiteSkips = pdata['suite']['skip']
        logger.console("suiteName=%s, suiteFailures=%s, suiteTests=%s, suiteErrors=%s, suiteSkips=%s" % (suiteName, suiteFailures, suiteTests, suiteErrors, suiteSkips))

        keys = pdata.keys()
        logger.console("keys=%s" % keys)

        tc_name_list = []
        for key in keys:
            if key != 'suite':
                tc_name_list.append(key)

        logger.console("tc_name_list=%s" % tc_name_list)

        kwargs = {
            'testProjectName':testProjectName,
            'testPlanName':testPlanName,
            'buildName':buildName,
            'platformname':platform,
        }

        for tc in tc_name_list:
            suites, scriptname = os.path.splitext(pdata[tc]['classname'])
            notes, suiteName = os.path.splitext(suites)
            suiteName = re.sub('\.', '', suiteName, re.DOTALL)
            notes = re.sub('\.', '::', notes, re.DOTALL)
            reportResult = myTestLink.reportResult(tc, pdata[tc]['status'], suiteName, notes, **kwargs)
            logger.console('testCase=%s, reportResult=%s' % reportResult)

    except Exception as msg:
        raise TestLinkError("report_test_result fails %s" % msg)
        return 0
    return 1

def main():
    """
    Usage: python testlink.py --testProjectName 'Hellos' --testPlanName 'Hellos-plan' --buildName 'hello_1' --platform '1048D' --testResultFile '/var/www/html/Jenkins/workspace/Hellos/junit.xml'
    Or python testlink.py -h for a help
    """
    try:
        tl_helper = TestLinkHelper()
        tl_helper.setParamsFromArgs()
        myTestLink = tl_helper.connect(TestLink)
        #logger.console('myTestLink=%s' % myTestLink)
        #logger.console('myTestLink.about()=%s' % myTestLink.about())

        if tl_helper._testProjectName is None: 
            logger.console("Missing Argument: testProjectName. Get help using 'python testlink.py -h'")
            return 0
        if tl_helper._testPlanName is None: 
            logger.console("Missing Argument: testPlanName. Get help using 'python testlink.py -h'")
            return 0
        if tl_helper._buildName is None: 
            logger.console("Missing Argument: buildName. Get help using 'python testlink.py -h'")
            return 0
        if tl_helper._platform is None: 
            logger.console("Missing Argument: platform. Get help using 'python testlink.py -h'")
            return 0
        if tl_helper._testResultFile is None: 
            logger.console("Missing Argument: testResultFile. Get help using 'python testlink.py -h'")
            return 0
        
        pdata = parseXml.xml_parser(tl_helper._testResultFile)
        if len(pdata) == 0:
            logger.console("Test result wouldn't log to Testlink due to cannot locate the test result file")
            return 1

        suiteName = pdata['suite']['name']
        suiteFailures = pdata['suite']['failures']
        suiteTests = pdata['suite']['tests']
        suiteErrors = pdata['suite']['errors']
        suiteSkips = pdata['suite']['skip']

        keys = pdata.keys()
        tc_name_list = []
        for key in keys:
            if key != 'suite':
                tc_name_list.append(key)

        kwargs = {
            'testProjectName':tl_helper._testProjectName,
            'testPlanName':tl_helper._testPlanName,
            'buildName':tl_helper._buildName,
            'platformname':tl_helper._platform,
        }

        for tc in tc_name_list:
            suites, scriptname = os.path.splitext(pdata[tc]['classname'])
            notes, suiteName = os.path.splitext(suites)
            suiteName = re.sub('\.', '', suiteName, re.DOTALL)
            notes = re.sub('\.', '::', notes, re.DOTALL)
            #pdb.set_trace()
            reportResult = myTestLink.reportResult(pdata[tc]['status'], tc, suiteName, notes, **kwargs)
            if reportResult == -1:
                logger.console('Unable reportResult: notes=%s, suiteName=%s, testCase=%s' % (notes, suiteName, tc))
            else: 
                logger.console('notes=%s, suiteName=%s, testCase=%s, reportResult=%s' % (notes, suiteName, tc, reportResult))

    except Exception as msg:
        logger.console("report_test_result fails %s" % msg)
        return 0

    return 1

if __name__ == "__main__":
    main()
    #report_test_result('hello', 'hello-plan', 'hello-1', '1048D', '/hme/jimhe/working/cfg/jimhe-tb/juint.xml')
