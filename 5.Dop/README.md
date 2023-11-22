### Практические задания - категория Nginx/Apache
1. Создать виртуальную машину, установить nginx. Настроить в nginx кэш по
условиям: кэшировать только те запросы, где есть utm_source=
2. Создать виртуальную машину, установить apache web server. Настроить в apache
кэш по условиям: кэшировать только те запросы, где есть utm_source=. Можно
использовать mod_lua, mod_cache, mod_disk_cache, mod_alias и другие модули.
3. Изменить конфигурации apache и nginx: запустить их на порту 8080. Установить
дополнительный nginx (можно virtualhost, в случае, когда nginx будет бэком) на
порту 80 и настроить на нем reverse proxy. Настройка логгирования на бэк веб
серверах, чтобы отображались x-forwarded-for, server hostname в логах серверов.
4. Добавить в cron задачу, которая будет находить и удалять файлы в папке /tmp, с
даты создания которых прошло больше 14 дней и размер которых больше 5 Мб.
5. Установить Minikube, Helm. Установить bitnami/wordpress helm chart. При помощи
wappalyzer посмотреть, какие технологии используются. Сделать скриншот вывода
и залить его в репозиторий. Скриншот должен выглядеть примерно так:
6. Скрыть версии apache, nginx, php на серверах, используемых для выполнения
заданий. Поставить расширение Wappalyzer для Chrome, проверить информацию
по версиям. Сделать скриншоты до скрытия версий и после. Залить их в
репозиторий или ClickUp. Пример скриншота:

### Решение

Подготовил терраформ модуль, который создает nginx и apache серверов и добавил скрипт в provisioner файл который автоматический устанавливает nginx, apache веб серверов 
и меняет им порты, настраивает nginx reverse proxy для них и остальные задачи в заданья, делает деплой helm, minikube, kubectl, bitnami/wordpress

nano main.tf
```
provider "aws" {
  region = "us-east-2"
}

variable "myhosts" {
  type = map(any)
  default = {
    nginx = {
      type = "t2.medium"
      scriptfile = "nginx.sh"
      key        = "ubuntu"
      ssh_user = "ubuntu"
    }
    apache = {
      type       = "t2.medium"
      scriptfile = "apache.sh"
      key        = "amazon2023"
      ssh_user   = "ec2-user"
    }
  }
}

module "sec_group" {
  source = "./modules/sec_group"
  my_ip  = "89.236.248.170/32"
}

module "server" {
  for_each   = var.myhosts
  servername = each.key
  type       = each.value.type
  scriptfile = each.value.scriptfile
  key        = each.value.key
  ssh_user   = each.value.ssh_user
  keyfile    = "dvsp"
  source     = "./modules/instance"
  sec_gr     = module.sec_group.web_sg
  volumesize = "8"
}
```

Скрипт nginx сервера, ОС ubuntu

nano nginx.sh
```
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

# install kubectl
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
```

Скрипт apache сервера, ОС amazon linux 

nano apache.sh
```
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

# to hide nginx versions 
sudo sed -i '/main;$/a server_tokens off;' /etc/nginx/nginx.conf
sudo systemctl reload nginx

# to hide apache versions 
sudo sed -i '$ a\ServerTokens ProductOnly' /etc/httpd/conf/httpd.conf
sudo sed -i '$ a\ServerSignature Off' /etc/httpd/conf/httpd.conf
sudo systemctl restart httpd
```

#### Инициализация проекта, проверяем конфигурацию и запускаем 
```
terraform init
terraform validate
terraform fmt
terraform plan
terraform apply --auto-approve
```

## Результаты

![k_nginx.PNG](img%2Fk_nginx.PNG)

![k_apache.PNG](img%2Fk_apache.PNG)

![t_apply_apache.PNG](img%2Ft_apply_apache.PNG)

![t_apply.PNG](img%2Ft_apply.PNG)

![t_state_list.PNG](img%2Ft_state_list.PNG)

![servers.PNG](img%2Fservers.PNG)

#### Nginx машина

![kc_nginx.PNG](img%2Fkc_nginx.PNG)

![th_nginx.PNG](img%2Fth_nginx.PNG)

После скрытия версий

![ah_nginx.PNG](img%2Fah_nginx.PNG)

#### Apache машина

![kc_apache.PNG](img%2Fkc_apache.PNG)

![th_apache.PNG](img%2Fth_apache.PNG)

После скрытия версий

![ah_apache.PNG](img%2Fah_apache.PNG)