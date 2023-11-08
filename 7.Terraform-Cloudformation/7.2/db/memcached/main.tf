resource "aws_elasticache_subnet_group" "TF-memcached-Subnet-Group" {
  name       = "TF-memcached-Subnet-Group"
  subnet_ids = var.private_subnets
}

resource "aws_elasticache_cluster" "TF-memcached" {
  cluster_id           = var.memcached_cluster_id
  engine               = var.memcached_engine
  node_type            = var.memcached_type
  num_cache_nodes      = 1
  parameter_group_name = var.memcached_param_gn
  port                 = var.memcached_port

  subnet_group_name = aws_elasticache_subnet_group.TF-memcached-Subnet-Group.name
  security_group_ids = [ var.sg_memcached_id ]

  tags = {
    Name = "TF-memcached"
  }
}



