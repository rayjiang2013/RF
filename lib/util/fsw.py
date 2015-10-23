from misc import *
import pdb

"""
   FortiSwitch class for all switch related methods
"""
class fsw(object):

    def get_svi_mac(self, info):
        '''
        This python API parses and return svi mac address
        '''
        func_name = 'get_svi_mac'
        try:
            status_data = {'status':0}
            t_info = re.sub(r'(\\r)+', '', info, re.DOTALL)
            svi_mac = 0
            for line in t_info.split('\n'):
                nested_print(line)
                s = re.search(r'HWaddr (([0-9A-F][0-9A-F]:){5}[0-9A-F][0-9A-F])', line, re.U)
                if s:
                    svi_mac = s.group(1)
                    break
            if svi_mac != 0:
                status_data = {
                    'status':1,
                    'svi_mac':svi_mac,
                }
        except:
            e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
            status_data = {'status':0, 'msg':e}
        finally:
            return(status_data)

    def parse_system_status(self, info):
        '''
        This python API parses and return system status in a dictionary format
        '''
        func_name = 'parse_system_status'
        try:
            status_data = {'status':0}
            t_info = re.sub(r'(\\r)+', '', info, re.DOTALL)
            system_status = {}
            for line in t_info.split('\n'):
                nested_print(line)
                s = re.search(r'(.*):(.*)', line, re.U)
                if s:
                    title = s.group(1).strip()
                    value = s.group(2).strip()
                    system_status[title] = value
            if system_status != {}:
                status_data = {
                    'status':1,
                    'system_status':system_status,
                }
        except:
            e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
            status_data = {'status':0, 'msg':e}
        finally:
            return(status_data)

    def get_module_name(self, module_info):
        '''
        This python API parses and return module name
        '''
        func_name = 'get_module_name'
        try:
            status_data = {'status':0}
            s = re.search(r'^([A-Z][0-9]{3}[A-Z]+)', module_info, re.U)
            if s:
                status_data = {
                    'status':1,
                    'module_name':s.group(1)
                }
        except:
            e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
            status_data = {'status':0, 'msg':e}
        finally:
            return(status_data)

    def check_table(self, info, table):
        '''
        This python API checks the info content and returns fail if a table content is missing table in info
        '''
        func_name = 'check_table'
        try:
            status_data = {'status':0}
            missing_string = ""
            info = re.sub(r'(\\r)+', '', info, re.DOTALL)
            table = re.sub(r'(\\r)+', '', table, re.DOTALL)
            for t_line in table.split('\n'):
                t_line = t_line.strip()
                line_match  = 0
                for i_line in info.split('\n'):
                    i_line = i_line.strip()
                    i_line = re.sub(r'\s+', ' ', i_line, re.DOTALL)
                    if i_line == t_line:
                        line_match = 1
                        break
                if line_match == 0:
                    missing_string = missing_string + t_line
            if missing_string == "":
                status_data = {
                    'status':1,
                }
            else:
                status_data = {
                    'status':0,
                    'missing_string': missing_string
                }

        except:
            e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
            status_data = {'status':0, 'msg':e}
        finally:
            return(status_data)

if __name__ == "__main__":
    info = '''
[F]: Format boot device.
Enter G,F,I,U,R,Q,or H:
    '''
    info1 = '''
[F]: Format boot device.
Enter G,F,I,U,R,Q,or H:
    '''
    f = fsw()
    Status = f.check_table(info, info1)
    nested_print(Status)