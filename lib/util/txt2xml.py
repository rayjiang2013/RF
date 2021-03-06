from argparse import ArgumentParser
import sys, os, re
import pdb

DEFAULT_DESCRIPTION = 'python txt2xml.py --txtfile txtfilename --status status --importance importance --execution_type execution_type --keyword keyword'

def _createArgparser(usage):
    '''  
    returns a parser for command line arguments
    '''
    a_parser = ArgumentParser( description=usage)
    # optional command line parameters
    a_parser.add_argument('--txtfile', default=None,
        help='Test cases file in txt format (default: %(default)s) ')
    a_parser.add_argument('--status', default=1,
        help='1~7: 1=Draft, 2=Read for Review, 3=Review in Progress, 4=Rework, 5=Obsolete, 6=Future, 7=Final: (default: %(default)s) ')
    a_parser.add_argument('--importance', default=2,
        help='1~3: 1=High, 2=Medium, 3=Low: (default: %(default)s) ')
    a_parser.add_argument('--execution_type', default=None,
        help='1~2: 1=Manual, 2=Automated: (default: %(default)s) ')
    a_parser.add_argument('--keyword', default=None,
        help='Robot Framework Tag: Used to search test suite and test cases: (default: %(default)s) ')
    return a_parser

def _setParamsFromArgs(usage=DEFAULT_DESCRIPTION, args=None):
    ''' 
    fill slots _txtfile from command line argument
    txtfile <- --txtfile
    status <- --status
    importance <- --importance
    execution_type <- --execution_type
    keyword <- --keyword
    uses current values of these slots as default values
    '''
    a_parser = _createArgparser(usage)
    args     = a_parser.parse_args(args)
    return(args)

def text2xml(txtfile, status, importance, execution_type, keyword):
    '''
    This python API converts textfile to xml format file
    '''
    try:
        # confirm tbinfo file exist
        if not os.path.exists(txtfile):
            raise Exception("Please provides a valid tc file: %s" % txtfile)

        if int(status) < 1 or int(status) > 7:
            raise Exception('Invalid status value. Has to be integer and 1 ~ 7') 

        if int(importance) < 1 or int(importance) > 3:
            raise Exception('Invalid importance value. Has to be integer and 1 ~ 3') 

        if int(execution_type) < 1 or int(execution_type) > 2:
            raise Exception('Invalid execution_type value. Has to be integer and 1 ~ 2') 

        # Read txtfile
        fid = open(txtfile, 'r')
        tc_data = fid.read()
        fid.close()

        # initialize xml_data
        xml_data = '<?xml version="1.0" encoding="UTF-8"?>\n'

        tc_data_list = tc_data.split("\n")
        testSuiteStage = 0
        suite_id = 1
        testsuiteClose = None
        testSubsuiteClose = None
        stepsClose = None

        # each test suite starts with TestSuiteName::
        for line in tc_data_list:

            line = line.strip('\n')
            line = line.strip('\r')
            line = re.sub('\t', ' ', line, re.DOTALL)
            line = re.sub('"', '', line, re.DOTALL)
            line = re.sub('&', ' and ', line, re.DOTALL)
            line = re.sub(r'(\xc2|\x92|\x93|\x94)', '', line, re.DOTALL)
            line = re.sub('/', ' ', line, re.DOTALL)
            line = re.sub('\s+', ' ', line, re.DOTALL)
            line = re.sub('_', '-', line, re.DOTALL)
 
            # start a new suite section
            if re.match(r'TestSuiteName::', line):
                testcase_id = 1
                testSuiteStage = 1
                continue

            re_line = re.match(r'^[0-9]+\.[0-9]+\s(.*)', line)
            if re_line and testSuiteStage == 1:
                xml_data = xml_data + '<testsuite name="' + re_line.group(1)+'" id="">\n'
                xml_data = xml_data + ' <node_order><![CDATA[' + str(testcase_id) + ']]></node_order>\n'
                testsuiteClose = '</testsuite>\n'
                testSuiteStage = 2
                testcase_id += 1
                continue
            re_line = re.match(r'^Summary::\s(.*)', line)
            if re_line and testSuiteStage == 2:
                xml_data = xml_data + ' <details>"' + re_line.group(1) + '"</details>\n'
                if keyword != None:
                    xml_data = xml_data + ' <keywords><keyword name="' + keyword + '"><notes><![CDATA[]]></notes></keyword></keywords>\n'
                testSuiteStage = 3
                continue
            # start a sub-suite section
            re_line = re.match(r'^[0-9]+\.[0-9]+\.[0-9]+\s(.*)', line)
            if re_line and testSuiteStage == 3:
                xml_data = xml_data + ' <testsuite name="' + re_line.group(1) +'" id="' + str(suite_id) + '">\n'
                xml_data = xml_data + '  <node_order><![CDATA[' + str(testcase_id) + ']]></node_order>\n'
                testSubsuiteClose = ' </testsuite>\n'
                testSuiteStage = 4
                continue
            re_line = re.match(r'^Summary::\s(.*)', line)
            if re_line and testSuiteStage == 4:
                xml_data = xml_data + '  <details>"' + re_line.group(1) + '"</details>\n'
                if keyword != None:
                    xml_data = xml_data + '  <keywords><keyword name="' + keyword + '"><notes><![CDATA[]]></notes></keyword></keywords>\n'
                testSuiteStage = 5
                continue
            # start test cases
            re_line = re.match(r'^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\s(.*)', line)
            if re_line and testSuiteStage == 5:
                xml_data = xml_data + '  <testcase name="' + re_line.group(1) + '" internalid="' + str(testcase_id) + '">\n'
                xml_data = xml_data + '   <node_order><![CDATA[' + str(testcase_id) + ']]></node_order>\n'
                xml_data = xml_data + '   <externalid><![CDATA["' + str(testcase_id) + '"]]></externalid>\n'
                xml_data = xml_data + '   <version><![CDATA[1]]></version>\n'
                testcase_id += 1
                testCaseClose = None
                testSuiteStage = 6
                continue
            re_line = re.match(r'^Summary::\s(.*)', line)
            if re_line and testSuiteStage == 6:
                xml_data = xml_data + '   <summary>"' + re_line.group(1) + '"</summary>\n'
                xml_data = xml_data + '   <preconditions><![CDATA[]]></preconditions>\n'
                xml_data = xml_data + '   <importance><![CDATA[%s]]></importance>\n' % str(importance)
                xml_data = xml_data + '   <execution_type><![CDATA[%s]]></execution_type>\n' % str(execution_type)
                xml_data = xml_data + '   <estimated_exec_duration>3.00</estimated_exec_duration>\n'
                xml_data = xml_data + '   <status><![CDATA[%s]]></status>\n' % str(status)
                if keyword != None:
                    xml_data = xml_data + '   <keywords><keyword name="' + keyword + '"><notes><![CDATA[]]></notes></keyword></keywords>\n'
                testSuiteStage = 7
                continue
            # start text case steps
            if re.match(r'^Steps::', line) and testSuiteStage == 7:
                stepsOpen = '   <steps><step>\n'
                stepsClose = '   </step></steps>\n'
                step_data = ""
                testSuiteStage = 8
                step_number = 0
                continue
            if re.match(r'^[0-9]+\.\s(.*)', line) and testSuiteStage == 8:
                step_data = step_data + '    <p>' + line + '</p>\n'
                step_number += 1
                continue
            if re.match(r'^ExpectedResults::', line) and testSuiteStage == 8:
                testSuiteStage = 9
                continue
            if testSuiteStage == 9:
                testSuiteStage = 5
                if step_data == "":
                    xml_data = xml_data + '  </testcase>'
                    continue
                xml_data = xml_data + stepsOpen
                stepsOpen = None
                xml_data = xml_data + '   <step_number><![CDATA[' + str(step_number) + ']]></step_number>\n'
                xml_data = xml_data + '   <actions><![CDATA[' + step_data + ']]></actions>\n'
                xml_data = xml_data + '   <expectedresults><![CDATA[<p>' + line + '</p>]]></expectedresults>\n'
                xml_data = xml_data + '   <execution_type><![CDATA[1]]></execution_type>\n'
                xml_data = xml_data + stepsClose
                xml_data = xml_data + '  </testcase>\n'
                stepsClose = None
                continue
            if re.match(r'Section::', line) and testSubsuiteClose != None:
                xml_data = xml_data + testSubsuiteClose
                testSubsuiteClose = None
                testSuiteStage = 3
                suite_id += 1
            if re.match(r'^[0-9a-zA-Z]+', line) and testSuiteStage == 8:
                step_data = step_data + '      <p>' + '\t' + line + '</p>\n'
                continue

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
        importance = cli_args.importance
        execution_type = cli_args.execution_type
        keyword = cli_args.keyword
        if txtfile == None:
            raise Exception('"python txt2xml.py -h" for a help')
        status_data = text2xml(txtfile, status, importance, execution_type, keyword)
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
