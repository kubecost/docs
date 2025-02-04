# Teams

{% hint style="info" %}
RBAC is only officially supported on Kubecost Enterprise plans.
{% endhint %}

Teams enables Role-Based Access Control (RBAC) in Kubecost's UI, allowing you to define a granular set of permissions for your users. These permissions include enabling or disabling pages within Kubecost as well as scoping those pages down to even finer levels with filters.


## Prerequisites

Before using the Teams page, make sure you have configured [SAML](/install-and-configure/advanced-configuration/user-management-saml/README.md) or [OIDC](/install-and-configure/advanced-configuration/user-management-oidc/user-management-oidc.md) with a provider of your choice. Teams cannot work independent of one of these two IAM protocols.


In order to use teams, you must have the Kubecost PersistentVolume enabled in your Helm values. This is enabled by default and no action is needed unless you have previously disabled it. PersistentVolume is enabled via:


```yaml
persistentVolume:
  enabled: true
```

If this is your first time using Teams, consult the [Getting started](teams.md#getting-started) section below. For additional team creation, see the [Adding a team](teams.md#adding-a-team) section.

If you previously had teams enabled and are upgrading from a version of Kubecost prior to 2.6, see the [Upgrading](teams.md#upgrading-and-legacy-teams) section below.


## Getting started

To manage teams via the Kubecost UI, you must either have admin-level access to Kubecost and create teams through the UI, or configure via Helm. There are three available methods for getting started.

### Method 1: Enable Teams and login in

In order to enable teams, enable RBAC for your desired IAM protocol (SAML or OIDC) but do not define any values under the respective `groups[]` list. If groups are defined, this will default the installation to the earlier [simple RBAC](teams.md#rbac-teams-versus-simple-rbac) and not the newer teams RBAC. An example of how to enable the new teams RBAC in Helm when using OIDC is shown below.

```yaml
oidc:
  enabled: true
  rbac:
    enabled: true
```

The first person to log in will be added to a default team with admin-level access. They will then be able to configure teams through the UI on the Teams page.

### Method 2: Enable SAML/OIDC without Teams, create teams, then enable Teams

This method leaves additional authentication in place while RBAC is disabled.

```yaml
oidc:
  enabled: true
  rbac:
    enabled: false
```

Now, access the Teams page, and create your initial admin team. See the [Adding a team](teams.md#adding-a-team) section below for specific instructions for using the UI. Once your admin team has been created, reenable RBAC authentication:

```yaml
oidc:
  enabled: true
  rbac:
    enabled: true
```

The members of your team are now able to add new members, or create new teams.

### Method 3: Configure teams through Helm values

{% hint style="warning" %}
Configuring teams through Helm will disable configuration of teams through the UI.
{% endhint %}


Kubecost allows teams to be defined in Helm values obviating the need to create them in the UI. An example values snippet is shown below.

```yaml
 teams:
   # teamsConfigMapName: teams-configmap-name
   teamsConfig:
     - id: ''
       name: helm-team
       roles:
       - id: ''
         name: helm-role
         description: helm configured role
         pages:
           showOverview: true
           showAllocation: true
           showAsset: true
           showCloudCost: true
           showClusters: true
           showExternalCosts: true
           showNetwork: true
           showCollections: true
           showReports: true
           showInsights: true
           showActions: true
           showAlerts: true
           showBudgets: true
           showAnomalies: true
           showEfficiency: true
           showSettings: true
         permissions: admin
         routes: []
         allocationFilters:
         - key: cluster
           operator: ":"
           value: cluster-one
         assetFilters: []
         cloudCostFilters: [] 
       claims:
         NameID: email@domain.com
```

Configure at least one team under `teamsConfig` with an associated role under the team's `roles`.

Alternatively, a ConfigMap can be created manually, with `teamsConfigMapName` set to this ConfigMap's name.

```yaml
apiVersion: v1
data:
  rbac-teams-configs.json: '[json teams data]'
kind: ConfigMap
metadata:
  name: <your-configmap-name>
  namespace: <your-kc-namespace>

Note that setting a manually-configured ConfigMap name will override `teamsConfig`.

For more information about teams and roles, see the [Adding a team](teams.md#adding-a-team) section below.

## Claims

Claims are part of the Identity Provider (IdP) response that provide information about the authenticated user. For SAML, these are relayed as part of the SAML response. For OIDC, these are returned as part of the access or ID tokens.

Kubecost Teams uses these claims to map users to teams. As long as a group or attribute defined in your IdP is returned as part of the authorization process in the SAML response/OIDC token(s), it can be used in teams.

For example, in OIDC, an ID token may contain a certain number of claims.

```json
{
  "sub": "11111111",
  "name": "John Example",
  "email": "john.example@company.com",
  "iss": "https:/authserver.com",
  "groups": {
    "kubecost_admins",
  }
  "iat": 1735722061,
  "exp": 1735722062,
}
```

While some of these claims (e.g. `iss`, `iat`, `exp`) are set automatically by the IdP and are unsuitable for matching, others (e.g. `groups`, `name`, `email`) can be used to map a Kubecost team to the user.

## Adding a team

After initial configuration, more teams and roles can be added through the Teams page in the UI.

### Teams and roles

A team matches user claims from your configured IdP to a set of roles. Each role is essentially a set of permissions, such as over access level (admin/readonly/editor), page enablement states, filters, and so on.

Each team can have several roles, and each user may map to several teams. A team without a role has no permissions.

Therefore, to have permissions when using Teams, each prospective user must have at least one team with at least one role.

### Adding a role through the Kubecost UI

Each team requires one or more roles, which act as sets of user permissions. If you have already created a role or want to use an existing one, go on to the next step.

![Adding a Role](/images/rbac-teams-role-creation-example.png)

To add a role:

1. Click the `New Role` button on the roles page.
2. Add a role name. Note that this must be unique, and multiple roles cannot share the same name.
3. Add a description of the role.
4. Choose the role's access level. This can be `Admin`, `Read Only`, or `Editor`.
5. Define which pages can be viewed by users with the role. If any `Monitoring` pages are shown, you may additionally define a filter that will apply to the contents of this page.

### Adding a team through the Kubecost UI

![Adding a Team](/images/rbac-teams-team-creation-example.png)

To add a team:

1. Click the `New Team` button on the teams page.
2. Add a team name. Note that this must be unique, and multiple teams cannot share the same name.
3. Define user claims. For more information on what a claim is, see the [Claims](teams.md#claims) section above. __Note that any overlap between a user's claim data from the IdP and a team's claims will assign the user to the team, even if there are other claims specified in the Team.__
4. Add one or more roles.

On login, the user with the associated claims will be assigned the permissions of their team(s) role(s).

Note that, depending on the claims set, a user may have multiple teams. Also note that a team can have multiple roles. For more info, see the [Multiple teams](teams.md#multiple-teams) section below.

## Multiple teams

If a user has multiple roles (either through having multiple teams, a team with multiple roles, or both), they will be assigned an __additive__ union of the permissions defined by each role.

### Filters

Asset, Allocation, and Cloud Cost filters are ANDed together within a role, and then ORed together within both a set of roles in a team and a set of teams for a user.

For example, if a user is assigned both roles `Role 1` and `Role 2` with the following Allocation filters:

```
Role 1:
cluster IS cluster-1, cluster-2
namespace IS kubecost

Role 2:
cluster IS cluster-3
namespace IS dev

### Permissions level

Permissions level will respect only the highest level out of all roles for all teams assigned to a user. The order of precedence is `Admin` > `Editor` > `Read Only`.

### Pages

Disabled/enabled pages will enable any page marked as such in any one of a user's roles. Otherwise, the page is designated as disabled. Essentially, if any of the user's roles has a page enabled, that page will be enabled for the user. Only if none of the user's roles have a page enabled is it disabled.

## Upgrading and legacy teams

### Legacy Teams

Prior to Kubecost v2.6, Teams existed with more limited functionality. This is refered to as [legacy Teams](legacy-teams.md). 

Legacy teams provided:

- Functionality for SAML environments
- Allocation filtering
- Ability to assign a team a permissions level (under legacy teams previously refered to as a "Role") of `Admin`, `Read Only`, or `Editor`

Post-v2.6 Teams, in addition to all the functionality provided by legacy Teams, provides:

- Support for OIDC and SAML authentication
- Asset and Cloud Cost filters along with existing Allocation filters
- Individual page enable/disable functionality
- Ability to assign teams based on OIDC ID/Acccess token claims or claims returned in SAML response

### Upgrading with existing legacy teams

If upgrading to v2.6+ with existing teams, no config changes are required. Kubecost will attempt to automatically migrate existing legacy Teams teams on pod startup. 

For each existing legacy team, a role and associated team will be created. The Allocation filter and permissions level will be migrated into the new role, with the SAML email claim being added to the team.

## RBAC Teams versus simple RBAC

Kubecost allows configuration of a simple version of RBAC in the Helm chart (for example, see the config for [Entra ID](/install-and-configure/advanced-configuration/user-management-saml/microsoft-entra-id-saml-integration-for-kubecost.md#entra-id-rbac-configuration)). This is mutually exclusive with Teams.

If any configuration is specified under `saml.rbac.groups` or `oidc.rbac.groups`, this will enabled simple RBAC, ignoring any configured teams.

## Troubleshooting

The Kubecost aggregator container handles all operations relating to Teams. Viewing the logs may allow you to troubleshoot any issues.

If a state where invalid or incorrect teams are causing access issues in Kubecost, teams config can be deleted by running:

```sh
kubectl exec $POD -- sh -c 'rm -rf /var/configs/rbac_teams.json'

After this, on pod restart, Teams should recreate these stores as empty stores.
