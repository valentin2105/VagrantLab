# 03-docker-recipe

Inventory list :

`ansible-inventory --graph`

Ping hosts : 

`ansible all -m ping`

Get Docker collection : 

`ansible-galaxy collection install community.docker`

Apply playbook : 

`ansible-playbook site.yaml`

Verify : 

http://192.168.56.20:8080
