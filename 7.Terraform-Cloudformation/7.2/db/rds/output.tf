output "RDS" {
  value = [ aws_db_instance.TF-RDS.address, aws_db_instance.TF-RDS.username, aws_db_instance.TF-RDS.port ]
}

output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.TF-RDS.address
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.TF-RDS.port
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.TF-RDS.username
}