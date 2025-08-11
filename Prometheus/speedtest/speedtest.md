# Setup Speedtest Exporter on a Client 
## Speedtest Docker Compose 
```
services:
    speedtest:
      restart: always
      image:  ghcr.io/danopstech/speedtest_exporter:v0.0.5
      ports:
      - 9516:9090
```

# Prometheus Side 
```
  - job_name: 'speedtest-exporter'
    scrape_interval: 1m #this interval is for running speedtest change it to logical number 
    scrape_timeout: 1m
    static_configs:
    - targets: ['192.168.4.182:9516']
```

# Grafana Dashboard
ID : ***14336***

![image](https://user-images.githubusercontent.com/88557305/180394812-d24e19c1-f1c9-4f62-baea-27aee596fe85.png)
