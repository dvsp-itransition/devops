resource "aws_instance" "ex1" {
  ami = var.ami[var.key]
  instance_type = var.type
  key_name = var.keyfile
  
  root_block_device {
    volume_size = var.volumesize
  }

  tags = {
    Name = var.servername
  }
  
  provisioner "file" {
    source      = var.scriptfile
    destination = "/tmp/${var.scriptfile}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/${var.scriptfile}",
      "sudo /tmp/${var.scriptfile}",
    ]
  }

  connection {
    type     = "ssh"
    user     = var.ssh_user
    private_key = file("~/Downloads/dvsp.pem")
    host     = self.public_ip
  }
}

variable "scriptfile" {}
variable "ami" {
  type = map
  default = {
    "ubuntu" = "ami-06c4532923d4ba1ec"
    "amazon2023" = "ami-06d4b7182ac3480fa"
    "amazonlinux" = "ami-09f85f3aaae282910"
  }
}

variable "key" { 
}

variable "ssh_user" { 
  
}

variable "type" {
  default = "t2.micro"
}

variable "keyfile" {
  default = "terraform"
}

variable "servername" {
  default = "servername"
}

variable "volumesize" {
  type = number
  default = "8"  
}



