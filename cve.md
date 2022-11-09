# CVE Protocols

Kubecost will never ask for or access your confidential data, and likewise, security and privacy are important to us. Here is our proactive approach for ensuring common vulnerabilities and exposures (CVEs) are spotted and handled to ensure our product remains safe to use.

Due to Kubecost’s multiple base dependencies, it’s important to track vulnerabilities in our product as well as those dependencies. We use [Aqua’s Trivy](https://github.com/aquasecurity/trivy) to scan our containers as well as any [Helm chart](https://github.com/kubecost/integration-ci-cd/blob/main/.github/workflows/nightly-scan-dependencies.yaml) dependencies nightly to track potential CVEs. The specific action used can be viewed [here](https://github.com/aquasecurity/trivy-action). Potential vulnerabilities will always be fixed in our upcoming release.

IWe recommend users ensure their version of Kubecost is always up to date. Keep up with our monthly releases [here](https://github.com/kubecost/cost-analyzer-helm-chart/releases).
