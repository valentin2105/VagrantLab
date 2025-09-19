# KubeVirt


## 1) Installer K3s

```bash
curl -sfL https://get.k3s.io | sh -
sudo mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl get nodes
kubectl get pods -A
```

([Medium][1])

## 2) Installer KubeVirt (Operator + CR)

```bash
export VERSION=$(curl -s https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)
echo $VERSION

kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-operator.yaml
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/kubevirt-cr.yaml

kubectl get all -n kubevirt
```

([Medium][1])

## 3) Installer KubeVirt-Manager (Web UI)

```bash
kubectl apply -f https://raw.githubusercontent.com/kubevirt-manager/kubevirt-manager/main/kubernetes/bundled.yaml

kubectl -n kubevirt-manager get svc
kubectl -n kubevirt-manager edit svc kubevirt-manager   # change "type: ClusterIP" -> "LoadBalancer"
kubectl -n kubevirt-manager get svc kubevirt-manager -o wide
```

([Medium][1])

## 4) (Optionnel) Installer `virtctl`

```bash
VERSION=$(kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o=jsonpath="{.status.observedKubeVirtVersion}")
ARCH=$(uname -s | tr A-Z a-z)-$(uname -m | sed 's/x86_64/amd64/')
curl -L -o virtctl https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/virtctl-${VERSION}-${ARCH}
chmod +x virtctl && sudo install virtctl /usr/local/bin/virtctl
virtctl version
```

([Medium][1])

## 5) Déployer une VM de test

```bash
kubectl create namespace vm
kubectl -n vm apply -f https://kubevirt.io/labs/manifests/vm.yaml
kubectl -n vm get vm
kubectl -n vm patch virtualmachine testvm --type merge -p '{"spec":{"running":true}}'
kubectl -n vm get vmis
```

([Medium][1])

## 6) (Optionnel) Accès UI

```bash
# Remplace l'EXTERNAL-IP ci-dessous par celui du Service LoadBalancer
kubectl -n kubevirt-manager get svc kubevirt-manager -o jsonpath='{.status.loadBalancer.ingress[0].ip}{"\n"}'
# Puis ouvre http://EXTERNAL-IP:8080
```

([Medium][1])

---

C’est tout.

[1]: https://medium.com/%40contact_44117/how-to-set-up-kubevirt-on-k3s-single-node-118c5bd8022b "How to Set Up KubeVirt on K3s (Single Node) | by Sohaib Khan | Medium"
[2]: https://kubevirt.io/quickstart_cloud/?utm_source=chatgpt.com "Labs - KubeVirt quickstart with cloud providers"
