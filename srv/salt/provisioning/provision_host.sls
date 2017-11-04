fake_provisioning_step:
  cmd.run:
    - name: 'echo "hello"'

wait_for_proxy:
  cmd.run:
    - name: sleep 90

{% set lldp_data = salt['lldp.neighbor']('eth2') %}
{% set switch = lldp_data['switch'] %}
{% set port = lldp_data['port'] %}

signal_port_provisioning:
  event.send:
    - name: example/provision/complete/{{ salt['grains.get']('id') }}
    - data:
        switch: "{{ switch }}"
        port: "{{ port }}"
        environment: "{{ salt['pillar.get']('environment') }}"
