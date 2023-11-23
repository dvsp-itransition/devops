variable "vpc_igw" {}
variable "subnet" { type = list }
variable "vpc_id" {}

locals {
  public_subnets = concat([aws_subnet.dev-subnet[0].id, aws_subnet.dev-subnet[1].id]) # list/massiv
}

