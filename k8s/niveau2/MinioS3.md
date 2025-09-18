


helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
kubectl create ns minio




helm upgrade --install minio bitnami/minio -n minio \
  --set mode=standalone \
  --set auth.rootUser='MYUSER' \
  --set auth.rootPassword='MYPASS!' \
  --set ingress.enabled=true \
  --set ingress.ingressClassName=nginx \
  --set ingress.hostname=minio.k8s.localhost \
  --set console.enabled=true \
  --set console.ingress.enabled=true \
  --set console.ingress.ingressClassName=nginx \
  --set console.ingress.hostname=minio-console.k8s.localhost



echo "192.168.56.200 minio.k8s.localhost minio-console.k8s.localhost" | sudo tee -a /etc/hosts


kubectl -n minio get pods,svc,ingress
# Connexions :
#  - Console :    http://minio-console.k8s.localhost
#  - S3 API :     http://minio.k8s.localhost



