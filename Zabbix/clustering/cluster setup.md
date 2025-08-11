The solution consists of multiple zabbix_server instances or nodes. Every node:

    is configured separately
    uses the same database
    may have several modes: active, standby, unavailable, stopped
    Two Zabbix server nodes zabbix-node1, zabbix-node2
    One shared database (e.g. MySQL/Galera or PostgreSQL with Patroni/HAProxy)
    

Optional: Shared storage for externalscripts, alertscripts, and modules

One shared database (e.g. MySQL/Galera or PostgreSQL with Patroni/HAProxy)

Optional: Shared storage for externalscripts, alertscripts, and modules

![zabbix_ha_agent](https://github.com/farshadnick/zabbix-course/assets/88557305/67c917f7-be15-4013-bd02-24d907cc529f)

# ZBX1 => Zabbix_server.conf
```
HANodeName=zabbix1 
NodeAddress=192.168.4.150
```
# ZBX2 => Zabbix_server.conf
```
HANodeName=zabbix2 
NodeAddress=192.168.4.151
```

# Config for sending Zabbix agent data to Zabbix servers
```
ServerActive=zabbix1.example.com;zabbix2.example.com
# Two node cluder and one standalone server on local machine:
ServerActive=zabbix1.example.com;zabbix2.example.com,localhost

```
# Verify Cluster
```
zabbix_server -R ha_status
```
