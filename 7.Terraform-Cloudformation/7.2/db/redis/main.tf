resource "aws_elasticache_subnet_group" "TF-REDIS-Subnet-Group" {
  name       = "TF-REDIS-Subnet-Group"
  subnet_ids = var.private_subnets
}

resource "aws_elasticache_cluster" "TF-REDIS" {
  cluster_id           = var.redis_cluster_id
  engine               = var.redis_engine
  node_type            = var.redis_type
  num_cache_nodes      = 1
  parameter_group_name = var.redis_param_gn
  engine_version       = var.redis_engine_version
  port                 = var.redis_port

  subnet_group_name = aws_elasticache_subnet_group.TF-REDIS-Subnet-Group.name
  security_group_ids = [ var.sg_redis_id ]

  tags = {
    Name = "TF-REDIS"
  }
}


