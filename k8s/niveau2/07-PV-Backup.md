# Backup volume with Longhorn / Minio


## Create an app :

```
cat <<'EOF' | kubectl apply -f -

# nginx-pvc-deploy.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nginx-data
  namespace: default
spec:
  storageClassName: longhorn
  accessModes: [ ReadWriteOnce ]
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  namespace: default
spec:
  replicas: 1
  selector: { matchLabels: { app: nginx } }
  template:
    metadata:
      labels: { app: nginx }
    spec:
      # Seed a file on the volume before nginx starts
      initContainers:
      - name: seed
        image: busybox:1.36
        command: ["/bin/sh","-c"]
        args:
          - |
            echo 'Hello from Longhorn backup demo' > /data/index.html
        volumeMounts:
        - name: data
          mountPath: /data
      containers:
      - name: nginx
        image: nginx:1.27-alpine
        ports: [{containerPort: 80}]
        volumeMounts:
        - name: data
          mountPath: /usr/share/nginx/html
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: nginx-data
EOF


kubectl rollout status deploy/nginx

kubectl exec deploy/nginx -- sh -c 'wget -qO- localhost' 

```
## Backup it

> Sur l'UI Longhorn, lancer un full backup du volume

> Attendre qu'il apparaisse dans l'onglet Backup


## Delete it 

```
kubectl delete deploy/nginx
kubectl delete pvc/nginx-data
```

## Restore it

> Sur l'onglet Backup, cliquer sur "Restore Latest backup"

Name: `nginx-restore`


```
cat <<'EOF' | kubectl apply -f -

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-restore
  namespace: default
spec:
  replicas: 1
  selector: { matchLabels: { app: nginx-restore } }
  template:
    metadata:
      labels: { app: nginx-restore }
    spec:
      containers:
      - name: nginx
        image: nginx:1.27-alpine
        ports: [{containerPort: 80}]
        volumeMounts:
        - name: data
          mountPath: /usr/share/nginx/html
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: nginx-data-restore
EOF

kubectl rollout status deploy/nginx-restore


kubectl exec deploy/nginx-restore -- sh -c 'wget -qO- localhost'
```
