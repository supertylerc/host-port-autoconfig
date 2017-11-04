{% set vlan = pillar['vlan'] %}
{% set port = pillar['port'] %}

provision_port_{{ port }}_vlan_{{ vlan }}:
  netconfig.managed:
    - template_name: salt://templates/host_port.{{ salt['grains.get']('os') }}.j2
    - vlan: {{ vlan }}
    - port: {{ port }}
