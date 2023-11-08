variable "vpc_igw" {}
variable "subnet" {
  type = map(any)
}

variable "vpc_id" {}

locals {
  public_subnets = concat([aws_subnet.tf-pubsub-web-az1.id], [aws_subnet.tf-pubsub-web-az2.id]) # list/massiv
}

locals {
  private_subnets = concat([aws_subnet.tf-privsub-db-az1.id], [aws_subnet.tf-privsub-db-az2.id]) # list/massiv
}