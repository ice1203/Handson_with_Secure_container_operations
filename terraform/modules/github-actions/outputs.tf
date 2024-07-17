output "role_name" {
  value       = aws_iam_role.githubactions.name
  description = "The role name for the GitHub Actions service"
}
