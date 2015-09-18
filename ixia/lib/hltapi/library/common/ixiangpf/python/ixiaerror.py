#!/usr/bin/env python

class IxiaError(RuntimeError):
    ''' Ixia error '''
    TCL_NOT_FOUND = 1
    HLTAPI_NOT_FOUND = 2
    HLTAPI_NOT_PREPARED = 3
    HLTAPI_NOT_INITED = 4
    COMMAND_FAIL = 5,
    WINREG_NOT_FOUND = 6
    IXNETWORK_API_NOT_FOUND = 7
    XML_PROCESS_FAIL = 8
    IXNET_ERROR = 9
    HLAPI_NO_SESSION = 10

    __error_texts = {
        TCL_NOT_FOUND: 'No compatible TCL interpretor could be found',
        HLTAPI_NOT_FOUND: 'No HLTAPI installation found',
        HLTAPI_NOT_PREPARED: 'Unable to prepare the initialization of Ixia TCL package',
        HLTAPI_NOT_INITED: 'Unable to initialize HLTAPI',
        COMMAND_FAIL: 'HLTAPI command failed',
        WINREG_NOT_FOUND: 'Could not find a product in windows registry. Please specify manually in constructor',
        IXNETWORK_API_NOT_FOUND: 'IxNetwork python API was not found',
        XML_PROCESS_FAIL: 'Failed to process return xml',
        IXNET_ERROR: 'Ixnetwork error occured',
        HLAPI_NO_SESSION: 'No NGPF session was found. Please call IxiaNgpf.connect first',
    }

    def __init__(self, msgid, additional_info=''):
        if msgid not in self.__error_texts.keys():
            raise ValueError('message id is incorrect')

        self.msgid = msgid
        message = self.__error_texts[msgid]
        if additional_info:
            message += '\nAdditional error info:\n' + additional_info

        super(self.__class__, self).__init__(message)