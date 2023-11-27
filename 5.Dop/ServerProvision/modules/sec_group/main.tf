resource "aws_security_group" "web_sg" {
  name   = "web_sg"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.ip]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_sg"
  }
}

variable "ip" {}

output "web_sg" {
  value = aws_security_group.web_sg.id
}




