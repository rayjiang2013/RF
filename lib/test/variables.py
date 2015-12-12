'''
Created on Nov 25, 2015

@author: leijiang
'''
INFO = "Radio 0: AP\n\r  country        : cfg=US oper=US \n\r countryID      : cfg=841 oper=841\n\r" +\
        "   sta info       : 0/0\n\r  beacon intv    : 100\n\r  txpwr cfg/oper/max : 21/21/21\n\r  " +\
        "Radio 1: AP\n\r  country        : cfg=US oper=US\n\r  HT20/40 coext  : 1\n\r   beacon intv    : 50\n\r" +\
        "   txpwr cfg/oper/max : 10/10/10"
INFO_NEG = "Radio 0: AP\n\r  country        : cfg=US oper=US \n\r countryID      : cfg=841 oper=841\n\r" +\
        "   sta info       : 0/0\n\r  beacon intv    : 100\n\r  txpwr cfg/oper/max : 21/21/21\n\r  " +\
        "Radio 1: AP\n\r  country        : cfg=US oper=US\n\r  HT20/40 coext  : 1\n\r   \n\r" +\
        "   txpwr cfg/oper/max : 10/10/10"
INFO_2 = "Radio 0: AP\r\n  country        : cfg=US oper=US \r\n countryID      : cfg=841 oper=841\r\n" +\
        "   sta info       : 0/0\r\n  \r\n  txpwr cfg/oper/max : 21/21/21\r\n  " +\
        "Radio 1: AP\r\n  country        : cfg=US oper=US\r\n  HT20/40 coext  : 1\r\n   beacon intv    : 50\r\n" +\
        "   txpwr cfg/oper/max : 10/10/10"

# config wireless-controller wtp-profile then get FAP320C-default 
INFO_3 = "name                : FAP320C-default\r\ncomment             : \r\nplatform:\r\n    type                : 320C \r\n" +\
        "wan-port-mode       : wan-only\r\nmax-clients         : 0\r\nradio-1:\r\n    mode                : ap \r\nchannel             :\r\n" +\
        'radio-2: \r\n    mode                : ap \r\nchannel             : "36" "40" "44" "48"\r\nlbs:\r\n    ekahau-blink-mode   : disable' 

# add empty line to INFO_3
INFO_4 = "name                : FAP320C-default\r\ncomment             : \r\nplatform:\r\n    type                : 320C \r\n" +\
        "wan-port-mode       : wan-only\r\nmax-clients         : 0\r\nradio-1:\r\n    mode                : ap \r\nchannel             :\r\n" +\
        'radio-2: \r\n    mode                : ap \r\n  \r\nchannel             : "36" "40" "44" "48"\r\nlbs:\r\n    ekahau-blink-mode   : disable' 
