install_lldpd:
  pkg.latest:
    - name: lldpd

start_lldp:
  service.running:
    - name: lldpd
    - enable: True
