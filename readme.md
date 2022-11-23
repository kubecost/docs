Kubecost Documentation
======================

Kubecost helps you monitor and manage cost and capacity in Kubernetes environments. Check out [our website](kubecost.com) for more info. 

This repo contains all external documentation for Kubecost. Additionally, this doc provides information for contirbuting to our docs for continual improvement. Docs for Kubecost are hosted at [here](https://guide.kubecost.com). The main branch of the kubecost/docs repo is pulled and documents are updated daily.

## Markdown

All Kubecost docs are formatted in Markdown. For those unfamiliar, the [Markdown Guide](https://www.markdownguide.org/getting-started/) is a one-stop shop for using this markup syntax language.

## Contributing

We encourage users who notice errors in our documentation to bring these to our attention, or if you feel inclined, submit changes personally.

### Build and deploy

The main branch of the kubecost/docs repo is pulled and documents on guide.kubecost.com are updated daily.

### Create a new doc

To create a new document, submit a pull request including a Markdown file and any image assets to the main branch of the kubecost/docs repo. After reviewing and merging on GitHub, a new document will be created on guide.kubecost.com once the build and deploy phase has completed.

### Images

Use a direct link to the GitHub image within the kubecost/docs repo or an alternative host such as GCS or S3.

```
![Add key dialog](https://raw.githubusercontent.com/kubecost/docs/main/add-key-dialog.png)
```
 
At this time there aren't limits on the location of images within the kubecost/docs repo. Images may exist in the `/images` folder or in the root directory.


<!--- {"article":"4407763013271","section":"1500002777682","permissiongroup":"1500001277122"} --->
