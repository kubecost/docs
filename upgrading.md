# Enterprise Upgrading / Compatibility Matrix

## Overview

Kubecost is flexible with version differences between Primary and Agent clusters.

The majority of the changes in version upgrades are in the Kubecost Primary instance with new UI functionality and backend performance improvements.

With upgrades, Kubecost also updates images to patch security concerns. No service is exposed on Agent Clusters, mitigating most risks. Though organizational security standards should be followed.

The below table represents best-practice. Much older agents will still provide the required metrics or most common use cases.

## Multi-Cluster Version Compatibility


| Release Date | Kubecost Primary Version | Agent Version | Kubernetes Version |
|--------------|:------------------------:|:-------------:|:------------------:|
| 04-May-2023  | 1.103                    | 1.103 (3)     | 1.17+              |
| 04-APR-2023  | 1.102                    | 1.102 (2)     | 1.17+              |
| 10-MAR-2023  | 1.101                    | 1.100         | 1.17+              |
| 07-FEB-2023  | 1.100                    | 1.100 (1)     | 1.17+              |

## Kubernetes API Version Upgrades

Before upgrading to kubernetes 1.25, podSecurityPolicies must be disabled.
Detail here: <https://github.com/kubecost/poc-common-configurations/blob/main/psp-disable/disable-psps.yaml>

## Agent Notes

Kubecost recommends all Agents (secondary) clusters run at least version [1.102](https://github.com/kubecost/cost-analyzer-helm-chart/releases/tag/v1.102.0) due to improvements made for usage calculations to fix cost calculation in certain environments. In 1.102, recording rules were also added to improve performance and accuracy when calculating CPU request-sizing recommendations.

1. Added support for node labels
2. Fixed calculation for non-bundled prometheus CPU+Memory.
3. Fixed calculation of Azure virtual nodes