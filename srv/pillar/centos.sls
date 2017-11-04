napalm:
  # annoying hax0r because the `pip` package name in CentOS 7 is `python2-pip`
  # note we're only overiding the junos packages because that's all the
  # workshop uses
  junos:
    - python2-pip
    - python-devel
    - libxml2-devel
    - libxslt-devel
    - gcc
    - openssl
    - openssl-devel
    - libffi-devel
