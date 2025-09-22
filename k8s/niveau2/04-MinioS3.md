# Minio S3

```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
kubectl create ns minio




helm upgrade --install minio bitnami/minio -n minio \
  --set mode=standalone \
  --set auth.rootUser='admin' \
  --set auth.rootPassword='SuPeRmInIoPaSsW0rD' \
  --set ingress.enabled=true \
  --set ingress.ingressClassName=nginx \
  --set ingress.hostname=minio.k8s.local \
  --set console.enabled=true \
  --set persistence.storageClass=nfs-client \
  --set console.ingress.enabled=true \
  --set console.ingress.ingressClassName=nginx \
  --set console.ingress.hostname=minio-console.k8s.local
```


```
echo "192.168.56.200 minio.k8s.local minio-console.k8s.local" | sudo tee -a /etc/hosts


kubectl -n minio get pods,svc,ingress
```


### Connexions :
####  - Console :    http://minio-console.k8s.local
####  - S3 API :     http://minio.k8s.local


> Create `backups` and `longhorn` buckets.
