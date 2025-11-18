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


############################################
# Containerd
############################################
apt-get update
apt-get install -y containerd containernetworking-plugins

mkdir -p /etc/containerd
containerd config default >/etc/containerd/config.toml

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sed -i 's#sandbox_image = ".*pause:.*"#sandbox_image = "registry.k8s.io/pause:3.10.1"#' /etc/containerd/config.toml

sed -i '/\[plugins\."io.containerd.grpc.v1.cri"\.registry\]/,/\[/ s#^\(\s*config_path = \).*#\1"/etc/containerd/certs.d"#' /etc/containerd/config.toml

mkdir -p /etc/containerd/certs.d/docker.io

tee /etc/containerd/certs.d/docker.io/hosts.toml <<'EOF'
server = "https://registry-1.docker.io"
[host."https://reg.ntl.nc/v2/proxy"]
  capabilities = ["pull", "resolve"]
  override_path = true
EOF

systemctl daemon-reload
systemctl enable containerd
systemctl restart containerd

cat >/etc/crictl.yaml <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
EOF


############################################
# Kubernetes repo + installation
############################################
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key \
  | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' \
  >/etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
systemctl enable kubelet

