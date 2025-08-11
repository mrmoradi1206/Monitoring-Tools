
# Postgres Config 

apt install postgres-server postgresql-contrib -y 

su - postgres

psql 

### Create User named postgres_exporter (what ever you name) with password = password
```
CREATE OR REPLACE FUNCTION __tmp_create_user() returns void as $$
BEGIN
  IF NOT EXISTS (
          SELECT                       -- SELECT list can stay empty for this
          FROM   pg_catalog.pg_user
          WHERE  usename = 'postgres_exporter') THEN
    CREATE USER postgres_exporter;
  END IF;
END;
$$ language plpgsql;
SELECT __tmp_create_user();
DROP FUNCTION __tmp_create_user();
ALTER USER postgres_exporter WITH PASSWORD 'password';
ALTER USER postgres_exporter SET SEARCH_PATH TO postgres_exporter,pg_catalog;
GRANT CONNECT ON DATABASE postgres TO postgres_exporter;
GRANT pg_monitor to postgres_exporter;
```


## ADD Following Config in your Postgres Config vim /etc/postgresql/14/main/postgresql.conf
**Enable PG Status Extention**
****
shared_preload_libraries = 'pg_stat_statements' 

track_activity_query_size = 2048 

pg_stat_statements.track = all 

****

## Grant Permission for exporter 
su - postgres

psql 

```
CREATE SCHEMA IF NOT EXISTS postgres_exporter;
GRANT USAGE ON SCHEMA postgres_exporter TO postgres_exporter;

CREATE OR REPLACE FUNCTION get_pg_stat_activity() RETURNS SETOF pg_stat_activity AS
$$ SELECT * FROM pg_catalog.pg_stat_activity; $$
LANGUAGE sql
VOLATILE
SECURITY DEFINER;

CREATE OR REPLACE VIEW postgres_exporter.pg_stat_activity
AS
  SELECT * from get_pg_stat_activity();

GRANT SELECT ON postgres_exporter.pg_stat_activity TO postgres_exporter;

CREATE OR REPLACE FUNCTION get_pg_stat_replication() RETURNS SETOF pg_stat_replication AS
$$ SELECT * FROM pg_catalog.pg_stat_replication; $$
LANGUAGE sql
VOLATILE
SECURITY DEFINER;
CREATE OR REPLACE VIEW postgres_exporter.pg_stat_replication
AS
  SELECT * FROM get_pg_stat_replication();
GRANT SELECT ON postgres_exporter.pg_stat_replication TO postgres_exporter;
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE OR REPLACE FUNCTION get_pg_stat_statements() RETURNS SETOF pg_stat_statements AS
$$ SELECT * FROM public.pg_stat_statements; $$
LANGUAGE sql
VOLATILE
SECURITY DEFINER;
CREATE OR REPLACE VIEW postgres_exporter.pg_stat_statements
AS
  SELECT * FROM get_pg_stat_statements();
GRANT SELECT ON postgres_exporter.pg_stat_statements TO postgres_exporter;
```

****

**service postgresql@14-main restart**


----------------------------------------
# Postgress Exporter Install
---------------------------------------
```
RELEASE=0.13.2
DATA_SOURCE_NAME="postgresql://postgres_exporter:password@localhost:5432/?sslmode=disable"

wget https://github.com/prometheus-community/postgres_exporter/releases/download/v$RELEASE/postgres_exporter-$RELEASE.linux-amd64.tar.gz
tar -xzvf postgres_exporter-$RELEASE.linux-amd64.tar.gz
cp postgres_exporter-$RELEASE.linux-amd64/postgres_exporter /usr/local/bin && rm -rf postgres_exporter-$RELEASE.linux-amd64

sudo useradd -rs /bin/false postgres-exp

# Download Query Version 14 
 curl -k https://raw.githubusercontent.com/farshadnick/Monitoring-Stack-Course/main/Prometheus/postgres/query-version14.yml?token=GHSAT0AAAAAACFYFW4VXKB2CXZLOUSJOW3UZIEALPA -o /etc/query.yml

chown postgres-exp:postgres-exp  /etc/query.yml


mkdir  -p  /opt/postgres_exporter/
echo "DATA_SOURCE_NAME=postgresql://postgres_exporter:password@localhost:5432/postgres?sslmode=disable"    >  /opt/postgres_exporter/postgres_exporter.env

# /etc/systemd/system/postgres_exporter.service

```
```
[Unit]
Description=Prometheus exporter for Postgresql
Wants=network-online.target
After=network-online.target
[Service]
User=postgres-exp
Group=postgres-exp
WorkingDirectory=/opt/postgres_exporter
EnvironmentFile=/opt/postgres_exporter/postgres_exporter.env
ExecStart=/usr/local/bin/postgres_exporter --web.listen-address=:9187 --web.telemetry-path=/metrics  --extend.query-path=/etc/query.yml
Restart=always
[Install]
WantedBy=multi-user.target
```
```

sudo systemctl daemon-reload
sudo systemctl start postgres_exporter
sudo systemctl enable postgres_exporter
sudo systemctl status postgres_exporter
```
## Dashboard ID 10017
## Postgrtes query for verify
```
\dx   #shows extentions

\dt # shows tables

\d pg_stat_statements;



# Query for verifying PG-status 12 
SELECT total_time, min_time, max_time, mean_time, calls, rows, query
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 1;

#  Query for verifying Version 14
SELECT total_exec_time, min_exec_time, max_exec_time, mean_exec_time, calls, rows, query
FROM pg_stat_statements;


## Prometheus Side 
```
  - job_name: postgres
    static_configs:
       - targets:
         - 192.168.4.180:9187
    metrics_path: /metrics

```

