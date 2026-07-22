output "access_key_id" {
  value     = aws_iam_access_key.reviewer.id
  sensitive = true
}

output "secret_access_key" {
  value     = aws_iam_access_key.reviewer.secret
  sensitive = true
}

output "username" {
  value = aws_iam_user.reviewer.name
}

output "console_password" {
  value     = aws_iam_user_login_profile.reviewer.password
  sensitive = true
}

output "console_login_url" {
  value = "https://${data.aws_caller_identity.current.account_id}.signin.aws.amazon.com/console"
}
