# Thanos Encryption With s3 and KMS

You can encrypt the s3 bucket where kubecost data is stored in AWS via s3 and KMS. However, because thanos can store potentially millions of objects, it is suggested that you use bucket-level encryption instead of object-level encryption. More details available here:

https://thanos.io/tip/thanos/storage.md/#s3
https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html
https://docs.aws.amazon.com/AmazonS3/latest/userguide/configuring-bucket-key-object.html
