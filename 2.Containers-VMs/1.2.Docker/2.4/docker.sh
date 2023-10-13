#!/bin/bash
set -euo pipefail

# 1.Set up Docker's Apt repository.
sudo apt update && sudo apt install ca-certificates curl gnupg lsb-release -y
sudo mkdir -m 0755 -p /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o docker.gpg
sudo mv docker.gpg /etc/apt/keyrings/docker.gpg
sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee docker.list
sudo mv docker.list /etc/apt/sources.list.d/docker.list
sudo apt-get update

# 2.Install the Docker packages.
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo systemctl enable docker
sudo usermod -aG docker ${USER}

# 3.Install docker-compose
sudo curl -SL https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64 -o /usr/bin/docker-compose
sudo chmod 777 /usr/bin/docker-compose

docker compose version
docker version