data "aws_availability_zones" "all" {}

# Creates Public subnet in AZ1
resource "aws_subnet" "tf-pubsub-web-az1" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet["pub_az1"]
  availability_zone       = data.aws_availability_zones.all.names[0]
  map_public_ip_on_launch = true
  

  tags = {
    Name = "tf-pubsub-web-az1"
  }
  
}

# Creates Public subnet in AZ2
resource "aws_subnet" "tf-pubsub-web-az2" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet["pub_az2"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.all.names[1]

  tags = {
    Name = "tf-pubsub-web-az2"
  }
}

# Creates private subnet in AZ1
resource "aws_subnet" "tf-privsub-db-az1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet["priv_az1"]
  availability_zone = data.aws_availability_zones.all.names[0]

  tags = {
    Name = "tf-privsub-db-az1"
  }
}

# Creates private subnet in AZ2
resource "aws_subnet" "tf-privsub-db-az2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet["priv_az2"]
  availability_zone = data.aws_availability_zones.all.names[1]

  tags = {
    Name = "tf-privsub-db-az2"
  }
}



