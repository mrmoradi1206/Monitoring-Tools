
# SSH Login Monitoring with Zabbix 7 + Telegram (Ubuntu)

This repository contains a **complete, end-to-end configuration** for detecting
**successful SSH logins** on an Ubuntu server and sending **real-time alerts to Telegram**
using **Zabbix 7**.

This setup is written **from the beginning**, including **auditd**, exactly as used in production.

---

## Architecture

Ubuntu VM ├─ auditd (watches auth.log) ├─ /var/log/auth.log │     ↓ ├─ Zabbix Agent (ACTIVE) │     ↓ ├─ Zabbix Server (Trigger) │     ↓ └─ Telegram Bot (Webhook)

---

## 0) System Preparation (Ubuntu)

```bash
sudo apt update
sudo apt install -y zabbix-agent auditd audispd-plugins
sudo systemctl enable --now zabbix-agent auditd


---

1) auditd – Track SSH login events

Although Zabbix reads /var/log/auth.log directly, auditd ensures SSH activity is audited.

Create audit rule

sudo tee /etc/audit/rules.d/ssh-logins.rules >/dev/null <<'EOF'
# Successful SSH login events on Ubuntu
-w /var/log/auth.log -p wa -k ssh_authlog
EOF

Load rules

sudo augenrules --load
sudo systemctl restart auditd

Verify

sudo auditctl -l | grep auth.log


---

2) Zabbix Agent Configuration (ACTIVE REQUIRED)

> Zabbix 7 requires active agent checks for log[] items.



Edit agent config:

sudo nano /etc/zabbix/zabbix_agentd.conf

Set:

ServerActive=<ZABBIX_SERVER_IP>
Hostname=<HOSTNAME_AS_DEFINED_IN_ZABBIX_UI>

Restart agent:

sudo systemctl restart zabbix-agent

Permissions (Ubuntu)

sudo usermod -aG adm zabbix
sudo systemctl restart zabbix-agent


---

3) Zabbix Item – SSH Login

Create an item on the host:

Field	Value

Name	SSH Login
Type	Zabbix agent (active)
Type of information	Log
Update interval	10s
History	31d
Trends	Do not store


Item key (password + publickey)

log[/var/log/auth.log,"Accepted (password|publickey) for",,,skip]

Password-only (recommended security option)

log[/var/log/auth.log,"Accepted password for",,,skip]


---

4) Triggers (Zabbix 7 syntax)

Replace n8n with your Zabbix host name.

Recommended (reduce noise – 30s window)

count(/n8n/log[/var/log/auth.log,"Accepted (password|publickey) for",,,skip],30s)>0

Ignore your own IP

count(/n8n/log[/var/log/auth.log,"Accepted (password|publickey) for",,,skip],30s)>0
and
find(/n8n/log[/var/log/auth.log,"Accepted (password|publickey) for",,,skip],,"like","from 1.2.3.4")=0

Password-only + ignore IP (best practice)

count(/n8n/log[/var/log/auth.log,"Accepted password for",,,skip],30s)>0
and
find(/n8n/log[/var/log/auth.log,"Accepted password for",,,skip],,"like","from 1.2.3.4")=0

Recovery expression (auto-close after 5 minutes)

count(/n8n/log[/var/log/auth.log,"Accepted (password|publickey) for",,,skip],5m)=0


---

5) Telegram Bot

Create a bot using @BotFather and copy the BOT TOKEN.

Get your chat_id:

curl -s "https://api.telegram.org/bot<BOT_TOKEN>/getUpdates"

Look for:

"chat":{"id":123456789}

> Group chat IDs usually start with -100.




---

6) Zabbix Media Type – Telegram (Built-in)

Go to: Administration → Media types → Telegram

Set:

Token: <YOUR_BOT_TOKEN>

To: {ALERT.SENDTO}

Message: {ALERT.MESSAGE}

ParseMode: HTML



---

7) Add Telegram Media to User

Administration → Users → <your user> → Media → Add

Type: Telegram

Send to: <CHAT_ID>

When active: 1-7,00:00-24:00

Severity: enable at least trigger severity

Enabled: ✅



---

8) Zabbix Action (Trigger → Telegram)

Configuration → Actions → Trigger actions → Create

Condition

Trigger name contains SSH login

Message template

Subject

SSH login on {HOST.NAME}

Message

🚨 <b>SSH LOGIN DETECTED</b>

<b>Host:</b> {HOST.NAME}
<b>Time:</b> {EVENT.DATE} {EVENT.TIME}

<b>Details:</b>
<code>{ITEM.LASTVALUE}</code>


---

9) Test

ssh user@<VM_IP>

A Telegram alert should arrive instantly.



