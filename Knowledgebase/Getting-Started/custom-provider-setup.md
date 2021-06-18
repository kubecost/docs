
Kubecost: Custom Provider Setup
===============================

### Note: this feature is available on Kubecost commercial plans and during free trials.

The following resource documents the steps required to set up custom prices with a CSV pipeline. This feature allows for individual assets (e.g. nodes) to be supplied unique prices. Common uses are for on-premise machines or for external enterprise discounts. 

Provide a file path for your CSV pricing data in [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/fcc4ce694751424bceee0d7730456b8b7295f129/cost-analyzer/values.yaml#L29-L35). This path can reference a local persistent volume or an S3 bucket. 

```
pricingCsv:  enabled: true  location:   provider: "AWS|GCP"   region: "us-east-1"    URI: < your-valid-file-URI >   csvAccessCredentials: pricing-schema-access-secret
```

 Supported file formats:

 1. S3 bucket access supported with this format -- s3://<bucket-name>/<key>

 Example: s3://kc-csv-test/pricing_schema.csv

2. Otherwise, CSV file will be read from the cost-analyzer PV

 Example path: */model/pricing.csv*

 Provide file access 

The required permissions are:


```
{   "Version": "2012-10-17",   "Statement": [     {       "Effect": "Allow",       "Action": [         "s3:Get*",         "s3:List*"       ],       "Resource": [         "arn:aws:s3:::<your-bucket-name>/*",         "arn:aws:s3:::<your-bucket-name>"       ]     }   ] }
```

There are two options for adding the credentials to the kubecost pod:

 

Service key: Create an s3 service key with the permissions above, then add its ID and access key as a kubernetes secret:

1. *echo -n "<access_key_id>" > AWS_ACCESS_KEY_ID*
2. *echo -n "access_key_secret" > AWS_SECRET_ACCESS_KEY*
3. *kubectl create secret generic pricing-schema-access-secret -n kubecost --from-file=AWS_ACCESS_KEY_ID --from-file=AWS_SECRET_ACCESS_KEY*
4. The name of this secret should be the same as csvAccessCredentials in values.yaml above

IAM annotation: Create and add an annotation as described below to the kubecost service [account](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values.yaml#L331) 

https://docs.aws.amazon.com/eks/latest/userguide/specify-service-account-role.html 


 Push CSV schema in this [format](https://docs.google.com/spreadsheets/d/1LziLt3LjDwhECjKh-jwBIkZDRNvt1jR8Rp2rEPoXEEs/edit#gid=0). CSV changes are picked up hourly by default. 

1. InstanceID -- identifier used to match asset
2. Region
3. AssetClass -- *node* and *pv* supported 
4. InstanceIDField -- field in *spec* or *metadata* that will contain the relevant InstanceID. For nodes, often spec.providerID , for pv’s often metadata.name
5. InstanceType     -- optional field to define the asset type, e.g. *m5.12xlarge*
6. MarketPriceHourly -- hourly price to charge this asset
7. Version -- field for schema version, currently unused


 Verification:

1. Connect to the kubecost prometheus:

2. *kubectl port-forward --namespace kubecost services/kubecost-prometheus-server 9003:80*

3. . Run the following query
    *node_total_hourly_cost*
5. You should see output similar to this:
 ```
  node_total_hourly_cost{instance="ip-172-20-41-147.us-east-2.compute.internal",instance_type="t2.medium",job="kubecost",node="ip-172-20-41-147.us-east-2.compute.internal",region="us-east-2"} | 0.04
 ```
6.. Verify that the price on the right is consistent with your CSV prices

	1. Get the providerID from node instance
	
	 `*kubectl get nodes ip-172-20-41-147.us-east-2.compute.internal -o=jsonpath="providerID:{.spec.providerID}"*`

*providerID:aws:///us-east-2a/i-071001c20d001bb6b*

7. Check in the csv that the resource_id matches the cost

 

 

 

**Pricing Discounts**

 

Negotiated discounts are applied after cost metrics are written to Prometheus. This implies that discounts apply to all node pricing data, including pricing data read directly from the custom provider CSV pipeline. Additionally, this implies that all discounts can be updated at any time and changes are applied retroactively. 

 

 

**Pricing Inference**

 

The following logic is used to match node prices accurately: 

 

- First, search for an exact match in CSV pipeline
- If exact match not available, search for an existing CSV data point that matches region, instanceType, and AssetClass
- If neither available, fallback to pricing estimates

 

You can check a summary of the number of nodes that have matched with the CSV by visiting */model/pricingSourceCounts* . The response is a json object of the form:

 

 

 

data: {  TotalNodes: 10  PricingType: {    csvExact: 5 // exact matches by the providerID field   csvClass: 4 // matches where the region and instanceType match   “”: 1 // matches that use our default pricing } }

 