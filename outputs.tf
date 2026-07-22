# name -> Elastic IP for every instance (app, jenkins). Point DNS here.
output "instance_public_ips" {
  description = "Elastic IPs keyed by instance name."
  value       = module.compute.public_ips
}

output "jenkins_url" {
  # Jenkins serves plain HTTP on this port (no TLS by default). Front it with
  # Nginx + a cert for HTTPS. Reachable only from admin_ip_cidr.
  description = "Jenkins UI (HTTP, admin_ip_cidr only)."
  value       = "http://${module.compute.public_ips["jenkins"]}:${var.jenkins_port}"
}

output "app_url" {
  description = "App server public entry (via Nginx)."
  value       = "https://${module.compute.public_ips["app"]}"
}

output "ssh_key_name" {
  description = "EC2 key pair name in use."
  value       = module.compute.key_name
}

output "ssh_private_key_path" {
  description = "Local path to the generated private key (empty if reusing an existing key)."
  value       = module.compute.private_key_path
}

output "rds_endpoint" {
  description = "Private RDS endpoint. Reachable only from the app server."
  value       = module.database.endpoint
}

output "reviewer_username" {
  description = "IAM console username."
  value       = module.iam.username
}

output "reviewer_console_url" {
  description = "AWS console sign-in URL for the reviewer."
  value       = module.iam.console_login_url
}

output "reviewer_console_password" {
  description = "Get with: terraform output -raw reviewer_console_password"
  value       = module.iam.console_password
  sensitive   = true
}

output "reviewer_access_key_id" {
  description = "Send to reviewer OUT OF BAND (email), never commit."
  value       = module.iam.access_key_id
  sensitive   = true
}

output "reviewer_secret_access_key" {
  description = "Get with: terraform output -raw reviewer_secret_access_key"
  value       = module.iam.secret_access_key
  sensitive   = true
}
