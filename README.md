# VagrantLab

> #### This lab provide a Docker-ready multi-VM environment for Swarm / k8s / Salt 

## Useful commands

- `vagrant up` launch the lab (you can modify nodes on `Vagrantfile`)

- `vagrant status | awk 'BEGIN{ tog=0; } /^$/{ tog=!tog; } /./ { if(tog){print $1} }' | xargs -P2 -I {} vagrant up {}` launch the lab simultaneously

- `vagrant ssh-config > vagrant-ssh` fetch vagrant repo's ssh config

- `ssh -F vagrant-ssh box01` ssh to box01

- `vagrant destroy -f` destroy all lab

## Docker Swarm

- `docker swarm init --advertise-addr 172.16.16.1` init a swarm cluster on your local machine

- `vagrant ssh box01 -- sudo docker swarm join --token ${TOKEN} 172.16.16.1:2377` register your first box in the swarm

- `docker service create --name web -p 80:80 nginx:stable-alpine` create a nginx service in your cluster

- `docker service scale web=3` scale your deployment to 3 replicas

## k3s

- `wget https://github.com/k3s-io/k3s/releases/download/v1.27.1%2Bk3s1/k3s` download k3s locally 

- `chmod +x k3s && mv k3s /usr/local/bin/` k3s executable and in PATH

- `sudo k3s server &` launch k3s server

- `vagrant ssh box01 -- sudo k3s agent --server https://172.16.16.1:6443 --token ${NODE_TOKEN}`  add a node on the cluster

> `NODE_TOKEN` comes from `/var/lib/rancher/k3s/server/node-token` on your server

- `sudo k3s kubectl get node,svc,pod -A`

