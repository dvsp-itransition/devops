output "sg_web_id" {
  value = aws_security_group.tf-web-SG.id
}
output "sg_elb_id" {
  value = aws_security_group.ELB-SG-TF.id
}
output "sg_rds_id" {
  value = aws_security_group.TF-RDS-SG.id
}
output "sg_redis_id" {
  value = aws_security_group.TF-Redis-SG.id
}
output "sg_memcached_id" {
  value = aws_security_group.TF-Memcached-SG.id
}