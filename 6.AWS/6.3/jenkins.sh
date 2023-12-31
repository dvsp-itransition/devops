#!/bin/bash

# 1. installs java, jenkins needs java to run
sudo apt update
sudo apt install fontconfig openjdk-17-jre -y
java -version

# 2. installs jenkins
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins docker.io -y

sudo systemctl enable jenkins
sudo systemctl start jenkins

sudo cat /var/lib/jenkins/secrets/initialAdminPassword




