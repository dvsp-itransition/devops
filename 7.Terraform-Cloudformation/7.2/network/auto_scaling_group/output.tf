output "launch_template_id" {
  value = aws_launch_template.TF-launch-template.id
}
output "autoscaling_group_id" {
  value = aws_autoscaling_group.TF-ASG.id
}