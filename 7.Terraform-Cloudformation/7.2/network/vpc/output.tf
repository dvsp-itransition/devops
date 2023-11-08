output "vpc" {
  value = aws_vpc.tf-VPC.cidr_block
}

output "vpc_id" {
  value = aws_vpc.tf-VPC.id
}

output "vpc_gateway_id" {
  value = aws_internet_gateway.tf-IG.id
}
