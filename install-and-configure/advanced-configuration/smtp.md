# Custom SMTP Configuration

Kubecost Enterprise supports defining a custom SMTP server which, when defined, will be preferred by all Kubecost scheduled reports and alerts when sending email. Use of a custom SMTP server is especially beneficial in air gapped or hardened computing environments when the default, public SMTP server used by Kubecost cannot be contacted.

To create a custom SMTP server configuration, navigate to _Settings_ and then find the _SMTP Configuration_ section. Click the _Add Configuration_ button.

![SMTP configuration dialog](/images/smtp.png)

An SMTP configuration must define, minimally, a sender email, host, and port. Authentication via TLS is supported using username and password. Custom certificates are not currently supported but will be available in a future version. You can test the connection after providing inputs to ensure it is successful. Once successful, save the configuration. Kubecost will now direct all outbound emails over this new SMTP configuration.
