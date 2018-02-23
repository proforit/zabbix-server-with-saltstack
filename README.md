# zabbix-server-with-saltstack
Zabbix server setup with saltstack

This was meant to be a very simple example. No pillar data was set to configure the states. If you want to changes passwords, ports, timezone, etc you'll have to do it in the state files.

# Workstation setup
This was tested with:

1. OS X High Sierra
2. Vagrant v2.0.1
3. VirtualBox 5.2.6

# Instructions

1. Clone this repo.
2. `cd zabbix-server-with-saltstack/vagrant`
3. `vagrant up`
4. Wait for installation to finish.
5. Open a web browser and go to http://localhost:8080/zabbix/
6. Login with U: `Admin` P: `zabbix`

# Troubleshooting

This whole process relies on many external systems so there is definite possibility that something will go wrong.

Don't be alarmed if there is a lot of red text on the initial run. That usually means one step failed. Try rerunning the salt state. To do that, login to the vagrant machine with `vagrant ssh`. Then `sudo salt-call state.apply`.
