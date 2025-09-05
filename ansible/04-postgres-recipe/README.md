# 04-postgres

Inventory list :

`ansible-inventory --graph`

Ping hosts : 

`ansible all -m ping`

Get Postgres collection : 

`ansible-galaxy collection install community.postgresql`

Create the Vault : 

`ansible-vault create group_vars/dbservers/vault.yml`

Put that in it : 

```
vault_postgres_root_password: "S3cureRoot!"
vault_postgres_app_password: "S3cureApp!"
```

Apply playbook : 

`ansible-playbook site.yaml --ask-vault-pass`

Verify : 

`psql "host=192.168.56.20 port=5432 dbname=app01 user=app01 password=S3cureApp!"`

Without password to type : 

- Add this to ansible.cfg : 

`vault_password_file = ./.vault_pass.txt`

Launch that : 

```
echo 'MySuperSecretVaultPass' > .vault_pass.txt
chmod 600 .vault_pass.txt
```


You can now launch : 

`ansible-playbook site.yaml`
