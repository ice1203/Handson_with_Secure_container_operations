locals {
  sys_name = "ecs"
  env_name = "handson"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "${local.sys_name}-${local.env_name}-vpc"
  cidr = "172.18.0.0/16"

  azs             = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  private_subnets = ["172.18.0.0/24", "172.18.1.0/24", "172.18.2.0/24"]
  public_subnets  = ["172.18.128.0/24", "172.18.129.0/24", "172.18.130.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_vpn_gateway   = false
  enable_dns_hostnames = true

  enable_flow_log                      = false
  flow_log_max_aggregation_interval    = 60
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  tags = {
    Environment = local.env_name
  }
}
module "frontend-ecr" {
  source = "./modules/ecr"

  sys_name    = local.sys_name
  env_name    = local.env_name
  subsys_name = "frontend"

}
module "frontend-ecs" {
  source = "./modules/ecs"

  sys_name              = local.sys_name
  env_name              = local.env_name
  subsys_name           = "frontend"
  vpc_id                = module.vpc.vpc_id
  private_subnets       = module.vpc.private_subnets
  public_subnets        = module.vpc.public_subnets
  alb_listener_port     = 80
  docker_container_port = 80
  #ecr_repository_url    = module.frontend-ecr.ecr_repository_url
  alb_allowed_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  allowed_cidr_blocks     = var.allowed_cidr_blocks

}
