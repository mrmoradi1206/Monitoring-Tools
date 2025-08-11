# SSL Certificate Expiry Check for Zabbix

This script checks how many days remain until an SSL certificate expires.

```
#!/bin/bash
# /home/zabbix/checkssl.sh

data=$(echo | openssl s_client -servername $1 -connect $1:${2:-443} 2>/dev/null \
    | openssl x509 -in /dev/stdin -noout -enddate \
    | sed -e 's#notAfter=##')

ssldate=$(date -d "${data}" '+%s')
nowdate=$(date '+%s')

diff=$((ssldate - nowdate))
echo $((diff / 86400))
```
Zabbix Item Key Example:


system.run[/home/zabbix/checkssl.sh example.com 443]
