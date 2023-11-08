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



