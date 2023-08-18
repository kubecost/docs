# Creating a Google Service Account

In order to create a Google service account for use with Thanos, navigate to the [Google Cloud Platform home page](https://console.cloud.google.com/getting-started) and select _IAM & Admin > Service Accounts_.

![GCP IAM Service Account](/images/gcp-iam-sa.png)

From here, select the option _Create Service Account_.

![GCP option to create Service Account](/images/gcp-create-sa.png)

Provide a service account name, ID, and description, then select _Create and Continue_.

![GCP create Service Account wizard](/images/gcp-sa-wizard.png)

You should now be at the Service account permissions (optional) page. Select the first _Role_ dropdown and select _Storage Object Creator_. Select _Add Another Role_, then select _Storage Object Viewer_ from the second dropdown. Select _Continue_.

![GCP Service Account permissions editor](/images/gcp-sa-perms.png)

You should now be prompted to allow specific accounts access to this service account. This should be based on specific internal needs and is not a requirement. You can leave this empty and select _Done_.

## Create a key

Once back to the Service accounts page, select the _Actions_ icon > _Manage keys_. Then, select the _Add Key_ dropdown and select _Create new key_. A Create private key window opens.

Select _JSON_ as the Key type and select _Create_. This will download a JSON service account key entry for use with the Thanos `object-store.yaml` mentioned in the initial setup step.
