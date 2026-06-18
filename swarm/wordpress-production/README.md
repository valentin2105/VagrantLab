# GlusterFS Vagrant / Swarm


## box01


- `vagrant ssh box01`

- `sudo su`

- `mkdir -p /gluster/vol01`

## box02

- `vagrant ssh box02`

- `sudo su`

- `mkdir -p /gluster/vol01`


## box03

- `vagrant ssh box03`

- `sudo su`

- `gluster peer probe box01`

- `gluster peer probe box02`

- `gluster pool list`

- `mkdir -p /gluster/vol01`


## box01

- `sudo su`

- `gluster volume create vol01 replica 3 box01:/gluster/vol1 box02:/gluster/vol1 box03:/gluster/vol1 force`

- `gluster volume start vol01`

- `gluster volume status vol01`

- `echo 'localhost:/vol01 /mnt glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0' >> /etc/fstab`

- `mount.glusterfs localhost:/vol01 /mnt`

## box02

- `sudo su`

- `echo 'localhost:/vol01 /mnt glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0' >> /etc/fstab`

- `mount.glusterfs localhost:/vol01 /mnt`

- `mkdir -p /mnt/supersite-localhost/wp_data /mnt/supersite-localhost/db_data`

## box03

- `sudo su`

- `echo 'localhost:/vol01 /mnt glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0' >> /etc/fstab`

- `mount.glusterfs localhost:/vol01 /mnt`


## Exercice : 

- Modifier le docker-compose.yml afin d'exposer le Wordpress avec Traefik sous le nom `supersite.localhost`
- Déployer le Wordpress avec le fichier docker-compose.yml
- Scaler le service WP à 3 replicas
