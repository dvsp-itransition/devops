output "sg_web_id" {
  value = aws_security_group.dev-sg.id
}
output "sg_elb_id" {
  value = aws_security_group.ELB-SG-TF.id
}
