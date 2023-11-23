output "public_ip" {
  value = [
    for instance in aws_instance.lamp : instance.public_ip
  ]
}

output "instance_ids" { # lists/massives
  value = [
    for instance in aws_instance.lamp : instance.id
  ]
}



