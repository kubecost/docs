The notion of Availability Tiers impact both recommendations and health ratings in the Kubecost oroduct. For example, production jobs receive higher resource request recommendations than dev workload.   

Today our product supports the following tiers:


Tier | Priority | Default
--------- | ----------- | -------
`Highly Available` or `Critical` | 0 | If true, recommendations and health scores heavily prioritize availability. This is the default tier if none is supplied. 
`Production` | 1 | Intended for production jobs that are not necessarily mission critic
`Staging` or `Dev` | 2 | Meant for experimental or development resources. Here redundancy or available is not a priority. 

Have questions or feedback? Contact us at <team@kubecost.com>.
