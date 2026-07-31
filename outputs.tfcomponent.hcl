output "vpc_id" {
  description = "The ID of the VPC, keyed by region."
  type        = map(string)
  value       = { for region in var.regions : region => component.vpc[region].vpc_id }
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC, keyed by region."
  type        = map(string)
  value       = { for region in var.regions : region => component.vpc[region].vpc_cidr_block }
}

output "private_subnets" {
  description = "List of private subnet IDs, keyed by region."
  type        = map(list(string))
  value       = { for region in var.regions : region => component.vpc[region].private_subnets }
}

output "public_subnets" {
  description = "List of public subnet IDs, keyed by region."
  type        = map(list(string))
  value       = { for region in var.regions : region => component.vpc[region].public_subnets }
}

output "route_table_id" {
  description = "List of private route table IDs, keyed by region."
  type        = map(list(string))
  value       = { for region in var.regions : region => component.vpc[region].route_table_id }
}
