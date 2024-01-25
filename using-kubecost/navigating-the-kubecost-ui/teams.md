# Teams

Teams is a page which allows for RBAC configuration using Kubecost's UI. 

## Prerequisites

Before using the Teams page, make sure you have configured [SAML RBAC](/install-and-configure/advanced-configuration/user-management-saml/README.md) with a provider of your choice. Kubecost provides tutorials for configuring SAML RBAC with [Okta](/install-and-configure/advanced-configuration/user-management-saml/okta-saml-integration.md) and [Microsoft Entra](/install-and-configure/advanced-configuration/user-management-saml/microsoft-entra-id-saml-integration-for-kubecost.md).

{% hint style="warning" %}
Teams is currently *not* compatible with [OIDC RBAC](/install-and-configure/advanced-configuration/user-management-oidc/user-management-oidc.md).
{% endhint %}

Users must also have the PVs Helm flag enabled. This will be enabled in Kubecost by default, and so no action is needed unless you have previously disabled it. To renable PVs, use the following command:

```
helm upgrade -i kubecost kubecost/cost-analyzer \
    --set persistentVolume.enabled = true
```

If this is your first time using Teams, consult the [Getting started](teams.md#getting-started) section below. For additional team creation, see the [Adding a team](teams.md#adding-a-team) section.

## Getting started

To manage teams via the Kubecost UI, you must take special measures while creating an initial admin team. Additional teams can then be created by users in this group. There are three methods available for getting started:

### Method 1: Disabling SAML

You will need to disable your existing SAML configuration temporarily through this tutorial. You will need to turn off SAML authentication Helm flag before creating your team, then turning it back on.

```
helm upgrade -i kubecost kubecost/cost-analyzer \
    --set saml.enabled = false
```

Now, access the Teams page, and create your initial admin team. See the [Adding a team](teams.md#adding-a-team) section below for specific instructions for using the UI. Once your admin team has been created, reenable SAML authentication:

```
helm upgrade -i kubecost kubecost/cost-analyzer \
    --set saml.enabled = true
```

The members of your team are now able to add new members, or create new teams.

### Method 2: Disable SAML RBAC while leaving SAML enabled

This method leaves additional authentication in place while SAML RBAC is disabled. 

```
helm upgrade -i kubecost kubecost/cost-analyzer \
    --set saml.rbac.enabled = false
```

Now, access the Teams page, and create your initial admin team. See the [Adding a team](teams.md#adding-a-team) section below for specific instructions for using the UI. Once your admin team has been created, reenable SAML RBAC authentication:

```
helm upgrade -i kubecost kubecost/cost-analyzer \
    --set saml.rbac.enabled = true
```

The members of your team are now able to add new members, or create new teams.

### Method 3: Implement SAML RBAC through *values.yaml*

In the *values.yaml* where your SAML RBAC is configured, modify your values to include your admin group, where `assertionValues` matches the group configured with your SAML provider. Do not modify the `assertionName` value.
```
rbac:
    enabled: true
    groups:
      - name: admin
        enabled: true
        assertionName: "kubecost_group"
        assertionValues:
          - "kubecost_admin"
```

Now access the Teams page and reconfigure your admin team by selecting it from the table. See below for editing teams. Then, delete the admin group from your *values.yaml* and delete/detach the group from your SAML provider. The members of your team are now able to add new members, or create new teams.

## Adding a team

To create a team, select *Add Team*. The 'New Team' slide panel opens. Provide a name for your team, then choose the role (supports *Admin*, *Editor*, and *Read Only*). If this is your first team, select *Admin*.

Teams support an optional Allocations Filter which can be used to limit team functionality to specific Kubernetes objects, as well as custom labels. These filters use advanced filtering language for additional customization.

In the 'Add Member' text box, add users one at a time by providing the corresponding username/email provided to your SAML RBAC provider, or member configuration will fail. Save each member by selecting *Add*. Add as many members as needed, then finalize your changes by selecting *Save Team*.

Teams will require a name, role, and at least one member to be created successfully.

Admins can edit existing teams by selecting them from the Teams page. Teams can then also be deleted by selecting *Delete Team*.

## Notes about user roles

User roles can always be optionally configured using the UI or by adjusting the Helm flags in your *values.yaml*. There is no reequirement to choose one or the other.

Kubecost RBAC follows the principle of most privilege. If a user is added to multiple teams with different roles, they will assume the role with the highest authority unless Allocation Filters are used to limit role functions.

Authentication is handled by the cost-model and Aggregator pods.

## Debugging

For help with troubleshooting, follow this guide for diagnostic assistance:

1. Opne your browser's developer tools.
2. Access Cookies (Select *Storage* in Firefox, or *Application* in Google Chrome).
3. Look for the `token` cookie.
4. Copy and paste the token value into jwt.io.
5. The last group is the username.
6. Omit `group:` to find the username Kubecost requires for teams.