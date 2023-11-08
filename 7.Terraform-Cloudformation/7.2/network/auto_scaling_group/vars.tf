variable "private_subnets" {}
variable "public_subnets" {}
variable "key_name" {}
variable "type" {}
variable "key" {}
variable "ami" { type = map(any) }
variable "sg_web_id" {}
variable "resource_type" {}
variable "size" { type = map(any) }
variable "threshold_out" {}
variable "threshold_in" {}
