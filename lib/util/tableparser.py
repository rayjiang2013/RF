#!/usr/bin/python
# Table parser
# Author: Jim He
#
from robot.api import logger
import util
import re, sys
import pdb

"""
   tableParser -- A library for parsing a table and returning
   the table content in a dictionary. The key of the dictionary
   is the title of the table.
   Mandatory parameters:
      header: header of the table
      table:  table to be parsed of
   Optional parameters:
      delimiter: 
"""

class tableParserLib(object):
    """
    tableParser Library class
    """
    def __init__(self, header, table, **args):
        self.header = header
        self.headerTitles = len(self.header.split())
        self.table = table
        self.opts = args

    def _getTableHeader(self):
        """
        _getTableHeader(self) returns status 0 if the header does not match the header of the table
        otherwise return the real header
        """
        try:
            status_data = {'status':0}

            # reorganize the header, converts it to a searchable string for regexp
            header_criteria = re.sub(r' ', ' +', self.header)
            header_criteria = re.sub(r'_', ' ', header_criteria)

            # search for header
            for line in self.table.split('\n'):
                if re.search(header_criteria, line):
                    status_data = {
                        'status':1,
                        'data':line
                    }
                    break
        except:
            e = '%s, Unexpected error: %s' % (_getTableHeader, sys.exc_info()[0])
            status_data = {'status':0, 'msg':e}
        finally:
            return(status_data)

    def _trimTable(self, real_header):
        """
        _trimTable(self, real_header) removes all extra lines before header,
        as well as all lines after delimiter if it is defined. This func returns the trimed table
        """
        # trim extra info from table
        try:
            status_data = {'status':0}
            if 'delimiter' in self.opts:
                t = re.search(r'(.*)'+(real_header)+r'\s+(.*)'+self.opts['delimiter'], self.table, re.DOTALL)
            else:
                t = re.search(r'(.*)'+(real_header)+r'\s+(.*)', self.table, re.DOTALL)
            tt = re.sub(r'(\\r)+', '', t.group(2), re.DOTALL)
            status_data = {
                'status':1,
                'data':tt
            }
        except:
            e = '%s, Unexpected error: %s' % (_trimTable, sys.exc_info()[0])
            status_data = {'status':0, 'data':e}
        finally:
            return(status_data)

    def _getTitlePositions(self, real_header):
        """
        _getTitlePositions returns a dictionary. Header title is the key and 
        each title's starting column and ending column pair as the valure
        """
        # trim extra info from table
        try:
            status_data = {'status':0}
            pre_title_name = ''
            columns = {}
            for title in self.header.split():
                t1 = re.sub(r'_', ' ', title)
                column = real_header.find(t1)
                if not columns.has_key(title):
                    columns[title] = [column]
                if pre_title_name != '':
                    columns[pre_title_name].append(column)
                pre_title_name = title
            end_of_header = len(real_header)
            if end_of_header > 130:
                columns[title].append(end_of_header)
            else:
                columns[title].append(130)
            status_data = {
                'status':1,
                'data':columns
            }
        except:
            e = '%s, Unexpected error: %s' % (_getTitlePositions, sys.exc_info()[0])
            status_data = {'status':0, 'data':e}
        finally:
            return(status_data)

    def _getTitleSequence(self):
        """
        _getTitleSequence returns a dictionary. Sequence number is the key and Header title is the value
        """
        # trim extra info from table
        try:
            status_data = {'status':0}
            sequence = {}
            sequence_number = 0
            for title in self.header.split():
                sequence[sequence_number] = title
                sequence_number += 1
            status_data = {
                'status':1,
                'data':sequence
            }
        except:
            e = '%s, Unexpected error: %s' % (_getTitleSequence, sys.exc_info()[0])
            status_data = {'status':0, 'data':e}
        finally:
            return(status_data)

    def _parseTableInPosition(self, header, table, columns):
        """
        _parseTableInPosition(self, header, table, columns) parses the table
        based on the header and title columns. parsed info is saved in a dictionary and 
        returned
        """
        # parse the table
        try:
            status_data = {'status':0}
            tmp_info = {}
            for line in table.split('\n'):
                if len(line) == 0:
                    continue
                if re.match(r'^\s+$', line):
                    break
                if re.match(r'^(_|-|=)+', line):
                    continue
                if re.match(r'header', line):
                    continue
                # parse data line
                for key, cols in columns.iteritems():
                    value = line[cols[0]:cols[1]].strip()
                    if not tmp_info.has_key(key):
                        tmp_info[key] = [value]
                    else:
                        tmp_info[key].append(value)

            # return the parsed info in a dictionary
            if tmp_info != {}:
                status_data = {
                    'status':1,
                    'data':tmp_info
            }
        except:
            e = '%s, Unexpected error: %s' % (_parseTableInPosition, sys.exc_info()[0])
            status_data = {'status':0, 'data':e}
        finally:
            return(status_data)

    def _parseTableInSequence(self, header, table, sequence):
        """
        _parseTableInSequence(self, header, table, sequence) parses the table
        based on the header and title sequence. parsed info is saved in a dictionary and
        returned
        """
        # parse the table
        try:
            header_len = len(header)
            status_data = {'status':0}
            tmp_info = {}
            for line in table.split('\r\n'):
                if len(line) == 0:
                    continue
                if re.match(r'^\s+$', line):
                    break
                if re.match(r'^(_|-|=)+', line):
                    continue
                if re.match(r'header', line):
                    continue
                # parse data line
                values = line.split()
                for sequence_number, title in sequence.iteritems():
                    if not tmp_info.has_key(title):
                        try:
                            tmp_info[title] = [values[sequence_number]]
                        except:
                            tmp_info[title] = ['']
                    else:
                        try:
                            tmp_info[title].append(values[sequence_number])
                        except:
                            tmp_info[title].append([''])
            # return the parsed info in a dictionary
            if tmp_info != {}:
                status_data = {
                    'status':1,
                    'data':tmp_info
            }
        except:
            e = '%s, Unexpected error: %s' % (_parseTableInPosition, sys.exc_info()[0])
            status_data = {'status':0, 'data':e}
        finally:
            return(status_data)

def tableParserInSequence(kwargs):
    """
    tableParserInPosition API callable via Robot Framework
    """
    func_name = tableParserInSequence.__name__

    try:
        status_data = {'status':0}
        table = kwargs.get('table','')
        header = kwargs.get('header','')
        delimit = kwargs.get('delimiter','')
        debug = int(kwargs.get('debug',0))

        if table == '' or header == '':
            logger.console('Usage: tableParser(table=table, header=header, [delimiter=delimiter])')
        else:
            if debug != 0:
                logger.console('header=%s\n' % header)
                logger.console('table=%s\n' % table)
                logger.console('delimit=%s\n' % delimit)
            if delimit != '':
                t = tableParserLib(header, table, delimiter=delimit)
            else:
                t = tableParserLib(header, table)
            tableHeader = t._getTableHeader()
            if tableHeader['status'] == 0:
               raise Exception('%s _getTableHeader fail: %s' % (func_name, tableHeader))
            if debug != 0:
               logger.console('Real tableHeader=%s' % tableHeader)
            table1 = t._trimTable(tableHeader['data'])
            if table1['status'] == 0:
               raise Exception('%s _trimTable fail: %s' % (func_name, tableHeader))
            if debug != 0:
               logger.console('Trimed table1=%s' % table1)
            sequence = t._getTitleSequence()
            if sequence['status'] == 0:
               raise Exception('%s _getTitleSequence fail: %s' % (func_name, sequence))
            if debug != 0:
               logger.console('sequence=%s' % sequence)
            parsed_data = t._parseTableInSequence(tableHeader['data'], table1['data'], sequence['data'])
            if parsed_data['status'] == 0:
               raise Exception('%s _parseTableInSequence fail: %s' % (func_name, parsed_data))
            if debug != 0:
               logger.console('parsed_data=%s' % parsed_data)
            status_data = {
                'status':1,
                'data':parsed_data['data'],
            }
    except Exception as msg:
        e = '%s Exception: %s' % (func_name, msg)
        status_data = {'status':0, 'data':e}
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'data':e}
    finally:
        #util.nested_print(status_data)
        return(status_data)


def tableParserInPosition(kwargs):
    """
    tableParserInPosition API callable via Robot Framework
    """
    func_name = tableParserInPosition.__name__

    try:
        status_data = {'status':0}
        table = kwargs.get('table','')
        header = kwargs.get('header','')
        delimit = kwargs.get('delimiter','')
        debug = int(kwargs.get('debug',0))
    
        if table == '' or header == '':
            logger.console('Usage: tableParser(table=table, header=header, [delimiter=delimiter])')
        else:
            if debug != 0:
                logger.console('header=%s\n' % header)
                logger.console('table=%s\n' % table)
                logger.console('delimiter=%s\n' % delimit)
            if delimit != '':
                t = tableParserLib(header, table, delimiter=delimit)
            else:
                t = tableParserLib(header, table)
            tableHeader = t._getTableHeader()
            if tableHeader['status'] == 0:
               raise Exception('%s _getTableHeader fail: %s' % (func_name, tableHeader))
            if debug != 0:
               logger.console(tableHeader)
            table1 = t._trimTable(tableHeader['data'])
            if table1['status'] == 0:
               raise Exception('%s _trimTable fail: %s' % (func_name, tableHeader))
            if debug != 0:
               logger.console(table1)
            columns = t._getTitlePositions(tableHeader['data'])
            if columns['status'] == 0:
               raise Exception('%s _getTitlePositions fail: %s' % (func_name, columns))
            if debug != 0:
               logger.console(columns)
            parsed_data = t._parseTableInPosition(tableHeader['data'], table1['data'], columns['data'])
            if parsed_data['status'] == 0:
               raise Exception('%s _parseTableInPosition fail: %s' % (func_name, parsed_data))
            if debug != 0:
               logger.console(parsed_data)
            status_data = {
                'status':1,
                'data':parsed_data['data'],
            }
    except Exception as msg:
        e = '%s Exception: %s' % (func_name, msg)
        status_data = {'status':0, 'data':e}
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'data':e}
    finally:
        #util.nested_print(status_data)
        return(status_data)

if __name__ == "__main__":
    table = '''
FS1D483Z14000170 # get switch acl counter

 ID     Packets Size          Bytes Count         description
___________________________________________________________

 0001   1537633               196816384
 0002   1122334455            334455667788         jim

FS1D483Z14000170 #

    '''
    header = 'ID Packets_Size Bytes_Count description'
    table_info = {
        'table':table,
        'header':header,
        'delimiter':'FS1D483Z14000170',
        'debug':1
    }
    t = tableParserInSequence(table_info)
