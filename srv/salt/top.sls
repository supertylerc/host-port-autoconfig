base:
  'G@os_family:RedHat':
    - epel
    - napalm_install
  '*':
    - salt_proxy
  'minion.tylerc.me':
    - lldp
    - provisioning.provision_host
