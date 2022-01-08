Kubecost components use following ports by default:

| Component                                         | Port  |
| ------------------------------------------------- | ----- |
| ingress http                                      | 80    |
| ingress https                                     | 443   |
| grafana                                           | 3000  |
| cost-analyzer                                     | 3001  |
| cost-analyzer-service - tcp-server                | 9001  |
| cost-analyzer-service - tcp-model                 | 9003  |
| cost-analyzer-service - api-server                | 9004  |
| prometheus service                                | 9090  |
| prometheus pushgateway service                    | 9091  |
| prometheus alertmanager-networkpolicy             | 9093  |
| prometheus node-exporter service                  | 9100  |
| prometheus server service                         | 10901 |
| prometheus alertmanager-service                   | 6783  |
| cost-analyzer-prometheus-postgres-adapter service | 9201  |
| kubecost-cluster-controller                       | 9731  |
| kube-state-metrics                                | 8080  |