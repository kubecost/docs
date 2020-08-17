### Creating a Thanos IAM policy
In order to create an AWS IAM policy for use with Thanos:

1.  Navigate to the AWS console and select `IAM`.

2. Select Policies in the Navigation menu and choose `Create Policy`

3. Add the following JSON in the policy editor

&nbsp;&nbsp;&nbsp;&nbsp;**Note:** make sure to replace `<your-bucket-name>` with the name of your newly created S3 bucket

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Statement",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::<your-bucket-name>/*",
                "arn:aws:s3:::<your-bucket-name>"
            ]
        }
    ]
}
```

&nbsp;&nbsp;4.&nbsp;Select Review policy and name this policy, e.g. `kc-thanos-store-policy`

&nbsp;&nbsp;5.&nbsp;Navigate to Users in IAM control panel, and select Add user

&nbsp;&nbsp;6.&nbsp;Provide a User name (e.g. `kubecost-thanos-service-account`) and select `Programmatic access`

&nbsp;&nbsp;7.&nbsp;Select Attach existing policies directly, search for the policy name provided in step 4, and then create the user.

![image](/attach-existing.png)

&nbsp;&nbsp;&nbsp;8.&nbsp;Capture your Access Key ID and secret in the view below:

![image](/key-created.png)

If you don’t want to use a service account, IAM credentials retrieved from an instance profile are also supported.
You must get both access key and secret key from the same method (i.e. both from service or instance profile). More info on retrieving credentials [here](https://thanos.io/storage.md/#credentials).
