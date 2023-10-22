#! /bin/bash
sudo apt update 
sudo apt install default-jdk  maven docker.io -y
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker

# Installs Trivy to scan docker images
wget https://github.com/aquasecurity/trivy/releases/download/v0.41.0/trivy_0.41.0_Linux-64bit.deb
sudo dpkg -i trivy_0.41.0_Linux-64bit.deb