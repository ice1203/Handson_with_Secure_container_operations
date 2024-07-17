terraform {
  backend "s3" {
    key                        = "common/handson_ecs/tfstate"
    region                     = "ap-northeast-1"
    terraform_state_lock_table = "tmp-hands-on-tf-state-lock"
  }
}
