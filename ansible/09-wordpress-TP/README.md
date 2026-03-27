# TP Ansible — Déploiement WordPress multi-instances

**Niveau :** Intermédiaire | **Durée :** 3 à 4h | **Prérequis :** bases Ansible, Vagrant installé

---

## Architecture

3 VMs Debian (Vagrant) sur un réseau privé :

| VM | IP | Rôle |
|---|---|---|
| `proxy.local` | 192.168.56.10 | Nginx — Reverse Proxy |
| `web.local` | 192.168.56.20 | Apache + PHP + WordPress |
| `db.local` | 192.168.56.30 | MariaDB |

---

## Étape 1 — Mise en place de l'environnement

Modifier `Vagrantfile` qui monte les 3 VMs Debian sur le réseau privé ci-dessus.

**Résultat attendu :** `vagrant up` démarre les 3 machines sans erreur, elles se pingent mutuellement.

---

## Étape 2 — Structure du projet Ansible

Initialiser un projet Ansible avec la structure suivante : un inventaire, des `group_vars`, et un répertoire `roles/`.

**Résultat attendu :** `ansible all -m ping` répond avec `pong` sur les 3 hôtes.

---

## Étape 3 — Rôle `common`

Créer un rôle appliqué à tous les hôtes qui met à jour les paquets APT, installe les utilitaires de base (vim, curl, etc)  et configure le fichier `/etc/hosts` avec les noms des 3 VMs.

**Résultat attendu :** chaque VM résout `proxy.local`, `web.local` et `db.local` par nom.

---

## Étape 4 — Rôle `mariadb`

Créer un rôle qui installe MariaDB, sécurise le compte root et crée, pour chaque instance WordPress définie dans les variables, une base de données et un utilisateur dédié avec les droits suffisants.

Les mots de passe doivent être stockés dans un fichier chiffré avec `ansible-vault`.

**Résultat attendu :** depuis `web.local`, une connexion MySQL avec chaque utilisateur créé aboutit.

---

## Étape 5 — Rôle `apache_php`

Créer un rôle qui installe Apache2 et PHP avec les extensions nécessaires à WordPress, et active les modules Apache requis.

Sois via https://galaxy.ansible.com/geerlingguy/apache/
Sois via des files / templates

---

## Étape 6 — Rôle `wordpress`

Créer un rôle qui, pour chaque instance définie dans les variables :

- télécharge WordPress depuis l'URL officielle (`wordpress.org/latest.zip`)
- le déploie dans un sous-répertoire dédié sur `web.local`
- génère un `wp-config.php` à partir d'un template Jinja2 avec les bonnes variables de connexion

Le rôle doit être **idempotent** : un second passage ne redéploie pas si le site existe déjà.

**Résultat attendu :** la page d'installation WordPress s'affiche pour chaque site via l'IP de `web.local`.

---

## Étape 7 — Rôle `nginx_proxy`

Créer un rôle qui installe Nginx et génère dynamiquement un virtual host par instance WordPress, en se basant sur la liste définie dans les variables. Chaque virtual host proxifie vers le bon sous-répertoire Apache.

**Résultat attendu :** en ajoutant les domaines dans `/etc/hosts` du poste hôte, `http://site1.local` et `http://site2.local` affichent chacun leur page d'installation WordPress.

Sois via https://galaxy.ansible.com/geerlingguy/nginx/
Sois via des files / templates

---

## Étape 8 — Multi-instances

Ajouter un troisième WordPress (`site3.local`) en ne modifiant **qu'un seul fichier** de variables, puis relancer le playbook.

**Résultat attendu :** `site3.local` est accessible sans aucune autre modification du code Ansible. Les deux sites précédents restent fonctionnels.

---

## Critères d'évaluation

| Critère | Points |
|---|:---:|
| Structure du projet (rôles, inventaire, vault) | 3 |
| 3 VMs opérationnelles | 2 |
| MariaDB : bases et utilisateurs créés | 3 |
| Apache + PHP fonctionnel | 2 |
| WordPress déployé depuis le ZIP | 4 |
| Nginx : virtual hosts dynamiques | 3 |
| 3e site ajouté sans modifier les rôles | 2 |
| Idempotence (0 `changed` au 2e passage) | 1 |
| **Total** | **20** |

