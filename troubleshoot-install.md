## Issue: no persistent volumes available for this claim and/or no storage class is set

Your clusters needs a default storage class for the Kubecost and Prometheus persistent volumes to be successfully attached.

To check if a storage class exists, you can run

```kubectl get storageclass```

You should see a storageclass name with (default) next to it as in this example. 

<pre>
NAME                PROVISIONER           AGE 
standard (default)  kubernetes.io/gce-pd  10d
</pre>

If you see a name but no (default) next to it, run 

```kubectl patch storageclass <name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'```

If you don’t see a name, you need to add a storage class. For help doing this, see the following guides:

* AWS: https://docs.aws.amazon.com/eks/latest/userguide/storage-classes.html
* Azure: https://kubernetes.io/docs/concepts/storage/storage-classes/#azure-disk
