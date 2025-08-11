# What is Federation ?
On any given Prometheus server, the /federate endpoint allows retrieving the current value for a selected set of time series in that server. At least one match[] URL parameter must be specified to select the series to expose. 


# Cross Federation  VS Global Federation 

![image](https://user-images.githubusercontent.com/88557305/182715749-0566a659-7ebd-48f3-b970-699113d672e6.png)






```
  - job_name: 'federate'
    honor_labels: true
    metrics_path: '/federate'
    params:
      'match[]':
        - '{__name__=~".+"}'
    static_configs:
      - targets:
        - '192.168.4.180:9090'
```
```

      'match[]':
        - '{job="Mysql"}'
        - '{job="node"}'
        - '{__name__=~".+"}’  #Scrape ALL Metrics!
```
[image](https://user-images.githubusercontent.com/88557305/182714922-2a317f0c-d5f2-4316-ac56-b730e2067a8a.png)
```
    params:
      'match[]':
        # all metrics with label job == "prometheus"
        - '{job="prometheus"}'
        # plus all metrics with label foo == "bar" where instance != "example.com"
        - '{foo="bar", instance!="example.com"}'         
        # and so on

```
