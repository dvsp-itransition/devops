# Associatation ACL with private subnet
resource "aws_network_acl_association" "priv-az" {
  count = 2
  network_acl_id = aws_network_acl.tf-db-NACL.id
  subnet_id      = var.private_subnets[count.index]
}

# Create ACL for private subnet
resource "aws_network_acl" "tf-db-NACL" {
  vpc_id = var.vpc_id

  ingress {
    protocol   = -1
    rule_no    = 101
    action     = "allow"
    cidr_block = var.subnet["pub_az1"]
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 102
    action     = "allow"
    cidr_block = var.subnet["priv_az1"]
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = -1
    rule_no    = 103
    action     = "allow"
    cidr_block = var.subnet["pub_az2"]
    from_port  = 0
    to_port    = 0
  }


  ingress {
    protocol   = -1
    rule_no    = 104
    action     = "allow"
    cidr_block = var.subnet["priv_az2"]
    from_port  = 0
    to_port    = 0
  }


  egress {
    protocol   = -1
    rule_no    = 101
    action     = "allow"
    cidr_block = var.subnet["pub_az1"]
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 102
    action     = "allow"
    cidr_block = var.subnet["priv_az1"]
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 103
    action     = "allow"
    cidr_block = var.subnet["pub_az2"]
    from_port  = 0
    to_port    = 0
  }


  egress {
    protocol   = -1
    rule_no    = 104
    action     = "allow"
    cidr_block = var.subnet["priv_az2"]
    from_port  = 0
    to_port    = 0
  }


  tags = {
    Name = "tf-db-NACL"
  }
}


