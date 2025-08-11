# Installation 

```
cd /opt && wget https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v0.10.0/nginx-prometheus-exporter_0.10.0_linux_amd64.tar.gz
tar -xzvf nginx-prometheus-exporter_0.10.0_linux_amd64.tar.gz
mv nginx-prometheus-exporter /usr/local/bin/ && chmod +x /usr/local/bin/nginx-prometheus-exporter 
#For Running Without Service         #/usr/local/bin/nginx-prometheus-exporter  -nginx.scrape-uri=http://127.0.0.1/basic_status 
```

# Service for Nginx Exporter

```
echo -n "[Unit]
Description=Nginx Exporter
Wants=network-online.target
After=network-online.target
[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/nginx-prometheus-exporter  \
-nginx.scrape-uri=http://127.0.0.1:8090/basic_status
SyslogIdentifier=nginx-exporter
Restart=always
[Install]
WantedBy=multi-user.target" | tee /etc/systemd/system/nginx-exporter.service >/dev/null

```
systemctl daemon-reload

systemctl enable nginx-exporter --now


# Nginx Side Config

/etc/nginx/site-enabled/stub.conf

```
server {
   listen 8090 ;

   location = /basic_status {
     stub_status;

   }


}
```

# Listening on :9113
# Nginx exporter :12708

![image](https://user-images.githubusercontent.com/88557305/180165571-7b9d0a08-7d7f-4800-a617-8c687d0cacdb.png)

# Add Exporter to  Prometheus for Scraping 
```
  - job_name: NGINX
    static_configs:
       - targets:
         - 192.168.4.182:9113
    metrics_path: /metrics
```

