from robot.api import logger
from pprint import pprint
import os, sys
import time
import ast
import pdb

from ixiatcl import IxiaTcl
from ixiahlt import IxiaHlt
from ixiangpf import IxiaNgpf
from ixiaerror import IxiaError

ixiatcl = IxiaTcl()
ixiahlt = IxiaHlt(ixiatcl)
ixiangpf = IxiaNgpf(ixiahlt)

try:
    ErrorHandler('', {})
except (NameError,):
    def ErrorHandler(cmd, retval):
        global ixiatcl
        err = ixiatcl.tcl_error_info()
        log = retval['log']
        additional_info = '> command: %s\n> tcl errorInfo: %s\n> log: %s' % (cmd, err, log)
        raise IxiaError(IxiaError.COMMAND_FAIL, additional_info)

def ixia_print(obj, nested_level=0, output=sys.stdout):
    spacing = '   '
    if type(obj) == dict:
        logger.console('%s' % ((nested_level) * spacing))
        for k, v in obj.items():
            if hasattr(v, '__iter__'):
                logger.console('%s%s:' % ((nested_level + 1) * spacing, k))
                ixia_print(v, nested_level + 1, output)
            else:
                logger.console('%s%s: %s' % ((nested_level + 1) * spacing, k, v))
        logger.console('%s' % (nested_level * spacing))
    elif type(obj) == list:
        logger.console('%s[' % ((nested_level) * spacing))
        for v in obj:
            if hasattr(v, '__iter__'):
                ixia_print(v, nested_level + 1, output)
            else:
                logger.console('%s%s' % ((nested_level + 1) * spacing, v))
        logger.console('%s]' % ((nested_level) * spacing))
    else:
        logger.console('%s%s' % (nested_level * spacing, obj))

def ixia_connect(**kwargs):
    '''
    Connects to IXIA chassis and make a use of the ports in the port_list 
    Arguments:
     -port_list: interface list
     -aggregation_mode: 
       ANY
     -aggregation_resource_mode:
       ANY
     -device:
       chaais IP address or chassis name
     -break_locks:
       CHOICES 0 1
     -close_server_on_disconnect:
       CHOICES 0 1
     -config_file:
       ANY
     -config_file_hlt:
       ANY
     -connect_timeout:
       NUMERIC
     -enable_win_tcl_server:
       CHOICES 0 1
     -guard_rail:
       CHOICES statistics none
     -interactive:
       CHOICES 0 1
     -ixnetwork_tcl_server
       ANY
     -ixnetwork_license_servers
       ANY
     -ixnetwork_license_type:
       ANY
     -'logging:
       CHOICES hltapi_calls
     -log_path
       ANY
     -ixnetwork_tcl_proxy:
       ANY
     -master_device:
       ANY
     -chain_sequence
       ANY
     -chain_cables_length
       ANY
     -chain_type:
       CHOICES none daisy star
     -reset:
       CHOICES 0 1
     -session_resume_keys:
       CHOICES 0 1
     -session_resume_include_filter
       ANY
     -sync
       CHOICES 0 1
     -tcl_proxy_username
       ANY
     -tcl_server
       ANY
     -username
       ANY
     -mode:
       CHOICES connect disconnect reconnect_ports save
     -vport_count:
       RANGE 1 - 600
     -vport_list:
       REGEXP ^\[0-9\]+/\[0-9\]+/\[0-9\
     -execution_timeout:
       NUMERIC
     -return_detailed_handles
       CHOICES 0 1
     return:
       Connect result as a dictionary
    '''

    '''
    #### Connect with ixNet api first, might need to uncomment when IxNetwork Connection manager enabled
    ixNet=ixiangpf.ixnet
    ixNet.connect(ixnetwork_tcl_server)
    proxy_port = dict(zip(ixNet._connectTokens.split()[::2], ixNet._connectTokens.split()[1::2]))['-port']
    ixia_print('proxy_port=%s' % proxy_port)
    ixnetwork_cmgr_ip = ixnetwork_tcl_server + ":" + proxy_port
    '''
    ###########################################
    ##  CONNECT AND RETURN CONNECTION RESULT ##
    ###########################################
    #ixiangpf.ixiahlt.ixiatcl._eval("set ::ixia::logHltapiCommandsFlag 1")
    #ixiangpf.ixiahlt.ixiatcl._eval("set ::ixia::logHltapiCommandsFileName, hltCmdLog.txt")

    connect_result = ixiangpf.connect(**kwargs)
    
    if connect_result['status'] != '1':
        ErrorHandler('connect', connect_result)
    else:
        ixia_print('\nixia_connect done')

    return(connect_result)

def ixia_disconnect(**kwargs):
    '''
    Disconnect from IXIA chassis and reset the ports to factory defaults before releasing them
    Arguments:
     -maintain_lock: 
       CHOICES 0 1
     -skip_wait_pending_operations:
       CHOICES 0 1
     -reset:
       CHOICES 0 1
       1 - Reset the ports to factory defaults before releasing them
     return:
       Disconnect result as a dictionary
    '''
    for k in kwargs:
        exec('{KEY} = {VALUE}'.format(KEY = k, VALUE = repr(kwargs[k])))

    #################################################
    ##  DISCONNECT AND RETURN DISCONNECTION RESULT ##
    #################################################
    disconnect_result = ixiangpf.cleanup_session(**kwargs)

    if disconnect_result['status'] != '1':
        ErrorHandler('cleanup_session', disconnect_result)
    else:
        ixia_print('\nixia_disconnect done')

    return(disconnect_result)

def ixia_topology_config(**kwargs):
    '''
    create a topology 
    Arguments:
     -port_handle:
       REGEXP ^[0-9]+/[0-9]+/[0-9]+$
    Default:
     -topology_name:'topology 1'
    return:
     -topology_handle:
    '''
    tkwargs = {
        'topology_name':'topology 1',
    }
    for key, value in kwargs.iteritems():
        tkwargs[key]=value

    #################################################
    ##  Configure Topology                          #
    #################################################
    topology_status = ixiangpf.topology_config(**tkwargs)

    if topology_status['status'] != '1':
        ErrorHandler('topology_config', topology_status)
    else:
        ixia_print('\nConfigure Topology done')

    return topology_status

def ixia_devicegrp_config(**kwargs):
    '''
    create one or multiple device groups
    Arguments:
     -topology_handle:
       ALPHA
     -device_group_multiplier:
       NUMERIC
    Default:
     -device_group_name:'group 1'
     -device_group_multiplier:1
     -device_group_enabled:1
    return:
     -device_group_handle
    '''
    tkwargs = {
        'device_group_multiplier':1,
        'device_group_enabled':1,
    }
    for key, value in kwargs.iteritems():
        tkwargs[key]=value

    #################################################
    ##  Configure Group(s)                          #
    #################################################
    device_group_status = ixiangpf.topology_config(**tkwargs)

    if device_group_status['status'] != '1':
        ErrorHandler('topology_config', device_group_status)
    else:
        ixia_print('\nConfigure Group(s) done')

    return(device_group_status)

def ixia_multivalue_config(**kwargs):
    '''
    create multivalue config
    Arguments:
     -topology_handle:
       ALPHA
     -nest_step:
       ANY
     -nest_owner:
       ANY
     -counter_start:
       NUMERIC
    Default:
     -pattern:'counter'
     -counter_step:00:00:00:00:00:01
     -counter_direction:'increment'
     -nest_enabled:1
    return:
     -multivalue_handle
    '''
    tkwargs = {
        'pattern':'counter',
        'counter_step':'00:00:00:00:00:01',
        'counter_direction':'increment',
        'nest_enabled':1
    }
    for key, value in kwargs.iteritems():
        tkwargs[key]=value

    #################################################
    ##  Configure Group(s)                          #
    #################################################
    device_group_status = ixiangpf.topology_config(**tkwargs)

    if device_group_status['status'] != '1':
        ErrorHandler('topology_config', device_group_status)
    else:
        ixia_print('\nConfigure Group(s) done')

    return(device_group_status)

def ixia_l2_interface_config(**kwargs):
    '''
    This command create Ethernet Stack for the Device Group
    Arguments:
     -protocol_name:
       ALPHA
     -protocol_handle:
       ANY
     -mtu:
       NUMERIC
     -src_mac_addr:
       ANY
     -src_mac_addr_step:
       NUMERIC
     -vlan:
       CHOICES 0 1
     -vlan_id_count:
       NUMERIC
     -vlan_id:
       NUMERIC
    return:
     -ethernet_handle
    '''
    tkwargs = {
        'mtu':1500,
    }
    for key, value in kwargs.iteritems():
        tkwargs[key]=value

    #####################################################
    ##  Create Src Ethernet Stack for the Device Group  #
    #####################################################
    ethernet_status = ixiangpf.interface_config(**tkwargs)

    if ethernet_status['status'] != '1':
        ErrorHandler('inerface_config', ethernet_status)
    else:
        ixia_print('\nCreate Ethernet Stack for the Device Group done')

    return(ethernet_status)

def ixia_l2_multi_vlan_tag_interface_config(topology_handle):
    '''
    This command create Ethernet Stack for the Device Group
    Arguments:
     -nest_owner:
       topology_handle
    return:
     -multivalue_handle
    '''
    tkwargs = {
        'pattern':"single_value",
        'single_value':"2",
        'nest_step':"1",
        'nest_owner':topology_handle,
        'nest_enabled':"0",
        'overlay_value':"3",
        'overlay_value_step':"3",
        'overlay_index':"2",
        'overlay_index_step':"0",
        'overlay_count':"1",
    }
    #####################################################
    ##  Create Src Ethernet Stack for the Device Group  #
    #####################################################
    multivalue_status = ixiangpf.multivalue_config(**tkwargs)
    if multivalue_status['status'] != IxiaHlt.SUCCESS:
        ErrorHandler('multivalue_config', multivalue_status)
    else:
        ixia_print('\nCreate multivalue configuration done')

    return(multivalue_status)

def ixia_ping(protocol_handle, ping_dst, send_ping=1):
    '''
    This command ping a destination host
    Arguments:
     -protocol_handle:
       ANY
     -ping_dst
       ANY
     -send_ping:
       HOICES 0 1
    return:
     -ping_status
    '''
    kwargs = {}
    kwargs['protocol_handle']=protocol_handle
    kwargs['ping_dst']=ping_dst
    kwargs['send_ping']=send_ping

    #####################################################
    ##  ping host                                       #
    #####################################################
    ping_status = ixiangpf.interface_config(**kwargs)

    if ping_status['status'] != IxiaHlt.SUCCESS:
        ErrorHandler('inerface_config', ping_status)

    keys = ping_status.keys()
    port_handle = keys[1]
    if ping_status[port_handle]['ping_success'] != IxiaHlt.SUCCESS:
        try:
            ixia_print('ping %s failed: %s' % (ping_dst, ping_status[port_handle]['ping_details']))
        except:
            ixia_print('ping %s failed. cannot find ping failure details' % ping_dst)
    else:
        ixia_print('ping %s successful' % ping_dst)

    return(ping_status)

def ixia_l3_interface_config(**kwargs):
    '''
    This command create L3 Stack on top of Ethernet Stack
    Arguments:
     -protocol_name:
       ALPHA
     -protocol_handle:
       ANY
     -gateway:
       ANY
     -gateway_step:
       ANY
     -intf_ip_addr:
       ANY
     -intf_ip_addr_step:
       NUMERIC
     -netmask:
       ANY
    return:
     l3_status as a dictionary
    '''

    #################################################
    ##  Create L3 Stack on top of Ethernet Stack    #
    #################################################
    l3_status = ixiangpf.interface_config(**kwargs)

    if l3_status['status'] != '1':
        ErrorHandler('inerface_config', l3_status)
    else:
        ixia_print('\nCreate L3 Stack on top of Ethernet Stack done')

    return(l3_status)

def ixia_ipv4_arp_config():
    '''
    This command configure global options for ipv4 arp
    Arguments:
       None
    return:
     config info in a dictionary
    '''

    kwargs = {}
    kwargs['protocol_handle']='/globals'
    kwargs['arp_on_linkup']=1
    kwargs['single_arp_per_gateway']=1
    kwargs['ipv4_send_arp_rate']=200
    kwargs['ipv4_send_arp_interval']=1000
    kwargs['ipv4_send_arp_max_outstanding']=400
    kwargs['ipv4_send_arp_scale_mode']='port'
    kwargs['ipv4_attempt_enabled']=0
    kwargs['ipv4_attempt_rate']=200
    kwargs['ipv4_attempt_interval']=1000
    kwargs['ipv4_attempt_scale_mode']='port'
    kwargs['ipv4_diconnect_enabled']=0
    kwargs['ipv4_disconnect_rate']=200
    kwargs['ipv4_disconnect_interval']=1000
    kwargs['ipv4_disconnect_scale_mode']='port'

    #################################################
    ##  Create global Arp  service                  #
    #################################################
    global_arp_config_status = ixiangpf.interface_config(**kwargs)

    if global_arp_config_status['status'] != '1':
        ErrorHandler('interface_config', global_arp_config_status)
    else:
        ixia_print('\nConfigure a global Arp service for Ipv4 done')

    return(global_arp_config_status)

def ixia_ipv6_arp_config():
    '''
    This command configure global options for ipv6 arp
    Arguments:
       None
    return:
     config info in a dictionary
    '''

    kwargs = {}
    kwargs['protocol_handle']='/globals'
    kwargs['arp_on_linkup']=1
    kwargs['single_ns_per_gateway']=1
    kwargs['ipv6_send_ns_rate']=200
    kwargs['ipv6_send_ns_interval']=1000
    kwargs['ipv6_send_ns_max_outstanding']=400
    kwargs['ipv6_send_ns_scale_mode']='port'
    kwargs['ipv6_attempt_enabled']=0
    kwargs['ipv6_attempt_rate']=200
    kwargs['ipv6_attempt_interval']=1000
    kwargs['ipv6_attempt_scale_mode']='port'
    kwargs['ipv6_diconnect_enabled']=0
    kwargs['ipv6_disconnect_rate']=200
    kwargs['ipv6_disconnect_interval']=1000
    kwargs['ipv6_disconnect_scale_mode']='port'

    #################################################
    ##  Create global Arp  service                  #
    #################################################
    global_arp_config_status = ixiangpf.interface_config(**kwargs)

    if global_arp_config_status['status'] != '1':
        ErrorHandler('interface_config', global_arp_config_status)
    else:
        ixia_print('\nConfigure a global Arp service for Ipv6 done')

    return(global_arp_config_status)

def ixia_ethernet_config():
    '''
    This command configure global options for ethernet
    Arguments:
       None
    return:
     config info in a dictionary
    '''

    kwargs = {}
    kwargs['protocol_handle']='/globals'
    kwargs['ethernet_attempt_enabled']=0
    kwargs['ethernet_attempt_rate']=100
    kwargs['ethernet_attempt_interval']=999
    kwargs['ethernet_attempt_scale_mode']='port'
    kwargs['ethernet_diconnect_enabled']=0
    kwargs['ethernet_disconnect_rate']=100
    kwargs['ethernet_disconnect_interval']=999
    kwargs['ethernet_disconnect_scale_mode']='port'

    #################################################
    ##  Create global Arp  service                  #
    #################################################
    ethernet_global_status = ixiangpf.interface_config(**kwargs)

    if ethernet_global_status['status'] != '1':
        ErrorHandler('interface_config', ethernet_global_status)
    else:
        ixia_print('\nConfigure ethernet done')

    return(ethernet_global_status)

def ixia_start_protocols():
    '''
    This command configure starts all protocol(s)
    Arguments:
       None
    return:
     config info in a dictionary
    '''

    kwargs = {}
    kwargs['action']='start_all_protocols'

    #################################################
    ##  Create global Arp  service                  #
    #################################################
    test_control_status = ixiangpf.test_control(**kwargs)
    if test_control_status['status'] != '1':
        ErrorHandler('test_control', test_control_status)
    else:
        ixia_print('\nStart all protocols done')

    return(test_control_status)

def ixia_stop_protocols():
    '''
    This command configure stop all protocol(s)
    Arguments:
       None
    return:
     config info in a dictionary
    '''

    kwargs = {}
    kwargs['action']='stop_all_protocols'

    #################################################
    ##  Create global Arp  service                  #
    #################################################
    test_control_status = ixiangpf.test_control(**kwargs)

    if test_control_status['status'] != '1':
        ErrorHandler('test_control', test_control_status)
    else:
        ixia_print('\nStop all protocols done')

    return(test_control_status)

def ixia_send_arp_req(protocol_handle):
    '''
    This command configure sends arp request
    Arguments:
       -protocol_handle:
        interface handler
    return:
     config info in a dictionary
    '''

    kwargs = {}
    kwargs['protocol_handle']=protocol_handle
    kwargs['arp_send_req']=1

    #################################################
    ##  Create global Arp  service                  #
    #################################################
    for i in range(5):
        arp_status = ixiangpf.interface_config(**kwargs)

        if arp_status['status'] != '1':
            ErrorHandler('interface_config', arp_status)
        else:
            ixia_print('\nsends out arp request done')
            
        if arp_status[protocol_handle]['arp_request_success'] != IxiaHlt.SUCCESS:
            try:
                 interfaces_not_started = arp_status[protocol_handle]['arp_interfaces_not_started']
                 ixia_print("Interfaces not started: %s" % interfaces_not_started)
            except:
                 try:
                     arp_failed_item_handles = arp_status[protocol_handle]['arp_failed_item_handles']
                     ixia_print("Arp failed on: %s" %  arp_failed_item_handles)
                 except:
                     ixia_print("arp_request_success is 0, but neither arp_interfaces_not_started nor arp_failed_item_handles key is returned")
            time.sleep(10)
        else:
            ixia_print("ARP succeeded on %s" % protocol_handle)
            break

    return(arp_status)

def ixia_traffic_config(**kwargs):
    '''
    This command configures Traffic stream
    Arguments:
     -src_handle:
       ALPHA
     -dst_handle:
       ALPHA
     others
       ANY (check IXIA HLAPI traffic_config API manual for detail)
    Default:
     'mode':'create',
     'endpointset_count':1,
     'src_dest_mesh':'one_to_one',
     'route_mesh':'one_to_one',
     'bidirectional':1,
     'name':'Traffic_Item_1',
     'circuit_endpoint_type':'ipv4',
     'frame_size':64,
     'rate_mode':'percent',
     'rate_percent':2,
     'track_by':'endpoint_pair'
    '''

    tkwargs = {
        'mode':'create',
        'endpointset_count':1,
        'src_dest_mesh':'one_to_one',
        'route_mesh':'one_to_one',
        'bidirectional':1,
        'name':'Traffic_Item_1',
        'circuit_endpoint_type':'ipv4',
        'frame_size':64,
        'rate_mode':'percent',
        'rate_percent':2,
        'track_by':'endpoint_pair'
    }
    for key, value in kwargs.iteritems():
        tkwargs[key]=value

    #################################################
    ##  Create Create Traffic                       #
    #################################################
    traffic_config_status = ixiangpf.traffic_config(**tkwargs)

    if traffic_config_status['status'] != '1':
        ErrorHandler('traffic_config', traffic_config_status)
    else:
        ixia_print('\nCreate Traffic stream done')

    return(traffic_config_status)

def ixia_remove_traffic_config(**kwargs):
    '''
    This command remove Traffic stream
    Arguments:
     -stream_id:
       ANY
    Default:
     'mode':'remove',
    '''
    tkwargs = {
        'mode':'remove',
    }
    for key, value in kwargs.iteritems():
        tkwargs[key]=value

    #################################################
    ##  Create Create Traffic                       #
    #################################################
    traffic_config_status = ixiangpf.traffic_config(**tkwargs)

    if traffic_config_status['status'] != '1':
        ErrorHandler('traffic_config', traffic_config_status)
    else:
        ixia_print('\nRemove Traffic Stream done')

    return(traffic_config_status)

def ixia_regenerate():
    '''
    This command sends regenerate action
    Arguments:
     -action: regenerate
    '''

    kwargs={}
    kwargs['action']='regenerate'

    #################################################
    ##  Create Create Traffic                       #
    #################################################
    traffic_control_status = ixiangpf.traffic_control(**kwargs)

    if traffic_control_status['status'] != '1':
        ErrorHandler('traffic_control -action regenerate', traffic_control_status)
    else:
        ixia_print('\nSend regenerate done')

    return(traffic_control_status)

def ixia_apply():
    '''
    This command sends apply action
    Arguments:
     -action: regenerate
    '''

    kwargs={}
    kwargs['action']='apply'

    #################################################
    ##  Create Create Traffic                       #
    #################################################
    traffic_control_status = ixiangpf.traffic_control(**kwargs)

    if traffic_control_status['status'] != '1':
        ErrorHandler('traffic_control -action apply', traffic_control_status)
    else:
        ixia_print('\nSend apply done')

    return(traffic_control_status)

def ixia_start_traffic(**kwargs):
    '''
    This command apply & Start the traffic
    Arguments:
     -max_wait_timer:
       NUMERIC
     -handle:
       ANY
    '''

    tkwargs = {
        'action':'run',
        'max_wait_timer':120,
    }
    for key, value in kwargs.iteritems():
        tkwargs[key]=value

    #################################################
    ##  Create Create Traffic                       #
    #################################################
    traffic_control_status = ixiangpf.traffic_control(**tkwargs)

    if traffic_control_status['status'] != '1':
        ErrorHandler('traffic_control -action run', traffic_control_status)

    if tkwargs['max_wait_timer'] != 0:
        if traffic_control_status['stopped'] == '1':
            ixia_print("traffic is not started yet... Give poll for the traffic status for another 60 seconds\n")
            count = 30
            while True:
                traffic_poll_status = ixiangpf.traffic_control(
                    action = 'poll',
                )
                if traffic_poll_status['stopped'] == '1':
                    if count == 0:
                        break
                    else:
                        time.sleep(2)
                        count -= 1
                else:
                    break

            if traffic_poll_status['stopped'] == '1':
                ErrorHandler('traffic_control', traffic_control_status)
        else:
            ixia_print('\ntraffic control is done')

    return(traffic_control_status)

def ixia_stop_traffic():
    '''
    This command stop sending traffic
    Arguments:
     -max_wait_timer:
       NUMERIC
    '''

    kwargs={}
    kwargs['action']='stop'

    #################################################
    ##  Create Create Traffic                       #
    #################################################
    traffic_control_status = ixiangpf.traffic_control(**kwargs)

    if traffic_control_status['status'] != '1':
        ErrorHandler('traffic_control', traffic_control_status)
    else:
        ixia_print('\ntraffic stop is done')

    return(traffic_control_status)

def ixia_clear_traffic():
    '''
    This command clear traffic
    Arguments:
     -max_wait_timer:
       NUMERIC
    '''

    kwargs={}
    kwargs['action']='clear_stats'

    #################################################
    ##  Create Create Traffic                       #
    #################################################
    traffic_control_status = ixiangpf.traffic_control(**kwargs)

    if traffic_control_status['status'] != '1':
        ErrorHandler('traffic_control', traffic_control_status)
    else:
        ixia_print('\ntraffic clear is done')

    return(traffic_control_status)

def ixia_traffic_stats(port):
    '''
    This command Collecting traffic Stats for a port
    Arguments:
     -mode:
       ALPHA
    '''

    kwargs={}
    kwargs['mode']='aggregate'

    #################################################
    ##  Create Create Traffic                       #
    #################################################
    traffic_stats = ixiangpf.traffic_stats(**kwargs)

    if traffic_stats['status'] != IxiaHlt.SUCCESS:
        ErrorHandler('traffic_stats', traffic_stats)
    else:
        tx_count = traffic_stats[port]['aggregate']['tx']['pkt_count']
        if tx_count == 'N/A':
            tx_count = 0
        rx_count = traffic_stats[port]['aggregate']['rx']['pkt_count']
        if rx_count == 'N/A':
            rx_count = 0
        tx_total_count = traffic_stats[port]['aggregate']['tx']['total_pkts']
        if tx_total_count == 'N/A':
            tx_total_count = 0
        rx_total_count = traffic_stats[port]['aggregate']['rx']['total_pkts']
        if rx_total_count == 'N/A':
            rx_total_count = 0

    traffic_stats = {
        'status':1,
        'tx_count':tx_count,
        'rx_count':rx_count,
        'tx_total_count':tx_total_count,
        'rx_total_count':rx_total_count,
    }
    return(traffic_stats)

def ixia_flow_stats(flow, port):
    '''
    This command Collecting Flow Stats for a port
     -flowe:
       NUMERIC
     -flowe:
       port
    '''

    kwargs={}
    kwargs['mode']='flow'

    #################################################
    ##  Create Create Traffic                       #
    #################################################
    flow_stats = ixiangpf.traffic_stats(**kwargs)

    if flow_stats['status'] != IxiaHlt.SUCCESS:
        ErrorHandler('traffic_stats', flow_stats)
    else:
        flow_count = flow_stats['flow'][flow][port]

    flow_stats = {
        'status':1,
        'flow_count':flow_count,
    }
    return(flow_stats)

def ixia_traffic_packets(port, ptype, count_title):
    '''
    This command Collecting packets counts
    Arguments:
     -mode:
       ALPHA
    '''

    kwargs={}
    kwargs['mode']='aggregate'

    #################################################
    ##  Create Create Traffic                       #
    #################################################
    traffic_stats = ixiangpf.traffic_stats(**kwargs)

    if traffic_stats['status'] != IxiaHlt.SUCCESS:
        ErrorHandler('traffic_stats', traffic_stats)
    else:
        packet_count = traffic_stats[port]['aggregate'][ptype][count_title]
        if packet_count == 'N/A':
            packet_count = 0

    traffic_stats = {
        'status':1,
        'packet_count':packet_count,
    }
    return(traffic_stats)

def ixia_port_stats(port):
    '''
    This command Collecting Flow Stats for a port
    Arguments:
     -port:
       ANY
    '''
    kwargs={}
    kwargs['port_handle']=port

    #################################################
    ##  Create Create Traffic                       #
    #################################################
    port_stats = ixiangpf.interface_stats(**kwargs)

    if port_stats['status'] != IxiaHlt.SUCCESS:
        ErrorHandler('port_stats', port_stats)

    return(port_stats)

def ixia_traffic_pkts(**kwargs):
    '''
    This command returns packages
    Arguments:
     -traffic_stats data (dictionalry)
     -port:
      tx
      rt
     return:
      package count
    '''

    #################################################
    ##  Create Create Traffic                       #
    #################################################
    port = str(kwargs['port'])
    traffic_item_name = str(kwargs['traffic_item_name'])
    traffic_stats = kwargs['traffic_stats']
    return(traffic_stats['traffic_item'][traffic_item_name][port]['total_pkts'])

def PacketDiff(traffic1, traffic2, perc):
    '''
    This API compares the difference of first packets with seconds. Returns 1 if
    the difference is within perc. Otherwise, returns 0
    '''
    func_name = PacketDiff.__name__
    try:
        status_data = {'status':0}
        if type(traffic1) != float:
            traffic1 = float(traffic1)
        if type(traffic2) != float:
            traffic2 = float(traffic2)
        if type(perc) != float:
            perc = float(perc)
        if perc > 1.0 or perc <= 0.0:
            raise Exception('Invalid perc %s, it has to be in the range of 1.0 < perc > 0.0' % perc)
        if traffic1 == 0.0:
            raise Exception('Invalid traffic1. It cannot be 0')
        if traffic2 == 0.0:
            raise Exception('Invalid traffic2. It cannot be 0')
        if traffic1 >= traffic2:
            p = traffic2/traffic1
        else:
            p = traffic1/traffic2
        if p >= perc:
            result = 1
        else:
            result = 0
        status_data = {'status':1, 'result':result}
    except Exception as msg:
        e = '%s Exception: %s' % (func_name, msg)
        status_data = {'status':0, 'result':e}
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'result':e}
    finally:
        return(status_data)

def ixia_get_resolved_mac(handle):
    '''
    This API returns resolved Gateway Mac
    '''
    func_name = ixia_get_resolved_mac.__name__
    try:
        status_data = {'status':0}
        resolved_mac_list = ixiangpf.ixnet.getAttribute(handle, 'resolvedGatewayMac')
        status_data = {'status':1, 'resolvedGatewayMac':resolved_mac_list}
    except:
        e = '%s, Unexpected error: %s' % (func_name, sys.exc_info()[0])
        status_data = {'status':0, 'resolvedGatewayMac':e}
    finally:
        return(status_data)

def ixia_enable_capture(**kwargs):
    '''
    Enable capture
    Arguments:
     -port_handle:
       ANY
     -data_plane_capture_enable:
       CHOICES 0 1
     -control_plane_capture_enable:
       CHOICES 0 1
     -slice_size:
       NUMERIC
     -capture_mode:
       trigger
     -trigger_position:
       NUMERIC
     -after_trigger_filter:
       ANY
     -before_trigger_filter:
       ANY
     -continuous_filter:
       ANY
    '''
    tkwargs = {
        'data_plane_capture_enable':1,
        'control_plane_capture_enable':0,
        'slice_size':0,
        'capture_mode':'trigger',
        'trigger_position':1,
        'after_trigger_filter':'trigger',
        'before_trigger_filter':none,
        'continuous_filter':'all',
    }
    for key, value in kwargs.iteritems():
        tkwargs[key]=value

    #################################################
    ##  Enable capture
    #################################################
    enable_capture_status = ixiangpf.packet_config_buffers(**tkwargs)

    if enable_capture_status['status'] != '1':
        ErrorHandler('enable_capture', enable_capture_status)
    else:
        ixia_print('\nenable_capture done')

    return(enable_capture_status)

def ixia_start_capture(**kwargs):
    '''
    Enable capture
    Arguments:
     -port_handle:
       ANY
    '''
    tkwargs = {
        'action':'start',
    }
    for key, value in kwargs.iteritems():
        tkwargs[key]=value

    #################################################
    ##  Enable capture
    #################################################
    start_capture_status = ixiangpf.packet_config_buffers(**tkwargs)

    if start_capture_status['status'] != '1':
        ErrorHandler('start_capture', start_capture_status)
    else:
        ixia_print('\nstart_capture done')

    return(start_capture_status)

def ixia_stop_capture(**kwargs):
    '''
    Enable capture
    Arguments:
     -port_handle:
       ANY
    '''
    tkwargs = {
        'action':'stop',
    }
    for key, value in kwargs.iteritems():
        tkwargs[key]=value

    #################################################
    ##  Enable capture
    #################################################
    stop_capture_status = ixiangpf.packet_config_buffers(**tkwargs)

    if stop_capture_status['status'] != '1':
        ErrorHandler('stop_capture', stop_capture_status)
    else:
        ixia_print('\nstop_capture done')

    return(stop_capture_status)

def ixia_get_captured_data(**kwargs):
    '''
    Enable capture
    Arguments:
     -port_handle:
       ANY
    '''
    tkwargs = {
        'format':'var',
        'frame_id_start':1,
        'frame_id_end':2,
    }
    for key, value in kwargs.iteritems():
        tkwargs[key]=value

    #################################################
    ##  Enable capture
    #################################################
    get_captured_data_status = ixiangpf.packet_config_buffers(**tkwargs)

    if get_captured_data_status['status'] != '1':
        ErrorHandler('get_captured_data', get_captured_data_status)
    else:
        ixia_print('\nget_captured_data done')

    return(get_captured_data_status)

if __name__ == "__main__":
    pdb.set_trace()
    r = PacketDiff(100,98,0.99)
