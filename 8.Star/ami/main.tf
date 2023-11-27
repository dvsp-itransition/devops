provider "aws" {
  region = "us-east-2"
}

variable "myhosts" {
  type = map(any)
  default = {
    ami = {
      type       = "t2.medium"
      scriptfile = "lamp.sh"
      key        = "amazon2023"
      ssh_user   = "ec2-user"
    }
  }
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
  volumesize = "8"
}








