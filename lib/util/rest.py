from misc import *
import requests
import json
import pdb

"""
   Class for FortiswitchOS REST APIs
"""

'''
   Well-defined HTTP status codes for FortiswitchOS REST APIs
   Which are used to indicate query results to the API
'''
http_response_codes = {
    200:'Status Ok',
    400:'Bad Request',
    403:'Forbidden Request is missing CSRF token',
    404:'Unable to find the specified resource',
    405:'Specified HTTP method is not allowed for this resource',
    413:'Request Entity Too Large',
    424:'Failed Dependency',
    500:'Internal Server Error',
}

class rest(object):

    def __init__(self, **args):
        self.payload = 'username=admin&secretkey='
        self.ops = args

    def login(self, switch_ip, verify=False):
        '''
        This python API provides login to Fortiswitch and returns csrftoken
        '''
        func_name = 'login'
        try:
            status_data = {'status':0}
            url_login = 'https://%s/logincheck' % switch_ip
            url_logout = 'https://%s/logout' % switch_ip
            url_cmdb = 'https://%s/' % switch_ip
            url_monitor = 'https://%s/' % switch_ip

            # Create a requests session
            client = requests.session()

            # Login request
            r = client.post(url_login, data=self.payload, verify=verify)
            if r.status_code != requests.codes.ok:
                raise Exception('%s:%s' % (r.status_code, http_response_codes[r.status_code]))

            apscookie=r.cookies

            # Check token present it is stored in a list
            csrftoken = ''
            for cookie in client.cookies:
                if cookie.name == 'ccsrftoken':
                    # have to remove the first 'c' to make it a normal GUI cookis
                    # this 'c' is added for distinguishing REST from GUI
                    csrftoken = cookie.value[1:-1]
            if csrftoken == '':
                raise Exception('Unable find csrftoken')

            # update the header, needed for writes
            client.headers.update({'X-CSRFTOKEN': csrftoken})

            status_data = {
                'status':1,
                switch_ip:{
                    'verify':verify,
                    'client':client,
                    'apscookie':apscookie,
                    'url_logout':url_logout,
                    'url_cmdb':url_cmdb,
                    'url_monitor':url_monitor,
                }
            }
        except Exception as msg:
            e = '%s, %s' % (func_name, msg)
            status_data = {'status':0, 'cookie':e}
        except:
            e = '%s, %s' % (func_name, sys.exc_info()[0])
            status_data = {'status':0, 'cookie':e}
        finally:
            return(status_data)

    def logout(self, *args):
        '''
        This python API logout from fortiSwitch
        '''
        func_name = 'logout'
        try:
            status_data = {'status':0}
            client_info = args[0]

            if (type(client_info) != dict or 
                'client' not in client_info or 
                'verify' not in client_info or 
                'url_logout' not in client_info):
                raise Exception('Invalid argument')

            client = client_info['client']
            url_logout = client_info['url_logout']
            verify = client_info['verify']

            # Login request
            r = client.put(url_logout, verify=verify)
            if r.status_code != requests.codes.ok:
                raise Exception('%s:s' % (r.status_code, http_response_codes[r.status_code]))

            status_data = {'status':1}

        except Exception as msg:
            e = '%s, %s' % (func_name, msg)
            status_data = {'status':0, 'client':e}
        except:
            e = '%s, %s' % (func_name, sys.exc_info()[0])
            status_data = {'status':0, 'client':e}
        finally:
            return(status_data)
 
    def post(self, url_cmd, *args):
        '''
        This python API create a resource or execute actions
        '''
        func_name = 'post'
        try:
            status_data = {'status':0}
            payload = args[0]
            client_info = args[1]

            if (type(client_info) != dict or
                'client' not in client_info or
                'verify' not in client_info or
                'apscookie' not in client_info or
                'url_cmdb' not in client_info):
                raise Exception('Invalid client_info value')

            client = client_info['client']
            url_cmdb = client_info['url_cmdb']
            verify = client_info['verify']
            apscookie = client_info['apscookie']

            # login to a particular site
            url_cmdb = url_cmdb + url_cmd

            if type(payload) != dict:
                raise Exception('Invalid payload type. Has to be dictionary')

            # execute the command
            r = client.post(url_cmdb, data=payload, verify=verify)
            if r.status_code != requests.codes.ok:
                raise Exception("%s:%s" % (r.status_code, http_response_codes[r.status_code]))
            status_data = {'status':1}

        except Exception as msg:
            e = '%s, %s' % (func_name, msg)
            status_data = {'status':0, 'token':e}
        except:
            e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
            status_data = {'status':0, 'msg':e}
        finally:
            return(status_data)

    def put(self, url_cmd, *args):
        '''
        This python API update a resource
        '''
        func_name = 'put'
        try:
            status_data = {'status':0}
            payload = args[0]
            client_info = args[1]

            if (type(client_info) != dict or 
                'client' not in client_info or 
                'verify' not in client_info or 
                'apscookie' not in client_info or 
                'url_cmdb' not in client_info):
                raise Exception('Invalid client_info value')

            client = client_info['client']
            url_cmdb = client_info['url_cmdb']
            verify = client_info['verify']
            apscookie = client_info['apscookie']

            # login to a particular site
            url_cmdb = url_cmdb + url_cmd

            if type(payload) != dict:
                raise Exception('Invalid payload type. Has to be dictionary')
            json_payload = {'json':payload}

            # execute the command
            r = client.put(url_cmdb, data=json.dumps(json_payload), cookies=apscookie, verify=verify)
            if r.status_code != requests.codes.ok:
                raise Exception("%s:%s" % (r.status_code, http_response_codes[r.status_code]))

            r = client.get(url_cmdb, verify=verify)
            if r.status_code != requests.codes.ok:
                raise Exception("%s:%s" % (r.status_code, http_response_codes[r.status_code]))

            status_data = {'status':1, 'data':json.dumps(r.json(), indent=4)}

        except Exception as msg:
            e = '%s, %s' % (func_name, msg)
            status_data = {'status':0, 'token':e}
        except:
            e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
            status_data = {'status':0, 'msg':e}
        finally:
            return(status_data)

    def get(self, url_cmd, *args):
        '''
        This python API retrieves a resource or collection of resources
        '''
        func_name = 'get'
        try:
            status_data = {'status':0}
            client_info = args[0]

            if (type(client_info) != dict or
                'client' not in client_info or
                'verify' not in client_info or
                'url_cmdb' not in client_info):
                raise Exception('Invalid client_info value')

            client = client_info['client']
            url_cmdb = client_info['url_cmdb']
            verify = client_info['verify']
            apscookie = client_info['apscookie']

            # login to a particular site
            url_cmdb = url_cmdb + url_cmd

            # execute the command
            r = client.get(url_cmdb, verify=verify)
            if r.status_code != requests.codes.ok:
                raise Exception("%s:%s" % (r.status_code, http_response_codes[r.status_code]))

            status_data = {'status':1, 'data':json.dumps(r.json(), indent=4)}

        except:
            e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
            status_data = {'status':0, 'msg':e}
        finally:
            return(status_data)

    def monitor_get(self, url_cmd, *args):
        '''
        This python API monite a resource or collection of resources
        '''
        func_name = 'monitor_get'
        try:
            status_data = {'status':0}
            client_info = args[0]

            if (type(client_info) != dict or
                'client' not in client_info or
                'verify' not in client_info or
                'apscookie' not in client_info or
                'url_monitor' not in client_info):
                raise Exception('Invalid client_info value')

            client = client_info['client']
            url_monitor = client_info['url_monitor']
            verify = client_info['verify']
            apscookie = client_info['apscookie']

            # login to a particular site
            url_monitor = url_monitor + url_cmd

            # execute the command
            r = client.get(url_monitor, verify=verify)
            if r.status_code != requests.codes.ok:
                raise Exception("%s:%s" % (r.status_code, http_response_codes[r.status_code]))

            status_data = {'status':1, 'data':json.dumps(r.json(), indent=4)}

        except:
            e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
            status_data = {'status':0, 'msg':e}
        finally:
            return(status_data)

    def delete(self, url_cmd, *args):
        '''
        This python API delete a resource or collection of resources
        '''
        func_name = 'delete'
        try:
            status_data = {'status':0}
            payload = args[0]
            client_info = args[1]

            if (type(client_info) != dict or
                'client' not in client_info or
                'verify' not in client_info or
                'apscookie' not in client_info or
                'url_cmdb' not in client_info):
                raise Exception('Invalid client_info value')

            client = client_info['client']
            url_cmdb = client_info['url_cmdb']
            verify = client_info['verify']
            apscookie = client_info['apscookie']

            # login to a particular site
            url_cmdb = url_cmdb + url_cmd

            # execute the command
            if type(payload) != dict:
                raise Exception("%s:%s" % (r.status_code, http_response_codes[r.status_code]))
            json_payload = {'json':payload}

            r = client.delete(url_cmdb, data=json.dumps(json_payload), cookies=apscookie, verify=verify)
            if r.status_code != requests.codes.ok:
                raise Exception("%s:%s" % (r.status_code, http_response_codes[r.status_code]))

            status_data = {'status':1, 'data':json.dumps(r.json(), indent=4)}

        except:
            e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
            status_data = {'status':0, 'msg':e}
        finally:
            return(status_data)

if __name__ == "__main__":
    switch_ip = '10.160.37.38'
    r = rest()
    login_info = r.login(switch_ip)
    #nested_print(login_info)
    info = login_info[switch_ip]

    url_cmd = '/api/v2/cmdb/switch/physical-port/port1'
    payload = {'speed':'1000full','max-frame-size':'4500'}
    put_info = r.put(url_cmd, payload, info)
    nested_print(put_info)

    url_cmd = '/api/v2/cmdb/switch/physical-port/port2'
    get_info = r.get(url_cmd, info)
    nested_print(get_info)
 
    url_monitor = '/api/v2/monitor/switch/stp-state'
    monitor_info = r.monitor_get(url_monitor, info)
    nested_print(monitor_info)

    url_cmd = '/system/maintenance/backup'
    payload = {'backup_to':'0', 'backup':'1'}
    post_info = r.post(url_cmd, payload, info)
    nested_print(post_info)

    url_cmd = '/api/v2/cmdb/switch/physical-port/port1'
    payload = {'speed':'1000full','max-frame-size':'4500'}
    delete_info = r.delete(url_cmd, payload, info)
    nested_print(delete_info)

    logout_info = r.logout(info)
    nested_print(logout_info)
