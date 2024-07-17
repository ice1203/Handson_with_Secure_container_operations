output "github_actions_rolename" {
  value       = module.githubactions_role.role_name
  description = "The role name for the GitHub Actions service"
}
