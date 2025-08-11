What Does Clustering do for Alertmanager ?
it will make alertmanager to act like a single instance but with FT
# in First Alertmanager (add to Alertmanager Systemd Service )
ExecStart=/usr/local/bin/alertmanager --config.file="/etc/alertmanager/alertmanager.yml" --storage.path="/var/lib/alertmanager/" --web.listen-address="0.0.0.0:9093" --cluster.advertise-address="YOUR_CURRENT_ALT-MG-IP:9094" --cluster.peer="YOUR_Second_ALT-MG-IP:9094"
# in Second Alertmanager (add to Alertmanager Systemd Service )
ExecStart=/usr/local/bin/alertmanager --config.file="/etc/alertmanager/alertmanager.yml" --storage.path="/var/lib/alertmanager/" --web.listen-address="0.0.0.0:9093" --cluster.advertise-address="YOUR_CURRENT_ALT-MG-IP:9094" --cluster.peer="YOUR_First_ALT-MG-IP:9094"
