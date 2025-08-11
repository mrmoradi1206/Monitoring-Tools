```
groupadd --system prometheus
grep prometheus /etc/group
useradd -s /sbin/nologin -r -g prometheus prometheus

apt update && apt install bind9 -y
curl -s https://api.github.com/repos/prometheus-community/bind_exporter/releases/latest | grep browser_download_url | grep linux-amd64 |  cut -d '"' -f 4 | wget -qi -
tar xvf bind_exporter*.tar.gz
sudo mv bind_exporter-*/bind_exporter /usr/local/bin

/etc/bind/named.conf.options (add after options block )
statistics-channels {
  inet 127.0.0.1 port 8053 allow { 127.0.0.1; };
};

sudo systemctl restart named
sudo tee /etc/systemd/system/bind_exporter.service<<EOF
[Unit]
Description=Prometheus
Documentation=https://github.com/digitalocean/bind_exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/bind_exporter \
  --bind.pid-file=/var/run/named/named.pid \
  --bind.timeout=20s \
  --web.listen-address=0.0.0.0:9153 \
  --web.telemetry-path=/metrics \
  --bind.stats-url=http://localhost:8053/ \
  --bind.stats-groups=server,view,tasks

SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl restart bind_exporter.service
sudo systemctl enable bind_exporter.service


# prometheus side 

  - job_name: dns
    static_configs:
       - targets:
         - 192.168.4.182:9153
    metrics_path: /metrics




```
# dashboard 1666
![image](https://user-images.githubusercontent.com/88557305/180322849-21a90bdd-b0c8-4200-bdb2-6c673d46c869.png)
