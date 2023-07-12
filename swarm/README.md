## Docker Swarm

- `docker swarm init --advertise-addr 172.16.16.1` init a swarm cluster on your local machine

- `vagrant ssh box01 -- sudo docker swarm join --token ${TOKEN} 172.16.16.1:2377` register your first box in the swarm

- `docker service create --name web -p 8080:80 nginx:stable-alpine` create a nginx service in your cluster

- `docker service scale web=3` scale your deployment to 3 replicas

https://docs.docker.com/engine/swarm/stack-deploy/

