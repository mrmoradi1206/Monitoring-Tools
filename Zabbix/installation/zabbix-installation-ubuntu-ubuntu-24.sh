# this installation made for ubuntu 24.04

#!/bin/bash
cd /opt/
wget https://repo.zabbix.com/zabbix/7.4/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.4+ubuntu24.04_all.deb
dpkg -i zabbix-release_latest_7.4+ubuntu24.04_all.deb
apt update 

apt install zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent2  mysql-server
apt install zabbix-agent2-plugin-mongodb zabbix-agent2-plugin-mssql zabbix-agent2-plugin-postgresql 

### Enable This option for Importing Schema
echo -e "[mysqld]\nlog_bin_trust_function_creators = 1" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf > /dev/null
service mysql restart 
# Creating MYSQL Database for Zabbix + Give it Desired Permission  
mysql << EOF  
create database zabbix character set utf8 collate utf8_bin;
create user zabbix@localhost identified by 'PackopsZBX2025';
grant all privileges on zabbix.* to zabbix@localhost;
flush privileges;
EOF




zcat /usr/share/zabbix/sql-scripts/mysql/server.sql.gz | mysql -uzabbix -p zabbix 

# Put DBpassword in Zabbix server in order to connect to DB
 echo "DBPassword=PackopsZBX2025" >> /etc/zabbix/zabbix_server.conf 


cp /etc/zabbix/nginx.conf /etc/nginx/sites-enabled/zabbix.conf
#
## Change default port from 8080 to 80 and uncoment 
sed -i 's/^#\s*listen\s*8080;/        listen          80;/' /etc/nginx/sites-enabled/zabbix.conf
rm -rf /etc/nginx/sites-enabled/default


systemctl enable zabbix-server zabbix-agent2 nginx  php8.3-fpm  --now
service nginx restart

