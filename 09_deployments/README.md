# Deployments

[Reference Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

Deploy the nginx-application with 3 replicas

```
kubectl apply -f deployment.yaml
```


2. Update the deployment to use image `nginx:1.9.1`

```
kubectl --record deployment.apps/nginx-deployment set image deployment.v1.apps/nginx-deployment nginx=nginx:1.9.1
```

3. Make an error (use wrong image tag)

```
kubectl set image deployment.v1.apps/nginx-deployment nginx=nginx:1.91 --record=true
```

Watch the error with kubectl get po

```
$ kubectl get po
NAME                                READY   STATUS             RESTARTS   AGE
nginx-deployment-6f6986d7b6-rjwzr   0/1     ImagePullBackOff   0          18s
nginx-deployment-784b7cc96d-q2c4c   1/1     Running            0          69s
nginx-deployment-784b7cc96d-w84ss   1/1     Running            0          71s
nginx-deployment-784b7cc96d-zv8f7   1/1     Running            0          112s
```

Display Rollout Status `kubectl rollout status deployment.v1.apps/nginx-deployment`

Get Deployment History
```
$ kubectl rollout history deployment.v1.apps/nginx-deployment
deployment.apps/nginx-deployment 
REVISION  CHANGE-CAUSE
1         <none>
2         kubectl deployment.apps/nginx-deployment set image deployment.v1.apps/nginx-deployment nginx=nginx:1.9.1 --record=true
3         kubectl set image deployment.v1.apps/nginx-deployment nginx=nginx:1.91 --record=true

```
See details to a specific revision number
```
$ kubectl rollout history deployment.v1.apps/nginx-deployment --revision=2
deployment.apps/nginx-deployment with revision #2
Pod Template:
  Labels:	app=nginx
	pod-template-hash=784b7cc96d
  Annotations:	kubernetes.io/change-cause:
	  kubectl deployment.apps/nginx-deployment set image deployment.v1.apps/nginx-deployment nginx=nginx:1.9.1 --record=true
  Containers:
   nginx:
    Image:	nginx:1.9.1
    Port:	80/TCP
    Host Port:	0/TCP
    Environment:	<none>
    Mounts:	<none>
  Volumes:	<none>
```

Rollback to the previous revision
```
kubectl rollout undo deployment.v1.apps/nginx-deployment
```
Alternatively use a specified revision number
```
kubectl rollout undo deployment.v1.apps/nginx-deployment --to-revision=2
```


### Scaling a Deployment

Scale the deployment to a given replica-count

```
kubectl scale deployment.v1.apps/nginx-deployment --replicas=5
```


If you enable the horizontal-pod-autoscaler feature, you could autoscale 
the application based on the given CPU utilization

```
kubectl autoscale deployment.v1.apps/nginx-deployment --min=1 --max=5 --cpu-percent=80
```

### Pausing and resuming a Deployment

You can pause a Deployment before triggering one or more updates and 
then resume it. This will allow you to apply multiple fixes in between 
pausing and resuming without triggering unnecessary rollouts.

```
kubectl rollout pause deployment.v1.apps/nginx-deployment
```

Make your changes. No rollout will be performed

Resume the Deployment

```
kubectl rollout resume deployment.v1.apps/nginx-deployment
```





# Deployment Strategies


1) Continous Integration
2) Continous Delivery
3) Continous Deployment

Build Prozess -> 
    "Docker" Image ->
        "Testen" / End2End Test -> # Continous Integration "erreicht", kann manuell durchgeführt werden
            "Deployment Prozess" (ArgoCD) -> 
                
                # Continous Delivery: Manuelles! Deployment in DEV/Staging/Prod
                # Continous Deployment: Automatisiertes Deployment in Dev/... 

                Dev-Cluster -> 
                    Staging Cluster -> 
                        Production Cluster -> 
                            Eventuell Rollback  # Continous Deployment: Automatisierter Rollback basierend auf Applikations-Metriken