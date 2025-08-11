
alertmanager/config.yml"
-------------------------

   Becarefull  **parse_mode: ""**  Should be set  to "" (Null) Otherwise you'll get Error
```
- name: 'tg_new'
  telegram_configs:
  - bot_token: 5567554827:AAGdwucdw6QI_Cl-sBghTUYUVpuUTmYVVWE
    chat_id: 96100908
    api_url: "https://api.telegram.org"
    send_resolved: true
    parse_mode: ""


```
