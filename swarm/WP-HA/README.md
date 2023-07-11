# GlusterFS Vagrant / Swarm

## Global

- `vagrant ssh box01 / box02`

- `sudo nano /etc/hosts`

```
127.0.0.1  localhost

192.168.56.10 box01
192.168.56.20 box02
```

## box01

- `vagrant ssh box01`

- `sudo su`

- `apt-get -y install glusterfs-server`

- `systemctl start glusterd`

- `systemctl enable glusterd`


> Exit 

## box02

- `vagrant ssh box02`

- `sudo su`

- `apt-get -y install glusterfs-server`

- `systemctl start glusterd`

- `systemctl enable glusterd`

- `gluster peer probe box01`

- `gluster pool list`

- `mkdir -p /gluster/vol01`

> Exit 

## box01

- `mkdir -p /gluster/vol01`

- `sudo gluster volume create vol01 replica 2 box01:/gluster/vol1 box02:/gluster/vol1 force`

- `gluster volume start vol01`

- `gluster volume status vol01`

- `echo 'localhost:/vol01 /mnt glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0' >> /etc/fstab`

- `mount.glusterfs localhost:/vol01 /mnt`
> Exit 

## box02

- `echo 'localhost:/vol01 /mnt glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0' >> /etc/fstab`

- `mount.glusterfs localhost:/vol01 /mnt`


