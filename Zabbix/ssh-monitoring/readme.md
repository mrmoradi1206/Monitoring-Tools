# 🔐 SSH Login Monitoring with Zabbix 7 + Telegram (Ubuntu)

This repository provides a **fully explained, step-by-step, production-ready guide**
for monitoring **successful SSH logins** on an Ubuntu server and sending **real-time alerts to Telegram**
using **Zabbix 7**.

This document is intentionally **detailed and verbose** so it can be safely shared on GitHub
and understood by **students, junior admins, and SRE/DevOps engineers** alike.

---

## 📌 What this setup does

- Detects **every successful SSH login**
- Captures **username, source IP, authentication method**
- Uses **auditd** to audit SSH-related log activity
- Uses **Zabbix Agent (ACTIVE)** to read SSH logs
- Triggers alerts using **Zabbix 7 syntax**
- Sends notifications to **Telegram**
- Supports **noise reduction** and **security filtering**

---

## 🧱 Architecture Overview

```
+------------------+
|   Ubuntu VM     |
|------------------|
| auditd           |
|  └─ monitors     |
|     auth.log     |
|        ↓         |
| Zabbix Agent     |
|  (ACTIVE)        |
+--------↓---------+
         |
+--------↓---------+
| Zabbix Server    |
|------------------|
| Item (log[])     |
| Trigger (count)  |
| Action           |
+--------↓---------+
         |
+--------↓---------+
| Telegram Bot     |
+------------------+
```

---

## 0️⃣ System Preparation (Ubuntu)

First, make sure your system is up to date and required packages are installed.

```bash
sudo apt update
sudo apt install -y zabbix-agent auditd audispd-plugins
```

Enable services so they survive reboot:

```bash
sudo systemctl enable --now zabbix-agent
sudo systemctl enable --now auditd
```

---

## 1️⃣ auditd – Why and How

Although SSH already logs events to `/var/log/auth.log`, **auditd adds an additional security layer**
by tracking file access and modifications related to authentication.

This is especially useful for **forensics and compliance**.

### Create audit rule for SSH log file

```bash
sudo tee /etc/audit/rules.d/ssh-logins.rules >/dev/null <<'EOF'
# Monitor authentication log for SSH login events
-w /var/log/auth.log -p wa -k ssh_authlog
EOF
```

### Load the rules

```bash
sudo augenrules --load
sudo systemctl restart auditd
```

### Verify audit rules

```bash
sudo auditctl -l | grep auth.log
```

You should see `/var/log/auth.log` listed.

---

## 2️⃣ Zabbix Agent Configuration (ACTIVE MODE)

### Why active mode is required

In **Zabbix 7**, log monitoring with `log[]` **only works with active checks**.
The agent must **push log entries** to the server.

### Configure agent

Edit the agent config:

```bash
sudo nano /etc/zabbix/zabbix_agentd.conf
```

Set:

```ini
ServerActive=<ZABBIX_SERVER_IP>
Hostname=<HOSTNAME_AS_DEFINED_IN_ZABBIX_UI>
```

⚠️ `Hostname` must exactly match the host name in Zabbix UI.

Restart agent:

```bash
sudo systemctl restart zabbix-agent
```

### Permissions (Ubuntu-specific)

Ubuntu restricts access to auth logs.
Add the Zabbix user to the `adm` group:

```bash
sudo usermod -aG adm zabbix
sudo systemctl restart zabbix-agent
```

---

## 3️⃣ Zabbix Item – SSH Login Log Item

Create a new item on the host in Zabbix UI.

### Item configuration

| Field | Value |
|------|------|
| Name | SSH Login |
| Type | Zabbix agent (active) |
| Type of information | Log |
| Update interval | 10s |
| History storage | 31d |
| Trends | Disabled |

### Item key (recommended)

This captures **both password and key-based logins**:

```text
log[/var/log/auth.log,"Accepted (password|publickey) for",,,skip]
```

### Alternative: password-only logins

```text
log[/var/log/auth.log,"Accepted password for",,,skip]
```

Use this if you want to be alerted **only when password authentication is used**.

---

## 4️⃣ Triggers (Zabbix 7 Expressions Explained)

Replace `n8n` with your actual Zabbix host name.

### Recommended trigger (low noise)

```text
count(/n8n/log[/var/log/auth.log,"Accepted (password|publickey) for",,,skip],30s)>0
```

**Explanation:**
- `count()` checks log entries in a time window
- `30s` groups multiple logins into a single alert
- `skip` prevents duplicate events

---

### Ignore your own IP (very common)

```text
count(/n8n/log[/var/log/auth.log,"Accepted (password|publickey) for",,,skip],30s)>0
and
find(/n8n/log[/var/log/auth.log,"Accepted (password|publickey) for",,,skip],,"like","from 1.2.3.4")=0
```

Replace `1.2.3.4` with your trusted IP.

---

### Password-only + IP filter (best practice)

```text
count(/n8n/log[/var/log/auth.log,"Accepted password for",,,skip],30s)>0
and
find(/n8n/log[/var/log/auth.log,"Accepted password for",,,skip],,"like","from 1.2.3.4")=0
```

---

### Recovery expression (auto-close problem)

```text
count(/n8n/log[/var/log/auth.log,"Accepted (password|publickey) for",,,skip],5m)=0
```

This resolves the trigger after **5 minutes of no new logins**.

---

## 5️⃣ Telegram Bot Setup

1. Open **@BotFather** in Telegram
2. Run `/newbot`
3. Copy the **BOT TOKEN**

### Get chat ID

Send a message to your bot, then:

```bash
curl -s "https://api.telegram.org/bot<BOT_TOKEN>/getUpdates"
```

Find:

```json
"chat":{"id":123456789}
```

Group chats usually start with `-100`.

---

## 6️⃣ Zabbix Media Type – Telegram (Built-in)

Navigate to:

**Administration → Media types → Telegram**

Set:

- **Token:** `<YOUR_BOT_TOKEN>`
- **To:** `{ALERT.SENDTO}`
- **Message:** `{ALERT.MESSAGE}`
- **ParseMode:** `HTML`

---

## 7️⃣ Add Telegram Media to Zabbix User

**Administration → Users → <your user> → Media → Add**

- Type: Telegram
- Send to: `<CHAT_ID>`
- When active: `1-7,00:00-24:00`
- Severity: match trigger severity
- Enabled: ✅

---

## 8️⃣ Zabbix Action (Trigger → Telegram)

Create a **Trigger Action**.

### Condition

```
Trigger name contains SSH login
```

### Message template

**Subject**
```text
SSH login on {HOST.NAME}
```

**Message**
```text
🚨 <b>SSH LOGIN DETECTED</b>

<b>Host:</b> {HOST.NAME}
<b>Time:</b> {EVENT.DATE} {EVENT.TIME}

<b>Details:</b>
<code>{ITEM.LASTVALUE}</code>
```

---

## 9️⃣ Testing the Setup

Run:

```bash
ssh user@<VM_IP>
```

You should immediately receive a Telegram message containing:
- Username
- Source IP
- Authentication method

---

## 🔒 Security Recommendations

- Disable SSH password authentication
- Use key-based auth only
- Combine with **Fail2Ban**
- Monitor sudo usage
- Keep audit logs backed up

---
