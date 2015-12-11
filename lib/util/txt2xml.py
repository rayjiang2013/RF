from argparse import ArgumentParser
import sys, os, re
import pdb

DEFAULT_DESCRIPTION = 'python txt2xml.py --txtfile txtfilename --keyword keyword'

def _createArgparser(usage):
    '''  
    returns a parser for command line arguments
    '''
    a_parser = ArgumentParser( description=usage)
    # optional command line parameters
    a_parser.add_argument('--txtfile', default=None,
        help='Test cases file in txt format (default: %(default)s) ')
    a_parser.add_argument('--status', default=1,
        help='Test cases status: (default: %(default)s) ')
    a_parser.add_argument('--keyword', default=None,
        help='Search test suite and test cases: (default: %(default)s) ')
    return a_parser

def _setParamsFromArgs(usage=DEFAULT_DESCRIPTION, args=None):
    ''' 
    fill slots _txtfile from command line argument
    txtfile <- --txtfile
    status <- --status
    keyword <- --keyword
    uses current values of these slots as default values
    '''
    a_parser = _createArgparser(usage)
    args     = a_parser.parse_args(args)
    return(args)

def text2xml(txtfile, status, keyword):
    '''
    This python API converts textfile to xml format file
    '''
    try:
        # confirm tbinfo file exist
        if not os.path.exists(txtfile):
            raise Exception("Please provides a valid tc file: %s" % txtfile)

        # Read txtfile
        fid = open(txtfile, 'r')
        tc_data = fid.read()
        fid.close()

        # initialize xml_data
        xml_data = '<?xml version="1.0" encoding="UTF-8"?>'

        tc_data_list = tc_data.split("\n")
        testSuiteStage = 0
        suite_id = 1
        testsuiteClose = None
        testSubsuiteClose = None
        stepsClose = None

        # each test suite starts with TestSuiteName::
        for line in tc_data_list:

            # start a new suite section
            if re.match(r'TestSuiteName::', line):
                testcase_id = 1
                testSuiteStage = 1
                continue

            re_line = re.match(r'^[0-9]+\.[0-9]+\s(.*)', line)
            if re_line and testSuiteStage == 1:
                xml_data = xml_data + '<testsuite name="' + re_line.group(1)+'" id="">'
                xml_data = xml_data + '<node_order><![CDATA[' + str(testcase_id) + ']]></node_order>'
                testsuiteClose = '</testsuite>'
                testSuiteStage = 2
                testcase_id += 1
                continue
            re_line = re.match(r'^Summary::\s(.*)', line)
            if re_line and testSuiteStage == 2:
                xml_data = xml_data + '<details>"' + re_line.group(1) + '"</details>'
                if keyword != None:
                    xml_data = xml_data + '<keywords><keyword name="' + keyword + '"><notes><![CDATA[]]></notes></keyword></keywords>'
                testSuiteStage = 3
                continue
            # start a sub-suite section
            re_line = re.match(r'^[0-9]+\.[0-9]+\.[0-9]+\s(.*)', line)
            if re_line and testSuiteStage == 3:
                xml_data = xml_data + '<testsuite name="' + re_line.group(1) +'" id="' + str(suite_id) + '">'
                xml_data = xml_data + '<node_order><![CDATA[' + str(testcase_id) + ']]></node_order>'
                testSubsuiteClose = '</testsuite>'
                testSuiteStage = 4
                continue
            re_line = re.match(r'^Summary::\s(.*)', line)
            if re_line and testSuiteStage == 4:
                xml_data = xml_data + '<details>"' + re_line.group(1) + '"</details>'
                if keyword != None:
                    xml_data = xml_data + '<keywords><keyword name="' + keyword + '"><notes><![CDATA[]]></notes></keyword></keywords>'
                testSuiteStage = 5
                continue
            # start test cases
            re_line = re.match(r'^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\s(.*)', line)
            if re_line and testSuiteStage == 5:
                xml_data = xml_data + '<testcase name="' + re_line.group(1) + '" internalid="' + str(testcase_id) + '">'
                xml_data = xml_data + '<node_order><![CDATA[' + str(testcase_id) + ']]></node_order>'
                xml_data = xml_data + '<externalid><![CDATA["' + str(testcase_id) + '"]]></externalid>'
                xml_data = xml_data + '<version><![CDATA[1]]></version>'
                testcase_id += 1
                testCaseClose = None
                testSuiteStage = 6
                continue
            re_line = re.match(r'^Summary::\s(.*)', line)
            if re_line and testSuiteStage == 6:
                xml_data = xml_data + '<summary>"' + re_line.group(1) + '"</summary>'
                xml_data = xml_data + '<preconditions><![CDATA[]]></preconditions>'
                xml_data = xml_data + '<importance><![CDATA[2]]></importance>'
                xml_data = xml_data + '<estimated_exec_duration>1.00</estimated_exec_duration>'
                xml_data = xml_data + '<status>"' + str(status) + '"</status>'
                if keyword != None:
                    xml_data = xml_data + '<keywords><keyword name="' + keyword + '"><notes><![CDATA[]]></notes></keyword></keywords>'
                testSuiteStage = 7
                continue
            # start text case steps
            if re.match(r'^Steps::', line) and testSuiteStage == 7:
                stepsOpen = '<steps><step>'
                stepsClose = '</step></steps>'
                step_data = ""
                testSuiteStage = 8
                step_number = 0
                continue
            if re.match(r'^[0-9]+\.\s(.*)', line) and testSuiteStage == 8:
                step_data = step_data + '<p>' + line + '</p>'
                step_number += 1
                continue
            if re.match(r'^ExpectedResults::', line) and testSuiteStage == 8:
                testSuiteStage = 9
                continue
            if testSuiteStage == 9:
                testSuiteStage = 5
                if step_data == "":
                    xml_data = xml_data + '</testcase>'
                    continue
                xml_data = xml_data + stepsOpen
                stepsOpen = None
                xml_data = xml_data + '<step_number><![CDATA[' + str(step_number) + ']]></step_number>'
                xml_data = xml_data + '<actions><![CDATA[' + step_data + ']]></actions>'
                xml_data = xml_data + '<expectedresults><![CDATA[<p>' + line + '</p>]]></expectedresults>'
                xml_data = xml_data + '<execution_type><![CDATA[1]]></execution_type>'
                xml_data = xml_data + stepsClose
                xml_data = xml_data + '</testcase>'
                stepsClose = None
                continue
            if re.match(r'Section::', line) and testSubsuiteClose != None:
                xml_data = xml_data + testSubsuiteClose
                testSubsuiteClose = None
                testSuiteStage = 3
                suite_id += 1

        if testSubsuiteClose != None:
            xml_data = xml_data + testSubsuiteClose
        if testsuiteClose != None:
            xml_data = xml_data + testsuiteClose

        if len(xml_data) <= 38:
            raise Exception('Incorrect txtfile format')

        status_data = {'status':1, 'xml_data':xml_data}

    except Exception as msg:
        error_msg = 'text2xml %s Exception: %s' % (txtfile,msg)
        status_data = {'status':0, 'msg':error_msg}

    finally:
        return(status_data)

def main():
    '''
    main function. Returns 1 if succeed. Otherwise returns 0
    '''
    try:
        cli_args = _setParamsFromArgs()
        txtfile = cli_args.txtfile
        status = cli_args.status
        keyword = cli_args.keyword
        if txtfile == None:
            raise Exception('"python txt2xml.py -h" for a help')
        status_data = text2xml(txtfile, status, keyword)
        if status_data['status'] != 1:
            raise Exception(status_data['msg'])
        (prefix, sep, suffix) = txtfile.rpartition('.')
        xml_file_name = prefix + '.xml'
        fid = open(xml_file_name, 'w')
        fid.write(status_data['xml_data'])
        fid.close()
        status_data = {'status':1}
    except Exception as e:
        status_data = {'status':0, 'msg':e}
    except:
        e = 'Unexpected error: %s' % sys.exc_info()[0]
        status_data = {'status':0, 'msg':e}
    finally:
        return(status_data)

if __name__ == "__main__":
    exit(main())
