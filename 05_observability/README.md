
# Metrics Server
To use the metrics server inside the KIND-Cluster we created a customized config with `--kubelet-insecure-tls`.

To install use the following command:

```
kubectl apply -k ./metrics-server
```
