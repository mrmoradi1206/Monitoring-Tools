## 1-Install PMM Agent  on client (Postgres)

```
wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
sudo dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb
apt update 
sudo apt-get install pmm2-client
```

## 2-Create user on postgres for connecting from pmm to postgres

```
su - postgres
psql -c "CREATE USER pmm WITH ENCRYPTED PASSWORD 'Skills39'"
psql -c "GRANT pg_monitor to pmm";
psql -c "select pg_reload_conf()"

```
## 3-Open Access (PMM agent to postgres)
vim /etc/postgresql/14/main/pg_hba.conf

```
host    all             all             192.168.4.0/24            scram-sha-256

```
## 4- Add Postgres to PMM
```
pmm-admin add postgresql  --username=pmm  --password Skills39 192.168.4.14
pmm-admin config --server-insecure-tls --server-url=https://admin:admin@192.168.4.13

```
