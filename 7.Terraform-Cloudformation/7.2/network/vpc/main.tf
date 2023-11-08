# creates VPC
resource "aws_vpc" "tf-VPC" {
  cidr_block           = var.vpc
  enable_dns_hostnames = true

  tags = {
    Name = "TF-VPC"
  }
}

# Create an IGW for the new VPC
resource "aws_internet_gateway" "tf-IG" {
  vpc_id = aws_vpc.tf-VPC.id

  tags = {
    Name = "tf-IG"
  }
}




