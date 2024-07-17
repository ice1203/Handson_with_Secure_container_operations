data "aws_caller_identity" "current" {}
locals {
  sys_name       = "ecs"
  env_name       = "handson"
  aws_account_id = data.aws_caller_identity.current.account_id
}

module "githubactions_role" {
  source = "../../modules/github-actions"

  sys_name       = local.sys_name
  env_name       = local.env_name
  github_owner   = "ice1203"
  github_repo    = "Handson_with_Secure_container_operations"
  aws_account_id = local.aws_account_id

}
