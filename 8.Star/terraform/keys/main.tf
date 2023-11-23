resource "tls_private_key" "tf-priv-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "tf-keypair" {
  key_name   = var.key_name
  public_key = tls_private_key.tf-priv-key.public_key_openssh
}

resource "local_sensitive_file" "pem_file" {
  filename        = pathexpand("./${var.key_name}.pem")
  file_permission = "400"
  content         = tls_private_key.tf-priv-key.private_key_pem
}

variable "key_name" { }

