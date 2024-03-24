## k3s

- `sudo apt-get update && sudo apt-get -y install open-iscsi`

- `sudo systemctl start iscsid`

- `cd /home/formation/ && echo "alias k=kubectl" >> .bashrc && source .bashrc`

- `wget https://dl.k8s.io/release/v1.28.7/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/`

- `wget https://get.helm.sh/helm-v3.14.3-linux-amd64.tar.gz && tar -zxvf helm-v3.14.3-linux-amd64.tar.gz && sudo mv linux-amd64/helm /usr/local/bin/`

- `sudo mkdir /home/formation/.kube && sudo cp /etc/rancher/k3s/k3s.yaml /home/formation/.kube/config  && sudo chown formation:formation /home/formation/.kube/config`

- `k get node,svc,pod -A`

- `helm list -A`



