```
group_by: ['alertname']  # Alerts with these labels end up in a group, i.e., they go together in just one Slack notification (makes it less spammy).
  group_wait: 30s          # How long to let a group build up, before sending it to Slack FOR THE FIRST TIME.
  group_interval: 5m       # The group now lives on in memory, sleeping, but checking in on things after each group_interval. If a new alert was added during an
                           # interval, an updated Slack notification is sent at these occasions.
                           #
                           #    CASES: 
                           #        a) NEW ALERT CAME IN DURING THE GROUP_INTERVAL TIME: 
                           #               - Group wakes up 
                           #               - New alert is added to group 
                           #               - Updated notification sent to Slack, including all it's alerts (the old ones and the new one).
                           #               - Group goes back to sleep for another group_interval.
                           #
                           #        b) NO NEW ALERTS:
                           #               - Group wakes up
                           #               - Group goes back to sleep for another group_interval.
                           #               
                           #        c) NO NEW ALERTS UP UNTIL THE REPEAT_INTERVAL:
                           #               - Group wakes up
                           #               - Group received no new alerts for a few successive group_intervals, and we now reached the timer of the
                           #                 repeat_interval. 
                           #               - Group now REPEATS it's latest Slack notification (NOTE: not updating it as earlier).
                           #               - NOTE: the repeat_interval is counted from the last Slack notification sent, not from the
                           #                 end of the group_interval that just elapsed.
                           #
                           #    ILLUSTRATION:
                           #         ________________________________ __________________________________________________________________________________________________
                           #        <<--      repeat interval       ||                                       repeat_interval                                           |
                           #         ________________________________ ________________________________ ________________________________ ________________________________
                           #        |        group_interval         ||        group_interval         ||        group_interval         ||        group_interval         |
                           #      [N1]--------------[A]-----------[N2]------------------------------------------------------------------------------------------------[N2]       
                           #       ^                 ^             ^                                 ^                                ^                                ^
                           #     first            new alert   updated notification               no new alerts,                   no new alerts,                   no new alerts,
                           # notification                        due to [A]                   no new notification              no new notification            repeat_interval elapsed
                           #                                                                                                                                        repeats N2
                           #                  
                           
  repeat_interval: 1h      # How long to wait before REPEATING a Slack notification that has already been sent.
