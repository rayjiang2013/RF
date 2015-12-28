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

# show Full
INFO_5 = "config system global\r\n" +\
        "    set admin-concurrent enable\r\n" +\
        "end\r\n" +\
        "config system virtual-switch\r\n" +\
        '    edit "internal"\r\n' +\
        '        set physical-switch "sw0"\r\n' +\
        '        config port\r\n' +\
        '            edit "internal1"\r\n' +\
        '                set status up\r\n' +\
        "                set alias ''\r\n" +\
        '            next\r\n' +\
        '            edit "internal2"\r\n' +\
        '                set speed auto\r\n' +\
        "                set alias ''\r\n" +\
        '            next\r\n' +\
        '        end\r\n' +\
        '    next\r\n' +\
        'end\r\n'
        
# 3 set in edit
INFO_6 = "config system virtual-switch\r\n" +\
        '    edit "internal"\r\n' +\
        '        set physical-switch "sw0"\r\n' +\
        '        config port\r\n' +\
        '            edit "internal1"\r\n' +\
        '                set status up\r\n' +\
        "                set alias ''\r\n" +\
        "                set X Y\r\n" +\
        '            next\r\n' +\
        '        end\r\n' +\
        '    next\r\n' +\
        'end\r\n'

# 2 set in edit
INFO_7 = "config system virtual-switch\r\n" +\
        '    edit "internal"\r\n' +\
        '        set physical-switch "sw0"\r\n' +\
        '        config port\r\n' +\
        '            edit "internal1"\r\n' +\
        '                set status up\r\n' +\
        "                set alias ''\r\n" +\
        "                set X Y\r\n" +\
        '            next\r\n' +\
        '        end\r\n' +\
        '        set A B\r\n' +\
        '    next\r\n' +\
        'end\r\n'
# More than 1 config in edit
INFO_8 = "config system virtual-switch\r\n" +\
        '    edit "internal"\r\n' +\
        '        set A B\r\n' +\
        '        config C\r\n' +\
        '            edit D\r\n' +\
        "                set X Y\r\n" +\
        '            next\r\n' +\
        '        end\r\n' +\
        '        config E\r\n' +\
        '            edit F\r\n' +\
        "                set X Y\r\n" +\
        '            next\r\n' +\
        '        end\r\n' +\
        '        set G H\r\n' +\
        '    next\r\n' +\
        'end\r\n'

# Add space and new line handling for general_parser_show
INFO_20 = "\r\n" +\
        "config system virtual-switch\r\n" +\
        '    edit "internal"\r\n' +\
        '        set physical-switch "sw0"\r\n' +\
        '        \r\n' +\
        '        config port\r\n' +\
        '            edit "internal1"\r\n' +\
        '                set status up\r\n' +\
        "                set alias ''\r\n" +\
        "                set X Y\r\n" +\
        '            next\r\n' +\
        '        end\r\n' +\
        '    next\r\n' +\
        'end\r\n' +\
        "\r\n"
# diagnose wireless-controller wlac -c vap
INFO_9 = "\r\n" +\
        "bssid             ssid                 intf                 wtp-id               vfid:ip-port rId wId\r\n" +\
        "08:5b:0e:79:16:0c fortinet             wifi                 FP320C3X14006196     ws (0-192.168.1.111:5246) 0 0\r\n" +\
        "08:5b:0e:ae:2d:38 fortinet             wifi                 FWF90D-WIFI0         ws (0-127.0.0.1:15246) 0 0\r\n" +\
        "\r\n"

# 2 columns of x:y pattern
INFO_10 = "\r\n" +\
        "bssid             ssid                 intf        x:y         wtp-id               vfid:ip-port rId wId\r\n" +\
        "08:5b:0e:79:16:0c fortinet             wifi        a b         FP320C3X14006196     ws (0-192.168.1.111:5246) 0 0\r\n" +\
        "08:5b:0e:ae:2d:38 fortinet             wifi        c d         FWF90D-WIFI0         ws (0-127.0.0.1:15246) 0 0\r\n" +\
        "\r\n"

# diagnose wireless-controller wlac -d sta
INFO_11 = "*  vf=0 wtp=3 rId=1 wlan=wifi vlan_id=0 ip=0.0.0.0 mac=08:5b:0e:ae:2d:38 " +\
        "vci= host= user= group= signal=0 noise=0 idle=396733 bw=0 use=4 chan=6 " +\
        "radio_type=11N security=wpa2_only_personal encrypt=aes cp_authed=no online=yes \r\n" +\
        "\r\n"

# diagnose wireless-controller wlac -d wtp
INFO_12 = "vf=0 wtp=3 base=08:5b:0e:ae:2d:38 127.0.0.1:1024<->127.0.0.1:5247 use=4" +\
        "\r\n"

# diagnose wireless-controller wlac -d wlan
INFO_13 = "wlan=wifi UP ip=0.0.0.0/0 mac=00:ff:db:8c:96:70 intra_priv=0 fast_roaming=1 dynamic_vlan=0 lbr=0 lsw=1 cpauth=0 bc_suppression=3 sta_cnt=1 use=4" +\
        "\r\n"
# diagnose wireless-controller wlac -d all
INFO_14 = "wlan=wifi UP ip=0.0.0.0/0 mac=00:ff:db:8c:96:70 intra_priv=0 fast_roaming=1 dynamic_vlan=0 lbr=0 lsw=1 cpauth=0 bc_suppression=3 sta_cnt=1 use=4" +\
        "\r\n" +\
        "vf=0 wtp=3 base=08:5b:0e:ae:2d:38 127.0.0.1:1024<->127.0.0.1:5247 use=4" +\
        "\r\n" +\
        "vf=0 wtp=3 wlan=wifi             bssid=08:5b:0e:ae:2d:38 tun=01 in_kern=1 lan=0 vlan_id=0 monitor=0 idx=0 use=5" +\
        "\r\n"
# multiple lines starting with *
INFO_15 = "*  vf=0 wtp=3 rId=1 wlan=wifi vlan_id=0 ip=0.0.0.0 mac=08:5b:0e:ae:2d:38 " +\
        "vci= host= user= group= signal=0 noise=0 idle=396733 bw=0 use=4 chan=6 " +\
        "radio_type=11N security=wpa2_only_personal encrypt=aes cp_authed=no online=yes \r\n" +\
        "\r\n" +\
        "vf=0 wtp=3 base=08:5b:0e:ae:2d:38 127.0.0.1:1024<->127.0.0.1:5247 use=4" +\
        "\r\n" +\
        "*  vf=0 wtp=3 wlan=wifi             bssid=08:5b:0e:ae:2d:38 tun=01 in_kern=1 lan=0 vlan_id=0 monitor=0 idx=0 use=5" +\
        "\r\n"

# diagnose wireless-controller wlac -c wtp
INFO_16 = '-------------------------------WTP    1----------------------------\r\n' +\
        'WTP vd               : root\r\n' +\
        '    refcnt           : 3 own(1) wtpprof(1) ws(1) \r\n' +\
        '    name             : \r\n' +\
        '    location         : \r\n' +\
        '  LLDP               : disabled\r\n' +\
        '  Radio 1            : AP\r\n' +\
        '    txpower          : 100% (calc 27 oper 0 max 0 dBm)\r\n' +\
        '    WIDS profile     : ---\r\n' +\
        '      wlan  0        : wifi\r\n' +\
        '    max vaps         : 8\r\n' +\
        '-------------------------------WTP    2----------------------------\r\n' +\
        'WTP vd               : root\r\n' +\
        '    split-tunneling-local-ap-subnet  : disabled\r\n' +\
        '    last failure     : 0 -- N/A\r\n' +\
        '  Radio 1            : AP\r\n' +\
        '    country name     : NA\r\n' +\
        '    WIDS profile     : ---\r\n' +\
        '      wlan  0        : wifi\r\n' +\
        '    max vaps         : 8\r\n' +\
        '  Radio 2            : AP\r\n' +\
        '    WIDS profile     : ---\r\n' +\
        '  Radio 3            : Not Exist\r\n' +\
        '-------------------------------Total    2 WTPs----------------------------\r\n' +\
        '\r\n'
# diagnose wireless-controller wlac -c wlan
INFO_21 = 'WLAN (001/001) vdom,name: root, wifi \r\n' +\
    '     vlanid             : 0 (auto vlan intf disabled)\r\n' +\
    '     ip, mac            : 0.0.0.0, 00:ff:db:8c:96:70\r\n' +\
    '     refcnt, deleted    : 37  own(1) wtpprof(36) r\n' +\
    '     mf acl cfg         : disabled, allow, 0 entries\r\n' +\
    '  WTP 0001              : 0, FP320C3X14006196\r\n' +\
    '  WTP 0002              : 0, FWF90D-WIFI0\r\n' +\
    '      ---- 0-127.0.0.1:15246 (12 - CWAS_RUN)\r\n'

# diagnose wireless-controller wlac -c wlan example 2
INFO_22 = 'WLAN (001/001) vdom,name: root, wifi \r\n' +\
    '     vlanid             : 0 (auto vlan intf disabled)\r\n' +\
    '     ip, mac            : 0.0.0.0, 00:ff:db:8c:96:70\r\n' +\
    '     refcnt, deleted    : 37  own(1) wtpprof(36) r\n' +\
    '     mf acl cfg         : disabled, allow, 0 entries\r\n' +\
    '  WTP 0001              : 0, FP320C3X14006196\r\n' +\
    '  WTP 0002              : 0, FWF90D-WIFI0\r\n' +\
    '      ---- 0-127.0.0.1:15246 (12 - CWAS_RUN)\r\n' +\
    '      --A:B\r\n' +\
    '  C:D\r\n'


# for test_general_parser_colon
INFO_17 = 'WTP vd               : root\r\n' +\
        '    refcnt           : 3 own(1) wtpprof(1) ws(1) \r\n' +\
        '    name             : \r\n' +\
        '    location         : \r\n' +\
        '  LLDP               : disabled\r\n' +\
        '  Radio 1            : AP\r\n' +\
        '    txpower          : 100% (calc 27 oper 0 max 0 dBm)\r\n' +\
        '    WIDS profile     : ---\r\n' +\
        '      wlan  0        : wifi\r\n' +\
        '    max vaps         : 8\r\n'

# for test_general_parser_colon - 3 elements in the lowest layer
INFO_18 = 'WTP vd               : root\r\n' +\
        '    refcnt           : 3 own(1) wtpprof(1) ws(1) \r\n' +\
        '    name             : \r\n' +\
        '    location         : \r\n' +\
        '  LLDP               : disabled\r\n' +\
        '  Radio 1            : AP\r\n' +\
        '    txpower          : 100% (calc 27 oper 0 max 0 dBm)\r\n' +\
        '    WIDS profile     : ---\r\n' +\
        '      wlan  0        : wifi\r\n' +\
        '      A B: C\r\n' +\
        '      D: E\r\n' +\
        '    max vaps         : 8\r\n'
        
# for test_general_parser_colon - empty line
INFO_19 = '\r\n' +\
        'WTP vd               : root\r\n' +\
        '    refcnt           : 3 own(1) wtpprof(1) ws(1) \r\n' +\
        '    name             : \r\n' +\
        '    location         : \r\n' +\
        '  LLDP               : disabled\r\n' +\
        '  Radio 1            : AP\r\n' +\
        '    txpower          : 100% (calc 27 oper 0 max 0 dBm)\r\n' +\
        '    WIDS profile     : ---\r\n' +\
        '      wlan  0        : wifi\r\n' +\
        '      A B: C\r\n' +\
        '      D: E\r\n' +\
        '    max vaps         : 8\r\n' +\
        '\r\n'
