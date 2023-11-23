# load balancer
output "elb_dns_name" {
  value = module.elb.lb_dns_name
}

# instance
output "public_ip" {
  value = module.server.public_ip
}




