base:
  'G@os_family:RedHat':
    - napalm_install
  '*':
    - salt_proxy
  'minion.tylerc.me':
    - provisioning.provision_host
