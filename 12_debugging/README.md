# Debugging Distroless Containers with `kubectl debug`

Distroless container images (`gcr.io/distroless/*`, Chainguard, Wolfi, scratch-based,
etc.) ship **only the application binary and its runtime dependencies**. No shell,
no `ps`, no `ls`, no package manager. This is great for security and image size,
but breaks the classic debugging reflex:

```bash
kubectl exec -it <pod> -- sh
# OCI runtime exec failed: exec: "sh": executable file not found in $PATH
```

The fix: **ephemeral debug containers** (stable since Kubernetes 1.25). They are
attached to a running pod, share its namespaces, and bring their own toolchain.

## 1. Deploy the demo workload

```bash
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-distroless-deployment.yaml

kubectl -n debugging get pods -w
```

Confirm the distroless reflex fails:

```bash
POD=$(kubectl -n debugging get pod -l app=distroless-app -o name)

kubectl -n debugging exec -it "$POD" -- sh
# -> executable file not found in $PATH
```

## 2. Attach an ephemeral debug container

`kubectl debug` injects a new container into the **running pod**. The original
container is untouched.

```bash
kubectl -n debugging debug -it "$POD" \
  --image=busybox:1.36 \
  --target=app \
  -- sh
```

Flags:

- `--image` — debug toolbox image. `busybox`, `nicolaka/netshoot`,
  `alpine`, `cgr.dev/chainguard/wolfi-base` all work.
- `--target=app` — enables **process namespace sharing** with the `app`
  container. Without it you only share network + IPC, not PIDs / `/proc`.
- `-it -- sh` — interactive TTY into the debug image's shell.

Inside the debug container:

```sh
# see processes of the target container
ps -ef

# reach the target container's filesystem via /proc
ls -l /proc/1/root/

# poke the app over loopback (shared network namespace)
wget -qO- 127.0.0.1:8080

# look at env / open files of PID 1 of the target
cat /proc/1/environ | tr '\0' '\n'
ls -l /proc/1/fd/
```

Exit the shell — the ephemeral container stops but **remains recorded** in the
pod spec for the lifetime of the pod (`kubectl describe pod`).

## 3. Network-only debug (no `--target`)

For pure network troubleshooting (DNS, routes, egress) the PID share is not
needed:

```bash
kubectl -n debugging debug -it "$POD" \
  --image=nicolaka/netshoot \
  -- bash

# inside:
dig kubernetes.default
curl -v http://distroless-app/
ip route
```

## 4. Debug a crashing pod with `--copy-to`

When the target container crash-loops you can't attach — it isn't running long
enough. Clone the pod, swap the broken image / command for a shell, and
investigate the clone:

```bash
kubectl -n debugging debug "$POD" \
  --copy-to=distroless-debug \
  --container=app \
  --image=busybox:1.36 \
  --share-processes \
  -- sh -c 'sleep 1d'

kubectl -n debugging exec -it distroless-debug -- sh
# Now you have a shell where the broken container used to be,
# with the same volumes, env, service account, and node placement.

# Cleanup
kubectl -n debugging delete pod distroless-debug
```

## 5. Debug a node (bonus)

Same command, different target — useful for kubelet / containerd issues:

```bash
NODE=$(kubectl get node -o name | head -1)
kubectl debug "$NODE" -it --image=busybox:1.36
# host filesystem is mounted at /host
chroot /host
```

## Cheatsheet

| Scenario                          | Command                                                                 |
| --------------------------------- | ----------------------------------------------------------------------- |
| Distroless, running, need shell   | `kubectl debug -it POD --image=busybox --target=CTR -- sh`              |
| Network only                      | `kubectl debug -it POD --image=nicolaka/netshoot -- bash`               |
| Crashlooping container            | `kubectl debug POD --copy-to=dbg --container=CTR --image=busybox -- sh` |
| Inspect a node                    | `kubectl debug node/NODE -it --image=busybox`                           |

## Cleanup

```bash
kubectl delete namespace debugging
```

## References

- <https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/>
- <https://kubernetes.io/docs/reference/kubectl/generated/kubectl_debug/>
- <https://github.com/GoogleContainerTools/distroless>
