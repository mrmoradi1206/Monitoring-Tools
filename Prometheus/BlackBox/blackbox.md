#!/bin/bash
RELEASE=0.26.0
wget https://github.com/prometheus/blackbox_exporter/releases/download/v$RELEASE/blackbox_exporter-$RELEASE.linux-amd64.tar.gz
tar xvzf blackbox_exporter-$RELEASE.linux-amd64.tar.gz
mv   blackbox_exporter-$RELEASE.linux-amd64/blackbox_exporter /usr/local/bin 

mkdir -p /etc/blackbox
mv blackbox_exporter-$RELEASE.linux-amd64/blackbox.yml /etc/blackbox && rm -rf ./blackbox_exporter-$RELEASE.linux-amd64
 sudo useradd -rs /bin/false blackbox && sudo chown blackbox:blackbox /usr/local/bin/blackbox_exporter &&   sudo chown -R blackbox:blackbox /etc/blackbox/*

 echo -n "[Unit]
Description=Blackbox Exporter Service
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=blackbox
Group=blackbox
ExecStart=/usr/local/bin/blackbox_exporter \
  --config.file=/etc/blackbox/blackbox.yml \
  --web.listen-address=":9115"

Restart=always

[Install]
WantedBy=multi-user.target" > /lib/systemd/system/blackbox.service
systemctl daemon-reload
systemctl enable blackbox.service
systemctl start blackbox.service



#####
# Dashboard ID : 13659 7587


####
![image](https://user-images.githubusercontent.com/88557305/180177299-e46409ad-e182-4b89-8d84-3adf093f84d4.png)



##
# Pometheus Side Config
##
```
  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
        - packops.dev
        - packops.ir
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 192.168.4.182:9115

  - job_name: 'blackbox-ICMP'
    metrics_path: /probe
    params:
      module:
      - icmp
    static_configs:
      - targets:
        - 8.8.8.8
        - 4.2.2.4
        - time.ir
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 192.168.1.114:9115

```


