# Client syslog Config for Forwarding Data to Elasticsearch 

```
vim /etc/rsyslog.conf
*.* @IP_FLUENT:5140 
```

# Fluent Config for Syslog

```
<source>
 @type syslog
 port 5140
 tag syslognew
</source>

<match syslognew**>
  @type elasticsearch
  host elasticsearch
  port 9200
  logstash_format true
  logstash_prefix syslog
  logstash_dateformat %Y%m%d
  include_tag_key true
  type_name syslog
  tag_key @log_name
  flush_interval 1s

</match>


```
