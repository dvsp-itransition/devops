#!/bin/bash
set -euo pipefail
sudo apt update && sudo apt -y install docker.io

# install docker-compose
sudo curl -SL https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64 -o /usr/bin/docker-compose
sudo chmod 777 /usr/bin/docker-compose
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker

# configure 
sudo usermod -aG docker $USER
sudo chmod 777 /var/run/docker.sock # to get docker commands in jenkins