# ArgoCD

```
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
kubectl create ns argocd


helm upgrade --install argocd argo/argo-cd -n argocd \
  --set configs.params."server\.insecure"=true \
  --set server.ingress.enabled=true \
  --set server.ingress.ingressClassName=nginx \
  --set server.ingress.hostname=argocd.k8s.localhost



kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d; echo


echo "192.168.56.200 argocd.k8s.localhost" | sudo tee -a /etc/hosts

```
```
```

https://argocd.k8s.localhost

