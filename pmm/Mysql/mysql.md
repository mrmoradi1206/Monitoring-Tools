## 1-Install PMM Agent  on client (Postgres)

```
wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
sudo dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
apt update 
sudo apt-get install pmm2-client
```

## 2-Create user on Mysql for connecting from pmm to Mysql

```
CREATE USER 'pmm'@'%' IDENTIFIED BY 'Skills39' WITH MAX_USER_CONNECTIONS 10;
GRANT SELECT, PROCESS, SUPER, REPLICATION CLIENT, RELOAD ON *.* TO 'pmm'@'%';
FLUSH PRIVILEGES;
```


## 3- Add Mysql to PMM

```
pmm-admin config --server-insecure-tls --server-url=https://admin:admin@192.168.4.13
pmm-admin add mysql  --username=pmm  --password Skills39 192.168.4.14
```
