# GlusterFS Vagrant / Kubernetes

## sur box01

- `vagrant ssh box01`

- `sudo su`

```
echo "192.168.56.10 box01" | tee -a /etc/hosts
echo "192.168.56.20 box02" | tee -a /etc/hosts
```

- `apt-get -y install glusterfs-server`

- `systemctl start glusterd`

- `systemctl enable glusterd`

- `mkdir -p /gluster/volume01`

## sur box02

- `vagrant ssh box02`

- `sudo su`

```
echo "192.168.56.10 box01" | tee -a /etc/hosts
echo "192.168.56.20 box02" | tee -a /etc/hosts
```

- `apt-get -y install glusterfs-server`

- `systemctl start glusterd`

- `systemctl enable glusterd`

- `gluster peer probe box01`

- `gluster pool list`

- `mkdir -p /gluster/volume01`

- `gluster volume create vol01 replica 2 box01:/gluster/volume01 box02:/gluster/volume01 force`

- `gluster volume start vol01`

- `gluster volume status vol01`

- `echo 'localhost:/vol01 /mnt glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0' >> /etc/fstab`

- `mount.glusterfs localhost:/vol01 /mnt`

- `mkdir -p /mnt/supersite.localhost/db_data`

- `mkdir -p /mnt/supersite.localhost/wp_data`

## sur box01

- `echo 'localhost:/vol01 /mnt glusterfs defaults,_netdev,backupvolfile-server=localhost 0 0' >> /etc/fstab`

- `mount.glusterfs localhost:/vol01 /mnt`


## sur le PC de Formation

- `sudo su`

- `apt-get -y install haproxy`

- `cp haproxy.cfg /etc/haproxy/haproxy.cfg`

- `systemctl start haproxy && systemctl enable haproxy`


> stats is available at http://supersite.localhost:8000/

On désactive le schedule sur le master
