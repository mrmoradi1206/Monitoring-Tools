```
NODE_EXPORTER_VERSION="1.3.1"
NODE_EXPORTER_USER="node_exporter"
BIN_DIRECTORY="/usr/local/bin"
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
tar -xf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter ${BIN_DIRECTORY}/
chown ${NODE_EXPORTER_USER}:${NODE_EXPORTER_USER} ${BIN_DIRECTORY}/node_exporter
rm -rf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64*
mkdir /etc/node-exporter

openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout node_exporter.key -out node_exporter.crt -subj "/C=ZA/ST=CT/L=SA/O=VPN/CN=localhost" -addext "subjectAltName = DNS:localhost"
chown -R ${NODE_EXPORTER_USER}:${NODE_EXPORTER_USER} /etc/node-exporter

cat  > /etc/node-exporter/config.yml << EOF
tls_server_config:
  cert_file: node_exporter.crt
  key_file: node_exporter.key
basic_auth_users:
  prometheus: <the-output-value-of-htpasswd>
EOF

cat > /etc/systemd/system/node_exporter.service << EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
StartLimitIntervalSec=500
StartLimitBurst=5
[Service]
User=${NODE_EXPORTER_USER}
Group=${NODE_EXPORTER_USER}
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=${BIN_DIRECTORY}/node_exporter --web.config=/etc/node-exporter/config.yml
[Install]
WantedBy=multi-user.target
EOF

 systemctl daemon-reload
 systemctl enable node_exporter
 systemctl restart node_exporter


##### Prometheus Side 
#ADD Following Config in prometheus config
# /etc/prometheus/prometheus.yml and copy node-exporter.crt in /etc/prometheus
echo -n "
scrape_configs:
  - job_name: 'node-exporter-tls'
    scheme: https
    basic_auth:
      username: prometheus
      password: <the-plain-text-password>
    tls_config:
      ca_file: node_exporter.crt
      insecure_skip_verify: true
    static_configs:
    - targets: ['node-exporter-ip:9100']
      labels:
        instance: friendly-instance-name" > /etc/prometheus/prometheus.yml


```
