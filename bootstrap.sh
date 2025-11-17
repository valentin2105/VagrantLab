#!/bin/bash

echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
echo "nameserver 1.1.1.1" | sudo tee -a /etc/resolv.conf

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get -y install ca-certificates curl gnupg open-iscsi git conntrackd conntrack nfs-common
sudo apt-get -y upgrade
sudo systemctl start iscsid
sudo install -m 0755 -d /etc/apt/keyrings
sudo apt-get -y autoremove

mkdir -p /etc/rancher/k3s
cat <<EOF >>/etc/rancher/k3s/registries.yaml
mirrors:
  docker.io:
    endpoint:
      - "https://reg.ntl.nc/v2/proxy/"
EOF

cat >>/etc/hosts <<'EOF'
192.168.56.10  box01
192.168.56.20  box02
192.168.56.30  box03
192.168.56.40  box04
192.168.56.50 nfs-server
EOF

swapoff -a

sed -ri 's/^\s*([^#].*\s+swap\s+)/#\1/' /etc/fstab
sudo sed -i '/^127\.0\.2\.1\s\+box/d' /etc/hosts

####################
# KubeADM Part
####################
sudo tee /etc/modules-load.d/k8s.conf <<'EOF'
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/99-kubernetes-cri.conf <<'EOF'
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
EOF

sudo sysctl --system


sudo apt-get update
sudo apt-get install -y containerd containernetworking-plugins

# Génère un config par défaut puis passe en SystemdCgroup
sudo mkdir -p /etc/containerd
sudo containerd config default | tee /etc/containerd/config.toml >/dev/null

sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo sed -i 's#sandbox_image = ".*pause:.*"#sandbox_image = "registry.k8s.io/pause:3.10.1"#'   /etc/containerd/config.toml

sudo sed -i '/\[plugins\."io.containerd.grpc.v1.cri"\.registry\]/,/\[/ s#^\(\s*config_path = \).*#\1"/etc/containerd/certs.d"#' /etc/containerd/config.toml
sudo mkdir -p /etc/containerd/certs.d/docker.io

sudo tee /etc/containerd/certs.d/docker.io/hosts.toml >/dev/null <<'EOF'
server = "https://registry-1.docker.io"
# Use Harbor Proxy Cache under a sub-path; treat that path as the API base
[host."https://reg.ntl.nc/v2/proxy"]
  capabilities = ["pull", "resolve"]
  override_path = true
EOF

sudo systemctl daemon-reload
sudo systemctl enable containerd
sudo systemctl restart containerd

sudo cat >/etc/crictl.yaml <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
EOF

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key \
  | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable kubelet
####################


####################
## Install Docker ##
####################
#curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
#sudo chmod a+r /etc/apt/keyrings/docker.gpg
#echo \
#  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
#  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
#  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#sudo apt-get update
#sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin  || exit 1
#sudo docker ps
