resource "aws_instance" "lamp" {
  count = 1
  ami = var.ami
  instance_type = var.type
  key_name = var.key_name
  subnet_id = var.subnet_id[count.index]
  vpc_security_group_ids = [ var.sg_id]  
  associate_public_ip_address = var.use_pubip

  root_block_device {
    volume_size = var.volumeSize
  }

  tags = {
    Name = var.servername
  }  
}















