Windows Node Support

Windows nodes are partially supported by kubecost as of v1.93.0. Additional support is coming soon!
* When tracked by the kubernetes API, nodes should show up with the correct number of pods and resources.
* By default, we will be missing utilization data for pods on window nodes; pods will be billed based on request size.
* Kubecost can be configured to pick up utilization data for windows nodes; cadvisor must run on these nodes and be scraped.
