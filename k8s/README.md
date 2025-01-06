## k3s

> On your local machine

- `sudo apt-get update && sudo apt-get -y install open-iscsi`

- `sudo systemctl start iscsid`

- `cd  && echo "alias k=kubectl" >> .bashrc && source .bashrc`

- `wget https://dl.k8s.io/release/v1.30.5/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/`

- `curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" sh -s`

- `wget https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz && tar -zxvf helm-v3.16.2-linux-amd64.tar.gz && sudo mv linux-amd64/helm /usr/local/bin/`

-> Get the `${NODE_TOKEN}` from `/var/lib/rancher/k3s/server/node-token` on your machine

---

- `vagrant ssh box01`

- On the box01 -> `curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://192.168.56.1:6443 --token ${NODE_TOKEN} --flannel-iface eth1" sh -s -`

- `exit`

---

- `vagrant ssh box02`

- On the box02 -> `curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://192.168.56.1:6443 --token ${NODE_TOKEN} --flannel-iface eth1" sh -s -`

- `exit`

---

- `cd && mkdir .kube/ && sudo cp /etc/rancher/k3s/k3s.yaml .kube/config  && sudo chown $USER:$USER .kube/config`

- `k get node,svc,pod -A`

- `helm list -A`


---
### Old version (dont do that)
- `wget https://github.com/k3s-io/k3s/releases/download/v1.31.4%2Bk3s1/k3s` download k3s locally

- `chmod +x k3s && sudo mv k3s /usr/local/bin/` k3s executable and in PATH

- `screen` puis `sudo k3s server &` launch k3s server (CTRL+A - D) pour sortir

- `vagrant ssh box01 -- sudo k3s agent --server https://192.168.56.1:6443 --flannel-iface eth1 --token ${NODE_TOKEN}`  add a node on the cluster

- `vagrant ssh box02 -- sudo k3s agent --server https://192.168.56.1:6443 --flannel-iface eth1 --token ${NODE_TOKEN}`  add a node on the cluster

