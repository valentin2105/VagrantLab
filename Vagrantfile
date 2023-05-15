servers=[
  {
    :hostname => "box01",
    :ip => "172.16.16.10",
    :box => "debian/bullseye64",
    :ram => 1024,
    :cpu => 1
  },
  {
    :hostname => "box02",
    :ip => "172.16.16.20",
    :box => "debian/bullseye64",
    :ram => 1024,
    :cpu => 1
  }
]

Vagrant.configure(2) do |config|
    servers.each do |machine|
        config.vm.provision :shell, path: "bootstrap.sh"
        config.vm.define machine[:hostname] do |node|
            node.vm.box = machine[:box]
            node.vm.hostname = machine[:hostname]
            node.vm.network "private_network", ip: machine[:ip]
            node.vm.provider "virtualbox" do |vb|
                vb.customize ["modifyvm", :id, "--cpus", machine[:cpu]]
                vb.customize ["modifyvm", :id, "--memory", machine[:ram]]
                vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
                vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
            end
        end
    end
end

