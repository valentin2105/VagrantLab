# 01-simple-pkgs

Inventory list :

`ansible-inventory --graph`

Ping hosts : 

`ansible all -m ping`

Check diff before apply : 

`ansible-playbook pkgs.yaml --diff --check`

Apply playbook : 

`ansible-playbook pkgs.yaml`

Show facts : 

`ansible box01 -m setup`

