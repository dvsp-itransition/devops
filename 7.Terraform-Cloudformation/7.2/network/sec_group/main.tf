
# Security Group for ELB
resource "aws_security_group" "ELB-SG-TF" { 

  name   = "ELB-SG-TF" 
  vpc_id = var.vpc_id

  ingress { 
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ELB-SG-TF"
  }
}

resource "aws_security_group" "tf-web-SG" {
  name   = "tf-web-SG"
  vpc_id = var.vpc_id

  # allow SSH from my ip
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # allow HTTP only for ELB
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = ["${aws_security_group.ELB-SG-TF.id}"]
  }

  # allow HTTPs only for ELB
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = ["${aws_security_group.ELB-SG-TF.id}"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf-web-SG "
  }
}

# Security Group for RDS
resource "aws_security_group" "TF-RDS-SG" {
  name   = "TF-RDS-SG"
  vpc_id = var.vpc_id

  depends_on = [ aws_security_group.tf-web-SG ]

  ingress {   # allow db_port for web-sg
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = ["${aws_security_group.tf-web-SG.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.subnet["pub_az1"], var.subnet["priv_az1"], var.subnet["pub_az2"], var.subnet["priv_az2"]]
  }

  tags = {
    Name = "TF-RDS-SG"
  }
}

# Security Group for Redis
resource "aws_security_group" "TF-Redis-SG" {
  name   = "TF-Redis-SG"
  vpc_id = var.vpc_id

  ingress {   # allows traffic inside the VPC
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.subnet["pub_az1"], var.subnet["priv_az1"], var.subnet["pub_az2"], var.subnet["priv_az2"]]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.subnet["pub_az1"], var.subnet["priv_az1"], var.subnet["pub_az2"], var.subnet["priv_az2"]]
  }

  tags = {
    Name = "TF-Redis-SG"
  }
}

# Security Group for Memcached
resource "aws_security_group" "TF-Memcached-SG" {
  name   = "TF-Memcached-SG"
  vpc_id = var.vpc_id

  depends_on = [ aws_security_group.tf-web-SG ]

  ingress {  
    from_port   = 11211
    to_port     = 11211
    protocol    = "tcp"
    security_groups = ["${aws_security_group.tf-web-SG.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.subnet["pub_az1"], var.subnet["priv_az1"], var.subnet["pub_az2"], var.subnet["priv_az2"]]
  }

  tags = {
    Name = "TF-Memcached-SG"
  }
}

