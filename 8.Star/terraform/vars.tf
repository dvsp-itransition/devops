variable "vpc" {
  default = "10.0.0.0/16"
}

# key-pair
variable "key_name" {
  default = "dev-key"
}

# security groups
variable "my_ip" {
  default = "0.0.0.0/0"
}

variable "subnet" {
  type    = list(any)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

# instance
variable "ami" {
  default = "ami-02aebcd577dfd35d7"
}

variable "type" {
  default = "t2.medium"
}

variable "use_pubip" {
  default = "true"
}

variable "volumeSize" {
  type    = list(number)
  default = [8, 10, 20]
}

variable "servername" {
  default = "lamp"
}

# load balancer listener ports
variable "port" {
  type = map(any)
  default = {
    "Wordpress" = "80"
    "Gatsby" = "8000"
  }      
}

variable "protocol" {
  default = "HTTP"
}
variable "health_check_path" {
  default = "/"
}

variable "elb_type" {
  default = "false"
}

variable "elb_action_type" {
  default = "forward"
}








