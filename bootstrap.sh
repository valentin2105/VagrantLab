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
192.168.56.50  box05
192.168.56.60  box06
192.168.56.70  box07
192.168.56.80  box08
192.168.56.100 nfs-server
EOF

swapoff -a

sed -ri 's/^\s*([^#].*\s+swap\s+)/#\1/' /etc/fstab
sudo sed -i '/^127\.0\.2\.1\s\+box/d' /etc/hosts

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
