# NFS with Kubernetes


> sur NFS-Server

```
sudo su

apt-get update
apt-get install -y nfs-kernel-server nfs-common

mkdir -p /srv/nfs/kubedata
chown -R nobody:nogroup /srv/nfs
chmod -R 0777 /srv/nfs


cat >/etc/exports <<'EOF'
/srv/nfs/kubedata 192.168.56.0/24(rw,sync,no_subtree_check,no_root_squash)
EOF

exportfs -rav
systemctl enable --now nfs-server

exportfs -v

```


> Test sur box03 

```
showmount -e 192.168.56.50
mkdir -p /mnt/nfs-test
mount -t nfs 192.168.56.50:/srv/nfs/kubedata /mnt/nfs-test
touch /mnt/nfs-test/OK
umount /mnt/nfs-test
```


> nfs-subdir-external-provisioner


```
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update

# Namespace dédié
kubectl create ns nfs-provisioner

# Installation : pointe vers box05 et le chemin exporté
helm upgrade --install nfs-subdir-external-provisioner \
  nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
  --namespace nfs-provisioner \
  --set nfs.server=192.168.56.50 \
  --set nfs.path=/srv/nfs/kubedata \
  --set storageClass.name=nfs-client \
  --set storageClass.defaultClass=true \
  --set storageClass.allowVolumeExpansion=true \
  --set podAnnotations."k8s\.v1\.cni\.cncf\.io/networks"=""    # rien de spécial côté Cilium


kubectl -n nfs-provisioner get pods
kubectl get sc
```


> Test


```
kubectl create ns nfs-test

cat <<'EOF' | kubectl -n nfs-test apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-nfs
spec:
  accessModes: ["ReadWriteMany"]
  storageClassName: nfs-client
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: writer
spec:
  containers:
  - name: alpine
    image: alpine:3.20
    command: ["sh","-c","echo hello-from-$(hostname) > /data/hello.txt; sleep 3600"]
    volumeMounts:
    - mountPath: /data
      name: vol
  volumes:
  - name: vol
    persistentVolumeClaim:
      claimName: pvc-nfs
EOF

kubectl -n nfs-test get pvc,pod

```



> Check sur le nfs-server

```
ls -R /srv/nfs/kubedata
cat /srv/nfs/kubedata/*/hello.txt

```
