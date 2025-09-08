# Molecule

cd 01-simple-pkgs/

ansible-lint 

sudo usermod -aG docker formation
newgrp docker

sudo apt install -y python3 python3-pip pipx
pipx install molecule
pipx inject molecule "molecule-plugins[docker]"
ansible-galaxy collection install -p ./collections ansible.posix community.docker --force

molecule create
molecule converge
molecule verify
molecule destroy
