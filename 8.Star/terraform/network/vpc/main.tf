resource "aws_vpc" "dev-vpc" {
  cidr_block           = var.vpc
  enable_dns_hostnames = true

  tags = {
    Name = "dev-vpc"
  }
}

resource "aws_internet_gateway" "dev-ig" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    Name = "dev-ig"
  }
}




