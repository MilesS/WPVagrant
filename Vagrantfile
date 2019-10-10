# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/xenial64"
  config.vm.provision "shell", path: "./scripts/xenial64-wp-provision.sh"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.synced_folder ".", "/vagrant", :group => "www-data", :mount_options => ['dmode=775','fmode=664']
  
  config.trigger.before :destroy do |trigger|
    trigger.name = "Impossible trigger, Pre-Destroy"
    trigger.run_remote = { inline: "rm /vagrant/wordpress.bak" }
    trigger.run_remote = { inline: "mv /vagrant/wordpress.sql /vagrant/wordpress.bak" }
    trigger.run_remote = { inline: "mysqldump -u root -psecret wordpress > /vagrant/wordpress.sql" }
    trigger.on_error = :continue
  end

end
