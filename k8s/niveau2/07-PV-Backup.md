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
## Setup Minio for Longhorn 

```
kubectl -n longhorn-system create secret generic longhorn-minio \
  --from-literal=AWS_ACCESS_KEY_ID='admin' \
  --from-literal=AWS_SECRET_ACCESS_KEY='SuPeRmInIoPaSsW0rD' \
  --from-literal=AWS_ENDPOINTS='http://minio.minio.svc.cluster.local:9000'

helm upgrade longhorn longhorn/longhorn -n longhorn-system --reuse-values \
  --set defaultBackupStore.backupTarget="s3://longhorn@us-east-1/" \
  --set defaultBackupStore.backupTargetCredentialSecret="longhorn-minio"

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

> Sur le volume restauré, cliquer "Créer PV/PVC" et nommer le PVC "nginx-data-restore"

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
