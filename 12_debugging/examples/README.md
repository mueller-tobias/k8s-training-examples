# Debugging Examples — Top 5 Fehlerbilder

Namespace: `example-debugging`

## Apply

```bash
kubectl apply -f 00-namespace.yaml
kubectl apply -f .
```

## Cases

| File | Symptom | Trigger |
|------|---------|---------|
| `01-imagepullbackoff.yaml` | `ImagePullBackOff` | Image tag does not exist |
| `02-crashloopbackoff.yaml` | `CrashLoopBackOff` | Container exits 1 on boot |
| `03-oomkilled.yaml` | `OOMKilled` | Allocates 250Mi, limit 64Mi |
| `04-pending-failedscheduling.yaml` | `Pending` / `FailedScheduling` | Impossible nodeSelector + 999Gi request |
| `05-readiness-fails.yaml` | Readiness fails | Probe hits `/healthz` (404 in nginx) |

## Debug commands (Faustregel)

```bash
NS=example-debugging

# 1. Status + Events
kubectl -n $NS get pods
kubectl -n $NS describe pod <name>
kubectl -n $NS get events --sort-by=.lastTimestamp

# 2. Logs (current + previous)
kubectl -n $NS logs <name>
kubectl -n $NS logs <name> --previous

# 3. Manifest-Diff
kubectl -n $NS get pod <name> -o yaml
```

## Cleanup

```bash
kubectl delete namespace example-debugging
```
