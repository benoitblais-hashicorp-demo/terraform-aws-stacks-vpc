# AWS VPC
component "vpc" {
  for_each = var.regions

  source = "./modules/aws-vpc"

  inputs = {
    vpc_name           = var.vpc_name
    vpc_cidr           = var.vpc_cidr
    single_nat_gateway = var.single_nat_gateway
    tags               = var.tags
  }

  providers = {
    aws = provider.aws.configurations[each.value]
  }
}
