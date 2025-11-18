servers=[
  {
    :hostname => "box01",
    :ip => "192.168.56.10",
    :box => "bento/debian-13",
    :ram => 3072,
    :cpu => 3
  },
  {
    :hostname => "box02",
    :ip => "192.168.56.20",
    :box => "bento/debian-13",
    :ram => 2048,
    :cpu => 2
  },
  {
    :hostname => "box03",
    :ip => "192.168.56.30",
    :box => "bento/debian-13",
    :ram => 2048,
    :cpu => 2
  },
  {
    :hostname => "box04",
    :ip => "192.168.56.40",
    :box => "bento/debian-13",
    :ram => 2048,
    :cpu => 2
  },
#  {
#    :hostname => "nfs-server",
#    :ip => "192.168.56.50",
#    :box => "bento/debian-13",
#    :ram => 1024,
#    :cpu => 1
#  },
]

Vagrant.configure("2") do |config|
  # Évite de re-télécharger systématiquement la box
  config.vm.box_check_update = false

  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box      = machine[:box]
      node.vm.hostname = machine[:hostname]

      # Réseau host-only pour le lab
      node.vm.network "private_network", ip: machine[:ip]

      # Ressources VirtualBox
      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--cpus",   machine[:cpu]]
        vb.customize ["modifyvm", :id, "--memory", machine[:ram]]
      end

      # Provisionnement avec le script bootstrap.sh
      node.vm.provision "shell",
        path: "bootstrap.sh",
        env: { "DEBIAN_FRONTEND" => "noninteractive" }
    end
  end
end
