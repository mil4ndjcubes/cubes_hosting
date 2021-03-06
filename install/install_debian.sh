apt-get -y update
apt-get -y upgrade
apt-get -y install locales-all

echo 'export HISTTIMEFORMAT="%d.%m.%Y %T "' >> /etc/profile.d/hist.sh
. /etc/profile.d/hist.sh
  
apt install nftables
wget -O /etc/nftables.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/nftables/nftables.conf
systemctl enable nftables
systemctl restart nftables					
							
apt-get -y install curl gnupg2 ca-certificates lsb-release
echo "deb http://nginx.org/packages/debian `lsb_release -cs` nginx" | tee /etc/apt/sources.list.d/nginx.list
curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
apt-get -y update
apt-get -y install nginx
systemctl enable nginx
mkdir /etc/nginx/sites-available
mkdir /etc/nginx/sites-enabled
mkdir /etc/nginx/ssl
openssl req -nodes -subj "/C=RS/ST=Serbial/L=Belgrade/O=Cubes/CN=www.cubes.rs" -x509 -newkey rsa:4096 -keyout /etc/nginx/ssl/server-key.pem -out /etc/nginx/ssl/server-cert.pem -days 3650
wget -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/nginx/nginx.conf
wget -O /etc/nginx/conf.d/default.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/nginx/conf.d/default.conf
wget -O /etc/nginx/conf.d/fastcgi_cache.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/nginx/conf.d/fastcgi_cache.conf
wget -O /usr/share/nginx/html/index.html https://raw.githubusercontent.com/cubes-doo/hosting/master/files/index.html
service nginx restart						
					
apt-get -y install mariadb-server
wget -O /etc/mysql/mariadb.conf.d/99-performance-tunning.cnf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/mysql/mariadb.conf.d/99-performance-tunning.cnf
systemctl enable mariadb
systemctl restart mariadb
mysql -e "CREATE USER 'phpmyadmin'@'%' IDENTIFIED BY '********';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'phpmyadmin'@'%' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"
																		
apt-get -y install vsftpd libpam-pwdfile apache2-utils whois
mkdir -p /etc/vsftpd/users
wget -O /etc/vsftpd.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/vsftpd/vsftpd.conf
wget -O /etc/pam.d/vsftpd https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/vsftpd/pam.d/vsftpd
wget -O /etc/vsftpd/mk.passwd.sh https://raw.githubusercontent.com/mil4ndjcubes/cubes_hosting/master/scripts/mk.passwd.sh
chmod +x /etc/vsftpd/mk.passwd.sh
touch /etc/vsftpd/users.passwd
wget -O /etc/vsftpd/users/website.rs https://raw.githubusercontent.com/mil4ndjcubes/cubes_hosting/master/config/vsftpd.user.conf
systemctl enable vsftpd
systemctl restart vsftpd
												
apt-get -y install apt-transport-https lsb-release ca-certificates curl
curl -sSL -o /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
apt-get -y update
apt-get -y install php7.4-fpm php7.4-cli php7.4-mbstring php7.4-mysql
wget -O /etc/php/7.4/fpm/pool.d/www.conf https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/php/fpm/pool.d/www.conf
systemctl enable php7.4-fpm
systemctl restart php7.4-fpm
																		
wget https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-all-languages.tar.gz
tar -xzf phpMyAdmin-5.0.4-all-languages.tar.gz
mv phpMyAdmin-5.0.4-all-languages /usr/share/phpmyadmin
rm phpMyAdmin-5.0.4-all-languages.tar.gz
wget -O /usr/share/phpmyadmin/config.inc.php https://raw.githubusercontent.com/cubes-doo/hosting/master/configs/phpmyadmin/config.inc.php
mkdir /usr/share/phpmyadmin/tmp
chmod 777 /usr/share/phpmyadmin/tmp

apt-get update
apt-get install snapd
snap install core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot 
certbot --nginx

apt-get update
apt-get install salt-master
apt-get install salt-syndic
service salt-master restart
salt-key -A

wget -O - https://deb.goaccess.io/gnugpg.key | gpg --dearmor | tee /usr/share/keyrings/goaccess.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/goaccess.gpg] https://deb.goaccess.io/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/goaccess.list
apt-get update
apt-get install goaccess

mkdir /var/www
mkdir /var/www/dev		
cd /var/www/dev
mknod -m 666 null c 1 3
mknod -m 666 tty c 5 0
mknod -m 666 zero c 1 5
mknod -m 666 random c 1 8
chown root:root /var/www
chmod 755 /var/www
mkdir /var/www/bin
cp /bin/bash /var/www/bin
mkdir -p /var/www/lib/x86_64-linux-gnu /var/www/lib64
cp /lib/x86_64-linux-gnu/{libtinfo.so.6,libdl.so.2,libc.so.6} /var/www/lib/x86_64-linux-gnu
cp /lib64/ld-linux-x86-64.so.2 /var/www/lib64
mkdir /var/www/etc
cp /etc/{passwd,group} /var/www/etc
wget -O /etc/ssh/sshd_config https://raw.githubusercontent.com/mil4ndjcubes/cubes_hosting/master/config/sshd_config
systemctl restart sshd
mkdir -p /var/www/home/cubes
chown cubes: /var/www/home/cubes
chmod 700 /var/www/home/cubes
touch /home/chroot.sh
wget -O /home/chroot.sh https://raw.githubusercontent.com/mil4ndjcubes/cubes_hosting/master/scripts/chroot.sh
cd /home
chmod +x chroot.sh
./chroot.sh /bin/{ls,cat,echo,rm,vi,date,mkdir,git}

apt-get update
apt-get install salt-minion
apt-get install salt-syndic
service salt-minion restart

apt-get -y install sshguard 
wget -O /etc/sshguard/sshguard.conf https://raw.githubusercontent.com/mil4ndjcubes/cubes_hosting/master/config/sshguard.conf
mkdir /var/db
mkdir /var/db/sshguard
cd /var/db/sshguard
touch blacklist.db
cd /etc/sshguard
touch sshg-fw-nft-sets
wget -O /etc/sshguard/sshg-fw-nft-sets https://raw.githubusercontent.com/mil4ndjcubes/cubes_hosting/master/config/sshg-fw-nft-sets
chmod +x sshg-fw-nft-sets 
systemctl enable sshguard
systemctl restart sshguard

wget https://repo.zabbix.com/zabbix/5.4/debian/pool/main/z/zabbix-release/zabbix-release_5.4-1+debian10_all.deb
dpkg -i zabbix-release_5.4-1+debian10_all.deb
apt update
apt install zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent
mysql -e "create database zabbix character set utf8 collate utf8_bin;"
mysql -e "create user zabbix@localhost identified by 'password';"
mysql -e "grant all privileges on zabbix.* to zabbix@localhost;"
zcat /usr/share/doc/zabbix-sql-scripts/mysql/create.sql.gz | mysql -uzabbix -p zabbix
nano /etc/zabbix/zabbix_server.conf
#DBPassword=password
systemctl restart zabbix-server zabbix-agent nginx php7.3-fpm
systemctl enable zabbix-server zabbix-agent nginx php7.3-fpm
