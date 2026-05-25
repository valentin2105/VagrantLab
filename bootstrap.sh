#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

############################################
# DNS
############################################
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf


############################################
# Packages de base
############################################
apt-get update
apt-get install -y ca-certificates curl gnupg open-iscsi git conntrackd conntrack nfs-common

apt-get -y -o Dpkg::Options::="--force-confdef" \
            -o Dpkg::Options::="--force-confold" upgrade

systemctl start iscsid
install -m 0755 -d /etc/apt/keyrings
apt-get -y autoremove


############################################
# K3s registry mirror
############################################
mkdir -p /etc/rancher/k3s
cat <<EOF >/etc/rancher/k3s/registries.yaml
mirrors:
  docker.io:
    endpoint:
      - "https://reg.ntl.nc/v2/proxy/"
EOF


############################################
# Hosts
############################################
cat >>/etc/hosts <<'EOF'
192.168.56.10  box01
192.168.56.20  box02
192.168.56.30  box03
192.168.56.40  box04
192.168.56.50  nfs-server
EOF

sed -i '/^127\.0\.2\.1\s\+box/d' /etc/hosts


############################################
# Désactivation du swap
############################################
swapoff -a
sed -ri 's/^\s*([^#].*\s+swap\s+)/#\1/' /etc/fstab


############################################
# KubeADM – Préparation système
############################################
tee /etc/modules-load.d/k8s.conf <<'EOF'
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

tee /etc/sysctl.d/99-kubernetes-cri.conf <<'EOF'
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
EOF

sysctl --system

