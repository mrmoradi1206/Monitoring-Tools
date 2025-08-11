

# Add IIS Collector in Windows Exporter 
https://github.com/prometheus-community/windows_exporter/releases/download/v0.19.0/windows_exporter-0.19.0-386.msi

msiexec /i windows_exporter-0.19.0-386_2.msi ENABLED_COLLECTORS="ad,**iis**,logon,memory,process,tcp,thermalzone" TEXTFILE_DIR="C:\custom_metrics\"

sc config windows_exporter binPath= "\"C:\Program files (x86)\windows_exporter\windows_exporter.exe\" --log.format logger:eventlog?name=windows_exporter  --collectors.enabled \"ad,dns,cs,cpu,logical_disk,logon,memory,net,os,service,system,tcp\" --telemetry.addr :9182"




# Grafana Dashboard ID  : 14532

![image](https://user-images.githubusercontent.com/88557305/181702786-038c22dc-70c6-47b8-98a4-0e8bbb41981b.png)
