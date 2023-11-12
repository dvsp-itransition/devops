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

module "keys" {
  source   = "./keys"
  key_name = var.key_name
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

module "register_targets" {
  source            = "./network/register_targets"
  target_group = module.elb.target_group 
  instance_ids = module.server.instance_ids
}





