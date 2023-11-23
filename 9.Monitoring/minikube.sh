#!/bin/bash

# Install docker
sudo apt update && sudo apt -y install docker.io

# install kubectl
curl -LO https://dl.k8s.io/release/`curl -LS https://dl.k8s.io/release/stable.txt`/bin/linux/amd64/kubectl && chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/kubectl

# install minikube 
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v1.23.2/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
sudo apt install conntrack

# install helm
curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz > helm.tar.gz
tar xzvf helm.tar.gz
mv linux-amd64/helm /usr/local/bin
alias k=kubectl

# minikube start --vm-driver=none
# kubectl cluster-info
# minikube status
# minikube ip
# minikube stop
# minikube delete