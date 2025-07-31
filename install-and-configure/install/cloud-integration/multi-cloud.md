# Multi-Cloud Integrations

{% hint style="info" %}
Multi-cloud integrations are Kubecost Enterprise only features.
{% endhint %}

This document outlines how to set up cloud integration for accounts on multiple cloud service providers (CSPs), or multiple accounts on the same cloud provider. This configuration can be used independently of, or in addition, to other cloud integration configurations provided by Kubecost. Once configured, Kubecost will display cloud assets for all configured accounts and perform reconciliation for all [federated clusters](/install-and-configure/install/multi-cluster/federated-etl/federated-etl.md) that have their respective accounts configured.

## Step 1: Set up cloud cost and usage reporting

For each cloud account that you would like to configure, you will need to make sure that it is exporting cost data to its respective service to allow Kubecost to gain access to it.

* Azure: Set up cost data export following this [guide](/install-and-configure/install/cloud-integration/azure-out-of-cluster/azure-out-of-cluster.md).
* GCP: Set up BigQuery billing data exports with this [guide](https://cloud.google.com/billing/docs/how-to/export-data-bigquery).
* AWS: Follow steps 1-3 to set up and configure a Cost and Usage Report (CUR) in our [guide](/install-and-configure/install/cloud-integration/aws-cloud-integrations/aws-cloud-integrations.md).
* Alibaba: Create a user account with access to the [QueryInstanceBill API](https://www.alibabacloud.com/help/en/bss-openapi/latest/api-bssopenapi-2017-12-14-queryinstancebill).

## Step 2: Create cloud integration secret

The secret should contain a file named _cloud-integration.json_ with the following format (only containing applicable CSPs in your setup):

```json
{
  "azure": [],
  "gcp": [],
  "aws": [],
  "alibaba": []
}
```

This method of cloud integration supports multiple configurations per cloud provider simply by adding each cost export to their respective arrays in the .json file. The structure and required values for the configuration objects for each cloud provider are described below. Once you have filled in the configuration object, use the command:

{% code overflow="wrap" %}
```bash
kubectl create secret generic <SECRET_NAME> --from-file=cloud-integration.json -n kubecost
```
{% endcode %}

Once the secret is created, set `.Values.kubecostProductConfigs.cloudIntegrationSecret` to `<SECRET_NAME>` and upgrade Kubecost via Helm.

A GitHub repository with sample files required can be found [here](https://github.com/kubecost/poc-common-configurations/). Select the folder with the name of the cloud service you are configuring.

### Azure

The following values can be located in the Azure Portal under _Cost Management_ > _Exports_, or _Storage accounts_:

* `azureSubscriptionID` is the Subscription ID belonging to the Storage account which stores your exported Azure cost report data.
* `azureStorageAccount` is the name of the Storage account where the exported Azure cost report data is being stored.
* `azureStorageAccessKey` can be found by selecting _Access Keys_ from the navigation sidebar then selecting _Show keys_. Using either of the two keys will work.
* `azureStorageContainer` is the name that you chose for the exported cost report when you set it up. This is the name of the container where the CSV cost reports are saved in your Storage account.
* `azureContainerPath` is an optional value which should be used if there is more than one billing report that is exported to the configured container. The path provided should have only one billing export because Kubecost will retrieve the most recent billing report for a given month found within the path.
* `azureCloud` is an optional value which denotes the cloud where the storage account exists. Possible values are `public` and `gov`. The default is `public`.

Set these values into the following object and add them to the Azure array:

```json
{
    "azureSubscriptionID": "AZ_cloud_integration_subscriptionId",
    "azureStorageAccount": "AZ_cloud_integration_azureStorageAccount",
    "azureStorageAccessKey": "AZ_cloud_integration_azureStorageAccessKey",
    "azureStorageContainer": "AZ_cloud_integration_azureStorageContainer",
    "azureContainerPath": "",
    "azureCloud": "public/gov"
}
```

### GCP

If you don't already have a GCP service key for any of the projects you would like to configure, you can run the following commands in your command line to generate and export one. Make sure your GCP project is where your external costs are being run.

{% code overflow="wrap" %}
```bash
export PROJECT_ID=$(gcloud config get-value project)
gcloud iam service-accounts create compute-viewer-kubecost --display-name "Compute Read Only Account Created For Kubecost" --format json
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/compute.viewer
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.user
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.dataViewer
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.jobUser
gcloud iam service-accounts keys create ./compute-viewer-kubecost-key.json --iam-account compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com
```
{% endcode %}

You can then get your service account key to paste into the UI:

```bash
cat compute-viewer-kubecost-key.json
```

* `<KEY_JSON>` is the GCP service key created above. This value should be left as a JSON when inserted into the configuration object
* `<PROJECT_ID>` is the Project ID in the GCP service key.
* `<BILLING_DATA_DATASET>` requires a BigQuery dataset prefix (e.g. `billing_data`) in addition to the BigQuery table name. A full example is `billing_data.gcp_billing_export_v1_018AIF_74KD1D_534A2`.

Set these values into the following object and add it to the GCP array:

```json
{
    "key": {
        "type": "service_account",
        "project_id": "<GCP_PROJECT_ID>",
        "private_key_id": "<PRIVATE_KEY_ID>",
        "private_key": "<PRIVATE_KEY>",
        "client_email": "<CLIENT_EMAIL>",
        "client_id": "<CLIENT_ID>",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/<CERT_NAME>"
    },
    "projectID": "<GCP_PROJECT_ID>",
    "billingDataDataset": "<GCP_BILLING_BIGQUERY_EXPORT>"
}
```

Many of these values in this config can be generated using the following command:

```bash
gcloud iam service-accounts keys create ./compute-viewer-kubecost-key.json --iam-account compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com
```

### AWS

For each AWS account that you would like to configure, create an Access Key for the Kubecost user who has access to the CUR. Navigate to [IAM Management Console dashboard](https://console.aws.amazon.com/iam), and select _Access Management_ > _Users_. Find the Kubecost user and select _Security Credentials_ > _Create Access Key_. Note the Access Key ID and Secret access key.

Gather each of these values from the AWS console for each account you would like to configure.

* `<ACCESS_KEY_ID>` is the ID of the Access Key created in the previous step.
* `<ACCESS_KEY_SECRET>` is the secret of the Access Key created in the
* `<ATHENA_BUCKET_NAME>` is the S3 bucket storing Athena query results which Kubecost has permission to access. The name of the bucket should match `s3://aws-athena-query-results-*`, so the IAM roles defined above will automatically allow access to it. The bucket can have a canned ACL set to Private or other permissions as needed.
* `<ATHENA_REGION>` is the AWS region Athena is running in
* `<ATHENA_DATABASE>` is the name of the database created by the Athena setup. The Athena database name is available as the value (physical id) of `AWSCURDatabase` in the CloudFormation stack created above.
* `<ATHENA_TABLE>` is the name of the table created by the Athena setup The table name is typically the database name with the leading `athenacurcfn_` removed (but is not available as a CloudFormation stack resource).
* `<ATHENA_WORKGROUP>` is the workgroup assigned to be used with Athena. Default value is `Primary`.
* `<ATHENA_PROJECT_ID>`is the AWS AccountID where the Athena CUR is. For example: `530337586277`.
* `<MASTER_PAYER_ARN>` is an optional value which should be set if you are using a multi-account billing set-up and are not accessing Athena through the primary account. It should be set to the ARN of the role in the management (formerly master payer) account, for example: `arn:aws:iam::530337586275:role/KubecostRole`.

Set these values into the following object and add them to the AWS array in the _cloud-integration.json_:

```json
{
    "serviceKeyName": "<ACCESS_KEY_ID>",
    "serviceKeySecret":"<ACCESS_KEY_SECRET>",
    "athenaBucketName": "<ATHENA_BUCKET_NAME>",
    "athenaRegion": "<ATHENA_REGION>",
    "athenaDatabase": "<ATHENA_DATABASE>",
    "athenaTable": "<ATHENA_TABLE>",
    "athenaWorkgroup": "<ATHENA_WORKGROUP>",
    "projectID": "<ATHENA_PROJECT_ID>",
    "masterPayerARN": "<MASTER_PAYER_ARN>"
}
```

Additionally set the `kubecostProductConfigs.athenaProjectID` Helm value to the AWS account that Kubecost is being installed in.

### Alibaba

Kubecost does not support complete integrations with Alibaba, but you will still be able to view accurate list prices for cloud resources. Gather these following values from the Alibaba Cloud Console for your account:

* `clusterRegion` is the most used region
* `accountID` is your Alibaba account ID
* `serviceKeyName` is the RAM user key name
* `serviceKeySecret` is the RAM user secret

Set these values into the following object and add them to the Alibaba array in your _cloud-integration.json_:

```json
"alibaba" : [
    {
      "clusterRegion": "",
      "accountID": "",
      "serviceKeyName": "",
      "serviceKeySecret": ""
    }
  ]
```
