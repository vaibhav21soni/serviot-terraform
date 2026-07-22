output "vpc_id" {
  value = aws_vpc.this.id
}

# Sorted lists so downstream index [0] is deterministic.
output "public_subnet_ids" {
  value = [for k in sort(keys(aws_subnet.public)) : aws_subnet.public[k].id]
}

output "private_subnet_ids" {
  value = [for k in sort(keys(aws_subnet.private)) : aws_subnet.private[k].id]
}
