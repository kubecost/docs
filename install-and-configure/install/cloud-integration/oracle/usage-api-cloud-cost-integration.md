# Oracle Usage API Cloud Cost Integration

This document describes how to integrate Kubecost with the Oracle Usage API to build Cloud Costs for your tenancy. This will largely be done via the OCI CLI which you will need admin privileges on.

## Before Starting

Ensure that you have the oracle CLI installed and configured for your account. Documentation on this can be found [here](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm).

You will also need the tenancy ID and region of the tenancy in which your clusters are running. This can be found in the Oracle Cloud console by selecting "Tenancy: _TENANCY-NAME_" from the profile drop down in the top right corner. Under "Tenancy information" the tenancy ID is labeled "OCID" and the region is marked "Home region". The region name listed here will need to be changed to a region identify found [here](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm).

## Authentication and Authorization

Access to the Usage API is defined in a policy that applies to a group. Using credentials for a User that is a member of that group Kubecost can gain access to the API.

### Creating a User

Run the following command to create a user. You will need to provide an email address for this user which does not have to be unique among users. Be sure to save the values mentioned below.

```sh
oci iam user create \
--name kubecostUser \
--description="Access point for kubecost" \
--email <REQUIRED_EMAIL>
```

Save the user ID which can be found in the "id" property of the output.

Save the compartment ID found in the "compartment-id" property of the output.

### Creating a Group

Next create a group which will have the policy attached to it.

```sh
oci iam group create \
--name=kubecost \
--description="group for kubecost"
```

Save the group ID found in the "id" property of the output.

Add user to the new group.

```sh
oci iam group add-user \
--group-id $OCI_GROUP_ID \
--user-id $OCI_USER_ID
```

Create a policy for group.

```sh
oci iam policy create \
--compartment-id $OCI_COMPARTMENT_ID \
--name kubecostUserPolicy \
--description="policy for kubecost" \
--statements='["ALLOW GROUP kubecost to read all-resources IN TENANCY"]'
```

### Create and add an API key for the User

Start by generating a set of RSA PEM files.

> If following this guide, be sure to change the name of the PEM files you are creating. Failing to do so can cause the CLI to stop working. See Oracle documentation [here](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#apisigningkey_topic_How_to_Generate_an_API_Signing_Key_Mac_Linux) for more details.

Upload the public key to the user you created in the last step.

```sh
oci iam user api-key upload \
--user-id $OCI_USER_ID \
--key-file="/path/to/key_public.pem"
```

## Create Configuration

To create the configuration you will need the following values.

* "_TENANCY-ID_": The ID of the tenancy of the clusters that Kubernetes is running on
* "REGION": the region identifier of the tenancy
* "USER-ID": the ID for the user created above
* "FINGERPRINT": the finger print for the RSA key attached to the user, obtained when attaching the public key to the users
* "PRIVATE-KEY": the text value of the private .pem file. This string should contain "\n" character at the new lines

Create a JSON file name `cloud-integration.json` using the above values.

```json
{
  "oci": {
    "usageApi": [
      {
        "tenancyID": "<TENANCY-ID",
        "region": "<REGION>",
        "authorizer": {
          "authorizerType": "OCIRawConfigProvider",
          "tenancyID": "<TENANCY-ID>",
          "userID": "<USER-ID>",
          "region": "<REGION>",
          "fingerprint": "<FINGERPRINT>",
          "privateKey": "<PRIVATE-KEY>"
        }
      }
    ]
  }
}
```

Create a Kubernetes secret in the same namespace as your Kubecost deployment with this JSON file.

```sh
kubectl create secret generic cloud-integration \
-n kubecost \
--from-file=cloud-integration.json
```

Update the Helm values to mount the secret with the configuration.

```yaml
kubecostProductConfigs:
  cloudIntegrationSecret: cloud-integration
```
