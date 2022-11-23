# Capture a Bug Report

The Kubecost bug report feature captures relevant product configuration data and diagnostic logs for reviewing an active Kubecost deployment.

To capture a bug report: select _Settings_ in the left navigation, then scroll to the bottom and select _Capture bug report_.

![Bug report button in setings](https://raw.githubusercontent.com/kubecost/docs/main/images/bug-report.png)

This downloads a bug report in text format to your local machine. You can then share this file directly with our team via email (support@kubecost.com) or directly with our team on Slack in a private message.

> **Note:** Capturing a full bug report requires [namespace logs access](https://github.com/kubecost/cost-analyzer-helm-chart/blob/df5e4ab053e3a8bd22534bceff9a468b82d33f0f/cost-analyzer/values.yaml#L367), which is granted by default in Kubecost.

We do not recommend distributing this report broadly because log data is included.
