variable "vpc_name" {
  description = "(Required) Name of the VPC. Used as a tag and name prefix for all subnet resources."
  type        = string

  validation {
    condition     = length(var.vpc_name) > 0
    error_message = "vpc_name must not be empty."
  }
}

variable "vpc_cidr" {
  description = "(Required) IPv4 CIDR block for the VPC (e.g. '10.0.0.0/16')."
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "single_nat_gateway" {
  description = "(Optional) Use a single NAT gateway for all private subnets. Reduces cost; not recommended for production HA. Defaults to true."
  type        = bool
  default     = true
}

variable "tags" {
  description = "(Optional) Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}
