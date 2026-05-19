# Velero Helm Install

Add Helm Chart Repository:

```
helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
helm repo update
```

Install Velero via Helm

```bash
# Simple Install with default values
helm install \
  velero vmware-tanzu/velero \
  --version 10.1.3 \
  --namespace velero \
  --create-namespace

# Customized Installation
helm upgrade \
  velero vmware-tanzu/velero \
  --version 11.1.0 \
  --namespace velero \
  -f velero-custom-values.yaml
```
