{% set vlan_map = {
  'development': '666',
  'production': '69',
  'provisioning': '777'
} %}
{% set vlan = vlan_map[data['data']['environment']] %}
{% set switch = data['data']['switch'] %}
{% set port = data['data']['port'] %}

provision_host_port:
  local.state.apply:
    - tgt: "{{ switch }}"
    - tgt_type: glob
    - arg:
        - provisioning.provision_port
    - kwarg:
        pillar:
          vlan: {{ vlan }}
          port: {{ port }}
