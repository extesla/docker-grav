# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "bento/ubuntu-16.04"
  config.vm.provider :virtualbox do |vb|
    vb.gui = false
    vb.customize ["modifyvm", :id, "--cpus", "2"]
    vb.customize ["modifyvm", :id, "--memory", "4096"]
  end

  config.vm.synced_folder ".", "/vagrant"
  config.vm.provision :shell, path: "devops/bootstrap.sh"
  config.vm.network :forwarded_port, guest: 7000, host: 7000, protocol: "tcp"

  config.vm.synced_folder "devops/salt/roots/", "/srv/salt"
  config.vm.provision :salt do |salt|
    salt.bootstrap_options = "-F -c /tmp/ -P"
    salt.minion_config = "devops/salt/env/minion"
    salt.run_highstate = true
    salt.verbose = true
  end
end