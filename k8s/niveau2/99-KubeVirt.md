# 🚀 Installer K3s + KubeVirt + KubeVirt Manager

## 1. Installer K3s

```bash
curl -sfL https://get.k3s.io | sh -
mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl get nodes
```

## 2. Installer KubeVirt

```bash
export VERSION=$(curl -s https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-operator.yaml
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-cr.yaml
kubectl get pods -n kubevirt
```

## 3. Installer KubeVirt Manager (UI)

```bash
kubectl apply -f https://raw.githubusercontent.com/kubevirt-manager/kubevirt-manager/main/kubernetes/bundled.yaml
kubectl -n kubevirt-manager edit svc kubevirt-manager   # mettre type: LoadBalancer
kubectl -n kubevirt-manager get svc kubevirt-manager -o wide
```

## 4. (Optionnel) Installer `virtctl`

```bash
VERSION=$(kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o=jsonpath="{.status.observedKubeVirtVersion}")
ARCH=$(uname -s | tr A-Z a-z)-$(uname -m | sed 's/x86_64/amd64/')
curl -L -o virtctl https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/virtctl-${VERSION}-${ARCH}
chmod +x virtctl && sudo install virtctl /usr/local/bin/virtctl
virtctl version
```

## 5. Déployer une VM de test

```bash
kubectl create ns vm
kubectl -n vm apply -f https://kubevirt.io/labs/manifests/vm.yaml
kubectl -n vm get vm
kubectl -n vm patch virtualmachine testvm --type merge -p '{"spec":{"running":true}}'
kubectl -n vm get vmis
```

## 6. Accéder à l’UI

```bash
kubectl -n kubevirt-manager get svc kubevirt-manager -o jsonpath='{.status.loadBalancer.ingress[0].ip}{"\n"}'
# Ouvrir http://EXTERNAL-IP:8080
```

---
