variable "aws_identity_token" {
  description = "(Required) Ephemeral AWS identity token for authentication with AWS services."
  type        = string
  ephemeral   = true
  sensitive   = true
}

variable "role_arn" {
  description = "(Required) ARN of the IAM role to assume for AWS operations."
  type        = string
}

variable "vpc_cidr" {
  description = "(Required) CIDR block for the VPC network (e.g. '10.0.0.0/16')."
  type        = string
}

variable "vpc_name" {
  description = "(Required) Name of the VPC to be created."
  type        = string
}

variable "regions" {
  description = "(Optional) Set of AWS regions where the VPC will be deployed."
  type        = set(string)
  default     = ["ca-central-1"]
}

variable "single_nat_gateway" {
  description = "(Optional) Use a single NAT gateway for all private subnets. Reduces cost; not recommended for production HA."
  type        = bool
  default     = true
}

variable "tags" {
  description = "(Optional) Additional tags to apply to all VPC resources."
  type        = map(string)
  default     = {}
}
