User Management - SSO/SAML/RBAC*
================================

__*Note that SSO and RBAC capabilities are only included with a Kubecost Enterprise Subscription.__

Kubecost supports access control/Single Sign On (SSO) with SAML 2.0. Kubecost works with most identity providers including Okta, Auth0, AzureAD, PingID, and KeyCloak.

High-level access control options:

* **User authentication** SSO provides a simple mechanism to restrict application access internally and externally
* **Custom access roles** Limit users based on attributes or group membership to view a set of namespaces, labels, cluster, or other aggregations
* **Pre-defined user roles**
    * admin: full control with permissions to manage users, configure model inputs, and application settings.
    * readonly: user role with read-only permission
    * editor: role can change and build alerts and reports, but cannot edit application settings and otherwise functions as read-only.

<br/>

Setup guide: [https://github.com/kubecost/poc-common-configurations/tree/main/saml-okta](https://github.com/kubecost/poc-common-configurations/tree/main/saml-okta)

Additional [troubleshooting guide](https://docs.google.com/document/d/1cgns9_jHQy5GFB2Yzd3Qlyd-owlbLqVi9Ti6IuCYCJE)

Contact us via email (<support@kubecost.com>) or join us on [Slack](https://join.slack.com/t/kubecost/shared_invite/enQtNTA2MjQ1NDUyODE5LWFjYzIzNWE4MDkzMmUyZGU4NjkwMzMyMjIyM2E0NGNmYjExZjBiNjk1YzY5ZDI0ZTNhZDg4NjlkMGRkYzFlZTU) if you have questions!

Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/user-management.md)

<!--- {"article":"4407595985047","section":"4402815636375","permissiongroup":"1500001277122"} --->