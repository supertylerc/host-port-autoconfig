# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'

MASTER_MEMORY = ENV.key?('MASTER_MEMORY') ? ENV['MASTER_MEMORY'] : 1024
MINION_MEMORY = ENV.key?('MINION_MEMORY') ? ENV['MINION_MEMORY'] : 1024
NETWORK_MEMORY = ENV.key?('NETWORK_MEMORY') ? ENV['NETWORK_MEMORY'] : 1024
PFE_MEMORY = ENV.key?('PFE_MEMORY') ? ENV['PFE_MEMORY'] : 2048

VAGRANT_PLUGINS = %w(vagrant-triggers)

PLUGINS_TO_INSTALL = VAGRANT_PLUGINS.select { |plugin| not Vagrant.has_plugin? plugin }
if not PLUGINS_TO_INSTALL.empty?
  puts "Installing plugins: #{PLUGINS_TO_INSTALL.join(' ')}"
  if system "vagrant plugin install #{PLUGINS_TO_INSTALL.join(' ')}"
    exec "vagrant #{ARGV.join(' ')}"
  else
    abort "Installation of one or more plugins has failed. Aborting."
  end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define 'salt_master' do |smaster|
    smaster.vm.box = 'supertylerc/centos-7-salt'
    smaster.vm.network 'private_network', ip: '192.168.18.100', intnet: 'mgmt'
    smaster.vm.hostname = 'master.tylerc.me'
    smaster.vm.provider :virtualbox do |vb|
      vb.customize ['modifyvm', :id, '--memory', MASTER_MEMORY]
    end
    smaster.vm.provision 'shell' do |s|
      s.path = 'scripts/install.sh'
      s.args = 'master'
    end
  end

  # CentOS Minion
  config.vm.define 'salt_minion' do |sminion|
    sminion.vm.box = 'supertylerc/centos-7-salt'
    sminion.vm.network 'private_network', ip: '192.168.18.51', intnet: 'mgmt'
    sminion.vm.network 'private_network', ip: '192.168.69.51', intnet: 'cloud'
    sminion.vm.hostname = 'minion.tylerc.me'
    sminion.vm.provider :virtualbox do |vb|
      vb.customize ['modifyvm', :id, '--memory', MINION_MEMORY]
    end
    sminion.vm.provision 'shell' do |s|
      s.path = 'scripts/install.sh'
      s.args = 'minion'
    end
  end

  config.vm.define 'pfe' do |pfe|
    pfe.ssh.insert_key = false
    pfe.vm.box = 'juniper/vqfx10k-pfe'

    # DO NOT REMOVE / NO VMtools installed
    pfe.vm.synced_folder '.', '/vagrant', disabled: true
    pfe.vm.provider :virtualbox do |vb|
      vb.customize ['modifyvm', :id, '--memory', PFE_MEMORY]
    end
    pfe.vm.network 'private_network', auto_config: false, nic_type: '82540EM', intnet: 'vqfx_internal'
  end

  config.vm.define 'rtr' do |rtr|
    rtr.ssh.insert_key = false
    rtr.vm.box = 'juniper/vqfx10k-re'
    rtr.vm.synced_folder '.', '/vagrant', disabled: true

    rtr.vm.provider :virtualbox do |vb|
      vb.customize ['modifyvm', :id, '--memory', NETWORK_MEMORY]
    end
    rtr.vm.network 'private_network', auto_config: false, nic_type: '82540EM', intnet: 'vqfx_internal'
    rtr.vm.network 'private_network', auto_config: false, nic_type: '82540EM', intnet: 'reserved-bridge'
    rtr.vm.network 'private_network', auto_config: false, nic_type: '82540EM', intnet: 'mgmt'
    rtr.vm.network 'private_network', auto_config: false, nic_type: '82540EM', intnet: 'cloud'
  end

  config.trigger.after :up, :vm => ['rtr'] do
    run 'scripts/install.sh rtr'
    run 'scripts/install.sh clean'
  end
end
