### Creating an IAM policy
In order to create an AWS IAM policy for use with Thanos:

#### Navigate to the AWS console menu and select `...`.



**Note:** make sure to replace <your-bucket-name> with the name of the bucket from step

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
                "s3:CreateBucket",
                "s3:DeleteBucket"
            ],
            "Resource": [
                "arn:aws:s3:::<your-bucket-name>/*",
                "arn:aws:s3:::<your-bucket-name>"
            ]
        }
    ]
}
```




If you don’t want to use a service account, IAM credentials retrieved from an instance profile are also supported.
You must get both access key and secret key from the same method (i.e. both from service or instance profile).
