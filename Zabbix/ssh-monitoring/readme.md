# SSH Login Alerts to Telegram (Zabbix 7 + Ubuntu)

This repository documents a **production-ready setup** to detect **successful SSH logins**
on an Ubuntu VM using **Zabbix 7 (active agent)** and send **real-time alerts to Telegram**.

---

## Architecture

```
Ubuntu VM
 └─ /var/log/auth.log
      ↓
Zabbix Agent (ACTIVE)
      ↓
Zabbix Server (Trigger)
      ↓
Telegram Bot (Webhook)
```

---

## Prerequisites

### On the monitored Ubuntu VM
- Zabbix Agent or Agent2 installed
- SSH logging enabled
- `/var/log/auth.log` exists

Check:
```bash
sudo tail -n 20 /var/log/auth.log
```

---

## 1) Zabbix Agent Configuration (REQUIRED)

Log monitoring in Zabbix 7 **requires active checks**.

Edit:
```bash
sudo nano /etc/zabbix/zabbix_agentd.conf
```

Set:
```ini
ServerActive=<ZABBIX_SERVER_IP>
Hostname=<HOSTNAME_AS_DEFINED_IN_ZABBIX_UI>
```

Restart:
```bash
sudo systemctl restart zabbix-agent
```

### Permissions (Ubuntu)
```bash
sudo usermod -aG adm zabbix
sudo systemctl restart zabbix-agent
```

---

## 2) Zabbix Item – SSH Login

Create item on the host:

| Field | Value |
|------|------|
| Name | SSH Login |
| Type | Zabbix agent (active) |
| Type of information | Log |
| Update interval | 10s |
| History | 31d |
| Trends | Do not store |

### Item Key (password OR key login)
```text
log[/var/log/auth.log,"Accepted (password|publickey) for",,,skip]
```

### (Optional) Password-only logins
```text
log[/var/log/auth.log,"Accepted password for",,,skip]
```

---

## 3) Triggers (Zabbix 7 syntax)

Replace `n8n` with your Zabbix host name.

### A) Simple trigger (fires on each login)
```text
last(/n8n/log[/var/log/auth.log,"Accepted (password|publickey) for",,,skip])<>""
```

### B) Recommended (reduce noise – 30s window)
```text
count(/n8n/log[/var/log/auth.log,"Accepted (password|publickey) for",,,skip],30s)>0
```

### C) Ignore your own IP (replace 1.2.3.4)
```text
count(/n8n/log[/var/log/auth.log,"Accepted (password|publickey) for",,,skip],30s)>0
and
find(/n8n/log[/var/log/auth.log,"Accepted (password|publickey) for",,,skip],,"like","from 1.2.3.4")=0
```

### D) Password-only + ignore your IP (recommended)
```text
count(/n8n/log[/var/log/auth.log,"Accepted password for",,,skip],30s)>0
and
find(/n8n/log[/var/log/auth.log,"Accepted password for",,,skip],,"like","from 1.2.3.4")=0
```

### Recovery expression (auto-close after 5 minutes)
```text
count(/n8n/log[/var/log/auth.log,"Accepted (password|publickey) for",,,skip],5m)=0
```

---

## 4) Telegram Bot

Create a bot via **@BotFather** and copy the **BOT TOKEN**.

Get your `chat_id`:
```bash
curl -s "https://api.telegram.org/bot<BOT_TOKEN>/getUpdates"
```

Look for:
```json
"chat":{"id":123456789}
```

> Group chat IDs usually start with `-100`.

---

## 5) Zabbix Media Type (Telegram – built-in)

Go to:
**Administration → Media types → Telegram**

Set:
- **Token:** `<YOUR_BOT_TOKEN>`
- **To:** `{ALERT.SENDTO}`
- **Message:** `{ALERT.MESSAGE}`
- **ParseMode:** `HTML`

---

## 6) Add Telegram Media to User

**Administration → Users → <your user> → Media → Add**

- Type: Telegram
- Send to: `<CHAT_ID>`
- When active: `1-7,00:00-24:00`
- Severity: enable at least the trigger severity
- Enabled: ✅

---

## 7) Zabbix Action (Trigger → Telegram)

**Configuration → Actions → Trigger actions → Create**

### Condition
- Trigger name contains `SSH login`

### Message Template

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

## 8) Test

```bash
ssh user@<VM_IP>
```

You should immediately receive a Telegram alert with username and source IP.

---

## Notes / Best Practices
- Prefer **key-based SSH** and disable password auth if possible
- Combine with **Fail2Ban** for automatic blocking
- Use IP filters in triggers to avoid alert noise
- Works with Zabbix 7.x (tested)

---

