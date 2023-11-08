# vpc & internet gateway
output "vpc" {
  value = module.vpc.vpc
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

# subnets
output "public_subnets-ids" {
  value = module.subnets.public_subnets
}

output "private_subnets-ids" {
  value = module.subnets.private_subnets
}

# routes
output "route_id" {
  value = module.route.route_id
}

# nat gateway
output "NatGW-ids" {
  value = module.nat-gateway.NatGW-ids
}
output "elastic-ips" {
  value = module.nat-gateway.elastic-ips
}

# security groups
output "sg_web_id" {
  value = module.security_groups.sg_web_id
}

output "sg_rds_id" {
  value = module.security_groups.sg_rds_id
}

output "sg_elb_id" {
  value = module.security_groups.sg_elb_id
}

output "sg_memcached_id" {
  value = module.security_groups.sg_memcached_id
}

output "sg_redis_id" {
  value = module.security_groups.sg_redis_id
}

# ACL

output "private_acl_id" {
  value = module.acl.private_acl_id
}

# auto scaling group
output "launch_template_id" {
  value = module.asg.launch_template_id
}

output "autoscaling_group_id" {
  value = module.asg.autoscaling_group_id
}

# load balancer
output "elb_dns_name" {
  value = module.elb.lb_dns_name
}

# rds
output "RDS-INFO" {
  value = module.rds.RDS
}

# redis
output "REDIS-INFO" {
  value = module.redis.redis
}

# memcached
output "MEMCACHED-INFO" {
  value = module.memcached.memcached
}