# AWS VPC Module

Creates an AWS VPC with public and private subnets across three availability zones, a NAT gateway, and the required subnet tags for EKS load balancer discovery.

## Usage

```hcl
module "vpc" {
  source  = "app.terraform.io/benoitblais-hashicorp/vpc/aws"
  version = "~> 1.0"

  vpc_name = "my-vpc"
  vpc_cidr = "10.0.0.0/16"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| aws | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| vpc | terraform-aws-modules/vpc/aws | 6.6.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vpc\_name | Name of the VPC. Used as a tag and name prefix for all subnet resources. | `string` | n/a | yes |
| vpc\_cidr | IPv4 CIDR block for the VPC (e.g. `10.0.0.0/16`). | `string` | n/a | yes |
| single\_nat\_gateway | Use a single NAT gateway for all private subnets. Reduces cost; not recommended for production HA. | `bool` | `true` | no |
| tags | Additional tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc\_id | The ID of the VPC. |
| private\_subnets | List of IDs of private subnets. |
| public\_subnets | List of IDs of public subnets. |
| route\_table\_id | List of IDs of private route tables. |
| vpc\_cidr\_block | The CIDR block of the VPC. |
