Creating a Thanos IAM policy
============================
In order to create an AWS IAM policy for use with Thanos:

1.  Navigate to the AWS console and select `IAM`.

2. Select Policies in the Navigation menu and choose `Create Policy`

3. Add the following JSON in the policy editor

    > **Note:** Make sure to replace `<your-bucket-name>` with the name of your newly created S3 bucket

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

4. Select Review policy and name this policy, e.g. `kc-thanos-store-policy`

5. Navigate to Users in IAM control panel, and select Add user

6. Provide a User name (e.g. `kubecost-thanos-service-account`) and select `Programmatic access`

7. Select Attach existing policies directly, search for the policy name provided in step 4, and then create the user.

    ![image](https://raw.githubusercontent.com/kubecost/docs/main/attach-existing.png)

8.Capture your Access Key ID and secret in the view below:

    ![image](https://raw.githubusercontent.com/kubecost/docs/main/key-created.png)

If you don’t want to use a service account, IAM credentials retrieved from an instance profile are also supported.
You must get both access key and secret key from the same method (i.e. both from service or instance profile). More info on retrieving credentials [here](https://thanos.io/storage.md/#credentials).

<!--- {"article":"4407595933847","section":"4402829036567","permissiongroup":"1500001277122"} --->
