output "vpc_id" {
  description = "The ID of the spoke VPC"
  value       = aws_vpc.spoke.id
}

output "public_subnet_id" {
  value = aws_subnet.public_a.id
}

output "private_subnet_id" {
  value = aws_subnet.private_a.id
}
