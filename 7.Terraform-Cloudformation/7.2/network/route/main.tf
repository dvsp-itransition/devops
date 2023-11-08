data "aws_availability_zones" "all" {}

resource "aws_route_table" "RT-Public-IG" {
  vpc_id = var.vpc_id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.vpc_gateway_id
  }

  tags = {
    Name = "RT-Public-IG"
  }
}

# Associataion the RouteTable to the Subnets
resource "aws_route_table_association" "tf-pubsub-web" {
  count = 2
  subnet_id      = var.public_subnets[count.index]
  route_table_id = aws_route_table.RT-Public-IG.id
}
