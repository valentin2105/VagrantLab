## k3s

- `sudo apt-get update && sudo apt-get -y install open-iscsi`

- `sudo systemctl start iscsid`

- `wget https://github.com/k3s-io/k3s/releases/download/v1.28.7%2Bk3s1/k3s` download k3s locally 

- `chmod +x k3s && sudo mv k3s /usr/local/bin/` k3s executable and in PATH

- `cd /home/formation/ && echo "alias k=kubectl" >> .bashrc && source .bashrc`

- `wget https://dl.k8s.io/release/v1.27.7/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/`

- `wget https://get.helm.sh/helm-v3.14.3-linux-amd64.tar.gz && tar -zxvf helm-v3.14.3-linux-amd64.tar.gz && sudo mv linux-amd64/helm /usr/local/bin/`

- `sudo k3s server &` launch k3s server

> `${NODE_TOKEN}` comes from `/var/lib/rancher/k3s/server/node-token` on your machine

- `vagrant ssh box01 -- sudo k3s agent --server https://192.168.56.1:6443 --flannel-iface eth1 --token ${NODE_TOKEN}`  add a node on the cluster

- `vagrant ssh box02 -- sudo k3s agent --server https://192.168.56.1:6443 --flannel-iface eth1 --token ${NODE_TOKEN}`  add a node on the cluster

- `sudo mkdir /home/formation/.kube && sudo cp /etc/rancher/k3s/k3s.yaml /home/formation/.kube/config  && sudo chown formation:formation /home/formation/.kube/config`

- `k get node,svc,pod -A`

- `helm list -A`


If ZFS : 
```
sudo zfs create -s -V 10GB rpool/ROOT/ubuntu_rbl8ta/var/lib/rancher
sudo mkfs.ext4 /dev/rpool/ROOT/ubuntu_rbl8ta/var/lib/rancher
echo "/dev/zvol/zpool/k3s/agent /var/lib/rancher/k3s/agent ext4 defaults,_netdev 0 0" | sudo tee -a /etc/fstab
sudo mount -a
```


