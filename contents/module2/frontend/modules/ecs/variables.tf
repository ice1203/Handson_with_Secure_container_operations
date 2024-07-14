variable "sys_name" {
  type        = string
  description = "system name"

}
variable "subsys_name" {
  type        = string
  description = "sub system name"

}
variable "env_name" {
  type        = string
  description = "environment name"

}
variable "vpc_id" {
  type        = string
  description = "vpc id"

}
variable "public_subnets" {
  type        = list(string)
  description = "public subnets"

}
variable "private_subnets" {
  type        = list(string)
  description = "private subnets"

}
variable "alb_listener_port" {
  type        = number
  description = "alb listener port"

}
variable "docker_container_port" {
  type        = number
  description = "docker container port"

}
#variable "ecr_repository_url" {
#  type        = string
#  description = "ecr repository url"
#
#}
variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "allowed cidr blocks"

}
variable "alb_allowed_cidr_blocks" {
  type        = list(string)
  description = "alb allowed cidr blocks"

}
