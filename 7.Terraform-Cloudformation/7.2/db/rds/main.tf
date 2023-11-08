resource "aws_db_subnet_group" "TF-RDS-Subnet-Group" {
  name       = "rds-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "TF-RDS-Subnet-Group"
  }
}

resource "aws_db_instance" "TF-RDS" {
  db_name = "RDS"
  instance_class         = var.rds_type
  allocated_storage      = var.rds_storage
  engine                 = var.rds_engine
  engine_version         = var.rds_engine_version
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.TF-RDS-Subnet-Group.id
  vpc_security_group_ids = [ var.sg_rds_id ]
  skip_final_snapshot    = true

  tags = {
    Name = "TF-RDS"
  }
}

