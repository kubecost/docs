Availability Tiers
==================

Availability Tiers impact capacity recommendations, health ratings and more in the Kubecost product. As an example, production jobs receive higher resource request recommendations than dev workloads. Another example is health scores for high availability workloads are heavily penalized for not having multiple replicas available.

Today our product supports the following tiers:


Tier | Priority | Default
--------- | ----------- | -------
`Highly Available` or `Critical` | 0 | If true, recommendations and health scores heavily prioritize availability. This is the default tier if none is supplied.
`Production` | 1 | Intended for production jobs that are not necessarily mission-critical.
`Staging` or `Dev` | 2 | Meant for experimental or development resources. Redundancy or availability is not a high priority.

To apply a namespace tier, add a `tier` namespace label to reflect the desired value.

Have questions or feedback? Contact us at <team@kubecost.com>.

Edit this doc on [Github](https://github.com/kubecost/docs/blob/main/availability-tiers.md)

<!--- {"article":"4407595926423","section":"4402815656599","permissiongroup":"1500001277122"} --->