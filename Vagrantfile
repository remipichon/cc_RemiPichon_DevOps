BASE = <<-HEREDOC
echo "hello world"
HEREDOC

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.provision "shell", inline:BASE
end