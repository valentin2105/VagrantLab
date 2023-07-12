# VagrantLab

> #### This lab provide a Docker-ready multi-VM environment for Docker-Swarm and Kubernetes (k3s)

## Useful commands

- `vagrant up` launch the lab (you can modify nodes on `Vagrantfile`)

- `vagrant ssh box01` ssh to box01 from VagrantFolder

- `vagrant ssh-config > vagrant-ssh` fetch vagrant repo's ssh config

- `ssh -F vagrant-ssh box01` ssh to box01

- `vagrant destroy -f` destroy all lab

- `CMD="docker ps" && for i in box01 box02 ; do vagrant ssh $i -- sudo $CMD ;done` 

Launch command on each box
