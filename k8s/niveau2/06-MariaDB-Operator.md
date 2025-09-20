# MariaDB Operator

```
helm repo add mariadb-operator https://helm.mariadb.com/mariadb-operator
helm install mariadb-operator-crds mariadb-operator/mariadb-operator-crds

helm install --namespace mariadb-operator \
     --create-namespace \
     mariadb-operator \
     mariadb-operator/mariadb-operator
```

```
git clone https://github.com/mariadb-operator/mariadb-operator.git --depth 1

cd mariadb-operator/


kubectl apply -f examples/manifests/config
kubectl apply -f examples/manifests/mariadb.yaml

kubectl get mariadbs
kubectl get statefulsets
kubectl get pod
kubectl get services


kubectl apply -f examples/manifests/database.yaml
kubectl apply -f examples/manifests/user.yaml
kubectl apply -f examples/manifests/grant.yaml


kubectl get databases
kubectl get users
kubectl get grants
```

```
sudo ip route add 192.168.56.201/32 via 192.168.56.10
mysql -u user -p -h 192.168.56.201  
# MariaDB11!
```

# S3-Backup
```
kubectl create -f backup-s3.yaml
kubectl get cronjob,job

# Check on minio
```

# Galera 

```
kubectl create -f mariadb-galera.yaml
sudo ip route add 192.168.56.202/32 via 192.168.56.10


kubectl get mariadb
kubectl get statefulsets
kubectl get pod
kubectl get svc,ep

mysql -u root -p -h 192.168.56.202
# MariaDB11!

SHOW STATUS LIKE 'wsrep_incoming_addresses';

SHOW STATUS LIKE 'wsrep_cluster_size';

SHOW STATUS LIKE 'wsrep_local_state_comment';
```