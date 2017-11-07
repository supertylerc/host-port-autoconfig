function setup_yum() {
  sudo yum -y -q update
}

function install_minion() {
  sudo cp /vagrant/conf/minion /etc/salt
  hostname > /etc/salt/minion_id
  sudo systemctl restart salt-minion
  sudo systemctl enable salt-minion
}

function install_master() {
  sudo cp /vagrant/conf/master /etc/salt/master
  sudo cp /vagrant/conf/master.d/reactor.conf /etc/salt/master.d/reactor.conf
  sudo cp /vagrant/conf/master.d/gitfs.conf /etc/salt/master.d/gitfs.conf
  sudo cp -R /vagrant/srv/salt/* /srv/salt/
  sudo cp -R /vagrant/srv/pillar/* /srv/pillar/

  sudo systemctl restart salt-master
  sudo systemctl enable salt-master
}

function setup_master() {
  echo "127.0.0.1 master.tylerc.me" >> /etc/hosts
  echo "127.0.0.1 salt" >> /etc/hosts
  echo "192.168.18.51 minion.tylerc.me" >> /etc/hosts

  sudo hostnamectl set-hostname master.tylerc.me

  setup_yum
  setup_iptables
  install_master
  install_minion
}

function setup_minion() {
  echo "192.168.18.100 salt" >> /etc/hosts
  echo "192.168.18.100 master.tylerc.me" >> /etc/hosts
  echo "127.0.0.1 minion.tylerc.me" >> /etc/hosts

  sudo hostnamectl set-hostname minion.tylerc.me

  setup_yum
  install_minion
}

function setup_iptables() {
  firewall-cmd --permanent --zone=public --add-port=4505-4506/tcp
  firewall-cmd --reload
}

function setup_rtr() {
  vagrant ssh rtr -- -lroot "cli -c 'configure; set system host-name rtr; commit and-quit'"
  vagrant ssh rtr -- -lroot "cli -c 'configure; set system login user vagrant authentication encrypted-password \"\$1\$810kIUBW\$MOXi4lDzP1uUFVquni7sn0\"; commit and-quit'"
  vagrant ssh rtr -- -lroot "cli -c 'configure; delete interfaces; set interfaces em0.0 family inet dhcp; commit and-quit'"
  vagrant ssh rtr -- -lroot "cli -c 'configure; set interfaces em1.0 family inet address 169.254.0.2/24; commit and-quit'"
  vagrant ssh rtr -- -lroot "cli -c 'configure; set interfaces irb.69 family inet address 192.168.69.1/24; commit and-quit'"
  vagrant ssh rtr -- -lroot "cli -c 'configure; set interfaces irb.666 family inet address 192.168.66.1/24; commit and-quit'"
  vagrant ssh rtr -- -lroot "cli -c 'configure; set vlans PROVISIONING vlan-id 777; commit and-quit'"
  vagrant ssh rtr -- -lroot "cli -c 'configure; set vlans PRODUCTION vlan-id 69; set vlans PRODUCTION l3-interface irb.69; commit and-quit'"
  vagrant ssh rtr -- -lroot "cli -c 'configure; set vlans DEVELOPMENT vlan-id 666; set vlans DEVELOPMENT l3-interface irb.666; commit and-quit'"
  vagrant ssh rtr -- -lroot "cli -c 'configure; set interfaces xe-0/0/0.0 family inet address 192.168.18.31/24; commit and-quit'"
  vagrant ssh rtr -- -lroot "cli -c 'configure; set interfaces xe-0/0/1.0 family ethernet-switching vlan members 777; commit and-quit'"
  vagrant ssh rtr -- -lroot "cli -c 'configure; set protocols lldp interface all; commit and-quit'"
}

function clean_keys() {
  vagrant ssh salt_master -c "sudo salt-key -y -d 10.0.2.15"
}

# main
if [[ "${1}" == "master" ]]; then
  setup_master
elif [[ "${1}" == "minion" ]]; then
  setup_minion
elif [[ "${1}" == "rtr" ]]; then
  setup_rtr
elif [[ "${1}" == "clean" ]]; then
  clean_keys
else
  echo "lolno"
fi
