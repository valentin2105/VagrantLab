# TP Netpol / Hubble

```
cd k8s/niveau2

kubectl create -f hubble.yml
```

Go to : http://hubble.k8s.local

```

HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
HUBBLE_ARCH=amd64; [ "$(uname -m)" = "aarch64" ] && HUBBLE_ARCH=arm64
curl -L --fail --remote-name-all \
  https://github.com/cilium/hubble/releases/download/${HUBBLE_VERSION}/hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}
sha256sum --check hubble-linux-${HUBBLE_ARCH}.tar.gz.sha256sum
sudo tar xzvfC hubble-linux-${HUBBLE_ARCH}.tar.gz /usr/local/bin
rm hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}
hubble version


kubectl -n kube-system port-forward svc/hubble-relay 4245:80 


hubble observe --from-namespace ingress-nginx --to-namespace demo -f

CTRL+C

kubectl apply -f L7-netpol.yml

hubble observe --from-namespace ingress-nginx --to-namespace demo -f

```



