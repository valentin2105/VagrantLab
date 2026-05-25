# TP — Gateway API avec Envoy Gateway

**Formation Kubernetes niveau 2**

## Objectifs pédagogiques

À la fin de ce TP, le stagiaire saura :

1. Installer un contrôleur Gateway API (Envoy Gateway) via Helm
2. Exposer le data plane Envoy via le même mécanisme L2 announcer Cilium que l'Ingress NGINX existant
3. Déployer une application et la router avec une `HTTPRoute`
4. Comparer concrètement Gateway API et Ingress sur un cas réel

## Pré-requis

- Cluster Kubernetes 1.32 → 1.35 (Envoy Gateway v1.8 ne supporte pas au-delà)
- Cilium installé avec L2 announcements activé (`l2announcements.enabled=true`, `externalIPs.enabled=true`)
- Un `CiliumLoadBalancerIPPool` et une `CiliumL2AnnouncementPolicy` déjà en place (ceux qui servent déjà l'Ingress NGINX)
- Ingress NGINX déjà exposé en `LoadBalancer` avec `loadBalancerClass: io.cilium/l2-announcer` (point de départ du TP)
- `helm` et `kubectl` configurés

> **Note de version.** Au moment de la rédaction, la dernière stable est **Envoy Gateway v1.8.0** : elle embarque Envoy Proxy v1.38.0 et la Gateway API v1.5.1, supporte Kubernetes 1.32 à 1.35, et est maintenue jusqu'au 08/11/2026. Adaptez si vous utilisez une autre version.

---

## Partie 0 — Rappel : l'existant (Ingress NGINX)

Pour situer le point de départ, voici comment l'Ingress NGINX est exposé dans notre cluster :

```bash
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx --create-namespace \
  --set controller.service.type=LoadBalancer \
  --set controller.service.loadBalancerClass="io.cilium/l2-announcer" \
  --set controller.service.externalTrafficPolicy=Cluster
```

Ici, **le contrôleur lui-même** porte le Service `LoadBalancer`. C'est NGINX qui demande une IP via Cilium L2.

Vérification :

```bash
kubectl -n ingress-nginx get svc ingress-nginx-controller
# On note l'EXTERNAL-IP attribuée par Cilium (ex: 192.168.56.240)
```

> **Point d'attention architectural à transmettre aux stagiaires.** Avec Envoy Gateway, le modèle est différent : on ne pose **pas** le `loadBalancerClass` sur le Helm value du contrôleur. Envoy Gateway crée **dynamiquement** un déploiement Envoy *par Gateway*, chacun avec son propre Service `LoadBalancer`. On configure donc l'exposition L2 via une ressource `EnvoyProxy` rattachée à la `GatewayClass`. C'est précisément l'une des différences de fond entre Ingress et Gateway API (séparation des responsabilités) que ce TP met en évidence.

---

## Partie 1 — Installer Envoy Gateway

### 1.1 Installation Helm

```bash
helm install envoy-gateway oci://docker.io/envoyproxy/gateway-helm \
  --version v1.8.0 \
  -n envoy-gateway-system --create-namespace

# Attendre que le contrôleur soit prêt
kubectl wait --timeout=5m -n envoy-gateway-system \
  deployment/envoy-gateway --for=condition=Available
```

L'installation pose aussi les CRD Gateway API (GatewayClass, Gateway, HTTPRoute, etc.). On peut le vérifier :

```bash
kubectl get crd | grep gateway
```

### 1.2 Configurer l'exposition L2 via une ressource `EnvoyProxy`

C'est l'étape clé. On crée une `EnvoyProxy` qui force le Service du data plane en `LoadBalancer` avec le `loadBalancerClass` Cilium, à l'image de l'Ingress NGINX.

```yaml
# envoyproxy-l2.yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: EnvoyProxy
metadata:
  name: cilium-l2
  namespace: envoy-gateway-system
spec:
  provider:
    type: Kubernetes
    kubernetes:
      envoyService:
        type: LoadBalancer
        loadBalancerClass: io.cilium/l2-announcer
        externalTrafficPolicy: Cluster
```

```bash
kubectl apply -f envoyproxy-l2.yaml
```

### 1.3 Créer la `GatewayClass` qui référence cette `EnvoyProxy`

```yaml
# gatewayclass.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: envoy
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
  parametersRef:
    group: gateway.envoyproxy.io
    kind: EnvoyProxy
    name: cilium-l2
    namespace: envoy-gateway-system
```

```bash
kubectl apply -f gatewayclass.yaml
kubectl get gatewayclass envoy
# La colonne ACCEPTED doit passer à True
```

---

## Partie 2 — Déployer les deux applications

On déploie deux petites apps. La première servira à montrer le routing par chemin, la seconde le routing par hôte (ou un second chemin).

```yaml
# apps.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-nginx
  labels: { app: hello-nginx }
spec:
  replicas: 1
  selector:
    matchLabels: { app: hello-nginx }
  template:
    metadata:
      labels: { app: hello-nginx }
    spec:
      containers:
        - name: nginx
          image: nginxdemos/nginx-hello:plain-text
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: hello-nginx
spec:
  selector: { app: hello-nginx }
  ports:
    - port: 80
      targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo-app
  labels: { app: echo-app }
spec:
  replicas: 1
  selector:
    matchLabels: { app: echo-app }
  template:
    metadata:
      labels: { app: echo-app }
    spec:
      containers:
        - name: echo
          image: ealen/echo-server:latest
          ports:
            - containerPort: 80
          env:
            - name: PORT
              value: "80"
---
apiVersion: v1
kind: Service
metadata:
  name: echo-app
spec:
  selector: { app: echo-app }
  ports:
    - port: 80
      targetPort: 80
```

```bash
kubectl apply -f apps.yaml
kubectl rollout status deploy/hello-nginx
kubectl rollout status deploy/echo-app
```

- `nginxdemos/nginx-hello` renvoie en texte brut le nom du pod, l'IP, l'URI — parfait pour visualiser quel backend répond.
- `ealen/echo-server` renvoie un JSON avec tous les en-têtes de la requête — utile pour montrer ce que Gateway API injecte.

---

## Partie 3 — Créer la Gateway et les routes

### 3.1 La `Gateway`

```yaml
# gateway.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: demo-gateway
spec:
  gatewayClassName: envoy
  listeners:
    - name: http
      protocol: HTTP
      port: 80
      allowedRoutes:
        namespaces:
          from: Same
```

```bash
kubectl apply -f gateway.yaml
```

Au moment de l'apply, Envoy Gateway crée le déploiement Envoy correspondant **et** son Service `LoadBalancer`, qui va demander une IP à Cilium via le L2 announcer.

```bash
# Le Service du data plane est créé dans le namespace du contrôleur,
# avec un nom dérivé de la Gateway
kubectl -n envoy-gateway-system get svc \
  -l gateway.envoyproxy.io/owning-gateway-name=demo-gateway

# Récupérer l'IP attribuée par Cilium
kubectl get gateway demo-gateway \
  -o jsonpath='{.status.addresses[0].value}'; echo
```

Stockez l'IP dans une variable pour la suite :

```bash
GW_IP=$(kubectl get gateway demo-gateway -o jsonpath='{.status.addresses[0].value}')
echo "Gateway IP = $GW_IP"
```

### 3.2 Routing par chemin (`HTTPRoute`)

On route `/hello` vers nginx et `/echo` vers echo-server, sur la même Gateway.

```yaml
# routes.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: hello-route
spec:
  parentRefs:
    - name: demo-gateway
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /hello
      filters:
        - type: URLRewrite
          urlRewrite:
            path:
              type: ReplacePrefixMatch
              replacePrefixMatch: /
      backendRefs:
        - name: hello-nginx
          port: 80
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: echo-route
spec:
  parentRefs:
    - name: demo-gateway
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /echo
      filters:
        - type: URLRewrite
          urlRewrite:
            path:
              type: ReplacePrefixMatch
              replacePrefixMatch: /
      backendRefs:
        - name: echo-app
          port: 80
```

```bash
kubectl apply -f routes.yaml
kubectl get httproute
# La colonne des parents doit montrer la Gateway et un statut Accepted
```

### 3.3 Test

```bash
# nginx hello world
curl -s http://$GW_IP/hello
# -> texte brut : Server name, pod, URI...

# echo server
curl -s http://$GW_IP/echo | jq .
# -> JSON avec les en-têtes vus par le backend
```

---

## Partie 4 — Aller plus loin (démo des capacités natives)

C'est ici qu'on montre ce qu'Ingress ne fait pas sans annotations propriétaires.

### 4.1 Split de trafic pondéré (canary) — natif

On scale echo-app à deux "versions" pour illustrer. En pratique on créerait deux Services ; ici on montre la syntaxe du poids :

```yaml
# canary.yaml — extrait à fusionner dans une HTTPRoute
rules:
  - matches:
      - path: { type: PathPrefix, value: /echo }
    backendRefs:
      - name: echo-app
        port: 80
        weight: 90
      - name: echo-app-v2   # un second Service à créer
        port: 80
        weight: 10
```

Le **poids** (`weight`) est un champ standard de l'API. Avec Ingress NGINX, le canary passe par des annotations `nginx.ingress.kubernetes.io/canary-*` propres au contrôleur.

### 4.2 Manipulation d'en-têtes — native

```yaml
filters:
  - type: RequestHeaderModifier
    requestHeaderModifier:
      add:
        - name: X-TP-Demo
          value: gateway-api
```

Relancer `curl http://$GW_IP/echo | jq .request.headers` : on voit l'en-tête ajouté par la Gateway, pas par l'application.

---

## Partie 5 — Nettoyage

```bash
kubectl delete -f routes.yaml -f gateway.yaml -f apps.yaml
kubectl delete -f gatewayclass.yaml -f envoyproxy-l2.yaml
helm uninstall envoy-gateway -n envoy-gateway-system
kubectl delete ns envoy-gateway-system
```

---

## Synthèse — Gateway API vs Ingress

### Le problème que résout Gateway API

L'Ingress API est restée volontairement minimale : elle gère essentiellement le routage HTTP(S) par hôte et par chemin. Tout le reste — réécriture d'URL, canary, CORS, timeouts, rate limiting, gRPC, TCP/UDP — a dû être ajouté par chaque contrôleur sous forme **d'annotations propriétaires**. Résultat : un Ingress écrit pour NGINX n'est pas portable vers Traefik, HAProxy ou Envoy, et les annotations ne sont ni typées ni validées par l'API server.

### Tableau comparatif

| Aspect | Ingress | Gateway API |
|---|---|---|
| **Objet** | Une seule ressource `Ingress` | Plusieurs ressources : `GatewayClass`, `Gateway`, `HTTPRoute`, `TCPRoute`, `GRPCRoute`… |
| **Séparation des rôles** | Tout mélangé dans un objet | L'admin infra gère `GatewayClass`/`Gateway`, les devs gèrent les `*Route` |
| **Fonctions avancées** | Annotations propriétaires non portables | Champs standardisés et typés (poids, filtres, en-têtes, réécriture) |
| **Protocoles** | HTTP/HTTPS uniquement | HTTP, HTTPS, TCP, UDP, TLS, gRPC |
| **Cross-namespace** | Non (route et service même namespace) | Oui, via `ReferenceGrant` explicite |
| **Validation** | Annotations = chaînes libres | CRD typées, validées à l'`apply` |
| **Portabilité** | Liée au contrôleur | Même YAML d'un contrôleur conforme à l'autre |
| **Statut du projet** | Figé (maintenance) | API officielle qui succède à Ingress |

### Les trois idées à retenir pour les stagiaires

1. **Séparation des responsabilités.** `GatewayClass` et `Gateway` sont du ressort de l'équipe plateforme ; les `HTTPRoute` appartiennent aux équipes applicatives. Un dev peut publier une route sans toucher à l'infra réseau ni demander une modification du contrôleur. C'est le modèle "infra/app" qui n'existe pas avec Ingress.

2. **Le standard remplace les annotations.** Ce qui demandait des annotations spécifiques au contrôleur (canary, réécriture, en-têtes) devient des **champs typés et validés** de l'API. Le YAML devient portable entre contrôleurs conformes (Envoy Gateway, Cilium lui-même, Istio, Traefik, Contour…).

3. **Au-delà du HTTP.** Gateway API gère nativement TCP, UDP, TLS et gRPC, là où Ingress se limite au HTTP(S). C'est ce qui en fait la base des service meshes (projet GAMMA) et des passerelles modernes.

### Le mot de la fin

Gateway API n'est pas "un meilleur Ingress" : c'est un **modèle de ressources** pensé pour exprimer le routage de façon portable, typée et partagée entre équipes. Ingress reste parfaitement valable pour un routage HTTP simple, mais dès qu'on a besoin de fonctions avancées, de plusieurs protocoles ou d'une vraie séparation des rôles, Gateway API est la voie standard recommandée.
