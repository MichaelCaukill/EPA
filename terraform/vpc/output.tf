output "vpc_id" {
  value = aws_vpc.main.id
}

output "igw_id" {
  value = aws_internet_gateway.prod_igw.id
}

output "subnet_id_a" {
  value = aws_subnet.public_a.id
}

output "subnet_id_b" {
  value = aws_subnet.public_b.id
}