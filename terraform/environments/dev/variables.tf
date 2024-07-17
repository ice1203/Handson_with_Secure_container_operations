variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "allowed cidr blocks"
  default     = ["0.0.0.0/0"]

}
