
## Раздел со звездочкой: сборка сайтов в AWS

## Задача

1. Задачи должны выполняться на Centos или Amazon Linux
2. Необходимо разобраться с установкой Apache + PHP 7.3 + MySQL + NPM, если получится - автоматизировать этот процесс (достаточно все оформить в bash, ansible)
3. Зарегистрировать бесплатную учетную запись в AWS 
4. Разобраться со стоимостью сервисов в AWS и все дальнейшие действия делать только на бесплатном окружении!
5. Создать новый Инстанс, автоматически установить на нем софт из п.2, сохранить как AMI и удалить.
6. Используя Cloudformation или Terraform:
   - Запустить инстанс, с предустановленным ПО из AMI из п.5.
   - Создать Application load balancer, добавить маршрутизацию на сервер из п.5
   - Входные параметры Cloudformation/Terraform:
     - Размер инстанса (выпадающий список)
     - SSH Ключ
     - Использование публичного IP адреса (true/false)
     - VPC, где будет размещен инстанс
     - Имя инстанса, которое будет задано как тег Name.
   - Выходные параметры:
     - Публичный IP инстанса
     - DNS, полученный в Load Balancer
7. На сервере сделать два сайта (через виртуальную директорию, или через хосты - на усмотрение)
   - 1й сайт: установить самый Wordpress без дополнительной конфигурации
   - 2й сайт: установить статический сайт https://github.com/gatsbyjs/gatsby-starter-hello-world
   - Оба сайта должны работать через балансировщик

В качестве успешно выполненного задания необходимо показать:
   - Скрипт по конфигурированию сервере (установке необходимого софта из п.2) – bash или playbook
   - Шаблон cloudformation для разворачивания окружения
   - Сайт на WP
   - Сайт на gatsby

## Решение

- В качестве образа выбрал дистрибутива Amazon Linux 2023
- Сделал bash скрипт, который автоматизирует установку нашего lamp стека

nano lamp.sh

```
#!/bin/bash

db_root_password="admin123"

# Installs LAMP stack on Amazon Linux 2023
sudo dnf update -y
sudo dnf install httpd wget php-fpm php-mysqli php-gd php-json php php-devel php-mysqlnd mariadb105-server -y

sudo systemctl start httpd
sudo systemctl enable httpd

sudo systemctl start mariadb            
sudo systemctl enable mariadb

sudo usermod -a -G apache $USER 
sudo chown -R $USER:apache /var/www 
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \; 
find /var/www -type f -exec sudo chmod 0664 {} \;

# Secures the database server
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${db_root_password}'"; # update root password
sudo mysql -u root -p${db_root_password} -e "DELETE FROM mysql.global_priv WHERE User='';" # remove_anonymous_users
sudo mysql -u root -p${db_root_password} -e "DELETE FROM mysql.global_priv WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');" # remove_remote_root
sudo mysql -u root -p${db_root_password} -e "DROP DATABASE IF EXISTS test;" # remove_test_database
sudo mysql -u root -p${db_root_password} -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
sudo mysql -u root -p${db_root_password} -e "FLUSH PRIVILEGES;" # Make our changes take effect

# Installs npm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash 
. ~/.nvm/nvm.sh 
nvm install 20 
```

#### Необходимые софты установлены и сохранил AMI образ

![ami.PNG](img%2Fami.PNG)

### Сделал модулей для создания сетей, серверов и других необходимых сервисов

```
provider "aws" {
  region = "us-east-2"
}

module "vpc" {
  source = "./network/vpc"
  vpc    = var.vpc
}

module "subnets" {
  source  = "./network/subnets"
  vpc_id  = module.vpc.vpc_id
  subnet  = var.subnet
  vpc_igw = module.vpc.vpc_gateway_id
}

module "route" {
  source         = "./network/route"
  vpc_id         = module.vpc.vpc_id
  vpc_gateway_id = module.vpc.vpc_gateway_id
  public_subnets = module.subnets.public_subnets
}

module "security_groups" {
  source         = "./network/sec_group"
  vpc_id         = module.vpc.vpc_id
  my_ip          = var.my_ip
  subnet         = var.subnet
  public_subnets = module.subnets.public_subnets
}

module "server" {
  source     = "./instance"
  subnet_id  = module.subnets.public_subnets
  sg_id      = module.security_groups.sg_web_id
  key_name   = var.key_name
  ami        = var.ami
  type       = var.type
  use_pubip  = var.use_pubip
  volumeSize = var.volumeSize[0]
  servername = var.servername
}

module "elb" {
  source            = "./network/load_balancer"
  vpc_id            = module.vpc.vpc_id
  port              = var.port
  protocol          = var.protocol
  health_check_path = var.health_check_path
  elb_type          = var.elb_type
  elb_action_type   = var.elb_action_type
  sg_elb_id         = module.security_groups.sg_elb_id
  public_subnets    = module.subnets.public_subnets
}

```
### Инициализируем проект и запускаем
```
terraform init
terraform validate
terraform plan
terraform apply --auto-approve
```
![vpc_output.PNG](img%2Fvpc_output.PNG)

![state_list.PNG](img%2Fstate_list.PNG)

![vpc.PNG](img%2Fvpc.PNG)

![instance.PNG](img%2Finstance.PNG)

### Деплой wordpress

```
wget https://wordpress.org/latest.tar.gz && tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/
```

#### Базовые настройки mysql server и wordpress

```
mysql -u root -p
CREATE USER 'wordpress'@'localhost' IDENTIFIED BY 'admin123';
CREATE DATABASE `wordpress`;
GRANT ALL PRIVILEGES ON `wordpress`.* TO "wordpress"@"localhost";
FLUSH PRIVILEGES;
exit

cd /var/www/html/
cp wp-config-sample.php wp-config.php

nano wp-config.php
define('DB_NAME', 'wordpress');
define('DB_USER', 'wordpress');
define('DB_PASSWORD', 'admin123');
```

### Деплой gatsby

```
cd ~
npm install -g gatsby-cli
dnf install git -y
gatsby new my-hello-world-starter https://github.com/gatsbyjs/gatsby-starter-hello-world
cd my-hello-world-starter/
gatsby develop --host=0.0.0.0
```

### Модуль для регистра инстансов

```
module "register_targets" {
  source            = "./network/register_targets"
  target_group = module.elb.target_group 
  instance_ids = module.server.instance_ids
}
```

### Инициализация и запуск
```
terraform init
terraform apply
```

![registr.PNG](img%2Fregistr.PNG)

![lb.PNG](img%2Flb.PNG)

![tg.PNG](img%2Ftg.PNG)

![gatsby.PNG](img%2Fgatsby.PNG)

![wp.PNG](img%2Fwp.PNG)

## Результаты:

![output.PNG](img%2Foutput.PNG)

![wp_site.PNG](img%2Fwp_site.PNG)

![gatsby_site.PNG](img%2Fgatsby_site.PNG)



