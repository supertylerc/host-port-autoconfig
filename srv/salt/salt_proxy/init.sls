{% set salt_proxy_names = salt['pillar.get']('salt_proxy_names', []) %}

{% if salt_proxy_names|length %}
salt_proxy_disable_multiprocessing:
  file.managed:
    - name: /etc/salt/proxy
    - contents:
      - "multiprocessing: False"
{% endif %}

{% for name in salt_proxy_names %}
salt_proxy_configure_{{ name }}:
  salt_proxy.configure_proxy:
    - proxyname: {{ name }}
    - start: True
{% endfor %}
