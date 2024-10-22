# GlusterFS Vagrant / Swarm

## Sur chaque box

- `vagrant ssh box01 / box02`

- `sudo vim /etc/hosts`

```
192.168.56.10 box01
192.168.56.20 box02
```

## box01

- `vagrant ssh box01`

- `sudo su`

- `apt-get -y install glusterfs-server`

- `systemctl start glusterd`

- `systemctl enable glusterd`

- `mkdir -p /gluster/vol01`

## box02

- `vagrant ssh box02`

- `sudo su`

- `apt-get -y install glusterfs-server`

- `systemctl start glusterd`

- `systemctl enable glusterd`

- `gluster peer probe box01`

- `gluster pool list`

- `mkdir -p /gluster/vol01`


## box01

- `sudo gluster volume create vol01 replica 2 box01:/gluster/vol1 box02:/gluster/vol1 force`

- `gluster volume start vol01`

- `gluster volume status vol01`

- `echo 'localhost:/vol01 /mnt glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0' >> /etc/fstab`

- `mount.glusterfs localhost:/vol01 /mnt`

## box02

- `echo 'localhost:/vol01 /mnt glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0' >> /etc/fstab`

- `mount.glusterfs localhost:/vol01 /mnt`

- `mkdir -p /mnt/supersite-localhost/wp_data /mnt/supersite-localhost/db_data`


## PC Formation

- `sudo su`

- `apt-get -y install haproxy`

- `cp haproxy.cfg /etc/haproxy/haproxy.cfg`

- `systemctl start haproxy && systemctl enable haproxy`

- `echo "127.0.0.1 supersite.localhost" >> /etc/hosts`


> stats is available at http://supersite.localhost:8000/
