Security and Data Protection
========

Ensuring your data's integrity, confidentiality, and availability has been part of Kubecost's mission from day one. We believe that users should own and fully control their data, especially when it comes to sensitive cost and product usage metrics.

## High-availability infrastructure 
Users interact with the application by deploying a Docker image to their infrastructure. When using hosted Kubecost, the system architecture is distributed across AWS availability zones which increases fault tolerance. Each system component is designed to be resilient and redundant.

## ISMS procedures
Kubecost is committed to investing in Information Security and to reducing the risk to the business and its customers. Executive leadership is involved in designing, reviewing, and approving all Information Security Management System (ISMS) policies. Effectiveness of these policies is measured via identified application security vulnerabilities, security incidents, and effectiveness of controls relative to process, operational, or business changes.

## Access control
All staff must use unique accounts for all access. The use of shared accounts is not permitted. Where enforceable, two-factor authentication is required. Staff access rights are granted according to the requirements of a specific role and responsibilities. Employees are only provided with access to the network and network services that they have been specifically authorized to use, and their accounts are created and granted access to resources based on their job roles.

Access to production systems must use transport encryption, and is only allowed via SSH key authentication. Password access is disabled. Two-factor authentication is required for AWS administrative access.

## User data protection 
Industry-leading data privacy and protection. 
* All customer data is encrypted at rest using the AES-256 cipher and we support TLS 1.2 for data in transit.
* Cryptographic keys or values are not stored in source code.
* Regularly scheduled data risk assessments aided by industry-leading tools.
* Multiple product configurations to meet your organization's data privacy needs, including hosted, installed, and air-gapped environments.
* Access to production systems is only allowed via SSH key authentication. Password access is disabled.
* Our self-hosted software products require opt-in consent to share product consumption usage data to our externally managed services (e.g. Mixpanel). If no consent is granted, Kubecost will not have access to your data.
* Our SaaS software products are powered by the collection and sharing of Kubernetes data. Product consumption usage is shared with our externally managed services (e.g. Mixpanel).

## Digital communication security
* External Internet-exposed interfaces use default-deny policies.
* Connections between the clients and the applications require secure transport encryption.
* All non-public systems and services use RFC 1918 reserved IP address space.
* Only services specifically required to be externally accessible are Internet exposed.
* Network ACLs secure the production environment by limiting network connections to those deemed necessary for the operation of the application.
* Security Groups are also used as an additional security measure to allow both Inbound/Outbound traffic between instances of the same category.

## Code security
Application code is version controlled using GitHub. All code changes are tracked with full revision history and  are attributable to a specific individual. Code must be reviewed and accepted by a different engineer than the author of the change.

### Application and system security
Each new server instance is updated with the latest security patches available before deployment. Logging and monitoring interfaces are enabled and logs are stored in a centralized location. The engineering team monitors for patches that address common vulnerabilities and exposures in production systems. This is done through nightly scans that monitor all containers. Patches are staged in the Staging environment and monitored to ensure stability and compatibility. After they pass monitoring requirements, the patches are rolled out to Production.

## Employee management
Data privacy and security policies are distributed and available to all employees, and all employees are required to review and abide by all ISMS policies. An internal audit is conducted at least annually to ensure accuracy and compliance with these policies.
* All employees are required to read the employee handbook.
* Employee accounts are provisioned based on job role and initiated by a manager's request.
* All employees are required to complete a background check.
* When someone leaves the company, their accounts are revoked within 1 business day, including access to Amazon Web Services, as well as all 3rd party services indicated in a separate spreadsheet.
* Employees access production and customer data via virtual machines, which are destroyed when the employee leaves the company.
* Employees knowingly violating security policies are subject to disciplinary action up to termination, with additional or alternative consequences in place for carelessness or malfeasance.

For more information on Kubecost privacy and security, please reach out to us at <support@kubecost.com>.
