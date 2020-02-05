### Creating a Google Service Account
In order to create a Google service account for use with Thanos:

#### Navigate to the Google console menu and select `IAM & Admin -> Service accounts`.

![image](https://user-images.githubusercontent.com/334480/66667677-95094780-ec21-11e9-860f-fe3edcbb0d4c.png)

#### From here, select the option `+ Create Service Account`

![image](https://user-images.githubusercontent.com/334480/66667734-b4a07000-ec21-11e9-9683-de7600806910.png)

#### Provide a Service Account Name and Description

![image](https://user-images.githubusercontent.com/334480/66667856-faf5cf00-ec21-11e9-817d-65c2dad92af4.png)

#### Press `Create`.
You should now be at the `Service account permissions (optional)` screen. Click inside the `Role` box, and set the first entry to **Storage Object Creator**. Click the `+ Add Another Role` and set the second  entry to **Storage Object Viewer**.

![image](https://user-images.githubusercontent.com/334480/66667955-2ed0f480-ec22-11e9-90cb-b160b8170aa4.png)

#### Hit Continue
You should now be prompted to allow specific accounts access to this service account. This should be based on specific internal needs and is not a requirement. You can leave empty and press `Done`

#### Create a Key
Once back to the service accounts menu, select the `...` at the end of the entry you  just created and press `Create Key`

![image](https://user-images.githubusercontent.com/334480/66668267-d3ebcd00-ec22-11e9-9e8c-4f178b8dd265.png)

#### Confirm JSON
Confirm a JSON key and hit `Create`. This will download a JSON service account key entry for use with the Thanos `object-store.yaml` mentioned in the initial setup step.
