output "NatGW-ids" {
  value = aws_nat_gateway.NAT-Gateway-AZ1.*.id  
}
output "elastic-ips" {
  value = aws_eip.Nat-Gateway-EIP.*.public_ip
}