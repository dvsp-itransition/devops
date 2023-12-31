## Практические задания:

### Подготовить шаблон Terraform для автоматизации создания ресурсов, знакомство с которыми было в части «Основы AWS».

### Установка terraform

nano terraform.sh
```
#!/bin/bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt-get install terraform -y

# installs AWS Cli:
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y && unzip awscliv2.zip
sudo ./aws/install --bin-dir /usr/bin --install-dir /usr/bin/aws-cli --update 
```

#### Настраиваем AWS Access/Secret Keys
```
aws configure # creates ~/.aws/credentials file
```

#### terraform workflow
```
terraform init
terraform validate
terraform fmt
terraform plan
terraform apply --auto-approve
terraform show
terraform state list
terraform destroy
terraform.exe destroy --target aws_instance.tf-nginx1 # specific resource
```
 
#### Сделал terraform модулей для создания всех ресурсов из 1 части

#### Структура

![struc.PNG](img%2Fstruc.PNG)

### main файл

```
provider "aws" {
  region = "us-east-2"
}

# creates vpc 
module "vpc" {
  source = "./network/vpc"
  vpc    = var.VPC
}

module "subnets" {
  source  = "./network/subnets"
  vpc_id  = module.vpc.vpc_id
  subnet  = var.subnet
  vpc_igw = module.vpc.vpc_gateway_id
}

module "route" {
  source          = "./network/route"
  vpc_id          = module.vpc.vpc_id
  vpc_gateway_id  = module.vpc.vpc_gateway_id
  public_subnets  = module.subnets.public_subnets
  private_subnets = module.subnets.private_subnets
}

module "nat-gateway" {
  source          = "./network/nat_gateway"
  private_subnets = module.subnets.private_subnets
  public_subnets  = module.subnets.public_subnets
  vpc_id          = module.vpc.vpc_id
  vpc_gateway_id  = module.vpc.vpc_gateway_id
}

module "keys" {
  source   = "./keys"
  key_name = var.key_name
}

module "security_groups" {
  source          = "./network/sec_group"
  vpc_id          = module.vpc.vpc_id
  my_ip           = var.my_ip
  subnet          = var.subnet
  private_subnets = module.subnets.private_subnets
  public_subnets  = module.subnets.public_subnets
}

# creates access contol lists
module "acl" {
  source          = "./network/access_control_list"
  vpc_id          = module.vpc.vpc_id
  subnet          = var.subnet
  private_subnets = module.subnets.private_subnets
  public_subnets  = module.subnets.public_subnets
}

# creates Auto Scaling Groups
module "asg" {
  source          = "./network/auto_scaling_group"
  key_name        = var.key_name
  type            = var.type
  key             = var.key
  ami             = var.ami
  sg_web_id       = module.security_groups.sg_web_id
  resource_type   = var.resource_type
  size            = var.size
  public_subnets  = module.subnets.public_subnets
  private_subnets = module.subnets.private_subnets
  threshold_out   = var.threshold_out
  threshold_in    = var.threshold_in
}

# creates Load Balancer
module "elb" {
  source                 = "./network/load_balancer"
  vpc_id                 = module.vpc.vpc_id
  port                   = var.port
  protocol               = var.protocol
  health_check_path      = var.health_check_path
  autoscaling_group_name = module.asg.autoscaling_group_id
  elb_type               = var.elb_type
  sg_elb_id              = module.security_groups.sg_elb_id
  public_subnets         = module.subnets.public_subnets
  private_subnets        = module.subnets.private_subnets
  elb_action_type        = var.elb_action_type
}

module "rds" {
  source             = "./db/rds"
  public_subnets     = module.subnets.public_subnets
  private_subnets    = module.subnets.private_subnets
  rds_type           = var.rds_type
  rds_engine         = var.rds_engine
  rds_engine_version = var.rds_engine_version
  sg_rds_id          = module.security_groups.sg_rds_id
  rds_storage        = var.rds_storage
  db_password        = var.db_password
  db_username        = var.db_username
}

module "redis" {
  source               = "./db/redis"
  public_subnets       = module.subnets.public_subnets
  private_subnets      = module.subnets.private_subnets
  sg_redis_id          = module.security_groups.sg_redis_id
  redis_cluster_id     = var.redis_cluster_id
  redis_engine         = var.redis_engine
  redis_type           = var.redis_type
  redis_param_gn       = var.redis_param_gn
  redis_engine_version = var.redis_engine_version
  redis_port           = var.redis_port
}

module "memcached" {
  source               = "./db/memcached"
  public_subnets       = module.subnets.public_subnets
  private_subnets      = module.subnets.private_subnets
  sg_memcached_id      = module.security_groups.sg_memcached_id
  memcached_cluster_id = var.memcached_cluster_id
  memcached_engine     = var.memcached_engine
  memcached_type       = var.memcached_type
  memcached_param_gn   = var.memcached_param_gn
  memcached_port       = var.memcached_port
}
```

### Инициализируем проект, проверяем конфигурацию и запускаем деплой
```
terraform init
terraform validate
terraform fmt
terraform plan
terraform apply --auto-approve
```

![rs_create.PNG](img%2Frs_create.PNG)

## Результат

![all_list.PNG](img%2Fall_list.PNG)

![sxema_vpc.PNG](img%2Fsxema_vpc.PNG)

### Создан 2 Nginx сервера через auto scaling group

![servers.PNG](img%2Fservers.PNG)

![asg.PNG](img%2Fasg.PNG)

![asg_policy.PNG](img%2Fasg_policy.PNG)

### Установлен Load balancer и Target Group

![tg.PNG](img%2Ftg.PNG)

![lb.PNG](img%2Flb.PNG)

![lb_link.PNG](img%2Flb_link.PNG)

### Установлен RDS, Redis и Memcache

![rds.PNG](img%2Frds.PNG)

![redis.PNG](img%2Fredis.PNG)

![memcached.PNG](img%2Fmemcached.PNG)

### Проверка подключения к rds, redis и memcache с 2 серверов  
```
psql -h terraform-20231108162147270700000004.c2nqsqdeccby.us-east-2.rds.amazonaws.com -U postgres
exit
redis-cli -h redis.qrib4s.0001.use2.cache.amazonaws.com -p 6379
exit
telnet memcached.qrib4s.0001.use2.cache.amazonaws.com 11211
quit
```
### Nginx 1

![nginx1.PNG](img%2Fnginx1.PNG)

### Nginx 2

![nginx2.PNG](img%2Fnginx2.PNG)

### Сработало scale in policy 

![scale_in_worked.PNG](img%2Fscale_in_worked.PNG)

![scale_in_worked_2.PNG](img%2Fscale_in_worked_2.PNG)

![scale_in_worked_3.PNG](img%2Fscale_in_worked_3.PNG)

### Переводим state файл в s3 backet, для lock state используем сервиса dynamodb

```
terraform{
  backend "s3" {
    bucket = "dvsp-tf-state-s3-backet" # state file in s3 bucket
    key = "terraform.tfstate"
    region = "us-east-2"        
    dynamodb_table = "dvsp-dynomodb-state-locking" # state lock implementation    
  }
}
```
![state_s3.PNG](img%2Fstate_s3.PNG)

![dynamodb.PNG](img%2Fdynamodb.PNG)







