data "aws_availability_zones" "all" {}

resource "aws_subnet" "dev-subnet" {
  count = length(var.subnet)
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet[count.index]
  availability_zone       = data.aws_availability_zones.all.names[count.index] 

  tags = {
    Name = "dev-subnet"
  }  
}








