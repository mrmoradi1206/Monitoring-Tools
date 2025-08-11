
1- Create a Item in zabbix 

Property 	Value
Name 	rnd
Type 	Zabbix Trapper
key 	rnd
Type of information 	Numeric (unsigned)

2- Send a data to zabbix server by 
install zabbix-sender first
```
apt install zabbix-sender

```

```
zabbix_sender -z <Zabbix server/proxy IP or Domain name> -s "<host name as written in Zabbix>" -k rnd -o 123
```
