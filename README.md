# VagrantLab


## Useful commands

- `vagrant ssh-config > vagrant-ssh` fetch vagrant repo's ssh config

- `ssh -F vagrant-ssh box01` ssh to box01

- `vagrant destroy -f` destroy all lab


## K3s

- `wget https://github.com/k3s-io/k3s/releases/download/v1.27.1%2Bk3s1/k3s` download k3s locally 

- `chmod +x k3s && mv k3s /usr/local/bin/` k3s executable and in PATH

- `sudo k3s server &` launch k3s server

- `sudo k3s agent --server https://myserver:6443 --token ${NODE_TOKEN}`  add a node on the cluster

> # NODE_TOKEN comes from /var/lib/rancher/k3s/server/node-token on your server

- `sudo k3s kubectl get node,svc,pod -A`
