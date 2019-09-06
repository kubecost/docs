The notion of Availability Tiers impact both recommendations and ratings in the Kubecost Product. Today our product supports the following:


Tier | Priority | Default
--------- | ----------- | -------
`Highly Available` or `Critical` | 0 | If true, recommendations and health scores heavily prioritize availability. This is the default tier if none is supplied. 
`Production` | 1 | Intended for production jobs that are not necessarily mission critic
`Staging` or `Dev` | 2 | Meant for experimental or development resources. Here redundancy or available is not a priority. 
