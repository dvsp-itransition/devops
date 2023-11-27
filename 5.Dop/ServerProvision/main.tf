provider "aws" {
  region = "us-east-2"
}

variable "myhosts" {
  type = map(any)
  default = {
    nginx = {
      type       = "t2.medium"
      scriptfile = "nginx.sh"
      key        = "ubuntu"
      ssh_user   = "ubuntu"
    }
    apache = {
      type       = "t2.medium"
      scriptfile = "apache.sh"
      key        = "amazon2023"
      ssh_user   = "ec2-user"
    }
  }
}

module "sec_group" {
  source = "./modules/sec_group"
  ip  = "0.0.0.0/0"
}

module "server" {
  for_each   = var.myhosts
  servername = each.key
  type       = each.value.type
  scriptfile = each.value.scriptfile
  key        = each.value.key
  ssh_user   = each.value.ssh_user
  keyfile    = "dvsp"
  source     = "./modules/instance"
  sec_gr     = module.sec_group.web_sg
  volumesize = "8"
}








