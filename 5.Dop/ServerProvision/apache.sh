#!/bin/bash
sudo dnf update -y

# Install apache
sudo dnf install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

sudo sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf 
sudo echo "Hello world" > /var/www/html/index.html   
sudo systemctl restart httpd

# Install nginx
sudo dnf install nginx -y

mkdir -p /var/cache/nginx 

cat > proxy.conf <<EOT

proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=utm_source:10m inactive=120s max_size=100m; 

server{
    add_header X-Proxy-Cache \$upstream_cache_status;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header Host \$host;
    
    listen *:80;

    location / {       
        proxy_pass http://localhost:8080;     
        proxy_cache utm_source;      
        proxy_cache_valid 200 302 301 10m;
        proxy_cache_valid 404      1m; 
    }
}
EOT

sudo cp proxy.conf /etc/nginx/conf.d/proxy.conf
sudo nginx -t
sudo systemctl start nginx
sudo systemctl enable nginx
nginx -v

alias ngt='sudo nginx -t'
alias ngr="sudo systemctl reload nginx"

# custom logging apache
sudo sed -i 's/"%h/"\\\"%{X-Forwarded-For}i\\" \\"%{Host}i\\"/' /etc/httpd/conf/httpd.conf

# setting crontab
sudo yum install cronie -y
sudo systemctl enable crond.service
sudo systemctl start crond.service
echo "0 0 1 * * sudo find /tmp -type f -size +5M -and -ctime +14 | xargs /bin/rm -f" | crontab -

# Install Minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v1.23.2/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
sudo dnf install conntrack docker -y

# Install kubectl
curl -LO https://dl.k8s.io/release/`curl -LS https://dl.k8s.io/release/stable.txt`/bin/linux/amd64/kubectl && chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/kubectl

# Install Helm
curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz > helm.tar.gz
tar xzvf helm.tar.gz
sudo mv linux-amd64/helm /usr/local/bin 

sudo minikube start --vm-driver=none
sudo kubectl cluster-info
sudo minikube status
alias k='kubectl'
alias h='helm'
alias m='minikube'

# configure bitnami/wordpress with helm 
sudo helm repo add bitnami https://charts.bitnami.com/bitnami
sudo helm install wordpress bitnami/wordpress --version 18.1.14

# to hide nginx version 
sudo sed -i '/main;$/a server_tokens off;' /etc/nginx/nginx.conf
sudo systemctl reload nginx

# to hide apache version
sudo sed -i '$ a\ServerTokens ProductOnly' /etc/httpd/conf/httpd.conf
sudo sed -i '$ a\ServerSignature Off' /etc/httpd/conf/httpd.conf
sudo systemctl restart httpd