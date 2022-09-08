Creating a Google Service Account
=================================

In order to create a Google service account for use with Thanos, navigate to the [Google Cloud Platform home page](https://console.cloud.google.com/getting-started) and select *IAM & Admin -> Service Accounts*.

![image](https://user-images.githubusercontent.com/334480/66667677-95094780-ec21-11e9-860f-fe3edcbb0d4c.png)

From here, select the option *Create Service Account*.

![image](https://user-images.githubusercontent.com/334480/66667734-b4a07000-ec21-11e9-9683-de7600806910.png)

Provide a service account name and description, then select _Create_.

![image](https://user-images.githubusercontent.com/334480/66667856-faf5cf00-ec21-11e9-817d-65c2dad92af4.png)

You should now be at the Service account permissions (optional) page. Select the first _Role_ dropdown and select *Storage Object Creator*. Select _Add Another Role_, then select _Storage Object Viewer_ from the second dropdown. Select _Continue_.

![image](https://user-images.githubusercontent.com/334480/66667955-2ed0f480-ec22-11e9-90cb-b160b8170aa4.png)

You should now be prompted to allow specific accounts access to this service account. This should be based on specific internal needs and is not a requirement. You can leave empty and select _Done_.__

## Create a key
Once back to the Service accounts page, select the _Actions_ icon > _Manage keys_. Then, select the _Add Key_ dropdown and select _Create new key_. A Create private key window opens.

![image](https://user-images.githubusercontent.com/334480/66668267-d3ebcd00-ec22-11e9-9e8c-4f178b8dd265.png)

Select _JSON_ as the Key type and select _Create_. This will download a JSON service account key entry for use with the Thanos `object-store.yaml` mentioned in the initial setup step.


Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/google-service-account-thanos.md)

<!--- {"article":"4407601817495","section":"4402815680407","permissiongroup":"1500001277122"} --->
