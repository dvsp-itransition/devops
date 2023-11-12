output "lb_dns_name" {
  value = aws_lb.TF-ELB.dns_name
}

output "target_group" {
  value = aws_lb_target_group.TF-TG
}