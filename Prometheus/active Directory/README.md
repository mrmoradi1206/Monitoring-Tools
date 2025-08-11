# Install Windows Exporter and Enable AD Collector
```
https://github.com/prometheus-community/windows_exporter/releases/download/v0.23.1/windows_exporter-0.23.1-amd64.msi

msiexec /i windows_exporter-v0.23.1-386_2.msi ENABLED_COLLECTORS="ad,iis,logon,memory,process,tcp,thermalzone" TEXTFILE_DIR="C:\custom_metrics\"

sc config windows_exporter binPath= "\"C:\Program files (x86)\windows_exporter\windows_exporter.exe\" --log.format logger:eventlog?name=windows_exporter  --collectors.enabled \"ad,dns,cs,cpu,logical_disk,logon,memory,net,os,service,system,tcp\" --telemetry.addr :9182"
```

# import Dashboard Json file
![image](https://user-images.githubusercontent.com/88557305/181624149-c4df3fba-c8ca-4dfa-a873-4137cac421fe.png)
