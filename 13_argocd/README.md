# ArgoCD Troubleshooting Demo

ArgoCD `Application` manifests wrapping the broken pods from `12_debugging/examples`
plus the Helm chart from `11_helm/lindner-app`. Each broken case is its own
Application so the ArgoCD UI shows one failure mode per tile.

## Bootstrap

```bash
kubectl apply -f 00-appproject.yaml
kubectl apply -f 01-app-of-apps.yaml
```

The root Application syncs everything under `apps/`.

## What to look at in the UI

| Application                         | Expected state                | Where to look                              |
| ----------------------------------- | ----------------------------- | ------------------------------------------ |
| `debug-imagepullbackoff`            | Synced / **Degraded**         | Pod → Events: `Failed to pull image`       |
| `debug-crashloopbackoff`            | Synced / **Degraded**         | Pod → Logs, restart count                  |
| `debug-oomkilled`                   | Synced / **Degraded**         | Pod → containerStatuses → `OOMKilled`      |
| `debug-pending-failedscheduling`    | Synced / **Progressing**      | Pod → Events: `FailedScheduling`           |
| `debug-readiness-fails`             | Synced / **Degraded**         | Pod ready 0/1, Service endpoints empty     |
| `lindner-app`                       | Synced / Healthy              | Helm-rendered tree, diff vs. live          |

## Talking points

- **Synced ≠ Healthy.** Git state can match cluster while pods burn.
- **Self-Heal.** Delete a broken pod manually → ArgoCD recreates it.
- **Diff view.** Edit a live resource with `kubectl edit` → ArgoCD shows OutOfSync.
- **App-of-Apps.** Root Application manages child Applications; cascade delete via finalizer.

## Cleanup

```bash
kubectl -n argocd delete application training-root
kubectl delete ns example-debugging lindner-app
```
