#!/bin/bash


apt-get -y update
apt-get -y upgrade
apt-get -y install locales-all

wget -O /etc/ssh/sshd_config https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/ssh/sshd_config
systemctl restart sshd

apt-get -y install nftables
wget -O /etc/nftables.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/nftables/nftables.conf
systemctl enable nftables
systemctl restart nftables

apt-get -y install mariadb-server
wget -O /etc/mysql/my.cnf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/mysql/my.cnf
wget -O /etc/mysql/mariadb.conf.d/99-performance-tunning.cnf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/mysql/mariadb.conf.d/99-performance-tunning.cnf
systemctl enable mariadb
systemctl restart mariadb
mysql -e "create database zabbix character set utf8 collate utf8_bin;"
mysql -e "create user zabbix@localhost;"
mysql -e "SET PASSWORD FOR 'zabbix'@'localhost' = PASSWORD('$MYSQL_ZABBIX_PWD');"
mysql -e "grant all privileges on zabbix.* to zabbix@localhost;"
mysql -e "FLUSH PRIVILEGES;"

wget https://repo.zabbix.com/zabbix/5.4/debian/pool/main/z/zabbix-release/zabbix-release_5.4-1+debian10_all.deb
dpkg -i zabbix-release_5.4-1+debian10_all.deb
apt-get -y update
apt-get -y install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent
zcat /usr/share/doc/zabbix-sql-scripts/mysql/create.sql.gz | mysql -uzabbix -pcubes123 zabbix
wget -O /etc/zabbix/zabbix_server.conf https://raw.githubusercontent.com/mil4ndjcubes/cubes_hosting/master/config/zabbix_server.conf
systemctl enable zabbix-server zabbix-agent apache2
systemctl restart zabbix-server zabbix-agent apache2
