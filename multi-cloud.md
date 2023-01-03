# Setting Up Cloud Integrations

This document outlines how to set up cloud integration for accounts on multiple cloud providers, or multiple accounts on the same cloud provider. Multi-Cloud is an enterprise feature. This configuration can be used independently of or in addition to other cloud integration configurations provided by Kubecost. Once configured, Kubecost will display cloud assets for all configured accounts and perform reconciliation for all [federated clusters](https://github.com/kubecost/docs/blob/main/long-term-storage.md) that have their respective accounts configured.

## Step 1: Set up cloud cost and usage reporting

For each Cloud Account that you would like to configure you will need to make sure that it is exporting cost data to its respective service to allow Kubecost to gain access to it.

### Azure

Set up cost data export following this [guide](https://github.com/kubecost/docs/blob/main/azure-out-of-cluster.md)

### GCP

Set up BigQuery billing data exports with this [guide](https://cloud.google.com/billing/docs/how-to/export-data-bigquery)

### AWS

Follow steps 1-3 to set up and configure a Cost and Usage Report (CUR) in our [guide](https://github.com/kubecost/docs/blob/main/aws-cloud-integrations.md)

## Step 2: Create cloud integration secret

The secret should contain a file named `cloud-integration.json` with the following format:

```json
{
  "azure": [],
  "gcp": [],
  "aws": []
}
```

This method of Cloud-Integration supports multiple configurations per cloud provider simply by adding each cost export to their respective arrays in the .json file. The structure and required values for the configuration objects for each cloud provider are described below. Once you have filled in the configuration object use the command:

```bash
kubectl create secret generic <SECRET_NAME> --from-file=cloud-integration.json -n kubecost
```

Once the secret is created, set `.Values.kubecostProductConfigs.cloudIntegrationSecret` to <SECRET_NAME> and upgrade Kubecost via Helm.

A GitHub repository with sample files required can be found here, just select the cloud provider you are configuring: [https://github.com/kubecost/poc-common-configurations/](https://github.com/kubecost/poc-common-configurations/)

### Azure

The following values can be located in the Azure Portal under "Cost Management -> Exports" or "Storage accounts":

- `azureSubscriptionID` is the "Subscription ID" belonging to the Storage account which stores your exported Azure cost report -ata.
- `azureStorageAccount` is the name of the Storage account where the exported Azure cost report data is being stored.
- `azureStorageAccessKey` can be found by selecting the "Access Keys" option from the navigation sidebar then selecting "Show -eys". Using either of the two keys will work.
- `azureStorageContainer` is the name that you chose for the exported cost report when you set it up. This is the name of the -ontainer where the CSV cost reports are saved in your Storage account.
- `azureContainerPath` is an optional value which should be used if there is more than one billing report that is exported to the -onfigured container. The path provided should have only one billing export because kubecost will retrieve the most recent -illing report for a given month found within the path.
- `azureCloud` is an optional value which denotes the cloud where the storage account exist, possible values are `public` and `gov`. The default is `public`.

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

If you don't already have a GCP service key for any of the projects you would like to configure, you can run the following commands in your command line to generate and export one. Make sure your gcloud project is where your external costs are being run.

```bash
export PROJECT_ID=$(gcloud config get-value project)
gcloud iam service-accounts create compute-viewer-kubecost --display-name "Compute Read Only Account Created For Kubecost" --format json
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/compute.viewer
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.user
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.dataViewer
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.jobUser
gcloud iam service-accounts keys create ./compute-viewer-kubecost-key.json --iam-account compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com
```

You can then get your service account key to paste into the UI (be careful with this!):

```bash
cat compute-viewer-kubecost-key.json
```

- `<KEY_JSON>` The GCP service key created above. This value should be left as JSON when inserted into the configuration object
- `<PROJECT_ID>` GCP Project ID should match the Project ID in the GCP service key.
- `<BILLING_DATA_DATASET>` BigQuery dataset requires a BigQuery dataset prefix (e.g. billing\_data) in addition to the BigQuery table name. A full example is billing\_data.gcp\_billing\_export\_v1\_018AIF\_74KD1D\_534A2.

Set these values into the following object and add it to the GCP array:

```json
{
    "key": "<KEY_JSON>",
    "projectID": "<PROJECT_ID>",
    "billingDataDataset": "<BILLING_DATA_DATASET>"
}
```

### AWS

For each AWS account that you would like to configure, create an Access Key for the Kubecost user who has access to the CUR. Navigate to https://console.aws.amazon.com/iam _Access Management_ > _Users_. Find the Kubecost user and select _Security Credentials_ > _Create Access Key_. Note the Access key ID and Secret access key.

Gather each of these values from the AWS console for each account you would like to configure.

- `<ACCESS_KEY_ID>` ID of the Access Key created in the previous step
- `<ACCESS_KEY_SECRET>` Secret of the Access Key created in the
- `<ATHENA_BUCKET_NAME>` An S3 bucket to store Athena query results that you’ve created that kubecost has permission to access
The name of the bucket should match `s3://aws-athena-query-results-*`, so the IAM roles defined above will automatically allow access to it
The bucket can have a Canned ACL of Private or other permissions as you see fit.
- `<ATHENA_REGION>` The AWS region Athena is running in
- `<ATHENA_DATABASE>` the name of the database created by the Athena setup. The Athena database name is available as the value (physical id) of AWSCURDatabase in the CloudFormation stack created above (in Step 2: Setting up the Athena of the AWS guild above)
- `<ATHENA_TABLE>` the name of the table created by the Athena setup
The table name is typically the database name with the leading athenacurcfn_ removed (but is not available as a CloudFormation stack resource)
- `<ATHENA_WORKGROUP>` The workgroup assigned to be used with Athena. If omitted, defaults to `Primary`.
- `<ATHENA_PROJECT_ID>` e.g. "530337586277" # The AWS AccountID where the Athena CUR is.
- `<MASTER_PAYER_ARN>` Is an optional value which should be set if you are using a multi-account billing set-up and are not accessing athena through the primary account. It should be set to the arn of the role in the masterpayer account, e.g. `arn:aws:iam::530337586275:role/KubecostRole`.

Set these values into the following object and add them to the AWS array in the *cloud-integration.json*:

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

Additionally set the `kubecostProductConfigs.projectID` helm value to the AWS account that Kubecost is being installed in.
