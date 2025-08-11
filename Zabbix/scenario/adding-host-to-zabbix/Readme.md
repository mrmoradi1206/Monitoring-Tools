# Zabbix Side  
``in my scenario zabbix ip address is : 192.168.6.100 CHANGE IT``

Data Collection ==> Host ==> Create a Host 
 - Name 
 - add template ==> linux by zabbix agent
 -  interfaces (How target should be monitored ) => agent => IP TARGET

# Client Side 
### 1- Installing Zabbix Agent 2
```
cd /opt/
wget https://repo.zabbix.com/zabbix/7.4/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.4+ubuntu24.04_all.deb
dpkg -i zabbix-release_latest_7.4+ubuntu24.04_all.deb
apt update 
apt install  zabbix-agent2
```
### 2- Add Zabbix server config in
```
vim /etc/zabbix/zabbix_agent2.conf

Server=127.0.0.1,192.168.6.100
ServerActive=127.0.0.1,192.168.6.100
```

restart zabbix agent 

```
service zabbix-agent2 restart
``
