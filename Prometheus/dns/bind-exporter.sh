groupadd --system bind-exporter
useradd -s /sbin/nologin -r -g bind-exporter bind-exporter

RELEASE=0.7.0
wget https://github.com/prometheus-community/bind_exporter/releases/download/v$RELEASE/bind_exporter-$RELEASE.linux-amd64.tar.gz
tar xvf bind_exporter-$RELEASE.linux-amd64.tar.gz

cp bind_exporter-$RELEASE.linux-amd64/bind_exporter /usr/local/bin/bind_exporter
chown bind-exporter:bind-exporter /usr/local/bin/bind_exporter


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

# For Exposing Monitoring Metrics 
#
echo -n "statistics-channels {
  inet 127.0.0.1 port 8053 allow { 127.0.0.1; };
};" >> /etc/bind/named.conf.options


sudo systemctl daemon-reload
sudo systemctl restart bind_exporter.service
sudo systemctl restart named.service
sudo systemctl enable bind_exporter.service
