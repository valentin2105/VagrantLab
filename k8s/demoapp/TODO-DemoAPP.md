# Todo

`sudo apt-get install buildah`


```
buildah login reg.ntl.nc

buildah build -t reg.ntl.nc/formation/VOTRENOM:latest  .

buildah push  reg.ntl.nc/formation/VOTRENOM:latest
```

> Ensuite -> Déployer :  AVEC les YAML dans un sous dossier k8s/

DANS LE NAMESPACE "demoapp"  :   `kubectl create namespace demoapp`

- 1 Deployment pour demoapp (image -> celle que vous venez de builder)
- 1 Service pour votre demoapp
- 1 Ingress pour votre demoapp (demoapp.localhost)

--- 

- 1 Deployment pour Redis (image : reg.ntl.nc/proxy/library/redis:latest) 
- 1 Service Pour Redis (port 6379)
