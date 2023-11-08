variable "VPC" {
  default = "192.168.0.0/16"
}

# key-pair
variable "key_name" {
  default = "TF-key"
}

# security groups
variable "my_ip" {
  default = "93.170.165.94/32"
}

variable "subnet" {
  type = map(any)
  default = {
    "pub_az1"  = "192.168.1.0/24"
    "priv_az1" = "192.168.2.0/24"
    "pub_az2"  = "192.168.3.0/24"
    "priv_az2" = "192.168.4.0/24"
  }
}

# auto scaling group
variable "type" {
  default = "t2.micro"
}

variable "key" {
  default = "ubuntu"
}

variable "ami" {
  type = map(any)
  default = {
    "ubuntu" = "ami-06c4532923d4ba1ec"
    "amazon" = "ami-092b51d9008adea15"
  }
}

variable "resource_type" {
  default = "instance"
}

variable "size" {
  type = map(any)
  default = {
    "min"     = "1"
    "desired" = "2"
    "max"     = "4"
  }
}

variable "threshold_out" {
  default = "75"
}

variable "threshold_in" {
  default = "15"
}

# load balancer
variable "port" {
  default = 80
}
variable "protocol" {
  default = "HTTP"
}
variable "health_check_path" {
  default = "/index.html"
}

variable "elb_type" {
  default = "false"
}

variable "elb_action_type" {
  default = "forward"
}

# rds
variable "rds_type" {
  default = "db.t3.micro"
}

variable "rds_engine" {
  default = "postgres"
}

variable "rds_engine_version" {
  default = "14.3"
}

variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
  default     = "postgres"
}

variable "db_username" {
  default = "postgres"
}

variable "rds_storage" {
  default = 20
}

# redis
variable "redis_cluster_id" {
  default = "redis"
}
variable "redis_engine" {
  default = "redis"
}
variable "redis_type" {
  default = "cache.t2.micro"
}
variable "redis_param_gn" {
  default = "default.redis7"
}
variable "redis_engine_version" {
  default = "7.0"
}
variable "redis_port" {
  default = "6379"
}

# memcached
variable "memcached_cluster_id" {
  default = "memcached"
}
variable "memcached_engine" {
  default = "memcached"
}
variable "memcached_type" {
  default = "cache.t3.micro"
}
variable "memcached_param_gn" {
  default = "default.memcached1.6"
}
variable "memcached_port" {
  default = 11211
}

