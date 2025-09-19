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
```