# CSV Pricing

> **Note**: This feature is only officially supported on Kubecost Enterprise plans and during free trials.

The following resource documents the steps required to set up custom prices with a CSV pipeline. This feature allows for individual assets (e.g. nodes) to be supplied at unique prices. Common uses are for on-premise machines or for external enterprise discounts. 

1. Provide a file path for your CSV pricing data in values.yaml. This path can reference a local PV or an S3 bucket. 

    ```
    pricingCsv:
    enabled: true
    location:
    provider: "AWS|GCP"
    region: "us-east-1" 
    URI: < your-valid-file-URI >
    csvAccessCredentials: pricing-schema-access-secret
    ```
    
    S3 bucket access is supported with the format `s3://<bucket-name>/<key>`, for example 's3://kc-csv-test/pricing_schema.csv
`. Otherwise, the CSV file will be read from the cost-analyzer PV, for example:

    ```
    pricingCsv:
    enabled: true
    location:
    URI: /var/kubecost-csv/custom-pricing.csv
    location: local
    extraVolumes:
    - name: kubecost-csv
    configMap:
    name: csv-pricing
    extraVolumeMounts:
    - name: kubecost-csv
    mountPath: /var/kubecost-csv
    ```
    
2. For S3 locations, provide file access. The required permissions are:

    ```
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
           "Resource": [
                "arn:aws:s3:::<your-bucket-name>/*",
                "arn:aws:s3:::<your-bucket-name>"
            ]
        }
      ]
    }
    ```
   
   There are two options for adding the credentials to the Kubecost pod:
    1. Service key: Create an S3 service key with the permissions above, then add its ID and access key as a K8s secret:
        1. `kubectl create secret generic pricing-schema-access-secret -n kubecost --from-literal=AWS_ACCESS_KEY_ID=id --from-literal=AWS_SECRET_ACCESS_KEY=key`
        2. The name of this secret should be the same as csvAccessCredentials in values.yaml above
    2. [AWS IAM (IRSA) service account annotation](https://docs.aws.amazon.com/eks/latest/userguide/adot-iam.html)

3. Create a CSV in this [format](https://github.com/kubecost/cost-analyzer-helm-chart/blob/gpu-pricing-1.99-rc.1/custom-pricing.csv) (also in the below table). CSV changes are picked up hourly by default. 
    1. EndTimeStamp: currently unused
    2. InstanceID: identifier used to match asset
    3. Region filter match based on topology.kubernetes.io/region 
    4. AssetClass: node pv, gpu are supported 
    5. InstanceIDField: field in spec or metadata that will contain the relevant InstanceID. For nodes, often spec.providerID , for pv’s often metadata.name
    6. InstanceType: optional field to define the asset type, e.g. m5.12xlarge
    7. MarketPriceHourly: hourly price to charge this asset
    8. Version: field for schema version, currently unused

    If the node label topology.kubernetes.io/region is present, it must also be in the CSV Region column.

![Pricing table](https://raw.githubusercontent.com/kubecost/docs/main/images/pricing.png)

## GPU pricing:
1. The node the GPU is attached to must be matched by a CSV node price. Typically this will be matched on instance type (node.kubernetes.io/instance-type)
2. Supported GPU labels are currently:
    * gpu.nvidia.com/class
    * nvidia.com/gpu_type
3. Verification:
    1. Connect to the Kubecost Prometheus: `kubectl port-forward --namespace kubecost services/kubecost-prometheus-server 9003:80`
    2. Run the following query: `node_total_hourly_cost`
        1. You should see output similar to this: `node_total_hourly_cost{instance="ip-172-20-41-147.us-east-compute.internal",instance_type="t2.medium",job="kubecost",node="ip-172-20-41-147.us-east-2.compute.internal",region="us-east-2"} | 0.04`
    3. Verify that the price on the right is consistent with your CSV prices
        1. Get the providerID from node instance: `kubectl get nodes ip-172-20-41-147.us-east-2.compute.internal -o=jsonpath=" providerID:{.spec.providerID}"providerID:aws:///us-east-2a/i-071001c20d001bb6b
        2. Check in the csv that the resource_id matches the cost

## Pricing discounts

Negotiated discounts are applied after cost metrics are written to Prometheus. Discounts will apply to all node pricing data, including pricing data read directly from the custom provider CSV pipeline. Additionally, all discounts can be updated at any time and changes are applied retroactively.

## Pricing inference

The following logic is used to match node prices accurately: 

* First, search for an exact match in CSV pipeline
* If exact match not available, search for an existing CSV data point that matches region, instanceType, and AssetClass
* If neither available, fallback to pricing estimates

You can check a summary of the number of nodes that have matched with the CSV by visiting /model/pricingSourceCounts. The response is a JSON object of the form:

```
data: {
	TotalNodes: 10
	PricingType: { 
		csvExact: 5 // exact matches by the providerID field
		csvClass: 4 // matches where the region and instanceType match
		“”: 1 // matches that use our default pricing
}
}
```

## More information

Refer to our public [cost-model repository README](https://github.com/opencost/opencost#readme) for more information.
