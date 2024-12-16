Ports
=====

Kubecost components use following ports by default:

| Component                                         | Port  |
| ------------------------------------------------- | ----- |
| ingress http                                      | 80    |
| ingress https                                     | 443   |
| grafana                                           | 3000  |
| cost-analyzer                                     | 3001  |
| cost-analyzer-service - tcp-model                 | 9003  |
| cost-analyzer-service - api-server                | 9004  |
| prometheus service                                | 9090  |
| prometheus alertmanager-networkpolicy             | 9093  |
| kubecost-cluster-controller                       | 9731  |
| kube-state-metrics                                | 8080  |
