#!/bin/bash
sudo apt update 
sudo apt install nginx -y

sudo rm -f /etc/nginx/sites-available/default
mkdir /var/cache/nginx

cat > default <<EOT

log_format main '\$http_x_forwarded_for - "\$host" [\$time_local] "\$request" \$status "\$http_user_agent"';   

server {
    listen *:8080 default_server;
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    server_name _;
            
    location / {
            try_files \$uri \$uri/ =404;
    }
    
    access_log /var/log/nginx/backend.access.log main; 
}

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

sudo cp default /etc/nginx/sites-available/default
sudo nginx -t # tests configuration before apply changes
sudo systemctl reload nginx # applies conf.changes
alias ngt='sudo nginx -t'
alias ngr="sudo systemctl reload nginx"

# Crontab
echo "0 0 1 * * sudo find /tmp -type f -size +5M -and -ctime +14 | xargs /bin/rm -f" | crontab -

# Install Minikube
sudo apt update
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v1.23.2/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
sudo apt install conntrack docker.io -y

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

sudo helm repo add bitnami https://charts.bitnami.com/bitnami
sudo helm install wordpress bitnami/wordpress --version 18.1.14

# to hide nginx version 
sudo sed -i 's/# server_tokens off;/server_tokens off;/' /etc/nginx/nginx.conf
sudo systemctl restart nginx













