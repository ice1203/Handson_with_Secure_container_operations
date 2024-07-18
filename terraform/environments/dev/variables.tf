variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "allowed cidr blocks"
  default     = ["0.0.0.0/0"]

}

variable "sysdig_agent_access_key" {
  type        = string
  description = "Sysdig agent access key"
  sensitive   = true

}
#variable "secure_api_token" {
#  type        = string
#  description = "Sysdig Secure API token"
#  sensitive = true
#
#}
