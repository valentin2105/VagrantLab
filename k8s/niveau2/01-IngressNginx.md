## Deploy Ingress Nginx

```
cat <<'EOF' | kubectl apply -f -
apiVersion: "cilium.io/v2"
kind: CiliumLoadBalancerIPPool
metadata:
  name: lb-pool-56
spec:
  blocks:
  - start: "192.168.56.200"
    stop:  "192.168.56.230"
---
apiVersion: "cilium.io/v2alpha1"
kind: CiliumL2AnnouncementPolicy
metadata:
  name: l2-lb-workers
spec:
  # annonce les IPs de Services type LoadBalancer
  loadBalancerIPs: true
  # pas d'annonce depuis le control-plane
  nodeSelector:
    matchExpressions:
    - key: node-role.kubernetes.io/control-plane
      operator: DoesNotExist
  # annonce uniquement sur l'interface host-only (ADAPTE le regex si besoin)
  interfaces:
  - ^enp0s8$
EOF
```


```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.type=LoadBalancer \
  --set controller.service.loadBalancerClass="io.cilium/l2-announcer" \
  --set controller.service.externalTrafficPolicy=Cluster




## Wait a little bit

kubectl -n ingress-nginx get pod -o wide
kubectl -n ingress-nginx get svc ingress-nginx-controller




# namespace & app
kubectl create ns demo
kubectl -n demo create deploy echo --image=ealen/echo-server:latest --replicas=2
kubectl -n demo expose deploy echo --port=80 --target-port=80

# Ingress (host: demo.local)
cat <<'EOF' | kubectl -n demo apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: echo
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: demo-site.k8s.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: echo
            port:
              number: 80
EOF

```

## Sur votre machine Ubuntu :

```
sudo ip route add 192.168.56.200/32 via 192.168.56.10

curl -v 192.168.56.200

echo "192.168.56.200 demo-site.k8s.local" | sudo tee -a /etc/hosts

sudo apt install jq

curl http://demo-site.k8s.local/ | jq 
```



