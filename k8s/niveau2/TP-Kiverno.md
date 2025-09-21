# POC Kyverno

```
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
kubectl create ns kyverno
helm upgrade --install kyverno kyverno/kyverno -n kyverno
```

1) Policy “validate” : exiger un label sur les Pods

But : refuser tout Pod sans label owner.

```
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-owner-label
spec:
  validationFailureAction: Enforce
  rules:
  - name: must-have-owner
    match:
      any:
      - resources:
          kinds: ["Pod"]
    validate:
      message: "Label 'owner' est requis"
      pattern:
        metadata:
          labels:
            owner: "?*"
```

Test :
```
# échoue
kubectl run bad --image=nginx:1.27 --restart=Never
# OK
kubectl run good --image=nginx:1.27 --restart=Never -l owner=alice
```

2) Policy “mutate” : durcir par défaut

But : si absent, ajouter runAsNonRoot: true 

```
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: default-seccontext
spec:
  rules:
  - name: add-seccontext
    match:
      any:
      - resources:
          kinds: ["Pod"]
    mutate:
      patchStrategicMerge:
        spec:
          securityContext:
            +(runAsNonRoot): true

```
Test :

kubectl run secure --image=nginx:1.27 --restart=Never -l owner=alice
kubectl get pod secure -o yaml | grep -A4 securityContext

```