## Docker Swarm

- `docker swarm init --advertise-addr 192.168.56.1` init a swarm cluster on your local machine

- `vagrant ssh box01 -- sudo docker swarm join --token ${TOKEN} 192.168.56.1:2377` register your first box in the swarm

- `docker service create --name whoami --constraint node.role==worker -p 8080:80 reg.ntl.nc/library/whoami:latest ` 

- `docker service scale whoami=10` scale your deployment to 10 replicas

https://docs.docker.com/engine/swarm/stack-deploy/

