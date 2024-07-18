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

  enable_nat_gateway                   = true
  single_nat_gateway                   = true
  enable_vpn_gateway                   = false
  enable_dns_hostnames                 = true
  manage_default_network_acl           = true
  enable_flow_log                      = false
  flow_log_max_aggregation_interval    = 60
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true
  default_network_acl_egress = [
    {
      protocol   = "-1"
      rule_no    = 100
      action     = "deny"
      cidr_block = "49.12.80.40/32"
    }
  ]

  tags = {
    Environment = local.env_name
  }
}

module "fargate-orchestrator-agent" {
  source  = "sysdiglabs/fargate-orchestrator-agent/aws"
  version = "0.4.1"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  access_key = var.sysdig_agent_access_key

  collector_host = "ingest-us2.app.sysdig.com"
  collector_port = "6443"

  name        = "sysdig-orchestrator"
  agent_image = "quay.io/sysdig/orchestrator-agent:latest"

  # True if the VPC uses an InternetGateway, false otherwise
  assign_public_ip = false

  tags = {
    description = "Sysdig Serverless Agent Orchestrator"
  }
}
module "frontend-ecr" {
  source = "../../modules/ecr"

  sys_name    = local.sys_name
  env_name    = local.env_name
  subsys_name = "frontend"

}
module "frontend-ecs" {
  source = "../../modules/ecs"

  sys_name    = local.sys_name
  env_name    = local.env_name
  subsys_name = "frontend"
  vpc_id      = module.vpc.vpc_id
  #private_subnets       = module.vpc.private_subnets
  public_subnets        = module.vpc.public_subnets
  alb_listener_port     = 80
  docker_container_port = 8080
  #ecr_repository_url    = module.frontend-ecr.ecr_repository_url
  alb_allowed_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  allowed_cidr_blocks     = var.allowed_cidr_blocks

}
