terraform {
  backend "s3" {
    key                        = "module2/ecs/tfstate"
    region                     = "ap-northeast-1"
    terraform_state_lock_table = "tmp-hands-on-tf-state-lock"
  }
}
