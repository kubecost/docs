Thanos Chunk Pool Size 
======================

The following error in the thanos-store pod indicates a need to increase the chunk-pool-size. 

```
rpc error: code = Aborted desc = fetch series for block <>: preload chunks: read range for 0: allocate chunk bytes: pool exhausted" msg="returning partial response"
```

Increase the chunkPoolSize to 8GB in the values.yaml file:

```
thanos:
  store:
    chunkPoolSize: 8GB
```

