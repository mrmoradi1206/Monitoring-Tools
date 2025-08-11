```
#Influxdb Installation

sudo curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -                                    
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
sudo apt update
sudo apt install influxdb -y
sudo systemctl start influxdb
sudo systemctl enable influxdb
influx
create database telegraf
create user telegraf with password 'Packps22@xx'
show databases
show users

#telegraf Installation

apt install telegraf -y
sudo systemctl start telegraf
sudo systemctl enable telegraf
cd /etc/telegraf/
mv telegraf.conf telegraf.conf.default


echo "
[agent]
  hostname = "linux1"
  flush_interval = "15s"
  interval = "15s"


# Input Plugins
[[inputs.cpu]]
    percpu = true
    totalcpu = true
    collect_cpu_time = false
    report_active = false
[[inputs.disk]]
    ignore_fs = ["tmpfs", "devtmpfs", "devfs"]
[[inputs.io]]
[[inputs.mem]]
[[inputs.net]]
[[inputs.system]]
[[inputs.swap]]
[[inputs.netstat]]
[[inputs.processes]]
[[inputs.kernel]]

# Output Plugin InfluxDB
[[outputs.influxdb]]
  database = "telegraf"
  urls = [ "http://127.0.0.1:8086" ]
  username = "telegraf"
  password = "Packps22@xx"

"  > /etc/telegraf/telegraf.conf

#grafana Side

sudo apt-get install -y apt-transport-https
sudo apt-get install -y software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
apt update && apt install  grafana
systemctl enable grafana-server
sudo systemctl start grafana-server

```
