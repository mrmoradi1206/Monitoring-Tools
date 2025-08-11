# Zabbix Auto Registration Tutorial

## 📌 Overview
Zabbix Auto Registration allows new agents to be automatically added to Zabbix Server when they first connect, without manual configuration.

---

## ⚙️ Step 1: Prepare Zabbix Agent

### Install and configure Zabbix Agent
```
sudo apt install zabbix-agent -y   # Debian/Ubuntu
```
# or
```
sudo yum install zabbix-agent -y   # CentOS/RHEL
```
## Configure Zabbix Agent
```
Edit /etc/zabbix/zabbix_agentd.conf:

Server=<ZABBIX_SERVER_IP>
ServerActive=<ZABBIX_SERVER_IP>
HostnameItem=system.hostname
HostMetadata=packops   # Used for auto-registration condition
```
Restart Agent:
```
sudo systemctl restart zabbix-agent
sudo systemctl enable zabbix-agent
```

🛠 Step 2: Create Auto Registration Action in Zabbix

    Login to Zabbix Web UI as Admin.

    Navigate:
    Configuration → Actions → Auto registration actions → Create action

    Action Name: Auto Register Linux Hosts

    Conditions:

        Host metadata → contains → packops

    Operations:

        Add Host

        Add to Host Group: e.g., Linux servers

        Link Template: e.g., Template OS Linux by Zabbix agent

    Save Action.


![Screenshot 1](https://github.com/user-attachments/assets/d60eafee-3d78-48ce-9620-5a99afa6411d)

![Screenshot 2](https://github.com/user-attachments/assets/ed2b2e09-324e-4859-ac2a-7d4bd1c4ba97)
