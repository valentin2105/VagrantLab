servers=[
  {
    :hostname => "box01",
    :ip => "192.168.56.10",
    :box => "debian/bookworm64",
    :ram => 2048,
    :cpu => 2
  },
  {
    :hostname => "box02",
    :ip => "192.168.56.20",
    :box => "debian/bookworm64",
    :ram => 2048,
    :cpu => 2
  }
]

Vagrant.configure(2) do |config|
    config.vm.provision :shell, path: "bootstrap.sh"
    servers.each do |machine|

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

