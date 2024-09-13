# Oracle Usage API Cloud Cost Integration

This document describes how to integrate Kubecost with the Oracle Usage API to build Cloud Costs for your tenancy. This will largely be done via the OCI CLI which you will need admin privileges on.

### Before Starting

To begin with check ensure that you have the oracle cli installed and configured for your account, documentation on this can be found (here)[https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm#InstallingCLI__macos_homebrew]

You will also need the tenancy id and region of the tenancy that your clusters are running in. This can be found in the Oracle Cloud console by selecting "Tenancy: <TENANCY-NAME>" from the profile drop down in the top right corner. Under "Tenancy information" the tenancy id is labeled "OCID" and the region is marked "Home region". The region name listed here will need to be changed to a region identify found (here)[https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm] 

### Authentication and Authorization
Access to the Usage API is defined in a policy that applies to a group. Using credentials for a User that is a member of that group Kubecost can gain access to the API.


#### Creating a User

Run the following command to create a user, you will need to provide an email address for this users which does not have to be unique among users. Be sure to save the values mentioned below

```
oci iam user create \
--name kubecostUser \
--description="Access point for kubecost" \
--email <REQUIRED_EMAIL>
```

save the user id which can be found in the "id" property of the output

`export OCI_USER_ID="<USER-ID-VALUE>"`

save the compartment ID found in the "compartment-id" property of the output

`export OCI_COMPARTMENT_ID="<COMPARTMENT-ID-VALUE>"`

#### Creating a Group

Next create a group which will have the policy attached to it.
```
oci iam group create \
--name=kubecost \
--description="group for kubecost"
```

save the group ID found in the "id" property of the output

`export OCI_GROUP_ID="<GROUP-ID-VALUE>"`

Add user to new group

```
oci iam group add-user \
--group-id $OCI_GROUP_ID \
--user-id $OCI_USER_ID
```

create policy for group

```
oci iam policy create \
--compartment-id $OCI_COMPARTMENT_ID \
--name kubecostUserPolicy \
--description="policy for kubecost" \
--statements='["ALLOW GROUP kubecost to read all-resources IN TENANCY"]'
```


#### Create and add an API key for the User

start by generating a set of RSA Pem files
> If following this guide, be sure to change the name of the pem files you are creating. Failing to do can cause the CLI to stop working
https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#apisigningkey_topic_How_to_Generate_an_API_Signing_Key_Mac_Linux


Upload the public key to the user you created in the last step

```
oci iam user api-key upload \
--user-id $OCI_USER_ID 
--key-file="/path/to/key_public.pem"
```
From the result retain the "fingerprint" and "key-value" properties 

## Create Configuration 

To create the configuration you will need the following values.

* "<TENANCY-ID>": The id of the tenancy of the clusters that kubernetes is running on
* "REGION": the region identifier of the tenancy
* "USER-ID": the id for the user created above
* "FINGERPRINT": the finger print for the RSA key attached to the user, obtained when attaching the public key to the users
* "PRIVATE-KEY": the text value of the private .pem file. This string should contain "\n" character at the new lines

create a JSON file name "cloud-integration.json" using the above values

```
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
          "region": "<REGION>"
          "fingerprint": "<FINGERPRINT>",
          "privateKey": "<PRIVATE-KEY>"
        }
      }
    ]
  }
}

```

create a kubernetes secret in the same namespace as your Kubecost deployment with this JSON file.
```
kubectl create secret generic cloud-integration \
-n kubecost \
--from-file=cloud-integration.json
```

Update the helm values to mount the secret with the configuration
`.Values.kubecostProductConfigs.cloudIntegrationSecret=cloud-integration`

