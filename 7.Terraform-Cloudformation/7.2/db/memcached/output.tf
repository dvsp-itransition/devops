output "memcached" {
  value = aws_elasticache_cluster.TF-memcached.cache_nodes
}