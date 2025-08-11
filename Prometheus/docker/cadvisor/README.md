# Bring up Cadvisor docker compose
 
 docker-compose up -d 
 
 
 
 **Dashboard id** :  13112  14282
 
 ![image](https://user-images.githubusercontent.com/88557305/181718143-f86da501-5aa1-4188-a1bc-35ab70c3eef4.png)
![image](https://user-images.githubusercontent.com/88557305/181718438-d311b481-aa6a-4b8b-9b1b-428a3ac75e2d.png)


# Prometheus Side 

```
  - job_name: 'Cadvisor'
    metrics_path: /metrics
    static_configs:
         - targets:

            - 192.168.4.180:8070
```
