#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get -y install ca-certificates curl gnupg open-iscsi git conntrackd conntrack
sudo apt-get -y dist-upgrade

sudo systemctl start iscsid

#sudo install -m 0755 -d /etc/apt/keyrings
#curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
#sudo chmod a+r /etc/apt/keyrings/docker.gpg
#echo \
#  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
#  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
#  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


#sudo apt-get update
#sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin  || exit 1
mkdir -p /etc/rancher/k3s

cat <<EOF >>/etc/rancher/k3s/registries.yaml
mirrors:
  docker.io:
    endpoint:
      - "https://reg.ntl.nc/v2/proxy/"
EOF

sudo apt-get -y autoremove

wget https://github.com/k3s-io/k3s/releases/download/v1.27.3%2Bk3s1/k3s -q --show-progress
chmod +x k3s && sudo mv k3s /usr/local/bin/ 

echo "nameserver 8.8.8.8" | sudo tee    /etc/resolv.conf
echo "nameserver 1.1.1.1" | sudo tee -a /etc/resolv.conf

#sudo docker ps
