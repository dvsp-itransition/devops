output "vpc" {
  value = aws_vpc.dev-vpc.cidr_block
}

output "vpc_id" {
  value = aws_vpc.dev-vpc.id
}

output "vpc_gateway_id" {
  value = aws_internet_gateway.dev-ig.id
}
