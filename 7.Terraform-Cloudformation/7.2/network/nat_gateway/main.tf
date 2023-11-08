# creates elastic IP for NAT gateway
resource "aws_eip" "Nat-Gateway-EIP" {
  count = 2
  tags = {
    Name = "Nat-Gateway-EIP-${count.index + 1}"
  }
}

# creates NAT Gateway
resource "aws_nat_gateway" "NAT-Gateway-AZ1" {
  count = 2

  # explicit dependency on the Internet Gateway 
  depends_on = [ aws_eip.Nat-Gateway-EIP ] 

  # allocates elastic IP to NATGW
  allocation_id = aws_eip.Nat-Gateway-EIP[count.index].id    
  subnet_id = var.private_subnets[count.index]

  tags = {
    Name = "NAT-Gateway-AZ${count.index + 1}"
  }
}

# Creates a RouteTable for the created NATGW
resource "aws_route_table" "RT-Private-NATGW" {
  count = 2
  vpc_id = var.vpc_id

  depends_on = [ aws_nat_gateway.NAT-Gateway-AZ1 ]

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.NAT-Gateway-AZ1[count.index].id
  }    

  tags = {
      Name = "RT-Private-NATGW-${count.index + 1}"
  }
}

# Association private subnet with NATGW Route
resource "aws_route_table_association" "NATGW-RT-Ass" {
  count = 2
  
  subnet_id      = var.private_subnets[count.index]
  route_table_id = aws_route_table.RT-Private-NATGW[count.index].id
}




