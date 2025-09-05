# 02-simple-nginx

Inventory list :

`ansible-inventory --graph`

Ping hosts : 

`ansible all -m ping`

Apply playbook : 

`ansible-playbook site.yaml`

Verify : 

`curl http://192.168.56.1` (ou dans votre navigateur http://192.168.56.10)

Show facts : 

`ansible box01 -m setup`

