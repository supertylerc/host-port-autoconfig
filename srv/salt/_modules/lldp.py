import re

def neighbor(interface=None):
    lldp_results = __salt__['cmd.run']('lldpcli show neighbors ports %s' % interface)
    switch = re.search('SysName:\s+(\w+)', lldp_results).group(1)
    port = re.search('PortDescr:\s+(.*)\n.*', lldp_results).group(1)
    return {
        'switch': switch,
        'port': port
    }
