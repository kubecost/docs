# Gluu Server with OIDC Configuration Guide

Gluu is an open-source Identity and Access Management (IAM) platform that can be used to authenticate and authorize users for applications and services. It can be configured to use the OpenID Connect (OIDC) protocol, which is an authentication layer built on top of OAuth 2.0 that allows applications to verify the identity of users and obtain basic profile information about them.

To configure a Gluu server with OIDC, you will need to install and set up the Gluu server software on a suitable host machine. This will typically involve performing the following steps:

1. Install the necessary dependencies and packages, such as:&#x20;
2. Download and extract the Gluu server software package.
3. Run the installation script to set up the Gluu server.
4. Configure the Gluu server by modifying the `/etc/gluu/conf/gluu.properties` file and setting the values for various properties, such as the hostname, LDAP bind password, and OAuth keys.
5. Start the Gluu server by running the `/etc/init.d/gluu-serverd start` command.

<figure><img src="https://lh3.googleusercontent.com/AK3iXMaG5oO4l1n7CFfrZwPFAF5KbwfFW9NH-OIbHFC7VLAp6hYLIpPM0Ufxrf2QmYhjZEk2tvqt-wGQwlqdMq6SLvkiyzPnMjLWJnjfkqAkewvOkBV51d9hYtkP_djNhFk4qtF_VBS22PlYYWaiLSDjHuzFITnwj0PXf3EiG3A9ZRIU52m2sJ9Ew7gv" alt=""><figcaption><p>Test Gluu Server - <a href="https://gts0001.kubecost-gluu-test.com/identity/home.htm">https://gts0001.kubecost-gluu-test.com/identity/home.htm</a></p></figcaption></figure>

You can read [Gluu's own documentation](https://gluu.org/docs/gluu-server/) for more detailed help with these steps.

> **Note**: Later versions of Gluu Server also support deployment to Kubernetes environments. You can read more about their Kubernetes support [here](https://gluu.org/docs/gluu-server/installation-guide/install-kubernetes/).

Once the Gluu server is up and running, you can connect it to a Kubecost cluster by performing the following steps:

6\. Obtain the OIDC client ID and client secret for the Gluu server. These can be found in the `/etc/gluu/conf/gluu.properties` file under the `oxAuthClientId` and `oxAuthClientPassword` properties, respectively.

<figure><img src="../.gitbook/assets/Screen Shot 2023-01-03 at 9.55.49 PM.png" alt=""><figcaption><p>Test gluu.properties file</p></figcaption></figure>

7\.  In the Kubecost cluster, create a new OIDC identity provider by running `kubectl apply -f oidc-provider.yaml` command, where _oidc-provider.yaml_ is a configuration file that specifies the OIDC client ID and client secret, as well as the issuer URL and authorization and token endpoints for the Gluu server.

<figure><img src="https://lh5.googleusercontent.com/SyH8YK5C6rHpWtD1cD2xOs6Guxs-GrKAo6krHoyZnuEMVUZP3aXdp2aVrIASvB2bGBkLsoq_ZgdRlY-yvlMvrQk-MzCF-tdAajQOxOch1Ujnq5endiUFcWdFYCSUTQ307QabFeRYw_GicOfkQRoSGHZbpqZDf3wrK5cx_q7V283tLG-FoA9e3pg_ny2Z" alt=""><figcaption><p>Test oidc-provider.yaml file</p></figcaption></figure>

In this file, you will need to replace the following placeholders with the appropriate values:

* `<OIDC_CLIENT_ID>`: The OIDC client ID for the Gluu server. This can be found in the `/etc/gluu/conf/gluu.properties` file under the `oxAuthClientId` property.
* `<OIDC_CLIENT_SECRET>`: The OIDC client secret for the Gluu server. This can be found in the `/etc/gluu/conf/gluu.properties` file under the `oxAuthClientPassword` property.
* `<GLUU_SERVER_HOSTNAME>`: The hostname of the Gluu server.
* `<BASE64_ENCODED_OIDC_CLIENT_ID>`: The OIDC client ID, encoded in base64.
* `<BASE64_ENCODED_OIDC_CLIENT_SECRET>`: The OIDC client secret, encoded in base64.               &#x20;

8\.  Set up a Kubernetes service account and bind it to the OIDC identity provider. This can be done by running the `kubectl apply -f service-account.yaml` command, where _service-account.yaml_ is a configuration file that specifies the name of the service account and the OIDC identity provider.

<figure><img src="https://lh5.googleusercontent.com/Mt0gnNAJ1fytSQUS3IgtIp6sYaJuJoR1geWSw5Dp7KiMwUNlbv7qtN82PNFLr_3720lCcqiymMpDbc0ZXkFlJEEvRcfvsF8rsXc33k19j6fHeuLX7SQnaLlKzQvBSO0ni1v-nMUN0vlDxaBq83AF2uj754Uz4ZaMt0gvRZvP0L7j2vsPQiS0e_YSoTbK" alt=""><figcaption><p>Test service-account.yaml file</p></figcaption></figure>

In this file, you will need to replace the following placeholders with the appropriate values:

* `<SERVICE_ACCOUNT_NAME>`: The name of the service account. This can be any name that you choose.
* `<GLUU_SERVER_HOSTNAME>`: The hostname of the Gluu server.
* `<OIDC_CLIENT_ID>`: The OIDC client ID for the Gluu server. This can be found in the _/etc/gluu/conf/gluu.properties_ file under the `oxAuthClientId` property.

> &#x20;**Note**: You should also ensure that the `kubernetes.io/oidc-issuer-url`, `kubernetes.io/oidc-client-id`, `kubernetes.io/oidc-username-claim`, and `kubernetes.io/oidc-groups-claim` annotations are set to the correct values for your Gluu server and configuration. These annotations specify the issuer URL and client ID for the OIDC identity provider, as well as the claims to use for the username and group membership of authenticated users.

Once these steps are completed, the Gluu server should be configured to use OIDC and connected to the Kubecost cluster, allowing users to authenticate and authorize themselves using their Gluu credentials.
