output "instance_ids" {
  value = { for k, i in aws_instance.this : k => i.id }
}

# name -> Elastic IP. Point DNS / subdomains at these.
output "public_ips" {
  value = { for k, e in aws_eip.this : k => e.public_ip }
}

output "private_ips" {
  value = { for k, i in aws_instance.this : k => i.private_ip }
}

output "key_name" {
  value = local.key_name
}

output "private_key_path" {
  description = "Path to the generated SSH private key (empty if using existing)."
  value       = var.create_key_pair ? local_sensitive_file.private_key[0].filename : ""
}
