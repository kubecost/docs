# Capture a bug report

The Kubecost bug report feature captures relevant product configuration data and logs to debug an active deployment.
To capture a bug report: visit __Settings__, scroll to the bottom, and select __CAPTURE BUG REPORT__.

![Bug report button in setings](images/bug-report.png)


This downloads a bug report in text format to your local machine. You can then share this file directly with our team via email (team@kubecost.com) or directly with our team on Slack in a private message. We not recommend distributing this report broadly because log data is included.

> __Note:__ capturing a full bug report requires [namespace logs access](https://github.com/kubecost/cost-analyzer-helm-chart/blob/df5e4ab053e3a8bd22534bceff9a468b82d33f0f/cost-analyzer/values.yaml#L367), which is granted by default in Kubecost.
