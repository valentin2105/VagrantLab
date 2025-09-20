# Monitoring k8s

## MetricServer 

```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl -n kube-system patch deploy metrics-server --type=json -p='[
  {"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"},
  {"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-preferred-address-types=InternalIP,Hostname,InternalDNS,ExternalIP,ExternalDNS"}
]'

kubectl -n kube-system rollout status deploy/metrics-server
kubectl top nodes
kubectl top pods -A
```

## Grafana / Prometheus

```
kubectl create namespace monitoring

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update


helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --set grafana.service.type=ClusterIP \
  --set grafana.ingress.enabled=true \
  --set grafana.ingress.ingressClassName=nginx \
  --set grafana.ingress.hosts[0]=grafana.k8s.local \
  --set prometheus.ingress.enabled=true \
  --set prometheus.ingress.ingressClassName=nginx \
  --set prometheus.ingress.hosts[0]=prometheus.k8s.local \
  --set alertmanager.ingress.enabled=true \
  --set alertmanager.ingress.ingressClassName=nginx \
  --set alertmanager.ingress.hosts[0]=alertmanager.k8s.local



  echo "192.168.56.200 grafana.k8s.local prometheus.k8s.local alertmanager.k8s.local" | sudo tee -a /etc/hosts
```


http://grafana.k8s.local

Add this Dashboard : https://grafana.com/grafana/dashboards/15661-k8s-dashboard-en-20250125/