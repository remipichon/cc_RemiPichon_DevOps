BASE = <<-HEREDOC
echo "welcome !"
HEREDOC

# VM config
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.provision "shell", inline:BASE
  config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  config.vm.synced_folder ".", "/vagrant"
end

# Prepare Docker
Vagrant.configure("2") do |config|
	# blank playbook install Ansible and its role
	config.vm.provision "ansible_local" do |ansible|
		ansible.playbook = "ansible/blank.yml"
			ansible.become = true
      ansible.galaxy_role_file = "ansible/requirements.yml"
      ansible.galaxy_roles_path = "/etc/ansible/roles"
      ansible.galaxy_command = "sudo ansible-galaxy install --role-file=%{role_file} --roles-path=%{roles_path} --force"
	end

 	# install Docker and setup Swarm
	config.vm.provision "ansible_local" do |ansible|
		ansible.playbook = "ansible/install_docker.yml"
	end
	config.vm.provision "ansible_local" do |ansible|
  	ansible.playbook = "ansible/init_swarm.yml"
  end
end

# Deploy Jenkins on Swarm
Vagrant.configure("2") do |config|
	config.vm.provision "ansible_local" do |ansible|
  		ansible.playbook = "ansible/deploy_jenkins.yml"
  end
end

