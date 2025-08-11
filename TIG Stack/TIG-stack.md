
# 1- Influxdb Installation
```
wget -q https://repos.influxdata.com/influxdata-archive_compat.key
echo '393e8779c89ac8d958f81f942f9ad7fb82a25e133faddaf92e15b16e6ac9ce4c influxdata-archive_compat.key' | sha256sum -c && cat influxdata-archive_compat.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg > /dev/null
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' | sudo tee /etc/apt/sources.list.d/influxdata.list

sudo apt-get update && sudo apt-get install influxdb2

influx setup
```
![image](https://github.com/farshadnick/Monitoring-Stack-Course/assets/88557305/c386a020-b2ab-425c-af59-8f3cbcd1c081)
```
user :     packops
Orgonization:  packops-org
Bucket:  tigstack
```
# 2- Create API token
![image](https://github.com/farshadnick/Monitoring-Stack-Course/assets/88557305/65f104a5-7f21-4037-a4b1-454daf4a5daf)
![image](https://github.com/farshadnick/Monitoring-Stack-Course/assets/88557305/da57a774-bbd2-4e85-a7eb-0274244223ca)
![Uploading image.png…]()


#telegraf Installation and configure (determine influxdb address and token)
```
apt install telegraf -y
sudo systemctl start telegraf
sudo systemctl enable telegraf
cd /etc/telegraf/
mv telegraf.conf telegraf.conf.default
```
```
echo "
[global_tags]
[agent]
  ## Default data collection interval for all inputs
  interval = "10s"
  ## Rounds collection interval to 'interval'
  ## ie, if interval="10s" then always collect on :00, :10, :20, etc.
  round_interval = true

  ## Telegraf will send metrics to outputs in batches of at most
  ## metric_batch_size metrics.
  ## This controls the size of writes that Telegraf sends to output plugins.
  metric_batch_size = 1000

  ## Maximum number of unwritten metrics per output.  Increasing this value
  ## allows for longer periods of output downtime without dropping metrics at the
  ## cost of higher maximum memory usage.
  metric_buffer_limit = 10000

  ## Collection jitter is used to jitter the collection by a random amount.
  ## Each plugin will sleep for a random time within jitter before collecting.
  ## This can be used to avoid many plugins querying things like sysfs at the
  ## same time, which can have a measurable effect on the system.
  collection_jitter = "0s"

  ## Collection offset is used to shift the collection by the given amount.
  ## This can be be used to avoid many plugins querying constraint devices
  ## at the same time by manually scheduling them in time.
  # collection_offset = "0s"

  ## Default flushing interval for all outputs. Maximum flush_interval will be
  ## flush_interval + flush_jitter
  flush_interval = "10s"
  flush_jitter = "0s"
  precision = "0s"
  hostname = "srv1"
  ## If set to true, do no set the "host" tag in the telegraf agent.
  omit_hostname = false
 [[outputs.influxdb_v2]]
   urls = ["http://127.0.0.1:8086"]
   token = "Tt9SRXCcGs1w1aBJXIWm5fAfaY_6-fLbyAxGs8lLmTIB3tdwJJdrh-k569jikiHthFggQspc5tDl2KeQKTquQA=="
   organization = "packops-org"
   bucket = "tigstack"
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


"  > /etc/telegraf/telegraf.conf
```
#grafana Side
```
sudo apt-get install -y apt-transport-https
sudo apt-get install -y software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
apt update && apt install  grafana
systemctl enable grafana-server
sudo systemctl start grafana-server
```
## add grafana id 15650
https://grafana.com/grafana/dashboards/15650-telegraf-influxdb-2-0-flux/
