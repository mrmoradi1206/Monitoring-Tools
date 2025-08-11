```
NODE_EXPORTER_VERSION="1.3.1"
NODE_EXPORTER_USER="node_exporter"
BIN_DIRECTORY="/usr/local/bin"
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
tar -xf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter ${BIN_DIRECTORY}/
chown ${NODE_EXPORTER_USER}:${NODE_EXPORTER_USER} ${BIN_DIRECTORY}/node_exporter
rm -rf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64*
apt install prometheus & python3-bcrypt
pip3 install getpass4
pass.py
-------------
import getpass
import bcrypt

password = getpass.getpass("password: ")
hashed_password = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt())
print(hashed_password.decode())



python3 pass.py
promtool check web-config  /etc/node-exporter/config.yml
mkdir /etc/node-exporter
cat  > /etc/node-exporter/config.yml << EOF
basic_auth_users:
  prometheus: <HASH_OF_PASS.PY>
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
ExecStart=${BIN_DIRECTORY}/node_exporter --web.config.file=/etc/node-exporter/config.yml
[Install]
WantedBy=multi-user.target
EOF

 systemctl daemon-reload
 systemctl enable node_exporter
 systemctl restart node_exporter


##### Prometheus Side 
#ADD Following Config in prometheus config
# /etc/prometheus/prometheus.yml and copy node-exporter.crt in /etc/prometheus

scrape_configs:
  - job_name: 'node-exporter'
    basic_auth:
      username: prometheus
      password: <PLAIN_TEXT_PASSWORD>
    static_configs:
    - targets: ['node-exporter-ip:9100']

       
 ```
 
