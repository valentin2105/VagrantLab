## Instllation de Kubernetes avec k3s

> Sur le PC de formation (Ubuntu)

- `sudo apt-get update && sudo apt-get -y install open-iscsi`

- `sudo systemctl start iscsid`

- `echo "alias k=kubectl" >> /home/formation/.bashrc && source /home/formation/.bashrc`

- `wget https://dl.k8s.io/release/v1.30.5/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/`

- `curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server" sh -s`

- `cd /tmp/ && wget https://get.helm.sh/helm-v3.16.2-linux-amd64.tar.gz && tar -zxvf helm-v3.16.2-linux-amd64.tar.gz && sudo mv linux-amd64/helm /usr/local/bin/`

- `cd - `

- `NODE_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)`

Récupérer ce token (complet) pour la suite

---


- Sur box01 -> `vagrant ssh box01 -c "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=\"agent --server https://192.168.56.1:6443 --token $NODE_TOKEN --flannel-iface eth1\" sh -s -"`


- Sur box02 -> `vagrant ssh box02 -c "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=\"agent --server https://192.168.56.1:6443 --token $NODE_TOKEN --flannel-iface eth1\" sh -s -"`

- Sur box03 -> `vagrant ssh box03 -c "curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=\"agent --server https://192.168.56.1:6443 --token $NODE_TOKEN --flannel-iface eth1\" sh -s -"`

---

> Sur le PC de formation (Ubuntu)

- `mkdir /home/formation/.kube/ && sudo cp /etc/rancher/k3s/k3s.yaml /home/formation/.kube/config  && sudo chown $USER:$USER /home/formation/.kube/config`

- `k get node,svc,pod -A`

- `helm list -A`

