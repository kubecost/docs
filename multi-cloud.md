Setting Up Cloud Integrations
=============================

# Setting Up Cloud Integrations
This document outlines how to set up cloud integration for accounts on multiple cloud providers, or multiple accounts on the same cloud provider. Multi-Cloud is an enterprise feature. This configuration can be used independently of or in addition to other cloud integration configurations provided by Kubecost. Once configured Kubecost will display cloud assets for all configured accounts and perform reconciliation for all [federated clusters](https://github.com/kubecost/docs/blob/master/long-term-storage.md) that have their respective accounts configured.

## Step #1 Set up Cloud Cost and Usage Reporting

For each Cloud Account that you would like to configure you will need to make sure that it is exporting cost data to its respective service to allow Kubecost to gain access to it.

### Azure
Set up cost data export following this guide [guide](https://docs.microsoft.com/en-us/azure/cost-management-billing/costs/tutorial-export-acm-data?tabs=azure-portal)

### GCP
Set up BigQuery billing data exports with this [guide](https://cloud.google.com/billing/docs/how-to/export-data-bigquery)

### AWS

Follow steps #1-3 to set up and configure a CUR in our [guide](https://github.com/kubecost/docs/blob/master/aws-cloud-integrations.md)


## Step #2 Create Cloud Integration Secret

The secret should contain a file called cloud-integration.json with the following format

```
{
"azure": [],
"gcp": [],
"aws": []
}
```
This Configuration supports multiple configurations per cloud provider simply add any number of cloud configuration objects to their respective arrays in the JSON file. The structure and required values for the configuration objects for each cloud provider are described below. Once you have filled in the configuration object use the command
```
kubectl create secret generic <SECRET_NAME> --from-file=cloud-integration.json -n kubecost

```

Once the secret is created, set .Values.kubecostProductConfigs.cloudIntegrationSecret to <SECRET_NAME> and upgrade Kubecost via Helm

### Azure
The values needed to provide access to the Azure Storage Account where cost data is being exported can be found in the Azure portal in the Storage account where the cost data is being exported.
- <SUBSCRIPTION_ID> is the id of the subscription that the exported files are being generated for
- <STORAGE_ACCOUNT_NAME> is the name of the Storage account where the exported CSV is being stored.
- <STORE_ACCESS_KEY> can be found by selecting the “Access Keys” option from the navigation sidebar then selecting “Show Keys”. Using either of the two keys will work.
- <REPORT_CONTAINER_NAME> is the name that you choose for the exported cost report when you set it up. This is the name of the container where the CSV cost reports are saved in your Storage account.

Set these values into the following object and add them to the Azure array:
```
{
	"azureSubscriptionID": "<SUBSCRIPTION_ID>",
	"azureStorageAccount": "<STORAGE_ACCOUNT_NAME>",
	"azureStorageAccessKey": "<STORE_ACCESS_KEY>",
	"azureStorageContainer": <REPORT_CONTAINER_NAME>
}
```

### GCP

If you don't already have a GCP service key for any of the projects you would like to configure, you can run the following commands in your command line to generate and export one. Make sure your gcloud project is where your external costs are being run.
```

export PROJECT_ID=$(gcloud config get-value project)
gcloud iam service-accounts create compute-viewer-kubecost --display-name "Compute Read Only Account Created For Kubecost" --format json
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/compute.viewer
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.user
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.dataViewer
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.jobUser
gcloud iam service-accounts keys create ./compute-viewer-kubecost-key.json --iam-account compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com 
You can then get your service account key to paste into the UI (be careful with this!):

```
```
 cat compute-viewer-kubecost-key.json 

```

- <KEY_JSON> The GCP service key created above. This value should be left as JSON when inserted into the configuration object
- <PROJECT_ID> GCP Project ID should match the Project ID in the GCP service key.
- <BILLING_DATA_DATASET> BigQuery dataset requires a BigQuery dataset prefix (e.g. billing_data) in addition to the BigQuery table name. A full example is billing_data.gcp_billing_export_v1_018AIF_74KD1D_534A2.


Set these values into the following object and add it to the GCP array:
```
{
	"key": <KEY_JSON>
	"projectID": "<PROJECT_ID>",
	"billingDataDataset": "<BILLING_DATA_DATASET>",
}
```

### AWS
For each AWS Account that you would like to configure, create an Access Key for the Kubercost user who has access to the CUR. Navigate to https://console.aws.amazon.com/iam Access Management > Users. Find the Kubecost User and select Security Credentials > Create Access Key. Note the Access key ID and Secret access key.

Gather each of these values from the AWS console for each account you would like to configure.

- <ACCESS_KEY_ID> ID of the Access Key created in the previous step
- <ACCESS_KEY_SECRET> Secret of the Access Key created in the
- <ATHENA_BUCKET_NAME> An S3 bucket to store Athena query results that you’ve created that kubecost has permission to access
The name of the bucket should match s3://aws-athena-query-results-*, so the IAM roles defined above will automatically allow access to it
The bucket can have a Canned ACL of Private or other permissions as you see fit.
- <ATHENA_REGION> The AWS region Athena is running in
- <ATHENA_DATABASE> the name of the database created by the Athena setup. The Athena database name is available as the value (physical id) of AWSCURDatabase in the CloudFormation stack created above (in Step 2: Setting up the Athena of the AWS guild above)
- <ATHENA_TABLE> the name of the table created by the Athena setup
The table name is typically the database name with the leading athenacurcfn_ removed (but is not available as a CloudFormation stack resource)
- <ATHENA_PROJECT_ID> e.g. "530337586277" # The AWS AccountID where the Athena CUR is.

Set these values into the following object and add them to the AWS array:

```
{
	"serviceKeyName": "<ACCESS_KEY_ID>",
    "serviceKeySecret":"<ACCESS_KEY_SECRET>",
    "athenaBucketName": "<ATHENA_BUCKET_NAME>",
    "athenaRegion": "<ATHENA_REGION>",
    "athenaDatabase": "<ATHENA_DATABASE>",
    "athenaTable": "<ATHENA_TABLE>",
    "projectID": "<ATHENA_PROJECT_ID>"
}
```

Edit this doc on [Github](https://github.com/kubecost/docs/blob/main/multi-cloud.md)

<!--- {"article":"4407595968919","section":"4402815636375","permissiongroup":"1500001277122"} --->
