apt install python3-pip

pip install mktxp
 pip install git+https://github.com/akpw/mktxp

mktxp edit 
```
[Sample-Router]
    enabled = False         # turns metrics collection for this RouterOS device on / off
    
    hostname = 192.168.4.1    # RouterOS IP address
    port = 8728             # RouterOS IP Port
    
    username = username     # RouterOS user, needs to have 'read' and 'api' permissions
    password = password
    
    use_ssl = False                 # enables connection via API-SSL servis
    no_ssl_certificate = False      # enables API_SSL connect without router SSL certificate
    ssl_certificate_verify = False  # turns SSL certificate verification on / off   

    dhcp = True                     # DHCP general metrics
    dhcp_lease = True               # DHCP lease metrics
    pool = True                     # Pool metrics
    interface = True                # Interfaces traffic metrics
    firewall = True                 # Firewall rules matching traffic metrics
    monitor = True                  # Interface monitor metrics
    route = True                    # Routes metrics
    wireless = True                 # WLAN general metrics
    wireless_clients = True         # WLAN clients metrics
    capsman = True                  # CAPsMAN general metrics
    capsman_clients = True          # CAPsMAN clients metrics

    use_comments_over_names = False  # when available, forces using comments over the interfaces names 

```

mktxp print -en R1 -cc




Grafana Dashboard : 13679



Mikrotik Side 
```
/user group add name=mktxp_group policy=api,read
/user add name=mktxp_user group=mktxp_group password=mktxp_user_password
```
