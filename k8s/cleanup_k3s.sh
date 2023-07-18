#!/bin/bash

systemctl stop k3s
systemctl disable k3s
systemctl daemon-reload
rm -f /etc/systemd/system/k3s.service

if [ -e /sys/fs/cgroup/systemd/system.slice/k3s.service/cgroup.procs ]; then
    kill -9 `cat /sys/fs/cgroup/systemd/system.slice/k3s.service/cgroup.procs`
fi
umount `cat /proc/self/mounts | awk '{print $2}' | grep '^/run/k3s'`
umount `cat /proc/self/mounts | awk '{print $2}' | grep '^/var/lib/rancher/k3s'`

rm -rf /var/lib/rancher/k3s
rm -rf /etc/rancher/k3s

