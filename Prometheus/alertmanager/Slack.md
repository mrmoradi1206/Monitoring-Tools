You will need a Slack Webhook URL in order to receive alerting notifications. Please go to **Slack -> Administration -> Manage apps** as shown below:
![slack_dashboard](https://github.com/farshadnick/Monitoring-Stack-Course/assets/88557305/812e8fb2-86f7-4372-b330-65fcb9096804)

In the Manage apps directory, search for **Incoming Webhooks** and add it to your Slack workspace as shown below:
![slack_incoming_webhook](https://github.com/farshadnick/Monitoring-Stack-Course/assets/88557305/043508f2-5103-4e07-aba2-4b58893b82bb)

After you click the Add to Slack button as shown above, you will be directed to the configuration page. Please select the channel that you would like to receive notifications from Alertmanager, in this example, we will use a channel called “#test-alerts”:
![slack_config_channel](https://github.com/farshadnick/Monitoring-Stack-Course/assets/88557305/c027bf76-0604-4c4e-a905-197fcddbeb7c)

![slack_webhook_url](https://github.com/farshadnick/Monitoring-Stack-Course/assets/88557305/5b902f55-1ea6-46e3-b39c-62e74f4f38d8)

## /etc/alertmanager/alertmanager.yml
```
global:
  resolve_timeout: 1m
  ## PUT Your Webhook token here
  slack_api_url: 'https://hooks.slack.com/services/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'
route:
  receiver: 'telegram'
  routes:
    - match:
        severity: critical
      receiver: 'slack-prom'
    - match:
        team: dba
      receiver: 'slack-dba'

receivers:
- name: 'telegram'
  telegram_configs:
  - bot_token: <Token Telegram Bot>
    chat_id: <Your Chat ID>
    api_url: "https://api.telegram.org"
    send_resolved: true
    parse_mode: ""

- name: 'slack-prom'
  slack_configs:
  - channel: '#test-alerts'
    send_resolved: true
    title: "{{ range .Alerts }}{{ .Annotations.summary }}\n{{ end }}"
    text: "{{ range .Alerts }}{{ .Annotations.description }}\n{{ end }}"

```
