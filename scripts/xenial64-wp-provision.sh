#!/bin/bash

# simple vagrant provisioning script

# some coloring in outputs.
COLOR="\033[;35m"
COLOR_RST="\033[0m"

echo -e "${COLOR}---updating system---${COLOR_RST}"
sudo apt-get update
sudo apt-get upgrade

echo -e "${COLOR}---installing some tools---${COLOR_RST}"
sudo apt-get install -y software-properties-common
sudo apt-get install -y python-software-properties
sudo apt-get install -y zip unzip
sudo apt-get install -y curl
sudo apt-get install -y build-essential

# installing mysql
# pre-loading a default password --> yourpassword
debconf-set-selections <<< "mysql-server mysql-server/root_password password secret"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password secret"
echo -e "${COLOR}---installing MySql---${COLOR_RST}"
sudo apt-get install -y mysql-server mysql-client

# installing apache2
echo -e "${COLOR}---installing Apache---${COLOR_RST}"
sudo apt-get install -y apache2
sudo rm -rf /var/www/html
sudo ln -fs /vagrant /var/www/html

# installing php 7.0
echo -e "${COLOR}---installing php---${COLOR_RST}"
sudo apt-get install -y php7.0 libapache2-mod-php7.0 php7.0-mcrypt php7.0-curl php7.0-mysql php7.0-gd

#setup the database
echo -e "${COLOR}---setting up database---${COLOR_RST}"
cd /vagrant
sudo mysql -u root -psecret -e "DROP DATABASE IF EXISTS wordpress;"
sudo mysql -u root -psecret -e "create database wordpress;"
sudo mysql -u root -psecret -e "grant usage on *.* to wordpress@localhost identified by 'password';"
sudo mysql -u root -psecret -e "grant all privileges on wordpress.* to wordpress@localhost;"

#phpmyadmin
echo -e "${COLOR}---Install PHPMYADMIN---${COLOR_RST}"
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-install boolean true'
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/app-password-confirm password secret'
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-pass password secret'
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/app-pass password secret'
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect none'
sudo apt-get install -y phpmyadmin
sudo ln -fs /usr/share/phpmyadmin /vagrant/phpmyadmin

# enable mod rewrite for apache2
echo -e "${COLOR}---enabling rewrite module---${COLOR_RST}"
if [ ! -f /etc/apache2/mods-enabled/rewrite.load ] ; then
    a2enmod rewrite
fi

#deflat module for apache2
if [ ! -f /etc/apache2/mods-enabled/deflate.load ] ; then
    a2enmod deflate
fi

#enable modrewrite for htaccess
echo -e "${COLOR}---enable FollowSymLinks---${COLOR_RST}"
sudo sed -i "/VirtualHost/a <Directory /var/www/html/> \n Options Indexes FollowSymLinks MultiViews \n AllowOverride All \n Order allow,deny \n  allow from all \n </Directory>" /etc/apache2/sites-available/000-default.conf

# restart apache2
echo -e "${COLOR}---restarting apache2---${COLOR_RST}"
sudo service apache2 restart

# move to vagrant
echo -e "${COLOR}---move to vagrant---${COLOR_RST}"
cd /vagrant

# install wordpress
echo -e "${COLOR}---installing wordpress---${COLOR_RST}"
sudo wget http://wordpress.org/latest.tar.gz

# extract wordpress
echo -e "${COLOR}---extracting wordpress---${COLOR_RST}"
sudo tar xfz latest.tar.gz

# moving wordpress
echo -e "${COLOR}---moving wordpress---${COLOR_RST}"
sudo mv wordpress/* ./
sudo rmdir ./wordpress/
sudo rm -f latest.tar.gz

echo -e "${COLOR}---install complete---${COLOR_RST}"
