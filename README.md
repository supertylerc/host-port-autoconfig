# Automated Host Port Turn Up Example

This example uses Vagrant to bring up a Salt Master, Salt Minion, and a router.

> This `Vagrantfile` uses a custom Vagrant box.  It is built with Packer.
> You are encouraged to read the code that builds the box.
> It can be viewed [here](https://github.com/supertylerc/packer-salt).

The Salt Minion is a server that is going to be provisioned using a dummy
provisioning state in Salt.  The entire purpose of that state is to send
a message to the Salt Master where a reactor is configured that will configure
the switch port.

> This `Vagrantfile` installs a Vagrant plugin automatically.  You should
> be sure you understand what this `Vagrantfile` does before proceeding.

To get started, just `vagrant up`.  It will take a while to download the
boxes and do initial setup.  Once you've done this, you should log into the
router with `vagrant ssh rtr` and check the VLAN configured on `xe-0/0/1` with
`show configuration interfaces xe-0/0/1`.  It should be `777`.

Next, log into the `salt_master` with `vagrant ssh salt_master`.  Run
`sudo salt \* state.apply`.  This can take a while to run.  Once it's done,
though, you should go back to the router and check it's configuration again.
It should now have VLAN `69` applied.

Finally, you should try changing to environment from `production` to
`development`.  Edit `/srv/pillar/minion.sls` on `salt_master`, and
change `environment` from `production` to `development`.  Then, refresh
pillar data with `sudo salt \* saltutil.refresh_pillar`, then apply the
states to the minion again with `sudo salt mi\* state.apply`.  Once the
state finishes, check `rtr` again and you should that the VLAN is now `666`.

# Author

Tyler Christiansen <mail@tylerc.me>, @supertylerc on Twitter
