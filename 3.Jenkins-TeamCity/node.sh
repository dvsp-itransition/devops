#! /bin/bash
sudo apt update 
sudo apt install default-jdk docker.io -y
sudo systemctl enable docker
sudo systemctl start docker

# configure 
sudo chmod 777 /var/run/docker.sock 

# Installs Trivy to scan docker images
wget https://github.com/aquasecurity/trivy/releases/download/v0.41.0/trivy_0.41.0_Linux-64bit.deb
sudo dpkg -i trivy_0.41.0_Linux-64bit.deb