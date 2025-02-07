Installing Kubecost with Plural
================================

[Plural](https://www.plural.sh/) is a free, open-source tool that enables you to deploy Kubecost on Kubernetes with the cloud provider of your choice. Plural is an open-source DevOps platform for self-hosting applications on Kubernetes without the management overhead. With baked-in SSO, automated upgrades, and secret encryption, you get all the benefits of a managed service with none of the lock-in or cost.

Kubecost is available as direct install with Plural, and it interoperates very well with the ecosystem, providing cost monitoring out of the box to users that deploy their Kubernetes clusters with Plural.

## Getting started

First, create an account on [Plural](https://app.plural.sh). This is only to track your installations and allow for the delivery of automated upgrades. You will not be asked to provide any infrastructure credentials or sensitive information.

Next, install the Plural CLI by following steps 1-3 of [Plural's CLI Quickstart guide](https://docs.plural.sh/getting-started).

You'll need a Git repository to store your Plural configuration. This will contain the Helm charts, Terraform config, and Kubernetes manifests that Plural will autogenerate for you.

You have two options:
- Run `plural init` in any directory to let Plural initiate an OAuth workflow to create a Git repo for you.
- Create a Git repo manually, clone it down, and run `plural init` inside it.

Running `plural init` will start a configuration wizard to configure your Git repo and cloud provider for use with Plural. You're now ready to install Kubecost on your Plural repo.

## Installing Kubecost

To find the console bundle name for your cloud provider, run:

```bash
plural bundle list kubecost
```

Now, to add it your workspace, run the install command. If you're on AWS, this is what the command would look like:

```bash
plural bundle install kubecost kubecost-aws
```

Plural's Kubecost distribution has support for AWS, GCP, and Azure, so feel free to pick whichever best fits your infrastructure.

The CLI will prompt you to choose whether you want to use Plural OIDC. [OIDC](https://openid.net/connect/) allows you to log in to the applications you host on Plural with your [login](https://app.plural.sh) acting as an SSO provider. 

To generate the configuration and deploy your infrastructure, run:

```bash
plural build
plural deploy --commit "deploying kubecost"
```

> **Note**: Deploys will generally take 10-20 minutes, based on your cloud provider.

## Installing the Plural Console

To make management of your installation as simple as possible, we recommend installing the Plural Console. The console provides tools to manage resource scaling, receiving automated upgrades, creating dashboards tailored to your Kubecost installation, and log aggregation. This can be done using the exact same process as above, using AWS as an example:

```bash
plural bundle install console console-aws
plural build
plural deploy --commit "deploying the console too"
```

## Accessing your Kubecost installation

Now, head over to `kubecost.YOUR_SUBDOMAIN.onplural.sh` to access the Kubecost UI. If you set up a different subdomain for Kubecost during installation, make sure to use that instead.

## Accessing your Plural Console

To monitor and manage your Kubecost installation, head over to the Plural Console at `console.YOUR_SUBDOMAIN.onplural.sh`.

## Uninstalling Kubecost on Plural

To bring down your Plural installation of Kubecost at any time, run:

```bash
plural destroy kubecost
```

To bring your entire Plural deployment down, run:

```bash
plural destroy
```
{% hint style="info" %}
Only do this if you're absolutely sure you want to bring down all associated resources with this repository.
{% endhint %}

## Troubleshooting

If you have any issues with installing Kubecost on Plural, feel free to join the Plural [Discord Community](https://discord.gg/bEBAMXV64s) and we can help you out.

If you'd like to request any new features for our Kubecost installation, feel free to open an issue or PR [here](https://github.com/pluralsh/plural-artifacts).

## Further reading

To learn more about what you can do with Plural and more advanced uses of the platform, feel free to dive deeper into [Plural's docs](https://docs.plural.sh).
