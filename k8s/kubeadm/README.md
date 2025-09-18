## Installation de KubeADM

### Sur chaque Box

> Preparation

```
sudo su

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
```

> Containerd

```
apt-get update
apt-get install -y containerd containernetworking-plugins

# Génère un config par défaut puis passe en SystemdCgroup
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml >/dev/null

# Bascule en systemd cgroups (ligne [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options])
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sed -i 's#sandbox_image = ".*pause:.*"#sandbox_image = "registry.k8s.io/pause:3.10.1"#'   /etc/containerd/config.toml

systemctl daemon-reload
systemctl enable --now containerd

cat >/etc/crictl.yaml <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
EOF

```

> Kubeadm / Kubelet

```
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key \
  | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' \
  | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
systemctl enable kubelet

```

### Sur Box01 (Master Kubernetes)

> Bootstrap Controle Plane

```
POD_CIDR=10.244.0.0/16

kubeadm init   \
        --apiserver-advertise-address=192.168.56.10   \
        --pod-network-cidr=${POD_CIDR}   \
        --cri-socket unix:///run/containerd/containerd.sock   \
        --skip-phases=addon/kube-proxy

```

> Prepare KubeConfig

``` 
mkdir -p $HOME/.kube
cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
```

> Cilium

```
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
bash get_helm.sh


helm repo add cilium https://helm.cilium.io
helm repo update


helm upgrade --install cilium cilium/cilium -n kube-system --create-namespace \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost=192.168.56.10 \
  --set k8sServicePort=6443 \
  --set routingMode=native \
  --set autoDirectNodeRoutes=true \
  --set ipv4NativeRoutingCIDR=192.168.56.0/24 \
  --set devices="{eth1}" \
  --set ipam.mode=cluster-pool \
  --set ipam.operator.clusterPoolIPv4PodCIDRList="{10.244.0.0/16}" \
  --set l2announcements.enabled=true \
  --set externalIPs.enabled=true \
  --set hubble.enabled=true \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set cni.binPath=/usr/lib/cni



kubectl -n kube-system rollout status ds/cilium
kubectl -n kube-system exec ds/cilium -- cilium status

# CoreDNS should come up now
kubectl -n kube-system get pods -l k8s-app=kube-dns


```

> Get node registration token

```
kubeadm token create --print-join-command
```


### Sur Box02,03,04

```
sudo su 
kubeadm join 192.168.56.10:6443 --token ..... (previous output)

```
