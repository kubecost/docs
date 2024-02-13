# Kubecost Cloud AWS Integration

{% hint style="info" %}
This documentation should only be consulted when using Kubecost Cloud. For information about the configuring an AWS integration with self-hosted Kubecost, see [here](/install-and-configure/install/cloud-integration/aws-cloud-integrations/aws-cloud-integrations.md).
{% endhint %}

Kubecost Cloud provides the ability to allocate out of cluster (OOC) costs back to Kubernetes concepts like namespaces and deployments. The following guide provides the steps required for allocating OOC costs in AWS.

## Prerequisites

Before beginning your integration, you need to create a Cost and Usage Report (CUR) through AWS. Consult AWS' documentation [Creating Cost and Usage Reports](https://docs.aws.amazon.com/cur/latest/userguide/cur-create.html) for step-by-step instructions if needed during this process. When creating your CUR, make sure to configure these settings:

* Time granularity is set to _Daily_
* Resource IDs and Athena are enabled

Remember the name of the S3 bucket that is created for this CUR. AWS may require up to 24 hours to publish data. Wait until you have received data before proceeding with this integration.

## Adding an integration

In the Kubecost Cloud UI, begin by selecting _Settings_ in the left navigation. Scroll down to Cloud Integrations, then select _View Additional Details_. The Cloud Integrations dashboard opens. Select _+ Add Integration_. Then, select _AWS Integration_ from the slide panel.

### Step 1: Setting up a CUR

If your CUR has been properly set up and is now providing data after following the on-screen instructions in the Kubecost UI, select _Continue_.

### Step 2: Setting up Athena

It's important to set up an Athena integration so Kubecost can perform reconciliation for providing accurate billing data. The on-screen instructions of the Kubecost Cloud UI are repeated here:

As part of the CUR creation process, Amazon also creates a CloudFormation template that is used to create the Athena integration. It is created in the CUR S3 bucket under `s3-path-prefix/cur-name` and typically has the filename _crawler-cfn.yml_. This .yml is your necessary CloudFormation template. You will need it in order to complete the CUR Athena integration. You can read more about this [here.](https://docs.aws.amazon.com/cur/latest/userguide/use-athena-cf.html)

{% hint style="info" %}
Your S3 path prefix can be found by going to your AWS Cost and Usage Reports dashboard and selecting your bucket's report. In the Report details tab, you will find the S3 path prefix.
{% endhint %}

Once Athena is set up with the CUR, you will need to create a new S3 bucket for Athena query results:

* Navigate to the [S3 Management Console.](https://console.aws.amazon.com/s3/home?region=us-east-2)
* Select _Create bucket._ The Create Bucket page opens.
* Use the same region used for the CUR bucket and pick a name that follows the format `aws-athena-query-results-*`.
* Select _Create bucket_ at the bottom of the page.
* Navigate to the [Amazon Athena Dashboard.](https://console.aws.amazon.com/athena)
* Select _Settings_, then select _Manage_. The 'Manage settings' window opens.
* Set Location of query result to the S3 bucket you just created, then select _Save_.

When you have completed all the above steps, select _Continue_ in the Kubecost Cloud UI.

### Step 3: Setting up IAM permissions

Before continuing with the integration in the Kubecost Cloud UI, you need to set up IAM permissions in AWS.

Begin by downloading [this .yaml template](https://raw.githubusercontent.com/kubecost/cloudformation/master/kubecost-sub-account-permissions.yaml).

Then, navigate to the [AWS Console Cloud Formation page](https://console.aws.amazon.com/cloudformation).

* Select _Create Stack_, then select _With existing resources (import resources)_ from the dropdown. On the 'Identify resources' page, select _Next._
* Under Template source, choose _Upload a template file_.
* Select _Choose file_, which will open your file explorer. Select the .yaml template, and then select _Open_. Then, select _Next_.
* On the 'Identify resources' page, provide any additional resources to import. Then, select _Next_.
* For _Stack name_, enter a name for your template.
* Set the following parameters:
  * MasterPayerAccountID: The account ID of the management account (formerly called master payer account) where the CUR has been created
  * SpotDataFeedBucketName: Optional. The bucket where the Spot data feed is sent to
* Review all provided information, then select _Import Resources_.
* At the bottom of the page, select _I acknowledge that AWS CloudFormation might create IAM resources._
* Select _Create Stack._

### Step 4: Provide CUR config values to Kubecost

You will be prompted to provide values for several different fields to finalize your integration. See this table for working definitions of each field:

<table><thead><tr><th width="218">Field</th><th>Description</th></tr></thead><tbody><tr><td>AWS Account ID</td><td>The AWS account ID where the Athena CUR is, likely your management account.</td></tr><tr><td>Master Payer ARN</td><td>Also known as the management account ARN. Configured in Step 3. The account ID of the management account where the CUR has been created.</td></tr><tr><td>Region</td><td>The AWS region Athena is running in</td></tr><tr><td>Bucket</td><td>An S3 bucket to store Athena query results that you’ve created that Kubecost has permission to access. The name of the bucket should match <tt>s3://aws-athena-query-results-*</tt></td></tr><tr><td>Database</td><td>The name of the database created by the Athena setup</td></tr><tr><td>Table</td><td>The name of the table created by the Athena setup</td></tr><tr><td>Workgroup</td><td>Optional. Primary workgroup associated with the AWS account where your Athena CUR is.</td></tr><tr><td>Access Key Id</td><td>In the AWS IAM Console, select <em>Asset Management</em> > <em>Users</em>. Find your user and select <em>Security credentials > Create access key.</em></td></tr><tr><td>Secret Access Key</td><td>Use the Access Key associated with the Access Key ID above.</td></tr></tbody></table>

When you have provided all mandatory fields, select _Create Integration_ to finalize. Be patient while your integration is set up. The Status should initially display as Unknown. This is normal. You should eventually see the integration's Status change from Pending to Successful.
