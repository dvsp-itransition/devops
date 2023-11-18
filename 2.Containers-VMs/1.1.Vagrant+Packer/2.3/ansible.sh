#!/bin/bash
sudo apt update
sudo apt install ansible -y
rm -f /etc/ansible/ansible.cfg

cat > /etc/ansible/ansible.cfg <<EOT
[defaults]
sudo_user = root
host_key_checking = False
EOT

# creating inventory file
cat > /vagrant/hosts <<HOSTS
web ansible_host=192.168.200.254 ansible_user=vagrant ansible_ssh_private_key_file=/home/vagrant/.ssh/id_rsa
HOSTS






